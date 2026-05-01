"""
WISING TAX ENGINE — app/models/layer0.py
Layer 0 state dataclass and Jurisdiction enum.
Source: sprint1_input_layer_PATCHED.py Section 1–2.
Schema contract: specs/layer0_residency_final.jsonc
14 fields: 6 REQUIRED, 5 CONDITIONAL, 3 DERIVED.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Optional


class Jurisdiction(str, Enum):
    INDIA_ONLY = "india_only"
    US_ONLY = "us_only"
    DUAL = "dual"
    NONE = "none"


@dataclass
class Layer0State:
    """
    Exact 1:1 mapping to layer0_residency_final.jsonc.
    14 fields: 6 REQUIRED, 5 CONDITIONAL, 3 DERIVED.
    """
    # ── India-flag inputs ──
    is_indian_citizen: Optional[bool] = None          # Q1 | REQUIRED
    is_pio_or_oci: Optional[bool] = None              # Q2 | CONDITIONAL: is_indian_citizen=false
    india_days: Optional[int] = None                  # Q3 | REQUIRED (0–366)
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

    # ── DERIVED outputs (never user-input) ──
    india_flag: Optional[bool] = None
    us_flag: Optional[bool] = None
    jurisdiction: Optional[Jurisdiction] = None
