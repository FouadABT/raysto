// What Try cards 10–14 show, read from the backend's own rows: the bill the
// accountant read, the month's books, a pay link, the dispatcher's ranking
// and the supply planner's forecast. Every reader is tolerant (a field the
// deployment does not send yet is left out, never invented) and pure, so
// tests/try-new.test.ts covers it without a browser.
import type { Json } from "./contracts";

/** The sample electricity bill uploaded for the judges' café (`tool/judge_restaurant.cjs bill`). */
export const sampleBillMediaId = Number(process.env.NEXT_PUBLIC_RAYSTO_JUDGE_BILL_MEDIA_ID ?? 0);

const num = (v: unknown): number | undefined => {
  if (v === null || v === undefined || v === "") return undefined;
  const n = Number(v);
  return Number.isFinite(n) ? n : undefined;
};
const text = (v: unknown): string | undefined => (typeof v === "string" && v.trim() ? v.trim() : undefined);
const objects = (v: unknown): Json[] =>
  Array.isArray(v) ? v.filter((x): x is Json => !!x && typeof x === "object" && !Array.isArray(x)) : [];
const object = (v: unknown): Json => (v && typeof v === "object" && !Array.isArray(v) ? (v as Json) : {});

/** Rows labelled sample by the judges' reset end with this. */
export const sampleMark = "· Sample";

/* ---------- 10. A bill ---------- */

/** The bill file the card reads: the build's id when set, else the newest bill the scanner approved. */
export function pickBillFile(media: Json[], preferred = 0): Json | undefined {
  const files = media.filter((m) => m.purpose === "bill" && m.status === "approved");
  return files.find((m) => Number(m.id) === preferred) ?? [...files].sort((a, b) => Number(b.id) - Number(a.id))[0];
}

/** "bu…@personal.example.com": enough to recognise a payee without printing the whole address. */
export function maskEmail(email: unknown): string | undefined {
  const e = text(email);
  if (!e) return undefined;
  const at = e.indexOf("@");
  if (at < 1) return "…";
  return `${e.slice(0, Math.min(2, at))}…${e.slice(at)}`;
}

export type BillView = {
  id?: number;
  version: number;
  vendor: string;
  category: string;
  reference?: string;
  amountMinor: number;
  vatMinor: number;
  currency: string;
  dueAt?: string;
  state: string;
  payVia: string;
  payee?: string;
  /** 0–1, when the accountant's read recorded it. */
  confidence?: number;
  duplicateOfId?: number;
  providerBatchId?: string;
  payoutState?: string;
  recurring?: string;
  sample: boolean;
};

export function billView(raw: Json | undefined): BillView | undefined {
  const vendor = text(raw?.vendor);
  if (!raw || !vendor) return undefined;
  const read = object(raw.read);
  const confidence = num(read.confidence ?? raw.confidence);
  return {
    id: num(raw.id),
    version: num(raw.version) ?? 1,
    vendor,
    category: text(raw.category) ?? "other",
    reference: text(raw.reference),
    amountMinor: num(raw.amountMinor) ?? 0,
    vatMinor: num(raw.vatMinor) ?? 0,
    currency: text(raw.currency) ?? "USD",
    dueAt: text(raw.dueAt),
    state: text(raw.state) ?? "review",
    payVia: text(raw.payVia) ?? "elsewhere",
    payee: text(raw.payeeEmail),
    confidence: confidence === undefined ? undefined : confidence > 1 ? confidence / 100 : confidence,
    duplicateOfId: num(raw.duplicateOfId),
    providerBatchId: text(raw.providerBatchId),
    payoutState: text(raw.payoutState),
    recurring: text(raw.recurring),
    sample: vendor.endsWith(sampleMark),
  };
}

/** What can happen to a bill next, from its state and payee. */
export type BillNext = "pay" | "elsewhere" | "duplicate" | "paying" | "paid" | "paidElsewhere" | "void";

export function billNext(b: BillView): BillNext {
  if (b.state === "paid") return "paid";
  if (b.state === "paying") return "paying";
  if (b.state === "paidElsewhere") return "paidElsewhere";
  if (b.state === "void") return "void";
  if (b.duplicateOfId) return "duplicate";
  return b.payVia === "paypal" && b.payee ? "pay" : "elsewhere";
}

/** One plain sentence for where the bill stands. */
export function billNextLine(b: BillView): string {
  switch (billNext(b)) {
    case "paid":
      return b.providerBatchId
        ? `Paid with PayPal Payouts, batch ${b.providerBatchId} (Sandbox).`
        : "Paid with PayPal Payouts (Sandbox).";
    case "paying":
      return b.providerBatchId
        ? `PayPal accepted the payout, batch ${b.providerBatchId}; it completes in a few minutes.`
        : "PayPal is being asked to pay it.";
    case "paidElsewhere":
      return "Marked paid outside PayPal, with a proof.";
    case "void":
      return "Voided: nothing will be paid.";
    case "duplicate":
      return `This looks like bill #${b.duplicateOfId} again, so the accountant will not pay it twice.`;
    case "pay":
      return `The vendor takes PayPal: ${maskEmail(b.payee)} (Sandbox).`;
    default:
      return "This vendor has no PayPal account on file: it is paid outside PayPal and marked paid with a proof.";
  }
}

/* ---------- 11. The month's books ---------- */

/** "2026-11": the month as the café's clock reads it. */
export function monthOf(at: Date, timeZone = "America/New_York"): string {
  const parts = new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit" }).formatToParts(at);
  const y = parts.find((p) => p.type === "year")?.value ?? String(at.getUTCFullYear());
  const m = parts.find((p) => p.type === "month")?.value ?? String(at.getUTCMonth() + 1).padStart(2, "0");
  return `${y}-${m}`;
}

export type PnlLine = { account: string; name: string; amountMinor: number; group: "Revenue" | "Costs" };
export type PnlView = {
  currency: string;
  revenueMinor: number;
  costsMinor: number;
  netMinor: number;
  /** Net over revenue, one decimal; undefined without revenue. */
  marginPct?: number;
  lines: PnlLine[];
  feesEstimated: boolean;
};

export function pnlView(raw: Json): PnlView {
  const side = (list: unknown, group: PnlLine["group"]): PnlLine[] =>
    objects(list)
      .map((r) => ({
        account: String(r.account ?? ""),
        name: text(r.name) ?? text(r.accountName) ?? String(r.account ?? ""),
        amountMinor: num(r.amountMinor) ?? 0,
        group,
      }))
      .filter((l) => l.amountMinor !== 0);
  const revenue = side(raw.revenue, "Revenue");
  const costs = side(raw.costs, "Costs");
  const sum = (ls: PnlLine[]) => ls.reduce((n, l) => n + l.amountMinor, 0);
  const revenueMinor = num(raw.revenueMinor) ?? sum(revenue);
  const costsMinor = num(raw.costsMinor) ?? sum(costs);
  const netMinor = num(raw.netMinor) ?? revenueMinor - costsMinor;
  return {
    currency: text(raw.currency) ?? "USD",
    revenueMinor,
    costsMinor,
    netMinor,
    marginPct: revenueMinor > 0 ? Math.round((netMinor / revenueMinor) * 1000) / 10 : undefined,
    lines: [...revenue, ...costs],
    feesEstimated: raw.feesEstimated === true,
  };
}

export type VatView = { collectedMinor: number; paidMinor: number; dueMinor: number; configured: boolean };

export function vatView(raw: Json | undefined): VatView | undefined {
  if (!raw) return undefined;
  const collectedMinor = num(raw.collectedMinor) ?? 0;
  const paidMinor = num(raw.paidMinor) ?? 0;
  return {
    collectedMinor,
    paidMinor,
    dueMinor: num(raw.dueMinor) ?? collectedMinor - paidMinor,
    configured: raw.taxConfigured !== false,
  };
}

export type Anomaly = { title: string; detail?: string; ids: string[] };

const idLabels: [string, string][] = [
  ["providerCaptureId", "PayPal capture"],
  ["providerBatchId", "PayPal payout batch"],
  ["providerRefundId", "PayPal refund"],
  ["providerOrderId", "PayPal order"],
  ["providerInvoiceId", "PayPal invoice"],
  ["paypalId", "PayPal"],
];

/** What looks wrong in the month, each with the PayPal ids it is about. */
/** The accountant's rule names, in words a café owner reads. */
const findingNames: Record<string, string> = {
  bill_due_soon: "A bill is due soon",
  bill_overdue: "A bill is overdue",
  bill_spike: "A bill is much higher than usual",
  cash_shortfall: "Cash may run short",
  duplicate_bill: "A bill may be a duplicate",
  expense_uncategorised: "An expense has no category",
  payout_failed: "A PayPal payout failed",
  refund_rate_high: "Refunds are high",
  request_overdue: "A payment request is overdue",
  unbalanced_books: "The books do not balance",
  vat_not_configured: "The VAT rate is not set",
};

/** A rule name the list above does not know yet: "some_rule" or "someRule" -> "Some rule". */
const ruleWords = (code: string) => {
  const words = code
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/[_-]+/g, " ")
    .trim()
    .toLowerCase();
  return words ? words[0].toUpperCase() + words.slice(1) : words;
};

export function anomalyView(list: unknown): Anomaly[] {
  const out: Anomaly[] = [];
  for (const a of objects(list)) {
    const code = text(a.kind) ?? text(a.rule);
    const title = text(a.title) ?? text(a.summary) ?? (code ? findingNames[code] ?? ruleWords(code) : undefined);
    if (!title) continue;
    const ids: string[] = [];
    for (const source of [a, object(a.evidence), object(a.source)]) {
      for (const [k, label] of idLabels) {
        const v = text(source[k]);
        if (v && !ids.some((i) => i.endsWith(v))) ids.push(`${label} ${v}`);
      }
    }
    out.push({ title, detail: text(a.detail) ?? text(a.explanation) ?? text(a.message) ?? text(a.facts), ids });
  }
  return out;
}

/* ---------- 12. A pay link ---------- */

export type RequestView = {
  id?: number;
  version: number;
  payUrl?: string;
  state: string;
  amountMinor: number;
  currency: string;
  payerName: string;
  description: string;
  captureId?: string;
  paid: boolean;
  sample: boolean;
};

export function requestView(raw: Json | undefined): RequestView | undefined {
  if (!raw || num(raw.id) === undefined) return undefined;
  const payerName = text(raw.payerName) ?? "";
  const payUrl = text(raw.payUrl);
  return {
    id: num(raw.id),
    version: num(raw.version) ?? 1,
    // Only an https link is shown or encoded in a QR code.
    payUrl: payUrl && /^https:\/\//.test(payUrl) ? payUrl : undefined,
    state: text(raw.state) ?? "open",
    amountMinor: num(raw.amountMinor) ?? 0,
    currency: text(raw.currency) ?? "USD",
    payerName,
    description: text(raw.description) ?? "",
    captureId: text(raw.providerCaptureId),
    paid: raw.state === "paid",
    sample: payerName.endsWith(sampleMark),
  };
}

/** The deposit a judge asks for on card 12: labelled sample, small, Sandbox. */
export const depositRequest = {
  kind: "link",
  payerName: `Studio Lumen ${sampleMark}`,
  description: "Catering deposit · Friday lunch for 12 (sample, PayPal Sandbox)",
  amountMinor: 3555,
};

/* ---------- 13. Dispatch ---------- */

/** The newest job that needs one of the café's drivers, preferring the partner order just sent. */
export function pickJob(rows: Json[], partnerRef?: string): Json | undefined {
  const open = rows.filter((r) => r.status === "unassigned" && r.fulfilledBy !== "partner" && !r.offer);
  return (
    (partnerRef ? open.find((r) => r.partnerRef === partnerRef) : undefined) ??
    [...open].sort((a, b) => Number(b.id) - Number(a.id))[0]
  );
}

export type RankRow = {
  driverId: number;
  name: string;
  vehicle: string;
  minutes?: number;
  score?: number;
  activeJobs: number;
  reasons: string[];
  hasLogin: boolean;
  sample: boolean;
};

export function rankingView(list: unknown): RankRow[] {
  return objects(list)
    .map((r) => {
      const name = text(r.name) ?? "Driver";
      return {
        driverId: num(r.driverId) ?? 0,
        name,
        vehicle: text(r.vehicle) ?? "",
        minutes: num(r.minutes),
        score: num(r.score),
        activeJobs: num(r.activeJobs) ?? 0,
        reasons: (Array.isArray(r.reasons) ? r.reasons : []).filter((x): x is string => typeof x === "string"),
        hasLogin: r.hasLogin === true,
        sample: name.endsWith(sampleMark),
      };
    })
    .filter((r) => r.driverId > 0)
    .sort((a, b) => (b.score ?? -1) - (a.score ?? -1) || a.activeJobs - b.activeJobs || a.driverId - b.driverId);
}

export type PartnerLine = { id: number; direction: "in" | "out"; type: string; status: string; code?: number; attempts: number; at: string };

/** The partner API's log, oldest first, newest eight. */
export function partnerLines(list: unknown, ref?: string): PartnerLine[] {
  const all = objects(list)
    .filter((e) => !ref || !e.ref || e.ref === ref)
    .map((e) => ({
      id: num(e.id) ?? 0,
      direction: (e.direction === "in" || e.direction === "inbound" ? "in" : "out") as "in" | "out",
      type: text(e.type) ?? text(e.event) ?? "event",
      status: text(e.status) ?? "",
      code: num(e.responseCode),
      attempts: num(e.attempts) ?? 0,
      at: text(e.createdAt) ?? "",
    }))
    .sort((a, b) => a.at.localeCompare(b.at) || a.id - b.id);
  return all.slice(-8);
}

export const partnerLabel = (l: PartnerLine) =>
  `${l.direction === "in" ? "Received from the partner" : "Signed webhook to the partner"}: ${l.type}${
    l.status ? ` · ${l.status}` : ""
  }${l.code ? ` (HTTP ${l.code})` : ""}`;

/* ---------- 14. Supplies ---------- */

export type CoverRow = {
  stockItemId: number;
  name: string;
  unit: string;
  quantity: number;
  dailyUsage: number;
  daysCover?: number;
  stockOutAt?: string;
  reorder: boolean;
  suggestedQty: number;
  low: boolean;
};

/** Stock most at risk first: what to reorder, then the fewest days of cover. */
export function coverRows(list: unknown): CoverRow[] {
  return objects(list)
    .map((r) => ({
      stockItemId: num(r.stockItemId) ?? 0,
      name: text(r.name) ?? "",
      unit: text(r.unit) ?? "",
      quantity: num(r.quantity) ?? 0,
      dailyUsage: num(r.dailyUsage) ?? 0,
      daysCover: num(r.daysCover),
      stockOutAt: text(r.stockOutAt),
      reorder: r.reorder === true,
      suggestedQty: num(r.suggestedQty) ?? 0,
      low: r.low === true,
    }))
    .filter((r) => r.name)
    .sort(
      (a, b) =>
        Number(b.reorder) - Number(a.reorder) ||
        (a.daysCover ?? Number.POSITIVE_INFINITY) - (b.daysCover ?? Number.POSITIVE_INFINITY) ||
        a.name.localeCompare(b.name),
    );
}

/** Where the usage figures come from, in words. */
export function basisLabel(basis: unknown): string {
  switch (basis) {
    case "movements":
      return "usage from 28 days of sales and waste";
    case "recipes":
      return "usage from 28 days of orders × recipes";
    default:
      return "no sales recorded yet: reorders come from the low marks";
  }
}

export type MatchLine = {
  name: string;
  unit: string;
  orderedQty: number;
  receivedQty: number;
  orderedUnitMinor: number;
  billedUnitMinor: number;
  qtyDiff: number;
  /** Billed against ordered unit price, in percent, one decimal. */
  pricePct: number;
  flag: boolean;
};

/** The purchase order against what arrived and what was billed, per line. */
export function matchLines(order: Json | undefined, flagPct = 5): MatchLine[] {
  return objects(order?.lines).map((l) => {
    const orderedQty = num(l.qty) ?? 0;
    const receivedQty = num(l.receivedQty) ?? 0;
    const orderedUnitMinor = num(l.unitCostMinor) ?? 0;
    const billedUnitMinor = num(l.receivedUnitCostMinor) ?? orderedUnitMinor;
    const pricePct = orderedUnitMinor > 0 ? Math.round(((billedUnitMinor - orderedUnitMinor) / orderedUnitMinor) * 1000) / 10 : 0;
    const qtyDiff = Math.round((receivedQty - orderedQty) * 1000) / 1000;
    return {
      name: text(l.name) ?? "",
      unit: text(l.unit) ?? "",
      orderedQty,
      receivedQty,
      orderedUnitMinor,
      billedUnitMinor,
      qtyDiff,
      pricePct,
      flag: Math.abs(pricePct) > flagPct || qtyDiff !== 0,
    };
  });
}

/** The three totals of a 3-way match: ordered, delivered at the billed prices, and the bill itself. */
export function matchTotals(lines: MatchLine[], billMinor?: number) {
  const orderedMinor = Math.round(lines.reduce((n, l) => n + l.orderedQty * l.orderedUnitMinor, 0));
  const deliveredMinor = Math.round(lines.reduce((n, l) => n + l.receivedQty * l.billedUnitMinor, 0));
  return {
    orderedMinor,
    deliveredMinor,
    billMinor,
    /** The bill against the order: what the price changes cost. */
    diffMinor: (billMinor ?? deliveredMinor) - orderedMinor,
  };
}

/** A proposed purchase order, from the planner's pending action. */
export function proposedOrder(preview: Json | undefined) {
  const p = object(preview);
  return {
    supplier: text(p.supplier) ?? text(p.supplierName) ?? "No supplier yet",
    lines: objects(p.lines).map((l) => ({
      name: text(l.name) ?? "",
      unit: text(l.unit) ?? "",
      qty: num(l.qty) ?? 0,
      unitCostMinor: num(l.unitCostMinor) ?? 0,
    })),
    totalMinor: num(p.totalMinor) ?? 0,
    currency: text(p.currency) ?? "USD",
  };
}

/** What an approved proposal did, in words, by its command. Only shown once it executed. */
export function executedText(command: string): string {
  switch (command) {
    case "bill.pay":
      // PayPal accepts a payout at once and completes it a little later; the
      // bill reads paid only when PayPal says the payout completed.
      return "Sent with PayPal Payouts to the vendor's PayPal account (Sandbox). The bill reads paid once PayPal completes the payout, usually within minutes.";
    case "bill.record":
    case "bill.save":
    case "bill.approve":
      return "Filed as an approved payable. It is paid from Accountant, Bills.";
    case "bill.markPaid":
      return "Marked paid outside PayPal, with the proof attached.";
    case "supplier.order.propose":
    case "supplier.order.save":
      return "Saved as a purchase order. Nothing is paid until the supplier's bill matches the order and the delivery.";
    case "delivery.offer":
      return "Offered to the driver. The board shows their answer as soon as they accept or decline.";
    case "request.create":
    case "request.send":
    case "request.remind":
      return "Done. The payer pays on PayPal's page; this café sees it as soon as PayPal captures it.";
    default:
      return "Done.";
  }
}
