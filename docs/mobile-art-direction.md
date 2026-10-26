# Raysto — a place at the table

26 October 2026 · Mobile 0.10.0 · Android application ID remains `com.gmrt.raysto`.

## Art direction

Raysto borrows the warmth of a neighborhood restaurant's printed menu: forest ink, paper, lime, a gingham edge and scalloped ceramic shapes. The existing Plus Jakarta Sans, Material controls and semantic light/dark palettes remain the foundation. Photography continues to describe actual dishes; brand illustrations are decorative and never stand in for a restaurant's uploaded photos.

The original transparent dining illustration is bundled at [assets/images/raysto-table-story.png](../assets/images/raysto-table-story.png). Six native vector scenes accompany it: a table setting, menu, takeaway bag, kitchen cloche, receipt and olive sprout. The flower-like plate mark is an accent alongside the existing Raysto wordmark, not a replacement app icon.

## Research and implementation decisions

| Source | Finding | Raysto application |
| --- | --- | --- |
| [Material 3 motion](https://m3.material.io/styles/motion) | Material distinguishes expressive spatial springs from effects such as opacity, which should not overshoot. | The existing interruptible spring dock now supports the connected app and all native role destinations. Short, bounded entrances use clamped opacity; decorative drawings settle after entry. This is a custom Flutter implementation, not a claim that Flutter ships Material's complete expressive spring scheme. |
| [Flutter animation architecture](https://docs.flutter.dev/ui/animations/overview) | Controllers, tickers and simulations can coordinate motion while allowing cancellation and disposal. | Reuse the existing motion scope and spring controller; dispose new drawing controllers and avoid repeating ambient loops. |
| [Flutter accessibility motion flag](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/disableAnimations.html) | The platform can request simplified or disabled animation. | Device preferences OR the app preference settle new art and entrance animation immediately. Controls and content remain accessible. |
| [Flutter performance guidance](https://docs.flutter.dev/perf/best-practices) | Build and paint work need deliberate boundaries and measurement on real devices. | Drawing uses CustomPainter repaint notifications, static child subtrees and repaint boundaries. The hero decodes at a bounded width. No offscreen blur or animated full-screen effects were added. Physical-device frame timing remains a separate check. |
| [Lottie introduction](https://airbnb.gitbook.io/lottie) | Lottie renders authored After Effects/Bodymovin assets. | Useful for an established motion-authoring pipeline. This pass uses original native drawings so their geometry, palette, lifecycle and reduced-motion behavior live with the app. No stock animation packs or new Lottie dependency. |
| [Rive Flutter asset lifecycle](https://rive.app/docs/runtimes/flutter/caching-a-rive-file) | Reused Rive files can be cached, and their lifecycle needs explicit disposal. | Consider Rive when Raysto needs complex, interactive character animation. The current small scenes do not need an additional rendering runtime. |

## Screens and interaction

- Connected sign-in and account creation: original dining artwork, more deliberate visual hierarchy and all existing identity/verification controls.
- Connected discovery: Raysto wordmark, illustrated introduction, service icons, a warm QR entry card, restaurant cards using real server fields and the forest/lime navigation dock.
- Menu and basket: illustrated menu heading, calmer card surfaces, wrapped dish details and prices, and a basket introduction without changing authoritative quotes.
- Activity, visits, account and restaurant workspaces: scene-specific headings and shared action cards. Team actions still depend on the original permission checks.
- Menu studio: an illustrated draft-focused introduction; human approval and existing AI limits remain unchanged.
- Empty states: contextual copy and illustrations for orders, favorites, kitchen tasks, deliveries and discovery.
- Camera: framed corners, a dimmed outside area and one introductory scan sweep, shown only while the camera is running. Camera detection, permissions and QR validation remain unchanged.
- Explicit offline demo: shared art direction across entry, discovery, assistant, restaurant heroes and empty states; illustrative data remains isolated.

## Motion and accessibility

| Moment | Behavior |
| --- | --- |
| Header entrance | 650 ms bounded fade/12 px reveal |
| Small illustration | 900 ms settling movement; no repeated idle loop |
| Dock selection | Existing retargetable spring preserves velocity during rapid changes |
| Press feedback | Existing stable hit targets, native ink and inner-only scale |
| Camera guide | One 1100 ms sweep; static corners thereafter |
| Reduced motion | Immediate settled artwork; native actions remain usable |
| Text above 1.5× | Decorative hero imagery steps back; navigation opens a roomy scrollable chooser |

No global text-scaling cap was added. New illustrations are excluded from accessibility narration. Backend responses, payment statuses, auth scopes and idempotency behavior are not replaced by visual success effects.

## Review

[Open the screen review](screenshots/story/index.html). PNGs render the actual Flutter widgets with bundled fonts, using isolated fixtures. They do not prove live restaurant availability or external provider success.

Reproduce captures with:

```powershell
.tooling/flutter/bin/flutter.bat test --no-pub tool/render_raysto_story_test.dart --update-goldens
```

Validation completed: **17 targeted tests passed**, full `lib` analysis and changed test/tool analysis reported **no issues**, and **nine screen renders** were inspected. The Android release build succeeded: **0.10.0 / code 2012**, 69,725,577 bytes, ARM64 and x64 Flutter engines, the existing development signing certificate and the original artwork confirmed in the APK. Install the Android test APK (local artifact; not distributed). Full metadata and check logs are recorded in the release evidence (local artifact; not distributed).

Phone review: open sign-in, discovery, a menu and activity; change dock destinations quickly; then enable reduced motion and larger text in settings. Check the QR frame with the camera permission allowed and denied. The changes are visual: provider prerequisites and live account/payment behavior remain as documented for the connected release.

Native camera operation, TalkBack/VoiceOver, iOS behavior and physical-device frame timing need device acceptance; widget renders are not a substitute.

## Original artwork provenance

Generated with the built-in imagegen tool, followed by a transparent-background cleanup edit. No CLI model/API fallback was used. The final project asset is the PNG linked above; its alpha channel is retained. Native vector scenes are authored in [raysto_art.dart](../lib/design_system/raysto_art.dart).

Initial prompt:

> Use case: illustration-story. Asset type: original transparent hero illustration for Raysto, a warm contemporary restaurant mobile app. Make one beautiful editorial cut-paper and risograph illustration of a relaxed bistro table seen obliquely from above: an oversized off-white scalloped ceramic plate with a very simple leafy garden dish, sculptural dark forest-green fork and spoon, a small glass with lime liquid, one loosely folded gingham napkin, and a tiny olive sprig. Everything is playfully asymmetrical, with bold imperfect silhouettes, fine dry-ink grain inside shapes, delicate hand-drawn contours and just a few gestural dots. Sophisticated independent food magazine / printed restaurant menu sensibility, contemporary flat 2D art; NO generic 3D, NO characters/faces, NO UI mockup, NO text or lettering, NO gradients or drop shadows. Palette tightly restricted to forest #173F35, lime #D7F978, paper #F6F7F2, warm peach #F3E8DB, muted olive. Composition: landscape 3:2 vignette, compact interlocking objects, full objects visible with generous transparent margin, suitable for display at 340x180 logical pixels. Transparent background with real alpha, no backdrop, no white rectangle. Do not add a logo, watermarks or extra colors.

Final edit prompt:

> Precise edit of this Raysto illustration: preserve the exact plate, salad, fork, napkin, glass, spoon and olive sprig, their colors, grain, layout and silhouettes. Remove ALL of the soft blurry shadows, glows and colored haze outside the objects. Outside the crisp cut-paper object silhouettes must be completely empty alpha transparency. No cast shadows, no dark backdrop, no gradient, no vignette. Keep texture INSIDE the shapes. No other changes.
