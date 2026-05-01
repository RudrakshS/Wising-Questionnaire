"""
WISING TAX ENGINE — app/repository/event_repo.py
Append-only tax_events log.
No UPDATE, no DELETE — audit trail only.
"""
from __future__ import annotations

import json
import uuid
from typing import Optional

import asyncpg


class EventRepository:
    """Append-only event log for audit trail."""

    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    async def append_event(
        self,
        user_id: str,
        tax_year_id: str,
        event_type: str,
        payload: dict,
        caused_by: Optional[str] = None,
    ) -> str:
        """Insert one event. Returns the new event ID."""
        event_id = str(uuid.uuid4())
        query = """
            INSERT INTO tax_events (id, user_id, tax_year_id, event_type, payload, caused_by)
            VALUES ($1::uuid, $2::uuid, $3::uuid, $4, $5::jsonb, $6::uuid)
            RETURNING id
        """
        async with self.pool.acquire() as conn:
            result = await conn.fetchval(
                query,
                event_id,
                user_id,
                tax_year_id,
                event_type,
                json.dumps(payload),
                caused_by,
            )
            return str(result)

    async def get_events(
        self,
        user_id: str,
        tax_year_id: str,
        limit: int = 100,
    ) -> list[dict]:
        """Return recent events for a user+tax_year, newest first."""
        query = """
            SELECT id, event_type, payload, caused_by, created_at
            FROM tax_events
            WHERE user_id = $1::uuid AND tax_year_id = $2::uuid
            ORDER BY created_at DESC
            LIMIT $3
        """
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, user_id, tax_year_id, limit)
            result = []
            for row in rows:
                d = dict(row)
                if isinstance(d.get("payload"), str):
                    d["payload"] = json.loads(d["payload"])
                for k, v in d.items():
                    if hasattr(v, "isoformat"):
                        d[k] = v.isoformat()
                    elif hasattr(v, "hex"):
                        d[k] = str(v)
                result.append(d)
            return result
