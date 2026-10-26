# Deployment boundaries

Public source includes a [local proxy](local/Caddyfile), provider configuration examples and [operations/recovery guidance](../docs/backend-v2/operations.md). Host-specific scripts, credentials and private rollout evidence for the original AWS machine are excluded. Do not apply historical host-specific commands to a new machine.

Deployment requires isolated runtime/database roles, TLS routing for RPC/REST, private administrative ports, generated migrations **plus** tenant constraints, configured providers, backups/restore checks and bounded workers. See [setup](../docs/getting-started.md). The Caddy example is loopback-only development configuration; see [Caddy's reverse-proxy documentation](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy).
