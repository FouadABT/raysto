# Raysto back office: the money agents (design, 3 November 2026)

Decision (Fouad, 3 Nov): widen Raysto into the café's whole back office, and put an AI + PayPal loop inside every new feature. Rule for each feature: **money moves through PayPal, and the AI decides something about that money; a person approves; PayPal executes and returns an id.** Freeze 8 Nov; anything not reliable on production by then is cut, never shown half-working.

Sandbox facts checked 3 Nov (`deploy/ec2/spike-money-tools.py`): Payouts work (batch `64ZL2AJ9CGL5C`); Transaction Search and Invoicing are `NOT_AUTHORIZED` until Fouad enables them on the Sandbox app; Disputes list works; the shipped PayPal MCP server with `--tools=all` offers 28 tools including `create_invoice`, `send_invoice`, `send_invoice_reminder`, `generate_invoice_qr_code`, `get_invoice`, `list_invoices`, `list_transactions`, `list_disputes`, `get_dispute`, `accept_dispute_claim`, `create_refund`, `create_order`, `pay_order`.

## 1. Areas, loops and what is new

| Area | Agent | Trigger | AI decides | PayPal executes (after approval) | Command |
|---|---|---|---|---|---|
| Daily close | `close` | schedule at closing time (settings `closeAt`, default 23:00 local) or `close.run` | matches PayPal's transactions to Raysto's captures/refunds/cash, explains each gap, proposes the sign-off and any fix | reads `list_transactions` (MCP) or `GET /v1/reporting/transactions`; fallback: Raysto's own ledger from webhooks, labelled | `close.sign` (ops) |
| Pay and tips | `payroll` | schedule at close, or `payroll.run {from,to}` | tip pool split by hours and role; wages from hours × rate | **Payouts** batch (REST `/v1/payments/payouts`) | `payout.send` (money, step-up) |
| Catering | `catering` | `catering.request {text, email}` from a customer form or the console | prices from the menu, quantities, deposit, due date, drafts the invoice | **Invoicing** via MCP `create_invoice` + `send_invoice` + `generate_invoice_qr_code`; reminder via `send_invoice_reminder`; `INVOICING.INVOICE.PAID` webhook → scheduled order | `invoice.send`, `invoice.remind` (money, step-up) |
| Complaints and refunds | `complaints` | `complaint.open {orderId, text}` (diner app, console) | full / partial / none with the evidence from the ticket and PayPal's capture | **Refunds** (existing `payment.refund`, step-up) | `payment.refund` |
| Disputes | `disputes` | `dispute.sweep` (MCP `list_disputes`) or seeded | evidence pack and a draft reply; accept when the café is wrong | MCP `accept_dispute_claim` only after approval; otherwise the reply text is for the owner to paste | `dispute.accept` (money) |
| Suppliers and stock | `supplies` | `supply.receive {mediaId}` (photo of a delivery note) | reads lines and prices (reuses the menu vision call), matches to stock items, proposes stock in and the supplier payout | **Payouts** to the supplier's PayPal email | `stock.receive` (ops), `payout.send` |
| Customers and loyalty | `loyalty` | schedule weekly, or `loyalty.run` | who is lapsing or a regular, the coupon to offer and its cost | coupon redeemed at **Orders** checkout (coupons exist in settings) | `coupon.create` (ops) |
| Expenses | `expenses` | `expense.snap {mediaId}` (photo of a receipt) | category, amount, VAT, whether it already appears in PayPal's transactions | shows in the close and the P&L | `expense.record` (ops) |
| Team and shifts | `copilot` (extended) | weekly | next week's roster from sales by hour | hours feed the pay run | `shift.plan` (ops) |

Owner limits (autonomy), settings `autonomy`: `{refundsMaxMinor: 500, refundsPerDay: 3, remindersAuto: true}`. Within the limit the agent's action is executed by the AI worker under the service identity and shown in the inbox as "done within your limit", with the PayPal id; above it, it waits for approval and the step-up as now. Payouts and invoice sends are never automatic.

## 2. Models (new `.spy.yaml` under `lib/src/models/platform/`, one migration)

- `StaffShift`: restaurantId, userId?, name, role, startsAt, endsAt, clockInAt?, clockOutAt?, hourlyRateMinor, payoutEmail?, createdAt. Index (restaurantId, startsAt).
- `PayoutBatch`: restaurantId, kind (`tips`|`wages`|`supplier`), periodFrom, periodTo, totalMinor, currency, state (`proposed`|`sent`|`completed`|`failed`), providerBatchId?, requestKey (unique), taskId?, createdAt, updatedAt.
- `PayoutItem`: restaurantId, batchId, recipientEmail, recipientName, shiftIds json, amountMinor, note, providerItemId?, state. Index (batchId).
- `CateringRequest`: restaurantId, customerEmail, customerName?, text, eventAt?, quoteJson, status (`requested`|`quoted`|`sent`|`paid`|`cancelled`), providerInvoiceId?, invoiceNumber?, qrMediaId?, orderId?, depositMinor, totalMinor, currency, dueAt?, remindedAt?, taskId?, createdAt, updatedAt. Unique index on providerInvoiceId.
- `Complaint`: restaurantId, orderId, captureId?, userId?, text, status (`open`|`proposed`|`refunded`|`declined`), refundId?, taskId?, createdAt, updatedAt.
- `DisputeCase`: restaurantId, providerDisputeId (unique), captureId?, reason, amountMinor, currency, status, evidenceJson, replyText?, taskId?, createdAt, updatedAt.
- `Supplier`: restaurantId, name, payoutEmail, createdAt. `StockItem`: restaurantId, name, unit, quantity (double), costMinor, supplierId?, lowAt, updatedAt. `SupplyDelivery`: restaurantId, supplierId?, mediaId, linesJson, totalMinor, state (`read`|`received`|`paid`), payoutBatchId?, taskId?, createdAt.
- `Expense`: restaurantId, category, amountMinor, currency, vatMinor, spentAt, mediaId?, merchant, paypalTransactionId?, taskId?, createdAt.
- `DailyClose`: restaurantId, day (yyyy-mm-dd), source (`paypal_transactions`|`raysto_ledger`), summaryJson, gapsJson, state (`drafted`|`signed`), signedBy?, taskId?, createdAt, updatedAt. Unique (restaurantId, day).
- `CustomerProfile`: restaurantId, userId?, emailHash, displayName, visits, spentMinor, lastSeenAt, tags json, couponCode?, updatedAt. Unique (restaurantId, emailHash).
- `CheckoutIntent` gains `tipMinor: int` (default 0): `payment.allocate` accepts optional `tipMinor` (0 ≤ tip ≤ 50% of the amount); the PayPal order amount is amount + tip with a "Tip" item; the capture keeps `tipMinor`; allocations never include the tip.

## 3. Commands and queries (names are the contract for the console and app)

Commands: `close.run`, `close.sign`, `payroll.run`, `payout.send`, `shift.save`, `shift.clock`, `shift.plan`, `catering.request`, `invoice.send`, `invoice.remind`, `complaint.open`, `dispute.sweep`, `dispute.accept`, `supply.receive`, `stock.receive`, `stock.save`, `supplier.save`, `expense.snap`, `expense.record`, `loyalty.run`, `coupon.create`, `autonomy.set`.
Queries: `backoffice.close {day?}`, `backoffice.closes`, `shifts {from,to}`, `payouts`, `payout {id}`, `catering`, `catering.request {id}`, `complaints`, `disputes`, `stock`, `suppliers`, `deliveries`, `expenses {from,to}`, `customers`, `analytics {from,to}` (sales by hour, by channel, PayPal fees, refunds, tips, staff cost, expenses, margin per dish from stock costs).
All through `POST /api/v2/commands/{name}` and the query endpoint; the console proxy allowlist (`web/src/lib/connected/proxy-allowlist.ts`) must list each.

## 4. Console

Two new sections beside Overview/Orders/Payments/Agents/Floor: **Money** (tabs: Close, Pay & tips, Catering, Refunds & disputes, Expenses, Analytics with AG Grid charts) and **Team** (shifts grid, clock state, roster proposal), plus **Customers** inside Money. Every tab: a grid (AG Grid Community), the agent's proposal card with evidence chips and the PayPal id after approval, one primary action. Try Raysto page: money cards first (Close the day, Pay the team, Bill the caterer, Settle a complaint, Chase a payment, Split a table), then the existing menu, voice and photo cards; at most 9 cards.

## 5. App

Staff tablet: Shifts tab (clock in/out, today's roster). Diner app: tip step before PayPal (none / 5% / 10% / custom), complaint from an order ("Something was wrong"). Nothing else.

## 6. Judges' café seed

Three staff with the Sandbox buyer emails as payout targets, shifts for the week, paid orders with tips, one catering request, one delivery-note photo and one receipt photo in `assets/judge/`, one complaint, one lapsed regular; the daily reset and hourly tidy restore all of it.

## 7. Order and cuts

Build order: models and migration → gateway/MCP → close + payroll → catering + complaints → supplies + expenses + loyalty → disputes → console → app → seeds and Try cards → tests → deploy → docs and film. Cut order: disputes, expenses, loyalty, supplies, team roster proposal. Never cut the close, payouts, invoices, refunds.
