"""
WISING TAX ENGINE — app/database.py
asyncpg connection pool managed via FastAPI lifespan.
"""
from __future__ import annotations

from contextlib import asynccontextmanager
from typing import AsyncGenerator

import asyncpg
from fastapi import FastAPI

from app.config import settings

# Module-level pool — set during lifespan startup
_pool: asyncpg.Pool | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create asyncpg pool on startup, close on shutdown."""
    global _pool
    _pool = await asyncpg.create_pool(
        dsn=settings.database_url,
        min_size=2,
        max_size=10,
        command_timeout=60,
    )
    yield
    if _pool:
        await _pool.close()


async def get_db() -> AsyncGenerator[asyncpg.Pool, None]:
    """FastAPI dependency — yields the connection pool."""
    if _pool is None:
        raise RuntimeError("Database pool not initialized. Is the lifespan running?")
    yield _pool
