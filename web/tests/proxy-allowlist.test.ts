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
  phase16Commands,
  phase16Queries,
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
// The 0.16 names are promised by docs/release-0.16-design.md in the same way.
const release16 = readFileSync(join(__dirname, "../../docs/release-0.16-design.md"), "utf8");
const listedIn = (doc: string, kind: "Commands" | "Queries") =>
  [...(doc.match(new RegExp(`^${kind}: (.*)$`, "m"))?.[1] ?? "").matchAll(/`([A-Za-z.]+)[^`]*`/g)].map((m) => m[1]);
const promised = (kind: "Commands" | "Queries") => new Set([...listedIn(design, kind), ...listedIn(release16, kind)]);
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
    ...names(read("platform/finance_decisions.dart"), /^\s+'([a-z]+(?:\.[a-zA-Z]+)+)':/gm),
    ...["finance_017", "judge_story_017"].flatMap(m => [...names(read(`platform/${m}.dart`).match(/commands\s*=\s*\{([\s\S]*?)\n  \};/)?.[1] ?? '', /'([A-Za-z.]+)':/g)]),
    ...names(read("web/platform_routes.dart"), /^\s+case '([A-Za-z.]+)':/gm),
  ]);
  const promisedCommands = promised("Commands");
  for (const name of consoleCommands)
    assert.ok(
      known(name, commands, promisedCommands, new Set([...backofficeCommands, ...phase16Commands])),
      `unknown backend command ${name}`,
    );
});

test("every allowlisted query exists in the backend or is promised by the design", () => {
  const source = read("platform/queries.dart");
  const queries = new Set([
    ...names(source, /^\s+case '([A-Za-z.]+)':/gm),
    ...names(source, /name == '([A-Za-z.]+)'/g),
    ...names(read("platform/finance_017.dart").match(/queryNames = \{([\s\S]*?)\};/)?.[1] ?? '', /'([A-Za-z.]+)'/g),
    ...names(read("platform/finance_decisions.dart").match(/queries = \{([\s\S]*?)\};/)?.[1] ?? '', /'([A-Za-z.]+)'/g),
    // Back-office queries (and the dashboard) are answered by BackOfficeModule.query.
    ...names(read("platform/backoffice.dart"), /^\s+case '([A-Za-z.]+)':/gm),
    // 0.16 queries are answered by their modules through the chained fallback.
    ...["group", "ledger", "accountant", "delivery", "partner", "purchasing", "studio_layout"].flatMap((m) => [
      ...names(read(`platform/${m}.dart`), /^\s+case '([A-Za-z.]+)':/gm),
    ]),
  ]);
  const promisedQueries = promised("Queries");
  for (const name of consoleQueries)
    assert.ok(
      known(name, queries, promisedQueries, new Set([...backofficeQueries, ...phase16Queries])),
      `unknown backend query ${name}`,
    );
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
  assert.ok(allowedPath("queries/dashboard"));
  assert.ok(allowedPath("commands/autonomy.set"));
  assert.ok(!allowedPath("commands/admin.plan"));
  assert.ok(!allowedPath("commands/payment.refund/extra"));
  assert.ok(!allowedPath("queries/"));
  assert.ok(!allowedPath("rooms/0/events"));
  assert.ok(!allowedPath("webhooks/paypal-platform"));
  assert.ok(!allowedPath("media/13/content"));
  assert.ok(!allowedPath("media/0"));
  // Uploads: the command is relayed; the bytes go through a separate,
  // size-capped PUT route, never through allowedPath.
  assert.ok(allowedPath("commands/media.upload"));
  assert.ok(allowedPath("queries/ledger.pnl"));
  assert.ok(allowedPath("commands/bill.pay"));
  assert.ok(!allowedPath("voice/counter/extra"));
});
