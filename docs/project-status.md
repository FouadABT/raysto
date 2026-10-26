# Project status

Snapshot: **26 October 2026**. Mobile `0.10.0+2012`; latest recorded deployed backend `0.9.4`; separate web prototype `0.1.0`.

Repository preparation did not rerun application tests, build an APK, deploy services or approve a payment. Source, observed execution and planned work are distinct below.

| Area | Evidence / boundary |
| --- | --- |
| Connected mobile/backend | Screens and commands cover discovery, menu/cart/quote/order, visits, service, bills, reservations, kitchen/couriers, management, support and privacy. Not every combination has device acceptance. |
| Identity | Selected live temporary-account and revocation checks recorded. SQL memberships govern business access. Google account-picker/inbox flows and guest device attestation still need acceptance. |
| Operations | Recorded live QA includes menu/quote/order, cash/idempotency, kitchen/pickup, visit privacy/invitations/service/closure/reset. Selected evidence, not exhaustive concurrency coverage. |
| AI/files | Recorded quarantine/sanitization checks and real Gemini draft generation. Publication requires review. Multi-person conversational AI is not implemented. |
| PayPal | Sandbox order creation and approval handoff observed. Capture/reconciliation and v2 allocations/refund source exist. Complete real buyer approval → capture → partial refund → verified webhook acceptance is pending. |
| Marketplace/billing | Source exists; live approval, merchant capabilities, separate subscription credentials/plans and commercial configuration are pending. Live payments remain disabled. |
| Notifications | Inbox/outbox and FCM source exists. Physical-device push receipt and transactional email acceptance are pending. |
| Mobile design | Recorded 17 focused checks, clean analysis, nine inspected widget renders and an Android build for the art release. Full assistive-technology/device review remains separate. |
| Web / AG Grid | Browser-local Next.js prototype with AG Grid Community and recorded prototype checks. No connected restaurant console or AG Studio yet. |
| Conversations | Existing customer/staff support thread. Multi-diner visit rooms, explicit audiences, action cards and chat-grade delivery/reconnect are proposed work. |
| Release hardening | iOS build, store signing, complete device review, off-host restore rehearsal, load measurements and alert routing remain pending. |

## Recorded validation

The integration release records **22 backend checks** and **50 mobile checks**. The later art release records **17 focused checks**. These describe different runs and should not be added into one claimed suite. [Integration report](mobile-backend-integration.md) · [Art report](mobile-art-direction.md).

The web records six domain tests and browser coverage in [web phase 1](web-phase-1.md) and [web creative direction](web-creative-direction.md). Raw local logs and private provider records are not published. Reproduction commands are in [setup](getting-started.md) and [CONTRIBUTING.md](../CONTRIBUTING.md).

## Submission gates

- Complete the connected table-room journey across two diners and one staff session.
- Demonstrate real Sandbox approval, capture, recovery, partial refund and verified webhook delivery, separately from UI fixtures.
- Connect the restaurant workspace to the same records before presenting it as live AG Grid/AG Studio operations.
- Verify a clean checkout and the exact reviewer build; publish a versioned artifact/checksum when ready.
- Record usability observations without inventing adoption, performance or business metrics.
- Keep access available through judging; recheck external service/trial eligibility before submission.

No claim of production readiness, guaranteed contest score or live-money acceptance is made.
