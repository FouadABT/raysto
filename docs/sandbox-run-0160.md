# Sandbox run for 0.16 (template)

**Status: not run yet.** Each row is filled from what PayPal and the backend returned, on production (api.rays.to) with PayPal Sandbox, after backend 0.16.0 and console 0.18.x are deployed. An empty cell means it has not happened. Never fill a cell from memory, from a preview fixture or from another run.

How to fill a row:

- Run the step from the console or the app as written, or with `node tool/judge_path_qa.cjs`.
- Copy the PayPal id from the card, the grid or the task, then check it in the PayPal Sandbox dashboard or with a read-only query (`node tool/judge_restaurant.cjs query <name> '<json>'`).
- Save the screenshot under `docs/qa/<date>/` and link it.
- Write the time in UTC and who ran it.
- A step PayPal refused stays in the table with "refused" and PayPal's error code. That is a result too.

## Money paths

| # | Path | How to run it | Raysto record | PayPal id | Time (UTC) | Ran by | Screenshot | Result |
|---|---|---|---|---|---|---|---|---|
| 1 | A bill paid with PayPal Payouts | Try card 10: read the sample electricity PDF, approve with the identity check | bill # · payout batch # |  |  |  |  |  |
| 2 | A pay link paid by the Sandbox buyer | Try card 12: make the $35.55 link, pay it as buyer 1 | request # · checkout # | capture: |  |  |  |  |
| 3 | A partner settlement request | Accountant: request what Demo Delivery Co. (simulator) owes for its settled orders, as a pay link; pay it as buyer 2 | request # · partner app # | capture: |  |  |  |  |
| 4 | A driver Payout | Payroll: run the `delivery` batch for the courier login's deliveries, approve | payout batch # | batch: |  |  |  |  |
| 5 | A supplier bill | Try card 14 or Supplies: accept the planner's `bill.match` for Marché Dupont's bill, then pay it (Payouts) or mark it paid elsewhere with a proof | bill # · supplier order # | batch, or "paid elsewhere" |  |  |  |  |
| 6 | A refund | Try card 4: approve the complaints agent's partial refund | order # · complaint # | refund: |  |  |  |  |
| 7 | The daily close | Try card 1: run the close after rows 1–6, sign it off | close # | source: PayPal transactions or webhook ledger |  |  |  |  |

## Checks before calling the run done

| Check | How | Result |
|---|---|---|
| The journal balances for the day | `ledger.journal` for the run's date: `balanced` is true |  |
| The close reads the same totals as the profit and loss | `backoffice.close` and `ledger.pnl` for the same day agree on sales, refunds, fees and payouts |  |
| Every id above opens in the PayPal Sandbox dashboard | Search each id; note any that do not |  |
| `docs/facts.json` lists the new ids | Add captures, refunds and payout batches; `web/tests/facts.test.ts` passes |  |
| Nothing on screen claims a PayPal result that is not in this table | Compare the README, Devpost text, judges page and film captions with this table |  |
