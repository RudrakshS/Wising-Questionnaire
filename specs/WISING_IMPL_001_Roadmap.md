# WISING v5.0 — Implementation Roadmap

**Document ID:** WISING-IMPL-001 v1.0  
**Companion to:** WISING-ARCH-005 v2.0  
**Date:** April 2026

---

## STEP 1: DATABASE & STATE DESIGN

### 1.1 Create Tables

Run these in order. Total: 4 tables.

```sql
-- 1. Field Registry (seed FIRST — everything else depends on this)
CREATE TABLE field_registry (
    field_path      TEXT PRIMARY KEY,
    schema_name     TEXT NOT NULL CHECK (schema_name IN ('layer0','layer1_india','layer1_us')),
    section         TEXT NOT NULL,
    classification  TEXT NOT NULL CHECK (classification IN ('REQUIRED','OPTIONAL','DERIVED','CONDITIONAL')),
    friendly_label  TEXT NOT NULL,
    input_type      TEXT NOT NULL CHECK (input_type IN ('integer','boolean','enum','date','currency','string','array')),
    enum_values     JSONB,             -- e.g. ["NR","RNOR","ROR"] for enum fields
    enabled_if      JSONB,             -- structured gate: {"field":"india_days","op":"gte","value":60}
    default_value   JSONB,
    default_label   TEXT,
    wizard_order    INTEGER NOT NULL,
    section_order   INTEGER NOT NULL
);

-- 2. Tax State Snapshots (one active row per user per tax year)
CREATE TABLE tax_state_snapshots (
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
CREATE UNIQUE INDEX idx_active_snapshot
    ON tax_state_snapshots(user_id, tax_year_id) WHERE status = 'active';

-- 3. Event Log (append-only audit trail)
CREATE TABLE tax_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    tax_year_id     UUID NOT NULL,
    event_type      TEXT NOT NULL,
    payload         JSONB NOT NULL,
    caused_by       UUID,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_events_lookup ON tax_events(user_id, tax_year_id, created_at);

-- 4. Bridge Events (dual-jurisdiction shared life events)
CREATE TABLE bridge_events (
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
```

### 1.2 Seed the Field Registry

Walk through each JSONC schema file and insert one row per user-facing field. Here's the pattern for the first 15 fields (Layer 0 + India residency P0 fields):

```sql
INSERT INTO field_registry (field_path, schema_name, section, classification,
    friendly_label, input_type, enabled_if, default_value, default_label,
    wizard_order, section_order) VALUES

-- LAYER 0 (section_order = 1)
('layer0.is_indian_citizen', 'layer0', 'citizenship', 'REQUIRED',
 'Are you an Indian citizen?', 'boolean', NULL, NULL, NULL, 1, 1),

('layer0.is_pio_or_oci', 'layer0', 'citizenship', 'CONDITIONAL',
 'Are you a Person of Indian Origin (PIO) or OCI cardholder?', 'boolean',
 '{"field":"layer0.is_indian_citizen","op":"eq","value":false}', NULL, NULL, 2, 1),

('layer0.is_us_citizen', 'layer0', 'us_status', 'REQUIRED',
 'Are you a US citizen?', 'boolean', NULL, NULL, NULL, 3, 1),

('layer0.has_green_card', 'layer0', 'us_status', 'CONDITIONAL',
 'Do you hold a valid US Green Card?', 'boolean',
 '{"field":"layer0.is_us_citizen","op":"eq","value":false}', NULL, NULL, 4, 1),

('layer0.india_days', 'layer0', 'presence', 'REQUIRED',
 'How many days were you in India this tax year (Apr 2025 – Mar 2026)?', 'integer',
 NULL, NULL, NULL, 5, 1),

('layer0.was_in_us_this_year', 'layer0', 'presence', 'REQUIRED',
 'Were you in the United States at any point this calendar year?', 'boolean',
 NULL, NULL, NULL, 6, 1),

('layer0.us_days', 'layer0', 'presence', 'CONDITIONAL',
 'How many days were you in the US this calendar year?', 'integer',
 '{"field":"layer0.was_in_us_this_year","op":"eq","value":true}', NULL, NULL, 7, 1),

('layer0.has_india_source_income_or_assets', 'layer0', 'source_income', 'REQUIRED',
 'Do you have any India-source income or Indian assets?', 'boolean',
 NULL, NULL, NULL, 8, 1),

('layer0.has_us_source_income_or_assets', 'layer0', 'source_income', 'REQUIRED',
 'Do you have any US-source income or US assets?', 'boolean',
 NULL, NULL, NULL, 9, 1),

('layer0.liable_to_tax_in_another_country', 'layer0', 'passthrough', 'CONDITIONAL',
 'Are you liable to pay income tax in any other country this year?', 'boolean',
 '{"field":"layer0.is_indian_citizen","op":"eq","value":true}', NULL, NULL, 10, 1),

('layer0.left_india_for_employment_this_year', 'layer0', 'passthrough', 'CONDITIONAL',
 'Did you leave India this year for employment abroad?', 'boolean',
 '{"field":"layer0.is_indian_citizen","op":"eq","value":true}', NULL, NULL, 11, 1),

-- LAYER 1 INDIA — RESIDENCY DETAIL (section_order = 2)
('layer1_india.residency_detail.days_in_india_current_year', 'layer1_india',
 'residency_detail', 'REQUIRED',
 'Days in India this tax year (pre-filled from above)', 'integer',
 NULL, NULL, NULL, 1, 2),

('layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365', 'layer1_india',
 'residency_detail', 'CONDITIONAL',
 'Were you in India for 365+ days total in the 4 preceding tax years?', 'boolean',
 '{"and":[{"field":"layer1_india.residency_detail.days_in_india_current_year","op":"gte","value":60},{"field":"layer1_india.residency_detail.days_in_india_current_year","op":"lt","value":182}]}',
 NULL, NULL, 2, 2),

('layer1_india.residency_detail.india_source_income_above_15l', 'layer1_india',
 'residency_detail', 'CONDITIONAL',
 'Is your India-source income above ₹15 lakh this year?', 'boolean',
 '{"field":"layer0.has_india_source_income_or_assets","op":"eq","value":true}',
 NULL, NULL, 8, 2),

('layer1_india.profile.tax_regime', 'layer1_india', 'profile', 'REQUIRED',
 'Which tax regime do you want to use?', 'enum',
 NULL, '"NEW"', 'Assumed: New Tax Regime', 1, 3);
```

**Build task:** Walk through ALL fields in `specs/layer0_residency_final.jsonc`, `specs/layer1_india_v5_1_final.jsonc`, and `specs/layer1_us_v2_final.jsonc`. Use `wising_backend/seeds/seed_registry.py` to generate inserts — do not hand-write SQL. Seeder produces 656 registry rows total.

### 1.3 Completion Percentage Query

The completion percentage is computed in Python (not SQL) for determinism, but here's the data it reads:

```python
# In FastAPI endpoint — called on every field change
async def get_completion(user_id: UUID, tax_year_id: UUID, db: AsyncSession):
    snapshot = await db.execute(
        select(TaxStateSnapshot).where(
            TaxStateSnapshot.user_id == user_id,
            TaxStateSnapshot.tax_year_id == tax_year_id,
            TaxStateSnapshot.status == 'active'
        )
    )
    row = snapshot.scalar_one()

    registry = await db.execute(select(FieldRegistry))
    fields = registry.scalars().all()

    return compute_completion(
        field_registry=[f.__dict__ for f in fields],
        layer0_state=row.layer0_state,
        layer1_india=row.layer1_india,
        layer1_us=row.layer1_us,
        jurisdiction=row.jurisdiction,
        india_lock=row.india_lock,
        us_lock=row.us_lock,
    )
```

---

## STEP 2: THE CPA DECISION TREE (STATE MACHINE)

### 2.1 Architecture

```
field_registry (PostgreSQL)
    │
    │  GET /api/wizard/schema → returns field_registry rows
    │                           ordered by section_order, wizard_order
    ▼
XState machine (client-side, Next.js)
    │
    │  Evaluates enabled_if gates against current context
    │  Renders one question at a time
    │  On answer: PATCH /api/profile → backend patches JSONB + re-fires locks
    │  Backend returns: new lock values + completion + next relevant fields
    │
    ▼
Wizard renders next question
```

### 2.2 Frontend Implementation

```typescript
// /app/wizard/page.tsx — Next.js App Router

'use client';
import { useMachine } from '@xstate/react';
import { taxWizardMachine } from './machine';
import { QuestionCard } from './components/QuestionCard';

export default function WizardPage() {
  const [state, send] = useMachine(taxWizardMachine);

  const currentField = state.context.currentField;
  if (!currentField) return <ResultsView state={state} />;

  return (
    <QuestionCard
      field={currentField}
      onAnswer={(value) => send({ type: 'ANSWER', value })}
      onSkip={() => send({ type: 'SKIP' })}
    />
  );
}
```

```typescript
// /app/wizard/machine.ts — XState v5

import { setup, assign } from 'xstate';

// Field registry loaded from backend on page mount
type Field = {
  field_path: string;
  friendly_label: string;
  input_type: string;
  enum_values?: string[];
  enabled_if: any;
  classification: string;
  section: string;
};

export const taxWizardMachine = setup({
  types: {} as {
    context: {
      fields: Field[];            // field_registry rows, ordered
      currentIndex: number;       // pointer into fields[]
      currentField: Field | null;
      answers: Record<string, any>; // field_path → value
      jurisdiction: string | null;
      indiaLock: string | null;
      usLock: string | null;
      completion: { percentage: number; missing: string[] };
    };
    events:
      | { type: 'ANSWER'; value: any }
      | { type: 'SKIP' }
      | { type: 'BACKEND_RESPONSE'; data: any };
  },
  guards: {
    hasMoreFields: ({ context }) => context.currentIndex < context.fields.length,
    fieldIsRelevant: ({ context }) => {
      const field = context.fields[context.currentIndex];
      if (!field) return false;
      if (field.classification === 'DERIVED') return false;
      return evaluateGate(field.enabled_if, context.answers);
    },
  },
  actions: {
    advanceToNextRelevant: assign(({ context }) => {
      let idx = context.currentIndex + 1;
      while (idx < context.fields.length) {
        const f = context.fields[idx];
        if (f.classification !== 'DERIVED' && evaluateGate(f.enabled_if, context.answers)) {
          return { currentIndex: idx, currentField: f };
        }
        idx++;
      }
      return { currentIndex: idx, currentField: null }; // done
    }),
    saveAnswer: assign(({ context, event }) => {
      if (event.type !== 'ANSWER') return {};
      const field = context.currentField!;
      return {
        answers: { ...context.answers, [field.field_path]: event.value }
      };
    }),
    syncWithBackend: ({ context, event }) => {
      // Fire PATCH /api/profile with the new field value
      // Backend returns jurisdiction, locks, completion
      // Trigger BACKEND_RESPONSE event with result
    },
    applyBackendState: assign(({ context, event }) => {
      if (event.type !== 'BACKEND_RESPONSE') return {};
      const { jurisdiction, india_lock, us_lock, completion } = event.data;
      return { jurisdiction, indiaLock: india_lock, usLock: us_lock, completion };
    }),
  },
}).createMachine({
  id: 'wizard',
  initial: 'questioning',
  context: {
    fields: [],  // populated on init from GET /api/wizard/schema
    currentIndex: 0,
    currentField: null,
    answers: {},
    jurisdiction: null,
    indiaLock: null,
    usLock: null,
    completion: { percentage: 0, missing: [] },
  },
  states: {
    questioning: {
      always: [
        { target: 'done', guard: ({ context }) => !context.currentField },
      ],
      on: {
        ANSWER: {
          actions: ['saveAnswer', 'syncWithBackend'],
          target: 'waitingForBackend',
        },
        SKIP: {
          actions: 'advanceToNextRelevant',
          target: 'questioning',  // re-evaluate
        },
      },
    },
    waitingForBackend: {
      on: {
        BACKEND_RESPONSE: {
          actions: ['applyBackendState', 'advanceToNextRelevant'],
          target: 'questioning',
        },
      },
    },
    done: {
      // All fields asked. Show results + "Evaluate Tax" button.
      on: {
        EVALUATE_TAX: 'computing',
        EDIT_FIELD: 'questioning',  // jump back to specific field
      },
    },
    computing: {
      invoke: {
        src: 'callEvaluateTax',
        onDone: { target: 'results', actions: 'applyBackendState' },
        onError: 'error',
      },
    },
    results: {
      on: {
        FILL_MORE: 'questioning',
        EVALUATE_TAX: 'computing',
      },
    },
    error: {},
  },
});

// Gate evaluator — deterministic, no AI
function evaluateGate(gate: any, answers: Record<string, any>): boolean {
  if (!gate) return true; // no gate = always shown

  if (gate.and) return gate.and.every((g: any) => evaluateGate(g, answers));
  if (gate.or) return gate.or.some((g: any) => evaluateGate(g, answers));

  const val = answers[gate.field];
  if (val === undefined || val === null) return false; // gate field not yet answered

  switch (gate.op) {
    case 'eq': return val === gate.value;
    case 'neq': return val !== gate.value;
    case 'gte': return val >= gate.value;
    case 'lt': return val < gate.value;
    case 'in': return gate.value.includes(val);
    default: return true;
  }
}
```

### 2.3 The `evaluateGate` function is the entire branching engine

No AI. No NLP. No fuzzy logic. The `enabled_if` JSON from the field_registry is a simple boolean expression tree. The gate evaluator is 20 lines of code. It is unit-testable with 100% branch coverage.

---

## STEP 3: THE EVENT-DRIVEN COMPUTE LOOP

### 3.1 API Endpoints (FastAPI)

```python
# ═══════════════════════════════════════════════════════════════
# /api/profile/{user_id}/{tax_year_id}  — PATCH
# Called on every wizard answer. Patches one field.
# ═══════════════════════════════════════════════════════════════

class FieldPatchRequest(BaseModel):
    schema: Literal["layer0", "layer1_india", "layer1_us"]
    field_path: str       # e.g. "india_days" or "residency_detail.india_source_income_above_15l"
    value: Any

class PatchResponse(BaseModel):
    jurisdiction: str | None
    india_lock: str | None
    us_lock: str | None
    lock_changed: bool
    lock_change_alert: dict | None
    completion: CompletionResult
    tax_estimate_stale: bool   # true if snapshot has changed since last compute

@router.patch("/api/profile/{user_id}/{tax_year_id}")
async def patch_field(user_id: UUID, tax_year_id: UUID, body: FieldPatchRequest, db: AsyncSession):
    # 1. Load snapshot
    snapshot = await load_active_snapshot(user_id, tax_year_id, db)
    old_jurisdiction = snapshot.jurisdiction
    old_india_lock = snapshot.india_lock
    old_us_lock = snapshot.us_lock

    # 2. Get old value for event log
    old_value = get_nested(snapshot, body.schema, body.field_path)

    # 3. Patch JSONB
    set_nested(snapshot, body.schema, body.field_path, body.value)

    # 4. Write event
    event = TaxEvent(
        user_id=user_id, tax_year_id=tax_year_id,
        event_type="field_update",
        payload={"schema": body.schema, "field": body.field_path,
                 "old": old_value, "new": body.value}
    )
    db.add(event)

    # 5. Re-fire Layer 0 Router (pure function, ~1ms)
    snapshot.jurisdiction = compute_jurisdiction(snapshot.layer0_state)

    # 6. Handle jurisdiction change
    if snapshot.jurisdiction != old_jurisdiction:
        handle_jurisdiction_transition(snapshot, old_jurisdiction)
        db.add(TaxEvent(user_id=user_id, tax_year_id=tax_year_id,
            event_type="jurisdiction_changed",
            payload={"old": old_jurisdiction, "new": snapshot.jurisdiction},
            caused_by=event.id))

    # 7. Re-fire locks (pure functions, ~1ms each)
    if snapshot.layer1_india is not None:
        snapshot.india_lock = compute_india_lock(
            snapshot.layer0_state, snapshot.layer1_india)
    if snapshot.layer1_us is not None:
        snapshot.us_lock = compute_us_lock(
            snapshot.layer0_state, snapshot.layer1_us)

    # 8. Detect lock changes
    lock_changed = (snapshot.india_lock != old_india_lock
                    or snapshot.us_lock != old_us_lock)
    alert = None
    if lock_changed:
        alert = build_lock_change_alert(
            old_india_lock, snapshot.india_lock,
            old_us_lock, snapshot.us_lock)
        db.add(TaxEvent(user_id=user_id, tax_year_id=tax_year_id,
            event_type="lock_changed", payload=alert, caused_by=event.id))

    # 9. Recompute completion
    completion = compute_completion(...)  # pure function
    snapshot.completion_pct = completion.percentage
    snapshot.completion_detail = completion.model_dump()

    # 10. Save + return
    snapshot.updated_at = datetime.utcnow()
    await db.commit()

    return PatchResponse(
        jurisdiction=snapshot.jurisdiction,
        india_lock=snapshot.india_lock,
        us_lock=snapshot.us_lock,
        lock_changed=lock_changed,
        lock_change_alert=alert,
        completion=completion,
        tax_estimate_stale=(snapshot.last_computed_at is not None),
    )


# ═══════════════════════════════════════════════════════════════
# /api/evaluate/{user_id}/{tax_year_id}  — POST
# Called when user clicks "Evaluate Tax". Runs full DAG.
# ═══════════════════════════════════════════════════════════════

class EvaluateResponse(BaseModel):
    status: Literal["APPROXIMATION", "FINAL"]
    completion: CompletionResult
    india_tax: dict | None
    us_tax: dict | None
    advisory_cards: list[dict]
    missing_for_final: list[dict]
    assumptions_used: list[dict]

@router.post("/api/evaluate/{user_id}/{tax_year_id}")
async def evaluate_tax(user_id: UUID, tax_year_id: UUID, db: AsyncSession):
    # 1. Load snapshot
    snapshot = await load_active_snapshot(user_id, tax_year_id, db)

    # 2. Log event
    db.add(TaxEvent(user_id=user_id, tax_year_id=tax_year_id,
        event_type="computation_requested", payload={}))

    # 3. Run DAG (synchronous, pure, ~500ms–2s)
    result = run_tax_dag(
        layer0=snapshot.layer0_state,
        layer1_india=snapshot.layer1_india,
        layer1_us=snapshot.layer1_us,
    )
    # result = { jurisdiction, india_lock, us_lock,
    #            india_tax: {...}, us_tax: {...},
    #            cross_flags: {...}, assumptions: [...] }

    # 4. Compute completion
    completion = compute_completion(...)

    # 5. Run advisory cards
    cards = run_advisory_engine(result, snapshot)

    # 6. Save result
    snapshot.computation_result = result
    snapshot.is_approximation = (completion.percentage < 100)
    snapshot.last_computed_at = datetime.utcnow()
    await db.commit()

    # 7. Log completion
    db.add(TaxEvent(user_id=user_id, tax_year_id=tax_year_id,
        event_type="computation_completed",
        payload={"completion_pct": completion.percentage,
                 "is_approximation": snapshot.is_approximation}))
    await db.commit()

    return EvaluateResponse(
        status="FINAL" if completion.percentage == 100 else "APPROXIMATION",
        completion=completion,
        india_tax=result.get("india_tax"),
        us_tax=result.get("us_tax"),
        advisory_cards=cards,
        missing_for_final=[
            {"field": f, "label": get_label(f)}
            for f in completion.missing_required
        ],
        assumptions_used=result.get("assumptions", []),
    )
```

---

## STEP 4: API PAYLOAD EXAMPLE

### 4.1 User Adds a Property Sale Mid-Year

The user has already completed onboarding (jurisdiction = dual, india_lock = NR, us_lock = RESIDENT_ALIEN). They now add a property sale.

**Request 1: Gate question**
```http
PATCH /api/profile/abc-123/fy2025-26
Content-Type: application/json

{
  "schema": "layer1_india",
  "field_path": "property.has_indian_property_transaction",
  "value": true
}
```

**Response 1:**
```json
{
  "jurisdiction": "dual",
  "india_lock": "NR",
  "us_lock": "RESIDENT_ALIEN",
  "lock_changed": false,
  "lock_change_alert": null,
  "completion": {
    "percentage": 65,
    "filled_required": 39,
    "total_required": 60,
    "is_approximation": true,
    "filing_ready": false,
    "missing_required": [
      "layer1_india.property.properties[0].sale_consideration",
      "layer1_india.property.properties[0].sale_date",
      "layer1_india.property.properties[0].acquisition_date",
      "layer1_india.property.properties[0].actual_cost",
      "layer1_india.property.properties[0].property_type"
    ],
    "missing_required_labels": [
      "What was the sale amount?",
      "When did you sell?",
      "When did you acquire this property?",
      "What was the purchase price?",
      "What type of property?"
    ],
    "optional_remaining": 12
  },
  "tax_estimate_stale": true
}
```

The wizard now shows the property detail questions one by one. After filling all property fields, the user clicks "Evaluate Tax."

**Request 2: Evaluate**
```http
POST /api/evaluate/abc-123/fy2025-26
```

**Response 2:**
```json
{
  "status": "APPROXIMATION",
  "completion": {
    "percentage": 82,
    "filled_required": 49,
    "total_required": 60,
    "is_approximation": true,
    "filing_ready": false,
    "missing_required": [
      "layer1_india.tax_credits.advance_tax_q1_15jun_inr",
      "layer1_india.tax_credits.advance_tax_q2_15sep_inr",
      "layer1_india.tax_credits.advance_tax_q3_15dec_inr",
      "layer1_india.tax_credits.advance_tax_q4_15mar_inr",
      "layer1_india.tax_credits.tds_already_deducted_inr",
      "layer1_india.property.properties[0].buyer_tds_deducted_inr",
      "layer1_us.real_estate.properties[0].us_cost_basis_usd",
      "layer1_us.real_estate.properties[0].sale_proceeds_usd"
    ],
    "missing_required_labels": [
      "Q1 advance tax paid (15 Jun)",
      "Q2 advance tax paid (15 Sep)",
      "Q3 advance tax paid (15 Dec)",
      "Q4 advance tax paid (15 Mar)",
      "Total TDS deducted (Form 26AS)",
      "TDS deducted by property buyer",
      "US cost basis of property (USD)",
      "US sale proceeds (USD)"
    ],
    "optional_remaining": 8
  },
  "india_tax": {
    "total_income_inr": 4850000,
    "gross_tax_inr": 682500,
    "surcharge_inr": 0,
    "cess_inr": 27300,
    "total_tax_inr": 709800,
    "tds_credit_inr": 0,
    "advance_tax_credit_inr": 0,
    "net_payable_inr": 709800,
    "regime_used": "NEW",
    "regime_comparison": { "old_regime": 735000, "new_regime": 709800 },
    "property_cg": {
      "sale_consideration_inr": 12000000,
      "cost_of_acquisition_inr": 5000000,
      "ltcg_inr": 7000000,
      "rate_applied": 0.125,
      "s54_exemption_inr": 0,
      "note": "No s.54 reinvestment claimed"
    }
  },
  "us_tax": {
    "agi_usd": 95000,
    "taxable_income_usd": 78900,
    "federal_tax_usd": 12340,
    "state_tax_usd": 3200,
    "property_gain_usd": 84337,
    "ftc_claimed_usd": 5100,
    "note": "India property gain included in worldwide income. §1031 does NOT apply to foreign property."
  },
  "advisory_cards": [
    {
      "card_id": "PLAN-S54-REINVEST-2025-26",
      "title": "Section 54 Reinvestment Window Open",
      "description": "You sold a residential property. If you reinvest in another residential property within 2 years, you can exempt up to ₹70,00,000 of LTCG. Deadline: Jan 2028.",
      "estimated_impact_inr": 875000,
      "deadline": "2028-01-15",
      "category": "TAX_SAVING"
    },
    {
      "card_id": "PLAN-S54-US-TRAP-2025-26",
      "title": "⚠ Section 54 Does NOT Reduce US Tax",
      "description": "Even if you claim s.54 in India, the US taxes the full property gain with zero FTC offset. Plan your US liability separately.",
      "estimated_impact_usd": 12650,
      "category": "COMPLIANCE"
    }
  ],
  "missing_for_final": [
    { "field": "layer1_india.tax_credits.tds_already_deducted_inr",
      "label": "Total TDS deducted (Form 26AS)" },
    { "field": "layer1_us.real_estate.properties[0].us_cost_basis_usd",
      "label": "US cost basis of property (USD)" }
  ],
  "assumptions_used": [
    { "field": "layer1_india.profile.tax_regime", "assumed": "NEW",
      "label": "Assumed New Tax Regime — change in Profile" },
    { "field": "layer1_india.property.properties[0].reinvestment_exemption_claimed",
      "assumed": "none", "label": "No s.54/54F/54EC reinvestment assumed" }
  ]
}
```

---

## BUILD ORDER

| Sprint | What | Deliverable | Days |
|--------|------|------------|------|
| **1** | Database DDL + field_registry seed (all 656 fields via seeder) | Tables created. Full registry populated. Engine modules split from PATCHED file. | 3 |
| **2** | PATCH endpoint + Router + Lock re-fire | Backend accepts field updates, returns jurisdiction + locks + completion. | 4 |
| **3** | XState wizard — Layer 0 flow (9 questions) + router result screen | User completes onboarding, sees jurisdiction. | 3 |
| **4** | XState wizard — India residency questions + lock result screen | India lock fires. Lock change alerts work. | 3 |
| **5** | XState wizard — US residency questions + lock result screen | US lock fires. Both locks work for dual users. | 3 |
| **6** | Output stamper + advisory card engine | APPROXIMATION/FINAL badge. All 8 cross-border trap cards emit. | 3 |
| **7** | Income section mini-wizards (salary, property, business, holdings) | User can fill all income data. Completion % is accurate. | 7 |
| **8** | ⚠ ON HOLD — India Math DAG | Pending architect review of `sprint2_math_dag.py`. DO NOT BEGIN. | — |
| **9** | ⚠ ON HOLD — US Math DAG | Depends on Sprint 8 unblocking. DO NOT BEGIN. | — |
| **10** | ⚠ ON HOLD — Cross-engine reconciliation + bridge events | Depends on Sprints 8 + 9. DO NOT BEGIN. | — |

**Sprints 1–7 total: ~30 dev-days.**
**Sprints 8–10 are deferred pending Layer 2 architect sign-off. See `ANTIGRAVITY_BUILD_PROMPT.md` Part 6.**
