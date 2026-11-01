"use client";
import { useCallback, useEffect, useMemo, useState } from "react";
import { AgGridReact } from "ag-grid-react";
import { themeQuartz, type ColDef } from "ag-grid-community";
import { ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import {
  asRows,
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
} from "@/lib/connected/business";

export type Section = "overview" | "orders" | "payments";

const gridTheme = themeQuartz.withParams({
  accentColor: "#23493c",
  backgroundColor: "#fffdf7",
  foregroundColor: "#193c30",
  fontFamily: "var(--font-jakarta)",
  rowHeight: 48,
});
const time = (iso: unknown) =>
  iso ? new Date(String(iso)).toLocaleString([], { dateStyle: "short", timeStyle: "short" }) : "";
const words = (v: unknown) => {
  const s = String(v ?? "").replace(/([a-z])([A-Z])/g, "$1 $2").replaceAll("_", " ");
  return s.charAt(0).toUpperCase() + s.slice(1);
};
const money =
  (fallback: string) =>
  (p: { value?: unknown; data?: unknown }): string =>
    currency(
      Number(p.value ?? 0),
      String((p.data as { currency?: string } | undefined)?.currency ?? fallback),
    );
const defaults: ColDef = { sortable: true, filter: true, resizable: true, flex: 1, minWidth: 110 };

function useLoad<T>(load: () => Promise<T>, deps: unknown[]) {
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
    const [summary, channels, collections, checkouts, orders] = await Promise.all([
      api.query<Summary>("report", { restaurantId: tenant, report: "summary", ...today }),
      api.query<{ channels: Record<string, { orders: number; salesMinor: number }> }>(
        "report",
        { restaurantId: tenant, report: "channels", ...today },
      ),
      api.query<Json>("report", { restaurantId: tenant, report: "collections", limit: 100, ...today }),
      api.query<Json>("checkouts", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }),
      api.query<Json>("orders", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }),
    ]);
    return {
      summary,
      mix: channelMix(channels.channels ?? {}),
      totals: collectionTotals(asRows<CollectionRow>(collections)),
      attention: unresolved(asRows<CheckoutRow>(checkouts), new Date()).length,
      active: asRows<OrderRow>(orders).filter((o) => statusGroup(o.status) !== "Done"),
    };
  }, [api, tenant, revision]);
  const code = data?.summary.currency ?? currencyCode;
  if (!data) return <p className="ops-note">{error || "Gathering today's figures…"}</p>;
  const { summary, mix, totals, attention, active } = data;
  const kpis: { label: string; value: string; note: string; to?: [Section | "floor", string?] }[] = [
    { label: "Orders today", value: String(summary.ordersCreated), note: `${summary.completedOrders} completed`, to: ["orders"] },
    { label: "Booked sales", value: currency(summary.bookedSalesMinor, code), note: "Placed and not cancelled", to: ["orders"] },
    { label: "PayPal collected", value: currency(totals.paypal, code), note: "Captured by PayPal today", to: ["payments", "captures"] },
    { label: "Cash collected", value: currency(totals.cash, code), note: "Recorded at the counter or table", to: ["payments", "cash"] },
    { label: "Refunded", value: currency(summary.refundsMinor, code), note: "Completed refunds today", to: ["payments", "refunds"] },
    { label: "PayPal to resolve", value: String(attention + (totals.review ? 1 : 0)), note: totals.review ? `${currency(totals.review, code)} under review` : "Unfinished or uncertain attempts", to: ["payments", "attempts"] },
    { label: "In the kitchen", value: String(active.length), note: "New, preparing or ready", to: ["orders", "active"] },
    { label: "Service requests", value: String(openRequests), note: "Open at the tables", to: ["floor"] },
  ];
  return (
    <div className="ops-business">
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis">
        {kpis.map((k) => (
          <button
            key={k.label}
            className={`ops-kpi ${k.label === "PayPal to resolve" && k.value !== "0" ? "alert" : ""}`}
            onClick={() => k.to && open(k.to[0], k.to[1])}
            disabled={!k.to}
          >
            <span>{k.label}</span>
            <strong>{k.value}</strong>
            <small>{k.note}</small>
          </button>
        ))}
      </div>
      <section className="ops-panel">
        <h2>Today by channel</h2>
        {mix.length === 0 ? (
          <p className="ops-note">No orders yet today.</p>
        ) : (
          <table className="ops-mix">
            <thead>
              <tr><th>Channel</th><th>Orders</th><th>Sales</th><th>Share</th></tr>
            </thead>
            <tbody>
              {mix.map((m) => {
                const total = mix.reduce((n, x) => n + x.salesMinor, 0) || 1;
                return (
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
                );
              })}
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
  const [rows, setRows] = useState<OrderRow[]>([]);
  // Until the first page arrives the grid shows loading, not "no rows".
  const [loaded, setLoaded] = useState(false);
  const [cursor, setCursor] = useState<number | null>(null);
  const [channel, setChannel] = useState<Channel | "All">("All");
  const [group, setGroup] = useState<StatusGroup | "Active" | "All">(focus === "active" ? "Active" : "All");
  const [selected, setSelected] = useState<number>();
  const [error, setError] = useState("");
  const load = useCallback(
    async (more = false) => {
      try {
        const page = await api.query<{ rows: OrderRow[]; nextCursor: number | null }>("orders", {
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
  const shown = rows.filter(
    (o) =>
      (channel === "All" || channelOf(o) === channel) &&
      (group === "All" ||
        (group === "Active" ? statusGroup(o.status) !== "Done" : statusGroup(o.status) === group)),
  );
  const columns = useMemo<ColDef<OrderRow>[]>(
    () => [
      { headerName: "Ticket", valueGetter: (p) => (p.data?.number ? `#${p.data.number}` : `Order ${p.data?.id}`), minWidth: 100, flex: 0.7 },
      { headerName: "Channel", valueGetter: (p) => (p.data ? channelOf(p.data) : "") },
      { field: "status", valueFormatter: (p) => words(p.value) },
      { field: "paymentStatus", headerName: "Payment", valueFormatter: (p) => words(p.value) },
      { field: "totalMinor", headerName: "Total", type: "rightAligned", valueFormatter: money(currencyCode) },
      { headerName: "Customer / table", minWidth: 140, valueGetter: (p) => (p.data ? customerOf(p.data) : "") },
      { field: "createdAt", headerName: "Placed", minWidth: 160, valueFormatter: (p) => time(p.value), sort: "desc" },
    ],
    [currencyCode],
  );
  return (
    <div className="ops-business with-panel">
      <div>
        <div className="ops-chips" role="group" aria-label="Channel">
          {(["All", "Counter", "Pickup", "Dine-in", "Delivery"] as const).map((c) => (
            <button key={c} aria-pressed={channel === c} onClick={() => setChannel(c)}>{c}</button>
          ))}
        </div>
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
          <small>{shown.length} of {rows.length} loaded, newest first.</small>
          {cursor && <button onClick={() => void load(true)}>Load older orders</button>}
        </div>
      </div>
      <aside className="ops-side">
        {selected ? (
          <OrderPanel key={selected} api={api} tenant={tenant} id={selected} revision={revision} onChanged={() => void load()} />
        ) : (
          <p className="ops-note">Select an order to see its lines, its PayPal payments and its next step.</p>
        )}
      </aside>
    </div>
  );
}

function OrderPanel({
  api,
  tenant,
  id,
  revision,
  onChanged,
}: {
  api: ConnectedApi;
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
  if (!order) return <p className="ops-note">{error || "Loading the order…"}</p>;
  const step = nextStep(order);
  async function advance() {
    if (!order || !step) return;
    setBusy(true);
    setNote("");
    try {
      let code: string | undefined;
      if (step === "collected" && order.origin !== "counter" && order.pickupCode) {
        code = window.prompt("Pickup code on the customer's phone (managers may leave it empty)") ?? undefined;
        if (code === undefined) return;
        if (code === "") code = undefined;
      }
      if (step === "ready") {
        // Tick any lines the kitchen left open, then mark the order ready.
        const kitchen = await api.query<{ rows: Json[] }>("kitchen", { restaurantId: tenant, limit: 100 });
        const tickets = (kitchen.rows.find((r) => r.id === order.id)?.tickets ?? []) as Json[];
        for (const t of tickets) {
          if (Number(t.completedQuantity) >= Number(t.quantity)) continue;
          await api.command("kitchen.progress", tenant, { lineKey: t.lineKey, completedQuantity: t.quantity }, { id: order.id, version: Number(t.version) });
        }
      }
      await api.command("order.transition", tenant, { status: step, ...(code ? { code } : {}) }, { id: order.id, version: order.version });
      reload();
      onChanged();
    } catch (e) {
      setNote(String(e instanceof Error ? e.message : e));
    } finally {
      setBusy(false);
    }
  }
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
        <button className="ops-primary" disabled={busy} onClick={() => void advance()}>
          {busy ? "Working…" : { accepted: "Accept", preparing: "Start cooking", ready: "Mark ready", served: "Served", collected: "Hand over", completed: "Complete" }[step]}
        </button>
      )}
      {note && <p className="ops-error" role="alert">{note}</p>}
      <p className="ops-note">Refunds need a fresh identity check and are made in the Raysto app.</p>
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
    const [checkouts, collections, refunds] = await Promise.all([
      api.query<Json>("checkouts", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }),
      api.query<Json>("report", { restaurantId: tenant, report: "collections", limit: 100, ...week }),
      api.query<Json>("report", { restaurantId: tenant, report: "refunds", limit: 100, ...week }),
    ]);
    return {
      checkouts: asRows<CheckoutRow>(checkouts).map((r) => ({ ...r, checkoutId: r.checkoutId ?? r.id })),
      collections: asRows<CollectionRow>(collections),
      refunds: asRows<RefundRow>(refunds),
    };
  }, [api, tenant, revision]);
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
        <div className="ops-kpi"><span>PayPal · 7 days</span><strong>{currency(totals.paypal, currencyCode)}</strong></div>
        <div className="ops-kpi"><span>Cash · 7 days</span><strong>{currency(totals.cash, currencyCode)}</strong></div>
        <div className="ops-kpi"><span>Refunded</span><strong>{currency(totals.refunded, currencyCode)}</strong></div>
        <div className={`ops-kpi ${totals.review ? "alert" : ""}`}><span>Under review</span><strong>{currency(totals.review, currencyCode)}</strong></div>
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
              { field: "state", valueFormatter: (p) => words(p.value) },
              { field: "amountMinor", headerName: "Amount", type: "rightAligned", valueFormatter: money(currencyCode) },
              { headerName: "For", valueGetter: (p) => (p.data?.orderId ? `Order ${p.data.orderId}` : `Visit ${p.data?.visitId}`) },
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
              { field: "state", valueFormatter: (p) => words(p.value) },
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
              { field: "state", headerName: "Ledger", valueFormatter: (p) => (p.value === "review" ? "Under review" : words(p.value)) },
              ...(tab === "captures" ? [{ field: "providerCaptureId" as const, headerName: "PayPal capture id", minWidth: 190 }] : []),
              { headerName: "For", valueGetter: (p) => (p.data?.orderId ? `Order ${p.data.orderId}` : p.data?.visitId ? `Visit ${p.data.visitId}` : "") },
              { field: "createdAt", headerName: "Collected", valueFormatter: (p) => time(p.value), sort: "desc" },
            ]}
          />
        )}
      </div>
      <small>PayPal and cash are kept apart. Amounts under review are PayPal captures found on a released checkout.</small>
    </div>
  );
}
