"use client";
/**
 * The Overview's AI Action Inbox: the work the AI coworkers prepared, at the
 * top of the console. Each proposal shows who prepared it, its evidence and
 * whether it moves money; Approve and Not now go through `agent.decide`,
 * with the identity check the server asks for before PayPal moves money.
 * The outcome stays on the card in words, with PayPal's own id when the
 * result (or the record, a moment later) carries one; a refusal reads as a
 * refusal. Every judge shares one café, so the list refreshes itself and a
 * proposal someone else decided first reads as "already handled".
 *
 * Beside it, four starters run the hero flows (hero-flows.ts): real AI work
 * that then lands here for approval.
 */
import { useCallback, useEffect, useMemo, useRef, useState, type FormEvent, type ReactNode } from "react";
import { AnimatePresence, m } from "motion/react";
import { QRCodeSVG } from "qrcode.react";
import type { ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import {
  actionView,
  ago,
  alreadyHandled,
  confirmedOutcome,
  handledOutcome,
  idLookup,
  inboxRows,
  inboxSummary,
  lookupResult,
  outcomeOf,
  type IdLookup,
  type InboxAction,
  type Outcome,
} from "@/lib/connected/inbox";
import { elapsed, isJudgeVenue, judge } from "@/lib/connected/judge";
import { duration, easing, stagger, useFirstVisit, useReduce } from "@/lib/connected/motion";
import { maskEmail, type BillView, type RequestView } from "@/lib/connected/try-new";
import { useDecision } from "./business-sections";
import { StepUpAction } from "./backoffice-sections";
import { billArrived, collectDeposit, guestComplained, runPayroll, waitForPayment, type FlowId, type FlowResult } from "./hero-flows";
import { Icon, type IconName } from "./icons";
import { Stamp } from "./m3";
import { message, useDemo } from "./try-section";
import "./action-inbox.css";

/* ---------- Loading the inbox ---------- */

/** How often the shared café's inbox is read again while the page is visible. */
const EVERY_MS = 20000;

/**
 * `agent.inbox` for the Overview: loads with the section, again when the
 * workspace sees a change (`revision`) and every 20 s while the page is
 * visible, since another judge may decide a proposal at any time. A late
 * answer never replaces a newer one.
 */
export function useInbox(api: ConnectedApi, tenant: number, revision: string) {
  const [rows, setRows] = useState<InboxAction[]>([]);
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState("");
  const live = useRef(true);
  const seq = useRef(0);
  const load = useCallback(async () => {
    const n = ++seq.current;
    try {
      const raw = await api.query<Json>("agent.inbox", { restaurantId: tenant });
      if (!live.current || n !== seq.current) return;
      setRows(inboxRows(raw));
      setError("");
    } catch (e) {
      if (!live.current || n !== seq.current) return;
      setError(message(e));
    } finally {
      if (live.current && n === seq.current) setLoaded(true);
    }
  }, [api, tenant]);
  useEffect(() => {
    live.current = true;
    return () => {
      live.current = false;
    };
  }, []);
  useEffect(() => {
    void load();
  }, [load, revision]);
  useEffect(() => {
    const timer = setInterval(() => {
      if (document.visibilityState === "visible") void load();
    }, EVERY_MS);
    return () => clearInterval(timer);
  }, [load]);
  return { rows, loaded, error, reload: load };
}

export type InboxState = ReturnType<typeof useInbox>;

/* ---------- The inbox ---------- */

const agentIcons: Record<string, IconName> = {
  accountant: "ledger",
  payroll: "team",
  complaints: "chat",
  payments: "paypal",
  close: "chart",
  catering: "invoice",
  menu: "menu",
  images: "image",
  dispatch: "dispatch",
  supplies: "supplies",
  expenses: "receipt",
  disputes: "alert",
  loyalty: "money",
  orders: "orders",
  counter: "mic",
};

type Decided = { action: InboxAction; outcome: Outcome; lookingUp?: boolean };
type LocalItem =
  | { key: string; kind: "payLink"; request: RequestView; at: string }
  | { key: string; kind: "payBill"; bill: BillView; at: string };

/** Items shown before "Show more". */
const FIRST = 4;

const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));

export function ActionInbox({
  api,
  tenant,
  inbox,
  timeZone,
}: {
  api: ConnectedApi;
  tenant: number;
  inbox: InboxState;
  /** The café's own time zone, for due dates. */
  timeZone?: string;
}) {
  const reduce = useReduce();
  const first = useFirstVisit("overview-inbox");
  const [decided, setDecided] = useState<Record<number, Decided>>({});
  const decidedRef = useRef(decided);
  decidedRef.current = decided;
  const [local, setLocal] = useState<LocalItem[]>([]);
  const [fresh, setFresh] = useState<number[]>([]);
  const [all, setAll] = useState(false);
  // Results put away by the person; their rows stay out even before the inbox is read again.
  const [putAway, setPutAway] = useState<number[]>([]);
  const engaged = useRef(new Set<number>());
  const lastRows = useRef<InboxAction[]>([]);
  const live = useRef(true);
  useEffect(() => {
    live.current = true;
    return () => {
      live.current = false;
    };
  }, []);
  const knownPassword = isJudgeVenue(tenant) ? judge.password : "";
  const money = (minor: number, code: string) => currency(minor, code);

  // A proposal someone was working on that left the inbox was decided elsewhere.
  useEffect(() => {
    const now = new Set(inbox.rows.map((r) => r.id));
    const gone = lastRows.current.filter((a) => !now.has(a.id) && engaged.current.has(a.id) && !decidedRef.current[a.id]);
    if (gone.length) setDecided((d) => ({ ...d, ...Object.fromEntries(gone.map((a) => [a.id, { action: a, outcome: handledOutcome }])) }));
    lastRows.current = inbox.rows;
  }, [inbox.rows]);

  const actions = useMemo(() => {
    const byId = new Map<number, InboxAction>();
    for (const a of inbox.rows) if (!putAway.includes(a.id)) byId.set(a.id, a);
    for (const d of Object.values(decided)) if (!byId.has(d.action.id)) byId.set(d.action.id, d.action);
    return [...byId.values()].sort((a, b) => b.id - a.id);
  }, [inbox.rows, decided, putAway]);
  const waiting = inbox.rows.filter((a) => !decided[a.id] && !putAway.includes(a.id));

  const settle = (id: number, change: (d: Decided) => Decided) =>
    setDecided((known) => (known[id] ? { ...known, [id]: change(known[id]) } : known));

  /** After an approval: PayPal's id from the record, when the result did not carry it. */
  async function lookUp(action: InboxAction, lookup: IdLookup) {
    const read = async (): Promise<Json | undefined> => {
      if (lookup.kind === "complaint") {
        const rows = (await api.query<{ rows?: Json[] }>("complaints", { restaurantId: tenant })).rows ?? [];
        return rows.find((r) => Number(r.taskId) === lookup.taskId);
      }
      return api.query<Json>(lookup.kind === "bill" ? "bill" : "payout", { restaurantId: tenant, id: lookup.id });
    };
    const until = Date.now() + 45000;
    while (live.current && Date.now() < until) {
      await wait(3000);
      const found = lookupResult(lookup.kind, await read().catch(() => undefined));
      if (found.paypalId) return settle(action.id, (d) => ({ ...d, lookingUp: false, outcome: confirmedOutcome(action.command, found.paypalId!) }));
      if (found.refused)
        return settle(action.id, (d) => ({
          ...d,
          lookingUp: false,
          outcome: { tone: "refused", text: "PayPal refused it after the approval. No money moved." },
        }));
    }
    settle(action.id, (d) => ({
      ...d,
      lookingUp: false,
      outcome: { ...d.outcome, text: `${d.outcome.text} Its PayPal id appears on the record once PayPal confirms.` },
    }));
  }

  function onDecided(action: InboxAction, outcome: Outcome) {
    engaged.current.delete(action.id);
    const lookup = outcome.tone === "done" && !outcome.paypalId ? idLookup(action) : undefined;
    setDecided((d) => ({ ...d, [action.id]: { action, outcome, lookingUp: !!lookup } }));
    if (lookup) void lookUp(action, lookup);
    void inbox.reload();
  }

  function dismiss(id: number) {
    setPutAway((h) => [...h, id]);
    setDecided((d) => {
      const { [id]: _gone, ...rest } = d;
      return rest;
    });
  }

  /** A starter's proposal arrived: read the inbox, then bring it into view. */
  async function arrived(actionId: number) {
    await inbox.reload();
    if (!live.current) return;
    setFresh((f) => [...f, actionId]);
    requestAnimationFrame(() =>
      document.getElementById(`inbox-${actionId}`)?.scrollIntoView({ block: "nearest", behavior: reduce ? "auto" : "smooth" }),
    );
    setTimeout(() => live.current && setFresh((f) => f.filter((id) => id !== actionId)), 6000);
  }

  function started(result: FlowResult) {
    if (result.kind === "proposal") void arrived(result.actionId);
    else if (result.kind === "payLink" || result.kind === "payBill") {
      const item: LocalItem =
        result.kind === "payLink"
          ? { key: `link-${result.request.id}`, kind: "payLink", request: result.request, at: new Date().toISOString() }
          : { key: `bill-${result.bill.id}-${Date.now()}`, kind: "payBill", bill: result.bill, at: new Date().toISOString() };
      setLocal((l) => [item, ...l.filter((x) => x.key !== item.key)]);
      requestAnimationFrame(() => document.getElementById(`inbox-${item.key}`)?.scrollIntoView({ block: "nearest", behavior: reduce ? "auto" : "smooth" }));
    }
  }

  // What a starter just put here comes first, then the newest.
  const ordered = fresh.length ? [...actions].sort((a, b) => Number(fresh.includes(b.id)) - Number(fresh.includes(a.id))) : actions;
  const count = local.length + ordered.length;
  const shownActions = all ? ordered : ordered.slice(0, Math.max(0, FIRST - local.length));
  const more = count - local.length - shownActions.length;
  const empty = inbox.loaded && count === 0;
  const entries: { key: string; dom: string; node: ReactNode }[] = [
    ...local.map((item) => ({
      key: item.key,
      dom: item.key,
      node:
        item.kind === "payLink" ? (
          <PayLinkItem api={api} tenant={tenant} request={item.request} at={item.at} onDismiss={() => setLocal((l) => l.filter((x) => x.key !== item.key))} />
        ) : (
          <PayBillItem api={api} tenant={tenant} bill={item.bill} onDismiss={() => setLocal((l) => l.filter((x) => x.key !== item.key))} />
        ),
    })),
    ...shownActions.map((a) => ({
      key: `a${a.id}`,
      dom: String(a.id),
      node: (
        <InboxCard
          api={api}
          tenant={tenant}
          action={a}
          view={actionView(a, money, timeZone)}
          decided={decided[a.id]}
          fresh={fresh.includes(a.id)}
          knownPassword={knownPassword}
          onEngage={(on) => (on ? engaged.current.add(a.id) : engaged.current.delete(a.id))}
          onDecided={(outcome) => onDecided(a, outcome)}
          onHandled={() => onDecided(a, handledOutcome)}
          onCancelled={() => void inbox.reload()}
          onDismiss={() => dismiss(a.id)}
        />
      ),
    })),
  ];

  return (
    <section className={`ops-inbox${empty ? " ops-inbox-is-empty" : ""}`} aria-labelledby="ops-inbox-title">
      <div className="ops-inbox-main">
        <header className="ops-inbox-head">
          <span className="ops-inbox-mark" aria-hidden="true">
            <Icon name="agents" size={22} />
          </span>
          <div className="ops-inbox-heading">
            <h2 id="ops-inbox-title">AI Action Inbox</h2>
            <p>Your AI coworkers prepare the work. You approve. PayPal moves the money.</p>
          </div>
          <div className="ops-inbox-tools">
            {inbox.loaded && !inbox.error && waiting.length > 0 && (
              <span className={`ops-inbox-count${waiting.length ? " busy" : ""}`} role="status">
                {inboxSummary(waiting)}
              </span>
            )}
            <button type="button" className="ops-inbox-refresh" aria-label="Check the inbox again" onClick={() => void inbox.reload()}>
              <Icon name="refresh" size={20} />
            </button>
          </div>
        </header>
        {inbox.error && (
          <p className="ops-inbox-error" role="alert">
            <Icon name="alert" size={18} />
            <span>The inbox could not load: {inbox.error}</span>
          </p>
        )}
        {!inbox.loaded ? (
          <div className="ops-inbox-skeleton" role="status" aria-label="Loading the inbox">
            <span />
            <span />
          </div>
        ) : empty ? (
          <div className="ops-inbox-empty">
            <span className="ops-inbox-empty-mark" aria-hidden="true">
              <Icon name="check" size={28} />
            </span>
            <div>
              <h3>You&rsquo;re all caught up.</h3>
              <p>Nothing is waiting for your approval. Start new work and your AI coworkers will prepare it here.</p>
            </div>
          </div>
        ) : reduce ? (
          <ul className="ops-inbox-list" aria-label="Waiting for your approval">
            {entries.map((e) => (
              <li key={e.key} id={`inbox-${e.dom}`} className="ops-inbox-li">
                {e.node}
              </li>
            ))}
          </ul>
        ) : (
          <ul className="ops-inbox-list" aria-label="Waiting for your approval">
            <AnimatePresence initial={first} mode="popLayout">
              {entries.map((e, i) => (
                <m.li
                  key={e.key}
                  id={`inbox-${e.dom}`}
                  className="ops-inbox-li"
                  layout="position"
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0, transition: { duration: duration.medium2, ease: easing.emphasizedDecelerate, delay: stagger(i) } }}
                  exit={{ opacity: 0, transition: { duration: duration.short4, ease: easing.emphasizedAccelerate } }}
                >
                  {e.node}
                </m.li>
              ))}
            </AnimatePresence>
          </ul>
        )}
        {more > 0 && (
          <button type="button" className="ops-inbox-more" onClick={() => setAll(true)}>
            Show {more} more
            <Icon name="arrow" size={18} />
          </button>
        )}
      </div>
      <Starters api={api} tenant={tenant} onResult={started} />
    </section>
  );
}

/* ---------- One proposal ---------- */

function InboxCard({
  api,
  tenant,
  action,
  view,
  decided,
  fresh,
  knownPassword,
  onEngage,
  onDecided,
  onHandled,
  onCancelled,
  onDismiss,
}: {
  api: ConnectedApi;
  tenant: number;
  action: InboxAction;
  view: ReturnType<typeof actionView>;
  decided?: Decided;
  fresh: boolean;
  knownPassword: string;
  onEngage: (on: boolean) => void;
  onDecided: (outcome: Outcome) => void;
  onHandled: () => void;
  /** The identity check was left: the approval waits, started, on the server. */
  onCancelled: () => void;
  onDismiss: () => void;
}) {
  const decision = useDecision({
    api,
    tenant,
    action,
    knownPassword,
    onDone: (state, result) => onDecided(outcomeOf(action.command, state, result)),
  });
  const { busy, needsCheck, failure } = decision;
  useEffect(() => {
    onEngage(busy || needsCheck);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [busy, needsCheck]);
  // Someone else decided it first (its version moved on, or it is gone).
  useEffect(() => {
    if (alreadyHandled(failure)) onHandled();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [failure]);
  const titleId = `inbox-title-${action.id}`;
  const when = ago(view.createdAt);
  const outcome = decided?.outcome;
  const amount = view.amount ? currency(view.amount.minor, view.amount.currency) : undefined;
  return (
    <article
      className={`ops-inbox-item${view.movesMoney ? " money" : ""}${fresh ? " fresh" : ""}${outcome ? ` decided ${outcome.tone}` : ""}`}
      aria-labelledby={titleId}
    >
      <span className="ops-inbox-avatar" aria-hidden="true">
        <Icon name={agentIcons[action.agent] ?? "agents"} size={20} />
      </span>
      <div className="ops-inbox-body">
        <div className="ops-inbox-top">
          <div className="ops-inbox-titles">
            <p className="ops-inbox-meta">
              <span className="ops-inbox-who">{view.who}</span>
              {when && <span> · {when}</span>}
            </p>
            <h3 id={titleId}>{view.title}</h3>
          </div>
          <div className="ops-inbox-amount">
            {amount && <strong>{amount}</strong>}
            <span className={`ops-inbox-moves${view.movesMoney ? " on" : ""}`}>
              <Icon name={view.movesMoney ? "paypal" : "check"} size={14} />
              {view.movesMoney ? view.rail : "No money moves"}
            </span>
          </div>
        </div>
        {view.rationale && <p className="ops-inbox-why">{view.rationale}</p>}
        {view.facts.length > 0 && (
          <ul className="ops-inbox-facts" aria-label="Evidence">
            {view.facts.map((f) => (
              <li key={f}>{f}</li>
            ))}
          </ul>
        )}
        {outcome ? (
          <OutcomeBlock outcome={outcome} lookingUp={decided?.lookingUp} onDismiss={onDismiss} />
        ) : needsCheck ? (
          <CheckForm
            decision={decision}
            amount={view.movesMoney ? amount : undefined}
            onCancel={() => {
              decision.cancelCheck();
              onCancelled();
            }}
          />
        ) : (
          <div className="ops-inbox-actions">
            <button
              type="button"
              className="ops-primary"
              disabled={busy}
              aria-label={`Approve: ${view.title}`}
              onClick={() => void decision.decide("approve")}
            >
              <Icon name={view.movesMoney ? "lock" : "check"} size={18} />
              {busy ? "Working…" : view.awaitingCheck ? "Finish approving" : "Approve"}
            </button>
            {/* Once an approval has started on the server, only the identity check finishes it. */}
            {!view.awaitingCheck && (
              <button type="button" className="ops-inbox-later" disabled={busy} aria-label={`Not now: ${view.title}`} onClick={() => void decision.decide("reject")}>
                Not now
              </button>
            )}
            <small className="ops-inbox-hint">
              {view.awaitingCheck
                ? "Approval started; the identity check is still to do."
                : view.movesMoney
                  ? "Identity check first, then PayPal moves it."
                  : view.aiCost
                    ? `Prepared by AI for ${view.aiCost}.`
                    : "Nothing changes until you approve."}
            </small>
          </div>
        )}
        {!outcome && failure !== undefined && !alreadyHandled(failure) && decision.note && (
          <p className="ops-inbox-failed" role="alert">
            <Icon name="alert" size={16} />
            <span>It did not go through: {decision.note}</span>
          </p>
        )}
      </div>
    </article>
  );
}

/** The identity check before a money approval: the step where PayPal is about to move money. */
function CheckForm({ decision, amount, onCancel }: { decision: ReturnType<typeof useDecision>; amount?: string; onCancel: () => void }) {
  function submit(e: FormEvent) {
    e.preventDefault();
    void decision.confirm();
  }
  return (
    <form className="ops-inbox-check" onSubmit={submit}>
      <div className="ops-inbox-check-head">
        <Icon name="lock" size={18} />
        <strong>Confirm it&rsquo;s you</strong>
        <span className="ops-paypal-chip">
          <Icon name="paypal" size={14} />
          PayPal Sandbox
        </span>
      </div>
      <p>{amount ? `PayPal moves ${amount} only after this check.` : "Money moves only after this check."}</p>
      <div className="ops-inbox-check-row">
        {decision.passwordAccount && (
          <label>
            <span>Password</span>
            <input
              type="password"
              autoComplete="current-password"
              value={decision.password}
              onChange={(e) => decision.setPassword(e.target.value)}
              required
            />
          </label>
        )}
        <button type="submit" className="ops-primary" disabled={decision.busy}>
          {decision.busy ? "Checking…" : decision.passwordAccount ? "Confirm and approve" : "Confirm with Google and approve"}
        </button>
        <button type="button" className="ops-inbox-later" disabled={decision.busy} onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
}

function OutcomeBlock({ outcome, lookingUp, onDismiss }: { outcome: Outcome; lookingUp?: boolean; onDismiss: () => void }) {
  const icon: IconName =
    outcome.tone === "refused" || outcome.tone === "failed"
      ? "alert"
      : outcome.tone === "expired"
        ? "clock"
        : outcome.tone === "dismissed"
          ? "cross"
          : outcome.tone === "handled"
            ? "team"
            : "check";
  return (
    <div className={`ops-inbox-outcome ${outcome.tone}`} role="status" aria-live="polite">
      <Icon name={icon} size={18} />
      <div>
        <p>{outcome.text}</p>
        {outcome.paypalId && <code className="ops-inbox-id">{outcome.paypalId}</code>}
        {lookingUp && (
          <p className="ops-inbox-pending">
            <span className="ops-spinner small" aria-hidden="true" />
            Waiting for PayPal&rsquo;s id…
          </p>
        )}
      </div>
      <button type="button" className="ops-inbox-later" onClick={onDismiss} aria-label="Dismiss this result">
        <Icon name="cross" size={18} />
      </button>
    </div>
  );
}

/* ---------- Work the starters put in the inbox ---------- */

/** A deposit pay link: its QR code, the link, and PAID once PayPal's capture arrives. */
function PayLinkItem({ api, tenant, request: made, at, onDismiss }: { api: ConnectedApi; tenant: number; request: RequestView; at: string; onDismiss: () => void }) {
  const [request, setRequest] = useState(made);
  const [error, setError] = useState("");
  const [now, setNow] = useState(() => Date.now());
  const begun = useRef(Date.now());
  const open = !request.paid && request.state !== "cancelled" && !error;
  useEffect(() => {
    if (!made.id) return;
    const c = new AbortController();
    waitForPayment(api, tenant, made.id, c.signal)
      .then(setRequest)
      .catch((e) => {
        if (!c.signal.aborted) setError(message(e));
      });
    return () => c.abort();
  }, [api, tenant, made.id]);
  useEffect(() => {
    if (!open) return;
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, [open]);
  return (
    <article className={`ops-inbox-item money${request.paid ? " decided done" : ""}`} aria-labelledby={`link-${made.id}`}>
      <span className="ops-inbox-avatar" aria-hidden="true">
        <Icon name="qr" size={20} />
      </span>
      <div className="ops-inbox-body">
        <div className="ops-inbox-top">
          <div className="ops-inbox-titles">
            <p className="ops-inbox-meta">
              <span className="ops-inbox-who">Pay link</span> · {ago(at) ?? "just now"}
            </p>
            <h3 id={`link-${made.id}`}>{request.description || "Deposit"}</h3>
          </div>
          <div className="ops-inbox-amount">
            <strong>{currency(request.amountMinor, request.currency)}</strong>
            <span className="ops-inbox-moves on">
              <Icon name="paypal" size={14} />
              PayPal checkout
            </span>
          </div>
        </div>
        <p className="ops-inbox-why">For {request.payerName || "the customer"}. They pay on PayPal&rsquo;s own page; nothing is charged here.</p>
        {open && request.payUrl && (
          <div className="ops-inbox-pay">
            <figure>
              <QRCodeSVG value={request.payUrl} size={132} marginSize={2} title="QR code for this pay link" />
              <figcaption>Scan with a phone</figcaption>
            </figure>
            <div className="ops-inbox-pay-side">
              <span className="ops-paypal-chip">
                <Icon name="paypal" size={14} />
                PayPal Sandbox
              </span>
              <a className="ops-primary ops-inbox-link" href={request.payUrl} target="_blank" rel="noopener noreferrer">
                Open the pay link
                <Icon name="external" size={18} />
              </a>
              {judge.buyerEmail && (
                <details className="ops-inbox-buyer">
                  <summary>Test buyer login</summary>
                  <dl>
                    <dt>Email</dt>
                    <dd>
                      <code>{judge.buyerEmail}</code>
                    </dd>
                    <dt>Password</dt>
                    <dd>
                      <code>{judge.buyerPassword}</code>
                    </dd>
                  </dl>
                </details>
              )}
              <p className="ops-inbox-pending" role="status">
                <span className="ops-spinner small" aria-hidden="true" />
                Waiting for the payment · {elapsed(now - begun.current)}
              </p>
            </div>
          </div>
        )}
        <div className="ops-inbox-paidline">
          {request.paid ? (
            <div className="ops-inbox-outcome done" role="status">
              <Icon name="check" size={18} />
              <div>
                <p>Paid with PayPal. The journal records the deposit.</p>
                {request.captureId && <code className="ops-inbox-id">PayPal capture {request.captureId}</code>}
              </div>
              <button type="button" className="ops-inbox-later" onClick={onDismiss} aria-label="Dismiss this result">
                <Icon name="cross" size={18} />
              </button>
            </div>
          ) : request.state === "cancelled" ? (
            <div className="ops-inbox-outcome dismissed" role="status">
              <Icon name="clock" size={18} />
              <p>The pay link was cancelled before it was paid.</p>
            </div>
          ) : error ? (
            <div className="ops-inbox-outcome failed" role="alert">
              <Icon name="alert" size={18} />
              <p>{error}</p>
            </div>
          ) : null}
          <Stamp paid={request.paid} />
        </div>
      </div>
    </article>
  );
}

/** A bill read before, payable now with PayPal Payouts behind the identity check. */
function PayBillItem({ api, tenant, bill, onDismiss }: { api: ConnectedApi; tenant: number; bill: BillView; onDismiss: () => void }) {
  const [outcome, setOutcome] = useState<Outcome>();
  const amount = currency(bill.amountMinor, bill.currency);
  async function pay() {
    const paid = await api.command<Json>("bill.pay", tenant, { approve: true }, { id: bill.id });
    const done = outcomeOf("bill.pay", "executed", paid);
    setOutcome(done);
    if (!done.paypalId && bill.id) {
      // PayPal's batch id is recorded when PayPal accepts the payout.
      for (let i = 0; i < 7 && !done.paypalId; i++) {
        await wait(3000);
        const found = lookupResult("bill", await api.query<Json>("bill", { restaurantId: tenant, id: bill.id }).catch(() => undefined));
        if (found.paypalId) {
          setOutcome(confirmedOutcome("bill.pay", found.paypalId));
          break;
        }
      }
    }
    return done.text;
  }
  return (
    <article className={`ops-inbox-item money${outcome ? ` decided ${outcome.tone}` : ""}`} aria-labelledby={`bill-${bill.id}`}>
      <span className="ops-inbox-avatar" aria-hidden="true">
        <Icon name="ledger" size={20} />
      </span>
      <div className="ops-inbox-body">
        <div className="ops-inbox-top">
          <div className="ops-inbox-titles">
            <p className="ops-inbox-meta">
              <span className="ops-inbox-who">AI accountant</span> · read before
            </p>
            <h3 id={`bill-${bill.id}`}>
              Pay {bill.vendor} {amount}
            </h3>
          </div>
          <div className="ops-inbox-amount">
            <strong>{amount}</strong>
            <span className="ops-inbox-moves on">
              <Icon name="paypal" size={14} />
              PayPal Payouts to the vendor
            </span>
          </div>
        </div>
        <p className="ops-inbox-why">The accountant read this bill before, so no AI was spent again. The vendor takes PayPal.</p>
        <ul className="ops-inbox-facts" aria-label="Evidence">
          {bill.reference && <li>Reference {bill.reference}</li>}
          {bill.vatMinor > 0 && <li>VAT {currency(bill.vatMinor, bill.currency)}</li>}
          {maskEmail(bill.payee) && <li>Pays {maskEmail(bill.payee)}</li>}
        </ul>
        {outcome ? (
          <OutcomeBlock outcome={outcome} onDismiss={onDismiss} />
        ) : (
          <div className="ops-inbox-actions">
            <StepUpAction api={api} tenant={tenant} label="Pay with PayPal" onRun={pay} />
            <span className="ops-paypal-chip">
              <Icon name="paypal" size={14} />
              PayPal Sandbox
            </span>
          </div>
        )}
      </div>
    </article>
  );
}

/* ---------- Starters: the four hero flows ---------- */

const flows: { id: FlowId; icon: IconName; title: string; lead: string; time: string }[] = [
  {
    id: "bill",
    icon: "invoice",
    title: "A bill arrived",
    lead: "The AI accountant reads the café's electricity bill and drafts paying it with PayPal Payouts.",
    time: "about 20 s",
  },
  {
    id: "complaint",
    icon: "chat",
    title: "A guest complained",
    lead: "The complaints agent checks the order and PayPal's capture, then drafts a refund.",
    time: "about 20 s",
  },
  {
    id: "payroll",
    icon: "team",
    title: "Run this week's payroll",
    lead: "The payroll agent turns shifts and tips into one PayPal Payouts batch.",
    time: "about 15 s",
  },
  {
    id: "deposit",
    icon: "qr",
    title: "Collect a deposit",
    lead: "A $35.55 PayPal pay link with a QR code you can scan and pay.",
    time: "about 5 s",
  },
];

function Starters({ api, tenant, onResult }: { api: ConnectedApi; tenant: number; onResult: (r: FlowResult) => void }) {
  return (
    <aside className="ops-inbox-start" aria-labelledby="ops-start-title">
      <h3 id="ops-start-title">Start new work</h3>
      <p>Pick one: an AI coworker prepares it and it lands in the inbox for your approval.</p>
      <ul>
        {flows.map((f) => (
          <Starter key={f.id} api={api} tenant={tenant} flow={f} onResult={onResult} />
        ))}
      </ul>
    </aside>
  );
}

function Starter({ api, tenant, flow, onResult }: { api: ConnectedApi; tenant: number; flow: (typeof flows)[number]; onResult: (r: FlowResult) => void }) {
  const demo = useDemo();
  const [result, setResult] = useState<FlowResult>();
  const running = demo.phase === "running";
  const start = () =>
    demo.run(async (signal, say) => {
      setResult(undefined);
      const inbox = async () => inboxRows(await api.query<Json>("agent.inbox", { restaurantId: tenant }));
      const r =
        flow.id === "bill"
          ? await billArrived(api, tenant, signal, say, inbox)
          : flow.id === "complaint"
            ? await guestComplained(api, tenant, signal, say)
            : flow.id === "payroll"
              ? await runPayroll(api, tenant, signal, say)
              : await collectDeposit(api, tenant, signal, say);
      if (signal.aborted) return;
      setResult(r);
      onResult(r);
    });
  return (
    <li className={`ops-inbox-starter${running ? " running" : ""}`}>
      <button type="button" disabled={running} onClick={() => void start()} aria-describedby={`starter-${flow.id}-state`}>
        <span className="ops-inbox-starter-icon" aria-hidden="true">
          <Icon name={flow.icon} size={20} />
        </span>
        <span className="ops-inbox-starter-text">
          <strong>{flow.title}</strong>
          <span>{flow.lead}</span>
        </span>
        <span className="ops-inbox-starter-go" aria-hidden="true">
          {running ? <span className="ops-spinner small" /> : <Icon name="arrow" size={18} />}
        </span>
      </button>
      <div id={`starter-${flow.id}-state`} className="ops-inbox-starter-state" role="status" aria-live="polite">
        {running ? (
          <p className="ops-inbox-progress">
            <span>{demo.step}</span>
            <b>{demo.seconds}</b>
          </p>
        ) : demo.phase === "failed" ? (
          <p className="ops-inbox-starter-note failed">{demo.error}</p>
        ) : demo.phase === "done" && result ? (
          <StarterResult result={result} took={demo.took} />
        ) : (
          <span className="m3-sr">Takes {flow.time}.</span>
        )}
      </div>
    </li>
  );
}

function StarterResult({ result, took }: { result: FlowResult; took: string }) {
  if (result.kind === "note")
    return (
      <p className={`ops-inbox-starter-note ${result.tone}`}>
        <span>
          {result.text}
          {result.paypalId && (
            <>
              {" "}
              <code className="ops-inbox-id">{result.paypalId}</code>
            </>
          )}
        </span>
      </p>
    );
  const words =
    result.kind === "proposal"
      ? `${result.note ?? "Ready for your approval in the inbox."} Prepared in ${took}${result.aiCost ? ` for ${result.aiCost} of AI` : ""}.`
      : result.kind === "payLink"
        ? `Pay link ready in the inbox, made in ${took}.`
        : "Ready to pay in the inbox.";
  return (
    <p className="ops-inbox-starter-note done">
      <Icon name="check" size={16} />
      <span>{words}</span>
    </p>
  );
}
