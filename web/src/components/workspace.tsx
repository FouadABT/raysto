"use client";
import Link from "next/link";
import { useMemo, useState } from "react";
import { AgGridReact } from "ag-grid-react";
import {
  AllCommunityModule,
  ModuleRegistry,
  themeQuartz,
  type ColDef,
  type ICellRendererParams,
} from "ag-grid-community";
import { QRCodeSVG } from "qrcode.react";
import { useDemo } from "@/lib/store";
import {
  money,
  rolePeople,
  roleNames,
  roles,
  type Order,
  type Product,
  type Staff,
} from "@/lib/domain";
import {
  ActionLink,
  Badge,
  Button,
  Chips,
  DownloadCSV,
  Empty,
  Field,
  FoodImage,
  Icon,
  IconButton,
  Modal,
  OrderLines,
  PageTitle,
  Search,
  SectionTitle,
  Totals,
  timeLabel,
} from "./ui";
import { Operations } from "./workspace-operations";
ModuleRegistry.registerModules([AllCommunityModule]);
const gridTheme = themeQuartz.withParams({
  fontFamily: "var(--font-jakarta), sans-serif",
  fontSize: 13,
  foregroundColor: "#173E34",
  backgroundColor: "#FFFFFF",
  headerBackgroundColor: "#F6F7F2",
  headerTextColor: "#59675E",
  borderColor: "#E6EAE2",
  rowBorder: { color: "#EDF0E9" },
  wrapperBorder: false,
  wrapperBorderRadius: 16,
  cellHorizontalPadding: 20,
  headerFontSize: 11,
  headerFontWeight: 600,
  accentColor: "#173F35",
});
export function Dashboard({ section }: { section: string }) {
  switch (section) {
    case "overview":
      return <Overview />;
    case "orders":
      return <Orders />;
    case "kitchen":
      return <Orders kitchen />;
    case "menu":
      return <Menu />;
    case "tables":
      return <Tables />;
    default:
      return <Operations section={section} />;
  }
}
function Overview() {
  const { state } = useDemo();
  const [range, setRange] = useState("Today");
  const active = state.orders.filter(
    (o) => !["Completed", "Cancelled"].includes(o.status),
  );
  const paid = state.orders.filter(
    (o) =>
      o.payment === "Paid" &&
      new Date(o.createdAt).toDateString() === new Date().toDateString(),
  );
  const sales = paid.reduce((sum, o) => sum + o.total, 0);
  const occupied = state.tables.filter((t) => t.status === "Occupied").length;
  return (
    <>
      <PageTitle
        eyebrow="YOUR RESTAURANT, AT A GLANCE"
        title={`A good day starts here, ${rolePeople[state.role!]}.`}
        description="A little clarity for a beautifully busy service."
        action={
          <div className="date-control">
            <Icon name="calendar_today" />
            {new Intl.DateTimeFormat("en", {
              day: "numeric",
              month: "short",
              year: "numeric",
            }).format(new Date())}
          </div>
        }
      />
      <div className="service-strip">
        <span>
          <span className={`live-dot ${state.settings.open ? "" : "paused"}`} />
          <strong>
            {state.settings.open
              ? "Open for good company"
              : "Taking a little pause"}
          </strong>
          <span className="muted">
            {state.settings.restaurant} · Demo service
          </span>
        </span>
        <Link href="/dashboard/settings">
          Manage service <Icon name="arrow_forward" />
        </Link>
      </div>
      <div className="stat-grid">
        <Stat
          label="Collected sales"
          value={money(sales)}
          note={`${paid.length} paid demo orders`}
          icon="payments"
          accent
        />
        <Stat
          label="Active orders"
          value={String(active.length).padStart(2, "0")}
          note={`${state.orders.filter((o) => o.status === "New").length} waiting for acceptance`}
          icon="receipt_long"
        />
        <Stat
          label="Tables occupied"
          value={`${occupied}/${state.tables.length}`}
          note={`${state.tables.filter((t) => t.status === "Available").length} tables ready to welcome`}
          icon="table_restaurant"
        />
        <Stat
          label="Average paid order"
          value={money(paid.length ? Math.round(sales / paid.length) : 0)}
          note="Based on collected demo sales"
          icon="monitoring"
        />
      </div>
      <div className="overview-grid">
        <section className="panel sales-panel">
          <SectionTitle title="The rhythm of your day">
            <span className="subtle-label">Collected sales · MAD</span>
          </SectionTitle>
          <div className="chart-summary">
            <div>
              <strong>{money(sales)}</strong>
              <span>
                <span className="chart-dot" /> Today’s demo sales
              </span>
            </div>
            <span className="soft-icon">
              <Icon name="show_chart" />
            </span>
          </div>
          <SalesChart orders={state.orders} />
        </section>
        <section className="panel service-panel">
          <SectionTitle title="On the floor">
            <Link className="text-link" href="/dashboard/tables">
              View all <Icon name="arrow_forward" />
            </Link>
          </SectionTitle>
          <div className="floor-mini">
            {state.tables.slice(0, 8).map((t) => (
              <Link
                href="/dashboard/tables"
                className={`mini-table ${t.status.toLowerCase().replace(" ", "-")}`}
                key={t.id}
              >
                <span>{String(t.id).padStart(2, "0")}</span>
                <small>{t.status}</small>
              </Link>
            ))}
          </div>
          <div className="floor-legend">
            <span>
              <i className="legend-square occupied" />
              Occupied
            </span>
            <span>
              <i className="legend-square available" />
              Available
            </span>
            <span>
              <i className="legend-square reserved" />
              Reserved
            </span>
          </div>
        </section>
      </div>
      <div className="overview-lower">
        <section className="panel order-panel">
          <SectionTitle title="Orders in motion">
            <Link className="text-link" href="/dashboard/orders">
              All orders <Icon name="arrow_forward" />
            </Link>
          </SectionTitle>
          <OrderGrid orders={active.slice(0, 6)} compact />
        </section>
        <section className="panel popular-panel">
          <SectionTitle title="A few crowd favorites">
            <Icon name="local_fire_department" />
          </SectionTitle>
          {state.products
            .filter((p) => p.featured)
            .map((p, i) => (
              <Link href="/dashboard/menu" className="popular-item" key={p.id}>
                <span className="rank">0{i + 1}</span>
                <FoodImage image={p.image} name={p.name} />
                <div>
                  <strong>{p.name}</strong>
                  <small>
                    {state.orders.reduce(
                      (sum, o) =>
                        sum +
                        o.lines
                          .filter((l) => l.productId === p.id)
                          .reduce((s, l) => s + l.quantity, 0),
                      0,
                    )}{" "}
                    portions ordered
                  </small>
                </div>
                <Icon name="arrow_outward" />
              </Link>
            ))}
          <div className="warm-note">
            <Icon name="favorite" />
            <span>
              Small details.
              <br />
              <strong>Memorable experiences.</strong>
            </span>
          </div>
        </section>
      </div>
    </>
  );
}
export function Stat({
  label,
  value,
  note,
  icon,
  accent = false,
}: {
  label: string;
  value: string;
  note: string;
  icon: string;
  accent?: boolean;
}) {
  return (
    <section className={`stat-card ${accent ? "accent" : ""}`}>
      <div>
        <span>{label}</span>
        <span className="stat-icon">
          <Icon name={icon} />
        </span>
      </div>
      <strong>{value}</strong>
      <small>{note}</small>
    </section>
  );
}
export function SalesChart({ orders }: { orders: Order[] }) {
  const buckets = Array.from({ length: 8 }, (_, i) => ({
    hour: i * 3,
    value: orders
      .filter(
        (o) =>
          o.payment === "Paid" &&
          new Date(o.createdAt).getHours() >= i * 3 &&
          new Date(o.createdAt).getHours() < 3 + i * 3,
      )
      .reduce((s, o) => s + o.total / 100, 0),
  }));
  const max = Math.max(...buckets.map((b) => b.value), 100);
  const points = buckets
    .map((b, i) => `${40 + i * 84},${190 - (b.value / max) * 150}`)
    .join(" ");
  return (
    <div className="sales-chart">
      <svg
        viewBox="0 0 660 240"
        role="img"
        aria-label={`Collected demo sales by time: ${buckets.map((b) => `${b.hour}:00, ${b.value} MAD`).join("; ")}`}
      >
        <defs>
          <linearGradient id="sales-fill" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor="#D7F978" stopOpacity=".55" />
            <stop offset="100%" stopColor="#D7F978" stopOpacity="0" />
          </linearGradient>
        </defs>
        {[40, 90, 140, 190].map((y) => (
          <line
            key={y}
            x1="35"
            x2="635"
            y1={y}
            y2={y}
            stroke="currentColor"
            strokeOpacity=".10"
            strokeDasharray="4 5"
          />
        ))}
        <polygon points={`40,190 ${points} 628,190`} fill="url(#sales-fill)" />
        <polyline
          points={points}
          fill="none"
          stroke="#3C704C"
          strokeWidth="3"
          strokeLinejoin="round"
        />
        {buckets.map((b, i) => (
          <g key={b.hour}>
            <circle
              cx={40 + i * 84}
              cy={190 - (b.value / max) * 150}
              r="4"
              fill="#173F35"
            />
            <text x={40 + i * 84} y="222" textAnchor="middle">
              {b.hour}:00
            </text>
          </g>
        ))}
      </svg>
      <small>
        Calculated from this browser’s paid demo orders. No live sales data.
      </small>
    </div>
  );
}
export function OrderGrid({
  orders,
  compact = false,
}: {
  orders: Order[];
  compact?: boolean;
}) {
  const { state } = useDemo();
  const tableTheme = useMemo(
    () =>
      state.settings.dark
        ? gridTheme.withParams({
            backgroundColor: "#192A22",
            foregroundColor: "#E5EBDD",
            headerBackgroundColor: "#101E19",
            headerTextColor: "#B7C6B8",
            borderColor: "#3E5143",
            rowBorder: { color: "#2C4033" },
            accentColor: "#D7F978",
          })
        : gridTheme,
    [state.settings.dark],
  );
  const [selected, setSelected] = useState<string | null>(null);
  const columns = useMemo<ColDef<Order>[]>(
    () => [
      {
        field: "id",
        headerName: "ORDER",
        minWidth: 130,
        flex: 1,
        cellRenderer: (p: ICellRendererParams<Order>) => (
          <button className="grid-link" onClick={() => setSelected(p.data!.id)}>
            {p.value}
          </button>
        ),
      },
      { field: "guest", headerName: "GUEST", minWidth: 130, flex: 1 },
      {
        field: "channel",
        headerName: "SERVICE",
        minWidth: 120,
        flex: 1,
        cellRenderer: (p: ICellRendererParams<Order>) => (
          <span>
            {p.value}
            {p.data?.table ? ` · T${p.data.table}` : ""}
          </span>
        ),
      },
      {
        field: "status",
        headerName: "STATUS",
        minWidth: 150,
        flex: 1,
        cellRenderer: (p: ICellRendererParams<Order>) => (
          <Badge>{p.value}</Badge>
        ),
      },
      {
        field: "total",
        headerName: "TOTAL",
        minWidth: 135,
        flex: 1,
        valueFormatter: (p) => money(p.value),
      },
      ...(!compact
        ? [
            {
              field: "payment" as const,
              headerName: "PAYMENT",
              minWidth: 120,
              cellRenderer: (p: ICellRendererParams<Order>) => (
                <Badge>{p.value}</Badge>
              ),
            },
          ]
        : []),
    ],
    [compact],
  );
  return (
    <>
      {orders.length ? (
        <div className="data-grid" style={{ height: compact ? 355 : 510 }}>
          <AgGridReact<Order>
            theme={tableTheme}
            rowData={orders}
            columnDefs={columns}
            rowHeight={62}
            headerHeight={48}
            defaultColDef={{ sortable: true, resizable: true }}
            getRowId={(p) => p.data.id}
            pagination={!compact}
            paginationPageSize={10}
            paginationPageSizeSelector={[10, 25, 50]}
            suppressCellFocus={false}
            onRowDoubleClicked={(e) => setSelected(e.data!.id)}
          />
        </div>
      ) : (
        <Empty
          title="All caught up"
          icon="task_alt"
          text="Orders will appear here when a guest places one."
        />
      )}
      {selected && (
        <OrderDetail id={selected} onClose={() => setSelected(null)} />
      )}
    </>
  );
}
export function OrderDetail({
  id,
  onClose,
}: {
  id: string;
  onClose: () => void;
}) {
  const { state, progress, cancelOrder, payOrder, refundOrder } = useDemo();
  const order = state.orders.find((o) => o.id === id);
  if (!order) return null;
  const management = ["owner", "manager"].includes(state.role || "");
  const canAdvance =
    management ||
    (state.role === "kitchen" &&
      ["Accepted", "Preparing"].includes(order.status)) ||
    (state.role === "waiter" && order.status === "Ready") ||
    (state.role === "courier" &&
      order.courier === "Sami" &&
      ["Ready", "Out for delivery"].includes(order.status));
  const labels: Record<string, string> = {
    New: "Accept order",
    Accepted: "Start preparing",
    Preparing: "Mark ready",
    Ready: order.channel === "Delivery" ? "Hand off delivery" : "Mark served",
    "Out for delivery": "Mark delivered",
  };
  return (
    <Modal title={`Order ${order.id}`} onClose={onClose} wide>
      <div className="detail-meta">
        <Badge>{order.status}</Badge>
        <Badge>{order.payment}</Badge>
        <span>
          {order.channel}
          {order.table && ` · Table ${order.table}`}
        </span>
      </div>
      <h3>{order.guest}</h3>
      <p>
        {timeLabel(order.createdAt)}
        {order.address && ` · ${order.address}`}
      </p>
      <OrderLines order={order} />
      <Totals {...order} />
      <div className="timeline compact-timeline">
        {order.events.map((e, i) => (
          <div key={i}>
            <Icon name="check_circle" />
            <span>{e.label}</span>
            <small>{timeLabel(e.time)}</small>
          </div>
        ))}
      </div>
      <div className="modal-actions">
        {canAdvance && labels[order.status] && (
          <Button icon="arrow_forward" onClick={() => progress(order.id)}>
            {labels[order.status]}
          </Button>
        )}
        {order.payment === "Unpaid" &&
          (management || state.role === "waiter") && (
            <Button variant="secondary" onClick={() => payOrder(id)}>
              Record demo cash payment
            </Button>
          )}
        {management && ["New", "Accepted"].includes(order.status) && (
          <Button
            variant="danger"
            onClick={() => {
              if (
                confirm(
                  "Cancel this demo order? Any demo payment will be refunded.",
                )
              )
                cancelOrder(id);
            }}
          >
            Cancel order
          </Button>
        )}
        {management && order.payment === "Paid" && (
          <Button
            variant="text"
            onClick={() => {
              if (confirm("Record a full demo refund for this order?"))
                refundOrder(id);
            }}
          >
            Refund demo payment
          </Button>
        )}
      </div>
    </Modal>
  );
}
function Orders({ kitchen = false }: { kitchen?: boolean }) {
  const { state, progress } = useDemo();
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("All orders");
  const [channel, setChannel] = useState("All services");
  const [selected, setSelected] = useState<string | null>(null);
  const orders = state.orders.filter(
    (o) =>
      (status === "All orders" ||
        (status === "Active" &&
          !["Completed", "Cancelled"].includes(o.status)) ||
        o.status === status) &&
      (channel === "All services" || o.channel === channel) &&
      `${o.id} ${o.guest} ${o.table || ""}`
        .toLowerCase()
        .includes(query.toLowerCase()),
  );
  return (
    <>
      <PageTitle
        eyebrow={kitchen ? "THE HEART OF THE HOUSE" : "EVERY ORDER, TOGETHER"}
        title={kitchen ? "A little heat. A lot of heart." : "Orders"}
        description={
          kitchen
            ? "A clear queue, from first fire to final garnish."
            : "Keep every guest’s next good moment moving."
        }
        action={
          !kitchen && (
            <DownloadCSV
              rows={[
                [
                  "Order",
                  "Guest",
                  "Service",
                  "Status",
                  "Total (MAD)",
                  "Payment",
                ],
                ...orders.map((o) => [
                  o.id,
                  o.guest,
                  o.channel,
                  o.status,
                  o.total / 100,
                  o.payment,
                ]),
              ]}
            />
          )
        }
      />
      {kitchen ? (
        <>
          <div className="kitchen-summary">
            <span className="live-dot" /> Demo kitchen ·{" "}
            {
              state.orders.filter((o) =>
                ["Accepted", "Preparing"].includes(o.status),
              ).length
            }{" "}
            tickets to prepare{" "}
            <span className="muted">Updates follow your actions.</span>
          </div>
          <div className="kanban">
            {["Accepted", "Preparing", "Ready"].map((stage) => (
              <section key={stage} className="kanban-column">
                <h2>
                  <span className={`stage-dot ${stage.toLowerCase()}`} />
                  {stage}
                  <span className="count">
                    {state.orders.filter((o) => o.status === stage).length}
                  </span>
                </h2>
                {state.orders
                  .filter((o) => o.status === stage)
                  .map((order) => (
                    <article className="ticket" key={order.id}>
                      <div className="ticket-heading">
                        <strong>
                          {order.table
                            ? `Table ${String(order.table).padStart(2, "0")}`
                            : order.channel}
                        </strong>
                        <span>{timeLabel(order.createdAt)}</span>
                      </div>
                      <button
                        className="text-link"
                        onClick={() => setSelected(order.id)}
                      >
                        {order.id} <Icon name="open_in_new" />
                      </button>
                      <div className="ticket-items">
                        {order.lines.map((line) => (
                          <div key={line.id}>
                            <b>{line.quantity}</b>
                            <span>
                              <strong>{line.name}</strong>
                              <small>{line.option}</small>
                              {line.note && <em>{line.note}</em>}
                            </span>
                          </div>
                        ))}
                      </div>
                      {stage !== "Ready" ? (
                        <Button
                          variant={
                            stage === "Preparing" ? "primary" : "secondary"
                          }
                          icon={stage === "Preparing" ? "check" : "skillet"}
                          onClick={() => progress(order.id)}
                        >
                          {stage === "Preparing"
                            ? "Mark ready"
                            : "Start preparing"}
                        </Button>
                      ) : (
                        <div className="ready-note">
                          <Icon name="check_circle" />
                          Ready for the service team
                        </div>
                      )}
                    </article>
                  ))}
                {!state.orders.some((o) => o.status === stage) && (
                  <Empty
                    icon="skillet"
                    title="A clear station"
                    text="Tickets appear here as orders move through the kitchen."
                  />
                )}
              </section>
            ))}
          </div>
        </>
      ) : (
        <>
          <div className="toolbar">
            <Chips
              items={[
                "All orders",
                "Active",
                "New",
                "Preparing",
                "Ready",
                "Completed",
                "Cancelled",
              ]}
              value={status}
              onChange={setStatus}
            />
          </div>
          <section className="panel">
            <div className="table-toolbar">
              <Search
                value={query}
                onChange={setQuery}
                placeholder="Search order, guest or table"
              />
              <select
                aria-label="Service type"
                value={channel}
                onChange={(e) => setChannel(e.target.value)}
              >
                {["All services", "Dine-in", "Pickup", "Delivery"].map((c) => (
                  <option key={c}>{c}</option>
                ))}
              </select>
              <span className="muted">{orders.length} orders</span>
            </div>
            <OrderGrid orders={orders} />
          </section>
        </>
      )}
      {selected && (
        <OrderDetail id={selected} onClose={() => setSelected(null)} />
      )}
    </>
  );
}
function Menu() {
  const { state, update, notify, saveProduct } = useDemo();
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("All items");
  const [edit, setEdit] = useState<Product | null>(null);
  const [dirty, setDirty] = useState(false);
  const management = ["owner", "manager"].includes(state.role || "");
  const products = state.products.filter(
    (p) =>
      (category === "All items" || p.category === category) &&
      `${p.name} ${p.description}`.toLowerCase().includes(query.toLowerCase()),
  );
  return (
    <>
      <PageTitle
        eyebrow="MADE WITH CARE"
        title="Your menu, beautifully served."
        description="Seasonal favorites, signature dishes and everything in between."
        action={
          management && (
            <Button
              icon="add"
              onClick={() => {
                setEdit({
                  id: `p-${crypto.randomUUID().slice(0, 8)}`,
                  name: "",
                  description: "",
                  category: "Mains",
                  price: 0,
                  image: "tomato_pasta.jpg",
                  tags: [],
                  allergens:
                    "Allergen information is not verified. Ask the team.",
                  available: true,
                });
                setDirty(false);
              }}
            >
              Add menu item
            </Button>
          )
        }
      />
      <div className="toolbar">
        <Chips
          items={[
            "All items",
            ...new Set(state.products.map((p) => p.category)),
          ]}
          value={category}
          onChange={setCategory}
        />
        <Search value={query} onChange={setQuery} placeholder="Find a dish" />
      </div>
      <div className="menu-admin-grid">
        {products.map((p) => (
          <article
            className={`menu-admin-card ${!p.available ? "unavailable" : ""}`}
            key={p.id}
          >
            <div className="menu-admin-image">
              <FoodImage image={p.image} name={p.name} />
              <span className="image-badge">{p.category}</span>
              {management && (
                <IconButton
                  name="edit"
                  label={`Edit ${p.name}`}
                  onClick={() => {
                    setEdit(structuredClone(p));
                    setDirty(false);
                  }}
                />
              )}
            </div>
            <div className="menu-card-body">
              <div className="between">
                <h3>{p.name}</h3>
                <strong>{money(p.price)}</strong>
              </div>
              <p>{p.description}</p>
              <div className="menu-card-bottom">
                <span>{p.tags[0] || "House recipe"}</span>
                <label className="switch-label">
                  <input
                    type="checkbox"
                    role="switch"
                    checked={p.available}
                    onChange={() => {
                      if (
                        update((s) => {
                          const item = s.products.find((i) => i.id === p.id)!;
                          item.available = !item.available;
                        }, "menu")
                      )
                        notify(
                          `${p.name} is now ${p.available ? "unavailable" : "available"}.`,
                        );
                    }}
                  />
                  <span>{p.available ? "Available" : "Sold out"}</span>
                </label>
              </div>
            </div>
          </article>
        ))}
      </div>
      {!products.length && (
        <Empty
          title="No dishes found"
          text="Try another name or category."
          action={
            <Button
              onClick={() => {
                setQuery("");
                setCategory("All items");
              }}
            >
              Clear filters
            </Button>
          }
        />
      )}
      {edit && (
        <Modal
          title={
            state.products.some((p) => p.id === edit.id)
              ? "Edit menu item"
              : "Something new for the menu"
          }
          onClose={() => setEdit(null)}
          dirty={dirty}
        >
          <form
            onSubmit={(e) => {
              e.preventDefault();
              if (saveProduct(edit)) {
                setDirty(false);
                setEdit(null);
              }
            }}
            onChange={() => setDirty(true)}
          >
            <Field label="Dish name">
              <input
                required
                value={edit.name}
                onChange={(e) => setEdit({ ...edit, name: e.target.value })}
              />
            </Field>
            <Field label="Description">
              <textarea
                required
                value={edit.description}
                onChange={(e) =>
                  setEdit({ ...edit, description: e.target.value })
                }
              />
            </Field>
            <div className="form-grid">
              <Field label="Price (MAD)">
                <input
                  required
                  min="0.01"
                  max="10000"
                  step="0.01"
                  type="number"
                  value={edit.price / 100 || ""}
                  onChange={(e) =>
                    setEdit({
                      ...edit,
                      price: Math.round(Number(e.target.value) * 100),
                    })
                  }
                />
              </Field>
              <Field label="Category">
                <select
                  value={edit.category}
                  onChange={(e) =>
                    setEdit({ ...edit, category: e.target.value })
                  }
                >
                  {["Starters", "Mains", "Pizza", "Drinks", "Desserts"].map(
                    (c) => (
                      <option key={c}>{c}</option>
                    ),
                  )}
                </select>
              </Field>
            </div>
            <Field label="Illustrative photo">
              <select
                value={edit.image}
                onChange={(e) => setEdit({ ...edit, image: e.target.value })}
              >
                <option value="salad_bowl.jpg">Garden bowl</option>
                <option value="tomato_pasta.jpg">Tomato pasta</option>
                <option value="wood_fired_pizza.jpg">Wood-fired pizza</option>
                <option value="">Simple illustration</option>
              </select>
            </Field>
            <Field label="Allergen information">
              <textarea
                required
                value={edit.allergens}
                onChange={(e) =>
                  setEdit({ ...edit, allergens: e.target.value })
                }
              />
            </Field>
            <div className="modal-actions">
              <Button type="submit" icon="check">
                Save menu item
              </Button>
              <Button
                variant="secondary"
                type="button"
                onClick={() => {
                  if (!dirty || confirm("Discard your unsaved changes?"))
                    setEdit(null);
                }}
              >
                Cancel
              </Button>
            </div>
          </form>
        </Modal>
      )}
    </>
  );
}
function Tables() {
  const { state, update, closeTable, notify } = useDemo();
  const [zone, setZone] = useState("All spaces");
  const [selected, setSelected] = useState<number | null>(null);
  const [layout, setLayout] = useState("Floor plan");
  const table = state.tables.find((t) => t.id === selected);
  return (
    <>
      <PageTitle
        eyebrow="A PLACE FOR EVERYONE"
        title="Good company starts here."
        description="Your floor, your guests and every table’s next chapter."
        action={
          <ActionLink
            href="/table/1"
            variant="secondary"
            icon="qr_code_scanner"
          >
            Try a guest QR journey
          </ActionLink>
        }
      />
      <div className="toolbar">
        <Chips
          items={["All spaces", "Main room", "Terrace"]}
          value={zone}
          onChange={setZone}
        />
        <Chips
          items={["Floor plan", "List"]}
          value={layout}
          onChange={setLayout}
        />
      </div>
      <div className="floor-status">
        <Badge tone="available">
          {state.tables.filter((t) => t.status === "Available").length}{" "}
          available
        </Badge>
        <Badge tone="occupied">
          {state.tables.filter((t) => t.status === "Occupied").length} occupied
        </Badge>
        <Badge tone="reserved">
          {state.tables.filter((t) => t.status === "Reserved").length} reserved
        </Badge>
        <Badge tone="unpaid">
          {state.tables.filter((t) => t.status === "Needs reset").length} need
          resetting
        </Badge>
      </div>
      <section
        className={`floor-plan panel ${layout === "List" ? "table-list" : ""}`}
      >
        <div className="floor-plan-label">
          <Icon name="door_front" /> ENTRANCE{" "}
          <span>OLIVE & HEARTH · DEMO FLOOR</span>
        </div>
        <div className="floor-tables">
          {state.tables
            .filter((t) => zone === "All spaces" || t.zone === zone)
            .map((t) => (
              <button
                className={`floor-table ${t.status.toLowerCase().replaceAll(" ", "-")}`}
                key={t.id}
                onClick={() => setSelected(t.id)}
              >
                <span className="chair top-left" />
                <span className="chair top-right" />
                <span className="chair bottom-left" />
                <span className="chair bottom-right" />
                <span className="table-number">
                  {String(t.id).padStart(2, "0")}
                </span>
                <span>{t.status}</span>
                <small>
                  {t.zone} · {t.seats} seats
                </small>
                {t.guests > 0 && <small>{t.guests} guests seated</small>}
              </button>
            ))}
        </div>
        <div className="floor-bottom">
          <Icon name="local_florist" /> THE TERRACE{" "}
          <span>Take a breath. Make room for a good moment.</span>
        </div>
      </section>
      {table && (
        <Modal
          title={`Table ${String(table.id).padStart(2, "0")}`}
          onClose={() => setSelected(null)}
        >
          <div className="detail-meta">
            <Badge>{table.status}</Badge>
            <span>
              {table.zone} · {table.seats} seats
            </span>
          </div>
          <div className="qr-card">
            <QRCodeSVG
              value={`${window.location.origin}/table/${table.id}`}
              size={180}
              level="M"
              marginSize={4}
              title={`Guest ordering for table ${table.id}`}
            />
            <h3>Good things start with a scan.</h3>
            <p>
              {state.settings.restaurant} · Table {table.id}
            </p>
            <small>Demo link · devices keep separate local data</small>
          </div>
          <div className="modal-actions">
            <ActionLink href={`/table/${table.id}`} icon="open_in_new">
              Open guest link
            </ActionLink>
            <Button
              variant="secondary"
              icon="print"
              onClick={() => window.print()}
            >
              Print QR
            </Button>
          </div>
          {table.status === "Occupied" && (
            <>
              <h3>Visit orders</h3>
              {state.orders
                .filter((o) => o.visitId === table.visitId)
                .map((o) => (
                  <div className="list-row" key={o.id}>
                    <span>{o.id}</span>
                    <Badge>{o.status}</Badge>
                    <span>{money(o.total)}</span>
                    <Badge>{o.payment}</Badge>
                  </div>
                ))}
              <Button variant="secondary" onClick={() => closeTable(table.id)}>
                Close settled visit
              </Button>
            </>
          )}
          {["Needs reset", "Reserved"].includes(table.status) && (
            <Button
              onClick={() => {
                if (
                  update((s) => {
                    s.tables.find((t) => t.id === table.id)!.status =
                      "Available";
                  }, "tables")
                )
                  notify("Table is ready for the next guests.");
              }}
            >
              Mark table available
            </Button>
          )}
        </Modal>
      )}
    </>
  );
}
