# Raysto correction plan

Companion to [the full product audit](raysto-full-product-audit.md). Priorities follow the audit brief:
- **P0:** evidenced financial-correctness, authorization or data-loss defects.
- **P1:** broken or missing core restaurant and snack-bar journeys, inaccessible existing capabilities, and required provider acceptance.
- **P2:** depth and polish.
- **Deferred:** commercial milestones.

Each package lists:
- **Problem / evidence**
- **Who / channel:** affected role and channel.
- **Reuse:** what already exists.
- **Change:** the concrete change.
- **Depends on**
- **Acceptance:** the acceptance scenario.
- **Risk**
- **Release:** **R** = needed for the current functional (hackathon) release; **L** = later milestone.

## P0: correctness defects

### WP-0.1 Release stuck PayPal checkouts (D1) · R

**Problem / evidence**
- `capture()` accepts `created` (`money.dart:376-389`). An unapproved checkout then stays in `capturing`, because the state is never reset (`money.dart:667-670`).
- Any read error sets `uncertain` (`money.dart:689-690`).
- Neither state can be cancelled or auto-released (`money.dart:404`; `automation.dart:707-709`), and retries stop after 5 hours.
- One stuck checkout blocks the visit, the split, closing the table and cancelling the order.

**Who / channel:** every payer and staff member; all channels.

**Reuse:** the read-then-capture logic in `reconcile`; the pattern in `SandboxPaymentService` (GET first, require `APPROVED`); `_release`.

**Change**
1. When the read shows the order is not `APPROVED` and no capture exists, return `capturing` to `created`.
2. Set `uncertain` only after a capture POST was attempted.
3. Add a manager command, `payment.release`, gated by step-up and audit. It re-reads PayPal and releases the allocation only if the provider shows no completed capture.
4. Mobile: show "Check payment" only in `approved` state, or make it a plain status refresh. Show Cancel for `capturing`/`uncertain` once the backend allows it.

**Depends on:** nothing.

**Acceptance**
- Tapping "check" on an unapproved checkout leaves it cancellable.
- A simulated read failure followed by a successful read returns to `created`/`approved`.
- Manager release of a never-captured checkout frees the visit.
- Tests: v2 integration tests with a mocked provider for each path.

**Risk:** releasing after an unseen capture. The release must re-read the provider inside the lock and refuse when any capture exists.

### WP-0.2 Refunds attributed to the right order (D5) · R

**Problem / evidence:** refunds consume allocations in id order across the whole capture (`money.dart:782-789`). On a visit capture covering several orders, refunding order B can mark order A refunded.

**Who / channel:** managers; group and solo dine-in with multiple rounds.

**Reuse:** the `payment.refund` typed body; allocation rows.

**Change:** add an optional `orderId` (or charge ids) to `payment.refund`, and consume only allocations for those charges. Keep the capture-level cap.

**Depends on:** nothing.

**Acceptance:** with two orders on one capture, refunding B changes only B's `paymentStatus`. The test uses a mocked provider.

**Risk:** existing refund records; this needs no migration.

### WP-0.3 Newest-first order and payment lists · R

**Problem / evidence**
- `orders` and `checkouts` page ascending from id 0 (`queries.dart:154-169,495-507`).
- `/ops` requests 100 and never pages (`operations-workspace.tsx:331,336`).
- Once a restaurant passes 100 orders, new orders never appear in the console. Customer history also starts with the oldest.

**Who / channel:** all staff and customers.

**Reuse:** the keyset pagination helper.

**Change**
1. Add `sort: "desc"` with a `before` cursor to `orders` and `checkouts`, and expose `createdAt`.
2. Use it in `/ops` and in the mobile lists.

**Depends on:** nothing.

**Acceptance:** a seeded restaurant with 150 orders shows order 150 first in both clients.

**Risk:** low.

### WP-0.4 Web proxy allowlist · R

**Problem / evidence:** `commands/[a-z.]+` (`route.ts:6`) blocks camel-case commands, so `operations.archiveThread`, `menu.publishDraft`, `identity.stepUp` and `admin.*` all fail.

**Who / channel:** managers on `/ops`.

**Reuse:** the existing proxy.

**Change:** replace the regex with an explicit allowlist of command and query names. The narrower option is safer than `[A-Za-z.]+`.

**Depends on:** nothing.

**Acceptance:** deleting a thread and the step-up prompt both succeed through the proxy, and unknown names still return 404.

**Risk:** allowlist drift. Add a test that compares it with the backend registry.

## P1: core journeys and acceptance

### WP-1.1 Counter and staff-on-behalf orders · R

**Problem / evidence**
- Every order belongs to the caller (`ordering.dart:495`).
- There is no origin, order number or customer name (`purchase_order.spy.yaml`).
- The references show staff-entered orders (#40) and bill collection (#41).

**Who / channel:** cashier capability; counter takeaway.

**Reuse:** `quote.create` / `order.submit` pricing and snapshots; the `pickup` fulfilment; the kitchen and charges pipeline.

**Change**
1. Add `origin` (`online | counter | table_staff`) and an optional `customerLabel` (name or phone, up to 80 characters) to `OrderContext`. Add a per-restaurant daily `orderNumber` and a 4-digit `pickupCode`.
2. Accept `onBehalf: true` on quote and submit for counter-capable staff. The order gets no `customerId` (or a restaurant walk-in sentinel). Coupons skip the per-user check.
3. Show the number and code on the ticket and the customer screens.

**Depends on:** WP-1.2 (who may do it).

**Acceptance:** a cashier creates a 2-item takeaway. The kitchen sees "#17 · counter" with no table, room or host, and the order is absent from the cashier's personal history.

**Risk:** schema migration on a shared host. It runs on the Raysto database only and is additive.

### WP-1.2 Capabilities instead of a new global role · R

**Problem / evidence**
- Non-visit orders fall back to managers (`core.dart:406-430`). The kitchen cannot accept (`ordering.dart:678-683`).
- There is one role per user (`membership.spy.yaml`), and no cashier exists.

**Who / channel:** owner, waiter, kitchen; counter, pickup and delivery.

**Reuse:** `Membership`; `w.role`; the team UI.

**Change**
1. Add `capabilities` (`counter`, `dispatch`, `acceptOrders`) to `Membership`.
2. Make `_orderAccess` allow `counter` for non-visit orders, and `order.transition` allow `acceptOrders`. Cash on standalone orders goes to `counter`.
3. Add an optional per-restaurant `autoAcceptPaid` setting.

**Depends on:** nothing.

**Acceptance:** a waiter with `counter` accepts, records cash and collects a pickup order. A waiter without it is refused.

**Risk:** permission widening. Cover each capability with a negative test.

### WP-1.3 Counter PayPal handoff · R

**Problem / evidence:** there is no customer-controlled payment for a walk-in. The approval URL exists but is only opened on the payer's own device.

**Who / channel:** cashier and customer; counter.

**Reuse:** `payment.allocate`/`checkout` for orders; the approval-host allowlist; reconcile.

**Change**
1. The counter screen shows the approval URL as a QR. The customer approves on their own phone.
2. The counter screen polls the checkout. Capture runs server-side once `APPROVED` (see WP-1.5) or from the counter's "check" action, never on the cashier's say-so.

**Depends on:** WP-0.1, WP-1.1, WP-1.5.

**Acceptance:** a real Sandbox buyer scans and approves. The order moves to submitted/paid and the kitchen board shows it.

**Risk:** this is not card-present payment, and the product must not describe it as one.

### WP-1.4 Connected mobile: role shells and purpose-built screens · R

**Problem / evidence**
- Connected mode is a form console (`forms.dart:37,415`), and every role gets the customer tabs.
- The demo already has role shells (`mobile_app.dart:328-360`), an order board (`operations/orders.dart:137-292`), a request board, a delivery desk, a floor editor and menu editors.

**Who / channel:** all staff; all channels.

**Reuse:** the demo widgets in `lib/features/operations/*` and `lib/features/customer/*`, re-bound from `DemoStore` to the `PlatformApi` queries and commands. Keep `RecordEditor` only for rare admin forms.

**Change, in this order:**
1. A staff shell chosen by membership: kitchen opens the kitchen board, courier opens tasks, owner/manager/counter open the orders board.
2. An orders board with channel, status and payment filters, using `orders` desc (WP-0.3).
3. A kitchen board (`kitchen` + `order.transition` + `kitchen.progress`).
4. The counter screen (WP-1.1/1.3).
5. A restaurant-wide request inbox (`operations.snapshot` / `services`).
6. Dispatch (`deliveries` + `delivery.assign` with a picker built from `team`).
7. Single-tap actions without an interstitial confirm page. Keep confirmation only for money and destructive actions.

**Depends on:** WP-0.3, WP-1.1, WP-1.2.

**Acceptance:** a kitchen account lands on the board, and new paid orders appear within 3 s (SSE or poll). A cashier rings up a sale in 6 taps or fewer.

**Risk:** scope. Do items 1–4 for the hackathon release; 5–6 if time allows.

### WP-1.5 PayPal acceptance and capture after approval (D3) · R

**Problem / evidence**
- There are zero captures in any channel.
- Nothing captures unless the app returns and the user taps.
- The v2 webhook is not registered.

**Who / channel:** all payers.

**Reuse:** v2 webhook routes (`platform_routes.dart:100-130`); reconcile.

**Change**
1. Register the v2 single-sandbox webhook (`CHECKOUT.ORDER.APPROVED`, `PAYMENT.CAPTURE.*`).
2. On `APPROVED`, enqueue a capture through the same idempotent path.
3. Run and record:
   - (a) a pickup PayPal capture,
   - (b) a counter QR capture,
   - (c) a two-buyer group split,
   - (d) a partial refund,
   - (e) a chat MCP status read.

**Depends on:** WP-0.1; the owner's Sandbox buyer participation.

**Acceptance:** the ledger shows captures matching the PayPal capture ids, the webhook was delivered and deduplicated, and the refund is reflected in both.

**Risk:** this is an external dependency. Book the buyer session early.

### WP-1.6 Payment-state fixes for real flows (D2, D4) · R

**Problem / evidence**
- A partial refund strands an order being prepared (`ordering.dart:708-710`).
- A pay-before group order expires at 20 minutes while it is being split (`automation.dart:912-927`).

**Who / channel:** managers and diners.

**Reuse:** `paymentStatus` and the expiry job.

**Change**
1. Allow preparation and handoff when `paymentStatus` is `partiallyRefunded`/`refunded` and the refund was staff-initiated.
2. Pause expiry while any allocation is reserved or settled. Default new dine-in restaurants to `paymentTiming: end`.

**Depends on:** nothing.

**Acceptance:** a partially refunded order can still complete. A slow second payer is not cancelled.

**Risk:** low.

### WP-1.7 AI that doesn't depend on a table · R

**Problem / evidence**
- Gemini returns HTTP 429.
- The equal split exists only through Gemini.
- There is no priced AI basket outside visits, and `recommend` has no allergen data.

**Who / channel:** customers and managers.

**Reuse:** `EqualShares.prepare` (`shares.dart`); `_price`; the `quote_basket` tool; the assistant harness.

**Change**
1. Resolve the Gemini quota or billing. If the owner approves, add a configured second model for capacity errors.
2. Add a deterministic `room.split.equal` command (no AI) with the same frozen-share rules.
3. Allow `quote_basket` in a pickup/delivery cart context, producing a cart proposal the customer approves.
4. Pass allergen and dietary data to `recommend`.
5. Add read-only manager tools: `sales_summary`, `kitchen_load`, `pickup_ready`, `unresolved_payments`.

**Depends on:** WP-0.3 for the list-based tools.

**Acceptance**
- Equal split works with AI disabled.
- A pickup customer gets a priced basket with allergen caveats.
- "Which PayPal attempts are unresolved?" answers from real rows, with an MCP read on one of them.

**Risk:** AI spend. Keep the $35/$15 caps.

### WP-1.8 `/ops` across the business · R (items 1–4), L (rest)

**Problem / evidence**
- The workspace is centred on the dine-in floor.
- The server refuses built-in widgets (`workspace.dart:264-274`).
- The AG Studio evaluation key expires 10 December, before judging ends.

**Who / channel:** owner/manager; all channels.

**Reuse:**
- Queries: `report` (summary/orders/collections/refunds), `kitchen`, `deliveries`, `order`, `payment.exceptions`.
- AG Studio async data sources and the `getAiTools()` widget tools.

**Change**
1. An overview page with channel-wide KPIs from `report=summary`, in restaurant-timezone day bounds, each with drill-down.
2. An orders grid: newest first, `createdAt`, origin/channel, order number, line drill-down from `order`.
3. A payments workspace: attempts, captures, refunds and cash as separate tabs. Never one blended total.
4. Extend the widget allowlist to selected built-in charts and grids bound to allowlisted sources, and stop the focus tool resetting user layouts.
5. Later (L): kitchen and dispatch boards, menu operations, reservations, staff, support.

**Also:** get the AG Studio licence extended past 15 December.

**Depends on:** WP-0.3, WP-0.4.

**Acceptance:** an owner filters today's pickup orders, opens one, sees its PayPal capture and refund, saves the layout, and reloads.

**Risk:** read rate limits (240/min). Load data per tab.

### WP-1.9 Staff notifications · R

**Problem / evidence:** only customers are notified (`ordering.dart:618,653`).

**Change:**
- Notify kitchen/counter devices of new paid orders.
- Notify managers of cancellation requests and waiters of service requests on their tables.
- Reuse the existing outbox and FCM path.

**Acceptance:** a test device receives the push. Device acceptance is separate.

### WP-1.10 Connected localisation and settings · R

**Problem / evidence:** zero `tr(` calls in `lib/features/connected/`, and the device locale is ignored.

**Change:**
- Route connected strings through the existing `app_localizations` (en/fr/ar).
- Use the device locale, then the profile locale.
- Add language, theme and motion settings to Account.

**Acceptance:** the counter, orders, kitchen and checkout screens work in French and in Arabic RTL at 320 px with 2× text.

### WP-1.11 v2 order-engine integration tests · R

**Problem / evidence:** integration tests cover the legacy `placeOrder` engine. The v2 quote/submit/transition/kitchen/delivery paths have no tests.

**Change:** add focused tests on the isolated Raysto test database for:
- counter sale;
- pickup pay-before release;
- delivery handoff;
- kitchen accept rights;
- refund attribution;
- stuck-checkout release.

**Acceptance:** the tests fail before the fixes above and pass after.

### WP-1.12 Settings and menu data-safety · R

**Problem / evidence**
- `restaurant.configure` merges onto defaults, not saved settings (`catalogue.dart:83`).
- `menu.availability` hides an item when `available` is omitted (`catalogue.dart:508`).
- Every availability toggle expires every open quote.
- AI import requires an already-published restaurant and archives the existing menu.

**Change**
1. Merge onto saved settings.
2. Make `available` required.
3. Version availability separately from the menu definition.
4. Allow AI import before publishing, and match imported items to existing ids.

**Acceptance:** a partial configure keeps hours and zones. One item toggle does not invalidate other quotes.

## P2: depth and polish (L unless noted)

- **Customer flow polish (R if time allows):**
  - one-tap add;
  - basket with prices and steppers;
  - tracking stepper with ETA, with the conversation secondary;
  - scan opens the table menu with the room as a tab;
  - v2 receipt with the PayPal capture id;
  - reorder at current prices;
  - address picker with server geocoding;
  - favourites by name with unfavourite.
- **Reuse the demo's editors:** floor drag editor, category/item/modifier editors, menu translation UI, setup checklist.
- **Reports:** charts, channel mix, top items, cash vs PayPal, CSV export.
- **Reservations and waitlist:** UI, staff booking for phone callers, waitlist offer expiry, dine-in-disabled checks.
- **Platform:** separate job lanes for payments and AI (`automation.dart:613-620`); D6 pending-refund resolution; D7 single-merchant credentials for disputes and imports.
- **`/ops` design:** canonical tokens, dark mode, view mode by default on phones, Playwright coverage at 320 px.
- **Cleanup:** remove `LiveWorkspace` dead code; hide the Sandbox test harness and the v1 payments screen in release builds; a plan for retiring the legacy v1 engine.
- **MCP:** have the client reject unexpected tools; review upstream advisories.

## Deferred (commercial milestones)

- Connected public web ordering at rays.to.
- Marketplace merchant onboarding, commissions and subscriptions/entitlements.
- iOS/APNs validation; store-signed releases.
- Payroll, procurement, recipe costing, loyalty, cash-drawer and fiscal printer hardware. These are proposals only and not part of agreed scope.

## Dependency-aware sequence (15 days to 12 November)

| Days | Work |
|---|---|
| 1–3 | WP-0.1, 0.2, 0.3, 0.4 (small, independent). WP-1.12 settings merge. Start the Gemini quota fix (WP-1.7 step 1) |
| 3–6 | WP-1.2 capabilities, then WP-1.1 counter orders, with WP-1.11 tests alongside. WP-1.6 payment-state fixes. WP-1.7 deterministic split |
| 6–9 | WP-1.4 items 1–4 (staff shell, orders board, kitchen board, counter screen). WP-1.5 webhook + capture-on-approval. WP-1.3 counter QR |
| 9–10 | **Acceptance session with real Sandbox buyers:** pickup, counter, two-buyer split, partial refund, chat MCP read |
| 9–11 | WP-1.8 items 1–4 (overview, orders, payments, widgets). AG licence extension. WP-1.9 staff push. WP-1.10 localisation for the demo screens |
| 11 | Freeze. Record the film |

### Demo showcase (under 3 minutes)

1. **Snack bar (no tables):**
   - The cashier rings up a takeaway.
   - The customer scans the QR and approves in PayPal Sandbox.
   - The kitchen board lights up, then the order goes ready and is collected using the pickup code.
2. **Customer pickup from the app:**
   - The AI suggests a priced basket with allergen caveats.
   - The customer pays with PayPal.
3. **Group dine-in (the signature moment):**
   - The host approves an AI proposal.
   - Two diners each approve their exact PayPal share.
   - The assistant confirms one payment through PayPal MCP.
4. **Owner on `/ops`:**
   - An overview across channels.
   - Drill into an order's PayPal capture and refund.
   - Ask "which payments are unresolved?".

Show only what passed acceptance on camera, and label the Sandbox.
