"""
WISING TAX ENGINE — tests/conftest.py
Frozen state fixtures for all tests.
Three canonical fixtures per spec Part 8:
  - india_nr_state: US-based NRI with Indian source income
  - india_rnor_state: Returning NRI crossing 182 days
  - dual_usc_india_property: US citizen with India property (dual filer)
"""
from __future__ import annotations

import pytest

from app.models.india_residency import (
    EmploymentCrewStatus, IndiaResidency, IndiaResidencyDetail,
)
from app.models.layer0 import Jurisdiction, Layer0State
from app.models.tax_state import TaxEngineState, WizardPhase
from app.models.us_residency import (
    ExemptIndividualStatus, USResidency, USResidencyDetail,
)


@pytest.fixture
def india_nr_state() -> TaxEngineState:
    """
    US-based NRI — 45 days in India, Indian citizen, has India source income,
    has green card, 220 US days. India lock → NR, US lock → RESIDENT_ALIEN.
    """
    state = TaxEngineState(user_id="test-nr", tax_year_id="ty-2025-26")
    state.layer0 = Layer0State(
        is_indian_citizen=True,
        india_days=45,
        has_india_source_income_or_assets=True,
        is_us_citizen=False,
        has_green_card=True,
        was_in_us_this_year=True,
        us_days=220,
        has_us_source_income_or_assets=True,
        liable_to_tax_in_another_country=True,
        left_india_for_employment_this_year=False,
        india_flag=True,
        us_flag=True,
        jurisdiction=Jurisdiction.DUAL,
    )
    state.india_residency = IndiaResidencyDetail(
        days_in_india_current_year=45,
        india_source_income_above_15l=False,
        final_india_residency_status=IndiaResidency.NR,
    )
    state.us_residency = USResidencyDetail(
        is_us_citizen=False,
        has_green_card=True,
        us_days_current_year=220,
        us_days_minus_1_year=200,
        us_days_minus_2_years=180,
        exempt_individual_status=ExemptIndividualStatus.NONE,
        final_us_residency_status=USResidency.RESIDENT_ALIEN,
    )
    state.wizard_phase = WizardPhase.INCOME_SECTIONS
    return state


@pytest.fixture
def india_rnor_state() -> TaxEngineState:
    """
    Returning NRI — 190 days in India this year, was NR for 9+ of last 10 years.
    India lock → RNOR (Condition A via 182-day rule).
    """
    state = TaxEngineState(user_id="test-rnor", tax_year_id="ty-2025-26")
    state.layer0 = Layer0State(
        is_indian_citizen=True,
        india_days=190,
        has_india_source_income_or_assets=True,
        is_us_citizen=False,
        has_green_card=False,
        was_in_us_this_year=False,
        has_us_source_income_or_assets=False,
        india_flag=True,
        us_flag=False,
        jurisdiction=Jurisdiction.INDIA_ONLY,
    )
    state.india_residency = IndiaResidencyDetail(
        days_in_india_current_year=190,
        nr_years_last_10_gte_9=True,
        final_india_residency_status=IndiaResidency.RNOR,
    )
    state.wizard_phase = WizardPhase.INCOME_SECTIONS
    return state


@pytest.fixture
def dual_usc_india_property() -> TaxEngineState:
    """
    US citizen with India property (dual filer).
    India lock → NR (< 60 days, no income threshold crossed).
    US lock → US_CITIZEN.
    """
    state = TaxEngineState(user_id="test-usc-prop", tax_year_id="ty-2025-26")
    state.layer0 = Layer0State(
        is_indian_citizen=False,
        is_pio_or_oci=True,
        india_days=30,
        has_india_source_income_or_assets=True,
        is_us_citizen=True,
        was_in_us_this_year=True,
        us_days=280,
        has_us_source_income_or_assets=True,
        india_flag=True,
        us_flag=True,
        jurisdiction=Jurisdiction.DUAL,
    )
    state.india_residency = IndiaResidencyDetail(
        days_in_india_current_year=30,
        india_source_income_above_15l=False,
        final_india_residency_status=IndiaResidency.NR,
    )
    state.us_residency = USResidencyDetail(
        is_us_citizen=True,
        us_days_current_year=280,
        exempt_individual_status=ExemptIndividualStatus.NONE,
        final_us_residency_status=USResidency.US_CITIZEN,
    )
    state.wizard_phase = WizardPhase.INCOME_SECTIONS
    return state
