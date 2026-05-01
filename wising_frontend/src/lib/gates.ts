// Wising Tax Engine — Gate evaluator (TypeScript mirror of Python evaluate_gate)
// GAP-003: 'contains' operator support
// GAP-004: eq with [] checks correctly (None !== [])

type Context = Record<string, unknown>;

function resolvePath(context: Context, fieldPath: string): unknown {
  const parts = fieldPath.split(".");
  let cur: unknown = context;
  for (const part of parts) {
    const clean = part.replace(/\[\]$/g, "");
    if (cur === null || cur === undefined) return undefined;
    if (typeof cur === "object") {
      cur = (cur as Record<string, unknown>)[clean];
    } else {
      return undefined;
    }
  }
  return cur;
}

export function evaluateGate(gate: unknown, context: Context): boolean {
  if (gate === null || gate === undefined) return true;

  const g = gate as Record<string, unknown>;

  if ("and" in g && Array.isArray(g.and)) {
    return (g.and as unknown[]).every((c) => evaluateGate(c, context));
  }

  if ("or" in g && Array.isArray(g.or)) {
    return (g.or as unknown[]).some((c) => evaluateGate(c, context));
  }

  const fieldPath = (g.field as string) ?? "";
  const op = (g.op as string) ?? "eq";
  const expected = g.value;
  const actual = resolvePath(context, fieldPath);

  switch (op) {
    case "eq":
      // GAP-004: [] != null/undefined
      if (Array.isArray(expected) && expected.length === 0) {
        return Array.isArray(actual) && actual.length === 0;
      }
      return actual === expected;
    case "neq":
      return actual !== expected;
    case "gt":
      return typeof actual === "number" && actual > (expected as number);
    case "gte":
      return typeof actual === "number" && actual >= (expected as number);
    case "lt":
      return typeof actual === "number" && actual < (expected as number);
    case "in":
      return Array.isArray(expected) && expected.includes(actual);
    case "contains":
      // GAP-003
      return Array.isArray(actual) && actual.includes(expected);
    default:
      return false;
  }
}
