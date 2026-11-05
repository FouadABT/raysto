# Reviewer guide

Raysto is the AI operating system for restaurants: AI coworkers prepare the money work, a person approves it, and PayPal moves the money. Everything a reviewer can touch runs on PayPal Sandbox.

## The two-minute path (browser only)

1. Open **[rays.to](https://rays.to)** and press **Enter the live demo**. You are signed into the [owner console](https://ops.rays.to/ops?judge=1) as the manager of the demo café, Atelier Café, on its **Overview**.
2. At the top is the **AI Action Inbox**: work the AI coworkers have prepared, each with its reasons, its evidence and whether it moves money. Press **Approve** or **Not now**. An approval that moves money asks for the password again (prefilled for the demo login); then PayPal moves the money and the card shows PayPal's own id.
3. Beside it, **Start new work** has four starters. Each sets an AI coworker to work, and its proposal lands in the inbox within seconds:

| Starter | What the AI does | What PayPal does after you approve |
|---|---|---|
| A bill arrived | The AI accountant reads the café's electricity bill (vendor, amount, VAT, due date), checks it was not paid before, and drafts paying it | PayPal Payouts pays the vendor; the card shows the batch id |
| A guest complained | The complaints agent reads the complaint, the kitchen ticket and PayPal's capture through PayPal's MCP server, and proposes a fair refund | PayPal refunds the guest; the card shows the refund id |
| Run this week's payroll | The payroll agent turns the week's shifts into wages and splits the tips | PayPal Payouts sends one batch; the card shows its id |
| Collect a deposit | A catering deposit becomes a PayPal pay link with a QR code | You scan and pay with the Sandbox buyer login (Devpost testing instructions); the card shows the capture id |

4. Below, **The café at a glance** and an AG Studio canvas show the last 30 days of sales and money. The past days are sample sales paid in cash or by card at the counter, marked by the **Demo café** badge; anything paid through PayPal is a real Sandbox payment with its PayPal id.

The other sections show the same café: Orders, Payments, Agents (every proposal, with its AI cost), Money, Team, **Accountant** (bills, pay links, profit and loss, cash flow, payables and VAT on AG Studio), Supplies, **Dispatch** (a map, drivers and the labelled delivery-partner simulator), **Group** (two cafés under one owner) and Floor. The scripted demos of earlier versions (reading a printed menu, a voice order, drawing a dish, the daily close) remain at [ops.rays.to/ops?judge=1&section=try](https://ops.rays.to/ops?judge=1&section=try).

The demo café starts fresh every day at 09:00 UTC. The manager login cannot rename the café, change its team or take it offline.

## The Android app (optional)

Install the APK from [rays.to/raysto.apk](https://rays.to/raysto.apk); its checksum and install steps are on [rays.to](https://rays.to). Sign in as the **diner** to order from the demo café with Ask Raysto and pay in PayPal Sandbox, or as the **manager** to see the staff tablet: the counter till with the PayPal QR and voice ordering, the kitchen board and the Agents inbox. Tap **Sign in as a diner** or **Sign in as the café manager**; there is nothing to type. The served build is 0.16.0 (4 November): 0.15.0 plus the AI accountant, supplies, the courier's deliveries, the group's Today and the PayPal account page.

## Evidence

- [PayPal Sandbox acceptance](paypal-acceptance-2026-10-31.md): every journey with its PayPal ids, the 3 November run of the nine cards (session 6), and the fixes live runs found.
- [The 0.16 run](sandbox-run-0160.md): the bill paid with Payouts, the pay link, the refund and the close, 4 November.
- [Live AI evaluation](ai-evaluation-results.md): 12 of 12 cases on production.
- [Neutral audit](audits/raysto-hackathon-audit-2026-11-02.md) against the judging criteria, scored before the money agents.

Limits, stated plainly: everything is Sandbox on one merchant account; Invoicing and Transaction Search are still being enabled on that account, so no real Sandbox invoice or dispute is recorded yet; no real restaurant has used Raysto; the evaluation inputs are rendered images and synthetic voices; the supplies and expenses agents are covered by tests, not yet by a production run; iOS is not built.

## Technical review

- Agents: `backend/raysto/raysto_server/lib/src/platform/agents.dart` (approval layer), the money agents `agent_close.dart`, `agent_payroll.dart`, `agent_catering.dart`, `agent_complaints.dart`, `agent_disputes.dart`, `agent_supplies.dart`, `agent_expenses.dart`, `agent_loyalty.dart`, and `agent_payments.dart`, `agent_menu.dart`, `voice.dart`, `agent_copilot.dart`, `agent_images.dart`; back-office records and queries in `backoffice.dart`; the judges' café is `judge.dart`. PayPal Payouts, Transaction Search and Disputes calls are in `providers.dart`; the twelve-tool MCP client is `lib/src/services/paypal_mcp_client.dart`.
- [Back-office design](back-office-design.md): the rule each money feature follows and the contract between backend, console and app.
- [Architecture and maps](backend-v2/README.md) · [Integration examples](backend-v2/integration.md) · [OpenAPI](backend-v2/openapi.json) · [Permissions and transitions](backend-v2/security-and-states.md) · [PayPal MCP](paypal-mcp.md)
- [Run it yourself](getting-started.md)
