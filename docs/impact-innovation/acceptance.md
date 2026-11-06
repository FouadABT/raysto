# Decision-workflow candidate acceptance

6 November 2026. This record separates implementation, local checks and external acceptance. It does not establish a 9/10 judging score.

## Implemented product behavior

- One-dish entry uses existing menu, private document, receipt and recipe commands. Saved investigation checkpoints explain wall-clock timing and whether inputs were already complete. Payroll and an accounting cutover are not prerequisites for supported costing.
- Server-owned immutable comparisons retain the current-price/current-cost baseline, stricter case cap, owner-entered price, volume assumptions, fee model, break-even calculation, cost-reduction requirement, input versions and evidence. Incomplete inputs cannot support a recommendation. Publication still requires the existing expiring AgentAction approval.
- Owners can keep, defer or reject with a reason, or prepare a reviewed publication. Repeated commands retain request keys. Accountants do not gain publication authority.
- Typed AI tools create comparison revisions and validate analytical view configuration. Installed AG Studio APIs configure actual comparison, evidence and scenario widgets; layout changes cannot execute money actions. Late responses and delayed client tools are discarded after scope changes; dirty comparison drafts are protected.
- Web and native Android expose comparison history, decisions, approval and outcome evidence. Saved orders use frozen prices and recipe/cost snapshots. Successful collection does not imply earned revenue; recipient payout outcomes are separate from batch submission.
- Descriptive observation windows use seven complete venue-local days before and after publication, exclude publication day and account for daylight-saving boundaries. Unknown costs/refund allocations remain unknown. No causal demand or profit conclusion is produced.

## Verification records

[Machine-readable candidate evidence](candidate-evidence.json) names each log, checksum, count and status. The [release manifest](../release-0.17-manifest.json) identifies exact committed component sources and artifacts. There is no accepted submission tag. Previous development checkpoints remain separate.

The full Flutter and web regressions passed before final menu-entry and wording refinements. Their final targeted checks and builds are recorded separately. Browser checks use real installed Studio components with frozen sample records. They establish rendered interaction, not a live model or PayPal outcome. Scripted provider tests likewise establish boundaries, not model accuracy.

Failed attempts remain in the evidence index: a Docker BuildKit environment error, a missing test import/transient timeout, and a narrow-phone test that scrolled its text label rather than the entire tappable control. Successful corrected runs are not substitutes for disclosing those attempts.

[Restored-schema check](restored-schema.json) used a temporary database on AWS and preserved existing order, receipt, capture and bill fingerprints. No production data was exported. The final [restored startup](restored-startup.json) passed before the [backend patch deployment](backend-patch-deployment.json). Only Raysto services changed; Awhar and its Nginx configuration remained unchanged. Initial schema-inspection warnings were checked directly: all 50 reported constraints/indexes existed and were valid; none was removed to silence the warnings.

The integrated baseline passed 381 backend tests. The final financial/AI fixes passed 44 focused tests and static analysis. Full Flutter 257 and web 168 regressions precede final refinements; final targeted checks, native/Linux builds and five browser journeys are listed separately. Counts are not added together as distinct tests.

The real Sandbox run on backend source `3f2c9533028447f212593ec8c8359d2e36b1d06e` confirmed the sample supplier document, a $3.50-to-$3.85 recipe cost change, reviewed $9.00-to-$9.70 publication, a new $9.70 collection and a separately approved $11.00 supplier payment. Capture `5BG76447UF5689408`, payout batch `8G3RC4H4QXV82` and payout item `TB6TJNTVZM9BQ` are actual Sandbox identifiers. The payout item completed. Repeated capture/bill-payment calls reused their records; a stale-version repeated price approval was rejected, while replaying its original request key returned the existing execution. The older checkout retained $9.00 and was then cancelled without deleting history.

The decision view links the source document, matched bill, payout item, frozen price/recipe and $3.85 recorded consumption cost. A missing delivery-to-bill lookup was found during actual acceptance and fixed with regression coverage. Sample fulfillment is simulated restaurant activity; the provider transactions are actual Sandbox activity. No earned-revenue or profit result is inferred from collection. The legacy accounting basis is explicitly incomplete, and no opening balances were invented.

The Android artifact uses the existing development signing key. Physical-device review was explicitly deferred by Fouad on 6 November; widget/layout checks and an APK build do not establish that review.

## Research readiness and missing external evidence

Fouad confirmed **zero owners booked**. The hypothesis register, source-based comparison, consent/interview protocol, two matched USD exercises and blank observation form are ready. Both exercise answer sets have an independent Decimal reference checker. No participant findings, quotations, setup times, adoption benefits or business improvements are recorded.

The authored evaluation contains the original 30 cases plus 12 focused cases. Fourteen varied phrases were run against actual Gemini; this is not a claim that all 42 cases were model-tested. Internal source/response review found 12/14 successful first attempts (85.7%), one transport failure and one labelled fallback. A read-only recovery obtained the transport-failed task's valid result, giving 13/14 valid model results (92.9%) without a new inference. The first-attempt target remains unmet. Prices and venue policy remained unchanged and no action was executed by these evaluation turns.

Earlier full runs are retained: dev.3 passed 11/14 reviewed tasks; dev.4 passed 12/14. Those runs exposed a missing final-report handling path, an AI-expanded case cap and an unsupported percentage. The final backend validates text reports through the same evidence boundary, forbids AI cap widening and checks percentages against returned basis-point values. Some explanations still expose field names and basis points; owner-language clarity needs improvement. The reference/structured-controls/assistant timing comparison remains pending.

Live Studio acceptance exposed two client defects: rolling financial timestamps invalidated an unchanged owner selection, and text chunks without an opening message identifier were dropped by the installed Studio framework. Both are fixed in console 0.17.0-dev.5, source `36c4501bc710869b5b4aebce59c786a12b7a1d29`. The final [actual browser run](live-studio-acceptance.json) passed with Gemini task 2961: the explanation is visible, comparison and ingredient evidence are arranged side by side with the requested columns, the receipt opens, and layout undo preserves the comparison. No browser errors occurred. A [reviewed screenshot](live-studio-dev5.png) records the resulting workspace. Prior failed runs and the narrower layout-only pass remain separate evidence.

## Remaining release gates

1. Improve first-attempt AI delivery and owner-facing wording; complete the remaining authored model/recovery cases and the three-method timing comparison.
2. Obtain owner-reviewed accounting cutover/opening balances before claiming complete accrual results; configure and validate the repeatable public guided fixture.
3. Complete independent cold-reviewer acceptance and private-owner persistent-layout demonstration. Keep live model/browser results distinct from preview tests.
4. Complete actual uncertain-provider recovery and refund acceptance for the final combination; existing isolated regressions are not actual provider outcomes.
5. Complete the deferred native device review against that matching backend.
6. Recruit consenting owners and retain actual task accuracy, assistance, timing, failures and denominators. If none participate, leave owner-impact claims unestablished.
7. Resolve the AG Studio licence through the end of judging and conduct the unfamiliar-reviewer pass.

The connected decision implementation strengthens the innovation case. Potential Impact remains unproven with target owners, and a defensible 9/10 assessment for either criterion requires the missing evidence above. Presentation work has not been undertaken.
