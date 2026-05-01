"""
WISING TAX ENGINE — app/models/tax_state.py
Root state object + WizardPhase enum.
Source: sprint1_input_layer_PATCHED.py Section 1–2.
schema_version is always "v5.1".
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional

from app.models.india_residency import IndiaResidencyDetail
from app.models.layer0 import Layer0State
from app.models.us_residency import USResidencyDetail


class WizardPhase(str, Enum):
    """Top-level wizard state machine phases — mirrors XState states exactly."""
    LAYER0_WIZARD = "layer0_wizard"
    LAYER0_COMPLETE = "layer0_complete"
    INDIA_RESIDENCY = "india_residency"
    US_RESIDENCY = "us_residency"
    INDIA_LOCKED = "india_locked"
    US_LOCKED = "us_locked"
    INCOME_SECTIONS = "income_sections"
    READY_TO_EVALUATE = "ready_to_evaluate"
    JURISDICTION_NONE = "jurisdiction_none"


@dataclass
class TaxEngineState:
    """
    Root state object persisted to tax_state_snapshots.
    Mirrors the JSONB columns: layer0_state, layer1_india, layer1_us.
    schema_version is locked to "v5.1" per WISING-AI-CONTRACT GAP-002 fix.
    """
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str = ""
    tax_year_id: str = ""

    layer0: Layer0State = field(default_factory=Layer0State)
    india_residency: Optional[IndiaResidencyDetail] = None
    us_residency: Optional[USResidencyDetail] = None

    # ── Wizard state ──
    wizard_phase: WizardPhase = WizardPhase.LAYER0_WIZARD
    completion_pct: int = 0
    is_approximation: bool = True

    # ── Audit trail ──
    events: list = field(default_factory=list)
    schema_version: str = "v5.1"
    created_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
