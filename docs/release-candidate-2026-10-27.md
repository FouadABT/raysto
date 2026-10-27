# Connected candidate — 27 October 2026

This is a test candidate, not the completed judging release. Backend/console
deployment, source checks, provider observations and physical-device acceptance
are separate claims. See [current status](project-status.md).

**Deployed:** backend and console `0.11.6` on the existing Raysto services.
Public readiness and authenticated diner-room/manager reads passed. Previous
releases and a Raysto database backup were retained. No migration, Awhar service
change or shared PostgreSQL upgrade was performed; the Awhar process/configuration
baseline matched before and after activation.

## Changes

- Mobile rooms group consecutive activity for the same record while preserving
  original history, messages and unread boundaries. Service and payment cards
  show meaningful state, amounts and next steps. Waiter acknowledgement remains
  distinct from message delivery.
- Expired proposals cannot be approved from the card. A retryable assistant
  failure can restore the question to the composer's draft for review; it never
  automatically makes another paid request or overwrites unfinished text.
- Gemini uses bounded streaming responses. Only a complete final result can
  release tool calls; provider signatures and usage survive assembly. Capacity,
  timeout, configuration and malformed responses have distinct safe errors.
  A timed-out generation closes its own connection without closing the shared
  Google authentication transport used by Firebase operations.
- “Did my last PayPal payment finish?” can resolve the requesting diner's latest
  checkout in the current authorized room. An explicit checkout ID must belong
  to that room too. Cancelled attempts report Raysto's local history explicitly;
  they do not pretend to be fresh PayPal confirmations or infer settlement from
  a missing provider record.
- Console reload restores the selected table and records tab along with the
  shared filter. The server rejects selections outside the restaurant. Raysto's
  general control styles are isolated from AG Studio/Grid's internal controls.

## Focused verification

Twenty distinct selected checks passed: seven Gemini transport tests, three
assistant-fact tests, eight isolated conversation/domain tests and two Flutter
room tests. This counts each case once, not every rerun. Coverage includes
truncated tool responses, tenant/room-scoped payment lookup, saved-table
authorization, message grouping and the 320px / 2× text / open-keyboard layout.
Changed-source analysis, TypeScript, Linux release builds and the Android
candidate build passed. No full-suite, load or iOS claim is made.

The deployed console restored **Ready to settle**, **Garden 1**, **Payments** and
the authorized table conversation after reload. Its $27 outstanding total is
unpaid QA debt. [Browser capture](screenshots/story/operations-recovery.png).
The [AG Studio controls capture](screenshots/story/operations-studio-controls.png)
shows the corrected toolbar/gallery styling on the deployed console.

## Provider observations

| Observation | Result and limit |
| --- | --- |
| Fresh official PayPal MCP read | The deployed Dart MCP implementation, running as the Raysto user, verified a fresh USD 1.00 Sandbox order through `get_order` over stdio in 2,737 ms. Status: `PAYER_ACTION_REQUIRED`; no REST fallback or ledger mutation. |
| Probe cleanup | The unapproved $1 checkout was cancelled through Raysto's guarded command. No buyer approved it and no capture or refund was performed. |
| Old checkout | Its PayPal resource was unavailable; Raysto already recorded the checkout as cancelled. A provider 404 alone never authorizes a replacement payment or allocation release. |
| Gemini transport | A synthetic streaming request completed in about 17.3 seconds. This establishes one transport response, not assistant reliability. |
| Assistant runs 18–20 | Run 18 encountered the old provider resource and then reached its model deadline. Runs 19 and 20 received HTTP 429 before completing an MCP tool call. These failed attempts remain in the evidence. |
| Google diagnostic | A bounded synthetic request returned HTTP 429, `RESOURCE_EXHAUSTED`, “Resource exhausted. Please try again later.” The response did not identify a specific project quota. No region/model switch or unbounded retry was performed. |

Complete Gemini → MCP conversation acceptance remains **pending**, despite the
successful direct MCP read. Two real buyer approvals/captures, verified webhooks,
refund-detail MCP, partial refund and interrupted-return recovery are also
pending. [MCP implementation and limits](paypal-mcp.md).

After cleanup, the QA ledger reported **2,700 minor units outstanding, zero
reserved, zero settled and zero captures**. The development AI ledger recorded
**USD 2.850219** conservatively charged and no outstanding reservation against
its $35 limit. This includes failed/diagnostic requests and is application
accounting, not the Google invoice; the separate $15 reviewer allowance remains
reserved for reviewer work.

The upstream MCP dependency audit remains non-clean: on October 27 the pinned
tree reported 13 affected package entries (12 high, one moderate). This includes
transitive entries and is not 13 independently reachable application exploits.
The two-tool isolation reduces exposure; it does not replace dependency repair.
See the [runtime review](../backend/raysto/raysto_server/paypal_mcp_runtime/README.md).

## Android handoff

`raysto-0.11.5-2014-android-arm64.apk` — 46,132,761 bytes.
Package `com.gmrt.raysto`, version `0.11.5+2014`, min SDK 24, target SDK 36.
Built for the ARM64 test target with development signing; not a Play release.

SHA-256:

```text
d507b703c114830b5162b9820f586d5d2315111a00e159281d0d73ddea2e8860
```

The owner receives the APK through the local handoff. A final public release
asset/tag follows acceptance; this document does not imply that an APK has been
published to GitHub Releases. Existing backend contracts remain compatible.

Deployment archive checksums (SHA-256):

```text
730f6acb2fba1e958c757943bd7c07fb8d25819784e26f1ea6e4b8f7fdf19c1e  raysto-backend-0.11.6-linux-amd64.tar.gz
db69343eae1431ddcf0cc30a1ad182e19e2c2687ea25c9be011dcbbb60150052  raysto-ops-0.11.6-linux-x64.tar.gz
```

Archives contain 75,925,979 and 75,450,984 bytes respectively. They are private
deployment artifacts, not substitutes for clean-checkout reproduction. Rollback
uses the retained `0.11.5` release links for each Raysto service, followed by
readiness and authenticated-read checks. No financial history is removed.

## Remaining participation and gates

1. Owner supplies only the local path to the two Personal Sandbox buyers'
   credentials file, or personally approves the two checkouts. The accounts
   exist; their creation is not evidence of payment.
2. Owner arranges the Android phone, two diners and waiter for Google sign-in,
   push and the shared-visit journey. Follow the
   [device and pilot checklist](device-and-pilot-checklist.md).
3. AG Studio extension remains pending: the supplied key expires December 10;
   reviewer coverage needs December 15.
4. Resume the fixed [AI evaluation](ai-evaluation.md) when the provider accepts
   requests. Report both failures and successful cases, not a selected success
   rate. Keep the $35 development / $15 reviewer budget split.
5. Record the three recruited pilot sessions, clean-checkout reproduction and
   final reviewer artifacts. The [pilot sheet](pilot-results.csv) has no invented
   results. The owner produces the video after the journey is dependable.

Source for the capacity interpretation:
[Google's 429 guidance](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/deploy/error-code-429).
