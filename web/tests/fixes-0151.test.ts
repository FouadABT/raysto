import { test } from "node:test";
import assert from "node:assert/strict";
import type { PayoutBatch } from "../src/lib/connected/backoffice";
import { heldOf, payoutFor } from "../src/lib/connected/money-view";
import { closeSourceChip, outcomeTone, sourceLabel, toolChips } from "../src/lib/connected/try-chips";

const batch = (over: Partial<PayoutBatch> = {}): PayoutBatch =>
  ({
    id: 7,
    kind: "wages",
    periodFrom: "2026-10-27T00:00:00.000Z",
    periodTo: "2026-11-03T00:00:00.000Z",
    totalMinor: 54400,
    currency: "USD",
    state: "proposed",
    createdAt: "2026-11-03T23:35:51.000Z",
    items: [{ recipientName: "Omar", amountMinor: 28800, state: "proposed" }],
    ...over,
  }) as PayoutBatch;

test("a payout list row without lines names nobody instead of crashing", () => {
  const bare = { ...batch(), items: undefined } as unknown as PayoutBatch;
  assert.equal(payoutFor("Omar", [bare]), undefined);
  assert.deepEqual(payoutFor("omar", [bare, batch()]), {
    state: "proposed",
    amountMinor: 28800,
    currency: "USD",
    kind: "wages",
  });
});

test("people held for a missing PayPal email are read from the batch summary", () => {
  const withHeld = { ...batch(), summary: { held: [{ recipientName: "Lina", amountMinor: 35200, minutes: 960, reason: "No PayPal email: add one to pay." }] } };
  assert.deepEqual(heldOf(withHeld), [
    { recipientName: "Lina", amountMinor: 35200, minutes: 960, reason: "No PayPal email: add one to pay." },
  ]);
  assert.deepEqual(heldOf(batch()), []);
  assert.deepEqual(heldOf({ summary: { held: "nonsense" } }), []);
});

test("PayPal is named only when PayPal answered, and how", () => {
  assert.equal(sourceLabel("paypal_mcp"), "asked PayPal via MCP");
  assert.equal(sourceLabel("raysto_ledger"), "PayPal webhook ledger (Transaction Search pending)");
  assert.equal(sourceLabel(undefined), undefined);
  assert.deepEqual(
    toolChips([
      { tool: "read_ledger", status: "completed" },
      { tool: "read_paypal", status: "completed", source: "paypal_mcp", transport: "stdio" },
      { tool: "read_paypal", status: "completed", source: "paypal_mcp" },
      { tool: "propose_fix", status: "completed" },
      { model: "gemini", ms: 10 },
    ]),
    ["used read_ledger", "asked PayPal via MCP", "used propose_fix"],
  );
  // A tool whose name mentions PayPal but that read Raysto's own ledger is not "PayPal via MCP".
  assert.deepEqual(toolChips([{ tool: "read_paypal_day", source: "raysto_ledger" }]), [
    "PayPal webhook ledger (Transaction Search pending)",
  ]);
  assert.deepEqual(toolChips("not a trace"), []);
});

test("the close says where it read PayPal's day from", () => {
  assert.equal(closeSourceChip({ source: "raysto_ledger", summary: {} }), "PayPal webhook ledger (Transaction Search pending)");
  assert.equal(closeSourceChip({ source: "paypal_transactions", summary: { via: "paypal_mcp" } }), "read PayPal's transaction list via MCP");
  assert.equal(closeSourceChip({ source: "paypal_transactions", summary: { via: "paypal_rest" } }), "read PayPal's transaction list (REST)");
  assert.equal(closeSourceChip(undefined), "PayPal source not recorded");
});

test("only an executed approval is done; a refusal never looks like one", () => {
  assert.equal(outcomeTone("executed"), "done");
  assert.equal(outcomeTone("rejected"), "refused");
  assert.equal(outcomeTone("failed", { error: "provider_feature_disabled" }), "refused");
  assert.equal(outcomeTone("failed", { error: "provider_unavailable" }), "failed");
  assert.equal(outcomeTone("expired"), "expired");
  assert.equal(outcomeTone("stale"), "expired");
});
