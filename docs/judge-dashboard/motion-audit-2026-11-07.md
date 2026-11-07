# Raysto Ops — motion, loading and interaction audit

Audit date: 7 November 2026. Scope: the connected web owner workspace at https://ops.rays.to/ops, with emphasis on first impressions, motion, loading and the judge investigation journey.

This is an audit and proposed direction. No application code, deployment, server service, database, provider record or financial action was changed for this audit.

## 1. Assessment

The user's criticism is substantially justified. Raysto has a reusable motion foundation, but the most prominent parts of the current dashboard do not consistently use it. The result feels like a set of screens assembled with different interaction rules, rather than one deliberately choreographed application.

The problem is broader than adding pop-in effects. The highest-value improvements are consistent pending states, continuity between investigation stages, reliable entrances AND exits, and feedback that explains what changed. Decorative movement alone will leave the main usability issues unresolved.

The current paper/forest/lime identity and focused café story are useful foundations. They do not need another palette replacement. The dashboard needs a coherent interaction layer and a clearer distinction between initial loading, background refreshing, empty results, errors and successful execution.

### Provisional design assessment

These are this auditor's qualitative ratings, not hackathon criteria or measured user outcomes. They assess the reviewed live interfaces and corresponding source. Normal-motion playback quality was not freshly measured in this browser session.

| Area | Assessment | Main reason |
|---|---|---|
| Visual identity | 7/10 | Distinctive restaurant tone, restrained colors and display typography; some supporting copy is too small. |
| First-view hierarchy | 7/10 desktop; 6/10 narrow phone | A clear investigation action exists; repeated introductory content consumes substantial phone space. |
| Motion coverage and consistency | 4/10 | Shared primitives exist, but major hero, stage and disclosure interactions bypass them. |
| Loading and refresh experience | 4/10 | Static placeholders, text-only waits, different patterns across sections and repeated initial loading on return. |
| State-change continuity | 5/10 | Main navigation has transitions; nested stages, disclosures and some closing paths do not. |
| Accessibility foundation | 7/10, provisional | OS preference, app switch, native dialogs and outgoing-view isolation exist; CSS preference coverage and assistive-technology review remain incomplete. |
| Runtime smoothness | Not rated | No new frame trace, CPU-throttled run or physical-device measurement was made. |

Overall, the reviewed experience is approximately **6/10 for interface polish**, with motion and loading the clearest weaknesses. This is not a claim about the backend's quality or the full hackathon score.

## 2. Evidence and boundaries

### Release identity

The recorded deployed console is `0.17.0-dev.7-20261107`, source `e840a1d6a0b326941f56e46ab1b9f5453a8200e1`. The deployment record is `docs/judge-dashboard/console-deployment.json`. No SSH session or server inspection was performed for this audit; this identity comes from the retained deployment evidence and the live UI agrees with its design.

Newer local console work is not evidence that a change is live. In particular, the later Group/Studio empty-schema corrections are not part of this deployed console. A source comparison against the deployed commit showed the principal motion, overview, finance and shell files discussed here have not changed between that commit and the current local HEAD.

### Work performed

- Visited the live judge café, initial connection, Today overview, cost evidence, receipt loading and loaded receipt, comparison controls, a price-limit disclosure, analytical workspace, Bills and stock, Team and Money.
- Inspected the period-switch pending state and detailed-report entry.
- Reviewed the phone navigation drawer and Today at 390px and 320px. Restored the viewport afterward.
- Inspected the shared motion provider, navigation transitions, reveals, chart animation, count-up, dialog, snackbar, loading helper, CSS and relevant browser-test definitions.
- Compared these with current primary guidance from Google Material, Android Developers, Motion, web.dev, W3C and Apple.

The live browser reported `prefers-reduced-motion: reduce = true`; the Raysto Reduce motion switch was off. Raysto correctly combines these preferences with OR, so turning the app switch off does not override the device. Static live playback under this condition is expected. Findings about normal-mode entrances and exits below are source-verified unless explicitly described as a live observation.

No app/OS motion preference was changed. No new scenario, AI conversation, menu publication, supplier payment, customer collection or other business mutation was performed. There were no captured warning/error console entries in the inspected session, but this is not a full console or all-route regression result.

The 320px and 390px Today checks did not show horizontal document overflow. These are browser viewport checks, not physical-phone acceptance. New 2x text, screen-reader, low-end-device and unrestricted-motion playback reviews remain outstanding. Financial correctness, security and provider acceptance are outside this audit's scope.

## 3. Findings

Priority meanings: **P1** significantly affects the central first impression, interpretation or task flow; **P2** affects consistency, refinement or a secondary interaction. No critical financial defect is established by this visual audit.

### F01 — P1: The main hero has visual styling without motion choreography

The welcome, investigation story, three journey steps and cost illustration are ordinary elements in `judge-home.tsx`. The receipt card's slight rotation is a static CSS transform, not animation. KPI cards use `Reveal`, while the focal investigation area does not.

Consequently, the least important supporting tiles receive an entrance treatment while the main product story has none. Even with normal motion enabled, the first section does not establish a recognizable Raysto interaction style.

Direction: introduce a short, coordinated first-entry sequence: heading/context, investigation surface, evidence card, then supporting metrics. Keep the primary action usable immediately. Avoid a typewriter effect on essential instructions or a long cascade through every card.

Evidence: `web/src/components/connected/judge-home.tsx` around lines 116–207 and 292–307; `web/src/app/ops/judge-dashboard.css` around lines 156–164.

### F02 — P1: The new overview bypasses the existing skeleton treatment

Initial overview metrics are static cards containing “Loading…” and a dash (`jr-metric jr-pending`). There is no dedicated animated `jr-pending` treatment in the reviewed CSS. The older console has an animated skeleton, but the new overview does not reuse it. The cost illustration initially shows a different placeholder, and chart sections mount only after dashboard data arrives.

This creates a mixture of empty-looking cards, a placeholder illustration, changing copy and newly inserted sections. It can feel unfinished even when the request is progressing normally.

Direction: use geometry-matched placeholders for the actual overview. Reserve expected chart and card space. Add a restrained activity treatment under normal motion; show clear stable pending content under reduced motion. Never display fabricated zero amounts or fake completion percentages.

Evidence: `judge-home.tsx` around lines 164–207 and 260–269; `operations.css` around lines 1191–1229.

### F03 — P1: Loading is implemented as several unrelated experiences

Initial connection and finance costing use a spinner with text. Receipt, decisions, analytical-workspace import and detailed-report import use text-only waits. Stock and Team use unknown-value dashes and grid/text loading. A global read-status sentence can appear in addition to local status.

These states communicate some useful information, but differ in placement, geometry and visual activity. The app lacks a shared policy for brief waits, initial loads, background refreshes, unavailable data and long-running tasks.

Direction: define a small shared set of loading patterns, each with contextual language and appropriate status semantics. Keep feedback local when one panel is updating. Use a single top-level status only when the whole context is affected. Add longer-wait recovery language based on actual request/task state.

Evidence: `operations-entry.tsx` lines 197–201; `finance-section.tsx` lines 31, 410–417, 1303 and 1480; `judge-home.tsx` lines 18–20; `read-progress.tsx` lines 19–29; `raysto-grid.tsx` around line 320.

### F04 — P1: Returning to Today repeats a first-load experience

After visiting other owner sections, returning to Today visibly showed the generic dish heading, “Finding a dish…” text, disabled investigation actions and loading metric cards again. The previous page data did not remain visible across this section unmount/remount. The local `useLoad` state starts without data on a fresh mount.

This is different from period refresh, which correctly retains the previous dashboard result with an explicit notice. The inconsistency makes routine navigation feel slower.

Direction: consider a bounded, identity/tenant/filter-scoped read cache or deliberate snapshot retention for safe analytical reads. Revalidate it visibly. Clear it on logout, role or tenant change. Preserve evidence/version checks before any business action. Do not retain one restaurant's data in another restaurant's view.

Evidence: live return-to-Today state; `business-sections.tsx` around lines 177–222; `judge-home.tsx` loading branches.

### F05 — P1: Investigation stages do not share the main navigation transition

`FadeThrough` is keyed by the main `section`. Changing Cost evidence → Compare options → Analytical workspace changes the finance `view`, so it stays inside the same outer transition key. These panels use conditional rendering without a shared stage transition. Price-option cards have a small CSS entry effect, but it does not provide continuity for the overall investigation.

Direction: keep the selected dish/context anchored and transition the changing stage body. Make the active stage change legible, preserve a sensible scroll/focus destination, and cancel or retarget transitions during rapid input. Avoid scaling ancestors of AG Grid or the Studio canvas.

Evidence: `operations-workspace.tsx` around lines 986–990; `finance-section.tsx` around lines 369–390, 829, 1093 and 1110; `design-workspace.css` lines 513–537.

### F06 — P1: Receipt close bypasses its exit animation

`ContainerDialog` supports an exit when `open` becomes false. However, the finance parent conditionally mounts `ReceiptEvidence` only while `receipt` exists, passes `open` as an unconditional true value, and closes by clearing `receipt`. This removes the component directly; its internal exit sequence has no opportunity to finish.

Focus restoration on direct unmount is deliberately handled and should be preserved. The defect concerns visual continuity, not a claim that focus restoration is absent.

Direction: keep the wrapper mounted through a controlled closing phase, then clear the receipt after completion. Closing must retain the current draft checks and native modal behavior. Reduced motion should close directly.

Evidence: `finance-section.tsx` lines 1166–1174 and 1377–1382; `m3/container-dialog.tsx` exit/finish logic.

### F07 — P2: The phone drawer has an entry animation and an immediate close

Normal-mode CSS defines a 400ms drawer entrance. Close-button, backdrop and navigation handlers call native `dialog.close()` directly; there is no corresponding exit lifecycle in this path.

Direction: give dismissing and selecting a destination a matching, shorter closing treatment, while keeping immediate keyboard/draft behavior and returning focus appropriately. Test rapid open/close and resizing through the 600px breakpoint.

Evidence: `m3-shell.css` lines 112–140; `operations-entry.tsx` lines 506–530 and the close-button handler.

### F08 — P2: Disclosure expansion snaps and moves surrounding content

Price limits, saved comparisons, calculations, payment proof and secondary navigation use native disclosures. The inspected price-limits disclosure opens correctly, but the reviewed source does not provide an expansion/collapse motion system for these components.

Direction: retain accessible summary controls, add a small controlled reveal and chevron state change where useful, and ensure rapid reversal works. Keep open content available to focus/assistive technology; closed content must be unavailable. Do not animate every table row underneath.

Evidence: `price-comparison.tsx`; the `.jr-price-settings`, `.jr-assumptions`, `.jr-option-calculation` and `.jr-payment-proof` rules in `judge-dashboard.css`.

### F09 — P2: Period selection changes before the replacement result arrives

The clicked period becomes selected immediately, while the previous period's title and values remain visible. This is honestly explained by “Updating figures. The previous loaded period remains visible,” plus a global status sentence. It is safer than relabeling old values as new ones, but the duplicated notices and split selected/displayed state require careful reading.

Direction: retain the truthful old-period label, distinguish “requested period” from “displayed period” while pending, place one concise update indicator beside the affected figures and update related widgets together. Do not count across unrelated periods as though a real business change occurred.

Evidence: live 7-day/30-day switches; `judge-home.tsx` period and loading branches.

### F10 — P2: Some empty-state language is displayed before data is known

Money's daily-close hero renders “Not closed yet” whenever `data?.close` is absent. That includes the initial unresolved request and failure without prior data, as well as a confirmed absence. The live initial Money state displayed this heading while its grid was still loading.

Direction: separate checking, confirmed absence, loaded close and unavailable states. Initial loading should not look like a verified business conclusion. The same distinction should be reviewed across action inboxes and summary cards.

Evidence: `backoffice-sections.tsx` around lines 489–535. This is a state-representation finding; no close operation was run.

### F11 — P2: Reduced-motion support is strong in principle but incomplete across CSS

`useReduce` correctly respects OS OR app preference. `FadeThrough`, `Reveal`, chart and count-up components render final states. OS reduced-motion CSS broadly disables animation. However, the app-specific data-attribute rules cover selected patterns rather than all CSS effects. The base spinner, old skeleton shimmer and live pulse do not have equivalent app-switch rules in the reviewed stylesheets. Initial connection is also outside the signed-in motion root.

Direction: audit the app switch across both React and CSS motion, including bootstrap. Provide one reliable CSS preference contract. Maintain understandable progress text when an activity indicator is still. Do not force motion on to make a judge demo look animated.

Evidence: `lib/connected/motion.ts`; `operations.css` lines 466, 1206–1245; app-specific overrides in `m3-shell.css`, `design-workspace.css`, `action-inbox.css` and `upload-drop.css`.

### F12 — P2: Chart animation exists, but coverage and update semantics differ

Sparklines and the area chart reveal on entering the viewport; donut segments also animate. These are genuine implementations. Main overview amounts, however, are ordinary text rather than the existing `CountUp`. Returning to sections can skip reveals intentionally, so repeated exploration feels quieter than first entry.

Do not interpret a chart outside the viewport that has not yet drawn as missing data. Earlier full-page screenshot evidence can capture that intermediate state; static screenshots cannot establish animation quality.

Direction: keep authoritative values immediately readable. Use subtle emphasis or a crossfade to communicate a refresh; reserve animated number interpolation for appropriate comparable values. Stabilize chart geometry and avoid redrawing unchanged data on every live event. Test data arrival and viewport entry independently.

Evidence: `m3/charts.tsx`, `m3/count-up.tsx`, `m3/reveal.tsx`; `judge-home.tsx` lines 292–305.

### F13 — P2: The evidence panel is oversized for the available record

At desktop width the receipt opens as an almost full-height right-side panel. The reviewed sample receipt loads a few text lines and explicitly has no attached source document. Most of the panel remains blank. While pending, it is a large empty white surface with “Loading receipt…”.

Direction: use a readable receipt-shaped skeleton, compact metadata and a deliberate document/limitation area. Consider a content-aware panel for metadata-only records. Preserve the honest missing-document statement; animation must not imply a source document exists.

Evidence: live receipt view; `design-workspace.css` lines 645–648; `finance-section.tsx` receipt renderer.

### F14 — P2: Small copy and repeated introductions weaken the first phone view

The narrow phone view spends much of its first screen on the app bar, welcome heading, explanatory paragraph and a second large story heading. At 320 × 740 the primary investigation control reaches the lower viewport edge and continues below it. Supporting labels/disclaimers in the overview use several 9–11px sizes.

Direction: tighten repeated introductory content on phones, keep the problem/dish/action together and make essential provenance and financial qualifications comfortably readable. This is not a finding that every small label fails WCAG contrast or text-size requirements; no complete contrast/text-scaling audit was performed.

Evidence: live 320px/390px first views; type rules in `judge-dashboard.css`.

### F15 — P2: Existing checks prove behavior more than perceived motion quality

The repository contains useful tests for reduced motion, outgoing-view inertness, rapid navigation, focus and reflow. Existing validation records also describe passing checks. The new overview screenshot cases explicitly use reduced motion. These cannot prove that the normal-mode hero is expressive, that every close path animates, or that frames remain smooth on a modest device.

Direction: add a small explicit motion acceptance matrix covering first, mid-transition, final and interrupted states. Use short recordings and frame/performance traces for the candidate. Do not replace behavioral tests with screenshot-only tests or claim 60fps from a static image.

Evidence: `tests/browser/judge-dashboard.spec.ts` around lines 110–150; `tests/browser/design-workspace.spec.ts` around lines 334–396; `docs/judge-dashboard/validation.json`. These existing suites were inspected, not rerun for this documentation-only audit.

## 4. What already works and should remain

- Five primary owner destinations and a prominent investigation action reduce initial navigation burden.
- Distinctive paper, forest, lime and restaurant typography offer a recognizable foundation.
- The server's amounts remain authoritative; the overview uses exact displayed values.
- Unknown initial financial figures are generally shown as dashes rather than fabricated zeros.
- Period refresh retains previous data and explicitly says it is previous data.
- Main-section navigation already has a 90ms exit plus 210ms entry; first-load suppression is deliberate.
- Outgoing main-section content is inert, hidden from accessibility navigation and pointer-disabled.
- The navigation indicator, chart reveal, count-up and snackbar primitives already exist.
- Native dialogs, focus restoration and draft guards are valuable and should survive any motion work.
- Device reduced motion is respected even when the app switch is off.
- Chart data has accessible textual/table support, and sample/financial qualifications are visible.

## 5. Current online guidance and its relevance

### Google Material 3 Expressive

Current Material guidance describes physics-based expressive and standard motion schemes. Spatial motion covers position, size and shape; effects cover opacity and color without overshoot. It distinguishes fast/default/slow treatments. For Raysto, expressive movement suits the investigation entry and evidence transitions; recurring financial reading should stay restrained. These principles need translation to the installed web animation library, not direct adoption of Android APIs. Existing cubic-bezier transitions are not automatically wrong, but they do not alone establish a current expressive motion system. Sources: [Material motion](https://m3.material.io/styles/motion), [how it works](https://m3.material.io/styles/motion/overview/how-it-works), [official MotionScheme reference](https://developer.android.com/reference/kotlin/androidx/compose/material3/MotionScheme).

### Loading and progress

Loading should preserve context, show useful content early and accurately communicate continued work. Unknown progress needs an indeterminate treatment; measured progress may use a determinate one. This supports contextual skeletons and activity indicators, not artificial percentage counters or a mandatory animated intro before every page. Sources: [Apple loading guidance](https://developer.apple.com/design/human-interface-guidelines/loading), [progress indicators](https://developer.apple.com/design/human-interface-guidelines/progress-indicators).

### Web implementation

The project already installs Motion 14.6.0. Its existing exit and layout facilities are sufficient for the proposed direction; another animation framework is unnecessary for these findings. Closing requires a component lifecycle that actually permits an exit. Shared layout transitions should be used selectively and protected from grid-measurement conflicts. Sources: [Motion exit animations](https://motion.dev/docs/react-animate-presence), [layout animation](https://motion.dev/docs/react-layout-animations).

### Accessibility and performance

Respect motion preferences while preserving meaning. WCAG 2.3.3 addresses disabling nonessential interaction animation at AAA; it should not be mislabeled as an AA requirement. WCAG 4.1.3 covers programmatically identifiable status messages at AA. Animation is not a substitute for status semantics. Sources: [W3C interaction animation](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html), [W3C status messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html), [Motion accessibility](https://motion.dev/docs/react-accessibility).

Prefer transform/opacity for common movement and fades, inspect exceptions, and measure dropped frames rather than assuming smoothness. Avoid promoting every card with permanent `will-change`. Source: [web.dev animation performance](https://web.dev/articles/animations-guide).

The Material site relies on JavaScript; some directly opened pages returned only a JavaScript shell. The search index exposed the official motion guidance, corroborated by Google's API documentation. No recommendation here relies on a third-party template roundup or competitor marketing claim.

## 6. Recommended interaction direction

Proposed direction: **a responsive café decision workspace with expressive focal interactions and calm financial data**. The following timing ranges are starting design targets, not quoted Material requirements or measured results.

| Interaction | Proposed normal-motion behavior | Reduced-motion behavior |
|---|---|---|
| First useful entry | Short 300–450ms hierarchy reveal; small translation; primary action never waits for the sequence | Final layout immediately |
| Primary button | Immediate state-layer/press feedback, roughly 80–140ms; stable hit area | Color/state feedback without displacement |
| Main destination | Refine existing fade-through, preserve focus and interrupted navigation | Immediate replacement |
| Investigation stage | Anchored dish context; 180–260ms body transition and active-stage feedback | Immediate stage change and focus update |
| Disclosure | 160–220ms content/chevron transition with rapid reversal | Immediate expansion/collapse |
| Receipt or menu | Spatial entrance with paired, slightly shorter exit | Immediate open/close with native focus behavior |
| Initial data | Geometry-matched placeholders, restrained activity while genuinely pending | Still placeholders with explicit pending state |
| Background refresh | Keep records, one local activity cue, brief settled-state emphasis | Keep records and announce completion appropriately |
| Chart entry | Brief one-time reveal; exact labels readable independently | Complete chart immediately |
| Scenario result | Grouped transition from pending to calculated options; clarify revision | Complete result and revision/status text |
| AI work | Actual task stages, cancellation and recovery; no invented progress | Same task information without decorative movement |
| Payment state | Pending/completed/failed/unresolved tied to recorded provider state | Same factual states, no celebratory motion needed |

No looping float/parallax on financial cards, scroll hijacking, per-cell entrance cascade, endlessly pulsing money values or visual success before a provider outcome. Motion should show relationships and state, not delay reading or suggest that an unapproved action happened.

## 7. Priority order and acceptance

### First: loading and truthfulness

Unify initial/refresh/empty/error patterns, repair pre-load daily-close language, reserve geometry and review app-switch CSS coverage. Confirm no stale period is mislabeled and no missing amount appears as zero. This is the largest usability gain.

### Second: the core investigation

Add focal entry choreography, retain selected-dish context across stages, pair receipt entrance/exit and preserve drafts/focus during interruption. Tighten the phone's repeated introduction. This is the strongest visible improvement for a judge following the café story.

### Third: interaction consistency

Unify disclosure, drawer, button, notification and chart-update behavior. Reuse the existing library and primitives. Avoid styling unrelated secondary operations independently.

### Fourth: prove the candidate

Before calling the result polished, review:

1. Normal motion, OS reduced motion and app reduced motion independently, including first connection.
2. Cold entry, returning to a section, fast data, controlled delayed data, failure and recovery.
3. Receipt/drawer open, close, Escape, backdrop, rapid reversal and breakpoint change.
4. Evidence → comparison → Studio → outcomes, including stale results and changed scope.
5. 320px, 390px, tablet and desktop; 2x text and keyboard navigation.
6. No outgoing view accepts input or appears in accessibility navigation.
7. Exact financial amounts and execution permissions remain unchanged by presentation operations.
8. Performance recordings under stated device/network/dataset conditions; investigate animation-triggered long tasks, layout shifts and dropped frames.
9. A short first-time-reviewer session to verify that animation improves understanding rather than merely attracting attention.

Existing all-route scans remain useful supporting evidence, but are not a replacement for this motion-specific acceptance. The retained dev7 scan also contains a Group Studio `pnl` empty-source error. It is a separately known deployed-release issue, not newly reproduced in this audit and not resolved merely by adding motion.

## 8. Decision

Do not describe the current dashboard as having no animation at all: meaningful primitives are present. Equally, do not describe it as a complete expressive interface because those primitives exist. The central user journey currently has inconsistent motion coverage and weak pending-state design.

The next design iteration should prioritize loading clarity, anchored stage transitions and complete open/close lifecycles, then add a restrained Raysto signature to the hero and evidence flow. A higher polish score needs direct normal-motion playback, performance and first-time-user evidence. It cannot be guaranteed by implementing a list of effects.
