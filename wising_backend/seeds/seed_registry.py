#!/usr/bin/env python3
"""
WISING TAX ENGINE — Field Registry Seeder
══════════════════════════════════════════════════════════════════════
Document : WISING-IMPL-001 Sprint 1 / Antigravity Gate
Schema   : layer0_residency_final.jsonc
           layer1_india_v5_1_final.jsonc
           layer1_us_v2_final.jsonc
Output   : seed_output.sql  (PostgreSQL UPSERT statements)

PURPOSE
───────
This script is the SINGLE authoritative DML source for field_registry.
sprint1_migration_DDL_ONLY.sql is DDL-only (table creation). Never hard-code
field rows in SQL again — all changes flow through this script.

ANTI-CORRUPTION CONTROLS
─────────────────────────
1. SHA-256 checksums of all three JSONC source files are logged and
   embedded as SQL comments. CI must fail if checksums change without
   a corresponding registry version bump.
2. All field_paths are fully qualified: schema.section(.subsection)*.field
3. Array-of-object templates are registered as parent[].field so the
   completion engine can iterate actual array items.
4. CLASSIFICATION tags are parsed directly from JSONC comment blocks.
   The seeder never infers classification from field name heuristics.
5. ENABLED IF gates are parsed into structured JSONB that evaluate_gate()
   in sprint1_input_layer_PATCHED.py can evaluate directly.
6. DERIVED fields ARE seeded (classification='DERIVED') so the contract
   between backend derivation and frontend read-only display is explicit.

SCHEMA VERSION NOTES (v5.1 specific)
──────────────────────────────────────
• `presumptive_scheme`   : array of enum — input_type='array'
• `nature_of_business`   : array of enum — input_type='array'
• `goods_vehicles[]`     : array of objects — container + template fields
• `asset_blocks[]`       : array of objects — container + template fields
• `msme_payables[]`      : array of objects — container + template fields
• `financial_holdings.transactions[]` : array of objects
• `property.properties[]` : array of objects
• All new v5.1 expense sub-fields registered under
  domestic_income.business_income.expenses.*

KNOWN GAPS (HISTORICAL — ALL RESOLVED)
────────────────────────────────────────
• GAP-001: ✅ RESOLVED — enum_values JSONB column is present in sprint1_migration_DDL_ONLY.sql.
  The seeder still emits an ALTER TABLE IF NOT EXISTS as a safety net.
• GAP-002: ✅ RESOLVED — schema_version is now "v5.1" in sprint1_input_layer_PATCHED.py.
• GAP-003: ✅ RESOLVED — evaluate_gate() in sprint1_input_layer_PATCHED.py now supports
  `contains` and `eq []` operators.

USAGE
─────
  python seed_registry.py                         # write seed_output.sql
  python seed_registry.py --dry-run               # print to stdout
  python seed_registry.py --output my_seed.sql    # custom output path
  python seed_registry.py --checksum-only         # only print checksums

"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Optional

# ══════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ══════════════════════════════════════════════════════════════════════

# Adjust if running from a directory other than the project root.
PROJECT_ROOT = Path(__file__).parent

SCHEMA_FILES: dict[str, Path] = {
    "layer0":       PROJECT_ROOT / "layer0_residency_final.jsonc",
    "layer1_india": PROJECT_ROOT / "layer1_india_v5_1_final.jsonc",
    "layer1_us":    PROJECT_ROOT / "layer1_us_v2_final.jsonc",
}

DEFAULT_OUTPUT = PROJECT_ROOT / "seed_output.sql"

# Section ordering tables — defines wizard_section_order per schema.
# Increment by 10 to leave room for future sections between existing ones.
LAYER0_SECTION_ORDER: dict[str, int] = {
    "jurisdiction_router": 10,
}

LAYER1_INDIA_SECTION_ORDER: dict[str, int] = {
    "profile":               10,
    "residency_detail":      20,
    "dtaa":                  30,
    "compliance_docs":       40,
    "bank_accounts":         50,
    "nro_repatriation":      55,
    "property":              60,
    "financial_holdings":    70,
    "commodities":           80,
    "unlisted_equity":       90,
    "share_buyback":        100,
    "domestic_income":      110,
    "other_sources":        120,
    "deductions":           130,
    "carry_forward_losses": 140,
    "lrs_outbound":         150,
    "tax_credits":          160,
    "surcharge_buckets":    170,
    "metadata":             180,
}

LAYER1_US_SECTION_ORDER: dict[str, int] = {
    "us_profile":              10,
    "us_residency_detail":     20,
    "us_state_residency":      30,
    "us_income_us_source":     40,
    "us_income_foreign_source":50,
    "us_equity_compensation":  60,
    "us_feie":                 70,
    "us_bank_accounts":        80,
    "us_financial_holdings":   90,
    "us_real_estate":         100,
    "us_retirement_accounts": 110,
    "us_foreign_entities":    120,
    "us_foreign_gifts":       130,
    "us_deductions_credits":  140,
    "us_amt":                 150,
    "us_niit":                160,
    "us_ftc":                 170,
    "us_withholding":         180,
    "us_nra_specific":        190,
    "metadata":               200,
}

SECTION_ORDER_MAPS: dict[str, dict[str, int]] = {
    "layer0":       LAYER0_SECTION_ORDER,
    "layer1_india": LAYER1_INDIA_SECTION_ORDER,
    "layer1_us":    LAYER1_US_SECTION_ORDER,
}

# Human-readable labels for fields that lack a Q-line comment.
# The seeder falls back to humanizing the field name if not found here.
LABEL_OVERRIDES: dict[str, str] = {
    # ── Layer 0 ──
    "layer0.is_indian_citizen":                      "Are you an Indian citizen?",
    "layer0.is_pio_or_oci":                          "Are you a Person of Indian Origin (PIO) or OCI cardholder?",
    "layer0.india_days":                             "How many days were you physically present in India this tax year (Apr 2025–Mar 2026)?",
    "layer0.has_india_source_income_or_assets":      "Do you have any India-source income or Indian assets this year?",
    "layer0.is_us_citizen":                          "Are you a US citizen?",
    "layer0.has_green_card":                         "Do you hold a valid US Green Card (Form I-551)?",
    "layer0.was_in_us_this_year":                    "Were you physically present in the US at any point this calendar year?",
    "layer0.us_days":                                "How many days were you in the US this calendar year?",
    "layer0.has_us_source_income_or_assets":         "Do you have any US-source income or US-situs assets this year?",
    "layer0.liable_to_tax_in_another_country":       "Are you personally liable to pay income tax in any other country this year?",
    "layer0.left_india_for_employment_this_year":    "Did you leave India this year specifically for employment abroad or as a ship crew member?",
    "layer0.india_flag":                             "[DERIVED] India taxing rights flag",
    "layer0.us_flag":                                "[DERIVED] US taxing rights flag",
    "layer0.jurisdiction":                           "[DERIVED] Jurisdiction routing output",
    # ── Layer 1 India: Profile ──
    "layer1_india.profile.date_of_birth":            "What is your date of birth?",
    "layer1_india.profile.pan":                      "What is your PAN (Permanent Account Number)?",
    "layer1_india.profile.pan_aadhaar_linked":       "Is your PAN linked to Aadhaar?",
    "layer1_india.profile.tax_regime":               "Which tax regime do you prefer? (New or Old)",
    # ── Layer 1 India: Residency Detail ──
    "layer1_india.residency_detail.days_in_india_current_year": "How many days were you physically present in India this FY?",
    "layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365": "In the preceding 4 FYs combined, were you in India for 365+ days total?",
    "layer1_india.residency_detail.employment_or_crew_status": "What is your employment/crew status for the departure from India?",
    "layer1_india.residency_detail.is_departure_year": "Is this the first FY you left India for this employment/crew role?",
    "layer1_india.residency_detail.ship_nationality": "What is the nationality of the ship you serve on?",
    "layer1_india.residency_detail.came_on_visit_to_india_pio_citizen": "Did you come to India on a visit, being a PIO or Indian citizen?",
    "layer1_india.residency_detail.nr_years_last_10_gte_9": "In the last 10 FYs, were you Non-Resident for 9 or more years?",
    "layer1_india.residency_detail.days_in_india_last_7_years_lte_729": "In the preceding 7 FYs combined, were you in India for 729 days or fewer?",
    "layer1_india.residency_detail.india_source_income_above_15l": "Is your India-source income above ₹15 lakh this tax year?",
    "layer1_india.residency_detail.current_year_trip_log": "India trip log (arrival/departure dates)",
    "layer1_india.residency_detail.liable_to_tax_in_another_country_being_indian_citizen": "[DERIVED] Deemed Resident blocker",
    "layer1_india.residency_detail.final_india_residency_status": "[DERIVED] India Residency Lock (NR / RNOR / ROR)",
    # ── Layer 1 India: DTAA ──
    "layer1_india.dtaa.tax_residency_country":       "Which country is your current tax home (ISO code, e.g. US)?",
    "layer1_india.dtaa.is_us_resident_for_dtaa":     "Are you a US tax resident for DTAA purposes?",
    "layer1_india.dtaa.trc_status":                  "Do you have a valid Tax Residency Certificate (TRC)?",
    "layer1_india.dtaa.has_permanent_establishment_in_india": "Do you have a fixed place of business or dependent agent in India?",
    "layer1_india.dtaa.treaty_elections":             "Treaty rate elections (per income stream)",
    "layer1_india.dtaa.mfn_clause_invoked":          "Are you invoking the Most Favoured Nation (MFN) clause?",
    # ── Layer 1 India: Compliance Docs ──
    "layer1_india.compliance_docs.trc.validity_start_date": "TRC validity start date",
    "layer1_india.compliance_docs.trc.validity_end_date": "TRC validity end date",
    "layer1_india.compliance_docs.trc.document_uploaded": "Has the TRC document been uploaded/verified?",
    "layer1_india.compliance_docs.form_10f.is_filed": "Has Form 10F been filed electronically?",
    "layer1_india.compliance_docs.form_10f.ack_number": "Form 10F acknowledgement number",
    "layer1_india.compliance_docs.section_197_cert.is_available": "Do you have a Section 197 lower TDS certificate?",
    "layer1_india.compliance_docs.section_197_cert.rate": "Section 197 certificate rate (e.g. 0.05 for 5%)",
    "layer1_india.compliance_docs.section_197_cert.validity_start_date": "Section 197 certificate validity start date",
    "layer1_india.compliance_docs.section_197_cert.validity_end_date": "Section 197 certificate validity end date",
    "layer1_india.compliance_docs.section_197_cert.covered_income_types": "Income types covered by Section 197 certificate",
    "layer1_india.compliance_docs.chapter_xiia_elected": "Have you ever elected the Chapter XII-A special tax regime?",
    # ── Layer 1 India: Bank Accounts ──
    "layer1_india.bank_accounts":                    "Indian bank accounts",
    # ── Layer 1 India: NRO Repatriation ──
    "layer1_india.nro_repatriation.cumulative_repatriated_usd_this_fy": "Total USD repatriated from NRO this FY",
    "layer1_india.nro_repatriation.pending_repatriation_inr": "Pending NRO repatriation amount (INR)",
    "layer1_india.nro_repatriation.tds_deducted_on_nro_balance": "Has TDS been deducted on NRO balance?",
    # ── Layer 1 India: Property ──
    "layer1_india.property.has_indian_property_transaction": "Have you sold or are you selling Indian immovable property this FY?",
    "layer1_india.property.properties":              "Property transaction details",
    # ── Layer 1 India: Financial Holdings ──
    "layer1_india.financial_holdings.has_financial_transactions": "Did you have any financial transactions (stocks, MFs, bonds) this FY?",
    "layer1_india.financial_holdings.transactions":   "Financial transaction details",
    # ── Layer 1 India: Commodities ──
    "layer1_india.commodities.has_commodity_transactions": "Did you have any commodity transactions (gold, silver, SGB) this FY?",
    "layer1_india.commodities.transactions":          "Commodity transaction details",
    # ── Layer 1 India: Unlisted Equity ──
    "layer1_india.unlisted_equity.has_unlisted_equity_transaction": "Did you sell any unlisted/private company shares this FY?",
    "layer1_india.unlisted_equity.transactions":      "Unlisted equity transaction details",
    # ── Layer 1 India: Share Buyback ──
    "layer1_india.share_buyback.has_buyback_transaction": "Were any of your shares bought back by a company this FY?",
    "layer1_india.share_buyback.transactions":        "Share buyback transaction details",
    # ── Layer 1 India: Domestic Income — Salary ──
    "layer1_india.domestic_income.salary.has_salary_income": "Do you have salary income this FY?",
    "layer1_india.domestic_income.salary.gross_salary_inr": "Gross salary received (INR)",
    "layer1_india.domestic_income.salary.exempt_allowances_inr": "Total exempt allowances (INR)",
    "layer1_india.domestic_income.salary.hra_received_inr": "HRA received (INR)",
    "layer1_india.domestic_income.salary.rent_paid_inr": "Rent paid during the year (INR)",
    "layer1_india.domestic_income.salary.is_metro_city": "Is your place of employment in a metro city?",
    "layer1_india.domestic_income.salary.basic_da_inr": "Basic salary + DA (INR)",
    "layer1_india.domestic_income.salary.lta_claimed_inr": "LTA claimed (INR)",
    "layer1_india.domestic_income.salary.perquisites_inr": "Perquisites value (INR)",
    "layer1_india.domestic_income.salary.esop_perquisite_inr": "ESOP perquisite value (INR)",
    "layer1_india.domestic_income.salary.professional_tax_inr": "Professional tax paid (INR)",
    "layer1_india.domestic_income.salary.employer_nps_contribution_inr": "Employer NPS contribution (INR)",
    "layer1_india.domestic_income.salary.prior_employer_salary_inr": "Salary from prior employer (INR, if switched jobs mid-year)",
    # ── Layer 1 India: Domestic Income — House Property ──
    "layer1_india.domestic_income.house_property.has_house_property_income": "Do you have income from house property?",
    # ── Layer 1 India: Domestic Income — Business ──
    "layer1_india.domestic_income.business_income.has_business_or_fo_income": "Do you have business, professional, or F&O income?",
    "layer1_india.domestic_income.business_income.nature_of_business": "Nature of your business/profession (select all that apply)",
    "layer1_india.domestic_income.business_income.presumptive_scheme": "Presumptive taxation scheme (select all that apply)",
    "layer1_india.domestic_income.business_income.profession_type": "Type of profession (for s.44ADA)",
    "layer1_india.domestic_income.business_income.s115BAC_optout_history": "Have you previously opted out of the New Tax Regime?",
    "layer1_india.domestic_income.business_income.turnover_inr": "Total gross turnover/receipts for the FY (INR)",
    "layer1_india.domestic_income.business_income.digital_receipts_inr": "Receipts via banking channels (INR)",
    "layer1_india.domestic_income.business_income.cash_receipts_inr": "Cash receipts (INR)",
    "layer1_india.domestic_income.business_income.gross_receipts_inr": "Gross professional receipts (INR)",
    "layer1_india.domestic_income.business_income.s44AD_last_exit_ay": "Last AY you opted out of s.44AD (if any)",
    "layer1_india.domestic_income.business_income.s44AD_opted_current_year": "Are you electing s.44AD for the current year?",
    "layer1_india.domestic_income.business_income.goods_vehicles": "Goods transport vehicles (for s.44AE)",
    "layer1_india.domestic_income.business_income.opening_stock_inr": "Opening stock value at 1 April (INR)",
    "layer1_india.domestic_income.business_income.closing_stock_inr": "Closing stock value at 31 March (INR)",
    "layer1_india.domestic_income.business_income.gst_registration_status": "GST registration status",
    "layer1_india.domestic_income.business_income.gst_collected_inr": "GST collected from customers this FY (INR)",
}


# ══════════════════════════════════════════════════════════════════════
# GATE OVERRIDES — Complex enabled_if conditions that the auto-parser
# cannot handle. These are manually specified as structured JSONB.
# ══════════════════════════════════════════════════════════════════════

GATE_OVERRIDES: dict[str, dict | None] = {
    # employment_or_crew_status: ALL 5 conditions must be true
    "layer1_india.residency_detail.employment_or_crew_status": {
        "and": [
            {"field": "layer0.left_india_for_employment_this_year", "op": "eq", "value": True},
            {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 60},
            {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "lt", "value": 182},
            {"field": "layer1_india.residency_detail.days_in_india_preceding_4_years_gte_365", "op": "eq", "value": True},
            {"field": "layer0.is_indian_citizen", "op": "eq", "value": True},
        ]
    },
    # is_departure_year: employment_or_crew_status NOT IN [none, null]
    "layer1_india.residency_detail.is_departure_year": {
        "field": "layer1_india.residency_detail.employment_or_crew_status",
        "op": "not_in", "value": ["none"]
    },
    # ship_nationality: employment_or_crew_status IN [indian_ship_crew, foreign_ship_crew]
    "layer1_india.residency_detail.ship_nationality": {
        "field": "layer1_india.residency_detail.employment_or_crew_status",
        "op": "in", "value": ["indian_ship_crew", "foreign_ship_crew"]
    },
    # came_on_visit: employment = "none" (only in the 60-181 + P4Y path)
    "layer1_india.residency_detail.came_on_visit_to_india_pio_citizen": {
        "field": "layer1_india.residency_detail.employment_or_crew_status",
        "op": "eq", "value": "none"
    },
    # nr_years_last_10: days >= 182 OR came_on_visit = false
    "layer1_india.residency_detail.nr_years_last_10_gte_9": {
        "or": [
            {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 182},
            {"field": "layer1_india.residency_detail.came_on_visit_to_india_pio_citizen", "op": "eq", "value": False},
        ]
    },
    # days_in_india_last_7_years: same OR gate as above
    "layer1_india.residency_detail.days_in_india_last_7_years_lte_729": {
        "or": [
            {"field": "layer1_india.residency_detail.days_in_india_current_year", "op": "gte", "value": 182},
            {"field": "layer1_india.residency_detail.came_on_visit_to_india_pio_citizen", "op": "eq", "value": False},
        ]
    },
    # india_source_income_above_15l: Layer 0 has_india_source_income = true
    "layer1_india.residency_detail.india_source_income_above_15l": {
        "field": "layer0.has_india_source_income_or_assets", "op": "eq", "value": True
    },
    # DTAA section: lock = NR
    "layer1_india.dtaa.tax_residency_country": {
        "field": "layer1_india.residency_detail.final_india_residency_status",
        "op": "eq", "value": "NR"
    },
    "layer1_india.dtaa.is_us_resident_for_dtaa": {
        "field": "layer1_india.dtaa.tax_residency_country", "op": "eq", "value": "US"
    },
    "layer1_india.dtaa.trc_status": {
        "field": "layer1_india.residency_detail.final_india_residency_status",
        "op": "eq", "value": "NR"
    },
    "layer1_india.dtaa.has_permanent_establishment_in_india": {
        "field": "layer1_india.residency_detail.final_india_residency_status",
        "op": "eq", "value": "NR"
    },
    # LRS outbound: lock = ROR only
    "layer1_india.lrs_outbound": {
        "field": "layer1_india.residency_detail.final_india_residency_status",
        "op": "eq", "value": "ROR"
    },
}

# ══════════════════════════════════════════════════════════════════════
# DATA STRUCTURES
# ══════════════════════════════════════════════════════════════════════

@dataclass
class FieldDef:
    """One row destined for the field_registry table."""
    field_path:     str
    schema_name:    str
    section:        str
    classification: str          # REQUIRED | CONDITIONAL | OPTIONAL | DERIVED
    friendly_label: str
    input_type:     str          # integer|boolean|enum|date|currency|string|array
    enum_values:    Optional[list[str]] = None
    enabled_if:     Optional[dict]      = None
    default_value:  Optional[Any]       = None
    default_label:  Optional[str]       = None
    wizard_order:   int = 0
    section_order:  int = 0

    # ── section-local counter for wizard_order (set by walker) ──
    _local_idx: int = field(default=0, repr=False, compare=False)


# ══════════════════════════════════════════════════════════════════════
# JSONC PARSER
# ══════════════════════════════════════════════════════════════════════

def strip_jsonc(text: str) -> str:
    """
    Remove JSONC comments (// line comments, /* */ block comments).
    Also removes trailing commas before ] or } so the result is
    valid JSON.

    Does NOT use a full tokeniser — avoids pulling in dependencies.
    Handles the only patterns that appear in the Wising JSONC files.
    """
    # 1. Remove /* ... */ block comments (non-greedy, dotall)
    text = re.sub(r'/\*[\s\S]*?\*/', '', text)

    # 2. Remove // line comments  (do NOT strip inside string values)
    #    Safe approach: remove from the first // that is NOT inside quotes.
    #    The JSONC files never have // inside string values, so a simple
    #    line-level strip is safe.
    lines = []
    for line in text.splitlines():
        # Find first // that is not inside a quoted string
        in_string = False
        i = 0
        while i < len(line):
            c = line[i]
            if c == '"' and (i == 0 or line[i-1] != '\\'):
                in_string = not in_string
            if not in_string and line[i:i+2] == '//':
                line = line[:i]
                break
            i += 1
        lines.append(line)
    text = '\n'.join(lines)

    # 3. Remove trailing commas before } or ] (common JSONC pattern)
    text = re.sub(r',\s*([\]}])', r'\1', text)

    return text


def load_jsonc(path: Path) -> tuple[dict | list, str]:
    """
    Load a JSONC file. Returns (parsed_json, raw_text).
    raw_text is needed for comment-metadata extraction.
    """
    raw = path.read_text(encoding='utf-8')
    clean = strip_jsonc(raw)
    try:
        return json.loads(clean), raw
    except json.JSONDecodeError as e:
        print(f"[ERROR] Failed to parse {path.name}: {e}", file=sys.stderr)
        print(f"  Offending section near char {e.pos}:", file=sys.stderr)
        start = max(0, e.pos - 80)
        print(f"  ...{clean[start:e.pos+80]}...", file=sys.stderr)
        raise


# ══════════════════════════════════════════════════════════════════════
# COMMENT METADATA EXTRACTOR
# ══════════════════════════════════════════════════════════════════════

@dataclass
class FieldMeta:
    classification: str = "OPTIONAL"
    friendly_label: str = ""
    enabled_if_raw: str = ""
    enum_hint:      str = ""     # raw text after the field definition
    input_type_hint:str = ""     # "bool"|"integer"|"date"|"enum"|"string"|"array"


class CommentExtractor:
    """
    Scans raw JSONC text and, for each field name encountered,
    collects the comment block that immediately follows the field
    definition line.

    Multiple occurrences of the same field name (e.g. `acquisition_date`
    in several array templates) are stored in order of appearance so
    the walker can pick the right one by occurrence index.
    """

    _FIELD_LINE = re.compile(r'^\s*"([^"]+)"\s*[:\[]')
    _CLASS_TAG  = re.compile(r'CLASSIFICATION\s*:\s*(REQUIRED|CONDITIONAL|OPTIONAL|DERIVED)',
                              re.IGNORECASE)
    _ENABLED_IF = re.compile(r'ENABLED\s+IF\s*[:\-–]?\s*(.+)', re.IGNORECASE)
    _Q_LINE     = re.compile(r'Q\d+[a-z]?\s*\|\s*(.+)')
    _TYPE_HINT  = re.compile(
        r'\b(bool|integer|string|date|enum|array|currency|float)\b', re.IGNORECASE)

    def __init__(self, raw_text: str):
        self._occurrences: dict[str, list[FieldMeta]] = {}
        self._parse(raw_text)

    def _parse(self, text: str) -> None:
        lines = text.splitlines()
        n = len(lines)
        i = 0
        while i < n:
            m = self._FIELD_LINE.match(lines[i])
            if m:
                fname = m.group(1)
                meta = FieldMeta()
                j = i + 1
                comment_lines: list[str] = []
                while j < n:
                    stripped = lines[j].strip()
                    if stripped.startswith('//'):
                        comment_lines.append(stripped[2:].strip())
                        j += 1
                    else:
                        break

                for cl in comment_lines:
                    cm = self._CLASS_TAG.search(cl)
                    if cm:
                        raw_cls = cm.group(1).upper()
                        # NEW v5.1 fields may have "OPTIONAL — NEW v5.1" etc.
                        meta.classification = raw_cls

                    em = self._ENABLED_IF.search(cl)
                    if em and not meta.enabled_if_raw:
                        meta.enabled_if_raw = em.group(1).strip()

                    qm = self._Q_LINE.search(cl)
                    if qm and not meta.friendly_label:
                        meta.friendly_label = qm.group(1).strip()

                    # Collect type hints and enum hints
                    if '"' in cl and ('|' in cl):
                        meta.enum_hint += ' ' + cl
                    tm = self._TYPE_HINT.search(cl)
                    if tm and not meta.input_type_hint:
                        meta.input_type_hint = tm.group(1).lower()

                # First non-metadata comment line → label fallback
                # Skip lines that are pure type descriptors (bool, integer, date, enum pipes)
                _TYPE_ONLY = re.compile(
                    r'^("?(?:bool|integer|string|date|enum|array|currency|float|DERIVED|'
                    r'PRE-FILLED|PROGRESSIVE|number|decimal)'
                    r'[^a-zA-Z]*(?:\(.*\))?[^a-zA-Z]*$'
                    r'|^"[A-Z\-]+"$'  # "YYYY-MM-DD" etc
                    r'|^"[^"]*"\s*\|'  # "val1" | "val2" pipe lists
                    r'|^[A-Z_]+\s*$'  # bare constants
                    r')', re.IGNORECASE)
                if not meta.friendly_label:
                    for cl in comment_lines:
                        if not self._CLASS_TAG.search(cl) \
                                and not self._ENABLED_IF.search(cl) \
                                and cl and not cl.startswith('─') \
                                and not cl.startswith('═') \
                                and not _TYPE_ONLY.match(cl.strip()) \
                                and not cl.strip().startswith('bool') \
                                and len(cl.strip()) > 15:
                            meta.friendly_label = cl[:120]
                            break

                if fname not in self._occurrences:
                    self._occurrences[fname] = []
                self._occurrences[fname].append(meta)

            i += 1

    def get(self, fname: str, occurrence: int = 0) -> FieldMeta:
        entries = self._occurrences.get(fname, [])
        if not entries:
            return FieldMeta()
        return entries[min(occurrence, len(entries) - 1)]

    def occurrence_count(self, fname: str) -> int:
        return len(self._occurrences.get(fname, []))


# ══════════════════════════════════════════════════════════════════════
# ENABLED IF  →  STRUCTURED JSONB GATE PARSER
# ══════════════════════════════════════════════════════════════════════

def _qualify_field(raw_field: str, schema: str, section: str) -> str:
    """
    Fully qualify a bare field reference found in an ENABLED IF clause.
    If it already contains a dot, assume it's qualified.
    """
    if '.' in raw_field:
        return raw_field
    # Layer 0 fields referenced from Layer 1 keep their layer0 prefix
    LAYER0_FIELDS = {
        'is_indian_citizen', 'is_pio_or_oci', 'india_days',
        'has_india_source_income_or_assets', 'is_us_citizen',
        'has_green_card', 'was_in_us_this_year', 'us_days',
        'has_us_source_income_or_assets',
        'liable_to_tax_in_another_country',
    }
    if raw_field in LAYER0_FIELDS:
        return f"layer0.{raw_field}"
    return f"{schema}.{section}.{raw_field}"


# Patterns for common ENABLED IF grammar found in the Wising JSONC files
_PATTERNS = [
    # "value" IN field_name
    (re.compile(r'^"([^"]+)"\s+IN\s+(\w+)$', re.I),
     lambda m, s, sec: {"field": _qualify_field(m.group(2), s, sec),
                        "op": "contains", "value": m.group(1)}),
    # field_name = [] (empty array)
    (re.compile(r'^(\w+)\s*=\s*\[\]$', re.I),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "eq", "value": []}),
    # field_name = true / false
    (re.compile(r'^(\w[\w.]*)\s*=\s*(true|false)$', re.I),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "eq",
                        "value": m.group(2).lower() == "true"}),
    # field_name = "string_value"
    (re.compile(r'^(\w[\w.]*)\s*=\s*"([^"]+)"$'),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "eq", "value": m.group(2)}),
    # field_name > 0
    (re.compile(r'^(\w[\w.]*)\s*>\s*(\d+)$'),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "gt", "value": int(m.group(2))}),
    # field_name >= N
    (re.compile(r'^(\w[\w.]*)\s*>=\s*(\d+)$'),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "gte", "value": int(m.group(2))}),
    # field_name < N
    (re.compile(r'^(\w[\w.]*)\s*<\s*(\d+)$'),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "lt", "value": int(m.group(2))}),
    # lock IN ["X","Y"]  or  lock = "X"
    (re.compile(r'^(\w[\w.]*)\s+IN\s+\[([^\]]+)\]$', re.I),
     lambda m, s, sec: {"field": _qualify_field(m.group(1), s, sec),
                        "op": "in",
                        "value": [v.strip().strip('"')
                                  for v in m.group(2).split(',')]}),
]

# AND-splitting pattern  (handles both AND and " AND ")
_AND_SPLIT = re.compile(r'\s+AND\s+', re.IGNORECASE)


def parse_enabled_if(raw: str, schema: str, section: str) -> Optional[dict]:
    """
    Convert a raw ENABLED IF string into structured JSONB gate.
    Returns None if raw is empty.
    Returns {"_raw": raw, "_parse_error": true} for expressions
    that cannot be parsed — these must be reviewed manually.
    """
    raw = raw.strip().rstrip('.')
    if not raw:
        return None

    # Clean up inline taxonomy noise
    for noise in ['(DOM_Tax_03', '(s.', '(engine-enforced']:
        if noise in raw:
            raw = raw[:raw.index(noise)].strip()

    parts = [p.strip() for p in _AND_SPLIT.split(raw)]
    conditions = []
    for part in parts:
        matched = False
        for pattern, builder in _PATTERNS:
            m = pattern.match(part)
            if m:
                conditions.append(builder(m, schema, section))
                matched = True
                break
        if not matched:
            # Cannot parse — emit raw string for manual audit
            conditions.append({"_raw": part, "_parse_error": True})

    if len(conditions) == 1:
        return conditions[0]
    return {"and": conditions}


# ══════════════════════════════════════════════════════════════════════
# INPUT TYPE INFERENCE
# ══════════════════════════════════════════════════════════════════════

_BOOL_NAMES = re.compile(
    r'^(is_|has_|was_|came_|left_|pan_|s115BAC_|employer_pf|'
    r'closer_connection|first_year|s6013g|tender_or_open|'
    r'is_metro|is_self_occ|is_new_mfg|is_in_notified|'
    r'is_maturity|is_departure)', re.IGNORECASE)
_INT_NAMES  = re.compile(r'(_inr|_usd|_days|_years|_months|_percent|'
                          r'quantity|shares|number_of|wizard_order)')
_DATE_NAMES = re.compile(r'(date|_ay\b)')
_STR_NAMES  = re.compile(r'(pan$|isin$|ship_nationality|_ay$|'
                          r'year_of_|first_year_of|company_name|'
                          r'asset_name|s44AD_last_exit_ay|'
                          r'amt_credit_bf_origin_ay)')


def infer_input_type(fname: str, json_value: Any, meta: FieldMeta) -> str:
    """
    Determine the input_type for field_registry.input_type.
    Priority: meta comment hint > JSON value type > name heuristic.
    """
    # 1. Honour comment hint
    if meta.input_type_hint:
        hint = meta.input_type_hint
        if hint == 'bool':
            return 'boolean'
        if hint in ('integer', 'date', 'string', 'array', 'enum', 'currency'):
            return hint

    # 2. JSON value type
    if isinstance(json_value, bool):
        return 'boolean'
    if isinstance(json_value, int):
        return 'integer'
    if isinstance(json_value, list):
        return 'array'

    # 3. Enum hint in comments (values separated by |)
    if meta.enum_hint and '"' in meta.enum_hint and '|' in meta.enum_hint:
        return 'enum'

    # 4. Name heuristics
    if _BOOL_NAMES.match(fname):
        return 'boolean'
    if _INT_NAMES.search(fname):
        return 'integer'
    if _DATE_NAMES.search(fname):
        return 'date'
    if fname in ('pan', 'isin', 'ship_nationality'):
        return 'string'
    if _STR_NAMES.search(fname):
        return 'string'

    # 5. Fall back: treat as string (will be visible in output for review)
    return 'string'


def extract_enum_values(meta: FieldMeta) -> Optional[list[str]]:
    """
    Parse enum values from the enum_hint comment fragment.
    e.g. '"s44AD" | "s44ADA" | "s44AE"'  →  ["s44AD", "s44ADA", "s44AE"]
    """
    if not meta.enum_hint:
        return None
    values = re.findall(r'"([^"]+)"', meta.enum_hint)
    # Filter out noise (long strings, sentences)
    values = [v for v in values if len(v) < 60 and ' ' not in v]
    return values if values else None


def humanize(fname: str) -> str:
    """Convert snake_case field name to Title Case label as last resort."""
    return fname.replace('_', ' ').replace('.', ' › ').title()


# ══════════════════════════════════════════════════════════════════════
# RECURSIVE SCHEMA WALKER
# ══════════════════════════════════════════════════════════════════════

class SchemaWalker:
    """
    Recursively walks a parsed JSONC schema and emits FieldDef rows.

    Array-of-objects handling (v5.1):
    - The array container itself is registered with input_type='array'.
    - Each field in the first template object is registered with path
      parent[].field, so the completion engine can iterate instances.
    - `nature_of_business` and `presumptive_scheme` are plain arrays
      (no template object). They are registered as input_type='array'
      with enum_values populated from comments.
    """

    # Top-level keys that are section names (not field names)
    # For layer0 all top-level keys are fields; for layer1 top-level keys
    # are sections. We detect sections by checking if the value is a dict.

    def __init__(self,
                 schema_name: str,
                 extractor: CommentExtractor,
                 section_order_map: dict[str, int]):
        self.schema_name   = schema_name
        self.extractor     = extractor
        self.section_map   = section_order_map
        self.fields: list[FieldDef] = []
        self._occurrence_counter: dict[str, int] = {}
        self._section_field_counter: dict[str, int] = {}

    # ── Public entry point ────────────────────────────────────────────

    def walk(self, node: dict | list, path: str, section: str,
             in_array_template: bool = False) -> None:
        if isinstance(node, dict):
            for key, value in node.items():
                child_path    = f"{path}.{key}" if path else key
                child_section = key if (path == self.schema_name
                                        or path == "") else section
                self._process_node(
                    key, value, child_path, child_section, in_array_template)

    # ── Core dispatcher ───────────────────────────────────────────────

    def _process_node(self, key: str, value: Any,
                      full_path: str, section: str,
                      in_array_template: bool) -> None:

        # 1. Dict → recurse into sub-section / sub-block
        if isinstance(value, dict):
            self.walk(value, full_path, section, in_array_template)
            return

        # 2. List → array field
        if isinstance(value, list):
            self._handle_array(key, value, full_path, section, in_array_template)
            return

        # 3. Scalar (None/null, bool, int, str) → leaf field
        self._register_leaf(key, value, full_path, section, in_array_template)

    # ── Array handler ─────────────────────────────────────────────────

    def _handle_array(self, key: str, value: list,
                       full_path: str, section: str,
                       in_array_template: bool) -> None:
        occurrence = self._bump_occurrence(key)
        meta = self.extractor.get(key, occurrence)

        # Register the array container itself
        itype = 'array'
        enum_vals = extract_enum_values(meta) if meta.enum_hint else None

        f = self._build_field(
            field_path     = full_path,
            section        = section,
            meta           = meta,
            json_value     = value,
            input_type     = itype,
            enum_values    = enum_vals,
        )
        self.fields.append(f)

        # If the array contains objects, recurse into the template
        if value and isinstance(value[0], dict):
            template_path = full_path + "[]"
            self.walk(value[0], template_path, section, in_array_template=True)

    # ── Leaf field registration ───────────────────────────────────────

    def _register_leaf(self, key: str, value: Any,
                        full_path: str, section: str,
                        in_array_template: bool) -> None:
        occurrence = self._bump_occurrence(key)
        meta = self.extractor.get(key, occurrence)

        itype = infer_input_type(key, value, meta)
        enum_vals = extract_enum_values(meta) if itype == 'enum' else None

        f = self._build_field(
            field_path  = full_path,
            section     = section,
            meta        = meta,
            json_value  = value,
            input_type  = itype,
            enum_values = enum_vals,
        )
        self.fields.append(f)

    # ── FieldDef builder ──────────────────────────────────────────────

    def _build_field(self, field_path: str, section: str, meta: FieldMeta,
                      json_value: Any, input_type: str,
                      enum_values: Optional[list[str]] = None) -> FieldDef:

        # Fully qualified field_path: prepend schema_name if not present
        if not field_path.startswith(self.schema_name):
            fqpath = f"{self.schema_name}.{field_path}"
        else:
            fqpath = field_path

        # Friendly label
        label = (LABEL_OVERRIDES.get(fqpath)
                 or meta.friendly_label
                 or humanize(field_path.split('.')[-1].replace('[]', '')))
        label = label[:200]  # DB column width safety

        # ENABLED IF gate — use GATE_OVERRIDES first, then auto-parsed
        if fqpath in GATE_OVERRIDES:
            gate = GATE_OVERRIDES[fqpath]
        elif meta.enabled_if_raw:
            gate = parse_enabled_if(meta.enabled_if_raw, self.schema_name, section)
        else:
            gate = None

        # section_order from map; fallback to 999
        sec_order = self.section_map.get(section, 999)

        # wizard_order: local counter per section
        wiz_key  = f"{self.schema_name}.{section}"
        wiz_idx  = self._section_field_counter.get(wiz_key, 0) + 1
        self._section_field_counter[wiz_key] = wiz_idx

        # Default value: use JSON value only if it's not null
        default_val = json_value if (json_value is not None
                                     and not isinstance(json_value, (dict, list))) \
                      else None

        return FieldDef(
            field_path     = fqpath,
            schema_name    = self.schema_name,
            section        = section,
            classification = meta.classification,
            friendly_label = label,
            input_type     = input_type,
            enum_values    = enum_values,
            enabled_if     = gate,
            default_value  = default_val,
            default_label  = None,
            wizard_order   = wiz_idx,
            section_order  = sec_order,
        )

    # ── Occurrence tracker (disambiguates duplicate field names) ──────

    def _bump_occurrence(self, fname: str) -> int:
        count = self._occurrence_counter.get(fname, 0)
        self._occurrence_counter[fname] = count + 1
        return count


# ══════════════════════════════════════════════════════════════════════
# SQL GENERATOR
# ══════════════════════════════════════════════════════════════════════

def _pg_literal(v: Any) -> str:
    """Render a Python value as a PostgreSQL literal."""
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, str):
        escaped = v.replace("'", "''")
        return f"'{escaped}'"
    # dict / list → JSONB
    escaped = json.dumps(v).replace("'", "''")
    return f"'{escaped}'::jsonb"


def _jsonb_or_null(v: Any) -> str:
    if v is None:
        return 'NULL'
    escaped = json.dumps(v).replace("'", "''")
    return f"'{escaped}'::jsonb"


def field_to_upsert(f: FieldDef) -> str:
    """
    Render a FieldDef as a PostgreSQL INSERT … ON CONFLICT DO UPDATE
    (UPSERT). This is idempotent — re-running the seeder updates
    all columns except field_path (the PK).
    """
    enum_json   = _jsonb_or_null(f.enum_values)
    gate_json   = _jsonb_or_null(f.enabled_if)
    default_val = _jsonb_or_null(f.default_value)
    default_lbl = _pg_literal(f.default_label)

    return (
        f"INSERT INTO field_registry\n"
        f"  (field_path, schema_name, section, classification,\n"
        f"   friendly_label, input_type, enum_values, enabled_if,\n"
        f"   default_value, default_label, wizard_order, section_order)\n"
        f"VALUES (\n"
        f"  '{f.field_path}',\n"
        f"  '{f.schema_name}',\n"
        f"  '{f.section}',\n"
        f"  '{f.classification}',\n"
        f"  {_pg_literal(f.friendly_label)},\n"
        f"  '{f.input_type}',\n"
        f"  {enum_json},\n"
        f"  {gate_json},\n"
        f"  {default_val},\n"
        f"  {default_lbl},\n"
        f"  {f.wizard_order},\n"
        f"  {f.section_order}\n"
        f")\n"
        f"ON CONFLICT (field_path) DO UPDATE SET\n"
        f"  schema_name    = EXCLUDED.schema_name,\n"
        f"  section        = EXCLUDED.section,\n"
        f"  classification = EXCLUDED.classification,\n"
        f"  friendly_label = EXCLUDED.friendly_label,\n"
        f"  input_type     = EXCLUDED.input_type,\n"
        f"  enum_values    = EXCLUDED.enum_values,\n"
        f"  enabled_if     = EXCLUDED.enabled_if,\n"
        f"  default_value  = EXCLUDED.default_value,\n"
        f"  default_label  = EXCLUDED.default_label,\n"
        f"  wizard_order   = EXCLUDED.wizard_order,\n"
        f"  section_order  = EXCLUDED.section_order;\n"
    )


# ══════════════════════════════════════════════════════════════════════
# VALIDATION
# ══════════════════════════════════════════════════════════════════════

def validate_fields(fields: list[FieldDef]) -> list[str]:
    """
    Run sanity checks on the extracted field list.
    Returns a list of warning strings (empty = clean).
    """
    warnings: list[str] = []
    paths = [f.field_path for f in fields]

    # Duplicate paths
    seen: set[str] = set()
    for p in paths:
        if p in seen:
            warnings.append(f"DUPLICATE field_path: {p}")
        seen.add(p)

    for f in fields:
        # classification must be one of the four
        if f.classification not in ('REQUIRED', 'CONDITIONAL', 'OPTIONAL', 'DERIVED'):
            warnings.append(
                f"UNKNOWN classification '{f.classification}' on {f.field_path}")

        # input_type must match field_registry CHECK constraint
        valid_types = {'integer', 'boolean', 'enum', 'date', 'currency',
                       'string', 'array'}
        if f.input_type not in valid_types:
            warnings.append(
                f"INVALID input_type '{f.input_type}' on {f.field_path}")

        # CONDITIONAL fields should have an enabled_if gate
        if (f.classification == 'CONDITIONAL'
                and f.enabled_if is None
                and not f.field_path.endswith('[]')):
            warnings.append(
                f"CONDITIONAL field missing enabled_if gate: {f.field_path}")

        # flag unparsed gates for manual review
        if f.enabled_if and isinstance(f.enabled_if, dict):
            if f.enabled_if.get('_parse_error'):
                warnings.append(
                    f"UNPARSED gate on {f.field_path}: "
                    f"{f.enabled_if.get('_raw','')}")
            if 'and' in f.enabled_if:
                for clause in f.enabled_if['and']:
                    if isinstance(clause, dict) and clause.get('_parse_error'):
                        warnings.append(
                            f"UNPARSED AND-clause on {f.field_path}: "
                            f"{clause.get('_raw','')}")

    return warnings


# ══════════════════════════════════════════════════════════════════════
# CHECKSUM HELPERS
# ══════════════════════════════════════════════════════════════════════

def file_sha256(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


# ══════════════════════════════════════════════════════════════════════
# MAIN ORCHESTRATOR
# ══════════════════════════════════════════════════════════════════════

def main(dry_run: bool = False,
         output_path: Path = DEFAULT_OUTPUT,
         checksum_only: bool = False) -> None:

    print("══════════════════════════════════════════════════")
    print("  WISING Field Registry Seeder")
    print("══════════════════════════════════════════════════")

    # 1. Checksum source files
    checksums: dict[str, str] = {}
    for schema_name, path in SCHEMA_FILES.items():
        if not path.exists():
            print(f"[ERROR] Schema file not found: {path}", file=sys.stderr)
            sys.exit(1)
        checksums[schema_name] = file_sha256(path)
        print(f"  {schema_name:15s}  sha256={checksums[schema_name][:16]}…  {path.name}")

    if checksum_only:
        return

    # 2. Walk each schema and collect FieldDefs
    all_fields: list[FieldDef] = []

    for schema_name, path in SCHEMA_FILES.items():
        print(f"\n  Parsing {path.name}…")
        parsed_json, raw_text = load_jsonc(path)
        extractor = CommentExtractor(raw_text)
        walker = SchemaWalker(
            schema_name       = schema_name,
            extractor         = extractor,
            section_order_map = SECTION_ORDER_MAPS[schema_name],
        )

        # For Layer 0 the whole document IS the section.
        # For Layer 1 the top-level keys are section names.
        if schema_name == "layer0":
            # All layer0 fields are in one implicit section
            for key, value in parsed_json.items():
                full_path = f"layer0.{key}"
                walker._process_node(
                    key=key, value=value,
                    full_path=full_path,
                    section="jurisdiction_router",
                    in_array_template=False,
                )
        else:
            # Top-level keys = sections
            for section_key, section_value in parsed_json.items():
                if isinstance(section_value, dict):
                    walker.walk(
                        section_value,
                        path=f"{schema_name}.{section_key}",
                        section=section_key,
                    )
                elif isinstance(section_value, list):
                    walker._handle_array(
                        key=section_key,
                        value=section_value,
                        full_path=f"{schema_name}.{section_key}",
                        section=section_key,
                        in_array_template=False,
                    )
                else:
                    walker._register_leaf(
                        key=section_key,
                        value=section_value,
                        full_path=f"{schema_name}.{section_key}",
                        section=section_key,
                        in_array_template=False,
                    )

        print(f"    → {len(walker.fields)} fields extracted")
        all_fields.extend(walker.fields)

    print(f"\n  Total fields extracted: {len(all_fields)}")

    # 3. Validate
    print("\n  Running validation…")
    warnings = validate_fields(all_fields)
    if warnings:
        print(f"  ⚠  {len(warnings)} warnings:")
        for w in warnings:
            print(f"     • {w}")
    else:
        print("  ✓  No validation warnings.")

    # 4. Summary by schema + classification
    from collections import Counter
    summary: dict[str, Counter] = {}
    for f in all_fields:
        summary.setdefault(f.schema_name, Counter())
        summary[f.schema_name][f.classification] += 1
    print("\n  Field census:")
    for schema, counts in summary.items():
        total = sum(counts.values())
        print(f"    {schema:15s}  REQ={counts['REQUIRED']:3d}  "
              f"COND={counts['CONDITIONAL']:3d}  "
              f"OPT={counts['OPTIONAL']:3d}  "
              f"DERIV={counts['DERIVED']:3d}  "
              f"TOTAL={total:3d}")

    # 5. Build SQL output
    lines: list[str] = []
    lines.append("-- ══════════════════════════════════════════════════════════════")
    lines.append("-- WISING Field Registry Seed  (AUTO-GENERATED — DO NOT EDIT)")
    lines.append("-- Run `python seed_registry.py` to regenerate.")
    lines.append("--")
    lines.append("-- Source file checksums:")
    for schema_name, sha in checksums.items():
        lines.append(f"--   {schema_name}: {sha}")
    lines.append("--")
    lines.append(f"-- Total fields: {len(all_fields)}")
    lines.append("-- ══════════════════════════════════════════════════════════════")
    lines.append("")

    # ── GAP-001 fix: add enum_values column if missing ────────────────
    lines.append("-- GAP-001 FIX: Add enum_values column if not present.")
    lines.append("-- Run this once before the first seed; idempotent.")
    lines.append("ALTER TABLE field_registry")
    lines.append("  ADD COLUMN IF NOT EXISTS enum_values JSONB;")
    lines.append("")

    lines.append("BEGIN;")
    lines.append("")

    current_schema = None
    current_section = None

    for f in all_fields:
        # Section header comments for readability
        if f.schema_name != current_schema:
            current_schema = f.schema_name
            lines.append(f"-- {'═'*60}")
            lines.append(f"-- SCHEMA: {current_schema.upper()}")
            lines.append(f"-- {'═'*60}")
            current_section = None

        if f.section != current_section:
            current_section = f.section
            lines.append(f"\n-- ── Section: {current_section} (order={f.section_order}) ──")

        lines.append(field_to_upsert(f))

    lines.append("")
    lines.append("COMMIT;")
    lines.append("")
    lines.append("-- Verification query: run after seeding to confirm counts.")
    lines.append("SELECT schema_name, classification, COUNT(*) AS n")
    lines.append("FROM   field_registry")
    lines.append("GROUP  BY schema_name, classification")
    lines.append("ORDER  BY schema_name, classification;")

    sql_output = '\n'.join(lines)

    # 6. Write or print
    if dry_run:
        print("\n" + "─"*60)
        print(sql_output[:4000])
        print(f"… (truncated, full output is {len(sql_output)} chars)")
    else:
        output_path.write_text(sql_output, encoding='utf-8')
        print(f"\n  ✓ Written to: {output_path}")
        print(f"    Size: {len(sql_output):,} bytes / ~{len(all_fields)} UPSERTs")

    # 7. Emit warnings summary for CI
    if warnings:
        print(f"\n  ⚠  {len(warnings)} warnings require human review before deploy.")
        print("     Search the output SQL for '_parse_error' to find unparsed gates.")
        sys.exit(1)
    else:
        print("\n  ✓ Seeder completed cleanly. Ready for Antigravity deploy.")


# ══════════════════════════════════════════════════════════════════════
# CLI ENTRY POINT
# ══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="WISING Field Registry Seeder — populates field_registry from JSONC schemas"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Print first 4000 chars of SQL to stdout instead of writing file"
    )
    parser.add_argument(
        "--output", type=Path, default=DEFAULT_OUTPUT,
        help=f"Output SQL file path (default: {DEFAULT_OUTPUT})"
    )
    parser.add_argument(
        "--checksum-only", action="store_true",
        help="Only print file checksums and exit"
    )
    args = parser.parse_args()
    main(
        dry_run       = args.dry_run,
        output_path   = args.output,
        checksum_only = args.checksum_only,
    )
