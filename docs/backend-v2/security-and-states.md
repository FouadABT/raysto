# Permissions, transitions and invariants

These are implementation contracts and deferred acceptance requirements, not a security certification.

| Actor | Permitted scope | Sensitive boundaries |
|---|---|---|
| Guest | Own carts/orders, joined visits, booking, support | No staff membership, restaurant creation or privileged claims |
| Registered customer | Own records, favorites, verified-order reviews | Identity must match Firebase proof; revocation checked |
| Owner | Tenant configuration, operations, invitations, ownership and billing | MFA for ownership/payment settings/billing; owner safeguards |
| Manager | Menu, operations, reports, refunds, operational invitations | Cannot grant owner/manager privileges; recent auth for refunds |
| Waiter | Assigned tables/visits, service, assisted orders, authorized cash | No global menu or financial configuration; no foreign table access |
| Kitchen | Necessary menu availability and actionable ticket details | No addresses, ownership or financial mutations |
| Courier | Assigned active delivery, permitted transitions and consented location | No other courier's deliveries; location expires after five minutes |
| Platform admin | Explicit allowlisted identity, audited admin commands | MFA; no client-supplied admin role |

Tenant ownership is checked in domain services. The SQL supplement adds composite tenant relationships as defense in depth. Requester identity, active membership, assignment, current record version and lifecycle constraints are distinct checks. Public table QR resolution exposes table identification, not the active visit. Visit admission requires self-seating configuration, staff confirmation or an expiring invitation.

## Transition contracts

| Resource | Allowed progression | Failure handling |
|---|---|---|
| Restaurant | Draft → configured → published; pause/suspension | Existing settlements/refunds remain reachable |
| Menu | Editable draft → explicit atomic publish | Base menu revision conflict prevents stale publication |
| Visit | Active → closed → table reset | Closure requires resolved orders, service and balances |
| Reservation | Held → confirmed → arrived → seated | Expired hold, cancellation and no-show are separate |
| Waitlist | Waiting → offered → seated | Offer expiry, return to waiting, or leave |
| Order | AwaitingPayment → submitted → accepted → preparing → ready → served/collected/delivered → completed | Pre-accept cancellation; later reviewed request; rejection separately |
| Delivery | Unassigned → assigned → collected → outForDelivery → delivered | Issue records prior state; manager records resolution |
| Checkout | Reserved → creating → created/approved → capturing → completed | Uncertain holds allocation; safe local cancellation prevents later backend capture |
| Refund | Pending → completed / failed | Unknown provider result retains reserved refund amount |
| Subscription | Creating → approvalPending → active | Verified failure grace, suspension, cancellation or expiration |
| File | AwaitingUpload → quarantine → approved / rejected | Only sanitized approved menu images can publish |
| AI | Queued → running → review → approved | Cancelled/stale/failed proposals cannot publish |
| Job | Pending → leased running → done | Bounded backoff → dead letter → audited operator replay |

## Financial rules

- Amounts are integer minor units; EUR, USD, GBP only. No automatic conversion.
- A transaction reserves available charges before network work. One unresolved visit checkout is enforced by a unique active-visit pointer.
- Provider creation/capture requests use stable identifiers. The checkout is marked in flight before calling PayPal; cancellation cannot release an uncertain capture.
- Captures verify merchant, currency, total and Raysto reference. Unique checkout/capture/allocation keys prevent duplicate settlement.
- A new round has new charges and never changes a frozen pending checkout.
- Refund reservations include all nonfailed refund requests. Credits change obligation; refunds change collected money. Cancellation does not recreate debt when money is returned.
- Cash and online collections share the balance lock. Cash commission collection is disabled.
- A reversal is applied only through explicit audited administration backed by verified provider evidence. Disputes remain review cases until evidence supports a financial action.

## Abuse, files and AI

The v2 HTTP body reader enforces a limit during streaming: 128 KiB command, 256 KiB webhook, 8 MiB upload. The Raysto reverse proxy must enforce matching limits for RPC before buffering. Actor limits, guest creation limits, menu/document bounds and a two-worker lease gate constrain cost and concurrency. Public routes need the documented edge IP limits.

App Check verifies RS256 signature, issuer, audience, expiry and allowed application ID. It supplements identity and object permissions. App Check token-consumption/replay protection is not claimed for this Dart implementation.

Uploads require an intent and digest. Scanner execution is a fixed administrator-configured executable with fixed arguments, without a shell. Images have pixel/frame limits; PDFs have page/encryption limits. Run parsers in a resource-restricted Raysto service. The model receives no tools or credentials, and prices/IDs are validated again by the backend. Missing extracted prices/allergens remain unknown for human correction.

## Deferred evidence

Static source analysis cannot prove tenant isolation, timing safety, correct real-provider handling or operating-system resource isolation. The acceptance matrix includes these runtime checks. Keep live payments disabled until its gates pass.
