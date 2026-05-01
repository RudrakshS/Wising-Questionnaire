"use client";

import type { AdvisoryCard } from "@/types/schema";

interface AdvisoryPanelProps {
  cards: AdvisoryCard[];
}

const SEVERITY_ICON: Record<string, string> = {
  Critical: "🚨",
  High: "⚠️",
  Medium: "ℹ️",
  Low: "💡",
};

export function AdvisoryPanel({ cards }: AdvisoryPanelProps) {
  if (cards.length === 0) {
    return (
      <div>
        <div className="panel-section-title">Advisory Cards</div>
        <div style={{ color: "var(--text-muted)", fontSize: "0.82rem", textAlign: "center", padding: "20px 0" }}>
          Run Advisory Check to see cross-border compliance alerts.
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="panel-section-title">
        Advisory Cards ({cards.length})
      </div>
      {cards.map((card) => (
        <div key={card.card_id} className={`advisory-card ${card.severity}`}>
          <div className="advisory-card-title">
            {SEVERITY_ICON[card.severity] ?? "•"} {card.title}
          </div>
          <div className="advisory-card-body">{card.description}</div>
        </div>
      ))}
    </div>
  );
}
