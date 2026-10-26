# Project status

Snapshot: **26 October 2026**. Android candidate `0.11.0+2013`; deployed backend `0.11.4`; console `0.11.2` at [ops.rays.to](https://ops.rays.to/ops). [Road to 10/10](road-to-10-10.md) records the detailed evidence, deployment boundaries and recovery procedure.

| Area | Implemented and observed | Remaining acceptance |
| --- | --- | --- |
| Conversations | Native visit/order rooms, audience labels, host authority, preferences, replies, unread cursors, encrypted local drafts, pinned Menu/Order/Bill, private help and authorized event delivery. Two diners and one waiter exchanged the same persisted message; outsider access was denied and retries deduplicated. | Physical-device multi-person journey; richer grouped operational cards. |
| Revocation and live delivery | Active-stream access ended and new reads were denied within 2.074 seconds in one QA check. Public first-frame checks took 1.469 and 1.642 seconds after correcting buffering. | Load measurements and broader interruption/device coverage. These timings are individual observations. |
| Gemini | Real tools produced a $27 vegetarian basket under $30, unknown-allergen caveats, and two frozen $13.50 shares. The host explicitly approved/submitted the order. After correcting provider reuse and avoiding a redundant model round, a payment-status run completed with the actual provider status. | Fixed evaluation set, multilingual/conflicting/stale requests and pilot observations. Earlier deadline failures remain part of the evidence. |
| PayPal | One reserved $13.50 checkout opens a real Sandbox approval handoff. REST reports `PAYER_ACTION_REQUIRED`. Generalized allocations, capture, refunds and reconciliation exist. | Two buyer approvals, captures, matching ledger/webhooks, partial refund and interrupted-return recovery. No capture is claimed. |
| PayPal MCP | Official pinned self-hosted server, two read-only tools, isolated stdio and labelled fallback. The deployed Dart client validated a real USD 13.50 order via MCP in 3.526 seconds; no ledger mutation. [Evidence](paypal-mcp.md). | Hosted endpoint remains blocked. Chat acceptance encountered Gemini timeouts; refund-detail acceptance awaits an actual refund. Upstream dependency advisories remain documented. |
| Restaurant console | Firebase session sign-in, authorized shared records, floor plan, AG Grid, three AG Studio widgets and a server assistant. Manager request selected the bill-requested/unpaid table and displayed its tool result and USD 27 explanation. Saved attention filter, panels and conversation recovered after reload. | Physical-device coordination and AG evaluation license extension beyond December 10. |
| Existing business modules | Catalogue, prices/orders, dining/reservations, fulfillment, support/privacy, media import, notifications, marketplace/subscription source and permission controls remain available. | Live marketplace approval, commercial billing, transactional email, phone Google sign-in/guest admission/FCM and complete business acceptance. |
| Deployment | Isolated Raysto backend/console releases on AWS with health checks, retained rollback releases and database backups. Awhar service/configuration and PostgreSQL major version preserved. Live money disabled. | Off-host restore rehearsal, alert routing, clean-checkout reproduction and final reviewer release. |

## Validation evidence

Focused checks comprised **36 selected backend tests**, followed by **one event-transport and two factual-summary tests**, plus **six selected Flutter tests**. These are distinct runs, not one full-suite total. The narrow-screen room check includes 2× text and an open keyboard. TypeScript SDK/console and Linux backend/console compilation passed. Android candidate is for direct testing with development signing; iOS is separate.

Historical evidence is retained in [mobile integration](mobile-backend-integration.md), [art direction](mobile-art-direction.md), [web prototype](web-phase-1.md) and [web design](web-creative-direction.md). Their earlier scope statements are not current release status.

## Before submission

- Complete the two-buyer Sandbox journey and conversational payment-status acceptance; the direct MCP order read passed.
- Run the fixed AI evaluation and physical-device acceptance on the actual candidate.
- Record three small restaurant/diner pilot sessions with permission; no findings or adoption metrics exist yet.
- Extend the AG trial through December 15, reproduce from clean source, and publish the exact versioned APK/checksum with the final release tag.

The implementation is a connected integration candidate. It is not described as production-secure, approved for live money, or guaranteed to win.
