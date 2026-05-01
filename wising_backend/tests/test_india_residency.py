"""
tests/test_india_residency.py — 19 tests, one per RS-001 path.
Paths: ROR-1, ROR-2, RNOR-1..9, NR-1..8.
"""
import pytest
from app.engine.india_residency import evaluate_india_residency
from app.models.india_residency import EmploymentCrewStatus, IndiaResidency, IndiaResidencyDetail
from app.models.layer0 import Layer0State


def l0(**kw) -> Layer0State:
    defaults = dict(is_indian_citizen=True, liable_to_tax_in_another_country=False)
    defaults.update(kw)
    return Layer0State(**defaults)


def rd(**kw) -> IndiaResidencyDetail:
    return IndiaResidencyDetail(**kw)


# ── ROR paths ─────────────────────────────────────────────────────

def test_ror_1_182_days_no_condition():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=200,
        nr_years_last_10_gte_9=False, days_in_india_last_7_years_lte_729=False))
    assert r.status == IndiaResidency.ROR and r.path_id == "ROR-1"

def test_ror_2_60_day_path_no_condition():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=90,
        days_in_india_preceding_4_years_gte_365=True,
        came_on_visit_to_india_pio_citizen=False,
        nr_years_last_10_gte_9=False, days_in_india_last_7_years_lte_729=False))
    assert r.status == IndiaResidency.ROR and r.path_id == "ROR-2"

# ── RNOR paths ────────────────────────────────────────────────────

def test_rnor_1_182_condition_a():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=190,
        nr_years_last_10_gte_9=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-1"

def test_rnor_2_182_condition_b():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=200,
        nr_years_last_10_gte_9=False, days_in_india_last_7_years_lte_729=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-2"

def test_rnor_3_employment_deemed():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=100,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.EMPLOYED_ABROAD,
        india_source_income_above_15l=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-3"

def test_rnor_4_visitor_120_condition_c():
    r = evaluate_india_residency(l0(is_indian_citizen=False), rd(
        days_in_india_current_year=130,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.NONE,
        came_on_visit_to_india_pio_citizen=True,
        india_source_income_above_15l=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-4"

def test_rnor_5_60_day_condition_a():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=100,
        days_in_india_preceding_4_years_gte_365=True,
        came_on_visit_to_india_pio_citizen=False,
        nr_years_last_10_gte_9=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-5"

def test_rnor_6_60_day_condition_b():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=100,
        days_in_india_preceding_4_years_gte_365=True,
        came_on_visit_to_india_pio_citizen=False,
        nr_years_last_10_gte_9=False, days_in_india_last_7_years_lte_729=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-6"

def test_rnor_7_deemed_below_60():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=30,
        india_source_income_above_15l=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-7"

def test_rnor_8_deemed_60_day_p4y_fails():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=100,
        days_in_india_preceding_4_years_gte_365=False,
        india_source_income_above_15l=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-8"

def test_rnor_9_visitor_lt120_deemed():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=80,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.NONE,
        came_on_visit_to_india_pio_citizen=True,
        india_source_income_above_15l=True))
    assert r.status == IndiaResidency.RNOR and r.path_id == "RNOR-9"

# ── NR paths ──────────────────────────────────────────────────────

def test_nr_1_deemed_blocked_liable():
    r = evaluate_india_residency(l0(liable_to_tax_in_another_country=True),
        rd(days_in_india_current_year=30, india_source_income_above_15l=True))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-1"

def test_nr_2_no_threshold_below_60():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=30,
        india_source_income_above_15l=False))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-2"

def test_nr_3_60_day_p4y_fails_blocked():
    r = evaluate_india_residency(l0(liable_to_tax_in_another_country=True),
        rd(days_in_india_current_year=100,
           days_in_india_preceding_4_years_gte_365=False,
           india_source_income_above_15l=True))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-3"

def test_nr_4_60_day_no_income():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=100,
        days_in_india_preceding_4_years_gte_365=False,
        india_source_income_above_15l=False))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-4"

def test_nr_5_visitor_120_low_income():
    r = evaluate_india_residency(l0(is_indian_citizen=False), rd(
        days_in_india_current_year=130,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.NONE,
        came_on_visit_to_india_pio_citizen=True,
        india_source_income_above_15l=False))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-5"

def test_nr_6_visitor_lt120_blocked():
    r = evaluate_india_residency(l0(liable_to_tax_in_another_country=True),
        rd(days_in_india_current_year=80,
           days_in_india_preceding_4_years_gte_365=True,
           employment_or_crew_status=EmploymentCrewStatus.NONE,
           came_on_visit_to_india_pio_citizen=True,
           india_source_income_above_15l=True))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-6"

def test_nr_7_employment_low_income():
    r = evaluate_india_residency(l0(), rd(days_in_india_current_year=100,
        days_in_india_preceding_4_years_gte_365=True,
        employment_or_crew_status=EmploymentCrewStatus.EMPLOYED_ABROAD,
        india_source_income_above_15l=False))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-7"

def test_nr_8_employment_deemed_blocked():
    r = evaluate_india_residency(l0(liable_to_tax_in_another_country=True),
        rd(days_in_india_current_year=100,
           days_in_india_preceding_4_years_gte_365=True,
           employment_or_crew_status=EmploymentCrewStatus.EMPLOYED_ABROAD,
           india_source_income_above_15l=True))
    assert r.status == IndiaResidency.NR and r.path_id == "NR-8"
