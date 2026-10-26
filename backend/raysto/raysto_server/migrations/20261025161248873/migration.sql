BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "delivery_order" ON "raysto_delivery_assignment" USING btree ("orderId");
CREATE INDEX "delivery_courier" ON "raysto_delivery_assignment" USING btree ("courierId", "status");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "context_order" ON "raysto_order_context" USING btree ("orderId");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "quote_actor" ON "raysto_price_quote" USING btree ("userId", "createdAt");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "raysto_restaurant_policy" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "settingsJson" text NOT NULL,
    "version" bigint NOT NULL,
    "menuVersion" bigint NOT NULL,
    "suspended" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "policy_restaurant" ON "raysto_restaurant_policy" USING btree ("restaurantId");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_access_invitation"
    ADD CONSTRAINT "raysto_access_invitation_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_ai_operation"
    ADD CONSTRAINT "raysto_ai_operation_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_checkout_intent"
    ADD CONSTRAINT "raysto_checkout_intent_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_customer_cart"
    ADD CONSTRAINT "raysto_customer_cart_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_customer_favorite"
    ADD CONSTRAINT "raysto_customer_favorite_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_dining_table"
    ADD CONSTRAINT "raysto_dining_table_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_dining_waitlist"
    ADD CONSTRAINT "raysto_dining_waitlist_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_floor_layout"
    ADD CONSTRAINT "raysto_floor_layout_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_menu_draft"
    ADD CONSTRAINT "raysto_menu_draft_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_merchant_connection"
    ADD CONSTRAINT "raysto_merchant_connection_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_price_quote"
    ADD CONSTRAINT "raysto_price_quote_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_restaurant_policy"
    ADD CONSTRAINT "raysto_restaurant_policy_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_support_message"
    ADD CONSTRAINT "raysto_support_message_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "raysto_support_conversation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261025161248873', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025161248873', "timestamp" = now();

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
