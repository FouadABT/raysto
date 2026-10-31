import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  allowedPath,
  consoleCommands,
  consoleQueries,
} from "../src/lib/connected/proxy-allowlist";

const platform = join(
  __dirname,
  "../../backend/raysto/raysto_server/lib/src",
);
const read = (path: string) => readFileSync(join(platform, path), "utf8");
const names = (source: string, pattern: RegExp) =>
  new Set([...source.matchAll(pattern)].map((m) => m[1]));

test("every allowlisted command exists in the backend", () => {
  const commands = new Set([
    ...names(read("platform/platform.dart"), /^\s+'([A-Za-z.]+)': \w+Module\./gm),
    ...names(read("web/platform_routes.dart"), /^\s+case '([A-Za-z.]+)':/gm),
  ]);
  for (const name of consoleCommands)
    assert.ok(commands.has(name), `unknown backend command ${name}`);
});

test("every allowlisted query exists in the backend", () => {
  const source = read("platform/queries.dart");
  const queries = new Set([
    ...names(source, /^\s+case '([A-Za-z.]+)':/gm),
    ...names(source, /name == '([A-Za-z.]+)'/g),
  ]);
  for (const name of consoleQueries)
    assert.ok(queries.has(name), `unknown backend query ${name}`);
});

test("camel-case console commands pass and unlisted names do not", () => {
  assert.ok(allowedPath("commands/operations.archiveThread"));
  assert.ok(allowedPath("commands/identity.stepUp"));
  assert.ok(allowedPath("queries/orders"));
  assert.ok(allowedPath("rooms/12/events"));
  assert.ok(allowedPath("events"));
  assert.ok(!allowedPath("commands/admin.plan"));
  assert.ok(!allowedPath("commands/payment.refund/extra"));
  assert.ok(!allowedPath("queries/"));
  assert.ok(!allowedPath("rooms/0/events"));
  assert.ok(!allowedPath("webhooks/paypal-platform"));
});
