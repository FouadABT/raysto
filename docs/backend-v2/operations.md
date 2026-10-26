# Release, operation and recovery runbook

The owner authorized execution on 26 October 2026. Raysto's additive migrations, constraint/backfill supplements, isolated AWS service, Firebase identity permissions, private uploads, Gemini EU inference and Sandbox handoff now have selected execution evidence in [the release report](../mobile-backend-integration.md). SES, live marketplace payments and off-host restore rehearsal remain unconfigured/unverified.

## Current deployment notes

- Runtime release: `/opt/raysto/releases/0.9.4-20261026`. Patch deployment script: `deploy/ec2/activate-platform-patch.py`. Every switch takes a Raysto-only database backup and rolls the application symlink back if readiness fails. Awhar PID and Nginx checksum are compared before/after.
- The first v2 cutover exposed a brief readiness race after Nginx reload; it rolled back automatically. A bounded readiness retry was added, and the next deployment passed. The rollout retained additive schema during rollback.
- Supplemental tenant foreign keys/indexes are intentionally outside generated Serverpod definitions. Serverpod emits schema-difference warnings naming those objects. Confirm the supplemental catalog objects exist; **do not apply a repair migration that drops them**. The migration launcher checks the installed Raysto migration version before invoking maintenance again.
- Google runtime custom role `projects/raysto-38505/roles/raystoAuthRuntime` has only `firebaseauth.users.get` and `firebaseauth.users.delete`, explicitly approved by the owner. The broader Firebase Auth administrator grant was rejected and was never applied. Vertex inference uses `roles/aiplatform.user`.
- The v2-enabled Serverpod authentication handler also checks that legacy RPC JWTs have an active backing session and rejects deleted/disabled Firebase identities. Firebase revocation detected by current identity proof revokes backend tokens. HTTP event streams use the forwarded Firebase proof; small chunks may be buffered by the current HTTP adapter until the bounded stream closes, so low-latency web streaming still needs acceptance.
- EU Gemini hostname is `aiplatform.eu.rep.googleapis.com`, location `eu`, model `gemini-3.8-flash`. Both token preflight and generation use this host.
- ClamAV and pdfinfo plus their libraries are extracted under `/opt/raysto/tools`, independently of system packages. Only `raysto-signatures.timer` updates `/opt/raysto/clamav`. No Awhar service or shared package was upgraded.
- One leased worker runs at a time. Raysto's cgroup includes the scanner (MemoryHigh 1152M, MemoryMax 1536M, CPUQuota 50%). Uploads are bounded to 8 MiB; timed-out child processes are killed. Invalid images are terminal rejections.
- AI preview is enabled only with Sandbox and unenforced billing: three jobs and 73,728 reserved tokens per restaurant/day, with 20 jobs/day across the preview platform. No commercial plan or subscription price is fabricated.
- Backups taken for this rollout are private local Raysto database dumps. An encrypted off-host destination and successful restore rehearsal have **not** been established; the backup procedure below remains a release-hardening requirement.

## Release gates

1. Review source/contracts and all additive SQL. Confirm the Raysto database name and production PostgreSQL major version; retain PostgreSQL 16 compatibility. Do not upgrade the shared cluster.
2. After the owner resumes verification, use only the isolated local Raysto test cluster for automated integration/concurrency tests. Apply both generated migrations and the supplemental constraints there. Exercise the acceptance matrix.
3. Build the server separately after authorization. Run real Sandbox acceptance with explicit test identities and merchant/buyer separation. Verify refund and webhook evidence independently.
4. Confirm provider permissions/configuration below, operational limits and backups. Record source artifact hash, migration IDs and restored-backup evidence.
5. Take an encrypted off-host Raysto database backup. Confirm destination and encryption key access; neither archive nor credentials belong in this repository.
6. Apply generated additive migrations with the Raysto migration role. Apply `backend/operations/platform-v2-constraints.sql` on both new databases and upgrades. Apply `platform-v2-backfill.sql` only after reviewing historical mappings. Never force-drop or repair unrelated objects.
7. Deploy to the isolated `raysto.service` artifact path with v2 disabled. Validate existing v1 and Sandbox behavior first. Do not change Awhar service files, ports, roles, Nginx sites or process state.
8. Enable v2 for the staging/Sandbox acceptance deployment, then enable one scheduler. Roll out new clients separately. Keep live PayPal disabled until platform approval and live acceptance have their own decision.

Generated migrations live under `backend/raysto/raysto_server/migrations/`. The source model dictionary lists all new tables. The SQL supplement is maintained separately because generated schema files must not be hand-edited; installation must include it for every environment.

## Environment configuration

Use a root-owned, mode-0600 Raysto environment file or an equivalent secrets mechanism. Preserve existing v1 variables. New settings are documented in `backend/operations/platform-v2.env.example`; never fill secrets into that tracked example.

| Group | Required configuration / permission |
|---|---|
| Activation | `RAYSTO_PLATFORM_V2_ENABLED`, `RAYSTO_PLATFORM_WORKER_ENABLED`, `RAYSTO_GUESTS_ENABLED` explicitly default false |
| Identity | Firebase project ID, project number, allowed app IDs, verified-email sign-in and MFA enrollment |
| Google server | Raysto service-account credential path; project-scoped identity lookup/deletion, FCM send and Vertex inference permissions; object access scoped to the Raysto bucket |
| App Check | Start registered clients in `observe`, measure failures, then use `enforce`; guest creation requires verification immediately |
| PayPal marketplace | New platform client ID/secret, partner merchant ID, attribution code, webhook ID, callbacks and approved merchant-country allowlist |
| PayPal subscriptions | Separate seller client ID/secret, merchant ID, webhook ID, callbacks and pre-created matching subscription plans |
| AI | Google Cloud project; Gemini EU enabled; administrator-configured per-plan request/token quotas; billing alerts and project cost limits |
| Scanners | Fixed ClamAV and pdfinfo executable paths, current malware definitions, bounded CPU/memory/process count |
| Email | Raysto-scoped SES credentials/region, verified From identity, SES sending access; no Awhar credential reuse |
| Billing | Plan prices/fees/entitlements; `RAYSTO_BILLING_ENFORCED=true` only after onboarding a valid plan; failure grace defaults seven days |
| Administration | Explicit backend user UUID allowlist plus verified MFA; keep administrative endpoints behind additional edge controls |

The current Google adapter uses the existing service-account-file pattern. Workload Identity Federation should be introduced only as a separately reviewed Raysto-scoped AWS identity; it is not configured by this release.

## Edge and process limits

Prepare changes only in Raysto's Nginx site. Public API upstream remains on Raysto's existing private listener; do not expose PostgreSQL or Serverpod administration ports. Set ordinary API `client_max_body_size 128k`, webhook `256k`, upload `8m`; make the upload location specific to the binary route. Apply the ordinary limit to Serverpod RPC as well; large media should use the binary endpoint.

The prepared server-block include is `backend/operations/nginx-platform-v2.locations.example.conf`. It routes v2 HTTP to the existing Raysto web port 18082 and leaves RPC on its existing port. This example has not been installed or syntax-checked against production. Preserve the current Raysto TLS/proxy configuration and all Awhar sites.

Configure per-IP rate limiting on authentication/public discovery, connection limits on SSE, request/response timeouts, and an explicit future-web CORS origin allowlist. Trust client-IP headers only from the configured Cloudflare/proxy ranges. SSE needs proxy buffering disabled for the events location. API responses containing identities, private files or money should use `Cache-Control: no-store`; public media caching requires publication-aware invalidation.

Use Raysto systemd resource limits and a dedicated user: memory, CPU, tasks and file descriptors. File parsing should have a private temporary directory, no unnecessary network access and a read-only base filesystem. Do not apply resource policies to shared Awhar processes. Keep one leased platform job maximum initially. Parser timeouts, HTTP timeouts, pixel/page/byte bounds and token preflight are additional application controls.

## Database roles and backup

The migration role owns schema changes. The runtime role gets only schema usage, table DML and sequence usage required by Raysto. It must not own tables, create roles, alter schema or disable triggers. Revoke UPDATE/DELETE on `raysto_audit_record` from runtime in addition to the append-only trigger. Authentication and Serverpod internal tables still require their documented runtime permissions.

Use encrypted PostgreSQL logical backups or the existing Raysto backup strategy, copied off the instance. Scope every command to Raysto's database and credential file. A suggested retention policy is daily/weekly/monthly copies, but final retention and recovery objectives require owner selection. Backups must cover SQL and the private objects needed to restore published menu/media references. Test restore into a distinct isolated Raysto database after verification is authorized; do not restore over production.

Record restore duration, row counts, charge balances, capture IDs, pending inbox/jobs and sampled media availability. Run recovery with outbound provider workers disabled. Reconcile pending financial records against provider evidence before re-enabling workers; restoring a database does not undo a PayPal capture.

## Payment recovery

Never delete a pending checkout to unblock a bill. Inspect the frozen reference, stable request ID, merchant, amount, currency and provider history. A create/capture timeout is unknown. Reconcile the same provider order. Aged requests outside the bounded retry window go to manual review; request-ID retention differs by provider product.

Verified capture evidence settles once. Local cancellation is allowed only when no in-flight/uncertain capture can race it. Reversals and disputes are stored separately. `admin.paymentException` requires explicit evidence review or a provider-supported reversal action and an audit reason. Do not change preparation history to repair money.

Legacy pending attempts imported into `ProviderInbox` remain on the legacy reconciliation path. They must never create replacement marketplace orders. The historical backfill intentionally does not invent a restaurant merchant connection, commission or customer permission.

Before backfill, resolve any historical receipt without its original provider attempt/order reference; the script refuses those inconsistencies. Unmatched refund events remain in operator review. Use `admin.reconcileRefund` to link an existing verified provider refund to a pending local request (or import it when unambiguous). Supply a reason and MFA proof; this recovery action only reads PayPal. Subscription reversals remain explicit operator exceptions and must be reconciled against the separate billing merchant's statement before financial reporting is treated as final.

## Worker and notification recovery

Each claim commits a lease before external IO. Acknowledge only the same lease. Process crashes can redeliver an external notification; clients deduplicate the stable event ID. Provider payment/refund retries reuse provider request IDs. Failed AI generation is not automatically repeated because an uncertain generation can already have incurred cost; a new explicit request consumes a new allowance.

Inspect `admin.jobs`, `admin.paymentExceptions` and tenant `payment.exceptions`. Fix configuration before replay. `admin.replayJob` requires MFA and an audit reason and refuses aged financial request replay. Unknown job kinds remain failed rather than being silently acknowledged.

Pending provider states reschedule without consuming the transport-failure retry budget. Checkout uncertainty older than five hours requires operator review. Failed AI operations cannot be replayed through the generic job endpoint: create a new explicitly quota-reserved operation. Notification delivery honors category preferences while the persistent inbox remains the activity record.

## Observability

Monitor API error rate/latency, private database disk/locks, oldest reserved/uncertain checkout, unprocessed webhook age, dead jobs, expired leases, missing scanner definitions, subscription grace expiry, FCM/SES failures and AI quotas. Never log provider bodies, tokens, payment secrets, private document text or unnecessary addresses.

`/health` remains the existing basic database liveness check. `/ready` checks local database/schema and required identity configuration when v2 is enabled; it explicitly reports providers as not probed. Prepared SQL inspection queries are in `platform-v2-observability.sql`. Health is not provider acceptance. Keep separate alerts for provider capability/configuration failures.

## Retention and rollback

Account deletion revokes access, clears personal profile/cart/device data and removes nonfinancial personal content, while financial record IDs/snapshots are retained subject to policy. Active service or large histories create an explicit archival hold. Download access to exports expires after 24 hours. Configure Storage lifecycle deletion for expired export and abandoned quarantine prefixes only after reviewing which approved original sources still use the quarantine prefix; do not blindly delete the whole prefix.

Rollback first disables v2 admission and the platform scheduler, retaining access needed to inspect and reconcile existing records. Deploy the previous application artifact only after confirming it cannot mutate v2 orders through legacy routes. Keep additive tables and evidence; do not reverse financial migrations by dropping data. Restore a backup only for a separately approved disaster-recovery procedure, with external workers disabled and provider reconciliation afterward.
