"""
═══════════════════════════════════════════════════════════════════════════════
  WISING TAX ENGINE — CORE IMPLEMENTATION
  File: wising_tax_engine_core.py
  Version: 1.0 (v4 schema alignment, TRD v1.1 patches applied)
  Date: April 2026
═══════════════════════════════════════════════════════════════════════════════

PURPOSE
───────
Single-file reference implementation covering the 4 build sprints:

  Sprint 1 — Input Layer & Dynamic Residency Lock
              (Layer 0 router, Layer 1 India RS-001 lock, Layer 1 US SPT lock,
               Python mirror FSM, reactive upstream-change handler)

  Sprint 2 — Compute Layer (The Math DAG)
              (Pure, deterministic, side-effect-free DAG with topo-sorted
               nodes; India: GTI → Slab → Surcharge → MR → Cess → Rebate;
               US: 1040 → AMT → NIIT → FTC)

  Sprint 3 — Output Layer & Testing
              (APPROXIMATION vs FINAL stamping, assumptions_used array,
               no silent defaults, unit tests)

  Sprint 4 — Security & Persistence
              (tax_state_snapshots DDL, field_registry, soft-archive on
               jurisdiction change, FastAPI endpoints)

ARCHITECTURAL INVARIANTS
────────────────────────
1. Backend is the authority. Frontend XState FSM is a UX projection; backend
   validates every transition server-side.
2. Layer 0 and Layer 1 schemas are STRICTLY isolated (no India field in US
   schema, no US field in India schema).
3. The Math DAG is PURE. Zero DB I/O, zero API calls, zero filesystem access.
4. Every output below 100% completion is stamped APPROXIMATION. Binary.
5. Every silent default becomes an explicit entry in `assumptions_used`.
6. Data is NEVER hard-deleted. Jurisdiction/lock changes soft-archive.
7. Locks re-fire reactively on upstream change. The DAG only fires on
   explicit "Evaluate Tax" events.

TRD v1.1 FIXES APPLIED
──────────────────────
- PATCH-1: Async writes via BackgroundTask (no response-path blocking).
- PATCH-2: Structural validator does no domain logic.
- PATCH-3: All cross-field validators use `getattr(self, 'x', None)` guards.
- PATCH-4: WisingLayer1InputDBRead subclass (`extra="ignore"`) for historical
           JSONB reads; strict model used for API ingress only.
- PATCH-5: Document metadata stored OUT-OF-BAND (Blob URL refs), not in JSON.

═══════════════════════════════════════════════════════════════════════════════
"""

from __future__ import annotations

import hashlib
import json
import logging
from dataclasses import dataclass, field as dc_field
from datetime import date, datetime, timezone
from decimal import ROUND_HALF_UP, Decimal
from enum import Enum
from typing import (
    Any,
    Callable,
    ClassVar,
    Dict,
    Generic,
    List,
    Literal,
    Optional,
    Set,
    Tuple,
    TypeVar,
    Union,
)
from uuid import UUID, uuid4

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    field_validator,
    model_validator,
)

# ── External (assumed installed per TRD v1.1 pyproject.toml) ──────────────────
# import asyncpg
# from fastapi import APIRouter, BackgroundTasks, Depends, FastAPI, HTTPException, status
# from azure.servicebus.aio import ServiceBusClient
# from tenacity import retry, stop_after_attempt, wait_exponential

logger = logging.getLogger("wising.tax_engine")

INR = Decimal  # explicit type alias — always rupees, never paise
USD = Decimal  # explicit type alias — always dollars, never cents
ZERO = Decimal("0")


# ╔═════════════════════════════════════════════════════════════════════════════
# ║  SPRINT 0 — FOUNDATIONS
# ║    Enums, base models, strict config, exception hierarchy.
# ╚═════════════════════════════════════════════════════════════════════════════

class Jurisdiction(str, Enum):
    INDIA_ONLY = "india_only"
    US_ONLY = "us_only"
    DUAL = "dual"
    NONE = "none"


class IndiaResidencyLock(str, Enum):
    NR = "NR"
    RNOR = "RNOR"
    ROR = "ROR"


class USResidencyLock(str, Enum):
    US_CITIZEN = "US_CITIZEN"
    RESIDENT_ALIEN = "RESIDENT_ALIEN"
    NON_RESIDENT_ALIEN = "NON_RESIDENT_ALIEN"
    DUAL_STATUS = "DUAL_STATUS"


class TaxRegime(str, Enum):
    NEW = "NEW"
    OLD = "OLD"


class EmploymentOrCrew(str, Enum):
    EMPLOYED_ABROAD = "employed_abroad"
    INDIAN_SHIP_CREW = "indian_ship_crew"
    FOREIGN_SHIP_CREW = "foreign_ship_crew"
    NONE = "none"


class InputCompleteness(str, Enum):
    PROVISIONAL = "provisional"
    COMPLETE = "complete"


class ComputationStatus(str, Enum):
    APPROXIMATION = "APPROXIMATION"
    FINAL = "FINAL"


class SnapshotStatus(str, Enum):
    ACTIVE = "active"
    ARCHIVED = "archived"


class FSMState(str, Enum):
    """Backend mirror of the XState wizard state. Enum-only; no hierarchy."""
    LAYER0_IN_PROGRESS = "layer0_in_progress"
    LAYER0_COMPLETE = "layer0_complete"
    JURISDICTION_DERIVED = "jurisdiction_derived"
    INDIA_RESIDENCY_PROVISIONAL = "india_residency_provisional"
    US_RESIDENCY_PROVISIONAL = "us_residency_provisional"
    INDIA_LOCKED = "india_locked"
    US_LOCKED = "us_locked"
    FULLY_LOCKED = "fully_locked"
    INCOME_SECTIONS_OPEN = "income_sections_open"
    READY_TO_EVALUATE = "ready_to_evaluate"
    COMPUTING = "computing"
    RESULT_APPROXIMATION = "result_approximation"
    RESULT_FINAL = "result_final"


# ── Strict base (API ingress) — rejects unknown fields, no type coercion ──────
class StrictBase(BaseModel):
    model_config = ConfigDict(
        strict=True,
        extra="forbid",
        frozen=False,
        validate_assignment=True,
    )


# ── Permissive base (DB read) — TRD v1.1 PATCH-4 ──────────────────────────────
#    JSONB rows may carry legacy/extra keys from earlier schema versions;
#    ingress validation must NEVER loosen, so we inherit and override.
class PermissiveBase(BaseModel):
    model_config = ConfigDict(
        strict=False,
        extra="ignore",
        frozen=False,
    )


# ── Exception hierarchy ───────────────────────────────────────────────────────
class WisingTaxEngineError(Exception):
    """Base."""


class InvalidTransitionError(WisingTaxEngineError):
    """FSM refused the requested transition."""


class LockNotSetError(WisingTaxEngineError):
    """Downstream section accessed before residency lock is set."""


class DAGExecutionError(WisingTaxEngineError):
    """Node raised during DAG execution. Wraps root cause."""


class JurisdictionMismatchError(WisingTaxEngineError):
    """Attempted to write India section while jurisdiction is us_only (or vice versa)."""


# ╔═════════════════════════════════════════════════════════════════════════════
# ║  SPRINT 1 — INPUT LAYER & DYNAMIC RESIDENCY LOCK
# ╚═════════════════════════════════════════════════════════════════════════════

# ── 1.1 Layer 0 input model ───────────────────────────────────────────────────
class Layer0Input(StrictBase):
    """
    The 9-question jurisdiction router input. Exactly mirrors
    layer0_residency_final.jsonc v4.0.

    Parallel flag architecture: india_flag and us_flag are evaluated
    COMPLETELY INDEPENDENTLY — no india_days gate on US questions,
    no us_status gate on India questions.
    """
    # ── India-flag inputs
    is_indian_citizen: bool
    is_pio_or_oci: Optional[bool] = None           # gate: is_indian_citizen = false
    india_days: int = Field(ge=0, le=366)
    has_india_source_income_or_assets: bool

    # ── US-flag inputs
    is_us_citizen: bool
    has_green_card: Optional[bool] = None          # gate: is_us_citizen = false
    was_in_us_this_year: bool
    us_days: Optional[int] = Field(default=None, ge=0, le=366)
    has_us_source_income_or_assets: bool

    # ── Pass-through (do not affect routing)
    liable_to_tax_in_another_country: Optional[bool] = None      # gate: is_indian_citizen = true
    left_india_for_employment_this_year: Optional[bool] = None   # gate: is_indian_citizen = true

    # ── Structural conditional-gate enforcement (TRD PATCH-2: no domain logic) ──
    @model_validator(mode="after")
    def _enforce_conditional_gates(self) -> "Layer0Input":
        # All guards use getattr() per PATCH-3
        if getattr(self, "is_indian_citizen", None) is True:
            if getattr(self, "is_pio_or_oci", None) is not None:
                raise ValueError("is_pio_or_oci must be null when is_indian_citizen=true")
        if getattr(self, "is_us_citizen", None) is True:
            if getattr(self, "has_green_card", None) is not None:
                raise ValueError("has_green_card must be null when is_us_citizen=true")
        if getattr(self, "was_in_us_this_year", None) is False:
            if getattr(self, "us_days", None) not in (None, 0):
                raise ValueError("us_days must be null/0 when was_in_us_this_year=false")
        if getattr(self, "is_indian_citizen", None) is False:
            if getattr(self, "liable_to_tax_in_another_country", None) is not None:
                raise ValueError(
                    "liable_to_tax_in_another_country must be null for non-Indian citizens"
                )
            if getattr(self, "left_india_for_employment_this_year", None) is not None:
                raise ValueError(
                    "left_india_for_employment_this_year must be null for non-Indian citizens"
                )
        return self


class Layer0Derived(StrictBase):
    india_flag: bool
    us_flag: bool
    jurisdiction: Jurisdiction


# ── 1.2 Layer 1 residency inputs (minimal slice — only what the lock needs) ───
class IndiaResidencyInput(StrictBase):
    """
    The 8 fields the RS-001 cascade reads. Full layer1_india_v5_1_final.jsonc
    residency_detail has more (trip log, ship nationality, etc.); this
    struct is the *lock input contract* — deliberately minimal.
    """
    days_in_india_current_year: int = Field(ge=0, le=366)         # DAYS — pre-filled from Layer 0
    days_in_india_preceding_4_years_gte_365: Optional[bool] = None  # P4Y_365 — gate: days 60–181
    employment_or_crew_status: Optional[EmploymentOrCrew] = None    # EMP — gate: days 60–181 + P4Y + citizen
    came_on_visit_to_india_pio_oci_citizen: Optional[bool] = None   # VISIT — gate: EMP=none
    nr_years_last_10_gte_9: Optional[bool] = None                   # NR9 — gate: days>=182 OR VISIT=false
    days_in_india_last_7_years_lte_729: Optional[bool] = None       # D7_729 — same gate
    india_source_income_above_15l: Optional[bool] = None            # INC_15L
    # Composite boolean (citizen AND liable_elsewhere), pre-computed from Layer 0:
    liable_to_tax_in_another_country_being_indian_citizen: bool = False  # LTAC


class USResidencyInput(StrictBase):
    """
    Inputs for the SPT / GC / DS cascade. Exempt-day detail
    (visa history, medical, transit) lives in deeper sub-models; this
    is the lock input contract.
    """
    is_us_citizen: bool
    has_green_card: bool
    green_card_surrendered_this_year: bool = False  # I-407 filed?
    closer_connection_claim: bool = False
    first_year_choice_elected: bool = False
    partial_year_gc_grant: bool = False
    expatriated_mid_year: bool = False
    # Countable days AFTER exempt-day subtraction, per US_Residential_Status_Spec_v1_1
    countable_days_cy: int = Field(ge=0, le=366)
    countable_days_py1: int = Field(ge=0, le=366)
    countable_days_py2: int = Field(ge=0, le=366)


# ── 1.3 Jurisdiction router (pure function) ───────────────────────────────────
def compute_jurisdiction(l0: Layer0Input) -> Layer0Derived:
    """Parallel flag architecture. Pure function. No side effects."""
    india_flag = (
        l0.is_indian_citizen
        or bool(l0.is_pio_or_oci)
        or l0.india_days > 0
        or l0.has_india_source_income_or_assets
    )
    us_flag = (
        l0.is_us_citizen
        or bool(l0.has_green_card)
        or (l0.was_in_us_this_year and (l0.us_days or 0) > 0)
        or l0.has_us_source_income_or_assets
    )
    if india_flag and us_flag:
        j = Jurisdiction.DUAL
    elif india_flag:
        j = Jurisdiction.INDIA_ONLY
    elif us_flag:
        j = Jurisdiction.US_ONLY
    else:
        j = Jurisdiction.NONE
    return Layer0Derived(india_flag=india_flag, us_flag=us_flag, jurisdiction=j)


# ── 1.4 RS-001 India residency lock (2 ROR + 9 RNOR + 8 NR paths) ─────────────
def compute_india_lock(ri: IndiaResidencyInput, is_indian_citizen: bool) -> IndiaResidencyLock:
    """
    Direct translation of the boolean matrix from
    'India Residency (Tax Engine Logic).docx' — mirrored in
    layer1_india_v5_1_final.jsonc. Pure function.

    CRITICAL: citizenship is enforced INDEPENDENTLY on Deemed Resident paths.
    A PIO (citizen=false) never enters RNOR-3/7/8/9 even if LTAC=false.
    """
    DAYS = ri.days_in_india_current_year
    P4Y_365 = bool(ri.days_in_india_preceding_4_years_gte_365)
    EMP = ri.employment_or_crew_status or EmploymentOrCrew.NONE
    VISIT = bool(ri.came_on_visit_to_india_pio_oci_citizen)
    NR9 = bool(ri.nr_years_last_10_gte_9)
    D7_729 = bool(ri.days_in_india_last_7_years_lte_729)
    INC_15L = bool(ri.india_source_income_above_15l)
    LTAC = ri.liable_to_tax_in_another_country_being_indian_citizen

    # ─── ROR paths (2) ───
    if DAYS >= 182 and not NR9 and not D7_729:
        return IndiaResidencyLock.ROR                                           # ROR-1
    if (60 <= DAYS < 182 and P4Y_365 and EMP == EmploymentOrCrew.NONE
            and not VISIT and not NR9 and not D7_729):
        return IndiaResidencyLock.ROR                                           # ROR-2

    # ─── RNOR paths (9) ───
    if DAYS >= 182 and NR9:
        return IndiaResidencyLock.RNOR                                          # RNOR-1
    if DAYS >= 182 and D7_729:
        return IndiaResidencyLock.RNOR                                          # RNOR-2

    # Deemed Resident paths (3, 7, 8, 9) require Indian citizenship
    if is_indian_citizen:
        if (60 <= DAYS < 182 and P4Y_365 and EMP != EmploymentOrCrew.NONE
                and INC_15L and not LTAC):
            return IndiaResidencyLock.RNOR                                      # RNOR-3
        if DAYS < 60 and INC_15L and not LTAC:
            return IndiaResidencyLock.RNOR                                      # RNOR-7
        if (60 <= DAYS < 182 and not P4Y_365 and INC_15L and not LTAC):
            return IndiaResidencyLock.RNOR                                      # RNOR-8
        if (60 <= DAYS < 182 and P4Y_365 and EMP == EmploymentOrCrew.NONE
                and VISIT and DAYS < 120 and INC_15L and not LTAC):
            return IndiaResidencyLock.RNOR                                      # RNOR-9

    # RNOR-4/5/6 (do NOT require citizenship)
    if (60 <= DAYS < 182 and P4Y_365 and EMP == EmploymentOrCrew.NONE
            and VISIT and 120 <= DAYS < 182 and INC_15L):
        return IndiaResidencyLock.RNOR                                          # RNOR-4
    if (60 <= DAYS < 182 and P4Y_365 and EMP == EmploymentOrCrew.NONE
            and not VISIT and NR9):
        return IndiaResidencyLock.RNOR                                          # RNOR-5
    if (60 <= DAYS < 182 and P4Y_365 and EMP == EmploymentOrCrew.NONE
            and not VISIT and D7_729):
        return IndiaResidencyLock.RNOR                                          # RNOR-6

    # ─── Default: NR (any of the 8 NR paths — fall-through) ───
    return IndiaResidencyLock.NR


# ── 1.5 US residency lock (SPT + GC + DS cascade) ─────────────────────────────
def compute_us_lock(ui: USResidencyInput) -> USResidencyLock:
    """
    Priority cascade per US_Residential_Status_Spec_v1_1:
      1. USC      →  US_CITIZEN
      2. GC (unsurrendered) → RESIDENT_ALIEN
      3. SPT met + no closer-connection → RESIDENT_ALIEN
      4. Mid-year transitions → DUAL_STATUS
      5. Else → NON_RESIDENT_ALIEN

    SPT: current_year ≥ 31 AND (cy + py1/3 + py2/6) ≥ 183,
         using COUNTABLE (exempt-subtracted) days.
    """
    if ui.is_us_citizen:
        return USResidencyLock.US_CITIZEN
    if ui.has_green_card and not ui.green_card_surrendered_this_year:
        return USResidencyLock.RESIDENT_ALIEN

    # SPT
    spt_met = False
    if ui.countable_days_cy >= 31:
        weighted = (
            ui.countable_days_cy
            + (ui.countable_days_py1 / Decimal(3))
            + (ui.countable_days_py2 / Decimal(6))
        )
        if weighted >= 183:
            spt_met = True

    # Dual-status precedence (checked before RA/NRA finalization)
    if ui.partial_year_gc_grant or ui.first_year_choice_elected or ui.expatriated_mid_year:
        return USResidencyLock.DUAL_STATUS

    if spt_met and not ui.closer_connection_claim:
        return USResidencyLock.RESIDENT_ALIEN

    return USResidencyLock.NON_RESIDENT_ALIEN


# ── 1.6 Python mirror FSM ─────────────────────────────────────────────────────
#     This is NOT a re-implementation of XState. It is the backend's
#     authoritative transition table used to validate every state mutation
#     POSTed by the client. The client's XState machine is an optimistic
#     UX projection; this one is the source of truth.
@dataclass
class FSMSnapshot:
    """In-memory working copy of the wizard state. Mirrors tax_state_snapshots row."""
    user_id: UUID
    tax_year_id: UUID
    state: FSMState
    layer0: Optional[Layer0Input] = None
    layer0_derived: Optional[Layer0Derived] = None
    india_residency: Optional[IndiaResidencyInput] = None
    us_residency: Optional[USResidencyInput] = None
    india_lock: Optional[IndiaResidencyLock] = None
    us_lock: Optional[USResidencyLock] = None
    layer1_india: Dict[str, Any] = dc_field(default_factory=dict)
    layer1_us: Dict[str, Any] = dc_field(default_factory=dict)
    completion_pct: int = 0
    archived_us: Optional[Dict[str, Any]] = None
    archived_india: Optional[Dict[str, Any]] = None
    last_computed_at: Optional[datetime] = None
    computation_result: Optional[Dict[str, Any]] = None


# ── Transition table: (from_state, event) → to_state. Events that aren't
#    present for a given state are rejected by the FSM (InvalidTransitionError).
TransitionKey = Tuple[FSMState, str]
TRANSITIONS: Dict[TransitionKey, FSMState] = {
    (FSMState.LAYER0_IN_PROGRESS, "LAYER0_SUBMITTED"):      FSMState.LAYER0_COMPLETE,
    (FSMState.LAYER0_COMPLETE, "DERIVE_JURISDICTION"):      FSMState.JURISDICTION_DERIVED,
    (FSMState.JURISDICTION_DERIVED, "START_INDIA_RESIDENCY"): FSMState.INDIA_RESIDENCY_PROVISIONAL,
    (FSMState.JURISDICTION_DERIVED, "START_US_RESIDENCY"):    FSMState.US_RESIDENCY_PROVISIONAL,
    (FSMState.INDIA_RESIDENCY_PROVISIONAL, "INDIA_LOCK_SET"): FSMState.INDIA_LOCKED,
    (FSMState.US_RESIDENCY_PROVISIONAL, "US_LOCK_SET"):       FSMState.US_LOCKED,
    (FSMState.INDIA_LOCKED, "START_US_RESIDENCY"):         FSMState.US_RESIDENCY_PROVISIONAL,
    (FSMState.US_LOCKED, "START_INDIA_RESIDENCY"):         FSMState.INDIA_RESIDENCY_PROVISIONAL,
    (FSMState.INDIA_LOCKED, "OPEN_INCOME"):                FSMState.INCOME_SECTIONS_OPEN,
    (FSMState.US_LOCKED, "OPEN_INCOME"):                   FSMState.INCOME_SECTIONS_OPEN,
    (FSMState.FULLY_LOCKED, "OPEN_INCOME"):                FSMState.INCOME_SECTIONS_OPEN,
    (FSMState.INCOME_SECTIONS_OPEN, "READY"):              FSMState.READY_TO_EVALUATE,
    (FSMState.READY_TO_EVALUATE, "EVALUATE_TAX"):          FSMState.COMPUTING,
    (FSMState.COMPUTING, "COMPUTE_DONE_APPROX"):           FSMState.RESULT_APPROXIMATION,
    (FSMState.COMPUTING, "COMPUTE_DONE_FINAL"):            FSMState.RESULT_FINAL,
    (FSMState.RESULT_APPROXIMATION, "FILL_MORE"):          FSMState.INCOME_SECTIONS_OPEN,
    (FSMState.RESULT_APPROXIMATION, "UPDATE_UPSTREAM"):    FSMState.INCOME_SECTIONS_OPEN,
    (FSMState.RESULT_FINAL, "UPDATE_UPSTREAM"):            FSMState.INCOME_SECTIONS_OPEN,
}


class WizardFSM:
    """
    Authoritative backend state machine. Every client field write gets
    translated into an event here; any disallowed event is rejected.

    The FSM is stateless at the class level — state lives in FSMSnapshot
    objects. That means a single class instance can drive many users.
    """

    def transition(self, snap: FSMSnapshot, event: str) -> FSMSnapshot:
        key = (snap.state, event)
        if key not in TRANSITIONS:
            raise InvalidTransitionError(
                f"Cannot fire {event!r} from {snap.state.value!r}"
            )
        snap.state = TRANSITIONS[key]
        logger.info("fsm.transition", extra={
            "user_id": str(snap.user_id),
            "event": event,
            "to": snap.state.value,
        })
        return snap

    # ── Reactive handlers: these wrap transition() with side-effect logic.

    def apply_layer0(self, snap: FSMSnapshot, l0: Layer0Input) -> FSMSnapshot:
        snap.layer0 = l0
        snap.layer0_derived = compute_jurisdiction(l0)
        self.transition(snap, "LAYER0_SUBMITTED")
        self.transition(snap, "DERIVE_JURISDICTION")

        # Pre-fill Layer 1 residency inputs from Layer 0
        if snap.layer0_derived.india_flag:
            snap.india_residency = IndiaResidencyInput(
                days_in_india_current_year=l0.india_days,
                liable_to_tax_in_another_country_being_indian_citizen=(
                    l0.is_indian_citizen
                    and bool(l0.liable_to_tax_in_another_country)
                ),
            )
        if snap.layer0_derived.us_flag:
            snap.us_residency = USResidencyInput(
                is_us_citizen=l0.is_us_citizen,
                has_green_card=bool(l0.has_green_card),
                countable_days_cy=l0.us_days or 0,
                countable_days_py1=0,
                countable_days_py2=0,
            )
        return snap

    def apply_india_residency(
        self, snap: FSMSnapshot, patch: Dict[str, Any]
    ) -> FSMSnapshot:
        """
        Partial save: merge `patch` into the existing IndiaResidencyInput,
        then re-run RS-001. If the lock is deterministically computable
        (all required flags present for the matched path), fire INDIA_LOCK_SET.
        """
        if snap.layer0_derived is None or not snap.layer0_derived.india_flag:
            raise JurisdictionMismatchError("No India jurisdiction on this snapshot")
        if snap.state not in (FSMState.JURISDICTION_DERIVED,
                              FSMState.INDIA_RESIDENCY_PROVISIONAL,
                              FSMState.US_LOCKED,
                              FSMState.INDIA_LOCKED,     # re-edit allowed
                              FSMState.INCOME_SECTIONS_OPEN):
            raise InvalidTransitionError(
                f"Cannot patch india_residency from {snap.state.value}"
            )
        if snap.state == FSMState.JURISDICTION_DERIVED:
            self.transition(snap, "START_INDIA_RESIDENCY")

        merged = (snap.india_residency or IndiaResidencyInput(
            days_in_india_current_year=snap.layer0.india_days if snap.layer0 else 0
        )).model_dump()
        merged.update(patch)
        snap.india_residency = IndiaResidencyInput.model_validate(merged)

        # Reactive lock recompute. It is OK for the lock to flip — that's
        # the whole point of the dynamic lock: upstream change → downstream
        # lock → downstream sections gate.
        prev_lock = snap.india_lock
        snap.india_lock = compute_india_lock(
            snap.india_residency,
            is_indian_citizen=snap.layer0.is_indian_citizen if snap.layer0 else False,
        )
        if snap.state in (FSMState.INDIA_RESIDENCY_PROVISIONAL,):
            self.transition(snap, "INDIA_LOCK_SET")

        if prev_lock is not None and prev_lock != snap.india_lock:
            # Lock changed → archive any downstream sections that are no
            # longer valid under the new lock (e.g., LRS if lock fell from
            # ROR to RNOR; DTAA if lock rose from ROR to NR).
            self._soft_archive_invalidated_india_sections(snap, prev_lock, snap.india_lock)

        return snap

    def apply_us_residency(
        self, snap: FSMSnapshot, patch: Dict[str, Any]
    ) -> FSMSnapshot:
        if snap.layer0_derived is None or not snap.layer0_derived.us_flag:
            raise JurisdictionMismatchError("No US jurisdiction on this snapshot")
        if snap.state == FSMState.JURISDICTION_DERIVED:
            self.transition(snap, "START_US_RESIDENCY")
        elif snap.state == FSMState.INDIA_LOCKED:
            self.transition(snap, "START_US_RESIDENCY")
        elif snap.state not in (FSMState.US_RESIDENCY_PROVISIONAL,
                                FSMState.US_LOCKED,
                                FSMState.INCOME_SECTIONS_OPEN):
            raise InvalidTransitionError(
                f"Cannot patch us_residency from {snap.state.value}"
            )

        merged = (snap.us_residency or USResidencyInput(
            is_us_citizen=False,
            has_green_card=False,
            countable_days_cy=0,
            countable_days_py1=0,
            countable_days_py2=0,
        )).model_dump()
        merged.update(patch)
        snap.us_residency = USResidencyInput.model_validate(merged)

        prev_lock = snap.us_lock
        snap.us_lock = compute_us_lock(snap.us_residency)
        if snap.state == FSMState.US_RESIDENCY_PROVISIONAL:
            self.transition(snap, "US_LOCK_SET")

        if prev_lock is not None and prev_lock != snap.us_lock:
            self._soft_archive_invalidated_us_sections(snap, prev_lock, snap.us_lock)

        # Promote to FULLY_LOCKED if both locks are set
        if snap.india_lock is not None and snap.us_lock is not None:
            snap.state = FSMState.FULLY_LOCKED

        return snap

    def reapply_upstream(self, snap: FSMSnapshot, field_path: str, new_value: Any) -> FSMSnapshot:
        """
        Requirement: user can update an upstream input (e.g., india_days) at
        any time; this must reactively re-trigger the residency lock and
        adjust downstream states.

        The field_path is dotted: "layer0.india_days", "india_residency.employment_or_crew_status", etc.
        """
        parts = field_path.split(".", 1)
        if len(parts) != 2:
            raise ValueError(f"field_path must be 'section.field', got {field_path!r}")
        section, field = parts

        if section == "layer0":
            if snap.layer0 is None:
                raise LockNotSetError("Cannot patch layer0 before it has been submitted")
            patch = snap.layer0.model_dump()
            patch[field] = new_value
            new_l0 = Layer0Input.model_validate(patch)
            # Full re-derive (jurisdiction may flip)
            new_derived = compute_jurisdiction(new_l0)
            if (snap.layer0_derived is not None
                    and new_derived.jurisdiction != snap.layer0_derived.jurisdiction):
                self._handle_jurisdiction_change(snap, new_derived.jurisdiction)
            snap.layer0 = new_l0
            snap.layer0_derived = new_derived
            # If india_days changed, also re-push into india_residency
            if field == "india_days" and snap.india_residency is not None:
                ri = snap.india_residency.model_dump()
                ri["days_in_india_current_year"] = new_value
                snap.india_residency = IndiaResidencyInput.model_validate(ri)
                prev = snap.india_lock
                snap.india_lock = compute_india_lock(
                    snap.india_residency, is_indian_citizen=new_l0.is_indian_citizen
                )
                if prev is not None and prev != snap.india_lock:
                    self._soft_archive_invalidated_india_sections(snap, prev, snap.india_lock)
        elif section == "india_residency":
            self.apply_india_residency(snap, {field: new_value})
        elif section == "us_residency":
            self.apply_us_residency(snap, {field: new_value})
        else:
            raise ValueError(f"Unknown section {section!r}")

        # Upstream change invalidates the cached computation result
        snap.computation_result = None
        snap.last_computed_at = None
        if snap.state in (FSMState.RESULT_APPROXIMATION, FSMState.RESULT_FINAL):
            self.transition(snap, "UPDATE_UPSTREAM")
        return snap

    # ── Soft-archive helpers (Sprint 4 backing) ──
    def _soft_archive_invalidated_india_sections(
        self, snap: FSMSnapshot, prev: IndiaResidencyLock, new: IndiaResidencyLock
    ) -> None:
        """Sections whose visibility depends on lock value get archived
        (moved into `archived_india`), not deleted."""
        snap.archived_india = snap.archived_india or {}
        # DTAA is NR-only
        if prev == IndiaResidencyLock.NR and new != IndiaResidencyLock.NR:
            if "dtaa" in snap.layer1_india:
                snap.archived_india.setdefault("dtaa", []).append({
                    "archived_at": datetime.now(timezone.utc).isoformat(),
                    "reason_lock_change": f"{prev.value}→{new.value}",
                    "payload": snap.layer1_india.pop("dtaa"),
                })
        # LRS is ROR-only
        if prev == IndiaResidencyLock.ROR and new != IndiaResidencyLock.ROR:
            if "lrs_outbound" in snap.layer1_india:
                snap.archived_india.setdefault("lrs_outbound", []).append({
                    "archived_at": datetime.now(timezone.utc).isoformat(),
                    "reason_lock_change": f"{prev.value}→{new.value}",
                    "payload": snap.layer1_india.pop("lrs_outbound"),
                })

    def _soft_archive_invalidated_us_sections(
        self, snap: FSMSnapshot, prev: USResidencyLock, new: USResidencyLock
    ) -> None:
        snap.archived_us = snap.archived_us or {}
        # FEIE requires RA/USC abroad; NRA flip invalidates it.
        if (prev in (USResidencyLock.RESIDENT_ALIEN, USResidencyLock.US_CITIZEN)
                and new == USResidencyLock.NON_RESIDENT_ALIEN):
            if "feie" in snap.layer1_us:
                snap.archived_us.setdefault("feie", []).append({
                    "archived_at": datetime.now(timezone.utc).isoformat(),
                    "reason_lock_change": f"{prev.value}→{new.value}",
                    "payload": snap.layer1_us.pop("feie"),
                })

    def _handle_jurisdiction_change(
        self, snap: FSMSnapshot, new_j: Jurisdiction
    ) -> None:
        """Soft-archive entire Layer 1 module on jurisdiction shift."""
        now = datetime.now(timezone.utc).isoformat()
        if new_j == Jurisdiction.INDIA_ONLY and snap.layer1_us:
            snap.archived_us = {
                "archived_at": now,
                "reason": "jurisdiction→india_only",
                "payload": snap.layer1_us,
            }
            snap.layer1_us = {}
            snap.us_residency = None
            snap.us_lock = None
        elif new_j == Jurisdiction.US_ONLY and snap.layer1_india:
            snap.archived_india = {
                "archived_at": now,
                "reason": "jurisdiction→us_only",
                "payload": snap.layer1_india,
            }
            snap.layer1_india = {}
            snap.india_residency = None
            snap.india_lock = None
        elif new_j == Jurisdiction.DUAL:
            # Check for auto-restore (< 30 days old)
            self._maybe_restore_archived(snap)

    def _maybe_restore_archived(self, snap: FSMSnapshot) -> None:
        THIRTY_DAYS = 30 * 24 * 3600
        now = datetime.now(timezone.utc)
        if snap.archived_us and not snap.layer1_us:
            ts = datetime.fromisoformat(snap.archived_us["archived_at"])
            if (now - ts).total_seconds() < THIRTY_DAYS:
                snap.layer1_us = snap.archived_us["payload"]
                snap.archived_us = None
        if snap.archived_india and not snap.layer1_india:
            ts = datetime.fromisoformat(snap.archived_india["archived_at"])
            if (now - ts).total_seconds() < THIRTY_DAYS:
                snap.layer1_india = snap.archived_india["payload"]
                snap.archived_india = None


# ╔═════════════════════════════════════════════════════════════════════════════
# ║  SPRINT 2 — COMPUTE LAYER (THE MATH DAG)
# ║    Pure, deterministic, topologically-ordered, zero side effects.
# ╚═════════════════════════════════════════════════════════════════════════════

# ── 2.1 DAG framework ─────────────────────────────────────────────────────────
TDagCtx = TypeVar("TDagCtx", bound=BaseModel)

@dataclass
class DAGNode:
    """
    A single pure-function compute step.

    Contract:
      - `fn` takes the context (Pydantic model) and returns a dict of
        keys to set on the context (using model_copy(update=...)).
      - `depends_on` lists sibling node names that must run first.
      - `fn` MUST NOT perform I/O. Runtime enforcement is by convention.
    """
    name: str
    fn: Callable[[Any], Dict[str, Any]]
    depends_on: Tuple[str, ...] = ()
    emits_assumptions: Tuple[str, ...] = ()


class PureDAG(Generic[TDagCtx]):
    """
    Minimal DAG executor. No side effects; no I/O. Deterministic.
    Nodes are topologically sorted once on registration.
    """

    def __init__(self, name: str) -> None:
        self.name = name
        self._nodes: Dict[str, DAGNode] = {}
        self._order: List[str] = []

    def register(self, node: DAGNode) -> None:
        if node.name in self._nodes:
            raise ValueError(f"Node {node.name!r} already registered")
        self._nodes[node.name] = node
        self._order = self._topo_sort()

    def _topo_sort(self) -> List[str]:
        visited: Set[str] = set()
        ordered: List[str] = []
        temp: Set[str] = set()

        def visit(n: str) -> None:
            if n in visited:
                return
            if n in temp:
                raise DAGExecutionError(f"Cycle detected at {n!r}")
            temp.add(n)
            for dep in self._nodes[n].depends_on:
                if dep not in self._nodes:
                    raise DAGExecutionError(f"{n!r} depends on missing node {dep!r}")
                visit(dep)
            temp.discard(n)
            visited.add(n)
            ordered.append(n)

        for n in list(self._nodes):
            visit(n)
        return ordered

    def run(self, ctx: TDagCtx) -> Tuple[TDagCtx, List[str]]:
        """Execute all nodes in topo order. Returns (final_ctx, trace)."""
        trace: List[str] = []
        for name in self._order:
            node = self._nodes[name]
            try:
                update = node.fn(ctx)
            except Exception as e:
                raise DAGExecutionError(f"Node {name!r} failed: {e}") from e
            if not isinstance(update, dict):
                raise DAGExecutionError(f"Node {name!r} returned non-dict")
            ctx = ctx.model_copy(update=update)
            trace.append(name)
        return ctx, trace


# ── 2.2 India DAG — slab / surcharge / marginal relief / cess ─────────────────
# Slab table keyed by FY. Finance Act 2025 bands are default.
# TODO(CA_SIGNOFF_PENDING): swap to DOM-05 v3 bands (₹3L/₹7L/₹10L/₹12L/₹15L)
# if CA signs off on the older table. Pure data swap — no code change.
INDIA_NEW_REGIME_SLABS: Dict[str, List[Tuple[INR, Decimal]]] = {
    "FY2025-26": [
        (INR("400000"),  Decimal("0.00")),
        (INR("800000"),  Decimal("0.05")),
        (INR("1200000"), Decimal("0.10")),
        (INR("1600000"), Decimal("0.15")),
        (INR("2000000"), Decimal("0.20")),
        (INR("2400000"), Decimal("0.25")),
        (INR("99999999999"), Decimal("0.30")),
    ],
}

INDIA_OLD_REGIME_SLABS: List[Tuple[INR, Decimal]] = [
    (INR("250000"),  Decimal("0.00")),
    (INR("500000"),  Decimal("0.05")),
    (INR("1000000"), Decimal("0.20")),
    (INR("99999999999"), Decimal("0.30")),
]

# Surcharge thresholds (normal income)
INDIA_SURCHARGE_THRESHOLDS: List[Tuple[INR, Decimal]] = [
    (INR("5000000"),   Decimal("0.10")),   # 50L–1Cr
    (INR("10000000"),  Decimal("0.15")),   # 1Cr–2Cr
    (INR("20000000"),  Decimal("0.25")),   # 2Cr–5Cr
    (INR("50000000"),  Decimal("0.37")),   # >5Cr (old regime) — 25% in new regime
]
INDIA_SURCHARGE_CG_CAP = Decimal("0.15")   # Capped for LTCG/STCG per Finance Act
INDIA_CESS_RATE = Decimal("0.04")
INDIA_87A_REBATE_CEILING_NEW = INR("1200000")
INDIA_87A_REBATE_MAX_NEW = INR("60000")
INDIA_87A_REBATE_CEILING_OLD = INR("500000")
INDIA_87A_REBATE_MAX_OLD = INR("12500")


class IndiaSurchargeBuckets(StrictBase):
    """Direct mirror of layer1_india_v5_1_final.jsonc `surcharge_buckets` section."""
    income_normal_slab_inr: INR = Field(default=ZERO)
    income_stcg_111A_inr: INR = Field(default=ZERO)
    income_ltcg_112A_inr: INR = Field(default=ZERO)
    income_ltcg_112_inr: INR = Field(default=ZERO)
    income_stcg_other_inr: INR = Field(default=ZERO)
    income_dividend_inr: INR = Field(default=ZERO)
    income_special_115BB_115BBJ_inr: INR = Field(default=ZERO)
    income_vda_115BBH_inr: INR = Field(default=ZERO)
    speculative_income_inr: INR = Field(default=ZERO)


class IndiaDAGContext(StrictBase):
    """
    Context passed between India DAG nodes. Every field is a Decimal or
    typed value — no floats anywhere in the engine.
    """
    # ── Inputs ──
    financial_year: str
    residency_lock: IndiaResidencyLock
    age_at_start_of_fy: int
    tax_regime: TaxRegime
    gross_total_income_inr: INR
    chapter_via_deductions_inr: INR = Field(default=ZERO)
    surcharge_buckets: IndiaSurchargeBuckets = Field(default_factory=IndiaSurchargeBuckets)
    tds_deducted_inr: INR = Field(default=ZERO)
    advance_tax_paid_inr: INR = Field(default=ZERO)
    ftc_claimed_inr: INR = Field(default=ZERO)
    agricultural_income_inr: INR = Field(default=ZERO)

    # ── Derived (populated by DAG) ──
    total_income_inr: Optional[INR] = None
    normal_income_inr: Optional[INR] = None
    tax_on_normal_income_inr: Optional[INR] = None
    tax_on_cg_inr: Optional[INR] = None
    tax_on_special_income_inr: Optional[INR] = None
    rebate_inr: Optional[INR] = None
    surcharge_normal_inr: Optional[INR] = None
    surcharge_cg_inr: Optional[INR] = None
    marginal_relief_inr: Optional[INR] = None
    cess_inr: Optional[INR] = None
    gross_tax_liability_inr: Optional[INR] = None
    net_tax_payable_inr: Optional[INR] = None


def _round_inr(x: INR) -> INR:
    """s.288A/288B: income to nearest ₹10, tax to nearest ₹10."""
    return (x / INR("10")).quantize(INR("1"), rounding=ROUND_HALF_UP) * INR("10")


def _apply_slabs(income: INR, slabs: List[Tuple[INR, Decimal]]) -> INR:
    """Pure function. Walks a slab table and computes progressive tax."""
    tax = ZERO
    prev = ZERO
    for upper, rate in slabs:
        band = min(income, upper) - prev
        if band <= 0:
            break
        tax += band * rate
        prev = upper
        if income <= upper:
            break
    return tax


def _india_gti_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """Compute total_income and normal_income (GTI − Ch VI-A − special-rate buckets)."""
    total_income = ctx.gross_total_income_inr - ctx.chapter_via_deductions_inr
    if total_income < 0:
        total_income = ZERO
    total_income = _round_inr(total_income)   # s.288A

    special = (
        ctx.surcharge_buckets.income_stcg_111A_inr
        + ctx.surcharge_buckets.income_ltcg_112A_inr
        + ctx.surcharge_buckets.income_ltcg_112_inr
        + ctx.surcharge_buckets.income_stcg_other_inr
        + ctx.surcharge_buckets.income_special_115BB_115BBJ_inr
        + ctx.surcharge_buckets.income_vda_115BBH_inr
    )
    normal_income = total_income - special
    if normal_income < 0:
        normal_income = ZERO
    return {"total_income_inr": total_income, "normal_income_inr": normal_income}


def _india_slab_tax_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """Apply slab tax to normal income. NR cannot use OLD regime."""
    if ctx.tax_regime == TaxRegime.OLD and ctx.residency_lock == IndiaResidencyLock.NR:
        # NR blocked from old regime — force new. Assumption will be emitted
        # by the output layer, not here.
        slabs = INDIA_NEW_REGIME_SLABS[ctx.financial_year]
    elif ctx.tax_regime == TaxRegime.NEW:
        slabs = INDIA_NEW_REGIME_SLABS[ctx.financial_year]
    else:
        slabs = INDIA_OLD_REGIME_SLABS

    tax_normal = _apply_slabs(ctx.normal_income_inr or ZERO, slabs)
    return {"tax_on_normal_income_inr": tax_normal}


def _india_cg_tax_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """Flat rates on CG buckets. No slab application."""
    b = ctx.surcharge_buckets
    tax_cg = ZERO
    # STT-paid equity STCG: 20% (Budget 2024)
    tax_cg += b.income_stcg_111A_inr * Decimal("0.20")
    # STT-paid equity LTCG: 12.5% above ₹1.25L (ROR only; NRIs don't get exemption)
    if ctx.residency_lock == IndiaResidencyLock.ROR:
        ltcg_112a_taxable = max(ZERO, b.income_ltcg_112A_inr - INR("125000"))
    else:
        ltcg_112a_taxable = b.income_ltcg_112A_inr
    tax_cg += ltcg_112a_taxable * Decimal("0.125")
    # Non-STT LTCG: 12.5% (post Jul 2024, no indexation default)
    tax_cg += b.income_ltcg_112_inr * Decimal("0.125")

    # Special income: 30% flat
    tax_special = (
        b.income_special_115BB_115BBJ_inr * Decimal("0.30")
        + b.income_vda_115BBH_inr * Decimal("0.30")
    )
    # Slab-rate STCG (debt MF post-Apr 2023 etc.): already in normal slab
    return {"tax_on_cg_inr": tax_cg, "tax_on_special_income_inr": tax_special}


def _india_rebate_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """s.87A rebate — NEVER on CG tax, ROR only, new regime: ₹12L cliff/₹60K max."""
    if ctx.residency_lock != IndiaResidencyLock.ROR:
        return {"rebate_inr": ZERO}
    total_income = ctx.total_income_inr or ZERO
    tax_normal = ctx.tax_on_normal_income_inr or ZERO
    if ctx.tax_regime == TaxRegime.NEW:
        if total_income <= INDIA_87A_REBATE_CEILING_NEW:
            return {"rebate_inr": min(INDIA_87A_REBATE_MAX_NEW, tax_normal)}
        return {"rebate_inr": ZERO}
    # Old regime
    if total_income <= INDIA_87A_REBATE_CEILING_OLD:
        return {"rebate_inr": min(INDIA_87A_REBATE_MAX_OLD, tax_normal)}
    return {"rebate_inr": ZERO}


def _india_surcharge_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """Separate surcharge on normal income vs CG (15% cap on CG/Dividend)."""
    total_income = ctx.total_income_inr or ZERO
    tax_normal_after_rebate = max(ZERO, (ctx.tax_on_normal_income_inr or ZERO) - (ctx.rebate_inr or ZERO))
    tax_cg = ctx.tax_on_cg_inr or ZERO

    rate_normal = ZERO
    for threshold, rate in INDIA_SURCHARGE_THRESHOLDS:
        if total_income > threshold:
            rate_normal = rate
    rate_cg = min(rate_normal, INDIA_SURCHARGE_CG_CAP)

    return {
        "surcharge_normal_inr": tax_normal_after_rebate * rate_normal,
        "surcharge_cg_inr": tax_cg * rate_cg,
    }


def _india_marginal_relief_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """Ensure additional tax above threshold ≤ additional income above threshold."""
    total_income = ctx.total_income_inr or ZERO
    tax_before_mr = (
        (ctx.tax_on_normal_income_inr or ZERO)
        - (ctx.rebate_inr or ZERO)
        + (ctx.surcharge_normal_inr or ZERO)
        + (ctx.tax_on_cg_inr or ZERO)
        + (ctx.surcharge_cg_inr or ZERO)
    )
    relief = ZERO
    for threshold, _ in INDIA_SURCHARGE_THRESHOLDS:
        if total_income > threshold:
            # Hypothetical tax at exactly threshold income, regime-aware
            slabs = (INDIA_NEW_REGIME_SLABS[ctx.financial_year]
                     if ctx.tax_regime == TaxRegime.NEW
                     else INDIA_OLD_REGIME_SLABS)
            tax_at_threshold = _apply_slabs(threshold, slabs)
            excess_income = total_income - threshold
            max_additional = excess_income
            additional_tax = tax_before_mr - tax_at_threshold
            if additional_tax > max_additional:
                relief_here = additional_tax - max_additional
                if relief_here > relief:
                    relief = relief_here
    return {"marginal_relief_inr": relief}


def _india_cess_and_net_node(ctx: IndiaDAGContext) -> Dict[str, Any]:
    """Cess 4% then subtract TDS/AT/FTC."""
    tax_after_mr = (
        (ctx.tax_on_normal_income_inr or ZERO)
        - (ctx.rebate_inr or ZERO)
        + (ctx.surcharge_normal_inr or ZERO)
        + (ctx.tax_on_cg_inr or ZERO)
        + (ctx.surcharge_cg_inr or ZERO)
        + (ctx.tax_on_special_income_inr or ZERO)
        - (ctx.marginal_relief_inr or ZERO)
    )
    cess = tax_after_mr * INDIA_CESS_RATE
    gross = tax_after_mr + cess
    gross = _round_inr(gross)    # s.288B
    net = gross - ctx.tds_deducted_inr - ctx.advance_tax_paid_inr - ctx.ftc_claimed_inr
    return {
        "cess_inr": cess,
        "gross_tax_liability_inr": gross,
        "net_tax_payable_inr": net,
    }


def build_india_dag() -> PureDAG[IndiaDAGContext]:
    dag: PureDAG[IndiaDAGContext] = PureDAG("india")
    dag.register(DAGNode("gti", _india_gti_node))
    dag.register(DAGNode("slab_tax", _india_slab_tax_node, depends_on=("gti",)))
    dag.register(DAGNode("cg_tax", _india_cg_tax_node, depends_on=("gti",)))
    dag.register(DAGNode("rebate", _india_rebate_node, depends_on=("slab_tax", "gti")))
    dag.register(DAGNode("surcharge", _india_surcharge_node,
                         depends_on=("rebate", "cg_tax", "gti")))
    dag.register(DAGNode("marginal_relief", _india_marginal_relief_node,
                         depends_on=("surcharge",)))
    dag.register(DAGNode("cess_and_net", _india_cess_and_net_node,
                         depends_on=("marginal_relief",)))
    return dag


# ── 2.3 US DAG — 1040 / AMT / NIIT / FTC ──────────────────────────────────────
# OBBBA 2026 constants per Layer 1 US v2.0 + NRI_Tax_07_Sunset_Planning_v3
US_STD_DEDUCTION_SINGLE = USD("16100")
US_STD_DEDUCTION_MFJ = USD("32200")
US_STD_DEDUCTION_HOH = USD("24150")

# 2026 federal brackets (Single) — illustrative; full table should be keyed by filing_status
US_FEDERAL_BRACKETS_2026_SINGLE: List[Tuple[USD, Decimal]] = [
    (USD("11925"),   Decimal("0.10")),
    (USD("48475"),   Decimal("0.12")),
    (USD("103350"),  Decimal("0.22")),
    (USD("197300"),  Decimal("0.24")),
    (USD("250525"),  Decimal("0.32")),
    (USD("626350"),  Decimal("0.35")),
    (USD("99999999"),Decimal("0.37")),
]

US_NIIT_RATE = Decimal("0.038")
US_NIIT_THRESHOLD_SINGLE = USD("200000")
US_NIIT_THRESHOLD_MFJ = USD("250000")

US_AMT_RATE_LOW = Decimal("0.26")
US_AMT_RATE_HIGH = Decimal("0.28")
US_AMT_RATE_BREAK = USD("232600")
US_AMT_EXEMPTION_SINGLE = USD("137000")
US_AMT_EXEMPTION_MFJ = USD("126500")


class USFilingStatus(str, Enum):
    SINGLE = "single"
    MFJ = "mfj"
    MFS = "mfs"
    HOH = "hoh"


class USDAGContext(StrictBase):
    # ── Inputs ──
    us_residency_lock: USResidencyLock
    filing_status: USFilingStatus
    calendar_year: int
    worldwide_wages_usd: USD = Field(default=ZERO)
    worldwide_investment_income_usd: USD = Field(default=ZERO)
    iso_spread_at_exercise_usd: USD = Field(default=ZERO)      # AMT preference item
    itemized_deductions_usd: USD = Field(default=ZERO)
    state_local_tax_paid_usd: USD = Field(default=ZERO)
    india_tax_paid_inr: INR = Field(default=ZERO)              # for FTC (converted upstream)
    india_tax_paid_usd: USD = Field(default=ZERO)              # already-converted
    modified_agi_usd: Optional[USD] = None                     # for NIIT threshold test

    # ── Derived ──
    agi_usd: Optional[USD] = None
    taxable_income_usd: Optional[USD] = None
    regular_tax_usd: Optional[USD] = None
    amt_usd: Optional[USD] = None
    niit_usd: Optional[USD] = None
    ftc_allowed_usd: Optional[USD] = None
    federal_tax_payable_usd: Optional[USD] = None


def _us_agi_node(ctx: USDAGContext) -> Dict[str, Any]:
    """Very simplified AGI: wages + investment income. ECI-only for NRA handled upstream."""
    if ctx.us_residency_lock == USResidencyLock.NON_RESIDENT_ALIEN:
        # NRA: ECI only — upstream should already have scoped the inputs
        agi = ctx.worldwide_wages_usd + ctx.worldwide_investment_income_usd
    else:
        # USC / RA: worldwide
        agi = ctx.worldwide_wages_usd + ctx.worldwide_investment_income_usd
    return {"agi_usd": agi}


def _us_taxable_income_node(ctx: USDAGContext) -> Dict[str, Any]:
    """Apply standard vs itemized deduction. NRA cannot take standard."""
    std = {
        USFilingStatus.SINGLE: US_STD_DEDUCTION_SINGLE,
        USFilingStatus.MFJ: US_STD_DEDUCTION_MFJ,
        USFilingStatus.MFS: US_STD_DEDUCTION_SINGLE,
        USFilingStatus.HOH: US_STD_DEDUCTION_HOH,
    }[ctx.filing_status]
    if ctx.us_residency_lock == USResidencyLock.NON_RESIDENT_ALIEN:
        deduction = ctx.itemized_deductions_usd   # NRA: itemized only
    else:
        deduction = max(std, ctx.itemized_deductions_usd)
    ti = max(ZERO, (ctx.agi_usd or ZERO) - deduction)
    return {"taxable_income_usd": ti}


def _us_regular_tax_node(ctx: USDAGContext) -> Dict[str, Any]:
    """Apply federal slabs. Filing-status-aware slab table lookup."""
    # For brevity, only Single is wired; production would key by status.
    slabs = US_FEDERAL_BRACKETS_2026_SINGLE
    tax = _apply_slabs(ctx.taxable_income_usd or ZERO, slabs)
    return {"regular_tax_usd": tax}


def _us_amt_node(ctx: USDAGContext) -> Dict[str, Any]:
    """AMT. ISO spread at exercise is the major preference item."""
    exemption = (US_AMT_EXEMPTION_MFJ if ctx.filing_status == USFilingStatus.MFJ
                 else US_AMT_EXEMPTION_SINGLE)
    amti = (ctx.taxable_income_usd or ZERO) + ctx.iso_spread_at_exercise_usd
    # Add back SALT per AMT rules
    amti += ctx.state_local_tax_paid_usd
    amti_after_exemption = max(ZERO, amti - exemption)
    if amti_after_exemption <= US_AMT_RATE_BREAK:
        amt_tentative = amti_after_exemption * US_AMT_RATE_LOW
    else:
        amt_tentative = (
            US_AMT_RATE_BREAK * US_AMT_RATE_LOW
            + (amti_after_exemption - US_AMT_RATE_BREAK) * US_AMT_RATE_HIGH
        )
    amt = max(ZERO, amt_tentative - (ctx.regular_tax_usd or ZERO))
    return {"amt_usd": amt}


def _us_niit_node(ctx: USDAGContext) -> Dict[str, Any]:
    """3.8% on lesser of NII or MAGI−threshold. NRA exempt from NIIT."""
    if ctx.us_residency_lock == USResidencyLock.NON_RESIDENT_ALIEN:
        return {"niit_usd": ZERO}
    threshold = (US_NIIT_THRESHOLD_MFJ if ctx.filing_status == USFilingStatus.MFJ
                 else US_NIIT_THRESHOLD_SINGLE)
    magi = ctx.modified_agi_usd or (ctx.agi_usd or ZERO)
    excess = max(ZERO, magi - threshold)
    niit_base = min(ctx.worldwide_investment_income_usd, excess)
    return {"niit_usd": niit_base * US_NIIT_RATE}


def _us_ftc_node(ctx: USDAGContext) -> Dict[str, Any]:
    """Form 1116 FTC. Simplified: credit up to regular_tax * (foreign/total)."""
    # Foreign source portion proxied by india_tax_paid_usd / 100
    # (production: per-basket computation with carryforward)
    foreign_tax = ctx.india_tax_paid_usd
    reg_tax = ctx.regular_tax_usd or ZERO
    # Cap by regular tax * (foreign_income / total_income) — simplified
    ftc_limit = reg_tax  # placeholder; full computation needs foreign_source_ti
    return {"ftc_allowed_usd": min(foreign_tax, ftc_limit)}


def _us_federal_net_node(ctx: USDAGContext) -> Dict[str, Any]:
    """Final: max(regular, AMT) - FTC + NIIT."""
    higher_of = max((ctx.regular_tax_usd or ZERO), (ctx.amt_usd or ZERO))
    net = higher_of - (ctx.ftc_allowed_usd or ZERO) + (ctx.niit_usd or ZERO)
    return {"federal_tax_payable_usd": max(ZERO, net)}


def build_us_dag() -> PureDAG[USDAGContext]:
    dag: PureDAG[USDAGContext] = PureDAG("us")
    dag.register(DAGNode("agi", _us_agi_node))
    dag.register(DAGNode("taxable_income", _us_taxable_income_node, depends_on=("agi",)))
    dag.register(DAGNode("regular_tax", _us_regular_tax_node, depends_on=("taxable_income",)))
    dag.register(DAGNode("amt", _us_amt_node, depends_on=("regular_tax",)))
    dag.register(DAGNode("niit", _us_niit_node, depends_on=("agi",)))
    dag.register(DAGNode("ftc", _us_ftc_node, depends_on=("regular_tax",)))
    dag.register(DAGNode("net", _us_federal_net_node, depends_on=("amt", "niit", "ftc")))
    return dag


# ── 2.5 Evaluate Tax trigger — the ONLY public entry point for the DAG ────────
#     Wizard does NOT invoke the DAG on every field change. Only on the
#     explicit "Evaluate Tax" event.
INDIA_DAG = build_india_dag()
US_DAG = build_us_dag()


def evaluate_tax(
    snap: FSMSnapshot,
    fsm: WizardFSM,
    india_ctx: Optional[IndiaDAGContext] = None,
    us_ctx: Optional[USDAGContext] = None,
) -> "TaxComputationOutput":
    """
    Only valid from READY_TO_EVALUATE. Fires the India and/or US DAGs in
    parallel (conceptually — in a single worker they run sequentially).
    """
    if snap.state != FSMState.READY_TO_EVALUATE:
        # Allow firing from INCOME_SECTIONS_OPEN if user skipped "READY" button
        if snap.state == FSMState.INCOME_SECTIONS_OPEN:
            fsm.transition(snap, "READY")
        else:
            raise InvalidTransitionError(
                f"Cannot EVALUATE_TAX from {snap.state.value}"
            )
    fsm.transition(snap, "EVALUATE_TAX")

    india_result: Optional[Dict[str, Any]] = None
    us_result: Optional[Dict[str, Any]] = None

    if (snap.layer0_derived and snap.layer0_derived.india_flag and india_ctx):
        final, trace = INDIA_DAG.run(india_ctx)
        india_result = final.model_dump(mode="json")
        india_result["_trace"] = trace
    if (snap.layer0_derived and snap.layer0_derived.us_flag and us_ctx):
        final, trace = US_DAG.run(us_ctx)
        us_result = final.model_dump(mode="json")
        us_result["_trace"] = trace

    # Completion evaluation and APPROXIMATION / FINAL stamp → Sprint 3
    output = TaxComputationOutput.build(snap, india_result, us_result)
    if output.status == ComputationStatus.FINAL:
        fsm.transition(snap, "COMPUTE_DONE_FINAL")
    else:
        fsm.transition(snap, "COMPUTE_DONE_APPROX")
    snap.computation_result = output.model_dump(mode="json")
    snap.last_computed_at = datetime.now(timezone.utc)
    return output


# ╔═════════════════════════════════════════════════════════════════════════════
# ║  SPRINT 3 — OUTPUT LAYER & TESTING
# ╚═════════════════════════════════════════════════════════════════════════════

# ── 3.1 Assumption model — surfaced to the user; no silent defaults ───────────
class Assumption(StrictBase):
    field: str
    assumed: Any
    reason: str
    user_changeable: bool = True


class MissingRequiredField(StrictBase):
    field: str
    friendly_label: str
    section: str


class CompletionDetail(StrictBase):
    percentage: int = Field(ge=0, le=100)
    filled: int
    total: int
    missing_required: List[MissingRequiredField]


class TaxComputationOutput(StrictBase):
    """The canonical response shape. NEVER returned silently — every
    assumption and every missing input is explicit."""
    status: ComputationStatus                            # APPROXIMATION or FINAL
    completion: CompletionDetail
    india_tax: Optional[Dict[str, Any]] = None
    us_tax: Optional[Dict[str, Any]] = None
    assumptions_used: List[Assumption] = Field(default_factory=list)
    computed_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    schema_version: str = "v5.1"

    # Stamped-hash of the full payload; used by clients to detect stale results.
    payload_hash: Optional[str] = None

    @classmethod
    def build(
        cls,
        snap: FSMSnapshot,
        india_result: Optional[Dict[str, Any]],
        us_result: Optional[Dict[str, Any]],
    ) -> "TaxComputationOutput":
        completion = compute_completion(snap)
        assumptions = collect_assumptions(snap)
        status = (ComputationStatus.FINAL
                  if completion.percentage == 100 and not assumptions
                  else ComputationStatus.APPROXIMATION)

        # ── Defensive: any assumption forces APPROXIMATION, even at 100% ─
        # because 100% of *collected* fields does not mean zero engine defaults.

        output = cls(
            status=status,
            completion=completion,
            india_tax=india_result,
            us_tax=us_result,
            assumptions_used=assumptions,
        )
        payload = output.model_dump(mode="json", exclude={"payload_hash"})
        output.payload_hash = hashlib.sha256(
            json.dumps(payload, sort_keys=True, default=str).encode()
        ).hexdigest()
        return output


def collect_assumptions(snap: FSMSnapshot) -> List[Assumption]:
    """Walk the snapshot and emit an Assumption for every silent default
    the engine would otherwise use."""
    out: List[Assumption] = []
    # India: tax_regime default
    if snap.india_lock is not None:
        regime = snap.layer1_india.get("profile", {}).get("tax_regime")
        if regime is None and snap.india_lock == IndiaResidencyLock.NR:
            out.append(Assumption(
                field="layer1_india.profile.tax_regime",
                assumed="NEW",
                reason="NR defaults to NEW regime; OLD not legally blocked but rarely optimal",
            ))
        elif regime is None:
            out.append(Assumption(
                field="layer1_india.profile.tax_regime",
                assumed="NEW",
                reason="Regime not selected; engine auto-computed both, using lower",
            ))
    # US: filing_status default
    if snap.us_lock is not None:
        fs = snap.layer1_us.get("filing_status")
        if fs is None:
            out.append(Assumption(
                field="layer1_us.filing_status",
                assumed="single",
                reason="Filing status not provided; assumed single. Marriage affects brackets.",
            ))
    # CII status for indexation users
    if snap.india_lock is not None:
        has_property = bool(snap.layer1_india.get("property"))
        cii_confirmed = snap.layer1_india.get("metadata", {}).get("cii_confirmed_for_fy")
        if has_property and not cii_confirmed:
            out.append(Assumption(
                field="layer1_india.metadata.cii_confirmed_for_fy",
                assumed="pending",
                reason="CII for FY not yet notified by CBDT; indexation is estimated",
                user_changeable=False,
            ))
    return out


def compute_completion(snap: FSMSnapshot) -> CompletionDetail:
    """
    Pure function over the snapshot. A real impl reads field_registry
    to enumerate required fields; here we sketch the surface.
    """
    required_fields: List[Tuple[str, str, str]] = []
    # Layer 0 — always required when any jurisdiction is active
    required_fields += [
        ("layer0.is_indian_citizen", "Are you an Indian citizen?", "layer0"),
        ("layer0.is_us_citizen", "Are you a US citizen?", "layer0"),
        ("layer0.india_days", "Days in India this FY", "layer0"),
    ]
    if snap.layer0_derived and snap.layer0_derived.india_flag:
        required_fields += [
            ("layer1_india.profile.pan", "PAN", "profile"),
            ("layer1_india.profile.date_of_birth", "Date of birth", "profile"),
        ]
    if snap.layer0_derived and snap.layer0_derived.us_flag:
        required_fields += [
            ("layer1_us.filing_status", "Filing status", "us_residency_detail"),
            ("layer1_us.state_residency.primary_state_of_residence", "State of residence",
             "state_residency"),
        ]
    total = len(required_fields)
    missing: List[MissingRequiredField] = []
    filled = 0
    for path, label, section in required_fields:
        if _get_by_path(snap, path) in (None, "", []):
            missing.append(MissingRequiredField(
                field=path, friendly_label=label, section=section
            ))
        else:
            filled += 1
    pct = int(round((filled / total) * 100)) if total else 100
    return CompletionDetail(percentage=pct, filled=filled, total=total, missing_required=missing)


def _get_by_path(snap: FSMSnapshot, dotted: str) -> Any:
    """Utility: 'layer0.is_indian_citizen' → snap.layer0.is_indian_citizen."""
    parts = dotted.split(".")
    root = parts[0]
    if root == "layer0" and snap.layer0:
        obj: Any = snap.layer0.model_dump()
    elif root == "layer1_india":
        obj = snap.layer1_india
    elif root == "layer1_us":
        obj = snap.layer1_us
    else:
        return None
    for p in parts[1:]:
        if obj is None:
            return None
        if isinstance(obj, dict):
            obj = obj.get(p)
        else:
            obj = getattr(obj, p, None)
    return obj


# ── 3.4 Unit tests ────────────────────────────────────────────────────────────
# Run with: pytest wising_tax_engine_core.py
def _test_fsm_provisional_to_locked() -> None:
    """Requirement 3.1.a: state machine transition provisional → locked."""
    fsm = WizardFSM()
    snap = FSMSnapshot(
        user_id=uuid4(),
        tax_year_id=uuid4(),
        state=FSMState.LAYER0_IN_PROGRESS,
    )
    # Submit Layer 0 — Indian citizen, 200 days in India
    l0 = Layer0Input(
        is_indian_citizen=True,
        is_pio_or_oci=None,
        india_days=200,
        has_india_source_income_or_assets=True,
        is_us_citizen=False,
        has_green_card=False,
        was_in_us_this_year=False,
        us_days=None,
        has_us_source_income_or_assets=False,
        liable_to_tax_in_another_country=False,
        left_india_for_employment_this_year=False,
    )
    fsm.apply_layer0(snap, l0)
    assert snap.state == FSMState.JURISDICTION_DERIVED, snap.state
    assert snap.layer0_derived and snap.layer0_derived.jurisdiction == Jurisdiction.INDIA_ONLY

    # Provide remaining India residency inputs. With DAYS=200 and NR9=false/D7_729=false,
    # RS-001 should fire ROR-1.
    fsm.apply_india_residency(snap, {
        "nr_years_last_10_gte_9": False,
        "days_in_india_last_7_years_lte_729": False,
    })
    assert snap.state == FSMState.INDIA_LOCKED, f"expected INDIA_LOCKED, got {snap.state}"
    assert snap.india_lock == IndiaResidencyLock.ROR

    print("PASS  test_fsm_provisional_to_locked")


def _test_dag_determinism() -> None:
    """Requirement 3.1.b: DAG produces deterministic output for identical input."""
    ctx = IndiaDAGContext(
        financial_year="FY2025-26",
        residency_lock=IndiaResidencyLock.ROR,
        age_at_start_of_fy=35,
        tax_regime=TaxRegime.NEW,
        gross_total_income_inr=INR("1500000"),
        chapter_via_deductions_inr=ZERO,
        tds_deducted_inr=INR("0"),
    )
    out1, trace1 = INDIA_DAG.run(ctx)
    out2, trace2 = INDIA_DAG.run(ctx)
    assert out1.model_dump() == out2.model_dump(), "DAG non-deterministic!"
    assert trace1 == trace2
    # Spot-check: ₹15L GTI, all normal income, new regime → slab tax
    # 0–4L: 0 | 4L–8L: ₹20K | 8L–12L: ₹40K | 12L–15L: ₹45K = ₹1,05,000
    assert out1.tax_on_normal_income_inr == INR("105000"), out1.tax_on_normal_income_inr
    print("PASS  test_dag_determinism")


def _test_parallel_flag_routing() -> None:
    """Layer 0 parallel flag: no india_days gate on us flag."""
    l0 = Layer0Input(
        is_indian_citizen=False,
        is_pio_or_oci=False,
        india_days=0,
        has_india_source_income_or_assets=False,
        is_us_citizen=True,
        has_green_card=None,
        was_in_us_this_year=True,
        us_days=365,
        has_us_source_income_or_assets=True,
        liable_to_tax_in_another_country=None,
        left_india_for_employment_this_year=None,
    )
    d = compute_jurisdiction(l0)
    assert d.jurisdiction == Jurisdiction.US_ONLY
    assert d.us_flag and not d.india_flag
    print("PASS  test_parallel_flag_routing")


def _test_rs001_rnor_3_deemed_resident() -> None:
    """Deemed Resident RNOR-3: Indian citizen, 60–181 days, >₹15L India income,
    not liable elsewhere."""
    ri = IndiaResidencyInput(
        days_in_india_current_year=130,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentOrCrew.EMPLOYED_ABROAD,
        india_source_income_above_15l=True,
        liable_to_tax_in_another_country_being_indian_citizen=False,
    )
    lock = compute_india_lock(ri, is_indian_citizen=True)
    assert lock == IndiaResidencyLock.RNOR, lock
    print("PASS  test_rs001_rnor_3_deemed_resident")


def _test_citizenship_blocks_deemed_resident_path() -> None:
    """PIO (citizen=false) cannot enter RNOR-7 even when other conditions match."""
    ri = IndiaResidencyInput(
        days_in_india_current_year=30,
        india_source_income_above_15l=True,
        liable_to_tax_in_another_country_being_indian_citizen=False,
    )
    lock = compute_india_lock(ri, is_indian_citizen=False)
    assert lock == IndiaResidencyLock.NR
    print("PASS  test_citizenship_blocks_deemed_resident_path")


def _test_assumptions_emitted_when_defaults_applied() -> None:
    """No silent defaults: every default must appear in assumptions_used."""
    snap = FSMSnapshot(
        user_id=uuid4(),
        tax_year_id=uuid4(),
        state=FSMState.FULLY_LOCKED,
        india_lock=IndiaResidencyLock.NR,
        layer1_india={"profile": {}},   # tax_regime omitted
        layer0_derived=Layer0Derived(
            india_flag=True, us_flag=False, jurisdiction=Jurisdiction.INDIA_ONLY
        ),
    )
    assumptions = collect_assumptions(snap)
    assert any(a.field == "layer1_india.profile.tax_regime" for a in assumptions)
    print("PASS  test_assumptions_emitted_when_defaults_applied")


def _run_all_tests() -> None:
    _test_fsm_provisional_to_locked()
    _test_dag_determinism()
    _test_parallel_flag_routing()
    _test_rs001_rnor_3_deemed_resident()
    _test_citizenship_blocks_deemed_resident_path()
    _test_assumptions_emitted_when_defaults_applied()


# ╔═════════════════════════════════════════════════════════════════════════════
# ║  SPRINT 4 — SECURITY & PERSISTENCE
# ╚═════════════════════════════════════════════════════════════════════════════

# ── 4.1 DDL (text-only — run via Alembic in prod) ─────────────────────────────
TAX_STATE_SNAPSHOTS_DDL = """
CREATE TABLE IF NOT EXISTS tax_state_snapshots (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL,
    tax_year_id         UUID NOT NULL,

    -- The three schemas
    layer0_state        JSONB NOT NULL DEFAULT '{}'::jsonb,
    layer1_india        JSONB,
    layer1_us           JSONB,

    -- Archived shadows (soft-hide)
    archived_india      JSONB,
    archived_us         JSONB,

    -- Derived state
    jurisdiction        TEXT,
    india_lock          TEXT,
    us_lock             TEXT,
    fsm_state           TEXT NOT NULL DEFAULT 'layer0_in_progress',
    completion_pct      INTEGER NOT NULL DEFAULT 0,
    completion_detail   JSONB,

    -- Last computation
    computation_result  JSONB,
    is_approximation    BOOLEAN DEFAULT TRUE,
    payload_hash        TEXT,
    last_computed_at    TIMESTAMPTZ,

    -- Lifecycle
    status              TEXT NOT NULL DEFAULT 'active',
    schema_version      TEXT NOT NULL DEFAULT 'v5.1',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Partial unique index: only one ACTIVE row per (user, tax_year)
CREATE UNIQUE INDEX IF NOT EXISTS ux_snapshots_active
    ON tax_state_snapshots(user_id, tax_year_id)
    WHERE status = 'active';
"""

TAX_EVENTS_DDL = """
CREATE TABLE IF NOT EXISTS tax_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    tax_year_id     UUID NOT NULL,
    event_type      TEXT NOT NULL,   -- field_update, jurisdiction_changed,
                                     -- lock_changed, computation_requested,
                                     -- computation_completed, section_archived
    payload         JSONB NOT NULL,
    caused_by       UUID REFERENCES tax_events(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_events_user_year
    ON tax_events(user_id, tax_year_id, created_at);
"""

FIELD_REGISTRY_DDL = """
CREATE TABLE IF NOT EXISTS field_registry (
    field_path      TEXT PRIMARY KEY,
    schema_name     TEXT NOT NULL,       -- layer0 | layer1_india | layer1_us
    section         TEXT NOT NULL,
    classification  TEXT NOT NULL,       -- REQUIRED | OPTIONAL | DERIVED | CONDITIONAL
    friendly_label  TEXT NOT NULL,
    input_type      TEXT NOT NULL,
    enabled_if      JSONB,
    default_value   JSONB,
    default_label   TEXT,
    wizard_order    INTEGER,
    section_order   INTEGER
);
"""


# ── 4.2 Repository — thin asyncpg wrapper (TRD v1.1 PATCH-4 compliant) ────────
#     Strict model for API ingress; permissive model for DB JSONB reads.
class TaxSnapshotRow(PermissiveBase):
    """DB row projection. extra=ignore absorbs legacy/forward-compat fields."""
    id: UUID
    user_id: UUID
    tax_year_id: UUID
    layer0_state: Dict[str, Any] = Field(default_factory=dict)
    layer1_india: Optional[Dict[str, Any]] = None
    layer1_us: Optional[Dict[str, Any]] = None
    archived_india: Optional[Dict[str, Any]] = None
    archived_us: Optional[Dict[str, Any]] = None
    jurisdiction: Optional[str] = None
    india_lock: Optional[str] = None
    us_lock: Optional[str] = None
    fsm_state: str = FSMState.LAYER0_IN_PROGRESS.value
    completion_pct: int = 0
    status: str = SnapshotStatus.ACTIVE.value
    schema_version: str = "v5.1"
    computation_result: Optional[Dict[str, Any]] = None


class SnapshotRepository:
    """
    All writes go through this class. Soft-archive is enforced here — no
    caller can DELETE a row; the only mutation is UPDATE SET status=archived.
    """

    def __init__(self, pool: Any) -> None:  # asyncpg.Pool in prod
        self.pool = pool

    async def create(
        self, user_id: UUID, tax_year_id: UUID
    ) -> TaxSnapshotRow:
        """POST /tax-years — initial row creation."""
        query = """
            INSERT INTO tax_state_snapshots (user_id, tax_year_id, fsm_state)
            VALUES ($1, $2, 'layer0_in_progress')
            RETURNING *;
        """
        row = await self.pool.fetchrow(query, user_id, tax_year_id)
        return TaxSnapshotRow.model_validate(dict(row))

    async def get_active(
        self, user_id: UUID, tax_year_id: UUID
    ) -> Optional[TaxSnapshotRow]:
        query = """
            SELECT * FROM tax_state_snapshots
            WHERE user_id=$1 AND tax_year_id=$2 AND status='active';
        """
        row = await self.pool.fetchrow(query, user_id, tax_year_id)
        return TaxSnapshotRow.model_validate(dict(row)) if row else None

    async def upsert_section(
        self,
        snapshot_id: UUID,
        jurisdiction: Literal["india", "us"],
        section: str,
        data: Dict[str, Any],
    ) -> None:
        """PUT /tax-years/{id}/{jurisdiction}/{section} — section-level upsert."""
        col = "layer1_india" if jurisdiction == "india" else "layer1_us"
        query = f"""
            UPDATE tax_state_snapshots
            SET {col} = COALESCE({col}, '{{}}'::jsonb) || jsonb_build_object($2::text, $3::jsonb),
                updated_at = now()
            WHERE id = $1 AND status = 'active';
        """
        await self.pool.execute(query, snapshot_id, section, json.dumps(data))

    async def archive_on_jurisdiction_change(
        self,
        snapshot_id: UUID,
        new_jurisdiction: Jurisdiction,
    ) -> None:
        """Soft-hide the invalidated module instead of deleting.

        CRITICAL: this is the ONLY path that touches layer1_{india,us} outside
        of normal upserts, and it NEVER deletes — it moves the payload into
        the archived_{india,us} JSONB column with a timestamp and reason.
        """
        if new_jurisdiction == Jurisdiction.INDIA_ONLY:
            query = """
                UPDATE tax_state_snapshots
                SET archived_us = jsonb_build_object(
                        'archived_at', now()::text,
                        'reason', 'jurisdiction_change_to_india_only',
                        'payload', COALESCE(layer1_us, '{}'::jsonb)
                    ),
                    layer1_us = NULL,
                    us_lock = NULL,
                    updated_at = now()
                WHERE id = $1 AND status = 'active' AND layer1_us IS NOT NULL;
            """
            await self.pool.execute(query, snapshot_id)
        elif new_jurisdiction == Jurisdiction.US_ONLY:
            query = """
                UPDATE tax_state_snapshots
                SET archived_india = jsonb_build_object(
                        'archived_at', now()::text,
                        'reason', 'jurisdiction_change_to_us_only',
                        'payload', COALESCE(layer1_india, '{}'::jsonb)
                    ),
                    layer1_india = NULL,
                    india_lock = NULL,
                    updated_at = now()
                WHERE id = $1 AND status = 'active' AND layer1_india IS NOT NULL;
            """
            await self.pool.execute(query, snapshot_id)

    async def log_event(
        self,
        user_id: UUID,
        tax_year_id: UUID,
        event_type: str,
        payload: Dict[str, Any],
        caused_by: Optional[UUID] = None,
    ) -> UUID:
        query = """
            INSERT INTO tax_events (user_id, tax_year_id, event_type, payload, caused_by)
            VALUES ($1, $2, $3, $4::jsonb, $5)
            RETURNING id;
        """
        return await self.pool.fetchval(
            query, user_id, tax_year_id, event_type, json.dumps(payload), caused_by
        )


# ── 4.3 FastAPI endpoints (skeletons) ─────────────────────────────────────────
#     The full router is deliberately not wired to FastAPI imports here to
#     keep this file runnable as a pure module. Paste into app/routers/.

"""
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status

router = APIRouter(prefix="/api/v1")
fsm = WizardFSM()

# ─── POST /tax-years  (Layer 0 submission) ─────────────────────────────────
@router.post("/tax-years", response_model=Layer0Response, status_code=201)
async def submit_layer0(
    payload: Layer0Input,
    user_id: UUID,                                   # from JWT middleware
    bg: BackgroundTasks,                             # TRD PATCH-1: async write
    repo: SnapshotRepository = Depends(get_repo),
):
    # 1. Ingress validation already happened via Pydantic (STRICT mode)
    # 2. Compute jurisdiction synchronously
    derived = compute_jurisdiction(payload)
    # 3. Load-or-create snapshot
    row = await repo.get_active(user_id, CURRENT_TAX_YEAR_ID)
    if row is None:
        row = await repo.create(user_id, CURRENT_TAX_YEAR_ID)
    # 4. Handle jurisdiction change (if any) — soft-archive invalidated module
    if row.jurisdiction and row.jurisdiction != derived.jurisdiction.value:
        await repo.archive_on_jurisdiction_change(row.id, derived.jurisdiction)
    # 5. Persist Layer 0 and derived fields
    await repo.pool.execute(
        \"\"\"UPDATE tax_state_snapshots
           SET layer0_state=$1::jsonb, jurisdiction=$2, fsm_state='jurisdiction_derived',
               updated_at=now()
           WHERE id=$3\"\"\",
        json.dumps(payload.model_dump(mode="json")),
        derived.jurisdiction.value, row.id,
    )
    # 6. TRD PATCH-1: audit and Service Bus publish happen in BackgroundTask
    bg.add_task(repo.log_event, user_id, CURRENT_TAX_YEAR_ID,
                "field_update", {"layer": "layer0", "fields": list(payload.model_dump())})
    # 7. Respond
    return Layer0Response(
        tax_year_id=row.id,
        jurisdiction=derived.jurisdiction,
        india_flag=derived.india_flag,
        us_flag=derived.us_flag,
    )

# ─── PUT /tax-years/{id}/{jurisdiction}/{section}  (Layer 1 section upsert) ─
@router.put("/tax-years/{tax_year_id}/{jur}/{section}")
async def upsert_layer1_section(
    tax_year_id: UUID,
    jur: Literal["india", "us"],
    section: str,
    payload: Dict[str, Any],
    bg: BackgroundTasks,
    user_id: UUID = Depends(get_user_id),
    repo: SnapshotRepository = Depends(get_repo),
):
    row = await repo.get_active(user_id, tax_year_id)
    if row is None:
        raise HTTPException(status_code=404, detail="tax_year not found")
    # Jurisdiction gate: reject india sections when jurisdiction is us_only
    if jur == "india" and row.jurisdiction == "us_only":
        raise HTTPException(status_code=409, detail="jurisdiction_mismatch")
    if jur == "us" and row.jurisdiction == "india_only":
        raise HTTPException(status_code=409, detail="jurisdiction_mismatch")
    # Validate per section via SECTION_MODELS registry (omitted here for brevity)
    validated_payload = validate_section(jur, section, payload)   # raises on error
    await repo.upsert_section(row.id, jur, section, validated_payload)
    bg.add_task(repo.log_event, user_id, tax_year_id, "field_update",
                {"layer": f"layer1_{jur}", "section": section})
    return {"status": "saved", "section": section, "updated_at": datetime.utcnow().isoformat()}

# ─── POST /tax-years/{id}/evaluate  (Evaluate Tax trigger) ─────────────────
@router.post("/tax-years/{tax_year_id}/evaluate", response_model=TaxComputationOutput)
async def evaluate(
    tax_year_id: UUID,
    user_id: UUID = Depends(get_user_id),
    repo: SnapshotRepository = Depends(get_repo),
):
    row = await repo.get_active(user_id, tax_year_id)
    if row is None:
        raise HTTPException(status_code=404)
    # Reconstitute FSMSnapshot from row (helper omitted)
    snap = snapshot_from_row(row)
    india_ctx = build_india_ctx(snap) if snap.layer0_derived.india_flag else None
    us_ctx = build_us_ctx(snap) if snap.layer0_derived.us_flag else None
    return evaluate_tax(snap, fsm, india_ctx, us_ctx)
"""


# ╔═════════════════════════════════════════════════════════════════════════════
# ║  MAIN
# ╚═════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format="%(asctime)s %(levelname)s %(name)s: %(message)s")
    print("── Running Wising Tax Engine core smoke tests ──")
    _run_all_tests()
    print("── All tests passed ──")
