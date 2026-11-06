/**
 * The AI accountant on the console (stream S1): the books Raysto derives
 * from its own records (ledger.* queries), the bills it owes and the money
 * it is owed (bills, requests), and the AG Studio views over them.
 *
 * Everything here is pure except the data access at the end, so the row
 * shaping and the action rules are unit-tested (tests/accountant.test.ts).
 * Money stays in minor units until Studio, which gets major units of the
 * café's one currency.
 */
import type { ConnectedApi } from "./api";
import type { AgentActionRow } from "./business";
import type { Json } from "./contracts";
import { major, type StudioRow, type StudioSource } from "./studio/sources";
import type { StudioState, StudioWidgetSpec } from "./studio/studio-canvas";

/* ---------- Shapes the backend sends ---------- */

export interface BillRow {
  id: number;
  vendor: string;
  category: string;
  account: string;
  accountName?: string | null;
  reference?: string | null;
  amountMinor: number;
  vatMinor: number;
  currency: string;
  issuedAt?: string | null;
  dueAt?: string | null;
  periodFrom?: string | null;
  periodTo?: string | null;
  state: BillState;
  payVia: "paypal" | "elsewhere";
  payeeEmail?: string | null;
  recurring?: string | null;
  recurringOfId?: number | null;
  sourceMediaId?: number | null;
  proofMediaId?: number | null;
  duplicateOfId?: number | null;
  payoutBatchId?: number | null;
  payoutState?: string | null;
  providerBatchId?: string | null;
  providerItemId?: string | null;
  read?: { from?: string; confidence?: number; notes?: string; explanation?: string; payoutFailed?: string; voidReason?: string; paidNote?: string; basis?: string };
  taskId?: number | null;
  paidAt?: string | null;
  overdue: boolean;
  ageDays?: number | null;
  bucket?: string | null;
  version: number;
  createdAt: string;
}
export type BillState = "expected" | "review" | "approved" | "paying" | "paid" | "paidElsewhere" | "void";

export interface Finding {
  kind: string;
  ref: string;
  severity: "high" | "medium" | "low";
  amountMinor: number;
  facts: string;
  billId?: number;
  requestId?: number;
  fix?: { command: string; payload: Json };
}

export interface BillsPage {
  rows: BillRow[];
  currency: string;
  summary: {
    dueMinor: number;
    overdueMinor: number;
    overdueCount: number;
    reviewCount: number;
    expectedMinor: number;
    paidThisMonthMinor: number;
    aging: Record<string, number>;
  };
  categories: string[];
  findings?: Finding[];
}

export interface RequestRow {
  id: number;
  kind: "link" | "invoice";
  payerName: string;
  payerEmail?: string | null;
  description: string;
  amountMinor: number;
  currency: string;
  dueAt?: string | null;
  state: "draft" | "open" | "sent" | "paid" | "cancelled";
  overdue: boolean;
  payUrl?: string | null;
  providerInvoiceId?: string | null;
  invoiceUrl?: string | null;
  remindersSent: number;
  lastRemindedAt?: string | null;
  checkoutId?: number | null;
  checkoutState?: string | null;
  providerOrderId?: string | null;
  providerCaptureId?: string | null;
  paidAt?: string | null;
  version: number;
  createdAt: string;
}
export interface RequestsPage {
  rows: RequestRow[];
  currency: string;
  summary: { outstandingMinor: number; overdueMinor: number; paidThisMonthMinor: number };
}

export interface PnlRow {
  month: string;
  account: string;
  accountName: string;
  group: "Revenue" | "Costs";
  amountMinor: number;
}
export interface PnlPage {
  basis?: string;
  effectiveFrom?: string;
  partialPeriod?: boolean;
  complete?: boolean;
  issues?: string[];
  from: string;
  to: string;
  currency: string;
  revenueMinor: number;
  costsMinor: number;
  netMinor: number;
  rows: PnlRow[];
  feesEstimated: boolean;
}

export interface Cashflow {
  currency: string;
  history: { date: string; inMinor: number; outMinor: number; netMinor: number }[];
  forecast: { date: string; inMinor: number; outMinor: number; balanceMinor: number; items: { kind: string; vendor: string; amountMinor: number; overdue: boolean }[] }[];
  openingMinor: number;
  averageDailyInMinor: number;
  averageDailyNetMinor: number;
  lowestMinor: number;
  overdue: Json[];
  basis: string;
}

export interface VatPage {
  from: string;
  to: string;
  currency: string;
  taxBps: number;
  taxConfigured: boolean;
  collectedMinor: number;
  paidMinor: number;
  dueMinor: number;
  rows: { month: string; collectedMinor: number; paidMinor: number; dueMinor: number }[];
}

/* ---------- Words ---------- */

export const billStateWords: Record<BillState, string> = {
  expected: "Expected",
  review: "To review",
  approved: "Approved",
  paying: "Paying via PayPal",
  paid: "Paid via PayPal",
  paidElsewhere: "Paid elsewhere",
  void: "Void",
};
/** Grid pill tones for the bill states (grid-columns `toneOf` words). */
export const billStateTone: Record<BillState, string> = {
  expected: "planned",
  review: "review",
  approved: "approved",
  paying: "capturing",
  paid: "paid",
  paidElsewhere: "completed",
  void: "cancelled",
};
export const requestStateWords: Record<RequestRow["state"], string> = {
  draft: "Draft",
  open: "Link ready",
  sent: "Sent",
  paid: "Paid",
  cancelled: "Cancelled",
};

export const billCategoryWords: Record<string, string> = {
  electricity: "Electricity",
  water: "Water",
  gas: "Gas",
  rent: "Rent",
  internet: "Internet",
  phone: "Phone",
  insurance: "Insurance",
  supplier: "Supplier",
  maintenance: "Maintenance",
  tax: "Taxes and licences",
  other: "Other",
};

/* ---------- What a person may do with a bill ---------- */

export type BillAction = "approve" | "pay" | "markPaid" | "void";

/**
 * The actions a bill offers, in order of the one useful next step first.
 * A bill paid or being paid offers nothing: PayPal's answer settles it.
 */
export function billActions(b: Pick<BillRow, "state" | "payVia" | "payeeEmail" | "duplicateOfId">): BillAction[] {
  const payable = b.payVia === "paypal" && !!b.payeeEmail;
  switch (b.state) {
    case "review":
      return payable ? ["pay", "approve", "markPaid", "void"] : ["approve", "markPaid", "void"];
    case "approved":
      return payable ? ["pay", "markPaid", "void"] : ["markPaid", "void"];
    case "expected":
      return ["markPaid", "void"];
    default:
      return [];
  }
}

/** What the PayPal side of a bill says, for the grid and the detail: never a claim without an id. */
export function paypalEvidence(b: Pick<BillRow, "state" | "providerBatchId" | "payoutState" | "providerItemId" | "proofMediaId" | "read">): string {
  if (b.state === "paidElsewhere") return b.proofMediaId ? `Paid elsewhere · proof #${b.proofMediaId}` : "Paid elsewhere";
  if (b.providerBatchId) {
    const item = b.providerItemId ? ` · item ${b.providerItemId}` : "";
    return `PayPal Payouts ${b.providerBatchId}${item} · ${b.payoutState ?? "sent"}`;
  }
  if (b.state === "paying") return "Asking PayPal…";
  if (b.read?.payoutFailed) return `PayPal did not pay it: ${b.read.payoutFailed}`;
  return "";
}

/* ---------- Overview figures ---------- */

export interface AccountantKpis {
  cashInMinor: number;
  cashOutMinor: number;
  netMinor: number;
  billsDueMinor: number;
  overdueMinor: number;
  receivablesMinor: number;
}

export function kpisOf(bills?: BillsPage, requests?: RequestsPage, cash?: Cashflow): AccountantKpis {
  const cashIn = (cash?.history ?? []).reduce((n, d) => n + d.inMinor, 0);
  const cashOut = (cash?.history ?? []).reduce((n, d) => n + d.outMinor, 0);
  return {
    cashInMinor: cashIn,
    cashOutMinor: cashOut,
    netMinor: cashIn - cashOut,
    billsDueMinor: bills?.summary.dueMinor ?? 0,
    overdueMinor: (bills?.summary.overdueMinor ?? 0) + (requests?.summary.overdueMinor ?? 0),
    receivablesMinor: requests?.summary.outstandingMinor ?? 0,
  };
}

export const severityWords: Record<Finding["severity"], string> = { high: "Needs you today", medium: "This week", low: "When you can" };

/* ---------- AG Studio sources ---------- */

/** P&L rows for the pivot: costs negative, so the grand total row is the profit. */
export function pnlRows(rows: readonly PnlRow[]): StudioRow[] {
  return rows.map((r) => ({
    group: r.group,
    account: `${r.account} ${r.accountName}`,
    month: r.month,
    amount: r.group === "Costs" ? -major(r.amountMinor) : major(r.amountMinor),
  }));
}

/**
 * Cash flow by day for the combo chart: money in and out as columns, the
 * balance as a line. The past runs back from today's balance; the forecast
 * runs forward from it and says it is a forecast.
 */
export function cashRows(cash: Cashflow | undefined): StudioRow[] {
  if (!cash) return [];
  const out: StudioRow[] = [];
  let balance = cash.openingMinor;
  const past = [...cash.history].sort((a, b) => b.date.localeCompare(a.date));
  const pastRows: StudioRow[] = [];
  for (const d of past) {
    pastRows.unshift(
      { day: d.date, flow: "Money in", part: "Actual", amount: major(d.inMinor), balance: major(balance) },
      { day: d.date, flow: "Money out", part: "Actual", amount: -major(d.outMinor), balance: major(balance) },
    );
    balance -= d.netMinor;
  }
  out.push(...pastRows);
  for (const d of cash.forecast) {
    out.push(
      { day: d.date, flow: "Expected in", part: "Forecast", amount: major(d.inMinor), balance: major(d.balanceMinor) },
      { day: d.date, flow: "Expected out", part: "Forecast", amount: -major(d.outMinor), balance: major(d.balanceMinor) },
    );
  }
  return out;
}

/** Open bills by age, for the payables aging pivot. */
export function agingRows(bills: readonly BillRow[]): StudioRow[] {
  return bills
    .filter((b) => b.bucket && ["review", "approved", "paying"].includes(b.state))
    .map((b) => ({
      vendor: b.vendor,
      category: billCategoryWords[b.category] ?? b.category,
      bucket: `${b.bucket} days`,
      amount: major(b.amountMinor),
      overdue: b.overdue ? "Overdue" : "Not yet due",
    }));
}

export const source = (id: string, data: StudioRow[]): StudioSource => ({ id, data });

const title = (text: string) => ({ title: { text, enabled: true } });

export const pnlPivot = (code: string): StudioWidgetSpec => ({
  type: "pivot-grid",
  format: { ...title(`Profit and loss by month (${code}); costs are negative, the total row is profit`), style: { grandTotalRow: { enabled: true }, totalColumns: true } },
  dataMapping: {
    rows: [{ id: "pnl.group" }, { id: "pnl.account" }],
    columns: [{ id: "pnl.month" }],
    values: [{ id: "pnl.amount", aggregation: "sum" }],
  },
});

export const agingPivot = (code: string): StudioWidgetSpec => ({
  type: "pivot-grid",
  format: { ...title(`Bills owed by age (${code})`), style: { grandTotalRow: { enabled: true }, totalColumns: true } },
  dataMapping: {
    rows: [{ id: "aging.category" }, { id: "aging.vendor" }],
    columns: [{ id: "aging.bucket" }],
    values: [{ id: "aging.amount", aggregation: "sum" }],
  },
});

/** The Cash flow page: two figures and the combo chart over the `cash` source. */
export function cashState(code: string): StudioState {
  return {
    pages: [
      {
        id: "cash",
        widgets: {
          lowest: { type: "value", format: title(`Lowest balance ahead (${code})`), dataMapping: { value: [{ id: "cash.balance", aggregation: "min" }] } },
          flow: { type: "value", format: title(`Money in less out (${code})`), dataMapping: { value: [{ id: "cash.amount", aggregation: "sum" }] } },
          part: {
            type: "list-filter",
            format: { ...title("Actual or forecast"), style: { selection: { type: "multiple" } } },
            dataMapping: { value: [{ id: "cash.part" }] },
          },
          chart: {
            type: "combo-chart-grouped-column-line",
            format: title(`Money in and out by day, with the balance (${code})`),
            dataMapping: {
              categoryKey: [{ id: "cash.day" }],
              valueKey: [{ id: "cash.amount", aggregation: "sum" }],
              secondaryValueKey: [{ id: "cash.balance", aggregation: "avg" }],
              legendKey: [{ id: "cash.flow" }],
            },
          },
        },
        widgetLayout: {
          lowest: { xTrack: 0, yTrack: 0, xSpan: 8, ySpan: 8 },
          flow: { xTrack: 8, yTrack: 0, xSpan: 8, ySpan: 8 },
          part: { xTrack: 16, yTrack: 0, xSpan: 8, ySpan: 8 },
          chart: { xTrack: 0, yTrack: 8, xSpan: 24, ySpan: 20 },
        },
      },
    ],
    selectedPageId: "cash",
  } as unknown as StudioState;
}

/* ---------- A new payment request ---------- */

export interface RequestDraft {
  kind: "link" | "invoice";
  payerName: string;
  payerEmail: string;
  description: string;
  amount: string;
  dueAt: string;
}

/** The request's fields for `request.create`, or why the draft is not ready. */
export function requestData(d: RequestDraft): { ok: true; data: Json } | { ok: false; error: string } {
  const name = d.payerName.trim();
  if (!name) return { ok: false, error: "Name who pays." };
  const description = d.description.trim();
  if (!description) return { ok: false, error: "Say what it is for." };
  const amount = Number(d.amount.replace(",", "."));
  if (!Number.isFinite(amount) || amount <= 0 || amount > 100000) return { ok: false, error: "Enter an amount between 0.01 and 100,000." };
  const cents = Math.round(amount * 100);
  if (Math.abs(cents / 100 - amount) > 1e-9) return { ok: false, error: "Use at most two decimals." };
  const email = d.payerEmail.trim();
  if (email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return { ok: false, error: "Check the email address." };
  if (d.kind === "invoice" && !email) return { ok: false, error: "An invoice needs the payer's email." };
  const data: Json = { kind: d.kind, payerName: name, description, amountMinor: cents };
  if (email) data.payerEmail = email;
  if (d.dueAt) data.dueAt = new Date(`${d.dueAt}T23:59:00`).toISOString();
  return { ok: true, data };
}

/* ---------- Data access ---------- */

const rowsOf = <T>(page: Json | undefined): T[] => ((page?.rows as T[] | undefined) ?? []);

export const accountant = (api: ConnectedApi, tenant: number) => ({
  bills: (withFindings = false) => api.query<BillsPage>("bills", withFindings ? { restaurantId: tenant, withFindings: true } : { restaurantId: tenant }),
  requests: () => api.query<RequestsPage>("requests", { restaurantId: tenant }),
  pnl: (month?: string) => api.query<PnlPage>("ledger.pnl", month ? { restaurantId: tenant, month } : { restaurantId: tenant }),
  cashflow: (days = 30) => api.query<Cashflow>("ledger.cashflow", { restaurantId: tenant, days }),
  vat: () => api.query<VatPage>("ledger.vat", { restaurantId: tenant }),
  inbox: async () =>
    rowsOf<AgentActionRow>(await api.query<Json>("agent.inbox", { restaurantId: tenant }).catch(() => ({ rows: [] }))).filter(
      (a) => a.agent === "accountant",
    ),
  run: (mode: "month" | "anomalies") => api.command<{ taskId: number }>("accountant.run", tenant, { mode }),
  snap: (mediaId: number) => api.command<{ taskId: number | null; duplicateOfId: number | null }>("bill.snap", tenant, { mediaId }),
  save: (data: Json, at?: { id: number; version: number }) => api.command<BillRow>("bill.save", tenant, data, at ?? {}),
  approve: (b: BillRow, notDuplicate = false) =>
    api.command<BillRow>("bill.approve", tenant, notDuplicate ? { notDuplicate: true } : {}, { id: b.id, version: b.version }),
  /** One key per attempt: a retry after the identity check resumes the same payment. */
  pay: (b: BillRow, key: string) => api.command<Json>("bill.pay", tenant, b.state === "review" ? { approve: true } : {}, { id: b.id, key }),
  markPaid: (b: BillRow, proofMediaId: number, note?: string) =>
    api.command<BillRow>("bill.markPaid", tenant, note ? { proofMediaId, note } : { proofMediaId }, { id: b.id, version: b.version }),
  void: (b: BillRow, reason: string) => api.command<BillRow>("bill.void", tenant, { reason }, { id: b.id, version: b.version }),
  createRequest: (data: Json) => api.command<RequestRow>("request.create", tenant, data),
  send: (r: RequestRow) => api.command<RequestRow>("request.send", tenant, {}, { id: r.id }),
  remind: (r: RequestRow) => api.command<RequestRow>("request.remind", tenant, {}, { id: r.id }),
  cancel: (r: RequestRow) => api.command<RequestRow>("request.cancel", tenant, {}, { id: r.id }),
});
export type AccountantApi = ReturnType<typeof accountant>;
