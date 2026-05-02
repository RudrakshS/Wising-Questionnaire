"use client";

import { useState } from "react";
import type { FieldDef } from "@/types/schema";

// ── Custom enum display labels ──────────────────────────────────────
// Maps raw enum values to user-friendly display labels
const ENUM_DISPLAY: Record<string, string> = {
  // Exempt individual status (US SPT)
  none: "None",
  f_student: "F-1 Student",
  j_scholar: "J-1 Research Scholar / Teacher",
  g_diplomat: "G-1 Diplomat",
  professional_athlete: "P-1A Professional Athlete",
  // Filing status
  single: "Single",
  mfj: "Married Filing Jointly",
  mfs: "Married Filing Separately",
  hoh: "Head of Household",
  qss: "Qualifying Surviving Spouse",
  // SSN/ITIN type
  ssn: "SSN",
  itin: "ITIN",
  // India bank account types
  NRE: "NRE",
  NRO: "NRO",
  FCNR: "FCNR",
  RFC: "RFC",
  GIFT_IFSC: "GIFT IFSC",
  SAVINGS: "Savings",
  CURRENT: "Current",
  // US bank account types
  checking: "Checking",
  savings: "Savings",
  money_market: "Money Market",
  cd: "Certificate of Deposit",
  brokerage_cash: "Brokerage Cash",
  nro: "NRO",
  nre: "NRE",
  fcnr: "FCNR",
  rfc: "RFC",
  // Employment/crew status
  employed_abroad: "Employed Abroad",
  indian_ship_crew: "Indian Ship Crew",
  foreign_ship_crew: "Foreign Ship Crew",
  // Tax regime
  NEW: "New Tax Regime",
  OLD: "Old Tax Regime",
  // FEIE qualification
  physical_presence: "Physical Presence Test",
  bona_fide_residence: "Bona Fide Residence Test",
  // Standard/Itemized
  standard: "Standard Deduction",
  itemized: "Itemized Deductions",
  auto: "Auto (Engine picks best)",
  // DTAA income types
  interest: "Interest Income",
  dividend: "Dividend Income",
  royalty: "Royalty Income",
  fts: "Fees for Technical Services",
  capital_gains: "Capital Gains",
  // Property types
  residential: "Residential",
  commercial: "Commercial",
  land: "Land",
  agricultural_rural: "Agricultural / Rural (Exempt)",
  under_construction: "Under Construction",
  // Country codes
  US: "United States",
  AE: "UAE",
  GB: "United Kingdom",
  SG: "Singapore",
  CA: "Canada",
  AU: "Australia",
  DE: "Germany",
  FR: "France",
  NL: "Netherlands",
  CH: "Switzerland",
  JP: "Japan",
  HK: "Hong Kong",
  NZ: "New Zealand",
  IE: "Ireland",
  SE: "Sweden",
  IN: "India",
};

// ── Info tooltips for terms marked with ⓘ ──────────────────────────
const INFO_HINTS: Record<string, string> = {
  "trc_status": "A Tax Residency Certificate (TRC) is a certificate issued by the government of your country of residence, confirming you are a tax resident there. Required to claim treaty benefits under DTAA.",
  "has_permanent_establishment_in_india": "A Permanent Establishment (PE) is a fixed place of business — such as an office, branch, factory, or dependent agent — through which you conduct business in India.",
  "mfn_clause_invoked": "The Most Favoured Nation (MFN) clause allows you to benefit from a lower treaty rate that India has granted to another OECD country. Applicable for treaties with Netherlands, France, Switzerland, etc.",
  "trc.validity_start_date": "TRC = Tax Residency Certificate. This is issued by your country of residence. Enter the start date printed on the certificate.",
  "form_10f.is_filed": "Form 10F is a self-declaration form required by Indian income tax law for claiming DTAA benefits. PAN holders must file it electronically on the IT e-filing portal.",
  "section_197_cert.is_available": "A lower TDS certificate (under Section 197 of the Income Tax Act) allows you to receive income with reduced TDS instead of the standard rate. Apply via Form 13 on the IT portal.",
  "chapter_xiia_elected": "Chapter XII-A is a special tax regime for certain NRI investment income. Once elected, it is a one-way door — you cannot exit back to the normal regime (Section 115I).",
  "exempt_individual_status": "Exempt individuals include F-1 students (first 5 calendar years), J-1 research scholars/teachers (2 of last 6 years), G-series diplomats, and P-1A professional athletes. Days as exempt do NOT count toward the Substantial Presence Test.",
  "closer_connection_claim": "The Closer Connection Exception (Form 8840) may exempt you from being treated as a US resident even if you meet the SPT, provided you were in the US < 183 days and have a closer connection to a foreign country.",
  "first_year_choice_election": "This election allows you to voluntarily be treated as a US resident for part of the year. You would use this if you know you will become a Resident Alien next year and want to start residency earlier.",
  "s6013g_joint_election": "This election allows a non-resident alien spouse to be treated as a US resident for the purpose of filing a joint return (MFJ). Once made, it applies to all future years unless revoked.",
};

interface FieldInputProps {
  field: FieldDef;
  value: unknown;
  isLoading: boolean;
  onCommit: (value: unknown) => void;
}

export function FieldInput({ field, value, isLoading, onCommit }: FieldInputProps) {
  if (isLoading) return <span className="spinner" />;
  return <InputRenderer field={field} value={value} onCommit={onCommit} />;
}

function InputRenderer({ field, value, onCommit }: {
  field: FieldDef; value: unknown; onCommit: (v: unknown) => void;
}) {
  switch (field.input_type) {
    case "boolean":
      return (
        <div className="input-boolean">
          <button id={`${field.field_path}-yes`}
            className={`btn-choice ${value === true ? "selected" : ""}`}
            onClick={() => onCommit(true)}>
            Yes
          </button>
          <button id={`${field.field_path}-no`}
            className={`btn-choice ${value === false ? "selected" : ""}`}
            onClick={() => onCommit(false)}>
            No
          </button>
        </div>
      );

    case "integer":
      return <IntegerInput fieldPath={field.field_path} value={value as number | null} onCommit={onCommit} />;

    case "enum":
      if (!field.enum_values) return null;
      return (
        <div className="input-enum">
          {field.enum_values.map((opt) => (
            <button key={opt} id={`${field.field_path}-${opt}`}
              className={`btn-enum ${value === opt ? "selected" : ""}`}
              onClick={() => onCommit(opt)}>
              {ENUM_DISPLAY[opt] ?? formatEnumLabel(opt)}
            </button>
          ))}
        </div>
      );

    case "date":
      return (
        <input id={field.field_path} type="date" className="input-text"
          style={{ maxWidth: 220 }} defaultValue={(value as string) ?? ""}
          onBlur={(e) => e.target.value && onCommit(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter") { const v = (e.target as HTMLInputElement).value; if (v) onCommit(v); }}}
        />
      );

    case "currency":
      return (
        <div className="input-number">
          <input id={field.field_path} type="number" min={0}
            placeholder="0" defaultValue={(value as number) ?? ""}
            onBlur={(e) => { const n = parseFloat(e.target.value); if (!isNaN(n)) onCommit(n); }}
            onKeyDown={(e) => { if (e.key === "Enter") { const n = parseFloat((e.target as HTMLInputElement).value); if (!isNaN(n)) onCommit(n); }}}
          />
          <span className="input-unit">{field.field_path.includes("_usd") ? "USD" : "₹"}</span>
        </div>
      );

    case "string":
    default:
      return (
        <input id={field.field_path} type="text" className="input-text"
          placeholder="Type your answer…" defaultValue={(value as string) ?? ""}
          onBlur={(e) => e.target.value && onCommit(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter") { const v = (e.target as HTMLInputElement).value; if (v) onCommit(v); }}}
        />
      );
  }
}

function IntegerInput({ fieldPath, value, onCommit }: {
  fieldPath: string; value: number | null; onCommit: (v: unknown) => void;
}) {
  const [local, setLocal] = useState<string>(value != null ? String(value) : "");
  const isDay = fieldPath.includes("days") || fieldPath.includes("day");
  const isINR = fieldPath.includes("_inr");
  const isUSD = fieldPath.includes("_usd");
  const unit = isDay ? "days" : isINR ? "INR" : isUSD ? "USD" : "";

  return (
    <div className="input-number">
      <input id={fieldPath} type="number" min={0}
        max={isDay ? 366 : undefined}
        placeholder={isDay ? "0" : "0"}
        value={local}
        onChange={(e) => setLocal(e.target.value)}
        onBlur={() => { const n = parseInt(local, 10); if (!isNaN(n)) onCommit(n); }}
        onKeyDown={(e) => { if (e.key === "Enter") { const n = parseInt(local, 10); if (!isNaN(n)) onCommit(n); }}}
      />
      {unit && <span className="input-unit">{unit}</span>}
    </div>
  );
}

function formatEnumLabel(val: string): string {
  return val.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

/** Extract info hint key from field label (matches text after ⓘ marker) or field_path suffix */
export function getInfoHint(field: FieldDef): string | null {
  // Check by field path suffix first
  for (const [key, hint] of Object.entries(INFO_HINTS)) {
    if (field.field_path.endsWith(key)) return hint;
  }
  return null;
}
