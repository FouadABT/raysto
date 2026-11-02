import { test } from "node:test";
import assert from "node:assert/strict";
import {
  basketOf,
  elapsed,
  heardLines,
  menuChanges,
  toolsUsed,
  type Dish,
} from "../src/lib/connected/judge";

const menu: Dish[] = [
  {
    productId: 1,
    name: "Croque monsieur",
    priceMinor: 750,
    modifiers: [
      {
        id: "options",
        name: "Options",
        options: [{ id: "o0", name: "Fried egg (croque madame)", priceMinor: 100 }],
      },
    ],
  },
  { productId: 2, name: "Cappuccino", priceMinor: 300 },
];

test("demo timers read in seconds, then minutes", () => {
  assert.equal(elapsed(4_400), "4 s");
  assert.equal(elapsed(65_000), "1 min 05 s");
  assert.equal(elapsed(-5), "0 s");
});

test("a read menu is compared with the menu on sale", () => {
  const rows = menuChanges(
    [
      { name: "Croque Monsieur", category: "Sandwiches", priceMinor: 750 },
      { name: "Cappuccino", category: "Drinks", priceMinor: 320 },
      { name: "Lemon tart", category: "Sweets", priceMinor: 450 },
      { name: "Soup of the day", category: "Plates", priceMinor: 0, available: false },
    ],
    menu,
  );
  assert.deepEqual(
    rows.map((r) => [r.name, r.change, r.was]),
    [
      ["Croque Monsieur", "same", undefined],
      ["Cappuccino", "price", 300],
      ["Lemon tart", "new", undefined],
      ["Soup of the day", "new", undefined],
    ],
  );
  assert.equal(rows[3].available, false);
});

test("heard lines use the menu's own names and options", () => {
  assert.deepEqual(
    heardLines(
      [
        { productId: 1, quantity: 1, options: [] },
        { productId: 1, quantity: 1, options: ["options:o0"] },
        { productId: 2, quantity: 2, options: [], note: "extra hot" },
        { productId: 9, quantity: 1 },
      ],
      menu,
    ),
    [
      "1× Croque monsieur",
      "1× Croque monsieur + Fried egg (croque madame)",
      "2× Cappuccino (extra hot)",
      "1× dish 9",
    ],
  );
});

test("only a basket proposal can be ordered", () => {
  assert.equal(basketOf(undefined), undefined);
  assert.equal(basketOf({ proposal: { kind: "payment" } }), undefined);
  const basket = basketOf({
    proposal: {
      id: 7,
      version: 2,
      kind: "basket",
      payload: {
        quote: {
          lines: [{ name: "Falafel wrap (vegan)", quantity: 2 }],
          totalMinor: 1600,
          currency: "USD",
          slot: "2026-11-03T17:30:00.000Z",
        },
      },
    },
  });
  assert.deepEqual(basket, {
    id: 7,
    version: 2,
    lines: ["2× Falafel wrap (vegan)"],
    totalMinor: 1600,
    currency: "USD",
    slot: "2026-11-03T17:30:00.000Z",
  });
});

test("tool steps are listed once, in order", () => {
  assert.deepEqual(
    toolsUsed([{ tool: "read_ledger" }, { name: "read_paypal" }, { tool: "read_ledger" }, {}, "x"]),
    ["read_ledger", "read_paypal"],
  );
  assert.deepEqual(toolsUsed(undefined), []);
});
