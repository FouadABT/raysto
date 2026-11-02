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

### 1 November: counter sale filmed on a tablet

The Android build (0.12.1, emulator tablet, signed in as the QA owner) rang up three items for $33.00 and showed the PayPal QR code. Buyer 2 approved on a phone-sized browser. The counter showed "Payment received", ticket #3 and a pickup code, and the kitchen board took #3 to Ready.
- Ledger: checkout 9 completed, order 5 (counter, #3) paid, capture `55W092765M630635H`.
- AI check: the manager then asked Ask Raysto on the same tablet. The answer: "No PayPal payment needs attention… PayPal reports COMPLETED for checkout 9: USD 33.00. Source: PayPal MCP."

Before filming, the three earlier orders were moved to completed through ordinary staff commands, so the boards started empty.

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

## Session 3 — AI coworkers (1 November, backend 0.13.0 to 0.13.2)

Live runs of the new agents against production. The menu and voice runs used the QA owner's own unpublished restaurant "Atelier Café · QA" (id 4, EUR), so the demo restaurant's menu did not change. The payment run used the Sandbox restaurant (id 3). Scripts: `tool/agents_live_qa.cjs` and the `abandon` / `operator` modes of `tool/live_session_qa.cjs` (both outside git, like the session 1–2 script).

| Agent | Input | What the agent did | Result |
|---|---|---|---|
| Menu ("Snap your menu") | A rendered image of a printed café menu (not a camera photo): 14 dishes in 5 sections, two priced options, one dish with no price ("ask us") | One Gemini vision call for the page, then one organising call. Task 1 took 18 s and cost $0.013 | 14 of 14 dishes and 14 of 14 prices read. "Soup of the day" was held back as unavailable, with "1 price to check". Options read with their prices: fried egg +1.00 on the croque monsieur, oat milk +0.40 on the cappuccino. The owner approved action 1 and the merge published menu version 2: 14 dishes in 5 sections |
| Payments | Diner 2 ordered a $12.00 pickup (order 6), opened PayPal checkout 10 at 20:47 UTC and never approved it | At 21:18 UTC (30 minutes on, at the next sweep) the agent read the ledger, then PayPal through PayPal MCP over stdio: `PAYER_ACTION_REQUIRED`. It proposed `payment.release`, a money action. 11.3 s, $0.003 | The owner signed in again, passed `identity.stepUp` and approved action 2. Checkout 10 was released (`cancelled`, `released: true`) |
| Takeaway assistant, one tap (0.13.2) | Diner 1 typed: "Two vegetarian lunches under $25 for pickup at 12:30, please." | Run 28: `read_menu`, then `quote_basket` with pickup time 12:30 in the restaurant's zone (tomorrow, since 12:30 had passed). Proposed 2× Garden pasta, $24.00. The first attempt (run 27) timed out at the old 30 s limit and nothing was ordered | One tap (the app's four requests): basket approved, order 7 placed for 12:30, PayPal checkout 11 created. Buyer 1 approved on PayPal's Sandbox page. Checkout completed, order paid, capture `9BY842216S6346205`, pickup code issued |
| Counter voice | A 7.5 s synthetic recording (Kokoro TTS, not a person): "Two croque monsieur, one of them with a fried egg. A cappuccino with oat milk. And a lemonade. The name is Sam." | `POST /api/v2/voice/counter`: one Gemini call with the counter menu and the audio. 3.9 s round trip, 2.6 s on the server | Ticket lines: 1× croque monsieur, 1× croque monsieur with fried egg, 1× cappuccino with oat milk. Customer label "Sam". "lemonade" reported as not on the menu |

On 2 November, with Gemini billing on, the image studio was switched on (`RAYSTO_AGENT_IMAGES_ENABLED`) and run once on the QA café: task 54 asked Gemini (`gemini-3.1-flash-image`) for a photo of the croque monsieur. It took 44 s and $0.04. The photo went through the file scan and re-encode, waited as a proposal, and on the owner's approval became media 13 on the dish with `aiImage` set; the menu version did not change. The photo showed blurred diners in the background despite "no people" in the prompt; the prompt now asks for an empty background (0.13.6).

The console's Agents section loaded on 0.13.0 for the QA owner with no errors and no horizontal scroll at 390 px.

### Fixes found by session 3

- **Menu headings (0.13.1).** Sections came out in the menu's printed capitals ("BREAKFAST"). Headings printed in capitals are now shown as "Breakfast"; names an owner typed keep their case.
- **Voice route size limit (Nginx).** The first voice request got `413` from Nginx, whose `/api/v2/` limit is 128 KB. The exact voice route now has its own 1100 KB limit on Raysto's `api.rays.to` site. Awhar's site was checked unchanged.
- **Payments agent wording (0.13.2).** The release proposal said the payment would free "the table", though this was a pickup order. The ledger read now names the sale (pickup order, counter sale or table bill) and the agent uses those words.
- **Copilot false rush (0.13.4).** On 0.13.3 the copilot measured lateness from when an order was placed, so order 7 (paid tonight for 12:30 tomorrow) looked 30 minutes old and it proposed "Promise 35 minutes instead of 20" twice. Nothing changed, since a manager must approve; the QA owner turned the first card down. Lateness is now measured from each order's due time (its pickup slot, or placement plus the preparation time).
- **Sessions past 100 sign-ins (0.13.5).** After 103 scripted sign-ins the QA owner's new sessions were refused as "revoked": the auth library's token listing returns only the first 100. Raysto now looks the current session up by its id.
- **Assistant time limit (0.13.3).** Run 27 timed out at 30 s while Gemini composed the basket; earlier runs took 14–23 s. Assistant runs now have 45 s; they run in their own worker lane, so no payment job waits on them.

## Session 4 — the judges' path (2 November, backend 0.13.7)

The judges' café ("Atelier Café · Judges", restaurant 5, USD, New York time) was set up by `tool/judge_restaurant.cjs` with three verified accounts: a private owner, a published manager login and a published diner login. The Sandbox merchant now serves restaurants 3 and 5. The run below drove the five **Try Raysto** cards in a real browser (`tool/judge_path_qa.cjs`, kept out of git because it reads the buyer logins), through the console built from this commit and running locally, against the production API. Buyer 1 approved on PayPal's Sandbox page.

| Card | What happened | Time |
|---|---|---|
| One click | `?judge=1` signed in as the manager and opened Try Raysto | 5–8 s |
| 2. Voice | The 7.5 s sample (re-sampled to 8 kHz to fit the console's 128 KB request limit) became: 1× croque monsieur, 1× croque monsieur with fried egg, 1× cappuccino with oat milk, for "Sam"; "lemonade" not on the menu | 4.2 s (2.8 s on the server) |
| 1. Menu | 14 dishes in 5 sections, 1 price change (cappuccino $3.00 → $3.20), soup held back without a price; approved and published | 25 s, $0.013 |
| 4. Payment | An espresso order's PayPal checkout was left unpaid; the payments agent read the ledger, read PayPal through MCP (`PAYER_ACTION_REQUIRED`) and proposed the release; approved after the password step-up; checkout released | 22 s, $0.004 |
| 5. Photo | Gemini (`gemini-3.1-flash-image`) drew the croque monsieur on an empty table; scanned, approved, on the menu | 52 s, $0.040 |
| 3. Order | "Two vegetarian lunches under $25 for pickup at 12:30, please." → falafel wrap and mushroom risotto, $21.50, 12:30 café time; one tap, buyer 1 approved in PayPal | basket 9.7 s; capture `3PV01986C4166344M`, ticket #3, pickup code issued |

### Fixes found by session 4

- **Menu names (0.13.8).** The agent reads "Falafel wrap (vegan)" as the dish "Falafel wrap" marked vegan. The café's starting menu used the printed names, so approving the read added two duplicates. The starting menu now uses the names the agent reads, with the dietary marks.
- **Payments agent wording (0.13.8).** Asked by a manager, the agent wrote "PayPal status shows that the diner left"; that was the manager's report, not a PayPal fact. It now says "you reported" for what a manager saw.
- **Console.** The Agents section did not prefill the judge password at the identity check, so the browser refused the empty field; it now does on the judges' café.

## Owner console

The console at `https://ops.rays.to/ops` (0.12.0, then 0.12.1) showed the same records to the QA owner:
- **Overview:** two orders today, $36.00 collected by PayPal, and the counter/pickup channel mix.
- **Orders grid:** each order opens a panel with its lines, the PayPal capture id and the next step.
- **Payments:** captures, cash, refunds and attempts in separate tabs, with the $5.00 refund on the pickup capture.

## Not covered by these sessions

- Physical-phone runs of the Android build (0.12.1, code 2015). The sessions drove the same backend commands the app sends.
- Delivery, iOS, and live (non-Sandbox) PayPal.
- For the agents: a camera photo of a real paper menu, a person speaking at a real counter, and the one-tap order tapped in the Android app itself (the session sent the same requests from a script).
