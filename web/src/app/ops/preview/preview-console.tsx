"use client";

import { useEffect, useMemo, useState } from "react";
import { ApiFailure, type ConnectedApi } from "@/lib/connected/api";
import type { Json } from "@/lib/connected/contracts";
import type { Dashboard } from "@/lib/connected/dashboard";
import { ConsoleShell } from "@/components/connected/operations-entry";
import { OperationsWorkspace } from "@/components/connected/operations-workspace";
// S3 (supplies) preview fixtures: append-only.
import { suppliesPreview } from "@/lib/connected/supplies-preview";
// S4 (group) preview fixtures: append-only.
import { groupPreview, groupPreviewShell } from "@/lib/connected/group-preview";
// S1 (accountant) preview fixtures: append-only.
import { accountantPreview } from "@/lib/connected/accountant-preview";
// S2 (dispatch) preview fixtures: append-only.
import { dispatchPreview } from "@/lib/connected/dispatch-preview";
// S6: the PayPal account, `?state=paypal` for a café on its own app.
import { paypalAccountPreview } from "@/lib/connected/paypal-account";

/**
 * Development only: the real console shell and workspace on a fixture API,
 * so the browser tests run without a backend or a sign-in. Nothing here can
 * send a command. `?state=failed` makes the dashboard query fail, and
 * `?state=empty` returns a café with no paid order yet.
 */
export function PreviewConsole({ week, today }: { week: Dashboard; today: Dashboard }) {
  const [ready, setReady] = useState(false);
  const [state, setState] = useState("");
  useEffect(() => {
    setState(new URLSearchParams(window.location.search).get("state") ?? "");
    setReady(true);
  }, []);
  const api = useMemo(() => fixtureApi({ week, today, state }), [week, today, state]);
  if (!ready) return <main className="ops-root" />;
  return (
    <ConsoleShell
      api={api}
      memberships={[{ restaurantId: 1, name: "Atelier Café · Preview", role: "owner" } as never]}
      selected={1}
      onSelect={() => {}}
      onSignOut={() => {}}
      person={{ name: "Fouad Preview", email: "preview@example.com" }}
      workspace={OperationsWorkspace}
      // S4: `?state=group` adds a second venue and a group (append-only).
      {...groupPreviewShell(state)}
    />
  );
}

function month(week: Dashboard): Dashboard {
  const start = new Date(week.points[week.points.length - 1].start).getTime() - 29 * 86400000;
  const points = Array.from({ length: 30 }, (_, i) => {
    const p = week.points[i % week.points.length];
    const at = new Date(start + i * 86400000);
    return { ...p, start: at.toISOString(), label: at.toLocaleDateString("en-GB", { day: "numeric", month: "short", timeZone: "UTC" }) };
  });
  const series = (key: "salesMinor" | "orders") => points.map((p) => p[key]);
  const sales = series("salesMinor"),
    orders = series("orders");
  const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0);
  return {
    ...week,
    range: "30d",
    points,
    kpis: {
      sales: { value: sum(sales), previous: Math.round(sum(sales) * 0.8), series: sales },
      orders: { value: sum(orders), previous: Math.round(sum(orders) * 0.8), series: orders },
      averageTicket: {
        value: Math.round(sum(sales) / Math.max(1, sum(orders))),
        previous: week.kpis.averageTicket.previous,
        series: points.map((p) => (p.orders ? Math.round(p.salesMinor / p.orders) : 0)),
      },
      tips: { value: week.kpis.tips.value * 4, previous: week.kpis.tips.previous, series: points.map((_, i) => week.kpis.tips.series[i % 7]) },
    },
    sample: week.sample
      ? { label: week.sample.label, points: points.map((p, i) => ({ ...week.sample!.points[i % 7], start: p.start, label: p.label })) }
      : null,
  };
}

function emptied(d: Dashboard): Dashboard {
  const zero = { value: 0, previous: 0, series: d.points.map(() => 0) };
  return {
    ...d,
    points: d.points.map((p) => ({ ...p, salesMinor: 0, orders: 0 })),
    kpis: { sales: zero, orders: zero, averageTicket: zero, tips: zero },
    channels: [],
    kitchen: { submitted: 0, accepted: 0, preparing: 0, ready: 0, oldestMinutes: 0 },
    latest: [],
    staff: [],
    target: { dailyTargetMinor: 0, todayMinor: 0 },
    sample: null,
  };
}

function fixtureApi({ week, today, state }: { week: Dashboard; today: Dashboard; state: string }): ConnectedApi {
  const asOf = new Date().toISOString();
  const orders = week.latest.map((o) => ({ ...o, restaurantId: 1, version: 1, visitId: null, pickupCode: null, address: null, lines: [] }));
  const queries: Record<string, (p: Json) => unknown> = {
    "operations.snapshot": (p) => ({
      restaurantId: 1,
      name: "Atelier Café · Preview",
      currency: "USD",
      filter: p.filter ?? "all",
      rows: [],
      floor: null,
      eventCursor: 1,
      asOf,
      layout: null,
      layoutVersion: 0,
      outstandingMinor: 0,
    }),
    orders: () => ({ rows: orders, nextCursor: null }),
    checkouts: () => ({ rows: [] }),
    "operations.threads": () => ({ runs: [] }),
    "agent.inbox": () => ({
      rows:
        state === "empty"
          ? []
          : [{ id: 1, taskId: 1, agent: "payroll", command: "payout.send", title: "Pay this week's tips", rationale: "Preview", risk: "money", status: "pending", version: 1 }],
    }),
    // `?state=payouts`: a list row in the shape the 0.15.0 backend sent (no
    // `items`), next to a completed batch, with someone held for a missing email.
    payouts: () =>
      state !== "payouts"
        ? { rows: [] }
        : {
            rows: [
              {
                id: 2,
                kind: "wages",
                periodFrom: asOf,
                periodTo: asOf,
                totalMinor: 28800,
                currency: "USD",
                state: "proposed",
                createdAt: asOf,
                summary: { held: [{ recipientName: "Lina", amountMinor: 35200, minutes: 960, reason: "No PayPal email: add one to pay." }] },
              },
              {
                id: 1,
                kind: "wages",
                periodFrom: asOf,
                periodTo: asOf,
                totalMinor: 25600,
                currency: "USD",
                state: "completed",
                providerBatchId: "TMS8FKRT6ALYU",
                createdAt: asOf,
                items: [{ recipientName: "Nadia", amountMinor: 25600, state: "completed" }],
              },
            ],
            nextCursor: null,
          },
    shifts: () =>
      state !== "payouts"
        ? { rows: [] }
        : {
            rows: ["Omar", "Lina", "Nadia"].map((name, i) => ({
              id: i + 1,
              version: 1,
              name,
              role: i === 0 ? "kitchen" : "floor",
              startsAt: new Date(Date.now() - (i + 2) * 3600000).toISOString(),
              endsAt: new Date(Date.now() - (i + 1) * 3600000).toISOString(),
              hourlyRateMinor: 1800,
              payoutEmail: name === "Lina" ? null : `${name.toLowerCase()}@example.com`,
            })),
          },
    dashboard: (p) => {
      if (state === "failed") throw new ApiFailure("not_found", "Unknown query: dashboard (the backend does not serve it yet).");
      const d = p.range === "today" ? today : p.range === "30d" ? month(week) : week;
      return state === "empty" ? emptied(d) : d;
    },
    // ---- S3 supplies fixtures (append-only block) ----
    ...suppliesPreview(asOf),
    // ---- end S3 ----
    // ---- S4 group fixtures, `?state=group` (append-only block) ----
    ...groupPreview(state, asOf),
    // ---- end S4 ----
    // ---- S1 accountant fixtures (append-only block) ----
    ...accountantPreview(asOf),
    // ---- end S1 ----
    // ---- S2 dispatch fixtures (append-only block) ----
    ...dispatchPreview(asOf),
    // ---- end S2 ----
    // ---- S6 PayPal account fixtures (append-only block) ----
    ...paypalAccountPreview(state),
    // ---- end S6 ----
  };
  const api = {
    async query<T>(name: string, params: Json = {}) {
      await new Promise((r) => setTimeout(r, 120));
      const handler = queries[name];
      return (handler ? handler(params) : { rows: [] }) as T;
    },
    async command(): Promise<never> {
      throw new ApiFailure("preview", "The preview does not send commands.");
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
    async stream(_path: string, signal: AbortSignal, receive: (e: Json) => void) {
      receive({ cursor: 1, kind: "heartbeat" });
      await new Promise<void>((resolve) => signal.addEventListener("abort", () => resolve(), { once: true }));
    },
    close() {},
  };
  return api as unknown as ConnectedApi;
}
