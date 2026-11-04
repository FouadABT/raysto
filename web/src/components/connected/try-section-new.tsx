"use client";
/**
 * Try cards 10–14, the 0.16 back office on the judges' café: a bill read and
 * paid with PayPal Payouts, the accountant's month, a pay link, dispatch with
 * the partner API, and the supply planner. Same patterns as cards 1–9 (Card,
 * Approve, OutcomeLine, Chips, MoneyOutcome, live timers): a command the
 * deployment does not offer yet reads as that, and nothing claims a PayPal
 * result PayPal did not return. Rows the reset seeds end in "· Sample".
 * Owner: stream S5.
 */
import { useState, type FormEvent } from "react";
import { QRCodeSVG } from "qrcode.react";
import type { ConnectedApi } from "@/lib/connected/api";
import type { Json } from "@/lib/connected/contracts";
import { agentCost, type AgentActionRow } from "@/lib/connected/business";
import { connectedAuth } from "@/lib/connected/firebase";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import { toolChips } from "@/lib/connected/try-chips";
import {
  anomalyView,
  basisLabel,
  billNext,
  billNextLine,
  billView,
  coverRows,
  depositRequest,
  executedText,
  matchLines,
  matchTotals,
  monthOf,
  partnerLabel,
  partnerLines,
  pickBillFile,
  pickJob,
  pnlView,
  proposedOrder,
  rankingView,
  requestView,
  sampleBillMediaId,
  vatView,
  type Anomaly,
  type BillView,
  type CoverRow,
  type MatchLine,
  type PartnerLine,
  type PnlView,
  type RankRow,
  type RequestView,
  type VatView,
} from "@/lib/connected/try-new";
import { Icon } from "./icons";
import { Stamp } from "./m3";
import {
  Approve,
  Card,
  Chips,
  OutcomeLine,
  Progress,
  agentTask,
  cafeZone,
  counted,
  decided,
  message,
  money,
  pendingOf,
  poll,
  unavailable,
  useDemo,
  type Decided,
} from "./try-section";

const day = (iso?: string) =>
  iso ? new Date(iso).toLocaleDateString("en-US", { day: "numeric", month: "short", timeZone: cafeZone }) : undefined;
const words = (s: string) => s.replace(/([a-z])([A-Z])/g, "$1 $2").replace(/^./, (c) => c.toUpperCase());

/**
 * A money command behind the identity check, inside a card: the manager
 * confirms again (the judges' published password is ready), the server
 * records the step-up, then [run] sends the command.
 */
function IdentityCheck({
  api,
  tenant,
  label,
  run,
}: {
  api: ConnectedApi;
  tenant: number;
  label: string;
  run: () => Promise<void>;
}) {
  const known = isJudgeVenue(tenant) ? judge.password : "";
  const [asking, setAsking] = useState(false);
  const [byPassword, setByPassword] = useState(true);
  const [password, setPassword] = useState(known);
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  async function start() {
    setNote("");
    setByPassword(await usesPassword().catch(() => true));
    setAsking(true);
  }
  async function confirm(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setNote("");
    try {
      await stepUp(api, tenant, byPassword ? password : undefined);
      setAsking(false);
      setPassword(known);
      await run();
    } catch (err) {
      setNote(message(err));
    } finally {
      setBusy(false);
    }
  }
  return (
    <div className="ops-bo-stepup">
      {asking ? (
        <form onSubmit={(e) => void confirm(e)} className="ops-bo-form">
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
            {busy ? "Working…" : byPassword ? `Confirm and ${label.toLowerCase()}` : `Confirm with Google and ${label.toLowerCase()}`}
          </button>
        </form>
      ) : (
        <button className="ops-primary" disabled={busy} onClick={() => void start()}>
          <Icon name="paypal" size={18} />
          {label} (identity check)
        </button>
      )}
      {note && (
        <p className="ops-error" role="alert">
          {note}
        </p>
      )}
    </div>
  );
}

/* 10. A bill PDF becomes a payable; PayPal Payouts pays the vendor. */
function BillCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [bill, setBill] = useState<BillView>();
  const [task, setTask] = useState<Json>();
  const [action, setAction] = useState<AgentActionRow>();
  const [repeat, setRepeat] = useState(false);
  const [outcome, setOutcome] = useState<Decided>();
  const [ids, setIds] = useState<string[]>([]);
  const readBack = async (id: number) => {
    const view = billView(await api.query<Json>("bill", { restaurantId: tenant, id }));
    if (!view) throw new Error("The bill could not be read back.");
    setBill(view);
    return view;
  };
  /** After a payment: the bill again, until PayPal's batch id is recorded. */
  const settle = async (id: number) => {
    const until = Date.now() + 20000;
    let view = await readBack(id);
    while (!view.providerBatchId && Date.now() < until && ["paying", "approved"].includes(view.state)) {
      await new Promise((r) => setTimeout(r, 2000));
      view = await readBack(id);
    }
    setIds(view.providerBatchId ? [`PayPal payout batch ${view.providerBatchId}`] : []);
  };
  const start = () =>
    demo.run(async (signal, say) => {
      setBill(undefined);
      setTask(undefined);
      setAction(undefined);
      setRepeat(false);
      setOutcome(undefined);
      setIds([]);
      say("Finding the sample bill");
      const media = await api.query<{ rows?: Json[] }>("media", { restaurantId: tenant, limit: 100 });
      const file = pickBillFile(media.rows ?? [], sampleBillMediaId);
      if (!file) throw new Error("The sample bill is not uploaded on this deployment yet.");
      say("The accountant is reading the bill with Gemini");
      let asked: Json;
      try {
        asked = await api.command<Json>("bill.snap", tenant, { mediaId: Number(file.id) });
      } catch (e) {
        throw unavailable(e, "Reading bills");
      }
      let id = Number(asked.duplicateOfId ?? 0);
      let done: Json | undefined;
      if (id) {
        // The same file was read before: caught before any AI was spent.
        setRepeat(true);
      } else {
        if (!asked.taskId) throw new Error("The accountant did not start.");
        done = await agentTask(api, tenant, Number(asked.taskId), signal, 120000);
        say("Reading what the accountant filed");
        const list = await api.query<{ rows?: Json[] }>("bills", { restaurantId: tenant });
        const filed = (list.rows ?? [])
          .filter((b) => Number(b.sourceMediaId) === Number(file.id) && (!b.taskId || Number(b.taskId) === Number(asked.taskId)))
          .sort((a, b) => Number(b.id) - Number(a.id))[0];
        id = Number(filed?.id ?? pendingOf(done)?.preview?.billId ?? 0);
        if (!id) throw new Error(String(done.summary ?? "The accountant could not read a bill from this file."));
      }
      await readBack(id);
      setTask(done);
      const proposal = done ? pendingOf(done) : undefined;
      setAction(proposal && (!proposal.preview?.billId || Number(proposal.preview.billId) === id) ? proposal : undefined);
    });
  const next = bill ? billNext(bill) : undefined;
  return (
    <Card
      n={10}
      icon="invoice"
      title="Pay a bill with PayPal"
      time="about 20 s, then PayPal"
      lead="The accountant reads this electricity bill with Gemini: vendor, amount, VAT, due date. It files it as a payable in place of the one it expected this month, with the vendor's PayPal account, and checks it is not a bill paid before. After your identity check, PayPal Payouts pays the vendor (Sandbox)."
    >
      <figure className="ops-try-sample">
        <img src="/judges/bill.png" alt="Sample electricity bill from Hudson Power & Light · Sample: 1,240 kWh for October, $190.86 due 24 November" />
        <figcaption>The bill the accountant reads: a sample PDF, not a real utility</figcaption>
      </figure>
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        {demo.phase === "idle" ? "Read this bill" : "Read it again"}
      </button>
      <Progress demo={demo} />
      {bill && (
        <div className="ops-try-result">
          <div className="ops-try-ticket">
            <span className="ops-eyebrow">
              {bill.vendor} · {words(bill.category)} · {words(bill.state)}
            </span>
            <ul>
              {bill.reference && <li>Reference {bill.reference}</li>}
              <li>
                {money(bill.amountMinor, bill.currency)}
                {bill.vatMinor > 0 ? `, of which VAT ${money(bill.vatMinor, bill.currency)}` : ""}
              </li>
              {bill.dueAt && <li>Due {day(bill.dueAt)}</li>}
              {bill.confidence !== undefined && <li>Read with {Math.round(bill.confidence * 100)}% confidence</li>}
            </ul>
            <strong>{counted(bill.amountMinor, bill.currency)}</strong>
            <p>{billNextLine(bill)}</p>
          </div>
          <Chips
            items={[
              repeat && "Same file as before: caught without spending AI",
              ...toolChips(task?.trace),
              task && `read in ${demo.took}`,
              task && `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
              ...ids,
            ]}
          />
          {outcome ? (
            <OutcomeLine outcome={outcome} />
          ) : action ? (
            <Approve
              api={api}
              tenant={tenant}
              action={action}
              done={(state, result) => {
                setOutcome(decided(state, executedText(action.command), result));
                if (state === "executed" && bill.id) void settle(bill.id).catch(() => {});
              }}
            />
          ) : next === "pay" ? (
            <IdentityCheck
              api={api}
              tenant={tenant}
              label="Pay with PayPal"
              run={async () => {
                let paid: Json;
                try {
                  paid = await api.command<Json>("bill.pay", tenant, { approve: true }, { id: bill.id });
                } catch (e) {
                  throw unavailable(e, "Paying bills");
                }
                setOutcome(decided("executed", executedText("bill.pay")));
                if (typeof paid.providerBatchId === "string") setIds([`PayPal payout batch ${paid.providerBatchId}`]);
                await settle(bill.id!).catch(() => {});
              }}
            />
          ) : next === "paid" || next === "paying" || next === "paidElsewhere" ? (
            <OutcomeLine
              outcome={{
                tone: "done",
                text: `${billNextLine(bill)}${repeat ? " The café starts fresh every hour; read it again after that for a new run." : ""}`,
              }}
            />
          ) : next === "duplicate" ? (
            <OutcomeLine outcome={{ tone: "refused", text: billNextLine(bill) }} />
          ) : null}
        </div>
      )}
    </Card>
  );
}

/* 11. One journal for the month: P&L, VAT and what looks wrong, with PayPal's ids. */
function MonthCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [books, setBooks] = useState<{ month: string; pnl: PnlView; vat?: VatView }>();
  const [flags, setFlags] = useState<Anomaly[]>([]);
  const [task, setTask] = useState<Json>();
  const [aiNote, setAiNote] = useState("");
  const start = () =>
    demo.run(async (signal, say) => {
      setBooks(undefined);
      setFlags([]);
      setTask(undefined);
      setAiNote("");
      const month = monthOf(new Date(), cafeZone);
      say("Building this month's journal from PayPal, the till and the bills");
      let pnl: Json;
      try {
        pnl = await api.query<Json>("ledger.pnl", { restaurantId: tenant, month });
      } catch (e) {
        throw unavailable(e, "The profit and loss");
      }
      const vat = await api.query<Json>("ledger.vat", { restaurantId: tenant, month }).catch(() => undefined);
      setBooks({ month, pnl: pnlView(pnl), vat: vatView(vat) });
      say("The accountant is checking the month");
      const found = await api
        .query<{ rows?: Json[] }>("accountant.anomalies", { restaurantId: tenant })
        .then((r) => r.rows ?? [])
        .catch(() => [] as Json[]);
      setFlags(anomalyView(found));
      try {
        const asked = await api.command<{ taskId?: number }>("accountant.run", tenant, {});
        if (asked.taskId) setTask(await agentTask(api, tenant, asked.taskId, signal, 120000));
        else setAiNote("The accountant agent is switched off here; the figures are the journal's own.");
      } catch (e) {
        if (signal.aborted) throw e;
        setAiNote(`${unavailable(e, "The accountant agent").message} The figures are the journal's own.`);
      }
    });
  const pnl = books?.pnl;
  const label = books
    ? new Date(`${books.month}-15T12:00:00Z`).toLocaleDateString("en-US", { month: "long", year: "numeric" })
    : "";
  return (
    <Card
      n={11}
      icon="ledger"
      title="The accountant's month"
      time="about 15 s"
      lead="Every PayPal capture, refund, fee and payout, every bill and pay link, in one double-entry journal. The accountant reads this month's profit and loss and VAT, and explains what looks wrong, each point with its PayPal id. It only reads: nothing to approve."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        {demo.phase === "idle" ? "Read this month" : "Read it again"}
      </button>
      <Progress demo={demo} />
      {pnl && (
        <div className="ops-try-result">
          <div className="ops-try-ticket">
            <span className="ops-eyebrow">{label} · profit and loss</span>
            <strong>{counted(pnl.netMinor, pnl.currency)}</strong>
            <p>
              Sales and other income {money(pnl.revenueMinor, pnl.currency)}, costs {money(pnl.costsMinor, pnl.currency)}
              {pnl.marginPct !== undefined ? `: a ${pnl.marginPct}% margin.` : "."}
            </p>
          </div>
          {pnl.lines.length > 0 ? (
            <table className="ops-try-table">
              <thead>
                <tr>
                  <th scope="col">Account</th>
                  <th scope="col">Side</th>
                  <th scope="col">Amount</th>
                </tr>
              </thead>
              <tbody>
                {pnl.lines.slice(0, 10).map((l) => (
                  <tr key={`${l.group}-${l.account}`}>
                    <td>
                      {l.account} {l.name}
                    </td>
                    <td>{l.group === "Revenue" ? "In" : "Out"}</td>
                    <td>{money(l.amountMinor, pnl.currency)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p className="ops-try-answer">Nothing was booked this month yet.</p>
          )}
          {books.vat && (
            <p className="ops-try-answer">
              {books.vat.configured
                ? `VAT collected ${money(books.vat.collectedMinor, pnl.currency)}, paid on bills ${money(books.vat.paidMinor, pnl.currency)}, due ${money(books.vat.dueMinor, pnl.currency)}.`
                : "VAT is not set up for this café, so none is collected."}
            </p>
          )}
          {flags.length > 0 ? (
            <ol className="ops-try-gaps">
              {flags.slice(0, 5).map((f, i) => (
                <li key={i}>
                  <strong>{f.title}</strong>
                  {f.detail ? ` ${f.detail}` : ""}
                  {f.ids.length > 0 && (
                    <>
                      {" "}
                      <code>{f.ids.join(" · ")}</code>
                    </>
                  )}
                </li>
              ))}
            </ol>
          ) : (
            demo.phase === "done" && <p className="ops-try-answer">The accountant&rsquo;s rules found nothing out of place.</p>
          )}
          {task?.summary ? <p className="ops-try-answer">{String(task.summary)}</p> : null}
          {aiNote && <p className="ops-note">{aiNote}</p>}
          <Chips
            items={[
              ...toolChips(task?.trace),
              pnl.feesEstimated && "PayPal fees estimated where PayPal did not report them",
              demo.phase === "done" && `read in ${demo.took}`,
              task && `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
          />
          <p className="ops-try-lead">The Group section compares both sample cafés from this same journal.</p>
        </div>
      )}
    </Card>
  );
}

/* 12. A pay link with a QR code, paid in PayPal Sandbox. */
function PayLinkCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [request, setRequest] = useState<RequestView>();
  const start = () =>
    demo.run(async (signal, say) => {
      setRequest(undefined);
      say("Making the pay link");
      let created: Json;
      try {
        created = await api.command<Json>("request.create", tenant, depositRequest);
      } catch (e) {
        throw unavailable(e, "Making pay links");
      }
      const view = requestView(created);
      if (!view?.id) throw new Error("The pay link could not be read back.");
      if (!view.payUrl)
        throw new Error("The request was made, but this deployment has no pay-link secret yet, so its link cannot open.");
      setRequest(view);
      say("Waiting for the payment in PayPal Sandbox");
      const final = await poll(
        () => api.query<Json>("request", { restaurantId: tenant, id: view.id }),
        (r) => ["paid", "cancelled"].includes(String(r.state)),
        signal,
        3000,
        15 * 60000,
      );
      const after = requestView(final);
      setRequest(after);
      if (!after?.paid) throw new Error("The request was cancelled before it was paid.");
    });
  return (
    <Card
      n={12}
      icon="payments"
      title="Ask a customer to pay"
      time="about 5 s, then PayPal"
      lead="A deposit for a catering order becomes a PayPal pay link with a QR code. Open it, pay with the Sandbox buyer, and PayPal's capture marks it paid here and in the journal. No invoice feature needed: it is a PayPal checkout."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="paypal" size={18} />
        Make a $35.55 pay link
      </button>
      <Progress demo={demo} />
      {request && (
        <div className="ops-try-result">
          <div className="ops-try-ticket">
            <span className="ops-eyebrow">
              {request.payerName} · {words(request.state)}
            </span>
            <p className="ops-try-answer">{request.description}</p>
            <strong>{counted(request.amountMinor, request.currency)}</strong>
          </div>
          {request.payUrl && !request.paid && (
            <div className="ops-try-paypal">
              <figure className="ops-try-photo small">
                <QRCodeSVG value={request.payUrl} size={168} marginSize={2} title="QR code for this pay link" />
                <figcaption>Scan with a phone, or open the link</figcaption>
              </figure>
              <a className="ops-primary" href={request.payUrl} target="_blank" rel="noopener noreferrer">
                <Icon name="paypal" size={18} />
                Open the pay link
              </a>
              {judge.buyerEmail ? (
                <dl>
                  <dt>Sandbox buyer</dt>
                  <dd>
                    <code>{judge.buyerEmail}</code>
                  </dd>
                  <dt>Password</dt>
                  <dd>
                    <code>{judge.buyerPassword}</code>
                  </dd>
                </dl>
              ) : (
                <small>Sign in on PayPal&rsquo;s page with the Sandbox buyer login from the testing instructions.</small>
              )}
              <small>Sandbox money only. Pay, then come back: this card updates by itself.</small>
            </div>
          )}
          <div className="ops-try-paidline">
            {request.paid && (
              <p className="ops-try-done" role="status">
                <Icon name="check" size={18} />
                <span>
                  Paid in PayPal Sandbox{request.captureId ? `, capture ${request.captureId}` : ""}, after {demo.took}.
                </span>
              </p>
            )}
            <Stamp paid={request.paid} />
          </div>
        </div>
      )}
    </Card>
  );
}

/**
 * The partner simulator (stream S2's console route): "Demo Delivery Co.", a
 * pretend outside delivery app, sends one signed order. Its key stays on
 * the server; a signed-in manager of the judges' café may use it.
 */
async function simulatorOrder(tenant: number): Promise<{ ref?: string; note?: string }> {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  try {
    const user = (await connectedAuth()).currentUser;
    if (user) headers["X-Raysto-Firebase-Token"] = await user.getIdToken();
  } catch {
    // Signed out or not configured: the route answers why.
  }
  let response: Response;
  try {
    response = await fetch("/api/partner-sim/orders", {
      method: "POST",
      headers,
      body: JSON.stringify({ restaurantId: tenant }),
      cache: "no-store",
      signal: AbortSignal.timeout(30000),
    });
  } catch {
    return { note: "The delivery simulator did not answer." };
  }
  if (response.status === 404) return { note: "The delivery simulator is not on this deployment yet." };
  const payload = (await response.json().catch(() => ({}))) as Json;
  if (!response.ok)
    return { note: String((payload.error as Json | undefined)?.message ?? `The delivery simulator answered HTTP ${response.status}.`) };
  const data = ((payload.data as Json | undefined) ?? payload) as Json;
  const ref = data.ref ?? data.partnerRef ?? data.externalRef;
  return { ref: typeof ref === "string" ? ref : undefined };
}

/* 13. A partner's order, ranked by the AI dispatcher, offered to a driver, with signed webhooks. */
function DispatchCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [job, setJob] = useState<Json>();
  const [simNote, setSimNote] = useState("");
  const [ranking, setRanking] = useState<RankRow[]>([]);
  const [basis, setBasis] = useState("");
  const [task, setTask] = useState<Json>();
  const [action, setAction] = useState<AgentActionRow>();
  const [aiOff, setAiOff] = useState(false);
  const [outcome, setOutcome] = useState<Decided>();
  const [log, setLog] = useState<PartnerLine[]>([]);
  const readLog = async (ref?: string) => {
    const events = await api.query<{ rows?: Json[] }>("partner.events", { restaurantId: tenant, limit: 30 }).catch(() => undefined);
    setLog(partnerLines(events?.rows ?? [], ref));
  };
  const start = () =>
    demo.run(async (signal, say) => {
      setJob(undefined);
      setSimNote("");
      setRanking([]);
      setBasis("");
      setTask(undefined);
      setAction(undefined);
      setAiOff(false);
      setOutcome(undefined);
      setLog([]);
      say("Opening the dispatch board");
      const board = () => api.query<{ rows?: Json[] }>("delivery.board", { restaurantId: tenant });
      try {
        await board();
      } catch (e) {
        throw unavailable(e, "Dispatch");
      }
      say("Demo Delivery Co. (simulator) sends a signed order");
      const sent = await simulatorOrder(tenant);
      if (sent.note) setSimNote(sent.note);
      let found: Json | undefined;
      if (sent.ref) {
        say("The partner's order reaches the board");
        found = await poll(
          async () => pickJob((await board()).rows ?? [], sent.ref),
          (j) => !!j && j.partnerRef === sent.ref,
          signal,
          2000,
          30000,
        ).catch(() => undefined);
      }
      found ??= pickJob((await board()).rows ?? []);
      if (!found)
        throw new Error(`${sent.note ? `${sent.note} ` : ""}No delivery is waiting for a driver right now.`);
      setJob(found);
      say("The AI dispatcher is ranking the drivers");
      let suggested: Json;
      try {
        suggested = await api.command<Json>("dispatch.suggest", tenant, { assignmentId: Number(found.id) });
      } catch (e) {
        throw unavailable(e, "The AI dispatcher");
      }
      setRanking(rankingView(suggested.ranking));
      setBasis(typeof suggested.basis === "string" ? suggested.basis : "");
      if (suggested.taskId) {
        const done = await agentTask(api, tenant, Number(suggested.taskId), signal, 90000);
        setTask(done);
        setAction(pendingOf(done));
      } else {
        setAiOff(true);
      }
      await readLog(typeof found.partnerRef === "string" ? found.partnerRef : undefined);
    });
  const after = async () => {
    const ref = typeof job?.partnerRef === "string" ? job.partnerRef : undefined;
    // The partner hears each step as a signed webhook; show the log as it grows.
    for (let i = 0; i < 5; i++) {
      await readLog(ref);
      await new Promise((r) => setTimeout(r, 3000));
    }
  };
  const best = ranking[0];
  const partner = job?.partner as Json | undefined;
  return (
    <Card
      n={13}
      icon="dispatch"
      title="Dispatch a delivery"
      time="about 20 s"
      lead="An outside delivery app sends an order through Raysto's Delivery Partner API: here Demo Delivery Co., a labelled simulator, not Uber Eats or Glovo. The AI dispatcher ranks the café's drivers by distance and jobs on hand and proposes one. You approve the offer; the partner gets a signed webhook for each step."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Send a partner order
      </button>
      <Progress demo={demo} />
      {job && (
        <div className="ops-try-result">
          <div className="ops-try-ticket">
            <span className="ops-eyebrow">
              Order {job.number ? `#${String(job.number)}` : `${String(job.orderId ?? "")}`} ·{" "}
              {partner
                ? `${String(partner.name)}${partner.simulator && !/simulator/i.test(String(partner.name)) ? " (simulator)" : ""}`
                : "the café's own order"}
            </span>
            {(job.address as Json | undefined)?.line ? <p>{String((job.address as Json).line)}</p> : null}
            {job.totalMinor !== undefined && <strong>{money(job.totalMinor, String(job.currency ?? "USD"))}</strong>}
          </div>
          {simNote && <p className="ops-note">{simNote} This card uses the newest delivery waiting for a driver instead.</p>}
          {ranking.length > 0 && (
            <ol className="ops-try-gaps">
              {ranking.slice(0, 3).map((r) => (
                <li key={r.driverId}>
                  <strong>
                    {r.name} · {r.vehicle}
                  </strong>
                  {r.minutes !== undefined ? ` · about ${r.minutes} min` : ""}
                  {r.score !== undefined ? ` · score ${r.score}` : ""}
                  {r.reasons.length > 0 ? `. ${r.reasons.join("; ")}.` : ""}
                </li>
              ))}
            </ol>
          )}
          {basis && <p className="ops-note">{basis}</p>}
          <Chips
            items={[
              ...toolChips(task?.trace),
              task && `ranked in ${demo.took}`,
              task && `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
          />
          {outcome ? (
            <OutcomeLine outcome={outcome} />
          ) : action ? (
            <Approve
              api={api}
              tenant={tenant}
              action={action}
              done={(state, result) => {
                setOutcome(decided(state, executedText(action.command), result));
                if (state === "executed") void after().catch(() => {});
              }}
            />
          ) : aiOff && best ? (
            <>
              <p className="ops-note">The AI dispatcher is off on this deployment: this is Raysto&rsquo;s own ranking.</p>
              <button
                className="ops-primary"
                onClick={() =>
                  void api
                    .command("delivery.offer", tenant, { driverId: best.driverId }, { id: Number(job.id) })
                    .then(() => {
                      setOutcome(decided("executed", executedText("delivery.offer")));
                      void after().catch(() => {});
                    })
                    .catch((e) => setOutcome({ tone: "failed", text: unavailable(e, "Offering a delivery").message }))
                }
              >
                <Icon name="dispatch" size={18} />
                Offer it to {best.name}
              </button>
            </>
          ) : null}
          {log.length > 0 && (
            <>
              <h3 className="ops-eyebrow">Partner API log</h3>
              <ul className="ops-try-chips">
                {log.map((l) => (
                  <li key={l.id}>{partnerLabel(l)}</li>
                ))}
              </ul>
            </>
          )}
        </div>
      )}
    </Card>
  );
}

/* 14. A stock-out forecast becomes a purchase order; last week's delivery is matched three ways. */
function SupplyCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [cover, setCover] = useState<CoverRow[]>([]);
  const [basis, setBasis] = useState<unknown>();
  const [task, setTask] = useState<Json>();
  const [action, setAction] = useState<AgentActionRow>();
  const [outcome, setOutcome] = useState<Decided>();
  const [match, setMatch] = useState<{ supplier: string; lines: MatchLine[]; billMinor?: number; currency: string }>();
  const start = () =>
    demo.run(async (signal, say) => {
      setCover([]);
      setTask(undefined);
      setAction(undefined);
      setOutcome(undefined);
      setMatch(undefined);
      say("Reading stock and 28 days of usage");
      let forecast: Json;
      try {
        forecast = await api.query<Json>("stock.forecast", { restaurantId: tenant });
      } catch (e) {
        throw unavailable(e, "The stock forecast");
      }
      setCover(coverRows(forecast.rows));
      setBasis(forecast.basis);
      say("The supply planner is drafting the order");
      let asked: { taskId?: number };
      try {
        asked = await api.command<{ taskId?: number }>("supplies.plan", tenant, {});
      } catch (e) {
        throw unavailable(e, "The supply planner");
      }
      if (!asked.taskId) throw new Error("The supply planner did not start.");
      const done = await agentTask(api, tenant, asked.taskId, signal, 120000);
      setTask(done);
      setAction(pendingOf(done));
      say("Checking last week's delivery against its order and bill");
      const orders = await api
        .query<{ rows?: Json[] }>("supplier.orders", { restaurantId: tenant, limit: 50 })
        .then((r) => r.rows ?? [])
        .catch(() => [] as Json[]);
      const delivered = new Set(["partiallyReceived", "received", "billed", "paid"]);
      const received =
        orders.find((o) => delivered.has(String(o.state)) && String(o.note ?? "").includes("Sample")) ??
        orders.find((o) => delivered.has(String(o.state)));
      if (received) {
        const bills = await api
          .query<{ rows?: Json[] }>("bills", { restaurantId: tenant })
          .then((r) => r.rows ?? [])
          .catch(() => [] as Json[]);
        const bill = bills.find((b) => Number(b.supplierOrderId) === Number(received.id) && b.state !== "void");
        setMatch({
          supplier: String(received.supplierName ?? "The supplier"),
          lines: matchLines(received),
          billMinor: bill ? Number(bill.amountMinor) : undefined,
          currency: String(received.currency ?? "USD"),
        });
      }
    });
  const order = proposedOrder(action?.preview);
  const totals = match ? matchTotals(match.lines, match.billMinor) : undefined;
  const reorders = cover.filter((c) => c.reorder).length;
  return (
    <Card
      n={14}
      icon="supplies"
      title="Never run out"
      time="about 20 s"
      lead="From 28 days of sales and the recipes, Raysto works out each item's days of cover and what runs out before the next delivery. The supply planner drafts the purchase order up to par, picks the supplier and flags prices that moved more than 5%. You approve it. Last week's delivery is checked three ways: the order, the delivery note and the supplier's bill."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Plan this week's order
      </button>
      <Progress demo={demo} />
      {cover.length > 0 && (
        <div className="ops-try-result">
          <table className="ops-try-table">
            <thead>
              <tr>
                <th scope="col">Item</th>
                <th scope="col">On hand</th>
                <th scope="col">Cover</th>
              </tr>
            </thead>
            <tbody>
              {cover.slice(0, 5).map((c) => (
                <tr key={c.stockItemId} className={c.reorder ? "price" : ""}>
                  <td>
                    {c.name}
                    {c.reorder && <em className="warn">reorder {c.suggestedQty} {c.unit}</em>}
                  </td>
                  <td>
                    {c.quantity} {c.unit}
                  </td>
                  <td>
                    {c.daysCover === undefined ? (c.low ? "below its low mark" : "no recent use") : `${c.daysCover} days`}
                    {c.stockOutAt && c.daysCover !== undefined && (
                      <span style={{ display: "block", fontSize: 12, fontWeight: 400, color: "var(--muted)" }}>
                        runs out {day(c.stockOutAt)}
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {action && order.lines.length > 0 && (
            <div className="ops-try-ticket">
              <span className="ops-eyebrow">Proposed order · {order.supplier}</span>
              <ul>
                {order.lines.map((l, i) => (
                  <li key={i}>
                    {l.qty} {l.unit} {l.name} · {money(l.qty * l.unitCostMinor, order.currency)}
                  </li>
                ))}
              </ul>
              <strong>{counted(order.totalMinor, order.currency)}</strong>
            </div>
          )}
          <Chips
            items={[
              basisLabel(basis),
              `${reorders} to reorder`,
              ...toolChips(task?.trace),
              task && `planned in ${demo.took}`,
              task && `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
          />
          {outcome ? (
            <OutcomeLine outcome={outcome} />
          ) : action ? (
            <Approve
              api={api}
              tenant={tenant}
              action={action}
              done={(state, result) => setOutcome(decided(state, executedText(action.command), result))}
            />
          ) : task ? (
            <p className="ops-try-answer">{String(task.summary ?? "Nothing needs ordering now.")}</p>
          ) : null}
          {match && totals && match.lines.length > 0 && (
            <>
              <h3 className="ops-eyebrow">3-way match · {match.supplier}</h3>
              <table className="ops-try-table">
                <thead>
                  <tr>
                    <th scope="col">Item</th>
                    <th scope="col">Ordered, delivered</th>
                    <th scope="col">Unit price</th>
                  </tr>
                </thead>
                <tbody>
                  {match.lines.map((l) => (
                    <tr key={l.name} className={l.flag ? "price" : ""}>
                      <td>
                        {l.name}
                        {l.flag && <em className="warn">{l.qtyDiff !== 0 ? "quantity differs" : `price ${l.pricePct > 0 ? "+" : ""}${l.pricePct}%`}</em>}
                      </td>
                      <td>
                        {l.orderedQty}, {l.receivedQty} {l.unit}
                      </td>
                      <td>
                        {money(l.billedUnitMinor, match.currency)}
                        {l.billedUnitMinor !== l.orderedUnitMinor && <s>{money(l.orderedUnitMinor, match.currency)}</s>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <p className="ops-try-answer">
                Ordered {money(totals.orderedMinor, match.currency)}; delivered at the billed prices{" "}
                {money(totals.deliveredMinor, match.currency)}
                {totals.billMinor !== undefined
                  ? `; the supplier's bill says ${money(totals.billMinor, match.currency)}, ${money(Math.abs(totals.diffMinor), match.currency)} ${totals.diffMinor >= 0 ? "more" : "less"} than ordered.`
                  : "; the supplier's bill has not arrived yet."}
              </p>
            </>
          )}
        </div>
      )}
    </Card>
  );
}

/** Cards 10–14, rendered at the end of the Try grid. */
export function TryCardsNew({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  return (
    <>
      <header className="ops-try-split" style={{ gridColumn: "1 / -1" }}>
        <span className="ops-eyebrow">NEW IN 0.16 · FIVE MORE DEMOS, THE BACK OFFICE</span>
        <p className="ops-try-lead">
          Bills, the books, pay links, delivery and supplies. Rows marked &ldquo;· Sample&rdquo; are demo data the café
          starts with; every PayPal step is real Sandbox.
        </p>
      </header>
      <BillCard api={api} tenant={tenant} />
      <MonthCard api={api} tenant={tenant} />
      <PayLinkCard api={api} tenant={tenant} />
      <DispatchCard api={api} tenant={tenant} />
      <SupplyCard api={api} tenant={tenant} />
    </>
  );
}
