import { test } from "node:test";
import assert from "node:assert/strict";
import { stagger } from "../src/lib/connected/motion";
import {
  arcPath,
  areaPath,
  countAt,
  delta,
  deltaLabel,
  donutSegments,
  formatMoney,
  formatMoneyShort,
  labelEvery,
  linePath,
  niceMax,
  progress,
  project,
  ticks,
} from "../src/components/connected/m3/chart-math";

test("stagger is 0.09 s per item and never more than 0.36 s", () => {
  assert.equal(stagger(0), 0);
  assert.equal(stagger(1), 0.09);
  assert.ok(Math.abs(stagger(3) - 0.27) < 1e-9);
  assert.equal(stagger(4), 0.36);
  assert.equal(stagger(40), 0.36);
  assert.equal(stagger(-2), 0);
  assert.equal(stagger(Number.NaN), 0);
});

test("a count lands exactly on the real value and never passes it", () => {
  assert.equal(countAt(0, 19530, 0), 0);
  assert.equal(countAt(0, 19530, 1), 19530);
  assert.equal(countAt(0, 19530, 1.2), 19530);
  for (let t = 0; t <= 1; t += 0.05) {
    const v = countAt(0, 19530, t);
    assert.ok(Number.isInteger(v), "whole minor units");
    assert.ok(v >= 0 && v <= 19530);
  }
  for (let t = 0; t <= 1; t += 0.05) {
    const v = countAt(8600, 2150, t);
    assert.ok(v <= 8600 && v >= 2150, "counting down stays between the two values");
  }
});

test("deltas: a change against the previous period, or 'new' when there was none", () => {
  assert.equal(delta(19530, 6200)?.toFixed(3), "2.150");
  assert.equal(delta(5, 0), null);
  assert.equal(deltaLabel(19530, 6200), "+215%");
  assert.equal(deltaLabel(2150, 8600), "−75%");
  assert.equal(deltaLabel(300, 0), "new");
  assert.equal(deltaLabel(0, 0), "0%");
  assert.equal(deltaLabel(100, 100), "0%");
});

test("money reads from minor units", () => {
  assert.equal(formatMoney(19530), "$195.30");
  assert.equal(formatMoneyShort(19530), "$195");
  assert.equal(formatMoneyShort(1953000), "$19.5K");
});

test("axis tops are tidy and ticks are even", () => {
  assert.equal(niceMax(0), 1);
  assert.equal(niceMax(8600), 10000);
  assert.equal(niceMax(19530), 20000);
  assert.equal(niceMax(61900), 100000);
  assert.equal(niceMax(2300), 2500);
  assert.deepEqual(ticks(8600), [0, 2500, 5000, 7500, 10000]);
});

test("points fill the box; zero sits on the baseline and the top on the top", () => {
  const pts = project([0, 5000, 10000], 200, 100, 10000);
  assert.deepEqual(pts, [
    [0, 100],
    [100, 50],
    [200, 0],
  ]);
  assert.deepEqual(project([7], 200, 100, 10), [[100, 30]], "one point is centred");
});

test("the smooth line never goes below the baseline or above the highest point", () => {
  const values = [0, 0, 1350, 4280, 3150, 8600, 2150];
  const pts = project(values, 600, 200);
  const d = linePath(pts);
  const ys = [...d.matchAll(/(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/g)].map((m) => Number(m[2]));
  const top = Math.min(...pts.map((p) => p[1]));
  for (const y of ys) {
    assert.ok(y <= 200 + 1e-6, `control point ${y} stays above the baseline`);
    assert.ok(y >= top - 1e-6, `control point ${y} stays below the highest point`);
  }
  assert.ok(d.startsWith("M0,200"));
  assert.ok(areaPath(pts, 200).endsWith("L600,200L0,200Z"));
  assert.equal(linePath([]), "");
});

test("donut segments share the turn and skip empty channels", () => {
  const segs = donutSegments([15100, 0, 3080, 1350]);
  assert.equal(segs.length, 3);
  assert.deepEqual(segs.map((s) => s.index), [0, 2, 3]);
  const shares = segs.reduce((n, s) => n + s.share, 0);
  assert.ok(Math.abs(shares - 1) < 1e-9);
  assert.ok(segs[0].start > 0 && segs[0].end < segs[1].start, "a gap between segments");
  assert.deepEqual(donutSegments([5]), [{ start: 0, end: 1, share: 1, index: 0 }]);
  assert.deepEqual(donutSegments([0, 0]), []);
  assert.match(arcPath(50, 50, 40, 0, 0.25), /^M50,10A40,40 0 0 1 90,50$/);
});

test("progress toward a target, and past it", () => {
  assert.deepEqual(progress(2150, 30000), { fraction: 2150 / 30000, over: false });
  assert.deepEqual(progress(45000, 30000), { fraction: 1, over: true });
  assert.deepEqual(progress(100, 0), { fraction: 0, over: false }, "no target, empty ring");
});

test("axis labels thin out but always keep the last", () => {
  const show = labelEvery(30, 7);
  const shown = Array.from({ length: 30 }, (_, i) => i).filter(show);
  assert.ok(shown.length <= 8);
  assert.ok(shown.includes(29));
  assert.ok(labelEvery(7, 7)(3));
});
