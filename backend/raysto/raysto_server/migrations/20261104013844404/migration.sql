BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "driverId" bigint;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "partnerAppId" bigint;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "partnerRef" text;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "fulfilledBy" text;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "etaAt" timestamp without time zone;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "distanceMeters" bigint;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "feeMinor" bigint;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "proofKind" text;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "proofMediaId" bigint;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "codeHash" text;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "pickedUpAt" timestamp without time zone;
ALTER TABLE "raysto_delivery_assignment" ADD COLUMN "deliveredAt" timestamp without time zone;
--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_stock_item" ADD COLUMN "parLevel" double precision;
ALTER TABLE "raysto_stock_item" ADD COLUMN "leadDays" bigint;
--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_supplier" ADD COLUMN "email" text;
ALTER TABLE "raysto_supplier" ADD COLUMN "leadDays" bigint;
--
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_supply_delivery" ADD COLUMN "supplierOrderId" bigint;
ALTER TABLE "raysto_supply_delivery" ADD COLUMN "matchJson" text;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_bill"
    ADD CONSTRAINT "raysto_bill_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_driver"
    ADD CONSTRAINT "raysto_driver_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_group_membership"
    ADD CONSTRAINT "raysto_group_membership_fk_0"
    FOREIGN KEY("groupId")
    REFERENCES "raysto_restaurant_group"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_ledger_adjustment"
    ADD CONSTRAINT "raysto_ledger_adjustment_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_menu_template"
    ADD CONSTRAINT "raysto_menu_template_fk_0"
    FOREIGN KEY("groupId")
    REFERENCES "raysto_restaurant_group"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_partner_app"
    ADD CONSTRAINT "raysto_partner_app_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_payment_request"
    ADD CONSTRAINT "raysto_payment_request_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_recipe_line"
    ADD CONSTRAINT "raysto_recipe_line_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_stock_movement"
    ADD CONSTRAINT "raysto_stock_movement_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_supplier_order"
    ADD CONSTRAINT "raysto_supplier_order_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261104013844404', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104013844404', "timestamp" = now();

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
