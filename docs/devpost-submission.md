# Raysto: Devpost submission text

Copy each section into the matching Devpost field. Everything below is backed by code in this repository or by recorded live runs in [paypal-acceptance-2026-10-31.md](paypal-acceptance-2026-10-31.md) and [ai-evaluation-results.md](ai-evaluation-results.md). All payments are PayPal Sandbox: no real money moves.

## Project name

Raysto

## Elevator pitch

AI coworkers run a small restaurant's money: they close the day against PayPal's ledger, pay the team through PayPal Payouts, bill caterers with PayPal Invoicing, settle complaints with refunds, and also read the menu, hear orders and draw dishes. A person approves every change, and PayPal moves the money.

## Try it (put at the top of the description)

**[rays.to](https://rays.to) → Try it now.** One click signs you into the owner console of a demo café, on a page of nine live demos, money first: close the day, pay the team through PayPal Payouts, bill a caterer, settle a complaint with a refund, chase an unfinished payment through the PayPal MCP server, order lunch in one sentence and pay in PayPal Sandbox, read a printed menu, take an order by voice, draw a dish. Two minutes, nothing to install. Logins are in the README and on rays.to.

## About the project

### Inspiration

A snack bar or small restaurant runs on a till, paper tickets and a card terminal that don't talk to each other. The owner then spends the evening closing the till against the card terminal's printout, working out tips, writing a catering quote, deciding whether to refund the missing croissant, and typing the menu into one system. We wanted one product that runs the counter and the kitchen from a tablet, takes every payment with PayPal, and gives the owner AI coworkers that decide the money matters and prepare them with PayPal's own tools, without ever letting an AI move money without a person.

### What it does

**For the counter and the kitchen** (Android tablet):
- A till with a PayPal QR code: the customer pays the counter sale on their own phone; once paid the ticket goes to the kitchen with a daily number. Cash works too.
- **Voice ordering**: the cashier says the order and the counter agent fills the ticket with real dishes and options from the menu. Nothing is charged until the cashier takes payment.
- A kitchen board with new, preparing and ready lanes and urgency colours.

**For diners** (Android app):
- Order ahead for pickup and pay with PayPal; staff check a four-digit pickup code.
- **Ask Raysto**: "Two vegetarian lunches under $25, ready as soon as you can." Raysto reads the menu, keeps to the budget, picks a pickup time the kitchen can keep (and says so when it cannot keep the time you asked for), and proposes a priced basket. One tap places the order and opens PayPal; only the diner's approval on PayPal's own page pays.
- Table service with a shared room and exact split bills: each diner pays their own share in PayPal.

- A tip step before PayPal and a "Something was wrong?" sheet on a paid order that reaches the complaints agent (in the source; the next APK build is pending).

**For the owner** (console at [ops.rays.to](https://ops.rays.to/ops), AG Grid and AG Studio):
- Today's sales, orders with their PayPal capture ids, payments kept apart by PayPal, cash, refund and attempt.
- A **Money** section (close, pay and tips, catering, refunds and disputes, expenses, customers, analytics) and a **Team** section (shifts, clock in and out, the roster proposal).
- An **Agents** inbox where every AI proposal waits with its evidence. Fourteen coworkers, eight of them about money:
  - the **close agent** reconciles the day: PayPal's transaction list against the till, cash, tips, refunds and unpaid tickets, explains every gap, and waits for the owner's sign-off (when Transaction Search is not enabled on the account it reconciles from Raysto's own ledger and says so);
  - the **payroll agent** turns clocked shifts into wages and splits the tip pool by hours and role; after the identity check **PayPal Payouts** sends the batch and the id is kept;
  - the **catering agent** prices "lunch for 12 on Friday, budget $150" from the menu with a deposit, and after the identity check **PayPal Invoicing** sends the invoice with a QR code through the PayPal MCP server; overdue invoices get a reminder; a paid invoice becomes a kitchen order through the webhook;
  - the **complaints agent** reads the complaint, the kitchen ticket and PayPal's capture (through MCP), and proposes a full, partial or no **refund**; within the owner's limit (`autonomy`: an amount, a few a day) it refunds by itself and shows PayPal's refund id;
  - the **disputes agent** lists and reads disputes through MCP, assembles the evidence pack and drafts the reply; accepting a claim needs approval;
  - the **supplies agent** reads a photographed delivery note into stock and proposes the supplier's **payout**; the **expenses agent** reads a receipt and matches it to PayPal's transactions; the **loyalty agent** finds regulars and lapsed customers and proposes a coupon redeemed at checkout;
  - the **menu agent** turns a photo of a printed menu into a draft menu: 14 of 14 dishes and prices read in 19 s, new dishes and changed prices marked, unreadable prices held back;
  - the **payments agent** notices a PayPal checkout that never finished, asks PayPal itself through the PayPal MCP server, and prepares the release, which needs the owner's identity check;
  - the **copilot** sees the kitchen running late and proposes a longer promised time, then a shorter one when it is calm, and proposes next week's roster from sales by hour;
  - the **image studio** draws a dish photo with Gemini; it is scanned, waits for approval, and diners see it labelled as an AI image.

### How PayPal is used

- **Orders v2** for every online payment: create, buyer approval on PayPal's page, one server-side capture. A capture lease means nothing is ever captured twice; the verified webhook, a reconciliation job and the buyer's return all lead to the same settle step.
- **Verified webhooks**, each event processed exactly once.
- **Payouts** (`/v1/payments/payouts`): wages, tips and supplier payments as one batch per pay run, sent only after the owner's identity check, polled to completion with batch and item ids kept.
- **Invoicing** through the PayPal MCP server: the catering agent's quote becomes a PayPal invoice (create, send, QR code, reminder), each step only after approval; `INVOICING.INVOICE.PAID` turns it into a kitchen order.
- **Transaction Search** (read only) for the daily close and for matching receipts to PayPal's transactions.
- **Disputes** through the MCP server: list and read for the evidence pack, accept a claim only after approval.
- **Refunds**: partial or full, credited to the right order, behind a fresh identity check; small ones inside the owner's limit are made by the complaints agent itself and shown with PayPal's refund id.
- **Counter QR** for walk-in sales and **exact split bills** with one PayPal order per diner's share.
- **PayPal MCP server** (`@paypal/mcp` 1.8.1 over stdio) started with exactly twelve tools: seven reads the model may call (`get_order`, `get_refund`, `list_transactions`, `list_invoices`, `get_invoice`, `list_disputes`, `get_dispute`) and five executes (`create_invoice`, `send_invoice`, `send_invoice_reminder`, `generate_invoice_qr_code`, `accept_dispute_claim`) that only an approved action can run. The AI reads PayPal's own record before it proposes anything, and says that PayPal was the source.
- **Agentic checkout**: an AI-built basket becomes a real PayPal order in one tap, but only the buyer's approval in PayPal moves money.
- Sandbox only, on one Sandbox business account. Payouts works there; Transaction Search and Invoicing are being enabled on the Sandbox app (PayPal answered `NOT_AUTHORIZED` on 3 November), and the demo says so where it matters. Each restaurant connecting its own PayPal account is built (Partner Referrals, the restaurant as payee); going live needs PayPal to approve Raysto as a platform partner.

### How AI is used

Gemini 3.6 Flash (Developer API) with function calling, vision and audio; `gemini-3.1-flash-image` for dish photos. Each coworker gets only its own tools:

| Coworker | Tools | PayPal capability it ends in |
|---|---|---|
| Close agent | `read_day`, `read_paypal_day` (MCP `list_transactions`, REST Transaction Search), `propose_close` | Transactions, reconcile |
| Payroll agent | `read_week`, `propose_pay` | Payouts |
| Catering agent | `read_request`, `read_menu`, `propose_quote` | Invoicing via MCP |
| Complaints agent | `read_complaint`, `read_payment` (PayPal MCP), `propose_remedy` | Refunds |
| Disputes agent | `read_dispute` (MCP `get_dispute`), `propose_response` | Disputes via MCP |
| Supplies agent | Gemini vision, `read_stock`, `read_suppliers`, `propose_delivery` | Payouts |
| Expenses agent | Gemini vision, `read_paypal_transactions`, `propose_expense` | Transactions |
| Loyalty agent | `read_customers`, `propose_coupon` | Coupon at Orders checkout |
| Copilot | `read_kitchen`, `propose_preparation_time`, `read_demand`, `propose_roster` | Hours feed Payouts |
| Menu agent | Gemini vision for the pages, then one organising call | The menu Orders charge from |
| Counter voice | Gemini audio with the counter menu | Counter QR |
| Ask Raysto (pickup basket) | `read_menu`, `quote_basket`, `payment_status` | Orders v2 |
| Payments agent | `read_ledger`, `read_paypal` (PayPal MCP), `propose_fix` | Orders, release |
| Image studio | Gemini image generation, then the file scanner | — |

The rules are enforced by the backend, not by prompts:
- Agents run as a service identity that can read and propose but never pass a role check. Every proposal stores its evidence and a fingerprint of the records it saw; if they changed, the approval is refused as stale.
- Money changes need the approver to confirm their identity again. Payouts and invoice sends are never automatic.
- The owner can set limits (`autonomy`: refunds up to an amount, a few a day, automatic invoice reminders); inside them an agent acts by itself and shows the PayPal id it received. Outside them, nothing moves without a person.
- The model never sees a PayPal write tool: the five MCP executes and the Payouts call run only from an approved action.
- AI spending has a hard budget per feature and $5 per restaurant per day; each agent has a kill switch.

### How we built it

- **App**: Flutter (Android), phone and tablet layouts, English, French and Arabic.
- **Backend**: Serverpod 4 and PostgreSQL on AWS ([api.rays.to](https://api.rays.to/ready)), with a durable job queue and a separate lane for AI work so a slow model never delays a payment.
- **Console and judges' page**: Next.js 16, React 19, AG Grid, AG Studio.
- **Services**: Firebase Authentication, Gemini Developer API, PayPal Orders v2, Payouts, Invoicing, Transaction Search, Disputes, Webhooks and the MCP server.
- **Tests**: backend 68 unit tests and 122 integration tests on an isolated database; console 83 unit tests and 31 browser tests; app 211 widget tests, all passing on 4 November.

### Verified live in PayPal Sandbox (31 October to 4 November 2026)

Eleven captures, four refunds and five Payouts batches in all.

| Journey | Result | PayPal ids |
|---|---|---|
| Pickup order paid in the app | Captured, pickup code issued | capture `633829727B675370M` |
| Counter sale paid by QR | Captured, ticket to the kitchen | capture `4C048952Y13801205` |
| $27.00 table bill split by two buyers | Two $13.50 shares captured, bill settled | captures `4MG67343RS1841023`, `47E23175WJ603464A` |
| Partial refund of $5.00 | Refund completed | refund `2J851836BE9699524` |
| Counter sale on the Android tablet | Captured, ticket #3 to the kitchen | capture `55W092765M630635H` |
| One sentence to Ask Raysto, one tap | 2× Garden pasta $24.00, order placed, approved in PayPal | capture `9BY842216S6346205` |
| The judges' path, run three times on rays.to (the third filmed for the demo video) | Five live demos; each one-sentence order paid by a Sandbox buyer | captures `3PV01986C4166344M`, `1FC985713C934991E`, `8DJ62510842222013` |
| Payments agent on an abandoned checkout | Read PayPal via MCP (`PAYER_ACTION_REQUIRED`), release approved after identity check | checkout 10 |
| The nine-card judge path on 3 November (backend 0.14.0, console 0.16.0) | Close signed; pay run of $448.00 wages sent through PayPal Payouts; catering quoted (invoice send refused: Invoicing not yet enabled); one-tap order paid, ticket #14 | payout batch `EUG58M87BKY5E`, capture `8L994373M64657007` |
| Pay runs and complaints, 3–4 November (backend 0.14.1 to 0.15.0) | Four more wage batches sent through PayPal Payouts after the identity check; three $8.00 complaint refunds made by PayPal; the redesigned console's nine-card run paid by buyer 1 | payout batches `4KZDS8M7DDWTL`, `N48TL9D5X6PLG`, `ZFW54957PSL9C`, `TMS8FKRT6ALYU`; refunds `8MM65248WS403211T`, `0S763729H45148806`, `80508388SK757251T`; capture `20K31884958788526` |
| Live AI evaluation | 12 of 12: 3 menus, 5 spoken orders, 4 takeaway requests | [results](ai-evaluation-results.md) |

### Challenges we ran into

- **Settling once.** A payment can be settled by the webhook, a background job or the buyer's return, in any order. The capture lease and the single settle step took the most testing.
- **AI that can be trusted near money.** Agents had to be useful without being able to act. The answer was a service identity that can only propose, evidence stored with each proposal, and a stale check at approval time.
- **Real-world timing.** Live runs found what tests had not: a copilot alarm from an order scheduled for the next day, a 30-second limit too short for a basket, sessions refused after 100 sign-ins. Each became a fix and a test.
- **Letting the AI use PayPal's own tools without trusting it with them.** The PayPal MCP server offers invoice, dispute and refund writes next to its reads. We start it with twelve tools, let the model call only the seven reads, and route the five writes through the same approval path as every other money change, so a judge can see the AI do real PayPal work and still see a person's approval in front of every dollar.

### Accomplishments that we're proud of

- Every PayPal journey and every AI coworker above was run live against PayPal Sandbox and Gemini, with ids recorded, including a real Payouts batch sent by the payroll agent after the owner's identity check.
- A judge can try nine AI demos in a few minutes, with nothing to install.
- One backend serves the counter, the kitchen, pickup, table service, shifts, stock, expenses and the owner console.

### What we learned

PayPal's order states map naturally onto a restaurant: approved is not paid, and capture is the moment that counts. Giving each AI coworker a narrow set of tools and nothing it can execute made it both more useful and easier to trust, and that stayed true when the coworkers started working with payouts, invoices and refunds.

### What's next

- A pilot with one snack bar, on a real menu photo and a real counter voice.
- Invoicing and Transaction Search enabled on the Sandbox app, then a real Sandbox invoice and dispute recorded.
- PayPal onboarding so each restaurant connects its own live account.
- iOS, translated menus and marketing posts drafted by the same coworkers.

## Built with

flutter, dart, serverpod, postgresql, aws, nginx, cloudflare, next.js, react, typescript, ag-grid, ag-studio, firebase-authentication, gemini, gemini-image, paypal-orders-v2, paypal-payouts, paypal-invoicing, paypal-transaction-search, paypal-disputes, paypal-webhooks, paypal-mcp-server, kokoro-tts, remotion

## Testing instructions (private field for judges)

1. Open https://rays.to and press **Try it now**, or open https://ops.rays.to/ops and press **Try Raysto as a judge**.
2. Run the nine cards on the **Try Raysto** page in any order: Close the day, Pay the team, Bill the caterer, Settle a complaint, Chase an unfinished payment, Order lunch in one sentence, Read a printed menu, Take an order by voice, Draw a dish. Approvals that move money ask for the manager password again; it is prefilled for the judge login.
3. For card 6, PayPal's Sandbox page asks for a buyer login: `<Sandbox buyer email>` / `<Sandbox buyer password>` (fill in from the private buyer file; never commit it).
4. Two Sandbox app features are being enabled: Transaction Search (the close then reads PayPal's own list; until then it reconciles from Raysto's ledger and says so) and Invoicing (card 3 quotes, and says that sending is not enabled yet). Payouts (card 2) works.
5. Android: install the APK from https://rays.to/raysto.apk and sign in as the diner (logins in the README), or as the manager to see the staff tablet. The build is 0.15.0 (4 November): Today screen, kitchen drag between lanes, Shifts tab, tip step before PayPal, complaint sheet.
6. The demo café starts fresh every day at 09:00 UTC. Everything is PayPal Sandbox.

## Links

- Try it: https://rays.to
- Code (MIT): https://github.com/FouadABT/raysto
- Owner console: https://ops.rays.to/ops
- API health: https://api.rays.to/ready
