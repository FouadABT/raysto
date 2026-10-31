# Raysto readiness audit — 31 October 2026

Scope: the whole project as it stands on branch `hackathon/full-suite` (uncommitted), compared with what runs in production at api.rays.to. Three questions: does it work, is it ready for restaurants and snack bars, and should the owner's tablet POS be the app or the web console.

Method: every test suite run fresh; live production checks (read-only GETs); a secret scan of the public repository; one real Gemini call series; two independent code reviews (backend money/ordering, mobile staff/POS screens), whose key findings were re-verified in the code; research on fiscal POS rules and PayPal in-person payments.

## 1. Verdict

| Use | Verdict |
|---|---|
| Hackathon demo in PayPal Sandbox | **Not yet.** Close: four bugs break the demo path (AI basket never appears, Gemini too slow, kitchen blocked after a refund, duplicate sale on retry). About two days of fixes, then the buyer sessions. |
| Supervised pilot at one friendly snack bar | **Not yet.** Needs the fixes below, a tablet layout, receipt printing, a resumable sale, live PayPal and per-item VAT. Several weeks after the hackathon. |
| Replacing a restaurant's cash register | **No.** Missing card payments, cash-up, legal receipts, offline mode and, in Belgium and France, fiscal certification. A multi-month programme with legal input. |
| Tablet POS: app or web | **Native app (Flutter, Android tablet) for counter and kitchen; web `/ops` for the owner's back office.** The web console cannot take an order at all today, and only a native app can drive printers, card readers, kiosk mode and reliable alerts. |

## 2. Does it work? Test and live evidence

| Check | Result |
|---|---|
| Backend unit + integration (isolated `raysto-backend-postgres`) | 111/111 pass |
| Backend `dart analyze` | No issues |
| Web unit tests / typecheck | 9/9 / clean |
| Flutter analyze | No issues |
| Flutter tests | 129 pass, 3 fail. The 3 also fail on a clean `main` (demo-mode viewport tests), so they predate this work |
| api.rays.to `/health` | 200 OK, Sandbox — but runs the **old** release (`main`, 27 Oct) with the money bugs D1/D5/D8 still present |
| Production data | One restaurant: "Raysto Sandbox Table · QA", USD. No real restaurant |
| ops.rays.to | 200, table-centric console |
| rays.to | 503 "landing page is being prepared" |
| PayPal | Zero completed captures in any environment. Webhook registration not confirmed |
| Gemini key | Works since the API was enabled. `gemini-3.8-flash`: 115 s, 22 s, 23 s for a one-word reply. `gemini-3.6-flash`: 4.7 s at the same price. The assistant allows 30 s for up to four rounds, so 3.8 would time out on nearly every question. Local config switched to 3.6 |
| Secret scan of the public repo | No server secrets. Firebase client API keys are present by design (public identifiers); check their API restrictions in Google Cloud |
| Git | Nothing from 28–31 Oct is committed; branch exists only on this PC |

Green tests do not mean it works: both reviews found real bugs the tests did not cover.

## 3. Defects found in this audit (verified in code)

Most are in code written on 29 October. Severity is for real-money use.

### Critical / high

| # | Area | Defect | Effect |
|---|---|---|---|
| H1 | Counter (mobile) | `charge()` chains quote → submit → allocate → read with fresh request keys; a network drop after allocate and a retry creates a second order | Two kitchen tickets, cash recorded twice |
| H2 | Money (backend) | `payment.release` assumes provider calls end within 3 min; a slow capture can complete after the release. Cancelled checkouts are never read again, so the capture is silently lost | Customer charged, bill reopened, possible double payment |
| H3 | AI (mobile) | Ask Raysto waits for `completed`; a basket proposal sets the run to `review` | The basket never appears; page spins forever. Breaks the pickup-AI demo |
| H4 | AI (provider) | `gemini-3.8-flash` latency 22–115 s | Every assistant run times out. Switch to 3.6-flash (config) and re-measure |
| H5 | Ordering (backend) | Refund fix incomplete: `kitchen.progress` and courier handoff still require `paid` | A partly refunded order is stuck at "preparing" forever |
| H6 | Live updates (mobile) | Restaurant feed starts at cursor 0 | On every start the boards replay all history (100 events / 2 s) and hammer Firebase lookups; real changes appear late |
| H7 | Counter (backend) | Counter sales pass the online-ordering checks (paused, opening hours, enabled modes, published) | Pausing online orders in a rush also stops the till; empty hours = till never works |
| H8 | Kitchen (mobile) | Modifier options are objects; the ticket joins them as raw maps | Cook reads `{id: g:o, name: No onion, priceMinor: 0}` |
| H9 | Tablet (mobile) | No tablet layout anywhere: single-column phone screens | At 1280×800 the cashier scrolls past the whole menu for every sale; kitchen "columns" are stacked |
| H10 | Permissions (backend) | `counter` replaced the manager check for all non-table orders, and any role can hold it | A kitchen or courier member with `counter` can record cash on, or cancel, paid app orders and read customers' order chats |

### Medium

- Counter shows a locally computed total; the server may add tax or use newer prices, so the cashier can collect a different amount from the one recorded.
- Daily ticket numbers can collide after a timezone change, failing every submit until midnight (500 error).
- The customer basket assistant can be used by any signed-in user or guest and draws on the single platform-wide AI budget.
- "Split equally" leaves the table host out of the payer list for other diners.
- Orders awaiting payment or out for delivery are filed under "Done" on the boards.
- Live feed never reconnects after ~6 s offline (falls back to a 10 s poll for the session).
- Boards drop refresh notices that arrive during a load, and the list shifts under the finger on each refresh.
- PayPal QR polling has no in-flight guard or timeout; a failed checkout leaves the order in "awaiting payment" and a retry adds another.
- The staff shell opens over the customer tabs and over notification destinations; Android back drops an active basket or QR.
- "Record cash" is one tap with no amount shown and no undo.
- Too many taps per sale: cashier must accept (auto-accept defaults off), then ready, collected and complete; "Mark ready" shows before lines are ticked and is then refused.
- Pickup codes are 4 random digits, not unique per day; lookup searches 24 h, not the service day; collection never checks the code; the code is sent to Gemini in `pickup_ready`.
- A reconcile read rewrites `updatedAt`, which the capture lease relies on.
- The walk-in expiry job fails if the cashier's profile is removed; one job slot serves payments, pushes and AI.
- Money is printed as `12.50 EUR`, not localised.

Each item carries file:line evidence in the two review reports; the fixes are small and local except H2 (lease redesign) and H9 (layout).

## 4. Restaurant and snack-bar readiness

### What exists and works (tested locally)
Menu and modifiers, pickup and dine-in ordering with server-side pricing, table visits and the group room, PayPal Sandbox checkout with strict amount/merchant checks, refunds, staff roles and capabilities, counter sale with ticket number and pickup code, kitchen board, orders board, cash recording, AI basket and manager assistant (once H3/H4 are fixed), step-up for sensitive actions, tenant isolation, audit trail, daily database backups.

### What a POS needs that Raysto does not have

| Need | Status |
|---|---|
| Card payments | **Missing.** Only PayPal (Sandbox) and hand-recorded cash. Most snack-bar customers pay by card. PayPal's in-person product (PayPal POS / Zettle, with Tap to Pay) has native Android/iOS SDKs only |
| Live PayPal | Sandbox only; merchant onboarding blocked; live switch not approved |
| Receipt and kitchen printing | **Missing.** No ESC/POS, Bluetooth, USB or network printer support |
| Cash drawer, float, cash-up, end-of-day (Z) report | **Missing** |
| Legal receipts | **Missing.** No customer receipt with business details, VAT breakdown and sequential numbering |
| VAT | **One rate per restaurant.** Restaurants need per-item rates and different rates for eating in vs taking away (for example food vs alcohol; dine-in vs takeaway) |
| Fiscal certification | **None.** Belgium: certified GKS 2.0 register with a fiscal data module for horeca above €25,000 on-premises meal turnover, mandatory for new businesses since 1 July 2026. France: NF525 certification or an editor attestation for VAT-registered cash software. Morocco: no register certification found; e-invoicing is being phased in |
| Discounts, voids, tendered amount and change | **Missing** at the counter |
| Offline mode | **Missing.** Every sale needs the server; a drop mid-sale triggers H1 |
| Shared tablet: fast staff switching (PIN) | **Missing.** One Firebase account per device |
| Kiosk mode, keep-awake, sound alert for new tickets | **Missing** |
| Currencies | EUR, USD, GBP only. No MAD; PayPal does not offer Moroccan merchants local acceptance in dirhams |
| Operations | No monitoring or alerting, no offsite backup or tested restore, production shares a small EC2 host with Awhar (512 MiB cap for Raysto) |
| Legal pages | No privacy policy, terms, or data-processing agreement for restaurants |

## 5. Tablet POS: app or web

**Recommendation: the Flutter app on an Android tablet (10–11", landscape) for the counter and the kitchen; the Next.js `/ops` console in a browser for the owner's back office.**

| Factor | Flutter app (Android tablet) | Web `/ops` |
|---|---|---|
| Can ring up a sale today | Yes (counter screen) | **No** — no order-entry command anywhere in `/ops` |
| Receipt / kitchen printers, cash drawer | Yes, via native plugins (Bluetooth, USB, LAN) | Very limited (WebUSB/WebBluetooth on Chrome only; no raw network printing; nothing on iPad Safari) |
| Card payments with PayPal POS / Zettle, Tap to Pay | Possible (native SDKs) | Not possible |
| Kiosk / lock-task, keep screen on, auto-start | Yes (Android) | Partial |
| New-order alerts with sound in background | Yes (FCM) | Unreliable |
| Offline queue | Possible (local storage + sync) | Harder |
| Dense reports, grids, exports, menu admin | Weaker | Strong (AG Grid / AG Studio) |
| Project rules | Flutter is the mobile client; no Flutter web target allowed | Separate React app for the owner console |

What the app needs before a tablet pilot: a two-pane counter (menu grid left, ticket and pay right), side-by-side kitchen columns, a navigation rail in landscape, staff PIN switching, kiosk and keep-awake, a sound on new tickets, and printer support. Choose one well-supported Android tablet model and one printer model to start with, rather than supporting everything.

## 6. Hackathon re-score

| Criterion | 29 Oct (claimed) | 31 Oct (after this audit) | If fixes + plan ship |
|---|---|---|---|
| Technical implementation | 7.5 | **7** | 8.5 |
| Design | 6.5 | **6** | 8 |
| Potential impact | 7.5 | **7** | 8 |
| Innovation | 7.5 | **7.5** | 8.5 |
| Presentation | 5 | **5** | 8 |
| **Total** | 34 | **32.5 / 50** | **41–43 / 50** |

The drop from 34 reflects defects the 29 October score did not know about (H1, H3–H5, H9). The ceiling is unchanged because every one has a known, local fix.

## 7. Recommended order of work

1. **Fix the demo-breaking bugs (1–2 days):** H3, H4 (model), H5, H8, H6, H7, H1, H10, then the medium items that touch the demo (split host, awaiting-payment filter, QR polling, local total).
2. **Commit** the work in dated commits (Devpost "progress during the six weeks").
3. **Deploy** backend and migration to api.rays.to; register the PayPal webhook.
4. **Buyer session 1:** pickup and counter QR with the two Sandbox buyers.
5. **Tablet layout** for counter and kitchen (two-pane, landscape).
6. **`/ops`** overview, orders and payments (AG Grid prize).
7. **Buyer session 2:** two-buyer split, partial refund, MCP read. Fix H2 before any real money.
8. Android build, film, Devpost text.
After the hackathon, for a pilot: printing, legal receipts, per-item VAT, cash-up, PIN switching, offline queue, live PayPal, card payments (PayPal POS SDK), monitoring and offsite backups, legal pages; then fiscal certification for the launch country.

## Sources

- Belgium GKS 2.0: [fiskaly](https://www.fiskaly.com/blog/gks-2-0-fdm-requirements-belgium), [VATupdate, July 2026 deadline](https://www.vatupdate.com/2026/06/12/gks-2-0-mandatory-for-hospitality-businesses-from-july-1-2026/), [fiscal-requirements.com](https://www.fiscal-requirements.com/news/5864-when-do-belgian-horeca-businesses-need-to-switch-to-gks-20)
- France NF525: [Cabinet Kohen Avocats](https://kohenavocats.fr/?p=1995962), [myPOS](https://www.mypos.com/fr-fr/blog/guide-entreprise/logiciels-de-caisse-certifies), [SumUp](https://www.sumup.com/fr-fr/gerer-son-entreprise/paiements/caisse-enregistreuse-obligatoire/)
- Morocco: [EDICOM e-invoicing](https://edicomgroup.com/fr/blog/maroc-obligation-facturation-electronique), [CASHPLUS × PayPal withdrawals](https://www.zawya.com/en/press-release/companies-news/cashplus-partners-with-paypal-to-simplify-withdrawals-and-global-shopping-for-morocco-s-digital-generation-j5jhisl1), [Wise on PayPal in Morocco](https://wise.com/gb/blog/can-i-use-paypal-in-morocco)
- PayPal in-person: [Zettle Tap to Pay](https://www.zettle.com/gb/payments/tap-to-pay), [Apple Tap to Pay regions](https://developer.apple.com/tap-to-pay/regions/), [TechCrunch on Tap to Pay on Android](https://techcrunch.com/2023/06/28/paypal-launches-support-for-tap-to-pay-on-android-for-merchants-using-venmo-and-zettle-in-the-u-s/)

Legal summaries come from secondary sources; confirm with the tax authority or an accountant in the launch country before relying on them.
