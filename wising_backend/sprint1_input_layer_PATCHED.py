"""
WISING TAX ENGINE — SPRINT 1: INPUT LAYER & DYNAMIC RESIDENCY LOCK
═══════════════════════════════════════════════════════════════════
Document: WISING-IMPL-001 Sprint 1
Architecture: WISING-ARCH-005 v2.0

This module implements:
  1. Core type system (all data models)
  2. Layer 0 Jurisdiction Router (parallel flag architecture)
  3. Layer 1 India Residency Lock (RS-001 — 19 exhaustive paths)
  4. Layer 1 US Residency Lock (SPT — 5-priority cascade)
  5. State Machine (XState-equivalent) for progressive wizard
  6. Reactive re-evaluation on upstream changes
  7. Partial save / incremental state support
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass, field, asdict
from datetime import date, datetime
from enum import Enum
from typing import Any, Literal, Optional
from copy import deepcopy


# ═══════════════════════════════════════════════════════════════════
# SECTION 1 — ENUMS & LITERALS
# ═══════════════════════════════════════════════════════════════════

class Jurisdiction(str, Enum):
    INDIA_ONLY = "india_only"
    US_ONLY = "us_only"
    DUAL = "dual"
    NONE = "none"


class IndiaResidency(str, Enum):
    NR = "NR"
    RNOR = "RNOR"
    ROR = "ROR"


class USResidency(str, Enum):
    US_CITIZEN = "US_CITIZEN"
    RESIDENT_ALIEN = "RESIDENT_ALIEN"
    NON_RESIDENT_ALIEN = "NON_RESIDENT_ALIEN"
    DUAL_STATUS = "DUAL_STATUS"


class EmploymentCrewStatus(str, Enum):
    EMPLOYED_ABROAD = "employed_abroad"
    INDIAN_SHIP_CREW = "indian_ship_crew"
    FOREIGN_SHIP_CREW = "foreign_ship_crew"
    NONE = "none"


class ExemptIndividualStatus(str, Enum):
    NONE = "none"
    F_STUDENT = "f_student"
    J_SCHOLAR = "j_scholar"
    G_DIPLOMAT = "g_diplomat"
    PROFESSIONAL_ATHLETE = "professional_athlete"


class WizardPhase(str, Enum):
    """Top-level state machine states."""
    LAYER0_WIZARD = "layer0_wizard"
    LAYER0_COMPLETE = "layer0_complete"
    INDIA_RESIDENCY = "india_residency"
    US_RESIDENCY = "us_residency"
    INDIA_LOCKED = "india_locked"
    US_LOCKED = "us_locked"
    INCOME_SECTIONS = "income_sections"
    READY_TO_EVALUATE = "ready_to_evaluate"
    JURISDICTION_NONE = "jurisdiction_none"


# ═══════════════════════════════════════════════════════════════════
# SECTION 2 — CORE DATA MODELS
# Direct translation of layer0_residency_v4.jsonc,
# layer1_india_v5_1_final.jsonc (Section 2), layer1_us_v2.jsonc (Section 2)
# ═══════════════════════════════════════════════════════════════════

@dataclass
class Layer0State:
    """
    Exact 1:1 mapping to layer0_residency_v4.jsonc.
    14 fields: 6 REQUIRED, 5 CONDITIONAL, 3 DERIVED.
    """
    # ── India-flag inputs ──
    is_indian_citizen: Optional[bool] = None          # Q1 | REQUIRED
    is_pio_or_oci: Optional[bool] = None              # Q2 | CONDITIONAL: is_indian_citizen=false
    india_days: Optional[int] = None                  # Q3 | REQUIRED (0-366)
    has_india_source_income_or_assets: Optional[bool] = None  # Q4 | REQUIRED

    # ── US-flag inputs ──
    is_us_citizen: Optional[bool] = None              # Q5 | REQUIRED
    has_green_card: Optional[bool] = None             # Q6 | CONDITIONAL: is_us_citizen=false
    was_in_us_this_year: Optional[bool] = None        # Q7 | REQUIRED
    us_days: Optional[int] = None                     # Q7b | CONDITIONAL: was_in_us=true
    has_us_source_income_or_assets: Optional[bool] = None  # Q7c | REQUIRED

    # ── Cross-cutting pass-through ──
    liable_to_tax_in_another_country: Optional[bool] = None   # Q8 | CONDITIONAL: citizen=true
    left_india_for_employment_this_year: Optional[bool] = None  # Q9 | CONDITIONAL: citizen=true

    # ── DERIVED outputs ──
    india_flag: Optional[bool] = None
    us_flag: Optional[bool] = None
    jurisdiction: Optional[Jurisdiction] = None


@dataclass
class IndiaResidencyDetail:
    """
    Exact 1:1 mapping to layer1_india_v5_1_final.jsonc Section 2.
    12 fields: 1 REQUIRED, 8 CONDITIONAL, 1 OPTIONAL, 2 DERIVED.
    """
    # ── User inputs ──
    days_in_india_current_year: Optional[int] = None           # PRE-FILLED from L0
    days_in_india_preceding_4_years_gte_365: Optional[bool] = None  # COND: days 60-181
    employment_or_crew_status: Optional[EmploymentCrewStatus] = None  # COND: complex gate
    is_departure_year: Optional[bool] = None                   # COND: emp != none
    ship_nationality: Optional[str] = None                     # COND: crew status
    came_on_visit_to_india_pio_citizen: Optional[bool] = None  # COND: emp = none
    nr_years_last_10_gte_9: Optional[bool] = None              # COND: days>=182 OR visit=false
    days_in_india_last_7_years_lte_729: Optional[bool] = None  # COND: same gate
    india_source_income_above_15l: Optional[bool] = None       # COND: has_india_source=true
    current_year_trip_log: list = field(default_factory=list)   # OPTIONAL

    # ── DERIVED ──
    liable_to_tax_in_another_country_being_indian_citizen: Optional[bool] = None
    final_india_residency_status: Optional[IndiaResidency] = None


@dataclass
class USResidencyDetail:
    """
    Exact 1:1 mapping to layer1_us_v2.jsonc Section 2.
    16 fields: 7 REQUIRED, 2 CONDITIONAL, 2 OPTIONAL, 5 DERIVED.
    """
    # ── Status flags (pre-filled from L0) ──
    is_us_citizen: Optional[bool] = None
    has_green_card: Optional[bool] = None
    green_card_grant_date: Optional[str] = None       # COND: has_green_card=true
    i407_surrendered_date: Optional[str] = None        # COND: has_green_card=true

    # ── SPT inputs ──
    us_days_current_year: Optional[int] = None         # PRE-FILLED from L0
    us_days_minus_1_year: Optional[int] = None         # REQUIRED
    us_days_minus_2_years: Optional[int] = None        # REQUIRED
    exempt_individual_status: Optional[ExemptIndividualStatus] = None  # REQUIRED

    # ── Elections ──
    closer_connection_claim: Optional[bool] = None     # COND: spt_met AND days<183
    first_year_choice_election: Optional[bool] = None  # OPTIONAL
    s6013g_joint_election: Optional[bool] = None       # OPTIONAL

    # ── DERIVED ──
    spt_day_count_weighted: Optional[float] = None
    spt_test_met: Optional[bool] = None
    final_us_residency_status: Optional[USResidency] = None
    residency_start_date: Optional[str] = None
    residency_end_date: Optional[str] = None


@dataclass
class TaxEngineState:
    """
    Root state object persisted to tax_state_snapshots.
    Mirrors the JSONB columns: layer0_state, layer1_india, layer1_us.
    """
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str = ""
    tax_year_id: str = ""

    layer0: Layer0State = field(default_factory=Layer0State)
    india_residency: Optional[IndiaResidencyDetail] = None
    us_residency: Optional[USResidencyDetail] = None

    # ── Wizard state ──
    wizard_phase: WizardPhase = WizardPhase.LAYER0_WIZARD
    completion_pct: int = 0
    is_approximation: bool = True

    # ── Audit trail ──
    events: list = field(default_factory=list)
    schema_version: str = "v5.1"
    created_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())


# ═══════════════════════════════════════════════════════════════════
# SECTION 3 — LAYER 0: JURISDICTION ROUTER
# Pure function. Zero side effects. Direct translation of the
# parallel flag architecture from layer0_residency_v4.jsonc.
# ═══════════════════════════════════════════════════════════════════

def evaluate_india_flag(s: Layer0State) -> bool:
    """
    india_flag = is_indian_citizen OR is_pio_or_oci
                 OR india_days > 0
                 OR has_india_source_income_or_assets
    """
    return bool(
        s.is_indian_citizen
        or s.is_pio_or_oci
        or (s.india_days is not None and s.india_days > 0)
        or s.has_india_source_income_or_assets
    )


def evaluate_us_flag(s: Layer0State) -> bool:
    """
    us_flag = is_us_citizen OR has_green_card
              OR (was_in_us_this_year AND us_days > 0)
              OR has_us_source_income_or_assets
    """
    return bool(
        s.is_us_citizen
        or s.has_green_card
        or (s.was_in_us_this_year and s.us_days is not None and s.us_days > 0)
        or s.has_us_source_income_or_assets
    )


def evaluate_jurisdiction(s: Layer0State) -> Layer0State:
    """
    Compute both flags and derive jurisdiction.
    Returns a NEW Layer0State with derived fields populated.
    Pure function — does not mutate input.
    """
    result = deepcopy(s)
    result.india_flag = evaluate_india_flag(s)
    result.us_flag = evaluate_us_flag(s)

    if result.india_flag and result.us_flag:
        result.jurisdiction = Jurisdiction.DUAL
    elif result.india_flag and not result.us_flag:
        result.jurisdiction = Jurisdiction.INDIA_ONLY
    elif not result.india_flag and result.us_flag:
        result.jurisdiction = Jurisdiction.US_ONLY
    else:
        result.jurisdiction = Jurisdiction.NONE

    return result


# ═══════════════════════════════════════════════════════════════════
# SECTION 4 — LAYER 1 INDIA: RS-001 RESIDENCY LOCK
# Direct translation of the 19 exhaustive paths from
# layer1_india_v5_1_final.jsonc Section 2 lock derivation cascade.
#
# ABBREVIATIONS (matching the schema comments exactly):
#   DAYS     = days_in_india_current_year
#   P4Y_365  = days_in_india_preceding_4_years_gte_365
#   EMP      = employment_or_crew_status
#   VISIT    = came_on_visit_to_india_pio_citizen
#   NR9      = nr_years_last_10_gte_9
#   D7_729   = days_in_india_last_7_years_lte_729
#   INC_15L  = india_source_income_above_15l
#   LTAC     = liable_to_tax_in_another_country_being_indian_citizen
# ═══════════════════════════════════════════════════════════════════

@dataclass
class RS001Result:
    """Output of the RS-001 engine. Includes the path ID for audit."""
    status: IndiaResidency
    path_id: str        # e.g. "ROR-1", "RNOR-4", "NR-7"
    statutory_basis: str


def compute_ltac(is_indian_citizen: Optional[bool],
                 liable_to_tax: Optional[bool]) -> bool:
    """
    DERIVED composite boolean.
    TRUE only when BOTH citizen=true AND liable=true.
    Truth table from schema:
      citizen=true  + liable=true  → TRUE
      citizen=false + liable=true  → FALSE
      citizen=true  + liable=false → FALSE
      citizen=false + liable=false → FALSE
    """
    return bool(is_indian_citizen) and bool(liable_to_tax)


def evaluate_india_residency(
    l0: Layer0State,
    r: IndiaResidencyDetail
) -> RS001Result:
    """
    RS-001 Engine: 19 exhaustive paths (2 ROR + 9 RNOR + 8 NR).

    Implementation follows Engine Implementation Notes 1-7 exactly:
      1. Evaluate top-down: DAYS >= 182 first
      2. Within 60-181, fork on P4Y_365 first
      3. Then fork on EMP → VISIT → Condition A/B
      4. Deemed Resident paths always RNOR per s.6(6)(d)
      5. Non-citizens never enter Deemed Resident paths
      6. Null/hidden fields treated as "none"/false
    """
    DAYS = r.days_in_india_current_year or 0
    P4Y_365 = bool(r.days_in_india_preceding_4_years_gte_365)
    EMP = r.employment_or_crew_status or EmploymentCrewStatus.NONE
    VISIT = bool(r.came_on_visit_to_india_pio_citizen)
    NR9 = bool(r.nr_years_last_10_gte_9)
    D7_729 = bool(r.days_in_india_last_7_years_lte_729)
    INC_15L = bool(r.india_source_income_above_15l)
    CITIZEN = bool(l0.is_indian_citizen)

    # Compute LTAC from Layer 0 pre-fills
    LTAC = compute_ltac(l0.is_indian_citizen, l0.liable_to_tax_in_another_country)

    # ─── BRANCH 1: 182-day universal rule ───────────────────────────
    if DAYS >= 182:
        # Check RNOR Condition A or B
        if NR9:
            return RS001Result(IndiaResidency.RNOR, "RNOR-1",
                               "Condition A via 182-day — s.6(6)(a)")
        if D7_729:
            return RS001Result(IndiaResidency.RNOR, "RNOR-2",
                               "Condition B via 182-day — s.6(6)(a)")
        # Neither Condition A nor B met → ROR
        return RS001Result(IndiaResidency.ROR, "ROR-1",
                           "182+ days, Condition A/B not met")

    # ─── BRANCH 2: 60-day secondary path ────────────────────────────
    if 60 <= DAYS < 182:
        if not P4Y_365:
            # 60-day path does not trigger residency.
            # Check Deemed Resident only.
            if INC_15L and CITIZEN and not LTAC:
                return RS001Result(IndiaResidency.RNOR, "RNOR-8",
                                   "Deemed Resident — 60-day path fails, "
                                   "preceding 4yr < 365 — s.6(1A)+s.6(6)(d)")
            if INC_15L and LTAC:
                return RS001Result(IndiaResidency.NR, "NR-3",
                                   "60-day path fails + Deemed Resident blocked")
            return RS001Result(IndiaResidency.NR, "NR-4",
                               "60-day path fails + no Deemed Resident (income ≤15L)")

        # P4Y_365 = true → fork on EMP
        if EMP != EmploymentCrewStatus.NONE:
            # ── Employment / crew departure path ──
            if INC_15L and CITIZEN and not LTAC:
                return RS001Result(IndiaResidency.RNOR, "RNOR-3",
                                   "Employment departure + Deemed Resident — "
                                   "s.6(1A)+s.6(6)(d)")
            if INC_15L and LTAC:
                return RS001Result(IndiaResidency.NR, "NR-8",
                                   "Employment departure + Deemed blocked")
            return RS001Result(IndiaResidency.NR, "NR-7",
                               "Employment departure, income ≤15L")

        # EMP = "none" → fork on VISIT
        if VISIT:
            # ── Visitor path ──
            if DAYS >= 120:
                # Condition C: 120-day visitor with income > 15L
                if INC_15L:
                    return RS001Result(IndiaResidency.RNOR, "RNOR-4",
                                       "Visitor 120-day — Condition C — s.6(6)(c)")
                return RS001Result(IndiaResidency.NR, "NR-5",
                                   "Visitor 120-day path: income ≤15L")
            else:
                # DAYS < 120 — visitor below Condition C threshold
                if INC_15L and CITIZEN and not LTAC:
                    return RS001Result(IndiaResidency.RNOR, "RNOR-9",
                                       "Visitor < 120 days + Deemed Resident — "
                                       "s.6(1A)+s.6(6)(d)")
                if INC_15L and LTAC:
                    return RS001Result(IndiaResidency.NR, "NR-6",
                                       "Visitor < 120 days + Deemed blocked")
                # Income ≤ 15L, below 120 days, visitor
                return RS001Result(IndiaResidency.NR, "NR-4",
                                   "Visitor < 120 days, income ≤15L")

        # VISIT = false → standard 60-day path → check Condition A/B
        if NR9:
            return RS001Result(IndiaResidency.RNOR, "RNOR-5",
                               "Non-visitor Condition A via 60-day")
        if D7_729:
            return RS001Result(IndiaResidency.RNOR, "RNOR-6",
                               "Non-visitor Condition B via 60-day")
        # Neither A nor B met → ROR
        return RS001Result(IndiaResidency.ROR, "ROR-2",
                           "60-day path, Condition A/B not met")

    # ─── BRANCH 3: Below 60 days ────────────────────────────────────
    # Only Deemed Resident check applies here
    if INC_15L and CITIZEN and not LTAC:
        return RS001Result(IndiaResidency.RNOR, "RNOR-7",
                           "Deemed Resident below 60 days — s.6(1A)+s.6(6)(d)")
    if INC_15L and LTAC:
        return RS001Result(IndiaResidency.NR, "NR-1",
                           "Deemed Resident blocked — citizen liable elsewhere")
    return RS001Result(IndiaResidency.NR, "NR-2",
                       "No income threshold met; no path to residency")


# ═══════════════════════════════════════════════════════════════════
# SECTION 5 — LAYER 1 US: SPT RESIDENCY LOCK
# Direct translation of layer1_us_v2.jsonc Section 2 cascade.
# ═══════════════════════════════════════════════════════════════════

@dataclass
class SPTResult:
    """Output of the SPT engine."""
    status: USResidency
    priority: int       # 1-5 per the cascade
    spt_weighted: Optional[float] = None
    spt_met: Optional[bool] = None


def evaluate_us_residency(r: USResidencyDetail) -> SPTResult:
    """
    SPT Engine: 5-priority cascade from layer1_us_v2.jsonc.
      1. is_us_citizen = true → US_CITIZEN
      2. has_green_card = true AND no I-407 this year → RESIDENT_ALIEN
      3. SPT met AND ¬closer_connection → RESIDENT_ALIEN
      4. Mid-year GC / first-year choice / expatriation → DUAL_STATUS
      5. Otherwise → NON_RESIDENT_ALIEN
    """
    # Priority 1: US citizenship
    if r.is_us_citizen:
        return SPTResult(USResidency.US_CITIZEN, 1)

    # Priority 2: Green Card (unsurrendered)
    if r.has_green_card and not r.i407_surrendered_date:
        return SPTResult(USResidency.RESIDENT_ALIEN, 2)

    # Compute SPT weighted count
    cy_days = r.us_days_current_year or 0
    py1_days = r.us_days_minus_1_year or 0
    py2_days = r.us_days_minus_2_years or 0

    # Exempt individuals: their days do not count
    if r.exempt_individual_status and r.exempt_individual_status != ExemptIndividualStatus.NONE:
        cy_days = 0  # Simplified: full exemption for exempt status

    weighted = cy_days + (py1_days / 3) + (py2_days / 6)
    spt_met = cy_days >= 31 and weighted >= 183

    # Priority 3: SPT met
    if spt_met and not r.closer_connection_claim:
        return SPTResult(USResidency.RESIDENT_ALIEN, 3, weighted, True)

    # Priority 4: Dual-status (mid-year events)
    if r.first_year_choice_election:
        return SPTResult(USResidency.DUAL_STATUS, 4, weighted, spt_met)
    if r.has_green_card and r.i407_surrendered_date:
        # Surrendered mid-year → dual-status
        return SPTResult(USResidency.DUAL_STATUS, 4, weighted, spt_met)

    # Priority 5: Non-resident alien
    return SPTResult(USResidency.NON_RESIDENT_ALIEN, 5, weighted, spt_met)


# ═══════════════════════════════════════════════════════════════════
# SECTION 6 — STATE MACHINE (XState-equivalent in Python)
# Governs wizard progression with reactive re-evaluation.
# ═══════════════════════════════════════════════════════════════════

@dataclass
class StateTransition:
    """Audit log entry for every state change."""
    from_phase: WizardPhase
    to_phase: WizardPhase
    trigger: str           # e.g. "LAYER0_SUBMIT", "INDIA_LOCK_REFIRE"
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    payload: dict = field(default_factory=dict)


class WizardStateMachine:
    """
    Progressive disclosure wizard.

    State flow:
      LAYER0_WIZARD ──[submit]──→ LAYER0_COMPLETE
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
            INDIA_RESIDENCY   US_RESIDENCY   JURISDICTION_NONE
                    │               │
                    ▼               ▼
             INDIA_LOCKED      US_LOCKED
                    │               │
                    └───────┬───────┘
                            ▼
                    INCOME_SECTIONS
                            │
                            ▼
                   READY_TO_EVALUATE

    Any upstream change (e.g., india_days) triggers reactive
    re-evaluation of the router and locks.
    """

    def __init__(self, state: TaxEngineState):
        self.state = state
        self.transitions: list[StateTransition] = []

    def _transition(self, to: WizardPhase, trigger: str,
                    payload: dict | None = None):
        """Record transition and update phase."""
        t = StateTransition(
            from_phase=self.state.wizard_phase,
            to_phase=to,
            trigger=trigger,
            payload=payload or {}
        )
        self.transitions.append(t)
        self.state.events.append(asdict(t))
        self.state.wizard_phase = to
        self.state.updated_at = datetime.utcnow().isoformat()

    # ── Layer 0 operations ──────────────────────────────────────────

    def patch_layer0(self, updates: dict[str, Any]) -> Layer0State:
        """
        Apply partial updates to Layer 0 fields.
        Reactively re-evaluates jurisdiction.
        Supports incremental state — only patch what changed.
        """
        l0 = self.state.layer0
        for key, value in updates.items():
            if hasattr(l0, key):
                setattr(l0, key, value)

        # Re-evaluate jurisdiction on every Layer 0 change
        self.state.layer0 = evaluate_jurisdiction(l0)
        return self.state.layer0

    def submit_layer0(self) -> Jurisdiction:
        """
        Finalize Layer 0 and transition to next phase.
        Returns the jurisdiction for frontend routing.
        """
        l0 = evaluate_jurisdiction(self.state.layer0)
        self.state.layer0 = l0

        self._transition(WizardPhase.LAYER0_COMPLETE, "LAYER0_SUBMIT",
                         {"jurisdiction": l0.jurisdiction.value if l0.jurisdiction else "none"})

        j = l0.jurisdiction
        if j == Jurisdiction.NONE:
            self._transition(WizardPhase.JURISDICTION_NONE, "JURISDICTION_NONE_REACHED")
        elif j in (Jurisdiction.INDIA_ONLY, Jurisdiction.DUAL):
            # Initialize India residency detail with pre-fills
            self.state.india_residency = IndiaResidencyDetail(
                days_in_india_current_year=l0.india_days
            )
            self._transition(WizardPhase.INDIA_RESIDENCY, "INDIA_RESIDENCY_STARTED")
        elif j == Jurisdiction.US_ONLY:
            self.state.us_residency = USResidencyDetail(
                is_us_citizen=l0.is_us_citizen,
                has_green_card=l0.has_green_card,
                us_days_current_year=l0.us_days
            )
            self._transition(WizardPhase.US_RESIDENCY, "US_RESIDENCY_STARTED")

        return j

    # ── India residency lock ────────────────────────────────────────

    def patch_india_residency(self, updates: dict[str, Any]) -> IndiaResidencyDetail:
        """
        Apply partial updates to India residency fields.
        Does NOT auto-fire lock — lock fires on explicit submit
        or reactive re-evaluation.
        """
        r = self.state.india_residency
        if r is None:
            raise ValueError("India residency not initialized (jurisdiction does not include India)")

        for key, value in updates.items():
            if hasattr(r, key):
                setattr(r, key, value)

        return r

    def fire_india_lock(self) -> RS001Result:
        """
        Compute India residency lock (RS-001).
        Stores result and transitions wizard phase.
        """
        r = self.state.india_residency
        if r is None:
            raise ValueError("India residency not initialized")

        # Compute LTAC derived field
        r.liable_to_tax_in_another_country_being_indian_citizen = compute_ltac(
            self.state.layer0.is_indian_citizen,
            self.state.layer0.liable_to_tax_in_another_country
        )

        # Run RS-001
        result = evaluate_india_residency(self.state.layer0, r)
        r.final_india_residency_status = result.status

        old_phase = self.state.wizard_phase
        self._transition(WizardPhase.INDIA_LOCKED, "INDIA_LOCK_SET",
                         {"status": result.status.value,
                          "path_id": result.path_id,
                          "statutory_basis": result.statutory_basis})

        # If dual jurisdiction, start US residency next
        if self.state.layer0.jurisdiction == Jurisdiction.DUAL:
            self.state.us_residency = USResidencyDetail(
                is_us_citizen=self.state.layer0.is_us_citizen,
                has_green_card=self.state.layer0.has_green_card,
                us_days_current_year=self.state.layer0.us_days
            )
            self._transition(WizardPhase.US_RESIDENCY, "US_RESIDENCY_STARTED_DUAL")
        elif self.state.layer0.jurisdiction == Jurisdiction.INDIA_ONLY:
            # No US lock needed — advance directly to income sections
            self._transition(WizardPhase.INCOME_SECTIONS, "INDIA_ONLY_LOCK_COMPLETE")

        return result

    # ── US residency lock ───────────────────────────────────────────

    def patch_us_residency(self, updates: dict[str, Any]) -> USResidencyDetail:
        """Apply partial updates to US residency fields."""
        r = self.state.us_residency
        if r is None:
            raise ValueError("US residency not initialized")

        for key, value in updates.items():
            if hasattr(r, key):
                setattr(r, key, value)

        return r

    def fire_us_lock(self) -> SPTResult:
        """Compute US residency lock (SPT)."""
        r = self.state.us_residency
        if r is None:
            raise ValueError("US residency not initialized")

        result = evaluate_us_residency(r)
        r.spt_day_count_weighted = result.spt_weighted
        r.spt_test_met = result.spt_met
        r.final_us_residency_status = result.status

        self._transition(WizardPhase.US_LOCKED, "US_LOCK_SET",
                         {"status": result.status.value,
                          "priority": result.priority})

        # Both locks set → advance to income sections
        if (self.state.india_residency
                and self.state.india_residency.final_india_residency_status):
            self._transition(WizardPhase.INCOME_SECTIONS, "BOTH_LOCKS_SET")
        elif self.state.layer0.jurisdiction == Jurisdiction.US_ONLY:
            self._transition(WizardPhase.INCOME_SECTIONS, "US_LOCK_ONLY")

        return result

    # ── Reactive re-evaluation ──────────────────────────────────────

    def refire_on_upstream_change(self, layer0_updates: dict[str, Any]) -> dict:
        """
        Called when user changes an upstream field (e.g., india_days).
        Reactively re-evaluates:
          1. Layer 0 jurisdiction
          2. India lock (if applicable)
          3. US lock (if applicable)

        Returns a diff of what changed for the frontend to update.
        """
        old_jurisdiction = self.state.layer0.jurisdiction
        old_india_lock = (self.state.india_residency.final_india_residency_status
                          if self.state.india_residency else None)
        old_us_lock = (self.state.us_residency.final_us_residency_status
                       if self.state.us_residency else None)

        # Step 1: Re-evaluate Layer 0
        self.patch_layer0(layer0_updates)
        new_l0 = self.state.layer0
        new_jurisdiction = new_l0.jurisdiction

        diff = {}

        # Step 2: Check jurisdiction change
        if new_jurisdiction != old_jurisdiction:
            diff["jurisdiction_changed"] = {
                "from": old_jurisdiction.value if old_jurisdiction else None,
                "to": new_jurisdiction.value if new_jurisdiction else None
            }
            self._transition(WizardPhase.LAYER0_COMPLETE,
                             "JURISDICTION_REFIRE",
                             diff["jurisdiction_changed"])

        # Step 3: Re-fire India lock if india_days changed
        if (self.state.india_residency
                and "india_days" in layer0_updates):
            self.state.india_residency.days_in_india_current_year = new_l0.india_days
            result = evaluate_india_residency(new_l0, self.state.india_residency)
            self.state.india_residency.final_india_residency_status = result.status

            if result.status != old_india_lock:
                diff["india_lock_changed"] = {
                    "from": old_india_lock.value if old_india_lock else None,
                    "to": result.status.value,
                    "path_id": result.path_id
                }
                self._transition(self.state.wizard_phase,
                                 "INDIA_LOCK_REFIRE", diff["india_lock_changed"])

        # Step 4: Re-fire US lock if us_days changed
        if (self.state.us_residency
                and "us_days" in layer0_updates):
            self.state.us_residency.us_days_current_year = new_l0.us_days
            result = evaluate_us_residency(self.state.us_residency)
            self.state.us_residency.final_us_residency_status = result.status

            if result.status != old_us_lock:
                diff["us_lock_changed"] = {
                    "from": old_us_lock.value if old_us_lock else None,
                    "to": result.status.value
                }

        return diff

    # ── Section visibility (downstream gate evaluation) ─────────────

    def get_visible_sections(self) -> dict[str, bool]:
        """
        Evaluate which Layer 1 sections are visible based on
        the residency locks. Direct translation of the unlock
        logic from the schema header comments.
        """
        india_lock = (self.state.india_residency.final_india_residency_status
                      if self.state.india_residency else None)
        us_lock = (self.state.us_residency.final_us_residency_status
                   if self.state.us_residency else None)

        sections = {}

        # ── India sections (from layer1_india header) ──
        if india_lock:
            sections["india_profile"] = True                        # Screen 2A: always
            sections["india_dtaa"] = india_lock == IndiaResidency.NR  # Screen 2B
            sections["india_compliance_docs"] = india_lock == IndiaResidency.NR  # Screen 2C
            sections["india_bank_accounts"] = True                  # Screen 2D: all locks
            sections["india_property"] = True                       # Screen 2E: gated by has_*
            sections["india_financial_holdings"] = True              # Screen 2F: always
            sections["india_commodities"] = True                    # Screen 2G: always
            sections["india_unlisted_equity"] = True                # Screen 2H: always
            sections["india_share_buyback"] = True                  # Screen 2I: always
            sections["india_domestic_income"] = True                # Screen 2J: always
            sections["india_other_sources"] = True                  # Screen 2K: always
            sections["india_deductions"] = india_lock in (           # Screen 2L
                IndiaResidency.RNOR, IndiaResidency.ROR)
            sections["india_carry_forward_losses"] = True           # Screen 2M: always
            sections["india_lrs_outbound"] = india_lock == IndiaResidency.ROR  # Screen 2N
            sections["india_tax_credits"] = True                    # Screen 2O: always

        # ── US sections (from layer1_us header) ──
        if us_lock:
            sections["us_profile"] = True                           # Screen 3A: always
            sections["us_state_residency"] = True                   # Screen 3B: always
            sections["us_income_us_source"] = True                  # Screen 3C: always
            sections["us_income_foreign_source"] = us_lock in (      # Screen 3D
                USResidency.US_CITIZEN, USResidency.RESIDENT_ALIEN,
                USResidency.DUAL_STATUS)
            sections["us_equity_compensation"] = True               # Screen 3E: gated by has_*
            sections["us_feie"] = us_lock in (                       # Screen 3F
                USResidency.US_CITIZEN, USResidency.RESIDENT_ALIEN)
            sections["us_bank_accounts"] = True                     # Screen 3G: always
            sections["us_financial_holdings"] = True                # Screen 3H: always
            sections["us_real_estate"] = True                       # Screen 3I: gated
            sections["us_retirement_accounts"] = True               # Screen 3J: gated
            sections["us_foreign_entities"] = True                  # Screen 3K: gated
            sections["us_foreign_gifts"] = True                     # Screen 3L: gated
            sections["us_deductions_credits"] = True                # Screen 3M: always
            sections["us_amt"] = True                               # Screen 3N: derived
            sections["us_niit"] = True                              # Screen 3O: derived
            sections["us_ftc"] = True                               # Screen 3P: gated
            sections["us_withholding"] = True                       # Screen 3Q: always
            sections["us_nra_specific"] = us_lock == USResidency.NON_RESIDENT_ALIEN  # 3R

        return sections


# ═══════════════════════════════════════════════════════════════════
# SECTION 7 — ENABLED-IF GATE EVALUATOR
# Evaluates field-level visibility from the field_registry.
# Used by both frontend (local) and backend (validation).
# ═══════════════════════════════════════════════════════════════════

def evaluate_gate(gate_json: dict | None, context: dict) -> bool:
    """
    Evaluate an ENABLED IF gate expression against context.

    Supported gate formats (field_registry.enabled_if JSONB):
      {"field": "path", "op": "eq",       "value": <scalar|[]>}
      {"field": "path", "op": "neq",      "value": <scalar>}
      {"field": "path", "op": "gt",       "value": <number>}
      {"field": "path", "op": "gte",      "value": <number>}
      {"field": "path", "op": "lt",       "value": <number>}
      {"field": "path", "op": "in",       "value": [<scalars>]}   # actual IN list
      {"field": "path", "op": "contains", "value": <scalar>}      # list CONTAINS value
      {"and": [...conditions...]}
      {"or":  [...conditions...]}

    Operator semantics:
      eq         : actual == expected  (handles [] == [] for empty-array check,
                   i.e. `presumptive_scheme = []` gates)
      neq        : actual != expected
      gt         : actual > expected   (numeric only; None → False)
      gte        : actual >= expected  (numeric only; None → False)
      lt         : actual < expected   (numeric only; None → False)
      in         : actual is one of the expected list   ("lock IN [...]")
      contains   : actual list contains the expected scalar
                   Used for: `"s44AD" IN presumptive_scheme`,
                              `"professional" IN nature_of_business`

    GAP-003 FIX: `contains` operator added for v5.1 array-enum gates.
    GAP-004 FIX: `eq` now correctly handles `value: []` (empty array check).
    """
    if gate_json is None:
        return True  # No gate = always visible

    if "and" in gate_json:
        return all(evaluate_gate(c, context) for c in gate_json["and"])

    if "or" in gate_json:
        return any(evaluate_gate(c, context) for c in gate_json["or"])

    # ── Single condition ──────────────────────────────────────────────
    field_path = gate_json.get("field", "")
    op         = gate_json.get("op", "eq")
    expected   = gate_json.get("value")

    # Resolve field value from context using dotted path.
    # Supports: "layer0.india_days", "layer1_india.residency_detail.days_..."
    # Also handles array-path notation like "parent[].field" — skipped
    # (template fields are not evaluated against context directly).
    actual = context
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
        # Used for: `"s44AD" IN presumptive_scheme` gates in v5.1.
        if isinstance(actual, list):
            return expected in actual
        return False

    return False


# ═══════════════════════════════════════════════════════════════════
# SECTION 8 — COMPLETION PERCENTAGE ENGINE
# Formula: filled_relevant_required / total_relevant_required × 100
# No weighting. No probabilistic scoring.
# ═══════════════════════════════════════════════════════════════════

def compute_completion_pct(
    state: TaxEngineState,
    field_registry: list[dict]
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
      list (GAP-005 fix: empty [] for a required array means the user
      has not provided any items — it is NOT filled).

    Args:
        state: Current engine state
        field_registry: List of field_registry rows with
                       field_path, classification, enabled_if, section

    Returns:
        (percentage: int, detail: dict with per-section breakdown)
    """
    context = {
        "layer0": asdict(state.layer0),
        "layer1_india": asdict(state.india_residency) if state.india_residency else {},
        "layer1_us": asdict(state.us_residency) if state.us_residency else {},
    }

    total_required = 0
    filled_required = 0
    section_detail = {}

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
            value = context
            for part in field_path.split("."):
                # Strip array template notation
                part = part.rstrip("[]").rstrip("][")
                if isinstance(value, dict):
                    value = value.get(part)
                else:
                    value = None
                    break

            # GAP-005 FIX: An empty list [] is NOT "filled".
            # For array-type required fields (e.g. goods_vehicles),
            # the user must provide at least one item.
            is_filled = (value is not None
                         and not (isinstance(value, list) and len(value) == 0))

            if is_filled:
                filled_required += 1

            # Per-section tracking
            section = field_def.get("section", "unknown")
            if section not in section_detail:
                section_detail[section] = {"total": 0, "filled": 0,
                                            "missing": []}
            section_detail[section]["total"] += 1
            if is_filled:
                section_detail[section]["filled"] += 1
            else:
                section_detail[section]["missing"].append(field_path)

    pct = round((filled_required / total_required * 100) if total_required > 0 else 0)
    return pct, section_detail
