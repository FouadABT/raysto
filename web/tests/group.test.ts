import { test } from "node:test";
import assert from "node:assert/strict";
import {
  agingBucket,
  compareRows,
  currenciesOf,
  groupOfVenue,
  parseTemplateLines,
  pnlRows,
  readsMoney,
  roleLabel,
  totalsByCurrency,
  venueRows,
  venuesInChoice,
  type GroupRow,
  type LedgerLine,
  type VenueFigures,
} from "../src/lib/connected/group";
import { billsDueWithin, profitByCurrency, toolFor } from "../src/lib/connected/studio/ai-tools";
import { isStudioState, mergeLayout } from "../src/lib/connected/studio/layout";
import { groupPages } from "../src/lib/connected/studio/pages";
import type { Membership } from "../src/lib/connected/contracts";

const venue = (restaurantId: number, name: string, currency: string, sales: number, extra: Partial<VenueFigures> = {}): VenueFigures => ({
  restaurantId,
  name,
  currency,
  paidSalesMinor: sales,
  orders: 2,
  averageTicketMinor: sales / 2,
  refundsMinor: 0,
  payoutsMinor: 0,
  billsDue: 1,
  billsDueMinor: 5000,
  lowStock: 1,
  liveDeliveries: 0,
  ...extra,
});

test("group totals are kept per currency, never added across currencies", () => {
  const totals = totalsByCurrency([venue(1, "Café", "USD", 10000), venue(2, "Harbour", "EUR", 7000), venue(3, "Annex", "usd", 2500)]);
  assert.deepEqual(
    totals.map((t) => [t.currency, t.venues, t.paidSalesMinor, t.orders]),
    [
      ["EUR", 1, 7000, 2],
      ["USD", 2, 12500, 4],
    ],
  );
  assert.deepEqual(currenciesOf([{ currency: "usd" }, { currency: "EUR" }, { currency: "USD" }]), ["EUR", "USD"]);
});

test("Studio sources hold one currency at a time, in major units", () => {
  const rows = venueRows([venue(1, "Café", "USD", 10050), venue(2, "Harbour", "EUR", 7000)], "USD");
  assert.equal(rows.length, 1);
  assert.equal(rows[0].venue, "Café");
  assert.equal(rows[0].sales, 100.5);
  const days = compareRows(
    [
      { restaurantId: 1, venue: "Café", currency: "USD", date: "2026-11-03", salesMinor: 1200, orders: 1 },
      { restaurantId: 2, venue: "Harbour", currency: "EUR", date: "2026-11-03", salesMinor: 900, orders: 1 },
    ],
    "EUR",
  );
  assert.deepEqual(days, [{ venue: "Harbour", currency: "EUR", day: "2026-11-03", sales: 9, orders: 1 }]);
});

const line = (account: string, debitMinor: number, creditMinor: number, currency = "USD", venueName = "Café"): LedgerLine => ({
  restaurantId: 1,
  venue: venueName,
  date: "2026-11-03",
  at: "2026-11-03T10:00:00Z",
  account,
  accountName: account,
  debitMinor,
  creditMinor,
  currency,
});

test("the profit and loss source signs revenue up and costs down, so the total row is profit", () => {
  const lines = [line("1000", 1000, 0), line("4000", 0, 1000), line("6000", 39, 0), line("1000", 0, 39), line("4000", 0, 500, "EUR", "Harbour")];
  const rows = pnlRows(lines, "USD");
  assert.deepEqual(
    rows.map((r) => [r.kind, r.amount]),
    [
      ["Revenue", 10],
      ["Costs", -0.39],
    ],
  );
  assert.equal(
    rows.reduce((n, r) => n + Number(r.amount), 0),
    9.61,
  );
  assert.deepEqual(profitByCurrency(lines), [
    { currency: "EUR", revenueMinor: 500, costMinor: 0, netMinor: 500 },
    { currency: "USD", revenueMinor: 1000, costMinor: 39, netMinor: 961 },
  ]);
});

test("payables age in the buckets accountants use, and the bills tool finds what is due", () => {
  assert.equal(agingBucket(0), "Not due");
  assert.equal(agingBucket(12), "0–30 days");
  assert.equal(agingBucket(45), "31–60 days");
  assert.equal(agingBucket(75), "61–90 days");
  assert.equal(agingBucket(120), "90+ days");
  const now = new Date("2026-11-04T12:00:00Z");
  const bill = (id: number, dueAt: string | null, daysOverdue = 0) => ({
    restaurantId: 1,
    venue: "Café",
    currency: "USD",
    id,
    vendor: `Vendor ${id}`,
    amountMinor: 1000,
    dueAt,
    state: "approved",
    daysOverdue,
  });
  const due = billsDueWithin([bill(1, "2026-11-20T00:00:00Z"), bill(2, "2026-11-06T00:00:00Z"), bill(3, "2026-10-01T00:00:00Z", 34)], 7, now);
  assert.deepEqual(
    due.map((b) => b.id),
    [3, 2],
  );
});

test("menu template lines need a name and a price; nothing is guessed", () => {
  const ok = parseTemplateLines("Mushroom soup, 7.50, with thyme cream\nLemon tart; 6\n\n");
  assert.deepEqual(ok.errors, []);
  assert.deepEqual(ok.items, [
    { name: "Mushroom soup", priceMinor: 750, description: "with thyme cream" },
    { name: "Lemon tart", priceMinor: 600 },
  ]);
  const bad = parseTemplateLines("Bread\nSoup, seven");
  assert.equal(bad.items.length, 0);
  assert.equal(bad.errors.length, 2);
});

test("roles: owners and accountants read the books, area managers the figures", () => {
  assert.equal(readsMoney("owner"), true);
  assert.equal(readsMoney("accountant"), true);
  assert.equal(readsMoney("areaManager"), false);
  assert.equal(roleLabel("areaManager"), "Area manager");
});

const groups: GroupRow[] = [
  {
    id: 7,
    name: "Atelier Group",
    role: "owner",
    version: 1,
    venues: [
      { restaurantId: 1, name: "Café", currency: "USD", role: "owner" },
      { restaurantId: 2, name: "Harbour", currency: "EUR", role: "manager" },
    ],
  },
];
const memberships = [
  { restaurantId: 1, name: "Café", role: "owner" },
  { restaurantId: 2, name: "Harbour", role: "manager" },
  { restaurantId: 9, name: "Elsewhere", role: "owner" },
] as Membership[];

test("the group switcher narrows the venue picker to the chosen group's venues", () => {
  assert.equal(venuesInChoice(memberships, null).length, 3);
  assert.equal(venuesInChoice(memberships, { groups, groupId: null }).length, 3);
  assert.deepEqual(
    venuesInChoice(memberships, { groups, groupId: 7 }).map((m) => m.restaurantId),
    [1, 2],
  );
  // A group role with no venue role still opens on a venue.
  assert.equal(venuesInChoice([memberships[2]], { groups, groupId: 7 }).length, 1);
  assert.equal(groupOfVenue(groups, 2)?.id, 7);
  assert.equal(groupOfVenue(groups, 9), undefined);
});

test("the assistant matches a question to one tool, and says so when none fits", () => {
  assert.deepEqual(toolFor("What profit did we make this month?"), { tool: "raysto_pnl", args: { range: "30d" } });
  assert.deepEqual(toolFor("Which bills are due?"), { tool: "raysto_bills_due", args: { withinDays: 7 } });
  assert.deepEqual(toolFor("What is running low?"), { tool: "raysto_stockouts", args: {} });
  assert.deepEqual(toolFor("Propose a restock plan"), { tool: "raysto_propose", args: { kind: "restock" } });
  assert.deepEqual(toolFor("Ask the accountant to review the bills"), { tool: "raysto_propose", args: { kind: "bills" } });
  assert.equal(toolFor("Tell me a joke"), undefined);
});

test("the Group pages: Money only for owners and accountants; a saved layout keeps pages added later", () => {
  const full = groupPages("USD", true);
  const area = groupPages("USD", false);
  assert.deepEqual(
    full.pages.map((p) => p.id),
    ["portfolio", "compare", "money"],
  );
  assert.deepEqual(
    area.pages.map((p) => p.id),
    ["portfolio", "compare"],
  );
  assert.ok(isStudioState(full));
  assert.equal(isStudioState({ pages: [] }), false);
  assert.equal(isStudioState({ pages: [{ id: 1 }], selectedPageId: "x" }), false);
  const saved = { ...area, selectedPageId: "compare" };
  const merged = mergeLayout(saved, full, "money");
  assert.deepEqual(
    merged.pages.map((p) => p.id),
    ["portfolio", "compare", "money"],
  );
  assert.equal(merged.selectedPageId, "money");
  assert.equal(mergeLayout(null, full).selectedPageId, "portfolio");
  // Every widget reads a source the Group section provides.
  const fields = JSON.stringify(full).match(/"(venues|days|pnl)\.[a-zA-Z]+"/g) ?? [];
  assert.ok(fields.length > 10);
  assert.equal(JSON.stringify(full).match(/"(?!venues|days|pnl)[a-z]+\.[a-zA-Z]+"/g), null);
});
