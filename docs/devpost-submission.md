# Raysto: Devpost submission text

Copy each section into the matching Devpost field. Everything below is backed by code in this repository or by recorded live runs in [paypal-acceptance-2026-10-31.md](paypal-acceptance-2026-10-31.md) and [ai-evaluation-results.md](ai-evaluation-results.md). All payments are PayPal Sandbox: no real money moves.

## Project name

Raysto

## Elevator pitch

AI coworkers run the back office of a small restaurant: they read the menu, hear orders, chase payments and draw dishes. A person approves every change, and PayPal moves the money.

## Try it (put at the top of the description)

**[rays.to](https://rays.to) → Try it now.** One click signs you into the owner console of a demo café, on a page of five live demos: read a printed menu, take an order by voice, order lunch in one sentence and pay in PayPal Sandbox, chase an unfinished payment through the PayPal MCP server, draw a dish. Two minutes, nothing to install. Logins are in the README and on rays.to.

## About the project

### Inspiration

A snack bar or small restaurant runs on a till, paper tickets and a card terminal that don't talk to each other. The owner then spends the evening typing the menu into one system, chasing a payment that never came through and guessing why the kitchen ran late. We wanted one product that runs the counter and the kitchen from a tablet, takes every payment with PayPal, and gives the owner AI coworkers for the tedious parts, without ever letting an AI move money on its own.

### What it does

**For the counter and the kitchen** (Android tablet):
- A till with a PayPal QR code: the customer pays the counter sale on their own phone; once paid the ticket goes to the kitchen with a daily number. Cash works too.
- **Voice ordering**: the cashier says the order and the counter agent fills the ticket with real dishes and options from the menu. Nothing is charged until the cashier takes payment.
- A kitchen board with new, preparing and ready lanes and urgency colours.

**For diners** (Android app):
- Order ahead for pickup and pay with PayPal; staff check a four-digit pickup code.
- **Ask Raysto**: "Two vegetarian lunches under $25 for pickup at 12:30." Raysto reads the menu, keeps to the budget and the time, and proposes a priced basket. One tap places the order and opens PayPal; only the diner's approval on PayPal's own page pays.
- Table service with a shared room and exact split bills: each diner pays their own share in PayPal.

**For the owner** (console at [ops.rays.to](https://ops.rays.to/ops), AG Grid and AG Studio):
- Today's sales, orders with their PayPal capture ids, payments kept apart by PayPal, cash, refund and attempt.
- An **Agents** inbox where every AI proposal waits with its evidence:
  - the **menu agent** turns a photo of a printed menu into a draft menu: 14 of 14 dishes and prices read in 18 s, new dishes and changed prices marked, unreadable prices held back;
  - the **payments agent** notices a PayPal checkout that never finished, asks PayPal itself through the PayPal MCP server, and prepares the release, which needs the owner's identity check;
  - the **copilot** sees the kitchen running late and proposes a longer promised time, then a shorter one when it is calm;
  - the **image studio** draws a dish photo with Gemini; it is scanned, waits for approval, and diners see it labelled as an AI image.

### How PayPal is used

- **Orders v2** for every online payment: create, buyer approval on PayPal's page, one server-side capture. A capture lease means nothing is ever captured twice; the verified webhook, a reconciliation job and the buyer's return all lead to the same settle step.
- **Verified webhooks**, each event processed exactly once.
- **Counter QR** for walk-in sales, **exact split bills** with one PayPal order per diner's share, and **partial refunds** behind a fresh identity check.
- **PayPal MCP server** (`@paypal/mcp` over stdio) inside the payments agent and Ask Raysto: the AI reads PayPal's own record of a payment before it proposes anything, and says that PayPal was the source.
- **Agentic checkout**: an AI-built basket becomes a real PayPal order in one tap, but only the buyer's approval in PayPal moves money.
- Sandbox only, on one Sandbox business account.

### How AI is used

Gemini 3.6 Flash (Developer API) with function calling, vision and audio; `gemini-3.1-flash-image` for dish photos. Each coworker gets only its own tools:

| Coworker | Tools |
|---|---|
| Menu agent | Gemini vision for the pages, then one organising call |
| Counter voice | Gemini audio with the counter menu |
| Ask Raysto (pickup basket) | `read_menu`, `quote_basket`, `payment_status` |
| Payments agent | `read_ledger`, `read_paypal` (PayPal MCP), `propose_fix` |
| Copilot | `read_kitchen`, `propose_preparation_time` |
| Image studio | Gemini image generation, then the file scanner |

The rules are enforced by the backend, not by prompts:
- Agents run as a service identity that can read and propose but never pass a role check. Every proposal stores its evidence and a fingerprint of the records it saw; if they changed, the approval is refused as stale.
- Money changes need the approver to confirm their identity again.
- The AI never captures, refunds or marks anything paid.
- AI spending has a hard budget per feature and $5 per restaurant per day; each agent has a kill switch.

### How we built it

- **App**: Flutter (Android), phone and tablet layouts, English, French and Arabic.
- **Backend**: Serverpod 4 and PostgreSQL on AWS ([api.rays.to](https://api.rays.to/ready)), with a durable job queue and a separate lane for AI work so a slow model never delays a payment.
- **Console and judges' page**: Next.js 16, React 19, AG Grid, AG Studio.
- **Services**: Firebase Authentication, Gemini Developer API, PayPal Orders v2, Webhooks and MCP.
- **Tests**: backend 85 integration tests on an isolated database and 60 unit tests; console 21; app 145 widget tests.

### Verified live in PayPal Sandbox (31 October to 2 November 2026)

| Journey | Result | PayPal ids |
|---|---|---|
| Pickup order paid in the app | Captured, pickup code issued | capture `633829727B675370M` |
| Counter sale paid by QR | Captured, ticket to the kitchen | capture `4C048952Y13801205` |
| $27.00 table bill split by two buyers | Two $13.50 shares captured, bill settled | captures `4MG67343RS1841023`, `47E23175WJ603464A` |
| Partial refund of $5.00 | Refund completed | refund `2J851836BE9699524` |
| Counter sale on the Android tablet | Captured, ticket #3 to the kitchen | capture `55W092765M630635H` |
| One sentence to Ask Raysto, one tap | 2× Garden pasta $24.00, order placed, approved in PayPal | capture `9BY842216S6346205` |
| Payments agent on an abandoned checkout | Read PayPal via MCP (`PAYER_ACTION_REQUIRED`), release approved after identity check | checkout 10 |
| Live AI evaluation | 12 of 12: 3 menus, 5 spoken orders, 4 takeaway requests | [results](ai-evaluation-results.md) |

### Challenges we ran into

- **Settling once.** A payment can be settled by the webhook, a background job or the buyer's return, in any order. The capture lease and the single settle step took the most testing.
- **AI that can be trusted near money.** Agents had to be useful without being able to act. The answer was a service identity that can only propose, evidence stored with each proposal, and a stale check at approval time.
- **Real-world timing.** Live runs found what tests had not: a copilot alarm from an order scheduled for the next day, a 30-second limit too short for a basket, sessions refused after 100 sign-ins. Each became a fix and a test.

### Accomplishments that we're proud of

- Every PayPal journey and every AI coworker above was run live against PayPal Sandbox and Gemini, with ids recorded.
- A judge can try all five AI demos in two minutes, with nothing to install.
- One backend serves the counter, the kitchen, pickup, table service and the owner console.

### What we learned

PayPal's order states map naturally onto a restaurant: approved is not paid, and capture is the moment that counts. Giving each AI coworker a narrow set of tools and nothing it can execute made it both more useful and easier to trust.

### What's next

- A pilot with one snack bar, on a real menu photo and a real counter voice.
- PayPal onboarding so each restaurant connects its own live account.
- iOS, catering invoices, translated menus and marketing posts drafted by the same coworkers.

## Built with

flutter, dart, serverpod, postgresql, aws, nginx, cloudflare, next.js, react, typescript, ag-grid, ag-studio, firebase-authentication, gemini, gemini-image, paypal-orders-v2, paypal-webhooks, paypal-mcp-server, kokoro-tts, remotion

## Testing instructions (private field for judges)

1. Open https://rays.to and press **Try it now**, or open https://ops.rays.to/ops and press **Try Raysto as a judge**.
2. Run the five cards on the **Try Raysto** page in any order.
3. For card 3, PayPal's Sandbox page asks for a buyer login: `<Sandbox buyer email>` / `<Sandbox buyer password>` (fill in from the private buyer file; never commit it).
4. Android: install the APK from https://github.com/FouadABT/raysto/releases and sign in as the diner (logins in the README), or as the manager to see the staff tablet.
5. The demo café starts fresh every day at 09:00 UTC. Everything is PayPal Sandbox.

## Links

- Try it: https://rays.to
- Code (MIT): https://github.com/FouadABT/raysto
- Owner console: https://ops.rays.to/ops
- API health: https://api.rays.to/ready
