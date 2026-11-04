import { test } from "node:test";
import assert from "node:assert/strict";
import {
  anomalyView,
  basisLabel,
  billNext,
  billNextLine,
  billView,
  coverRows,
  depositRequest,
  executedText,
  maskEmail,
  matchLines,
  matchTotals,
  monthOf,
  partnerLabel,
  partnerLines,
  pickBillFile,
  pickJob,
  pnlView,
  proposedOrder,
  rankingView,
  requestView,
  vatView,
} from "../src/lib/connected/try-new";

test("card 10 reads the build's bill file, else the newest approved one, never a rejected scan", () => {
  const media = [
    { id: 3, purpose: "menuSource", status: "approved" },
    { id: 7, purpose: "bill", status: "approved" },
    { id: 9, purpose: "bill", status: "approved" },
    { id: 11, purpose: "bill", status: "rejected" },
  ];
  assert.equal(pickBillFile(media, 7)?.id, 7);
  assert.equal(pickBillFile(media)?.id, 9);
  assert.equal(pickBillFile(media, 11)?.id, 9);
  assert.equal(pickBillFile([{ id: 1, purpose: "bill", status: "pending" }]), undefined);
});

test("a payee is recognisable without printing the whole address", () => {
  assert.equal(maskEmail("buyer-one@personal.example.com"), "bu…@personal.example.com");
  assert.equal(maskEmail("a@b.co"), "a…@b.co");
  assert.equal(maskEmail(""), undefined);
  assert.equal(maskEmail("nobody"), "…");
});

test("a bill reads its state, payee and what happens next", () => {
  const read = billView({
    id: 41,
    version: 3,
    vendor: "Hudson Power & Light · Sample",
    category: "electricity",
    reference: "HPL-2026-11-0417",
    amountMinor: 19086,
    vatMinor: 1414,
    currency: "USD",
    state: "review",
    payVia: "paypal",
    payeeEmail: "buyer-one@personal.example.com",
    read: { confidence: 94 },
  })!;
  assert.equal(read.sample, true);
  assert.equal(read.confidence, 0.94);
  assert.equal(billNext(read), "pay");
  assert.match(billNextLine(read), /takes PayPal: bu…@personal\.example\.com \(Sandbox\)/);

  const elsewhere = billView({ vendor: "Metro Water · Sample", state: "approved", payVia: "elsewhere" })!;
  assert.equal(billNext(elsewhere), "elsewhere");
  assert.match(billNextLine(elsewhere), /no PayPal account on file/);

  const twice = billView({ vendor: "Hudson", state: "review", payVia: "paypal", payeeEmail: "x@y.z", duplicateOfId: 12 })!;
  assert.equal(billNext(twice), "duplicate");
  assert.match(billNextLine(twice), /bill #12 again/);

  // Only PayPal's own batch id is quoted, and "paid" needs the state, not a guess.
  const paying = billView({ vendor: "Hudson", state: "paying", payVia: "paypal", payeeEmail: "x@y.z" })!;
  assert.equal(billNextLine(paying), "PayPal is being asked to pay it.");
  const paid = billView({ vendor: "Hudson", state: "paid", providerBatchId: "8XKQ2Y3ZT4W5A" })!;
  assert.match(billNextLine(paid), /batch 8XKQ2Y3ZT4W5A/);
  assert.equal(billView({ state: "review" }), undefined);
  assert.equal(billView(undefined), undefined);
});

test("the month is the café's month, not the browser's", () => {
  // 1 December 03:00 UTC is still 30 November in New York.
  assert.equal(monthOf(new Date("2026-12-01T03:00:00Z"), "America/New_York"), "2026-11");
  assert.equal(monthOf(new Date("2026-12-01T03:00:00Z"), "UTC"), "2026-12");
});

test("the profit and loss keeps its sides, drops empty lines and states the margin", () => {
  const pnl = pnlView({
    currency: "USD",
    revenue: [
      { account: "4000", name: "Sales", amountMinor: 120000 },
      { account: "4090", name: "Refunds", amountMinor: 0 },
    ],
    costs: [
      { account: "6000", name: "PayPal fees", amountMinor: 4300 },
      { account: "6100", name: "Utilities", amountMinor: 17680 },
    ],
    revenueMinor: 120000,
    costsMinor: 21980,
    netMinor: 98020,
    feesEstimated: true,
  });
  assert.deepEqual(
    pnl.lines.map((l) => `${l.group} ${l.account}`),
    ["Revenue 4000", "Costs 6000", "Costs 6100"],
  );
  assert.equal(pnl.marginPct, 81.7);
  assert.equal(pnl.feesEstimated, true);
  // Without totals they are summed from the lines; without revenue there is no margin.
  const bare = pnlView({ costs: [{ account: "6110", amountMinor: 180000 }] });
  assert.equal(bare.costsMinor, 180000);
  assert.equal(bare.netMinor, -180000);
  assert.equal(bare.marginPct, undefined);
});

test("VAT due is collected minus paid, and an unconfigured café says so", () => {
  assert.deepEqual(vatView({ collectedMinor: 900, paidMinor: 1414 }), {
    collectedMinor: 900,
    paidMinor: 1414,
    dueMinor: -514,
    configured: true,
  });
  assert.equal(vatView({ taxConfigured: false })?.configured, false);
  assert.equal(vatView(undefined), undefined);
});

test("an anomaly carries the PayPal ids it is about, from wherever the backend put them", () => {
  const flags = anomalyView([
    { title: "A capture with no order", providerCaptureId: "6KA28102CB433905M" },
    { kind: "newPayee", detail: "First payout to this email.", evidence: { providerBatchId: "TMS8FKRT6ALYU" } },
    { nothing: true },
    { kind: "cash_shortfall", facts: "Cash would fall to -$120.00 within 30 days." },
  ]);
  assert.equal(flags.length, 3);
  assert.deepEqual(flags[0].ids, ["PayPal capture 6KA28102CB433905M"]);
  // A rule's code is never shown raw: unknown ones become words.
  assert.equal(flags[1].title, "New payee");
  assert.deepEqual(flags[1].ids, ["PayPal payout batch TMS8FKRT6ALYU"]);
  assert.equal(flags[2].title, "Cash may run short");
  assert.equal(flags[2].detail, "Cash would fall to -$120.00 within 30 days.");
});

test("a pay link is shown only as https, and paid only when the backend says paid", () => {
  const open = requestView({ id: 5, payUrl: "https://api.rays.to/pay/abc", state: "open", amountMinor: 3555, payerName: depositRequest.payerName })!;
  assert.equal(open.payUrl, "https://api.rays.to/pay/abc");
  assert.equal(open.paid, false);
  assert.equal(open.sample, true);
  assert.equal(requestView({ id: 6, payUrl: "javascript:alert(1)" })!.payUrl, undefined);
  assert.equal(requestView({ id: 7, state: "paid", providerCaptureId: "9AB" })!.captureId, "9AB");
  assert.equal(requestView({ state: "open" }), undefined);
  assert.equal(depositRequest.kind, "link");
  assert.ok(depositRequest.payerName.endsWith("· Sample"));
});

test("dispatch picks the partner's own job, else the newest one that needs a driver", () => {
  const rows = [
    { id: 1, status: "unassigned", fulfilledBy: "restaurant" },
    { id: 2, status: "unassigned", fulfilledBy: "restaurant", partnerRef: "sim-42" },
    { id: 3, status: "unassigned", fulfilledBy: "partner" },
    { id: 4, status: "assigned", fulfilledBy: "restaurant" },
    { id: 5, status: "unassigned", fulfilledBy: "restaurant", offer: { offerId: 9 } },
  ];
  assert.equal(pickJob(rows, "sim-42")?.id, 2);
  assert.equal(pickJob(rows)?.id, 2);
  assert.equal(pickJob(rows.slice(2)), undefined);
});

test("the ranking is best first and keeps its reasons", () => {
  const ranked = rankingView([
    { driverId: 3, name: "Ines · Sample", vehicle: "scooter", score: 81, activeJobs: 0, reasons: ["At the café"] },
    { driverId: 2, name: "Sam · Sample", vehicle: "bike", score: 88.4, activeJobs: 1, minutes: 6 },
    { driverId: 0, name: "Nobody" },
  ]);
  assert.deepEqual(
    ranked.map((r) => r.driverId),
    [2, 3],
  );
  assert.equal(ranked[0].sample, true);
  assert.deepEqual(ranked[1].reasons, ["At the café"]);
});

test("the partner log reads both directions, oldest first, and only this order's events", () => {
  const lines = partnerLines(
    [
      { id: 3, direction: "out", type: "order.accepted", status: "delivered", responseCode: 200, ref: "sim-42", createdAt: "2026-11-08T10:00:03Z" },
      { id: 2, direction: "in", type: "orders.create", status: "accepted", ref: "sim-42", createdAt: "2026-11-08T10:00:01Z" },
      { id: 1, direction: "in", type: "orders.create", status: "accepted", ref: "sim-41", createdAt: "2026-11-08T09:00:00Z" },
    ],
    "sim-42",
  );
  assert.deepEqual(
    lines.map((l) => l.id),
    [2, 3],
  );
  assert.equal(partnerLabel(lines[0]), "Received from the partner: orders.create · accepted");
  assert.equal(partnerLabel(lines[1]), "Signed webhook to the partner: order.accepted · delivered (HTTP 200)");
});

test("stock most at risk comes first", () => {
  const rows = coverRows([
    { stockItemId: 1, name: "Flour T55", unit: "kg", quantity: 12, daysCover: 9.5, reorder: false },
    { stockItemId: 2, name: "Espresso beans", unit: "kg", quantity: 2, daysCover: 2.1, reorder: true, suggestedQty: 4.5 },
    { stockItemId: 3, name: "Gruyère", unit: "kg", quantity: 1.2, reorder: false },
    { stockItemId: 4, name: "Butter AOP", unit: "kg", quantity: 3.5, daysCover: 4, reorder: true, suggestedQty: 6.5 },
  ]);
  assert.deepEqual(
    rows.map((r) => r.name),
    ["Espresso beans", "Butter AOP", "Flour T55", "Gruyère"],
  );
  assert.equal(basisLabel("movements"), "usage from 28 days of sales and waste");
  assert.match(basisLabel(undefined), /low marks/);
});

test("the 3-way match flags the butter's price and totals the three papers", () => {
  const lines = matchLines({
    lines: [
      { name: "Button mushrooms", unit: "kg", qty: 6, unitCostMinor: 650, receivedQty: 6, receivedUnitCostMinor: 650 },
      { name: "Butter AOP", unit: "kg", qty: 10, unitCostMinor: 980, receivedQty: 10, receivedUnitCostMinor: 1040 },
    ],
  });
  assert.deepEqual(
    lines.map((l) => [l.name, l.pricePct, l.flag]),
    [
      ["Button mushrooms", 0, false],
      ["Butter AOP", 6.1, true],
    ],
  );
  assert.deepEqual(matchTotals(lines, 14300), {
    orderedMinor: 13700,
    deliveredMinor: 14300,
    billMinor: 14300,
    diffMinor: 600,
  });
  // A short delivery is flagged even at the ordered price.
  const short = matchLines({ lines: [{ name: "Eggs", qty: 120, unitCostMinor: 32, receivedQty: 100 }] });
  assert.equal(short[0].qtyDiff, -20);
  assert.equal(short[0].flag, true);
});

test("a proposed order reads the planner's preview", () => {
  const order = proposedOrder({
    supplier: "Marché Dupont",
    lines: [{ name: "Espresso beans", unit: "kg", qty: 4.5, unitCostMinor: 2200 }],
    totalMinor: 9900,
    currency: "USD",
  });
  assert.equal(order.supplier, "Marché Dupont");
  assert.equal(order.lines[0].qty, 4.5);
  assert.equal(proposedOrder(undefined).supplier, "No supplier yet");
});

test("an approval's words name what really ran, and money only for bill.pay", () => {
  assert.match(executedText("bill.pay"), /PayPal Payouts/);
  assert.doesNotMatch(executedText("supplier.order.propose"), /PayPal/);
  assert.doesNotMatch(executedText("delivery.offer"), /PayPal/);
  assert.equal(executedText("anything.else"), "Done.");
});
