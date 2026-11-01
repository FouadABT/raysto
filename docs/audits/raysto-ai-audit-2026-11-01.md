# AI audit: is Raysto's use of AI meaningful? (1 November 2026)

**Question.** The PayPal AI Hackathon requires meaningful use of both PayPal and AI. Does AI have a real role in Raysto, or is it a chat bolted onto a working POS?

**Short answer.** The AI is real, well built and safe. But it is on the edge of the product, not in the middle of it.
- Every AI feature is optional and lives in a side screen.
- The main business flows (counter, kitchen, pickup, owner console) contain no AI at all.
- Where the AI does run, it either answers questions or drafts a proposal that a person then completes in three more steps.
- In the manager assistant, the final payment answers come from fixed templates, so the model mostly picks which database query to run.

A judge watching the demo will most likely see "a POS with a chatbot". That is the opposite of what the "Best Use of PayPal + AI" and "Agentic Commerce" prizes reward.

**Score: 17 / 35** (rubric in section 5).

Method: read the code paths (`assistant.dart`, `automation.dart`, `shares.dart`, `providers.dart`, the mobile flows in `assistant_flows.dart`, `room.dart`, `shopping.dart` and `operations.dart`), then queried production (`raysto_assistant_run` and `raysto_ai_operation`).

---

## 1. Inventory: every place AI is used

### A1. Table room assistant (diners at a table)

| | |
|---|---|
| Where | "Ask Raysto" inside the table room (`room.dart`), run by `AssistantModule` |
| Model | Gemini 3.6 Flash with function calling: up to 4 rounds, 30 s, 8 tool calls |
| Tools | `read_menu`, `read_room`, `read_bill`, `read_operations`, `quote_basket`, `propose_payment`, `payment_status`, `operations_summary` |
| What the AI decides | (a) Turns a group request ("two vegetarians, under $30, something to share") into chosen menu lines. (b) Turns "I'll pay for the pasta and half the starter" into per-item fractions of the bill. |
| What it can change | Nothing directly. It creates a **proposal**. The basket is priced by the server, and the proposal expires and is re-checked against menu and bill versions. |
| After approval | Basket: becomes a price quote, then the person submits the order, then pays. Payment: becomes that diner's share reservation, then PayPal. |
| Works without AI? | The basket can be built by hand. **Fractional splits cannot be expressed in the UI without AI.** The equal split was moved out of AI into a plain button (`room.split.equal`). |
| Production evidence | 17 room runs, 7 succeeded, 10 failed. All the failures were on 26–27 Oct with Vertex AI (timeouts, capacity, unavailable). **No room run since the switch to the Developer API on 31 Oct.** |
| Verdict | **The most meaningful AI in Raysto, but under-shown.** The demo shows the room with screenshots from 26 Oct. The one thing only AI can do here, the itemised split, appears nowhere in the demo. |

### A2. Pickup basket assistant (one customer, takeaway)

| | |
|---|---|
| Where | "Ask Raysto what to order" on a restaurant page (`shopping.dart`, `context: cart`) |
| Tools | `read_menu`, `quote_basket`, `payment_status` |
| What the AI decides | Picks a pickup basket within a budget and diet |
| After approval | Quote, then submit, then PayPal, all done by the customer |
| Works without AI? | Yes: the menu and basket work without it |
| Production evidence | **0 runs ever** |
| Verdict | Real, but untested live and invisible in the demo. AI is a shortcut here, not a role. |

### A3. Manager assistant ("Ask Raysto about today")

| | |
|---|---|
| Where | Staff shell → More (`staff_shell.dart`, `AskRaystoPage(manager: true)`) |
| Tools | `sales_summary`, `kitchen_load`, `pickup_ready`, `unresolved_payments`, `operations_summary`, `payment_status`, `read_menu`. **All read-only.** |
| What the AI decides | Which read to run. For payment questions, the final sentence is a fixed template (`factualAnswer`), not model text. |
| What it can change | Nothing. No proposals, no actions. |
| Works without AI? | Yes. Every figure is already on the owner console. |
| Production evidence | 9 runs, 8 succeeded. The last 6 runs (31 Oct – 1 Nov, Gemini 3.6 Flash) all succeeded. |
| Verdict | **Weakest in a judge's eyes:** a chat over SQL. The templates are good engineering (the AI cannot misreport money), but they also make the AI invisible. The instruction even says "say what the manager should do next", yet the AI cannot do any of it. |

### A4. PayPal status through MCP (inside A1, A2 and A3)

| | |
|---|---|
| What it does | `payment_status` reads one PayPal order or refund through the official `@paypal/mcp` server (stdio), with REST as a fallback, and checks amount and currency against the ledger |
| Production evidence | Runs 21–26 used MCP over stdio, about 5 s each |
| Verdict | A genuine PayPal and AI link, but **read-only and one record at a time**. The AI never creates, captures or refunds anything through PayPal, not even as a draft for a person to approve. |

### A5. Menu AI jobs (extract, generate, translate)

| | |
|---|---|
| Where | Restaurant → menu → "Create an AI draft" (`operations.dart`), run by `AiModule.run` |
| What the AI decides | `menuExtract` reads a photo or PDF of a menu (Gemini vision) into items with prices, ingredients and allergens, with unknowns left empty and flagged for review. `menuGenerate` drafts items from a description. `translate` translates the menu. |
| After approval | A menu draft the manager edits and publishes |
| UX | **Raw forms.** You pick a task by its internal name (`menuExtract`), type a numeric "Uploaded menu reference" you have to remember from an earlier dialog, and review a data dump. |
| Production evidence | 2 runs ever (1 approved, 1 failed), both `menuGenerate`. **`menuExtract` has never run in production.** |
| Verdict | **The most valuable AI for a snack bar** ("photograph your menu board, get a digital menu in two minutes"). The backend is ready, but in practice it is unusable and absent from the demo. |

### A6. `recommend` job (legacy)

A single-shot "suggest dishes" job: no tools, and it returns lines for the cart. A2 does the same with tools and live pricing. It duplicates A2 and should be hidden.

### A7. Places with no AI at all

Counter sale, PayPal QR, kitchen board, pickup codes, orders board, owner console (overview, orders, payments), refunds, payment release and reconciliation, delivery, team, reports, settings.

These are exactly the flows the demo leads with.

---

## 2. What is good and should stay

- **Strict tool scoping per context.** The room, the basket and the manager each get only their own tools, and the backend refuses any other.
- **Server-authoritative proposals.** Prices come from the server, not the model. Proposals have versions, expire, are re-checked on approval, and are bound to the person who approved them.
- **Safety rules in the instructions and in code.** All text is treated as untrusted. Unknown allergens are "not safe". Prices and payments are never invented. Facts from PayPal are templated, not paraphrased.
- **Budget control.** A $35 + $15 hard cap, a 20-a-day limit per customer, and rate limits.
- **Audit trail.** Each run stores its tool trace, including MCP transport and fallback reasons.
- **Every money movement needs the person's own PayPal approval.** This is exactly how agentic commerce should work.
- **A written evaluation set** (`docs/ai-evaluation.md`, 12 cases), though it was last run on Gemini 3.8.

These are real strengths. The problem is not quality but **role and reach**.

---

## 3. Why a judge may call it "not meaningful"

1. **AI is optional everywhere.** "AI is never required to move money" was a design principle, but it has turned into "AI is never required for anything". Turn the AI off and the demo still works.
2. **AI never completes a job.** The best case ends at a draft basket. The person then approves, submits and pays separately. Nowhere does the AI carry a task from intent to a PayPal approval screen.
3. **The manager AI only reads.** It summarises data the console already shows. There is no action, recommendation or proposal.
4. **AI and PayPal only meet in a read-only status check.** For "Best Use of PayPal + AI", the AI should drive the PayPal flow (prepare orders, investigate problems, draft refunds) with a person approving.
5. **AI's unique jobs are hidden.** The itemised split and menu-photo import are the two things only AI can do. Neither is in the demo or reachable through a polished screen.
6. **Thin live evidence for the customer side.** The room assistant has not run since the model switch, and the basket assistant has never run.
7. **The demo shows AI as screenshots and a chat answer.** The new 60-second video shows the table AI as stills from 26 Oct and Ask Raysto as a Q&A.

---

## 4. Recommendations: give AI a job, not a chat window

Principle: **the AI does the work; PayPal approval (or one tap from a manager) is the human gate.** Keep every safety rule. Change what the AI is allowed to *prepare*.

### R1. Agentic checkout: from a sentence to the PayPal approval screen (highest impact, ~1.5–2 days)

A customer says "two vegetarian lunches under $25 for pickup at 12:30". The agent:
1. reads the menu;
2. builds and prices the basket;
3. creates the order in `awaitingPayment`;
4. creates the PayPal checkout;
5. returns **one button: approve in PayPal**.

Why this is safe:
- With pay-before, an unpaid order never reaches the kitchen and expires by itself (the existing `order.expire`).
- The person's PayPal approval is the consent, which is exactly PayPal's agentic-commerce model.
- The same applies at the table: "I'll pay for my pasta and half the starter" produces a reserved share and a PayPal link in one step.

Backend:
- A new `prepare_checkout` tool, with the same checks as `order.submit` and `payment.allocate`, bound to the requesting user. The proposal type becomes `checkout`.
- A cap per run (one order, an amount limit).

App:
- The proposal card shows the items, the total and "Approve in PayPal".

This makes AI the main path for ordering, and PayPal the place where the person decides.

### R2. AI payment operator: AI that works without being asked (~2 days)

When something goes wrong with money, a background AI run starts by itself:
- a checkout stuck in `capturing` or `uncertain`;
- an approval left unfinished;
- a capture after release (`captureAfterRelease`);
- a PayPal reversal or dispute webhook.

The AI then:
1. reads the ledger, the order and the PayPal order or capture through MCP;
2. classifies the case: approved but not captured, abandoned, captured after release, refund pending, reversed;
3. writes a one-line explanation;
4. **drafts the fix**: reconcile, release, or a refund proposal for the exact amount.

The manager sees "Raysto found 1 payment to resolve: checkout 12 was approved at PayPal 18 minutes ago but never captured. Recommended: capture now." The manager approves with one tap, and refunds still need the step-up. This puts AI inside operations and uses PayPal plus MCP for a real job. Most of it reuses `unresolved_payments`, `payment_status`, `payment.release`, `payment.refund` and the existing job worker.

### R3. Menu onboarding from a photo (~1.5 days, mostly the app)

Turn `menuExtract` into a real flow:
1. take a photo or pick a PDF;
2. "Reading your menu…";
3. a review list with the fields the AI was unsure of highlighted ("price not found", "allergens unknown");
4. publish.

This is the strongest AI story for small restaurants: a snack bar is selling in minutes. It is vision AI doing work a person would otherwise type. The backend already exists; it needs a guided screen and an end-to-end test in production.

### R4. Show the itemised split (~0.5 day)

Add a chip in the room: "Split by what we ordered". For example: "I had the pasta, Sam had the salad, we shared the starter." The AI turns that into per-item fractions (already supported by `propose_payment.parts`), and each person pays their own share in PayPal. Keep the equal-split button too; it is a fallback, not the AI's job.

### R5. Manager agent that proposes actions (~1–1.5 days)

Give the manager AI **action proposals** that the manager approves with one tap:
- pause online orders for 20 minutes when the kitchen is overloaded;
- push the pickup time back;
- mark an item sold out;
- release a stuck checkout;
- send the end-of-day summary.

The AI watches the reads it already has (`kitchen_load`, `pickup_ready`) and suggests the action. This turns "chat over SQL" into an assistant that runs the shop with you.

### R6. Proof (~0.5 day, always)

- Re-run the 12-case set in `docs/ai-evaluation.md` on Gemini 3.6 Flash, plus new cases for R1, R2 and R4.
- Record success rate, latency and cost.
- Run the room and basket assistants live at least once each.
- Put the numbers in the Devpost text, for example "AI evaluation: 14/15 cases passed, median 4.7 s".

### What not to do

- Don't add more chat screens.
- Don't let the AI move money without PayPal approval, or refund without the manager's step-up.
- Don't remove the fact templates. Keep them, and let the model add a short, separate recommendation.

### Suggested order with 10 days left

| Order | Work | Days | Why |
|---|---|---|---|
| 1 | R1 agentic checkout (pickup and table share) | 2 | Puts AI in the main ordering path; fits the Agentic Commerce prize |
| 2 | R2 AI payment operator | 2 | AI with PayPal + MCP doing an operational job; fits Best Use of PayPal + AI |
| 3 | R4 itemised split chip | 0.5 | Shows a job only AI can do, with two PayPal buyers |
| 4 | R3 menu-photo onboarding | 1.5 | The strongest small-business AI story |
| 5 | R6 evaluation and live runs | 0.5 | Turns claims into evidence |
| 6 | R5 manager action proposals | 1–1.5 | If time remains |
| — | Re-record the demo around R1, R2 and R3 | 1 | The video should open with AI doing the work |

---

## 5. Scoring rubric (0–5 each)

| Criterion | Score | Reason |
|---|---|---|
| Centrality: is AI in the main flows? | 1 | Counter, kitchen, pickup and console have none |
| Agency: does AI complete tasks? | 2 | It drafts proposals; a person finishes every task |
| Necessity: is anything impossible without AI? | 2 | Itemised split and menu-photo import, both hidden |
| PayPal + AI link | 2 | MCP read-only status checks |
| Safety and guardrails | 5 | Scoped tools, server prices, versioned proposals, templates, budget |
| Reliability and evidence | 3 | Manager 6/6 since the model switch; customer AI not run since; evaluation not re-run |
| Quality of the AI screens | 2 | Room and Ask screens are good; menu AI is raw forms |
| **Total** | **17 / 35** | |

With R1, R2, R4 and R6 done, the expected score is about 28/35. Adding R3 and R5 brings it to 31–32.

---

## 6. Production data used (read on 1 Nov 2026)

- `raysto_assistant_run`: 26 runs.
  - 13 completed, 2 in review (the 26 Oct basket and split proposals), 11 failed.
  - All failures were on 26–27 Oct with Vertex AI: 3 unavailable, 5 timeouts, 2 capacity, 1 provider error.
  - Runs 21–26 (31 Oct – 1 Nov) were all manager runs and all completed; `payment_status` used PayPal MCP over stdio.
- `raysto_ai_operation`: 2 `menuGenerate` runs (1 approved, 1 failed). No `menuExtract`, `translate` or `recommend` runs.
- Production flags: `RAYSTO_AI_PREVIEW_ENABLED=true` and `RAYSTO_PAYPAL_MCP_ENABLED=true`. Model `gemini-3.6-flash` through the Developer API.
