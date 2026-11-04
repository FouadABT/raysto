// One set of numbers: docs/facts.json is the source, and the README, the
// Devpost text, the reviewer guide and the judges' page must state the same.
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { evidence } from "../src/lib/connected/judge";

const root = join(__dirname, "..", "..");
const read = (rel: string) => readFileSync(join(root, rel), "utf8");
const facts = JSON.parse(read("docs/facts.json"));
const pages = ["README.md", "docs/devpost-submission.md", "docs/reviewer-guide.md"];

const words: Record<string, number> = {
  one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9, ten: 10,
  eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15, sixteen: 16, twenty: 20,
};
const asNumber = (s: string) => (/^\d+$/.test(s) ? Number(s) : words[s.toLowerCase()]);

/** Every "<number> <noun>" claim in a page, e.g. "Eleven captures" or "4 refunds". */
function counts(text: string, noun: string): number[] {
  const out: number[] = [];
  for (const m of text.matchAll(new RegExp(`\\b(\\w+)\\s+${noun}\\b`, "gi"))) {
    const n = asNumber(m[1]);
    if (n !== undefined) out.push(n);
  }
  return out;
}

test("the judges' page constants are the facts", () => {
  assert.equal(evidence.captures, facts.paypal.captures.count);
  assert.equal(evidence.refunds, facts.paypal.refunds.count);
  assert.equal(evidence.payoutBatches, facts.paypal.payoutBatches.count);
  assert.equal(evidence.backendUnit, facts.tests.backendUnit);
  assert.equal(evidence.backendIntegration, facts.tests.backendIntegration);
  assert.equal(evidence.startedOn, facts.startedOn);
  assert.equal(evidence.firstCommit, facts.firstCommit);
  const page = read("web/src/components/judges/judges-page.tsx");
  assert.match(page, /evidence\.captures/);
  assert.match(page, /evidence\.backendIntegration/);
  assert.doesNotMatch(page, /<strong>(9|151)<\/strong>/, "the evidence strip states its numbers through `evidence`");
});

test("the facts agree with themselves", () => {
  for (const kind of ["captures", "refunds", "payoutBatches"] as const) {
    const f = facts.paypal[kind];
    assert.equal(f.ids.length, f.count, kind);
    assert.equal(new Set(f.ids).size, f.count, `${kind} ids are distinct`);
    assert.equal(asNumber(f.words), f.count, `${kind} in words`);
  }
});

for (const page of pages) {
  test(`${page} states the same numbers`, () => {
    const text = read(page);
    for (const n of counts(text, "captures")) assert.equal(n, facts.paypal.captures.count, "captures");
    for (const n of counts(text, "refunds")) assert.equal(n, facts.paypal.refunds.count, "refunds");
    for (const n of counts(text, "Payouts batches")) assert.equal(n, facts.paypal.payoutBatches.count, "Payouts batches");
    for (const m of text.matchAll(/backend (\d+) unit tests and (\d+) integration tests/g)) {
      assert.equal(Number(m[1]), facts.tests.backendUnit, "backend unit tests");
      assert.equal(Number(m[2]), facts.tests.backendIntegration, "backend integration tests");
    }
    for (const m of text.matchAll(/console (\d+) unit tests/g)) assert.equal(Number(m[1]), facts.tests.consoleUnit, "console unit tests");
    for (const m of text.matchAll(/(\d+) browser tests/g)) assert.equal(Number(m[1]), facts.tests.consoleBrowser, "browser tests");
    for (const m of text.matchAll(/app (\d+) widget tests/g)) assert.equal(Number(m[1]), facts.tests.app, "app widget tests");
    for (const m of text.matchAll(/(?:APK is|[Bb]uild is|served build is) (\d+\.\d+\.\d+)/g))
      assert.equal(m[1], facts.versions.apk, "APK version");
    for (const m of text.matchAll(/started on (\d{1,2} \w+ \d{4})/g)) assert.equal(m[1], facts.startedOn, "start date");
    for (const m of text.matchAll(/first commit \((\d{1,2} \w+)\)/gi))
      assert.ok(facts.firstCommit.startsWith(m[1]), `first commit ${m[1]}`);
  });
}

test("no page still states a retired number", () => {
  for (const page of pages) {
    const text = read(page);
    assert.doesNotMatch(text, /\b(Ten|Nine) captures\b/, page);
    assert.doesNotMatch(text, /\b0\.14\.2\b/, `${page} names the old APK`);
  }
});
