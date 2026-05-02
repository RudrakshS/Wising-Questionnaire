"""
WISING TAX ENGINE — app/engine/gate_evaluator.py
ENABLED-IF Gate Evaluator + Completion Percentage Engine.
Source: sprint1_input_layer_PATCHED.py Sections 7–8.

GAP-003 FIX: `contains` operator added for v5.1 array-enum gates.
GAP-004 FIX: `eq` correctly handles `value: []` (empty array check).
GAP-005 FIX: empty [] is NOT "filled" for array-type required fields.

Operator semantics:
  eq       : actual == expected (handles [] == [] for empty-array check)
  neq      : actual != expected
  gt       : actual > expected  (numeric; None → False)
  gte      : actual >= expected (numeric; None → False)
  lt       : actual < expected  (numeric; None → False)
  in       : actual is one of expected list
  contains : actual list contains the expected scalar
             Used for: "s44AD" IN presumptive_scheme
"""
from __future__ import annotations

from dataclasses import asdict
from typing import Any

from app.models.tax_state import TaxEngineState


def evaluate_gate(gate_json: dict | None, context: dict) -> bool:
    """
    Evaluate an ENABLED IF gate expression against a context dict.

    Supported gate formats (field_registry.enabled_if JSONB):
      {"field": "path", "op": "eq",       "value": <scalar|[]>}
      {"field": "path", "op": "neq",      "value": <scalar>}
      {"field": "path", "op": "gt",       "value": <number>}
      {"field": "path", "op": "gte",      "value": <number>}
      {"field": "path", "op": "lt",       "value": <number>}
      {"field": "path", "op": "in",       "value": [<scalars>]}   # IN list check
      {"field": "path", "op": "contains", "value": <scalar>}      # list CONTAINS value
      {"and": [...conditions...]}
      {"or":  [...conditions...]}
    """
    if gate_json is None:
        return True  # No gate = always visible

    # Fields with _parse_error in their gate cannot be evaluated → hide
    if gate_json.get("_parse_error"):
        return False

    if "and" in gate_json:
        return all(evaluate_gate(c, context) for c in gate_json["and"])

    if "or" in gate_json:
        return any(evaluate_gate(c, context) for c in gate_json["or"])

    # ── Single condition ──────────────────────────────────────────────
    field_path = gate_json.get("field", "")
    op = gate_json.get("op", "eq")
    expected = gate_json.get("value")

    # Resolve field value from context using dotted path.
    # Supports: "layer0.india_days", "layer1_india.residency_detail.days_..."
    # Also handles array-path notation like "parent[].field" — stripped.
    actual: Any = context
    for part in field_path.split("."):
        # Strip array-template notation: "goods_vehicles[]" → "goods_vehicles"
        part = part.rstrip("[]").rstrip("][")
        if isinstance(actual, dict):
            actual = actual.get(part)
        elif hasattr(actual, part):
            actual = getattr(actual, part)
        else:
            actual = None
            break

    # ── Operator dispatch ─────────────────────────────────────────────
    if op == "eq":
        # GAP-004: empty-array check — [] == [] must be True.
        # isinstance guard prevents None == [] from accidentally passing.
        if expected == [] and not isinstance(actual, list):
            return False
        return actual == expected

    elif op == "neq":
        return actual != expected

    elif op == "gt":
        return actual is not None and actual > expected

    elif op == "gte":
        return actual is not None and actual >= expected

    elif op == "lt":
        return actual is not None and actual < expected

    elif op == "in":
        # "actual is one of the expected list"
        # e.g. {"field": "india_lock", "op": "in", "value": ["ROR","RNOR"]}
        if isinstance(expected, list):
            return actual in expected
        return False

    elif op == "contains":
        # GAP-003: "expected scalar is inside the actual list-field"
        # e.g. {"field": "layer1_india.domestic_income.business_income.presumptive_scheme",
        #        "op": "contains", "value": "s44AD"}
        if isinstance(actual, list):
            return expected in actual
        return False

    elif op == "not_in":
        # actual is NOT one of the expected list values AND is not null
        if isinstance(expected, list):
            return actual is not None and actual not in expected
        return False

    return False


def compute_completion_pct(
    state: TaxEngineState,
    field_registry: list[dict],
) -> tuple[int, dict]:
    """
    Compute completion percentage from field_registry rows.

    Formula: filled_relevant_required / total_relevant_required × 100
    No weighting. No probabilistic scoring.

    Rules:
    - DERIVED fields are excluded entirely.
    - OPTIONAL fields are excluded from the denominator.
    - CONDITIONAL fields only count when their gate is open.
    - A field is "filled" when its value is not None AND not an empty
      list (GAP-005 fix: empty [] for a required array field means the
      user has not provided any items — it is NOT filled).

    Args:
        state: Current engine state
        field_registry: List of field_registry rows (dicts with
                       field_path, classification, enabled_if, section)

    Returns:
        (percentage: int, detail: dict with per-section breakdown and
         missing_required list)
    """
    context = {
        "layer0": asdict(state.layer0),
        "layer1_india": asdict(state.india_residency) if state.india_residency else {},
        "layer1_us": asdict(state.us_residency) if state.us_residency else {},
    }

    total_required = 0
    filled_required = 0
    missing_required: list[str] = []
    missing_required_labels: list[str] = []
    section_detail: dict = {}

    for field_def in field_registry:
        cls = field_def.get("classification")
        if cls == "DERIVED":
            continue  # Excluded from completion UI

        if cls == "OPTIONAL":
            continue  # Excluded from denominator

        # For CONDITIONAL fields, check if gate is active
        if cls == "CONDITIONAL":
            gate = field_def.get("enabled_if")
            if not evaluate_gate(gate, context):
                continue  # Gate closed → not counted

        # At this point cls is REQUIRED or CONDITIONAL-with-open-gate
        if cls in ("REQUIRED", "CONDITIONAL"):
            total_required += 1

            # Resolve field value from context using dotted path
            field_path = field_def.get("field_path", "")
            value: Any = context
            for part in field_path.split("."):
                part = part.rstrip("[]").rstrip("][")
                if isinstance(value, dict):
                    value = value.get(part)
                else:
                    value = None
                    break

            # GAP-005 FIX: An empty list [] is NOT "filled".
            is_filled = (
                value is not None
                and not (isinstance(value, list) and len(value) == 0)
            )

            if is_filled:
                filled_required += 1
            else:
                missing_required.append(field_path)
                missing_required_labels.append(
                    field_def.get("friendly_label", field_path)
                )

            # Per-section tracking
            section = field_def.get("section", "unknown")
            if section not in section_detail:
                section_detail[section] = {"total": 0, "filled": 0, "missing": []}
            section_detail[section]["total"] += 1
            if is_filled:
                section_detail[section]["filled"] += 1
            else:
                section_detail[section]["missing"].append(field_path)

    pct = round((filled_required / total_required * 100) if total_required > 0 else 0)

    detail = {
        "percentage": pct,
        "filled_required": filled_required,
        "total_required": total_required,
        "missing_required": missing_required[:20],        # cap for API response size
        "missing_required_labels": missing_required_labels[:20],
        "is_approximation": pct < 100,
        "filing_ready": pct == 100,
        "sections": section_detail,
    }
    return pct, detail
