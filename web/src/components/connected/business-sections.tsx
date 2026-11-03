"use client";
import { useCallback, useEffect, useMemo, useState } from "react";
import { AgGridReact } from "ag-grid-react";
import type { ColDef } from "ag-grid-community";
import { ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { m3GridTheme } from "@/lib/connected/grid-theme";
import { advanceOrder, type OrderApi } from "@/lib/connected/pending-moves";
import { ContainerCard, ContainerDialog, CountUp, Reveal, useSnackbar, type SnackbarOptions } from "./m3";
import { OrdersBoard, PickupCodeDialog, type BoardOrder } from "./orders-board";
import { Icon, type IconName } from "./icons";
import {
  agentCost,
  agentName,
  asRows,
  evidenceChips,
  channelMix,
  channelOf,
  customerOf,
  collectionTotals,
  dayRange,
  isPaid,
  nextStep,
  statusGroup,
  unresolved,
  type Channel,
  type CheckoutRow,
  type CollectionRow,
  type OrderRow,
  type RefundRow,
  type StatusGroup,
  type Summary,
  type AgentActionRow,
  type AgentTaskRow,
} from "@/lib/connected/business";

export type Section = "overview" | "orders" | "payments" | "agents" | "money" | "team";

/** The console's one grid theme, on the Material tokens (grid-theme.ts). */
export const gridTheme = m3GridTheme;

/** Snackbars come from the console's SnackbarProvider; without one a message is simply not shown. */
function useOptionalSnackbar(): { show: (o: SnackbarOptions) => number } | null {
  try {
    return useSnackbar();
  } catch {
    return null;
  }
}
/** Status words read as small colored pills, so state is seen, not read. */
const tones: Record<string, string> = {
  submitted: "new", new: "new", awaitingpayment: "new", created: "new", pending: "new", reserved: "new", queued: "new", review: "warn",
  requested: "new", proposed: "new", drafted: "new", open: "new", planned: "new",
  accepted: "cook", preparing: "cook", approved: "cook", capturing: "cook", running: "cook", quoted: "cook", sent: "cook", onshift: "cook",
  ready: "ready", outfordelivery: "ready",
  paid: "ok", completed: "ok", collected: "ok", done: "ok", executed: "ok", captured: "ok", applied: "ok", signed: "ok", success: "ok", resolved: "ok",
  partiallyrefunded: "warn", refunded: "warn", uncertain: "late", failed: "late", unpaid: "late", missed: "late", overdue: "late",
  cancelled: "off", rejected: "off", expired: "off", released: "off", voided: "off", declined: "off",
};
export const pill = (p: { value?: unknown; valueFormatted?: string | null }) =>
  p.value == null || p.value === "" ? null : (
    <span className={`ops-pill ${tones[String(p.value).toLowerCase().replaceAll("_", "")] ?? "neutral"}`}>
      {p.valueFormatted ?? words(p.value)}
    </span>
  );
export const time = (iso: unknown) =>
  iso ? new Date(String(iso)).toLocaleString([], { dateStyle: "short", timeStyle: "short" }) : "";
export const words = (v: unknown) => {
  const s = String(v ?? "").replace(/([a-z])([A-Z])/g, "$1 $2").replaceAll("_", " ");
  return s.charAt(0).toUpperCase() + s.slice(1);
};
export const money =
  (fallback: string) =>
  (p: { value?: unknown; data?: unknown }): string =>
    currency(
      Number(p.value ?? 0),
      String((p.data as { currency?: string } | undefined)?.currency ?? fallback),
    );
export const defaults: ColDef = { sortable: true, filter: true, resizable: true, flex: 1, minWidth: 110 };

export function useLoad<T>(load: () => Promise<T>, deps: unknown[]) {
  const [data, setData] = useState<T>();
  const [error, setError] = useState("");
  const run = useCallback(() => {
    let live = true;
    load()
      .then((d) => live && (setData(d), setError("")))
      .catch((e) => live && setError(String(e instanceof Error ? e.message : e)));
    return () => {
      live = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
  useEffect(run, [run]);
  return { data, error, reload: run };
}

export function BusinessOverview({
  api,
  tenant,
  revision,
  currencyCode,
  openRequests,
  open,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
  openRequests: number;
  open: (section: Section | "floor", focus?: string) => void;
}) {
  const { data, error } = useLoad(async () => {
    const today = dayRange(new Date());
    const [summary, channels, collections, checkouts, orders, inbox] = await Promise.all([
      api.query<Summary>("report", { restaurantId: tenant, report: "summary", ...today }),
      api.query<{ channels: Record<string, { orders: number; salesMinor: number }> }>(
        "report",
        { restaurantId: tenant, report: "channels", ...today },
      ),
      api.query<Json>("report", { restaurantId: tenant, report: "collections", limit: 100, ...today }),
      api.query<Json>("checkouts", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }),
      api.query<Json>("orders", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }),
      // Agents may be switched off on a deployment; the overview still loads.
      api.query<Json>("agent.inbox", { restaurantId: tenant }).catch(() => ({ rows: [] })),
    ]);
    return {
      summary,
      waiting: asRows<AgentActionRow>(inbox),
      mix: channelMix(channels.channels ?? {}),
      totals: collectionTotals(asRows<CollectionRow>(collections)),
      attention: unresolved(asRows<CheckoutRow>(checkouts), new Date()).length,
      // The kitchen sees an order once it is paid or accepted; one still
      // waiting for its payment is not in the kitchen.
      active: asRows<OrderRow>(orders).filter(
        (o) => ["submitted", "accepted", "preparing", "ready"].includes(o.status),
      ),
    };
  }, [api, tenant, revision]);
  const code = data?.summary.currency ?? currencyCode;
  if (!data)
    return error ? (
      <p className="ops-error" role="alert">{error}</p>
    ) : (
      <div className="ops-skeleton" role="status" aria-label="Gathering today's figures">
        <span className="hero" />
        <span />
        <span />
        <span />
        <span />
      </div>
    );
  const { summary, mix, totals, attention, active, waiting } = data;
  const go = (to: [Section | "floor", string?]) => open(to[0], to[1]);
  const resolve = attention + (totals.review ? 1 : 0);
  const aboutMoney = waiting.filter((a) => a.risk === "money").length;
  const stats: [string, number, string, [Section | "floor", string?]][] = [
    ["PayPal collected", totals.paypal, "Captured by PayPal today", ["payments", "captures"]],
    ["Cash collected", totals.cash, "Recorded at the counter or table", ["payments", "cash"]],
    ["Refunded", summary.refundsMinor, "Completed refunds today", ["payments", "refunds"]],
  ];
  // Calm when nothing waits; warm or hot only when someone should look.
  const needs: { label: string; value: number; note: string; icon: IconName; tone: string; to: [Section | "floor", string?] }[] = [
    {
      label: "PayPal to resolve",
      value: resolve,
      note: totals.review ? `${currency(totals.review, code)} under review` : resolve ? "Unfinished or uncertain attempts" : "Every attempt is settled",
      icon: "paypal",
      tone: resolve ? "hot" : "calm",
      to: ["payments", "attempts"],
    },
    {
      label: "Agents need you",
      value: waiting.length,
      note: waiting.length ? `${aboutMoney} about money` : "AI coworkers are up to date",
      icon: "agents",
      tone: waiting.length ? (aboutMoney ? "hot" : "warm") : "calm",
      to: ["agents"],
    },
    {
      label: "Service requests",
      value: openRequests,
      note: openRequests ? "Open at the tables" : "No table is waiting",
      icon: "bell",
      tone: openRequests ? "warm" : "calm",
      to: ["floor"],
    },
    {
      label: "In the kitchen",
      value: active.length,
      note: "Paid and waiting, preparing or ready",
      icon: "kitchen",
      tone: active.length ? "busy" : "calm",
      to: ["orders", "active"],
    },
  ];
  const total = mix.reduce((n, x) => n + x.salesMinor, 0) || 1;
  return (
    <div className="ops-business">
      {error && <p className="ops-error" role="alert">{error}</p>}
      <section className="ops-hero" aria-label="Today">
        <button className="ops-hero-main" onClick={() => go(["orders"])}>
          <span className="ops-hero-label">Booked sales today</span>
          <strong>{currency(summary.bookedSalesMinor, code)}</strong>
          <span className="ops-hero-sub">
            {summary.ordersCreated} {summary.ordersCreated === 1 ? "order" : "orders"} today · {summary.completedOrders} completed
          </span>
        </button>
        <div className="ops-hero-split">
          {stats.map(([label, value, note, to]) => (
            <button key={label} className="ops-hero-stat" onClick={() => go(to)}>
              <span>{label}</span>
              <strong>{currency(value, code)}</strong>
              <small>{note}</small>
            </button>
          ))}
        </div>
      </section>
      <section aria-labelledby="ops-needs">
        <h2 id="ops-needs" className="ops-section-title">Needs you</h2>
        <div className="ops-attention">
          {needs.map((n) => (
            <button key={n.label} className={`ops-tile ${n.tone}`} onClick={() => go(n.to)}>
              <span className="ops-tile-icon">
                <Icon name={n.tone === "calm" ? "check" : n.icon} size={20} />
              </span>
              <span className="ops-tile-label">{n.label}</span>
              <strong>{n.value}</strong>
              <small>{n.note}</small>
              <Icon className="ops-tile-go" name="arrow" size={18} />
            </button>
          ))}
        </div>
      </section>
      <section className="ops-panel">
        <h2>Today by channel</h2>
        {mix.length === 0 ? (
          <p className="ops-quiet-note">
            {summary.ordersCreated > 0
              ? `${summary.ordersCreated} ${summary.ordersCreated === 1 ? "order was" : "orders were"} placed today and none is paid yet. Channels count paid orders.`
              : "No orders yet today. Channels appear here as paid orders come in."}
          </p>
        ) : (
          <table className="ops-mix">
            <thead>
              <tr><th>Channel</th><th>Orders</th><th>Sales</th><th>Share</th></tr>
            </thead>
            <tbody>
              {mix.map((m) => (
                <tr key={m.channel}>
                  <td>{m.channel}</td>
                  <td>{m.orders}</td>
                  <td>{currency(m.salesMinor, code)}</td>
                  <td>
                    <span className="ops-share">
                      <span className="ops-bar" style={{ width: `${Math.round((m.salesMinor / total) * 100)}%` }} />
                    </span>{" "}
                    {Math.round((m.salesMinor / total) * 100)}%
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}

export function OrdersSection({
  api,
  tenant,
  revision,
  focus,
  currencyCode,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  focus?: string;
  currencyCode: string;
}) {
  const [rows, setRows] = useState<BoardOrder[]>([]);
  // Until the first page arrives the grid shows loading, not "no rows".
  const [loaded, setLoaded] = useState(false);
  const [cursor, setCursor] = useState<number | null>(null);
  const [channel, setChannel] = useState<Channel | "All">("All");
  const [group, setGroup] = useState<StatusGroup | "Active" | "All">(focus === "active" ? "Active" : "All");
  const [selected, setSelected] = useState<number>();
  const [error, setError] = useState("");
  const [view, setView] = useState<"board" | "list">(readView);
  const choose = (v: "board" | "list") => {
    setView(v);
    try {
      localStorage.setItem(VIEW_KEY, v);
    } catch {
      /* Private mode: the choice lasts for this visit. */
    }
  };
  const load = useCallback(
    async (more = false) => {
      try {
        const page = await api.query<{ rows: BoardOrder[]; nextCursor: number | null }>("orders", {
          restaurantId: tenant,
          staff: true,
          order: "desc",
          limit: 100,
          ...(more && cursor ? { cursor } : {}),
        });
        setRows((old) => (more ? [...old, ...page.rows] : page.rows));
        setCursor(page.nextCursor);
        setLoaded(true);
        setError("");
      } catch (e) {
        setError(String(e instanceof Error ? e.message : e));
      }
    },
    [api, tenant, cursor],
  );
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => void load(), [api, tenant, revision]);
  const byChannel = rows.filter((o) => channel === "All" || channelOf(o) === channel);
  const shown = byChannel.filter(
    (o) =>
      group === "All" ||
      (group === "Active" ? statusGroup(o.status) !== "Done" : statusGroup(o.status) === group),
  );
  const columns = useMemo<ColDef<OrderRow>[]>(
    () => [
      { headerName: "Ticket", valueGetter: (p) => (p.data?.number ? `#${p.data.number}` : `Order ${p.data?.id}`), minWidth: 100, flex: 0.7, cellClass: "ops-cell-strong" },
      { headerName: "Channel", valueGetter: (p) => (p.data ? channelOf(p.data) : "") },
      { field: "status", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 185 },
      { field: "paymentStatus", headerName: "Payment", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 180 },
      { field: "totalMinor", headerName: "Total", type: "rightAligned", valueFormatter: money(currencyCode) },
      { headerName: "Customer", minWidth: 140, valueGetter: (p) => (p.data ? customerOf(p.data) : "") },
      { field: "createdAt", headerName: "Placed", minWidth: 160, valueFormatter: (p) => time(p.value), sort: "desc" },
    ],
    [currencyCode],
  );
  const toolbar = (
    <div className="m3-orders-bar">
      <div className="m3-segmented" role="group" aria-label="Orders view">
        <button type="button" aria-pressed={view === "board"} onClick={() => choose("board")}>
          Board
        </button>
        <button type="button" aria-pressed={view === "list"} onClick={() => choose("list")}>
          List
        </button>
      </div>
      <div className="ops-chips" role="group" aria-label="Channel">
        {(["All", "Counter", "Pickup", "Dine-in", "Delivery"] as const).map((c) => (
          <button key={c} aria-pressed={channel === c} onClick={() => setChannel(c)}>{c}</button>
        ))}
      </div>
    </div>
  );
  if (view === "board")
    return (
      <div className="ops-business">
        {toolbar}
        {error && <p className="ops-error" role="alert">{error}</p>}
        {!loaded && !error ? (
          <p className="ops-note" role="status">Loading the orders…</p>
        ) : (
          <OrdersBoard api={api} tenant={tenant} rows={byChannel} revision={revision} reload={() => void load()} />
        )}
        <div className="ops-row">
          <small>
            Drag a card to the next column, or use its button; a move waits five seconds for Undo. The newest {rows.length} orders are
            loaded.
          </small>
          {cursor && <button onClick={() => void load(true)}>Load older orders</button>}
        </div>
      </div>
    );
  // The list takes the full width until an order is chosen.
  return (
    <div className={`ops-business${selected ? " with-panel" : ""}`}>
      <div>
        {toolbar}
        <div className="ops-chips" role="group" aria-label="Status">
          {(["All", "Active", "New", "Preparing", "Ready", "Done"] as const).map((g) => (
            <button key={g} aria-pressed={group === g} onClick={() => setGroup(g)}>{g}</button>
          ))}
        </div>
        {error && <p className="ops-error" role="alert">{error}</p>}
        <div className="ops-grid tall">
          <AgGridReact<OrderRow>
            theme={gridTheme}
            rowData={shown}
            loading={!loaded && !error}
            columnDefs={columns}
            defaultColDef={defaults}
            getRowId={(p) => String(p.data.id)}
            onRowClicked={(e) => e.data && setSelected(e.data.id)}
            rowSelection={{ mode: "singleRow", checkboxes: false, enableClickSelection: true }}
          />
        </div>
        <div className="ops-row">
          <small>
            {shown.length} of {rows.length} loaded, newest first.
            {!selected && " Select an order to see its lines, its PayPal payments and its next step."}
          </small>
          {cursor && <button onClick={() => void load(true)}>Load older orders</button>}
        </div>
      </div>
      {selected && (
        <aside className="ops-side">
          <OrderPanel key={selected} api={api} tenant={tenant} id={selected} revision={revision} onChanged={() => void load()} />
        </aside>
      )}
    </div>
  );
}

const VIEW_KEY = "raysto.ordersView";
function readView(): "board" | "list" {
  try {
    return globalThis.localStorage?.getItem(VIEW_KEY) === "list" ? "list" : "board";
  } catch {
    return "board";
  }
}

export function OrderPanel({
  api,
  tenant,
  id,
  revision,
  onChanged,
}: {
  api: OrderApi;
  tenant: number;
  id: number;
  revision: string;
  onChanged: () => void;
}) {
  const { data: order, error, reload } = useLoad(
    () => api.query<OrderRow & Json>("order", { restaurantId: tenant, id, staff: true }),
    [api, tenant, id, revision],
  );
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const [asking, setAsking] = useState(false);
  if (!order) return <p className="ops-note">{error || "Loading the order…"}</p>;
  const step = nextStep(order);
  // The same path as a move on the board: ticks open lines before ready,
  // then the transition with the version this panel holds.
  async function advance(code?: string) {
    if (!order || !step) return;
    setBusy(true);
    setNote("");
    try {
      await advanceOrder(api, tenant, order, step, code);
      reload();
      onChanged();
    } catch (e) {
      setNote(String(e instanceof Error ? e.message : e));
    } finally {
      setBusy(false);
    }
  }
  const needsCode = step === "collected" && order.origin !== "counter" && !!order.pickupCode;
  const payments = (order.payments ?? []) as Json[];
  const lines = (order.lines ?? []) as Json[];
  return (
    <div className="ops-order">
      <span className="ops-eyebrow">{channelOf(order)} · {words(order.status)}</span>
      <h2>{order.number ? `#${order.number}` : `Order ${order.id}`}</h2>
      {order.customerLabel && <p>{order.customerLabel}</p>}
      <ul className="ops-lines">
        {lines.map((l, i) => (
          <li key={i}>
            <span>{String(l.quantity)}× {String(l.name)}</span>
            {Array.isArray(l.options) && l.options.length > 0 && (
              <small>{(l.options as Json[]).map((o) => String(o.name ?? o)).join(", ")}</small>
            )}
          </li>
        ))}
      </ul>
      <p className="ops-total">{currency(order.totalMinor, order.currency)} · {isPaid(order.paymentStatus) ? "Paid" : words(order.paymentStatus)}</p>
      <h3>Payments</h3>
      {payments.length === 0 ? (
        <p className="ops-note">No payment yet.</p>
      ) : (
        <ul className="ops-payments">
          {payments.map((p) => (
            <li key={String(p.checkoutId)}>
              <strong>{p.method === "paypal" ? "PayPal" : "Cash"} · {currency(Number(p.amountMinor), String(p.currency))}</strong>
              <span>{words(p.state)} · {time(p.createdAt)}</span>
              {p.providerCaptureId ? <code title="PayPal capture id">{String(p.providerCaptureId)}</code> : null}
              {((p.refunds ?? []) as Json[]).map((r) => (
                <span key={String(r.id)} className="ops-refund">
                  Refund {currency(Number(r.amountMinor), String(p.currency))} · {words(r.state)}
                  {r.providerRefundId ? <code>{String(r.providerRefundId)}</code> : null}
                </span>
              ))}
            </li>
          ))}
        </ul>
      )}
      {step && (
        <button className="ops-primary" disabled={busy} onClick={() => (needsCode ? setAsking(true) : void advance())}>
          {busy ? "Working…" : { accepted: "Accept", preparing: "Start cooking", ready: "Mark ready", served: "Served", collected: "Hand over", completed: "Complete" }[step]}
        </button>
      )}
      {note && <p className="ops-error" role="alert">{note}</p>}
      <p className="ops-note">Refunds need a fresh identity check and are made in the Raysto app.</p>
      <PickupCodeDialog
        open={asking}
        ticket={order.number ? `#${order.number}` : `Order ${order.id}`}
        optional
        onCancel={() => setAsking(false)}
        onConfirm={(code) => {
          setAsking(false);
          void advance(code);
        }}
      />
    </div>
  );
}

export function PaymentsSection({
  api,
  tenant,
  revision,
  focus,
  currencyCode,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  focus?: string;
  currencyCode: string;
}) {
  type Tab = "attempts" | "captures" | "refunds" | "cash";
  const [tab, setTab] = useState<Tab>(
    (["attempts", "captures", "refunds", "cash"] as const).includes(focus as Tab) ? (focus as Tab) : "captures",
  );
  const [onlyOpen, setOnlyOpen] = useState(focus === "attempts");
  const { data, error } = useLoad(async () => {
    const week = dayRange(new Date(), 6);
    const [checkouts, collections, refunds, orders] = await Promise.all([
      api.query<Json>("checkouts", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }),
      api.query<Json>("report", { restaurantId: tenant, report: "collections", limit: 100, ...week }),
      api.query<Json>("report", { restaurantId: tenant, report: "refunds", limit: 100, ...week }),
      api.query<Json>("orders", { restaurantId: tenant, staff: true, order: "desc", limit: 200 }).catch(() => ({ rows: [] })),
    ]);
    return {
      checkouts: asRows<CheckoutRow>(checkouts).map((r) => ({ ...r, checkoutId: r.checkoutId ?? r.id })),
      collections: asRows<CollectionRow>(collections),
      refunds: asRows<RefundRow>(refunds),
      // Ticket numbers, so a payment reads the same here as on the Orders board.
      tickets: new Map(asRows<OrderRow>(orders).map((o) => [o.id, o.number])),
    };
  }, [api, tenant, revision]);
  const forLabel = (orderId?: number | null, visitId?: number | null) => {
    if (orderId) {
      const n = data?.tickets.get(orderId);
      return n ? `#${n} · order ${orderId}` : `Order ${orderId}`;
    }
    return visitId ? `Visit ${visitId}` : "";
  };
  const totals = collectionTotals(data?.collections ?? []);
  const attempts = data ? (onlyOpen ? unresolved(data.checkouts, new Date()) : data.checkouts) : [];
  const tabs: [Tab, string][] = [
    ["captures", "PayPal captures"],
    ["cash", "Cash"],
    ["refunds", "Refunds"],
    ["attempts", "Attempts"],
  ];
  // Zero totals while loading would read as "no money taken".
  if (!data) return <p className="ops-note">{error || "Loading payments…"}</p>;
  return (
    <div className="ops-business">
      <div className="ops-kpis compact">
        {(
          [
            ["PayPal · 7 days", totals.paypal, ""],
            ["Cash · 7 days", totals.cash, ""],
            ["Refunded", totals.refunded, ""],
            ["Under review", totals.review, totals.review ? "alert" : ""],
          ] as const
        ).map(([label, value, tone], i) => (
          <Reveal key={label} index={i} visitKey="payments-kpis" className={`ops-kpi ${tone}`}>
            <span>{label}</span>
            <strong>
              <CountUp value={value} format={(n) => currency(n, currencyCode)} />
            </strong>
          </Reveal>
        ))}
      </div>
      <div className="ops-chips" role="tablist" aria-label="Payment records">
        {tabs.map(([t, label]) => (
          <button key={t} role="tab" aria-selected={tab === t} aria-pressed={tab === t} onClick={() => setTab(t)}>{label}</button>
        ))}
        {tab === "attempts" && (
          <label className="ops-toggle">
            <input type="checkbox" checked={onlyOpen} onChange={(e) => setOnlyOpen(e.target.checked)} /> Only unresolved
          </label>
        )}
      </div>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-grid tall">
        {tab === "attempts" ? (
          <AgGridReact<CheckoutRow>
            key="attempts"
            theme={gridTheme}
            rowData={attempts}
            defaultColDef={defaults}
            columnDefs={[
              { field: "checkoutId", headerName: "Checkout", flex: 0.6 },
              { field: "method", valueFormatter: (p) => (p.value === "paypal" ? "PayPal" : "Cash") },
              { field: "state", valueFormatter: (p) => words(p.value), cellRenderer: pill },
              { field: "amountMinor", headerName: "Amount", type: "rightAligned", valueFormatter: money(currencyCode) },
              { headerName: "For", valueGetter: (p) => forLabel(p.data?.orderId, p.data?.visitId) },
              { field: "createdAt", headerName: "Started", valueFormatter: (p) => time(p.value) },
            ]}
          />
        ) : tab === "refunds" ? (
          <AgGridReact<RefundRow>
            key="refunds"
            theme={gridTheme}
            rowData={data?.refunds ?? []}
            defaultColDef={defaults}
            columnDefs={[
              { field: "id", headerName: "Refund", flex: 0.5 },
              { field: "amountMinor", headerName: "Amount", type: "rightAligned", valueFormatter: money(currencyCode) },
              { field: "state", valueFormatter: (p) => words(p.value), cellRenderer: pill },
              { field: "reason" },
              { field: "providerRefundId", headerName: "PayPal refund id" },
              { field: "createdAt", headerName: "Requested", valueFormatter: (p) => time(p.value) },
            ]}
          />
        ) : (
          <AgGridReact<CollectionRow>
            key={tab}
            theme={gridTheme}
            rowData={(data?.collections ?? []).filter((c) => (tab === "cash" ? c.method === "cash" : c.method !== "cash"))}
            defaultColDef={defaults}
            columnDefs={[
              { field: "amountMinor", headerName: "Amount", type: "rightAligned", valueFormatter: money(currencyCode) },
              { field: "refundedMinor", headerName: "Refunded", type: "rightAligned", valueFormatter: money(currencyCode) },
              { field: "state", headerName: "Ledger", valueFormatter: (p) => (p.value === "review" ? "Under review" : words(p.value)), cellRenderer: pill },
              ...(tab === "captures" ? [{ field: "providerCaptureId" as const, headerName: "PayPal capture id", minWidth: 190 }] : []),
              { headerName: "For", valueGetter: (p) => forLabel(p.data?.orderId, p.data?.visitId) },
              { field: "createdAt", headerName: "Collected", valueFormatter: (p) => time(p.value), sort: "desc" },
            ]}
          />
        )}
      </div>
      <small>PayPal and cash are kept apart. Amounts under review are PayPal captures found on a released checkout.</small>
    </div>
  );
}

/**
 * AI coworkers: what each agent prepared, with its evidence, waiting for a
 * manager. Nothing changes until someone approves; money also needs the
 * manager to confirm their identity first.
 */
export function AgentsSection({
  api,
  tenant,
  revision,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
}) {
  const [tab, setTab] = useState<"inbox" | "activity">("inbox");
  const [selected, setSelected] = useState<number>();
  // The dialog keeps the action it opened with while it shrinks back.
  const [shown, setShown] = useState<AgentActionRow>();
  const snackbar = useOptionalSnackbar();
  const { data, error, reload } = useLoad(async () => {
    const [inbox, activity] = await Promise.all([
      api.query<Json>("agent.inbox", { restaurantId: tenant }),
      api.query<Json>("agent.activity", { restaurantId: tenant, limit: 50 }),
    ]);
    return {
      inbox: asRows<AgentActionRow>(inbox),
      activity: asRows<AgentTaskRow>(activity),
    };
  }, [api, tenant, revision]);
  const today = new Date().toDateString();
  const todays = (data?.activity ?? []).filter((t) => new Date(t.createdAt).toDateString() === today);
  const open = (a: AgentActionRow) => {
    setShown(a);
    setSelected(a.id);
  };
  const decided = (action: AgentActionRow, state: string, result?: Json) => {
    setSelected(undefined);
    reload();
    // Money cannot be taken back, so these messages never offer Undo.
    const id = paypalIdOf(result);
    snackbar?.show({
      message:
        state === "executed"
          ? `${action.title}: done${id ? ` · PayPal ${id}` : ""}`
          : state === "rejected"
            ? `${action.title}: dismissed`
            : state === "stale"
              ? "Things changed since the agent looked. It will check again."
              : String(result?.message ?? "It could not be completed."),
    });
  };
  const activityColumns = useMemo<ColDef<AgentTaskRow>[]>(
    () => [
      { headerName: "Agent", valueGetter: (p) => (p.data ? agentName(p.data.agent) : ""), minWidth: 140 },
      { field: "title", headerName: "Task", minWidth: 180 },
      { field: "summary", headerName: "Outcome", flex: 2, minWidth: 260, tooltipField: "summary" },
      { field: "status", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 110 },
      {
        headerName: "Time",
        valueGetter: (p) => Number(p.data?.state?.ms ?? 0) / 1000,
        valueFormatter: (p) => (p.value ? `${Number(p.value).toFixed(1)} s` : ""),
        minWidth: 100,
      },
      {
        field: "chargedMicros",
        headerName: "AI cost",
        valueFormatter: (p) => agentCost(Number(p.value ?? 0)),
        type: "rightAligned",
        minWidth: 110,
      },
      { field: "createdAt", headerName: "When", valueFormatter: (p) => time(p.value), sort: "desc", minWidth: 150 },
    ],
    [],
  );
  if (!data) return <p className="ops-note">{error || "Loading the agents…"}</p>;
  const kpis: [string, number, (n: number) => string][] = [
    ["Waiting for you", data.inbox.length, (n) => String(Math.round(n))],
    ["Agent tasks today", todays.length, (n) => String(Math.round(n))],
    ["Money suggestions", data.inbox.filter((a) => a.risk === "money").length, (n) => String(Math.round(n))],
    ["AI cost today", todays.reduce((n, t) => n + t.chargedMicros, 0), (n) => agentCost(Math.round(n))],
  ];
  return (
    <div className="ops-business">
      <div className="ops-kpis compact">
        {kpis.map(([label, value, format], i) => (
          <Reveal key={label} index={i} visitKey="agents-kpis" className="ops-kpi">
            <span>{label}</span>
            <strong>
              <CountUp value={value} format={format} />
            </strong>
          </Reveal>
        ))}
      </div>
      <div className="ops-chips" role="group" aria-label="Agents view">
        <button aria-pressed={tab === "inbox"} onClick={() => setTab("inbox")}>Waiting for you</button>
        <button aria-pressed={tab === "activity"} onClick={() => setTab("activity")}>What the agents did</button>
      </div>
      {error && <p className="ops-error" role="alert">{error}</p>}
      {tab === "inbox" ? (
        data.inbox.length === 0 ? (
          <p className="ops-quiet-note">Nothing is waiting. Agents ask here when something needs you.</p>
        ) : (
          <ul className="m3-proposals" aria-label="Waiting for you">
            {data.inbox.map((a, i) => {
              const chips = evidenceChips(a.evidence ?? {}, a.preview ?? {}, (minor, code) => currency(minor, code)).slice(0, 3);
              return (
                <Reveal key={a.id} as="li" index={i} visitKey="agents-inbox">
                  <ContainerCard layoutId={`agent-${a.id}`} as="article" className={`m3-proposal ${a.risk}`}>
                    <span className="ops-eyebrow">
                      {agentName(a.agent)} · {a.risk === "money" ? "Money · identity check" : a.risk === "ops" ? "Service" : "Menu"}
                    </span>
                    <h3>{a.title}</h3>
                    <p className="m3-proposal-why">{a.rationale}</p>
                    {chips.length > 0 && (
                      <ul className="m3-proposal-chips">
                        {chips.map((c) => (
                          <li key={c}>{c}</li>
                        ))}
                      </ul>
                    )}
                    <div className="m3-proposal-foot">
                      <small>{time(a.createdAt)}</small>
                      <button type="button" className="ops-primary" onClick={() => open(a)} aria-label={`Review: ${a.title}`}>
                        Review
                      </button>
                    </div>
                  </ContainerCard>
                </Reveal>
              );
            })}
          </ul>
        )
      ) : (
        <div className="ops-grid tall">
          <AgGridReact<AgentTaskRow>
            key="agents-activity"
            theme={gridTheme}
            rowData={data.activity}
            columnDefs={activityColumns}
            defaultColDef={defaults}
            getRowId={(p) => String(p.data.id)}
            tooltipShowDelay={300}
          />
        </div>
      )}
      <small className="ops-note">Agents prepare; people approve; PayPal moves the money.</small>
      <ContainerDialog
        layoutId={`agent-${shown?.id ?? 0}`}
        open={selected !== undefined}
        onClose={() => setSelected(undefined)}
        title={shown?.title ?? "Proposal"}
      >
        {shown && (
          <AgentPanel
            key={`${shown.id}-${shown.version}`}
            api={api}
            tenant={tenant}
            action={shown}
            variant="dialog"
            knownPassword={isJudgeVenue(tenant) ? judge.password : ""}
            onDone={(state, result) => decided(shown, state, result)}
          />
        )}
      </ContainerDialog>
    </div>
  );
}

/** The PayPal id a decided action reports, for the confirmation message. */
export function paypalIdOf(result?: Json): string | undefined {
  if (!result) return undefined;
  for (const key of ["providerBatchId", "providerRefundId", "providerCaptureId", "invoiceNumber", "providerInvoiceId"]) {
    const v = result[key];
    if (typeof v === "string" && v) return v;
  }
  return undefined;
}

export function AgentPanel({
  api,
  tenant,
  action,
  onDone,
  inline = false,
  variant,
  knownPassword = "",
}: {
  api: ConnectedApi;
  tenant: number;
  action: AgentActionRow;
  /** The decided state, and the action's result (its error code and message when it failed). */
  onDone: (state: string, result?: Json) => void;
  /** Inside a card instead of the side column. */
  inline?: boolean;
  /** Where it sits: the side column (default), a card (`inline`) or a container-transform dialog. */
  variant?: "side" | "inline" | "dialog";
  /** The published judge password, so the identity check is one tap. */
  knownPassword?: string;
}) {
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const [needsCheck, setNeedsCheck] = useState(false);
  const [password, setPassword] = useState(knownPassword);
  const [passwordAccount, setPasswordAccount] = useState(true);
  // One request key per decision: retrying after the identity check resumes
  // the same approval instead of starting another.
  const [keys] = useState(() => ({ approve: crypto.randomUUID(), reject: crypto.randomUUID() }));
  const chips = evidenceChips(action.evidence ?? {}, action.preview ?? {}, (minor, code) => currency(minor, code));

  async function decide(decision: "approve" | "reject") {
    setBusy(true);
    setNote("");
    try {
      const result = await api.command<Json>(
        "agent.decide",
        tenant,
        { decision },
        { id: action.id, version: action.version, key: keys[decision] },
      );
      if (result.needs) {
        setPasswordAccount(await usesPassword());
        setNeedsCheck(true);
        setNote("Confirm it is you to approve this payment change.");
        return;
      }
      const state = String(result.state);
      setNote(
        state === "executed"
          ? "Done."
          : state === "rejected"
            ? "Dismissed."
            : state === "stale"
              ? "Things changed since the agent looked. It will check again."
              : state === "failed"
                ? String((result.result as Json | undefined)?.message ?? "It could not be completed.")
                : words(state),
      );
      onDone(state, result.result as Json | undefined);
    } catch (e) {
      setNote(String(e instanceof Error ? e.message : e));
    } finally {
      setBusy(false);
    }
  }

  async function confirm() {
    setBusy(true);
    try {
      await stepUp(api, tenant, passwordAccount ? password : undefined);
      setPassword(knownPassword);
      setNeedsCheck(false);
      await decide("approve");
    } catch (e) {
      setNote(String(e instanceof Error ? e.message : e));
      setBusy(false);
    }
  }

  const place = variant ?? (inline ? "inline" : "side");
  const Shell = place === "side" ? "aside" : "div";
  return (
    <Shell className={place === "inline" ? "ops-try-approve" : place === "dialog" ? "ops-order m3-agent-dialog" : "ops-side ops-order"}>
      <span className="ops-eyebrow">
        {agentName(action.agent)} · {action.risk === "money" ? "Money" : action.risk === "ops" ? "Service" : "Menu"}
      </span>
      <h2 style={{ fontSize: place === "inline" ? 19 : place === "dialog" ? 22 : 24 }}>{action.title}</h2>
      <p>{action.rationale}</p>
      {chips.length > 0 && (
        <>
          <h3>Evidence</h3>
          <ul className="ops-payments">
            {chips.map((c) => (
              <li key={c}>
                <code>{c}</code>
              </li>
            ))}
          </ul>
        </>
      )}
      {needsCheck ? (
        <form
          onSubmit={(e) => {
            e.preventDefault();
            void confirm();
          }}
        >
          {passwordAccount ? (
            <label>
              Password
              <input
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </label>
          ) : null}
          <button className="ops-primary" disabled={busy} type="submit">
            {passwordAccount ? "Confirm and approve" : "Confirm with Google and approve"}
          </button>
        </form>
      ) : (
        <>
          <button className="ops-primary" disabled={busy} onClick={() => void decide("approve")}>
            {action.risk === "money" ? "Approve (identity check)" : "Approve"}
          </button>
          <button disabled={busy} onClick={() => void decide("reject")} style={{ width: "100%", marginTop: 8 }}>
            Not now
          </button>
        </>
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </Shell>
  );
}
