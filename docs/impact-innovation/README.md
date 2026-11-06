# Impact and innovation evidence — decision workflow

Registered 6 November 2026. This is internal product/research evidence, not submission copy.

The intended value is one café owner tracing a confirmed supplier increase, comparing a constrained pricing decision, challenging an assumption, reviewing an action and returning to its records. A 9/10 is an objective, not an established result.

## Current evidence boundary

- Fouad confirmed **zero owners booked** on 6 November. No owner quotations, task times, adoption findings or business improvement are established.
- The decision backend is deployed as 0.17.0-dev.5. The matching console and development-signed Android artifact are identified independently in the [release manifest](../release-0.17-manifest.json). Component versions differ; this is still a development candidate with open acceptance gates.
- Scripted Gemini responses test boundaries. The [actual-model review](actual-model-review.json) separately records 12/14 successful first attempts, one transport failure and one fallback. The transport-failed result was recovered without a new model call: 13/14 valid model results are available, while first-attempt delivery remains 12/14. All earlier runs are retained.
- The [integrated Sandbox record](integrated-sandbox-dev5.json) links an actual $9.70 capture and an actual $11.00 completed payout item to reviewed sample evidence, prices and recipe/cost snapshots. The sample venue's journal balances on its legacy recorded-transactions basis; full accrual agreement and earned-revenue attribution remain incomplete without a reviewed cutover.
- The [deployed Studio journey](live-studio-acceptance.json) passed on console 0.17.0-dev.5: visible Gemini explanation, configured comparison/evidence widgets, receipt drill-down and layout undo. Earlier scope and missing-text failures are retained and documented in acceptance.
- No completed seven-day owner-impact observation is claimed. Immediate collections and payouts demonstrate execution, not improved demand or profit.
- Presentation remains a separate workstream.

## Contents

- [Hypotheses and disconfirmation](hypotheses.md)
- [Dated capability comparison](capability-comparison.md)
- [Matched exercises and facilitator answers](exercises.md), [machine-readable fixtures](exercises.json)
- [Consent, interview and observed-task protocol](owner-protocol.md)
- [Blank participant observations](owner-observations.csv)
- [Focused AI/workflow cases](evaluation-cases.json), extending the existing [30-case set](../evaluation-0.17-cases.json)
- [Case-by-case evidence and remaining coverage](case-coverage.md)
- [Candidate acceptance](acceptance.md)

## Research and execution responsibilities

Fouad recruits and obtains consent. The facilitator uses the same supplied evidence for both methods and records assistance. Engineering maintains exact calculations, authorization, client parity and provider recovery. An independent facilitator or reviewer checks answers before sessions; the Python reference checker is an additional independent arithmetic implementation, not a substitute for human research review.

Reassess only after inspecting actual denominators, failures and source versions. If no owners participate, Potential Impact remains an untested case. If real-model Studio interaction or the integrated payment journey is unverified, Innovation remains a partially demonstrated case.
