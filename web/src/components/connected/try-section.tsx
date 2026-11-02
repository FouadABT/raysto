"use client";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { ApiFailure, type ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import { agentCost, type AgentActionRow } from "@/lib/connected/business";
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
import { AgentPanel } from "./business-sections";
import { Icon, type IconName } from "./icons";

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
  return (
    <article className="ops-try-card" aria-labelledby={`try-${n}`}>
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
    </article>
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
  done: (state: string) => void;
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

const decided = (state: string, executed: string) =>
  state === "executed"
    ? executed
    : state === "rejected"
      ? "Turned down. Nothing changed."
      : "It did not go through; run it again.";

/* 1. A photo of a printed menu becomes a draft menu. */
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
      say("Finding the menu photo");
      const media = await api.query<{ rows: Json[] }>("media", {
        restaurantId: tenant,
        limit: 100,
      });
      const photo = media.rows.find(
        (m) => m.purpose === "menuSource" && m.status === "approved",
      );
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
  const fresh = rows.filter((r) => r.change === "new").length;
  const repriced = rows.filter((r) => r.change === "price").length;
  const check = rows.filter((r) => !r.available).length;
  const sections = [...new Set(rows.map((r) => r.category))];
  return (
    <Card
      n={1}
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
                    {r.change === "new" && <em>new</em>}
                    {!r.available && <em className="warn">price to check</em>}
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

/* 2. A spoken order becomes ticket lines at the counter. */
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
      n={2}
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

/* 3. One sentence becomes a paid pickup order, approved in PayPal. */
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
  const order = () =>
    pay.run(async (signal, say) => {
      if (!basket) return;
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
      const created = await api.command<{ approvalUrl: string }>(
        "payment.checkout",
        tenant,
        {},
        { id: allocated.checkoutId, key: key("checkout") },
      );
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
  const slot = basket?.slot
    ? new Date(basket.slot).toLocaleTimeString("en-US", {
        hour: "numeric",
        minute: "2-digit",
        timeZone: cafeZone,
      })
    : undefined;
  return (
    <Card
      n={3}
      icon="chat"
      title="Order lunch in one sentence"
      time="about 20 s, then PayPal"
      lead="Ask Raysto as a diner would. It reads the menu, keeps to your budget and proposes a basket; one tap places the order and opens PayPal Sandbox. Only your approval in PayPal pays."
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
                Open PayPal Sandbox
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
              <small>Sandbox money only. Approve, then come back here: this card updates by itself.</small>
            </div>
          )}
          <Progress demo={pay} />
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
        </div>
      )}
    </Card>
  );
}

/* 4. The payments agent checks an unfinished PayPal payment. */
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
      n={4}
      icon="paypal"
      title="Chase an unfinished payment"
      time="about 15 s"
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

/* 5. The image studio draws a dish; the photo waits for approval. */
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
      n={5}
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
    <div className="ops-try">
      <section className="ops-try-intro">
        <div>
          <span className="ops-eyebrow">TRY RAYSTO · FIVE LIVE DEMOS</span>
          <h2>AI coworkers prepare. You approve. PayPal moves the money.</h2>
          <p>
            Each card runs the real product on this demo café: Gemini models, the PayPal MCP server and PayPal Sandbox
            checkout. No real money moves, and nothing changes until you approve it.
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
        <MenuCard api={api} tenant={tenant} />
        <VoiceCard api={api} tenant={tenant} />
        <OrderCard api={api} tenant={tenant} />
        <PaymentCard api={api} tenant={tenant} />
        <PhotoCard api={api} tenant={tenant} />
      </div>
    </div>
  );
}
