"""
WISING TAX ENGINE — app/api/evaluate.py
POST /api/evaluate/{session_id}/{tax_year_id}
STUBBED per ANTIGRAVITY_BUILD_PROMPT Part 6.
Layer 2 Math DAG is ON HOLD — pending architect review.
"""
from __future__ import annotations

import asyncpg
from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.repository.snapshot_repo import SnapshotRepository
from app.repository.event_repo import EventRepository
from app.output.stamper import OutputStamper

router = APIRouter()


@router.post("/evaluate/{session_id}/{tax_year_id}")
async def evaluate_tax(
    session_id: str,
    tax_year_id: str,
    pool: asyncpg.Pool = Depends(get_db),
) -> dict:
    """
    POST /api/evaluate/{session_id}/{tax_year_id}
    STUB — Layer 2 Math DAG is ON HOLD pending architect review.
    Advisory cards from stamper DO still emit (they read snapshot, not DAG output).
    """
    snap_repo = SnapshotRepository(pool)
    event_repo = EventRepository(pool)

    snapshot = await snap_repo.get_snapshot_by_id(session_id)
    if not snapshot:
        raise HTTPException(404, "Session not found")

    await event_repo.append_event(
        session_id, tax_year_id, "computation_requested", {}
    )

    completion_pct = snapshot.get("completion_pct", 0)
    detail = snapshot.get("completion_detail") or {}

    # Emit advisory cards from snapshot data (not DAG output)
    stamper = OutputStamper()
    output = stamper.stamp(
        snapshot=snapshot,
        completion_pct=completion_pct,
        missing_required=detail.get("missing_required", []),
        missing_required_labels=detail.get("missing_required_labels", []),
        assumptions_used=[],
    )

    await event_repo.append_event(
        session_id, tax_year_id, "computation_completed",
        {"completion_pct": completion_pct, "is_approximation": output.is_approximation},
    )

    # Return stub response per Part 6 spec
    return {
        "status": "APPROXIMATION",
        "session_id": session_id,
        "completion_pct": completion_pct,
        "india_tax": {
            "_stub": True,
            "note": "India Math DAG pending architect review — estimate unavailable",
        },
        "us_tax": {
            "_stub": True,
            "note": "US Math DAG pending architect review — estimate unavailable",
        },
        "advisory_cards": [
            {
                "card_id": c.card_id,
                "title": c.title,
                "description": c.description,
                "severity": c.severity,
                "category": c.category,
            }
            for c in output.advisory_cards
        ],
        "missing_for_final": output.missing_for_final,
        "assumptions_used": [],
    }
