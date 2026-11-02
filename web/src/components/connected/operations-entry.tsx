"use client";
import { useEffect, useRef, useState } from "react";
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
import { judge, judgeLogin } from "@/lib/connected/judge";
import { Icon } from "./icons";

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
  const draft = useRef(false);
  const canLeave = () =>
    !draft.current || window.confirm("Discard the unsent room message?");
  const [auth, setAuth] = useState<Auth>();
  const [api, setApi] = useState<ConnectedApi>();
  const [memberships, setMemberships] = useState<Membership[]>([]);
  const [selected, setSelected] = useState<number>();
  const [email, setEmail] = useState(""),
    [password, setPassword] = useState(""),
    [error, setError] = useState("");
  const [busy, setBusy] = useState(true),
    [signedIn, setSignedIn] = useState(false);
  // The sidebar slot the workspace renders its sections into.
  const [navTarget, setNavTarget] = useState<HTMLElement | null>(null);
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
            .query<{ memberships: Membership[] }>("me")
            .then((me) => {
              if (!active || current !== next) return;
              const allowed = me.memberships.filter((m) =>
                ["owner", "manager"].includes(m.role),
              );
              setApi(next);
              setMemberships(allowed);
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
  const signOutButton = (className: string) => (
    <button
      className={className}
      onClick={() => {
        if (auth && canLeave()) {
          draft.current = false;
          void signOut(auth);
        }
      }}
    >
      <Icon name="signOut" size={18} />
      Sign out
    </button>
  );
  const wordmark = (
    <a className="ops-wordmark" href="/ops">
      rays<span>to</span>
      <i>✳</i>
    </a>
  );
  // Signed in with a restaurant: the console shell, with the sections in a
  // sidebar that the workspace fills.
  if (signedIn && !busy && api && selected)
    return (
      <main className="ops-root with-shell">
        <aside className="ops-shell-side">
          <div className="ops-shell-brand">
            {wordmark}
            <span className="ops-tag">THE RESTAURANT ROOM</span>
          </div>
          <label className="ops-venue">
            <span>Restaurant</span>
            <select
              value={selected}
              onChange={(e) => {
                if (canLeave()) {
                  draft.current = false;
                  setSelected(Number(e.target.value));
                }
              }}
            >
              {memberships.map((m) => (
                <option key={m.restaurantId} value={m.restaurantId}>
                  {m.name}
                </option>
              ))}
            </select>
            <small>
              You are its {memberships.find((m) => m.restaurantId === selected)?.role ?? "manager"}
            </small>
          </label>
          <div className="ops-shell-nav" ref={setNavTarget} />
          <div className="ops-shell-foot">
            <span className="ops-sandbox">
              <Icon name="paypal" size={16} />
              PayPal Sandbox · no live payments
            </span>
            {signOutButton("ops-quiet")}
          </div>
        </aside>
        <div className="ops-shell-main">
          {error && (
            <p className="ops-error" role="alert">
              {error}
            </p>
          )}
          <Workspace
            key={selected}
            api={api}
            tenant={selected}
            navTarget={navTarget}
            onDirty={(dirty) => {
              draft.current = dirty;
            }}
          />
        </div>
      </main>
    );
  return (
    <main className="ops-root">
      <header className="ops-top">
        {wordmark}
        <span className="ops-tag">THE RESTAURANT ROOM</span>
        {signedIn && signOutButton("ops-quiet")}
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
                <span className="ops-eyebrow">HACKATHON JUDGES</span>
                <p>
                  One click into the demo café: five live demos, PayPal
                  Sandbox only.
                </p>
                <button
                  type="button"
                  className="ops-primary"
                  onClick={() => void login(false, true)}
                >
                  <Icon name="play" size={18} />
                  Try Raysto as a judge
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
