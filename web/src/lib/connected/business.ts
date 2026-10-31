/** Whole-business views for the owner console. Money is integer minor units. */
import type { Json } from "./contracts";

export interface OrderRow {
  id: number;
  number: number | null;
  origin: string;
  fulfillment: string;
  status: string;
  paymentStatus: string;
  totalMinor: number;
  currency: string;
  createdAt: string;
  visitId: number | null;
  customerLabel: string | null;
  version: number;
}

export interface CheckoutRow {
  id: number;
  checkoutId: number;
  orderId: number | null;
  visitId: number | null;
  method: string;
  state: string;
  amountMinor: number;
  currency: string;
  createdAt: string;
}

export interface CollectionRow {
  id: number;
  checkoutId: number;
  method: string | null;
  providerCaptureId: string | null;
  orderId: number | null;
  visitId: number | null;
  amountMinor: number;
  refundedMinor: number;
  currency: string;
  state: string;
  createdAt: string;
}

export interface RefundRow {
  id: number;
  captureId: number;
  providerRefundId: string | null;
  amountMinor: number;
  state: string;
  reason: string;
  createdAt: string;
}

export interface Summary {
  currency: string;
  ordersCreated: number;
  completedOrders: number;
  bookedSalesMinor: number;
  collectionsMinor: number;
  refundsMinor: number;
  currentOutstandingMinorForOrdersInRange: number;
}

export type Channel = "Counter" | "Pickup" | "Dine-in" | "Delivery";

export const channelOf = (o: Pick<OrderRow, "origin" | "fulfillment">): Channel =>
  o.origin === "counter"
    ? "Counter"
    : o.fulfillment === "dineIn"
      ? "Dine-in"
      : o.fulfillment === "delivery"
        ? "Delivery"
        : "Pickup";

/** "pickup:counter" style keys from the channels report, regrouped by channel. */
export function channelMix(
  channels: Record<string, { orders: number; salesMinor: number }>,
): { channel: Channel; orders: number; salesMinor: number }[] {
  const out = new Map<Channel, { orders: number; salesMinor: number }>();
  for (const [key, value] of Object.entries(channels)) {
    const [fulfillment, origin] = key.split(":");
    const channel = channelOf({ fulfillment, origin });
    const sum = out.get(channel) ?? { orders: 0, salesMinor: 0 };
    sum.orders += value.orders;
    sum.salesMinor += value.salesMinor;
    out.set(channel, sum);
  }
  return [...out.entries()]
    .map(([channel, v]) => ({ channel, ...v }))
    .sort((a, b) => b.salesMinor - a.salesMinor);
}

export type StatusGroup = "New" | "Preparing" | "Ready" | "Done";

export const statusGroup = (status: string): StatusGroup =>
  status === "awaitingPayment" || status === "submitted"
    ? "New"
    : status === "accepted" || status === "preparing"
      ? "Preparing"
      : ["ready", "served", "collected", "outForDelivery", "delivered"].includes(
            status,
          )
        ? "Ready"
        : "Done";

export const isPaid = (paymentStatus: string) =>
  ["paid", "partiallyRefunded", "refunded"].includes(paymentStatus);

/** The next order step a manager can take from the console, if any. */
export function nextStep(o: Pick<OrderRow, "status" | "fulfillment">) {
  switch (o.status) {
    case "submitted":
      return "accepted";
    case "accepted":
      return "preparing";
    case "preparing":
      return "ready";
    case "ready":
      return o.fulfillment === "dineIn"
        ? "served"
        : o.fulfillment === "pickup"
          ? "collected"
          : null;
    case "served":
    case "collected":
    case "delivered":
      return "completed";
    default:
      return null;
  }
}

/** Local day bounds as ISO strings, for the report query. */
export function dayRange(now: Date, daysBack = 0) {
  const start = new Date(now);
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - daysBack);
  const until = new Date(now);
  until.setHours(0, 0, 0, 0);
  until.setDate(until.getDate() + 1);
  return { from: start.toISOString(), until: until.toISOString() };
}

/**
 * PayPal attempts automatic recovery has not closed: a capture or an
 * uncertain outcome, or an approval link left unfinished for 30 minutes.
 */
export function unresolved(rows: CheckoutRow[], now: Date): CheckoutRow[] {
  return rows.filter(
    (r) =>
      r.method === "paypal" &&
      (["capturing", "uncertain"].includes(r.state) ||
        (["created", "approved"].includes(r.state) &&
          now.getTime() - new Date(r.createdAt).getTime() > 30 * 60 * 1000)),
  );
}

/** Totals kept apart by method: PayPal and cash are never blended. */
export function collectionTotals(rows: CollectionRow[]) {
  let paypal = 0,
    cash = 0,
    refunded = 0,
    review = 0;
  for (const r of rows) {
    if (r.state === "review") {
      review += r.amountMinor;
      continue;
    }
    if (r.method === "cash") cash += r.amountMinor;
    else paypal += r.amountMinor;
    refunded += r.refundedMinor;
  }
  return { paypal, cash, refunded, review };
}

export const asRows = <T>(value: unknown): T[] =>
  Array.isArray((value as Json)?.rows) ? ((value as Json).rows as T[]) : [];
