"use client";
import { useMemo, useState } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import type { Json } from "@/lib/connected/contracts";
import { MotionRoot } from "@/lib/connected/motion";
import { SnackbarProvider } from "@/components/connected/m3";
import { AgentsSection, OrdersSection } from "@/components/connected/business-sections";

type Order = Json & { id: number; version: number; status: string };

declare global {
  interface Window {
    __boardCommands?: { name: string; data: Json; id?: number; version?: number }[];
  }
}

const minutes = (n: number) => new Date(Date.now() - n * 60000).toISOString();

function seed(): Order[] {
  const o = (id: number, number: number, status: string, fulfillment: string, origin: string, extra: Json = {}): Order => ({
    id,
    restaurantId: 5,
    number,
    status,
    fulfillment,
    origin,
    paymentStatus: "paid",
    version: 3,
    currency: "USD",
    totalMinor: 1350 + id * 40,
    createdAt: minutes(60 - id),
    visitId: null,
    customerLabel: origin === "counter" ? "Sam" : null,
    pickupCode: null,
    lines: [{ name: "Croque monsieur", quantity: 1 }, { name: "Cappuccino", quantity: 2 }],
    ...extra,
  });
  return [
    o(11, 11, "awaitingPayment", "pickup", "online", { paymentStatus: "unpaid" }),
    o(12, 12, "submitted", "pickup", "online"),
    o(13, 13, "accepted", "dineIn", "table", { visitId: 4 }),
    o(14, 14, "preparing", "pickup", "online"),
    o(15, 15, "ready", "pickup", "online", { pickupCode: "0271" }),
    o(16, 16, "ready", "delivery", "online"),
    o(17, 17, "collected", "pickup", "counter"),
    o(18, 18, "completed", "pickup", "online"),
  ];
}

function fakeApi(orders: Order[]): ConnectedApi {
  const record = (name: string, data: Json, id?: number, version?: number) => {
    window.__boardCommands ??= [];
    window.__boardCommands.push({ name, data, id, version });
  };
  const tickets = new Map<number, Json[]>([[14, [
    { id: 1, lineKey: "l0", quantity: 1, completedQuantity: 1, version: 2 },
    { id: 2, lineKey: "l1", quantity: 2, completedQuantity: 0, version: 4 },
  ]]]);
  const api = {
    async query<T>(name: string, params: Json = {}): Promise<T> {
      await new Promise((r) => setTimeout(r, 30));
      if (name === "orders") return { rows: orders.map((o) => ({ ...o })), nextCursor: null } as T;
      if (name === "order") {
        const o = orders.find((x) => x.id === Number(params.id));
        return { ...o, payments: [], timeline: [] } as T;
      }
      if (name === "kitchen") return { rows: orders.filter((o) => tickets.has(o.id)).map((o) => ({ id: o.id, tickets: tickets.get(o.id) })) } as T;
      if (name === "agent.inbox")
        return {
          rows: [
            {
              id: 70, taskId: 842, agent: "complaints", command: "payment.refund", title: "Refund $8.00 for the missing falafel wrap",
              rationale: "The diner reported that their falafel wrap was missing. The order contains it and PayPal shows the capture as completed.",
              risk: "money", status: "pending", version: 1, preview: {}, evidence: { paypalStatus: "COMPLETED", paypalSource: "paypal_mcp", amountMinor: 800, currency: "USD" },
              createdAt: minutes(12), expiresAt: minutes(-60),
            },
          ],
        } as T;
      if (name === "agent.activity") return { rows: [] } as T;
      throw new Error(`No fake for ${name}`);
    },
    async command<T>(name: string, _tenant: number, data: Json = {}, options: { id?: number; version?: number } = {}): Promise<T> {
      record(name, data, options.id, options.version);
      await new Promise((r) => setTimeout(r, 30));
      if (name === "kitchen.progress") return { version: Number(options.version) + 1 } as T;
      if (name === "order.transition") {
        const o = orders.find((x) => x.id === options.id)!;
        if (o.version !== options.version) throw new Error("The order changed. Reload and try again.");
        if (data.code && data.code !== o.pickupCode) throw new Error("The pickup code does not match.");
        o.status = String(data.status);
        o.version += 1;
        return { version: o.version, status: o.status } as T;
      }
      if (name === "agent.decide") return { state: "executed", result: { providerRefundId: "4RJ81234AB567890C" } } as T;
      throw new Error(`No fake for ${name}`);
    },
  };
  return api as unknown as ConnectedApi;
}

export function BoardPreview() {
  const [orders] = useState(seed);
  const api = useMemo(() => fakeApi(orders), [orders]);
  const [section, setSection] = useState<"orders" | "agents">("orders");
  return (
    <main className="ops-root" style={{ minHeight: "100vh", padding: 24, background: "var(--paper)" }}>
      <MotionRoot>
        <SnackbarProvider>
          <div className="ops-chips" role="group" aria-label="Preview section" style={{ marginBottom: 16 }}>
            <button aria-pressed={section === "orders"} onClick={() => setSection("orders")}>Orders</button>
            <button aria-pressed={section === "agents"} onClick={() => setSection("agents")}>Agents</button>
          </div>
          {section === "orders" ? (
            <OrdersSection api={api} tenant={5} revision="preview" currencyCode="USD" />
          ) : (
            <AgentsSection api={api} tenant={5} revision="preview" />
          )}
        </SnackbarProvider>
      </MotionRoot>
    </main>
  );
}
