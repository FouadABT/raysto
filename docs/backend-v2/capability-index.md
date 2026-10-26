# Capability and implementation index

Generated command/query inventory. Each command uses shared authorization, SQL transactions and idempotency. External side effects are reconciled separately.

| Operation | Service | REST path |
|---|---|---|
| `admin.paymentException` | `SettlementModule.resolve` | `/api/v2/commands/admin.paymentException` |
| `admin.plan` | `OperationsModule.plan` | `/api/v2/commands/admin.plan` |
| `admin.reconcileRefund` | `SettlementModule.reconcileRefund` | `/api/v2/commands/admin.reconcileRefund` |
| `admin.replayJob` | `OperationsModule.replay` | `/api/v2/commands/admin.replayJob` |
| `admin.suspend` | `OperationsModule.suspend` | `/api/v2/commands/admin.suspend` |
| `ai.approve` | `AiModule.approve` | `/api/v2/commands/ai.approve` |
| `ai.cancel` | `AiModule.cancel` | `/api/v2/commands/ai.cancel` |
| `ai.start` | `AiModule.start` | `/api/v2/commands/ai.start` |
| `assistant.approve` | `AssistantModule.approve` | `/api/v2/commands/assistant.approve` |
| `assistant.cancel` | `AssistantModule.cancel` | `/api/v2/commands/assistant.cancel` |
| `assistant.start` | `AssistantModule.start` | `/api/v2/commands/assistant.start` |
| `billing.cancel` | `OperationsModule.cancelSubscription` | `/api/v2/commands/billing.cancel` |
| `billing.refresh` | `OperationsModule.refreshSubscription` | `/api/v2/commands/billing.refresh` |
| `billing.subscribe` | `OperationsModule.subscribe` | `/api/v2/commands/billing.subscribe` |
| `cart.save` | `OrderingModule.saveCart` | `/api/v2/commands/cart.save` |
| `delivery.assign` | `OrderingModule.assignCourier` | `/api/v2/commands/delivery.assign` |
| `delivery.location` | `OrderingModule.location` | `/api/v2/commands/delivery.location` |
| `delivery.transition` | `OrderingModule.delivery` | `/api/v2/commands/delivery.transition` |
| `favorite.set` | `OperationsModule.favorite` | `/api/v2/commands/favorite.set` |
| `floor.save` | `DiningModule.saveFloor` | `/api/v2/commands/floor.save` |
| `identity.claim` | `IdentityModule.claim` | `/api/v2/commands/identity.claim` |
| `identity.claimTicket` | `IdentityModule.claimTicket` | `/api/v2/commands/identity.claimTicket` |
| `identity.privacy` | `IdentityModule.privacy` | `/api/v2/commands/identity.privacy` |
| `identity.profile` | `IdentityModule.profile` | `/api/v2/commands/identity.profile` |
| `identity.revokeSessions` | `IdentityModule.revokeSessions` | `/api/v2/commands/identity.revokeSessions` |
| `identity.stepUp` | `IdentityModule.stepUp` | `/api/v2/commands/identity.stepUp` |
| `kitchen.progress` | `OrderingModule.kitchen` | `/api/v2/commands/kitchen.progress` |
| `media.publish` | `AiModule.publishMedia` | `/api/v2/commands/media.publish` |
| `media.upload` | `AiModule.upload` | `/api/v2/commands/media.upload` |
| `menu.availability` | `CatalogueModule.availability` | `/api/v2/commands/menu.availability` |
| `menu.draft` | `CatalogueModule.draft` | `/api/v2/commands/menu.draft` |
| `menu.publishDraft` | `CatalogueModule.publishDraft` | `/api/v2/commands/menu.publishDraft` |
| `menu.save` | `CatalogueModule.saveItem` | `/api/v2/commands/menu.save` |
| `merchant.connect` | `MoneyModule.connectMerchant` | `/api/v2/commands/merchant.connect` |
| `merchant.refresh` | `MoneyModule.refreshMerchant` | `/api/v2/commands/merchant.refresh` |
| `notification.update` | `OperationsModule.notification` | `/api/v2/commands/notification.update` |
| `operations.archiveThread` | `WorkspaceModule.archiveThread` | `/api/v2/commands/operations.archiveThread` |
| `operations.layout` | `WorkspaceModule.saveLayout` | `/api/v2/commands/operations.layout` |
| `order.cancel` | `OrderingModule.cancel` | `/api/v2/commands/order.cancel` |
| `order.transition` | `OrderingModule.transition` | `/api/v2/commands/order.transition` |
| `payment.cancel` | `MoneyModule.cancel` | `/api/v2/commands/payment.cancel` |
| `payment.capture` | `MoneyModule.capture` | `/api/v2/commands/payment.capture` |
| `payment.checkout` | `MoneyModule.checkout` | `/api/v2/commands/payment.checkout` |
| `reservation.create` | `DiningModule.reserve` | `/api/v2/commands/reservation.create` |
| `reservation.transition` | `DiningModule.reservationTransition` | `/api/v2/commands/reservation.transition` |
| `restaurant.configure` | `CatalogueModule.configure` | `/api/v2/commands/restaurant.configure` |
| `restaurant.create` | `IdentityModule.createRestaurant` | `/api/v2/commands/restaurant.create` |
| `restaurant.publish` | `CatalogueModule.publish` | `/api/v2/commands/restaurant.publish` |
| `review.moderate` | `OperationsModule.moderateReview` | `/api/v2/commands/review.moderate` |
| `review.save` | `OperationsModule.review` | `/api/v2/commands/review.save` |
| `room.host` | `ConversationModule.host` | `/api/v2/commands/room.host` |
| `room.message` | `ConversationModule.send` | `/api/v2/commands/room.message` |
| `room.open` | `ConversationModule.open` | `/api/v2/commands/room.open` |
| `room.preferences` | `ConversationModule.preferences` | `/api/v2/commands/room.preferences` |
| `room.read` | `ConversationModule.read` | `/api/v2/commands/room.read` |
| `room.report` | `ConversationModule.report` | `/api/v2/commands/room.report` |
| `room.split.reset` | `EqualShares.reset` | `/api/v2/commands/room.split.reset` |
| `service.create` | `DiningModule.request` | `/api/v2/commands/service.create` |
| `service.transition` | `DiningModule.transitionRequest` | `/api/v2/commands/service.transition` |
| `support.message` | `OperationsModule.message` | `/api/v2/commands/support.message` |
| `support.open` | `OperationsModule.openConversation` | `/api/v2/commands/support.open` |
| `support.transition` | `OperationsModule.supportTransition` | `/api/v2/commands/support.transition` |
| `table.reset` | `DiningModule.resetTable` | `/api/v2/commands/table.reset` |
| `table.save` | `DiningModule.saveTable` | `/api/v2/commands/table.save` |
| `team.accept` | `IdentityModule.accept` | `/api/v2/commands/team.accept` |
| `team.invite` | `IdentityModule.invite` | `/api/v2/commands/team.invite` |
| `team.membership` | `IdentityModule.membership` | `/api/v2/commands/team.membership` |
| `team.transfer` | `IdentityModule.transfer` | `/api/v2/commands/team.transfer` |
| `visit.close` | `DiningModule.close` | `/api/v2/commands/visit.close` |
| `visit.invite` | `DiningModule.invite` | `/api/v2/commands/visit.invite` |
| `visit.join` | `DiningModule.join` | `/api/v2/commands/visit.join` |
| `visit.leave` | `DiningModule.leave` | `/api/v2/commands/visit.leave` |
| `visit.move` | `DiningModule.move` | `/api/v2/commands/visit.move` |
| `waitlist.join` | `DiningModule.waitlistJoin` | `/api/v2/commands/waitlist.join` |
| `waitlist.transition` | `DiningModule.waitlistTransition` | `/api/v2/commands/waitlist.transition` |
| `quote.create` | Typed `CreateQuote` | `/api/v2/commands/quote.create` |
| `order.submit` | Typed `SubmitOrder` | `/api/v2/commands/order.submit` |
| `visit.start` | Typed `StartVisit` | `/api/v2/commands/visit.start` |
| `payment.allocate` | Typed `AllocatePayment` | `/api/v2/commands/payment.allocate` |
| `payment.refund` | Typed `RequestRefund` | `/api/v2/commands/payment.refund` |

Read queries: `admin.financialCases`, `admin.jobs`, `admin.paymentExceptions`, `admin.revenue`, `admin.reviews`, `ai`, `ai.jobs`, `assistant.run`, `availability`, `billing`, `billing.history`, `cart`, `checkout`, `checkouts`, `deliveries`, `delivery.tracking`, `discovery`, `exports`, `favorites`, `floor`, `kitchen`, `me`, `media`, `menu.drafts`, `menu.manage`, `notifications`, `operations.snapshot`, `operations.threads`, `order`, `orders`, `payment.exceptions`, `report`, `reservations`, `restaurant.manage`, `reviews.manage`, `room`, `room.events`, `services`, `storefront`, `support`, `support.inbox`, `table.resolve`, `team`, `visit`, `visits`, `waitlist`.

Schemas are in [data-dictionary.md](data-dictionary.md); release limitations and deferred gates are in [README.md](README.md).
