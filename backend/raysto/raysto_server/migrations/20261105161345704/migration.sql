BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "raysto_finance_record" (
    "id" bigserial PRIMARY KEY,
    "restaurantId" bigint NOT NULL,
    "kind" text NOT NULL,
    "recordKey" text NOT NULL,
    "payloadJson" text NOT NULL,
    "createdBy" text NOT NULL,
    "version" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "finance_record_key" ON "raysto_finance_record" USING btree ("restaurantId", "kind", "recordKey");
CREATE INDEX "finance_record_page" ON "raysto_finance_record" USING btree ("restaurantId", "kind", "id");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "raysto_finance_record"
    ADD CONSTRAINT "raysto_finance_record_fk_0"
    FOREIGN KEY("restaurantId")
    REFERENCES "raysto_restaurant"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR raysto
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('raysto', '20261105161345704', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105161345704', "timestamp" = now();

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
