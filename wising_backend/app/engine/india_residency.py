"""
WISING TAX ENGINE — app/engine/india_residency.py
India Residency Lock — RS-001 Engine (19 exhaustive paths).
Pure function — zero I/O, zero side effects.
Source: sprint1_input_layer_PATCHED.py Section 4.
Schema: specs/layer1_india_v5_1_final.jsonc Section 2.

ABBREVIATIONS (matching schema comments exactly):
  DAYS    = days_in_india_current_year
  P4Y_365 = days_in_india_preceding_4_years_gte_365
  EMP     = employment_or_crew_status
  VISIT   = came_on_visit_to_india_pio_citizen
  NR9     = nr_years_last_10_gte_9
  D7_729  = days_in_india_last_7_years_lte_729
  INC_15L = india_source_income_above_15l
  LTAC    = liable_to_tax_in_another_country_being_indian_citizen

Paths covered:
  ROR-1, ROR-2
  RNOR-1, RNOR-2, RNOR-3, RNOR-4, RNOR-5, RNOR-6, RNOR-7, RNOR-8, RNOR-9
  NR-1, NR-2, NR-3, NR-4, NR-5, NR-6, NR-7, NR-8
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from app.models.india_residency import (
    EmploymentCrewStatus,
    IndiaResidency,
    IndiaResidencyDetail,
)
from app.models.layer0 import Layer0State


@dataclass
class RS001Result:
    """Output of the RS-001 engine. Includes path_id for audit."""
    status: IndiaResidency
    path_id: str        # e.g. "ROR-1", "RNOR-4", "NR-7"
    statutory_basis: str


def compute_ltac(
    is_indian_citizen: Optional[bool],
    liable_to_tax: Optional[bool],
) -> bool:
    """
    DERIVED composite boolean.
    TRUE only when BOTH citizen=true AND liable=true.
    Truth table from schema:
      citizen=true  + liable=true  → TRUE
      citizen=false + liable=true  → FALSE
      citizen=true  + liable=false → FALSE
      citizen=false + liable=false → FALSE
    """
    return bool(is_indian_citizen) and bool(liable_to_tax)


def evaluate_india_residency(
    l0: Layer0State,
    r: IndiaResidencyDetail,
) -> RS001Result:
    """
    RS-001 Engine: 19 exhaustive paths (2 ROR + 9 RNOR + 8 NR).

    Implementation follows Engine Implementation Notes 1–7 exactly:
      1. Evaluate top-down: DAYS >= 182 first
      2. Within 60–181, fork on P4Y_365 first
      3. Then fork on EMP → VISIT → Condition A/B
      4. Deemed Resident paths always RNOR per s.6(6)(d)
      5. Non-citizens never enter Deemed Resident paths
      6. Null/hidden fields treated as "none"/false
    """
    DAYS = r.days_in_india_current_year or 0
    P4Y_365 = bool(r.days_in_india_preceding_4_years_gte_365)
    EMP = r.employment_or_crew_status or EmploymentCrewStatus.NONE
    VISIT = bool(r.came_on_visit_to_india_pio_citizen)
    NR9 = bool(r.nr_years_last_10_gte_9)
    D7_729 = bool(r.days_in_india_last_7_years_lte_729)
    INC_15L = bool(r.india_source_income_above_15l)
    CITIZEN = bool(l0.is_indian_citizen)

    # Compute LTAC from Layer 0 pre-fills
    LTAC = compute_ltac(l0.is_indian_citizen, l0.liable_to_tax_in_another_country)

    # ─── BRANCH 1: 182-day universal rule ───────────────────────────
    if DAYS >= 182:
        # Check RNOR Condition A or B
        if NR9:
            return RS001Result(
                IndiaResidency.RNOR, "RNOR-1",
                "Condition A via 182-day — s.6(6)(a)",
            )
        if D7_729:
            return RS001Result(
                IndiaResidency.RNOR, "RNOR-2",
                "Condition B via 182-day — s.6(6)(a)",
            )
        # Neither Condition A nor B met → ROR
        return RS001Result(
            IndiaResidency.ROR, "ROR-1",
            "182+ days, Condition A/B not met",
        )

    # ─── BRANCH 2: 60-day secondary path ────────────────────────────
    if 60 <= DAYS < 182:
        if not P4Y_365:
            # 60-day path does not trigger residency.
            # Check Deemed Resident only.
            if INC_15L and CITIZEN and not LTAC:
                return RS001Result(
                    IndiaResidency.RNOR, "RNOR-8",
                    "Deemed Resident — 60-day path fails, preceding 4yr < 365 — s.6(1A)+s.6(6)(d)",
                )
            if INC_15L and LTAC:
                return RS001Result(
                    IndiaResidency.NR, "NR-3",
                    "60-day path fails + Deemed Resident blocked",
                )
            return RS001Result(
                IndiaResidency.NR, "NR-4",
                "60-day path fails + no Deemed Resident (income ≤15L)",
            )

        # P4Y_365 = true → fork on EMP
        if EMP != EmploymentCrewStatus.NONE:
            # ── Employment / crew departure path ──
            if INC_15L and CITIZEN and not LTAC:
                return RS001Result(
                    IndiaResidency.RNOR, "RNOR-3",
                    "Employment departure + Deemed Resident — s.6(1A)+s.6(6)(d)",
                )
            if INC_15L and LTAC:
                return RS001Result(
                    IndiaResidency.NR, "NR-8",
                    "Employment departure + Deemed blocked",
                )
            return RS001Result(
                IndiaResidency.NR, "NR-7",
                "Employment departure, income ≤15L",
            )

        # EMP = "none" → fork on VISIT
        if VISIT:
            # ── Visitor path ──
            if DAYS >= 120:
                # Condition C: 120-day visitor with income > 15L
                if INC_15L:
                    return RS001Result(
                        IndiaResidency.RNOR, "RNOR-4",
                        "Visitor 120-day — Condition C — s.6(6)(c)",
                    )
                return RS001Result(
                    IndiaResidency.NR, "NR-5",
                    "Visitor 120-day path: income ≤15L",
                )
            else:
                # DAYS < 120 — visitor below Condition C threshold
                if INC_15L and CITIZEN and not LTAC:
                    return RS001Result(
                        IndiaResidency.RNOR, "RNOR-9",
                        "Visitor < 120 days + Deemed Resident — s.6(1A)+s.6(6)(d)",
                    )
                if INC_15L and LTAC:
                    return RS001Result(
                        IndiaResidency.NR, "NR-6",
                        "Visitor < 120 days + Deemed blocked",
                    )
                return RS001Result(
                    IndiaResidency.NR, "NR-4",
                    "Visitor < 120 days, income ≤15L",
                )

        # VISIT = false → standard 60-day path → check Condition A/B
        if NR9:
            return RS001Result(
                IndiaResidency.RNOR, "RNOR-5",
                "Non-visitor Condition A via 60-day",
            )
        if D7_729:
            return RS001Result(
                IndiaResidency.RNOR, "RNOR-6",
                "Non-visitor Condition B via 60-day",
            )
        # Neither A nor B met → ROR
        return RS001Result(
            IndiaResidency.ROR, "ROR-2",
            "60-day path, Condition A/B not met",
        )

    # ─── BRANCH 3: Below 60 days ────────────────────────────────────
    # Only Deemed Resident check applies here
    if INC_15L and CITIZEN and not LTAC:
        return RS001Result(
            IndiaResidency.RNOR, "RNOR-7",
            "Deemed Resident below 60 days — s.6(1A)+s.6(6)(d)",
        )
    if INC_15L and LTAC:
        return RS001Result(
            IndiaResidency.NR, "NR-1",
            "Deemed Resident blocked — citizen liable elsewhere",
        )
    return RS001Result(
        IndiaResidency.NR, "NR-2",
        "No income threshold met; no path to residency",
    )
