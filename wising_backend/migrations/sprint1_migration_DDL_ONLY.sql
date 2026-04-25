-- ═══════════════════════════════════════════════════════════════
-- WISING TAX ENGINE — Sprint 1 Database Migration
-- Document: WISING-IMPL-001 Sprint 1
-- Date: April 2026
-- 
-- Creates: 4 core tables + seeds field_registry for Layer 0
--          + Layer 1 India core sections (profile, residency,
--          DTAA, property, income gates, metadata, surcharge)
--
-- Layer 1 India remaining sections (bank, deductions, etc.)
-- and Layer 1 US: seeded in Sprints 5-6 per roadmap.
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- TABLE 1: field_registry
-- Drives wizard sequencing + completion percentage engine
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS field_registry (
    field_path      TEXT PRIMARY KEY,
    schema_name     TEXT NOT NULL CHECK (schema_name IN ('layer0','layer1_india','layer1_us')),
    section         TEXT NOT NULL,
    classification  TEXT NOT NULL CHECK (classification IN ('REQUIRED','CONDITIONAL','OPTIONAL','DERIVED')),
    friendly_label  TEXT NOT NULL,
    input_type      TEXT NOT NULL CHECK (input_type IN ('integer','boolean','enum','date','currency','string','array')),
    enabled_if      JSONB,
    default_value   JSONB,
    default_label   TEXT,
    wizard_order    INTEGER NOT NULL DEFAULT 0,
    section_order   INTEGER NOT NULL DEFAULT 0
);

-- ═══════════════════════════════════════════════════════════════
-- TABLE 2: tax_state_snapshots
-- One active row per user per tax year. JSONB per layer.
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS tax_state_snapshots (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL,
    tax_year_id         UUID NOT NULL,
    layer0_state        JSONB NOT NULL DEFAULT '{}',
    layer1_india        JSONB,
    layer1_us           JSONB,
    jurisdiction        TEXT,
    india_lock          TEXT,
    us_lock             TEXT,
    completion_pct      INTEGER DEFAULT 0,
    completion_detail   JSONB DEFAULT '{}',
    computation_result  JSONB,
    is_approximation    BOOLEAN DEFAULT TRUE,
    last_computed_at    TIMESTAMPTZ,
    status              TEXT NOT NULL DEFAULT 'active',
    schema_version      TEXT NOT NULL DEFAULT 'v5.1',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_active_snapshot
    ON tax_state_snapshots(user_id, tax_year_id) WHERE status = 'active';

-- ═══════════════════════════════════════════════════════════════
-- TABLE 3: tax_events (append-only audit log)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS tax_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    tax_year_id     UUID NOT NULL,
    event_type      TEXT NOT NULL,
    payload         JSONB NOT NULL,
    caused_by       UUID,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_events_lookup
    ON tax_events(user_id, tax_year_id, created_at);

-- ═══════════════════════════════════════════════════════════════
-- TABLE 4: bridge_events (dual-jurisdiction shared life events)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS bridge_events (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL,
    tax_year_id         UUID NOT NULL,
    event_type          TEXT NOT NULL,
    captured_inputs     JSONB NOT NULL,
    india_projection    JSONB,
    us_projection       JSONB,
    cross_flags         JSONB,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;

-- ═══════════════════════════════════════════════════════════════
-- DML REMOVED — Field registry is seeded exclusively by:
--   db/seeds/seed_registry.py
--
-- Run the seeder after running this DDL:
--   python db/seeds/seed_registry.py
--
-- This file is DDL-only (table creation). Never add INSERT
-- statements here. All changes to field definitions must
-- go through the seeder and its JSONC source files.
-- ═══════════════════════════════════════════════════════════════
