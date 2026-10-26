# Firebase / frontend connection — 24 October 2026

Current checkpoint: [25 October integration hardening](integration-hardening.md), following [real functionality checks](live-functionality-checks.md). AWS deployment and successful verified QA sign-in/cloud CRUD supersede the historical local-only evidence below.

Subsequent Google sign-in and additional Firebase services are tracked in [firebase-services.md](firebase-services.md). That checkpoint supersedes this phase's email/password-only configuration: Firestore, Storage and Realtime Database are now provisioned in the user-selected Belgium region, with deployed private-access rules and updated mobile configuration.

## Selected project and remote changes

The user selected **raysto-38505** and completed Firebase CLI reauthentication as their existing account. The current CLI is **15.34.1**, invoked through `npx -y firebase-tools@latest`.

Initially the selected project contained no mobile apps. Registered through Firebase CLI:

| Platform | Identifier | Firebase app ID |
| --- | --- | --- |
| Android | com.gmrt.raysto | 1:110106610042:android:0c26736df2eb8f90076ec3 |
| iOS | com.gmrt.raysto | 1:110106610042:ios:455ee13e4e8e6103076ec3 |

Downloaded app configuration directly to `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`; generated `lib/backend/firebase_options.dart` from those verified files. These are public app identifiers/configuration, not server service-account private keys. No admin key was created or downloaded. Android uses Google Services Gradle plugin **4.5.0**.

`firebase.json` enables only email/password authentication; `deploy --only auth --project raysto-38505` succeeded. No hosting, functions, Firestore, storage-rule deployment, billing upgrade or AWS deployment was performed. No real test user was created and no verification/reset email was sent by the agent.

## Connected app behavior

- Welcome and Profile offer **Use my Raysto account**. Firebase initializes on demand. The existing demo and sample accounts remain separate, including explicitly labeled practice sign-in/restaurant roles.
- Real account creation sends Firebase's email-verification link. Sign-in, verification refresh/resend and password reset use Firebase SDK APIs. No demo password or six-digit mock verification code is used in the connected flow.
- Only a verified Firebase user exchanges a fresh token with `client.firebase.login`. The resulting **Serverpod user ID**, rather than a Firebase UID or demo account ID, identifies backend actions. Serverpod tokens persist through its secure Flutter session manager; no JWT is written to DemoStore/shared preferences.
- The backend also requires verified email independently of the UI. It validates Firebase signatures and audience using the selected project and Google public certificates; sign-in does not require a service-account private key. Admin credentials remain necessary for trusted FCM sends and private storage writes.
- After authentication, the account page reads the real public restaurant catalog, menu products and the signed-in user's order history. Empty live data remains empty; illustrative demo restaurants/orders are not automatically published or imported.
- Customer-facing order creation/checkout and the broader operational demo screens are not all migrated to server data in this Firebase-first phase. The connected account view is a separate entry into the real backend; existing demo behavior is explicitly local.
- Notification permission is an explicit action after sign-in. The current FCM token is registered through the authenticated commerce endpoint; refresh tokens are re-registered. Logout unregisters/invalidate tokens before revoking/clearing the backend and Firebase sessions. This prepares device delivery, not proof that server-side FCM sending is configured.
- A generation guard and serialized credential writes prevent a delayed Firebase sign-in or backend exchange from restoring a logged-out session. UI errors do not expose provider payloads/tokens.

## Local operation

From the project root in PowerShell, start the dedicated development server:

```powershell
.\backend\backend.ps1 -Action start
```

If already in the `backend` directory, use `.\backend.ps1 -Action start`. The leading `.\` is required by PowerShell. The user starts this server, per the backend AGENTS.md. The local wrapper reads `raysto-38505` from `.firebaserc`, enables its identity provider and applies pending development migrations. No global environment or Firebase login tokens are copied into server credentials.

For an Android emulator:

```powershell
.\.tooling\flutter\bin\flutter.bat run -d <emulator-id> --dart-define=RAYSTO_API_URL=http://10.0.2.2:8080/
```

Debug mode defaults to the standard Android emulator host address. Connected **release** builds require an explicit `RAYSTO_API_URL` pointing to the actual HTTPS backend. No AWS URL was invented. For a USB-connected phone, a debug build can use `adb reverse tcp:8080 tcp:8080` with `--dart-define=RAYSTO_API_URL=http://127.0.0.1:8080/`. HTTP is restricted to local development addresses; Android cleartext allowance is debug-only. Release manifests now include Internet permission, and notification permission is requested only from its explicit UI action.

## Evidence and remaining platform setup

The connected Android preview is `dist/raysto-connected-arm64-debug.apk`, version **0.4.0**, Android versionCode **2004** (updates the prior preview's 2003), signed with the existing development certificate. It is **99,711,366 bytes**, SHA-256 `38A2EFDF02EFBD5F9FC856F383424A83CEB79E7D7A0764B2B1CC8C1C1107AC2E`. Manifest/signature verification succeeded. Flutter's engine targets ARM64; bundled dependency libraries also include other ABIs. Metadata is in `dist/connected-artifact.json`. The older `raysto-arm64-preview.apk` remains the historical 0.3 offline preview.

To try this connected preview on an ARM64 Android phone with USB debugging, install the APK, keep the local backend running and execute from the project root:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" reverse tcp:8080 tcp:8080
```

Open **Use my Raysto account**, create an account with your actual email, follow Firebase's email-verification link and return to refresh verification. No real user login was performed by the agent. This APK connects to the local computer through USB forwarding; it is not configured for AWS.

- Backend suite: **17 passed**, including missing/invalid Firebase configuration and server-side verified-email policy.
- Session coordination: **10 passed**, including late sign-in/exchange vs logout, backend failure, offline revocation, rapid duplicate taps, immediate logout during device cleanup and identity revalidation when reopening the account.
- New account UI tests cover 320px Arabic dark mode at 2x text with keyboard and real email-link verification without a demo code.
- Against the server started by the user: `/health` returned Raysto/SQL status OK; generated client catalog call returned zero published restaurants; unauthenticated order access was rejected as `ServerpodClientUnauthorized`; an intentionally invalid Firebase token was rejected as `FirebaseIdTokenVerificationException`.
- Complete mobile regression suite: **64 passed**, including the original 52 tests plus new session/UI coverage. Static analysis reports no issues; formatting is clean.
- Android x64 debug **0.4.0+4** compiled with native Firebase dependencies, installed and launched on a task-owned read-only Android emulator. The observed **Use my Raysto account** button opened the real account screen; Firebase/session initialization completed, email/password fields and sign-in/create/reset controls became enabled, and no application crash was logged. No credentials were entered and no live account was created. Screenshots were visually inspected. This validates native initialization, not a successful verified-user login or physical-device behavior.

Successful exchange for a real, verified email still needs an actual user's account and verification link; this has not been fabricated with admin overrides. FCM server delivery requires trusted service-account/IAM configuration; iOS push also requires Apple APNs credentials/capabilities. Firebase Storage bucket/IAM/billing and a deliberate image access policy remain separate; no permissive Storage rules or client role assumptions were introduced.

The Dart Firebase options include iOS, but native iOS finalization/build needs macOS/Xcode/Swift. Current Firebase plugins require iOS >=15 while the existing project still targets 13; raise the deployment target and validate generated Flutter plugin linkage on a Mac. The xcode-project-setup skill requires native Swift tooling and forbids manual pbxproj parsing, so its native setup was not bypassed on this Windows machine. The downloaded plist has not been claimed as linked into an Xcode resource phase; programmatic Dart initialization uses the generated options.

Official references: [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup), [Firebase Android setup](https://firebase.google.com/docs/android/setup), [Serverpod Firebase setup](https://docs.serverpod.dev/concepts/authentication/providers/firebase/setup), [project-ID-only verification and email validation](https://docs.serverpod.dev/concepts/authentication/providers/firebase/configuration).
