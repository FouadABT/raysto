# Getting started

Start with an offline mobile or web preview to inspect the interface. Connected behavior requires configured services; fictional demo accounts are not cloud credentials.

## Toolchain

| Component | Recorded version / prerequisite |
| --- | --- |
| Mobile | Flutter 3.47.8 / Dart 3.13.7, Android SDK/API 36, Java 17 and emulator/device. Run `flutter doctor` to finish local setup. |
| Backend | Dart 3.13.7; Serverpod 4.0.4 pinned in workspace/tooling manifests. |
| Database | Dedicated PostgreSQL; Compose pins 18.6. Source retains compatibility with the original deployment's PostgreSQL 16 major version. |
| Web | Node.js 22 LTS or compatible supported release, npm; exact packages in `web/package-lock.json`. |
| Connected local origin | A reverse proxy such as Caddy combines native RPC and REST. |

These versions describe this snapshot. Do not upgrade shared production tooling to match. `.tooling/` is not distributed; use executables on PATH.

## 1. Mobile preview

```sh
git clone https://github.com/FouadABT/raysto.git
cd raysto
flutter pub get
flutter devices
flutter run -d <your-device-id>
```

Choose the explicit offline demo. Its fictional `.test` accounts use demonstration password `RaystoDemo123!`; simulated verification uses `123456`. These values authenticate nothing on the backend. See [demo scenarios](demo-guide.md).

Flutter prepares ignored local platform tooling on first run. iOS requires macOS/Xcode and signing/provider setup; an iOS build has not been validated. Do not add Flutter web; `web/` is a separate application.

## 2. Web preview

From the repository root:

```sh
cd web
npm ci
npm run dev
```

Open http://127.0.0.1:3100; choose a fictional account at `/login`. This prototype uses browser-local data and AG Grid Community. It does not contact the backend or perform PayPal payments. See [web instructions](../web/README.md).

## 3. Dedicated local backend

Commands below use PowerShell; use equivalent copy/environment syntax on other shells.

```powershell
Copy-Item backend/.env.example backend/.env
Copy-Item backend/raysto/raysto_server/config/passwords.example.yaml backend/raysto/raysto_server/config/passwords.yaml
```

Edit these **ignored copies**. Replace each placeholder using your password manager or `python -c "import secrets; print(secrets.token_urlsafe(64))"`. The development database password must match `POSTGRES_PASSWORD` in `backend/.env`; the test password must match the isolated test role. Generate independent signing/pepper values for each environment. Never fill secrets into tracked examples.

```powershell
docker compose --env-file backend/.env -f backend/compose.yaml up -d
dart pub get --directory backend/raysto
dart pub get --directory backend/tooling
cd backend/raysto/raysto_server
dart run bin/main.dart --mode=development --apply-migrations
```

Compose uses a dedicated container/database on `127.0.0.1:61810`. If a container with the same name exists, inspect its ownership/data before changing it. Do not use `down -v` on data you need.

Initial startup applies generated migrations with platform v2 disabled. Stop the server after migration. From a new terminal at the repository root, apply required tenant constraints:

```powershell
Get-Content backend/operations/platform-v2-constraints.sql -Raw | docker exec -i raysto-backend-postgres psql -U raysto -d raysto_backend -v ON_ERROR_STOP=1
```

Adjust username/database if you changed defaults. Existing databases also need a reviewed [legacy backfill](../backend/operations/platform-v2-backfill.sql). Never target unrelated data. Generated migrations do not install these supplemental constraints.

Ports: RPC `8080`, private Insights `8081`, REST/health `8082`. `GET http://127.0.0.1:8082/health` checks database connectivity. Keep Insights private.

## 4. Connected identity, files and AI

Use a Firebase/Google Cloud project you control. Checked-in mobile configuration identifies the original Raysto app; forks must replace it before connecting their own services.

1. Register Android/iOS apps for your application IDs and signing fingerprints. The current ID is `com.gmrt.raysto`.
2. Enable intended Authentication providers. Registered backend access requires verified email. Configure MFA for sensitive operations.
3. Replace Android `google-services.json`, iOS `GoogleService-Info.plist` and Dart options. The app imports `RaystoFirebaseOptions` from `lib/backend/firebase_options.dart`; preserve that class contract when replacing generated values. Update `.firebaserc`.
4. Provision Storage/Firestore/Realtime Database as needed; review/deploy the supplied rules/indexes to your project. SQL remains the business authority.
5. Supply server-only Google credentials through a secret store/ignored path, with the identity lookup/revocation and Storage/FCM/Vertex permissions required. Mobile app configuration is not an Admin credential.
6. Set `FIREBASE_PROJECT_ID`, `FIREBASE_PROJECT_NUMBER`, `FIREBASE_ALLOWED_APP_IDS`, `FIREBASE_STORAGE_BUCKET`, `GOOGLE_CLOUD_PROJECT` and `GOOGLE_APPLICATION_CREDENTIALS` in the server process. Use [environment reference](../backend/operations/platform-v2.env.example) and [operations guide](backend-v2/operations.md).
7. Set `RAYSTO_FIREBASE_ENABLED=true` and `RAYSTO_PLATFORM_V2_ENABLED=true`. Start registered App Check in observation mode; guest creation always requires valid attestation. Register development debug tokens privately; leave guests disabled until configured.
8. For file/AI jobs, configure ClamAV/current definitions, `pdfinfo`, approved Vertex access, quotas and spending controls, then enable one worker with `RAYSTO_PLATFORM_WORKER_ENABLED=true`. Leave unconfigured email/billing/payment services disabled.

Environment examples are documentation: Dart does not load them automatically. Set variables in the launching shell or deployment's environment mechanism. `backend/.env` is only the Compose PostgreSQL configuration.

Restart the backend with that environment. For a connected Android emulator, run the **loopback-only** proxy from the repository root:

```powershell
caddy run --config deploy/local/Caddyfile
```

In another terminal:

```sh
flutter run --dart-define=RAYSTO_API_URL=http://10.0.2.2:8085/
```

The proxy combines RPC/REST without exposing Insights. Physical devices need a reachable **HTTPS** origin and matching provider configuration. For your hosted environment:

```sh
flutter run --dart-define=RAYSTO_API_URL=https://your-api.example/
```

Create and verify an account in the configured Firebase project, then use connected onboarding. Do not import demo identities or manufacture staff memberships. Existing Raysto hosting is not an unrestricted reviewer/admin account.

## 5. PayPal Sandbox

Standalone Sandbox, restaurant marketplace and subscription billing use separate configurations.

- Standalone: `PAYPAL_CLIENT_ID`, `PAYPAL_CLIENT_SECRET`, `PAYPAL_MERCHANT_ID`, `PAYPAL_WEBHOOK_ID`, `PAYPAL_RETURN_URL`, `PAYPAL_CANCEL_URL`. See [backend example](../backend/.env.example).
- Marketplace/subscriptions: `PAYPAL_PLATFORM_*`, `PAYPAL_BILLING_*`, explicit merchant capabilities/countries and registered webhooks. See [v2 reference](../backend/operations/platform-v2.env.example).
- Use Sandbox buyer and merchant accounts. Keep `RAYSTO_PAYPAL_ENVIRONMENT=sandbox`, `RAYSTO_LIVE_PAYMENTS_APPROVED=false`.
- Configure reachable HTTPS callbacks/webhooks. The mobile callback-origin allowlist and native link declarations must match; current code is scoped to `api.rays.to`.
- A redirect is not payment proof. Verify capture/webhook/recovery/refund evidence through the backend. See [payment contracts](backend-v2/integration.md).

Credentials are not distributed. Offline payment results and screenshots never count as Sandbox acceptance.

## Validation and release

[CONTRIBUTING.md](../CONTRIBUTING.md) lists checks. Database tests need an isolated role permitted to create/drop test databases and matching test configuration. Never use production/shared databases.

After configuring the origin:

```sh
flutter build apk --release --dart-define=RAYSTO_API_URL=https://your-api.example/
```

Current Android release builds use development signing for direct testing. Configure release signing/provider fingerprints before distribution; do not commit keys. New builds, device/provider acceptance and deployments are separate from this source preparation.
