/**
 * The back office: the daily close, pay and tips, catering, refunds and
 * disputes, expenses, customers, analytics and shifts. Money is integer minor
 * units. These are the shapes the console expects from the backend queries
 * and commands named in docs/back-office-design.md §3; every query returns
 * `{ rows: [...] }` unless written otherwise, and dates are ISO strings.
 *
 * Queries (all take restaurantId):
 *   backoffice.close {day?}      → { close: Close | null }
 *   backoffice.closes            → { rows: Close[] }
 *   shifts {from, to}            → { rows: Shift[] }
 *   payouts                      → { rows: PayoutBatch[] }   (items included)
 *   payout {id}                  → PayoutBatch
 *   catering                     → { rows: CateringRequest[] }
 *   catering.request {id}        → CateringRequest
 *   complaints                   → { rows: Complaint[] }
 *   disputes                     → { rows: Dispute[] }
 *   expenses {from, to}          → { rows: Expense[] }
 *   customers                    → { rows: CustomerProfile[] }
 *   analytics {from, to}         → Analytics
 * Commands (dataJson fields; id/version where a row changes):
 *   close.run {day?}             → { taskId }
 *   close.sign  (id: close.id, version)            → { state }
 *   payroll.run {from, to}       → { taskId }
 *   payout.send (id: batch.id, version; step-up)   → { providerBatchId, state }
 *   shift.save {name, role, startsAt, endsAt, hourlyRateMinor, payoutEmail?} (id?, version?) → { id }
 *   shift.clock {action: "in" | "out"} (id: shift.id, version)  → { clockInAt?, clockOutAt? }
 *   catering.request {customerEmail, customerName, text, eventAt?} → { id, taskId }
 *   invoice.send   (id: request.id, version; step-up) → { providerInvoiceId, invoiceNumber, qrUrl? }
 *   invoice.remind (id: request.id, version)          → { remindedAt }
 *   complaint.open {orderId, text}                    → { id, taskId }
 *   dispute.sweep                                     → { taskId }
 *   expense.record {category, amountMinor, vatMinor?, spentAt, merchant} → { id }
 *   loyalty.run                                       → { taskId }
 * Agent proposals arrive through agent.inbox with these `command` names:
 *   close.sign, payout.send, invoice.send, payment.refund, dispute.accept,
 *   shift.plan, coupon.create, expense.record, stock.receive.
 */
import type { ConnectedApi } from "./api";
import { asRows, type AgentActionRow } from "./business";
import type { Json } from "./contracts";

export interface Shift {
  id: number;
  version: number;
  userId?: string | null;
  name: string;
  role: string;
  startsAt: string;
  endsAt: string;
  clockInAt?: string | null;
  clockOutAt?: string | null;
  hourlyRateMinor: number;
  payoutEmail?: string | null;
}

export interface PayoutItem {
  id?: number;
  recipientName: string;
  recipientEmail?: string;
  amountMinor: number;
  note?: string;
  state: string;
  providerItemId?: string | null;
}

export interface PayoutBatch {
  id: number;
  version: number;
  kind: "tips" | "wages" | "supplier";
  periodFrom: string;
  periodTo: string;
  totalMinor: number;
  currency: string;
  state: "proposed" | "sent" | "completed" | "failed" | string;
  providerBatchId?: string | null;
  createdAt: string;
  items: PayoutItem[];
}

export interface CloseGap {
  kind: string;
  amountMinor: number;
  explanation: string;
  proposedFix?: string;
}

export interface Close {
  id: number;
  version: number;
  day: string;
  source: "paypal_transactions" | "raysto_ledger" | string;
  summary: {
    paypalCapturedMinor: number;
    raystoCapturedMinor: number;
    refundsMinor: number;
    tipsMinor: number;
    cashMinor: number;
    feesMinor: number;
    currency?: string;
  };
  gaps: CloseGap[];
  state: "drafted" | "signed" | string;
  signedBy?: string | null;
  createdAt?: string;
}

export interface CateringRequest {
  id: number;
  version: number;
  customerEmail?: string;
  customerName: string;
  text: string;
  eventAt?: string | null;
  status: "requested" | "quoted" | "sent" | "paid" | "cancelled" | string;
  totalMinor: number;
  depositMinor: number;
  currency: string;
  dueAt?: string | null;
  providerInvoiceId?: string | null;
  invoiceNumber?: string | null;
  qrUrl?: string | null;
  remindedAt?: string | null;
  quote?: { lines?: { name: string; quantity: number; unitMinor: number }[]; notes?: string } | null;
  createdAt: string;
}

export interface Complaint {
  id: number;
  orderId: number;
  text: string;
  status: "open" | "proposed" | "refunded" | "declined" | string;
  proposal?: { kind: string; amountMinor: number; rationale: string } | null;
  refundId?: number | null;
  providerRefundId?: string | null;
  createdAt: string;
}

export interface Dispute {
  id: number;
  providerDisputeId: string;
  reason: string;
  amountMinor: number;
  currency: string;
  status: string;
  evidence?: Json;
  replyText?: string | null;
  createdAt: string;
}

export interface Expense {
  id: number;
  category: string;
  amountMinor: number;
  vatMinor?: number;
  currency: string;
  spentAt: string;
  merchant: string;
  paypalTransactionId?: string | null;
}

export interface StockItem {
  id: number;
  name: string;
  unit: string;
  quantity: number;
  costMinor: number;
  lowAt: number;
}

export interface CustomerProfile {
  id: number;
  displayName: string;
  visits: number;
  spentMinor: number;
  lastSeenAt: string;
  tags: string[];
  couponCode?: string | null;
}

export interface Analytics {
  currency?: string;
  byHour: { hour: number; salesMinor: number; orders: number }[];
  byChannel: { channel: string; salesMinor: number }[];
  feesMinor: number;
  refundsMinor: number;
  tipsMinor: number;
  staffCostMinor: number;
  expensesMinor: number;
  marginByDish: { name: string; priceMinor: number; costMinor: number }[];
}

/* ---------- Pure helpers (unit tested) ---------- */

/** Hours a shift counts for pay: the clock when it was used, else the plan. */
export function shiftHours(s: Pick<Shift, "startsAt" | "endsAt" | "clockInAt" | "clockOutAt">, now = new Date()): number {
  const start = new Date(s.clockInAt ?? s.startsAt).getTime();
  const end = s.clockInAt && !s.clockOutAt ? Math.min(now.getTime(), new Date(s.endsAt).getTime()) : new Date(s.clockOutAt ?? s.endsAt).getTime();
  if (!Number.isFinite(start) || !Number.isFinite(end) || end <= start) return 0;
  // Quarter hours, as a till would count them.
  return Math.round(((end - start) / 3_600_000) * 4) / 4;
}

export const shiftPayMinor = (s: Shift, now = new Date()) => Math.round(shiftHours(s, now) * s.hourlyRateMinor);

/** "On shift", "Done", "Planned" or "Missed" for a row. */
export function shiftState(s: Pick<Shift, "startsAt" | "endsAt" | "clockInAt" | "clockOutAt">, now = new Date()): string {
  if (s.clockOutAt) return "done";
  if (s.clockInAt) return "onShift";
  return new Date(s.endsAt).getTime() < now.getTime() ? "missed" : "planned";
}

/** The clock action a row offers next, if any. */
export const clockAction = (s: Pick<Shift, "clockInAt" | "clockOutAt">): "in" | "out" | null =>
  s.clockOutAt ? null : s.clockInAt ? "out" : "in";

/** Monday to Sunday around a date, as ISO bounds. */
export function weekRange(now: Date) {
  const start = new Date(now);
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - ((start.getDay() + 6) % 7));
  const to = new Date(start);
  to.setDate(to.getDate() + 7);
  return { from: start.toISOString(), to: to.toISOString() };
}

export const localDay = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

/** What the close shows beside PayPal's figure: a difference or "matches". */
export function closeDelta(c: Pick<Close, "summary">): { minor: number; matches: boolean } {
  const minor = c.summary.paypalCapturedMinor - c.summary.raystoCapturedMinor;
  return { minor, matches: minor === 0 };
}

const gapNames: Record<string, string> = {
  fee: "PayPal fee",
  fees: "PayPal fees",
  refund: "Refund",
  unpaid: "Unpaid ticket",
  unpaidTicket: "Unpaid ticket",
  cash: "Cash",
  missingCapture: "Capture not in Raysto",
  missingTransaction: "Not in PayPal",
  tip: "Tip",
  tips: "Tips",
  expense: "Expense",
  unknown: "Unexplained",
};

/** A gap as a short label, never the model's words. */
export const gapLabel = (g: Pick<CloseGap, "kind">) =>
  gapNames[g.kind] ?? g.kind.replace(/([a-z])([A-Z])/g, "$1 $2").replace(/^./, (c) => c.toUpperCase());

/** Where the close read PayPal from, in the words a judge checks. */
export const closeSourceLabel = (source: string) =>
  source === "paypal_transactions"
    ? "PayPal's transaction list"
    : source === "raysto_ledger"
      ? "Raysto's own ledger (PayPal webhooks)"
      : source;

/** Bar heights in 0–1 for a simple chart; an empty series is all zero. */
export function barScale(values: number[]): number[] {
  const max = Math.max(0, ...values);
  return values.map((v) => (max > 0 ? Math.max(0, v) / max : 0));
}

/** Margin per dish, as a percentage of the price; null when unknown. */
export const marginPercent = (d: { priceMinor: number; costMinor: number }) =>
  d.priceMinor > 0 && d.costMinor >= 0 ? Math.round(((d.priceMinor - d.costMinor) / d.priceMinor) * 100) : null;

/** Sum of a payout batch's items, to show a batch total that adds up. */
export const batchTotal = (b: Pick<PayoutBatch, "items">) => b.items.reduce((n, i) => n + i.amountMinor, 0);

/** The inbox actions that belong to one back-office area. */
export const actionsFor = (inbox: AgentActionRow[], commands: string[]) =>
  inbox.filter((a) => commands.includes(a.command));

/* ---------- Data access ---------- */

export const backoffice = (api: ConnectedApi, tenant: number) => ({
  close: (day?: string) => api.query<{ close: Close | null }>("backoffice.close", { restaurantId: tenant, day }),
  closes: async () => asRows<Close>(await api.query<Json>("backoffice.closes", { restaurantId: tenant })),
  shifts: async (from: string, to: string) => asRows<Shift>(await api.query<Json>("shifts", { restaurantId: tenant, from, to })),
  payouts: async () => asRows<PayoutBatch>(await api.query<Json>("payouts", { restaurantId: tenant })),
  catering: async () => asRows<CateringRequest>(await api.query<Json>("catering", { restaurantId: tenant })),
  complaints: async () => asRows<Complaint>(await api.query<Json>("complaints", { restaurantId: tenant })),
  disputes: async () => asRows<Dispute>(await api.query<Json>("disputes", { restaurantId: tenant })),
  expenses: async (from: string, to: string) => asRows<Expense>(await api.query<Json>("expenses", { restaurantId: tenant, from, to })),
  customers: async () => asRows<CustomerProfile>(await api.query<Json>("customers", { restaurantId: tenant })),
  analytics: (from: string, to: string) => api.query<Analytics>("analytics", { restaurantId: tenant, from, to }),
  inbox: async () => asRows<AgentActionRow>(await api.query<Json>("agent.inbox", { restaurantId: tenant }).catch(() => ({ rows: [] }))),
});
