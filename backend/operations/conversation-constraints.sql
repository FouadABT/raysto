-- Additive supplement, after Serverpod migration 20261026164954486.
-- Apply to Raysto only, with the migration role. PostgreSQL 16+.
BEGIN;
DO $$ BEGIN
  IF current_database() !~ '^raysto([_-].*)?$' THEN
    RAISE EXCEPTION 'Refusing non-Raysto database';
  END IF;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS room_tenant_pair ON raysto_conversation_room(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS assistant_run_tenant_pair ON raysto_assistant_run(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS assistant_proposal_tenant_pair ON raysto_assistant_proposal(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS split_plan_tenant_pair ON raysto_bill_split_plan(id,"restaurantId");
CREATE UNIQUE INDEX IF NOT EXISTS room_message_room_pair ON raysto_room_message(id,"roomId");
DO $$ DECLARE e record; BEGIN
  FOR e IN SELECT * FROM (VALUES
    ('raysto_conversation_room','visitId','raysto_dining_visit'),
    ('raysto_conversation_room','orderId','raysto_order'),
    ('raysto_room_member','roomId','raysto_conversation_room'),
    ('raysto_room_message','roomId','raysto_conversation_room'),
    ('raysto_assistant_run','roomId','raysto_conversation_room'),
    ('raysto_assistant_proposal','roomId','raysto_conversation_room'),
    ('raysto_assistant_proposal','runId','raysto_assistant_run'),
    ('raysto_bill_split_plan','roomId','raysto_conversation_room'),
    ('raysto_checkout_intent','splitPlanId','raysto_bill_split_plan'),
    ('raysto_price_quote','assistantProposalId','raysto_assistant_proposal')
  ) AS edges(child,field,parent) LOOP
    IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname=e.child||'_'||e.field||'_tenant_fk') THEN
      EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (%I,"restaurantId") REFERENCES %I(id,"restaurantId")',e.child,e.child||'_'||e.field||'_tenant_fk',e.field,e.parent);
    END IF;
  END LOOP;
  IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='room_reply_same_room') THEN
    ALTER TABLE raysto_room_message ADD CONSTRAINT room_reply_same_room FOREIGN KEY ("replyToId","roomId") REFERENCES raysto_room_message(id,"roomId");
  END IF;
END $$;
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT * FROM (VALUES
    ('raysto_conversation_room','room_single_context','("visitId" IS NULL) <> ("orderId" IS NULL) AND sequence>=0 AND version>0'),
    ('raysto_room_member','room_cursor_nonnegative','"lastReadSequence">=0'),
    ('raysto_room_message','room_sequence_positive','sequence>0'),
    ('raysto_bill_split_plan','split_active_pointer','"activeRoomId" IS NULL OR "activeRoomId"="roomId"'),
    ('raysto_ai_spend_budget','ai_budget_nonnegative','"limitMicros">=0 AND "reservedMicros">=0 AND "spentMicros">=0'),
    ('raysto_ai_spend_entry','ai_cost_nonnegative','"reservedMicros">=0 AND "chargedMicros">=0'),
    ('raysto_checkout_intent','checkout_provider_mode','"providerMode" IN (''marketplace'',''singleMerchantSandbox'')')
  ) AS checks(tab,name,expression) LOOP
    IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname=r.name) THEN
      EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I CHECK (%s)',r.tab,r.name,r.expression);
    END IF;
  END LOOP;
END $$;
COMMIT;
