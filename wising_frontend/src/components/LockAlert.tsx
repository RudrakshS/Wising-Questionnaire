"use client";

import type { PatchResponse } from "@/types/schema";

interface LockAlertProps {
  alert: PatchResponse["lock_change_alert"];
  onDismiss: () => void;
}

export function LockAlert({ alert, onDismiss }: LockAlertProps) {
  if (!alert) return null;

  const isIndiaChange = alert.previous_india_lock !== alert.new_india_lock;
  const isUSChange = alert.previous_us_lock !== alert.new_us_lock;

  return (
    <div className="lock-alert-overlay" onClick={onDismiss}>
      <div className="lock-alert-card" onClick={(e) => e.stopPropagation()}>
        <div className="lock-alert-icon">⚠️</div>
        <div className="lock-alert-title">Residency Status Changed</div>
        <div className="lock-alert-body">{alert.message}</div>

        {isIndiaChange && (
          <div className="lock-change-row">
            <span style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>🇮🇳 India</span>
            <span className="lock-change-from">{alert.previous_india_lock ?? "—"}</span>
            <span className="lock-change-arrow">→</span>
            <span className="lock-change-to">{alert.new_india_lock}</span>
          </div>
        )}
        {isUSChange && (
          <div className="lock-change-row">
            <span style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>🇺🇸 US</span>
            <span className="lock-change-from">{alert.previous_us_lock ?? "—"}</span>
            <span className="lock-change-arrow">→</span>
            <span className="lock-change-to">{alert.new_us_lock}</span>
          </div>
        )}

        <button className="btn-dismiss" id="btn-dismiss-lock-alert" onClick={onDismiss}>
          Understood — Continue
        </button>
      </div>
    </div>
  );
}
