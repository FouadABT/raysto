# Business capability to implementation

This is source traceability, not runtime acceptance evidence. Exact command/read inventory is in [capability-index.md](capability-index.md); field definitions are in [data-dictionary.md](data-dictionary.md).

| Business capability | Command/read families | Authoritative models and boundary |
|---|---|---|
| Identity, guests, profiles and privacy | `auth/*`, `identity.*`, `me`, `exports` | ActorProfile, SecurityGrant, existing FirebaseAccount/auth tables; guest claims transfer personal ownership only |
| Restaurant onboarding and publication | `restaurant.*`, `storefront` | Restaurant, RestaurantPolicy, Membership; operational settings checked before publication |
| Hours, modes, taxes, capacity and delivery areas | `restaurant.configure`, `availability`, `quote.create` | RestaurantPolicy; timezone, cutoffs and capacity checked again under tenant lock |
| Categories, variants, modifiers, allergens and menu versions | `menu.*`, `menu`, `storefront` | MenuProduct, MenuDefinition, MenuDraft; complete draft publication is atomic |
| Discovery, favorites and verified reviews | `discovery`, `favorite.*`, `review.*`, `favorites` | PostgreSQL search indexes, CustomerFavorite, CustomerReview; completed-order proof and moderation |
| Floor plans, zones, tables and public QR | `floor.*`, `table.*`, `floor`, `table.resolve` | FloorLayout, DiningTable; QR only resolves public identity |
| Visits, participants, service and table turnover | `visit.*`, `service.*`, `visit`, `services` | DiningVisit, VisitParticipant, AccessInvitation, VisitRequest; one active visit and explicit reset |
| Carts, pricing, coupons and immutable purchases | `cart.*`, `quote.create`, `order.submit` | CustomerCart, PriceQuote, OrderContext, PurchaseOrder, frozen OrderLine; minor-unit prices and stock reservations |
| Orders, cancellation and kitchen | `order.*`, `kitchen.*`, `orders`, `order`, `kitchen` | PurchaseOrder, OrderContext, KitchenProgress, AuditRecord; guarded fulfillment transitions separate from money |
| Pickup and restaurant delivery | `availability`, `delivery.*`, `delivery`, `delivery.tracking` | OrderContext slot keys, DeliveryAssignment; assigned courier only and expiring consented location |
| Reservations, holds and waitlist | `reservation.*`, `waitlist.*`, `reservations`, `waitlist` | DiningReservation, DiningWaitlist; timed holds and atomic seating |
| Merchant onboarding and checkout | `merchant.*`, `payment.allocate`, `payment.checkout`, `payment.capture` | MerchantConnection, CheckoutIntent, BillCharge, PaymentAllocation, PaymentCapture; verified merchant and frozen balance |
| Cash, partial refunds, disputes and recovery | `payment.refund`, `payment.exceptions`, `admin.paymentException`, `admin.reconcileRefund` | PaymentRefund, PaymentException, ProviderInbox; credits and collected money remain distinct |
| Subscriptions, commission and revenue | `admin.plan`, `billing.*`, `billing.history`, `admin.revenue`, `report` | RestaurantPlan, RestaurantSubscription, BillingHistory, CommissionEntry; separate subscription merchant and currency totals |
| Team invitations, limits and ownership | `team.*`, `team` | Membership, AccessInvitation, SecurityGrant, AuditRecord; operational-role boundaries and MFA ownership transfer |
| Inbox, email, push, support and abuse | `support.*`, `notification.*`, `support.inbox`, `notifications` | UserNotification, SupportConversation, SupportMessage, PlatformJob, DeviceToken; authorized attachments and preferences |
| Private uploads and approved publication | `media.*`, binary upload/read | MediaAsset plus private Storage; digest/size limits, quarantine, scanner and sanitized images |
| Menu extraction/generation/translation and assistant | `ai.*`, `ai` | AiOperation, MenuDraft, MediaAsset; quotas, fixed Gemini adapter, exact revision approval, fresh quote before purchase |
| Operations, reporting and administration | `report`, `admin.*`, `/health`, `/ready` | AuditRecord, PlatformJob, MutationReceipt, ProviderInbox, RateWindow; bounded reads, leases and audited recovery |
| Dart and future web integration | `platform` RPC, `/api/v2/`, generated SDKs | Shared domain services; legacy write adapters reject v2-owned records; no frontend implementation in this phase |

Security acceptance and concurrent execution are defined in [acceptance.md](acceptance.md). Operational installation, backups, recovery and rollback are in [operations.md](operations.md). Every external provider path remains subject to its separate configuration and deferred acceptance gate.
