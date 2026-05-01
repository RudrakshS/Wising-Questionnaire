"""
WISING TAX ENGINE — app/main.py
FastAPI application entry point with lifespan (asyncpg pool).
"""
from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import lifespan
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
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.get("/health")
async def health() -> dict:
    return {"status": "ok", "schema_version": "v5.1"}
