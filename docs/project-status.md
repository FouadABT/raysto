# Project status

Snapshot: **27 October 2026**. Android candidate `0.11.5+2014`; backend/console patch `0.11.6`. The [candidate report](release-candidate-2026-10-27.md) records current checks and blockers; [Road to 10/10](road-to-10-10.md) preserves earlier evidence and the recovery procedure. The connected console is at [ops.rays.to](https://ops.rays.to/ops).

| Area | Implemented and observed | Remaining acceptance |
| --- | --- | --- |
| Conversations | Native visit/order rooms, audience labels, host authority, preferences, replies, unread cursors, encrypted local drafts, pinned Menu/Order/Bill, private help and authorized event delivery. Grouped service/payment activity, expiry labels and reviewed question retry are implemented. Two diners and one waiter exchanged the same persisted message; outsider access was denied and retries deduplicated. | Physical-device multi-person journey and visual/device review of operational cards. |
| Revocation and live delivery | Active-stream access ended and new reads were denied within 2.074 seconds in one QA check. Public first-frame checks took 1.469 and 1.642 seconds after correcting buffering. | Load measurements and broader interruption/device coverage. These timings are individual observations. |
| Gemini | Earlier real tools produced a $27 vegetarian basket under $30, unknown-allergen caveats and two frozen $13.50 shares; the host submitted the order. A prior payment-status run completed via REST. Bounded streaming, complete-response validation, isolated generation connections and useful error recovery are now implemented. | **Current blocker: Google HTTP 429 `RESOURCE_EXHAUSTED`.** Full fixed evaluation, conversational MCP acceptance and pilot observations remain pending. Deadline/capacity failures stay in the evidence. |
| PayPal | Real Sandbox approval handoffs were created for a $13.50 share and a fresh $1 diagnostic checkout. Both remain unapproved and are locally cancelled. Generalized allocations, capture, refunds and reconciliation exist. | Two buyer approvals, captures, matching ledger/webhooks, partial refund and interrupted-return recovery. No capture is claimed. |
| PayPal MCP | Official pinned self-hosted server, two read-only tools, isolated stdio and labelled fallback. The deployed Dart reader validated the fresh USD 1.00 order in 2.737 seconds with no fallback or ledger mutation, then the guarded API cancelled the probe. [Evidence](paypal-mcp.md). | Hosted endpoint remains blocked. Gemini capacity blocks complete chat acceptance; refund-detail acceptance awaits an actual refund. Upstream dependency advisories remain documented. |
| Restaurant console | Firebase session sign-in, authorized shared records, floor plan, AG Grid, three AG Studio widgets and a server assistant. Manager request selected the bill-requested/unpaid table and explained USD 27. Saved attention filter, selected table, Payments tab and authorized room recovered after reload. | Physical-device coordination and AG evaluation license extension beyond December 10. |
| Existing business modules | Catalogue, prices/orders, dining/reservations, fulfillment, support/privacy, media import, notifications, marketplace/subscription source and permission controls remain available. | Live marketplace approval, commercial billing, transactional email, phone Google sign-in/guest admission/FCM and complete business acceptance. |
| Deployment | Isolated Raysto backend/console releases on AWS with health checks, retained rollback releases and database backups. Awhar service/configuration and PostgreSQL major version preserved. Live money disabled. | Off-host restore rehearsal, alert routing, clean-checkout reproduction and final reviewer release. |

## Validation evidence

The October 27 change set passed **20 distinct selected checks**: seven Gemini transport, three assistant-fact, eight isolated conversation/domain and two Flutter room tests. Changed-source analysis, TypeScript, Linux backend/console and Android compilation passed. The narrow-screen room check includes 2× text and an open keyboard. Android is development-signed for direct testing; physical-device and iOS validation are separate. Earlier targeted runs are retained in [Road to 10/10](road-to-10-10.md); counts are not combined into a full-suite claim.

Historical evidence is retained in [mobile integration](mobile-backend-integration.md), [art direction](mobile-art-direction.md), [web prototype](web-phase-1.md) and [web design](web-creative-direction.md). Their earlier scope statements are not current release status.

## Before submission

- Resolve or recover from the Google capacity response, then complete conversational MCP acceptance; the direct MCP order read passed.
- Complete the two-buyer Sandbox journey once the owner supplies the local credentials-file path or participates in approval.
- Run the fixed AI evaluation and physical-device acceptance on the actual candidate.
- Record three small restaurant/diner pilot sessions with permission; no findings or adoption metrics exist yet.
- Extend the AG trial through December 15, reproduce from clean source, and publish the exact versioned APK/checksum with the final release tag.

The implementation is a connected integration candidate. It is not described as production-secure, approved for live money, or guaranteed to win.
