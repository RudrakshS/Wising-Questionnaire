"""
WISING TAX ENGINE — app/api/profile.py
PATCH /api/profile/{session_id}/{tax_year_id}
Primary field-patch endpoint. Contract: WISING-AI-CONTRACT v1.0 Section 2.

Validation order (mandatory per spec):
  1. field_path exists in field_registry
  2. value type matches input_type
  3. enabled_if gate is open
  4. If enum, value is in enum_values
  5. If India-NR + s44AD/s44ADA → reject NR_INELIGIBLE_PRESUMPTIVE

Re-evaluation order after patch (mandatory per spec):
  1. Write to layer0_state / layer1_india / layer1_us JSONB
  2. Re-evaluate india_flag, us_flag, jurisdiction (always)
  3. If jurisdiction changed → emit JURISDICTION_CHANGED event
  4. If India residency input changed → re-fire RS-001 lock
  5. If US residency input changed → re-fire SPT lock
  6. If lock changed → emit INDIA_LOCK_CHANGED / US_LOCK_CHANGED
  7. Recompute completion_pct against field_registry
  8. Set tax_estimate_stale = true if income-relevant field changed
  9. Return full response shape from AI-CONTRACT §2.1
"""
from __future__ import annotations

import json
from dataclasses import asdict
from typing import Any, Optional

import asyncpg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.database import get_db
from app.engine.gate_evaluator import compute_completion_pct, evaluate_gate
from app.engine.india_residency import compute_ltac, evaluate_india_residency
from app.engine.layer0_router import evaluate_jurisdiction
from app.engine.us_residency import evaluate_us_residency
from app.models.india_residency import (
    EmploymentCrewStatus, IndiaResidency, IndiaResidencyDetail,
)
from app.models.layer0 import Jurisdiction, Layer0State
from app.models.tax_state import TaxEngineState, WizardPhase
from app.models.us_residency import ExemptIndividualStatus, USResidency, USResidencyDetail
from app.repository.event_repo import EventRepository
from app.repository.field_registry_repo import FieldRegistryRepository
from app.repository.snapshot_repo import SnapshotRepository

router = APIRouter()

# Fields that trigger tax_estimate_stale when changed
_INCOME_RELEVANT_SCHEMAS = {"layer1_india", "layer1_us"}
_RESIDENCY_INDIA_FIELDS = {
    "days_in_india_current_year", "days_in_india_preceding_4_years_gte_365",
    "employment_or_crew_status", "came_on_visit_to_india_pio_citizen",
    "nr_years_last_10_gte_9", "days_in_india_last_7_years_lte_729",
    "india_source_income_above_15l",
}
_RESIDENCY_US_FIELDS = {
    "us_days_current_year", "us_days_minus_1_year", "us_days_minus_2_years",
    "exempt_individual_status", "closer_connection_claim",
    "has_green_card", "i407_surrendered_date",
}


class FieldPatch(BaseModel):
    field_schema: str   # "layer0" | "layer1_india" | "layer1_us"
    field_path: str
    value: Any
    source: Optional[str] = None
    raw_utterance: Optional[str] = None
    confidence: Optional[float] = None


class BatchPatchRequest(BaseModel):
    patches: Optional[list[FieldPatch]] = None
    # Single-patch form (also supported)
    field_schema: Optional[str] = None
    field_path: Optional[str] = None
    value: Optional[Any] = None
    source: Optional[str] = None
    raw_utterance: Optional[str] = None


@router.patch("/profile/{session_id}/{tax_year_id}")
async def patch_profile(
    session_id: str,
    tax_year_id: str,
    body: BatchPatchRequest,
    pool: asyncpg.Pool = Depends(get_db),
) -> dict:
    snap_repo = SnapshotRepository(pool)
    reg_repo = FieldRegistryRepository(pool)
    event_repo = EventRepository(pool)

    snapshot = await snap_repo.get_snapshot_by_id(session_id)
    if not snapshot:
        raise HTTPException(404, "Session not found")

    all_fields = await reg_repo.get_all_fields()
    field_map = {f["field_path"]: f for f in all_fields}

    # Normalise to list of patches
    if body.patches:
        patches = body.patches
    elif body.field_path:
        patches = [FieldPatch(
            field_schema=body.field_schema or "", field_path=body.field_path,
            value=body.value, source=body.source,
        )]
    else:
        raise HTTPException(422, "Provide field_path or patches[]")

    # Build mutable state dicts
    l0_state: dict = snapshot.get("layer0_state") or {}
    l1_india: dict = snapshot.get("layer1_india") or {}
    l1_us: dict = snapshot.get("layer1_us") or {}
    old_jurisdiction = snapshot.get("jurisdiction")
    old_india_lock = snapshot.get("india_lock")
    old_us_lock = snapshot.get("us_lock")

    india_residency_changed = False
    us_residency_changed = False
    event_ids: list[str] = []

    # ── Apply each patch ──────────────────────────────────────────
    for patch in patches:
        field_def = field_map.get(patch.field_path)

        # Validation 1: field exists
        if not field_def:
            close = _find_close_match(patch.field_path, field_map)
            raise HTTPException(422, {
                "error": "UNKNOWN_FIELD_PATH",
                "field_path": patch.field_path,
                "message": f"Field not found in field_registry.",
                "did_you_mean": close,
            })

        # Validation 2: type check
        _validate_type(patch.field_path, patch.value, field_def["input_type"])

        # Build context for gate eval
        ctx = {"layer0": l0_state, "layer1_india": l1_india, "layer1_us": l1_us}

        # Validation 3: gate open
        if not evaluate_gate(field_def.get("enabled_if"), ctx):
            raise HTTPException(422, {
                "error": "GATE_CLOSED",
                "field_path": patch.field_path,
                "gate": field_def.get("enabled_if"),
                "message": "Field gate is closed — prerequisite fields not yet answered.",
            })

        # Validation 4: enum check
        if field_def["input_type"] == "enum" and field_def.get("enum_values"):
            valid = field_def["enum_values"]
            if isinstance(patch.value, list):
                bad = [v for v in patch.value if v not in valid]
                if bad:
                    raise HTTPException(422, {
                        "error": "INVALID_ENUM_VALUE",
                        "field_path": patch.field_path,
                        "received_value": patch.value,
                        "valid_values": valid,
                    })
            elif patch.value not in valid and patch.value is not None:
                raise HTTPException(422, {
                    "error": "INVALID_ENUM_VALUE",
                    "field_path": patch.field_path,
                    "received_value": patch.value,
                    "valid_values": valid,
                })

        # Validation 5: NR ineligible for s44AD/s44ADA
        if (
            patch.schema == "layer1_india"
            and "presumptive_scheme" in patch.field_path
            and isinstance(patch.value, list)
        ):
            india_lock_current = snapshot.get("india_lock")
            nr_schemes = {"s44AD", "s44ADA"}
            if india_lock_current == "NR" and nr_schemes.intersection(patch.value):
                raise HTTPException(422, {
                    "error": "NR_INELIGIBLE_PRESUMPTIVE",
                    "field_path": patch.field_path,
                    "india_lock": "NR",
                    "attempted_value": patch.value,
                    "message": "s.44AD and s.44ADA require resident assessee (ROR or RNOR).",
                    "allowed_for_nr": ["s44AE"],
                })

        # Write to appropriate JSONB blob
        field_key = patch.field_path.split(".")[-1]
        if patch.field_schema == "layer0":
            old_val = l0_state.get(field_key)
            l0_state[field_key] = patch.value
        elif patch.field_schema == "layer1_india":
            old_val = _get_nested(l1_india, patch.field_path)
            _set_nested(l1_india, patch.field_path)
            l1_india = _set_path_value(l1_india, patch.field_path, patch.value)
            if field_key in _RESIDENCY_INDIA_FIELDS:
                india_residency_changed = True
        else:
            old_val = _get_nested(l1_us, patch.field_path)
            l1_us = _set_path_value(l1_us, patch.field_path, patch.value)
            if field_key in _RESIDENCY_US_FIELDS:
                us_residency_changed = True

        eid = await event_repo.append_event(
            session_id, tax_year_id, "field_update",
            {"schema": patch.field_schema, "field": patch.field_path,
             "old": old_val, "new": patch.value},
        )
        event_ids.append(eid)

    # ── Re-evaluation (post all patches) ─────────────────────────

    # Step 2: Re-evaluate jurisdiction
    l0_obj = _dict_to_layer0(l0_state)
    l0_obj = evaluate_jurisdiction(l0_obj)
    l0_state = asdict(l0_obj)
    new_jurisdiction = l0_obj.jurisdiction.value if l0_obj.jurisdiction else None

    lock_changed = False
    lock_change_alert = None

    # Step 3: Jurisdiction change event
    if new_jurisdiction != old_jurisdiction:
        await event_repo.append_event(
            session_id, tax_year_id, "jurisdiction_changed",
            {"old": old_jurisdiction, "new": new_jurisdiction},
            caused_by=event_ids[-1] if event_ids else None,
        )

    # Step 4: Re-fire India lock if residency inputs changed
    new_india_lock = old_india_lock
    if india_residency_changed or "india_days" in [p.field_path.split(".")[-1] for p in patches]:
        rd = l1_india.get("residency_detail", l1_india)
        india_rd = _dict_to_india_residency(rd)
        result = evaluate_india_residency(l0_obj, india_rd)
        new_india_lock = result.status.value
        if "residency_detail" in l1_india:
            l1_india["residency_detail"]["final_india_residency_status"] = new_india_lock
        else:
            l1_india["final_india_residency_status"] = new_india_lock

    # Step 5: Re-fire US lock if residency inputs changed
    new_us_lock = old_us_lock
    if us_residency_changed:
        urd = l1_us.get("us_residency_detail", l1_us)
        us_rd = _dict_to_us_residency(urd)
        result_us = evaluate_us_residency(us_rd)
        new_us_lock = result_us.status.value
        if "us_residency_detail" in l1_us:
            l1_us["us_residency_detail"]["final_us_residency_status"] = new_us_lock
        else:
            l1_us["final_us_residency_status"] = new_us_lock

    # Step 6: Lock change events + alert
    if new_india_lock != old_india_lock or new_us_lock != old_us_lock:
        lock_changed = True
        lock_change_alert = {
            "type": "INDIA_LOCK_CHANGED" if new_india_lock != old_india_lock else "US_LOCK_CHANGED",
            "previous_india_lock": old_india_lock,
            "new_india_lock": new_india_lock,
            "previous_us_lock": old_us_lock,
            "new_us_lock": new_us_lock,
            "message": "Residency status has changed. Review newly visible/hidden sections.",
        }
        await event_repo.append_event(
            session_id, tax_year_id, "lock_changed", lock_change_alert,
            caused_by=event_ids[-1] if event_ids else None,
        )

    # Step 7: Recompute completion
    state = TaxEngineState(id=session_id, user_id=session_id, tax_year_id=tax_year_id)
    state.layer0 = l0_obj
    if l1_india:
        state.india_residency = _dict_to_india_residency(l1_india.get("residency_detail", l1_india))
    if l1_us:
        state.us_residency = _dict_to_us_residency(l1_us.get("us_residency_detail", l1_us))

    all_field_dicts = all_fields
    pct, detail = compute_completion_pct(state, all_field_dicts)

    # Step 8: tax_estimate_stale
    tax_estimate_stale = any(p.field_schema in _INCOME_RELEVANT_SCHEMAS for p in patches)

    # Determine wizard phase
    wizard_phase = _derive_wizard_phase(new_jurisdiction, new_india_lock, new_us_lock, pct)

    # Get next required fields
    ctx_new = {"layer0": l0_state, "layer1_india": l1_india, "layer1_us": l1_us}
    next_required = _get_next_required(all_fields, ctx_new, new_jurisdiction)

    # Persist upsert
    await snap_repo.upsert_snapshot({
        "id": session_id,
        "layer0_state": l0_state,
        "layer1_india": l1_india if l1_india else None,
        "layer1_us": l1_us if l1_us else None,
        "jurisdiction": new_jurisdiction,
        "india_lock": new_india_lock,
        "us_lock": new_us_lock,
        "completion_pct": pct,
        "completion_detail": detail,
        "is_approximation": pct < 100,
    })

    return {
        "session_id": session_id,
        "tax_year_id": tax_year_id,
        "jurisdiction": new_jurisdiction,
        "india_lock": new_india_lock,
        "us_lock": new_us_lock,
        "wizard_phase": wizard_phase,
        "lock_changed": lock_changed,
        "lock_change_alert": lock_change_alert,
        "completion": {
            "percentage": pct,
            "filled_required": detail["filled_required"],
            "total_required": detail["total_required"],
            "is_approximation": detail["is_approximation"],
            "filing_ready": detail["filing_ready"],
            "missing_required": detail["missing_required"],
        },
        "tax_estimate_stale": tax_estimate_stale,
        "next_required_fields": next_required,
    }


# ── Helper functions ──────────────────────────────────────────────

def _validate_type(field_path: str, value: Any, input_type: str) -> None:
    if value is None:
        return
    type_map = {
        "boolean": bool,
        "integer": (int, float),
        "array": list,
    }
    expected = type_map.get(input_type)
    if expected and not isinstance(value, expected):
        raise HTTPException(422, {
            "error": "TYPE_MISMATCH",
            "field_path": field_path,
            "expected_type": input_type,
            "received_value": value,
            "message": f"Value must be of type {input_type}.",
        })


def _find_close_match(field_path: str, field_map: dict) -> Optional[str]:
    key = field_path.split(".")[-1]
    for fp in field_map:
        if key in fp:
            return fp
    return None


def _set_path_value(obj: dict, field_path: str, value: Any) -> dict:
    """Set a value at a dotted path within a nested dict."""
    parts = field_path.split(".")
    # Skip schema prefix (layer0, layer1_india, layer1_us)
    if parts[0] in ("layer0", "layer1_india", "layer1_us"):
        parts = parts[1:]
    cur = obj
    for part in parts[:-1]:
        if part not in cur or not isinstance(cur[part], dict):
            cur[part] = {}
        cur = cur[part]
    cur[parts[-1]] = value
    return obj


def _get_nested(obj: dict, field_path: str) -> Any:
    parts = field_path.split(".")
    if parts[0] in ("layer0", "layer1_india", "layer1_us"):
        parts = parts[1:]
    cur: Any = obj
    for part in parts:
        if isinstance(cur, dict):
            cur = cur.get(part)
        else:
            return None
    return cur


def _set_nested(obj: dict, field_path: str) -> None:
    pass  # Used only for side-effect tracking


def _dict_to_layer0(d: dict) -> Layer0State:
    jur = d.get("jurisdiction")
    s = Layer0State(
        is_indian_citizen=d.get("is_indian_citizen"),
        is_pio_or_oci=d.get("is_pio_or_oci"),
        india_days=d.get("india_days"),
        has_india_source_income_or_assets=d.get("has_india_source_income_or_assets"),
        is_us_citizen=d.get("is_us_citizen"),
        has_green_card=d.get("has_green_card"),
        was_in_us_this_year=d.get("was_in_us_this_year"),
        us_days=d.get("us_days"),
        has_us_source_income_or_assets=d.get("has_us_source_income_or_assets"),
        liable_to_tax_in_another_country=d.get("liable_to_tax_in_another_country"),
        left_india_for_employment_this_year=d.get("left_india_for_employment_this_year"),
        india_flag=d.get("india_flag"),
        us_flag=d.get("us_flag"),
        jurisdiction=Jurisdiction(jur) if jur else None,
    )
    return s


def _dict_to_india_residency(d: dict) -> IndiaResidencyDetail:
    emp = d.get("employment_or_crew_status")
    fin = d.get("final_india_residency_status")
    return IndiaResidencyDetail(
        days_in_india_current_year=d.get("days_in_india_current_year"),
        days_in_india_preceding_4_years_gte_365=d.get("days_in_india_preceding_4_years_gte_365"),
        employment_or_crew_status=EmploymentCrewStatus(emp) if emp else None,
        is_departure_year=d.get("is_departure_year"),
        ship_nationality=d.get("ship_nationality"),
        came_on_visit_to_india_pio_citizen=d.get("came_on_visit_to_india_pio_citizen"),
        nr_years_last_10_gte_9=d.get("nr_years_last_10_gte_9"),
        days_in_india_last_7_years_lte_729=d.get("days_in_india_last_7_years_lte_729"),
        india_source_income_above_15l=d.get("india_source_income_above_15l"),
        final_india_residency_status=IndiaResidency(fin) if fin else None,
    )


def _dict_to_us_residency(d: dict) -> USResidencyDetail:
    ex = d.get("exempt_individual_status")
    fin = d.get("final_us_residency_status")
    return USResidencyDetail(
        is_us_citizen=d.get("is_us_citizen"),
        has_green_card=d.get("has_green_card"),
        green_card_grant_date=d.get("green_card_grant_date"),
        i407_surrendered_date=d.get("i407_surrendered_date"),
        us_days_current_year=d.get("us_days_current_year"),
        us_days_minus_1_year=d.get("us_days_minus_1_year"),
        us_days_minus_2_years=d.get("us_days_minus_2_years"),
        exempt_individual_status=ExemptIndividualStatus(ex) if ex else None,
        closer_connection_claim=d.get("closer_connection_claim"),
        first_year_choice_election=d.get("first_year_choice_election"),
        final_us_residency_status=USResidency(fin) if fin else None,
    )


def _derive_wizard_phase(
    jurisdiction: Optional[str],
    india_lock: Optional[str],
    us_lock: Optional[str],
    pct: int,
) -> str:
    if not jurisdiction:
        return WizardPhase.LAYER0_WIZARD.value
    if jurisdiction == "none":
        return WizardPhase.JURISDICTION_NONE.value
    if india_lock and us_lock:
        return WizardPhase.INCOME_SECTIONS.value if pct < 100 else WizardPhase.READY_TO_EVALUATE.value
    if india_lock:
        return WizardPhase.INDIA_LOCKED.value
    if us_lock:
        return WizardPhase.US_LOCKED.value
    if jurisdiction in ("india_only", "dual"):
        return WizardPhase.INDIA_RESIDENCY.value
    if jurisdiction == "us_only":
        return WizardPhase.US_RESIDENCY.value
    return WizardPhase.LAYER0_COMPLETE.value


def _get_next_required(
    fields: list[dict],
    context: dict,
    jurisdiction: Optional[str],
) -> list[dict]:
    """Return up to 3 next required fields that have no value yet."""
    result = []
    for f in fields:
        if f["classification"] == "DERIVED":
            continue
        if f["classification"] == "OPTIONAL":
            continue
        # Schema filter
        if f["schema_name"] == "layer1_india" and jurisdiction not in ("india_only", "dual"):
            continue
        if f["schema_name"] == "layer1_us" and jurisdiction not in ("us_only", "dual"):
            continue
        # Gate check
        if not evaluate_gate(f.get("enabled_if"), context):
            continue
        # Value check
        val = _get_nested(context.get(f["schema_name"].replace("layer1_", "layer1_"), context), f["field_path"])
        if val is None:
            result.append({
                "field_path": f["field_path"],
                "friendly_label": f["friendly_label"],
                "input_type": f["input_type"],
                "section": f["section"],
            })
        if len(result) >= 3:
            break
    return result
