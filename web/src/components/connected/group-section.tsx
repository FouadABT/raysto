"use client";
/**
 * The franchise view: every venue of a group on AG Studio pages (Portfolio,
 * Compare venues, Money), with the same figures in plain grids beneath, and
 * the group's menu templates and stock transfers.
 *
 * - Reads go through the group.* queries, which check the person's group
 *   role and read each venue with a read-only view. Money is shown per
 *   currency and never added across currencies.
 * - Owners edit the Studio layout (saved for them) and get the assistant
 *   panel; the judges' café may rearrange but never saves.
 * - Writes are the venues' own commands: pushing a template makes a
 *   proposed menu draft that each venue's manager publishes; a transfer
 *   writes two stock movements; nothing here moves money.
 */
import { useMemo, useRef, useState, type FormEvent } from "react";
import type { ColDef } from "ag-grid-community";
import type { ConnectedApi } from "@/lib/connected/api";
import { currency } from "@/lib/connected/contracts";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import { countCol, dateCol, idCol, moneyCol, statusCol } from "@/lib/connected/grid-columns";
import {
  agingBucket,
  compareRows,
  currenciesOf,
  groupOfVenue,
  parseTemplateLines,
  pnlRows,
  rangeLabel,
  readsMoney,
  roleLabel,
  totalsByCurrency,
  venueRows,
  type CompareRow,
  type GroupOverview,
  type GroupRange,
  type GroupRow,
  type LedgerLine,
  type PayableRow,
  type TemplateRow,
  type VenueFigures,
} from "@/lib/connected/group";
import { StudioCanvas } from "@/lib/connected/studio/studio-canvas";
import { groupPages } from "@/lib/connected/studio/pages";
import { groupAssistant, type ToolScope } from "@/lib/connected/studio/ai-tools";
import { CountUp, Reveal } from "./m3";
import { Icon } from "./icons";
import { RaystoGrid } from "./raysto-grid";
import { useLoad } from "./business-sections";
import { useGroupChoice } from "./group-switcher";
import "./group-section.css";

/** Props every 0.16 section receives from the workspace. */
export interface SectionProps {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
}

/** Group commands carry no restaurant: the group row is the one locked. */
const noVenue = undefined as unknown as number;
const errorText = (e: unknown) => (e instanceof Error ? e.message : String(e));

type Page = "portfolio" | "compare" | "money" | "templates" | "transfers";
const studioPagesIds = new Set<Page>(["portfolio", "compare", "money"]);

/**
 * Franchise view: every venue of the group on AG Studio pages (portfolio, compare venues, money).
 * The group is the one chosen in the switcher, else the one this venue belongs to.
 */
export function GroupSection({ api, tenant, revision, currencyCode }: SectionProps) {
  const choice = useGroupChoice();
  const list = useLoad(() => api.query<{ rows: GroupRow[] }>("group.list").then((r) => r.rows), [api, revision]);
  const groups = list.data ?? choice?.groups;
  const group =
    (choice?.groupId ? groups?.find((g) => g.id === choice.groupId) : undefined) ?? (groups ? groupOfVenue(groups, tenant) : undefined);
  if (!groups)
    return list.error ? (
      <p className="ops-error" role="alert">
        {list.error}
      </p>
    ) : (
      <p className="ops-note" role="status">
        Loading your groups…
      </p>
    );
  if (!group)
    return (
      <NoGroup
        api={api}
        tenant={tenant}
        currencyCode={currencyCode}
        groups={groups}
        onDone={() => {
          list.reload();
          choice?.reload();
        }}
      />
    );
  return <GroupView key={group.id} api={api} tenant={tenant} revision={revision} group={group} onChanged={() => list.reload()} />;
}

function NoGroup({
  api,
  tenant,
  currencyCode,
  groups,
  onDone,
}: {
  api: ConnectedApi;
  tenant: number;
  currencyCode: string;
  groups: GroupRow[];
  onDone: () => void;
}) {
  const owned = groups.filter((g) => g.role === "owner");
  const [name, setName] = useState("");
  const [target, setTarget] = useState<number | "">(owned[0]?.id ?? "");
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  async function run(e: FormEvent, create: boolean) {
    e.preventDefault();
    setBusy(true);
    setNote("");
    try {
      let groupId = typeof target === "number" ? target : 0;
      if (create) {
        const made = await api.command<{ groupId: number }>("group.create", noVenue, { name: name.trim(), currency: currencyCode });
        groupId = made.groupId;
      }
      await api.command("group.attach", tenant, { groupId });
      onDone();
    } catch (err) {
      setNote(errorText(err));
    } finally {
      setBusy(false);
    }
  }
  return (
    <section className="ops-panel ops-group-empty" aria-labelledby="group-title">
      <span className="ops-eyebrow">Group</span>
      <h2 id="group-title">This venue is not in a group</h2>
      <p>
        A group puts up to twelve venues side by side: sales, the books and stock across all of them, menu templates and stock transfers.
        Each venue keeps its own PayPal connection, team and records. Only a venue&rsquo;s owner can add it.
      </p>
      <div className="ops-group-forms">
        <form className="ops-group-form" onSubmit={(e) => void run(e, true)}>
          <label>
            New group&rsquo;s name
            <input value={name} onChange={(e) => setName(e.target.value)} maxLength={80} required placeholder="Atelier Group" />
          </label>
          <button className="ops-primary" type="submit" disabled={busy || !name.trim()}>
            <Icon name="plus" size={18} /> Start a group with this venue
          </button>
        </form>
        {owned.length > 0 && (
          <form className="ops-group-form" onSubmit={(e) => void run(e, false)}>
            <label>
              Or add it to a group you own
              <select value={target} onChange={(e) => setTarget(Number(e.target.value))}>
                {owned.map((g) => (
                  <option key={g.id} value={g.id}>
                    {g.name}
                  </option>
                ))}
              </select>
            </label>
            <button type="submit" disabled={busy || target === ""}>
              Add this venue
            </button>
          </form>
        )}
      </div>
      {note && (
        <p className="ops-error" role="alert">
          {note}
        </p>
      )}
    </section>
  );
}

function GroupView({
  api,
  tenant,
  revision,
  group,
  onChanged,
}: {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  group: GroupRow;
  onChanged: () => void;
}) {
  const [range, setRange] = useState<GroupRange>("7d");
  const [page, setPage] = useState<Page>("portfolio");
  const money = readsMoney(group.role);
  const owner = group.role === "owner";
  const judges = group.venues.some((v) => isJudgeVenue(v.restaurantId)) || isJudgeVenue(tenant);
  const overview = useLoad(
    () => api.query<GroupOverview>("group.overview", { groupId: group.id, range }),
    [api, group.id, range, revision],
  );
  const compare = useLoad(
    () => api.query<{ rows: CompareRow[] }>("group.compare", { groupId: group.id, range }).then((r) => r.rows),
    [api, group.id, range, revision],
  );
  const ledger = useLoad(
    () =>
      money
        ? api.query<{ rows: LedgerLine[]; truncated: boolean }>("group.ledger", { groupId: group.id, range })
        : Promise.resolve({ rows: [] as LedgerLine[], truncated: false }),
    [api, group.id, range, revision, money],
  );
  const payables = useLoad(
    () => (money ? api.query<{ rows: PayableRow[] }>("group.payables", { groupId: group.id }).then((r) => r.rows) : Promise.resolve([])),
    [api, group.id, revision, money],
  );
  const venues = overview.data?.venues;
  const currencies = useMemo(() => currenciesOf(venues ?? group.venues), [venues, group.venues]);
  const [picked, setPicked] = useState<string>();
  const cur = picked && currencies.includes(picked) ? picked : currencies[0] ?? "USD";

  // Studio's sources: one currency at a time, refreshed in place.
  const sources = useMemo(
    () => [
      { id: "venues", data: venueRows(venues ?? [], cur) },
      { id: "days", data: compareRows(compare.data ?? [], cur) },
      { id: "pnl", data: pnlRows(ledger.data?.rows ?? [], cur) },
    ],
    [venues, compare.data, ledger.data, cur],
  );
  const initial = useMemo(() => groupPages(cur, money), [cur, money]);
  const scope = useMemo<ToolScope>(
    () => ({ api, groupId: group.id, groupName: group.name, venues: group.venues, range, money }),
    [api, group, range, money],
  );
  const scopeRef = useRef(scope);
  scopeRef.current = scope;
  const assistant = useMemo(() => groupAssistant(() => scopeRef.current), [scopeRef]);

  const pages: [Page, string][] = [
    ["portfolio", "Portfolio"],
    ["compare", "Compare venues"],
    ...(money ? ([["money", "Money"]] as [Page, string][]) : []),
    ["templates", "Menu templates"],
    ["transfers", "Stock transfers"],
  ];
  const totals = totalsByCurrency(venues ?? []);
  const shared = group.venues.length === 2 ? "Both venues share" : "These venues share";
  return (
    <div className="ops-business ops-group">
      <header className="ops-group-head">
        <div>
          <span className="ops-eyebrow">
            Group · {group.venues.length} venue{group.venues.length === 1 ? "" : "s"} · you are its {roleLabel(group.role).toLowerCase()}
          </span>
          <h2>{group.name}</h2>
          <p className="ops-group-venues">{group.venues.map((v) => v.name).join(" · ")}</p>
        </div>
        <div className="ops-chips" role="group" aria-label="Period">
          {(["today", "7d", "30d"] as const).map((r) => (
            <button key={r} type="button" aria-pressed={range === r} onClick={() => setRange(r)}>
              {rangeLabel[r]}
            </button>
          ))}
        </div>
      </header>
      <p className="ops-group-banner" role="note">
        <Icon name="paypal" size={18} />
        <span>
          <strong>Sandbox.</strong> {shared} one Sandbox merchant; in production each connects its own PayPal.
        </span>
      </p>
      {overview.error && (
        <p className="ops-error" role="alert">
          {overview.error}
        </p>
      )}
      <div className="ops-kpis compact" aria-label="Group totals">
        {totals.length === 0 && !overview.error ? (
          <p className="ops-note" role="status">
            Adding up the venues…
          </p>
        ) : (
          totals.flatMap((t, i) => [
            <Reveal key={`${t.currency}-sales`} index={i * 3} visitKey="group-kpis" className="ops-kpi">
              <span>
                Paid sales · {t.currency} · {t.venues} venue{t.venues === 1 ? "" : "s"}
              </span>
              <strong>
                <CountUp value={t.paidSalesMinor} format={(n) => currency(Math.round(n), t.currency)} />
              </strong>
              <small>{t.orders} paid orders</small>
            </Reveal>,
            <Reveal key={`${t.currency}-bills`} index={i * 3 + 1} visitKey="group-kpis" className={`ops-kpi${t.billsDueMinor ? " alert" : ""}`}>
              <span>Bills due in 7 days · {t.currency}</span>
              <strong>
                <CountUp value={t.billsDueMinor} format={(n) => currency(Math.round(n), t.currency)} />
              </strong>
            </Reveal>,
            <Reveal key={`${t.currency}-stock`} index={i * 3 + 2} visitKey="group-kpis" className={`ops-kpi${t.lowStock ? " alert" : ""}`}>
              <span>Items low on stock · {t.currency} venues</span>
              <strong>
                <CountUp value={t.lowStock} format={(n) => String(Math.round(n))} />
              </strong>
            </Reveal>,
          ])
        )}
      </div>
      <div className="ops-chips ops-group-pages" role="tablist" aria-label="Group pages">
        {pages.map(([id, label]) => (
          <button key={id} type="button" role="tab" aria-selected={page === id} aria-pressed={page === id} onClick={() => setPage(id)}>
            {label}
          </button>
        ))}
      </div>
      {studioPagesIds.has(page) && (
        <>
          <div className="ops-group-studio-bar">
            {currencies.length > 1 ? (
              <div className="ops-chips" role="group" aria-label="Currency">
                {currencies.map((c) => (
                  <button key={c} type="button" aria-pressed={cur === c} onClick={() => setPicked(c)}>
                    {c}
                  </button>
                ))}
              </div>
            ) : null}
            <small>
              Amounts in {cur}
              {currencies.length > 1 ? "; Studio shows one currency at a time and never adds two together." : "."}
              {owner && !judges ? " Your layout is saved for you." : judges ? " Rearrange freely: the demo café never saves a layout." : ""}
            </small>
          </div>
          <StudioCanvas
            key={`${cur}-${money}`}
            label={`${group.name}: ${pages.find(([id]) => id === page)?.[1] ?? "Portfolio"}`}
            sources={sources}
            initialState={initial}
            page={page}
            editable={owner || judges}
            height={780}
            layoutKey={{ api, scope: `group:${group.id}`, section: "group", save: owner && !judges }}
            ai={owner || judges ? assistant : undefined}
          />
        </>
      )}
      {page === "portfolio" && <VenuesGrid venues={venues} loading={!overview.data && !overview.error} />}
      {page === "compare" && <CompareGrid rows={compare.data} loading={!compare.data && !compare.error} error={compare.error} />}
      {page === "money" && money && (
        <MoneyGrids
          ledger={ledger.data?.rows}
          truncated={ledger.data?.truncated ?? false}
          payables={payables.data}
          error={ledger.error || payables.error}
        />
      )}
      {page === "templates" && <Templates api={api} group={group} owner={owner} />}
      {page === "transfers" && <Transfers api={api} tenant={tenant} group={group} revision={revision} />}
      {page === "portfolio" && owner && !judges && <Invite api={api} tenant={tenant} group={group} onDone={onChanged} />}
    </div>
  );
}

function VenuesGrid({ venues, loading }: { venues?: VenueFigures[]; loading: boolean }) {
  const columns = useMemo<ColDef<VenueFigures>[]>(
    () => [
      { field: "name", headerName: "Venue", minWidth: 180, cellClass: "ops-cell-strong" },
      { field: "currency", headerName: "Currency", minWidth: 100, flex: 0.5 },
      moneyCol<VenueFigures>("Paid sales", "paidSalesMinor", (v) => v.currency),
      countCol<VenueFigures>("Paid orders", "orders"),
      moneyCol<VenueFigures>("Average ticket", "averageTicketMinor", (v) => v.currency, { total: false }),
      moneyCol<VenueFigures>("Refunds", "refundsMinor", (v) => v.currency),
      moneyCol<VenueFigures>("Paid out", "payoutsMinor", (v) => v.currency),
      countCol<VenueFigures>("Bills due", "billsDue"),
      moneyCol<VenueFigures>("Due in 7 days", "billsDueMinor", (v) => v.currency),
      countCol<VenueFigures>("Low stock", "lowStock"),
      countCol<VenueFigures>("Deliveries out", "liveDeliveries"),
    ],
    [],
  );
  return (
    <RaystoGrid
      label="Venues"
      rows={venues}
      columns={columns}
      loading={loading}
      getRowId={(p) => String(p.data.restaurantId)}
      csvName="group-venues"
      emptyText="No venue in this group yet."
    />
  );
}

function CompareGrid({ rows, loading, error }: { rows?: CompareRow[]; loading: boolean; error?: string }) {
  const columns = useMemo<ColDef<CompareRow>[]>(
    () => [
      dateCol<CompareRow>("Day", "date", { dayOnly: true, sort: "desc" }),
      { field: "venue", headerName: "Venue", minWidth: 180 },
      moneyCol<CompareRow>("Paid sales", "salesMinor", (r) => r.currency),
      countCol<CompareRow>("Paid orders", "orders"),
    ],
    [],
  );
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <RaystoGrid
        label="Sales by venue and day"
        rows={rows}
        columns={columns}
        loading={loading}
        getRowId={(p) => `${p.data.restaurantId}:${p.data.date}`}
        csvName="group-sales-by-day"
        emptyText="No paid orders in this period."
      />
    </>
  );
}

function MoneyGrids({
  ledger,
  truncated,
  payables,
  error,
}: {
  ledger?: LedgerLine[];
  truncated: boolean;
  payables?: PayableRow[];
  error?: string;
}) {
  const billColumns = useMemo<ColDef<PayableRow>[]>(
    () => [
      { field: "vendor", headerName: "Supplier or biller", minWidth: 180, cellClass: "ops-cell-strong" },
      { field: "venue", headerName: "Venue", minWidth: 160 },
      { field: "category", headerName: "Category", minWidth: 130 },
      moneyCol<PayableRow>("Amount", "amountMinor", (b) => b.currency),
      dateCol<PayableRow>("Due", "dueAt", { dayOnly: true, sort: "asc" }),
      countCol<PayableRow>("Days overdue", "daysOverdue", { total: false }),
      { headerName: "Aging", valueGetter: (p) => (p.data ? agingBucket(p.data.daysOverdue) : ""), minWidth: 130 },
      statusCol<PayableRow>("State", "state"),
    ],
    [],
  );
  const lineColumns = useMemo<ColDef<LedgerLine>[]>(
    () => [
      dateCol<LedgerLine>("Date", "date", { dayOnly: true, sort: "desc" }),
      { field: "venue", headerName: "Venue", minWidth: 150 },
      { headerName: "Account", valueGetter: (p) => (p.data ? `${p.data.account} ${p.data.accountName}` : ""), minWidth: 200 },
      moneyCol<LedgerLine>("Debit", "debitMinor", (l) => l.currency),
      moneyCol<LedgerLine>("Credit", "creditMinor", (l) => l.currency),
      { field: "memo", headerName: "Memo", minWidth: 200, flex: 1.5, tooltipField: "memo" },
      { headerName: "From", valueGetter: (p) => (p.data?.source?.kind ? `${p.data.source.kind}${p.data.source.estimated ? " (fee estimated)" : ""}` : ""), minWidth: 140 },
    ],
    [],
  );
  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <h3 className="ops-group-sub">Bills to pay across the group</h3>
      <RaystoGrid
        label="Bills to pay"
        rows={payables}
        columns={billColumns}
        loading={!payables && !error}
        getRowId={(p) => `${p.data.restaurantId}:${p.data.id}`}
        csvName="group-payables"
        emptyText="No unpaid bills. Bills are recorded and paid in each venue's Accountant."
      />
      <h3 className="ops-group-sub">Journal lines</h3>
      <RaystoGrid
        label="Journal lines"
        rows={ledger}
        columns={lineColumns}
        loading={!ledger && !error}
        csvName="group-journal"
        tooltipShowDelay={300}
        emptyText="No journal lines in this period."
      />
      <small className="ops-note">
        Each venue&rsquo;s journal is derived from its own orders, PayPal captures, refunds, payouts and bills; debits equal credits per
        venue and currency.{truncated ? " Only the newest 2,000 lines are shown; export a shorter period for the rest." : ""}
      </small>
    </>
  );
}

function Templates({ api, group, owner }: { api: ConnectedApi; group: GroupRow; owner: boolean }) {
  const list = useLoad(
    () => api.query<{ rows: TemplateRow[] }>("group.templates", { groupId: group.id }).then((r) => r.rows),
    [api, group.id],
  );
  const [name, setName] = useState("");
  const [category, setCategory] = useState("Group specials");
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const parsed = parseTemplateLines(text);
  async function save(e: FormEvent) {
    e.preventDefault();
    if (parsed.errors.length || parsed.items.length === 0) return;
    setBusy(true);
    setNote("");
    try {
      await api.command("group.template.save", noVenue, {
        groupId: group.id,
        name: name.trim(),
        items: parsed.items.map((i) => ({ ...i, category: category.trim() || "Group specials" })),
      });
      setName("");
      setText("");
      setNote("Template saved. Push it when every venue should see it.");
      list.reload();
    } catch (err) {
      setNote(errorText(err));
    } finally {
      setBusy(false);
    }
  }
  async function push(t: TemplateRow) {
    setBusy(true);
    setNote("");
    try {
      const r = await api.command<{ drafts?: unknown[] }>("group.template.push", noVenue, { groupId: group.id, templateId: t.id });
      const n = r.drafts?.length ?? group.venues.length;
      setNote(`“${t.name}” is now a proposed menu draft in ${n} venue${n === 1 ? "" : "s"}. Each venue's manager reviews and publishes it.`);
    } catch (err) {
      setNote(errorText(err));
    } finally {
      setBusy(false);
    }
  }
  return (
    <section className="ops-panel ops-group-panel" aria-labelledby="group-templates">
      <h3 id="group-templates">Menu templates</h3>
      <p>A template is a set of dishes for every venue. Pushing it never changes a live menu: each venue gets a draft its manager publishes.</p>
      {list.error && (
        <p className="ops-error" role="alert">
          {list.error}
        </p>
      )}
      {!list.data ? (
        <p className="ops-note" role="status">
          Loading the templates…
        </p>
      ) : list.data.length === 0 ? (
        <p className="ops-quiet-note">No template yet.{owner ? " Write the first one below." : " The group's owner writes them."}</p>
      ) : (
        <ul className="ops-group-templates">
          {list.data.map((t) => (
            <li key={t.id}>
              <div>
                <strong>{t.name}</strong>
                <small>
                  {t.items.length} dish{t.items.length === 1 ? "" : "es"} · updated {new Date(t.updatedAt).toLocaleDateString()}
                </small>
                <span className="ops-group-dishes">
                  {t.items
                    .slice(0, 4)
                    .map((i) => i.name)
                    .join(", ")}
                  {t.items.length > 4 ? "…" : ""}
                </span>
              </div>
              {owner && (
                <button type="button" onClick={() => void push(t)} disabled={busy}>
                  Push to every venue
                </button>
              )}
            </li>
          ))}
        </ul>
      )}
      {owner && (
        <form className="ops-group-form wide" onSubmit={(e) => void save(e)}>
          <label>
            Template name
            <input value={name} onChange={(e) => setName(e.target.value)} maxLength={80} required placeholder="Winter specials" />
          </label>
          <label>
            Menu category for these dishes
            <input value={category} onChange={(e) => setCategory(e.target.value)} maxLength={80} />
          </label>
          <label className="span">
            Dishes, one per line: name, price, optional description
            <textarea
              rows={5}
              value={text}
              onChange={(e) => setText(e.target.value)}
              placeholder={"Mushroom soup, 7.50, with thyme cream\nLemon tart, 6.00"}
            />
          </label>
          {text && parsed.errors.length > 0 && (
            <ul className="ops-error span" role="alert">
              {parsed.errors.slice(0, 4).map((e) => (
                <li key={e}>{e}</li>
              ))}
            </ul>
          )}
          <button className="ops-primary" type="submit" disabled={busy || !name.trim() || parsed.items.length === 0 || parsed.errors.length > 0}>
            Save template ({parsed.items.length} dish{parsed.items.length === 1 ? "" : "es"})
          </button>
        </form>
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </section>
  );
}

interface StockRow {
  id: number;
  name: string;
  unit: string;
  quantity: number;
  low: boolean;
}

function Transfers({ api, tenant, group, revision }: { api: ConnectedApi; tenant: number; group: GroupRow; revision: string }) {
  const here = group.venues.find((v) => v.restaurantId === tenant);
  const others = group.venues.filter((v) => v.restaurantId !== tenant);
  const stock = useLoad(
    () => api.query<{ rows: StockRow[] }>("stock", { restaurantId: tenant, limit: 200 }).then((r) => r.rows),
    [api, tenant, revision],
  );
  const [to, setTo] = useState<number>(others[0]?.restaurantId ?? 0);
  const [item, setItem] = useState<number>(0);
  const [quantity, setQuantity] = useState("");
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const chosen = stock.data?.find((s) => s.id === item) ?? stock.data?.[0];
  const amount = Number(quantity);
  const valid = chosen && to && Number.isFinite(amount) && amount > 0 && amount <= chosen.quantity;
  const stockColumns = useMemo<ColDef<StockRow>[]>(
    () => [
      { field: "name", headerName: "Item", minWidth: 180, cellClass: "ops-cell-strong" },
      countCol<StockRow>("On hand", "quantity", { total: false, format: (n) => String(Math.round(n * 1000) / 1000) }),
      { field: "unit", headerName: "Unit", minWidth: 90, flex: 0.5 },
      statusCol<StockRow>("Level", (r) => (r.low ? "low" : "ok"), { label: (v) => (v === "low" ? "Low" : "Enough") }),
      idCol<StockRow>("Item id", "id", { prefix: "#" }),
    ],
    [],
  );
  async function send(e: FormEvent) {
    e.preventDefault();
    if (!valid || !chosen) return;
    setBusy(true);
    setNote("");
    try {
      await api.command("stock.transfer", tenant, { toRestaurantId: to, stockItemId: chosen.id, quantity: amount });
      const dest = others.find((v) => v.restaurantId === to)?.name ?? "the other venue";
      setNote(`Moved ${amount} ${chosen.unit} of ${chosen.name} to ${dest}. Both venues' stock records show the transfer.`);
      setQuantity("");
      stock.reload();
    } catch (err) {
      setNote(errorText(err));
    } finally {
      setBusy(false);
    }
  }
  if (!here)
    return (
      <p className="ops-quiet-note">
        Open one of the group&rsquo;s venues to move its stock; transfers start from the venue that gives.
      </p>
    );
  return (
    <section className="ops-panel ops-group-panel" aria-labelledby="group-transfers">
      <h3 id="group-transfers">Move stock from {here.name}</h3>
      <p>A transfer takes stock off this venue and adds it to another venue of the group, as two movements with one transfer id. You need a manager role in both.</p>
      {others.length === 0 ? (
        <p className="ops-quiet-note">There is no other venue in this group to send stock to.</p>
      ) : (
        <form className="ops-group-form wide" onSubmit={(e) => void send(e)}>
          <label>
            Item
            <select value={chosen?.id ?? ""} onChange={(e) => setItem(Number(e.target.value))} disabled={!stock.data?.length}>
              {(stock.data ?? []).map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name} ({s.quantity} {s.unit})
                </option>
              ))}
            </select>
          </label>
          <label>
            Quantity{chosen ? ` (${chosen.unit})` : ""}
            <input inputMode="decimal" value={quantity} onChange={(e) => setQuantity(e.target.value.replace(",", "."))} required />
          </label>
          <label>
            To
            <select value={to} onChange={(e) => setTo(Number(e.target.value))}>
              {others.map((v) => (
                <option key={v.restaurantId} value={v.restaurantId}>
                  {v.name}
                </option>
              ))}
            </select>
          </label>
          <button className="ops-primary" type="submit" disabled={busy || !valid}>
            <Icon name="swap" size={18} /> Move stock
          </button>
          {chosen && quantity && amount > chosen.quantity && (
            <p className="ops-error span" role="alert">
              {here.name} has only {chosen.quantity} {chosen.unit}.
            </p>
          )}
        </form>
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
      <RaystoGrid
        label={`${here.name} stock`}
        rows={stock.data}
        columns={stockColumns}
        loading={!stock.data && !stock.error}
        getRowId={(p) => String(p.data.id)}
        csvName="stock"
        totals={false}
        emptyText={stock.error ? stock.error : "No stock items recorded at this venue yet."}
      />
    </section>
  );
}

function Invite({ api, tenant, group, onDone }: { api: ConnectedApi; tenant: number; group: GroupRow; onDone: () => void }) {
  const known = isJudgeVenue(tenant) ? judge.password : "";
  const [email, setEmail] = useState("");
  const [role, setRole] = useState<"accountant" | "areaManager">("accountant");
  const [asking, setAsking] = useState(false);
  const [byPassword, setByPassword] = useState(true);
  const [password, setPassword] = useState(known);
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  async function start(e: FormEvent) {
    e.preventDefault();
    setByPassword(await usesPassword());
    setAsking(true);
  }
  async function confirm(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setNote("");
    try {
      await stepUp(api, tenant, byPassword ? password : undefined);
      await api.command("group.member.invite", noVenue, { groupId: group.id, email: email.trim(), role });
      setNote(
        `Invitation sent to ${email.trim()}. ${role === "accountant" ? "An accountant reads every venue's books once they accept." : "An area manager reads the group's sales and stock."} You can revoke it later.`,
      );
      setEmail("");
      setAsking(false);
      setPassword(known);
      onDone();
    } catch (err) {
      setNote(errorText(err));
    } finally {
      setBusy(false);
    }
  }
  return (
    <section className="ops-panel ops-group-panel" aria-labelledby="group-invite">
      <h3 id="group-invite">Invite someone to the group</h3>
      <p>An accountant gets the books of every venue; an area manager gets the group&rsquo;s figures. Neither can pay, refund or change a menu without a venue role.</p>
      {asking ? (
        <form className="ops-group-form" onSubmit={(e) => void confirm(e)}>
          {byPassword && (
            <label>
              Your password, to confirm it is you
              <input type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required />
            </label>
          )}
          <button className="ops-primary" type="submit" disabled={busy}>
            {busy ? "Sending…" : byPassword ? "Confirm and invite" : "Confirm with Google and invite"}
          </button>
          <button type="button" className="ops-quiet" onClick={() => setAsking(false)} disabled={busy}>
            Cancel
          </button>
        </form>
      ) : (
        <form className="ops-group-form wide" onSubmit={(e) => void start(e)}>
          <label>
            Email
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="off" />
          </label>
          <label>
            Role
            <select value={role} onChange={(e) => setRole(e.target.value as "accountant" | "areaManager")}>
              <option value="accountant">Accountant</option>
              <option value="areaManager">Area manager</option>
            </select>
          </label>
          <button type="submit" disabled={!email.trim()}>
            Invite (identity check)
          </button>
        </form>
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </section>
  );
}
