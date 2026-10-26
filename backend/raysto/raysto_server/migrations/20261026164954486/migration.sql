BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "raysto_ai_spend_entry" (
    "id" bigserial PRIMARY KEY,
    "sourceKey" text NOT NULL,
    "stage" text NOT NULL,
    "reservedMicros" bigint NOT NULL,
    "chargedMicros" bigint NOT NULL,
    "settled" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "spend_source" ON "raysto_ai_spend_entry" USING btree ("sourceKey");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_checkout_intent" ADD COLUMN "providerMode" text NOT NULL DEFAULT 'marketplace'::text;
ALTER TABLE "raysto_checkout_intent" ADD COLUMN "splitPlanId" bigint;
--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_price_quote" ADD COLUMN "assistantProposalId" bigint;
--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_checkout_intent"
    ADD CONSTRAINT "raysto_checkout_intent_fk_1"
    FOREIGN KEY("splitPlanId")
    REFERENCES "raysto_bill_split_plan"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_operations_layout"
    ADD CONSTRAINT "raysto_operations_layout_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_price_quote"
    ADD CONSTRAINT "raysto_price_quote_fk_1"
    FOREIGN KEY("assistantProposalId")
    REFERENCES "raysto_assistant_proposal"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
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
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261026164954486', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261026164954486', "timestamp" = now();

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
