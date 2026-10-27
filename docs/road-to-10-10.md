# Road to 10/10 — integration candidate

**Updated 27 October 2026.** The target is strong evidence across implementation, design, impact, innovation and presentation, not a predicted judging score. [Current status](project-status.md) is the release authority. The [October 27 candidate report](release-candidate-2026-10-27.md) records the new APK, grouped mobile cards, workspace recovery, fresh MCP read, Google capacity failures and participation checklist. Earlier observations below are preserved as historical evidence.

## The connected journey

Staff admits a party to a visit. Two diners and the assigned waiter share its room; private help stays separate. Gemini reads authorized menu/preferences and proposes a server-priced basket. The host approves its exact revision before submitting. Each payer reviews their own frozen share and opens actual PayPal Sandbox approval. Verified capture/reconciliation updates the ledger and restaurant workspace. New rounds remain outside an existing split; uncertain attempts retain their reservations.

API-level evidence covers room membership, real Gemini basket/share proposals, explicit host order submission and an unapproved PayPal checkout. The full physical-device, buyer-to-refund journey remains pending.

[Current system map](backend-v2/maps/conversation-architecture.png) · [SVG](backend-v2/maps/conversation-architecture.svg) · [editable Mermaid](backend-v2/maps/conversation-architecture.mmd).

## Source and contracts

| Capability | Main source |
| --- | --- |
| Rooms, audiences, messages, reports and stream authorization | `backend/raysto/raysto_server/lib/src/platform/conversations.dart` |
| Gemini tools and reviewed actions | `…/platform/assistant.dart` |
| $35 development + $15 review allowance | `…/platform/ai_budget.dart` |
| Frozen equal shares and guarded settlement | `…/platform/shares.dart`, `money.dart` |
| Official stdio / Streamable HTTP MCP and strict read-tool schemas | `…/services/paypal_mcp_client.dart`, `…/paypal_mcp_runtime/` |
| Manager snapshots/layouts | `…/platform/workspace.dart` |
| Unbuffered bounded event response | `…/web/event_response.dart` |
| Native conversation and proposal approval | `lib/features/connected/room.dart` |
| AG Grid/Studio, custom widgets and harness | `web/src/components/connected/`, `web/src/lib/connected/` |

Additive migration: `20261026164954486`. Tenant/financial constraints: `backend/operations/conversation-constraints.sql`. [OpenAPI](backend-v2/openapi.json), [dictionary](backend-v2/data-dictionary.md) and [capability index](backend-v2/capability-index.md) are regenerated from source. Resource aliases add `/api/v2/rooms/`, `/assistant/` and `/operations/`; existing generic commands remain compatible.

Every tool authorizes actor, tenant and record independently. AI cannot capture, refund or publish. Four model rounds, eight tool calls and a 30-second execution deadline bound runs. Complete read-only payment/dashboard facts can be rendered directly from validated tool results without another model paraphrase. Unknown provider usage retains its conservative budget reservation; application accounting does not guarantee the provider invoice.

Only `get_order` and `get_refund` may cross MCP; provider IDs come from authorized records. Writes remain guarded REST operations. Direct Sandbox is explicitly limited to one test restaurant with zero commission. Marketplace, subscription and standalone test configuration remain separate; live money is disabled.

## Observed checks

| Check | Result |
| --- | --- |
| Two diners + waiter; unrelated account | Same persisted room message; unrelated read denied |
| Retried message ID | One stored message |
| Waiter removed during live stream | Access ended and new read denied in 2.074 s; QA membership restored |
| Public SSE first frame | 1.469 / 1.642 s, after fixing a 34-second buffering defect |
| Real Gemini group budget | $27 vegetarian quote under $30; four tools; unknown allergens flagged |
| Host approval | Reviewed quote submitted as a pay-at-end Sandbox order |
| Real Gemini equal split | Frozen $13.50 share for each of two diners |
| Checkout recovery | Same checkout resumed after fixing missing return URLs; actual PayPal Sandbox handoff |
| Remote MCP | Access/protocol errors; no successful runtime read claimed. REST fallback reached PayPal |
| Self-hosted official MCP, backend 0.11.4 | The same deployed Dart client read the existing USD 13.50 checkout through official stdio MCP as the Raysto service user, validated merchant/amount, and returned `PAYER_ACTION_REQUIRED` in 3.526 s without fallback or ledger changes. [Detailed evidence and limitations](paypal-mcp.md). |
| Conversational payment check on 0.11.4 | Runs 14–16 timed out in Gemini's model stage before a completed MCP tool result. The direct MCP check passed; complete chat acceptance remains open. |
| Payment-status assistant after correction | Completed run with `PAYER_ACTION_REQUIRED`, USD 13.50 and explicit REST fallback attribution; no paid-ledger mutation |
| Console | Real QA Firebase login, table/room/service request and $27 balance displayed in AG workspace |
| Manager assistant | Selected the bill-requested/unpaid table; browser displayed the completed tool and USD 27 explanation after correcting AG Studio message-part rendering |
| Console recovery | Saved filter/panels and persisted assistant conversation recovered after reload; table-specific order grid showed the same unpaid USD 27 order |
| Impossible budget | Real menu read correctly rejected a $1 meal for two instead of inventing prices |
| Privacy injection | Refused a request for another restaurant's private support/payment credentials; no tool executed |
| Unknown allergens / French | English-locale run preserved unknown allergens but answered in English; the French-locale run answered in French and requested staff clarification |

These are individual checks, not load benchmarks or pilot findings. The restaurant/menu/accounts are explicitly labelled QA fixtures. Raw tokens, provider payloads and credentials stay outside public source.

Browser evidence: [manager assistant and AG Studio widgets](screenshots/story/operations-assistant.png) · [connected order and table room](screenshots/story/operations-connected.png). Both show real hosted QA records; the unpaid state is intentional while buyer approvals are pending.

The application budget ledger recorded USD **1.020369** spent and no outstanding reservation after the French-locale check, before the final manager-display recheck on October 26. This includes conservatively reserved failed runs; it is an application accounting observation, not the Google invoice. The development cap remains $35, with $15 reserved for review.

Focused validation comprised 36 selected backend checks, then one event-transport and two factual-summary checks, plus six selected Flutter checks. These are distinct targeted runs, not a single full-suite claim. TypeScript, Linux backend, console and Android compilation completed. The pinned mobile actions passed the 320px, 2× text, open-keyboard check. Earlier provider deadline failures motivated Google credential-transport reuse and direct rendering of complete verified tool facts; the subsequent payment-status run completed. A full AI reliability evaluation remains pending.

## Build and rollout

Use pinned toolchains/lockfiles in [setup](getting-started.md), `backend/.env.example`, the platform configuration example and `web/.env.example`. Supply your own Firebase app/domain and valid AG Studio license. The current evaluation key expires December 10; an extension through December 15 is pending.

`tool/check_conversations.ps1` runs focused backend checks against the isolated localhost:61810 cluster only. Additional changed-path checks are `event_response_test.dart` and `assistant_facts_test.dart`. Mobile checks are `table_room_test.dart` and `platform_mobile_test.dart`. Never run tests against the shared production cluster.

Build backend from `backend/raysto` with its Dockerfile. Build `web/Dockerfile` with a BuildKit `ops_env` secret; never deploy `.env.local`. Android candidate command:

```sh
flutter build apk --release --target-platform android-arm64 --dart-define=RAYSTO_API_URL=https://api.rays.to/
```

Current local artifact: `raysto-0.11.5-2014-android-arm64.apk` (development signing, direct testing only). SHA-256:

```text
d507b703c114830b5162b9820f586d5d2315111a00e159281d0d73ddea2e8860
```

1. Back up Raysto database/runtime and capture previous links plus Awhar service/configuration fingerprints.
2. Install in a new Raysto directory. Copy environment-specific production configuration; never package credentials.
3. Apply the generated migration with the migrator role, then both platform and conversation constraint supplements. Preserve supplemental tenant constraints; do not run destructive automatic schema repair to silence their comparison warnings.
4. Configure feature flags, explicit Sandbox tenant, dedicated webhook, current AI prices and both `PAYPAL_V2_RETURN_URL` / `PAYPAL_V2_CANCEL_URL`.
5. Atomically switch only Raysto's link/service; check local/public readiness and unauthorized rejection. Console has its own service/link/loopback port. Do not change Awhar or the shared PostgreSQL major version.
6. On failure restore the previous link/runtime. Additive tables remain; never delete financial records to reverse deployment. Disable new feature flags if rolling back before their source existed.
7. Reconcile existing provider IDs before replay. A timeout never authorizes a replacement checkout. Preserve audit history and idempotency keys.

Prior releases and local backups are retained. Off-host restore rehearsal, alert routing and load measurements remain pending. The final tag/reviewer artifact should follow acceptance, not disguise this candidate as a finished submission.

## Remaining acceptance

- Two Personal Sandbox buyers approve/capture their shares; verify webhook, matching balances, partial refund and interrupted-return recovery. [Buyer instructions](paypal-sandbox-buyers.md).
- Conversational payment-status acceptance after Gemini timeouts/capacity errors. Direct MCP reads passed for the earlier $13.50 share and a fresh $1 probe; hosted MCP access remains blocked and refund-detail acceptance awaits a refund.
- Fixed AI evaluation: budget ordering, conflicting preferences, unknown allergens, stale availability, French/Arabic input, privacy injection, payment status, cancellation and exhausted allowance. Keep failed attempts in the record.
- Physical-device Google sign-in, guest admission, coordinated console/mobile activity and notification. Browser filter/table/tab/room recovery passed. Grouped service/payment cards are implemented with focused layout/grouping checks; physical-device review remains pending.
- Three short restaurant/diner pilots: record party size, experience, manual/assisted task order, decision time, corrections, staff clarifications, settlement success and audience/approval comprehension. Obtain permission before recording/quoting; report the small sample and learning effects. No pilot findings exist yet.
- AG trial extension, clean-checkout reproduction and final reviewer release. iOS, voice, live marketplace, commercial subscriptions and public web ordering remain separate milestones.

References: [PayPal MCP](https://developer.paypal.com/ai-tools/mcp-server/), [agent tools](https://developer.paypal.com/ai-tools/agent-tools/), [Gemini guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/guides/gemini-3-8-flash), [AG custom harness](https://www.ag-grid.com/studio/react/ai-custom-harness/).
