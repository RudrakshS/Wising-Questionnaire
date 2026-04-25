# WISING — Antigravity Build Prompt

**Document ID:** WISING-ANTIGRAVITY-001 v2.0
**Companion to:** WISING-ARCH-005 v2.0 · WISING-IMPL-001 · WISING-AI-CONTRACT v1.0
**Status:** READY FOR EXECUTION
**Last updated:** April 2026

---

> **TO THE AI BUILDER:** You are building Wising, a deterministic cross-border
> tax engine for the US–India NRI corridor. Read this document END-TO-END
> before writing a single line of code. It tells you exactly **what to build**,
> **how to build it**, **which files to read**, and **which files to ignore
> until instructed**.
>
> **Layer 2 (the tax computation DAG) is ON HOLD — pending architect review.
> DO NOT IMPLEMENT IT. This is non-negotiable.**
>
> If you hit a hard blocker, flag it explicitly and stop. Do not invent.

---

## PART 1 — WHAT YOU ARE BUILDING

**Wising** is a deterministic, rules-based, legally auditable tax engine. It
is **NOT** a chatbot. It is **NOT** an AI tax advisor. It is a progressive-
disclosure wizard backed by a computation engine that produces exact tax
liabilities for dual US–India filers.

### The Three Inviolable Laws

1. **Zero AI in the computation path.** All tax logic is rule-based and
   auditable. If an AI classifier is used anywhere, it only translates natural
   language into structured field patches — it never classifies residency,
   never computes tax, never decides jurisdiction.

2. **No silent defaults.** Every assumption the engine makes is logged in
   `assumptions_used[]`. The user sees every guess.

3. **Layer boundaries are enforced.** US logic never bleeds into the India
   schema. India logic never bleeds into the US schema. Layer 0 never guesses
   residency. Layer 1 never computes tax.

### The Three-Layer Architecture

```
Layer 0 — Jurisdiction Router
  Input:  9 Layer 0 user questions
  Output: jurisdiction ∈ {india_only, us_only, dual, none}
  Rule:   Evaluates india_flag and us_flag INDEPENDENTLY.
          NEVER classifies residency. NEVER applies income gates.

Layer 1 — Specialist Modules (India + US)
  Input:  Layer 0 routing result + domain-specific questions
  Output: Residency Lock (NR/RNOR/ROR for India;
                          RA/NRA/USC/DS for US)
  Rule:   First action in each module is ALWAYS the Residency Lock.
          All downstream sections are gated on the lock.
          The s.6(1A) 15L Deemed-Resident gate lives HERE, not in Layer 0.

Layer 2 — Math DAG                                     ⚠ ON HOLD
  Input:  Frozen Layer 1 JSON payload
  Output: Tax liability + surcharge + cess + FTC + advisory cards
  Status: PENDING ARCHITECT REVIEW. DO NOT IMPLEMENT.
          Stub the evaluate endpoint per Part 6, Sprint 8.
```

---

## PART 2 — FILE MANIFEST (THE RULES OF ENGAGEMENT)

All source files live in `TAX/` at the project root. Files are grouped by
**access tier**. Respect these tiers strictly.

### 🟢 TIER 1 — READ FIRST (before any coding)

These four files define the contract. They are the source of truth.

| File | Role |
|------|------|
| `specs/WISING_ARCH_005_v2_Lean.md` | Architecture blueprint. 7 inviolable rules. Event-driven model. |
| `specs/WISING_AI_CONTRACT.md` | Exact payload contracts for every API endpoint. Non-negotiable. |
| `specs/WISING_IMPL_001_Roadmap.md` | 10-sprint roadmap. Defines dependencies. |
| `specs/WISING_SCHEMA_SPEC_v5_3_UNABRIDGED.md` | Field census + classification index (521 fields). |

### 🟢 TIER 1 — SCHEMA CONTRACTS (read before Sprint 1)

These are the JSONC data contracts. **Do not modify them.** If you find a bug,
flag it and stop — do not patch the schema yourself.

| File | Role |
|------|------|
| `specs/layer0_residency_final.jsonc` | Layer 0 Router: 9 questions → jurisdiction |
| `specs/layer1_india_v5_1_final.jsonc` | Layer 1 India specialist module |
| `specs/layer1_us_v2_final.jsonc` | Layer 1 US specialist module |

### 🟡 TIER 2 — READ WHEN THE CORRESPONDING SPRINT BEGINS

These are reference implementations. Read them when you start the sprint
that consumes them — not before. Treat them as starting points to be
**split and refactored** into the folder structure in Part 3, not dumped
wholesale into `wising_backend/`.

| File | Consumed in |
|------|-------------|
| `wising_backend/sprint1_input_layer_PATCHED.py` | Sprint 1 (USE THIS, not the unpatched file) |
| `wising_backend/migrations/sprint1_migration_DDL_ONLY.sql` | Sprint 1 (DDL only — no seed INSERTs) |
| `wising_backend/seeds/seed_registry.py` | Sprint 1 (JSONC → field_registry upserts) |
| `wising_backend/seeds/seed_output.sql` | Sprint 1 (pre-generated upserts if seeder fails) |
| `wising_backend/sprint3_output_tests.py` | Sprint 3 (output stamping + test cases) |
| `wising_backend/sprint4_persistence.py` | Sprint 2 (FastAPI + asyncpg reference) |
| `wising_backend/wising_tax_engine_core.py` | Reference only — cross-check before refactoring |

### 🔴 TIER 3 — DO NOT READ UNLESS EXPLICITLY REQUESTED

These files are either on hold, historical, or irrelevant to the current
build. Reading them will waste context and may pollute decisions.

| File / Folder | Why excluded |
|---------------|--------------|
| `wising_backend/sprint2_math_dag.py` | **ON HOLD** — Layer 2 pending review. Do not modify. |
| `wising_backend/sprint1_input_layer.py` | Superseded by `sprint1_input_layer_PATCHED.py`. |
| `wising_backend/migrations/sprint1_migration.sql` | Superseded by DDL_ONLY version. Contains stale INSERTs. |
| `_raw_docs/*.docx` (all 21 files) | Legal audit trail. Only read if resolving a specific tax-law ambiguity. |
| `WISING_PLAN_001_Tax_Planning_Engine.docx` | Future feature. Not in this build. |
| `WISING_PLAN_002_US_Citizen_India.docx` | Future feature. Not in this build. |
| `Wising_TL_Gaps_v1.docx` | Historical gap analysis. Gaps are already resolved in patched files. |

**Rule:** If you think you need a Tier 3 file, STOP and ask the architect
before reading.

---

## PART 3 — THE FOLDER STRUCTURE YOU WILL BUILD

The project root is `TAX/`. You build the runnable application **inside**
`TAX/wising_backend/` and `TAX/wising_frontend/`. The `specs/` and
`_raw_docs/` directories are read-only.

```
TAX/
├── _raw_docs/                            ← Read-only (Tier 3)
├── specs/                                ← Read-only (Tier 1)
│
├── wising_backend/                       ← YOU BUILD HERE
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                       # FastAPI entry point
│   │   ├── config.py                     # pydantic-settings
│   │   ├── database.py                   # asyncpg pool + lifespan
│   │   │
│   │   ├── engine/                       # Pure computation — zero I/O
│   │   │   ├── __init__.py
│   │   │   ├── layer0_router.py          # evaluate_india_flag,
│   │   │   │                             #   evaluate_us_flag,
│   │   │   │                             #   evaluate_jurisdiction
│   │   │   ├── india_residency.py        # RS-001 engine (19 paths)
│   │   │   ├── us_residency.py           # SPT engine (5-priority cascade)
│   │   │   ├── gate_evaluator.py         # evaluate_gate(),
│   │   │   │                             #   compute_completion_pct()
│   │   │   ├── state_machine.py          # WizardStateMachine
│   │   │   └── math_dag/                 # ⚠ ON HOLD — stub modules only
│   │   │       ├── __init__.py
│   │   │       ├── india_dag.py          # # IMPLEMENTATION PENDING REVIEW
│   │   │       └── us_dag.py             # # IMPLEMENTATION PENDING REVIEW
│   │   │
│   │   ├── models/                       # Pydantic v2 + dataclasses
│   │   │   ├── __init__.py
│   │   │   ├── layer0.py                 # Layer0State, Jurisdiction enum
│   │   │   ├── india_residency.py        # IndiaResidencyDetail
│   │   │   ├── us_residency.py           # USResidencyDetail
│   │   │   ├── tax_state.py              # TaxEngineState (root)
│   │   │   └── field_registry.py         # FieldRegistry model
│   │   │
│   │   ├── api/                          # FastAPI routers
│   │   │   ├── __init__.py
│   │   │   ├── router.py                 # APIRouter aggregator
│   │   │   ├── session.py                # POST /api/session
│   │   │   ├── profile.py                # PATCH /api/profile/{sid}/{tyid}
│   │   │   ├── evaluate.py               # POST /api/evaluate (STUB)
│   │   │   └── wizard.py                 # GET /api/wizard/schema
│   │   │
│   │   ├── repository/                   # DB access (parameterized only)
│   │   │   ├── __init__.py
│   │   │   ├── snapshot_repo.py          # tax_state_snapshots CRUD
│   │   │   ├── field_registry_repo.py    # Read-only registry queries
│   │   │   └── event_repo.py             # Append-only tax_events
│   │   │
│   │   └── output/
│   │       ├── __init__.py
│   │       └── stamper.py                # APPROXIMATION/FINAL badge +
│   │                                     #   advisory card emission
│   │
│   ├── migrations/                       # Already present — do not recreate
│   │   └── sprint1_migration_DDL_ONLY.sql
│   │
│   ├── seeds/                            # Already present
│   │   ├── seed_registry.py
│   │   └── seed_output.sql
│   │
│   ├── tests/
│   │   ├── __init__.py
│   │   ├── conftest.py                   # pytest fixtures (frozen states)
│   │   ├── test_layer0_router.py         # 14 router cases
│   │   ├── test_india_residency.py       # 19 RS-001 paths (one each)
│   │   ├── test_us_residency.py          # 5 SPT cascade tests
│   │   ├── test_gate_evaluator.py        # contains, eq[], null vs [] tests
│   │   ├── test_completion_pct.py        # array-fill edge cases
│   │   ├── test_state_machine.py         # WizardStateMachine transitions
│   │   └── test_patch_endpoint.py        # httpx integration tests
│   │
│   ├── requirements.txt
│   ├── Dockerfile
│   └── (leave originals: sprint1_input_layer_PATCHED.py, sprint3_*, sprint4_*,
│        wising_tax_engine_core.py in place as reference; do not delete)
│
├── wising_frontend/                      ← YOU BUILD HERE
│   ├── src/
│   │   ├── app/                          # Next.js 14 App Router
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx                  # redirects to /wizard
│   │   │   └── wizard/
│   │   │       ├── page.tsx              # Wizard entry (layer0 start)
│   │   │       ├── layer0/page.tsx
│   │   │       ├── india/
│   │   │       │   ├── residency/page.tsx
│   │   │       │   └── income/page.tsx
│   │   │       └── us/
│   │   │           ├── residency/page.tsx
│   │   │           └── income/page.tsx
│   │   │
│   │   ├── components/
│   │   │   ├── wizard/
│   │   │   │   ├── QuestionCard.tsx      # Single-question renderer
│   │   │   │   ├── ProgressBar.tsx       # completion_pct (server-driven)
│   │   │   │   ├── LockAlert.tsx         # Residency lock change modal
│   │   │   │   ├── ArrayItemEditor.tsx   # goods_vehicles[], asset_blocks[]
│   │   │   │   └── TripCalendar.tsx      # Day-toggle calendar
│   │   │   └── results/
│   │   │       ├── TaxSummary.tsx        # Stubbed for now (Layer 2 hold)
│   │   │       ├── AdvisoryCard.tsx
│   │   │       └── AssumptionsList.tsx
│   │   │
│   │   ├── machines/
│   │   │   └── wizardMachine.ts          # XState v5 — states mirror
│   │   │                                 #   WizardPhase enum exactly
│   │   │
│   │   ├── lib/
│   │   │   ├── api.ts                    # Typed fetch wrappers
│   │   │   └── gates.ts                  # TS mirror of evaluate_gate()
│   │   │
│   │   └── types/
│   │       └── schema.ts                 # Auto-derived from JSONC schemas
│   │
│   ├── package.json
│   ├── tsconfig.json
│   └── Dockerfile
│
├── docker-compose.yml                    ← YOU CREATE AT ROOT
└── .env.example                          ← YOU CREATE AT ROOT
```

**Do not invent top-level directories.** If you need a utility folder, place
it inside `app/` or `src/`.

---

## PART 4 — ENVIRONMENT SETUP

### `wising_backend/requirements.txt`
```
fastapi==0.115.0
uvicorn[standard]==0.30.0
asyncpg==0.29.0
pydantic==2.7.0
pydantic-settings==2.3.0
python-dotenv==1.0.1
httpx==0.27.0
pytest==8.2.0
pytest-asyncio==0.23.0
```

### `TAX/docker-compose.yml`
```yaml
version: "3.9"
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB:       wising
      POSTGRES_USER:     wising
      POSTGRES_PASSWORD: wising_dev
    ports: ["5432:5432"]
    volumes: [pg_data:/var/lib/postgresql/data]

  backend:
    build: ./wising_backend
    depends_on: [db]
    env_file: .env
    ports: ["8000:8000"]
    volumes:
      - ./wising_backend:/app
      - ./specs:/specs

  frontend:
    build: ./wising_frontend
    depends_on: [backend]
    ports: ["3000:3000"]
    volumes: [./wising_frontend:/app]

volumes: {pg_data: {}}
```

### `TAX/.env.example`
```
DATABASE_URL=postgresql://wising:wising_dev@localhost:5432/wising
SCHEMA_DIR=/specs
DEBUG=true
LOG_LEVEL=INFO
```

---

## PART 5 — BUILDABLE SPRINTS (1 THROUGH 7)

Sprints 1–7 are buildable now. **Sprints 8–10 are on hold** (they all depend
on Layer 2). See Part 6.

Each sprint has a validation checkpoint. Do not proceed to the next sprint
until all tests for the current sprint pass.

---

### Sprint 1 — Database + Field Registry (3 dev-days)

**Goal:** Tables exist. Field registry is populated. Engine modules are
importable from the new folder structure.

**Step 1.1 — Run DDL Migration**
```bash
psql $DATABASE_URL -f wising_backend/migrations/sprint1_migration_DDL_ONLY.sql
```
Creates 4 tables: `field_registry`, `tax_state_snapshots`, `tax_events`,
`bridge_events`.

**Step 1.2 — Seed the Field Registry**

Option A (preferred — re-derives from current JSONC):
```bash
cd wising_backend
python seeds/seed_registry.py
```
Option B (fallback — pre-generated inserts):
```bash
psql $DATABASE_URL -f wising_backend/seeds/seed_output.sql
```

**Expected final row counts** (from `specs/WISING_SCHEMA_SPEC_v5_3_UNABRIDGED.md`):
```
layer0:       REQ=6   COND=5    OPT=0    DERIV=3   TOTAL=14
layer1_india: REQ=17  COND=126  OPT=151  DERIV=24  TOTAL=318
layer1_us:    REQ=26  COND=116  OPT=131  DERIV=51  TOTAL=324
                                                 ─────────
                                          TOTAL:   656
```
*(Total reconciles to 656 registry rows; the 521 figure in memory refers to
a prior count snapshot — use the seeder's emitted count as ground truth.)*

**Step 1.3 — Split `sprint1_input_layer_PATCHED.py` into the folder structure**

Do not dump the patched file into `app/engine/` as one giant module. Split by
responsibility:

| From `sprint1_input_layer_PATCHED.py` | → To |
|---------------------------------------|------|
| `evaluate_india_flag`, `evaluate_us_flag`, `evaluate_jurisdiction` | `app/engine/layer0_router.py` |
| `RS001Result`, `compute_ltac`, `evaluate_india_residency` | `app/engine/india_residency.py` |
| `SPTResult`, `evaluate_us_residency` | `app/engine/us_residency.py` |
| `evaluate_gate`, `compute_completion_pct` (patched versions) | `app/engine/gate_evaluator.py` |
| `WizardStateMachine`, `StateTransition` | `app/engine/state_machine.py` |
| `Layer0State`, `Jurisdiction` | `app/models/layer0.py` |
| `IndiaResidencyDetail`, `IndiaResidency`, `EmploymentCrewStatus` | `app/models/india_residency.py` |
| `USResidencyDetail`, `USResidency`, `ExemptIndividualStatus` | `app/models/us_residency.py` |
| `TaxEngineState`, `WizardPhase` | `app/models/tax_state.py` |

**All models import from `app.models.*`. Engine modules import from `app.models`
and from each other only where strictly needed. No circular imports.**

Confirm `schema_version = "v5.1"` in `TaxEngineState`.

**Step 1.4 — Validation Checkpoint**
```bash
pytest tests/test_layer0_router.py -v       # 14 tests
pytest tests/test_india_residency.py -v     # 19 tests (one per RS-001 path)
pytest tests/test_us_residency.py -v        # 5 tests
pytest tests/test_gate_evaluator.py -v      # contains, eq[], null≠[] tests
pytest tests/test_completion_pct.py -v
```
**All must pass before Sprint 2.**

---

### Sprint 2 — PATCH Endpoint + Reactive Lock Re-fire (4 dev-days)

**Goal:** Backend accepts field updates and returns jurisdiction, locks,
completion percentage, and `next_required_fields[]`.

**Reference:** `specs/WISING_AI_CONTRACT.md` Sections 2–3.

**Step 2.1 — Repository Layer**

Port `TaxStateRepository` from `sprint4_persistence.py` into
`app/repository/snapshot_repo.py`. Use `asyncpg.Pool` via FastAPI dependency
injection. Parameterized queries only.

Required methods:
- `get_active_snapshot(user_id, tax_year_id) → dict | None`
- `upsert_snapshot(snapshot: dict) → dict`
- `append_event(event: dict) → None`

**Step 2.2 — PATCH /api/profile/{session_id}/{tax_year_id}**

This is the most critical endpoint. Follow the exact contract in
`specs/WISING_AI_CONTRACT.md` Section 2.

**Validation order (mandatory):**
1. `field_path` exists in `field_registry`
2. `value` type matches `input_type`
3. `enabled_if` gate is open (via `evaluate_gate()`)
4. If enum, `value` is in `enum_values`
5. If India-NR + `s44AD`/`s44ADA` → reject with `NR_INELIGIBLE_PRESUMPTIVE`

**Re-evaluation order after successful patch (mandatory):**
1. Write to `layer0_state` / `layer1_india` / `layer1_us` JSONB
2. Re-evaluate `india_flag`, `us_flag`, `jurisdiction` (always)
3. If jurisdiction changed → emit `JURISDICTION_CHANGED` event
4. If India residency input changed → re-fire RS-001 lock
5. If US residency input changed → re-fire SPT lock
6. If lock changed → emit `INDIA_LOCK_CHANGED` / `US_LOCK_CHANGED`
7. Recompute `completion_pct` against `field_registry`
8. Set `tax_estimate_stale = true` if an income-relevant field changed
9. Return the full response shape from AI-CONTRACT §2.1

**Step 2.3 — Batch PATCH Support**

Implement `{ patches: [...] }` form per AI-CONTRACT §2.2. Locks re-fire
**once** after all patches are applied, not per-patch.

**Step 2.4 — GET /api/wizard/schema**

Returns `field_registry` rows ordered by `(section_order, wizard_order)`,
filtered by active jurisdiction.

**Step 2.5 — Validation Checkpoint**
```bash
pytest tests/test_patch_endpoint.py -v
```
Required cases: boolean patch, gate-closed (422), unknown field_path (422),
type mismatch (422), enum array patch, NR presumptive rejection, batch patch
with lock flip, mid-session jurisdiction flip.

---

### Sprint 3 — Output Stamper + Advisory Card Engine (3 dev-days)

**Goal:** When a (stubbed) tax estimate is returned, it is stamped
`APPROXIMATION` or `FINAL` and advisory cards are emitted for cross-border
traps.

**Reference:** `sprint3_output_tests.py` — port `OutputStamper` logic into
`app/output/stamper.py`.

**Step 3.1 — Stamping Rules**
- `completion_pct < 100` → `APPROXIMATION` + `is_approximation: true`
- `completion_pct == 100` AND no missing required → `FINAL`
- Always return `assumptions_used[]`, `missing_for_final[]`

**Step 3.2 — Advisory Cards (see Part 7 for the full list)**

Cards are emitted **from the stamper**, based on data conditions in the
snapshot. They are NOT user-triggered. Implement all 8 cards from Part 7.

**Step 3.3 — Validation Checkpoint**
```bash
pytest tests/test_stamper.py -v
```

---

### Sprint 4 — Layer 0 Wizard UI (4 dev-days)

**Goal:** A Next.js screen renders the 9 Layer 0 questions, one at a time,
with an XState v5 machine driving transitions based on `enabled_if` gates.

**Step 4.1 — XState Machine**

`wizardMachine.ts` states must **mirror `WizardPhase` exactly**:
```
layer0_wizard → layer0_complete → india_residency | us_residency
             → india_locked    | us_locked
             → income_sections → ready_to_evaluate
```

**Step 4.2 — QuestionCard Component**

Renders a single field at a time. On submit, calls PATCH. On response,
updates `completion_pct`, renders `lock_change_alert` modal if present,
transitions to next question from `next_required_fields[0]`.

**Step 4.3 — Client-side Gate Evaluator**

`lib/gates.ts` is a TypeScript mirror of the backend's `evaluate_gate()`.
Used only for **progressive disclosure within a rendered form** — never
for authoritative gating. The backend is the source of truth.

**Step 4.4 — Validation Checkpoint**

Manual E2E: complete all 9 Layer 0 questions for a US-India NRI scenario.
Verify jurisdiction resolves to `dual` and the UI transitions to the India
residency mini-wizard.

---

### Sprint 5 — India Residency Mini-wizard (3 dev-days)

**Goal:** Render the India residency lock UI. Handles RS-001's 19 paths. On
lock change mid-session, displays `LockAlert` modal before proceeding.

**Step 5.1 — TripCalendar Component**

For `days_in_india_current_year` — a calendar-style day toggle. Backend
receives the integer day count, not the date list.

**Step 5.2 — Mid-session Lock Flip Handling**

If a user edits a Layer 0 field after India lock has fired, and the lock
changes (e.g., `NR` → `RNOR`), the UI must:
1. Display `LockAlert` with the before/after values and the triggering field
2. Block further input until user acknowledges
3. Revalidate all already-entered Layer 1 India fields against new gates

---

### Sprint 6 — US Residency Mini-wizard (3 dev-days)

**Goal:** Same pattern as Sprint 5, but for US residency (SPT cascade).

The SPT cascade has 5 priority steps. Render them in order. The XState
machine should NOT skip steps even if a higher-priority condition is met —
the backend is authoritative.

---

### Sprint 7 — Income Sections + Array Item Editor (7 dev-days)

**Goal:** Render all income sections with conditional visibility, array item
management, and complex business-income gating.

**Step 7.1 — Section-by-section Rendering**

Sections from `layer1_india_v5_1_final.jsonc`:
salary, house_property, capital_gains, business_income, other_sources,
deductions, tax_credits.

Each section is gated on `india_lock` (e.g., salary section visible for all
locks; business_income `s44AD` restricted to ROR/RNOR).

**Step 7.2 — ArrayItemEditor**

For `goods_vehicles[]`, `asset_blocks[]`, `house_properties[]`, etc.:
- "Add item" opens inline template form
- On save → PATCH the **full array** with new item appended
- On delete → PATCH the full array minus deleted item
- **Always send the full array.** Never deltas.

**Step 7.3 — Business Income Gating (hardest part; build last)**

Implement these exact gates:
- `has_business_or_fo_income = false` → entire block hidden
- `presumptive_scheme = []` → expenses + asset_blocks visible
- `"s44AD" IN presumptive_scheme` → digital_receipts_inr + cash_receipts_inr visible
- `"s44ADA" IN presumptive_scheme` → gross_receipts_inr visible
- `"s44AE" IN presumptive_scheme` → goods_vehicles[] visible
- `"partner_in_firm" IN nature_of_business` → partner_income block visible
- India lock = "NR" AND s44AD/s44ADA attempted → `NR_INELIGIBLE_PRESUMPTIVE` warning

**Step 7.4 — Validation Checkpoint**

Manual E2E: complete a dual-filer scenario through to `ready_to_evaluate`.
Hit the stubbed evaluate endpoint and verify it returns the stub response
from Part 6.

---

## PART 6 — LAYER 2 HOLD NOTICE ⚠

**Layer 2 (the Math DAG) is on hold pending architect review.**

### What this means concretely

1. `app/engine/math_dag/india_dag.py` and `us_dag.py` exist as stub modules
   containing ONLY:
   ```python
   """India tax computation DAG. IMPLEMENTATION PENDING ARCHITECT REVIEW."""
   # Do not implement. See ANTIGRAVITY_BUILD_PROMPT.md Part 6.
   ```

2. `POST /api/evaluate/{session_id}/{tax_year_id}` is **stubbed** to return:
   ```json
   {
     "status": "APPROXIMATION",
     "session_id": "sess_...",
     "completion_pct": 72,
     "india_tax": {
       "_stub": true,
       "note": "India Math DAG pending architect review — estimate unavailable"
     },
     "us_tax": {
       "_stub": true,
       "note": "US Math DAG pending architect review — estimate unavailable"
     },
     "advisory_cards": [],
     "missing_for_final": [],
     "assumptions_used": []
   }
   ```
   Advisory cards from `output/stamper.py` (Sprint 3) DO still emit, even
   in stub mode — they depend on snapshot state, not computation results.

3. **Do NOT read `wising_backend/sprint2_math_dag.py`.** It contains an
   outdated DAG skeleton that is being reworked. Reading it will pollute
   design decisions.

4. Sprints 8 (India DAG), 9 (US DAG), and 10 (Cross-engine reconciliation
   + bridge events) are **deferred**. Do not begin them. Do not build
   scaffolding for them beyond the stubs already specified.

### When will Layer 2 unblock?

When the architect signs off on the revised DAG specification, a new
version of this document (`v3.0`) will be issued with Sprints 8–10
populated. Until then, stop at Sprint 7.

---

## PART 7 — CROSS-BORDER TRAPS (ADVISORY CARDS)

These 8 advisory cards must fire from `output/stamper.py` when the
corresponding conditions are met in the snapshot. They are **non-negotiable**
— they exist to protect users from expensive cross-border mistakes.

| Card ID | Condition | Severity |
|---------|-----------|----------|
| `PLAN-S54-US-TRAP` | India capital gains + US `RESIDENT_ALIEN` | High |
| `TRAP-PFIC-MF` | US person holds Indian mutual funds (any amount) | Critical |
| `TRAP-FBAR` | US person + Indian account peak > $10,000 | High |
| `TRAP-8938` | US person + foreign assets above threshold | High |
| `ALERT-PAN-INOPERATIVE` | `pan_aadhaar_linked = false` AND NR exemption does not apply | High |
| `INCOME_THRESHOLD_DISCREPANCY` | Computed India income > ₹15L AND `india_source_income_above_15l = false` | Critical |
| `ALERT-AUDIT-SPECULATIVE` | `speculative_turnover_inr >= 1 Cr` | Medium |
| `FLAG-S43B-MSME` | Any `msme_payables[].payment_date` beyond prescribed period | Medium |

These emit based on data conditions in the snapshot, not user actions.
Even with Layer 2 stubbed, these cards still fire — the stamper reads the
snapshot, not the computation result.

---

## PART 8 — TESTING REQUIREMENTS (NON-NEGOTIABLE)

No sprint is complete until all its tests pass.

### Required fixtures in `tests/conftest.py`
- `india_nr_state` — US-based NRI with Indian source income (most common)
- `india_rnor_state` — Returning NRI crossing 182 days
- `dual_usc_india_property` — US citizen with India property (dual filer)

### Required tests per module

| Test file | Minimum test count | Coverage |
|-----------|-------------------|----------|
| `test_layer0_router.py` | 14 | All jurisdiction outcomes incl. edge cases |
| `test_india_residency.py` | 19 | **One test per RS-001 path** — ROR-1/2, RNOR-1..5, NR-1..8 |
| `test_us_residency.py` | 5 | All SPT cascade priorities |
| `test_gate_evaluator.py` | ≥8 | `contains`, `eq []`, `null ≠ []`, `and`/`or`/`not`, numeric ops |
| `test_completion_pct.py` | ≥6 | array-field fill, DERIVED field exclusion, gate-closed field exclusion |
| `test_patch_endpoint.py` | ≥10 | All validation errors + batch patch + lock flip + stale-estimate flag |

### Critical gate evaluator edge cases (must include)
```python
def test_gate_eq_empty_array_vs_none():
    """None (not answered) must NOT match [] (explicitly empty)."""
    gate = {"field": "layer1_india.domestic_income.business_income.presumptive_scheme",
            "op": "eq", "value": []}
    ctx_none   = {"layer1_india": {"domestic_income": {"business_income": {"presumptive_scheme": None}}}}
    ctx_empty  = {"layer1_india": {"domestic_income": {"business_income": {"presumptive_scheme": []}}}}
    assert evaluate_gate(gate, ctx_none)  is False
    assert evaluate_gate(gate, ctx_empty) is True
```

---

## PART 9 — DEFINITION OF DONE (SPRINTS 1–7)

Antigravity's current scope is complete when:

- [ ] All 4 database tables created; `field_registry` seeded (656 rows)
- [ ] Engine modules split from `sprint1_input_layer_PATCHED.py` per Part 5.1.3
- [ ] `schema_version = "v5.1"` in all snapshots
- [ ] Layer 0 wizard: 9 questions → jurisdiction result → screen renders
- [ ] India residency lock fires for all 19 RS-001 paths (tests prove it)
- [ ] US residency lock fires for all 5 SPT paths (tests prove it)
- [ ] Mid-session lock flip → `LockAlert` modal appears, re-gates Layer 1
- [ ] Progress bar driven by server `completion_pct`, never local state
- [ ] All income section mini-wizards render
- [ ] `ArrayItemEditor` works for `goods_vehicles[]` and `asset_blocks[]`
- [ ] Business income gates correct (`contains`, `eq []`, NR-presumptive reject)
- [ ] `POST /api/evaluate` returns the Layer-2-hold stub
- [ ] All 8 advisory cards emit under the correct conditions (Part 7)
- [ ] All unit + integration tests green (Part 8)
- [ ] No silent defaults anywhere in the codebase

**Once every checkbox is ticked, STOP. Do not begin Sprint 8 until a new
version of this document authorizes it.**

---

## PART 10 — IF YOU HIT A BLOCKER

1. Stop. Do not invent a solution.
2. Identify which Tier-1 or Tier-2 file the blocker touches.
3. Write a single-paragraph description:
   - Which file
   - Which line/function
   - What you expected vs. what you found
   - What decision is needed
4. Ask the architect before continuing.

Do **not** modify JSONC schemas. Do **not** modify Tier-1 `.md` specs.
Do **not** read Tier-3 files speculatively. Do **not** implement Layer 2
under any circumstances.

---

*End of WISING-ANTIGRAVITY-001 v2.0*
*Layer 2 is on hold. Build Sprints 1–7 only. Stop at the stubbed evaluate endpoint.*
