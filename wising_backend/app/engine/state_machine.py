"""
WISING TAX ENGINE — app/engine/state_machine.py
WizardStateMachine — XState-equivalent Python FSM.
Source: sprint1_input_layer_PATCHED.py Section 6.

State flow:
  LAYER0_WIZARD ──[submit]──→ LAYER0_COMPLETE
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
        INDIA_RESIDENCY   US_RESIDENCY   JURISDICTION_NONE
                │               │
                ▼               ▼
         INDIA_LOCKED      US_LOCKED
                │               │
                └───────┬───────┘
                        ▼
                INCOME_SECTIONS
                        │
                        ▼
               READY_TO_EVALUATE

Any upstream change (e.g., india_days) triggers reactive
re-evaluation of the router and locks.
"""
from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime
from typing import Any

from app.engine.india_residency import RS001Result, compute_ltac, evaluate_india_residency
from app.engine.layer0_router import evaluate_jurisdiction
from app.engine.us_residency import SPTResult, evaluate_us_residency
from app.models.india_residency import IndiaResidencyDetail
from app.models.layer0 import Jurisdiction, Layer0State
from app.models.tax_state import TaxEngineState, WizardPhase
from app.models.us_residency import USResidencyDetail


@dataclass
class StateTransition:
    """Audit log entry for every state change."""
    from_phase: WizardPhase
    to_phase: WizardPhase
    trigger: str            # e.g. "LAYER0_SUBMIT", "INDIA_LOCK_REFIRE"
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    payload: dict = field(default_factory=dict)


class WizardStateMachine:
    """
    Progressive disclosure wizard state machine.
    Governs wizard progression with reactive re-evaluation on field changes.
    """

    def __init__(self, state: TaxEngineState):
        self.state = state
        self.transitions: list[StateTransition] = []

    def _transition(
        self,
        to: WizardPhase,
        trigger: str,
        payload: dict | None = None,
    ) -> None:
        """Record transition and update wizard phase."""
        t = StateTransition(
            from_phase=self.state.wizard_phase,
            to_phase=to,
            trigger=trigger,
            payload=payload or {},
        )
        self.transitions.append(t)
        self.state.events.append(asdict(t))
        self.state.wizard_phase = to
        self.state.updated_at = datetime.utcnow().isoformat()

    # ── Layer 0 operations ──────────────────────────────────────────

    def patch_layer0(self, updates: dict[str, Any]) -> Layer0State:
        """
        Apply partial updates to Layer 0 fields.
        Reactively re-evaluates jurisdiction.
        Supports incremental state — only patch what changed.
        """
        l0 = self.state.layer0
        for key, value in updates.items():
            if hasattr(l0, key):
                setattr(l0, key, value)

        # Re-evaluate jurisdiction on every Layer 0 change
        self.state.layer0 = evaluate_jurisdiction(l0)
        return self.state.layer0

    def submit_layer0(self) -> Jurisdiction:
        """
        Finalize Layer 0 and transition to next phase.
        Returns the jurisdiction for frontend routing.
        """
        l0 = evaluate_jurisdiction(self.state.layer0)
        self.state.layer0 = l0

        self._transition(
            WizardPhase.LAYER0_COMPLETE,
            "LAYER0_SUBMIT",
            {"jurisdiction": l0.jurisdiction.value if l0.jurisdiction else "none"},
        )

        j = l0.jurisdiction
        if j == Jurisdiction.NONE:
            self._transition(WizardPhase.JURISDICTION_NONE, "JURISDICTION_NONE_REACHED")
        elif j in (Jurisdiction.INDIA_ONLY, Jurisdiction.DUAL):
            # Initialize India residency detail with pre-fills from L0
            self.state.india_residency = IndiaResidencyDetail(
                days_in_india_current_year=l0.india_days
            )
            self._transition(WizardPhase.INDIA_RESIDENCY, "INDIA_RESIDENCY_STARTED")
        elif j == Jurisdiction.US_ONLY:
            self.state.us_residency = USResidencyDetail(
                is_us_citizen=l0.is_us_citizen,
                has_green_card=l0.has_green_card,
                us_days_current_year=l0.us_days,
            )
            self._transition(WizardPhase.US_RESIDENCY, "US_RESIDENCY_STARTED")

        return j

    # ── India residency lock ────────────────────────────────────────

    def patch_india_residency(self, updates: dict[str, Any]) -> IndiaResidencyDetail:
        """
        Apply partial updates to India residency fields.
        Does NOT auto-fire lock — lock fires on explicit submit
        or reactive re-evaluation.
        """
        r = self.state.india_residency
        if r is None:
            raise ValueError(
                "India residency not initialized "
                "(jurisdiction does not include India)"
            )

        for key, value in updates.items():
            if hasattr(r, key):
                setattr(r, key, value)

        return r

    def fire_india_lock(self) -> RS001Result:
        """
        Compute India residency lock (RS-001).
        Stores result and transitions wizard phase.
        """
        r = self.state.india_residency
        if r is None:
            raise ValueError("India residency not initialized")

        # Compute LTAC derived field
        r.liable_to_tax_in_another_country_being_indian_citizen = compute_ltac(
            self.state.layer0.is_indian_citizen,
            self.state.layer0.liable_to_tax_in_another_country,
        )

        # Run RS-001
        result = evaluate_india_residency(self.state.layer0, r)
        r.final_india_residency_status = result.status

        self._transition(
            WizardPhase.INDIA_LOCKED,
            "INDIA_LOCK_SET",
            {
                "status": result.status.value,
                "path_id": result.path_id,
                "statutory_basis": result.statutory_basis,
            },
        )

        # If dual jurisdiction, start US residency next
        if self.state.layer0.jurisdiction == Jurisdiction.DUAL:
            self.state.us_residency = USResidencyDetail(
                is_us_citizen=self.state.layer0.is_us_citizen,
                has_green_card=self.state.layer0.has_green_card,
                us_days_current_year=self.state.layer0.us_days,
            )
            self._transition(WizardPhase.US_RESIDENCY, "US_RESIDENCY_STARTED_DUAL")
        elif self.state.layer0.jurisdiction == Jurisdiction.INDIA_ONLY:
            self._transition(WizardPhase.INCOME_SECTIONS, "INDIA_ONLY_LOCK_COMPLETE")

        return result

    # ── US residency lock ───────────────────────────────────────────

    def patch_us_residency(self, updates: dict[str, Any]) -> USResidencyDetail:
        """Apply partial updates to US residency fields."""
        r = self.state.us_residency
        if r is None:
            raise ValueError("US residency not initialized")

        for key, value in updates.items():
            if hasattr(r, key):
                setattr(r, key, value)

        return r

    def fire_us_lock(self) -> SPTResult:
        """Compute US residency lock (SPT cascade)."""
        r = self.state.us_residency
        if r is None:
            raise ValueError("US residency not initialized")

        result = evaluate_us_residency(r)
        r.spt_day_count_weighted = result.spt_weighted
        r.spt_test_met = result.spt_met
        r.final_us_residency_status = result.status

        self._transition(
            WizardPhase.US_LOCKED,
            "US_LOCK_SET",
            {"status": result.status.value, "priority": result.priority},
        )

        # Both locks set → advance to income sections
        if (
            self.state.india_residency
            and self.state.india_residency.final_india_residency_status
        ):
            self._transition(WizardPhase.INCOME_SECTIONS, "BOTH_LOCKS_SET")
        elif self.state.layer0.jurisdiction == Jurisdiction.US_ONLY:
            self._transition(WizardPhase.INCOME_SECTIONS, "US_LOCK_ONLY")

        return result

    # ── Reactive re-evaluation ──────────────────────────────────────

    def refire_on_upstream_change(self, layer0_updates: dict[str, Any]) -> dict:
        """
        Called when user changes an upstream field (e.g., india_days).
        Reactively re-evaluates:
          1. Layer 0 jurisdiction
          2. India lock (if applicable)
          3. US lock (if applicable)

        Returns a diff of what changed for the frontend alert system.
        """
        old_jurisdiction = self.state.layer0.jurisdiction
        old_india_lock = (
            self.state.india_residency.final_india_residency_status
            if self.state.india_residency
            else None
        )
        old_us_lock = (
            self.state.us_residency.final_us_residency_status
            if self.state.us_residency
            else None
        )

        # Step 1: Re-evaluate Layer 0
        self.patch_layer0(layer0_updates)
        new_l0 = self.state.layer0
        new_jurisdiction = new_l0.jurisdiction

        diff: dict = {}

        # Step 2: Check jurisdiction change
        if new_jurisdiction != old_jurisdiction:
            diff["jurisdiction_changed"] = {
                "from": old_jurisdiction.value if old_jurisdiction else None,
                "to": new_jurisdiction.value if new_jurisdiction else None,
            }
            self._transition(
                WizardPhase.LAYER0_COMPLETE,
                "JURISDICTION_REFIRE",
                diff["jurisdiction_changed"],
            )

        # Step 3: Re-fire India lock if residency inputs changed
        if self.state.india_residency and "india_days" in layer0_updates:
            self.state.india_residency.days_in_india_current_year = new_l0.india_days
            result = evaluate_india_residency(new_l0, self.state.india_residency)
            self.state.india_residency.final_india_residency_status = result.status

            if result.status != old_india_lock:
                diff["india_lock_changed"] = {
                    "from": old_india_lock.value if old_india_lock else None,
                    "to": result.status.value,
                    "path_id": result.path_id,
                }
                self._transition(
                    self.state.wizard_phase,
                    "INDIA_LOCK_REFIRE",
                    diff["india_lock_changed"],
                )

        # Step 4: Re-fire US lock if us_days changed
        if self.state.us_residency and "us_days" in layer0_updates:
            self.state.us_residency.us_days_current_year = new_l0.us_days
            result = evaluate_us_residency(self.state.us_residency)
            self.state.us_residency.final_us_residency_status = result.status

            if result.status != old_us_lock:
                diff["us_lock_changed"] = {
                    "from": old_us_lock.value if old_us_lock else None,
                    "to": result.status.value,
                }

        return diff

    # ── Section visibility (downstream gate evaluation) ─────────────

    def get_visible_sections(self) -> dict[str, bool]:
        """
        Evaluate which Layer 1 sections are visible based on the
        residency locks. Direct translation of unlock logic from
        schema header comments.
        """
        from app.models.india_residency import IndiaResidency
        from app.models.us_residency import USResidency

        india_lock = (
            self.state.india_residency.final_india_residency_status
            if self.state.india_residency
            else None
        )
        us_lock = (
            self.state.us_residency.final_us_residency_status
            if self.state.us_residency
            else None
        )

        sections: dict[str, bool] = {}

        # ── India sections (from layer1_india header) ──
        if india_lock:
            sections["india_profile"] = True
            sections["india_dtaa"] = india_lock == IndiaResidency.NR
            sections["india_compliance_docs"] = india_lock == IndiaResidency.NR
            sections["india_bank_accounts"] = True
            sections["india_property"] = True
            sections["india_financial_holdings"] = True
            sections["india_commodities"] = True
            sections["india_unlisted_equity"] = True
            sections["india_share_buyback"] = True
            sections["india_domestic_income"] = True
            sections["india_other_sources"] = True
            sections["india_deductions"] = india_lock in (
                IndiaResidency.RNOR,
                IndiaResidency.ROR,
            )
            sections["india_carry_forward_losses"] = True
            sections["india_lrs_outbound"] = india_lock == IndiaResidency.ROR
            sections["india_tax_credits"] = True

        # ── US sections (from layer1_us header) ──
        if us_lock:
            sections["us_profile"] = True
            sections["us_state_residency"] = True
            sections["us_income_us_source"] = True
            sections["us_income_foreign_source"] = us_lock in (
                USResidency.US_CITIZEN,
                USResidency.RESIDENT_ALIEN,
                USResidency.DUAL_STATUS,
            )
            sections["us_equity_compensation"] = True
            sections["us_feie"] = us_lock in (
                USResidency.US_CITIZEN,
                USResidency.RESIDENT_ALIEN,
            )
            sections["us_bank_accounts"] = True
            sections["us_financial_holdings"] = True
            sections["us_real_estate"] = True
            sections["us_retirement_accounts"] = True
            sections["us_foreign_entities"] = True
            sections["us_foreign_gifts"] = True
            sections["us_deductions_credits"] = True
            sections["us_amt"] = True
            sections["us_niit"] = True
            sections["us_ftc"] = True
            sections["us_withholding"] = True
            sections["us_nra_specific"] = us_lock == USResidency.NON_RESIDENT_ALIEN

        return sections
