import { test } from "node:test";
import assert from "node:assert/strict";
import { allowedNext, dropReason, stageOf, stages, type BoardRole, type RuleOrder } from "../src/lib/connected/order-rules";

const order = (status: string, fulfillment = "pickup", extra: Partial<RuleOrder> = {}): RuleOrder => ({
  status,
  fulfillment,
  origin: "online",
  paymentStatus: "paid",
  pickupCode: null,
  ...extra,
});

// The server's forward table (ordering.dart, OrderingModule.transition).
const server: Record<string, Record<string, string | null>> = {
  pickup: { awaitingPayment: null, submitted: "accepted", accepted: "preparing", preparing: "ready", ready: "collected", outForDelivery: null, served: "completed", collected: "completed", delivered: "completed", completed: null, cancelled: null, rejected: null, expired: null },
  dineIn: { awaitingPayment: null, submitted: "accepted", accepted: "preparing", preparing: "ready", ready: "served", outForDelivery: null, served: "completed", collected: "completed", delivered: "completed", completed: null, cancelled: null, rejected: null, expired: null },
  delivery: { awaitingPayment: null, submitted: "accepted", accepted: "preparing", preparing: "ready", ready: null, outForDelivery: null, served: "completed", collected: "completed", delivered: "completed", completed: null, cancelled: null, rejected: null, expired: null },
};

test("every status and fulfilment offers exactly the server's next step to a manager", () => {
  for (const [fulfillment, table] of Object.entries(server)) {
    for (const [status, next] of Object.entries(table)) {
      const a = allowedNext(order(status, fulfillment), "manager");
      assert.equal(a.to, next, `${fulfillment} ${status}`);
      if (next) {
        assert.equal(a.stage, stageOf(next));
        assert.equal(a.reason, null);
        assert.ok(a.verb);
      } else {
        assert.equal(a.stage, null);
        assert.ok(a.reason, `${fulfillment} ${status} explains why`);
      }
    }
  }
});

test("counter sales follow the pickup table and never ask for a code", () => {
  for (const [status, next] of Object.entries(server.pickup)) {
    const a = allowedNext(order(status, "pickup", { origin: "counter", pickupCode: "0271" }), "owner");
    assert.equal(a.to, next, status);
    assert.equal(a.needsCode, false);
  }
});

test("an online pickup with a code is handed over against it", () => {
  const a = allowedNext(order("ready", "pickup", { pickupCode: "0271" }), "manager");
  assert.equal(a.to, "collected");
  assert.equal(a.needsCode, true);
  assert.equal(allowedNext(order("ready", "pickup"), "manager").needsCode, false);
});

test("only ready ticks the open kitchen lines first", () => {
  for (const status of Object.keys(server.pickup)) {
    assert.equal(allowedNext(order(status), "manager").autoTicks, status === "preparing", status);
  }
});

test("roles: the kitchen cooks, operators accept and hand over", () => {
  const roles: BoardRole[] = ["owner", "manager", "waiter", "kitchen"];
  const can = (status: string, role: BoardRole, fulfillment = "pickup") => allowedNext(order(status, fulfillment), role).to !== null;
  for (const role of roles) {
    assert.equal(can("submitted", role), role !== "kitchen", `accept ${role}`);
    assert.equal(can("accepted", role), role !== "waiter", `cook ${role}`);
    assert.equal(can("preparing", role), role !== "waiter", `ready ${role}`);
    assert.equal(can("ready", role, "dineIn"), role !== "kitchen", `serve ${role}`);
    assert.equal(can("collected", role), role !== "kitchen", `complete ${role}`);
  }
});

test("a refunded order is not taken into the kitchen; awaiting payment never moves by hand", () => {
  assert.equal(allowedNext(order("submitted", "pickup", { paymentStatus: "refunded" }), "manager").to, null);
  assert.match(allowedNext(order("awaitingPayment"), "owner").reason!, /PayPal/);
  assert.equal(stages.find((s) => s.id === "awaiting")!.drops, false);
});

test("delivery leaves ready only through the delivery flow", () => {
  assert.match(allowedNext(order("ready", "delivery"), "manager").reason!, /delivery flow/);
});

test("rejecting is never a board move", () => {
  for (const status of Object.keys(server.pickup)) {
    assert.notEqual(allowedNext(order(status), "manager").to, "rejected");
  }
});

test("only the next column accepts a drop, and every other column says why", () => {
  const o = order("accepted");
  for (const s of stages) {
    const why = dropReason(o, "manager", s.id);
    if (s.id === "preparing") assert.equal(why, null);
    else assert.ok(why, s.id);
  }
  assert.equal(dropReason(o, "manager", "accepted"), "Already here");
  assert.equal(dropReason(o, "manager", "ready"), "Next step: Preparing");
  assert.match(dropReason(order("ready", "delivery"), "manager", "handedOver")!, /delivery flow/);
});

test("columns: payment, kitchen, hand-over and done", () => {
  assert.equal(stageOf("awaitingPayment"), "awaiting");
  assert.equal(stageOf("submitted"), "new");
  assert.equal(stageOf("outForDelivery"), "handedOver");
  assert.equal(stageOf("served"), "handedOver");
  assert.equal(stageOf("completed"), "done");
  assert.equal(stageOf("cancelled"), "done");
});
