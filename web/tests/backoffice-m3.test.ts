import { test } from "node:test";
import assert from "node:assert/strict";
import type { PayoutBatch, Shift } from "../src/lib/connected/backoffice";
import { approvalNotice, hourWindow, latestSent, payoutFor, paypalIdOf, peopleOf, spendShare } from "../src/lib/connected/money-view";

const now = new Date("2026-11-03T20:00:00.000Z");
const shift = (over: Partial<Shift> = {}): Shift => ({
  id: 1,
  version: 1,
  name: "Nadia",
  role: "staff",
  startsAt: "2026-11-03T09:00:00.000Z",
  endsAt: "2026-11-03T17:00:00.000Z",
  hourlyRateMinor: 1600,
  ...over,
});
const batch = (over: Partial<PayoutBatch> = {}): PayoutBatch => ({
  id: 1,
  version: 1,
  kind: "tips",
  periodFrom: "2026-10-27",
  periodTo: "2026-11-02",
  totalMinor: 2000,
  currency: "USD",
  state: "sent",
  createdAt: "2026-11-03T10:00:00.000Z",
  items: [{ recipientName: "Nadia", amountMinor: 1334, state: "sent" }],
  ...over,
});

test("PayPal's id is read from an approval's result, the payout batch first", () => {
  assert.equal(paypalIdOf({ providerBatchId: "EUG58M87BKY5E", state: "sent" }), "PayPal batch EUG58M87BKY5E");
  assert.equal(paypalIdOf({ invoiceNumber: "0007" }), "PayPal invoice 0007");
  assert.equal(paypalIdOf({ providerRefundId: "1AB" }), "PayPal refund 1AB");
  assert.equal(paypalIdOf({ closeId: 1 }), undefined);
  assert.equal(paypalIdOf(undefined), undefined);
});

test("the snackbar after an approval says what PayPal did, or why it did not", () => {
  assert.equal(approvalNotice("executed", { providerBatchId: "X1" }), "Approved. PayPal batch X1.");
  assert.equal(approvalNotice("executed", { closeId: 1 }), "Approved.");
  assert.equal(approvalNotice("rejected"), "Turned down. Nothing changed.");
  assert.match(approvalNotice("failed", { error: "provider_feature_disabled" }), /not enabled on the Sandbox app yet/);
  assert.equal(approvalNotice("failed", { message: "PayPal returned no invoice id." }), "It did not go through: PayPal returned no invoice id.");
});

test("people are one card per name with their week's hours, wage and state", () => {
  const people = peopleOf(
    [
      shift({ id: 1, clockInAt: "2026-11-03T09:00:00.000Z", clockOutAt: "2026-11-03T13:00:00.000Z" }),
      shift({ id: 2, startsAt: "2026-11-04T09:00:00.000Z", endsAt: "2026-11-04T12:00:00.000Z", payoutEmail: "n@example.com" }),
      shift({ id: 3, name: "Omar", role: "kitchen", hourlyRateMinor: 1800, clockInAt: "2026-11-03T18:00:00.000Z", endsAt: "2026-11-03T23:00:00.000Z", startsAt: "2026-11-03T18:00:00.000Z" }),
    ],
    now,
  );
  assert.deepEqual(
    people.map((p) => [p.name, p.hours, p.wageMinor, p.state]),
    [
      ["Nadia", 7, 11200, "planned"],
      ["Omar", 2, 3600, "onShift"],
    ],
  );
  assert.equal(people[0].payoutEmail, "n@example.com");
  assert.equal(people[1].role, "kitchen");
});

test("a person's payout is the newest batch that names them; the latest sent batch skips proposals", () => {
  const older = batch({ id: 1, state: "completed", createdAt: "2026-10-27T10:00:00.000Z", items: [{ recipientName: "Nadia", amountMinor: 900, state: "completed" }] });
  const newer = batch({ id: 2, state: "sent" });
  const proposal = batch({ id: 3, state: "proposed", createdAt: "2026-11-04T10:00:00.000Z" });
  assert.deepEqual(payoutFor("nadia", [older, newer, proposal]), { state: "sent", amountMinor: 1334, currency: "USD", kind: "tips" });
  assert.equal(payoutFor("Lina", [older, newer]), undefined);
  assert.equal(latestSent([older, newer, proposal])?.id, 2);
  assert.equal(latestSent([proposal]), undefined);
});

test("a spend bar is a share of the biggest spender", () => {
  const all = [{ spentMinor: 4000 }, { spentMinor: 1000 }, { spentMinor: 0 }];
  assert.equal(spendShare(all[0], all), 1);
  assert.equal(spendShare(all[1], all), 0.25);
  assert.equal(spendShare(all[2], all), 0);
  assert.equal(spendShare({ spentMinor: 0 }, [{ spentMinor: 0 }]), 0);
});

test("sales by hour keep every hour of a day, never narrower than 7:00 to 21:00", () => {
  const quiet = hourWindow([]);
  assert.equal(quiet[0].hour, 7);
  assert.equal(quiet[quiet.length - 1].hour, 21);
  assert.ok(quiet.every((h) => h.salesMinor === 0));
  const late = hourWindow([
    { hour: 6, salesMinor: 500, orders: 1 },
    { hour: 23, salesMinor: 900, orders: 1 },
  ]);
  assert.equal(late[0].hour, 5);
  assert.equal(late[late.length - 1].hour, 23);
  assert.equal(late.find((h) => h.hour === 6)?.salesMinor, 500);
  assert.equal(late.length, 19);
  assert.equal(late[0].label, "5:00");
});
