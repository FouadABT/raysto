# Raysto 0.16: release notes (draft)

**Status, 4 November 2026: draft.** Nothing in this file is deployed yet. The names streams build against are in `docs/release-0.16-design.md`. Real PayPal ids go in `docs/sandbox-run-0160.md` once they exist, never here first.

0.16 turns the café's back office into AI coworkers with PayPal doing the money: franchise groups, an AI accountant for bills and money owed, delivery with drivers and a partner API, a supply planner, and AG Studio across the analytics. Backend 0.16.0, console 0.18.x, app 0.16.0, migration `20261104013844404`.

## What 0.16 adds

- **Franchise groups.** An owner with several cafés groups them. Group pages compare venues from one journal. Group roles only read; paying anything still needs that café's own membership and the identity check.
- **The AI accountant.** A bill photo or PDF becomes a payable, read by Gemini, matched to last month's bill from the same vendor and checked for duplicates. An approved bill is paid with PayPal Payouts to the vendor's PayPal email, or marked "paid elsewhere" with a proof when the vendor has no PayPal. Money the café is owed becomes a pay link, a standalone PayPal checkout with a QR code, or a PayPal invoice once Invoicing is enabled on the Sandbox app. The ledger is one derived double-entry journal, so the close, the profit and loss and the group pages cannot disagree.
- **Delivery.** Drivers, offers with a countdown, proof of delivery, an AI dispatcher that ranks drivers by distance and load, live tracking on OpenStreetMap, and the Delivery Partner API with signed webhooks. "Demo Delivery Co." is a labelled simulator, not a real delivery company.
- **Supplies.** Recipes draw stock down as orders complete. The planner forecasts days of cover, drafts purchase orders up to par, flags price changes above 5% and runs the 3-way match: order, delivery note, supplier's bill.
- **AG Studio at the centre.** Profit and loss, cash flow, payables, inventory and purchasing as Studio pages; the console's money grids share one column library.

## The judges' café

The full reset (`judge.reset`, daily and on "Start the café fresh") seeds this, labelled "· Sample" in names or notes and `{"sample": true}` in the bills' read data. Each step runs only when its setting is configured on the server.

| What | Rows | Setting |
|---|---|---|
| Second café, "Atelier Harbour · Sample", same owner | its own settings, menu, stock, recipes and bills | `RAYSTO_JUDGE_SECOND_RESTAURANT_ID` |
| Group "Atelier Group · Sample" with both cafés; the judge login is an area manager | 1 group, 2 venues, 2 members | the second café; `RAYSTO_JUDGE_GROUP_ID` optional |
| Delivery for café 1: a 3 km zone, modes pickup and delivery, fee $2.99, minimum $8.00, proof by code | settings | none |
| Drivers: the published courier login plus Sam and Ines, simulated | 3 drivers | a courier membership for the first |
| Bills: electricity last month (paid by transfer), water (approved, no PayPal), rent (paid elsewhere, no PayPal), internet (approved, Sandbox PayPal payee) | 4 bills | `RAYSTO_JUDGE_PAYOUT_EMAILS` for the payees |
| This month's electricity as `expected`, with the utility's Sandbox PayPal email | 1 bill | the payout emails |
| Marché Dupont's bill for the received supplier order, in review | 1 bill | none |
| Supplier orders: an AI-style draft, one sent, one received with the butter at $10.40 instead of $9.80 | 3 orders | none |
| Stock with par levels and lead times, recipes for 10 of the 11 dishes | 8 items, 20 recipe lines | none |
| A catering deposit pay link, made the way `request.create` makes one | 1 request | `RAYSTO_PAY_LINK_SECRET` for an openable link |
| "Demo Delivery Co. (simulator)" kept named, active and marked simulator | 1 partner app | `RAYSTO_SIM_PARTNER_APP_ID` |

Clean-up rules:

- Unpaid bills, unsent drafts and unopened pay links that judges made are removed after 10 minutes, at the next full reset.
- Anything paid stays, with its PayPal ids.
- Stock put back by the reset is an audited `adjust` movement.
- **Re-reading the sample bill.** The hourly tidy releases a bill read from a sample file once it was paid more than an hour earlier. It clears the file hash, marks the reference "(earlier demo run)" and retires the reading task's dedupe key. The amount, the payout batch and the paid date are untouched. Within that hour, reading the same file again shows the duplicate check at work.

## Try cards 10–14

They follow cards 1–9 in `web/src/components/connected/try-section-new.tsx`, under the heading "New in 0.16". A command the deployment does not offer yet reads "… is not available on this deployment yet", and a PayPal feature that is off reads as that. Nothing shows a check mark unless the backend returned it.

| Card | What the judge does | Backend | PayPal |
|---|---|---|---|
| 10 Pay a bill with PayPal | Reads the sample electricity PDF; approves the payment | `media`, `bill.snap`, `agent.task`, `bills`, `bill`, `bill.pay` or the accountant's proposal | Payouts batch id on the bill |
| 11 The accountant's month | Reads this month's books | `ledger.pnl`, `ledger.vat`, `accountant.anomalies`, `accountant.run` | ids quoted per anomaly |
| 12 Ask a customer to pay | Makes a $35.55 pay link, pays it as the Sandbox buyer | `request.create`, `request` | Orders v2 capture id |
| 13 Dispatch a delivery | Sends a simulator order, approves the dispatcher's offer | `/api/partner-sim/orders`, `delivery.board`, `dispatch.suggest`, `partner.events` | none; partner settlement is a separate pay link |
| 14 Never run out | Plans the order, approves it, reads the 3-way match | `stock.forecast`, `supplies.plan`, `supplier.orders`, `bills` | none until the supplier's bill is paid |

The sample bill is `web/public/judges/bill.pdf` (what is read) and `bill.png` (what the card shows), rendered from `tool/judges/bill-sample.html` by `tool/judge_samples.cjs`. It says "Sample" on its face.

## Production setup, in order

1. Deploy backend 0.16.0 with `RAYSTO_PAY_LINK_SECRET`, `RAYSTO_PARTNER_PEPPER` and the existing `RAYSTO_JUDGE_*` settings.
2. Run `node tool/judge_restaurant.cjs accounts`, which adds the published courier login, then `courier`.
3. Run `node tool/judge_restaurant.cjs venue2`, then set `RAYSTO_JUDGE_SECOND_RESTAURANT_ID` on the server.
4. Run `node tool/judge_restaurant.cjs bill`. It uploads the PDF with purpose `bill` and keeps its id.
5. Run `node tool/judge_restaurant.cjs partner [webhook-url]`. The shown-once key goes to `backend/.secrets/partner-sim.json` and is never printed. Then set `RAYSTO_SIM_PARTNER_APP_ID` on the server.
6. Restart the backend, then run `node tool/judge_restaurant.cjs fresh` for café 1 and start café 2 fresh from the console.
7. Run `node tool/judge_restaurant.cjs console`, which writes `NEXT_PUBLIC_RAYSTO_JUDGE_BILL_MEDIA_ID` and the courier login, then build and deploy the console.
8. Run `RAYSTO_QA_OUT=docs/qa/<date> node tool/judge_path_qa.cjs https://ops.rays.to`, which covers all fourteen cards. Record each real id in `docs/sandbox-run-0160.md`.

## Evidence so far

Recorded 4 November 2026 on a development machine; production is not touched.

| Check | Result |
|---|---|
| `judge_test.dart`, isolated Raysto test database, `-j 1` | 8 of 8 pass |
| `web/tests/try-new.test.ts` (card helpers) | 15 of 15 pass |
| `web/tests/browser/try-new.spec.ts` on `/ops/kit/try-new` fixtures | 9 of 9 pass |

The browser fixtures use ids that say PREVIEW; they are not PayPal results.

## Film v2 (script only, not rendered)

`video/src/demo/narration.json` keeps every line the current cut uses and adds six for 0.16: `bill`, `books`, `paylink`, `dispatch`, `supply` and `group`. Suggested order for the 10 November cut: hook, judges, bill, books, paylink, payroll, complaint, order, paid, dispatch, supply, group, montage, evidence, outro. Card 3 and the close move to the montage. `judges` now says fourteen live demos. `evidence` no longer states a coworker count; put it back from `docs/facts.json` once the agent count for 0.16 is settled.

## Copy to paste once 0.16 is live

These drafts claim nothing that has not run. Add each id from `docs/sandbox-run-0160.md` only after it exists, and keep `docs/facts.json` and `web/tests/facts.test.ts` in step.

**README, "What Raysto does" (new paragraph):**

> Raysto now runs the back office too. The AI accountant reads a bill's PDF, files it as a payable and, after the owner's identity check, pays it with PayPal Payouts; a vendor without PayPal is marked paid elsewhere with a proof. Money the café is owed becomes a PayPal pay link with a QR code. Every capture, refund, fee, payout and bill lands in one double-entry journal, which the profit and loss, the daily close and the franchise group pages all read. Delivery apps connect through a signed Delivery Partner API (a labelled simulator shows it), an AI dispatcher ranks the café's drivers, and the supply planner forecasts stock-outs, drafts purchase orders and matches deliveries against bills.

**Devpost, "How AI and PayPal work together" (new bullets):**

> - Bills → PayPal Payouts: Gemini reads the bill, rules catch duplicates and new payees, a person approves, Payouts pays.
> - Receivables → PayPal checkout: a pay link and QR code per request; the capture settles the books.
> - One journal from PayPal's own records: the accountant explains anomalies with the PayPal id they are about.
> - Delivery partners settle outside PayPal; the accountant then sends them a PayPal pay link for what they owe.

**Judges page, Try section:** "Fourteen live demos" in place of nine, with one line per new card: "Pay a bill with PayPal · The accountant's month · Ask a customer to pay · Dispatch a delivery · Never run out." Change `coworkers.demos` in `web/src/lib/connected/judge.ts` and the Try intro in `try-section.tsx` at the same time.

## Open items for other streams

- **S1, accountant.** The `bill.snap` dedupe key is per file. The hourly tidy retires it once the paid bill is released; a key that includes the request key would make that unnecessary. Matching a read bill to its `expected` copy compares vendor names exactly; the PDF prints "Hudson Power & Light · Sample" for that reason.
- **S2, delivery.** Card 13 calls S2's `POST /api/partner-sim/orders` as written: body `{restaurantId}` (so the café's own drivers deliver), the `X-Raysto-Firebase-Token` header, `{data: {ref}}` back. When the simulator is not configured, the card says so and uses the newest delivery waiting on the board. The card has no map yet; it can embed `osm-map.tsx`.
- **S3, supplies.** The seed's supplier order lines carry `receivedQty` and `receivedUnitCostMinor`, the keys `purchasing.dart` reads.
