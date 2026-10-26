BEGIN;

--
-- ACTION CREATE TABLE
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
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261025133602556', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025133602556', "timestamp" = now();

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
