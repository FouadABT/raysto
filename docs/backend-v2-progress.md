# Complete backend implementation

Started 25 October 2026 from the approved backend plan. On 26 October the owner authorized mobile integration, focused tests, builds and AWS deployment. Current execution evidence and provider limitations are in [mobile-backend-integration.md](mobile-backend-integration.md). Web implementation is outside this release.

## Source work packages

Updated 26 October 2026. Checked items below mean source implementation/preparation, never runtime acceptance.

- [x] Shared contracts, tenant transactions, permissions, idempotency and append-only audit supplement
- [x] Registered/guest identity, explicit guest claiming, session-bound sensitive grants, revocation, teams and ownership
- [x] Restaurant policies, catalogue drafts/publication, pricing, customer data and private media pipeline
- [x] Floor plans, private visit joining, QR resolution, service requests, reservations and waitlist seating
- [x] Dine-in/pickup/delivery ordering, frozen snapshots, cancellation, kitchen and courier operations
- [x] PayPal merchant onboarding, split allocations, cash, refunds, verified provider inbox and reconciliation
- [x] Subscription plans/history/entitlements, commission, support, notifications, reports and administration
- [x] Gemini provider, bounded import/generation/translation jobs and explicit reviewed proposals
- [x] Generated Dart bindings and two additive migration directories; legacy compatibility guards
- [x] OpenAPI and TypeScript client, source data dictionary, business traceability and permission/state contracts
- [x] Four diagrams exported as editable Mermaid, SVG and PNG; release/recovery/rollback documentation
- [x] Meaningful unit/integration definitions and full deferred acceptance/evidence matrix

Inventory: **41 persistent models + 8 transport models; 68 command routes; 41 read queries**. Source is under `backend/raysto/raysto_server/lib/src/platform/`; start reading at [backend v2 README](backend-v2/README.md).

## Verification and activation gates

| Gate | Status |
|---|---|
| Serverpod source generation | Completed; generated files were produced from authored models/endpoints |
| Additive migrations | Applied to Raysto: `20261025161248873`, `20261025162915326` |
| Supplemental SQL constraints/backfill | Applied; disposable-schema installation also passed |
| Dart/TypeScript static checks | Passed: server/client Dart analyzers report no issues, TypeScript `--noEmit` exits 0; [source evidence](backend-v2/source-checks.md) |
| Automated unit/integration/concurrency tests | 22 distinct backend and 50 mobile checks passed; selected, not the full acceptance matrix |
| Provider/Sandbox/device functionality | Verified Firebase exchange, uploads, Gemini draft/approval, restaurant workflows and unapproved PayPal Sandbox handoff; physical acceptance remains separate |
| Load, backup restoration and rollback exercises | Load and off-host restore not executed; deployment rollback was exercised by an initial readiness failure |
| Backend build / APK build | Linux build deployed; Android test APK built; see release artifact evidence |
| AWS migration, deployment and feature activation | v2 and bounded workers enabled in Raysto's isolated service; Awhar preserved |

The v2 API, guest admission and worker still default to disabled in new environments; they are explicitly enabled on Raysto AWS. The scanner and bounded Gemini Sandbox preview are configured. Marketplace approval, verified merchant eligibility, a separate billing merchant, commercial prices/taxes and SES access remain prerequisites for those business services. Subscription reversal events require operator reconciliation against provider statements.

The backend architecture and native mobile entry points are implemented. Focused runtime evidence is recorded; the complete acceptance matrix and live-money production readiness are not established.

Provider enablement is separate from implementation. New provider credentials and commercial rates are never fabricated. The release report separates executed checks from outstanding acceptance.
