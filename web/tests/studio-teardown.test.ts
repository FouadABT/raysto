import { test } from "node:test";
import assert from "node:assert/strict";
import { createRequire } from "node:module";
const { patchBundle } = createRequire(import.meta.url)("../tool/patch-studio.cjs") as { patchBundle: (s: string) => string };
test("the pinned correction refuses unknown sources and is repeatable", () => {
  assert.throws(() => patchBundle("an incompatible upgraded package"), /pinned bundle/);
  const source = 'isBlockStillWanted(startRow, generation) {\n    if (generation !== this.refreshGeneration) {\nreturn false;\n}\n}\npollTimer = setInterval(() => {\n            if (this.isBlockStillWanted(startRow, generation)) {';
  const patched = patchBundle(source);
  assert.equal(patchBundle(patched), patched);
  assert.match(patched, /!this\.isAlive\(\) \|\| !this\.api/);
  assert.match(patched, /controller\.abort\("destroyed"\)/);
});
