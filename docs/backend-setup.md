# Raysto backend — local setup and manual services

Prepared 24 October 2026; deployment updated 25 October 2026. Native Android application ID and iOS bundle ID: **com.gmrt.raysto**. Render is excluded. The backend is now deployed at **https://api.rays.to/** on the user's AWS host, independently of Awhar. This document describes local development and provider setup; see [AWS operations](aws-backend.md) and the [English Cloudflare guide](cloudflare-domain-setup.md) for hosting/domain configuration.

## What is implemented

`backend/raysto` contains a Serverpod 4.0.4 workspace with generated server models, a Dart client and an initial SQL migration. Business state is separate from the existing Flutter `DemoStore`.

- Authenticated restaurant creation gives its creator the owner membership. Only that owner can grant/revoke staff roles in that restaurant. Firebase supplies identity; SQL memberships supply permissions.
- Restaurant publication and menu writes require manager/owner permissions. Public catalog endpoints expose only published restaurants and available products.
- Customer order placement validates restaurant, items, quantities, fulfillment and delivery address. Prices/fees are computed on the server in integer minor units. Immutable item names/prices and totals are stored with the order. Supported currencies are EUR/USD/GBP, all two decimal places. Prices are treated as inclusive; no invented tax rate or discount is applied.
- Per-customer request keys and request hashes make order retries idempotent and reject changed payloads. Preparation requires confirmed payment and role-authorized transitions, with version conflicts reported explicitly.
- Sandbox PayPal checkout persists its attempt before calling the provider, reuses the provider request ID and reconciles completed captures against order ID, merchant, amount, currency and capture status. A unique receipt and durable notification are committed together. Capture GET recovers lost responses. Signed webhook events are verified using PayPal's verification API before reconciliation.
- Device tokens are user-scoped; customers can create idempotent order service requests. Notifications use a SQL outbox, FCM HTTP v1 and bounded retry backoff. Push contains event/order IDs, not order addresses.
- Private menu image upload helper validates manager membership, size/type and writes to Firebase's GCS bucket. It is not yet exposed as a public upload endpoint or public image-serving policy.
- Authenticated, paginated HTTP order reports are available for the future AG Grid dashboard. The web frontend itself is not built in this phase.

## Toolchain on this machine

The project-local SDK is `.tooling/flutter` (Flutter 3.47.8 / Dart 3.13.7). `.tooling/dart-sdk` is the separately verified Dart 3.13.7 SDK used for backend tools. Global Flutter/Serverpod and the installed PostgreSQL 18.0 cluster were left untouched. The Flutter SDK was checked out from the official 3.47.8 tag; the standalone Dart archive was checked against GCS's published MD5 before extraction.

Use these from the Raysto root in PowerShell:

```powershell
.\.tooling\flutter\bin\flutter.bat pub get
.\.tooling\flutter\bin\flutter.bat run -d <device-id>
.\backend\backend.ps1 -Action analyze
.\backend\backend.ps1 -Action test
.\backend\backend.ps1 -Action start
```

`start` applies pending migrations to the configured development database. No persistent application server was started automatically. Tests boot their own Serverpod harness and apply migrations to ephemeral databases on the isolated cluster. The generated project's MCP-first development guidance remains in `backend/raysto/AGENTS.md`; use that workflow once Serverpod MCP is connected. CLI generation was needed for initial bootstrap because no such MCP was available.

The task-owned database container `raysto-backend-postgres` is PostgreSQL **18.6**, exposed only on **127.0.0.1:61810**; volume `raysto-backend-pg18`. `backend/.env` and the generated `config/passwords.yaml` hold local random credentials and are ignored. Do not print/commit them. Existing port 55432 was occupied and was not disturbed. The native PostgreSQL installation is not used or upgraded.

On this machine, start the existing container with `docker start raysto-backend-postgres`. For a fresh checkout, copy `backend/.env.example` to `.env`, generate a password, then use `docker compose --env-file backend/.env -f backend/compose.yaml up -d`. Do not run Compose against the separately created existing container without deliberately adopting/recreating it; the persisted volume must be preserved. Do not use `down -v` on data you need. Configure `development.yaml`/`test.yaml` and ignored `passwords.yaml` to match your isolated database. Serverpod's ephemeral tests require a database role with permission to create test databases; production should use a separate restricted role.

Server ports: typed API 8080, private Insights 8081, HTTP routes 8082. Android emulator reaches the API through `http://10.0.2.2:8080/`; a physical phone needs an explicitly configured reachable development host. `lib/backend/backend_connection.dart` prepares an opt-in generated client with HTTPS validation. **Use my Raysto account** now opens the connected Firebase sign-in/verification flow, followed by live catalog/menu and order-history reads. The existing broader restaurant demo remains explicit; demo identities/records are never migrated silently. See `firebase-integration.md` for current integration scope. SDK minimum is now Dart 3.13. Flutter 3.47 also required a Cupertino import update and a local MIT Regular/Fill Phosphor compatibility subset; see `third_party/phosphor_flutter/README.md`.

## Firebase — user creates and links the project

1. Register Android **com.gmrt.raysto** and iOS **com.gmrt.raysto** in your Firebase project. Enable the chosen Authentication providers. Add platform signing fingerprints/provider settings where required.
2. Run FlutterFire configuration for **Android/iOS only** after installing Firebase/FlutterFire CLI. Its generated `firebase_options.dart`, `google-services.json` and `GoogleService-Info.plist` belong to that project. These mobile Firebase files are not the server service-account key.
3. Firebase SDKs and a secure Serverpod session manager are installed. The custom real-account UI uses Firebase email/password, actual email-link verification and password reset, then exchanges a fresh Firebase token through the generated `client.firebase.login` endpoint. `SessionController` coordinates both systems explicitly and prevents late login results from undoing logout. A Firebase UID is not a SQL staff role. The optional global `initializeFirebaseSignIn()` sign-out hook is not used because it would race this explicit two-system session coordinator.
4. Set `RAYSTO_FIREBASE_ENABLED=true` and `FIREBASE_PROJECT_ID=raysto-38505` on the server. Only the project ID is required for Firebase ID-token verification against Google public certificates; no service-account private key is needed for sign-in. The backend independently requires verified email before issuing its session. The local `backend.ps1 -Action start` reads this selected project from `.firebaserc`; AWS still uses explicit environment configuration. With the flag off there is no fake login provider.
5. For push/storage helpers, mount a server-only service-account JSON file and set `GOOGLE_APPLICATION_CREDENTIALS`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`. Grant only the needed FCM/Storage permissions. Set `RAYSTO_NOTIFICATIONS_ENABLED=true` on exactly one scheduler instance; it schedules a durable dispatcher every 30 seconds. Other API instances leave that flag off. Clients deduplicate received pushes by `eventId` and refresh authenticated order data.
6. The user upgraded to Blaze; the actual bucket is now `raysto-38505.firebasestorage.app` in Belgium (`europe-west1`). Private avatar rules are deployed; the server upload helper still requires its own IAM credentials. **Storage rules cannot read PostgreSQL memberships**, and Serverpod tokens do not automatically authenticate the Firebase Storage client. Design public menu image reads/private receipt access separately when exposing uploads. See `firebase-services.md` for Firestore/Realtime Database resources and deployment evidence.

Do not send private service-account JSON in chat or commit it. On AWS, mount/inject it through a secrets mechanism. The selected Firebase project and Android/iOS apps are now configured, and email/password authentication is enabled. End-to-end sign-in with a user-verified email, actual FCM delivery and storage uploads are tracked separately in `firebase-integration.md`; no untested provider success is claimed.

## PayPal Sandbox configuration

Create a PayPal developer sandbox REST app and buyer/business test accounts. Set `PAYPAL_CLIENT_ID`, `PAYPAL_CLIENT_SECRET`, `PAYPAL_MERCHANT_ID`, `PAYPAL_WEBHOOK_ID`, `PAYPAL_RETURN_URL`, `PAYPAL_CANCEL_URL` on the server. Callback URLs must be HTTPS, e.g. `/payments/return` and `/payments/cancel` on the backend. Register **PAYMENT.CAPTURE.COMPLETED** at `/webhooks/paypal` on port 8082 behind TLS.

Flow: customer calls `commerce.placeOrder` with a new request key → `commerce.checkout` returns a sandbox approval URL → the user approves through PayPal → `commerce.capture` checks/captures and reconciles → verified webhook retries can reconcile the same payment. Return/cancel pages **never mark an order paid**. Unknown create outcomes older than three hours require operator reconciliation rather than a new potentially duplicate provider order. Keep and reuse the original order/request key.

This initial adapter uses **one configured sandbox merchant**, not marketplace onboarding, split settlement or courier payouts. Live payment mode is intentionally absent. Refunds, disputes, reversals, cancellation/expiration policy, marketplace onboarding and provider reconciliation operations need their own reviewed workflows before accepting real money. Do not enable live traffic with only this capture webhook. Real PayPal sandbox transactions still need your credentials and external callback access; tests use controlled HTTP responses and real isolated PostgreSQL. PayPal MCP is optional development/agent tooling and does not replace this authoritative server payment path.

## HTTP contract for the future web application

`GET /api/v1/orders?restaurantId=1&offset=0&limit=50`, authenticated with a valid Serverpod bearer session. Owner/manager membership is checked in the shared service. Response: `{rows, offset, limit, nextOffset}`. Rows contain IDs, fulfillment/status/paymentStatus, integer total/currency and creation time, without customer address. Fixed newest-ID order; limits 1–100. Unknown filters are not interpreted as SQL. Arbitrary AG Grid server-side filters/sorts, aggregates and a full OpenAPI contract are future additions.

`GET /health` checks SQL connectivity. `POST /webhooks/paypal` verifies the provider. Browser origins/cookie strategy must be configured for the actual separate Node.js/React domain; no broad credentialed CORS allowlist is shipped. Never expose Insights port 8081 publicly.

## Scope still to connect

The UI's broader demo flows (dine-in visits/QR participation, split bills, full reservations/waitlist, stock/modifiers/allergens, assigned courier dispatch, refund management and AI tool orchestration) are not all implemented in this backend iteration. Their existing demo behavior remains explicitly local. The prepared core is intended to be extended and wired after Firebase configuration; it is not a claim that the entire local demo has become a production multi-user service.

Official references: [Serverpod installation](https://docs.serverpod.dev/installation), [Firebase identity bridge](https://docs.serverpod.dev/concepts/authentication/providers/firebase/setup), [Serverpod HTTP routes](https://docs.serverpod.dev/concepts/web-server/overview), [PayPal Orders v2](https://developer.paypal.com/api/orders/v2), [PayPal idempotency](https://developer.paypal.com/api/rest/reference/idempotency/), [Firebase FCM servers](https://firebase.google.com/docs/cloud-messaging/server-environment), [Storage billing changes](https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024).
