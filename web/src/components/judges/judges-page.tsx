"use client";
import { useEffect, useState, type ReactNode } from "react";
import { AnimatePresence, motion, useReducedMotion } from "motion/react";
import { coworkers, evidence, judge } from "@/lib/connected/judge";
import { Icon, type IconName } from "@/components/connected/icons";

const consoleUrl = "https://ops.rays.to/ops?judge=1";
const repo = "https://github.com/FouadABT/raysto";
const doc = (name: string) => `${repo}/blob/main/docs/${name}`;
const ease = [0.2, 0.8, 0.2, 1] as const;

/** The three moments of one order, shown one after another in the hero. */
const moments: { key: string; render: () => ReactNode }[] = [
  {
    key: "menu",
    render: () => (
      <div className="jg-moment">
        <span className="jg-chip lime">
          <Icon name="menu" size={16} /> Menu agent
        </span>
        <div className="jg-menu">
          <img src="/judges/menu.jpg" alt="" />
          <div>
            <strong>14 of 14 dishes read</strong>
            <span>5 sections · every price right · 18 s</span>
            <span className="warn">1 price to check: soup of the day</span>
          </div>
        </div>
        <span className="jg-wait">Waiting for the owner&rsquo;s approval</span>
      </div>
    ),
  },
  {
    key: "agent",
    render: () => (
      <div className="jg-moment">
        <span className="jg-chip">
          <Icon name="paypal" size={16} /> Payments agent · Money
        </span>
        <strong className="jg-title">Release abandoned checkout 10 · $12.00</strong>
        <p>The diner opened PayPal and never approved. Nothing was captured, so the pickup order can be paid again.</p>
        <div className="jg-evidence">
          <code>PayPal: PAYER_ACTION_REQUIRED</code>
          <code>read via PayPal MCP</code>
        </div>
        <span className="jg-button">
          <Icon name="check" size={16} /> Approve (identity check)
        </span>
      </div>
    ),
  },
  {
    key: "paid",
    render: () => (
      <div className="jg-moment">
        <span className="jg-chip ok">
          <Icon name="check" size={16} /> Paid in PayPal Sandbox
        </span>
        <strong className="jg-title">2× Garden pasta · $24.00</strong>
        <p>“Two vegetarian lunches under $25 for pickup at 12:30.” One sentence, one tap, approved in PayPal.</p>
        <div className="jg-evidence">
          <code>capture 9BY842216S6346205</code>
          <code>ticket on the kitchen board</code>
        </div>
      </div>
    ),
  },
];

function Hero() {
  const reduced = useReducedMotion();
  const [index, setIndex] = useState(0);
  const [paused, setPaused] = useState(false);
  useEffect(() => {
    if (reduced || paused) return;
    const timer = setInterval(() => {
      if (!document.hidden) setIndex((i) => (i + 1) % moments.length);
    }, 3400);
    return () => clearInterval(timer);
  }, [reduced, paused]);
  return (
    <header className="jg-hero">
      <div className="jg-hero-copy">
        <a className="jg-wordmark" href="#top" aria-label="Raysto">
          rays<span>to</span>
          <i aria-hidden="true">✳</i>
        </a>
        <span className="jg-eyebrow">PAYPAL AI HACKATHON · FOR JUDGES</span>
        <h1>
          AI coworkers run the café&rsquo;s money.
          <br />
          You approve.
          <br />
          <em>PayPal moves it.</em>
        </h1>
        <p className="jg-lead">
          Raysto is the till, kitchen board, ordering app and back office for a small restaurant. Its {coworkers.count}{" "}
          AI coworkers close the day, pay the team, bill the caterer, settle refunds, chase payments, read menus, hear
          orders and draw dishes. Each one prepares a change with its evidence, a person approves it, and PayPal&rsquo;s
          own tools move the money.
        </p>
        <div className="jg-ctas">
          <a className="jg-primary" href={consoleUrl}>
            <Icon name="play" size={20} />
            Try it now: one click, nothing to install
          </a>
          {judge.videoUrl && (
            <a className="jg-secondary" href={judge.videoUrl} target="_blank" rel="noopener noreferrer">
              Watch the {judge.videoLength || "short"} film
            </a>
          )}
        </div>
        <small className="jg-sandbox">
          <Icon name="paypal" size={16} /> PayPal Sandbox only: no real money moves.
        </small>
      </div>
      <div
        className="jg-stage"
        onMouseEnter={() => setPaused(true)}
        onMouseLeave={() => setPaused(false)}
        onFocus={() => setPaused(true)}
        onBlur={() => setPaused(false)}
        aria-label="Three recorded live runs"
        role="group"
      >
        {reduced ? (
          moments.map((m) => <div key={m.key}>{m.render()}</div>)
        ) : (
          <AnimatePresence mode="wait" initial={false}>
            <motion.div
              key={moments[index].key}
              initial={{ opacity: 0, y: 18, scale: 0.98 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -14, scale: 0.98 }}
              transition={{ duration: 0.45, ease }}
            >
              {moments[index].render()}
            </motion.div>
          </AnimatePresence>
        )}
        <span className="jg-stage-note">Recorded live runs, 1–2 November · PayPal Sandbox</span>
        {!reduced && (
          <div className="jg-dots" role="tablist" aria-label="Moments">
            {moments.map((m, i) => (
              <button
                key={m.key}
                role="tab"
                aria-selected={i === index}
                aria-label={["Menu read", "Payment checked", "Order paid"][i]}
                onClick={() => setIndex(i)}
              />
            ))}
          </div>
        )}
      </div>
    </header>
  );
}

/** Rises into view while scrolling. The page renders fully visible first, so
 * nothing stays hidden if scripts are slow or off. */
function Reveal({ children, delay = 0, className }: { children: ReactNode; delay?: number; className?: string }) {
  const reduced = useReducedMotion();
  const [running, setRunning] = useState(false);
  useEffect(() => setRunning(true), []);
  if (reduced || !running) return <div className={className}>{children}</div>;
  return (
    <motion.div
      className={className}
      initial={{ opacity: 0, y: 22 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-60px" }}
      transition={{ duration: 0.5, delay, ease }}
    >
      {children}
    </motion.div>
  );
}

const steps: { icon: IconName; title: string; text: string }[] = [
  {
    icon: "agents",
    title: "An AI coworker prepares",
    text: "It reads the menu photo, the spoken order, the ledger or PayPal itself, then drafts one change with its evidence.",
  },
  {
    icon: "check",
    title: "A person approves",
    text: "Nothing changes until the owner or manager taps Approve. Money changes ask them to confirm it is really them.",
  },
  {
    icon: "paypal",
    title: "PayPal moves the money",
    text: "Orders v2 checkout, capture once, verified webhooks, exact split bills and refunds. Sandbox for the hackathon.",
  },
];

const demos: { icon: IconName; title: string; see: string; time: string }[] = [
  { icon: "chart", title: "Close the day", see: "The close agent matches PayPal's transactions to the till and explains every gap; you sign off.", time: "20 s" },
  { icon: "team", title: "Pay the team", see: "Tips and wages from this week's shifts, one batch; PayPal Payouts sends it after your identity check.", time: "15 s + PayPal" },
  { icon: "invoice", title: "Bill the caterer", see: "A one-line request becomes a priced PayPal invoice with a QR code; you send it.", time: "20 s + PayPal" },
  { icon: "money", title: "Settle a complaint", see: "The agent checks the ticket and PayPal's capture, then proposes the refund; PayPal refunds it.", time: "20 s + PayPal" },
  { icon: "paypal", title: "Chase an unfinished payment", see: "The payments agent asks PayPal through its MCP server and drafts the fix.", time: "20 s" },
  { icon: "chat", title: "Order lunch in one sentence", see: "Raysto builds a basket within budget; one tap places it and opens PayPal Sandbox.", time: "20 s + PayPal" },
  { icon: "menu", title: "Read a printed menu", see: "14 dishes and prices come off a photo; the new ones wait for you.", time: "20 s" },
  { icon: "mic", title: "Take an order by voice", see: "A spoken counter order becomes ticket lines. Try your own voice.", time: "5 s" },
  { icon: "image", title: "Draw a dish for the menu", see: "Gemini draws a photo; it is scanned and labelled as an AI image.", time: "45 s" },
];

function Copy({ value }: { value: string }) {
  const [done, setDone] = useState(false);
  return (
    <button
      className="jg-copy"
      onClick={() => {
        void navigator.clipboard?.writeText(value).then(() => {
          setDone(true);
          setTimeout(() => setDone(false), 1600);
        });
      }}
      aria-label={`Copy ${value}`}
    >
      {done ? "Copied" : "Copy"}
    </button>
  );
}

function Login({ label, email, password, note }: { label: string; email: string; password: string; note: string }) {
  if (!email) return null;
  return (
    <div className="jg-login">
      <span className="jg-eyebrow">{label}</span>
      <dl>
        <dt>Email</dt>
        <dd>
          <code>{email}</code>
          <Copy value={email} />
        </dd>
        <dt>Password</dt>
        <dd>
          <code>{password}</code>
          <Copy value={password} />
        </dd>
      </dl>
      <small>{note}</small>
    </div>
  );
}

export function JudgesPage() {
  return (
    <div className="jg-root" id="top">
      <Hero />
      <main>
        <section className="jg-section" aria-labelledby="how">
          <Reveal>
            <span className="jg-eyebrow">HOW IT WORKS</span>
            <h2 id="how">One rule, everywhere in the product.</h2>
          </Reveal>
          <ol className="jg-steps">
            {steps.map((s, i) => (
              <Reveal key={s.title} delay={i * 0.08} className="jg-step">
                <span className="jg-step-icon">
                  <Icon name={s.icon} size={22} />
                </span>
                <strong>
                  <b>{i + 1}</b> {s.title}
                </strong>
                <p>{s.text}</p>
              </Reveal>
            ))}
          </ol>
        </section>

        <section className="jg-section" aria-labelledby="try">
          <Reveal>
            <span className="jg-eyebrow">TRY IT IN TWO MINUTES</span>
            <h2 id="try">Nine live demos, money first. One click signs you in.</h2>
            <p className="jg-section-lead">
              The button opens the owner console already signed in as the manager of a demo café. Each demo runs the real
              product: Gemini, the PayPal MCP server, PayPal Payouts, Invoicing, Refunds and Sandbox checkout.
            </p>
          </Reveal>
          <div className="jg-demos">
            {demos.map((d, i) => (
              <Reveal key={d.title} delay={i * 0.05}>
                <a className="jg-demo" href={consoleUrl}>
                  <span className="jg-demo-n">
                    <Icon name={d.icon} size={20} />
                  </span>
                  <span className="jg-demo-text">
                    <strong>
                      {i + 1}. {d.title}
                    </strong>
                    <span>{d.see}</span>
                  </span>
                  <span className="jg-demo-time">
                    <Icon name="clock" size={14} /> {d.time}
                  </span>
                </a>
              </Reveal>
            ))}
          </div>
          <a className="jg-primary center" href={consoleUrl}>
            <Icon name="play" size={20} />
            Open the {coworkers.demos === 9 ? "nine" : String(coworkers.demos)} demos
          </a>
        </section>

        <section className="jg-section" aria-labelledby="logins">
          <Reveal>
            <span className="jg-eyebrow">LOGINS</span>
            <h2 id="logins">Everything is Sandbox, so the logins are public.</h2>
          </Reveal>
          <div className="jg-logins">
            <Login
              label="Owner console · manager of the demo café"
              email={judge.email}
              password={judge.password}
              note="The button above signs in with this for you. ops.rays.to/ops"
            />
            <Login
              label="Android app · a diner"
              email={judge.dinerEmail}
              password={judge.dinerPassword}
              note="Order from the demo café with Ask Raysto and pay in PayPal Sandbox."
            />
            <div className="jg-login">
              <span className="jg-eyebrow">PayPal Sandbox buyer</span>
              <p>
                PayPal&rsquo;s own Sandbox page asks for a buyer login when you approve a payment. It is in the Devpost
                testing instructions.
              </p>
              <small>The demo café resets every day at 09:00 UTC, so you always start from the same menu.</small>
            </div>
          </div>
        </section>

        <section className="jg-section" aria-labelledby="evidence">
          <Reveal>
            <span className="jg-eyebrow">EVIDENCE</span>
            <h2 id="evidence">Checked live, not just on a slide.</h2>
          </Reveal>
          <div className="jg-evidence-grid">
            <a href={doc("ai-evaluation-results.md")} className="jg-fact">
              <strong>12 / 12</strong>
              <span>live AI evaluation cases: 3 menus, 5 spoken orders, 4 takeaway requests</span>
            </a>
            <a href={doc("paypal-acceptance-2026-10-31.md")} className="jg-fact">
              <strong>{evidence.captures}</strong>
              <span>
                PayPal Sandbox captures recorded, plus {evidence.refunds} refunds and {evidence.payoutBatches} Payouts
                batches, each with its PayPal id
              </span>
            </a>
            <a href={`${repo}#evidence`} className="jg-fact">
              <strong>{evidence.backendUnit + evidence.backendIntegration}</strong>
              <span>
                backend tests ({evidence.backendIntegration} integration on an isolated database, {evidence.backendUnit} unit)
              </span>
            </a>
            <a href={`${repo}#how-paypal-is-used`} className="jg-fact">
              <strong>MCP</strong>
              <span>the payments agent reads PayPal through PayPal&rsquo;s own MCP server</span>
            </a>
          </div>
        </section>

        <section className="jg-section jg-app" aria-labelledby="app">
          <Reveal>
            <span className="jg-eyebrow">THE APP</span>
            <h2 id="app">The staff tablet and the diner app, on Android.</h2>
            <p className="jg-section-lead">
              The console is enough to judge Raysto. The Android app adds the counter till with voice ordering, the
              kitchen board and the diner&rsquo;s side.
            </p>
          </Reveal>
          {judge.apkUrl ? (
            <div className="jg-download">
              <a className="jg-secondary" href={judge.apkUrl}>
                Download the Android app (APK{judge.apkVersion ? `, ${judge.apkVersion}` : ""})
              </a>
              <ol>
                <li>Open the file on an Android phone or tablet (Android 7 or later, 64-bit) and allow the install.</li>
                <li>
                  Choose <strong>Use my Raysto account</strong>, then <strong>Sign in as a diner</strong> or{" "}
                  <strong>Sign in as the café manager</strong>.
                </li>
              </ol>
              {judge.apkSha256 && (
                <p className="jg-sha">
                  SHA-256 <code>{judge.apkSha256}</code>
                </p>
              )}
            </div>
          ) : (
            <a className="jg-secondary" href={`${repo}/releases`}>
              Releases on GitHub
            </a>
          )}
        </section>
      </main>
      <footer className="jg-footer">
        <span>
          Built during the PayPal AI Hackathon: started {evidence.startedOn}, first commit {evidence.firstCommit} · MIT
          licence ·{" "}
          <a href={repo}>Source on GitHub</a>
        </span>
        <span>PayPal Sandbox only. No real payments, no real restaurant.</span>
      </footer>
    </div>
  );
}
