// Wising Tax Engine — Typed API client
import type {
  SessionResponse,
  PatchResponse,
  EvaluateResponse,
  FieldDef,
} from "@/types/schema";

const BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...init,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ detail: res.statusText }));
    throw Object.assign(new Error(err.detail ?? "API error"), { status: res.status, body: err });
  }
  return res.json() as Promise<T>;
}

export const api = {
  /** POST /api/session — create or resume session */
  createSession(user_id: string, tax_year: string): Promise<SessionResponse> {
    return request("/api/session", {
      method: "POST",
      body: JSON.stringify({ user_id, tax_year, timezone: "Asia/Kolkata" }),
    });
  },

  /** PATCH /api/profile/{session_id}/{tax_year_id} — patch one field */
  patchField(
    session_id: string,
    tax_year_id: string,
    field_schema: string,
    field_path: string,
    value: unknown
  ): Promise<PatchResponse> {
    return request(`/api/profile/${session_id}/${tax_year_id}`, {
      method: "PATCH",
      body: JSON.stringify({ field_schema, field_path, value }),
    });
  },

  /** PATCH /api/profile — batch patch */
  patchBatch(
    session_id: string,
    tax_year_id: string,
    patches: { field_schema: string; field_path: string; value: unknown }[]
  ): Promise<PatchResponse> {
    return request(`/api/profile/${session_id}/${tax_year_id}`, {
      method: "PATCH",
      body: JSON.stringify({ patches }),
    });
  },

  /** GET /api/wizard/schema */
  getSchema(jurisdiction?: string): Promise<{ fields: FieldDef[]; total: number }> {
    const q = jurisdiction ? `?jurisdiction=${jurisdiction}` : "";
    return request(`/api/wizard/schema${q}`);
  },

  /** POST /api/evaluate/{session_id}/{tax_year_id} */
  evaluate(session_id: string, tax_year_id: string): Promise<EvaluateResponse> {
    return request(`/api/evaluate/${session_id}/${tax_year_id}`, { method: "POST" });
  },
};
