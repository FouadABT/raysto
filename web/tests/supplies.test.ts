import { test } from "node:test";
import assert from "node:assert/strict";
import {
  basisText,
  coverText,
  flagLabel,
  flagTone,
  funnelSource,
  inventoryState,
  matchText,
  orderActions,
  parseQty,
  poFunnel,
  portionCost,
  receiptDraft,
  remaining,
  reorderGroups,
  scorecardSource,
  stockSource,
  stockState,
  type Forecast,
  type ForecastRow,
  type MatchLine,
  type SupplierOrder,
} from "../src/lib/connected/supplies";
import { suppliesPreview } from "../src/lib/connected/supplies-preview";

type Json = Record<string, unknown>;

const row = (over: Partial<ForecastRow> = {}): ForecastRow => ({
  stockItemId: 1,
  name: "Flour",
  unit: "kg",
  quantity: 10,
  lowAt: 8,
  low: false,
  costMinor: 120,
  valueMinor: 1200,
  leadDays: 2,
  supplierId: 1,
  supplierName: "Dupont",
  version: 1,
  dailyUsage: 2,
  daysCover: 5,
  stockOutAt: "2026-11-09T12:00:00.000Z",
  atArrival: 6,
  parLevel: 18,
  reorder: true,
  suggestedQty: 12,
  ...over,
});

test("the purchase-order funnel counts the orders that reached each stage", () => {
  const states = ["draft", "sent", "partiallyReceived", "received", "billed", "paid", "cancelled"];
  const f = poFunnel(states.map((state) => ({ state })));
  assert.deepEqual(
    f.map((s) => [s.stage, s.count]),
    [
      ["draft", 6],
      ["sent", 5],
      ["received", 4],
      ["billed", 2],
      ["paid", 1],
    ],
  );
  assert.deepEqual(funnelSource([{ state: "sent" } as SupplierOrder])[1], { stage: "Sent", orders: 1 });
});

test("an order offers its next actions, and the receipt starts from what is still to arrive", () => {
  assert.deepEqual(orderActions({ state: "draft" }), ["send", "cancel"]);
  assert.deepEqual(orderActions({ state: "sent" }), ["receive", "cancel"]);
  assert.deepEqual(orderActions({ state: "partiallyReceived" }), ["receive"]);
  assert.deepEqual(orderActions({ state: "billed" }), []);
  assert.equal(remaining({ qty: 25, receivedQty: 20 }), 5);
  assert.equal(remaining({ qty: 25, receivedQty: 30 }), 0);
  assert.deepEqual(
    receiptDraft({
      lines: [
        { stockItemId: 1, name: "Flour", unit: "kg", qty: 25, unitCostMinor: 120, receivedQty: 20 },
        { stockItemId: 2, name: "Butter", unit: "kg", qty: 10, unitCostMinor: 980, receivedQty: 10 },
      ],
    }),
    [{ stockItemId: 1, qty: 5 }],
  );
});

test("stock rows read as words, not only colours", () => {
  assert.equal(stockState(row()), "reorder");
  assert.equal(stockState(row({ reorder: false, low: true })), "low");
  assert.equal(stockState(row({ reorder: false })), "ok");
  assert.equal(coverText(row()), "5.0 days");
  assert.equal(coverText(row({ daysCover: 0.4 })), "Under a day");
  assert.equal(coverText(row({ daysCover: null })), "No recent use");
  assert.match(basisText("none"), /add recipes/);
  assert.match(basisText("movements", 28), /28 days of sales and waste/);
});

test("reorder lines group by supplier, the largest order first", () => {
  const groups = reorderGroups([
    row(),
    row({ stockItemId: 2, name: "Butter", costMinor: 980, suggestedQty: 6 }),
    row({ stockItemId: 3, name: "Eggs", supplierId: 2, supplierName: "Verger", costMinor: 32, suggestedQty: 26 }),
    row({ stockItemId: 4, name: "Salt", reorder: false }),
  ]);
  assert.deepEqual(
    groups.map((g) => [g.supplierName, g.rows.length, g.totalMinor]),
    [
      ["Dupont", 2, 12 * 120 + 6 * 980],
      ["Verger", 1, 832],
    ],
  );
});

test("a match line says what differs in words, with the money", () => {
  const line = (over: Partial<MatchLine>): MatchLine => ({
    name: "Butter",
    unit: "kg",
    orderedQty: 10,
    deliveredQty: 10,
    qtyVariance: 0,
    orderedUnitMinor: 980,
    deliveredUnitMinor: 980,
    billedUnitMinor: null,
    priceVariancePct: 0,
    flags: [],
    ...over,
  });
  assert.equal(matchText(line({}), "USD"), "As ordered.");
  assert.equal(matchText(line({ deliveredQty: 8, qtyVariance: -2, flags: ["short"] }), "USD"), "2 kg short (8 of 10 kg).");
  assert.equal(
    matchText(line({ deliveredUnitMinor: 1050, priceVariancePct: 7.1, flags: ["price_up"] }), "USD"),
    "$10.50 instead of $9.80 a unit (+7.1%).",
  );
  assert.equal(matchText(line({ deliveredQty: null, flags: ["missing"] }), "USD"), "Nothing arrived of 10 kg ordered.");
  assert.equal(matchText(line({ orderedQty: 0, deliveredQty: 2, flags: ["not_ordered"] }), "USD"), "2 kg arrived but were not ordered.");
  assert.equal(flagLabel("billed_differs"), "Bill differs");
  assert.equal(flagTone("short"), "late");
  assert.equal(flagTone("price_down"), "warn");
});

test("typed quantities accept a comma or a point, nothing else", () => {
  assert.equal(parseQty("2,5"), 2.5);
  assert.equal(parseQty(" 12 "), 12);
  assert.equal(parseQty("-1"), null);
  assert.equal(parseQty("1e3"), null);
  assert.equal(parseQty(""), null);
});

test("Studio sources: major units, flags as counts, and the inventory page", () => {
  const f: Forecast = { rows: [row({ low: true })], basis: "movements", windowDays: 28, currency: "EUR", waste: [] };
  assert.deepEqual(stockSource(f)[0], { name: "Flour", supplier: "Dupont", unit: "kg", quantity: 10, value: 12, cover: 5, low: 1, reorder: 1 });
  assert.deepEqual(stockSource(undefined), []);
  const state = inventoryState("eur") as unknown as { pages: { widgets: Record<string, { type: string; dataMapping: Json }> }[] };
  const widgets = state.pages[0].widgets;
  assert.equal(widgets.cover.type, "radial-gauge");
  assert.equal(widgets.map.type, "treemap-chart");
  assert.match(JSON.stringify(widgets.value), /Stock value \(EUR\)/);
  // Every field a widget reads exists on the source rows.
  const fields = new Set(Object.keys(stockSource(f)[0]).map((k) => `stock.${k}`));
  for (const w of Object.values(widgets)) for (const id of JSON.stringify(w.dataMapping).match(/stock\.[a-z]+/gi) ?? []) assert.ok(fields.has(id), id);
  assert.deepEqual(
    scorecardSource([
      { supplierId: 1, name: "A", orders: 2, onTimePct: 100, fillRatePct: 90, priceVariancePct: null, leadDays: 2, hasEmail: true, hasPayPal: true },
      { supplierId: 2, name: "B", orders: 0, onTimePct: null, fillRatePct: null, priceVariancePct: null, leadDays: 2, hasEmail: false, hasPayPal: false },
    ]),
    [{ supplier: "A", onTime: 100, priceVariance: 0, fillRate: 90, orders: 2 }],
  );
});

test("portion cost adds the recipe's lines", () => {
  assert.equal(portionCost({ lines: [{ stockItemId: 1, quantity: 0.05, costMinor: 6 }, { stockItemId: 2, quantity: 0.025, costMinor: 25 }] }), 31);
});

test("the preview fixtures follow the forecast's own arithmetic", () => {
  const f = suppliesPreview(new Date().toISOString())["stock.forecast"]({}) as Forecast;
  const flour = f.rows.find((r) => r.name === "Flour T55")!;
  assert.equal(flour.daysCover, 5);
  assert.equal(flour.reorder, true);
  assert.equal(flour.suggestedQty, 12);
  const salt = f.rows.find((r) => r.name === "Sea salt")!;
  assert.equal(salt.reorder, false);
});
