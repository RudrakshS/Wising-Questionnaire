"""
WISING TAX ENGINE — app/repository/field_registry_repo.py
Read-only field registry queries.
The field_registry table is seeded once and never mutated at runtime.
"""
from __future__ import annotations

from typing import Optional

import asyncpg


class FieldRegistryRepository:
    """Read-only access to the field_registry table."""

    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    async def get_all_fields(self) -> list[dict]:
        """Return all field_registry rows ordered by (section_order, wizard_order)."""
        query = """
            SELECT field_path, schema_name, section, classification,
                   friendly_label, input_type, enum_values, enabled_if,
                   default_value, default_label, wizard_order, section_order
            FROM field_registry
            ORDER BY section_order ASC, wizard_order ASC
        """
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query)
            return [self._row_to_dict(r) for r in rows]

    async def get_field(self, field_path: str) -> Optional[dict]:
        """Lookup a single field by its primary key."""
        query = """
            SELECT field_path, schema_name, section, classification,
                   friendly_label, input_type, enum_values, enabled_if,
                   default_value, default_label, wizard_order, section_order
            FROM field_registry
            WHERE field_path = $1
        """
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, field_path)
            return self._row_to_dict(row) if row else None

    async def get_fields_by_schema(
        self, schema_name: str
    ) -> list[dict]:
        """Return all fields for a specific schema (layer0, layer1_india, layer1_us)."""
        query = """
            SELECT field_path, schema_name, section, classification,
                   friendly_label, input_type, enum_values, enabled_if,
                   default_value, default_label, wizard_order, section_order
            FROM field_registry
            WHERE schema_name = $1
            ORDER BY section_order ASC, wizard_order ASC
        """
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, schema_name)
            return [self._row_to_dict(r) for r in rows]

    @staticmethod
    def _row_to_dict(row: asyncpg.Record) -> dict:
        """Convert asyncpg Record to plain dict."""
        import json

        d = dict(row)
        for jsonb_col in ("enum_values", "enabled_if", "default_value"):
            val = d.get(jsonb_col)
            if isinstance(val, str):
                try:
                    d[jsonb_col] = json.loads(val)
                except (json.JSONDecodeError, TypeError):
                    pass
        return d
