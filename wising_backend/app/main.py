"""
WISING TAX ENGINE — app/main.py
FastAPI application entry point with lifespan (asyncpg pool).
"""
from __future__ import annotations

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
import asyncpg

from app.database import lifespan, get_db
from app.api.router import router
from app.config import settings

app = FastAPI(
    title="Wising Tax Engine",
    version="1.0.0",
    description="US–India NRI Cross-Border Tax Engine — Deterministic, Rules-Based, Legally Auditable.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https://.*\.vercel\.app|http://localhost:3000",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, prefix="/api")


@app.get("/health")
async def health(pool: asyncpg.Pool = Depends(get_db)) -> dict:
    try:
        async with pool.acquire() as conn:
            await conn.execute("SELECT 1")
        return {"status": "ok", "database": "connected", "schema_version": "v5.1"}
    except Exception as e:
        return {"status": "error", "database": str(e), "schema_version": "v5.1"}
