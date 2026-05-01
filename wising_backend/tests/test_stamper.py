"""
tests/test_stamper.py — Advisory card emission tests.
"""
import pytest
from app.output.stamper import OutputStamper


def stamper() -> OutputStamper:
    return OutputStamper()


def _snap(**kw) -> dict:
    base = {"layer1_india": {}, "layer1_us": {}, "india_lock": None, "us_lock": None,
            "computation_result": None}
    base.update(kw)
    return base


def test_approximation_when_incomplete():
    out = stamper().stamp(_snap(), completion_pct=60, missing_required=["field_a"],
                          missing_required_labels=["Field A"])
    assert out.status == "APPROXIMATION"
    assert out.is_approximation is True


def test_final_when_complete():
    out = stamper().stamp(_snap(), completion_pct=100, missing_required=[],
                          missing_required_labels=[])
    assert out.status == "FINAL"
    assert out.is_approximation is False


def test_pfic_card_us_citizen_with_mf():
    snap = _snap(
        us_lock="US_CITIZEN",
        layer1_india={"financial_holdings": {"has_mutual_fund_investments": True}},
    )
    out = stamper().stamp(snap, 50, [], [])
    ids = [c.card_id for c in out.advisory_cards]
    assert "TRAP-PFIC-MF" in ids


def test_pfic_card_not_emitted_for_nra():
    snap = _snap(
        us_lock="NON_RESIDENT_ALIEN",
        layer1_india={"financial_holdings": {"has_mutual_fund_investments": True}},
    )
    out = stamper().stamp(snap, 50, [], [])
    ids = [c.card_id for c in out.advisory_cards]
    assert "TRAP-PFIC-MF" not in ids


def test_fbar_card_emitted():
    snap = _snap(
        us_lock="RESIDENT_ALIEN",
        layer1_india={"bank_accounts": {"accounts": [
            {"peak_balance_inr": 1_000_000},  # ~$11,900 USD — above $10K threshold
        ]}},
    )
    out = stamper().stamp(snap, 70, [], [])
    ids = [c.card_id for c in out.advisory_cards]
    assert "TRAP-FBAR" in ids


def test_pan_inoperative_card_for_resident():
    snap = _snap(
        india_lock="RNOR",
        layer1_india={"profile": {"pan_aadhaar_linked": False}},
    )
    out = stamper().stamp(snap, 80, [], [])
    ids = [c.card_id for c in out.advisory_cards]
    assert "ALERT-PAN-INOPERATIVE" in ids


def test_pan_inoperative_not_emitted_for_nr():
    snap = _snap(
        india_lock="NR",
        layer1_india={"profile": {"pan_aadhaar_linked": False}},
    )
    out = stamper().stamp(snap, 80, [], [])
    ids = [c.card_id for c in out.advisory_cards]
    assert "ALERT-PAN-INOPERATIVE" not in ids


def test_speculative_audit_card():
    snap = _snap(
        india_lock="ROR",
        layer1_india={"domestic_income": {"business_income": {
            "speculative_turnover_inr": 15_000_000,  # 1.5 Cr
        }}},
    )
    out = stamper().stamp(snap, 90, [], [])
    ids = [c.card_id for c in out.advisory_cards]
    assert "ALERT-AUDIT-SPECULATIVE" in ids


def test_no_cards_clean_state():
    out = stamper().stamp(_snap(), completion_pct=50, missing_required=[], missing_required_labels=[])
    assert len(out.advisory_cards) == 0
