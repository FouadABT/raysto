BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_merchant_app"
    ADD CONSTRAINT "raysto_merchant_app_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
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
