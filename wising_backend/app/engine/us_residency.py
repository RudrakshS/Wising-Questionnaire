"""
WISING TAX ENGINE — app/engine/us_residency.py
US Residency Lock — SPT Engine (5-priority cascade).
Pure function — zero I/O, zero side effects.
Source: sprint1_input_layer_PATCHED.py Section 5.
Schema: specs/layer1_us_v2_final.jsonc Section 2.

Priority cascade:
  1. is_us_citizen = true → US_CITIZEN
  2. has_green_card = true AND no I-407 this year → RESIDENT_ALIEN
  3. SPT met AND ¬closer_connection → RESIDENT_ALIEN
  4. Mid-year GC / first-year choice / expatriation → DUAL_STATUS
  5. Otherwise → NON_RESIDENT_ALIEN
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from app.models.us_residency import ExemptIndividualStatus, USResidency, USResidencyDetail


@dataclass
class SPTResult:
    """Output of the SPT engine."""
    status: USResidency
    priority: int           # 1–5 per cascade
    spt_weighted: Optional[float] = None
    spt_met: Optional[bool] = None


def evaluate_us_residency(r: USResidencyDetail) -> SPTResult:
    """
    SPT Engine: 5-priority cascade from layer1_us_v2_final.jsonc.
    """
    # Priority 1: US citizenship
    if r.is_us_citizen:
        return SPTResult(USResidency.US_CITIZEN, 1)

    # Priority 2: Green Card (unsurrendered)
    if r.has_green_card and not r.i407_surrendered_date:
        return SPTResult(USResidency.RESIDENT_ALIEN, 2)

    # Compute SPT weighted count
    cy_days = r.us_days_current_year or 0
    py1_days = r.us_days_minus_1_year or 0
    py2_days = r.us_days_minus_2_years or 0

    # Exempt individuals: their days do not count toward SPT
    if (
        r.exempt_individual_status
        and r.exempt_individual_status != ExemptIndividualStatus.NONE
    ):
        cy_days = 0  # Full-year exemption

    weighted = cy_days + (py1_days / 3) + (py2_days / 6)
    spt_met = cy_days >= 31 and weighted >= 183

    # Priority 3: SPT met, no closer-connection claim
    if spt_met and not r.closer_connection_claim:
        return SPTResult(USResidency.RESIDENT_ALIEN, 3, weighted, True)

    # Priority 4: Dual-status (mid-year events)
    if r.first_year_choice_election:
        return SPTResult(USResidency.DUAL_STATUS, 4, weighted, spt_met)
    if r.has_green_card and r.i407_surrendered_date:
        # Surrendered mid-year → dual-status
        return SPTResult(USResidency.DUAL_STATUS, 4, weighted, spt_met)

    # Priority 5: Non-resident alien
    return SPTResult(USResidency.NON_RESIDENT_ALIEN, 5, weighted, spt_met)
