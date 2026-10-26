# Raysto Serverpod backend

Serverpod 4.0.4 with PostgreSQL. Start with [current setup](../../../docs/getting-started.md), [project status](../../../docs/project-status.md) and [v2 contracts](../../../docs/backend-v2/README.md).

Run `backend/backend.ps1 -Action test` from the repository root after starting the dedicated Raysto PostgreSQL container. `-Action start` starts the development server and applies migrations. The generated server/client and test helpers are regenerated with the pinned tooling package, not edited manually.

Firebase linking and provider secrets are supplied separately. PayPal remains Sandbox. Connected mobile and the explicit offline demo remain separate. No Render or Serverpod Cloud email/storage dependency is configured.
