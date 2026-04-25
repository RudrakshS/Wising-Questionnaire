# WISING v5.0 — Progressive Event-Driven Architecture Blueprint

**Document ID:** WISING-ARCH-005 v2.0  
**Status:** ARCHITECTURAL PROPOSAL — Requires CTO + CA + CPA sign-off before build  
**Date:** April 2026  
**Author:** Principal Systems Architect  
**Supersedes:** v1.0 (AI Translation Layer and Confidence Score removed per CTO review)

---

## EXECUTIVE POSITION: What Changes and What Does NOT

| Layer | What Changes | What Does NOT Change |
|-------|-------------|---------------------|
| **Frontend** | Rigid all-at-once forms → **Smart Conditional Wizard** (deterministic state machine, one question at a time, CPA-interview style) | — |
| **State Management** | Batch collection → Event-sourced, incremental state with partial profiles | — |
| **Layer 0 Router** | Runs reactively on every field change | Parallel Flag logic (india_flag × us_flag) is unchanged |
| **Layer 1 Schemas** | Fields get criticality tiers (Required / Optional) | The JSONC contracts, ENABLED IF gates, DERIVED fields — ZERO changes |
| **Layer 1 Locks** | Locks re-fire reactively on upstream change | RS-001 cascade, SPT cascade — ZERO changes to residency law logic |
| **Layer 2 Math DAG** | Re-invoked on every "Evaluate Tax" event | Pure functions, deterministic outputs — ZERO changes |
| **Tax Law** | — | Every rate, threshold, section reference, exemption rule — ZERO changes |

**The wizard is the CPA interviewer. The engine is the CPA's calculator.** The wizard follows a hardcoded decision tree to ask the right questions in the right order. The engine runs deterministic math on whatever data it has. No AI. No guessing. No probabilistic scores.

---

## PART 1: HIGH-LEVEL SYSTEM ARCHITECTURE

### 1.1 The Four-Layer Stack

```
┌──────────────────────────────────────────────────────────────────┐
│                 LAYER A: SMART CONDITIONAL WIZARD                 │
│  Next.js 14 + XState v5 finite state machine                     │
│  Renders: one question at a time, CPA-interview style             │
│  Branching: 100% deterministic, driven by ENABLED IF gates        │
│  from the Layer 1 JSONC schemas                                   │
│  Never computes tax. Never classifies residency.                  │
│  Every question maps to EXACTLY ONE schema field.                 │
└────────────────────────────┬─────────────────────────────────────┘
                             │ Typed field value (e.g., india_days: 120)
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│              LAYER B: STATE MANAGER + EVENT LOG                   │
│  FastAPI + PostgreSQL 15 (JSONB)                                  │
│  Stores: UserTaxProfile (Layer 0 + Layer 1 India + Layer 1 US)    │
│  Every field write = append-only event in tax_events table        │
│  On every field change:                                           │
│    1. Patch JSONB snapshot                                        │
│    2. Re-fire Layer 0 Router (jurisdiction)                       │
│    3. Re-fire Layer 1 Locks (residency) if inputs changed         │
│    4. Recompute completion_percentage                              │
│  Emits: lock_changed / jurisdiction_changed alerts to frontend    │
└────────────────────────────┬─────────────────────────────────────┘
                             │ On "Evaluate Tax" button click
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│              LAYER C: DETERMINISTIC MATH DAG                      │
│  FastAPI + Pure Python (Pydantic v2 models)                       │
│  The existing 3-layer engine:                                     │
│    Layer 0 Router → Layer 1 Locks → Layer 2 Computation           │
│  Residency Confirm → Asset Class → Income Compute → DTAA →       │
│  GTI → Surcharge & Marginal Relief → Final Tax → 234ABC           │
│  Input: validated JSONB snapshot (partial data OK — uses defaults) │
│  Output: TaxEstimate + CompletionPct + MissingRequiredFields      │
│  Any result on < 100% profile is stamped "APPROXIMATION"          │
└────────────────────────────┬─────────────────────────────────────┘
                             │ TaxEstimate
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│              LAYER D: PLANNING + PRESENTATION                     │
│  WISING-PLAN-001 card engine + completion tracker                 │
│  Renders: tax estimate, advisory cards, completion bar            │
│  Shows: "Profile 72% complete — Approximate tax: ₹4,23,500"      │
│  Shows: "Complete these 5 items for your final tax number"        │
│  At 100%: "FINAL" badge. Filing outputs (ITR XML/1040) enabled.  │
└──────────────────────────────────────────────────────────────────┘
```

### 1.2 Tech Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Frontend** | Next.js 14 (App Router) + React | Server Components for fast initial load |
| **Wizard State Machine** | XState v5 (runs client-side) | Deterministic FSM; the ENABLED IF gates from our JSONC schemas compile directly into XState transitions; serializable for persistence |
| **API** | FastAPI (Python 3.11+) | Pydantic v2 native; same language as Math DAG; no second runtime |
| **Database** | PostgreSQL 15 (JSONB) | Single store for partial profiles, event log, and computation results |
| **Math DAG** | Pure Python functions (in-process, same FastAPI worker) | No message queue needed. "Evaluate Tax" = synchronous POST. Deterministic. |
| **Deployment** | Azure Container Apps | Already in stack per eng spec |

### 1.3 What We Removed and Why

| Removed | Why |
|---------|-----|
| **AI Translation Layer (Claude Haiku)** | Compliance risk. An LLM misinterpreting "about 6 months" as 180 days when the user meant 183 = wrong residency = wrong tax. Every input must be explicit, typed, and confirmed by the user through deterministic UI controls. |
| **Confidence Score** | Legal liability. A "78% confident" tax number implies the other 22% might be wrong — inviting user distrust and regulatory scrutiny. Replaced with a simple, binary "X% complete / Approximation vs Final" that users and regulators understand. |
| **Temporal.io** | Over-engineered for a synchronous computation that takes < 2 seconds. A single FastAPI POST with Pydantic validation is sufficient. |
| **Redis** | Not needed. The completion percentage is a pure function of the JSONB snapshot — computed on every read, not cached. |
| **Azure Service Bus** | Not needed for MVP. Layer B calls Layer C directly. Add a queue later if we need async processing at scale. |

---

## PART 2: THE SMART CONDITIONAL WIZARD

### 2.1 How It Works

The wizard is a finite state machine (XState v5) that mirrors the ENABLED IF gates already defined in our Layer 0 and Layer 1 JSONC schemas. It asks questions one at a time, exactly like a CPA conducting an interview.

**Key principle: the wizard is a UI over the schema, not a separate system.** The wizard's transition table is auto-generated from the JSONC comments. No separate "question database."

```
WIZARD INTERVIEW FLOW (simplified):

  START
    │
    ├─ "Are you an Indian citizen?"                    → is_indian_citizen
    │   ├─ No → "Are you a PIO/OCI cardholder?"       → is_pio_or_oci
    │   └─ Yes → skip PIO/OCI
    │
    ├─ "Are you a US citizen?"                         → is_us_citizen
    │   ├─ No → "Do you hold a US Green Card?"         → has_green_card
    │   └─ Yes → skip GC
    │
    ├─ "How many days were you in India this tax year?" → india_days
    │
    ├─ "Were you in the US at all this calendar year?"  → was_in_us_this_year
    │   └─ Yes → "How many days?"                       → us_days
    │
    ├─ "Do you have India-source income or assets?"     → has_india_source_income_or_assets
    ├─ "Do you have US-source income or assets?"        → has_us_source_income_or_assets
    │
    ├─ [IF is_indian_citizen = true]:
    │   ├─ "Are you liable to tax in another country?"  → liable_to_tax_in_another_country
    │   └─ "Did you leave India for employment?"        → left_india_for_employment_this_year
    │
    ├─ ── ROUTER FIRES (jurisdiction derived) ──
    │   Frontend shows: "You have tax obligations in [India / US / Both]"
    │
    ├─ ── LAYER 1 RESIDENCY QUESTIONS (gated by jurisdiction) ──
    │   [IF india_flag]: India residency detail questions (days, preceding 4yr, etc.)
    │   [IF us_flag]: US residency detail questions (days CY/PY1/PY2, exempt status, etc.)
    │
    ├─ ── LOCKS FIRE ──
    │   Frontend shows: "India status: NR" / "US status: Resident Alien"
    │
    ├─ ── INCOME + ASSET SECTIONS (gated by locks) ──
    │   Each section is a mini-wizard:
    │   "Do you earn a salary?" → Yes → salary detail fields
    │   "Do you have Indian bank accounts?" → Yes → account detail fields
    │   "Did you sell property this year?" → Yes → property detail fields
    │   (User can skip any section → those fields stay null → completion drops)
    │
    ├─ ── "EVALUATE TAX" ENABLED ──
    │   (Enabled once ALL required fields for at least one lock path are filled)
    │
    └─ END (user can always return and fill more)
```

### 2.2 XState Machine Structure

```typescript
// Simplified — the real machine has ~40 states matching JSONC sections
import { createMachine, assign } from 'xstate';

const wizardMachine = createMachine({
  id: 'taxWizard',
  initial: 'layer0_citizenship',
  context: {
    // Mirrors the JSONB snapshot — partial data OK
    layer0: {},
    layer1_india: null,  // null until jurisdiction includes india
    layer1_us: null,     // null until jurisdiction includes us
    // Derived
    jurisdiction: null,
    india_lock: null,
    us_lock: null,
    completion: { percentage: 0, missing_required: [], filled: 0, total: 0 },
  },
  states: {
    // ── Layer 0 questions ──
    layer0_citizenship: {
      on: {
        ANSWER: {
          target: 'layer0_us_status',
          actions: assign({ layer0: (ctx, e) => ({...ctx.layer0, ...e.data}) })
        }
      }
    },
    layer0_us_status: {
      on: {
        ANSWER: [
          // Conditional transitions mirror ENABLED IF gates
          { target: 'layer0_india_days', actions: 'patchLayer0' }
        ]
      }
    },
    layer0_india_days: { /* ... */ },
    layer0_us_presence: { /* ... */ },
    layer0_source_income: { /* ... */ },
    layer0_passthrough: {
      // liable_to_tax, left_for_employment — only if indian citizen
      always: [
        { target: 'router_result', guard: 'isNotIndianCitizen' },
        { target: 'layer0_liable_to_tax' }
      ]
    },

    // ── Router fires ──
    router_result: {
      entry: 'deriveJurisdiction',
      // Show user: "You have obligations in India and the US"
      on: { CONTINUE: [
        { target: 'india_residency_detail', guard: 'hasIndiaFlag' },
        { target: 'us_residency_detail', guard: 'hasUsFlag' },
      ]}
    },

    // ── Layer 1 India residency ──
    india_residency_detail: {
      // Sub-machine: days, preceding_4yr, employment, visitor, income_15L
      // Fires india_lock on exit
      on: { LOCK_SET: [
        { target: 'us_residency_detail', guard: 'hasUsFlag' },
        { target: 'income_sections' }
      ]}
    },

    // ── Layer 1 US residency ──
    us_residency_detail: {
      // Sub-machine: citizen, GC, days, exempt, closer_connection
      // Fires us_lock on exit
      on: { LOCK_SET: 'income_sections' }
    },

    // ── Income + Asset sections (user can skip any) ──
    income_sections: {
      // Parallel state: user picks sections from a menu
      // Each section = sub-wizard with its own fields
      type: 'parallel',
      states: {
        salary: { /* gated by lock + has_salary_income */ },
        property: { /* gated by has_property_transaction */ },
        bank_accounts: { /* always shown */ },
        financial_holdings: { /* always shown */ },
        deductions: { /* gated by tax_regime + lock */ },
        // ... all other sections
      },
      on: { EVALUATE_TAX: 'computing' }
    },

    computing: {
      // Call Layer C backend
      invoke: {
        src: 'evaluateTax',
        onDone: 'results',
        onError: 'error'
      }
    },

    results: {
      // Show tax estimate + completion + missing fields
      on: {
        FILL_MORE: 'income_sections',
        UPDATE_FIELD: { actions: 'patchAndRecheck' }
      }
    }
  }
});
```

### 2.3 Why XState, Not a JSON Form Library

JSON form libraries (react-jsonschema-form, Formio) are great for flat forms. They are terrible for:
- Conditional branching that depends on DERIVED values (the jurisdiction and locks)
- Multi-step progressive disclosure where the user can jump back
- Serializable state that survives page refresh and session restore
- Parallel sub-machines (income sections are independent)

XState gives us all of this, and the state machine is inspectable and testable — you can unit-test "if user answers X, Y, Z, does the wizard reach state S?" without rendering any UI.

---

## PART 3: THE COMPLETION PERCENTAGE MODEL

### 3.1 Definition

Completion percentage is a simple, deterministic fraction:

```
completion_percentage = filled_relevant_required_fields / total_relevant_required_fields × 100
```

There is no weighting, no probabilistic scoring, no complexity penalties. It is a count.

### 3.2 Field Classification

Every field in the JSONC schemas is classified as:

| Classification | Definition | Effect on Completion |
|---------------|-----------|---------------------|
| **REQUIRED** | Must be filled for a legally correct tax computation | Counts toward denominator AND numerator (when filled) |
| **OPTIONAL** | Improves accuracy but engine can compute without it (uses safe default) | Does NOT affect completion percentage. Tracked separately as "optional items remaining." |
| **DERIVED** | Engine-computed, never user-input | Excluded from completion entirely |
| **CONDITIONAL** | REQUIRED, but only when its ENABLED IF condition is true | Counts toward denominator ONLY when the gate is active |

### 3.3 The Completion Engine (Pure Function)

```python
from dataclasses import dataclass

@dataclass
class CompletionResult:
    percentage: int               # 0–100, integer, no decimals
    filled_required: int          # count of filled required fields
    total_required: int           # count of relevant required fields
    missing_required: list[str]   # field paths that are required + empty
    missing_required_labels: list[str]  # human-readable labels
    optional_remaining: int       # count of unfilled optional fields
    is_approximation: bool        # True if percentage < 100
    filing_ready: bool            # True if percentage == 100


def compute_completion(
    field_registry: list[dict],
    layer0_state: dict,
    layer1_india: dict | None,
    layer1_us: dict | None,
    jurisdiction: str,
    india_lock: str | None,
    us_lock: str | None,
) -> CompletionResult:
    """
    Pure function. No database access. No side effects.
    Called on every field change and after every computation.
    """
    filled = 0
    total = 0
    missing = []
    missing_labels = []
    optional_remaining = 0

    for field in field_registry:
        # Skip DERIVED fields
        if field["classification"] == "DERIVED":
            continue

        # Skip fields not relevant to this user's jurisdiction
        if field["schema"] == "layer1_india" and jurisdiction not in ("india_only", "dual"):
            continue
        if field["schema"] == "layer1_us" and jurisdiction not in ("us_only", "dual"):
            continue

        # Evaluate ENABLED IF gate
        if not is_gate_active(field, layer0_state, layer1_india, layer1_us,
                              jurisdiction, india_lock, us_lock):
            continue

        # Get current value from snapshot
        value = get_nested_value(
            layer0_state if field["schema"] == "layer0"
            else layer1_india if field["schema"] == "layer1_india"
            else layer1_us,
            field["field_path"]
        )

        if field["classification"] == "OPTIONAL":
            if value is None:
                optional_remaining += 1
            continue  # Optional fields don't affect percentage

        # REQUIRED or CONDITIONAL (with active gate)
        total += 1
        if value is not None:
            filled += 1
        else:
            missing.append(field["field_path"])
            missing_labels.append(field["friendly_label"])

    pct = round(filled / total * 100) if total > 0 else 0

    return CompletionResult(
        percentage=pct,
        filled_required=filled,
        total_required=total,
        missing_required=missing[:20],       # cap for API response size
        missing_required_labels=missing_labels[:20],
        optional_remaining=optional_remaining,
        is_approximation=(pct < 100),
        filing_ready=(pct == 100),
    )
```

### 3.4 How It Renders

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  Your Tax Estimate (FY 2025-26)                              │
│                                                              │
│  Profile: ████████████░░░░░░ 72% Complete                    │
│  Status:  ⚠ APPROXIMATION                                    │
│                                                              │
│  India Tax:  ₹4,23,500 (approx.)                             │
│  US Tax:     $12,340 (approx.)                                │
│                                                              │
│  Complete these to get your final number:                     │
│  ☐ Property sale date and consideration                      │
│  ☐ TDS details from Form 26AS                                │
│  ☐ Section 54 reinvestment details                           │
│  ☐ W-8BEN filing status per broker                           │
│  ☐ Quarter-wise advance tax payments                         │
│                                                              │
│  [Fill Missing Items]   [Download Draft]   [Book CA Review]  │
│                                                              │
│  ───────────────────────────────────────────────────────────  │
│  At 100%: your tax number is FINAL and ITR/1040 filing is    │
│  enabled. Below 100%: all numbers are approximations.        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3.5 Completion Thresholds

| Percentage | Label | What's Enabled |
|-----------|-------|---------------|
| 0–49% | "Getting started" | Residency + jurisdiction shown. No tax numbers. |
| 50–99% | "APPROXIMATION" | Tax estimate shown with ⚠ badge. Advisory cards fire. Draft PDF. No ITR/1040 XML. |
| 100% | "FINAL" | Green badge. ITR XML / 1040 JSON generation enabled. CA review optional. |

Simple. Binary. No legal ambiguity.

---

## PART 4: THE EVENT-DRIVEN RE-COMPUTATION LOOP

### 4.1 What Happens on Every Field Change

```
User changes india_days from 200 → 45
    │
    ▼
Frontend (XState) sends: PATCH /api/profile/{user_id}/{tax_year_id}
  Body: { "schema": "layer0", "field": "india_days", "value": 45 }
    │
    ▼
Backend (Layer B — FastAPI):
    │
    ├─ 1. Validate: field exists in schema, type matches, range OK
    │
    ├─ 2. Write event: INSERT INTO tax_events (user_id, tax_year_id,
    │     event_type='field_update', payload={field, old:200, new:45})
    │
    ├─ 3. Patch snapshot: UPDATE tax_state_snapshots
    │     SET layer0_state = jsonb_set(layer0_state, '{india_days}', '45')
    │
    ├─ 4. Re-fire Layer 0 Router (cheap pure function of ~9 inputs):
    │     india_flag = true (citizen), us_flag = true (GC)
    │     jurisdiction = "dual" (unchanged)
    │
    ├─ 5. Re-fire India Lock (cheap pure function of ~8 inputs):
    │     days=45 → < 60 → check Deemed Resident path
    │     citizen=T, income_15L=T, liable_elsewhere=F → RNOR
    │     Previous lock: ROR → New lock: RNOR → CHANGED
    │
    ├─ 6. Write event: INSERT INTO tax_events
    │     (event_type='lock_changed', payload={schema:'layer1_india',
    │      old:'ROR', new:'RNOR', caused_by: <event_id from step 2>})
    │
    ├─ 7. Recompute completion_percentage (pure function)
    │
    └─ 8. Return response:
         {
           "jurisdiction": "dual",
           "india_lock": "RNOR",
           "us_lock": "RESIDENT_ALIEN",
           "lock_changed": true,
           "lock_change_alert": {
             "previous": "ROR",
             "current": "RNOR",
             "impacts": [
               "NRE interest is now taxable for the full year",
               "DTAA section is now available",
               "LRS outbound section is now hidden"
             ],
             "sections_now_visible": ["dtaa"],
             "sections_now_hidden": ["lrs_outbound"]
           },
           "completion": { "percentage": 68, "is_approximation": true,
                           "missing_required": [...] },
           "tax_estimate_stale": true
         }
    │
    ▼
Frontend (XState):
    Shows alert: "Your India status changed from ROR to RNOR. This affects
                  your tax. [Review Changes] [Evaluate Tax]"
    Wizard re-evaluates: some sections appear, others hide.
    "Evaluate Tax" button highlighted.
```

### 4.2 What Happens on "Evaluate Tax"

```
User clicks "Evaluate Tax"
    │
    ▼
Frontend sends: POST /api/evaluate/{user_id}/{tax_year_id}
    │
    ▼
Backend (Layer C — Deterministic Math DAG):
    │
    ├─ 1. Load snapshot from tax_state_snapshots (single JSONB read)
    │
    ├─ 2. Validate via Pydantic (permissive mode — nulls OK for optional)
    │
    ├─ 3. Step A: Confirm Jurisdiction (Layer 0 Router — re-run)
    │     → "dual"
    │
    ├─ 4. Step B: Confirm India Lock (RS-001 cascade — re-run)
    │     → "RNOR"
    │
    ├─ 5. Step C: Confirm US Lock (SPT cascade — re-run)
    │     → "RESIDENT_ALIEN"
    │
    ├─ 6. Step D: India Tax Computation (Layer 2 India DAG)
    │     ├─ Income assembly (salary + HP + business + CG + other_sources)
    │     ├─ DTAA rate override (if NR + TRC)
    │     ├─ GTI assembly
    │     ├─ Deductions (Chapter VI-A, regime comparison if RNOR)
    │     ├─ Slab tax
    │     ├─ Surcharge + marginal relief (per named buckets)
    │     ├─ Cess 4%
    │     ├─ Rebate s.87A (if eligible)
    │     ├─ Interest 234A/B/C (from quarter-wise advance tax)
    │     └─ → india_tax_result
    │
    ├─ 7. Step E: US Tax Computation (Layer 2 US DAG)
    │     ├─ Worldwide income assembly (if RA/USC) or ECI+FDAP (if NRA)
    │     ├─ Deductions (standard or itemized)
    │     ├─ Federal slab tax (OBBBA 2026 brackets)
    │     ├─ AMT check
    │     ├─ NIIT check (3.8% on NII)
    │     ├─ FTC computation (per basket, with India surcharge+cess hint)
    │     ├─ State tax (CA/NY/etc.)
    │     ├─ Estimated tax penalty check (§6654)
    │     └─ → us_tax_result
    │
    ├─ 8. Step F: Cross-Engine Reconciliation
    │     ├─ FTC: India tax paid → credit against US federal tax
    │     ├─ Bridge events: s.54 India exempt → US still taxable cross-flag
    │     ├─ Calendar split: India FY → US CY mapping
    │     └─ → reconciled_result
    │
    ├─ 9. Step G: Compute completion_percentage (pure function)
    │
    ├─ 10. Step H: Run PLAN-001 advisory card engine
    │
    ├─ 11. Write to snapshot:
    │     UPDATE tax_state_snapshots SET
    │       computation_result = <JSON>,
    │       completion_percentage = <int>,
    │       last_computed_at = now()
    │
    ├─ 12. Write event: INSERT INTO tax_events
    │     (event_type='computation_completed', payload={...})
    │
    └─ 13. Return response:
         {
           "status": "APPROXIMATION",  // or "FINAL" if 100%
           "completion": { "percentage": 72, ... },
           "india_tax": {
             "total_income_inr": 2850000,
             "tax_payable_inr": 423500,
             "regime_used": "NEW",
             "regime_comparison": { "old": 445000, "new": 423500 }
           },
           "us_tax": {
             "agi_usd": 95000,
             "federal_tax_usd": 12340,
             "state_tax_usd": 3200,
             "ftc_claimed_usd": 5100
           },
           "advisory_cards": [ ... ],
           "missing_for_final": [
             { "field": "property.sale_consideration", "label": "Property sale amount" },
             { "field": "tax_credits.advance_tax_q1_15jun_inr", "label": "Q1 advance tax" }
           ],
           "assumptions_used": [
             { "field": "profile.tax_regime", "assumed": "NEW",
               "label": "Assumed New Tax Regime (you can change this)" }
           ]
         }
```

### 4.3 Handling Missing Data in the DAG

When the DAG encounters a null field:

| Field Type | DAG Behavior |
|-----------|-------------|
| **Required + null** | Use safe default + flag assumption. E.g., `tax_regime = null` → use "NEW" + add to `assumptions_used`. |
| **Required for section but section gate = false** | Skip section entirely. If `has_salary_income = null`, assume no salary. |
| **Array field empty** | Treat as no items. E.g., `property.properties = []` → no property CG computed. |
| **Required + no safe default possible** | Omit that income head entirely. E.g., `sale_consideration = null` → property CG = 0 with explicit note: "Property income excluded — sale amount missing." |

The DAG NEVER throws an error on missing data. It always produces a result. The result is just less complete, and `is_approximation = true`.

---

## PART 5: STATE PRESERVATION AND SMART UPDATES

### 5.1 No Repetitive Questions

Once a user provides a field value, the wizard NEVER re-asks it. The field is pre-filled in the wizard state from the JSONB snapshot. The user can always click "Edit" on any previously answered field.

### 5.2 Context Shift Protocol

When a lock or jurisdiction changes, the wizard does NOT re-ask questions. It:

1. Shows an alert explaining what changed and why
2. Shows which sections are newly visible / newly hidden
3. Offers: "[Review Changes] [Keep My Answers]"
4. Previously entered data is PRESERVED (soft-hidden, never deleted)

### 5.3 Soft-Archive on Jurisdiction Change

| Transition | Action |
|-----------|--------|
| `dual` → `india_only` | `layer1_us` snapshot set to `status: 'archived'`. Not deleted. Restorable. |
| `india_only` → `dual` | Check for archived `layer1_us`. If found + < 30 days old → auto-restore. Else → instantiate empty. |

---

## PART 6: DATABASE SCHEMA

### 6.1 Core Tables

```sql
-- The user's tax profile for a given year. Single JSONB document per layer.
CREATE TABLE tax_state_snapshots (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    tax_year_id     UUID NOT NULL REFERENCES tax_years(id),

    -- The three schemas
    layer0_state    JSONB NOT NULL DEFAULT '{}',
    layer1_india    JSONB,          -- NULL if jurisdiction excludes india
    layer1_us       JSONB,          -- NULL if jurisdiction excludes us

    -- Derived (written by backend on every field change)
    jurisdiction        TEXT,       -- 'india_only' | 'us_only' | 'dual' | 'none'
    india_lock          TEXT,       -- 'NR' | 'RNOR' | 'ROR'
    us_lock             TEXT,       -- 'US_CITIZEN' | 'RESIDENT_ALIEN' | 'NON_RESIDENT_ALIEN' | 'DUAL_STATUS'
    completion_pct      INTEGER DEFAULT 0,
    completion_detail   JSONB,      -- { filled: N, total: M, missing: [...] }

    -- Last computation output
    computation_result  JSONB,
    is_approximation    BOOLEAN DEFAULT TRUE,
    last_computed_at    TIMESTAMPTZ,

    -- Lifecycle
    status              TEXT NOT NULL DEFAULT 'active',  -- 'active' | 'archived'
    schema_version      TEXT NOT NULL DEFAULT 'v5.1',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE(user_id, tax_year_id) WHERE status = 'active'
);

-- Append-only event log. No UPDATE, no DELETE.
CREATE TABLE tax_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    tax_year_id     UUID NOT NULL,
    event_type      TEXT NOT NULL,
    -- 'field_update' | 'jurisdiction_changed' | 'lock_changed'
    -- | 'computation_requested' | 'computation_completed'
    payload         JSONB NOT NULL,
    caused_by       UUID REFERENCES tax_events(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_events_user_year ON tax_events(user_id, tax_year_id, created_at);

-- Bridge events for dual-jurisdiction shared life events
CREATE TABLE bridge_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    tax_year_id     UUID NOT NULL,
    event_type      TEXT NOT NULL,  -- 'property_sale' | 'equity_comp' etc.
    captured_inputs JSONB NOT NULL,
    india_projection JSONB,
    us_projection    JSONB,
    cross_flags     JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Field registry: drives wizard sequencing + completion calculation
CREATE TABLE field_registry (
    field_path      TEXT PRIMARY KEY,
    schema_name     TEXT NOT NULL,      -- 'layer0' | 'layer1_india' | 'layer1_us'
    section         TEXT NOT NULL,
    classification  TEXT NOT NULL,      -- 'REQUIRED' | 'OPTIONAL' | 'DERIVED' | 'CONDITIONAL'
    friendly_label  TEXT NOT NULL,      -- "How many days in India?"
    input_type      TEXT NOT NULL,      -- 'integer' | 'boolean' | 'enum' | 'date' | 'currency'
    enabled_if      JSONB,             -- gate condition as structured JSON
    default_value   JSONB,             -- safe default for approximation mode
    default_label   TEXT,              -- "Assumed: New Tax Regime"
    wizard_order    INTEGER,           -- display order within section
    section_order   INTEGER            -- display order of section in wizard
);
```

### 6.2 Why Not Full Event Sourcing

v1.0 proposed rebuilding state by folding all events. That is academically pure but operationally expensive — every read requires replaying the full event history.

v2.0 uses a simpler pattern: **JSONB snapshot + append-only event log for audit**. The snapshot is the live state. The event log is the audit trail. We don't need to reconstruct state from events; we just need to explain "what changed and when" for CA review.

---

## PART 7: ARCHITECTURAL INVARIANTS

1. **Every question maps to exactly one schema field.** No multi-field questions. No "tell me about your property" that extracts 5 fields at once. One question → one field → one event.

2. **The wizard branching is 100% deterministic.** No LLM, no NLP, no fuzzy matching. The transition table is compiled from ENABLED IF gates in the JSONC schemas.

3. **The Math DAG has no I/O.** It receives a Pydantic model, returns a Pydantic model. No database reads, no API calls, no file access inside compute nodes.

4. **Every computation output below 100% completion is stamped APPROXIMATION.** No ambiguity. No probabilistic confidence. Binary: approximate or final.

5. **No silent defaults.** If the engine assumes `tax_regime = NEW`, the response explicitly says so in `assumptions_used`. The user sees every assumption.

6. **Locks re-fire on every upstream change. The DAG only fires on "Evaluate Tax."** Cheap operations are reactive. Expensive operations are user-triggered.

7. **Data is never deleted, only archived.** Jurisdiction changes soft-hide modules. Lock changes soft-hide sections. The user's data is always recoverable.

---

## SIGN-OFF REQUIRED

| # | Item | Owner | Blocking? |
|---|------|-------|-----------|
| 1 | CTO approval on XState vs alternative FSM for wizard | Devanshu | YES |
| 2 | CA: classify every Layer 1 India field as REQUIRED / OPTIONAL / DERIVED | Sarthak | YES |
| 3 | CPA: classify every Layer 1 US field as REQUIRED / OPTIONAL / DERIVED | CPA | YES |
| 4 | CA: approve safe defaults for approximation mode (e.g., tax_regime = NEW) | Sarthak | YES |
| 5 | UX: validate one-question-at-a-time flow vs section-based mini-forms | Nihal | YES |
| 6 | CTO: confirm JSONB snapshot + event log (vs full event sourcing) | Devanshu | YES |
