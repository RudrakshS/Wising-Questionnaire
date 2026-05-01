"""
tests/test_us_residency.py — 5 tests, one per SPT cascade priority.
"""
from app.engine.us_residency import evaluate_us_residency
from app.models.us_residency import ExemptIndividualStatus, USResidency, USResidencyDetail


def test_priority_1_us_citizen():
    r = evaluate_us_residency(USResidencyDetail(is_us_citizen=True))
    assert r.status == USResidency.US_CITIZEN and r.priority == 1


def test_priority_2_green_card_unsurrendered():
    r = evaluate_us_residency(USResidencyDetail(
        is_us_citizen=False, has_green_card=True, i407_surrendered_date=None,
    ))
    assert r.status == USResidency.RESIDENT_ALIEN and r.priority == 2


def test_priority_3_spt_met():
    r = evaluate_us_residency(USResidencyDetail(
        is_us_citizen=False, has_green_card=False,
        us_days_current_year=190, us_days_minus_1_year=120, us_days_minus_2_years=60,
        exempt_individual_status=ExemptIndividualStatus.NONE,
        closer_connection_claim=False,
    ))
    assert r.status == USResidency.RESIDENT_ALIEN and r.priority == 3
    assert r.spt_met is True


def test_priority_4_dual_status_first_year_choice():
    r = evaluate_us_residency(USResidencyDetail(
        is_us_citizen=False, has_green_card=False,
        us_days_current_year=60, us_days_minus_1_year=30, us_days_minus_2_years=0,
        exempt_individual_status=ExemptIndividualStatus.NONE,
        first_year_choice_election=True,
    ))
    assert r.status == USResidency.DUAL_STATUS and r.priority == 4


def test_priority_5_nra():
    r = evaluate_us_residency(USResidencyDetail(
        is_us_citizen=False, has_green_card=False,
        us_days_current_year=40, us_days_minus_1_year=20, us_days_minus_2_years=10,
        exempt_individual_status=ExemptIndividualStatus.NONE,
    ))
    assert r.status == USResidency.NON_RESIDENT_ALIEN and r.priority == 5
