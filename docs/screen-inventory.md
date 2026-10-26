# Mobile screen and state inventory

25 October source update: camera QR, a customer dining-room map, enhanced staff Plan view, the redesigned guest menu and Menu studio are now implemented in source. The historical rows below describe the earlier checkpoint; [mobile-experience-enhancements.md](mobile-experience-enhancements.md) records current entry points, boundaries and intentionally deferred test/build validation.

Updated 24 October 2026. This maps the supplied prompt to implemented mobile entry points. “Implemented” describes local frontend behavior, not production service integration or a claim of device verification. Test/build/device evidence belongs in `validation.md`.

The app enters through `RaystoApp` in `lib/app/mobile_app.dart`. `MobileShell` retains role destinations; account or world changes recreate the navigation scope. Customer details use native `MaterialPageRoute`; operations expose `OperationsPage(store, section)` and `openOperation(context, store, section, id: ...)`. All use the shared `DemoStore`.

## Entry and onboarding

| ID | Entry / implementation | Essential local states |
| --- | --- | --- |
| S01 | `_RaystoAppState._restore` | Branded restoration, retry on startup failure, saved session restoration; no forced splash delay |
| S02 | `EntryScreen` | Customer/restaurant entry, guest action, restrained product story |
| S03 | `AccountChooserScreen`; welcome or Settings → Demo controls | Role descriptions, seeded accounts, active-account selection |
| S04 | `DemoAuthScreen` | Validation, visible/hidden password, busy/error, recovery |
| S05 | `DemoAuthScreen` registration mode | Required fields, dirty-form guard, verification before local account creation, then onboarding; use fictional `.test` addresses for the demo |
| S06 | `VerificationScreen` | Shown demo code, wrong/expired code, resend countdown and retry |
| S07 | `RecoveryScreen` | Local recovery confirmation; explicitly no sent email |
| S08 | `LanguageAppearanceScreen` / `LanguageAppearanceControls` | English/French/Arabic, RTL, system/light/dark, immediate preview |
| S09 | `PermissionControls` | Simulated location/camera/notification choices, manual alternatives; no OS permission claim |
| S10 | `OnboardingScreen`; Settings → Demo controls → Replay onboarding | Persisted step, back/skip, conventional or deterministic guided preferences, editable review; isolated waiter-request/kitchen-ticket/courier-handoff practice; owner/manager can open O02 |
| S11 | Settings → Demo controls → Restaurant | Only authorized workspaces; owner-created drafts add a permitted workspace |
| S12 | `AccessStateScreen`, root restoration, role route guards | Access denied, demo-session-expired preview, offline banner, saved-data recovery and retry |

## Customer

| ID | Entry / implementation | Essential local states |
| --- | --- | --- |
| C01 | Discover → `DiscoveryScreen` | Service channels, restaurant sections, search/favorites, scan action, active-visit entry |
| C02 | Discovery location button → `LocationScreen` | Manual saved address/city entry, local map preview, eligibility and manual alternative |
| C03 | Discovery search | Restaurant and dish results, in-view recent queries, clear/filter/sort, empty recovery; local filtering is immediate |
| C04 | Restaurant card → `RestaurantScreen` | Bundled cover, description, hours, channels, availability and restaurant information |
| C05 | `RestaurantScreen` menu | Search/categories/dietary filters, unavailable dishes, cart access |
| C06 | Menu row → `ItemScreen` | Ingredients/unknown dietary copy, required modifier validation, note, quantity, add/update |
| C07 | Discovery heart / Profile → `FavoritesScreen`, `AccountFavoritesScreen` | Personal favorites, empty state, current availability |
| C08 | Assistant → `AssistantScreen` | Restaurant context, budget/preferences, bounded local progress, menu comparison/replacement, unsupported-input and allergy fallback |
| C09 | Assistant → `ProposalScreen` | Review/remove/quantity, item and delivery amounts, explicit approve; modifiers editable in cart before checkout |
| C10 | Discover → Scan → `ScanScreen` | Generated real QR, same local parser for demo/manual code, invitation, invalid/expired code recovery; no live camera or automatic invitation join |
| C11 | Parsed table → `TableConfirmationScreen`; invitation → `InvitationConfirmationScreen` | Physical table: restaurant/table/capacity, guest count, explicit new visit, occupied/reserved/reset guidance. Invitation: restaurant/table/party preview and explicit confirmation before shared-visit access |
| C12 | Active visit → `VisitScreen` | Participants, orders, bill, request states, closed-visit handling |
| C13 | Menu cart action → `CartScreen` | Quantity/edit/note/modifiers, remove/undo, fees, coupon, empty and stale-availability recovery |
| C14 | Delivery location or Profile → `AddressEditor`, `AddressBookScreen`, `AddressEditorScreen` | Add/edit/delete/default, instructions, field validation, out-of-area result |
| C15 | Cart/checkout pickup action → `PickupScreen` | Restaurant-configured slots, contact context, unavailable/closed guards |
| C16 | Cart → `CheckoutScreen` | Frozen-attempt creation, itemized charges/tip, delivery/pickup/visit context, pay-before/pay-at-end review |
| C17 | Checkout method selection | Demo PayPal balance/guest instruments; no credential/card fields or external handoff |
| C18 | `PaymentScreen` pending; resume from Orders | Retained attempt ID, safe exit, deterministic controlled outcomes |
| C19 | `PaymentScreen` failed/cancelled | Preserved basket, actionable message, new-attempt retry |
| C20 | `PaymentScreen` success | Order identity, exact amount, separate payment and food statuses |
| C21 | Orders → `OrderDetailScreen` | Channel-specific timeline, statuses, cancellation eligibility/reason and support |
| C22 | Visit → request actions | Water/cutlery/assistance/bill, duplicate guard, sent/acknowledged/completed/cancelled |
| C23 | `VisitScreen` bill section | Purchased lines, captured amount, outstanding amount, pending-allocation reservation, pay-at-end action |
| C24 | Visit → Another round | New editable cart round linked to the existing visit; historical orders stay frozen |
| C25 | Order → `ReceiptScreen` | Item/modifier/fee/discount/tip lines, captured/refunded amounts and order/table context; local preview only |
| C26 | Orders → `OrdersScreen` | Active/history filters, receipt/detail, reorder under current price/availability validation |
| C27 | Order detail → `ReviewScreen` | Editable local rating and note, saved state; no public-publication claim |
| C28 | Order support → `SupportScreen` | Persistent local conversation, quick replies, order context, unresolved issue; no real calls/messages |
| C29 | Discover → Book a table → `ReservationsScreen` | Restaurant/party/day/slot selection, booking, saved detail, modification/cancellation |
| C30 | Discover → Join waitlist → `WaitlistScreen` | Join, current position, local notification state, leave, closed-restaurant disabled state |
| C31 | App bar notifications → `NotificationsScreen` | Read/unread, contextual navigation, dismissal |
| C32 | Profile → `SettingsScreen` | Shared account/settings catalogue below |

## Owner and manager

Implementation lives in `lib/features/operations/`; focused entries below are arguments to `openOperation` unless noted. Manager UI excludes ownership/payment-policy/billing changes; domain actions enforce permissions independently.

| ID | Entry / implementation | Essential local states |
| --- | --- | --- |
| O01 | Overview → `_Overview` | Service status, active/ready orders, occupied tables, requests and derived payment summary; cards open corresponding records |
| O02 | More → Setup checklist → `_Setup` | Derived progress, existing restaurant draft, profile/services/menu/table/storefront task links, owner create-draft |
| O03 | More → `restaurant` → `_RestaurantEditor` | Name/description/address/contact, independent bundled logo/avatar and cover choices, save and dirty-form guard |
| O04 | More → `services` | Dine-in/pickup/delivery, hours, preparation, pickup slots, temporary pause and guest policy |
| O05 | More → `delivery-settings` | Demo area, fee/minimum, saved delivery slots and eligibility preview |
| O06 | Owner More → `payment-policy` | Pay-before/pay-at-end, demo PayPal connection state, local method explanation |
| O07 | Menu → `_Menu` | Search/category/name/price sorting, quick availability, duplicate, category rename |
| O08 | Menu → `item` → `_ItemEditor` | Create/edit/duplicate/archive, photo/description/price/dietary data, preview, save/discard |
| O09 | Item → `_ModifierEditor` | Required/optional min/max, exclusive choice limits, option price/name validation, edit/remove |
| O10 | Menu → `import` → `_MenuImport` | Bundled PNG/PDF sample preview, bounded extraction, cancellation/retry/offline state |
| O11 | Import review | Persisted local draft, editable flagged fields, duplicate detection, discard and explicit publish approval |
| O12 | More → `storefront` → `_Storefront` | Current menu/services/hours, local publish/unpublish; no public web deployment |
| O13 | Tables → `_Tables` | List/grid/live plan, zone filter, occupancy/balance/request badges, assigned-table scope |
| O14 | Tables → `floor` → `_FloorEditor` | Logical-coordinate canvas, pan/pinch/zoom/fit, select/drag/snap, add/duplicate/move/rotate/resize/delete, inspector/list alternatives, undo/redo/save/cancel |
| O15 | Table → `table` → `_TableDetail` | Name/seats/shape/zone/active editor, real local QR and parser-backed link, start/reset, occupied-delete rejection |
| O16 | Occupied table → `visit` → `_VisitDetail` | Guest/participant context, note, order/bill/request records, invitation QR, explicit move, cash/close/reset eligibility |
| O17 | Orders → `_Orders` | Search, preparation/channel/payment/time/attention filters, empty recovery |
| O18 | Order → `order` → `_OrderDetail` | Frozen items/options/notes, independent statuses, event history, permission-aware accept/reject/start/ready/serve/handoff/complete |
| O19 | Overview request card / `requests` → `_Requests`; activity → `request` → `_RequestRecord` | Active/completed/all, acknowledge, assign waiter, complete, cancel with reason and contextual detail |
| O20 | More → `reservations` → `_Reservations` | Date filter, arrivals, reschedule, no-show/cancel, eligible fresh-visit seating, waitlist notify/seat/remove |
| O21 | More → `payments` → `_Payments` | Attempts/status filters/detail/frozen allocations, pending resolution, linked order and refund records; order detail initiates refund |
| O22 | More → `team` → `_Team` | Scoped staff, fictional `.test` invitations, role descriptions, deactivate/reactivate, table assignments |
| O23 | More → `reports` → `_Reports` | Today/7-day/all-time, derived sales/captures/refunds/outstanding/order average, labeled channel bars, top items and source orders |
| O24 | More → `deliveries` → `_Deliveries` | Current/unassigned/issue/completed filters, courier assignment, handoff and issue resolution |
| O25 | More → `notifications` → `_Activity` | Read/dismiss notifications, restaurant event history and linked operational records |
| O26 | More → App settings; service/configuration entries | Shared appearance/language/notification/demo controls plus restaurant configuration and simulated payment connection |
| O27 | Owner More → `billing` → `_Billing` | Clearly fictional current/alternative plans; confirmation saves preview only |

## Waiter, kitchen and courier

| ID | Entry / implementation | Essential local states |
| --- | --- | --- |
| W01 | Shift → `_Overview` | Relevant orders, ready work, requests and assignments |
| W02 | Tables → `_Tables` | Assigned tables, zone/list/grid/plan and separate status indicators |
| W03 | Assigned occupied table → `_VisitDetail` | Visit duration, participants, notes, orders, bill and requests |
| W04 | Visit → Take an order → `openAssistedOrder` | Shared menu/item/modifier/cart/checkout builder; staff may submit an unpaid dine-in round |
| W05 | Requests → `_Requests` | Acknowledge/complete/cancel; management controls reassignment |
| W06 | Orders → ready order → `_OrderDetail` | Table destination and explicit served confirmation |
| W07 | Visit bill section | Balance/current-party QR, explicit demo cash collection, linked receipt/order records, close eligibility |
| W08 | Closed visit → Table reset | Needs-reset state and explicit mark-ready action |
| W09 | More → Role & help / App settings | Assigned tables, permissions, notifications and support |
| K01 | Queue → `_Orders(kitchen: true)` | Accepted/preparing/ready filters, elapsed demo-clock labels, channel/table identity |
| K02 | Queue ticket → `_OrderDetail` | Quantities/options/notes, per-item prepared checkbox, start/complete ticket; no automatic payment change |
| K03 | Availability → `_Menu(availabilityOnly: true)` | Search and guarded availability switches shared with customer/staff ordering |
| K04 | More → Role & help / App settings | Role information, notification simulation, display/accessibility and dark theme |
| D01 | Tasks → `_Deliveries` | Assigned current/completed records and empty state |
| D02 | Task → `_DeliveryDetail` pickup section | Restaurant/address, reference/package items, ready guard and explicit collection |
| D03 | Task delivery section | Address/instructions, status, schematic local map and local support conversation |
| D04 | Task actions | Collected → out for delivery → delivered with confirmation |
| D05 | Report delivery issue sheet | Customer/address/package/other reason, local note and manager visibility/resolution |
| D06 | Activity → completed `_Deliveries` | Completed tasks and detail |
| D07 | Profile → `_More` / App settings | Restaurant/role, local availability preference, notification settings and help |

## Shared settings and boundaries

`SettingsScreen` links profile/avatar, language/appearance, uncapped accessibility preferences, dining interests, saved addresses, favorites, notification categories/simulated permissions, security/sessions/password preview, local account reset, help/support, app information, demo privacy/terms, account/workspace/scenario controls and the isolated component/motion studio.

**Reset personal demo data** in Demo controls and **Reset this demo account** in Security and sessions clear the selected account's private carts, addresses, favorites, dining preferences, onboarding progress, support messages and reviews, and restore device app settings to defaults. They preserve shared restaurant orders, visits and payments. **Reset whole demo** and scenario replacement restore a shared fixture world and invalidate older domain operations.

Named mobile route aliases are `/gallery`, `/settings` (also `/preferences`), `/scan`, `/table…`, `/order/<id>`, `/visit/<id>`, `/item/<id>` and `/operations/<destination>`. A `raysto://table/<restaurant>/<table>` payload opens table confirmation through the parser. These are in-app route/parser entries, not a claim of registered OS app links. Operational destination aliases are role-scoped: owner/manager `overview`, `orders`, `tables`, `menu`, `more`; waiter `shift`, `tables`, `orders`, `requests`, `more`; kitchen `queue`, `availability`, `more`; courier `tasks`, `activity`, `profile`. The secondary `openOperation` section keys listed above are internal navigation entries rather than extra named-route aliases.

Local data is persisted through `DemoPersistence`, with schema/fixture versioning and reset. Language, appearance, accessibility, notification and simulated permission settings are device-wide; private dining preferences and customer records are account-scoped. English/French/Arabic interface localization includes RTL; authored restaurant fixture names and developer-gallery explanatory examples remain in English. Native permissions, live GPS, email, AI, PayPal, real authentication, external synchronization and publication remain intentionally absent. Existing foundation preview routes/tests stay isolated from the restaurant world.
