"""
WISING TAX ENGINE — app/engine/layer0_router.py
Layer 0 Jurisdiction Router.
Pure functions — zero I/O, zero side effects.
Source: sprint1_input_layer_PATCHED.py Section 3.
Schema: specs/layer0_residency_final.jsonc

Parallel flag architecture:
  india_flag and us_flag are evaluated INDEPENDENTLY.
  The router NEVER classifies residency.
  The router NEVER applies income gates.
"""
from __future__ import annotations

from copy import deepcopy

from app.models.layer0 import Jurisdiction, Layer0State


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
