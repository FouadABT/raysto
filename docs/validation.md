# Validation — 24 October 2026

Current 0.4.0 connected-account evidence is in [Firebase integration](firebase-integration.md): 62 mobile tests, 17 backend tests, native Firebase initialization and actual unauthenticated API rejection checks. Historical evidence below does not establish verified-user login or live payment delivery.

Latest backend/SDK/package-ID update: see [backend validation](backend-validation.md). The current 0.3.0+3 APK uses com.gmrt.raysto, Flutter 3.47.8 and a prepared Serverpod backend core. The evidence below is the historical 0.2.0 mobile review and must not be read as runtime validation of the newly identified APK.

## Scope

Raysto 0.2.0+2 implements the complete local mobile frontend prompt. Flutter 3.41.9 / Dart 3.11.5, Android/iOS only, Windows host. The original 0.1 browse/save preview remains a developer reference; its older evidence does not establish the new product's behavior. No production services or web application are involved.

## Automated evidence

| Area | Verification |
| --- | --- |
| Formatting and analysis | `dart format --output=none --set-exit-if-changed lib test`: 47 files, no changes; `flutter analyze --no-pub`: no issues found |
| Complete regression suite | `flutter test --no-pub --concurrency=1 --reporter expanded`: **52 tests passed**, after the final native-route repair |
| Money | Required modifiers, integer prices, coupons/fees/tips, frozen pending allocations/addresses, idempotent retry/restoration, cancellation/refund separation |
| Connected journey | Customer proposal/payment → manager acceptance → kitchen preparation → waiter service → customer water request → waiter completion |
| Domain scopes | Private accounts/carts, restaurant permissions, foreign IDs, visit isolation, reset cancellation, role-switch continuity and storage failure/recovery |
| Operations | Availability and immutable history; owner/import drafts; floor save/undo/redo and waiter continuity; occupied-table restrictions; delivery; fresh reservation/waitlist visits |
| Entry | Resumable onboarding, nested sign-in/registration, wrong/valid verification, isolated staff practice |
| Layout | Actual Jakarta/Arabic fonts; widths 320/360/390/430, landscape 640×360; English/French/Arabic RTL; light/dark; 2× text; open keyboards; reachable primary actions |
| Motion/accessibility | OS OR app reduced motion, contrast pairs, touch/selection semantics, rapid tabs/routes, inactive-branch isolation, draft guards |
| Native-route regression | Full table URI and Android-normalized path both show confirmation without modifying cart or visits |

Logs: `build/mobile-tests-final.log`, `build/android-debug-final.log`, `build/android-release-final.log`. Coverage uses representative risk-heavy screens and connected workflows; it is not exhaustive manual review of every screen/configuration.

## Native Android review

The updated x64 debug app was installed on task-owned Android API35 emulator `REDRAWN_Mobile_Test_20260917`, 1080×1920, software GPU. Actual adb screen captures were inspected. Native checks covered entry/account selection, retained roles, discovery, item/restaurant detail, owner overview, tables, floor zoom, cart, checkout and payment recovery.

Scenario F produced `attempt-107` for €22.00. After force-stopping only Raysto and relaunching, Orders retained the same pending attempt and amount. Resume checkout → explicit simulated success released one order with preparation **submitted** and payment **Settled**. No real transaction occurred.

Running-app item and preferences links dispatched correctly. Table-link testing found Android forwards the path without the URI host. The repaired router normalizes known physical-table paths through the same payload parser. Cold launch of `raysto://table/olive/olive-table-06` now renders **Confirm your table**, the occupied state and invitation guidance without joining or exposing the party's bill. The adb cold-start wait timed out under load; the app subsequently rendered the inspected confirmation.

The emulator was slow under host memory pressure and initially displayed unrelated Android system-app ANR dialogs. No Flutter exception appeared in inspected Raysto payment/restart logs. This is functional/visual evidence, **not a frame-rate measurement**. UI/raster profiling on a suitable physical device remains outstanding; no 60/120fps claim is made.

## Package

`dist/raysto-arm64-preview.apk`: optimized ARM64, Android 7.0/API24+, `com.raysto.raysto`, versionName 0.2.0, source build2, split versionCode2002, compile/target SDK36. Uses an **Android Debug development certificate** for local preview, not store release. `dist/artifact.json` records exact size, SHA-256 and identity.

APK inspection verified four Jakarta weights, Noto Arabic, bundled photographs and authored PDF/image menu fixtures; icon tree shaking completed. ARM64 build/signature verification and x64 emulator execution are distinct checks. The ARM64 package was not run on a physical ARM64 phone.

## Visual evidence

- `runtime/welcome.png`, `runtime/accounts.png`, `runtime/discover.png`: native 0.2 implementation entry review.
- `runtime/owner-overview.png`, `runtime/menu-item.png`, `runtime/checkout.png`: updated native customer/operational surfaces.
- `runtime/payment-pending.png`, `runtime/payment-restored.png`, `runtime/payment-success.png`: the actual retained attempt and resolution.
- `runtime/table-link.png`: repaired native table-link confirmation.
- `runtime/tables.png`, `runtime/floor-editor.png`, `runtime/floor-zoom.png`: native canvas review earlier in the same 0.2 implementation, before final state/route repairs.
- `screenshots/` contains older **widget renders of the 0.1 foundation**, not current native product captures.

The authored menu PDF and its PNG were rendered with Poppler and visually inspected. They are deterministic import fixtures, not customer-upload OCR or mock app screenshots.

## Limits

- iOS sources/assets are present; Xcode compilation/signing, native iOS gestures and VoiceOver were not verified on Windows.
- Physical-device performance, TalkBack/VoiceOver reading quality and real camera/location/permission behavior remain unverified. Scanner and permission alternatives are explicitly simulated.
- Assistant/import, account/payment/support/legal/plan flows are local previews with bounded fixtures, not live services or production security.
- UI strings support English/French/Arabic. Restaurant-authored names/descriptions, sample messages and developer-gallery examples include English content.
- State is shared across accounts within one installation only. Appearance/language are device settings; private records and restaurant activity have distinct scopes.

## Final gate

Final post-table-link-fix checks passed: clean formatting, clean analysis, all 52 tests, x64 debug build/install, ARM64 release build and `apksigner verify`. The final APK is 23,259,211 bytes (22.2 MiB), SHA-256 `676E9D79E77B940411847ECE4E3021E1AF29737F9CDC1B20A6B5513F3D6F23AB`. The task-owned emulator was shut down after native review. No application-source work remains pending; the specific platform/performance/service limitations above remain explicit.

## Firebase-first connection checkpoint — 0.4.0

The subsequent connected account implementation supersedes the earlier offline-only UI and Firebase-not-configured statements above. Project raysto-38505 has registered Android/iOS apps and email/password authentication enabled. The app exchanges verified Firebase identity for a securely stored Serverpod session and reads actual catalog/menu/order-history endpoints; broader demo operations remain local. The user-started local server returned healthy status, unauthenticated orders and an invalid Firebase token were rejected, and the public catalog returned no published restaurants.

Final mobile suite: **64 passed**; backend suite: **17 passed**; final Flutter static analysis: **no issues**. Native Firebase initialization/account UI was reviewed on an x64 Android emulator, then the task-owned emulator was shut down. The final ARM64 debug package `dist/raysto-connected-arm64-debug.apk` is version 0.4.0, Android code 2004, 99,711,366 bytes, SHA-256 `38A2EFDF02EFBD5F9FC856F383424A83CEB79E7D7A0764B2B1CC8C1C1107AC2E`; its manifest and development signature were verified. It requires the local backend and USB port forwarding. No verified user's successful login, actual push delivery, private storage upload, physical-device test, iOS build or AWS deployment is claimed. iOS native completion needs a Mac and deployment target >=15. See [Firebase integration](firebase-integration.md) for commands and remaining setup.

## AWS deployment checkpoint — 25 October 2026

The user authorized SSH deployment beside Awhar. Raysto now runs as its own native systemd service on the existing AWS host at https://api.rays.to/, with a separate database and runtime/migration roles on the existing PostgreSQL 16.15. Awhar's service PID/start time and Nginx file checksum remained unchanged; its API/site returned 200 before and after. Shared Nginx received syntax-tested graceful reloads. No global SDK/PostgreSQL upgrade or Docker installation occurred on the host.

Native Linux compilation, archive hash verification, new-database migration/integrity, runtime health and real generated-client checks succeeded. Public HTTPS catalog reads returned zero published restaurants; unauthenticated orders and an invalid Firebase token were rejected. Trusted origin certificates cover API and root/www; www redirects to root, which intentionally returns a landing-pending 503 until the landing page is built. A private Raysto-only backup/timer and certificate renewal hook are installed. These checks are not a real-user OAuth, payment, FCM delivery, restore exercise or physical-phone test.

Deployment files are in deploy/ec2/. See [AWS operations](aws-backend.md) and the [complete English Cloudflare guide](cloudflare-domain-setup.md) for exact paths, commands, isolation and remaining provider setup. Existing offline/demo and older localhost APK evidence above remains historical.
