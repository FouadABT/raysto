# Ops expressive candidate — acceptance record

Date: 7 November 2026. Direction: expressive and focused. This is a web-only candidate; financial commands, permissions and amounts remain server-owned.

## Baseline and delivery boundary

- Recorded live console: `0.17.0-dev.7-20261107`, source `e840a1d6a0b326941f56e46ab1b9f5453a8200e1`.
- Candidate source: fa5c46d537436974fcf5c98646c17bd3c9036f10, from baseline 32e19fee529471e2e23d90cfa0e381eb351e16e3, retaining the subsequent Group/Studio empty-source correction. Build ID: 1TIcqsY5ctw2_mc2P9bDw.
- The baseline audit is `motion-audit-2026-11-07.md`; prior captures and source identity remain in the existing judge-dashboard evidence.
- The backend and Android are independently versioned companions. This work does not rebuild, replace or certify them.
- Production remains on hold. No AWS, PostgreSQL, Awhar, Nginx or global SDK change is part of this implementation.

## Finding coverage

Implementation and acceptance are separate. The implementation column records what changed; validation results below determine what has actually passed.

| Audit | Implementation |
|---|---|
| F01 hero choreography | Shared spring presets; coordinated context/story reveal; confirmed-cost card entrance. |
| F02 overview skeletons | Named metric placeholders and reserved chart placeholders; explicit missing costs. |
| F03 inconsistent waits | Shared pending/activity/long-wait patterns; local refresh status; common grid activity. |
| F04 return navigation | Identity/venue/filter-scoped in-memory Today snapshots, twelve entries, two-minute expiry, immediate revalidation. |
| F05 investigation continuity | Anchored selected dish, shared stage surface and active-stage indicator; heading focus on stage navigation. |
| F06 receipt exit | Controlled closing state; parent record retained until exit completion; native focus restoration. |
| F07 drawer exit | Paired dismissal, Escape/backdrop/selection handling and breakpoint recovery. |
| F08 disclosures | Shared native disclosure/chevron CSS; animated expansion where supported, immediate native fallback. |
| F09 period refresh | Requested-period pending indicator; retained values retain their actual period label. |
| F10 premature empty state | Checking/unavailable/confirmed absence distinguished in daily close; pending close action disabled. |
| F11 reduced motion | Combined OS/app preference; bootstrap wrapper; complete CSS preference override; outgoing effects settle. |
| F12 charts | Shorter reveal; unchanged amount labels remain exact; chart data/keyboard support preserved. |
| F13 empty receipt panel | Metadata-only compact panel and contextual receipt placeholder. |
| F14 phone hierarchy | Repeated welcome removed on phones; complete primary action prioritized; financial qualifications enlarged. |
| F15 motion evidence | Added snapshot/state tests, motion/browser scenarios, recordings and production review script. |

## Validation interpretation

- Unit tests, browser fixtures and synthetic performance tasks do not establish restaurant impact or provider acceptance.
- The first browser attempt used the legacy navigation because the required public finance flag was missing. Its finance-navigation timeout is an environment configuration failure, not an accepted product result. The harness now explicitly enables the owner feature when the opt-in finance suite runs.
- Normal-motion recordings and reduced-motion captures must be identified separately. Offscreen charts must be activated before a final full-page capture.
- Production performance results must state hardware, browser, viewport and CPU throttle. Total long tasks do not automatically identify animation as their cause.
- No reviewer observations may be invented. The user confirmed that unfamiliar reviewers are not yet available. The independent-reviewer gate remains open; see `ops-motion-reviewer-tasks.md`.

## Pinned Studio corrections

The browser review exposed two independent layout-undo defects. The integration now selects a surviving page before calling the installed history API, so undoing creation of the current page does not restore an invalid selected-page identifier. A version-checked postinstall/prebuild correction in `web/tool/patch-studio.cjs` also guards AG Studio 3.0.0's eviction poll after its grid is destroyed and aborts the obsolete query. Both supported ESM/CJS entry bundles are patched; package versions and licence notices are retained. An unknown bundle or package version stops the patch rather than guessing. Revalidate this correction before upgrading Studio.

The strengthened browser regression captures console errors and uncaught page errors through undo and navigation. Passing its original visual assertion alone was insufficient evidence.

## Automated and visual validation

- Unit suite: **181 passed, zero failed**. This includes snapshot expiry/limits/isolation, permission invalidation, exact initial money rendering, formatter equivalence, Studio history and teardown checks. The build also runs TypeScript checking.
- Broad browser regression: **38 passed** across the twelve destinations, investigation tabs, responsive layouts, keyboard/focus behavior, draft protection, 2× text, navigation, loading failure and Studio. This preceded the final focused refinements; it is not represented as a complete rerun of the final source.
- Focused follow-up checks passed for receipt geometry at 320/1440px, receipt focus/exit, normal/reduced recordings, interrupted drawer dismissal, retained periods, identity/venue changes, revoked permissions and ignored late responses. The entry is usable while costing is still pending.
- **43 distinct browser cases** were exercised during implementation. Repeated executions are not additional cases. The machine record separates broad and focused runs.
- The intermediate ops-motion-accepted run has twelve passes and one timing-sensitive drawer-test failure. The corrected interruption regression captures the cancellation frame synchronously and passes. Another intermediate scope assertion matched both the workspace alert and Next's route announcer; the scoped assertion passes. These failures remain in the local evidence.
- Tested widths include 320, 390, 768, 1024, 1280 and 1440px. Actual bundled fonts/assets were used. Normal and reduced motion were recorded separately.

### Local evidence

- [Machine validation and artifact identity](ops-motion-validation.json).
- [Normal-motion recording](../../web/test-results/ops-motion-accepted/ops-motion-record-the-inve-7d3da-evidence-with-no-preference/video.webm).
- [Reduced-motion recording](../../web/test-results/ops-motion-accepted/ops-motion-record-the-inve-01c46-ry-and-evidence-with-reduce/video.webm).
- [Desktop capture](../../web/test-results/ops-motion/desktop-no-preference.png) and [320px capture](../../web/test-results/ops-motion/overview-320.png).
- Production measurements, screenshots, traces and diagnostic profiles are in .tooling/ops-motion-production/. Final build and unit logs are .tooling/ops-motion-build-final.log and .tooling/ops-motion-unit-final.log.

The authored recordings precede the last scope-hardening and immediate-entry refinement. The final production captures and measurement source are identified separately in the machine record. These files are local evidence, not public deployment artifacts.

## Remaining acceptance work

The independent-reviewer gate is **not run**: zero reviewers are confirmed. Use the prepared task sheet when two unfamiliar people become available; retain failures and assistance.

The CPU-throttled run shows stalls and remains a performance limitation. Earlier profiling identified layout projection, repeated number-format construction and test-query overhead. The candidate removes those avoidable paths and the measurement uses pre-resolved native input, but a good normal-reference result does not establish smooth behavior on every slower device. The final measured results appear below and in the machine record.

This is a tested **Windows local console candidate**. Linux deployment packaging, resource/headroom checks, live promotion, end-of-judging Studio licence coverage and the post-promotion public journey remain separate gates. No backend migration, native build or new provider acceptance run is claimed by this frontend work.

## Final production measurements

Source: fa5c46d537436974fcf5c98646c17bd3c9036f10. Build ID: 1TIcqsY5ctw2_mc2P9bDw. These measurements use the final compiled candidate, not the development server.

| Condition | Sampled transition intervals | Within 20ms | p95 interval | Observed long tasks | Observed CLS |
|---|---:|---:|---:|---:|---:|
| Reference CPU | 211 | 97.6% | 17.0ms | 0 | 0 |
| 4× CPU throttle | 42 | 59.5% | 333.4ms | 31 | 0 |

CLS uses the browser definition and excludes shifts associated with recent input. Separate receipt-geometry checks verified that its footer remains stable while data arrives.

The reference condition meets the planned 95% frame target. The throttled condition shows substantial stalls and does not establish smooth behavior on slower devices. Its smaller interval count reflects missed rendering opportunities within the same fixed windows; it must not be treated as equivalent smooth coverage.

Conditions: headless Edge 157.0.4341.42, Windows, Intel Core Ultra 7 155H, 22 logical CPUs, approximately 32 GiB RAM, 1440×1000 viewport, normal motion. The desktop was shared with other work; it was not a dedicated benchmark machine. The existing USD sample café was read through the local production console. The harness blocked connected business commands and model turns. No artificial network throttling was applied. The reference overview displayed 327 paid orders over seven days, seven chart points and two channels; the interaction investigated one dish. Total product-row count was not captured, so this is not a large-grid scale benchmark.

Three receipt-open/close and evidence/comparison cycles were measured using pre-resolved coordinates and native input. Screenshots and diagnostic traces were taken outside the measurement windows. Idle cadence was approximately 60Hz. The warm diagnostic trace includes React event/scheduler processing and major garbage collection; that suggests rendering/event and allocation work, but does not identify one responsible component or attribute every long task to animation.

A first attempt raced local server startup and received connection refused. Its zero-sample result is preserved separately. The completed run above began after an HTTP 200 readiness check. Earlier diagnostic and stress results remain available, including the slower measurements; the report does not select only favorable runs.

## Promotion gate

Promotion is a separate final step after candidate acceptance. Recheck exact source and companion versions, run the existing extraction/disk/inode preflight, retain at least 1 GiB free afterward, and preserve the previous Raysto console artifact. Stop if resources or shared-service health fail the gate. Do not restart Awhar, PostgreSQL or the Raysto backend and do not modify Nginx or payment history.

No claim of a 10/10 score is made by this record.
