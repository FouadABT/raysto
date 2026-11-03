# Backend 0.14.0 to 0.14.3, console 0.16.0 to 0.16.5 (3 November 2026)

The back office: eight money agents, PayPal Payouts, Invoicing and disputes through the PayPal MCP server, and the records they work on. Deployed to `api.rays.to` and `ops.rays.to` on 3 November; the design and the contract between backend, console and app are in [back-office-design.md](back-office-design.md).

## Backend 0.14.0 (03:19 UTC)

- **Migration `20261103014213036`**: twelve new tables (`raysto_staff_shift`, `raysto_payout_batch`, `raysto_payout_item`, `raysto_catering_request`, `raysto_complaint`, `raysto_dispute_case`, `raysto_supplier`, `raysto_stock_item`, `raysto_supply_delivery`, `raysto_expense`, `raysto_daily_close`, `raysto_customer_profile`); nothing dropped or altered. `AllocatePayment` gains an optional `tipMinor` (no table change).
- **Agents**: close, payroll, catering, complaints, disputes, supplies, expenses, loyalty, and the copilot's roster proposal (`shift.plan`). Each registers its own `AgentCommand`s in the approval layer; money commands (`payout.send`, `invoice.send`, `payment.refund`, `dispute.accept`) need the identity step-up. Owner limits in settings `autonomy` (`refundsMaxMinor` ≤ 5000, `refundsPerDay` ≤ 20, `remindersAuto`), `closeAt`, `tipPolicy`.
- **PayPal**: Payouts (`/v1/payments/payouts`, create and read, `PayPal-Request-Id` per batch, a `payout.poll` job to completion), Transaction Search (`/v1/reporting/transactions`), Disputes list and get; a 403 `NOT_AUTHORIZED` becomes `provider_feature_disabled`. The MCP client starts the official server with exactly twelve tools: reads `get_order`, `get_refund`, `list_transactions`, `list_invoices`, `get_invoice`, `list_disputes`, `get_dispute`; executes `create_invoice`, `send_invoice`, `send_invoice_reminder`, `generate_invoice_qr_code`, `accept_dispute_claim`, reachable only through `execute()` from an approved action. `verify-contract.cjs` asserts the list at the Docker build (its deadline raised to 60 s: the server takes 10–15 s to start on a loaded build machine).
- **Webhooks**: `INVOICING.INVOICE.PAID` (invoice → kitchen order), `INVOICING.INVOICE.CANCELLED`, `CUSTOMER.DISPUTE.CREATED`, `CUSTOMER.DISPUTE.RESOLVED`, added to webhook `6F260723274035041` by `deploy/ec2/webhook-events-0140.py`.
- **Commands and queries** (all behind the console proxy allowlist): `close.run`, `close.sign`, `payroll.run`, `payout.send`, `shift.save`, `shift.clock`, `shift.plan`, `catering.request`, `invoice.send`, `invoice.remind`, `complaint.open`, `dispute.sweep`, `dispute.seed` (judges' café only), `dispute.accept`, `supply.receive`, `stock.receive`, `stock.save`, `supplier.save`, `expense.snap`, `expense.record`, `loyalty.run`, `coupon.create`, `autonomy.set`; queries `backoffice.close`, `backoffice.closes`, `shifts`, `payouts`, `payout`, `catering`, `catering.request`, `complaints`, `disputes`, `stock`, `suppliers`, `deliveries`, `expenses`, `customers`, `analytics`.
- **Tips**: `payment.allocate {tipMinor}` adds the tip charge the quote path already used; PayPal's amount carries it; the tip pool feeds the pay run.
- **Judges' café**: the daily reset seeds three staff with shifts (payout emails from `RAYSTO_JUDGE_PAYOUT_EMAILS`), a catering request, a complaint on a paid order, a seeded dispute, two suppliers, six stock items, two expenses and two customer profiles; `judge.reset {menu: true}` restores only the menu before the menu card.
- Runtime settings added: the eight `RAYSTO_AGENT_*_ENABLED` switches, `RAYSTO_JUDGE_PAYOUT_EMAILS`, `RAYSTO_PAYPAL_REPORTING_ENABLED` (off until Transaction Search is enabled on the Sandbox app).
- Archive `raysto-backend-0.14.0-linux-amd64.tar.gz`, SHA-256 `3aad9a1ed52d6065a6ade75275c68fc6c8d251e1ef43149cc73737c6cd63ba26`.

## Backend 0.14.1

- The MCP client treats a JSON answer carrying an `error` key as a failed tool, so a refused invoice step reads as `provider_feature_disabled` and the close never takes an empty answer for PayPal's list.
- The close agent requires PayPal's `transaction_details` list before it trusts an MCP answer; otherwise it tries REST, then falls back to Raysto's ledger and says so.
- The seeded complaint names the first dish of its order.
- The payments agent's prompt says "the diner left" for what the counter saw, never "you reported".

## Backend 0.14.2 and 0.14.3

- 0.14.2: a signed day can be closed again (the new draft replaces it and the audit says it was re-run); the complaints agent gives the diner the benefit of the doubt for a missing or wrong item the order contains, and refuses only claims that name nothing in the order; the judges' reset withdraws a quoted-but-unsent catering request and an answered complaint, so the next judge sees the agents work.
- 0.14.3: the official toolkit reports a refused PayPal call as `{"ok":false,"status":403,...}` inside a successful MCP text block; the client now reads that as a failed tool (a 403 is a missing Sandbox feature, `provider_feature_disabled`; anything else `mcp_tool_rejected`). The seeded complaint wakes the complaints agent at once; a declined complaint keeps the agent's reason.
- Live check after 0.14.3: the seeded complaint ("my falafel wrap was missing") was answered with an $8.00 partial refund proposal, PayPal's capture read through MCP; the catering send failed honestly with `provider_feature_disabled`.
- Archives: 0.14.1 `a02fad7d…8b29`, 0.14.2 `28c8f52e…c079`, 0.14.3 `6122a4ab0b3a597e18b95f1ca9e3c3f7b5270209227ec824e13f637083567494`.

## Console 0.16.0 to 0.16.5

- **Money** section: Close the day, Pay & tips (PayPal batch ids), Catering (quote, invoice number, QR), Refunds & disputes, Expenses, Customers, Analytics (sales by hour and channel, fees, refunds, tips, staff cost, expenses, margin per dish). **Team** section: the week's shifts, clock in and out, the roster proposal.
- **Try Raysto**: nine cards, money first; the one-sentence order is one tap; held-back menu rows are no longer counted as new; the menu is restored before each read; Overview counts agree; Payments shows ticket numbers beside order ids.
- 0.16.1: the payment chase asks with "the diner left"; the catering card accepts the QR code as a data URL.
- 0.16.2: rays.to shows the Android build 0.14.2 and its checksum.
- 0.16.3 and 0.16.4: the catering card places a fresh request when the last one is spent; the complaint card names a dish the chosen order really has.
- 0.16.5: a money card whose PayPal step was refused says why ("PayPal refused it: this feature is not enabled on the Sandbox app yet. Nothing was sent or charged.") instead of "run it again".

## Verification

- Backend: `dart analyze` clean; 68 unit and 112 integration tests (the integration directory must run with `-j 1`; concurrent files race on the test database).
- Console: typecheck clean, 28 tests. App: analyzer clean, 162 widget tests (Shifts tab, tip step, complaint sheet; served as APK 0.14.2+2020 at rays.to/raysto.apk, SHA-256 5a9c3e0e…2ca00).
- Production: session 6 of [paypal-acceptance-2026-10-31.md](paypal-acceptance-2026-10-31.md): payout batch `EUG58M87BKY5E`, capture `8L994373M64657007`; Awhar's service and Nginx site unchanged after each activation.
- Still pending on the Sandbox app: Invoicing and Transaction Search (`NOT_AUTHORIZED` on 3 November).
