# Web phase 1 — restaurant workspace and public guest experience

Implemented 25 October 2026 in the standalone `web/` Next.js application. This new web scope supersedes the original mobile-only prompt's prohibition on building a separate web frontend. It does not migrate the native app or authorize new production integration.

## Design direction and research

The web product retains Raysto's established paper `#F6F7F2`, forest `#173F35`, lime `#D7F978`, mint and warm surfaces, actual Plus Jakarta Sans weights, and semantic light/dark modes. Material Symbols Rounded provides one consistent icon family. Density and navigation adapt to desktop operations and public phone ordering; the mobile document's phone-preview frame is not applied to the desktop dashboard.

Research consulted on 25 October 2026:

- [Next.js installation](https://nextjs.org/docs/app/getting-started/installation): App Router, TypeScript, local fonts, Node requirements and current stable 16.4.3. Version independently verified against npm before installation; package versions are pinned with a lockfile.
- [Google's Material 3 Expressive research](https://design.google/library/expressive-material-design-google-research): emphasis, recognizable hierarchy and expressive shape in service of useful tasks. Applied as calm tonal dashboard surfaces, rounded control groups, warm editorial guest layouts and visible primary actions.
- [Material 3 typography](https://m3.material.io/styles/typography/overview): display, headline, title, body and label roles. The site requires JavaScript; detailed implementation was also grounded in the existing project typography guide. No claim that a particular font is a mandatory 2026 choice.
- [Google's Material 3 Expressive introduction](https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/): shape, emphasis and meaningful motion. Adapted to web interaction rather than claiming a first-party Google React component implementation.

Type sizes use rem so browser text preferences can grow them. Controls have visible focus/state layers and stable hit areas. Dialogs use the native `dialog` top layer with focus restoration and dirty-draft confirmation. OS reduced motion or the app preference suppresses animation. No live service, timing or revenue is fabricated for animation.

## Screen inventory

| Route | Implemented experience |
| --- | --- |
| `/`, `/discover` | Editorial discovery, local dish search, categories/diet filter, favorite controls and restaurant entry |
| `/r/olive-and-hearth` | Restaurant cover/information, service selection, menu categories/search, availability, basket summary |
| Menu item dialog | Size, quantity, notes, illustrative allergen notice, current-price basket insertion |
| `/scan` | QR instructions and validated manual table number/local-link parser |
| `/table/:id` | Table availability, capacity, explicit visit creation; occupied/missing table recovery |
| `/cart` | Quantity changes, note editing, remove/undo, service selection and totals |
| `/checkout` | Delivery region/minimum, guest context, coupon, tip, demo payment choice and success/failure/cancel outcomes |
| `/orders` | Guest active/past/all orders |
| `/orders/:id` | Preparation timeline, independent payment status, guarded cancellation, demo settlement, receipt/print, feedback and current-price reorder |
| `/visit` | Table context, another round, service requests, duplicate guard, bill and per-order settlement |
| `/reservations` | Date/party/time validation, booking/cancellation and local waitlist |
| `/favorites` | Saved dishes and current availability |
| `/account` | Editable fictional profile/address, dark mode, reduced motion and explicit whole-demo reset |
| `/help` | Relevant FAQ and clearly transient local support-note preview |
| `/about` | Demo/privacy/persistence explanation |
| `/login` | Five restaurant demo identities and role entry |
| `/dashboard/overview` | Derived current sales/active orders/occupancy, hourly chart, floor summary, active order grid and top dishes |
| `/dashboard/orders` | AG Grid sorting, resizing, pagination, search/status/channel filters, CSV export and order detail/actions |
| `/dashboard/kitchen` | Accepted/preparing/ready board with item options/notes and explicit transitions |
| `/dashboard/tables` | Zone filters, floor/list views, current visit orders, real QR generation/print, close/reset guards |
| `/dashboard/menu` | Search/category filters, shared availability, create/edit item with real save/cancel and draft guard |
| `/dashboard/reservations` | Arrival statuses, new booking, capacity-aware seating, cancel and simulated waitlist notification |
| `/dashboard/requests` | New/acknowledged/completed service requests |
| `/dashboard/deliveries` | Courier assignment, assigned role view, guarded handoff/completion, local issue recording |
| `/dashboard/payments` | Paid/unpaid/refunded records, independent collection/refund actions and CSV |
| `/dashboard/team` | Team list, fictional .test identity creation/edit, roles and activation |
| `/dashboard/reports` | Period filters, collected totals, average paid order, channel counts, item quantities and CSV |
| `/dashboard/storefront` | Current restaurant/menu/service preview and setup status |
| `/dashboard/settings` | Restaurant details, service pause/channels, delivery fee/minimum, appearance and guarded save/discard |
| `/dashboard/activity` | Local action history and delivery issues |
| `/dashboard/billing` | Owner-only illustrative plan explanation; no subscription connected |
| Shared states | Restoration, storage warning, empty/no-match, unavailable item, access denied, missing route, route error/retry, dialogs and toast feedback |

## Data and business rules

One versioned browser store holds restaurant data; screens read committed state from it. Edits use separate drafts. Each mutation clones before committing; thrown validation leaves the previous state intact. Order lines and integer minor-unit totals are frozen at checkout. Preparation never settles payment. A declined/cancelled payment simulation does not create an order or discard the cart. Current price, availability, service pause, delivery region/minimum and table visit are checked on submission. Double submission is blocked by cleared transactional cart state and the submit latch.

Restaurant roles have distinct navigation and guarded domain transitions. Guest table links do not join an existing party or create restaurant permissions. Visits cannot close with unfinished/unpaid orders. Requests are deduplicated while outstanding. A settled table moves to needs-reset before becoming available again. CSV fields escape quotes and neutralize formula prefixes.

This is demo enforcement, not a security boundary: browser state is user-controlled. Tabs on the same origin receive storage updates, with last-write-wins concurrency; devices do not synchronize. Persistence errors are surfaced. Whole-demo reset is explicit and scoped to `raysto.web.demo.v1`.

## Deliberate phase boundaries

- No changes to AWS, Awhar, api.rays.to, rays.to, Firebase projects, SQL schemas or live commerce services.
- No real auth, PayPal, invitations/email, SMS, reservations, courier/location service or AI claims.
- No floor-coordinate drag editor, scanned-menu OCR/import, production billing, live maps, multilingual translation or shared-party cross-device invitations in this phase. The existing mobile scope remains its own implementation; this document describes the delivered web screen inventory.
- The preview is local. QR payloads use the current origin; a phone needs a reachable host to open the link.
- Website public hosting and backend integration are separate from the guest UI's account-free access.
- No physical-device or screen-reader certification follows from desktop browser checks.

## Validation

See `web/artifacts/screenshots/` for actual-font rendered review images. The existing native frontend is checked separately; web UI screenshots do not establish native performance.

Verified on 25 October 2026:

- `npm run build`: successful production compilation, TypeScript checking and route generation with Next.js 16.4.3.
- `npm run typecheck`: passed.
- `npm test`: all 6 domain tests passed (minor-unit totals, service/region/minimum guards, stale price/availability, active visits, role-specific transitions and route permissions).
- Playwright: all 7 browser scenarios passed across the final full and targeted runs: checkout-to-service, table/bill/request, menu draft/availability, role/cross-tab, draft recovery/dark grid, screen inventory, and keyboard/reduced-motion/2× text. Screen inventory covers 14 workspace destinations at desktop and 20 public/workspace paths at 320px. Screenshot and account-form waits were tightened to inspect loaded fonts and lazy-loaded content rather than transient loading states.
- Native `flutter analyze`: no issues found.
- Native `flutter test --no-pub test/design_system_test.dart test/domain_test.dart test/navigation_test.dart`: all 25 existing regression tests passed using the project-scoped SDK. The initial sandbox run could not access its temporary compiled files; the authorized run outside the sandbox passed.
- Actual browser pixels reviewed for desktop discovery/dashboard/tables and narrow guest/dashboard screens. The review caught and fixed cramped currency values and mini-table overlap beyond the document-level overflow assertions.

Keyboard focus restoration, OS reduced motion and 2× root text are checked in the browser suite. Browser tests use isolated contexts; they do not reset the user's visible demo. Screenshots are `guest-desktop.png`, `guest-mobile.png`, `dashboard-desktop.png`, `dashboard-mobile.png`, and `dashboard-dark.png`. They are review artifacts, not physical-device certification.
