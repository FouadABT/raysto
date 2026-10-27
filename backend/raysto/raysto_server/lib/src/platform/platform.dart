library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/firebase.dart';
import 'package:serverpod_auth_idp_server/providers/anonymous.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:image/image.dart' as img;
import 'package:googleapis_auth/auth_io.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as jwt;
import '../generated/protocol.dart';
import '../services/firebase_services.dart';
import '../services/paypal_gateway.dart';
import '../services/paypal_mcp_client.dart';
import '../services/gemini_transport.dart';

part 'core.dart';
part 'identity.dart';
part 'catalogue.dart';
part 'dining.dart';
part 'ordering.dart';
part 'money.dart';
part 'operations.dart';
part 'providers.dart';
part 'automation.dart';
part 'queries.dart';
part 'settlement.dart';
part 'files.dart';
part 'conversations.dart';
part 'ai_budget.dart';
part 'assistant.dart';
part 'workspace.dart';
part 'shares.dart';

typedef Json = Map<String, dynamic>;
final _random = Random.secure();
String _uuid() => const uuid.Uuid().v4();
DateTime _now() => DateTime.now().toUtc();
Never _fail(String code, String message) =>
    throw DomainError(code: code, message: message);
String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
String _secret() => base64UrlEncode(
  List<int>.generate(32, (_) => _random.nextInt(256)),
).replaceAll('=', '');

Json _json(String value, {int maxBytes = 131072}) {
  if (utf8.encode(value).length > maxBytes) {
    _fail('payload_too_large', 'Request is too large.');
  }
  try {
    final result = jsonDecode(value);
    if (result is! Map<String, dynamic>) {
      _fail('invalid_input', 'Expected an object.');
    }
    return result;
  } on FormatException {
    _fail('invalid_input', 'Invalid JSON.');
  }
}

Json _object(dynamic value) {
  if (value is Map && value.keys.every((key) => key is String)) {
    return Map<String, dynamic>.from(value);
  }
  _fail('invalid_input', 'Expected an object.');
}

void _keys(Json d, Set<String> allowed) {
  if (d.keys.any((k) => !allowed.contains(k))) {
    _fail('invalid_input', 'Unknown field.');
  }
}

String _str(
  Json d,
  String k, {
  int max = 250,
  String? fallback,
  Set<String>? choices,
}) {
  final value = d[k] ?? fallback;
  if (value is! String ||
      value.trim().isEmpty ||
      value.length > max ||
      value.contains('\u0000')) {
    _fail('invalid_input', 'Invalid $k.');
  }
  if (choices != null && !choices.contains(value)) {
    _fail('invalid_input', 'Unsupported $k.');
  }
  return value.trim();
}

int _int(Json d, String k, {int min = 0, int max = 1000000, int? fallback}) {
  final value = d[k] ?? fallback;
  if (value is! int || value < min || value > max) {
    _fail('invalid_input', 'Invalid $k.');
  }
  return value;
}

bool _bool(Json d, String k, {bool fallback = false}) {
  final value = d[k] ?? fallback;
  if (value is! bool) _fail('invalid_input', 'Invalid $k.');
  return value;
}

List<dynamic> _list(Json d, String k, {int max = 100}) {
  final value = d[k] ?? <dynamic>[];
  if (value is! List || value.length > max) {
    _fail('invalid_input', 'Invalid $k.');
  }
  return value;
}

DateTime _date(Json d, String k) {
  final value = _str(d, k, max: 40);
  if (!RegExp(r'(Z|[+-]\d\d:\d\d)$').hasMatch(value)) {
    _fail('invalid_input', 'Use an explicit UTC offset for $k.');
  }
  return DateTime.tryParse(value)?.toUtc() ??
      _fail('invalid_input', 'Invalid $k.');
}

void _version(int actual, int? expected) {
  if (expected == null || actual != expected) {
    _fail('version_conflict', 'This record changed. Refresh before saving.');
  }
}

int _rid(PlatformCommand c) =>
    c.restaurantId ?? _fail('invalid_input', 'restaurantId is required.');
int _id(PlatformCommand c) =>
    c.resourceId ?? _fail('invalid_input', 'resourceId is required.');
const _managers = {'owner', 'manager'};
const _operators = {'owner', 'manager', 'waiter'};

/// Used by RPC and REST. Persisted rows are never serialized wholesale to clients.
class PlatformApi {
  // Web routes have a separate Request; RPC headers come from Session.request.
  // Expando keeps proofs scoped to this request's Session without global retention.
  static final _httpHeaders = Expando<Map<String, String>>(
    'platform-http-proof',
  );
  static void bindHttpHeaders(Session session, Map<String, String> headers) {
    _httpHeaders[session] = {
      for (final name in ['x-raysto-firebase-token', 'x-firebase-appcheck'])
        if (headers[name] != null) name: headers[name]!,
    };
  }

  static String? requestHeader(Session session, String name) =>
      _httpHeaders[session]?[name] ?? session.request?.headers[name]?.first;

  static void enabled() {
    if (Platform.environment['RAYSTO_PLATFORM_V2_ENABLED'] != 'true') {
      _fail('not_enabled', 'The platform API is not enabled.');
    }
  }

  /// JWT signatures alone do not establish that the backing session still exists.
  /// Apply this to legacy RPCs as well as v2, without changing their wire contract.
  static Future<AuthenticationInfo?> authenticate(
    Session s,
    String token,
  ) async {
    final identity = await AuthServices.instance.authenticationHandler(
      s,
      token,
    );
    if (identity == null) return null;
    final userId = UuidValue.fromString(identity.userIdentifier);
    final sessions = await AuthServices.instance.tokenManager.listTokens(
      s,
      authUserId: userId,
    );
    if (!sessions.any((item) => item.tokenId == identity.authId)) return null;
    final actor = await ActorProfile.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(identity.userIdentifier),
    );
    if (actor != null && (actor.disabled || actor.claimedBy != null)) {
      return null;
    }
    if (Platform.environment['RAYSTO_FIREBASE_ENABLED'] == 'true' &&
        actor?.isGuest != true) {
      final account = await AuthServices.instance.firebaseIdp.admin
          .findAccountByAuthUserId(s, authUserId: userId);
      if (account != null) {
        final lookup = await ProviderClients.lookupIdentity(
          account.userIdentifier,
        );
        final users = lookup['users'] as List? ?? [];
        if (users.length != 1 || users.single['disabled'] == true) {
          await AuthServices.instance.tokenManager.revokeAllTokens(
            s,
            authUserId: userId,
          );
          return null;
        }
      }
    }
    return identity;
  }

  static Future<void> guard(Session s) async {
    enabled();
    await ProviderClients.checkApp(s);
    final actor = await _actor(s);
    await requireCurrentSession(s);
    if (actor.isGuest) await ProviderClients.checkApp(s, required: true);
    if (!actor.isGuest) {
      final token = requestHeader(s, 'x-raysto-firebase-token');
      if (token == null || actor.firebaseUid == null) {
        _fail(
          'firebase_proof_required',
          'Provide a current Firebase identity token.',
        );
      }
      await ProviderClients.verifyIdentity(
        s,
        token,
        actor.firebaseUid!,
        recent: false,
      );
    }
  }

  static Future<void> requireCurrentSession(Session s) async {
    final identity = s.authenticated;
    if (identity == null) _fail('unauthorized', 'Sign in to continue.');
    final tokens = await AuthServices.instance.tokenManager.listTokens(
      s,
      authUserId: UuidValue.fromString(identity.userIdentifier),
    );
    if (!tokens.any((t) => t.tokenId == identity.authId)) {
      _fail('unauthorized', 'This backend session has been revoked.');
    }
  }

  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'room.split.reset': EqualShares.reset,
    'operations.archiveThread': WorkspaceModule.archiveThread,
    'assistant.start': AssistantModule.start,
    'assistant.cancel': AssistantModule.cancel,
    'assistant.approve': AssistantModule.approve,
    'operations.layout': WorkspaceModule.saveLayout,
    'room.open': ConversationModule.open,
    'room.message': ConversationModule.send,
    'room.read': ConversationModule.read,
    'room.preferences': ConversationModule.preferences,
    'room.host': ConversationModule.host,
    'room.report': ConversationModule.report,
    'identity.profile': IdentityModule.profile,
    'identity.claim': IdentityModule.claim,
    'identity.claimTicket': IdentityModule.claimTicket,
    'identity.revokeSessions': IdentityModule.revokeSessions,
    'identity.privacy': IdentityModule.privacy,
    'identity.stepUp': IdentityModule.stepUp,
    'restaurant.create': IdentityModule.createRestaurant,
    'restaurant.configure': CatalogueModule.configure,
    'restaurant.publish': CatalogueModule.publish,
    'team.invite': IdentityModule.invite,
    'team.accept': IdentityModule.accept,
    'team.membership': IdentityModule.membership,
    'team.transfer': IdentityModule.transfer,
    'menu.save': CatalogueModule.saveItem,
    'menu.availability': CatalogueModule.availability,
    'menu.draft': CatalogueModule.draft,
    'menu.publishDraft': CatalogueModule.publishDraft,
    'cart.save': OrderingModule.saveCart,
    'floor.save': DiningModule.saveFloor,
    'table.save': DiningModule.saveTable,
    'table.reset': DiningModule.resetTable,
    'visit.invite': DiningModule.invite,
    'visit.join': DiningModule.join,
    'visit.leave': DiningModule.leave,
    'visit.move': DiningModule.move,
    'visit.close': DiningModule.close,
    'service.create': DiningModule.request,
    'service.transition': DiningModule.transitionRequest,
    'reservation.create': DiningModule.reserve,
    'reservation.transition': DiningModule.reservationTransition,
    'waitlist.join': DiningModule.waitlistJoin,
    'waitlist.transition': DiningModule.waitlistTransition,
    'order.transition': OrderingModule.transition,
    'order.cancel': OrderingModule.cancel,
    'kitchen.progress': OrderingModule.kitchen,
    'delivery.assign': OrderingModule.assignCourier,
    'delivery.transition': OrderingModule.delivery,
    'delivery.location': OrderingModule.location,
    'payment.checkout': MoneyModule.checkout,
    'payment.capture': MoneyModule.capture,
    'payment.cancel': MoneyModule.cancel,
    'merchant.connect': MoneyModule.connectMerchant,
    'merchant.refresh': MoneyModule.refreshMerchant,
    'billing.subscribe': OperationsModule.subscribe,
    'billing.refresh': OperationsModule.refreshSubscription,
    'billing.cancel': OperationsModule.cancelSubscription,
    'favorite.set': OperationsModule.favorite,
    'review.save': OperationsModule.review,
    'review.moderate': OperationsModule.moderateReview,
    'support.open': OperationsModule.openConversation,
    'support.message': OperationsModule.message,
    'support.transition': OperationsModule.supportTransition,
    'notification.update': OperationsModule.notification,
    'media.upload': AiModule.upload,
    'media.publish': AiModule.publishMedia,
    'ai.start': AiModule.start,
    'ai.cancel': AiModule.cancel,
    'ai.approve': AiModule.approve,
    'admin.plan': OperationsModule.plan,
    'admin.suspend': OperationsModule.suspend,
    'admin.replayJob': OperationsModule.replay,
    'admin.paymentException': SettlementModule.resolve,
    'admin.reconcileRefund': SettlementModule.reconcileRefund,
  };

  static Future<PlatformResponse> command(
    Session s,
    String operation,
    PlatformCommand c,
  ) async {
    await guard(s);
    final handler =
        commands[operation] ?? _fail('not_found', 'Unknown operation.');
    return PlatformResponse(
      requestId: c.requestKey,
      dataJson: jsonEncode(await handler(s, c)),
    );
  }
}
