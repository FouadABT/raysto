# Raysto backend preparation

**Current update — 26 October 2026:** the complete v2 backend and connected mobile workspace are implemented; migrations and Raysto-only AWS deployment have run with the owner's authorization. The earlier preparation notes below are historical. See [mobile-backend-integration.md](mobile-backend-integration.md) for current functionality, tests, APK and provider limitations. PostgreSQL now also owns visits, split allocations, reservations, kitchen/courier operations, subscriptions, AI approvals and audit/outbox records.

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
