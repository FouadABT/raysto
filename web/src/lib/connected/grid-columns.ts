/**
 * The console's column kinds for AG Grid Community, so every grid reads the
 * same way: money right-aligned in tabular figures, counts and dates that
 * sort as numbers and instants, statuses as pills, yes/no as an icon and
 * record ids in monospace with a copy button.
 *
 * Each column says how it adds up (`context.total`), and `columnTotals`
 * turns the rows a filter leaves into the pinned totals row. Money is summed
 * per currency and never across currencies. Pure: no React here, so the
 * totals are unit-tested (tests/grid-columns.test.ts). The renderers the
 * names below refer to live in raysto-grid.tsx.
 */
import type { ColDef, ValueFormatterParams, ValueGetterParams } from "ag-grid-community";
import { currency } from "./contracts";

/** How a column adds up in the pinned totals row. */
export type TotalKind = "sum" | "money";

/** What a column tells RaystoGrid, in `ColDef.context`. */
export interface ColumnContext {
  total?: TotalKind;
  /** Money: the row's currency code. */
  currencyOf?: (row: unknown) => string;
  /** A sum's own wording, such as "12.5 s". */
  format?: (n: number) => string;
  /** The cell as a spreadsheet should read it in the CSV export. */
  csv?: (value: unknown, row: unknown) => string;
}

/** Renderer names RaystoGrid registers (raysto-grid.tsx). */
export const renderers = { pill: "raystoPill", bool: "raystoBool", id: "raystoId" } as const;

/** Status words to pill tones, so state is seen, not read. */
const tones: Record<string, string> = {
  submitted: "new", new: "new", awaitingpayment: "new", created: "new", pending: "new", reserved: "new", queued: "new", review: "warn",
  requested: "new", proposed: "new", drafted: "new", open: "new", planned: "new", draft: "new", invited: "new",
  accepted: "cook", preparing: "cook", approved: "cook", capturing: "cook", running: "cook", quoted: "cook", sent: "cook", onshift: "cook",
  ready: "ready", outfordelivery: "ready", intransit: "ready", assigned: "ready",
  paid: "ok", completed: "ok", collected: "ok", done: "ok", executed: "ok", captured: "ok", applied: "ok", signed: "ok", success: "ok",
  resolved: "ok", delivered: "ok", received: "ok", active: "ok",
  partiallyrefunded: "warn", refunded: "warn", partial: "warn", due: "warn",
  uncertain: "late", failed: "late", unpaid: "late", missed: "late", overdue: "late", low: "late",
  cancelled: "off", rejected: "off", expired: "off", released: "off", voided: "off", declined: "off", inactive: "off", revoked: "off",
};
export const toneOf = (value: unknown) => tones[String(value ?? "").toLowerCase().replaceAll("_", "")] ?? "neutral";

/** "awaitingPayment" and "awaiting_payment" both read "Awaiting payment". */
export const words = (v: unknown) => {
  const s = String(v ?? "")
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replaceAll("_", " ");
  const lower = s.charAt(0) + s.slice(1).toLowerCase();
  return lower.charAt(0).toUpperCase() + lower.slice(1);
};

/** A local short date and time from an ISO instant; empty for nothing. */
export const when = (iso: unknown) =>
  iso ? new Date(String(iso)).toLocaleString([], { dateStyle: "short", timeStyle: "short" }) : "";
/** A day "2026-11-04" (or an instant) as a local short date. */
export const day = (value: unknown) => {
  if (!value) return "";
  const s = String(value);
  const date = /^\d{4}-\d{2}-\d{2}$/.test(s) ? new Date(`${s}T12:00:00`) : new Date(s);
  return Number.isNaN(date.getTime()) ? s : date.toLocaleDateString([], { dateStyle: "medium" });
};

const blank = (v: unknown) => v === null || v === undefined || v === "";
const integer = new Intl.NumberFormat("en");

type Value<T> = ColDef<T>["field"] | ((row: T) => unknown);
/** A column reads a field, or computes its value from the row. */
function source<T>(value: Value<T>): Pick<ColDef<T>, "field" | "valueGetter"> {
  if (typeof value === "function") {
    const read = value;
    return { valueGetter: (p: ValueGetterParams<T>) => (p.data ? read(p.data) : null) };
  }
  return { field: value };
}

/** Money in minor units, in the row's currency (or a fixed one). */
export function moneyCol<T>(
  headerName: string,
  value: Value<T>,
  currencyCode: string | ((row: T) => string | null | undefined),
  extra: Partial<ColDef<T>> & { total?: boolean } = {},
): ColDef<T> {
  const { total = true, ...rest } = extra;
  const codeOf = (row: unknown): string =>
    (typeof currencyCode === "function" ? (row ? currencyCode(row as T) : "") : currencyCode) ||
    String((row as { currency?: string } | undefined)?.currency ?? "USD");
  const show = (v: unknown, row: unknown) => (blank(v) ? "" : currency(Number(v), codeOf(row)));
  return {
    headerName,
    ...source(value),
    // AG Grid 36 no longer aligns `type: "rightAligned"` here (checked in the browser), so the classes are set directly.
    cellClass: "ops-num ag-right-aligned-cell",
    headerClass: "ag-right-aligned-header",
    filter: "agNumberColumnFilter",
    minWidth: 120,
    valueFormatter: (p: ValueFormatterParams<T>) => show(p.value, p.data),
    getQuickFilterText: (p) => show(p.value, p.data),
    context: {
      ...(total ? { total: "money" as const } : {}),
      currencyOf: codeOf,
      csv: (v: unknown) => (blank(v) ? "" : (Number(v) / 100).toFixed(2)),
    } satisfies ColumnContext,
    ...rest,
  };
}

/** A whole number (orders, covers, items), summed in the totals row. */
export function countCol<T>(
  headerName: string,
  value: Value<T>,
  extra: Partial<ColDef<T>> & { total?: boolean; format?: (n: number) => string } = {},
): ColDef<T> {
  const { total = true, format = (n: number) => integer.format(n), ...rest } = extra;
  const show = (v: unknown) => (blank(v) ? "" : format(Number(v)));
  return {
    headerName,
    ...source(value),
    // AG Grid 36 no longer aligns `type: "rightAligned"` here (checked in the browser), so the classes are set directly.
    cellClass: "ops-num ag-right-aligned-cell",
    headerClass: "ag-right-aligned-header",
    filter: "agNumberColumnFilter",
    minWidth: 100,
    valueFormatter: (p: ValueFormatterParams<T>) => show(p.value),
    getQuickFilterText: (p) => show(p.value),
    context: { ...(total ? { total: "sum" as const } : {}), format } satisfies ColumnContext,
    ...rest,
  };
}

/** An instant (or a day with `dayOnly`), sorted as time and filtered by date. */
export function dateCol<T>(
  headerName: string,
  value: Value<T>,
  extra: Partial<ColDef<T>> & { dayOnly?: boolean } = {},
): ColDef<T> {
  const { dayOnly = false, ...rest } = extra;
  const show = (v: unknown) => (dayOnly ? day(v) : when(v));
  return {
    headerName,
    ...source(value),
    minWidth: dayOnly ? 130 : 160,
    cellClass: "ops-num",
    valueFormatter: (p: ValueFormatterParams<T>) => show(p.value),
    getQuickFilterText: (p) => show(p.value),
    filter: "agDateColumnFilter",
    filterParams: {
      // Compare local calendar days, whatever the instant's time.
      comparator: (filterDate: Date, cell: unknown) => {
        if (blank(cell)) return -1;
        const s = String(cell);
        const d = /^\d{4}-\d{2}-\d{2}$/.test(s) ? new Date(`${s}T12:00:00`) : new Date(s);
        const a = new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
        const b = filterDate.getTime();
        return a < b ? -1 : a > b ? 1 : 0;
      },
    },
    comparator: (a: unknown, b: unknown) => {
      const x = blank(a) ? 0 : Date.parse(String(a));
      const y = blank(b) ? 0 : Date.parse(String(b));
      return x - y;
    },
    context: { csv: (v: unknown) => (blank(v) ? "" : String(v)) } satisfies ColumnContext,
    ...rest,
  };
}

/** A state as a colored pill; `label` rewords a value ("review" → "Under review"). */
export function statusCol<T>(
  headerName: string,
  value: Value<T>,
  extra: Partial<ColDef<T>> & { label?: (v: unknown) => string } = {},
): ColDef<T> {
  const { label = words, ...rest } = extra;
  const show = (v: unknown) => (blank(v) ? "" : label(v));
  return {
    headerName,
    ...source(value),
    minWidth: 150,
    valueFormatter: (p: ValueFormatterParams<T>) => show(p.value),
    getQuickFilterText: (p) => show(p.value),
    cellRenderer: renderers.pill,
    context: { csv: (v: unknown) => show(v) } satisfies ColumnContext,
    ...rest,
  };
}

/** Yes or no as an icon with its words for screen readers and the CSV. */
export function boolCol<T>(
  headerName: string,
  value: Value<T>,
  extra: Partial<ColDef<T>> & { labels?: [yes: string, no: string] } = {},
): ColDef<T> {
  const { labels = ["Yes", "No"], ...rest } = extra;
  const show = (v: unknown) => (blank(v) ? "" : v === true || v === "true" ? labels[0] : labels[1]);
  return {
    headerName,
    ...source(value),
    minWidth: 100,
    flex: 0.6,
    cellClass: "ops-bool",
    valueFormatter: (p: ValueFormatterParams<T>) => show(p.value),
    getQuickFilterText: (p) => show(p.value),
    filterValueGetter: (p) =>
      show(
        typeof value === "function"
          ? p.data
            ? value(p.data)
            : null
          : String(value ?? "")
              .split(".")
              .reduce<unknown>((o, k) => (o == null ? o : (o as Record<string, unknown>)[k]), p.data),
      ),
    cellRenderer: renderers.bool,
    context: { csv: (v: unknown) => show(v) } satisfies ColumnContext,
    ...rest,
  };
}

/** A record or provider id in monospace, with a copy button. */
export function idCol<T>(
  headerName: string,
  value: Value<T>,
  extra: Partial<ColDef<T>> & { prefix?: string } = {},
): ColDef<T> {
  const { prefix = "", ...rest } = extra;
  const show = (v: unknown) => (blank(v) ? "" : `${prefix}${v}`);
  return {
    headerName,
    ...source(value),
    minWidth: 120,
    flex: 0.7,
    cellClass: "ops-id",
    valueFormatter: (p: ValueFormatterParams<T>) => show(p.value),
    getQuickFilterText: (p) => show(p.value),
    cellRenderer: renderers.id,
    context: { csv: (v: unknown) => (blank(v) ? "" : String(v)) } satisfies ColumnContext,
    ...rest,
  };
}

/** A stable id for each column: its colId, its field, or its header in lower case. */
export function columnIds<T>(columns: ColDef<T>[]): string[] {
  const seen = new Set<string>();
  return columns.map((c, i) => {
    let id =
      c.colId ??
      (typeof c.field === "string" ? c.field : undefined) ??
      (c.headerName ? c.headerName.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") : "") ??
      "";
    if (!id) id = `col-${i}`;
    while (seen.has(id)) id = `${id}-${i}`;
    seen.add(id);
    return id;
  });
}

/**
 * The totals row's words for each column that adds up, from the rows the
 * filter left. Money is summed per currency: one currency reads "$12.50",
 * several read "€8.00 · $12.50", and none is ever added to another.
 */
export function columnTotals<T, I>(
  columns: ColDef<T>[],
  items: readonly I[],
  valueOf: (column: ColDef<T>, id: string, item: I) => unknown,
  dataOf: (item: I) => T,
): Record<string, string> {
  const ids = columnIds(columns);
  const out: Record<string, string> = {};
  columns.forEach((c, i) => {
    const ctx = (c.context ?? {}) as ColumnContext;
    if (!ctx.total) return;
    const id = ids[i];
    if (ctx.total === "sum") {
      let n = 0;
      for (const item of items) {
        const v = Number(valueOf(c, id, item));
        if (Number.isFinite(v)) n += v;
      }
      out[id] = (ctx.format ?? ((x: number) => integer.format(x)))(n);
      return;
    }
    const sums = new Map<string, number>();
    for (const item of items) {
      const raw = valueOf(c, id, item);
      if (blank(raw)) continue;
      const v = Number(raw);
      if (!Number.isFinite(v)) continue;
      const code = (ctx.currencyOf?.(dataOf(item)) || "USD").toUpperCase();
      sums.set(code, (sums.get(code) ?? 0) + v);
    }
    out[id] =
      sums.size === 0
        ? ""
        : [...sums]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([code, minor]) => currency(minor, code))
            .join(" · ");
  });
  return out;
}

/** The label column: the first column that does not add up, or none. */
export function totalsLabelColumn<T>(columns: ColDef<T>[]): number {
  return columns.findIndex((c) => !((c.context ?? {}) as ColumnContext).total && !c.hide);
}

/** "Total of 3" for the label cell. */
export const totalsLabel = (shown: number) => (shown === 1 ? "Total of 1 row" : `Total of ${integer.format(shown)} rows`);
