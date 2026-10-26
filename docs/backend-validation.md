# Backend preparation validation — 24 October 2026

Latest 25 October checkpoint: all **25 backend checks** passed on the isolated test cluster, plus **58 focused mobile checks** and one receipt fixture render. Actual deployed unapproved Sandbox checkout/retry, Firebase identity exchange, owner isolation and approval-gate checks also passed. See [0.7.0 actual Sandbox test](paypal-real-sandbox-test.md) for evidence and the pending buyer-approved capture/device checks. Counts below are historical.

For the newer 0.4.0 Firebase/frontend connection evidence, see [Firebase integration](firebase-integration.md). The preparation/build evidence below describes the prior 0.3.0 snapshot; the latest suites contain 17 backend and 62 mobile tests.

## Verified toolchain

- Scoped Flutter **3.47.8**, framework revision `737ba8f885dc774b53b442759999a312c9461e4e`, engine `cf636b1dfb818dd6a3ff16e390e93b1a036969c8`; Dart **3.13.7**. Global Flutter 3.41.9 / Serverpod CLI 3.1.1 are unchanged.
- Standalone Dart SDK ZIP: official GCS MD5 `0a2a5f3ff67a8db3e59631cc4e63bd11`; computed SHA-256 `3b31d9f90b27861f29842d378f39f98ce9e60910042334f950ef5702f174fb81`. SDK extracted only after verification.
- Serverpod/server/client/auth/test/CLI packages **4.0.4**, pinned tooling workspace and package locks. No prerelease Serverpod is selected.
- `SELECT version()` on the task-owned container confirmed **PostgreSQL 18.6**. Host bind `127.0.0.1:61810`. Existing native PostgreSQL 18.0 and unrelated containers were not upgraded, reset or stopped.

## Checks passed

- `backend/backend.ps1 -Action generate`: generated server models, endpoint dispatch, future-call dispatch, Dart client and test harness. Generated sources are not hand-maintained.
- Initial migration `20261024150949945` generated; integration harness successfully applied it, including Serverpod authentication module migrations, to ephemeral databases on the isolated Raysto cluster.
- Backend suite: **15 passed**. Coverage includes immutable server pricing, idempotent ordering, changed-key rejection, cross-tenant/customer access denial, invalid/cross-restaurant items, unpaid preparation refusal, courier queue restriction before assignment, merchant/amount mismatch rejection, receipt/outbox deduplication, stale-version conflicts, staff revocation, lost capture recovery by GET, invalid webhook refusal, user-scoped devices/service requests, exact sandbox request contracts and integer money parsing.
- Concurrency case uses `RollbackDatabase.disabled` inside an ephemeral database, so four order requests use independent committed SQL transactions rather than a shared rollback fixture. Exactly one order results. Four concurrent capture reconciliations produce one receipt and one outbox event. The harness drops that ephemeral database afterwards.
- `dart build cli --target bin/main.dart --output build` produced the Windows server executable and all three native assets (sqlite3, connection pool, argon2). This is compile/package validation, not a deployed Windows service.
- Root `flutter analyze`: **no issues** after current SDK compatibility fixes. This also checks the prepared backend source under the workspace analyzer. Dart formatting was applied to new/changed sources.
- Mobile regression suite after dependency upgrades: **52 passed**. Narrow screens, 2x text, Arabic/French fonts, keyboard layouts, local ordering/payment recovery, role actions, drafts and motion remain covered.
- Android ARM64 release **0.3.0+3** built with the scoped Flutter SDK. `aapt` confirms package **com.gmrt.raysto**, versionName **0.3.0**, split versionCode **2003**, minSdk **24**, targetSdk **36**, ABI **arm64-v8a**. `apksigner verify --print-certs` succeeded; certificate is Android Debug (development signing).
- New `dist/raysto-arm64-preview.apk`: **23,367,724 bytes**, SHA-256 `BC6D792A48F16A32A4F55FF3EBBC159A44DB17BC9CC8112F44DE1FE3B440F8F6`. Metadata in `dist/artifact.json` matches this build. iOS source bundle IDs are updated; iOS build is unavailable on this Windows host.

## Packaging and limits

Linux x64 Docker image `raysto-backend:0.3.0` built successfully with the final exec-based entrypoint, native assets and a non-root user. Docker image/manifest ID `sha256:6bc2b0ed9b766888a4ccf1f0b5e2c021813b21f735b2f9bf49c83b8f816c5cec`; image configuration digest `sha256:3b13f8fdc93b305b0062b28d577a325cf9109f786f0a521692f902169244f960`. A network-disabled shell check confirmed UID **65532**, executable presence, and exclusion of `config/passwords.yaml`/`.env`. A help-only executable probe revealed Serverpod has no `--help` option: it initialized with disposable test secrets and attempted a blocked database connection. The task-owned probe container was stopped immediately. This is not a successful HTTP/database startup test of the deployed container. Server business/database behavior is covered through the integration harness. No persistent application server was left running.

No AWS deployment, DNS change, registry publication or cloud resource creation was performed. Template nested CI/debug files with stale paths/embedded-database assumptions were removed; no remote CI execution is claimed.

Firebase identity exchange, actual FCM delivery/private storage upload, and a real PayPal sandbox buyer approval/capture have not been exercised: no external project credentials were supplied. HTTP contracts use controlled mock provider responses; business persistence and concurrency use real PostgreSQL. The future AG Grid interface has a compiled/authenticated reporting route, not a built dashboard or tested browser session/CORS flow.

The new Android APK has not been installed or exercised on a physical device/emulator in this backend phase. Earlier 0.2.0 emulator evidence remains historical and used a different provisional package ID. BackendConnection is prepared but the UI remains offline DemoStore. No real AI model/tool orchestration is connected. See backend-setup.md for remaining business features and live-payment boundaries.

Android builds warn that Gradle 8.14.0, AGP 8.11.1 and Kotlin 2.2.20 will need future upgrades; they remain compatible enough for this verified build. They were not described as globally upgraded tools. Global database migrations and major native build-system migration were not performed as part of preparing this isolated backend.

## Firebase-first connection checkpoint — 0.4.0

The subsequent connected account implementation supersedes the earlier offline-only UI and Firebase-not-configured statements above. Project raysto-38505 has registered Android/iOS apps and email/password authentication enabled. The app exchanges verified Firebase identity for a securely stored Serverpod session and reads actual catalog/menu/order-history endpoints; broader demo operations remain local. The user-started local server returned healthy status, unauthenticated orders and an invalid Firebase token were rejected, and the public catalog returned no published restaurants.

Final mobile suite: **64 passed**; backend suite: **17 passed**; final Flutter static analysis: **no issues**. Native Firebase initialization/account UI was reviewed on an x64 Android emulator, then the task-owned emulator was shut down. The final ARM64 debug package `dist/raysto-connected-arm64-debug.apk` is version 0.4.0, Android code 2004, 99,711,366 bytes, SHA-256 `38A2EFDF02EFBD5F9FC856F383424A83CEB79E7D7A0764B2B1CC8C1C1107AC2E`; its manifest and development signature were verified. It requires the local backend and USB port forwarding. No verified user's successful login, actual push delivery, private storage upload, physical-device test, iOS build or AWS deployment is claimed. iOS native completion needs a Mac and deployment target >=15. See [Firebase integration](firebase-integration.md) for commands and remaining setup.

## AWS deployment checkpoint — 25 October 2026

The user authorized SSH deployment beside Awhar. Raysto now runs as its own native systemd service on the existing AWS host at https://api.rays.to/, with a separate database and runtime/migration roles on the existing PostgreSQL 16.15. Awhar's service PID/start time and Nginx file checksum remained unchanged; its API/site returned 200 before and after. Shared Nginx received syntax-tested graceful reloads. No global SDK/PostgreSQL upgrade or Docker installation occurred on the host.

Native Linux compilation, archive hash verification, new-database migration/integrity, runtime health and real generated-client checks succeeded. Public HTTPS catalog reads returned zero published restaurants; unauthenticated orders and an invalid Firebase token were rejected. Trusted origin certificates cover API and root/www; www redirects to root, which intentionally returns a landing-pending 503 until the landing page is built. A private Raysto-only backup/timer and certificate renewal hook are installed. These checks are not a real-user OAuth, payment, FCM delivery, restore exercise or physical-phone test.

Deployment files are in deploy/ec2/. See [AWS operations](aws-backend.md) and the [complete English Cloudflare guide](cloudflare-domain-setup.md) for exact paths, commands, isolation and remaining provider setup. Existing offline/demo and older localhost APK evidence above remains historical.
