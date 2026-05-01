-- ══════════════════════════════════════════════════════════════
-- WISING Field Registry Seed  (AUTO-GENERATED — DO NOT EDIT)
-- Run `python seed_registry.py` to regenerate.
--
-- Source file checksums:
--   layer0: ae04908e9790d7baf098d8a43f71dbcf1cea3d1374ac4c740932652736b2c9e2
--   layer1_india: 54a8a2b017f9542e2b8f5eccec28cd036b98a29b0d41f21e66d8b7b57d40beb3
--   layer1_us: a6cc2d69c6c181f11eff16c75ed7a013c2c6fc6cfa8fc6f1d2a479391c8a0d3b
--
-- Total fields: 656
-- ══════════════════════════════════════════════════════════════

-- GAP-001 FIX: Add enum_values column if not present.
-- Run this once before the first seed; idempotent.
ALTER TABLE field_registry
  ADD COLUMN IF NOT EXISTS enum_values JSONB;

BEGIN;

-- ════════════════════════════════════════════════════════════
-- SCHEMA: LAYER0
-- ════════════════════════════════════════════════════════════

-- ── Section: jurisdiction_router (order=10) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.is_indian_citizen',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Are you an Indian citizen?',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.is_pio_or_oci',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Are you a PIO or OCI cardholder?',
  'boolean',
  NULL,
  '{"field": "layer0.is_indian_citizen", "op": "eq", "value": false}'::jsonb,
  NULL,
  NULL,
  2,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.india_days',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Days in India this tax year (Apr 2025–Mar 2026)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.has_india_source_income_or_assets',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Any India-source income or Indian assets this year?',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.is_us_citizen',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Are you a US citizen?',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.has_green_card',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Do you hold a valid US Green Card?',
  'boolean',
  NULL,
  '{"field": "layer0.is_us_citizen", "op": "eq", "value": false}'::jsonb,
  NULL,
  NULL,
  6,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.was_in_us_this_year',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Were you in the US at any point this calendar year?',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.us_days',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'How many days were you in the US this calendar year?',
  'integer',
  NULL,
  '{"field": "layer0.was_in_us_this_year", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  8,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.has_us_source_income_or_assets',
  'layer0',
  'jurisdiction_router',
  'REQUIRED',
  'Any US-source income or US-situs assets this year?',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.liable_to_tax_in_another_country',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Are you liable to income tax in any other country?',
  'boolean',
  NULL,
  '{"field": "layer0.is_indian_citizen", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  10,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.left_india_for_employment_this_year',
  'layer0',
  'jurisdiction_router',
  'CONDITIONAL',
  'Did you leave India this year for employment abroad?',
  'boolean',
  NULL,
  '{"field": "layer0.is_indian_citizen", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  11,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.india_flag',
  'layer0',
  'jurisdiction_router',
  'DERIVED',
  '[DERIVED] India taxing rights flag',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.us_flag',
  'layer0',
  'jurisdiction_router',
  'DERIVED',
  '[DERIVED] US taxing rights flag',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer0.jurisdiction',
  'layer0',
  'jurisdiction_router',
  'DERIVED',
  '[DERIVED] Jurisdiction routing output',
  'enum',
  '["india_only", "us_only", "dual", "none"]'::jsonb,
  NULL,
  NULL,
  NULL,
  14,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

-- ════════════════════════════════════════════════════════════
-- SCHEMA: LAYER1_INDIA
-- ════════════════════════════════════════════════════════════

-- ── Section: profile (order=10) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.profile.date_of_birth',
  'layer1_india',
  'profile',
  'REQUIRED',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.profile.pan',
  'layer1_india',
  'profile',
  'REQUIRED',
  'string (10 chars, AAAAA9999A format)',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.profile.pan_aadhaar_linked',
  'layer1_india',
  'profile',
  'REQUIRED',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.profile.tax_regime',
  'layer1_india',
  'profile',
  'OPTIONAL',
  '"NEW" | "OLD" | null',
  'enum',
  '["NEW", "OLD"]'::jsonb,
  NULL,
  NULL,
  NULL,
  4,
  10
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: residency_detail (order=20) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.days_in_india_current_year',
  'layer1_india',
  'residency_detail',
  'REQUIRED',
  'integer (0–366)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"and": [{"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 60}, {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "lt", "value": 182}]}'::jsonb,
  NULL,
  NULL,
  2,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.employment_or_crew_status',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  '"employed_abroad" | "indian_ship_crew" | "foreign_ship_crew" | "none"',
  'enum',
  '["employed_abroad", "indian_ship_crew", "foreign_ship_crew", "none"]'::jsonb,
  '{"_raw": "ALL of the following are true:", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  3,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.is_departure_year',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"_raw": "employment_or_crew_status NOT IN [\"none\", null]", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  4,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.ship_nationality',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  '"indian" | "foreign"',
  'enum',
  '["indian", "foreign"]'::jsonb,
  '{"field": "layer1_india.residency_detail.employment_or_crew_status", "op": "in", "value": ["indian_ship_crew", "foreign_ship_crew"]}'::jsonb,
  NULL,
  NULL,
  5,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.came_on_visit_to_india_pio_citizen',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_india.residency_detail.employment_or_crew_status", "op": "eq", "value": "none"}'::jsonb,
  NULL,
  NULL,
  6,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.nr_years_last_10_gte_9',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 182}'::jsonb,
  NULL,
  NULL,
  7,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.days_in_india_last_7_years_lte_729',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 182}'::jsonb,
  NULL,
  NULL,
  8,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.india_source_income_above_15l',
  'layer1_india',
  'residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"_raw": "Layer 0 has_india_source_income_or_assets = true", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  9,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.current_year_trip_log',
  'layer1_india',
  'residency_detail',
  'OPTIONAL',
  'Array of trip objects: [{ "arrival_date": "YYYY-MM-DD", "departure_date": "YYYY-MM-DD" }]',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.liable_to_tax_in_another_country_being_indian_citizen',
  'layer1_india',
  'residency_detail',
  'DERIVED',
  'DERIVED | bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.residency_detail.final_india_residency_status',
  'layer1_india',
  'residency_detail',
  'DERIVED',
  'DERIVED | "NR" | "RNOR" | "ROR"',
  'enum',
  '["NR", "RNOR", "ROR"]'::jsonb,
  NULL,
  NULL,
  NULL,
  12,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: dtaa (order=30) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.tax_residency_country',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'ISO 3166-1 alpha-2 e.g. "US" | "AE" | "GB" | "SG" | "CA"',
  'enum',
  '["US", "AE", "GB", "SG", "CA"]'::jsonb,
  NULL,
  NULL,
  NULL,
  1,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.is_us_resident_for_dtaa',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_india.dtaa.tax_residency_country", "op": "eq", "value": "US"}'::jsonb,
  NULL,
  NULL,
  2,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.trc_status',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.has_permanent_establishment_in_india',
  'layer1_india',
  'dtaa',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.treaty_elections',
  'layer1_india',
  'dtaa',
  'OPTIONAL',
  'Array — per-income-stream treaty rate election.',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.treaty_elections[].income_type',
  'layer1_india',
  'dtaa',
  'OPTIONAL',
  'Income Type',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.treaty_elections[].elected_rate',
  'layer1_india',
  'dtaa',
  'OPTIONAL',
  'Elected Rate',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.treaty_elections[].treaty_article',
  'layer1_india',
  'dtaa',
  'OPTIONAL',
  'Treaty Article',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.dtaa.mfn_clause_invoked',
  'layer1_india',
  'dtaa',
  'OPTIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  30
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: compliance_docs (order=40) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.trc.validity_start_date',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.trc.validity_end_date',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.trc.document_uploaded',
  'layer1_india',
  'compliance_docs',
  'OPTIONAL',
  'bool — true = VERIFIED (treaty rates unlocked for ITR XML);',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.form_10f.is_filed',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.form_10f.ack_number',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  'string (15-digit ack from IT e-filing portal)',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.section_197_cert.is_available',
  'layer1_india',
  'compliance_docs',
  'OPTIONAL',
  'Is Available',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.section_197_cert.rate',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  'Overrides BOTH domestic AND DTAA rate.',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.section_197_cert.validity_start_date',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  'Validity Start Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.section_197_cert.validity_end_date',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  'Validity End Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.section_197_cert.covered_income_types',
  'layer1_india',
  'compliance_docs',
  'CONDITIONAL',
  'Covered Income Types',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.compliance_docs.chapter_xiia_elected',
  'layer1_india',
  'compliance_docs',
  'OPTIONAL',
  'bool | PROGRESSIVE',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  40
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: bank_accounts (order=50) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts',
  'layer1_india',
  'bank_accounts',
  'OPTIONAL',
  'Bank Accounts',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].bank_name',
  'layer1_india',
  'bank_accounts',
  'OPTIONAL',
  'Bank Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].account_type',
  'layer1_india',
  'bank_accounts',
  'REQUIRED',
  'Account Type',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].current_balance',
  'layer1_india',
  'bank_accounts',
  'REQUIRED',
  'Current Balance',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].current_balance_currency',
  'layer1_india',
  'bank_accounts',
  'OPTIONAL',
  'Current Balance Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].annual_interest_rate',
  'layer1_india',
  'bank_accounts',
  'OPTIONAL',
  'Annual Interest Rate',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].interest_credited_this_fy_inr',
  'layer1_india',
  'bank_accounts',
  'REQUIRED',
  'integer (INR) — actual interest credited this FY. Required for s.80TTA/TTB',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].account_conversion_date',
  'layer1_india',
  'bank_accounts',
  'CONDITIONAL',
  '"YYYY-MM-DD" | OPTIONAL',
  'enum',
  '["YYYY-MM-DD"]'::jsonb,
  '{"and": [{"field": "layer1_india.bank_accounts.account_type", "op": "eq", "value": "NRE"}, {"_raw": "lock changed to RNOR or ROR this FY", "_parse_error": true}]}'::jsonb,
  NULL,
  NULL,
  8,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].fcnr_maturity_date',
  'layer1_india',
  'bank_accounts',
  'CONDITIONAL',
  'Fcnr Maturity Date',
  'date',
  NULL,
  '{"field": "layer1_india.bank_accounts.account_type", "op": "eq", "value": "FCNR"}'::jsonb,
  NULL,
  NULL,
  9,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].nro_balance',
  'layer1_india',
  'bank_accounts',
  'CONDITIONAL',
  'Nro Balance',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.bank_accounts[].nro_balance_currency',
  'layer1_india',
  'bank_accounts',
  'OPTIONAL',
  'Nro Balance Currency',
  'string',
  NULL,
  NULL,
  '"INR"',
  NULL,
  11,
  50
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: nro_repatriation (order=55) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.nro_repatriation.cumulative_repatriated_usd_this_fy',
  'layer1_india',
  'nro_repatriation',
  'OPTIONAL',
  'number (USD). Annual limit: USD 1M aggregate. Alerts at 80% / 95%.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  55
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.nro_repatriation.pending_repatriation_inr',
  'layer1_india',
  'nro_repatriation',
  'OPTIONAL',
  'number (INR). Determines Form 15CA/15CB trigger (INR 5L threshold).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  55
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.nro_repatriation.tds_deducted_on_nro_balance',
  'layer1_india',
  'nro_repatriation',
  'OPTIONAL',
  'bool. false → TAX_CLEARANCE_REQUIRED fires.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  55
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: property (order=60) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.has_indian_property_transaction',
  'layer1_india',
  'property',
  'REQUIRED',
  'bool — GATE',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Properties',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].property_type',
  'layer1_india',
  'property',
  'CONDITIONAL',
  '"residential"|"commercial"|"land"|"agricultural_rural"|"under_construction"',
  'enum',
  '["residential", "commercial", "land", "agricultural_rural", "under_construction"]'::jsonb,
  NULL,
  NULL,
  NULL,
  3,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].acquisition_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].actual_cost',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Actual Cost',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].actual_cost_currency',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Actual Cost Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].pre_2001_fmv_inr',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Engine uses MAX(actual_cost, pre_2001_fmv_inr) as cost basis.',
  'integer',
  NULL,
  '{"_raw": "acquisition_date < \"2001-04-01\"", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  7,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].transfer_expenses_inr',
  'layer1_india',
  'property',
  'OPTIONAL',
  'number (INR). Brokerage, legal fees, stamp duty paid by seller.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].sale_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'FA 2024: pre-23 Jul → 20% indexed (residents only);',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].sale_consideration',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Sale Consideration',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].sale_consideration_currency',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Sale Consideration Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].stamp_duty_value',
  'layer1_india',
  'property',
  'OPTIONAL',
  'number (INR) — circle rate at SALE date.',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].stamp_duty_value_currency',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Stamp Duty Value Currency',
  'string',
  NULL,
  NULL,
  '"INR"',
  NULL,
  13,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].buyer_tan',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Buyer Tan',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].buyer_tds_deducted_inr',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Buyer Tds Deducted Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].buyer_tds_challan_number',
  'layer1_india',
  'property',
  'OPTIONAL',
  's.195 TDS = 12.5% + surcharge + cess on FULL sale value (not gain) for NRI sellers',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].is_joint_property',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Is Joint Property',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].ownership_percentage',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Ownership Percentage',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].is_inherited',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Is Inherited',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].original_owner_acquisition_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Original Owner Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].original_owner_cost',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Original Owner Cost',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].original_owner_cost_currency',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Original Owner Cost Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].reinvestment_exemption_claimed',
  'layer1_india',
  'property',
  'OPTIONAL',
  '"none" | "s54" | "s54f" | "s54ec"',
  'enum',
  '["none", "s54", "s54f", "s54ec"]'::jsonb,
  NULL,
  NULL,
  NULL,
  23,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].new_property_cost',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'New Property Cost',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  24,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].new_property_cost_currency',
  'layer1_india',
  'property',
  'OPTIONAL',
  'New Property Cost Currency',
  'string',
  NULL,
  NULL,
  '"INR"',
  NULL,
  25,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].new_property_purchase_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'New Property Purchase Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  26,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].s54_two_house_option',
  'layer1_india',
  'property',
  'DERIVED',
  'DERIVED | bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  27,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].bond_investment',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Bond Investment',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  28,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].bond_investment_currency',
  'layer1_india',
  'property',
  'OPTIONAL',
  'Bond Investment Currency',
  'string',
  NULL,
  NULL,
  '"INR"',
  NULL,
  29,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.property.properties[].bond_investment_date',
  'layer1_india',
  'property',
  'CONDITIONAL',
  'Bond Investment Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  30,
  60
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: financial_holdings (order=70) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.has_financial_transactions',
  'layer1_india',
  'financial_holdings',
  'REQUIRED',
  'bool — gate',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions',
  'layer1_india',
  'financial_holdings',
  'OPTIONAL',
  'Transactions',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].asset_class',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  '"listed_equity"|"equity_mutual_fund"|"debt_mutual_fund_pre_apr23"',
  'enum',
  '["listed_equity", "equity_mutual_fund", "debt_mutual_fund_pre_apr23", "debt_mutual_fund_post_apr23", "hybrid_mf_equity", "hybrid_mf_debt", "international_mf", "fof", "etf", "bond_listed", "reit_invit", "vda_crypto"]'::jsonb,
  NULL,
  NULL,
  NULL,
  3,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].asset_name_or_ticker',
  'layer1_india',
  'financial_holdings',
  'OPTIONAL',
  'Asset Name Or Ticker',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].isin',
  'layer1_india',
  'financial_holdings',
  'OPTIONAL',
  'Isin',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].quantity',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Quantity',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].acquisition_date',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].purchase_value',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Purchase Value',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].purchase_currency',
  'layer1_india',
  'financial_holdings',
  'OPTIONAL',
  'Purchase Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].fmv_31jan2018_per_unit_inr',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Grandfathered FMV per s.112A. Engine uses MAX(purchase_value, qty * fmv_31jan2018) as cost.',
  'integer',
  NULL,
  '{"and": [{"_raw": "acquisition_date < \"2018-02-01\"", "_parse_error": true}, {"field": "layer1_india.financial_holdings.asset_class", "op": "in", "value": ["listed_equity", "equity_mutual_fund"]}]}'::jsonb,
  NULL,
  NULL,
  10,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].sale_date',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Sale Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].sale_value',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Sale Value',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].sale_currency',
  'layer1_india',
  'financial_holdings',
  'OPTIONAL',
  'Sale Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.financial_holdings.transactions[].stt_paid',
  'layer1_india',
  'financial_holdings',
  'CONDITIONAL',
  'Stt Paid',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  70
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: commodities (order=80) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.has_commodity_transactions',
  'layer1_india',
  'commodities',
  'REQUIRED',
  'Has Commodity Transactions',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions',
  'layer1_india',
  'commodities',
  'OPTIONAL',
  'Transactions',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].commodity_type',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  '"physical_gold"|"sovereign_gold_bond_original"|"sovereign_gold_bond_secondary"',
  'enum',
  '["physical_gold", "sovereign_gold_bond_original", "sovereign_gold_bond_secondary", "silver", "gold_etf", "gold_fund_of_funds", "other"]'::jsonb,
  NULL,
  NULL,
  NULL,
  3,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].quantity',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  'Quantity',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].acquisition_date',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].purchase_value',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  'Purchase Value',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].purchase_currency',
  'layer1_india',
  'commodities',
  'OPTIONAL',
  'Purchase Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].is_maturity_redemption',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  'true → FULLY EXEMPT.',
  'boolean',
  NULL,
  '{"field": "layer1_india.commodities.commodity_type", "op": "eq", "value": "sovereign_gold_bond_original"}'::jsonb,
  NULL,
  NULL,
  8,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].sale_date',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  'Sale Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].sale_value',
  'layer1_india',
  'commodities',
  'CONDITIONAL',
  'Sale Value',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.commodities.transactions[].sale_currency',
  'layer1_india',
  'commodities',
  'OPTIONAL',
  'Sale Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  80
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: unlisted_equity (order=90) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.has_unlisted_equity_transaction',
  'layer1_india',
  'unlisted_equity',
  'REQUIRED',
  'Has Unlisted Equity Transaction',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions',
  'layer1_india',
  'unlisted_equity',
  'OPTIONAL',
  'Transactions',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].company_name',
  'layer1_india',
  'unlisted_equity',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].acquisition_date',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].cost_per_share',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'Cost Per Share',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].cost_per_share_currency',
  'layer1_india',
  'unlisted_equity',
  'OPTIONAL',
  'Cost Per Share Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].number_of_shares',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'Number Of Shares',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].sale_price_per_share',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'Sale Price Per Share',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].sale_price_per_share_currency',
  'layer1_india',
  'unlisted_equity',
  'OPTIONAL',
  'Sale Price Per Share Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].sale_date',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'Sale Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].fmv_valuation_report_date',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'FEMA: NRI selling to resident must sell at >= FMV. Stale if > 90 days.',
  'date',
  NULL,
  '{"field": "layer1_india.unlisted_equity.lock", "op": "eq", "value": "NR"}'::jsonb,
  NULL,
  NULL,
  11,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].original_investment_currency',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'If foreign: s.48 First Proviso applies (currency-neutralised CG).',
  'currency',
  NULL,
  '{"field": "layer1_india.unlisted_equity.lock", "op": "eq", "value": "NR"}'::jsonb,
  NULL,
  NULL,
  12,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.unlisted_equity.transactions[].original_cost_in_foreign_currency',
  'layer1_india',
  'unlisted_equity',
  'CONDITIONAL',
  'Original Cost In Foreign Currency',
  'string',
  NULL,
  '{"_raw": "original_investment_currency != \"INR\"", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  13,
  90
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: share_buyback (order=100) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.has_buyback_transaction',
  'layer1_india',
  'share_buyback',
  'REQUIRED',
  'Has Buyback Transaction',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions',
  'layer1_india',
  'share_buyback',
  'OPTIONAL',
  'Transactions',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].company_name',
  'layer1_india',
  'share_buyback',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].isin',
  'layer1_india',
  'share_buyback',
  'OPTIONAL',
  'Isin',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].buyback_date',
  'layer1_india',
  'share_buyback',
  'CONDITIONAL',
  'Buyback Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].tender_or_open_market',
  'layer1_india',
  'share_buyback',
  'CONDITIONAL',
  'Tender Or Open Market',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].shares_tendered',
  'layer1_india',
  'share_buyback',
  'CONDITIONAL',
  'Shares Tendered',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].consideration_received_inr',
  'layer1_india',
  'share_buyback',
  'CONDITIONAL',
  'Consideration Received Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].original_cost_inr',
  'layer1_india',
  'share_buyback',
  'CONDITIONAL',
  'Original Cost Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].original_acquisition_date',
  'layer1_india',
  'share_buyback',
  'CONDITIONAL',
  'Original Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].buyback_pre_or_post_oct2024',
  'layer1_india',
  'share_buyback',
  'DERIVED',
  'DERIVED | "pre_oct2024" | "post_oct2024"',
  'enum',
  '["pre_oct2024", "post_oct2024"]'::jsonb,
  NULL,
  NULL,
  NULL,
  11,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].deemed_dividend_inr',
  'layer1_india',
  'share_buyback',
  'DERIVED',
  'DERIVED | integer (INR)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.share_buyback.transactions[].capital_loss_inr',
  'layer1_india',
  'share_buyback',
  'DERIVED',
  'DERIVED | integer (INR)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  100
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: domestic_income (order=110) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.has_salary_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'Has Salary Income',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.gross_salary_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Gross Salary Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.exempt_allowances_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Exempt Allowances Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.hra_received_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Hra Received Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.rent_paid_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Rent Paid Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.is_metro_city',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Is Metro City',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.basic_da_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Basic Da Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.lta_claimed_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Lta Claimed Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.perquisites_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Perquisites Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.esop_perquisite_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer — FMV at exercise minus exercise price; taxed as salary in exercise year.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.professional_tax_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Professional Tax Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.employer_nps_contribution_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Employer Nps Contribution Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.salary.prior_employer_salary_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Prior Employer Salary Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.has_house_property_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'Has House Property Income',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Properties',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].property_use',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Property Use',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].gross_annual_value_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Gross Annual Value Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].municipal_taxes_paid_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Municipal Taxes Paid Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].interest_on_borrowed_capital_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Interest On Borrowed Capital Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].pre_construction_interest_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  '1/5 schedule across 5 years post-completion',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].is_self_occupied_with_loan',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Is Self Occupied With Loan',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.house_property.properties[].co_owner_share_percent',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Co Owner Share Percent',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.has_business_or_fo_income',
  'layer1_india',
  'domestic_income',
  'REQUIRED',
  'bool — GATE. If false, entire business_income block is hidden.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  23,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.nature_of_business',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'array of enum — may contain any of:',
  'array',
  '["small_business", "professional", "goods_transport", "fno_trader", "intraday_trader", "regular_business", "partner_in_firm"]'::jsonb,
  '{"field": "layer1_india.domestic_income.has_business_or_fo_income", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  24,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.presumptive_scheme',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'array of enum — may contain any of:',
  'array',
  '["s44AD", "s44ADA", "s44AE"]'::jsonb,
  '{"field": "layer1_india.domestic_income.has_business_or_fo_income", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  25,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.profession_type',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"legal" | "medical" | "engineering" | "architecture" | "accountancy"',
  'enum',
  '["legal", "medical", "engineering", "architecture", "accountancy", "technical_consultancy", "interior_decoration", "authorised_representative", "film_artist", "it_services", "other"]'::jsonb,
  '{"_raw": "\"s44ADA\" IN presumptive_scheme OR \"professional\" IN nature_of_business", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  26,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.s115BAC_optout_history',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  27,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.turnover_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"field": "layer1_india.domestic_income.has_business_or_fo_income", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  28,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.digital_receipts_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "contains", "value": "s44AD"}'::jsonb,
  NULL,
  NULL,
  29,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.cash_receipts_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "contains", "value": "s44AD"}'::jsonb,
  NULL,
  NULL,
  30,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.gross_receipts_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"and": [{"_raw": "\"s44ADA\" IN presumptive_scheme OR (\"professional\" IN nature_of_business", "_parse_error": true}, {"_raw": "presumptive_scheme = [])", "_parse_error": true}]}'::jsonb,
  NULL,
  NULL,
  31,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.s44AD_last_exit_ay',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'string e.g. "AY2023-24" | null',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  32,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.s44AD_opted_current_year',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  33,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.goods_vehicles',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Max 10 vehicles. Engine sums per-vehicle presumptive income.',
  'array',
  NULL,
  '{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "contains", "value": "s44AE"}'::jsonb,
  NULL,
  NULL,
  34,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.goods_vehicles[].vehicle_type',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"heavy" | "light"',
  'enum',
  '["heavy", "light"]'::jsonb,
  NULL,
  NULL,
  NULL,
  35,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.goods_vehicles[].gvw_tonnes',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer — Gross Vehicle Weight in tonnes',
  'integer',
  NULL,
  '{"field": "layer1_india.domestic_income.vehicle_type", "op": "eq", "value": "heavy"}'::jsonb,
  NULL,
  NULL,
  36,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.goods_vehicles[].months_owned',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (1–12)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  37,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.opening_stock_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"and": [{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "eq", "value": []}, {"field": "layer1_india.domestic_income.nature_of_business", "op": "contains", "value": "regular_business"}]}'::jsonb,
  NULL,
  NULL,
  38,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.closing_stock_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"and": [{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "eq", "value": []}, {"field": "layer1_india.domestic_income.nature_of_business", "op": "contains", "value": "regular_business"}]}'::jsonb,
  NULL,
  NULL,
  39,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.gst_registration_status',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"regular" | "composition" | "unregistered"',
  'enum',
  '["regular", "composition", "unregistered"]'::jsonb,
  '{"and": [{"field": "layer1_india.domestic_income.has_business_or_fo_income", "op": "eq", "value": true}, {"field": "layer1_india.domestic_income.presumptive_scheme", "op": "eq", "value": []}]}'::jsonb,
  NULL,
  NULL,
  40,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.gst_collected_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR)',
  'integer',
  NULL,
  '{"field": "layer1_india.domestic_income.gst_registration_status", "op": "eq", "value": "regular"}'::jsonb,
  NULL,
  NULL,
  41,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.rent_for_business_premises_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR) — s.30. Fully deductible.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  42,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.repairs_maintenance_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.30 (buildings) + s.31 (plant/machinery). Current',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  43,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.employee_salary_wages_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.36(1)(ii). Subject to s.43B actual payment rule.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  44,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.employee_bonus_commission_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.36(1)(ii). Subject to s.43B actual payment rule.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  45,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.interest_on_borrowed_capital_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.36(1)(iii). Must be for business purpose.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  46,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.insurance_premium_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.30 (premises) + s.31 (plant) + s.36(1)(i) (livestock).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  47,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.bad_debts_written_off_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.36(1)(vii). Must be previously included in',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  48,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.brokerage_on_fno_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — brokerage fees and commissions paid to broker for',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  49,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.exchange_charges_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — exchange transaction charges, SEBI turnover fees,',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  50,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.advisory_and_data_subscriptions_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — market data terminals (TradingView, Bloomberg),',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  51,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.internet_proportion_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — proportionate internet charges for trading vs',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  52,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.home_office_proportion_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — proportionate rent/electricity for room used',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  53,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.margin_interest_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — interest on margin funding / margin pledge facility.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  54,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.ca_professional_fees_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — CA and professional fees for F&O/business tax filing.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  55,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.other_business_expenses_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.37(1) residual. Revenue expenditure wholly and',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  56,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.total_cash_payments_exceeding_limit_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — aggregate of all cash payments exceeding the',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  57,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.has_related_party_payments',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'bool — s.40A(2). Are there any payments to specified related',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  58,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.payments_to_non_residents_no_tds_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.40(a)(i). Any interest, royalty, fees for',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  59,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.payments_to_residents_no_tds_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.40(a)(ia). Any sum payable to a resident on',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  60,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.employer_pf_esi_contribution_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — employer contribution to PF, ESI, gratuity fund.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  61,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.employer_pf_esi_paid_before_due_date',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Has the employer PF/ESI contribution been actually paid before',
  'boolean',
  NULL,
  '{"field": "layer1_india.domestic_income.employer_pf_esi_contribution_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  62,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35_own_revenue_research_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.35(1)(i). Revenue expenditure on own in-house',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  63,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35_own_capital_research_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.35(2). Capital expenditure on own scientific',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  64,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35_donation_to_approved_body_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.35(1)(ii) / s.35(2AA). Donation to approved',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  65,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35D_total_preliminary_expenses_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — total preliminary expenses eligible for',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  66,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35D_year_of_commencement',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'string e.g. "FY2023-24"',
  'string',
  NULL,
  '{"field": "layer1_india.domestic_income.s35D_total_preliminary_expenses_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  67,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35DDA_vrs_payments_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — total VRS (Voluntary Retirement Scheme) payments',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  68,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.s35DDA_first_year_of_payment',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'string e.g. "FY2023-24"',
  'string',
  NULL,
  '{"field": "layer1_india.domestic_income.s35DDA_vrs_payments_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  69,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.stt_paid_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — Securities Transaction Tax paid on F&O trades',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  70,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.expenses.ctt_paid_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — Commodities Transaction Tax paid on commodity',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  71,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Array of block objects — one per asset class.',
  'array',
  NULL,
  '{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "eq", "value": []}'::jsonb,
  NULL,
  NULL,
  72,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].asset_class',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"building_residential" (5%) | "building_commercial" (10%)',
  'enum',
  '["building_residential", "building_commercial", "building_temporary", "plant_machinery_general", "computers_peripherals", "motor_vehicles", "heavy_vehicles", "furniture_fittings", "intangible_assets", "books_annual", "books_other", "solar_energy", "wind_energy"]'::jsonb,
  NULL,
  NULL,
  NULL,
  73,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].opening_wdv_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR) — WDV at start of FY (1 April).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  74,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].additions_during_year_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — cost of assets added to this block during the FY.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  75,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].addition_date',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Date the asset was put to use. If on or after 1 October →',
  'date',
  NULL,
  '{"field": "layer1_india.domestic_income.additions_during_year_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  76,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].sale_consideration_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — consideration received for assets sold from',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  77,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].is_new_manufacturing_asset',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Is the addition a NEW asset used for manufacturing/production?',
  'boolean',
  NULL,
  '{"field": "layer1_india.domestic_income.additions_during_year_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  78,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.asset_blocks[].is_in_notified_backward_area',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'Is the asset installed in a notified backward area (Bihar, WB,',
  'boolean',
  NULL,
  '{"field": "layer1_india.domestic_income.additions_during_year_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  79,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.speculative_income_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — net P&L from intraday equity trades (bought and',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  80,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.speculative_turnover_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — sum of ABSOLUTE VALUE of each individual intraday',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  81,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.non_speculative_income_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — net P&L from F&O derivatives on recognised',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  82,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.fno_turnover_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — F&O turnover for s.44AB audit threshold.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  83,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.s41_remission_income_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.41(1). Amount obtained by way of remission or',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  84,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.s41_bad_debt_recovery_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — s.41(4). Recovery of a bad debt previously written',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  85,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.partner_income.entity_type',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"registered_firm" | "llp"',
  'enum',
  '["registered_firm", "llp"]'::jsonb,
  '{"field": "layer1_india.domestic_income.nature_of_business", "op": "contains", "value": "partner_in_firm"}'::jsonb,
  NULL,
  NULL,
  86,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.partner_income.remuneration_from_entity_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR) — salary, bonus, commission received by partner',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  87,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.partner_income.interest_on_capital_from_entity_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR) — interest on capital received by partner.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  88,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.partner_income.profit_share_exempt_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — share of profit from the firm/LLP.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  89,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.msme_payables',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Msme Payables',
  'array',
  NULL,
  '{"field": "layer1_india.domestic_income.presumptive_scheme", "op": "eq", "value": []}'::jsonb,
  NULL,
  NULL,
  90,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.msme_payables[].supplier_name',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'string — name of the micro/small enterprise supplier.',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  91,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.msme_payables[].amount_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'integer (INR) — amount payable to the MSME supplier.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  92,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.msme_payables[].invoice_date',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"YYYY-MM-DD" — date of acceptance of goods/services (appointed day).',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  93,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.msme_payables[].has_written_agreement',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'bool — drives the prescribed period:',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  94,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.msme_payables[].payment_date',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  '"YYYY-MM-DD" | null',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  95,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.amt_credit_bf_inr',
  'layer1_india',
  'domestic_income',
  'OPTIONAL',
  'integer (INR) — aggregate AMT credit carried forward from prior',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  96,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.business_income.amt_credit_bf_origin_ay',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'string e.g. "AY2015-16"',
  'string',
  NULL,
  '{"field": "layer1_india.domestic_income.amt_credit_bf_inr", "op": "gt", "value": 0}'::jsonb,
  NULL,
  NULL,
  97,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.has_agricultural_income',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Exempt under s.10(1) but triggers partial integration (DOM-05 §10).',
  'boolean',
  NULL,
  '{"field": "layer1_india.domestic_income.lock", "op": "in", "value": ["ROR", "RNOR"]}'::jsonb,
  NULL,
  NULL,
  98,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.domestic_income.agricultural_income_inr',
  'layer1_india',
  'domestic_income',
  'CONDITIONAL',
  'Agricultural Income Inr',
  'integer',
  NULL,
  '{"field": "layer1_india.domestic_income.has_agricultural_income", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  99,
  110
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: other_sources (order=120) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.has_other_sources_income',
  'layer1_india',
  'other_sources',
  'REQUIRED',
  'Has Other Sources Income',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.interest_savings_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Interest Savings Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.interest_fd_rd_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Interest Fd Rd Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.interest_bonds_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Interest Bonds Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.interest_on_it_refund_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Interest On It Refund Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.dividend_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Dividend Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.gifts_above_50k_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Gifts Above 50K Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.family_pension_gross_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Family Pension Gross Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.family_pension_standard_deduction_inr',
  'layer1_india',
  'other_sources',
  'DERIVED',
  'DERIVED | integer = MIN(15000, family_pension_gross_inr / 3)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.winnings_lottery_gaming_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Winnings Lottery Gaming Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.online_gaming_winnings_inr',
  'layer1_india',
  'other_sources',
  'OPTIONAL',
  'Online Gaming Winnings Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.other_sources.deemed_dividend_from_buyback_inr',
  'layer1_india',
  'other_sources',
  'DERIVED',
  'DERIVED | integer',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  120
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: deductions (order=130) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.epf_employee_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Epf Employee Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.ppf_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Ppf Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.elss_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Elss Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.life_insurance_premium_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Life Insurance Premium Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.principal_home_loan_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Principal Home Loan Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.nsc_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Nsc Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.tuition_fees_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Tuition Fees Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.sukanya_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Sukanya Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.tax_saving_fd_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Tax Saving Fd Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80C.scss_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Scss Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80CCD_1B.nps_additional_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Nps Additional Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80D.self_family_premium_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Self Family Premium Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80D.parents_premium_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Parents Premium Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80D.parents_are_senior',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Parents Are Senior',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80D.preventive_health_checkup_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Preventive Health Checkup Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80G',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'S80G',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80G[].donee_name',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Donee Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80G[].pan_of_donee',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Pan Of Donee',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80G[].amount_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Amount Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80G[].deduction_percent',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Deduction Percent',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80G[].with_qualifying_limit',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'With Qualifying Limit',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80TTA_TTB.savings_interest_inr',
  'layer1_india',
  'deductions',
  'DERIVED',
  'DERIVED — sum of savings interest from bank_accounts.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80TTA_TTB.applicable_section',
  'layer1_india',
  'deductions',
  'DERIVED',
  'DERIVED | "80TTA" | "80TTB" | null',
  'enum',
  '["80TTA", "80TTB"]'::jsonb,
  NULL,
  NULL,
  NULL,
  23,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80E.education_loan_interest_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Education Loan Interest Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  24,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80EEA_EE.affordable_home_loan_interest_inr',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Affordable Home Loan Interest Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  25,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.deductions.s80EEA_EE.loan_sanction_date',
  'layer1_india',
  'deductions',
  'OPTIONAL',
  'Loan Sanction Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  26,
  130
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: carry_forward_losses (order=140) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.has_brought_forward_losses',
  'layer1_india',
  'carry_forward_losses',
  'REQUIRED',
  'Has Brought Forward Losses',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.business_loss_cf',
  'layer1_india',
  'carry_forward_losses',
  'CONDITIONAL',
  '[{ "fy": "FY2022-23", "amount_inr": 250000 }, ...]',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.speculative_loss_cf',
  'layer1_india',
  'carry_forward_losses',
  'CONDITIONAL',
  '4-year CF. Offsets speculative income only.',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.stcg_loss_cf',
  'layer1_india',
  'carry_forward_losses',
  'CONDITIONAL',
  '8-year CF. Offsets STCG (any rate) and LTCG.',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.ltcg_loss_cf',
  'layer1_india',
  'carry_forward_losses',
  'CONDITIONAL',
  '8-year CF. Offsets LTCG only.',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.house_property_loss_cf',
  'layer1_india',
  'carry_forward_losses',
  'CONDITIONAL',
  '8-year CF. Offsets HP income only (current-year cap of ₹2L against other heads',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.carry_forward_losses.unabsorbed_depreciation_cf',
  'layer1_india',
  'carry_forward_losses',
  'OPTIONAL',
  'integer (INR). NO time limit. Offsets any head except salary.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  140
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: lrs_outbound (order=150) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.total_lrs_remitted_this_fy_inr',
  'layer1_india',
  'lrs_outbound',
  'OPTIONAL',
  'number (INR). Annual limit USD 250K. TCS 20% on investment > ₹10L (w.e.f. 1 Apr 2026).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.lrs_purpose',
  'layer1_india',
  'lrs_outbound',
  'OPTIONAL',
  '"investment"|"education_own_funds"|"education_loan"|"medical"|"travel"|"gift_donation"',
  'enum',
  '["investment", "education_own_funds", "education_loan", "medical", "travel", "gift_donation"]'::jsonb,
  NULL,
  NULL,
  NULL,
  2,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.has_foreign_assets',
  'layer1_india',
  'lrs_outbound',
  'CONDITIONAL',
  'bool. true → Schedule FA mandatory. ₹10L/yr BMA s.43 penalty for non-disclosure.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets',
  'layer1_india',
  'lrs_outbound',
  'OPTIONAL',
  'Per-asset rows for Schedule FA.',
  'array',
  NULL,
  '{"field": "layer1_india.lrs_outbound.has_foreign_assets", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  4,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets[].country',
  'layer1_india',
  'lrs_outbound',
  'CONDITIONAL',
  'Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets[].nature_of_asset',
  'layer1_india',
  'lrs_outbound',
  'CONDITIONAL',
  'Nature Of Asset',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets[].peak_balance_inr',
  'layer1_india',
  'lrs_outbound',
  'CONDITIONAL',
  'Peak Balance Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets[].closing_balance_inr',
  'layer1_india',
  'lrs_outbound',
  'CONDITIONAL',
  'Closing Balance Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets[].gross_interest_inr',
  'layer1_india',
  'lrs_outbound',
  'OPTIONAL',
  'Gross Interest Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.foreign_assets[].gross_proceeds_inr',
  'layer1_india',
  'lrs_outbound',
  'OPTIONAL',
  'Gross Proceeds Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.lrs_outbound.has_received_foreign_income',
  'layer1_india',
  'lrs_outbound',
  'CONDITIONAL',
  'true → Schedule FSI + FTC computation required.',
  'boolean',
  NULL,
  '{"field": "layer1_india.lrs_outbound.has_foreign_assets", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  11,
  150
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: tax_credits (order=160) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.advance_tax_q1_15jun_inr',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Advance Tax Q1 15Jun Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.advance_tax_q2_15sep_inr',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Advance Tax Q2 15Sep Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.advance_tax_q3_15dec_inr',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Advance Tax Q3 15Dec Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.advance_tax_q4_15mar_inr',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Advance Tax Q4 15Mar Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.tds_already_deducted_inr',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'integer (INR). Source: Form 26AS / AIS.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.form_26as_uploaded',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Form 26As Uploaded',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Foreign Tax Credit',
  'array',
  NULL,
  '{"_raw": "lock = \"ROR\" OR (lock = \"NR\" claiming s.91)", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  7,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].country',
  'layer1_india',
  'tax_credits',
  'CONDITIONAL',
  'Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].income_type',
  'layer1_india',
  'tax_credits',
  'OPTIONAL',
  'Income Type',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].foreign_income_in_foreign_ccy',
  'layer1_india',
  'tax_credits',
  'CONDITIONAL',
  'Foreign Income In Foreign Ccy',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].foreign_tax_in_foreign_ccy',
  'layer1_india',
  'tax_credits',
  'CONDITIONAL',
  'Foreign Tax In Foreign Ccy',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].foreign_currency',
  'layer1_india',
  'tax_credits',
  'CONDITIONAL',
  'Foreign Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].conversion_rate',
  'layer1_india',
  'tax_credits',
  'CONDITIONAL',
  'SBI TT buying rate, last day of preceding month, per Rule 128.',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].foreign_income_inr',
  'layer1_india',
  'tax_credits',
  'DERIVED',
  'Foreign Income Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.tax_credits.foreign_tax_credit[].foreign_tax_inr',
  'layer1_india',
  'tax_credits',
  'DERIVED',
  'Foreign Tax Inr',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  160
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: surcharge_buckets (order=170) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_normal_slab_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'DERIVED. Sum of: salary + house property + non-speculative business',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_stcg_111A_inr',
  'layer1_india',
  'surcharge_buckets',
  'OPTIONAL',
  'DERIVED. STT-paid equity STCG @ 20%.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_ltcg_112A_inr',
  'layer1_india',
  'surcharge_buckets',
  'OPTIONAL',
  'DERIVED. STT-paid equity LTCG @ 12.5% above ₹1.25L exemption.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_ltcg_112_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'DERIVED. Property / unlisted / debt-MF-pre-Apr23 LTCG @ 12.5%.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_stcg_other_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'DERIVED. Slab-rate STCG (debt MF post Apr 2023, etc.).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_dividend_inr',
  'layer1_india',
  'surcharge_buckets',
  'DERIVED',
  'DERIVED. Standalone dividend bucket for surcharge cap visibility.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_special_115BB_115BBJ_inr',
  'layer1_india',
  'surcharge_buckets',
  'OPTIONAL',
  'DERIVED. Lottery, gaming, online gaming — flat 30%.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.income_vda_115BBH_inr',
  'layer1_india',
  'surcharge_buckets',
  'OPTIONAL',
  'DERIVED. Crypto / VDA — flat 30%, no set-off, no deductions.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.surcharge_buckets.speculative_income_inr',
  'layer1_india',
  'surcharge_buckets',
  'OPTIONAL',
  'DERIVED. Intraday — slab rate but ring-fenced for set-off purposes.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  170
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: metadata (order=180) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.financial_year',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Financial Year',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.request_id',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Request Id',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.source',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Source',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.input_completeness',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Input Completeness',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.cii_confirmed_for_fy',
  'layer1_india',
  'metadata',
  'DERIVED',
  'bool — flips to true once CBDT notifies CII for the FY.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.schema_version',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Schema Version',
  'string',
  NULL,
  NULL,
  '"layer1_india_v5_1_final"',
  NULL,
  6,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.created_at',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Created At',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_india.metadata.last_updated_at',
  'layer1_india',
  'metadata',
  'DERIVED',
  'Last Updated At',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  180
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

-- ════════════════════════════════════════════════════════════
-- SCHEMA: LAYER1_US
-- ════════════════════════════════════════════════════════════

-- ── Section: profile (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.profile.date_of_birth',
  'layer1_us',
  'profile',
  'REQUIRED',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.profile.filing_status',
  'layer1_us',
  'profile',
  'REQUIRED',
  '"single" | "mfj" | "mfs" | "hoh" | "qss"',
  'enum',
  '["single", "mfj", "mfs", "hoh", "qss"]'::jsonb,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.profile.ssn_or_itin',
  'layer1_us',
  'profile',
  'OPTIONAL',
  'string — SSN (NNN-NN-NNNN) or ITIN (9NN-NN-NNNN).',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.profile.ssn_or_itin_type',
  'layer1_us',
  'profile',
  'REQUIRED',
  '"ssn" | "itin" | "none"',
  'enum',
  '["ssn", "itin", "none"]'::jsonb,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.profile.dependents_count',
  'layer1_us',
  'profile',
  'OPTIONAL',
  'integer — total dependents claimed.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.profile.spouse_is_us_person',
  'layer1_us',
  'profile',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_us.profile.filing_status", "op": "in", "value": ["mfj", "mfs", "hoh"]}'::jsonb,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: us_residency_detail (order=20) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.is_us_citizen',
  'layer1_us',
  'us_residency_detail',
  'REQUIRED',
  'bool. Pre-filled from Layer 0 is_us_citizen.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.has_green_card',
  'layer1_us',
  'us_residency_detail',
  'REQUIRED',
  'bool. Pre-filled from Layer 0 has_green_card.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.green_card_grant_date',
  'layer1_us',
  'us_residency_detail',
  'CONDITIONAL',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  '{"field": "layer0.has_green_card", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  3,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.i407_surrendered_date',
  'layer1_us',
  'us_residency_detail',
  'CONDITIONAL',
  '"YYYY-MM-DD" | nullable',
  'enum',
  '["YYYY-MM-DD"]'::jsonb,
  '{"_raw": "has_green_card = true (historical)", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  4,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.us_days_current_year',
  'layer1_us',
  'us_residency_detail',
  'REQUIRED',
  'integer (0–365)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.us_days_minus_1_year',
  'layer1_us',
  'us_residency_detail',
  'REQUIRED',
  'integer (0–365)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.us_days_minus_2_years',
  'layer1_us',
  'us_residency_detail',
  'REQUIRED',
  'integer (0–365)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.exempt_individual_status',
  'layer1_us',
  'us_residency_detail',
  'REQUIRED',
  '"none" | "f_student" | "j_scholar" | "g_diplomat" | "professional_athlete"',
  'enum',
  '["none", "f_student", "j_scholar", "g_diplomat", "professional_athlete"]'::jsonb,
  NULL,
  NULL,
  NULL,
  8,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.closer_connection_claim',
  'layer1_us',
  'us_residency_detail',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"and": [{"field": "layer1_us.us_residency_detail.spt_test_met", "op": "eq", "value": true}, {"field": "layer1_us.us_residency_detail.us_days_current_year", "op": "lt", "value": 183}]}'::jsonb,
  NULL,
  NULL,
  9,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.first_year_choice_election',
  'layer1_us',
  'us_residency_detail',
  'OPTIONAL',
  'bool — §7701(b)(4) first-year choice for partial-year residency.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.s6013g_joint_election',
  'layer1_us',
  'us_residency_detail',
  'OPTIONAL',
  'bool — NRA spouse elects to be treated as RA for joint filing.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.spt_day_count_weighted',
  'layer1_us',
  'us_residency_detail',
  'DERIVED',
  'DERIVED | number',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.spt_test_met',
  'layer1_us',
  'us_residency_detail',
  'DERIVED',
  'DERIVED | bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.final_us_residency_status',
  'layer1_us',
  'us_residency_detail',
  'DERIVED',
  'DERIVED | "US_CITIZEN" | "RESIDENT_ALIEN" | "NON_RESIDENT_ALIEN" | "DUAL_STATUS"',
  'enum',
  '["US_CITIZEN", "RESIDENT_ALIEN", "NON_RESIDENT_ALIEN", "DUAL_STATUS"]'::jsonb,
  NULL,
  NULL,
  NULL,
  14,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.residency_start_date',
  'layer1_us',
  'us_residency_detail',
  'DERIVED',
  'DERIVED | "YYYY-MM-DD" | nullable',
  'enum',
  '["YYYY-MM-DD"]'::jsonb,
  NULL,
  NULL,
  NULL,
  15,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.us_residency_detail.residency_end_date',
  'layer1_us',
  'us_residency_detail',
  'DERIVED',
  'DERIVED | "YYYY-MM-DD" | nullable',
  'enum',
  '["YYYY-MM-DD"]'::jsonb,
  NULL,
  NULL,
  NULL,
  16,
  20
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: state_residency (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.primary_state_of_residence',
  'layer1_us',
  'state_residency',
  'REQUIRED',
  '2-letter US state code e.g. "CA" | "NY" | "TX" | "FL" | "WA"',
  'enum',
  '["CA", "NY", "TX", "FL", "WA"]'::jsonb,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.moved_states_this_year',
  'layer1_us',
  'state_residency',
  'REQUIRED',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.previous_state',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  '2-letter US state code.',
  'string',
  NULL,
  '{"field": "layer1_us.state_residency.moved_states_this_year", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.move_date',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  '{"field": "layer1_us.state_residency.moved_states_this_year", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.state_days_in_current_state',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  'integer',
  'integer',
  NULL,
  '{"field": "layer1_us.state_residency.moved_states_this_year", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.ca_planning_departure',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"_raw": "primary_state_of_residence = \"CA\" OR previous_state = \"CA\"", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.ca_safe_harbor_employment_contract',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_us.state_residency.ca_planning_departure", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.ca_retains_property_or_voter_reg',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"field": "layer1_us.state_residency.ca_planning_departure", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.ny_183_day_rule_met',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"_raw": "primary_state_of_residence = \"NY\" OR previous_state = \"NY\"", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.state_residency.ny_permanent_place_of_abode',
  'layer1_us',
  'state_residency',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  '{"_raw": "primary_state_of_residence = \"NY\" OR previous_state = \"NY\"", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: income_us_source (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Wages W2',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].employer_name',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Employer Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].employer_ein',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Employer Ein',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].wages_box1_usd',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Wages Box1 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].federal_tax_withheld_usd',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Federal Tax Withheld Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].ss_wages_box3_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Ss Wages Box3 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].ss_tax_withheld_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Ss Tax Withheld Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].medicare_wages_box5_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Medicare Wages Box5 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].medicare_tax_withheld_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Medicare Tax Withheld Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].state_wages_box16_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'State Wages Box16 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].state_tax_withheld_box17_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'State Tax Withheld Box17 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.wages_w2[].is_statutory_employee',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Is Statutory Employee',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.self_employment.has_se_income',
  'layer1_us',
  'income_us_source',
  'REQUIRED',
  'Has Se Income',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.self_employment.gross_receipts_usd',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Gross Receipts Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.self_employment.expenses_usd',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Expenses Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.self_employment.qbi_eligible',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'bool — §199A pass-through deduction (made permanent by OBBBA).',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.self_employment.is_specified_service_trade',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'bool — consulting, financial services, health, law, etc. (SSTB)',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.interest_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Interest Us Source Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.ordinary_dividends_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Ordinary Dividends Us Source Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.qualified_dividends_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Subset of ordinary dividends taxed at LTCG rates (held > 60 days).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.stcg_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Short-term capital gains (held ≤ 1 year). Taxed at ordinary rates.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.ltcg_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Long-term capital gains (held > 1 year). 0%/15%/20% rates.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.rental_income_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Rental Income Us Source Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  23,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.royalty_income_us_source_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Royalty Income Us Source Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  24,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.k1_passthrough_income_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'K1 Passthrough Income Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  25,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.ira_distributions_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Ira Distributions Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  26,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.401k_distributions_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  '401K Distributions Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  27,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.social_security_benefits_usd',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Up to 85% taxable depending on combined income (US-002 §16.2).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  28,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Crypto Transactions',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  29,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions[].asset',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Asset',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  30,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions[].acquisition_date',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  31,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions[].disposal_date',
  'layer1_us',
  'income_us_source',
  'OPTIONAL',
  'Disposal Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  32,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions[].proceeds_usd',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Proceeds Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  33,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions[].cost_basis_usd',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Cost Basis Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  34,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_us_source.crypto_transactions[].is_long_term',
  'layer1_us',
  'income_us_source',
  'CONDITIONAL',
  'Is Long Term',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  35,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: income_foreign_source (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Foreign Wages',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].source_country',
  'layer1_us',
  'income_foreign_source',
  'CONDITIONAL',
  'Source Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].employer_name',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Employer Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].gross_wages_local_ccy',
  'layer1_us',
  'income_foreign_source',
  'CONDITIONAL',
  'Gross Wages Local Ccy',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].local_currency',
  'layer1_us',
  'income_foreign_source',
  'CONDITIONAL',
  'Local Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].gross_wages_usd',
  'layer1_us',
  'income_foreign_source',
  'DERIVED',
  'Gross Wages Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].foreign_tax_withheld_local_ccy',
  'layer1_us',
  'income_foreign_source',
  'CONDITIONAL',
  'Foreign Tax Withheld Local Ccy',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_wages[].foreign_tax_withheld_usd',
  'layer1_us',
  'income_foreign_source',
  'DERIVED',
  'Foreign Tax Withheld Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_interest_usd',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Includes NRO/NRE interest. NRE interest is India-exempt but US-taxable',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_dividends_usd',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Indian dividends: 25% India TDS (DTAA Art. 10) → FTC passive basket.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_stcg_usd',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Foreign Stcg Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_ltcg_usd',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Indian property CG: India taxes first (DTAA Art. 13) → FTC general basket.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_rental_income_usd',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Foreign Rental Income Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.foreign_pension_income_usd',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Indian EPF/PPF distributions: complex US treatment. PPF treated as foreign',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Section 988 Gains Losses',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses[].transaction_date',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Transaction Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses[].amount_local_ccy',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Amount Local Ccy',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses[].local_currency',
  'layer1_us',
  'income_foreign_source',
  'CONDITIONAL',
  'Local Currency',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses[].rate_at_receipt',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Rate At Receipt',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses[].rate_at_conversion',
  'layer1_us',
  'income_foreign_source',
  'OPTIONAL',
  'Rate At Conversion',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.income_foreign_source.section_988_gains_losses[].gain_or_loss_usd',
  'layer1_us',
  'income_foreign_source',
  'DERIVED',
  'Gain Or Loss Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: equity_compensation (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.has_equity_comp',
  'layer1_us',
  'equity_compensation',
  'REQUIRED',
  'Has Equity Comp',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Iso Exercises',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].company_name',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].grant_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Grant Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].exercise_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Exercise Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].number_of_shares',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Number Of Shares',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].exercise_price',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Exercise Price',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].fmv_on_exercise_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'PER SHARE, USD. CRITICAL — drives the AMT preference item:',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].shares_sold_same_year',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Shares Sold Same Year',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].sale_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Sale Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].sale_price_per_share',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Sale Price Per Share',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.iso_exercises[].amt_preference_inr',
  'layer1_us',
  'equity_compensation',
  'DERIVED',
  'DERIVED | USD — feeds amt_inputs.iso_preference_total_usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Nso Exercises',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises[].company_name',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises[].exercise_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Exercise Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises[].number_of_shares',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Number Of Shares',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises[].exercise_price',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Exercise Price',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises[].fmv_on_exercise_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Fmv On Exercise Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.nso_exercises[].ordinary_income_at_exercise_usd',
  'layer1_us',
  'equity_compensation',
  'DERIVED',
  'Ordinary Income At Exercise Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Rsu Vestings',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings[].company_name',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings[].vest_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Vest Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings[].shares_vested',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Shares Vested',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  23,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings[].fmv_on_vest_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Fmv On Vest Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  24,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings[].ordinary_income_at_vest_usd',
  'layer1_us',
  'equity_compensation',
  'DERIVED',
  'Ordinary Income At Vest Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  25,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.rsu_vestings[].shares_withheld_for_tax',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Shares Withheld For Tax',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  26,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Espp Purchases',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  27,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].company_name',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  28,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].purchase_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Purchase Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  29,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].shares_purchased',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Shares Purchased',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  30,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].purchase_price',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Purchase Price',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  31,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].fmv_on_purchase_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Fmv On Purchase Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  32,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].fmv_on_offering_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Fmv On Offering Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  33,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.espp_purchases[].is_qualifying_disposition',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Is Qualifying Disposition',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  34,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Unvested Restricted Stock Awards',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  35,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].company_name',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'Company Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  36,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].grant_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Grant Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  37,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].number_of_unvested_shares',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Number Of Unvested Shares',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  38,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].fmv_at_grant_per_share_usd',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Used to compute the §83(b) inclusion amount = shares × (fmv − price paid).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  39,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].price_paid_per_share_usd',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'Price Paid Per Share Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  40,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].section_83b_election_filed_within_30_days',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  41,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].section_83b_filing_date',
  'layer1_us',
  'equity_compensation',
  'CONDITIONAL',
  '"YYYY-MM-DD"',
  'date',
  NULL,
  '{"field": "layer1_us.equity_compensation.section_83b_election_filed_within_30_days", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  42,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].section_83b_inclusion_amount_usd',
  'layer1_us',
  'equity_compensation',
  'DERIVED',
  'DERIVED | USD = number_of_unvested_shares × (fmv_at_grant − price_paid)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  43,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.equity_compensation.unvested_restricted_stock_awards[].vesting_schedule_summary',
  'layer1_us',
  'equity_compensation',
  'OPTIONAL',
  'string — free text for audit trail e.g. "4yr / 1yr cliff / monthly"',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  44,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: foreign_earned_income (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.claims_feie',
  'layer1_us',
  'foreign_earned_income',
  'OPTIONAL',
  'Claims Feie',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.qualification_test',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  '"physical_presence" | "bona_fide_residence"',
  'enum',
  '["physical_presence", "bona_fide_residence"]'::jsonb,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.tax_home_country',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  'Tax Home Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.physical_presence_start_date',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  'Physical Presence Start Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.physical_presence_end_date',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  'Physical Presence End Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.days_in_us_during_test_period',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  'Days In Us During Test Period',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.bona_fide_residence_start_date',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  'Bona Fide Residence Start Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.foreign_earned_income_usd',
  'layer1_us',
  'foreign_earned_income',
  'CONDITIONAL',
  'Wages/SE income earned while tax home is abroad. Capped at FEIE limit:',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.feie_amount_claimed_usd',
  'layer1_us',
  'foreign_earned_income',
  'DERIVED',
  'DERIVED | USD = MIN(foreign_earned_income_usd, $132,900, days_qualifying / 365 × $132,900)',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.foreign_housing_expenses_usd',
  'layer1_us',
  'foreign_earned_income',
  'OPTIONAL',
  'Rent, utilities (excl. telephone), real/personal property insurance,',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.housing_exclusion_base_usd',
  'layer1_us',
  'foreign_earned_income',
  'DERIVED',
  'DERIVED | 16% of FEIE limit = $21,264 for 2026.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.housing_exclusion_cap_usd',
  'layer1_us',
  'foreign_earned_income',
  'DERIVED',
  'DERIVED | 30% of FEIE limit = $39,870 (location-adjusted upward for',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_earned_income.foreign_housing_exclusion_usd',
  'layer1_us',
  'foreign_earned_income',
  'DERIVED',
  'DERIVED | MAX(0, MIN(foreign_housing_expenses − base, cap − base))',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: bank_accounts (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Bank Accounts',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].bank_name',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Bank Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].country',
  'layer1_us',
  'bank_accounts',
  'CONDITIONAL',
  'Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].is_us_account',
  'layer1_us',
  'bank_accounts',
  'REQUIRED',
  'Is Us Account',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].account_type',
  'layer1_us',
  'bank_accounts',
  'REQUIRED',
  '"checking" | "savings" | "money_market" | "cd" | "brokerage_cash"',
  'enum',
  '["checking", "savings", "money_market", "cd", "brokerage_cash", "nro", "nre", "fcnr", "rfc"]'::jsonb,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].account_number_last_4',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Account Number Last 4',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].is_jointly_held',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Is Jointly Held',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].is_signature_authority_only',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Is Signature Authority Only',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].peak_balance_during_cy_usd',
  'layer1_us',
  'bank_accounts',
  'REQUIRED',
  'CRITICAL | USD',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].peak_balance_date',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Peak Balance Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].cy_end_balance_usd',
  'layer1_us',
  'bank_accounts',
  'REQUIRED',
  'CRITICAL | USD — closing balance on 31 Dec converted at year-end Treasury rate.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].interest_credited_cy_usd',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Annual interest credited. Routes to income_us_source.interest_us_source_usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].tax_withheld_cy_usd',
  'layer1_us',
  'bank_accounts',
  'OPTIONAL',
  'Foreign withholding tax (e.g., 30% NRO TDS). Routes to FTC passive basket.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].w8ben_filed_with_this_payor',
  'layer1_us',
  'bank_accounts',
  'CONDITIONAL',
  'W8Ben Filed With This Payor',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].w8ben_signature_date',
  'layer1_us',
  'bank_accounts',
  'CONDITIONAL',
  'W8Ben Signature Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].w8ben_expiry_date',
  'layer1_us',
  'bank_accounts',
  'DERIVED',
  '"YYYY-MM-DD" — DERIVED if signature_date is set: signature_date + 3 years,',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.bank_accounts[].treaty_country_claimed_with_this_payor',
  'layer1_us',
  'bank_accounts',
  'CONDITIONAL',
  'Treaty Country Claimed With This Payor',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: fbar_aggregate_peak_usd (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.fbar_aggregate_peak_usd',
  'layer1_us',
  'fbar_aggregate_peak_usd',
  'DERIVED',
  'DERIVED | USD — sum of peak_balance_during_cy_usd across foreign accounts.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: form_8938_required (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.form_8938_required',
  'layer1_us',
  'form_8938_required',
  'DERIVED',
  'DERIVED | bool — applies the resident/foreign-resident threshold matrix',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: financial_holdings (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  'Financial Holdings',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].asset_name_or_ticker',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  'Asset Name Or Ticker',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].isin',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  'Isin',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].country_of_issuer',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Country Of Issuer',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].broker_name',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  'string e.g. "Schwab" | "Fidelity" | "IBKR" | "Zerodha"',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].asset_class',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  '"us_listed_equity" | "us_etf" | "us_mutual_fund" | "us_bond"',
  'enum',
  '["us_listed_equity", "us_etf", "us_mutual_fund", "us_bond", "foreign_listed_equity", "foreign_mutual_fund", "foreign_etf", "foreign_bond", "reit", "crypto"]'::jsonb,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].quantity',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Quantity',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].acquisition_date',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].cost_basis_usd',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Cost Basis Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].current_market_value_usd',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  'Current Market Value Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].peak_balance_during_cy_usd',
  'layer1_us',
  'financial_holdings',
  'REQUIRED',
  'Peak Balance During Cy Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].cy_end_balance_usd',
  'layer1_us',
  'financial_holdings',
  'REQUIRED',
  'Cy End Balance Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].is_pfic',
  'layer1_us',
  'financial_holdings',
  'REQUIRED',
  'bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].pfic_election',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  '"1291_default" | "mark_to_market" | "qef"',
  'enum',
  '["1291_default", "mark_to_market", "qef"]'::jsonb,
  '{"field": "layer1_us.financial_holdings.is_pfic", "op": "eq", "value": true}'::jsonb,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].pfic_election_first_year',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Pfic Election First Year',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].form_8621_filed_prior_years',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  'Form 8621 Filed Prior Years',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].sale_date',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Sale Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].sale_proceeds_usd',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Sale Proceeds Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].is_long_term',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Is Long Term',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].wash_sale_disallowed_loss_usd',
  'layer1_us',
  'financial_holdings',
  'OPTIONAL',
  '§1091 wash sale: 30-day window before/after sale; disallows loss on',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].w8ben_filed_with_this_broker',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'W8Ben Filed With This Broker',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].w8ben_signature_date',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'W8Ben Signature Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].w8ben_expiry_date',
  'layer1_us',
  'financial_holdings',
  'DERIVED',
  '"YYYY-MM-DD" — DERIVED if signature_date is set: signature_date + 3 years,',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  23,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.financial_holdings[].treaty_country_claimed_with_this_broker',
  'layer1_us',
  'financial_holdings',
  'CONDITIONAL',
  'Treaty Country Claimed With This Broker',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  24,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: real_estate (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.has_real_estate_transaction',
  'layer1_us',
  'real_estate',
  'REQUIRED',
  'Has Real Estate Transaction',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties',
  'layer1_us',
  'real_estate',
  'OPTIONAL',
  'Properties',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].country',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].property_type',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  '"primary_residence" | "rental" | "vacation" | "investment" | "land"',
  'enum',
  '["primary_residence", "rental", "vacation", "investment", "land"]'::jsonb,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].address',
  'layer1_us',
  'real_estate',
  'OPTIONAL',
  'Address',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].acquisition_date',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].us_cost_basis_usd',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'CRITICAL: this is the US §1012 cost basis, NOT the India indexed cost.',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].improvements_capitalized_usd',
  'layer1_us',
  'real_estate',
  'OPTIONAL',
  'Improvements Capitalized Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].depreciation_taken_usd',
  'layer1_us',
  'real_estate',
  'OPTIONAL',
  'Depreciation Taken Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].sale_date',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'Sale Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].sale_proceeds_usd',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'Sale Proceeds Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].selling_expenses_usd',
  'layer1_us',
  'real_estate',
  'OPTIONAL',
  'Selling Expenses Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].section_121_eligible',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'bool — owned + used as primary 2 of last 5 years.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].section_121_exclusion_claimed_usd',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'Up to $250K single / $500K MFJ.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].section_1031_exchange',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  'bool. CRITICAL: §1031 does NOT apply to foreign property — cannot',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].section_54_india_exempt_us_taxable',
  'layer1_us',
  'real_estate',
  'DERIVED',
  'DERIVED | bool',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.real_estate.properties[].fmv_at_inheritance_usd',
  'layer1_us',
  'real_estate',
  'CONDITIONAL',
  '§1014 step-up basis (US side only). India side uses original owner cost.',
  'integer',
  NULL,
  '{"_raw": "acquired by inheritance", "_parse_error": true}'::jsonb,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: retirement_accounts (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.traditional_ira_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'Traditional Ira Contribution Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.roth_ira_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  '2026 phase-out: $165K single / $246K MFJ. Above → backdoor Roth route.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.backdoor_roth_executed',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'Backdoor Roth Executed',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.401k_employee_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  '401K Employee Contribution Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.401k_employer_match_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  '401K Employer Match Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.roth_401k_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'Roth 401K Contribution Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.hsa_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'Triple tax advantage. 2026 limits per IRS Rev. Proc. 2025-32.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.solo_401k_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'Solo 401K Contribution Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.sep_ira_contribution_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'Sep Ira Contribution Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.rmd_required',
  'layer1_us',
  'retirement_accounts',
  'DERIVED',
  'Rmd Required',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.rmd_amount_usd',
  'layer1_us',
  'retirement_accounts',
  'DERIVED',
  'Rmd Amount Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.indian_epf_balance_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'EPF: not US-tax-deferred. Employer contributions = current W-2 income for USC/RA.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.indian_ppf_balance_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'PPF: arguably foreign grantor trust. Forms 3520 + 3520-A may be required.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.retirement_accounts.indian_nps_balance_usd',
  'layer1_us',
  'retirement_accounts',
  'OPTIONAL',
  'NPS: similar foreign-pension complications.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: foreign_entities (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.owns_10_percent_foreign_corp',
  'layer1_us',
  'foreign_entities',
  'REQUIRED',
  'bool — gate',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'Foreign Corporations',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].corp_name',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Corp Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].country_of_incorporation',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Country Of Incorporation',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].ownership_percent',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Ownership Percent',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].is_cfc',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Is Cfc',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].is_pfic_corp',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Is Pfic Corp',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].category_5471',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  '"category_1" | "category_2" | "category_3" | "category_4" | "category_5"',
  'enum',
  '["category_1", "category_2", "category_3", "category_4", "category_5"]'::jsonb,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].cfc_tax_year_start',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  '"YYYY-MM-DD"',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].tested_income_usd',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Tested Income Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].tested_loss_usd',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'Tested Loss Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].subpart_f_income_usd',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'Subpart F Income Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].section_962_election_made',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'bool — per-year strategic election. Enables 40% §250 deduction and',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].high_tax_exception_elected',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'bool — §951A(c)(2)(A)(i)(III). Country-by-country annual election that',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].ptep_pool_pre_jun28_2025_usd',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'Previously-Taxed E&P — pre-OBBBA pool (20% FTC haircut on distribution).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_corporations[].ptep_pool_post_jun28_2025_usd',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'Previously-Taxed E&P — post-OBBBA pool (10% FTC haircut on distribution).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.owns_10_percent_foreign_partnership',
  'layer1_us',
  'foreign_entities',
  'REQUIRED',
  'bool — gate',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_partnerships',
  'layer1_us',
  'foreign_entities',
  'OPTIONAL',
  'Foreign Partnerships',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_partnerships[].partnership_name',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Partnership Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_partnerships[].country',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_partnerships[].ownership_percent',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Ownership Percent',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_partnerships[].category_8865',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  '"category_1" | "category_2" | "category_3" | "category_4"',
  'enum',
  '["category_1", "category_2", "category_3", "category_4"]'::jsonb,
  NULL,
  NULL,
  NULL,
  22,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_partnerships[].k1_income_usd',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'K1 Income Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  23,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.owns_foreign_disregarded_entity',
  'layer1_us',
  'foreign_entities',
  'REQUIRED',
  'Owns Foreign Disregarded Entity',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  24,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_entities.foreign_de_details',
  'layer1_us',
  'foreign_entities',
  'CONDITIONAL',
  'Foreign De Details',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  25,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: foreign_gifts_and_trusts (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.received_foreign_gifts_above_100k',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'REQUIRED',
  'bool — gate',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'OPTIONAL',
  'Foreign Gifts',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts[].donor_name',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'CONDITIONAL',
  'Donor Name',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts[].donor_relationship',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'OPTIONAL',
  'Donor Relationship',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts[].donor_country',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'CONDITIONAL',
  'Donor Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts[].gift_date',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'CONDITIONAL',
  'Gift Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts[].gift_value_usd',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'CONDITIONAL',
  'Gift Value Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_gifts[].gift_type',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'OPTIONAL',
  'Gift Type',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.is_us_beneficiary_of_foreign_trust',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'REQUIRED',
  'bool. Triggers Form 3520 (distributions) + Form 3520-A (annual info).',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.foreign_trust_details',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'CONDITIONAL',
  'Foreign Trust Details',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.foreign_gifts_and_trusts.received_gift_from_covered_expatriate',
  'layer1_us',
  'foreign_gifts_and_trusts',
  'OPTIONAL',
  'bool. CRITICAL: US RECIPIENT pays 40% on gifts/bequests from covered',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: itemized_deductions_and_credits (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.use_standard_or_itemized',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  '"standard" | "itemized" | "auto"',
  'enum',
  '["standard", "itemized", "auto"]'::jsonb,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.state_and_local_taxes_paid_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'SALT cap raised by OBBBA from $10,000 to $40,400 for 2026. Phase-out',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.mortgage_interest_paid_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Cap: interest on $750K of acquisition debt (post-Dec 2017 mortgages).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.mortgage_acquisition_date',
  'layer1_us',
  'itemized_deductions_and_credits',
  'CONDITIONAL',
  'Mortgage Acquisition Date',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.charitable_contributions_cash_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  '60% of AGI cap for cash to public charities.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.charitable_contributions_appreciated_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  '30% of AGI cap for appreciated property.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.medical_expenses_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Deductible above 7.5% of AGI threshold.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.casualty_loss_federal_disaster_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Casualty Loss Federal Disaster Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.hsa_contributions_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Above-the-line; mirrors retirement_accounts.hsa_contribution_usd for',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.student_loan_interest_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Student Loan Interest Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.educator_expenses_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Educator Expenses Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.child_tax_credit_dependents',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'integer — qualifying children under 17 with SSN.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  12,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.credit_for_other_dependents',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Credit For Other Dependents',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  13,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.child_and_dependent_care_expenses_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Child And Dependent Care Expenses Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  14,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.education_credits_aotc_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Education Credits Aotc Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  15,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.education_credits_llc_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Education Credits Llc Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  16,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.saver_credit_eligible',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Saver Credit Eligible',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  17,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.funded_529_plan',
  'layer1_us',
  'itemized_deductions_and_credits',
  'OPTIONAL',
  'Funded 529 Plan',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  18,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.529_contributions_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'CONDITIONAL',
  '529 Contributions Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  19,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.529_state_deduction_state',
  'layer1_us',
  'itemized_deductions_and_credits',
  'CONDITIONAL',
  '2-letter state — many states allow state-level deduction (NY $5K/$10K MFJ,',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  20,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.qbi_deduction_eligible',
  'layer1_us',
  'itemized_deductions_and_credits',
  'DERIVED',
  'Qbi Deduction Eligible',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  21,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.itemized_deductions_and_credits.qbi_deduction_usd',
  'layer1_us',
  'itemized_deductions_and_credits',
  'DERIVED',
  'Qbi Deduction Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  22,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: amt_inputs (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.iso_preference_total_usd',
  'layer1_us',
  'amt_inputs',
  'DERIVED',
  'DERIVED | sum of equity_compensation.iso_exercises[].amt_preference_inr.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.salt_addback_usd',
  'layer1_us',
  'amt_inputs',
  'DERIVED',
  'DERIVED | state_and_local_taxes_paid_usd (added back for AMT).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.private_activity_bond_interest_usd',
  'layer1_us',
  'amt_inputs',
  'OPTIONAL',
  'Tax-exempt for regular tax; AMT preference item.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.amt_exemption_usd',
  'layer1_us',
  'amt_inputs',
  'DERIVED',
  'DERIVED | OBBBA 2026: phase-out threshold reset to 2018 levels with',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.amti_usd',
  'layer1_us',
  'amt_inputs',
  'DERIVED',
  'Amti Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.tentative_minimum_tax_usd',
  'layer1_us',
  'amt_inputs',
  'DERIVED',
  'Tentative Minimum Tax Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.amt_due_usd',
  'layer1_us',
  'amt_inputs',
  'DERIVED',
  'Amt Due Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.amt_inputs.minimum_tax_credit_carryforward_usd',
  'layer1_us',
  'amt_inputs',
  'OPTIONAL',
  'From prior years. Offsets future regular tax when regular > AMT.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: niit_inputs (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.niit_inputs.modified_agi_usd',
  'layer1_us',
  'niit_inputs',
  'DERIVED',
  'Modified Agi Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.niit_inputs.niit_threshold_usd',
  'layer1_us',
  'niit_inputs',
  'DERIVED',
  'DERIVED | $200K single / $250K MFJ / $125K MFS. Not indexed for inflation.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.niit_inputs.net_investment_income_usd',
  'layer1_us',
  'niit_inputs',
  'DERIVED',
  'DERIVED | interest + dividends + cg + rental + royalty − allocable expenses.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.niit_inputs.niit_due_usd',
  'layer1_us',
  'niit_inputs',
  'DERIVED',
  'DERIVED | 3.8% × MIN(net_investment_income_usd, MAGI − threshold).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: ftc_inputs (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.claims_ftc',
  'layer1_us',
  'ftc_inputs',
  'OPTIONAL',
  'Claims Ftc',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.claims_ftc_simplified_under_300',
  'layer1_us',
  'ftc_inputs',
  'OPTIONAL',
  'bool — § election for ≤ $300 ($600 MFJ) of foreign tax, all passive,',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets',
  'layer1_us',
  'ftc_inputs',
  'OPTIONAL',
  'Ftc Baskets',
  'array',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].basket',
  'layer1_us',
  'ftc_inputs',
  'CONDITIONAL',
  '"passive" | "general" | "global_intangible_low_taxed_income"',
  'enum',
  '["passive", "general", "global_intangible_low_taxed_income", "foreign_branch", "treaty_resourced"]'::jsonb,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].source_country',
  'layer1_us',
  'ftc_inputs',
  'CONDITIONAL',
  'Source Country',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].foreign_source_income_usd',
  'layer1_us',
  'ftc_inputs',
  'CONDITIONAL',
  'Foreign Source Income Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].foreign_taxes_paid_usd',
  'layer1_us',
  'ftc_inputs',
  'CONDITIONAL',
  'CRITICAL UI HINT: the frontend MUST explicitly prompt the user to',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].ftc_limitation_usd',
  'layer1_us',
  'ftc_inputs',
  'DERIVED',
  'Ftc Limitation Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].ftc_allowed_usd',
  'layer1_us',
  'ftc_inputs',
  'DERIVED',
  'Ftc Allowed Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  9,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].ftc_carryback_1yr_usd',
  'layer1_us',
  'ftc_inputs',
  'OPTIONAL',
  'Ftc Carryback 1Yr Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  10,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.ftc_inputs.ftc_baskets[].ftc_carryforward_10yr_usd',
  'layer1_us',
  'ftc_inputs',
  'OPTIONAL',
  'Ftc Carryforward 10Yr Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  11,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: withholding_and_estimated (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.federal_withholding_total_usd',
  'layer1_us',
  'withholding_and_estimated',
  'DERIVED',
  'Federal Withholding Total Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.state_withholding_total_usd',
  'layer1_us',
  'withholding_and_estimated',
  'DERIVED',
  'State Withholding Total Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.estimated_tax_q1_apr15_usd',
  'layer1_us',
  'withholding_and_estimated',
  'OPTIONAL',
  'Estimated Tax Q1 Apr15 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.estimated_tax_q2_jun15_usd',
  'layer1_us',
  'withholding_and_estimated',
  'OPTIONAL',
  'Estimated Tax Q2 Jun15 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.estimated_tax_q3_sep15_usd',
  'layer1_us',
  'withholding_and_estimated',
  'OPTIONAL',
  'Estimated Tax Q3 Sep15 Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.estimated_tax_q4_jan15_usd',
  'layer1_us',
  'withholding_and_estimated',
  'OPTIONAL',
  'Quarter-wise required for §6654 underpayment penalty computation.',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.prior_year_total_tax_usd',
  'layer1_us',
  'withholding_and_estimated',
  'OPTIONAL',
  'For safe harbor: pay 100% of prior-year tax (110% if AGI > $150K).',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.withholding_and_estimated.additional_medicare_tax_owed_usd',
  'layer1_us',
  'withholding_and_estimated',
  'DERIVED',
  'DERIVED | 0.9% on wages/SE > $200K single / $250K MFJ. Employer does',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: nra_specific (order=999) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.files_form_1040nr',
  'layer1_us',
  'nra_specific',
  'CONDITIONAL',
  'Files Form 1040Nr',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.w8ben_aggregate_status',
  'layer1_us',
  'nra_specific',
  'DERIVED',
  'DERIVED | "all_filed" | "partial" | "none" | "expired"',
  'enum',
  '["all_filed", "partial", "none", "expired"]'::jsonb,
  NULL,
  NULL,
  NULL,
  2,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.form_w7_itin_application_filed',
  'layer1_us',
  'nra_specific',
  'CONDITIONAL',
  'bool — required for NRAs without SSN before any 1040-NR can be processed.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  3,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.us_eci_income_usd',
  'layer1_us',
  'nra_specific',
  'DERIVED',
  'DERIVED | USD',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.us_fdap_income_usd',
  'layer1_us',
  'nra_specific',
  'DERIVED',
  'DERIVED | USD',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  5,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.us_real_property_disposed',
  'layer1_us',
  'nra_specific',
  'CONDITIONAL',
  'bool — FIRPTA: 15% withholding on gross sale price by buyer (Form 8288).',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  6,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.firpta_withholding_usd',
  'layer1_us',
  'nra_specific',
  'CONDITIONAL',
  'Firpta Withholding Usd',
  'integer',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.nra_specific.is_lrs_investor',
  'layer1_us',
  'nra_specific',
  'CONDITIONAL',
  'bool — Indian resident investing in US markets via RBI''s LRS scheme.',
  'boolean',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  999
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


-- ── Section: metadata (order=200) ──
INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.us_calendar_year',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Us Calendar Year',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.request_id',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Request Id',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.source',
  'layer1_us',
  'metadata',
  'DERIVED',
  '"onboarding" | "annual_update" | "transaction_trigger" | "ca_review"',
  'enum',
  '["onboarding", "annual_update", "transaction_trigger", "ca_review"]'::jsonb,
  NULL,
  NULL,
  NULL,
  3,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.input_completeness',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Input Completeness',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  4,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.schema_version',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Schema Version',
  'string',
  NULL,
  NULL,
  '"layer1_us_v2_final"',
  NULL,
  5,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.obbba_threshold_table_version',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Pins the inflation-adjusted threshold table the engine uses for this row.',
  'string',
  NULL,
  NULL,
  '"rev_proc_2025_32"',
  NULL,
  6,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.created_at',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Created At',
  'string',
  NULL,
  NULL,
  NULL,
  NULL,
  7,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;

INSERT INTO field_registry
  (field_path, schema_name, section, classification,
   friendly_label, input_type, enum_values, enabled_if,
   default_value, default_label, wizard_order, section_order)
VALUES (
  'layer1_us.metadata.last_updated_at',
  'layer1_us',
  'metadata',
  'DERIVED',
  'Last Updated At',
  'date',
  NULL,
  NULL,
  NULL,
  NULL,
  8,
  200
)
ON CONFLICT (field_path) DO UPDATE SET
  schema_name    = EXCLUDED.schema_name,
  section        = EXCLUDED.section,
  classification = EXCLUDED.classification,
  friendly_label = EXCLUDED.friendly_label,
  input_type     = EXCLUDED.input_type,
  enum_values    = EXCLUDED.enum_values,
  enabled_if     = EXCLUDED.enabled_if,
  default_value  = EXCLUDED.default_value,
  default_label  = EXCLUDED.default_label,
  wizard_order   = EXCLUDED.wizard_order,
  section_order  = EXCLUDED.section_order;


COMMIT;

-- Verification query: run after seeding to confirm counts.
SELECT schema_name, classification, COUNT(*) AS n
FROM   field_registry
GROUP  BY schema_name, classification
ORDER  BY schema_name, classification;