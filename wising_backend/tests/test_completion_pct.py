"""
tests/test_completion_pct.py — 6 tests for the completion engine.
Tests: DERIVED exclusion, OPTIONAL exclusion, gate-closed exclusion,
       array GAP-005, section detail structure, full 100% scenario.
"""
import pytest
from app.engine.gate_evaluator import compute_completion_pct
from app.models.india_residency import IndiaResidency, IndiaResidencyDetail
from app.models.layer0 import Jurisdiction, Layer0State
from app.models.tax_state import TaxEngineState
from app.models.us_residency import USResidencyDetail


def _state_with_l0(**kw) -> TaxEngineState:
    state = TaxEngineState()
    for k, v in kw.items():
        setattr(state.layer0, k, v)
    return state


MINIMAL_REGISTRY = [
    {"field_path": "layer0.is_indian_citizen", "schema_name": "layer0",
     "section": "identity", "classification": "REQUIRED",
     "friendly_label": "Are you an Indian citizen?", "input_type": "boolean",
     "enabled_if": None},
    {"field_path": "layer0.india_days", "schema_name": "layer0",
     "section": "residency", "classification": "REQUIRED",
     "friendly_label": "Days in India", "input_type": "integer",
     "enabled_if": None},
    {"field_path": "layer0.is_pio_or_oci", "schema_name": "layer0",
     "section": "identity", "classification": "CONDITIONAL",
     "friendly_label": "PIO/OCI?", "input_type": "boolean",
     "enabled_if": {"field": "layer0.is_indian_citizen", "op": "eq", "value": False}},
    {"field_path": "layer0.jurisdiction", "schema_name": "layer0",
     "section": "derived", "classification": "DERIVED",
     "friendly_label": "Jurisdiction", "input_type": "enum",
     "enabled_if": None},
    {"field_path": "layer0.some_optional", "schema_name": "layer0",
     "section": "identity", "classification": "OPTIONAL",
     "friendly_label": "Optional field", "input_type": "string",
     "enabled_if": None},
]


def test_derived_excluded():
    state = _state_with_l0(is_indian_citizen=True, india_days=100)
    pct, detail = compute_completion_pct(state, MINIMAL_REGISTRY)
    # DERIVED and OPTIONAL excluded → 2 REQUIRED fields
    assert detail["total_required"] == 2


def test_optional_excluded():
    state = _state_with_l0(is_indian_citizen=True, india_days=100)
    pct, detail = compute_completion_pct(state, MINIMAL_REGISTRY)
    assert "some_optional" not in str(detail["sections"])


def test_gate_closed_not_counted():
    # is_pio_or_oci gate: is_indian_citizen=True → gate closed → not counted
    state = _state_with_l0(is_indian_citizen=True, india_days=100)
    pct, detail = compute_completion_pct(state, MINIMAL_REGISTRY)
    assert detail["total_required"] == 2  # only 2 REQUIRED, CONDITIONAL gate closed


def test_gate_open_counted():
    # is_pio_or_oci gate: is_indian_citizen=False → gate opens
    state = _state_with_l0(is_indian_citizen=False, india_days=50)
    pct, detail = compute_completion_pct(state, MINIMAL_REGISTRY)
    assert detail["total_required"] == 3  # 2 REQUIRED + 1 CONDITIONAL with open gate


def test_gap_005_empty_array_not_filled():
    """GAP-005: empty list [] is NOT filled."""
    registry = [{
        "field_path": "layer1_india.goods_vehicles", "schema_name": "layer1_india",
        "section": "transport", "classification": "REQUIRED",
        "friendly_label": "Vehicles", "input_type": "array", "enabled_if": None,
    }]
    state = TaxEngineState()
    state.india_residency = IndiaResidencyDetail()
    # Monkey-patch array field
    state.india_residency.__dict__["goods_vehicles"] = []
    pct, detail = compute_completion_pct(state, registry)
    assert detail["filled_required"] == 0


def test_100pct_when_all_filled():
    state = _state_with_l0(is_indian_citizen=True, india_days=100)
    req_only = [f for f in MINIMAL_REGISTRY if f["classification"] == "REQUIRED"]
    pct, detail = compute_completion_pct(state, req_only)
    assert pct == 100
    assert detail["filing_ready"] is True
