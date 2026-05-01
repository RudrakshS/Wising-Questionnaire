"""
WISING TAX ENGINE — app/api/wizard.py
GET /api/wizard/schema — Returns field_registry rows for active jurisdiction.
Contract: WISING-AI-CONTRACT v1.0.
"""
from __future__ import annotations

from typing import Optional
import asyncpg
from fastapi import APIRouter, Depends, Query
from app.database import get_db
from app.repository.field_registry_repo import FieldRegistryRepository

router = APIRouter()


@router.get("/api/wizard/schema")
async def get_wizard_schema(
    jurisdiction: Optional[str] = Query(None),
    pool: asyncpg.Pool = Depends(get_db),
) -> dict:
    """
    GET /api/wizard/schema
    Returns field_registry rows ordered by (section_order, wizard_order).
    Filters by active jurisdiction when provided.
    """
    repo = FieldRegistryRepository(pool)
    all_fields = await repo.get_all_fields()

    if jurisdiction:
        filtered = []
        for f in all_fields:
            schema = f["schema_name"]
            if schema == "layer0":
                filtered.append(f)
            elif schema == "layer1_india" and jurisdiction in ("india_only", "dual"):
                filtered.append(f)
            elif schema == "layer1_us" and jurisdiction in ("us_only", "dual"):
                filtered.append(f)
        fields = filtered
    else:
        fields = all_fields

    return {
        "fields": fields,
        "total": len(fields),
        "jurisdiction": jurisdiction,
    }
