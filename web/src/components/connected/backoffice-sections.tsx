"use client";
/**
 * Money: the café's back office. Each tab is one loop: an AI coworker
 * prepares the money matter with its evidence, the owner approves, PayPal
 * executes and its id is shown. Nothing here moves money by itself.
 * Figures count up to their real values, PAID lands only when PayPal reports
 * the payment, and every outcome is a snackbar with PayPal's id.
 */
import { useMemo, useState, type FormEvent, type ReactNode } from "react";
import type { ColDef } from "ag-grid-community";
import { ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { agentName, asRows, dayRange, type AgentActionRow, type OrderRow } from "@/lib/connected/business";
import {
  actionsFor,
  backoffice,
  batchTotal,
  closeDelta,
  closeSourceLabel,
  gapLabel,
  localDay,
  marginPercent,
  shiftHours,
  shiftPayMinor,
  shiftState,
  weekRange,
  type Analytics,
  type CateringRequest,
  type Close,
  type Complaint,
  type CustomerProfile,
  type Dashboard,
  type Dispute,
  type Expense,
  type PayoutBatch,
  type Shift,
} from "@/lib/connected/backoffice";
import { boolCol, countCol, dateCol, idCol, moneyCol, statusCol } from "@/lib/connected/grid-columns";
import { StudioWidget, type StudioWidgetSpec } from "@/lib/connected/studio/studio-canvas";
import { major } from "@/lib/connected/studio/sources";
import { RaystoGrid } from "./raysto-grid";
import { MotionRoot } from "@/lib/connected/motion";
import { approvalNotice, heldOf, hourWindow, latestSent, payoutFor, peopleOf, spendShare, type Person } from "@/lib/connected/money-view";
import { Icon } from "./icons";
import { PayPalAccountTab } from "./paypal-account";
import { AgentPanel, pill, time, useLoad, words } from "./business-sections";
import {
  AreaChart,
  BarRow,
  ContainerCard,
  ContainerDialog,
  CountUp,
  Reveal,
  SnackbarProvider,
  Stamp,
  useSnackbar,
} from "./m3";

export type MoneyTab = "close" | "pay" | "catering" | "refunds" | "expenses" | "customers" | "analytics" | "paypal";
const moneyTabs: [MoneyTab, string][] = [
  ["close", "Close the day"],
  ["pay", "Pay & tips"],
  ["catering", "Catering"],
  ["refunds", "Refunds & disputes"],
  ["expenses", "Expenses"],
  ["customers", "Customers"],
  ["analytics", "Analytics"],
  // 0.16 (S6): which PayPal account the money goes through.
  ["paypal", "PayPal account"],
];

const fail = (e: unknown) => String(e instanceof Error ? e.message : e);

type Notice = ReturnType<typeof useSnackbar>;

/** The console's snackbar, or none when no SnackbarProvider is above (the note line then says it). */
function useNotice(): Notice | null {
  try {
    return useSnackbar();
  } catch {
    return null;
  }
}

/** The kit's roots for a section: motion's features, and a snackbar unless the shell already has one. */
function KitRoot({ children }: { children: ReactNode }) {
  const notice = useNotice();
  const inner = <MotionRoot>{children}</MotionRoot>;
  return notice ? inner : <SnackbarProvider>{inner}</SnackbarProvider>;
}

/** Money that counts up to its real value. */
function Cash({ minor, code }: { minor: number; code: string }) {
  return <CountUp value={Math.round(Number(minor) || 0)} format={(n) => currency(n, code)} />;
}

/** A whole number that counts up. */
function Count({ n }: { n: number }) {
  return <CountUp value={Math.round(n)} format={(x) => String(x)} />;
}

/** Hours to the quarter, counted in hundredths so the count stays on whole steps. */
function Hours({ h }: { h: number }) {
  return <CountUp value={Math.round(h * 100)} format={(x) => (x / 100).toFixed(2)} />;
}

/** One command with its busy state and outcome: a snackbar when the shell has one, else a note line. */
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
  return { busy, note, act, setNote };
}

/**
 * A money action behind the identity check: the manager confirms again (a
 * password, or Google), the server records the step-up, then the command runs.
 * The judges' café keeps its published password ready so it is one tap.
 */
export function StepUpAction({
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

/** The agent's proposals that belong to this tab, approved like any other; the outcome is a snackbar with PayPal's id. */
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
  const notice = useNotice();
  const mine = actionsFor(inbox, commands);
  if (mine.length === 0) return null;
  return (
    <div className="ops-bo-proposals">
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

function Empty({ children }: { children: ReactNode }) {
  return <p className="ops-quiet-note">{children}</p>;
}

/** Two buttons that switch a view, e.g. Cards | Grid. */
function ViewSwitch<T extends string>({ value, options, onChange, label }: { value: T; options: [T, string][]; onChange: (v: T) => void; label: string }) {
  return (
    <div className="ops-chips ops-bo-switch" role="group" aria-label={label}>
      {options.map(([v, text]) => (
        <button key={v} aria-pressed={value === v} onClick={() => onChange(v)}>{text}</button>
      ))}
    </div>
  );
}

const initials = (name: string) =>
  name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w.charAt(0).toUpperCase())
    .join("") || "?";

const slug = (s: string) => s.trim().toLowerCase().replace(/[^a-z0-9]+/g, "-") || "x";

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
  const { data: inbox } = useLoad(() => bo.inbox(), [bo, revision, tick]);
  const refresh = () => setTick((n) => n + 1);
  // A tab refetches on every live change and after every action, without
  // remounting: a payment PayPal confirms while the page is open lands its
  // stamp instead of appearing already there.
  const version = `${revision}-${tick}`;
  const props = { api, tenant, bo, currencyCode, inbox: inbox ?? [], refresh, version };
  return (
    <KitRoot>
      <div className="ops-business">
        <div className="ops-chips ops-bo-tabs" role="tablist" aria-label="Back office">
          {moneyTabs.map(([t, label]) => (
            <button key={t} role="tab" aria-selected={tab === t} aria-pressed={tab === t} onClick={() => setTab(t)}>{label}</button>
          ))}
        </div>
        {tab === "close" ? <CloseTab key={tab} {...props} /> : tab === "pay" ? <PayTab key={tab} {...props} /> : tab === "catering" ? <CateringTab key={tab} {...props} /> : tab === "refunds" ? <RefundsTab key={tab} {...props} /> : tab === "expenses" ? <ExpensesTab key={tab} {...props} /> : tab === "customers" ? <CustomersTab key={tab} {...props} /> : tab === "paypal" ? <PayPalAccountTab key={tab} api={api} tenant={tenant} version={version} /> : <AnalyticsTab key={tab} {...props} />}
        <small className="ops-note">AI coworkers prepare the money matters; you approve; PayPal moves the money and its id is kept here.</small>
      </div>
    </KitRoot>
  );
}

type TabProps = {
  api: ConnectedApi;
  tenant: number;
  bo: ReturnType<typeof backoffice>;
  currencyCode: string;
  inbox: AgentActionRow[];
  refresh: () => void;
  /** Changes on every live event and every action; tabs refetch on it. */
  version: string;
};

/** A summary tile whose figure counts up. */
function Kpi({ label, children, alert }: { label: string; children: ReactNode; alert?: boolean }) {
  return (
    <div className={`ops-kpi ${alert ? "alert" : ""}`}>
      <span>{label}</span>
      <strong>{children}</strong>
    </div>
  );
}

/* ---------- Close the day ---------- */

/** The close agent's gap kinds are snake_case (`capture_not_in_raysto`); the labels know camelCase. */
const gapNamesByKind: Record<string, string> = {
  capture_not_in_raysto: "Capture not in Raysto",
  raysto_not_in_paypal: "Not in PayPal",
  unpaid_ticket: "Unpaid ticket",
  refund_mismatch: "Refund mismatch",
  fee_note: "PayPal fee",
};
const gapText = (kind: string) =>
  gapNamesByKind[kind] ?? gapLabel({ kind: kind.replace(/_([a-z])/g, (_, c: string) => c.toUpperCase()) });

function CloseTab({ api, tenant, bo, currencyCode, inbox, refresh, version }: TabProps) {
  const today = localDay(new Date());
  const { data, error } = useLoad(async () => {
    const [current, past] = await Promise.all([bo.close(today), bo.closes()]);
    return { close: current.close, past };
  }, [bo, version]);
  const { busy, note, act } = useAct(refresh);
  const c = data?.close;
  const code = c?.summary.currency ?? currencyCode;
  const delta = c ? closeDelta(c) : null;
  const columns = useMemo<ColDef<Close>[]>(
    () => [
      dateCol<Close>("Day", "day", { dayOnly: true, sort: "desc" }),
      moneyCol<Close>("PayPal says", (c) => c.summary.paypalCapturedMinor, currencyCode),
      moneyCol<Close>("Raysto says", (c) => c.summary.raystoCapturedMinor, currencyCode),
      moneyCol<Close>("Cash", (c) => c.summary.cashMinor, currencyCode),
      moneyCol<Close>("Refunds", (c) => c.summary.refundsMinor, currencyCode),
      countCol<Close>("Gaps found", (c) => c.gaps.length),
      statusCol<Close>("State", "state", { minWidth: 120 }),
    ],
    [currencyCode],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-bo-split">
        <Reveal as="section" className="ops-panel ops-bo-card" visitKey="money-close">
          <span className="ops-eyebrow">Daily close · {today}</span>
          <h2 id="bo-close">{c ? (c.state === "signed" ? "Signed off" : "Ready for your sign-off") : "Not closed yet"}</h2>
          {c ? (
            <>
              <p className="ops-note">PayPal read from {closeSourceLabel(c.source)}.</p>
              <dl className="ops-bo-figures">
                <dt>PayPal captured</dt><dd><Cash minor={c.summary.paypalCapturedMinor} code={code} /></dd>
                <dt>Raysto recorded</dt><dd><Cash minor={c.summary.raystoCapturedMinor} code={code} /></dd>
                <dt>Difference</dt>
                <dd className={delta?.matches ? "ok" : "warn"}>{delta?.matches ? "Matches" : <Cash minor={delta?.minor ?? 0} code={code} />}</dd>
                <dt>Cash</dt><dd><Cash minor={c.summary.cashMinor} code={code} /></dd>
                <dt>Tips</dt><dd><Cash minor={c.summary.tipsMinor} code={code} /></dd>
                <dt>Refunds</dt><dd><Cash minor={c.summary.refundsMinor} code={code} /></dd>
                <dt>PayPal fees</dt><dd><Cash minor={c.summary.feesMinor} code={code} /></dd>
              </dl>
              <h3>{c.gaps.length ? `${c.gaps.length} ${c.gaps.length === 1 ? "gap" : "gaps"} explained` : "No gaps"}</h3>
              {c.gaps.length > 0 && (
                <ul className="ops-bo-gaps">
                  {c.gaps.map((g, i) => (
                    <li key={i}>
                      <span className="ops-pill warn">{gapText(g.kind)}</span>
                      <strong>{currency(g.amountMinor, code)}</strong>
                      <p>{g.explanation}{g.proposedFix ? ` Proposed: ${g.proposedFix}` : ""}</p>
                    </li>
                  ))}
                </ul>
              )}
              {c.state !== "signed" && actionsFor(inbox, ["close.sign"]).length === 0 && (
                <button className="ops-primary" disabled={busy} onClick={() => void act(async () => { await api.command("close.sign", tenant, {}, { id: c.id, version: c.version }); return `Signed off ${c.day}. PayPal's figures are posted beside the till's.`; })}>
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
        </Reveal>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["close.sign"]} onDone={refresh} />
      </div>
      <h2 className="ops-section-title">Past closes</h2>
      <RaystoGrid<Close> label="Closed days" rows={data?.past} loading={!data && !error} columns={columns} getRowId={(p) => String(p.data.id)} csvName="closes" emptyText="No day has been closed yet." />
    </>
  );
}

/* ---------- Pay & tips ---------- */

function PayTab({ api, tenant, bo, currencyCode, inbox, refresh, version }: TabProps) {
  const week = useMemo(() => weekRange(new Date()), []);
  const { data, error } = useLoad(async () => {
    const [shifts, payouts] = await Promise.all([bo.shifts(week.from, week.to), bo.payouts()]);
    return { shifts, payouts };
  }, [bo, week, version]);
  const { busy, note, act } = useAct(refresh);
  const hours = (data?.shifts ?? []).reduce((n, s) => n + shiftHours(s), 0);
  const wages = (data?.shifts ?? []).reduce((n, s) => n + shiftPayMinor(s), 0);
  const proposed = (data?.payouts ?? []).filter((b) => b.state === "proposed");
  const last = latestSent(data?.payouts ?? []);
  const columns = useMemo<ColDef<PayoutBatch>[]>(
    () => [
      dateCol<PayoutBatch>("Prepared", "createdAt", { sort: "desc", minWidth: 150 }),
      { field: "kind", headerName: "Pays", valueFormatter: (p) => words(p.value), flex: 0.6 },
      { headerName: "Period", valueGetter: (p) => `${String(p.data?.periodFrom ?? "").slice(0, 10)} to ${String(p.data?.periodTo ?? "").slice(0, 10)}`, minWidth: 200 },
      countCol<PayoutBatch>("People", (b) => b.items?.length ?? 0, { flex: 0.5 }),
      moneyCol<PayoutBatch>("Total", "totalMinor", currencyCode),
      statusCol<PayoutBatch>("State", "state", { minWidth: 120 }),
      idCol<PayoutBatch>("PayPal batch id", "providerBatchId", { minWidth: 180 }),
    ],
    [currencyCode],
  );
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <Kpi label="Hours this week"><Hours h={hours} /></Kpi>
        <Kpi label="Wages so far"><Cash minor={wages} code={currencyCode} /></Kpi>
        <Kpi label="Shifts"><Count n={data?.shifts.length ?? 0} /></Kpi>
        <Kpi label="Payouts waiting" alert={proposed.length > 0}><Count n={proposed.length} /></Kpi>
      </div>
      <div className="ops-bo-split">
        <Reveal as="section" className="ops-panel ops-bo-card" visitKey="money-pay">
          <span className="ops-eyebrow">Pay run</span>
          <h2 id="bo-pay">{proposed.length ? "A payout batch is ready" : "Pay the team through PayPal"}</h2>
          {proposed.length === 0 && <p>The payroll agent counts the hours, splits the tip pool by hours and role, and prepares one PayPal Payouts batch for you to send.</p>}
          {proposed.map((b) => (
            <div key={b.id} className="ops-bo-batch">
              <strong>{words(b.kind)} · <Cash minor={b.totalMinor} code={b.currency} /></strong>
              <small>{String(b.periodFrom).slice(0, 10)} → {String(b.periodTo).slice(0, 10)}</small>
              <ul className="ops-payments">
                {(b.items ?? []).map((i, n) => (
                  <li key={n}>
                    <strong>{i.recipientName} · {currency(i.amountMinor, b.currency)}</strong>
                    {i.note && <span>{i.note}</span>}
                  </li>
                ))}
                {heldOf(b).map((h, n) => (
                  <li key={`held-${n}`} className="ops-bo-held">
                    <strong>Held · {h.recipientName} · {currency(h.amountMinor, b.currency)}</strong>
                    <span>{h.reason ?? "No PayPal email: add one to pay."}</span>
                  </li>
                ))}
              </ul>
              {batchTotal({ items: b.items ?? [] }) !== b.totalMinor && <p className="ops-error" role="alert">The lines do not add up to the batch total.</p>}
              {actionsFor(inbox, ["payout.send"]).some((a) => Number((a.preview as Json)?.batchId) === b.id) ? null : (
                <StepUpAction api={api} tenant={tenant} label="Send with PayPal" onRun={async () => {
                  // A batch has no version: the server checks that it is still proposed.
                  const r = await api.command<Json>("payout.send", tenant, {}, { id: b.id });
                  refresh();
                  return `Sent with PayPal Payouts. PayPal batch ${String(r.providerBatchId ?? "")}.`;
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
        </Reveal>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["payout.send"]} onDone={refresh} />
      </div>
      {last && (
        <Reveal as="section" className="ops-panel ops-bo-card ops-bo-stamped ops-bo-latest" visitKey="money-pay-latest">
          <span className="ops-eyebrow">Latest payout · {words(last.kind)}</span>
          <h2><Cash minor={last.totalMinor} code={last.currency} /></h2>
          <p className="ops-note">
            {last.state === "completed" ? "PayPal reports every payment in this batch done." : last.state === "failed" ? "PayPal could not complete this batch." : "PayPal is sending it; this updates when PayPal reports back."}
            {last.providerBatchId ? ` PayPal batch ${last.providerBatchId}.` : ""}
          </p>
          <ul className="ops-payments">
            {(last.items ?? []).map((i, n) => (
              <li key={n}>
                <strong>{i.recipientName} · {currency(i.amountMinor, last.currency)}</strong>
                <span>{pill({ value: i.state })}</span>
              </li>
            ))}
          </ul>
          <Stamp key={last.id} paid={last.state === "completed"} className="ops-bo-stamp" />
        </Reveal>
      )}
      <h2 className="ops-section-title">Payouts</h2>
      <RaystoGrid<PayoutBatch> label="Payouts" rows={data?.payouts} loading={!data && !error} columns={columns} getRowId={(p) => String(p.data.id)} csvName="payouts" emptyText="No payout yet. Run pay to prepare one." />
    </>
  );
}

/* ---------- Catering ---------- */

const openRequest = (x: CateringRequest) => x.status !== "paid" && x.status !== "cancelled";

function CateringTab({ api, tenant, bo, currencyCode, inbox, refresh, version }: TabProps) {
  const { data, error } = useLoad(() => bo.catering(), [bo, version]);
  const [selected, setSelected] = useState<number>();
  const [form, setForm] = useState({ customerName: "", customerEmail: "", text: "", eventAt: "" });
  const { busy, note, act } = useAct(refresh);
  const rows = data ?? [];
  // The request on show stays the same across refetches, so one PayPal
  // marks paid while the page is open lands its stamp here.
  // With nothing open, the newest request shows (a paid one with its stamp, still).
  const newest = [...rows].sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt)))[0];
  const fallback = (rows.find(openRequest) ?? newest)?.id;
  const [pinned, setPinned] = useState<number>();
  if (pinned === undefined && fallback !== undefined) setPinned(fallback);
  const r = rows.find((x) => x.id === (selected ?? pinned)) ?? rows.find(openRequest) ?? newest;
  const code = r ? r.currency || currencyCode : currencyCode;
  const columns = useMemo<ColDef<CateringRequest>[]>(
    () => [
      { field: "customerName", headerName: "Customer", minWidth: 140, cellClass: "ops-cell-strong" },
      { field: "text", headerName: "Request", flex: 2, minWidth: 220, tooltipField: "text" },
      dateCol<CateringRequest>("Event", "eventAt", { minWidth: 150 }),
      moneyCol<CateringRequest>("Quote", "totalMinor", currencyCode),
      statusCol<CateringRequest>("Status", "status", { minWidth: 120 }),
      idCol<CateringRequest>("PayPal invoice", "invoiceNumber", { minWidth: 160 }),
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
        <Reveal as="section" className="ops-panel ops-bo-card" visitKey="money-catering">
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
        </Reveal>
        {r && (
          <Reveal as="section" index={1} className="ops-panel ops-bo-card ops-bo-stamped" visitKey="money-catering-request">
            <span className="ops-eyebrow">{words(r.status)} · {r.customerName}</span>
            <h2>{r.totalMinor ? <Cash minor={r.totalMinor} code={code} /> : "Being priced"}</h2>
            <p>{r.text}</p>
            {r.quote?.lines && r.quote.lines.length > 0 && (
              <ul className="ops-lines">
                {r.quote.lines.map((l, i) => (
                  <li key={i}><span>{l.quantity}× {l.name}</span><small>{currency(l.unitMinor * l.quantity, code)}</small></li>
                ))}
              </ul>
            )}
            <dl className="ops-bo-figures">
              {r.eventAt && <><dt>Event</dt><dd>{time(r.eventAt)}</dd></>}
              {r.depositMinor > 0 && <><dt>Deposit</dt><dd><Cash minor={r.depositMinor} code={code} /></dd></>}
              {r.dueAt && <><dt>Due</dt><dd>{time(r.dueAt)}</dd></>}
              {r.invoiceNumber && <><dt>PayPal invoice</dt><dd><code>{r.invoiceNumber}</code></dd></>}
              {r.providerInvoiceId && <><dt>Invoice id</dt><dd><code>{r.providerInvoiceId}</code></dd></>}
              {r.remindedAt && <><dt>Reminded</dt><dd>{time(r.remindedAt)}</dd></>}
            </dl>
            {r.qrUrl && <img className="ops-bo-qr" src={r.qrUrl} alt="PayPal invoice QR code" width={160} height={160} />}
            {r.status === "quoted" && actionsFor(inbox, ["invoice.send"]).length === 0 && (
              <StepUpAction api={api} tenant={tenant} label="Send the invoice" onRun={async () => {
                const x = await api.command<Json>("invoice.send", tenant, {}, { id: r.id, version: r.version });
                refresh();
                return `Sent with PayPal Invoicing. PayPal invoice ${String(x.invoiceNumber ?? x.providerInvoiceId ?? "")}.`;
              }} />
            )}
            {r.status === "sent" && (
              <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("invoice.remind", tenant, {}, { id: r.id, version: r.version }); return "Reminder sent through PayPal."; })}>
                <Icon name="bell" size={18} />Send a reminder
              </button>
            )}
            {r.status === "paid" && <p className="ops-try-done"><Icon name="check" size={18} />Paid on PayPal. The kitchen has the order.</p>}
            {/* PAID is PayPal's confirmation (the invoice-paid webhook); there is no button for it. */}
            <Stamp key={r.id} paid={r.status === "paid"} className="ops-bo-stamp" />
          </Reveal>
        )}
      </div>
      <Proposals api={api} tenant={tenant} inbox={inbox} commands={["invoice.send", "invoice.remind"]} onDone={refresh} />
      <h2 className="ops-section-title">Requests</h2>
      <RaystoGrid<CateringRequest> label="Catering requests" rows={rows} loading={!data && !error} columns={columns} getRowId={(p) => String(p.data.id)} onRowClicked={(e) => e.data && setSelected(e.data.id)} rowSelection={{ mode: "singleRow", checkboxes: false, enableClickSelection: true }} csvName="catering" emptyText="No catering request yet." tooltipShowDelay={300} />
    </>
  );
}

/* ---------- Refunds & disputes ---------- */

function RefundsTab({ api, tenant, bo, currencyCode, inbox, refresh, version }: TabProps) {
  const { data, error } = useLoad(async () => {
    const [complaints, disputes, orders] = await Promise.all([
      bo.complaints(),
      bo.disputes(),
      api.query<Json>("orders", { restaurantId: tenant, staff: true, order: "desc", limit: 30 }).then(asRows<OrderRow>).catch(() => [] as OrderRow[]),
    ]);
    return { complaints, disputes, orders };
  }, [bo, version]);
  const [form, setForm] = useState({ orderId: "", text: "" });
  const { busy, note, act } = useAct(refresh);
  const complaints = data?.complaints ?? [];
  const refunded = complaints.filter((c) => c.status === "refunded");
  const refundedMinor = refunded.reduce((n, c) => n + (c.proposal?.amountMinor ?? 0), 0);
  const complaintColumns = useMemo<ColDef<Complaint>[]>(
    () => [
      { headerName: "Order", valueGetter: (p) => `Order ${p.data?.orderId}`, flex: 0.6, cellClass: "ops-cell-strong" },
      { field: "text", headerName: "Complaint", flex: 2, minWidth: 220, tooltipField: "text" },
      { headerName: "Agent proposes", valueGetter: (p) => (p.data?.proposal ? `${words(p.data.proposal.kind)} · ${currency(p.data.proposal.amountMinor, currencyCode)}` : ""), minWidth: 170 },
      statusCol<Complaint>("Status", "status", { minWidth: 120 }),
      idCol<Complaint>("PayPal refund id", "providerRefundId", { minWidth: 180 }),
      dateCol<Complaint>("Opened", "createdAt", { sort: "desc", minWidth: 150 }),
    ],
    [currencyCode],
  );
  const disputeColumns = useMemo<ColDef<Dispute>[]>(
    () => [
      idCol<Dispute>("PayPal dispute", "providerDisputeId", { minWidth: 180 }),
      { field: "reason", headerName: "Reason", valueFormatter: (p) => words(p.value), minWidth: 160 },
      moneyCol<Dispute>("Amount", "amountMinor", currencyCode),
      statusCol<Dispute>("Status", "status", { minWidth: 130 }),
      { field: "replyText", headerName: "Draft reply", flex: 2, minWidth: 220, tooltipField: "replyText" },
      dateCol<Dispute>("Opened", "createdAt", { sort: "desc", minWidth: 150 }),
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
      <div className="ops-kpis compact">
        <Kpi label="Open complaints"><Count n={complaints.filter((c) => c.status === "open" || c.status === "proposed").length} /></Kpi>
        <Kpi label="Refunded through PayPal"><Cash minor={refundedMinor} code={currencyCode} /></Kpi>
        <Kpi label="PayPal disputes"><Count n={data?.disputes.length ?? 0} /></Kpi>
      </div>
      <div className="ops-bo-split">
        <Reveal as="section" className="ops-panel ops-bo-card" visitKey="money-refunds">
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
        </Reveal>
        <Proposals api={api} tenant={tenant} inbox={inbox} commands={["payment.refund", "dispute.accept"]} onDone={refresh} />
      </div>
      <h2 className="ops-section-title">Complaints</h2>
      <RaystoGrid<Complaint> label="Complaints" rows={complaints} loading={!data && !error} columns={complaintColumns} getRowId={(p) => String(p.data.id)} csvName="complaints" emptyText="No complaint. Good." tooltipShowDelay={300} totals={false} />
      <div className="ops-bo-toolbar">
        <h2 className="ops-section-title">PayPal disputes</h2>
        <button className="ops-secondary" disabled={busy} onClick={() => void act(async () => { await api.command("dispute.sweep", tenant, {}); return "Asking PayPal for open disputes through the MCP server."; })}>
          <Icon name="paypal" size={18} />Check PayPal for disputes
        </button>
      </div>
      <RaystoGrid<Dispute> label="PayPal disputes" rows={data?.disputes} loading={!data && !error} columns={disputeColumns} getRowId={(p) => String(p.data.id)} csvName="disputes" emptyText="No dispute on PayPal." tooltipShowDelay={300} />
    </>
  );
}

/* ---------- Expenses ---------- */

const expenseCategories = ["Ingredients", "Drinks", "Packaging", "Rent", "Utilities", "Equipment", "Marketing", "Other"];

function ExpensesTab({ api, tenant, bo, currencyCode, inbox, refresh, version }: TabProps) {
  const month = useMemo(() => dayRange(new Date(), 29), []);
  const { data, error } = useLoad(() => bo.expenses(month.from, month.until), [bo, month, version]);
  const [form, setForm] = useState({ merchant: "", category: "Ingredients", amount: "", vat: "", spentAt: localDay(new Date()) });
  const { busy, note, act } = useAct(refresh);
  const total = (data ?? []).reduce((n, e) => n + e.amountMinor, 0);
  const byCategory = useMemo(() => {
    const sums = new Map<string, number>();
    for (const e of data ?? []) sums.set(e.category, (sums.get(e.category) ?? 0) + e.amountMinor);
    return [...sums].sort((a, b) => b[1] - a[1]);
  }, [data]);
  const columns = useMemo<ColDef<Expense>[]>(
    () => [
      dateCol<Expense>("Date", "spentAt", { dayOnly: true, sort: "desc", minWidth: 130 }),
      { field: "merchant", headerName: "Merchant", minWidth: 160, cellClass: "ops-cell-strong" },
      { field: "category", headerName: "Category", valueFormatter: (p) => words(p.value), minWidth: 130 },
      moneyCol<Expense>("Amount", "amountMinor", currencyCode),
      moneyCol<Expense>("VAT", "vatMinor", currencyCode),
      boolCol<Expense>("Found in PayPal", (x) => Boolean(x.paypalTransactionId), { labels: ["Matched in PayPal", "Not in PayPal"] }),
      idCol<Expense>("PayPal transaction", "paypalTransactionId", { minWidth: 180 }),
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
        <Kpi label="Last 30 days"><Cash minor={total} code={currencyCode} /></Kpi>
        <Kpi label="Entries"><Count n={data?.length ?? 0} /></Kpi>
        <Kpi label="Matched in PayPal"><Count n={(data ?? []).filter((e) => e.paypalTransactionId).length} /></Kpi>
      </div>
      <div className="ops-bo-split">
        <Reveal as="section" className="ops-panel ops-bo-card" visitKey="money-expenses">
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
        </Reveal>
        <div className="ops-bo-stack">
          {byCategory.length > 0 && (
            <Reveal as="section" index={1} className="ops-panel ops-bo-card" visitKey="money-expenses-categories">
              <span className="ops-eyebrow">Where it went · 30 days</span>
              <BarRow title="Expenses by category, last 30 days" rows={byCategory.map(([label, value]) => ({ label, value, display: currency(value, currencyCode) }))} />
            </Reveal>
          )}
          <Proposals api={api} tenant={tenant} inbox={inbox} commands={["expense.record", "stock.receive"]} onDone={refresh} />
        </div>
      </div>
      <RaystoGrid<Expense> label="Expenses" rows={data} loading={!data && !error} columns={columns} getRowId={(p) => String(p.data.id)} csvName="expenses" emptyText="No expense recorded in the last 30 days." />
    </>
  );
}

/* ---------- Customers ---------- */

function CustomersTab({ api, tenant, bo, currencyCode, inbox, refresh, version }: TabProps) {
  const { data, error } = useLoad(() => bo.customers(), [bo, version]);
  const { busy, note, act } = useAct(refresh);
  const [view, setView] = useState<"cards" | "grid" | "tags">("cards");
  const [open, setOpen] = useState<{ id: number; shown: boolean }>();
  const customers = data ?? [];
  const opened = customers.find((c) => c.id === open?.id);
  const columns = useMemo<ColDef<CustomerProfile>[]>(
    () => [
      { field: "displayName", headerName: "Customer", minWidth: 160, cellClass: "ops-cell-strong" },
      countCol<CustomerProfile>("Visits", "visits", { flex: 0.5 }),
      moneyCol<CustomerProfile>("Spent with PayPal", "spentMinor", currencyCode),
      dateCol<CustomerProfile>("Last seen", "lastSeenAt", { sort: "desc", minWidth: 150 }),
      { headerName: "Tags", valueGetter: (p) => (p.data?.tags ?? []).map(words).join(", "), minWidth: 160 },
      idCol<CustomerProfile>("Coupon", "couponCode", { minWidth: 140 }),
    ],
    [currencyCode],
  );
  // AG Studio's pivot: each customer under their first tag, so no one is counted twice.
  const byTag = useMemo(
    () => ({
      id: "customers",
      data: customers.map((c) => ({
        tag: c.tags[0] ? words(c.tags[0]) : "Untagged",
        customer: c.displayName,
        visits: c.visits,
        spent: major(c.spentMinor),
      })),
    }),
    [customers],
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
      <Proposals api={api} tenant={tenant} inbox={inbox} commands={["coupon.create"]} onDone={refresh} />
      <ViewSwitch label="Customers view" value={view} onChange={setView} options={[["cards", "Cards"], ["grid", "Grid"], ["tags", "By tag"]]} />
      {view === "cards" ? (
        customers.length === 0 ? (
          <Empty>{data ? "No customer profile yet. They appear as PayPal orders are paid." : "Loading customers…"}</Empty>
        ) : (
          <div className="ops-bo-people">
            {customers.map((c, i) => (
              <Reveal key={c.id} index={i} visitKey="money-customers">
                <ContainerCard layoutId={`customer-${c.id}`} as="article" className="ops-bo-person">
                  <header>
                    <span className="ops-bo-avatar" aria-hidden="true">{initials(c.displayName)}</span>
                    <div>
                      <h3>{c.displayName}</h3>
                      <small>Last seen {time(c.lastSeenAt)}</small>
                    </div>
                  </header>
                  <div className="ops-bo-spend">
                    <span>Spent</span>
                    <strong><Cash minor={c.spentMinor} code={currencyCode} /></strong>
                    <span className="ops-bo-spend-track" aria-hidden="true">
                      <span style={{ width: `${Math.round(spendShare(c, customers) * 100)}%` }} />
                    </span>
                  </div>
                  <p className="ops-bo-person-line">
                    {c.visits} {c.visits === 1 ? "visit" : "visits"}
                    {c.couponCode ? <> · coupon <code>{c.couponCode}</code></> : null}
                  </p>
                  {c.tags.length > 0 && <div className="ops-bo-tags">{c.tags.map((t) => <span key={t}>{pill({ value: t })}</span>)}</div>}
                  <button className="ops-secondary" onClick={() => setOpen({ id: c.id, shown: true })}>
                    Details<span className="m3-sr"> for {c.displayName}</span>
                  </button>
                </ContainerCard>
              </Reveal>
            ))}
          </div>
        )
      ) : view === "tags" ? (
        <StudioWidget label="Customers by tag" source={byTag} widget={customersPivot(currencyCode)} height={480} />
      ) : (
        <RaystoGrid<CustomerProfile> label="Customers" rows={customers} loading={!data && !error} columns={columns} getRowId={(p) => String(p.data.id)} csvName="customers" emptyText="No customer profile yet. They appear as PayPal orders are paid." />
      )}
      {open && (
        <ContainerDialog layoutId={`customer-${open.id}`} open={open.shown} onClose={() => setOpen({ ...open, shown: false })} title={opened ? `${opened.displayName}, customer details` : "Customer details"}>
          {opened && (
            <div className="ops-bo-dialog">
              <span className="ops-eyebrow">Customer</span>
              <h2>{opened.displayName}</h2>
              <dl className="ops-bo-figures">
                <dt>Spent with PayPal</dt><dd><Cash minor={opened.spentMinor} code={currencyCode} /></dd>
                <dt>Visits</dt><dd>{opened.visits}</dd>
                <dt>Last seen</dt><dd>{time(opened.lastSeenAt)}</dd>
                <dt>Tags</dt><dd>{opened.tags.length ? opened.tags.map(words).join(", ") : "None"}</dd>
                <dt>Coupon</dt><dd>{opened.couponCode ? <code>{opened.couponCode}</code> : "None offered yet"}</dd>
              </dl>
              <p className="ops-note">Built from the orders PayPal paid. Coupons come from the loyalty agent and are redeemed at PayPal checkout; nothing is sent to the customer without you.</p>
            </div>
          )}
        </ContainerDialog>
      )}
    </>
  );
}

/* ---------- Analytics ---------- */

const shortMoney = (code: string) => (n: number) => currency(n, code).replace(/\.00$/, "");

function AnalyticsTab({ bo, currencyCode, version }: TabProps) {
  const [days, setDays] = useState(7);
  const range = useMemo(() => dayRange(new Date(), days - 1), [days]);
  const { data, error } = useLoad(async () => {
    const [analytics, dashboard] = await Promise.all([
      bo.analytics(range.from, range.until),
      // Per-day paid sales come from the dashboard query (backend 0.15.0); without it the day chart is left out.
      bo.dashboard(days === 7 ? "7d" : "30d").catch(() => null as Dashboard | null),
    ]);
    return { analytics, dashboard };
  }, [bo, range, version]);
  const a: Analytics | undefined = data?.analytics;
  const code = a?.currency ?? currencyCode;
  const fmt = (v: number) => currency(v, code);
  const columns = useMemo<ColDef<Analytics["marginByDish"][number]>[]>(
    () => [
      { field: "name", headerName: "Dish", minWidth: 180, cellClass: "ops-cell-strong" },
      moneyCol<Analytics["marginByDish"][number]>("Price", "priceMinor", code, { total: false }),
      moneyCol<Analytics["marginByDish"][number]>("Cost", "costMinor", code, { total: false }),
      countCol<Analytics["marginByDish"][number]>("Margin", (d) => marginPercent(d), { total: false, format: (n) => `${n}%`, sort: "asc" }),
    ],
    [code],
  );
  const sales = (a?.byHour ?? []).reduce((n, h) => n + h.salesMinor, 0);
  const hours = hourWindow(a?.byHour ?? []);
  const perDay = data?.dashboard;
  return (
    <>
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-chips" role="group" aria-label="Period">
        {[7, 30].map((d) => (
          <button key={d} aria-pressed={days === d} onClick={() => setDays(d)}>{d === 7 ? "7 days" : "30 days"}</button>
        ))}
      </div>
      <div className="ops-kpis">
        <Kpi label="Sales"><Cash minor={sales} code={code} /></Kpi>
        <Kpi label="PayPal fees"><Cash minor={a?.feesMinor ?? 0} code={code} /></Kpi>
        <Kpi label="Refunds"><Cash minor={a?.refundsMinor ?? 0} code={code} /></Kpi>
        <Kpi label="Tips"><Cash minor={a?.tipsMinor ?? 0} code={code} /></Kpi>
        <Kpi label="Staff cost"><Cash minor={a?.staffCostMinor ?? 0} code={code} /></Kpi>
        <Kpi label="Expenses"><Cash minor={a?.expensesMinor ?? 0} code={code} /></Kpi>
      </div>
      {perDay && (
        <Reveal as="section" className="ops-panel ops-bo-chartcard" visitKey={`money-analytics-days-${days}`}>
          <h2>Paid sales per day</h2>
          <AreaChart
            key={days}
            title={`Paid sales per day, last ${days} days`}
            points={perDay.points.map((p) => ({ label: p.label, value: p.salesMinor }))}
            format={fmt}
            axisFormat={shortMoney(code)}
            sample={perDay.sample ? { label: perDay.sample.label, values: perDay.sample.points.map((p) => p.salesMinor) } : null}
          />
        </Reveal>
      )}
      <div className="ops-bo-split">
        <Reveal as="section" className="ops-panel ops-bo-chartcard" visitKey="money-analytics-hours">
          <h2>Sales by hour of day</h2>
          {sales === 0 ? (
            <Empty>No sales in this period yet.</Empty>
          ) : (
            <AreaChart key={days} title={`Sales by hour of day, last ${days} days`} points={hours.map((h) => ({ label: h.label, value: h.salesMinor }))} format={fmt} axisFormat={shortMoney(code)} height={200} />
          )}
        </Reveal>
        <Reveal as="section" index={1} className="ops-panel ops-bo-chartcard" visitKey="money-analytics-channels">
          <h2>Sales by channel</h2>
          {(a?.byChannel ?? []).length === 0 ? (
            <Empty>No sales in this period yet.</Empty>
          ) : (
            <BarRow key={days} title={`Sales by channel, last ${days} days`} rows={(a?.byChannel ?? []).map((c) => ({ label: words(c.channel), value: c.salesMinor, display: fmt(c.salesMinor) }))} />
          )}
        </Reveal>
      </div>
      <h2 className="ops-section-title">Margin per dish</h2>
      <p className="ops-note">Price against the ingredient cost from the stock the supplies agent reads off delivery notes. Lowest margin first.</p>
      <RaystoGrid label="Margin by dish" rows={a?.marginByDish} loading={!data && !error} columns={columns} csvName="margin-by-dish" totals={false} emptyText="No cost known yet. Costs come from delivery notes the supplies agent reads." />
    </>
  );
}

/* ---------- Team ---------- */

const stateText: Record<Person["state"], string> = { onShift: "On shift", planned: "Planned", done: "Done" };

/** One shift, new or existing: the form a manager fills, shared by the grid's side panel and a person's dialog. */
function ShiftForm({
  editing,
  setEditing,
  busy,
  note,
  onSave,
  onClock,
  onCancel,
}: {
  editing: Partial<Shift>;
  setEditing: (s: Partial<Shift>) => void;
  busy: boolean;
  note: string;
  onSave: (e: FormEvent) => void;
  onClock: () => void;
  onCancel: () => void;
}) {
  return (
    <form className="ops-bo-form" onSubmit={onSave}>
      <span className="ops-eyebrow">{editing.id ? "Edit shift" : "New shift"}</span>
      <label>Name<input value={editing.name ?? ""} onChange={(e) => setEditing({ ...editing, name: e.target.value })} required maxLength={60} /></label>
      <label>Role<select value={editing.role ?? "staff"} onChange={(e) => setEditing({ ...editing, role: e.target.value })}>{["staff", "kitchen", "manager", "courier"].map((r) => <option key={r} value={r}>{words(r)}</option>)}</select></label>
      <label>Starts<input type="datetime-local" value={String(editing.startsAt ?? "")} onChange={(e) => setEditing({ ...editing, startsAt: e.target.value })} required /></label>
      <label>Ends<input type="datetime-local" value={String(editing.endsAt ?? "")} onChange={(e) => setEditing({ ...editing, endsAt: e.target.value })} required /></label>
      <label>Hourly rate<input type="number" inputMode="decimal" min="0" step="0.01" value={((editing.hourlyRateMinor ?? 0) / 100).toFixed(2)} onChange={(e) => setEditing({ ...editing, hourlyRateMinor: Math.round(Number(e.target.value) * 100) })} required /></label>
      <label>PayPal email for payouts<input type="email" value={editing.payoutEmail ?? ""} onChange={(e) => setEditing({ ...editing, payoutEmail: e.target.value })} /></label>
      {editing.id && !editing.clockOutAt && (
        <button type="button" className="ops-secondary" disabled={busy} onClick={onClock}>
          <Icon name="clock" size={18} />{editing.clockInAt ? "Clock out" : "Clock in"}
        </button>
      )}
      <button className="ops-primary" type="submit" disabled={busy}>{busy ? "Saving…" : "Save shift"}</button>
      <button type="button" className="ops-secondary" onClick={onCancel}>Cancel</button>
      {note && <p className="ops-note" role="status">{note}</p>}
    </form>
  );
}

export function TeamSection(props: { api: ConnectedApi; tenant: number; revision: string; currencyCode: string }) {
  return (
    <KitRoot>
      <Team {...props} />
    </KitRoot>
  );
}

function Team({
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
  const [tick, setTick] = useState(0);
  const week = useMemo(() => {
    const d = new Date();
    d.setDate(d.getDate() + offset * 7);
    return weekRange(d);
  }, [offset]);
  const { data, error } = useLoad(async () => {
    const [shifts, inbox, payouts] = await Promise.all([bo.shifts(week.from, week.to), bo.inbox(), bo.payouts().catch(() => [] as PayoutBatch[])]);
    return { shifts, inbox, payouts };
  }, [bo, week, revision, tick]);
  const reload = () => setTick((n) => n + 1);
  const [view, setView] = useState<"cards" | "grid">("cards");
  const [editing, setEditing] = useState<Partial<Shift> | null>(null);
  const [person, setPerson] = useState<{ name: string; shown: boolean }>();
  const { busy, note, act } = useAct(reload);
  const shifts = data?.shifts ?? [];
  const people = useMemo(() => peopleOf(shifts), [shifts]);
  const opened = people.find((p) => p.name === person?.name);
  const hours = shifts.reduce((n, s) => n + shiftHours(s), 0);
  const onShift = shifts.filter((s) => s.clockInAt && !s.clockOutAt).length;
  const columns = useMemo<ColDef<Shift>[]>(
    () => [
      { field: "name", headerName: "Person", minWidth: 140, cellClass: "ops-cell-strong" },
      { field: "role", headerName: "Role", valueFormatter: (p) => words(p.value), minWidth: 110 },
      dateCol<Shift>("Starts", "startsAt", { sort: "asc", minWidth: 140 }),
      dateCol<Shift>("Ends", "endsAt", { minWidth: 140 }),
      countCol<Shift>("Hours", (x) => shiftHours(x), { format: (n) => n.toFixed(2), flex: 0.5 }),
      moneyCol<Shift>("Pay", (x) => shiftPayMinor(x), currencyCode, { flex: 0.6, minWidth: 100 }),
      statusCol<Shift>("State", (x) => shiftState(x), { label: (v) => (v === "onShift" ? "On shift" : words(v)), minWidth: 110 }),
    ],
    [currencyCode],
  );
  const local = (iso?: string | null) => (iso ? new Date(iso).toISOString().slice(0, 16) : "");
  const edit = (s: Shift) => setEditing({ ...s, startsAt: local(s.startsAt), endsAt: local(s.endsAt) });
  const fresh = (base: Partial<Shift> = {}) =>
    setEditing({ role: "staff", startsAt: `${localDay(new Date())}T09:00`, endsAt: `${localDay(new Date())}T17:00`, hourlyRateMinor: 1500, ...base });
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
      return `Shift saved for ${editing.name}.`;
    });
  }
  const clock = (s: Pick<Shift, "id" | "version" | "name" | "clockInAt">) =>
    void act(async () => {
      await api.command("shift.clock", tenant, { action: s.clockInAt ? "out" : "in" }, { id: s.id, version: s.version });
      setEditing(null);
      return s.clockInAt ? `${s.name} clocked out.` : `${s.name} clocked in.`;
    });
  const form = editing && (
    <ShiftForm
      editing={editing}
      setEditing={setEditing}
      busy={busy}
      note={note}
      onSave={save}
      onClock={() => editing.id && editing.version !== undefined && clock({ id: editing.id, version: editing.version, name: editing.name ?? "", clockInAt: editing.clockInAt })}
      onCancel={() => setEditing(null)}
    />
  );
  return (
    <div className="ops-business">
      {error && <p className="ops-error" role="alert">{error}</p>}
      <div className="ops-kpis compact">
        <Kpi label="On shift now"><Count n={onShift} /></Kpi>
        <Kpi label="Shifts this week"><Count n={shifts.length} /></Kpi>
        <Kpi label="Hours"><Hours h={hours} /></Kpi>
        <Kpi label="Wages"><Cash minor={shifts.reduce((n, s) => n + shiftPayMinor(s), 0)} code={currencyCode} /></Kpi>
      </div>
      <div className="ops-bo-toolbar">
        <div className="ops-chips" role="group" aria-label="Week">
          <button onClick={() => setOffset(offset - 1)}>Previous week</button>
          <button aria-pressed={offset === 0} onClick={() => setOffset(0)}>This week</button>
          <button onClick={() => setOffset(offset + 1)}>Next week</button>
          <small>{week.from.slice(0, 10)} → {week.to.slice(0, 10)}</small>
        </div>
        <ViewSwitch label="Team view" value={view} onChange={(v) => { setView(v); setEditing(null); }} options={[["cards", "Cards"], ["grid", "Grid"]]} />
        <button className="ops-primary" onClick={() => { fresh(); if (view === "cards") setPerson({ name: "", shown: true }); }}>
          <Icon name="plus" size={18} />Add a shift
        </button>
      </div>
      {view === "cards" ? (
        people.length === 0 ? (
          <Empty>{data ? "No shift this week. Add one, or let the copilot plan the roster." : "Loading the week…"}</Empty>
        ) : (
          <div className="ops-bo-people">
            {people.map((p, i) => {
              const paid = payoutFor(p.name, data?.payouts ?? []);
              return (
                <Reveal key={p.name} index={i} visitKey="team-people">
                  <ContainerCard layoutId={`person-${slug(p.name)}`} as="article" className="ops-bo-person">
                    <header>
                      <span className="ops-bo-avatar" aria-hidden="true">{initials(p.name)}</span>
                      <div>
                        <h3>{p.name}</h3>
                        <small>{words(p.role)}</small>
                      </div>
                      {pill({ value: p.state === "onShift" ? "onShift" : p.state, valueFormatted: stateText[p.state] })}
                    </header>
                    <dl className="ops-bo-person-figures">
                      <div><dt>Hours this week</dt><dd><Hours h={p.hours} /></dd></div>
                      <div><dt>Wage</dt><dd><Cash minor={p.wageMinor} code={currencyCode} /></dd></div>
                      <div>
                        <dt>Payout</dt>
                        <dd>{paid ? <>{pill({ value: paid.state })} {currency(paid.amountMinor, paid.currency)}</> : p.payoutEmail ? "None yet" : "No PayPal email"}</dd>
                      </div>
                    </dl>
                    <button className="ops-secondary" onClick={() => { setEditing(null); setPerson({ name: p.name, shown: true }); }}>
                      Shifts and details<span className="m3-sr"> for {p.name}</span>
                    </button>
                  </ContainerCard>
                </Reveal>
              );
            })}
          </div>
        )
      ) : (
        <div className="ops-business with-panel">
          <RaystoGrid<Shift> label="Shifts" rows={shifts} loading={!data && !error} columns={columns} getRowId={(p) => String(p.data.id)} onRowClicked={(e) => e.data && edit(e.data)} rowSelection={{ mode: "singleRow", checkboxes: false, enableClickSelection: true }} csvName="shifts" emptyText="No shift this week. Add one, or let the copilot plan the roster." tall />
          <aside className="ops-side">
            {form ?? (
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
                        <button className="ops-secondary" disabled={busy} onClick={() => clock(s)}>
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
      )}
      {person && (
        <ContainerDialog
          layoutId={`person-${slug(person.name)}`}
          open={person.shown}
          onClose={() => { setPerson({ ...person, shown: false }); setEditing(null); }}
          title={person.name ? `${person.name}'s shifts this week` : "New shift"}
        >
          <div className="ops-bo-dialog">
            {opened ? (
              <>
                <span className="ops-eyebrow">{words(opened.role)} · {stateText[opened.state]}</span>
                <h2>{opened.name}</h2>
                <dl className="ops-bo-figures">
                  <dt>Hours this week</dt><dd>{opened.hours.toFixed(2)}</dd>
                  <dt>Wage</dt><dd>{currency(opened.wageMinor, currencyCode)}</dd>
                  <dt>PayPal email for payouts</dt><dd>{opened.payoutEmail ?? "Not set: payouts skip this person"}</dd>
                </dl>
                <ul className="ops-payments">
                  {opened.shifts.map((s) => (
                    <li key={s.id}>
                      <strong>{time(s.startsAt)} → {time(s.endsAt)}</strong>
                      <span>{pill({ value: shiftState(s), valueFormatted: shiftState(s) === "onShift" ? "On shift" : words(shiftState(s)) })} {shiftHours(s).toFixed(2)} h · {currency(shiftPayMinor(s), currencyCode)}</span>
                      <button className="ops-secondary" onClick={() => edit(s)}>Edit<span className="m3-sr"> the shift starting {time(s.startsAt)}</span></button>
                    </li>
                  ))}
                </ul>
                {form ?? (
                  <button className="ops-primary" onClick={() => fresh({ name: opened.name, role: opened.role, hourlyRateMinor: opened.shifts[0]?.hourlyRateMinor ?? 1500, payoutEmail: opened.payoutEmail ?? undefined })}>
                    <Icon name="plus" size={18} />Add a shift for {opened.name}
                  </button>
                )}
              </>
            ) : (
              form ?? <p className="ops-note">Saved. Close this to see the week.</p>
            )}
          </div>
        </ContainerDialog>
      )}
      <Proposals api={api} tenant={tenant} inbox={data?.inbox ?? []} commands={["shift.plan"]} onDone={reload} />
      <small className="ops-note">Hours feed the pay run in Money → Pay &amp; tips. The copilot proposes next week's roster from sales by hour; {agentName("copilot")} never changes a shift without you.</small>
    </div>
  );
}

/** Customers by first tag (rows) with spend and visits, totals per tag and overall: AG Studio's pivot. */
function customersPivot(code: string): StudioWidgetSpec {
  return {
    type: "pivot-grid",
    format: {
      title: { text: `Customers by tag: spent with PayPal (${code}) and visits`, enabled: true },
      style: { grandTotalRow: { enabled: true } },
    },
    dataMapping: {
      rows: [{ id: "customers.tag" }, { id: "customers.customer" }],
      columns: [],
      values: [
        { id: "customers.spent", aggregation: "sum" },
        { id: "customers.visits", aggregation: "sum" },
      ],
    },
  };
}
