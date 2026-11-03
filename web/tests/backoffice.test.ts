import { test } from "node:test";
import assert from "node:assert/strict";
import {
  barScale,
  batchTotal,
  clockAction,
  closeDelta,
  closeSourceLabel,
  gapLabel,
  localDay,
  marginPercent,
  shiftHours,
  shiftPayMinor,
  shiftState,
  weekRange,
  type Shift,
} from "../src/lib/connected/backoffice";

const shift = (over: Partial<Shift> = {}): Shift => ({
  id: 1,
  version: 1,
  name: "Nadia",
  role: "staff",
  startsAt: "2026-11-03T09:00:00.000Z",
  endsAt: "2026-11-03T17:00:00.000Z",
  hourlyRateMinor: 1500,
  ...over,
});

test("planned hours come from the plan, clocked hours from the clock, in quarter hours", () => {
  assert.equal(shiftHours(shift()), 8);
  assert.equal(shiftHours(shift({ clockInAt: "2026-11-03T09:10:00.000Z", clockOutAt: "2026-11-03T16:50:00.000Z" })), 7.75);
  // Still on shift: counted up to now, never past the planned end.
  const now = new Date("2026-11-03T12:00:00.000Z");
  assert.equal(shiftHours(shift({ clockInAt: "2026-11-03T09:00:00.000Z" }), now), 3);
  assert.equal(shiftHours(shift({ clockInAt: "2026-11-03T09:00:00.000Z" }), new Date("2026-11-03T20:00:00.000Z")), 8);
  assert.equal(shiftHours(shift({ endsAt: "2026-11-03T08:00:00.000Z" })), 0);
});

test("pay is hours times the rate, rounded to the cent", () => {
  assert.equal(shiftPayMinor(shift()), 12000);
  assert.equal(shiftPayMinor(shift({ clockInAt: "2026-11-03T09:10:00.000Z", clockOutAt: "2026-11-03T16:50:00.000Z", hourlyRateMinor: 1333 })), 10331);
});

test("a shift reads as planned, on shift, done or missed", () => {
  const now = new Date("2026-11-03T12:00:00.000Z");
  assert.equal(shiftState(shift(), now), "planned");
  assert.equal(shiftState(shift({ clockInAt: "2026-11-03T09:00:00.000Z" }), now), "onShift");
  assert.equal(shiftState(shift({ clockInAt: "2026-11-03T09:00:00.000Z", clockOutAt: "2026-11-03T11:00:00.000Z" }), now), "done");
  assert.equal(shiftState(shift(), new Date("2026-11-04T12:00:00.000Z")), "missed");
  assert.equal(clockAction(shift()), "in");
  assert.equal(clockAction(shift({ clockInAt: "x" })), "out");
  assert.equal(clockAction(shift({ clockInAt: "x", clockOutAt: "y" })), null);
});

test("the week runs Monday to the next Monday", () => {
  const { from, to } = weekRange(new Date(2026, 10, 5, 15)); // Thursday 5 Nov 2026
  assert.equal(new Date(from).getDay(), 1);
  assert.equal(new Date(from).getDate(), 2);
  assert.equal((new Date(to).getTime() - new Date(from).getTime()) / 86_400_000, 7);
  assert.equal(localDay(new Date(2026, 0, 9)), "2026-01-09");
});

test("the close shows the difference between PayPal and Raysto, or that they match", () => {
  const summary = { paypalCapturedMinor: 12050, raystoCapturedMinor: 12050, refundsMinor: 0, tipsMinor: 0, cashMinor: 0, feesMinor: 0 };
  assert.deepEqual(closeDelta({ summary }), { minor: 0, matches: true });
  assert.deepEqual(closeDelta({ summary: { ...summary, raystoCapturedMinor: 12000 } }), { minor: 50, matches: false });
  assert.equal(closeSourceLabel("paypal_transactions"), "PayPal's transaction list");
  assert.equal(closeSourceLabel("raysto_ledger"), "Raysto's own ledger (PayPal webhooks)");
});

test("gaps get short labels, never the model's words", () => {
  assert.equal(gapLabel({ kind: "fee" }), "PayPal fee");
  assert.equal(gapLabel({ kind: "unpaidTicket" }), "Unpaid ticket");
  assert.equal(gapLabel({ kind: "missingCapture" }), "Capture not in Raysto");
  assert.equal(gapLabel({ kind: "somethingElse" }), "Something Else");
});

test("charts scale to the tallest bar and margins are a percentage of the price", () => {
  assert.deepEqual(barScale([0, 50, 100]), [0, 0.5, 1]);
  assert.deepEqual(barScale([]), []);
  assert.deepEqual(barScale([0, 0]), [0, 0]);
  assert.equal(marginPercent({ priceMinor: 1000, costMinor: 400 }), 60);
  assert.equal(marginPercent({ priceMinor: 0, costMinor: 400 }), null);
  assert.equal(batchTotal({ items: [{ recipientName: "a", amountMinor: 1200, state: "pending" }, { recipientName: "b", amountMinor: 800, state: "pending" }] }), 2000);
});
