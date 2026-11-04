/**
 * The partner simulator's server half: "Demo Delivery Co.", a pretend
 * outside delivery app (not Uber Eats or Glovo). Its key and webhook secret
 * live only in the console server's environment (`RAYSTO_SIM_PARTNER_KEY`,
 * `RAYSTO_SIM_PARTNER_SECRET`, never `NEXT_PUBLIC_`); it signs its requests
 * to the real Delivery Partner API and verifies the webhooks Raysto sends
 * back. Only a signed-in owner or manager of the judges' café may drive it.
 *
 * Imported by route handlers only (it uses node:crypto); never from a client
 * component. Owner: stream S2.
 */
import { createHash, createHmac, randomBytes, timingSafeEqual } from "node:crypto";

export const partnerBase = "https://api.rays.to/api/partner/v1";
const backend = "https://api.rays.to/api/v2";

export interface SimConfig {
  key: string;
  secret: string;
  restaurantId: number;
}

/** The simulator's settings, or null when this deployment has none. */
export function simConfig(env: Record<string, string | undefined> = process.env): SimConfig | null {
  const key = env.RAYSTO_SIM_PARTNER_KEY ?? "";
  const secret = env.RAYSTO_SIM_PARTNER_SECRET ?? "";
  const restaurantId = Number(env.RAYSTO_SIM_RESTAURANT_ID ?? env.NEXT_PUBLIC_RAYSTO_JUDGE_RESTAURANT_ID ?? 0);
  if (!/^rk_[a-z0-9]{8}_[A-Za-z0-9_-]{20,100}$/.test(key) || !secret.startsWith("whsec_") || !(restaurantId > 0)) return null;
  return { key, secret, restaurantId };
}

/** `hex(HMAC-SHA256(secret, "t.body"))`, as Raysto signs and checks. */
export function sign(secret: string, t: number, body: string): string {
  return createHmac("sha256", secret).update(`${t}.${body}`).digest("hex");
}

/** Whether an `X-Raysto-Signature` header signs `body` with `secret`, within five minutes. */
export function verify(secret: string, header: string | null, body: string, nowSeconds = Math.floor(Date.now() / 1000)): boolean {
  const m = /^t=(\d{1,12}),v1=([0-9a-f]{64})$/.exec(header?.trim() ?? "");
  if (!m) return false;
  const t = Number(m[1]);
  if (Math.abs(nowSeconds - t) > 300) return false;
  const expected = Buffer.from(sign(secret, t, body), "hex");
  const given = Buffer.from(m[2], "hex");
  return expected.length === given.length && timingSafeEqual(expected, given);
}

export interface ReceivedHook {
  id: string;
  type: string;
  ref: string | null;
  receivedAt: string;
  attempt: number | null;
  verified: true;
  data: Record<string, unknown>;
}

/** The last 50 verified webhooks, in memory (they reset when the server restarts). */
const g = globalThis as typeof globalThis & { __raystoSimHooks?: ReceivedHook[] };
export const hooks: ReceivedHook[] = (g.__raystoSimHooks ??= []);

export function remember(body: string): ReceivedHook | null {
  let event: Record<string, unknown>;
  try {
    event = JSON.parse(body) as Record<string, unknown>;
  } catch {
    return null;
  }
  if (typeof event.id !== "string" || typeof event.type !== "string") return null;
  const hook: ReceivedHook = {
    id: event.id,
    type: event.type,
    ref: typeof event.ref === "string" ? event.ref : null,
    receivedAt: new Date().toISOString(),
    attempt: typeof event.attempt === "number" ? event.attempt : null,
    verified: true,
    data: (event.data as Record<string, unknown>) ?? {},
  };
  // A retried event replaces its earlier copy.
  const at = hooks.findIndex((h) => h.id === hook.id);
  if (at >= 0) hooks.splice(at, 1);
  hooks.unshift(hook);
  hooks.splice(50);
  return hook;
}

export const json = (status: number, value: unknown) => Response.json(value, { status, headers: { "Cache-Control": "no-store" } });
export const refuse = (status: number, code: string, message: string) => json(status, { error: { code, message } });

/** The console's own origin, as the backend proxy checks it for writes. */
export function sameOrigin(request: Request): boolean {
  const origin =
    process.env.RAYSTO_CONSOLE_ORIGIN ?? (process.env.NODE_ENV === "production" ? "https://ops.rays.to" : new URL(request.url).origin);
  return request.headers.get("origin") === origin;
}

const verified = new Map<string, number>();

/**
 * Whether the request comes from a signed-in owner or manager of the judges'
 * café: the Firebase ID token is exchanged with Raysto's backend and the
 * person's memberships are read there. A good answer is kept for 5 minutes.
 */
export async function authorize(request: Request, config: SimConfig): Promise<Response | null> {
  if (request.method === "POST" && !sameOrigin(request)) return refuse(403, "invalid_origin", "Open the simulator from the console.");
  const token = request.headers.get("x-raysto-firebase-token") ?? "";
  if (token.length < 20 || token.length > 8000) return refuse(401, "unauthorized", "Sign in to the console to use the simulator.");
  const mark = createHash("sha256").update(token).digest("hex");
  if ((verified.get(mark) ?? 0) > Date.now()) return null;
  try {
    const signIn = await fetch(`${backend}/auth/firebase`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ firebaseIdToken: token }),
      cache: "no-store",
      redirect: "error",
      signal: AbortSignal.timeout(15000),
    });
    const session = (await signIn.json().catch(() => ({}))) as { data?: { token?: string } };
    if (!signIn.ok || !session.data?.token) return refuse(401, "unauthorized", "Sign in to the console to use the simulator.");
    const me = await fetch(`${backend}/queries/me`, {
      headers: { Authorization: `Bearer ${session.data.token}`, "X-Raysto-Firebase-Token": token },
      cache: "no-store",
      redirect: "error",
      signal: AbortSignal.timeout(15000),
    });
    const body = (await me.json().catch(() => ({}))) as { data?: { memberships?: { restaurantId: number; role: string }[] } };
    const ok = (body.data?.memberships ?? []).some((m) => m.restaurantId === config.restaurantId && ["owner", "manager"].includes(m.role));
    if (!ok) return refuse(403, "forbidden", "The simulator is for the managers of the judges' café.");
  } catch {
    return refuse(503, "unavailable", "Raysto did not answer. Try again.");
  }
  verified.set(mark, Date.now() + 5 * 60_000);
  if (verified.size > 200) verified.delete(verified.keys().next().value as string);
  return null;
}

/** One signed call to the real Delivery Partner API as the simulator. */
export async function partnerCall(
  config: SimConfig,
  method: "GET" | "POST",
  path: string,
  body?: unknown,
): Promise<{ status: number; data: Record<string, unknown> }> {
  const raw = body === undefined ? "" : JSON.stringify(body);
  const t = Math.floor(Date.now() / 1000);
  const headers: Record<string, string> = {
    Authorization: `Bearer ${config.key}`,
    "X-Raysto-Signature": `t=${t},v1=${sign(config.secret, t, raw)}`,
    "User-Agent": "Raysto-Partner-Simulator/1.0",
  };
  if (method === "POST") {
    headers["Content-Type"] = "application/json";
    headers["Idempotency-Key"] = `sim-${randomBytes(12).toString("hex")}`;
  }
  const response = await fetch(`${partnerBase}/${path}`, {
    method,
    headers,
    body: method === "POST" ? raw : undefined,
    cache: "no-store",
    redirect: "error",
    signal: AbortSignal.timeout(20000),
  });
  const data = (await response.json().catch(() => ({}))) as Record<string, unknown>;
  return { status: response.status, data };
}

/** Sample drop-offs near the judges' café in Manhattan: not real customers. */
export const sampleDropoffs = [
  { line: "Sample drop-off 1 · not a real address", city: "New York", country: "US", latitude: 40.7484, longitude: -73.9967 },
  { line: "Sample drop-off 2 · not a real address", city: "New York", country: "US", latitude: 40.7359, longitude: -74.0036 },
  { line: "Sample drop-off 3 · not a real address", city: "New York", country: "US", latitude: 40.7505, longitude: -74.0024 },
];

type MenuItem = { productId?: number; available?: boolean; modifiers?: { min?: number }[] };

/** One or two menu items with no required choices, for a sample order. */
export function sampleLines(items: unknown): { productId: number; quantity: number }[] {
  const list = Array.isArray(items) ? (items as MenuItem[]) : [];
  return list
    .filter((i) => typeof i.productId === "number" && i.available !== false && (i.modifiers ?? []).every((m) => (m.min ?? 0) === 0))
    .slice(0, 2)
    .map((i, n) => ({ productId: i.productId as number, quantity: n === 0 ? 2 : 1 }));
}

export const sampleRef = () => `sim-${randomBytes(4).toString("hex")}`;
