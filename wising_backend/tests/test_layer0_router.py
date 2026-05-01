"""
tests/test_layer0_router.py — 14 tests covering all jurisdiction outcomes.
"""
import pytest
from app.engine.layer0_router import evaluate_india_flag, evaluate_us_flag, evaluate_jurisdiction
from app.models.layer0 import Jurisdiction, Layer0State


def l0(**kw) -> Layer0State:
    return Layer0State(**kw)


# ── India flag tests ─────────────────────────────────────────────

def test_india_flag_citizen():
    assert evaluate_india_flag(l0(is_indian_citizen=True)) is True

def test_india_flag_pio():
    assert evaluate_india_flag(l0(is_indian_citizen=False, is_pio_or_oci=True)) is True

def test_india_flag_days_gt0():
    assert evaluate_india_flag(l0(india_days=1)) is True

def test_india_flag_days_zero():
    assert evaluate_india_flag(l0(india_days=0)) is False

def test_india_flag_source_income():
    assert evaluate_india_flag(l0(has_india_source_income_or_assets=True)) is True

def test_india_flag_none_inputs():
    assert evaluate_india_flag(l0()) is False

# ── US flag tests ─────────────────────────────────────────────────

def test_us_flag_citizen():
    assert evaluate_us_flag(l0(is_us_citizen=True)) is True

def test_us_flag_green_card():
    assert evaluate_us_flag(l0(has_green_card=True)) is True

def test_us_flag_days_present():
    assert evaluate_us_flag(l0(was_in_us_this_year=True, us_days=90)) is True

def test_us_flag_days_zero():
    assert evaluate_us_flag(l0(was_in_us_this_year=True, us_days=0)) is False

def test_us_flag_source_income():
    assert evaluate_us_flag(l0(has_us_source_income_or_assets=True)) is True

def test_us_flag_none_inputs():
    assert evaluate_us_flag(l0()) is False

# ── Jurisdiction derivation tests ─────────────────────────────────

def test_jurisdiction_dual():
    s = l0(is_indian_citizen=True, india_days=45, has_india_source_income_or_assets=True,
           is_us_citizen=True, was_in_us_this_year=True, us_days=220)
    result = evaluate_jurisdiction(s)
    assert result.jurisdiction == Jurisdiction.DUAL
    assert result.india_flag is True
    assert result.us_flag is True

def test_jurisdiction_india_only():
    s = l0(is_indian_citizen=True, india_days=200)
    result = evaluate_jurisdiction(s)
    assert result.jurisdiction == Jurisdiction.INDIA_ONLY

def test_jurisdiction_none():
    result = evaluate_jurisdiction(l0())
    assert result.jurisdiction == Jurisdiction.NONE
