/**
 * Development preview only (/ops/preview): illustrative Supplies records for
 * the browser tests, in the shapes the backend sends (purchasing.dart).
 * Nothing here is a real supplier, order or bill. Owner: stream S3.
 */
import type { Json } from "./contracts";
import type { Delivery, Forecast, ForecastRow, Recipe, Scorecard, SupplierOrder } from "./supplies";

const day = 86_400_000;

function row(
  stockItemId: number,
  name: string,
  unit: string,
  quantity: number,
  costMinor: number,
  lowAt: number,
  supplier: [number, string] | null,
  dailyUsage: number,
  leadDays: number,
  parLevel?: number,
): ForecastRow {
  const now = Date.now();
  const daysCover = dailyUsage > 0 ? Math.round((quantity / dailyUsage) * 10) / 10 : null;
  const atArrival = quantity - dailyUsage * leadDays;
  const par = parLevel ?? Math.max(lowAt * 2, dailyUsage * (leadDays + 7));
  const short = dailyUsage > 0 ? atArrival < lowAt : quantity < lowAt;
  const raw = Math.max(0, par - Math.max(0, atArrival));
  const suggestedQty = short ? (unit === "piece" || unit === "box" ? Math.ceil(raw) : Math.round(raw * 100) / 100) : 0;
  return {
    stockItemId,
    name,
    unit,
    quantity,
    lowAt,
    low: quantity <= lowAt,
    costMinor,
    valueMinor: Math.round(quantity * costMinor),
    leadDays,
    supplierId: supplier?.[0] ?? null,
    supplierName: supplier?.[1] ?? null,
    version: 3,
    dailyUsage,
    daysCover,
    stockOutAt: daysCover == null ? null : new Date(now + daysCover * day).toISOString(),
    atArrival: Math.round(atArrival * 1000) / 1000,
    parLevel: Math.round(par * 1000) / 1000,
    reorder: short && suggestedQty > 0,
    suggestedQty,
  };
}

export function suppliesPreview(asOf: string): Record<string, (p: Json) => unknown> {
  const now = Date.now();
  const iso = (offsetDays: number) => new Date(now + offsetDays * day).toISOString();
  const dupont: [number, string] = [1, "Marché Dupont"];
  const verger: [number, string] = [2, "Verger du Val"];
  const nord: [number, string] = [3, "Café Nord Roasters"];
  const rows = [
    row(1, "Flour T55", "kg", 10, 120, 8, dupont, 2, 2),
    row(2, "Butter AOP", "kg", 3.5, 980, 3, dupont, 0.6, 2),
    row(3, "Free-range eggs", "piece", 40, 32, 60, verger, 14, 1, 180),
    row(4, "Whole milk", "l", 24, 110, 10, verger, 4.5, 1),
    row(5, "Espresso beans", "kg", 6, 2200, 2, nord, 0.4, 4),
    row(6, "Oranges", "kg", 18, 210, 5, verger, 1.2, 1),
    row(7, "Sea salt", "kg", 4, 90, 1, null, 0.05, 2),
  ];
  const forecast: Forecast = {
    rows,
    basis: "movements",
    windowDays: 28,
    currency: "USD",
    waste: [
      { stockItemId: 4, name: "Whole milk", unit: "l", quantity: 2, valueMinor: 220, reason: "expired", at: iso(-1) },
      { stockItemId: 6, name: "Oranges", unit: "kg", quantity: 1.5, valueMinor: 315, reason: "spoiled", at: iso(-3) },
      { stockItemId: 3, name: "Free-range eggs", unit: "piece", quantity: 6, valueMinor: 192, reason: "dropped", at: iso(-6) },
    ],
  };
  const orders: SupplierOrder[] = [
    {
      id: 14,
      supplierId: 1,
      supplierName: "Marché Dupont",
      supplierEmail: "orders@dupont.example.com",
      state: "sent",
      lines: [
        { stockItemId: 1, name: "Flour T55", unit: "kg", qty: 25, unitCostMinor: 120, receivedQty: 0 },
        { stockItemId: 2, name: "Butter AOP", unit: "kg", qty: 10, unitCostMinor: 980, receivedQty: 0 },
      ],
      totalMinor: 12800,
      currency: "USD",
      expectedAt: iso(1),
      sentAt: iso(-1),
      version: 3,
      createdAt: iso(-1),
      updatedAt: iso(-1),
    },
    {
      id: 13,
      supplierId: 2,
      supplierName: "Verger du Val",
      supplierEmail: null,
      state: "draft",
      lines: [{ stockItemId: 3, name: "Free-range eggs", unit: "piece", qty: 180, unitCostMinor: 32, receivedQty: 0 }],
      totalMinor: 5760,
      currency: "USD",
      expectedAt: iso(1),
      note: "Proposed by the supply planner",
      taskId: 41,
      version: 1,
      createdAt: iso(0),
      updatedAt: iso(0),
    },
    {
      id: 12,
      supplierId: 3,
      supplierName: "Café Nord Roasters",
      supplierEmail: "hello@cafenord.example.com",
      state: "billed",
      lines: [{ stockItemId: 5, name: "Espresso beans", unit: "kg", qty: 5, unitCostMinor: 2200, receivedQty: 5, receivedUnitCostMinor: 2350 }],
      totalMinor: 11000,
      currency: "USD",
      expectedAt: iso(-6),
      sentAt: iso(-10),
      receivedAt: iso(-5),
      billId: 7,
      billState: "approved",
      version: 6,
      createdAt: iso(-10),
      updatedAt: iso(-5),
    },
    {
      id: 11,
      supplierId: 1,
      supplierName: "Marché Dupont",
      supplierEmail: "orders@dupont.example.com",
      state: "paid",
      lines: [{ stockItemId: 1, name: "Flour T55", unit: "kg", qty: 25, unitCostMinor: 120, receivedQty: 25 }],
      totalMinor: 3000,
      currency: "USD",
      expectedAt: iso(-13),
      sentAt: iso(-15),
      receivedAt: iso(-13),
      billId: 5,
      billState: "paid",
      version: 7,
      createdAt: iso(-15),
      updatedAt: iso(-12),
    },
  ];
  const match = {
    lines: [
      { name: "Espresso beans", stockItemId: 5, unit: "kg", orderedQty: 5, deliveredQty: 5, qtyVariance: 0, orderedUnitMinor: 2200, deliveredUnitMinor: 2350, billedUnitMinor: 2350, priceVariancePct: 6.8, flags: ["price_up"] },
    ],
    flagged: 1,
    orderedTotalMinor: 11000,
    deliveredTotalMinor: 11750,
    billTotalMinor: 11750,
    billDiffers: false,
    clean: false,
    currency: "USD",
    supplierOrderId: 12,
    billId: 7,
    billState: "review",
    reference: "CN-2211",
    explanation: "All 5 kg of espresso beans arrived, at 23.50 a kilo instead of the 22.00 ordered (+6.8%). The bill matches the note; ask Café Nord about the price before the next order.",
  };
  const deliveries: Delivery[] = [
    {
      id: 9,
      supplierId: 3,
      mediaId: 31,
      lines: [{ name: "Espresso beans", quantity: 5, unit: "kg", unitCostMinor: 2350 }],
      totalMinor: 11750,
      currency: "USD",
      state: "received",
      taskId: 40,
      supplierOrderId: 12,
      match,
      version: 2,
      createdAt: iso(-5),
    },
  ];
  const scorecards: Scorecard[] = [
    { supplierId: 1, name: "Marché Dupont", orders: 6, onTimePct: 100, fillRatePct: 97.5, priceVariancePct: 0.4, lastOrderAt: iso(-1), leadDays: 2, hasEmail: true, hasPayPal: true },
    { supplierId: 2, name: "Verger du Val", orders: 4, onTimePct: 75, fillRatePct: 88, priceVariancePct: -1.2, lastOrderAt: iso(-8), leadDays: 1, hasEmail: false, hasPayPal: true },
    { supplierId: 3, name: "Café Nord Roasters", orders: 3, onTimePct: 66.7, fillRatePct: 100, priceVariancePct: 6.8, lastOrderAt: iso(-10), leadDays: 4, hasEmail: true, hasPayPal: false },
  ];
  const recipes: Recipe[] = [
    {
      productId: 1,
      name: "Butter croissant",
      priceMinor: 350,
      available: true,
      lines: [
        { stockItemId: 1, name: "Flour T55", unit: "kg", quantity: 0.05, costMinor: 6 },
        { stockItemId: 2, name: "Butter AOP", unit: "kg", quantity: 0.025, costMinor: 25 },
      ],
    },
    { productId: 2, name: "Flat white", priceMinor: 420, available: true, lines: [{ stockItemId: 5, name: "Espresso beans", unit: "kg", quantity: 0.018, costMinor: 40 }, { stockItemId: 4, name: "Whole milk", unit: "l", quantity: 0.15, costMinor: 17 }] },
    { productId: 3, name: "Fresh orange juice", priceMinor: 550, available: true, lines: [] },
  ];
  return {
    "stock.forecast": () => forecast,
    "supplier.orders": () => ({ rows: orders, nextCursor: null }),
    "supplier.order": (p) => {
      const o = orders.find((x) => x.id === Number(p.id));
      return o ? { ...o, delivery: o.id === 12 ? { id: 9, state: "received", totalMinor: 11750, mediaId: 31, match } : null } : null;
    },
    "supplier.scorecards": () => ({ rows: scorecards, nextCursor: null }),
    recipes: () => ({ rows: recipes, nextCursor: null }),
    "supply.deliveries": () => ({ rows: deliveries, nextCursor: null, asOf }),
  };
}
