"""Additive upgrade check on the dedicated Raysto Docker cluster only.

No connection strings or production database names are accepted. The unique
database created here is the only database this script may drop.
"""
import pathlib
import subprocess
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTAINER = "raysto-backend-postgres"
DATABASE = "raysto_017_upgrade_" + uuid.uuid4().hex[:12]
MIGRATIONS = ROOT / "backend/raysto/raysto_server/migrations"


def docker(*args, **kwargs):
    return subprocess.run(
        ["docker", "--context", "desktop-linux", "exec", "-i", CONTAINER, *args],
        check=True, **kwargs,
    )


def sql(content):
    docker("psql", "-U", "raysto", "-d", DATABASE, "-v", "ON_ERROR_STOP=1",
           input=content.encode(), stdout=subprocess.DEVNULL)


docker("createdb", "-U", "raysto", DATABASE)
try:
    sql((MIGRATIONS / "20261104152814507/definition.sql").read_text())
    sql('''
      INSERT INTO raysto_restaurant (id,name,currency,"deliveryFeeMinor",published,"createdAt")
        VALUES (170001,'Isolated upgrade fixture','USD',0,false,now());
      INSERT INTO raysto_stock_movement
        (id,"restaurantId","stockItemId",kind,quantity,"unitCostMinor","refType","refId",at)
        VALUES (170001,170001,170001,'receive',1.25,1100,'fixture','immutable-receipt',now());
    ''')
    for migration in ["20261105161345704", "20261105193140136"]:
        sql((MIGRATIONS / migration / "migration.sql").read_text())
    sql('''
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM raysto_stock_movement WHERE id=170001
          AND quantity=1.25 AND "unitCostMinor"=1100 AND "purchaseUnit" IS NULL
          AND "refId"='immutable-receipt') THEN
          RAISE EXCEPTION 'Legacy receipt changed during migration';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='finance_record_key') THEN
          RAISE EXCEPTION 'Missing tenant/record uniqueness';
        END IF;
      END $$;
      -- The previous application can still insert without knowing the new column.
      INSERT INTO raysto_stock_movement
        ("restaurantId","stockItemId",kind,quantity,"unitCostMinor","refType","refId",at)
        VALUES (170001,170001,'receive',2,1200,'fixture','old-client-after-upgrade',now());
      INSERT INTO raysto_finance_record
        ("restaurantId",kind,"recordKey","payloadJson","createdBy",version,"createdAt","updatedAt")
        VALUES (170001,'fixture','same-key','{}','fixture',1,now(),now());
      DO $$ BEGIN
        BEGIN
          INSERT INTO raysto_finance_record
            ("restaurantId",kind,"recordKey","payloadJson","createdBy",version,"createdAt","updatedAt")
            VALUES (170001,'fixture','same-key','{}','fixture',1,now(),now());
          RAISE EXCEPTION 'Duplicate key was accepted';
        EXCEPTION WHEN unique_violation THEN NULL;
        END;
      END $$;
    ''')
    print("PASS: baseline upgrade, preserved receipt, unknown legacy unit, old-writer compatibility and unique records.")
finally:
    assert DATABASE.startswith("raysto_017_upgrade_")
    docker("dropdb", "-U", "raysto", DATABASE)
