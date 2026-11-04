# Sandbox run for 0.16

**Status: rows 1, 2, 6 and 7 ran on 4 November 2026 against backend 0.16.0/0.16.1 and console 0.18.0/0.18.1 on production; rows 3, 4 and 5 have not run yet.** Each row is filled from what PayPal and the backend returned, on production (api.rays.to) with PayPal Sandbox, after backend 0.16.0 and console 0.18.x are deployed. An empty cell means it has not happened. Never fill a cell from memory, from a preview fixture or from another run.

How to fill a row:

- Run the step from the console or the app as written, or with `node tool/judge_path_qa.cjs`.
- Copy the PayPal id from the card, the grid or the task, then check it in the PayPal Sandbox dashboard or with a read-only query (`node tool/judge_restaurant.cjs query <name> '<json>'`).
- Save the screenshot under `docs/qa/<date>/` and link it.
- Write the time in UTC and who ran it.
- A step PayPal refused stays in the table with "refused" and PayPal's error code. That is a result too.

## Money paths

| # | Path | How to run it | Raysto record | PayPal id | Time (UTC) | Ran by | Screenshot | Result |
|---|---|---|---|---|---|---|---|---|
| 1 | A bill paid with PayPal Payouts | Try card 10: read the sample electricity PDF, approve with the identity check | Hudson Power & Light HPL-2026-11-0417 · payout batch #9 (kind `bill`) | batch: K5EHYWJ2YBBQ8 (completed) | 18:22:48 | Claude, `tool/judge_path_qa.cjs` | [try-bill-paid.png](qa/2026-11-04-0160/try-bill-paid.png) | Paid. The first run on 0.16.0 read the bill but found no payee, because the vendor name did not match the expected copy exactly; fixed in 0.16.1 |
| 2 | A pay link paid by the Sandbox buyer | Try card 12: make the $35.55 link, pay it as buyer 1 | catering deposit pay link · journal capture #15 | capture: 9BX29653G6291915K | 17:51:09 | Claude, `tool/judge_path_qa.cjs` | [try-paylink-paid.png](qa/2026-11-04-0160/try-paylink-paid.png) | Paid 19 s after the link opened. The first attempt on 0.16.0 got a 404: Nginx did not route `/pay/`; fixed the same day |
| 3 | A partner settlement request | Accountant: request what Demo Delivery Co. (simulator) owes for its settled orders, as a pay link; pay it as buyer 2 | request # · partner app # | capture: |  |  |  |  |
| 4 | A driver Payout | Payroll: run the `delivery` batch for the courier login's deliveries, approve | payout batch # | batch: |  |  |  |  |
| 5 | A supplier bill | Try card 14 or Supplies: accept the planner's `bill.match` for Marché Dupont's bill, then pay it (Payouts) or mark it paid elsewhere with a proof | bill # · supplier order # | batch, or "paid elsewhere" |  |  |  |  |
| 6 | A refund | Try card 4: approve the complaints agent's partial refund | order 29 · journal refund #6 | refund: 3HS05577CC683905V | 17:41:08 | Claude, `tool/judge_path_qa.cjs` | [try-complaint.png](qa/2026-11-04-0160/try-complaint.png) | $13.50 of $21.50 refunded |
| 7 | The daily close | Try card 1: run the close after rows 1–6, sign it off | close for 2026-11-04 | source: webhook ledger ("PayPal source not recorded") | 17:39:48 | Claude, `tool/judge_path_qa.cjs` | [try-close.png](qa/2026-11-04-0160/try-close.png) | Signed off. It ran before rows 1, 2 and 6, so it shows no money; Transaction Search is still off in the Sandbox app |

## Checks before calling the run done

| Check | How | Result |
|---|---|---|
| The journal balances for the day | `ledger.journal` for the run's date: `balanced` is true |  |
| The close reads the same totals as the profit and loss | `backoffice.close` and `ledger.pnl` for the same day agree on sales, refunds, fees and payouts |  |
| Every id above opens in the PayPal Sandbox dashboard | Search each id; note any that do not |  |
| `docs/facts.json` lists the new ids | Add captures, refunds and payout batches; `web/tests/facts.test.ts` passes |  |
| Nothing on screen claims a PayPal result that is not in this table | Compare the README, Devpost text, judges page and film captions with this table |  |

## Other real ids from the same run

| Card | What happened | PayPal id | Time (UTC) |
|---|---|---|---|
| 2 Payroll | Wages sent through PayPal Payouts after approval | batch: LSQETJ2QB55Z4 | 17:39:56 |
| 6 Order and pay | The one-sentence order paid by the Sandbox buyer | capture: 4B674470UL685961J | 17:44:18 |

The 0.15.1 check run earlier the same day (about 02:14 UTC) also left capture 6KA28102CB433905M, refund 5CM99257TT453104U and Payouts batch YCM8E55AAW8HA; all three are in the café's journal and in `docs/facts.json`.
