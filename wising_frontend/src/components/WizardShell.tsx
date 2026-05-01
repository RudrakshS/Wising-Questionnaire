"use client";
import { useState, useEffect, useCallback, useRef } from "react";
import { api } from "@/lib/api";
import { evaluateGate } from "@/lib/gates";
import { FieldInput } from "@/components/FieldInput";
import { LockAlert } from "@/components/LockAlert";
import { AdvisoryPanel } from "@/components/AdvisoryPanel";
import type {
  SessionResponse, FieldDef, PatchResponse,
  WizardSession, EvaluateResponse,
} from "@/types/schema";

/* ── Section display names ─────────────────────────────────────── */
const SEC_NAME: Record<string, string> = {
  jurisdiction_router: "Jurisdiction Setup",
  residency_detail: "Residency Detail", profile: "Profile", metadata: "Metadata",
  domestic_income: "Domestic Income", other_sources: "Other Sources",
  deductions: "Deductions", property: "Property",
  financial_holdings: "Financial Holdings", bank_accounts: "Bank Accounts",
  dtaa: "DTAA / Treaty", tax_credits: "Tax Credits",
  carry_forward_losses: "Carry-forward Losses", compliance_docs: "Compliance Docs",
  lrs_outbound: "LRS / Foreign Assets", nro_repatriation: "NRO Repatriation",
  unlisted_equity: "Unlisted Equity", commodities: "Commodities",
  share_buyback: "Share Buyback", surcharge_buckets: "Surcharge",
  us_residency_detail: "US Residency", state_residency: "State Residency",
  income_us_source: "US Income", income_foreign_source: "Foreign Income",
  foreign_earned_income: "FEIE", equity_compensation: "Equity Comp",
  real_estate: "Real Estate", foreign_entities: "Foreign Entities",
  foreign_gifts_and_trusts: "Foreign Gifts & Trusts",
  ftc_inputs: "FTC", fbar_aggregate_peak_usd: "FBAR",
  form_8938_required: "FATCA", nra_specific: "NRA-Specific",
  withholding_and_estimated: "Withholding", niit_inputs: "NIIT", amt_inputs: "AMT",
  itemized_deductions_and_credits: "Deductions & Credits",
  retirement_accounts: "Retirement",
};

interface Props { session: SessionResponse }

export function WizardShell({ session }: Props) {
  const [ws, setWs] = useState<WizardSession>({
    session_id: session.session_id, tax_year_id: session.tax_year_id,
    jurisdiction: null, india_lock: null, us_lock: null,
    wizard_phase: session.wizard_phase, completion: session.completion,
    fields: [], answers: {},
  });
  const [lockAlert, setLockAlert] = useState<PatchResponse["lock_change_alert"] | null>(null);
  const [patching, setPatching] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [advisoryResult, setAdvisoryResult] = useState<EvaluateResponse | null>(null);
  const [showAdvisory, setShowAdvisory] = useState(false);
  const [navOpen, setNavOpen] = useState(false);
  const [qIndex, setQIndex] = useState(0);
  const [animating, setAnimating] = useState(false);
  const stageRef = useRef<HTMLDivElement>(null);

  // Load schema
  useEffect(() => {
    api.getSchema().then((d) => setWs((p) => ({ ...p, fields: d.fields }))).catch(console.error);
  }, []);
  useEffect(() => {
    if (!ws.jurisdiction) return;
    api.getSchema(ws.jurisdiction).then((d) => setWs((p) => ({ ...p, fields: d.fields }))).catch(console.error);
  }, [ws.jurisdiction]);

  // Build gate context
  const ctx: Record<string, Record<string, unknown>> = { layer0: {}, layer1_india: {}, layer1_us: {} };
  Object.entries(ws.answers).forEach(([path, val]) => {
    const parts = path.split(".");
    const schema = parts[0];
    if (schema in ctx) {
      ctx[schema][parts.slice(1).join(".")] = val;
      ctx[schema][parts[parts.length - 1]] = val;
    }
  });

  // Visible questions list (no DERIVED, no array containers, gate-filtered)
  const visibleFields = (ws.fields || []).filter((f) => {
    const ctx = (ws as any).answers_context || ws.answers || {};
    const sc = (ctx as any)[f.schema_name] ?? {};
    if (!evaluateGate(f.enabled_if as Record<string, unknown>, sc)) return false;
    if (f.schema_name === "layer1_india" && ws.jurisdiction !== "india_only" && ws.jurisdiction !== "dual") return false;
    if (f.schema_name === "layer1_us" && ws.jurisdiction !== "us_only" && ws.jurisdiction !== "dual") return false;
    return true;
  });

  const currentField = visibleFields[qIndex] ?? null;
  const totalQ = visibleFields.length;
  const { percentage } = ws.completion;

  // Navigate with animation
  const goTo = useCallback((idx: number) => {
    if (animating) return;
    const target = Math.max(0, Math.min(idx, totalQ - 1));
    if (target === qIndex) return;
    setAnimating(true);
    // Trigger exit
    stageRef.current?.classList.add("exit");
    setTimeout(() => {
      setQIndex(target);
      stageRef.current?.classList.remove("exit");
      setAnimating(false);
    }, 280);
  }, [qIndex, totalQ, animating]);

  // Auto-advance after commit (for booleans/enums)
  const advance = useCallback(() => {
    if (qIndex < totalQ - 1) {
      setTimeout(() => goTo(qIndex + 1), 350);
    }
  }, [qIndex, totalQ, goTo]);

  // Commit field
  const handlePatch = useCallback(async (field: FieldDef, value: unknown) => {
    setPatching(field.field_path);
    setError(null);
    try {
      const res = await api.patchField(ws.session_id, ws.tax_year_id, field.schema_name, field.field_path, value);
      setWs((prev) => ({
        ...prev,
        jurisdiction: res.jurisdiction, india_lock: res.india_lock,
        us_lock: res.us_lock, wizard_phase: res.wizard_phase,
        completion: res.completion,
        answers: { ...prev.answers, [field.field_path]: value },
      }));
      if (res.lock_changed && res.lock_change_alert) {
        setLockAlert(res.lock_change_alert);
      }
      // Auto-advance for boolean/enum
      if (field.input_type === "boolean" || field.input_type === "enum") {
        advance();
      }
    } catch (e: unknown) {
      const body = (e as { body?: { detail?: string } }).body;
      setError(body?.detail ?? (e as Error).message ?? "Update failed");
    } finally {
      setPatching(null);
    }
  }, [ws, advance]);

  // Evaluate
  const handleEvaluate = useCallback(async () => {
    try {
      const res = await api.evaluate(ws.session_id, ws.tax_year_id);
      setAdvisoryResult(res);
      setShowAdvisory(true);
    } catch (e: unknown) {
      setError((e as Error).message ?? "Advisory check failed");
    }
  }, [ws.session_id, ws.tax_year_id]);

  // Build sidebar sections
  const sidebarSections: { key: string; schema: string; section: string; count: number; filled: number }[] = [];
  const seen = new Set<string>();
  for (const f of visibleFields) {
    const k = `${f.schema_name}::${f.section}`;
    if (seen.has(k)) {
      const s = sidebarSections.find((x) => x.key === k);
      if (s) { s.count++; if (ws.answers[f.field_path] !== undefined) s.filled++; }
      continue;
    }
    seen.add(k);
    sidebarSections.push({
      key: k, schema: f.schema_name, section: f.section,
      count: 1, filled: ws.answers[f.field_path] !== undefined ? 1 : 0,
    });
  }

  // Find question index for a section
  const jumpToSection = (sectionKey: string) => {
    const [schema, section] = sectionKey.split("::");
    const idx = visibleFields.findIndex((f) => f.schema_name === schema && f.section === section);
    if (idx >= 0) { goTo(idx); setNavOpen(false); }
  };

  // Find active section key for current question
  const activeSectionKey = currentField ? `${currentField.schema_name}::${currentField.section}` : "";

  return (
    <div className="app-shell">
      {/* Top bar */}
      <div className="topbar">
        <div className="topbar-left">
          <div className={`hamburger ${navOpen ? "open" : ""}`} onClick={() => setNavOpen(!navOpen)}>
            <span /><span /><span />
          </div>
          <div className="topbar-brand">
            <div className="brand-mark">W</div>
            Wising
          </div>
        </div>
        <div className="topbar-right">
          {ws.jurisdiction && (
            <span className={`topbar-pill ${ws.jurisdiction === "dual" ? "" : ws.jurisdiction === "india_only" ? "india" : "us"}`}>
              {ws.jurisdiction === "dual" ? "🇮🇳🇺🇸 Dual" : ws.jurisdiction === "india_only" ? "🇮🇳 India" : "🇺🇸 US"}
            </span>
          )}
          {ws.india_lock && <span className="topbar-pill india lock">IN: {ws.india_lock}</span>}
          {ws.us_lock && <span className="topbar-pill us lock">US: {ws.us_lock}</span>}
        </div>
      </div>

      {/* Progress seeker */}
      <div className="progress-seeker">
        <div className="progress-seeker-fill" style={{ width: `${percentage}%` }} />
      </div>

      {/* Slide-out nav */}
      <div className={`nav-overlay ${navOpen ? "open" : ""}`} onClick={() => setNavOpen(false)} />
      <div className={`nav-drawer ${navOpen ? "open" : ""}`}>
        <div className="nav-group-label">Setup</div>
        {sidebarSections.filter((s) => s.schema === "layer0").map((s) => (
          <div key={s.key} className={`nav-item ${activeSectionKey === s.key ? "active" : ""} ${s.filled === s.count ? "done" : ""}`}
            onClick={() => jumpToSection(s.key)}>
            <span className="nav-dot" />
            {SEC_NAME[s.section] ?? s.section}
            <span className="nav-badge">{s.filled}/{s.count}</span>
          </div>
        ))}

        {(ws.jurisdiction === "india_only" || ws.jurisdiction === "dual") && (
          <>
            <div className="nav-group-label" style={{ color: "var(--india)" }}>🇮🇳 India</div>
            {sidebarSections.filter((s) => s.schema === "layer1_india").map((s) => (
              <div key={s.key} className={`nav-item ${activeSectionKey === s.key ? "active" : ""} ${s.filled === s.count ? "done" : ""}`}
                onClick={() => jumpToSection(s.key)}>
                <span className="nav-dot" />
                {SEC_NAME[s.section] ?? s.section}
                <span className="nav-badge">{s.filled}/{s.count}</span>
              </div>
            ))}
          </>
        )}

        {(ws.jurisdiction === "us_only" || ws.jurisdiction === "dual") && (
          <>
            <div className="nav-group-label" style={{ color: "var(--us)" }}>🇺🇸 US</div>
            {sidebarSections.filter((s) => s.schema === "layer1_us").map((s) => (
              <div key={s.key} className={`nav-item ${activeSectionKey === s.key ? "active" : ""} ${s.filled === s.count ? "done" : ""}`}
                onClick={() => jumpToSection(s.key)}>
                <span className="nav-dot" />
                {SEC_NAME[s.section] ?? s.section}
                <span className="nav-badge">{s.filled}/{s.count}</span>
              </div>
            ))}
          </>
        )}

        {/* Evaluate button in nav */}
        <div style={{ padding: "20px 24px" }}>
          <button className="btn-continue" style={{ width: "100%", borderRadius: "var(--radius-sm)" }}
            disabled={percentage < 10} onClick={handleEvaluate}>
            {percentage < 10 ? `Need ${10 - percentage}% more` : "Run Advisory Check"}
          </button>
        </div>
      </div>

      {/* Lock alert */}
      {lockAlert && <LockAlert alert={lockAlert} onDismiss={() => setLockAlert(null)} />}

      {/* Advisory modal */}
      {showAdvisory && advisoryResult && (
        <div className="advisory-overlay" onClick={() => setShowAdvisory(false)}>
          <div className="advisory-modal" onClick={(e) => e.stopPropagation()}>
            <h3 style={{ fontSize: "1.1rem", fontWeight: 700, marginBottom: 4 }}>Advisory Check</h3>
            <p style={{ fontSize: "0.78rem", color: "var(--text-muted)", marginBottom: 20 }}>
              {advisoryResult.status} · {advisoryResult.completion_pct}% complete
            </p>
            {!!(advisoryResult.india_tax as any)?._stub && (
              <div style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginBottom: 16,
                padding: "10px 14px", background: "var(--surface)", borderRadius: "var(--radius-sm)" }}>
                📐 Math DAG (Layer 2) pending — advisory cards below are live.
              </div>
            )}
            <AdvisoryPanel cards={advisoryResult.advisory_cards || []} />
            <button className="btn-dismiss" style={{ marginTop: 16 }} onClick={() => setShowAdvisory(false)}>
              Close
            </button>
          </div>
        </div>
      )}

      {/* Main — one question at a time */}
      <div className="wizard-content">
        {error && (
          <div className="error-banner" style={{ cursor: "pointer" }} onClick={() => setError(null)}>
            {error} <span style={{ float: "right" }}>✕</span>
          </div>
        )}

        {currentField ? (
          <div className="question-stage" ref={stageRef} key={currentField.field_path}>
            <div className="question-meta">
              <span className="question-number">Q{qIndex + 1}/{totalQ}</span>
              <span className="question-section-label">
                {currentField.schema_name === "layer1_india" ? "🇮🇳 " : currentField.schema_name === "layer1_us" ? "🇺🇸 " : ""}
                {SEC_NAME[currentField.section] ?? currentField.section}
              </span>
              <span className={`question-classification ${currentField.classification.toLowerCase()}`}>
                {currentField.classification}
              </span>
            </div>

            <div className="question-main">{currentField.friendly_label}</div>

            <FieldInput
              field={currentField}
              value={ws.answers[currentField.field_path]}
              isLoading={patching === currentField.field_path}
              onCommit={(v) => handlePatch(currentField, v)}
            />

            <div className="question-nav">
              <button className="btn-nav btn-back" onClick={() => goTo(qIndex - 1)}
                style={{ visibility: qIndex > 0 ? "visible" : "hidden" }}>
                ← Back
              </button>
              {currentField.classification !== "REQUIRED" && (
                <button className="btn-nav btn-skip" onClick={() => goTo(qIndex + 1)}>
                  Skip for now
                </button>
              )}
              <button className="btn-nav btn-continue"
                disabled={ws.answers[currentField.field_path] === undefined && currentField.classification === "REQUIRED"}
                onClick={() => goTo(qIndex + 1)}>
                Continue →
              </button>
            </div>
          </div>
        ) : (
          <div style={{ textAlign: "center", color: "var(--text-muted)" }}>
            <div style={{ fontSize: "2.5rem", marginBottom: 12, opacity: 0.4 }}>✓</div>
            <div style={{ fontSize: "1.1rem", fontWeight: 600, color: "var(--text)", marginBottom: 8 }}>
              All questions answered
            </div>
            <div style={{ fontSize: "0.85rem", marginBottom: 24 }}>
              {percentage}% complete — run an advisory check to see compliance alerts.
            </div>
            <button className="btn-continue" style={{ padding: "14px 36px", borderRadius: "var(--radius-pill)" }}
              onClick={handleEvaluate}>
              Run Advisory Check
            </button>
          </div>
        )}
      </div>

      {/* Bottom status */}
      <div className="status-footer">
        <div className="status-chip">
          <span className="dot green" />
          <span>{percentage}%</span>
        </div>
        <span>{ws.completion.filled_required}/{ws.completion.total_required} required</span>
        {ws.india_lock && <span>India: {ws.india_lock}</span>}
        {ws.us_lock && <span>US: {ws.us_lock}</span>}
        <span style={{ color: "var(--text-muted)" }}>{ws.wizard_phase.replace(/_/g, " ")}</span>
      </div>
    </div>
  );
}
