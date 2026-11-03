import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import {
  channelName,
  deltaChip,
  deltaSentence,
  firstName,
  greetingFor,
  isRange,
  kitchenTotal,
  localDate,
  localHour,
  noSales,
  previousShort,
  trend,
  zoneCity,
} from "../src/lib/connected/overview";
import type { Dashboard } from "../src/lib/connected/dashboard";

const fixture = (name: string) =>
  JSON.parse(readFileSync(path.join(__dirname, "..", "..", "docs", "fixtures", name), "utf8")) as Dashboard;

test("the greeting follows the café's own hour, not the browser's", () => {
  // 18:30 UTC is 13:30 in New York and 03:30 the next day in Tokyo.
  const at = new Date("2026-11-03T18:30:00Z");
  assert.equal(localHour(at, "America/New_York"), 13);
  assert.equal(greetingFor(at, "America/New_York"), "Good afternoon");
  assert.equal(greetingFor(at, "Asia/Tokyo"), "Good evening");
  assert.equal(greetingFor(new Date("2026-11-03T14:00:00Z"), "America/New_York"), "Good morning");
  assert.equal(greetingFor(new Date("2026-11-03T23:00:00Z"), "America/New_York"), "Good evening");
  assert.equal(localDate(at, "America/New_York"), "Tuesday 3 November");
  assert.equal(zoneCity("America/New_York"), "New York");
});

test("the name greeted is the first name, the email's start, or 'judge' in the judges' café", () => {
  assert.equal(firstName("Fouad Abt", "x@y.z"), "Fouad");
  assert.equal(firstName(null, "nadia.r@cafe.example"), "Nadia");
  assert.equal(firstName("", ""), "");
  assert.equal(firstName("Hackathon judge", "judge@rays.to", true), "judge");
});

test("comparisons read as numbers on the chip and as words for screen readers", () => {
  assert.deepEqual(trend(19530, 6200), { kind: "up", percent: 215 });
  assert.equal(deltaChip(19530, 6200), "+215%");
  assert.equal(deltaSentence(19530, 6200, "7d"), "up 215% on the previous 7 days");
  assert.equal(deltaChip(700, 1000), "−30%");
  assert.equal(deltaSentence(700, 1000, "today"), "down 30% on yesterday at this time");
  assert.equal(deltaChip(300, 0), "New");
  assert.equal(deltaSentence(300, 0, "30d"), "new: nothing in the previous 30 days");
  assert.equal(deltaChip(0, 0), "—");
  assert.equal(deltaChip(1001, 1000), "Same");
  assert.equal(previousShort("7d"), "vs previous 7 days");
});

test("the kitchen total counts new, accepted, preparing and ready orders", () => {
  const d = fixture("dashboard-7d.json");
  assert.equal(kitchenTotal(d.kitchen), 4);
  assert.equal(kitchenTotal({ submitted: 0, accepted: 0, preparing: 0, ready: 0, oldestMinutes: 0 }), 0);
});

test("a window without a paid order is recognised, and the fixtures are not empty", () => {
  const week = fixture("dashboard-7d.json");
  assert.equal(noSales(week), false);
  assert.equal(noSales(fixture("dashboard-today.json")), false);
  assert.equal(
    noSales({
      kpis: { ...week.kpis, orders: { value: 0, previous: 3, series: [] } },
      points: week.points.map((p) => ({ ...p, salesMinor: 0, orders: 0 })),
    }),
    true,
  );
});

test("the sample is never part of the figures the Overview shows", () => {
  const week = fixture("dashboard-7d.json");
  assert.ok(week.sample, "the 7-day fixture carries a sample");
  const real = week.points.reduce((n, p) => n + p.salesMinor, 0);
  assert.equal(week.kpis.sales.value, real);
  assert.notEqual(week.kpis.sales.value, week.sample!.points.reduce((n, p) => n + p.salesMinor, 0));
  assert.equal(fixture("dashboard-today.json").sample, null);
});

test("channel names and ranges", () => {
  assert.equal(channelName("pickup"), "Pickup");
  assert.equal(channelName("dineIn"), "Dine-in");
  assert.equal(channelName("catering"), "Catering");
  assert.ok(isRange("today") && isRange("30d") && !isRange("1y"));
});
