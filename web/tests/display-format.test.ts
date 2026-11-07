import { test } from "node:test";
import assert from "node:assert/strict";
import { currency } from "../src/lib/connected/contracts";
import { formatMoney, formatMoneyShort } from "../src/components/connected/m3/chart-math";

test("reusing currency formatters preserves native formatting for every supported currency", () => {
  for (const code of ["USD", "EUR", "GBP", "JPY"]) for (const minor of [0, 1, 99, 19530, -19530]) {
    assert.equal(currency(minor, code), new Intl.NumberFormat("en", { style: "currency", currency: code }).format(minor / 100));
    assert.equal(formatMoney(minor, code), new Intl.NumberFormat("en-US", { style: "currency", currency: code }).format(minor / 100));
  }
  assert.equal(formatMoneyShort(1953000), "$19.5K");
  assert.throws(() => currency(100, "invalid-currency"), RangeError);
});
