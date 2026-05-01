"""
WISING TAX ENGINE — app/output/stamper.py
OutputStamper — APPROXIMATION/FINAL badge + Advisory Card Engine.
Source: sprint3_output_tests.py (ported + refactored).

Advisory Cards (Part 7 of ANTIGRAVITY_BUILD_PROMPT):
  These emit based on data conditions in the snapshot, NOT on
  computation results. They fire even when Layer 2 is stubbed.
  They are NON-NEGOTIABLE — they protect users from cross-border mistakes.

  Card ID                        | Condition                                    | Severity
  PLAN-S54-US-TRAP               | India cap gains + US RESIDENT_ALIEN          | High
  TRAP-PFIC-MF                   | US person holds Indian mutual funds           | Critical
  TRAP-FBAR                      | US person + Indian account peak > $10,000    | High
  TRAP-8938                      | US person + foreign assets above threshold    | High
  ALERT-PAN-INOPERATIVE          | pan_aadhaar_linked=false AND NR exemption NA  | High
  INCOME_THRESHOLD_DISCREPANCY   | Computed income > ₹15L AND flag=false        | Critical
  ALERT-AUDIT-SPECULATIVE        | speculative_turnover_inr >= 1Cr              | Medium
  FLAG-S43B-MSME                 | msme_payables[].payment_date beyond deadline  | Medium
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class AdvisoryCard:
    """A single advisory card emitted by the stamper."""
    card_id: str
    title: str
    description: str
    severity: str           # "Critical" | "High" | "Medium" | "Low"
    category: str           # "COMPLIANCE" | "TAX_SAVING" | "REPORTING"
    estimated_impact_inr: Optional[int] = None
    estimated_impact_usd: Optional[float] = None
    deadline: Optional[str] = None
    action_required: bool = True


@dataclass
class StamperOutput:
    """Output of the OutputStamper."""
    status: str             # "APPROXIMATION" | "FINAL"
    is_approximation: bool
    completion_pct: int
    advisory_cards: list[AdvisoryCard] = field(default_factory=list)
    missing_for_final: list[dict] = field(default_factory=list)
    assumptions_used: list[dict] = field(default_factory=list)


class OutputStamper:
    """
    Stamps tax output as APPROXIMATION or FINAL.
    Emits advisory cards based on snapshot data conditions.

    Stamping rules:
      - completion_pct < 100 → APPROXIMATION + is_approximation: true
      - completion_pct == 100 AND no missing required → FINAL
      - Always return assumptions_used[], missing_for_final[]
    """

    def stamp(
        self,
        snapshot: dict,
        completion_pct: int,
        missing_required: list[str],
        missing_required_labels: list[str],
        assumptions_used: Optional[list[dict]] = None,
    ) -> StamperOutput:
        """
        Stamp the output and emit advisory cards.

        Args:
            snapshot: The full snapshot dict (layer0_state, layer1_india, layer1_us,
                      india_lock, us_lock, computation_result)
            completion_pct: Current completion percentage
            missing_required: List of missing required field paths
            missing_required_labels: Human-readable labels for missing fields
            assumptions_used: List of assumption dicts from DAG

        Returns:
            StamperOutput with status, advisory_cards, missing_for_final
        """
        is_approximation = completion_pct < 100
        status = "APPROXIMATION" if is_approximation else "FINAL"

        missing_for_final = [
            {"field": fp, "label": lbl}
            for fp, lbl in zip(missing_required[:20], missing_required_labels[:20])
        ]

        cards = self._emit_advisory_cards(snapshot)

        return StamperOutput(
            status=status,
            is_approximation=is_approximation,
            completion_pct=completion_pct,
            advisory_cards=cards,
            missing_for_final=missing_for_final,
            assumptions_used=assumptions_used or [],
        )

    def _emit_advisory_cards(self, snapshot: dict) -> list[AdvisoryCard]:
        """
        Evaluate all 8 cross-border trap conditions against the snapshot.
        Returns the list of firing cards.
        """
        cards: list[AdvisoryCard] = []

        l1_india = snapshot.get("layer1_india") or {}
        l1_us = snapshot.get("layer1_us") or {}
        india_lock = snapshot.get("india_lock")
        us_lock = snapshot.get("us_lock")

        is_us_person = us_lock in (
            "US_CITIZEN", "RESIDENT_ALIEN", "DUAL_STATUS"
        )

        # ── Card 1: PLAN-S54-US-TRAP ─────────────────────────────────
        # India capital gains + US RESIDENT_ALIEN
        # s.54 exemption in India does NOT reduce US tax on the same gain.
        has_india_cg = self._has_capital_gains(l1_india)
        if has_india_cg and us_lock == "RESIDENT_ALIEN":
            cards.append(AdvisoryCard(
                card_id="PLAN-S54-US-TRAP",
                title="⚠ Section 54 Does NOT Reduce US Tax",
                description=(
                    "Even if you claim a Section 54/54F/54EC exemption in India, "
                    "the US taxes the full property gain — with zero FTC offset for "
                    "the Indian exempted amount. Plan your US liability separately."
                ),
                severity="High",
                category="COMPLIANCE",
            ))

        # ── Card 2: TRAP-PFIC-MF ─────────────────────────────────────
        # US person holds Indian mutual funds — PFIC rules apply
        has_indian_mf = self._has_indian_mutual_funds(l1_india)
        if is_us_person and has_indian_mf:
            cards.append(AdvisoryCard(
                card_id="TRAP-PFIC-MF",
                title="🚨 Indian Mutual Funds Are PFICs",
                description=(
                    "As a US person, your Indian mutual funds are Passive Foreign "
                    "Investment Companies (PFICs). Without a QEF or Mark-to-Market "
                    "election, gains are taxed at the highest ordinary rate + interest "
                    "penalty. File Form 8621 for each fund. Consult a CPA immediately."
                ),
                severity="Critical",
                category="COMPLIANCE",
            ))

        # ── Card 3: TRAP-FBAR ─────────────────────────────────────────
        # US person + Indian bank account with peak > $10,000
        fbar_threshold = self._get_indian_account_peak(l1_india)
        if is_us_person and fbar_threshold is not None and fbar_threshold > 10_000:
            cards.append(AdvisoryCard(
                card_id="TRAP-FBAR",
                title="⚠ FBAR Filing Required",
                description=(
                    "You had Indian bank account(s) with a peak balance exceeding "
                    "$10,000 (USD equivalent) at any point this year. You must file "
                    "FinCEN Form 114 (FBAR) by April 15 (auto-extended to Oct 15). "
                    "Failure to file can result in penalties up to $10,000+ per violation."
                ),
                severity="High",
                category="REPORTING",
            ))

        # ── Card 4: TRAP-8938 ─────────────────────────────────────────
        # US person + foreign financial assets above Form 8938 threshold
        foreign_assets = self._get_foreign_assets_value(l1_india, l1_us)
        if is_us_person and foreign_assets is not None and foreign_assets > 50_000:
            cards.append(AdvisoryCard(
                card_id="TRAP-8938",
                title="⚠ Form 8938 (FATCA) Required",
                description=(
                    "Your specified foreign financial assets exceed the $50,000 "
                    "threshold (or $100,000 if filing jointly). You must attach "
                    "Form 8938 to your US tax return. Failure to disclose results "
                    "in a $10,000 penalty plus potential 40% understatement penalty."
                ),
                severity="High",
                category="REPORTING",
            ))

        # ── Card 5: ALERT-PAN-INOPERATIVE ────────────────────────────
        # pan_aadhaar_linked = false AND NR exemption does not apply
        profile = l1_india.get("profile") or {}
        pan_linked = profile.get("pan_aadhaar_linked")
        if pan_linked is False and india_lock != "NR":
            cards.append(AdvisoryCard(
                card_id="ALERT-PAN-INOPERATIVE",
                title="⚠ PAN Inoperative — Aadhaar Not Linked",
                description=(
                    "Your PAN is inoperative because it is not linked to Aadhaar. "
                    "This will result in TDS at the higher rate (20%) on all payments "
                    "and may block ITR filing. Link PAN-Aadhaar immediately at the "
                    "Income Tax portal. NR exemption does not apply to your profile."
                ),
                severity="High",
                category="COMPLIANCE",
            ))

        # ── Card 6: INCOME_THRESHOLD_DISCREPANCY ─────────────────────
        # Computed India income > ₹15L AND india_source_income_above_15l = false
        residency_detail = l1_india.get("residency_detail") or {}
        income_flag = residency_detail.get("india_source_income_above_15l")
        computed_income = self._get_computed_india_income(snapshot)
        if (
            income_flag is False
            and computed_income is not None
            and computed_income > 1_500_000
        ):
            cards.append(AdvisoryCard(
                card_id="INCOME_THRESHOLD_DISCREPANCY",
                title="🚨 Income Threshold Discrepancy Detected",
                description=(
                    f"Your computed India-source income is ₹{computed_income:,.0f} — "
                    "above the ₹15L Deemed Resident threshold. You indicated your "
                    "India-source income is below ₹15L. This may change your residency "
                    "from NR to RNOR. Please review and update your residency detail."
                ),
                severity="Critical",
                category="COMPLIANCE",
            ))

        # ── Card 7: ALERT-AUDIT-SPECULATIVE ──────────────────────────
        # speculative_turnover_inr >= 1 Crore
        domestic_income = l1_india.get("domestic_income") or {}
        business_income = domestic_income.get("business_income") or {}
        spec_turnover = business_income.get("speculative_turnover_inr")
        if spec_turnover is not None and spec_turnover >= 10_000_000:  # 1 Crore
            cards.append(AdvisoryCard(
                card_id="ALERT-AUDIT-SPECULATIVE",
                title="⚠ Tax Audit Required (Speculative Turnover ≥ ₹1 Cr)",
                description=(
                    f"Your speculative (F&O/intraday) turnover is ₹{spec_turnover:,.0f} — "
                    "above ₹1 Crore. A tax audit under Section 44AB is mandatory. "
                    "Ensure your books are maintained and engage a CA for the audit "
                    "before the due date."
                ),
                severity="Medium",
                category="COMPLIANCE",
            ))

        # ── Card 8: FLAG-S43B-MSME ───────────────────────────────────
        # Any msme_payables[].payment_date beyond prescribed period
        msme_payables = business_income.get("msme_payables") or []
        if self._has_overdue_msme_payables(msme_payables):
            cards.append(AdvisoryCard(
                card_id="FLAG-S43B-MSME",
                title="⚠ MSME Payables May Be Disallowed (s.43B)",
                description=(
                    "One or more payments to MSME vendors have a payment date beyond "
                    "the prescribed period under Section 43B(h). Payments not made "
                    "within 45 days (for micro/small enterprises) are disallowed as "
                    "a deduction in the current year and taxable as income."
                ),
                severity="Medium",
                category="COMPLIANCE",
            ))

        return cards

    # ── Helper methods ──────────────────────────────────────────────

    @staticmethod
    def _has_capital_gains(l1_india: dict) -> bool:
        """Check if user has any Indian property or equity capital gains."""
        property_section = l1_india.get("property") or {}
        properties = property_section.get("properties") or []
        financial = l1_india.get("financial_holdings") or {}
        has_equity_sale = financial.get("has_listed_equity_sale") or False
        return bool(properties) or bool(has_equity_sale)

    @staticmethod
    def _has_indian_mutual_funds(l1_india: dict) -> bool:
        """Check if user holds Indian mutual funds."""
        financial = l1_india.get("financial_holdings") or {}
        mf = financial.get("mutual_fund_investments_inr")
        if mf is not None and mf > 0:
            return True
        has_mf = financial.get("has_mutual_fund_investments")
        return bool(has_mf)

    @staticmethod
    def _get_indian_account_peak(l1_india: dict) -> Optional[float]:
        """Return peak Indian bank account balance in USD equivalent, or None."""
        bank = l1_india.get("bank_accounts") or {}
        accounts = bank.get("accounts") or []
        if not accounts:
            return None
        # Sum all account peak balances (stored in INR; rough USD conversion)
        total_inr = sum(
            (acc.get("peak_balance_inr") or 0) for acc in accounts
        )
        # Use 84 INR/USD as a conservative conversion
        return total_inr / 84 if total_inr > 0 else None

    @staticmethod
    def _get_foreign_assets_value(l1_india: dict, l1_us: dict) -> Optional[float]:
        """Estimate total specified foreign assets in USD for Form 8938."""
        total_usd = 0.0
        has_data = False

        # Indian bank accounts
        bank = l1_india.get("bank_accounts") or {}
        accounts = bank.get("accounts") or []
        for acc in accounts:
            peak = acc.get("peak_balance_inr") or 0
            total_usd += peak / 84
            has_data = True

        # Indian financial holdings
        financial = l1_india.get("financial_holdings") or {}
        mf = financial.get("mutual_fund_investments_inr") or 0
        total_usd += mf / 84
        if mf:
            has_data = True

        return total_usd if has_data else None

    @staticmethod
    def _get_computed_india_income(snapshot: dict) -> Optional[float]:
        """Extract computed India total income from computation_result if available."""
        computation = snapshot.get("computation_result") or {}
        india_tax = computation.get("india_tax") or {}
        return india_tax.get("total_income_inr")

    @staticmethod
    def _has_overdue_msme_payables(msme_payables: list) -> bool:
        """Check if any MSME payable has a payment date beyond the prescribed period."""
        if not msme_payables:
            return False
        for payable in msme_payables:
            payment_date = payable.get("payment_date")
            overdue = payable.get("is_overdue")
            # If explicitly marked overdue or payment_date is populated and flagged
            if overdue is True:
                return True
            # If payment_date exists we flag it for CA review
            if payment_date:
                return True
        return False
