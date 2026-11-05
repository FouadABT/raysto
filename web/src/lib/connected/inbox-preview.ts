/**
 * Development only: the Overview's AI Action Inbox on the preview's fixture
 * API (/ops/preview), in the shapes the backend answers (agents.dart
 * `inbox` and `decide`, the complaints, payroll and accountant agents, pay
 * links, `ledger.journal`). Every PayPal id here says PREVIEW: none of it is
 * a PayPal result, and nothing leaves the browser.
 *
 * - `?state=inbox`: five proposals. Approving one returns what the backend
 *   would (a refund's PayPal id arrives a moment later, on the complaint);
 *   the oldest was already decided by someone else.
 * - `?state=caught-up`: an empty inbox whose four starters run: their
 *   agents finish at once and their proposals land in the inbox.
 * Any state but "empty" also answers `ledger.journal` with 30 sample days.
 */
import { ApiFailure } from "./api";
import type { Json } from "./contracts";

type Handlers = Record<string, (data: Json, options: { id?: number; version?: number }) => unknown>;

const USD = "USD";

function action(id: number, taskId: number, agent: string, command: string, risk: string, title: string, rationale: string, preview: Json, evidence: Json, asOf: string, minutesAgo: number): Json {
  const at = new Date(new Date(asOf).getTime() - minutesAgo * 60000).toISOString();
  return {
    id,
    taskId,
    agent,
    command,
    title,
    rationale,
    risk,
    status: "pending",
    version: 1,
    preview,
    evidence,
    createdAt: at,
    expiresAt: new Date(new Date(asOf).getTime() + 86400000).toISOString(),
    task: { id: taskId, agent, status: "done", title, summary: rationale, chargedMicros: 1800 + id * 10, createdAt: at, state: {} },
  };
}

const refund = (id: number, taskId: number, asOf: string, minutesAgo: number) =>
  action(
    id,
    taskId,
    "complaints",
    "payment.refund",
    "money",
    "Partly refund order #14: $8.50 USD",
    "The guest says the croque monsieur was missing. The kitchen ticket never marked it done and PayPal's capture is complete, so refunding that dish is fair.",
    { amountMinor: 850, currency: USD, capturedMinor: 2150, alreadyRefundedMinor: 0, providerCaptureId: "PREVIEWCAPTURE7" },
    { kind: "partial", paypalStatus: "COMPLETED", paypalSource: "paypal_mcp", capturedMinor: 2150, refundedMinor: 0, currency: USD },
    asOf,
    minutesAgo,
  );
const billPay = (id: number, taskId: number, asOf: string, minutesAgo: number) =>
  action(
    id,
    taskId,
    "accountant",
    "bill.pay",
    "money",
    "Pay Hudson Power & Light · Sample $190.86",
    "October's electricity bill: same vendor and PayPal payee as last month, 8% higher with the colder weeks. Due on 24 November.",
    {
      billId: 41,
      vendor: "Hudson Power & Light · Sample",
      category: "electricity",
      reference: "HPL-2026-11-0417",
      amountMinor: 19086,
      vatMinor: 1414,
      currency: USD,
      dueAt: "2026-11-24T05:00:00.000Z",
      payVia: "paypal",
      payeeEmail: "buyer-one@personal.example.com",
    },
    {},
    asOf,
    minutesAgo,
  );
const payroll = (id: number, taskId: number, asOf: string, minutesAgo: number) =>
  action(
    id,
    taskId,
    "payroll",
    "payout.send",
    "money",
    "Pay this week's tips: $184.00 to 3 people",
    "The tip pool split by hours and role from this week's clocked shifts. Everyone has a PayPal email on file.",
    {
      batchId: 7,
      kind: "tips",
      totalMinor: 18400,
      currency: USD,
      held: [],
      items: [
        { recipientName: "Nadia", amountMinor: 7200 },
        { recipientName: "Omar", amountMinor: 6400 },
        { recipientName: "Lina", amountMinor: 4800 },
      ],
    },
    {},
    asOf,
    minutesAgo,
  );

/** Thirty days of journal lines: sales by PayPal and cash, fees, wages, rent, a bill and a refund. */
function journal(asOf: string): Json[] {
  const lines: Json[] = [];
  const end = new Date(asOf);
  const line = (date: string, account: string, accountName: string, debitMinor: number, creditMinor: number, estimated = false) =>
    lines.push({ date, account, accountName, debitMinor, creditMinor, currency: USD, source: { type: "preview", ...(estimated ? { estimated: true } : {}) } });
  for (let i = 29; i >= 0; i--) {
    const at = new Date(end.getTime() - i * 86400000);
    const date = at.toISOString().slice(0, 10);
    const weekday = at.getUTCDay();
    const paypal = 12000 + ((i * 37) % 9) * 1500 + (weekday === 5 || weekday === 6 ? 9000 : 0);
    const cash = 3000 + ((i * 13) % 5) * 700;
    line(date, "1000", "PayPal balance", paypal, 0);
    line(date, "4000", "Sales", 0, paypal);
    line(date, "1010", "Cash and bank", cash, 0);
    line(date, "4000", "Sales", 0, cash);
    const fee = Math.round(paypal * 0.0349) + 49;
    line(date, "6000", "PayPal fees", fee, 0, true);
    line(date, "1000", "PayPal balance", 0, fee);
    if (weekday === 1) {
      line(date, "6020", "Wages", 52000, 0);
      line(date, "1000", "PayPal balance", 0, 52000);
    }
    if (i === 24) {
      line(date, "6110", "Rent", 180000, 0);
      line(date, "1010", "Cash and bank", 0, 180000);
    }
    if (i === 9) {
      line(date, "6100", "Utilities", 17672, 0);
      line(date, "1000", "PayPal balance", 0, 17672);
    }
    if (i === 3) {
      line(date, "4090", "Refunds", 850, 0);
      line(date, "1000", "PayPal balance", 0, 850);
    }
  }
  return lines;
}

export function inboxPreview(state: string, asOf: string): { queries: Record<string, (p: Json) => unknown>; commands: Handlers } {
  // The Try section, opened with `?section=try`, reads the menu when it mounts.
  const queries: Record<string, (p: Json) => unknown> = { "counter.menu": () => ({ menu: [] }) };
  const commands: Handlers = {};
  if (state !== "empty" && state !== "failed")
    queries["ledger.journal"] = () => ({ currency: USD, rows: journal(asOf), truncated: false, balanced: true });
  if (state !== "inbox" && state !== "caught-up") return { queries, commands };

  let rows: Json[] =
    state === "inbox"
      ? [
          refund(45, 145, asOf, 3),
          billPay(44, 144, asOf, 12),
          payroll(43, 143, asOf, 40),
          action(
            42,
            142,
            "supplies",
            "supplier.order.propose",
            "ops",
            "Order from Marché Dupont: espresso beans and butter",
            "Espresso beans run out before Dupont's next delivery and butter is below its low mark. Nothing is paid until the bill matches the delivery.",
            { supplier: "Marché Dupont", totalMinor: 16270, currency: USD },
            {},
            asOf,
            95,
          ),
          action(
            41,
            141,
            "payments",
            "payment.release",
            "money",
            "Release an unfinished PayPal checkout of $4.50",
            "A diner opened PayPal for an espresso and walked away 40 minutes ago. PayPal holds nothing for it.",
            { amountMinor: 450, currency: USD },
            { paypalStatus: "CREATED", paypalSource: "paypal_mcp", ledgerState: "approved" },
            asOf,
            180,
          ),
        ]
      : [];
  const drop = (id: number) => (rows = rows.filter((r) => Number(r.id) !== id));
  const complaints: Json[] = [];
  let complaintReads = 0;
  let requestReads = 0;
  const tasks: Record<number, Json> = {};
  const finish = (taskId: number, made: Json) => {
    tasks[taskId] = { id: taskId, status: "done", summary: made.rationale, chargedMicros: 2100, trace: [], actions: [made] };
    if (!rows.some((r) => r.id === made.id)) rows = [made, ...rows];
  };

  queries["agent.inbox"] = () => ({ rows });
  queries["agent.task"] = (p) => tasks[Number(p.id)] ?? { id: Number(p.id), status: "done", actions: [] };
  queries.complaints = () => {
    complaintReads++;
    return {
      rows: complaints.map((c) =>
        c.status === "refunded" ? { ...c, providerRefundId: complaintReads >= 2 ? "PREVIEWREFUND7Q" : null, refundState: complaintReads >= 2 ? "completed" : "requested" } : c,
      ),
    };
  };
  queries.media = () => ({ rows: [{ id: 12, purpose: "bill", status: "approved" }] });
  // The complaint starter looks for an order PayPal captured: ticket #14.
  queries.checkouts = () => ({
    rows: [{ id: 90, checkoutId: 90, orderId: 27, visitId: null, method: "paypal", state: "completed", amountMinor: 2150, currency: USD, createdAt: asOf }],
    nextCursor: null,
  });
  queries.order = (p) => ({
    id: Number(p.id),
    number: 14,
    status: "completed",
    paymentStatus: "paid",
    totalMinor: 2150,
    currency: USD,
    lines: [{ name: "Croque monsieur", quantity: 1 }],
    payments: [{ checkoutId: 90, method: "paypal", amountMinor: 2150, currency: USD, state: "completed", providerCaptureId: "PREVIEWCAPTURE7", refunds: [] }],
  });
  queries.request = () => ({
    id: 5,
    version: 1,
    kind: "link",
    payerName: "Studio Lumen · Sample",
    description: "Catering deposit · Friday lunch for 12",
    amountMinor: 3555,
    currency: USD,
    payUrl: "https://api.rays.to/pay/preview-token",
    // Made (1), then paid from the fourth read on: about six seconds of waiting.
    ...(++requestReads >= 4 ? { state: "paid", providerCaptureId: "PREVIEWCAPTURE2" } : { state: "open" }),
  });

  commands["agent.decide"] = (data, options) => {
    const id = Number(options.id);
    // The oldest proposal was decided by someone else a moment ago.
    if (id === 41) {
      drop(id);
      throw new ApiFailure("invalid_transition", "This action was already decided.");
    }
    const row = rows.find((r) => Number(r.id) === id);
    if (!row) throw new ApiFailure("not_found", "Action not found.");
    drop(id);
    if (data.decision === "reject") return { state: "rejected", actionId: id };
    switch (row.command) {
      case "payment.refund":
        complaints.push({ id: 3, orderId: 27, taskId: row.taskId, text: "My croque monsieur was missing from the bag.", status: "refunded", refundId: 9 });
        complaintReads = 0;
        return { state: "executed", actionId: id, result: { refundId: 9, state: "requested" } };
      case "bill.pay":
        return { state: "executed", actionId: id, result: { billId: 41, state: "paying", providerBatchId: "PREVIEWBATCH02" } };
      case "payout.send":
        return { state: "executed", actionId: id, result: { batchId: 7, state: "sent", providerBatchId: "PREVIEWBATCH03" } };
      default:
        return { state: "executed", actionId: id, result: {} };
    }
  };
  // The starters: each agent finishes at once and its proposal lands in the inbox.
  commands["payroll.run"] = () => {
    finish(301, payroll(46, 301, new Date().toISOString(), 0));
    return { taskId: 301 };
  };
  commands["bill.snap"] = () => {
    finish(302, billPay(47, 302, new Date().toISOString(), 0));
    return { mediaId: 12, taskId: 302, duplicateOfId: null };
  };
  commands["complaint.open"] = (_data, options) => {
    complaints.push({ id: 4, orderId: Number(options.id), taskId: 303, text: "My order was missing from the bag.", status: "open" });
    finish(303, refund(48, 303, new Date().toISOString(), 0));
    return { id: 4, taskId: 303 };
  };
  commands["request.create"] = () => {
    requestReads = 0;
    return { ...(queries.request({}) as Json), state: "open" };
  };
  return { queries, commands };
}
