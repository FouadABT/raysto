# Reviewer guide

Raysto is the till, kitchen board, ordering app and back office for a small restaurant. AI coworkers prepare changes with their evidence, a person approves them, and PayPal moves the money. Everything a reviewer can touch runs on PayPal Sandbox.

## The two-minute path (browser only)

1. Open **[rays.to](https://rays.to)** and press **Try it now**. You are signed into the [owner console](https://ops.rays.to/ops?judge=1) as the manager of the demo café "Atelier Café · Judges".
2. The console opens on **Try Raysto**: five cards, each with one button.

| Card | What happens | Where the AI or PayPal does real work |
|---|---|---|
| 1. Read a printed menu | The menu agent reads the sample menu photo; a table shows each dish, its section and price, with new dishes and changed prices marked. Approve publishes it | Gemini vision reads the page; a person approves the merge |
| 2. Take an order by voice | Send the sample recording, or press **Say your own order**; the counter ticket appears with dishes, options, the customer's name and anything not on the menu | Gemini hears the audio against the café's menu; nothing is charged |
| 3. Order lunch in one sentence | Ask Raysto proposes a basket within your budget and pickup time. **Order and pay with PayPal** places the order and opens PayPal Sandbox; approve with the Sandbox buyer login, and the card shows the capture id and kitchen ticket | Function calling (`read_menu`, `quote_basket`); PayPal Orders v2 capture after the buyer's approval |
| 4. Chase an unfinished payment | A PayPal checkout is created and left unpaid; the payments agent reads the ledger and PayPal, then proposes the release. Approve asks for the password again (prefilled for the judge login) | PayPal MCP server read inside the agent; identity check before a money change |
| 5. Draw a dish for the menu | Gemini draws the chosen dish; the scanned photo waits for approval and then appears on the menu labelled as an AI image | `gemini-3.1-flash-image`; file scan before anyone sees it |

The other console sections show the same café through AG Grid: Overview, Orders (with PayPal capture ids), Payments, Agents (every proposal and what each agent did, with its AI cost) and Floor (AG Studio with three custom widgets).

**Start the café fresh** on the Try page puts the starting menu back; it also resets every day at 09:00 UTC. The manager login cannot rename the café, change its team or take it offline.

## The Android app (optional)

Install the APK from the [releases page](https://github.com/FouadABT/raysto/releases). Sign in as the **diner** to order from the demo café with Ask Raysto and pay in PayPal Sandbox, or as the **manager** to see the staff tablet: the counter till with the PayPal QR and voice ordering, the kitchen board and the Agents inbox. Logins are in the [README](../README.md#try-it-in-two-minutes).

## Evidence

- [PayPal Sandbox acceptance](paypal-acceptance-2026-10-31.md): every journey with its PayPal ids, and the fixes live runs found.
- [Live AI evaluation](ai-evaluation-results.md): 12 of 12 cases on production.
- [Neutral audit](audits/raysto-hackathon-audit-2026-11-02.md) against the judging criteria.

Limits, stated plainly: everything is Sandbox; no real restaurant has used Raysto; the evaluation inputs are rendered images and synthetic voices; iOS is not built.

## Technical review

- Agents: `backend/raysto/raysto_server/lib/src/platform/agents.dart` (approval layer), `agent_payments.dart`, `agent_menu.dart`, `voice.dart`, `agent_copilot.dart`, `agent_images.dart`; the judges' café is `judge.dart`.
- [Architecture and maps](backend-v2/README.md) · [Integration examples](backend-v2/integration.md) · [OpenAPI](backend-v2/openapi.json) · [Permissions and transitions](backend-v2/security-and-states.md) · [PayPal MCP](paypal-mcp.md)
- [Run it yourself](getting-started.md)
