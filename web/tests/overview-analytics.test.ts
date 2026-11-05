import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import type { Dashboard } from "../src/lib/connected/dashboard";
import {
  feesEstimated,
  localDay,
  moneyRows,
  overviewStudioState,
  receivedRows,
  salesRows,
  totalsBy,
  weekOf,
  type JournalLine,
} from "../src/lib/connected/overview-analytics";

const fixture = (name: string) =>
  JSON.parse(readFileSync(path.join(__dirname, "..", "..", "docs", "fixtures", name), "utf8")) as Dashboard;

const line = (date: string, account: string, accountName: string, debitMinor: number, creditMinor: number, currency = "USD"): JournalLine => ({
  date,
  account,
  accountName,
  debitMinor,
  creditMinor,
  currency,
});

test("weeks are ISO weeks named by their Monday; days are the café's own", () => {
  assert.equal(weekOf("2026-11-04"), "W45 · 2 Nov");
  assert.equal(weekOf("2026-11-08"), "W45 · 2 Nov");
  assert.equal(weekOf("2026-11-09"), "W46 · 9 Nov");
  // 1 January 2026 is a Thursday: week 1 starts on Monday 29 December.
  assert.equal(weekOf("2026-01-01"), "W01 · 29 Dec");
  assert.equal(weekOf("nonsense"), "nonsense");
  assert.equal(localDay("2026-10-28T04:00:00.000Z", "America/New_York"), "2026-10-28");
  assert.equal(localDay("2026-10-28T03:00:00.000Z", "America/New_York"), "2026-10-27");
});

test("sales rows are the dashboard's own days; the labelled sample is never read", () => {
  const d = fixture("dashboard-7d.json");
  const rows = salesRows(d);
  assert.equal(rows.length, d.points.length);
  assert.equal(rows[0].day, "2026-10-28");
  const total = rows.reduce((n, r) => n + Number(r.sales), 0);
  assert.equal(Math.round(total * 100), d.kpis.sales.value);
  assert.equal(rows.reduce((n, r) => n + Number(r.orders), 0), d.kpis.orders.value);
  assert.deepEqual(salesRows(undefined), []);
});

test("money in is positive and money out negative, so the total is the profit; other currencies stay out", () => {
  const lines = [
    line("2026-11-02", "1000", "PayPal balance", 10000, 0),
    line("2026-11-02", "4000", "Sales", 0, 10000),
    line("2026-11-02", "6000", "PayPal fees", 400, 0),
    line("2026-11-02", "1000", "PayPal balance", 0, 400),
    line("2026-11-03", "4090", "Refunds", 850, 0),
    line("2026-11-03", "4000", "Sales", 0, 9999, "EUR"),
  ];
  const rows = moneyRows(lines, "USD");
  assert.deepEqual(
    rows.map((r) => [r.kind, r.account, r.amount, r.moneyIn, r.moneyOut]),
    [
      ["Money in", "Sales", 100, 100, 0],
      ["Money out", "PayPal fees", -4, 0, -4],
      ["Money in", "Refunds", -8.5, -8.5, 0],
    ],
  );
  assert.equal(Math.round(rows.reduce((n, r) => n + Number(r.amount), 0) * 100), 10000 - 400 - 850);
  assert.equal(rows[0].week, "W45 · 2 Nov");
});

test("money received is the debits to PayPal and the till, by method", () => {
  const rows = receivedRows([
    line("2026-11-02", "1000", "PayPal balance", 10000, 0),
    line("2026-11-02", "1010", "Cash and bank", 2500, 0),
    line("2026-11-02", "1000", "PayPal balance", 0, 400),
    line("2026-11-02", "4000", "Sales", 0, 12500),
  ]);
  assert.deepEqual(
    rows.map((r) => [r.method, r.amount]),
    [
      ["PayPal", 100],
      ["Cash and bank", 25],
    ],
  );
  assert.deepEqual(totalsBy(rows, "method"), [
    { label: "PayPal", minor: 10000 },
    { label: "Cash and bank", minor: 2500 },
  ]);
  assert.deepEqual(totalsBy([{ k: "out", amount: -9.5 }, { k: "in", amount: 3 }, { k: "out", amount: -0.5 }], "k"), [
    { label: "out", minor: -1000 },
    { label: "in", minor: 300 },
  ]);
  assert.equal(feesEstimated([{ ...line("2026-11-02", "6000", "PayPal fees", 1, 0), source: { estimated: true } }]), true);
  assert.equal(feesEstimated([line("2026-11-02", "6000", "PayPal fees", 1, 0)]), false);
});

test("every Studio widget reads a field the rows really have", () => {
  const state = overviewStudioState("USD") as unknown as { pages: { id: string; widgets: Record<string, { dataMapping: Record<string, { id: string }[]> }> }[] };
  assert.deepEqual(
    state.pages.map((p) => p.id),
    ["sales", "received", "money"],
  );
  const fields: Record<string, string[]> = {
    days: Object.keys(salesRows(fixture("dashboard-7d.json"))[0]),
    received: Object.keys(receivedRows([line("2026-11-02", "1000", "PayPal balance", 1, 0)])[0]),
    money: Object.keys(moneyRows([line("2026-11-02", "4000", "Sales", 0, 1)])[0]),
  };
  for (const page of state.pages)
    for (const widget of Object.values(page.widgets))
      for (const refs of Object.values(widget.dataMapping))
        for (const { id } of refs) {
          const [source, field] = id.split(".");
          assert.ok(fields[source]?.includes(field), `${page.id}: ${id}`);
        }
});
