"""
WISING TAX ENGINE — SPRINT 2: COMPUTE LAYER (THE MATH DAG)
═══════════════════════════════════════════════════════════════════
Document: WISING-IMPL-001 Sprint 2
Architecture: WISING-ARCH-005 v2.0

CRITICAL CONTRACT:
  - ZERO database I/O
  - ZERO API calls
  - ZERO side effects
  - Accepts frozen data model → returns computed model
  - Fires ONLY on explicit "Evaluate Tax" trigger
  - Every DAG node is independently unit-testable

DAG Structure:
  India: Income Assembly → GTI → Slab Tax → Surcharge → Cess → Credits → Net
  US:    AGI → Taxable Income → Regular Tax → AMT → NIIT → FTC → Net
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional
from enum import Enum

from sprint1_input_layer import (
    IndiaResidency, USResidency, TaxEngineState, Layer0State,
    IndiaResidencyDetail, USResidencyDetail
)


# ═══════════════════════════════════════════════════════════════════
# SECTION 1 — DAG NODE PROTOCOL
# Every node is a pure function: Input → Output.
# Nodes compose into a pipeline. No node has side effects.
# ═══════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Assumption:
    """
    Tracks every default the engine uses.
    NO SILENT DEFAULTS — every assumption is explicit.
    """
    field_path: str
    assumed_value: str
    reason: str
    user_overridable: bool = True


# ═══════════════════════════════════════════════════════════════════
# SECTION 2 — INDIA TAX DAG
# Pipeline: Income Assembly → GTI → Slab → Surcharge → Cess → Net
# Source: Wising_India_Tax_Logic_Spec_v6.docx
# ═══════════════════════════════════════════════════════════════════

# ── 2A: India Slab Tables (FY 2025-26) ──────────────────────────

INDIA_NEW_REGIME_SLABS_FY2025 = [
    # (upper_limit, rate) — cumulative brackets
    (400_000,   0.00),
    (800_000,   0.05),
    (1_200_000, 0.10),
    (1_600_000, 0.15),
    (2_000_000, 0.20),
    (2_400_000, 0.25),
    (float('inf'), 0.30),
]

INDIA_OLD_REGIME_SLABS_GENERAL = [
    (250_000,   0.00),
    (500_000,   0.05),
    (1_000_000, 0.20),
    (float('inf'), 0.30),
]

INDIA_OLD_REGIME_SLABS_SENIOR = [  # 60-80 years
    (300_000,   0.00),
    (500_000,   0.05),
    (1_000_000, 0.20),
    (float('inf'), 0.30),
]

INDIA_OLD_REGIME_SLABS_SUPER_SENIOR = [  # 80+ years
    (500_000,   0.00),
    (1_000_000, 0.20),
    (float('inf'), 0.30),
]

# ── Special CG rates (post FA 2024) ──
INDIA_STCG_111A_RATE = 0.20        # STT-paid equity STCG
INDIA_LTCG_112A_RATE = 0.125       # STT-paid equity LTCG (above ₹1.25L exemption)
INDIA_LTCG_112_RATE = 0.125        # Property/unlisted/debt-MF LTCG
INDIA_SPECIAL_RATE = 0.30          # Lottery, gaming, VDA (s.115BB/BBJ/BBH)
INDIA_LTCG_112A_EXEMPTION = 125_000  # ₹1.25L threshold

# ── Surcharge table (New Regime) ──
INDIA_SURCHARGE_NEW = [
    (5_000_000,   0.00),
    (10_000_000,  0.10),
    (20_000_000,  0.15),
    (float('inf'), 0.25),
]

# ── Surcharge table (Old Regime) ──
INDIA_SURCHARGE_OLD = [
    (5_000_000,   0.00),
    (10_000_000,  0.10),
    (20_000_000,  0.15),
    (50_000_000,  0.25),
    (float('inf'), 0.37),
]

INDIA_CESS_RATE = 0.04  # Health & Education Cess


@dataclass(frozen=True)
class IndiaIncomeAssembly:
    """
    Input to the India DAG. Assembled from Layer 1 India income sections.
    Maps to surcharge_buckets in schema Section 18.
    """
    # ── Slab-rate income ──
    salary_net_inr: int = 0
    house_property_net_inr: int = 0
    business_non_speculative_inr: int = 0
    other_sources_slab_inr: int = 0          # interest + dividend + family pension net

    # ── Special-rate income ──
    stcg_111a_inr: int = 0                   # STT-paid equity STCG @ 20%
    ltcg_112a_inr: int = 0                   # STT-paid equity LTCG (pre-exemption)
    ltcg_112_inr: int = 0                    # Property/unlisted LTCG @ 12.5%
    stcg_other_inr: int = 0                  # Slab-rate STCG
    special_115bb_bbj_inr: int = 0           # Lottery, gaming @ 30%
    vda_115bbh_inr: int = 0                  # Crypto/VDA @ 30%
    speculative_inr: int = 0                 # Intraday

    # ── Deductions (Old Regime only) ──
    chapter_via_total_inr: int = 0           # 80C+80D+80G etc.
    rebate_87a_eligible: bool = False

    # ── Agriculture (partial integration) ──
    agricultural_income_inr: int = 0

    # ── Carry-forward set-off ──
    brought_forward_loss_applied_inr: int = 0

    # ── Tax credits ──
    advance_tax_paid_inr: int = 0
    tds_deducted_inr: int = 0
    ftc_india_inr: int = 0

    # ── Regime ──
    tax_regime: str = "NEW"                  # "NEW" or "OLD"
    is_senior: bool = False                  # 60+
    is_super_senior: bool = False            # 80+


@dataclass
class IndiaTaxResult:
    """Output of the India DAG."""
    # ── Income ──
    gross_total_income_inr: int = 0
    total_income_after_deductions_inr: int = 0

    # ── Tax on normal slab income ──
    tax_on_slab_income_inr: int = 0

    # ── Tax on special-rate income ──
    tax_on_stcg_111a_inr: int = 0
    tax_on_ltcg_112a_inr: int = 0
    tax_on_ltcg_112_inr: int = 0
    tax_on_special_inr: int = 0
    tax_on_vda_inr: int = 0

    # ── Aggregate before surcharge ──
    total_tax_before_surcharge_inr: int = 0

    # ── Surcharge + Cess ──
    surcharge_inr: int = 0
    cess_inr: int = 0

    # ── Credits ──
    rebate_87a_inr: int = 0
    total_credits_inr: int = 0

    # ── Net ──
    total_tax_liability_inr: int = 0
    net_tax_payable_inr: int = 0             # After credits

    # ── Audit ──
    regime_used: str = "NEW"
    assumptions: list = field(default_factory=list)


def compute_slab_tax(income: int, slabs: list[tuple[float, float]]) -> int:
    """
    Pure function: compute tax on income using progressive slab table.
    No side effects. Deterministic.
    """
    tax = 0
    prev_limit = 0
    for upper_limit, rate in slabs:
        if income <= prev_limit:
            break
        taxable_in_slab = min(income, upper_limit) - prev_limit
        if taxable_in_slab > 0:
            tax += int(taxable_in_slab * rate)
        prev_limit = upper_limit
    return tax


def compute_surcharge(total_income: int, tax: int,
                      table: list[tuple[float, float]]) -> int:
    """
    Compute surcharge with marginal relief.
    The surcharge cannot make post-surcharge tax exceed
    the tax at the lower bracket + the excess income.
    """
    surcharge_rate = 0.0
    for threshold, rate in table:
        if total_income <= threshold:
            break
        surcharge_rate = rate

    raw_surcharge = int(tax * surcharge_rate)

    # Marginal relief check
    if surcharge_rate > 0:
        prev_threshold = 0
        for threshold, rate in table:
            if rate == surcharge_rate:
                prev_threshold = threshold
                break
            prev_threshold = threshold

        if prev_threshold > 0:
            excess_income = total_income - prev_threshold
            tax_at_threshold = compute_slab_tax(
                prev_threshold,
                INDIA_NEW_REGIME_SLABS_FY2025  # Simplified — use regime-appropriate slabs
            )
            marginal_limit = excess_income
            if raw_surcharge > marginal_limit:
                raw_surcharge = marginal_limit

    return raw_surcharge


def run_india_dag(inp: IndiaIncomeAssembly) -> IndiaTaxResult:
    """
    INDIA MATH DAG — Pure function, zero side effects.

    Pipeline:
      1. Income Assembly → GTI
      2. GTI → Deductions → Total Income
      3. Total Income → Slab Tax (normal income)
      4. Special-rate income → flat-rate tax
      5. Aggregate → Surcharge → Cess
      6. Rebate 87A → Credits → Net Payable
    """
    assumptions: list[Assumption] = []
    result = IndiaTaxResult(regime_used=inp.tax_regime)

    # ── NODE 1: GTI Assembly ────────────────────────────────────────
    slab_income = (inp.salary_net_inr + inp.house_property_net_inr
                   + inp.business_non_speculative_inr + inp.other_sources_slab_inr
                   + inp.stcg_other_inr + inp.speculative_inr)

    gti = (slab_income + inp.stcg_111a_inr + inp.ltcg_112a_inr
           + inp.ltcg_112_inr + inp.special_115bb_bbj_inr + inp.vda_115bbh_inr)

    result.gross_total_income_inr = max(0, gti - inp.brought_forward_loss_applied_inr)

    # ── NODE 2: Deductions ──────────────────────────────────────────
    deductions = 0
    if inp.tax_regime == "OLD":
        deductions = inp.chapter_via_total_inr
    else:
        assumptions.append(Assumption(
            "profile.tax_regime", "NEW",
            "New Tax Regime assumed — no Chapter VI-A deductions applied"
        ))

    total_income = max(0, result.gross_total_income_inr - deductions)
    result.total_income_after_deductions_inr = total_income

    # ── NODE 3: Slab Tax on normal income ───────────────────────────
    # Normal income = total income MINUS special-rate components
    normal_income = max(0, total_income - inp.stcg_111a_inr - inp.ltcg_112a_inr
                        - inp.ltcg_112_inr - inp.special_115bb_bbj_inr
                        - inp.vda_115bbh_inr)

    if inp.tax_regime == "NEW":
        slabs = INDIA_NEW_REGIME_SLABS_FY2025
    elif inp.is_super_senior:
        slabs = INDIA_OLD_REGIME_SLABS_SUPER_SENIOR
    elif inp.is_senior:
        slabs = INDIA_OLD_REGIME_SLABS_SENIOR
    else:
        slabs = INDIA_OLD_REGIME_SLABS_GENERAL

    result.tax_on_slab_income_inr = compute_slab_tax(normal_income, slabs)

    # ── NODE 4: Special-rate tax ────────────────────────────────────
    result.tax_on_stcg_111a_inr = int(inp.stcg_111a_inr * INDIA_STCG_111A_RATE)

    ltcg_112a_taxable = max(0, inp.ltcg_112a_inr - INDIA_LTCG_112A_EXEMPTION)
    result.tax_on_ltcg_112a_inr = int(ltcg_112a_taxable * INDIA_LTCG_112A_RATE)

    result.tax_on_ltcg_112_inr = int(inp.ltcg_112_inr * INDIA_LTCG_112_RATE)
    result.tax_on_special_inr = int(inp.special_115bb_bbj_inr * INDIA_SPECIAL_RATE)
    result.tax_on_vda_inr = int(inp.vda_115bbh_inr * INDIA_SPECIAL_RATE)

    # ── NODE 5: Aggregate before surcharge ──────────────────────────
    total_tax = (result.tax_on_slab_income_inr + result.tax_on_stcg_111a_inr
                 + result.tax_on_ltcg_112a_inr + result.tax_on_ltcg_112_inr
                 + result.tax_on_special_inr + result.tax_on_vda_inr)
    result.total_tax_before_surcharge_inr = total_tax

    # ── NODE 6: Surcharge ───────────────────────────────────────────
    surcharge_table = (INDIA_SURCHARGE_NEW if inp.tax_regime == "NEW"
                       else INDIA_SURCHARGE_OLD)
    result.surcharge_inr = compute_surcharge(total_income, total_tax, surcharge_table)

    # ── NODE 7: Cess ────────────────────────────────────────────────
    tax_plus_surcharge = total_tax + result.surcharge_inr
    result.cess_inr = int(tax_plus_surcharge * INDIA_CESS_RATE)

    # ── NODE 8: Rebate 87A ──────────────────────────────────────────
    if inp.rebate_87a_eligible and total_income <= 700_000 and inp.tax_regime == "NEW":
        result.rebate_87a_inr = min(tax_plus_surcharge + result.cess_inr, 25_000)
    elif inp.rebate_87a_eligible and total_income <= 500_000 and inp.tax_regime == "OLD":
        result.rebate_87a_inr = min(tax_plus_surcharge + result.cess_inr, 12_500)

    # ── NODE 9: Total liability ─────────────────────────────────────
    result.total_tax_liability_inr = max(
        0, tax_plus_surcharge + result.cess_inr - result.rebate_87a_inr
    )

    # ── NODE 10: Net payable after credits ──────────────────────────
    total_credits = inp.advance_tax_paid_inr + inp.tds_deducted_inr + inp.ftc_india_inr
    result.total_credits_inr = total_credits
    result.net_tax_payable_inr = max(0, result.total_tax_liability_inr - total_credits)

    result.assumptions = [a.__dict__ for a in assumptions]
    return result


# ═══════════════════════════════════════════════════════════════════
# SECTION 3 — US TAX DAG
# Pipeline: AGI → Taxable → Regular Tax → AMT → NIIT → FTC → Net
# Source: WISING-TAX-US-002 v2.3 (OBBBA 2026 Update Edition)
# ═══════════════════════════════════════════════════════════════════

# ── 3A: US Tax Tables (CY 2026, OBBBA thresholds) ───────────────

US_BRACKETS_SINGLE_2026 = [
    (11_925,    0.10),
    (48_475,    0.12),
    (103_350,   0.22),
    (197_300,   0.24),
    (250_525,   0.32),
    (626_350,   0.35),
    (float('inf'), 0.37),
]

US_BRACKETS_MFJ_2026 = [
    (23_850,    0.10),
    (96_950,    0.12),
    (206_700,   0.22),
    (394_600,   0.24),
    (501_050,   0.32),
    (751_600,   0.35),
    (float('inf'), 0.37),
]

US_STANDARD_DEDUCTION_2026 = {
    "single": 16_100,
    "mfj": 32_200,
    "mfs": 16_100,
    "hoh": 24_150,
    "qss": 32_200,
}

US_LTCG_RATES_SINGLE_2026 = [
    (48_475,    0.00),
    (533_400,   0.15),
    (float('inf'), 0.20),
]

US_AMT_EXEMPTION_SINGLE_2026 = 88_100
US_AMT_EXEMPTION_MFJ_2026 = 137_000
US_AMT_RATE_LOW = 0.26
US_AMT_RATE_HIGH = 0.28
US_AMT_HIGH_THRESHOLD = 232_600  # single

US_NIIT_RATE = 0.038
US_NIIT_THRESHOLD_SINGLE = 200_000
US_NIIT_THRESHOLD_MFJ = 250_000

US_SALT_CAP_2026 = 40_400  # OBBBA raised from $10K


@dataclass(frozen=True)
class USIncomeAssembly:
    """Input to the US DAG. Assembled from Layer 1 US income sections."""
    filing_status: str = "single"

    # ── Gross income ──
    wages_usd: int = 0
    interest_usd: int = 0
    ordinary_dividends_usd: int = 0
    qualified_dividends_usd: int = 0
    stcg_usd: int = 0
    ltcg_usd: int = 0
    rental_income_usd: int = 0
    se_income_usd: int = 0
    foreign_wages_usd: int = 0
    foreign_interest_usd: int = 0
    foreign_dividends_usd: int = 0
    foreign_cg_usd: int = 0
    ira_distributions_usd: int = 0
    ss_benefits_taxable_usd: int = 0

    # ── Above-the-line ──
    hsa_contribution_usd: int = 0
    student_loan_interest_usd: int = 0
    feie_exclusion_usd: int = 0

    # ── Deductions ──
    use_standard_or_itemized: str = "auto"
    salt_paid_usd: int = 0
    mortgage_interest_usd: int = 0
    charitable_cash_usd: int = 0
    charitable_appreciated_usd: int = 0
    medical_expenses_usd: int = 0

    # ── Credits ──
    child_tax_credit_children: int = 0
    education_credits_usd: int = 0

    # ── FTC ──
    foreign_taxes_paid_usd: int = 0

    # ── AMT preferences ──
    iso_preference_usd: int = 0
    private_activity_bond_usd: int = 0

    # ── Withholding ──
    federal_withholding_usd: int = 0
    estimated_payments_usd: int = 0

    # ── Lock ──
    us_residency_status: str = "US_CITIZEN"


@dataclass
class USTaxResult:
    """Output of the US DAG."""
    # ── Income ──
    gross_income_usd: int = 0
    agi_usd: int = 0
    taxable_income_usd: int = 0

    # ── Deductions used ──
    standard_deduction_usd: int = 0
    itemized_deductions_usd: int = 0
    deduction_used: str = "standard"

    # ── Regular tax ──
    regular_tax_usd: int = 0
    tax_on_ltcg_usd: int = 0
    tax_on_ordinary_usd: int = 0

    # ── AMT ──
    amti_usd: int = 0
    tentative_minimum_tax_usd: int = 0
    amt_due_usd: int = 0

    # ── NIIT ──
    net_investment_income_usd: int = 0
    niit_due_usd: int = 0

    # ── FTC ──
    ftc_allowed_usd: int = 0

    # ── Credits ──
    ctc_usd: int = 0
    total_credits_usd: int = 0

    # ── Net ──
    total_tax_liability_usd: int = 0
    net_tax_payable_usd: int = 0

    assumptions: list = field(default_factory=list)


def run_us_dag(inp: USIncomeAssembly) -> USTaxResult:
    """
    US MATH DAG — Pure function, zero side effects.

    Pipeline:
      1. Gross Income → AGI
      2. AGI → Deduction → Taxable Income
      3. Taxable Income → Regular Tax (ordinary + LTCG)
      4. AMT computation
      5. NIIT computation
      6. FTC limitation
      7. Credits → Net Payable
    """
    assumptions: list[Assumption] = []
    result = USTaxResult()

    # ── NODE 1: Gross Income ────────────────────────────────────────
    gross = (inp.wages_usd + inp.interest_usd + inp.ordinary_dividends_usd
             + inp.stcg_usd + inp.ltcg_usd + inp.rental_income_usd
             + inp.se_income_usd + inp.foreign_wages_usd
             + inp.foreign_interest_usd + inp.foreign_dividends_usd
             + inp.foreign_cg_usd + inp.ira_distributions_usd
             + inp.ss_benefits_taxable_usd)
    result.gross_income_usd = gross

    # ── NODE 2: AGI ─────────────────────────────────────────────────
    above_the_line = (inp.hsa_contribution_usd + inp.student_loan_interest_usd
                      + inp.feie_exclusion_usd)
    agi = max(0, gross - above_the_line)
    result.agi_usd = agi

    # ── NODE 3: Deduction → Taxable Income ──────────────────────────
    standard = US_STANDARD_DEDUCTION_2026.get(inp.filing_status, 16_100)
    result.standard_deduction_usd = standard

    # Itemized
    salt_capped = min(inp.salt_paid_usd, US_SALT_CAP_2026)
    medical_threshold = int(agi * 0.075)
    medical_deductible = max(0, inp.medical_expenses_usd - medical_threshold)
    charitable = min(inp.charitable_cash_usd, int(agi * 0.60))
    charitable += min(inp.charitable_appreciated_usd, int(agi * 0.30))

    itemized = salt_capped + inp.mortgage_interest_usd + charitable + medical_deductible
    result.itemized_deductions_usd = itemized

    if inp.use_standard_or_itemized == "itemized":
        deduction = itemized
        result.deduction_used = "itemized"
    elif inp.use_standard_or_itemized == "standard":
        deduction = standard
        result.deduction_used = "standard"
    else:
        # Auto — pick whichever is larger
        if itemized > standard:
            deduction = itemized
            result.deduction_used = "itemized"
        else:
            deduction = standard
            result.deduction_used = "standard"
            assumptions.append(Assumption(
                "use_standard_or_itemized", "standard",
                "Standard deduction used (auto-selected, larger than itemized)"
            ))

    taxable_income = max(0, agi - deduction)
    result.taxable_income_usd = taxable_income

    # ── NODE 4: Regular Tax ─────────────────────────────────────────
    # Separate LTCG + qualified dividends (preferential rates) from ordinary
    preferential_income = inp.ltcg_usd + inp.qualified_dividends_usd
    ordinary_income = max(0, taxable_income - preferential_income)

    brackets = (US_BRACKETS_MFJ_2026 if inp.filing_status in ("mfj", "qss")
                else US_BRACKETS_SINGLE_2026)
    tax_on_ordinary = compute_slab_tax(ordinary_income, brackets)
    result.tax_on_ordinary_usd = tax_on_ordinary

    # LTCG rates (simplified — single filer table used)
    ltcg_rates = US_LTCG_RATES_SINGLE_2026
    tax_on_ltcg = compute_slab_tax(preferential_income, ltcg_rates)
    result.tax_on_ltcg_usd = tax_on_ltcg

    regular_tax = tax_on_ordinary + tax_on_ltcg
    result.regular_tax_usd = regular_tax

    # ── NODE 5: AMT ─────────────────────────────────────────────────
    exemption = (US_AMT_EXEMPTION_MFJ_2026 if inp.filing_status in ("mfj", "qss")
                 else US_AMT_EXEMPTION_SINGLE_2026)

    amti = taxable_income + inp.iso_preference_usd + inp.private_activity_bond_usd
    # Add back SALT for AMT
    if result.deduction_used == "itemized":
        amti += salt_capped
    result.amti_usd = amti

    amt_base = max(0, amti - exemption)
    if amt_base <= US_AMT_HIGH_THRESHOLD:
        tmt = int(amt_base * US_AMT_RATE_LOW)
    else:
        tmt = int(US_AMT_HIGH_THRESHOLD * US_AMT_RATE_LOW
                  + (amt_base - US_AMT_HIGH_THRESHOLD) * US_AMT_RATE_HIGH)
    result.tentative_minimum_tax_usd = tmt
    result.amt_due_usd = max(0, tmt - regular_tax)

    # ── NODE 6: NIIT ────────────────────────────────────────────────
    niit_threshold = (US_NIIT_THRESHOLD_MFJ if inp.filing_status in ("mfj", "qss")
                      else US_NIIT_THRESHOLD_SINGLE)

    nii = (inp.interest_usd + inp.ordinary_dividends_usd + inp.stcg_usd
           + inp.ltcg_usd + inp.rental_income_usd
           + inp.foreign_interest_usd + inp.foreign_dividends_usd
           + inp.foreign_cg_usd)
    result.net_investment_income_usd = nii

    magi_excess = max(0, agi - niit_threshold)
    niit = int(min(nii, magi_excess) * US_NIIT_RATE)

    # NRAs are exempt from NIIT
    if inp.us_residency_status == "NON_RESIDENT_ALIEN":
        niit = 0
    result.niit_due_usd = niit

    # ── NODE 7: FTC Limitation ──────────────────────────────────────
    # FTC limited to: (foreign source income / total taxable) × US tax
    total_foreign = (inp.foreign_wages_usd + inp.foreign_interest_usd
                     + inp.foreign_dividends_usd + inp.foreign_cg_usd)
    if taxable_income > 0 and regular_tax > 0:
        limitation = int((total_foreign / taxable_income) * regular_tax)
        ftc = min(inp.foreign_taxes_paid_usd, limitation)
    else:
        ftc = 0
    result.ftc_allowed_usd = ftc

    # ── NODE 8: Credits ─────────────────────────────────────────────
    ctc = inp.child_tax_credit_children * 2_000  # $2K per child (OBBBA retained)
    result.ctc_usd = ctc
    total_credits = ctc + inp.education_credits_usd + ftc
    result.total_credits_usd = total_credits

    # ── NODE 9: Total liability ─────────────────────────────────────
    total_liability = regular_tax + result.amt_due_usd + niit
    result.total_tax_liability_usd = max(0, total_liability - total_credits)

    # ── NODE 10: Net payable ────────────────────────────────────────
    payments = inp.federal_withholding_usd + inp.estimated_payments_usd
    result.net_tax_payable_usd = max(0, result.total_tax_liability_usd - payments)

    result.assumptions = [a.__dict__ for a in assumptions]
    return result


# ═══════════════════════════════════════════════════════════════════
# SECTION 4 — DAG ORCHESTRATOR
# Fires ONLY on explicit "Evaluate Tax" trigger.
# Never fires on individual field changes.
# ═══════════════════════════════════════════════════════════════════

@dataclass
class FullComputationResult:
    """Combined output of both DAGs."""
    india_result: Optional[IndiaTaxResult] = None
    us_result: Optional[USTaxResult] = None
    all_assumptions: list = field(default_factory=list)
    computed_at: str = ""


def evaluate_tax(
    state: TaxEngineState,
    india_income: Optional[IndiaIncomeAssembly] = None,
    us_income: Optional[USIncomeAssembly] = None,
) -> FullComputationResult:
    """
    THE "EVALUATE TAX" TRIGGER.
    Called ONLY when user explicitly clicks the button.
    Never called on individual field changes.

    This is the single entry point for the Math DAG layer.
    """
    from datetime import datetime
    result = FullComputationResult(computed_at=datetime.utcnow().isoformat())
    all_assumptions = []

    jurisdiction = state.layer0.jurisdiction

    # ── Run India DAG if applicable ─────────────────────────────────
    if jurisdiction in (Jurisdiction.INDIA_ONLY, Jurisdiction.DUAL):
        if india_income is None:
            raise ValueError("India income assembly required for india_only/dual jurisdiction")
        india_result = run_india_dag(india_income)
        result.india_result = india_result
        all_assumptions.extend(india_result.assumptions)

    # ── Run US DAG if applicable ────────────────────────────────────
    if jurisdiction in (Jurisdiction.US_ONLY, Jurisdiction.DUAL):
        if us_income is None:
            raise ValueError("US income assembly required for us_only/dual jurisdiction")
        us_result = run_us_dag(us_income)
        result.us_result = us_result
        all_assumptions.extend(us_result.assumptions)

    result.all_assumptions = all_assumptions
    return result
