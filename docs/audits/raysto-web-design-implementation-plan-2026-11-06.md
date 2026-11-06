# Raysto web design and experience implementation plan

Prepared 6 November 2026 from the [21-finding web audit](raysto-web-design-audit-2026-11-06.md). Status: proposed implementation sequence; tasks and targets below are not completed acceptance results.

The objective is a distinctive, coherent restaurant-management experience in which an unfamiliar owner can investigate a cost change, understand the evidence, compare options, review a decision and return to its outcome. The same design quality must extend through the rest of the web product.

Ten out of ten is the design target. A judging score cannot be guaranteed. Readiness will be determined by the observable gates below, followed by independent review. Presentation production and the separate owner-impact research remain separate workstreams.

## Scope and engineering boundaries

Cover the public landing, connected entry, Today, Sales and margins, Bills and stock, Team, Money, Orders, Payments, Agents, Accountant, Dispatch, Group and Floor. Cover their supported tabs, detail views, forms, approvals, empty states, failures and narrow-screen equivalents. Include the installed AG Grid and AG Studio experience as part of the product.

Retain the approved paper, forest, lime, mint and peach palette; Jakarta functional typography; Fraunces display typography; Material icons selected for the current product; native controls where appropriate; existing Motion integration; and server authority for financial calculations and permissions. The older local guest demo remains explicit and separate. Inventory any affected shared styles and check those routes for regressions without turning this into a new guest-product redesign.

Reuse the current Next.js, authenticated API, Serverpod and PostgreSQL architecture. Preserve existing comparison revisions, scenario callers, order snapshots, payment idempotency and manual approval. A UI change must not introduce a new financial policy or accounting cutover. Necessary contract additions require backend validation and compatibility checks before either client depends on them.

No Flutter web target, global SDK upgrades or replacement animation framework is needed. Deploy only through Raysto's existing services. Preserve Awhar, its database, SDKs and Nginx configuration. Physical Android acceptance remains deferred as requested; responsive browser checks do not close it.

## Definition of excellent design

Use this internal review rubric consistently. Each area targets 10/10; the statements define what must be demonstrated rather than promising the resulting rating.

| Area | Observable finish standard |
| --- | --- |
| Visual identity | Every task family carries the same typography, palette, surfaces, icon language and attention to detail while having an appropriate composition. |
| Information architecture | Owners can predict where work belongs; routes, Back, Forward and refresh preserve useful context. |
| Decision workflow | One understandable comparison journey, explicit assumptions, traceable evidence and a clear next action. |
| Motion | Movement explains selection, evidence, change and outcome; it remains interruptible and optional. |
| Responsive design | Equivalent business actions at 320px through wide desktop, with readable navigation and usable keyboards. |
| Accessibility | Keyboard, focus, announcements, contrast, text enlargement and reduced motion work through complete tasks. |
| Data communication | Loading, empty, unknown, incomplete, stale, estimated and failed states are distinct and understandable. |
| Studio integration | Useful analytical content appears before editor complexity; configuration preserves selection, scope and authority. |
| Performance | Interaction remains responsive under recorded representative workloads, including refresh, charts and animation. |
| Product consistency | Every supported section and material state passes the shared component and interaction contracts. |

No average can hide a critical failure. An inaccessible approval, lost draft, incorrect amount, unauthorized record, duplicate execution or misleading payment status blocks promotion regardless of the visual score.

## Phase 0 Establish the implementation baseline

Purpose: make every design result reproducible and preserve work already in progress.

1. Inventory the current branch, component source commits, public deployment, candidate artifacts, feature switches and uncommitted files. Preserve unrelated documentation and video drafts.
2. Create the implementation branch from the intended integrated source. Record the starting point in the release evidence; do not reset the workspace or stage unrelated changes.
3. Make a route-and-state inventory listing each supported role, destination, tab, detail, mutation, loading state, empty state and recoverable error. Identify features that are unavailable to the public manager and verify them through an appropriately authorized private account.
4. Capture baseline views at 1440 × 900, 1280 × 800, 1024 × 768, 768 × 1024, 390 × 844 and 320 × 800. Include landscape and expanded text for the main decision path.
5. Record selected venue, period, currency, provenance and dataset size beside each capture. Exclude credentials and private contact data from artifacts.
6. Retain the previous test results, but rerun the relevant baseline checks when the checkout or environment differs from those records. Keep environment failures distinct from application failures.
7. Reproduce D08 and D09: the stock grid with empty analytical widgets, and Group entry under the default group selection. Record requests, resolved scope and visible state before deciding the cause.
8. Create one issue per audit finding, linked to its implementation phase and acceptance evidence. Add newly discovered defects without silently replacing the original audit.

Deliverables: baseline captures, state inventory, issue register, source/version record and reproducible failure cases.

Exit: every destination has an owner task and a defined verification path; existing work remains preserved.

## Phase 1 Resolve the interaction and composition before styling

Purpose: establish the product structure that visual design and motion will express.

1. Specify the first useful action for Today, a pricing investigation, a bill, a staff shift and a payment problem. Keep secondary reporting subordinate to those tasks.
2. Draw the investigation states: choose dish, confirm missing evidence, inspect cost change, compare, review, decision recorded, execution pending, outcome available. Include keep, reject and defer branches.
3. Produce realistic desktop and phone compositions using the actual USD example and an incomplete dish. Use real labels, long product names, unknown costs, stale comparisons and failed provider states.
4. Define a persistent context area for dish, current price, costing readiness and evidence status. Place business-wide accounting reports in a dedicated report destination reachable from the investigation.
5. Define the difference between record-reading, comparison editing, analytical layout editing and business approval. Each must have a visibly distinct mode and exit path.
6. Specify direct access to Bills within Bills and stock. Retain useful Accountant report links and existing URLs through aliases rather than breaking saved links.
7. Review designs against all 21 findings before coding. Resolve duplicated controls, hidden next steps and crowded mobile layouts in these compositions.
8. Establish a small component review route isolated from real business mutations. Use explicit illustrative fixtures for all states.

Deliverables: reviewed screen compositions, state diagrams, navigation map and component-state catalogue.

Exit: the complete investigation is understandable without a verbal explanation, and its phone version provides the same business decisions.

## Phase 2 Consolidate the visual system and reusable controls

Purpose: make Raysto recognizable across the entire product.

1. Inventory `tokens.css`, `md-sys.css`, operations styles, later overrides and component styles. Identify duplicated or conflicting roles before introducing more CSS.
2. Define explicit roles for page background, white content surface, quiet supporting surface, selected surface, raised overlay, danger, warning and success. Fix financial panels that currently disappear into the page.
3. Repair the undefined Fraunces custom property and create one shared definition for display, section, body, label and numeric typography. Load the actual installed fonts and verify computed styles in the browser.
4. Use Fraunces selectively for page orientation and brief editorial headings. Use Jakarta for controls, evidence, forms and dense tables. Use tabular numerals and consistent currency alignment.
5. Consolidate spacing, content widths, border strengths, radii and elevation. Remove wrappers that add padding without meaningful grouping. Establish comfortable and compact density where both are useful.
6. Standardize primary, secondary, quiet, destructive and icon-only actions. Include hover, pressed, focus, pending, disabled and failure states; essential controls retain at least 48 × 48px targets under the project requirement.
7. Standardize fields, labels, help text, validation, segmented controls, search, filters, badges, tables, dialogs, drawers, notifications and empty states.
8. Give icon-only controls accessible names and discoverable descriptions. Keep status understandable through text and shape as well as color.
9. Give tables consistent row rhythm, readable metadata, controlled truncation, explicit totals and a clear way to inspect full values. Do not hide approval information in truncated cells.
10. Review contrast in actual combinations, including error surfaces, chart labels, focus and selected states. Use 4.5:1 for ordinary text and 3:1 for qualifying large text as the text-contrast criteria; evaluate other components separately. [W3C contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)

Deliverables: documented tokens and component examples using the installed design stack.

Exit: representative Today, pricing, receipt, team and payment compositions use the same system without page-specific visual patches.

## Phase 3 Repair navigation and preserve working context

Purpose: make moving through the product predictable.

1. Keep five primary owner destinations: Today, Sales and margins, Bills and stock, Team and Money. Give operational destinations a deliberate, accessible secondary treatment.
2. Make section, supported tab and selected record part of the route. Retain existing query links and judge entry. Do not include credentials, document contents or unsaved financial assumptions in URLs.
3. Validate route scope against the authenticated venue and role. Recover from missing, deleted or unauthorized records with a useful local state.
4. Implement Back, Forward, refresh and direct-link restoration. Prevent routing from remounting the whole identity/session layer.
5. Retain useful list filters, sort, selection and scroll on return. Clear identity- and tenant-specific state on scope changes.
6. Replace the clipped 80px rail treatment. Use reviewed short visible labels with full accessible names, wrapping or a wider rail as appropriate. Tooltips supplement labels rather than carrying essential navigation alone.
7. Keep the phone drawer keyboard accessible, with focus containment, Escape, a clear close action and focus restoration. Closing navigation must not discard a working draft.
8. Consolidate draft guards into branded dialogs with Keep editing, Discard and Save where saving is supported. Preserve checks on section changes, record changes, receipt close, modal dismissal and browser navigation.
9. Retain edits across in-app navigation through scoped state. Use existing server draft mechanisms for durable drafts where supported. If a field is not saved, clearly identify that state and protect reload; do not promise durable recovery without an implemented storage path.

Exit: a reviewer opens a dish directly, edits an assumption, navigates away, returns, refreshes and changes venue without losing confirmed work or leaking prior context.

## Phase 4 Repair loading and analytical failure states

Purpose: make all displayed information trustworthy at every stage of loading.

1. Introduce explicit states for initial loading, refreshing with previous data, loaded-empty, loaded-incomplete, unavailable, permission denied and failed-with-retry.
2. Replace initial zero totals and “0 of 0” with placeholders or pending labels until a valid result exists. Keep real zero distinguishable from unknown.
3. Preserve previous records during refresh with a freshness indicator. Recheck versions before actions; retained display data does not authorize stale execution.
4. Repair the stock analytical state from the reproduced failure. Check source fields, mapping, asynchronous updates and supported dataset coverage before changing widget configuration.
5. Resolve an authorized group before querying its data. Distinguish all-groups selection, no group membership and an unavailable selected group. Show a chooser or retry before mounting an editor without useful context.
6. Centralize venue, currency, timezone, period, accounting basis and sample provenance in a visible context treatment. Keep measure-specific definitions where they differ.
7. Replace raw parameter errors with concise owner-facing messages and a concrete recovery action. Retain diagnostic references in a secondary technical detail area.
8. Place errors beside the affected work. A chart failure must not hide a usable bill list; an unavailable model must leave structured controls operational.
9. Announce status updates accessibly without announcing every polling response or repeated chart redraw.

Exit: delayed and failed responses never appear as valid zero results, and every supported failure has a recovery path.

## Phase 5 Build one focused pricing investigation

Purpose: make the strongest product journey shorter and easier to understand.

1. Consolidate the two scenario interfaces into one user-facing comparison workflow. Keep existing backend scenario callers and immutable history compatible.
2. Replace the long native product selector with searchable dishes, readiness filters, useful identifiers and sensible disambiguation for repeated names.
3. Preserve the selected dish on refresh and return. Offer complete sample and incomplete-data paths explicitly in the judge venue, without hiding incomplete products from actual owners.
4. Make Investigate enter the relevant workspace, place its heading and first useful control in view, and move focus appropriately. Expose expanded state if the interaction remains a disclosure.
5. Show current price, confirmed cost, contribution and costing readiness in a compact contextual header. Show missing components beside their corrective actions.
6. Show one set of assumptions: baseline volume, assumed volume response, case-specific cap and optional owner price. Explain inherited owner policy and analysis-only candidates.
7. Compare Keep price, Lowest qualifying price, Owner-entered price and Defer through a consistent structure. Align price, unit contribution, target, limits and break-even results for scanning.
8. Show unchanged, minus 10%, minus 20% and entered-volume scenarios through the same server results. Provide accessible tabular values alongside visual comparison.
9. Make source inspection and “what changed in this revision” reachable without repeating their full text under every option.
10. Preserve revision identifiers, expiry, policy, fee assumptions and cost completeness. An expired comparison stays readable and clearly requires recalculation before execution.
11. Retain keep, reject and defer decisions with reviewed language for reasons. Make the next action depend on the chosen outcome rather than showing every action at equal weight.
12. Provide an obvious route to decision history and recorded outcomes. Keep financial reports reachable without placing the whole business summary before the dish task.

Exit: an unfamiliar reviewer can select a complete dish and begin comparing without passing unrelated accounting sections; an incomplete dish clearly explains the required correction.

## Phase 6 Unify evidence review and business approval

Purpose: preserve context and make consequential actions understandable.

1. Create one evidence presentation pattern for receipt, recipe, supplier bill, order and provider outcome. Show source, relevant values, date, provenance and completeness before technical identifiers.
2. Open evidence in a contextual side panel on desktop and an accessible phone dialog or detail route. Keep a clear close/back path and restore opener focus.
3. Preserve private-document access controls and existing upload/extraction/confirmation steps. A preview must not confirm a receipt or approve a bill.
4. Present editable extracted values beside source evidence, with field-specific corrections and explicit Save/Cancel. Preserve dirty-form checks across all dismissal routes.
5. Present price review with old/new amount, currency, product, current inputs, owner constraints, expiry and exact action. Keep financial amounts stable and readable.
6. Show supplier payment as its own review, with the obligation, recipient information permitted for the role, amount, currency, identity check and execution consequence.
7. Provide distinct pending, submitted, completed, failed and unresolved states using existing backend records. A payout batch must not look like recipient completion.
8. Handle repeated taps, stale versions, role revocation, reconnect and uncertain responses with the existing authoritative execution path.
9. Maintain separate visual language for a saved comparison, a recorded decision, a prepared action, approval and actual execution. Preserve the permission model.

Exit: reviewers can explain what their next tap does, what remains unexecuted and where actual provider confirmation appears.

## Phase 7 Make AG Studio part of the investigation

Purpose: provide advanced analysis without making ordinary owners operate a dashboard builder first.

1. Start with useful reading views for contribution changes, comparison, ingredient evidence, bills due and payment outcomes. Mount an editor only when its scope and data are valid.
2. Apply the shared typography, surfaces, status language and spacing through the installed Studio APIs. Verify titles, chart labels and controls at actual rendered sizes.
3. Separate Read, Ask and Arrange interactions. Reveal only the requested panel and preserve the current analytical context when closing it.
4. Keep dish, comparison revision, provenance, currency and period synchronized across widgets. Preserve selection and filters when live data arrives.
5. Allow the bounded assistant to configure supported columns, arrangement, widgets and filters. Retain server calculations and validated presentation fields; layout operations never publish or pay.
6. Make source drill-down visible from the relevant row or widget. Explain preview counts and incomplete data. Keep totals authoritative behind pagination.
7. At narrow widths, provide readable equivalent cards and controls for evidence and comparison, with an optional expanded canvas. Essential business actions cannot require panning an 1100px editor.
8. Keep layout undo separate from business history. Verify undo/redo, persistent owner layouts, public session layouts and cache clearing on identity/tenant changes.
9. Verify model cancellation, failure and fallback while the owner edits assumptions or changes scope. Discard late updates and preserve manual controls.
10. Resolve licence availability through judging before making the Studio journey a release dependency. Keep the tested operational fallback accurately described.

Exit: the actual installed harness changes a useful view, its explanation is visible, source drill-down works, and layout undo preserves the decision.

## Phase 8 Apply the design system across every owner section

Purpose: bring secondary workflows to the same quality as the core investigation.

| Surface | Required composition and behavior |
| --- | --- |
| Today | Prioritize actionable work, financial context and a compact operational summary. Keep period and basis explicit. Support zero, one and many inbox items without empty space dominating the page. |
| Bills and stock | Provide a Bills destination and document-review entry, linked purchasing/delivery/matching/payment records, readable stock exceptions and progressive analytics. Preserve counts, waste and recipe workflows. |
| Team | Lead with current coverage and schedule; keep wages and payout status understandable. Preserve weekly navigation, shift editing and role restrictions. |
| Money | Organize collections, obligations and reconciliation around owner tasks. Standardize tabs, period controls and linked evidence for close, wages/tips, catering, refunds, expenses, customers, analytics and PayPal account. |
| Orders | Make active tickets distinct from history. Explain empty lanes, keep channel filters visible and offer list/history access. Preserve keyboard alternatives to drag, Undo and existing status rules. |
| Payments | Make amount, kind, status and related business record primary. Move long provider identifiers into accessible detail without obscuring evidence. Keep captures, refunds, attempts and cash distinguishable. |
| Agents | Put decisions requiring attention before secondary activity/spend metrics. Distinguish proposed work, running tasks, cancelled tasks, fallback and failure. Link completed work to its actual result. |
| Accountant | Lead with scoped findings and reports. Keep legacy/incomplete basis visible and preserve drill-down from reports to records. Provide owner-language recovery from missing prerequisites. |
| Dispatch | Balance map, waiting jobs and driver availability; keep empty states useful. Provide an alternative to drag assignment and keep simulator activity explicit. |
| Group | Require a resolved group, then lead with comparable venue context. Keep currencies separate, editor controls optional and permissions intact. |
| Floor | Prioritize tables requiring attention and the selected service context. Keep analytics and assistant from displacing the room task; support a clear empty-room state. |

For each surface, complete the state inventory from Phase 0, inspect every supported tab and material modal, and review the phone path. Reuse components without forcing every workflow into identical KPI-card-and-grid layouts.

Exit: no supported section is left as an older visual system or an unreviewed error state.

## Phase 9 Complete responsive and enlarged-text layouts

Purpose: make the product usable at every supported size.

1. Test at the baseline viewports and immediately around breakpoint boundaries. Include narrow landscape, browser zoom and 200% text enlargement; check reflow separately at an equivalent 320 CSS pixels.
2. Use content-driven heights and flexible columns. Allow real long labels and values to wrap. Do not shrink text to conceal overflow.
3. Compact mobile metrics and contextual headers so the primary work appears early. Avoid stacking four oversized summary cards before the task.
4. Keep primary actions reachable with the keyboard open and safe-area padding applied. Sticky controls must not cover errors, evidence or approval details.
5. Provide controlled scrolling for genuinely two-dimensional tables, maps and the optional full canvas. Normal reading and essential task controls must reflow. [W3C reflow guidance](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html)
6. Verify drawer, dialog and side-panel transitions across rotation and resizing. Keep focus, selection and drafts stable.
7. Check long dish names, large amounts, negative results, unknown values and translated or browser-translated text where supported. Do not claim new language coverage from layout tests.
8. Record physical mobile-browser checks when a device is available. Keep them separate from emulated viewport results and the deferred native Android review.

Exit: essential controls and amounts remain readable at every required size, without hiding information to make screenshots fit.

## Phase 10 Build the connected motion language

Purpose: make the product feel advanced through continuity, feedback and explanation.

1. Define motion roles using the installed tokens: immediate interaction feedback, local content change, contextual panel transition, layout rearrangement and meaningful completion.
2. Use short feedback around 150–200ms, typical content changes around 200–300ms and larger contextual transitions around 300–400ms as starting values. Adjust through recorded review; duration does not determine backend state.
3. Keep the travelling selection indicator and align navigation, heading changes and focus. Rapid navigation must retarget or finish cleanly without replaying unrelated entrances.
4. Connect a receipt preview to its evidence panel, maintaining its visual origin. Use a simpler transition when the origin is offscreen or under reduced motion.
5. Connect ingredient selection to affected dish evidence. Preserve a static equivalent and readable labels; do not require watching an animation to understand a cost relationship.
6. Show changed assumptions and recalculate locally within the comparison region. Highlight changed result rows after the server response; avoid counting through invented financial values.
7. Transform a chosen option into its review context, retaining the selected price and evidence. Approval buttons remain explicit, stable and correctly scoped.
8. Animate recorded outcome transitions only when authoritative states arrive. Pending, unresolved and failed outcomes must remain visually distinct from success.
9. Animate layout changes without transforming grid ancestors in ways that break measurement. Verify row virtualization, focus and scroll after interruption.
10. Exclude outgoing branches from pointer input, focus, accessibility navigation and decorative tickers during exit. Verify the existing fade-through wrapper rather than assuming its wait mode handles those obligations.
11. Respect system OR app reduced-motion settings live. Provide the same final content and progress information, disable nonessential spatial movement and pause decorative video. [Motion accessibility guidance](https://motion.dev/docs/react-accessibility), [W3C interaction-animation guidance](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
12. Keep scroll native in the operational workspace. Avoid making task completion depend on parallax, scroll choreography, WebGL, autoplay or long entrance sequences.

Exit: every animation has an identified user purpose, an interruption behavior and an equivalent reduced-motion state. No animation delays a command or fabricates an outcome.

## Phase 11 Align public branding and product entry

Purpose: make the public promise and the product experience feel connected.

1. Carry the same reviewed typography, spacing, controls and imagery treatment between landing and console while respecting their different tasks.
2. Provide clear entries to follow the café investigation or explore the workspace. Keep those paths tied to the actual accepted release and supported permissions.
3. Make the guided path repeatable with existing run/version protections. Preserve completed financial history and display a busy/retry state when another run owns the shared fixture.
4. Simplify the mobile diagram into legible stages, with optional access to detail. Do not depend on small baked-in text or unreadable provider identifiers.
5. Match public source, advertised APK, checksums and release versions. Retain correct distinctions between sample restaurant data and actual Sandbox outcomes.
6. Keep claim language consistent with enabled behavior, financial completeness and existing automatic policies. Remove universal approval claims wherever actual behavior differs.
7. Preserve asset attribution and record provenance for any new artwork. Use real product recordings only for functioning-product claims.

Exit: a reviewer entering through the landing reaches the intended release and can identify the audience, next action and operating limitations. Video, narration, deck and Devpost production remain outside this plan.

## Phase 12 Verify accessibility and interaction resilience

Purpose: establish that the polished product remains operable beyond a visual demonstration.

1. Complete keyboard journeys for navigation, search, filters, evidence, assumptions, comparison, draft recovery and approval review.
2. Verify a visible focus indicator, logical order, skip navigation where appropriate, dialog containment, Escape and return focus. No sticky surface may obscure the focused control.
3. Check labels, descriptions, errors, selected states and status announcements with an actual screen reader. Validate dynamic Studio content through its supported accessible representations.
4. Check text contrast, enlarged text, reflow and target sizes in actual components. Review chart colors, legends, patterns and text equivalents rather than relying on color alone.
5. Exercise rapid section changes, double taps, slow network, reconnect, expired sessions, tenant changes and role revocation during work.
6. Verify that the real financial amounts, reviewed inputs and provider states remain consistent during every visual transition and refresh.
7. Test system reduced motion, app reduced motion, a preference change during animation and a hidden/background tab.
8. Record automated findings and manual outcomes separately. Do not turn an automated accessibility scan into a claim of complete conformance.

Exit: no unresolved blocker to completing the core workflows with keyboard, enlarged text, reduced motion or the tested assistive technology.

## Phase 13 Measure performance on representative work

Purpose: protect responsiveness as motion and analytical detail increase.

1. Record the current shell, route, grid, chart and comparison timings before changing budgets. State browser, device, network, dataset and cache conditions.
2. Use both the actual café-sized fixture and a larger synthetic fixture, for example 500 products and 1,000 historical records. Clearly label synthetic records and keep pagination/totals authoritative.
3. Profile route changes, evidence opening, filtering, resize, widget layout, live refresh and the main motion transitions. Look for main-thread blocking, repeated mounts and cumulative layout movement.
4. Reserve geometry for fonts, images, placeholders and charts. Avoid observing “zero” while real data loads. Retain interactive content during background updates.
5. Lazy-load heavy workspace tools when their task needs them. Keep essential navigation and record inspection usable while those tools load.
6. Verify refresh does not reset selection, recompute unrelated layouts or replay entrance animations. Stop nonessential work on inactive branches.
7. Set local acceptance budgets after measuring the baseline. Initial targets are visible action feedback within 100ms and no recurring application-caused main-thread stalls over 100ms during the representative interactions; record exceptions and actual results rather than claiming universal performance.
8. Keep provider/model waiting distinct from UI latency. Present progress, cancellation and recoverable state rather than using animation to disguise unavailable results.

Exit: representative work remains responsive and stable on the recorded test conditions, with no material regression from the accepted baseline.

## Phase 14 Validate usefulness and complete the candidate

Purpose: decide readiness using observed work, not screenshots alone.

1. Ask at least two unfamiliar reviewers to find an affected dish, inspect its supplier evidence, change a volume assumption, compare options, defer a decision and return to it. Give the same starting conditions and record assistance.
2. Ask them to explain contribution versus profit, assumption versus observation, proposal versus execution, and layout undo versus business reversal.
3. Measure core-task completion, wrong turns, corrections, assistance and abandonment. Retain failures. These are internal usability observations unless the participants are actual target owners in the separate consented research protocol.
4. Use an internal target that both reviewers complete the core path without task-specific coaching and correctly explain the approval boundary. A failure requires repair and a recorded follow-up; the first result remains in evidence.
5. Run type checking, relevant unit/contract tests, meaningful browser journeys and a production build against the final source. Add regressions for the repaired routing, loading, group, stock, draft and motion failures.
6. Complete an integrated actual-model Studio journey and the existing reviewed Sandbox path after material wiring changes. Isolated UI fixtures cannot establish live provider acceptance.
7. Back up Raysto, use additive changes where required, retain the previous artifacts, deploy only its services and verify the public entry. Preserve reconciliation during rollback.
8. Publish the exact matching source and artifacts, update the manifest and attach dated screenshots, measurements, reviewer findings and unresolved limitations.
9. Re-score every internal dimension independently. Link each rating to observed evidence and retain disagreements. An open major issue prevents declaring the ten-level target achieved.

Exit: the exact public candidate matches its source, accepted behavior and supporting evidence. Any deferred capability has a specific remaining gate and a narrower claim.

## Audit traceability

| Finding | Primary delivery phases |
| --- | --- |
| D01 long financial page | 1, 5, 9 |
| D02 duplicate scenario interfaces | 5 |
| D03 setup opens out of view | 5, 12 |
| D04 indistinguishable surfaces | 2 |
| D05 clipped tablet navigation | 3, 9 |
| D06 bills discoverability | 1, 3, 8 |
| D07 route restoration | 3 |
| D08 empty inventory analytics | 4, 7 |
| D09 invalid group entry | 4, 8 |
| D10 Studio complexity and fixed widths | 7, 9 |
| D11 false loading zeros | 4 |
| D12 financial context | 4, 5, 8 |
| D13 undefined font token | 2 |
| D14 oversized hero and refresh duplication | 1, 5 |
| D15 repeated generic compositions | 1, 2, 8 |
| D16 mobile priority and touch targets | 2, 9, 12 |
| D17 product discovery | 5 |
| D18 prose-heavy comparisons | 5 |
| D19 inconsistent draft dialogs | 3, 6 |
| D20 unclear empty order board | 8 |
| D21 landing continuity and mobile diagram | 11 |

## Delivery dependencies and deadline decisions

Critical path: baseline and state inventory → interaction design → tokens and navigation contracts → unified comparison/evidence → Studio integration → responsive completion → motion → integrated acceptance → deployment.

Secondary sections can adopt stable shared components while the core workflow is integrated. Motion work starts once its layout and state contracts are stable. Verification accompanies each phase; it is not postponed until the final day.

Suggested Morocco-time checkpoints are targets, not a guarantee that every phase fits the remaining hackathon window:

| Date | Checkpoint |
| --- | --- |
| November 6 | Baseline, issue inventory, compositions and state contracts locked. |
| November 7 | Tokens, navigation, loading/error repairs and first unified comparison integrated locally. |
| November 8 | Core evidence/approval and Studio flows integrated; section-wide component adoption underway. |
| November 9 before 18:00 | Candidate capability freeze; responsive and connected-motion paths complete for claimed scope. |
| November 10 | Accessibility, performance, unfamiliar-reviewer checks and matching deployment. |
| November 11 | Acceptance evidence and release handoff; presentation handled as its separate workstream. |
| November 12 | Operational buffer and submission verification; avoid last-minute design restructuring. |

If a checkpoint slips, reduce the candidate honestly. Defer optional diagram detail, decorative transitions, secondary chart variants and additional layout presets before cutting route correctness, drafts, accessibility, financial clarity or provider recovery. Preserve a coherent verified core. Unreviewed sections cannot be included in a claim that the whole product meets the ten-level target.

## Relationship to the overall hackathon score

This plan targets the web design and experience dimensions in depth. It can strengthen Design and make the implementation and innovation easier to evaluate. It does not establish owner impact, market uniqueness or presentation quality by itself.

The separate release gates remain applicable: consenting owner research, broader actual-model evaluation, reviewed accounting prerequisites for complete reports, final provider recovery acceptance, deferred native review, public-source consistency and Studio availability through judging. A polished interface cannot substitute for those results.
