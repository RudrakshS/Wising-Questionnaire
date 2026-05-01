"""
WISING TAX ENGINE — app/models/us_residency.py
US residency models.
Source: sprint1_input_layer_PATCHED.py Section 2.
Schema contract: specs/layer1_us_v2_final.jsonc Section 2.
16 fields: 7 REQUIRED, 2 CONDITIONAL, 2 OPTIONAL, 5 DERIVED.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Optional


class USResidency(str, Enum):
    US_CITIZEN = "US_CITIZEN"
    RESIDENT_ALIEN = "RESIDENT_ALIEN"
    NON_RESIDENT_ALIEN = "NON_RESIDENT_ALIEN"
    DUAL_STATUS = "DUAL_STATUS"


class ExemptIndividualStatus(str, Enum):
    NONE = "none"
    F_STUDENT = "f_student"
    J_SCHOLAR = "j_scholar"
    G_DIPLOMAT = "g_diplomat"
    PROFESSIONAL_ATHLETE = "professional_athlete"


@dataclass
class USResidencyDetail:
    """
    Exact 1:1 mapping to layer1_us_v2_final.jsonc Section 2.
    16 fields: 7 REQUIRED, 2 CONDITIONAL, 2 OPTIONAL, 5 DERIVED.
    """
    # ── Status flags (pre-filled from L0) ──
    is_us_citizen: Optional[bool] = None
    has_green_card: Optional[bool] = None
    green_card_grant_date: Optional[str] = None       # COND: has_green_card=true
    i407_surrendered_date: Optional[str] = None       # COND: has_green_card=true

    # ── SPT inputs ──
    us_days_current_year: Optional[int] = None         # PRE-FILLED from L0
    us_days_minus_1_year: Optional[int] = None         # REQUIRED
    us_days_minus_2_years: Optional[int] = None        # REQUIRED
    exempt_individual_status: Optional[ExemptIndividualStatus] = None  # REQUIRED

    # ── Elections ──
    closer_connection_claim: Optional[bool] = None     # COND: spt_met AND days<183
    first_year_choice_election: Optional[bool] = None  # OPTIONAL
    s6013g_joint_election: Optional[bool] = None       # OPTIONAL

    # ── DERIVED (engine-computed, never user-input) ──
    spt_day_count_weighted: Optional[float] = None
    spt_test_met: Optional[bool] = None
    final_us_residency_status: Optional[USResidency] = None
    residency_start_date: Optional[str] = None
    residency_end_date: Optional[str] = None
