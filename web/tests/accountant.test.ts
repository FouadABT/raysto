import { test } from "node:test";
import assert from "node:assert/strict";
import {
  agingRows,
  billActions,
  cashRows,
  kpisOf,
  paypalEvidence,
  pnlRows,
  requestData,
  type BillRow,
  type BillsPage,
  type Cashflow,
  type RequestsPage,
} from "../src/lib/connected/accountant";
import { fileProblem } from "../src/lib/connected/uploads";

const bill = (b: Partial<BillRow>): BillRow =>
  ({ id: 1, vendor: "Power Co", category: "electricity", account: "6100", amountMinor: 1000, vatMinor: 0, currency: "USD", state: "review", payVia: "elsewhere", overdue: false, version: 1, createdAt: "2026-11-01T00:00:00Z", ...b }) as BillRow;

test("a bill offers its one useful next step first, and nothing once PayPal has it", () => {
  assert.deepEqual(billActions(bill({ state: "review", payVia: "paypal", payeeEmail: "a@b.co" })), ["pay", "approve", "markPaid", "void"]);
  assert.deepEqual(billActions(bill({ state: "review" })), ["approve", "markPaid", "void"]);
  assert.deepEqual(billActions(bill({ state: "approved", payVia: "paypal", payeeEmail: "a@b.co" })), ["pay", "markPaid", "void"]);
  // A PayPal bill without an email cannot be paid through Payouts.
  assert.deepEqual(billActions(bill({ state: "approved", payVia: "paypal", payeeEmail: null })), ["markPaid", "void"]);
  assert.deepEqual(billActions(bill({ state: "expected" })), ["markPaid", "void"]);
  for (const state of ["paying", "paid", "paidElsewhere", "void"] as const) assert.deepEqual(billActions(bill({ state })), [], state);
});

test("the PayPal column never claims a payment without PayPal's id or a proof", () => {
  assert.equal(paypalEvidence(bill({ state: "paid", providerBatchId: "B-1", payoutState: "completed", providerItemId: "I-1" })), "PayPal Payouts B-1 · item I-1 · completed");
  assert.equal(paypalEvidence(bill({ state: "paidElsewhere", proofMediaId: 9 })), "Paid elsewhere · proof #9");
  assert.equal(paypalEvidence(bill({ state: "paying" })), "Asking PayPal…");
  assert.equal(paypalEvidence(bill({ state: "approved", read: { payoutFailed: "DENIED" } })), "PayPal did not pay it: DENIED");
  assert.equal(paypalEvidence(bill({ state: "review" })), "");
});

test("P&L rows make costs negative so the pivot's total row is the profit", () => {
  const rows = pnlRows([
    { month: "2026-11", account: "4000", accountName: "Sales", group: "Revenue", amountMinor: 10000 },
    { month: "2026-11", account: "6100", accountName: "Utilities", group: "Costs", amountMinor: 2500 },
  ]);
  assert.deepEqual(rows[0], { group: "Revenue", account: "4000 Sales", month: "2026-11", amount: 100 });
  assert.equal(rows[1].amount, -25);
  assert.equal(rows.reduce((n, r) => n + Number(r.amount), 0), 75);
});

test("cash rows run the balance back from today and forward through the forecast", () => {
  const cash: Cashflow = {
    currency: "USD",
    history: [
      { date: "2026-11-02", inMinor: 1000, outMinor: 200, netMinor: 800 },
      { date: "2026-11-03", inMinor: 500, outMinor: 100, netMinor: 400 },
    ],
    forecast: [{ date: "2026-11-04", inMinor: 700, outMinor: 300, balanceMinor: 5400, items: [] }],
    openingMinor: 5000,
    averageDailyInMinor: 700,
    averageDailyNetMinor: 600,
    lowestMinor: 5000,
    overdue: [],
    basis: "",
  };
  const rows = cashRows(cash);
  assert.equal(rows.length, 6);
  assert.deepEqual(rows.map((r) => r.day), ["2026-11-02", "2026-11-02", "2026-11-03", "2026-11-03", "2026-11-04", "2026-11-04"]);
  // Today's balance is the opening; the day before is 400 less.
  assert.equal(rows[2].balance, 50);
  assert.equal(rows[0].balance, 46);
  assert.equal(rows[1].amount, -2);
  assert.equal(rows[4].part, "Forecast");
  assert.equal(rows[4].balance, 54);
  assert.deepEqual(cashRows(undefined), []);
});

test("aging takes only unpaid bills, in their age buckets", () => {
  const rows = agingRows([
    bill({ state: "approved", bucket: "31–60", amountMinor: 4200, overdue: true }),
    bill({ state: "paid", bucket: null }),
    bill({ state: "expected", bucket: "0–30" }),
  ]);
  assert.deepEqual(rows, [{ vendor: "Power Co", category: "Electricity", bucket: "31–60 days", amount: 42, overdue: "Overdue" }]);
});

test("overview figures add the cash days, bills and requests", () => {
  const k = kpisOf(
    { summary: { dueMinor: 900, overdueMinor: 100, overdueCount: 1, reviewCount: 0, expectedMinor: 0, paidThisMonthMinor: 0, aging: {} } } as unknown as BillsPage,
    { summary: { outstandingMinor: 1200, overdueMinor: 50, paidThisMonthMinor: 0 } } as unknown as RequestsPage,
    { history: [{ date: "d", inMinor: 1000, outMinor: 300, netMinor: 700 }] } as unknown as Cashflow,
  );
  assert.deepEqual(k, { cashInMinor: 1000, cashOutMinor: 300, netMinor: 700, billsDueMinor: 900, overdueMinor: 150, receivablesMinor: 1200 });
  assert.deepEqual(kpisOf(), { cashInMinor: 0, cashOutMinor: 0, netMinor: 0, billsDueMinor: 0, overdueMinor: 0, receivablesMinor: 0 });
});

test("a payment request is checked before it is sent", () => {
  const base = { kind: "link" as const, payerName: "Acme", payerEmail: "", description: "Lunch", amount: "120.50", dueAt: "" };
  assert.deepEqual(requestData(base), { ok: true, data: { kind: "link", payerName: "Acme", description: "Lunch", amountMinor: 12050 } });
  assert.equal(requestData({ ...base, amount: "0" }).ok, false);
  assert.equal(requestData({ ...base, amount: "1.234" }).ok, false);
  assert.equal(requestData({ ...base, kind: "invoice" }).ok, false);
  assert.equal(requestData({ ...base, payerEmail: "not-an-email" }).ok, false);
  const invoice = requestData({ ...base, kind: "invoice", payerEmail: "a@acme.example", dueAt: "2026-11-30" });
  assert.ok(invoice.ok && invoice.data.payerEmail === "a@acme.example" && typeof invoice.data.dueAt === "string");
});

test("only photos and PDFs up to 8 MB are sent", () => {
  assert.equal(fileProblem({ type: "application/pdf", size: 1000 }), null);
  assert.equal(fileProblem({ type: "image/webp", size: 1000 }), null);
  assert.match(fileProblem({ type: "image/gif", size: 1000 }) ?? "", /PDF/);
  assert.match(fileProblem({ type: "image/jpeg", size: 0 }) ?? "", /empty/);
  assert.match(fileProblem({ type: "image/jpeg", size: 8 * 1024 * 1024 + 1 }) ?? "", /8 MB/);
});
