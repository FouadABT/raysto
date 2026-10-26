# Raysto local mobile demo

The Flutter project targets Android and iOS only. All accounts, orders, table visits, payments and deliveries described here live in one installation. There is no backend, cross-device synchronization, live AI, real PayPal, email delivery, GPS navigation or published website.

## Run and verify

The implementation uses Flutter 3.41.9 / Dart 3.11.5. From the project directory:

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
flutter analyze
flutter test --concurrency=1
flutter build apk --debug
```

On macOS with Xcode, use `flutter run -d <ios-device-id>`. Windows cannot establish iOS build/gesture/VoiceOver verification. For an optimized local Android package:

```sh
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

Release signing remains a separate deployment concern. See `validation.md` for actual test/build/runtime outcomes; this guide does not assert performance measurements.

## Enter a role

At welcome choose **Explore demo accounts**. From an active account use **Profile / app-bar Settings → Demo controls → Switch account**. Operational More also links App settings. A working mock login accepts the displayed password `RaystoDemo123!`; verification uses the displayed code `123456`.

| Account | Role and useful entry |
| --- | --- |
| `new.customer@raysto.test` | New customer; incomplete guided setup and empty history |
| `customer@raysto.test` | Returning customer; saved addresses, favorites and history |
| `diner@raysto.test` | Participant in the active Olive Kitchen Table 06 visit |
| `owner@raysto.test` | Full Olive Kitchen setup, menu, operations and fictional plan preview |
| `manager@raysto.test` | Olive operations/menu/team/reports; restricted ownership and billing |
| `waiter@raysto.test` | Assigned tables, assisted ordering, requests, serving and cash collection |
| `kitchen@raysto.test` | Accepted/preparing/ready tickets and availability |
| `courier@raysto.test` | Assigned deliveries, pickup/progression and issues |
| `harbor.owner@raysto.test` | Harbor Cafe only; useful for isolation checks |
| Continue as guest | Browse and order under the restaurant's guest policy |

Switching accounts preserves shared operational state. Private carts, addresses, dining preferences, conversations and reviews follow their account. Language, appearance, accessibility, notification and simulated permission settings apply to this installation. A static table QR identifies a physical table; a current visit invitation is separately required to see another party's shared bill.

Registration is a local demonstration: **Sign in → Create account** validates the form, then requires the shown verification code before creating the new account. Use a fictional `.test` email. The entered registration password is a validation demonstration, not a stored credential; subsequent mock sign-in still uses `RaystoDemo123!`. Onboarding can be resumed after restart. Replay it from **Demo controls → Replay onboarding**; waiter, kitchen and courier practice uses an isolated sample world, while owner/manager setup links to the actual local setup checklist.

## Best cross-role walkthrough: scenario B

1. Open **Demo controls → Scenario → B · Dine-in with PayPal** and confirm replacement. This restores a fresh Table 06 party and selects the active diner.
2. In Discover, open **Scan a table → Use demo invitation**, review the restaurant/table/party and choose **Confirm and join visit**. The valid seed invitation is `RAYSTO-JOIN-06`. The separate physical-table payload is `raysto://table/olive/olive-table-06`; it cannot grant access to an existing party's bill by itself.
3. Open Assistant, keep Olive Kitchen and the vegetarian-meal preference, then ask **Two meals and a drink under €25**. Review and approve the Garden bowl €9 + Grilled chicken wrap €10 + House lemonade €3 proposal. Base dine-in is €22, without fee or tip.
4. Review the cart and confirm the explicitly labeled **demo** PayPal payment. Success releases one order; food preparation remains submitted.
5. Switch to manager. Open Orders, select the new order and **Accept order**.
6. Switch to kitchen. Open Queue, start preparation, check prepared items and **Mark ready**.
7. Switch to waiter. Open the ready order for Table 06 and **Confirm served**.
8. Switch back to diner. Inspect the same order/visit, request Water, and inspect its sent state. Switch to waiter and acknowledge/complete the request. Return to diner to see the completed state.
9. Inspect the shared bill and receipt. Switch to owner/manager/waiter, close the eligible visit, then open Table reset and **Mark table ready**. The next party receives a fresh visit; the previous receipt remains historical.

## Scenario presets A–L

Each preset intentionally replaces the shared world. Use account switching, not scenario switching, to continue an existing cross-role journey.

| Preset | Walkthrough and observable result |
| --- | --- |
| A — First order | New customer → language/appearance → quick or guided onboarding → editable preferences → Discover → restaurant/item/modifiers → cart → demo checkout → confirmation and Orders. Restart and confirm the saved account/history remains. |
| B — Dine-in | Follow the detailed walkthrough above. The bill, request and food states are shared across authorized roles. |
| C — Pay at end | The diner starts with dine-in/pay-at-end enabled. Build and confirm an unpaid round. Manager accepts; kitchen readies; waiter serves. Add another round from the same visit. Inspect the combined balance, then use the authorized staff cash-collection confirmation. Close only once all actionable orders and money are resolved. |
| D — Delivery | Returning customer has an eligible home address and the €22 reference basket. Delivery adds €2, total €24. Pay, accept and prepare across roles. Manager Delivery desk assigns the new task to a courier. Courier confirms pickup only after ready, starts delivery and confirms delivered. Customer tracking and report records update. |
| E — Pickup | Review the seeded reference basket, choose a configured pickup slot, pay, accept/prepare/ready across roles, then confirm pickup. Open history and receipt. |
| F — Payment recovery | The next outcome starts pending. Confirm checkout, leave safely, resume from Orders and resolve the exact retained attempt. For separate runs choose failed/cancelled/success in Demo controls before checkout. Retry keeps the basket; repeated callbacks/taps must not create duplicate money or food records. Restart while pending to inspect persistence. |
| G — Owner setup | Owner → More → Setup checklist → Create a restaurant draft. Save identity, services/hours/slots. Import the bundled menu fixture; review the unclear price and unknown dietary information. Remove or rename duplicates, approve local publish, add tables in Floor plan, save, open a real table QR and inspect Storefront preview. Publication affects this installation only. |
| H — Availability | The bowl starts unavailable. Inspect customer guidance and ask Assistant for a replacement. To exercise a stale cart, first make the bowl available as kitchen, add it as customer, then mark it unavailable again as kitchen. Existing confirmed order lines remain unchanged; checkout requests a cart correction. |
| I — Floor and service | Owner opens Tables → Edit floor plan. Select and move a table, use inspector/list controls or drag, then undo/redo/save. Waiter sees the committed positions. Try deleting occupied Table 06: it is rejected. Manager moves the active visit explicitly to an eligible table; old table needs reset. Resolve requests/balance/orders before closure. |
| J — Permissions | Switch owner/manager/waiter/kitchen/courier/customer/Harbor owner. Compare visible work and permitted actions. Kitchen cannot open payments; Harbor owner cannot select Olive. Customer restaurant switching preserves distinct private drafts. |
| K — Reservation/waitlist | Customer books a party/date/slot, modifies or cancels it. Manager Reservations marks arrival and seats into an available table, creating a fresh visit. Join a customer waitlist, notify/seat from manager, or leave from customer. No previous party's bill is reused. |
| L — Accessibility/recovery | Starts Arabic RTL, dark, 2× app text preview, reduced motion and simulated offline. Browse, open a keyboard form and inspect recovery. Restore online, test an empty filter, reset personal data or the entire world, and confirm no old pending operation mutates the new seed. Device text scaling remains uncapped and combines with the app preference. |

## Money, timing and recovery controls

- Prices are stored as EUR integer minor units. Language changes formatting, never currency conversion. Delivery fee, selected modifier prices, discounts and tips visibly affect totals.
- `FRESH10` applies the fixture's 10% item discount; `EXPIRED` demonstrates an expired coupon; another value demonstrates an unknown coupon.
- **Next payment outcome** chooses success, pending, failure or cancellation. **Service delay** chooses instant, normal or slow deterministic local response timing.
- **Advance 15 minutes** changes the shared demo clock used by queue/visit elapsed labels and invitation validity. It does not claim real background GPS or a live restaurant clock.
- A pending bill attempt reserves only its frozen order allocations. Add another round during pending payment: settling the earlier attempt leaves the new round outstanding.
- Cancelling/rejecting paid food removes the billable obligation but does not erase capture history. A separate demo refund updates the money ledger; it does not reopen cancelled debt or rewrite preparation history.
- A closed visit's table is **needs reset**, never automatically available. Reset is a distinct staff action.

## Persistence and reset

The local repository serializes account preferences, onboarding, carts, restaurant/menu/layout edits, visits, orders, attempts, payments/refunds, requests, deliveries, reservations, notifications and support state. Import review drafts are saved per restaurant. Unsaved form/layout changes remain drafts and ask before back-navigation loss.

**Demo controls → Reset personal demo data** clears the selected account's private carts, addresses, favorites, dining preferences, onboarding progress, support messages and reviews. It also returns app settings on this device to defaults. Shared restaurant orders, visits and payments are preserved. **Security and sessions → Reset this demo account** performs the same local reset; it does not delete a real account. **Reset whole demo** restores deterministic fixtures for every account. **Scenario replacement** also resets the world. World reset and scenario replacement invalidate previous asynchronous domain operations so late results cannot change the replacement world.

The component and motion gallery is under Demo controls and remains separate from restaurant data. It can be used to inspect native controls, focus, pressed/selected states, sheets and reduced motion without placing an order.

## Demonstration boundaries

The assistant recognizes a bounded set of menu, budget, comparison and replacement requests; unsupported input has a recovery message. It is not a general conversational model. Menu import reviews a bundled, authored fixture and does not process arbitrary documents. Generated QR codes and manually entered table/invitation codes use the local parser; the camera view is simulated. Maps are schematic and do not route or track a device.

English, French and Arabic interface strings, semantic dark mode and Arabic RTL are implemented. Restaurant-authored fixture names and developer-gallery explanatory examples remain in English. Mock sign-in, fixed verification code, payment outcomes, support replies and permission choices are local simulations. Real privacy/terms policies and release signing remain deployment work; see the validation record for the separately verified platforms and runtime checks.
