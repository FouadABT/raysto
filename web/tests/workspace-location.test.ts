import { strict as assert } from "node:assert";
import { test } from "node:test";
import { workspaceUrl } from "../src/lib/connected/workspace-location";

test("section navigation preserves entry context but removes another task selection", () => {
  assert.equal(
    workspaceUrl(
      "https://ops.rays.to/ops?judge=1&section=finance&tab=compare&product=72&comparison=90",
      { section: "supplies", tab: "bills" },
    ),
    "/ops?judge=1&section=supplies&tab=bills",
  );
});
test("a selected dish and comparison can be restored without encoding draft values", () => {
  assert.equal(
    workspaceUrl("/ops?section=finance&tab=compare", {
      product: 72,
      comparison: 90,
    }),
    "/ops?section=finance&tab=compare&product=72&comparison=90",
  );
  assert.equal(
    workspaceUrl("/ops?section=finance&comparison=90", {
      comparison: undefined,
    }),
    "/ops?section=finance",
  );
});
