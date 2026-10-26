-- PREPARED ONLY. Run after backup, generated migrations and constraints.
-- Historical money evidence is copied; legacy order workflows are not switched.
BEGIN;
DO $$ BEGIN IF current_database() !~ '^raysto([_-].*)?$' THEN RAISE EXCEPTION 'Refusing non-Raysto database'; END IF; END $$;
DO $$ BEGIN
  IF EXISTS(SELECT 1 FROM raysto_payment_receipt r LEFT JOIN raysto_payment_attempt a ON a."orderId"=r."orderId" WHERE a.id IS NULL OR a."providerOrderId" IS NULL) THEN
    RAISE EXCEPTION 'Reconcile historical receipts missing provider attempts before backfill';
  END IF;
END $$;
INSERT INTO raysto_bill_charge("restaurantId","orderId","lineKey",kind,"amountMinor","creditedMinor","settledMinor","reservedMinor","foodNetMinor",version)
SELECT o."restaurantId",o.id,'legacy:whole','legacyWholeOrder',r."amountMinor",0,r."amountMinor",0,0,1
FROM raysto_payment_receipt r JOIN raysto_order o ON o.id=r."orderId"
ON CONFLICT ("orderId","lineKey") DO NOTHING;

INSERT INTO raysto_checkout_intent("restaurantId","userId","orderId","requestKey","requestHash","providerRequestId","providerOrderId","merchantId",state,method,currency,"amountMinor","commissionMinor","commissionBps","createdAt","updatedAt")
SELECT o."restaurantId",o."customerId",o.id,'legacy-receipt-'||r.id,'legacy-import',a."requestId",a."providerOrderId",'legacy-single-merchant','completed','paypal',r.currency,r."amountMinor",0,0,r."createdAt",r."createdAt"
FROM raysto_payment_receipt r JOIN raysto_order o ON o.id=r."orderId" JOIN raysto_payment_attempt a ON a."orderId"=o.id
ON CONFLICT DO NOTHING;

INSERT INTO raysto_payment_allocation("restaurantId","checkoutId","chargeId","amountMinor","foodNetMinor","refundedMinor",state)
SELECT i."restaurantId",i.id,b.id,b."amountMinor",0,0,'settled' FROM raysto_checkout_intent i JOIN raysto_bill_charge b ON b."orderId"=i."orderId" AND b."lineKey"='legacy:whole'
WHERE i."requestKey" LIKE 'legacy-receipt-%' ON CONFLICT DO NOTHING;

INSERT INTO raysto_payment_capture("restaurantId","checkoutId","providerCaptureId","amountMinor","refundedMinor",currency,state,"createdAt")
SELECT i."restaurantId",i.id,r."captureId",r."amountMinor",0,r.currency,'completed',r."createdAt" FROM raysto_checkout_intent i JOIN raysto_payment_receipt r ON r."orderId"=i."orderId"
WHERE i."requestKey" LIKE 'legacy-receipt-%' ON CONFLICT DO NOTHING;

-- Pending attempts enter an evidence inbox without creating replacement orders.
-- They remain on the existing PaymentService reconcile path until a deliberate cutover.
INSERT INTO raysto_provider_inbox(provider,"eventId","eventType","payloadJson",status,"receivedAt")
SELECT 'legacy-paypal','attempt-'||a.id,'LEGACY.PENDING',json_build_object('orderId',a."orderId",'providerOrderId',a."providerOrderId",'requestId',a."requestId")::text,'operatorReview',CURRENT_TIMESTAMP
FROM raysto_payment_attempt a LEFT JOIN raysto_payment_receipt r ON r."orderId"=a."orderId" WHERE r.id IS NULL ON CONFLICT DO NOTHING;
COMMIT;
