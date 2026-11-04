"use client";
/**
 * Supplies: what the café has, what it will run out of and when, what it
 * ordered, what arrived and what the supplier charges. The forecast is
 * plain arithmetic on the server; the supply planner (an AI coworker)
 * explains it and proposes orders, and checks each delivery note against
 * the order and the bill. A manager approves every order, receipt and bill.
 * Owner: stream S3 (docs/release-0.16-design.md).
 */
import { useMemo, useState, type FormEvent, type ReactNode } from "react";
import type { ColDef } from "ag-grid-community";
import { ApiFailure, type ConnectedApi } from "@/lib/connected/api";
import type { AgentActionRow } from "@/lib/connected/business";
import { currency } from "@/lib/connected/contracts";
import { boolCol, countCol, dateCol, idCol, moneyCol, statusCol } from "@/lib/connected/grid-columns";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { approvalNotice } from "@/lib/connected/money-view";
import { MotionRoot } from "@/lib/connected/motion";
import { StudioCanvas, StudioWidget } from "@/lib/connected/studio/studio-canvas";
import {
  basisText,
  coverText,
  flagLabel,
  flagTone,
  funnelSource,
  funnelWidget,
  inventoryState,
  matchText,
  orderActions,
  parseQty,
  portionCost,
  qty,
  receiptDraft,
  remaining,
  reorderGroups,
  scatterWidget,
  scorecardSource,
  source,
  stockSource,
  stockState,
  supplies,
  wasteReasons,
  type Delivery,
  type ForecastRow,
  type Match,
  type Recipe,
  type Scorecard,
  type SupplierOrder,
  type SuppliesApi,
  type WasteEntry,
  type WasteReason,
} from "@/lib/connected/supplies";
import { AgentPanel, useLoad } from "./business-sections";
import type { SectionProps } from "./group-section";
import { Icon } from "./icons";
import { CountUp, Reveal, SnackbarProvider, useSnackbar } from "./m3";
import { RaystoGrid } from "./raysto-grid";
import { UploadDrop } from "./upload-drop";
import "./supplies-section.css";

export type SuppliesTab = "inventory" | "purchasing" | "receive" | "suppliers" | "recipes" | "waste";
const tabs: [SuppliesTab, string][] = [
  ["inventory", "Inventory"],
  ["purchasing", "Purchasing"],
  ["receive", "Receive"],
  ["suppliers", "Suppliers"],
  ["recipes", "Recipes"],
  ["waste", "Waste"],
];

const fail = (e: unknown) => String(e instanceof Error ? e.message : e);

type Notice = ReturnType<typeof useSnackbar>;
function useNotice(): Notice | null {
  try {
    return useSnackbar();
  } catch {
    return null;
  }
}

function KitRoot({ children }: { children: ReactNode }) {
  const notice = useNotice();
  const inner = <MotionRoot>{children}</MotionRoot>;
  return notice ? inner : <SnackbarProvider>{inner}</SnackbarProvider>;
}

/** One command with its busy state and its outcome as a snackbar or a note line. */
function useAct(onDone?: () => void) {
  const notice = useNotice();
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  async function act(run: () => Promise<string | void>) {
    setBusy(true);
    setNote("");
    try {
      const said = (await run()) ?? "Done.";
      if (notice) notice.show({ message: said });
      else setNote(said);
      onDone?.();
    } catch (e) {
      setNote(fail(e));
    } finally {
      setBusy(false);
    }
  }
  return { busy, note, act };
}

function Kpi({ label, children, alert }: { label: string; children: ReactNode; alert?: boolean }) {
  return (
    <div className={`ops-kpi ${alert ? "alert" : ""}`}>
      <span>{label}</span>
      <strong>{children}</strong>
    </div>
  );
}

const Count = ({ n }: { n: number }) => <CountUp value={Math.round(n)} format={(x) => String(x)} />;
const Cash = ({ minor, code }: { minor: number; code: string }) => <CountUp value={Math.round(minor)} format={(n) => currency(n, code)} />;

/** The agent's proposals for some commands, each with its evidence and the approve button. */
function Proposals({ api, tenant, inbox, commands, onDone }: { api: ConnectedApi; tenant: number; inbox: AgentActionRow[]; commands: string[]; onDone: () => void }) {
  const notice = useNotice();
  const mine = inbox.filter((a) => commands.includes(a.command));
  if (mine.length === 0) return null;
  return (
    <div className="ops-bo-proposals ops-sup-proposals">
      {mine.map((a, i) => (
        <Reveal key={`${a.id}-${a.version}`} index={i} as="section" className="ops-panel ops-bo-card">
          <AgentPanel
            api={api}
            tenant={tenant}
            action={a}
            inline
            knownPassword={isJudgeVenue(tenant) ? judge.password : ""}
            onDone={(state, result) => {
              notice?.show({ message: approvalNotice(state, result) });
              onDone();
            }}
          />
        </Reveal>
      ))}
    </div>
  );
}

type TabProps = {
  api: ConnectedApi;
  tenant: number;
  sp: SuppliesApi;
  currencyCode: string;
  inbox: AgentActionRow[];
  refresh: () => void;
  /** Changes on every live event and every action; tabs refetch on it. */
  version: string;
};

export function SuppliesSection({ api, tenant, revision, currencyCode, focus }: SectionProps & { focus?: string }) {
  const [tab, setTab] = useState<SuppliesTab>(tabs.some(([t]) => t === focus) ? (focus as SuppliesTab) : "inventory");
  const [tick, setTick] = useState(0);
  const sp = useMemo(() => supplies(api, tenant), [api, tenant]);
  const { data: inbox } = useLoad(() => sp.inbox(), [sp, revision, tick]);
  const refresh = () => setTick((n) => n + 1);
  const version = `${revision}-${tick}`;
  const props: TabProps = { api, tenant, sp, currencyCode, inbox: inbox ?? [], refresh, version };
  const waiting = (inbox ?? []).filter((a) => ["supplier.order.propose", "stock.receive", "bill.match"].includes(a.command)).length;
  return (
    <KitRoot>
      <div className="ops-business ops-supplies">
        <div className="ops-chips ops-bo-tabs" role="tablist" aria-label="Supplies">
          {tabs.map(([t, label]) => (
            <button key={t} role="tab" aria-selected={tab === t} aria-pressed={tab === t} onClick={() => setTab(t)}>
              {label}
              {t === "purchasing" && waiting > 0 && <span className="ops-sup-badge" aria-label={`${waiting} waiting for you`}>{waiting}</span>}
            </button>
          ))}
        </div>
        {tab === "inventory" ? (
          <InventoryTab key={tab} {...props} />
        ) : tab === "purchasing" ? (
          <PurchasingTab key={tab} {...props} />
        ) : tab === "receive" ? (
          <ReceiveTab key={tab} {...props} />
        ) : tab === "suppliers" ? (
          <SuppliersTab key={tab} {...props} />
        ) : tab === "recipes" ? (
          <RecipesTab key={tab} {...props} />
        ) : (
          <WasteTab key={tab} {...props} />
        )}
        <small className="ops-note">The forecast is arithmetic on your own records. The supply planner explains it and proposes orders; you approve each order, receipt and bill.</small>
      </div>
    </KitRoot>
  );
}

/* ---------- Inventory ---------- */

const stateWords: Record<string, string> = { low: "Reorder now", due: "Low", active: "Covered" };
/** The grid's status words map to the shared pill tones: low is red, due amber, active green. */
const stateTone = (r: ForecastRow) => ({ reorder: "low", low: "due", ok: "active" })[stockState(r)];

function InventoryTab({ sp, currencyCode, version, inbox, api, tenant, refresh }: TabProps) {
  const { data, error } = useLoad(() => sp.forecast(), [sp, version]);
  const code = data?.currency ?? currencyCode;
  const rows = data?.rows;
  const studio = useMemo(() => source("stock", stockSource(data)), [data]);
  const state = useMemo(() => inventoryState(code), [code]);
  const reorder = (rows ?? []).filter((r) => r.reorder).length;
  const low = (rows ?? []).filter((r) => r.low).length;
  const value = (rows ?? []).reduce((n, r) => n + r.valueMinor, 0);
  const columns = useMemo<ColDef<ForecastRow>[]>(
    () => [
      { field: "name", headerName: "Item", minWidth: 160, cellClass: "ops-cell-strong" },
      { field: "supplierName", headerName: "Supplier", minWidth: 150 },
      { headerName: "On hand", valueGetter: (p) => p.data?.quantity, valueFormatter: (p) => qty(p.data?.quantity, p.data?.unit), type: "rightAligned", cellClass: "ops-num", minWidth: 110 },
      { headerName: "Low at", valueGetter: (p) => p.data?.lowAt, valueFormatter: (p) => qty(p.data?.lowAt, p.data?.unit), type: "rightAligned", cellClass: "ops-num", minWidth: 100 },
      { headerName: "Par", valueGetter: (p) => p.data?.parLevel, valueFormatter: (p) => qty(p.data?.parLevel, p.data?.unit), type: "rightAligned", cellClass: "ops-num", minWidth: 100 },
      { headerName: "Cover", valueGetter: (p) => p.data?.daysCover ?? null, valueFormatter: (p) => (p.data ? coverText(p.data) : ""), type: "rightAligned", cellClass: "ops-num", minWidth: 120, sort: "asc" },
      dateCol<ForecastRow>("Runs out", "stockOutAt", { dayOnly: true }),
      statusCol<ForecastRow>("Status", (r) => stateTone(r), { label: (v) => stateWords[String(v)] ?? String(v), minWidth: 140 }),
      { headerName: "Suggested", valueGetter: (p) => (p.data?.reorder ? p.data.suggestedQty : null), valueFormatter: (p) => (p.data?.reorder ? qty(p.data.suggestedQty, p.data.unit) : ""), type: "rightAligned", cellClass: "ops-num", minWidth: 120 },
      moneyCol<ForecastRow>("Value", "valueMinor", code),
    ],
    [code],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <Kpi label="To reorder now" alert={reorder > 0}><Count n={reorder} /></Kpi>
        <Kpi label="At or under the low mark"><Count n={low} /></Kpi>
        <Kpi label="Stock value"><Cash minor={value} code={code} /></Kpi>
      </div>
      {data && <p className="ops-note">{basisText(data.basis, data.windowDays)}</p>}
      <StudioCanvas label="Supplies: stock cover and value" sources={[studio]} initialState={state} height={520} />
      <Proposals api={api} tenant={tenant} inbox={inbox} commands={["supplier.order.propose"]} onDone={refresh} />
      <RaystoGrid<ForecastRow>
        label="Stock"
        rows={rows}
        columns={columns}
        loading={!data && !error}
        emptyText="No stock items yet. They appear when a delivery note is read or an item is added."
        getRowId={(p) => String(p.data.stockItemId)}
        csvName="raysto-stock"
      />
    </>
  );
}

/* ---------- Purchasing ---------- */

function PurchasingTab({ api, tenant, sp, currencyCode, inbox, refresh, version }: TabProps) {
  const { data: orders, error } = useLoad(() => sp.orders(), [sp, version]);
  const { data: forecast } = useLoad(() => sp.forecast(), [sp, version]);
  const [openId, setOpenId] = useState<number>();
  const { busy, note, act } = useAct(refresh);
  const code = forecast?.currency ?? currencyCode;
  const groups = useMemo(() => reorderGroups(forecast?.rows ?? []), [forecast]);
  const funnel = useMemo(() => source("orders", funnelSource(orders ?? [])), [orders]);
  const opened = (orders ?? []).find((o) => o.id === openId);
  const columns = useMemo<ColDef<SupplierOrder>[]>(
    () => [
      idCol<SupplierOrder>("Order", "id", { prefix: "PO-" }),
      { field: "supplierName", headerName: "Supplier", minWidth: 150, cellClass: "ops-cell-strong", valueFormatter: (p) => p.value ?? "No supplier yet" },
      statusCol<SupplierOrder>("State", "state"),
      countCol<SupplierOrder>("Lines", (o) => o.lines.length, { total: false }),
      moneyCol<SupplierOrder>("Total", "totalMinor", (o) => o.currency),
      dateCol<SupplierOrder>("Expected", "expectedAt", { dayOnly: true }),
      dateCol<SupplierOrder>("Sent", "sentAt"),
      dateCol<SupplierOrder>("Received", "receivedAt"),
    ],
    [],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-toolbar">
        <p className="ops-note">The supply planner reads 28 days of usage, each item&apos;s cover and its supplier&apos;s lead time, then proposes one order per supplier. Nothing is ordered until you approve.</p>
        <button
          className="ops-primary"
          disabled={busy}
          onClick={() =>
            void act(async () => {
              await sp.plan();
              return "The supply planner is reading your stock. Its proposals appear here in a few seconds.";
            })
          }
        >
          <Icon name="agents" size={18} />Ask the planner what to order
        </button>
      </div>
      {note && <p className="ops-note" role="status">{note}</p>}
      <Proposals api={api} tenant={tenant} inbox={inbox} commands={["supplier.order.propose"]} onDone={refresh} />
      {groups.length > 0 && (
        <div className="ops-sup-groups">
          {groups.map((g, i) => (
            <Reveal key={g.supplierId ?? "none"} index={i} as="section" className="ops-panel ops-bo-card" visitKey="supplies-groups">
              <span className="ops-eyebrow">From the forecast</span>
              <h3>{g.supplierName}</h3>
              <p>
                {g.rows.map((r) => `${r.name} (${qty(r.suggestedQty, r.unit)})`).join(", ")}: about {currency(g.totalMinor, code)}.
              </p>
              <button
                className="ops-secondary"
                disabled={busy}
                onClick={() =>
                  void act(async () => {
                    const saved = await sp.saveOrder({
                      ...(g.supplierId ? { supplierId: g.supplierId } : {}),
                      lines: g.rows.map((r) => ({ stockItemId: r.stockItemId, qty: r.suggestedQty })),
                      note: "Drafted from the forecast",
                    });
                    setOpenId(saved.orderId);
                    return `Draft PO-${saved.orderId} saved. Check it, then send it to ${g.supplierName}.`;
                  })
                }
              >
                <Icon name="plus" size={18} />Draft this order
              </button>
            </Reveal>
          ))}
        </div>
      )}
      <StudioWidget label="Purchase orders by stage" source={funnel} widget={funnelWidget} height={300} />
      <RaystoGrid<SupplierOrder>
        label="Purchase orders"
        rows={orders}
        columns={columns}
        loading={!orders && !error}
        emptyText="No purchase order yet. Ask the planner, or draft one from the forecast."
        getRowId={(p) => String(p.data.id)}
        onRowClicked={(e) => e.data && setOpenId(e.data.id)}
        csvName="raysto-purchase-orders"
      />
      {opened && <OrderDetail key={`${opened.id}-${opened.version}`} order={opened} sp={sp} onDone={refresh} onClose={() => setOpenId(undefined)} />}
    </>
  );
}

function OrderDetail({ order, sp, onDone, onClose }: { order: SupplierOrder; sp: SuppliesApi; onDone: () => void; onClose: () => void }) {
  const { busy, note, act } = useAct(onDone);
  const actions = orderActions(order);
  const [email, setEmail] = useState("");
  const [cancelling, setCancelling] = useState(false);
  // The receipt is a draft until it is sent: what is still to arrive, at the ordered price.
  const [receipt, setReceipt] = useState(() =>
    Object.fromEntries(order.lines.map((l) => [l.stockItemId, { qty: String(remaining(l)), price: (l.unitCostMinor / 100).toFixed(2) }])),
  );
  const code = order.currency;
  function receive(e: FormEvent) {
    e.preventDefault();
    const lines = order.lines
      .map((l) => {
        const r = receipt[l.stockItemId];
        const q = parseQty(r?.qty ?? "");
        const p = parseQty(r?.price ?? "");
        if (q == null || q <= 0) return null;
        const unit = p == null ? undefined : Math.round(p * 100);
        return { stockItemId: l.stockItemId, qty: q, ...(unit != null && unit !== l.unitCostMinor ? { unitCostMinor: unit } : {}) };
      })
      .filter((x): x is NonNullable<typeof x> => x != null);
    if (lines.length === 0) return;
    void act(async () => {
      const r = await sp.receiveOrder(order, lines);
      return r.complete ? `PO-${order.id} received in full. Stock is up.` : `Part of PO-${order.id} received. The rest stays open.`;
    });
  }
  return (
    <section className="ops-panel ops-bo-card ops-sup-order" aria-labelledby={`po-${order.id}`}>
      <div className="ops-sup-order-head">
        <div>
          <span className="ops-eyebrow">Purchase order</span>
          <h2 id={`po-${order.id}`}>PO-{order.id} · {order.supplierName ?? "No supplier yet"}</h2>
        </div>
        <button className="ops-secondary" onClick={onClose} aria-label={`Close PO-${order.id}`}><Icon name="cross" size={18} />Close</button>
      </div>
      {order.note && <p className="ops-note">{order.note}</p>}
      <form onSubmit={receive}>
        <div className="ops-sup-table-wrap">
          <table className="ops-sup-table">
            <caption className="sr-only">Lines of PO-{order.id}</caption>
            <thead>
              <tr>
                <th scope="col">Item</th>
                <th scope="col">Ordered</th>
                <th scope="col">Arrived</th>
                <th scope="col">Unit price</th>
                {actions.includes("receive") && <th scope="col">Arriving now</th>}
                {actions.includes("receive") && <th scope="col">Price paid</th>}
              </tr>
            </thead>
            <tbody>
              {order.lines.map((l) => (
                <tr key={l.stockItemId}>
                  <th scope="row">{l.name}</th>
                  <td>{qty(l.qty, l.unit)}</td>
                  <td>{qty(l.receivedQty ?? 0, l.unit)}</td>
                  <td>{currency(l.unitCostMinor, code)}</td>
                  {actions.includes("receive") && (
                    <td>
                      <input
                        inputMode="decimal"
                        aria-label={`${l.name}: quantity arriving now, in ${l.unit}`}
                        value={receipt[l.stockItemId]?.qty ?? ""}
                        onChange={(e) => setReceipt({ ...receipt, [l.stockItemId]: { ...receipt[l.stockItemId], qty: e.target.value } })}
                      />
                    </td>
                  )}
                  {actions.includes("receive") && (
                    <td>
                      <input
                        inputMode="decimal"
                        aria-label={`${l.name}: unit price paid`}
                        value={receipt[l.stockItemId]?.price ?? ""}
                        onChange={(e) => setReceipt({ ...receipt, [l.stockItemId]: { ...receipt[l.stockItemId], price: e.target.value } })}
                      />
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <p className="ops-sup-total">Total ordered <strong>{currency(order.totalMinor, code)}</strong></p>
        <div className="ops-sup-actions">
          {actions.includes("send") && (
            <>
              {!order.supplierEmail && order.supplierId && (
                <label className="ops-sup-inline">
                  Supplier&apos;s order email
                  <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="orders@supplier.example" maxLength={254} />
                </label>
              )}
              <button
                type="button"
                className="ops-primary"
                disabled={busy || !order.supplierId}
                onClick={() =>
                  void act(async () => {
                    const r = await sp.sendOrder(order, email.trim() || undefined);
                    return r.emailed ? `PO-${order.id} emailed to ${r.to}.` : `PO-${order.id} marked as sent. No email on file, so send it to the supplier yourself.`;
                  })
                }
              >
                <Icon name="arrow" size={18} />Send to {order.supplierName ?? "the supplier"}
              </button>
              {!order.supplierId && <span className="ops-note">Choose a supplier before sending.</span>}
            </>
          )}
          {actions.includes("receive") && (
            <button type="submit" className="ops-primary" disabled={busy}>
              <Icon name="check" size={18} />Record what arrived
            </button>
          )}
          {actions.includes("cancel") &&
            (cancelling ? (
              <>
                <button
                  type="button"
                  className="ops-secondary danger"
                  disabled={busy}
                  onClick={() =>
                    void act(async () => {
                      await sp.cancelOrder(order);
                      return `PO-${order.id} cancelled.`;
                    })
                  }
                >
                  Yes, cancel PO-{order.id}
                </button>
                <button type="button" className="ops-secondary" onClick={() => setCancelling(false)}>Keep it</button>
              </>
            ) : (
              <button type="button" className="ops-secondary" onClick={() => setCancelling(true)}>Cancel the order</button>
            ))}
        </div>
      </form>
      {note && <p className="ops-note" role="status">{note}</p>}
    </section>
  );
}

/* ---------- Receive ---------- */

const pause = (ms: number) => new Promise((r) => setTimeout(r, ms));

function ReceiveTab({ api, tenant, sp, currencyCode, inbox, refresh, version }: TabProps) {
  const { data: orders } = useLoad(() => sp.orders(), [sp, version]);
  const { data: deliveries, error } = useLoad(() => sp.deliveries(), [sp, version]);
  const open = (orders ?? []).filter((o) => o.state === "sent" || o.state === "partiallyReceived");
  const [orderId, setOrderId] = useState<number | "">("");
  const [shownId, setShownId] = useState<number>();
  const { busy, note, act } = useAct(refresh);
  const chosen = orderId === "" ? (open.length === 1 ? open[0].id : undefined) : orderId;
  const matched = (deliveries ?? []).filter((d) => d.match);
  const shown = matched.find((d) => d.id === shownId) ?? matched[0];

  /** The scanned note goes to the supplies agent, with the order it belongs to. */
  function read(mediaId: number) {
    return act(async () => {
      // The scanner approved the file; a moment's lag on the server is retried briefly.
      for (let tries = 0; ; tries++) {
        try {
          await sp.receiveNote(mediaId, chosen);
          break;
        } catch (e) {
          if (!(e instanceof ApiFailure) || e.code !== "media_pending" || tries >= 8) throw e;
          await pause(1500);
        }
      }
      return chosen
        ? `Reading the note and checking it against PO-${chosen}. The match appears here in a few seconds.`
        : "Reading the note. What it tops up appears here in a few seconds.";
    });
  }

  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="sup-receive">
          <span className="ops-eyebrow">Delivery note</span>
          <h2 id="sup-receive">Check a delivery against its order</h2>
          <p>Photograph or upload the supplier&apos;s note. The supplies agent reads it, compares every line with the order and the supplier&apos;s bill, and prepares the receipt and the bill for you to approve.</p>
          <label className="ops-sup-inline">
            Order
            <select value={chosen ?? ""} onChange={(e) => setOrderId(e.target.value === "" ? "" : Number(e.target.value))}>
              <option value="">No order: just read the note</option>
              {open.map((o) => (
                <option key={o.id} value={o.id}>PO-{o.id} · {o.supplierName ?? "No supplier"} · {currency(o.totalMinor, o.currency)}</option>
              ))}
            </select>
          </label>
          <UploadDrop
            api={api}
            tenant={tenant}
            purpose="deliveryNote"
            label="Drop the delivery note here, or choose a photo or PDF"
            disabled={busy}
            onReady={(mediaId) => read(mediaId)}
          />
          {busy && <p className="ops-note" role="status">Asking the supplies agent…</p>}
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
        <div className="ops-bo-stack">
          <Proposals api={api} tenant={tenant} inbox={inbox} commands={["stock.receive", "bill.match"]} onDone={refresh} />
        </div>
      </div>
      {matched.length > 1 && (
        <div className="ops-chips" role="group" aria-label="Checked deliveries">
          {matched.slice(0, 8).map((d) => (
            <button key={d.id} aria-pressed={shown?.id === d.id} onClick={() => setShownId(d.id)}>
              PO-{d.supplierOrderId} · {new Date(d.createdAt).toLocaleDateString([], { dateStyle: "medium" })}
            </button>
          ))}
        </div>
      )}
      {shown?.match ? (
        <MatchView delivery={shown} match={shown.match} code={shown.currency ?? currencyCode} />
      ) : (
        <p className="ops-quiet-note">{deliveries ? "No delivery checked against an order yet." : "Loading deliveries…"}</p>
      )}
    </>
  );
}

function MatchView({ delivery, match, code }: { delivery: Delivery; match: Match; code: string }) {
  return (
    <section className="ops-panel ops-bo-card ops-sup-match" aria-labelledby={`match-${delivery.id}`}>
      <span className="ops-eyebrow">3-way match · order, delivery note, bill</span>
      <h2 id={`match-${delivery.id}`}>
        PO-{match.supplierOrderId}
        {match.reference ? ` · note ${match.reference}` : ""}:{" "}
        {match.clean ? "everything agrees" : `${match.flagged} ${match.flagged === 1 ? "line differs" : "lines differ"}`}
      </h2>
      {match.explanation && (
        <p className="ops-sup-ai">
          <Icon name="agents" size={18} />
          <span><strong>Supplies agent: </strong>{match.explanation}</span>
        </p>
      )}
      <div className="ops-sup-table-wrap">
        <table className="ops-sup-table">
          <caption className="sr-only">Each line of the order against the delivery note and the bill</caption>
          <thead>
            <tr>
              <th scope="col">Item</th>
              <th scope="col">Ordered</th>
              <th scope="col">Arrived</th>
              <th scope="col">Order price</th>
              <th scope="col">Note price</th>
              <th scope="col">Bill price</th>
              <th scope="col">Check</th>
            </tr>
          </thead>
          <tbody>
            {match.lines.map((l) => (
              <tr key={l.name} className={l.flags.length ? "flagged" : ""}>
                <th scope="row">{l.name}</th>
                <td>{qty(l.orderedQty, l.unit)}</td>
                <td>{l.deliveredQty == null ? "None" : qty(l.deliveredQty, l.unit)}</td>
                <td>{l.orderedUnitMinor == null ? "" : currency(l.orderedUnitMinor, code)}</td>
                <td>{l.deliveredUnitMinor == null ? "" : currency(l.deliveredUnitMinor, code)}</td>
                <td>{l.billedUnitMinor == null ? "" : currency(l.billedUnitMinor, code)}</td>
                <td>
                  <span className="ops-sup-flags">
                    {l.flags.length === 0 ? <span className="ops-pill ok">Matches</span> : l.flags.map((f) => <span key={f} className={`ops-pill ${flagTone(f)}`}>{flagLabel(f)}</span>)}
                  </span>
                  <span className="ops-sup-why">{matchText(l, code)}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <dl className="ops-sup-totals">
        <div><dt>Ordered</dt><dd>{currency(match.orderedTotalMinor, code)}</dd></div>
        <div><dt>On the note</dt><dd>{currency(match.deliveredTotalMinor, code)}</dd></div>
        <div className={match.billDiffers ? "flagged" : ""}>
          <dt>Bill</dt>
          <dd>{match.billTotalMinor == null ? "No bill yet" : `${currency(match.billTotalMinor, code)}${match.billDiffers ? " (differs from the note)" : ""}`}</dd>
        </div>
        <div><dt>Bill state</dt><dd>{match.billState ? match.billState.replace(/([a-z])([A-Z])/g, "$1 $2") : "None"}</dd></div>
      </dl>
    </section>
  );
}

/* ---------- Suppliers ---------- */

function SuppliersTab({ sp, version }: TabProps) {
  const { data, error } = useLoad(() => sp.scorecards(), [sp, version]);
  const scatter = useMemo(() => source("suppliers", scorecardSource(data ?? [])), [data]);
  const pct = (v: unknown) => (v == null || v === "" ? "No orders yet" : `${Number(v).toFixed(1)}%`);
  const columns = useMemo<ColDef<Scorecard>[]>(
    () => [
      { field: "name", headerName: "Supplier", minWidth: 160, cellClass: "ops-cell-strong" },
      countCol<Scorecard>("Orders", "orders"),
      { field: "onTimePct", headerName: "On time", type: "rightAligned", cellClass: "ops-num", valueFormatter: (p) => pct(p.value), minWidth: 120 },
      { field: "fillRatePct", headerName: "Fill rate", type: "rightAligned", cellClass: "ops-num", valueFormatter: (p) => pct(p.value), minWidth: 120 },
      {
        field: "priceVariancePct",
        headerName: "Price change",
        type: "rightAligned",
        cellClass: (p) => `ops-num${Number(p.value) > 5 ? " ops-sup-up" : ""}`,
        valueFormatter: (p) => (p.value == null ? "" : `${Number(p.value) > 0 ? "+" : ""}${Number(p.value).toFixed(1)}%`),
        minWidth: 130,
      },
      countCol<Scorecard>("Lead days", "leadDays", { total: false }),
      boolCol<Scorecard>("Order email", "hasEmail", { labels: ["On file", "Missing"] }),
      boolCol<Scorecard>("PayPal", "hasPayPal", { labels: ["On file", "Missing"] }),
      dateCol<Scorecard>("Last order", "lastOrderAt", { dayOnly: true }),
    ],
    [],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <p className="ops-note">Each supplier over its received orders: how often it arrived on time, how much of what was ordered came, and how far prices moved from the order. Bottom right is best.</p>
      <StudioWidget label="Suppliers: on time against price change" source={scatter} widget={scatterWidget} height={340} />
      <RaystoGrid<Scorecard> label="Suppliers" rows={data} columns={columns} loading={!data && !error} emptyText="No supplier yet." getRowId={(p) => String(p.data.supplierId)} csvName="raysto-suppliers" />
    </>
  );
}

/* ---------- Recipes ---------- */

function RecipesTab({ sp, currencyCode, refresh, version }: TabProps) {
  const { data: recipes, error } = useLoad(() => sp.recipes(), [sp, version]);
  const { data: forecast } = useLoad(() => sp.forecast(), [sp, version]);
  const [openId, setOpenId] = useState<number>();
  const items = forecast?.rows ?? [];
  const opened = (recipes ?? []).find((r) => r.productId === openId);
  const code = forecast?.currency ?? currencyCode;
  const columns = useMemo<ColDef<Recipe>[]>(
    () => [
      { field: "name", headerName: "Dish", minWidth: 170, cellClass: "ops-cell-strong" },
      moneyCol<Recipe>("Price", "priceMinor", code, { total: false }),
      moneyCol<Recipe>("Portion cost", (r) => (r.lines.length ? portionCost(r) : null), code, { total: false }),
      {
        headerName: "Margin",
        valueGetter: (p) => (p.data && p.data.lines.length && p.data.priceMinor ? Math.round(((p.data.priceMinor - portionCost(p.data)) / p.data.priceMinor) * 100) : null),
        valueFormatter: (p) => (p.value == null ? "" : `${p.value}%`),
        type: "rightAligned",
        cellClass: "ops-num",
        minWidth: 110,
      },
      countCol<Recipe>("Ingredients", (r) => r.lines.length, { total: false }),
    ],
    [code],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <p className="ops-note">A recipe is what one portion uses. Each completed order then counts its dishes down from stock, so the forecast knows your real usage. Choose a dish to edit its recipe.</p>
      <RaystoGrid<Recipe>
        label="Recipes"
        rows={recipes}
        columns={columns}
        loading={!recipes && !error}
        emptyText="No dish on the menu yet."
        getRowId={(p) => String(p.data.productId)}
        onRowClicked={(e) => e.data && setOpenId(e.data.productId)}
        totals={false}
      />
      {opened && <RecipeEditor key={opened.productId} recipe={opened} items={items} sp={sp} code={code} onDone={refresh} onClose={() => setOpenId(undefined)} />}
    </>
  );
}

function RecipeEditor({ recipe, items, sp, code, onDone, onClose }: { recipe: Recipe; items: ForecastRow[]; sp: SuppliesApi; code: string; onDone: () => void; onClose: () => void }) {
  const { busy, note, act } = useAct(onDone);
  const initial = recipe.lines.map((l) => ({ stockItemId: l.stockItemId, quantity: String(l.quantity) }));
  const [lines, setLines] = useState(initial);
  const changed = JSON.stringify(lines) !== JSON.stringify(initial);
  const byId = new Map(items.map((i) => [i.stockItemId, i]));
  const unused = items.filter((i) => !lines.some((l) => l.stockItemId === i.stockItemId));
  const cost = lines.reduce((n, l) => n + Math.round((parseQty(l.quantity) ?? 0) * (byId.get(l.stockItemId)?.costMinor ?? 0)), 0);
  const valid = lines.every((l) => (parseQty(l.quantity) ?? 0) > 0);
  function save(e: FormEvent) {
    e.preventDefault();
    if (!valid) return;
    void act(async () => {
      await sp.saveRecipe(recipe.productId, lines.map((l) => ({ stockItemId: l.stockItemId, quantity: parseQty(l.quantity)! })));
      return `Recipe for ${recipe.name} saved. Completed orders now count it down from stock.`;
    });
  }
  return (
    <section className="ops-panel ops-bo-card ops-sup-order" aria-labelledby={`recipe-${recipe.productId}`}>
      <div className="ops-sup-order-head">
        <div>
          <span className="ops-eyebrow">Recipe · one portion</span>
          <h2 id={`recipe-${recipe.productId}`}>{recipe.name}</h2>
        </div>
        <button className="ops-secondary" onClick={onClose} aria-label={`Close the recipe for ${recipe.name}`}><Icon name="cross" size={18} />Close</button>
      </div>
      <form onSubmit={save}>
        {lines.length === 0 && <p className="ops-quiet-note">No ingredient yet.</p>}
        <ul className="ops-sup-lines">
          {lines.map((l, i) => {
            const item = byId.get(l.stockItemId);
            return (
              <li key={l.stockItemId}>
                <span className="ops-sup-line-name">{item?.name ?? `Item ${l.stockItemId}`}</span>
                <label>
                  <span className="sr-only">{item?.name}: quantity per portion in {item?.unit}</span>
                  <input inputMode="decimal" value={l.quantity} aria-invalid={(parseQty(l.quantity) ?? 0) <= 0} onChange={(e) => setLines(lines.map((x, j) => (j === i ? { ...x, quantity: e.target.value } : x)))} />
                </label>
                <span>{item?.unit}</span>
                <button type="button" className="ops-icon-button" aria-label={`Remove ${item?.name ?? "this ingredient"}`} onClick={() => setLines(lines.filter((_, j) => j !== i))}>
                  <Icon name="cross" size={18} />
                </button>
              </li>
            );
          })}
        </ul>
        {unused.length > 0 && (
          <label className="ops-sup-inline">
            Add an ingredient
            <select value="" onChange={(e) => e.target.value && setLines([...lines, { stockItemId: Number(e.target.value), quantity: "" }])}>
              <option value="">Choose a stock item</option>
              {unused.map((i) => (
                <option key={i.stockItemId} value={i.stockItemId}>{i.name} ({i.unit})</option>
              ))}
            </select>
          </label>
        )}
        <p className="ops-sup-total">Portion cost <strong>{currency(cost, code)}</strong> of {currency(recipe.priceMinor, code)}</p>
        <div className="ops-sup-actions">
          <button type="submit" className="ops-primary" disabled={busy || !changed || !valid}><Icon name="save" size={18} />Save the recipe</button>
          {changed && <button type="button" className="ops-secondary" onClick={() => setLines(initial)}>Undo changes</button>}
        </div>
      </form>
      {note && <p className="ops-note" role="status">{note}</p>}
    </section>
  );
}

/* ---------- Waste ---------- */

const reasonOf = (r: string) => wasteReasons.find(([k]) => k === r)?.[1] ?? r;

function WasteTab({ sp, currencyCode, refresh, version }: TabProps) {
  const { data, error } = useLoad(() => sp.forecast(), [sp, version]);
  const { busy, note, act } = useAct(refresh);
  const [form, setForm] = useState<{ stockItemId: string; quantity: string; reason: WasteReason }>({ stockItemId: "", quantity: "", reason: "spoiled" });
  const code = data?.currency ?? currencyCode;
  const items = data?.rows ?? [];
  const waste = data?.waste;
  const total = (waste ?? []).reduce((n, w) => n + w.valueMinor, 0);
  const columns = useMemo<ColDef<WasteEntry>[]>(
    () => [
      dateCol<WasteEntry>("When", "at", { sort: "desc" }),
      { field: "name", headerName: "Item", minWidth: 150, cellClass: "ops-cell-strong" },
      { headerName: "Quantity", valueGetter: (p) => p.data?.quantity, valueFormatter: (p) => qty(p.data?.quantity, p.data?.unit), type: "rightAligned", cellClass: "ops-num", minWidth: 110 },
      { field: "reason", headerName: "Why", valueFormatter: (p) => reasonOf(String(p.value ?? "")), minWidth: 140 },
      moneyCol<WasteEntry>("Value", "valueMinor", code),
    ],
    [code],
  );
  const item = items.find((i) => String(i.stockItemId) === form.stockItemId);
  const amount = parseQty(form.quantity);
  function submit(e: FormEvent) {
    e.preventDefault();
    if (!item || amount == null || amount <= 0) return;
    void act(async () => {
      await sp.waste(item.stockItemId, amount, form.reason);
      setForm({ ...form, quantity: "" });
      return `Recorded ${qty(amount, item.unit)} of ${item.name} as waste. The forecast counts it as usage.`;
    });
  }
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <Kpi label={`Waste, last ${data?.windowDays ?? 28} days`}><Cash minor={total} code={code} /></Kpi>
        <Kpi label="Entries"><Count n={waste?.length ?? 0} /></Kpi>
      </div>
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="sup-waste">
          <span className="ops-eyebrow">Waste</span>
          <h2 id="sup-waste">Record what was thrown away</h2>
          <p>Stock goes down and the forecast learns from it, so the planner orders less of what spoils.</p>
          <form className="ops-bo-form" onSubmit={submit}>
            <label>
              Item
              <select value={form.stockItemId} onChange={(e) => setForm({ ...form, stockItemId: e.target.value })} required>
                <option value="">Choose a stock item</option>
                {items.map((i) => (
                  <option key={i.stockItemId} value={i.stockItemId}>{i.name} ({qty(i.quantity, i.unit)} on hand)</option>
                ))}
              </select>
            </label>
            <label>
              Quantity{item ? ` (${item.unit})` : ""}
              <input inputMode="decimal" value={form.quantity} onChange={(e) => setForm({ ...form, quantity: e.target.value })} required aria-invalid={form.quantity !== "" && (amount == null || amount <= 0)} />
            </label>
            <label>
              Why
              <select value={form.reason} onChange={(e) => setForm({ ...form, reason: e.target.value as WasteReason })}>
                {wasteReasons.map(([k, label]) => (
                  <option key={k} value={k}>{label}</option>
                ))}
              </select>
            </label>
            {item && amount != null && amount > 0 && <p className="ops-note">Worth about {currency(Math.round(amount * item.costMinor), code)} at the last price.</p>}
            <button className="ops-primary" type="submit" disabled={busy || !item || amount == null || amount <= 0}><Icon name="plus" size={18} />Record the waste</button>
          </form>
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
      </div>
      <RaystoGrid<WasteEntry>
        label="Waste log"
        rows={waste}
        columns={columns}
        loading={!data && !error}
        emptyText="No waste recorded in the last 28 days."
        csvName="raysto-waste"
      />
    </>
  );
}

