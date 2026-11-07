import { test } from "node:test";
import assert from "node:assert/strict";
import type { AgStudioApi } from "ag-studio";
import { stepLayoutHistory } from "../src/lib/connected/studio/history";

test("undo moves off a removed analytical page before restoring the durable layout", () => {
  let current = { pages: [{ id: "costing" }, { id: "decision" }], selectedPageId: "decision" };
  const calls: string[] = [];
  const api = {
    getHistory: () => ({ undo: [{ state: { pages: [{ id: "costing" }] } }], redo: [] }),
    getState: () => current,
    setState: (state: typeof current) => { calls.push("select"); current = state; },
    undo: () => { calls.push("undo"); assert.equal(current.selectedPageId, "costing"); },
  } as unknown as AgStudioApi;
  stepLayoutHistory(api, "undo");
  assert.deepEqual(calls, ["select", "undo"]);
});
test("redo on a surviving page leaves the current page and history intact", () => {
  const calls: string[] = [];
  const api = {
    getHistory: () => ({ redo: [{ state: { pages: [{ id: "costing" }, { id: "decision" }], selectedPageId: "decision" } }] }),
    getState: () => ({ pages: [{ id: "costing" }], selectedPageId: "costing" }),
    setState: () => calls.push("select"), redo: () => calls.push("redo"),
  } as unknown as AgStudioApi;
  stepLayoutHistory(api, "redo");
  assert.deepEqual(calls, ["redo"]);
});
