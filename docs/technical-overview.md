# Raysto: technical overview

The detail behind the [README](../README.md): every AI coworker, how each PayPal product is used, the tools, and the architecture. Last updated 5 November 2026; recorded times and ids are from the dated runs named in each row.

## What Raysto is

A snack bar or small restaurant runs on a till, paper tickets and a card terminal that do not talk to each other, and the owner closes the day, pays the team, bills the caterer and settles complaints by hand. Raysto puts the counter, the kitchen board, pickup and table ordering, split bills, shifts, stock, expenses and the owner's back office on one backend, takes every payment through PayPal, and gives the owner AI coworkers that decide the money matters and prepare them: closing the day against PayPal's own ledger, splitting tips and paying the team, invoicing a catering request, deciding a refund, reading a delivery note or a receipt, as well as reading a menu into the system, taking a spoken order and drawing dish photos.

The one rule: **an AI coworker prepares a change with its evidence; a person approves it; only then does PayPal move the money.** Money changes also need the person to confirm it is really them. The owner can set small limits (`autonomy`: refunds up to an amount, a few a day, automatic invoice reminders) inside which an agent acts by itself and shows the PayPal id it got; payouts and invoice sends are never automatic.

## The AI coworkers

Fourteen coworkers, each with only its own tools. The eight money agents were added on 3 November; their first live run on production is in session 6 of the [acceptance notes](paypal-acceptance-2026-10-31.md).

| Coworker | What it does | Its tools | What a person approves | PayPal executes | Recorded live |
|---|---|---|---|---|---|
| **Close agent** | Reconciles the day: PayPal's transaction list against the till, cash, tips, refunds and unpaid tickets; explains every gap and proposes the fix | `read_day`, `read_paypal_day` (MCP `list_transactions`, then REST Transaction Search), `propose_close` | The sign-off, and a reconcile for a capture Raysto missed | Transactions (read) | 13 s, signed; PayPal's list not yet enabled on the Sandbox app, so the close said so and used the ledger |
| **Payroll agent** | Turns clocked shifts into wages and splits the tip pool by hours and role into one batch | `read_week`, `propose_pay` | Sending the batch, with an identity check | **Payouts** `/v1/payments/payouts` | 10 s; batch `EUG58M87BKY5E`, $448.00 wages, pending at creation |
| **Catering agent** | Prices a one-sentence request from the menu, with a deposit and due date, drafts the invoice; reminds when overdue; a paid invoice becomes a kitchen order | `read_request`, `read_menu`, `propose_quote` | Sending the invoice, with an identity check | **Invoicing** via MCP (`create_invoice`, `send_invoice`, `generate_invoice_qr_code`, `send_invoice_reminder`); `INVOICING.INVOICE.PAID` webhook | Quote in 16 s; the send was refused because Invoicing is not yet enabled on the Sandbox app |
| **Complaints agent** | Reads the complaint, the kitchen ticket and PayPal's capture, proposes a full, partial or no refund with its reasons | `read_complaint`, `read_payment` (PayPal MCP), `propose_remedy` | The refund, with an identity check; within the owner's limit it refunds by itself | **Refunds** | 16 s; the seeded complaint named a dish the order lacked, so no refund was proposed (fixed in 0.14.1) |
| **Disputes agent** | Lists and reads disputes, assembles the evidence (ticket, pickup code, timeline) and drafts the reply; accepts only when the café is wrong | `read_dispute` (MCP `get_dispute`), `propose_response` | Accepting a claim | **Disputes** via MCP (`list_disputes`, `get_dispute`, `accept_dispute_claim`) | The judges' café holds a seeded case, labelled seeded; no real Sandbox dispute yet |
| **Supplies agent** | Reads a photographed delivery note into lines and prices, matches stock, proposes stock in and the supplier's payment | Gemini vision, `read_stock`, `read_suppliers`, `propose_delivery` | Stock in, and the payout | **Payouts** to the supplier | Integration test on the sample note (8 lines, $479.80); not yet run on production |
| **Expenses agent** | Reads a receipt into merchant, category, amount and VAT and matches it to PayPal's transactions | Gemini vision, `read_paypal_transactions`, `propose_expense` | Recording the expense | Transactions (read) | Integration test on the sample receipt ($79.56); not yet run on production |
| **Loyalty agent** | Tags regulars and lapsed customers from paid orders and proposes one coupon with its cost | `read_customers`, `propose_coupon` | Creating the coupon | Coupon redeemed at **Orders** checkout | Ran on the judges' café: a coupon proposal waits in the inbox |
| **Copilot** | Notices a kitchen running late and proposes a new preparation time; proposes next week's roster from sales by hour | `read_kitchen`, `propose_preparation_time`, `read_demand`, `propose_roster` | The new preparation time; the roster | Hours feed the pay run | Ran live on 1 November; the roster is covered by tests |
| **Menu agent** | Reads photos of a printed menu into dishes, sections, prices and options; never guesses a price | Gemini vision, then an organising call | Publishing the merged menu | The menu PayPal charges from | 14 of 14 dishes, 19 s, $0.012 (3 November) |
| **Counter voice** | Hears a spoken order at the till and fills the ticket with real dishes and options | Gemini audio with the counter menu | The cashier checks the lines and takes payment as usual | Counter QR | 3.5 s (3 November) |
| **Takeaway assistant** (Ask Raysto) | Builds a priced pickup basket from one sentence, keeps to a budget and a pickup time | `read_menu`, `quote_basket`, `payment_status` | The basket, then the payment on PayPal's page | **Orders v2** | 9.6 s → capture `8L994373M64657007`, ticket #14 (3 November) |
| **Payments agent** | Investigates stuck or abandoned PayPal checkouts, explains them, prepares the fix | `read_ledger`, `read_paypal` (PayPal MCP) | Releasing or recording a payment, with an identity check | Orders (read via MCP), release | 17 s via MCP (3 November) |
| **Image studio** | Draws a photo of a dish from its own description, with an empty background | Gemini `gemini-3.1-flash-image` (OpenAI `gpt-image-1` when a key is set) | Putting the photo on the menu, labelled as AI | — | 52.7 s, $0.04 (3 November) |

<p align="center">
<img src="media/try-voice.png" width="32%" alt="Counter voice: a spoken order became three ticket lines, with lemonade flagged as not on the menu">
<img src="media/try-menu.png" width="32%" alt="Menu agent: 14 dishes read from a photo, 3 new, 1 price change, the soup held back without a price">
<img src="media/try-photo.png" width="32%" alt="Image studio: Gemini's croque monsieur photo, scanned and waiting for approval">
</p>
<p align="center"><sub>Counter voice, the menu agent and the image studio on the live console, 2 November.</sub></p>

AI spending has hard caps: a hackathon budget split by feature, and $5 per restaurant per day. Each agent has its own kill switch.

## How PayPal is used

- **Orders v2** for every online payment: create, buyer approval on PayPal's page, then a single server-side capture. A capture lease means nothing is captured twice; the verified webhook, a reconciliation job and the buyer's return all lead to the same settle step.
- **Payouts** (`/v1/payments/payouts`) for wages, tips and supplier payments, as one batch per pay run, sent only after the owner's identity check; the batch and item ids are kept and polled to completion.
- **Invoicing** through the PayPal MCP server for catering: create, send, QR code and reminder, each only after approval; `INVOICING.INVOICE.PAID` turns the invoice into a kitchen order.
- **Transaction Search** for the daily close and expense matching (read only).
- **Disputes** through the MCP server: list and read for the evidence pack, accept only after approval.
- **Refunds**, partial or full, credited to the right order, behind a fresh identity check; small ones inside the owner's limit are made by the complaints agent itself.
- **Verified webhooks** (`CHECKOUT.ORDER.APPROVED`, `PAYMENT.CAPTURE.COMPLETED`, `PAYMENT.CAPTURE.REFUNDED`, `INVOICING.INVOICE.PAID`, `INVOICING.INVOICE.CANCELLED`, `CUSTOMER.DISPUTE.CREATED`, `CUSTOMER.DISPUTE.RESOLVED`), each processed exactly once.
- **Counter QR**: the customer pays the counter sale on their own phone; once paid the ticket goes to the kitchen.
- **Exact split bills**: each diner pays their own share as its own PayPal order, tied to a frozen split plan, to the cent.
- **PayPal MCP server** (`@paypal/mcp` 1.8.1 over stdio) started with exactly twelve tools: seven reads the model may call (`get_order`, `get_refund`, `list_transactions`, `list_invoices`, `get_invoice`, `list_disputes`, `get_dispute`) and five executes (`create_invoice`, `send_invoice`, `send_invoice_reminder`, `generate_invoice_qr_code`, `accept_dispute_claim`) that only the approval path can run; the model never sees them.
- **PayPal's page names the restaurant** (`brand_name`), with no shipping step and a "Pay now" button.
- **Sandbox only** for the hackathon, on one Sandbox business account. Payouts works there; Transaction Search and Invoicing are being enabled on the Sandbox app (PayPal answered `NOT_AUTHORIZED` on 3 November), and the console says so where it matters. Each restaurant connecting its own PayPal account is built (`merchant.connect`, PayPal Partner Referrals, the restaurant as payee); going live needs PayPal to approve Raysto as a platform partner.

## Tools used, and how

| Tool | How Raysto uses it |
|---|---|
| PayPal Orders v2 and Webhooks | Checkout, capture, refunds, verified events, invoice and dispute events (Sandbox) |
| PayPal Payouts | Wages, tips and supplier payments after approval |
| PayPal Invoicing, Transaction Search, Disputes | Catering invoices, the daily close and expense matching, dispute evidence and acceptance |
| PayPal MCP server `@paypal/mcp` 1.8.1 | Seven reads for the agents and Ask Raysto, five executes behind approval, over stdio |
| Google Gemini 3.6 Flash (Developer API) | Function calling for the fourteen coworkers and Ask Raysto; vision for menus, delivery notes and receipts; audio for counter orders |
| Gemini `gemini-3.1-flash-image` | Dish photos in the image studio |
| AG Grid and AG Studio | Every console grid on one shared grid; AG Studio pages for the accountant (profit and loss, cash flow, payables, VAT), supplies, the franchise group and the floor |
| Firebase Authentication | Google and email sign-in; the backend checks verified email |
| Serverpod 4, PostgreSQL | Backend, roles, ledger, durable jobs, on AWS at `api.rays.to` |
| Flutter | Android staff tablet (counter, kitchen, orders, shifts, agents) and diner app |
| Next.js 16, React 19 | Owner console at `ops.rays.to` and the product page at `rays.to` |
| Kokoro TTS, Remotion | Synthetic voices for the voice evaluation, and the demo video |


## Architecture

```mermaid
flowchart LR
    App[Flutter app: staff tablet and diner] --> API[Serverpod API]
    Console[Next.js console + AG Grid / AG Studio] --> API
    API --> SQL[(PostgreSQL: roles, orders, ledger)]
    SQL --> Jobs[Durable jobs: core lane + AI lane]
    Jobs --> PayPal[PayPal Orders v2 + Webhooks, Sandbox]
    Jobs --> Agents[AI coworkers: Gemini]
    Agents --> MCP[PayPal MCP server, read-only]
    Agents --> Inbox[Proposals wait for a person]
    Inbox --> API
```

PostgreSQL owns permissions, prices, orders, payments, shifts, payouts, invoices, stock and expenses. Agents act through a service identity that can read and propose, never run a command; the five MCP executes and the Payouts call run only from an approved action. [API contracts](backend-v2/integration.md) · [System maps](backend-v2/README.md) · [Back-office design](back-office-design.md)
