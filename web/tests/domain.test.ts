import { test } from "node:test";
import assert from "node:assert/strict";
import {
  advanceOrder,
  calculate,
  can,
  seedState,
  validateCheckout,
  type CartLine,
} from "../src/lib/domain";
const line: CartLine = {
  id: "test",
  productId: "p1",
  name: "Burrata garden bowl",
  price: 8500,
  quantity: 2,
  option: "Regular",
  note: "",
  image: "",
};
test("totals use minor units, discount food only, then add fee and tip", () => {
  assert.deepEqual(calculate([line], "Delivery", 1500, 2000, true), {
    subtotal: 17000,
    discount: 1700,
    fee: 1500,
    tip: 2000,
    total: 18800,
  });
  assert.equal(calculate([line], "Pickup", 1500).fee, 0);
});
test("checkout rejects stale price and unavailable menu items", () => {
  const s = seedState();
  s.cart = [line];
  validateCheckout(s, "");
  s.products[0].price = 9000;
  assert.throws(() => validateCheckout(s, ""), /new price/);
  s.products[0].available = false;
  assert.throws(() => validateCheckout(s, ""), /no longer available/);
});
test("delivery enforces service, region and minimum", () => {
  const s = seedState();
  s.cart = [{ ...line, quantity: 1 }];
  s.channel = "Delivery";
  assert.throws(() => validateCheckout(s, "Rabat"), /Casablanca/);
  s.settings.minimum = 10000;
  assert.throws(() => validateCheckout(s, "Casablanca"), /minimum/);
  s.settings.minimum = 8000;
  s.settings.delivery = false;
  assert.throws(() => validateCheckout(s, "Casablanca"), /paused/);
});
test("dine-in requires a current occupied visit, not a table number", () => {
  const s = seedState();
  s.cart = [line];
  s.channel = "Dine-in";
  assert.throws(() => validateCheckout(s, ""), /Join/);
  s.visit = { id: "forged", table: 2, guests: 2 };
  assert.throws(() => validateCheckout(s, ""), /Join/);
  s.visit.id = "visit-2";
  validateCheckout(s, "");
  s.tables[1].status = "Needs reset";
  assert.throws(() => validateCheckout(s, ""), /Join/);
});
test("kitchen, waiter and courier transitions enforce distinct responsibilities", () => {
  const s = seedState();
  const order = s.orders[0];
  assert.throws(() => advanceOrder(order, "kitchen"), /accepted/);
  order.status = "Accepted";
  assert.equal(advanceOrder(order, "kitchen"), "Preparing");
  assert.throws(() => advanceOrder(order, "waiter"), /ready/);
  order.status = "Ready";
  assert.equal(advanceOrder(order, "waiter"), "Completed");
  order.channel = "Delivery";
  order.courier = "Other";
  assert.throws(() => advanceOrder(order, "courier"), /assigned/);
  order.courier = "Sami";
  assert.equal(advanceOrder(order, "courier"), "Out for delivery");
  order.status = "Completed";
  assert.throws(() => advanceOrder(order, "owner"), /closed/);
});
test("demo routes do not grant management access to other roles", () => {
  assert.equal(can(null, "overview"), false);
  assert.equal(can("waiter", "payments"), false);
  assert.equal(can("kitchen", "team"), false);
  assert.equal(can("courier", "orders"), false);
  assert.equal(can("manager", "billing"), false);
  assert.equal(can("owner", "billing"), true);
});
