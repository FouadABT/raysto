part of 'platform.dart';

// 0.16, stream S6: each restaurant's own PayPal account.
//
// Two ways in, in the order PayPal allows them today:
// - Path B, "use my own PayPal app": the owner pastes the Client ID and
//   Secret of their PayPal developer app. Raysto checks them with PayPal,
//   stores the secret AES-256-GCM sealed, registers a webhook on that app,
//   reads which features the app has, and from then on every PayPal call for
//   the restaurant uses it. Works in Sandbox today.
// - Path A, "Connect with PayPal" (Partner Referrals, MoneyModule.connectMerchant):
//   ready, but PayPal answers NOT_AUTHORIZED until Raysto is an approved
//   partner. The status says so; nothing pretends it worked.
//
// Routing for a restaurant: its own app (ready) > its partner connection
// (ready) > the shared Sandbox merchant named in the server settings > not
// configured. One restaurant's keys are never used for another restaurant.

/// A restaurant's own PayPal app, opened for one call path. Lives only in
/// memory; it is never serialized and never printed.
class PayPalAccount {
  PayPalAccount._(
    this.appId,
    this.restaurantId,
    this.clientId,
    this._secret,
    this.credentialVersion,
    this.merchantId,
  );
  final int appId;
  final int restaurantId;
  final String clientId;
  final String _secret;
  final int credentialVersion;
  final String? merchantId;

  /// The provider name its webhook events are stored under.
  String get channel => 'paypal-app:$appId';
  String get _cacheKey => '$appId:$credentialVersion';

  @override
  String toString() => 'PayPalAccount(app $appId, restaurant $restaurantId)';
}

/// AES-256-GCM under the server-only RAYSTO_MERCHANT_SECRET_KEY (base64, 32
/// bytes). Each seal draws a fresh 96-bit nonce; the associated data binds
/// the ciphertext to its restaurant, environment, client id and key version,
/// so a sealed secret copied to another row does not open.
class MerchantSecrets {
  static int get keyVersion =>
      int.tryParse(
        ProviderClients.environment()['RAYSTO_MERCHANT_SECRET_KEY_VERSION'] ??
            '',
      ) ??
      1;

  static bool get configured {
    try {
      _key();
      return true;
    } on DomainError {
      return false;
    }
  }

  static Uint8List _key() {
    final raw =
        ProviderClients.environment()['RAYSTO_MERCHANT_SECRET_KEY']?.trim() ??
        '';
    Uint8List key;
    try {
      key = base64.decode(raw);
    } on FormatException {
      key = Uint8List(0);
    }
    if (key.length != 32) {
      _fail(
        'not_configured',
        'This server cannot store PayPal app keys yet '
            '(RAYSTO_MERCHANT_SECRET_KEY is not set).',
      );
    }
    return key;
  }

  static String aad(int restaurantId, String environment, String clientId) =>
      'raysto-merchant-app:v1:$restaurantId:$environment:$clientId:$keyVersion';

  static pc.GCMBlockCipher _cipher(bool seal, Uint8List nonce, String aad) =>
      pc.GCMBlockCipher(pc.AESEngine())..init(
        seal,
        pc.AEADParameters(
          pc.KeyParameter(_key()),
          128,
          nonce,
          Uint8List.fromList(utf8.encode(aad)),
        ),
      );

  static String seal(String secret, String aad) {
    final nonce = Uint8List.fromList([
      for (var i = 0; i < 12; i++) _random.nextInt(256),
    ]);
    final sealed = _cipher(
      true,
      nonce,
      aad,
    ).process(Uint8List.fromList(utf8.encode(secret)));
    return base64.encode([...nonce, ...sealed]);
  }

  static String open(String sealed, String aad) {
    // A missing key says so (not_configured) before any ciphertext is read.
    _key();
    try {
      final bytes = base64.decode(sealed);
      if (bytes.length < 12 + 16 + 1) throw const FormatException();
      return utf8.decode(
        _cipher(
          false,
          Uint8List.sublistView(bytes, 0, 12),
          aad,
        ).process(Uint8List.sublistView(bytes, 12)),
      );
    } catch (_) {
      _fail(
        'merchant_keys_unreadable',
        'The saved PayPal app keys cannot be opened on this server. '
            'The owner saves them again.',
      );
    }
  }
}

class MerchantAppModule {
  /// The read-only checklist, in display order.
  static const features = [
    'orders',
    'refunds',
    'payouts',
    'invoicing',
    'transactionSearch',
    'disputes',
  ];

  /// The events Raysto handles, registered on the restaurant's app.
  static const webhookEvents = [
    'CHECKOUT.ORDER.APPROVED',
    'CHECKOUT.ORDER.COMPLETED',
    'PAYMENT.CAPTURE.COMPLETED',
    'PAYMENT.CAPTURE.DENIED',
    'PAYMENT.CAPTURE.PENDING',
    'PAYMENT.CAPTURE.REFUNDED',
    'PAYMENT.CAPTURE.REVERSED',
    'PAYMENT.PAYOUTSBATCH.SUCCESS',
    'PAYMENT.PAYOUTSBATCH.DENIED',
    'CUSTOMER.DISPUTE.CREATED',
    'CUSTOMER.DISPUTE.UPDATED',
    'CUSTOMER.DISPUTE.RESOLVED',
    'INVOICING.INVOICE.PAID',
    'INVOICING.INVOICE.CANCELLED',
  ];

  static final _clientPattern = RegExp(r'^[A-Za-z0-9_-]{20,128}$');
  static final _merchantPattern = RegExp(r'^[A-Z0-9]{10,16}$');

  /// Who confirms identity before keys change. MFA by default, as for the
  /// partner connection; a deployment whose owners have no second factor can
  /// accept a fresh sign-in instead (RAYSTO_MERCHANT_APP_STEP_UP=recent_auth).
  static bool get _mfa =>
      ProviderClients.environment()['RAYSTO_MERCHANT_APP_STEP_UP'] !=
      'recent_auth';

  static Future<MerchantApp?> _row(
    Session s,
    int rid, {
    Transaction? tx,
    bool lock = false,
  }) => MerchantApp.db.findFirstRow(
    s,
    where: (t) =>
        t.restaurantId.equals(rid) &
        t.environment.equals(ProviderClients.paypalEnvironment),
    transaction: tx,
    lockMode: lock ? LockMode.forUpdate : null,
  );

  static PayPalAccount _open(MerchantApp a) => PayPalAccount._(
    a.id!,
    a.restaurantId,
    a.clientId,
    MerchantSecrets.open(
      a.secretCipher,
      MerchantSecrets.aad(a.restaurantId, a.environment, a.clientId),
    ),
    a.credentialVersion,
    a.merchantId,
  );

  /// The restaurant's own PayPal app when it is connected. Null means the
  /// restaurant has none, and the shared Sandbox merchant or the partner
  /// connection applies as before.
  static Future<PayPalAccount?> forRestaurant(
    Session s,
    int rid, {
    Transaction? tx,
  }) async {
    final a = await _row(s, rid, tx: tx);
    if (a == null || a.status != 'ready') return null;
    if (a.keyVersion != MerchantSecrets.keyVersion) {
      _fail(
        'merchant_keys_unreadable',
        'The server key changed; the owner saves the PayPal app keys again.',
      );
    }
    return _open(a);
  }

  /// The account a checkout was taken through. Only `ownApp` checkouts have
  /// one; they are never moved to another account.
  static Future<PayPalAccount?> forIntent(
    Session s,
    CheckoutIntent i,
  ) async {
    if (i.providerMode != 'ownApp') return null;
    final a = await forRestaurant(s, i.restaurantId);
    if (a == null) {
      _fail(
        'merchant_unavailable',
        'This payment went through the café\'s own PayPal app, which is no '
            'longer connected. The owner connects it again to finish.',
      );
    }
    if (i.merchantId.isNotEmpty &&
        a.merchantId != null &&
        a.merchantId != i.merchantId) {
      _fail(
        'merchant_changed',
        'This payment belongs to a different PayPal account than the one '
            'connected now.',
      );
    }
    return a;
  }

  /// What a payout batch records about the account that sent it.
  static Json route(PayPalAccount? a) => a == null
      ? {'mode': 'shared'}
      : {'mode': 'ownApp', 'appId': a.appId, 'clientId': a.clientId};

  /// The account to read a sent batch with: the one that sent it.
  static Future<PayPalAccount?> forPayout(Session s, PayoutBatch b) async {
    final r = _json(b.summaryJson)['paypal'];
    if (r is! Map || r['mode'] != 'ownApp') return null;
    final a = await forRestaurant(s, b.restaurantId);
    if (a == null || a.appId != r['appId'] || a.clientId != r['clientId']) {
      _fail(
        'merchant_changed',
        'This payout was sent from a PayPal app that is no longer connected.',
      );
    }
    return a;
  }

  /// The webhook channel a checkout's events must arrive on.
  static Future<String> channelFor(Session s, CheckoutIntent i) async {
    if (i.providerMode == 'singleMerchantSandbox') {
      return 'paypal-single-sandbox';
    }
    if (i.providerMode == 'ownApp') {
      final a = await _row(s, i.restaurantId);
      return a == null ? 'paypal-app:none' : 'paypal-app:${a.id}';
    }
    return 'paypal-platform';
  }

  /// The first order through an own app tells Raysto which PayPal account
  /// the app belongs to (the payee); nothing is created just to find out.
  static Future<void> learn(Work w, CheckoutIntent i, Json provider) async {
    if (i.providerMode != 'ownApp' || i.merchantId.isNotEmpty) return;
    final units = provider['purchase_units'];
    if (units is! List || units.length != 1) return;
    final payee = _object(_object(units.single)['payee'] ?? {})['merchant_id'];
    if (payee is! String || !_merchantPattern.hasMatch(payee)) return;
    i.merchantId = payee;
    final a = await _row(w.s, i.restaurantId, tx: w.tx);
    if (a != null && a.status == 'ready' && a.merchantId == null) {
      a
        ..merchantId = payee
        ..updatedAt = _now();
      await MerchantApp.db.updateRow(w.s, a, transaction: w.tx);
    }
  }

  static String webhookUrl(String token) {
    final v =
        ProviderClients.environment()['RAYSTO_PUBLIC_API_URL']?.trim() ?? '';
    final base = v.isEmpty ? 'https://api.rays.to' : v;
    final trimmed = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$trimmed/api/v2/webhooks/paypal-app/$token';
  }

  static String _token() => [
    for (var i = 0; i < 16; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();

  static String _end(String clientId) =>
      clientId.substring(clientId.length - 4);

  /// Payments and payouts still open on the app: changing or removing it
  /// would strand them, so the owner finishes them first.
  static Future<int> _openWork(Session s, MerchantApp a, Transaction tx) async {
    final since = _now().subtract(const Duration(hours: 6));
    final checkouts = await CheckoutIntent.db.count(
      s,
      where: (t) =>
          t.restaurantId.equals(a.restaurantId) &
          t.providerMode.equals('ownApp') &
          t.state.notInSet({'completed', 'cancelled', 'failed'}) &
          (t.updatedAt > since),
      transaction: tx,
    );
    final batches = await PayoutBatch.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(a.restaurantId) &
          t.state.inSet({'sending', 'sent'}),
      limit: 500,
      transaction: tx,
    );
    final payouts = batches.where((b) {
      final r = _json(b.summaryJson)['paypal'];
      return r is Map && r['mode'] == 'ownApp' && r['appId'] == a.id;
    }).length;
    return checkouts + payouts;
  }

  static ({String clientId, String secret, String? merchantId}) _input(
    Json d,
  ) {
    _keys(d, {'clientId', 'clientSecret', 'merchantId'});
    final clientId = d['clientId'] is String
        ? (d['clientId'] as String).trim()
        : '';
    final secret = d['clientSecret'] is String
        ? (d['clientSecret'] as String).trim()
        : '';
    if (!_clientPattern.hasMatch(clientId)) {
      _fail(
        'invalid_input',
        'Paste the app\'s Client ID from developer.paypal.com.',
      );
    }
    // The secret's own value never appears in a message.
    if (!_clientPattern.hasMatch(secret)) {
      _fail(
        'invalid_input',
        'Paste the app\'s Secret from developer.paypal.com.',
      );
    }
    final merchant = d['merchantId'] is String
        ? (d['merchantId'] as String).trim().toUpperCase()
        : null;
    if (merchant != null &&
        merchant.isNotEmpty &&
        !_merchantPattern.hasMatch(merchant)) {
      _fail(
        'invalid_input',
        'The PayPal merchant ID has 10 to 16 letters and digits.',
      );
    }
    return (
      clientId: clientId,
      secret: secret,
      merchantId: merchant == null || merchant.isEmpty ? null : merchant,
    );
  }

  /// `merchant.app.save`: the owner connects (or rotates) the restaurant's
  /// own PayPal app. PayPal must accept the keys before anything is stored.
  static Future<Json> save(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'merchant.app.save', (w, d) async {
      _input(d);
      if (ProviderClients.paypalEnvironment != 'sandbox') {
        _fail(
          'not_configured',
          'Own PayPal apps are Sandbox-only on this deployment.',
        );
      }
      MerchantSecrets._key();
      await _stepUp(w, mfa: _mfa);
      return {'restaurantId': w.tenant};
    }, roles: {'owner'});
    final rid = c.restaurantId!;
    final input = _input(_json(c.dataJson));
    final token = await ProviderClients.ownAppToken(
      input.clientId,
      input.secret,
    );
    final user = s.authenticated!.userIdentifier;
    await MoneyModule.locked(s, rid, user, (w) async {
      await w.role({'owner'});
      final elsewhere = await MerchantApp.db.findFirstRow(
        s,
        where: (t) =>
            t.clientId.equals(input.clientId) &
            t.status.equals('ready') &
            t.restaurantId.notEquals(rid),
        transaction: w.tx,
      );
      if (elsewhere != null) {
        _fail(
          'merchant_app_in_use',
          'This PayPal app is already connected to another restaurant. '
              'Use one PayPal app per restaurant.',
        );
      }
      final env = ProviderClients.paypalEnvironment;
      final sealed = MerchantSecrets.seal(
        input.secret,
        MerchantSecrets.aad(rid, env, input.clientId),
      );
      var a = await _row(s, rid, tx: w.tx, lock: true);
      final newApp =
          a == null || a.status != 'ready' || a.clientId != input.clientId;
      if (a != null && a.status == 'ready' && a.clientId != input.clientId) {
        final open = await _openWork(s, a, w.tx);
        if (open > 0) {
          _fail(
            'merchant_busy',
            '$open PayPal payment${open == 1 ? ' is' : 's are'} still open on '
                'the current app. Finish ${open == 1 ? 'it' : 'them'} first.',
          );
        }
      }
      final now = _now();
      if (a == null) {
        a = await MerchantApp.db.insertRow(
          s,
          MerchantApp(
            restaurantId: rid,
            environment: env,
            clientId: input.clientId,
            secretCipher: sealed,
            keyVersion: MerchantSecrets.keyVersion,
            credentialVersion: 1,
            status: 'ready',
            merchantId: input.merchantId,
            appId: token['appId'] as String?,
            webhookToken: _token(),
            webhookStatus: 'pending',
            featuresJson: '{}',
            savedBy: w.user,
            createdAt: now,
            updatedAt: now,
            version: 1,
          ),
          transaction: w.tx,
        );
      } else {
        a
          ..clientId = input.clientId
          ..secretCipher = sealed
          ..keyVersion = MerchantSecrets.keyVersion
          ..credentialVersion += 1
          ..status = 'ready'
          ..merchantId = input.merchantId ?? (newApp ? null : a.merchantId)
          ..appId = token['appId'] as String? ?? a.appId
          ..savedBy = w.user
          ..updatedAt = now
          ..version += 1;
        if (newApp) {
          // A different PayPal app: a fresh webhook address, so events from
          // the old app stop at a 404, and a fresh checklist.
          a
            ..webhookToken = _token()
            ..webhookId = null
            ..webhookStatus = 'pending'
            ..featuresJson = '{}'
            ..checkedAt = null;
        }
        await MerchantApp.db.updateRow(s, a, transaction: w.tx);
      }
      await w.audit('merchant.app.saved', 'merchantApp', a.id, {
        'clientIdEnd': _end(input.clientId),
        'newApp': newApp,
        'environment': env,
      });
    });
    await check(s, rid);
    return status(s, rid, user);
  }

  /// `merchant.app.check`: registers the webhook if it is missing and reads
  /// the feature checklist again. Owners and managers.
  static Future<Json> recheck(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'merchant.app.check', (w, d) async {
      _keys(d, {});
      final a = await _row(s, w.tenant, tx: w.tx);
      if (a == null || a.status != 'ready') {
        _fail('not_found', 'No PayPal app is connected to this restaurant.');
      }
      return {'restaurantId': w.tenant};
    }, roles: _managers);
    await check(s, c.restaurantId!);
    return status(s, c.restaurantId!, s.authenticated!.userIdentifier);
  }

  /// `merchant.app.remove`: the owner disconnects the app. The sealed secret
  /// is erased; the restaurant falls back to the shared Sandbox merchant (or
  /// its partner connection), or to no PayPal at all.
  static Future<Json> remove(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'merchant.app.remove', (w, d) async {
      _keys(d, {});
      await _stepUp(w, mfa: _mfa);
      final a = await _row(s, w.tenant, tx: w.tx);
      if (a == null || a.status != 'ready') {
        _fail('not_found', 'No PayPal app is connected to this restaurant.');
      }
      final open = await _openWork(s, a, w.tx);
      if (open > 0) {
        _fail(
          'merchant_busy',
          '$open PayPal payment${open == 1 ? ' is' : 's are'} still open on '
              'this app. Finish ${open == 1 ? 'it' : 'them'} first.',
        );
      }
      return {'restaurantId': w.tenant};
    }, roles: {'owner'});
    final rid = c.restaurantId!;
    final user = s.authenticated!.userIdentifier;
    // Best effort: take Raysto's webhook off the app while the keys still open.
    try {
      final a = await _row(s, rid);
      if (a?.webhookId != null && a!.status == 'ready') {
        await ProviderClients.ownRaw(
          _open(a),
          'DELETE',
          '/v1/notifications/webhooks/${a.webhookId}',
        );
      }
    } catch (_) {
      // The webhook stays at PayPal; its address now answers 404.
    }
    await MoneyModule.locked(s, rid, user, (w) async {
      await w.role({'owner'});
      final a = await _row(s, rid, tx: w.tx, lock: true);
      if (a == null || a.status != 'ready') return;
      final open = await _openWork(s, a, w.tx);
      if (open > 0) {
        _fail('merchant_busy', 'A PayPal payment opened meanwhile. Try again.');
      }
      a
        ..status = 'removed'
        ..secretCipher = ''
        ..credentialVersion += 1
        ..webhookId = null
        ..webhookStatus = 'pending'
        ..webhookToken = _token()
        ..updatedAt = _now()
        ..version += 1;
      await MerchantApp.db.updateRow(s, a, transaction: w.tx);
      await w.audit('merchant.app.removed', 'merchantApp', a.id, {
        'clientIdEnd': _end(a.clientId),
      });
    });
    ProviderClients.forgetOwnTokens();
    return status(s, rid, user);
  }

  /// Registers the webhook and reads the checklist with the restaurant's
  /// own keys. Read-only at PayPal except the webhook. Never throws: what
  /// failed is recorded for the owner to see.
  static Future<void> check(Session s, int rid) async {
    final a = await _row(s, rid);
    if (a == null || a.status != 'ready') return;
    final account = _open(a);
    final found = <String, Json>{};
    String? merchant;
    Json state(int status, Json body) {
      if (status >= 200 && status < 300) return {'state': 'enabled'};
      // An unknown id answers 404 (or 400/422) only after PayPal let the
      // app in: the feature is on, there is simply nothing to show.
      if ({400, 404, 422}.contains(status)) return {'state': 'enabled'};
      if (status == 403) return {'state': 'notEnabled', 'code': body['name']};
      if (status == 401) return {'state': 'keysRejected'};
      return {
        'state': 'unknown',
        'code': status == 0 ? 'unreachable' : '$status',
      };
    }

    String iso(DateTime t) =>
        '${t.toUtc().toIso8601String().split('.').first}Z';
    final end = _now().subtract(const Duration(hours: 4));
    final probes = <String, (String, String)>{
      'orders': ('GET', '/v2/checkout/orders/RAYSTOPROBE00000'),
      'refunds': ('GET', '/v2/payments/refunds/RAYSTOPROBE00000'),
      'payouts': ('GET', '/v1/payments/payouts/RAYSTOPROBE00000'),
      'invoicing': ('GET', '/v2/invoicing/invoices?page=1&page_size=1'),
      'transactionSearch': (
        'GET',
        '/v1/reporting/transactions?start_date=${iso(end.subtract(const Duration(days: 1)))}'
            '&end_date=${iso(end)}&fields=transaction_info&page_size=1',
      ),
      'disputes': ('GET', '/v1/customer/disputes?page_size=1'),
    };
    for (final e in probes.entries) {
      try {
        final (status, body) = await ProviderClients.ownRaw(
          account,
          e.value.$1,
          e.value.$2,
        );
        found[e.key] = state(status, body);
        if (e.key == 'transactionSearch' &&
            status == 200 &&
            body['account_number'] is String &&
            _merchantPattern.hasMatch(body['account_number'] as String)) {
          merchant = body['account_number'] as String;
        }
      } on DomainError catch (err) {
        found[e.key] = {'state': 'unknown', 'code': err.code};
      } catch (_) {
        found[e.key] = {'state': 'unknown', 'code': 'unreachable'};
      }
    }
    String? webhookId = a.webhookId;
    var webhookStatus = a.webhookStatus;
    if (webhookId == null) {
      final url = webhookUrl(a.webhookToken);
      try {
        final (status, body) = await ProviderClients.ownRaw(
          account,
          'POST',
          '/v1/notifications/webhooks',
          body: {
            'url': url,
            'event_types': [
              for (final name in webhookEvents) {'name': name},
            ],
          },
        );
        if (status >= 200 && status < 300 && body['id'] is String) {
          webhookId = body['id'] as String;
        } else if (body['name'] == 'WEBHOOK_URL_ALREADY_EXISTS') {
          final (_, list) = await ProviderClients.ownRaw(
            account,
            'GET',
            '/v1/notifications/webhooks',
          );
          for (final h in (list['webhooks'] as List? ?? []).whereType<Map>()) {
            if (h['url'] == url && h['id'] is String) {
              webhookId = h['id'] as String;
            }
          }
        }
        webhookStatus = webhookId == null ? 'failed' : 'registered';
      } catch (_) {
        webhookStatus = 'failed';
      }
    }
    await s.db.transaction((tx) async {
      final fresh = await MerchantApp.db.findById(
        s,
        a.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      // Keys saved again meanwhile: that save runs its own check.
      if (fresh == null ||
          fresh.status != 'ready' ||
          fresh.credentialVersion != a.credentialVersion) {
        return;
      }
      fresh
        ..featuresJson = jsonEncode(found)
        ..checkedAt = _now()
        ..webhookId = webhookId
        ..webhookStatus = webhookStatus
        ..merchantId = fresh.merchantId ?? merchant
        ..updatedAt = _now();
      await MerchantApp.db.updateRow(s, fresh, transaction: tx);
    });
  }

  static bool get partnerAvailable => [
    'PAYPAL_PLATFORM_CLIENT_ID',
    'PAYPAL_PLATFORM_CLIENT_SECRET',
    'PAYPAL_PLATFORM_MERCHANT_ID',
    'PAYPAL_PLATFORM_BN_CODE',
  ].every((k) => ProviderClients.environment()[k]?.trim().isNotEmpty == true);

  static const partnerNote =
      'Needs PayPal\'s partner approval for Raysto. Until then, use your own '
      'PayPal app.';

  static const _labels = {
    'orders': 'Take payments (Orders)',
    'refunds': 'Refunds',
    'payouts': 'Payouts (bills, wages, tips, suppliers, drivers)',
    'invoicing': 'Invoicing (catering, payment requests)',
    'transactionSearch': 'Transaction Search (the daily close)',
    'disputes': 'Disputes',
  };

  /// `merchant.status`: how this restaurant takes and sends PayPal money now.
  /// Never includes a secret, a token or the webhook address.
  static Future<Json> status(Session s, int rid, String user) async {
    final member = await Membership.db.findFirstRow(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.userId.equals(user) &
          t.active.equals(true),
    );
    if (member == null || !_finance.contains(member.role)) {
      _fail('forbidden', 'This action is not permitted.');
    }
    final env = ProviderClients.paypalEnvironment;
    final a = await _row(s, rid);
    final connection = await MerchantConnection.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(rid) & t.environment.equals(env),
    );
    final partnerReady =
        connection?.status == 'ready' &&
        connection?.merchantId != null &&
        connection?.verifiedAt != null &&
        _now().difference(connection!.verifiedAt!).inHours <= 24;
    final shared = ProviderClients.singleRestaurant(rid);
    final own = a != null && a.status == 'ready';
    final found = own ? _json(a.featuresJson) : const <String, dynamic>{};
    return {
      'restaurantId': rid,
      'environment': env,
      'mode': own
          ? 'ownApp'
          : partnerReady
          ? 'partner'
          : shared
          ? 'sharedSandbox'
          : 'none',
      'canEdit': member.role == 'owner',
      'keysStorable': MerchantSecrets.configured && env == 'sandbox',
      'stepUp': _mfa ? 'mfa' : 'recentAuth',
      'ownApp': own
          ? {
              'status': a.status,
              'clientIdEnd': _end(a.clientId),
              'merchantId': a.merchantId,
              'webhook': a.webhookStatus,
              'checkedAt': a.checkedAt?.toIso8601String(),
              'updatedAt': a.updatedAt.toIso8601String(),
              'version': a.version,
              'features': [
                for (final name in features)
                  {
                    'name': name,
                    'label': _labels[name],
                    'state': _object(found[name] ?? {})['state'] ?? 'unchecked',
                  },
              ],
            }
          : null,
      'partner': {
        'available': partnerAvailable,
        'status': connection?.status ?? 'notConnected',
        'merchantId': connection?.merchantId,
        'verifiedAt': connection?.verifiedAt?.toIso8601String(),
        if (!partnerAvailable || connection?.status == 'approvalRequired')
          'note': partnerNote,
      },
      'shared': shared,
    };
  }

  /// PayPal's MERCHANT.ONBOARDING.COMPLETED (partner channel): the seller
  /// finished Connect with PayPal; read their integration as the partner and
  /// mark the connection ready or restricted, as `merchant.refresh` would.
  static Future<void> onboardingCompleted(Session s, Json resource) async {
    final merchant = _str(resource, 'merchant_id', max: 50);
    final details = await MoneyModule.merchantIntegration(merchant);
    final tracking = details['tracking_id'];
    if (tracking is! String) {
      _fail('unmatched_provider_event', 'Onboarding has no tracking id.');
    }
    final m = await MerchantConnection.db.findFirstRow(
      s,
      where: (t) =>
          t.trackingId.equals(tracking) &
          t.environment.equals(ProviderClients.paypalEnvironment),
    );
    if (m == null) {
      _fail('unmatched_provider_event', 'No connection for this onboarding.');
    }
    MoneyModule.applyIntegration(m, merchant, details);
    await MerchantConnection.db.updateRow(s, m);
  }
}
