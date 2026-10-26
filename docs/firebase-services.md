# Firebase services — Raysto

Hosting update, 25 October 2026: the SQL backend is now live at **https://api.rays.to/** on AWS. The older 0.5.1 APK described below still points to localhost; use an AWS-configured build for direct phone access. See [AWS operations](aws-backend.md) and [Cloudflare setup](cloudflare-domain-setup.md). Firebase project/resources remain unchanged.

Project: **raysto-38505**. Native identifier: **com.gmrt.raysto**. The user upgraded to Blaze and authorized Google sign-in, Storage, Firestore and Realtime Database. These are supporting services; PostgreSQL remains the authority for restaurant membership, orders, prices, payments and reports. No demo data is imported.

## Completed remote configuration

- Google sign-in is enabled alongside email/password. Firebase's provider API reports `enabled: true`.
- OAuth brand display name is Raysto; support email is the existing signed-in project account, contact@awhar.com. No additional Google API scopes are requested.
- Registered the existing Android development certificate SHA-1 `D530D3184AE71564C3F39F7EEA12C8F2CE4E6865`. A production upload/Play signing certificate will need its own registration when available.
- Registered its matching SHA-256 `3482EDF88871F139F190FE05DC7F80276127E5B9A1EECF1F03010C64A7D98EFC`.
- Downloaded fresh `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` through the authenticated Firebase CLI implementation. These include actual Android, iOS and web OAuth client IDs. The web OAuth client is required for native sign-in; no Flutter web target or Firebase web app was created.
- Enabled service APIs: Firestore, Firebase Storage, Firebase Security Rules and Realtime Database.
- Initial inventory: no Firestore databases, no Realtime Database instances, and default Storage bucket lookup returned 404.

## Current integration checkpoint

The [Firebase server verification](firebase-server-verification.md) records the installed AWS credential, successful FCM validation-only request, private server Storage upload/read/delete and enabled recurring dispatcher. Actual push reception/display and Google/inbox/iOS acceptance remain pending. The [25 October integration hardening](integration-hardening.md) and [live functionality assessment](live-functionality-checks.md) supersede historical claims below that no authenticated cloud CRUD or successful verified-user exchange had been exercised. Dedicated profile/avatar/presence UI remains future work. Server credential instructions are in [server-credentials-setup.md](server-credentials-setup.md).

## Region and provisioning

The user selected **Belgium, `europe-west1`**, and all three resources were created there on 24 October 2026:

| Resource | Actual identifier | Verified state |
| --- | --- | --- |
| Firestore | `projects/raysto-38505/databases/raysto-mobile` | ENTERPRISE / FIRESTORE_NATIVE, Firestore API and realtime updates enabled, MongoDB access disabled |
| Storage | `gs://raysto-38505.firebasestorage.app` | EUROPE-WEST1, STANDARD storage class, linked as the default Firebase bucket |
| Realtime Database | `raysto-38505-default-rtdb` | ACTIVE, europe-west1, default instance |

Realtime URL: `https://raysto-38505-default-rtdb.europe-west1.firebasedatabase.app`. Location and identity were read back from the actual resource APIs. No extra database or bucket was created.

The Firestore configuration targets the named **Enterprise Native** database, `raysto-mobile`, with Firestore data access and realtime updates, without MongoDB access. The new-instance default follows the installed Firebase Firestore skill. Empty indexes are sufficient for the current direct document accesses. Do not silently deploy to `(default)` or create a second database if remote inventory changes.

`firebase deploy --only firestore,storage,database --dry-run --project raysto-38505 --non-interactive` compiled all three rule sets successfully. The actual deployment then published the rules and Firestore indexes. Remote rule content was read back and matched the local files, including the release for the named Firestore database rather than `(default)`. Storage bucket IAM had **zero public bindings**. Unauthenticated reads were rejected: Firestore **403 Missing or insufficient permissions**, Storage **403 Permission denied**, Realtime Database **401 Permission denied**. These checks wrote no production documents or files and did not create a test user.

Mobile configuration was downloaded again after provisioning. Android JSON and iOS plist now contain the actual Realtime URL; both Dart FirebaseOptions include the same `databaseURL`. Bucket existence is verified independently of the config files. Public resource identifiers and rule release hashes are recorded in `firebase-resources.json`.

## App integration

The account screen offers **Continue with Google** in English/French/Arabic. The official `google_sign_in` 7.2 API obtains an ID token, Firebase authenticates the credential, and the existing coordinator exchanges a fresh Firebase token for the actual Serverpod session. Cancellation returns to signed out without an error. Logout clears Google/Firebase/backend sessions, and late Google responses cannot restore a logged-out account. No Google account was selected and no real verified-user login is claimed.

`LiveRuntime.cloud` exposes `CloudAccountServices` without automatically uploading data, creating documents or starting listeners:

| Service | Prepared path/API | Allowed client access |
| --- | --- | --- |
| Firestore | `users/{Firebase UID}`; `readPreferences` / `savePreferences` | Verified owner only; display name 1–80 chars, locale en/fr/ar, server timestamp; extra fields rejected |
| Storage | `users/{Firebase UID}/avatar`; upload/read/delete avatar | Verified owner only; JPEG/PNG/WebP; nonempty, at most 5 MiB |
| Realtime Database | `presence/{Firebase UID}/{connection ID}`; explicit open/close connection | Verified owner only; online/offline with a bounded server timestamp; no extra fields |

These are prepared service APIs, not new profile editor/upload/presence product screens. Firebase UID is used only to scope personal Firebase data, never as a SQL restaurant permission. The client reads avatars through authenticated SDK calls; do not publish private download-token URLs. MIME metadata does not establish actual safe image content; a future public upload pipeline needs trusted decoding/validation. Presence is advisory and must never authorize orders or staff actions. A feature using presence must manage disconnect/reconnect and close connections on logout/lifecycle changes.

All other client paths are denied, including restaurants, orders, payment state and staff roles. Server-side IAM bypasses Firebase rules and is scoped separately. Initial mobile provisioning did not generate or embed a service-account key. The later [server credential checkpoint](firebase-server-verification.md) completed scoped AWS FCM/Storage access; device delivery and APNs remain pending.

## Local security tests

`tool/firebase_rules` contains the official rules-unit-testing SDK with a Node 22 compatible dependency lock. It uses the fake project `demo-raysto-rules` and local ports 8185/9185/9285; the development Serverpod port 8080 is untouched. Tests cover owner CRUD, other-user/guest/unverified rejection, schema/role injection, timestamps and upload limits. Test fixtures never write production data.

```powershell
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-21.0.5.11-hotspot'
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
npx -y firebase-tools@latest emulators:exec --config firebase.emulators.json --project demo-raysto-rules --only firestore,database,storage "node --test tool/firebase_rules/rules.test.mjs"
```

Rules are a prototype requiring review before broad distribution. Default denial, verified-user ownership, strict schemas and limits reduce common cross-account and privilege-escalation mistakes; they do not guarantee production security or prevent all abuse. App Check enforcement is not enabled automatically before device attestation is configured.

Verification: **9 local security-test groups passed** across Firestore, Storage and Realtime Database. All emulators shut down afterward. Firestore's emulator used Standard edition, so this verifies rule syntax/behavior, not Enterprise production provisioning. The account/session tests passed **15 tests**, including Google token exchange, cancellation and late-response logout handling, plus narrow Arabic UI checks. The previous whole-app regression checkpoint remains 64 passed; it was not rerun or relabeled as this turn's result.

## Android preview

Current Android preview: `dist/raysto-firebase-arm64-debug.apk`, version **0.5.1 / Android code 2006**, **103,922,119 bytes**, SHA-256 `EF28B9FB4563D12437E3E40A32379286251DC49111A5654C01DF81A292F481AC`. Native Android build, package identity and development signature passed verification. This preview includes the Google button, cloud SDKs and actual Belgium resource URLs. No actual Google account was selected, no authenticated production CRUD was performed and this package was not run on a device. The older 0.5.0 Google preview predates resource provisioning; 0.4/0.3 artifacts remain historical. Current artifact metadata is `dist/firebase-artifact.json`.

The SQL backend still runs locally. Keep the user-started server running and, for an ARM64 Android phone connected through USB debugging, execute from the project root:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" reverse tcp:8080 tcp:8080
```

Open **Use my Raysto account** and **Continue with Google**, or create/verify an email/password account. Firebase services connect directly to the configured cloud project; Serverpod APIs use the USB-forwarded local port. This is not an AWS-connected release build. Dedicated preferences, avatar and presence screens remain future product work.

## iOS boundary

The updated plist contains the real reversed Google client ID. A Mac still needs to register its `REVERSED_CLIENT_ID` URL scheme in the iOS app, set deployment target >=15, finish native plist/plugin linkage and test the return from Google. The xcode-project-setup skill requires Swift tooling and forbids manual project editing; it was not bypassed on Windows. Android native builds are verified independently.

References: [Flutter Google authentication](https://firebase.google.com/docs/auth/flutter/federated-auth), [Firebase resource locations](https://firebase.google.com/docs/projects/locations), [default Storage provisioning API](https://firebase.google.com/docs/reference/rest/storage/rest/v1alpha/projects.defaultBucket/create), [CLI database commands](https://firebase.google.com/docs/cli).
