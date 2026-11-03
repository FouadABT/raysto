"use client";
/**
 * Money: the café's back office. Each tab is one loop: an AI coworker
 * prepares the money matter with its evidence, the owner approves, PayPal
 * executes and its id is shown. Nothing here moves money by itself.
 */
import { useMemo, useState, type FormEvent, type ReactNode } from "react";
import { AgGridReact } from "ag-grid-react";
import type { ColDef } from "ag-grid-community";
import { ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { agentName, asRows, dayRange, type AgentActionRow, type OrderRow } from "@/lib/connected/business";
import {
  actionsFor,
  backoffice,
  barScale,
  batchTotal,
  closeDelta,
  closeSourceLabel,
  gapLabel,
  localDay,
  marginPercent,
  shiftHours,
  shiftPayMinor,
  weekRange,
  type Analytics,
  type CateringRequest,
  type Close,
  type Complaint,
  type CustomerProfile,
  type Dispute,
  type Expense,
  type PayoutBatch,
  type Shift,
} from "@/lib/connected/backoffice";
import { Icon } from "./icons";
import { AgentPanel, defaults, gridTheme, money, pill, time, useLoad, words } from "./business-sections";

export type MoneyTab = "close" | "pay" | "catering" | "refunds" | "expenses" | "customers" | "analytics";
const moneyTabs: [MoneyTab, string][] = [
  ["close", "Close the day"],
  ["pay", "Pay & tips"],
  ["catering", "Catering"],
  ["refunds", "Refunds & disputes"],
  ["expenses", "Expenses"],
  ["customers", "Customers"],
  ["analytics", "Analytics"],
];

const fail = (e: unknown) => String(e instanceof Error ? e.message : e);

/** One command with its busy state and outcome line. */
function useAct(onDone?: () => void) {
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  async function act(run: () => Promise<string | void>) {
    setBusy(true);
    setNote("");
    try {
      const said = await run();
      setNote(said ?? "Done.");
      onDone?.();
    } catch (e) {
      setNote(fail(e));
    } finally {
      setBusy(false);
    }
  }
  return { busy, note, act, setNote };
}

/**
 * A money action behind the identity check: the manager confirms again (a
 * password, or Google), the server records the step-up, then the command runs.
 * The judges' café keeps its published password ready so it is one tap.
 */
function StepUpAction({
  api,
  tenant,
  label,
  onRun,
  disabled,
}: {
  api: ConnectedApi;
  tenant: number;
  label: string;
  onRun: () => Promise<string | void>;
  disabled?: boolean;
}) {
  const known = isJudgeVenue(tenant) ? judge.password : "";
  const [asking, setAsking] = useState(false);
  const [password, setPassword] = useState(known);
  const [byPassword, setByPassword] = useState(true);
  const { busy, note, act } = useAct();
  async function start() {
    setByPassword(await usesPassword());
    setAsking(true);
  }
  function confirm(e: FormEvent) {
    e.preventDefault();
    void act(async () => {
      await stepUp(api, tenant, byPassword ? password : undefined);
      setAsking(false);
      setPassword(known);
      return onRun();
    });
  }
  return (
    <div className="ops-bo-stepup">
      {asking ? (
        <form onSubmit={confirm} className="ops-bo-form">
          {byPassword && (
            <label>
              Password
              <input type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required />
            </label>
          )}
          <button className="ops-primary" type="submit" disabled={busy}>
            {busy ? "Working…" : byPassword ? `Confirm and ${label.toLowerCase()}` : `Confirm with Google and ${label.toLowerCase()}`}
          </button>
        </form>
      ) : (
        <button className="ops-primary" disabled={disabled || busy} onClick={() => void start()}>
          <Icon name="paypal" size={18} />
          {label} (identity check)
        </button>
      )}
      {note && <p className="ops-note" role="status">{note}</p>}
    </div>
  );
}

/** The agent's proposals that belong to this tab, approved like any other. */
function Proposals({
  api,
  tenant,
  inbox,
  commands,
  onDone,
}: {
  api: ConnectedApi;
  tenant: number;
  inbox: AgentActionRow[];
  commands: string[];
  onDone: () => void;
}) {
  const mine = actionsFor(inbox, commands);
  if (mine.length === 0) return null;
  return (
    <div className="ops-bo-proposals">
      {mine.map((a) => (
        <section key={`${a.id}-${a.version}`} className="ops-panel ops-bo-card">
          <AgentPanel api={api} tenant={tenant} action={a} inline knownPassword={isJudgeVenue(tenant) ? judge.password : ""} onDone={onDone} />
        </section>
      ))}
    </div>
  );
}

function Empty({ children }: { children: ReactNode }) {
  return <p className="ops-quiet-note">{children}</p>;
}

export function MoneySection({
  api,
  tenant,
  revision,
  currencyCode,
  focus,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
  focus?: string;
}) {
  const [tab, setTab] = useState<MoneyTab>(moneyTabs.some(([t]) => t === focus) ? (focus as MoneyTab) : "close");
  const [tick, setTick] = useState(0);
  const bo = useMemo(() => backoffice(api, tenant), [api, tenant]);
  const { data: inbox, reload } = useLoad(() => bo.inbox(), [bo, revision, tick]);
  const refresh = () => {
    reload();
    setTick((n) => n + 1);
  };
  const props = { api, tenant, bo, currencyCode, inbox: inbox ?? [], refresh };
  const key = `${tab}-${tick}`;
  return (
    <div className="ops-business">
      <div className="ops-chips ops-bo-tabs" role="tablist" aria-label="Back office">
        {moneyTabs.map(([t, label]) => (
          <button key={t} role="tab" aria-selected={tab === t} aria-pressed={tab === t} onClick={() => setTab(t)}>{label}</button>
        ))}
      </div>
      {tab === "close" ? <CloseTab key={key} {...props} /> : tab === "pay" ? <PayTab key={key} {...props} /> : tab === "catering" ? <CateringTab key={key} {...props} /> : tab === "refunds" ? <RefundsTab key={key} {...props} /> : tab === "expenses" ? <ExpensesTab key={key} {...props} /> : tab === "customers" ? <CustomersTab key={key} {...props} /> : <AnalyticsTab key={key} {...props} />}
      <small className="ops-note">AI coworkers prepare the money matters; you approve; PayPal moves the money and its id is kept here.</small>
    </div>
  );
}

type TabProps = {
  api: ConnectedApi;
  tenant: number;
  bo: ReturnType<typeof backoffice>;
  currencyCode: string;
  inbox: AgentActionRow[];
  refresh: () => void;
};

/* ---------- Close the day ---------- */

function CloseTab({ api, tenant, bo, currencyCode, inbox, refresh }: TabProps) {
  const today = localDay(new Date());
  const { data, error, reload } = useLoad(async () => {
    const [current, past] = await Promise.all([bo.close(today), bo.closes()]);
    return { close: current.close, past };
  }, [bo]);
  const { busy, note, act } = useAct(() => {
    reload();
    refresh();
  });
  const c = data?.close;
  const code = c?.summary.currency ?? currencyCode;
  const delta = c ? closeDelta(c) : null;
  const columns = useMemo<ColDef<Close>[]>(
    () => [
      { field: "day", headerName: "Day", minWidth: 120, sort: "desc" },
      { headerName: "PayPal", type: "rightAligned", valueGetter: (p) => p.data?.summary.paypalCapturedMinor, valueFormatter: money(currencyCode) },
      { headerName: "Raysto", type: "rightAligned", valueGetter: (p) => p.data?.summary.raystoCapturedMinor, valueFormatter: money(currencyCode) },
      { headerName: "Cash", type: "rightAligned", valueGetter: (p) => p.data?.summary.cashMinor, valueFormatter: money(currencyCode) },
      { headerName: "Refunds", type: "rightAligned", valueGetter: (p) => p.data?.summary.refundsMinor, valueFormatter: money(currencyCode) },
      { headerName: "Gaps", valueGetter: (p) => p.data?.gaps.length ?? 0, flex: 0.5 },
      { field: "state", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 120 },
    ],
    [currencyCode],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="bo-close">
          <span className="ops-eyebrow">Daily close · {today}</span>
          <h2 id="bo-close">{c ? (c.state === "signed" ? "Signed off" : "Ready for your sign-off") : "Not closed yet"}</h2>
          {c ? (
            <>
              <p className="ops-note">PayPal read from {closeSourceLabel(c.source)}.</p>
              <dl className="ops-bo-figures">
                <dt>PayPal captured</dt><dd>{currency(c.summary.paypalCapturedMinor, code)}</dd>
                <dt>Raysto recorded</dt><dd>{currency(c.summary.raystoCapturedMinor, code)}</dd>
                <dt>Difference</dt>
                <dd className={delta?.matches ? "ok" : "warn"}>{delta?.matches ? "Matches" : currency(delta?.minor ?? 0, code)}</dd>
                <dt>Cash</dt><dd>{currency(c.summary.cashMinor, code)}</dd>
                <dt>Tips</dt><dd>{currency(c.summary.tipsMinor, code)}</dd>
                <dt>Refunds</dt><dd>{currency(c.summary.refundsMinor, code)}</dd>
                <dt>PayPal fees</dt><dd>{currency(c.summary.feesMinor, code)}</dd>
              </dl>
              <h3>{c.gaps.length ? `${c.gaps.length} ${c.gaps.length === 1 ? "gap" : "gaps"} explained` : "No gaps"}</h3>
              {c.gaps.length > 0 && (
                <ul className="ops-bo-gaps">
                  {c.gaps.map((g, i) => (
                    <li key={i}>
                      <span className="ops-pill warn">{gapLabel(g)}</span>
                      <strong>{currency(g.amountMinor, code)}</strong>
                      <p>{g.explanation}{g.proposedFix ? ` Proposed: ${g.proposedFix}` : ""}</p>
                    </li>
                  ))}
                </ul>
              )}
              {c.state !== "signed" && actionsFor(inbox, ["close.sign"]).length === 0 && (
                <button className="ops-primary" disabled={busy} onClick={() => void act(async () => { await api.command("close.sign", tenant, {}, { id: c.id, version: c.version }); return "Signed off."; })}>
                  <Icon name="check" size={18} />
                  Sign off the day
                </button>
              )}
              {c.state === "signed" && <p className="ops-try-done"><Icon name="check" size={18} />Signed{c.signedBy ? ` by ${c.signedBy}` : ""}.</p>}
            </>
          ) : (
            <p>The close agent matches PayPal's transactions to the till and the kitchen, explains each gap and prepares the sign-off.</p>
          )}
          <div className="ops-try-actions">
            <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("close.run", tenant, { day: today }); return "The close agent is reading PayPal. Refresh in a few seconds."; })}>
              <Icon name="refresh" size={18} />
              {c ? "Run the close again" : "Run the close"}
            </button>
          </div>
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["close.sign"]} onDone={() => { reload(); refresh(); }} />
      </div>
      <h2 className="ops-section-title">Past closes</h2>
      <div className="ops-grid">
        <AgGridReact<Close> theme={gridTheme} rowData={data?.past ?? []} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} overlayNoRowsTemplate="No day has been closed yet." />
      </div>
    </>
  );
}

/* ---------- Pay & tips ---------- */

function PayTab({ api, tenant, bo, currencyCode, inbox, refresh }: TabProps) {
  const week = useMemo(() => weekRange(new Date()), []);
  const { data, error, reload } = useLoad(async () => {
    const [shifts, payouts] = await Promise.all([bo.shifts(week.from, week.to), bo.payouts()]);
    return { shifts, payouts };
  }, [bo, week]);
  const { busy, note, act } = useAct(() => {
    reload();
    refresh();
  });
  const hours = (data?.shifts ?? []).reduce((n, s) => n + shiftHours(s), 0);
  const wages = (data?.shifts ?? []).reduce((n, s) => n + shiftPayMinor(s), 0);
  const proposed = (data?.payouts ?? []).filter((b) => b.state === "proposed");
  const columns = useMemo<ColDef<PayoutBatch>[]>(
    () => [
      { field: "createdAt", headerName: "Prepared", valueFormatter: (p) => time(p.value), sort: "desc", minWidth: 150 },
      { field: "kind", valueFormatter: (p) => words(p.value), flex: 0.6 },
      { headerName: "Period", valueGetter: (p) => `${String(p.data?.periodFrom ?? "").slice(0, 10)} → ${String(p.data?.periodTo ?? "").slice(0, 10)}`, minWidth: 190 },
      { headerName: "People", valueGetter: (p) => p.data?.items.length ?? 0, flex: 0.5 },
      { field: "totalMinor", headerName: "Total", type: "rightAligned", valueFormatter: money(currencyCode) },
      { field: "state", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 120 },
      { field: "providerBatchId", headerName: "PayPal batch id", minWidth: 170 },
    ],
    [currencyCode],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <div className="ops-kpi"><span>Hours this week</span><strong>{hours.toFixed(2)}</strong></div>
        <div className="ops-kpi"><span>Wages so far</span><strong>{currency(wages, currencyCode)}</strong></div>
        <div className="ops-kpi"><span>Shifts</span><strong>{data?.shifts.length ?? 0}</strong></div>
        <div className={`ops-kpi ${proposed.length ? "alert" : ""}`}><span>Payouts waiting</span><strong>{proposed.length}</strong></div>
      </div>
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="bo-pay">
          <span className="ops-eyebrow">Pay run</span>
          <h2 id="bo-pay">{proposed.length ? "A payout batch is ready" : "Pay the team through PayPal"}</h2>
          {proposed.length === 0 && <p>The payroll agent counts the hours, splits the tip pool by hours and role, and prepares one PayPal Payouts batch for you to send.</p>}
          {proposed.map((b) => (
            <div key={b.id} className="ops-bo-batch">
              <strong>{words(b.kind)} · {currency(b.totalMinor, b.currency)}</strong>
              <small>{String(b.periodFrom).slice(0, 10)} → {String(b.periodTo).slice(0, 10)}</small>
              <ul className="ops-payments">
                {b.items.map((i, n) => (
                  <li key={n}>
                    <strong>{i.recipientName} · {currency(i.amountMinor, b.currency)}</strong>
                    {i.note && <span>{i.note}</span>}
                  </li>
                ))}
              </ul>
              {batchTotal(b) !== b.totalMinor && <p className="ops-error" role="alert">The lines do not add up to the batch total.</p>}
              {actionsFor(inbox, ["payout.send"]).some((a) => Number((a.preview as Json)?.batchId) === b.id) ? null : (
                <StepUpAction api={api} tenant={tenant} label="Send with PayPal" onRun={async () => {
                  const r = await api.command<Json>("payout.send", tenant, {}, { id: b.id, version: b.version });
                  reload();
                  refresh();
                  return `Sent. PayPal batch ${String(r.providerBatchId ?? "")}.`;
                }} />
              )}
            </div>
          ))}
          <div className="ops-try-actions">
            <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("payroll.run", tenant, { from: week.from, to: week.to }); return "The payroll agent is working out the pay. Refresh in a few seconds."; })}>
              <Icon name="refresh" size={18} />
              Run pay for this week
            </button>
          </div>
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["payout.send"]} onDone={() => { reload(); refresh(); }} />
      </div>
      <h2 className="ops-section-title">Payouts</h2>
      <div className="ops-grid">
        <AgGridReact<PayoutBatch> theme={gridTheme} rowData={data?.payouts ?? []} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} overlayNoRowsTemplate="No payout yet. Run pay to prepare one." />
      </div>
    </>
  );
}

/* ---------- Catering ---------- */

function CateringTab({ api, tenant, bo, currencyCode, inbox, refresh }: TabProps) {
  const { data, error, reload } = useLoad(() => bo.catering(), [bo]);
  const [selected, setSelected] = useState<number>();
  const [form, setForm] = useState({ customerName: "", customerEmail: "", text: "", eventAt: "" });
  const { busy, note, act } = useAct(() => {
    reload();
    refresh();
  });
  const rows = data ?? [];
  const r = rows.find((x) => x.id === selected) ?? rows.find((x) => x.status !== "paid" && x.status !== "cancelled");
  const columns = useMemo<ColDef<CateringRequest>[]>(
    () => [
      { field: "customerName", headerName: "Customer", minWidth: 140, cellClass: "ops-cell-strong" },
      { field: "text", headerName: "Request", flex: 2, minWidth: 220, tooltipField: "text" },
      { field: "eventAt", headerName: "Event", valueFormatter: (p) => time(p.value), minWidth: 150 },
      { field: "totalMinor", headerName: "Quote", type: "rightAligned", valueFormatter: money(currencyCode) },
      { field: "status", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 120 },
      { field: "invoiceNumber", headerName: "PayPal invoice", minWidth: 150 },
    ],
    [currencyCode],
  );
  function submit(e: FormEvent) {
    e.preventDefault();
    void act(async () => {
      await api.command("catering.request", tenant, {
        customerName: form.customerName,
        customerEmail: form.customerEmail,
        text: form.text,
        ...(form.eventAt ? { eventAt: new Date(form.eventAt).toISOString() } : {}),
      });
      setForm({ customerName: "", customerEmail: "", text: "", eventAt: "" });
      return "The catering agent is pricing it from the menu. Refresh in a few seconds.";
    });
  }
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="bo-catering">
          <span className="ops-eyebrow">New request</span>
          <h2 id="bo-catering">Bill a catering order with a PayPal invoice</h2>
          <p>Write what the customer asked for. The catering agent prices it from the menu, sets a deposit and drafts the PayPal invoice; nothing is sent until you approve.</p>
          <form className="ops-bo-form" onSubmit={submit}>
            <label>Customer name<input value={form.customerName} onChange={(e) => setForm({ ...form, customerName: e.target.value })} required maxLength={80} /></label>
            <label>Customer email<input type="email" value={form.customerEmail} onChange={(e) => setForm({ ...form, customerEmail: e.target.value })} required /></label>
            <label className="wide">The request<textarea value={form.text} onChange={(e) => setForm({ ...form, text: e.target.value })} required maxLength={600} placeholder="Lunch for 12 on Friday at noon: sandwiches, two salads and coffee, around $150" /></label>
            <label>Event date and time<input type="datetime-local" value={form.eventAt} onChange={(e) => setForm({ ...form, eventAt: e.target.value })} /></label>
            <button className="ops-primary" type="submit" disabled={busy}><Icon name="invoice" size={18} />Ask the catering agent</button>
          </form>
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
        {r && (
          <section className="ops-panel ops-bo-card" aria-label="Catering request">
            <span className="ops-eyebrow">{words(r.status)} · {r.customerName}</span>
            <h2>{r.totalMinor ? currency(r.totalMinor, r.currency || currencyCode) : "Being priced"}</h2>
            <p>{r.text}</p>
            {r.quote?.lines && r.quote.lines.length > 0 && (
              <ul className="ops-lines">
                {r.quote.lines.map((l, i) => (
                  <li key={i}><span>{l.quantity}× {l.name}</span><small>{currency(l.unitMinor * l.quantity, r.currency || currencyCode)}</small></li>
                ))}
              </ul>
            )}
            <dl className="ops-bo-figures">
              {r.eventAt && <><dt>Event</dt><dd>{time(r.eventAt)}</dd></>}
              {r.depositMinor > 0 && <><dt>Deposit</dt><dd>{currency(r.depositMinor, r.currency || currencyCode)}</dd></>}
              {r.dueAt && <><dt>Due</dt><dd>{time(r.dueAt)}</dd></>}
              {r.invoiceNumber && <><dt>PayPal invoice</dt><dd><code>{r.invoiceNumber}</code></dd></>}
              {r.providerInvoiceId && <><dt>Invoice id</dt><dd><code>{r.providerInvoiceId}</code></dd></>}
              {r.remindedAt && <><dt>Reminded</dt><dd>{time(r.remindedAt)}</dd></>}
            </dl>
            {r.qrUrl && <img className="ops-bo-qr" src={r.qrUrl} alt="PayPal invoice QR code" width={160} height={160} />}
            {r.status === "quoted" && actionsFor(inbox, ["invoice.send"]).length === 0 && (
              <StepUpAction api={api} tenant={tenant} label="Send the invoice" onRun={async () => {
                const x = await api.command<Json>("invoice.send", tenant, {}, { id: r.id, version: r.version });
                reload();
                refresh();
                return `Sent. PayPal invoice ${String(x.invoiceNumber ?? x.providerInvoiceId ?? "")}.`;
              }} />
            )}
            {r.status === "sent" && (
              <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("invoice.remind", tenant, {}, { id: r.id, version: r.version }); return "Reminder sent through PayPal."; })}>
                <Icon name="bell" size={18} />Send a reminder
              </button>
            )}
            {r.status === "paid" && <p className="ops-try-done"><Icon name="check" size={18} />Paid on PayPal. The kitchen has the order.</p>}
          </section>
        )}
      </div>
      <Proposals api={api} tenant={tenant} inbox={inbox} commands={["invoice.send", "invoice.remind"]} onDone={() => { reload(); refresh(); }} />
      <h2 className="ops-section-title">Requests</h2>
      <div className="ops-grid">
        <AgGridReact<CateringRequest> theme={gridTheme} rowData={rows} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} onRowClicked={(e) => e.data && setSelected(e.data.id)} rowSelection={{ mode: "singleRow", checkboxes: false, enableClickSelection: true }} overlayNoRowsTemplate="No catering request yet." tooltipShowDelay={300} />
      </div>
    </>
  );
}

/* ---------- Refunds & disputes ---------- */

function RefundsTab({ api, tenant, bo, currencyCode, inbox, refresh }: TabProps) {
  const { data, error, reload } = useLoad(async () => {
    const [complaints, disputes, orders] = await Promise.all([
      bo.complaints(),
      bo.disputes(),
      api.query<Json>("orders", { restaurantId: tenant, staff: true, order: "desc", limit: 30 }).then(asRows<OrderRow>).catch(() => [] as OrderRow[]),
    ]);
    return { complaints, disputes, orders };
  }, [bo]);
  const [form, setForm] = useState({ orderId: "", text: "" });
  const { busy, note, act } = useAct(() => {
    reload();
    refresh();
  });
  const complaintColumns = useMemo<ColDef<Complaint>[]>(
    () => [
      { headerName: "Order", valueGetter: (p) => `Order ${p.data?.orderId}`, flex: 0.6, cellClass: "ops-cell-strong" },
      { field: "text", headerName: "Complaint", flex: 2, minWidth: 220, tooltipField: "text" },
      { headerName: "Agent proposes", valueGetter: (p) => (p.data?.proposal ? `${words(p.data.proposal.kind)} · ${currency(p.data.proposal.amountMinor, currencyCode)}` : ""), minWidth: 170 },
      { field: "status", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 120 },
      { field: "providerRefundId", headerName: "PayPal refund id", minWidth: 170 },
      { field: "createdAt", headerName: "Opened", valueFormatter: (p) => time(p.value), sort: "desc", minWidth: 150 },
    ],
    [currencyCode],
  );
  const disputeColumns = useMemo<ColDef<Dispute>[]>(
    () => [
      { field: "providerDisputeId", headerName: "PayPal dispute", minWidth: 170, cellClass: "ops-cell-strong" },
      { field: "reason", valueFormatter: (p) => words(p.value), minWidth: 160 },
      { field: "amountMinor", headerName: "Amount", type: "rightAligned", valueFormatter: money(currencyCode) },
      { field: "status", valueFormatter: (p) => words(p.value), cellRenderer: pill, minWidth: 130 },
      { field: "replyText", headerName: "Draft reply", flex: 2, minWidth: 220, tooltipField: "replyText" },
      { field: "createdAt", headerName: "Opened", valueFormatter: (p) => time(p.value), sort: "desc", minWidth: 150 },
    ],
    [currencyCode],
  );
  function submit(e: FormEvent) {
    e.preventDefault();
    void act(async () => {
      await api.command("complaint.open", tenant, { orderId: Number(form.orderId), text: form.text });
      setForm({ orderId: "", text: "" });
      return "The complaints agent is checking the ticket and PayPal's capture. Refresh in a few seconds.";
    });
  }
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="bo-complaint">
          <span className="ops-eyebrow">Complaint</span>
          <h2 id="bo-complaint">Settle a complaint with a PayPal refund</h2>
          <p>The complaints agent reads the kitchen ticket and PayPal's own record of the capture, then proposes a full refund, a partial one or none, with its reasons. A refund needs your identity check.</p>
          <form className="ops-bo-form" onSubmit={submit}>
            <label>
              Order
              <select value={form.orderId} onChange={(e) => setForm({ ...form, orderId: e.target.value })} required>
                <option value="">Choose an order</option>
                {(data?.orders ?? []).map((o) => (
                  <option key={o.id} value={o.id}>{o.number ? `#${o.number}` : `Order ${o.id}`} · {currency(o.totalMinor, o.currency)} · {words(o.paymentStatus)}</option>
                ))}
              </select>
            </label>
            <label className="wide">What went wrong<textarea value={form.text} onChange={(e) => setForm({ ...form, text: e.target.value })} required maxLength={600} placeholder="The croissant was missing from the bag" /></label>
            <button className="ops-primary" type="submit" disabled={busy}><Icon name="receipt" size={18} />Ask the complaints agent</button>
          </form>
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["payment.refund", "dispute.accept"]} onDone={() => { reload(); refresh(); }} />
      </div>
      <h2 className="ops-section-title">Complaints</h2>
      <div className="ops-grid">
        <AgGridReact<Complaint> theme={gridTheme} rowData={data?.complaints ?? []} loading={!data && !error} columnDefs={complaintColumns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} overlayNoRowsTemplate="No complaint. Good." tooltipShowDelay={300} />
      </div>
      <div className="ops-bo-toolbar">
        <h2 className="ops-section-title">PayPal disputes</h2>
        <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("dispute.sweep", tenant, {}); return "Asking PayPal for open disputes through the MCP server."; })}>
          <Icon name="paypal" size={18} />Check PayPal for disputes
        </button>
      </div>
      <div className="ops-grid">
        <AgGridReact<Dispute> theme={gridTheme} rowData={data?.disputes ?? []} loading={!data && !error} columnDefs={disputeColumns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} overlayNoRowsTemplate="No dispute on PayPal." tooltipShowDelay={300} />
      </div>
    </>
  );
}

/* ---------- Expenses ---------- */

const expenseCategories = ["Ingredients", "Drinks", "Packaging", "Rent", "Utilities", "Equipment", "Marketing", "Other"];

function ExpensesTab({ api, tenant, bo, currencyCode, inbox, refresh }: TabProps) {
  const month = useMemo(() => dayRange(new Date(), 29), []);
  const { data, error, reload } = useLoad(() => bo.expenses(month.from, month.until), [bo, month]);
  const [form, setForm] = useState({ merchant: "", category: "Ingredients", amount: "", vat: "", spentAt: localDay(new Date()) });
  const { busy, note, act } = useAct(() => {
    reload();
    refresh();
  });
  const total = (data ?? []).reduce((n, e) => n + e.amountMinor, 0);
  const columns = useMemo<ColDef<Expense>[]>(
    () => [
      { field: "spentAt", headerName: "Date", valueFormatter: (p) => String(p.value ?? "").slice(0, 10), sort: "desc", minWidth: 120 },
      { field: "merchant", minWidth: 160, cellClass: "ops-cell-strong" },
      { field: "category", minWidth: 130 },
      { field: "amountMinor", headerName: "Amount", type: "rightAligned", valueFormatter: money(currencyCode) },
      { field: "vatMinor", headerName: "VAT", type: "rightAligned", valueFormatter: money(currencyCode) },
      { field: "paypalTransactionId", headerName: "In PayPal as", minWidth: 170 },
    ],
    [currencyCode],
  );
  function submit(e: FormEvent) {
    e.preventDefault();
    void act(async () => {
      await api.command("expense.record", tenant, {
        merchant: form.merchant,
        category: form.category,
        amountMinor: Math.round(Number(form.amount) * 100),
        ...(form.vat ? { vatMinor: Math.round(Number(form.vat) * 100) } : {}),
        spentAt: new Date(form.spentAt).toISOString(),
      });
      setForm({ ...form, merchant: "", amount: "", vat: "" });
      return "Recorded. The close will match it against PayPal's transactions.";
    });
  }
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <div className="ops-kpi"><span>Last 30 days</span><strong>{currency(total, currencyCode)}</strong></div>
        <div className="ops-kpi"><span>Entries</span><strong>{data?.length ?? 0}</strong></div>
        <div className="ops-kpi"><span>Matched in PayPal</span><strong>{(data ?? []).filter((e) => e.paypalTransactionId).length}</strong></div>
      </div>
      <div className="ops-bo-split">
        <section className="ops-panel ops-bo-card" aria-labelledby="bo-expense">
          <span className="ops-eyebrow">Expense</span>
          <h2 id="bo-expense">Record what the café spent</h2>
          <p>Photographed receipts come in through the Raysto app, where the expenses agent reads them. Here you can add one by hand; the close matches every expense against PayPal's transactions.</p>
          <form className="ops-bo-form" onSubmit={submit}>
            <label>Merchant<input value={form.merchant} onChange={(e) => setForm({ ...form, merchant: e.target.value })} required maxLength={80} /></label>
            <label>Category<select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })}>{expenseCategories.map((c) => <option key={c}>{c}</option>)}</select></label>
            <label>Amount<input type="number" inputMode="decimal" min="0.01" step="0.01" value={form.amount} onChange={(e) => setForm({ ...form, amount: e.target.value })} required /></label>
            <label>VAT (optional)<input type="number" inputMode="decimal" min="0" step="0.01" value={form.vat} onChange={(e) => setForm({ ...form, vat: e.target.value })} /></label>
            <label>Date<input type="date" value={form.spentAt} onChange={(e) => setForm({ ...form, spentAt: e.target.value })} required /></label>
            <button className="ops-primary" type="submit" disabled={busy}><Icon name="plus" size={18} />Record the expense</button>
          </form>
          {note && <p className="ops-note" role="status">{note}</p>}
        </section>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["expense.record", "stock.receive"]} onDone={() => { reload(); refresh(); }} />
      </div>
      <div className="ops-grid">
        <AgGridReact<Expense> theme={gridTheme} rowData={data ?? []} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} overlayNoRowsTemplate="No expense recorded in the last 30 days." />
      </div>
    </>
  );
}

/* ---------- Customers ---------- */

function CustomersTab({ api, tenant, bo, currencyCode, inbox, refresh }: TabProps) {
  const { data, error, reload } = useLoad(() => bo.customers(), [bo]);
  const { busy, note, act } = useAct(() => {
    reload();
    refresh();
  });
  const columns = useMemo<ColDef<CustomerProfile>[]>(
    () => [
      { field: "displayName", headerName: "Customer", minWidth: 160, cellClass: "ops-cell-strong" },
      { field: "visits", type: "rightAligned", flex: 0.5 },
      { field: "spentMinor", headerName: "Spent", type: "rightAligned", valueFormatter: money(currencyCode) },
      { field: "lastSeenAt", headerName: "Last seen", valueFormatter: (p) => time(p.value), sort: "desc", minWidth: 150 },
      { headerName: "Tags", valueGetter: (p) => (p.data?.tags ?? []).map(words).join(", "), minWidth: 160 },
      { field: "couponCode", headerName: "Coupon", minWidth: 130 },
    ],
    [currencyCode],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-toolbar">
        <p className="ops-note">Regulars and lapsing customers, from the orders PayPal paid. The loyalty agent proposes a coupon and what it will cost; the coupon is redeemed at PayPal checkout.</p>
        <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("loyalty.run", tenant, {}); return "The loyalty agent is reading the regulars. Refresh in a few seconds."; })}>
          <Icon name="agents" size={18} />Find who to win back
        </button>
      </div>
      {note && <p className="ops-note" role="status">{note}</p>}
      <Proposals api={api} tenant={tenant} inbox={inbox} commands={["coupon.create"]} onDone={() => { reload(); refresh(); }} />
      <div className="ops-grid">
        <AgGridReact<CustomerProfile> theme={gridTheme} rowData={data ?? []} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} overlayNoRowsTemplate="No customer profile yet. They appear as PayPal orders are paid." />
      </div>
    </>
  );
}

/* ---------- Analytics ---------- */

function Bars({ values, labels, format, title }: { values: number[]; labels: string[]; format: (v: number) => string; title: string }) {
  const scale = barScale(values);
  if (values.length === 0) return <Empty>No sales in this period yet.</Empty>;
  return (
    <figure className="ops-bo-chart" aria-label={title}>
      <svg viewBox={`0 0 ${values.length * 28} 120`} preserveAspectRatio="none" role="img">
        {scale.map((h, i) => (
          <rect key={i} x={i * 28 + 4} y={110 - h * 100} width={20} height={h * 100} rx={3} className="ops-bo-bar">
            <title>{labels[i]}: {format(values[i])}</title>
          </rect>
        ))}
      </svg>
      <figcaption>
        {labels.map((l, i) => (
          <span key={i}>{l}</span>
        ))}
      </figcaption>
    </figure>
  );
}

function AnalyticsTab({ bo, currencyCode }: TabProps) {
  const [days, setDays] = useState(7);
  const range = useMemo(() => dayRange(new Date(), days - 1), [days]);
  const { data, error } = useLoad(() => bo.analytics(range.from, range.until), [bo, range]);
  const code = data?.currency ?? currencyCode;
  const fmt = (v: number) => currency(v, code);
  const columns = useMemo<ColDef<Analytics["marginByDish"][number]>[]>(
    () => [
      { field: "name", headerName: "Dish", minWidth: 180, cellClass: "ops-cell-strong" },
      { field: "priceMinor", headerName: "Price", type: "rightAligned", valueFormatter: money(code) },
      { field: "costMinor", headerName: "Cost", type: "rightAligned", valueFormatter: money(code) },
      { headerName: "Margin", type: "rightAligned", valueGetter: (p) => (p.data ? marginPercent(p.data) : null), valueFormatter: (p) => (p.value == null ? "—" : `${p.value}%`), sort: "asc" },
    ],
    [code],
  );
  const sales = (data?.byHour ?? []).reduce((n, h) => n + h.salesMinor, 0);
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-chips" role="group" aria-label="Period">
        {[7, 30].map((d) => (
          <button key={d} aria-pressed={days === d} onClick={() => setDays(d)}>{d === 7 ? "7 days" : "30 days"}</button>
        ))}
      </div>
      <div className="ops-kpis">
        <div className="ops-kpi"><span>Sales</span><strong>{fmt(sales)}</strong></div>
        <div className="ops-kpi"><span>PayPal fees</span><strong>{fmt(data?.feesMinor ?? 0)}</strong></div>
        <div className="ops-kpi"><span>Refunds</span><strong>{fmt(data?.refundsMinor ?? 0)}</strong></div>
        <div className="ops-kpi"><span>Tips</span><strong>{fmt(data?.tipsMinor ?? 0)}</strong></div>
        <div className="ops-kpi"><span>Staff cost</span><strong>{fmt(data?.staffCostMinor ?? 0)}</strong></div>
        <div className="ops-kpi"><span>Expenses</span><strong>{fmt(data?.expensesMinor ?? 0)}</strong></div>
      </div>
      <div className="ops-bo-split">
        <section className="ops-panel">
          <h2>Sales by hour</h2>
          <Bars title="Sales by hour" values={(data?.byHour ?? []).map((h) => h.salesMinor)} labels={(data?.byHour ?? []).map((h) => `${h.hour}h`)} format={fmt} />
        </section>
        <section className="ops-panel">
          <h2>Sales by channel</h2>
          <Bars title="Sales by channel" values={(data?.byChannel ?? []).map((c) => c.salesMinor)} labels={(data?.byChannel ?? []).map((c) => c.channel)} format={fmt} />
        </section>
      </div>
      <h2 className="ops-section-title">Margin per dish</h2>
      <p className="ops-note">Price against the ingredient cost from the stock the supplies agent reads off delivery notes. Lowest margin first.</p>
      <div className="ops-grid">
        <AgGridReact theme={gridTheme} rowData={data?.marginByDish ?? []} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} overlayNoRowsTemplate="No cost known yet. Costs come from delivery notes the supplies agent reads." />
      </div>
    </>
  );
}

/* ---------- Team ---------- */

export function TeamSection({
  api,
  tenant,
  revision,
  currencyCode,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
}) {
  const bo = useMemo(() => backoffice(api, tenant), [api, tenant]);
  const [offset, setOffset] = useState(0);
  const week = useMemo(() => {
    const d = new Date();
    d.setDate(d.getDate() + offset * 7);
    return weekRange(d);
  }, [offset]);
  const { data, error, reload } = useLoad(async () => {
    const [shifts, inbox] = await Promise.all([bo.shifts(week.from, week.to), bo.inbox()]);
    return { shifts, inbox };
  }, [bo, week, revision]);
  const [editing, setEditing] = useState<Partial<Shift> | null>(null);
  const { busy, note, act } = useAct(reload);
  const shifts = data?.shifts ?? [];
  const hours = shifts.reduce((n, s) => n + shiftHours(s), 0);
  const onShift = shifts.filter((s) => s.clockInAt && !s.clockOutAt).length;
  const columns = useMemo<ColDef<Shift>[]>(
    () => [
      { field: "name", minWidth: 140, cellClass: "ops-cell-strong" },
      { field: "role", valueFormatter: (p) => words(p.value), minWidth: 110 },
      { field: "startsAt", headerName: "Starts", valueFormatter: (p) => time(p.value), sort: "asc", minWidth: 140 },
      { field: "endsAt", headerName: "Ends", valueFormatter: (p) => time(p.value), minWidth: 140 },
      { headerName: "Hours", type: "rightAligned", valueGetter: (p) => (p.data ? shiftHours(p.data) : 0), valueFormatter: (p) => Number(p.value).toFixed(2), flex: 0.5 },
      { headerName: "Pay", type: "rightAligned", valueGetter: (p) => (p.data ? shiftPayMinor(p.data) : 0), valueFormatter: money(currencyCode), flex: 0.6, minWidth: 90 },
      { headerName: "State", valueGetter: (p) => (p.data ? (p.data.clockOutAt ? "done" : p.data.clockInAt ? "onShift" : new Date(p.data.endsAt) < new Date() ? "missed" : "planned") : ""), valueFormatter: (p) => (p.value === "onShift" ? "On shift" : words(p.value)), cellRenderer: pill, minWidth: 110 },
    ],
    [currencyCode],
  );
  const local = (iso?: string | null) => (iso ? new Date(iso).toISOString().slice(0, 16) : "");
  function save(e: FormEvent) {
    e.preventDefault();
    if (!editing) return;
    void act(async () => {
      await api.command(
        "shift.save",
        tenant,
        {
          name: editing.name,
          role: editing.role ?? "staff",
          startsAt: new Date(String(editing.startsAt)).toISOString(),
          endsAt: new Date(String(editing.endsAt)).toISOString(),
          hourlyRateMinor: Number(editing.hourlyRateMinor ?? 0),
          ...(editing.payoutEmail ? { payoutEmail: editing.payoutEmail } : {}),
        },
        editing.id ? { id: editing.id, version: editing.version } : {},
      );
      setEditing(null);
      return "Shift saved.";
    });
  }
  return (
    <div className="ops-business">
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <div className="ops-kpi"><span>On shift now</span><strong>{onShift}</strong></div>
        <div className="ops-kpi"><span>Shifts this week</span><strong>{shifts.length}</strong></div>
        <div className="ops-kpi"><span>Hours</span><strong>{hours.toFixed(2)}</strong></div>
        <div className="ops-kpi"><span>Wages</span><strong>{currency(shifts.reduce((n, s) => n + shiftPayMinor(s), 0), currencyCode)}</strong></div>
      </div>
      <div className="ops-bo-toolbar">
        <div className="ops-chips" role="group" aria-label="Week">
          <button onClick={() => setOffset(offset - 1)}>Previous week</button>
          <button aria-pressed={offset === 0} onClick={() => setOffset(0)}>This week</button>
          <button onClick={() => setOffset(offset + 1)}>Next week</button>
          <small>{week.from.slice(0, 10)} → {week.to.slice(0, 10)}</small>
        </div>
        <button className="ops-primary" onClick={() => setEditing({ role: "staff", startsAt: `${localDay(new Date())}T09:00`, endsAt: `${localDay(new Date())}T17:00`, hourlyRateMinor: 1500 })}>
          <Icon name="plus" size={18} />Add a shift
        </button>
      </div>
      <div className="ops-business with-panel">
        <div className="ops-grid tall">
          <AgGridReact<Shift> theme={gridTheme} rowData={shifts} loading={!data && !error} columnDefs={columns} defaultColDef={defaults} getRowId={(p) => String(p.data.id)} onRowClicked={(e) => e.data && setEditing({ ...e.data, startsAt: local(e.data.startsAt), endsAt: local(e.data.endsAt) })} rowSelection={{ mode: "singleRow", checkboxes: false, enableClickSelection: true }} overlayNoRowsTemplate="No shift this week. Add one, or let the copilot plan the roster." />
        </div>
        <aside className="ops-side">
          {editing ? (
            <form className="ops-bo-form" onSubmit={save}>
              <span className="ops-eyebrow">{editing.id ? "Edit shift" : "New shift"}</span>
              <label>Name<input value={editing.name ?? ""} onChange={(e) => setEditing({ ...editing, name: e.target.value })} required maxLength={60} /></label>
              <label>Role<select value={editing.role ?? "staff"} onChange={(e) => setEditing({ ...editing, role: e.target.value })}>{["staff", "kitchen", "manager", "courier"].map((r) => <option key={r} value={r}>{words(r)}</option>)}</select></label>
              <label>Starts<input type="datetime-local" value={String(editing.startsAt ?? "")} onChange={(e) => setEditing({ ...editing, startsAt: e.target.value })} required /></label>
              <label>Ends<input type="datetime-local" value={String(editing.endsAt ?? "")} onChange={(e) => setEditing({ ...editing, endsAt: e.target.value })} required /></label>
              <label>Hourly rate<input type="number" inputMode="decimal" min="0" step="0.01" value={((editing.hourlyRateMinor ?? 0) / 100).toFixed(2)} onChange={(e) => setEditing({ ...editing, hourlyRateMinor: Math.round(Number(e.target.value) * 100) })} required /></label>
              <label>PayPal email for payouts<input type="email" value={editing.payoutEmail ?? ""} onChange={(e) => setEditing({ ...editing, payoutEmail: e.target.value })} /></label>
              {editing.id && !editing.clockOutAt && (
                <button type="button" className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("shift.clock", tenant, { action: editing.clockInAt ? "out" : "in" }, { id: editing.id, version: editing.version }); setEditing(null); return editing.clockInAt ? "Clocked out." : "Clocked in."; })}>
                  <Icon name="clock" size={18} />{editing.clockInAt ? "Clock out" : "Clock in"}
                </button>
              )}
              <button className="ops-primary" type="submit" disabled={busy}>{busy ? "Saving…" : "Save shift"}</button>
              <button type="button" className="ops-secondary" onClick={() => setEditing(null)}>Cancel</button>
              {note && <p className="ops-note" role="status">{note}</p>}
            </form>
          ) : (
            <div className="ops-order">
              <span className="ops-eyebrow">Clock</span>
              <h2>Who is in</h2>
              {shifts.filter((s) => !s.clockOutAt).length === 0 ? (
                <p className="ops-note">Nobody is on a shift right now.</p>
              ) : (
                <ul className="ops-payments">
                  {shifts.filter((s) => !s.clockOutAt).map((s) => (
                    <li key={s.id}>
                      <strong>{s.name} · {words(s.role)}</strong>
                      <span>{s.clockInAt ? `In since ${time(s.clockInAt)}` : `Planned ${time(s.startsAt)}`}</span>
                      <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("shift.clock", tenant, { action: s.clockInAt ? "out" : "in" }, { id: s.id, version: s.version }); return s.clockInAt ? `${s.name} clocked out.` : `${s.name} clocked in.`; })}>
                        <Icon name="clock" size={18} />{s.clockInAt ? "Clock out" : "Clock in"}
                      </button>
                    </li>
                  ))}
                </ul>
              )}
              {note && <p className="ops-note" role="status">{note}</p>}
            </div>
          )}
        </aside>
      </div>
      <Proposals api={api} tenant={tenant} inbox={data?.inbox ?? []} commands={["shift.plan"]} onDone={reload} />
      <small className="ops-note">Hours feed the pay run in Money → Pay &amp; tips. The copilot proposes next week's roster from sales by hour; {agentName("copilot")} never changes a shift without you.</small>
    </div>
  );
}
