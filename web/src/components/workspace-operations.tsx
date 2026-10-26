"use client";
import { useState, useEffect } from "react";
import { useDemo } from "@/lib/store";
import { useDraft } from "@/lib/use-draft";
import { money, roles, roleNames, type Staff } from "@/lib/domain";
import {
  ActionLink,
  Badge,
  Button,
  Chips,
  DownloadCSV,
  Empty,
  Field,
  Icon,
  Modal,
  PageTitle,
  SectionTitle,
  Search,
  timeLabel,
} from "./ui";
import { OrderDetail, OrderGrid, SalesChart, Stat } from "./workspace";
export function Operations({ section }: { section: string }) {
  switch (section) {
    case "reservations":
      return <Reservations />;
    case "requests":
      return <Requests />;
    case "deliveries":
      return <Deliveries />;
    case "payments":
      return <Payments />;
    case "team":
      return <Team />;
    case "reports":
      return <Reports />;
    case "settings":
      return <Settings />;
    case "storefront":
      return <Storefront />;
    case "activity":
      return <Activity />;
    case "billing":
      return <Billing />;
    default:
      return (
        <Empty
          title="This page isn’t on the menu"
          text="Return to your workspace to continue."
          action={<ActionLink href="/dashboard">Back to overview</ActionLink>}
        />
      );
  }
}
function Reservations() {
  const { state, update, reserve, notify } = useDemo();
  const [filter, setFilter] = useState("Confirmed");
  const [open, setOpen] = useState(false);
  const [dirty, setDirty] = useState(false);
  return (
    <>
      <PageTitle
        eyebrow="SAVE A LITTLE SPACE"
        title="Reservations & arrivals"
        description="A warm welcome, before they even walk in."
        action={
          <Button icon="add" onClick={() => setOpen(true)}>
            New reservation
          </Button>
        }
      />
      <div className="toolbar">
        <Chips
          items={["Confirmed", "Seated", "Cancelled", "No-show", "All"]}
          value={filter}
          onChange={setFilter}
        />
      </div>
      <section className="panel">
        <div className="reservation-list">
          {state.reservations
            .filter((r) => filter === "All" || r.status === filter)
            .map((r) => (
              <article className="reservation-row" key={r.id}>
                <div className="reservation-time">
                  <strong>{r.time}</strong>
                  <small>{r.date}</small>
                </div>
                <div>
                  <h3>{r.name}</h3>
                  <p>
                    {r.guests} guests · {r.id}
                  </p>
                </div>
                <Badge>{r.status}</Badge>
                {r.status === "Confirmed" && (
                  <div className="row-actions">
                    <Button
                      variant="secondary"
                      onClick={() => {
                        if (
                          update((s) => {
                            const t = s.tables.find(
                              (t) =>
                                t.status === "Available" && t.seats >= r.guests,
                            );
                            if (!t)
                              throw new Error(
                                "No available table can seat this party.",
                              );
                            s.reservations.find((x) => x.id === r.id)!.status =
                              "Seated";
                            t.status = "Occupied";
                            t.guests = r.guests;
                            t.visitId = `visit-${crypto.randomUUID()}`;
                          }, "reservations")
                        )
                          notify(
                            "Party seated at the next suitable available table.",
                          );
                      }}
                    >
                      Seat guests
                    </Button>
                    <Button
                      variant="text"
                      onClick={() => {
                        if (confirm("Cancel this reservation?"))
                          update((s) => {
                            s.reservations.find((x) => x.id === r.id)!.status =
                              "Cancelled";
                          }, "reservations");
                      }}
                    >
                      Cancel
                    </Button>
                  </div>
                )}
              </article>
            ))}
          {!state.reservations.some(
            (r) => filter === "All" || r.status === filter,
          ) && (
            <Empty
              icon="calendar_month"
              title="Room for a good evening"
              text="No reservations match this view."
            />
          )}
        </div>
      </section>
      <section className="panel section-gap">
        <SectionTitle title="The waitlist">
          <span className="muted">{state.waitlist.length} parties</span>
        </SectionTitle>
        {state.waitlist.length ? (
          state.waitlist.map((w) => (
            <div className="list-row" key={w.id}>
              <span>
                <strong>{w.name}</strong> · {w.guests} guests
              </span>
              <Badge>{w.status}</Badge>
              <Button
                variant="secondary"
                onClick={() => {
                  update((s) => {
                    s.waitlist.find((x) => x.id === w.id)!.status = "Notified";
                  }, "reservations");
                  notify("Demo notification recorded. No message was sent.");
                }}
              >
                Notify in demo
              </Button>
            </div>
          ))
        ) : (
          <Empty
            icon="group"
            title="Everyone has a place"
            text="Guests who join the demo waitlist will appear here."
          />
        )}
      </section>
      {open && (
        <Modal
          title="Welcome them in"
          onClose={() => setOpen(false)}
          dirty={dirty}
        >
          <form
            onChange={() => setDirty(true)}
            onSubmit={(e) => {
              e.preventDefault();
              const f = new FormData(e.currentTarget);
              if (
                reserve({
                  name: String(f.get("name")),
                  guests: Number(f.get("guests")),
                  date: String(f.get("date")),
                  time: String(f.get("time")),
                })
              ) {
                setOpen(false);
                setDirty(false);
              }
            }}
          >
            <Field label="Guest name">
              <input name="name" required />
            </Field>
            <div className="form-grid">
              <Field label="Party size">
                <input
                  name="guests"
                  type="number"
                  min="1"
                  max="12"
                  defaultValue="2"
                  required
                />
              </Field>
              <Field label="Date">
                <input
                  name="date"
                  type="date"
                  min={new Date().toISOString().slice(0, 10)}
                  required
                />
              </Field>
            </div>
            <Field label="Arrival time">
              <select name="time">
                {[
                  "12:00",
                  "12:30",
                  "13:00",
                  "13:30",
                  "19:00",
                  "19:30",
                  "20:00",
                  "20:30",
                  "21:00",
                ].map((t) => (
                  <option key={t}>{t}</option>
                ))}
              </select>
            </Field>
            <Button type="submit">Create reservation</Button>
          </form>
        </Modal>
      )}
    </>
  );
}
function Requests() {
  const { state, update, notify } = useDemo();
  const [filter, setFilter] = useState("Active");
  const requests = state.requests.filter(
    (r) =>
      filter === "All" ||
      (filter === "Active" && r.status !== "Completed") ||
      filter === r.status,
  );
  return (
    <>
      <PageTitle
        eyebrow="THE LITTLE THINGS MATTER"
        title="At your service."
        description="Water, another fork, the bill. Small requests, thoughtfully handled."
      />
      <Chips
        items={["Active", "New", "Acknowledged", "Completed", "All"]}
        value={filter}
        onChange={setFilter}
      />
      <div className="request-grid section-gap">
        {requests.map((r) => (
          <article className="panel request-card" key={r.id}>
            <div className="between">
              <span className="soft-icon">
                <Icon
                  name={
                    r.kind.includes("Water")
                      ? "water_drop"
                      : r.kind.includes("bill")
                        ? "receipt_long"
                        : "room_service"
                  }
                />
              </span>
              <Badge>{r.status}</Badge>
            </div>
            <span className="eyebrow">
              TABLE {String(r.table).padStart(2, "0")}
            </span>
            <h2>{r.kind}</h2>
            <p>Requested at {timeLabel(r.createdAt)}</p>
            {r.status !== "Completed" && (
              <Button
                variant={r.status === "New" ? "primary" : "secondary"}
                onClick={() => {
                  update((s) => {
                    s.requests.find((x) => x.id === r.id)!.status =
                      r.status === "New" ? "Acknowledged" : "Completed";
                  }, "requests");
                  notify(
                    r.status === "New"
                      ? "Request acknowledged."
                      : "Request completed.",
                  );
                }}
              >
                {r.status === "New" ? "I’ll take care of it" : "Mark completed"}
              </Button>
            )}
          </article>
        ))}
      </div>
      {!requests.length && (
        <Empty
          icon="room_service"
          title="Every little thing is taken care of"
          text="New guest requests will appear here."
        />
      )}
    </>
  );
}
function Deliveries() {
  const { state, update, notify } = useDemo();
  const [filter, setFilter] = useState("Active");
  const [selected, setSelected] = useState<string | null>(null);
  const orders = state.orders.filter(
    (o) =>
      o.channel === "Delivery" &&
      (state.role !== "courier" || o.courier === "Sami") &&
      (filter === "All" ||
        (filter === "Active" &&
          !["Completed", "Cancelled"].includes(o.status)) ||
        filter === o.status),
  );
  return (
    <>
      <PageTitle
        eyebrow="GOOD FOOD, ON ITS WAY"
        title="Beyond your front door."
        description="From kitchen handoff to one happy doorstep."
      />
      <Chips
        items={["Active", "Ready", "Out for delivery", "Completed", "All"]}
        value={filter}
        onChange={setFilter}
      />
      <div className="delivery-grid section-gap">
        {orders.map((o) => (
          <article className="panel" key={o.id}>
            <div className="between">
              <span className="soft-icon">
                <Icon name="moped" />
              </span>
              <Badge>{o.status}</Badge>
            </div>
            <h2>{o.guest}</h2>
            <p>
              <Icon name="location_on" />
              {o.address}
            </p>
            <div className="delivery-route">
              <span>
                <i />
                Olive & Hearth · Pickup
              </span>
              <span>
                <i />
                {o.address}
              </span>
            </div>
            <div className="list-row">
              <span>{o.id}</span>
              <strong>{money(o.total)}</strong>
            </div>
            {state.role !== "courier" && (
              <Field label="Demo courier">
                <select
                  value={o.courier || ""}
                  onChange={(e) => {
                    update((s) => {
                      s.orders.find((x) => x.id === o.id)!.courier =
                        e.target.value;
                    }, "deliveries");
                    notify("Courier assignment updated.");
                  }}
                >
                  <option value="">Unassigned</option>
                  <option>Sami</option>
                </select>
              </Field>
            )}
            <Button
              onClick={() => setSelected(o.id)}
              variant="secondary"
              icon="arrow_forward"
            >
              View delivery
            </Button>
            <Button
              variant="text"
              onClick={() => {
                const note = prompt("Describe the delivery issue (demo only).");
                if (note?.trim()) {
                  update((s) => {
                    s.activity.unshift({
                      id: crypto.randomUUID(),
                      text: `Delivery issue · ${o.id}: ${note.trim()}`,
                      time: new Date().toISOString(),
                    });
                  }, "deliveries");
                  notify("Delivery issue recorded in workspace activity.");
                }
              }}
            >
              Report an issue
            </Button>
          </article>
        ))}
      </div>
      {!orders.length && (
        <Empty
          icon="moped"
          title="No deliveries in this view"
          text="Assigned demo delivery orders will appear here."
        />
      )}
      {selected && (
        <OrderDetail id={selected} onClose={() => setSelected(null)} />
      )}
    </>
  );
}
function Payments() {
  const { state } = useDemo();
  const [filter, setFilter] = useState("All");
  const filtered = state.orders.filter(
    (o) => filter === "All" || o.payment === filter,
  );
  return (
    <>
      <PageTitle
        eyebrow="EVERY AMOUNT, ACCOUNTED FOR"
        title="Payments"
        description="A clear record of demo collections, outstanding balances and refunds."
        action={
          <DownloadCSV
            name="raysto-demo-payments"
            rows={[
              ["Order", "Payment", "Total MAD"],
              ...filtered.map((o) => [o.id, o.payment, o.total / 100]),
            ]}
          />
        }
      />
      <div className="stat-grid three">
        {(["Paid", "Unpaid", "Refunded"] as const).map((status, i) => (
          <Stat
            key={status}
            label={
              status === "Paid"
                ? "Collected"
                : status === "Unpaid"
                  ? "Outstanding"
                  : "Refunded"
            }
            value={money(
              state.orders
                .filter((o) => o.payment === status && o.status !== "Cancelled")
                .reduce((s, o) => s + o.total, 0),
            )}
            note="Local demo records only"
            icon={["payments", "schedule", "undo"][i]}
            accent={i === 0}
          />
        ))}
      </div>
      <div className="notice">
        <Icon name="info" />
        This is a payment simulation. No PayPal account, bank account or card is
        connected.
      </div>
      <section className="panel">
        <div className="table-toolbar">
          <Chips
            items={["All", "Paid", "Unpaid", "Refunded"]}
            value={filter}
            onChange={setFilter}
          />
        </div>
        <OrderGrid orders={filtered} />
      </section>
    </>
  );
}
function Team() {
  const { state, saveStaff, update, notify } = useDemo();
  const [edit, setEdit] = useState<Staff | null>(null);
  const [dirty, setDirty] = useState(false);
  return (
    <>
      <PageTitle
        eyebrow="YOUR PEOPLE MAKE THE PLACE"
        title="A great team. A great service."
        description="Give everyone the right space to do what they do best."
        action={
          <Button
            icon="person_add"
            onClick={() => {
              setEdit({
                id: crypto.randomUUID(),
                name: "",
                email: "",
                role: "waiter",
                active: true,
              });
              setDirty(false);
            }}
          >
            Add demo team member
          </Button>
        }
      />
      <div className="team-grid">
        {state.staff.map((person) => (
          <article className="panel team-card" key={person.id}>
            <div className="between">
              <span className="avatar large">{person.name[0]}</span>
              <Badge tone={person.active ? "available" : "unpaid"}>
                {person.active ? "Active" : "Inactive"}
              </Badge>
            </div>
            <h2>{person.name}</h2>
            <p>{person.email}</p>
            <div className="role-label">
              <Icon name="badge" />
              {roleNames[person.role]}
            </div>
            <div className="row-actions">
              <Button
                variant="secondary"
                onClick={() => {
                  setEdit(structuredClone(person));
                  setDirty(false);
                }}
                disabled={person.role === "owner" && state.role !== "owner"}
              >
                Edit member
              </Button>
              {person.role !== "owner" && (
                <Button
                  variant="text"
                  onClick={() => {
                    if (saveStaff({ ...person, active: !person.active }))
                      notify(
                        `Team member ${person.active ? "deactivated" : "reactivated"}.`,
                      );
                  }}
                >
                  {person.active ? "Deactivate" : "Reactivate"}
                </Button>
              )}
            </div>
          </article>
        ))}
      </div>
      {edit && (
        <Modal
          title="Demo team member"
          onClose={() => setEdit(null)}
          dirty={dirty}
        >
          <form
            onChange={() => setDirty(true)}
            onSubmit={(e) => {
              e.preventDefault();
              if (saveStaff(edit)) setEdit(null);
            }}
          >
            <Field label="Name">
              <input
                value={edit.name}
                required
                onChange={(e) => setEdit({ ...edit, name: e.target.value })}
              />
            </Field>
            <Field
              label="Fictional email"
              hint="Use a .test address. No email is sent."
            >
              <input
                value={edit.email}
                type="email"
                required
                onChange={(e) => setEdit({ ...edit, email: e.target.value })}
              />
            </Field>
            <Field label="Role">
              <select
                value={edit.role}
                onChange={(e) =>
                  setEdit({ ...edit, role: e.target.value as Staff["role"] })
                }
              >
                {roles
                  .filter((r) => state.role === "owner" || r !== "owner")
                  .map((r) => (
                    <option value={r} key={r}>
                      {roleNames[r]}
                    </option>
                  ))}
              </select>
            </Field>
            <Button type="submit">Save team member</Button>
          </form>
        </Modal>
      )}
    </>
  );
}
function Reports() {
  const { state } = useDemo();
  const [period, setPeriod] = useState("Today");
  const cutoff =
    period === "Today"
      ? new Date().setHours(0, 0, 0, 0)
      : period === "7 days"
        ? Date.now() - 7 * 86400000
        : 0;
  const orders = state.orders.filter(
    (o) => new Date(o.createdAt).getTime() >= cutoff,
  );
  const paid = orders.filter((o) => o.payment === "Paid");
  const revenue = paid.reduce((s, o) => s + o.total, 0);
  return (
    <>
      <PageTitle
        eyebrow="SEE THE BIGGER PICTURE"
        title="A little insight. Better decisions."
        description="Honest numbers, calculated from the demo records in this browser."
        action={
          <DownloadCSV
            name="raysto-demo-report"
            rows={[
              ["Period", "Collected MAD", "Orders", "Average paid MAD"],
              [
                period,
                revenue / 100,
                orders.length,
                paid.length ? revenue / paid.length / 100 : 0,
              ],
            ]}
          />
        }
      />
      <div className="toolbar">
        <Chips
          items={["Today", "7 days", "All time"]}
          value={period}
          onChange={setPeriod}
        />
      </div>
      <div className="stat-grid three">
        <Stat
          label="Collected revenue"
          value={money(revenue)}
          note={`${paid.length} paid orders`}
          icon="payments"
          accent
        />
        <Stat
          label="Orders received"
          value={String(orders.length)}
          note={`${orders.filter((o) => o.status === "Cancelled").length} cancelled`}
          icon="receipt_long"
        />
        <Stat
          label="Average paid order"
          value={money(paid.length ? Math.round(revenue / paid.length) : 0)}
          note={`Period: ${period}`}
          icon="monitoring"
        />
      </div>
      <div className="overview-grid">
        <section className="panel">
          <SectionTitle title="Sales by time of day" />
          <SalesChart orders={orders} />
        </section>
        <section className="panel">
          <SectionTitle title="How guests dine" />
          {["Dine-in", "Pickup", "Delivery"].map((channel) => {
            const count = orders.filter((o) => o.channel === channel).length;
            return (
              <div className="channel-report" key={channel}>
                <div>
                  <strong>{channel}</strong>
                  <span>{count} orders</span>
                </div>
                <progress value={count} max={orders.length || 1} />
              </div>
            );
          })}
        </section>
      </div>
      <section className="panel section-gap">
        <SectionTitle title="The dishes they come back for" />
        {state.products
          .map((p) => ({
            product: p,
            quantity: orders.reduce(
              (sum, o) =>
                sum +
                (o.status === "Cancelled"
                  ? 0
                  : o.lines
                      .filter((l) => l.productId === p.id)
                      .reduce((s, l) => s + l.quantity, 0)),
              0,
            ),
          }))
          .sort((a, b) => b.quantity - a.quantity)
          .slice(0, 5)
          .map(({ product, quantity }, i) => (
            <div className="list-row" key={product.id}>
              <span className="rank">0{i + 1}</span>
              <strong>{product.name}</strong>
              <span>{quantity} portions</span>
            </div>
          ))}
      </section>
    </>
  );
}
function Settings() {
  const { state, update, notify } = useDemo();
  const { draft, setDraft, dirty } = useDraft(
    "restaurant",
    state.settings,
    "restaurant",
  );
  return (
    <>
      <PageTitle
        eyebrow="MAKE YOURSELF AT HOME"
        title="Restaurant settings"
        description="The essentials that keep your service running your way."
      />
      <form
        onSubmit={(e) => {
          e.preventDefault();
          if (
            update((s) => {
              s.settings = { ...draft };
            }, "settings")
          )
            notify("Restaurant settings saved in this browser.");
        }}
      >
        <div className="settings-layout">
          <section className="panel">
            <SectionTitle title="The restaurant" />
            <Field label="Restaurant name">
              <input
                required
                value={draft.restaurant}
                onChange={(e) =>
                  setDraft({ ...draft, restaurant: e.target.value })
                }
              />
            </Field>
            <Field label="A little about your place">
              <textarea
                required
                value={draft.description}
                onChange={(e) =>
                  setDraft({ ...draft, description: e.target.value })
                }
              />
            </Field>
            <Field label="Address">
              <input
                required
                value={draft.address}
                onChange={(e) =>
                  setDraft({ ...draft, address: e.target.value })
                }
              />
            </Field>
            <Field label="Phone">
              <input
                required
                type="tel"
                value={draft.phone}
                onChange={(e) => setDraft({ ...draft, phone: e.target.value })}
              />
            </Field>
          </section>
          <div>
            <section className="panel">
              <SectionTitle title="Service, your way" />
              {(["open", "pickup", "delivery"] as const).map((key) => (
                <label className="setting-row" key={key}>
                  <span>
                    <strong>
                      {key === "open"
                        ? "Accept new orders"
                        : key === "pickup"
                          ? "Pickup"
                          : "Delivery"}
                    </strong>
                    <small>
                      {key === "open"
                        ? "Pause new orders without losing existing ones."
                        : key === "pickup"
                          ? "Let guests collect their favorites."
                          : "Demo delivery within Casablanca."}
                    </small>
                  </span>
                  <input
                    type="checkbox"
                    role="switch"
                    checked={draft[key]}
                    onChange={(e) =>
                      setDraft({ ...draft, [key]: e.target.checked })
                    }
                  />
                </label>
              ))}
              <div className="form-grid">
                <Field label="Delivery fee (MAD)">
                  <input
                    type="number"
                    min="0"
                    max="1000"
                    step="0.01"
                    required
                    value={draft.deliveryFee / 100}
                    onChange={(e) =>
                      setDraft({
                        ...draft,
                        deliveryFee: Math.round(Number(e.target.value) * 100),
                      })
                    }
                  />
                </Field>
                <Field label="Minimum order (MAD)">
                  <input
                    type="number"
                    min="0"
                    max="10000"
                    required
                    value={draft.minimum / 100}
                    onChange={(e) =>
                      setDraft({
                        ...draft,
                        minimum: Math.round(Number(e.target.value) * 100),
                      })
                    }
                  />
                </Field>
              </div>
              <p className="muted">
                Demo hours: 12:00–22:00. Availability is controlled by “Accept
                new orders” in phase 1.
              </p>
            </section>
            <section className="panel section-gap">
              <SectionTitle title="Appearance & motion" />
              {(["dark", "reducedMotion"] as const).map((key) => (
                <label className="setting-row" key={key}>
                  <span>
                    {key === "dark" ? "Dark appearance" : "Reduce motion"}
                  </span>
                  <input
                    type="checkbox"
                    role="switch"
                    checked={draft[key]}
                    onChange={(e) =>
                      setDraft({ ...draft, [key]: e.target.checked })
                    }
                  />
                </label>
              ))}
            </section>
          </div>
        </div>
        <div className="save-bar">
          <span>
            {dirty ? "You have unsaved changes." : "Everything is up to date."}
          </span>
          <Button
            type="button"
            variant="secondary"
            disabled={!dirty}
            onClick={() => setDraft(state.settings)}
          >
            Discard changes
          </Button>
          <Button type="submit" disabled={!dirty} icon="check">
            Save changes
          </Button>
        </div>
      </form>
    </>
  );
}
function Storefront() {
  const { state } = useDemo();
  return (
    <>
      <PageTitle
        eyebrow="YOUR DIGITAL FRONT DOOR"
        title="A warm first impression."
        description="Preview the guest experience using your current menu and service settings."
        action={
          <ActionLink href="/r/olive-and-hearth" icon="open_in_new">
            Open storefront
          </ActionLink>
        }
      />
      <section className="storefront-preview panel">
        <img
          src="/images/wood_fired_pizza.jpg"
          alt="Illustrative wood-fired pizza"
        />
        <div>
          <span className="eyebrow">MEDITERRANEAN · CASABLANCA</span>
          <h1>{state.settings.restaurant}</h1>
          <p>{state.settings.description}</p>
          <Badge tone={state.settings.open ? "available" : "unpaid"}>
            {state.settings.open ? "Accepting demo orders" : "Service paused"}
          </Badge>
          <div className="section-gap">
            <ActionLink
              href="/dashboard/settings"
              variant="secondary"
              icon="edit"
            >
              Edit restaurant details
            </ActionLink>
          </div>
        </div>
      </section>
      <div className="settings-layout section-gap">
        <section className="panel">
          <SectionTitle title="Ready for a little company" />
          {[
            ["restaurant", "Restaurant profile", true],
            [
              "restaurant_menu",
              `${state.products.filter((p) => p.available).length} available menu items`,
              state.products.some((p) => p.available),
            ],
            ["qr_code", `${state.tables.length} table QR links`, true],
          ].map(([icon, label, done]) => (
            <div className="list-row" key={String(icon)}>
              <Icon name={String(icon)} />
              <strong>{label}</strong>
              <Icon name={done ? "check_circle" : "pending"} />
            </div>
          ))}
        </section>
        <section className="panel">
          <h2>A public experience, in demo mode.</h2>
          <p>
            The guest pages need no account. The current preview is local;
            publishing and connecting the real backend are separate deployment
            steps.
          </p>
          <p>
            QR codes use this preview’s address. A phone needs a reachable
            hosted or LAN address to open them.
          </p>
        </section>
      </div>
    </>
  );
}
function Activity() {
  const { state } = useDemo();
  return (
    <>
      <PageTitle
        eyebrow="THE STORY OF YOUR SERVICE"
        title="Activity"
        description="A shared record of what changed in this browser’s demo restaurant."
      />
      <section className="panel activity-list">
        {state.activity.map((a) => (
          <div className="activity-row" key={a.id}>
            <span className="soft-icon">
              <Icon
                name={a.text.includes("issue") ? "priority_high" : "check"}
              />
            </span>
            <div>
              <strong>{a.text}</strong>
              <p>
                {new Date(a.time).toLocaleDateString("en")} ·{" "}
                {timeLabel(a.time)}
              </p>
            </div>
          </div>
        ))}
      </section>
    </>
  );
}
function Billing() {
  return (
    <>
      <PageTitle
        title="Room to grow."
        description="An illustrative plan preview. No subscription or charge is created."
      />
      <section className="panel">
        <span className="demo-tag">PHASE 1</span>
        <h2>Raysto demo</h2>
        <p>Explore the complete workspace and guest journey with local data.</p>
        <Badge tone="available">No billing connected</Badge>
        <div className="section-gap">
          <ActionLink href="/dashboard">Back to your workspace</ActionLink>
        </div>
      </section>
    </>
  );
}
