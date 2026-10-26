# Reusable mobile PayPal core — 0.6.0+9

For the newer actual USD1 checkout, deployed backend and 0.7.0 APK, see [real Sandbox phone test](paypal-real-sandbox-test.md). This document records the earlier foundation checkpoint.

This phase adds a reusable Flutter payment coordinator, concrete adapters for the existing authenticated Serverpod commerce API, reusable payment presentation, a local test lab and Android HTTPS return routing. Restaurant, basket and staff business flows remain separate work. No demo order was converted into a live order and no new provider payment was created during this implementation.

## Contracts and reuse

Import `lib/payments/payments.dart` for the model and controller API. The core does not import restaurant models, Firebase, the generated client or browser/storage plugins. Its ports are:

| Port | Responsibility |
| --- | --- |
| `PaymentBackend` | Read an authorized order, prepare its checkout, complete/reconcile it |
| `PaymentStore` | Save one pending checkout privately for a particular account |
| `PaymentBrowser` | Open a previously validated approval URL |
| `PayPalLinkPolicy` | Enforce PayPal Sandbox approval and expected callback URLs |

`PaymentAmount` uses integer minor units and explicitly supports the current two-decimal currencies USD/EUR/GBP/CAD/AUD/CHF. Unsupported currencies, invalid references, changed amounts/currencies and mismatched provider data fail closed. Extend currency handling deliberately before introducing currencies with different minor-unit rules.

`payment_adapters.dart` supplies `ServerpodPaymentBackend`, `SecurePaymentStore` and `ExternalPaymentBrowser`. The Serverpod adapter maps real own-order/checkout/capture endpoints to the core, verifies ownership again on returned order records and exposes sanitized problem types. It never accepts an amount from the mobile UI. The existing backend owns frozen totals, authorization, stable provider request IDs, capture validation and webhook reconciliation.

Typical consumer sequence:

```dart
await payments.connect(backendUserId);
await payments.prepare(existingOrderId.toString());
await payments.openApproval();
// On return/resume: read status; callbacks never assert settlement.
await payments.refresh();
// Explicit action after the buyer returns:
await payments.complete();
// On logout/account change, immediately invalidate in-flight UI work:
payments.disconnect();
```

`LiveRuntime.payments` wires these ports once. `PaymentPanel` can be reused without restaurant UI. Consumers observe immutable snapshots with idle/restoring/preparing/ready/away/checking/completing/paid/paused/needs-attention phases. Only a matching authenticated backend order can produce `paid`.

## Recovery and safety behavior

- Persist the order reference and frozen amount **before** calling checkout creation. A lost response can resume that same order through the server's idempotency key.
- Save the provider order/approval URL before opening the system browser. No PayPal password, Client Secret, access token, card information or server credential is stored in the mobile module.
- Secure-storage keys scope recovery to both backend URL and backend account. Logout immediately hides checkout state and rejects late responses. The original account retains its encrypted recovery reference for a later sign-in; another account cannot see it.
- Serialize storage writes and payment operations; duplicate taps cannot create parallel client operations. A server request already sent before logout may still settle and must be reconciled when its owner returns.
- Fail closed if recovery storage is unreadable. Do not overwrite an unknown saved checkout with a new one. Explicit recovery or removing the local reference is required first.
- Treat network/capture timeouts as **uncertain**, preserving recovery. Read backend status first; explicit completion retries use the same order. Neither retry nor process recreation manufactures a receipt.
- A valid return must match the saved provider token and expected origin/path; reject foreign origins/ports, duplicate tokens, fragments and mismatches. Only HTTPS Sandbox approval links for the same provider order are opened.
- Cancellation pauses checkout. Removing the saved reference affects only device recovery; it never cancels/refunds a provider or business order. A settlement already received by webhook wins over stale cancel/return hints.
- Account restoration and app resume read status without automatically capturing a payment.

## Test APK entry points

- **Welcome → Payment test lab**, or **Profile → Payment test lab**: no Firebase login, published restaurant or SQL order is required. The banner explicitly identifies a local simulation; these ports never call PayPal or AWS.
- In the lab, prepare the USD 1.00 fixture, simulate opening PayPal, simulate buyer approval/return, then check and complete. Try a cancellation return, offline status, a lost capture response, controller recreation and reset. Controller recreation uses retained memory, not a claim of real process-persistence acceptance.
- **Use my Raysto account → PayPal Sandbox**: verified connected accounts can select their existing unpaid backend orders. This uses real Serverpod endpoints and PayPal Sandbox approval in the external browser. With no connected orders, it shows an honest empty state and access to the local lab. The existing illustrative restaurant checkout remains unchanged.

## Android return configuration

The existing Flutter deep-link handler remains enabled. The app now handles HTTPS paths `/payments/return` and `/payments/cancel` on `api.rays.to`, with cold-start and warm-route handling before demo onboarding gates. Return routes go through connected authentication and the saved-owner/provider checks.

Published `https://api.rays.to/.well-known/assetlinks.json` for `com.gmrt.raysto` and the existing development-signing SHA-256 `3482EDF88871F139F190FE05DC7F80276127E5B9A1EECF1F03010C64A7D98EFC`. Public JSON content and health returned HTTP 200. Only Raysto's exact Nginx location was added; a successful syntax check preceded a graceful reload. The Nginx master and Awhar process/configuration were preserved by that operation. The fresh Awhar baseline was PID 2320581, start 25 October 2026 04:52 UTC; earlier report PIDs are historical.

Android still controls verified-link behavior on each device; user link preferences can require a manual return to Raysto. Resuming and checking status supports that fallback. Register the actual Play signing certificate before store distribution. iOS Universal Links, entitlements, signing and APNs/native acceptance still require the Mac workflow; this phase does not claim them.

## Verification

- **53 distinct focused checks passed** across payment core/UI, return routing, existing backend-session/notification/account UI and navigation tests. This includes lost responses, process-style restoration, storage failure, changed amounts, malicious URLs, cancellation, duplicate taps and logout/account races.
- **11 additional existing mobile/account journey checks passed**. A 17-test follow-up also repeated the four payment UI and two return-route checks after the Profile shortcut/reset addition.
- Static analysis of mobile sources and new payment tests/renderer passed with no issues.
- Read the existing provider probe again from AWS without mutation: its actual `www.sandbox.paypal.com/checkoutnow` approval URL matched the mobile policy, and its status remained `PAYER_ACTION_REQUIRED`. No second provider checkout was created.
- Rendered and inspected the lab, prepared, uncertain, recovered and 320px Arabic 2x dark states with the actual bundled Jakarta/Arabic/Material/Phosphor fonts. Images are widget-render evidence, not native-device screenshots: `docs/qa/2026-10-25/paypal-core-*.png`.
- The phone package is `dist/raysto-paypal-core-arm64-preview.apk`: **0.6.0 / Android code 2009**, **26,451,543 bytes**, SHA-256 `BBBF0A93DCFF907C78C9B95F55DF72E03F440944ED89E31D4EE8F9608F19D9C9`. Release ARM64 and x86_64 builds succeeded; package, SDK 24/36, ARM64 ABI and development signature were verified. The AOT binary contains the payment lab, reset, completion and secure-recovery markers. APK file inventory contains no `.env`, `.pem` or Firebase-admin credential files. Full metadata is in `dist/paypal-core-artifact.json`; the latest AWS preview alias contains the same phone APK.

No Android device was connected during this verification. Physical-device browser handoff, Android link verification state, real secure-storage process restart, TalkBack and performance remain manual acceptance work. This phase did not approve/capture a PayPal payment or prove an actual delivered, signature-verified capture webhook. Existing server configuration checks are in [PayPal sandbox status](paypal-sandbox-status.md).

## Relevant official references

- [PayPal Orders flow](https://developer.paypal.com/api/rest/integration/orders-api)
- [Flutter URL launcher](https://pub.dev/packages/url_launcher)
- [Flutter Android app links](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)
- [Android website associations](https://developer.android.com/training/app-links/configure-assetlinks)
