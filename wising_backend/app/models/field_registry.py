"""
WISING TAX ENGINE — app/models/field_registry.py
Pydantic v2 model for field_registry table rows.
Used by gate_evaluator and completion engine.
"""
from __future__ import annotations

from typing import Any, Optional

from pydantic import BaseModel


class FieldRegistry(BaseModel):
    """Mirrors the field_registry table schema exactly."""
    field_path: str
    schema_name: str          # 'layer0' | 'layer1_india' | 'layer1_us'
    section: str
    classification: str       # 'REQUIRED' | 'CONDITIONAL' | 'OPTIONAL' | 'DERIVED'
    friendly_label: str
    input_type: str           # 'integer' | 'boolean' | 'enum' | 'date' | 'currency' | 'string' | 'array'
    enum_values: Optional[list[Any]] = None  # For enum fields
    enabled_if: Optional[dict] = None        # Structured gate JSON
    default_value: Optional[Any] = None
    default_label: Optional[str] = None
    wizard_order: int = 0
    section_order: int = 0

    model_config = {"from_attributes": True}
