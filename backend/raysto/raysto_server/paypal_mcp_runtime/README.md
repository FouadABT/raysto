# PayPal MCP runtime

Raysto runs PayPal's official `@paypal/mcp` 1.8.1 over stdio inside its own
backend service. `package-lock.json` also pins `@paypal/agent-toolkit` 1.11.0
and the resolved dependencies. Install with `npm ci --ignore-scripts`; never
download packages during a payment investigation. The backend Dockerfile
bundles Node 24.19.0 and this directory into `lib/paypal-mcp/`.

The process receives only a short-lived Sandbox OAuth token and minimal process
settings. Credentials are never command-line arguments. It opens no listening
port. Arguments always select `orders.get,payments.getRefunds` and Sandbox.
Raysto negotiates MCP, validates the two read-tool schemas, bounds output and
execution time, and closes the process after use. The assistant independently
authorizes the restaurant, actor, checkout and configured merchant before a
provider call; returned payment details are validated and minimized. This
reader cannot change the payment ledger.

Set `RAYSTO_PAYPAL_MCP_TRANSPORT=stdio`, `RAYSTO_PAYPAL_MCP_NODE` to the absolute
bundled Node executable, and `RAYSTO_PAYPAL_MCP_SCRIPT` to the absolute
`node_modules/@paypal/mcp/dist/index.js` path. See `backend/.env.example`.
For a container, substitute `/app` for `/opt/raysto/current`. The existing
`http` transport remains selectable. A failure falls back to the authorized
REST reader with `source=paypal_rest` and a sanitized reason; a successful
local MCP read records `source=paypal_mcp,mcpTransport=stdio`.

## Dependency review

The upstream package includes other agent integrations that this stdio entry
point does not load. The initial locked-tree npm audit on 26 October 2026
reported 12 affected package entries (7 high, 2 moderate, 3 low), including
transitive advisories. This is not a clean dependency audit. LangChain,
LangSmith and Vercel AI paths are unused. The loaded toolkit also imports
mathjs and Zod: expression evaluation is not available through these two
tools, and the only tool argument is a server-bound string of at most 100
characters. Untrusted arrays, expressions, schemas and free-form tool arguments
never reach them. Keep this runtime restricted to the isolated Sandbox reader;
reassess and update the upstream dependencies before widening its scope.

A read-only audit refresh on **27 October 2026** reported **13 affected package
entries: 12 high and one moderate**, with no critical entry. Advisory counts can
change without changing the lockfile. The loaded mathjs 14.9.1 and Zod 3.25.76
now have fixes outside the toolkit's declared compatible major ranges
(mathjs 15.2.0 and Zod 4.6.6). Forcing those incompatible majors without validating
the official toolkit is not treated as a repair. The selected order/refund
reader does not expose expression evaluation or user-supplied schemas. The
audit nevertheless remains an open dependency risk; live-money activation or
broader tool exposure requires an upstream-compatible update and reassessment.

Focused tests cover transport negotiation, schema rejection, write-tool
denial, isolated process environment, response IDs, malformed/oversized output,
unexpected exit and the 15-second deadline. Those fixture tests are not payment
evidence; record live provider acceptance separately.

`node verify-contract.cjs` checks the installed official package's negotiated
protocol and exact exposed tools without making a provider request. It also
runs during the backend container build; changed upstream schemas stop the build.

Sources: [official MCP documentation](https://developer.paypal.com/ai-tools/mcp-server/),
[official server source](https://github.com/paypal/paypal-mcp-server),
[official agent toolkit](https://github.com/paypal/agent-toolkit).
