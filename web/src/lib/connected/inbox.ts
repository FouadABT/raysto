/**
 * The Overview's AI Action Inbox, as plain data: what each proposal from
 * `agent.inbox` shows (who prepared it, the evidence, whether money moves)
 * and how a decision ended, in words. Pure and tolerant: a field the
 * deployment does not send is left out, never invented, and a PayPal id is
 * only ever one PayPal returned. tests/inbox.test.ts covers it.
 */
import { ApiFailure } from "./api";
import { agentCost, agentName, evidenceChips, type AgentActionRow } from "./business";
import type { Json } from "./contracts";
import { paypalIdOf } from "./money-view";
import { maskEmail } from "./try-new";

/** A row of `agent.inbox`: an action with its decision, when there is one. */
export type InboxAction = AgentActionRow & {
  decidedAt?: string | null;
  result?: Json;
  errorCode?: string | null;
};

const num = (v: unknown): number | undefined => {
  if (v === null || v === undefined || v === "") return undefined;
  const n = Number(v);
  return Number.isFinite(n) ? n : undefined;
};
const text = (v: unknown): string | undefined => (typeof v === "string" && v.trim() ? v.trim() : undefined);
const object = (v: unknown): Json => (v && typeof v === "object" && !Array.isArray(v) ? (v as Json) : {});

/** The inbox's rows, newest first; a row without an id or a title is left out. */
export function inboxRows(raw: unknown): InboxAction[] {
  const rows = (raw as { rows?: unknown } | undefined)?.rows;
  if (!Array.isArray(rows)) return [];
  return rows
    .filter((r): r is InboxAction => !!r && typeof r === "object" && num((r as Json).id) !== undefined && !!text((r as Json).title))
    .map((r) => ({
      ...r,
      id: Number(r.id),
      version: num(r.version) ?? 1,
      taskId: num(r.taskId) ?? 0,
      agent: text(r.agent) ?? "agent",
      command: text(r.command) ?? "",
      rationale: text(r.rationale) ?? "",
      status: text(r.status) ?? "pending",
      preview: object(r.preview),
      evidence: object(r.evidence),
    }))
    .sort((a, b) => b.id - a.id);
}

export type Money = { minor: number; currency: string };

/** What one proposal shows on its card. */
export interface ActionView {
  id: number;
  /** The AI coworker who prepared it, in words. */
  who: string;
  title: string;
  rationale: string;
  /** The backend's own flag: approving it moves money through PayPal. */
  movesMoney: boolean;
  amount?: Money;
  /** How the money moves, when it does: "PayPal refund to the guest". */
  rail?: string;
  /** Short evidence labels, at most four, never the model's words. */
  facts: string[];
  /** Someone started approving it; the identity check is still to do. */
  awaitingCheck: boolean;
  createdAt?: string;
  /** What the AI work behind it cost, when the task recorded it. */
  aiCost?: string;
}

const rails: Record<string, string> = {
  "payment.refund": "PayPal refund to the guest",
  "payout.send": "PayPal Payouts to the team",
  "bill.pay": "PayPal Payouts to the vendor",
  "invoice.send": "PayPal invoice to the customer",
  "payment.release": "Releases an unfinished PayPal checkout",
  "dispute.accept": "Accepts a PayPal dispute",
  "close.sign": "Signs the day's close",
};

/** "24 Nov" on the café's clock; undefined for a date it cannot read. */
function shortDay(iso: unknown, timeZone = "UTC"): string | undefined {
  const t = text(iso);
  if (!t) return undefined;
  const d = new Date(t);
  if (Number.isNaN(d.getTime())) return undefined;
  try {
    return d.toLocaleDateString("en-US", { day: "numeric", month: "short", timeZone });
  } catch {
    return d.toLocaleDateString("en-US", { day: "numeric", month: "short", timeZone: "UTC" });
  }
}

/** One proposal's card. `timeZone` is the café's, for due dates. */
export function actionView(a: InboxAction, format: (minor: number, code: string) => string, timeZone?: string): ActionView {
  const p = object(a.preview);
  const e = object(a.evidence);
  const code = text(p.currency) ?? text(e.currency) ?? "USD";
  const minor = num(p.amountMinor) ?? num(p.totalMinor);
  const facts: string[] = [];
  const add = (f: string | undefined | false) => {
    if (f && !facts.includes(f)) facts.push(f);
  };
  switch (a.command) {
    case "payment.refund": {
      const captured = num(p.capturedMinor) ?? num(e.capturedMinor);
      const already = num(p.alreadyRefundedMinor) ?? num(e.refundedMinor);
      if (captured !== undefined) add(`${format(captured, code)} captured`);
      if (already) add(`${format(already, code)} already refunded`);
      add(text(p.providerCaptureId) && `PayPal capture ${text(p.providerCaptureId)}`);
      add(e.kind === "partial" ? "Partial refund" : e.kind === "full" ? "Full refund" : undefined);
      break;
    }
    case "payout.send": {
      const items = Array.isArray(p.items) ? (p.items as Json[]) : [];
      const held = Array.isArray(p.held) ? p.held.length : 0;
      if (items.length) add(`${items.length} ${items.length === 1 ? "person" : "people"}`);
      add(text(p.kind) && `${String(p.kind).charAt(0).toUpperCase()}${String(p.kind).slice(1)}`);
      const named = items
        .slice(0, 2)
        .map((i) => `${text(i.recipientName) ?? "Someone"} ${format(num(i.amountMinor) ?? 0, code)}`)
        .join(", ");
      add(named || undefined);
      if (held) add(`${held} held: no PayPal email`);
      break;
    }
    case "bill.pay": {
      add(text(p.vendor));
      const due = shortDay(p.dueAt, timeZone);
      if (due) add(`Due ${due}`);
      const vat = num(p.vatMinor);
      if (vat) add(`VAT ${format(vat, code)}`);
      add(maskEmail(p.payeeEmail) && `Pays ${maskEmail(p.payeeEmail)}`);
      break;
    }
  }
  for (const chip of evidenceChips(e, p, format)) add(chip);
  const task = a.task;
  return {
    id: a.id,
    who: agentName(a.agent),
    title: a.title,
    rationale: a.rationale,
    movesMoney: a.risk === "money",
    amount: minor !== undefined ? { minor, currency: code } : undefined,
    rail: a.risk === "money" ? rails[a.command] ?? "Moves money through PayPal" : undefined,
    facts: facts.slice(0, 4),
    awaitingCheck: a.status === "approved",
    createdAt: text(a.createdAt),
    aiCost: task && Number(task.chargedMicros) > 0 ? agentCost(Number(task.chargedMicros)) : undefined,
  };
}

/** "just now", "4 min ago", "2 h ago", "3 days ago". */
export function ago(iso: string | undefined, now = new Date()): string | undefined {
  if (!iso) return undefined;
  const at = new Date(iso).getTime();
  if (!Number.isFinite(at)) return undefined;
  const minutes = Math.floor((now.getTime() - at) / 60000);
  if (minutes < 1) return "just now";
  if (minutes < 60) return `${minutes} min ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} h ago`;
  const days = Math.floor(hours / 24);
  return `${days} ${days === 1 ? "day" : "days"} ago`;
}

/** What an executed proposal did, in words. Only shown once it executed. */
export function executedWords(command: string): string {
  switch (command) {
    case "payment.refund":
      return "Refunded through PayPal. The guest gets PayPal's email and the order shows the refund.";
    case "payout.send":
      return "Sent with PayPal Payouts. Each person receives it in their PayPal account.";
    case "bill.pay":
      return "Sent with PayPal Payouts to the vendor. The bill reads paid once PayPal completes the payout.";
    case "invoice.send":
      return "Sent with PayPal Invoicing. The customer pays on PayPal's page.";
    case "payment.release":
      return "Released. The order can be paid again or cancelled; PayPal holds nothing.";
    case "close.sign":
      return "Signed off. The close is posted with PayPal's figures beside the till's.";
    case "dispute.accept":
      return "Accepted with PayPal. The dispute is closed.";
    case "delivery.offer":
      return "Offered to the driver. The board shows their answer.";
    case "supplier.order.propose":
    case "supplier.order.save":
      return "Saved as a purchase order. Nothing is paid until the bill matches the delivery.";
    case "bill.record":
      return "Filed as an approved payable. This vendor is paid outside PayPal, from Accountant, Bills.";
    case "bill.match":
      return "Matched: the bill agrees with its order and delivery.";
    case "expense.categorise":
    case "expense.record":
      return "Filed in the books.";
    case "menu.publish":
      return "Published. Diners see the new menu in the app now.";
    case "menu.image":
      return "On the menu, labelled as an AI image for diners.";
    default:
      return "Approved and done.";
  }
}

/** done: it ran; dismissed: a person turned it down; refused/failed: it did not go through. */
export type OutcomeTone = "done" | "dismissed" | "refused" | "expired" | "failed" | "handled";

/** How a decision ended: only an executed action reads as done. */
export interface Outcome {
  tone: OutcomeTone;
  text: string;
  /** The PayPal id the result carries, as "PayPal refund 3AB…"; only one PayPal returned. */
  paypalId?: string;
}

/**
 * What an approved money command says before PayPal's id is known: the
 * refund or payout is on its way, not done. Others read as done at once.
 */
export function pendingWords(command: string): string {
  switch (command) {
    case "payment.refund":
      return "Approved. The refund is on its way to PayPal.";
    case "payout.send":
    case "bill.pay":
      return "Approved. The payout is on its way to PayPal Payouts.";
    default:
      return executedWords(command);
  }
}

/** The outcome once PayPal's own id for it is known. */
export const confirmedOutcome = (command: string, paypalId: string): Outcome => ({ tone: "done", text: executedWords(command), paypalId });

export function outcomeOf(command: string, state: string, result?: Json): Outcome {
  if (state === "executed") {
    const paypalId = paypalIdOf(result);
    return paypalId ? confirmedOutcome(command, paypalId) : { tone: "done", text: pendingWords(command) };
  }
  if (state === "rejected") return { tone: "dismissed", text: "Turned down. Nothing changed." };
  if (state === "expired") return { tone: "expired", text: "This proposal ran out of time. Nothing changed." };
  if (state === "stale" || state === "superseded")
    return { tone: "expired", text: "Things changed since the agent looked. Nothing was sent; it will check again." };
  if (result?.error === "provider_feature_disabled")
    return { tone: "refused", text: "PayPal refused it: this feature is not enabled on the PayPal app yet. Nothing was sent or charged." };
  const said = text(result?.message);
  return { tone: "failed", text: said ? `It did not go through: ${said}` : "It did not go through. Nothing was sent." };
}

/** Someone else decided it first, or it is gone: the shared café moved on. */
export function alreadyHandled(e: unknown): boolean {
  return e instanceof ApiFailure && ["version_conflict", "invalid_transition", "not_found"].includes(e.code);
}

export const handledOutcome: Outcome = {
  tone: "handled",
  text: "Already handled: someone else decided this one first. The inbox is up to date.",
};

/**
 * Where PayPal's id shows up after an approval when the result does not
 * carry it yet: a refund's id arrives when PayPal answers the refund job.
 */
export type IdLookup =
  | { kind: "complaint"; taskId: number }
  | { kind: "bill"; id: number }
  | { kind: "payout"; id: number };

export function idLookup(a: Pick<InboxAction, "command" | "taskId" | "preview">): IdLookup | undefined {
  const p = object(a.preview);
  if (a.command === "payment.refund" && a.taskId) return { kind: "complaint", taskId: a.taskId };
  if (a.command === "bill.pay" && num(p.billId)) return { kind: "bill", id: Number(p.billId) };
  if (a.command === "payout.send" && num(p.batchId)) return { kind: "payout", id: Number(p.batchId) };
  return undefined;
}

/**
 * What a record read after an approval says about PayPal: its id once PayPal
 * returned one, a refusal when PayPal refused, or nothing yet.
 */
export function lookupResult(kind: IdLookup["kind"], row: Json | undefined): { paypalId?: string; refused?: boolean } {
  if (!row) return {};
  if (kind === "complaint") {
    const id = text(row.providerRefundId);
    if (id) return { paypalId: `PayPal refund ${id}` };
    return row.refundState === "failed" ? { refused: true } : {};
  }
  const batch = text(row.providerBatchId);
  if (batch) return { paypalId: `PayPal batch ${batch}` };
  return row.state === "failed" || row.payoutState === "failed" ? { refused: true } : {};
}

/** The one-line summary under the inbox's title. */
export function inboxSummary(rows: readonly Pick<AgentActionRow, "risk">[]): string {
  if (rows.length === 0) return "You're all caught up.";
  const money = rows.filter((r) => r.risk === "money").length;
  return `${rows.length} waiting for you${money ? ` · ${money} ${money === 1 ? "moves" : "move"} money` : ""}`;
}
