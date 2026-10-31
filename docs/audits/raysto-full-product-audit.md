# Raysto full product audit

**Date:** 28 October 2026
**Commit:** `a9fcb19` on `main`, with uncommitted work:
- `room.dart`, `connected_app.dart` and `pubspec` were changed to add a markdown renderer for assistant replies.
- New, untracked: `assistant_message_body.dart` and its test, `tool/render_video_test.dart`, `video/` and `docs/RAYSTO_COMPLETE_PROJECT_BRIEF.txt`.

**Baseline:** the owner's scope correction of 28 October 2026. Raysto is a complete restaurant and snack-bar platform. The shared visit is one feature among many and must not be required for counter, pickup, delivery or solo orders.

**Companion files:**
- [feature coverage](raysto-feature-coverage.csv): 85 requirements with stable IDs.
- [image inventory](raysto-image-inventory.csv): 72 reference panels.
- [correction plan](raysto-correction-plan.md).

## How to read this report

| Label | Meaning |
|---|---|
| **Fact** | Read in source at the cited line. |
| **Verified** | Observed in a check run during this audit. |
| **Reported** | Stated in an existing dated document; not re-observed. |
| **Proposal** | My recommendation, not missing agreed work. |

## 1. Product definition and evidence baseline

### Inspected
- Flutter 3.47.8 / Dart 3.13 app (`lib/`, about 37k lines), pinned in `.tooling/flutter`.
- Serverpod 3.4.8 backend (`backend/raysto/raysto_server`, about 16k lines of domain code, 80 commands).
- Next.js 16.4.3 / React 19.3.1 web app with AG Grid Community 36.2.0 and AG Studio 3.0.0 (`web/`).
- Firebase project raysto-38505.
- Live endpoints, by GET only:
  - `api.rays.to/health` returned 200.
  - `ops.rays.to/ops` returned 200.
  - `rays.to` returned 503. The landing page is reserved, so this is expected.

### Surfaces, audited separately

| Surface | Entry | Data |
|---|---|---|
| Connected mobile app | `lib/main.dart` → `ConnectedAccountEntry` → `ConnectedApp` | Real REST v2 (`/api/v2/queries\|commands`) |
| Offline demo, mobile | "Explore the offline demo" link | `lib/domain/store.dart` (DemoStore) |
| Connected web console | `/ops` | Real backend via `web/src/app/api/raysto/[...path]/route.ts` |
| Web prototype | every other web route | localStorage `raysto.web.demo.v1`, money hard-coded to MAD |
| Legacy v1 API | `commerce`/`restaurant` endpoints, `/api/v1/orders` | Second order and payment engine, still exposed |

### Where the narrowing happened

`docs/product-direction.md:3-7`, the project brief (`RAYSTO_COMPLETE_PROJECT_BRIEF.txt:11`: "Its central experience is an authorized table conversation") and the product film (`tool/render_video_test.dart`, room in 8 of 11 shots) all present the visit room as the product. The audit found the narrowing is **real, but uneven**:

- **Backend: broad.** Catalogue, ordering for dine-in/pickup/delivery, kitchen, delivery, tables, reservations, waitlist, team, money, reports, support and AI all exist. The order engine does not require a visit.
- **Mobile UI: narrow in investment.**
  - The table room (`room.dart`, 1,258 lines) is the only purpose-built connected screen.
  - Every other connected screen is a generic form plus a key/value dump. `RecordSummary` (`lib/features/connected/forms.dart:415`) prints raw keys. Every action pushes a full-page `RecordEditor` (`forms.dart:37`, called from `connected_app.dart:77`).
  - The polished role shells, kitchen board, floor editor, menu tools, reports and delivery desk exist **only in the offline demo**.
- **Web console: narrow in data model.** The `operations.snapshot` rows are dining tables (`workspace.dart:68-176`). Pickup and delivery appear only as rows in a thin Orders tab.
- **Missing everywhere: a genuine snack-bar gap.** There is no counter or staff-on-behalf order, no order number, and no cashier capability.

## 2. Reference images

There is no `images/` folder. The reference set is `ui/1.png`–`ui/14.png`: 14 boards containing 72 numbered concept panels (#01–#72). There are 48 phone panels, 23 desktop panels and 1 tablet panel. All were opened and read; none were unreadable. Each is listed in [the inventory](raysto-image-inventory.csv) with REF-01…REF-61 feature IDs.

**Classification.** Every `ui/` panel is a *reference concept*. They carry the "Restaurant OS / Olive Kitchen" sample brand, show the Material 3 baseline purple (#52 literally shows `#6750A4`), and the sample data contradicts itself across boards. Treat them as intended coverage, not as a specification or a palette.

**`docs/screenshots/`:**
- `story/*.png` are golden renders from `tool/render_raysto_story_test.dart`.
- Four `story/operations-*.png` files are real browser captures of `/ops` against QA data.
- The root PNGs are 0.1-era renders.

**What the references show, and what they don't:**
- The boards are channel-balanced:
  - Delivery/pickup/dine-in toggles: #04, #06, #14, #32, #43, #61.
  - A cross-channel kitchen display: #63.
  - Delivery dispatch: #45, #64.
  - Owner reports with channel mix: #66.
  - Settings with per-channel toggles and dine-in "pay at end": #68.
- They contain **no** counter/POS screen, **no** multi-person group ordering, and **no** reservations.
- The closest thing to a cashier is the waiter bill screen (#41: Card/Cash/Mobile, guest scan-to-pay QR).

The shared-visit room the project centred on is therefore not in the references. The broad operational suite is.

### Reference-to-implementation map (connected app)

| Reference | Feature | Connected route or screen | Result | Gap |
|---|---|---|---|---|
| #04–#06 | Discover, search, storefront, mode switch | `DiscoveryPage` / `StorefrontPage` (`shopping.dart:3,168`) | Connected | No filter sheet; one empty confirm page per add |
| #07–#08 | QR scan, visit hub | `scanTable` → always the room (`shopping.dart:135-154`) | Connected | The room is forced; the hub is only reachable from inside it |
| #10 | Modifiers | `chooseItem` (`shopping.dart:352`) | Partial | Checkboxes used for single-choice groups |
| #11–#12, #70 | AI ordering for one diner | Room assistant (visit only); `recommend` assistant (no allergens, not priced) | Partial / blocked | No priced AI basket outside a visit; Gemini 429 |
| #13–#18 | Cart, delivery details, PayPal checkout, pending, confirmed | `BasketPage` → `QuotePage` → `allocate` → `checkoutPage` (`activity.dart:425-631`) | Wired; never captured | Raw dumps, three confirm pages, manual "I approved" tap |
| #19, #72 | Tracking stepper | `orderPage` raw dump; first button is "Open conversation" (`activity.dart:104`) | Partial | No stepper or ETA |
| #20–#24 | Table services, bill, receipt, another round | Visit page, room | Partial | No v2 receipt; a staff round belongs to the waiter |
| #25–#30 | History, profile, addresses, accessibility, help, payment failure | Activity / Account tabs | Partial | No reorder; addresses need typed lat/lng; no connected language/theme/motion settings |
| #31–#36, #49–#52 | Owner onboarding wizard, AI import, publish | Setup and AI studio forms | Partial | Hours typed as minutes after midnight; AI import needs an already-published restaurant |
| #37–#42 | Waiter shift, table map, session, add order, bill, request queue | Restaurants → tile; per-visit requests only | Partial | No staff home; no request inbox |
| #43–#48 | Live orders by channel, kitchen ticket, delivery handoff, payment detail, team, alerts | Generic staff pages | Partial | No channel filters, typed courier ID, no staff alerts |
| #53–#56 | Floor editor, live floor, service desk | `/ops` SVG map + Services tab; mobile numeric forms | Partial | No drag editor in connected mode (demo only) |
| #57–#60 | Menu catalogue, product editor, AI extraction, translated publish | Menu forms + drafts | Partial | No modifier editor, photo picker or translation UI |
| #61–#64 | Unified orders board, order detail, kitchen display, delivery map | `/ops` Orders tab (5 columns, oldest 100) | Mostly missing | See section 7 |
| #65–#68 | Payments ledger, sales reports, staff matrix, settings | Reports raw dump; `/ops` Payments tab = attempts | Mostly missing | No ledger by method, no charts, no export |
| #69–#72 | Public web storefront / checkout | Web prototype only | Deferred | Not connected |

## 3. Coverage by module and channel

Full detail is in the [coverage CSV](raysto-feature-coverage.csv). Summary by channel:

| Channel | Backend | Connected mobile | `/ops` | Verdict |
|---|---|---|---|---|
| **Counter / walk-in** | **Missing.** The order is always owned by the caller (`ordering.dart:495`); no origin field (`purchase_order.spy.yaml`) | Missing | Missing | **Not supported** |
| **Remote pickup** | Complete flow, slots, capacity; forced pay-before (`ordering.dart:415-417`) | Reachable without a table; generic UI | Orders row only | Works in source; UX poor; PayPal unverified |
| **Delivery** | Zones, minimum, fee, courier, issue, location | Reachable; addresses need typed coordinates; courier ID typed | Missing (prototype only) | Works in source; dispatch UI weak |
| **Solo dine-in** | Visit + order, pay-at-end option | Scan forces the room | Table map | Works, but chat is forced |
| **Group dine-in** | Rooms, host, proposals, frozen shares | Polished room | Room panel | Strongest area |

**Roles for non-table orders (fact).**
- `_orderAccess` falls back to `w.role(_managers)` for any order without a visit (`core.dart:406-430`).
- The kitchen role can only set preparing/ready and cannot accept (`ordering.dart:678-683`).
- No cashier role exists anywhere (`identity.dart:551`), and each user holds one role per restaurant (`membership.spy.yaml`).

So a snack bar needs an owner or manager to accept, take cash for and hand over **every** pickup or delivery order.

**Other confirmed module gaps:**
- **Settings.** `restaurant.configure` merges the request onto the *defaults*, not the saved settings (`catalogue.dart:83`), so a partial update wipes hours, zones and coupons.
- **Menu availability.** `menu.availability` defaults `available` to false (`catalogue.dart:508`), and every toggle bumps the menu version, which expires every open quote.
- **AI menu import.** It requires an already-published restaurant (`automation.dart:319,540`), and publishing an import archives all existing items (`catalogue.dart:595-621`).
- **Staff notifications.** Staff are never notified of new orders, cancellation requests, reservations or service requests. Only the customer is notified (`ordering.dart:618,653`).
- **Waitlist.** Offers never expire, and an expired offer blocks the party from rejoining (`dining.dart:889-896`).
- **Localisation.** The connected app is English-only. There are zero `tr(` calls in `lib/features/connected/` (verified by grep), and the device locale is ignored.

## 4. Shared-visit coupling

**The backend is not coupled.**
- Cart, pickup/delivery quote, submit, kitchen, delivery, history, refund and reports all work with `visitId == null` (`ordering.dart:207-216,531`; `core.dart:446`).
- The one-unresolved-checkout rule is per visit (unique `activeVisitId`) and per order. It did **not** become global (`money.dart:96-128`).
- Ordering works with AI off (`ordering.dart:444-451`).
- Dine-in can be disabled (`ordering.dart:174-177`). However, `visit.start`, `reservation.create` and `waitlist.join` don't check that setting.

**Coupling sits in the clients and the operations model:**
1. **Order page.** Its primary action opens a conversation room for any order, including delivery (`activity.dart:104-108`). The room copy assumes a table ("People at your table", `room.dart:347`; "Message your table", `room.dart:1208`).
2. **Notifications.** They route to the room first (`connected_app.dart:139-147`).
3. **Scanning.** A QR scan always creates or joins a visit and pushes the room (`shopping.dart:135-154`).
4. **Basket.** Dine-in from the basket needs a typed visit reference (`shopping.dart:538-546`).
5. **AI.** Priced AI baskets (`quote_basket`) exist only in visit rooms (`assistant.dart:516-520`). The customer `recommend` path has no allergen data (`automation.dart:373-384`).
6. **Console.** `operations.snapshot`, the three AG Studio tiles, the shared filter and the AI focus tool are all table attention (`workspace.dart:68-176`).
7. **Waiter order list.** Waiters only see orders on visits at their assigned tables (`queries.dart:472-504`).

**Journeys affected:** counter, pickup, delivery and solo dine-in are all routed toward a room they don't need, and staff have no non-table operating view.

## 5. Reachable connected UI vs mock, backend-only, hidden and deferred

| State | Capabilities |
|---|---|
| Connected and purpose-built | Table room (messages, proposals, shares, service, MCP badge); sign-in; `/ops` floor + room + tiles |
| Connected but generic form or dump | Storefront → basket → quote → order; checkout; kitchen; deliveries; floor editing; menu and drafts; AI import; setup; team; reports; billing; reservations; waitlist; support; media; reviews |
| Mock only (offline demo) | Role-specific staff shells; overview dashboard; order board with filters; restaurant-wide request board; drag floor editor with undo; category/item/modifier editors; setup checklist and storefront preview; reports with charts; delivery desk; reorder; receipts; address book; pickup-slot screen |
| Backend only | `operations.snapshot` on mobile; report kinds `collections/refunds/commission/audit` on the web; `payment.exceptions`; translations; `support.inbox` for staff on the web; `menu.manage`, `kitchen`, `deliveries`, `reservations`, `waitlist`, `team` on the web |
| Not discoverable | Staff tools sit under Restaurants → restaurant → tile in a customer-shaped shell; kitchen and courier users land on Discover |
| Should be hidden | "Test PayPal Sandbox" and the legacy v1 `ConnectedPaymentsScreen` are reachable from Account (`activity.dart:994-999`); paying a v2 order there fails with `client_upgrade_required` |
| Dead code | `LiveWorkspace` / `LiveMenuScreen` (`live_account_screen.dart:293-533`) |
| Deferred | Public web ordering; marketplace onboarding; subscriptions; commissions |

## 6. PayPal and AI by channel

### Payment stacks
There are three. The connected app uses only the **v2 MoneyModule** (`money.dart`).
- The legacy v1 `PaymentService` and the fixed-$1 `SandboxPaymentService` still exist.
- The PayPal webhook registered on the PayPal side is the legacy `/webhooks/paypal`.
- The v2 webhook routes (`platform_routes.dart:100-130`) have no documented registration.

### Channel matrix
Steps: quote → review → checkout → approval → capture → ledger → staff release → fulfilment → receipt → refund.

| Channel | In source | Verified evidence |
|---|---|---|
| Counter takeaway | Not possible as staff entry; only customer self-pickup | None |
| Remote pickup | Complete. Pay-before; work released on settlement (`money.dart:495-503`) | Cash path collected end-to-end (reported 2026-10-26). PayPal handoff only; no approval |
| Delivery | Complete. Handoff needs paid (`ordering.dart:945-948`) | None with PayPal |
| Solo dine-in | Through the visit; pay-at-end supported | Visit rules verified (integration tests, this audit) |
| Group dine-in | Frozen shares; serialized payers (one active checkout per visit) | Shares verified with mocked/cash payments this audit; $13.50 PayPal handoff reported 2026-10-27; **0 captures** |

### What holds (fact, mocked provider; tests passed this audit)
- **Amounts.** Integer minor units.
- **One merchant per checkout.** Each checkout pays a single merchant.
- **Approval is not payment.** `APPROVED` never marks an order paid. Settlement needs a `COMPLETED` capture that matches amount, currency, merchant and `custom_id` (`money.dart:646-717`).
- **Idempotency.** Every PayPal call carries a `PayPal-Request-Id`. A duplicate webhook is ignored, and an invalid one cannot change any record.
- **Refunds.** A refund cannot exceed the captured amount minus what is already refunded.
- **Cash.** Cash is stored separately from PayPal.
- **Host vs payer.** A host cannot approve someone else's payment.

### Defects (fact, confirmed in source)

**D1 (P0): a checkout can get stuck with no exit.**
- `capture()` accepts a checkout in the `created` state (`money.dart:376-389`).
- When the buyer has not approved, `reconcile` reads `PAYER_ACTION_REQUIRED`, so no capture is posted. But the checkout stays in `capturing`, because that state is never reset (`money.dart:667-670`).
- Any provider read error moves the checkout to `uncertain` (`money.dart:689-690`).
- Neither state can leave: cancel refuses both (`money.dart:404`), the 3-hour auto-release skips them (`automation.dart:707-709`), and retries stop after 5 hours.
- One stuck checkout blocks every payment at the table, closing the visit, resetting the split and cancelling the order.
- The mobile app invites the trigger by showing "I approved in PayPal · check payment" in the `created` state (`activity.dart:586-598`).

**D2 (P1): a pay-before group order can expire while the bill is being split.** It auto-cancels at 20 minutes with `refundDue` and no automatic refund (`automation.dart:912-927`; `ordering.dart:789`).

**D3 (P1): nothing captures after approval unless the app returns and the user taps.** No server-side capture runs on `CHECKOUT.ORDER.APPROVED`.

**D4 (P1): a partial refund strands an order that is being prepared.** Every later step requires `paymentStatus == 'paid'` (`ordering.dart:708-710`; `money.dart:929-934`).

**D5 (P1): refunds are matched to allocations in id order across the whole capture** (`money.dart:782-789`). On a capture covering several orders, refunding one order can mark a different order refunded.

**D6 (P2): a refund PayPal rejects stays pending forever.** It keeps consuming refundable headroom.

**D7 (P2): wrong credentials in single-sandbox mode.** Dispute, reversal and refund-import calls use platform credentials, which are empty in this mode.

**D8 (P2): one background job runs at a time, platform-wide** (`automation.dart:613-620`). AI jobs delay payment reconciliation.

### AI

**Room and manager assistant.**
- Model: `gemini-3.8-flash` (EU), with 8 tools that run authorization checks.
- It proposes; it never writes. Proposals expire after 5 minutes and are bound to a menu revision.
- Budget is tracked; 429 responses map to a retryable error. A failed run is charged its full reservation (`ai_budget.dart:107`).

**PayPal MCP.**
- The official `@paypal/mcp` 1.8.1 runs over stdio with `orders.get` and `payments.getRefunds`. It is authorized before every call, and a labelled REST fallback covers failures.
- A direct read was reported on 2026-10-27. The conversational path is **blocked** by Gemini HTTP 429.
- The client skips extra tools rather than rejecting them, contrary to `docs/paypal-mcp.md:24`.

**Outside rooms.**
- Customers get only `recommend` (unpriced, no allergen data).
- Managers get 3 effective tools in `/ops`: `read_menu`, `payment_status` and `operations_summary`, the last of which is table-only.
- The equal split is reachable only through Gemini; there is no deterministic fallback.

## 7. AG Grid and AG Studio

- **Workspace shape.** `/ops` is restaurant-scoped but **centred on the dine-in floor**:
  - 3 custom AG Studio tiles: outstanding bills, service attention, payment exceptions.
  - One `tables` data source, an SVG floor, and a room panel.
  - Orders, Payments and Services grids built on Community modules.
  - A custom AI harness backed by the server assistant. No key is held in the client.
- **Saved layouts.** They live on the server with version checks, and restore is tenant-validated (`workspace.dart:211-300`). This is strong.
- **Sponsor fit.** The integration goes beyond a plain grid, as the AG brief asks: custom widgets, theming, saved layouts and a custom harness are all present.

**Defects (confirmed this audit):**
1. **The Orders and Payments tabs show the *oldest* 100 records.** The queries sort ascending by id from cursor 0 (`queries.dart:154-169,495-507`), and the client never pages (`operations-workspace.tsx:331,336`). New orders never appear once a restaurant passes 100. The mobile order lists use the same queries.
2. **The proxy allowlist is lowercase only.** `commands/[a-z.]+` (`route.ts:6`) rejects `operations.archiveThread` (thread delete always fails), `menu.publishDraft`, `identity.stepUp` and `admin.*`.
3. **The server rejects any widget except the three Raysto tiles** (`workspace.dart:264-274`), but edit mode offers the full built-in palette. Adding a chart and saving fails with `invalid_input`.
4. **The AI focus tool rebuilds the layout from the default** (`studio-harness.ts:256-270`), discarding the user's arrangement.

**Coverage of the 11 workspace targets:**

| Status | Targets |
|---|---|
| Present (connected) | Tables |
| Partial | Orders (no lines or time), payments (attempts only), overview (tables only), multi-restaurant (switcher only) |
| Missing (backend data already exists) | Kitchen, dispatch, menu operations, reservations/waitlist, sales reports, staff, support |

The prototype web dashboard has most of them, but on local fake data.

**Data correctness.**
- Tenant scoping is sound. No cross-currency sums or double counting were found.
- Dates use the browser timezone, not the restaurant's.
- `currency()` assumes two decimals.
- The snapshot fails hard above 200 tables.
- There is no AG Grid Enterprise licence for standalone grids. AG Studio pulls Enterprise in transitively under its own evaluation key, which expires **10 December, before judging ends on 15 December**.

**Design.** `/ops` overrides the canonical tokens (`--forest:#23493c` vs `#173F35`). It has no dark mode, fixed grid heights, and no Playwright coverage of `/ops`.

## 8. Material 3, navigation, motion and accessibility

**Foundations are good.**
- Material 3 with paper/forest/lime tokens (`tokens.dart:5-31`).
- Plus Jakarta Sans and Noto Sans Arabic are bundled.
- Reduced motion follows the device OR the app setting (`motion.dart`).
- Text scaling is not capped, and the dock becomes a sheet above 1.5×.
- Touch targets are 48 px, RTL works in the room, and draft guards exist.

**Problems in connected mode:**
- **Language.** It is English-only and ignores the device locale and the saved profile locale.
- **Settings.** There are no language, theme or motion settings; those exist only in the demo.
- **Shell.** All roles share the same customer tabs, with no staff home.
- **Too many pages.** Every action goes through an extra confirm page.
- **Raw data.** Records render as raw key dumps and typed numeric IDs (visit, courier, media, table, waiter).
- **Refresh failures.** A failed poll blanks loaded data (`connected_app.dart:247-251`), and there is no offline banner.
- **Inconsistencies.** Spinners ignore reduced motion in the room (`room.dart:877,1227`), and icon families are mixed (Phosphor and Material).

**Root cause.** The narrowing in connected mode is **information architecture and UI investment**, not backend capability. The smallest correction is to reuse the demo's role shells and purpose-built widgets over the existing v2 queries and commands (see the plan).

## 9. Checks run, failures, blockers and limitations

| Check | Result |
|---|---|
| `flutter analyze` (pinned 3.47.8) | **No issues found** |
| Backend unit tests (`test/unit`, local only: mocked HTTP, stdio fixture) | **47/47 passed** |
| Backend integration tests (isolated `raysto-backend-postgres` container, `raysto_backend_test` database) | **37/37 passed.** The first run hit a pool-lock timeout in `commerce_test` `setUpAll`; a re-run of that file passed 11/11 |
| Web `tsc --noEmit` | Clean |
| Web unit tests (`tests/*.test.ts`) | 6/6 passed |
| `flutter test` | **Not run.** The Git Bash launcher exited 127; the owner then asked to skip tests and builds |
| Live GETs | `api.rays.to/health` 200; `ops.rays.to/ops` 200; `rays.to` 503 |

**Coverage caveat (fact).**
- `commerce_test` and `concurrency_test` exercise the **legacy v1 `placeOrder` engine**, not the v2 engine the app uses.
- There are **no v2 integration tests** for quote, submit, order transitions, kitchen, delivery, reservations or waitlist.
- The v2 tests that exist cover payment allocation, cash, visits, rooms, proposals, budgets and tenancy.

**Not done in this audit, by design.**
- No journeys were executed on a device or the deployed backend.
- No PayPal, Gemini or Firebase calls were made.
- No tests or builds were run after the owner's request.

Journeys A–H in the prompt remain **unexecuted**. Their source-level status is in section 3 and the CSV:
- A (snack bar) and C (delivery) are blocked by the counter and role gaps.
- E (group) is blocked by Gemini capacity and buyer approval.

**Blocked externally:**
- Gemini 429.
- Sandbox buyer approval (needs the owner).
- Hosted MCP (403/1010).
- Marketplace and billing credentials.
- MCP dependency advisories (12 high, 1 moderate, reported 2026-10-27).

## 10. Correction plan and documentation updates

See [raysto-correction-plan.md](raysto-correction-plan.md) for the work packages.

**Documentation updates proposed:**
- **`product-direction.md` and `project-status.md`.** Lead with the full-suite definition. Present the visit room as the distinctive feature, not the product.
- **`RAYSTO_COMPLETE_PROJECT_BRIEF.txt`.** Correct section A/E positioning, and add counter/pickup/delivery as first-class journeys.
- **`docs/paypal-mcp.md:24`.** Change "the client rejects write tools" to "the client exposes only allowlisted tools; startup arguments restrict the server".
- **`web/README.md:81`.** Document `/ops` and the connected proxy.
- **`docs/backend-v2/security-and-states.md:11`.** It claims waiter "assisted orders". Mark this as not implemented until WP-C1 lands.
- **Test reporting.** Report legacy-engine tests separately from v2 coverage.

## 11. Hackathon assessment under the corrected scope

The criteria are design, impact, innovation and presentation. A third-party summary says they are weighted equally; Devpost could not be fetched (403).

### Today's build: 30/50

This is lower than my earlier 34/50. That earlier score was based on documentation; this audit inspected the connected screens.

| Criterion | Score | Reasoning |
|---|---|---|
| Technical implementation | 6.5 | Backend depth is real: 80 commands, a verified ledger and real PayPal MCP. Against that: zero captures, the D1 stuck-checkout defect, Gemini 429, and v2 order flows with no tests |
| Design | 5 | The demo and the room are polished. The connected app judges would install is mostly forms and raw dumps, in English only |
| Potential impact | 6.5 | A restaurant + snack-bar platform is a broader story, but none of it is proven, and counter sales are missing |
| Innovation | 7 | Group AI proposals with exact per-payer PayPal shares and an MCP payment check remain distinctive |
| Presentation | 5 | No end-to-end paid order to show; the film is room-centric |

### If the P0+P1 plan works: 41–43/50 (estimate)

| Criterion | Score | Reasoning |
|---|---|---|
| Technical | 8.5 | Real Sandbox captures in pickup and group flows, counter sale, kitchen release on verified capture, MCP answer in chat |
| Design | 8 | Role shells and purpose-built screens reused from the demo, localised, consistent |
| Impact | 8 | A snack bar and a full-service restaurant both run on one system; a disclosed small pilot |
| Innovation | 8.5 | AI ordering for solo and group, deterministic splits, AG Studio operations assistant across channels |
| Presentation | 8 | 3-minute film: counter sale with PayPal, kitchen, owner workspace, then the group split as the wow moment |

**Risk.** There are 15 days left. Shipping the whole suite is not realistic. The plan sequences the smallest set that makes the broader product *demonstrable and true*.


## 12. Re-score after the correction work (29 October 2026)

Scope: everything on branch `hackathon/full-suite` (uncommitted, not deployed). Evidence levels: **tested locally** = backend integration tests on the isolated database and/or widget tests; **built, not verified live** = code exists, no Sandbox or device run yet; **blocked** = waits on an external step.

| Criterion | 27 Oct | 29 Oct | If the remaining plan ships | Why it moved |
|---|---|---|---|---|
| Technical implementation | 6.5 | 7.5 | 8.5 | D1/D2/D4/D5 fixed with tests; counter orders, capabilities, capture-on-approval, manager release, deterministic split; v2 engine now has 37 integration tests. Still no live capture or deployment. |
| Design | 5 | 6.5 | 8 | Purpose-built staff shell, orders board, kitchen board, counter with QR, Ask Raysto; FR/AR for new screens; tested at 320 px and 2×. Customer tracking/receipt pages unchanged; not device-verified. |
| Potential impact | 6.5 | 7.5 | 8 | A snack bar can now run on Raysto without tables: counter sale, ticket number, pickup code, cash or PayPal QR. |
| Innovation | 7 | 7.5 | 8.5 | AI proposes, humans approve, PayPal collects; manager AI backed by ledger tools and PayPal MCP evidence; money never depends on the model. |
| Presentation | 5 | 5 | 8 | Nothing filmed; brief not rewritten; no Devpost text. |
| **Total** | **30** | **34** | **41–43** | |

Defects: D1 fixed · D2 fixed · D3 (no capture ever completed) built, blocked on a buyer session · D4 fixed · D5 fixed · D6/D7 deferred · D8 (lists oldest-first) fixed. Proxy allowlist fixed. Settings merge fixed. Availability toggle no longer expires other quotes.

Open before 12 November: production migration and deploy; Gemini API enablement on the key's project; PayPal webhook registration; two Sandbox buyer sessions (pickup, counter QR, two-buyer split, partial refund, MCP read); `/ops` overview/orders/payments; Android build on two phones; film; Devpost text. Pre-existing Flutter failures on `main` (3 demo-mode viewport tests) are unrelated to this work.
