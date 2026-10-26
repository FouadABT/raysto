# Actual PayPal Sandbox test — 0.7.0

This standalone checkout uses actual PayPal Sandbox APIs and PayPal's approval website. The server fixes the amount at **USD 1.00**, with receipts separate from restaurant orders and fulfillment. No restaurant setup is needed. The local Payment test lab remains a simulation.

## Test on your Android phone

1. Install `dist/raysto-paypal-sandbox-arm64-preview.apk` over the previous preview: version **0.7.0**, Android code **2010**, package `com.gmrt.raysto`. It uses the existing registered development certificate, not store signing.
2. From **Welcome**, **Profile**, or the connected account workspace, select **Test PayPal Sandbox**.
3. Sign into your **Raysto account** using Google or verified email/password. This differs from your PayPal buyer login.
4. Tap **Test USD 1.00 with PayPal**. Your browser opens `https://www.sandbox.paypal.com/checkoutnow?token=…` after backend checkout creation.
5. Sign in with a **Sandbox Personal buyer account** and approve USD 1.00. The configured Sandbox Business account is the seller.
6. Return to Raysto. If the browser stays on the neutral `api.rays.to/payments/return` page, switch back manually. Tap **Check and complete payment**. Returning alone never marks a payment paid.
7. Confirm **Sandbox capture confirmed**, a PayPal order ID and a capture ID. Tap **Refresh receipt** to check **Webhook: verified and received**. Capture and webhook delivery are independent; delivery may arrive later.

Only virtual Sandbox funds move. The x86_64 APK is for compatible emulators, not normal ARM64 phones.

## Get the buyer login

Open [PayPal Developer → Sandbox Accounts](https://developer.paypal.com/dashboard/accounts). Locate **Personal**, select **⋮ → View/Edit Account**, and use its generated email/password on the Sandbox checkout page. If none exists, select **Create Account → Personal**, select a country and create it. Check that the buyer has virtual funds. Enter these credentials only on PayPal; they do not belong in the app environment or chat.

Official guides: [Sandbox accounts](https://developer.paypal.com/sandbox-testing/accounts), [Sandbox login details](https://developer.paypal.com/api/get-started/), [Capture approved orders](https://developer.paypal.com/api/orders/v2/orders-capture), [Webhooks](https://developer.paypal.com/api/rest/webhooks/rest/).

## Recovery

Cancellation keeps the checkout. A timeout remains uncertain until checked against the backend: retry the saved checkout. The start key is encrypted before the first request; provider create/capture calls use stable server-generated request IDs. Capture queries PayPal first to recover a success whose response was lost. Logout hides the previous account's checkout and ignores late responses.

**Start another test** is available after capture and explicitly resets the local start key; it does not refund the preceding test. New sessions are limited to ten/account/day; retries reuse their session. An unprepared session older than three hours requires reconciliation to avoid a duplicate outside the provider idempotency window. Android association is deployed for this preview certificate. iOS return acceptance remains separate work.

## Evidence — 25 October 2026

Backend `/opt/raysto/releases/0.7.0-20261025` is deployed at `https://api.rays.to/`. Additive migration `20261025133602556` creates only `raysto_sandbox_payment` with unique owner/request, provider-order and capture indexes. Runtime table/sequence grants passed. `RAYSTO_SANDBOX_TEST_ENABLED=true` gates authenticated endpoints; the gateway is hardcoded to Sandbox. Credentials remain server-side.

Raysto was backed up. Only `raysto.service` restarted. Awhar PID **2327174**, start **2026-10-25 05:41:00 UTC**, and Nginx SHA-256 `057200aeaa0026d4b3df9c62a83446471a33c23b65b07bdc659397151969cef1` matched before/after. Both APIs returned 200. No Awhar database/configuration or global SDK was changed.

**Actual service checks:** two temporary verified Firebase identities exchanged with AWS (200). Anonymous start returned 401; cross-account read returned `not_found` (400). A USD1 start retry reused its session. Actual PayPal order **9PD25045KA043650D** was created and reused on retry with a Sandbox approval URL. Capture before approval returned `approval_required` (400), leaving no capture or webhook falsely reported. Evidence: `qa/2026-10-25/paypal-sandbox-live.json`.

Both temporary Firebase/Serverpod identities, refresh sessions and the unapproved QA receipt were removed and verified absent; their local private file was removed. The provider QA order remains unapproved in Sandbox. It is not a checkout for the user to approve.

**Automated checks:** all **25 backend checks**, including eight new sandbox checks, passed on dedicated PostgreSQL `localhost:61810`. Provider responses in these tests are mocked; SQL transactions/isolation are real. **58 focused mobile checks** passed, covering generated adapter/secure start retries, coordinator/auth/notification/returns and receipt layout at 320px/2x text in English/French/Arabic. One bundled-font render also passed. App/test and backend static analysis passed. `qa/2026-10-25/paypal-sandbox-receipt-fixture.png` is a UI fixture, not capture evidence.

Both APKs built. Version/package/ABI/signature and AOT markers for the new screen/API were verified; file inventories contain no server credential filenames. No Android device was connected. **Buyer-approved capture, actual signed webhook delivery, browser-to-app return and physical-device acceptance remain pending the phone test.**

Metadata: `dist/paypal-sandbox-artifact.json`. Backend archive: `dist/raysto-backend-0.7.0-linux-x64.tar.gz`, **7,282,912 bytes**, SHA-256 `39DD9054E9F828D666A614A90013BFB1678782ED8080C5376B4F35802E1B6242`. Deployment script `deploy/ec2/update-sandbox-070.py` is one-shot and refuses an existing release.
