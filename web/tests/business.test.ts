import { test } from "node:test";
import assert from "node:assert/strict";
import {
  channelMix,
  channelOf,
  collectionTotals,
  dayRange,
  nextStep,
  statusGroup,
  unresolved,
  type CheckoutRow,
  type CollectionRow,
} from "../src/lib/connected/business";

test("counter sales are their own channel, apart from app pickups", () => {
  assert.equal(channelOf({ origin: "counter", fulfillment: "pickup" }), "Counter");
  assert.equal(channelOf({ origin: "online", fulfillment: "pickup" }), "Pickup");
  assert.equal(channelOf({ origin: "online", fulfillment: "dineIn" }), "Dine-in");
  assert.deepEqual(
    channelMix({
      "pickup:counter": { orders: 3, salesMinor: 2400 },
      "pickup:online": { orders: 1, salesMinor: 900 },
      "dineIn:online": { orders: 2, salesMinor: 5000 },
    }).map((c) => c.channel),
    ["Dine-in", "Counter", "Pickup"],
  );
});

test("orders waiting for payment count as new, delivery in progress as ready", () => {
  assert.equal(statusGroup("awaitingPayment"), "New");
  assert.equal(statusGroup("outForDelivery"), "Ready");
  assert.equal(statusGroup("cancelled"), "Done");
  assert.equal(nextStep({ status: "ready", fulfillment: "pickup" }), "collected");
  assert.equal(nextStep({ status: "ready", fulfillment: "delivery" }), null);
});

test("unresolved PayPal attempts exclude cash and fresh approval links", () => {
  const now = new Date("2026-10-31T12:00:00Z");
  const row = (state: string, minutesAgo: number, method = "paypal"): CheckoutRow => ({
    id: 1,
    checkoutId: 1,
    orderId: 1,
    visitId: null,
    method,
    state,
    amountMinor: 900,
    currency: "EUR",
    createdAt: new Date(now.getTime() - minutesAgo * 60000).toISOString(),
  });
  assert.equal(unresolved([row("created", 5)], now).length, 0);
  assert.equal(unresolved([row("created", 45)], now).length, 1);
  assert.equal(unresolved([row("uncertain", 1)], now).length, 1);
  assert.equal(unresolved([row("capturing", 1, "cash")], now).length, 0);
});

test("PayPal, cash and items under review are never blended", () => {
  const row = (method: string | null, amountMinor: number, state = "completed", refundedMinor = 0): CollectionRow => ({
    id: 1,
    checkoutId: 1,
    method,
    providerCaptureId: null,
    orderId: 1,
    visitId: null,
    amountMinor,
    refundedMinor,
    currency: "EUR",
    state,
    createdAt: "",
  });
  assert.deepEqual(
    collectionTotals([row("paypal", 1000, "completed", 200), row("cash", 500), row("paypal", 700, "review")]),
    { paypal: 1000, cash: 500, refunded: 200, review: 700 },
  );
});

test("a day range covers local midnight to midnight", () => {
  const { from, until } = dayRange(new Date(2026, 9, 31, 15, 30));
  assert.equal(new Date(until).getTime() - new Date(from).getTime(), 86400000);
  assert.equal(new Date(from).getHours(), 0);
});
