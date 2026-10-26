"use client";
import Link from "next/link";
import dynamic from "next/dynamic";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useDemo } from "@/lib/store";
import { can, roleNames, rolePeople, roles, type Role } from "@/lib/domain";
import {
  ActionLink,
  Brand,
  Button,
  Empty,
  Icon,
  IconButton,
  Modal,
} from "./ui";
const Dashboard = dynamic(() =>
  import("./workspace").then((module) => module.Dashboard),
);
const GuestApp = dynamic(() =>
  import("./guest").then((module) => module.GuestApp),
);

export const navigation = [
  {
    section: "overview",
    name: "Overview",
    icon: "space_dashboard",
    group: "WORKSPACE",
  },
  { section: "orders", name: "Orders", icon: "receipt_long" },
  { section: "kitchen", name: "Kitchen display", icon: "skillet" },
  { section: "tables", name: "Tables & QR codes", icon: "table_restaurant" },
  { section: "reservations", name: "Reservations", icon: "calendar_month" },
  { section: "requests", name: "Service requests", icon: "room_service" },
  {
    section: "menu",
    name: "Menu management",
    icon: "restaurant_menu",
    group: "RESTAURANT",
  },
  { section: "deliveries", name: "Deliveries", icon: "moped" },
  { section: "payments", name: "Payments", icon: "account_balance_wallet" },
  { section: "team", name: "Team", icon: "group" },
  { section: "reports", name: "Reports", icon: "bar_chart" },
  { section: "storefront", name: "Storefront", icon: "storefront" },
  { section: "settings", name: "Settings", icon: "tune" },
];
export function WebApp({ path }: { path: string[] }) {
  const { state, ready, toast, storageError } = useDemo();
  if (!ready)
    return (
      <main className="loading-page">
        <Brand />
        <p>Preparing your demo space…</p>
        <div className="skeleton" />
      </main>
    );
  const workspace = path[0] === "dashboard";
  return (
    <>
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      {storageError && (
        <div className="storage-notice" role="alert">
          {storageError} <Link href="/account">Open preferences</Link>
        </div>
      )}
      {path[0] === "login" ? (
        <Login />
      ) : workspace ? (
        <WorkspaceShell section={path[1] || "overview"}>
          <Dashboard section={path[1] || "overview"} />
        </WorkspaceShell>
      ) : (
        <GuestApp path={path} />
      )}
      <div
        className={`toast ${toast ? "visible" : ""}`}
        role="status"
        aria-live="polite"
      >
        {toast && (
          <>
            <Icon name="info" />
            {toast}
          </>
        )}
      </div>
    </>
  );
}
function WorkspaceShell({
  section,
  children,
}: {
  section: string;
  children: React.ReactNode;
}) {
  const { state, logout } = useDemo();
  const router = useRouter();
  const [menu, setMenu] = useState(false);
  const [account, setAccount] = useState(false);
  if (!state.role) return <Login />;
  const name =
    navigation.find((n) => n.section === section)?.name || "Activity";
  const sidebar = (
    <>
      <div className="sidebar-brand">
        <Brand />
        <span className="workspace-label">WORKSPACE</span>
      </div>
      <div className="restaurant-switch">
        <div className="restaurant-monogram">
          o<span>&</span>h
        </div>
        <div>
          <strong>{state.settings.restaurant}</strong>
          <small>Casablanca, Morocco</small>
        </div>
      </div>
      <nav aria-label="Restaurant workspace">
        {navigation
          .filter((item) => can(state.role, item.section))
          .map((item) => (
            <div key={item.section}>
              {item.group && <div className="nav-group">{item.group}</div>}
              <Link
                onClick={() => setMenu(false)}
                href={`/dashboard/${item.section}`}
                aria-current={section === item.section ? "page" : undefined}
                className={`nav-item ${section === item.section ? "active" : ""}`}
              >
                <Icon name={item.icon} />
                <span>{item.name}</span>
                {item.section === "orders" && (
                  <span className="nav-count">
                    {state.orders.filter((o) => o.status === "New").length}
                  </span>
                )}
                {item.section === "requests" &&
                  state.requests.some((r) => r.status === "New") && (
                    <i className="notification-dot" />
                  )}
              </Link>
            </div>
          ))}
      </nav>
      <div className="sidebar-bottom">
        <div className="preview-card">
          <Icon name="auto_awesome" />
          <strong>Your next great service.</strong>
          <p>One connected demo, from kitchen to table.</p>
          <Link href="/r/olive-and-hearth">
            Preview guest experience <Icon name="north_east" />
          </Link>
        </div>
        <button className="account-button" onClick={() => setAccount(true)}>
          <span className="avatar">{rolePeople[state.role].slice(0, 1)}</span>
          <span>
            <strong>{rolePeople[state.role]} Bennani</strong>
            <small>{roleNames[state.role]}</small>
          </span>
          <Icon name="unfold_more" />
        </button>
      </div>
    </>
  );
  return (
    <div className="workspace-shell">
      <aside className="sidebar">{sidebar}</aside>
      {menu && (
        <Modal title="Workspace navigation" onClose={() => setMenu(false)}>
          <div className="mobile-sidebar">{sidebar}</div>
        </Modal>
      )}
      <div className="workspace-main">
        <header className="workspace-header">
          <div className="header-breadcrumb">
            <span className="mobile-menu">
              <IconButton
                name="menu"
                label="Open navigation"
                onClick={() => setMenu(true)}
              />
            </span>
            <span className="muted">Workspace</span>
            <Icon name="chevron_right" />
            <strong>{name}</strong>
          </div>
          <div className="header-actions">
            <span className="demo-tag">DEMO WORKSPACE</span>
            <Link
              className="text-link storefront-link"
              href="/r/olive-and-hearth"
            >
              View storefront <Icon name="north_east" />
            </Link>
            <Link
              href="/dashboard/activity"
              className="icon-button"
              aria-label="Activity and notifications"
            >
              <Icon name="notifications" />
              <i className="notification-dot" />
            </Link>
            <button
              className="avatar"
              aria-label="Switch demo account"
              onClick={() => setAccount(true)}
            >
              {rolePeople[state.role][0]}
            </button>
          </div>
        </header>
        <main id="main" className="workspace-content" key={section}>
          {can(state.role, section) ? (
            children
          ) : (
            <Empty
              icon="lock"
              title="A different workspace"
              text="This page is outside your current demo role. Switch to the owner account to explore it."
              action={
                <Button onClick={() => setAccount(true)}>
                  Switch demo account
                </Button>
              }
            />
          )}
        </main>
        <footer className="workspace-footer">
          <span>Made for the moments around the table.</span>
          <span>Raysto · Phase 1 demo</span>
        </footer>
      </div>
      {account && (
        <Modal title="Your demo workspace" onClose={() => setAccount(false)}>
          <p>
            Switch roles to explore the same restaurant records. These are local
            demo identities.
          </p>
          <RolePicker
            onSelect={(role) => {
              setAccount(false);
              router.push(
                `/dashboard/${role === "kitchen" ? "kitchen" : role === "courier" ? "deliveries" : "overview"}`,
              );
            }}
          />
          <Button
            variant="text"
            icon="logout"
            onClick={() => {
              logout();
              setAccount(false);
              router.push("/login");
            }}
          >
            Leave workspace
          </Button>
        </Modal>
      )}
    </div>
  );
}
function RolePicker({ onSelect }: { onSelect: (role: Role) => void }) {
  const { state, login } = useDemo();
  return (
    <div className="role-list">
      {roles.map((role) => (
        <button
          key={role}
          className={`role-card ${state.role === role ? "selected" : ""}`}
          disabled={!state.staff.some((s) => s.role === role && s.active)}
          onClick={() => {
            login(role);
            onSelect(role);
          }}
        >
          <span className="avatar">{rolePeople[role][0]}</span>
          <span>
            <strong>
              {rolePeople[role]} · {roleNames[role]}
            </strong>
            <small>{role}@raysto.test</small>
          </span>
          <Icon name="arrow_forward" />
        </button>
      ))}
    </div>
  );
}
function Login() {
  const router = useRouter();
  return (
    <main className="login-layout" id="main">
      <section className="login-story">
        <Brand />
        <div>
          <span className="eyebrow">A LITTLE MORE HOSPITALITY</span>
          <h1>
            Good food.
            <br />
            Great flow.
            <br />
            <em>All together.</em>
          </h1>
          <p>
            A calmer service starts here. Bring your people, your kitchen and
            every little detail into one place.
          </p>
          <div className="login-photo">
            <img
              src="/images/olive-room.webp"
              alt="Illustrative Olive & Hearth dining room"
            />
            <span>Built around your table.</span>
          </div>
        </div>
        <small>Raysto for restaurants · Phase 1</small>
      </section>
      <section className="login-form">
        <div>
          <span className="demo-tag">LET’S TAKE A LOOK AROUND</span>
          <h2>
            Your restaurant,
            <br />
            in good hands.
          </h2>
          <p>Choose a demo account to enter Olive & Hearth.</p>
          <RolePicker
            onSelect={(role) =>
              router.push(
                `/dashboard/${role === "kitchen" ? "kitchen" : role === "courier" ? "deliveries" : "overview"}`,
              )
            }
          />
          <p className="fine-print">
            No password needed. Changes stay in this browser. Payments,
            invitations and delivery are simulated.
          </p>
          <ActionLink href="/discover" icon="arrow_back" variant="text">
            Explore as a guest
          </ActionLink>
        </div>
      </section>
    </main>
  );
}
