# Raysto backend v2

This implementation extends the existing Serverpod backend. On 26 October 2026 the owner authorized mobile integration, focused validation and AWS deployment. The v2 surface and bounded workers are enabled on Raysto's isolated AWS service. Payments remain Sandbox. See [mobile integration and release evidence](../mobile-backend-integration.md) for observed results and remaining provider requirements.

The current generated inventory contains 59 platform models/transport types, 80 commands and 46 queries. The original additive migrations and conversation migration `20261026164954486`, both constraint supplements and legacy backfill are applied to Raysto's database. No legacy receipts required backfilling in this deployment. [Current conversation release evidence](../road-to-10-10.md) supersedes historical verification deferrals.

## Read the system

- [Current conversation/AI/payment architecture](maps/conversation-architecture.png) · [SVG](maps/conversation-architecture.svg) · [Mermaid](maps/conversation-architecture.mmd)

- [Complete capability map](maps/capability-map.png) Â· [SVG](maps/capability-map.svg) Â· [Mermaid](maps/capability-map.mmd)
- [System architecture](maps/system-architecture.png) Â· [SVG](maps/system-architecture.svg) Â· [Mermaid](maps/system-architecture.mmd)
- [Data relationships](maps/data-relationships.png) Â· [SVG](maps/data-relationships.svg) Â· [Mermaid](maps/data-relationships.mmd)
- [Payment workflow](maps/payment-workflow.png) Â· [SVG](maps/payment-workflow.svg) Â· [Mermaid](maps/payment-workflow.mmd)

## Source navigation

| Concern | Source |
|---|---|
| Shared commands, identity checks, transactions, idempotency, audit | `backend/raysto/raysto_server/lib/src/platform/platform.dart`, `core.dart` |
| Identity, guests, claiming, teams, sensitive authentication | `identity.dart` |
| Restaurant settings, menus, availability, atomic draft publication | `catalogue.dart` |
| Tables, visits, invitations, service, reservations and waitlist | `dining.dart` |
| Pricing, snapshots, stock, orders, kitchen and courier operations | `ordering.dart` |
| Allocations, PayPal handoff, capture, cash, refunds, merchant onboarding | `money.dart`, `settlement.dart` |
| Subscriptions, plans, history, support, reviews and administration | `operations.dart` |
| Provider transports and credential boundaries | `providers.dart` |
| Quarantine, Gemini, human approval, durable workers and privacy jobs | `automation.dart`, `files.dart` |
| Restricted reads, reports and refresh events | `queries.dart` |
| Dart RPC and REST | `src/endpoints/platform_endpoint.dart`, `src/web/platform_routes.dart` |

See [capability index](capability-index.md), [data dictionary](data-dictionary.md), [OpenAPI](openapi.json), [integration guide](integration.md), [security/state contracts](security-and-states.md), [operations runbook](operations.md), and [acceptance matrix](acceptance.md).

[Business traceability](traceability.md) maps every requested business area to its API family and authoritative records. [Implementation status](../backend-v2-progress.md) distinguishes completed source work from deferred execution.

## Business defaults

PostgreSQL is the authority for permissions, prices, occupancy, orders and money. Firebase Authentication supplies registered identity; Storage holds private files. Existing Firestore preferences and RTDB presence do not grant business access. Each restaurant has one currency and one subscription; owners can own multiple restaurants. Currency is locked after an order. Variant choices use required modifier groups.

Subscription prices, tax configuration, commission rates, merchant countries, AI allowances and email identities require explicit configuration. No commercial prices or tax rates are invented. Commission uses discounted food subtotal, excludes taxes/fees/tips, and uses integer minor units. Cash is recorded but does not automatically collect commission. Delivery fees are currently configured as final amounts without a separate delivery-tax component; configure inclusive fees accordingly and verify this against the applicable commercial tax policy before rollout.

The restaurant lock serializes critical mutations within one tenant. This deliberately favors correctness and a simple first deployment over high write concurrency; load measurements belong to the deferred phase. Required/optional modifiers, discounts and tax allocations use deterministic rounding. A selected-item key is `orderId:lineKey`, with each purchased quantity represented by a separate bill charge.

Initial bounded defaults are 200 current menu items per restaurant, monthly subscription plans with no unconfigured trial/setup fee/tax, one leased worker, 8 MiB uploads, 20-page PDFs and 20-megapixel images. Archived menu IDs remain historical references. Publishing a draft replaces the current catalogue atomically and archives omitted items. PostgreSQL full-text indexes serve restaurant/dish discovery. Team limits count active memberships, including the owner, when billing enforcement is enabled.

## Compatibility and activation

Legacy IDs, orders, payment attempts, receipts, Sandbox facility and generated Dart method signatures remain. New restaurants created through v2 receive a `RestaurantPolicy`. Legacy mutation/payment routes reject v2 restaurants/orders with `client_upgrade_required` rather than bypassing the new ledger. Old restaurants are not automatically activated as v2 tenants. Historical receipt backfill adds evidence and whole-order allocations without fabricating new provider payments or changing old order context.

The prepared legacy pending-attempt import creates operator-review evidence; the existing `PaymentService.reconcile` remains its authority. Do not send imported legacy single-merchant payments through the marketplace refund path without reconciling their merchant configuration first.

## Provider and operational prerequisites

- PayPal platform approval, merchant country/product eligibility and merchant capabilities are distinct from the existing single-merchant Sandbox credentials. Marketplace and subscription credentials have new environment names. A ready merchant connection is refreshed at least daily.
- Raysto subscription sales require a separate merchant account. Provider plans must already exist and match configured currency and price.
- Merchant onboarding requires explicit data-sharing consent. Merchant identity, partner consent, product status, email confirmation, receivability and allowed country are checked independently. Missing country evidence leaves the connection restricted for review.
- Firebase identity lookups and account deletion require the relevant server IAM permissions. Registered v2 requests include current Firebase identity proof in addition to the backend session; guests use the anonymous provider and App Check.
- MFA must be enrolled before ownership, payment-setting and platform-administration actions. A client role or decoded, unverified token never satisfies this requirement.
- ClamAV and `pdfinfo` must be installed in the isolated Raysto execution environment. Scanning fails closed. A malware scanner rejection is not proof a file is safe; verify parser limits and process isolation during acceptance.
- Gemini is pinned to `gemini-3.8-flash` in `eu`, using LOW thinking and a token preflight. No external tools, SQL, arbitrary URLs, credentials, autonomous publication or payment actions are supplied to the model.
- SES requires a verified sending identity and appropriate account sending access. At-least-once notification delivery can repeat after a crash; clients deduplicate persistent event IDs.
- Financial exceptions and aged uncertain provider requests require audited operator review. A dispute notification alone does not change a customer's debt.
- `admin.reconcileRefund` links a verified existing provider refund to a local request or imports an external refund; it never initiates another provider refund. Subscription revenue reports separate collections/refunds and commissions by currency. Subscription reversals remain operator-review evidence until reconciled with the billing merchant's statement.
- Ordinary account exports/deletion run in bounded batches of at most 1,000 records per category. Larger histories enter an explicit operator archival hold. Financial records retain an opaque actor ID; financial/legal retention periods must be set before activation.
- Google Workload Identity Federation is a later optional credential replacement. This phase does not alter the shared AWS instance identity or Awhar permissions.

## Release status

Source generation, static analysis, focused tests, native/server builds and selected live workflows now have execution evidence. Load testing, off-host restore rehearsal, physical-device Google/push acceptance and complete marketplace payment acceptance remain outstanding. See the current release report; this deployment is for testing, not live-money acceptance.

[Source checks](source-checks.md): the backend and generated Dart client report no analyzer issues, and the TypeScript client passes `tsc --noEmit`.

## Research references

- [Serverpod SQL transactions](https://docs.serverpod.dev/concepts/data-and-the-database/database/transactions) and [row locking](https://docs.serverpod.dev/concepts/data-and-the-database/database/row-locking) inform the tenant/balance locking design.
- [Anonymous authentication](https://docs.serverpod.dev/concepts/authentication/providers/anonymous/setup) requires an explicit guest-claiming adapter; automatic account linking is not assumed.
- [Firebase token revocation](https://firebase.google.com/docs/auth/admin/manage-sessions) and [App Check verification](https://firebase.google.com/docs/app-check/custom-resource-backend) define the separate identity and app-verification checks.
- [PayPal platform onboarding](https://developer.paypal.com/platforms/seller-onboarding), [platform approval](https://developer.paypal.com/platforms/get-started), [partner-fee restrictions](https://developer.paypal.com/platforms/overview), and [idempotency](https://developer.paypal.com/api/rest/reference/idempotency/) inform merchant separation and reconciliation.
- [Gemini 3.8 Flash guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/guides/gemini-3-8-flash) specifies thinking levels; [model documentation](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-8-flash) lists EU availability.
- [OWASP API Security](https://owasp.org/API-Security/editions/2023/en/0x11-t10/), [file upload controls](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html), [prompt injection controls](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html) and [AWS transactional outbox](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html) inform the acceptance matrix.
