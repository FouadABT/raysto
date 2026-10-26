# Integration hardening — 25 October 2026

Source version **0.5.3+8**. This checkpoint follows [live functionality assessment](live-functionality-checks.md) and addresses the notification cleanup defect found there. It concerns the existing connected foundation; it does not migrate demo ordering/staff screens into live product features.

Subsequent configuration: [Firebase server verification](firebase-server-verification.md) supersedes the missing Firebase server-credential boundary below. AWS FCM authorization, private Storage access and recurring dispatcher configuration now pass. [PayPal sandbox setup](paypal-sandbox-status.md) also supersedes the missing PayPal credential boundary: server credentials/webhook and checkout connection checks now pass. Native notification acceptance, Google/inbox/iOS and buyer-approved payment capture/webhook remain pending; the code-test and native evidence in this document is unchanged.

## Fixes

- Persist the backend device-token owner and explicit notification opt-in in platform secure storage, scoped to the backend URL. Logout can unregister the token after a process restart.
- Serialize registration, rotation and cleanup. Account-generation guards reject late permission responses and queued token callbacks after logout. Permission prompts do not hold up logout.
- Listen for token rotation before enabling native auto-init or requesting the current token, so rotation during those calls is not lost.
- Persist the token before sending registration to AWS. A timeout or process exit after server acceptance therefore does not lose the cleanup reference.
- On logout, mark pending cleanup disabled and invalidate the Firebase device token even when SQL unregister is unavailable. A later login by its owner retries cleanup without restoring notification opt-in. Another account obtains a fresh native token rather than inheriting that registration. A row that cannot be removed while its owner is offline can remain until owner retry or the existing server outbox removes an FCM `UNREGISTERED` token; offline logout cannot guarantee immediate SQL cleanup.
- Put cleanup in the session coordinator, so future sign-out callers cannot accidentally bypass it by omitting a screen callback.
- Revoke a restored backend device session before replacing it during a fresh Firebase identity exchange, avoiding normal reconnects accumulating unused refresh sessions.
- Key the live workspace by the Serverpod identity, preventing state from being reused between account identities.
- Disable native FCM auto-init by default on Android/iOS. Android backup is disabled to avoid restoring secure-storage ciphertext without its device key. iOS Google return URL is registered in Info.plist, and FCM token retrieval checks that APNs is ready.

## Verification

The focused session, notification, and connected-account regression run passed **26 tests**, including cold-start logout, pending permission prompts, in-flight registration, token rotation, rotation during token retrieval, offline cleanup retry, cross-account token replacement, late authentication responses, and verification UI. Static analysis of the affected integration files passed. This is not a claim that the production database integration-test harness was run.

The following real service checks were repeated with isolated temporary QA accounts against `raysto-38505` and `https://api.rays.to/`:

- Verified Firebase identity exchange succeeds; unverified identity is rejected with `FirebaseEmailNotVerifiedException`.
- Expired access tokens are rejected. Real refresh-token exchanges return new access tokens; both QA accounts can subsequently read their protected own-orders lists (HTTP 200). Anonymous access is HTTP 401.
- Private JPEG upload/download yields matching SHA-256; deletion is confirmed. Cross-account and unverified uploads, reads and mutations are rejected.
- Named Firestore `raysto-mobile` saves, reads, updates and deletes the personal document; invalid fields and other-account access are rejected.
- Realtime Database presence saves, reads and deletes; invalid/unverified writes and other-account reads are rejected.

The corrected Android release builds succeeded for ARM64 and x86_64. The phone preview is raysto-aws-arm64-preview.apk (local artifact; not distributed): version 0.5.3, Android code 2008, 26,320,119 bytes, SHA-256 `A0B8BE3FEE3225958CFF445B5FEB37BCA52C66D08C2899C59EF9DFCA0805F8A7`. Manifest identity, SDK 24/36, ARM64 ABI and the registered development signing certificate were verified. The compiled AOT binary contains the new secure notification-registration code. This remains a development-signed preview, not store signing.

**Native acceptance remains pending.** Both the pre-existing read-only Android 15 AVD and a fresh task-owned AVD stalled during Android boot/app installation. Android had not completed boot, UI automation failed before a usable app screen, and the native restart/logout flow could not be repeated. No new native pass or screenshots are claimed for 0.5.3. The earlier 0.5.2 observations remain in the historical assessment. This environment problem does not turn the focused regression checks into device acceptance. Neither ARM64 physical-device nor iOS behavior is established.

## Cleanup and service health

Run `qa-live-e165830c92b6`: all three Firebase QA users were deleted, with zero returned by admin lookup. Client reads confirmed the QA document, avatar and presence connection absent. The two exact SQL QA auth identities and their cascading auth/session records were deleted; final matching identity and push-row counts were zero. The local file containing temporary QA passwords/tokens was deleted. All task-owned emulators were stopped; shared AVD data was not wiped.

No Firebase rules, IAM credentials, AWS deployment, service configuration or Awhar records were changed. Raysto stayed active with public health HTTP 200. Awhar remained PID 2221016 with its original 24 October 2026 15:24:10 UTC start time, and its Nginx checksum matched the deployment baseline.

## External configuration still needed

AWS configuration was read only for public identifiers and presence flags: Firebase identity is enabled; project and bucket match Raysto. Firebase server IAM credentials and PayPal sandbox Client ID, Secret, Merchant ID and Webhook ID are not installed. This is a missing configuration boundary, not a failed Firebase mobile upload or sign-in. The user requested [step-by-step credential instructions](server-credentials-setup.md); no service-account private key was generated or copied by this task.

Real Google-account selection, verification inbox/link completion and password-reset inbox/link completion remain pending by the user's choice. iOS native dependency/resource linkage, minimum deployment target, signing, APNs and device validation require the Mac/Xcode workflow. The Info.plist changes alone do not complete iOS setup.

Dedicated avatar/profile/presence screens and the complete connected order/payment/staff flows remain product work. Actual push sending/display and a PayPal buyer-approved sandbox capture/webhook cycle must be tested after credentials are supplied. No real-money transaction was attempted.
