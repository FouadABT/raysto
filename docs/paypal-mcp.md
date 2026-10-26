# PayPal MCP — Sandbox payment investigation

Raysto supports PayPal's official MCP server as a private stdio subprocess in
the backend. This is an actual MCP initialize → tools/list → tools/call exchange;
the official server performs the provider read. It does not expose a public MCP
port, receive messages directly from diners, or let AI execute payment writes.

## Why this transport

The original hosted `https://mcp.sandbox.paypal.com/http` path returned HTTP 404
in the deployed Dart client. An authenticated diagnostic from the AWS host
subsequently obtained a valid Sandbox OAuth token, but hosted `/http` and `/sse`
returned HTTP 403 / Cloudflare 1010 (`browser_signature_banned`). Those hosted
access failures are not claimed to be fixed. PayPal documents self-hosted stdio
as an alternative, so Raysto now supports that official option.

## Boundaries

- The package is `@paypal/mcp` 1.8.1 with a committed dependency lock, including
  `@paypal/agent-toolkit` 1.11.0. Node 24.19.0 is bundled for Raysto; Awhar and
  machine-wide SDKs are not changed.
- Startup explicitly selects Sandbox and only `orders.get,payments.getRefunds`.
  The actual advertised tool schemas are `get_order(id)` and
  `get_refund(refund_id)`. The client rejects incompatible schemas and write tools.
- OAuth tokens travel in the subprocess environment, never command-line
  arguments. The subprocess does not inherit backend secrets or provider debug
  settings. Its stderr is drained without forwarding provider data to logs.
- Actor, restaurant, checkout and configured merchant are authorized before a
  provider call. The model never supplies a PayPal ID directly. Response identity,
  currency, amount and merchant checks remain in the business service.
- The reader has a 15-second deadline, bounded stdout/stderr, a 128 MiB V8 heap
  setting and process cleanup. These supplement the Raysto service's resource
  limits; they are not a claim about maximum total native-process memory.
- A verified MCP read records `source=paypal_mcp` and `mcpTransport=stdio`.
  Transport/provider errors can use the existing authorized REST read, explicitly
  recorded as `source=paypal_rest` with a sanitized fallback reason.
- Reads never settle a bill. Checkout, capture, refund and reconciliation still
  use the guarded payment service and its allocation/idempotency rules.

## Verification and remaining work

Eighteen distinct focused Dart cases passed: seven existing/extended HTTP and
response checks, nine subprocess/configuration cases, and two assistant-fact
checks. The second run repeated the six HTTP cases and added the provider-error
case; this is not a full-suite total. Changed-source analysis reported no issues.

The official package's exact two-tool contract passed locally and inside the
final Linux image. No provider request is made by that offline contract check.
Backend **0.11.4** is deployed at `api.rays.to`; public readiness passed and the
Awhar process/configuration baseline remained unchanged. The release archive
`raysto-backend-0.11.4-linux-amd64.tar.gz` is 75,919,145 bytes, SHA-256:

```text
9303cd88b291f905ef1321a8ac093d9f49c6124a4ef14ecd33c6857325edcdfd
```

A private probe compiled from the same deployed Dart MCP client ran as the
Raysto service user on AWS. It read the existing checkout bound to the configured
Sandbox merchant and verified the provider ID, merchant, currency and amount:

| Field | Observed result |
| --- | --- |
| Source / transport | `paypal_mcp` / `stdio`, no REST fallback |
| Tool | `get_order` |
| Amount | USD 13.50 |
| Status | `PAYER_ACTION_REQUIRED` |
| Duration | 3,526 ms in this individual check |
| Financial mutation | None |

This confirms a real provider read through the deployed client and official MCP
server. It does not establish a completed payment or successful conversational
orchestration. Assistant runs 14, 15 and 16 timed out in the model path before a
completed MCP tool result; those failures are retained as integration evidence.

Actual buyer approval, capture, verified webhook delivery, a second payer,
partial refund and interrupted-payment recovery remain separate acceptance
gates. Two US Personal Sandbox accounts were shown as created; their credentials
or interactive buyer participation are still needed. See the
[buyer instructions](paypal-sandbox-buyers.md).

The upstream dependency audit is not clean. The initial lock reported 12 affected
package entries, including transitive advisories. Unused agent integrations and
the restrictions on the two loaded read tools are documented in the
[runtime review](../backend/raysto/raysto_server/paypal_mcp_runtime/README.md).
Review upstream patches before widening the integration beyond this Sandbox
reader; do not describe these checks as a general security certification.

## Deployment and recovery

Use the backend Dockerfile and `npm ci --ignore-scripts` with the pinned toolchain.
The build also runs `verify-contract.cjs`. Configure `RAYSTO_PAYPAL_MCP_TRANSPORT`,
`RAYSTO_PAYPAL_MCP_NODE` and `RAYSTO_PAYPAL_MCP_SCRIPT` as shown in
[the environment example](../backend/.env.example). The node executable must be
executable by the Raysto service user; the scripts/dependencies are read-only.

No schema migration is required. Back up Raysto, retain its previous release and
environment, switch only its service, then verify public readiness and a real
authorized MCP read. On failure restore the previous release/environment. Setting
`RAYSTO_PAYPAL_MCP_ENABLED=false` retains the clearly labelled REST status reader.
Do not replay or replace pending checkouts to diagnose MCP.

Sources: [PayPal MCP documentation](https://developer.paypal.com/ai-tools/mcp-server/),
[official server](https://github.com/paypal/paypal-mcp-server),
[official agent toolkit](https://github.com/paypal/agent-toolkit).
