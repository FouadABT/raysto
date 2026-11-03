"use client";
import { useEffect, useMemo, useState } from "react";
import { ConnectedApi } from "@/lib/connected/api";
import type { Json } from "@/lib/connected/contracts";
import { backoffice, type Dashboard, type DashboardRange } from "@/lib/connected/backoffice";
import { asRows, unresolved, type AgentActionRow, type CheckoutRow } from "@/lib/connected/business";
import {
  channelName,
  deltaChip,
  deltaSentence,
  firstName,
  greetingFor,
  isRange,
  kitchenTotal,
  localDate,
  noSales,
  previousShort,
  previousWords,
  rangeWords,
  ranges,
  trend,
  zoneCity,
} from "@/lib/connected/overview";
import {
  AreaChart,
  BarRow,
  CountUp,
  Donut,
  Reveal,
  Ring,
  Sparkline,
  formatCount,
  formatMoney,
  formatMoneyShort,
} from "./m3";
import { Icon, type IconName } from "./icons";
import { pill, useLoad, words, type Section } from "./business-sections";

const RANGE_KEY = "raysto.overviewRange";

function storedRange(): DashboardRange {
  try {
    const v = globalThis.localStorage?.getItem(RANGE_KEY);
    return isRange(v) ? v : "7d";
  } catch {
    return "7d";
  }
}

type Kpi = { key: keyof Dashboard["kpis"]; label: string; money: boolean; hero?: boolean };
const kpis: readonly Kpi[] = [
  { key: "sales", label: "Paid sales", money: true, hero: true },
  { key: "orders", label: "Orders", money: false },
  { key: "averageTicket", label: "Average ticket", money: true },
  { key: "tips", label: "Tips", money: true },
];

/**
 * The owner's Overview, on the `dashboard` query (docs/dashboard-contract.md).
 * Every figure is real: paid orders counted when they were placed. The judges'
 * café may add a sample series, drawn apart and labelled, never added to any
 * figure. It reloads when the workspace sees a real change (`revision`).
 */
export function OverviewSection({
  api,
  tenant,
  revision,
  currencyCode,
  openRequests,
  person,
  judges,
  open,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
  openRequests: number;
  /** The signed-in person's display name or email. */
  person?: { name?: string | null; email?: string | null };
  judges: boolean;
  open: (section: Section | "floor", focus?: string) => void;
}) {
  const [range, setRange] = useState<DashboardRange>(storedRange);
  useEffect(() => {
    try {
      globalThis.localStorage?.setItem(RANGE_KEY, range);
    } catch {
      /* Private mode: the choice lasts for this page only. */
    }
  }, [range]);
  const board = useLoad(() => backoffice(api, tenant).dashboard(range), [api, tenant, range, revision]);
  // What waits for a person; it loads on its own so one failure never hides the other.
  const needs = useLoad(async () => {
    const [inbox, checkouts] = await Promise.all([
      api.query<Json>("agent.inbox", { restaurantId: tenant }).catch(() => ({ rows: [] })),
      api.query<Json>("checkouts", { restaurantId: tenant, staff: true, order: "desc", limit: 100 }).catch(() => ({ rows: [] })),
    ]);
    const waiting = asRows<AgentActionRow>(inbox);
    return {
      proposals: waiting.length,
      aboutMoney: waiting.filter((a) => a.risk === "money").length,
      payments: unresolved(asRows<CheckoutRow>(checkouts), new Date()).length,
    };
  }, [api, tenant, revision]);

  const d = board.data;
  const code = d?.currency ?? currencyCode;
  const money = (n: number) => formatMoney(n, code);
  const short = (n: number) => formatMoneyShort(n, code);
  const now = new Date();
  const zone = d?.timezone;
  const name = firstName(person?.name, person?.email, judges);

  return (
    <div className="ops-ov" aria-busy={!d && !board.error}>
      <header className="ops-ov-head">
        <div className="ops-ov-hello">
          <p className="ops-ov-date">
            {localDate(now, zone)}
            {zone ? ` · ${zoneCity(zone)} time` : ""}
          </p>
          <h2 className="ops-ov-greeting">
            {greetingFor(now, zone)}
            {name ? (
              <>
                , <em>{name}</em>
              </>
            ) : (
              "."
            )}
          </h2>
          <p className="ops-ov-basis">
            Paid sales, counted when ordered · {rangeWords(range)} compared with {previousWords(range)}
          </p>
        </div>
        <div className="ops-segmented" role="group" aria-label="Period">
          {ranges.map((r) => (
            <button key={r.id} type="button" aria-pressed={range === r.id} onClick={() => setRange(r.id)}>
              {range === r.id && <Icon name="check" size={16} />}
              {r.label}
            </button>
          ))}
        </div>
      </header>

      <NeedsYou
        proposals={needs.data?.proposals ?? 0}
        aboutMoney={needs.data?.aboutMoney ?? 0}
        payments={needs.data?.payments ?? 0}
        requests={openRequests}
        loaded={!!needs.data}
        open={open}
      />

      {board.error && !d ? (
        <section className="ops-ov-card ops-ov-failed" role="alert">
          <Icon name="alert" size={22} />
          <div>
            <h3>The figures could not load.</h3>
            <p>{board.error}</p>
            <p>The other sections still work. Nothing here is estimated or filled in while it is missing.</p>
          </div>
          <button type="button" className="ops-secondary" onClick={() => board.reload()}>
            <Icon name="refresh" size={18} />
            Try again
          </button>
        </section>
      ) : !d ? (
        <div className="ops-skeleton" role="status" aria-label="Gathering the figures">
          <span className="hero" />
          <span />
          <span />
          <span />
        </div>
      ) : (
        <Figures d={d} range={range} money={money} short={short} open={open} />
      )}
    </div>
  );
}

function NeedsYou({
  proposals,
  aboutMoney,
  payments,
  requests,
  loaded,
  open,
}: {
  proposals: number;
  aboutMoney: number;
  payments: number;
  requests: number;
  loaded: boolean;
  open: (section: Section | "floor", focus?: string) => void;
}) {
  const chips: { label: string; icon: IconName; to: [Section | "floor", string?]; hot: boolean }[] = [];
  if (proposals)
    chips.push({
      label: `${proposals} ${proposals === 1 ? "proposal waits" : "proposals wait"} for you${aboutMoney ? ` · ${aboutMoney} about money` : ""}`,
      icon: "agents",
      to: ["agents"],
      hot: aboutMoney > 0,
    });
  if (payments)
    chips.push({
      label: `${payments} PayPal ${payments === 1 ? "payment" : "payments"} to resolve`,
      icon: "paypal",
      to: ["payments", "attempts"],
      hot: true,
    });
  if (requests)
    chips.push({ label: `${requests} service ${requests === 1 ? "request" : "requests"} at the tables`, icon: "bell", to: ["floor"], hot: false });
  if (!loaded) return <div className="ops-ov-needs" aria-hidden="true" />;
  return (
    <section className="ops-ov-needs" aria-label="Needs you">
      {chips.length === 0 ? (
        <span className="ops-ov-chip calm">
          <Icon name="check" size={18} />
          Nothing needs you right now
        </span>
      ) : (
        chips.map((c) => (
          <button key={c.label} type="button" className={`ops-ov-chip${c.hot ? " hot" : ""}`} onClick={() => open(c.to[0], c.to[1])}>
            <Icon name={c.icon} size={18} />
            {c.label}
            <Icon name="arrow" size={16} />
          </button>
        ))
      )}
    </section>
  );
}

function Figures({
  d,
  range,
  money,
  short,
  open,
}: {
  d: Dashboard;
  range: DashboardRange;
  money: (n: number) => string;
  short: (n: number) => string;
  open: (section: Section | "floor", focus?: string) => void;
}) {
  const empty = noSales(d);
  const kitchen = kitchenTotal(d.kitchen);
  const sample = useMemo(
    () => (d.sample && d.sample.points.length === d.points.length ? { label: d.sample.label, values: d.sample.points.map((p) => p.salesMinor) } : null),
    [d.sample, d.points.length],
  );
  const channelTotal = d.channels.reduce((n, c) => n + c.salesMinor, 0);
  const target = d.target.dailyTargetMinor;
  const reached = target > 0 ? Math.round((d.target.todayMinor / target) * 100) : 0;
  const per = d.granularity === "hour" ? "per hour" : "per day";
  return (
    <>
      <section className="ops-ov-kpis" aria-label={`Key figures, ${rangeWords(range)}`}>
        {kpis.map((k, i) => {
          const f = d.kpis[k.key];
          const fmt = k.money ? money : formatCount;
          const t = trend(f.value, f.previous);
          return (
            <Reveal key={k.key} index={i} visitKey="overview" as="article" className={`ops-ov-card ops-ov-kpi${k.hero ? " hero" : ""}`}>
              <h3 className="ops-ov-kpi-label">{k.label}</h3>
              <div className="ops-ov-kpi-main">
                <p className="ops-ov-kpi-value">
                  <CountUp value={f.value} format={fmt} />
                </p>
                {f.series.some((v) => v !== 0) && <Sparkline values={f.series} label={`${k.label} ${per}, ${rangeWords(range)}`} />}
              </div>
              <p className="ops-ov-delta">
                <span className={`ops-ov-trend ${t.kind}`} aria-hidden="true">
                  {deltaChip(f.value, f.previous)}
                </span>
                <span aria-hidden="true">{previousShort(range)}</span>
                <span className="m3-sr">{deltaSentence(f.value, f.previous, range)}</span>
              </p>
            </Reveal>
          );
        })}
      </section>

      <section className="ops-ov-row">
        <Reveal index={1} visitKey="overview" className="ops-ov-card ops-ov-trendcard">
          <div className="ops-ov-card-head">
            <h3>Paid sales {per}</h3>
            <span className="ops-ov-note">{rangeWords(range)}</span>
          </div>
          {empty && !sample ? (
            <p className="ops-ov-empty">
              No paid orders {range === "today" ? "yet today" : `in ${rangeWords(range)}`}. Paid sales appear here as PayPal or cash payments come in;
              nothing is drawn until then.
            </p>
          ) : (
            <>
              <AreaChart
                title={`Paid sales ${per}, ${rangeWords(range)}`}
                seriesLabel="Paid sales"
                points={d.points.map((p) => ({ label: p.label, value: p.salesMinor }))}
                sample={sample}
                format={money}
                axisFormat={short}
              />
              {empty && sample && (
                <p className="ops-ov-note">No real paid orders in this period yet: the solid line is at zero, the dashed one is the labelled sample.</p>
              )}
            </>
          )}
        </Reveal>
        <Reveal index={2} visitKey="overview" className="ops-ov-card ops-ov-live">
          <p className="ops-ov-live-chip">
            <i aria-hidden="true" />
            Kitchen live
          </p>
          <p className="ops-ov-live-number">
            <CountUp value={kitchen} format={formatCount} />
            <small>{kitchen === 1 ? "order in the kitchen" : "orders in the kitchen"}</small>
          </p>
          <BarRow
            title="Kitchen by status"
            max={Math.max(1, kitchen)}
            rows={[
              { label: "New", value: d.kitchen.submitted, display: String(d.kitchen.submitted), color: "var(--md-sys-color-inverse-primary)" },
              { label: "Accepted", value: d.kitchen.accepted, display: String(d.kitchen.accepted), color: "var(--md-sys-color-inverse-primary)" },
              { label: "Preparing", value: d.kitchen.preparing, display: String(d.kitchen.preparing), color: "var(--md-sys-color-inverse-primary)" },
              { label: "Ready", value: d.kitchen.ready, display: String(d.kitchen.ready), color: "var(--md-sys-color-inverse-primary)" },
            ]}
          />
          <p className="ops-ov-live-foot">
            {kitchen ? `Oldest waiting ${d.kitchen.oldestMinutes} min` : "The kitchen is clear"}
            <button type="button" className="ops-ov-link inverse" onClick={() => open("orders", "active")}>
              Open the orders
              <Icon name="arrow" size={16} />
            </button>
          </p>
        </Reveal>
      </section>

      <section className="ops-ov-row three">
        <Reveal index={0} inView visitKey="overview" className="ops-ov-card">
          <h3>Sales by channel</h3>
          {d.channels.length === 0 ? (
            <p className="ops-ov-empty">No paid orders to share out yet.</p>
          ) : (
            <Donut
              title={`Paid sales by channel, ${rangeWords(range)}`}
              segments={d.channels.map((c) => ({ label: channelName(c.channel), value: c.salesMinor, display: money(c.salesMinor) }))}
              center={
                <>
                  <strong className="ops-ov-center">{short(channelTotal)}</strong>
                  <small>paid sales</small>
                </>
              }
            />
          )}
        </Reveal>
        <Reveal index={1} inView visitKey="overview" className="ops-ov-card ops-ov-target">
          <h3>Daily target</h3>
          {target > 0 ? (
            <>
              <Ring
                value={d.target.todayMinor}
                max={target}
                label="Today's paid sales against the daily target"
                valueText={`${money(d.target.todayMinor)} of ${money(target)}`}
              >
                <strong className="ops-ov-center">{reached}%</strong>
                <small>of {short(target)}</small>
              </Ring>
              <p className="ops-ov-note">
                {money(d.target.todayMinor)} paid today{reached >= 100 ? ": target reached" : ""}
              </p>
            </>
          ) : (
            <div className="ops-ov-empty">
              <p>No daily target is set, so there is nothing to measure against.</p>
              <button type="button" className="ops-ov-link" onClick={() => open("money", "target")}>
                Set a daily target
                <Icon name="arrow" size={16} />
              </button>
            </div>
          )}
        </Reveal>
        <Reveal index={2} inView visitKey="overview" className="ops-ov-card">
          <h3>Team, {rangeWords(range)}</h3>
          {d.staff.length === 0 ? (
            <p className="ops-ov-empty">No one has moved an order or worked a recorded shift in this period.</p>
          ) : (
            <BarRow
              title={`Orders moved by each person, ${rangeWords(range)}`}
              rows={d.staff.map((s) => ({
                label: s.name,
                note: `${Math.round(s.hours * 10) / 10} h worked`,
                value: s.ordersMoved,
                display: `${s.ordersMoved} ${s.ordersMoved === 1 ? "order" : "orders"}`,
              }))}
            />
          )}
        </Reveal>
      </section>

      <Reveal index={0} inView visitKey="overview" as="section" className="ops-ov-card ops-ov-latest">
        <div className="ops-ov-card-head">
          <h3>Latest orders</h3>
          <button type="button" className="ops-ov-link" onClick={() => open("orders")}>
            All orders
            <Icon name="arrow" size={16} />
          </button>
        </div>
        {d.latest.length === 0 ? (
          <p className="ops-ov-empty">No orders yet.</p>
        ) : (
          <ul>
            {d.latest.map((o) => (
              <li key={o.id}>
                <button type="button" onClick={() => open("orders", `order:${o.id}`)}>
                  <strong>{o.number ? `#${o.number}` : `Order ${o.id}`}</strong>
                  <span className="ops-ov-latest-who">
                    {channelName(o.origin === "counter" ? "counter" : o.fulfillment)}
                    {o.customerLabel ? ` · ${o.customerLabel}` : ""}
                  </span>
                  {pill({ value: o.status, valueFormatted: words(o.status) })}
                  <span className="ops-ov-latest-time">
                    {new Date(o.createdAt).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}
                  </span>
                  <span className="ops-ov-latest-total">{formatMoney(o.totalMinor, o.currency)}</span>
                </button>
              </li>
            ))}
          </ul>
        )}
      </Reveal>
    </>
  );
}
