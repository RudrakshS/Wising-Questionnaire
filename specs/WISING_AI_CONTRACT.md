# WISING AI Contract
## Exact JSON Payload Contracts for AI Intent Classifiers ↔ WizardStateMachine

**Document ID:** WISING-AI-CONTRACT v1.0  
**Companion to:** WISING-ARCH-005 v2.0 · WISING-IMPL-001 · WISING-SCHEMA-SPEC v5.3  
**Status:** APPROVED FOR ANTIGRAVITY  
**Date:** April 2026

---

## Foundational Rule: What AI May and May Not Do

> **The AI intent classifier is a TRANSLATOR, not a REASONER.**
> It converts natural language into structured field patches.
> It NEVER computes tax, NEVER guesses residency, and NEVER decides jurisdiction.
> Those are deterministic, legally auditable operations performed by the Python engine.

| Permitted | Forbidden |
|-----------|-----------|
| Identify which field the user is answering | Classify residency (NR/RNOR/ROR) |
| Extract a structured value from natural language | Compute flag values (india_flag, us_flag) |
| Ask a clarifying question when intent is ambiguous | Derive jurisdiction |
| Patch one or more fields in a single turn | Apply enabled_if gates itself |
| Surface the current wizard phase for context | Decide which Layer 1 module activates |
| Present lock-change alerts returned by the backend | Override engine-computed values |

The backend is the single source of truth. Every PATCH triggers a re-evaluation.
The AI sees only the response and uses it to drive the next question.

---

## System Overview: Request Flow

```
User utterance (NL)
        │
        ▼
AI Intent Classifier
  • Identifies intent type (field_patch | clarification | navigation | evaluate)
  • Extracts field_path + value from utterance
        │
        ▼ JSON payload
FastAPI PATCH /api/profile/{session_id}/{tax_year_id}
  • Validates field_path against field_registry
  • Patches JSONB layer in tax_state_snapshots
  • Re-fires jurisdiction router and/or residency locks
  • Re-computes completion_pct
        │
        ▼ JSON response
AI reads: jurisdiction, india_lock, us_lock, completion, lock_change_alert
  • Presents result to user
  • Asks next relevant question (driven by next_required_fields)
        │
        ▼
POST /api/evaluate/{session_id}/{tax_year_id}  (when user requests tax estimate)
```

---

## 1. Session Initialisation

### 1.1 Create Session

**POST** `/api/session`

**Request body:**
```json
{
  "user_id": "usr_a4f9e2b1",
  "tax_year": "FY2025-26",
  "timezone": "Asia/Kolkata"
}
```

**Response:**
```json
{
  "session_id": "sess_3d7b1c09",
  "tax_year_id": "ty_fy2025_26",
  "wizard_phase": "layer0_wizard",
  "completion": {
    "percentage": 0,
    "filled_required": 0,
    "total_required": 11,
    "is_approximation": true,
    "filing_ready": false
  },
  "next_required_fields": [
    {
      "field_path": "layer0.is_indian_citizen",
      "friendly_label": "Are you an Indian citizen?",
      "input_type": "boolean",
      "section": "jurisdiction_router"
    }
  ]
}
```

**AI behaviour after this response:**
Ask `next_required_fields[0]`. Do not ask more than one question per turn unless the questions are binary and obviously linked (e.g. citizenship + PIO).

---

## 2. Core PATCH Endpoint

### 2.1 Single Field Patch

**PATCH** `/api/profile/{session_id}/{tax_year_id}`

This is the primary endpoint. The AI calls it after each user answer.

**Request body — minimal form:**
```json
{
  "schema": "layer0",
  "field_path": "layer0.is_indian_citizen",
  "value": true
}
```

**Request body — full form (preferred for audit trail):**
```json
{
  "schema": "layer0",
  "field_path": "layer0.is_indian_citizen",
  "value": true,
  "source": "ai_classifier",
  "raw_utterance": "Yes, I'm an Indian citizen",
  "confidence": 0.98
}
```

**Field: `schema`**  
Must be one of: `"layer0"` | `"layer1_india"` | `"layer1_us"`  
Must match the schema prefix in `field_path`.

**Field: `value`** — type rules:

| input_type | Accepted values |
|------------|----------------|
| `boolean`  | `true` \| `false` (JSON bool, never string) |
| `integer`  | JSON number, no quotes, no commas, no currency symbols |
| `enum`     | String matching one of the enum_values in field_registry |
| `array`    | JSON array of strings for plain enum arrays; JSON array of objects for item arrays |
| `date`     | ISO 8601 string: `"YYYY-MM-DD"` |
| `string`   | Plain string |
| `currency` | String (10-char PAN: `"ABCDE1234F"`); treated as validated string |

**Full PATCH response:**
```json
{
  "session_id": "sess_3d7b1c09",
  "tax_year_id": "ty_fy2025_26",
  "jurisdiction": "dual",
  "india_lock": null,
  "us_lock": null,
  "wizard_phase": "layer0_wizard",
  "lock_changed": false,
  "lock_change_alert": null,
  "completion": {
    "percentage": 9,
    "filled_required": 1,
    "total_required": 11,
    "is_approximation": true,
    "filing_ready": false,
    "missing_required": [
      "layer0.india_days",
      "layer0.has_india_source_income_or_assets",
      "layer0.is_us_citizen",
      "layer0.was_in_us_this_year",
      "layer0.has_us_source_income_or_assets"
    ]
  },
  "newly_visible_fields": [
    {
      "field_path": "layer0.liable_to_tax_in_another_country",
      "friendly_label": "Are you liable to income tax in any other country?",
      "input_type": "boolean",
      "section": "jurisdiction_router",
      "enabled_if": {"field": "layer0.is_indian_citizen", "op": "eq", "value": true}
    },
    {
      "field_path": "layer0.left_india_for_employment_this_year",
      "friendly_label": "Did you leave India this year for employment abroad?",
      "input_type": "boolean",
      "section": "jurisdiction_router",
      "enabled_if": {"field": "layer0.is_indian_citizen", "op": "eq", "value": true}
    }
  ],
  "tax_estimate_stale": false,
  "next_required_fields": [
    {
      "field_path": "layer0.india_days",
      "friendly_label": "How many days were you in India this tax year (Apr 2025–Mar 2026)?",
      "input_type": "integer",
      "section": "jurisdiction_router"
    }
  ]
}
```

---

### 2.2 Batch Patch (Multi-field in one turn)

Use when the user's single utterance resolves multiple fields simultaneously.

**Example utterance:** *"I'm an Indian citizen who's never been to the US and has no US assets"*

**Request:**
```json
{
  "patches": [
    {
      "schema": "layer0",
      "field_path": "layer0.is_indian_citizen",
      "value": true
    },
    {
      "schema": "layer0",
      "field_path": "layer0.is_us_citizen",
      "value": false
    },
    {
      "schema": "layer0",
      "field_path": "layer0.was_in_us_this_year",
      "value": false
    },
    {
      "schema": "layer0",
      "field_path": "layer0.has_us_source_income_or_assets",
      "value": false
    }
  ],
  "source": "ai_classifier",
  "raw_utterance": "I'm an Indian citizen who's never been to the US and has no US assets"
}
```

**Response:** Same structure as single PATCH. Locks are re-evaluated once after all patches are applied.

**AI rule:** Never split a batch into sequential single PATCHes unless values are genuinely uncertain. Batching reduces round-trips and prevents intermediate lock states from confusing the user.

---

## 3. Layer 0 Wizard Flow — Field-by-Field Contract

The Layer 0 screen is a single-screen flow with max 9 questions and 2 conditional follow-ups. The AI must ask these in order, respecting enabled_if gates.

### 3.1 Complete Layer 0 Sequence

```
Q1: layer0.is_indian_citizen            (REQUIRED, boolean)
  └─ IF true → Q8: layer0.liable_to_tax_in_another_country  (CONDITIONAL, boolean)
  └─ IF true → Q9: layer0.left_india_for_employment_this_year (CONDITIONAL, boolean)
  └─ IF false → Q2: layer0.is_pio_or_oci (CONDITIONAL, boolean)

Q3: layer0.india_days                   (REQUIRED, integer 0–366)

Q4: layer0.has_india_source_income_or_assets (REQUIRED, boolean)

Q5: layer0.is_us_citizen                (REQUIRED, boolean)
  └─ IF false → Q6: layer0.has_green_card (CONDITIONAL, boolean)

Q7: layer0.was_in_us_this_year          (REQUIRED, boolean)
  └─ IF true → Q7b: layer0.us_days (CONDITIONAL, integer 0–365)

Q7c: layer0.has_us_source_income_or_assets (REQUIRED, boolean)

[DERIVED — never asked of user]:
  layer0.india_flag
  layer0.us_flag
  layer0.jurisdiction
```

### 3.2 Layer 0 Completion Trigger

When all REQUIRED fields and any applicable CONDITIONAL fields in Layer 0 are filled, the backend fires the jurisdiction router and returns:

```json
{
  "wizard_phase": "layer0_complete",
  "jurisdiction": "dual",
  "india_flag": true,
  "us_flag": true,
  "completion": {
    "percentage": 100,
    "filled_required": 11,
    "total_required": 11
  },
  "layer1_modules_activated": ["layer1_india", "layer1_us"],
  "next_phase_prompt": "india_residency"
}
```

**AI behaviour:** Present the jurisdiction result to the user clearly:
- `"dual"` → "You have filing obligations in both India and the US. Let's determine your India residency status first."
- `"india_only"` → "You have India filing obligations. Let's determine your residency status."
- `"us_only"` → "You have US filing obligations. Let's start with your US residency."
- `"none"` → "We need to review your situation with a CA. No standard module applies."

---

## 4. India Residency Lock — `patch_india_residency` Contract

### 4.1 Endpoint

**PATCH** `/api/profile/{session_id}/{tax_year_id}`

Same endpoint. The AI patches `layer1_india.residency_detail.*` fields.

### 4.2 Residency Detail Field Sequence

The backend enforces this evaluation order (from WISING-SCHEMA-SPEC §Layer 1 India Section 2):

```
Step 1: layer1_india.residency_detail.days_in_india_current_year   (PRE-FILLED from L0)
Step 2: layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365
        ENABLED IF: days_in_india_current_year >= 60 AND < 182
Step 3: layer1_india.residency_detail.employment_or_crew_status
        ENABLED IF: days >= 60 AND < 182 AND preceding_4yr = true AND is_indian_citizen
Step 4: layer1_india.residency_detail.is_departure_year
        ENABLED IF: employment_or_crew_status IN ["employed_abroad","indian_ship_crew","foreign_ship_crew"]
        layer1_india.residency_detail.ship_nationality
        ENABLED IF: employment_or_crew_status IN ["indian_ship_crew","foreign_ship_crew"]
Step 5: layer1_india.residency_detail.came_on_visit_to_india_pio_oci_citizen
        ENABLED IF: employment_or_crew_status = "none"
Step 6: layer1_india.residency_detail.nr_years_last_10_gte_9
        ENABLED IF: days >= 182 OR came_on_visit = false
        layer1_india.residency_detail.days_in_india_last_7_years_lte_729
        ENABLED IF: days >= 182 OR came_on_visit = false
Step 7: layer1_india.residency_detail.india_source_income_above_15l
        ENABLED IF: layer0.has_india_source_income_or_assets = true
Step 8: [DERIVED] liable_to_tax_in_another_country_being_indian_citizen
Step 9: [DERIVED] final_india_residency_status  ← THE LOCK
```

### 4.3 Example — Patch India Residency Field

**Request:**
```json
{
  "schema": "layer1_india",
  "field_path": "layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365",
  "value": true,
  "source": "ai_classifier",
  "raw_utterance": "Yes, I was in India for more than a year in total over the last 4 years"
}
```

### 4.4 Lock Fire Response

When the engine has enough data to set the India residency lock, the PATCH response includes:

```json
{
  "session_id": "sess_3d7b1c09",
  "wizard_phase": "india_locked",
  "jurisdiction": "dual",
  "india_lock": "NR",
  "us_lock": null,
  "lock_changed": true,
  "lock_change_alert": {
    "type": "INDIA_LOCK_SET",
    "previous_lock": null,
    "new_lock": "NR",
    "message": "India residency determined: Non-Resident (NR). Only India-source income is taxable.",
    "income_scope": "india_source_only",
    "sections_unlocked": [
      "india_dtaa",
      "india_compliance_docs",
      "india_bank_accounts",
      "india_financial_holdings"
    ],
    "sections_blocked": [
      "india_deductions",
      "india_lrs_outbound"
    ]
  },
  "completion": {
    "percentage": 22,
    "filled_required": 13,
    "total_required": 60,
    "is_approximation": true
  },
  "next_required_fields": [
    {
      "field_path": "layer1_india.profile.date_of_birth",
      "friendly_label": "What is your date of birth?",
      "input_type": "date"
    }
  ]
}
```

**AI behaviour on lock_change_alert:**
1. Present the lock result in plain language: *"Based on your answers, you are a Non-Resident (NR) for Indian tax purposes this year. This means only your India-source income is taxable in India."*
2. Do NOT speculate about what NR means for their tax liability. That is Layer 2's job.
3. Proceed to the next required field.

### 4.5 Lock Change Alert (Residency Flip Mid-Session)

If a user updates an upstream field (e.g., corrects india_days) and the lock changes, the response returns:

```json
{
  "lock_changed": true,
  "lock_change_alert": {
    "type": "INDIA_LOCK_CHANGED",
    "previous_lock": "NR",
    "new_lock": "RNOR",
    "message": "Your India residency has changed from NR to RNOR. Please review newly visible sections.",
    "downstream_invalidated": [
      "layer1_india.dtaa",
      "layer1_india.compliance_docs"
    ],
    "sections_newly_unlocked": ["india_deductions"],
    "sections_newly_blocked": ["india_dtaa"]
  },
  "tax_estimate_stale": true
}
```

**AI behaviour:** Explicitly tell the user their status changed. Do not silently proceed.

---

## 5. US Residency Lock — `patch_us_residency` Contract

### 5.1 US Residency Field Sequence

```
(PRE-FILLED from L0):
  layer1_us.us_residency_detail.is_us_citizen
  layer1_us.us_residency_detail.has_green_card
  layer1_us.us_residency_detail.us_days_current_year

User-provided:
  layer1_us.us_residency_detail.green_card_grant_date
  ENABLED IF: has_green_card = true

  layer1_us.us_residency_detail.i407_surrendered_date
  ENABLED IF: has_green_card = true

  layer1_us.us_residency_detail.us_days_minus_1_year    (REQUIRED)
  layer1_us.us_residency_detail.us_days_minus_2_years   (REQUIRED)
  layer1_us.us_residency_detail.exempt_individual_status (REQUIRED)
    enum: "none" | "f_student" | "j_scholar" | "g_diplomat" | "professional_athlete"

  layer1_us.us_residency_detail.closer_connection_claim
  ENABLED IF: spt_test_met = true AND us_days_current_year < 183

  layer1_us.us_residency_detail.first_year_choice_election   (OPTIONAL)
  layer1_us.us_residency_detail.s6013g_joint_election        (OPTIONAL)

[DERIVED]:
  spt_day_count_weighted
  spt_test_met
  final_us_residency_status  ← THE LOCK
  residency_start_date
  residency_end_date
```

### 5.2 US Lock Fire Response

```json
{
  "wizard_phase": "us_locked",
  "us_lock": "RESIDENT_ALIEN",
  "lock_changed": true,
  "lock_change_alert": {
    "type": "US_LOCK_SET",
    "new_lock": "RESIDENT_ALIEN",
    "spt_calculation": {
      "current_year_days": 190,
      "minus_1_year_days": 120,
      "minus_2_year_days": 60,
      "weighted_total": 200.0,
      "threshold": 183,
      "test_met": true
    },
    "message": "US residency determined: Resident Alien (RA) via Substantial Presence Test. You are taxed on worldwide income in the US.",
    "sections_unlocked": [
      "us_income_foreign_source",
      "us_feie"
    ]
  }
}
```

---

## 6. Income Section Patches — `patch_layer0` vs `patch_india_residency` vs Income

Once both locks are set, the AI patches income fields using the same PATCH endpoint.

### 6.1 Array Field Patch — Adding a New Array Item

For `goods_vehicles`, `asset_blocks`, `msme_payables`, `properties[]`, `transactions[]`, the AI sends the array with the new item appended.

**Request — first vehicle:**
```json
{
  "schema": "layer1_india",
  "field_path": "layer1_india.domestic_income.business_income.goods_vehicles",
  "value": [
    {
      "vehicle_type": "heavy",
      "gvw_tonnes": 16,
      "months_owned": 12
    }
  ]
}
```

**Request — second vehicle appended:**
```json
{
  "schema": "layer1_india",
  "field_path": "layer1_india.domestic_income.business_income.goods_vehicles",
  "value": [
    {
      "vehicle_type": "heavy",
      "gvw_tonnes": 16,
      "months_owned": 12
    },
    {
      "vehicle_type": "light",
      "gvw_tonnes": null,
      "months_owned": 8
    }
  ]
}
```

**Rule:** The AI always sends the FULL array, not a delta. The backend replaces the array atomically. This prevents partial-write race conditions.

### 6.2 Enum Array Patch (nature_of_business, presumptive_scheme)

```json
{
  "schema": "layer1_india",
  "field_path": "layer1_india.domestic_income.business_income.nature_of_business",
  "value": ["professional", "fno_trader"]
}
```

```json
{
  "schema": "layer1_india",
  "field_path": "layer1_india.domestic_income.business_income.presumptive_scheme",
  "value": []
}
```

**AI rule:** An empty array `[]` is a valid value for `presumptive_scheme` (means "regular computation"). Do NOT patch with `null`. These are fundamentally different: `null` means "not yet answered"; `[]` means "no presumptive scheme elected."

---

## 7. Evaluate Tax Endpoint

### 7.1 Request

**POST** `/api/evaluate/{session_id}/{tax_year_id}`

No request body required. The engine reads the current snapshot.

### 7.2 Response

```json
{
  "status": "APPROXIMATION",
  "completion": {
    "percentage": 74,
    "filled_required": 44,
    "total_required": 60,
    "is_approximation": true,
    "filing_ready": false,
    "missing_required": [
      "layer1_india.tax_credits.advance_tax_q1_15jun_inr",
      "layer1_india.tax_credits.tds_already_deducted_inr",
      "layer1_us.us_residency_detail.us_days_minus_1_year"
    ],
    "missing_required_labels": [
      "Q1 advance tax paid (15 Jun)",
      "Total TDS deducted (Form 26AS)",
      "US days in 2025 (prior year)"
    ]
  },
  "india_tax": {
    "total_income_inr": 3200000,
    "gross_tax_inr": 320000,
    "surcharge_inr": 0,
    "cess_inr": 12800,
    "total_tax_inr": 332800,
    "tds_credit_inr": 0,
    "advance_tax_credit_inr": 0,
    "net_payable_inr": 332800,
    "regime_used": "NEW",
    "regime_comparison": {
      "old_regime": 345000,
      "new_regime": 332800
    }
  },
  "us_tax": null,
  "advisory_cards": [],
  "missing_for_final": [
    {
      "field": "layer1_india.tax_credits.tds_already_deducted_inr",
      "label": "Total TDS deducted (Form 26AS)"
    }
  ],
  "assumptions_used": [
    {
      "field": "layer1_india.profile.tax_regime",
      "assumed": "NEW",
      "label": "Assumed New Tax Regime — change in Profile"
    }
  ]
}
```

**AI behaviour:**
- Present the estimate with the `is_approximation` flag visible.
- Surface the `missing_for_final` fields as a checklist.
- Do NOT present a FINAL estimate as if it is binding.
- Surface each `advisory_card` as a separate, actionable item with its deadline.

---

## 8. Income Threshold Feedback Loop (Audit Resolution #5)

When Layer 2 detects a discrepancy between the user's `india_source_income_above_15l` boolean and the computed income:

### 8.1 Alert Response (embedded in evaluate response)

```json
{
  "threshold_discrepancy_alert": {
    "type": "INCOME_THRESHOLD_DISCREPANCY",
    "current_flag": false,
    "computed_income_inr": 1850000,
    "threshold_inr": 1500000,
    "message": "Your computed India-source income is ₹18,50,000 — above the ₹15L Deemed Resident threshold. This may change your residency from NR to RNOR.",
    "options": [
      {
        "action": "UPDATE_AND_REEVALUATE",
        "label": "Update & Re-evaluate",
        "description": "Set india_source_income_above_15l = true and re-fire the residency lock. Max 2 iterations.",
        "endpoint": "PATCH layer1_india.residency_detail.india_source_income_above_15l = true"
      },
      {
        "action": "KEEP_CURRENT",
        "label": "Keep Current Status",
        "description": "Flag as INCOME_THRESHOLD_OVERRIDE_BY_USER for CA review. Lock unchanged.",
        "endpoint": "PATCH layer1_india.residency_detail.income_threshold_override_confirmed = true"
      }
    ],
    "iteration_count": 1,
    "max_iterations": 2
  }
}
```

**AI behaviour:** Present both options clearly. Do NOT make the choice for the user. If `iteration_count` reaches 2, tell the user this needs a CA review and disable the re-evaluate path.

---

## 9. Validation Error Responses

### 9.1 Unknown Field Path

**HTTP 422 Unprocessable Entity:**
```json
{
  "error": "UNKNOWN_FIELD_PATH",
  "field_path": "layer1_india.business.revenue",
  "message": "Field 'layer1_india.business.revenue' not found in field_registry. Check field_path spelling.",
  "did_you_mean": "layer1_india.domestic_income.business_income.turnover_inr"
}
```

### 9.2 Gate Violation (Patching a Gated Field Before Gate is Open)

**HTTP 422:**
```json
{
  "error": "GATE_CLOSED",
  "field_path": "layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365",
  "gate": {"and": [
    {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 60},
    {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "lt", "value": 182}
  ]},
  "message": "This field is only relevant when india_days is between 60 and 181. Current value: 45. Skip this field."
}
```

**AI behaviour:** Do NOT retry. Accept the skip and move on.

### 9.3 Type Mismatch

**HTTP 422:**
```json
{
  "error": "TYPE_MISMATCH",
  "field_path": "layer0.india_days",
  "expected_type": "integer",
  "received_value": "about 90 days",
  "message": "Value must be a whole number (0–366). Extract the integer from the user's response."
}
```

### 9.4 Enum Value Not Recognised

**HTTP 422:**
```json
{
  "error": "INVALID_ENUM_VALUE",
  "field_path": "layer1_india.domestic_income.business_income.presumptive_scheme",
  "received_value": ["44AD"],
  "valid_values": ["s44AD", "s44ADA", "s44AE"],
  "message": "Enum values must be prefixed with 's'. Did you mean 's44AD'?"
}
```

### 9.5 NR Ineligible for Presumptive Scheme

**HTTP 422:**
```json
{
  "error": "NR_INELIGIBLE_PRESUMPTIVE",
  "field_path": "layer1_india.domestic_income.business_income.presumptive_scheme",
  "india_lock": "NR",
  "attempted_value": ["s44AD"],
  "message": "s.44AD and s.44ADA require resident assessee (ROR or RNOR). Only s.44AE is available to NR users. Remove 's44AD' from the array.",
  "allowed_for_nr": ["s44AE"]
}
```

---

## 10. Wizard Phase Transition Map

```
layer0_wizard
    │ (all L0 required fields filled)
    ▼
layer0_complete  ── jurisdiction = "none" ──→  JURISDICTION_NONE (CA review)
    │
    ├── jurisdiction = "india_only" or "dual"
    │       ▼
    │   india_residency
    │       │ (residency lock fires)
    │       ▼
    │   india_locked
    │
    └── jurisdiction = "us_only" or "dual"
            ▼
        us_residency
            │ (residency lock fires)
            ▼
        us_locked

india_locked + us_locked (if dual)
    │
    ▼
income_sections
    │ (user fills income, deductions, credits)
    ▼
ready_to_evaluate
    │ (user clicks "Evaluate Tax")
    ▼
POST /api/evaluate  →  APPROXIMATION or FINAL
```

---

## 11. AI Classifier System Prompt Fragment

Include this fragment in the system prompt of the AI intent classifier to enforce the contract:

```
You are the Wising Tax Assistant. You collect tax information from the user
and translate it into structured JSON patches for the Wising backend.

STRICT RULES:
1. You NEVER compute tax, classify residency, or determine jurisdiction.
   These are computed by the backend engine — you only collect inputs.
2. Every user answer maps to a PATCH on a specific field_path.
   Always include the exact field_path, schema, and typed value.
3. Values must match the input_type exactly:
   - boolean: true/false (never "yes"/"no")
   - integer: number only (never "about 90 days" — extract the number)
   - enum: exact string from enum_values list (never free text)
   - array: JSON array (never null for enum-array fields — use [] for empty)
4. You ask ONE question per turn unless the user volunteers multiple answers.
5. When the backend returns a lock_change_alert, present it to the user
   in plain English before proceeding.
6. When the backend returns a gateway error (GATE_CLOSED), silently skip
   that field and move to the next one.
7. When the backend returns INCOME_THRESHOLD_DISCREPANCY, present both
   options and wait for explicit user choice before patching.
8. You do NOT guess field values. If the user is unsure, patch with null
   (which preserves the "not yet answered" state) and move on.

Current wizard_phase: {wizard_phase}
Current jurisdiction: {jurisdiction}
India lock: {india_lock}
US lock: {us_lock}
Completion: {completion_pct}%
```

---

## 12. Gap Register (Antigravity Blockers)

| ID | Gap | Location | Severity | Status |
|----|-----|----------|----------|--------|
| GAP-001 | `field_registry` DDL missing `enum_values JSONB` column | `wising_backend/migrations/sprint1_migration_DDL_ONLY.sql` | 🔴 BLOCKER | ✅ RESOLVED — column present in DDL_ONLY file |
| GAP-002 | `TaxEngineState.schema_version = "v4"` must be `"v5.1"` | `wising_backend/sprint1_input_layer_PATCHED.py` | 🟡 WARNING | ✅ RESOLVED — patched to `"v5.1"` |
| GAP-003 | `evaluate_gate()` missing `contains` operator for `"s44AD" IN presumptive_scheme` | `wising_backend/sprint1_input_layer_PATCHED.py` | 🔴 BLOCKER | ✅ RESOLVED — `contains` op added in PATCHED file |
| GAP-004 | `evaluate_gate()` missing `empty_array` / `eq []` operator for `presumptive_scheme = []` | `wising_backend/sprint1_input_layer_PATCHED.py` | 🔴 BLOCKER | ✅ RESOLVED — `eq []` op added in PATCHED file |
| GAP-005 | `compute_completion_pct()` treats empty array `[]` as "not filled" for array-type fields | `wising_backend/sprint1_input_layer_PATCHED.py` | 🟡 WARNING | ✅ RESOLVED — array fill logic patched |
| GAP-006 | `sprint1_migration.sql` hardcoded INSERT statements must be removed; seed via seeder only | `wising_backend/migrations/sprint1_migration_DDL_ONLY.sql` | 🔴 BLOCKER | ✅ RESOLVED — DDL_ONLY file has no INSERTs |
| GAP-007 | `layer0_residency_final.jsonc` DERIVED fields (`india_flag`, `us_flag`, `jurisdiction`) must be read-only on frontend | `specs/layer0_residency_final.jsonc` | 🟡 INFO | ✅ RESOLVED — seeder registers as DERIVED |
| GAP-008 | `patch_india_residency` endpoint does not yet enforce max-2-iteration limit on 15L feedback loop | `wising_backend/` (Sprint 3) | 🟡 WARNING | 🔲 OPEN — implement in Sprint 3 |

---

*End of WISING-AI-CONTRACT v1.0*
