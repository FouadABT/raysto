# Raysto Table Host — proposed next milestone

**Historical proposal, 26 October 2026.** Implementation has started shipping as the Road to 10/10 candidate. See [the release report](road-to-10-10.md) and [current status](project-status.md) for implemented behavior, checks and remaining gaps. This original design document is not a completion claim.

## Product promise

One shared place to decide what to eat, ask for service, follow the order and settle the bill. Familiar conversation behavior, with Raysto's own hospitality identity and clear actions.

The core demonstration is two diners with different preferences and a shared budget: join a visit, review a grounded AI basket, submit it, handle an unavailable item with approval, follow preparation, pay their shares through actual PayPal Sandbox, and see the same outcome in the restaurant workspace.

## Default audience

The main **Table room** includes admitted diners and the currently assigned waiter. Before joining and above the composer, show who can see messages: **Everyone at this table + your waiter**. List current staff and announce assignment changes. New staff may read the operational history necessary to take over; diners are told this when joining.

Provide a distinct **Private help** thread with authorized restaurant support for sensitive requests. It is private from other diners, not from the restaurant's authorized support team. Do not silently change a message's audience or move private text into the shared room.

An optional **Diners only** conversation can use the same membership model later. It should not be an additional empty channel everyone must navigate on day one. Privacy labels must state whether an explicitly invoked AI assistant receives the selected context; do not imply end-to-end encryption.

## Room rules and edge cases

| Situation | Proposed behavior |
| --- | --- |
| Dine-in | One room per active visit, not per permanent table. Multiple rounds remain in that room. |
| New party | New visit and room; no access to the previous party's messages or bill. |
| Table move | Preserve visit/room; update the table label and operational assignment. |
| Guest / later sign-in | Session proof admits the guest; explicit verified claiming transfers ownership without granting staff privileges. |
| Join/leave | QR identifies a table; a separate authorized admission grants visit access. Leaving does not erase purchased obligations or permit reading later messages. |
| Waiter change / no waiter | Announce reassignment. Route requests to the restaurant's service queue when no waiter is assigned; show actual pending/acknowledged state. |
| Kitchen | Receive structured tickets and relevant clarification, not everyone's personal conversation. |
| Delivery | Order-linked conversation with customer and restaurant; assigned courier gets only the necessary delivery channel/data. |
| Pickup | Order-linked conversation; no fictional dining table required. |
| Sensitive issue | Separate private-help audience; shared timeline gets only an explicitly approved, non-sensitive operational outcome. |
| Closed visit | Read-only permitted history and receipts; continued disputes/support go to their own thread. Retention/deletion policy still applies. |
| Offline / lost response | Pending/failed/retrying message states and stable IDs. No invented order confirmation or payment success. |

Restaurant policy can disable customer free-text while preserving structured service/order actions. Moderation, message limits and reporting belong in the core; voice calls, social feeds and general-purpose messaging do not.

## Mobile experience

- Discovery remains useful before a visit. During a visit, the active table is one tap away.
- Pin **Menu · Order · Bill** so essential tasks never require searching chat history.
- Use actionable cards for basket proposals, changed items, service requests, kitchen milestones and verified receipts.
- Keep quick actions for water/help/another round; free text is optional, not required to use the app.
- Preserve forest ink, warm paper, lime selections, original illustration and bounded motion. Respect reduced motion and larger text.
- Show a concise service timeline; collapse noisy background events instead of filling the room with bots.

## AI's role

Invoke **Ask Raysto** or `@Raysto` explicitly. Use authorized menu/availability data, diners' voluntarily shared preferences and budget. Unknown allergens remain unknown; absence of a flag is not a safety guarantee.

Return an editable proposal with item IDs, quantities, reasons, totals and fields needing attention. The backend requotes and binds approval to that exact revision. A menu change makes stale approval invalid. AI cannot capture payments, silently publish menus, issue refunds or treat a casual “yes” as authorization.

Translation retains the original message and identifies generated text. Private-help context is never automatically supplied to a shared-room answer.

## Payments and restaurant workspace

The bill card displays server-authoritative charges, allocations and remaining balance. Support whole bill, selected items and a custom amount. Reserve payable amounts and handle competing/uncertain attempts through existing backend rules. PayPal opens its actual Sandbox approval page; only verified provider evidence produces a paid receipt.

Keep mobile native Flutter. Build the connected manager workspace in the existing Next.js app: **table map + AG Grid + selected room**. Selecting a table/order filters the same records across the workspace. Restricted backend queries supply rows; grid input never becomes SQL.

For AG Studio, add useful custom widgets (table service state, outstanding bills, payment exceptions), coordinated filters and an agent that can answer **“Which tables requested the bill and still have a balance?”** with linked rows. Querying and drafting are distinct from sending messages or making financial changes. The [sponsor brief](https://paypalaihackathon.devpost.com/details/aggrid) emphasizes custom widgets, theming, layout and the Studio Agent Framework; a standalone decorative grid is a weaker fit. Check license/trial coverage through judging before integration.

## Implementation sequence and exit criteria

| Step | Deliverable | Evidence before moving on |
| --- | --- | --- |
| 1. Conversation domain | Visit/order rooms, membership, audiences, message/event IDs, moderation and retention. Preserve current support APIs. | Unauthorized participant/tenant access denied; a new visit cannot read old-party history. |
| 2. Connected delivery | Durable messages, pagination, reconnect/cursor recovery and current membership checks on streams. | Two diners and a waiter receive consistent updates; revoked access ends; retry does not duplicate messages. |
| 3. Native room | Audience header, rich cards, pinned actions, private help and bounded motion. | Join/order/service/leave work on devices; large text and reduced motion remain usable. |
| 4. Reviewed group AI | Menu-grounded budget/preference proposals, explicit consent and revision-bound approval. | Unavailable item and conflicting preferences produce a reviewable correction, not an invented order. |
| 5. Real Sandbox settlement | Bill allocation → real approval → capture → receipt → recovery/refund. | Actual buyer and merchant evidence, verified webhook and no duplicate settlement after retries. |
| 6. Connected AG workspace | Same backend records, table map/grid/room and focused AG Studio widgets/agent. | A native order/service/payment change appears under the correct restaurant and permissions. |
| 7. Submission polish | Focused regression, clean-checkout run, reviewer access, provenance and release notes. | Verified happy path and one meaningful recovery path; status docs match the final build. |

Build one complete dine-in journey first. The shared room model should support pickup, delivery and private help without requiring every secondary screen before the main journey works. The user owns demo-video production; engineering work supplies reliable behavior and evidence for it.

The target is strong evidence across implementation, design, impact, innovation and presentation. No design choice can guarantee a 10/10 score or first prize.
