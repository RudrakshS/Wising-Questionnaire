"""
WISING TAX ENGINE — app/api/router.py
APIRouter aggregator for all sub-routers.
"""
from fastapi import APIRouter
from app.api import session, profile, evaluate, wizard

router = APIRouter()
router.include_router(session.router)
router.include_router(profile.router)
router.include_router(evaluate.router)
router.include_router(wizard.router)
