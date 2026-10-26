# Mobile experience pass — 0.8.0 source

**Later release:** the 26 October 2026 mobile 0.10.0 art and motion redesign is documented in [mobile-art-direction.md](mobile-art-direction.md). The source-only/test-deferral notes below describe the earlier 0.8 pass.

Requested 25 October 2026: improve the mobile design and fill gaps around camera QR, tables/maps and menu creation. The user explicitly requested **no tests or APK builds** for this pass. Work is limited to mobile source/dependency resolution and static analysis; no backend deployment is included.

## Audit and implemented changes

| Gap found | Updated flow |
| --- | --- |
| QR entry displayed a generated code but could not use the camera | Discover → Scan → Open camera now opens a native QR scanner with a viewfinder, flashlight, lifecycle pause/resume and permission/error fallback. Scanned text uses the existing table/invitation parser and explicit confirmation; arbitrary links are never launched. Manual and demo entry remain available. |
| Dining-room layout was available only within staff operations | Discover, Scan or restaurant menu → dining room offers the persisted table/floor layout, zone and party-size filters, status legend, selection details and an equivalent table list. The party size carries into table confirmation. Other parties' orders and bills are not exposed. |
| Staff table map was buried behind List/Grid/Plan controls | Staff Tables opens on Plan, with derived availability/occupancy/reset counts, semantic status colors, zoom/fit and list details. The original floor editor and its save/undo/redo workflow remain available. Large saved layouts fit their own coordinate bounds. |
| Customer menus lacked a strong browsing hierarchy | Restaurant menu now has a collapsing photo header, service choices, table/visit entry, photo cards and list mode, category navigation, search/clear, vegetarian filter and price sorting. Cart and item/modifier flows continue through the shared store. Missing dish photos get a neutral fallback. |
| Menu creation depended on individual item forms or a fixed sample import | Owner/manager Menu → Create a menu draft opens Menu studio. Pasted `Category | Dish | Price | Description` lines generate editable draft records. Drafts are persisted locally, every generated item requires review, invalid prices stay flagged, duplicates block publishing and replacement/discard require confirmation. Add-a-dish and guest-menu preview actions are provided. |
| Incomplete menu metadata was hard to notice | Menu readiness shows real counts for missing descriptions and unknown dietary information. It never infers allergens, ingredients or dietary claims. |
| Staff QR links were visible but inconvenient to reuse | Table & QR adds Copy table link beside the existing generated QR and local parser-backed preview. |
| Test tools distracted from the welcome experience | Sandbox/local payment test entries are removed from Welcome and remain available through Profile and the connected workspace. |

New UI copy is provided in English/French/Arabic. Shared forest/paper/lime surfaces, Material icons, native ink, existing page motion, uncapped text scaling and role guards are retained. Camera permission is requested only after choosing Open camera; Android declares optional camera hardware and iOS has a camera-purpose description.

## Menu draft example

```text
Starters | Tomato soup | 6.50 | Roasted tomatoes and basil
Mains | Garden pasta | 12.00 | Add your actual dish description
Drinks | Lemonade | 3.00 | Add your actual drink description
```

This is **local structured-text generation**, not a live AI/OCR service. It does not invent a restaurant's menu or translate its authored content. Prices follow the existing local demo's EUR pricing. Uploaded photos/PDF OCR, AI recipe/menu generation and new server-side menu permissions are separate integrations. The existing sample document import remains explicitly labeled as a demo.

## Source map and boundaries

- `lib/features/scanning/qr_camera_screen.dart`: native camera scanner using mobile_scanner 7.4.2.
- `lib/mobile/table_map.dart`, `experience_widgets.dart`: shared map, legend, action/hero and metric surfaces.
- `lib/features/customer/restaurant_menu.dart`, `dining_room.dart`, `visits.dart`: guest menu, floor and QR entry.
- `lib/features/operations/menu_builder.dart`, `menu.dart`, `tables.dart`: staff creation/review and floor overview.
- `lib/domain/menu_composer.dart`: bounded integer-price parser generating drafts from user-authored lines.
- `lib/l10n/experience_catalog.dart`: additional localized interface copy.

Camera decoding is native; restaurant/table/menu state in these flows still belongs to the isolated persisted DemoStore. A camera scan does not authorize a backend restaurant/table visit. Server-issued table invitations, live seat availability, live menu writes, image/document import and iOS Universal Links remain integration gaps. Existing Firebase login and standalone PayPal Sandbox services retain their own connected flows.

No camera/device acceptance, visual render, runtime layout validation, tests or APK build is claimed for this pass. The previous 0.7 APK/artifact evidence predates these changes. Compile/device checks will be performed when requested.

Scanner references: [package and native lifecycle usage](https://pub.dev/packages/mobile_scanner), [upstream source](https://github.com/juliansteenbakker/mobile_scanner). Installed package source was consulted for the exact APIs.
