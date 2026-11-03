"use client";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { ApiFailure, type ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import { agentCost, type AgentActionRow } from "@/lib/connected/business";
import { gapLabel } from "@/lib/connected/backoffice";
import {
  basketOf,
  elapsed,
  heardLines,
  judge,
  menuChanges,
  toolsUsed,
  type Dish,
  type DraftRow,
} from "@/lib/connected/judge";
import { m } from "motion/react";
import { duration, easing, MotionRoot, stagger, useFirstVisit, useReduce } from "@/lib/connected/motion";
import { AgentPanel } from "./business-sections";
import { Icon, type IconName } from "./icons";
import { CountUp, Stamp } from "./m3";

/** The café's clock: pickup times read as the café sees them. */
const cafeZone = "America/New_York";

type Phase = "idle" | "running" | "done" | "failed";

const message = (e: unknown) =>
  e instanceof ApiFailure || e instanceof Error ? e.message : String(e);

function wait(ms: number, signal: AbortSignal) {
  return new Promise<void>((resolve, reject) => {
    const timer = setTimeout(resolve, ms);
    signal.addEventListener(
      "abort",
      () => {
        clearTimeout(timer);
        reject(new DOMException("Stopped", "AbortError"));
      },
      { once: true },
    );
  });
}

/** Reads until [done] holds, every [every] ms, for at most [limit] ms. */
async function poll<T>(
  read: () => Promise<T>,
  done: (value: T) => boolean,
  signal: AbortSignal,
  every = 2000,
  limit = 150000,
): Promise<T> {
  const until = Date.now() + limit;
  for (;;) {
    const value = await read();
    if (done(value)) return value;
    if (Date.now() > until)
      throw new Error("This is taking longer than usual. Try again in a minute.");
    await wait(every, signal);
  }
}

/** One demo's progress: what it is doing now and for how long. */
function useDemo() {
  const [phase, setPhase] = useState<Phase>("idle");
  const [step, setStep] = useState("");
  const [error, setError] = useState("");
  const [started, setStarted] = useState(0);
  const [now, setNow] = useState(0);
  const [took, setTook] = useState("");
  const controller = useRef<AbortController | null>(null);
  useEffect(() => () => controller.current?.abort(), []);
  useEffect(() => {
    if (phase !== "running") return;
    const timer = setInterval(() => setNow(Date.now()), 500);
    return () => clearInterval(timer);
  }, [phase]);
  async function run(
    work: (signal: AbortSignal, say: (step: string) => void) => Promise<void>,
  ) {
    controller.current?.abort();
    const c = new AbortController();
    controller.current = c;
    const begin = Date.now();
    setPhase("running");
    setError("");
    setStep("Starting…");
    setStarted(begin);
    setNow(begin);
    try {
      await work(c.signal, setStep);
      if (c.signal.aborted) return;
      setTook(elapsed(Date.now() - begin));
      setPhase("done");
    } catch (e) {
      if (c.signal.aborted) return;
      setError(message(e));
      setPhase("failed");
    }
  }
  return { phase, step, error, took, seconds: elapsed(now - started), run };
}
type Demo = ReturnType<typeof useDemo>;

function Progress({ demo }: { demo: Demo }) {
  if (demo.phase === "running")
    return (
      <p className="ops-try-progress" role="status">
        <span className="ops-spinner" aria-hidden="true" />
        <span>{demo.step}</span>
        <b>{demo.seconds}</b>
      </p>
    );
  if (demo.phase === "failed")
    return (
      <p className="ops-error" role="alert">
        {demo.error}
      </p>
    );
  return null;
}

function Card({
  n,
  icon,
  title,
  time,
  lead,
  children,
}: {
  n: number;
  icon: IconName;
  title: string;
  time: string;
  lead: string;
  children: ReactNode;
}) {
  // The kit's Reveal, inline so the article keeps its own name and class:
  // a fade with a 6 px rise, staggered, on the first visit of the session only.
  const reduce = useReduce();
  const first = useFirstVisit("try");
  const still = reduce || !first;
  const Tag = still ? "article" : m.article;
  const enter = still
    ? {}
    : {
        initial: { opacity: 0, y: 6 },
        animate: { opacity: 1, y: 0 },
        transition: { duration: duration.medium2, ease: easing.emphasizedDecelerate, delay: stagger(n - 1) },
      };
  return (
    <Tag className="ops-try-card" aria-labelledby={`try-${n}`} {...enter}>
      <header>
        <span className="ops-try-n" aria-hidden="true">
          <Icon name={icon} size={20} />
        </span>
        <div>
          <span className="ops-eyebrow">
            {n} · {time}
          </span>
          <h2 id={`try-${n}`}>{title}</h2>
        </div>
      </header>
      <p className="ops-try-lead">{lead}</p>
      {children}
    </Tag>
  );
}

function Chips({ items }: { items: (string | false | undefined)[] }) {
  const shown = items.filter((v): v is string => !!v);
  if (!shown.length) return null;
  return (
    <ul className="ops-try-chips">
      {shown.map((c) => (
        <li key={c}>{c}</li>
      ))}
    </ul>
  );
}

const menuOf = async (api: ConnectedApi, tenant: number) =>
  (await api.query<{ menu: Dish[] }>("counter.menu", { restaurantId: tenant }))
    .menu;

async function agentTask(
  api: ConnectedApi,
  tenant: number,
  id: number,
  signal: AbortSignal,
  limit = 150000,
) {
  const task = await poll(
    () => api.query<Json>("agent.task", { restaurantId: tenant, id }),
    (t) => t.status === "done" || t.status === "failed",
    signal,
    2000,
    limit,
  );
  if (task.status === "failed")
    throw new Error(String(task.summary ?? "The agent could not finish."));
  return task;
}

const pendingOf = (task: Json) =>
  ((task.actions as AgentActionRow[] | undefined) ?? []).find(
    (a) => a.status === "pending",
  );

/** Approval inside a card; the result line replaces it once decided. */
function Approve({
  api,
  tenant,
  action,
  done,
}: {
  api: ConnectedApi;
  tenant: number;
  action: AgentActionRow;
  done: (state: string, result?: Json) => void;
}) {
  return (
    <AgentPanel
      inline
      api={api}
      tenant={tenant}
      action={action}
      knownPassword={judge.password}
      onDone={done}
    />
  );
}

const decided = (state: string, executed: string, result?: Json) =>
  state === "executed"
    ? executed
    : state === "rejected"
      ? "Turned down. Nothing changed."
      : result?.error === "provider_feature_disabled"
        ? "PayPal refused it: this feature is not enabled on the Sandbox app yet. Nothing was sent or charged."
        : typeof result?.message === "string" && result.message
          ? `It did not go through: ${result.message}`
          : "It did not go through; run it again.";

/** A command that the backend does not offer yet reads as that, never as a result. */
const unavailable = (e: unknown, what: string) => {
  const m = message(e);
  if (/not_found|Unknown operation|404|not allowed|forbidden path/i.test(m))
    return new Error(`${what} is not available on this deployment yet.`);
  if (/provider_feature_disabled|not enabled/i.test(m))
    return new Error(`${what}: this PayPal feature is not enabled on the Sandbox app yet.`);
  return e instanceof Error ? e : new Error(m);
};

/** PayPal's ids from an executed action: what PayPal returned, as recorded. */
function paypalIds(task: Json | undefined): string[] {
  const out: string[] = [];
  for (const a of (task?.actions as AgentActionRow[] | undefined) ?? []) {
    const r = ((a as unknown as Json).result ?? {}) as Json;
    const p = (a.preview ?? {}) as Json;
    const pick: [string, string][] = [
      ["providerBatchId", "PayPal payout batch"],
      ["invoiceNumber", "PayPal invoice"],
      ["providerInvoiceId", "PayPal invoice id"],
      ["providerRefundId", "PayPal refund"],
      ["providerCaptureId", "PayPal capture"],
      ["providerDisputeId", "PayPal dispute"],
    ];
    for (const [k, label] of pick) {
      const v = r[k] ?? p[k];
      if (typeof v === "string" && v) out.push(`${label} ${v}`);
    }
  }
  return [...new Set(out)];
}

/** Reads rows until one satisfies [pick], for the agents woken by an event. */
async function pollRows<T extends Json>(
  read: () => Promise<Json>,
  pick: (rows: T[]) => T | undefined,
  signal: AbortSignal,
  limit = 30000,
): Promise<T> {
  const found = await poll(
    async () => pick(((await read()).rows as T[] | undefined) ?? []),
    (row) => row !== undefined,
    signal,
    2000,
    limit,
  );
  return found as T;
}

/** The common tail of a money card: chips, approval, and PayPal's ids after it. */
function MoneyOutcome({
  api,
  tenant,
  task,
  action,
  executed,
  chips,
  refresh,
}: {
  api: ConnectedApi;
  tenant: number;
  task: Json;
  action?: AgentActionRow;
  executed: string;
  chips: (string | false | undefined)[];
  refresh: () => Promise<Json>;
}) {
  const [outcome, setOutcome] = useState("");
  const [ids, setIds] = useState<string[]>([]);
  return (
    <>
      <Chips items={[...chips, ...ids]} />
      {outcome ? (
        <p className="ops-try-done" role="status">
          <Icon name="check" size={18} />
          {outcome}
        </p>
      ) : action ? (
        <Approve
          api={api}
          tenant={tenant}
          action={action}
          done={(state, result) => {
            setOutcome(decided(state, executed, result));
            if (state === "executed") void refresh().then((t) => setIds(paypalIds(t))).catch(() => {});
          }}
        />
      ) : (
        <p className="ops-try-answer">{String(task.summary ?? "")}</p>
      )}
    </>
  );
}

const money = (minor: unknown, code = "USD") => currency(Number(minor ?? 0), code);

/** A result total that counts up to its real value. */
const counted = (minor: unknown, code = "USD") => (
  <CountUp value={Math.round(Number(minor ?? 0))} format={(n) => currency(n, code)} />
);

/* 1. The close agent matches PayPal's transactions to the till. */
function CloseCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [task, setTask] = useState<Json>();
  const [close, setClose] = useState<Json>();
  const start = () =>
    demo.run(async (signal, say) => {
      setTask(undefined);
      setClose(undefined);
      say("The close agent is reading PayPal's transactions and Raysto's ledger");
      let asked: { taskId?: number };
      try {
        asked = await api.command<{ taskId?: number }>("close.run", tenant, {});
      } catch (e) {
        throw unavailable(e, "The daily close");
      }
      if (!asked.taskId) throw new Error("The close agent did not start.");
      const done = await agentTask(api, tenant, asked.taskId, signal, 120000);
      say("Reading the close");
      const read = await api.query<{ close?: Json }>("backoffice.close", { restaurantId: tenant });
      setClose(read.close ?? undefined);
      setTask(done);
    });
  const summary = (close?.summary ?? {}) as Json;
  const gaps = (close?.gaps as Json[] | undefined) ?? [];
  const code = String(summary.currency ?? "USD");
  return (
    <Card
      n={1}
      icon="chart"
      title="Close the day"
      time="about 20 s"
      lead="At closing time the close agent reads PayPal's own transaction list through the PayPal MCP server, matches it to the till and the kitchen, and explains every gap. You sign off; nothing is posted until you do."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Close today
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          {close && (
            <div className="ops-try-ticket">
              <span className="ops-eyebrow">
                Daily close · {String(close.day ?? "today")} ·{" "}
                {close.source === "paypal_transactions" ? "PayPal's transaction list" : "Raysto's ledger of PayPal webhooks"}
              </span>
              <ul>
                <li>PayPal captured {counted(summary.paypalCapturedMinor, code)}</li>
                <li>Raysto recorded {counted(summary.raystoCapturedMinor, code)}</li>
                <li>Tips {money(summary.tipsMinor, code)} · refunds {money(summary.refundsMinor, code)} · fees {money(summary.feesMinor, code)}</li>
                <li>Cash {money(summary.cashMinor, code)}</li>
              </ul>
              {gaps.length ? (
                <ol className="ops-try-gaps">
                  {gaps.map((g, i) => (
                    <li key={i}>
                      <strong>{gapLabel({ kind: String(g.kind ?? "gap") })}</strong> {money(g.amountMinor, code)}: {String(g.explanation ?? "")}
                    </li>
                  ))}
                </ol>
              ) : (
                <p>No gaps: PayPal and the till agree.</p>
              )}
            </div>
          )}
          <MoneyOutcome
            api={api}
            tenant={tenant}
            task={task}
            action={pendingOf(task)}
            executed="Signed off. The close is posted with PayPal's figures beside the till's."
            chips={[
              ...toolsUsed(task.trace).map((t) => (/paypal|transactions/i.test(t) ? "read PayPal via MCP" : `used ${t}`)),
              `closed in ${demo.took}`,
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
            refresh={() => api.query<Json>("agent.task", { restaurantId: tenant, id: task.id })}
          />
        </div>
      )}
    </Card>
  );
}

/* 2. Tips and wages from the week's shifts; PayPal Payouts sends the batch. */
function PayrollCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [task, setTask] = useState<Json>();
  const [batch, setBatch] = useState<Json>();
  const start = () =>
    demo.run(async (signal, say) => {
      setTask(undefined);
      setBatch(undefined);
      say("The payroll agent is adding up this week's shifts and tips");
      const to = new Date();
      const from = new Date(to.getTime() - 7 * 86400000);
      let asked: { taskId?: number };
      try {
        asked = await api.command<{ taskId?: number }>("payroll.run", tenant, {
          from: from.toISOString(),
          to: to.toISOString(),
        });
      } catch (e) {
        throw unavailable(e, "The pay run");
      }
      if (!asked.taskId) throw new Error("The payroll agent did not start.");
      const done = await agentTask(api, tenant, asked.taskId, signal, 120000);
      const pending = pendingOf(done);
      const batchId = Number(pending?.preview.batchId ?? 0);
      if (batchId) {
        say("Reading the batch");
        const read = await api.query<Json>("payout", { restaurantId: tenant, id: batchId }).catch(() => undefined);
        setBatch(read ?? (pending?.preview as Json | undefined));
      } else {
        setBatch(pending?.preview as Json | undefined);
      }
      setTask(done);
    });
  const items = (batch?.items as Json[] | undefined) ?? [];
  const code = String(batch?.currency ?? "USD");
  return (
    <Card
      n={2}
      icon="team"
      title="Pay the team"
      time="about 15 s, then PayPal"
      lead="The payroll agent turns this week's clocked shifts into wages and splits the tip pool by hours and role, as one batch. After your identity check, PayPal Payouts sends it to each person's PayPal, and the batch id is kept."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Run this week's pay
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          {batch && (
            <div className="ops-try-ticket">
              <span className="ops-eyebrow">
                {String(batch.kind ?? "pay")} · {counted(batch.totalMinor, code)}
              </span>
              {items.length ? (
                <ul>
                  {items.map((it, i) => (
                    <li key={i}>
                      {String(it.recipientName ?? it.name ?? "")} · {money(it.amountMinor, code)}
                      {it.note ? ` · ${String(it.note)}` : ""}
                    </li>
                  ))}
                </ul>
              ) : (
                <p>{String(batch.summary ?? "No one is owed anything this week.")}</p>
              )}
            </div>
          )}
          <MoneyOutcome
            api={api}
            tenant={tenant}
            task={task}
            action={pendingOf(task)}
            executed="Sent with PayPal Payouts. Each person receives it in their PayPal account (Sandbox)."
            chips={[
              ...toolsUsed(task.trace).map((t) => `used ${t}`),
              `prepared in ${demo.took}`,
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
            refresh={() => api.query<Json>("agent.task", { restaurantId: tenant, id: task.id })}
          />
        </div>
      )}
    </Card>
  );
}

/* 3. A catering request becomes a priced PayPal invoice with a QR code. */
function CateringCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [task, setTask] = useState<Json>();
  const [request, setRequest] = useState<Json>();
  const [qr, setQr] = useState<string>();
  useEffect(() => () => {
    if (qr) URL.revokeObjectURL(qr);
  }, [qr]);
  const start = () =>
    demo.run(async (signal, say) => {
      setTask(undefined);
      setRequest(undefined);
      setQr(undefined);
      say("Finding the catering request");
      const list = await api.query<{ rows: Json[] }>("catering", { restaurantId: tenant }).catch((e) => {
        throw unavailable(e, "Catering");
      });
      // A request still being priced, or priced with its invoice waiting for
      // approval, is shown; otherwise (sent, paid, or a send that failed) a
      // new one is placed so the agent works in front of the judge.
      let row: Json | undefined;
      for (const r of list.rows) {
        if (!r.taskId || ["paid", "cancelled", "sent"].includes(String(r.status))) continue;
        if (r.status === "requested") {
          row = r;
          break;
        }
        const t = await api.query<Json>("agent.task", { restaurantId: tenant, id: Number(r.taskId) }).catch(() => undefined);
        if (t && ((t.actions as Json[] | undefined) ?? []).some((a) => a.status === "pending")) {
          row = r;
          break;
        }
      }
      if (!row) {
        say("A customer asks for lunch for twelve");
        try {
          await api.command("catering.request", tenant, {
            customerEmail: judge.buyerEmail || "caterer@example.com",
            customerName: "Studio Lumen",
            text: "Lunch for 12 on Friday, sandwiches and salads, budget $150. Two of us are vegetarian.",
          });
        } catch (e) {
          throw unavailable(e, "Catering");
        }
        say("The catering agent is pricing it from the menu");
        row = await pollRows<Json>(
          () => api.query<Json>("catering", { restaurantId: tenant }),
          (rows) => rows.find((r) => r.taskId && r.status !== "cancelled"),
          signal,
        ).catch(() => {
          throw new Error("The catering agent is not available on this deployment yet.");
        });
      }
      const done = await agentTask(api, tenant, Number(row.taskId), signal, 120000);
      say("Reading the quote");
      const fresh = await api.query<Json>("catering.request", { restaurantId: tenant, id: row.id }).catch(() => row);
      setRequest(fresh);
      setTask(done);
    });
  const quote = (request?.quote ?? {}) as Json;
  const lines = (quote.lines as Json[] | undefined) ?? [];
  const code = String(request?.currency ?? "USD");
  const refresh = async () => {
    const t = await api.query<Json>("agent.task", { restaurantId: tenant, id: task!.id });
    const fresh = await api.query<Json>("catering.request", { restaurantId: tenant, id: request!.id }).catch(() => request!);
    setRequest(fresh);
    if (typeof fresh.qrUrl === "string" && fresh.qrUrl.startsWith("data:image/")) {
      setQr(fresh.qrUrl);
    } else if (fresh.qrMediaId) {
      const blob = await api.file(Number(fresh.qrMediaId)).catch(() => undefined);
      if (blob) setQr(URL.createObjectURL(blob));
    }
    return t;
  };
  return (
    <Card
      n={3}
      icon="invoice"
      title="Bill the caterer"
      time="about 20 s, then PayPal"
      lead="A customer asks for lunch for twelve. The catering agent prices it from the menu, keeps to the budget and drafts the invoice with a deposit. After your identity check, PayPal Invoicing sends it, with a QR code the customer can pay from."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Quote and invoice
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          {request && (
            <div className="ops-try-ticket">
              <span className="ops-eyebrow">
                {String(request.customerName ?? "Customer")} · {String(request.status ?? "")}
              </span>
              <p className="ops-try-answer">“{String(request.text ?? "")}”</p>
              {lines.length > 0 && (
                <ul>
                  {lines.map((l, i) => (
                    <li key={i}>
                      {Number(l.quantity ?? 1)}× {String(l.name ?? "")} · {money(Number(l.unitMinor ?? l.priceMinor ?? 0) * Number(l.quantity ?? 1), code)}
                    </li>
                  ))}
                </ul>
              )}
              <strong>
                {counted(request.totalMinor, code)}
                {Number(request.depositMinor ?? 0) > 0 ? ` · deposit ${money(request.depositMinor, code)}` : ""}
              </strong>
              {request.invoiceNumber ? <p>Invoice {String(request.invoiceNumber)} sent by PayPal.</p> : null}
              {qr && (
                <figure className="ops-try-photo small">
                  <img src={qr} alt="PayPal QR code for this invoice" />
                  <figcaption>PayPal's QR code for the invoice</figcaption>
                </figure>
              )}
            </div>
          )}
          <MoneyOutcome
            api={api}
            tenant={tenant}
            task={task}
            action={pendingOf(task)}
            executed="Sent with PayPal Invoicing. The customer pays on PayPal's page or from the QR code; when it is paid, the order goes to the kitchen."
            chips={[
              ...toolsUsed(task.trace).map((t) => (/invoice/i.test(t) ? "PayPal Invoicing via MCP" : `used ${t}`)),
              `quoted in ${demo.took}`,
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
            refresh={refresh}
          />
        </div>
      )}
    </Card>
  );
}

/* 4. A complaint on a paid order becomes a proposed PayPal refund. */
function ComplaintCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [task, setTask] = useState<Json>();
  const [complaint, setComplaint] = useState<Json>();
  const start = () =>
    demo.run(async (signal, say) => {
      setTask(undefined);
      setComplaint(undefined);
      say("Finding a complaint on a paid order");
      const list = await api.query<{ rows: Json[] }>("complaints", { restaurantId: tenant }).catch((e) => {
        throw unavailable(e, "Complaints");
      });
      let row = list.rows.find((r) => ["open", "proposed"].includes(String(r.status)) && r.taskId);
      if (!row) {
        const orders = await api.query<{ rows: Json[] }>("orders", {
          restaurantId: tenant,
          staff: true,
          order: "desc",
          limit: 100,
        });
        const taken = new Set(list.rows.map((r) => Number(r.orderId)));
        const paid = orders.rows.find(
          (o) => o.paymentStatus === "paid" && !["cancelled", "rejected", "expired"].includes(String(o.status)) && !taken.has(Number(o.id)),
        );
        if (!paid)
          throw new Error("No paid order without a complaint yet: pay for one with card 6 first, then come back.");
        say(`A diner writes about ticket #${String(paid.number ?? paid.id)}`);
        // The diner names a dish that order really has, so the agent can check it.
        const first = ((paid.lines as Json[] | undefined) ?? [])[0];
        const dish = first ? String(first.name ?? "order").toLowerCase() : "order";
        try {
          await api.command("complaint.open", tenant, { text: `My ${dish} was missing from the bag.` }, { id: Number(paid.id) });
        } catch (e) {
          throw unavailable(e, "Complaints");
        }
        say("The complaints agent is checking the ticket and PayPal's capture");
        row = await pollRows<Json>(
          () => api.query<Json>("complaints", { restaurantId: tenant }),
          (rows) => rows.find((r) => Number(r.orderId) === Number(paid.id) && r.taskId),
          signal,
        ).catch(() => {
          throw new Error("The complaints agent is not available on this deployment yet.");
        });
      }
      const done = await agentTask(api, tenant, Number(row.taskId), signal, 120000);
      setComplaint(row);
      setTask(done);
    });
  const pending = task ? pendingOf(task) : undefined;
  const preview = (pending?.preview ?? {}) as Json;
  return (
    <Card
      n={4}
      icon="money"
      title="Settle a complaint"
      time="about 20 s, then PayPal"
      lead="A diner says something was missing. The complaints agent reads the kitchen ticket and PayPal's record of the capture, then proposes a full refund, a partial one or none, with its reasons. After your identity check, PayPal refunds it and the refund id is kept on the order."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Settle it
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          {complaint && (
            <div className="ops-try-ticket">
              <span className="ops-eyebrow">Complaint on order {String(complaint.orderId)}</span>
              <p className="ops-try-answer">“{String(complaint.text ?? "")}”</p>
              {preview.amountMinor !== undefined && (
                <strong>
                  Proposed refund {counted(preview.amountMinor, String(preview.currency ?? "USD"))}
                  {preview.capturedMinor !== undefined ? ` of ${money(preview.capturedMinor, String(preview.currency ?? "USD"))} captured` : ""}
                </strong>
              )}
            </div>
          )}
          <MoneyOutcome
            api={api}
            tenant={tenant}
            task={task}
            action={pending}
            executed="Refunded through PayPal. The diner gets PayPal's email; the order shows the refund."
            chips={[
              ...toolsUsed(task.trace).map((t) => (/paypal/i.test(t) ? "asked PayPal via MCP" : `used ${t}`)),
              `checked in ${demo.took}`,
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
            refresh={() => api.query<Json>("agent.task", { restaurantId: tenant, id: task.id })}
          />
        </div>
      )}
    </Card>
  );
}

/* 7. A photo of a printed menu becomes a draft menu. */
function MenuCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [rows, setRows] = useState<DraftRow[]>([]);
  const [task, setTask] = useState<Json>();
  const [action, setAction] = useState<AgentActionRow>();
  const [outcome, setOutcome] = useState("");
  const start = () =>
    demo.run(async (signal, say) => {
      setRows([]);
      setTask(undefined);
      setAction(undefined);
      setOutcome("");
      // Every judge reads the photo against the same starting menu, so the
      // changes it finds are the same ones the film and the README show.
      say("Putting the starting menu back");
      await api.command("judge.reset", tenant, { menu: true }).catch(() => {});
      say("Finding the menu photo");
      const media = await api.query<{ rows: Json[] }>("media", {
        restaurantId: tenant,
        limit: 100,
      });
      // The menu photo by its id when the build knows it; otherwise the first
      // approved source photo, which is the menu (the delivery note and the
      // receipt came later).
      const sources = media.rows
        .filter((m) => m.purpose === "menuSource" && m.status === "approved")
        .sort((a, b) => Number(a.id) - Number(b.id));
      const photo = sources.find((m) => m.id === judge.menuMediaId) ?? sources[0];
      if (!photo) throw new Error("The sample menu photo is not set up yet.");
      say("The menu agent is reading the photo with Gemini");
      const asked = await api.command<{ taskId: number }>("menu.snap", tenant, {
        mediaIds: [photo.id],
      });
      const done = await agentTask(api, tenant, asked.taskId, signal);
      const pending = pendingOf(done);
      if (!pending) throw new Error(String(done.summary ?? "Nothing to review."));
      say("Comparing with the menu on sale");
      const [drafts, menu] = await Promise.all([
        api.query<{ rows: Json[] }>("menu.drafts", {
          restaurantId: tenant,
          cursor: Number(pending.preview.draftId) - 1,
          limit: 1,
        }),
        menuOf(api, tenant),
      ]);
      const draft = drafts.rows.find((d) => d.id === pending.preview.draftId);
      setRows(menuChanges((draft?.items as Json[] | undefined) ?? [], menu));
      setTask(done);
      setAction(pending);
    });
  // A dish without a price is held back, not published, so it is not "new".
  const fresh = rows.filter((r) => r.change === "new" && r.available).length;
  const repriced = rows.filter((r) => r.change === "price").length;
  const check = rows.filter((r) => !r.available).length;
  const sections = [...new Set(rows.map((r) => r.category))];
  return (
    <Card
      n={7}
      icon="menu"
      title="Read a printed menu"
      time="about 20 s"
      lead="The menu agent reads this photo, compares it with the menu on sale and prepares the changes. Nothing changes until you approve."
    >
      <figure className="ops-try-sample">
        <img src="/judges/menu.jpg" alt="Printed menu of Atelier Café: 14 dishes in 5 sections, prices in US dollars" />
        <figcaption>The photo the agent reads</figcaption>
      </figure>
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        {demo.phase === "idle" ? "Read this menu" : "Read it again"}
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          <Chips
            items={[
              `${rows.length} dishes in ${sections.length} sections`,
              `${fresh} new`,
              `${repriced} price ${repriced === 1 ? "change" : "changes"}`,
              check > 0 && `${check} without a price, held back`,
              `read in ${demo.took}`,
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
          />
          <table className="ops-try-table">
            <thead>
              <tr>
                <th scope="col">Dish</th>
                <th scope="col">Section</th>
                <th scope="col">Price</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.name} className={r.change}>
                  <td>
                    {r.name}
                    {r.change === "new" && r.available && <em>new</em>}
                    {!r.available && <em className="warn">held back, price to check</em>}
                  </td>
                  <td>{r.category}</td>
                  <td>
                    {r.available ? currency(r.priceMinor, "USD") : "—"}
                    {r.was !== undefined && <s>{currency(r.was, "USD")}</s>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {outcome ? (
            <p className="ops-try-done" role="status">
              <Icon name="check" size={18} />
              {outcome}
            </p>
          ) : (
            action && (
              <Approve
                api={api}
                tenant={tenant}
                action={action}
                done={(state) =>
                  setOutcome(
                    decided(state, "Published. Diners see the new menu in the app now."),
                  )
                }
              />
            )
          )}
        </div>
      )}
    </Card>
  );
}

/* 8. A spoken order becomes ticket lines at the counter. */
function VoiceCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [heard, setHeard] = useState<{
    lines: string[];
    label?: string;
    unmatched: string[];
    ms?: number;
  }>();
  const [recording, setRecording] = useState(false);
  const recorder = useRef<MediaRecorder | null>(null);
  useEffect(
    () => () => {
      recorder.current?.stream.getTracks().forEach((t) => t.stop());
    },
    [],
  );
  const send = (audio: () => Promise<Blob>, what: string) =>
    demo.run(async (_, say) => {
      setHeard(undefined);
      const blob = await audio();
      say(`Gemini is listening to ${what}`);
      const [result, menu] = await Promise.all([
        api.listen<Json>(tenant, blob),
        menuOf(api, tenant),
      ]);
      setHeard({
        lines: heardLines((result.lines as Json[] | undefined) ?? [], menu),
        label: typeof result.customerLabel === "string" ? result.customerLabel : undefined,
        unmatched: (result.unmatched as string[] | undefined) ?? [],
        ms: typeof result.ms === "number" ? result.ms : undefined,
      });
    });
  const sample = () =>
    send(async () => {
      const response = await fetch("/judges/counter-order.wav");
      return new Blob([await response.arrayBuffer()], { type: "audio/wav" });
    }, "the recording");
  async function speak() {
    if (recording) {
      recorder.current?.stop();
      return;
    }
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const type = ["audio/webm;codecs=opus", "audio/webm", "audio/mp4", "audio/ogg;codecs=opus"].find(
        (t) => MediaRecorder.isTypeSupported(t),
      );
      const r = new MediaRecorder(stream, { mimeType: type, audioBitsPerSecond: 32000 });
      const chunks: Blob[] = [];
      r.ondataavailable = (e) => chunks.push(e.data);
      const stopped = new Promise<Blob>((resolve) => {
        r.onstop = () => {
          stream.getTracks().forEach((t) => t.stop());
          setRecording(false);
          resolve(new Blob(chunks, { type: r.mimeType }));
        };
      });
      recorder.current = r;
      r.start();
      setRecording(true);
      setTimeout(() => r.state === "recording" && r.stop(), 15000);
      void send(() => stopped, "you");
    } catch {
      setRecording(false);
      void demo.run(async () => {
        throw new Error("The microphone is not available here. Send the recording instead.");
      });
    }
  }
  return (
    <Card
      n={8}
      icon="mic"
      title="Take an order by voice"
      time="about 5 s"
      lead="At the counter the cashier says the order; the counter agent turns it into ticket lines from this café's menu. Nothing is charged."
    >
      <figure className="ops-try-sample audio">
        <audio controls preload="none" src="/judges/counter-order.wav" />
        <figcaption>
          “Two croque monsieur, one of them with a fried egg. A cappuccino with oat milk. And a lemonade. The name is Sam.”
          <small> A synthetic voice, 7 s.</small>
        </figcaption>
      </figure>
      <div className="ops-try-actions">
        <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void sample()}>
          <Icon name="play" size={18} />
          Send this recording
        </button>
        <button
          className="ops-secondary"
          disabled={demo.phase === "running" && !recording}
          aria-pressed={recording}
          onClick={() => void speak()}
        >
          <Icon name="mic" size={18} />
          {recording ? "Stop and send" : "Say your own order"}
        </button>
      </div>
      {recording && (
        <p className="ops-try-progress" role="status">
          <i className="ops-try-rec" aria-hidden="true" /> Listening… say dishes from the menu, up to 15 s.
        </p>
      )}
      {!recording && <Progress demo={demo} />}
      {heard && (
        <div className="ops-try-result">
          <div className="ops-try-ticket">
            <span className="ops-eyebrow">Counter ticket{heard.label ? ` · ${heard.label}` : ""}</span>
            {heard.lines.length ? (
              <ul>
                {heard.lines.map((l, i) => (
                  <li key={`${l}-${i}`}>{l}</li>
                ))}
              </ul>
            ) : (
              <p>No dish from this menu was heard.</p>
            )}
          </div>
          <Chips
            items={[
              heard.unmatched.length > 0 && `Not on the menu: ${heard.unmatched.join(", ")}`,
              `heard in ${demo.took}`,
              heard.ms !== undefined && `${(heard.ms / 1000).toFixed(1)} s on the server`,
              "audio is not stored",
            ]}
          />
        </div>
      )}
    </Card>
  );
}

/* 6. One sentence becomes a paid pickup order, approved in PayPal. */
function OrderCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const pay = useDemo();
  const [text, setText] = useState("Two vegetarian lunches under $25, ready as soon as you can, please.");
  const [run, setRun] = useState<Json>();
  const [checkout, setCheckout] = useState<{ id: number; orderId: number; url: string }>();
  const [paid, setPaid] = useState<Json>();
  const keys = useRef<Record<string, string>>({});
  const key = (step: string) => (keys.current[step] ??= crypto.randomUUID());
  const basket = basketOf(run);
  const ask = () =>
    demo.run(async (signal, say) => {
      keys.current = {};
      setRun(undefined);
      setCheckout(undefined);
      setPaid(undefined);
      say("Raysto is reading the menu and building a basket");
      const started = await api.command<{ runId: number }>(
        "assistant.start",
        tenant,
        { text, locale: "en", context: "cart" },
        { key: key("start") },
      );
      const done = await poll(
        () => api.query<Json>("assistant.run", { restaurantId: tenant, id: started.runId }),
        (r) => !["queued", "running"].includes(String(r.status)),
        signal,
        1500,
        90000,
      );
      if (!basketOf(done))
        throw new Error(String((done.answer as Json | undefined)?.text ?? "Raysto did not propose a basket. Try other words."));
      setRun(done);
    });
  const order = () => {
    if (!basket) return;
    // One tap: the tab opens now, while the browser still counts it as a
    // click, and gets PayPal's page as soon as the order exists.
    const tab = window.open("", "_blank", "noopener");
    return pay.run(async (signal, say) => {
      say("Approving the basket and placing the order");
      const approved = await api.command<{ quoteId: number }>(
        "assistant.approve",
        tenant,
        {},
        { id: basket.id, version: basket.version, key: key("approve") },
      );
      const placed = await api.typed<{ orderId: number }>(
        "order.submit",
        tenant,
        { quoteId: approved.quoteId },
        key("submit"),
      );
      say("Creating the PayPal order");
      const allocated = await api.typed<{ checkoutId: number }>(
        "payment.allocate",
        tenant,
        { orderId: placed.orderId, method: "paypal" },
        key("allocate"),
      );
      let created: { approvalUrl: string };
      try {
        created = await api.command<{ approvalUrl: string }>(
          "payment.checkout",
          tenant,
          {},
          { id: allocated.checkoutId, key: key("checkout") },
        );
      } catch (e) {
        tab?.close();
        throw e;
      }
      if (tab && !tab.closed) tab.location.href = created.approvalUrl;
      setCheckout({ id: allocated.checkoutId, orderId: placed.orderId, url: created.approvalUrl });
      say("Waiting for you to approve in PayPal Sandbox");
      const final = await poll(
        () => api.query<Json>("checkout", { restaurantId: tenant, id: allocated.checkoutId }),
        (c) => ["completed", "cancelled", "failed"].includes(String(c.state)),
        signal,
        3000,
        15 * 60000,
      );
      if (final.state !== "completed")
        throw new Error("PayPal did not complete this payment. Run it again.");
      say("PayPal captured it; reading the order");
      const detail = await api.query<Json>("order", {
        restaurantId: tenant,
        id: placed.orderId,
        staff: true,
      });
      const payment = ((detail.payments as Json[] | undefined) ?? []).find(
        (p) => p.checkoutId === allocated.checkoutId,
      );
      setPaid({ ...detail, captureId: payment?.providerCaptureId });
    });
  };
  const slot = basket?.slot
    ? new Date(basket.slot).toLocaleTimeString("en-US", {
        hour: "numeric",
        minute: "2-digit",
        timeZone: cafeZone,
      })
    : undefined;
  return (
    <Card
      n={6}
      icon="chat"
      title="Order lunch in one sentence"
      time="about 20 s, then PayPal"
      lead="Ask Raysto as a diner would. It reads the menu, keeps to your budget and proposes a basket. Then one tap places the order and opens PayPal Sandbox in a new tab. Only your approval in PayPal pays."
    >
      <label className="ops-try-input">
        <span>What would you like?</span>
        <textarea rows={2} maxLength={300} value={text} onChange={(e) => setText(e.target.value)} />
      </label>
      <button
        className="ops-primary"
        disabled={demo.phase === "running" || pay.phase === "running" || !text.trim()}
        onClick={() => void ask()}
      >
        <Icon name="chat" size={18} />
        Ask Raysto
      </button>
      <Progress demo={demo} />
      {basket && (
        <div className="ops-try-result">
          {typeof (run?.answer as Json | undefined)?.text === "string" && (
            <p className="ops-try-answer">{String((run?.answer as Json).text)}</p>
          )}
          <div className="ops-try-ticket">
            <span className="ops-eyebrow">Proposed basket · pickup {slot ? `at ${slot} café time` : "as soon as it is ready"}</span>
            <ul>
              {basket.lines.map((l, i) => (
                <li key={`${l}-${i}`}>{l}</li>
              ))}
            </ul>
            <strong>{currency(basket.totalMinor, basket.currency)}</strong>
          </div>
          <Chips items={[`answered in ${demo.took}`, ...toolsUsed(run?.steps).map((t) => `used ${t}`)]} />
          {!checkout && (
            <button className="ops-primary" disabled={pay.phase === "running"} onClick={() => void order()}>
              <Icon name="paypal" size={18} />
              Order and pay with PayPal
            </button>
          )}
          {checkout && !paid && (
            <div className="ops-try-paypal">
              <a className="ops-primary" href={checkout.url} target="_blank" rel="noopener noreferrer">
                <Icon name="paypal" size={18} />
                Open PayPal Sandbox again
              </a>
              <small>PayPal opened in a new tab. If your browser blocked it, use this link.</small>
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
              <small>Sandbox money only. Approve, then come back here: this card updates by itself.</small>
            </div>
          )}
          <Progress demo={pay} />
          {/* The stamp is mounted before PayPal captures, so it lands at the moment it does. */}
          <div className="ops-try-paidline">
            {paid && (
              <p className="ops-try-done" role="status">
                <Icon name="check" size={18} />
                <span>
                  Paid in PayPal Sandbox{paid.captureId ? `, capture ${String(paid.captureId)}` : ""}. Ticket
                  {paid.number ? ` #${String(paid.number)}` : ""} is on the kitchen board
                  {paid.pickupCode ? `; pickup code ${String(paid.pickupCode)}` : ""}.
                </span>
              </p>
            )}
            <Stamp paid={Boolean(paid)} />
          </div>
        </div>
      )}
    </Card>
  );
}

/* 5. The payments agent checks an unfinished PayPal payment. */
function PaymentCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [task, setTask] = useState<Json>();
  const [action, setAction] = useState<AgentActionRow>();
  const [outcome, setOutcome] = useState("");
  const start = () =>
    demo.run(async (signal, say) => {
      setTask(undefined);
      setAction(undefined);
      setOutcome("");
      say("A diner orders an espresso and opens PayPal");
      const menu = await menuOf(api, tenant);
      const dish =
        menu.find((d) => d.name.toLowerCase() === "espresso") ??
        menu.find((d) => !(d.modifiers ?? []).length);
      if (!dish) throw new Error("The menu has nothing to order.");
      const quote = await api.typed<{ id: number }>("quote.create", tenant, {
        fulfillment: "pickup",
        linesJson: JSON.stringify([{ productId: dish.productId, quantity: 1, options: [], note: "" }]),
        tipMinor: 0,
      });
      const placed = await api.typed<{ orderId: number }>("order.submit", tenant, { quoteId: quote.id });
      const allocated = await api.typed<{ checkoutId: number }>("payment.allocate", tenant, {
        orderId: placed.orderId,
        method: "paypal",
      });
      await api.command("payment.checkout", tenant, {}, { id: allocated.checkoutId });
      say("They walk away without paying. The payments agent asks PayPal");
      // "check": the agent reads the ledger and PayPal and reports what it
      // found, rather than repeating a report the manager never made.
      const asked = await api.command<{ taskId: number }>(
        "payment.check",
        tenant,
        { reason: "left" },
        { id: allocated.checkoutId },
      );
      const done = await agentTask(api, tenant, asked.taskId, signal, 90000);
      setTask(done);
      setAction(pendingOf(done));
    });
  return (
    <Card
      n={5}
      icon="paypal"
      title="Chase an unfinished payment"
      time="about 20 s"
      lead="A diner opens PayPal and walks away. The payments agent reads Raysto's ledger and asks PayPal itself, through the PayPal MCP server, then prepares the fix. Money changes need your identity check."
    >
      <button className="ops-primary" disabled={demo.phase === "running"} onClick={() => void start()}>
        <Icon name="play" size={18} />
        Leave a payment unfinished
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          <Chips
            items={[
              ...toolsUsed(task.trace).map((t) => (t === "read_paypal" ? "asked PayPal via MCP" : `used ${t}`)),
              `checked in ${demo.took}`,
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
            ]}
          />
          {outcome ? (
            <p className="ops-try-done" role="status">
              <Icon name="check" size={18} />
              {outcome}
            </p>
          ) : action ? (
            <Approve
              api={api}
              tenant={tenant}
              action={action}
              done={(state) =>
                setOutcome(decided(state, "Released. The order can be paid again or cancelled; PayPal holds nothing."))
              }
            />
          ) : (
            <p className="ops-try-answer">{String(task.summary ?? "")}</p>
          )}
        </div>
      )}
    </Card>
  );
}

/* 9. The image studio draws a dish; the photo waits for approval. */
function PhotoCard({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const demo = useDemo();
  const [dishes, setDishes] = useState<Dish[]>([]);
  const [chosen, setChosen] = useState<number>();
  const [picture, setPicture] = useState<string>();
  const [task, setTask] = useState<Json>();
  const [action, setAction] = useState<AgentActionRow>();
  const [outcome, setOutcome] = useState("");
  useEffect(() => {
    let live = true;
    void menuOf(api, tenant)
      .then((menu) => {
        if (!live) return;
        setDishes(menu);
        setChosen((menu.find((d) => d.name.toLowerCase().startsWith("croque")) ?? menu[0])?.productId);
      })
      .catch(() => {});
    return () => {
      live = false;
    };
  }, [api, tenant]);
  useEffect(() => () => {
    if (picture) URL.revokeObjectURL(picture);
  }, [picture]);
  const start = () =>
    demo.run(async (signal, say) => {
      if (!chosen) throw new Error("Choose a dish.");
      setTask(undefined);
      setAction(undefined);
      setOutcome("");
      setPicture(undefined);
      say("Gemini is drawing the dish");
      const asked = await api.command<{ taskIds: number[] }>("menu.photo", tenant, {
        productIds: [chosen],
        provider: "gemini",
      });
      // Gemini's image model is sometimes slow; the server asks it once more after 90 s.
      const slow = setTimeout(
        () => say("Taking longer than usual. If Gemini does not answer within 90 s, Raysto asks it once more by itself"),
        60000,
      );
      let done: Json;
      try {
        done = await agentTask(api, tenant, asked.taskIds[0], signal, 300000);
      } catch (e) {
        throw new Error(`${message(e)} Image models are sometimes busy: try again in a minute.`);
      } finally {
        clearTimeout(slow);
      }
      const pending = pendingOf(done);
      if (!pending) throw new Error(String(done.summary ?? "No photo came back."));
      say("Loading the scanned photo");
      const blob = await api.file(Number(pending.preview.mediaId));
      setPicture(URL.createObjectURL(blob));
      setTask(done);
      setAction(pending);
    });
  return (
    <Card
      n={9}
      icon="image"
      title="Draw a dish for the menu"
      time="about 45 s"
      lead="The image studio asks Gemini for a photo of a dish from its own description. The picture is scanned, waits for you, and diners see it labelled as an AI image. If Gemini is slow, Raysto asks it once more by itself."
    >
      <label className="ops-try-input">
        <span>Dish</span>
        <select value={chosen ?? ""} onChange={(e) => setChosen(Number(e.target.value))}>
          {dishes.map((d) => (
            <option key={d.productId} value={d.productId}>
              {d.name}
            </option>
          ))}
        </select>
      </label>
      <button className="ops-primary" disabled={demo.phase === "running" || !chosen} onClick={() => void start()}>
        <Icon name="image" size={18} />
        Draw this dish
      </button>
      <Progress demo={demo} />
      {task && (
        <div className="ops-try-result">
          {picture && (
            <figure className="ops-try-photo">
              <img src={picture} alt={`AI photo proposed for ${String(action?.preview.dish ?? "the dish")}`} />
              <figcaption>
                Drawn by {String(action?.preview.model ?? "Gemini")} · waits for approval
              </figcaption>
            </figure>
          )}
          <Chips
            items={[
              `drawn in ${demo.took}`,
              ...(String(task.summary ?? "").includes("second try") ? ["Gemini answered on the second try"] : []),
              `AI cost ${agentCost(Number(task.chargedMicros ?? 0))}`,
              "scanned before you see it",
            ]}
          />
          {outcome ? (
            <p className="ops-try-done" role="status">
              <Icon name="check" size={18} />
              {outcome}
            </p>
          ) : (
            action && (
              <Approve
                api={api}
                tenant={tenant}
                action={action}
                done={(state) => setOutcome(decided(state, "On the menu, labelled “AI image” for diners."))}
              />
            )
          )}
        </div>
      )}
    </Card>
  );
}

export function TrySection({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const [resetting, setResetting] = useState(false);
  const [note, setNote] = useState("");
  async function reset() {
    setResetting(true);
    setNote("");
    try {
      await api.command("judge.reset", tenant, {});
      setNote("The café is back to its starting menu and settings.");
    } catch (e) {
      setNote(message(e));
    } finally {
      setResetting(false);
    }
  }
  return (
    <MotionRoot>
      <div className="ops-try">
        <section className="ops-try-intro">
          <div>
            <span className="ops-eyebrow">TRY RAYSTO · NINE LIVE DEMOS, MONEY FIRST</span>
            <h2>AI coworkers run the café&rsquo;s money. You approve. PayPal moves it.</h2>
            <p>
              Each card runs the real product on this demo café: Gemini models, the PayPal MCP server, PayPal Payouts,
              Invoicing, Refunds and Sandbox checkout. No real money moves, and nothing changes until you approve it.
            </p>
          </div>
          <div className="ops-try-intro-side">
            <span className="ops-sandbox">
              <Icon name="paypal" size={16} />
              PayPal Sandbox
            </span>
            <button className="ops-quiet" disabled={resetting} onClick={() => void reset()}>
              <Icon name="refresh" size={18} />
              {resetting ? "Starting fresh…" : "Start the café fresh"}
            </button>
            {note && (
              <small role="status" aria-live="polite">
                {note}
              </small>
            )}
          </div>
        </section>
        <div className="ops-try-grid">
          <CloseCard api={api} tenant={tenant} />
          <PayrollCard api={api} tenant={tenant} />
          <CateringCard api={api} tenant={tenant} />
          <ComplaintCard api={api} tenant={tenant} />
          <PaymentCard api={api} tenant={tenant} />
          <OrderCard api={api} tenant={tenant} />
          <MenuCard api={api} tenant={tenant} />
          <VoiceCard api={api} tenant={tenant} />
          <PhotoCard api={api} tenant={tenant} />
        </div>
      </div>
    </MotionRoot>
  );
}
