// Wising Tax Engine — Shared TypeScript Types
// Mirrors Python Pydantic models exactly.

export type Jurisdiction = "india_only" | "us_only" | "dual" | "none";
export type IndiaLock = "NR" | "RNOR" | "ROR";
export type USLock = "US_CITIZEN" | "RESIDENT_ALIEN" | "NON_RESIDENT_ALIEN" | "DUAL_STATUS";
export type WizardPhase =
  | "layer0_wizard"
  | "layer0_complete"
  | "india_residency"
  | "us_residency"
  | "india_locked"
  | "us_locked"
  | "income_sections"
  | "ready_to_evaluate"
  | "jurisdiction_none";

export type InputType = "integer" | "boolean" | "enum" | "date" | "currency" | "string" | "array";
export type Classification = "REQUIRED" | "CONDITIONAL" | "OPTIONAL" | "DERIVED";

export interface FieldDef {
  field_path: string;
  schema_name: "layer0" | "layer1_india" | "layer1_us";
  section: string;
  classification: Classification;
  friendly_label: string;
  input_type: InputType;
  enum_values?: string[];
  enabled_if?: Record<string, unknown>;
  default_value?: unknown;
  wizard_order: number;
  section_order: number;
}

export interface Completion {
  percentage: number;
  filled_required: number;
  total_required: number;
  is_approximation: boolean;
  filing_ready: boolean;
  missing_required?: string[];
}

export interface LockChangeAlert {
  type: string;
  previous_india_lock: IndiaLock | null;
  new_india_lock: IndiaLock | null;
  previous_us_lock: USLock | null;
  new_us_lock: USLock | null;
  message: string;
}

export interface SessionResponse {
  session_id: string;
  tax_year_id: string;
  wizard_phase: WizardPhase;
  completion: Completion;
  next_required_fields: FieldRef[];
}

export interface FieldRef {
  field_path: string;
  friendly_label: string;
  input_type: InputType;
  section: string;
}

export interface PatchResponse {
  session_id: string;
  tax_year_id: string;
  jurisdiction: Jurisdiction | null;
  india_lock: IndiaLock | null;
  us_lock: USLock | null;
  wizard_phase: WizardPhase;
  lock_changed: boolean;
  lock_change_alert: LockChangeAlert | null;
  completion: Completion;
  tax_estimate_stale: boolean;
  next_required_fields: FieldRef[];
}

export interface AdvisoryCard {
  card_id: string;
  title: string;
  description: string;
  severity: "Critical" | "High" | "Medium" | "Low";
  category: string;
}

export interface EvaluateResponse {
  status: "APPROXIMATION" | "FINAL";
  session_id: string;
  completion_pct: number;
  india_tax: Record<string, unknown>;
  us_tax: Record<string, unknown>;
  advisory_cards: AdvisoryCard[];
  missing_for_final: { field: string; label: string }[];
}

export interface WizardSession {
  session_id: string;
  tax_year_id: string;
  jurisdiction: Jurisdiction | null;
  india_lock: IndiaLock | null;
  us_lock: USLock | null;
  wizard_phase: WizardPhase;
  completion: Completion;
  fields: FieldDef[];
  answers: Record<string, unknown>;
}
