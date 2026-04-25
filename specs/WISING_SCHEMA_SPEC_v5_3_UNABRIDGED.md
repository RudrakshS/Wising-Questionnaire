# WISING TAX ENGINE — Complete Schema Specification v5.3 (UNABRIDGED)

**Document ID:** WISING-SCHEMA-SPEC v5.3
**Date:** April 2026
**Schemas:** layer0_residency_v4 · layer1_india_v5_1 · layer1_us_v2
**Status:** APPROVED FOR ANTIGRAVITY — Post-Audit + DOM_Tax_03 v2.0 + v5.1 Bug Fixes + Backlog
**Edition:** UNABRIDGED — every comment line preserved verbatim, zero truncation. All type cells populated (no "—" placeholders).

---

## Audit Resolutions Incorporated (v5.0→v5.3)

| # | Issue | Resolution | Impact |
|---|-------|-----------|--------|
| 6 | DOM_Tax_03 v2.0 business/F&O spec integration | Expanded `business_income` block in Layer 1 India from 10 fields to 52 fields. Added: `nature_of_business`, `profession_type` (s.44ADA eligibility), `digital_receipts_inr`/`cash_receipts_inr` (s.44AD blended rate), `s44AD_last_exit_ay`/`s44AD_opted_current_year` (5-year ban), `goods_vehicles[]` (s.44AE), `gst_registration_status`/`gst_collected_inr` (taxable turnover), structured `expenses{}` sub-block (s.30-s.37 categories, s.40A(3) cash disallowance, s.40A(2) related party, s.43B payment timing), `asset_blocks[]` (WDV depreciation, half-year rule, additional dep s.32(1)(iia), s.32AD backward area), `speculative_turnover_inr` (intraday audit gate), `partner_income{}` (firm/LLP distinction per s.40(b)), `msme_payables[]` (s.43B(h) Finance Act 2023). | layer1_india bumped v4→v5; +42 fields; no Layer 0 or Layer 1 US impact |
| 7 | v5.1 business_income bug fixes + backlog (Antigravity readiness) | **BUG-1**: `presumptive_scheme` single enum → array (DOM_Tax_03 §4.2 permits simultaneous s.44AE + s.44AD). **BUG-2**: `nature_of_business` single enum → array (multi-classification users: professional + F&O + intraday). **TEMPLATE NORM**: `goods_vehicles[]` sub-fields (`vehicle_type`, `gvw_tonnes`, `months_owned`) formally declared, consistent with `asset_blocks[]` / `msme_payables[]`. **NR-SCOPE GATE**: s.44AD / s.44ADA gated to lock IN ["ROR","RNOR"]; s.44AE unrestricted (DOM_Tax_03 §4.1). **BACKLOG FIELDS (20 added)**: s.40(a)(i) non-resident TDS-default (100% disallowed); s.40(a)(ia) resident TDS-default (30% disallowed); s.41(1) remission of trading liability; s.41(4) bad-debt recovery; opening/closing stock (inventory businesses, DOM_Tax_03 §11.3); s.35 scientific research (revenue/capital/donation — flat 100% post-FA-2023); s.35D preliminary expense amortisation; s.35DDA VRS amortisation; STT/CTT audit-trail fields (NOT deductible, recorded for reconciliation); AMT credit brought forward with origin AY (s.115JC, 15-yr carry forward). **ANTIGRAVITY PREP**: all 263 "—" type cells across the spec backfilled with canonical types derived from the JSONC schemas and field-name heuristics — pure documentation completion, no semantic change to any non-business_income field. | layer1_india v5 → v5.1; +20 new fields (+8 CONDITIONAL, +12 OPTIONAL) plus +1 container row for goods_vehicles; total +21 spec rows; no Layer 0 or Layer 1 US impact |
| 1 | PIO Deemed Resident protection | Citizenship check already enforced: LTAC truth table returns FALSE for non-citizens in all combinations; RS-001 engine pseudocode independently checks `citizen = true` before any s.6(1A) path. No schema change needed. | None — confirmed correct |
| 2 | `is_departure_year` April 1st reset | Replace manual boolean with Trip Calendar Toggle (India/US toggle). System derives exact day counts, departure dates, and departure-year status. `current_year_trip_log` becomes authoritative source. | New UX component; `india_days` and `us_days` become DERIVED from toggle |
| 3 | PIO 130-day Condition C flow | Confirmed correct: PIO → 130 days → P4Y_365 true → EMP gate fails (not citizen) → EMP = none → `came_on_visit` = true → DAYS ≥ 120 → INC_15L true → RNOR-4 (Condition C). LTAC irrelevant — Condition C is not Deemed Resident. | None — confirmed correct |
| 4 | Dual residency DTAA tie-breaker | Prepare tie-breaker inputs in Layer 1. Layer 2 DAG computes both India-primary and US-primary FTC scenarios. `DUAL_RESIDENCY_DTAA_REVIEW` routes to CA. | New fields in Layer 1; Layer 2 updated |
| 5 | ₹15L income threshold feedback loop | Option B: after DAG computes income > ₹15L, prompt user to confirm. Lock re-fires only on explicit user click. Max 2 iterations. `INCOME_THRESHOLD_OVERRIDE_BY_USER` flag for CA review. | New UX flow; boolean remains user-confirmed |

---

## Classification Legend

| Tag | Meaning | Completion % Impact |
|-----|---------|--------------------|
| **REQUIRED** | Must be answered. No ENABLED IF gate. | Counts in denominator + numerator |
| **CONDITIONAL** | Required IF its gate is open. | Counts only when gate is active |
| **OPTIONAL** | Engine can compute without it (uses safe default). | Does NOT affect completion % |
| **DERIVED** | Engine-computed. Never asked of user. | Excluded from completion UI |

## Field Census

| Schema | REQUIRED | CONDITIONAL | OPTIONAL | DERIVED | Total |
|--------|---------|-------------|---------|---------|-------|
| **Layer 0** | 6 | 5 | 0 | 3 | **14** |
| **Layer 1 India** | 17 | 124 | 136 | 28 | **305** |
| **Layer 1 US** | 26 | 117 | 114 | 51 | **308** |
| **TOTAL** | **49** | **246** | **250** | **82** | **627** |

---

# LAYER 0 — JURISDICTION ROUTER (v4.0)

Single responsibility: determine which country has the legal right to tax the user this year. Evaluates two independent boolean flags (`india_flag`, `us_flag`) via parallel architecture. Outputs `jurisdiction ∈ {india_only, us_only, dual, none}`. Layer 0 does NOT classify residency — that happens in Layer 1.

**Parallel Flag Architecture:**
- `india_flag` = is_indian_citizen OR is_pio_or_oci OR india_days > 0 OR has_india_source_income_or_assets = true
- `us_flag` = is_us_citizen OR has_green_card OR (was_in_us_this_year = true AND us_days > 0) OR has_us_source_income_or_assets = true
- `jurisdiction` = CASE WHEN both true → "dual" ∣ india_flag only → "india_only" ∣ us_flag only → "us_only" ∣ both false → "none" (CA review)

**Scope containment:** US-touch questions exist ONLY to drive `us_flag`. No US computation/classification here.

**Screen flow:** Single screen. Max ~9 questions, 2 conditional follow-ups.


## Fields

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `is_indian_citizen` | bool | **REQUIRED** |  | Q1 ∣ bool Are you an Indian citizen? Flag role: contributes to india_flag. Also gates the employment-departure question (Q9) and the `liable_to_tax_in_another_country` question. Pre-filled into layer1_india for the RS-001 residency engine. |
| `is_pio_or_oci` | bool | **CONDITIONAL** | is_indian_citizen = false | Q2 ∣ bool Are you a Person of Indian Origin (PIO) or OCI cardholder? Flag role: contributes to india_flag. Pre-filled into layer1_india for the 120-day visitor path (s.6(6)(c)). |
| `india_days` | integer | **REQUIRED** |  | Q3 ∣ integer (0–366) How many days were you physically present in India this tax year (1 April 2025 – 31 March 2026)? Flag role: india_days > 0 → contributes to india_flag. Pre-filled into layer1_india.residency_detail.days_in_india_current_year. Layer 1 collects the trip log for audit; the day total is captured here once. |
| `has_india_source_income_or_assets` | bool | **REQUIRED** |  | Q4 ∣ bool Do you have any India-source income (NRO/NRE interest, Indian dividends, Indian rental income, Indian capital gains, Indian salary/pension) or Indian-situs assets (Indian property, Indian bank accounts, Indian demat holdings, Indian mutual funds) this year? Flag role: catches the case where a person has zero India days and no Indian citizenship/PIO/OCI but still has India taxing rights through source-based income (e.g., a US citizen with Indian rental property). NOTE: This replaces the old `india_income_above_15l` field. Layer 0 does NOT ask about the ₹15L threshold — that is a RESIDENCY question (s.6(1A) Deemed Resident) and now lives in Layer 1. |
| `is_us_citizen` | bool | **REQUIRED** |  | Q5 ∣ bool Are you a US citizen? Flag role: if true → us_flag = true unconditionally. US has worldwide taxing rights for all citizens regardless of residence. |
| `has_green_card` | bool | **CONDITIONAL** | is_us_citizen = false | Q6 ∣ bool Do you hold a valid US Green Card (Form I-551)? Flag role: same as is_us_citizen → us_flag = true. Note: an unsurrendered Green Card (no Form I-407 filed) still creates US taxing rights even if physically expired. Answer true if never surrendered. |
| `was_in_us_this_year` | bool | **REQUIRED** |  | Q7 ∣ bool Were you physically present in the United States at any point this calendar year (1 January 2026 – 31 December 2026)? Green Card holders should answer YES even with 0 US days. NOTE: NO india_days gate. This question is always shown. |
| `us_days` | integer | **CONDITIONAL** | was_in_us_this_year = true | Q7b ∣ integer (0–365) Exactly how many days were you in the US this calendar year? Flag role: us_days > 0 + was_in_us = true → contributes to us_flag. Pre-filled into layer1_us.us_residency_detail.us_days_current_year. The exact SPT computation (3-year weighted formula, closer-connection exception, dual-status determination) is performed inside layer1_us. |
| `has_us_source_income_or_assets` | bool | **REQUIRED** |  | Q7c ∣ bool Do you have any US-source income (US salary, RSU vesting, US rental, US dividends, US bank interest) or US-situs assets (US brokerage, US real estate) this year? Flag role: catches the case where a person has zero US presence and no US status but still triggers US filing obligations through ECI / FDAP / withholding events. Contributes to us_flag. |
| `liable_to_tax_in_another_country` | bool | **CONDITIONAL** | is_indian_citizen = true | Q8 ∣ bool Are you personally liable to pay income tax in any other country this year? This question does NOT affect jurisdiction routing. It is collected here as a UX convenience and pre-filled into layer1_india.residency_detail where it gates the Deemed Resident path (s.6(1A)). Gate rationale: only Indian citizens can be Deemed Residents under s.6(1A). Non-citizens are never asked because the Deemed Resident provision does not apply to them. UAE residents: UAE has corporate tax (2023) but no personal income tax → false. This answer is pre-filled into Layer 1; the user is not re-asked. |
| `left_india_for_employment_this_year` | bool | **CONDITIONAL** | is_indian_citizen = true | Q9 ∣ bool Did you leave India THIS year specifically for employment abroad or as an Indian ship crew member? This question does NOT affect jurisdiction routing. It is pre-filled into layer1_india.residency_detail.employment_or_crew_status gating. Note: gate loosened from v2 (no longer requires india_days < 182) because a citizen who clocked >182 days before departing is still in the employment-departure exception scope. |
| `india_flag` | bool | **DERIVED** |  | DERIVED ∣ bool TRUE when ANY of: is_indian_citizen = true is_pio_or_oci = true india_days > 0 has_india_source_income_or_assets = true If none of the above → FALSE (no India taxing rights). |
| `us_flag` | bool | **DERIVED** |  | DERIVED ∣ bool TRUE when ANY of: is_us_citizen = true has_green_card = true (was_in_us_this_year = true AND us_days > 0) has_us_source_income_or_assets = true If none of the above → FALSE (no US taxing rights). |
| `jurisdiction` | enum | **DERIVED** |  | DERIVED ∣ "india_only" ∣ "us_only" ∣ "dual" ∣ "none" The primary routing output. Determines which Layer 1 specialist modules are instantiated for this tax_years row. "dual"       → BOTH layer1_india AND layer1_us are created Triggered when: india_flag = true AND us_flag = true This is the default for any USC/GC holder with non-zero India days, or any Indian resident with US-source income/assets, or any NRI in the US with India-source income. "india_only" → only layer1_india is created Triggered when: india_flag = true AND us_flag = false "us_only"    → only layer1_us is created Triggered when: india_flag = false AND us_flag = true "none"       → no Layer 1 module created Triggered when: india_flag = false AND us_flag = false Foreign national with no India or US exposure. Surfaced to a CA for manual review. |


# LAYER 1 INDIA — SPECIALIST MODULE (v5.1)

Collects all India-specific tax data after Layer 0 routes the user to `india_only` or `dual`. This module is the single source of truth for Indian residency classification, GTI assembly, and ITR data inputs.

**v5.1 update:** The `business_income` block is now 73 spec rows (72 schema leaves). Two architectural bugs fixed (`nature_of_business` and `presumptive_scheme` are now arrays, not single enums) and 20 new fields added to close DOM_Tax_03 v2.0 coverage gaps (TDS default disallowances, s.41 deemed income, opening/closing stock, s.35/s.35D/s.35DDA, STT/CTT audit trail, AMT credit BF). `goods_vehicles[]` template normalized to match `asset_blocks[]` and `msme_payables[]`. See Section 12.B for the complete field list.

**v5.0 update:** The `business_income` block was expanded from 10 fields to 52 fields to support the full DOM_Tax_03 v2.0 (Business & F&O) computation engine.

**The Residency Lock:** The very first thing this module does is run the RS-001 logic and write `residency_detail.final_india_residency_status`. This DERIVED field is the LOCK that gates every subsequent section. No section downstream of the lock may be filled until the lock is set.

**Income scope by lock:** NR → India-source only · RNOR → India + India-controlled business · ROR → worldwide

**Governing law:** Income Tax Act 2025 (eff. 1 Apr 2026) · IT Act 1961 (periods up to 31 Mar 2026) · Finance Act 2020

**Scope containment:** This file contains INDIA TAX LAW ONLY. All US-side concerns (PFIC, FBAR, Form 8938, GILTI/NCTI, §1014 step-up, treaty tie-breaker, W-Forms, FATCA, §962 election) live in layer1_us.

**Screen flow:** 2A (profile + residency → sets LOCK) → 2B (DTAA, if NR) → 2C (compliance docs) → 2D (bank accounts) → 2E (property) → 2F (financial holdings) → 2G (commodities) → 2H (unlisted equity) → 2I (share buyback) → 2J (domestic income) → 2K (other sources) → 2L (deductions, if OLD or RNOR/ROR) → 2M (carry-forward losses) → 2N (LRS, if ROR) → 2O (tax credits)


## Section 1: PROFILE

*Screen 2A | Asked of all India users*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `date_of_birth` | date | **REQUIRED** |  | "YYYY-MM-DD" Determines: senior citizen (60+) higher basic exemption under old regime, super senior (80+) advance tax exemption, slab breakpoints. |
| `pan` | currency | **REQUIRED** |  | string (10 chars, AAAAA9999A format) Permanent Account Number. Required for all India tax filings. |
| `pan_aadhaar_linked` | bool | **REQUIRED** |  | bool Is your PAN linked to Aadhaar? CRITICAL: an unlinked PAN is INOPERATIVE — TDS doubles to 20% on most streams under s.206AA, refunds are blocked, and ITR filing may be rejected. Engine fires PAN_INOPERATIVE_ALERT if false and applies the doubled-TDS assumption to all credit reconciliation. NRIs: exempt from Aadhaar requirement; engine treats null as "exempt" if residency lock = "NR". |
| `tax_regime` | enum | **OPTIONAL** |  | "NEW" ∣ "OLD" ∣ null DEFAULT for NRIs: "NEW". OLD is not legally blocked for NRIs. RNOR / ROR → if null, engine auto-computes BOTH regimes and surfaces the lower liability. Requires `deductions` block to be filled. NR         → defaults to "NEW" if null. Engine recomputes both on override. Validation: business/professional income with prior s.115BAC(6) opt-out is the only hard block (handled by DOM-03 inputs in `business_income`). |


## Section 2: RESIDENCY DETAIL  +  THE LOCK

*Screen 2A continued | Asked of all India users Runs the RS-001 engine and writes the LOCK. SOURCE OF TRUTH: "India Residency (Tax Engine Logic).docx" All input fields, ENABLED IF gates, and the lock derivation cascade below are a direct translation of that document's boolean matrix. FIELD EVALUATION ORDER (frontend must respect this sequence): 1. days_in_india_current_year (pre-filled from Layer 0) 2. days_in_india_preceding_4_years_gte_365 (if days 60–181) 3. employment_or_crew_status (if days 60–181 + preceding_4yr + Indian citizen) 4. is_departure_year, ship_nationality (if employment/crew active) 5. came_on_visit_to_india_pio_oci_citizen (if employment = none) 6. nr_years_last_10_gte_9 (if days >=182 OR came_on_visit = false) 7. days_in_india_last_7_years_lte_729 (same gate as above) 8. india_source_income_above_15l (if Layer 0 has_india_source_income = true) 9. liable_to_tax_in_another_country_being_indian_citizen (DERIVED) 10. final_india_residency_status (THE LOCK — DERIVED)*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `days_in_india_current_year` | integer | **REQUIRED** |  | integer (0–366) PRE-FILLED from Layer 0 india_days. Exact total days physically present in India this FY (1 Apr 2025 – 31 Mar 2026). Both arrival day and departure day count. Overridden by trip_log computation once log is populated. |
| `days_in_india_preceding_4_years_gte_365` | bool | **CONDITIONAL** | days_in_india_current_year >= 60 AND days_in_india_current_year < 182 | bool Across the 4 preceding FYs combined (FY 2021-22 through FY 2024-25), were you in India for 365 days or more in total? This is the Branch 2 prerequisite. If false AND days < 182, the 60-day path does NOT trigger residency — the person falls through to the Deemed Resident check or NR. |
| `employment_or_crew_status` | enum | **CONDITIONAL** | ALL of the following are true: AND days_in_india_current_year >= 60 AND days_in_india_current_year < 182 AND days_in_india_preceding_4_years_gte_365 = true AND Layer 0 is_indian_citizen = true | "employed_abroad" ∣ "indian_ship_crew" ∣ "foreign_ship_crew" ∣ "none" Layer 0 left_india_for_employment_this_year = true Gate rationale: the employment-departure exception (s.6(1) Explanation 1) only applies to Indian citizens in the 60–181 day band who meet the preceding-4-year test. If ANY gate condition fails, this field is hidden and treated as "none" for lock derivation. Foreign ship crew: NOT covered by the employment exception (only Indian ship crew under s.6(1)(c)). |
| `is_departure_year` | bool | **CONDITIONAL** | employment_or_crew_status NOT IN ["none", null] | bool First FY this person left India for this employment/crew role? Per Binny Bansal [2026]: exception applies only in the departure year. Engine auto-resets this flag every 1 April. |
| `ship_nationality` | enum | **CONDITIONAL** | employment_or_crew_status IN ["indian_ship_crew", "foreign_ship_crew"] | "indian" ∣ "foreign" |
| `came_on_visit_to_india_pio_citizen` | bool | **CONDITIONAL** | employment_or_crew_status = "none" (i.e., the person is in the 60–181 + preceding_4yr >= 365 | bool path but is NOT leaving for employment) NOTE: if employment_or_crew_status was never shown (because the employment gate conditions failed), this field is also NOT shown. It is only relevant in the sub-tree where the person is in the 60–181 band, has >= 365 preceding days, and is NOT an employee/crew. "Did you come to India on a visit, being a PIO or an Indian citizen?" If true → the person is on the Condition C (120-day visitor) path. Engine checks days >= 120 for s.6(6)(c) RNOR. If false → the person is on the standard 60-day path. Engine checks Condition A (NR 9/10) and Condition B (< 729 days) for RNOR vs ROR. |
| `nr_years_last_10_gte_9` | bool | **CONDITIONAL** | days_in_india_current_year >= 182 OR came_on_visit_to_india_pio_oci_citizen = false (a) days >= 182 → person is RESIDENT via Branch 1; need Condition A/B (b) came_on_visit = false → person is RESIDENT via the standard 60-day | bool Of the last 10 FYs (FY 2015-16 through FY 2024-25), were you NR for 9 or more of those years? RNOR years count as NR for this test (RS-001 CA sign-off Item 1). Condition A gate for RNOR under s.6(6)(a). Gate rationale: this question is asked in exactly two scenarios: to determine RNOR vs ROR. path (not a visitor); need Condition A/B to determine RNOR vs ROR. In all other paths (visitor, deemed resident, NR), this field is not needed. |
| `days_in_india_last_7_years_lte_729` | bool | **CONDITIONAL** | days_in_india_current_year >= 182 OR came_on_visit_to_india_pio_oci_citizen = false (RS-001 CA sign-off Item 15). | bool Across the 7 preceding FYs combined, were you in India for 729 days or fewer? Threshold is "<= 729" inclusive per statutory "or less" language Condition B gate for RNOR under s.6(6)(a). Same gate rationale as nr_years_last_10_gte_9. |
| `india_source_income_above_15l` | bool | **CONDITIONAL** | Layer 0 has_india_source_income_or_assets = true | bool Is your India-source income (excluding foreign earnings) above ₹15 lakh this tax year? This is the s.6(1A) Deemed Resident threshold. If true AND the person is an Indian citizen AND NOT liable to tax in another country → the person becomes a Deemed Resident (always RNOR per s.6(6)(d)). NOTE: replaces the old `india_source_income_exact_inr` field. A boolean is sufficient to set the residency lock; exact income computation happens later in the income sections. |
| `current_year_trip_log` | array | **OPTIONAL** |  | Array of trip objects: [{ "arrival_date": "YYYY-MM-DD", "departure_date": "YYYY-MM-DD" }] Days per trip = (departure_date − arrival_date + 1). Both days count. When populated, overrides days_in_india_current_year for authoritative count. |
| `liable_to_tax_in_another_country_being_indian_citizen` | bool | **DERIVED** |  | DERIVED ∣ bool Composite boolean derived from two Layer 0 pre-fills: Layer 0 is_indian_citizen = true AND Layer 0 liable_to_tax_in_another_country = true → TRUE ALL other combinations → FALSE (citizen=false, liable=true → FALSE) (citizen=true,  liable=false → FALSE) (citizen=false, liable=false → FALSE) This is the s.6(1A) Deemed Resident BLOCKER. When TRUE, the person is an Indian citizen who IS liable to tax elsewhere — the Deemed Resident provision is blocked, and the person remains NR (if they don't qualify via the 182-day or 60-day paths). When FALSE, the Deemed Resident path is OPEN (subject to income > ₹15L). TRUTH TABLE (from source document): ┌───────────────────┬──────────────────────────┬──────────┐ │ is_indian_citizen  │ liable_to_tax_elsewhere  │ Result   │ ├───────────────────┼──────────────────────────┼──────────┤ │ true               │ true                     │ TRUE     │ │ false              │ true                     │ FALSE    │ │ true               │ false                    │ FALSE    │ │ false              │ false                    │ FALSE    │ └───────────────────┴──────────────────────────┴──────────┘ |
| `final_india_residency_status` | derived | **DERIVED** |  | DERIVED ∣ "NR" ∣ "RNOR" ∣ "ROR" The LOCK. Computed by the RS-001 engine immediately after the questions above are answered. NEVER asked of the user. ALL DOWNSTREAM SECTION GATES READ THIS FIELD. The lock must be set before the frontend reveals any further screens. ═══════════════════════════════════════════════════════════════════ EXHAUSTIVE DERIVATION CASCADE Source: "India Residency (Tax Engine Logic).docx" — direct translation Abbreviations used below: DAYS     = days_in_india_current_year P4Y_365  = days_in_india_preceding_4_years_gte_365 EMP      = employment_or_crew_status VISIT    = came_on_visit_to_india_pio_oci_citizen NR9      = nr_years_last_10_gte_9 D7_729   = days_in_india_last_7_years_lte_729 INC_15L  = india_source_income_above_15l LTAC     = liable_to_tax_in_another_country_being_indian_citizen ═══════════════════════════════════════════════════════════════════ ─── ROR (2 paths) ─────────────────────────────────────────────── ROR-1: DAYS >= 182 AND NR9 = false AND D7_729 = false ROR-2: DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = false AND NR9 = false AND D7_729 = false ─── RNOR (9 paths) ────────────────────────────────────────────── RNOR-1 (Condition A via 182-day): DAYS >= 182 AND NR9 = true RNOR-2 (Condition B via 182-day): DAYS >= 182 AND D7_729 = true RNOR-3 (Employment departure + Deemed Resident): DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = any value (not "none") AND INC_15L = true AND LTAC = false RNOR-4 (Visitor 120-day — Condition C): DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND DAYS >= 120 AND DAYS < 182 AND INC_15L = true RNOR-5 (Non-visitor, Condition A via 60-day): DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = false AND NR9 = true RNOR-6 (Non-visitor, Condition B via 60-day): DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = false AND D7_729 = true RNOR-7 (Deemed Resident — days < 60): DAYS < 60 AND INC_15L = true AND LTAC = false RNOR-8 (Deemed Resident — 60–181, preceding 4yr < 365): DAYS >= 60 AND DAYS < 182 AND P4Y_365 = false AND INC_15L = true AND LTAC = false RNOR-9 (Visitor < 120 days + Deemed Resident): DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND DAYS < 120 AND INC_15L = true AND LTAC = false ─── NR (8 paths) ──────────────────────────────────────────────── NR-1:  DAYS < 60 AND INC_15L = true AND LTAC = true (Deemed Resident blocked: Indian citizen liable elsewhere) NR-2:  DAYS < 60 AND INC_15L = false (No income threshold met; no path to residency) NR-3:  DAYS >= 60 AND DAYS < 182 AND P4Y_365 = false AND INC_15L = true AND LTAC = true (60-day path fails, Deemed Resident blocked) NR-4:  DAYS >= 60 AND DAYS < 182 AND P4Y_365 = false AND INC_15L = false (60-day path fails, no Deemed Resident) NR-5:  DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND DAYS >= 120 AND DAYS < 182 AND INC_15L = false (Visitor 120-day path: meets days but income <= 15L) NR-6:  DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND DAYS < 120 AND INC_15L = true AND LTAC = true (Visitor < 120 days, Deemed Resident blocked) NR-7:  DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = any value (not "none") AND INC_15L = false (Employment departure, income <= 15L → no Deemed Resident) NR-8:  DAYS >= 60 AND DAYS < 182 AND P4Y_365 = true AND EMP = any value (not "none") AND INC_15L = true AND LTAC = true (Employment departure, income > 15L but Deemed Resident blocked) ─── ENGINE IMPLEMENTATION NOTES ───────────────────────────────── 1. Evaluate top-down: DAYS >= 182 first, then DAYS 60–181 sub-tree, then DAYS < 60 sub-tree. 2. Within the 60–181 sub-tree, the FIRST fork is P4Y_365. If P4Y_365 = false → skip directly to Deemed Resident check (RNOR-8 if INC_15L + !LTAC, else NR-3 or NR-4). 3. If P4Y_365 = true → fork on EMP: EMP != "none" → employment path (RNOR-3 or NR-7/NR-8) EMP = "none"  → fork on VISIT: VISIT = true  → visitor path (RNOR-4, RNOR-9, NR-5, NR-6) VISIT = false → standard path (ROR-2, RNOR-5, RNOR-6) 4. Deemed Resident paths (RNOR-3, RNOR-7, RNOR-8, RNOR-9) are ALWAYS RNOR (never ROR) per s.6(6)(d). The Condition A/B check is NOT applied to Deemed Residents. 5. RNOR-1 and RNOR-2 are NOT mutually exclusive. A person with days >= 182 AND NR9 = true AND D7_729 = true matches BOTH. The result is the same (RNOR), so no conflict. 6. The employment_or_crew_status field may be null/hidden when the gate conditions don't fire. In that case, treat as "none" for lock derivation. Same for came_on_visit_to_india_pio_oci_citizen. |


## Section 3: DTAA INPUT

*Screen 2B | ENABLED IF: residency_detail.final_india_residency_status = "NR"*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `tax_residency_country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 e.g. "US" ∣ "AE" ∣ "GB" ∣ "SG" ∣ "CA" Country where you currently pay personal income tax (your tax home). Drives the entire treaty rate table. |
| `is_us_resident_for_dtaa` | bool | **CONDITIONAL** | tax_residency_country = "US" | bool Triggers the Savings Clause alert (DTAA Art.1(3)) — Form 67 required to claim FTC for US taxes paid. Alert-only; does not block treaty benefit. NOTE: detailed US residency classification lives in layer1_us. |
| `trc_status` | bool | **CONDITIONAL** |  | bool Do you have a valid Tax Residency Certificate (TRC) from your country of residence? Without TRC → domestic rates apply (e.g. 30% NRO interest vs 10–15% treaty rate). |
| `has_permanent_establishment_in_india` | bool | **CONDITIONAL** |  | bool Do you have a fixed place of business, office, or dependent agent in India? If true → DUAL_RESIDENCY_REVIEW flag fires; PE income taxable in India regardless of DTAA. |
| `income_type` | enum | **OPTIONAL** |  | "interest" ∣ "dividend" ∣ "royalty" ∣ "fts" ∣ "capital_gains" |
| `elected_rate` | decimal | **OPTIONAL** |  | decimal e.g. 0.15 |
| `treaty_article` | string | **OPTIONAL** |  | string e.g. "Art. 11(2)(a) India-US DTAA" |
| `mfn_clause_invoked` | bool | **OPTIONAL** |  | bool For treaties with MFN protocols (Netherlands, France, Switzerland, etc.). Triggers per-stream rate recomputation against the lowest-rate comparable treaty. |


## Section 4: PROGRESSIVE COMPLIANCE DOCUMENTS

*PROGRESSIVE | Required before final ITR computation ENABLED IF: dtaa.tax_residency_country is set*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `validity_start_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" Engine validates against each income payment date per Rule 21AB. |
| `validity_end_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" |
| `document_uploaded` | bool | **OPTIONAL** |  | bool — true = VERIFIED (treaty rates unlocked for ITR XML); false = DECLARED (provisional treaty rates with badge). |
| `is_filed` | bool | **CONDITIONAL** |  | bool |
| `ack_number` | string | **CONDITIONAL** |  | string (15-digit ack from IT e-filing portal) Electronic Form 10F mandatory for PAN holders. Treaty rates BLOCKED until ack entered. |
| `is_available` | bool | **OPTIONAL** |  | bool |
| `rate` | decimal | **CONDITIONAL** |  | decimal e.g. 0.05. ENABLED IF is_available = true Overrides BOTH domestic AND DTAA rate. |
| `validity_start_date` | date | **CONDITIONAL** |  | ENABLED IF is_available = true |
| `validity_end_date` | date | **CONDITIONAL** |  | ENABLED IF is_available = true |
| `covered_income_types` | array | **CONDITIONAL** |  | array e.g. ["PROPERTY_CG","NRO_INTEREST","DIVIDEND"] |
| `chapter_xiia_elected` | bool | **OPTIONAL** |  | bool ∣ PROGRESSIVE Have you ever elected the Chapter XII-A special tax regime in any prior ITR? Once opted out, CANNOT re-enter (s.115I) — flag for CA before any change. |


## Section 5: BANK ACCOUNTS

*ENABLED IF: residency lock IN ["NR","RNOR","ROR"] Array — one object per account*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `bank_name` | string | **OPTIONAL** |  | string |
| `account_type` | enum | **REQUIRED** |  | "NRE"∣"NRO"∣"FCNR"∣"RFC"∣"GIFT_IFSC"∣"SAVINGS"∣"CURRENT" |
| `current_balance` | currency | **REQUIRED** |  | number |
| `current_balance_currency` | string | **OPTIONAL** |  | ISO 4217 |
| `annual_interest_rate` | decimal | **OPTIONAL** |  | decimal e.g. 0.065 |
| `interest_credited_this_fy_inr` | integer | **REQUIRED** |  | integer (INR) — actual interest credited this FY. Required for s.80TTA/TTB computation and for distinguishing NRE-exempt from NRO-taxable interest. |
| `account_conversion_date` | date | **CONDITIONAL** | account_type = "NRE" AND lock changed to RNOR or ROR this FY. | "YYYY-MM-DD" ∣ OPTIONAL CRITICAL: even 1 day as ROR = full year NRE interest taxable (no mid-year split). |
| `fcnr_maturity_date` | date | **CONDITIONAL** | account_type = "FCNR" |  |
| `nro_balance` | number | **CONDITIONAL** |  | ENABLED IF account_type = "NRO". Tracks USD 1M limit. |
| `nro_balance_currency` | string | **OPTIONAL** |  |  |


## Section 6: NRO REPATRIATION

*ENABLED IF: any bank_account has account_type = "NRO"*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `cumulative_repatriated_usd_this_fy` | currency | **OPTIONAL** |  | number (USD). Annual limit: USD 1M aggregate. Alerts at 80% / 95%. |
| `pending_repatriation_inr` | currency | **OPTIONAL** |  | number (INR). Determines Form 15CA/15CB trigger (INR 5L threshold). |
| `tds_deducted_on_nro_balance` | bool | **OPTIONAL** |  | bool. false → TAX_CLEARANCE_REQUIRED fires. |


## Section 7: IMMOVABLE PROPERTY

*GATE: has_indian_property_transaction (asked first) Applies to ALL residency statuses (rates and TDS obligations differ).*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_indian_property_transaction` | bool | **REQUIRED** |  | bool — GATE Selling, or have sold, Indian immovable property this FY? |
| `property_type` | enum | **CONDITIONAL** |  | "residential"∣"commercial"∣"land"∣"agricultural_rural"∣"under_construction" agricultural_rural → exempt (s.10(37)). Only "residential" qualifies for s.54. |
| `acquisition_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD". Inherited: original owner's date. |
| `actual_cost` | currency | **CONDITIONAL** |  | number (INR) |
| `actual_cost_currency` | string | **OPTIONAL** |  | ISO 4217 |
| `pre_2001_fmv_inr` | integer | **CONDITIONAL** | acquisition_date < "2001-04-01" | Engine uses MAX(actual_cost, pre_2001_fmv_inr) as cost basis. |
| `transfer_expenses_inr` | currency | **OPTIONAL** |  | number (INR). Brokerage, legal fees, stamp duty paid by seller. Statutorily deductible from sale consideration before CG computation. |
| `sale_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" FA 2024: pre-23 Jul → 20% indexed (residents only); post-23 Jul → 12.5% no indexation; NRIs: always 12.5% post Jul 2024. |
| `sale_consideration` | currency | **CONDITIONAL** |  | number (INR) |
| `sale_consideration_currency` | string | **OPTIONAL** |  |  |
| `stamp_duty_value` | currency | **OPTIONAL** |  | number (INR) — circle rate at SALE date. s.50C: if SDV > sale price by > 10%, SDV used as deemed consideration. |
| `stamp_duty_value_currency` | string | **OPTIONAL** |  |  |
| `buyer_tan` | string | **CONDITIONAL** |  | string. ENABLED IF lock = "NR" |
| `buyer_tds_deducted_inr` | integer | **CONDITIONAL** |  | integer. ENABLED IF lock = "NR" |
| `buyer_tds_challan_number` | string | **OPTIONAL** |  | string.  ENABLED IF lock = "NR" s.195 TDS = 12.5% + surcharge + cess on FULL sale value (not gain) for NRI sellers unless Section 197 cert exists. Required for 26AS reconciliation. |
| `is_joint_property` | bool | **OPTIONAL** |  | bool |
| `ownership_percentage` | number | **CONDITIONAL** |  | 1–100. ENABLED IF is_joint_property = true |
| `is_inherited` | bool | **OPTIONAL** |  | bool |
| `original_owner_acquisition_date` | date | **CONDITIONAL** |  | ENABLED IF is_inherited = true |
| `original_owner_cost` | number | **CONDITIONAL** |  | ENABLED IF is_inherited = true |
| `original_owner_cost_currency` | string | **CONDITIONAL** |  | ENABLED IF is_inherited = true |
| `reinvestment_exemption_claimed` | enum | **OPTIONAL** |  | "none" ∣ "s54" ∣ "s54f" ∣ "s54ec" |
| `new_property_cost` | number | **CONDITIONAL** |  | ENABLED IF claimed IN ["s54","s54f"]. Cap ₹10Cr. |
| `new_property_cost_currency` | string | **OPTIONAL** |  |  |
| `new_property_purchase_date` | date | **CONDITIONAL** |  |  |
| `s54_two_house_option` | bool | **DERIVED** |  | DERIVED ∣ bool TRUE when claimed = "s54" AND LTCG <= ₹2 Cr AND not previously exercised. |
| `bond_investment` | number | **CONDITIONAL** |  | ENABLED IF claimed = "s54ec". Cap ₹50L. |
| `bond_investment_currency` | string | **OPTIONAL** |  |  |
| `bond_investment_date` | date | **CONDITIONAL** |  | Within 6 months of sale_date. 5-year lock. |


## Section 8: FINANCIAL HOLDINGS (listed equity, MFs, ETFs, bonds)

*Applies to ALL residency statuses*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_financial_transactions` | bool | **REQUIRED** |  | bool — gate |
| `asset_class` | enum | **CONDITIONAL** |  | "listed_equity"∣"equity_mutual_fund"∣"debt_mutual_fund_pre_apr23" ∣"debt_mutual_fund_post_apr23"∣"hybrid_mf_equity"∣"hybrid_mf_debt" ∣"international_mf"∣"fof"∣"etf"∣"bond_listed"∣"reit_invit"∣"vda_crypto" |
| `asset_name_or_ticker` | string | **OPTIONAL** |  |  |
| `isin` | string | **OPTIONAL** |  |  |
| `quantity` | number | **CONDITIONAL** |  |  |
| `acquisition_date` | date | **CONDITIONAL** |  |  |
| `purchase_value` | number | **CONDITIONAL** |  |  |
| `purchase_currency` | string | **OPTIONAL** |  |  |
| `fmv_31jan2018_per_unit_inr` | integer | **CONDITIONAL** | acquisition_date < "2018-02-01" AND asset_class IN ["listed_equity","equity_mutual_fund"] | Grandfathered FMV per s.112A. Engine uses MAX(purchase_value, qty * fmv_31jan2018) as cost. |
| `sale_date` | date | **CONDITIONAL** |  |  |
| `sale_value` | number | **CONDITIONAL** |  |  |
| `sale_currency` | string | **OPTIONAL** |  |  |
| `stt_paid` | number | **CONDITIONAL** |  |  |


## Section 9: COMMODITIES (Gold, Silver, SGB)

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_commodity_transactions` | bool | **REQUIRED** |  |  |
| `commodity_type` | enum | **CONDITIONAL** |  | "physical_gold"∣"sovereign_gold_bond_original"∣"sovereign_gold_bond_secondary" ∣"silver"∣"gold_etf"∣"gold_fund_of_funds"∣"other" |
| `quantity` | number | **CONDITIONAL** |  |  |
| `acquisition_date` | date | **CONDITIONAL** |  |  |
| `purchase_value` | number | **CONDITIONAL** |  |  |
| `purchase_currency` | string | **OPTIONAL** |  |  |
| `is_maturity_redemption` | bool | **CONDITIONAL** | commodity_type = "sovereign_gold_bond_original" | true → FULLY EXEMPT. |
| `sale_date` | date | **CONDITIONAL** |  |  |
| `sale_value` | number | **CONDITIONAL** |  |  |
| `sale_currency` | string | **OPTIONAL** |  |  |


## Section 10: UNLISTED EQUITY

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_unlisted_equity_transaction` | bool | **REQUIRED** |  |  |
| `company_name` | string | **OPTIONAL** |  |  |
| `acquisition_date` | date | **CONDITIONAL** |  |  |
| `cost_per_share` | number | **CONDITIONAL** |  |  |
| `cost_per_share_currency` | string | **OPTIONAL** |  |  |
| `number_of_shares` | number | **CONDITIONAL** |  |  |
| `sale_price_per_share` | number | **CONDITIONAL** |  |  |
| `sale_price_per_share_currency` | string | **OPTIONAL** |  |  |
| `sale_date` | date | **CONDITIONAL** |  |  |
| `fmv_valuation_report_date` | date | **CONDITIONAL** | lock = "NR" | FEMA: NRI selling to resident must sell at >= FMV. Stale if > 90 days. |
| `original_investment_currency` | string | **CONDITIONAL** | lock = "NR" | If foreign: s.48 First Proviso applies (currency-neutralised CG). |
| `original_cost_in_foreign_currency` | string | **CONDITIONAL** | original_investment_currency != "INR" |  |


## Section 11: SHARE BUYBACK (post-1 Oct 2024 two-leg treatment)

*Buybacks on/after 1 Oct 2024: full consideration = deemed dividend (slab) AND original cost = capital loss (carry-forward).*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_buyback_transaction` | bool | **REQUIRED** |  |  |
| `company_name` | string | **OPTIONAL** |  |  |
| `isin` | string | **OPTIONAL** |  |  |
| `buyback_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" |
| `tender_or_open_market` | enum | **CONDITIONAL** |  | "tender" ∣ "open_market" |
| `shares_tendered` | integer | **CONDITIONAL** |  | integer |
| `consideration_received_inr` | integer | **CONDITIONAL** |  | integer (INR) |
| `original_cost_inr` | integer | **CONDITIONAL** |  | integer (INR) |
| `original_acquisition_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" |
| `buyback_pre_or_post_oct2024` | derived | **DERIVED** |  | DERIVED ∣ "pre_oct2024" ∣ "post_oct2024" Engine sets based on buyback_date. post_oct2024 → TWO LEGS: Leg A: full consideration_received_inr → other_sources.dividend_inr (slab) Leg B: original_cost_inr → capital loss → carry_forward_losses.cg_loss_cf pre_oct2024 → s.115QA company-level tax; nothing taxed in shareholder's hands. |
| `deemed_dividend_inr` | integer | **DERIVED** |  | DERIVED ∣ integer (INR) Equals consideration_received_inr if post_oct2024, else 0. Routes to other_sources. |
| `capital_loss_inr` | integer | **DERIVED** |  | DERIVED ∣ integer (INR) Equals original_cost_inr if post_oct2024, else 0. Routes to carry_forward_losses. |


## Section 12: DOMESTIC INCOME HEADS (detailed sub-fields)

*Income scope: NR → India-source only. RNOR → India + India-controlled business. ROR → worldwide.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_salary_income` | bool | **REQUIRED** |  | bool — gate |
| `gross_salary_inr` | integer | **CONDITIONAL** |  | integer (INR) |
| `exempt_allowances_inr` | integer | **OPTIONAL** |  | integer — total exempt allowances |
| `hra_received_inr` | integer | **OPTIONAL** |  | integer |
| `rent_paid_inr` | integer | **CONDITIONAL** |  | integer |
| `is_metro_city` | bool | **CONDITIONAL** |  | bool — drives 50% vs 40% HRA cap |
| `basic_da_inr` | integer | **CONDITIONAL** |  | integer — base for HRA computation |
| `lta_claimed_inr` | integer | **OPTIONAL** |  | integer |
| `perquisites_inr` | integer | **OPTIONAL** |  | integer |
| `esop_perquisite_inr` | integer | **OPTIONAL** |  | integer — FMV at exercise minus exercise price; taxed as salary in exercise year. |
| `professional_tax_inr` | integer | **OPTIONAL** |  | integer |
| `employer_nps_contribution_inr` | integer | **OPTIONAL** |  | integer — s.80CCD(2), outside 80C ceiling |
| `prior_employer_salary_inr` | integer | **OPTIONAL** |  | integer — mid-year switch reconciliation |
| `has_house_property_income` | bool | **REQUIRED** |  | bool — gate |
| `property_use` | enum | **CONDITIONAL** |  | "SOP" ∣ "LOP" ∣ "DLOP" |
| `gross_annual_value_inr` | integer | **CONDITIONAL** |  |  |
| `municipal_taxes_paid_inr` | integer | **OPTIONAL** |  |  |
| `interest_on_borrowed_capital_inr` | integer | **CONDITIONAL** |  |  |
| `pre_construction_interest_inr` | integer | **OPTIONAL** |  | 1/5 schedule across 5 years post-completion |
| `is_self_occupied_with_loan` | bool | **CONDITIONAL** |  | bool — ₹2L cap under s.24(b) |
| `co_owner_share_percent` | number | **OPTIONAL** |  | 1–100 |


### Section 12.B — Business & F&O (DOM_Tax_03 v2.0)

*ENABLED IF: `has_business_or_fo_income = true`. **v5.1 FIXES**: `nature_of_business` and `presumptive_scheme` are arrays. `goods_vehicles[]` template normalized. **+20 new fields** for s.40(a) TDS-defaults, s.41 deemed income, stock, s.35/35D/35DDA, STT/CTT, AMT credit BF.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_business_or_fo_income` | bool | **REQUIRED** |  | bool — GATE. If false, entire business_income block is hidden. |
| `nature_of_business` | array | **CONDITIONAL** | has_business_or_fo_income = true | Array of enum: "small_business" ∣ "professional" ∣ "goods_transport" ∣ "fno_trader" ∣ "intraday_trader" ∣ "regular_business" ∣ "partner_in_firm". **v5.1 BUG-FIX**: changed from single enum to array. Taxpayers routinely hold multiple classifications simultaneously (e.g., professional consultant + F&O + intraday). Empty array = no business classification (gate should not have been true). |
| `presumptive_scheme` | array | **CONDITIONAL** | has_business_or_fo_income = true | Array of enum: "s44AD" ∣ "s44ADA" ∣ "s44AE". **v5.1 BUG-FIX**: changed from single enum to array. DOM_Tax_03 §4.2 explicitly permits simultaneous election of s.44AE (transport) + s.44AD (other business). Empty array = "none" (regular computation). **NR-scope gate (engine)**: s.44AD / s.44ADA require lock IN ["ROR","RNOR"]; s.44AE has no residency restriction. |
| `profession_type` | enum | **CONDITIONAL** | "s44ADA" IN presumptive_scheme OR "professional" IN nature_of_business | "legal" ∣ "medical" ∣ "engineering" ∣ "architecture" ∣ "accountancy" ∣ "technical_consultancy" ∣ "interior_decoration" ∣ "authorised_representative" ∣ "film_artist" ∣ "it_services" ∣ "other". Exhaustive list per Rule 6F. "other" → s.44ADA not available. DOM_Tax_03 §3.1. |
| `s115BAC_optout_history` | bool | **OPTIONAL** |  | Has user previously opted OUT of New Regime under s.115BAC(6)? If true → PERMANENTLY locked into Old Regime for all years with business income. Hard block on profile.tax_regime = "NEW". DOM_Tax_03 §1.3. |
| `turnover_inr` | integer | **CONDITIONAL** | has_business_or_fo_income = true | integer (INR). Total gross turnover/receipts. Used for s.44AB audit threshold (₹1Cr cash / ₹10Cr digital), s.44AD eligibility (₹2Cr / ₹3Cr), s.44ADA eligibility (₹75L). |
| `digital_receipts_inr` | integer | **CONDITIONAL** | "s44AD" IN presumptive_scheme | integer (INR). Receipts via banking channels (UPI, NEFT, RTGS, card, account payee cheque). Drives 6% presumptive rate and ₹3Cr enhanced threshold (if digital ≥ 95%). Validation: digital + cash must equal turnover. DOM_Tax_03 §2.2. |
| `cash_receipts_inr` | integer | **CONDITIONAL** | "s44AD" IN presumptive_scheme | integer (INR). Receipts in cash or non-banking modes. Drives 8% presumptive rate. DOM_Tax_03 §2.2. |
| `gross_receipts_inr` | integer | **CONDITIONAL** | "s44ADA" IN presumptive_scheme OR ("professional" IN nature_of_business AND presumptive_scheme = []) | integer (INR). For professionals: s.44ADA threshold check at ₹75L. For regular computation: opening figure for PGBP. |
| `s44AD_last_exit_ay` | string | **OPTIONAL** |  | e.g. "AY2023-24" ∣ null. AY in which taxpayer last opted out of s.44AD. Engine checks: current_ay minus last_exit_ay ≤ 5 → S44AD_REENTRY_BLOCKED fires, s.44AD disabled in UI. DOM_Tax_03 §2.5. |
| `s44AD_opted_current_year` | bool | **OPTIONAL** |  | Is taxpayer electing s.44AD this year? Used with s44AD_last_exit_ay for 5-year ban enforcement. If false and prior year had s.44AD, engine records exit AY. |
| `goods_vehicles` | array | **CONDITIONAL** | "s44AE" IN presumptive_scheme | Array of goods-carriage vehicle objects. Max 10 vehicles. Engine sums per-vehicle presumptive income. DOM_Tax_03 §4. |
| `goods_vehicles[].vehicle_type` | enum | **CONDITIONAL** |  | "heavy" ∣ "light". Heavy (GVW > 12 tonnes) → ₹1,000/tonne/month. Light (GVW ≤ 12 tonnes) → ₹7,500/vehicle/month. |
| `goods_vehicles[].gvw_tonnes` | integer | **CONDITIONAL** | vehicle_type = "heavy" | integer. Gross Vehicle Weight in tonnes. Drives per-tonne presumptive income computation for heavy vehicles only. |
| `goods_vehicles[].months_owned` | integer | **CONDITIONAL** |  | integer (1–12). Months (or part of month) the vehicle was owned during the FY. Part-month counts as full month per DOM_Tax_03 §4.2. |
| `opening_stock_inr` | integer | **CONDITIONAL** | presumptive_scheme = [] AND "regular_business" IN nature_of_business | **NEW v5.1**. integer (INR). Opening inventory at 1 April. DOM_Tax_03 §11.3. Valuation: cost OR net realisable value, whichever is LOWER. |
| `closing_stock_inr` | integer | **CONDITIONAL** | presumptive_scheme = [] AND "regular_business" IN nature_of_business | **NEW v5.1**. integer (INR). Closing inventory at 31 March. Engine flags GROSS_PROFIT_RATIO_VARIANCE if GP ratio deviates >10% from prior year (DOM_Tax_03 §11.3 audit trigger). |
| `gst_registration_status` | enum | **CONDITIONAL** | has_business_or_fo_income = true AND presumptive_scheme = [] | "regular" ∣ "composition" ∣ "unregistered". Drives taxable turnover: regular = gross minus GST collected; composition = gross (implicit GST); unregistered = gross. DOM_Tax_03 §18.1. |
| `gst_collected_inr` | integer | **CONDITIONAL** | gst_registration_status = "regular" | integer (INR). Total GST collected — LIABILITY, not income. Subtracted from gross receipts for taxable turnover. Only irrecoverable GST (blocked ITC) is an allowable expense. |
| `expenses.rent_for_business_premises_inr` | integer | **CONDITIONAL** | presumptive_scheme = [] | integer (INR). s.30. Fully deductible. |
| `expenses.repairs_maintenance_inr` | integer | **OPTIONAL** |  | integer (INR). s.30 (buildings) + s.31 (plant/machinery). Current repairs only; capital expenditure → asset block. |
| `expenses.employee_salary_wages_inr` | integer | **OPTIONAL** |  | integer (INR). s.36(1)(ii). Subject to s.43B actual payment rule. |
| `expenses.employee_bonus_commission_inr` | integer | **OPTIONAL** |  | integer (INR). s.36(1)(ii). Subject to s.43B actual payment rule. |
| `expenses.interest_on_borrowed_capital_inr` | integer | **OPTIONAL** |  | integer (INR). s.36(1)(iii). Must be for business purpose. Pre-asset-use interest capitalised to asset cost. |
| `expenses.insurance_premium_inr` | integer | **OPTIONAL** |  | integer (INR). s.30 (premises) + s.31 (plant) + s.36(1)(i) (livestock). |
| `expenses.bad_debts_written_off_inr` | integer | **OPTIONAL** |  | integer (INR). s.36(1)(vii). Must be previously included in income AND written off in books. Provision not deductible. Recovery → s41_bad_debt_recovery_inr. |
| `expenses.brokerage_on_fno_inr` | integer | **OPTIONAL** |  | integer (INR). Brokerage fees/commissions paid to broker for F&O trades. DOM_Tax_03 §6.3. STT is NOT deductible (see stt_paid_inr). |
| `expenses.exchange_charges_inr` | integer | **OPTIONAL** |  | integer (INR). Exchange transaction charges, SEBI turnover fees, clearing member charges. |
| `expenses.advisory_and_data_subscriptions_inr` | integer | **OPTIONAL** |  | integer (INR). Market data terminals (TradingView, Bloomberg), SEBI-registered advisory fees. |
| `expenses.internet_proportion_inr` | integer | **OPTIONAL** |  | integer (INR). Proportionate internet charges for trading vs personal use. |
| `expenses.home_office_proportion_inr` | integer | **OPTIONAL** |  | integer (INR). Proportionate rent/electricity for room used exclusively for trading/business. |
| `expenses.margin_interest_inr` | integer | **OPTIONAL** |  | integer (INR). Interest on margin funding / margin pledge facility. |
| `expenses.ca_professional_fees_inr` | integer | **OPTIONAL** |  | integer (INR). CA and professional fees for F&O/business tax filing and advisory. |
| `expenses.other_business_expenses_inr` | integer | **OPTIONAL** |  | integer (INR). s.37(1) residual. Revenue expenditure wholly and exclusively for business. Excludes capital, personal, and illegal expenses. |
| `expenses.total_cash_payments_exceeding_limit_inr` | integer | **OPTIONAL** |  | integer (INR). s.40A(3) — cash payments exceeding ₹10,000/day to single party (₹35,000 for transporters). 100% DISALLOWED. Added back to taxable income. DOM_Tax_03 §9.6. |
| `expenses.has_related_party_payments` | bool | **OPTIONAL** |  | s.40A(2). Any payments to specified related parties? If true → RELATED_PARTY_PAYMENT_REVIEW fires for CA review. Engine cannot determine "excessive." |
| `expenses.payments_to_non_residents_no_tds_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.40(a)(i) — payments to non-residents where TDS not deducted or not deposited by return due date. **100% DISALLOWED**. DOM_Tax_03 §9.2.1. Restored in AY of actual TDS deposit. |
| `expenses.payments_to_residents_no_tds_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.40(a)(ia) — payments to residents where TDS not deducted or not deposited by return due date. **30% DISALLOWED** (not 100%). DOM_Tax_03 §9.2.2. TDS_DEFAULT_DISALLOWANCE fires. Restored in AY of actual TDS deposit. |
| `expenses.employer_pf_esi_contribution_inr` | integer | **OPTIONAL** |  | integer (INR). Employer contribution to PF, ESI, gratuity. Subject to s.43B actual payment rule. |
| `expenses.employer_pf_esi_paid_before_due_date` | bool | **CONDITIONAL** | employer_pf_esi_contribution_inr > 0 | Has PF/ESI been paid before return filing due date? If false → deduction deferred. S43B_PAYMENT_PENDING fires. |
| `expenses.s35_own_revenue_research_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.35(1)(i). Revenue expenditure on own in-house scientific research. 100% deductible (post-FA-2023; no weighted benefit). |
| `expenses.s35_own_capital_research_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.35(2). Capital expenditure on own scientific research (other than land). 100% deductible in year incurred. |
| `expenses.s35_donation_to_approved_body_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.35(1)(ii) / s.35(2AA). Donation to approved research associations, National Lab, IIT, university. 100% deductible (no weighted benefit from AY 2024-25). |
| `expenses.s35D_total_preliminary_expenses_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.35D preliminary expenses. Engine derives annual deduction = total / 5. Cap: 5% of cost of project OR capital employed. |
| `expenses.s35D_year_of_commencement` | string | **CONDITIONAL** | s35D_total_preliminary_expenses_inr > 0 | **NEW v5.1**. e.g. "FY2023-24". FY of business commencement. Engine computes AY1–AY5 amortisation window. |
| `expenses.s35DDA_vrs_payments_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.35DDA VRS payments. Engine derives annual deduction = total / 5. Full deduction in year of payment NOT available. |
| `expenses.s35DDA_first_year_of_payment` | string | **CONDITIONAL** | s35DDA_vrs_payments_inr > 0 | **NEW v5.1**. e.g. "FY2023-24". FY in which VRS payment was made. Engine computes 5-AY amortisation window. |
| `expenses.stt_paid_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). Securities Transaction Tax paid on F&O and equity-delivery trades. **NOT DEDUCTIBLE**. Recorded for broker contract note / Form 26AS reconciliation only. DOM_Tax_03 §6.3, s.36(1)(xv). |
| `expenses.ctt_paid_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). Commodities Transaction Tax paid on commodity derivative trades. **NOT DEDUCTIBLE**. Recorded for reconciliation only. DOM_Tax_03 §6.3. |
| `asset_blocks[].asset_class` | enum | **CONDITIONAL** | presumptive_scheme = [] | "building_residential" (5%) ∣ "building_commercial" (10%) ∣ "building_temporary" (40%) ∣ "plant_machinery_general" (15%) ∣ "computers_peripherals" (40%) ∣ "motor_vehicles" (15%) ∣ "heavy_vehicles" (30%) ∣ "furniture_fittings" (10%) ∣ "intangible_assets" (25%) ∣ "books_annual" (100%) ∣ "books_other" (60%) ∣ "solar_energy" (40%) ∣ "wind_energy" (40%). Goodwill NOT allowed (excluded AY 2021-22+). DOM_Tax_03 §8.3. |
| `asset_blocks[].opening_wdv_inr` | integer | **CONDITIONAL** | presumptive_scheme = [] | integer (INR). WDV at start of FY (1 April). |
| `asset_blocks[].additions_during_year_inr` | integer | **OPTIONAL** |  | integer (INR). Cost of assets added to this block during the FY. |
| `asset_blocks[].addition_date` | date | **CONDITIONAL** | additions_during_year_inr > 0 | "YYYY-MM-DD". If on or after 1 October → only 50% depreciation in year of addition (half-year rule). DOM_Tax_03 §8.2. |
| `asset_blocks[].sale_consideration_inr` | integer | **OPTIONAL** |  | integer (INR). If sale > opening_wdv + additions → block WDV negative → STCG under s.50 → Capital Gains module. DEPRECIABLE_ASSET_STCG fires. |
| `asset_blocks[].is_new_manufacturing_asset` | bool | **OPTIONAL** |  | If true → 20% additional depreciation on cost under s.32(1)(iia). Not available for ships, aircraft, office appliances, computers, furniture, secondhand assets. |
| `asset_blocks[].is_in_notified_backward_area` | bool | **OPTIONAL** |  | If true → 15% investment allowance under s.32AD on cost of new plant/machinery in Bihar, WB, Telangana, AP. |
| `speculative_income_inr` | integer | **OPTIONAL** |  | integer (INR). Net P&L from intraday equity trades (same-day, no delivery). Loss ring-fenced: offsets speculative profit only, 4-yr carry forward. DOM_Tax_03 §5. |
| `speculative_turnover_inr` | integer | **OPTIONAL** |  | integer (INR). Sum of abs(individual intraday trade P&L). NOT net position. Example: +₹4L and -₹3L across trades = ₹7L turnover. s.44AB audit gate: ≥ ₹1Cr → audit required. Enhanced ₹10Cr digital threshold does NOT apply to speculative. DOM_Tax_03 §5.4. |
| `non_speculative_income_inr` | integer | **OPTIONAL** |  | integer (INR). Net P&L from F&O derivatives on recognised exchanges (equity index/stock futures/options, currency, commodity, interest rate). Loss offsets any income except salary; 8-yr carry forward. DOM_Tax_03 §6. |
| `fno_turnover_inr` | integer | **OPTIONAL** |  | integer (INR). F&O turnover for s.44AB. Futures: abs(net settlement P&L). Options bought: abs(net P&L). Options sold: abs(net P&L) + premium received. ≥ ₹10Cr (95%+ digital) or ≥ ₹1Cr → audit. F&O loss + total income > exemption → audit. DOM_Tax_03 §6.2. |
| `s41_remission_income_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.41(1). Amount obtained by remission/cessation of a trading liability previously deducted. Taxable as PGBP even if business no longer carried on. Common cases: trade creditor waiver, bank loan principal waiver. S41_DEEMED_INCOME fires. DOM_Tax_03 §11.1.1. |
| `s41_bad_debt_recovery_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.41(4). Recovery of bad debt previously written off under s.36(1)(vii). Taxable only up to amount previously deducted. DOM_Tax_03 §11.1.3. |
| `partner_income.entity_type` | enum | **CONDITIONAL** | "partner_in_firm" IN nature_of_business | "registered_firm" ∣ "llp". Drives LLP_PROFIT_SHARE_EXEMPT flag and s.40(b) deductibility (firms only; LLPs governed by agreement + s.37(1)). DOM_Tax_03 §9.4. |
| `partner_income.remuneration_from_entity_inr` | integer | **CONDITIONAL** | "partner_in_firm" IN nature_of_business | integer (INR). Salary/bonus/commission received from firm/LLP. Taxable as PGBP. |
| `partner_income.interest_on_capital_from_entity_inr` | integer | **CONDITIONAL** | "partner_in_firm" IN nature_of_business | integer (INR). Interest on capital from firm (up to 12% p.a. under s.40(b)) or LLP (no statutory cap). Taxable as PGBP. |
| `partner_income.profit_share_exempt_inr` | integer | **OPTIONAL** |  | integer (INR). Share of profit — FULLY EXEMPT under s.10(2A) for BOTH firm and LLP. Collected for ITR disclosure, does NOT add to taxable income. |
| `msme_payables[].supplier_name` | string | **OPTIONAL** |  | Name of the micro/small enterprise supplier (Udyam registered). |
| `msme_payables[].amount_inr` | integer | **CONDITIONAL** | presumptive_scheme = [] | integer (INR). Amount payable to MSME supplier. |
| `msme_payables[].invoice_date` | date | **CONDITIONAL** | presumptive_scheme = [] | "YYYY-MM-DD". Date of acceptance of goods/services (appointed day). Drives prescribed period start. |
| `msme_payables[].has_written_agreement` | bool | **CONDITIONAL** | presumptive_scheme = [] | false → 15 days prescribed period. true → agreed date, max 45 days. |
| `msme_payables[].payment_date` | date | **CONDITIONAL** | presumptive_scheme = [] | "YYYY-MM-DD" ∣ null. If null or beyond prescribed period → MSME_PAYMENT_OVERDUE fires; deduction deferred to AY of actual payment. Compound interest at 3x RBI bank rate (monthly rests) payable to MSME — NOT deductible. Finance Act 2023, s.43B(h). DOM_Tax_03 §10.1. |
| `amt_credit_bf_inr` | integer | **OPTIONAL** |  | **NEW v5.1**. integer (INR). s.115JC AMT credit carried forward from prior AYs within 15-year utilisation window. Old Regime only — New Regime users cannot claim or utilise. Applied only when normal tax > AMT in current year. DOM_Tax_03 §13. |
| `amt_credit_bf_origin_ay` | string | **CONDITIONAL** | amt_credit_bf_inr > 0 | **NEW v5.1**. e.g. "AY2015-16". Oldest origin AY of outstanding AMT credit pool. Engine computes expiry (origin_ay + 15). AMT_CREDIT_EXPIRING flag within 2 AYs of expiry. |
| `has_agricultural_income` | bool | **CONDITIONAL** |  | bool. ENABLED IF lock IN ["ROR","RNOR"] Exempt under s.10(1) but triggers partial integration (DOM-05 §10). |
| `agricultural_income_inr` | integer | **CONDITIONAL** | has_agricultural_income = true |  |


## Section 13: OTHER SOURCES (detailed sub-fields)

*Restructured from a single integer to enable family pension s.57(iia) deduction, slab-vs-special-rate separation for surcharge cap, and correct routing of buyback dividend leg.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_other_sources_income` | bool | **REQUIRED** |  | bool — gate |
| `interest_savings_inr` | integer | **OPTIONAL** |  | integer — s.80TTA/TTB eligible |
| `interest_fd_rd_inr` | integer | **OPTIONAL** |  | integer |
| `interest_bonds_inr` | integer | **OPTIONAL** |  | integer |
| `interest_on_it_refund_inr` | integer | **OPTIONAL** |  | integer |
| `dividend_inr` | integer | **OPTIONAL** |  | integer (slab rate post FA 2020) |
| `gifts_above_50k_inr` | integer | **OPTIONAL** |  | integer — s.56(2)(x) |
| `family_pension_gross_inr` | integer | **OPTIONAL** |  | integer |
| `family_pension_standard_deduction_inr` | integer | **DERIVED** |  | DERIVED ∣ integer = MIN(15000, family_pension_gross_inr / 3) |
| `winnings_lottery_gaming_inr` | integer | **OPTIONAL** |  | integer — s.115BB / s.115BBJ flat 30% |
| `online_gaming_winnings_inr` | integer | **OPTIONAL** |  | integer — s.115BBJ flat 30%, no set-off |
| `deemed_dividend_from_buyback_inr` | integer | **DERIVED** |  | DERIVED ∣ integer Sum of share_buyback.transactions[].deemed_dividend_inr where post_oct2024. Slab-taxed; included in surcharge "normal income" bucket. |


## Section 14: DEDUCTIONS (Chapter VI-A)

*Screen 2L | ENABLED IF: profile.tax_regime = "OLD" OR lock IN ["RNOR","ROR"] (auto Old-vs-New comparison) NRI ELIGIBILITY: NRIs are statutorily blocked from 80DD, 80DDB, 80U, 80TTB, and from FRESH PPF/SCSS/SSY contributions (existing accounts may continue). The engine enforces these blocks based on the residency lock.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `epf_employee_inr` | integer | **OPTIONAL** |  |  |
| `ppf_inr` | integer | **OPTIONAL** |  | ENGINE BLOCK if lock="NR" AND new account |
| `elss_inr` | integer | **OPTIONAL** |  |  |
| `life_insurance_premium_inr` | integer | **OPTIONAL** |  |  |
| `principal_home_loan_inr` | integer | **OPTIONAL** |  |  |
| `nsc_inr` | integer | **OPTIONAL** |  | ENGINE BLOCK if lock="NR" AND new |
| `tuition_fees_inr` | integer | **OPTIONAL** |  |  |
| `sukanya_inr` | integer | **OPTIONAL** |  | ENGINE BLOCK if lock="NR" AND new |
| `tax_saving_fd_inr` | integer | **OPTIONAL** |  |  |
| `scss_inr` | integer | **OPTIONAL** |  | ENGINE BLOCK if lock="NR" AND new |
| `nps_additional_inr` | integer | **OPTIONAL** |  |  |
| `self_family_premium_inr` | integer | **OPTIONAL** |  |  |
| `parents_premium_inr` | integer | **OPTIONAL** |  |  |
| `parents_are_senior` | bool | **OPTIONAL** |  | bool — drives ₹25K vs ₹50K cap |
| `preventive_health_checkup_inr` | integer | **OPTIONAL** |  | sub-cap ₹5K within overall limit |
| `donee_name` | string | **OPTIONAL** |  |  |
| `pan_of_donee` | string | **OPTIONAL** |  |  |
| `amount_inr` | integer | **OPTIONAL** |  |  |
| `deduction_percent` | number | **OPTIONAL** |  | 50 ∣ 100 |
| `with_qualifying_limit` | bool | **OPTIONAL** |  | bool — drives 10% AGTI cap |
| `savings_interest_inr` | derived | **DERIVED** |  | DERIVED — sum of savings interest from bank_accounts. s.80TTA: ₹10K cap (non-senior). s.80TTB: ₹50K cap (senior, ROR/RNOR only). NRI: 80TTB BLOCKED. 80TTA available on NRO savings only. |
| `applicable_section` | derived | **DERIVED** |  | DERIVED ∣ "80TTA" ∣ "80TTB" ∣ null |
| `education_loan_interest_inr` | integer | **OPTIONAL** |  |  |
| `affordable_home_loan_interest_inr` | integer | **OPTIONAL** |  |  |
| `loan_sanction_date` | date | **OPTIONAL** |  | "YYYY-MM-DD" — eligibility window |


## Section 15: CARRY-FORWARD LOSSES (brought from prior FYs)

*Required for Schedule CYLA / BFLA / CFL assembly.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_brought_forward_losses` | bool | **REQUIRED** |  | bool — gate |
| `business_loss_cf` | array | **CONDITIONAL** |  | [{ "fy": "FY2022-23", "amount_inr": 250000 }, ...] 8-year CF. Offsets non-speculative business income only. |
| `speculative_loss_cf` | array | **CONDITIONAL** |  | 4-year CF. Offsets speculative income only. |
| `stcg_loss_cf` | array | **CONDITIONAL** |  | 8-year CF. Offsets STCG (any rate) and LTCG. |
| `ltcg_loss_cf` | array | **CONDITIONAL** |  | 8-year CF. Offsets LTCG only. |
| `house_property_loss_cf` | array | **CONDITIONAL** |  | 8-year CF. Offsets HP income only (current-year cap of ₹2L against other heads applies to current-year HP loss, not CF). |
| `unabsorbed_depreciation_cf` | integer | **OPTIONAL** |  | integer (INR). NO time limit. Offsets any head except salary. |


## Section 16: LRS OUTBOUND

*ENABLED IF: residency lock = "ROR"*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `total_lrs_remitted_this_fy_inr` | currency | **OPTIONAL** |  | number (INR). Annual limit USD 250K. TCS 20% on investment > ₹10L (w.e.f. 1 Apr 2026). |
| `lrs_purpose` | enum | **OPTIONAL** |  | "investment"∣"education_own_funds"∣"education_loan"∣"medical"∣"travel"∣"gift_donation" |
| `has_foreign_assets` | bool | **CONDITIONAL** |  | bool. true → Schedule FA mandatory. ₹10L/yr BMA s.43 penalty for non-disclosure. |
| `country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `nature_of_asset` | enum | **CONDITIONAL** |  | "bank"∣"equity"∣"property"∣"bond"∣"other" |
| `peak_balance_inr` | integer | **CONDITIONAL** |  |  |
| `closing_balance_inr` | integer | **CONDITIONAL** |  |  |
| `gross_interest_inr` | integer | **OPTIONAL** |  |  |
| `gross_proceeds_inr` | integer | **OPTIONAL** |  |  |
| `has_received_foreign_income` | bool | **CONDITIONAL** |  | bool. ENABLED IF has_foreign_assets = true true → Schedule FSI + FTC computation required. |


## Section 17: TAX CREDITS (advance tax, TDS, FTC)

*PROGRESSIVE | Collected throughout the year from Form 26AS / AIS*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `advance_tax_q1_15jun_inr` | integer | **OPTIONAL** |  | 15% cumulative threshold |
| `advance_tax_q2_15sep_inr` | integer | **OPTIONAL** |  | 45% cumulative threshold |
| `advance_tax_q3_15dec_inr` | integer | **OPTIONAL** |  | 75% cumulative threshold |
| `advance_tax_q4_15mar_inr` | integer | **OPTIONAL** |  | 100% cumulative threshold |
| `tds_already_deducted_inr` | integer | **OPTIONAL** |  | integer (INR). Source: Form 26AS / AIS. Reconciliation rule: credit = MAX(26AS, AIS) per deductor. |
| `form_26as_uploaded` | bool | **OPTIONAL** |  | bool |
| `country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `income_type` | enum | **OPTIONAL** |  | "salary"∣"interest"∣"dividend"∣"cg"∣"business"∣"other" |
| `foreign_income_in_foreign_ccy` | number | **CONDITIONAL** |  |  |
| `foreign_tax_in_foreign_ccy` | number | **CONDITIONAL** |  |  |
| `foreign_currency` | string | **CONDITIONAL** |  | ISO 4217 |
| `conversion_rate` | number | **CONDITIONAL** |  | SBI TT buying rate, last day of preceding month, per Rule 128. |
| `foreign_income_inr` | derived | **DERIVED** |  | DERIVED |
| `foreign_tax_inr` | derived | **DERIVED** |  | DERIVED |


## Section 18: SURCHARGE BUCKETS (DERIVED — Layer 2 contract)

*These are NEVER asked of the user. Engine populates them by re-bucketing every income field above into named buckets that the surcharge cap and marginal-relief logic can consume directly. CRITICAL: the surcharge cap rule treats CG/dividend at max 15% surcharge while normal income can hit 25% (above ₹2Cr) or 37% (above ₹5Cr, old regime). Marginal relief at the ₹2Cr / ₹5Cr boundary requires knowing exactly which rupees came from which bucket. Without these named outputs, the surcharge engine cannot be unit-tested.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `income_normal_slab_inr` | derived | **DERIVED** |  | DERIVED. Sum of: salary + house property + non-speculative business + slab-rate other_sources (interest, dividend, family pension net, buyback deemed dividend). |
| `income_stcg_111A_inr` | integer | **DERIVED** |  | DERIVED. STT-paid equity STCG @ 20%. |
| `income_ltcg_112A_inr` | integer | **DERIVED** |  | DERIVED. STT-paid equity LTCG @ 12.5% above ₹1.25L exemption. |
| `income_ltcg_112_inr` | derived | **DERIVED** |  | DERIVED. Property / unlisted / debt-MF-pre-Apr23 LTCG @ 12.5%. |
| `income_stcg_other_inr` | derived | **DERIVED** |  | DERIVED. Slab-rate STCG (debt MF post Apr 2023, etc.). |
| `income_dividend_inr` | derived | **DERIVED** |  | DERIVED. Standalone dividend bucket for surcharge cap visibility. |
| `income_special_115BB_115BBJ_inr` | integer | **DERIVED** |  | DERIVED. Lottery, gaming, online gaming — flat 30%. |
| `income_vda_115BBH_inr` | integer | **DERIVED** |  | DERIVED. Crypto / VDA — flat 30%, no set-off, no deductions. |
| `speculative_income_inr` | integer | **OPTIONAL** |  | DERIVED. Intraday — slab rate but ring-fenced for set-off purposes. |


## Section 19: METADATA

*Auto-populated by the system. No user input.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `financial_year` | derived | **DERIVED** |  | DERIVED e.g. "FY2025-26" |
| `request_id` | derived | **DERIVED** |  | DERIVED UUID |
| `source` | enum | **DERIVED** |  | "onboarding"∣"annual_update"∣"transaction_trigger"∣"ca_review" |
| `input_completeness` | enum | **DERIVED** |  | "provisional" ∣ "complete" |
| `cii_confirmed_for_fy` | bool | **DERIVED** |  | bool — flips to true once CBDT notifies CII for the FY. input_completeness cannot reach "complete" for indexation users until this is true. |
| `schema_version` | derived | **DERIVED** |  |  |
| `created_at` | derived | **DERIVED** |  | ISO 8601 |
| `last_updated_at` | derived | **DERIVED** |  |  |


# LAYER 1 US — SPECIALIST MODULE (v2.0)

Collects all US-specific tax data after Layer 0 routes the user to `us_only` or `dual`. This module is the single source of truth for US federal residency classification, worldwide-income computation (for USC/RA), 1040-NR computation (for NRA), AMT, NIIT, FEIE, FTC, state tax, and all US compliance reporting (FBAR, FATCA, PFIC, 5471, 3520).

**The US Residency Lock:** The very first thing this module does is run the SPT engine and write `us_residency_detail.final_us_residency_status`. This DERIVED field is the LOCK that gates every subsequent section.

**Lock values:** US_CITIZEN (worldwide, Form 1040) · RESIDENT_ALIEN (worldwide, 1040) · NON_RESIDENT_ALIEN (US-source ECI+FDAP only, 1040-NR) · DUAL_STATUS (split-year 1040 + 1040-NR)

**Source of truth:** WISING-TAX-US-002 v2.3 (OBBBA 2026 Update Edition). All thresholds per IRS Rev. Proc. 2025-32.

**Key OBBBA 2026 thresholds:** Standard deduction $16,100/$32,200/$24,150 · SALT cap $40,400 (phase-out >$500,500 MAGI; reverts $10K in 2030) · FEIE $132,900 · Senior deduction $6,000 (phase-out >$75K/$150K; expires 2028; NRA ineligible) · Estate $15M · QBI permanent · AMT phase-out reset to 2018 levels with doubled rate

**Scope containment:** US TAX LAW ONLY. India-side concerns live in layer1_india. For dual residents, the frontend Coordinator merges shared life events.

**Screen flow:** 3A (profile + residency → sets LOCK) → 3B (state) → 3C (US income) → 3D (foreign income, if RA/USC) → 3E (equity comp) → 3F (FEIE) → 3G (bank accounts) → 3H (financial holdings) → 3I (real estate) → 3J (retirement) → 3K (foreign entities) → 3L (foreign gifts) → 3M (deductions+credits) → 3N (AMT) → 3O (NIIT) → 3P (FTC) → 3Q (withholding) → 3R (NRA-specific)


## Section 1: PROFILE

*Screen 3A | Asked of all US users*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `date_of_birth` | date | **REQUIRED** |  | "YYYY-MM-DD" Drives: 65+ additional standard deduction, OBBBA $6,000 senior deduction (phase-out 6% of MAGI > $75K single / $150K MFJ; expires after 2028; NRAs ineligible). Drives RMD age (73 if born 1951-1959; 75 if born 1960+ per SECURE Act 2.0). |
| `filing_status` | enum | **REQUIRED** |  | "single" ∣ "mfj" ∣ "mfs" ∣ "hoh" ∣ "qss" Drives every bracket, deduction cap, and phase-out in the schema. NRA default: "single" or "mfs" (NRAs cannot file MFJ unless §6013(g)/(h) election made — see nra_specific block). |
| `ssn_or_itin` | string | **OPTIONAL** |  | string — SSN (NNN-NN-NNNN) or ITIN (9NN-NN-NNNN). ITIN holders apply via Form W-7 (US-002 §17, Fix #13). |
| `ssn_or_itin_type` | enum | **REQUIRED** |  | "ssn" ∣ "itin" ∣ "none" "none" → engine surfaces ITIN application requirement (Form W-7) before any 1040/1040-NR can be filed. |
| `dependents_count` | integer | **OPTIONAL** |  | integer — total dependents claimed. |
| `spouse_is_us_person` | bool | **CONDITIONAL** | filing_status IN ["mfj","mfs","hoh"] | bool Drives §6013(g)/(h) NRA-spouse election eligibility and CTC qualifying-child ITIN/SSN restrictions. |


## Section 2: US RESIDENCY DETAIL  +  THE LOCK

*Screen 3A continued | Asked of all US users Runs the SPT engine and writes the LOCK. Source: WISING-TAX-US-001 v1.1 (Residential Status)*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `is_us_citizen` | bool | **REQUIRED** |  | bool. Pre-filled from Layer 0 is_us_citizen. If true → final_us_residency_status = "US_CITIZEN"; SPT not evaluated; worldwide income taxed. |
| `has_green_card` | bool | **REQUIRED** |  | bool. Pre-filled from Layer 0 has_green_card. Unsurrendered Green Card (no Form I-407) → "RESIDENT_ALIEN" regardless of days. |
| `green_card_grant_date` | date | **CONDITIONAL** | has_green_card = true | "YYYY-MM-DD" Drives: residency start date (first day physically present in US after grant), covered-expatriate 8-year LTR test (US-002 §10.3), and dual-status year detection. |
| `i407_surrendered_date` | date | **CONDITIONAL** | has_green_card = true (historical) | "YYYY-MM-DD" ∣ nullable Drives the §877A expatriation tax cascade and Long-Term Resident determination. |
| `us_days_current_year` | integer | **REQUIRED** |  | integer (0–365) Pre-filled from Layer 0 us_days. Days physically present in CY 2026. |
| `us_days_minus_1_year` | integer | **REQUIRED** |  | integer (0–365) Days physically present in CY 2025. Counted at 1/3 weight for SPT. |
| `us_days_minus_2_years` | integer | **REQUIRED** |  | integer (0–365) Days physically present in CY 2024. Counted at 1/6 weight for SPT. |
| `exempt_individual_status` | enum | **REQUIRED** |  | "none" ∣ "f_student" ∣ "j_scholar" ∣ "g_diplomat" ∣ "professional_athlete" Days as an exempt individual do NOT count toward SPT. F/J students: typically exempt for first 5 calendar years. J scholars/teachers: typically exempt for 2 of last 6 calendar years. |
| `closer_connection_claim` | bool | **CONDITIONAL** | spt_test_met = true AND us_days_current_year < 183 | bool Triggers Form 8840 (Closer Connection Exception). Requires tax home and closer connection to a foreign country. |
| `first_year_choice_election` | bool | **OPTIONAL** |  | bool — §7701(b)(4) first-year choice for partial-year residency. |
| `s6013g_joint_election` | bool | **OPTIONAL** |  | bool — NRA spouse elects to be treated as RA for joint filing. |
| `spt_day_count_weighted` | currency | **DERIVED** |  | DERIVED ∣ number Formula: us_days_current_year + (us_days_minus_1_year / 3) + (us_days_minus_2_years / 6) Exempt-individual days are subtracted before the weighting. |
| `spt_test_met` | bool | **DERIVED** |  | DERIVED ∣ bool True iff: us_days_current_year >= 31 AND spt_day_count_weighted >= 183. |
| `final_us_residency_status` | derived | **DERIVED** |  | DERIVED ∣ "US_CITIZEN" ∣ "RESIDENT_ALIEN" ∣ "NON_RESIDENT_ALIEN" ∣ "DUAL_STATUS" THE LOCK. Computed immediately after the questions above. NEVER asked. Derivation cascade: 1. is_us_citizen = true                                         → "US_CITIZEN" 2. has_green_card = true AND no i407_surrendered_date this year → "RESIDENT_ALIEN" 3. spt_test_met = true AND closer_connection_claim != true      → "RESIDENT_ALIEN" 4. Mid-year arrival/departure with partial-year residency       → "DUAL_STATUS" (e.g., GC granted mid-year, first-year choice elected, or expatriation mid-year) 5. Else                                                         → "NON_RESIDENT_ALIEN" ALL DOWNSTREAM SECTION GATES READ THIS FIELD. The lock must be set before the frontend reveals any further screens. Income scope by lock: US_CITIZEN / RESIDENT_ALIEN → worldwide income (Form 1040) NON_RESIDENT_ALIEN          → US-source ECI + FDAP only (Form 1040-NR) DUAL_STATUS                 → split-year computation (1040 + 1040-NR statement) |
| `residency_start_date` | date | **DERIVED** |  | DERIVED ∣ "YYYY-MM-DD" ∣ nullable First day of US residency for the year. Used for dual-status splits. |
| `residency_end_date` | date | **DERIVED** |  | DERIVED ∣ "YYYY-MM-DD" ∣ nullable Last day of US residency for the year. Used for dual-status splits. |


## Section 3: STATE RESIDENCY (US-002 §12)

*Screen 3B | Asked of all US users*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `primary_state_of_residence` | string | **REQUIRED** |  | 2-letter US state code e.g. "CA" ∣ "NY" ∣ "TX" ∣ "FL" ∣ "WA" Drives the state tax computation. CA top rate 13.3% (>$1M), NY 10.9% + NYC 3.88%, TX/FL/WA/NV/SD/WY/AK/TN/NH 0% state tax. |
| `moved_states_this_year` | bool | **REQUIRED** |  | bool true → part-year resident return required in BOTH states. |
| `previous_state` | string | **CONDITIONAL** | moved_states_this_year = true | 2-letter US state code. |
| `move_date` | date | **CONDITIONAL** | moved_states_this_year = true | "YYYY-MM-DD" |
| `state_days_in_current_state` | integer | **CONDITIONAL** | moved_states_this_year = true | integer Drives part-year apportionment. |
| `ca_planning_departure` | bool | **CONDITIONAL** | primary_state_of_residence = "CA" OR previous_state = "CA" | bool CA aggressively pursues departing residents under the FTB "safe harbor" rules. Triggers domicile-exit planning workflow. |
| `ca_safe_harbor_employment_contract` | bool | **CONDITIONAL** | ca_planning_departure = true | bool 546-day employment-abroad safe harbor (CA R&TC §17014(d)). |
| `ca_retains_property_or_voter_reg` | bool | **CONDITIONAL** | ca_planning_departure = true | bool Strong domicile-retention indicator; FTB will likely contest non-residency. |
| `ny_183_day_rule_met` | bool | **CONDITIONAL** | primary_state_of_residence = "NY" OR previous_state = "NY" | bool NY statutory residency: domicile elsewhere + permanent place of abode in NY + 183+ NY days = NY resident regardless of intent. |
| `ny_permanent_place_of_abode` | bool | **CONDITIONAL** | primary_state_of_residence = "NY" OR previous_state = "NY" | bool |


## Section 4: US-SOURCE INCOME (Income Item Schema per US-002 §0A)

*Screen 3C | Asked of all US users Every income row carries source_country and income_type so the FTC basket engine and DTAA engine can route without hardcoded country logic.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `employer_name` | string | **OPTIONAL** |  |  |
| `employer_ein` | string | **OPTIONAL** |  |  |
| `wages_box1_usd` | string | **CONDITIONAL** |  | Box 1 federal wages |
| `federal_tax_withheld_usd` | string | **CONDITIONAL** |  | Box 2 |
| `ss_wages_box3_usd` | string | **OPTIONAL** |  | Box 3 |
| `ss_tax_withheld_usd` | string | **OPTIONAL** |  | Box 4 |
| `medicare_wages_box5_usd` | string | **OPTIONAL** |  | Box 5 |
| `medicare_tax_withheld_usd` | string | **OPTIONAL** |  | Box 6 |
| `state_wages_box16_usd` | string | **OPTIONAL** |  |  |
| `state_tax_withheld_box17_usd` | string | **OPTIONAL** |  |  |
| `is_statutory_employee` | bool | **OPTIONAL** |  |  |
| `has_se_income` | bool | **REQUIRED** |  |  |
| `gross_receipts_usd` | string | **CONDITIONAL** |  |  |
| `expenses_usd` | string | **CONDITIONAL** |  |  |
| `qbi_eligible` | bool | **OPTIONAL** |  | bool — §199A pass-through deduction (made permanent by OBBBA). 2026 phase-out: $201,775 single / $403,500 MFJ; SSTBs face full phase-out. |
| `is_specified_service_trade` | bool | **OPTIONAL** |  | bool — consulting, financial services, health, law, etc. (SSTB) |
| `interest_us_source_usd` | string | **OPTIONAL** |  |  |
| `ordinary_dividends_us_source_usd` | string | **OPTIONAL** |  |  |
| `qualified_dividends_us_source_usd` | string | **OPTIONAL** |  | Subset of ordinary dividends taxed at LTCG rates (held > 60 days). |
| `stcg_us_source_usd` | string | **OPTIONAL** |  | Short-term capital gains (held ≤ 1 year). Taxed at ordinary rates. |
| `ltcg_us_source_usd` | string | **OPTIONAL** |  | Long-term capital gains (held > 1 year). 0%/15%/20% rates. |
| `rental_income_us_source_usd` | string | **OPTIONAL** |  |  |
| `royalty_income_us_source_usd` | string | **OPTIONAL** |  |  |
| `k1_passthrough_income_usd` | string | **OPTIONAL** |  |  |
| `ira_distributions_usd` | string | **OPTIONAL** |  |  |
| `401k_distributions_usd` | string | **OPTIONAL** |  |  |
| `social_security_benefits_usd` | string | **OPTIONAL** |  | Up to 85% taxable depending on combined income (US-002 §16.2). |
| `asset` | string | **OPTIONAL** |  | e.g. "BTC" ∣ "ETH" |
| `acquisition_date` | date | **CONDITIONAL** |  |  |
| `disposal_date` | date | **CONDITIONAL** |  |  |
| `proceeds_usd` | string | **CONDITIONAL** |  |  |
| `cost_basis_usd` | string | **CONDITIONAL** |  |  |
| `is_long_term` | bool | **CONDITIONAL** |  |  |


## Section 5: FOREIGN-SOURCE INCOME (US-002 §2)

*Screen 3D | ENABLED IF: lock IN ["US_CITIZEN","RESIDENT_ALIEN","DUAL_STATUS"] NRAs do NOT report worldwide income — block hidden for NRA lock.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `source_country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 e.g. "IN" |
| `employer_name` | string | **OPTIONAL** |  |  |
| `gross_wages_local_ccy` | number | **CONDITIONAL** |  |  |
| `local_currency` | string | **CONDITIONAL** |  | ISO 4217 |
| `gross_wages_usd` | derived | **DERIVED** |  | DERIVED via §988 conversion |
| `foreign_tax_withheld_local_ccy` | number | **CONDITIONAL** |  |  |
| `foreign_tax_withheld_usd` | derived | **DERIVED** |  | DERIVED — feeds FTC |
| `foreign_interest_usd` | string | **OPTIONAL** |  | Includes NRO/NRE interest. NRE interest is India-exempt but US-taxable for USC/RA. Engine flags NRE_INDIA_EXEMPT_US_TAXABLE. |
| `foreign_dividends_usd` | string | **OPTIONAL** |  | Indian dividends: 25% India TDS (DTAA Art. 10) → FTC passive basket. |
| `foreign_stcg_usd` | string | **OPTIONAL** |  |  |
| `foreign_ltcg_usd` | string | **OPTIONAL** |  | Indian property CG: India taxes first (DTAA Art. 13) → FTC general basket. §54 trap: India CG exempt via reinvestment = zero India tax = zero FTC. Engine flags §54_INDIA_EXEMPT_US_TAXABLE on every Indian property sale with §54 reinvestment claimed in layer1_india. |
| `foreign_rental_income_usd` | string | **OPTIONAL** |  |  |
| `foreign_pension_income_usd` | string | **OPTIONAL** |  | Indian EPF/PPF distributions: complex US treatment. PPF treated as foreign grantor trust by some practitioners; engine surfaces CA-review flag. |
| `transaction_date` | date | **OPTIONAL** |  |  |
| `amount_local_ccy` | number | **OPTIONAL** |  |  |
| `local_currency` | string | **CONDITIONAL** |  |  |
| `rate_at_receipt` | string | **OPTIONAL** |  |  |
| `rate_at_conversion` | string | **OPTIONAL** |  |  |
| `gain_or_loss_usd` | derived | **DERIVED** |  | DERIVED — ordinary income/loss |


## Section 6: EQUITY COMPENSATION (US-002 §13, §4A)

*Screen 3E | Heavy AMT/ISO focus for tech employees.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_equity_comp` | bool | **REQUIRED** |  | bool — gate |
| `company_name` | string | **OPTIONAL** |  |  |
| `grant_date` | date | **CONDITIONAL** |  |  |
| `exercise_date` | date | **CONDITIONAL** |  |  |
| `number_of_shares` | number | **CONDITIONAL** |  |  |
| `exercise_price` | string | **CONDITIONAL** |  | per share, USD |
| `fmv_on_exercise_date` | date | **CONDITIONAL** |  | PER SHARE, USD. CRITICAL — drives the AMT preference item: AMT spread = (fmv_on_exercise_date − exercise_price) × number_of_shares. No regular tax at exercise; AMT-only. At 28% AMT rate, a $900K spread generates ~$250K AMT on cash the user has not received. |
| `shares_sold_same_year` | integer | **OPTIONAL** |  | integer — disqualifying disposition |
| `sale_date` | date | **CONDITIONAL** |  |  |
| `sale_price_per_share` | number | **CONDITIONAL** |  |  |
| `amt_preference_inr` | derived | **DERIVED** |  | DERIVED ∣ USD — feeds amt_inputs.iso_preference_total_usd |
| `company_name` | string | **OPTIONAL** |  |  |
| `exercise_date` | date | **CONDITIONAL** |  |  |
| `number_of_shares` | number | **CONDITIONAL** |  |  |
| `exercise_price` | string | **CONDITIONAL** |  |  |
| `fmv_on_exercise_date` | date | **CONDITIONAL** |  |  |
| `ordinary_income_at_exercise_usd` | derived | **DERIVED** |  | DERIVED — taxed as W-2 wages |
| `company_name` | string | **OPTIONAL** |  |  |
| `vest_date` | date | **CONDITIONAL** |  |  |
| `shares_vested` | string | **CONDITIONAL** |  |  |
| `fmv_on_vest_date` | date | **CONDITIONAL** |  |  |
| `ordinary_income_at_vest_usd` | derived | **DERIVED** |  | DERIVED — taxed as W-2 wages |
| `shares_withheld_for_tax` | string | **OPTIONAL** |  |  |
| `company_name` | string | **OPTIONAL** |  |  |
| `purchase_date` | date | **CONDITIONAL** |  |  |
| `shares_purchased` | string | **CONDITIONAL** |  |  |
| `purchase_price` | string | **CONDITIONAL** |  |  |
| `fmv_on_purchase_date` | date | **CONDITIONAL** |  |  |
| `fmv_on_offering_date` | date | **CONDITIONAL** |  | for qualifying disposition test |
| `is_qualifying_disposition` | bool | **CONDITIONAL** |  |  |
| `company_name` | string | **OPTIONAL** |  |  |
| `grant_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" |
| `number_of_unvested_shares` | integer | **CONDITIONAL** |  | integer |
| `fmv_at_grant_per_share_usd` | string | **CONDITIONAL** |  | Used to compute the §83(b) inclusion amount = shares × (fmv − price paid). |
| `price_paid_per_share_usd` | string | **CONDITIONAL** |  | often $0 for founder stock |
| `section_83b_election_filed_within_30_days` | bool | **CONDITIONAL** |  | bool CRITICAL: 30-day deadline from THIS grant_date is HARD — no exceptions, no late-filing relief. Filed with IRS service center + copy to employer. Election fixes ordinary income at grant FMV and starts LTCG holding period immediately, but is forfeited if shares are later forfeited (no refund). |
| `section_83b_filing_date` | date | **CONDITIONAL** | section_83b_election_filed_within_30_days = true | "YYYY-MM-DD" |
| `section_83b_inclusion_amount_usd` | derived | **DERIVED** |  | DERIVED ∣ USD = number_of_unvested_shares × (fmv_at_grant − price_paid) Reported as ordinary W-2 wages in the year of election. |
| `vesting_schedule_summary` | string | **OPTIONAL** |  | string — free text for audit trail e.g. "4yr / 1yr cliff / monthly" |


## Section 7: FOREIGN EARNED INCOME EXCLUSION (US-002 §4)

*Screen 3F | ENABLED IF: lock IN ["US_CITIZEN","RESIDENT_ALIEN"] AND claims_feie = true Primary tool for US expats living and working in India (US-002 §4.3).*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `claims_feie` | bool | **OPTIONAL** |  | bool — gate. Form 2555. |
| `qualification_test` | enum | **CONDITIONAL** |  | "physical_presence" ∣ "bona_fide_residence" Physical Presence: 330 full days in any 12-month period. Bona Fide Residence: full tax year as bona fide resident of foreign country. |
| `tax_home_country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `physical_presence_start_date` | date | **CONDITIONAL** |  | ENABLED IF qualification_test = "physical_presence" |
| `physical_presence_end_date` | date | **CONDITIONAL** |  |  |
| `days_in_us_during_test_period` | string | **CONDITIONAL** |  | must be ≤ 35 (i.e., 330+ abroad) |
| `bona_fide_residence_start_date` | date | **CONDITIONAL** |  | ENABLED IF qualification_test = "bona_fide_residence" |
| `foreign_earned_income_usd` | string | **CONDITIONAL** |  | Wages/SE income earned while tax home is abroad. Capped at FEIE limit: OBBBA 2026 → $132,900 per qualifying taxpayer. |
| `feie_amount_claimed_usd` | derived | **DERIVED** |  | DERIVED ∣ USD = MIN(foreign_earned_income_usd, $132,900, days_qualifying / 365 × $132,900) |
| `foreign_housing_expenses_usd` | string | **OPTIONAL** |  | Rent, utilities (excl. telephone), real/personal property insurance, residential parking, repairs. |
| `housing_exclusion_base_usd` | derived | **DERIVED** |  | DERIVED ∣ 16% of FEIE limit = $21,264 for 2026. |
| `housing_exclusion_cap_usd` | derived | **DERIVED** |  | DERIVED ∣ 30% of FEIE limit = $39,870 (location-adjusted upward for high-cost cities per IRS Notice). |
| `foreign_housing_exclusion_usd` | derived | **DERIVED** |  | DERIVED ∣ MAX(0, MIN(foreign_housing_expenses − base, cap − base)) |


## Section 8: BANK ACCOUNTS (US-002 §6.1, §6.2)

*Screen 3G | FBAR + Form 8938 driver For dual residents, this complements (does NOT duplicate) the layer1_india.bank_accounts block. India captures NRO/NRE/FCNR detail; here we capture the USD peak/end balances the IRS needs.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `bank_name` | string | **OPTIONAL** |  |  |
| `country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `is_us_account` | bool | **REQUIRED** |  | bool |
| `account_type` | enum | **REQUIRED** |  | "checking" ∣ "savings" ∣ "money_market" ∣ "cd" ∣ "brokerage_cash" ∣ "nro" ∣ "nre" ∣ "fcnr" ∣ "rfc" |
| `account_number_last_4` | string | **OPTIONAL** |  | string |
| `is_jointly_held` | bool | **OPTIONAL** |  | bool — affects FBAR aggregation |
| `is_signature_authority_only` | bool | **OPTIONAL** |  | bool — still triggers FBAR |
| `peak_balance_during_cy_usd` | string | **REQUIRED** |  | CRITICAL ∣ USD Highest balance at any point during the calendar year, converted to USD at the Treasury year-end rate (or transaction-date rate, taxpayer's choice applied consistently). Drives FBAR (FinCEN 114) reporting. FBAR threshold: aggregate foreign account peak > $10,000 at ANY point in CY. FBAR penalty: non-willful up to $10K/account/year; willful up to greater of $100K or 50% of account value. |
| `peak_balance_date` | date | **OPTIONAL** |  | "YYYY-MM-DD" |
| `cy_end_balance_usd` | string | **REQUIRED** |  | CRITICAL ∣ USD — closing balance on 31 Dec converted at year-end Treasury rate. Form 8938 thresholds (US-resident): MFJ $100K end / $150K peak; foreign-resident MFJ: $400K end / $600K peak. |
| `interest_credited_cy_usd` | string | **OPTIONAL** |  | Annual interest credited. Routes to income_us_source.interest_us_source_usd if is_us_account, else to income_foreign_source.foreign_interest_usd. |
| `tax_withheld_cy_usd` | string | **OPTIONAL** |  | Foreign withholding tax (e.g., 30% NRO TDS). Routes to FTC passive basket. |
| `w8ben_filed_with_this_payor` | bool | **CONDITIONAL** |  | bool |
| `w8ben_signature_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" |
| `w8ben_expiry_date` | date | **DERIVED** |  | "YYYY-MM-DD" — DERIVED if signature_date is set: signature_date + 3 years, expiring on 31 Dec of the third year. Engine fires expiry alert 60 days before. |
| `treaty_country_claimed_with_this_payor` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `fbar_aggregate_peak_usd` | derived | **DERIVED** |  | DERIVED ∣ USD — sum of peak_balance_during_cy_usd across foreign accounts. > $10,000 → FinCEN 114 mandatory. |
| `form_8938_required` | bool | **DERIVED** |  | DERIVED ∣ bool — applies the resident/foreign-resident threshold matrix against fbar_aggregate_peak_usd, cy_end totals, and filing_status. |


## Section 9: FINANCIAL HOLDINGS (PFIC, foreign brokerage)

*Screen 3H | US-002 §6.3, §7*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `asset_name_or_ticker` | string | **OPTIONAL** |  |  |
| `isin` | string | **OPTIONAL** |  |  |
| `country_of_issuer` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `broker_name` | string | **OPTIONAL** |  | string e.g. "Schwab" ∣ "Fidelity" ∣ "IBKR" ∣ "Zerodha" CRITICAL for W-8BEN tracking: holdings at the same broker share the same W-8BEN. Holdings at different brokers need separate W-8BENs. Engine groups by broker_name for the per-payor W-8BEN status check below. |
| `asset_class` | enum | **CONDITIONAL** |  | "us_listed_equity" ∣ "us_etf" ∣ "us_mutual_fund" ∣ "us_bond" ∣ "foreign_listed_equity" ∣ "foreign_mutual_fund" ∣ "foreign_etf" ∣ "foreign_bond" ∣ "reit" ∣ "crypto" |
| `quantity` | number | **CONDITIONAL** |  |  |
| `acquisition_date` | date | **CONDITIONAL** |  |  |
| `cost_basis_usd` | string | **CONDITIONAL** |  |  |
| `current_market_value_usd` | string | **OPTIONAL** |  |  |
| `peak_balance_during_cy_usd` | string | **REQUIRED** |  |  |
| `cy_end_balance_usd` | string | **REQUIRED** |  |  |
| `is_pfic` | bool | **REQUIRED** |  | bool CRITICAL: virtually every Indian mutual fund, ETF, FoF, ULIP, and Indian-domiciled hedge fund is a PFIC under §1297. The default §1291 regime applies the highest ordinary rate to "excess distributions" plus interest charge, with NO loss recognition. Most commonly missed obligation for NRIs. |
| `pfic_election` | enum | **CONDITIONAL** | is_pfic = true | "1291_default" ∣ "mark_to_market" ∣ "qef" 1291_default → punitive: excess distributions taxed at top rate + interest charge; gain on sale always ordinary income. mark_to_market → §1296 election; annual mark-to-market gain/loss as ordinary income; available for marketable PFICs only. qef           → §1295 election; flow-through of ordinary earnings and net capital gain; requires Annual Information Statement from the fund (rare for Indian MFs — most do not provide). |
| `pfic_election_first_year` | string | **CONDITIONAL** |  | tax year of first election |
| `form_8621_filed_prior_years` | bool | **OPTIONAL** |  | bool — prior reporting history |
| `sale_date` | date | **CONDITIONAL** |  |  |
| `sale_proceeds_usd` | string | **CONDITIONAL** |  |  |
| `is_long_term` | bool | **CONDITIONAL** |  | bool — held > 1 year |
| `wash_sale_disallowed_loss_usd` | string | **OPTIONAL** |  | §1091 wash sale: 30-day window before/after sale; disallows loss on repurchase of substantially identical security. Applies to all securities including foreign stock; does NOT currently apply to crypto. |
| `w8ben_filed_with_this_broker` | bool | **CONDITIONAL** |  | bool |
| `w8ben_signature_date` | date | **CONDITIONAL** |  | "YYYY-MM-DD" |
| `w8ben_expiry_date` | date | **DERIVED** |  | "YYYY-MM-DD" — DERIVED if signature_date is set: signature_date + 3 years, expiring on 31 Dec of the third year. Engine fires expiry alert 60 days before. |
| `treaty_country_claimed_with_this_broker` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |


## Section 10: REAL ESTATE (US-002 §9)

*Screen 3I For dual residents, the property sale itself is captured in layer1_india.property; here we capture the US-side cost basis and §121 / §1031 fields.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `has_real_estate_transaction` | bool | **REQUIRED** |  | bool — gate |
| `country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `property_type` | enum | **CONDITIONAL** |  | "primary_residence" ∣ "rental" ∣ "vacation" ∣ "investment" ∣ "land" |
| `address` | string | **OPTIONAL** |  |  |
| `acquisition_date` | date | **CONDITIONAL** |  |  |
| `us_cost_basis_usd` | string | **CONDITIONAL** |  | CRITICAL: this is the US §1012 cost basis, NOT the India indexed cost. For inherited property: §1014 step-up to FMV at date of death applies (the schema captures this; cross-engine reconciliation is the Coordinator's job). |
| `improvements_capitalized_usd` | string | **OPTIONAL** |  |  |
| `depreciation_taken_usd` | string | **OPTIONAL** |  | for rental — §1250 recapture |
| `sale_date` | date | **CONDITIONAL** |  |  |
| `sale_proceeds_usd` | string | **CONDITIONAL** |  |  |
| `selling_expenses_usd` | string | **OPTIONAL** |  |  |
| `section_121_eligible` | bool | **CONDITIONAL** |  | bool — owned + used as primary 2 of last 5 years. |
| `section_121_exclusion_claimed_usd` | string | **CONDITIONAL** |  | Up to $250K single / $500K MFJ. |
| `section_1031_exchange` | bool | **CONDITIONAL** |  | bool. CRITICAL: §1031 does NOT apply to foreign property — cannot be used to defer Indian property gains (US-002 §9.1). |
| `section_54_india_exempt_us_taxable` | bool | **DERIVED** |  | DERIVED ∣ bool True when country = "IN" AND layer1_india flagged this property with reinvestment_exemption_claimed IN ["s54","s54f"]. Surfaces the §54 trap: zero India tax = zero FTC = full US tax on the gain. |
| `fmv_at_inheritance_usd` | string | **CONDITIONAL** | acquired by inheritance | §1014 step-up basis (US side only). India side uses original owner cost. |


## Section 11: RETIREMENT ACCOUNTS (US-002 §8)

*Screen 3J*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `traditional_ira_contribution_usd` | string | **OPTIONAL** |  |  |
| `roth_ira_contribution_usd` | string | **OPTIONAL** |  | 2026 phase-out: $165K single / $246K MFJ. Above → backdoor Roth route. |
| `backdoor_roth_executed` | bool | **OPTIONAL** |  | bool — pro-rata rule trap |
| `401k_employee_contribution_usd` | string | **OPTIONAL** |  |  |
| `401k_employer_match_usd` | string | **OPTIONAL** |  |  |
| `roth_401k_contribution_usd` | string | **OPTIONAL** |  | No RMD starting 2024 (SECURE 2.0) |
| `hsa_contribution_usd` | string | **OPTIONAL** |  | Triple tax advantage. 2026 limits per IRS Rev. Proc. 2025-32. Self-only HDHP coverage / Family coverage limits apply. |
| `solo_401k_contribution_usd` | string | **OPTIONAL** |  | self-employed |
| `sep_ira_contribution_usd` | string | **OPTIONAL** |  | self-employed |
| `rmd_required` | derived | **DERIVED** |  | DERIVED — based on DOB + SECURE 2.0 |
| `rmd_amount_usd` | derived | **DERIVED** |  | DERIVED |
| `indian_epf_balance_usd` | string | **OPTIONAL** |  | EPF: not US-tax-deferred. Employer contributions = current W-2 income for USC/RA. Engine flags EPF_NO_US_DEFERRAL. |
| `indian_ppf_balance_usd` | string | **OPTIONAL** |  | PPF: arguably foreign grantor trust. Forms 3520 + 3520-A may be required. Engine surfaces PPF_GRANTOR_TRUST_REVIEW for CA sign-off. |
| `indian_nps_balance_usd` | string | **OPTIONAL** |  | NPS: similar foreign-pension complications. |


## Section 12: FOREIGN ENTITIES (US-002 §6.4)

*Screen 3K | Forms 5471, 8865 — heavy compliance penalties*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `owns_10_percent_foreign_corp` | bool | **REQUIRED** |  | bool — gate ≥10% ownership (vote or value) of a foreign corporation triggers Form 5471. For CFCs (>50% US-owned), §951A NCTI inclusion applies to USC/RA shareholders regardless of distribution. Per OBBBA (effective CFC tax years beginning after 31 Dec 2025): GILTI renamed NCTI; QBAI carve-out repealed; §250 deduction dropped to 40%; indirect FTC haircut reduced to 10%. |
| `corp_name` | string | **CONDITIONAL** |  |  |
| `country_of_incorporation` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `ownership_percent` | decimal | **CONDITIONAL** |  | decimal e.g. 0.60 |
| `is_cfc` | bool | **CONDITIONAL** |  | bool — >50% US-owned |
| `is_pfic_corp` | bool | **CONDITIONAL** |  | bool — PFIC at corp level |
| `category_5471` | enum | **CONDITIONAL** |  | "category_1" ∣ "category_2" ∣ "category_3" ∣ "category_4" ∣ "category_5" Determines which Form 5471 schedules are required. |
| `cfc_tax_year_start` | date | **CONDITIONAL** |  | "YYYY-MM-DD" CRITICAL for OBBBA transition: a CFC whose tax year started before 1 Jan 2026 still applies pre-OBBBA GILTI rules for that year. Indian Pvt Ltd FY (Apr–Mar) means FY 2025-26 is still on old GILTI; FY 2026-27 flips to NCTI. |
| `tested_income_usd` | string | **CONDITIONAL** |  | for GILTI/NCTI inclusion |
| `tested_loss_usd` | string | **OPTIONAL** |  |  |
| `subpart_f_income_usd` | string | **OPTIONAL** |  |  |
| `section_962_election_made` | bool | **OPTIONAL** |  | bool — per-year strategic election. Enables 40% §250 deduction and 90% indirect FTC at the cost of future-distribution taxation. |
| `high_tax_exception_elected` | bool | **OPTIONAL** |  | bool — §951A(c)(2)(A)(i)(III). Country-by-country annual election that pulls income out of NCTI if foreign ETR ≥ 18.9% (90% of 21% US corp rate). Indian Pvt Ltds at 25.17% qualify cleanly. |
| `ptep_pool_pre_jun28_2025_usd` | string | **OPTIONAL** |  | Previously-Taxed E&P — pre-OBBBA pool (20% FTC haircut on distribution). |
| `ptep_pool_post_jun28_2025_usd` | string | **OPTIONAL** |  | Previously-Taxed E&P — post-OBBBA pool (10% FTC haircut on distribution). |
| `owns_10_percent_foreign_partnership` | bool | **REQUIRED** |  | bool — gate ≥10% interest in a foreign partnership triggers Form 8865. |
| `partnership_name` | string | **CONDITIONAL** |  |  |
| `country` | string | **CONDITIONAL** |  |  |
| `ownership_percent` | number | **CONDITIONAL** |  |  |
| `category_8865` | enum | **CONDITIONAL** |  | "category_1" ∣ "category_2" ∣ "category_3" ∣ "category_4" |
| `k1_income_usd` | string | **CONDITIONAL** |  |  |
| `owns_foreign_disregarded_entity` | bool | **REQUIRED** |  | bool — Form 8858 |
| `foreign_de_details` | array | **CONDITIONAL** |  |  |


## Section 13: FOREIGN GIFTS & TRUSTS (US-002 §10, §6.4)

*Screen 3L | Form 3520 / 3520-A*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `received_foreign_gifts_above_100k` | bool | **REQUIRED** |  | bool — gate Form 3520 trigger: aggregate gifts from a foreign individual > $100,000 in the calendar year. From foreign corporations/partnerships: > $19,570 (2026, indexed). Penalty: 5% per month, max 25% of gift value. Practical: Indian parents gifting cash or Indian assets to a US child face NO US gift tax (NR alien donor of non-US-situs property), but the recipient must still file Form 3520 above the threshold. |
| `donor_name` | string | **CONDITIONAL** |  |  |
| `donor_relationship` | enum | **OPTIONAL** |  | "parent" ∣ "spouse" ∣ "other" |
| `donor_country` | string | **CONDITIONAL** |  |  |
| `gift_date` | date | **CONDITIONAL** |  |  |
| `gift_value_usd` | string | **CONDITIONAL** |  |  |
| `gift_type` | enum | **OPTIONAL** |  | "cash" ∣ "real_property" ∣ "securities" ∣ "other" |
| `is_us_beneficiary_of_foreign_trust` | bool | **REQUIRED** |  | bool. Triggers Form 3520 (distributions) + Form 3520-A (annual info). |
| `foreign_trust_details` | array | **CONDITIONAL** |  |  |
| `received_gift_from_covered_expatriate` | bool | **OPTIONAL** |  | bool. CRITICAL: US RECIPIENT pays 40% on gifts/bequests from covered expatriates — indefinitely after expatriation. Engine surfaces alert. |


## Section 14: ITEMIZED DEDUCTIONS & CREDITS (US-002 §3A)

*Screen 3M | OBBBA 2026 thresholds*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `use_standard_or_itemized` | enum | **OPTIONAL** |  | "standard" ∣ "itemized" ∣ "auto" Engine auto-selects whichever is larger if "auto". OBBBA 2026 standard deduction: Single $16,100 / MFJ $32,200 / HoH $24,150. 65+ adds OBBBA $6,000 senior deduction (phased out, NRA-ineligible). |
| `state_and_local_taxes_paid_usd` | string | **OPTIONAL** |  | SALT cap raised by OBBBA from $10,000 to $40,400 for 2026. Phase-out begins above $500,500 MAGI; reverts to $10,000 in 2030. |
| `mortgage_interest_paid_usd` | string | **OPTIONAL** |  | Cap: interest on $750K of acquisition debt (post-Dec 2017 mortgages). Pre-Dec 2017: grandfathered $1M cap. |
| `mortgage_acquisition_date` | date | **CONDITIONAL** |  | determines $750K vs $1M cap |
| `charitable_contributions_cash_usd` | string | **OPTIONAL** |  | 60% of AGI cap for cash to public charities. |
| `charitable_contributions_appreciated_usd` | string | **OPTIONAL** |  | 30% of AGI cap for appreciated property. |
| `medical_expenses_usd` | string | **OPTIONAL** |  | Deductible above 7.5% of AGI threshold. |
| `casualty_loss_federal_disaster_usd` | string | **OPTIONAL** |  |  |
| `hsa_contributions_usd` | string | **OPTIONAL** |  | Above-the-line; mirrors retirement_accounts.hsa_contribution_usd for deduction line vs contribution tracking. |
| `student_loan_interest_usd` | string | **OPTIONAL** |  | up to $2,500, phase-out applies |
| `educator_expenses_usd` | string | **OPTIONAL** |  | up to $300 |
| `child_tax_credit_dependents` | integer | **OPTIONAL** |  | integer — qualifying children under 17 with SSN. OBBBA: CTC retained at $2,000/child (non-refundable + $1,700 refundable ACTC portion). Phase-out: $200K single / $400K MFJ. |
| `credit_for_other_dependents` | string | **OPTIONAL** |  | $500 non-refundable |
| `child_and_dependent_care_expenses_usd` | string | **OPTIONAL** |  |  |
| `education_credits_aotc_usd` | string | **OPTIONAL** |  | American Opportunity, $2,500 max |
| `education_credits_llc_usd` | string | **OPTIONAL** |  | Lifetime Learning, $2,000 max |
| `saver_credit_eligible` | bool | **OPTIONAL** |  | bool — low/middle income |
| `funded_529_plan` | bool | **OPTIONAL** |  | bool — gate |
| `529_contributions_usd` | string | **CONDITIONAL** |  |  |
| `529_state_deduction_state` | string | **CONDITIONAL** |  | 2-letter state — many states allow state-level deduction (NY $5K/$10K MFJ, VA $4K, IL $10K/$20K MFJ, etc.). No federal deduction. |
| `qbi_deduction_eligible` | derived | **DERIVED** |  | DERIVED from self_employment |
| `qbi_deduction_usd` | derived | **DERIVED** |  | DERIVED |


## Section 15: ALTERNATIVE MINIMUM TAX INPUTS (US-002 §4A)

*Screen 3N | Mostly DERIVED — most rows pulled from equity_compensation and itemized_deductions blocks. Surfaced here for the AMT engine contract.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `iso_preference_total_usd` | derived | **DERIVED** |  | DERIVED ∣ sum of equity_compensation.iso_exercises[].amt_preference_inr. The single biggest AMT trigger for tech employees. |
| `salt_addback_usd` | derived | **DERIVED** |  | DERIVED ∣ state_and_local_taxes_paid_usd (added back for AMT). |
| `private_activity_bond_interest_usd` | string | **OPTIONAL** |  | Tax-exempt for regular tax; AMT preference item. |
| `amt_exemption_usd` | derived | **DERIVED** |  | DERIVED ∣ OBBBA 2026: phase-out threshold reset to 2018 levels with doubled phase-out rate. Engine reads OBBBA threshold table. |
| `amti_usd` | derived | **DERIVED** |  | DERIVED — Alternative Minimum Taxable Income |
| `tentative_minimum_tax_usd` | derived | **DERIVED** |  | DERIVED |
| `amt_due_usd` | derived | **DERIVED** |  | DERIVED — MAX(0, TMT − regular tax) |
| `minimum_tax_credit_carryforward_usd` | string | **OPTIONAL** |  | From prior years. Offsets future regular tax when regular > AMT. |


## Section 16: NET INVESTMENT INCOME TAX (US-002 §3)

*Screen 3O | DERIVED only*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `modified_agi_usd` | derived | **DERIVED** |  | DERIVED |
| `niit_threshold_usd` | derived | **DERIVED** |  | DERIVED ∣ $200K single / $250K MFJ / $125K MFS. Not indexed for inflation. |
| `net_investment_income_usd` | derived | **DERIVED** |  | DERIVED ∣ interest + dividends + cg + rental + royalty − allocable expenses. Excludes wages, SE income, retirement distributions, active business income. |
| `niit_due_usd` | derived | **DERIVED** |  | DERIVED ∣ 3.8% × MIN(net_investment_income_usd, MAGI − threshold). NRAs EXEMPT. No FTC offset against NIIT. |


## Section 17: FOREIGN TAX CREDIT (US-002 §5)

*Screen 3P | ENABLED IF foreign-source income exists Form 1116 — per-basket limitation under §904.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `claims_ftc` | bool | **OPTIONAL** |  | bool — Form 1116 |
| `claims_ftc_simplified_under_300` | bool | **OPTIONAL** |  | bool — § election for ≤ $300 ($600 MFJ) of foreign tax, all passive, reported on 1099-DIV/INT. Skip Form 1116 entirely. |
| `basket` | enum | **CONDITIONAL** |  | "passive" ∣ "general" ∣ "global_intangible_low_taxed_income" ∣ "foreign_branch" ∣ "treaty_resourced" Engine assigns basket from income_type per US-002 §0A.3. |
| `source_country` | string | **CONDITIONAL** |  | ISO 3166-1 alpha-2 |
| `foreign_source_income_usd` | string | **CONDITIONAL** |  |  |
| `foreign_taxes_paid_usd` | string | **CONDITIONAL** |  | CRITICAL UI HINT: the frontend MUST explicitly prompt the user to include INDIAN SURCHARGE and HEALTH & EDUCATION CESS in this total, not just the base TDS line shown on Form 26AS. Surcharge (10%/15%/ 25%/37% slab on tax) and cess (4% on tax + surcharge) are creditable foreign taxes under §901 — but ~70% of NRI users typing this field look at the base TDS column on 26AS and miss the add-ons, leaving material FTC unclaimed. Suggested microcopy: "Enter the TOTAL Indian tax for this income — base tax + surcharge + 4% Health & Education Cess. Check the 'Total Tax' column of Form 26AS / your Indian ITR, not just the base TDS rate." |
| `ftc_limitation_usd` | derived | **DERIVED** |  | DERIVED ∣ basket income / total taxable × US tax |
| `ftc_allowed_usd` | derived | **DERIVED** |  | DERIVED ∣ MIN(taxes paid, limitation) |
| `ftc_carryback_1yr_usd` | string | **OPTIONAL** |  |  |
| `ftc_carryforward_10yr_usd` | string | **OPTIONAL** |  |  |


## Section 18: WITHHOLDING & ESTIMATED TAX

*Screen 3Q | Always shown*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `federal_withholding_total_usd` | derived | **DERIVED** |  | DERIVED — sum from W-2s + 1099s |
| `state_withholding_total_usd` | derived | **DERIVED** |  | DERIVED |
| `estimated_tax_q1_apr15_usd` | string | **OPTIONAL** |  |  |
| `estimated_tax_q2_jun15_usd` | string | **OPTIONAL** |  |  |
| `estimated_tax_q3_sep15_usd` | string | **OPTIONAL** |  |  |
| `estimated_tax_q4_jan15_usd` | string | **OPTIONAL** |  | Quarter-wise required for §6654 underpayment penalty computation. |
| `prior_year_total_tax_usd` | string | **OPTIONAL** |  | For safe harbor: pay 100% of prior-year tax (110% if AGI > $150K). |
| `additional_medicare_tax_owed_usd` | derived | **DERIVED** |  | DERIVED ∣ 0.9% on wages/SE > $200K single / $250K MFJ. Employer does not match the additional 0.9%. No FTC offset. |


## Section 19: NRA-SPECIFIC (US-002 §19, §6.2A)

*Screen 3R | ENABLED IF: lock = "NON_RESIDENT_ALIEN" Form 1040-NR. US-source ECI + FDAP only.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `files_form_1040nr` | bool | **CONDITIONAL** |  | bool |
| `w8ben_aggregate_status` | enum | **DERIVED** |  | DERIVED ∣ "all_filed" ∣ "partial" ∣ "none" ∣ "expired" Engine computes by scanning bank_accounts[] and financial_holdings[] where lock = "NON_RESIDENT_ALIEN". "partial" or "expired" → alert fires identifying the specific brokers needing action. |
| `form_w7_itin_application_filed` | bool | **CONDITIONAL** |  | bool — required for NRAs without SSN before any 1040-NR can be processed. |
| `us_eci_income_usd` | derived | **DERIVED** |  | DERIVED ∣ USD Effectively Connected Income — US trade/business income, taxed at graduated rates with allowed deductions. Reported on 1040-NR p.1. Auto-summed from Section 4 wages_w2[] (where employer is US) and self_employment (where US-source) plus US rental rows where the user is materially participating. |
| `us_fdap_income_usd` | derived | **DERIVED** |  | DERIVED ∣ USD Fixed/Determinable/Annual/Periodic — passive US-source income (interest, dividends, royalties, non-ECI rents). Flat 30% withholding or treaty rate. Reported on 1040-NR Schedule NEC. Auto-summed from Section 4 interest_us_source_usd, ordinary_dividends_us_source_usd, royalty_income, and non-ECI rental rows. Treaty rate applied per-payor from W-8BEN status. |
| `us_real_property_disposed` | bool | **CONDITIONAL** |  | bool — FIRPTA: 15% withholding on gross sale price by buyer (Form 8288). |
| `firpta_withholding_usd` | string | **CONDITIONAL** |  |  |
| `is_lrs_investor` | bool | **CONDITIONAL** |  | bool — Indian resident investing in US markets via RBI's LRS scheme. Engine surfaces FDAP withholding rules; this user does NOT file 1040, only suffers withholding at source. |


## Section 20: METADATA

*Auto-populated by the system. No user input.*

| Field | Type | Class | Enabled If | Notes |
|-------|------|-------|-----------|-------|
| `us_calendar_year` | derived | **DERIVED** |  | DERIVED e.g. 2026 |
| `request_id` | derived | **DERIVED** |  | DERIVED UUID |
| `source` | enum | **DERIVED** |  | "onboarding" ∣ "annual_update" ∣ "transaction_trigger" ∣ "ca_review" |
| `input_completeness` | enum | **DERIVED** |  | "provisional" ∣ "complete" |
| `schema_version` | derived | **DERIVED** |  |  |
| `obbba_threshold_table_version` | derived | **DERIVED** |  | Pins the inflation-adjusted threshold table the engine uses for this row. |
| `created_at` | derived | **DERIVED** |  | ISO 8601 |
| `last_updated_at` | derived | **DERIVED** |  |  |


---

# APPENDIX A — India Residency Lock (RS-001) — 19 Exhaustive Paths

Source: India Residency (Tax Engine Logic).docx — CA signed KJ 23-03-2026

**Key:** DAYS = days_in_india_current_year · P4Y_365 = preceding 4yr ≥ 365 · EMP = employment_or_crew_status · VISIT = came_on_visit_to_india_pio_citizen · NR9 = NR 9/10 years · D7_729 = ≤ 729 days in 7yr · INC_15L = income > ₹15L · LTAC = liable_to_tax_in_another_country_being_indian_citizen

## ROR (2 paths) — Full worldwide taxation

| Path | Conditions |
|------|------------|
| ROR-1 | DAYS ≥ 182 AND NR9 = false AND D7_729 = false |
| ROR-2 | DAYS ∈ [60,181] AND P4Y_365 = true AND EMP = "none" AND VISIT = false AND NR9 = false AND D7_729 = false |

## RNOR (9 paths)

| Path | Conditions | Statutory Basis |
|------|------------|----------------|
| RNOR-1 | DAYS ≥ 182 AND NR9 = true | Condition A via 182-day — s.6(6)(a) |
| RNOR-2 | DAYS ≥ 182 AND D7_729 = true | Condition B via 182-day — s.6(6)(a) |
| RNOR-3 | DAYS ∈ [60,181] AND P4Y_365 = true AND EMP ≠ "none" AND INC_15L = true AND LTAC = false | Employment departure + Deemed Resident — s.6(1A) + s.6(6)(d) |
| RNOR-4 | DAYS ∈ [120,181] AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND INC_15L = true | Visitor 120-day — Condition C — s.6(6)(c). LTAC not checked — Condition C is independent of Deemed Resident. Applies to citizens AND PIOs. |
| RNOR-5 | DAYS ∈ [60,181] AND P4Y_365 = true AND EMP = "none" AND VISIT = false AND NR9 = true | Non-visitor Condition A via 60-day path |
| RNOR-6 | DAYS ∈ [60,181] AND P4Y_365 = true AND EMP = "none" AND VISIT = false AND D7_729 = true | Non-visitor Condition B via 60-day path |
| RNOR-7 | DAYS < 60 AND INC_15L = true AND LTAC = false | Deemed Resident below 60 days — s.6(1A) + s.6(6)(d). Protected: LTAC = FALSE for non-citizens (truth table rows 2+4); engine pseudocode independently checks citizen = true before entering this path. |
| RNOR-8 | DAYS ∈ [60,181] AND P4Y_365 = false AND INC_15L = true AND LTAC = false | Deemed Resident — 60-day path fails, preceding 4yr < 365. Same citizenship protection as RNOR-7. |
| RNOR-9 | DAYS ∈ [60,119] AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND INC_15L = true AND LTAC = false | Visitor < 120 days + Deemed Resident. Same citizenship protection as RNOR-7. |

## NR (8 paths)

| Path | Conditions | Reason |
|------|------------|--------|
| NR-1 | DAYS < 60 AND INC_15L = true AND LTAC = true | Deemed Resident blocked — Indian citizen liable to tax in another country |
| NR-2 | DAYS < 60 AND INC_15L = false | No income threshold met; no path to residency |
| NR-3 | DAYS ∈ [60,181] AND P4Y_365 = false AND INC_15L = true AND LTAC = true | 60-day path fails (preceding 4yr < 365) + Deemed Resident blocked by foreign liability |
| NR-4 | DAYS ∈ [60,181] AND P4Y_365 = false AND INC_15L = false | 60-day path fails + no Deemed Resident (income ≤ ₹15L) |
| NR-5 | DAYS ∈ [120,181] AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND INC_15L = false | Visitor 120-day path: meets day threshold but income ≤ ₹15L so Condition C does not apply |
| NR-6 | DAYS ∈ [60,119] AND P4Y_365 = true AND EMP = "none" AND VISIT = true AND INC_15L = true AND LTAC = true | Visitor < 120 days, income > ₹15L, but Deemed Resident blocked by foreign liability |
| NR-7 | DAYS ∈ [60,181] AND P4Y_365 = true AND EMP ≠ "none" AND INC_15L = false | Employment departure exception, income ≤ ₹15L → no Deemed Resident path available |
| NR-8 | DAYS ∈ [60,181] AND P4Y_365 = true AND EMP ≠ "none" AND INC_15L = true AND LTAC = true | Employment departure, income > ₹15L but Deemed Resident blocked by foreign liability |

### Engine Implementation Notes

1. Evaluate top-down: DAYS ≥ 182 first, then DAYS 60–181 sub-tree, then DAYS < 60 sub-tree.
2. Within the 60–181 sub-tree, the FIRST fork is P4Y_365. If P4Y_365 = false → skip directly to Deemed Resident check (RNOR-8 if INC_15L + ¬LTAC, else NR-3 or NR-4).
3. If P4Y_365 = true → fork on EMP: EMP ≠ "none" → employment path (RNOR-3 or NR-7/NR-8). EMP = "none" → fork on VISIT: VISIT = true → visitor path (RNOR-4, RNOR-9, NR-5, NR-6). VISIT = false → standard path (ROR-2, RNOR-5, RNOR-6).
4. Deemed Resident paths (RNOR-3, RNOR-7, RNOR-8, RNOR-9) are ALWAYS RNOR (never ROR) per s.6(6)(d). The Condition A/B check is NOT applied to Deemed Residents.
5. RNOR-1 and RNOR-2 are NOT mutually exclusive. A person with days ≥ 182 AND NR9 = true AND D7_729 = true matches BOTH. The result is the same (RNOR), so no conflict.
6. The employment_or_crew_status field may be null/hidden when the gate conditions don't fire. In that case, treat as "none" for lock derivation. Same for came_on_visit_to_india_pio_citizen.
7. **Citizenship enforcement on Deemed Resident paths:** The RS-001 engine pseudocode checks `citizen = true` independently before entering any s.6(1A) path. The LTAC composite boolean provides the "liable elsewhere" blocker; the `is_indian_citizen` pre-fill from Layer 0 provides the citizenship gate. A PIO (citizen=false) will never enter RNOR-3, RNOR-7, RNOR-8, or RNOR-9 because the engine checks `citizen` directly, even though LTAC = FALSE for non-citizens.

---

# APPENDIX B — US Residency Lock (SPT)

| Priority | Condition | Result |
|----------|-----------|--------|
| 1 | is_us_citizen = true | US_CITIZEN |
| 2 | has_green_card = true AND no I-407 surrendered this year | RESIDENT_ALIEN |
| 3 | SPT met (weighted ≥ 183 days) AND closer_connection_claim ≠ true | RESIDENT_ALIEN |
| 4 | Mid-year GC grant / first-year choice elected / expatriation mid-year | DUAL_STATUS |
| 5 | Otherwise | NON_RESIDENT_ALIEN |

**SPT Formula:** `us_days_current_year + (us_days_minus_1_year / 3) + (us_days_minus_2_years / 6)`. Exempt-individual days subtracted before weighting. Threshold: current_year ≥ 31 AND weighted total ≥ 183.

---

# APPENDIX C — Trip Calendar Toggle (Audit Resolution #2)

**Problem:** Users manually entering `india_days` and `us_days` introduces estimation error. The `is_departure_year` boolean is vulnerable to user mis-answering in subsequent years after the Binny Bansal [2026] auto-reset.

**Solution:** Replace manual day-count entry with a Trip Calendar Toggle:

1. User sees a year-long calendar (India FY: Apr–Mar for India days; US CY: Jan–Dec for US days)
2. User toggles each segment as "India" or "US" or "Other"
3. System DERIVES: `india_days`, `us_days`, departure date, whether departure year = current FY
4. `current_year_trip_log` is populated automatically from toggle data
5. The `is_departure_year` boolean becomes DERIVED (not user-input) — computed from the first date the user toggled from "India" to "US/Other" for employment, compared against FY boundaries
6. April 1st reset is no longer a background job — the trip calendar inherently scopes to the current FY

**Layer 0 impact:** `india_days` and `us_days` remain as fields but are now DERIVED from the calendar toggle. The toggle is the single source of truth. Layer 0 still shows these as pre-filled integers; the user can override manually if they prefer not to use the calendar.

**Implementation:** The toggle is a frontend-only component (React date-range picker). It writes to `current_year_trip_log` array. Backend derives day counts from the log on every PATCH.

---

# APPENDIX D — ₹15L Income Threshold Feedback Loop (Audit Resolution #5)

**Problem:** User answers `india_source_income_above_15l = false` during onboarding → classified NR. Later, Layer 2 DAG computes actual India income = ₹18L. Residency lock is stale.

**Solution — Option B (user-confirmed re-fire):**

1. Layer 2 DAG runs and computes total India-source income.
2. If computed income > ₹15L AND `india_source_income_above_15l` = false: Engine emits `INCOME_THRESHOLD_DISCREPANCY` alert. Frontend shows: "Your computed India income is ₹18,00,000 which exceeds ₹15 lakh. This may change your India residency from NR to RNOR. Would you like to update?" User chooses [Update & Re-evaluate] → sets `india_source_income_above_15l = true` → lock re-fires → DAG re-runs (max 2 iterations). Or [Keep Current Status] → flag persists as `INCOME_THRESHOLD_OVERRIDE_BY_USER` for CA review; lock unchanged.
3. If computed income ≤ ₹15L AND `india_source_income_above_15l` = true: Same flow in reverse.
4. Max iterations: 2. If lock flips twice, route to CA.

**Key principle:** The boolean remains user-confirmed — the engine never silently changes the lock. The DAG is re-entrant but not self-modifying.

---

# APPENDIX E — Dual Residency DTAA Tie-Breaker Inputs (Audit Resolution #4)

When both India lock (ROR/RNOR) AND US lock (RESIDENT_ALIEN/US_CITIZEN) fire simultaneously, the India-US DTAA Article 4 tie-breaker cascade must be applied. Layer 1 prepares the inputs; Layer 2 computes both scenarios.

**Tie-breaker cascade (DTAA Article 4):**

| Step | Test | Resident of |
|------|------|-------------|
| 1 | Permanent home available | Country where permanent home exists |
| 2 | Centre of vital interests | Country of stronger personal + economic ties |
| 3 | Habitual abode | Country of habitual residence |
| 4 | Nationality | Country of citizenship |
| 5 | Mutual agreement | Treaty authorities must agree |

**Inputs to prepare in Layer 1 (future sprint):**

| Field | Schema | Type | Notes |
|-------|--------|------|-------|
| `permanent_home_india` | layer1_india | bool | Owns or rents a permanent dwelling in India that is available to the individual at all times |
| `permanent_home_us` | layer1_us | bool | Owns or rents a permanent dwelling in the US that is available to the individual at all times |
| `vital_interests_country` | coordinator | enum (IN/US) | Country with stronger personal and economic ties — factual determination, never auto-resolved |
| `habitual_abode_country` | coordinator | enum (IN/US) | Country where the individual habitually resides — based on frequency and duration of stays |
| `nationality` | layer0 | enum | Pre-filled from citizenship fields — Indian citizen or US citizen (India does not permit dual citizenship with US; naturalised US citizens hold OCI) |

**Layer 2 DAG behavior:** When `DUAL_RESIDENCY_DTAA_REVIEW` fires, the DAG computes TWO scenarios (India-primary FTC computation, US-primary FTC computation) and presents both to the user and CA. The engine does NOT auto-resolve the tie-breaker — it requires factual analysis of the individual's circumstances by a licensed CA and CPA.
