"use client";
import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { AgGridReact } from "ag-grid-react";
import {
  AllCommunityModule,
  ModuleRegistry,
  themeQuartz,
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

ModuleRegistry.registerModules([AllCommunityModule]);
const license = process.env.NEXT_PUBLIC_AG_STUDIO_LICENSE;
if (license) AgStudioLicenseManager.setLicenseKey(license);
const gridTheme = themeQuartz.withParams({
  accentColor: "#23493c",
  backgroundColor: "#fffdf7",
  foregroundColor: "#193c30",
  fontFamily: "var(--font-jakarta)",
  rowHeight: 52,
});
const raystoTheme = studioTheme.withParams({
  accentColor: "#23493c",
  backgroundColor: "#fffdf7",
  foregroundColor: "#193c30",
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
function createTile<T extends TileId>(id: T): TileDefinition<T> {
  return {
    id,
    label:
      id === "raystoBalance"
        ? "Outstanding bills"
        : id === "raystoService"
          ? "Service attention"
          : "Payment exceptions",
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
      widgetLayout: {
        balance: { xTrack: 0, yTrack: 0, xSpan: 8, ySpan: 8 },
        service: { xTrack: 8, yTrack: 0, xSpan: 8, ySpan: 8 },
        exceptions: { xTrack: 16, yTrack: 0, xSpan: 8, ySpan: 8 },
      },
    },
  ],
  selectedPageId: "restaurant",
  panels: {
    ai: { collapsed: false },
    data: { collapsed: true },
    filters: { collapsed: true },
  },
};
const tableColumns: ColDef<TableRow>[] = [
  { field: "label", headerName: "Table", minWidth: 110 },
  { field: "zone", minWidth: 110 },
  { field: "guests", width: 100 },
  { field: "status", minWidth: 130 },
  {
    field: "outstandingMinor",
    headerName: "Outstanding",
    minWidth: 150,
    valueFormatter: (p) => currency(p.value ?? 0, p.data?.currency ?? "USD"),
  },
  { field: "serviceCount", headerName: "Requests", width: 110 },
  { field: "billRequested", headerName: "Bill requested", width: 150 },
];

export function OperationsWorkspace({
  api,
  tenant,
  onDirty,
}: {
  api: ConnectedApi;
  tenant: number;
  onDirty?: (dirty: boolean) => void;
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
  const [layout, setLayout] = useState<AgReportState<Registry>>();
  const [layoutVersion, setLayoutVersion] = useState(0);
  const [saving, setSaving] = useState(false);
  const state = useRef<AgReportState<Registry>>(defaultLayout);
  const live = useRef(true);
  const filterRef = useRef(filter);
  filterRef.current = filter;
  const selection = useRef(0);
  const roomDraft = useRef(false);
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
        setLayout(
          (old) =>
            old ??
            (next.layout?.pages
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
      !window.confirm("Discard the unsent room message and change tables?")
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
  const genericColumns: ColDef<Json>[] = (
    tab === "orders"
      ? ["id", "fulfillment", "status", "paymentStatus", "totalMinor"]
      : tab === "payments"
        ? ["id", "state", "amountMinor", "currency"]
        : ["table", "kind", "status"]
  ).map((field) => ({
    field,
    minWidth: 130,
    headerName:
      (
        {
          id: tab === "orders" ? "Order" : "Checkout",
          fulfillment: "Service",
          status: "Status",
          state: "Payment status",
          paymentStatus: "Payment",
          totalMinor: "Total",
          amountMinor: "Amount",
          currency: "Currency",
          table: "Table",
          kind: "Request",
        } as Record<string, string>
      )[field] ?? field,
    ...(field.endsWith("Minor")
      ? {
          valueFormatter: (p: ValueFormatterParams<Json>) =>
            currency(
              Number(p.value ?? 0),
              String(p.data?.currency ?? snapshot?.currency ?? "USD"),
            ),
        }
      : {
          valueFormatter: (p: ValueFormatterParams<Json>) => {
            if (field === "fulfillment" && p.value === "dineIn")
              return "Dine-in";
            if (
              [
                "fulfillment",
                "status",
                "state",
                "paymentStatus",
                "kind",
              ].includes(field)
            ) {
              const label = String(p.value ?? "")
                .replace(/([a-z])([A-Z])/g, "$1 $2")
                .replaceAll("_", " ");
              return label.charAt(0).toUpperCase() + label.slice(1);
            }
            return String(p.value ?? "");
          },
        }),
  }));
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
  if (!snapshot || !layout)
    return (
      <section className="ops-empty">
        <p role="status">{error || "Opening the restaurant…"}</p>
        <button onClick={() => void refreshRef.current()}>Retry</button>
      </section>
    );
  return (
    <Context.Provider value={{ snapshot, filter, setFilter }}>
      <section className="ops-workspace">
        <div className="ops-heading">
          <div>
            <span className="ops-eyebrow">MAKE EVERY TABLE FEEL SEEN</span>
            <h1>{snapshot.name}</h1>
          </div>
          <span className="ops-live">● {delivery}</span>
          <button onClick={() => void refreshRef.current()}>Refresh</button>
          <button onClick={() => void save()} disabled={saving}>
            {saving ? "Saving…" : "Save workspace"}
          </button>
        </div>
        {error && (
          <p className="ops-error" role="alert">
            {error}
          </p>
        )}
        <div className="ops-filters" aria-label="Shared workspace filter">
          {(["all", "billRequested", "paymentExceptions"] as const).map(
            (value) => (
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
            ),
          )}
          <small>Updated {new Date(snapshot.asOf).toLocaleTimeString()}</small>
        </div>
        <div className="ops-studio">
          <AgStudio<Registry>
            modules={[AgStudioAiModule]}
            theme={raystoTheme}
            loadThemeGoogleFonts={false}
            onApiReady={(event) => bindStudio(event.api)}
            widgets={tiles}
            ai={harness}
            mode="edit"
            initialState={layout}
            onStateUpdated={(event) => {
              state.current = event.state as unknown as AgReportState<Registry>;
            }}
            data={{
              sources: [
                {
                  id: "tables",
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
            style={{ height: "100%", width: "100%" }}
          />
        </div>
        <div className="ops-floor-heading">
          <h2>Meet the room.</h2>
          <p>Select a table to join its service conversation.</p>
          {selectedTable && (
            <button
              onClick={() => {
                if (
                  roomDraft.current &&
                  !window.confirm(
                    "Discard the unsent room message and show all tables?",
                  )
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
                    fill={object.kind === "wall" ? "#23493c" : "#d9ee96"}
                  />
                  {object.kind !== "wall" && <text y={-8}>{object.label}</text>}
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
                        g.shape === "round" ? Math.min(width, height) / 2 : 12
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
                {row.guests ? `${row.guests} guests` : "Ready for company"}
              </strong>
              <small>
                {row.outstandingMinor
                  ? currency(row.outstandingMinor, row.currency)
                  : row.status.replace(/([A-Z])/g, " $1")}
              </small>
              {row.serviceCount > 0 && <i>{row.serviceCount} requests</i>}
            </button>
          ))}
        </div>
        <div className="ops-bottom">
          <section className="ops-grid-panel">
            <nav aria-label="Operations records">
              {["tables", "orders", "services", "payments"].map((name) => (
                <button
                  aria-pressed={tab === name}
                  key={name}
                  onClick={() => setTab(name)}
                >
                  {name}
                </button>
              ))}
            </nav>
            <div className="ops-grid">
              {tab === "tables" ? (
                <AgGridReact<TableRow>
                  theme={gridTheme}
                  rowData={snapshot.rows}
                  columnDefs={tableColumns}
                  defaultColDef={{
                    sortable: true,
                    filter: true,
                    resizable: true,
                    flex: 1,
                  }}
                  onRowClicked={(e) => e.data && void openTable(e.data)}
                  getRowId={(p) => String(p.data.id)}
                />
              ) : (
                <AgGridReact<Json>
                  key={tab}
                  theme={gridTheme}
                  rowData={generalRows}
                  columnDefs={genericColumns}
                  defaultColDef={{
                    sortable: true,
                    filter: true,
                    resizable: true,
                    flex: 1,
                  }}
                />
              )}
            </div>
            <small>
              Orders and payments show up to 100 records, narrowed by the shared
              attention filter.
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
                onDirty={(dirty) => {
                  onDirty?.(dirty);
                  roomDraft.current = dirty;
                }}
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
      </section>
    </Context.Provider>
  );
}
