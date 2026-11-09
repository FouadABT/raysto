import Image from "next/image";
import { MotionReplay, MotionShell, MotionSwitch } from "./motion-shell";
import {
  AIReviewPreview,
  FloorPreview,
  GuestPhone,
  KitchenPreview,
  MenuPreview,
  MobileNavigation,
  RolePreview,
} from "./interactions";
import { Symbol } from "./symbol";
import { faqs, previewLabel } from "./fixtures";
import "./landing.css";
import { ScrollStory } from "./scroll-story";

const photo = "/images/landing/cafe-service.webp";
function Arrow() {
  return <Symbol name="north_east" />;
}
function BookDemo({ secondary = false }: { secondary?: boolean }) {
  return (
    <a
      className={`lp-button ${secondary ? "lp-button-outline" : ""}`}
      href="/contact"
    >
      Book a demo <Arrow />
    </a>
  );
}
function Label() {
  return <p className="lp-preview-label">{previewLabel}</p>;
}
function Wordmark() {
  return (
    <a href="/" className="lp-wordmark" aria-label="Raysto home">
      raysto<span aria-hidden="true">✳</span>
    </a>
  );
}

function HeroDashboard() {
  return (
    <div className="lp-dashboard" aria-label="Illustrative restaurant overview">
      <aside>
        <strong>raysto</strong>
        <span className="selected">
          <Symbol name="home" />
          Home
        </span>
        <span>
          <Symbol name="receipt_long" />
          Orders
        </span>
        <span>
          <Symbol name="table_restaurant" />
          Tables
        </span>
        <span>
          <Symbol name="account_balance_wallet" />
          Money
        </span>
        <span>
          <Symbol name="auto_awesome" />
          AI
        </span>
      </aside>
      <div className="lp-dashboard-main">
        <div className="lp-dashboard-top">
          <strong>Atelier Café</strong>
          <Symbol name="expand_more" />
          <span>WORKSPACE</span>
        </div>
        <h3>Overview</h3>
        <div className="lp-dashboard-stats">
          <div>
            <Symbol name="shopping_bag" />
            <span>
              Orders<strong>48</strong>
              <small className="lp-pill lime">6 active</small>
            </span>
          </div>
          <div>
            <Symbol name="table_restaurant" />
            <span>
              Tables<strong>8 / 12</strong>
              <small>Service in view</small>
            </span>
          </div>
        </div>
        <div className="lp-dashboard-detail">
          <div className="lp-floor lp-floor-hero" aria-hidden="true">
            <div className="lp-tables">
              {[1, 2, 3, 4, 5, 6].map((number) => (
                <span
                  key={number}
                  className={
                    number === 4
                      ? "lp-table-sample selected"
                      : "lp-table-sample"
                  }
                >
                  {String(number).padStart(2, "0")}
                </span>
              ))}
            </div>
          </div>
          <div className="lp-dashboard-updates">
            <div>
              <Symbol name="room_service" />
              <span>
                <strong>Table 04</strong>Bill requested
              </span>
            </div>
            <div data-hero-ai>
              <Symbol name="auto_awesome" />
              <span>
                <strong>AI proposal</strong>Needs your review
              </span>
            </div>
            <div data-hero-paypal>
              <Symbol name="account_balance_wallet" />
              <span>
                <strong>PayPal checkout</strong>Customer approval
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function CafeDrawing() {
  return (
    <svg
      data-cafe-drawing
      className="lp-cafe-drawing"
      viewBox="0 0 450 240"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.3"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {[
        "M29 130C29 104 250 104 250 130S29 157 29 130Z",
        "M140 157L114 225M145 157L170 225M97 225H184",
        "M265 222L287 157M362 225L345 161M262 158C282 142 351 141 368 158C379 175 255 177 262 158Z",
        "M285 149C282 124 279 52 306 37C334 18 371 31 376 60C383 89 369 131 363 152",
        "M300 148C298 124 297 58 321 43C345 30 363 47 363 65C364 90 350 123 349 146",
        "M124 125L121 97H148L145 125C140 132 128 131 124 125ZM135 97L133 61M134 79L116 62M135 71L151 54",
        "M132 61C109 65 108 45 114 43C125 42 133 54 132 61ZM135 77C157 80 165 61 157 59C145 59 139 68 135 77ZM134 61C148 62 159 43 152 41C142 39 136 53 134 61",
      ].map((d, index) => (
        <path key={index} d={d} pathLength="1" strokeDasharray="1" />
      ))}
    </svg>
  );
}

/** Server-composed copy and DOM scenes; only controls/choreography hydrate. */
export function LandingPage() {
  return (
    <MotionShell>
      <a className="lp-skip" href="#main">
        Skip to content
      </a>
      <header className="lp-header">
        <div className="lp-container lp-header-inner">
          <Wordmark />
          <nav className="lp-desktop-nav" aria-label="Main navigation">
            <a href="#platform">Platform</a>
            <a href="#how-it-works">How it works</a>
            <a href="#payments">PayPal</a>
            <a href="#ai">AI</a>
            <a href="#faq">FAQ</a>
          </nav>
          <div className="lp-header-actions">
            <a href="/ops" className="lp-signin">
              Sign in
            </a>
            <BookDemo />
          </div>
          <MobileNavigation />
        </div>
      </header>
      <main id="main" tabIndex={-1}>
        <section className="lp-hero lp-container" aria-labelledby="hero-title">
          <div className="lp-hero-copy">
            <p className="lp-eyebrow">THE RESTAURANT WORKSPACE</p>
            <h1 id="hero-title">
              <span data-hero-line>Every order.</span>
              <span data-hero-line>Every table.</span>
              <span data-hero-line>
                <em>One clear view.</em>
              </span>
            </h1>
            <p className="lp-intro">
              Bring orders, service, AI assistance and PayPal payments together
              in one workspace for your restaurant.
            </p>
            <div className="lp-integration-tags">
              <span>
                <Symbol name="auto_awesome" />
                AI prepares
              </span>
              <span>
                <Symbol name="account_balance_wallet" />
                PayPal payments
              </span>
              <span>You approve</span>
            </div>
            <div className="lp-actions">
              <BookDemo />
              <a
                className="lp-button lp-button-outline"
                href="#connected-story"
              >
                Follow the AI + PayPal story
              </a>
            </div>
            <a className="lp-guest-link" href="/discover">
              Here to order? <strong>Explore restaurants</strong> <Arrow />
            </a>
            <MotionReplay scene="hero" label="Replay introduction" />
          </div>
          <div className="lp-hero-scene">
            <div className="lp-hero-photo" data-hero-photo>
              <Image
                src={photo}
                alt="Illustrative café scene with a toasted sandwich, cappuccino and a server using a tablet"
                fill
                sizes="(max-width: 839px) 100vw, 55vw"
                loading="eager"
                fetchPriority="high"
              />
            </div>
            <div data-hero-dashboard className="lp-hero-dashboard">
              <HeroDashboard />
            </div>
            <div data-hero-phone className="lp-hero-phone">
              <GuestPhone />
            </div>
            <Label />
          </div>
        </section>
        <div className="lp-container">
          <div className="lp-audience">
            <span>
              Restaurants <i>/</i> Cafés <i>/</i> Quick service
            </span>
            <span>
              Dine-in <i>·</i> Pickup <i>·</i> Delivery
            </span>
          </div>
        </div>

        <ScrollStory />

        <section
          id="how-it-works"
          className="lp-section lp-container lp-journey"
          tabIndex={-1}
          aria-labelledby="journey-title"
        >
          <div className="lp-section-heading" data-reveal>
            <span className="lp-eyebrow">
              AI ASSISTANCE. PAYPAL CHECKOUT. CONNECTED SERVICE.
            </span>
            <h2 id="journey-title">
              One order, connected
              <br className="lp-wide-break" /> from start to finish.
            </h2>
          </div>
          <div className="lp-journey-grid" data-journey>
            {[
              {
                title: "Choose",
                subtitle: "Guest menu",
                icon: "shopping_bag",
                content: (
                  <>
                    <span className="lp-food-thumb">
                      <img
                        src={photo}
                        alt=""
                        width="54"
                        height="54"
                        loading="lazy"
                      />
                    </span>
                    <span>
                      <strong>Croque monsieur</strong>
                      <small>€7.50</small>
                    </span>
                  </>
                ),
              },
              {
                title: "Pay",
                subtitle: "PayPal checkout",
                icon: "account_balance_wallet",
                content: (
                  <>
                    <span className="lp-paypal" aria-hidden="true">
                      P
                    </span>
                    <span>
                      <strong>PayPal checkout</strong>
                      <small>Checkout preview</small>
                    </span>
                    <Symbol name="arrow_forward" />
                  </>
                ),
              },
              {
                title: "Prepare",
                subtitle: "Kitchen queue",
                icon: "skillet",
                content: (
                  <>
                    <span>
                      <strong>Order #24</strong>
                      <small>Croque monsieur</small>
                    </span>
                    <span className="lp-pill lime">Preparing</span>
                  </>
                ),
              },
              {
                title: "Serve",
                subtitle: "Service updates",
                icon: "room_service",
                content: (
                  <>
                    <span>
                      <strong>Table 04</strong>
                      <small>Order ready</small>
                    </span>
                    <span className="lp-stage-check">
                      <Symbol name="check" />
                    </span>
                  </>
                ),
              },
            ].map((stage, index) => (
              <div
                className="lp-journey-stage"
                data-journey-stage
                key={stage.title}
              >
                <span className="lp-stage-connector" aria-hidden="true" />
                <div className="lp-stage-heading">
                  <span className="lp-stage-number">
                    <Symbol name={stage.icon} />
                  </span>
                  <span>
                    <h3>{stage.title}</h3>
                    <p>{stage.subtitle}</p>
                  </span>
                  <small>0{index + 1}</small>
                </div>
                <div className="lp-stage-preview">{stage.content}</div>
              </div>
            ))}
          </div>
          <Label />
          <MotionReplay scene="journey" label="Replay order journey" />
        </section>

        <section
          id="platform"
          className="lp-section lp-platform"
          tabIndex={-1}
          aria-labelledby="platform-title"
        >
          <div className="lp-container">
            <div className="lp-section-heading" data-reveal>
              <span className="lp-eyebrow">THE WHOLE SERVICE, CONNECTED</span>
              <h2 id="platform-title">Keep the whole service in view.</h2>
              <p>From the first booking to the last plate.</p>
            </div>
            <div className="lp-operations-grid" data-reveal>
              <article>
                <div className="lp-product-panel">
                  <h3>
                    <Symbol name="table_restaurant" />
                    Tables &amp; reservations{" "}
                    <span className="lp-quiet-tag">
                      Terrace <Symbol name="expand_more" />
                    </span>
                  </h3>
                  <FloorPreview />
                </div>
                <p>See the floor and plan the next arrival.</p>
              </article>
              <article>
                <div className="lp-product-panel">
                  <h3>
                    <Symbol name="skillet" />
                    Orders &amp; kitchen
                  </h3>
                  <KitchenPreview />
                </div>
                <p>Know what&apos;s new, preparing and ready.</p>
              </article>
              <article>
                <div className="lp-product-panel">
                  <h3>
                    <Symbol name="stacks" />
                    Menu &amp; stock
                  </h3>
                  <MenuPreview />
                </div>
                <p>Manage dishes, availability and supplies.</p>
              </article>
            </div>
            <Label />
          </div>
        </section>

        <section
          id="payments"
          tabIndex={-1}
          className="lp-section lp-money"
          aria-labelledby="money-title"
        >
          <div className="lp-container lp-money-grid">
            <div data-reveal>
              <span className="lp-eyebrow">
                PAYPAL PAYMENTS · FINANCIAL EVIDENCE
              </span>
              <h2 id="money-title">
                Know what came in.
                <br />
                See what&apos;s still due.
              </h2>
              <p>
                Follow supported PayPal collections, refunds and payouts
                alongside supplier bills and receivables. AI helps explain the
                evidence; you review the financial action.
              </p>
              <p className="lp-payment-qualification">
                Connected demos use PayPal Sandbox. These product scenes are
                illustrative. Customer checkout and supplier payouts have
                separate approvals.
              </p>
              <ul className="lp-money-categories">
                <li>PayPal payments</li>
                <li>Bills</li>
                <li>Receivables</li>
                <li>Reports</li>
              </ul>
            </div>
            <div className="lp-money-preview" data-money>
              <h3>
                <Symbol name="account_balance_wallet" />
                Money<span className="lp-quiet-tag">Atelier Café</span>
              </h3>
              <div className="lp-money-metrics">
                <div data-money-row>
                  <Symbol name="description" />
                  <span>
                    Bills outstanding<strong>€238.10</strong>
                  </span>
                </div>
                <div data-money-row>
                  <Symbol name="arrow_forward" />
                  <span>
                    Receivables<strong>€120.00</strong>
                  </span>
                </div>
              </div>
              <div className="lp-paid-row" data-money-row>
                <Symbol name="receipt_long" />
                <strong>Order #7</strong>
                <span>€26.50</span>
                <span className="lp-pill lime">Paid</span>
              </div>
              <p className="lp-preview-label">
                {previewLabel} · PayPal payment example. Separate categories,
                not an account balance.
              </p>
            </div>
          </div>
        </section>

        <section
          id="ai"
          className="lp-section lp-container lp-ai"
          tabIndex={-1}
          aria-labelledby="ai-title"
        >
          <div>
            <AIReviewPreview />
            <Label />
            <MotionReplay scene="ai" label="Replay AI workflow" />
          </div>
          <div className="lp-ai-copy" data-reveal>
            <span className="lp-eyebrow">
              AI ASSISTANCE, CONNECTED TO MONEY ACTIONS
            </span>
            <h2 id="ai-title">
              Let AI prepare.
              <br />
              <em>You decide.</em>
            </h2>
            <p>
              Ask AI to read a supplier document, investigate a cost change or
              prepare a pricing scenario.
            </p>
            <p>
              AI prepares proposals. You approve financial actions. PayPal
              executes supported payments.
            </p>
            <details className="lp-ai-details">
              <summary>
                Explore AI assistance <Arrow />
              </summary>
              <p>
                AI can help interpret a document or prepare an explanation. The
                evidence stays available, uncertainty stays visible, and
                financial changes require the appropriate review. A PayPal
                payment or payout is a separate, authorized action. This scene
                is an illustrative product preview.
              </p>
              <a className="lp-link" href="/ops">
                Explore the workspace <Arrow />
              </a>
            </details>
          </div>
        </section>

        <section
          className="lp-section lp-roles lp-container"
          aria-labelledby="roles-title"
        >
          <div className="lp-section-heading" data-reveal>
            <span className="lp-eyebrow">
              A SHARED WORKSPACE. A USEFUL VIEW.
            </span>
            <h2 id="roles-title">
              One restaurant.
              <br className="lp-wide-break" /> The right view for everyone.
            </h2>
          </div>
          <RolePreview />
          <div className="lp-guest-feature" data-reveal>
            <div className="lp-service-photo">
              <Image
                src={photo}
                alt="Illustrative café service scene with a team member reviewing a tablet"
                fill
                sizes="(max-width: 839px) 100vw, 52vw"
              />
              <small>Illustrative café scene · AI-generated</small>
            </div>
            <div className="lp-guest-feature-copy">
              <div className="lp-guest-phone">
                <GuestPhone salad />
              </div>
              <div>
                <span className="lp-eyebrow">HOSPITALITY, ON BOTH SIDES</span>
                <h3>Made for the guest, too.</h3>
                <p>
                  Browse with AI assistance, review your order and use supported
                  PayPal checkout.
                </p>
                <a className="lp-link" href="/discover">
                  See the guest experience <Arrow />
                </a>
                <small className="lp-preview-label">
                  Guest discovery opens the existing interactive demo.
                </small>
              </div>
            </div>
          </div>
          <Label />
        </section>

        <section
          id="faq"
          className="lp-section lp-faq lp-container"
          tabIndex={-1}
          aria-labelledby="faq-title"
        >
          <div data-reveal>
            <span className="lp-eyebrow">A LITTLE MORE CLARITY</span>
            <h2 id="faq-title">
              A few things you
              <br className="lp-wide-break" /> may be wondering.
            </h2>
          </div>
          <div className="lp-faq-list">
            {faqs.map(([question, answer], index) => (
              <details key={question} open={index === 0}>
                <summary>
                  {question}
                  <Symbol name="add" />
                </summary>
                <div>
                  <p>{answer}</p>
                </div>
              </details>
            ))}
          </div>
        </section>

        <section className="lp-final">
          <div className="lp-container lp-final-grid">
            <div>
              <span className="lp-eyebrow">YOUR NEXT GREAT SERVICE</span>
              <h2>Bring your restaurant together.</h2>
              <p>
                See how AI assistance and PayPal payments connect to a clearer
                service.
              </p>
              <BookDemo />
            </div>
            <CafeDrawing />
          </div>
        </section>
      </main>
      <footer className="lp-footer">
        <div className="lp-container">
          <div className="lp-footer-main">
            <Wordmark />
            <span className="lp-domain">rays.to</span>
            <nav aria-label="Footer navigation">
              <a href="#platform">Platform</a>
              <a href="#payments">PayPal payments</a>
              <a href="#ai">AI</a>
              <a href="/discover">Guest experience</a>
              <a href="/contact">Contact</a>
            </nav>
            <span>© 2026 Raysto</span>
          </div>
          <div className="lp-footer-meta">
            <p>
              Product scenes are illustrative. Connected payments use PayPal
              Sandbox where enabled.
            </p>
            <span>Privacy &amp; Terms: publication pending</span>
            <MotionSwitch />
          </div>
        </div>
      </footer>
    </MotionShell>
  );
}
