"use client";

import { useState } from "react";
import type { FieldDef } from "@/types/schema";

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
              {formatEnumLabel(opt)}
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
