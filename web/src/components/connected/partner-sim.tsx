"use client";
/**
 * The partner simulator inside Dispatch: "Demo Delivery Co.", a pretend
 * outside delivery app, drives the real Delivery Partner API through the
 * console server, which keeps its key and signs each request. The banner
 * stays on screen the whole time: it is a simulator, not Uber Eats or Glovo.
 * Owner: stream S2.
 */
import { useCallback, useEffect, useState } from "react";
import type { Json } from "@/lib/connected/contracts";
import { simulatorBanner } from "@/lib/connected/dispatch";
import { connectedAuth } from "@/lib/connected/firebase";
import { words } from "@/lib/connected/grid-columns";
import { Icon } from "./icons";

interface SimOrder {
  ref: string;
  fulfilledBy: "restaurant" | "partner";
  status?: string;
  number?: number | null;
  totalMinor?: number;
  currency?: string;
  pickupCode?: string | null;
  dropoffCode?: string | null;
}

interface Hook {
  id: string;
  type: string;
  ref: string | null;
  receivedAt: string;
  verified: boolean;
}

/** One call to the simulator's routes with the person's Firebase proof. */
export async function simFetch(path: string, init: { method?: "GET" | "POST"; body?: Json } = {}): Promise<{ status: number; data: Json; message?: string }> {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  try {
    const user = (await connectedAuth()).currentUser;
    if (user) headers["X-Raysto-Firebase-Token"] = await user.getIdToken();
  } catch {
    // Signed out or not configured: the route answers why.
  }
  let response: Response;
  try {
    response = await fetch(`/api/partner-sim/${path}`, {
      method: init.method ?? "GET",
      headers,
      body: init.body ? JSON.stringify(init.body) : undefined,
      cache: "no-store",
      signal: AbortSignal.timeout(30000),
    });
  } catch {
    return { status: 0, data: {}, message: "The simulator did not answer." };
  }
  const payload = (await response.json().catch(() => ({}))) as Json;
  if (!response.ok) {
    const error = (payload.error as Json | undefined) ?? {};
    const message =
      response.status === 404 && (error.code === "not_configured" || !error.code)
        ? "The simulator is not configured on this deployment."
        : String(error.message ?? `The simulator answered HTTP ${response.status}.`);
    return { status: response.status, data: payload, message };
  }
  return { status: response.status, data: ((payload.data as Json | undefined) ?? payload) as Json };
}

export function PartnerSim({ tenant }: { tenant: number }) {
  const [orders, setOrders] = useState<SimOrder[]>([]);
  const [hooks, setHooks] = useState<Hook[]>([]);
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const [error, setError] = useState("");

  const readHooks = useCallback(async () => {
    const got = await simFetch("events");
    if (got.status === 200) setHooks(((got.data.rows as Hook[] | undefined) ?? []).slice(0, 20));
  }, []);

  useEffect(() => {
    void readHooks();
    const timer = setInterval(() => document.visibilityState === "visible" && void readHooks(), 5000);
    return () => clearInterval(timer);
  }, [readHooks]);

  async function run(fn: () => Promise<void>) {
    setBusy(true);
    setError("");
    setNote("");
    try {
      await fn();
    } finally {
      setBusy(false);
    }
  }

  const merge = (ref: string, data: Json) =>
    setOrders((list) =>
      list.map((o) =>
        o.ref === ref
          ? {
              ...o,
              status: String(data.status ?? o.status ?? ""),
              number: (data.number as number | null | undefined) ?? o.number,
              totalMinor: (data.totalMinor as number | undefined) ?? o.totalMinor,
              currency: (data.currency as string | undefined) ?? o.currency,
              pickupCode: (data.pickupCode as string | null | undefined) ?? o.pickupCode,
              dropoffCode: (data.dropoffCode as string | null | undefined) ?? o.dropoffCode,
            }
          : o,
      ),
    );

  const send = (fulfilledBy: SimOrder["fulfilledBy"]) =>
    run(async () => {
      const got = await simFetch("orders", { method: "POST", body: { restaurantId: tenant, fulfilledBy } });
      if (got.message) return setError(got.message);
      const ref = String(got.data.ref ?? "");
      setOrders((list) => [{ ref, fulfilledBy }, ...list].slice(0, 10));
      merge(ref, got.data);
      setNote(`Order ${ref} sent, signed with the simulator's key. It is on the Board now.`);
    });

  const step = (o: SimOrder, path: string, body?: Json, said?: string) =>
    run(async () => {
      const got = await simFetch(`orders/${o.ref}${path}`, { method: body ? "POST" : "GET", body });
      if (got.message) return setError(got.message);
      merge(o.ref, got.data);
      if (said) setNote(said);
      await readHooks();
    });

  return (
    <div className="ops-dsp-sim">
      <p className="ops-dsp-banner" role="note">
        <Icon name="alert" size={18} />
        {simulatorBanner}
      </p>
      <section className="ops-panel" aria-labelledby="dsp-sim-title">
        <h2 id="dsp-sim-title">Demo Delivery Co. (simulator)</h2>
        <p>
          It behaves like an outside delivery app: it reads the menu and sends orders through Raysto&apos;s Delivery Partner API, signed with
          its own key, and it receives Raysto&apos;s signed webhooks. Its orders are sample orders to sample addresses; nobody pays through
          PayPal for them, and the partner settles outside PayPal.
        </p>
        <div className="ops-dsp-job-actions">
          <button className="ops-primary" disabled={busy} onClick={() => void send("restaurant")}>
            <Icon name="plus" size={18} />
            Send an order for the café&apos;s driver
          </button>
          <button className="ops-secondary" disabled={busy} onClick={() => void send("partner")}>
            Send an order for the simulator&apos;s courier
          </button>
        </div>
        {error && (
          <p className="ops-error" role="alert">
            {error}
          </p>
        )}
        {note && (
          <p className="ops-note" role="status">
            {note}
          </p>
        )}
      </section>
      {orders.length > 0 && (
        <section className="ops-panel" aria-labelledby="dsp-sim-orders">
          <h2 id="dsp-sim-orders">Orders it sent</h2>
          <ul className="ops-dsp-sim-list">
            {orders.map((o) => (
              <li key={o.ref}>
                <div>
                  <strong>{o.ref}</strong>
                  {o.number != null ? ` · #${o.number}` : ""} · {o.fulfilledBy === "partner" ? "simulator's courier" : "café's driver"} ·{" "}
                  {o.status ? words(o.status) : "sent"}
                  <small>
                    {o.pickupCode ? `Pickup code for its courier: ${o.pickupCode}. ` : ""}
                    {o.dropoffCode ? `Code for the door: ${o.dropoffCode}.` : ""}
                  </small>
                </div>
                <div className="ops-dsp-job-actions">
                  <button className="ops-secondary" disabled={busy} onClick={() => void step(o, "")}>
                    <Icon name="refresh" size={18} />
                    Refresh
                  </button>
                  {o.fulfilledBy === "partner" && (
                    <>
                      <button className="ops-secondary" disabled={busy} onClick={() => void step(o, "/status", { status: "picked_up" }, `Reported ${o.ref} picked up.`)}>
                        Courier picked it up
                      </button>
                      <button className="ops-secondary" disabled={busy} onClick={() => void step(o, "/status", { status: "delivered" }, `Reported ${o.ref} delivered.`)}>
                        Courier delivered it
                      </button>
                    </>
                  )}
                  <button className="ops-secondary" disabled={busy} onClick={() => void step(o, "/cancel", {}, `Asked to cancel ${o.ref}.`)}>
                    Cancel
                  </button>
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}
      <section className="ops-panel" aria-labelledby="dsp-sim-hooks">
        <h2 id="dsp-sim-hooks">Webhooks it received</h2>
        {hooks.length === 0 ? (
          <p className="ops-note">None yet. Raysto sends one when the kitchen accepts or finishes a simulator order, and as its driver picks up and hands over.</p>
        ) : (
          <ul className="ops-dsp-sim-list">
            {hooks.map((h) => (
              <li key={h.id}>
                <div>
                  <strong>{h.type}</strong>
                  {h.ref ? ` · ${h.ref}` : ""}
                  <small>
                    {new Date(h.receivedAt).toLocaleTimeString()} · {h.verified ? "signature verified" : "unverified"}
                  </small>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
