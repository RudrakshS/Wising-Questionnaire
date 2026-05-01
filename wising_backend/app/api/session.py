"""
WISING TAX ENGINE — app/api/session.py
POST /api/session — Create or resume a tax session.
Contract: WISING-AI-CONTRACT v1.0 Section 1.
"""
from __future__ import annotations

import uuid
from typing import Optional

import asyncpg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.database import get_db
from app.repository.event_repo import EventRepository
from app.repository.field_registry_repo import FieldRegistryRepository
from app.repository.snapshot_repo import SnapshotRepository

router = APIRouter()


class CreateSessionRequest(BaseModel):
    user_id: str
    tax_year: str       # e.g. "FY2025-26"
    timezone: str = "Asia/Kolkata"


class SessionResponse(BaseModel):
    session_id: str
    tax_year_id: str
    wizard_phase: str
    completion: dict
    next_required_fields: list[dict]


@router.post("/session", response_model=SessionResponse, status_code=201)
async def create_session(
    req: CreateSessionRequest,
    pool: asyncpg.Pool = Depends(get_db),
) -> SessionResponse:
    """
    POST /api/session
    Creates a new tax session (snapshot).
    Returns session_id, tax_year_id, initial wizard state.
    """
    # Derive a stable tax_year_id from the tax_year string
    tax_year_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"wising.{req.tax_year}"))

    snapshot_repo = SnapshotRepository(pool)
    event_repo = EventRepository(pool)
    registry_repo = FieldRegistryRepository(pool)

    # Check if active snapshot already exists — if so, resume it
    existing = await snapshot_repo.get_active_snapshot(req.user_id, tax_year_id)
    if existing:
        session_id = existing["id"]
    else:
        session_id = await snapshot_repo.create_snapshot(req.user_id, tax_year_id)
        await event_repo.append_event(
            req.user_id,
            tax_year_id,
            "SESSION_CREATED",
            {"session_id": session_id, "tax_year": req.tax_year},
        )

    # Get first required field to ask
    all_fields = await registry_repo.get_all_fields()
    next_required = _get_first_required_fields(all_fields)

    return SessionResponse(
        session_id=session_id,
        tax_year_id=tax_year_id,
        wizard_phase="layer0_wizard",
        completion={
            "percentage": 0,
            "filled_required": 0,
            "total_required": _count_layer0_required(all_fields),
            "is_approximation": True,
            "filing_ready": False,
        },
        next_required_fields=next_required,
    )


def _get_first_required_fields(fields: list[dict]) -> list[dict]:
    """Return the first required field in Layer 0 to ask."""
    result = []
    for f in fields:
        if (
            f["schema_name"] == "layer0"
            and f["classification"] == "REQUIRED"
            and f.get("enabled_if") is None
        ):
            result.append({
                "field_path": f["field_path"],
                "friendly_label": f["friendly_label"],
                "input_type": f["input_type"],
                "section": f["section"],
            })
            if len(result) >= 1:
                break
    return result


def _count_layer0_required(fields: list[dict]) -> int:
    """Count REQUIRED fields in Layer 0 (no conditional gate)."""
    return sum(
        1 for f in fields
        if f["schema_name"] == "layer0" and f["classification"] == "REQUIRED"
    )
