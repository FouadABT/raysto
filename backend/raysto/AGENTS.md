# Serverpod project

Raysto is a Serverpod 4.0.4 restaurant backend, with PostgreSQL 18.6, generated Dart mobile client, Firebase identity/HTTP v1 push/private GCS uploads and sandbox PayPal REST. Native identity is com.gmrt.raysto. Hosting is the user's AWS infrastructure; exclude Render. See ../../docs/backend-implementation.md and ../../docs/backend-setup.md.
The user explicitly authorized native deployment on the existing AWS host alongside Awhar. That deployment is now at api.rays.to using raysto.service, its own database/roles and ports 18080–18082; see ../../docs/aws-backend.md and ../../deploy/ec2. The "user starts the server" rule below applies to local development. Authorized AWS operations use the isolated systemd/migration workflow; never restart Awhar or run tests on its shared production PostgreSQL cluster. The existing production PostgreSQL 16.15/global Dart SDK were preserved; the Raysto executable was compiled separately with Dart 3.13.7.
Build for multiple users, use Serverpod's built-in authentication, which is already set up in `lib/server.dart`.

The user starts the server with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload the running server.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `hot_reload` / `hot_restart` to reload or restart the server. Use `hot_restart` for changes that hot reload cannot apply, such as changes to `main()`.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `raysto_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests use only the isolated raysto-backend-postgres container on localhost:61810. No embedded database/dataPath is configured. Serverpod creates and drops ephemeral test databases on this dedicated cluster. Never point tests at an unrelated cluster or production. Run `dart test --concurrency=1` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically)
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` for any issues.

This initial workspace had no connected Serverpod MCP and could not start before generated bindings/migrations existed, so the pinned CLI was used for bootstrap. Preserve the MCP-first workflow above once the user starts/connects that service. Firebase project raysto-38505 is now selected/linked with the user's authorization. Sign-in verification needs only FIREBASE_PROJECT_ID and Google's public certificates; enforce verified email. Admin credentials are separate and still needed for FCM/private storage. The user starts the local server through backend/backend.ps1 -Action start. Connected-account reads remain separate from DemoStore; see ../../docs/firebase-integration.md. Do not claim verified-user sign-in or push/storage success without evidence.
