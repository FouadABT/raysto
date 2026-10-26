# Raysto mobile design and motion

Updated 24 October 2026 for the persistent local mobile demo. Android and iOS are the targets. There is no Flutter web target or web application in this phase.

## Foundation and Material 3

The app extends the existing `lib/design_system/` foundation. `AppTheme` enables the installed Flutter Material 3 implementation and configures real app bars, navigation bars, fields, switches, sheets, dialogs, snackbars and route transitions. Existing `AppButton`, `AppChoice`, `AppPanel`, `AppPill`, `AppNotice` and related wrappers retain their established APIs and native Material ink. Focus and semantics stay on a stable minimum 48 × 48 logical-pixel target while only the inner content compresses during a press.

The approved paper (`#F6F7F2`), forest (`#173F35`), lime (`#D7F978`), mint and peach palette is retained. Product surfaces resolve through `ThemeData.colorScheme`: primary and its foreground, primary/secondary/tertiary containers, surface containers, outline and error roles. Dark mode uses separately selected deep green surfaces and pale green/lime emphasis; it is not a color inversion. `AppStatusColors` adds paired success, warning and information roles. State labels and icons accompany status color.

The established Phosphor foundation remains available. New product screens use the Flutter Material outlined icon family; legacy design-studio examples retain Phosphor icons. The studio’s explicit canonical-palette swatches intentionally show the original palette in either theme; its surrounding controls and surfaces follow the selected theme.

## Typography, localization and layout

Real Plus Jakarta Sans files are bundled at weights 400, 500, 600 and 700. Noto Sans Arabic is bundled as the Arabic fallback, including its OFL license. Semantic `TextTheme` roles carry type size, weight, line height and tracking rather than each feature defining another scale. See [asset provenance](assets.md).

The shared offline catalogues in `lib/l10n/` provide French and Arabic translations of product interface strings. Flutter’s Material, Cupertino and Widgets localization delegates supply native localized controls and RTL. Directional padding/alignment follow the locale; prices and email addresses preserve their intended reading direction. Restaurant-authored fixture names and historical descriptions remain in their source language. The developer component studio retains English explanatory sample copy.

The existing spacing and shape tokens are preserved. New mobile pages use 16 logical-pixel side margins, generous section spacing and flexible wrapping rather than dense dashboard tables. Detail and form routes hide the role navigation. Settings, forms and sheets remain scrollable with safe-area and keyboard insets.

System text scaling is never capped. An optional additional app factor multiplies the platform scaler and cannot reduce it. At larger text sizes, the main shell replaces the crowded row of navigation destinations with a labelled “Navigate” action opening a full list of destinations. This keeps the selected destination and every navigation label readable on narrow phones. App-bar height also grows for large text. The role shell keeps destination state while changing tabs.

## Motion mapping

The app retains the foundation’s shared motion tokens instead of introducing a second set of feature-specific curves.

| Purpose | Shared token | Normal duration |
| --- | --- | --- |
| Press and small feedback | `feedback` | 140 ms |
| Selection, result or badge update | `selection` | 240 ms |
| Retained branch/content change | `branch` | 400 ms |
| Sheet entry / return | `sheet` / `sheetReverse` | 360 / 240 ms |
| Progress or completion | `milestone` | 440 ms |
| Existing foundation dock | `dock` | 460 ms |
| Brief welcome story reveal | `reveal` | 650 ms |

Native Material route, dialog, sheet and navigation transitions remain authoritative. Android uses the installed predictive-back transition builder and iOS uses the Cupertino transition builder. The reduced-motion wrapper preserves native gesture detectors instead of deleting the route wrapper. Platform gesture quality still requires native-device verification.

`RetainedBranches` captures the current transition state when selection changes, so rapid retargeting does not restart from a fixed endpoint. Inactive/outgoing branches are excluded from taps, focus, semantics and tickers. Onboarding coordinates step content with progress and similarly excludes outgoing content from interaction. Search fields stay in place while results change. Quantity changes affect the number and totals; order updates affect the relevant status and timeline. Floor-plan dragging follows the pointer and snaps on release. The local assistant briefly shows progress before revealing a complete answer. A payment remains pending until its local outcome actually resolves.

View-owned work captures its account, restaurant and world generation and ignores stale results. Valid payment operations belong to the domain store and survive role changes. Whole-world reset and scenario replacement invalidate old domain work. Staff onboarding practice uses a separate in-memory `DemoStore` and real guarded request, kitchen and delivery transitions; it never mutates the working restaurant.

## Reduced motion and accessibility

Effective reduced motion is the logical OR of the app preference, inherited motion settings, `MediaQuery.disableAnimations`, and the platform accessibility requests. An app switch cannot turn off an OS request. Optional navigation haptics honor the stored preference.

Reduced mode removes custom scale/translation/stagger and uses immediate meaningful updates. `StatusBadge` returns its final pill directly in reduced mode: a zero-duration `AnimatedSize` was avoided because it could continue scheduling frames during large-text layout changes. Collapsing content leaves the focus and semantics trees immediately. Press targets retain their geometry. Dirty forms protect unsaved changes; editing sheets do not use a drag-dismiss path that could bypass their guard.

Automated tests load actual Jakarta and Arabic font assets. The account tests check light and dark foreground/background text pairs against a 4.5:1 contrast floor; narrow 320px French/Arabic account layouts at 2× text; Arabic RTL; resumable onboarding; verification recovery; and isolated staff practice. Gallery tests exercise all collections at 320px/2× text in both themes, plus validation, cancellation and undo. Existing design-system tests cover press geometry, duplicate activation, focus/semantics exclusion and OS/app reduced motion.

These tests are layout and behavior evidence, not a claim of measured 60 fps, screen-reader quality, physical-device performance or iOS gesture certification. Current native build/runtime evidence and remaining limits are recorded in [validation](validation.md).

## Maintenance

Use the shared components and semantic colors first. Keep domain states separate: preparation, payment, table occupancy and service requests must not collapse into one colored status. Keep historical menu prices immutable, forms as drafts until saved, and mock service outcomes explicit. Add localizations when adding product interface strings. Review the component/motion gallery through Settings → Demo controls; it stays isolated from restaurant records.

References: [Flutter Material widgets](https://docs.flutter.dev/ui/widgets/material), [TextTheme](https://api.flutter.dev/flutter/material/TextTheme-class.html), [Flutter accessibility](https://docs.flutter.dev/ui/accessibility), [Flutter performance](https://docs.flutter.dev/perf/ui-performance), [Material 3 motion](https://m3.material.io/styles/motion/overview/how-it-works).
