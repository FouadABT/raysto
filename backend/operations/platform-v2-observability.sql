-- Read-only, prepared queries. Execute only against the selected Raysto database.
SELECT state,count(*),min("createdAt") AS oldest FROM raysto_checkout_intent GROUP BY state;
SELECT state,kind,count(*),min("availableAt") AS oldest FROM raysto_platform_job GROUP BY state,kind;
SELECT status,provider,count(*),min("receivedAt") AS oldest FROM raysto_provider_inbox GROUP BY status,provider;
SELECT status,count(*),min("graceEndsAt") AS earliest_grace_end FROM raysto_restaurant_subscription GROUP BY status;
SELECT "restaurantId",sum("inputTokens") AS input_tokens,sum("outputTokens") AS output_tokens,count(*) AS operations FROM raysto_ai_operation WHERE "createdAt">CURRENT_TIMESTAMP-INTERVAL '1 day' GROUP BY "restaurantId";
SELECT id,"restaurantId","amountMinor","creditedMinor","settledMinor","reservedMinor" FROM raysto_bill_charge WHERE "reservedMinor"<0 OR "settledMinor"<0 OR "creditedMinor"<0 OR "settledMinor">"amountMinor" OR "reservedMinor">GREATEST(0,"amountMinor"-"creditedMinor"-"settledMinor");
