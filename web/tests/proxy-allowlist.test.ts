import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  allowedPath,
  backofficeCommands,
  backofficeQueries,
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

// The back-office names are promised by docs/back-office-design.md §3; until
// the backend ships them they are accepted only when that section lists them.
const design = readFileSync(join(__dirname, "../../docs/back-office-design.md"), "utf8");
const promised = (kind: "Commands" | "Queries") =>
  new Set(
    [...(design.match(new RegExp(`^${kind}: (.*)$`, "m"))?.[1] ?? "").matchAll(/`([A-Za-z.]+)[^`]*`/g)].map((m) => m[1]),
  );
const pending: string[] = [];
const known = (name: string, backend: Set<string>, promisedSet: Set<string>, listed: Set<string>) => {
  if (backend.has(name)) return true;
  if (listed.has(name) && promisedSet.has(name)) {
    pending.push(name);
    return true;
  }
  return false;
};

test("every allowlisted command exists in the backend or is promised by the design", () => {
  const commands = new Set([
    ...names(read("platform/platform.dart"), /^\s+'([A-Za-z.]+)': [A-Z]\w+\.\w+,/gm),
    ...names(read("web/platform_routes.dart"), /^\s+case '([A-Za-z.]+)':/gm),
  ]);
  const promisedCommands = promised("Commands");
  for (const name of consoleCommands)
    assert.ok(known(name, commands, promisedCommands, backofficeCommands), `unknown backend command ${name}`);
});

test("every allowlisted query exists in the backend or is promised by the design", () => {
  const source = read("platform/queries.dart");
  const queries = new Set([
    ...names(source, /^\s+case '([A-Za-z.]+)':/gm),
    ...names(source, /name == '([A-Za-z.]+)'/g),
  ]);
  const promisedQueries = promised("Queries");
  for (const name of consoleQueries)
    assert.ok(known(name, queries, promisedQueries, backofficeQueries), `unknown backend query ${name}`);
  if (pending.length) console.log(`back-office names not yet in the backend: ${pending.join(", ")}`);
});

test("camel-case console commands pass and unlisted names do not", () => {
  assert.ok(allowedPath("commands/operations.archiveThread"));
  assert.ok(allowedPath("commands/identity.stepUp"));
  assert.ok(allowedPath("queries/orders"));
  assert.ok(allowedPath("rooms/12/events"));
  assert.ok(allowedPath("events"));
  assert.ok(allowedPath("voice/counter"));
  assert.ok(allowedPath("media/13"));
  assert.ok(allowedPath("commands/menu.snap"));
  assert.ok(allowedPath("commands/payment.check"));
  assert.ok(!allowedPath("commands/admin.plan"));
  assert.ok(!allowedPath("commands/payment.refund/extra"));
  assert.ok(!allowedPath("queries/"));
  assert.ok(!allowedPath("rooms/0/events"));
  assert.ok(!allowedPath("webhooks/paypal-platform"));
  assert.ok(!allowedPath("media/13/content"));
  assert.ok(!allowedPath("media/0"));
  assert.ok(!allowedPath("commands/media.upload"));
  assert.ok(!allowedPath("voice/counter/extra"));
});
