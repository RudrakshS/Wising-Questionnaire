// Wising Tax Engine — XState v5 Wizard Machine (v1.0.1-deploy)
// States mirror WizardPhase enum from Python exactly.
import { setup, assign, fromPromise } from "xstate";
import type { WizardSession, PatchResponse, FieldDef } from "@/types/schema";
import { api } from "@/lib/api";

// ── Context ───────────────────────────────────────────────────────
export interface WizardContext {
  session_id: string;
  tax_year_id: string;
  jurisdiction: string | null;
  india_lock: string | null;
  us_lock: string | null;
  completion_pct: number;
  is_approximation: boolean;
  fields: FieldDef[];
  answers: Record<string, unknown>;
  next_required: { field_path: string; friendly_label: string; input_type: string; section: string }[];
  lock_change_alert: PatchResponse["lock_change_alert"] | null;
  tax_estimate_stale: boolean;
  error: string | null;
}

// ── Events ────────────────────────────────────────────────────────
export type WizardEvent =
  | { type: "PATCH"; field_schema: string; field_path: string; value: unknown }
  | { type: "DISMISS_LOCK_ALERT" }
  | { type: "EVALUATE" }
  | { type: "RESET" };

// ── Machine ───────────────────────────────────────────────────────
export const wizardMachine = setup({
  types: {
    context: {} as WizardContext,
    events: {} as WizardEvent,
  },
  actions: {
    applyPatchResponse: assign(({ context, event }) => {
      if (!("output" in event)) return {};
      const res = (event as { output: PatchResponse }).output;
      return {
        jurisdiction: res.jurisdiction,
        india_lock: res.india_lock,
        us_lock: res.us_lock,
        completion_pct: res.completion.percentage,
        is_approximation: res.completion.is_approximation,
        lock_change_alert: res.lock_change_alert,
        tax_estimate_stale: res.tax_estimate_stale,
        next_required: res.next_required_fields,
        answers: {
          ...context.answers,
          [res.session_id]: res,
        },
        error: null,
      };
    }),
    setError: assign(({ event }) => ({
      error: String((event as any).error ?? "Unknown error"),
    })),
    dismissAlert: assign({ lock_change_alert: null }),
    clearError: assign({ error: null }),
  },
  actors: {
    patchField: fromPromise(async ({ input }: {
      input: { session_id: string; tax_year_id: string; field_schema: string; field_path: string; value: unknown }
    }) => {
      return api.patchField(input.session_id, input.tax_year_id, input.field_schema, input.field_path, input.value);
    }),
  },
  guards: {
    isJurisdictionNone: ({ context }) => context.jurisdiction === "none",
    hasIndiaJurisdiction: ({ context }) =>
      context.jurisdiction === "india_only" || context.jurisdiction === "dual",
    lockAlertPresent: ({ context }) => context.lock_change_alert !== null,
    bothLocked: ({ context }) => !!(context.india_lock && context.us_lock),
    isFilingReady: ({ context }) => context.completion_pct === 100,
  },
}).createMachine({
  id: "wising-wizard",
  initial: "layer0_wizard",
  context: ({ input }: { input?: any }) => ({
    session_id: input?.session_id ?? "",
    tax_year_id: input?.tax_year_id ?? "",
    jurisdiction: input?.jurisdiction ?? null,
    india_lock: input?.india_lock ?? null,
    us_lock: input?.us_lock ?? null,
    completion_pct: input?.completion_pct ?? 0,
    is_approximation: input?.is_approximation ?? true,
    fields: input?.fields ?? [],
    answers: input?.answers ?? {},
    next_required: input?.next_required ?? [],
    lock_change_alert: null,
    tax_estimate_stale: false,
    error: null,
  }),
  states: {
    layer0_wizard: {
      on: {
        PATCH: {
          target: "patching",
          actions: assign(({ event }) => ({ _pendingPatch: event })),
        },
      },
    },
    layer0_complete: {
      always: [
        { guard: "isJurisdictionNone", target: "jurisdiction_none" },
        { guard: "hasIndiaJurisdiction", target: "india_residency" },
        { target: "us_residency" },
      ],
    },
    india_residency: {
      on: { PATCH: "patching" },
    },
    us_residency: {
      on: { PATCH: "patching" },
    },
    india_locked: {
      on: { PATCH: "patching" },
    },
    us_locked: {
      on: { PATCH: "patching" },
    },
    income_sections: {
      on: {
        PATCH: "patching",
        EVALUATE: "evaluating",
      },
    },
    ready_to_evaluate: {
      on: { EVALUATE: "evaluating", PATCH: "patching" },
    },
    jurisdiction_none: {
      type: "final",
    },
    patching: {
      invoke: {
        src: "patchField",
        input: ({ context, event }) => {
          const e = event as Extract<WizardEvent, { type: "PATCH" }>;
          return {
            session_id: context.session_id,
            tax_year_id: context.tax_year_id,
            field_schema: e.field_schema,
            field_path: e.field_path,
            value: e.value,
          };
        },
        onDone: {
          actions: "applyPatchResponse",
          target: "routing",
        },
        onError: {
          actions: "setError",
          target: "layer0_wizard",
        },
      },
    },
    routing: {
      // Re-route based on the new wizard_phase from the server
      always: [
        { guard: ({ context }) => context.completion_pct === 100, target: "ready_to_evaluate" },
        { guard: ({ context }) => !!(context.india_lock && context.us_lock), target: "income_sections" },
        { guard: ({ context }) => !!context.india_lock && !context.us_lock, target: "us_residency" },
        { guard: ({ context }) => !context.india_lock && context.jurisdiction === "india_only", target: "india_locked" },
        { guard: ({ context }) => !!context.jurisdiction, target: "layer0_complete" },
        { target: "layer0_wizard" },
      ],
    },
    evaluating: {
      type: "final",
    },
  },
  on: {
    DISMISS_LOCK_ALERT: { actions: "dismissAlert" },
  },
});
