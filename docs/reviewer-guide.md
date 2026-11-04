# Reviewer guide

Raysto is the till, kitchen board, ordering app and back office for a small restaurant. AI coworkers run the café's money with PayPal's own tools, a person approves, and PayPal moves it. Everything a reviewer can touch runs on PayPal Sandbox.

## The two-minute path (browser only)

1. Open **[rays.to](https://rays.to)** and press **Try it now**. You are signed into the [owner console](https://ops.rays.to/ops?judge=1) as the manager of the demo café "Atelier Café · Judges".
2. The console opens on **Try Raysto**: nine cards, money first, each with one button. Approvals that move money ask for the password again (prefilled for the judge login).

| Card | What happens | Where the AI or PayPal does real work |
|---|---|---|
| 1. Close the day | The close agent reads the day and PayPal's transaction list, lists the gaps with an explanation each, and proposes the sign-off. Until Transaction Search is enabled on the Sandbox app the card says the close is from Raysto's ledger | MCP `list_transactions` / REST Transaction Search; a person signs off |
| 2. Pay the team | The payroll agent turns this week's clocked shifts into wages and splits the tip pool, one batch with a line per person. **Send with PayPal** needs the identity check; the card then shows the Payouts batch id | PayPal Payouts after approval |
| 3. Bill the caterer | The seeded request ("lunch for 12 on Friday, budget $150") becomes a priced quote with a deposit. **Send the invoice** needs the identity check; the card then shows the invoice number and QR code, or says that Invoicing is not enabled on the Sandbox app yet | PayPal Invoicing through the MCP server after approval |
| 4. Settle a complaint | The seeded complaint on a paid order: the agent reads the kitchen ticket and PayPal's capture, proposes a full, partial or no refund. Approve needs the identity check; the card shows PayPal's refund id | PayPal MCP read, then Refunds after approval |
| 5. Chase an unfinished payment | A PayPal checkout is created and left unpaid; the payments agent reads the ledger and PayPal, then proposes the release | PayPal MCP server read inside the agent; identity check before a money change |
| 6. Order lunch in one sentence | Ask Raysto proposes a basket within your budget and pickup time. One tap places the order and opens PayPal Sandbox; approve with the Sandbox buyer login, and the card shows the capture id and kitchen ticket | Function calling (`read_menu`, `quote_basket`); PayPal Orders v2 capture after the buyer's approval |
| 7. Read a printed menu | The menu agent reads the sample menu photo; a table shows each dish, its section and price, with new dishes and changed prices marked. Approve publishes it | Gemini vision reads the page; a person approves the merge |
| 8. Take an order by voice | Send the sample recording, or press **Say your own order**; the counter ticket appears with dishes, options, the customer's name and anything not on the menu | Gemini hears the audio against the café's menu; nothing is charged |
| 9. Draw a dish for the menu | Gemini draws the chosen dish; the scanned photo waits for approval and then appears on the menu labelled as an AI image | `gemini-3.1-flash-image`; file scan before anyone sees it |

The other console sections show the same café through AG Grid: Overview, Orders (with PayPal capture ids), Payments, Agents (every proposal and what each agent did, with its AI cost), **Money** (close, pay and tips with PayPal batch ids, catering, refunds and disputes, expenses, customers, analytics), **Team** (shifts, clock in and out, the roster proposal) and Floor (AG Studio with three custom widgets). The supplies, expenses and loyalty agents have no Try card; their work shows in Money once run from the console.

**Start the café fresh** on the Try page puts the starting menu back; it also resets every day at 09:00 UTC. The manager login cannot rename the café, change its team or take it offline.

## The Android app (optional)

Install the APK from [rays.to/raysto.apk](https://rays.to/raysto.apk); its checksum and install steps are on [rays.to](https://rays.to). Sign in as the **diner** to order from the demo café with Ask Raysto and pay in PayPal Sandbox, or as the **manager** to see the staff tablet: the counter till with the PayPal QR and voice ordering, the kitchen board and the Agents inbox. Logins are in the [README](../README.md#try-it-in-two-minutes). The served build is 0.16.0 (4 November): 0.15.0 plus the AI accountant, supplies, the courier's deliveries, the group's Today and the PayPal account page.

## Evidence

- [PayPal Sandbox acceptance](paypal-acceptance-2026-10-31.md): every journey with its PayPal ids, the 3 November run of the nine cards (session 6), and the fixes live runs found.
- [Live AI evaluation](ai-evaluation-results.md): 12 of 12 cases on production.
- [Neutral audit](audits/raysto-hackathon-audit-2026-11-02.md) against the judging criteria, scored before the money agents.

Limits, stated plainly: everything is Sandbox on one merchant account; Invoicing and Transaction Search are still being enabled on that account, so no real Sandbox invoice or dispute is recorded yet; no real restaurant has used Raysto; the evaluation inputs are rendered images and synthetic voices; the supplies and expenses agents are covered by tests, not yet by a production run; iOS is not built.

## Technical review

- Agents: `backend/raysto/raysto_server/lib/src/platform/agents.dart` (approval layer), the money agents `agent_close.dart`, `agent_payroll.dart`, `agent_catering.dart`, `agent_complaints.dart`, `agent_disputes.dart`, `agent_supplies.dart`, `agent_expenses.dart`, `agent_loyalty.dart`, and `agent_payments.dart`, `agent_menu.dart`, `voice.dart`, `agent_copilot.dart`, `agent_images.dart`; back-office records and queries in `backoffice.dart`; the judges' café is `judge.dart`. PayPal Payouts, Transaction Search and Disputes calls are in `providers.dart`; the twelve-tool MCP client is `lib/src/services/paypal_mcp_client.dart`.
- [Back-office design](back-office-design.md): the rule each money feature follows and the contract between backend, console and app.
- [Architecture and maps](backend-v2/README.md) · [Integration examples](backend-v2/integration.md) · [OpenAPI](backend-v2/openapi.json) · [Permissions and transitions](backend-v2/security-and-states.md) · [PayPal MCP](paypal-mcp.md)
- [Run it yourself](getting-started.md)
