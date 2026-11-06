# Raysto owner workspace — implementation contract

Baseline: `f7059b9`. Design implementation: `e59d7ed` (includes the `ec8075d` redesign, membership boundaries, recipe Undo reconciliation, desktop evidence panel and Studio canvas-readiness corrections). Backend HTTP correction: `c2221d3`. The [original audit](../audits/raysto-web-design-audit-2026-11-06.md) and [approved implementation sequence](../audits/raysto-web-design-implementation-plan-2026-11-06.md) remain historical inputs. This document describes the implemented behavior; the acceptance record describes what was actually verified.

## Navigation and state inventory

| Destination | Supported views and material states | Principal work |
| --- | --- | --- |
| Public entry | Desktop/phone diagram; investigation/workspace entries; Android preview and checksum | Enter an understandable, supported workflow. The diagram is labeled and contains no fabricated provider result. |
| Connected entry | Signed out, authentication failure, venue/group choice, phone drawer, sign-out draft guard | Resolve identity and venue before reading private records. |
| Today | Action inbox, empty inbox, proposed/decided/failed/running work, financial summary, period selection, sample history | Open the next relevant investigation or review. |
| Sales and margins | Choose dish, cost evidence, comparison, Studio, decisions/outcomes, financial reports | Investigate one dish without passing through unrelated reports. |
| One-dish setup | Confirmed inputs, incomplete inputs, saved checkpoint, recipe/conversion/package edits, policy review | Complete the evidence required by that dish. Uploads do not approve receipts or bills. |
| Comparison | Keep price, qualifying price, owner price, infeasible target, missing costs, assumptions changed, expired revision, prepared review | Use one server-calculated comparison, then keep, defer, reject or separately approve a proposal. |
| Evidence | Recipe quantities, conversions, receipt source, private-file loading/error, correction draft, modal dismissal | Inspect evidence in context and return focus to its opener. |
| Decisions | Saved comparisons, paginated decisions, publication history, restoration scenario, immediate events, incomplete seven-day observations | Distinguish the original projection, approved action and recorded outcome. |
| Studio | Read, Ask, Arrange, data/filter panels, cross-filter, receipt drill-down, layout undo/redo, saved owner layout, session-local judge layout | Configure presentation without authorizing a business mutation. Narrow screens have readable equivalent cards and the same bounded analysis API. |
| Bills and stock | Bills, inventory, purchasing, receive, suppliers, recipes, waste | Review documents, obligations and deliveries before replenishment or settlement. Bills reuse the existing Accountant implementation. |
| Team | Cards/grid, week selection, shift editor, person dialog, clock action, payroll evidence | Inspect hours and wage inputs. Unsaved forms guard navigation and modal dismissal. |
| Money | Close, pay/tips, catering, refunds/disputes, expenses, customers, analytics, PayPal account | Review obligations, execution and reconciliation with existing permissions and identity checks. |
| Orders | Active board, history/list, channel filters, detail, pickup code, keyboard/drag transitions, grace-period Undo | Work active tickets; explain completed-only boards and offer history. |
| Payments | Captures, cash, refunds, attempts, method/day, unresolved filter, related order | Inspect actual record and provider states. |
| Agents | Inbox, activity, task/action detail, pending/executed/rejected/failed/cancelled states | Review proposed work and inspect what actually ran. |
| Accountant | Overview, P&L, cash flow, bills, aging, requests, VAT | Read the supported accounting basis, estimates and evidence. Legacy recorded result remains distinct from accrual operating result. |
| Dispatch | Board/map, drivers, offers, waiting jobs, partner apps, identity check, simulator/unavailable simulator | Dispatch with keyboard alternatives and explicit simulated activity. |
| Group | Portfolio, venue comparison, money, templates, transfers, group/currency/period selection | Resolve an authorized group, keep currencies separate and expose analytical configuration deliberately. |
| Floor | Shared attention filter, room summaries, optional analytics/assistant, map/tables, records, room conversation, empty room | Prioritize the restaurant room before editing a dashboard. |
| Offline demo | Guest ordering, simulated payment outcomes, table/service history, local owner operations | Remains an explicit separate mode. Its tests run with `RAYSTO_OPS_ONLY=false`, not against connected-only redirects. |

All read capabilities remain authorized on the backend. Role-specific controls do not grant permissions. Owners, managers and accountants retain their existing server permissions; no accounting policy, model allowance or financial autonomy was expanded by this design release.

## Shared interaction rules

- Sections and supported tabs use the URL. Dishes, saved comparisons, order channels and analytical periods use validated route values. Browser history uses the same draft boundary as in-app navigation.
- Confirmed records remain on the server. Unsubmitted text, search and layout state are held only in memory under an API identity and venue. Reload protection does not claim durable recovery of an unsaved draft.
- Selecting the current destination cannot silently clear its dirty state. A changed saved comparison updates both the URL and analytical scope, including comparisons returned by AI.
- A discarded form does not erase an uncertain command's idempotency key or a prepared server action. Failed saves retain drafts. Successful submitted forms acknowledge only their own unchanged submission.
- Recipe and receipt forms use explicit Save/Cancel. Native dialog Escape, close and backdrop dismissal respect draft checks. Browser reload uses the browser's native unsaved-change prompt.
- Search, sorting and grid configuration survive in-app return under the same identity/venue. Late callbacks cannot restore an outgoing identity or record.
- Initial unknown amounts use pending placeholders. Background reads retain usable rows with a freshness notice. A financial-report failure cannot hide independently available dish costs.
- Comparison cards show server amounts directly. Changed assumptions invalidate the displayed decision for execution until recalculation; comparison expiry updates even while the page remains open.
- Price approval displays the product, old/new amount, currency, revision, target, cap, expiry and consequence. Supplier payment remains a separate approval. Dashboard arrangement cannot publish or pay.

## Visual and motion roles

The existing token source remains `docs/design-tokens.json`: paper canvas, white content surfaces, forest primary, lime selection, mint support and peach attention. Jakarta is functional typography; bundled Fraunces is used for orientation and brief editorial headings. Financial figures use tabular numerals.

Essential custom controls retain 48px targets, including grid-copy controls. The tablet rail is 112px with wrapping labels. The phone uses a modal navigation drawer and a compact investigation-view selector. Tables and optional canvases contain their own two-dimensional scrolling; ordinary content reflows.

| Motion | Purpose | Interruption/reduced-motion behavior |
| --- | --- | --- |
| Navigation indicator | Keep the selected destination visible | Retargets to the selected item; static under reduced motion. |
| Section fade | Explain a change of workspace | Outgoing content becomes inert, hidden from accessibility navigation and untappable. Grid ancestors are not scaled. |
| Evidence container | Maintain the receipt's visual origin | Native modal containment and guarded dismissal; direct final state under reduced motion or without an available origin. |
| Comparison entrance | Identify returned server results | Short local entrance; real amounts stay fixed. No invented payment outcome or count-through of scenario values. |
| Layout change | Explain presentation changes | Existing Studio APIs and document history; undo/redo controls reflect available history and never reverse a payment. |
| Recorded result feedback | Acknowledge a returned state | Existing pending, failed, unresolved and completed states remain distinct. |
| Existing figure motion | Reinforce a recorded value change | Stops on outgoing branches, hidden tabs and device OR app reduced motion. |

Operational scrolling remains native. No replacement animation library, WebGL requirement or scroll choreography was added. Heavy financial analysis loads on demand. The development-only component catalogue is `/ops/kit/decision`; it cannot execute a backend command, model call or payment and returns 404 in production.

## Audit traceability

| Finding | Implemented correction | Verification path |
| --- | --- | --- |
| D01/D02 | Six focused views; one comparison form; reports separate | Finance and routing browser journeys. |
| D03 | Guided entry scrolls and focuses the one-dish setup | Guided-entry keyboard test. |
| D04/D13 | Explicit white surfaces and real Fraunces definition | Rendered desktop/phone captures and typography inspection. |
| D05 | Wider, wrapping tablet rail | 1024px label/target checks. |
| D06 | Bills directly in Bills and stock | Route, refresh and bill-detail journeys. |
| D07 | URL restoration and scoped state | Back/Forward, refresh, dirty-draft and selection checks. |
| D08 | Declared stock fields and data-ready Studio mount | Loaded stock table/Studio agreement, including genuine deployed records. |
| D09 | Integer Group HTTP parsing plus scoped recovery | Three parser unit cases, eight isolated Group integration cases and actual authenticated HTTP queries. |
| D10 | Read first, deliberate panels, compact phone analysis | Studio, cross-filter, arrangement and narrow reflow checks. |
| D11/D12 | Pending values, retained reads, explicit financial context | Delayed/failing fixture and actual backend context checks. |
| D14 | Compact contextual header; hero only at investigation entry | Viewport captures and functional task paths. |
| D15 | Shared controls/typography with task-specific orientation and existing operational compositions | Every supported section/tab plus focused visual review. Independent usefulness review is separate. |
| D16 | 48px targets, compact metrics, phone view selector, corrected Floor header | 320px, tablet, keyboard and enlarged-text checks. |
| D17 | Searchable dishes, readiness filter and a direct next action | Complete/incomplete dish journeys. |
| D18 | Aligned option cards, target status and expandable assumptions | Saved comparison and approved-review inspection. |
| D19 | Shared branded discard flow and native guarded dialogs | Recipe, comparison, Team and browser-history checks. |
| D20 | Completed-only board explanation and history action | Orders regression suite. |
| D21 | Responsive labeled diagram and direct product entries | Landing tests and matching release artifact checks. |

## Acceptance boundaries

Implementation is not an independent 10/10 assessment. Physical Android acceptance remains explicitly deferred. Consenting restaurant owners booked: zero, unless a subsequent research record establishes otherwise. Unfamiliar-reviewer and actual screen-reader observations must be reported separately from browser automation. Studio availability must cover the end of judging; the previously recorded December 10 licence expiry does not cover December 15. No owner quotations, measured business improvement or seven-day impact outcome is inferred from fixtures or payment tests.

Presentation film, narration, deck and Devpost production remain outside this workstream. Historical financial-basis limitations and earlier failed evaluation attempts remain in their original records.
