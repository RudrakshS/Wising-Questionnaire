"""
WISING TAX ENGINE — app/models/india_residency.py
India residency models.
Source: sprint1_input_layer_PATCHED.py Section 2.
Schema contract: specs/layer1_india_v5_1_final.jsonc Section 2.
12 fields: 1 REQUIRED, 8 CONDITIONAL, 1 OPTIONAL, 2 DERIVED.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional


class IndiaResidency(str, Enum):
    NR = "NR"
    RNOR = "RNOR"
    ROR = "ROR"


class EmploymentCrewStatus(str, Enum):
    EMPLOYED_ABROAD = "employed_abroad"
    INDIAN_SHIP_CREW = "indian_ship_crew"
    FOREIGN_SHIP_CREW = "foreign_ship_crew"
    NONE = "none"


@dataclass
class IndiaResidencyDetail:
    """
    Exact 1:1 mapping to layer1_india_v5_1_final.jsonc Section 2.
    12 fields: 1 REQUIRED, 8 CONDITIONAL, 1 OPTIONAL, 2 DERIVED.
    """
    # ── User inputs ──
    days_in_india_current_year: Optional[int] = None           # PRE-FILLED from L0
    days_in_india_preceding_4_years_gte_365: Optional[bool] = None  # COND: days 60–181
    employment_or_crew_status: Optional[EmploymentCrewStatus] = None  # COND: complex gate
    is_departure_year: Optional[bool] = None                   # COND: emp != none
    ship_nationality: Optional[str] = None                     # COND: crew status
    came_on_visit_to_india_pio_citizen: Optional[bool] = None  # COND: emp = none
    nr_years_last_10_gte_9: Optional[bool] = None              # COND: days>=182 OR visit=false
    days_in_india_last_7_years_lte_729: Optional[bool] = None  # COND: same gate
    india_source_income_above_15l: Optional[bool] = None       # COND: has_india_source=true
    current_year_trip_log: list = field(default_factory=list)   # OPTIONAL

    # ── DERIVED (engine-computed, never user-input) ──
    liable_to_tax_in_another_country_being_indian_citizen: Optional[bool] = None
    final_india_residency_status: Optional[IndiaResidency] = None
