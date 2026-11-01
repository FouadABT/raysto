BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_ai_spend_entry" ADD COLUMN "feature" text;
ALTER TABLE "raysto_ai_spend_entry" ADD COLUMN "restaurantId" bigint;
--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_agent_task"
    ADD CONSTRAINT "raysto_agent_task_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261101152217899', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261101152217899', "timestamp" = now();

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
