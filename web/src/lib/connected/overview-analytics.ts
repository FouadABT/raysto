/**
 * The Overview's analytics on AG Studio: the last 30 days of paid sales (the
 * `dashboard` query) and of money in and out (the `ledger.journal` query),
 * shaped as plain rows Studio groups, pivots and charts. Pure, so
 * tests/overview-analytics.test.ts runs it without a browser. Money becomes
 * major units of the café's one currency; nothing is estimated here, and a
 * dashboard's labelled sample series is never read.
 */
import type { Dashboard } from "./dashboard";
import type { StudioRow } from "./studio/sources";
import type { StudioState, StudioWidgetSpec } from "./studio/studio-canvas";

const major = (minor: unknown) => Math.round(Number(minor ?? 0)) / 100;

/** A journal line as `ledger.journal` returns it (backend ledger.dart). */
export interface JournalLine {
  date: string;
  account: string;
  accountName?: string;
  debitMinor: number;
  creditMinor: number;
  currency?: string;
  source?: { type?: string; estimated?: boolean };
}

/** "2026-11-04": the café's local day of an instant. */
export function localDay(iso: string, timeZone?: string): string {
  const at = new Date(iso);
  if (Number.isNaN(at.getTime())) return iso.slice(0, 10);
  try {
    return new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).format(at);
  } catch {
    return iso.slice(0, 10);
  }
}

/** "W45 · 2 Nov": the ISO week of a local day and its Monday, sortable within a year. */
export function weekOf(day: string): string {
  const [y, m, d] = day.slice(0, 10).split("-").map(Number);
  if (!y || !m || !d) return day;
  const date = Date.UTC(y, m - 1, d);
  const monday = date - ((new Date(date).getUTCDay() + 6) % 7) * 86400000;
  const thursday = new Date(monday + 3 * 86400000);
  const yearStart = Date.UTC(thursday.getUTCFullYear(), 0, 1);
  const week = Math.ceil(((thursday.getTime() - yearStart) / 86400000 + 1) / 7);
  const label = new Date(monday).toLocaleDateString("en-GB", { day: "numeric", month: "short", timeZone: "UTC" });
  return `W${String(week).padStart(2, "0")} · ${label}`;
}

/** One row per day of the dashboard: paid sales, paid orders and the average ticket. */
export function salesRows(d: Pick<Dashboard, "points" | "timezone"> | undefined): StudioRow[] {
  if (!d) return [];
  return d.points.map((p) => ({
    day: localDay(p.start, d.timezone),
    sales: major(p.salesMinor),
    orders: p.orders,
    ticket: p.orders ? major(Math.round(p.salesMinor / p.orders)) : 0,
  }));
}

const revenue = (account: string) => account.startsWith("4");
const cost = (account: string) => account.startsWith("5") || account.startsWith("6");

/**
 * Revenue and cost lines: money in positive, money out negative, so a
 * pivot's grand total is the profit for the period. Lines in another
 * currency than the café's are left out, never added together.
 */
export function moneyRows(lines: readonly JournalLine[], currency?: string): StudioRow[] {
  return lines
    .filter((l) => !currency || !l.currency || l.currency.toUpperCase() === currency.toUpperCase())
    .filter((l) => revenue(String(l.account)) || cost(String(l.account)))
    .map((l) => {
      const debit = Number(l.debitMinor ?? 0);
      const credit = Number(l.creditMinor ?? 0);
      const isIn = revenue(String(l.account));
      const amount = major(isIn ? credit - debit : -(debit - credit));
      return {
        day: String(l.date ?? "").slice(0, 10),
        week: weekOf(String(l.date ?? "")),
        kind: isIn ? "Money in" : "Money out",
        account: l.accountName || String(l.account),
        amount,
        // The same amount split by side, so a value tile can total one side.
        moneyIn: isIn ? amount : 0,
        moneyOut: isIn ? 0 : amount,
      };
    })
    .filter((r) => r.amount !== 0);
}

const methods: Record<string, string> = { "1000": "PayPal", "1010": "Cash and bank" };

/** Money received into PayPal or the till, by day and method (debits to the cash accounts). */
export function receivedRows(lines: readonly JournalLine[], currency?: string): StudioRow[] {
  return lines
    .filter((l) => !currency || !l.currency || l.currency.toUpperCase() === currency.toUpperCase())
    .filter((l) => methods[String(l.account)] && Number(l.debitMinor ?? 0) > 0)
    .map((l) => ({
      day: String(l.date ?? "").slice(0, 10),
      week: weekOf(String(l.date ?? "")),
      method: methods[String(l.account)],
      amount: major(l.debitMinor),
    }));
}

/**
 * Sums of `value` by `key`, in minor units, largest first (by size): the
 * phone's bars, where AG Studio's canvas is too wide to read.
 */
export function totalsBy(rows: readonly StudioRow[], key: string, value = "amount"): { label: string; minor: number }[] {
  const sums = new Map<string, number>();
  for (const r of rows) {
    const label = String(r[key] ?? "");
    sums.set(label, (sums.get(label) ?? 0) + Math.round(Number(r[value] ?? 0) * 100));
  }
  return [...sums.entries()].map(([label, minor]) => ({ label, minor })).sort((a, b) => Math.abs(b.minor) - Math.abs(a.minor));
}

/** True when PayPal's fees in these lines were estimated, not reported by PayPal. */
export const feesEstimated = (lines: readonly JournalLine[]) => lines.some((l) => l.source?.estimated === true);

type Place = { xTrack: number; yTrack: number; xSpan: number; ySpan: number };
const at = (xTrack: number, yTrack: number, xSpan: number, ySpan: number): Place => ({ xTrack, yTrack, xSpan, ySpan });
const title = (text: string) => ({ title: { text, enabled: true } });
const value = (text: string, field: string, aggregation = "sum"): StudioWidgetSpec => ({
  type: "value",
  format: title(text),
  dataMapping: { value: [{ id: field, aggregation }] },
});

export type AnalyticsPage = "sales" | "received" | "money";
export const analyticsPages: readonly (readonly [AnalyticsPage, string])[] = [
  ["sales", "Sales by day"],
  ["received", "Payment methods"],
  ["money", "Money in and out"],
];

/** The three Studio pages, on Studio's 24-column canvas (rows of 16 px). */
export function overviewStudioState(code: string): StudioState {
  const sales = {
    id: "sales",
    widgets: {
      total: value(`Paid sales (${code})`, "days.sales"),
      orders: value("Paid orders", "days.orders"),
      best: value(`Best day (${code})`, "days.sales", "max"),
      average: value(`Average day (${code})`, "days.sales", "avg"),
      chart: {
        type: "combo-chart-grouped-column-line",
        format: title(`Paid sales by day, with paid orders`),
        dataMapping: {
          categoryKey: [{ id: "days.day" }],
          valueKey: [{ id: "days.sales", aggregation: "sum" }],
          secondaryValueKey: [{ id: "days.orders", aggregation: "sum" }],
        },
      },
    },
    widgetLayout: {
      total: at(0, 0, 6, 7),
      orders: at(6, 0, 6, 7),
      best: at(12, 0, 6, 7),
      average: at(18, 0, 6, 7),
      chart: at(0, 7, 24, 23),
    },
  };
  const received = {
    id: "received",
    widgets: {
      share: {
        type: "donut-chart",
        format: title(`Received by method (${code})`),
        dataMapping: { categoryKey: [{ id: "received.method" }], valueKey: [{ id: "received.amount", aggregation: "sum" }] },
      },
      pivot: {
        type: "pivot-grid",
        format: { ...title(`Received by week and method (${code})`), style: { grandTotalRow: { enabled: true }, totalColumns: true } },
        dataMapping: {
          rows: [{ id: "received.week" }],
          columns: [{ id: "received.method" }],
          values: [{ id: "received.amount", aggregation: "sum" }],
        },
      },
    },
    widgetLayout: {
      share: at(0, 0, 9, 30),
      pivot: at(9, 0, 15, 30),
    },
  };
  const money = {
    id: "money",
    widgets: {
      moneyIn: value(`Money in (${code})`, "money.moneyIn"),
      moneyOut: value(`Money out (${code})`, "money.moneyOut"),
      net: value(`Profit after costs (${code})`, "money.amount"),
      pivot: {
        type: "pivot-grid",
        format: {
          ...title(`Money in and out by week (${code}); money out is negative, the total row is the profit`),
          style: { grandTotalRow: { enabled: true }, totalColumns: true },
        },
        dataMapping: {
          rows: [{ id: "money.kind" }, { id: "money.account" }],
          columns: [{ id: "money.week" }],
          values: [{ id: "money.amount", aggregation: "sum" }],
        },
      },
    },
    widgetLayout: {
      moneyIn: at(0, 0, 8, 7),
      moneyOut: at(8, 0, 8, 7),
      net: at(16, 0, 8, 7),
      pivot: at(0, 7, 24, 23),
    },
  };
  return { pages: [sales, received, money], selectedPageId: "sales" } as unknown as StudioState;
}
