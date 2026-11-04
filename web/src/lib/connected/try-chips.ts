// What the Try cards say about where an agent's facts came from and how an
// approval ended. PayPal is named only when PayPal itself answered.
import type { Json } from "./contracts";

/** The words for a trace step's recorded source, or undefined for an internal tool. */
export function sourceLabel(source: unknown): string | undefined {
  switch (source) {
    case "paypal_mcp":
      return "asked PayPal via MCP";
    case "paypal_rest":
      return "asked PayPal (REST)";
    case "paypal_transactions":
      return "read PayPal's transaction list";
    case "raysto_ledger":
      return "PayPal webhook ledger (Transaction Search pending)";
    default:
      return undefined;
  }
}

/** One chip per tool the agent used, in order and without repeats. */
export function toolChips(trace: unknown): string[] {
  if (!Array.isArray(trace)) return [];
  const out: string[] = [];
  for (const raw of trace) {
    if (!raw || typeof raw !== "object") continue;
    const step = raw as Json;
    const name = step.tool ?? step.name;
    if (typeof name !== "string") continue;
    const label = sourceLabel(step.source) ?? `used ${name}`;
    if (!out.includes(label)) out.push(label);
  }
  return out;
}

/** Where the daily close read PayPal's day from, as the close itself records it. */
export function closeSourceChip(close: Json | undefined): string {
  if (!close) return "PayPal source not recorded";
  if (close.source === "paypal_transactions") {
    const via = (close.summary as Json | undefined)?.via;
    return via === "paypal_mcp"
      ? "read PayPal's transaction list via MCP"
      : via === "paypal_rest"
        ? "read PayPal's transaction list (REST)"
        : "read PayPal's transaction list";
  }
  return "PayPal webhook ledger (Transaction Search pending)";
}

/** How an approval ended: only an executed action is "done". */
export type OutcomeTone = "done" | "refused" | "expired" | "failed";

export function outcomeTone(state: string, result?: Json): OutcomeTone {
  if (state === "executed") return "done";
  if (state === "expired" || state === "stale") return "expired";
  if (state === "rejected" || result?.error === "provider_feature_disabled") return "refused";
  return "failed";
}
