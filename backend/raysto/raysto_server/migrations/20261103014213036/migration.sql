BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "stock_tenant" ON "raysto_stock_item" USING btree ("restaurantId", "name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "raysto_supplier" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "name" text NOT NULL,
    "payoutEmail" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "supplier_tenant" ON "raysto_supplier" USING btree ("restaurantId", "name");

--
-- ACTION CREATE TABLE
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
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "delivery_tenant" ON "raysto_supply_delivery" USING btree ("restaurantId", "createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_catering_request"
    ADD CONSTRAINT "raysto_catering_request_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_customer_profile"
    ADD CONSTRAINT "raysto_customer_profile_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_daily_close"
    ADD CONSTRAINT "raysto_daily_close_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_dispute_case"
    ADD CONSTRAINT "raysto_dispute_case_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_expense"
    ADD CONSTRAINT "raysto_expense_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_payout_batch"
    ADD CONSTRAINT "raysto_payout_batch_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_staff_shift"
    ADD CONSTRAINT "raysto_staff_shift_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_stock_item"
    ADD CONSTRAINT "raysto_stock_item_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_supplier"
    ADD CONSTRAINT "raysto_supplier_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_supply_delivery"
    ADD CONSTRAINT "raysto_supply_delivery_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261103014213036', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103014213036', "timestamp" = now();

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
