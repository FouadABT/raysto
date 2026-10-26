/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:raysto_server/src/generated/cart_line.dart' as _ifrjnlf7;
import 'package:raysto_server/src/generated/menu_product.dart' as _i1ckjdab;
import 'package:raysto_server/src/generated/purchase_order.dart' as _iybirl3i;
import 'package:raysto_server/src/generated/restaurant.dart' as _i0tlglpz;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'cart_line.dart' as _ihfq9pvm;
import 'checkout_result.dart' as _i5rg4892;
import 'device_token.dart' as _ilggw95u;
import 'domain_error.dart' as _immikmlr;
import 'membership.dart' as _iu35fd1a;
import 'menu_product.dart' as _i0rg43cj;
import 'order_line.dart' as _i7utqy3k;
import 'outbox_event.dart' as _i6i2iffh;
import 'payment_attempt.dart' as _i7qxa3yb;
import 'payment_receipt.dart' as _iobklzq3;
import 'platform/access_invitation.dart' as _iwre736y;
import 'platform/actor_profile.dart' as _ilpq7xc9;
import 'platform/ai_operation.dart' as _ilk7oan7;
import 'platform/ai_spend_budget.dart' as _iirkjcah;
import 'platform/ai_spend_entry.dart' as _ir6n0dh4;
import 'platform/allocate_payment.dart' as _iho8f24j;
import 'platform/assistant_proposal.dart' as _io28jxc4;
import 'platform/assistant_run.dart' as _ip6tr127;
import 'platform/audit_record.dart' as _icm9s83d;
import 'platform/bill_charge.dart' as _iab8f16w;
import 'platform/bill_split_plan.dart' as _iqi0qoum;
import 'platform/billing_history.dart' as _iqyxcx8t;
import 'platform/charge_share.dart' as _iaiv5uup;
import 'platform/checkout_intent.dart' as _ic84k6y9;
import 'platform/commission_entry.dart' as _ilsa31z6;
import 'platform/conversation_room.dart' as _i6es2wkr;
import 'platform/create_quote.dart' as _ihuzea45;
import 'platform/customer_cart.dart' as _iku6hp32;
import 'platform/customer_favorite.dart' as _i9nuszoc;
import 'platform/customer_review.dart' as _iasq0wzy;
import 'platform/delivery_assignment.dart' as _izs8cqpn;
import 'platform/dining_reservation.dart' as _ijz5ts4w;
import 'platform/dining_table.dart' as _i8p8f5o8;
import 'platform/dining_visit.dart' as _ids0orjk;
import 'platform/dining_waitlist.dart' as _iwj3dyxh;
import 'platform/floor_layout.dart' as _ijsenvl9;
import 'platform/kitchen_progress.dart' as _igcxmw5n;
import 'platform/media_asset.dart' as _i8f1ig6q;
import 'platform/menu_definition.dart' as _i39nz0x4;
import 'platform/menu_draft.dart' as _iryjexya;
import 'platform/merchant_connection.dart' as _itytb8tk;
import 'platform/mutation_receipt.dart' as _iotby0fz;
import 'platform/operations_layout.dart' as _i3exdroq;
import 'platform/order_context.dart' as _ihpzd016;
import 'platform/payment_allocation.dart' as _iro17wd2;
import 'platform/payment_capture.dart' as _if5yjfbd;
import 'platform/payment_exception.dart' as _i8uoe3bd;
import 'platform/payment_refund.dart' as _ievhyl6k;
import 'platform/platform_command.dart' as _in5mt2du;
import 'platform/platform_event.dart' as _i46ou76b;
import 'platform/platform_job.dart' as _ijcw4tvs;
import 'platform/platform_response.dart' as _ibbs4n93;
import 'platform/price_quote.dart' as _if2vl5a9;
import 'platform/provider_inbox.dart' as _ily1fshf;
import 'platform/rate_window.dart' as _i2sn7og2;
import 'platform/request_refund.dart' as _i7dkxoyy;
import 'platform/restaurant_plan.dart' as _i139usf3;
import 'platform/restaurant_policy.dart' as _iqbnlqb3;
import 'platform/restaurant_subscription.dart' as _ij0wcuq1;
import 'platform/room_member.dart' as _iou6uhjy;
import 'platform/room_message.dart' as _ipbq43ew;
import 'platform/security_grant.dart' as _izk5jc0w;
import 'platform/start_visit.dart' as _ic6k5ko2;
import 'platform/submit_order.dart' as _ijdjbc0u;
import 'platform/support_conversation.dart' as _ifweu7ui;
import 'platform/support_message.dart' as _ixm1i1fm;
import 'platform/user_notification.dart' as _iptgoord;
import 'platform/visit_participant.dart' as _ibnsatbv;
import 'platform/visit_request.dart' as _i2xnjcjt;
import 'purchase_order.dart' as _i4elpxu0;
import 'restaurant.dart' as _iwilqhab;
import 'sandbox_payment.dart' as _iftkb6t2;
import 'service_request.dart' as _ijgh7vob;
import 'webhook_event.dart' as _isfhmrl5;
export 'cart_line.dart';
export 'checkout_result.dart';
export 'device_token.dart';
export 'domain_error.dart';
export 'membership.dart';
export 'menu_product.dart';
export 'order_line.dart';
export 'outbox_event.dart';
export 'payment_attempt.dart';
export 'payment_receipt.dart';
export 'platform/access_invitation.dart';
export 'platform/actor_profile.dart';
export 'platform/ai_operation.dart';
export 'platform/ai_spend_budget.dart';
export 'platform/ai_spend_entry.dart';
export 'platform/allocate_payment.dart';
export 'platform/assistant_proposal.dart';
export 'platform/assistant_run.dart';
export 'platform/audit_record.dart';
export 'platform/bill_charge.dart';
export 'platform/bill_split_plan.dart';
export 'platform/billing_history.dart';
export 'platform/charge_share.dart';
export 'platform/checkout_intent.dart';
export 'platform/commission_entry.dart';
export 'platform/conversation_room.dart';
export 'platform/create_quote.dart';
export 'platform/customer_cart.dart';
export 'platform/customer_favorite.dart';
export 'platform/customer_review.dart';
export 'platform/delivery_assignment.dart';
export 'platform/dining_reservation.dart';
export 'platform/dining_table.dart';
export 'platform/dining_visit.dart';
export 'platform/dining_waitlist.dart';
export 'platform/floor_layout.dart';
export 'platform/kitchen_progress.dart';
export 'platform/media_asset.dart';
export 'platform/menu_definition.dart';
export 'platform/menu_draft.dart';
export 'platform/merchant_connection.dart';
export 'platform/mutation_receipt.dart';
export 'platform/operations_layout.dart';
export 'platform/order_context.dart';
export 'platform/payment_allocation.dart';
export 'platform/payment_capture.dart';
export 'platform/payment_exception.dart';
export 'platform/payment_refund.dart';
export 'platform/platform_command.dart';
export 'platform/platform_event.dart';
export 'platform/platform_job.dart';
export 'platform/platform_response.dart';
export 'platform/price_quote.dart';
export 'platform/provider_inbox.dart';
export 'platform/rate_window.dart';
export 'platform/request_refund.dart';
export 'platform/restaurant_plan.dart';
export 'platform/restaurant_policy.dart';
export 'platform/restaurant_subscription.dart';
export 'platform/room_member.dart';
export 'platform/room_message.dart';
export 'platform/security_grant.dart';
export 'platform/start_visit.dart';
export 'platform/submit_order.dart';
export 'platform/support_conversation.dart';
export 'platform/support_message.dart';
export 'platform/user_notification.dart';
export 'platform/visit_participant.dart';
export 'platform/visit_request.dart';
export 'purchase_order.dart';
export 'restaurant.dart';
export 'sandbox_payment.dart';
export 'service_request.dart';
export 'webhook_event.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'raysto_access_invitation',
      dartName: 'AccessInvitation',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientEmail',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'usesRemaining',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'revoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_access_invitation_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'invitation_token',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tokenHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_actor_profile',
      dartName: 'ActorProfile',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'firebaseUid',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'isGuest',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'disabled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'claimedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'dataJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'actor_user',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_ai_operation',
      dartName: 'AiOperation',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'mediaId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'inputJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'outputJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'menuVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'inputTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'outputTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_ai_operation_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'ai_actor_time',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_ai_spend_budget',
      dartName: 'AiSpendBudget',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'stage',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'limitMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reservedMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'spentMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'spend_stage',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'stage',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_ai_spend_entry',
      dartName: 'AiSpendEntry',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'sourceKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'stage',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reservedMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'chargedMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'settled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'spend_source',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_assistant_proposal',
      dartName: 'AssistantProposal',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'runId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contextHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_assistant_proposal_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_assistant_proposal_fk_1',
          columns: ['roomId'],
          referenceTable: 'raysto_conversation_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_assistant_proposal_fk_2',
          columns: ['runId'],
          referenceTable: 'raysto_assistant_run',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'proposal_run',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'runId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_assistant_run',
      dartName: 'AssistantRun',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'inputJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'outputJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'traceJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reservedMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'chargedMicros',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'budgetStage',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_assistant_run_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_assistant_run_fk_1',
          columns: ['roomId'],
          referenceTable: 'raysto_conversation_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'assistant_request',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'assistant_tenant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_audit_record',
      dartName: 'AuditRecord',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entityType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'detailsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'audit_tenant_time',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_bill_charge',
      dartName: 'BillCharge',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'lineKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'creditedMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'settledMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reservedMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'foodNetMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_bill_charge_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_bill_charge_fk_1',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'charge_order_line',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'lineKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'charge_visit',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'visitId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_bill_split_plan',
      dartName: 'BillSplitPlan',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'activeRoomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payersJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sharesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_bill_split_plan_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_bill_split_plan_fk_1',
          columns: ['roomId'],
          referenceTable: 'raysto_conversation_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'split_active_room',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'activeRoomId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_billing_history',
      dartName: 'BillingHistory',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'providerSubscriptionId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'detailsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_billing_history_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'billing_history_event',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_checkout_intent',
      dartName: 'CheckoutIntent',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'activeVisitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerRequestId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerOrderId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'merchantId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerMode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'marketplace\'',
        ),
        _isp.ColumnDefinition(
          name: 'splitPlanId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'approvalUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'method',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'commissionMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'commissionBps',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_checkout_intent_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_checkout_intent_fk_1',
          columns: ['splitPlanId'],
          referenceTable: 'raysto_bill_split_plan',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'checkout_request',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'checkout_active_visit',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'activeVisitId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'checkout_provider',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerOrderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_commission_entry',
      dartName: 'CommissionEntry',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'captureId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'refundId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'eventKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_commission_entry_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_commission_entry_fk_1',
          columns: ['captureId'],
          referenceTable: 'raysto_payment_capture',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'commission_event',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_conversation_room',
      dartName: 'ConversationRoom',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'contextKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'hostUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'hostEverAssigned',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'waiterUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_conversation_room_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_conversation_room_fk_1',
          columns: ['visitId'],
          referenceTable: 'raysto_dining_visit',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_conversation_room_fk_2',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'conversation_context',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'contextKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'conversation_tenant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_customer_cart',
      dartName: 'CustomerCart',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'linesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_customer_cart_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'cart_actor_restaurant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_customer_favorite',
      dartName: 'CustomerFavorite',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'productId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'targetKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_customer_favorite_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'favorite_target',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'targetKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_customer_review',
      dartName: 'CustomerReview',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rating',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'response',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_customer_review_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_customer_review_fk_1',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'review_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_delivery_assignment',
      dartName: 'DeliveryAssignment',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'courierId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'issueJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'locationJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'locationExpiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'locationConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_delivery_assignment_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_delivery_assignment_fk_1',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'delivery_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'delivery_courier',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'courierId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_device_token',
      dartName: 'DeviceToken',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'device_token_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_dining_reservation',
      dartName: 'DiningReservation',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tableId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'partySize',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'startsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'holdExpiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contactJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_dining_reservation_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_dining_reservation_fk_1',
          columns: ['tableId'],
          referenceTable: 'raysto_dining_table',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'reservation_interval',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'startsAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'endsAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_dining_table',
      dartName: 'DiningTable',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'zone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'capacity',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'needsReset',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'qrKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'geometryJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'assignedWaiterId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_dining_table_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'table_label',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'label',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'table_qr',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'qrKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_dining_visit',
      dartName: 'DiningVisit',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tableId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'activeTableId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'guestCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'openedBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'closedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_dining_visit_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_dining_visit_fk_1',
          columns: ['tableId'],
          referenceTable: 'raysto_dining_table',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'visit_active_table',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'activeTableId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'visit_tenant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_dining_waitlist',
      dartName: 'DiningWaitlist',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'partySize',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contactJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'offeredTableId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'offerExpiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_dining_waitlist_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'waitlist_tenant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_floor_layout',
      dartName: 'FloorLayout',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'layoutJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_floor_layout_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'layout_restaurant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_kitchen_progress',
      dartName: 'KitchenProgress',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'lineKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'quantity',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'completedQuantity',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_kitchen_progress_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_kitchen_progress_fk_1',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'kitchen_line',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'lineKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_media_asset',
      dartName: 'MediaAsset',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'purpose',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'objectName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'mime',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'byteLength',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sha256',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'public',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'metadataJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'media_object',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'objectName',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_membership',
      dartName: 'Membership',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_membership_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'membership_tenant_user',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_menu_definition',
      dartName: 'MenuDefinition',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'productId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'category',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'definitionJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'archived',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'stockRemaining',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_menu_definition_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_menu_definition_fk_1',
          columns: ['productId'],
          referenceTable: 'raysto_menu_product',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'definition_product',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'productId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'definition_category',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'category',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_menu_draft',
      dartName: 'MenuDraft',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'itemsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'baseMenuVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_menu_draft_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'menu_draft_tenant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_menu_product',
      dartName: 'MenuProduct',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'priceMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'available',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_menu_product_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'product_restaurant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_merchant_connection',
      dartName: 'MerchantConnection',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'trackingId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'merchantId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'environment',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'capabilitiesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'verifiedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_merchant_connection_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'merchant_restaurant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'environment',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'merchant_tracking',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'trackingId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_mutation_receipt',
      dartName: 'MutationReceipt',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'operation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'resultJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'mutation_actor_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_operations_layout',
      dartName: 'OperationsLayout',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'stateJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_operations_layout_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'operations_layout_user',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_order',
      dartName: 'PurchaseOrder',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'customerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'fulfillment',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'address',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lines',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:OrderLine>',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subtotalMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryFeeMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'totalMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'paymentStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_order_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'order_customer_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'customerId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'order_restaurant_created',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_order_context',
      dartName: 'OrderContext',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'quoteId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'detailsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'paymentTiming',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'cancellationRequested',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'stockReleased',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'slotKey',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'couponCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_order_context_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_order_context_fk_1',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'context_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_outbox',
      dartName: 'OutboxEvent',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'deliveredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_outbox_fk_0',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'outbox_pending',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deliveredAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextAttemptAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_payment_allocation',
      dartName: 'PaymentAllocation',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'checkoutId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'chargeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'foodNetMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'refundedMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_allocation_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_allocation_fk_1',
          columns: ['checkoutId'],
          referenceTable: 'raysto_checkout_intent',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_allocation_fk_2',
          columns: ['chargeId'],
          referenceTable: 'raysto_bill_charge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'allocation_charge_checkout',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'checkoutId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'chargeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_payment_attempt',
      dartName: 'PaymentAttempt',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requestId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerOrderId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'approvalUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_attempt_fk_0',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'payment_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'payment_provider_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerOrderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_payment_capture',
      dartName: 'PaymentCapture',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'checkoutId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'providerCaptureId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'refundedMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_capture_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_capture_fk_1',
          columns: ['checkoutId'],
          referenceTable: 'raysto_checkout_intent',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'capture_provider',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerCaptureId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'capture_checkout',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'checkoutId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_payment_exception',
      dartName: 'PaymentException',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'captureId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'providerEventId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_exception_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_exception_fk_1',
          columns: ['captureId'],
          referenceTable: 'raysto_payment_capture',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'exception_event',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerEventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_payment_receipt',
      dartName: 'PaymentReceipt',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'captureId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_receipt_fk_0',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'receipt_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'receipt_capture',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'captureId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_payment_refund',
      dartName: 'PaymentRefund',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'captureId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerRefundId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'allocationJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'commissionMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_refund_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_payment_refund_fk_1',
          columns: ['captureId'],
          referenceTable: 'raysto_payment_capture',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'refund_request',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'refund_provider',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerRefundId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_platform_job',
      dartName: 'PlatformJob',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'dedupeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'availableAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'leaseToken',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'job_dedupe',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'dedupeKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'job_ready',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'state',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'availableAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_price_quote',
      dartName: 'PriceQuote',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'snapshotJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'menuVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'totalMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'consumedOrderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'assistantProposalId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_price_quote_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_price_quote_fk_1',
          columns: ['assistantProposalId'],
          referenceTable: 'raysto_assistant_proposal',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'quote_actor',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_provider_inbox',
      dartName: 'ProviderInbox',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'processedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'inbox_provider_event',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_rate_window',
      dartName: 'RateWindow',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'bucket',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'windowStart',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'requests',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'rate_bucket',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'bucket',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'windowStart',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_restaurant',
      dartName: 'Restaurant',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryFeeMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'published',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_restaurant_plan',
      dartName: 'RestaurantPlan',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'priceMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'commissionBps',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'featuresJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerPlanId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'plan_code_version',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'code',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'version',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_restaurant_policy',
      dartName: 'RestaurantPolicy',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'settingsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'menuVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'suspended',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_restaurant_policy_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'policy_restaurant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_restaurant_subscription',
      dartName: 'RestaurantSubscription',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'planId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'providerSubscriptionId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'periodEndsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'graceEndsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'approvalUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_restaurant_subscription_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_restaurant_subscription_fk_1',
          columns: ['planId'],
          referenceTable: 'raysto_restaurant_plan',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'subscription_restaurant',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'restaurantId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'subscription_provider',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerSubscriptionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_room_member',
      dartName: 'RoomMember',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'lastReadSequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'preferencesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'muted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_room_member_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_room_member_fk_1',
          columns: ['roomId'],
          referenceTable: 'raysto_conversation_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_member_user',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_room_message',
      dartName: 'RoomMessage',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'clientMessageId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'replyToId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'bodyJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_room_message_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_room_message_fk_1',
          columns: ['roomId'],
          referenceTable: 'raysto_conversation_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_room_message_fk_2',
          columns: ['replyToId'],
          referenceTable: 'raysto_room_message',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_sequence',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sequence',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'room_message_dedupe',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'clientMessageId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_sandbox_payment',
      dartName: 'SandboxPayment',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerRequestId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'providerOrderId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'approvalUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'captureId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'webhookEventId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'webhookReceivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'capturedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'sandbox_owner_request',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'sandbox_provider_order',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerOrderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'sandbox_capture',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'captureId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_security_grant',
      dartName: 'SecurityGrant',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'proofHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'usedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'grant_proof',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'proofHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_service_request',
      dartName: 'ServiceRequest',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'customerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_service_request_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_service_request_fk_1',
          columns: ['orderId'],
          referenceTable: 'raysto_order',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'service_order_kind',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'kind',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_support_conversation',
      dartName: 'SupportConversation',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'orderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subject',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'escalated',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'conversation_actor',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_support_message',
      dartName: 'SupportMessage',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'mediaId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_support_message_fk_0',
          columns: ['conversationId'],
          referenceTable: 'raysto_support_conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'message_thread',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_user_notification',
      dartName: 'UserNotification',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'eventKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'referenceJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'readAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'dismissedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'notification_event_user',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_visit_participant',
      dartName: 'VisitParticipant',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_visit_participant_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_visit_participant_fk_1',
          columns: ['visitId'],
          referenceTable: 'raysto_dining_visit',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'participant_visit_user',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'visitId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_visit_request',
      dartName: 'VisitRequest',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'restaurantId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'visitId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'assignedUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_visit_request_fk_0',
          columns: ['restaurantId'],
          referenceTable: 'raysto_restaurant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'raysto_visit_request_fk_1',
          columns: ['visitId'],
          referenceTable: 'raysto_dining_visit',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'visit_request_status',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'visitId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'raysto_webhook_event',
      dartName: 'WebhookEvent',
      schema: 'public',
      module: 'raysto',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'providerEventId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'webhook_provider_event',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerEventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ihfq9pvm.CartLine) {
      return _ihfq9pvm.CartLine.fromJson(data) as T;
    }
    if (t == _i5rg4892.CheckoutResult) {
      return _i5rg4892.CheckoutResult.fromJson(data) as T;
    }
    if (t == _ilggw95u.DeviceToken) {
      return _ilggw95u.DeviceToken.fromJson(data) as T;
    }
    if (t == _immikmlr.DomainError) {
      return _immikmlr.DomainError.fromJson(data) as T;
    }
    if (t == _iu35fd1a.Membership) {
      return _iu35fd1a.Membership.fromJson(data) as T;
    }
    if (t == _i0rg43cj.MenuProduct) {
      return _i0rg43cj.MenuProduct.fromJson(data) as T;
    }
    if (t == _i7utqy3k.OrderLine) {
      return _i7utqy3k.OrderLine.fromJson(data) as T;
    }
    if (t == _i6i2iffh.OutboxEvent) {
      return _i6i2iffh.OutboxEvent.fromJson(data) as T;
    }
    if (t == _i7qxa3yb.PaymentAttempt) {
      return _i7qxa3yb.PaymentAttempt.fromJson(data) as T;
    }
    if (t == _iobklzq3.PaymentReceipt) {
      return _iobklzq3.PaymentReceipt.fromJson(data) as T;
    }
    if (t == _iwre736y.AccessInvitation) {
      return _iwre736y.AccessInvitation.fromJson(data) as T;
    }
    if (t == _ilpq7xc9.ActorProfile) {
      return _ilpq7xc9.ActorProfile.fromJson(data) as T;
    }
    if (t == _ilk7oan7.AiOperation) {
      return _ilk7oan7.AiOperation.fromJson(data) as T;
    }
    if (t == _iirkjcah.AiSpendBudget) {
      return _iirkjcah.AiSpendBudget.fromJson(data) as T;
    }
    if (t == _ir6n0dh4.AiSpendEntry) {
      return _ir6n0dh4.AiSpendEntry.fromJson(data) as T;
    }
    if (t == _iho8f24j.AllocatePayment) {
      return _iho8f24j.AllocatePayment.fromJson(data) as T;
    }
    if (t == _io28jxc4.AssistantProposal) {
      return _io28jxc4.AssistantProposal.fromJson(data) as T;
    }
    if (t == _ip6tr127.AssistantRun) {
      return _ip6tr127.AssistantRun.fromJson(data) as T;
    }
    if (t == _icm9s83d.AuditRecord) {
      return _icm9s83d.AuditRecord.fromJson(data) as T;
    }
    if (t == _iab8f16w.BillCharge) {
      return _iab8f16w.BillCharge.fromJson(data) as T;
    }
    if (t == _iqi0qoum.BillSplitPlan) {
      return _iqi0qoum.BillSplitPlan.fromJson(data) as T;
    }
    if (t == _iqyxcx8t.BillingHistory) {
      return _iqyxcx8t.BillingHistory.fromJson(data) as T;
    }
    if (t == _iaiv5uup.ChargeShare) {
      return _iaiv5uup.ChargeShare.fromJson(data) as T;
    }
    if (t == _ic84k6y9.CheckoutIntent) {
      return _ic84k6y9.CheckoutIntent.fromJson(data) as T;
    }
    if (t == _ilsa31z6.CommissionEntry) {
      return _ilsa31z6.CommissionEntry.fromJson(data) as T;
    }
    if (t == _i6es2wkr.ConversationRoom) {
      return _i6es2wkr.ConversationRoom.fromJson(data) as T;
    }
    if (t == _ihuzea45.CreateQuote) {
      return _ihuzea45.CreateQuote.fromJson(data) as T;
    }
    if (t == _iku6hp32.CustomerCart) {
      return _iku6hp32.CustomerCart.fromJson(data) as T;
    }
    if (t == _i9nuszoc.CustomerFavorite) {
      return _i9nuszoc.CustomerFavorite.fromJson(data) as T;
    }
    if (t == _iasq0wzy.CustomerReview) {
      return _iasq0wzy.CustomerReview.fromJson(data) as T;
    }
    if (t == _izs8cqpn.DeliveryAssignment) {
      return _izs8cqpn.DeliveryAssignment.fromJson(data) as T;
    }
    if (t == _ijz5ts4w.DiningReservation) {
      return _ijz5ts4w.DiningReservation.fromJson(data) as T;
    }
    if (t == _i8p8f5o8.DiningTable) {
      return _i8p8f5o8.DiningTable.fromJson(data) as T;
    }
    if (t == _ids0orjk.DiningVisit) {
      return _ids0orjk.DiningVisit.fromJson(data) as T;
    }
    if (t == _iwj3dyxh.DiningWaitlist) {
      return _iwj3dyxh.DiningWaitlist.fromJson(data) as T;
    }
    if (t == _ijsenvl9.FloorLayout) {
      return _ijsenvl9.FloorLayout.fromJson(data) as T;
    }
    if (t == _igcxmw5n.KitchenProgress) {
      return _igcxmw5n.KitchenProgress.fromJson(data) as T;
    }
    if (t == _i8f1ig6q.MediaAsset) {
      return _i8f1ig6q.MediaAsset.fromJson(data) as T;
    }
    if (t == _i39nz0x4.MenuDefinition) {
      return _i39nz0x4.MenuDefinition.fromJson(data) as T;
    }
    if (t == _iryjexya.MenuDraft) {
      return _iryjexya.MenuDraft.fromJson(data) as T;
    }
    if (t == _itytb8tk.MerchantConnection) {
      return _itytb8tk.MerchantConnection.fromJson(data) as T;
    }
    if (t == _iotby0fz.MutationReceipt) {
      return _iotby0fz.MutationReceipt.fromJson(data) as T;
    }
    if (t == _i3exdroq.OperationsLayout) {
      return _i3exdroq.OperationsLayout.fromJson(data) as T;
    }
    if (t == _ihpzd016.OrderContext) {
      return _ihpzd016.OrderContext.fromJson(data) as T;
    }
    if (t == _iro17wd2.PaymentAllocation) {
      return _iro17wd2.PaymentAllocation.fromJson(data) as T;
    }
    if (t == _if5yjfbd.PaymentCapture) {
      return _if5yjfbd.PaymentCapture.fromJson(data) as T;
    }
    if (t == _i8uoe3bd.PaymentException) {
      return _i8uoe3bd.PaymentException.fromJson(data) as T;
    }
    if (t == _ievhyl6k.PaymentRefund) {
      return _ievhyl6k.PaymentRefund.fromJson(data) as T;
    }
    if (t == _in5mt2du.PlatformCommand) {
      return _in5mt2du.PlatformCommand.fromJson(data) as T;
    }
    if (t == _i46ou76b.PlatformEvent) {
      return _i46ou76b.PlatformEvent.fromJson(data) as T;
    }
    if (t == _ijcw4tvs.PlatformJob) {
      return _ijcw4tvs.PlatformJob.fromJson(data) as T;
    }
    if (t == _ibbs4n93.PlatformResponse) {
      return _ibbs4n93.PlatformResponse.fromJson(data) as T;
    }
    if (t == _if2vl5a9.PriceQuote) {
      return _if2vl5a9.PriceQuote.fromJson(data) as T;
    }
    if (t == _ily1fshf.ProviderInbox) {
      return _ily1fshf.ProviderInbox.fromJson(data) as T;
    }
    if (t == _i2sn7og2.RateWindow) {
      return _i2sn7og2.RateWindow.fromJson(data) as T;
    }
    if (t == _i7dkxoyy.RequestRefund) {
      return _i7dkxoyy.RequestRefund.fromJson(data) as T;
    }
    if (t == _i139usf3.RestaurantPlan) {
      return _i139usf3.RestaurantPlan.fromJson(data) as T;
    }
    if (t == _iqbnlqb3.RestaurantPolicy) {
      return _iqbnlqb3.RestaurantPolicy.fromJson(data) as T;
    }
    if (t == _ij0wcuq1.RestaurantSubscription) {
      return _ij0wcuq1.RestaurantSubscription.fromJson(data) as T;
    }
    if (t == _iou6uhjy.RoomMember) {
      return _iou6uhjy.RoomMember.fromJson(data) as T;
    }
    if (t == _ipbq43ew.RoomMessage) {
      return _ipbq43ew.RoomMessage.fromJson(data) as T;
    }
    if (t == _izk5jc0w.SecurityGrant) {
      return _izk5jc0w.SecurityGrant.fromJson(data) as T;
    }
    if (t == _ic6k5ko2.StartVisit) {
      return _ic6k5ko2.StartVisit.fromJson(data) as T;
    }
    if (t == _ijdjbc0u.SubmitOrder) {
      return _ijdjbc0u.SubmitOrder.fromJson(data) as T;
    }
    if (t == _ifweu7ui.SupportConversation) {
      return _ifweu7ui.SupportConversation.fromJson(data) as T;
    }
    if (t == _ixm1i1fm.SupportMessage) {
      return _ixm1i1fm.SupportMessage.fromJson(data) as T;
    }
    if (t == _iptgoord.UserNotification) {
      return _iptgoord.UserNotification.fromJson(data) as T;
    }
    if (t == _ibnsatbv.VisitParticipant) {
      return _ibnsatbv.VisitParticipant.fromJson(data) as T;
    }
    if (t == _i2xnjcjt.VisitRequest) {
      return _i2xnjcjt.VisitRequest.fromJson(data) as T;
    }
    if (t == _i4elpxu0.PurchaseOrder) {
      return _i4elpxu0.PurchaseOrder.fromJson(data) as T;
    }
    if (t == _iwilqhab.Restaurant) {
      return _iwilqhab.Restaurant.fromJson(data) as T;
    }
    if (t == _iftkb6t2.SandboxPayment) {
      return _iftkb6t2.SandboxPayment.fromJson(data) as T;
    }
    if (t == _ijgh7vob.ServiceRequest) {
      return _ijgh7vob.ServiceRequest.fromJson(data) as T;
    }
    if (t == _isfhmrl5.WebhookEvent) {
      return _isfhmrl5.WebhookEvent.fromJson(data) as T;
    }
    if (t == _is.getType<_ihfq9pvm.CartLine?>()) {
      return (data != null ? _ihfq9pvm.CartLine.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i5rg4892.CheckoutResult?>()) {
      return (data != null ? _i5rg4892.CheckoutResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilggw95u.DeviceToken?>()) {
      return (data != null ? _ilggw95u.DeviceToken.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_immikmlr.DomainError?>()) {
      return (data != null ? _immikmlr.DomainError.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iu35fd1a.Membership?>()) {
      return (data != null ? _iu35fd1a.Membership.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0rg43cj.MenuProduct?>()) {
      return (data != null ? _i0rg43cj.MenuProduct.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7utqy3k.OrderLine?>()) {
      return (data != null ? _i7utqy3k.OrderLine.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6i2iffh.OutboxEvent?>()) {
      return (data != null ? _i6i2iffh.OutboxEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7qxa3yb.PaymentAttempt?>()) {
      return (data != null ? _i7qxa3yb.PaymentAttempt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iobklzq3.PaymentReceipt?>()) {
      return (data != null ? _iobklzq3.PaymentReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwre736y.AccessInvitation?>()) {
      return (data != null ? _iwre736y.AccessInvitation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilpq7xc9.ActorProfile?>()) {
      return (data != null ? _ilpq7xc9.ActorProfile.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilk7oan7.AiOperation?>()) {
      return (data != null ? _ilk7oan7.AiOperation.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iirkjcah.AiSpendBudget?>()) {
      return (data != null ? _iirkjcah.AiSpendBudget.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir6n0dh4.AiSpendEntry?>()) {
      return (data != null ? _ir6n0dh4.AiSpendEntry.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iho8f24j.AllocatePayment?>()) {
      return (data != null ? _iho8f24j.AllocatePayment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_io28jxc4.AssistantProposal?>()) {
      return (data != null ? _io28jxc4.AssistantProposal.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ip6tr127.AssistantRun?>()) {
      return (data != null ? _ip6tr127.AssistantRun.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icm9s83d.AuditRecord?>()) {
      return (data != null ? _icm9s83d.AuditRecord.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iab8f16w.BillCharge?>()) {
      return (data != null ? _iab8f16w.BillCharge.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iqi0qoum.BillSplitPlan?>()) {
      return (data != null ? _iqi0qoum.BillSplitPlan.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqyxcx8t.BillingHistory?>()) {
      return (data != null ? _iqyxcx8t.BillingHistory.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iaiv5uup.ChargeShare?>()) {
      return (data != null ? _iaiv5uup.ChargeShare.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ic84k6y9.CheckoutIntent?>()) {
      return (data != null ? _ic84k6y9.CheckoutIntent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilsa31z6.CommissionEntry?>()) {
      return (data != null ? _ilsa31z6.CommissionEntry.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i6es2wkr.ConversationRoom?>()) {
      return (data != null ? _i6es2wkr.ConversationRoom.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihuzea45.CreateQuote?>()) {
      return (data != null ? _ihuzea45.CreateQuote.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iku6hp32.CustomerCart?>()) {
      return (data != null ? _iku6hp32.CustomerCart.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i9nuszoc.CustomerFavorite?>()) {
      return (data != null ? _i9nuszoc.CustomerFavorite.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iasq0wzy.CustomerReview?>()) {
      return (data != null ? _iasq0wzy.CustomerReview.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izs8cqpn.DeliveryAssignment?>()) {
      return (data != null ? _izs8cqpn.DeliveryAssignment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijz5ts4w.DiningReservation?>()) {
      return (data != null ? _ijz5ts4w.DiningReservation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8p8f5o8.DiningTable?>()) {
      return (data != null ? _i8p8f5o8.DiningTable.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ids0orjk.DiningVisit?>()) {
      return (data != null ? _ids0orjk.DiningVisit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iwj3dyxh.DiningWaitlist?>()) {
      return (data != null ? _iwj3dyxh.DiningWaitlist.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijsenvl9.FloorLayout?>()) {
      return (data != null ? _ijsenvl9.FloorLayout.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_igcxmw5n.KitchenProgress?>()) {
      return (data != null ? _igcxmw5n.KitchenProgress.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8f1ig6q.MediaAsset?>()) {
      return (data != null ? _i8f1ig6q.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i39nz0x4.MenuDefinition?>()) {
      return (data != null ? _i39nz0x4.MenuDefinition.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iryjexya.MenuDraft?>()) {
      return (data != null ? _iryjexya.MenuDraft.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itytb8tk.MerchantConnection?>()) {
      return (data != null ? _itytb8tk.MerchantConnection.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iotby0fz.MutationReceipt?>()) {
      return (data != null ? _iotby0fz.MutationReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3exdroq.OperationsLayout?>()) {
      return (data != null ? _i3exdroq.OperationsLayout.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihpzd016.OrderContext?>()) {
      return (data != null ? _ihpzd016.OrderContext.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iro17wd2.PaymentAllocation?>()) {
      return (data != null ? _iro17wd2.PaymentAllocation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if5yjfbd.PaymentCapture?>()) {
      return (data != null ? _if5yjfbd.PaymentCapture.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8uoe3bd.PaymentException?>()) {
      return (data != null ? _i8uoe3bd.PaymentException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ievhyl6k.PaymentRefund?>()) {
      return (data != null ? _ievhyl6k.PaymentRefund.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_in5mt2du.PlatformCommand?>()) {
      return (data != null ? _in5mt2du.PlatformCommand.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i46ou76b.PlatformEvent?>()) {
      return (data != null ? _i46ou76b.PlatformEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijcw4tvs.PlatformJob?>()) {
      return (data != null ? _ijcw4tvs.PlatformJob.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibbs4n93.PlatformResponse?>()) {
      return (data != null ? _ibbs4n93.PlatformResponse.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if2vl5a9.PriceQuote?>()) {
      return (data != null ? _if2vl5a9.PriceQuote.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ily1fshf.ProviderInbox?>()) {
      return (data != null ? _ily1fshf.ProviderInbox.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2sn7og2.RateWindow?>()) {
      return (data != null ? _i2sn7og2.RateWindow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7dkxoyy.RequestRefund?>()) {
      return (data != null ? _i7dkxoyy.RequestRefund.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i139usf3.RestaurantPlan?>()) {
      return (data != null ? _i139usf3.RestaurantPlan.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqbnlqb3.RestaurantPolicy?>()) {
      return (data != null ? _iqbnlqb3.RestaurantPolicy.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ij0wcuq1.RestaurantSubscription?>()) {
      return (data != null
              ? _ij0wcuq1.RestaurantSubscription.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iou6uhjy.RoomMember?>()) {
      return (data != null ? _iou6uhjy.RoomMember.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ipbq43ew.RoomMessage?>()) {
      return (data != null ? _ipbq43ew.RoomMessage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izk5jc0w.SecurityGrant?>()) {
      return (data != null ? _izk5jc0w.SecurityGrant.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ic6k5ko2.StartVisit?>()) {
      return (data != null ? _ic6k5ko2.StartVisit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijdjbc0u.SubmitOrder?>()) {
      return (data != null ? _ijdjbc0u.SubmitOrder.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifweu7ui.SupportConversation?>()) {
      return (data != null
              ? _ifweu7ui.SupportConversation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixm1i1fm.SupportMessage?>()) {
      return (data != null ? _ixm1i1fm.SupportMessage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iptgoord.UserNotification?>()) {
      return (data != null ? _iptgoord.UserNotification.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibnsatbv.VisitParticipant?>()) {
      return (data != null ? _ibnsatbv.VisitParticipant.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2xnjcjt.VisitRequest?>()) {
      return (data != null ? _i2xnjcjt.VisitRequest.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4elpxu0.PurchaseOrder?>()) {
      return (data != null ? _i4elpxu0.PurchaseOrder.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwilqhab.Restaurant?>()) {
      return (data != null ? _iwilqhab.Restaurant.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iftkb6t2.SandboxPayment?>()) {
      return (data != null ? _iftkb6t2.SandboxPayment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijgh7vob.ServiceRequest?>()) {
      return (data != null ? _ijgh7vob.ServiceRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isfhmrl5.WebhookEvent?>()) {
      return (data != null ? _isfhmrl5.WebhookEvent.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _is.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_iaiv5uup.ChargeShare>) {
      return (data as List)
              .map((e) => deserialize<_iaiv5uup.ChargeShare>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_iaiv5uup.ChargeShare>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_iaiv5uup.ChargeShare>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i7utqy3k.OrderLine>) {
      return (data as List)
              .map((e) => deserialize<_i7utqy3k.OrderLine>(e))
              .toList()
          as T;
    }
    if (t == List<_i0tlglpz.Restaurant>) {
      return (data as List)
              .map((e) => deserialize<_i0tlglpz.Restaurant>(e))
              .toList()
          as T;
    }
    if (t == List<_i1ckjdab.MenuProduct>) {
      return (data as List)
              .map((e) => deserialize<_i1ckjdab.MenuProduct>(e))
              .toList()
          as T;
    }
    if (t == List<_ifrjnlf7.CartLine>) {
      return (data as List)
              .map((e) => deserialize<_ifrjnlf7.CartLine>(e))
              .toList()
          as T;
    }
    if (t == List<_iybirl3i.PurchaseOrder>) {
      return (data as List)
              .map((e) => deserialize<_iybirl3i.PurchaseOrder>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ihfq9pvm.CartLine => 'CartLine',
      _i5rg4892.CheckoutResult => 'CheckoutResult',
      _ilggw95u.DeviceToken => 'DeviceToken',
      _immikmlr.DomainError => 'DomainError',
      _iu35fd1a.Membership => 'Membership',
      _i0rg43cj.MenuProduct => 'MenuProduct',
      _i7utqy3k.OrderLine => 'OrderLine',
      _i6i2iffh.OutboxEvent => 'OutboxEvent',
      _i7qxa3yb.PaymentAttempt => 'PaymentAttempt',
      _iobklzq3.PaymentReceipt => 'PaymentReceipt',
      _iwre736y.AccessInvitation => 'AccessInvitation',
      _ilpq7xc9.ActorProfile => 'ActorProfile',
      _ilk7oan7.AiOperation => 'AiOperation',
      _iirkjcah.AiSpendBudget => 'AiSpendBudget',
      _ir6n0dh4.AiSpendEntry => 'AiSpendEntry',
      _iho8f24j.AllocatePayment => 'AllocatePayment',
      _io28jxc4.AssistantProposal => 'AssistantProposal',
      _ip6tr127.AssistantRun => 'AssistantRun',
      _icm9s83d.AuditRecord => 'AuditRecord',
      _iab8f16w.BillCharge => 'BillCharge',
      _iqi0qoum.BillSplitPlan => 'BillSplitPlan',
      _iqyxcx8t.BillingHistory => 'BillingHistory',
      _iaiv5uup.ChargeShare => 'ChargeShare',
      _ic84k6y9.CheckoutIntent => 'CheckoutIntent',
      _ilsa31z6.CommissionEntry => 'CommissionEntry',
      _i6es2wkr.ConversationRoom => 'ConversationRoom',
      _ihuzea45.CreateQuote => 'CreateQuote',
      _iku6hp32.CustomerCart => 'CustomerCart',
      _i9nuszoc.CustomerFavorite => 'CustomerFavorite',
      _iasq0wzy.CustomerReview => 'CustomerReview',
      _izs8cqpn.DeliveryAssignment => 'DeliveryAssignment',
      _ijz5ts4w.DiningReservation => 'DiningReservation',
      _i8p8f5o8.DiningTable => 'DiningTable',
      _ids0orjk.DiningVisit => 'DiningVisit',
      _iwj3dyxh.DiningWaitlist => 'DiningWaitlist',
      _ijsenvl9.FloorLayout => 'FloorLayout',
      _igcxmw5n.KitchenProgress => 'KitchenProgress',
      _i8f1ig6q.MediaAsset => 'MediaAsset',
      _i39nz0x4.MenuDefinition => 'MenuDefinition',
      _iryjexya.MenuDraft => 'MenuDraft',
      _itytb8tk.MerchantConnection => 'MerchantConnection',
      _iotby0fz.MutationReceipt => 'MutationReceipt',
      _i3exdroq.OperationsLayout => 'OperationsLayout',
      _ihpzd016.OrderContext => 'OrderContext',
      _iro17wd2.PaymentAllocation => 'PaymentAllocation',
      _if5yjfbd.PaymentCapture => 'PaymentCapture',
      _i8uoe3bd.PaymentException => 'PaymentException',
      _ievhyl6k.PaymentRefund => 'PaymentRefund',
      _in5mt2du.PlatformCommand => 'PlatformCommand',
      _i46ou76b.PlatformEvent => 'PlatformEvent',
      _ijcw4tvs.PlatformJob => 'PlatformJob',
      _ibbs4n93.PlatformResponse => 'PlatformResponse',
      _if2vl5a9.PriceQuote => 'PriceQuote',
      _ily1fshf.ProviderInbox => 'ProviderInbox',
      _i2sn7og2.RateWindow => 'RateWindow',
      _i7dkxoyy.RequestRefund => 'RequestRefund',
      _i139usf3.RestaurantPlan => 'RestaurantPlan',
      _iqbnlqb3.RestaurantPolicy => 'RestaurantPolicy',
      _ij0wcuq1.RestaurantSubscription => 'RestaurantSubscription',
      _iou6uhjy.RoomMember => 'RoomMember',
      _ipbq43ew.RoomMessage => 'RoomMessage',
      _izk5jc0w.SecurityGrant => 'SecurityGrant',
      _ic6k5ko2.StartVisit => 'StartVisit',
      _ijdjbc0u.SubmitOrder => 'SubmitOrder',
      _ifweu7ui.SupportConversation => 'SupportConversation',
      _ixm1i1fm.SupportMessage => 'SupportMessage',
      _iptgoord.UserNotification => 'UserNotification',
      _ibnsatbv.VisitParticipant => 'VisitParticipant',
      _i2xnjcjt.VisitRequest => 'VisitRequest',
      _i4elpxu0.PurchaseOrder => 'PurchaseOrder',
      _iwilqhab.Restaurant => 'Restaurant',
      _iftkb6t2.SandboxPayment => 'SandboxPayment',
      _ijgh7vob.ServiceRequest => 'ServiceRequest',
      _isfhmrl5.WebhookEvent => 'WebhookEvent',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('raysto.', '');
    }

    switch (data) {
      case _ihfq9pvm.CartLine():
        return 'CartLine';
      case _i5rg4892.CheckoutResult():
        return 'CheckoutResult';
      case _ilggw95u.DeviceToken():
        return 'DeviceToken';
      case _immikmlr.DomainError():
        return 'DomainError';
      case _iu35fd1a.Membership():
        return 'Membership';
      case _i0rg43cj.MenuProduct():
        return 'MenuProduct';
      case _i7utqy3k.OrderLine():
        return 'OrderLine';
      case _i6i2iffh.OutboxEvent():
        return 'OutboxEvent';
      case _i7qxa3yb.PaymentAttempt():
        return 'PaymentAttempt';
      case _iobklzq3.PaymentReceipt():
        return 'PaymentReceipt';
      case _iwre736y.AccessInvitation():
        return 'AccessInvitation';
      case _ilpq7xc9.ActorProfile():
        return 'ActorProfile';
      case _ilk7oan7.AiOperation():
        return 'AiOperation';
      case _iirkjcah.AiSpendBudget():
        return 'AiSpendBudget';
      case _ir6n0dh4.AiSpendEntry():
        return 'AiSpendEntry';
      case _iho8f24j.AllocatePayment():
        return 'AllocatePayment';
      case _io28jxc4.AssistantProposal():
        return 'AssistantProposal';
      case _ip6tr127.AssistantRun():
        return 'AssistantRun';
      case _icm9s83d.AuditRecord():
        return 'AuditRecord';
      case _iab8f16w.BillCharge():
        return 'BillCharge';
      case _iqi0qoum.BillSplitPlan():
        return 'BillSplitPlan';
      case _iqyxcx8t.BillingHistory():
        return 'BillingHistory';
      case _iaiv5uup.ChargeShare():
        return 'ChargeShare';
      case _ic84k6y9.CheckoutIntent():
        return 'CheckoutIntent';
      case _ilsa31z6.CommissionEntry():
        return 'CommissionEntry';
      case _i6es2wkr.ConversationRoom():
        return 'ConversationRoom';
      case _ihuzea45.CreateQuote():
        return 'CreateQuote';
      case _iku6hp32.CustomerCart():
        return 'CustomerCart';
      case _i9nuszoc.CustomerFavorite():
        return 'CustomerFavorite';
      case _iasq0wzy.CustomerReview():
        return 'CustomerReview';
      case _izs8cqpn.DeliveryAssignment():
        return 'DeliveryAssignment';
      case _ijz5ts4w.DiningReservation():
        return 'DiningReservation';
      case _i8p8f5o8.DiningTable():
        return 'DiningTable';
      case _ids0orjk.DiningVisit():
        return 'DiningVisit';
      case _iwj3dyxh.DiningWaitlist():
        return 'DiningWaitlist';
      case _ijsenvl9.FloorLayout():
        return 'FloorLayout';
      case _igcxmw5n.KitchenProgress():
        return 'KitchenProgress';
      case _i8f1ig6q.MediaAsset():
        return 'MediaAsset';
      case _i39nz0x4.MenuDefinition():
        return 'MenuDefinition';
      case _iryjexya.MenuDraft():
        return 'MenuDraft';
      case _itytb8tk.MerchantConnection():
        return 'MerchantConnection';
      case _iotby0fz.MutationReceipt():
        return 'MutationReceipt';
      case _i3exdroq.OperationsLayout():
        return 'OperationsLayout';
      case _ihpzd016.OrderContext():
        return 'OrderContext';
      case _iro17wd2.PaymentAllocation():
        return 'PaymentAllocation';
      case _if5yjfbd.PaymentCapture():
        return 'PaymentCapture';
      case _i8uoe3bd.PaymentException():
        return 'PaymentException';
      case _ievhyl6k.PaymentRefund():
        return 'PaymentRefund';
      case _in5mt2du.PlatformCommand():
        return 'PlatformCommand';
      case _i46ou76b.PlatformEvent():
        return 'PlatformEvent';
      case _ijcw4tvs.PlatformJob():
        return 'PlatformJob';
      case _ibbs4n93.PlatformResponse():
        return 'PlatformResponse';
      case _if2vl5a9.PriceQuote():
        return 'PriceQuote';
      case _ily1fshf.ProviderInbox():
        return 'ProviderInbox';
      case _i2sn7og2.RateWindow():
        return 'RateWindow';
      case _i7dkxoyy.RequestRefund():
        return 'RequestRefund';
      case _i139usf3.RestaurantPlan():
        return 'RestaurantPlan';
      case _iqbnlqb3.RestaurantPolicy():
        return 'RestaurantPolicy';
      case _ij0wcuq1.RestaurantSubscription():
        return 'RestaurantSubscription';
      case _iou6uhjy.RoomMember():
        return 'RoomMember';
      case _ipbq43ew.RoomMessage():
        return 'RoomMessage';
      case _izk5jc0w.SecurityGrant():
        return 'SecurityGrant';
      case _ic6k5ko2.StartVisit():
        return 'StartVisit';
      case _ijdjbc0u.SubmitOrder():
        return 'SubmitOrder';
      case _ifweu7ui.SupportConversation():
        return 'SupportConversation';
      case _ixm1i1fm.SupportMessage():
        return 'SupportMessage';
      case _iptgoord.UserNotification():
        return 'UserNotification';
      case _ibnsatbv.VisitParticipant():
        return 'VisitParticipant';
      case _i2xnjcjt.VisitRequest():
        return 'VisitRequest';
      case _i4elpxu0.PurchaseOrder():
        return 'PurchaseOrder';
      case _iwilqhab.Restaurant():
        return 'Restaurant';
      case _iftkb6t2.SandboxPayment():
        return 'SandboxPayment';
      case _ijgh7vob.ServiceRequest():
        return 'ServiceRequest';
      case _isfhmrl5.WebhookEvent():
        return 'WebhookEvent';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CartLine') {
      return deserialize<_ihfq9pvm.CartLine>(data['data']);
    }
    if (dataClassName == 'CheckoutResult') {
      return deserialize<_i5rg4892.CheckoutResult>(data['data']);
    }
    if (dataClassName == 'DeviceToken') {
      return deserialize<_ilggw95u.DeviceToken>(data['data']);
    }
    if (dataClassName == 'DomainError') {
      return deserialize<_immikmlr.DomainError>(data['data']);
    }
    if (dataClassName == 'Membership') {
      return deserialize<_iu35fd1a.Membership>(data['data']);
    }
    if (dataClassName == 'MenuProduct') {
      return deserialize<_i0rg43cj.MenuProduct>(data['data']);
    }
    if (dataClassName == 'OrderLine') {
      return deserialize<_i7utqy3k.OrderLine>(data['data']);
    }
    if (dataClassName == 'OutboxEvent') {
      return deserialize<_i6i2iffh.OutboxEvent>(data['data']);
    }
    if (dataClassName == 'PaymentAttempt') {
      return deserialize<_i7qxa3yb.PaymentAttempt>(data['data']);
    }
    if (dataClassName == 'PaymentReceipt') {
      return deserialize<_iobklzq3.PaymentReceipt>(data['data']);
    }
    if (dataClassName == 'AccessInvitation') {
      return deserialize<_iwre736y.AccessInvitation>(data['data']);
    }
    if (dataClassName == 'ActorProfile') {
      return deserialize<_ilpq7xc9.ActorProfile>(data['data']);
    }
    if (dataClassName == 'AiOperation') {
      return deserialize<_ilk7oan7.AiOperation>(data['data']);
    }
    if (dataClassName == 'AiSpendBudget') {
      return deserialize<_iirkjcah.AiSpendBudget>(data['data']);
    }
    if (dataClassName == 'AiSpendEntry') {
      return deserialize<_ir6n0dh4.AiSpendEntry>(data['data']);
    }
    if (dataClassName == 'AllocatePayment') {
      return deserialize<_iho8f24j.AllocatePayment>(data['data']);
    }
    if (dataClassName == 'AssistantProposal') {
      return deserialize<_io28jxc4.AssistantProposal>(data['data']);
    }
    if (dataClassName == 'AssistantRun') {
      return deserialize<_ip6tr127.AssistantRun>(data['data']);
    }
    if (dataClassName == 'AuditRecord') {
      return deserialize<_icm9s83d.AuditRecord>(data['data']);
    }
    if (dataClassName == 'BillCharge') {
      return deserialize<_iab8f16w.BillCharge>(data['data']);
    }
    if (dataClassName == 'BillSplitPlan') {
      return deserialize<_iqi0qoum.BillSplitPlan>(data['data']);
    }
    if (dataClassName == 'BillingHistory') {
      return deserialize<_iqyxcx8t.BillingHistory>(data['data']);
    }
    if (dataClassName == 'ChargeShare') {
      return deserialize<_iaiv5uup.ChargeShare>(data['data']);
    }
    if (dataClassName == 'CheckoutIntent') {
      return deserialize<_ic84k6y9.CheckoutIntent>(data['data']);
    }
    if (dataClassName == 'CommissionEntry') {
      return deserialize<_ilsa31z6.CommissionEntry>(data['data']);
    }
    if (dataClassName == 'ConversationRoom') {
      return deserialize<_i6es2wkr.ConversationRoom>(data['data']);
    }
    if (dataClassName == 'CreateQuote') {
      return deserialize<_ihuzea45.CreateQuote>(data['data']);
    }
    if (dataClassName == 'CustomerCart') {
      return deserialize<_iku6hp32.CustomerCart>(data['data']);
    }
    if (dataClassName == 'CustomerFavorite') {
      return deserialize<_i9nuszoc.CustomerFavorite>(data['data']);
    }
    if (dataClassName == 'CustomerReview') {
      return deserialize<_iasq0wzy.CustomerReview>(data['data']);
    }
    if (dataClassName == 'DeliveryAssignment') {
      return deserialize<_izs8cqpn.DeliveryAssignment>(data['data']);
    }
    if (dataClassName == 'DiningReservation') {
      return deserialize<_ijz5ts4w.DiningReservation>(data['data']);
    }
    if (dataClassName == 'DiningTable') {
      return deserialize<_i8p8f5o8.DiningTable>(data['data']);
    }
    if (dataClassName == 'DiningVisit') {
      return deserialize<_ids0orjk.DiningVisit>(data['data']);
    }
    if (dataClassName == 'DiningWaitlist') {
      return deserialize<_iwj3dyxh.DiningWaitlist>(data['data']);
    }
    if (dataClassName == 'FloorLayout') {
      return deserialize<_ijsenvl9.FloorLayout>(data['data']);
    }
    if (dataClassName == 'KitchenProgress') {
      return deserialize<_igcxmw5n.KitchenProgress>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i8f1ig6q.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MenuDefinition') {
      return deserialize<_i39nz0x4.MenuDefinition>(data['data']);
    }
    if (dataClassName == 'MenuDraft') {
      return deserialize<_iryjexya.MenuDraft>(data['data']);
    }
    if (dataClassName == 'MerchantConnection') {
      return deserialize<_itytb8tk.MerchantConnection>(data['data']);
    }
    if (dataClassName == 'MutationReceipt') {
      return deserialize<_iotby0fz.MutationReceipt>(data['data']);
    }
    if (dataClassName == 'OperationsLayout') {
      return deserialize<_i3exdroq.OperationsLayout>(data['data']);
    }
    if (dataClassName == 'OrderContext') {
      return deserialize<_ihpzd016.OrderContext>(data['data']);
    }
    if (dataClassName == 'PaymentAllocation') {
      return deserialize<_iro17wd2.PaymentAllocation>(data['data']);
    }
    if (dataClassName == 'PaymentCapture') {
      return deserialize<_if5yjfbd.PaymentCapture>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i8uoe3bd.PaymentException>(data['data']);
    }
    if (dataClassName == 'PaymentRefund') {
      return deserialize<_ievhyl6k.PaymentRefund>(data['data']);
    }
    if (dataClassName == 'PlatformCommand') {
      return deserialize<_in5mt2du.PlatformCommand>(data['data']);
    }
    if (dataClassName == 'PlatformEvent') {
      return deserialize<_i46ou76b.PlatformEvent>(data['data']);
    }
    if (dataClassName == 'PlatformJob') {
      return deserialize<_ijcw4tvs.PlatformJob>(data['data']);
    }
    if (dataClassName == 'PlatformResponse') {
      return deserialize<_ibbs4n93.PlatformResponse>(data['data']);
    }
    if (dataClassName == 'PriceQuote') {
      return deserialize<_if2vl5a9.PriceQuote>(data['data']);
    }
    if (dataClassName == 'ProviderInbox') {
      return deserialize<_ily1fshf.ProviderInbox>(data['data']);
    }
    if (dataClassName == 'RateWindow') {
      return deserialize<_i2sn7og2.RateWindow>(data['data']);
    }
    if (dataClassName == 'RequestRefund') {
      return deserialize<_i7dkxoyy.RequestRefund>(data['data']);
    }
    if (dataClassName == 'RestaurantPlan') {
      return deserialize<_i139usf3.RestaurantPlan>(data['data']);
    }
    if (dataClassName == 'RestaurantPolicy') {
      return deserialize<_iqbnlqb3.RestaurantPolicy>(data['data']);
    }
    if (dataClassName == 'RestaurantSubscription') {
      return deserialize<_ij0wcuq1.RestaurantSubscription>(data['data']);
    }
    if (dataClassName == 'RoomMember') {
      return deserialize<_iou6uhjy.RoomMember>(data['data']);
    }
    if (dataClassName == 'RoomMessage') {
      return deserialize<_ipbq43ew.RoomMessage>(data['data']);
    }
    if (dataClassName == 'SecurityGrant') {
      return deserialize<_izk5jc0w.SecurityGrant>(data['data']);
    }
    if (dataClassName == 'StartVisit') {
      return deserialize<_ic6k5ko2.StartVisit>(data['data']);
    }
    if (dataClassName == 'SubmitOrder') {
      return deserialize<_ijdjbc0u.SubmitOrder>(data['data']);
    }
    if (dataClassName == 'SupportConversation') {
      return deserialize<_ifweu7ui.SupportConversation>(data['data']);
    }
    if (dataClassName == 'SupportMessage') {
      return deserialize<_ixm1i1fm.SupportMessage>(data['data']);
    }
    if (dataClassName == 'UserNotification') {
      return deserialize<_iptgoord.UserNotification>(data['data']);
    }
    if (dataClassName == 'VisitParticipant') {
      return deserialize<_ibnsatbv.VisitParticipant>(data['data']);
    }
    if (dataClassName == 'VisitRequest') {
      return deserialize<_i2xnjcjt.VisitRequest>(data['data']);
    }
    if (dataClassName == 'PurchaseOrder') {
      return deserialize<_i4elpxu0.PurchaseOrder>(data['data']);
    }
    if (dataClassName == 'Restaurant') {
      return deserialize<_iwilqhab.Restaurant>(data['data']);
    }
    if (dataClassName == 'SandboxPayment') {
      return deserialize<_iftkb6t2.SandboxPayment>(data['data']);
    }
    if (dataClassName == 'ServiceRequest') {
      return deserialize<_ijgh7vob.ServiceRequest>(data['data']);
    }
    if (dataClassName == 'WebhookEvent') {
      return deserialize<_isfhmrl5.WebhookEvent>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('raysto', this);
    _iacs.Protocol().registerHostProtocol('raysto', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ilggw95u.DeviceToken:
        return _ilggw95u.DeviceToken.t;
      case _iu35fd1a.Membership:
        return _iu35fd1a.Membership.t;
      case _i0rg43cj.MenuProduct:
        return _i0rg43cj.MenuProduct.t;
      case _i6i2iffh.OutboxEvent:
        return _i6i2iffh.OutboxEvent.t;
      case _i7qxa3yb.PaymentAttempt:
        return _i7qxa3yb.PaymentAttempt.t;
      case _iobklzq3.PaymentReceipt:
        return _iobklzq3.PaymentReceipt.t;
      case _iwre736y.AccessInvitation:
        return _iwre736y.AccessInvitation.t;
      case _ilpq7xc9.ActorProfile:
        return _ilpq7xc9.ActorProfile.t;
      case _ilk7oan7.AiOperation:
        return _ilk7oan7.AiOperation.t;
      case _iirkjcah.AiSpendBudget:
        return _iirkjcah.AiSpendBudget.t;
      case _ir6n0dh4.AiSpendEntry:
        return _ir6n0dh4.AiSpendEntry.t;
      case _io28jxc4.AssistantProposal:
        return _io28jxc4.AssistantProposal.t;
      case _ip6tr127.AssistantRun:
        return _ip6tr127.AssistantRun.t;
      case _icm9s83d.AuditRecord:
        return _icm9s83d.AuditRecord.t;
      case _iab8f16w.BillCharge:
        return _iab8f16w.BillCharge.t;
      case _iqi0qoum.BillSplitPlan:
        return _iqi0qoum.BillSplitPlan.t;
      case _iqyxcx8t.BillingHistory:
        return _iqyxcx8t.BillingHistory.t;
      case _ic84k6y9.CheckoutIntent:
        return _ic84k6y9.CheckoutIntent.t;
      case _ilsa31z6.CommissionEntry:
        return _ilsa31z6.CommissionEntry.t;
      case _i6es2wkr.ConversationRoom:
        return _i6es2wkr.ConversationRoom.t;
      case _iku6hp32.CustomerCart:
        return _iku6hp32.CustomerCart.t;
      case _i9nuszoc.CustomerFavorite:
        return _i9nuszoc.CustomerFavorite.t;
      case _iasq0wzy.CustomerReview:
        return _iasq0wzy.CustomerReview.t;
      case _izs8cqpn.DeliveryAssignment:
        return _izs8cqpn.DeliveryAssignment.t;
      case _ijz5ts4w.DiningReservation:
        return _ijz5ts4w.DiningReservation.t;
      case _i8p8f5o8.DiningTable:
        return _i8p8f5o8.DiningTable.t;
      case _ids0orjk.DiningVisit:
        return _ids0orjk.DiningVisit.t;
      case _iwj3dyxh.DiningWaitlist:
        return _iwj3dyxh.DiningWaitlist.t;
      case _ijsenvl9.FloorLayout:
        return _ijsenvl9.FloorLayout.t;
      case _igcxmw5n.KitchenProgress:
        return _igcxmw5n.KitchenProgress.t;
      case _i8f1ig6q.MediaAsset:
        return _i8f1ig6q.MediaAsset.t;
      case _i39nz0x4.MenuDefinition:
        return _i39nz0x4.MenuDefinition.t;
      case _iryjexya.MenuDraft:
        return _iryjexya.MenuDraft.t;
      case _itytb8tk.MerchantConnection:
        return _itytb8tk.MerchantConnection.t;
      case _iotby0fz.MutationReceipt:
        return _iotby0fz.MutationReceipt.t;
      case _i3exdroq.OperationsLayout:
        return _i3exdroq.OperationsLayout.t;
      case _ihpzd016.OrderContext:
        return _ihpzd016.OrderContext.t;
      case _iro17wd2.PaymentAllocation:
        return _iro17wd2.PaymentAllocation.t;
      case _if5yjfbd.PaymentCapture:
        return _if5yjfbd.PaymentCapture.t;
      case _i8uoe3bd.PaymentException:
        return _i8uoe3bd.PaymentException.t;
      case _ievhyl6k.PaymentRefund:
        return _ievhyl6k.PaymentRefund.t;
      case _ijcw4tvs.PlatformJob:
        return _ijcw4tvs.PlatformJob.t;
      case _if2vl5a9.PriceQuote:
        return _if2vl5a9.PriceQuote.t;
      case _ily1fshf.ProviderInbox:
        return _ily1fshf.ProviderInbox.t;
      case _i2sn7og2.RateWindow:
        return _i2sn7og2.RateWindow.t;
      case _i139usf3.RestaurantPlan:
        return _i139usf3.RestaurantPlan.t;
      case _iqbnlqb3.RestaurantPolicy:
        return _iqbnlqb3.RestaurantPolicy.t;
      case _ij0wcuq1.RestaurantSubscription:
        return _ij0wcuq1.RestaurantSubscription.t;
      case _iou6uhjy.RoomMember:
        return _iou6uhjy.RoomMember.t;
      case _ipbq43ew.RoomMessage:
        return _ipbq43ew.RoomMessage.t;
      case _izk5jc0w.SecurityGrant:
        return _izk5jc0w.SecurityGrant.t;
      case _ifweu7ui.SupportConversation:
        return _ifweu7ui.SupportConversation.t;
      case _ixm1i1fm.SupportMessage:
        return _ixm1i1fm.SupportMessage.t;
      case _iptgoord.UserNotification:
        return _iptgoord.UserNotification.t;
      case _ibnsatbv.VisitParticipant:
        return _ibnsatbv.VisitParticipant.t;
      case _i2xnjcjt.VisitRequest:
        return _i2xnjcjt.VisitRequest.t;
      case _i4elpxu0.PurchaseOrder:
        return _i4elpxu0.PurchaseOrder.t;
      case _iwilqhab.Restaurant:
        return _iwilqhab.Restaurant.t;
      case _iftkb6t2.SandboxPayment:
        return _iftkb6t2.SandboxPayment.t;
      case _ijgh7vob.ServiceRequest:
        return _ijgh7vob.ServiceRequest.t;
      case _isfhmrl5.WebhookEvent:
        return _isfhmrl5.WebhookEvent.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'raysto';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
