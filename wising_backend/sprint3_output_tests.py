"""
WISING TAX ENGINE — SPRINT 3: OUTPUT LAYER & TESTING
═══════════════════════════════════════════════════════════════════
Document: WISING-IMPL-001 Sprint 3

This module implements:
  1. APPROXIMATION vs FINAL output stamping
  2. assumptions_used array — NO SILENT DEFAULTS
  3. Output payload formatting
  4. Complete test suite (27 test cases)
"""
from __future__ import annotations

import json
from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import Optional

from sprint1_input_layer import (
    Layer0State, IndiaResidencyDetail, USResidencyDetail,
    TaxEngineState, WizardStateMachine,
    Jurisdiction, IndiaResidency, USResidency,
    EmploymentCrewStatus, ExemptIndividualStatus,
    evaluate_india_residency, evaluate_us_residency,
    evaluate_jurisdiction, compute_ltac,
)
from sprint2_math_dag import (
    IndiaIncomeAssembly, USIncomeAssembly,
    IndiaTaxResult, USTaxResult,
    run_india_dag, run_us_dag, evaluate_tax,
    Assumption, FullComputationResult,
    compute_slab_tax, INDIA_NEW_REGIME_SLABS_FY2025,
)


# ═══════════════════════════════════════════════════════════════════
# SECTION 1 — OUTPUT PAYLOAD
# Strict APPROXIMATION vs FINAL stamping.
# Below 100% completion → APPROXIMATION badge.
# At 100% → FINAL badge + filing outputs enabled.
# ═══════════════════════════════════════════════════════════════════

class OutputBadge:
    APPROXIMATION = "APPROXIMATION"
    FINAL = "FINAL"


@dataclass
class TaxOutputPayload:
    """
    The user-facing output. Contains computed results,
    badge status, and every assumption the engine made.
    """
    # ── Badge ──
    badge: str = OutputBadge.APPROXIMATION
    completion_pct: int = 0

    # ── Results ──
    india_result: Optional[dict] = None
    us_result: Optional[dict] = None

    # ── Assumptions (NO SILENT DEFAULTS) ──
    assumptions_used: list[dict] = field(default_factory=list)

    # ── Metadata ──
    jurisdiction: Optional[str] = None
    india_lock: Optional[str] = None
    us_lock: Optional[str] = None
    computed_at: str = ""
    schema_version: str = "v5.1"

    # ── Alerts & flags ──
    alerts: list[dict] = field(default_factory=list)


def stamp_output(
    computation: FullComputationResult,
    state: TaxEngineState,
    completion_pct: int,
) -> TaxOutputPayload:
    """
    Stamp the computation output with APPROXIMATION or FINAL badge.

    Rules:
      - completion_pct < 100 → APPROXIMATION
      - completion_pct == 100 → FINAL
      - Every assumption from both DAGs is surfaced
      - Filing outputs (ITR XML, 1040 PDF) only enabled on FINAL
    """
    badge = OutputBadge.FINAL if completion_pct >= 100 else OutputBadge.APPROXIMATION

    # Collect all assumptions
    assumptions = list(computation.all_assumptions)

    # Add implicit assumptions based on state
    if state.india_residency:
        r = state.india_residency
        if r.final_india_residency_status and not r.current_year_trip_log:
            assumptions.append({
                "field_path": "residency_detail.current_year_trip_log",
                "assumed_value": "empty",
                "reason": "Trip log not provided — day count from Layer 0 "
                          "manual entry used as authoritative",
                "user_overridable": True,
            })

    # Build alerts
    alerts = []
    if badge == OutputBadge.APPROXIMATION:
        alerts.append({
            "type": "APPROXIMATION_WARNING",
            "message": f"Tax estimate is approximate ({completion_pct}% complete). "
                       f"Fill all required fields for a final computation.",
        })

    india_lock = None
    us_lock = None
    if state.india_residency and state.india_residency.final_india_residency_status:
        india_lock = state.india_residency.final_india_residency_status.value
    if state.us_residency and state.us_residency.final_us_residency_status:
        us_lock = state.us_residency.final_us_residency_status.value

    return TaxOutputPayload(
        badge=badge,
        completion_pct=completion_pct,
        india_result=asdict(computation.india_result) if computation.india_result else None,
        us_result=asdict(computation.us_result) if computation.us_result else None,
        assumptions_used=assumptions,
        jurisdiction=state.layer0.jurisdiction.value if state.layer0.jurisdiction else None,
        india_lock=india_lock,
        us_lock=us_lock,
        computed_at=computation.computed_at,
        alerts=alerts,
    )


# ═══════════════════════════════════════════════════════════════════
# SECTION 2 — COMPLETE TEST SUITE
# 27 tests covering:
#   - Layer 0 routing (6 tests)
#   - India RS-001 lock (10 tests — key paths from 19)
#   - US SPT lock (4 tests)
#   - India DAG determinism (3 tests)
#   - US DAG determinism (2 tests)
#   - Output stamping (2 tests)
# ═══════════════════════════════════════════════════════════════════

class TestRunner:
    """Minimal test runner — no external dependencies."""

    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.errors: list[str] = []

    def assert_eq(self, actual, expected, test_name: str):
        if actual == expected:
            self.passed += 1
            print(f"  ✓ {test_name}")
        else:
            self.failed += 1
            msg = f"  ✗ {test_name}: expected {expected}, got {actual}"
            self.errors.append(msg)
            print(msg)

    def assert_true(self, condition, test_name: str):
        self.assert_eq(condition, True, test_name)

    def assert_gt(self, actual, threshold, test_name: str):
        if actual > threshold:
            self.passed += 1
            print(f"  ✓ {test_name}")
        else:
            self.failed += 1
            msg = f"  ✗ {test_name}: expected > {threshold}, got {actual}"
            self.errors.append(msg)
            print(msg)

    def summary(self):
        total = self.passed + self.failed
        print(f"\n{'='*60}")
        print(f"Results: {self.passed}/{total} passed, {self.failed} failed")
        if self.errors:
            print("\nFailed tests:")
            for e in self.errors:
                print(f"  {e}")
        print(f"{'='*60}")
        return self.failed == 0


def run_all_tests() -> bool:
    t = TestRunner()

    # ═══════════════════════════════════════════════════════════════
    # GROUP 1: LAYER 0 ROUTING (6 tests)
    # ═══════════════════════════════════════════════════════════════
    print("\n── Layer 0: Jurisdiction Routing ──")

    # T-L0-1: Indian citizen with US income → dual
    l0 = Layer0State(is_indian_citizen=True, india_days=200,
                     has_india_source_income_or_assets=True,
                     is_us_citizen=False, was_in_us_this_year=True,
                     us_days=120, has_us_source_income_or_assets=True)
    r = evaluate_jurisdiction(l0)
    t.assert_eq(r.jurisdiction, Jurisdiction.DUAL, "T-L0-1: Indian citizen + US income → dual")

    # T-L0-2: Indian citizen, no US → india_only
    l0 = Layer0State(is_indian_citizen=True, india_days=200,
                     has_india_source_income_or_assets=True,
                     is_us_citizen=False, was_in_us_this_year=False,
                     has_us_source_income_or_assets=False)
    r = evaluate_jurisdiction(l0)
    t.assert_eq(r.jurisdiction, Jurisdiction.INDIA_ONLY, "T-L0-2: India only")

    # T-L0-3: US citizen, no India → us_only
    l0 = Layer0State(is_indian_citizen=False, india_days=0,
                     has_india_source_income_or_assets=False,
                     is_us_citizen=True, was_in_us_this_year=True, us_days=300,
                     has_us_source_income_or_assets=True)
    r = evaluate_jurisdiction(l0)
    t.assert_eq(r.jurisdiction, Jurisdiction.US_ONLY, "T-L0-3: US only")

    # T-L0-4: No exposure → none
    l0 = Layer0State(is_indian_citizen=False, india_days=0,
                     has_india_source_income_or_assets=False,
                     is_us_citizen=False, was_in_us_this_year=False,
                     has_us_source_income_or_assets=False)
    r = evaluate_jurisdiction(l0)
    t.assert_eq(r.jurisdiction, Jurisdiction.NONE, "T-L0-4: None")

    # T-L0-5: PIO with India assets → india_flag true
    l0 = Layer0State(is_indian_citizen=False, is_pio_or_oci=True,
                     india_days=0, has_india_source_income_or_assets=True,
                     is_us_citizen=False, was_in_us_this_year=False,
                     has_us_source_income_or_assets=False)
    r = evaluate_jurisdiction(l0)
    t.assert_true(r.india_flag, "T-L0-5: PIO sets india_flag")
    t.assert_eq(r.jurisdiction, Jurisdiction.INDIA_ONLY, "T-L0-5: PIO → india_only")

    # T-L0-6: Green Card holder → us_flag true
    l0 = Layer0State(is_indian_citizen=False, india_days=0,
                     has_india_source_income_or_assets=False,
                     is_us_citizen=False, has_green_card=True,
                     was_in_us_this_year=True, us_days=10,
                     has_us_source_income_or_assets=False)
    r = evaluate_jurisdiction(l0)
    t.assert_true(r.us_flag, "T-L0-6: Green Card sets us_flag")

    # ═══════════════════════════════════════════════════════════════
    # GROUP 2: INDIA RS-001 RESIDENCY LOCK (10 tests)
    # Tests from RS-001 v6 Section 11 test cases
    # ═══════════════════════════════════════════════════════════════
    print("\n── India RS-001: Residency Lock ──")

    # T-RS-01: Standard long-term resident (280 days) → ROR-1
    l0 = Layer0State(is_indian_citizen=True)
    rd = IndiaResidencyDetail(days_in_india_current_year=280,
                              nr_years_last_10_gte_9=False,
                              days_in_india_last_7_years_lte_729=False)
    res = evaluate_india_residency(l0, rd)
    t.assert_eq(res.status, IndiaResidency.ROR, "T-RS-01: 280 days → ROR")
    t.assert_eq(res.path_id, "ROR-1", "T-RS-01: path = ROR-1")

    # T-RS-02: 182+ days + Condition A (NR 9/10) → RNOR-1
    rd = IndiaResidencyDetail(days_in_india_current_year=200,
                              nr_years_last_10_gte_9=True,
                              days_in_india_last_7_years_lte_729=False)
    res = evaluate_india_residency(l0, rd)
    t.assert_eq(res.status, IndiaResidency.RNOR, "T-RS-02: 200d + NR9 → RNOR")
    t.assert_eq(res.path_id, "RNOR-1", "T-RS-02: path = RNOR-1")

    # T-RS-03: NRI leaving for employment, 45 days → NR-7
    l0_emp = Layer0State(is_indian_citizen=True,
                         left_india_for_employment_this_year=True)
    rd = IndiaResidencyDetail(
        days_in_india_current_year=90,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.EMPLOYED_ABROAD,
        india_source_income_above_15l=False)
    res = evaluate_india_residency(l0_emp, rd)
    t.assert_eq(res.status, IndiaResidency.NR, "T-RS-03: Employment departure, <15L → NR")
    t.assert_eq(res.path_id, "NR-7", "T-RS-03: path = NR-7")

    # T-RS-04: PIO visitor 130 days, income 20L → RNOR-4 (Condition C)
    l0_pio = Layer0State(is_indian_citizen=False, is_pio_or_oci=True,
                         has_india_source_income_or_assets=True)
    rd = IndiaResidencyDetail(
        days_in_india_current_year=130,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.NONE,
        came_on_visit_to_india_pio_citizen=True,
        india_source_income_above_15l=True)
    res = evaluate_india_residency(l0_pio, rd)
    t.assert_eq(res.status, IndiaResidency.RNOR, "T-RS-04: PIO 130d + 20L → RNOR")
    t.assert_eq(res.path_id, "RNOR-4", "T-RS-04: path = RNOR-4 (Condition C)")

    # T-RS-05: Dubai NRI, 0 days, income 20L, not liable → RNOR-7 (Deemed Resident)
    l0_dubai = Layer0State(is_indian_citizen=True,
                           liable_to_tax_in_another_country=False,
                           has_india_source_income_or_assets=True)
    rd = IndiaResidencyDetail(days_in_india_current_year=0,
                              india_source_income_above_15l=True)
    res = evaluate_india_residency(l0_dubai, rd)
    t.assert_eq(res.status, IndiaResidency.RNOR, "T-RS-05: Dubai 0d + 20L → RNOR")
    t.assert_eq(res.path_id, "RNOR-7", "T-RS-05: path = RNOR-7 (Deemed Resident)")

    # T-RS-06: Same as T-RS-05 but liable to tax elsewhere → NR-1
    l0_dubai_liable = Layer0State(is_indian_citizen=True,
                                  liable_to_tax_in_another_country=True,
                                  has_india_source_income_or_assets=True)
    rd = IndiaResidencyDetail(days_in_india_current_year=0,
                              india_source_income_above_15l=True)
    res = evaluate_india_residency(l0_dubai_liable, rd)
    t.assert_eq(res.status, IndiaResidency.NR, "T-RS-06: Dubai 0d + 20L + liable → NR")
    t.assert_eq(res.path_id, "NR-1", "T-RS-06: path = NR-1 (Deemed blocked)")

    # T-RS-07: PIO, 0 days, income 20L — NOT citizen → NR-2 (PIO protection)
    # The engine checks citizen=true before Deemed Resident path.
    # LTAC = FALSE for non-citizens, but citizenship gate blocks the path.
    l0_pio_zero = Layer0State(is_indian_citizen=False, is_pio_or_oci=True,
                              has_india_source_income_or_assets=True)
    rd = IndiaResidencyDetail(days_in_india_current_year=0,
                              india_source_income_above_15l=True)
    res = evaluate_india_residency(l0_pio_zero, rd)
    t.assert_eq(res.status, IndiaResidency.NR, "T-RS-07: PIO 0d + 20L → NR (not citizen)")
    t.assert_eq(res.path_id, "NR-2", "T-RS-07: PIO protected from Deemed Resident")

    # T-RS-08: 60 days, preceding <365, income <15L → NR-4
    l0 = Layer0State(is_indian_citizen=True)
    rd = IndiaResidencyDetail(days_in_india_current_year=65,
                              days_in_india_preceding_4_years_gte_365=False,
                              india_source_income_above_15l=False)
    res = evaluate_india_residency(l0, rd)
    t.assert_eq(res.status, IndiaResidency.NR, "T-RS-08: 65d + P4Y<365 + <15L → NR")
    t.assert_eq(res.path_id, "NR-4", "T-RS-08: path = NR-4")

    # T-RS-09: 60 days, preceding <365, income >15L, not liable → RNOR-8
    rd = IndiaResidencyDetail(days_in_india_current_year=65,
                              days_in_india_preceding_4_years_gte_365=False,
                              india_source_income_above_15l=True)
    l0_citizen = Layer0State(is_indian_citizen=True,
                             liable_to_tax_in_another_country=False,
                             has_india_source_income_or_assets=True)
    res = evaluate_india_residency(l0_citizen, rd)
    t.assert_eq(res.status, IndiaResidency.RNOR, "T-RS-09: 65d + P4Y<365 + >15L → RNOR-8")
    t.assert_eq(res.path_id, "RNOR-8", "T-RS-09: path = RNOR-8")

    # T-RS-10: State machine transition provisional → locked
    print("\n── State Machine: Wizard Transitions ──")
    engine_state = TaxEngineState(user_id="test-user", tax_year_id="FY2025-26")
    wiz = WizardStateMachine(engine_state)

    # Patch Layer 0
    wiz.patch_layer0({
        "is_indian_citizen": True,
        "india_days": 200,
        "has_india_source_income_or_assets": True,
        "is_us_citizen": False,
        "was_in_us_this_year": False,
        "has_us_source_income_or_assets": False,
    })
    # Submit Layer 0
    j = wiz.submit_layer0()
    t.assert_eq(j, Jurisdiction.INDIA_ONLY, "T-RS-10a: Wizard routes india_only")
    t.assert_eq(engine_state.wizard_phase.value, "india_residency",
                "T-RS-10b: Phase = india_residency")

    # Patch India residency and fire lock
    wiz.patch_india_residency({
        "nr_years_last_10_gte_9": False,
        "days_in_india_last_7_years_lte_729": False,
    })
    lock_result = wiz.fire_india_lock()
    t.assert_eq(lock_result.status, IndiaResidency.ROR, "T-RS-10c: Lock = ROR")
    t.assert_eq(engine_state.wizard_phase.value, "income_sections",
                "T-RS-10d: Phase advanced to income_sections")

    # ═══════════════════════════════════════════════════════════════
    # GROUP 3: US SPT LOCK (4 tests)
    # ═══════════════════════════════════════════════════════════════
    print("\n── US SPT: Residency Lock ──")

    # T-SPT-01: US citizen → US_CITIZEN (priority 1)
    us = USResidencyDetail(is_us_citizen=True)
    res = evaluate_us_residency(us)
    t.assert_eq(res.status, USResidency.US_CITIZEN, "T-SPT-01: US citizen → US_CITIZEN")

    # T-SPT-02: Green Card holder → RESIDENT_ALIEN (priority 2)
    us = USResidencyDetail(has_green_card=True, us_days_current_year=10,
                           exempt_individual_status=ExemptIndividualStatus.NONE)
    res = evaluate_us_residency(us)
    t.assert_eq(res.status, USResidency.RESIDENT_ALIEN,
                "T-SPT-02: Green Card → RESIDENT_ALIEN")

    # T-SPT-03: SPT met (183+ weighted) → RESIDENT_ALIEN (priority 3)
    us = USResidencyDetail(us_days_current_year=120,
                           us_days_minus_1_year=120,
                           us_days_minus_2_years=120,
                           exempt_individual_status=ExemptIndividualStatus.NONE)
    # Weighted: 120 + 40 + 20 = 180 < 183 → NOT met
    res = evaluate_us_residency(us)
    t.assert_eq(res.status, USResidency.NON_RESIDENT_ALIEN,
                "T-SPT-03: 120+120+120 weighted=180 → NRA")

    # T-SPT-04: SPT met with higher days
    us = USResidencyDetail(us_days_current_year=150,
                           us_days_minus_1_year=120,
                           us_days_minus_2_years=120,
                           exempt_individual_status=ExemptIndividualStatus.NONE)
    # Weighted: 150 + 40 + 20 = 210 → MET
    res = evaluate_us_residency(us)
    t.assert_eq(res.status, USResidency.RESIDENT_ALIEN,
                "T-SPT-04: 150+120+120 weighted=210 → RA")

    # ═══════════════════════════════════════════════════════════════
    # GROUP 4: INDIA DAG DETERMINISM (3 tests)
    # ═══════════════════════════════════════════════════════════════
    print("\n── India DAG: Deterministic Output ──")

    # T-DAG-IN-01: Zero income → zero tax
    inp = IndiaIncomeAssembly()
    result = run_india_dag(inp)
    t.assert_eq(result.total_tax_liability_inr, 0, "T-DAG-IN-01: Zero income → zero tax")

    # T-DAG-IN-02: Salary 10L, New Regime → known slab
    # New Regime: 0-4L=0%, 4-8L=5%=₹20K, 8-10L=10%=₹20K → Total ₹40K
    inp = IndiaIncomeAssembly(salary_net_inr=1_000_000, tax_regime="NEW")
    result = run_india_dag(inp)
    t.assert_eq(result.tax_on_slab_income_inr, 40_000,
                "T-DAG-IN-02: 10L salary New Regime → ₹40K slab tax")

    # T-DAG-IN-03: LTCG with exemption
    # 2L LTCG 112A → 2L - 1.25L = 0.75L taxable @ 12.5% = 9375
    inp = IndiaIncomeAssembly(ltcg_112a_inr=200_000, tax_regime="NEW")
    result = run_india_dag(inp)
    t.assert_eq(result.tax_on_ltcg_112a_inr, 9_375,
                "T-DAG-IN-03: 2L LTCG 112A → ₹9,375 after exemption")

    # ═══════════════════════════════════════════════════════════════
    # GROUP 5: US DAG DETERMINISM (2 tests)
    # ═══════════════════════════════════════════════════════════════
    print("\n── US DAG: Deterministic Output ──")

    # T-DAG-US-01: Zero income → zero tax
    inp_us = USIncomeAssembly()
    result_us = run_us_dag(inp_us)
    t.assert_eq(result_us.total_tax_liability_usd, 0,
                "T-DAG-US-01: Zero income → zero tax")

    # T-DAG-US-02: 100K wages, single → positive tax
    inp_us = USIncomeAssembly(wages_usd=100_000, filing_status="single")
    result_us = run_us_dag(inp_us)
    t.assert_gt(result_us.regular_tax_usd, 0,
                "T-DAG-US-02: 100K wages → positive regular tax")
    t.assert_eq(result_us.deduction_used, "standard",
                "T-DAG-US-02: Standard deduction auto-selected")

    # ═══════════════════════════════════════════════════════════════
    # GROUP 6: OUTPUT STAMPING (2 tests)
    # ═══════════════════════════════════════════════════════════════
    print("\n── Output: Badge Stamping ──")

    # T-OUT-01: Incomplete → APPROXIMATION
    state = TaxEngineState(user_id="test")
    state.layer0 = Layer0State(is_indian_citizen=True, india_days=200,
                                jurisdiction=Jurisdiction.INDIA_ONLY)
    state.india_residency = IndiaResidencyDetail(
        final_india_residency_status=IndiaResidency.ROR)

    computation = FullComputationResult(
        india_result=run_india_dag(IndiaIncomeAssembly(salary_net_inr=500_000)),
        computed_at=datetime.utcnow().isoformat()
    )
    output = stamp_output(computation, state, completion_pct=45)
    t.assert_eq(output.badge, OutputBadge.APPROXIMATION,
                "T-OUT-01: 45% complete → APPROXIMATION")

    # T-OUT-02: Complete → FINAL
    output = stamp_output(computation, state, completion_pct=100)
    t.assert_eq(output.badge, OutputBadge.FINAL,
                "T-OUT-02: 100% complete → FINAL")

    # ═══════════════════════════════════════════════════════════════
    # SUMMARY
    # ═══════════════════════════════════════════════════════════════
    return t.summary()


# ═══════════════════════════════════════════════════════════════════
# SECTION 3 — REACTIVE RE-EVALUATION TEST
# Verifies that changing india_days reactively re-fires the lock.
# ═══════════════════════════════════════════════════════════════════

def test_reactive_refire():
    """
    Scenario: User initially enters 200 india_days (ROR),
    then changes to 30 days. Lock must reactively re-fire to NR.
    """
    print("\n── Reactive Re-evaluation Test ──")

    state = TaxEngineState(user_id="reactive-test", tax_year_id="FY2025-26")
    wiz = WizardStateMachine(state)

    # Step 1: Initial setup — 200 days, india_only
    wiz.patch_layer0({
        "is_indian_citizen": True,
        "india_days": 200,
        "has_india_source_income_or_assets": True,
        "is_us_citizen": False,
        "was_in_us_this_year": False,
        "has_us_source_income_or_assets": False,
    })
    wiz.submit_layer0()
    wiz.patch_india_residency({
        "nr_years_last_10_gte_9": False,
        "days_in_india_last_7_years_lte_729": False,
    })
    wiz.fire_india_lock()

    initial_lock = state.india_residency.final_india_residency_status
    print(f"  Initial lock: {initial_lock.value}")
    assert initial_lock == IndiaResidency.ROR, f"Expected ROR, got {initial_lock}"

    # Step 2: User changes india_days to 30
    diff = wiz.refire_on_upstream_change({"india_days": 30})
    new_lock = state.india_residency.final_india_residency_status
    print(f"  After refire (30 days): {new_lock.value}")
    print(f"  Diff: {diff}")
    assert new_lock == IndiaResidency.NR, f"Expected NR, got {new_lock}"
    assert "india_lock_changed" in diff, "Diff should contain india_lock_changed"
    print("  ✓ Reactive re-evaluation passed")


if __name__ == "__main__":
    all_passed = run_all_tests()
    test_reactive_refire()
    print("\n" + "="*60)
    if all_passed:
        print("ALL TESTS PASSED — Ready for Sprint 4")
    else:
        print("SOME TESTS FAILED — Fix before proceeding")
