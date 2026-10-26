# Raysto web · Phase 1

A separate Next.js 16.4.3 application for restaurant operations and public guest dining. It uses React 19.3.1, TypeScript, AG Grid Community 36.2.0, locally bundled Plus Jakarta Sans, Material Symbols Rounded and a Raysto adaptation of Material 3 Expressive.

The **Good company edition** adds an editorial identity, locally hosted variable Fraunces, two original generated photographs, custom ticket buttons, a Three.js table sculpture, Motion parallax and Lenis wheel smoothing. See [creative direction and research](../docs/web-creative-direction.md). System and app reduced-motion settings disable spatial effects; unsupported WebGL retains an olive illustration.

## Run

```powershell
cd web
npm ci
npm run dev
```

Open [the guest experience](http://127.0.0.1:3100), [demo account chooser](http://127.0.0.1:3100/login), or [table 1 QR journey](http://127.0.0.1:3100/table/1).

The preview binds to loopback. A phone cannot reach the computer through a `127.0.0.1` QR. For a phone preview, run Next with an explicitly selected reachable LAN host and use that address in the browser before generating the QR. Production deployment is separate; this task does not change rays.to, api.rays.to, AWS, Firebase, or Awhar.

## Demo accounts

Choose an account—no password is requested:

| Account | Responsibilities |
| --- | --- |
| Yasmine / owner@raysto.test | Full restaurant workspace |
| Adam / manager@raysto.test | Operations and team; excludes owner billing |
| Lina / waiter@raysto.test | Orders, table service, reservations and requests |
| Omar / kitchen@raysto.test | Accepted-ticket preparation and menu availability |
| Sami / courier@raysto.test | Assigned deliveries and local issue reporting |
| Alex / alex@raysto.test | Guest profile, orders, favorites, bookings and table visit |

All identities and operational records are fictional. This chooser is not production authentication or authorization.

## Try a complete journey

1. Open `/table/1` and explicitly join the table.
2. Choose a dish, size, quantity and optional kitchen note; add it to the basket.
3. Review `/cart`, then `/checkout`. Try `WELCOME10`, a tip, and a failed or cancelled demo payment. Neither failure creates an order or clears the basket.
4. Place a successful demo order or choose pay at restaurant. The order freezes item prices and totals.
5. Choose the owner account, open Orders, and accept the new order. Kitchen can start and finish the ticket. Waiter/management can mark ready dine-in or pickup orders served. Courier can move assigned ready deliveries through delivery completion.
6. Return to the guest order or visit. Preparation and payment statuses remain independent. Settle an unpaid demo bill; the team can close a visit only when orders are closed and balances settled, then reset the table.

Tabs on the same origin share the demo through `localStorage` events. Each other browser/device has its own independent world. Concurrent writes use last-write-wins and are not a production synchronization mechanism. No sensitive information belongs in this store.

## Checks

```powershell
npm run typecheck
npm test
npm run test:e2e
npm run build
```

Browser tests use installed Microsoft Edge by default. Alternatively set `PLAYWRIGHT_EXECUTABLE` to a Chromium executable. They reuse a running preview on port 3100 or launch one. Screenshots are written to `artifacts/screenshots/`; failure traces go to ignored `test-results/`.

```powershell
npm run start
```

Run `start` after a successful build to serve the production artifact on loopback port 3100.

## Structure and scope

- `src/lib/domain.ts`: fixture model, money calculations, role permissions, checkout/transition rules.
- `src/lib/store.tsx`: transactional demo actions, versioned persistence, cross-tab updates and storage recovery feedback.
- `src/components/ui.tsx`: shared controls, dialogs, feedback, totals, media and export.
- `src/components/workspace*.tsx`: restaurant shell and operational screens.
- `src/components/guest.tsx`: public dining flows.
- `src/app/tokens.css`: semantic colors, typography roles, motion and light/dark tokens.
- `src/app/globals.css`: responsive compositions and native web control styling.
- `tests/`: domain checks and real browser journeys.

The mobile application remains a native Flutter product. No Flutter web target is added. For screen coverage, design sources and phase boundaries, see [web-phase-1.md](../docs/web-phase-1.md).

## Assets and licensing

Photographs and Plus Jakarta Sans are reused from the existing Raysto asset library. Full photographer attribution and source license references are in [assets.md](../docs/assets.md). Font OFL is retained in `public/fonts/OFL.txt`. Material Symbols uses the Apache-2.0 license from its installed package; the retained notice is in `public/licenses/`. Restaurant/product photos are illustrative stock imagery, not verification of ingredients.

## Production boundaries

The web application does not import Firebase or Serverpod clients and does not send requests to live commerce services. PayPal, email, SMS, AI extraction, map routing, location and cross-device synchronization are not connected. Public deployment, real account security, production APIs, real payments and operational concurrency require the next integration phase. The intended backend remains the existing Serverpod/PostgreSQL service, not a new database.
