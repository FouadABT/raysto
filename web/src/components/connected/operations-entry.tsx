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

const Workspace = dynamic(
  () => import("./operations-workspace").then((m) => m.OperationsWorkspace),
  { ssr: false, loading: () => <p>Setting your table…</p> },
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
  useEffect(() => {
    let active = true,
      unsubscribe = () => {},
      current: ConnectedApi | undefined;
    void connectedAuth()
      .then((a) => {
        if (!active) return;
        setAuth(a);
        unsubscribe = onAuthStateChanged(a, (user) => {
          current?.close();
          current = undefined;
          setApi(undefined);
          setMemberships([]);
          setSelected(undefined);
          setSignedIn(!!user);
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
  async function login(google: boolean) {
    if (!auth) return;
    setBusy(true);
    setError("");
    try {
      if (google) await signInWithPopup(auth, new GoogleAuthProvider());
      else await signInWithEmailAndPassword(auth, email, password);
      setPassword("");
    } catch (e) {
      setError(String(e));
      setBusy(false);
    }
  }
  return (
    <main className="ops-root">
      <header className="ops-top">
        <a className="ops-wordmark" href="/ops">
          rays<span>to</span>
          <i>✳</i>
        </a>
        <span className="ops-tag">THE RESTAURANT ROOM</span>
        {signedIn && (
          <button
            onClick={() => {
              if (auth && canLeave()) {
                draft.current = false;
                void signOut(auth);
              }
            }}
          >
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
        <p className="ops-loading" role="status">
          Connecting your restaurant…
        </p>
      ) : !signedIn ? (
        <section className="ops-welcome">
          <div>
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
            <h2>Welcome back.</h2>
            <p>Use your invited restaurant account.</p>
            <button
              type="button"
              className="ops-primary"
              onClick={() => void login(true)}
            >
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
            <button type="submit">Sign in</button>
            <small>
              Connected accounts only. Restaurant access is granted by your
              team.
            </small>
          </form>
        </section>
      ) : api && selected ? (
        <>
          <div className="ops-context">
            <label>
              Restaurant{" "}
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
                    {m.name} · {m.role}
                  </option>
                ))}
              </select>
            </label>
            <span>PayPal Sandbox · no live payments</span>
          </div>
          <Workspace
            key={selected}
            api={api}
            tenant={selected}
            onDirty={(dirty) => {
              draft.current = dirty;
            }}
          />
        </>
      ) : (
        <section className="ops-empty">
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
