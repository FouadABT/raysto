# AWS deployment and operations

Latest update: **0.7.0** is active at `/opt/raysto/releases/0.7.0-20261025`, with additive migration `20261025133602556` and the standalone actual PayPal Sandbox USD1 test enabled. Use `dist/raysto-paypal-sandbox-arm64-preview.apk` (**0.7.0**, code **2010**). Actual unapproved checkout/retry, authorization and the approval gate passed; buyer-approved capture/webhook and phone acceptance are pending. [Test instructions and current deployment evidence](paypal-real-sandbox-test.md) supersede the historical 0.5.1/0.6 artifact checkpoint below. Awhar PID 2327174 and its Nginx checksum remained unchanged during this update.

Raysto was deployed on **25 October 2026** to the user's existing Ubuntu AWS host **13.51.45.215**, with explicit SSH/deployment authorization. Public API: **https://api.rays.to/**. Cloudflare setup for the API and the future root/www landing page is in [cloudflare-domain-setup.md](cloudflare-domain-setup.md). Render is excluded. No new AWS instance, container runtime, global SDK upgrade or PostgreSQL upgrade was introduced.

## Actual deployment

The server already runs Awhar natively under systemd, Nginx and PostgreSQL 16.15. Raysto therefore uses an independent native systemd service instead of installing Docker or changing Awhar's runtime. The current Raysto executable was compiled locally for Linux x64 with Dart 3.13.7 / Serverpod 4.0.4, extracted from the current container build and copied with native libraries and migrations. PostgreSQL 16 satisfies Serverpod 4's >=16 requirement.

| Item | Actual configuration |
| --- | --- |
| Service / Unix user | `raysto.service` / `raysto` (nologin) |
| Release / active link | `/opt/raysto/releases/0.5.1-20261025` / `/opt/raysto/current` |
| Database | `raysto_production` on existing loopback PostgreSQL 5432 |
| Runtime / migration roles | `raysto_app` / `raysto_migrator`; no superuser, CREATEDB or CREATEROLE |
| Private env files | `/etc/raysto/runtime.env`, `/etc/raysto/migration.env`; root-owned 0600 in a 0700 directory |
| API / Insights / HTTP ports | `18080` / `18081` / `18082`; UFW incoming-deny protects them; no new inbound allow rules |
| Nginx sites | `/etc/nginx/sites-available/api.rays.to` and `/etc/nginx/sites-available/rays.to`, with separate enabled symlinks |
| Origin certificates | `/etc/letsencrypt/live/api.rays.to/` and `/etc/letsencrypt/live/rays.to/` (root + www) |
| Logs | `journalctl -u raysto`; `/var/log/nginx/raysto-*.log` |
| Backups | `/var/backups/raysto/`; root-only custom-format dumps; daily around 03:30 UTC, 14-day expiry |

The runtime has a five-connection pool and cannot own/alter the migration schema; migration credentials are used only by a one-shot maintenance command. Role connection limits are eight to allow Serverpod's parallel integrity checks. Default privileges grant runtime CRUD on Raysto tables and sequence usage. Metadata checks showed **zero business-table privileges in Awhar** for the new roles. No Awhar database migration, role change, service restart, configuration rewrite or SDK update was performed. PostgreSQL auth configuration was not changed.

Raysto's service is bounded to 512 MiB memory and 50% of one CPU, with automatic restart on failure and systemd filesystem/user protections. Its only SQL traffic uses localhost; `requireSsl: false` is intentionally scoped to that local host connection. Use certificate-validated TLS if the database moves off-host. Serverpod itself binds wildcard interfaces; the **existing UFW deny-incoming policy** protects 18080–18082, rather than a claim that those listeners bind only to loopback.

## Deployment evidence

- Native release archive: `dist/raysto-backend-0.5.1-linux-x64.tar.gz`, **7,250,823 bytes**, SHA-256 `AA9343760D852F8306AABA0B46C9DA3C3D0FCCBD1C5475F415B98365B88F14EE`. The server verified this hash before extraction. No SSH key, `.env`, password YAML, development/test config or local database was transferred in it.
- Linux image used for compilation: `raysto-backend:0.5.1-ec2`; image config digest `sha256:6f776db9cd6d29f366db1ee1a351e3dfa9e613ede91bcbd81ac0fb5aa4f9abb8`. It was built locally; no image was pushed to a registry or installed on the production host.
- Applied/verified migration `20261024150949945` on the **new Raysto database only**, then ran with `--apply-migrations=false`. The first bounded migration connection limit was too small for parallel schema checks; increasing only Raysto's migration-role limit to eight resolved it without reinitializing any database.
- `/health` returned HTTP 200 both directly and through **public HTTPS/Cloudflare**. The generated client over the public domain returned zero published restaurants, rejected unauthenticated orders as `ServerpodClientUnauthorized`, and rejected an invalid Firebase ID token. No actual user login or payment was fabricated.
- Separate trusted certificates were issued for API and root/www; origin TLS verification succeeded without `-k`. Root returns the deliberate landing-pending 503; www redirects to root.
- Both certificate renewal simulations passed against Let's Encrypt's staging CA (`certbot renew --dry-run --cert-name api.rays.to` and `--cert-name rays.to`). The existing certbot timer is active and the Raysto-only deploy hook is installed. The simulations did not replace production certificates or stop Nginx.
- Awhar's API/site returned HTTP 200 before and after deployment. Its process remained **PID 2221016**, started **2026-10-24 15:24:10 UTC**. Its Nginx file SHA-256 remained unchanged. Shared Nginx received syntax-tested graceful reloads, not restarts.
- A Raysto dump was created and its archive listing verified; the daily Raysto-only backup timer is enabled. This is local backup validation, **not a completed restore exercise or offsite disaster recovery**.

## Routine operations

```bash
sudo systemctl status raysto --no-pager
sudo journalctl -u raysto -n 50 --no-pager
curl http://127.0.0.1:18082/health
sudo systemctl list-timers raysto-backup.timer certbot.timer --no-pager
```

Deployment source files are in `deploy/ec2/` locally and `/opt/raysto/deploy/` remotely. The initial `provision.py` deliberately refuses to overwrite existing credentials/database/releases. Do not rerun it for updates. Future updates should create a new release directory, keep the existing secret files, back up Raysto, apply intentional migrations with `/opt/raysto/deploy/migrate.sh /opt/raysto/releases/NEW_RELEASE`, switch the active release and restart **only raysto.service**, with rollback to the preceding executable release if compatible. Omitting that argument targets the current release. Backward-incompatible database migrations require a separate reviewed plan; there is no automatic database rollback. Never run the integration test harness against this production cluster.

Firebase identity verification is enabled for `raysto-38505`; it needs no service-account key. Scoped server credentials are now installed at `/opt/raysto/secrets/firebase-admin.json` (`root:raysto`, `0640`, directory `0750`), with the recurring notification dispatcher enabled. FCM validation-only and private server Storage upload/read/delete passed; actual device delivery remains pending. See [Firebase server verification](firebase-server-verification.md) for the fresh Awhar baseline and remaining policy/device checks. PayPal sandbox credentials, discovered Merchant ID and webhook are now installed in the root-only runtime environment; AWS OAuth, one explicitly approved unapproved USD 1.00 checkout probe, idempotent create, callback routes and unsigned webhook rejection passed. A real buyer-approved capture/webhook and mobile checkout acceptance remain pending; see [PayPal status](paypal-sandbox-status.md). An offsite backup destination, recovery exercise, monitoring and an AWS static-IP assignment check remain operational follow-ups; no AWS API credentials were read. The root landing page and Node.js/AG Grid application are future work.

Current Android artifact: `dist/raysto-paypal-core-arm64-preview.apk` (also `dist/raysto-aws-arm64-preview.apk`), **0.6.0 / Android code 2009**, **26,451,543 bytes**, SHA-256 `BBBF0A93DCFF907C78C9B95F55DF72E03F440944ED89E31D4EE8F9608F19D9C9`. ARM64 release build, manifest and registered development signature were verified. Its `RAYSTO_API_URL` is `https://api.rays.to/`; no local server or USB forwarding is required. [Mobile PayPal core](paypal-mobile-core.md) records reusable checkout/recovery, the isolated local lab, connected own-order adapter, Android HTTPS return configuration and passing mobile checks. [Integration hardening](integration-hardening.md) retains the earlier notification regression evidence. No physical-device, real Google sign-in, actual push delivery or buyer-approved PayPal capture is claimed. Machine-readable deployment evidence is in `aws-deployment.json`; APK metadata is `dist/aws-artifact.json` and `dist/paypal-core-artifact.json`.

Final Flutter static analysis passed with **no issues** after the AWS version/build configuration update. Existing business-logic test results remain the earlier documented checkpoints; the database integration test harness was not run on production. Deployment verification used the real new Raysto schema and bounded API/authorization checks instead.

## Portable container

The optional portable-container path remains available. From `backend/raysto`, build with `docker build --platform linux/amd64 -f raysto_server/Dockerfile -t raysto-backend:0.5.1-ec2 .`. The multi-stage recipe uses Dart 3.13.7, packages native assets with `dart build cli`, excludes local secrets in `.dockerignore` and runs the container's final process as uid/gid 65532. The actual EC2 deployment above uses a separate Unix user and extracted executable, not a running container.

The container defaults to production. Supply these through ECS task environment/secrets, your EC2 service configuration or your existing secret-management system:

| Variable | Purpose |
| --- | --- |
| `SERVERPOD_DATABASE_HOST`, `..._PORT`, `..._NAME`, `..._USER` | Private PostgreSQL endpoint, normally port 5432 |
| `SERVERPOD_DATABASE_REQUIRE_SSL=true` | TLS to production PostgreSQL |
| `SERVERPOD_PASSWORD_database` | Database password |
| `SERVERPOD_PASSWORD_serviceSecret` | Independently generated Insights/service secret |
| `SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey` | Independently generated JWT signing secret, >=64 random bytes |
| `SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper` | Independently generated refresh-token pepper |
| `SERVERPOD_API_SERVER_PUBLIC_HOST` | Actual API domain; scheme https/public port 443 |
| `SERVERPOD_WEB_SERVER_PUBLIC_HOST` | Actual HTTP/webhook domain; scheme https/public port 443 |
| `SERVERPOD_APPLY_MIGRATIONS` | Enable only on an intentional migration task/startup |
| Firebase/PayPal variables | See backend-setup.md; server-only secret injection |

Replace placeholders in `config/production.yaml` through environment overrides. Do not ship the development `passwords.yaml`, `.env`, test credentials or local DB data in the image. Only the dedicated test role needs CREATEDB; use separate database users for production migration and runtime. Configure the trusted PostgreSQL certificate roots for your RDS/private server and verify certificate validation with your chosen deployment before production.

## Network and operation

- Load balancer/reverse proxy terminates TLS. Forward the typed API to 8080 and HTTP health/webhooks/reporting to 8082 with explicit routing. Preserve Authorization and PayPal transmission headers; allow the generated client's required request methods. Forward WebSocket upgrades if enabled later.
- Insights 8081 is private. Database 5432 is private and restricted to application/migration security groups. Do not open the local development port 61810 publicly.
- Readiness checks call `/health` on the HTTP listener and require HTTP 200. Restart unhealthy containers and collect structured stdout/stderr without logging tokens, service-account JSON or request secrets.
- Apply migration files in a single controlled rollout step before scaling API tasks. Back up production and test restore procedures first. Never aim the test configuration at production; the test harness creates/drops ephemeral databases.
- Enable notification scheduling on one designated instance. The outbox uses row locks and supports retries; push delivery is at least once and clients deduplicate event IDs.
- Keep Firebase storage private until explicit image publication/access policy is wired. Configure the real web origin and secure cookie/session strategy when the separate Node.js dashboard is implemented.

These container/network notes are for a future ECS/RDS move. The current single-host deployment, domain certificates, database roles and initial migration are complete as described above; no autoscaling or RDS migration was performed.
