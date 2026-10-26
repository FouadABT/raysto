# Complete mobile frontend implementation

Active request: `COMPLETE_MOBILE_FRONTEND_PROMPT.txt`. Android/iOS only; no backend or web.

## Audit

Flutter 3.41.9 / Dart 3.11.5. Existing ChangeNotifier + MaterialPageRoute architecture; no router or storage library. Existing Plus Jakarta Sans, paper/forest/lime tokens, real Material 3 controls, native page/sheet transitions, device OR app motion policy, retained branches and component studio are reusable. Existing preview is only browse/save and is retained as a developer reference. No pre-existing product workflows or user data are present; directory has no Git repository.

Targeted gaps: semantic dark colors and status extensions, Arabic font/RTL and externalized strings, local persistence, typed world and invariants, auth/onboarding, role shells, all ordering/operations flows, real local QR, floor editor, settings, scenarios and cross-role verification. New product screens use one Material icon family. Existing native identifiers are provisional; no signing/service credentials are added.

## Navigation

Customer: Discover / Orders / Assistant / Profile. Owner/manager: Overview / Orders / Tables / Menu / More. Waiter: Shift / Tables / Orders / Requests / More. Kitchen: Queue / Availability / More. Courier: Tasks / Activity / Profile. Details, editing, scan and checkout use focused native routes. Account changes replace the personal navigation tree while the shared repository remains alive.

## Passes

- [x] 1. Read complete prompt and inspect foundation, routes, dependencies, assets and tests.
- [x] 2. Semantic themes, localization, shared components, typed persistent demo world.
- [x] 3. Shared entry, local authentication, customer/owner/staff onboarding.
- [x] 4. Complete connected customer journeys C01–C32.
- [x] 5. Owner/manager workflows O01–O27 including floor editor/import.
- [x] 6. Waiter W01–W09, kitchen K01–K04, courier D01–D07, settings.
- [x] 7. Integrate all roles and scenarios A–L; repair shared invariants.
- [x] 8. Format, analyze, meaningful tests, native build, visual/runtime review and handoff.

## Parallel ownership

- Domain agent: lib/domain; persistent state, fixtures, actions, invariants and domain tests.
- Operations agent: lib/features/operations; owner/manager/waiter/kitchen/courier.
- Foundation agent: themes, lib/l10n, lib/features/account; entry/onboarding/settings.
- Root: app integration, lib/mobile shared product components, customer flows, validation/docs.

## Verification baseline

Previous foundation had 18 passing tests and successful Android release build. That evidence predates this implementation. New results must be recorded separately. Prior emulator booted but app installation/runtime was not validated. iOS cannot be compiled on Windows. Do not claim performance, native screenshots, or completion before evidence.

## Official references consulted

Flutter Material widget catalog, TextTheme API, accessibility and UI performance documentation; Android accessibility and Material 3 guidance; Material motion/typography references. Material site text requires JavaScript in the research tool. Current online Flutter docs describe a newer Material packaging change; this project stays on installed 3.41.9 `package:flutter/material.dart` and its actual APIs. No SDK migration.


## Final integration evidence

- All S/C/O/W/K/D screen families, shared domain workflows and scenarios A–L are implemented; see the screen inventory and demo guide for exact entry points and scope.
- Regression repairs include reduced-motion badge layout, live operational details, origin-scoped duplicate-route protection that preserves nested registration, explicit invitation approval, current opening hours/configured slots and truthful basket/reset copy.
- The final 52-test suite passes, with clean formatting and analysis. Native table-link testing exposed Android host stripping; source was repaired, both URL forms have regression coverage, and the cold-launch confirmation was inspected on the emulator.
- Native x64 Android build/install/launch, owner/customer surfaces, floor zoom and payment restart/recovery were inspected. The repaired table URI now opens physical-table confirmation on cold launch without joining a party. Native screenshots are in docs/runtime.
- Task-owned emulator was shut down after review. iOS compilation, physical-device accessibility and meaningful UI/raster performance profiling remain explicitly unverified platform limits, not implied results.
- Final handoff complete: native screenshots, screen inventory, design/motion note, demo guide, validation record and the rebuilt 0.2.0+2 ARM64 preview APK. `dist/artifact.json` records its verified identity, size and hash. Application source is frozen.
