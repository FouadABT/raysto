import { test } from "node:test";
import assert from "node:assert/strict";
import { ReadSnapshots, clearOverviewSnapshots, overviewSnapshots } from "../src/lib/connected/read-snapshots";
import { asyncState } from "../src/components/connected/m3/async-region";
import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { CountUp } from "../src/components/connected/m3/count-up";

test("retained reads expire and retain only twelve distinct filters", () => {
  let now = 0;
  const cache = new ReadSnapshots(() => now);
  cache.put("USD:7d", { sales: 19530 });
  assert.deepEqual(cache.get("USD:7d"), { sales: 19530 });
  assert.equal(cache.get("EUR:7d"), undefined);
  now = 120000;
  assert.equal(cache.get("USD:7d"), undefined);
  for (let n = 0; n < 13; n++) cache.put(String(n), n);
  assert.equal(cache.get("0"), undefined);
  assert.equal(cache.get("1"), 1);
  assert.equal(cache.get("12"), 12);
});
test("identity scopes never share retained records and end notifications clear consumers", () => {
  const owner = {}, next = {};
  const cache = overviewSnapshots(owner), events: boolean[] = [];
  cache.put("1:USD:7d", { sales: 19530 });
  assert.equal(overviewSnapshots(next).get("1:USD:7d"), undefined);
  assert.equal(cache.get("2:USD:7d"), undefined);
  const stop = cache.subscribe(ended => events.push(ended));
  const epoch = cache.epoch;
  clearOverviewSnapshots(owner, true);
  assert.equal(cache.get("1:USD:7d"), undefined);
  assert.ok(cache.epoch > epoch, "late responses retain their obsolete epoch");
  assert.deepEqual(events, [true]);
  stop();
});
test("mutation invalidation requests revalidation without pretending identity ended", () => {
  const cache = new ReadSnapshots(), events: boolean[] = [];
  cache.subscribe(ended => events.push(ended));
  cache.put("1:dashboard", { value: 100 });
  cache.clear();
  assert.deepEqual(events, [false]);
  assert.equal(cache.get("1:dashboard"), undefined);
});
test("loading, empty, unavailable and retained stale data remain distinct", () => {
  assert.equal(asyncState(true, undefined), "initial");
  assert.equal(asyncState(false, undefined, "failed"), "unavailable");
  assert.equal(asyncState(true, { total: 0 }), "refreshing");
  assert.equal(asyncState(false, [], undefined, true), "empty");
  assert.equal(asyncState(false, { total: 0 }, "failed"), "stale");
  assert.equal(asyncState(false, { total: 0 }), "ready");
});
test("the first available financial amount renders exactly instead of starting at zero", () => {
  const html = renderToStaticMarkup(createElement(CountUp, { value: 19530, format: n => `$${(n / 100).toFixed(2)}` }));
  assert.match(html, /m3-count-live[^>]*>\$195\.30</);
  assert.doesNotMatch(html, /m3-count-live[^>]*>\$0\.00</);
});
