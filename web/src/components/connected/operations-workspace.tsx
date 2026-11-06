"use client";
import { WorkspaceStateContext } from "@/lib/connected/workspace-state";
import { ReadProgress } from "./read-progress";
import {
  updateWorkspaceRoute,
  workspaceRouteEvent,
} from "@/lib/connected/workspace-location";
import { WorkspaceDraftBoundary } from "./workspace-drafts";
import { confirmDiscard } from "@/lib/connected/confirm-discard";
import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from "react";
import { createPortal } from "react-dom";
import {
  AllCommunityModule,
  ModuleRegistry,
  type ColDef,
  type ValueFormatterParams,
} from "ag-grid-community";
import {
  AgStudio,
  createWidgets,
  type AgWidgetDefinition,
} from "ag-studio-react";
import {
  AgStudioAiModule,
  AgStudioLicenseManager,
  studioTheme,
  type AgDefaultRegistry,
  type AgReportState,
  type AgStudioApi,
} from "ag-studio";
import { ApiFailure, ConnectedApi } from "@/lib/connected/api";
import { RaystoHarness } from "@/lib/connected/studio-harness";
import {
  currency,
  type AttentionFilter,
  type Json,
  type OperationsSnapshot,
  type TableRow,
} from "@/lib/connected/contracts";
import { RoomPanel } from "./room-panel";
import { Icon } from "./icons";
import {
  OrdersSection,
  PaymentsSection,
  type Section,
  AgentsSection,
} from "./business-sections";
import { TrySection } from "./try-section";
import { MoneySection, TeamSection } from "./backoffice-sections";
import { GroupSection } from "./group-section";
import { AccountantSection } from "./accountant-section";
import { FinanceSection } from "./finance-section";
import { DispatchSection } from "./dispatch-section";
import { SuppliesSection } from "./supplies-section";
import { OverviewSection } from "./overview-section";
import { FadeThrough, NavIndicator } from "./m3";
import { RaystoGrid } from "./raysto-grid";
import {
  boolCol,
  countCol,
  idCol,
  moneyCol,
  statusCol,
  words as wordsOf,
} from "@/lib/connected/grid-columns";
import { isJudgeVenue } from "@/lib/connected/judge";
import type { IconName } from "./icons";

type Place = Section | "floor" | "try";
/**
 * The console's sections, in navigation order. The scripted Try Raysto
 * demos are not in the navigation: the demo café opens `?section=try` by
 * URL (tool/judge_path_qa.cjs and our own checks use it).
 */
const places: readonly (readonly [Place, string, IconName])[] = [
  ...(process.env.NEXT_PUBLIC_RAYSTO_FINANCE_017 === "on"
    ? [
        ["overview", "Today", "overview"] as const,
        ["finance", "Sales and margins", "ledger"] as const,
        ["supplies", "Bills and stock", "supplies"] as const,
        ["team", "Team", "team"] as const,
        ["money", "Money", "money"] as const,
      ]
    : [["overview", "Overview", "overview"] as const]),
  ["orders", "Orders", "orders"],
  ["payments", "Payments", "payments"],
  ["agents", "Agents", "agents"],
  ...(process.env.NEXT_PUBLIC_RAYSTO_FINANCE_017 === "on"
    ? []
    : [
        ["money", "Money", "money"] as const,
        ["team", "Team", "team"] as const,
      ]),
  // 0.16: accountant, delivery dispatch, supplies, and the franchise view.
  ["accountant", "Accountant", "ledger"],
  ["dispatch", "Dispatch", "dispatch"],
  ...(process.env.NEXT_PUBLIC_RAYSTO_FINANCE_017 === "on"
    ? []
    : [["supplies", "Supplies", "supplies"] as const]),
  ["group", "Group", "group"],
  ["floor", "Floor", "floor"],
];
const purpose: Partial<Record<Place, string>> = {
  supplies: "Review bills and deliveries, then check what needs replenishing.",
  team: "Plan shifts, inspect worked hours and review the wage inputs.",
  money: "Review obligations, payment outcomes and reconciliation.",
  orders: "Work active tickets here. Completed orders stay in history.",
  payments:
    "Trace collections, refunds and unresolved attempts to their business records.",
  agents: "Review proposed actions, then inspect what actually ran.",
  accountant:
    "Check the accounting basis and follow each figure back to its records.",
  dispatch:
    "Assign waiting deliveries and inspect offers, drivers and partner events.",
  group:
    "Compare venues within each currency, with the venue scope kept visible.",
  floor: "Attend the room, service requests and unsettled tables.",
};
const tryPlace = ["try", "Try Raysto", "play"] as const;

/**
 * The section to open first: `?section=` when it names one (Try only on the
 * demo café), else the Overview, where the AI Action Inbox waits.
 */
function firstPlace(judges: boolean): Place {
  if (typeof window === "undefined") return "overview";
  const asked = new URLSearchParams(window.location.search).get("section");
  if (asked === "try") return judges ? "try" : "overview";
  return places.some(([id]) => id === asked) ? (asked as Place) : "overview";
}
/**
 * Sections whose content holds an AG Grid or AG Studio: they change with a
 * plain fade, never a scale, because a transform on their ancestors breaks
 * the grid's measurements. The Overview holds a 30-day AG Studio.
 */
const gridHeavy = new Set<Place>([
  "finance",
  "overview",
  "orders",
  "payments",
  "agents",
  "money",
  "team",
  "floor",
  "group",
  "accountant",
  "dispatch",
  "supplies",
]);

ModuleRegistry.registerModules([AllCommunityModule]);
// AG Studio can be switched off at build time (for example if its evaluation
// licence lapses); the Floor then shows its three tiles as plain cards.
const studioOn = process.env.NEXT_PUBLIC_RAYSTO_STUDIO !== "off";
const license = process.env.NEXT_PUBLIC_AG_STUDIO_LICENSE;
if (license) AgStudioLicenseManager.setLicenseKey(license);
const raystoTheme = studioTheme.withParams({
  accentColor: "#173f35",
  backgroundColor: "#ffffff",
  foregroundColor: "#173e34",
  fontFamily: "var(--font-jakarta)",
  borderRadius: 12,
});
type TileId = "raystoBalance" | "raystoService" | "raystoExceptions";
type TileDefinition<T extends TileId> = AgWidgetDefinition<
  T,
  { type: T; dataMapping: Record<string, never>; format?: {} }
>;
interface Registry extends Omit<AgDefaultRegistry, "widgets"> {
  widgets: readonly [
    ...AgDefaultRegistry["widgets"],
    TileDefinition<"raystoBalance">,
    TileDefinition<"raystoService">,
    TileDefinition<"raystoExceptions">,
  ];
}
const Context = createContext<{
  snapshot: OperationsSnapshot;
  filter: AttentionFilter;
  setFilter: (filter: AttentionFilter) => void;
} | null>(null);
function AttentionTile({ widgetType }: { widgetType: string }) {
  const context = useContext(Context);
  if (!context) return null;
  const { snapshot, setFilter } = context;
  const mode =
    widgetType === "raystoBalance"
      ? "balance"
      : widgetType === "raystoService"
        ? "service"
        : "exceptions";
  const value =
    mode === "balance"
      ? currency(snapshot.outstandingMinor, snapshot.currency)
      : mode === "service"
        ? snapshot.rows.reduce((sum, row) => sum + row.serviceCount, 0)
        : snapshot.rows.filter((row) => row.paymentException).length;
  return (
    <button
      className={`ops-metric ${mode}`}
      onClick={() =>
        setFilter(
          mode === "exceptions"
            ? "paymentExceptions"
            : mode === "balance"
              ? "billRequested"
              : "all",
        )
      }
    >
      <span>
        {mode === "balance"
          ? "Still at the table"
          : mode === "service"
            ? "A little attention"
            : "Payments to review"}
      </span>
      <strong>{value}</strong>
      <small>
        {mode === "balance"
          ? "Outstanding balance · current view"
          : mode === "service"
            ? "Open service requests · current view"
            : "Unresolved outcomes · current view"}
      </small>
    </button>
  );
}
// Thumbnails in AG Studio's widget menu, drawn like the console's icons.
const tileIcon = (path: string) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#173d33" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">${path}</svg>`;
const tileIcons: Record<TileId, string> = {
  raystoBalance: tileIcon(
    '<path d="M6 3h12v18l-3-2-3 2-3-2-3 2z"/><path d="M9 8h6M9 12h6"/>',
  ),
  raystoService: tileIcon(
    '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 21h4"/>',
  ),
  raystoExceptions: tileIcon(
    '<path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17h.01"/>',
  ),
};
function createTile<T extends TileId>(id: T): TileDefinition<T> {
  return {
    id,
    // Short words: the widget menu's cells are narrow.
    label:
      id === "raystoBalance"
        ? "Open bills"
        : id === "raystoService"
          ? "Service"
          : "Payment issues",
    icon: tileIcons[id],
    comp: AttentionTile,
    defaultSize: { width: 320, height: 180 },
    minSize: { width: 220, height: 140 },
    formatShape: ({ api }) =>
      api.defineAiCommand((s) => ({
        input: s.object({}),
        execute: () => ({ success: true as const, value: {} }),
      })).shape,
    form: (params) => params.createDefaults({}),
    ai: {
      description:
        "Live Raysto restaurant metric, scoped to the current authorized restaurant and shared attention filter. No financial actions.",
    },
  };
}
const tiles = createWidgets<Registry>({
  additionalTypes: [
    createTile("raystoBalance"),
    createTile("raystoService"),
    createTile("raystoExceptions"),
  ],
  menu: [
    {
      label: "Raysto hospitality",
      widgetIds: ["raystoBalance", "raystoService", "raystoExceptions"],
    },
  ],
});
const defaultLayout: AgReportState<Registry> = {
  pages: [
    {
      id: "restaurant",
      widgets: {
        balance: { type: "raystoBalance", dataMapping: {} },
        service: { type: "raystoService", dataMapping: {} },
        exceptions: { type: "raystoExceptions", dataMapping: {} },
      },
      // Two across and one below, so all three fit beside the AI Assistant.
      widgetLayout: {
        balance: { xTrack: 0, yTrack: 0, xSpan: 8, ySpan: 8 },
        service: { xTrack: 8, yTrack: 0, xSpan: 8, ySpan: 8 },
        exceptions: { xTrack: 0, yTrack: 8, xSpan: 8, ySpan: 8 },
      },
    },
  ],
  selectedPageId: "restaurant",
  panels: {
    ai: { collapsed: false },
    // Compose opens by itself when a widget is selected.
    edit: { collapsed: true },
    data: { collapsed: true },
    filters: { collapsed: true },
  },
};
const tableColumns: ColDef<TableRow>[] = [
  {
    field: "label",
    headerName: "Table",
    minWidth: 110,
    cellClass: "ops-cell-strong",
  },
  { field: "zone", headerName: "Zone", minWidth: 110 },
  countCol<TableRow>("Guests", "guests", { minWidth: 100, flex: 0.6 }),
  statusCol<TableRow>("Status", "status", { minWidth: 140 }),
  moneyCol<TableRow>("Outstanding", "outstandingMinor", (r) => r.currency),
  countCol<TableRow>("Requests", "serviceCount", { minWidth: 110, flex: 0.6 }),
  boolCol<TableRow>("Bill requested", "billRequested", {
    labels: ["Bill requested", "No bill asked"],
    minWidth: 140,
  }),
];

export function OperationsWorkspace({
  api,
  tenant,
  onDirty,
  navTarget,
  drawerNavTarget,
  appBarLead,
  person,
  role,
}: {
  api: ConnectedApi;
  tenant: number;
  role?: string;
  onDirty?: (dirty: boolean) => void;
  /** The console sidebar (drawer or rail); the sections render there when it exists. */
  navTarget?: HTMLElement | null;
  /** The phone's modal drawer, while it is open; the sections render there too. */
  drawerNavTarget?: HTMLElement | null;
  /** What the shell puts at the start of the top app bar (menu button, venue). */
  appBarLead?: ReactNode;
  /** The signed-in person, for the Overview's greeting. */
  person?: { name?: string | null; email?: string | null };
}) {
  const [snapshot, setSnapshot] = useState<OperationsSnapshot>();
  const [filter, setFilter] = useState<AttentionFilter>("all");
  const [selected, setSelected] = useState<number>();
  const [roomId, setRoomId] = useState<number>();
  const [orders, setOrders] = useState<Json[]>([]),
    [payments, setPayments] = useState<Json[]>([]);
  const [error, setError] = useState(""),
    [delivery, setDelivery] = useState("Connecting");
  const [tab, setTab] = useState("tables");
  const [floorAnalysis, setFloorAnalysis] = useState(false);
  const [floorPanel, setFloorPanel] = useState<"ai" | "edit" | undefined>();
  // The whole business first: every café, the demo one included, opens on
  // the Overview and its AI Action Inbox.
  const judges = isJudgeVenue(tenant);
  const [section, setSection] = useState<Place>(() => firstPlace(judges));
  const [focus, setFocus] = useState<string>();
  const [layout, setLayout] = useState<AgReportState<Registry>>();
  const [layoutVersion, setLayoutVersion] = useState(0);
  const [saving, setSaving] = useState(false);
  const state = useRef<AgReportState<Registry>>(defaultLayout);
  const live = useRef(true);
  const filterRef = useRef(filter);
  filterRef.current = filter;
  const selection = useRef(0);
  const roomDraft = useRef(false);
  const uiScope = useMemo(() => ({ api, tenant, role }), [api, tenant, role]);
  const draftSources = useRef(new Set<string>());
  function draftChanged(source: string, dirty: boolean) {
    if (dirty) draftSources.current.add(source);
    else draftSources.current.delete(source);
    roomDraft.current = draftSources.current.size > 0;
    onDirty?.(roomDraft.current);
  }

  const sectionScroll = useRef(new Map<string, number>());
  const previousSection = useRef(section);
  useEffect(() => {
    if (previousSection.current === section) return;
    sectionScroll.current.set(previousSection.current, window.scrollY);
    previousSection.current = section;
    const frame = requestAnimationFrame(() => {
      document
        .getElementById("workspace-heading")
        ?.focus({ preventScroll: true });
      window.scrollTo({
        top: sectionScroll.current.get(section) ?? 0,
        behavior: "instant",
      });
    });
    return () => cancelAnimationFrame(frame);
  }, [section]);
  const routeRef = useRef(
    typeof window === "undefined" ? "" : window.location.href,
  );
  useEffect(() => {
    const sync = (event: Event) => {
      const apply = () => {
        const next = firstPlace(judges);
        if (next !== section) {
          setFocus(undefined);
          setSection(next);
        }
        routeRef.current = window.location.href;
      };
      if (roomDraft.current && window.location.href !== routeRef.current) {
        event.stopImmediatePropagation();
        const destination = window.location.href;
        void confirmDiscard(
          "Keep editing your current draft, or discard it before leaving.",
        ).then((discard) => {
          if (!discard) {
            window.history.replaceState(null, "", routeRef.current);
            return;
          }
          roomDraft.current = false;
          onDirty?.(false);
          draftSources.current.clear();
          window.dispatchEvent(new Event("raysto:discard-drafts"));
          window.history.replaceState(null, "", destination);
          apply();
          window.dispatchEvent(new Event(workspaceRouteEvent));
        });
        return;
      }
      apply();
    };
    window.addEventListener("popstate", sync, true);
    window.addEventListener(workspaceRouteEvent, sync, true);
    return () => {
      window.removeEventListener("popstate", sync, true);
      window.removeEventListener(workspaceRouteEvent, sync, true);
    };
  }, [section, judges, onDirty]);
  async function navigate(next: Place, targetFocus?: string) {
    const changing =
      next !== section || (targetFocus !== undefined && targetFocus !== focus);
    if (!changing) return;
    if (
      roomDraft.current &&
      !(await confirmDiscard(
        "Keep editing your current draft, or discard it before leaving.",
      ))
    )
      return;
    if (roomDraft.current) {
      draftSources.current.clear();
      window.dispatchEvent(new Event("raysto:discard-drafts"));
    }
    roomDraft.current = false;
    onDirty?.(false);
    setFocus(targetFocus);
    setSection(next);
    updateWorkspaceRoute({
      section: next,
      ...(targetFocus ? { tab: targetFocus } : {}),
    });
    routeRef.current = window.location.href;
  }
  useEffect(() => {
    const guard = (event: BeforeUnloadEvent) => {
      if (roomDraft.current) {
        event.preventDefault();
        event.returnValue = "";
      }
    };
    window.addEventListener("beforeunload", guard);
    return () => window.removeEventListener("beforeunload", guard);
  }, []);
  const restored = useRef(false);
  const pendingRestore = useRef<Json | null>(null);
  const refreshRef = useRef<() => Promise<void>>(async () => {});
  const focusRef = useRef<
    (
      filter: AttentionFilter,
      view?: "overview" | "payments" | "service",
    ) => void
  >((f) => setFilter(f));
  const harness = useMemo(
    () =>
      new RaystoHarness(api, tenant, (f, view) => focusRef.current(f, view)),
    [api, tenant],
  );
  function bindStudio(studio: AgStudioApi) {
    const command = studio.defineAiCommand((s) => ({
      input: s.object({
        filter: s.enum(["all", "billRequested", "paymentExceptions"] as const),
        view: s.enum(["overview", "payments", "service"] as const).optional(),
      }),
      execute: ({ filter: next, view }) => {
        setFilter(next);
        if (view) {
          const current = studio.getState();
          const ordered =
            view === "payments"
              ? ["exceptions", "balance", "service"]
              : view === "service"
                ? ["service", "balance", "exceptions"]
                : ["balance", "service", "exceptions"];
          const page = defaultLayout.pages![0];
          studio.setState({
            ...current,
            pages: [
              {
                ...page,
                widgetLayout: Object.fromEntries(
                  ordered.map((id, index) => [
                    id,
                    { xTrack: index * 8, yTrack: 0, xSpan: 8, ySpan: 8 },
                  ]),
                ),
              },
            ] as AgReportState["pages"],
          });
        }
        return { success: true as const, value: { filter: next, view } };
      },
    }));
    // AG Studio validates the presentation command before applying the server's
    // authorized result. It cannot issue order, cash, capture or refund commands.
    const tool = studio.defineAiTool({
      name: "raysto_focus_workspace",
      description:
        "Apply an authorized Raysto attention filter and optional widget arrangement.",
      command,
      result: (value) => ({ response: value }),
    });
    focusRef.current = (f, view) => {
      void tool
        .execute?.(
          {
            toolCallId: crypto.randomUUID(),
            name: tool.name,
            args: { filter: f, ...(view ? { view } : {}) },
          },
          {
            signal: new AbortController().signal,
            run: { threadId: "operations", runId: crypto.randomUUID() },
            success: (response, data) => ({ success: true, response, data }),
            error: (messages) => ({
              success: false,
              issues: (Array.isArray(messages) ? messages : [messages]).map(
                (message) => ({ message }),
              ),
            }),
          },
        )
        .catch((e) => setError(String(e)));
    };
  }
  useEffect(() => {
    live.current = true;
    void harness.restore().catch((e) => setError(String(e)));
    return () => {
      live.current = false;
      harness.dispose();
    };
  }, [harness]);
  useEffect(() => {
    let active = true;
    const controller = new AbortController();
    let cursor = 0;
    let failures = 0;
    let timer: ReturnType<typeof setTimeout> | undefined;
    async function refresh() {
      try {
        const [next, o, p] = await Promise.all([
          api.query<OperationsSnapshot>(
            "operations.snapshot",
            { restaurantId: tenant, filter: filterRef.current },
            controller.signal,
          ),
          api.query<{ rows: Json[] }>(
            "orders",
            { restaurantId: tenant, staff: true, limit: 100 },
            controller.signal,
          ),
          api.query<{ rows: Json[] }>(
            "checkouts",
            { restaurantId: tenant, staff: true, limit: 100 },
            controller.signal,
          ),
        ]);
        if (!active || next.filter !== filterRef.current) return;
        if (!restored.current) {
          restored.current = true;
          pendingRestore.current = next.layout;
          const saved = next.layout?.filter;
          if (
            saved === "all" ||
            saved === "billRequested" ||
            saved === "paymentExceptions"
          ) {
            if (saved !== filterRef.current) {
              setFilter(saved);
              return;
            }
          }
        }
        if (pendingRestore.current) {
          const saved = pendingRestore.current;
          pendingRestore.current = null;
          if (
            ["tables", "orders", "services", "payments"].includes(
              String(saved.tab),
            )
          )
            setTab(String(saved.tab));
          // Saved IDs are preferences, never authority to read a table or room.
          const row = next.rows.find((row) => row.id === saved.selectedTableId);
          setSelected(row?.id);
          setRoomId(row?.roomId ?? undefined);
        }
        if (cursor === 0) cursor = next.eventCursor;
        setSnapshot(next);
        setOrders(o.rows);
        setPayments(p.rows);
        setError("");
        // Every judge starts from the same layout, whatever another saved.
        setLayout(
          (old) =>
            old ??
            (next.layout?.pages && !judges
              ? (next.layout as unknown as AgReportState<Registry>)
              : defaultLayout),
        );
        setLayoutVersion(next.layoutVersion);
      } catch (e) {
        if (active) {
          setError(String(e));
          if (
            e instanceof ApiFailure &&
            [
              "forbidden",
              "unauthorized",
              "session_changed",
              "account_disabled",
            ].includes(e.code)
          ) {
            setSnapshot(undefined);
            setOrders([]);
            setPayments([]);
            setRoomId(undefined);
            active = false;
            controller.abort();
          }
        }
      }
    }
    refreshRef.current = refresh;
    async function connect() {
      await refresh();
      while (active) {
        if (document.visibilityState === "hidden") {
          await new Promise((r) => setTimeout(r, 1000));
          continue;
        }
        try {
          await api.stream(
            `events?restaurantId=${tenant}&after=${cursor}`,
            controller.signal,
            (event) => {
              if (!active) return;
              setDelivery("Live");
              failures = 0;
              cursor = Number(event.cursor ?? cursor);
              if (event.kind === "snapshot.changed") {
                clearTimeout(timer);
                timer = setTimeout(() => void refresh(), 250);
              }
            },
          );
        } catch (e) {
          if (!active) return;
          failures++;
          setDelivery(failures >= 3 ? "Periodic refresh" : "Reconnecting");
          if (failures >= 3) await refresh();
          await new Promise((r) => setTimeout(r, failures >= 3 ? 10000 : 1500));
        }
      }
    }
    void connect();
    return () => {
      active = false;
      controller.abort();
      clearTimeout(timer);
    };
  }, [api, tenant]);
  useEffect(() => {
    void refreshRef.current();
  }, [filter]);
  const selectedTable = snapshot?.rows.find((row) => row.id === selected);
  async function openTable(row: TableRow) {
    if (
      roomDraft.current &&
      !(await confirmDiscard(
        "Discard the unsent room message and change tables?",
      ))
    )
      return;
    roomDraft.current = false;
    const revision = ++selection.current;
    setSelected(row.id);
    setRoomId(undefined);
    if (!row.visitId) return;
    try {
      const result = await api.command<{ roomId: number }>(
        "room.open",
        tenant,
        { visitId: row.visitId },
      );
      if (live.current && revision === selection.current)
        setRoomId(result.roomId);
    } catch (e) {
      if (live.current && revision === selection.current) setError(String(e));
    }
  }
  async function save() {
    if (saving) return;
    setSaving(true);
    try {
      const current = state.current;
      const result = await api.command<{ version: number }>(
        "operations.layout",
        tenant,
        {
          state: {
            pages: current.pages,
            selectedPageId: current.selectedPageId,
            panels: current.panels,
            filter,
            selectedTableId: selected,
            tab,
          },
        },
        { version: layoutVersion },
      );
      setLayoutVersion(result.version);
    } catch (e) {
      setError(String(e));
    } finally {
      setSaving(false);
    }
  }
  const visits = new Set(snapshot?.rows.map((r) => r.visitId).filter(Boolean));
  const inView = (row: Json) =>
    (filter === "all" || visits.has(Number(row.visitId))) &&
    (!selectedTable || Number(row.visitId) === selectedTable.visitId);
  const services =
    snapshot?.rows
      .filter((row) => !selectedTable || row.id === selectedTable.id)
      .flatMap((row) =>
        row.services.map((service) => ({ ...service, table: row.label })),
      ) ?? [];
  const generalRows =
    tab === "orders"
      ? orders.filter(inView)
      : tab === "payments"
        ? payments.filter(inView)
        : services;
  // The floor's records, in the console's column kinds (grid-columns.ts).
  const venueCurrency = (r: Json) =>
    String(r.currency ?? snapshot?.currency ?? "USD");
  const serviceWords = (v: unknown) =>
    v === "dineIn" ? "Dine-in" : wordsOf(v);
  const genericColumns: ColDef<Json>[] =
    tab === "orders"
      ? [
          idCol<Json>("Order", "id", { prefix: "#" }),
          {
            field: "fulfillment",
            headerName: "Service",
            minWidth: 120,
            valueFormatter: (p: ValueFormatterParams<Json>) =>
              serviceWords(p.value),
          },
          statusCol<Json>("Status", "status"),
          statusCol<Json>("Payment", "paymentStatus"),
          moneyCol<Json>("Total", "totalMinor", venueCurrency),
        ]
      : tab === "payments"
        ? [
            idCol<Json>("Checkout", "id", { prefix: "#" }),
            statusCol<Json>("Payment status", "state"),
            moneyCol<Json>("Amount", "amountMinor", venueCurrency),
            {
              field: "currency",
              headerName: "Currency",
              minWidth: 100,
              flex: 0.5,
            },
          ]
        : [
            {
              field: "table",
              headerName: "Table",
              minWidth: 110,
              cellClass: "ops-cell-strong",
            },
            {
              field: "kind",
              headerName: "Request",
              minWidth: 130,
              valueFormatter: (p: ValueFormatterParams<Json>) =>
                wordsOf(p.value),
            },
            statusCol<Json>("Status", "status"),
          ];
  if (tab === "services")
    genericColumns.push({
      headerName: "Service",
      colId: "action",
      minWidth: 170,
      cellRenderer: (p: { data?: Json }) =>
        p.data && (
          <button
            onClick={() =>
              void api
                .command(
                  "service.transition",
                  tenant,
                  {
                    status:
                      p.data!.status === "sent" ? "acknowledged" : "completed",
                  },
                  { id: Number(p.data!.id), version: Number(p.data!.version) },
                )
                .then(() => refreshRef.current())
                .catch((e) => setError(String(e)))
            }
          >
            {p.data.status === "sent" ? "Acknowledge" : "Complete"}
          </button>
        ),
    });
  const ownerNavigation = process.env.NEXT_PUBLIC_RAYSTO_FINANCE_017 === "on";
  const title =
    [tryPlace, ...places].find(([id]) => id === section)?.[1] ?? "Overview";
  // One navigation, rendered into the sidebar (drawer or rail) and, while it
  // is open, the phone's modal drawer; each has its own sliding indicator.
  const renderNavItems = (items: typeof places, layoutId: string) =>
    items.map(([id, label, icon]) => (
      <button
        key={id}
        type="button"
        className="ops-nav-item"
        aria-current={section === id ? "page" : undefined}
        title={label}
        onClick={() => void navigate(id)}
      >
        <NavIndicator active={section === id} layoutId={layoutId} />
        <span className="ops-nav-icon">
          <Icon name={icon} size={20} />
        </span>
        <span className="ops-nav-label">{label}</span>
      </button>
    ));
  const renderNav = (layoutId: string) => (
    <nav className="ops-sections" aria-label="Console sections">
      {renderNavItems(ownerNavigation ? places.slice(0, 5) : places, layoutId)}
      {ownerNavigation && (
        <details open={places.slice(5).some(([id]) => id === section)}>
          <summary
            style={{ minHeight: 48, padding: "14px 16px", cursor: "pointer" }}
          >
            Restaurant operations
          </summary>
          {renderNavItems(places.slice(5), layoutId)}
        </details>
      )}
    </nav>
  );
  if (!snapshot || !layout)
    return (
      <section className="ops-empty">
        {!error && <span className="ops-spinner" aria-hidden="true" />}
        <p role="status">{error || "Opening the restaurant…"}</p>
        <button
          className="ops-secondary"
          onClick={() => void refreshRef.current()}
        >
          <Icon name="refresh" size={18} />
          Retry
        </button>
      </section>
    );
  return (
    <WorkspaceStateContext.Provider value={uiScope}>
      <Context.Provider value={{ snapshot, filter, setFilter }}>
        <section
          className="ops-workspace"
          id="workspace-content"
          tabIndex={-1}
          aria-label="Restaurant workspace"
        >
          <header className="ops-appbar">
            {appBarLead}
            <div className="ops-appbar-title">
              <span className="ops-appbar-venue">
                <span className="ops-eyebrow">{snapshot.name}</span>
                {judges && (
                  <span
                    className="ops-demo-badge"
                    title="A shared demo café: its records are sample data and its payments run in PayPal Sandbox."
                  >
                    Demo café
                    <span className="m3-sr">
                      : sample data, payments in PayPal Sandbox
                    </span>
                  </span>
                )}
              </span>
              <h1 id="workspace-heading" tabIndex={-1}>
                {title}
              </h1>
              {purpose[section] && (
                <p className="ops-section-purpose">{purpose[section]}</p>
              )}
            </div>
            <div className="ops-appbar-actions">
              <span
                className={`ops-live ${delivery === "Live" ? "on" : ""}`}
                role="status"
              >
                <i aria-hidden="true" />
                <span className="m3-sr">Live updates: </span>
                {delivery}
              </span>
              <button
                type="button"
                className="ops-secondary ops-appbar-refresh"
                aria-label="Refresh"
                onClick={() => void refreshRef.current()}
              >
                <Icon name="refresh" size={18} />
                <span aria-hidden="true">Refresh</span>
              </button>
              {section === "floor" && floorAnalysis && !judges && (
                <button
                  type="button"
                  className="ops-secondary"
                  onClick={() => void save()}
                  disabled={saving}
                >
                  <Icon name="save" size={18} />
                  {saving ? "Saving…" : "Save workspace"}
                </button>
              )}
            </div>
          </header>
          {error && (
            <p className="ops-error" role="alert">
              {error}
            </p>
          )}
          <ReadProgress />
          {navTarget && createPortal(renderNav("ops-nav-side"), navTarget)}
          {drawerNavTarget &&
            createPortal(renderNav("ops-nav-drawer"), drawerNavTarget)}
          {!navTarget && !drawerNavTarget && renderNav("ops-nav-inline")}
          <WorkspaceDraftBoundary
            onDirty={(dirty) => draftChanged("forms", dirty)}
          >
            <FadeThrough
              k={section}
              scale={!gridHeavy.has(section)}
              className="ops-place"
            >
              {section === "try" ? (
                <TrySection api={api} tenant={tenant} />
              ) : section !== "floor" ? (
                section === "overview" ? (
                  <OverviewSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    currencyCode={snapshot.currency}
                    openRequests={snapshot.rows.reduce(
                      (sum, row) => sum + row.serviceCount,
                      0,
                    )}
                    person={person}
                    judges={judges}
                    open={(next, f) => {
                      void navigate(next, f);
                    }}
                  />
                ) : section === "finance" ? (
                  <FinanceSection
                    key={`${tenant}:${api.scopeKey ?? "preview"}`}
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    onDirty={(dirty) => draftChanged("finance", dirty)}
                  />
                ) : section === "orders" ? (
                  <OrdersSection
                    key={focus ?? "orders"}
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    focus={focus}
                    currencyCode={snapshot.currency}
                  />
                ) : section === "agents" ? (
                  <AgentsSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                  />
                ) : section === "money" ? (
                  <MoneySection
                    key={focus ?? "money"}
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    focus={focus}
                    currencyCode={snapshot.currency}
                  />
                ) : section === "accountant" ? (
                  <AccountantSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    currencyCode={snapshot.currency}
                  />
                ) : section === "dispatch" ? (
                  <DispatchSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    currencyCode={snapshot.currency}
                  />
                ) : section === "supplies" ? (
                  <SuppliesSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    currencyCode={snapshot.currency}
                  />
                ) : section === "group" ? (
                  <GroupSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    currencyCode={snapshot.currency}
                  />
                ) : section === "team" ? (
                  <TeamSection
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    currencyCode={snapshot.currency}
                  />
                ) : (
                  <PaymentsSection
                    key={focus ?? "payments"}
                    api={api}
                    tenant={tenant}
                    revision={snapshot.asOf}
                    focus={focus}
                    currencyCode={snapshot.currency}
                  />
                )
              ) : (
                <>
                  <div
                    className="ops-filters"
                    aria-label="Shared workspace filter"
                  >
                    {(
                      ["all", "billRequested", "paymentExceptions"] as const
                    ).map((value) => (
                      <button
                        key={value}
                        aria-pressed={filter === value}
                        onClick={() => setFilter(value)}
                      >
                        {value === "all"
                          ? "The whole room"
                          : value === "billRequested"
                            ? "Ready to settle"
                            : "Payment attention"}
                      </button>
                    ))}
                    <small>
                      Updated {new Date(snapshot.asOf).toLocaleTimeString()}
                    </small>
                  </div>
                  <div
                    className="ops-analysis-tools"
                    aria-label="Floor analysis controls"
                  >
                    <button
                      className="ops-btn secondary"
                      aria-expanded={floorAnalysis}
                      onClick={() => setFloorAnalysis((v) => !v)}
                    >
                      {floorAnalysis
                        ? "Return to the room"
                        : "Explore floor analytics"}
                    </button>
                    {floorAnalysis && (
                      <>
                        <button
                          className="ops-btn secondary"
                          aria-pressed={floorPanel === "ai"}
                          onClick={() =>
                            setFloorPanel((p) =>
                              p === "ai" ? undefined : "ai",
                            )
                          }
                        >
                          Ask about the room
                        </button>
                        <button
                          className="ops-btn secondary"
                          aria-pressed={floorPanel === "edit"}
                          onClick={() =>
                            setFloorPanel((p) =>
                              p === "edit" ? undefined : "edit",
                            )
                          }
                        >
                          Arrange widgets
                        </button>
                      </>
                    )}
                  </div>
                  {studioOn && floorAnalysis ? (
                    <div className="ops-studio ops-floor-analytics">
                      <AgStudio<Registry>
                        modules={[AgStudioAiModule]}
                        theme={raystoTheme}
                        loadThemeGoogleFonts={false}
                        onApiReady={(event) => bindStudio(event.api)}
                        widgets={tiles}
                        ai={harness}
                        mode={floorPanel ? "edit" : "view"}
                        panels={{
                          view: { left: [], right: [] },
                          edit: {
                            left: [],
                            right: floorPanel ? [floorPanel] : [],
                          },
                        }}
                        initialState={layout}
                        onStateUpdated={(event) => {
                          state.current =
                            event.state as unknown as AgReportState<Registry>;
                        }}
                        data={{
                          sources: [
                            {
                              id: "tables",
                              fields: [
                                { id: "id", format: "integerFormat" },
                                { id: "label", format: "textFormat" },
                                { id: "guests", format: "integerFormat" },
                                {
                                  id: "outstandingMinor",
                                  format: "integerFormat",
                                },
                                { id: "serviceCount", format: "integerFormat" },
                              ],
                              data: snapshot.rows.map(
                                ({
                                  id,
                                  label,
                                  guests,
                                  outstandingMinor,
                                  serviceCount,
                                }) => ({
                                  id,
                                  label,
                                  guests,
                                  outstandingMinor,
                                  serviceCount,
                                }),
                              ),
                            },
                          ],
                        }}
                        style={{ height: "100%", width: "100%", minWidth: 800 }}
                      />
                    </div>
                  ) : (
                    <div className="ops-floor-summaries">
                      {(
                        [
                          "raystoBalance",
                          "raystoService",
                          "raystoExceptions",
                        ] as const
                      ).map((id) => (
                        <AttentionTile key={id} widgetType={id} />
                      ))}
                    </div>
                  )}
                  <div className="ops-floor-heading">
                    <h2>Meet the room.</h2>
                    <p>Select a table to join its service conversation.</p>
                    {selectedTable && (
                      <button
                        onClick={async () => {
                          if (
                            roomDraft.current &&
                            !(await confirmDiscard(
                              "Discard the unsent room message and show all tables?",
                            ))
                          )
                            return;
                          selection.current++;
                          setSelected(undefined);
                          setRoomId(undefined);
                          roomDraft.current = false;
                          onDirty?.(false);
                        }}
                      >
                        Show all table records
                      </button>
                    )}
                  </div>
                  {snapshot.floor && (
                    <div className="ops-map">
                      <svg
                        viewBox={`0 0 ${snapshot.floor.width} ${snapshot.floor.height}`}
                        role="group"
                        aria-label="Floor plan. Table records are also available in the grid below."
                      >
                        {snapshot.floor.objects.map((object) => (
                          <g
                            key={object.id}
                            transform={`translate(${Number(object.geometry.x ?? 0)} ${Number(object.geometry.y ?? 0)}) rotate(${Number(object.geometry.rotation ?? 0)})`}
                          >
                            <rect
                              width={Number(object.geometry.width ?? 10)}
                              height={Number(object.geometry.height ?? 10)}
                              rx={3}
                              fill={
                                object.kind === "wall" ? "#23493c" : "#d9ee96"
                              }
                            />
                            {object.kind !== "wall" && (
                              <text y={-8}>{object.label}</text>
                            )}
                          </g>
                        ))}
                        {snapshot.rows.map((row) => {
                          const g = row.geometry;
                          const width = Number(g.width ?? 80),
                            height = Number(g.height ?? 80);
                          return (
                            <g
                              key={row.id}
                              transform={`translate(${Number(g.x ?? 0)} ${Number(g.y ?? 0)}) rotate(${Number(g.rotation ?? 0)} ${width / 2} ${height / 2})`}
                              tabIndex={0}
                              role="button"
                              aria-label={`${row.label}, ${row.guests} guests, ${currency(row.outstandingMinor, row.currency)} outstanding`}
                              onClick={() => void openTable(row)}
                              onKeyDown={(e) => {
                                if (e.key === "Enter" || e.key === " ") {
                                  e.preventDefault();
                                  void openTable(row);
                                }
                              }}
                            >
                              <rect
                                width={width}
                                height={height}
                                rx={
                                  g.shape === "round"
                                    ? Math.min(width, height) / 2
                                    : 12
                                }
                                fill={
                                  row.billRequested
                                    ? "#fbebd3"
                                    : row.visitId
                                      ? "#d9ee96"
                                      : "#fffdf7"
                                }
                                stroke="#23493c"
                                strokeWidth={selected === row.id ? 4 : 1}
                              />
                              <text
                                x={width / 2}
                                y={height / 2}
                                textAnchor="middle"
                                dominantBaseline="middle"
                              >
                                {row.label}
                              </text>
                            </g>
                          );
                        })}
                      </svg>
                    </div>
                  )}
                  <div className="ops-floor" aria-label="Restaurant tables">
                    {snapshot.rows.map((row) => (
                      <button
                        key={row.id}
                        className={`ops-table ${row.status} ${row.billRequested ? "attention" : ""}`}
                        aria-pressed={selected === row.id}
                        onClick={() => void openTable(row)}
                      >
                        <span>{row.label}</span>
                        <strong>
                          {row.guests
                            ? `${row.guests} guests`
                            : "Ready for company"}
                        </strong>
                        <small>
                          {row.outstandingMinor
                            ? currency(row.outstandingMinor, row.currency)
                            : row.status.replace(/([A-Z])/g, " $1")}
                        </small>
                        {row.serviceCount > 0 && (
                          <i>{row.serviceCount} requests</i>
                        )}
                      </button>
                    ))}
                  </div>
                  <div className="ops-bottom">
                    <section className="ops-grid-panel">
                      <nav aria-label="Operations records">
                        {["tables", "orders", "services", "payments"].map(
                          (name) => (
                            <button
                              aria-pressed={tab === name}
                              key={name}
                              onClick={() => setTab(name)}
                            >
                              {name}
                            </button>
                          ),
                        )}
                      </nav>
                      {tab === "tables" ? (
                        <RaystoGrid<TableRow>
                          label="Tables"
                          rows={snapshot.rows}
                          columns={tableColumns}
                          onRowClicked={(e) => e.data && void openTable(e.data)}
                          getRowId={(p) => String(p.data.id)}
                          csvName="tables"
                          emptyText="No table in this view."
                        />
                      ) : (
                        <RaystoGrid<Json>
                          key={tab}
                          label={
                            tab === "orders"
                              ? "Floor orders"
                              : tab === "payments"
                                ? "Floor payments"
                                : "Service requests"
                          }
                          rows={generalRows}
                          columns={genericColumns}
                          csvName={`floor-${tab}`}
                          totals={tab !== "services"}
                          emptyText={
                            tab === "services"
                              ? "No open request."
                              : `No ${tab} in this view.`
                          }
                        />
                      )}
                      <small>
                        Orders and payments show up to 100 records, narrowed by
                        the shared attention filter.
                      </small>
                    </section>
                    <aside className="ops-room-panel">
                      {roomId ? (
                        <RoomPanel
                          key={roomId}
                          api={api}
                          tenant={tenant}
                          roomId={roomId}
                          table={selectedTable?.label ?? "Table"}
                          onDirty={(dirty) => draftChanged("room", dirty)}
                        />
                      ) : (
                        <div className="ops-empty">
                          <span className="ops-flower">✳</span>
                          <h2>
                            A conversation
                            <br />
                            belongs here.
                          </h2>
                          <p>
                            {selectedTable && !selectedTable.visitId
                              ? "This table has no active visit. Seat guests in Raysto to open a new room."
                              : "Choose an occupied table to see its room and service history."}
                          </p>
                        </div>
                      )}
                    </aside>
                  </div>
                </>
              )}
            </FadeThrough>
          </WorkspaceDraftBoundary>
        </section>
      </Context.Provider>
    </WorkspaceStateContext.Provider>
  );
}
