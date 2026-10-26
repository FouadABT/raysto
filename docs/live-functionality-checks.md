# Live functionality checks — 25 October 2026

Subsequent remediation is recorded in [integration-hardening.md](integration-hardening.md). The notification defect below has a code fix and focused regression coverage in 0.5.3; the native repeat remains pending because Android test devices stalled during boot. Preserve this assessment as the original observed result.

These were real interactions with the Android application, Firebase project `raysto-38505`, and `https://api.rays.to/`. No mock services, unit-test suite, production database reset, or payment simulation was used.

## Environment and scope

Android 15 (API 35), x86_64 emulator, current 0.5.2+7 source built as a debug APK with `RAYSTO_API_URL=https://api.rays.to/`. This is not a physical-device, ARM64 release, or iOS acceptance result. The emulator was stopped after testing.

The user authorized temporary QA accounts and left real Google sign-in, inbox verification, and password-reset inbox checks pending. Two isolated users were marked verified through the admin API solely to exercise verified-user functionality; a third was created through the real Firebase client registration API and remained unverified. No verification or reset emails were requested. Admin fixture verification does not establish email delivery or verification-link behavior.

## Observed results

| Check | Result | Evidence / limit |
| --- | --- | --- |
| Email/password registration | Pass — service API | Real Firebase client created the unverified account. The app registration screen was not submitted because it also sends verification email. |
| Correct email/password sign-in | Pass — Android UI and service API | Native app reached the connected account screen using Firebase identity and AWS Serverpod authentication. Both verified QA identities also exchanged successfully via API (HTTP 200). |
| Incorrect password | Pass | Firebase returned `auth/invalid-credential`; Android displayed a generic error and remained signed out. |
| Unverified account restriction | Pass — service API | AWS returned HTTP 400, `FirebaseEmailNotVerifiedException`. Unverified Firebase writes were denied. |
| Session recovery | Pass — Android UI | Force-stop/relaunch, then reopen “Use my Raysto account”: connected account recovered without re-entering credentials. |
| Logout and persistence | Pass — Android UI | Logout returned to sign-in; force-stop/relaunch and reopen remained signed out. |
| Live catalog and own orders | Pass for empty results | Android showed the actual empty catalog and order states. Each verified account's own-orders API returned HTTP 200 with an empty list. No paid/order lifecycle or populated catalog was exercised. |
| Anonymous protected orders | Pass | Actual `/commerce/myOrders` request returned HTTP 401. |
| Firestore create/read/update | Pass — real client SDK | Named database `raysto-mobile`: profile saved, server-read, locale updated, server-read again, and deleted. |
| Firestore access validation | Pass — real client SDK | Another account's read, role-field injection, and unverified-user write returned `permission-denied`. |
| Image upload/download/delete | Pass — real client SDK | Uploaded a 244,367-byte JPEG to the private QA avatar path; downloaded bytes had identical SHA-256; deletion confirmed with `storage/object-not-found`. **There is no upload screen in the connected app yet.** |
| Storage access validation | Pass — real client SDK | Cross-account read/overwrite/delete, `text/plain` upload, and unverified upload returned `storage/unauthorized`. File-size boundary behavior was not exercised in this run. |
| Realtime Database presence | Pass — real client SDK | Server-timestamped online presence saved/read/deleted. Cross-account read and invalid/unverified writes were rejected. No app presence UI exists yet. |
| Notification permission and registration | Pass — Android UI + SQL observation | Native permission dialog displayed; permission granted; one real QA device-token row appeared in Raysto PostgreSQL. This does not prove delivery. |
| Notification unregister after app restart | **Fail — cleanup defect** | After registration, app restart and logout, one old device-token SQL row remained. Logout invokes Firebase token deletion, but the token registered with SQL is retained only in `LiveRuntime._registeredToken` memory. On restart that field is empty, so SQL unregister is skipped. The QA row was explicitly deleted during cleanup. No fix was made as part of this functionality assessment. |

## Pending or unavailable

- Google account selection and actual Google sign-in: pending by user choice.
- Verification-email delivery/link completion and password-reset delivery/link completion: pending by user choice.
- Upload/profile/presence interactions inside the native connected UI: these screens are not implemented; SDK results above do not certify a user-facing upload flow.
- Actual FCM push delivery: server Firebase IAM credentials are not configured. Registration alone is insufficient.
- PayPal sandbox checkout, buyer approval, capture, webhook processing, and refunds: sandbox credentials and a complete connected order flow are still required. No financial transaction was attempted.
- Published restaurant/menu management, ordering, staff operations, cross-account order ownership with populated orders, offline/network interruption, physical-device behavior, and iOS: not exercised in this run. Existing demo flows do not prove live backend integration.

## Cleanup and production checks

Run identifier: `qa-live-cc73c0ca2314`. All three temporary Firebase users were deleted and an admin lookup returned zero remaining users. Real client reads confirmed the QA Firestore document, avatar object, and presence connection were absent. The two corresponding SQL auth users were deleted through their exact Firebase identifiers; their auth relationships cascade. Final QA identity and device-token counts were zero. Temporary local credentials were deleted and the emulator's app data cleared.

Only isolated QA data was changed. No backend deployment, restart, rule change, or Awhar mutation was performed. Raysto service remained active and public `/health` returned HTTP 200. Awhar remained PID 2221016, started 24 October 2026 at 15:24:10 UTC; its Nginx configuration checksum remained unchanged.

## Screenshots

- Connected native account (local artifact; not distributed)
- Recovered session after app restart (local artifact; not distributed)
- Signed out after a further app restart (local artifact; not distributed)

## Recommended next work

First persist and unregister the device-token registration safely across restarts and account changes, then repeat that exact native flow. Next implement a connected profile/avatar upload screen using the already working private Storage and Firestore services. Complete real Google/inbox checks and provide scoped server Firebase and PayPal sandbox configuration before claiming push delivery or payments work end to end.
