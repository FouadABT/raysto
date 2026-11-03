"use client";

import { AllCommunityModule, ModuleRegistry } from "ag-grid-community";
import { AgGridReact } from "ag-grid-react";
import { useEffect, useState } from "react";
import {
  AreaChart,
  BarRow,
  ContainerCard,
  ContainerDialog,
  CountUp,
  Donut,
  FadeThrough,
  NavIndicator,
  Reveal,
  Ring,
  SnackbarProvider,
  Sparkline,
  Stamp,
  deltaLabel,
  formatCount,
  formatMoney,
  formatMoneyShort,
  useSnackbar,
} from "@/components/connected/m3";
import { m3GridTheme } from "@/lib/connected/grid-theme";
import { MotionRoot, setReduceMotion, useAppReduceMotion } from "@/lib/connected/motion";

ModuleRegistry.registerModules([AllCommunityModule]);

type Point = { start: string; label: string; salesMinor: number; orders: number };
type Kpi = { value: number; previous: number; series: number[] };
export type DashboardFixture = {
  range: string;
  currency: string;
  points: Point[];
  kpis: Record<"sales" | "orders" | "averageTicket" | "tips", Kpi>;
  channels: { channel: string; salesMinor: number; orders: number }[];
  kitchen: { submitted: number; accepted: number; preparing: number; ready: number; oldestMinutes: number };
  latest: { id: number; number: number; status: string; totalMinor: number; currency: string; createdAt: string }[];
  staff: { name: string; ordersMoved: number; hours: number }[];
  target: { dailyTargetMinor: number; todayMinor: number };
  sample: { label: string; points: Point[] } | null;
};

const channelNames: Record<string, string> = { pickup: "Pickup", counter: "Counter", table: "Table", delivery: "Delivery", dineIn: "Dine-in" };

export function KitGallery({ data }: { data: DashboardFixture }) {
  // Client only, like the console itself (loaded with ssr: false): the
  // server cannot know the reduced-motion setting, so it would render the
  // first animation frame where the client renders the final state.
  const [ready, setReady] = useState(false);
  useEffect(() => setReady(true), []);
  if (!ready) return <main className="ops-root kit" />;
  return (
    <MotionRoot>
      <SnackbarProvider>
        <Gallery data={data} />
      </SnackbarProvider>
    </MotionRoot>
  );
}

function Gallery({ data }: { data: DashboardFixture }) {
  const [run, setRun] = useState(0);
  const reduce = useAppReduceMotion();
  const money = (n: number) => formatMoney(n, data.currency);
  const short = (n: number) => formatMoneyShort(n, data.currency);
  const k = data.kpis;
  const cards: { key: keyof typeof k; label: string; fmt: (n: number) => string; hero?: boolean }[] = [
    { key: "sales", label: "Paid sales", fmt: money, hero: true },
    { key: "orders", label: "Orders", fmt: formatCount },
    { key: "averageTicket", label: "Average ticket", fmt: money },
    { key: "tips", label: "Tips", fmt: money },
  ];
  const kitchenTotal = data.kitchen.submitted + data.kitchen.accepted + data.kitchen.preparing + data.kitchen.ready;
  return (
    <main className="ops-root kit">
      <header className="kit-head">
        <div>
          <p className="kit-eyebrow">Development only · the m3 kit on docs/fixtures/dashboard-7d.json</p>
          <h1>
            Good evening, <em>Fouad</em>
          </h1>
        </div>
        <div className="kit-tools">
          <button type="button" className="kit-btn" onClick={() => setRun((r) => r + 1)}>
            Replay entrances
          </button>
          <label className="kit-switch">
            <input type="checkbox" checked={reduce} onChange={(e) => setReduceMotion(e.target.checked)} /> Reduce motion
          </label>
        </div>
      </header>

      <div key={run} className="kit-stack">
        <section className="kit-kpis" aria-label="Key figures">
          {cards.map((c, i) => (
            <Reveal key={c.key} index={i} as="article" className={`kit-card kit-kpi${c.hero ? " hero" : ""}`}>
              <p className="kit-kpi-label">{c.label}</p>
              <p className="kit-kpi-value">
                <CountUp value={k[c.key].value} format={c.fmt} />
              </p>
              <div className="kit-kpi-foot">
                <span className="kit-delta">{deltaLabel(k[c.key].value, k[c.key].previous)} vs previous 7 days</span>
                <Sparkline values={k[c.key].series} label={`${c.label}, last 7 days`} />
              </div>
            </Reveal>
          ))}
        </section>

        <section className="kit-row">
          <Reveal index={1} className="kit-card kit-wide">
            <h2>Paid sales</h2>
            <AreaChart
              title="Paid sales per day, last 7 days"
              points={data.points.map((p) => ({ label: p.label, value: p.salesMinor }))}
              sample={data.sample ? { label: data.sample.label, values: data.sample.points.map((p) => p.salesMinor) } : null}
              format={money}
              axisFormat={short}
            />
          </Reveal>
          <Reveal index={2} className="kit-card kit-live">
            <p className="kit-live-chip">
              <i /> Kitchen live
            </p>
            <p className="kit-live-number">
              <CountUp value={kitchenTotal} format={formatCount} />
              <small>orders in the kitchen</small>
            </p>
            <BarRow
              title="Kitchen by status"
              max={Math.max(1, kitchenTotal)}
              rows={[
                { label: "New", value: data.kitchen.submitted, display: String(data.kitchen.submitted), color: "var(--md-sys-color-inverse-primary)" },
                { label: "Accepted", value: data.kitchen.accepted, display: String(data.kitchen.accepted), color: "var(--md-sys-color-inverse-primary)" },
                { label: "Preparing", value: data.kitchen.preparing, display: String(data.kitchen.preparing), color: "var(--md-sys-color-inverse-primary)" },
                { label: "Ready", value: data.kitchen.ready, display: String(data.kitchen.ready), color: "var(--md-sys-color-inverse-primary)" },
              ]}
            />
            <small>Oldest waiting {data.kitchen.oldestMinutes} min</small>
          </Reveal>
        </section>

        <section className="kit-row three">
          <Reveal index={0} inView className="kit-card">
            <h2>Sales by channel</h2>
            <Donut
              title="Sales by channel"
              segments={data.channels.map((c) => ({ label: channelNames[c.channel] ?? c.channel, value: c.salesMinor, display: money(c.salesMinor) }))}
              center={
                <>
                  <strong className="kit-center">{short(k.sales.value)}</strong>
                  <small>paid sales</small>
                </>
              }
            />
          </Reveal>
          <Reveal index={1} inView className="kit-card kit-target">
            <h2>Daily target</h2>
            <Ring
              value={data.target.todayMinor}
              max={data.target.dailyTargetMinor}
              label="Today's paid sales against the daily target"
              valueText={`${money(data.target.todayMinor)} of ${money(data.target.dailyTargetMinor)}`}
            >
              <strong className="kit-center">{Math.round((data.target.todayMinor / data.target.dailyTargetMinor) * 100)}%</strong>
              <small>of {short(data.target.dailyTargetMinor)}</small>
            </Ring>
          </Reveal>
          <Reveal index={2} inView className="kit-card">
            <h2>Staff this week</h2>
            <BarRow
              title="Orders moved by each person this week"
              rows={data.staff.map((s) => ({ label: s.name, note: `${s.hours} h`, value: s.ordersMoved, display: `${s.ordersMoved} orders` }))}
            />
          </Reveal>
        </section>

        <section className="kit-row three">
          <Reveal index={0} inView className="kit-card">
            <h2>Snackbar</h2>
            <SnackbarDemo />
          </Reveal>
          <Reveal index={1} inView className="kit-card">
            <h2>Stamp</h2>
            <StampDemo />
          </Reveal>
          <Reveal index={2} inView className="kit-card">
            <h2>Container transform</h2>
            <DialogDemo order={data.latest[0]} money={money} />
          </Reveal>
        </section>

        <section className="kit-row">
          <Reveal index={0} inView className="kit-card kit-wide">
            <h2>Fade through and the navigation indicator</h2>
            <FadeDemo />
          </Reveal>
          <Reveal index={1} inView className="kit-card">
            <h2>AG Grid on the m3 theme</h2>
            <div className="kit-grid" data-testid="kit-grid">
              <AgGridReact
                theme={m3GridTheme}
                rowData={data.latest.map((o) => ({ ticket: `#${o.number}`, status: o.status, total: money(o.totalMinor) }))}
                columnDefs={[{ field: "ticket" }, { field: "status" }, { field: "total" }]}
                domLayout="autoHeight"
                rowSelection={{ mode: "singleRow" }}
              />
            </div>
          </Reveal>
        </section>
      </div>
    </main>
  );
}

function SnackbarDemo() {
  const snack = useSnackbar();
  const [log, setLog] = useState("Nothing sent yet.");
  return (
    <div className="kit-col">
      <button
        type="button"
        className="kit-btn"
        onClick={() => {
          setLog("Pending: #13 to Ready (5 s)");
          snack.show({
            message: "#13 moved to Ready",
            action: { label: "Undo", onPress: () => setLog("Undone: nothing was sent.") },
            onDismiss: (why) => {
              if (why === "timeout" || why === "dismiss") setLog("Sent: order.transition #13 → ready");
            },
          });
        }}
      >
        Move #13 to Ready
      </button>
      <p className="kit-log" aria-live="polite">
        {log}
      </p>
    </div>
  );
}

function StampDemo() {
  const [paid, setPaid] = useState(false);
  return (
    <div className="kit-col">
      <div className="kit-invoice">
        <span>Invoice INV-0042 · Studio Lumen</span>
        <strong>$118.50</strong>
        <div className="kit-stamp-slot">
          <Stamp paid={paid} />
        </div>
      </div>
      <button type="button" className="kit-btn" onClick={() => setPaid((p) => !p)}>
        {paid ? "Reset" : "PayPal confirms the payment"}
      </button>
    </div>
  );
}

function DialogDemo({ order, money }: { order: DashboardFixture["latest"][number]; money: (n: number) => string }) {
  const [open, setOpen] = useState(false);
  const id = `kit-order-${order.id}`;
  return (
    <>
      <ContainerCard layoutId={id} className="kit-order">
        <strong>#{order.number}</strong>
        <span>{order.status}</span>
        <span>{money(order.totalMinor)}</span>
        <button type="button" className="kit-btn" onClick={() => setOpen(true)}>
          Open order #{order.number}
        </button>
      </ContainerCard>
      <ContainerDialog layoutId={id} open={open} onClose={() => setOpen(false)} title={`Order #${order.number}`}>
        <h2 className="kit-dialog-title">Order #{order.number}</h2>
        <p>
          {order.status} · {money(order.totalMinor)}
        </p>
        <p>The order panel goes here: lines, payment, the next step.</p>
        <button type="button" className="kit-btn" onClick={() => setOpen(false)}>
          Done
        </button>
      </ContainerDialog>
    </>
  );
}

const tabs = ["Overview", "Orders", "Money", "Team"];

function FadeDemo() {
  const [tab, setTab] = useState(tabs[0]);
  return (
    <div className="kit-col">
      <nav className="kit-nav" aria-label="Demo sections">
        {tabs.map((t) => (
          <button key={t} type="button" className="kit-nav-item" aria-pressed={t === tab} onClick={() => setTab(t)}>
            <NavIndicator active={t === tab} layoutId="kit-nav" />
            <span>{t}</span>
          </button>
        ))}
      </nav>
      <FadeThrough k={tab}>
        <div className="kit-fade">
          <strong>{tab}</strong>
          <p>Content of {tab}: fades out in 90 ms, the next one fades in with a 0.92 → 1 scale in 210 ms.</p>
        </div>
      </FadeThrough>
    </div>
  );
}
