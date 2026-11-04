/**
 * Dispatch: the shapes the backend sends (delivery.dart, partner.dart,
 * agent_dispatch.dart) and the plain functions the section, the map and the
 * tests share. Distances are straight lines × 1.3 and every time is an
 * estimate; the words here say so. Owner: stream S2.
 */
import type { Json } from "./contracts";

export interface Point {
  latitude: number;
  longitude: number;
}

export interface Estimate {
  estimate: true;
  prepMinutes: number;
  rideMinutes: number | null;
  minutes: number | null;
  distanceMeters: number | null;
  at: string | null;
  vehicle: string;
  basis: string;
}

export interface BoardOffer {
  offerId: number;
  driverId: number;
  driverName?: string | null;
  expiresAt: string;
  score: number;
  by?: "person" | "agent";
}

export interface BoardRow {
  id: number;
  orderId: number;
  number: number | null;
  customerLabel?: string | null;
  origin: string;
  orderStatus: string;
  status: string;
  version: number;
  fulfilledBy: "restaurant" | "partner";
  partner: { id: number; name: string; simulator: boolean } | null;
  partnerRef?: string | null;
  ready: boolean;
  createdAt: string;
  totalMinor: number;
  currency: string;
  feeMinor: number;
  address: { line?: string; city?: string; instructions?: string } | null;
  dropoff: Point | null;
  eta: Estimate | null;
  etaAt?: string | null;
  driver: { id: number; name: string; vehicle: string; kind: string } | null;
  offer: BoardOffer | null;
  position: (Point & { at: string }) | null;
  pickedUpAt?: string | null;
  deliveredAt?: string | null;
  proofKind?: string | null;
}

export interface Board {
  rows: BoardRow[];
  venue: Point | null;
  proofMode: "none" | "code" | "photo";
  dispatchAuto: boolean;
  feeMode: "flat" | "distance";
  aiDispatcher: boolean;
  now: string;
}

export interface DriverRow {
  id: number;
  name: string;
  kind: "staff" | "partner";
  vehicle: string;
  status: "offline" | "available" | "busy";
  active: boolean;
  version: number;
  hasLogin: boolean;
  userId?: string | null;
  phoneLast4?: string | null;
  payoutEmail?: string | null;
  lastSeenAt?: string | null;
  activeJobs: number;
  jobIds: number[];
  deliveredToday: number;
  position: (Point & { at: string }) | null;
  sample?: boolean;
}

export interface Ranked {
  driverId: number;
  name: string;
  vehicle: string;
  status: string;
  hasLogin: boolean;
  activeJobs: number;
  toVenueMeters: number;
  tripMeters: number | null;
  minutes: number;
  score: number;
  declinedBefore: boolean;
  reasons: string[];
}

export interface Suggestion {
  assignmentId: number;
  ranking: Ranked[];
  ai: "queued" | "off";
  taskId?: number | null;
  basis: string;
}

export interface PartnerAppRow {
  id: number;
  name: string;
  keyPrefix: string;
  keyHint: string;
  webhookUrl: string | null;
  secretVersion: number;
  simulator: boolean;
  active: boolean;
  version: number;
  createdAt: string;
  owedThisMonth?: { orders: number; totalMinor: number; currency: string | null };
  events24h?: number;
  failing?: number;
}

export interface PartnerApps {
  configured: boolean;
  endpoint: string;
  rows: PartnerAppRow[];
}

export interface PartnerEventRow {
  id: number;
  appId: number;
  appName: string | null;
  simulator: boolean;
  direction: "in" | "out";
  type: string;
  ref: string | null;
  status: string;
  attempts: number;
  responseCode: number | null;
  idempotencyKey?: string | null;
  summary: Json;
  nextAttemptAt: string | null;
  createdAt: string;
}

/** A key and secret shown once, straight after creation or rotation. */
export interface Revealed {
  id: number;
  name: string;
  key?: string;
  webhookSecret?: string;
}

/** The part of ConnectedApi the section needs; tests pass a fake. */
export interface DispatchTransport {
  query<T>(name: string, params?: Json): Promise<T>;
  command<T>(name: string, restaurantId: number, data?: Json, options?: { id?: number; version?: number; key?: string }): Promise<T>;
}

export function dispatch(api: DispatchTransport, tenant: number) {
  const r = { restaurantId: tenant };
  return {
    board: () => api.query<Board>("delivery.board", r),
    drivers: () => api.query<{ rows: DriverRow[] }>("drivers", { ...r, all: true }).then((d) => d.rows),
    apps: () => api.query<PartnerApps>("partner.apps", r),
    events: (limit = 50) => api.query<{ rows: PartnerEventRow[] }>("partner.events", { ...r, limit }).then((d) => d.rows),
    inbox: () => api.query<{ rows: Json[] }>("agent.inbox", r).then((d) => d.rows ?? []),
    offer: (assignmentId: number, driverId: number, key?: string) =>
      api.command<Json>("delivery.offer", tenant, { driverId }, { id: assignmentId, key }),
    withdraw: (offerId: number) => api.command<Json>("delivery.respond", tenant, { answer: "withdraw" }, { id: offerId }),
    answerFor: (offerId: number, answer: "accept" | "decline") =>
      api.command<Json>("delivery.respond", tenant, { answer }, { id: offerId }),
    suggest: (assignmentId: number) => api.command<Suggestion>("dispatch.suggest", tenant, { assignmentId }),
    availability: (driverId: number, status: "available" | "offline") =>
      api.command<Json>("driver.availability", tenant, { status }, { id: driverId }),
    saveDriver: (data: Json, id?: number, version?: number) => api.command<Json>("driver.save", tenant, data, { id, version }),
    createApp: (data: Json) => api.command<Json>("partner.app.save", tenant, data),
    updateApp: (id: number, version: number, data: Json) => api.command<Json>("partner.app.save", tenant, data, { id, version }),
    rotateApp: (id: number, version: number, what: "key" | "secret") =>
      api.command<Json>("partner.app.rotate", tenant, { what }, { id, version }),
  };
}

export type DispatchApi = ReturnType<typeof dispatch>;

/** Whole seconds until an instant, never below zero. */
export function secondsLeft(iso: string | null | undefined, now = Date.now()): number {
  if (!iso) return 0;
  const at = Date.parse(iso);
  return Number.isNaN(at) ? 0 : Math.max(0, Math.ceil((at - now) / 1000));
}

/** "1:05" for 65 seconds. */
export function clock(seconds: number): string {
  const s = Math.max(0, Math.round(seconds));
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
}

/** "1.4 km" or "850 m"; empty when unknown. */
export function distanceText(meters: number | null | undefined): string {
  if (meters == null || !Number.isFinite(meters)) return "";
  return meters >= 1000 ? `${(meters / 1000).toFixed(1)} km` : `${Math.round(meters / 10) * 10} m`;
}

/** "About 18 min (estimate)" or a plain "No estimate". */
export function etaText(eta: Estimate | null | undefined): string {
  if (!eta || eta.minutes == null) return "No estimate";
  return `About ${eta.minutes} min (estimate)`;
}

const statusWords: Record<string, string> = {
  unassigned: "Needs a driver",
  assigned: "Driver assigned",
  collected: "Collected",
  outForDelivery: "On the way",
  delivered: "Delivered",
  issue: "Issue",
  cancelled: "Cancelled",
};
export const jobWords = (status: string) => statusWords[status] ?? status;

/**
 * The shared grid's pills take a status word and colour it (grid-columns.ts).
 * Each job state maps to one word with the right colour, and back again for
 * the words a person reads.
 */
const toneKeys: Record<string, string> = {
  unassigned: "due",
  assigned: "assigned",
  collected: "accepted",
  outForDelivery: "outForDelivery",
  delivered: "delivered",
  issue: "low",
  cancelled: "cancelled",
};
export const jobTone = (status: string) => toneKeys[status] ?? status;
export const toneWords = (key: unknown) => {
  const status = Object.entries(toneKeys).find(([, k]) => k === key)?.[0] ?? String(key ?? "");
  return jobWords(status);
};

export const vehicleWords: Record<string, string> = { foot: "On foot", bike: "Bike", scooter: "Scooter", car: "Car" };

/** A job the café's own drivers may be offered: unassigned, not the partner's, not cancelled. */
export const canOffer = (row: BoardRow) =>
  row.status === "unassigned" && row.fulfilledBy !== "partner" && !["cancelled", "rejected", "awaitingPayment"].includes(row.orderStatus);

/** Drivers a job can be dropped on: active café drivers who are not offline. */
export const takesJobs = (d: DriverRow) => d.kind === "staff" && d.active && d.status !== "offline";

export const jobLabel = (row: Pick<BoardRow, "number" | "orderId">) => `#${row.number ?? row.orderId}`;

export type PinKind = "venue" | "job" | "driver";
export interface MapPin {
  id: string;
  kind: PinKind;
  latitude: number;
  longitude: number;
  label: string;
  /** The pin's state, used as its CSS class (a job's or a driver's status). */
  tone: string;
  selected?: boolean;
}

export interface MapRoute {
  id: string;
  points: [number, number][];
  tone: "plan" | "live";
}

/** Pins for the café, each job's door and each driver's last position. */
export function mapPins(board: Board | undefined, drivers: DriverRow[] | undefined, selected?: number): MapPin[] {
  const pins: MapPin[] = [];
  if (board?.venue) pins.push({ id: "venue", kind: "venue", ...board.venue, label: "The café", tone: "venue" });
  for (const row of board?.rows ?? []) {
    if (!row.dropoff || row.status === "cancelled") continue;
    pins.push({
      id: `job-${row.id}`,
      kind: "job",
      ...row.dropoff,
      label: `${jobLabel(row)} · ${jobWords(row.status)}${row.address?.line ? ` · ${row.address.line}` : ""}`,
      tone: row.status,
      selected: row.id === selected,
    });
  }
  for (const d of drivers ?? []) {
    if (!d.position) continue;
    pins.push({ id: `driver-${d.id}`, kind: "driver", latitude: d.position.latitude, longitude: d.position.longitude, label: `${d.name} · ${vehicleWords[d.vehicle] ?? d.vehicle}`, tone: d.status });
  }
  return pins;
}

/** The planned ride for the selected job, and the live leg for jobs on the way. */
export function mapRoutes(board: Board | undefined, selected?: number): MapRoute[] {
  const out: MapRoute[] = [];
  const venue = board?.venue;
  for (const row of board?.rows ?? []) {
    if (!row.dropoff || ["delivered", "cancelled"].includes(row.status)) continue;
    const door: [number, number] = [row.dropoff.latitude, row.dropoff.longitude];
    if (row.position) out.push({ id: `live-${row.id}`, points: [[row.position.latitude, row.position.longitude], door], tone: "live" });
    else if (venue && row.id === selected) out.push({ id: `plan-${row.id}`, points: [[venue.latitude, venue.longitude], door], tone: "plan" });
  }
  return out;
}

/** The map's middle: the café, else the first job, else Raysto's default. */
export function mapCenter(board: Board | undefined): [number, number] {
  const p = board?.venue ?? board?.rows.find((r) => r.dropoff)?.dropoff;
  return p ? [p.latitude, p.longitude] : [40.7424, -74.006];
}

/** What a failed command means for a manager. */
export function failText(e: unknown): string {
  const code = (e as { code?: string } | undefined)?.code;
  if (code === "reauthentication_required") return "Confirm it's you to issue or rotate a partner key.";
  if (code === "not_configured") return "Partner apps are not configured on this server yet.";
  if (code === "driver_unavailable") return String((e as Error).message);
  if (code === "invalid_transition") return String((e as Error).message || "This job changed. Refresh the board.");
  return String(e instanceof Error ? e.message : e);
}

/** The partner API's event in a sentence: "Signed webhook: order.ready · delivered (HTTP 200)". */
export function eventText(e: PartnerEventRow): string {
  const head = e.direction === "in" ? "Received" : "Signed webhook";
  const code = e.responseCode ? ` (HTTP ${e.responseCode})` : "";
  const retry = e.status === "retrying" && e.nextAttemptAt ? `, next try ${new Date(e.nextAttemptAt).toLocaleTimeString()}` : "";
  return `${head}: ${e.type}${e.ref ? ` · ${e.ref}` : ""} · ${e.status}${code}${retry}`;
}

/** Copy for the keys panel: only the prefix is ever shown again. */
export const keyNotice =
  "Copy the key and the webhook secret now: Raysto keeps only a hash of the key and derives the secret, so neither is shown again.";

export const simulatorBanner = "Simulator: a pretend outside delivery app. Not Uber Eats or Glovo.";
