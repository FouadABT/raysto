"use client";

import dynamic from "next/dynamic";
import { useState } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import { currency } from "@/lib/connected/contracts";
import { backoffice, type DashboardRange } from "@/lib/connected/backoffice";
import type { CostProduct, FinancialSummary } from "@/lib/connected/finance";
import { channelName, localDate, rangeWords } from "@/lib/connected/overview";
import { useWorkspaceValue } from "@/lib/connected/workspace-location";
import { AreaChart, Donut, Sparkline, Reveal, formatMoneyShort } from "./m3";
import { Icon } from "./icons";
import { type Section } from "./business-sections";
import { useOverviewRead } from "@/lib/connected/use-overview-read";
import { Pending, RefreshStatus } from "./m3";
import { m } from "motion/react";
import { motionPresets, useReduce } from "@/lib/connected/motion";

const DetailedOverview = dynamic(
  () => import("./overview-section").then((m) => m.OverviewSection),
  {
    loading: () => (
      <Pending label="Opening detailed reports and review tools…" kind="studio" />
    ),
  },
);

type Props = {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
  openRequests: number;
  person?: { name?: string | null; email?: string | null };
  judges: boolean;
  open: (section: Section | "floor", focus?: string) => void;
  investigate: (
    productId?: number,
    view?: "evidence" | "studio" | "compare",
  ) => void;
};

export function OverviewSection(props: Props) {
  const { api, tenant, revision, judges, open, investigate } = props;
  const [view, setView] = useWorkspaceValue<"summary" | "details">(
    "overview",
    "view",
    ["summary", "details"],
    "summary",
  );
  const [range, setRange] = useWorkspaceValue<DashboardRange>(
    "overview",
    "period",
    ["today", "7d", "30d"],
    "7d",
  );
  const [definitions, setDefinitions] = useState(false);
  const board = useOverviewRead(
    api, tenant, `dashboard:${range}`, revision,
    () => backoffice(api, tenant).dashboard(range),
  );
  const costs = useOverviewRead(
    api, tenant, "costing.products", revision,
    (signal) =>
      api.query<{
        rows: CostProduct[];
        coverage: { complete: number; total: number };
      }>("costing.products", { restaurantId: tenant }, signal),
  );
  const d = board.data,
    code = d?.currency ?? props.currencyCode;
  const financial = useOverviewRead(
    api, tenant, `finance:${d?.from}:${d?.to}:${code}`, revision,
    (signal) =>
      api.query<FinancialSummary>("finance.summary", {
        restaurantId: tenant,
        from: d!.from, to: d!.to,
      }, signal),
    !!d,
  );
  const product =
    costs.data?.rows.find(
      (p) =>
        p.currency === code &&
        p.complete &&
        p.change?.complete &&
        (p.change?.costIncreaseMinor ?? 0) > 0,
    ) ?? costs.data?.rows.find((p) => p.currency === code && p.complete);
  const money = (n: number) => currency(n, code);
  const activeOrders = d
    ? d.kitchen.submitted +
      d.kitchen.accepted +
      d.kitchen.preparing +
      d.kitchen.ready
    : undefined;
  const summary = financial.data?.from === d?.from && financial.data?.to === d?.to && financial.data?.currency === code ? financial.data : undefined;
  if (view === "details")
    return (
      <div className="jr-details">
        <button
          className="ops-btn secondary"
          onClick={() => setView("summary")}
        >
          <Icon name="arrow" size={18} /> Back to café overview
        </button>
        <DetailedOverview {...props} />
      </div>
    );

  return (
    <div className="jr-home" aria-busy={!d && !board.error}>
      <Reveal as="header" className="jr-welcome" visitKey={`welcome:${tenant}`}>
        <div>
          <p className="jr-eyebrow">
            {judges ? "YOUR DEMO CAFÉ" : "YOUR CAFÉ, AT A GLANCE"}
          </p>
          <h2>
            {judges
              ? "One café. One clear decision."
              : "A clearer view of your day."}
          </h2>
          <p>
            {judges
              ? "Follow a supplier cost change, compare your options, then inspect the outcome."
              : "See the essentials, choose what needs attention and open the details when you need them."}
          </p>
        </div>
        <span className="jr-date">{localDate(new Date(), d?.timezone)}</span>
      </Reveal>

      <Reveal as="section" className="jr-start" ariaLabel="Start a cost investigation" index={1} visitKey={`story:${tenant}`}>
        <div className="jr-start-story">
          <span className="jr-kicker">
            <Icon name="agents" size={18} />{" "}
            {judges
              ? "START HERE · SAMPLE CAFÉ STORY"
              : "A DECISION WORTH A CLOSER LOOK"}
          </span>
          <h3>
            {product?.change?.complete &&
            product.change.costIncreaseMinor &&
            product.change.costIncreaseMinor > 0
              ? "A supplier cost rose. What should change?"
              : "Understand a dish before changing its price."}
          </h3>
          <p>
            {product
              ? product.name
              : costs.error
                ? "Dish costs could not load. You can still open the investigation workspace."
                : costs.data
                  ? "Start with one dish and its confirmed ingredient costs."
              : "Finding a dish with confirmed cost evidence…"}
          </p>
          <ol className="jr-journey" aria-label="The decision journey">
            <li>
              <span>1</span> Understand the cost
            </li>
            <li>
              <span>2</span> Compare prices
            </li>
            <li>
              <span>3</span> Review the outcome
            </li>
          </ol>
          <div className="jr-start-actions">
            <button
              className="ops-btn"
              onClick={() => investigate(product?.productId, "evidence")}
              disabled={!costs.data && !costs.error}
            >
              Start the investigation <Icon name="arrow" size={18} />
            </button>
            <button
              className="jr-text-button"
              disabled={!costs.data && !costs.error}
              onClick={() => investigate(product?.productId, "studio")}
            >
              Open in AG Studio <Icon name="arrow" size={16} />
            </button>
          </div>
          <p className="jr-start-note">
            {judges
              ? "Illustrative business data · real PayPal Sandbox evidence where recorded."
              : "AI explains. You review. Business changes require the appropriate approval."}
          </p>
        </div>
        <div className="jr-cost-visual">
          {product ? (
            <CostVisual product={product} />
          ) : (
            <div className="jr-cost-placeholder" aria-busy={!costs.error && !costs.data}>
              <Icon name="receipt" size={34} />
              {!costs.data && !costs.error ? <Pending kind="receipt" label="Finding confirmed dish costs…" /> : <p>Receipt → dish → decision</p>}
              <small>Missing costs stay unknown.</small>
              {costs.error && (
                <button
                  className="jr-text-button"
                  onClick={() => costs.reload()}
                >
                  Retry dish costs
                </button>
              )}
            </div>
          )}
        </div>
      </Reveal>

      {costs.error && product && (
        <p role="status" className="ops-note">
          Dish costs could not refresh. Previously loaded evidence may be stale.
          <button className="jr-text-button" onClick={() => costs.reload()}>
            Retry dish costs
          </button>
        </p>
      )}
      {d && <RefreshStatus loading={board.loading} label={`Updating ${rangeWords(range)}. The displayed figures still cover ${rangeWords(d.range)}.`} />}
      {board.error && d && (
        <p role="alert" className="ops-note">
          Figures could not refresh. Previously loaded figures may be stale.
          <button className="jr-text-button" onClick={() => board.reload()}>
            Retry café figures
          </button>
        </p>
      )}
      <div className="jr-section-heading">
        <div>
          <h3>The café in three numbers</h3>
          <p>
            {rangeWords(d?.range ?? range)} · {code}
            {judges ? " · includes sample history" : ""}
          </p>
        </div>
        <div className="ops-segmented" role="group" aria-label="Period">
          {(
            [
              ["today", "Today"],
              ["7d", "7 days"],
              ["30d", "30 days"],
            ] as const
          ).map(([key, label]) => (
            <button
              key={key}
              aria-pressed={range === key}
              data-pending={board.loading && range === key || undefined}
              onClick={() => setRange(key)}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {board.error && !d ? (
        <section className="jr-card" role="alert">
          <h3>The café figures are unavailable</h3>
          <p>Nothing has been filled in as zero.</p>
          <button className="ops-btn secondary" onClick={() => board.reload()}>
            Retry café figures
          </button>
        </section>
      ) : !d ? (
        <div className="jr-metrics" aria-label="Loading café figures" role="status">
          {[0, 1, 2].map((n) => (
            <div className="jr-metric jr-pending" key={n}>
              <span>{["Paid order value", "Paid orders", "Average order"][n]}</span>
              <span className="ops-skeleton-value" aria-hidden="true" />
              <span className="m3-sr">Loading…</span>
            </div>
          ))}
        </div>
      ) : (
        <section className="jr-metrics" aria-label="Café summary">
          {[
            {
              label: "Paid order value",
              k: d.kpis.sales,
              display: money(d.kpis.sales.value),
              help: "Value of paid orders placed in this period.",
            },
            {
              label: "Paid orders",
              k: d.kpis.orders,
              display: d.kpis.orders.value.toLocaleString(),
              help: "Orders placed in this period that have been paid.",
            },
            {
              label: "Average order",
              k: d.kpis.averageTicket,
              display: money(d.kpis.averageTicket.value),
              help: "Average value of those paid orders.",
            },
          ].map((metric, i) => (
            <Reveal
              key={metric.label}
              index={i}
              as="article"
              className={"jr-metric tone-" + i}
              visitKey="clear-overview-metrics"
            >
              <span className="jr-metric-label">{metric.label}</span>
              <div>
                <strong>{metric.display}</strong>
                <Sparkline
                  values={metric.k.series}
                  label={metric.label + " over the selected period"}
                />
              </div>
              <p>{metric.help}</p>
            </Reveal>
          ))}
        </section>
      )}

      {!d && !board.error && <div className="jr-dashboard-grid" aria-hidden="true"><Pending kind="studio" label="Loading the sales trend…" /><Pending kind="studio" label="Loading order channels…" /></div>}
      {d && (
        <div className="jr-dashboard-grid">
          <section
            className="jr-card jr-sales"
            aria-label="Paid order value trend"
          >
            <div className="jr-card-heading">
              <div>
                <span className="jr-eyebrow">THE BIG PICTURE</span>
                <h3>How sales are moving</h3>
              </div>
              <span className="jr-chart-unit">
                {code} · {d.granularity === "hour" ? "hourly" : "daily"}
              </span>
            </div>
            <AreaChart
              title={"Paid order value, " + rangeWords(d?.range ?? range)}
              seriesLabel="Paid order value"
              points={d.points.map((p) => ({
                label: p.label,
                value: p.salesMinor,
              }))}
              format={money}
              axisFormat={(n) => formatMoneyShort(n, code)}
              height={220}
            />
            <p className="jr-caption">
              Paid orders counted when placed. This is not an operating-profit
              chart.
            </p>
          </section>
          <section className="jr-card jr-channels" aria-label="Order channels">
            <span className="jr-eyebrow">WHERE ORDERS COME FROM</span>
            <h3>Ways people order</h3>
            {d.channels.some((c) => c.orders > 0) ? (
              <Donut
                title="Paid orders by channel"
                size={146}
                thickness={22}
                center={
                  <>
                    <strong>{d.kpis.orders.value.toLocaleString()}</strong>
                    <span>paid orders</span>
                  </>
                }
                segments={d.channels.map((c, i) => ({
                  label: channelName(c.channel),
                  value: c.orders,
                  display: c.orders.toLocaleString() + " orders",
                  color: ["#173F35", "#B3CB86", "#D2A87F", "#6B9686"][i % 4],
                }))}
              />
            ) : (
              <p>No paid orders in this period.</p>
            )}
          </section>
          <section
            className="jr-card jr-attention"
            aria-label="Your next actions"
          >
            <div className="jr-card-heading">
              <h3>A little attention</h3>
              <Icon name="agents" size={22} />
            </div>
            <button
              className="jr-action-row"
              onClick={() => setView("details")}
            >
              <span className="jr-action-icon">
                <Icon name="agents" size={20} />
              </span>
              <span>
                <strong>Review AI proposals</strong>
                <small>Inspect evidence before approving an action.</small>
              </span>
              <Icon name="arrow" size={18} />
            </button>
            <button className="jr-action-row" onClick={() => open("orders")}>
              <span className="jr-action-icon">
                <Icon name="orders" size={20} />
              </span>
              <span>
                <strong>
                  {activeOrders == null
                    ? "Open the kitchen"
                    : activeOrders === 0
                      ? "The kitchen is clear"
                      : activeOrders + " orders in the kitchen"}
                </strong>
                <small>Open active tickets and their next steps.</small>
              </span>
              <Icon name="arrow" size={18} />
            </button>
            <button
              className="jr-action-row"
              onClick={() => open("supplies", "bills")}
            >
              <span className="jr-action-icon">
                <Icon name="receipt" size={20} />
              </span>
              <span>
                <strong>
                  {typeof summary?.payablesMinor === "number"
                    ? money(summary.payablesMinor) + " in unpaid bills"
                    : "Review unpaid bills"}
                </strong>
                <small>Payment is a separate, reviewed action.</small>
              </span>
              <Icon name="arrow" size={18} />
            </button>
          </section>
          <section className="jr-card jr-how">
            <span className="jr-eyebrow">
              THREE TOOLS, ONE CONNECTED WORKFLOW
            </span>
            <h3>From evidence to a decision</h3>
            <div className="jr-tool-story">
              <div>
                <span>01</span>
                <strong>AI explains</strong>
                <p>Reads the evidence and prepares a supported comparison.</p>
              </div>
              <div>
                <span>02</span>
                <strong>You investigate</strong>
                <p>
                  Use AG Studio to compare, challenge and arrange the evidence.
                </p>
              </div>
              <div>
                <span>03</span>
                <strong>PayPal executes</strong>
                <p>
                  Approved collections and payouts leave inspectable Sandbox
                  records.
                </p>
              </div>
            </div>
          </section>
        </div>
      )}

      <footer className="jr-home-footer">
        <button className="jr-text-button" onClick={() => setView("details")}>
          Open detailed reports & AI tools <Icon name="arrow" size={16} />
        </button>
        <button
          className="jr-text-button"
          aria-expanded={definitions}
          onClick={() => setDefinitions((v) => !v)}
        >
          About these figures
        </button>
      </footer>
      {definitions && (
        <section
          className="jr-card jr-definitions"
          aria-label="Financial definitions"
        >
          <h3>What these figures mean</h3>
          <p>
            Paid order value is not recognized net sales or profit. Refunds,
            tax, tips, timing and incomplete records can make financial reports
            differ.
          </p>
          {summary && (
            <>
              <p>
                {summary.basisLabel} · {summary.currency} · {summary.timezone}
              </p>
              {!summary.complete && (
                <p>
                  Accounting evidence is incomplete or uses a legacy basis. An
                  operating-profit claim is unavailable.
                </p>
              )}
            </>
          )}
          {financial.error && (
            <p role="status">
              Financial definitions could not refresh. Open Money to inspect the
              available records.
            </p>
          )}
          <p>
            Recorded cash comes from Raysto transactions; it is not a verified
            external bank balance.
          </p>
          <button className="ops-btn secondary" onClick={() => open("money")}>
            Open financial records
          </button>
        </section>
      )}
    </div>
  );
}

function CostVisual({ product: p }: { product: CostProduct }) {
  const reduce = useReduce();
  const known =
    p.complete &&
    p.replacementCostMinor != null &&
    p.contributionMinor != null &&
    p.netPriceMinor > 0;
  const increase = p.change?.complete ? p.change.costIncreaseMinor : null;
  const costShare = known
    ? Math.max(
        0,
        Math.min(100, (p.replacementCostMinor! / p.netPriceMinor) * 100),
      )
    : 0;
  return (
    <m.div className="jr-cost-card" initial={reduce ? false : { opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={motionPresets.spatialDefault}>
      <div className="jr-cost-card-top">
        <span>THE DISH BEHIND THE DECISION</span>
        <Icon name="receipt" size={22} />
      </div>
      <h4>{p.name}</h4>
      {increase != null && increase > 0 && (
        <p className="jr-cost-change">
          +{currency(increase, p.currency)}
          <span>replacement cost per dish</span>
        </p>
      )}
      <p className="jr-cost-price">
        Of each {currency(p.netPriceMinor, p.currency)} net item sale
      </p>
      {known ? (
        <>
          <div
            className="jr-contribution-track"
            role="img"
            aria-label={
              "Included cost " +
              currency(p.replacementCostMinor!, p.currency) +
              "; contribution " +
              currency(p.contributionMinor!, p.currency) +
              " before fees and shared overhead."
            }
          >
            <span style={{ width: costShare + "%" }} />
            <span style={{ width: 100 - costShare + "%" }} />
          </div>
          <div className="jr-cost-legend">
            <div>
              <i className="cost" />
              <span>Included cost</span>
              <strong>{currency(p.replacementCostMinor!, p.currency)}</strong>
            </div>
            <div>
              <i className="contribution" />
              <span>Contribution*</span>
              <strong>{currency(p.contributionMinor!, p.currency)}</strong>
            </div>
          </div>
        </>
      ) : (
        <p>Cost data is incomplete. No recommendation is available.</p>
      )}
      <small>*Before fees and shared overhead. Not net profit.</small>
    </m.div>
  );
}
