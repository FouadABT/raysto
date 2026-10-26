"use client";
import Link from "next/link";
import {
  SupperHero,
  SmoothExperience,
  StoryPhoto,
  OliveDrawing,
} from "./experience";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useDemo } from "@/lib/store";
import { useDraft } from "@/lib/use-draft";
import { calculate, money, type Channel, type Product } from "@/lib/domain";
import {
  ActionLink,
  Badge,
  Brand,
  Button,
  Chips,
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

export function GuestApp({ path }: { path: string[] }) {
  const { state } = useDemo();
  const [nav, setNav] = useState(false);
  const first = path[0] || "discover";
  const count = state.cart.reduce((sum, l) => sum + l.quantity, 0);
  const content = () => {
    switch (first) {
      case "discover":
        return <Discover />;
      case "r":
        return path[1] === "olive-and-hearth" ? <Restaurant /> : <Missing />;
      case "table":
        return <TableJoin tableId={path[1]} />;
      case "scan":
        return <Scan />;
      case "cart":
        return <Cart />;
      case "checkout":
        return <Checkout />;
      case "orders":
        return path[1] ? <GuestOrder id={path[1]} /> : <GuestOrders />;
      case "visit":
        return <Visit />;
      case "reservations":
        return <GuestReservations />;
      case "favorites":
        return <Favorites />;
      case "account":
        return <Account />;
      case "help":
        return <Help />;
      case "about":
        return <About />;
      default:
        return <Missing />;
    }
  };
  return (
    <div className="guest-app">
      <SmoothExperience />
      <div className="guest-demo-bar">
        <span>A taste of Raysto · Interactive demo</span>
        <Link href="/login">
          For restaurant teams <Icon name="north_east" />
        </Link>
      </div>
      <header className="guest-header">
        <Brand />
        <nav aria-label="Guest navigation">
          <Link
            href="/discover"
            className={first === "discover" ? "active" : ""}
          >
            Discover
          </Link>
          <Link
            href="/r/olive-and-hearth"
            className={first === "r" ? "active" : ""}
          >
            Our restaurant
          </Link>
          <Link href="/orders" className={first === "orders" ? "active" : ""}>
            Your orders
          </Link>
          <Link
            href="/reservations"
            className={first === "reservations" ? "active" : ""}
          >
            Book a table
          </Link>
        </nav>
        <div className="header-actions">
          <Link
            href="/scan"
            className="icon-button"
            aria-label="Open QR or table code"
          >
            <Icon name="qr_code_scanner" />
          </Link>
          <Link
            href="/favorites"
            className="icon-button hide-small"
            aria-label="Your favorites"
          >
            <Icon name="favorite" />
          </Link>
          <Link
            href="/cart"
            className="basket-link"
            aria-label={`Basket, ${count} items`}
          >
            <Icon name="shopping_bag" />
            <span className="basket-word">Basket</span>
            <span className="basket-count">{count}</span>
          </Link>
          <Link
            href="/account"
            className="avatar hide-small"
            aria-label="Your demo account"
          >
            {state.profile.name[0]}
          </Link>
          <span className="mobile-menu">
            <IconButton
              name="menu"
              label="Open guest navigation"
              onClick={() => setNav(true)}
            />
          </span>
        </div>
      </header>
      {state.visit && first !== "visit" && (
        <Link href="/visit" className="visit-strip">
          <Icon name="table_restaurant" />
          You’re at table {state.visit.table} · View your visit{" "}
          <Icon name="arrow_forward" />
        </Link>
      )}
      <main
        id="main"
        className={`guest-content ${first === "discover" ? "discover-content" : ""}`}
        key={path.join("/")}
      >
        {content()}
      </main>
      <footer className="guest-footer">
        <div>
          <Brand />
          <p>
            Good food. Good company.
            <br />A little more hospitality.
          </p>
        </div>
        <div>
          <strong>Come on in</strong>
          <Link href="/discover">Discover</Link>
          <Link href="/reservations">Reserve a table</Link>
          <Link href="/scan">At a table? Start here</Link>
        </div>
        <div>
          <strong>Make yourself at home</strong>
          <Link href="/account">Your preferences</Link>
          <Link href="/help">A little help</Link>
          <Link href="/about">About this demo</Link>
        </div>
        <div className="footer-note">
          <OliveDrawing />
          <span className="eyebrow">THOUGHTFULLY MADE</span>
          <p>
            Restaurant details and photography are illustrative. Orders and
            payments are simulated in this browser.
          </p>
          <small>© {new Date().getFullYear()} Raysto</small>
        </div>
      </footer>
      <nav className="guest-mobile-nav" aria-label="Mobile guest navigation">
        {[
          ["discover", "explore", "Discover"],
          ["orders", "receipt_long", "Orders"],
          [
            state.visit ? "visit" : "scan",
            "qr_code_scanner",
            state.visit ? "Your table" : "Scan",
          ],
          ["account", "person", "You"],
        ].map(([route, icon, label]) => (
          <Link
            href={`/${route}`}
            className={first === route ? "active" : ""}
            key={route}
          >
            <Icon name={icon} />
            <span>{label}</span>
          </Link>
        ))}
      </nav>
      {nav && (
        <Modal title="Make yourself at home" onClose={() => setNav(false)}>
          <div className="mobile-nav-links">
            {[
              ["/discover", "Discover"],
              ["/r/olive-and-hearth", "Our restaurant"],
              ["/orders", "Your orders"],
              ["/reservations", "Book a table"],
              ["/favorites", "Favorites"],
              ["/account", "Your account"],
              ["/login", "Restaurant workspace"],
            ].map(([href, label]) => (
              <Link onClick={() => setNav(false)} href={href} key={href}>
                {label}
                <Icon name="arrow_forward" />
              </Link>
            ))}
          </div>
        </Modal>
      )}
    </div>
  );
}
function Discover() {
  const { state, update } = useDemo();
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState("All cravings");
  const [item, setItem] = useState<Product | null>(null);
  const products = state.products.filter(
    (p) =>
      (filter === "All cravings" ||
        (filter === "Vegetarian" && p.tags.includes("Vegetarian")) ||
        p.category === filter) &&
      `${p.name} ${p.description} ${state.settings.restaurant}`
        .toLowerCase()
        .includes(query.toLowerCase()),
  );
  return (
    <>
      <SupperHero />
      <section className="guest-section" id="discover-menu">
        <div className="section-heading">
          <div>
            <span className="eyebrow">FOLLOW YOUR APPETITE</span>
            <h2>
              Follow your <em>appetite.</em>
            </h2>
          </div>
          <ActionLink
            href="/r/olive-and-hearth"
            variant="text"
            icon="arrow_forward"
          >
            Explore the full menu
          </ActionLink>
        </div>
        <div className="discovery-tools">
          <Search
            value={query}
            onChange={setQuery}
            placeholder="What are you craving?"
          />
          <span className="eyebrow">FRESH PICKS · MADE WITH CARE</span>
        </div>
        <div className="category-row">
          {[
            ["All cravings", "restaurant"],
            ["Starters", "eco"],
            ["Mains", "dinner_dining"],
            ["Pizza", "local_pizza"],
            ["Drinks", "local_cafe"],
            ["Vegetarian", "nutrition"],
          ].map(([name, icon]) => (
            <button
              className={`category-button ${filter === name ? "active" : ""}`}
              onClick={() => setFilter(name)}
              aria-pressed={filter === name}
              key={name}
            >
              <span>
                <Icon name={icon} />
              </span>
              {name}
            </button>
          ))}
        </div>
        <div className="guest-product-grid">
          {products.slice(0, 6).map((p) => (
            <ProductCard key={p.id} product={p} onOpen={() => setItem(p)} />
          ))}
        </div>
        {!products.length && (
          <Empty
            title="A different craving?"
            text="We couldn’t find a match. Try pasta, pizza or salad."
            action={
              <Button
                onClick={() => {
                  setQuery("");
                  setFilter("All cravings");
                }}
              >
                Show all dishes
              </Button>
            }
          />
        )}
      </section>
      <section className="restaurant-feature">
        <StoryPhoto />
        <div className="restaurant-feature-copy">
          <OliveDrawing />
          <span className="eyebrow">THE NEIGHBORHOOD, AT YOUR TABLE</span>
          <h2>{state.settings.restaurant}</h2>
          <p>{state.settings.description}</p>
          <div className="restaurant-meta">
            <span>
              <Icon name="location_on" />
              Casablanca
            </span>
            <span>
              <Icon name="schedule" />
              20–30 min · demo estimate
            </span>
          </div>
          <ActionLink href="/r/olive-and-hearth" icon="arrow_forward">
            Meet your next favorite
          </ActionLink>
        </div>
      </section>
      <section className="guest-section dine-banner">
        <span className="oversized-symbol">
          <Icon name="qr_code_scanner" />
        </span>
        <div>
          <span className="eyebrow">ALREADY AT THE TABLE?</span>
          <h2>
            Less waiting.
            <br />
            More being here.
          </h2>
          <p>
            Scan the QR on your table, find something delicious and leave the
            rest to the team.
          </p>
        </div>
        <ActionLink href="/scan" variant="secondary" icon="qr_code_scanner">
          Open a table
        </ActionLink>
      </section>
      {item && <ProductModal product={item} onClose={() => setItem(null)} />}
    </>
  );
}
export function ProductCard({
  product,
  onOpen,
}: {
  product: Product;
  onOpen: () => void;
}) {
  const { state, update } = useDemo();
  const favorite = state.favorites.includes(product.id);
  return (
    <article
      className={`product-card ${!product.available ? "unavailable" : ""}`}
    >
      <div className="product-image-wrap">
        <button
          onClick={onOpen}
          className="product-image-button"
          aria-label={`View ${product.name}`}
        >
          <FoodImage image={product.image} name={product.name} />
        </button>
        {product.tags[1] && (
          <span className="image-badge">{product.tags[1]}</span>
        )}
        <button
          className={`favorite-button ${favorite ? "active" : ""}`}
          aria-label={`${favorite ? "Unsave" : "Save"} ${product.name}`}
          aria-pressed={favorite}
          onClick={() =>
            update((s) => {
              s.favorites = favorite
                ? s.favorites.filter((id) => id !== product.id)
                : [...s.favorites, product.id];
            })
          }
        >
          <Icon name="favorite" />
        </button>
      </div>
      <div className="product-info">
        <small>
          {product.category} <span>·</span> {product.tags[0]}
        </small>
        <button className="product-name" onClick={onOpen}>
          <h3>{product.name}</h3>
        </button>
        <p>{product.description}</p>
        <div className="product-bottom">
          <strong>{money(product.price)}</strong>
          <button
            aria-label={`Add ${product.name}`}
            className="add-button"
            disabled={!product.available}
            onClick={onOpen}
          >
            {product.available ? <Icon name="add" /> : "Sold out"}
          </button>
        </div>
      </div>
    </article>
  );
}
export function ProductModal({
  product,
  onClose,
}: {
  product: Product;
  onClose: () => void;
}) {
  const { addItem } = useDemo();
  const [qty, setQty] = useState(1);
  const [option, setOption] = useState("Regular");
  const [note, setNote] = useState("");
  return (
    <Modal
      title={product.name}
      onClose={onClose}
      dirty={!!note || qty !== 1 || option !== "Regular"}
    >
      <FoodImage
        className="product-detail-image"
        image={product.image}
        name={product.name}
      />
      <p>{product.description}</p>
      <div className="allergen-note">
        <Icon name="info" />
        <div>
          <strong>Let’s talk ingredients.</strong>
          <p>
            {product.allergens} Please check with the team if you have an
            allergy.
          </p>
        </div>
      </div>
      <fieldset className="option-fieldset">
        <legend>
          Make it your size <span>Required</span>
        </legend>
        {["Regular", "Large"].map((size) => (
          <label className="option-row" key={size}>
            <input
              type="radio"
              name="size"
              value={size}
              checked={option === size}
              onChange={() => setOption(size)}
            />
            <strong>{size}</strong>
            <span>{size === "Regular" ? "Included" : `+${money(2500)}`}</span>
          </label>
        ))}
      </fieldset>
      <Field label="A note for the kitchen (optional)">
        <textarea
          maxLength={300}
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder="Anything you’d like us to know?"
        />
      </Field>
      <div className="product-modal-footer">
        <Quantity value={qty} onChange={setQty} />
        <Button
          disabled={!product.available}
          icon="shopping_bag"
          onClick={() => {
            addItem(product, qty, option, note);
            onClose();
          }}
        >
          Add · {money((product.price + (option === "Large" ? 2500 : 0)) * qty)}
        </Button>
      </div>
    </Modal>
  );
}
function Quantity({
  value,
  onChange,
}: {
  value: number;
  onChange: (n: number) => void;
}) {
  return (
    <div className="quantity">
      <button
        aria-label="Decrease quantity"
        disabled={value <= 1}
        onClick={() => onChange(value - 1)}
      >
        <Icon name="remove" />
      </button>
      <output aria-live="polite">{value}</output>
      <button
        aria-label="Increase quantity"
        disabled={value >= 20}
        onClick={() => onChange(value + 1)}
      >
        <Icon name="add" />
      </button>
    </div>
  );
}
function Restaurant() {
  const { state, update } = useDemo();
  const [category, setCategory] = useState("All dishes");
  const [query, setQuery] = useState("");
  const [item, setItem] = useState<Product | null>(null);
  const [info, setInfo] = useState(false);
  const products = state.products.filter(
    (p) =>
      (category === "All dishes" || p.category === category) &&
      `${p.name} ${p.description}`.toLowerCase().includes(query.toLowerCase()),
  );
  return (
    <>
      <div className="restaurant-hero">
        <img
          src="/images/olive-room.webp"
          alt="Generated illustration of the Olive & Hearth dining room"
        />
        <div className="restaurant-hero-overlay">
          <span className="eyebrow">MEDITERRANEAN SOUL. MOROCCAN HEART.</span>
          <h1>{state.settings.restaurant}</h1>
          <p>{state.settings.description}</p>
        </div>
        <Badge tone={state.settings.open ? "available" : "unpaid"}>
          {state.settings.open ? "Open for demo orders" : "Service paused"}
        </Badge>
      </div>
      <div className="restaurant-info-bar">
        <span>
          <Icon name="location_on" />
          Casablanca
        </span>
        <span>
          <Icon name="schedule" />
          12:00–22:00 · Demo hours
        </span>
        <button onClick={() => setInfo(true)}>
          <Icon name="info" />
          Restaurant information
        </button>
        <Link href="/reservations">
          <Icon name="calendar_month" />
          Book a table
        </Link>
      </div>
      <div className="menu-page-layout">
        <aside className="menu-category-nav">
          <span className="eyebrow">SOMETHING FOR EVERY CRAVING</span>
          <h2>Our menu</h2>
          {[
            "All dishes",
            ...new Set(state.products.map((p) => p.category)),
          ].map((c) => (
            <button
              key={c}
              className={c === category ? "active" : ""}
              aria-pressed={c === category}
              onClick={() => setCategory(c)}
            >
              {c}
              <Icon name="chevron_right" />
            </button>
          ))}
          <div className="small-note">
            <Icon name="eco" />
            <p>
              Made with care.
              <br />
              Enjoyed together.
            </p>
          </div>
        </aside>
        <section>
          <div className="menu-service-bar">
            <Chips
              items={["Pickup", "Delivery", "Dine-in"]}
              value={state.channel}
              onChange={(value) => {
                if (value === "Dine-in" && !state.visit) {
                  window.location.assign("/scan");
                  return;
                }
                update((s) => {
                  s.channel = value as Channel;
                });
              }}
            />
            <Search
              value={query}
              onChange={setQuery}
              placeholder="Search the menu"
            />
          </div>
          <div className="between menu-heading">
            <h2>
              {category === "All dishes" ? "Find your favorite." : category}
            </h2>
            <span className="muted">{products.length} dishes</span>
          </div>
          <div className="restaurant-product-grid">
            {products.map((p) => (
              <ProductCard key={p.id} product={p} onOpen={() => setItem(p)} />
            ))}
          </div>
          {!products.length && (
            <Empty
              title="Nothing on this plate yet"
              text="Try a different search or category."
              action={
                <Button
                  onClick={() => {
                    setQuery("");
                    setCategory("All dishes");
                  }}
                >
                  Clear filters
                </Button>
              }
            />
          )}
        </section>
      </div>
      {state.cart.length > 0 && (
        <Link className="floating-basket" href="/cart">
          <span>
            <span className="basket-count">
              {state.cart.reduce((s, l) => s + l.quantity, 0)}
            </span>{" "}
            View your basket
          </span>
          <strong>
            {money(
              calculate(state.cart, state.channel, state.settings.deliveryFee)
                .total,
            )}
            <Icon name="arrow_forward" />
          </strong>
        </Link>
      )}
      {item && <ProductModal product={item} onClose={() => setItem(null)} />}
      {info && (
        <Modal
          title="A little about Olive & Hearth"
          onClose={() => setInfo(false)}
        >
          <p>{state.settings.description}</p>
          <div className="info-rows">
            <p>
              <Icon name="location_on" />
              {state.settings.address}
            </p>
            <p>
              <Icon name="schedule" />
              Daily, 12:00–22:00 (illustrative)
            </p>
            <p>
              <Icon name="call" />
              {state.settings.phone} (demo number)
            </p>
          </div>
          <div className="notice">
            This restaurant, its dishes and dietary descriptions are
            illustrative. Ask staff about allergies before placing a real order.
          </div>
        </Modal>
      )}
    </>
  );
}
function Scan() {
  const router = useRouter();
  const [code, setCode] = useState("");
  const [error, setError] = useState("");
  return (
    <div className="narrow-page">
      <PageTitle
        eyebrow="PULL UP A CHAIR"
        title="Your table is the starting point."
        description="Scan a printed QR with your phone’s camera, or enter the table code below."
      />
      <section className="panel scan-card">
        <div className="scan-illustration">
          <Icon name="qr_code_scanner" />
        </div>
        <h2>Good things start here.</h2>
        <p>
          For this demo, try table 1, 3 or 8. Joining a table is always your
          choice.
        </p>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            let id = code.trim();
            try {
              if (id.startsWith("http")) {
                const url = new URL(id);
                if (url.origin !== window.location.origin) throw new Error();
                id = url.pathname.split("/table/")[1] || "";
              }
            } catch {
              setError("Use a table link from this Raysto preview.");
              return;
            }
            if (!/^\d+$/.test(id) || Number(id) < 1 || Number(id) > 12) {
              setError(
                "Enter a table number from 1 to 12, or a valid table QR link.",
              );
              return;
            }
            router.push(`/table/${Number(id)}`);
          }}
        >
          <Field label="Table number or QR link">
            <input
              value={code}
              onChange={(e) => {
                setCode(e.target.value);
                setError("");
              }}
              required
              placeholder="e.g. 1"
            />
          </Field>
          {error && (
            <p className="error-text" role="alert">
              {error}
            </p>
          )}
          <Button type="submit" icon="arrow_forward">
            Find my table
          </Button>
        </form>
        <p className="fine-print">
          No camera permission is needed here. Your phone’s normal QR scanner
          opens the same confirmation page.
        </p>
      </section>
    </div>
  );
}
function TableJoin({ tableId }: { tableId: string }) {
  const { state, joinTable } = useDemo();
  const router = useRouter();
  const [guests, setGuests] = useState(2);
  const table = state.tables.find((t) => String(t.id) === tableId);
  if (!table)
    return (
      <Empty
        icon="qr_code"
        title="We couldn’t find this table"
        text="The code may be incorrect. Ask the team or enter the number again."
        action={<ActionLink href="/scan">Try another code</ActionLink>}
      />
    );
  const own = state.visit?.id === table.visitId && !!state.visit;
  return (
    <div className="narrow-page">
      <PageTitle
        eyebrow="YOU’RE IN GOOD COMPANY"
        title={`Welcome to table ${String(table.id).padStart(2, "0")}.`}
        description={`${state.settings.restaurant} · ${table.zone}`}
      />
      <section className="panel table-welcome">
        <div className="table-illustration">
          <Icon name="table_restaurant" />
          <span>{String(table.id).padStart(2, "0")}</span>
        </div>
        <Badge>{table.status}</Badge>
        <h2>A little space for your people.</h2>
        <p>
          Up to {table.seats} guests. Browse the menu, order another round and
          ask the team for a hand, right here.
        </p>
        {own ? (
          <ActionLink href="/visit" icon="arrow_forward">
            Return to your visit
          </ActionLink>
        ) : table.status === "Available" ? (
          <>
            <Field label="How many of you are joining?">
              <select
                value={guests}
                onChange={(e) => setGuests(Number(e.target.value))}
              >
                {Array.from({ length: table.seats }, (_, i) => (
                  <option key={i} value={i + 1}>
                    {i + 1} {i === 0 ? "guest" : "guests"}
                  </option>
                ))}
              </select>
            </Field>
            <Button
              icon="restaurant"
              onClick={() => {
                if (joinTable(table.id, guests))
                  router.push("/r/olive-and-hearth");
              }}
            >
              Join table & explore the menu
            </Button>
            <small>
              Starts a new visit in this browser’s demo. A QR link alone does
              not join an existing party.
            </small>
          </>
        ) : (
          <>
            <div className="notice">
              This table is {table.status.toLowerCase()}. Please ask your host
              for an available table.
            </div>
            <ActionLink href="/scan" variant="secondary">
              Try another table
            </ActionLink>
          </>
        )}
      </section>
    </div>
  );
}
function Cart() {
  const { state, update, notify } = useDemo();
  const [removed, setRemoved] = useState<{
    line: (typeof state.cart)[number];
    index: number;
  } | null>(null);
  const [edit, setEdit] = useState<string | null>(null);
  const [note, setNote] = useState("");
  if (!state.cart.length && !removed)
    return (
      <div className="narrow-page">
        <Empty
          icon="shopping_bag"
          title="A little room for something delicious."
          text="Your basket is waiting for your next favorite."
          action={
            <ActionLink href="/r/olive-and-hearth">Explore the menu</ActionLink>
          }
        />
      </div>
    );
  const totals = calculate(
    state.cart,
    state.channel,
    state.settings.deliveryFee,
  );
  return (
    <>
      <PageTitle
        eyebrow="GOOD CHOICES, ALL OF THEM"
        title="Your little feast."
        description={`${state.settings.restaurant} · ${state.channel}`}
      />
      <div className="checkout-layout">
        <section className="panel basket-items">
          {removed && (
            <div className="undo-notice">
              <span>{removed.line.name} removed.</span>
              <Button
                variant="text"
                onClick={() => {
                  update((s) => s.cart.splice(removed.index, 0, removed.line));
                  setRemoved(null);
                }}
              >
                Undo
              </Button>
            </div>
          )}
          {state.cart.map((line) => (
            <div className="cart-item" key={line.id}>
              <FoodImage image={line.image} name={line.name} />
              <div className="cart-item-content">
                <h3>{line.name}</h3>
                <p>
                  {line.option}
                  {line.note && ` · ${line.note}`}
                </p>
                <button
                  className="text-link"
                  onClick={() => {
                    setEdit(line.id);
                    setNote(line.note);
                  }}
                >
                  Edit kitchen note
                </button>
                <Quantity
                  value={line.quantity}
                  onChange={(n) =>
                    update((s) => {
                      s.cart.find((l) => l.id === line.id)!.quantity = n;
                    })
                  }
                />
              </div>
              <div className="cart-item-end">
                <strong>{money(line.price * line.quantity)}</strong>
                <IconButton
                  name="delete"
                  label={`Remove ${line.name}`}
                  onClick={() => {
                    setRemoved({
                      line: structuredClone(line),
                      index: state.cart.findIndex((l) => l.id === line.id),
                    });
                    update((s) => {
                      s.cart = s.cart.filter((l) => l.id !== line.id);
                    });
                  }}
                />
              </div>
            </div>
          ))}
          <ActionLink href="/r/olive-and-hearth" icon="add" variant="text">
            Something else catch your eye?
          </ActionLink>
        </section>
        <aside className="panel checkout-summary">
          <h2>A good meal, summed up.</h2>
          <Field label="How would you like to enjoy it?">
            <select
              value={state.channel}
              onChange={(e) =>
                update((s) => {
                  s.channel = e.target.value as Channel;
                })
              }
            >
              <option>Pickup</option>
              <option>Delivery</option>
              {state.visit && <option>Dine-in</option>}
            </select>
          </Field>
          <Totals {...totals} />
          <ActionLink
            href="/checkout"
            icon="arrow_forward"
            className={state.cart.length ? "" : "disabled"}
          >
            Continue to checkout
          </ActionLink>
          <p className="fine-print">A demo order. No money changes hands.</p>
        </aside>
      </div>
      {edit && (
        <Modal
          title="A note for the kitchen"
          onClose={() => setEdit(null)}
          dirty={note !== state.cart.find((l) => l.id === edit)?.note}
        >
          <Field label="Anything we should know?">
            <textarea
              maxLength={300}
              value={note}
              onChange={(e) => setNote(e.target.value)}
            />
          </Field>
          <Button
            onClick={() => {
              update((s) => {
                const l = s.cart.find((l) => l.id === edit);
                if (l) l.note = note;
              });
              setEdit(null);
              notify("Kitchen note saved.");
            }}
          >
            Save note
          </Button>
        </Modal>
      )}
    </>
  );
}
function Checkout() {
  const { state, checkout } = useDemo();
  const router = useRouter();
  const [address, setAddress] = useState(state.profile.address);
  const [tip, setTip] = useState("No tip");
  const [coupon, setCoupon] = useState("");
  const [couponApplied, setCouponApplied] = useState(false);
  const [method, setMethod] = useState("Pay now · demo");
  const [outcome, setOutcome] = useState("Success");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [agreement, setAgreement] = useState(false);
  const tips: Record<string, number> = {
    "No tip": 0,
    "10 MAD": 1000,
    "20 MAD": 2000,
    "30 MAD": 3000,
  };
  const totals = calculate(
    state.cart,
    state.channel,
    state.settings.deliveryFee,
    tips[tip],
    couponApplied,
  );
  if (!state.cart.length)
    return (
      <Empty
        icon="shopping_bag"
        title="Your basket is empty"
        text="Add a dish before checking out."
        action={
          <ActionLink href="/r/olive-and-hearth">Explore the menu</ActionLink>
        }
      />
    );
  return (
    <>
      <PageTitle
        eyebrow="JUST ONE MORE LITTLE THING"
        title="Let’s make it a meal."
        description="Review your details. We’ll take it from here—in the demo."
      />
      <form
        className="checkout-layout"
        onSubmit={(e) => {
          e.preventDefault();
          if (submitting) return;
          if (method === "Pay now · demo" && outcome !== "Success") {
            setError(
              outcome === "Failed"
                ? "The simulated payment failed. Your basket is safe. Choose Success to retry."
                : "The simulated payment was cancelled. Nothing was charged and your basket is saved.",
            );
            return;
          }
          setSubmitting(true);
          const id = checkout({
            address,
            tip: tips[tip],
            coupon: couponApplied,
            paid: method === "Pay now · demo",
          });
          if (id) router.push(`/orders/${id}`);
          else setSubmitting(false);
        }}
      >
        <div>
          <section className="panel">
            <SectionTitle
              title={
                state.channel === "Delivery"
                  ? "A good meal, delivered."
                  : state.channel === "Dine-in"
                    ? `At your table, ${state.visit?.table || ""}.`
                    : "Ready when you are."
              }
            />
            <p>
              {state.channel === "Pickup"
                ? `Collect at ${state.settings.address}. Demo preparation estimate: 20–30 minutes.`
                : state.channel === "Delivery"
                  ? "Demo delivery is available within Casablanca."
                  : "Your new round will be added to this table visit."}
            </p>
            {state.channel === "Delivery" && (
              <Field
                label="Delivery address"
                hint="Include Casablanca. This is an illustrative service area."
              >
                <textarea
                  required
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                />
              </Field>
            )}
            <Field label="Guest name">
              <input value={state.profile.name} readOnly />
            </Field>
            <ActionLink href="/account" variant="text">
              Edit guest details
            </ActionLink>
          </section>
          <section className="panel section-gap">
            <SectionTitle title="A little thank you for the team" />
            <Chips items={Object.keys(tips)} value={tip} onChange={setTip} />
          </section>
          <section className="panel section-gap">
            <SectionTitle title="How would you like to pay?" />
            {["Pay now · demo", "Pay at restaurant · demo"]
              .filter(
                (m) => state.channel !== "Delivery" || m === "Pay now · demo",
              )
              .map((m) => (
                <label className="option-row" key={m}>
                  <input
                    type="radio"
                    name="method"
                    checked={method === m}
                    onChange={() => setMethod(m)}
                  />
                  <Icon
                    name={
                      m.startsWith("Pay now")
                        ? "account_balance_wallet"
                        : "payments"
                    }
                  />
                  <strong>{m}</strong>
                </label>
              ))}
            <p className="fine-print">
              No card details, PayPal login or actual funds are needed.
            </p>
            {method === "Pay now · demo" && (
              <details className="demo-controls">
                <summary>Demo payment outcome</summary>
                <Chips
                  items={["Success", "Failed", "Cancelled"]}
                  value={outcome}
                  onChange={setOutcome}
                />
              </details>
            )}
          </section>
        </div>
        <aside className="panel checkout-summary">
          <h2>Your order</h2>
          {state.cart.map((l) => (
            <div className="summary-line" key={l.id}>
              <span>
                {l.quantity} × {l.name}
                <small>{l.option}</small>
              </span>
              <strong>{money(l.price * l.quantity)}</strong>
            </div>
          ))}
          <Field
            label="Have a demo offer?"
            hint="Try WELCOME10 for 10% off food."
          >
            <div className="coupon-input">
              <input
                value={coupon}
                placeholder="Offer code"
                onChange={(e) => {
                  setCoupon(e.target.value);
                  setCouponApplied(false);
                }}
              />
              <Button
                type="button"
                variant="secondary"
                onClick={() => {
                  if (coupon.trim().toUpperCase() === "WELCOME10") {
                    setCouponApplied(true);
                    setError("");
                  } else setError("That offer isn’t available. Try WELCOME10.");
                }}
              >
                Apply
              </Button>
            </div>
          </Field>
          {couponApplied && <Badge tone="available">WELCOME10 applied</Badge>}
          <Totals {...totals} />
          <label className="check-row">
            <input
              type="checkbox"
              checked={agreement}
              onChange={(e) => setAgreement(e.target.checked)}
              required
            />
            <span>
              I understand this is a demo order and no real meal or payment is
              arranged.
            </span>
          </label>
          {error && (
            <p className="error-text" role="alert">
              {error}
            </p>
          )}
          <Button
            type="submit"
            icon="arrow_forward"
            disabled={!agreement || submitting}
          >
            {submitting
              ? "Placing your order…"
              : `Place demo order · ${money(totals.total)}`}
          </Button>
        </aside>
      </form>
    </>
  );
}
function GuestOrders() {
  const { state } = useDemo();
  const [filter, setFilter] = useState("Active");
  const orders = state.orders.filter(
    (o) =>
      o.customer &&
      (filter === "All orders" ||
        (filter === "Active" &&
          !["Completed", "Cancelled"].includes(o.status)) ||
        (filter === "Past orders" &&
          ["Completed", "Cancelled"].includes(o.status))),
  );
  return (
    <>
      <PageTitle
        eyebrow="YOUR GOOD FOOD MOMENTS"
        title="Every bite has a story."
        description="Follow your current order or revisit an old favorite."
      />
      <Chips
        items={["Active", "Past orders", "All orders"]}
        value={filter}
        onChange={setFilter}
      />
      <div className="guest-order-list section-gap">
        {orders.map((o) => (
          <Link
            href={`/orders/${o.id}`}
            className="panel guest-order-card"
            key={o.id}
          >
            <FoodImage
              image={o.lines[0]?.image || ""}
              name={o.lines[0]?.name || "Order"}
            />
            <div>
              <div className="detail-meta">
                <Badge>{o.status}</Badge>
                <span>{o.channel}</span>
              </div>
              <h2>{state.settings.restaurant}</h2>
              <p>
                {o.lines.map((l) => `${l.quantity} × ${l.name}`).join(", ")}
              </p>
              <small>
                {o.id} · {timeLabel(o.createdAt)}
              </small>
            </div>
            <strong>{money(o.total)}</strong>
            <Icon name="arrow_forward" />
          </Link>
        ))}
      </div>
      {!orders.length && (
        <Empty
          icon="receipt_long"
          title="Your next favorite is waiting."
          text="When you place a demo order, you can follow it right here."
          action={
            <ActionLink href="/r/olive-and-hearth">
              Find something delicious
            </ActionLink>
          }
        />
      )}
    </>
  );
}
function GuestOrder({ id }: { id: string }) {
  const { state, cancelOrder, payOrder, update, notify } = useDemo();
  const [receipt, setReceipt] = useState(false);
  const [review, setReview] = useState(false);
  const [rating, setRating] = useState(5);
  const [note, setNote] = useState("");
  const order = state.orders.find((o) => o.id === id && o.customer);
  if (!order) return <Missing />;
  const stages =
    order.channel === "Delivery"
      ? [
          "New",
          "Accepted",
          "Preparing",
          "Ready",
          "Out for delivery",
          "Completed",
        ]
      : ["New", "Accepted", "Preparing", "Ready", "Completed"];
  const active = stages.indexOf(order.status);
  return (
    <>
      <PageTitle
        eyebrow={
          order.status === "Cancelled"
            ? "YOUR ORDER"
            : "A GOOD MEAL IS ON ITS WAY"
        }
        title={
          order.status === "Cancelled"
            ? "Plans change. That’s okay."
            : order.status === "Completed"
              ? "Hope that hit the spot."
              : "You’re in good hands."
        }
        description={`${order.id} · ${state.settings.restaurant} · ${order.channel}`}
        action={
          <Button
            variant="secondary"
            icon="receipt_long"
            onClick={() => setReceipt(true)}
          >
            View receipt
          </Button>
        }
      />
      <div className="checkout-layout">
        <div>
          <section className="panel tracking-panel">
            <span className="tracking-icon">
              <Icon
                name={
                  order.status === "Completed"
                    ? "task_alt"
                    : order.channel === "Delivery"
                      ? "moped"
                      : "skillet"
                }
              />
            </span>
            <Badge>{order.status}</Badge>
            <h2>
              {order.status === "New"
                ? "Your order is with the restaurant."
                : order.status === "Preparing"
                  ? "A little kitchen magic is happening."
                  : order.status === "Ready"
                    ? "Freshly made. Ready for you."
                    : order.status === "Out for delivery"
                      ? "Your meal is on its way."
                      : order.status === "Cancelled"
                        ? "Your order has been cancelled."
                        : order.status === "Completed"
                          ? "Thanks for pulling up a chair."
                          : "The team has accepted your order."}
            </h2>
            <p>
              Demo updates come from the restaurant workspace. They are not a
              live delivery feed.
            </p>
            <div className="tracking-steps">
              {stages.map((stage, i) => (
                <div className={i <= active ? "done" : ""} key={stage}>
                  <span>
                    <Icon name={i <= active ? "check" : "circle"} />
                  </span>
                  <strong>{stage === "New" ? "Placed" : stage}</strong>
                </div>
              ))}
            </div>
            <ActionLink href="/login" variant="text" icon="open_in_new">
              Explore the team side of this order
            </ActionLink>
          </section>
          <section className="panel section-gap">
            <SectionTitle title="The details that matter" />
            <p>
              <strong>{order.guest}</strong>
            </p>
            <p>
              {order.channel === "Delivery"
                ? order.address
                : order.channel === "Dine-in"
                  ? `Table ${order.table}`
                  : state.settings.address}
            </p>
            <div className="detail-meta">
              <Badge>{order.payment}</Badge>
              <span>
                {new Date(order.createdAt).toLocaleDateString("en")} ·{" "}
                {timeLabel(order.createdAt)}
              </span>
            </div>
            <div className="modal-actions">
              {order.payment === "Unpaid" && order.status !== "Cancelled" && (
                <Button variant="secondary" onClick={() => payOrder(id)}>
                  Settle demo bill
                </Button>
              )}
              {["New", "Accepted"].includes(order.status) && (
                <Button
                  variant="text"
                  onClick={() => {
                    if (
                      confirm(
                        "Cancel this demo order? Your demo payment, if any, will be refunded.",
                      )
                    )
                      cancelOrder(id, true);
                  }}
                >
                  Cancel order
                </Button>
              )}
              {order.status === "Completed" && (
                <Button onClick={() => setReview(true)} icon="star">
                  Leave a little feedback
                </Button>
              )}
              <ActionLink href="/help" variant="text">
                Need a hand?
              </ActionLink>
            </div>
          </section>
        </div>
        <aside className="panel checkout-summary">
          <h2>Your little feast</h2>
          <OrderLines order={order} />
          <Totals {...order} />
          {["Completed", "Cancelled"].includes(order.status) && (
            <Button
              variant="secondary"
              onClick={() => {
                if (
                  state.cart.length &&
                  !confirm(
                    "Replace your current basket with available items from this order?",
                  )
                )
                  return;
                update((s) => {
                  s.cart = order.lines.flatMap((line) => {
                    const p = s.products.find(
                      (p) => p.id === line.productId && p.available,
                    );
                    return p
                      ? [
                          {
                            ...line,
                            id: crypto.randomUUID(),
                            price:
                              p.price + (line.option === "Large" ? 2500 : 0),
                          },
                        ]
                      : [];
                  });
                });
                notify(
                  "Available items added at current menu prices. Review your basket.",
                );
              }}
            >
              Order favorites again
            </Button>
          )}
        </aside>
      </div>
      {receipt && (
        <Modal title="Your demo receipt" onClose={() => setReceipt(false)}>
          <div className="receipt">
            <Brand />
            <h3>{state.settings.restaurant}</h3>
            <p>
              {order.id} · {order.channel}
            </p>
            <Badge>{order.payment}</Badge>
            <OrderLines order={order} />
            <Totals {...order} />
            <p className="fine-print">
              Illustrative receipt. Not a fiscal document or evidence of a real
              payment.
            </p>
            <Button
              variant="secondary"
              icon="print"
              onClick={() => window.print()}
            >
              Print receipt
            </Button>
          </div>
        </Modal>
      )}
      {review && (
        <Modal
          title="How was your little feast?"
          onClose={() => setReview(false)}
          dirty={!!note}
        >
          <p>Your feedback is saved only in this demo browser.</p>
          <Field label="Rating">
            <select
              value={rating}
              onChange={(e) => setRating(Number(e.target.value))}
            >
              {[5, 4, 3, 2, 1].map((r) => (
                <option key={r} value={r}>
                  {r} stars
                </option>
              ))}
            </select>
          </Field>
          <Field label="A note for the team">
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              maxLength={500}
            />
          </Field>
          <Button
            onClick={() => {
              update((s) => {
                s.reviews = s.reviews.filter((r) => r.orderId !== id);
                s.reviews.push({ orderId: id, rating, note });
              });
              setReview(false);
              notify("Your demo feedback is saved. Thank you.");
            }}
          >
            Save feedback
          </Button>
        </Modal>
      )}
    </>
  );
}
function Visit() {
  const { state, requestService, payOrder } = useDemo();
  if (!state.visit)
    return (
      <Empty
        icon="table_restaurant"
        title="Your place at the table."
        text="Scan a table QR or enter a table number to start your visit."
        action={<ActionLink href="/scan">Find my table</ActionLink>}
      />
    );
  const orders = state.orders.filter((o) => o.visitId === state.visit!.id);
  const unpaid = orders.filter(
    (o) => o.payment === "Unpaid" && o.status !== "Cancelled",
  );
  return (
    <>
      <PageTitle
        eyebrow="STAY A LITTLE LONGER"
        title={`Your table. Your moment.`}
        description={`Table ${state.visit.table} · ${state.visit.guests} guests · ${state.settings.restaurant}`}
        action={
          <ActionLink href="/r/olive-and-hearth" icon="add">
            Order another round
          </ActionLink>
        }
      />
      <div className="checkout-layout">
        <div>
          <section className="panel">
            <SectionTitle title="A little help, right here" />
            <div className="service-request-buttons">
              {[
                ["Water refill", "water_drop"],
                ["Extra cutlery", "restaurant"],
                ["A hand, please", "room_service"],
                ["The bill, please", "receipt_long"],
              ].map(([kind, icon]) => (
                <Button
                  key={kind}
                  variant="secondary"
                  icon={icon}
                  onClick={() => requestService(kind)}
                >
                  {kind}
                </Button>
              ))}
            </div>
            {state.requests
              .filter((r) => r.table === state.visit!.table)
              .map((r) => (
                <div className="list-row" key={r.id}>
                  <strong>{r.kind}</strong>
                  <Badge>{r.status}</Badge>
                </div>
              ))}
          </section>
          <section className="panel section-gap">
            <SectionTitle title="Your rounds" />
            {orders.map((o) => (
              <Link className="list-row" key={o.id} href={`/orders/${o.id}`}>
                <span>
                  <strong>{o.id}</strong>
                  <small>
                    {o.lines.map((l) => `${l.quantity} × ${l.name}`).join(", ")}
                  </small>
                </span>
                <Badge>{o.status}</Badge>
                <strong>{money(o.total)}</strong>
                <Icon name="arrow_forward" />
              </Link>
            ))}
            {!orders.length && (
              <Empty
                icon="restaurant_menu"
                title="Let’s start with something good."
                text="Your first round is waiting to be discovered."
                action={
                  <ActionLink href="/r/olive-and-hearth">
                    Browse the menu
                  </ActionLink>
                }
              />
            )}
          </section>
        </div>
        <aside className="panel checkout-summary">
          <span className="soft-icon">
            <Icon name="receipt_long" />
          </span>
          <h2>The table bill</h2>
          <div className="bill-total">
            {money(unpaid.reduce((sum, o) => sum + o.total, 0))}
          </div>
          <p>Outstanding in this demo visit</p>
          {unpaid.map((o) => (
            <div className="list-row" key={o.id}>
              <span>{o.id}</span>
              <Button variant="secondary" onClick={() => payOrder(o.id)}>
                Pay {money(o.total)} · demo
              </Button>
            </div>
          ))}
          {!unpaid.length && <Badge tone="available">All settled so far</Badge>}
          <p className="fine-print">
            Payment does not close your table. The team closes and resets the
            visit after service is complete.
          </p>
        </aside>
      </div>
    </>
  );
}
function GuestReservations() {
  const { state, reserve, update, notify } = useDemo();
  const [name, setName] = useState(state.profile.name);
  const [guests, setGuests] = useState(2);
  const [date, setDate] = useState("");
  const [time, setTime] = useState("19:00");
  const bookings = state.reservations.filter((r) => r.customer);
  return (
    <>
      <PageTitle
        eyebrow="MAKE ROOM FOR A GOOD EVENING"
        title="We’ll save you a seat."
        description="A quiet dinner, a long catch-up or a little celebration. Come as you are."
      />
      <div className="checkout-layout">
        <section className="panel reservation-form">
          <h2>A table at {state.settings.restaurant}</h2>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              reserve({ name, guests, date, time, customer: true });
            }}
          >
            <Field label="Your name">
              <input
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </Field>
            <div className="form-grid">
              <Field label="Your party">
                <select
                  value={guests}
                  onChange={(e) => setGuests(Number(e.target.value))}
                >
                  {Array.from({ length: 12 }, (_, i) => (
                    <option key={i} value={i + 1}>
                      {i + 1} guests
                    </option>
                  ))}
                </select>
              </Field>
              <Field label="The day">
                <input
                  type="date"
                  required
                  min={new Date().toISOString().slice(0, 10)}
                  value={date}
                  onChange={(e) => setDate(e.target.value)}
                />
              </Field>
            </div>
            <Field label="The time">
              <select value={time} onChange={(e) => setTime(e.target.value)}>
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
            <Button type="submit" icon="calendar_month">
              Reserve a demo table
            </Button>
            <p className="fine-print">
              A local demonstration. No real restaurant reservation is made.
            </p>
          </form>
        </section>
        <div>
          <section className="panel">
            <SectionTitle title="Your upcoming moments" />
            {bookings.map((b) => (
              <div className="booking" key={b.id}>
                <Badge>{b.status}</Badge>
                <h3>
                  {b.date} · {b.time}
                </h3>
                <p>
                  {b.name} · {b.guests} guests
                </p>
                {b.status === "Confirmed" && (
                  <Button
                    variant="text"
                    onClick={() => {
                      if (confirm("Cancel your demo reservation?")) {
                        update((s) => {
                          s.reservations.find((r) => r.id === b.id)!.status =
                            "Cancelled";
                        });
                        notify("Demo reservation cancelled.");
                      }
                    }}
                  >
                    Cancel reservation
                  </Button>
                )}
              </div>
            ))}
            {!bookings.length && (
              <p>Your next get-together will appear here.</p>
            )}
          </section>
          <section className="panel section-gap">
            <Icon name="hourglass_top" />
            <h2>Feeling spontaneous?</h2>
            <p>Join the local demo waitlist for a walk-in table.</p>
            {state.waitlist.some((w) => w.name === state.profile.name) ? (
              <>
                <Badge tone="available">You’re on the demo waitlist</Badge>
                <p>
                  Position{" "}
                  {state.waitlist.findIndex(
                    (w) => w.name === state.profile.name,
                  ) + 1}{" "}
                  ·{" "}
                  {
                    state.waitlist.find((w) => w.name === state.profile.name)
                      ?.status
                  }
                </p>
                <Button
                  variant="text"
                  onClick={() =>
                    update((s) => {
                      s.waitlist = s.waitlist.filter(
                        (w) => w.name !== s.profile.name,
                      );
                    })
                  }
                >
                  Leave waitlist
                </Button>
              </>
            ) : (
              <Button
                variant="secondary"
                disabled={!state.settings.open}
                onClick={() => {
                  update((s) => {
                    if (!s.waitlist.some((w) => w.name === s.profile.name))
                      s.waitlist.push({
                        id: crypto.randomUUID(),
                        name: s.profile.name,
                        guests,
                        status: "Waiting",
                      });
                  });
                  notify("You’ve joined the demo waitlist.");
                }}
              >
                Join waitlist · {guests} guests
              </Button>
            )}
          </section>
        </div>
      </div>
    </>
  );
}
function Favorites() {
  const { state } = useDemo();
  const [item, setItem] = useState<Product | null>(null);
  const products = state.products.filter((p) => state.favorites.includes(p.id));
  return (
    <>
      <PageTitle
        eyebrow="SAVE A LITTLE GOODNESS"
        title="The ones you’ll come back for."
        description="Your favorites, kept close in this browser."
      />
      <div className="guest-product-grid">
        {products.map((p) => (
          <ProductCard key={p.id} product={p} onOpen={() => setItem(p)} />
        ))}
      </div>
      {!products.length && (
        <Empty
          icon="favorite"
          title="A little love goes a long way."
          text="Tap the heart on a dish to save it here."
          action={
            <ActionLink href="/r/olive-and-hearth">
              Find your favorites
            </ActionLink>
          }
        />
      )}
      {item && <ProductModal product={item} onClose={() => setItem(null)} />}
    </>
  );
}
function Account() {
  const { state, update, reset, notify } = useDemo();
  const { draft, setDraft, dirty } = useDraft(
    "profile",
    state.profile,
    "profile",
  );
  return (
    <>
      <PageTitle
        eyebrow="MAKE YOURSELF AT HOME"
        title={`Hello, ${state.profile.name.split(" ")[0]}.`}
        description="A few little preferences to make this space yours."
      />
      <div className="settings-layout">
        <section className="panel">
          <SectionTitle title="Your demo profile" />
          <form
            onSubmit={(e) => {
              e.preventDefault();
              if (!draft.email.endsWith(".test")) {
                notify("Use a fictional .test email for this demo.");
                return;
              }
              update((s) => {
                s.profile = draft;
              });
              notify("Demo profile saved.");
            }}
          >
            <Field label="Name">
              <input
                required
                value={draft.name}
                onChange={(e) => setDraft({ ...draft, name: e.target.value })}
              />
            </Field>
            <Field
              label="Fictional email"
              hint="Use a .test address. No email is sent."
            >
              <input
                type="email"
                required
                value={draft.email}
                onChange={(e) => setDraft({ ...draft, email: e.target.value })}
              />
            </Field>
            <Field label="Saved delivery address">
              <textarea
                value={draft.address}
                onChange={(e) =>
                  setDraft({ ...draft, address: e.target.value })
                }
              />
            </Field>
            <div className="modal-actions">
              <Button type="submit" disabled={!dirty}>
                Save profile
              </Button>
              <Button
                variant="secondary"
                type="button"
                disabled={!dirty}
                onClick={() => setDraft(state.profile)}
              >
                Cancel
              </Button>
            </div>
          </form>
        </section>
        <div>
          <section className="panel">
            <SectionTitle title="Your kind of comfortable" />
            {(["dark", "reducedMotion"] as const).map((key) => (
              <label className="setting-row" key={key}>
                <span>
                  <strong>
                    {key === "dark" ? "Dark appearance" : "Reduce motion"}
                  </strong>
                  <small>
                    {key === "dark"
                      ? "A little easier on the eyes after dark."
                      : "Device reduced-motion preferences are always respected."}
                  </small>
                </span>
                <input
                  type="checkbox"
                  role="switch"
                  checked={state.settings[key]}
                  onChange={(e) =>
                    update((s) => {
                      s.settings[key] = e.target.checked;
                    })
                  }
                />
              </label>
            ))}
            <div className="list-row">
              <span>Language</span>
              <span>English · Phase 1</span>
            </div>
          </section>
          <section className="panel section-gap">
            <SectionTitle title="A fresh start" />
            <p>
              Reset all demo orders, menus, table visits and preferences in this
              browser. This cannot be undone.
            </p>
            <Button
              variant="danger"
              onClick={() => {
                if (
                  confirm(
                    "Reset the entire web demo in this browser? This clears shared demo work for all roles.",
                  )
                ) {
                  reset();
                  setDraft({
                    name: "Alex Morgan",
                    email: "alex@raysto.test",
                    address: "18 Boulevard Anfa, Casablanca",
                  });
                }
              }}
            >
              Reset this browser’s demo
            </Button>
          </section>
          <ActionLink href="/login" variant="text" icon="space_dashboard">
            Explore the restaurant workspace
          </ActionLink>
        </div>
      </div>
    </>
  );
}
function Help() {
  const [message, setMessage] = useState("");
  const [messages, setMessages] = useState<string[]>([]);
  return (
    <div className="narrow-page">
      <PageTitle
        eyebrow="WE’RE RIGHT HERE"
        title="Need a little hand?"
        description="A few helpful answers, without the wait."
      />
      <section className="panel faq">
        {[
          [
            "Where is my order?",
            "Open Your orders to see its current stage. In this demo, the restaurant workspace controls preparation and delivery updates.",
          ],
          [
            "Can I change or cancel an order?",
            "You can cancel while an order is new or accepted. Once preparation starts, use the demo support note below.",
          ],
          [
            "What if I have an allergy?",
            "Allergen information is illustrative and cross-contact is unknown. Always speak with the restaurant before a real order.",
          ],
          [
            "Will I be charged?",
            "No. Every checkout in this phase is simulated. Never enter real payment credentials.",
          ],
          [
            "Does my phone share these demo orders?",
            "No. Data is stored in each browser. Tabs in the same browser share updates; other devices have a separate demo.",
          ],
        ].map(([q, a]) => (
          <details key={q}>
            <summary>{q}</summary>
            <p>{a}</p>
          </details>
        ))}
      </section>
      <section className="panel section-gap">
        <h2>Leave a demo support note</h2>
        <p>
          This is a local conversation preview. No support agent receives these
          notes; they last only while this page stays open.
        </p>
        {messages.map((m, i) => (
          <div className="chat-note" key={i}>
            {m}
          </div>
        ))}
        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (message.trim()) {
              setMessages([...messages, message.trim()]);
              setMessage("");
            }
          }}
        >
          <Field label="Your message">
            <textarea
              required
              maxLength={1000}
              value={message}
              onChange={(e) => setMessage(e.target.value)}
            />
          </Field>
          <Button type="submit" icon="send" disabled={!message.trim()}>
            Add demo note
          </Button>
        </form>
      </section>
    </div>
  );
}
function About() {
  return (
    <div className="narrow-page">
      <PageTitle
        title="A little more hospitality."
        description="Raysto brings the restaurant and the guest experience together."
      />
      <section className="panel">
        <h2>A thoughtful demo, with clear boundaries.</h2>
        <p>
          This phase explores the complete web experience using illustrative
          restaurant data. Orders, payments, reservations, reviews, invitations
          and service requests are simulations stored in your browser.
        </p>
        <p>
          No live restaurant, Firebase identity, Serverpod database, payment
          account or courier service is connected. The demo role chooser is not
          production authentication.
        </p>
        <p>
          Photography is reused from the existing Raysto demo asset library.
          Dietary details are illustrative, and unknown information stays
          unknown.
        </p>
        <p>
          Reset your local data in Account. Browser storage can be cleared by
          your browser and is not suitable for sensitive information.
        </p>
        <ActionLink href="/discover">Back to something delicious</ActionLink>
      </section>
    </div>
  );
}
function Missing() {
  return (
    <Empty
      icon="explore_off"
      title="This little corner isn’t here."
      text="The link may be incorrect, or this order belongs to another demo browser."
      action={<ActionLink href="/discover">Back to discover</ActionLink>}
    />
  );
}
