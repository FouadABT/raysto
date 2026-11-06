/**
 * Supplies: stock with its forecast, supplier orders, deliveries checked
 * against the order and the bill (the 3-way match), recipes and waste.
 * Money is integer minor units; dates are ISO strings. The forecast's
 * numbers are plain arithmetic on the server (purchasing.dart); the supply
 * planner's AI only explains them and proposes orders a manager approves.
 * Owner: stream S3.
 *
 * Queries (all take restaurantId):
 *   stock.forecast             → Forecast (rows, basis, waste log)
 *   supplier.orders            → { rows: SupplierOrder[] }
 *   supplier.order {id}        → SupplierOrder (with its latest delivery and match)
 *   supplier.scorecards        → { rows: Scorecard[] }
 *   recipes                    → { rows: Recipe[] }
 *   supply.deliveries          → { rows: Delivery[] }
 * Commands:
 *   supplier.order.save {supplierId?, lines[{stockItemId, qty, unitCostMinor?}], expectedAt?, note?} (id?, version?)
 *   supplier.order.save {state: "cancelled"} (id, version)   cancels a draft or a sent order
 *   supplier.order.send {email?} (id, version)               emails the supplier; the email is kept
 *   supplier.order.receive {lines[{stockItemId, qty, unitCostMinor?}], deliveryId?} (id, version)
 *   recipe.save {productId, lines[{stockItemId, quantity}]}
 *   stock.count {stockItemId, quantity}
 *   stock.waste {stockItemId, quantity, reason}
 *   supplies.plan                                           → { taskId }
 *   supply.receive {mediaId, supplierOrderId?}               → { taskId }
 * Agent proposals: supplier.order.propose, stock.receive, bill.match.
 */
import type { ConnectedApi } from "./api";
import { asRows, type AgentActionRow } from "./business";
import { currency, type Json } from "./contracts";
import type { StudioRow, StudioSource } from "./studio/sources";
import type { StudioState, StudioWidgetSpec } from "./studio/studio-canvas";

export interface ForecastRow {
  stockItemId: number;
  name: string;
  unit: string;
  quantity: number;
  lowAt: number;
  low: boolean;
  costMinor: number;
  valueMinor: number;
  leadDays: number;
  supplierId?: number | null;
  supplierName?: string | null;
  version: number;
  dailyUsage: number;
  daysCover: number | null;
  stockOutAt: string | null;
  atArrival: number;
  parLevel: number;
  reorder: boolean;
  suggestedQty: number;
}

export interface WasteEntry {
  stockItemId: number;
  name?: string | null;
  unit?: string | null;
  quantity: number;
  valueMinor: number;
  reason: string;
  at: string;
}

export interface Forecast {
  rows: ForecastRow[];
  /** Where usage came from: stock movements, completed orders × recipes, or nothing yet. */
  basis: "movements" | "recipes" | "none";
  windowDays: number;
  currency: string;
  waste: WasteEntry[];
}

export interface OrderLine {
  stockItemId: number;
  name: string;
  unit: string;
  qty: number;
  unitCostMinor: number;
  receivedQty?: number;
  receivedUnitCostMinor?: number;
}

export interface MatchLine {
  name: string;
  stockItemId?: number | null;
  unit?: string | null;
  orderedQty: number;
  deliveredQty: number | null;
  qtyVariance: number;
  orderedUnitMinor: number | null;
  deliveredUnitMinor: number | null;
  billedUnitMinor: number | null;
  priceVariancePct: number | null;
  flags: string[];
}

export interface Match {
  lines: MatchLine[];
  flagged: number;
  orderedTotalMinor: number;
  deliveredTotalMinor: number;
  billTotalMinor: number | null;
  billDiffers: boolean;
  clean: boolean;
  currency: string;
  supplierOrderId: number;
  billId?: number | null;
  billState?: string | null;
  reference?: string | null;
  explanation?: string;
}

export interface SupplierOrder {
  id: number;
  supplierId?: number | null;
  supplierName?: string | null;
  supplierEmail?: string | null;
  state: string;
  lines: OrderLine[];
  totalMinor: number;
  currency: string;
  expectedAt?: string | null;
  sentAt?: string | null;
  receivedAt?: string | null;
  billId?: number | null;
  billState?: string | null;
  taskId?: number | null;
  note?: string | null;
  version: number;
  createdAt: string;
  updatedAt: string;
  delivery?: {
    id: number;
    state: string;
    totalMinor: number;
    mediaId: number;
    match: Match | null;
  } | null;
}

export interface Delivery {
  id: number;
  supplierId?: number | null;
  mediaId: number;
  lines: {
    name: string;
    quantity: number;
    unit: string;
    unitCostMinor: number;
  }[];
  totalMinor: number;
  currency: string;
  state: string;
  taskId?: number | null;
  supplierOrderId?: number | null;
  match?: Match | null;
  version: number;
  createdAt: string;
}

export interface Scorecard {
  supplierId: number;
  name: string;
  orders: number;
  onTimePct: number | null;
  fillRatePct: number | null;
  priceVariancePct: number | null;
  lastOrderAt?: string | null;
  leadDays: number;
  hasEmail: boolean;
  hasPayPal: boolean;
}

export interface RecipeLine {
  stockItemId: number;
  name?: string | null;
  unit?: string | null;
  quantity: number;
  costMinor: number;
}

export interface Recipe {
  productId: number;
  name: string;
  priceMinor: number;
  available: boolean;
  lines: RecipeLine[];
}

export const wasteReasons = [
  ["spoiled", "Spoiled"],
  ["expired", "Past its date"],
  ["dropped", "Dropped or broken"],
  ["prep", "Prep trim"],
  ["other", "Other"],
] as const;
export type WasteReason = (typeof wasteReasons)[number][0];

/* ---------- Pure helpers (unit tested in tests/supplies.test.ts) ---------- */

/** A purchase order's stages in order; a funnel counts the orders that reached each. */
export const poStages = [
  ["draft", "Drafted"],
  ["sent", "Sent"],
  ["received", "Received"],
  ["billed", "Bill approved"],
  ["paid", "Paid"],
] as const;
const rank: Record<string, number> = {
  draft: 0,
  sent: 1,
  partiallyReceived: 2,
  received: 2,
  billed: 3,
  paid: 4,
};

/** How many orders reached each stage (cancelled ones reach none). */
export function poFunnel(
  orders: Pick<SupplierOrder, "state">[],
): { stage: string; label: string; count: number }[] {
  return poStages.map(([stage, label], i) => ({
    stage,
    label,
    count: orders.filter((o) => (rank[o.state] ?? -1) >= i).length,
  }));
}

/** What is still to arrive on a line. */
export const remaining = (l: Pick<OrderLine, "qty" | "receivedQty">) =>
  Math.max(0, round(l.qty - (l.receivedQty ?? 0), 3));

/** The receipt a person starts from: whatever is still to arrive, at the ordered price. */
export const receiptDraft = (o: Pick<SupplierOrder, "lines">) =>
  o.lines
    .filter((l) => remaining(l) > 0)
    .map((l) => ({ stockItemId: l.stockItemId, qty: remaining(l) }));

/** The actions an order offers next, in the order a manager takes them. */
export function orderActions(
  o: Pick<SupplierOrder, "state">,
): ("send" | "receive" | "cancel")[] {
  if (o.state === "draft") return ["send", "cancel"];
  if (o.state === "sent") return ["receive", "cancel"];
  if (o.state === "partiallyReceived") return ["receive"];
  return [];
}

/** A stock row's state as a word the grid colours: reorder, low or fine. */
export const stockState = (r: Pick<ForecastRow, "reorder" | "low">) =>
  r.reorder ? "reorder" : r.low ? "low" : "ok";

/** Days of cover as a person reads it. */
export const coverText = (r: Pick<ForecastRow, "daysCover">) =>
  r.daysCover == null
    ? "No recent use"
    : r.daysCover < 1
      ? "Under a day"
      : `${r.daysCover.toFixed(1)} days`;

export const basisText = (b: Forecast["basis"], days = 28) =>
  b === "movements"
    ? `Usage from the last ${days} days of sales and waste.`
    : b === "recipes"
      ? `Usage from the last ${days} days of completed orders and their recipes.`
      : "No usage recorded yet: add recipes so each completed order counts down stock.";

const flagNames: Record<string, string> = {
  short: "Short",
  over: "More than ordered",
  missing: "Missing",
  not_ordered: "Not ordered",
  price_up: "Dearer",
  price_down: "Cheaper",
  billed_differs: "Bill differs",
};
export const flagLabel = (f: string) => flagNames[f] ?? f;
/** A flag's tone: money against the café is late (red), the rest a warning. */
export const flagTone = (f: string) =>
  ["short", "missing", "price_up", "billed_differs"].includes(f)
    ? "late"
    : "warn";

const qtyFormat = new Intl.NumberFormat("en", { maximumFractionDigits: 3 });
export const qty = (n: number | null | undefined, unit?: string | null) =>
  n == null ? "" : `${qtyFormat.format(n)}${unit ? ` ${unit}` : ""}`;

/** One match line in words, so the colour is never the only signal. */
export function matchText(l: MatchLine, code: string): string {
  if (l.flags.includes("not_ordered"))
    return `${qty(l.deliveredQty, l.unit)} arrived but were not ordered.`;
  if (l.flags.includes("missing"))
    return `Nothing arrived of ${qty(l.orderedQty, l.unit)} ordered.`;
  const parts: string[] = [];
  if (l.flags.includes("short"))
    parts.push(
      `${qty(Math.abs(l.qtyVariance), l.unit)} short (${qty(l.deliveredQty)} of ${qty(l.orderedQty, l.unit)})`,
    );
  if (l.flags.includes("over"))
    parts.push(`${qty(l.qtyVariance, l.unit)} more than ordered`);
  if (
    (l.flags.includes("price_up") || l.flags.includes("price_down")) &&
    l.deliveredUnitMinor != null &&
    l.orderedUnitMinor != null
  )
    parts.push(
      `${currency(l.deliveredUnitMinor, code)} instead of ${currency(l.orderedUnitMinor, code)} a unit (${(l.priceVariancePct ?? 0) > 0 ? "+" : ""}${l.priceVariancePct}%)`,
    );
  if (l.flags.includes("billed_differs") && l.billedUnitMinor != null)
    parts.push(`the bill charges ${currency(l.billedUnitMinor, code)} a unit`);
  return parts.length ? `${parts.join("; ")}.` : "As ordered.";
}

/** A typed quantity: "2,5" and "2.5" both read 2.5; anything else is null. */
export function parseQty(text: string): number | null {
  const t = text.trim().replace(",", ".");
  if (!/^\d+(\.\d+)?$/.test(t)) return null;
  const n = Number(t);
  return Number.isFinite(n) ? n : null;
}

/** Cost of one portion of a dish from its recipe. */
export const portionCost = (r: Pick<Recipe, "lines">) =>
  r.lines.reduce((n, l) => n + l.costMinor, 0);

/** Reorder rows grouped by supplier, each with its suggested lines (the "draft from the forecast" button). */
export function reorderGroups(rows: ForecastRow[]) {
  const groups = new Map<
    number | null,
    {
      supplierId: number | null;
      supplierName: string;
      rows: ForecastRow[];
      totalMinor: number;
    }
  >();
  for (const r of rows.filter((x) => x.reorder)) {
    const k = r.supplierId ?? null;
    const g = groups.get(k) ?? {
      supplierId: k,
      supplierName: r.supplierName ?? "No supplier yet",
      rows: [],
      totalMinor: 0,
    };
    g.rows.push(r);
    g.totalMinor += Math.round(r.suggestedQty * r.costMinor);
    groups.set(k, g);
  }
  return [...groups.values()].sort((a, b) => b.totalMinor - a.totalMinor);
}

const round = (v: number, places: number) =>
  Math.round(v * 10 ** places) / 10 ** places;

/* ---------- AG Studio sources and pages ---------- */

/** One row per stock item for Studio; money in major units. */
export function stockSource(f: Forecast | undefined): StudioRow[] {
  return (f?.rows ?? []).map((r) => ({
    name: r.name,
    supplier: r.supplierName ?? "No supplier",
    unit: r.unit,
    quantity: r.quantity,
    value: Math.round(r.valueMinor) / 100,
    cover: r.daysCover,
    low: r.low ? 1 : 0,
    reorder: r.reorder ? 1 : 0,
  }));
}

export function funnelSource(orders: SupplierOrder[]): StudioRow[] {
  return poFunnel(orders).map((s) => ({ stage: s.label, orders: s.count }));
}

export function scorecardSource(rows: Scorecard[]): StudioRow[] {
  return rows
    .filter((r) => r.onTimePct != null)
    .map((r) => ({
      supplier: r.name,
      onTime: r.onTimePct,
      priceVariance: r.priceVariancePct ?? 0,
      fillRate: r.fillRatePct,
      orders: r.orders,
    }));
}

type Place = { xTrack: number; yTrack: number; xSpan: number; ySpan: number };
const at = (
  xTrack: number,
  yTrack: number,
  xSpan: number,
  ySpan: number,
): Place => ({ xTrack, yTrack, xSpan, ySpan });
const title = (text: string) => ({ title: { text, enabled: true } });

/** The Inventory canvas: shortest cover, low and reorder counts, stock value, and value by supplier and item. */
export function inventoryState(currencyCode: string): StudioState {
  const c = currencyCode.toUpperCase();
  const widgets: Record<string, StudioWidgetSpec> = {
    cover: {
      type: "radial-gauge",
      format: {
        ...title("Shortest cover (days)"),
        style: {
          label: { enabled: true },
          secondaryLabel: {
            enabled: true,
            text: "until the first item runs out",
          },
          scaleLabel: { min: 0, max: 14 },
        },
      },
      dataMapping: { value: [{ id: "stock.cover", aggregation: "min" }] },
    },
    low: {
      type: "value",
      format: title("Below low mark"),
      dataMapping: { value: [{ id: "stock.low", aggregation: "sum" }] },
    },
    reorder: {
      type: "value",
      format: title("Reorder now"),
      dataMapping: { value: [{ id: "stock.reorder", aggregation: "sum" }] },
    },
    value: {
      type: "value",
      format: title(`Stock value (${c})`),
      dataMapping: { value: [{ id: "stock.value", aggregation: "sum" }] },
    },
    map: {
      type: "treemap-chart",
      format: title(`Stock value by supplier and item (${c})`),
      dataMapping: {
        categoryKey: [{ id: "stock.supplier" }, { id: "stock.name" }],
        valueKey: [{ id: "stock.value", aggregation: "sum" }],
      },
    },
  };
  const page = {
    id: "inventory",
    widgets,
    widgetLayout: {
      cover: at(0, 0, 8, 14),
      low: at(8, 0, 8, 7),
      reorder: at(16, 0, 8, 7),
      value: at(8, 7, 16, 7),
      map: at(0, 14, 24, 18),
    },
  };
  return {
    pages: [page],
    selectedPageId: "inventory",
  } as unknown as StudioState;
}

export const funnelWidget: StudioWidgetSpec = {
  type: "funnel-chart",
  format: title("Purchase orders by stage"),
  dataMapping: {
    categoryKey: [{ id: "orders.stage" }],
    valueKey: [{ id: "orders.orders", aggregation: "sum" }],
  },
};

export const scatterWidget: StudioWidgetSpec = {
  type: "scatter-chart",
  format: title("On time (%) against price change (%) by supplier"),
  dataMapping: {
    groupByKey: [{ id: "suppliers.supplier" }],
    categoryKey: [{ id: "suppliers.onTime", aggregation: "avg" }],
    valueKey: [{ id: "suppliers.priceVariance", aggregation: "avg" }],
  },
};

export const source = (id: string, data: StudioRow[]): StudioSource => ({
  id,
  data,
  ...(id === "stock"
    ? {
        fields: [
          ...["name", "supplier", "unit"].map((id) => ({
            id,
            format: "textFormat" as const,
          })),
          ...["quantity", "value", "cover", "low", "reorder"].map((id) => ({
            id,
            format: "decimalFormat" as const,
          })),
        ],
      }
    : {}),
});

/* ---------- Data access ---------- */

export const supplies = (api: ConnectedApi, tenant: number) => ({
  forecast: () =>
    api.query<Forecast>("stock.forecast", { restaurantId: tenant }),
  orders: async () =>
    asRows<SupplierOrder>(
      await api.query<Json>("supplier.orders", {
        restaurantId: tenant,
        limit: 100,
      }),
    ),
  order: (id: number) =>
    api.query<SupplierOrder>("supplier.order", { restaurantId: tenant, id }),
  scorecards: async () =>
    asRows<Scorecard>(
      await api.query<Json>("supplier.scorecards", { restaurantId: tenant }),
    ),
  recipes: async () =>
    asRows<Recipe>(await api.query<Json>("recipes", { restaurantId: tenant })),
  deliveries: async () =>
    asRows<Delivery>(
      await api.query<Json>("supply.deliveries", {
        restaurantId: tenant,
        limit: 50,
      }),
    ),
  inbox: async () =>
    asRows<AgentActionRow>(
      await api
        .query<Json>("agent.inbox", { restaurantId: tenant })
        .catch(() => ({ rows: [] })),
    ),
  saveOrder: (data: Json, at?: { id: number; version: number }) =>
    api.command<{ orderId: number; state: string; version: number }>(
      "supplier.order.save",
      tenant,
      data,
      at ?? {},
    ),
  cancelOrder: (o: Pick<SupplierOrder, "id" | "version">) =>
    api.command<{ state: string }>(
      "supplier.order.save",
      tenant,
      { state: "cancelled" },
      { id: o.id, version: o.version },
    ),
  sendOrder: (o: Pick<SupplierOrder, "id" | "version">, email?: string) =>
    api.command<{ state: string; emailed: boolean; to?: string | null }>(
      "supplier.order.send",
      tenant,
      email ? { email } : {},
      { id: o.id, version: o.version },
    ),
  receiveOrder: (
    o: Pick<SupplierOrder, "id" | "version">,
    lines: { stockItemId: number; qty: number; unitCostMinor?: number }[],
  ) =>
    api.command<{ state: string; complete: boolean }>(
      "supplier.order.receive",
      tenant,
      { lines },
      { id: o.id, version: o.version },
    ),
  saveRecipe: (
    productId: number,
    lines: { stockItemId: number; quantity: number }[],
  ) =>
    api.command<{ lines: number }>("recipe.save", tenant, { productId, lines }),
  count: (stockItemId: number, quantity: number) =>
    api.command<{ variance: number }>("stock.count", tenant, {
      stockItemId,
      quantity,
    }),
  waste: (stockItemId: number, quantity: number, reason: WasteReason) =>
    api.command<{ quantity: number }>("stock.waste", tenant, {
      stockItemId,
      quantity,
      reason,
    }),
  plan: () => api.command<{ taskId: number }>("supplies.plan", tenant, {}),
  receiveNote: (mediaId: number, supplierOrderId?: number) =>
    api.command<{ taskId: number }>(
      "supply.receive",
      tenant,
      supplierOrderId ? { mediaId, supplierOrderId } : { mediaId },
    ),
});
export type SuppliesApi = ReturnType<typeof supplies>;
