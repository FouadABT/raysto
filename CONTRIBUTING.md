# Contributing to Raysto

Start with [setup](docs/getting-started.md), [current status](docs/project-status.md) and the [API contracts](docs/backend-v2/integration.md). Describe a concrete user problem before opening a large implementation change.

## Development boundaries

- Keep connected records and the offline demo separate. Demo identities never grant server permissions.
- Put authorization, prices, transitions and idempotency in shared backend services, not just UI controls.
- Change Serverpod source models/endpoints and regenerate bindings. Do not edit generated Dart or schema definitions manually.
- Preserve frozen order amounts and provider references through additive migrations.
- Preserve the forest/paper/lime design system, accessible scaling, RTL and reduced motion.
- Keep secrets out of commits, screenshots, logs, fixtures and issue descriptions.
- Run database tests only on an isolated local test database. No production migrations, cloud provisioning or paid provider operations belong in CI.

## Relevant checks

Choose checks that cover the change. Documentation-only changes need link/content review, not an APK build.

```sh
# Mobile, from the repository root
flutter analyze
flutter test

# Backend, after configuring the dedicated test database
cd backend/raysto/raysto_server
dart analyze
dart test --concurrency=1

# Web, from web/
npm run typecheck
npm test
```

Use focused test files while iterating. Database tests, device checks, provider acceptance and load checks are different evidence; report what actually ran. The browser suite requires a supported browser, documented in [web/README.md](web/README.md).

## Pull requests

Explain the previous behavior, resulting behavior, relevant validation and limitations. Include screenshots for visual changes and migration/recovery notes for schema changes. Keep generated output with its source change. Contributions must be compatible with the project license and retain third-party notices.
