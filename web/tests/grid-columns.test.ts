import { test } from "node:test";
import assert from "node:assert/strict";
import type { ColDef, ValueFormatterParams } from "ag-grid-community";
import {
  boolCol,
  columnIds,
  columnTotals,
  countCol,
  dateCol,
  idCol,
  moneyCol,
  statusCol,
  toneOf,
  totalsLabel,
  totalsLabelColumn,
  words,
  type ColumnContext,
} from "../src/lib/connected/grid-columns";

type Row = { id: number; venue: string; currency: string; amountMinor: number; orders: number; paid: boolean; state: string; at: string };
const rows: Row[] = [
  { id: 1, venue: "Café", currency: "USD", amountMinor: 1250, orders: 3, paid: true, state: "captured", at: "2026-11-04T09:30:00Z" },
  { id: 2, venue: "Bistro", currency: "EUR", amountMinor: 800, orders: 2, paid: false, state: "awaiting_payment", at: "2026-11-03T18:00:00Z" },
  { id: 3, venue: "Café", currency: "USD", amountMinor: 450, orders: 1, paid: true, state: "partiallyRefunded", at: "2026-11-02T12:00:00Z" },
];
const read = (c: ColDef<Row>, _id: string, r: Row) =>
  typeof c.valueGetter === "function"
    ? (c.valueGetter as (p: { data: Row }) => unknown)({ data: r })
    : (r as unknown as Record<string, unknown>)[String(c.field)];
const format = (c: ColDef<Row>, value: unknown, data?: Row) =>
  (c.valueFormatter as (p: ValueFormatterParams<Row>) => string)({ value, data } as ValueFormatterParams<Row>);

test("money is right-aligned, formatted in the row's currency and exported as major units", () => {
  const c = moneyCol<Row>("Amount", "amountMinor", (r) => r.currency);
  assert.equal(c.cellClass, "ops-num ag-right-aligned-cell");
  assert.equal(c.headerClass, "ag-right-aligned-header");
  assert.equal(c.filter, "agNumberColumnFilter");
  assert.equal(format(c, 1250, rows[0]), "$12.50");
  assert.equal(format(c, 800, rows[1]), "€8.00");
  assert.equal(format(c, null, rows[0]), "");
  assert.equal((c.context as ColumnContext).csv?.(1250, rows[0]), "12.50");
  assert.equal((c.context as ColumnContext).total, "money");
});

test("the totals row sums money per currency and never adds two currencies", () => {
  const cols = [
    { field: "venue" as const, headerName: "Venue" },
    moneyCol<Row>("Amount", "amountMinor", (r) => r.currency),
    countCol<Row>("Orders", "orders"),
  ];
  const totals = columnTotals(cols, rows, read, (r) => r);
  assert.equal(totals.amountMinor, "€8.00 · $17.00");
  assert.equal(totals.orders, "6");
  assert.equal(totals.venue, undefined);
});

test("the totals follow the rows a filter leaves", () => {
  const cols = [moneyCol<Row>("Amount", "amountMinor", (r) => r.currency), countCol<Row>("Orders", "orders")];
  const shown = rows.filter((r) => r.venue === "Café");
  const totals = columnTotals(cols, shown, read, (r) => r);
  assert.equal(totals.amountMinor, "$17.00");
  assert.equal(totals.orders, "4");
  assert.deepEqual(columnTotals(cols, [], read, (r) => r), { amountMinor: "", orders: "0" });
});

test("a column can opt out of the totals, and a count can carry its own wording", () => {
  const cols = [
    moneyCol<Row>("Average", "amountMinor", "USD", { total: false }),
    countCol<Row>("Time", (r) => r.orders * 1.5, { format: (n) => `${n.toFixed(1)} s` }),
  ];
  const totals = columnTotals(cols, rows, read, (r) => r);
  assert.deepEqual(Object.keys(totals), ["time"]);
  assert.equal(totals.time, "9.0 s");
});

test("the label goes in the first visible column that does not add up", () => {
  const cols = [moneyCol<Row>("Amount", "amountMinor", "USD"), statusCol<Row>("State", "state"), countCol<Row>("Orders", "orders")];
  assert.equal(totalsLabelColumn(cols), 1);
  assert.equal(totalsLabelColumn([countCol<Row>("Orders", "orders")]), -1);
  assert.equal(totalsLabel(1), "Total of 1 row");
  assert.equal(totalsLabel(1200), "Total of 1,200 rows");
});

test("column ids are stable and unique", () => {
  const ids = columnIds<Row>([
    { field: "venue" },
    { headerName: "For" },
    { headerName: "For" },
    { colId: "action" },
    {},
  ]);
  assert.deepEqual(ids, ["venue", "for", "for-2", "action", "col-4"]);
});

test("statuses read as words with a tone; booleans and ids keep their words for search and CSV", () => {
  const s = statusCol<Row>("State", "state");
  assert.equal(s.cellRenderer, "raystoPill");
  assert.equal(format(s, "awaiting_payment"), "Awaiting payment");
  assert.equal(format(s, "partiallyRefunded"), "Partially refunded");
  const relabel = statusCol<Row>("Ledger", "state", { label: (v) => (v === "review" ? "Under review" : words(v)) });
  assert.equal(format(relabel, "review"), "Under review");
  assert.equal(toneOf("captured"), "ok");
  assert.equal(toneOf("awaiting_payment"), "new");
  assert.equal(toneOf("overdue"), "late");
  assert.equal(toneOf("something new"), "neutral");

  const b = boolCol<Row>("Paid", "paid", { labels: ["Paid", "Unpaid"] });
  assert.equal(b.cellRenderer, "raystoBool");
  assert.equal(format(b, true), "Paid");
  assert.equal(format(b, false), "Unpaid");
  const filterValue = b.filterValueGetter as (p: { data: Row }) => string;
  assert.equal(filterValue({ data: rows[1] }), "Unpaid");

  const id = idCol<Row>("Order", "id", { prefix: "#" });
  assert.equal(id.cellRenderer, "raystoId");
  assert.equal(format(id, 42), "#42");
  assert.equal((id.context as ColumnContext).csv?.(42, rows[0]), "42");
});

test("dates sort as instants and filter by the local day", () => {
  const d = dateCol<Row>("When", "at");
  const compare = d.comparator as (a: unknown, b: unknown) => number;
  assert.ok(compare("2026-11-02T12:00:00Z", "2026-11-04T09:30:00Z") < 0);
  assert.ok(compare(null, "2026-11-04T09:30:00Z") < 0);
  const day = dateCol<Row>("Day", "at", { dayOnly: true });
  assert.match(format(day, "2026-11-04"), /2026/);
  const filter = (d.filterParams as { comparator: (f: Date, cell: unknown) => number }).comparator;
  const local = new Date(2026, 10, 4);
  assert.equal(filter(local, new Date(2026, 10, 4, 15, 0).toISOString()), 0);
  assert.equal(filter(local, new Date(2026, 10, 3, 23, 0).toISOString()), -1);
});
