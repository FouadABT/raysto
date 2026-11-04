import { test } from "node:test";
import assert from "node:assert/strict";
import { createHmac } from "node:crypto";
import {
  canOffer,
  clock,
  dispatch,
  distanceText,
  etaText,
  eventText,
  failText,
  jobTone,
  mapCenter,
  mapPins,
  mapRoutes,
  secondsLeft,
  simulatorBanner,
  takesJobs,
  toneWords,
  type BoardRow,
  type DriverRow,
} from "../src/lib/connected/dispatch";
import { dispatchPreview } from "../src/lib/connected/dispatch-preview";
import { phase16Commands, phase16Queries } from "../src/lib/connected/proxy-allowlist";
import { hooks, remember, sampleLines, sign, simConfig, verify } from "../src/lib/server/partner-sim";
import type { Board } from "../src/lib/connected/dispatch";

const asOf = new Date().toISOString();
const fixtures = dispatchPreview(asOf);
const board = fixtures["delivery.board"]({}) as Board;
const drivers = (fixtures.drivers({}) as { rows: DriverRow[] }).rows;

test("countdowns and distances read plainly, and times always say estimate", () => {
  const now = Date.parse("2026-11-04T12:00:00Z");
  assert.equal(secondsLeft("2026-11-04T12:01:30Z", now), 90);
  assert.equal(secondsLeft("2026-11-04T11:59:00Z", now), 0);
  assert.equal(secondsLeft(null, now), 0);
  assert.equal(clock(90), "1:30");
  assert.equal(clock(5), "0:05");
  assert.equal(distanceText(1430), "1.4 km");
  assert.equal(distanceText(644), "640 m");
  assert.equal(distanceText(null), "");
  assert.equal(etaText(board.rows[0].eta), "About 6 min (estimate)");
  assert.equal(etaText(null), "No estimate");
});

test("only the café's own unassigned jobs can be offered, and only to drivers taking jobs", () => {
  const [waiting, partnerJob, onTheWay] = board.rows;
  assert.equal(canOffer(waiting), true);
  assert.equal(canOffer(onTheWay), false);
  assert.equal(canOffer({ ...partnerJob, fulfilledBy: "partner" } as BoardRow), false);
  assert.equal(canOffer({ ...waiting, orderStatus: "cancelled" }), false);
  assert.deepEqual(
    drivers.filter(takesJobs).map((d) => d.name),
    ["Amal (demo login)", "Sam · Sample", "Ines · Sample"],
  );
});

test("each job state has one pill word that reads back as the state", () => {
  for (const status of ["unassigned", "assigned", "collected", "outForDelivery", "delivered", "issue", "cancelled"]) {
    assert.notEqual(toneWords(jobTone(status)), "", status);
  }
  assert.equal(toneWords(jobTone("unassigned")), "Needs a driver");
  assert.equal(toneWords(jobTone("outForDelivery")), "On the way");
  assert.equal(new Set(["unassigned", "assigned", "collected", "outForDelivery"].map(jobTone)).size, 4);
});

test("the map shows the café, each door and each driver's last position", () => {
  const pins = mapPins(board, drivers, 14);
  assert.equal(pins.filter((p) => p.kind === "venue").length, 1);
  assert.equal(pins.filter((p) => p.kind === "job").length, 4);
  assert.deepEqual(
    pins.filter((p) => p.kind === "driver").map((p) => p.label),
    ["Ines · Sample · Scooter"],
  );
  assert.equal(pins.find((p) => p.id === "job-14")?.selected, true);
  const routes = mapRoutes(board, 14);
  assert.deepEqual(
    routes.map((r) => [r.id, r.tone]),
    [
      ["plan-14", "plan"],
      ["live-12", "live"],
    ],
  );
  assert.deepEqual(mapCenter(board), [40.7424, -74.006]);
  assert.deepEqual(mapCenter(undefined), [40.7424, -74.006]);
});

test("the section's calls use the allowlisted names", async () => {
  const sent: [string, string, unknown, unknown][] = [];
  const fake = {
    async query<T>(name: string, params?: unknown) {
      sent.push(["query", name, params, undefined]);
      return { rows: [] } as T;
    },
    async command<T>(name: string, _rid: number, data?: unknown, options?: unknown) {
      sent.push(["command", name, data, options]);
      return {} as T;
    },
  };
  const dx = dispatch(fake, 7);
  await dx.board();
  await dx.drivers();
  await dx.apps();
  await dx.events();
  await dx.offer(14, 2, "fixed-key");
  await dx.withdraw(41);
  await dx.suggest(14);
  await dx.availability(2, "available");
  await dx.saveDriver({ name: "Sam" });
  await dx.createApp({ name: "Demo" });
  await dx.rotateApp(3, 2, "key");
  for (const [kind, name] of sent) {
    const allowed = kind === "query" ? phase16Queries : phase16Commands;
    assert.ok(allowed.has(name) || name === "agent.inbox", `${name} is allowlisted`);
  }
  const offer = sent.find(([, name]) => name === "delivery.offer")!;
  assert.deepEqual(offer[2], { driverId: 2 });
  assert.deepEqual(offer[3], { id: 14, key: "fixed-key" });
  assert.deepEqual(sent.find(([, name]) => name === "delivery.respond")![2], { answer: "withdraw" });
});

test("partner errors read as next steps, and events as sentences", () => {
  assert.match(failText(Object.assign(new Error("x"), { code: "reauthentication_required" })), /Confirm it's you/);
  assert.match(failText(Object.assign(new Error("x"), { code: "not_configured" })), /not configured/);
  const events = (fixtures["partner.events"]({}) as { rows: Parameters<typeof eventText>[0][] }).rows;
  assert.equal(eventText(events[0]), "Signed webhook: order.accepted · sim-5f2a · delivered (HTTP 200)");
  assert.equal(eventText(events[1]), "Received: orders.create · sim-5f2a · accepted (HTTP 201)");
  assert.equal(simulatorBanner, "Simulator: a pretend outside delivery app. Not Uber Eats or Glovo.");
});

test("the simulator signs like Raysto and only keeps verified, fresh webhooks", () => {
  const secret = "whsec_fixture";
  const body = JSON.stringify({ id: "evt_9", type: "order.ready", ref: "sim-1", attempt: 1, data: { ref: "sim-1" } });
  const t = 1_800_000_000;
  const expected = createHmac("sha256", secret).update(`${t}.${body}`).digest("hex");
  assert.equal(sign(secret, t, body), expected);
  assert.equal(verify(secret, `t=${t},v1=${expected}`, body, t + 10), true);
  assert.equal(verify(secret, `t=${t},v1=${expected}`, body, t + 301), false);
  assert.equal(verify(secret, `t=${t},v1=${expected}`, `${body} `, t), false);
  assert.equal(verify("whsec_other", `t=${t},v1=${expected}`, body, t), false);
  assert.equal(verify(secret, null, body, t), false);
  const before = hooks.length;
  assert.equal(remember(body)?.type, "order.ready");
  assert.equal(remember(body)?.id, "evt_9");
  assert.equal(hooks.length, before + 1, "a retried event replaces its earlier copy");
  assert.equal(remember("not json"), null);
  assert.equal(remember(JSON.stringify({ type: "x" })), null);
});

test("the simulator needs its key, its secret and the café, from server settings only", () => {
  assert.equal(simConfig({}), null);
  assert.equal(simConfig({ RAYSTO_SIM_PARTNER_KEY: "rk_abcd2345_" + "x".repeat(30), RAYSTO_SIM_PARTNER_SECRET: "whsec_1", RAYSTO_SIM_RESTAURANT_ID: "0" }), null);
  assert.deepEqual(
    simConfig({ RAYSTO_SIM_PARTNER_KEY: "rk_abcd2345_" + "x".repeat(30), RAYSTO_SIM_PARTNER_SECRET: "whsec_1", NEXT_PUBLIC_RAYSTO_JUDGE_RESTAURANT_ID: "12" }),
    { key: "rk_abcd2345_" + "x".repeat(30), secret: "whsec_1", restaurantId: 12 },
  );
  assert.deepEqual(
    sampleLines([
      { productId: 1, available: true, modifiers: [{ min: 1 }] },
      { productId: 2, available: false },
      { productId: 3, available: true, modifiers: [{ min: 0 }] },
      { productId: 4 },
      { productId: 5 },
    ]),
    [
      { productId: 3, quantity: 2 },
      { productId: 4, quantity: 1 },
    ],
  );
});
