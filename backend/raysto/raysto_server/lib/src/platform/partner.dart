part of 'platform.dart';

/// Delivery partner apps: hashed keys, signed webhooks both ways, and the
/// event log judges see (plan section 4). Owner: stream S2.
///
/// - **Keys.** A partner app gets one key, `rk_<prefix>_<secret>`, shown
///   once. Raysto keeps the prefix and a SHA-256 hash, never the key.
/// - **Webhook secret.** `whsec_…`, an HMAC of the app id and its secret
///   version under the server's `RAYSTO_PARTNER_PEPPER`. It is derived, never
///   stored, shown once, and rotated by bumping the version. The same secret
///   signs the partner's requests and Raysto's webhooks.
/// - **Requests.** `Authorization: Bearer rk_…`, an `X-Raysto-Signature`
///   of the form `t=…,v1=…` (the hex HMAC-SHA256 of `t.body`, with 5
///   minutes of tolerance), and an `Idempotency-Key` on every POST. 64 KB
///   per request, 60 requests a minute per app.
/// - **Money.** Partner orders are settled outside PayPal: they carry the
///   payment status `externalPartner` until the café's accountant sends the
///   partner a PayPal payment request for what it owes ([settlementDue]).
class PartnerModule {
  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'partner.app.save': save,
    'partner.app.rotate': rotate,
    // The names in the stream brief, kept as aliases of the two above.
    'partner.create': create,
    'partner.rotate': rotate,
    'partner.disable': disable,
  };

  static const maxBytes = 65536;
  static const perMinute = 60;
  static const tolerance = Duration(minutes: 5);

  /// Outbound retries after the first attempt: 1 min, 5 min, 30 min, 2 h, 6 h.
  static const backoff = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 30),
    Duration(hours: 2),
    Duration(hours: 6),
  ];

  // ---- Secrets ----------------------------------------------------------------

  static String? _pepperOrNull() {
    final p = ProviderClients.environment()['RAYSTO_PARTNER_PEPPER'] ?? '';
    return p.length >= 32 ? p : null;
  }

  static String _pepper() =>
      _pepperOrNull() ??
      _fail('not_configured', 'Partner apps are not configured on this server.');

  static bool get configured => _pepperOrNull() != null;

  static String _derived(int appId, int version) {
    final mac = Hmac(sha256, utf8.encode(_pepper()));
    return 'whsec_${mac.convert(utf8.encode('whsec:$appId:$version'))}';
  }

  /// The app's current webhook secret (requires the pepper).
  static String webhookSecret(PartnerApp app) =>
      _derived(app.id!, app.secretVersion);

  /// `hex(HMAC-SHA256(secret, "t.body"))`, for both directions.
  static String sign(String secret, int t, String body) => Hmac(
    sha256,
    utf8.encode(secret),
  ).convert(utf8.encode('$t.$body')).toString();

  static bool _same(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static const _alphabet = 'abcdefghijkmnpqrstuvwxyz23456789';
  static String _token(int n) => List.generate(
    n,
    (_) => _alphabet[_random.nextInt(_alphabet.length)],
  ).join();

  /// Public https only: no IP literals, no local names, no custom ports.
  /// Each delivery also checks that the name resolves to public addresses.
  static String _webhookUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    final host = uri?.host.toLowerCase() ?? '';
    if (uri == null ||
        uri.scheme != 'https' ||
        host.isEmpty ||
        !host.contains('.') ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && uri.port != 443) ||
        uri.fragment.isNotEmpty ||
        InternetAddress.tryParse(host) != null ||
        host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host.endsWith('.internal')) {
      _fail('invalid_input', 'Use a public https:// webhook URL.');
    }
    return uri.toString();
  }

  /// Test seam: whether a webhook host resolves only to public addresses.
  static Future<bool> Function(String host) publicHost = _publicHost;

  static Future<bool> _publicHost(String host) async {
    try {
      final found = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 3));
      return found.isNotEmpty && found.every((a) => !_private(a));
    } catch (_) {
      return false;
    }
  }

  static bool _private(InternetAddress a) {
    if (a.isLoopback || a.isLinkLocal || a.isMulticast) return true;
    final b = a.rawAddress;
    if (a.type == InternetAddressType.IPv4) {
      return b[0] == 0 ||
          b[0] == 10 ||
          b[0] == 127 ||
          (b[0] == 100 && b[1] >= 64 && b[1] <= 127) ||
          (b[0] == 169 && b[1] == 254) ||
          (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
          (b[0] == 192 && b[1] == 168);
    }
    final mapped = b.length == 16 &&
        b.sublist(0, 10).every((x) => x == 0) &&
        b[10] == 0xff &&
        b[11] == 0xff;
    if (mapped) {
      return _private(InternetAddress.fromRawAddress(b.sublist(12)));
    }
    return (b[0] & 0xfe) == 0xfc || b.every((x) => x == 0);
  }

  // ---- Managing apps --------------------------------------------------------

  static Future<PartnerApp> _app(Work w, int id) async {
    final app = await PartnerApp.db.findById(w.s, id, transaction: w.tx);
    if (app == null || app.restaurantId != w.tenant) {
      _fail('not_found', 'Partner app not found.');
    }
    return app;
  }

  static Json view(PartnerApp app) => {
    'id': app.id,
    'name': app.name,
    'keyPrefix': app.keyPrefix,
    'keyHint': 'rk_${app.keyPrefix}_…',
    'webhookUrl': app.webhookUrl,
    'secretVersion': app.secretVersion,
    'simulator': app.simulator,
    'active': app.active,
    'version': app.version,
    'createdAt': app.createdAt.toIso8601String(),
    'updatedAt': app.updatedAt.toIso8601String(),
  };

  /// A manager registers an app (after confirming their identity). The key
  /// and the webhook secret are in this one response and nowhere else: the
  /// receipt `_mutate` keeps for retries holds neither, so a retry of the
  /// same request says the key was already shown.
  static Future<Json> save(Session s, PlatformCommand c) async {
    if (c.resourceId != null) return _update(s, c);
    final prefix = _token(8);
    final key = 'rk_${prefix}_${_secret()}';
    final result = await _mutate(s, c, 'partner.app.save', (w, d) async {
      _keys(d, {'name', 'webhookUrl', 'simulator'});
      _pepper();
      await _stepUp(w);
      final count = await PartnerApp.db.count(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      if (count >= 10) {
        _fail('limit_reached', 'A café can have at most 10 partner apps.');
      }
      final app = await PartnerApp.db.insertRow(
        s,
        PartnerApp(
          restaurantId: w.tenant,
          name: _str(d, 'name', max: 80),
          keyPrefix: prefix,
          keyHash: _hash(key),
          webhookUrl: d['webhookUrl'] == null
              ? null
              : _webhookUrl(_str(d, 'webhookUrl', max: 500)),
          secretVersion: 1,
          simulator: _bool(d, 'simulator'),
          active: true,
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('partner.app_created', 'partnerApp', app.id, {
        'simulator': app.simulator,
      });
      return view(app);
    }, roles: _managers);
    if (result['keyPrefix'] != prefix) return {...result, 'shown': false};
    return {
      ...result,
      'key': key,
      'webhookSecret': _derived(result['id'] as int, 1),
      'shown': true,
    };
  }

  static Future<Json> create(Session s, PlatformCommand c) =>
      c.resourceId != null
      ? _fail('invalid_input', 'Use partner.app.save to edit an app.')
      : save(s, c);

  static Future<Json> disable(Session s, PlatformCommand c) =>
      _update(s, c.copyWith(dataJson: jsonEncode({'active': false})));

  static Future<Json> _update(Session s, PlatformCommand c) =>
      _mutate(s, c, 'partner.app.save', (w, d) async {
        _keys(d, {'name', 'webhookUrl', 'active', 'simulator'});
        final app = await _app(w, _id(c));
        _version(app.version, c.expectedVersion);
        if (d.containsKey('name')) app.name = _str(d, 'name', max: 80);
        if (d.containsKey('webhookUrl')) {
          app.webhookUrl = d['webhookUrl'] == null
              ? null
              : _webhookUrl(_str(d, 'webhookUrl', max: 500));
        }
        if (d.containsKey('active')) {
          final on = _bool(d, 'active');
          // Switching a key back on is as sensitive as issuing one.
          if (on && !app.active) await _stepUp(w);
          app.active = on;
        }
        if (d.containsKey('simulator')) app.simulator = _bool(d, 'simulator');
        app
          ..version += 1
          ..updatedAt = _now();
        await PartnerApp.db.updateRow(s, app, transaction: w.tx);
        await w.audit('partner.app_updated', 'partnerApp', app.id, {
          'active': app.active,
        });
        return view(app);
      }, roles: _managers);

  /// A new key (the old one stops at once) or a new webhook secret.
  static Future<Json> rotate(Session s, PlatformCommand c) async {
    final prefix = _token(8);
    final key = 'rk_${prefix}_${_secret()}';
    final nonce = _token(12);
    final result = await _mutate(s, c, 'partner.app.rotate', (w, d) async {
      _keys(d, {'what'});
      final what = _str(d, 'what', fallback: 'key', choices: {'key', 'secret'});
      _pepper();
      await _stepUp(w);
      final app = await _app(w, _id(c));
      _version(app.version, c.expectedVersion);
      if (what == 'key') {
        app
          ..keyPrefix = prefix
          ..keyHash = _hash(key);
      } else {
        app.secretVersion += 1;
      }
      app
        ..version += 1
        ..updatedAt = _now();
      await PartnerApp.db.updateRow(s, app, transaction: w.tx);
      await w.audit('partner.app_rotated', 'partnerApp', app.id, {
        'what': what,
      });
      return {...view(app), 'what': what, 'rotation': nonce};
    }, roles: _managers);
    final out = Map<String, dynamic>.from(result)..remove('rotation');
    if (result['rotation'] != nonce) return {...out, 'shown': false};
    return result['what'] == 'key'
        ? {...out, 'key': key, 'shown': true}
        : {
            ...out,
            'webhookSecret': _derived(
              result['id'] as int,
              result['secretVersion'] as int,
            ),
            'shown': true,
          };
  }

  // ---- What a partner owes ----------------------------------------------------

  /// Partner orders delivered in [from, to) that are still settled outside
  /// PayPal: what the café's accountant asks the partner to pay (stream S1).
  static Future<Json> settlementDue(
    Session s,
    int restaurantId,
    int partnerAppId,
    DateTime from,
    DateTime to, {
    Transaction? tx,
  }) async {
    // A paid payment request to this partner settles every partner order
    // delivered before the request was made, so those are not owed again.
    final settled = await PaymentRequest.db.findFirstRow(
      s,
      where: (t) =>
          t.restaurantId.equals(restaurantId) &
          t.partnerAppId.equals(partnerAppId) &
          t.state.equals('paid'),
      orderBy: (t) => t.createdAt.desc(),
      transaction: tx,
    );
    final start = settled != null && settled.createdAt.isAfter(from)
        ? settled.createdAt
        : from;
    final rows = await DeliveryAssignment.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(restaurantId) &
          t.partnerAppId.equals(partnerAppId) &
          t.status.equals('delivered') &
          (t.deliveredAt >= start) &
          (t.deliveredAt < to),
      orderBy: (t) => t.id,
      limit: 5000,
      transaction: tx,
    );
    var total = 0;
    String? currency;
    final ids = <int>[];
    for (final a in rows) {
      final o = await PurchaseOrder.db.findById(s, a.orderId, transaction: tx);
      if (o == null || o.paymentStatus != 'externalPartner') continue;
      total += o.totalMinor;
      currency ??= o.currency;
      ids.add(o.id!);
    }
    return {
      'partnerAppId': partnerAppId,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'orders': ids.length,
      'orderIds': ids,
      'totalMinor': total,
      'currency': currency,
      if (settled != null) 'settledUpTo': settled.createdAt.toIso8601String(),
      'basis':
          'Partner orders delivered in the period, settled outside PayPal '
          '(externalPartner) until the partner pays a payment request; a '
          'paid request covers everything delivered before it was made.',
    };
  }

  // ---- Queries ----------------------------------------------------------------

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async => switch (name) {
    'partner.apps' => apps(w),
    'partner.events' => events(w, d, limit, cursor),
    _ => null,
  };

  static Future<Json> apps(Work w) async {
    await w.role(_managers);
    final rows = await PartnerApp.db.find(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.id,
      transaction: w.tx,
    );
    final now = _now();
    final month = DateTime.utc(now.year, now.month);
    return {
      'configured': configured,
      'endpoint': '/api/partner/v1',
      'rows': [
        for (final app in rows)
          {
            ...view(app),
            'owedThisMonth': await settlementDue(
              w.s,
              w.tenant,
              app.id!,
              month,
              now.add(const Duration(seconds: 1)),
              tx: w.tx,
            ),
            'events24h': await PartnerEvent.db.count(
              w.s,
              where: (t) =>
                  t.partnerAppId.equals(app.id!) &
                  (t.createdAt > now.subtract(const Duration(hours: 24))),
              transaction: w.tx,
            ),
            'failing': await PartnerEvent.db.count(
              w.s,
              where: (t) =>
                  t.partnerAppId.equals(app.id!) &
                  t.status.inSet({'retrying', 'failed'}),
              transaction: w.tx,
            ),
          },
      ],
    };
  }

  /// The log of every call both ways, newest first.
  static Future<Json> events(Work w, Json d, int limit, int cursor) async {
    await w.role(_managers);
    final raw = d['appId'];
    final appId = raw is int ? raw : int.tryParse('${raw ?? ''}');
    final rows = await PartnerEvent.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (appId == null ? Constant.bool(true) : t.partnerAppId.equals(appId)) &
          (cursor == 0 ? Constant.bool(true) : t.id < cursor),
      orderBy: (t) => t.id.desc(),
      limit: limit,
      transaction: w.tx,
    );
    final names = <int, PartnerApp?>{};
    final out = <Json>[];
    for (final e in rows) {
      final app = names[e.partnerAppId] ??= await PartnerApp.db.findById(
        w.s,
        e.partnerAppId,
        transaction: w.tx,
      );
      out.add({
        'id': e.id,
        'appId': e.partnerAppId,
        'appName': app?.name,
        'simulator': app?.simulator ?? false,
        'direction': e.direction,
        'type': e.type,
        'ref': e.ref,
        'status': e.status,
        'attempts': e.attempts,
        'responseCode': e.responseCode,
        'idempotencyKey': e.idempotencyKey,
        'summary': _json(e.payloadJson),
        'nextAttemptAt': e.nextAttemptAt?.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      });
    }
    return {
      'rows': out,
      'nextCursor': rows.length == limit ? rows.last.id : null,
    };
  }

  // ---- Outbound webhooks --------------------------------------------------------

  /// Whether this work runs a partner's own request: its events are not
  /// echoed back to the partner as webhooks.
  static bool byPartner(Work w) =>
      w.command.requestKey.startsWith('partner-');

  /// Queues one signed webhook (or logs it as skipped when the app has no
  /// webhook URL).
  static Future<void> emit(
    Work w,
    int appId,
    String type,
    String? ref,
    Json data,
  ) async {
    final app = await PartnerApp.db.findById(w.s, appId, transaction: w.tx);
    if (app == null || !app.active) return;
    final hook = app.webhookUrl != null;
    final e = await PartnerEvent.db.insertRow(
      w.s,
      PartnerEvent(
        restaurantId: app.restaurantId,
        partnerAppId: app.id!,
        direction: 'out',
        type: type,
        ref: ref,
        status: hook ? 'pending' : 'skipped',
        attempts: 0,
        payloadJson: jsonEncode(data),
        nextAttemptAt: hook ? _now() : null,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: w.tx,
    );
    if (hook) {
      await w.job('partner.webhook', 'partner-webhook:${e.id}:0', {
        'eventId': e.id,
        'attempt': 0,
      });
    }
  }

  /// The `partner.webhook` job. Never throws: it records the answer and
  /// schedules its own retry, so the worker's generic retries stay out of it.
  static Future<void> deliver(Session s, int eventId, int attempt) async {
    final e = await PartnerEvent.db.findById(s, eventId);
    if (e == null ||
        e.direction != 'out' ||
        !{'pending', 'retrying'}.contains(e.status) ||
        e.attempts != attempt) {
      return;
    }
    final app = await PartnerApp.db.findById(s, e.partnerAppId);
    int? code;
    var skipped = false;
    if (app == null || !app.active || app.webhookUrl == null) {
      skipped = true;
    } else {
      try {
        final uri = Uri.parse(app.webhookUrl!);
        if (await publicHost(uri.host)) {
          final body = jsonEncode({
            'id': 'evt_${e.id}',
            'type': e.type,
            'createdAt': e.createdAt.toIso8601String(),
            'restaurantId': e.restaurantId,
            if (e.ref != null) 'ref': e.ref,
            'attempt': attempt + 1,
            'data': _json(e.payloadJson),
          });
          final t = _now().millisecondsSinceEpoch ~/ 1000;
          final request = http.Request('POST', uri)
            ..followRedirects = false
            ..headers.addAll({
              'content-type': 'application/json',
              'user-agent': 'Raysto-Webhooks/1.0 (+https://rays.to)',
              'x-raysto-event': e.type,
              'x-raysto-event-id': 'evt_${e.id}',
              'x-raysto-signature': 't=$t,v1=${sign(webhookSecret(app), t, body)}',
            })
            ..body = body;
          final client = ProviderClients.httpClient();
          try {
            final response = await client
                .send(request)
                .timeout(const Duration(seconds: 5));
            code = response.statusCode;
            await response.stream.drain<void>().timeout(
              const Duration(seconds: 2),
              onTimeout: () {},
            );
          } finally {
            client.close();
          }
        }
      } catch (_) {
        // A timeout, a refused connection or a blocked host: retried below.
      }
    }
    await s.db.transaction((tx) async {
      final row = await PartnerEvent.db.findById(
        s,
        eventId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row == null || row.attempts != attempt) return;
      row
        ..attempts = attempt + 1
        ..responseCode = code
        ..updatedAt = _now();
      if (skipped) {
        row
          ..status = 'skipped'
          ..nextAttemptAt = null;
      } else if (code != null && code >= 200 && code < 300) {
        row
          ..status = 'delivered'
          ..nextAttemptAt = null;
      } else if (attempt < backoff.length) {
        final at = _now().add(backoff[attempt]);
        row
          ..status = 'retrying'
          ..nextAttemptAt = at;
        await PlatformJob.db.insert(s, [
          PlatformJob(
            restaurantId: row.restaurantId,
            kind: 'partner.webhook',
            dedupeKey: 'partner-webhook:${row.id}:${attempt + 1}',
            payloadJson: jsonEncode({'eventId': row.id, 'attempt': attempt + 1}),
            state: 'pending',
            attempts: 0,
            availableAt: at,
            createdAt: _now(),
          ),
        ], ignoreConflicts: true, transaction: tx);
      } else {
        row
          ..status = 'failed'
          ..nextAttemptAt = null;
      }
      await PartnerEvent.db.updateRow(s, row, transaction: tx);
    });
  }

  // ---- The inbound API ------------------------------------------------------------

  static int _httpStatus(String code) => switch (code) {
    'unauthorized' ||
    'signature_required' ||
    'stale_signature' ||
    'bad_signature' => 401,
    'forbidden' => 403,
    'not_found' => 404,
    'rate_limited' => 429,
    'payload_too_large' => 413,
    'not_configured' => 503,
    'idempotency_conflict' ||
    'duplicate_ref' ||
    'too_late' ||
    'not_ready' ||
    'invalid_transition' => 409,
    'invalid_input' || 'idempotency_key_required' => 400,
    _ => 422,
  };

  static Json _error(String code, String message) => {
    'error': {'code': code, 'message': message},
  };

  static Future<PartnerApp> _authenticate(Session s, String? header) async {
    final m = RegExp(
      r'^Bearer (rk_([a-z0-9]{8})_[A-Za-z0-9_-]{20,100})$',
    ).firstMatch(header?.trim() ?? '');
    if (m == null) {
      _fail('unauthorized', 'Send your Raysto partner key as a Bearer token.');
    }
    final app = await PartnerApp.db.findFirstRow(
      s,
      where: (t) => t.keyPrefix.equals(m.group(2)!),
    );
    if (app == null || !_same(app.keyHash, _hash(m.group(1)!))) {
      _fail('unauthorized', 'Unknown or rotated partner key.');
    }
    return app;
  }

  static void _verify(PartnerApp app, String? header, String body) {
    final m = RegExp(
      r'^t=(\d{1,12}),v1=([0-9a-f]{64})$',
    ).firstMatch(header?.trim() ?? '');
    if (m == null) {
      _fail(
        'signature_required',
        'Sign each request: X-Raysto-Signature: t=<unix seconds>,'
            'v1=<hex HMAC-SHA256 of "t.body" with your webhook secret>.',
      );
    }
    final t = int.parse(m.group(1)!);
    final now = _now().millisecondsSinceEpoch ~/ 1000;
    if ((now - t).abs() > tolerance.inSeconds) {
      _fail('stale_signature', 'The signature time is more than 5 minutes off.');
    }
    if (!_same(sign(webhookSecret(app), t, body), m.group(2)!)) {
      _fail('bad_signature', 'The signature does not match this request.');
    }
  }

  static String _ref(dynamic raw) {
    if (raw is! String || !RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(raw)) {
      _fail('invalid_input', 'A ref is 1–64 letters, digits, - or _.');
    }
    return raw;
  }

  /// A partner's work runs as the café's service identity, under the
  /// restaurant lock for writes, with a request key that marks it as theirs.
  static Future<Work> _work(
    Session s,
    PartnerApp app,
    String key,
    Transaction tx, {
    bool lock = true,
  }) async {
    final restaurant = await Restaurant.db.findById(
      s,
      app.restaurantId,
      transaction: tx,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (restaurant == null) _fail('not_found', 'Restaurant not found.');
    final policy = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(app.restaurantId),
      transaction: tx,
    );
    final actor = await AgentModule.serviceActor(s, app.restaurantId, tx: tx);
    return Work(
      s,
      tx,
      actor,
      PlatformCommand(
        requestKey: 'partner-${app.id}-$key',
        restaurantId: app.restaurantId,
        dataJson: '{}',
      ),
      restaurant,
      policy,
    );
  }

  static Future<void> _log(
    Session s,
    PartnerApp app,
    String type,
    String? ref,
    String status,
    int code,
    Json summary,
    String? key, {
    Transaction? tx,
  }) async {
    await PartnerEvent.db.insertRow(
      s,
      PartnerEvent(
        restaurantId: app.restaurantId,
        partnerAppId: app.id!,
        direction: 'in',
        type: type,
        ref: ref,
        status: status,
        attempts: 1,
        responseCode: code,
        payloadJson: jsonEncode(summary),
        idempotencyKey: key,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: tx,
    );
  }

  /// What the log keeps of a request: its shape, never names or addresses.
  static Json _summary(String type, Json d) => switch (type) {
    'orders.create' => {
      'fulfilledBy': d['fulfilledBy'] ?? 'restaurant',
      'lines': d['lines'] is List ? (d['lines'] as List).length : 0,
    },
    'orders.status' => {'status': d['status']},
    'orders.cancel' => {'reason': d['reason'] != null},
    _ => {},
  };

  /// Handles one request to `/api/partner/v1/<path>`; returns the HTTP status
  /// and body. Refusals are logged against the app once it is identified.
  static Future<(int, Json)> inbound(
    Session s, {
    required String method,
    required String path,
    required Map<String, String> headers,
    required String body,
  }) async {
    PartnerApp? app;
    var type = 'request';
    String? ref;
    final key = headers['idempotency-key'];
    try {
      final parts = path.split('/').where((p) => p.isNotEmpty).toList();
      type = switch ((method, parts.length, parts.firstOrNull, parts.length > 2 ? parts[2] : null)) {
        ('GET', 1, 'menu', _) => 'menu.read',
        ('POST', 1, 'orders', _) => 'orders.create',
        ('GET', 2, 'orders', _) => 'orders.read',
        ('POST', 3, 'orders', 'cancel') => 'orders.cancel',
        ('POST', 3, 'orders', 'status') => 'orders.status',
        _ => 'unknown',
      };
      app = await _authenticate(s, headers['authorization']);
      final current = app;
      if (!current.active) {
        _fail('forbidden', 'This partner app is switched off.');
      }
      await s.db.transaction(
        (tx) => _rate(s, 'partner:${current.id}', perMinute, tx),
      );
      _verify(current, headers['x-raysto-signature'], body);
      if (type == 'unknown') _fail('not_found', 'Unknown endpoint.');
      if (parts.length >= 2) ref = _ref(parts[1]);
      if (method == 'GET') {
        return await s.db.transaction((tx) async {
          final w = await _work(s, current, 'read-${_uuid()}', tx, lock: false);
          final out = type == 'menu.read'
              ? await _menu(w)
              : await _read(w, current, ref!);
          await _log(s, current, type, ref, 'ok', 200, const {}, null, tx: tx);
          return (200, out);
        });
      }
      if (key == null || !RegExp(r'^[A-Za-z0-9_.:-]{8,100}$').hasMatch(key)) {
        _fail(
          'idempotency_key_required',
          'Send an Idempotency-Key header (8–100 characters) with every POST.',
        );
      }
      final d = _json(body.isEmpty ? '{}' : body, maxBytes: maxBytes);
      final fingerprint = _hash('$method /$path\n$body');
      return await s.db.transaction((tx) async {
        final w = await _work(s, current, key, tx);
        final user = 'partner:${current.id}';
        final previous = await MutationReceipt.db.findFirstRow(
          s,
          where: (t) => t.userId.equals(user) & t.requestKey.equals(key),
          transaction: tx,
        );
        if (previous != null) {
          if (previous.requestHash != fingerprint) {
            _fail(
              'idempotency_conflict',
              'This Idempotency-Key was used for a different request.',
            );
          }
          final stored = _json(previous.resultJson);
          final status = stored['status'] as int;
          await _log(s, current, type, ref ?? _object(stored['body'])['ref'] as String?, 'replayed', status, _summary(type, d), key, tx: tx);
          return (status, {..._object(stored['body']), 'replayed': true});
        }
        final (status, out) = switch (type) {
          'orders.create' => await _create(w, current, d),
          'orders.cancel' => await _cancel(w, current, ref!, d),
          _ => await _status(w, current, ref!, d),
        };
        await MutationReceipt.db.insertRow(
          s,
          MutationReceipt(
            userId: user,
            requestKey: key,
            operation: 'partner.$type',
            requestHash: fingerprint,
            resultJson: jsonEncode({'status': status, 'body': out}),
            createdAt: _now(),
          ),
          transaction: tx,
        );
        await _log(
          s,
          current,
          type,
          ref ?? out['ref'] as String?,
          'accepted',
          status,
          _summary(type, d),
          key,
          tx: tx,
        );
        return (status, out);
      });
    } on DomainError catch (e) {
      final status = _httpStatus(e.code);
      final known = app;
      if (known != null) {
        try {
          await _log(s, known, type, ref, 'rejected', status, {
            'error': e.code,
          }, key);
        } catch (_) {
          // The refusal is still answered when the log cannot be written.
        }
      }
      return (status, _error(e.code, e.message));
    }
  }

  // ---- Endpoints ----------------------------------------------------------------

  static Future<Json> _menu(Work w) async {
    final settings = w.settings;
    final modes = (settings['modes'] as List?) ?? const [];
    return {
      'restaurant': {
        'id': w.tenant,
        'name': w.restaurant!.name,
        'currency': w.restaurant!.currency,
        'accepting':
            w.restaurant!.published &&
            w.policy?.suspended == false &&
            settings['paused'] != true,
        'restaurantDelivers': modes.contains('delivery'),
        'deliveryFeeMode': settings['deliveryFeeMode'] ?? 'flat',
      },
      'fulfilledBy': [if (modes.contains('delivery')) 'restaurant', 'partner'],
      'items': await PlatformQueries.sellable(w.s, w.tenant, tx: w.tx),
    };
  }

  static String customerId(int appId) => 'walk-in:partner:$appId';

  static String _public(String status) => switch (status) {
    'awaitingPayment' || 'submitted' => 'received',
    'accepted' || 'preparing' => 'accepted',
    'ready' => 'ready',
    'outForDelivery' => 'picked_up',
    'delivered' || 'completed' => 'delivered',
    'cancelled' || 'rejected' => 'cancelled',
    _ => status,
  };

  static Future<(DeliveryAssignment, PurchaseOrder, OrderContext)> _byRef(
    Work w,
    PartnerApp app,
    String ref,
  ) async {
    final a = await DeliveryAssignment.db.findFirstRow(
      w.s,
      where: (t) => t.partnerAppId.equals(app.id!) & t.partnerRef.equals(ref),
      transaction: w.tx,
    );
    if (a == null || a.restaurantId != w.tenant) {
      _fail('not_found', 'No order with this ref.');
    }
    final (o, ctx) = await OrderingModule._order(w, a.orderId);
    return (a, o, ctx);
  }

  static Future<Json> _view(
    Work w,
    DeliveryAssignment a,
    PurchaseOrder o,
    OrderContext ctx,
  ) async {
    final driver = a.driverId == null
        ? null
        : await Driver.db.findById(w.s, a.driverId!, transaction: w.tx);
    final open = !{'delivered', 'cancelled'}.contains(a.status);
    final ours = a.fulfilledBy != 'partner';
    return {
      'ref': a.partnerRef,
      'orderId': o.id,
      'number': ctx.orderNumber,
      'status': _public(o.status),
      'orderStatus': o.status,
      'deliveryStatus': a.status,
      'fulfilledBy': a.fulfilledBy ?? 'restaurant',
      'totalMinor': o.totalMinor,
      'deliveryFeeMinor': o.deliveryFeeMinor,
      'currency': o.currency,
      'settlement': 'externalPartner',
      'createdAt': o.createdAt.toIso8601String(),
      'pickedUpAt': a.pickedUpAt?.toIso8601String(),
      'deliveredAt': a.deliveredAt?.toIso8601String(),
      if (open && ours)
        'eta': DeliveryModule.estimate(w.settings, o, driver: driver),
      if (!ours) 'pickupCode': ctx.pickupCode,
      if (ours && open && w.settings['deliveryProof'] == 'code')
        'dropoffCode': DeliveryModule.dropoffCode(o),
      if (ours && driver != null)
        'driver': {
          'name': DeliveryModule.firstName(driver.name),
          'vehicle': driver.vehicle,
        },
    };
  }

  static Future<Json> _read(Work w, PartnerApp app, String ref) async {
    final (a, o, ctx) = await _byRef(w, app, ref);
    return _view(w, a, o, ctx);
  }

  /// `POST orders`: priced by the café's own rules (menu, stock, hours,
  /// zone and fee when the café delivers; no fee, zone or minimum when the
  /// partner's courier does), then created like an online order.
  static Future<(int, Json)> _create(Work w, PartnerApp app, Json d) async {
    _keys(d, {'ref', 'fulfilledBy', 'lines', 'address', 'customer', 'note'});
    final ref = _ref(d['ref']);
    final by = _str(
      d,
      'fulfilledBy',
      fallback: 'restaurant',
      choices: {'restaurant', 'partner'},
    );
    final taken = await DeliveryAssignment.db.findFirstRow(
      w.s,
      where: (t) => t.partnerAppId.equals(app.id!) & t.partnerRef.equals(ref),
      transaction: w.tx,
    );
    if (taken != null) {
      _fail('duplicate_ref', 'An order with this ref already exists.');
    }
    final customer = _object(d['customer'] ?? const <String, dynamic>{});
    _keys(customer, {'name'});
    final who = customer['name'] == null
        ? null
        : _str(customer, 'name', max: 60);
    final note = d['note'] == null ? null : _str(d, 'note', max: 500);
    await _accepting(w);
    if (d['address'] == null) {
      _fail('invalid_input', 'Send the delivery address with its coordinates.');
    }
    final at =
        DeliveryModule.point(CatalogueModule.address(_object(d['address']))) ??
        _fail('invalid_input', 'The address needs latitude and longitude.');
    var pricing = w;
    if (by == 'partner') {
      final base = w.settings;
      final patched = {
        ...base,
        'modes': {...(base['modes'] as List), 'delivery'}.toList(),
        'deliveryFeeMinor': 0,
        'deliveryFeeMode': 'flat',
        'deliveryMinimumMinor': 0,
        'deliveryZones': [
          {'latitude': at.lat, 'longitude': at.lng, 'radiusKm': 1},
        ],
      };
      pricing = Work(
        w.s,
        w.tx,
        w.actor,
        w.command,
        w.restaurant,
        w.policy!.copyWith(settingsJson: jsonEncode(patched)),
      );
    }
    final snapshot = await OrderingModule._price(pricing, {
      'fulfillment': 'delivery',
      'lines': d['lines'],
      'address': d['address'],
    });
    final details = {
      ...snapshot,
      'origin': 'partner',
      'partner': {
        'appId': app.id,
        'name': app.name,
        'ref': ref,
        'fulfilledBy': by,
        'simulator': app.simulator,
      },
      'partnerNote': ?note,
    };
    final s = w.s;
    final day = OrderingModule.serviceDay(w.settings, _now());
    final policy = w.policy!;
    if (policy.orderSeqDay != day) {
      final last = await OrderContext.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant) & t.serviceDay.equals(day),
        orderBy: (t) => t.orderNumber.desc(),
        transaction: w.tx,
      );
      policy.orderSeqDay = day;
      policy.orderSeq = last?.orderNumber ?? 0;
    }
    policy.orderSeq++;
    await RestaurantPolicy.db.updateRow(s, policy, transaction: w.tx);
    final items = (snapshot['lines'] as List).cast<Json>();
    final order = await PurchaseOrder.db.insertRow(
      s,
      PurchaseOrder(
        restaurantId: w.tenant,
        customerId: customerId(app.id!),
        requestKey: 'partner-$ref',
        requestHash: _hash(jsonEncode(details)),
        fulfillment: 'delivery',
        address: jsonEncode(snapshot['address']),
        lines: [
          for (final v in items)
            OrderLine(
              productId: v['productId'],
              name: v['name'],
              quantity: v['quantity'],
              unitPriceMinor: v['unitPriceMinor'],
            ),
        ],
        currency: snapshot['currency'],
        subtotalMinor: snapshot['subtotalMinor'],
        deliveryFeeMinor: snapshot['deliveryFeeMinor'],
        totalMinor: snapshot['totalMinor'],
        status: 'submitted',
        paymentStatus: 'externalPartner',
        version: 1,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: w.tx,
    );
    final ctx = await OrderContext.db.insertRow(
      s,
      OrderContext(
        restaurantId: w.tenant,
        orderId: order.id!,
        detailsJson: jsonEncode(details),
        // Settled outside PayPal, so the kitchen never waits for a payment.
        paymentTiming: 'after',
        cancellationRequested: false,
        stockReleased: false,
        origin: 'partner',
        customerLabel: who == null ? app.name : '$who · ${app.name}',
        serviceDay: day,
        orderNumber: policy.orderSeq,
        // The partner's courier shows this code at the counter.
        pickupCode: by == 'partner'
            ? await OrderingModule._pickupCode(w, day)
            : null,
        createdAt: _now(),
      ),
      transaction: w.tx,
    );
    for (final line in items) {
      final def = (await MenuDefinition.db.findFirstRow(
        s,
        where: (t) => t.productId.equals(line['productId']),
        transaction: w.tx,
      ))!;
      if (def.stockRemaining != null) {
        def.stockRemaining = def.stockRemaining! - (line['quantity'] as int);
        await MenuDefinition.db.updateRow(s, def, transaction: w.tx);
      }
      await KitchenProgress.db.insertRow(
        s,
        KitchenProgress(
          restaurantId: w.tenant,
          orderId: order.id!,
          lineKey: line['lineKey'],
          quantity: line['quantity'],
          completedQuantity: 0,
          version: 1,
        ),
        transaction: w.tx,
      );
    }
    for (final raw in snapshot['charges'] as List) {
      final charge = _object(raw);
      await BillCharge.db.insertRow(
        s,
        BillCharge(
          restaurantId: w.tenant,
          orderId: order.id!,
          lineKey: charge['lineKey'],
          kind: charge['kind'],
          amountMinor: charge['amountMinor'],
          creditedMinor: 0,
          settledMinor: 0,
          reservedMinor: 0,
          foodNetMinor: charge['foodNetMinor'],
          version: 1,
        ),
        transaction: w.tx,
      );
    }
    final eta = DeliveryModule.estimate(w.settings, order);
    final a = await DeliveryAssignment.db.insertRow(
      s,
      DeliveryAssignment(
        restaurantId: w.tenant,
        orderId: order.id!,
        status: 'unassigned',
        issueJson: '{}',
        locationConsent: false,
        version: 1,
        updatedAt: _now(),
        partnerAppId: app.id,
        partnerRef: ref,
        fulfilledBy: by,
        feeMinor: order.deliveryFeeMinor,
        distanceMeters: eta['distanceMeters'] as int?,
      ),
      transaction: w.tx,
    );
    await w.audit('order.submitted', 'order', order.id, {
      'origin': 'partner',
      'partnerAppId': app.id,
    });
    await OrderingModule.alertTeam(w, order);
    return (201, await _view(w, a, order, ctx));
  }

  /// `POST orders/{ref}/cancel`, until the kitchen has finished the order.
  static Future<(int, Json)> _cancel(
    Work w,
    PartnerApp app,
    String ref,
    Json d,
  ) async {
    _keys(d, {'reason'});
    final reason = d['reason'] == null
        ? 'Cancelled by the partner app.'
        : _str(d, 'reason', max: 300);
    final (a, o, ctx) = await _byRef(w, app, ref);
    if (!{'cancelled', 'rejected'}.contains(o.status)) {
      if (!{'submitted', 'accepted', 'preparing'}.contains(o.status)) {
        _fail('too_late', 'The order is ready or on its way; call the café.');
      }
      await OrderingModule._cancel(
        w,
        o,
        ctx,
        'cancelled',
        '${app.name}: $reason',
      );
    }
    final fresh = (await DeliveryAssignment.db.findById(
      w.s,
      a.id!,
      transaction: w.tx,
    ))!;
    return (200, await _view(w, fresh, o, ctx));
  }

  /// `POST orders/{ref}/status`: the partner's courier picked the order up
  /// or handed it over. Only for orders the partner delivers.
  static Future<(int, Json)> _status(
    Work w,
    PartnerApp app,
    String ref,
    Json d,
  ) async {
    _keys(d, {'status', 'courier'});
    final next = _str(d, 'status', choices: {'picked_up', 'delivered'});
    final (a, o, ctx) = await _byRef(w, app, ref);
    if (a.fulfilledBy != 'partner') {
      _fail(
        'invalid_transition',
        'The café delivers this order, so its status comes from the café.',
      );
    }
    if (next == 'picked_up' && a.status == 'unassigned') {
      if (o.status != 'ready') {
        _fail('not_ready', 'The order is not ready yet.');
      }
      final courier = _object(d['courier'] ?? const <String, dynamic>{});
      _keys(courier, {'name', 'vehicle'});
      final name = courier['name'] == null
          ? 'Courier'
          : _str(courier, 'name', max: 60);
      final vehicle = _str(
        courier,
        'vehicle',
        fallback: 'bike',
        choices: DeliveryModule.speeds.keys.toSet(),
      );
      final driver =
          await Driver.db.findFirstRow(
            w.s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                t.partnerAppId.equals(app.id!) &
                t.name.equals(name),
            transaction: w.tx,
          ) ??
          await Driver.db.insertRow(
            w.s,
            Driver(
              restaurantId: w.tenant,
              kind: 'partner',
              partnerAppId: app.id,
              name: name,
              vehicle: vehicle,
              status: 'busy',
              active: true,
              version: 1,
              createdAt: _now(),
              updatedAt: _now(),
            ),
            transaction: w.tx,
          );
      a
        ..driverId = driver.id
        ..status = 'outForDelivery'
        ..pickedUpAt = _now()
        ..version += 1
        ..updatedAt = _now();
      await DeliveryAssignment.db.updateRow(w.s, a, transaction: w.tx);
      o.status = 'outForDelivery';
      await OrderingModule._changed(w, o, 'delivery.collected');
      await w.audit('delivery.collected', 'delivery', a.id, {'by': 'partner'});
    } else if (next == 'delivered' && a.status == 'outForDelivery') {
      a.proofKind = 'partner';
      await DeliveryModule.finish(w, a, o);
    } else if (!(next == 'picked_up' && a.status == 'outForDelivery') &&
        !(next == 'delivered' && a.status == 'delivered')) {
      _fail(
        'invalid_transition',
        next == 'delivered'
            ? 'Report picked_up first.'
            : 'This order is ${_public(o.status)}.',
      );
    }
    return (200, await _view(w, a, o, ctx));
  }
}
