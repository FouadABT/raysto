import { test } from "node:test";
import assert from "node:assert/strict";
import { PendingMoves, sendMove, type OrderApi, type PendingMove } from "../src/lib/connected/pending-moves";
import type { Json } from "../src/lib/connected/contracts";

/** A clock the test moves by hand. */
function clock() {
  let now = 0;
  let seq = 0;
  const timers = new Map<number, { at: number; fn: () => void }>();
  return {
    setTimer: (fn: () => void, ms: number) => {
      const id = ++seq;
      timers.set(id, { at: now + ms, fn });
      return id;
    },
    clearTimer: (id: unknown) => void timers.delete(id as number),
    async advance(ms: number) {
      now += ms;
      for (const [id, t] of [...timers]) {
        if (t.at <= now) {
          timers.delete(id);
          t.fn();
        }
      }
      await new Promise((r) => setImmediate(r));
    },
    get pending() {
      return timers.size;
    },
  };
}

function harness(fail?: Error) {
  const c = clock();
  const sent: PendingMove[] = [];
  const failed: [PendingMove, unknown][] = [];
  const moves = new PendingMoves({
    graceMs: 5000,
    setTimer: c.setTimer,
    clearTimer: c.clearTimer,
    send: async (m) => {
      if (fail) throw fail;
      sent.push(m);
    },
    onFailed: (m, e) => failed.push([m, e]),
  });
  return { c, sent, failed, moves };
}

const order = { id: 14, version: 3, status: "preparing" };

test("a move is sent after the 5 second grace period, not before", async () => {
  const { c, sent, moves } = harness();
  moves.schedule(order, "ready");
  await c.advance(4999);
  assert.equal(sent.length, 0);
  assert.ok(moves.has(14));
  await c.advance(1);
  assert.deepEqual(sent, [{ orderId: 14, from: "preparing", expectedVersion: 3, steps: ["ready"] }]);
  assert.equal(moves.has(14), false);
});

test("Undo sends nothing and reports the move it cancelled", async () => {
  const { c, sent, moves } = harness();
  moves.schedule(order, "ready");
  await c.advance(2000);
  assert.equal(moves.undo(14)?.steps[0], "ready");
  await c.advance(10000);
  assert.equal(sent.length, 0);
  assert.equal(moves.undo(14), null);
});

test("flush sends every waiting move at once", async () => {
  const { c, sent, moves } = harness();
  moves.schedule(order, "ready");
  moves.schedule({ id: 15, version: 1, status: "submitted" }, "accepted");
  await moves.flush();
  assert.deepEqual(sent.map((m) => m.orderId).sort(), [14, 15]);
  assert.equal(c.pending, 0);
  assert.equal(moves.size, 0);
});

test("a second move of the same card joins the first: one send, both steps, the first version", async () => {
  const { c, sent, moves } = harness();
  moves.schedule({ id: 9, version: 7, status: "submitted" }, "accepted");
  await c.advance(3000);
  moves.schedule({ id: 9, version: 7, status: "accepted" }, "preparing");
  await c.advance(3000);
  assert.equal(sent.length, 0, "the grace period started again");
  await c.advance(2000);
  assert.deepEqual(sent, [{ orderId: 9, from: "submitted", expectedVersion: 7, steps: ["accepted", "preparing"] }]);
});

test("a refused move is reported, and nothing stays pending", async () => {
  const conflict = Object.assign(new Error("The order changed."), { code: "version_conflict" });
  const { c, failed, moves } = harness(conflict);
  moves.schedule(order, "ready");
  await c.advance(5000);
  assert.equal(failed.length, 1);
  assert.equal(failed[0][1], conflict);
  assert.equal(moves.size, 0);
});

test("overlay shows the waiting status; a row the server changed meanwhile stays as the server says", () => {
  const { moves } = harness();
  moves.schedule(order, "ready");
  const rows = [
    { id: 14, version: 3, status: "preparing" },
    { id: 15, version: 2, status: "submitted" },
  ];
  assert.deepEqual(moves.overlay(rows).map((r) => r.status), ["ready", "submitted"]);
  assert.equal(moves.overlay([{ id: 14, version: 4, status: "cancelled" }])[0].status, "cancelled");
});

test("sending ticks the open lines before ready, then each step with the version the last returned", async () => {
  const calls: [string, Json, { id?: number; version?: number }][] = [];
  let version = 3;
  const api: OrderApi = {
    async query<T>(name: string) {
      assert.equal(name, "kitchen");
      return {
        rows: [
          { id: 14, tickets: [
            { lineKey: "l0", quantity: 2, completedQuantity: 2, version: 1 },
            { lineKey: "l1", quantity: 1, completedQuantity: 0, version: 5 },
          ] },
        ],
      } as T;
    },
    async command<T>(name: string, _tenant: number, data: Json = {}, options: { id?: number; version?: number } = {}) {
      calls.push([name, data, options]);
      if (name === "order.transition") version += 1;
      return { version } as T;
    },
  };
  await sendMove(api, 5, { orderId: 14, from: "accepted", expectedVersion: 3, steps: ["preparing", "ready"] });
  assert.deepEqual(calls, [
    ["order.transition", { status: "preparing" }, { id: 14, version: 3 }],
    ["kitchen.progress", { lineKey: "l1", completedQuantity: 1 }, { id: 14, version: 5 }],
    ["order.transition", { status: "ready" }, { id: 14, version: 4 }],
  ]);
});
