# Raysto web design and user experience audit

6 November 2026. Candidate backend and console 0.17.0-dev.5. Source reviewed at `f7059b9`; the console artifact is from `36c4501`. Product implementation, deployment, presentation production and financial records were not changed during this audit.

Raysto has a recognizable foundation: forest, paper and lime; characterful display typography; a useful navigation indicator; and a calm hospitality tone. Execution varies considerably between screens. Today and several Money views have deliberate compositions. The newer financial workflow often reads as a long form appended to an existing dashboard. Additional animation alone would leave its main usability problems intact.

The focused web design assessment is approximately **7/10**, as an editorial judgment rather than an organizer score. The earlier general release assessment of 8/10 did not expose the responsive and workflow issues recorded here. A nine-level design case requires a shorter decision journey, consistent visual hierarchy, dependable responsive navigation and motion that explains changes.

## Inspection scope

The running public product was inspected in the in-app browser. Desktop inspection used the available viewport, approximately 1503 pixels wide, with screenshots also capturing the browser's available height. Responsive checks used 1024 × 768, 390 × 844 and 320 × 800. Temporary viewport overrides were reset.

| Surface | Inspection |
| --- | --- |
| Public landing | Desktop and 390px visual inspection; entry actions, diagram and download messaging. |
| Today | Loaded action inbox, starters, financial summary, operational KPIs and analytics hierarchy. |
| Sales and margins | Loaded financial basis, coverage, default incomplete dish, two scenario interfaces, guided setup disclosure, Studio controls and page depth. Desktop, tablet and 320px inspection. |
| Bills and stock | Inventory metrics, loaded stock grid, analytical canvas and tab organization. |
| Team | Loaded weekly cards, metrics and primary scheduling controls. |
| Money | Loaded daily close and Expenses, forms, grids and navigation across its eight tabs. |
| Orders and Payments | Loaded active board and capture table; empty-board treatment and relationship to history. |
| Accountant | Loaded overview, findings, metrics and organization of Bills and financial reports. |
| Dispatch | Loaded map, drivers, queue and record table. |
| Group | Entry with the default All my restaurants selection, including its error and Studio state. |
| Floor | Loaded empty table/service state and Studio arrangement. |
| Agents | Loaded approval/task summary and mobile layout at 390px. |

Source inspection covered shared tokens, responsive shell, navigation, financial composition, scenario controls, Studio wrappers and motion primitives. Browser screenshots and DOM measurements establish the observed layouts. Source findings are identified separately below. No approvals, payments, record edits, AI requests or preference changes were submitted.

This was not a physical-device, screen-reader, complete keyboard, 2× text or frame-time certification. Every tab, permission combination, nested modal and error branch has not been exercised. The older local guest-demo design is a separate surface from the deployed owner console and was not visually reassessed here.

## Findings that should lead the redesign

P1 means address before making a strong design-readiness claim. P2 means address during the design consolidation. These are design priorities, not security vulnerability grades.

| ID | Priority | Evidence and consequence | Required change |
| --- | --- | --- | --- |
| D01 | P1 | At 320px, Sales and margins measured about 6,675px tall with the default incomplete dish, before opening a comparison. The first comparison region began around 3,068px and Studio around 4,077px. A desktop measurement was about 4,431px. The owner must pass several unrelated contexts to reach the decision. | Organize one investigation around a selected dish, compact evidence, comparison and reviewed decision. Put business-wide financial reporting in its own accessible view. |
| D02 | P1 | The page contains both “Compare an owner-target scenario” and “Compare a pricing decision,” with repeated baseline and volume inputs. Source confirms separate scenario and comparison components. | Present one comparison workspace, retaining compatibility with older scenario records behind the shared experience. Explain the current-cost baseline once. |
| D03 | P1 | Pressing “Investigate a cost change” inserted the setup region around 1,612px below the top at 320px. The hero button had no expanded-state announcement in the inspected DOM. | Move the owner into the setup step with a clear heading, focus and scroll position; provide an accessible expanded state if retaining a disclosure. Make Continue and missing-input correction directly visible. |
| D04 | P1 | Financial panels and the page both computed to `rgb(246,247,242)`. Panels still use 28px padding and rounded corners, producing large gaps with weak grouping. | Apply the correct white/container surface role to panels that need separation; remove unnecessary panel wrappers where spacing alone is sufficient. |
| D05 | P1 | At 1024px, the 80px navigation rail clipped “Sales and margins,” “Bills and stock” and the operations disclosure. The labels have no title tooltip; source retains `white-space: nowrap`. | Design a real rail treatment with readable wrapping or reviewed short labels, full accessible names and discoverable tooltips. Keep the operations entry usable. |
| D06 | P1 | Bills and stock opens Inventory and exposes Inventory, Purchasing, Receive, Suppliers, Recipes and Waste. The Bills tab lives inside Accountant, under secondary navigation. | Give Bills and stock a clear bills destination and document-review entry. Link purchasing, delivery, matched bill and payment within that context. |
| D07 | P1 | Section changes retained `/ops?judge=1`. Reloading from Sales and margins returned to Today. Source initializes from the query but changes section using component state. | Synchronize section and relevant selection with routing/history. Refresh, Back, Forward and shared links should restore useful context, subject to identity and draft guards. |
| D08 | P1 | In Inventory, metrics and an 11-row stock grid loaded while five analytical widgets still displayed “No data to display.” The empty canvas occupied roughly 500px before the records. | Reproduce and resolve the data-to-widget state. Distinguish loading, unavailable analysis, missing usage history and an actually empty dataset. Hide an unusable analysis behind a meaningful summary and corrective action. |
| D09 | P1 | Entering Group with the default All my restaurants selection produced “Invalid groupId.” A Studio editor with several open panels remained visible beneath the error. | Resolve an authorized group before loading its workspace. Provide a group chooser/retry state, and prevent editor chrome from presenting invalid or empty analytical context. Root cause still requires debugging. |
| D10 | P1 | Multiple Studio areas expose dense tool chrome, nested scrollbars, empty grids and truncated widget titles. Finance deliberately sets a minimum canvas width of 800px, or 1100px with its panel open. | Provide a curated reading mode and deliberate editing mode. At narrow sizes, expose the same calculations and business actions through compact cards and a focused assistant; keep the full canvas as an optional expanded view. |
| D11 | P1 | Financial coverage briefly displayed “0 of 0”; Team and Supplies initially displayed zero metrics before their actual values loaded. | Use loading placeholders or pending labels. Preserve prior data during refresh and state its freshness. A loading response must not look like a valid zero result. |
| D12 | P1 | Today, Accountant, Payments and Sales and margins expose different metrics, periods and accounting bases. Their labels contain useful detail, but comparison requires reading supporting paragraphs. | Put period, basis, currency and provenance beside the relevant measure or in a shared context strip. Retain all financial qualifications while reducing repeated prose. Do not silently merge the underlying measures. |

## Visual identity and component findings

| ID | Priority | Finding | Direction |
| --- | --- | --- | --- |
| D13 | P2 | The finance hero uses `var(--font-fraunces)` without that custom property being defined in the inspected source. Its computed family was Jakarta; the app bar correctly used Fraunces. | Define shared display/body/numeric typography roles and use them consistently. Keep display type for orientation and short editorial moments, with Jakarta for dense work. |
| D14 | P2 | The large finance hero contains a headline, introductory action, explanation and a second refresh control. The shell already has Refresh. Buttons compete without adding decision context. | Use a compact workspace introduction with one primary action, selected dish and useful status. Keep refresh in one predictable place. |
| D15 | P2 | Many sections repeat the same sequence of rounded KPI cards, capsule tabs, generic panel, search and grid. Useful primitives become the entire composition. | Give task families their own structure: a work inbox, a comparison, a receipt review, a schedule and a payment timeline should be recognizable by layout as well as title. |
| D16 | P2 | At 390px, the Agents view stacked four large summary cards before its core work area. Its two view-switch buttons measured 38px high. At 320px, inspected finance button bounds met 44px; that does not certify every control to the project's 48px target. | Prioritize approvals/tasks on mobile, compact secondary metrics, and check all interactive target dimensions against the established 48px requirement. |
| D17 | P2 | The default finance selection was an incomplete croissant within a 45-option native selector, containing repeated dish names. Only 3 dishes had complete costing. | Provide search, readiness filters, clear product identity and direct missing-input actions. Offer a clearly labelled complete sample path alongside the incomplete-data case in the judge venue. |
| D18 | P2 | Comparison options render as long prose blocks and sensitivity lists. Decision reasons use mechanically spaced enum labels. | Align options in comparable rows with an immediately visible price, unit contribution, target and assumed volume. Show explanatory detail on demand and use reviewed owner language. |
| D19 | P2 | Receipt review, recipe editing, saved-comparison restore and section changes use native `window.confirm` prompts. Draft protection exists, but its presentation differs from the rest of the interface. | Consolidate Save, Keep editing and Discard decisions into an accessible branded dialog while retaining every existing guard. |
| D20 | P2 | The active Orders board displayed empty lanes while its footer said the newest 100 orders were loaded. History was available through List, but the empty lanes did not explain the relationship. | Explain that there are no active tickets in this view and offer completed/history inspection as a useful next action. |
| D21 | P2 | The public landing has stronger typography and hierarchy than much of the console. Its detailed animated diagram becomes too small to read comfortably at 390px. | Carry the same visual discipline into the owner product. Use a simplified mobile diagram and keep the detailed diagram for expansion. Judge-facing amounts and labels must remain legible. |

## Motion design assessment

Raysto already has Motion integration, named duration/easing tokens, a travelling navigation indicator, fade-through transitions, reveal components, container dialogs, count-up metrics and system OR app reduced-motion support. `CountUp` provides final values to assistive technology while hiding moving digits. These are useful foundations to preserve.

The gap is a consistent relationship between movement and the owner's work. Today and older operational sections use motion primitives; the newer financial components are largely ordinary blocks and form disclosures. Hover effects and broad entrance animations do not make the sequence from evidence to decision understandable.

Use the existing short and medium timing roles, approximately 150–400ms depending on purpose, rather than adding an unrelated animation library or applying one duration everywhere.

| Interaction | Proposed motion and purpose | Safeguard |
| --- | --- | --- |
| Choose a dish | Keep its name, price and readiness visible while related evidence updates. Use a short content transition and local loading state. | Preserve the selected dish and filters on refresh; show authoritative amounts only. |
| Open supplier evidence | Expand a receipt preview into a side panel, with a clear origin and return path. On phones, use an appropriately sized dialog or sheet. | Focus moves into the evidence and returns to its opener; unsaved corrections remain protected. |
| Change a scenario assumption | Mark the changed assumption, show calculation in progress and update the affected result rows together. | Do not animate through invented prices or contribution amounts. Mark the revised scenario explicitly. |
| Compare options | Keep current price and candidate options aligned; use restrained emphasis to explain what changed from the previous revision. | Never imply predicted demand or an observed improvement. |
| Prepare and approve | Reveal the review panel from the selected option, retaining its evidence and assumptions in context. | Approval stays explicit and distinct from view configuration. |
| Inspect execution | Progress the timeline only as recorded statuses arrive: approved, submitted, pending, completed or failed. | Animation must not imply that PayPal completed an action before provider evidence establishes it. |
| Change layout | Animate widget arrangement while retaining chart/grid selection. | Undo changes presentation only. Validate grid measurements and preserve scroll. |

Source review also found that the fade-through wrapper retains outgoing content during its exit without an explicit `inert` or pointer/focus exclusion in that component. Verify this behavior under rapid navigation before extending motion around approvals. This is a verification gap, not an observed unauthorized execution.

Reduced motion should retain the same information, focus order, progress labels and useful final state. More animation should not increase the time required to reach an action. Frame-time and physical-device claims require separate measurement.

## Recommended visual direction

Keep the approved palette and fonts. Strengthen the restaurant context through original layouts, receipt details, ingredient evidence and careful typography. Use lime for selection and a small number of meaningful highlights; maintain forest for primary actions and warm paper for the workspace. Establish explicit raised, quiet and selected surface roles so sections do not accidentally disappear into the page.

Give the core investigation a persistent strip showing its actual progression: supplier evidence, recipe cost, options, review and outcome. Each stage should communicate whether it is complete, missing inputs or awaiting action. This makes the product's distinctive connected workflow visible through interaction.

On desktop, use a selected-dish header, central comparison and contextual evidence panel. Keep full financial reporting reachable without placing it ahead of every pricing task. On mobile, use focused stages with a compact summary and a persistent useful next action that respects keyboards and safe areas. Preserve the ability to reject, defer and correct evidence.

Studio should inherit the product's spacing, typography and state language. It should feel like part of the investigation, with editing controls revealed deliberately. A usable analytical view should appear before an empty builder.

## Implementation order and acceptance

1. **Repair the visible failures.** Resolve group entry, inventory analytical states, false loading zeros, clipped tablet labels and route restoration. Verify on the deployed candidate.
2. **Unify the decision journey.** Consolidate the scenario interfaces, make the main action reveal its work visibly, introduce dish search/readiness and relocate business-wide reporting. Preserve calculations, drafts, permission checks and saved records.
3. **Consolidate visual primitives.** Correct the typography token and panel surfaces; standardize headings, metrics, forms, tabs, dialogs, empty states and grids. Apply the system to the inspected operational screens, not only the finance hero.
4. **Integrate Studio at each size.** Curate its starting views, control panel exposure and drill-down. Keep equivalent narrow-screen decision actions and an optional expanded canvas.
5. **Apply connected motion.** Implement the interactions above with existing primitives, interruption handling, focus management and reduced motion. Avoid blocking entrances or repeated counters during live refresh.
6. **Review with unfamiliar people.** Observe finding an affected dish, opening evidence, changing an assumption, comparing options, deferring a decision and returning to it. Record assistance and failures; do not infer usability from screenshots alone.

Acceptance requires that desktop, 1024px, 390px and 320px layouts have readable navigation and essential controls; opening an action exposes the relevant work immediately; loading is distinguishable from zero; Back/Forward/refresh retain useful route context; all key actions work by keyboard; 2× text and open keyboards preserve approval information; and reduced motion retains the complete workflow. Validate persistent owner layouts separately from public session layouts.

## Source references

- [Canonical design guidance](../MOBILE_APP_DESIGN_SYSTEM_GUIDELINES.md)
- [Financial styles](../../web/src/components/connected/finance-section.css), [financial composition](../../web/src/components/connected/finance-section.tsx), [comparison controls](../../web/src/components/connected/price-comparison.tsx)
- [Responsive shell](../../web/src/app/ops/m3-shell.css), [navigation state](../../web/src/components/connected/operations-workspace.tsx), [surface roles](../../web/src/app/md-sys.css)
- [Finance Studio](../../web/src/components/connected/finance-studio.tsx), [shared Studio wrapper](../../web/src/lib/connected/studio/studio-canvas.tsx)
- [Motion roles and preferences](../../web/src/lib/connected/motion.ts), [fade through](../../web/src/components/connected/m3/fade-through.tsx), [count-up accessibility](../../web/src/components/connected/m3/count-up.tsx)
- [Current release manifest](../release-0.17-manifest.json)
