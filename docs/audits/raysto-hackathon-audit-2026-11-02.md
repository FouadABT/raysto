# Raysto hackathon audit — 2 November 2026

A neutral assessment of Raysto as it stands today against the PayPal AI Hackathon's official judging criteria and rules (paypalaihackathon.devpost.com, Official Rules §4 and §6). The demo video is left out of this audit on purpose; the Presentation criterion is scored as "not assessed".

Everything below was checked in the repository, on the production server or in recorded live runs on 1–2 November. Nothing is taken from plans.

## 1. What exists (verified)

**Backend** (Serverpod 4 / PostgreSQL, live at `api.rays.to`, release 0.13.6)

- 82 commands and 46 queries behind a role model (owner, manager, kitchen, waiter, courier, customer, guest) and a service identity for agents that can read and propose but never run a command.
- PayPal Sandbox: Orders v2 checkout, server-side capture (webhook, return page and retry job), partial refunds behind an identity step-up, exact per-person split of a table bill, counter sale with a PayPal QR, and a verified-webhook inbox. One shared Sandbox merchant.
- AI (Gemini 3.6 Flash, Developer API, billing on): four background agents (`payments`, `menu`, `copilot`, `images`), the counter voice route, and the takeaway assistant with a one-tap order. Every change an agent proposes waits for a person; money changes also need the identity step-up. Budget: $100 hackathon stage split by feature, $5 per restaurant per day.
- Tests: 81 integration (isolated database) + 57 unit, all passing on 2 November.

**Staff and customer app** (Flutter, Android build `dist/raysto-0.13.1-2017-android-arm64.apk`, not yet run on a physical device)

- Staff: orders board, counter with cash or PayPal QR and voice ordering, kitchen board, Agents inbox, Snap your menu, Photo with AI. Redesigned on 2 November (side rail, state-coloured cards, kitchen urgency bands).
- Customer: storefront, basket, checkout, table room with split bill, Ask Raysto with "Order and approve in PayPal".
- English, French and Arabic (184 connected strings), 320 px and 2× text layouts covered by tests. 145 widget tests pass; 3 older offline-demo layout tests fail (they failed before this week's work).
- An explicit offline demo mode exists with a *simulated* payment screen.

**Owner console** (Next.js 16 + AG Grid/AG Studio, live at `ops.rays.to`, release 0.14.0)

- Overview, Orders, Payments, Agents and Floor sections; AG Studio with three custom widgets. Redesigned on 2 November. 16 unit tests pass; typecheck clean.
- AG Grid Enterprise is loaded through AG Studio's evaluation key, which expires 10 December.

## 2. Live evidence

| Run | Result | Where |
|---|---|---|
| Sessions 1–2 (31 Oct–1 Nov) | Pickup, counter QR, two-buyer split, $5 partial refund, AI reading PayPal via MCP; all captured in Sandbox | `paypal-acceptance-2026-10-31.md` |
| Menu agent | 14/14 dishes and prices from a rendered menu image, 18 s, $0.013; approved merge published | same |
| Payments agent | Abandoned checkout 10 investigated through PayPal MCP, released after step-up | same |
| Counter voice | Synthetic 7.5 s order heard exactly, 3.9 s | same |
| One-tap order | Sentence → $24 basket → order 7 → buyer 1 approved in PayPal → capture `9BY842216S6346205` | same |
| Image studio | Gemini photo of a dish, scanned, approved, labelled "AI image", 44 s, $0.04 | same |
| Live evaluation | 12/12 cases: 3 menus, 5 voice orders, 4 takeaway requests | `ai-evaluation-results.md` |

Caveats judges would notice: inputs are rendered images and synthetic voices, not camera photos or people; everything is Sandbox; no real restaurant has used it.

## 3. Rule compliance

| Rule (§4) | Status |
|---|---|
| Public repository, open-source licence visible | Met: public on GitHub, MIT. |
| Functional demo judges can run (hosted URL *or* complete run instructions) | **Partly met.** The console is hosted but needs an invited owner login, and no judge credentials are published. Running the connected app from source needs Firebase and backend secrets a judge does not have; only the offline demo is reachable from the README. |
| Text description explaining features | **Out of date.** README, `devpost-submission.md` and `reviewer-guide.md` predate the agents, voice, copilot and image studio. Rules allow judges to score from the text alone. |
| Tools list with how each was used | Partly: Gemini and PayPal are listed; the PayPal MCP server, AG Studio, Kokoro TTS and Remotion are not described as tools. |
| Existing-project disclosure | Not required: all 54 commits date from 26 October. |
| Access until 15 December | At risk: AG Studio key ends 10 December; the server, Gemini billing and Sandbox buyers must stay up. |
| Third-party licences | Check that AG Studio's evaluation key permits a public submission. |
| Prize stacking | One Grand *or* one Honourable Mention, plus one Sponsor prize. |

## 4. Stage One (pass/fail)

**Pass.** PayPal is central (money only moves through PayPal Sandbox; the AI investigates payments through PayPal's own MCP server) and AI is central (it reads menus, hears orders, builds orders, draws photos and investigates payments).

## 5. Stage Two scores (equal weight; Presentation not assessed)

| Criterion | Score /10 | Reasoning |
|---|---|---|
| Technological implementation | **8.0** | Thorough, skilled use of both platforms with live proof and a real test suite. Deductions: single Sandbox merchant; defects found only in the last 48 hours (sessions past 100 sign-ins refused, a 30 s timeout, a false copilot alert) point to little time under load; AI steps take 4–44 s; evaluation is small and synthetic; no device run. |
| Design | **7.0** | Staff tablet and console form one coherent system; three languages and accessibility are handled. Deductions: customer screens are still plain forms; the offline demo's simulated payment screen sits beside the real product; three layout tests fail; the redesign is a day old and unseen on a device. More than a proof of concept, not a finished product. |
| Potential impact | **7.0** | A specific audience (small restaurants and snack bars) and a specific set of problems (till, kitchen timing, split bills, payment follow-up, menu entry), each addressed by something demonstrated. Deductions: no real user or venue; Sandbox only; a real venue could not onboard today (shared merchant); no argument for switching from established POS products. |
| Innovation / idea | **8.0** | "AI coworkers prepare, people approve, PayPal moves the money" is a distinct framing; the payments agent on PayPal MCP and the one-sentence order gated only by PayPal approval are uncommon. The parts (menu OCR, food photos, voice orders) exist elsewhere; the combination and the approval model are the novelty. |
| Presentation | not assessed | Video excluded. |

**Average of the four assessed criteria: 7.5 / 10.**

**As a judge would see it today: about 6.** The substance is a 7.5, but the documents describe last week's product and a judge cannot reach the agents without credentials, so a judge who does not build from source would score the older, smaller product.

## 6. Prize fit

- Best Use of PayPal + AI: strongest fit (PayPal MCP in an agent, PayPal-gated agentic order).
- Best Use of Agentic Commerce: plausible on the same two features; cannot be won together with the above.
- Best Use of AG Grid: eligible, at risk from the 10 December key expiry.
- Grand prizes: competitive on substance; held back by the write-up and access.

## 7. What would change the score

1. Rewrite README, `devpost-submission.md` and `reviewer-guide.md` around what exists, with the live evidence and the 12/12 evaluation, and list every tool and how it is used. (Presentation text, Technological implementation, Impact.)
2. Publish a judge path: a GitHub release with the APK and checksum, judge owner and customer logins on a dedicated restaurant, Sandbox buyer steps in the private testing notes. (Compliance.)
3. Resolve AG Studio licensing before 10 December. (Compliance, AG Grid prize.)
4. Run the app on a physical phone and tablet; add real photos and a real voice to the evaluation. (Implementation, Design.)
5. Clean the demo restaurant (close test order 7, clear stale agent cards) and remove or clearly fence the simulated payment screen. (Design, Impact.)

## 8. Update, 2 November evening: the judge path

Same method, same neutrality. What changed since the morning, all checked live:

| Item from section 7 | Status |
|---|---|
| 1. Write-up matches the product | Done. README leads with a two-minute path, lists every tool and how it is used, and states limits; Devpost text and reviewer guide rewritten; `tool/check_docs.cjs` refuses retired claims and broken links. |
| 2. Judge path | Mostly done. [rays.to](https://rays.to) is a guided page; one click signs into the console as the manager of a dedicated Sandbox café (restaurant 5) and opens five live demos. All five ran end to end on the hosted console against production (session 4 in the acceptance notes, captures `3PV01986C4166344M` and `1FC985713C934991E`). Logins are public; the café's identity, team and opening stay with a private owner, and it resets daily. **Open:** the APK is built (0.14.0+2018, judge sign-in buttons, offline demo behind "Design preview"; 145 widget tests pass, the same 3 older offline-demo tests fail) but not yet uploaded as a GitHub release. |
| 3. AG Studio licence | Fallback ready (`NEXT_PUBLIC_RAYSTO_STUDIO=off`); the extension request is still Fouad's. |
| 4. Physical device, real photo and voice | Not done. Judges can now record their own voice in the console, but no human run is recorded yet. |
| 5. Demo restaurant and simulated payment | Judges no longer touch restaurant 3. The simulated payment screen is behind "Design preview" in the judge build. |

| Criterion | Morning | Now | Why |
|---|---|---|---|
| Technological implementation | 8.0 | 8.5 | Judges can run every AI coworker and the PayPal flows themselves, against production, in two minutes; four more defects found and fixed by the run. Still no device run and a small, synthetic evaluation. |
| Design | 7.0 | 7.5 | One guided, coherent path from rays.to to a result on screen; the simulated payment is out of the judge's way. Customer screens in the app are still plain forms and the device run is missing. |
| Potential impact | 7.0 | 7.5 | A judge experiences the problem being solved (menu entry, voice till, unfinished payment) rather than reading about it. Still Sandbox and no real venue. |
| Innovation / idea | 8.0 | 8.0 | Unchanged. |
| Presentation (written part) | ~4.5 | 8.0 | The text now describes the product that exists, with evidence and limits. The video is not assessed. |

**Average of the five (video excluded): 7.9. As a judge would see it: about 7.9**, since the gap between the substance and what a judge can reach is closed. Reaching above 8 needs the remaining items: the APK release, a physical-device run, a real menu photo and a human voice in the evaluation, and a polish pass on the customer screens.

## 9. Cold judge's pass, 2 November night

A second reviewer who had not seen sections 5–8 judged Raysto the way a Devpost judge would: the README, the Devpost draft and about 15 minutes on rays.to. Its findings were checked against the code, the live console and screenshots before being recorded here. Section 8's 7.9 was too generous. It left the video out, and it gave impact and innovation credit that a cold reader does not give.

**What a judge hit on the live path**

| Finding | Checked |
|---|---|
| First AI result 9.5 s after opening rays.to (voice card); menu card 18 s, 14 dishes, 3 new, 1 price change | yes, screenshots |
| Payments agent: PayPal MCP read shown as evidence, identity check, release ran, about 22 s | yes |
| **Draw a dish failed** after about 2 minutes with "Gemini took too long to draw the photo" (the server's 120 s limit, `media_ai.dart:92`); earlier runs today took 44–48 s | yes |
| **Order in one sentence moved pickup from 12:30 to 2:15 PM without saying why**. The suggested sentence fixes the time at 12:30 New York time, which has already passed for most of the judging day. The reply was the backend's generic line, not the model's. | yes, `assistant.dart` fallback |
| PayPal's page names the merchant "Test Store" (no `brand_name` is sent) and follows the visitor's browser language | yes, no `experience_context` in the backend |
| The README, rays.to and the Devpost text point to a GitHub release that does not exist yet | yes, 0 releases |
| Counts disagree: rays.to says four AI coworkers, the README lists six, the Try page has five demos; "145" means backend tests on rays.to and app widget tests in the Devpost text | yes |
| Floor at 1440 px: the AG Studio canvas is squeezed between two panels, the widget thumbnails are blank, "Outstanding bills" breaks mid-word, and the AI Assistant panel shows the takeaway order conversation | yes, screenshot |
| Orders grid cuts off "Awaiting Payment" and the Customer column; the restaurant picker reads "Judges · mana" | yes |
| The copilot raised "kitchen rush" proposals in the judges' café because paid demo orders never move on | reported by the reviewer, not rechecked |
| No demo video under 3 minutes exists; the 60-second promo from 1 November shows none of the five demos | yes |

**Scores as a judge would give them tonight**

| Criterion | Score | Why |
|---|---|---|
| Technological implementation | 8.0 | Real agents, real PayPal Sandbox, MCP and a backed approval gate, all runnable by a judge. One of five demos failed in front of the judge. |
| Design | 7.5 | The judges' page and the Try page are polished and clear. The Floor/AG Studio section, cut-off labels and plain customer screens in the app hold it back. |
| Potential impact | 6.5 | The problem is real and specific. Sandbox only, a single shared merchant, no merchant onboarding and no real venue. |
| Innovation | 7.0 | The approval model and the payments agent reading PayPal through MCP are fresh; menu reading and voice orders exist elsewhere. |
| Presentation | 7.5 written / about 5 with the current video | The text is clear, honest and evidenced, but long, and has the claim and link problems above. No demo video exists. |

**Average: 7.3 on the written submission; about 6.8 if the 60-second promo were submitted as the video.** Above 8 needs a strong demo video, the judge-path fixes above and one real-world proof point (a real venue's menu and voice).

## 10. After the fixes, 2 November night

Everything section 9 found on the judge's path was fixed and checked on production: backend 0.13.9, console 0.15.2, the Android build 0.14.1 served at `rays.to/raysto.apk`, and a 2 min 25 s film at `rays.to/demo.mp4`, cut from a recorded run of all five demos (capture `8DJ62510842222013`). The diner screens were restyled, the three old app test failures were fixed (154 pass), an hourly tidy keeps the judges' café clean (checked: stale demo orders closed), and a Raysto-only watch restarts the backend or console if either stops answering.

This is the same reviewer's method applied by the author, so treat it as an estimate. A fresh cold read is the honest check.

| Criterion | Section 9 | Now | Why |
|---|---|---|---|
| Technological implementation | 8.0 | 8.5 | All five demos ran end to end on production; slow photos are retried; 326 automated tests pass. Still one Sandbox merchant and synthetic inputs. |
| Design | 7.5 | 8.0 | The Floor, grid labels and diner screens are fixed; one coherent look from rays.to to the tablet. No physical-device run yet. |
| Potential impact | 6.5 | 6.5 | Unchanged: no real venue, Sandbox only. The path to each café connecting its own PayPal is now stated, but it needs PayPal's partner approval. |
| Innovation | 7.0 | 7.0 | Unchanged. |
| Presentation | ~5 with no film | 8.0 | A film of the real product with captions, under three minutes; screenshots and consistent numbers in the text. The voice is synthetic. |

**Average: about 7.6.** What still separates it from 8+: one real venue (a phone photo of its menu, the owner's voice, a quote), a human voice on the film, and possibly an agentic-commerce piece where any AI assistant can order from the café and pay with PayPal.
