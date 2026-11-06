"use client";
import { submittedFormAcknowledgement } from "./workspace-drafts";
import { useWorkspaceTab } from "@/lib/connected/workspace-location";
/**
 * The AI accountant (stream S1). The books are derived from Raysto's own
 * records (captures, refunds, payouts, receipts, bills, payment requests),
 * so every figure here traces back to a PayPal id or a person's proof.
 *
 * - Overview: cash in and out, bills due, overdue and owed, the rules'
 *   findings, and the accountant's proposals to approve.
 * - P&L, Cash flow and Payables aging run on AG Studio (pivot with totals,
 *   a combo chart); the same figures sit in plain grids beneath.
 * - Bills: drop a bill and the accountant reads it; pay through PayPal
 *   Payouts after the identity check, or mark it paid elsewhere with proof.
 * - Requests: a pay link with its QR code, or a PayPal invoice once
 *   Invoicing is enabled on the Sandbox app.
 * - VAT: collected on sales against paid on bills and receipts.
 *
 * Nothing moves money without a person, except a monthly bill to a payee
 * already paid, within the owner's own limit (Settings → limits).
 */
import {
  useEffect,
  useMemo,
  useRef,
  useState,
  type FormEvent,
  type ReactNode,
} from "react";
import type { ColDef } from "ag-grid-community";
import { QRCodeSVG } from "qrcode.react";
import { ApiFailure, type ConnectedApi } from "@/lib/connected/api";
import type { AgentActionRow } from "@/lib/connected/business";
import { currency, type Json } from "@/lib/connected/contracts";
import {
  countCol,
  dateCol,
  day,
  idCol,
  moneyCol,
  statusCol,
  words,
} from "@/lib/connected/grid-columns";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { approvalNotice } from "@/lib/connected/money-view";
import { MotionRoot } from "@/lib/connected/motion";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import {
  StudioCanvas,
  StudioWidget,
} from "@/lib/connected/studio/studio-canvas";
import {
  accountant,
  agingPivot,
  agingRows,
  billActions,
  billCategoryWords,
  billStateTone,
  billStateWords,
  cashRows,
  cashState,
  kpisOf,
  paypalEvidence,
  pnlPivot,
  pnlRows,
  requestData,
  requestStateWords,
  severityWords,
  source,
  type AccountantApi,
  type BillRow,
  type BillState,
  type Finding,
  type PnlRow,
  type RequestDraft,
  type RequestRow,
  type VatPage,
} from "@/lib/connected/accountant";
import { AgentPanel, useLoad } from "./business-sections";
import type { SectionProps } from "./group-section";
import { Icon } from "./icons";
import { CountUp, Reveal, SnackbarProvider, Stamp, useSnackbar } from "./m3";
import { RaystoGrid } from "./raysto-grid";
import { UploadDrop } from "./upload-drop";
import "./accountant-section.css";

export type AccountantTab =
  "overview" | "pnl" | "cash" | "bills" | "aging" | "requests" | "vat";
const tabs: [AccountantTab, string][] = [
  ["overview", "Overview"],
  ["pnl", "P&L"],
  ["cash", "Cash flow"],
  ["bills", "Bills"],
  ["aging", "Payables aging"],
  ["requests", "Requests"],
  ["vat", "VAT"],
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

/** One command with its busy state; the outcome is a snackbar, or a note line without one. */
function useAct(onDone?: () => void) {
  const notice = useNotice();
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  async function act(run: () => Promise<string | void>) {
    const acknowledge = submittedFormAcknowledgement();
    setBusy(true);
    setNote("");
    try {
      const said = (await run()) ?? "Done.";
      acknowledge();
      if (notice) notice.show({ message: said });
      else setNote(said);
      onDone?.();
    } catch (e) {
      setNote(fail(e));
    } finally {
      setBusy(false);
    }
  }
  return { busy, note, setNote, act };
}

function Kpi({
  label,
  children,
  alert,
  hint,
}: {
  label: string;
  children: ReactNode;
  alert?: boolean;
  hint?: string;
}) {
  return (
    <div className={`ops-kpi ${alert ? "alert" : ""}`}>
      <span>{label}</span>
      <strong>{children}</strong>
      {hint && <small>{hint}</small>}
    </div>
  );
}

const Cash = ({ minor, code }: { minor: number; code: string }) => (
  <CountUp value={Math.round(minor)} format={(n) => currency(n, code)} />
);

/** The accountant's proposals for some commands, each approved like any other. */
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
  commands?: string[];
  onDone: () => void;
}) {
  const notice = useNotice();
  const mine = commands
    ? inbox.filter((a) => commands.includes(a.command))
    : inbox;
  if (mine.length === 0) return null;
  return (
    <div className="ops-acc-proposals">
      {mine.map((a, i) => (
        <Reveal
          key={`${a.id}-${a.version}`}
          index={i}
          as="section"
          className="ops-panel ops-bo-card"
        >
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
  ac: AccountantApi;
  currencyCode: string;
  inbox: AgentActionRow[];
  refresh: () => void;
  version: string;
  go: (tab: AccountantTab) => void;
};

export function AccountantSection({
  api,
  tenant,
  revision,
  currencyCode,
  billsOnly = false,
}: SectionProps & { billsOnly?: boolean }) {
  const [tab, setTab] = useWorkspaceTab<AccountantTab>(
    billsOnly ? "supplies" : "accountant",
    tabs.map(([t]) => t),
    billsOnly ? "bills" : "overview",
  );
  const [tick, setTick] = useState(0);
  const ac = useMemo(() => accountant(api, tenant), [api, tenant]);
  const { data: inbox } = useLoad(() => ac.inbox(), [ac, revision, tick]);
  const refresh = () => setTick((n) => n + 1);
  const props: TabProps = {
    api,
    tenant,
    ac,
    currencyCode,
    inbox: inbox ?? [],
    refresh,
    version: `${revision}-${tick}`,
    go: setTab,
  };
  const waiting = (inbox ?? []).length;
  return (
    <KitRoot>
      <div className="ops-business ops-accountant">
        {!billsOnly && (
          <div
            className="ops-chips ops-bo-tabs"
            role="tablist"
            aria-label="Accountant"
          >
            {tabs.map(([t, label]) => (
              <button
                key={t}
                role="tab"
                tabIndex={tab === t ? 0 : -1}
                aria-selected={tab === t}
                aria-pressed={tab === t}
                onClick={() => setTab(t)}
              >
                {label}
                {t === "overview" && waiting > 0 && (
                  <span
                    className="ops-acc-badge"
                    aria-label={`${waiting} waiting for you`}
                  >
                    {waiting}
                  </span>
                )}
              </button>
            ))}
          </div>
        )}
        {billsOnly ? (
          <BillsTab {...props} />
        ) : tab === "overview" ? (
          <OverviewTab key={tab} {...props} />
        ) : tab === "pnl" ? (
          <PnlTab key={tab} {...props} />
        ) : tab === "cash" ? (
          <CashTab key={tab} {...props} />
        ) : tab === "bills" ? (
          <BillsTab key={tab} {...props} />
        ) : tab === "aging" ? (
          <AgingTab key={tab} {...props} />
        ) : tab === "requests" ? (
          <RequestsTab key={tab} {...props} />
        ) : (
          <VatTab key={tab} {...props} />
        )}
        <small className="ops-note">
          The books are derived from your own records: PayPal captures, refunds
          and payouts, receipts, bills and payment requests. PayPal Sandbox: no
          real money moves.
        </small>
      </div>
    </KitRoot>
  );
}

/* ---------- Overview ---------- */

function OverviewTab({
  api,
  tenant,
  ac,
  currencyCode,
  inbox,
  refresh,
  version,
  go,
}: TabProps) {
  const bills = useLoad(() => ac.bills(true), [ac, version]);
  const requests = useLoad(() => ac.requests(), [ac, version]);
  const cash = useLoad(() => ac.cashflow(30), [ac, version]);
  const { busy, note, act } = useAct(refresh);
  const code = bills.data?.currency ?? currencyCode;
  const k = kpisOf(bills.data, requests.data, cash.data);
  const findings = bills.data?.findings ?? [];
  const error = bills.error || requests.error || cash.error;
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis ops-acc-kpis">
        <Kpi label="Money in, 30 days">
          {cash.data ? (
            <Cash minor={k.cashInMinor} code={code} />
          ) : (
            <span aria-label="Loading financial measure">—</span>
          )}
        </Kpi>
        <Kpi label="Money out, 30 days">
          {cash.data ? (
            <Cash minor={k.cashOutMinor} code={code} />
          ) : (
            <span aria-label="Loading financial measure">—</span>
          )}
        </Kpi>
        <Kpi label="Net, 30 days" alert={k.netMinor < 0}>
          {cash.data ? (
            <Cash minor={k.netMinor} code={code} />
          ) : (
            <span aria-label="Loading financial measure">—</span>
          )}
        </Kpi>
        <Kpi label="Bills to pay">
          {bills.data ? (
            <Cash minor={k.billsDueMinor} code={code} />
          ) : (
            <span aria-label="Loading financial measure">—</span>
          )}
        </Kpi>
        <Kpi label="Overdue" alert={k.overdueMinor > 0}>
          {bills.data ? (
            <Cash minor={k.overdueMinor} code={code} />
          ) : (
            <span aria-label="Loading financial measure">—</span>
          )}
        </Kpi>
        <Kpi label="Owed to you">
          {requests.data ? (
            <Cash minor={k.receivablesMinor} code={code} />
          ) : (
            <span aria-label="Loading financial measure">—</span>
          )}
        </Kpi>
      </div>
      <div className="ops-bo-toolbar">
        <p className="ops-note">
          The accountant checks the books by fixed rules (late or duplicate
          bills, unusual amounts, late payers, failed payouts, VAT and cash),
          explains each finding and proposes the fix. You approve every payment.
        </p>
        <button
          className="ops-primary"
          disabled={busy}
          onClick={() =>
            void act(async () => {
              await ac.run("month");
              return "The accountant is reviewing the month. Its proposals appear here in a few seconds.";
            })
          }
        >
          <Icon name="agents" size={18} />
          Ask the accountant to review the month
        </button>
      </div>
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
      <Proposals api={api} tenant={tenant} inbox={inbox} onDone={refresh} />
      <section
        className="ops-panel ops-acc-findings"
        aria-labelledby="acc-findings"
      >
        <h2 id="acc-findings">What needs attention</h2>
        {!bills.data && !bills.error ? (
          <p className="ops-note">Reading the books…</p>
        ) : findings.length === 0 ? (
          <p className="ops-note">
            Nothing needs attention: bills are on time, requests are paid, and
            the books balance.
          </p>
        ) : (
          <ul className="ops-acc-finding-list">
            {findings.map((f, i) => (
              <FindingCard key={f.ref} f={f} code={code} index={i} go={go} />
            ))}
          </ul>
        )}
      </section>
    </>
  );
}

function FindingCard({
  f,
  code,
  index,
  go,
}: {
  f: Finding;
  code: string;
  index: number;
  go: (t: AccountantTab) => void;
}) {
  const target: AccountantTab | null = f.billId
    ? "bills"
    : f.requestId
      ? "requests"
      : f.kind === "cash_shortfall"
        ? "cash"
        : f.kind.startsWith("vat")
          ? "vat"
          : null;
  return (
    <Reveal as="li" index={index} className={`ops-acc-finding ${f.severity}`}>
      <span className="ops-acc-severity">{severityWords[f.severity]}</span>
      <strong>{words(f.kind)}</strong>
      <p>{f.facts}</p>
      <div className="ops-acc-finding-foot">
        {f.amountMinor > 0 && <code>{currency(f.amountMinor, code)}</code>}
        {f.fix && (
          <small>The accountant can propose: {words(f.fix.command)}</small>
        )}
        {target && (
          <button className="ops-secondary" onClick={() => go(target)}>
            Open {tabs.find(([t]) => t === target)?.[1]}
            <Icon name="arrow" size={16} />
          </button>
        )}
      </div>
    </Reveal>
  );
}

/* ---------- P&L ---------- */

function PnlTab({ ac, currencyCode, version }: TabProps) {
  const [month, setMonth] = useState("");
  const { data, error } = useLoad(
    () => ac.pnl(month || undefined),
    [ac, version, month],
  );
  const code = data?.currency ?? currencyCode;
  const studio = useMemo(
    () => source("pnl", pnlRows(data?.rows ?? [])),
    [data],
  );
  const widget = useMemo(() => pnlPivot(code), [code]);
  const columns = useMemo<ColDef<PnlRow>[]>(
    () => [
      { field: "month", headerName: "Month", minWidth: 110 },
      { field: "group", headerName: "Kind", minWidth: 110 },
      {
        headerName: "Account",
        valueGetter: (p) =>
          p.data ? `${p.data.account} ${p.data.accountName}` : "",
        minWidth: 200,
        cellClass: "ops-cell-strong",
      },
      moneyCol<PnlRow>("Amount", "amountMinor", code),
    ],
    [code],
  );
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-bo-toolbar">
        <label className="ops-acc-month">
          Month
          <input
            type="month"
            value={month}
            onChange={(e) => setMonth(e.target.value)}
            aria-describedby="acc-month-hint"
          />
        </label>
        <small id="acc-month-hint" className="ops-note">
          Empty shows the last three months.
        </small>
      </div>
      <div className="ops-kpis compact">
        <Kpi label="Revenue">
          <Cash minor={data?.revenueMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Costs">
          <Cash minor={data?.costsMinor ?? 0} code={code} />
        </Kpi>
        <Kpi
          label={
            data?.basis === "management-accrual-v1" && data?.complete !== false
              ? "Operating result"
              : "Recorded result"
          }
          alert={(data?.netMinor ?? 0) < 0}
        >
          <Cash minor={data?.netMinor ?? 0} code={code} />
        </Kpi>
      </div>
      <p className="ops-note">
        {data?.basis === "management-accrual-v1"
          ? "Management basis from the reviewed cutover; only recorded revenue and costs are included."
          : "Legacy recognition basis; this recorded result is not an accrual operating result."}
        {data?.partialPeriod &&
          ` This report starts at ${data.effectiveFrom}; earlier records use the legacy basis.`}
      </p>
      {data?.complete === false && (
        <p className="ops-note" role="status">
          Incomplete financial evidence: {data.issues?.join(" ")}
        </p>
      )}
      {data?.feesEstimated && (
        <p className="ops-note ops-acc-estimate">
          PayPal fees are estimates (3.49% + 0.49 a payment) until Transaction
          Search is enabled on the Sandbox app; payout fees are PayPal&apos;s
          own.
        </p>
      )}
      <StudioWidget
        label="Accountant: profit and loss"
        source={studio}
        widget={widget}
        height={460}
      />
      <RaystoGrid<PnlRow>
        label="Profit and loss lines"
        rows={data?.rows}
        columns={columns}
        loading={!data && !error}
        emptyText="No revenue or costs in this period yet."
        getRowId={(p) => `${p.data.month}-${p.data.account}`}
        csvName="raysto-profit-and-loss"
      />
    </>
  );
}

/* ---------- Cash flow ---------- */

type DueItem = {
  date: string;
  kind: string;
  vendor: string;
  amountMinor: number;
  overdue: boolean;
};

function CashTab({ ac, currencyCode, version }: TabProps) {
  const { data, error } = useLoad(() => ac.cashflow(30), [ac, version]);
  const code = data?.currency ?? currencyCode;
  const studio = useMemo(() => source("cash", cashRows(data)), [data]);
  const state = useMemo(() => cashState(code), [code]);
  const due = useMemo<DueItem[]>(
    () =>
      (data?.forecast ?? []).flatMap((d) =>
        d.items.map((x) => ({ ...x, date: d.date })),
      ),
    [data],
  );
  const columns = useMemo<ColDef<DueItem>[]>(
    () => [
      dateCol<DueItem>("Day", "date", { dayOnly: true }),
      {
        field: "vendor",
        headerName: "Vendor",
        minWidth: 160,
        cellClass: "ops-cell-strong",
      },
      statusCol<DueItem>(
        "What",
        (x) =>
          x.overdue
            ? "overdue"
            : x.kind === "recurringExpected"
              ? "planned"
              : x.kind === "billToReview"
                ? "review"
                : "due",
        {
          label: (v) =>
            ({
              overdue: "Overdue",
              planned: "Monthly, expected",
              review: "To review",
              due: "Due",
            })[String(v)] ?? String(v),
        },
      ),
      moneyCol<DueItem>("Amount", "amountMinor", code),
    ],
    [code],
  );
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis compact">
        <Kpi label="Cash now (PayPal and till)">
          <Cash minor={data?.openingMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Lowest in 30 days" alert={(data?.lowestMinor ?? 0) < 0}>
          <Cash minor={data?.lowestMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Average day in">
          <Cash minor={data?.averageDailyInMinor ?? 0} code={code} />
        </Kpi>
      </div>
      {data && <p className="ops-note">{data.basis}</p>}
      <StudioCanvas
        label="Accountant: cash flow"
        sources={[studio]}
        initialState={state}
        height={560}
      />
      <RaystoGrid<DueItem>
        label="Bills due in the next 30 days"
        rows={data ? due : undefined}
        columns={columns}
        loading={!data && !error}
        emptyText="No bill falls due in the next 30 days."
        getRowId={(p) =>
          `${p.data.date}-${p.data.vendor}-${p.data.amountMinor}`
        }
        csvName="raysto-cash-due"
      />
    </>
  );
}

/* ---------- Bills ---------- */

const toneWords = Object.fromEntries(
  Object.entries(billStateTone).map(([s, tone]) => [
    tone,
    billStateWords[s as BillState],
  ]),
);

function BillsTab({
  api,
  tenant,
  ac,
  currencyCode,
  inbox,
  refresh,
  version,
}: TabProps) {
  const { data, error } = useLoad(() => ac.bills(), [ac, version]);
  const [openId, setOpenId] = useState<number>();
  const [manual, setManual] = useState(false);
  const { busy, note, setNote, act } = useAct(refresh);
  const later = useRef<number[]>([]);
  useEffect(() => () => later.current.forEach((t) => clearTimeout(t)), []);
  const code = data?.currency ?? currencyCode;
  const opened = data?.rows.find((b) => b.id === openId);
  const columns = useMemo<ColDef<BillRow>[]>(
    () => [
      idCol<BillRow>("Bill", "id", { prefix: "#" }),
      {
        field: "vendor",
        headerName: "Vendor",
        minWidth: 160,
        cellClass: "ops-cell-strong",
      },
      {
        headerName: "Category",
        valueGetter: (p) =>
          p.data ? (billCategoryWords[p.data.category] ?? p.data.category) : "",
        minWidth: 130,
      },
      statusCol<BillRow>(
        "State",
        (b) => (b.overdue ? "overdue" : billStateTone[b.state]),
        {
          label: (v) =>
            v === "overdue" ? "Overdue" : (toneWords[String(v)] ?? words(v)),
        },
      ),
      moneyCol<BillRow>("Amount", "amountMinor", (b) => b.currency),
      moneyCol<BillRow>("VAT", "vatMinor", (b) => b.currency),
      dateCol<BillRow>("Due", "dueAt", { dayOnly: true }),
      {
        headerName: "PayPal or proof",
        valueGetter: (p) => (p.data ? paypalEvidence(p.data) : ""),
        minWidth: 220,
        tooltipValueGetter: (p) => (p.data ? paypalEvidence(p.data) : ""),
      },
      {
        headerName: "Pays by",
        valueGetter: (p) =>
          p.data?.payVia === "paypal" ? "PayPal Payouts" : "Elsewhere",
        minWidth: 130,
      },
    ],
    [],
  );
  function snapped(mediaId: number) {
    return act(async () => {
      const r = await ac.snap(mediaId);
      if (r.duplicateOfId) {
        setOpenId(r.duplicateOfId);
        return `This file is already bill #${r.duplicateOfId}; nothing new was read.`;
      }
      // The agent reads in a few seconds: look again twice.
      later.current.push(
        window.setTimeout(refresh, 5000),
        window.setTimeout(refresh, 12000),
      );
      return "The accountant is reading the bill. It appears here in a few seconds, in review.";
    });
  }
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis compact">
        <Kpi label="To pay">
          <Cash minor={data?.summary.dueMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Overdue" alert={(data?.summary.overdueCount ?? 0) > 0}>
          <Cash minor={data?.summary.overdueMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Paid this month">
          <Cash minor={data?.summary.paidThisMonthMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Expected next">
          <Cash minor={data?.summary.expectedMinor ?? 0} code={code} />
        </Kpi>
      </div>
      <div className="ops-acc-intake">
        <UploadDrop
          api={api}
          tenant={tenant}
          purpose="bill"
          label="Drop a bill here, or choose a photo or PDF"
          hint="Electricity, water, rent, internet, a supplier invoice… A PDF of up to five pages, or a photo, up to 8 MB."
          onReady={(id) => snapped(id)}
          disabled={busy}
        />
        <button
          className="ops-secondary"
          aria-expanded={manual}
          onClick={() => setManual((m) => !m)}
        >
          <Icon name="plus" size={18} />
          {manual ? "Close the form" : "Enter a bill by hand"}
        </button>
      </div>
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
      {manual && (
        <ManualBill
          ac={ac}
          code={code}
          onSaved={(b) => {
            setManual(false);
            setOpenId(b.id);
            setNote(
              `Bill #${b.id} saved, ${billStateWords[b.state].toLowerCase()}.`,
            );
            refresh();
          }}
        />
      )}
      <Proposals
        api={api}
        tenant={tenant}
        inbox={inbox}
        commands={["bill.pay", "bill.record", "bill.markPaid"]}
        onDone={refresh}
      />
      <RaystoGrid<BillRow>
        label="Bills"
        rows={data?.rows}
        columns={columns}
        loading={!data && !error}
        emptyText="No bills yet. Drop one above: the accountant reads it and puts it in review."
        getRowId={(p) => String(p.data.id)}
        onRowClicked={(e) => e.data && setOpenId(e.data.id)}
        csvName="raysto-bills"
      />
      {opened && (
        <BillDetail
          key={`${opened.id}-${opened.version}`}
          api={api}
          tenant={tenant}
          ac={ac}
          bill={opened}
          onChanged={refresh}
          onClose={() => setOpenId(undefined)}
        />
      )}
    </>
  );
}

function ManualBill({
  ac,
  code,
  onSaved,
}: {
  ac: AccountantApi;
  code: string;
  onSaved: (b: BillRow) => void;
}) {
  const [f, setF] = useState({
    vendor: "",
    category: "electricity",
    amount: "",
    vat: "",
    dueAt: "",
    payeeEmail: "",
    reference: "",
    monthly: false,
  });
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  async function submit(e: FormEvent) {
    e.preventDefault();
    setError("");
    const amount = Math.round(Number(f.amount.replace(",", ".")) * 100);
    const vat = f.vat ? Math.round(Number(f.vat.replace(",", ".")) * 100) : 0;
    if (!Number.isFinite(amount) || amount < 1)
      return setError("Enter the amount to pay.");
    if (!Number.isFinite(vat) || vat < 0 || vat > amount)
      return setError("VAT is part of the amount, at most all of it.");
    setBusy(true);
    try {
      const saved = await ac.save({
        vendor: f.vendor.trim(),
        category: f.category,
        amountMinor: amount,
        vatMinor: vat,
        ...(f.reference.trim() ? { reference: f.reference.trim() } : {}),
        ...(f.dueAt
          ? { dueAt: new Date(`${f.dueAt}T23:59:00`).toISOString() }
          : {}),
        issuedAt: new Date().toISOString(),
        ...(f.payeeEmail.trim() ? { payeeEmail: f.payeeEmail.trim() } : {}),
        ...(f.monthly ? { recurring: "monthly" } : {}),
      });
      onSaved(saved);
    } catch (err) {
      setError(fail(err));
    } finally {
      setBusy(false);
    }
  }
  return (
    <Reveal
      as="section"
      className="ops-panel ops-bo-card"
      visitKey="acc-manual"
    >
      <span className="ops-eyebrow">New bill</span>
      <h2>Enter a bill by hand</h2>
      <form className="ops-bo-form" onSubmit={submit}>
        <label>
          Vendor
          <input
            value={f.vendor}
            onChange={(e) => setF({ ...f, vendor: e.target.value })}
            required
            maxLength={120}
          />
        </label>
        <label>
          Category
          <select
            value={f.category}
            onChange={(e) => setF({ ...f, category: e.target.value })}
          >
            {Object.entries(billCategoryWords).map(([k, v]) => (
              <option key={k} value={k}>
                {v}
              </option>
            ))}
          </select>
        </label>
        <label>
          Amount to pay ({code})
          <input
            inputMode="decimal"
            value={f.amount}
            onChange={(e) => setF({ ...f, amount: e.target.value })}
            required
            placeholder="196.10"
          />
        </label>
        <label>
          VAT included ({code})
          <input
            inputMode="decimal"
            value={f.vat}
            onChange={(e) => setF({ ...f, vat: e.target.value })}
            placeholder="0.00"
          />
        </label>
        <label>
          Reference
          <input
            value={f.reference}
            onChange={(e) => setF({ ...f, reference: e.target.value })}
            maxLength={80}
          />
        </label>
        <label>
          Due
          <input
            type="date"
            value={f.dueAt}
            onChange={(e) => setF({ ...f, dueAt: e.target.value })}
          />
        </label>
        <label className="wide">
          Vendor&apos;s PayPal email (to pay through PayPal Payouts)
          <input
            type="email"
            value={f.payeeEmail}
            onChange={(e) => setF({ ...f, payeeEmail: e.target.value })}
            placeholder="Leave empty to pay elsewhere"
          />
        </label>
        <label className="ops-acc-check">
          <input
            type="checkbox"
            checked={f.monthly}
            onChange={(e) => setF({ ...f, monthly: e.target.checked })}
          />
          Comes every month
        </label>
        <button className="ops-primary" type="submit" disabled={busy}>
          <Icon name="save" size={18} />
          {busy ? "Saving…" : "Save for review"}
        </button>
      </form>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
    </Reveal>
  );
}

/** Pays a bill through PayPal Payouts: the identity check first, then one request key for the attempt. */
function PayButton({
  api,
  tenant,
  ac,
  bill,
  onDone,
}: {
  api: ConnectedApi;
  tenant: number;
  ac: AccountantApi;
  bill: BillRow;
  onDone: (message: string) => void;
}) {
  const known = isJudgeVenue(tenant) ? judge.password : "";
  const [asking, setAsking] = useState(false);
  const [password, setPassword] = useState(known);
  const [byPassword, setByPassword] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [key] = useState(() => crypto.randomUUID());
  async function pay() {
    const r = await ac.pay(bill, key);
    const id = typeof r.providerBatchId === "string" ? r.providerBatchId : "";
    onDone(
      id
        ? `Sent to PayPal Payouts: batch ${id}. It shows as paid when PayPal confirms.`
        : "Sent to PayPal Payouts.",
    );
  }
  async function start() {
    setError("");
    setBusy(true);
    try {
      setByPassword(await usesPassword());
      setAsking(true);
    } finally {
      setBusy(false);
    }
  }
  async function confirm(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError("");
    try {
      await stepUp(api, tenant, byPassword ? password : undefined);
      setAsking(false);
      await pay();
    } catch (err) {
      setError(
        err instanceof ApiFailure && err.code === "payee_missing"
          ? err.message
          : fail(err),
      );
    } finally {
      setBusy(false);
      setPassword(known);
    }
  }
  return (
    <div className="ops-bo-stepup">
      {asking ? (
        <form className="ops-bo-form" onSubmit={confirm}>
          {byPassword && (
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
          )}
          <button className="ops-primary" type="submit" disabled={busy}>
            {busy
              ? "Asking PayPal…"
              : byPassword
                ? "Confirm and pay"
                : "Confirm with Google and pay"}
          </button>
        </form>
      ) : (
        <button
          className="ops-primary"
          disabled={busy}
          onClick={() => void start()}
        >
          <Icon name="paypal" size={18} />
          Pay {currency(bill.amountMinor, bill.currency)} via PayPal (identity
          check)
        </button>
      )}
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}

function BillDetail({
  api,
  tenant,
  ac,
  bill,
  onChanged,
  onClose,
}: {
  api: ConnectedApi;
  tenant: number;
  ac: AccountantApi;
  bill: BillRow;
  onChanged: () => void;
  onClose: () => void;
}) {
  const { busy, note, act } = useAct(onChanged);
  const notice = useNotice();
  const [proving, setProving] = useState(false);
  const [proofNote, setProofNote] = useState("");
  const [voiding, setVoiding] = useState(false);
  const [reason, setReason] = useState("");
  const actions = billActions(bill);
  const evidence = paypalEvidence(bill);
  async function openFile(id: number) {
    try {
      const blob = await api.file(id);
      window.open(URL.createObjectURL(blob), "_blank", "noopener");
    } catch (e) {
      notice?.show({ message: fail(e) });
    }
  }
  return (
    <Reveal
      as="section"
      className="ops-panel ops-bo-card ops-acc-detail"
      visitKey={`acc-bill-${bill.id}`}
      id="acc-bill-detail"
    >
      <div className="ops-acc-detail-head">
        <div>
          <span className="ops-eyebrow">
            Bill #{bill.id} ·{" "}
            {billCategoryWords[bill.category] ?? bill.category} ·{" "}
            {billStateWords[bill.state]}
          </span>
          <h2>
            {bill.vendor}: {currency(bill.amountMinor, bill.currency)}
          </h2>
        </div>
        <Stamp paid={bill.state === "paid"} label="PAID" />
        <button
          className="ops-secondary"
          onClick={onClose}
          aria-label="Close the bill"
        >
          <Icon name="cross" size={18} />
        </button>
      </div>
      {bill.read?.explanation && <p>{bill.read.explanation}</p>}
      <dl className="ops-bo-figures">
        {bill.reference && (
          <>
            <dt>Reference</dt>
            <dd>
              <code>{bill.reference}</code>
            </dd>
          </>
        )}
        <dt>VAT included</dt>
        <dd>{currency(bill.vatMinor, bill.currency)}</dd>
        {bill.issuedAt && (
          <>
            <dt>Issued</dt>
            <dd>{day(bill.issuedAt)}</dd>
          </>
        )}
        {bill.dueAt && (
          <>
            <dt>Due</dt>
            <dd>
              {day(bill.dueAt)}
              {bill.overdue ? " (overdue)" : ""}
            </dd>
          </>
        )}
        {bill.recurring && (
          <>
            <dt>Repeats</dt>
            <dd>Every month</dd>
          </>
        )}
        <dt>Pays by</dt>
        <dd>
          {bill.payVia === "paypal"
            ? `PayPal Payouts to ${bill.payeeEmail}`
            : "Elsewhere (bank, direct debit or cash)"}
        </dd>
        {evidence && (
          <>
            <dt>PayPal or proof</dt>
            <dd>
              <code>{evidence}</code>
            </dd>
          </>
        )}
        {bill.read?.from === "ai" && bill.read.confidence != null && (
          <>
            <dt>Read by the AI</dt>
            <dd>
              {Math.round(bill.read.confidence * 100)}% sure
              {bill.read.notes ? `: ${bill.read.notes}` : ""}
            </dd>
          </>
        )}
        {bill.read?.basis && (
          <>
            <dt>Expected</dt>
            <dd>{bill.read.basis}</dd>
          </>
        )}
        {bill.read?.paidNote && (
          <>
            <dt>Note</dt>
            <dd>{bill.read.paidNote}</dd>
          </>
        )}
        {bill.read?.voidReason && (
          <>
            <dt>Voided</dt>
            <dd>{bill.read.voidReason}</dd>
          </>
        )}
      </dl>
      {bill.duplicateOfId && (
        <p className="ops-error" role="alert">
          This looks like bill #{bill.duplicateOfId} (same file, or same vendor,
          reference and amount). Approve only if it is a different bill.
        </p>
      )}
      <div className="ops-acc-actions">
        {bill.sourceMediaId && (
          <button
            className="ops-secondary"
            onClick={() => void openFile(bill.sourceMediaId!)}
          >
            <Icon name="invoice" size={18} />
            Open the bill
          </button>
        )}
        {bill.proofMediaId && (
          <button
            className="ops-secondary"
            onClick={() => void openFile(bill.proofMediaId!)}
          >
            <Icon name="receipt" size={18} />
            Open the proof
          </button>
        )}
        {actions.includes("pay") && !bill.duplicateOfId && (
          <PayButton
            api={api}
            tenant={tenant}
            ac={ac}
            bill={bill}
            onDone={(m) => void act(async () => m)}
          />
        )}
        {actions.includes("approve") && (
          <button
            className="ops-secondary"
            disabled={busy}
            onClick={() =>
              void act(async () => {
                const b = await ac.approve(bill, !!bill.duplicateOfId);
                return `Bill #${b.id} approved.`;
              })
            }
          >
            <Icon name="check" size={18} />
            {bill.duplicateOfId ? "Not a duplicate: approve" : "Approve"}
          </button>
        )}
        {actions.includes("markPaid") && (
          <button
            className="ops-secondary"
            aria-expanded={proving}
            onClick={() => setProving((p) => !p)}
          >
            <Icon name="receipt" size={18} />
            Paid elsewhere…
          </button>
        )}
        {actions.includes("void") && (
          <button
            className="ops-secondary"
            aria-expanded={voiding}
            onClick={() => setVoiding((v) => !v)}
          >
            <Icon name="cross" size={18} />
            Void…
          </button>
        )}
      </div>
      {proving && (
        <div className="ops-acc-proof">
          <p className="ops-note">
            Paid by bank transfer, direct debit or cash? Add the proof (a
            receipt, a bank screenshot); it stays with the bill.
          </p>
          <label className="ops-acc-wide">
            Note (optional)
            <input
              value={proofNote}
              onChange={(e) => setProofNote(e.target.value)}
              maxLength={300}
              placeholder="Bank transfer on 3 Nov"
            />
          </label>
          <UploadDrop
            api={api}
            tenant={tenant}
            purpose="receipt"
            compact
            label="Drop the proof of payment"
            onReady={(id) =>
              act(async () => {
                const b = await ac.markPaid(
                  bill,
                  id,
                  proofNote.trim() || undefined,
                );
                setProving(false);
                return `Bill #${b.id} marked paid elsewhere, with proof #${id}.`;
              })
            }
          />
        </div>
      )}
      {voiding && (
        <form
          className="ops-bo-form"
          onSubmit={(e) => {
            e.preventDefault();
            void act(async () => {
              await ac.void(bill, reason.trim());
              setVoiding(false);
              return `Bill #${bill.id} voided.`;
            });
          }}
        >
          <label className="wide">
            Why void it
            <input
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              required
              maxLength={300}
              placeholder="Entered twice"
            />
          </label>
          <button className="ops-secondary" type="submit" disabled={busy}>
            Void bill #{bill.id}
          </button>
        </form>
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </Reveal>
  );
}

/* ---------- Payables aging ---------- */

function AgingTab({ ac, currencyCode, version }: TabProps) {
  const { data, error } = useLoad(() => ac.bills(), [ac, version]);
  const code = data?.currency ?? currencyCode;
  const studio = useMemo(
    () => source("aging", agingRows(data?.rows ?? [])),
    [data],
  );
  const widget = useMemo(() => agingPivot(code), [code]);
  const aging = data?.summary.aging ?? {};
  const open = (data?.rows ?? []).filter(
    (b) => b.bucket && ["review", "approved", "paying"].includes(b.state),
  );
  const columns = useMemo<ColDef<BillRow>[]>(
    () => [
      {
        field: "vendor",
        headerName: "Vendor",
        minWidth: 160,
        cellClass: "ops-cell-strong",
      },
      {
        headerName: "Age",
        valueGetter: (p) => (p.data ? `${p.data.bucket} days` : ""),
        minWidth: 110,
      },
      countCol<BillRow>("Days since issue", "ageDays", { total: false }),
      dateCol<BillRow>("Due", "dueAt", { dayOnly: true }),
      moneyCol<BillRow>("Amount", "amountMinor", (b) => b.currency),
    ],
    [],
  );
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis compact">
        {["0–30", "31–60", "61–90", "90+"].map((b) => (
          <Kpi
            key={b}
            label={`${b} days`}
            alert={b !== "0–30" && (aging[b] ?? 0) > 0}
          >
            <Cash minor={aging[b] ?? 0} code={code} />
          </Kpi>
        ))}
      </div>
      <p className="ops-note">
        Unpaid bills by days since they were issued, by category and vendor.
      </p>
      <StudioWidget
        label="Accountant: payables aging"
        source={studio}
        widget={widget}
        height={420}
      />
      <RaystoGrid<BillRow>
        label="Unpaid bills by age"
        rows={data ? open : undefined}
        columns={columns}
        loading={!data && !error}
        emptyText="Nothing owed."
        getRowId={(p) => String(p.data.id)}
        csvName="raysto-payables-aging"
      />
    </>
  );
}

/* ---------- Requests ---------- */

const emptyDraft: RequestDraft = {
  kind: "link",
  payerName: "",
  payerEmail: "",
  description: "",
  amount: "",
  dueAt: "",
};

function RequestsTab({
  api,
  tenant,
  ac,
  currencyCode,
  inbox,
  refresh,
  version,
}: TabProps) {
  const { data, error } = useLoad(() => ac.requests(), [ac, version]);
  const [draft, setDraft] = useState<RequestDraft>(emptyDraft);
  const [openId, setOpenId] = useState<number>();
  const [formError, setFormError] = useState("");
  const { busy, note, act } = useAct(refresh);
  const code = data?.currency ?? currencyCode;
  const opened = data?.rows.find((r) => r.id === openId);
  const columns = useMemo<ColDef<RequestRow>[]>(
    () => [
      idCol<RequestRow>("Request", "id", { prefix: "R-" }),
      {
        field: "payerName",
        headerName: "Payer",
        minWidth: 150,
        cellClass: "ops-cell-strong",
      },
      { field: "description", headerName: "For", minWidth: 180 },
      moneyCol<RequestRow>("Amount", "amountMinor", (r) => r.currency),
      statusCol<RequestRow>("State", (r) => (r.overdue ? "overdue" : r.state), {
        label: (v) =>
          v === "overdue"
            ? "Overdue"
            : (requestStateWords[v as RequestRow["state"]] ?? words(v)),
      }),
      dateCol<RequestRow>("Due", "dueAt", { dayOnly: true }),
      {
        headerName: "PayPal id",
        valueGetter: (p) =>
          p.data?.providerCaptureId ??
          p.data?.providerOrderId ??
          p.data?.providerInvoiceId ??
          "",
        minWidth: 170,
        cellClass: "ops-mono",
      },
      countCol<RequestRow>("Reminders", "remindersSent", { total: false }),
    ],
    [],
  );
  function submit(e: FormEvent) {
    e.preventDefault();
    setFormError("");
    const checked = requestData(draft);
    if (!checked.ok) return setFormError(checked.error);
    void act(async () => {
      const r = await ac.createRequest(checked.data);
      setDraft(emptyDraft);
      setOpenId(r.id);
      return r.kind === "link"
        ? `Pay link R-${r.id} ready: show its QR code or send it.`
        : `Invoice R-${r.id} drafted: send it through PayPal.`;
    });
  }
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis compact">
        <Kpi label="Owed to you">
          <Cash minor={data?.summary.outstandingMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Overdue" alert={(data?.summary.overdueMinor ?? 0) > 0}>
          <Cash minor={data?.summary.overdueMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Paid this month">
          <Cash minor={data?.summary.paidThisMonthMinor ?? 0} code={code} />
        </Kpi>
      </div>
      <div className="ops-bo-split">
        <Reveal
          as="section"
          className="ops-panel ops-bo-card"
          visitKey="acc-request-new"
        >
          <span className="ops-eyebrow">New request</span>
          <h2>Ask someone to pay you</h2>
          <p>
            A pay link opens PayPal&apos;s own checkout for the exact amount;
            share it by email or as a QR code. A PayPal invoice is sent by
            PayPal once Invoicing is enabled on the Sandbox app.
          </p>
          <form className="ops-bo-form" onSubmit={submit}>
            <fieldset className="ops-acc-kind">
              <legend>How they pay</legend>
              <label>
                <input
                  type="radio"
                  name="kind"
                  checked={draft.kind === "link"}
                  onChange={() => setDraft({ ...draft, kind: "link" })}
                />
                Pay link
              </label>
              <label>
                <input
                  type="radio"
                  name="kind"
                  checked={draft.kind === "invoice"}
                  onChange={() => setDraft({ ...draft, kind: "invoice" })}
                />
                PayPal invoice
              </label>
            </fieldset>
            <label>
              Who pays
              <input
                value={draft.payerName}
                onChange={(e) =>
                  setDraft({ ...draft, payerName: e.target.value })
                }
                required
                maxLength={120}
                placeholder="Acme Offices"
              />
            </label>
            <label>
              Their email{draft.kind === "link" ? " (optional)" : ""}
              <input
                type="email"
                value={draft.payerEmail}
                onChange={(e) =>
                  setDraft({ ...draft, payerEmail: e.target.value })
                }
                required={draft.kind === "invoice"}
              />
            </label>
            <label className="wide">
              For
              <input
                value={draft.description}
                onChange={(e) =>
                  setDraft({ ...draft, description: e.target.value })
                }
                required
                maxLength={300}
                placeholder="Team lunch for 12 on Friday"
              />
            </label>
            <label>
              Amount ({code})
              <input
                inputMode="decimal"
                value={draft.amount}
                onChange={(e) => setDraft({ ...draft, amount: e.target.value })}
                required
                placeholder="120.00"
              />
            </label>
            <label>
              Due
              <input
                type="date"
                value={draft.dueAt}
                onChange={(e) => setDraft({ ...draft, dueAt: e.target.value })}
              />
            </label>
            <button className="ops-primary" type="submit" disabled={busy}>
              <Icon name={draft.kind === "link" ? "qr" : "invoice"} size={18} />
              {draft.kind === "link"
                ? "Create the pay link"
                : "Draft the invoice"}
            </button>
          </form>
          {formError && (
            <p className="ops-error" role="alert">
              {formError}
            </p>
          )}
          {note && (
            <p className="ops-note" role="status">
              {note}
            </p>
          )}
        </Reveal>
        {opened && (
          <RequestDetail
            key={`${opened.id}-${opened.version}`}
            ac={ac}
            r={opened}
            onChanged={refresh}
          />
        )}
      </div>
      <Proposals
        api={api}
        tenant={tenant}
        inbox={inbox}
        commands={["request.remind", "request.create"]}
        onDone={refresh}
      />
      <RaystoGrid<RequestRow>
        label="Payment requests"
        rows={data?.rows}
        columns={columns}
        loading={!data && !error}
        emptyText="No payment requests yet."
        getRowId={(p) => String(p.data.id)}
        onRowClicked={(e) => e.data && setOpenId(e.data.id)}
        csvName="raysto-payment-requests"
      />
    </>
  );
}

function RequestDetail({
  ac,
  r,
  onChanged,
}: {
  ac: AccountantApi;
  r: RequestRow;
  onChanged: () => void;
}) {
  const { busy, note, act } = useAct(onChanged);
  const [copied, setCopied] = useState(false);
  const payable = r.state === "open" || r.state === "sent";
  return (
    <Reveal
      as="section"
      index={1}
      className="ops-panel ops-bo-card ops-acc-detail ops-bo-stamped"
      visitKey={`acc-request-${r.id}`}
    >
      <div className="ops-acc-detail-head">
        <div>
          <span className="ops-eyebrow">
            R-{r.id} · {r.kind === "link" ? "Pay link" : "PayPal invoice"} ·{" "}
            {requestStateWords[r.state]}
          </span>
          <h2>
            {r.payerName}: {currency(r.amountMinor, r.currency)}
          </h2>
        </div>
        <Stamp paid={r.state === "paid"} label="PAID" />
      </div>
      <p>{r.description}</p>
      {r.payUrl && payable && (
        <figure className="ops-acc-qr">
          <QRCodeSVG
            value={r.payUrl}
            size={176}
            level="M"
            marginSize={2}
            title={`Pay ${currency(r.amountMinor, r.currency)} with PayPal`}
          />
          <figcaption>
            <code>{r.payUrl}</code>
            <button
              className="ops-secondary"
              onClick={() =>
                void navigator.clipboard?.writeText(r.payUrl!).then(
                  () => {
                    setCopied(true);
                    setTimeout(() => setCopied(false), 1400);
                  },
                  () => undefined,
                )
              }
            >
              <Icon name={copied ? "check" : "copy"} size={16} />
              {copied ? "Copied" : "Copy the link"}
            </button>
          </figcaption>
        </figure>
      )}
      <dl className="ops-bo-figures">
        {r.payerEmail && (
          <>
            <dt>Email</dt>
            <dd>{r.payerEmail}</dd>
          </>
        )}
        {r.dueAt && (
          <>
            <dt>Due</dt>
            <dd>
              {day(r.dueAt)}
              {r.overdue ? " (overdue)" : ""}
            </dd>
          </>
        )}
        {r.providerOrderId && (
          <>
            <dt>PayPal order</dt>
            <dd>
              <code>{r.providerOrderId}</code>
            </dd>
          </>
        )}
        {r.checkoutState && (
          <>
            <dt>Checkout</dt>
            <dd>{words(r.checkoutState)}</dd>
          </>
        )}
        {r.providerCaptureId && (
          <>
            <dt>PayPal capture</dt>
            <dd>
              <code>{r.providerCaptureId}</code>
            </dd>
          </>
        )}
        {r.providerInvoiceId && (
          <>
            <dt>PayPal invoice</dt>
            <dd>
              <code>{r.providerInvoiceId}</code>
            </dd>
          </>
        )}
        {r.paidAt && (
          <>
            <dt>Paid</dt>
            <dd>{day(r.paidAt)}</dd>
          </>
        )}
        <dt>Reminders</dt>
        <dd>{r.remindersSent}</dd>
      </dl>
      {r.kind === "invoice" && r.state === "draft" && (
        <p className="ops-note">
          Sending an invoice needs PayPal Invoicing on the Sandbox app. If
          PayPal refuses, it stays a draft: use a pay link instead.
        </p>
      )}
      <div className="ops-acc-actions">
        {(r.state === "draft" || payable) && r.payerEmail && (
          <button
            className="ops-primary"
            disabled={busy}
            onClick={() =>
              void act(async () => {
                const x = await ac.send(r);
                return x.kind === "invoice"
                  ? `PayPal sent invoice ${x.providerInvoiceId ?? ""}.`
                  : `Emailed the pay link to ${r.payerEmail}.`;
              })
            }
          >
            <Icon name="send" size={18} />
            {r.kind === "invoice"
              ? "Send through PayPal"
              : r.state === "sent"
                ? "Email it again"
                : "Email the link"}
          </button>
        )}
        {payable && r.payerEmail && r.state === "sent" && (
          <button
            className="ops-secondary"
            disabled={busy}
            onClick={() =>
              void act(async () => {
                await ac.remind(r);
                return "Reminder sent.";
              })
            }
          >
            <Icon name="bell" size={18} />
            Remind
          </button>
        )}
        {(r.state === "draft" || payable) && (
          <button
            className="ops-secondary"
            disabled={busy}
            onClick={() =>
              void act(async () => {
                const x = await ac.cancel(r);
                return (x as unknown as Json).paypalInvoiceStillOpen
                  ? "Cancelled here. The invoice already sent stays open at PayPal; cancel it there too."
                  : "Cancelled.";
              })
            }
          >
            <Icon name="cross" size={18} />
            Cancel
          </button>
        )}
      </div>
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </Reveal>
  );
}

/* ---------- VAT ---------- */

type VatRow = VatPage["rows"][number];

function VatTab({ ac, currencyCode, version }: TabProps) {
  const { data, error } = useLoad(() => ac.vat(), [ac, version]);
  const code = data?.currency ?? currencyCode;
  const columns = useMemo<ColDef<VatRow>[]>(
    () => [
      {
        field: "month",
        headerName: "Month",
        minWidth: 110,
        cellClass: "ops-cell-strong",
      },
      moneyCol<VatRow>("Collected on sales", "collectedMinor", code),
      moneyCol<VatRow>("Paid on bills and receipts", "paidMinor", code),
      moneyCol<VatRow>("Due (or to reclaim)", "dueMinor", code),
    ],
    [code],
  );
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis compact">
        <Kpi label="Collected on sales">
          <Cash minor={data?.collectedMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label="Paid on bills and receipts">
          <Cash minor={data?.paidMinor ?? 0} code={code} />
        </Kpi>
        <Kpi label={(data?.dueMinor ?? 0) < 0 ? "To reclaim" : "Due"}>
          <Cash minor={Math.abs(data?.dueMinor ?? 0)} code={code} />
        </Kpi>
      </div>
      {data && !data.taxConfigured && (
        <p className="ops-error" role="alert">
          The café&apos;s tax rate is not set, so VAT collected on sales reads
          as zero. Set it in Settings.
        </p>
      )}
      {data?.taxConfigured && (
        <p className="ops-note">
          Tax rate {(data.taxBps / 100).toFixed(2)}%. The last three months; a
          summary for your accountant, not a filed return.
        </p>
      )}
      <RaystoGrid<VatRow>
        label="VAT by month"
        rows={data?.rows}
        columns={columns}
        loading={!data && !error}
        emptyText="No VAT in this period."
        getRowId={(p) => p.data.month}
        csvName="raysto-vat"
      />
    </>
  );
}
