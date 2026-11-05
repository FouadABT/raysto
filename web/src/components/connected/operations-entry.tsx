"use client";
import { useEffect, useRef, useState, type ReactNode } from "react";
import dynamic from "next/dynamic";
import {
  GoogleAuthProvider,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  type Auth,
} from "firebase/auth";
import { connectedAuth } from "@/lib/connected/firebase";
import { ConnectedApi } from "@/lib/connected/api";
import type { Membership } from "@/lib/connected/contracts";
import type { GroupRef } from "@/lib/connected/group";
import { isJudgeVenue, judge, judgeLogin } from "@/lib/connected/judge";
import { MotionRoot, setReduceMotion, useAppReduceMotion } from "@/lib/connected/motion";
import { Icon } from "./icons";
import { SnackbarProvider } from "./m3";
import { GroupChoiceProvider, GroupSwitcher, useGroups, venuesInChoice, type GroupChoice } from "./group-switcher";

const Workspace = dynamic(
  () => import("./operations-workspace").then((m) => m.OperationsWorkspace),
  {
    ssr: false,
    loading: () => (
      <div className="ops-loading" role="status">
        <span className="ops-spinner" aria-hidden="true" />
        Setting your table…
      </div>
    ),
  },
);
export function OperationsEntry() {
  const [auth, setAuth] = useState<Auth>();
  const [api, setApi] = useState<ConnectedApi>();
  const [memberships, setMemberships] = useState<Membership[]>([]);
  const [selected, setSelected] = useState<number>();
  const [email, setEmail] = useState(""),
    [password, setPassword] = useState(""),
    [error, setError] = useState("");
  const [busy, setBusy] = useState(true),
    [signedIn, setSignedIn] = useState(false);
  const [person, setPerson] = useState<{ name?: string | null; email?: string | null }>();
  // 0.16: the groups `me` lists, for the group switcher.
  const [groupRefs, setGroupRefs] = useState<GroupRef[]>([]);
  useEffect(() => {
    let active = true,
      unsubscribe = () => {},
      current: ConnectedApi | undefined;
    void connectedAuth()
      .then((a) => {
        if (!active) return;
        setAuth(a);
        // A link from the judges' page signs straight into the demo café.
        let judgeLink =
          judgeLogin() &&
          new URLSearchParams(window.location.search).get("judge") === "1";
        unsubscribe = onAuthStateChanged(a, (user) => {
          current?.close();
          current = undefined;
          setApi(undefined);
          setMemberships([]);
          setSelected(undefined);
          setSignedIn(!!user);
          setPerson(user ? { name: user.displayName, email: user.email } : undefined);
          if (!user && judgeLink) {
            judgeLink = false;
            void signInWithEmailAndPassword(a, judge.email, judge.password).catch(
              (e) => {
                if (active) {
                  setError(String(e));
                  setBusy(false);
                }
              },
            );
            return;
          }
          if (!user) {
            setBusy(false);
            return;
          }
          const next = new ConnectedApi(a, user);
          current = next;
          setBusy(true);
          void next
            .query<{ memberships: Membership[]; groups?: GroupRef[] }>("me")
            .then((me) => {
              if (!active || current !== next) return;
              const allowed = me.memberships.filter((m) =>
                ["owner", "manager"].includes(m.role),
              );
              setApi(next);
              setMemberships(allowed);
              setGroupRefs(me.groups ?? []);
              setSelected(allowed[0]?.restaurantId);
              setError("");
            })
            .catch((e) => {
              if (active && current === next) setError(String(e));
            })
            .finally(() => {
              if (active && current === next) setBusy(false);
            });
        });
      })
      .catch((e) => {
        if (active) {
          setError(String(e));
          setBusy(false);
        }
      });
    return () => {
      active = false;
      unsubscribe();
      current?.close();
    };
  }, []);
  async function login(google: boolean, asJudge = false) {
    if (!auth) return;
    setBusy(true);
    setError("");
    try {
      if (google) await signInWithPopup(auth, new GoogleAuthProvider());
      else if (asJudge)
        await signInWithEmailAndPassword(auth, judge.email, judge.password);
      else await signInWithEmailAndPassword(auth, email, password);
      setPassword("");
    } catch (e) {
      setError(String(e));
      setBusy(false);
    }
  }
  const leave = () => {
    if (auth) void signOut(auth);
  };
  // Signed in with a restaurant: the console shell, with the sections in a
  // navigation drawer (wide), a rail (medium) or a modal drawer (phone) that
  // the workspace fills.
  if (signedIn && !busy && api && selected)
    return (
      <ConsoleShell
        api={api}
        memberships={memberships}
        selected={selected}
        onSelect={setSelected}
        onSignOut={leave}
        error={error}
        person={person}
        groups={groupRefs}
      />
    );
  return (
    <main className="ops-root">
      <header className="ops-top">
        <Wordmark />
        <span className="ops-tag">THE RESTAURANT ROOM</span>
        {signedIn && (
          <button className="ops-quiet" onClick={leave}>
            <Icon name="signOut" size={18} />
            Sign out
          </button>
        )}
      </header>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      {busy ? (
        <div className="ops-loading" role="status">
          <span className="ops-spinner" aria-hidden="true" />
          Connecting your restaurant…
        </div>
      ) : !signedIn ? (
        <section className="ops-welcome">
          <div className="ops-welcome-story">
            <span className="ops-eyebrow">A LITTLE MORE HOSPITALITY</span>
            <h1>
              A room full
              <br />
              of possibilities.
            </h1>
            <p>
              Your tables, team and guests. One shared view, with Raysto close
              at hand.
            </p>
            <ul className="ops-welcome-points">
              <li>
                <Icon name="orders" size={18} /> Every order, from counter to
                table
              </li>
              <li>
                <Icon name="paypal" size={18} /> PayPal payments you can
                trust, checked twice
              </li>
              <li>
                <Icon name="agents" size={18} /> AI coworkers that prepare,
                so you can decide
              </li>
            </ul>
            <div className="ops-table-art" aria-hidden="true">
              <span>✳</span>
              <i />
              <i />
              <i />
              <i />
            </div>
          </div>
          <form
            className="ops-login"
            onSubmit={(e) => {
              e.preventDefault();
              void login(false);
            }}
          >
            {judgeLogin() && (
              <div className="ops-judge-entry">
                <span className="ops-eyebrow">DEMO CAFÉ</span>
                <p>
                  One click into a shared demo café, where AI coworkers prepare
                  the work and you approve it. Payments run in PayPal Sandbox.
                </p>
                <button
                  type="button"
                  className="ops-primary"
                  onClick={() => void login(false, true)}
                >
                  <Icon name="play" size={18} />
                  Open the demo café
                </button>
              </div>
            )}
            <h2>Welcome back.</h2>
            <p>Use your invited restaurant account.</p>
            <button
              type="button"
              className="ops-secondary ops-google"
              onClick={() => void login(true)}
            >
              <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
                <path fill="#4285F4" d="M21.6 12.2c0-.7-.1-1.4-.2-2H12v3.8h5.4a4.6 4.6 0 0 1-2 3v2.5h3.2c1.9-1.7 3-4.3 3-7.3z" />
                <path fill="#34A853" d="M12 22c2.7 0 5-.9 6.6-2.4l-3.2-2.5c-.9.6-2 1-3.4 1-2.6 0-4.8-1.8-5.6-4.1H3.1v2.6A10 10 0 0 0 12 22z" />
                <path fill="#FBBC05" d="M6.4 14c-.2-.6-.3-1.3-.3-2s.1-1.4.3-2V7.4H3.1a10 10 0 0 0 0 9.2z" />
                <path fill="#EA4335" d="M12 5.9c1.5 0 2.8.5 3.8 1.5l2.8-2.8A10 10 0 0 0 3.1 7.4L6.4 10c.8-2.3 3-4.1 5.6-4.1z" />
              </svg>
              Continue with Google
            </button>
            <span className="ops-or">or sign in with email</span>
            <label>
              Email
              <input
                autoComplete="username"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </label>
            <label>
              Password
              <input
                autoComplete="current-password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </label>
            <button type="submit" className="ops-primary">
              Sign in
            </button>
            <small>
              Connected accounts only. Restaurant access is granted by your
              team.
            </small>
          </form>
        </section>
      ) : (
        <section className="ops-empty">
          <span className="ops-empty-mark" aria-hidden="true">✳</span>
          <h1>Your place is waiting.</h1>
          <p>
            This account has no active owner or manager membership. Ask your
            restaurant owner to invite you in Raysto.
          </p>
        </section>
      )}
    </main>
  );
}

function Wordmark() {
  return (
    <a className="ops-wordmark" href="/ops" aria-label="Raysto">
      <b className="ops-wordmark-text">
        rays<span>to</span>
      </b>
      <i aria-hidden="true">✳</i>
    </a>
  );
}

function MenuIcon({ close = false }: { close?: boolean }) {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.75} strokeLinecap="round" aria-hidden="true" focusable="false">
      {close ? <path d="M6 6l12 12M18 6 6 18" /> : <path d="M4 7h16M4 12h16M4 17h16" />}
    </svg>
  );
}

function VenuePicker({
  memberships,
  selected,
  onSelect,
  className,
}: {
  memberships: Membership[];
  selected: number;
  onSelect: (id: number) => void;
  className: string;
}) {
  return (
    <label className={`ops-venue ${className}`}>
      <span>Restaurant</span>
      <select aria-label="Restaurant" value={selected} onChange={(e) => onSelect(Number(e.target.value))}>
        {memberships.map((m) => (
          <option key={m.restaurantId} value={m.restaurantId}>
            {m.name}
          </option>
        ))}
      </select>
      <small>You are its {memberships.find((m) => m.restaurantId === selected)?.role ?? "manager"}</small>
    </label>
  );
}

/** The console's own reduce-motion switch; it adds to the device setting, never overrides it. */
function ReduceMotionSwitch() {
  const on = useAppReduceMotion();
  return (
    <label className="ops-motion-switch">
      <input type="checkbox" role="switch" checked={on} onChange={(e) => setReduceMotion(e.target.checked)} />
      <span className="ops-motion-switch-text">Reduce motion</span>
    </label>
  );
}

function ShellFoot({ onSignOut }: { onSignOut: () => void }) {
  return (
    <div className="ops-shell-foot">
      <span className="ops-sandbox">
        <Icon name="paypal" size={16} />
        <span>PayPal Sandbox · no live payments</span>
      </span>
      <ReduceMotionSwitch />
      <button className="ops-quiet ops-signout" onClick={onSignOut}>
        <Icon name="signOut" size={18} />
        <span>Sign out</span>
      </button>
    </div>
  );
}

/**
 * The signed-in console: Material's navigation drawer on wide screens
 * (≥1200 px), a navigation rail on medium ones (600–1199 px) and a top app
 * bar with a modal drawer on phones. The workspace renders its sections into
 * whichever navigation is on screen. Exported for the development preview.
 */
export function ConsoleShell({
  api,
  memberships,
  selected,
  onSelect,
  onSignOut,
  error,
  person,
  workspace,
  groups,
}: {
  api: ConnectedApi;
  memberships: Membership[];
  selected: number;
  onSelect: (id: number) => void;
  onSignOut: () => void;
  error?: string;
  person?: { name?: string | null; email?: string | null };
  /** The development preview passes the workspace in directly (no dynamic import). */
  workspace?: typeof Workspace;
  /** 0.16: the person's groups from `me`; the group switcher shows when there is one. */
  groups?: GroupRef[];
}) {
  const draft = useRef(false);
  const canLeave = () => !draft.current || window.confirm("Discard the unsent room message?");
  // The sidebar slot (drawer or rail) the workspace renders its sections into,
  // and the phone drawer's slot while it is open.
  const [navTarget, setNavTarget] = useState<HTMLElement | null>(null);
  const [drawerTarget, setDrawerTarget] = useState<HTMLElement | null>(null);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const drawer = useRef<HTMLDialogElement>(null);
  const menuButton = useRef<HTMLButtonElement>(null);
  const View = workspace ?? Workspace;
  const select = (id: number) => {
    if (canLeave()) {
      draft.current = false;
      onSelect(id);
    }
  };
  // 0.16: the group switcher narrows the venue picker to the chosen group.
  const groupState = useGroups(api, groups);
  const pickGroup = (id: number | null) => {
    const next = venuesInChoice(memberships, { ...groupState, groupId: id });
    if (next.length && !next.some((m) => m.restaurantId === selected)) {
      if (!canLeave()) return;
      draft.current = false;
      onSelect(next[0].restaurantId);
    }
    groupState.setGroupId(id);
  };
  const choice: GroupChoice = { ...groupState, setGroupId: pickGroup };
  const venues = venuesInChoice(memberships, choice);
  const signOutNow = () => {
    if (canLeave()) {
      draft.current = false;
      onSignOut();
    }
  };
  useEffect(() => {
    const d = drawer.current;
    if (drawerOpen && d && !d.open) d.showModal();
  }, [drawerOpen]);
  useEffect(() => {
    const d = drawer.current;
    if (!d) return;
    // Native listeners: the sections are portalled into the drawer, so their
    // clicks bubble through the dialog in the DOM, not in React's tree.
    const onClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (target === d || target.closest(".ops-sections button")) d.close();
    };
    const onClose = () => {
      setDrawerOpen(false);
      menuButton.current?.focus();
    };
    d.addEventListener("click", onClick);
    d.addEventListener("close", onClose);
    // Wider than a phone, the rail or drawer is on screen: the modal goes.
    const wide = window.matchMedia("(min-width: 600px)");
    const onWide = () => {
      if (wide.matches && d.open) d.close();
    };
    wide.addEventListener("change", onWide);
    return () => {
      d.removeEventListener("click", onClick);
      d.removeEventListener("close", onClose);
      wide.removeEventListener("change", onWide);
    };
  }, []);
  const lead: ReactNode = (
    <>
      <button
        ref={menuButton}
        type="button"
        className="ops-appbar-menu"
        aria-label="Open the console menu"
        aria-haspopup="dialog"
        aria-expanded={drawerOpen}
        onClick={() => setDrawerOpen(true)}
      >
        <MenuIcon />
      </button>
      <GroupSwitcher choice={choice} className="in-bar" />
      <VenuePicker memberships={venues} selected={selected} onSelect={select} className="in-bar" />
      {/* The rail hides the sidebar's Sandbox line; the demo café's badge says it there instead. */}
      {!isJudgeVenue(selected) && (
        <span className="ops-appbar-sandbox">
          <Icon name="paypal" size={16} />
          Sandbox
        </span>
      )}
    </>
  );
  return (
    <MotionRoot>
      <SnackbarProvider>
        <main className="ops-root with-shell">
          <aside className="ops-shell-side" aria-label="Console">
            <div className="ops-shell-brand">
              <Wordmark />
              <span className="ops-tag">THE RESTAURANT ROOM</span>
            </div>
            <GroupSwitcher choice={choice} className="in-side" />
            <VenuePicker memberships={venues} selected={selected} onSelect={select} className="in-side" />
            <div className="ops-shell-nav" ref={setNavTarget} />
            <ShellFoot onSignOut={signOutNow} />
          </aside>
          <dialog ref={drawer} className="ops-drawer" aria-label="Console menu">
            {drawerOpen && (
              <div className="ops-drawer-body">
                <div className="ops-drawer-head">
                  <Wordmark />
                  <button type="button" className="ops-drawer-close" aria-label="Close the menu" onClick={() => drawer.current?.close()}>
                    <MenuIcon close />
                  </button>
                </div>
                <GroupSwitcher choice={choice} className="in-drawer" />
                <VenuePicker memberships={venues} selected={selected} onSelect={select} className="in-drawer" />
                <div className="ops-shell-nav" ref={setDrawerTarget} />
                <ShellFoot onSignOut={signOutNow} />
              </div>
            )}
          </dialog>
          <div className="ops-shell-main">
            {error && (
              <p className="ops-error" role="alert">
                {error}
              </p>
            )}
            <GroupChoiceProvider value={choice}>
              <View
                key={selected}
                api={api}
                tenant={selected}
                navTarget={navTarget}
                drawerNavTarget={drawerOpen ? drawerTarget : null}
                appBarLead={lead}
                person={person}
                onDirty={(dirty) => {
                  draft.current = dirty;
                }}
              />
            </GroupChoiceProvider>
          </div>
        </main>
      </SnackbarProvider>
    </MotionRoot>
  );
}
