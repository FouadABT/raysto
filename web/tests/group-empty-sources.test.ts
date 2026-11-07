import { test } from "node:test";
import assert from "node:assert/strict";
import { groupStudioSources } from "../src/lib/connected/studio/group-sources";
import { groupPages } from "../src/lib/connected/studio/pages";

test("empty group sources retain the fields used by every Studio page without synthetic money rows", () => {
  const sources = groupStudioSources([], [], [], "USD");
  const fields = new Set(
    sources.flatMap((s) => (s.fields ?? []).map((f) => s.id + "." + f.id)),
  );
  assert(sources.every((s) => s.data.length === 0 && s.fields!.length > 0));
  for (const page of groupPages("USD", true).pages)
    for (const widget of Object.values(page.widgets ?? {}))
      for (const refs of Object.values(widget?.dataMapping ?? {}))
        for (const ref of refs as { id: string }[])
          assert(
            fields.has(ref.id),
            "Declared schema must support " +
              ref.id +
              " even when no rows exist",
          );
});
