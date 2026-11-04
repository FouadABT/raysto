/**
 * The café's PayPal account (0.16, stream S6): what `merchant.status`
 * returns and how the console words it. Pure, so tests read it directly.
 *
 * Three ways money reaches PayPal, in the order the backend routes them:
 * the café's own PayPal app (keys pasted by the owner, Sandbox today), its
 * Connect with PayPal partner connection (needs PayPal's partner approval
 * for Raysto), and Raysto's shared Sandbox account for the demo cafés.
 */
import type { Json } from "./contracts";

export type PayPalMode = "ownApp" | "partner" | "sharedSandbox" | "none";
export type FeatureState = "enabled" | "notEnabled" | "keysRejected" | "unknown" | "unchecked";

export interface PayPalFeature {
  name: string;
  label: string;
  state: FeatureState;
}

export interface PayPalAccountStatus {
  restaurantId: number;
  environment: string;
  mode: PayPalMode;
  canEdit: boolean;
  keysStorable: boolean;
  stepUp: "mfa" | "recentAuth";
  ownApp: null | {
    status: string;
    clientIdEnd: string;
    merchantId: string | null;
    webhook: "pending" | "registered" | "failed" | string;
    checkedAt: string | null;
    updatedAt: string;
    version: number;
    features: PayPalFeature[];
  };
  partner: {
    available: boolean;
    status: string;
    merchantId: string | null;
    verifiedAt: string | null;
    note?: string;
  };
  shared: boolean;
}

export const modeLabel: Record<PayPalMode, string> = {
  ownApp: "Your own PayPal app",
  partner: "Connected with PayPal",
  sharedSandbox: "Raysto's shared Sandbox account",
  none: "Not connected",
};

export function modeLine(s: PayPalAccountStatus): string {
  const where = s.environment === "sandbox" ? "PayPal Sandbox" : "PayPal";
  switch (s.mode) {
    case "ownApp":
      return `Payments, refunds and payouts go through your own app on ${where}.`;
    case "partner":
      return `Payments go to your PayPal account through Raysto's partner connection on ${where}.`;
    case "sharedSandbox":
      return `This demo café uses Raysto's shared ${where} account. Connect your own app to use yours.`;
    default:
      return "This café cannot take PayPal payments yet. Connect a PayPal account below.";
  }
}

export const featureWord: Record<FeatureState, string> = {
  enabled: "On",
  notEnabled: "Not enabled in your PayPal app",
  keysRejected: "PayPal refused the keys",
  unknown: "Could not check",
  unchecked: "Not checked yet",
};

/** Features the owner must switch on in their PayPal app, with where. */
export function missingFeatures(s: PayPalAccountStatus): PayPalFeature[] {
  return (s.ownApp?.features ?? []).filter((f) => f.state === "notEnabled");
}

export const webhookWord = (state: string): string =>
  state === "registered"
    ? "PayPal tells Raysto about payments as they happen."
    : state === "failed"
      ? "Raysto could not add its webhook to your app; payments are checked when you open them. Check again to retry."
      : "Not set up yet.";

/** What the identity check asks for before keys change. */
export const stepUpNote = (s: PayPalAccountStatus): string =>
  s.stepUp === "mfa"
    ? "Saving or removing keys asks for your two-step sign-in (multi-factor) on this account."
    : "Saving or removing keys asks you to confirm your sign-in.";

/** The masked client id; the secret is never sent back, so never shown. */
export const maskedClient = (end: string): string => `••••${end}`;

/** Client IDs and secrets are 20–128 letters, digits, dashes or underscores. */
export const keyShape = /^[A-Za-z0-9_-]{20,128}$/;
export const merchantShape = /^[A-Z0-9]{10,16}$/;

export function keyProblems(clientId: string, secret: string, merchantId: string): string[] {
  const out: string[] = [];
  if (!keyShape.test(clientId.trim())) out.push("Paste the Client ID from your app's page on developer.paypal.com.");
  if (!keyShape.test(secret.trim())) out.push("Paste the Secret from the same page.");
  if (merchantId.trim() && !merchantShape.test(merchantId.trim().toUpperCase()))
    out.push("A PayPal merchant ID has 10 to 16 letters and digits, or leave it empty.");
  return out;
}

/** PayPal sends the seller back with these after Connect with PayPal. */
export const returnedFromPayPal = (search: string): boolean => {
  const q = new URLSearchParams(search);
  return q.has("merchantIdInPayPal") || q.has("permissionsGranted");
};

export const developerUrl = "https://developer.paypal.com/dashboard/applications/sandbox";

/** `?state=paypal` in the preview: a café on its own app with Invoicing off. */
export function paypalAccountPreview(state: string): Record<string, (p: Json) => unknown> {
  return {
    "merchant.status": (): PayPalAccountStatus => ({
      restaurantId: 1,
      environment: "sandbox",
      mode: state === "paypal" ? "ownApp" : "sharedSandbox",
      canEdit: true,
      keysStorable: true,
      stepUp: "mfa",
      ownApp:
        state === "paypal"
          ? {
              status: "ready",
              clientIdEnd: "Q7xZ",
              merchantId: "7XKQ2B9LMN3PA",
              webhook: "registered",
              checkedAt: new Date().toISOString(),
              updatedAt: new Date().toISOString(),
              version: 2,
              features: [
                { name: "orders", label: "Take payments (Orders)", state: "enabled" },
                { name: "refunds", label: "Refunds", state: "enabled" },
                { name: "payouts", label: "Payouts (bills, wages, tips, suppliers, drivers)", state: "enabled" },
                { name: "invoicing", label: "Invoicing (catering, payment requests)", state: "notEnabled" },
                { name: "transactionSearch", label: "Transaction Search (the daily close)", state: "enabled" },
                { name: "disputes", label: "Disputes", state: "enabled" },
              ],
            }
          : null,
      partner: {
        available: false,
        status: "notConnected",
        merchantId: null,
        verifiedAt: null,
        note: "Needs PayPal's partner approval for Raysto. Until then, use your own PayPal app.",
      },
      shared: true,
    }),
  };
}
