# Wising Tax Engine

**Deterministic, rules-based US–India cross-border tax engine for NRIs and US persons with India income.**

- 🇮🇳 RS-001: 19-path India residency classification (NR / RNOR / ROR)
- 🇺🇸 SPT Engine: 5-priority US status (US Citizen / Resident Alien / NRA / Dual Status)
- 🔗 DTAA advisory cards for cross-border compliance
- ⚡ Conversational wizard UI (one question at a time)

---

## Architecture

```
wising_frontend/   → Next.js 14 (App Router) — deploy to Vercel
wising_backend/    → FastAPI + asyncpg — deploy to Railway
                     PostgreSQL 17 — hosted on Railway or Neon
test_inputs/       → JSON test fixtures for residency scenarios
```

---

## Local Development

### Prerequisites
- Node.js 18+
- Python 3.11+
- PostgreSQL 17

### Backend

```bash
cd wising_backend
python -m venv .venv && .venv\Scripts\activate    # Windows
pip install -r requirements.txt

# Copy and configure .env
cp ../.env.example ../.env
# Edit DATABASE_URL with your local credentials

uvicorn app.main:app --reload --port 8000
```

### Frontend

```bash
cd wising_frontend
npm install

# Copy and configure env
cp .env.local.example .env.local
# NEXT_PUBLIC_API_URL=http://localhost:8000 (default)

npm run dev
# → http://localhost:3000
```

---

## Deployment

### Frontend → Vercel

1. Import `wising_frontend/` folder into Vercel (or set root directory)
2. Add environment variable in Vercel dashboard:
   ```
   NEXT_PUBLIC_API_URL = https://your-backend.up.railway.app
   ```
3. Deploy — Vercel auto-detects Next.js

### Backend → Railway

1. Create new Railway project → "Deploy from GitHub"
2. Select `wising_backend/` as the root directory
3. Set environment variables:
   ```
   DATABASE_URL = postgresql://...   (Railway Postgres or Neon)
   CORS_ORIGINS = https://your-app.vercel.app
   ```
4. Railway uses `Procfile` / `railway.json` automatically

### Database Setup (first deploy)

Run migrations and seed on Railway shell or Neon console:

```bash
# Apply DDL
psql $DATABASE_URL < migrations/sprint1_migration_DDL_ONLY.sql

# Seed field registry
psql $DATABASE_URL < seeds/seed_output.sql
```

---

## Residency Test Inputs

Six test fixtures in `test_inputs/` covering all residency paths:

| File | Scenario | Expected Lock |
|------|----------|--------------|
| `01_india_nri_120days.json` | Indian citizen, 120 days | India: **NR** |
| `02_india_ror_210days.json` | Indian citizen, 210 days | India: **ROR** |
| `03_dual_us_citizen.json` | Dual US + India citizen | IN: NR + US: **US_CITIZEN** |
| `04_us_green_card.json` | Green Card holder | US: **RESIDENT_ALIEN** |
| `05_india_rnor_returning.json` | Returning NRI, 9/10 yrs NR | India: **RNOR** |
| `06_dual_oci_green_card.json` | OCI + Green Card | IN: NR + US: **RESIDENT_ALIEN** |

---

## Layer Status

| Layer | Status |
|-------|--------|
| Layer 0 — Jurisdiction Router | ✅ Live |
| Layer 1 — Input Wizard (241 fields) | ✅ Live |
| RS-001 Residency Engine | ✅ Live |
| Advisory Cards | ✅ Live |
| Layer 2 — Math DAG | 🔜 Pending architect review |
