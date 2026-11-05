import { test } from "node:test";
import assert from "node:assert/strict";
import { ApiFailure } from "../src/lib/connected/api";
import { currency } from "../src/lib/connected/contracts";
import {
  actionView,
  ago,
  alreadyHandled,
  confirmedOutcome,
  idLookup,
  inboxRows,
  inboxSummary,
  lookupResult,
  outcomeOf,
  type InboxAction,
} from "../src/lib/connected/inbox";

const money = (minor: number, code: string) => currency(minor, code);

const refund = {
  id: 45,
  taskId: 145,
  agent: "complaints",
  command: "payment.refund",
  title: "Partly refund order #14: $8.50 USD",
  rationale: "The croque monsieur was missing.",
  risk: "money",
  status: "pending",
  version: 1,
  preview: { amountMinor: 850, currency: "USD", capturedMinor: 2150, alreadyRefundedMinor: 0, providerCaptureId: "CAP1" },
  evidence: { kind: "partial", paypalStatus: "COMPLETED", paypalSource: "paypal_mcp", currency: "USD" },
  createdAt: "2026-11-04T20:00:00.000Z",
  expiresAt: "2026-11-04T21:00:00.000Z",
  task: { id: 145, agent: "complaints", trigger: "event", status: "done", title: "", summary: null, chargedMicros: 2100, createdAt: "", completedAt: null, state: {} },
} as unknown as InboxAction;

test("the inbox keeps rows with an id and a title, newest first, with safe defaults", () => {
  const rows = inboxRows({
    rows: [
      { id: 3, title: "Older", agent: "payroll", command: "payout.send", risk: "money", version: 2 },
      { id: 9, title: "Newer" },
      { id: 5 },
      { title: "No id" },
      null,
    ],
  });
  assert.deepEqual(
    rows.map((r) => r.id),
    [9, 3],
  );
  assert.equal(rows[0].version, 1);
  assert.deepEqual(rows[0].preview, {});
  assert.equal(rows[0].status, "pending");
  assert.deepEqual(inboxRows(undefined), []);
  assert.deepEqual(inboxRows({ rows: "nope" }), []);
});

test("a refund proposal shows its PayPal capture and moves money to the guest", () => {
  const v = actionView(refund, money);
  assert.equal(v.who, "Complaints agent");
  assert.equal(v.movesMoney, true);
  assert.equal(v.rail, "PayPal refund to the guest");
  assert.deepEqual(v.amount, { minor: 850, currency: "USD" });
  assert.deepEqual(v.facts, ["$21.50 captured", "PayPal capture CAP1", "Partial refund", "PayPal: COMPLETED"]);
  assert.equal(v.aiCost, "$0.002");
  assert.equal(v.awaitingCheck, false);
});

test("a payroll batch names its people; a bill its vendor, due date on the café's clock, VAT and masked payee", () => {
  const payroll = actionView(
    {
      ...refund,
      agent: "payroll",
      command: "payout.send",
      preview: {
        batchId: 7,
        kind: "tips",
        totalMinor: 18400,
        currency: "USD",
        held: [{ recipientName: "Lina" }],
        items: [
          { recipientName: "Nadia", amountMinor: 7200 },
          { recipientName: "Omar", amountMinor: 6400 },
          { recipientName: "Sam", amountMinor: 4800 },
        ],
      },
      evidence: {},
    },
    money,
  );
  assert.deepEqual(payroll.facts, ["3 people", "Tips", "Nadia $72.00, Omar $64.00", "1 held: no PayPal email"]);
  assert.deepEqual(payroll.amount, { minor: 18400, currency: "USD" });
  assert.equal(payroll.rail, "PayPal Payouts to the team");

  const bill = actionView(
    {
      ...refund,
      agent: "accountant",
      command: "bill.pay",
      preview: { billId: 41, vendor: "Hudson Power", amountMinor: 19086, vatMinor: 1414, currency: "USD", dueAt: "2026-11-24T05:00:00.000Z", payeeEmail: "buyer-one@personal.example.com" },
      evidence: {},
    },
    money,
    "America/New_York",
  );
  assert.equal(bill.who, "AI accountant");
  assert.deepEqual(bill.facts, ["Hudson Power", "Due Nov 24", "VAT $14.14", "Pays bu…@personal.example.com"]);
});

test("a bare row never invents evidence; an ops proposal moves no money; a started approval says so", () => {
  const bare = actionView({ ...refund, command: "x", risk: "ops", preview: {}, evidence: {}, task: undefined, status: "approved" } as InboxAction, money);
  assert.deepEqual(bare.facts, []);
  assert.equal(bare.amount, undefined);
  assert.equal(bare.movesMoney, false);
  assert.equal(bare.rail, undefined);
  assert.equal(bare.aiCost, undefined);
  assert.equal(bare.awaitingCheck, true);
});

test("an outcome shows a PayPal id only when the result carries one", () => {
  assert.deepEqual(outcomeOf("payout.send", "executed", { providerBatchId: "B1", state: "sent" }), {
    tone: "done",
    text: "Sent with PayPal Payouts. Each person receives it in their PayPal account.",
    paypalId: "PayPal batch B1",
  });
  const pending = outcomeOf("payment.refund", "executed", { refundId: 9, state: "requested" });
  assert.equal(pending.tone, "done");
  assert.equal(pending.paypalId, undefined);
  assert.match(pending.text, /on its way to PayPal/);
  assert.equal(confirmedOutcome("payment.refund", "PayPal refund R1").paypalId, "PayPal refund R1");
  assert.match(confirmedOutcome("payment.refund", "PayPal refund R1").text, /^Refunded through PayPal/);
});

test("a refusal reads as a refusal, never as a result", () => {
  assert.deepEqual(outcomeOf("payout.send", "rejected"), { tone: "dismissed", text: "Turned down. Nothing changed." });
  assert.equal(outcomeOf("payout.send", "stale").tone, "expired");
  assert.equal(outcomeOf("payout.send", "expired").tone, "expired");
  const disabled = outcomeOf("bill.pay", "failed", { error: "provider_feature_disabled" });
  assert.equal(disabled.tone, "refused");
  assert.match(disabled.text, /Nothing was sent or charged/);
  const failed = outcomeOf("payment.refund", "failed", { error: "provider_error", message: "PayPal said no" });
  assert.deepEqual(failed, { tone: "failed", text: "It did not go through: PayPal said no" });
  assert.equal(outcomeOf("payment.refund", "failed").paypalId, undefined);
});

test("someone else deciding first is told apart from a refusal", () => {
  assert.equal(alreadyHandled(new ApiFailure("version_conflict", "This record changed.")), true);
  assert.equal(alreadyHandled(new ApiFailure("invalid_transition", "This action was already decided.")), true);
  assert.equal(alreadyHandled(new ApiFailure("not_found", "Action not found.")), true);
  assert.equal(alreadyHandled(new ApiFailure("forbidden", "No.")), false);
  assert.equal(alreadyHandled(new Error("network")), false);
  assert.equal(alreadyHandled(undefined), false);
});

test("PayPal's id is looked up on the record the command wrote", () => {
  assert.deepEqual(idLookup(refund), { kind: "complaint", taskId: 145 });
  assert.deepEqual(idLookup({ command: "bill.pay", taskId: 1, preview: { billId: 41 } }), { kind: "bill", id: 41 });
  assert.deepEqual(idLookup({ command: "payout.send", taskId: 1, preview: { batchId: 7 } }), { kind: "payout", id: 7 });
  assert.equal(idLookup({ command: "close.sign", taskId: 1, preview: {} }), undefined);
  assert.deepEqual(lookupResult("complaint", { providerRefundId: "R1" }), { paypalId: "PayPal refund R1" });
  assert.deepEqual(lookupResult("complaint", { providerRefundId: null, refundState: "failed" }), { refused: true });
  assert.deepEqual(lookupResult("complaint", { providerRefundId: null, refundState: "requested" }), {});
  assert.deepEqual(lookupResult("bill", { providerBatchId: "B2" }), { paypalId: "PayPal batch B2" });
  assert.deepEqual(lookupResult("payout", { state: "failed" }), { refused: true });
  assert.deepEqual(lookupResult("bill", undefined), {});
});

test("times read as words and the summary counts what moves money", () => {
  const now = new Date("2026-11-04T20:00:00Z");
  assert.equal(ago("2026-11-04T19:59:40Z", now), "just now");
  assert.equal(ago("2026-11-04T19:56:00Z", now), "4 min ago");
  assert.equal(ago("2026-11-04T17:30:00Z", now), "2 h ago");
  assert.equal(ago("2026-11-01T19:00:00Z", now), "3 days ago");
  assert.equal(ago(undefined, now), undefined);
  assert.equal(ago("not a date", now), undefined);
  assert.equal(inboxSummary([]), "You're all caught up.");
  assert.equal(inboxSummary([{ risk: "money" }, { risk: "ops" }]), "2 waiting for you · 1 moves money");
  assert.equal(inboxSummary([{ risk: "money" }, { risk: "money" }, { risk: "ops" }]), "3 waiting for you · 2 move money");
  assert.equal(inboxSummary([{ risk: "ops" }]), "1 waiting for you");
});
