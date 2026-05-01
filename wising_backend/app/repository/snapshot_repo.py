"""
WISING TAX ENGINE — app/repository/snapshot_repo.py
CRUD for tax_state_snapshots table.
Uses asyncpg.Pool via FastAPI dependency injection.
Parameterized queries only — no string interpolation of user data.
Source: sprint4_persistence.py TaxStateRepository.
"""
from __future__ import annotations

import json
import uuid
from typing import Any, Optional

import asyncpg
from fastapi import HTTPException


class SnapshotRepository:
    """
    Persistence layer for tax_state_snapshots.
    Single active snapshot per user per tax year.
    """

    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    async def get_active_snapshot(
        self, user_id: str, tax_year_id: str
    ) -> Optional[dict]:
        """
        Fetch the single active snapshot for a user+tax_year.
        Uses the unique index: idx_active_snapshot(user_id, tax_year_id)
                               WHERE status = 'active'
        """
        query = """
            SELECT id, user_id, tax_year_id, layer0_state, layer1_india,
                   layer1_us, jurisdiction, india_lock, us_lock,
                   completion_pct, completion_detail, computation_result,
                   is_approximation, last_computed_at, status,
                   schema_version, created_at, updated_at
            FROM tax_state_snapshots
            WHERE user_id = $1::uuid AND tax_year_id = $2::uuid AND status = 'active'
        """
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, user_id, tax_year_id)
            if not row:
                return None
            return self._row_to_dict(row)

    async def get_snapshot_by_id(self, snapshot_id: str) -> Optional[dict]:
        """Fetch snapshot by its primary key."""
        query = """
            SELECT id, user_id, tax_year_id, layer0_state, layer1_india,
                   layer1_us, jurisdiction, india_lock, us_lock,
                   completion_pct, completion_detail, computation_result,
                   is_approximation, last_computed_at, status,
                   schema_version, created_at, updated_at
            FROM tax_state_snapshots
            WHERE id = $1
        """
        import uuid as _uuid
        async with self.pool.acquire() as conn:
            try:
                uid = _uuid.UUID(snapshot_id)
            except ValueError:
                return None
            row = await conn.fetchrow(query, uid)
            if not row:
                return None
            return self._row_to_dict(row)

    async def create_snapshot(
        self,
        user_id: str,
        tax_year_id: str,
        session_id: Optional[str] = None,
    ) -> str:
        """
        Create a new active snapshot. Returns the snapshot ID (UUID).
        Raises 409 if an active snapshot already exists.
        """
        snapshot_id = session_id or str(uuid.uuid4())
        query = """
            INSERT INTO tax_state_snapshots
                (id, user_id, tax_year_id, layer0_state, status, schema_version)
            VALUES ($1::uuid, $2::uuid, $3::uuid, '{}', 'active', 'v5.1')
            RETURNING id
        """
        async with self.pool.acquire() as conn:
            try:
                result = await conn.fetchval(query, snapshot_id, user_id, tax_year_id)
                return str(result)
            except asyncpg.UniqueViolationError:
                raise HTTPException(
                    status_code=409,
                    detail="Active snapshot already exists for this user+tax_year",
                )

    async def upsert_snapshot(self, snapshot: dict) -> dict:
        """
        Upsert the full snapshot state.
        Used after every field patch + reactive re-evaluation.
        """
        query = """
            UPDATE tax_state_snapshots
            SET layer0_state      = $2::jsonb,
                layer1_india      = $3::jsonb,
                layer1_us         = $4::jsonb,
                jurisdiction      = $5,
                india_lock        = $6,
                us_lock           = $7,
                completion_pct    = $8,
                completion_detail = $9::jsonb,
                is_approximation  = $10,
                updated_at        = now()
            WHERE id = $1::uuid AND status = 'active'
            RETURNING id, updated_at
        """
        import uuid as _uuid
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                query,
                _uuid.UUID(snapshot["id"]),
                json.dumps(snapshot.get("layer0_state") or {}),
                json.dumps(snapshot.get("layer1_india")) if snapshot.get("layer1_india") is not None else None,
                json.dumps(snapshot.get("layer1_us")) if snapshot.get("layer1_us") is not None else None,
                snapshot.get("jurisdiction"),
                snapshot.get("india_lock"),
                snapshot.get("us_lock"),
                snapshot.get("completion_pct", 0),
                json.dumps(snapshot.get("completion_detail") or {}),
                snapshot.get("is_approximation", True),
            )
            if not row:
                raise HTTPException(404, "Snapshot not found or archived")
            snapshot["updated_at"] = str(row["updated_at"])
            return snapshot

    async def store_computation_result(
        self,
        snapshot_id: str,
        result: dict,
        completion_pct: int,
        is_approximation: bool,
    ) -> None:
        """Store DAG computation result in the snapshot."""
        query = """
            UPDATE tax_state_snapshots
            SET computation_result = $2::jsonb,
                completion_pct     = $3,
                is_approximation   = $4,
                last_computed_at   = now(),
                updated_at         = now()
            WHERE id = $1::uuid AND status = 'active'
        """
        async with self.pool.acquire() as conn:
            await conn.execute(
                query, snapshot_id, json.dumps(result), completion_pct, is_approximation
            )

    @staticmethod
    def _row_to_dict(row: asyncpg.Record) -> dict:
        """Convert asyncpg Record to plain dict, deserializing JSONB columns."""
        d = dict(row)
        for jsonb_col in (
            "layer0_state", "layer1_india", "layer1_us",
            "completion_detail", "computation_result",
        ):
            val = d.get(jsonb_col)
            if isinstance(val, str):
                d[jsonb_col] = json.loads(val)
        # Convert UUID and datetime objects to strings
        for k, v in d.items():
            if hasattr(v, "isoformat"):
                d[k] = v.isoformat()
            elif hasattr(v, "hex"):  # UUID
                d[k] = str(v)
        return d
