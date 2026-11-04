/**
 * Development preview only (/ops/preview): illustrative Dispatch records for
 * the browser tests, in the shapes the backend sends (delivery.dart,
 * partner.dart). Nothing here is a real customer, driver or delivery
 * company; "Demo Delivery Co." is the labelled simulator. Owner: stream S2.
 */
import type { Json } from "./contracts";
import type { Board, BoardRow, DriverRow, PartnerApps, PartnerEventRow } from "./dispatch";

const venue = { latitude: 40.7424, longitude: -74.006 };

function eta(minutes: number, distanceMeters: number, prepMinutes = 0, vehicle = "bike"): BoardRow["eta"] {
  return {
    estimate: true,
    prepMinutes,
    rideMinutes: minutes - prepMinutes,
    minutes,
    distanceMeters,
    at: new Date(Date.now() + minutes * 60000).toISOString(),
    vehicle,
    basis: `Straight line × 1.3 at 15 km/h${prepMinutes ? `, after about ${prepMinutes} min in the kitchen` : ""}.`,
  };
}

function job(over: Partial<BoardRow> & Pick<BoardRow, "id" | "number" | "status">): BoardRow {
  return {
    orderId: 100 + over.id,
    customerLabel: null,
    origin: "online",
    orderStatus: "ready",
    version: 2,
    fulfilledBy: "restaurant",
    partner: null,
    partnerRef: null,
    ready: true,
    createdAt: new Date(Date.now() - 18 * 60000).toISOString(),
    totalMinor: 2499,
    currency: "USD",
    feeMinor: 299,
    address: { line: "Sample drop-off · not a real address", city: "New York" },
    dropoff: { latitude: 40.7484, longitude: -73.9967 },
    eta: eta(6, 1430),
    driver: null,
    offer: null,
    position: null,
    ...over,
  };
}

export function dispatchPreview(asOf: string): Record<string, (p: Json) => unknown> {
  const board = (): Board => ({
    rows: [
      job({ id: 14, number: 14, status: "unassigned", address: { line: "Sample drop-off 1 · not a real address", city: "New York" } }),
      job({
        id: 15,
        number: 15,
        status: "unassigned",
        orderStatus: "preparing",
        ready: false,
        origin: "partner",
        partner: { id: 3, name: "Demo Delivery Co. (simulator)", simulator: true },
        partnerRef: "sim-5f2a",
        customerLabel: "Sample customer · Demo Delivery Co. (simulator)",
        address: { line: "Sample drop-off 2 · not a real address", city: "New York" },
        dropoff: { latitude: 40.7359, longitude: -74.0036 },
        eta: eta(12, 980, 8),
        offer: { offerId: 41, driverId: 2, driverName: "Sam · Sample", expiresAt: new Date(Date.now() + 80000).toISOString(), score: 88.4, by: "agent" },
      }),
      job({
        id: 12,
        number: 12,
        status: "outForDelivery",
        orderStatus: "outForDelivery",
        address: { line: "Sample drop-off 3 · not a real address", city: "New York" },
        dropoff: { latitude: 40.7505, longitude: -74.0024 },
        driver: { id: 3, name: "Ines · Sample", vehicle: "scooter", kind: "staff" },
        position: { latitude: 40.7461, longitude: -74.0035, at: asOf },
        eta: eta(3, 640, 0, "scooter"),
        pickedUpAt: new Date(Date.now() - 6 * 60000).toISOString(),
      }),
      job({
        id: 11,
        number: 11,
        status: "delivered",
        orderStatus: "delivered",
        driver: { id: 1, name: "Amal (demo login)", vehicle: "bike", kind: "staff" },
        eta: null,
        deliveredAt: new Date(Date.now() - 40 * 60000).toISOString(),
        proofKind: "code",
      }),
    ],
    venue,
    proofMode: "code",
    dispatchAuto: false,
    feeMode: "flat",
    aiDispatcher: true,
    now: asOf,
  });
  const drivers = (): { rows: DriverRow[] } => ({
    rows: [
      { id: 1, name: "Amal (demo login)", kind: "staff", vehicle: "bike", status: "available", active: true, version: 3, hasLogin: true, activeJobs: 0, jobIds: [], deliveredToday: 1, position: null, lastSeenAt: asOf },
      { id: 2, name: "Sam · Sample", kind: "staff", vehicle: "bike", status: "available", active: true, version: 2, hasLogin: false, activeJobs: 0, jobIds: [], deliveredToday: 0, position: null, sample: true },
      { id: 3, name: "Ines · Sample", kind: "staff", vehicle: "scooter", status: "busy", active: true, version: 4, hasLogin: false, activeJobs: 1, jobIds: [12], deliveredToday: 2, position: { latitude: 40.7461, longitude: -74.0035, at: asOf }, sample: true },
      { id: 4, name: "Noor · Sample", kind: "staff", vehicle: "car", status: "offline", active: true, version: 1, hasLogin: false, activeJobs: 0, jobIds: [], deliveredToday: 0, position: null, sample: true },
    ],
  });
  const apps = (): PartnerApps => ({
    configured: true,
    endpoint: "/api/partner/v1",
    rows: [
      {
        id: 3,
        name: "Demo Delivery Co. (simulator)",
        keyPrefix: "k7m2p9qa",
        keyHint: "rk_k7m2p9qa_…",
        webhookUrl: "https://ops.rays.to/api/partner-sim/webhook",
        secretVersion: 1,
        simulator: true,
        active: true,
        version: 2,
        createdAt: asOf,
        owedThisMonth: { orders: 2, totalMinor: 4998, currency: "USD" },
        events24h: 9,
        failing: 0,
      },
    ],
  });
  const events = (): { rows: PartnerEventRow[] } => ({
    rows: [
      { id: 9, appId: 3, appName: "Demo Delivery Co. (simulator)", simulator: true, direction: "out", type: "order.accepted", ref: "sim-5f2a", status: "delivered", attempts: 1, responseCode: 200, summary: { ref: "sim-5f2a" }, nextAttemptAt: null, createdAt: asOf },
      { id: 8, appId: 3, appName: "Demo Delivery Co. (simulator)", simulator: true, direction: "in", type: "orders.create", ref: "sim-5f2a", status: "accepted", attempts: 1, responseCode: 201, idempotencyKey: "sim-1f0c", summary: { fulfilledBy: "restaurant", lines: 2 }, nextAttemptAt: null, createdAt: asOf },
      { id: 7, appId: 3, appName: "Demo Delivery Co. (simulator)", simulator: true, direction: "in", type: "menu.read", ref: null, status: "ok", attempts: 1, responseCode: 200, summary: {}, nextAttemptAt: null, createdAt: asOf },
    ],
  });
  return {
    "delivery.board": board,
    drivers,
    "partner.apps": apps,
    "partner.events": events,
  };
}
