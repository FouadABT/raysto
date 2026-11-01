# Raysto backend preparation

**Current update — 27 October 2026:** the v2 backend, connected mobile rooms and AG Grid/Studio console are implemented. Backend/console patch `0.11.6` is deployed on Raysto-only AWS services; Android candidate `0.11.5+2014` is built. See [the current candidate report](release-candidate-2026-10-27.md) and [project status](project-status.md) for verified scope, Google capacity failures and outstanding buyer/device/pilot acceptance. The preparation notes below are historical; [mobile integration](mobile-backend-integration.md) preserves earlier evidence. PostgreSQL owns visits, split allocations, reservations, kitchen/courier operations, subscriptions, AI approvals and audit/outbox records.

**Deployed and accepted — 31 October to 1 November 2026:** the scope correction below is committed on `main` and live.

- Backend 0.12.0 applied migration `20261028134922094` and switched Gemini to the Developer API (3.6 Flash). 0.12.1 and 0.12.2 changed only Ask Raysto's answers: every fact is kept, and refund checks are named.
- Console 0.12.1 opens on Overview / Orders / Payments (AG Grid) at ops.rays.to.
- The PayPal webhook was already registered and matches `PAYPAL_SANDBOX_WEBHOOK_ID`.
- Live Sandbox acceptance with two buyers passed: pickup, counter QR, a two-buyer equal split, a $5 partial refund, and the manager assistant reading PayPal through MCP. Ids are in [paypal-acceptance-2026-10-31.md](paypal-acceptance-2026-10-31.md).
- Android 0.12.1+2015 (arm64 release, `RAYSTO_API_URL=https://api.rays.to/`) is built but has not been run on a physical phone.
- Backend 123/123, web 14/14.

**Hackathon scope correction — 28–29 October 2026 (branch `hackathon/full-suite`):** the audit in [`audits/raysto-full-product-audit.md`](audits/raysto-full-product-audit.md) found the product narrowed to the shared table. Work since, all on the isolated test database and not yet deployed:

- Money: a checkout "checked" before approval returns to `created` instead of sticking in `capturing`; read failures are no longer `uncertain`; managers get `payment.release` (re-reads PayPal, refuses if captured); refunds take an `orderId` so one capture over several orders refunds the right one; capture now runs server-side as soon as PayPal shows `APPROVED` (webhook, retry job, or the PayPal return page); partial refunds no longer strand preparation; split bills with a settled share are not expired.
- Snack bar: `counter`, `dispatch` and `acceptOrders` capabilities on memberships; counter sales (`quote.create` with `onBehalf`), daily ticket numbers, 4-digit pickup codes, `walk-in:<restaurant>` customer, `autoAcceptPaid`, staff alerts, newest-first `orders`/`checkouts` with `q` lookup by number or code.
- AI: Gemini runs through the Developer API when `GEMINI_API_KEY` is set (Vertex AI EU otherwise), with a bounded retry on 429/503 only; a customer basket context (`assistant.start` with `context: cart`) limited to menu and pickup-basket tools; manager tools `sales_summary`, `kitchen_load`, `pickup_ready`, `unresolved_payments` (then `payment_status` reads PayPal via MCP); `recommend` now sees allergens; `room.split.equal` splits without AI and binds each payer to their exact share.
- Mobile: staff shell (orders board, counter with PayPal QR, kitchen board, More), live refresh from `/api/v2/events`, Ask Raysto for pickup baskets and for managers, "Split equally" in the room, capabilities on `LiveContext`, French and Arabic strings for the new screens.
- Web: the `/ops` proxy uses an explicit allowlist (camelCase commands work) with a drift test.
- Verification: backend 111/111 (unit + integration on `raysto-backend-postgres`), web 9/9 and typecheck, `flutter analyze` clean, new staff widget tests at 320 px / 2× / Arabic. Not yet: production migration `20261028134922094`, Sandbox buyer sessions, the PayPal webhook registration, Gemini API enablement on the key's project.

The user selected Serverpod + PostgreSQL, Firebase for identity/notifications/storage, PayPal sandbox and a later AG Grid web dashboard. The backend is now deployed on the user's existing AWS infrastructure at **api.rays.to**; Render is excluded. Firebase project raysto-38505 is linked and supporting databases/storage are provisioned in Belgium. Android/iOS identity: `com.gmrt.raysto`. Current deployment evidence is in aws-backend.md; root/www domain configuration for the later landing page is in cloudflare-domain-setup.md.

## Architecture

- Serverpod owns authorization and business transitions. PostgreSQL stores restaurant records, orders, frozen totals, checkout attempts, receipts and notification events. Dine-in visits and broader operational records are future extensions.
- Flutter uses generated Dart APIs. A later React/Next.js application uses authenticated HTTP routes; business rules are shared.
- Firebase identity is bridged through Serverpod's supported identity provider. Tenant membership and staff permissions remain server-owned.
- PayPal REST calls and verified webhook processing run on the server. Client callbacks cannot declare payments settled. AI/MCP tools use the same authorized business services.
- Notifications are durable events sent after committed state changes. Firebase storage access is permission-controlled. No service credentials are embedded in clients.
- AWS artifacts are prepared for review and local testing. No cloud resources are provisioned or deployed in this task.

## Ordered implementation

- [x] Inspect current source and installed tools; research latest official documentation.
- [x] Prepare compatible stable toolchain and isolated PostgreSQL development/test database.
- [x] Generate Serverpod server/client without replacing the existing Flutter application.
- [x] Implement persisted core entities, tenant authorization, validated pickup/delivery ordering and versioned preparation transitions.
- [x] Add PayPal sandbox adapter, idempotent attempts, capture reconciliation and verified capture webhooks.
- [x] Prepare Firebase identity, push/private storage adapters and manual configuration instructions.
- [x] Provide paginated HTTP reporting data suitable for the later AG Grid application.
- [x] Prepare AWS-compatible container/configuration and local run instructions.
- [x] Run meaningful SQL, authorization, money/payment/recovery/concurrency tests; mobile regression and Android build/native identity checks. See backend-validation.md for limitations.

## Toolchain audit

Existing tools: Flutter 3.41.9 / Dart 3.11.5, global Serverpod CLI 3.1.1, PostgreSQL binaries 18.0, Docker Engine 29.1.2. Official stable releases checked: Serverpod 4.0.4; Flutter 3.47.8 with Dart 3.13.7; PostgreSQL 18.6. Serverpod 4 requires Flutter >=3.44.4 / Dart >=3.12.2 and PostgreSQL >=16.

Use project-scoped SDK tools and an isolated development database. This avoids migration of existing local database clusters. Flutter is checked out from its official 3.47.8 tag. The standalone Dart 3.13.7 archive was verified against GCS's published MD5; its SHA-256 is recorded in backend validation. PostgreSQL 18.6 uses a cached official container, bound to 127.0.0.1:61810.

The scoped implementation and remaining integration boundaries are documented in `backend-setup.md`; AWS packaging is in `aws-backend.md`. The subsequent Firebase-first connection is documented in `firebase-integration.md`: native Android initialization and live endpoint rejection/read checks succeeded, but a real verified user's successful exchange, live PayPal buyer approval, deployment and migration of frontend demo records are not claimed.
