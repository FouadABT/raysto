# Matched USD tasks

6 November 2026. Every business value here is illustrative. No real supplier document or restaurant result is represented. Use the input card below for participants; keep the answer key out of their task packet. These tasks have identical operations, input fields and constraints, with different amounts. Equivalence is designed, not empirically established.

## Participant input cards

| Input | Exercise A: lunch bowl | Exercise B: snack bowl |
|---|---|---|
| Previous confirmed receipt | 1 kg prepared ingredients, USD 10.00 | 1 kg prepared ingredients, USD 10.40 |
| New confirmed receipt | 1 kg same ingredients, USD 11.00 | 1 kg same ingredients, USD 11.40 |
| Recipe | 350 g, 100% usable yield | 300 g, 100% usable yield |
| Packaging | Explicitly confirmed USD 0.00 for reusable dine-in crockery | Same |
| Menu price | USD 9.00 | USD 8.00 |
| Recorded tax treatment | Zero tax for this illustrative exercise | Same |
| Included fee assumption | Zero for this exercise; not a PayPal fee claim | Same |
| Owner policy | 60% contribution target, 10% maximum increase, USD 0.10 increments | Same |
| Volume | Assume 100 units, compare 0%, -10%, -20%; this is not sales history | Same |
| Additional challenge | Narrow this comparison to a 5% cap; inspect USD 9.80 separately | Narrow to 5%; inspect USD 8.70 separately |
| Incomplete second dish | Seasonal bowl lacks a confirmed ingredient receipt cost | Same |

Task: identify the changed input; establish current dish cost and contribution; compare keeping the price with the lowest qualifying price; explain volume assumptions and break-even; challenge the cap; inspect the owner's price; keep, propose, defer or reject with a reason; explain the incomplete-dish refusal. Do not publish a price or send a payment during the observed usability task.

## Facilitator answer key

A: cost moves from USD 3.50 to 3.85. Keeping USD 9.00 contributes USD 5.15 before shared overhead. Lowest qualifying price USD 9.70 contributes USD 5.85. At 100/90/80 units the scenario contribution is USD 585.00/526.50/468.00. Break-even is 89 units against keeping the current price at the new cost. Keeping the price requires USD 0.25 lower included variable cost to meet 60%, without asserting such a saving exists. A 5% cap is infeasible. USD 9.80 yields USD 5.95 contribution under the original 10% policy, but is analysis-only under a narrowed 5% case cap.

B: cost moves from USD 3.12 to 3.42. Keeping USD 8.00 contributes USD 4.58. Lowest qualifying price USD 8.60 contributes USD 5.18. At 100/90/80 units the scenario contribution is USD 518.00/466.20/414.40. Break-even is 89 units. Keeping the price requires USD 0.22 less included variable cost. A 5% cap is infeasible. USD 8.70 yields USD 5.28 under the original cap and remains analysis-only under 5%.

For both, unknown ingredient cost cannot become zero. No demand, profit, supplier availability or actual outcome is inferred. Contribution excludes shared overhead. Proposal preparation is separate from publication; customer collection and supplier payout require their own existing approvals.

Run `python tool/check_decision_exercises.py` to cross-check the key using independent Decimal arithmetic. Human facilitator review before sessions remains required.
