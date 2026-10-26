# Data dictionary

Generated from authored `.spy.yaml` models. Money is integer minor units; dates are UTC. JSON fields are validated by the owning domain module. PostgreSQL owns business state.

## AccessInvitation

Table: `raysto_access_invitation`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `kind` | `String` |
| `targetId` | `int` |
| `tokenHash` | `String` |
| `createdBy` | `String` |
| `recipientEmail` | `String?` |
| `role` | `String?` |
| `expiresAt` | `DateTime` |
| `usesRemaining` | `int` |
| `revoked` | `bool` |
| `createdAt` | `DateTime` |

## ActorProfile

Table: `raysto_actor_profile`

| Field | Type |
|---|---|
| `userId` | `String` |
| `firebaseUid` | `String?` |
| `isGuest` | `bool` |
| `disabled` | `bool` |
| `claimedBy` | `String?` |
| `dataJson` | `String` |
| `version` | `int` |
| `createdAt` | `DateTime` |
| `updatedAt` | `DateTime` |

## AiOperation

Table: `raysto_ai_operation`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `kind` | `String` |
| `mediaId` | `int?` |
| `inputJson` | `String` |
| `outputJson` | `String?` |
| `status` | `String` |
| `menuVersion` | `int` |
| `version` | `int` |
| `inputTokens` | `int` |
| `outputTokens` | `int` |
| `expiresAt` | `DateTime` |
| `createdAt` | `DateTime` |

## AiSpendBudget

Table: `raysto_ai_spend_budget`

| Field | Type |
|---|---|
| `stage` | `String` |
| `limitMicros` | `int` |
| `reservedMicros` | `int` |
| `spentMicros` | `int` |

## AiSpendEntry

Table: `raysto_ai_spend_entry`

| Field | Type |
|---|---|
| `sourceKey` | `String` |
| `stage` | `String` |
| `reservedMicros` | `int` |
| `chargedMicros` | `int` |
| `settled` | `bool` |
| `createdAt` | `DateTime` |

## AllocatePayment

Transport model.

| Field | Type |
|---|---|
| `requestKey` | `String` |
| `restaurantId` | `int` |
| `visitId` | `int?` |
| `orderId` | `int?` |
| `amountMinor` | `int?` |
| `lineKeys` | `List<String>?` |
| `shares` | `List<ChargeShare>?` |
| `assistantProposalId` | `int?` |
| `method` | `String` |

## AssistantProposal

Table: `raysto_assistant_proposal`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `roomId` | `int?, relation(parent=raysto_conversation_room)` |
| `runId` | `int, relation(parent=raysto_assistant_run)` |
| `userId` | `String` |
| `kind` | `String` |
| `payloadJson` | `String` |
| `contextHash` | `String` |
| `status` | `String` |
| `version` | `int` |
| `expiresAt` | `DateTime` |
| `createdAt` | `DateTime` |

## AssistantRun

Table: `raysto_assistant_run`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `roomId` | `int?, relation(parent=raysto_conversation_room)` |
| `userId` | `String` |
| `requestKey` | `String` |
| `status` | `String` |
| `inputJson` | `String` |
| `outputJson` | `String` |
| `traceJson` | `String` |
| `reservedMicros` | `int` |
| `chargedMicros` | `int` |
| `budgetStage` | `String` |
| `version` | `int` |
| `createdAt` | `DateTime` |
| `completedAt` | `DateTime?` |

## AuditRecord

Table: `raysto_audit_record`

| Field | Type |
|---|---|
| `restaurantId` | `int?` |
| `userId` | `String` |
| `requestKey` | `String` |
| `kind` | `String` |
| `entityType` | `String` |
| `entityId` | `int?` |
| `detailsJson` | `String` |
| `createdAt` | `DateTime` |

## BillCharge

Table: `raysto_bill_charge`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `orderId` | `int, relation(parent=raysto_order)` |
| `visitId` | `int?` |
| `lineKey` | `String` |
| `kind` | `String` |
| `amountMinor` | `int` |
| `creditedMinor` | `int` |
| `settledMinor` | `int` |
| `reservedMinor` | `int` |
| `foodNetMinor` | `int` |
| `version` | `int` |

## BillSplitPlan

Table: `raysto_bill_split_plan`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `roomId` | `int, relation(parent=raysto_conversation_room)` |
| `activeRoomId` | `int?` |
| `createdBy` | `String` |
| `payersJson` | `String` |
| `sharesJson` | `String` |
| `createdAt` | `DateTime` |

## BillingHistory

Table: `raysto_billing_history`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `providerSubscriptionId` | `String` |
| `eventKey` | `String` |
| `status` | `String` |
| `detailsJson` | `String` |
| `createdAt` | `DateTime` |

## ChargeShare

Transport model.

| Field | Type |
|---|---|
| `chargeId` | `int` |
| `amountMinor` | `int` |
| `expectedVersion` | `int` |

## CheckoutIntent

Table: `raysto_checkout_intent`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `visitId` | `int?` |
| `activeVisitId` | `int?` |
| `orderId` | `int?` |
| `requestKey` | `String` |
| `requestHash` | `String` |
| `providerRequestId` | `String` |
| `providerOrderId` | `String?` |
| `merchantId` | `String` |
| `providerMode` | `String, default='marketplace'` |
| `splitPlanId` | `int?, relation(parent=raysto_bill_split_plan)` |
| `approvalUrl` | `String?` |
| `state` | `String` |
| `method` | `String` |
| `currency` | `String` |
| `amountMinor` | `int` |
| `commissionMinor` | `int` |
| `commissionBps` | `int` |
| `createdAt` | `DateTime` |
| `updatedAt` | `DateTime` |

## CommissionEntry

Table: `raysto_commission_entry`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `captureId` | `int, relation(parent=raysto_payment_capture)` |
| `refundId` | `int?` |
| `eventKey` | `String` |
| `amountMinor` | `int` |
| `currency` | `String` |
| `state` | `String` |
| `createdAt` | `DateTime` |

## ConversationRoom

Table: `raysto_conversation_room`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `contextKey` | `String` |
| `visitId` | `int?, relation(parent=raysto_dining_visit)` |
| `orderId` | `int?, relation(parent=raysto_order)` |
| `hostUserId` | `String?` |
| `hostEverAssigned` | `bool, default=false` |
| `waiterUserId` | `String?` |
| `sequence` | `int` |
| `version` | `int` |
| `createdAt` | `DateTime` |

## CreateQuote

Transport model.

| Field | Type |
|---|---|
| `requestKey` | `String` |
| `restaurantId` | `int` |
| `visitId` | `int?` |
| `fulfillment` | `String` |
| `linesJson` | `String` |
| `addressJson` | `String?` |
| `slot` | `DateTime?` |
| `couponCode` | `String?` |
| `tipMinor` | `int` |

## CustomerCart

Table: `raysto_customer_cart`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `linesJson` | `String` |
| `version` | `int` |
| `updatedAt` | `DateTime` |

## CustomerFavorite

Table: `raysto_customer_favorite`

| Field | Type |
|---|---|
| `userId` | `String` |
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `productId` | `int?` |
| `targetKey` | `String` |
| `createdAt` | `DateTime` |

## CustomerReview

Table: `raysto_customer_review`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `orderId` | `int, relation(parent=raysto_order)` |
| `userId` | `String` |
| `rating` | `int` |
| `text` | `String` |
| `response` | `String?` |
| `status` | `String` |
| `version` | `int` |
| `createdAt` | `DateTime` |

## DeliveryAssignment

Table: `raysto_delivery_assignment`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `orderId` | `int, relation(parent=raysto_order)` |
| `courierId` | `String?` |
| `status` | `String` |
| `issueJson` | `String` |
| `locationJson` | `String?` |
| `locationExpiresAt` | `DateTime?` |
| `locationConsent` | `bool` |
| `version` | `int` |
| `updatedAt` | `DateTime` |

## DiningReservation

Table: `raysto_dining_reservation`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `tableId` | `int, relation(parent=raysto_dining_table)` |
| `partySize` | `int` |
| `startsAt` | `DateTime` |
| `endsAt` | `DateTime` |
| `holdExpiresAt` | `DateTime?` |
| `status` | `String` |
| `contactJson` | `String` |
| `visitId` | `int?` |
| `version` | `int` |
| `createdAt` | `DateTime` |

## DiningTable

Table: `raysto_dining_table`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `label` | `String` |
| `zone` | `String` |
| `capacity` | `int` |
| `active` | `bool` |
| `needsReset` | `bool` |
| `qrKey` | `String` |
| `geometryJson` | `String` |
| `assignedWaiterId` | `String?` |
| `version` | `int` |

## DiningVisit

Table: `raysto_dining_visit`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `tableId` | `int, relation(parent=raysto_dining_table)` |
| `activeTableId` | `int?` |
| `guestCount` | `int` |
| `status` | `String` |
| `version` | `int` |
| `openedBy` | `String` |
| `createdAt` | `DateTime` |
| `closedAt` | `DateTime?` |

## DiningWaitlist

Table: `raysto_dining_waitlist`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `partySize` | `int` |
| `status` | `String` |
| `contactJson` | `String` |
| `offeredTableId` | `int?` |
| `offerExpiresAt` | `DateTime?` |
| `version` | `int` |
| `createdAt` | `DateTime` |

## FloorLayout

Table: `raysto_floor_layout`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `layoutJson` | `String` |
| `version` | `int` |
| `updatedAt` | `DateTime` |

## KitchenProgress

Table: `raysto_kitchen_progress`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `orderId` | `int, relation(parent=raysto_order)` |
| `lineKey` | `String` |
| `quantity` | `int` |
| `completedQuantity` | `int` |
| `version` | `int` |

## MediaAsset

Table: `raysto_media_asset`

| Field | Type |
|---|---|
| `restaurantId` | `int?` |
| `userId` | `String` |
| `purpose` | `String` |
| `objectName` | `String` |
| `mime` | `String` |
| `byteLength` | `int` |
| `sha256` | `String` |
| `status` | `String` |
| `public` | `bool` |
| `metadataJson` | `String` |
| `createdAt` | `DateTime` |

## MenuDefinition

Table: `raysto_menu_definition`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `productId` | `int, relation(parent=raysto_menu_product)` |
| `category` | `String` |
| `definitionJson` | `String` |
| `archived` | `bool` |
| `stockRemaining` | `int?` |
| `version` | `int` |

## MenuDraft

Table: `raysto_menu_draft`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `itemsJson` | `String` |
| `baseMenuVersion` | `int` |
| `version` | `int` |
| `status` | `String` |
| `createdAt` | `DateTime` |

## MerchantConnection

Table: `raysto_merchant_connection`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `trackingId` | `String` |
| `merchantId` | `String?` |
| `environment` | `String` |
| `status` | `String` |
| `capabilitiesJson` | `String` |
| `verifiedAt` | `DateTime?` |
| `createdAt` | `DateTime` |

## MutationReceipt

Table: `raysto_mutation_receipt`

| Field | Type |
|---|---|
| `userId` | `String` |
| `requestKey` | `String` |
| `operation` | `String` |
| `requestHash` | `String` |
| `resultJson` | `String` |
| `createdAt` | `DateTime` |

## OperationsLayout

Table: `raysto_operations_layout`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `stateJson` | `String` |
| `version` | `int` |

## OrderContext

Table: `raysto_order_context`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `orderId` | `int, relation(parent=raysto_order)` |
| `visitId` | `int?` |
| `quoteId` | `int?` |
| `detailsJson` | `String` |
| `paymentTiming` | `String` |
| `cancellationRequested` | `bool` |
| `stockReleased` | `bool` |
| `slotKey` | `String?` |
| `couponCode` | `String?` |
| `createdAt` | `DateTime` |

## PaymentAllocation

Table: `raysto_payment_allocation`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `checkoutId` | `int, relation(parent=raysto_checkout_intent)` |
| `chargeId` | `int, relation(parent=raysto_bill_charge)` |
| `amountMinor` | `int` |
| `foodNetMinor` | `int` |
| `refundedMinor` | `int` |
| `state` | `String` |

## PaymentCapture

Table: `raysto_payment_capture`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `checkoutId` | `int, relation(parent=raysto_checkout_intent)` |
| `providerCaptureId` | `String` |
| `amountMinor` | `int` |
| `refundedMinor` | `int` |
| `currency` | `String` |
| `state` | `String` |
| `createdAt` | `DateTime` |

## PaymentException

Table: `raysto_payment_exception`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `captureId` | `int, relation(parent=raysto_payment_capture)` |
| `providerEventId` | `String` |
| `kind` | `String` |
| `status` | `String` |
| `amountMinor` | `int` |
| `currency` | `String` |
| `evidenceJson` | `String` |
| `version` | `int` |
| `createdAt` | `DateTime` |

## PaymentRefund

Table: `raysto_payment_refund`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `captureId` | `int, relation(parent=raysto_payment_capture)` |
| `requestKey` | `String` |
| `providerRefundId` | `String?` |
| `allocationJson` | `String` |
| `amountMinor` | `int` |
| `commissionMinor` | `int` |
| `reason` | `String` |
| `state` | `String` |
| `createdBy` | `String` |
| `createdAt` | `DateTime` |
| `updatedAt` | `DateTime` |

## PlatformCommand

Transport model.

| Field | Type |
|---|---|
| `requestKey` | `String` |
| `restaurantId` | `int?` |
| `resourceId` | `int?` |
| `expectedVersion` | `int?` |
| `dataJson` | `String` |

## PlatformEvent

Transport model.

| Field | Type |
|---|---|
| `cursor` | `int` |
| `kind` | `String` |
| `entityId` | `int?` |
| `createdAt` | `DateTime` |

## PlatformJob

Table: `raysto_platform_job`

| Field | Type |
|---|---|
| `restaurantId` | `int?` |
| `userId` | `String?` |
| `kind` | `String` |
| `dedupeKey` | `String` |
| `payloadJson` | `String` |
| `state` | `String` |
| `attempts` | `int` |
| `availableAt` | `DateTime` |
| `leaseToken` | `String?` |
| `leaseUntil` | `DateTime?` |
| `lastError` | `String?` |
| `createdAt` | `DateTime` |

## PlatformResponse

Transport model.

| Field | Type |
|---|---|
| `requestId` | `String` |
| `dataJson` | `String` |

## PriceQuote

Table: `raysto_price_quote`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `userId` | `String` |
| `visitId` | `int?` |
| `snapshotJson` | `String` |
| `menuVersion` | `int` |
| `totalMinor` | `int` |
| `currency` | `String` |
| `expiresAt` | `DateTime` |
| `consumedOrderId` | `int?` |
| `assistantProposalId` | `int?, relation(parent=raysto_assistant_proposal)` |
| `createdAt` | `DateTime` |

## ProviderInbox

Table: `raysto_provider_inbox`

| Field | Type |
|---|---|
| `provider` | `String` |
| `eventId` | `String` |
| `eventType` | `String` |
| `payloadJson` | `String` |
| `status` | `String` |
| `receivedAt` | `DateTime` |
| `processedAt` | `DateTime?` |

## RateWindow

Table: `raysto_rate_window`

| Field | Type |
|---|---|
| `bucket` | `String` |
| `windowStart` | `DateTime` |
| `requests` | `int` |

## RequestRefund

Transport model.

| Field | Type |
|---|---|
| `requestKey` | `String` |
| `restaurantId` | `int` |
| `captureId` | `int` |
| `amountMinor` | `int` |
| `reason` | `String` |

## RestaurantPlan

Table: `raysto_restaurant_plan`

| Field | Type |
|---|---|
| `code` | `String` |
| `version` | `int` |
| `currency` | `String` |
| `priceMinor` | `int` |
| `commissionBps` | `int` |
| `featuresJson` | `String` |
| `providerPlanId` | `String?` |
| `active` | `bool` |
| `createdAt` | `DateTime` |

## RestaurantPolicy

Table: `raysto_restaurant_policy`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `settingsJson` | `String` |
| `version` | `int` |
| `menuVersion` | `int` |
| `suspended` | `bool` |
| `createdAt` | `DateTime` |
| `updatedAt` | `DateTime` |

## RestaurantSubscription

Table: `raysto_restaurant_subscription`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `planId` | `int, relation(parent=raysto_restaurant_plan)` |
| `providerSubscriptionId` | `String?` |
| `status` | `String` |
| `periodEndsAt` | `DateTime?` |
| `graceEndsAt` | `DateTime?` |
| `approvalUrl` | `String?` |
| `requestKey` | `String` |
| `updatedAt` | `DateTime` |

## RoomMember

Table: `raysto_room_member`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `roomId` | `int, relation(parent=raysto_conversation_room)` |
| `userId` | `String` |
| `lastReadSequence` | `int` |
| `preferencesJson` | `String` |
| `muted` | `bool` |
| `createdAt` | `DateTime` |

## RoomMessage

Table: `raysto_room_message`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `roomId` | `int, relation(parent=raysto_conversation_room)` |
| `sequence` | `int` |
| `userId` | `String?` |
| `clientMessageId` | `String?` |
| `replyToId` | `int?, relation(parent=raysto_room_message)` |
| `kind` | `String` |
| `bodyJson` | `String` |
| `createdAt` | `DateTime` |

## SecurityGrant

Table: `raysto_security_grant`

| Field | Type |
|---|---|
| `userId` | `String` |
| `kind` | `String` |
| `proofHash` | `String` |
| `expiresAt` | `DateTime` |
| `usedAt` | `DateTime?` |
| `createdAt` | `DateTime` |

## StartVisit

Transport model.

| Field | Type |
|---|---|
| `requestKey` | `String` |
| `restaurantId` | `int` |
| `tableId` | `int` |
| `guestCount` | `int` |
| `seatingToken` | `String?` |

## SubmitOrder

Transport model.

| Field | Type |
|---|---|
| `requestKey` | `String` |
| `restaurantId` | `int` |
| `quoteId` | `int` |

## SupportConversation

Table: `raysto_support_conversation`

| Field | Type |
|---|---|
| `restaurantId` | `int?` |
| `orderId` | `int?` |
| `userId` | `String` |
| `status` | `String` |
| `subject` | `String` |
| `escalated` | `bool` |
| `version` | `int` |
| `createdAt` | `DateTime` |

## SupportMessage

Table: `raysto_support_message`

| Field | Type |
|---|---|
| `conversationId` | `int, relation(parent=raysto_support_conversation)` |
| `userId` | `String` |
| `text` | `String` |
| `mediaId` | `int?` |
| `createdAt` | `DateTime` |

## UserNotification

Table: `raysto_user_notification`

| Field | Type |
|---|---|
| `userId` | `String` |
| `restaurantId` | `int?` |
| `eventKey` | `String` |
| `kind` | `String` |
| `referenceJson` | `String` |
| `readAt` | `DateTime?` |
| `dismissedAt` | `DateTime?` |
| `createdAt` | `DateTime` |

## VisitParticipant

Table: `raysto_visit_participant`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `visitId` | `int, relation(parent=raysto_dining_visit)` |
| `userId` | `String` |
| `active` | `bool` |
| `joinedAt` | `DateTime` |

## VisitRequest

Table: `raysto_visit_request`

| Field | Type |
|---|---|
| `restaurantId` | `int, relation(parent=raysto_restaurant)` |
| `visitId` | `int, relation(parent=raysto_dining_visit)` |
| `userId` | `String` |
| `kind` | `String` |
| `status` | `String` |
| `assignedUserId` | `String?` |
| `reason` | `String?` |
| `version` | `int` |
| `createdAt` | `DateTime` |
