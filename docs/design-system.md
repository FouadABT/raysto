# Raysto design-system contracts

The [original guide](MOBILE_APP_DESIGN_SYSTEM_GUIDELINES.md) remains the design authority. This document maps it to the mobile Flutter foundation, records the reusable APIs, and distinguishes implementation contracts from verified evidence. See [product direction](product-direction.md) for scope and `validation.md` for executed checks and limitations.

## Architecture

| Location | Responsibility |
| --- | --- |
| `lib/main.dart` | Mobile app entry point |
| `lib/app/app.dart` | App theme, motion preferences, routes, customer shell and selected destination |
| `lib/app/preview_store.dart` | One source of truth for sample dishes and session shortlist state |
| `lib/app/navigation.dart` | Responsive travelling dock and retained branch transitions |
| `lib/design_system/tokens.dart` | `AppColors`, `AppSpace`, `AppRadius`, `AppType` |
| `lib/design_system/theme.dart` | `AppTheme.light` maps the system to Material primitives |
| `lib/design_system/motion.dart` | `AppMotion` timing/curves and `MotionScope` accessibility policy |
| `lib/design_system/controls.dart` | Reusable buttons, cards, choices, chips and text entry |
| `lib/design_system/surfaces.dart` | Panels, typography compositions, notices, disclosures, progress, media and sheets |
| `lib/design_system/design_system.dart` | Public foundation exports |
| `lib/features/preview/preview_screens.dart` | Restaurant compositions built from the shared foundation |
| `lib/demo/` | Isolated interactive gallery examples |
| `assets/fonts/`, `assets/images/`, `assets/licenses/` | Bundled visuals and retained notices; provenance in `docs/assets.md` |

The foundation owns appearance, reusable interaction behavior and local widget resources. Feature screens own domain wording and task composition. Shared shortlist state belongs to `PreviewStore`; gallery example state belongs to its own widget/state scope. A gallery interaction must never modify the customer's collection. No data layer pretends to call a remote service.

## Color and typography

| Canonical token | Hex | Intended role |
| --- | --- | --- |
| `paper` | `#F6F7F2` | Main canvas |
| `white` | `#FFFFFF` | Content panels |
| `ink` | `#173E34` | Main text and icons |
| `forest` / `primary` | `#173F35` | Main actions and dock |
| `muted` | `#68756C` | Canonical quiet color; decorative details |
| `lime` / `selected` | `#D7F978` | Restrained selected emphasis |
| `mint` / `supportingSurface` | `#E6EDE2` | Secondary surfaces |
| `peach` / `warmSurface` | `#F3E8DB` | Supporting notices |
| `line` / `outlineSubtle` | `#DCE2D9` | Quiet structural dividers |

The canonical muted token remains unchanged. Ordinary secondary copy uses the darker semantic `secondaryText` (`#59675E`) because canonical muted on paper measures 4.48:1, just below the guide's 4.5:1 ordinary-text target. The semantic alias also supports copy on mint and peach. Explicit status roles use `error` `#A32D32`, `warning` `#805300`, and `success` `#28633F`, with white foregrounds. Status meaning always includes text and/or an icon.

Plus Jakarta Sans is bundled in real static 400, 500, 600 and 700 weights. `AppTheme.light.textTheme` defines editorial headings at 32–36, section headings at 21, card titles at 14–16, body at 14–16 with 1.6 line height, and compact labels at 11–15. `AppType.style` is the shared fallback for a deliberate composition. Important copy must wrap and grow; do not shrink it or cap the user's text scaler to fit a card.

Only the approved light theme is in scope. A dark theme, localization and RTL content require separate product decisions and validation. There is no desktop/web preview frame or Flutter web target.

## Geometry

Spacing tokens are 4, 8, 12, 16, 20, 22, 24, 28 and 32 logical pixels. Normal screen gutters are 22; panels use 20; sheets use 24. Card radius is 24, button radius 22, selection radius 18, media/sheet radius 28, and dock radius 27. Surfaces default to zero elevation; typography and spacing carry hierarchy.

Every interactive wrapper provides at least a 48 × 48 logical-pixel target. Content compression never resizes the hit area. Layouts use flexible widths and content-driven heights with scrollable content, system safe areas, keyboard insets and dock clearance. Section trailing actions move below the heading on narrow or large-text layouts.

## Public component contracts

| API | Contract |
| --- | --- |
| `AppButton` | Named label and callback; primary/secondary, disabled and explicit busy states; busy suppresses repeat activation; 0.96 inner press scale in normal motion |
| `AppIconButton` | Required accessible label/tooltip; full target around a 22-pixel icon |
| `AppTapSurface` | Tappable card/surface with stable target, native ink, visible focus and 0.98 inner compression |
| `AppChoice` | Explicit selected state plus border/check and semantics; title/subtitle wrap |
| `AppChip` | Explicit selected state with check/shape feedback; parent uses wrapping layout for a choice set |
| `AppTextField` | Persistent label, retained controller ownership with caller, correct multiline keyboard/action and nearby error text |
| `AppPanel` | Material-compatible surface, consistent radius/padding; avoid unnecessary nested cards |
| `AppSectionTitle` | Heading semantics, optional explanatory copy/action, adaptive stacking |
| `AppEyebrow` | Restrained 11-pixel uppercase context with wider tracking |
| `AppPill` | Noninteractive metadata; use a real control when it acts |
| `AppNotice` | Inline explanation/recovery with text and optional icon/action; no routine modal interruption |
| `AppDisclosure` | Explicit expanded semantics; collapsed controls are removed from focus/input/accessibility; surrounding size animates in normal mode |
| `AppProgress` | Actual clamped value and readable label/semantic percentage; changes animate without inventing a measurement |
| `AppMedia` | Bundled image, meaningful description, stable extent, 240 ms decode fade, deliberate unavailable fallback |
| `showAppSheet<T>` | Root-level blocking modal, scrollable content, safe areas and keyboard inset, explicit close target, up to 88% viewport height |
| `RaystoDock` | One travelling indicator, adaptive wrapped label measurement, selected semantics and stable destination identity |
| `RetainedBranches` | Preserve useful branch state; only active content accepts taps/focus/semantics; inactive decorative tickers stop |

App-authored iconography uses regular Phosphor icons by default and fill for meaningful selection/completion. Directional icons follow the platform/text direction where appropriate. Intrinsic platform controls retain their framework behavior.

## Motion policy

| Token | Normal timing | Purpose |
| --- | --- | --- |
| `feedback` | 140 ms | Press/release |
| `selection` | 240 ms | Selection, disclosure, short replacement, image decode |
| `branch` | 400 ms | Coordinated destination change |
| `sheet` / `sheetReverse` | 360 / 240 ms | Contextual sheet presentation/dismissal |
| `milestone` | 440 ms | Actual progress/completion emphasis |
| `dock` | About 460 ms | Interruptible spring selection |
| `reveal` | Up to 650 ms | Optional restrained initial presentation |

Spatial movement uses `easeOutCubic`, coordinated destination changes use `easeInOutCubicEmphasized`, and effects use `easeInOut`. The dock retargets from its current position and velocity instead of beginning a new unrelated movement. The branch transition removes outgoing interaction immediately and clears outgoing opacity early so two full headings do not compete.

Effective reduced motion is the logical OR of the app setting, `MediaQuery.disableAnimations` and relevant platform accessibility flags. `MotionScope` listens for runtime accessibility changes. App preferences cannot turn off the device's request. Reduced motion replaces selected/disclosed content directly, removes spatial compression, positions the dock immediately, and displays decoded images without a passive fade. Native back gestures remain native route behavior.

State commits and callbacks do not depend on an animation completing. No fake service delay, perpetual decorative motion or simulated AI processing is part of the product flow. Explicit gallery controls can preview states and stop/reset them.

## State and navigation

The customer shell has three recurring tasks: Discover, Menu and Saved. Preferences are an app-bar action and `/gallery` is a separate review route. `/dish/<id>` supports direct contextual detail; unknown routes recover visibly. Feature code prevents duplicate detail pushes and treats edit-sheet content as a draft until the user commits it.

The Android and iOS projects register local custom-scheme entry points such as `raysto://app/dish/bowl`, `raysto://app/gallery` and `raysto://app/preferences`. These are not verified website app links. [Native platform setup](native-platforms.md) records the manifest/plist configuration, brand resources and checks separately from actual device link-dispatch evidence.

Saved items, collection title/note, filters and motion preference are session-only. The same store drives detail, menu and Saved updates. Cancel retains the committed collection; undo restores actual prior data. Closing a modal does not submit an action. The preview needs no timers, integration permissions, background work, accounts or financial operations.

## Guide traceability

This is a scope/implementation map, not a claim that every acceptance item has been tested.

| Guide sections | Application treatment |
| --- | --- |
| 1–4: principles, scope and simplicity | Product brief, first visible dish, no setup gate, contextual task flow |
| 5–7: visual foundation | Semantic canonical palette, accessible secondary text alias, bundled typography, shared geometry |
| 8: phone responsiveness | Flexible mobile layouts, safe areas/keyboard/dock clearance; narrow and large-text checks belong in validation |
| 9: icons and media | Official Phosphor package; bundled matching stock imagery with source/license record |
| 10–11: anatomy and navigation | Three task destinations, contextual details/preferences, retained branches and responsive dock |
| 12–13: motion and accessibility | Shared motion policy, stable press targets, runtime reduced motion, input/focus/semantics exclusion |
| 14: component architecture | Public primitives above with explicit states/callbacks and no domain decisions inside their styling |
| 15–16: editing and modals | Labeled inputs, local edit drafts, validation, cancellation/undo, root modal sheet |
| 17: AI | Intentionally absent because this task has no useful AI requirement |
| 18: supporting states | Honest empty/no-match states and image failure; explicit gallery examples for asynchronous states |
| 19: state and lifecycle | Shared session store, retained tab context, disposable controllers, duplicate-action protection |
| 20: localization/trust/platform | English scope declared, no false real-world actions, native editing/back/scrolling conventions |
| 21–22: implementation and gallery | Separate foundation/features/demo structure; interactive gallery isolated from user data |
| 23–24: workflow and evidence | Build one complete sample flow, inspect visuals/interactions, record actual checks in validation |
| 25–27: anti-patterns and project memory | Retain the original guide; use this project's name/identity, scope and domain rather than copying the source app |

## Extending the foundation

Add new product flows by composing these APIs. Introduce a component only when it owns a distinct reusable interaction contract. Preserve a single source of truth for real domain changes, separate editable drafts from committed values, and keep authored examples separate from service responses. Add real production states and cancellation when adding asynchronous features.

Review actual pixels with the bundled fonts/photos, narrow layouts, large text, keyboard-visible forms, interrupted motion and a complete task journey. Run device-level accessibility, performance and native gesture checks before claiming production readiness. A source audit or widget test is not a substitute for that evidence.
