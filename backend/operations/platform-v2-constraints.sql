-- PREPARED ONLY. Apply with the Raysto migration role AFTER generated migrations.
-- Apply this supplement to fresh databases as well as upgrades. PostgreSQL 16+.
-- This never creates databases, alters the cluster or touches Awhar.
BEGIN;
DO $$ BEGIN
  IF current_database() !~ '^raysto([_-].*)?$' THEN
    RAISE EXCEPTION 'Refusing non-Raysto database';
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS raysto_order_tenant_pair ON raysto_order(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS raysto_menu_tenant_pair ON raysto_menu_product(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS raysto_table_tenant_pair ON raysto_dining_table(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS raysto_visit_tenant_pair ON raysto_dining_visit(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS raysto_charge_tenant_pair ON raysto_bill_charge(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS raysto_checkout_tenant_pair ON raysto_checkout_intent(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS raysto_capture_tenant_pair ON raysto_payment_capture(id,"restaurantId");

DO $$
DECLARE relation record;
BEGIN
  FOR relation IN SELECT * FROM (VALUES
    ('raysto_menu_definition','productId','raysto_menu_product'),
    ('raysto_dining_visit','tableId','raysto_dining_table'),
    ('raysto_visit_participant','visitId','raysto_dining_visit'),
    ('raysto_dining_reservation','tableId','raysto_dining_table'),
    ('raysto_visit_request','visitId','raysto_dining_visit'),
    ('raysto_order_context','orderId','raysto_order'),
    ('raysto_order_context','visitId','raysto_dining_visit'),
    ('raysto_bill_charge','orderId','raysto_order'),
    ('raysto_bill_charge','visitId','raysto_dining_visit'),
    ('raysto_checkout_intent','visitId','raysto_dining_visit'),
    ('raysto_checkout_intent','orderId','raysto_order'),
    ('raysto_payment_allocation','checkoutId','raysto_checkout_intent'),
    ('raysto_payment_allocation','chargeId','raysto_bill_charge'),
    ('raysto_payment_capture','checkoutId','raysto_checkout_intent'),
    ('raysto_payment_refund','captureId','raysto_payment_capture'),
    ('raysto_payment_exception','captureId','raysto_payment_capture'),
    ('raysto_commission_entry','captureId','raysto_payment_capture'),
    ('raysto_kitchen_progress','orderId','raysto_order'),
    ('raysto_delivery_assignment','orderId','raysto_order'),
    ('raysto_customer_review','orderId','raysto_order')
  ) AS edges(child,field,parent)
  LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname=relation.child||'_'||relation.field||'_tenant_fk') THEN
      EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (%I,"restaurantId") REFERENCES %I(id,"restaurantId") NOT VALID',relation.child,relation.child||'_'||relation.field||'_tenant_fk',relation.field,relation.parent);
      EXECUTE format('ALTER TABLE %I VALIDATE CONSTRAINT %I',relation.child,relation.child||'_'||relation.field||'_tenant_fk');
    END IF;
  END LOOP;
END $$;

DO $$
DECLARE rule record;
BEGIN
  FOR rule IN SELECT * FROM (VALUES
    ('raysto_bill_charge','bill_nonnegative','"amountMinor">=0 AND "creditedMinor">=0 AND "creditedMinor"<="amountMinor" AND "settledMinor">=0 AND "reservedMinor">=0 AND "reservedMinor"<=GREATEST(0,"amountMinor"-"creditedMinor"-"settledMinor") AND "settledMinor"<="amountMinor" AND "foodNetMinor">=0'),
    ('raysto_checkout_intent','checkout_money','"amountMinor">0 AND "commissionMinor">=0 AND "commissionMinor"<="amountMinor" AND currency IN (''EUR'',''USD'',''GBP'')'),
    ('raysto_payment_capture','capture_money','"amountMinor">0 AND "refundedMinor">=0 AND "refundedMinor"<="amountMinor"'),
    ('raysto_payment_allocation','allocation_money','"amountMinor">0 AND "refundedMinor">=0 AND "refundedMinor"<="amountMinor"'),
    ('raysto_payment_refund','refund_money','"amountMinor">0 AND "commissionMinor">=0 AND "commissionMinor"<="amountMinor"'),
    ('raysto_dining_table','table_capacity','capacity BETWEEN 1 AND 100'),
    ('raysto_dining_visit','active_visit_pointer','(status=''active'')=("activeTableId" IS NOT NULL) AND ("activeTableId" IS NULL OR "activeTableId"="tableId")'),
    ('raysto_dining_reservation','booking_times','"startsAt"<"endsAt" AND "partySize">0'),
    ('raysto_menu_definition','stock_nonnegative','"stockRemaining" IS NULL OR "stockRemaining">=0'),
    ('raysto_kitchen_progress','kitchen_quantity','quantity>0 AND "completedQuantity">=0 AND "completedQuantity"<=quantity')
  ) AS checks(tab,name,expression)
  LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname=rule.name) THEN
      EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I CHECK (%s) NOT VALID',rule.tab,rule.name,rule.expression);
      EXECUTE format('ALTER TABLE %I VALIDATE CONSTRAINT %I',rule.tab,rule.name);
    END IF;
  END LOOP;
END $$;

CREATE INDEX IF NOT EXISTS raysto_discovery_name ON raysto_restaurant USING gin(to_tsvector('simple',name)) WHERE published;
CREATE INDEX IF NOT EXISTS raysto_discovery_dish ON raysto_menu_product USING gin(to_tsvector('simple',name)) WHERE available;
CREATE INDEX IF NOT EXISTS raysto_order_timeline ON raysto_audit_record("restaurantId","entityType","entityId",id);
CREATE INDEX IF NOT EXISTS raysto_notification_cursor ON raysto_user_notification("userId",id);
CREATE INDEX IF NOT EXISTS raysto_job_claim ON raysto_platform_job(state,"availableAt",id);
CREATE INDEX IF NOT EXISTS raysto_reservation_overlap ON raysto_dining_reservation("restaurantId","tableId","startsAt","endsAt");
CREATE INDEX IF NOT EXISTS raysto_coupon_redemptions ON raysto_order_context("restaurantId","couponCode");

CREATE OR REPLACE FUNCTION raysto_audit_append_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'Audit records are append-only'; END $$;
DROP TRIGGER IF EXISTS raysto_audit_no_edit ON raysto_audit_record;
CREATE TRIGGER raysto_audit_no_edit BEFORE UPDATE OR DELETE ON raysto_audit_record FOR EACH ROW EXECUTE FUNCTION raysto_audit_append_only();

CREATE OR REPLACE FUNCTION raysto_currency_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.currency IS DISTINCT FROM OLD.currency AND EXISTS(SELECT 1 FROM raysto_order WHERE "restaurantId"=OLD.id) THEN
    RAISE EXCEPTION 'Restaurant currency is frozen after an order';
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS raysto_freeze_currency ON raysto_restaurant;
CREATE TRIGGER raysto_freeze_currency BEFORE UPDATE ON raysto_restaurant FOR EACH ROW EXECUTE FUNCTION raysto_currency_immutable();
COMMIT;
