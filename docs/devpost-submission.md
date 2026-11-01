# Raysto: Devpost submission text

Copy each section into the matching Devpost field. Everything below is backed by code in this repository or by the live Sandbox evidence in [paypal-acceptance-2026-10-31.md](paypal-acceptance-2026-10-31.md). All payments are PayPal Sandbox: no real money moves.

## Project name

Raysto

## Elevator pitch

A restaurant and snack-bar till where PayPal takes every payment, from a counter QR to a split table bill, and an AI assistant helps diners and staff but never moves money by itself.

## About the project

### Inspiration

A small restaurant or snack bar runs on three things that don't talk to each other: a till, paper tickets for the kitchen and a card terminal. Group tables are worse: one bill, five people and a phone calculator. We wanted one app that runs the counter and the kitchen from a tablet and lets every customer pay with PayPal on their own phone. It should also split a table bill to the cent. AI should handle the tedious parts, and a person should approve every payment.

### What it does

- **Counter.** Staff ring up a sale on a phone or tablet. The customer scans a PayPal QR code on the counter screen and pays on their own phone, or pays cash. Once paid, the order goes straight to the kitchen with a daily ticket number.
- **Kitchen board.** New, preparing and ready columns that update live. On a tablet they sit side by side.
- **Pickup.** Customers order ahead in the app and pay with PayPal. Staff check a four-digit pickup code at hand-off.
- **Table.** Everyone at a table shares a room. Gemini reads the real menu and builds a basket that the server prices and the host approves. When the bill comes, Raysto splits it into exact shares and each diner pays their own share in PayPal.
- **Owner console** ([ops.rays.to](https://ops.rays.to/ops)) shows:
  - today's sales by channel;
  - an AG Grid of every order with its PayPal capture ids and refunds;
  - payments in separate PayPal, cash, refund and attempt tabs, so cash and PayPal are never blended.
- **Ask Raysto.** A manager can ask *"Are any PayPal payments unresolved? Did checkout 5 go through?"* The assistant reads the ledger, then asks PayPal through the PayPal MCP server, and its answer names the source.

### How PayPal is used

- **Orders v2.** Every online payment uses create and capture. A capture lease means a payment is never captured twice. The verified webhook, a reconciliation job and the return page all lead to the same settle step, so a missed webhook still settles. If a capture arrives after a checkout was released, it is recorded for review, not lost.
- **Split bills.** Each person's share is its own PayPal order tied to a frozen split plan, so no part of a bill can be paid twice.
- **Refunds.** Partial refunds are credited to the right order even when one capture paid for several. A refund needs a fresh identity check.
- **PayPal MCP.** The assistant reads PayPal through the official `@paypal/mcp` server (stdio) and falls back to REST. The answer states which source it used and never marks anything paid.
- **Sandbox only** for the hackathon, with one Sandbox business account as the merchant.

### How AI is used

Gemini 3.6 Flash with function calling. Each conversation gets only the tools it needs:

| Context | Tools |
|---|---|
| Table room | `read_menu`, `read_room`, `read_bill`, `quote_basket` (the server prices it), `propose_payment` (exact shares), `payment_status` |
| Pickup basket | `read_menu`, `quote_basket`, `payment_status` |
| Manager | `sales_summary`, `kitchen_load`, `pickup_ready`, `unresolved_payments`, `operations_summary`, `payment_status` |

`payment_status` reads PayPal through MCP.

The rules are enforced by the backend, not by the prompt:

- The AI proposes and people approve. A basket becomes an order only when the host approves it. A share is paid only when that diner approves it in PayPal.
- The AI never captures, refunds or marks a payment paid. Money moves only through ordinary commands.
- Payment facts in answers come from fixed sentences filled from the ledger and from PayPal, not from the model's wording.
- Total AI spending has a hard cap, and each customer has a daily limit.
- Equal splitting also works without AI, so the AI is never needed to pay.

### How we built it

- **Mobile:** Flutter (Android). Phone and tablet layouts for counter, kitchen and orders.
- **Backend:** Serverpod 4 and PostgreSQL on AWS ([api.rays.to](https://api.rays.to/ready)).
- **Console:** Next.js 16 with AG Grid and AG Studio ([ops.rays.to](https://ops.rays.to/ops)).
- **Services:**
  - Firebase Authentication (Google and email)
  - Gemini Developer API
  - PayPal Orders v2, Webhooks and MCP
- **Tests:**
  - 122 backend tests, unit plus integration on an isolated database;
  - 134 widget tests for the app;
  - 14 tests for the console.

### Verified live in PayPal Sandbox (31 October and 1 November 2026)

| Journey | Result | PayPal ids |
|---|---|---|
| Pickup order paid in the app (buyer 1) | Captured, order paid, pickup code issued | capture `633829727B675370M` |
| Counter sale paid by QR (buyer 2) | Captured, order accepted for the kitchen | capture `4C048952Y13801205` |
| Table bill of $27.00 split equally (buyers 1 and 2) | Two $13.50 shares captured, bill fully settled | captures `4MG67343RS1841023`, `47E23175WJ603464A` |
| Partial refund of $5.00 on the pickup order | Refund completed, order partially refunded | refund `2J851836BE9699524` |
| Counter sale rung up in the Android app on a tablet, filmed for the video (1 November) | Captured, ticket #3 to the kitchen | capture `55W092765M630635H` |
| Manager asks Raysto about PayPal | Ledger checked, then PayPal read through MCP (stdio) | tool trace in the evidence file |

### Challenges we ran into

- **Settling once.** A payment can be settled by the webhook, a background job or the buyer's return, in any order. The capture lease and the single settle step took the most testing.
- **Safe AI around money.** An AI that can read payments must not get to state payment facts in its own words. The fixed fact sentences solved it.
- **Counter retries.** Weak Wi-Fi at a counter must not double-charge or double-order. Every step keeps its request key, so a retry resumes where it stopped.

### Accomplishments that we're proud of

- Every PayPal journey in the demo was run against the live Sandbox with two real buyer accounts.
- A $27 table bill was split and paid by two different PayPal buyers, to the cent.
- The same backend serves a snack-bar counter, a kitchen tablet, pickup, table service and an owner console.

### What we learned

PayPal's order states map naturally onto a restaurant: approved is not paid, and capture is the moment that counts. Giving the AI a narrow set of tools per context made it both more useful and easier to trust.

### What's next

- A pilot with one snack bar.
- iOS.
- Ordering from a web page.
- A delivery dispatch board.
- PayPal onboarding so each restaurant connects its own live account.

## Built with

flutter, dart, serverpod, postgresql, aws, nginx, cloudflare, next.js, react, typescript, ag-grid, ag-studio, firebase-authentication, gemini, paypal-orders-v2, paypal-webhooks, paypal-mcp

## Links

- Code (MIT): https://github.com/FouadABT/raysto
- Owner console: https://ops.rays.to/ops
- API health: https://api.rays.to/ready
