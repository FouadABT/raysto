# Acceptance matrix

This is the complete target matrix, not a blanket pass report. The owner subsequently authorized targeted validation and isolated deployment. Selected execution evidence is in [current status](../project-status.md) and [Road to 10/10](../road-to-10-10.md); unrecorded scenarios remain pending. Static analysis and source generation are not substitutes for runtime evidence.

Automated definitions added: `test/unit/platform_invariants_test.dart`, `test/integration/platform_domain_test.dart`. Existing isolated commerce, concurrency and Sandbox definitions remain. Additional provider/device and operational scenarios below are explicit release evidence requirements rather than fabricated automated coverage.

| Gate | Procedure | Required evidence |
|---|---|---|
| Tenant isolation | Attempt cross-tenant table/menu/order/charge/file/stream/report/AI IDs using each role | 403/404; no foreign row, object bytes or event details; SQL constraints reject invalid relationships |
| Role boundaries | Deactivate waiter/kitchen/courier during a command/stream; assign another courier's delivery | Immediate command denial and stream recheck; kitchen receives no address; courier receives only own assignment |
| Guest recovery | Restart with stored credentials; claim with both-session proof; replay claim; attempt privilege transfer | Personal ownership preserved once; guest revoked; no transferred team permissions |
| QR privacy | Resolve a printed QR while another party is seated; attempt direct join and bill reads | Only public table identity; seating/invitation required; no participant/bill disclosure |
| Concurrent seating | Commit two independent starts, moves, booking holds and waitlist offers for one table | Exactly one eligible winner; no overlapping active visit/offer; explicit reset enforced |
| Pricing | Required modifiers, zero/large prices, inclusive/exclusive tax, rounding, coupon caps, stock and paused service | Server totals match integer expectations; stale quote rejected; snapshot unchanged after menu edits |
| Payment recovery | Lose create/capture response; repeat request; deliver duplicate/out-of-order webhooks; crash before acknowledgement | One settled allocation/capture; same provider request ID; no replacement charge; uncertainty retains reservation |
| Split bills | Competing diners, selected unit quantities, custom amounts, new round during pending attempt | Single unresolved shared checkout; no double settlement; new round outside frozen attempt |
| Refunds and reversals | Partial refunds, simultaneous refunds, cancelled order credits, failed refund, dispute/reversal evidence | Captured unrefunded amount never exceeded; no recreated cancelled debt; commission adjustment once |
| Operations | Complete dine-in pay-at-end, prepaid pickup and restaurant delivery; reject/cancel/resolve issues | Correct role/state transitions; kitchen readiness never marks payment paid; address/location expire appropriately |
| Subscription | Seller approval, renewal, failure, grace expiry, cancellation, duplicate events | Verified history; configured grace enforced; no duplicate subscription; settlement/refund access remains |
| AI/files | Malformed JPEG/PDF, oversized pages/pixels, malware, prompt injection, invented product, cancelled/stale proposal, quota exhaustion | Quarantine and fail-closed handling; no unauthorized tools/data; no automatic publication or basket order |
| Recovery | Crash leased worker; replay dead job; restore backup into isolated DB; deploy rollback | At-least-once handling without financial duplication; evidence survives; no Awhar changes |
| Real Sandbox | Onboard approved test seller; buyer sees PayPal; approve, capture, partially refund; deliver verified webhook | Provider IDs, amounts, currencies and timestamps reconcile; screenshots and sanitized receipts recorded separately |
| Native devices | Google sign-in, App Check, upload, FCM delivery, app handoff and deep link on actual device | Device evidence; inbox/Google checks previously deferred are not silently counted as passed |

## Evidence record

For each scenario record: source artifact hash, isolated environment/database, actor roles, setup, input/request IDs, expected result, actual result, sanitized SQL/provider evidence, reviewer and date. Do not record credentials, account passwords or raw identity tokens. Any failure blocks the relevant release gate.

## Execution order

Validate SQL on the isolated cluster; run focused unit then integration/concurrency definitions; add missing automated cases where failures or complexity justify them; perform Sandbox/provider/device checks; test recovery; build the deployment artifact; then review activation. Keep source completion, verified functionality and production activation as separate statuses. Never run acceptance tests against Awhar or a shared production database.
