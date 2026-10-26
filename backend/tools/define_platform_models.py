"""Source schema authoring utility. Serverpod alone generates Dart bindings."""
from pathlib import Path

root = Path(__file__).resolve().parents[1] / 'raysto/raysto_server/lib/src/models/platform'
root.mkdir(parents=True, exist_ok=True)
models = {
 'ActorProfile': ('actor_profile', '''userId: String
firebaseUid: String?
isGuest: bool
disabled: bool
claimedBy: String?
dataJson: String
version: int
createdAt: DateTime
updatedAt: DateTime''', [('actor_user', 'userId', True)]),
 'RestaurantPolicy': ('restaurant_policy', '''restaurantId: int, relation(parent=raysto_restaurant)
settingsJson: String
version: int
menuVersion: int
suspended: bool
createdAt: DateTime
updatedAt: DateTime''', [('policy_restaurant','restaurantId',True)]),
 'MenuDefinition': ('menu_definition', '''restaurantId: int, relation(parent=raysto_restaurant)
productId: int, relation(parent=raysto_menu_product)
category: String
definitionJson: String
archived: bool
stockRemaining: int?
version: int''', [('definition_product','productId',True),('definition_category','restaurantId, category',False)]),
 'MenuDraft': ('menu_draft', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
itemsJson: String
baseMenuVersion: int
version: int
status: String
createdAt: DateTime''', [('menu_draft_tenant','restaurantId, status',False)]),
 'FloorLayout': ('floor_layout', '''restaurantId: int, relation(parent=raysto_restaurant)
layoutJson: String
version: int
updatedAt: DateTime''', [('layout_restaurant','restaurantId',True)]),
 'DiningTable': ('dining_table', '''restaurantId: int, relation(parent=raysto_restaurant)
label: String
zone: String
capacity: int
active: bool
needsReset: bool
qrKey: String
geometryJson: String
assignedWaiterId: String?
version: int''', [('table_label','restaurantId, label',True),('table_qr','qrKey',True)]),
 'DiningVisit': ('dining_visit', '''restaurantId: int, relation(parent=raysto_restaurant)
tableId: int, relation(parent=raysto_dining_table)
activeTableId: int?
guestCount: int
status: String
version: int
openedBy: String
createdAt: DateTime
closedAt: DateTime?''', [('visit_active_table','activeTableId',True),('visit_tenant','restaurantId, status',False)]),
 'VisitParticipant': ('visit_participant', '''restaurantId: int, relation(parent=raysto_restaurant)
visitId: int, relation(parent=raysto_dining_visit)
userId: String
active: bool
joinedAt: DateTime''', [('participant_visit_user','visitId, userId',True)]),
 'AccessInvitation': ('access_invitation', '''restaurantId: int, relation(parent=raysto_restaurant)
kind: String
targetId: int
tokenHash: String
createdBy: String
recipientEmail: String?
role: String?
expiresAt: DateTime
usesRemaining: int
revoked: bool
createdAt: DateTime''', [('invitation_token','tokenHash',True)]),
 'CustomerCart': ('customer_cart', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
linesJson: String
version: int
updatedAt: DateTime''', [('cart_actor_restaurant','userId, restaurantId',True)]),
 'PriceQuote': ('price_quote', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
visitId: int?
snapshotJson: String
menuVersion: int
totalMinor: int
currency: String
expiresAt: DateTime
consumedOrderId: int?
createdAt: DateTime''', [('quote_actor','userId, createdAt',False)]),
 'OrderContext': ('order_context', '''restaurantId: int, relation(parent=raysto_restaurant)
orderId: int, relation(parent=raysto_order)
visitId: int?
quoteId: int?
detailsJson: String
paymentTiming: String
cancellationRequested: bool
stockReleased: bool
slotKey: String?
couponCode: String?
createdAt: DateTime''', [('context_order','orderId',True)]),
 'BillCharge': ('bill_charge', '''restaurantId: int, relation(parent=raysto_restaurant)
orderId: int, relation(parent=raysto_order)
visitId: int?
lineKey: String
kind: String
amountMinor: int
creditedMinor: int
settledMinor: int
reservedMinor: int
foodNetMinor: int
version: int''', [('charge_order_line','orderId, lineKey',True),('charge_visit','visitId',False)]),
 'CheckoutIntent': ('checkout_intent', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
visitId: int?
activeVisitId: int?
orderId: int?
requestKey: String
requestHash: String
providerRequestId: String
providerOrderId: String?
merchantId: String
approvalUrl: String?
state: String
method: String
currency: String
amountMinor: int
commissionMinor: int
commissionBps: int
createdAt: DateTime
updatedAt: DateTime''', [('checkout_request','userId, requestKey',True),('checkout_active_visit','activeVisitId',True),('checkout_provider','providerOrderId',True)]),
 'PaymentAllocation': ('payment_allocation', '''restaurantId: int, relation(parent=raysto_restaurant)
checkoutId: int, relation(parent=raysto_checkout_intent)
chargeId: int, relation(parent=raysto_bill_charge)
amountMinor: int
foodNetMinor: int
refundedMinor: int
state: String''', [('allocation_charge_checkout','checkoutId, chargeId',True)]),
 'PaymentCapture': ('payment_capture', '''restaurantId: int, relation(parent=raysto_restaurant)
checkoutId: int, relation(parent=raysto_checkout_intent)
providerCaptureId: String
amountMinor: int
refundedMinor: int
currency: String
state: String
createdAt: DateTime''', [('capture_provider','providerCaptureId',True),('capture_checkout','checkoutId',True)]),
 'PaymentRefund': ('payment_refund', '''restaurantId: int, relation(parent=raysto_restaurant)
captureId: int, relation(parent=raysto_payment_capture)
requestKey: String
providerRefundId: String?
allocationJson: String
amountMinor: int
commissionMinor: int
reason: String
state: String
createdBy: String
createdAt: DateTime
updatedAt: DateTime''', [('refund_request','restaurantId, requestKey',True),('refund_provider','providerRefundId',True)]),
 'MerchantConnection': ('merchant_connection', '''restaurantId: int, relation(parent=raysto_restaurant)
trackingId: String
merchantId: String?
environment: String
status: String
capabilitiesJson: String
verifiedAt: DateTime?
createdAt: DateTime''', [('merchant_restaurant','restaurantId, environment',True),('merchant_tracking','trackingId',True)]),
 'DiningReservation': ('dining_reservation', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
tableId: int, relation(parent=raysto_dining_table)
partySize: int
startsAt: DateTime
endsAt: DateTime
holdExpiresAt: DateTime?
status: String
contactJson: String
visitId: int?
version: int
createdAt: DateTime''', [('reservation_interval','restaurantId, startsAt, endsAt',False)]),
 'DiningWaitlist': ('dining_waitlist', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
partySize: int
status: String
contactJson: String
offeredTableId: int?
offerExpiresAt: DateTime?
version: int
createdAt: DateTime''', [('waitlist_tenant','restaurantId, status, createdAt',False)]),
 'VisitRequest': ('visit_request', '''restaurantId: int, relation(parent=raysto_restaurant)
visitId: int, relation(parent=raysto_dining_visit)
userId: String
kind: String
status: String
assignedUserId: String?
reason: String?
version: int
createdAt: DateTime''', [('visit_request_status','visitId, status',False)]),
 'KitchenProgress': ('kitchen_progress', '''restaurantId: int, relation(parent=raysto_restaurant)
orderId: int, relation(parent=raysto_order)
lineKey: String
quantity: int
completedQuantity: int
version: int''', [('kitchen_line','orderId, lineKey',True)]),
 'DeliveryAssignment': ('delivery_assignment', '''restaurantId: int, relation(parent=raysto_restaurant)
orderId: int, relation(parent=raysto_order)
courierId: String?
status: String
issueJson: String
locationJson: String?
locationExpiresAt: DateTime?
locationConsent: bool
version: int
updatedAt: DateTime''', [('delivery_order','orderId',True),('delivery_courier','courierId, status',False)]),
 'RestaurantPlan': ('restaurant_plan', '''code: String
version: int
currency: String
priceMinor: int
commissionBps: int
featuresJson: String
providerPlanId: String?
active: bool
createdAt: DateTime''', [('plan_code_version','code, version',True)]),
 'RestaurantSubscription': ('restaurant_subscription', '''restaurantId: int, relation(parent=raysto_restaurant)
planId: int, relation(parent=raysto_restaurant_plan)
providerSubscriptionId: String?
status: String
periodEndsAt: DateTime?
graceEndsAt: DateTime?
approvalUrl: String?
requestKey: String
updatedAt: DateTime''', [('subscription_restaurant','restaurantId',True),('subscription_provider','providerSubscriptionId',True)]),
 'CommissionEntry': ('commission_entry', '''restaurantId: int, relation(parent=raysto_restaurant)
captureId: int, relation(parent=raysto_payment_capture)
refundId: int?
eventKey: String
amountMinor: int
currency: String
state: String
createdAt: DateTime''', [('commission_event','eventKey',True)]),
 'CustomerFavorite': ('customer_favorite', '''userId: String
restaurantId: int, relation(parent=raysto_restaurant)
productId: int?
targetKey: String
createdAt: DateTime''', [('favorite_target','userId, targetKey',True)]),
 'CustomerReview': ('customer_review', '''restaurantId: int, relation(parent=raysto_restaurant)
orderId: int, relation(parent=raysto_order)
userId: String
rating: int
text: String
response: String?
status: String
version: int
createdAt: DateTime''', [('review_order','orderId',True)]),
 'SupportConversation': ('support_conversation', '''restaurantId: int?
orderId: int?
userId: String
status: String
subject: String
escalated: bool
version: int
createdAt: DateTime''', [('conversation_actor','userId, createdAt',False)]),
 'SupportMessage': ('support_message', '''conversationId: int, relation(parent=raysto_support_conversation)
userId: String
text: String
mediaId: int?
createdAt: DateTime''', [('message_thread','conversationId, createdAt',False)]),
 'UserNotification': ('user_notification', '''userId: String
restaurantId: int?
eventKey: String
kind: String
referenceJson: String
readAt: DateTime?
dismissedAt: DateTime?
createdAt: DateTime''', [('notification_event_user','eventKey, userId',True)]),
 'AuditRecord': ('audit_record', '''restaurantId: int?
userId: String
requestKey: String
kind: String
entityType: String
entityId: int?
detailsJson: String
createdAt: DateTime''', [('audit_tenant_time','restaurantId, createdAt',False)]),
 'PlatformJob': ('platform_job', '''restaurantId: int?
userId: String?
kind: String
dedupeKey: String
payloadJson: String
state: String
attempts: int
availableAt: DateTime
leaseToken: String?
leaseUntil: DateTime?
lastError: String?
createdAt: DateTime''', [('job_dedupe','dedupeKey',True),('job_ready','state, availableAt',False)]),
 'MediaAsset': ('media_asset', '''restaurantId: int?
userId: String
purpose: String
objectName: String
mime: String
byteLength: int
sha256: String
status: String
public: bool
metadataJson: String
createdAt: DateTime''', [('media_object','objectName',True)]),
 'AiOperation': ('ai_operation', '''restaurantId: int, relation(parent=raysto_restaurant)
userId: String
kind: String
mediaId: int?
inputJson: String
outputJson: String?
status: String
menuVersion: int
version: int
inputTokens: int
outputTokens: int
expiresAt: DateTime
createdAt: DateTime''', [('ai_actor_time','userId, createdAt',False)]),
 'MutationReceipt': ('mutation_receipt', '''userId: String
requestKey: String
operation: String
requestHash: String
resultJson: String
createdAt: DateTime''', [('mutation_actor_key','userId, requestKey',True)]),
 'ProviderInbox': ('provider_inbox', '''provider: String
eventId: String
eventType: String
payloadJson: String
status: String
receivedAt: DateTime
processedAt: DateTime?''', [('inbox_provider_event','provider, eventId',True)]),
 'SecurityGrant': ('security_grant', '''userId: String
kind: String
proofHash: String
expiresAt: DateTime
usedAt: DateTime?
createdAt: DateTime''', [('grant_proof','proofHash',True)]),
 'RateWindow': ('rate_window', '''bucket: String
windowStart: DateTime
requests: int''', [('rate_bucket','bucket, windowStart',True)]),
}
import re
for name, (table, fields, indexes) in models.items():
    filename = re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()
    text = f'class: {name}\ntable: raysto_{table}\nserverOnly: true\nfields:\n'
    text += ''.join('  ' + line + '\n' for line in fields.splitlines())
    if indexes:
        text += 'indexes:\n'
        for idx, cols, unique in indexes:
            text += f'  {idx}:\n    fields: {cols}\n'
            if unique: text += '    unique: true\n'
    (root / (filename+'.spy.yaml')).write_text(text, encoding='utf-8')

# Transport documents are JSON with operation-specific schemas; records stay server-only.
transport = {
 'PlatformCommand': '''requestKey: String
restaurantId: int?
resourceId: int?
expectedVersion: int?
dataJson: String''',
 'PlatformResponse': '''requestId: String
dataJson: String''',
 'PlatformEvent': '''cursor: int
kind: String
entityId: int?
createdAt: DateTime''',
 'CreateQuote': '''requestKey: String
restaurantId: int
visitId: int?
fulfillment: String
linesJson: String
addressJson: String?
slot: DateTime?
couponCode: String?
tipMinor: int''',
 'SubmitOrder': '''requestKey: String
restaurantId: int
quoteId: int''',
 'StartVisit': '''requestKey: String
restaurantId: int
tableId: int
guestCount: int
seatingToken: String?''',
 'AllocatePayment': '''requestKey: String
restaurantId: int
visitId: int?
orderId: int?
amountMinor: int?
lineKeys: List<String>?
method: String''',
 'RequestRefund': '''requestKey: String
restaurantId: int
captureId: int
amountMinor: int
reason: String''',
}
for name, fields in transport.items():
    filename = re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()
    text = f'class: {name}\nfields:\n' + ''.join('  '+line+'\n' for line in fields.splitlines())
    (root / (filename+'.spy.yaml')).write_text(text, encoding='utf-8')
print(f'Authored {len(models)} persistent schemas and {len(transport)} transport schemas.')
