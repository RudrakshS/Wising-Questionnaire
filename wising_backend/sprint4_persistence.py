"""
WISING TAX ENGINE — SPRINT 4: SECURITY & PERSISTENCE
═══════════════════════════════════════════════════════════════════
Document: WISING-IMPL-001 Sprint 4

This module implements:
  1. Database interaction layer (tax_state_snapshots, field_registry, tax_events)
  2. Soft-hide / archival logic — NEVER hard-delete
  3. FastAPI endpoint mapping
  4. Jurisdiction transition with soft-archive
"""
from __future__ import annotations

import uuid
import json
from dataclasses import asdict
from datetime import datetime
from typing import Any, Optional

# ── FastAPI imports ──
from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel, Field

from sprint1_input_layer import (
    TaxEngineState, Layer0State, WizardStateMachine,
    Jurisdiction, IndiaResidency, USResidency,
    IndiaResidencyDetail, USResidencyDetail,
    evaluate_jurisdiction,
)
from sprint2_math_dag import (
    IndiaIncomeAssembly, USIncomeAssembly,
    evaluate_tax, FullComputationResult,
)
from sprint3_output_tests import stamp_output, TaxOutputPayload


# ═══════════════════════════════════════════════════════════════════
# SECTION 1 — DATABASE LAYER
# Maps to the 4 tables from sprint1_migration_DDL_ONLY.sql:
#   tax_state_snapshots, field_registry, tax_events, bridge_events
#
# Uses asyncpg for production. This file provides the interface;
# actual SQL queries are parameterized for safety.
# ═══════════════════════════════════════════════════════════════════

class TaxStateRepository:
    """
    Persistence layer for tax_state_snapshots.
    Single active snapshot per user per tax year.

    Table schema (from sprint1_migration_DDL_ONLY.sql):
      id                UUID PRIMARY KEY
      user_id           UUID NOT NULL
      tax_year_id       UUID NOT NULL
      layer0_state      JSONB NOT NULL DEFAULT '{}'
      layer1_india      JSONB
      layer1_us         JSONB
      jurisdiction      TEXT
      india_lock        TEXT
      us_lock           TEXT
      completion_pct    INTEGER DEFAULT 0
      completion_detail JSONB DEFAULT '{}'
      computation_result JSONB
      is_approximation  BOOLEAN DEFAULT TRUE
      last_computed_at  TIMESTAMPTZ
      status            TEXT NOT NULL DEFAULT 'active'
      schema_version    TEXT NOT NULL DEFAULT 'v5.1'
      created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
      updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
    """

    def __init__(self, db_pool):
        """db_pool: asyncpg connection pool."""
        self.pool = db_pool

    async def get_active_snapshot(
        self, user_id: str, tax_year_id: str
    ) -> Optional[dict]:
        """
        Fetch the single active snapshot for a user+tax_year.
        Uses the unique index: idx_active_snapshot(user_id, tax_year_id)
                               WHERE status = 'active'
        """
        query = """
            SELECT id, user_id, tax_year_id, layer0_state, layer1_india,
                   layer1_us, jurisdiction, india_lock, us_lock,
                   completion_pct, completion_detail, computation_result,
                   is_approximation, last_computed_at, status,
                   schema_version, created_at, updated_at
            FROM tax_state_snapshots
            WHERE user_id = $1 AND tax_year_id = $2 AND status = 'active'
        """
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, user_id, tax_year_id)
            return dict(row) if row else None

    async def create_snapshot(
        self, user_id: str, tax_year_id: str, layer0_state: dict
    ) -> str:
        """
        Create a new active snapshot. Returns the snapshot ID.
        If an active snapshot already exists, raises an error.
        """
        snapshot_id = str(uuid.uuid4())
        query = """
            INSERT INTO tax_state_snapshots
                (id, user_id, tax_year_id, layer0_state, status, schema_version)
            VALUES ($1, $2, $3, $4::jsonb, 'active', 'v5.1')
            RETURNING id
        """
        async with self.pool.acquire() as conn:
            try:
                result = await conn.fetchval(
                    query, snapshot_id, user_id, tax_year_id,
                    json.dumps(layer0_state)
                )
                return result
            except Exception as e:
                if "unique" in str(e).lower():
                    raise HTTPException(
                        status_code=409,
                        detail="Active snapshot already exists for this user+tax_year"
                    )
                raise

    async def patch_layer0(
        self, snapshot_id: str, updates: dict
    ) -> dict:
        """
        PATCH Layer 0 fields. Uses JSONB merge.
        Reactively re-evaluates jurisdiction.
        """
        query = """
            UPDATE tax_state_snapshots
            SET layer0_state = layer0_state || $2::jsonb,
                updated_at = now()
            WHERE id = $1 AND status = 'active'
            RETURNING layer0_state, jurisdiction
        """
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                query, snapshot_id, json.dumps(updates)
            )
            if not row:
                raise HTTPException(404, "Snapshot not found or archived")

            # Re-evaluate jurisdiction server-side
            l0_dict = row['layer0_state']
            l0 = Layer0State(**{k: v for k, v in l0_dict.items()
                               if hasattr(Layer0State, k)})
            l0 = evaluate_jurisdiction(l0)

            # Persist derived fields
            await conn.execute("""
                UPDATE tax_state_snapshots
                SET layer0_state = $2::jsonb,
                    jurisdiction = $3,
                    updated_at = now()
                WHERE id = $1
            """, snapshot_id, json.dumps(asdict(l0)),
                l0.jurisdiction.value if l0.jurisdiction else None)

            return asdict(l0)

    async def patch_layer1_section(
        self, snapshot_id: str, layer: str, section: str, data: dict
    ) -> dict:
        """
        PATCH a Layer 1 section.
        layer: 'layer1_india' or 'layer1_us'
        section: e.g. 'residency_detail', 'property', 'salary'

        Uses JSONB path-based update to merge section data
        without overwriting other sections.
        """
        column = layer  # layer1_india or layer1_us

        # First fetch current state
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                f"SELECT {column} FROM tax_state_snapshots WHERE id = $1 AND status = 'active'",
                snapshot_id
            )
            if not row:
                raise HTTPException(404, "Snapshot not found")

            current = row[column] or {}
            if isinstance(current, str):
                current = json.loads(current)

            # Merge section data
            current[section] = {**(current.get(section) or {}), **data}

            await conn.execute(f"""
                UPDATE tax_state_snapshots
                SET {column} = $2::jsonb, updated_at = now()
                WHERE id = $1
            """, snapshot_id, json.dumps(current))

            return current

    async def store_computation(
        self, snapshot_id: str, result: dict,
        completion_pct: int, is_approximation: bool
    ):
        """Store DAG computation result."""
        async with self.pool.acquire() as conn:
            await conn.execute("""
                UPDATE tax_state_snapshots
                SET computation_result = $2::jsonb,
                    completion_pct = $3,
                    is_approximation = $4,
                    last_computed_at = now(),
                    updated_at = now()
                WHERE id = $1
            """, snapshot_id, json.dumps(result),
                completion_pct, is_approximation)

    async def set_lock(
        self, snapshot_id: str, lock_type: str, lock_value: str
    ):
        """
        Set a residency lock.
        lock_type: 'india_lock' or 'us_lock'
        lock_value: e.g. 'NR', 'RNOR', 'ROR', 'US_CITIZEN', etc.
        """
        column = lock_type
        async with self.pool.acquire() as conn:
            await conn.execute(f"""
                UPDATE tax_state_snapshots
                SET {column} = $2, updated_at = now()
                WHERE id = $1
            """, snapshot_id, lock_value)


# ═══════════════════════════════════════════════════════════════════
# SECTION 2 — SOFT-HIDE / ARCHIVAL
# If a user changes jurisdiction, data from the invalidated
# jurisdiction is ARCHIVED, never hard-deleted.
#
# Pattern: status column transitions:
#   'active' → 'archived_jurisdiction_change'
#   'active' → 'archived_lock_change'
#   'active' → 'archived_user_reset'
#
# The archived snapshot persists indefinitely. A new 'active'
# snapshot is created with the valid jurisdiction's data carried
# forward and the invalidated jurisdiction's data set to NULL.
# ═══════════════════════════════════════════════════════════════════

class SoftArchivalService:
    """Handles jurisdiction transitions without data loss."""

    def __init__(self, repo: TaxStateRepository):
        self.repo = repo

    async def handle_jurisdiction_change(
        self,
        snapshot_id: str,
        old_jurisdiction: Jurisdiction,
        new_jurisdiction: Jurisdiction,
        new_layer0: dict,
    ) -> str:
        """
        Called when Layer 0 re-evaluation changes jurisdiction.

        Steps:
          1. Archive current snapshot (status = 'archived_jurisdiction_change')
          2. Create new active snapshot with:
             - Layer 0 = updated
             - Valid jurisdiction's Layer 1 = carried forward
             - Invalidated jurisdiction's Layer 1 = NULL (soft-hidden)
          3. Log the transition in tax_events

        Returns: new snapshot ID
        """
        async with self.repo.pool.acquire() as conn:
            # Step 1: Archive
            await conn.execute("""
                UPDATE tax_state_snapshots
                SET status = 'archived_jurisdiction_change',
                    updated_at = now()
                WHERE id = $1
            """, snapshot_id)

            # Step 2: Fetch archived data for carry-forward
            archived = await conn.fetchrow(
                "SELECT * FROM tax_state_snapshots WHERE id = $1",
                snapshot_id
            )

            # Determine what to carry forward
            carry_india = None
            carry_us = None

            if new_jurisdiction in (Jurisdiction.INDIA_ONLY, Jurisdiction.DUAL):
                carry_india = archived['layer1_india']
            if new_jurisdiction in (Jurisdiction.US_ONLY, Jurisdiction.DUAL):
                carry_us = archived['layer1_us']

            # Step 3: Create new active snapshot
            new_id = str(uuid.uuid4())
            await conn.execute("""
                INSERT INTO tax_state_snapshots
                    (id, user_id, tax_year_id, layer0_state,
                     layer1_india, layer1_us, jurisdiction,
                     india_lock, us_lock, status, schema_version)
                VALUES ($1, $2, $3, $4::jsonb, $5::jsonb, $6::jsonb,
                        $7, $8, $9, 'active', 'v5.1')
            """, new_id, archived['user_id'], archived['tax_year_id'],
                json.dumps(new_layer0),
                json.dumps(carry_india) if carry_india else None,
                json.dumps(carry_us) if carry_us else None,
                new_jurisdiction.value,
                archived['india_lock'] if carry_india else None,
                archived['us_lock'] if carry_us else None,
            )

            # Step 4: Log event
            await conn.execute("""
                INSERT INTO tax_events
                    (id, user_id, tax_year_id, event_type, payload, caused_by)
                VALUES ($1, $2, $3, 'JURISDICTION_CHANGE', $4::jsonb, $5)
            """, str(uuid.uuid4()), archived['user_id'],
                archived['tax_year_id'],
                json.dumps({
                    "from": old_jurisdiction.value,
                    "to": new_jurisdiction.value,
                    "archived_snapshot_id": snapshot_id,
                    "new_snapshot_id": new_id,
                }),
                snapshot_id
            )

            return new_id


# ═══════════════════════════════════════════════════════════════════
# SECTION 3 — TAX EVENTS (Append-only audit log)
# ═══════════════════════════════════════════════════════════════════

class TaxEventRepository:
    """Append-only event log for audit trail."""

    def __init__(self, db_pool):
        self.pool = db_pool

    async def log_event(
        self, user_id: str, tax_year_id: str,
        event_type: str, payload: dict,
        caused_by: Optional[str] = None
    ):
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO tax_events (id, user_id, tax_year_id, event_type, payload, caused_by)
                VALUES ($1, $2, $3, $4, $5::jsonb, $6)
            """, str(uuid.uuid4()), user_id, tax_year_id,
                event_type, json.dumps(payload), caused_by)

    async def get_events(
        self, user_id: str, tax_year_id: str, limit: int = 100
    ) -> list[dict]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT id, event_type, payload, caused_by, created_at
                FROM tax_events
                WHERE user_id = $1 AND tax_year_id = $2
                ORDER BY created_at DESC
                LIMIT $3
            """, user_id, tax_year_id, limit)
            return [dict(r) for r in rows]


# ═══════════════════════════════════════════════════════════════════
# SECTION 4 — FASTAPI ENDPOINT MAPPING
# Endpoint structure:
#   POST   /tax-years                                → Create snapshot (Layer 0)
#   GET    /tax-years/{id}                           → Get snapshot
#   PATCH  /tax-years/{id}/layer0                    → Update Layer 0
#   POST   /tax-years/{id}/layer0/submit             → Submit Layer 0 (fires router)
#   PATCH  /tax-years/{id}/{jurisdiction}/{section}   → Update Layer 1 section
#   POST   /tax-years/{id}/india/lock                → Fire India lock
#   POST   /tax-years/{id}/us/lock                   → Fire US lock
#   POST   /tax-years/{id}/evaluate                  → Fire DAG ("Evaluate Tax")
#   GET    /tax-years/{id}/sections                  → Get visible sections
#   GET    /tax-years/{id}/events                    → Get audit trail
# ═══════════════════════════════════════════════════════════════════

app = FastAPI(
    title="Wising Tax Engine",
    version="1.0.0",
    description="US-India NRI Cross-Border Tax Engine"
)

# ── Pydantic request/response models ────────────────────────────

class CreateTaxYearRequest(BaseModel):
    user_id: str
    tax_year_id: str
    layer0: dict = Field(default_factory=dict)


class PatchLayer0Request(BaseModel):
    updates: dict


class PatchSectionRequest(BaseModel):
    data: dict


class EvaluateTaxRequest(BaseModel):
    india_income: Optional[dict] = None
    us_income: Optional[dict] = None


class TaxYearResponse(BaseModel):
    id: str
    jurisdiction: Optional[str] = None
    india_lock: Optional[str] = None
    us_lock: Optional[str] = None
    completion_pct: int = 0
    is_approximation: bool = True
    layer0_state: dict = Field(default_factory=dict)


class LockResponse(BaseModel):
    status: str
    path_id: Optional[str] = None
    statutory_basis: Optional[str] = None


class SectionsResponse(BaseModel):
    sections: dict[str, bool]


# ── Dependency injection placeholder ────────────────────────────

def get_db_pool():
    """Production: return asyncpg pool. Override in tests."""
    raise NotImplementedError("Configure DB pool in application startup")


def get_repo(pool=Depends(get_db_pool)) -> TaxStateRepository:
    return TaxStateRepository(pool)


def get_events(pool=Depends(get_db_pool)) -> TaxEventRepository:
    return TaxEventRepository(pool)


# ── Endpoints ───────────────────────────────────────────────────

@app.post("/tax-years", status_code=status.HTTP_201_CREATED)
async def create_tax_year(
    req: CreateTaxYearRequest,
    repo: TaxStateRepository = Depends(get_repo),
    events: TaxEventRepository = Depends(get_events),
):
    """
    POST /tax-years
    Create a new tax year snapshot. Initializes Layer 0.
    """
    snapshot_id = await repo.create_snapshot(
        req.user_id, req.tax_year_id, req.layer0
    )
    await events.log_event(
        req.user_id, req.tax_year_id,
        "SNAPSHOT_CREATED", {"snapshot_id": snapshot_id}
    )
    return {"id": snapshot_id}


@app.get("/tax-years/{snapshot_id}")
async def get_tax_year(
    snapshot_id: str,
    repo: TaxStateRepository = Depends(get_repo),
):
    """GET /tax-years/{id} — Fetch current snapshot."""
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")
    return snapshot


@app.patch("/tax-years/{snapshot_id}/layer0")
async def patch_layer0(
    snapshot_id: str,
    req: PatchLayer0Request,
    repo: TaxStateRepository = Depends(get_repo),
):
    """
    PATCH /tax-years/{id}/layer0
    Partial update to Layer 0. Reactively re-evaluates jurisdiction.
    Supports debounced calls from frontend.
    """
    result = await repo.patch_layer0(snapshot_id, req.updates)
    return {"layer0": result}


@app.post("/tax-years/{snapshot_id}/layer0/submit")
async def submit_layer0(
    snapshot_id: str,
    repo: TaxStateRepository = Depends(get_repo),
    events: TaxEventRepository = Depends(get_events),
):
    """
    POST /tax-years/{id}/layer0/submit
    Finalize Layer 0 and route to jurisdiction.
    Creates Layer 1 modules as needed.
    """
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")

    # Build state from snapshot and run wizard
    state = _snapshot_to_engine_state(snapshot)
    wiz = WizardStateMachine(state)
    jurisdiction = wiz.submit_layer0()

    # Persist
    await repo.patch_layer0(snapshot_id, asdict(state.layer0))
    if state.india_residency:
        await repo.patch_layer1_section(
            snapshot_id, "layer1_india", "residency_detail",
            asdict(state.india_residency)
        )
    if state.us_residency:
        await repo.patch_layer1_section(
            snapshot_id, "layer1_us", "us_residency_detail",
            asdict(state.us_residency)
        )

    return {"jurisdiction": jurisdiction.value}


@app.patch("/tax-years/{snapshot_id}/{jurisdiction}/{section}")
async def patch_section(
    snapshot_id: str,
    jurisdiction: str,
    section: str,
    req: PatchSectionRequest,
    repo: TaxStateRepository = Depends(get_repo),
):
    """
    PUT /tax-years/{id}/{jurisdiction}/{section}
    Update a Layer 1 section (e.g., property, salary, bank_accounts).

    jurisdiction: 'india' or 'us'
    section: section name from schema (e.g., 'property', 'salary')
    """
    layer = f"layer1_{jurisdiction}"
    if layer not in ("layer1_india", "layer1_us"):
        raise HTTPException(400, f"Invalid jurisdiction: {jurisdiction}")

    result = await repo.patch_layer1_section(
        snapshot_id, layer, section, req.data
    )
    return {"section": section, "data": result.get(section)}


@app.post("/tax-years/{snapshot_id}/india/lock")
async def fire_india_lock(
    snapshot_id: str,
    repo: TaxStateRepository = Depends(get_repo),
    events: TaxEventRepository = Depends(get_events),
):
    """
    POST /tax-years/{id}/india/lock
    Fire the India RS-001 residency lock.
    """
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")

    state = _snapshot_to_engine_state(snapshot)
    wiz = WizardStateMachine(state)
    result = wiz.fire_india_lock()

    await repo.set_lock(snapshot_id, "india_lock", result.status.value)
    await events.log_event(
        snapshot['user_id'], snapshot['tax_year_id'],
        "INDIA_LOCK_SET",
        {"status": result.status.value, "path_id": result.path_id,
         "statutory_basis": result.statutory_basis}
    )

    return LockResponse(
        status=result.status.value,
        path_id=result.path_id,
        statutory_basis=result.statutory_basis
    )


@app.post("/tax-years/{snapshot_id}/us/lock")
async def fire_us_lock(
    snapshot_id: str,
    repo: TaxStateRepository = Depends(get_repo),
    events: TaxEventRepository = Depends(get_events),
):
    """POST /tax-years/{id}/us/lock — Fire the US SPT lock."""
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")

    state = _snapshot_to_engine_state(snapshot)
    wiz = WizardStateMachine(state)
    result = wiz.fire_us_lock()

    await repo.set_lock(snapshot_id, "us_lock", result.status.value)

    return LockResponse(status=result.status.value)


@app.post("/tax-years/{snapshot_id}/evaluate")
async def evaluate(
    snapshot_id: str,
    req: EvaluateTaxRequest,
    repo: TaxStateRepository = Depends(get_repo),
    events: TaxEventRepository = Depends(get_events),
):
    """
    POST /tax-years/{id}/evaluate
    THE "EVALUATE TAX" BUTTON.
    Fires the Math DAG. Only called on explicit user action.
    Never called on individual field changes.
    """
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")

    state = _snapshot_to_engine_state(snapshot)

    # Build income assemblies from request
    india_income = (IndiaIncomeAssembly(**req.india_income)
                    if req.india_income else None)
    us_income = (USIncomeAssembly(**req.us_income)
                 if req.us_income else None)

    # Run DAG
    computation = evaluate_tax(state, india_income, us_income)

    # Stamp output
    completion_pct = snapshot.get('completion_pct', 0)
    output = stamp_output(computation, state, completion_pct)

    # Persist
    await repo.store_computation(
        snapshot_id, asdict(output),
        completion_pct, output.badge == "APPROXIMATION"
    )

    await events.log_event(
        snapshot['user_id'], snapshot['tax_year_id'],
        "TAX_EVALUATED",
        {"badge": output.badge, "completion_pct": completion_pct,
         "assumptions_count": len(output.assumptions_used)}
    )

    return asdict(output)


@app.get("/tax-years/{snapshot_id}/sections")
async def get_sections(
    snapshot_id: str,
    repo: TaxStateRepository = Depends(get_repo),
):
    """GET /tax-years/{id}/sections — Visible sections based on locks."""
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")

    state = _snapshot_to_engine_state(snapshot)
    wiz = WizardStateMachine(state)
    sections = wiz.get_visible_sections()
    return SectionsResponse(sections=sections)


@app.get("/tax-years/{snapshot_id}/events")
async def get_event_log(
    snapshot_id: str,
    repo: TaxStateRepository = Depends(get_repo),
    event_repo: TaxEventRepository = Depends(get_events),
):
    """GET /tax-years/{id}/events — Audit trail."""
    snapshot = await repo.get_active_snapshot_by_id(snapshot_id)
    if not snapshot:
        raise HTTPException(404, "Snapshot not found")

    events_list = await event_repo.get_events(
        snapshot['user_id'], snapshot['tax_year_id']
    )
    return {"events": events_list}


# ── Helper: Snapshot dict → Engine state ────────────────────────

def _snapshot_to_engine_state(snapshot: dict) -> TaxEngineState:
    """Convert a DB snapshot row to the in-memory engine state."""
    state = TaxEngineState(
        id=snapshot['id'],
        user_id=snapshot['user_id'],
        tax_year_id=snapshot['tax_year_id'],
    )

    # Layer 0
    l0_dict = snapshot.get('layer0_state') or {}
    if isinstance(l0_dict, str):
        l0_dict = json.loads(l0_dict)
    for key, val in l0_dict.items():
        if hasattr(state.layer0, key):
            if key == 'jurisdiction' and val:
                setattr(state.layer0, key, Jurisdiction(val))
            else:
                setattr(state.layer0, key, val)

    # Layer 1 India
    india_dict = snapshot.get('layer1_india') or {}
    if isinstance(india_dict, str):
        india_dict = json.loads(india_dict)
    if india_dict:
        rd = india_dict.get('residency_detail', india_dict)
        state.india_residency = IndiaResidencyDetail()
        for key, val in rd.items():
            if hasattr(state.india_residency, key):
                if key == 'final_india_residency_status' and val:
                    setattr(state.india_residency, key, IndiaResidency(val))
                elif key == 'employment_or_crew_status' and val:
                    from sprint1_input_layer import EmploymentCrewStatus
                    setattr(state.india_residency, key, EmploymentCrewStatus(val))
                else:
                    setattr(state.india_residency, key, val)

    # Layer 1 US
    us_dict = snapshot.get('layer1_us') or {}
    if isinstance(us_dict, str):
        us_dict = json.loads(us_dict)
    if us_dict:
        urd = us_dict.get('us_residency_detail', us_dict)
        state.us_residency = USResidencyDetail()
        for key, val in urd.items():
            if hasattr(state.us_residency, key):
                if key == 'final_us_residency_status' and val:
                    setattr(state.us_residency, key, USResidency(val))
                elif key == 'exempt_individual_status' and val:
                    from sprint1_input_layer import ExemptIndividualStatus
                    setattr(state.us_residency, key, ExemptIndividualStatus(val))
                else:
                    setattr(state.us_residency, key, val)

    return state
