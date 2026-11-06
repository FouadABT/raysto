"use client";
/**
 * The Overview's analytics: the last 30 days of paid sales and of money in
 * and out, on the console's AG Studio wrapper (studio-canvas.tsx) over the
 * `dashboard` and `ledger.journal` queries. View mode, three pages switched
 * in place; nothing is saved. Studio loads once the card scrolls near, so
 * the Overview's first screen stays light. When the café has no history yet
 * it says so; it never draws estimated sales.
 */
import { useEffect, useMemo, useRef, useState, type RefObject } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import { backoffice } from "@/lib/connected/backoffice";
import type { Json } from "@/lib/connected/contracts";
import {
  analyticsPages,
  feesEstimated,
  moneyRows,
  overviewStudioState,
  receivedRows,
  salesRows,
  totalsBy,
  type AnalyticsPage,
  type JournalLine,
} from "@/lib/connected/overview-analytics";
import { StudioCanvas } from "@/lib/connected/studio/studio-canvas";
import { useStudioSource, type StudioSource } from "@/lib/connected/studio/sources";
import { Icon } from "./icons";
import { AreaChart, BarRow, formatMoney, formatMoneyShort } from "./m3";
import "./overview-studio.css";

const short: Record<AnalyticsPage, string> = { sales: "Sales", received: "Payments", money: "In & out" };
const HEIGHT = 520;

/** Phones: AG Studio's canvas keeps a desktop width, so the same pages are drawn with the kit's charts. */
const PHONE = "(max-width: 599px)";
function usePhone(): boolean {
  const [phone, setPhone] = useState(() => typeof window !== "undefined" && window.matchMedia(PHONE).matches);
  useEffect(() => {
    const mq = window.matchMedia(PHONE);
    const on = () => setPhone(mq.matches);
    on();
    mq.addEventListener("change", on);
    return () => mq.removeEventListener("change", on);
  }, []);
  return phone;
}

/** True once the element has come into view (or at once without IntersectionObserver). */
function useSeen(ref: RefObject<HTMLElement | null>): boolean {
  const [seen, setSeen] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (seen || !el) return;
    if (typeof IntersectionObserver === "undefined") {
      setSeen(true);
      return;
    }
    const io = new IntersectionObserver((entries) => {
      if (entries.some((e) => e.isIntersecting)) {
        setSeen(true);
        io.disconnect();
      }
    });
    io.observe(el);
    return () => io.disconnect();
  }, [ref, seen]);
  return seen;
}

export function OverviewStudio({ api, tenant, currencyCode }: { api: ConnectedApi; tenant: number; currencyCode: string }) {
  const [page, setPage] = useState<AnalyticsPage>("sales");
  const box = useRef<HTMLDivElement>(null);
  const seen = useSeen(box);
  const phone = usePhone();
  return (
    <section className="ops-ov-card ops-ov-studio" aria-labelledby="ops-ov-studio-title">
      <div className="ops-ov-studio-head">
        <div>
          <h3 id="ops-ov-studio-title">Sales and money · last 30 days</h3>
          <p className="ops-ov-note">
            {phone
              ? "Paid orders and the café’s double-entry journal. The pivots open in AG Studio on a wider screen."
              : "Paid orders and the café’s double-entry journal, pivoted and charted in AG Studio."}
          </p>
        </div>
        <div className="ops-segmented" role="group" aria-label="Analytics page">
          {analyticsPages.map(([id, label]) => (
            <button key={id} type="button" aria-pressed={page === id} title={label} onClick={() => setPage(id)}>
              {page === id && <Icon name="check" size={16} />}
              {short[id]}
            </button>
          ))}
        </div>
      </div>
      <div ref={box} className="ops-ov-studio-body">
        {seen ? (
          <StudioBody api={api} tenant={tenant} currencyCode={currencyCode} page={page} phone={phone} />
        ) : (
          <p className="ops-ov-note" role="status">
            Opening the analytics…
          </p>
        )}
      </div>
    </section>
  );
}

function StudioBody({
  api,
  tenant,
  currencyCode,
  page,
  phone,
}: {
  api: ConnectedApi;
  tenant: number;
  currencyCode: string;
  page: AnalyticsPage;
  phone: boolean;
}) {
  // One journal read feeds two sources; the window is the last 30 days, in UTC.
  const journal = useRef<Promise<{ lines: JournalLine[]; currency?: string }> | null>(null);
  const readJournal = () =>
    (journal.current ??= (async () => {
      const to = new Date();
      const from = new Date(to.getTime() - 30 * 86400000);
      const r = await api.query<Json>("ledger.journal", { restaurantId: tenant, from: from.toISOString(), to: to.toISOString() });
      return { lines: (Array.isArray(r.rows) ? r.rows : []) as JournalLine[], currency: typeof r.currency === "string" ? r.currency : undefined };
    })());
  const [estimated, setEstimated] = useState(false);
  const days = useStudioSource("days", async () => salesRows(await backoffice(api, tenant).dashboard("30d")), [api, tenant]);
  const received = useStudioSource(
    "received",
    async () => {
      const j = await readJournal();
      return receivedRows(j.lines, j.currency ?? currencyCode);
    },
    [api, tenant],
  );
  const money = useStudioSource(
    "money",
    async () => {
      const j = await readJournal();
      setEstimated(feesEstimated(j.lines));
      return moneyRows(j.lines, j.currency ?? currencyCode);
    },
    [api, tenant],
  );
  const loading = days.loading || received.loading || money.loading;
  // A source that could not load is handed to Studio empty, so its widgets read "no data", never stale figures.
  const sources = useMemo<StudioSource[]>(
    () => [days.source ?? { id: "days", data: [] }, received.source ?? { id: "received", data: [] }, money.source ?? { id: "money", data: [] }],
    [days.source, received.source, money.source],
  );
  const state = useMemo(() => overviewStudioState(currencyCode), [currencyCode]);
  const anySales = (days.source?.data ?? []).some((r) => Number(r.sales) > 0);
  const anyMoney = (money.source?.data.length ?? 0) > 0 || (received.source?.data.length ?? 0) > 0;
  const failed = [days.error, received.error, money.error].filter(Boolean);

  if (loading)
    return (
      <p className="ops-ov-note" role="status">
        Reading 30 days of sales and the journal…
      </p>
    );
  if (failed.length === 3)
    return (
      <div className="ops-ov-empty" role="alert">
        <p>The analytics could not load: {failed[0]}</p>
      </div>
    );
  if (!anySales && !anyMoney)
    return (
      <div className="ops-ov-empty ops-ov-studio-empty">
        <p>
          No paid sales or money moves in the last 30 days yet. These pages fill in from real records as orders are paid and the journal
          grows; nothing is drawn until then.
        </p>
      </div>
    );
  return (
    <>
      {phone ? (
        <PhoneAnalytics page={page} sources={sources} code={currencyCode} />
      ) : (
        <StudioCanvas label={`Analytics: ${analyticsPages.find(([id]) => id === page)?.[1]}`} sources={sources} initialState={state} page={page} height={HEIGHT} />
      )}
      {(failed.length > 0 || estimated) && (
        <p className="ops-ov-note ops-ov-studio-foot">
          {failed.length > 0 ? `Part of the analytics could not load: ${failed[0]}. ` : ""}
          {estimated ? "PayPal fees are estimated where PayPal did not report them." : ""}
        </p>
      )}
    </>
  );
}

/** The three pages on a phone: the same rows, drawn with the console's kit charts. */
function PhoneAnalytics({ page, sources, code }: { page: AnalyticsPage; sources: StudioSource[]; code: string }) {
  const rows = (id: string) => sources.find((s) => s.id === id)?.data ?? [];
  const money = (minor: number) => formatMoney(minor, code);
  if (page === "sales") {
    const days = rows("days");
    const minor = (r: (typeof days)[number]) => Math.round(Number(r.sales ?? 0) * 100);
    const total = days.reduce((n, r) => n + minor(r), 0);
    const orders = days.reduce((n, r) => n + Number(r.orders ?? 0), 0);
    const best = Math.max(0, ...days.map(minor));
    return (
      <div className="ops-ov-phone">
        <p className="ops-ov-phone-line">
          <strong>{money(total)}</strong> paid sales · {orders} paid {orders === 1 ? "order" : "orders"} · best day {money(best)}
        </p>
        <AreaChart
          title="Paid sales by day, last 30 days"
          seriesLabel="Paid sales"
          points={days.map((r) => ({ label: String(r.day).slice(5), value: minor(r) }))}
          format={money}
          axisFormat={(n) => formatMoneyShort(n, code)}
        />
      </div>
    );
  }
  if (page === "received") {
    const methods = totalsBy(rows("received"), "method");
    const total = methods.reduce((n, m) => n + m.minor, 0);
    return (
      <div className="ops-ov-phone">
        <p className="ops-ov-phone-line">
          <strong>{money(total)}</strong> received in 30 days
        </p>
        <BarRow
          title="Received by method, last 30 days"
          rows={methods.map((m) => ({
            label: m.label,
            value: m.minor,
            display: `${money(m.minor)} · ${total ? Math.round((m.minor / total) * 100) : 0}%`,
          }))}
        />
      </div>
    );
  }
  const lines = rows("money");
  const accounts = totalsBy(lines, "account");
  const inMinor = totalsBy(lines, "kind").find((k) => k.label === "Money in")?.minor ?? 0;
  const outMinor = totalsBy(lines, "kind").find((k) => k.label === "Money out")?.minor ?? 0;
  return (
    <div className="ops-ov-phone">
      <p className="ops-ov-phone-line">
        In {money(inMinor)} · out {money(Math.abs(outMinor))} · <strong>net cash movement {money(inMinor + outMinor)}</strong>
      </p>
      <BarRow
        title="Money in and out by account, last 30 days"
        rows={accounts.slice(0, 8).map((a) => ({
          label: a.label,
          note: a.minor < 0 ? "out" : "in",
          value: Math.abs(a.minor),
          display: money(a.minor),
          color: a.minor < 0 ? "var(--raysto-chart-4)" : undefined,
        }))}
      />
    </div>
  );
}
