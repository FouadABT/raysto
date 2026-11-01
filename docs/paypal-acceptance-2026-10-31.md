# PayPal Sandbox acceptance — 31 October 2026

Two live sessions against production (`api.rays.to`, backend 0.12.0; the last AI checks ran on 0.12.1 and 0.12.2) on the single-merchant Sandbox restaurant (id 3, USD). Two separate PayPal Sandbox personal buyers approved every payment on PayPal's own Sandbox checkout page in a real browser. Only virtual Sandbox funds moved.

The script that ran the sessions is `tool/live_session_qa.cjs` (kept out of git because it reads the private QA and buyer logins). It stores every request key, so a rerun resumes and never creates a duplicate. Buyer logins, tokens and screenshots of PayPal's pages (which show buyer emails) are not in the repository.

## Session 1 — pickup and counter

| Journey | What happened | Result |
|---|---|---|
| Pickup, buyer 1 | Customer account ordered for pickup ($12.00, ticket #1), paid with PayPal, returned to `api.rays.to/payments/return` ("Payment received. Thank you.") | Checkout 5 completed. Order 3 paid, pickup code issued. Capture `633829727B675370M` |
| Counter, buyer 2 | Owner rang up a counter sale for "Walk-in QA" ($24.00, ticket #2). Buyer 2 paid through the PayPal QR link | Checkout 6 completed. Order 4 paid and auto-accepted for the kitchen (origin counter). Capture `4C048952Y13801205` |

## Session 2 — split bill, partial refund, AI checking PayPal

| Journey | What happened | Result |
|---|---|---|
| Equal split, buyers 1 and 2 | Table visit 2 had a $27.00 dine-in bill. Each diner called `room.split.equal` and got the same frozen plan (plan 1), then paid their own $13.50 share | Checkouts 7 and 8 completed. Order 2 paid, bill remaining $0.00, settled $27.00. Captures `4MG67343RS1841023` and `47E23175WJ603464A` |
| Partial refund | Owner signed in again, passed `identity.stepUp`, refunded $5.00 of the pickup capture against order 3 | Refund completed at PayPal as `2J851836BE9699524`. Order 3 is `partiallyRefunded` |
| AI: unresolved payments and a PayPal check (run 22) | Manager asked: "Are any PayPal payments unresolved right now? Then check with PayPal whether the payment for checkout 5 really went through." | Tools: `unresolved_payments` (ledger, 12 ms), then `payment_status` (PayPal MCP over stdio, 5.1 s). Answer: "No PayPal payment needs attention… PayPal reports COMPLETED for checkout 5: USD 12.00. Source: PayPal MCP." |
| AI: refund check (runs 23–24) | Manager asked whether the $5 refund on checkout 5 completed at PayPal | `payment_status` read the refund through PayPal MCP: COMPLETED, USD 5.00. On 0.12.2 (run 24) the answer reads "PayPal reports COMPLETED for refund 1 on checkout 5: USD 5.00. Source: PayPal MCP." |

### Webhooks

Every event in these sessions arrived at `https://api.rays.to/api/v2/webhooks/paypal-single-sandbox`, passed signature verification and was processed exactly once:

| Event | Count |
|---|---|
| `CHECKOUT.ORDER.APPROVED` | 4 |
| `PAYMENT.CAPTURE.COMPLETED` | 4 |
| `PAYMENT.CAPTURE.REFUNDED` | 1 |

### Fixes found by these sessions

- **AI answer (0.12.1).** In run 21, the answer reported only the PayPal check and dropped the "nothing unresolved" finding from the first tool. Fact sentences from every tool in a run are now kept in order.
- **AI refund answer (0.12.2).** Run 23 reported "COMPLETED for checkout 5: USD 5.00", which could be read as a $5 payment. A refund check now names the refund ("refund 1 on checkout 5").
- **Console (0.12.1).** While loading, the Payments tab showed $0.00 totals, which looked like no money had been taken. It now says it is loading. The Orders grid shows a loading overlay instead of "No Rows To Show".

## Owner console

The console at `https://ops.rays.to/ops` (0.12.0, then 0.12.1) showed the same records to the QA owner:
- **Overview:** two orders today, $36.00 collected by PayPal, and the counter/pickup channel mix.
- **Orders grid:** each order opens a panel with its lines, the PayPal capture id and the next step.
- **Payments:** captures, cash, refunds and attempts in separate tabs, with the $5.00 refund on the pickup capture.

## Not covered by these sessions

- Physical-phone runs of the Android build (0.12.1, code 2015). The sessions drove the same backend commands the app sends.
- Delivery, iOS, and live (non-Sandbox) PayPal.
