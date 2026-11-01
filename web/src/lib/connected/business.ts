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

/** Who an order is for: the name given at the counter, the table visit, or the app account. */
export const customerOf = (o: Pick<OrderRow, "customerLabel" | "visitId" | "origin">) =>
  o.customerLabel ?? (o.visitId ? `Visit ${o.visitId}` : o.origin === "counter" ? "Walk-in" : "App customer");

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

/** An AI coworker's suggestion waiting in the inbox. */
export interface AgentActionRow {
  id: number;
  taskId: number;
  agent: string;
  command: string;
  title: string;
  rationale: string;
  risk: "catalogue" | "ops" | "money";
  status: string;
  version: number;
  preview: Json;
  evidence: Json;
  createdAt: string;
  expiresAt: string;
  task?: AgentTaskRow;
}

export interface AgentTaskRow {
  id: number;
  agent: string;
  trigger: string;
  status: string;
  title: string;
  summary: string | null;
  chargedMicros: number;
  createdAt: string;
  completedAt: string | null;
  state: Json;
}

const agentNames: Record<string, string> = {
  payments: "Payments agent",
  menu: "Menu agent",
  images: "Image studio",
  orders: "Order agent",
  counter: "Counter voice",
  catering: "Catering agent",
  copilot: "Copilot",
  translator: "Translator",
  marketing: "Marketing studio",
  reviews: "Review replies",
};
export const agentName = (agent: string) => agentNames[agent] ?? agent;

/** USD millionths, as the AI budget records them. */
export const agentCost = (micros: number) => `$${(micros / 1_000_000).toFixed(3)}`;

/** The facts behind a suggestion as short labels, never the model's words. */
export function evidenceChips(evidence: Json, preview: Json, format: (minor: number, code: string) => string): string[] {
  const chips: string[] = [];
  if (evidence.paypalStatus) chips.push(`PayPal: ${evidence.paypalStatus}`);
  if (evidence.paypalSource === "paypal_mcp") chips.push("Checked through PayPal MCP");
  else if (evidence.paypalSource === "paypal_rest") chips.push("Checked through PayPal REST");
  if (typeof evidence.amountMinor === "number") chips.push(format(evidence.amountMinor, String(evidence.currency ?? "")));
  if (evidence.ledgerState) chips.push(`Raysto: ${evidence.ledgerState}`);
  if (typeof evidence.queue === "number") chips.push(`Orders open: ${evidence.queue}`);
  if (typeof evidence.oldestOpenMinutes === "number") chips.push(`Oldest order: ${evidence.oldestOpenMinutes} min`);
  if (preview.item) chips.push(`${preview.item}: sold out`);
  const labels: Record<string, string> = { paused: "Online orders", preparationMinutes: "Prep time", slotCapacity: "Orders per slot" };
  for (const [key, value] of Object.entries(preview)) {
    if (!value || typeof value !== "object" || !("to" in (value as Json))) continue;
    const v = value as Json;
    const show = (x: unknown) => (key === "paused" ? (x ? "paused" : "open") : key === "preparationMinutes" ? `${x} min` : String(x));
    chips.push(`${labels[key] ?? key}: ${show(v.from)} → ${show(v.to)}`);
  }
  return chips;
}
