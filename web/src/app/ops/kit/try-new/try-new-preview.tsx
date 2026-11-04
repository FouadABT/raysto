"use client";
/**
 * Development only: cards 10–14 on a fixture API in the shapes the 0.16
 * backend answers (accountant.dart, delivery.dart, purchasing.dart). Every id
 * here says PREVIEW: none of it is a PayPal result.
 */
import { useEffect, useMemo, useState } from "react";
import { ApiFailure, type ConnectedApi } from "@/lib/connected/api";
import type { Json } from "@/lib/connected/contracts";
import { MotionRoot } from "@/lib/connected/motion";
import { TryCardsNew } from "@/components/connected/try-section-new";

export function TryNewPreview() {
  const [state, setState] = useState<string>();
  useEffect(() => setState(new URLSearchParams(window.location.search).get("state") ?? "ok"), []);
  const api = useMemo(() => (state ? fixtureApi(state) : undefined), [state]);
  if (!api) return <main className="ops-root" />;
  return (
    <main className="ops-root">
      <MotionRoot>
        <div className="ops-try">
          <div className="ops-try-grid">
            <TryCardsNew api={api} tenant={1} />
          </div>
        </div>
      </MotionRoot>
    </main>
  );
}

const now = () => new Date().toISOString();

function fixtureApi(state: string): ConnectedApi {
  const missing = state === "missing";
  let billPaid = false;
  let requestReads = 0;
  const bill = () => ({
    id: 41,
    version: billPaid ? 4 : 2,
    vendor: "Hudson Power & Light · Sample",
    category: "electricity",
    reference: "HPL-2026-11-0417",
    amountMinor: 19086,
    vatMinor: 1414,
    currency: "USD",
    dueAt: "2026-11-24T05:00:00.000Z",
    state: billPaid ? "paid" : "review",
    payVia: "paypal",
    payeeEmail: "buyer-one@personal.example.com",
    recurring: "monthly",
    sourceMediaId: 12,
    taskId: 101,
    providerBatchId: billPaid ? "PREVIEWBATCH01" : null,
    read: { from: "agent", confidence: 0.94 },
  });
  const action = (id: number, taskId: number, agent: string, command: string, risk: string, title: string, rationale: string, preview: Json) => ({
    id,
    taskId,
    agent,
    command,
    title,
    rationale,
    risk,
    status: "pending",
    version: 1,
    preview,
    evidence: {},
    createdAt: now(),
    expiresAt: now(),
  });
  const tasks: Record<number, Json> = {
    101: {
      id: 101,
      agent: "accountant",
      status: "done",
      summary: "Read the Hudson Power & Light bill for October: $190.86 due 24 November.",
      chargedMicros: 1800,
      trace: [{ tool: "read_bills" }],
      actions: [
        action(501, 101, "accountant", "bill.pay", "money", "Pay Hudson Power & Light · Sample $190.86", "Monthly bill, same vendor and payee as last month, 8% higher.", {
          billId: 41,
          amountMinor: 19086,
          currency: "USD",
        }),
      ],
    },
    102: {
      id: 102,
      agent: "accountant",
      status: "done",
      summary: "A good month: sales cover every bill. One capture has no order yet; check it before the close.",
      chargedMicros: 2100,
      trace: [{ tool: "pnl" }, { tool: "find_anomalies" }],
      actions: [],
    },
    103: {
      id: 103,
      agent: "dispatch",
      status: "done",
      summary: "Sam is closest with no job on hand.",
      chargedMicros: 900,
      trace: [{ tool: "rank_drivers" }],
      actions: [
        action(503, 103, "dispatch", "delivery.offer", "ops", "Offer order #A12 to Sam · Sample", "Closest available driver, no job on hand.", {
          order: "#A12",
          driver: "Sam · Sample",
          vehicle: "bike",
          rideMinutes: 9,
          estimate: true,
        }),
      ],
    },
    104: {
      id: 104,
      agent: "supplies",
      status: "done",
      summary: "Espresso beans run out before Dupont's next delivery; butter is below its low mark.",
      chargedMicros: 2400,
      trace: [{ tool: "forecast" }],
      actions: [
        action(504, 104, "supplies", "supplier.order.propose", "ops", "Order from Marché Dupont", "Two items run out before the next delivery.", {
          supplier: "Marché Dupont",
          lines: [
            { name: "Espresso beans", unit: "kg", qty: 4.5, unitCostMinor: 2200 },
            { name: "Butter AOP", unit: "kg", qty: 6.5, unitCostMinor: 980 },
          ],
          totalMinor: 16270,
          currency: "USD",
        }),
      ],
    },
  };
  const queries: Record<string, (p: Json) => unknown> = {
    media: () => ({ rows: [{ id: 12, purpose: "bill", status: "approved" }] }),
    "agent.task": (p) => tasks[Number(p.id)] ?? { id: p.id, status: "done", actions: [] },
    bills: () => ({
      rows: [bill(), { id: 44, vendor: "Marché Dupont · Sample", category: "supplier", state: "review", amountMinor: 14300, supplierOrderId: 7, currency: "USD" }],
    }),
    bill: () => bill(),
    "ledger.pnl": () => ({
      currency: "USD",
      revenue: [{ account: "4000", name: "Sales", amountMinor: 128450 }],
      costs: [
        { account: "6000", name: "PayPal fees", amountMinor: 4870 },
        { account: "6100", name: "Utilities", amountMinor: 17680 },
        { account: "6110", name: "Rent", amountMinor: 180000 },
      ],
      revenueMinor: 128450,
      costsMinor: 202550,
      netMinor: -74100,
      feesEstimated: true,
    }),
    "ledger.vat": () => ({ collectedMinor: 0, paidMinor: 1310, dueMinor: -1310, taxConfigured: true }),
    "accountant.anomalies": () => ({
      rows: [{ title: "A capture with no order", detail: "PayPal captured $12.40 with no Raysto order.", providerCaptureId: "PREVIEWCAPTURE1" }],
    }),
    request: () => ({
      id: 5,
      version: 1,
      kind: "link",
      payerName: "Studio Lumen · Sample",
      description: "Catering deposit · Friday lunch for 12 (sample, PayPal Sandbox)",
      amountMinor: 3555,
      currency: "USD",
      payUrl: "https://api.rays.to/pay/preview-token",
      // Made (1), first read (2), paid from the second read on (3).
      ...(++requestReads >= 3 ? { state: "paid", providerCaptureId: "PREVIEWCAPTURE2" } : { state: "open" }),
    }),
    "delivery.board": () => ({
      rows: [
        {
          id: 9,
          orderId: 300,
          number: "A12",
          status: "unassigned",
          fulfilledBy: "restaurant",
          partner: { id: 1, name: "Demo Delivery Co. (simulator)", simulator: true },
          partnerRef: "sim-42",
          totalMinor: 2450,
          currency: "USD",
          address: { line: "Sample drop-off, 5 Harbour Street" },
        },
      ],
      venue: { latitude: 40.7424, longitude: -74.006 },
    }),
    "partner.events": () => ({
      rows: [
        { id: 1, direction: "in", type: "orders.create", status: "accepted", ref: "sim-42", responseCode: 201, createdAt: "2026-11-08T10:00:01Z" },
        { id: 2, direction: "out", type: "order.accepted", status: "delivered", ref: "sim-42", responseCode: 200, createdAt: "2026-11-08T10:00:03Z" },
      ],
    }),
    "stock.forecast": () => ({
      basis: "recipes",
      rows: [
        { stockItemId: 1, name: "Flour T55", unit: "kg", quantity: 12, dailyUsage: 1.1, daysCover: 10.9, reorder: false },
        { stockItemId: 2, name: "Espresso beans", unit: "kg", quantity: 2, dailyUsage: 0.9, daysCover: 2.2, stockOutAt: "2026-11-10T12:00:00Z", reorder: true, suggestedQty: 4.5, low: true },
        { stockItemId: 3, name: "Butter AOP", unit: "kg", quantity: 3.5, dailyUsage: 0.6, daysCover: 5.8, reorder: true, suggestedQty: 6.5, low: true },
      ],
    }),
    "supplier.orders": () => ({
      rows: [
        {
          id: 7,
          state: "received",
          supplierName: "Marché Dupont",
          note: "Sample: received with a butter price change",
          currency: "USD",
          lines: [
            { name: "Button mushrooms", unit: "kg", qty: 6, unitCostMinor: 650, receivedQty: 6, receivedUnitCostMinor: 650 },
            { name: "Butter AOP", unit: "kg", qty: 10, unitCostMinor: 980, receivedQty: 10, receivedUnitCostMinor: 1040 },
          ],
        },
      ],
    }),
  };
  const commands: Record<string, (d: Json) => unknown> = {
    "bill.snap": () => ({ mediaId: 12, taskId: 101, duplicateOfId: null }),
    "accountant.run": () => ({ taskId: 102 }),
    "request.create": () => queries.request({}),
    "dispatch.suggest": () => ({
      assignmentId: 9,
      taskId: 103,
      basis: "Ranked by distance and jobs on hand. Distances are straight lines × 1.3 and times are estimates.",
      ranking: [
        { driverId: 2, name: "Sam · Sample", vehicle: "bike", score: 88, minutes: 6, activeJobs: 0, reasons: ["At the café (no live position)", "No job on hand"] },
        { driverId: 3, name: "Ines · Sample", vehicle: "scooter", score: 84, minutes: 8, activeJobs: 0, reasons: ["At the café (no live position)", "No job on hand"] },
      ],
    }),
    "supplies.plan": () => ({ taskId: 104 }),
    "agent.decide": () => {
      billPaid = true;
      return { state: "executed", result: {} };
    },
  };
  const unknown = (name: string) => new ApiFailure("not_found", `Unknown operation: ${name}`);
  const api = {
    async query<T>(name: string, params: Json = {}) {
      await new Promise((r) => setTimeout(r, 80));
      if (missing && name !== "media" && name !== "agent.task") throw unknown(name);
      const handler = queries[name];
      if (!handler) throw unknown(name);
      return handler(params) as T;
    },
    async command<T>(name: string, _restaurantId: number, data: Json = {}) {
      await new Promise((r) => setTimeout(r, 80));
      const handler = commands[name];
      if (missing || !handler) throw unknown(name);
      return handler(data) as T;
    },
    async typed(): Promise<never> {
      throw new ApiFailure("preview", "The preview does not send commands.");
    },
    async listen(): Promise<never> {
      throw new ApiFailure("preview", "The preview does not listen.");
    },
    async file(): Promise<Blob> {
      throw new ApiFailure("not_found", "The preview has no files.");
    },
    async request(): Promise<never> {
      throw new ApiFailure("preview", "The preview has no backend.");
    },
    close() {},
  };
  return api as unknown as ConnectedApi;
}
