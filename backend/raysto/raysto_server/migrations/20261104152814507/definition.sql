BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- Class AccessInvitation as table raysto_access_invitation
--
CREATE TABLE "raysto_access_invitation" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "kind" text NOT NULL,
    "targetId" bigint NOT NULL,
    "tokenHash" text NOT NULL,
    "createdBy" text NOT NULL,
    "recipientEmail" text,
    "role" text,
    "expiresAt" timestamp without time zone NOT NULL,
    "usesRemaining" bigint NOT NULL,
    "revoked" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "invitation_token" ON "raysto_access_invitation" USING btree ("tokenHash");

--
-- Class ActorProfile as table raysto_actor_profile
--
CREATE TABLE "raysto_actor_profile" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "firebaseUid" text,
    "isGuest" boolean NOT NULL,
    "disabled" boolean NOT NULL,
    "claimedBy" text,
    "dataJson" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "actor_user" ON "raysto_actor_profile" USING btree ("userId");

--
-- Class AgentAction as table raysto_agent_action
--
CREATE TABLE "raysto_agent_action" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "taskId" bigint NOT NULL,
    "agent" text NOT NULL,
    "ordinal" bigint NOT NULL,
    "command" text NOT NULL,
    "title" text NOT NULL,
    "rationale" text NOT NULL,
    "payloadJson" text NOT NULL,
    "previewJson" text NOT NULL,
    "evidenceJson" text NOT NULL,
    "risk" text NOT NULL,
    "contextHash" text NOT NULL,
    "status" text NOT NULL,
    "approverUserId" text,
    "executionKey" text,
    "resultJson" text,
    "errorCode" text,
    "version" bigint NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "decidedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "agent_action_task" ON "raysto_agent_action" USING btree ("taskId", "ordinal");
CREATE INDEX "agent_action_open" ON "raysto_agent_action" USING btree ("restaurantId", "status", "expiresAt");
CREATE UNIQUE INDEX "agent_action_execution" ON "raysto_agent_action" USING btree ("executionKey");

--
-- Class AgentTask as table raysto_agent_task
--
CREATE TABLE "raysto_agent_task" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "agent" text NOT NULL,
    "trigger" text NOT NULL,
    "triggerRef" text,
    "requestedBy" text,
    "dedupeKey" text NOT NULL,
    "status" text NOT NULL,
    "title" text NOT NULL,
    "summary" text,
    "inputJson" text NOT NULL,
    "stateJson" text NOT NULL,
    "traceJson" text NOT NULL,
    "feature" text NOT NULL,
    "reservedMicros" bigint NOT NULL,
    "chargedMicros" bigint NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "completedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "agent_task_dedupe" ON "raysto_agent_task" USING btree ("dedupeKey");
CREATE INDEX "agent_task_tenant" ON "raysto_agent_task" USING btree ("restaurantId", "status");

--
-- Class AiOperation as table raysto_ai_operation
--
CREATE TABLE "raysto_ai_operation" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "kind" text NOT NULL,
    "mediaId" bigint,
    "inputJson" text NOT NULL,
    "outputJson" text,
    "status" text NOT NULL,
    "menuVersion" bigint NOT NULL,
    "version" bigint NOT NULL,
    "inputTokens" bigint NOT NULL,
    "outputTokens" bigint NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "ai_actor_time" ON "raysto_ai_operation" USING btree ("userId", "createdAt");

--
-- Class AiSpendBudget as table raysto_ai_spend_budget
--
CREATE TABLE "raysto_ai_spend_budget" (
    "id" bigserial PRIMARY KEY,
    "stage" text NOT NULL,
    "limitMicros" bigint NOT NULL,
    "reservedMicros" bigint NOT NULL,
    "spentMicros" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "spend_stage" ON "raysto_ai_spend_budget" USING btree ("stage");

--
-- Class AiSpendEntry as table raysto_ai_spend_entry
--
CREATE TABLE "raysto_ai_spend_entry" (
    "id" bigserial PRIMARY KEY,
    "sourceKey" text NOT NULL,
    "stage" text NOT NULL,
    "reservedMicros" bigint NOT NULL,
    "chargedMicros" bigint NOT NULL,
    "settled" boolean NOT NULL,
    "feature" text,
    "restaurantId" bigint,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "spend_source" ON "raysto_ai_spend_entry" USING btree ("sourceKey");

--
-- Class AssistantProposal as table raysto_assistant_proposal
--
CREATE TABLE "raysto_assistant_proposal" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "roomId" bigint,
    "runId" bigint NOT NULL,
    "userId" text NOT NULL,
    "kind" text NOT NULL,
    "payloadJson" text NOT NULL,
    "contextHash" text NOT NULL,
    "status" text NOT NULL,
    "version" bigint NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "proposal_run" ON "raysto_assistant_proposal" USING btree ("runId");

--
-- Class AssistantRun as table raysto_assistant_run
--
CREATE TABLE "raysto_assistant_run" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "roomId" bigint,
    "userId" text NOT NULL,
    "requestKey" text NOT NULL,
    "status" text NOT NULL,
    "inputJson" text NOT NULL,
    "outputJson" text NOT NULL,
    "traceJson" text NOT NULL,
    "reservedMicros" bigint NOT NULL,
    "chargedMicros" bigint NOT NULL,
    "budgetStage" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "completedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "assistant_request" ON "raysto_assistant_run" USING btree ("userId", "requestKey");
CREATE INDEX "assistant_tenant" ON "raysto_assistant_run" USING btree ("restaurantId", "id");

--
-- Class AuditRecord as table raysto_audit_record
--
CREATE TABLE "raysto_audit_record" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint,
    "userId" text NOT NULL,
    "requestKey" text NOT NULL,
    "kind" text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" bigint,
    "detailsJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "audit_tenant_time" ON "raysto_audit_record" USING btree ("restaurantId", "createdAt");

--
-- Class Bill as table raysto_bill
--
CREATE TABLE "raysto_bill" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "vendor" text NOT NULL,
    "category" text NOT NULL,
    "reference" text,
    "amountMinor" bigint NOT NULL,
    "vatMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "issuedAt" timestamp without time zone,
    "dueAt" timestamp without time zone,
    "periodFrom" timestamp without time zone,
    "periodTo" timestamp without time zone,
    "state" text NOT NULL,
    "payVia" text NOT NULL,
    "payeeEmail" text,
    "recurring" text,
    "recurringOfId" bigint,
    "sourceMediaId" bigint,
    "proofMediaId" bigint,
    "contentSha" text,
    "supplierId" bigint,
    "supplierOrderId" bigint,
    "payoutBatchId" bigint,
    "readJson" text NOT NULL,
    "duplicateOfId" bigint,
    "taskId" bigint,
    "paidAt" timestamp without time zone,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "bill_tenant_due" ON "raysto_bill" USING btree ("restaurantId", "dueAt");
CREATE INDEX "bill_tenant_state" ON "raysto_bill" USING btree ("restaurantId", "state");

--
-- Class BillCharge as table raysto_bill_charge
--
CREATE TABLE "raysto_bill_charge" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "visitId" bigint,
    "lineKey" text NOT NULL,
    "kind" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "creditedMinor" bigint NOT NULL,
    "settledMinor" bigint NOT NULL,
    "reservedMinor" bigint NOT NULL,
    "foodNetMinor" bigint NOT NULL,
    "version" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "charge_order_line" ON "raysto_bill_charge" USING btree ("orderId", "lineKey");
CREATE INDEX "charge_visit" ON "raysto_bill_charge" USING btree ("visitId");

--
-- Class BillSplitPlan as table raysto_bill_split_plan
--
CREATE TABLE "raysto_bill_split_plan" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "roomId" bigint NOT NULL,
    "activeRoomId" bigint,
    "createdBy" text NOT NULL,
    "payersJson" text NOT NULL,
    "sharesJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "split_active_room" ON "raysto_bill_split_plan" USING btree ("activeRoomId");

--
-- Class BillingHistory as table raysto_billing_history
--
CREATE TABLE "raysto_billing_history" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "providerSubscriptionId" text NOT NULL,
    "eventKey" text NOT NULL,
    "status" text NOT NULL,
    "detailsJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "billing_history_event" ON "raysto_billing_history" USING btree ("eventKey");

--
-- Class CateringRequest as table raysto_catering_request
--
CREATE TABLE "raysto_catering_request" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "customerEmail" text NOT NULL,
    "customerName" text,
    "text" text NOT NULL,
    "eventAt" timestamp without time zone,
    "quoteJson" text NOT NULL,
    "status" text NOT NULL,
    "providerInvoiceId" text,
    "invoiceNumber" text,
    "qrMediaId" bigint,
    "orderId" bigint,
    "depositMinor" bigint NOT NULL,
    "totalMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "dueAt" timestamp without time zone,
    "remindedAt" timestamp without time zone,
    "taskId" bigint,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "catering_invoice" ON "raysto_catering_request" USING btree ("providerInvoiceId");
CREATE INDEX "catering_tenant" ON "raysto_catering_request" USING btree ("restaurantId", "createdAt");

--
-- Class CheckoutIntent as table raysto_checkout_intent
--
CREATE TABLE "raysto_checkout_intent" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "visitId" bigint,
    "activeVisitId" bigint,
    "orderId" bigint,
    "requestKey" text NOT NULL,
    "requestHash" text NOT NULL,
    "providerRequestId" text NOT NULL,
    "providerOrderId" text,
    "merchantId" text NOT NULL,
    "providerMode" text NOT NULL DEFAULT 'marketplace'::text,
    "splitPlanId" bigint,
    "approvalUrl" text,
    "state" text NOT NULL,
    "method" text NOT NULL,
    "currency" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "commissionMinor" bigint NOT NULL,
    "commissionBps" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "checkout_request" ON "raysto_checkout_intent" USING btree ("userId", "requestKey");
CREATE UNIQUE INDEX "checkout_active_visit" ON "raysto_checkout_intent" USING btree ("activeVisitId");
CREATE UNIQUE INDEX "checkout_provider" ON "raysto_checkout_intent" USING btree ("providerOrderId");

--
-- Class CommissionEntry as table raysto_commission_entry
--
CREATE TABLE "raysto_commission_entry" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "captureId" bigint NOT NULL,
    "refundId" bigint,
    "eventKey" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "state" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "commission_event" ON "raysto_commission_entry" USING btree ("eventKey");

--
-- Class Complaint as table raysto_complaint
--
CREATE TABLE "raysto_complaint" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "captureId" bigint,
    "userId" text,
    "text" text NOT NULL,
    "status" text NOT NULL,
    "refundId" bigint,
    "taskId" bigint,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "complaint_tenant" ON "raysto_complaint" USING btree ("restaurantId", "createdAt");

--
-- Class ConversationRoom as table raysto_conversation_room
--
CREATE TABLE "raysto_conversation_room" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "contextKey" text NOT NULL,
    "visitId" bigint,
    "orderId" bigint,
    "hostUserId" text,
    "hostEverAssigned" boolean NOT NULL DEFAULT false,
    "waiterUserId" text,
    "sequence" bigint NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "conversation_context" ON "raysto_conversation_room" USING btree ("contextKey");
CREATE INDEX "conversation_tenant" ON "raysto_conversation_room" USING btree ("restaurantId", "id");

--
-- Class CustomerCart as table raysto_customer_cart
--
CREATE TABLE "raysto_customer_cart" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "linesJson" text NOT NULL,
    "version" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "cart_actor_restaurant" ON "raysto_customer_cart" USING btree ("userId", "restaurantId");

--
-- Class CustomerFavorite as table raysto_customer_favorite
--
CREATE TABLE "raysto_customer_favorite" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "restaurantId" bigint NOT NULL,
    "productId" bigint,
    "targetKey" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "favorite_target" ON "raysto_customer_favorite" USING btree ("userId", "targetKey");

--
-- Class CustomerProfile as table raysto_customer_profile
--
CREATE TABLE "raysto_customer_profile" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text,
    "emailHash" text NOT NULL,
    "displayName" text NOT NULL,
    "visits" bigint NOT NULL,
    "spentMinor" bigint NOT NULL,
    "lastSeenAt" timestamp without time zone NOT NULL,
    "tagsJson" text NOT NULL,
    "couponCode" text,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "customer_profile_email" ON "raysto_customer_profile" USING btree ("restaurantId", "emailHash");

--
-- Class CustomerReview as table raysto_customer_review
--
CREATE TABLE "raysto_customer_review" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "userId" text NOT NULL,
    "rating" bigint NOT NULL,
    "text" text NOT NULL,
    "response" text,
    "status" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "review_order" ON "raysto_customer_review" USING btree ("orderId");

--
-- Class DailyClose as table raysto_daily_close
--
CREATE TABLE "raysto_daily_close" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "day" text NOT NULL,
    "source" text NOT NULL,
    "summaryJson" text NOT NULL,
    "gapsJson" text NOT NULL,
    "state" text NOT NULL,
    "signedBy" text,
    "taskId" bigint,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "daily_close_day" ON "raysto_daily_close" USING btree ("restaurantId", "day");

--
-- Class DeliveryAssignment as table raysto_delivery_assignment
--
CREATE TABLE "raysto_delivery_assignment" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "courierId" text,
    "status" text NOT NULL,
    "issueJson" text NOT NULL,
    "locationJson" text,
    "locationExpiresAt" timestamp without time zone,
    "locationConsent" boolean NOT NULL,
    "version" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "driverId" bigint,
    "partnerAppId" bigint,
    "partnerRef" text,
    "fulfilledBy" text,
    "etaAt" timestamp without time zone,
    "distanceMeters" bigint,
    "feeMinor" bigint,
    "proofKind" text,
    "proofMediaId" bigint,
    "codeHash" text,
    "pickedUpAt" timestamp without time zone,
    "deliveredAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "delivery_order" ON "raysto_delivery_assignment" USING btree ("orderId");
CREATE INDEX "delivery_courier" ON "raysto_delivery_assignment" USING btree ("courierId", "status");

--
-- Class DeliveryOffer as table raysto_delivery_offer
--
CREATE TABLE "raysto_delivery_offer" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "assignmentId" bigint NOT NULL,
    "driverId" bigint NOT NULL,
    "state" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "score" double precision NOT NULL,
    "reasonJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "respondedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "dlv_offer_assignment" ON "raysto_delivery_offer" USING btree ("assignmentId", "state");
CREATE INDEX "dlv_offer_driver" ON "raysto_delivery_offer" USING btree ("driverId", "state");

--
-- Class DeliveryPing as table raysto_delivery_ping
--
CREATE TABLE "raysto_delivery_ping" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "assignmentId" bigint NOT NULL,
    "lat" double precision NOT NULL,
    "lng" double precision NOT NULL,
    "accuracy" double precision,
    "at" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "dlv_ping_assignment_at" ON "raysto_delivery_ping" USING btree ("assignmentId", "at");

--
-- Class DeviceToken as table raysto_device_token
--
CREATE TABLE "raysto_device_token" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "token" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "device_token_unique" ON "raysto_device_token" USING btree ("token");

--
-- Class DiningReservation as table raysto_dining_reservation
--
CREATE TABLE "raysto_dining_reservation" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "tableId" bigint NOT NULL,
    "partySize" bigint NOT NULL,
    "startsAt" timestamp without time zone NOT NULL,
    "endsAt" timestamp without time zone NOT NULL,
    "holdExpiresAt" timestamp without time zone,
    "status" text NOT NULL,
    "contactJson" text NOT NULL,
    "visitId" bigint,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "reservation_interval" ON "raysto_dining_reservation" USING btree ("restaurantId", "startsAt", "endsAt");

--
-- Class DiningTable as table raysto_dining_table
--
CREATE TABLE "raysto_dining_table" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "label" text NOT NULL,
    "zone" text NOT NULL,
    "capacity" bigint NOT NULL,
    "active" boolean NOT NULL,
    "needsReset" boolean NOT NULL,
    "qrKey" text NOT NULL,
    "geometryJson" text NOT NULL,
    "assignedWaiterId" text,
    "version" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "table_label" ON "raysto_dining_table" USING btree ("restaurantId", "label");
CREATE UNIQUE INDEX "table_qr" ON "raysto_dining_table" USING btree ("qrKey");

--
-- Class DiningVisit as table raysto_dining_visit
--
CREATE TABLE "raysto_dining_visit" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "tableId" bigint NOT NULL,
    "activeTableId" bigint,
    "guestCount" bigint NOT NULL,
    "status" text NOT NULL,
    "version" bigint NOT NULL,
    "openedBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "closedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "visit_active_table" ON "raysto_dining_visit" USING btree ("activeTableId");
CREATE INDEX "visit_tenant" ON "raysto_dining_visit" USING btree ("restaurantId", "status");

--
-- Class DiningWaitlist as table raysto_dining_waitlist
--
CREATE TABLE "raysto_dining_waitlist" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "partySize" bigint NOT NULL,
    "status" text NOT NULL,
    "contactJson" text NOT NULL,
    "offeredTableId" bigint,
    "offerExpiresAt" timestamp without time zone,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "waitlist_tenant" ON "raysto_dining_waitlist" USING btree ("restaurantId", "status", "createdAt");

--
-- Class DisputeCase as table raysto_dispute_case
--
CREATE TABLE "raysto_dispute_case" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "providerDisputeId" text NOT NULL,
    "captureId" bigint,
    "reason" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "status" text NOT NULL,
    "evidenceJson" text NOT NULL,
    "replyText" text,
    "taskId" bigint,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "dispute_provider" ON "raysto_dispute_case" USING btree ("providerDisputeId");
CREATE INDEX "dispute_tenant" ON "raysto_dispute_case" USING btree ("restaurantId", "createdAt");

--
-- Class Driver as table raysto_driver
--
CREATE TABLE "raysto_driver" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "kind" text NOT NULL,
    "userId" text,
    "partnerAppId" bigint,
    "name" text NOT NULL,
    "phoneLast4" text,
    "vehicle" text NOT NULL,
    "payoutEmail" text,
    "status" text NOT NULL,
    "lastSeenAt" timestamp without time zone,
    "active" boolean NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "driver_tenant_status" ON "raysto_driver" USING btree ("restaurantId", "status");
CREATE INDEX "driver_user" ON "raysto_driver" USING btree ("userId");

--
-- Class Expense as table raysto_expense
--
CREATE TABLE "raysto_expense" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "category" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "vatMinor" bigint NOT NULL,
    "spentAt" timestamp without time zone NOT NULL,
    "mediaId" bigint,
    "merchant" text NOT NULL,
    "paypalTransactionId" text,
    "taskId" bigint,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "expense_tenant" ON "raysto_expense" USING btree ("restaurantId", "spentAt");

--
-- Class FloorLayout as table raysto_floor_layout
--
CREATE TABLE "raysto_floor_layout" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "layoutJson" text NOT NULL,
    "version" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "layout_restaurant" ON "raysto_floor_layout" USING btree ("restaurantId");

--
-- Class GroupMembership as table raysto_group_membership
--
CREATE TABLE "raysto_group_membership" (
    "id" bigserial PRIMARY KEY,
    "groupId" bigint NOT NULL,
    "userId" text NOT NULL,
    "role" text NOT NULL,
    "active" boolean NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "gmember_group_user" ON "raysto_group_membership" USING btree ("groupId", "userId");
CREATE INDEX "gmember_user" ON "raysto_group_membership" USING btree ("userId");

--
-- Class GroupVenue as table raysto_group_venue
--
CREATE TABLE "raysto_group_venue" (
    "id" bigserial PRIMARY KEY,
    "groupId" bigint NOT NULL,
    "restaurantId" bigint NOT NULL,
    "attachedBy" text NOT NULL,
    "attachedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "gvenue_restaurant" ON "raysto_group_venue" USING btree ("restaurantId");
CREATE INDEX "gvenue_group" ON "raysto_group_venue" USING btree ("groupId");

--
-- Class KitchenProgress as table raysto_kitchen_progress
--
CREATE TABLE "raysto_kitchen_progress" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "lineKey" text NOT NULL,
    "quantity" bigint NOT NULL,
    "completedQuantity" bigint NOT NULL,
    "version" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "kitchen_line" ON "raysto_kitchen_progress" USING btree ("orderId", "lineKey");

--
-- Class LedgerAdjustment as table raysto_ledger_adjustment
--
CREATE TABLE "raysto_ledger_adjustment" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "at" timestamp without time zone NOT NULL,
    "debitAccount" text NOT NULL,
    "creditAccount" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "reason" text NOT NULL,
    "userId" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "ledger_adj_tenant_at" ON "raysto_ledger_adjustment" USING btree ("restaurantId", "at");

--
-- Class MediaAsset as table raysto_media_asset
--
CREATE TABLE "raysto_media_asset" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint,
    "userId" text NOT NULL,
    "purpose" text NOT NULL,
    "objectName" text NOT NULL,
    "mime" text NOT NULL,
    "byteLength" bigint NOT NULL,
    "sha256" text NOT NULL,
    "status" text NOT NULL,
    "public" boolean NOT NULL,
    "metadataJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "media_object" ON "raysto_media_asset" USING btree ("objectName");

--
-- Class Membership as table raysto_membership
--
CREATE TABLE "raysto_membership" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "role" text NOT NULL,
    "active" boolean NOT NULL,
    "capabilities" json
);

-- Indexes
CREATE UNIQUE INDEX "membership_tenant_user" ON "raysto_membership" USING btree ("restaurantId", "userId");

--
-- Class MenuDefinition as table raysto_menu_definition
--
CREATE TABLE "raysto_menu_definition" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "productId" bigint NOT NULL,
    "category" text NOT NULL,
    "definitionJson" text NOT NULL,
    "archived" boolean NOT NULL,
    "stockRemaining" bigint,
    "version" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "definition_product" ON "raysto_menu_definition" USING btree ("productId");
CREATE INDEX "definition_category" ON "raysto_menu_definition" USING btree ("restaurantId", "category");

--
-- Class MenuDraft as table raysto_menu_draft
--
CREATE TABLE "raysto_menu_draft" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "itemsJson" text NOT NULL,
    "baseMenuVersion" bigint NOT NULL,
    "version" bigint NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "menu_draft_tenant" ON "raysto_menu_draft" USING btree ("restaurantId", "status");

--
-- Class MenuProduct as table raysto_menu_product
--
CREATE TABLE "raysto_menu_product" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text NOT NULL,
    "priceMinor" bigint NOT NULL,
    "available" boolean NOT NULL,
    "version" bigint NOT NULL
);

-- Indexes
CREATE INDEX "product_restaurant" ON "raysto_menu_product" USING btree ("restaurantId");

--
-- Class MenuTemplate as table raysto_menu_template
--
CREATE TABLE "raysto_menu_template" (
    "id" bigserial PRIMARY KEY,
    "groupId" bigint NOT NULL,
    "name" text NOT NULL,
    "itemsJson" text NOT NULL,
    "createdBy" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "mtemplate_group" ON "raysto_menu_template" USING btree ("groupId");

--
-- Class MerchantApp as table raysto_merchant_app
--
CREATE TABLE "raysto_merchant_app" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "environment" text NOT NULL,
    "clientId" text NOT NULL,
    "secretCipher" text NOT NULL,
    "keyVersion" bigint NOT NULL,
    "credentialVersion" bigint NOT NULL,
    "status" text NOT NULL,
    "merchantId" text,
    "appId" text,
    "webhookToken" text NOT NULL,
    "webhookId" text,
    "webhookStatus" text NOT NULL,
    "featuresJson" text NOT NULL,
    "checkedAt" timestamp without time zone,
    "savedBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "version" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "merchant_app_restaurant" ON "raysto_merchant_app" USING btree ("restaurantId", "environment");
CREATE UNIQUE INDEX "merchant_app_webhook" ON "raysto_merchant_app" USING btree ("webhookToken");

--
-- Class MerchantConnection as table raysto_merchant_connection
--
CREATE TABLE "raysto_merchant_connection" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "trackingId" text NOT NULL,
    "merchantId" text,
    "environment" text NOT NULL,
    "status" text NOT NULL,
    "capabilitiesJson" text NOT NULL,
    "verifiedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "merchant_restaurant" ON "raysto_merchant_connection" USING btree ("restaurantId", "environment");
CREATE UNIQUE INDEX "merchant_tracking" ON "raysto_merchant_connection" USING btree ("trackingId");

--
-- Class MutationReceipt as table raysto_mutation_receipt
--
CREATE TABLE "raysto_mutation_receipt" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "requestKey" text NOT NULL,
    "operation" text NOT NULL,
    "requestHash" text NOT NULL,
    "resultJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "mutation_actor_key" ON "raysto_mutation_receipt" USING btree ("userId", "requestKey");

--
-- Class OperationsLayout as table raysto_operations_layout
--
CREATE TABLE "raysto_operations_layout" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "stateJson" text NOT NULL,
    "version" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "operations_layout_user" ON "raysto_operations_layout" USING btree ("restaurantId", "userId");

--
-- Class PurchaseOrder as table raysto_order
--
CREATE TABLE "raysto_order" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "customerId" text NOT NULL,
    "requestKey" text NOT NULL,
    "requestHash" text NOT NULL,
    "fulfillment" text NOT NULL,
    "address" text,
    "lines" json NOT NULL,
    "currency" text NOT NULL,
    "subtotalMinor" bigint NOT NULL,
    "deliveryFeeMinor" bigint NOT NULL,
    "totalMinor" bigint NOT NULL,
    "status" text NOT NULL,
    "paymentStatus" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "order_customer_key" ON "raysto_order" USING btree ("customerId", "requestKey");
CREATE INDEX "order_restaurant_created" ON "raysto_order" USING btree ("restaurantId", "createdAt");

--
-- Class OrderContext as table raysto_order_context
--
CREATE TABLE "raysto_order_context" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "visitId" bigint,
    "quoteId" bigint,
    "detailsJson" text NOT NULL,
    "paymentTiming" text NOT NULL,
    "cancellationRequested" boolean NOT NULL,
    "stockReleased" boolean NOT NULL,
    "slotKey" text,
    "couponCode" text,
    "origin" text NOT NULL DEFAULT 'online'::text,
    "customerLabel" text,
    "placedBy" text,
    "serviceDay" text,
    "orderNumber" bigint,
    "pickupCode" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "context_order" ON "raysto_order_context" USING btree ("orderId");
CREATE UNIQUE INDEX "context_daily_number" ON "raysto_order_context" USING btree ("restaurantId", "serviceDay", "orderNumber");

--
-- Class OutboxEvent as table raysto_outbox
--
CREATE TABLE "raysto_outbox" (
    "id" bigserial PRIMARY KEY,
    "orderId" bigint NOT NULL,
    "userId" text NOT NULL,
    "kind" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "deliveredAt" timestamp without time zone,
    "attempts" bigint NOT NULL,
    "nextAttemptAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "outbox_pending" ON "raysto_outbox" USING btree ("deliveredAt", "nextAttemptAt");

--
-- Class PartnerApp as table raysto_partner_app
--
CREATE TABLE "raysto_partner_app" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "name" text NOT NULL,
    "keyPrefix" text NOT NULL,
    "keyHash" text NOT NULL,
    "webhookUrl" text,
    "secretVersion" bigint NOT NULL,
    "simulator" boolean NOT NULL,
    "active" boolean NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "partner_app_prefix" ON "raysto_partner_app" USING btree ("keyPrefix");
CREATE INDEX "partner_app_tenant" ON "raysto_partner_app" USING btree ("restaurantId");

--
-- Class PartnerEvent as table raysto_partner_event
--
CREATE TABLE "raysto_partner_event" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "partnerAppId" bigint NOT NULL,
    "direction" text NOT NULL,
    "type" text NOT NULL,
    "ref" text,
    "status" text NOT NULL,
    "attempts" bigint NOT NULL,
    "responseCode" bigint,
    "payloadJson" text NOT NULL,
    "idempotencyKey" text,
    "nextAttemptAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "partner_event_app_at" ON "raysto_partner_event" USING btree ("partnerAppId", "createdAt");
CREATE INDEX "partner_event_tenant_at" ON "raysto_partner_event" USING btree ("restaurantId", "createdAt");

--
-- Class PaymentAllocation as table raysto_payment_allocation
--
CREATE TABLE "raysto_payment_allocation" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "checkoutId" bigint NOT NULL,
    "chargeId" bigint NOT NULL,
    "amountMinor" bigint NOT NULL,
    "foodNetMinor" bigint NOT NULL,
    "refundedMinor" bigint NOT NULL,
    "state" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "allocation_charge_checkout" ON "raysto_payment_allocation" USING btree ("checkoutId", "chargeId");

--
-- Class PaymentAttempt as table raysto_payment_attempt
--
CREATE TABLE "raysto_payment_attempt" (
    "id" bigserial PRIMARY KEY,
    "orderId" bigint NOT NULL,
    "requestId" text NOT NULL,
    "providerOrderId" text,
    "approvalUrl" text,
    "state" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "payment_order" ON "raysto_payment_attempt" USING btree ("orderId");
CREATE UNIQUE INDEX "payment_provider_order" ON "raysto_payment_attempt" USING btree ("providerOrderId");

--
-- Class PaymentCapture as table raysto_payment_capture
--
CREATE TABLE "raysto_payment_capture" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "checkoutId" bigint NOT NULL,
    "providerCaptureId" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "refundedMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "state" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "capture_provider" ON "raysto_payment_capture" USING btree ("providerCaptureId");
CREATE UNIQUE INDEX "capture_checkout" ON "raysto_payment_capture" USING btree ("checkoutId");

--
-- Class PaymentException as table raysto_payment_exception
--
CREATE TABLE "raysto_payment_exception" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "captureId" bigint NOT NULL,
    "providerEventId" text NOT NULL,
    "kind" text NOT NULL,
    "status" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "evidenceJson" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "exception_event" ON "raysto_payment_exception" USING btree ("providerEventId");

--
-- Class PaymentReceipt as table raysto_payment_receipt
--
CREATE TABLE "raysto_payment_receipt" (
    "id" bigserial PRIMARY KEY,
    "orderId" bigint NOT NULL,
    "captureId" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "receipt_order" ON "raysto_payment_receipt" USING btree ("orderId");
CREATE UNIQUE INDEX "receipt_capture" ON "raysto_payment_receipt" USING btree ("captureId");

--
-- Class PaymentRefund as table raysto_payment_refund
--
CREATE TABLE "raysto_payment_refund" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "captureId" bigint NOT NULL,
    "requestKey" text NOT NULL,
    "providerRefundId" text,
    "allocationJson" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "commissionMinor" bigint NOT NULL,
    "reason" text NOT NULL,
    "state" text NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "refund_request" ON "raysto_payment_refund" USING btree ("restaurantId", "requestKey");
CREATE UNIQUE INDEX "refund_provider" ON "raysto_payment_refund" USING btree ("providerRefundId");

--
-- Class PaymentRequest as table raysto_payment_request
--
CREATE TABLE "raysto_payment_request" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "kind" text NOT NULL,
    "payerName" text NOT NULL,
    "payerEmail" text,
    "description" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "dueAt" timestamp without time zone,
    "state" text NOT NULL,
    "linkTokenHash" text NOT NULL,
    "checkoutIntentId" bigint,
    "providerInvoiceId" text,
    "remindersSent" bigint NOT NULL,
    "lastRemindedAt" timestamp without time zone,
    "partnerAppId" bigint,
    "cateringRequestId" bigint,
    "createdBy" text NOT NULL,
    "paidAt" timestamp without time zone,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "payreq_token" ON "raysto_payment_request" USING btree ("linkTokenHash");
CREATE INDEX "payreq_tenant_state" ON "raysto_payment_request" USING btree ("restaurantId", "state");

--
-- Class PayoutBatch as table raysto_payout_batch
--
CREATE TABLE "raysto_payout_batch" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "kind" text NOT NULL,
    "periodFrom" timestamp without time zone NOT NULL,
    "periodTo" timestamp without time zone NOT NULL,
    "totalMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "state" text NOT NULL,
    "providerBatchId" text,
    "requestKey" text NOT NULL,
    "taskId" bigint,
    "summaryJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "payout_batch_request" ON "raysto_payout_batch" USING btree ("requestKey");
CREATE INDEX "payout_batch_tenant" ON "raysto_payout_batch" USING btree ("restaurantId", "createdAt");

--
-- Class PayoutItem as table raysto_payout_item
--
CREATE TABLE "raysto_payout_item" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "batchId" bigint NOT NULL,
    "recipientEmail" text NOT NULL,
    "recipientName" text NOT NULL,
    "shiftIdsJson" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "note" text NOT NULL,
    "providerItemId" text,
    "state" text NOT NULL
);

-- Indexes
CREATE INDEX "payout_item_batch" ON "raysto_payout_item" USING btree ("batchId");

--
-- Class PlatformJob as table raysto_platform_job
--
CREATE TABLE "raysto_platform_job" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint,
    "userId" text,
    "kind" text NOT NULL,
    "dedupeKey" text NOT NULL,
    "payloadJson" text NOT NULL,
    "state" text NOT NULL,
    "attempts" bigint NOT NULL,
    "availableAt" timestamp without time zone NOT NULL,
    "leaseToken" text,
    "leaseUntil" timestamp without time zone,
    "lastError" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "job_dedupe" ON "raysto_platform_job" USING btree ("dedupeKey");
CREATE INDEX "job_ready" ON "raysto_platform_job" USING btree ("state", "availableAt");

--
-- Class PriceQuote as table raysto_price_quote
--
CREATE TABLE "raysto_price_quote" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text NOT NULL,
    "visitId" bigint,
    "snapshotJson" text NOT NULL,
    "menuVersion" bigint NOT NULL,
    "totalMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "consumedOrderId" bigint,
    "assistantProposalId" bigint,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "quote_actor" ON "raysto_price_quote" USING btree ("userId", "createdAt");

--
-- Class ProviderInbox as table raysto_provider_inbox
--
CREATE TABLE "raysto_provider_inbox" (
    "id" bigserial PRIMARY KEY,
    "provider" text NOT NULL,
    "eventId" text NOT NULL,
    "eventType" text NOT NULL,
    "payloadJson" text NOT NULL,
    "status" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL,
    "processedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "inbox_provider_event" ON "raysto_provider_inbox" USING btree ("provider", "eventId");

--
-- Class RateWindow as table raysto_rate_window
--
CREATE TABLE "raysto_rate_window" (
    "id" bigserial PRIMARY KEY,
    "bucket" text NOT NULL,
    "windowStart" timestamp without time zone NOT NULL,
    "requests" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "rate_bucket" ON "raysto_rate_window" USING btree ("bucket", "windowStart");

--
-- Class RecipeLine as table raysto_recipe_line
--
CREATE TABLE "raysto_recipe_line" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "productId" bigint NOT NULL,
    "stockItemId" bigint NOT NULL,
    "quantity" double precision NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "recipe_line_product_item" ON "raysto_recipe_line" USING btree ("productId", "stockItemId");
CREATE INDEX "recipe_line_tenant" ON "raysto_recipe_line" USING btree ("restaurantId");

--
-- Class Restaurant as table raysto_restaurant
--
CREATE TABLE "raysto_restaurant" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "currency" text NOT NULL,
    "deliveryFeeMinor" bigint NOT NULL,
    "published" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- Class RestaurantGroup as table raysto_restaurant_group
--
CREATE TABLE "raysto_restaurant_group" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "ownerUserId" text NOT NULL,
    "currency" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "rgroup_owner" ON "raysto_restaurant_group" USING btree ("ownerUserId");

--
-- Class RestaurantPlan as table raysto_restaurant_plan
--
CREATE TABLE "raysto_restaurant_plan" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "version" bigint NOT NULL,
    "currency" text NOT NULL,
    "priceMinor" bigint NOT NULL,
    "commissionBps" bigint NOT NULL,
    "featuresJson" text NOT NULL,
    "providerPlanId" text,
    "active" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "plan_code_version" ON "raysto_restaurant_plan" USING btree ("code", "version");

--
-- Class RestaurantPolicy as table raysto_restaurant_policy
--
CREATE TABLE "raysto_restaurant_policy" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "settingsJson" text NOT NULL,
    "version" bigint NOT NULL,
    "menuVersion" bigint NOT NULL,
    "suspended" boolean NOT NULL,
    "orderSeq" bigint NOT NULL DEFAULT 0,
    "orderSeqDay" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "policy_restaurant" ON "raysto_restaurant_policy" USING btree ("restaurantId");

--
-- Class RestaurantSubscription as table raysto_restaurant_subscription
--
CREATE TABLE "raysto_restaurant_subscription" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "planId" bigint NOT NULL,
    "providerSubscriptionId" text,
    "status" text NOT NULL,
    "periodEndsAt" timestamp without time zone,
    "graceEndsAt" timestamp without time zone,
    "approvalUrl" text,
    "requestKey" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "subscription_restaurant" ON "raysto_restaurant_subscription" USING btree ("restaurantId");
CREATE UNIQUE INDEX "subscription_provider" ON "raysto_restaurant_subscription" USING btree ("providerSubscriptionId");

--
-- Class RoomMember as table raysto_room_member
--
CREATE TABLE "raysto_room_member" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "roomId" bigint NOT NULL,
    "userId" text NOT NULL,
    "lastReadSequence" bigint NOT NULL,
    "preferencesJson" text NOT NULL,
    "muted" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "room_member_user" ON "raysto_room_member" USING btree ("roomId", "userId");

--
-- Class RoomMessage as table raysto_room_message
--
CREATE TABLE "raysto_room_message" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "roomId" bigint NOT NULL,
    "sequence" bigint NOT NULL,
    "userId" text,
    "clientMessageId" text,
    "replyToId" bigint,
    "kind" text NOT NULL,
    "bodyJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "room_sequence" ON "raysto_room_message" USING btree ("roomId", "sequence");
CREATE UNIQUE INDEX "room_message_dedupe" ON "raysto_room_message" USING btree ("roomId", "userId", "clientMessageId");

--
-- Class SandboxPayment as table raysto_sandbox_payment
--
CREATE TABLE "raysto_sandbox_payment" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "requestKey" text NOT NULL,
    "providerRequestId" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "state" text NOT NULL,
    "providerOrderId" text,
    "approvalUrl" text,
    "captureId" text,
    "webhookEventId" text,
    "webhookReceivedAt" timestamp without time zone,
    "capturedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "sandbox_owner_request" ON "raysto_sandbox_payment" USING btree ("userId", "requestKey");
CREATE UNIQUE INDEX "sandbox_provider_order" ON "raysto_sandbox_payment" USING btree ("providerOrderId");
CREATE UNIQUE INDEX "sandbox_capture" ON "raysto_sandbox_payment" USING btree ("captureId");

--
-- Class SecurityGrant as table raysto_security_grant
--
CREATE TABLE "raysto_security_grant" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "kind" text NOT NULL,
    "proofHash" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "usedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "grant_proof" ON "raysto_security_grant" USING btree ("proofHash");

--
-- Class ServiceRequest as table raysto_service_request
--
CREATE TABLE "raysto_service_request" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "orderId" bigint NOT NULL,
    "customerId" text NOT NULL,
    "kind" text NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "service_order_kind" ON "raysto_service_request" USING btree ("orderId", "kind");

--
-- Class StaffShift as table raysto_staff_shift
--
CREATE TABLE "raysto_staff_shift" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "userId" text,
    "name" text NOT NULL,
    "role" text NOT NULL,
    "startsAt" timestamp without time zone NOT NULL,
    "endsAt" timestamp without time zone NOT NULL,
    "clockInAt" timestamp without time zone,
    "clockOutAt" timestamp without time zone,
    "hourlyRateMinor" bigint NOT NULL,
    "payoutEmail" text,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "staff_shift_tenant_start" ON "raysto_staff_shift" USING btree ("restaurantId", "startsAt");

--
-- Class StockItem as table raysto_stock_item
--
CREATE TABLE "raysto_stock_item" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "name" text NOT NULL,
    "unit" text NOT NULL,
    "quantity" double precision NOT NULL,
    "costMinor" bigint NOT NULL,
    "supplierId" bigint,
    "lowAt" double precision NOT NULL,
    "version" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "parLevel" double precision,
    "leadDays" bigint
);

-- Indexes
CREATE INDEX "stock_tenant" ON "raysto_stock_item" USING btree ("restaurantId", "name");

--
-- Class StockMovement as table raysto_stock_movement
--
CREATE TABLE "raysto_stock_movement" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "stockItemId" bigint NOT NULL,
    "kind" text NOT NULL,
    "quantity" double precision NOT NULL,
    "unitCostMinor" bigint,
    "refType" text NOT NULL,
    "refId" text NOT NULL,
    "at" timestamp without time zone NOT NULL,
    "userId" text
);

-- Indexes
CREATE UNIQUE INDEX "stock_move_ref" ON "raysto_stock_movement" USING btree ("refType", "refId", "stockItemId");
CREATE INDEX "stock_move_tenant_at" ON "raysto_stock_movement" USING btree ("restaurantId", "at");
CREATE INDEX "stock_move_item_at" ON "raysto_stock_movement" USING btree ("stockItemId", "at");

--
-- Class StudioLayout as table raysto_studio_layout
--
CREATE TABLE "raysto_studio_layout" (
    "id" bigserial PRIMARY KEY,
    "scope" text NOT NULL,
    "userId" text NOT NULL,
    "section" text NOT NULL,
    "stateJson" text NOT NULL,
    "version" bigint NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "studio_layout_key" ON "raysto_studio_layout" USING btree ("scope", "userId", "section");

--
-- Class Supplier as table raysto_supplier
--
CREATE TABLE "raysto_supplier" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "name" text NOT NULL,
    "payoutEmail" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text,
    "leadDays" bigint
);

-- Indexes
CREATE INDEX "supplier_tenant" ON "raysto_supplier" USING btree ("restaurantId", "name");

--
-- Class SupplierOrder as table raysto_supplier_order
--
CREATE TABLE "raysto_supplier_order" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "supplierId" bigint,
    "state" text NOT NULL,
    "linesJson" text NOT NULL,
    "totalMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "expectedAt" timestamp without time zone,
    "sentAt" timestamp without time zone,
    "receivedAt" timestamp without time zone,
    "billId" bigint,
    "taskId" bigint,
    "note" text,
    "createdBy" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "supplier_order_tenant_state" ON "raysto_supplier_order" USING btree ("restaurantId", "state");

--
-- Class SupplyDelivery as table raysto_supply_delivery
--
CREATE TABLE "raysto_supply_delivery" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "supplierId" bigint,
    "mediaId" bigint NOT NULL,
    "linesJson" text NOT NULL,
    "totalMinor" bigint NOT NULL,
    "currency" text NOT NULL,
    "state" text NOT NULL,
    "payoutBatchId" bigint,
    "taskId" bigint,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "supplierOrderId" bigint,
    "matchJson" text
);

-- Indexes
CREATE INDEX "delivery_tenant" ON "raysto_supply_delivery" USING btree ("restaurantId", "createdAt");

--
-- Class SupportConversation as table raysto_support_conversation
--
CREATE TABLE "raysto_support_conversation" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint,
    "orderId" bigint,
    "userId" text NOT NULL,
    "status" text NOT NULL,
    "subject" text NOT NULL,
    "escalated" boolean NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "conversation_actor" ON "raysto_support_conversation" USING btree ("userId", "createdAt");

--
-- Class SupportMessage as table raysto_support_message
--
CREATE TABLE "raysto_support_message" (
    "id" bigserial PRIMARY KEY,
    "conversationId" bigint NOT NULL,
    "userId" text NOT NULL,
    "text" text NOT NULL,
    "mediaId" bigint,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "message_thread" ON "raysto_support_message" USING btree ("conversationId", "createdAt");

--
-- Class UserNotification as table raysto_user_notification
--
CREATE TABLE "raysto_user_notification" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "restaurantId" bigint,
    "eventKey" text NOT NULL,
    "kind" text NOT NULL,
    "referenceJson" text NOT NULL,
    "readAt" timestamp without time zone,
    "dismissedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "notification_event_user" ON "raysto_user_notification" USING btree ("eventKey", "userId");

--
-- Class VisitParticipant as table raysto_visit_participant
--
CREATE TABLE "raysto_visit_participant" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "visitId" bigint NOT NULL,
    "userId" text NOT NULL,
    "active" boolean NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "participant_visit_user" ON "raysto_visit_participant" USING btree ("visitId", "userId");

--
-- Class VisitRequest as table raysto_visit_request
--
CREATE TABLE "raysto_visit_request" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "visitId" bigint NOT NULL,
    "userId" text NOT NULL,
    "kind" text NOT NULL,
    "status" text NOT NULL,
    "assignedUserId" text,
    "reason" text,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "visit_request_status" ON "raysto_visit_request" USING btree ("visitId", "status");

--
-- Class WebhookEvent as table raysto_webhook_event
--
CREATE TABLE "raysto_webhook_event" (
    "id" bigserial PRIMARY KEY,
    "providerEventId" text NOT NULL,
    "eventType" text NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "webhook_provider_event" ON "raysto_webhook_event" USING btree ("providerEventId");

--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectDownloadEntry as table serverpod_cloud_storage_direct_download
--
CREATE TABLE "serverpod_cloud_storage_direct_download" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "downloadFileName" text,
    "contentType" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_download_auth_key" ON "serverpod_cloud_storage_direct_download" USING btree ("authKey");
CREATE INDEX "serverpod_cloud_storage_direct_download_expiration" ON "serverpod_cloud_storage_direct_download" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "maxFileSize" bigint NOT NULL DEFAULT 10485760,
    "contentLength" bigint,
    "preventOverwrite" boolean NOT NULL DEFAULT false,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text,
    "scheduling" json
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class FutureCallClaimEntry as table serverpod_future_call_claim
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" bigserial PRIMARY KEY,
    "futureCallId" bigint,
    "lastHeartbeatTime" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" USING btree ("futureCallId");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId", "order");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" USING btree ("sessionLogId", "order");

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId", "order");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Class AnonymousAccount as table serverpod_auth_idp_anonymous_account
--
CREATE TABLE "serverpod_auth_idp_anonymous_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- Class AppleAccount as table serverpod_auth_idp_apple_account
--
CREATE TABLE "serverpod_auth_idp_apple_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userIdentifier" text NOT NULL,
    "refreshToken" text NOT NULL,
    "refreshTokenRequestedWithBundleIdentifier" boolean NOT NULL,
    "lastRefreshedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text,
    "isEmailVerified" boolean,
    "isPrivateEmail" boolean,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_apple_account_identifier" ON "serverpod_auth_idp_apple_account" USING btree ("userIdentifier");

--
-- Class EmailAccount as table serverpod_auth_idp_email_account
--
CREATE TABLE "serverpod_auth_idp_email_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "passwordHash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_email" ON "serverpod_auth_idp_email_account" USING btree ("email");

--
-- Class EmailAccountPasswordResetRequest as table serverpod_auth_idp_email_account_password_reset_request
--
CREATE TABLE "serverpod_auth_idp_email_account_password_reset_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "emailAccountId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "challengeId" uuid NOT NULL,
    "setPasswordChallengeId" uuid
);

--
-- Class EmailAccountRequest as table serverpod_auth_idp_email_account_request
--
CREATE TABLE "serverpod_auth_idp_email_account_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email" text NOT NULL,
    "challengeId" uuid NOT NULL,
    "createAccountChallengeId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_request_email" ON "serverpod_auth_idp_email_account_request" USING btree ("email");

--
-- Class FacebookAccount as table serverpod_auth_idp_facebook_account
--
CREATE TABLE "serverpod_auth_idp_facebook_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "fullName" text,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_facebook_account_user_identifier" ON "serverpod_auth_idp_facebook_account" USING btree ("userIdentifier");

--
-- Class FirebaseAccount as table serverpod_auth_idp_firebase_account
--
CREATE TABLE "serverpod_auth_idp_firebase_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text,
    "phone" text,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_firebase_account_user_identifier" ON "serverpod_auth_idp_firebase_account" USING btree ("userIdentifier");

--
-- Class GitHubAccount as table serverpod_auth_idp_github_account
--
CREATE TABLE "serverpod_auth_idp_github_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_github_account_user_identifier" ON "serverpod_auth_idp_github_account" USING btree ("userIdentifier");

--
-- Class GoogleAccount as table serverpod_auth_idp_google_account
--
CREATE TABLE "serverpod_auth_idp_google_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_google_account_user_identifier" ON "serverpod_auth_idp_google_account" USING btree ("userIdentifier");

--
-- Class MicrosoftAccount as table serverpod_auth_idp_microsoft_account
--
CREATE TABLE "serverpod_auth_idp_microsoft_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_microsoft_account_user_identifier" ON "serverpod_auth_idp_microsoft_account" USING btree ("userIdentifier");

--
-- Class PasskeyAccount as table serverpod_auth_idp_passkey_account
--
CREATE TABLE "serverpod_auth_idp_passkey_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "keyId" bytea NOT NULL,
    "keyIdBase64" text NOT NULL,
    "clientDataJSON" bytea NOT NULL,
    "attestationObject" bytea NOT NULL,
    "originalChallenge" bytea NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_passkey_account_key_id_base64" ON "serverpod_auth_idp_passkey_account" USING btree ("keyIdBase64");

--
-- Class PasskeyChallenge as table serverpod_auth_idp_passkey_challenge
--
CREATE TABLE "serverpod_auth_idp_passkey_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "challenge" bytea NOT NULL
);

--
-- Class RateLimitedRequestAttempt as table serverpod_auth_idp_rate_limited_request_attempt
--
CREATE TABLE "serverpod_auth_idp_rate_limited_request_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "domain" text NOT NULL,
    "source" text NOT NULL,
    "key" text NOT NULL,
    "ipAddress" text,
    "attemptedAt" timestamp without time zone NOT NULL,
    "extraData" json
);

-- Indexes
CREATE INDEX "serverpod_auth_idp_rate_limited_request_attempt_composite" ON "serverpod_auth_idp_rate_limited_request_attempt" USING btree ("domain", "source", "key", "attemptedAt");

--
-- Class SecretChallenge as table serverpod_auth_idp_secret_challenge
--
CREATE TABLE "serverpod_auth_idp_secret_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "challengeCodeHash" text NOT NULL
);

--
-- Class RefreshToken as table serverpod_auth_core_jwt_refresh_token
--
CREATE TABLE "serverpod_auth_core_jwt_refresh_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "extraClaims" text,
    "method" text NOT NULL,
    "fixedSecret" bytea NOT NULL,
    "rotatingSecretHash" text NOT NULL,
    "lastUpdatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "serverpod_auth_core_jwt_refresh_token_last_updated_at" ON "serverpod_auth_core_jwt_refresh_token" USING btree ("lastUpdatedAt");

--
-- Class UserProfile as table serverpod_auth_core_profile
--
CREATE TABLE "serverpod_auth_core_profile" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "imageId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_profile_user_profile_email_auth_user_id" ON "serverpod_auth_core_profile" USING btree ("authUserId");

--
-- Class UserProfileImage as table serverpod_auth_core_profile_image
--
CREATE TABLE "serverpod_auth_core_profile_image" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userProfileId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "url" text NOT NULL
);

--
-- Class ServerSideSession as table serverpod_auth_core_session
--
CREATE TABLE "serverpod_auth_core_session" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone,
    "expireAfterUnusedFor" bigint,
    "sessionKeyHash" bytea NOT NULL,
    "sessionKeySalt" bytea NOT NULL,
    "method" text NOT NULL
);

--
-- Class AuthUser as table serverpod_auth_core_user
--
CREATE TABLE "serverpod_auth_core_user" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

--
-- Foreign relations for "raysto_access_invitation" table
--
ALTER TABLE ONLY "raysto_access_invitation"
    ADD CONSTRAINT "raysto_access_invitation_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_agent_action" table
--
ALTER TABLE ONLY "raysto_agent_action"
    ADD CONSTRAINT "raysto_agent_action_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_agent_action"
    ADD CONSTRAINT "raysto_agent_action_fk_1"
    FOREIGN KEY("taskId")
    REFERENCES "raysto_agent_task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_agent_task" table
--
ALTER TABLE ONLY "raysto_agent_task"
    ADD CONSTRAINT "raysto_agent_task_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_ai_operation" table
--
ALTER TABLE ONLY "raysto_ai_operation"
    ADD CONSTRAINT "raysto_ai_operation_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_assistant_proposal" table
--
ALTER TABLE ONLY "raysto_assistant_proposal"
    ADD CONSTRAINT "raysto_assistant_proposal_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_assistant_proposal"
    ADD CONSTRAINT "raysto_assistant_proposal_fk_1"
    FOREIGN KEY("roomId")
    REFERENCES "raysto_conversation_room"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_assistant_proposal"
    ADD CONSTRAINT "raysto_assistant_proposal_fk_2"
    FOREIGN KEY("runId")
    REFERENCES "raysto_assistant_run"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_assistant_run" table
--
ALTER TABLE ONLY "raysto_assistant_run"
    ADD CONSTRAINT "raysto_assistant_run_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_assistant_run"
    ADD CONSTRAINT "raysto_assistant_run_fk_1"
    FOREIGN KEY("roomId")
    REFERENCES "raysto_conversation_room"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_bill" table
--
ALTER TABLE ONLY "raysto_bill"
    ADD CONSTRAINT "raysto_bill_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_bill_charge" table
--
ALTER TABLE ONLY "raysto_bill_charge"
    ADD CONSTRAINT "raysto_bill_charge_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_bill_charge"
    ADD CONSTRAINT "raysto_bill_charge_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_bill_split_plan" table
--
ALTER TABLE ONLY "raysto_bill_split_plan"
    ADD CONSTRAINT "raysto_bill_split_plan_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_bill_split_plan"
    ADD CONSTRAINT "raysto_bill_split_plan_fk_1"
    FOREIGN KEY("roomId")
    REFERENCES "raysto_conversation_room"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_billing_history" table
--
ALTER TABLE ONLY "raysto_billing_history"
    ADD CONSTRAINT "raysto_billing_history_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_catering_request" table
--
ALTER TABLE ONLY "raysto_catering_request"
    ADD CONSTRAINT "raysto_catering_request_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_checkout_intent" table
--
ALTER TABLE ONLY "raysto_checkout_intent"
    ADD CONSTRAINT "raysto_checkout_intent_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_checkout_intent"
    ADD CONSTRAINT "raysto_checkout_intent_fk_1"
    FOREIGN KEY("splitPlanId")
    REFERENCES "raysto_bill_split_plan"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_commission_entry" table
--
ALTER TABLE ONLY "raysto_commission_entry"
    ADD CONSTRAINT "raysto_commission_entry_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_commission_entry"
    ADD CONSTRAINT "raysto_commission_entry_fk_1"
    FOREIGN KEY("captureId")
    REFERENCES "raysto_payment_capture"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_complaint" table
--
ALTER TABLE ONLY "raysto_complaint"
    ADD CONSTRAINT "raysto_complaint_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_complaint"
    ADD CONSTRAINT "raysto_complaint_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_conversation_room" table
--
ALTER TABLE ONLY "raysto_conversation_room"
    ADD CONSTRAINT "raysto_conversation_room_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_conversation_room"
    ADD CONSTRAINT "raysto_conversation_room_fk_1"
    FOREIGN KEY("visitId")
    REFERENCES "raysto_dining_visit"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_conversation_room"
    ADD CONSTRAINT "raysto_conversation_room_fk_2"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_customer_cart" table
--
ALTER TABLE ONLY "raysto_customer_cart"
    ADD CONSTRAINT "raysto_customer_cart_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_customer_favorite" table
--
ALTER TABLE ONLY "raysto_customer_favorite"
    ADD CONSTRAINT "raysto_customer_favorite_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_customer_profile" table
--
ALTER TABLE ONLY "raysto_customer_profile"
    ADD CONSTRAINT "raysto_customer_profile_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_customer_review" table
--
ALTER TABLE ONLY "raysto_customer_review"
    ADD CONSTRAINT "raysto_customer_review_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_customer_review"
    ADD CONSTRAINT "raysto_customer_review_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_daily_close" table
--
ALTER TABLE ONLY "raysto_daily_close"
    ADD CONSTRAINT "raysto_daily_close_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_delivery_assignment" table
--
ALTER TABLE ONLY "raysto_delivery_assignment"
    ADD CONSTRAINT "raysto_delivery_assignment_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_delivery_assignment"
    ADD CONSTRAINT "raysto_delivery_assignment_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_delivery_offer" table
--
ALTER TABLE ONLY "raysto_delivery_offer"
    ADD CONSTRAINT "raysto_delivery_offer_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_delivery_offer"
    ADD CONSTRAINT "raysto_delivery_offer_fk_1"
    FOREIGN KEY("assignmentId")
    REFERENCES "raysto_delivery_assignment"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_delivery_offer"
    ADD CONSTRAINT "raysto_delivery_offer_fk_2"
    FOREIGN KEY("driverId")
    REFERENCES "raysto_driver"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_delivery_ping" table
--
ALTER TABLE ONLY "raysto_delivery_ping"
    ADD CONSTRAINT "raysto_delivery_ping_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_delivery_ping"
    ADD CONSTRAINT "raysto_delivery_ping_fk_1"
    FOREIGN KEY("assignmentId")
    REFERENCES "raysto_delivery_assignment"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_dining_reservation" table
--
ALTER TABLE ONLY "raysto_dining_reservation"
    ADD CONSTRAINT "raysto_dining_reservation_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_dining_reservation"
    ADD CONSTRAINT "raysto_dining_reservation_fk_1"
    FOREIGN KEY("tableId")
    REFERENCES "raysto_dining_table"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_dining_table" table
--
ALTER TABLE ONLY "raysto_dining_table"
    ADD CONSTRAINT "raysto_dining_table_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_dining_visit" table
--
ALTER TABLE ONLY "raysto_dining_visit"
    ADD CONSTRAINT "raysto_dining_visit_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_dining_visit"
    ADD CONSTRAINT "raysto_dining_visit_fk_1"
    FOREIGN KEY("tableId")
    REFERENCES "raysto_dining_table"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_dining_waitlist" table
--
ALTER TABLE ONLY "raysto_dining_waitlist"
    ADD CONSTRAINT "raysto_dining_waitlist_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_dispute_case" table
--
ALTER TABLE ONLY "raysto_dispute_case"
    ADD CONSTRAINT "raysto_dispute_case_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_driver" table
--
ALTER TABLE ONLY "raysto_driver"
    ADD CONSTRAINT "raysto_driver_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_expense" table
--
ALTER TABLE ONLY "raysto_expense"
    ADD CONSTRAINT "raysto_expense_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_floor_layout" table
--
ALTER TABLE ONLY "raysto_floor_layout"
    ADD CONSTRAINT "raysto_floor_layout_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_group_membership" table
--
ALTER TABLE ONLY "raysto_group_membership"
    ADD CONSTRAINT "raysto_group_membership_fk_0"
    FOREIGN KEY("groupId")
    REFERENCES "raysto_restaurant_group"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_group_venue" table
--
ALTER TABLE ONLY "raysto_group_venue"
    ADD CONSTRAINT "raysto_group_venue_fk_0"
    FOREIGN KEY("groupId")
    REFERENCES "raysto_restaurant_group"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_group_venue"
    ADD CONSTRAINT "raysto_group_venue_fk_1"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_kitchen_progress" table
--
ALTER TABLE ONLY "raysto_kitchen_progress"
    ADD CONSTRAINT "raysto_kitchen_progress_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_kitchen_progress"
    ADD CONSTRAINT "raysto_kitchen_progress_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_ledger_adjustment" table
--
ALTER TABLE ONLY "raysto_ledger_adjustment"
    ADD CONSTRAINT "raysto_ledger_adjustment_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_membership" table
--
ALTER TABLE ONLY "raysto_membership"
    ADD CONSTRAINT "raysto_membership_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_menu_definition" table
--
ALTER TABLE ONLY "raysto_menu_definition"
    ADD CONSTRAINT "raysto_menu_definition_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_menu_definition"
    ADD CONSTRAINT "raysto_menu_definition_fk_1"
    FOREIGN KEY("productId")
    REFERENCES "raysto_menu_product"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_menu_draft" table
--
ALTER TABLE ONLY "raysto_menu_draft"
    ADD CONSTRAINT "raysto_menu_draft_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_menu_product" table
--
ALTER TABLE ONLY "raysto_menu_product"
    ADD CONSTRAINT "raysto_menu_product_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_menu_template" table
--
ALTER TABLE ONLY "raysto_menu_template"
    ADD CONSTRAINT "raysto_menu_template_fk_0"
    FOREIGN KEY("groupId")
    REFERENCES "raysto_restaurant_group"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_merchant_app" table
--
ALTER TABLE ONLY "raysto_merchant_app"
    ADD CONSTRAINT "raysto_merchant_app_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_merchant_connection" table
--
ALTER TABLE ONLY "raysto_merchant_connection"
    ADD CONSTRAINT "raysto_merchant_connection_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_operations_layout" table
--
ALTER TABLE ONLY "raysto_operations_layout"
    ADD CONSTRAINT "raysto_operations_layout_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_order" table
--
ALTER TABLE ONLY "raysto_order"
    ADD CONSTRAINT "raysto_order_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_order_context" table
--
ALTER TABLE ONLY "raysto_order_context"
    ADD CONSTRAINT "raysto_order_context_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_order_context"
    ADD CONSTRAINT "raysto_order_context_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_outbox" table
--
ALTER TABLE ONLY "raysto_outbox"
    ADD CONSTRAINT "raysto_outbox_fk_0"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_partner_app" table
--
ALTER TABLE ONLY "raysto_partner_app"
    ADD CONSTRAINT "raysto_partner_app_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_partner_event" table
--
ALTER TABLE ONLY "raysto_partner_event"
    ADD CONSTRAINT "raysto_partner_event_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_partner_event"
    ADD CONSTRAINT "raysto_partner_event_fk_1"
    FOREIGN KEY("partnerAppId")
    REFERENCES "raysto_partner_app"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_allocation" table
--
ALTER TABLE ONLY "raysto_payment_allocation"
    ADD CONSTRAINT "raysto_payment_allocation_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_payment_allocation"
    ADD CONSTRAINT "raysto_payment_allocation_fk_1"
    FOREIGN KEY("checkoutId")
    REFERENCES "raysto_checkout_intent"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_payment_allocation"
    ADD CONSTRAINT "raysto_payment_allocation_fk_2"
    FOREIGN KEY("chargeId")
    REFERENCES "raysto_bill_charge"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_attempt" table
--
ALTER TABLE ONLY "raysto_payment_attempt"
    ADD CONSTRAINT "raysto_payment_attempt_fk_0"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_capture" table
--
ALTER TABLE ONLY "raysto_payment_capture"
    ADD CONSTRAINT "raysto_payment_capture_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_payment_capture"
    ADD CONSTRAINT "raysto_payment_capture_fk_1"
    FOREIGN KEY("checkoutId")
    REFERENCES "raysto_checkout_intent"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_exception" table
--
ALTER TABLE ONLY "raysto_payment_exception"
    ADD CONSTRAINT "raysto_payment_exception_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_payment_exception"
    ADD CONSTRAINT "raysto_payment_exception_fk_1"
    FOREIGN KEY("captureId")
    REFERENCES "raysto_payment_capture"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_receipt" table
--
ALTER TABLE ONLY "raysto_payment_receipt"
    ADD CONSTRAINT "raysto_payment_receipt_fk_0"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_refund" table
--
ALTER TABLE ONLY "raysto_payment_refund"
    ADD CONSTRAINT "raysto_payment_refund_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_payment_refund"
    ADD CONSTRAINT "raysto_payment_refund_fk_1"
    FOREIGN KEY("captureId")
    REFERENCES "raysto_payment_capture"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payment_request" table
--
ALTER TABLE ONLY "raysto_payment_request"
    ADD CONSTRAINT "raysto_payment_request_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payout_batch" table
--
ALTER TABLE ONLY "raysto_payout_batch"
    ADD CONSTRAINT "raysto_payout_batch_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_payout_item" table
--
ALTER TABLE ONLY "raysto_payout_item"
    ADD CONSTRAINT "raysto_payout_item_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_payout_item"
    ADD CONSTRAINT "raysto_payout_item_fk_1"
    FOREIGN KEY("batchId")
    REFERENCES "raysto_payout_batch"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_price_quote" table
--
ALTER TABLE ONLY "raysto_price_quote"
    ADD CONSTRAINT "raysto_price_quote_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_price_quote"
    ADD CONSTRAINT "raysto_price_quote_fk_1"
    FOREIGN KEY("assistantProposalId")
    REFERENCES "raysto_assistant_proposal"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_recipe_line" table
--
ALTER TABLE ONLY "raysto_recipe_line"
    ADD CONSTRAINT "raysto_recipe_line_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_restaurant_policy" table
--
ALTER TABLE ONLY "raysto_restaurant_policy"
    ADD CONSTRAINT "raysto_restaurant_policy_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_restaurant_subscription" table
--
ALTER TABLE ONLY "raysto_restaurant_subscription"
    ADD CONSTRAINT "raysto_restaurant_subscription_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_restaurant_subscription"
    ADD CONSTRAINT "raysto_restaurant_subscription_fk_1"
    FOREIGN KEY("planId")
    REFERENCES "raysto_restaurant_plan"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_room_member" table
--
ALTER TABLE ONLY "raysto_room_member"
    ADD CONSTRAINT "raysto_room_member_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_room_member"
    ADD CONSTRAINT "raysto_room_member_fk_1"
    FOREIGN KEY("roomId")
    REFERENCES "raysto_conversation_room"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_room_message" table
--
ALTER TABLE ONLY "raysto_room_message"
    ADD CONSTRAINT "raysto_room_message_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_room_message"
    ADD CONSTRAINT "raysto_room_message_fk_1"
    FOREIGN KEY("roomId")
    REFERENCES "raysto_conversation_room"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_room_message"
    ADD CONSTRAINT "raysto_room_message_fk_2"
    FOREIGN KEY("replyToId")
    REFERENCES "raysto_room_message"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_service_request" table
--
ALTER TABLE ONLY "raysto_service_request"
    ADD CONSTRAINT "raysto_service_request_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_service_request"
    ADD CONSTRAINT "raysto_service_request_fk_1"
    FOREIGN KEY("orderId")
    REFERENCES "raysto_order"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_staff_shift" table
--
ALTER TABLE ONLY "raysto_staff_shift"
    ADD CONSTRAINT "raysto_staff_shift_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_stock_item" table
--
ALTER TABLE ONLY "raysto_stock_item"
    ADD CONSTRAINT "raysto_stock_item_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_stock_movement" table
--
ALTER TABLE ONLY "raysto_stock_movement"
    ADD CONSTRAINT "raysto_stock_movement_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_supplier" table
--
ALTER TABLE ONLY "raysto_supplier"
    ADD CONSTRAINT "raysto_supplier_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_supplier_order" table
--
ALTER TABLE ONLY "raysto_supplier_order"
    ADD CONSTRAINT "raysto_supplier_order_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_supply_delivery" table
--
ALTER TABLE ONLY "raysto_supply_delivery"
    ADD CONSTRAINT "raysto_supply_delivery_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_support_message" table
--
ALTER TABLE ONLY "raysto_support_message"
    ADD CONSTRAINT "raysto_support_message_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "raysto_support_conversation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_visit_participant" table
--
ALTER TABLE ONLY "raysto_visit_participant"
    ADD CONSTRAINT "raysto_visit_participant_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_visit_participant"
    ADD CONSTRAINT "raysto_visit_participant_fk_1"
    FOREIGN KEY("visitId")
    REFERENCES "raysto_dining_visit"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "raysto_visit_request" table
--
ALTER TABLE ONLY "raysto_visit_request"
    ADD CONSTRAINT "raysto_visit_request_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "raysto_visit_request"
    ADD CONSTRAINT "raysto_visit_request_fk_1"
    FOREIGN KEY("visitId")
    REFERENCES "raysto_dining_visit"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_future_call_claim" table
--
ALTER TABLE ONLY "serverpod_future_call_claim"
    ADD CONSTRAINT "serverpod_future_call_claim_fk_0"
    FOREIGN KEY("futureCallId")
    REFERENCES "serverpod_future_call"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_anonymous_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_anonymous_account"
    ADD CONSTRAINT "serverpod_auth_idp_anonymous_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_apple_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_apple_account"
    ADD CONSTRAINT "serverpod_auth_idp_apple_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_password_reset_request" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_0"
    FOREIGN KEY("emailAccountId")
    REFERENCES "serverpod_auth_idp_email_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_1"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_2"
    FOREIGN KEY("setPasswordChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_request" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_0"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_1"
    FOREIGN KEY("createAccountChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_facebook_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_facebook_account"
    ADD CONSTRAINT "serverpod_auth_idp_facebook_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_firebase_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_firebase_account"
    ADD CONSTRAINT "serverpod_auth_idp_firebase_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_github_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_github_account"
    ADD CONSTRAINT "serverpod_auth_idp_github_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_google_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_google_account"
    ADD CONSTRAINT "serverpod_auth_idp_google_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_microsoft_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_microsoft_account"
    ADD CONSTRAINT "serverpod_auth_idp_microsoft_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_passkey_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_passkey_account"
    ADD CONSTRAINT "serverpod_auth_idp_passkey_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_jwt_refresh_token" table
--
ALTER TABLE ONLY "serverpod_auth_core_jwt_refresh_token"
    ADD CONSTRAINT "serverpod_auth_core_jwt_refresh_token_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_1"
    FOREIGN KEY("imageId")
    REFERENCES "serverpod_auth_core_profile_image"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

--
-- Foreign relations for "serverpod_auth_core_profile_image" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile_image"
    ADD CONSTRAINT "serverpod_auth_core_profile_image_fk_0"
    FOREIGN KEY("userProfileId")
    REFERENCES "serverpod_auth_core_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_session" table
--
ALTER TABLE ONLY "serverpod_auth_core_session"
    ADD CONSTRAINT "serverpod_auth_core_session_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261104152814507', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104152814507', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
