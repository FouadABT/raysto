BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_membership" ADD COLUMN "capabilities" json;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_order_context" ADD COLUMN "origin" text NOT NULL DEFAULT 'online'::text;
ALTER TABLE "raysto_order_context" ADD COLUMN "customerLabel" text;
ALTER TABLE "raysto_order_context" ADD COLUMN "placedBy" text;
ALTER TABLE "raysto_order_context" ADD COLUMN "serviceDay" text;
ALTER TABLE "raysto_order_context" ADD COLUMN "orderNumber" bigint;
ALTER TABLE "raysto_order_context" ADD COLUMN "pickupCode" text;
CREATE UNIQUE INDEX "context_daily_number" ON "raysto_order_context" USING btree ("restaurantId", "serviceDay", "orderNumber");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "raysto_restaurant_policy" ADD COLUMN "orderSeq" bigint NOT NULL DEFAULT 0;
ALTER TABLE "raysto_restaurant_policy" ADD COLUMN "orderSeqDay" text;

--
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261028134922094', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261028134922094', "timestamp" = now();

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
