# AI evaluation results

Run on 2026-11-02 12:28 UTC against production (`api.rays.to`) with `tool/ai_eval.cjs all`. Model: Gemini 3.6 Flash (Developer API). Inputs are rendered menu images and synthetic voices (Kokoro TTS), not camera photos or people. Menu proposals were turned down after scoring and no order was placed.

| Agent | Cases | Passed | Median time |
|---|---|---|---|
| Menu agent | 3 | 3 | 17.3 s |
| Counter voice | 5 | 5 | 3.8 s |
| Takeaway assistant | 4 | 4 | 10.0 s |

## Menu agent

| Case | Input | Result | Pass | Time |
|---|---|---|---|---|
| menu-1 | Printed café menu, 14 dishes, 1 without price, 2 priced options | dishes 13/13, prices 13/13, unpriced held 1/1, options 2/2, sections 5 | yes | 19.1 s · $0.013 |
| menu-2 | French bistro chalkboard, handwriting font, comma decimals, 9 dishes | dishes 9/9, prices 9/9, unpriced held 0/0, options 1/1, sections 4 | yes | 13.0 s · $0.008 |
| menu-3 | Food-truck board, two columns, S/L sizes as price columns, 9 dishes | dishes 9/9, prices 9/9, unpriced held 0/0, options 1/1, sections 4 | yes | 17.3 s · $0.009 |

## Counter voice

| Case | Input | Result | Pass | Time |
|---|---|---|---|---|
| voice-1 | "Two croque monsieur, one with a fried egg. A cappuccino with oat milk. And a lemonade. The name is Sam." | 1× Croque monsieur, 1× Croque monsieur +option, 1× Cappuccino +option; name Sam; not on menu: lemonade | yes | 4.4 s |
| voice-2 | "Three espressos and one lemon tart, please." | 3× Espresso, 1× Lemon tart | yes | 3.8 s |
| voice-3 | "A granola bowl and a fresh orange juice. The name is Lina." (British voice) | 1× Granola bowl, 1× Fresh orange juice; name Lina | yes | 3.4 s |
| voice-4 | "Two cappuccinos, one of them with oat milk, and a chocolate mousse." | 1× Cappuccino, 1× Cappuccino +option, 1× Chocolate mousse | yes | 3.8 s |
| voice-5 | "One pizza margherita and a large coke, please." (nothing on the menu) | no lines; not on menu: one pizza margarita, a large coke | yes | 3.4 s |

## Takeaway assistant

| Case | Input | Result | Pass | Time |
|---|---|---|---|---|
| cart-1 | "Something vegetarian for one under $10, as soon as possible." | 1× Roasted vegetables, $9.00 | yes | 10.2 s |
| cart-2 | "Lunch for two under $30: one with chicken, one vegetarian." | 1× Lemon chicken, 1× Garden pasta, $27.00 | yes | 10.0 s |
| cart-3 | "I have a severe nut allergy. What can I order safely?" | no basket: "Because specific allergen safety details are not explicitly listed on our menu, unknown allergens require staf" | yes | 10.1 s |
| cart-4 | "One garden pasta for pickup at 15:30, please." | 1× Garden pasta, $12.00, pickup 15:30 | yes | 7.7 s |

Pass rules. Menu: every dish found, at least 90% of prices exact (a sized dish may take either size), every dish printed without a price held back unavailable. Voice: the exact dishes, quantities, options and name; nothing invented. Cart: the basket respects the stated budget, diet and pickup time; with a stated allergy and no recorded allergens, no basket is offered.
