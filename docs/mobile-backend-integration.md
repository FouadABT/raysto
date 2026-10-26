# Mobile integration and AWS test release â€” 26 October 2026

The owner authorized mobile/backend integration, deployment and necessary tests. The earlier validation deferral is lifted for this release. The separate web application is unchanged.

## What is connected

The Flutter connected workspace uses authenticated `/api/v2` commands and queries at `https://api.rays.to/`, alongside the existing generated Serverpod identity and Sandbox APIs. Its screens cover discovery, menus/modifiers, saved baskets, quotes, order history, table QR entry, private visits, service requests, shared bills, reservations, waitlist, kitchen, couriers, team invitations, restaurant settings, menus/drafts, media upload, AI review, reports, support, profiles, privacy requests and account security.

Owner/manager review responses and a separately gated platform administration workspace are included. All 68 command families have mobile entry points. The administrative workspace does not confer privileges: the backend UUID allowlist and MFA are enforced on every administrative request. No account was made a platform administrator during this deployment.

The API adapter handles current Firebase proof, Serverpod session refresh, App Check headers, bounded requests, pagination and durable idempotency keys for uncertain outcomes. Logout prevents late requests from restoring an old account. Guest records require explicit account claiming; they never become staff permissions. Offline demo data stays in its separate local world.

Firebase TOTP enrollment/sign-in support is wired into account security and enabled in the selected Firebase project. The final APK uses package `com.gmrt.raysto`, version `0.9.0+2011`, with the existing development signing certificate for direct testing. Store signing and an iOS build are separate release work.

## AWS deployment

- Active backend: `/opt/raysto/releases/0.9.4-20261026`, service `raysto.service`, public API `https://api.rays.to/`.
- Backend archive SHA-256: `32dd27dfd54e9de75779521a2c0add5300e068bbac9ca9ecd1b6ff9eab7f51a5`.
- Migrations `20261025161248873` and `20261025162915326`, tenant constraints and legacy backfill applied to `raysto_production`. The backfill found no existing completed receipts to import.
- v2, guests and one bounded worker enabled. Registered App Check is in observation mode; guest admission requires valid attestation. Billing enforcement remains off. PayPal remains Sandbox; live payments are disabled.
- Raysto's private scanner binaries/signatures and resource limits are isolated. The deployed shared PostgreSQL 16 cluster, global Dart SDK and Awhar service/configuration were preserved.
- Backups and automatic application rollback accompany deployment. Local and public `/ready` passed. Readiness checks schema/configuration, not every external provider.
- Awhar remained PID `2327174`; its Nginx site SHA-256 remained `057200aeaa0026d4b3df9c62a83446471a33c23b65b07bdc659397151969cef1` across the rollout.

The approved Firebase custom runtime role has only identity lookup and user deletion permissions. JSON server credentials remain outside the app/source. See [operations](backend-v2/operations.md) for exact paths, schema-difference notes and recovery steps.

## Observed verification

| Check | Result |
|---|---|
| Full mobile analysis before final additions | No issues |
| Focused analysis of final connected screens | No issues |
| Backend final analysis | No issues |
| Mobile API/session/payment/notification checks | 48 passed, plus 2 guest recovery/logout checks |
| Backend business/SQL checks | 19 passed, plus 1 REST-proof isolation check and 2 image-quarantine checks; 22 distinct checks |
| Final image/money/input unit file | All 13 passed, including the 2 added image cases |
| Schema and supplemental constraints | Installed in a disposable database on the isolated local test cluster; removed afterward |
| Linux executable | Compiled and deployed successfully |
| Android release APK | Final 64 MB APK installed in the disposable x64 emulator; sign-in/account-creation screens rendered. Full interaction acceptance was curtailed by emulator System UI/Messages ANRs; see `qa/2026-10-26/release-artifacts.json` |

Actual HTTPS checks used temporary verified Firebase accounts and a clearly named QA restaurant:

1. Firebase sign-in and Serverpod session exchange succeeded.
2. Restaurant settings and a published menu were read back; a customer could not open restaurant management.
3. Saved cart â†’ authoritative quote â†’ order submission preserved the EUR 12.99 total.
4. Staff-recorded test cash collection produced a receipt; repeating the same request did not collect twice. No external money moved.
5. The order progressed through acceptance, preparation, item-level kitchen readiness, collection and completion.
6. Public QR resolution revealed table identity without revealing an occupied visit. A separate invitation admitted a participant. Service acknowledgement/completion, visit closure and table reset succeeded.
7. A valid private PNG upload passed quarantine, became a sanitized JPEG, and downloaded with authentication. Anonymous download was rejected. The malformed PNG fixture reached `rejected` with reason `invalid_file` after the corrected worker processed it.
8. Gemini returned one structured draft through the EU endpoint. Missing confirmation was rejected; explicit QA approval created an unpublished draft and left the live menu unchanged.
9. A completed-order customer review and the manager response were persisted. A restaurant owner was denied all tested platform administrator queries.
10. The existing standalone PayPal test created a real USD 1 Sandbox order with a PayPal checkout URL. Retry reused the same provider order; another account could not read the receipt. The order remained unapproved and uncaptured.
11. Authenticated HTTP events delivered a heartbeat with the forwarded Firebase proof. The current HTTP adapter can buffer small events until its bounded response ends; mobile screens refresh their authorized snapshots every 20 seconds while visible. Low-latency web streaming needs separate acceptance before the web phase.
12. Revoking a backend session blocked the older RPC routes immediately. Deleting the temporary Firebase identity also blocked those routes without requiring a prior v2 request.

Cleanup completed: the QA restaurant is unpublished, all temporary Firebase accounts were deleted, and protected access using the deleted identities was rejected. The clearly labelled restaurant, order, test cash receipt and audit records remain for traceability. No PayPal buyer approval or capture occurred.

Machine-readable evidence is in platform-live.json (local artifact; not distributed) and google-services.json (local artifact; not distributed). These distinguish successful checks from intermediate failures that led to fixes. The REST header propagation issue, incorrect Gemini regional hostname and malformed-image retry behavior were corrected during live validation.

## Try the mobile app

1. Install the Android test APK (local artifact; not distributed) on an Android 7.0+ device. It is signed with the same development certificate as the earlier test app; retain existing data unless Android reports an incompatible signature.
2. Sign in with a verified account to enter the connected workspace. Choose the explicit offline demo only when you want illustrative local records.
3. Open **Your restaurants â†’ Create my restaurant**. Configure the address, contact, hours, services and your actual tax/pricing policy; add dishes and publish when ready. Demo restaurants are not imported into real accounts.
4. Test customer ordering and staff operations using separate accounts and an invitation. Accept invitations manually from **Your account** while SES email is unconfigured.
5. For an actual PayPal page, use **Your account â†’ Test PayPal Sandbox**. This separate fixed-amount test uses the already configured single-merchant Sandbox integration. Approval requires a PayPal Sandbox buyer account; the restaurant marketplace flow has separate prerequisites below.
6. Use account security to enroll a TOTP second factor before ownership, payment-setting or administrator changes. No passwords, MFA codes or service keys should be put in source files.

## What still depends on external setup or physical-device acceptance

- **Restaurant PayPal marketplace:** partner/platform credentials, partner attribution and webhook configuration, eligible seller onboarding and appropriate PayPal approval. Existing single-merchant Sandbox credentials cannot establish marketplace readiness.
- **Subscriptions:** a separate billing merchant, its credentials/webhook, matching PayPal plans and explicit commercial prices/commissions. No trial, tax rate or subscription price was invented.
- **Transactional email:** Raysto-scoped SES sending credentials and verified sending identity. Manual invitation codes remain usable.
- **Phone acceptance:** Google account chooser, email inbox links, real push delivery, camera permissions/QR scanning, GPS, App Check guest admission and buyer approval/capture/refund/webhook still require real-device/provider completion. API and widget tests do not prove those flows.
- **Production hardening:** encrypted off-host backup destination and restore rehearsal, load measurements, operator identity enrollment and alert routing. No iOS binary was built on Windows.

This is a deployed integration test release with concrete passing evidence. It is not a claim that every acceptance scenario is complete or that live-money production operation is approved.
