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
function Reveal({
  children,
  delay = 0,
  className,
}: {
  children: ReactNode;
  delay?: number;
  className?: string;
}) {
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

/** A responsive diagram, not a recording or provider execution result. */
function Diagram() {
  return (
    <figure className="jg-diagram jg-decision-map">
      <figcaption>
        <span className="jg-eyebrow">THE DECISION THREAD</span>
        <strong>
          From a cost change
          <br />
          <em>to a considered choice.</em>
        </strong>
      </figcaption>
      <ol>
        {[
          [
            "receipt",
            "01",
            "Read the evidence",
            "Confirm the supplier cost and recipe units.",
          ],
          [
            "chart",
            "02",
            "Challenge the options",
            "Inspect contribution and explicit volume assumptions.",
          ],
          [
            "check",
            "03",
            "Review the action",
            "Keep, defer or approve a separate price proposal.",
          ],
          [
            "paypal",
            "04",
            "Inspect the outcome",
            "Follow order, collection and supplier-payment records.",
          ],
        ].map(([icon, n, title, text]) => (
          <li key={n}>
            <span className="jg-map-node">
              <Icon name={icon as IconName} size={24} />
            </span>
            <div>
              <small>{n}</small>
              <h3>{title}</h3>
              <p>{text}</p>
            </div>
          </li>
        ))}
      </ol>
      <p className="jg-map-caption">
        Workflow diagram · sample café data and PayPal Sandbox are labeled in
        the workspace.
      </p>
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
    text: "Review pricing proposals and money actions separately. Existing automation policies remain visible in the workspace.",
  },
  {
    icon: "paypal",
    title: "PayPal moves the money",
    text: "Supported checkout, refunds and Payouts use PayPal Sandbox. Inspect the actual provider outcome and its financial records.",
  },
];

const flows: { icon: IconName; title: string; text: string; paypal: string }[] =
  [
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
  {
    icon: "orders",
    title: "Ordering and split bills",
    text: "Guests order in one sentence and each pays their own share.",
  },
  {
    icon: "kitchen",
    title: "Counter and kitchen",
    text: "Voice orders at the till and a live kitchen board.",
  },
  {
    icon: "ledger",
    title: "Books and VAT",
    text: "Recorded journal, cash movements and payables, with accounting-basis limitations visible.",
  },
  {
    icon: "supplies",
    title: "Supplies",
    text: "Stock-out forecasts, purchase orders and a three-way match.",
  },
  {
    icon: "dispatch",
    title: "Delivery",
    text: "Drivers, a live map and an API for delivery partners.",
  },
  {
    icon: "group",
    title: "Several venues",
    text: "One owner, many cafés, compared side by side.",
  },
  {
    icon: "chart",
    title: "Analytics",
    text: "Dashboards and pivots on AG Grid and AG Studio.",
  },
  {
    icon: "paypal",
    title: "Your own PayPal",
    text: "Account configuration and supported Sandbox payment evidence. Live merchant acceptance remains a release gate.",
  },
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
          <span className="jg-eyebrow">
            For restaurants, cafés and snack bars
          </span>
          <h1>
            The AI operating system
            <br />
            <em>for restaurants.</em>
          </h1>
          <p className="jg-lead">
            Connect supplier costs, recipes and payments. AI explains the
            evidence; you challenge the assumptions, review a decision and
            return to its recorded outcome.
          </p>
          <div className="jg-ctas">
            <a
              className="jg-primary"
              href={`${demoUrl}&section=finance&tab=investigate&guided=1`}
            >
              <Icon name="play" size={20} />
              Follow a cost investigation
            </a>
            {/* The film button returns with the new film (planned 9–10 November). */}
            <a className="jg-secondary" href={demoUrl}>
              Explore the workspace
            </a>
          </div>
          <small className="jg-sandbox">
            Opens a demo café, already signed in. Nothing to install.
          </small>
        </div>
        <Diagram />
      </header>

      <main>
        <section className="jg-section" aria-labelledby="how">
          <Reveal>
            <span className="jg-eyebrow">How it works</span>
            <h2 id="how">Evidence, review and a traceable outcome.</h2>
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
            <h2 id="does">Connected work, with the evidence close by.</h2>
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
                  Download for Android
                  {judge.apkVersion ? ` · ${judge.apkVersion}` : ""}
                </a>
                <p className="jg-sandbox">
                  Android preview · development signed. Physical review of this
                  build is pending.
                </p>
                <ol>
                  <li>
                    Open the file on an Android phone and allow the install.
                  </li>
                  <li>
                    Tap <strong>Use my Raysto account</strong>, then{" "}
                    <strong>Sign in as a diner</strong> or{" "}
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
                <QRCodeSVG
                  value={judge.apkUrl}
                  size={132}
                  level="M"
                  marginSize={2}
                />
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
          Built for the PayPal AI Hackathon · MIT licence ·{" "}
          <a href={repo}>Source on GitHub</a>
        </span>
        <span>
          The demo café uses sample data and PayPal Sandbox, so no real money
          moves. It starts fresh every day at 09:00 UTC.
        </span>
      </footer>
    </div>
  );
}
