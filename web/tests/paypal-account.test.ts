import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  keyProblems,
  maskedClient,
  missingFeatures,
  modeLabel,
  modeLine,
  paypalAccountPreview,
  returnedFromPayPal,
  stepUpNote,
  type PayPalAccountStatus,
} from "../src/lib/connected/paypal-account";
import { allowedPath } from "../src/lib/connected/proxy-allowlist";

const own = paypalAccountPreview("paypal")["merchant.status"]({}) as PayPalAccountStatus;
const shared = paypalAccountPreview("")["merchant.status"]({}) as PayPalAccountStatus;

test("the four ways money can reach PayPal read plainly", () => {
  assert.equal(modeLabel[own.mode], "Your own PayPal app");
  assert.match(modeLine(own), /own app on PayPal Sandbox/);
  assert.match(modeLine(shared), /shared PayPal Sandbox account/);
  assert.match(modeLine({ ...shared, mode: "none" }), /cannot take PayPal payments yet/);
  assert.match(modeLine({ ...shared, mode: "partner" }), /partner connection/);
});

test("the checklist names what to switch on, and the partner path says it needs approval", () => {
  assert.deepEqual(
    missingFeatures(own).map((f) => f.name),
    ["invoicing"],
  );
  assert.equal(own.partner.available, false);
  assert.match(own.partner.note ?? "", /partner approval/);
  assert.match(stepUpNote(own), /two-step sign-in/);
  assert.match(stepUpNote({ ...own, stepUp: "recentAuth" }), /confirm your sign-in/);
});

test("the form checks the key shapes before PayPal does, and never shows the secret", () => {
  assert.deepEqual(keyProblems("A".repeat(40), "B".repeat(40), ""), []);
  assert.equal(keyProblems("short", "B".repeat(40), "").length, 1);
  assert.equal(keyProblems("A".repeat(40), "", "").length, 1);
  assert.equal(keyProblems("A".repeat(40), "B".repeat(40), "bad id!").length, 1);
  assert.deepEqual(keyProblems("A".repeat(40), "B".repeat(40), "7xkq2b9lmn3pa"), []);
  assert.equal(maskedClient("Q7xZ"), "••••Q7xZ");
  // The status shape has no field that could carry a secret or a token.
  const keys = JSON.stringify(own);
  assert.doesNotMatch(keys, /secret|token|webhookToken|access/i);
});

test("PayPal's return after Connect with PayPal is recognised", () => {
  assert.ok(returnedFromPayPal("?merchantIdInPayPal=ABC&permissionsGranted=true"));
  assert.ok(!returnedFromPayPal("?tab=paypal"));
});

test("the proxy relays the PayPal account names and nothing more", () => {
  for (const name of ["merchant.app.save", "merchant.app.check", "merchant.app.remove", "merchant.connect", "merchant.refresh"])
    assert.ok(allowedPath(`commands/${name}`), name);
  assert.ok(allowedPath("queries/merchant.status"));
  assert.ok(!allowedPath("webhooks/paypal-app/0123456789abcdef0123456789abcdef"));
});

test("the page never puts the pasted secret anywhere but the save command", () => {
  const page = readFileSync(join(__dirname, "../src/components/connected/paypal-account.tsx"), "utf8");
  // The secret field is a password field and is cleared after PayPal accepts it.
  assert.match(page, /type="password"/);
  assert.match(page, /setSecret\(""\)/);
  assert.doesNotMatch(page, /localStorage|sessionStorage|console\.log/);
});
