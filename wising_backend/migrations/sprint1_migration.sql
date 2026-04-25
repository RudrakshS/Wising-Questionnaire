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
    schema_version      TEXT NOT NULL DEFAULT 'v4',
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

-- WISING Sprint 1 — Field Registry Seed
-- Generated for 76 fields across Layer 0 + Layer 1 India (partial)
-- Layer 1 US fields follow the same pattern — generate in Sprint 5
-- Date: April 2026

BEGIN;

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.is_indian_citizen',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Are you an Indian citizen?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.is_pio_or_oci',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Are you a Person of Indian Origin (PIO) or OCI cardholder?',
  'boolean',
  '{"field": "layer0.is_indian_citizen", "op": "eq", "value": false}'::jsonb,
  NULL::jsonb,
  NULL,
  2,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.india_days',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'How many days were you in India this tax year (Apr 2025 – Mar 2026)?',
  'integer',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  3,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.has_india_source_income_or_assets',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Do you have any India-source income or Indian assets?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  4,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.is_us_citizen',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Are you a US citizen?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  5,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.has_green_card',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Do you hold a valid US Green Card?',
  'boolean',
  '{"field": "layer0.is_us_citizen", "op": "eq", "value": false}'::jsonb,
  NULL::jsonb,
  NULL,
  6,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.was_in_us_this_year',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Were you in the US at any point this calendar year?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  7,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.us_days',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'How many days were you in the US this calendar year?',
  'integer',
  '{"field": "layer0.was_in_us_this_year", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  8,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.has_us_source_income_or_assets',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Do you have any US-source income or US assets?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  9,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.liable_to_tax_in_another_country',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Are you liable to pay income tax in any other country this year?',
  'boolean',
  '{"field": "layer0.is_indian_citizen", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  10,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.left_india_for_employment_this_year',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Did you leave India this year for employment abroad?',
  'boolean',
  '{"field": "layer0.is_indian_citizen", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  11,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.india_flag',
  'layer0',
  'jurisdiction_router',
  'DERIVED',
  'India taxing rights flag',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.us_flag',
  'layer0',
  'jurisdiction_router',
  'DERIVED',
  'US taxing rights flag',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer0.jurisdiction',
  'layer0',
  'jurisdiction_router',
  'DERIVED',
  'Jurisdiction routing output',
  'enum',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  1
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.profile.date_of_birth',
  'layer1_india',
  'profile',
  'REQUIRED',
  'What is your date of birth?',
  'date',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  2
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.profile.pan',
  'layer1_india',
  'profile',
  'REQUIRED',
  'What is your PAN number?',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  2,
  2
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.profile.pan_aadhaar_linked',
  'layer1_india',
  'profile',
  'REQUIRED',
  'Is your PAN linked to Aadhaar?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  3,
  2
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.profile.tax_regime',
  'layer1_india',
  'profile',
  'OPTIONAL',
  'Which tax regime do you want to use?',
  'enum',
  NULL::jsonb,
  '"NEW"'::jsonb,
  'Assumed: New Tax Regime',
  4,
  2
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.days_in_india_current_year',
  'layer1_india',
  'residency_detail',
  'REQUIRED',
  'Days in India this tax year (pre-filled)',
  'integer',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Were you in India 365+ days total in the 4 preceding tax years?',
  'boolean',
  '{"and": [{"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 60}, {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "lt", "value": 182}]}'::jsonb,
  NULL::jsonb,
  NULL,
  2,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.employment_or_crew_status',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'What was your employment/crew status when leaving India?',
  'enum',
  '{"and": [{"field": "layer0.left_india_for_employment_this_year", "op": "eq", "value": true}, {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 60}, {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "lt", "value": 182}, {"field": "layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365", "op": "eq", "value": true}, {"field": "layer0.is_indian_citizen", "op": "eq", "value": true}]}'::jsonb,
  NULL::jsonb,
  NULL,
  3,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.is_departure_year',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Is this the first year you left India for this employment?',
  'boolean',
  '{"field": "layer1_india.residency_detail.employment_or_crew_status", "op": "neq", "value": "none"}'::jsonb,
  NULL::jsonb,
  NULL,
  4,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.ship_nationality',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Is the ship Indian or foreign-flagged?',
  'enum',
  '{"field": "layer1_india.residency_detail.employment_or_crew_status", "op": "in", "value": ["indian_ship_crew", "foreign_ship_crew"]}'::jsonb,
  NULL::jsonb,
  NULL,
  5,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.came_on_visit_to_india_pio_oci_citizen',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Did you come to India on a visit as a PIO/OCI or Indian citizen?',
  'boolean',
  '{"field": "layer1_india.residency_detail.employment_or_crew_status", "op": "eq", "value": "none"}'::jsonb,
  NULL::jsonb,
  NULL,
  6,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.nr_years_last_10_gte_9',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Were you NR for 9 or more of the last 10 tax years?',
  'boolean',
  '{"or": [{"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 182}, {"field": "layer1_india.residency_detail.came_on_visit_to_india_pio_oci_citizen", "op": "eq", "value": false}]}'::jsonb,
  NULL::jsonb,
  NULL,
  7,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.days_in_india_last_7_years_lte_729',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Were you in India 729 days or fewer in the 7 preceding tax years?',
  'boolean',
  '{"or": [{"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 182}, {"field": "layer1_india.residency_detail.came_on_visit_to_india_pio_oci_citizen", "op": "eq", "value": false}]}'::jsonb,
  NULL::jsonb,
  NULL,
  8,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.india_source_income_above_15l',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'Is your India-source income above ₹15 lakh this year?',
  'boolean',
  '{"field": "layer0.has_india_source_income_or_assets", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  9,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.current_year_trip_log',
  'layer1_india',
  'residency_detail',
  'OPTIONAL',
  'Trip log for India travel this year',
  'array',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  10,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.liable_to_tax_in_another_country_being_indian_citizen',
  'layer1_india',
  'residency_detail',
  'DERIVED',
  'Deemed Resident blocker (composite)',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.residency_detail.final_india_residency_status',
  'layer1_india',
  'residency_detail',
  'DERIVED',
  'India residency lock (NR/RNOR/ROR)',
  'enum',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  3
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.dtaa.tax_residency_country',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'Which country are you a tax resident of?',
  'string',
  '{"field": "layer1_india.residency_detail.final_india_residency_status", "op": "eq", "value": "NR"}'::jsonb,
  NULL::jsonb,
  NULL,
  1,
  4
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.dtaa.is_us_resident_for_dtaa',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'Are you a US resident for DTAA purposes?',
  'boolean',
  '{"field": "layer1_india.dtaa.tax_residency_country", "op": "eq", "value": "US"}'::jsonb,
  NULL::jsonb,
  NULL,
  2,
  4
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.dtaa.trc_status',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'Do you have a valid Tax Residency Certificate (TRC)?',
  'boolean',
  '{"field": "layer1_india.residency_detail.final_india_residency_status", "op": "eq", "value": "NR"}'::jsonb,
  NULL::jsonb,
  NULL,
  3,
  4
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.dtaa.has_permanent_establishment_in_india',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'Do you have a fixed place of business in India?',
  'boolean',
  '{"field": "layer1_india.residency_detail.final_india_residency_status", "op": "eq", "value": "NR"}'::jsonb,
  NULL::jsonb,
  NULL,
  4,
  4
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.dtaa.mfn_clause_invoked',
  'layer1_india',
  'dtaa',
  'OPTIONAL',
  'Are you invoking the MFN clause?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  5,
  4
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.has_indian_property_transaction',
  'layer1_india',
  'property',
  'REQUIRED',
  'Did you sell Indian property this tax year?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].property_type',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'What type of property did you sell?',
  'enum',
  '{"field": "layer1_india.property.has_indian_property_transaction", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  2,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].acquisition_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'When did you acquire this property?',
  'date',
  '{"field": "layer1_india.property.has_indian_property_transaction", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  3,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].actual_cost',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'What was the purchase price (INR)?',
  'currency',
  '{"field": "layer1_india.property.has_indian_property_transaction", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  4,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].sale_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'When did you sell?',
  'date',
  '{"field": "layer1_india.property.has_indian_property_transaction", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  5,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].sale_consideration',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'What was the sale amount (INR)?',
  'currency',
  '{"field": "layer1_india.property.has_indian_property_transaction", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  6,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].stamp_duty_value',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Circle rate / stamp duty value at sale date?',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  7,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].buyer_tan',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Buyer''s TAN number (for NRI TDS)',
  'string',
  '{"field": "layer1_india.residency_detail.final_india_residency_status", "op": "eq", "value": "NR"}'::jsonb,
  NULL::jsonb,
  NULL,
  8,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].buyer_tds_deducted_inr',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'TDS deducted by buyer (INR)?',
  'currency',
  '{"field": "layer1_india.residency_detail.final_india_residency_status", "op": "eq", "value": "NR"}'::jsonb,
  NULL::jsonb,
  NULL,
  9,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].is_inherited',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Was this property inherited?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  10,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].original_owner_acquisition_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'When did the original owner acquire it?',
  'date',
  '{"field": "layer1_india.property.properties[].is_inherited", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  11,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].original_owner_cost',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Original owner''s purchase price?',
  'currency',
  '{"field": "layer1_india.property.properties[].is_inherited", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  12,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].reinvestment_exemption_claimed',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Are you claiming a reinvestment exemption?',
  'enum',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  13,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.property.properties[].s54_two_house_option',
  'layer1_india',
  'property',
  'DERIVED',
  'Section 54 two-house eligibility',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  8
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.domestic_income.salary.has_salary_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'Do you earn a salary?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  13
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.domestic_income.salary.gross_salary_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'What is your gross annual salary (INR)?',
  'currency',
  '{"field": "layer1_india.domestic_income.salary.has_salary_income", "op": "eq", "value": true}'::jsonb,
  NULL::jsonb,
  NULL,
  2,
  13
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.domestic_income.house_property.has_house_property_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'Do you earn rental income from property?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  10,
  13
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.domestic_income.business_income.has_business_or_fo_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'Do you have business or F&O income?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  20,
  13
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.other_sources.has_other_sources_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'Do you have other income (interest, dividends, pension)?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  30,
  13
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.financial_holdings.has_financial_transactions',
  'layer1_india',
  'financial_holdings',
  'REQUIRED',
  'Did you sell any stocks, mutual funds, or ETFs?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  9
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.commodities.has_commodity_transactions',
  'layer1_india',
  'commodities',
  'REQUIRED',
  'Did you sell gold, silver, or SGBs?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  10
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.unlisted_equity.has_unlisted_equity_transaction',
  'layer1_india',
  'unlisted_equity',
  'REQUIRED',
  'Did you sell unlisted/private company shares?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  11
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.share_buyback.has_buyback_transaction',
  'layer1_india',
  'share_buyback',
  'REQUIRED',
  'Did you participate in a share buyback?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  12
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.carry_forward_losses.has_brought_forward_losses',
  'layer1_india',
  'carry_forward_losses',
  'REQUIRED',
  'Do you have losses carried forward from prior years?',
  'boolean',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  1,
  16
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.financial_year',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: financial_year',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.request_id',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: request_id',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.source',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: source',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.input_completeness',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: input_completeness',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.cii_confirmed_for_fy',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: cii_confirmed_for_fy',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.schema_version',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: schema_version',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.created_at',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: created_at',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.metadata.last_updated_at',
  'layer1_india',
  'metadata',
  'DERIVED',
  'System field: last_updated_at',
  'string',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  20
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_normal_slab_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_normal_slab_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_stcg_111A_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_stcg_111A_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_ltcg_112A_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_ltcg_112A_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_ltcg_112_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_ltcg_112_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_stcg_other_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_stcg_other_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_dividend_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_dividend_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_special_115BB_115BBJ_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_special_115BB_115BBJ_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.income_vda_115BBH_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: income_vda_115BBH_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

INSERT INTO field_registry (field_path, schema_name, section, classification, friendly_label, input_type, enabled_if, default_value, default_label, wizard_order, section_order) VALUES (
  'layer1_india.surcharge_buckets.speculative_income_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'Surcharge bucket: speculative_income_inr',
  'currency',
  NULL::jsonb,
  NULL::jsonb,
  NULL,
  0,
  19
);

COMMIT;

-- Summary: 76 fields seeded
--   CONDITIONAL: 27
--   DERIVED: 23
--   OPTIONAL: 6
--   REQUIRED: 20
