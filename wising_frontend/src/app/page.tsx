"use client";

import { useState } from "react";
import { api } from "@/lib/api";
import { WizardShell } from "@/components/WizardShell";
import type { SessionResponse } from "@/types/schema";

export default function Home() {
  const [loading, setLoading] = useState(false);
  const [session, setSession] = useState<SessionResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function startSession() {
    setLoading(true);
    setError(null);
    try {
      const userId = crypto.randomUUID();
      const res = await api.createSession(userId, "FY2025-26");
      setSession(res);
    } catch (e: unknown) {
      setError((e as Error).message ?? "Failed to connect to backend");
    } finally {
      setLoading(false);
    }
  }

  if (session) return <WizardShell session={session} />;

  return (
    <div className="app-shell">
      <div className="topbar">
        <div className="topbar-left">
          <div className="topbar-brand">
            <div className="brand-mark">W</div>
            Wising
          </div>
        </div>
        <div className="topbar-right">
          <span className="topbar-pill" style={{ color: "var(--accent)" }}>FY 2025-26</span>
        </div>
      </div>

      <div className="landing">
        {/* Ambient glows */}
        <div className="landing-glow" style={{ top: "20%", left: "30%", background: "rgba(20,184,166,0.06)" }} />
        <div className="landing-glow" style={{ top: "60%", right: "20%", background: "rgba(139,92,246,0.05)" }} />

        <h1>Cross-Border<br />Tax Intelligence</h1>
        <p>
          Deterministic residency classification, compliance advisory, and
          filing-ready computation for NRIs and US persons with India income.
        </p>

        <div className="landing-features">
          {[
            { icon: "🇮🇳", title: "RS-001", sub: "19-path India residency" },
            { icon: "🇺🇸", title: "SPT Engine", sub: "5-priority US status" },
            { icon: "🔗", title: "DTAA", sub: "Cross-border compliance" },
          ].map((f) => (
            <div key={f.title} className="landing-feature">
              <div className="icon">{f.icon}</div>
              <div className="title">{f.title}</div>
              <div className="sub">{f.sub}</div>
            </div>
          ))}
        </div>

        {error && <div className="error-banner">⚠ {error}</div>}

        <button id="btn-start-session" className="btn-start" onClick={startSession} disabled={loading}>
          {loading ? (
            <span style={{ display: "flex", alignItems: "center", gap: 8 }}>
              <span className="spinner" /> Connecting…
            </span>
          ) : "Begin Tax Filing →"}
        </button>
        <p style={{ marginTop: 16, fontSize: "0.72rem", color: "var(--text-muted)", maxWidth: 400 }}>
          Layer 2 computation engine is pending architect review.
          Residency classification and advisory cards are fully operational.
        </p>
      </div>
    </div>
  );
}
