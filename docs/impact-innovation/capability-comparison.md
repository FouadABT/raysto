# Capability comparison checked 6 November 2026

Primary sources: [Restaurant365 Menu Item Analysis](https://docs.restaurant365.com/docs/menu-item-analysis), [MarketMan AI-assisted recipe management](https://www.marketman.com/platform/ai-powered-recipe-management). These are vendor documentation, not hands-on competitor tests. Undocumented behavior is **unverified**, never “absent.”

| Observable behavior | Raysto candidate | Spreadsheet workflow | Restaurant365 | MarketMan |
|---|---|---|---|---|
| Trace ingredient cost into dish analysis | Confirmed receipt and versioned recipe links; verify candidate end to end. | Possible with explicit source columns and maintained formulas. | Recipe-linked costs and actual/estimated methods documented. Exact receipt drill path unverified here. | Purchase prices linked to recipe costing documented. Exact receipt drill interaction unverified here. |
| Compare margins and quantities | Deterministic current-cost baseline, fee assumptions and volume scenarios. | Straightforward formulas if inputs and definitions are supplied correctly. | Menu analysis compares price, recipe cost, margin and sales quantities, with filters and categories. | Menu costing and sales-informed menu analysis documented. |
| Owner challenges a bounded recommendation | Immutable revisions with narrower cap, custom price/volume and unchanged persistent policy. Actual-model evaluation pending. | Owner edits assumptions; revision retention depends on setup. | Conversational challenge behavior unverified in reviewed documentation. | AI ingredient mapping, alternatives and profitability flags described. Exact bounded challenge/revision behavior unverified. |
| Configure evidence view during investigation | Installed Studio harness configures approved widgets, columns, arrangement, filters and sort. Browser acceptance required. | User can configure sheets/charts; automation depends on implementation. | Report parameters, views, detailed/summary output documented. Conversational configuration unverified. | Exact conversational analytical layout behavior unverified. |
| Separate approved execution | Existing AgentAction review for prices; separate PayPal Sandbox money approvals. | Requires additional integrations and controls. | Exact workflow and permissions unverified in this source. | Purchasing/accounting integrations described; exact approval path unverified here. |
| Revisit original decision and actual records | Comparison snapshots, actor/reason, approval, frozen order version, capture and payout-item evidence; incomplete observation periods labeled. | Possible with deliberate audit trails and integrations. | This exact connected decision-return path unverified. | This exact connected decision-return path unverified. |

Inference to test: Raysto's distinctive contribution may be the connected, challengeable decision and return path. Recipe costing, menu analysis and AI-assisted restaurant management are established commercial capabilities. No first-ever, exclusive or “competitors cannot” claim is supported by this review.

The [AG Grid guidance](https://paypalaihackathon.devpost.com/details/aggrid) explicitly emphasizes custom widgets, theming, layout tools and the Studio Agent Framework. Sponsor alignment is not evidence of competitive uniqueness. Record actual interactions and failures before claiming completion.

Next verification: request hands-on product walkthroughs only if available; record source dates and exact scope, keeping all unverified cells until evidence supports a change.
