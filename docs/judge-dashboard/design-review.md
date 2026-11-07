# Judge-first dashboard redesign

Reviewed: 7 November 2026. Scope: owner web console, shared shell and costing/pricing investigation. This is a UI release; the financial backend and Android release remain unchanged.

## Findings from the deployed baseline

The first screen placed an electricity-bill payment approval and four unrelated assistant starters ahead of the café figures. An unfamiliar reviewer had to choose among financial actions before understanding the problem. At 1440 × 1000, the overview measured 3292 CSS pixels high and contained 38 button elements with layout boxes, including navigation. The original count includes controls in collapsed native disclosures, so it is not a count of immediately available choices. The scan covered all twelve destinations; none had document-level horizontal overflow at that desktop size. These are interface measurements, not owner usability results. Exact headings and counts are in audit-before.json.

- Today: critical hierarchy problem; approvals, summary, alerts, four KPIs, charts and full Studio competed for attention.
- Sales and margins: six stages plus a duplicate desktop/mobile selector; repeated dish figures and technical references crowded the decision.
- Bills and stock, Team, Money: distinct operational tasks work better as named destinations than competing first-screen cards. Preserve their existing tabs, approvals and evidence.
- Orders, Payments, Agents, Accountant, Dispatch, Group and Floor: keep them as secondary operational tools. Do not force a judge to inspect every module to follow one decision.

## Research and interpretation

[Google Design: Material 3 Expressive research](https://design.google/library/expressive-material-design-google-research) informed emphasis through size, containment, shape and restrained color. Its usability findings belong to Google's study; they are not evidence of Raysto's usability.

[Google Analytics: Reports snapshot](https://support.google.com/analytics/answer/10668965?hl=en) supports a concise overview with drill-down paths. [Looker visualization guide](https://docs.cloud.google.com/looker/docs/visualization-guide) informed using a time series for change over time, a donut for channel composition and a stacked bar for the included cost/contribution relationship. [Looker dashboard performance guidance](https://docs.cloud.google.com/looker/docs/best-practices/considerations-when-building-performant-dashboards) supports loading detailed analytical work only when requested. The official [Material canonical layout examples](https://m3.material.io/foundations/layout/canonical-examples/overview) were consulted as a layout reference.

These sources inform design decisions; they do not certify this application. No third-party dashboard template, screenshot or illustration was copied into the product.

## Implemented direction

1. A calm paper-and-mint shell with five primary destinations and a single investigation entry.
2. A dynamically selected fully costed dish with a confirmed cost increase, when available. No hardcoded product ID. Unknown costs stay unknown.
3. A three-step story: understand cost, compare prices, inspect the outcome.
4. Three headline figures using server totals: paid order value, paid orders and average order value. These are not recognized revenue or profit.
5. A keyboard-readable paid-order trend, order-channel composition and labeled cost/contribution bar. No invented growth or demand response.
6. A short action list. Full reports, proposals and advanced Studio tools remain accessible on request and retain URL restoration.
7. Evidence without duplicated dish figures, followed by a direct comparison action. Saved assumptions and detailed pricing arithmetic use progressive disclosure; editing, cancel and draft guards remain active.
8. Studio starts with the selected dish. Owners can explicitly widen the view or clear its cross-filter. Raw payment references remain available in evidence details; batch submission does not establish recipient completion.
9. Existing Motion transitions, reduced motion, actual bundled fonts, visible focus and 48px principal controls. No new animation dependency.

## Limits and acceptance

The local connected audit could not authenticate against the isolated preview configuration. It is excluded from acceptance; local browser checks use explicitly labeled authored fixtures. Public acceptance must use the deployed candidate and actual authorized café reads. UI fixtures do not establish model, provider or owner-pilot acceptance.

No restaurant-owner sessions are confirmed. A simpler first view and fewer controls do not prove unaided task completion or a 10/10 score. Android physical review remains deferred by the user. Existing backend accounting-basis limitations and provider evidence remain part of the release record.

## Public-scan correction

The first public scan of dev.7 found a Group Studio schema failure when the ledger contained no rows. The follow-up candidate declares Group field schemas without dummy records. Its Money view withholds the analytical result for empty or truncated revenue/cost previews and labels nonempty results as recorded journal entries, not verified operating profit. The dev.7 scan and deployment records are retained separately. Static chart captures use reduced motion so an offscreen entrance animation is not mistaken for an empty chart.
