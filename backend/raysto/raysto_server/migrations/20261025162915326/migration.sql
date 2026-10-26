BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_billing_history"
    ADD CONSTRAINT "raysto_billing_history_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
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
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261025162915326', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025162915326', "timestamp" = now();

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
