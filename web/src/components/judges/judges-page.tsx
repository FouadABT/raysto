"use client";
/**
 * rays.to: Raysto's product page. One idea (AI prepares, you approve, PayPal
 * moves the money), four things it does for a café, everything else it
 * runs on, and one button into the live demo café. Hackathon notes live in
 * the footer and on Devpost, not in the way of the product.
 */
import { useEffect, useRef, useState, type ReactNode } from "react";
import { motion, useReducedMotion } from "motion/react";
import { QRCodeSVG } from "qrcode.react";
import { judge } from "@/lib/connected/judge";
import { Icon, type IconName } from "@/components/connected/icons";

const demoUrl = "https://ops.rays.to/ops?judge=1";
const repo = "https://github.com/FouadABT/raysto";
const ease = [0.2, 0.8, 0.2, 1] as const;

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

/** The animated diagram of the rule. Still for anyone who asks for less motion. */
function Diagram() {
  const reduced = useReducedMotion();
  const video = useRef<HTMLVideoElement>(null);
  useEffect(() => {
    const v = video.current;
    if (!v) return;
    if (reduced) v.pause();
    else void v.play().catch(() => {});
  }, [reduced]);
  return (
    <figure className="jg-diagram">
      <video
        ref={video}
        src="/judges/brain.mp4"
        poster="/judges/brain.jpg"
        muted
        loop
        playsInline
        autoPlay={!reduced}
        preload="metadata"
        aria-label="Animated diagram: the café's AI coworkers prepare a bill, a delivery payout and a supplier order; the owner approves with an identity check; PayPal pays the internet provider, the driver and the supplier."
      />
    </figure>
  );
}

const steps: { icon: IconName; title: string; text: string }[] = [
  {
    icon: "agents",
    title: "AI prepares",
    text: "An AI coworker reads the bill, the order, the shifts or PayPal itself, and drafts one change with its evidence.",
  },
  {
    icon: "check",
    title: "You approve",
    text: "Nothing moves until the owner or manager taps Approve. Money asks them to confirm it is really them.",
  },
  {
    icon: "paypal",
    title: "PayPal moves the money",
    text: "Checkout, refunds, Payouts and invoices run through PayPal, and the books update by themselves.",
  },
];

const flows: { icon: IconName; title: string; text: string; paypal: string }[] = [
  {
    icon: "receipt",
    title: "Pays your bills",
    text: "Snap a bill. The AI accountant reads the vendor, amount and due date, checks it was not paid before, and pays it once you approve.",
    paypal: "PayPal Payouts",
  },
  {
    icon: "chat",
    title: "Settles complaints",
    text: "A guest says a dish was missing. The agent checks the order and the payment, then proposes a fair partial refund.",
    paypal: "PayPal refunds",
  },
  {
    icon: "team",
    title: "Pays your team",
    text: "Tips and wages from the week's shifts, worked out and sent in one batch after your identity check.",
    paypal: "PayPal Payouts",
  },
  {
    icon: "qr",
    title: "Gets you paid",
    text: "A link and a QR code for a deposit or an unpaid order. The customer pays with PayPal and it is marked paid.",
    paypal: "PayPal checkout",
  },
];

const runsOn: { icon: IconName; title: string; text: string }[] = [
  { icon: "orders", title: "Ordering and split bills", text: "Guests order in one sentence and each pays their own share." },
  { icon: "kitchen", title: "Counter and kitchen", text: "Voice orders at the till and a live kitchen board." },
  { icon: "ledger", title: "Books and VAT", text: "Double-entry books, profit and loss, cash flow, payables." },
  { icon: "supplies", title: "Supplies", text: "Stock-out forecasts, purchase orders and a three-way match." },
  { icon: "dispatch", title: "Delivery", text: "Drivers, a live map and an API for delivery partners." },
  { icon: "group", title: "Several venues", text: "One owner, many cafés, compared side by side." },
  { icon: "chart", title: "Analytics", text: "Dashboards and pivots on AG Grid and AG Studio." },
  { icon: "paypal", title: "Your own PayPal", text: "Each restaurant connects its own PayPal account." },
];

const builtWith = [
  "PayPal Orders v2",
  "PayPal Payouts",
  "PayPal refunds",
  "PayPal MCP server",
  "Google Gemini",
  "AG Grid · AG Studio",
  "Flutter",
  "Next.js",
  "Serverpod",
  "PostgreSQL on AWS",
];

export function JudgesPage() {
  return (
    <div className="jg-root" id="top">
      <header className="jg-hero">
        <div className="jg-hero-copy">
          <a className="jg-wordmark" href="#top" aria-label="Raysto">
            rays<span>to</span>
            <i aria-hidden="true">✳</i>
          </a>
          <span className="jg-eyebrow">For restaurants, cafés and snack bars</span>
          <h1>
            The AI operating system
            <br />
            <em>for restaurants.</em>
          </h1>
          <p className="jg-lead">
            AI coworkers prepare the work, you approve it, and PayPal moves the money. Bills paid, refunds settled, the
            team paid and every sale in the books, without a back office.
          </p>
          <div className="jg-ctas">
            <a className="jg-primary" href={demoUrl}>
              <Icon name="play" size={20} />
              Enter the live demo
            </a>
            {/* The film button returns with the new film (planned 9–10 November). */}
            <a className="jg-secondary" href="#does">
              See what it does
            </a>
          </div>
          <small className="jg-sandbox">Opens a demo café, already signed in. Nothing to install.</small>
        </div>
        <Diagram />
      </header>

      <main>
        <section className="jg-section" aria-labelledby="how">
          <Reveal>
            <span className="jg-eyebrow">How it works</span>
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

        <section className="jg-section" aria-labelledby="does">
          <Reveal>
            <span className="jg-eyebrow">What it does for you</span>
            <h2 id="does">The money work, done before you ask.</h2>
          </Reveal>
          <div className="jg-flows">
            {flows.map((f, i) => (
              <Reveal key={f.title} delay={i * 0.06}>
                <a className="jg-flow" href={demoUrl}>
                  <span className="jg-flow-icon">
                    <Icon name={f.icon} size={22} />
                  </span>
                  <strong>{f.title}</strong>
                  <p>{f.text}</p>
                  <span className="jg-flow-paypal">
                    <Icon name="paypal" size={14} /> {f.paypal}
                  </span>
                </a>
              </Reveal>
            ))}
          </div>
          <a className="jg-primary center" href={demoUrl}>
            <Icon name="play" size={20} />
            Try it in the demo café
          </a>
        </section>

        <section className="jg-section" aria-labelledby="runs">
          <Reveal>
            <span className="jg-eyebrow">Everything the café runs on</span>
            <h2 id="runs">One system from the first order to the books.</h2>
          </Reveal>
          <div className="jg-features">
            {runsOn.map((f, i) => (
              <Reveal key={f.title} delay={i * 0.04} className="jg-feature">
                <Icon name={f.icon} size={20} />
                <span>
                  <strong>{f.title}</strong>
                  {f.text}
                </span>
              </Reveal>
            ))}
          </div>
        </section>

        {judge.apkUrl && (
          <section className="jg-section jg-app" aria-labelledby="app">
            <Reveal>
              <span className="jg-eyebrow">On your phone</span>
              <h2 id="app">The guest app and the staff app, on Android.</h2>
            </Reveal>
            <div className="jg-phone">
              <div className="jg-download">
                <a className="jg-secondary" href={judge.apkUrl}>
                  <Icon name="download" size={18} />
                  Download for Android{judge.apkVersion ? ` · ${judge.apkVersion}` : ""}
                </a>
                <ol>
                  <li>Open the file on an Android phone and allow the install.</li>
                  <li>
                    Tap <strong>Use my Raysto account</strong>, then <strong>Sign in as a diner</strong> or{" "}
                    <strong>Sign in as the café manager</strong>. No typing.
                  </li>
                </ol>
                {judge.apkSha256 && (
                  <p className="jg-sha">
                    SHA-256 <code>{judge.apkSha256}</code>
                  </p>
                )}
              </div>
              <div className="jg-qr" aria-hidden="true">
                <QRCodeSVG value={judge.apkUrl} size={132} level="M" marginSize={2} />
                <span>Scan with your phone</span>
              </div>
            </div>
          </section>
        )}

        <section className="jg-section" aria-labelledby="built">
          <Reveal>
            <span className="jg-eyebrow">Built with</span>
            <h2 id="built">PayPal for the money, Gemini for the thinking.</h2>
          </Reveal>
          <ul className="jg-built">
            {builtWith.map((b) => (
              <li key={b}>{b}</li>
            ))}
          </ul>
        </section>
      </main>
      <footer className="jg-footer">
        <span>
          Built for the PayPal AI Hackathon · MIT licence · <a href={repo}>Source on GitHub</a>
        </span>
        <span>
          The demo café uses sample data and PayPal Sandbox, so no real money moves. It starts fresh every day at 09:00
          UTC.
        </span>
      </footer>
    </div>
  );
}
