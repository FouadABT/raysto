import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { duration, easing } from "../src/lib/connected/motion";

// The console's Material tokens must match docs/design-tokens.json, the one
// source both the console and the Flutter app are written from.
const root = path.resolve(import.meta.dirname, "..", "..");
type Token = { $value: unknown };
type Group = { [name: string]: Token | Group | string };
const json = JSON.parse(readFileSync(path.join(root, "docs", "design-tokens.json"), "utf8"));
const css = readFileSync(path.join(root, "web", "src", "app", "md-sys.css"), "utf8");
const ops = readFileSync(path.join(root, "web", "src", "app", "ops", "operations.css"), "utf8");

const vars = new Map<string, string>();
for (const match of css.matchAll(/(--[a-z0-9-]+):\s*([^;]+);/g)) vars.set(match[1], match[2].trim());

const tokens = (group: Group) =>
  Object.entries(group).filter(([name, t]) => !name.startsWith("$") && typeof t === "object" && "$value" in t) as [string, Token][];

const bezier = (v: unknown) => `cubic-bezier(${(v as number[]).join(", ")})`;

test("every colour role in the source file is on :root with the same value", () => {
  for (const [name, t] of tokens(json.md.sys.color)) {
    assert.equal(vars.get(`--md-sys-color-${name}`)?.toLowerCase(), String(t.$value).toLowerCase(), name);
  }
  for (const [name, t] of tokens(json.raysto.sys.color)) {
    assert.equal(vars.get(`--raysto-sys-color-${name}`)?.toLowerCase(), String(t.$value).toLowerCase(), name);
  }
  for (const [name, t] of tokens(json.raysto.chart)) {
    assert.equal(vars.get(`--raysto-chart-${name}`)?.toLowerCase(), String(t.$value).toLowerCase(), `chart ${name}`);
  }
  assert.equal(Number(vars.get("--md-sys-scrim-opacity")), json.md.sys["scrim-opacity"].$value);
});

test("shape, state layers and elevation match", () => {
  for (const [name, t] of tokens(json.md.sys.shape)) assert.equal(vars.get(`--md-sys-shape-${name}`), t.$value, name);
  for (const [name, t] of tokens(json.md.sys.state)) assert.equal(Number(vars.get(`--md-sys-state-${name}`)), t.$value, name);
  for (const [name, t] of tokens(json.md.sys.elevation)) assert.equal(vars.get(`--md-sys-elevation-${name}`), t.$value, name);
  assert.equal(vars.get("--raysto-shape-card"), json.raysto.shape.card.$value);
});

test("motion easings and durations match in CSS and in motion.ts", () => {
  const camel = (s: string) => s.replace(/-([a-z])/g, (_, c: string) => c.toUpperCase());
  for (const [name, t] of tokens(json.md.sys.motion)) {
    const cssValue = vars.get(`--md-sys-motion-${name}`);
    if (name.startsWith("easing-")) {
      assert.equal(cssValue, bezier(t.$value), name);
      const key = camel(name.slice("easing-".length)) as keyof typeof easing;
      assert.deepEqual([...easing[key]], t.$value, `motion.ts ${key}`);
    } else {
      assert.equal(cssValue, t.$value, name);
      const key = name.slice("duration-".length) as keyof typeof duration;
      assert.equal(`${Math.round(duration[key] * 1000)}ms`, t.$value, `motion.ts ${key}`);
    }
  }
});

test("the console's old names are aliases now, and the one-off easing is gone", () => {
  const block = ops.slice(ops.indexOf(".ops-root {"), ops.indexOf("}", ops.indexOf(".ops-root {")));
  for (const name of ["--paper", "--surface", "--ink", "--forest", "--muted", "--lime", "--lime-ink", "--mint", "--peach", "--line", "--line-soft", "--ok", "--warn", "--late", "--radius"]) {
    const m = block.match(new RegExp(`${name}:\\s*([^;]+);`));
    assert.ok(m, `${name} is defined`);
    assert.match(m[1], /^var\(--(md-sys|raysto)-/, `${name} aliases a token`);
  }
  assert.doesNotMatch(ops, /var\(--ease\)|--ease:/);
  assert.equal(ops.match(/@keyframes ops-pulse/g)?.length, 1, "one ops-pulse");
});
