"""
tests/test_gate_evaluator.py — ≥8 tests for gate operators.
Includes the MANDATORY test: None != [] (GAP-004).
"""
import pytest
from app.engine.gate_evaluator import evaluate_gate


def test_no_gate_always_visible():
    assert evaluate_gate(None, {}) is True


def test_eq_scalar_match():
    gate = {"field": "layer0.is_indian_citizen", "op": "eq", "value": True}
    assert evaluate_gate(gate, {"layer0": {"is_indian_citizen": True}}) is True


def test_eq_scalar_no_match():
    gate = {"field": "layer0.is_indian_citizen", "op": "eq", "value": True}
    assert evaluate_gate(gate, {"layer0": {"is_indian_citizen": False}}) is False


def test_gate_eq_empty_array_vs_none():
    """
    MANDATORY TEST from ANTIGRAVITY_BUILD_PROMPT Part 8.
    None (not answered) must NOT match [] (explicitly empty).
    """
    gate = {
        "field": "layer1_india.domestic_income.business_income.presumptive_scheme",
        "op": "eq",
        "value": [],
    }
    ctx_none = {"layer1_india": {"domestic_income": {"business_income": {"presumptive_scheme": None}}}}
    ctx_empty = {"layer1_india": {"domestic_income": {"business_income": {"presumptive_scheme": []}}}}
    assert evaluate_gate(gate, ctx_none) is False   # None != []
    assert evaluate_gate(gate, ctx_empty) is True   # [] == []


def test_contains_operator():
    gate = {
        "field": "layer1_india.domestic_income.business_income.presumptive_scheme",
        "op": "contains",
        "value": "s44AD",
    }
    ctx = {"layer1_india": {"domestic_income": {"business_income": {"presumptive_scheme": ["s44AD", "s44ADA"]}}}}
    assert evaluate_gate(gate, ctx) is True
    ctx2 = {"layer1_india": {"domestic_income": {"business_income": {"presumptive_scheme": ["s44AE"]}}}}
    assert evaluate_gate(gate, ctx2) is False


def test_contains_on_null_returns_false():
    gate = {"field": "layer1_india.business_income.presumptive_scheme", "op": "contains", "value": "s44AD"}
    assert evaluate_gate(gate, {"layer1_india": {"business_income": {"presumptive_scheme": None}}}) is False


def test_gte_operator():
    gate = {"field": "layer0.india_days", "op": "gte", "value": 60}
    assert evaluate_gate(gate, {"layer0": {"india_days": 60}}) is True
    assert evaluate_gate(gate, {"layer0": {"india_days": 59}}) is False
    assert evaluate_gate(gate, {"layer0": {"india_days": None}}) is False


def test_lt_operator():
    gate = {"field": "layer0.india_days", "op": "lt", "value": 182}
    assert evaluate_gate(gate, {"layer0": {"india_days": 100}}) is True
    assert evaluate_gate(gate, {"layer0": {"india_days": 182}}) is False


def test_and_operator():
    gate = {"and": [
        {"field": "layer0.india_days", "op": "gte", "value": 60},
        {"field": "layer0.india_days", "op": "lt", "value": 182},
    ]}
    assert evaluate_gate(gate, {"layer0": {"india_days": 90}}) is True
    assert evaluate_gate(gate, {"layer0": {"india_days": 200}}) is False


def test_or_operator():
    gate = {"or": [
        {"field": "layer0.is_indian_citizen", "op": "eq", "value": True},
        {"field": "layer0.is_pio_or_oci", "op": "eq", "value": True},
    ]}
    assert evaluate_gate(gate, {"layer0": {"is_indian_citizen": False, "is_pio_or_oci": True}}) is True
    assert evaluate_gate(gate, {"layer0": {"is_indian_citizen": False, "is_pio_or_oci": False}}) is False


def test_in_operator():
    gate = {"field": "layer1_india.residency_detail.final_india_residency_status",
            "op": "in", "value": ["ROR", "RNOR"]}
    assert evaluate_gate(gate, {"layer1_india": {"residency_detail": {"final_india_residency_status": "RNOR"}}}) is True
    assert evaluate_gate(gate, {"layer1_india": {"residency_detail": {"final_india_residency_status": "NR"}}}) is False
