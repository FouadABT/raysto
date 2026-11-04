part of 'platform.dart';

/// A position: latitude and longitude in degrees.
typedef DeliveryPoint = ({double lat, double lng});

/// Drivers, offers, ETA, proof and pings (plan section 4). Owner: stream S2,
/// which also owns the delivery block of ordering.dart.
///
/// - A driver carries orders: a courier with a login (`userId`), a driver the
///   café dispatches by phone (no login), or a partner app's courier
///   (`kind: partner`, created when the partner reports a pickup).
/// - An offer gives one driver 90 seconds to accept one job. The first accept
///   wins: every command holds the restaurant lock, so two accepts can never
///   both see the job unassigned.
/// - Raysto has no routing engine. Every distance is the straight line × 1.3
///   and every ETA is labelled an estimate.
class DeliveryModule {
  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  /// `delivery.assign`, `delivery.transition` and `delivery.location` stay in
  /// ordering.dart, registered there.
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'driver.save': saveDriver,
    'driver.availability': availability,
    'delivery.offer': offer,
    'delivery.respond': respond,
    'delivery.proof': proof,
    'dispatch.suggest': DispatchAgent.suggest,
  };

  /// Audit kinds this module listens to (AgentModule.triggers, 0.16 anchor).
  static Future<void> onAccepted(Work w, String type, int? id, Json d) =>
      _orderEvent(w, type, id, 'order.accepted');
  static Future<void> onReady(Work w, String type, int? id, Json d) =>
      _orderEvent(w, type, id, 'order.ready');
  static Future<void> onCancelled(Work w, String type, int? id, Json d) =>
      _orderEvent(w, type, id, 'order.cancelled');
  static Future<void> onCollected(Work w, String type, int? id, Json d) =>
      _deliveryEvent(w, type, id, 'order.picked_up');
  static Future<void> onDelivered(Work w, String type, int? id, Json d) =>
      _deliveryEvent(w, type, id, 'order.delivered');

  static const offerSeconds = 90;
  static const roadFactor = 1.3;

  /// Typical city speeds in km/h, by vehicle.
  static const speeds = <String, double>{
    'foot': 4.5,
    'bike': 15,
    'scooter': 22,
    'car': 25,
  };

  /// Jobs a driver is carrying.
  static const live = {'assigned', 'collected', 'outForDelivery', 'issue'};

  // ---- Geometry, fees and the estimate ------------------------------------

  /// The café's own position: the centre of its first delivery zone. Venue
  /// coordinates are not stored anywhere else.
  static DeliveryPoint? venue(Json settings) {
    final zones = settings['deliveryZones'];
    if (zones is! List || zones.isEmpty || zones.first is! Map) return null;
    return point(Map<String, dynamic>.from(zones.first as Map));
  }

  static DeliveryPoint? point(Json? at) {
    final lat = at?['latitude'], lng = at?['longitude'];
    if (lat is! num || lng is! num || !lat.isFinite || !lng.isFinite) {
      return null;
    }
    return (lat: lat.toDouble(), lng: lng.toDouble());
  }

  static Json? coordinates(DeliveryPoint? p) =>
      p == null ? null : {'latitude': p.lat, 'longitude': p.lng};

  /// Where an order goes: its address, when that has coordinates.
  static DeliveryPoint? dropoff(PurchaseOrder o) {
    if (o.address == null) return null;
    try {
      return point(_json(o.address!));
    } on DomainError {
      return null;
    }
  }

  /// Straight-line metres between two points (haversine).
  static double meters(DeliveryPoint a, DeliveryPoint b) {
    double rad(double d) => d * pi / 180;
    final dLat = rad(b.lat - a.lat), dLng = rad(b.lng - a.lng);
    final num h =
        pow(sin(dLat / 2), 2) +
        cos(rad(a.lat)) * cos(rad(b.lat)) * pow(sin(dLng / 2), 2);
    return 2 * 6371000 * atan2(sqrt(h), sqrt(max(0, 1 - h)));
  }

  /// The road distance estimate: the straight line × 1.3.
  static int road(DeliveryPoint a, DeliveryPoint b) => (meters(a, b) * roadFactor).round();

  static int _setting(Json settings, String key, [int fallback = 0]) =>
      (settings[key] as num?)?.toInt() ?? fallback;

  /// The delivery fee for [address]: flat, or base + per km of the road
  /// estimate, capped at the maximum when one is set. Without coordinates
  /// (or a delivery zone to measure from) the flat fee applies.
  static int fee(Json settings, Json? address) {
    final flat = _setting(settings, 'deliveryFeeMinor');
    if (settings['deliveryFeeMode'] != 'distance') return flat;
    final from = venue(settings), to = point(address);
    if (from == null || to == null) return flat;
    final km = road(from, to) / 1000;
    final value =
        _setting(settings, 'deliveryFeeBaseMinor') +
        (km * _setting(settings, 'deliveryFeePerKmMinor')).round();
    final cap = _setting(settings, 'deliveryFeeMaxMinor');
    return cap > 0 ? min(value, cap) : value;
  }

  /// When the order should reach the door: the kitchen time left plus the
  /// ride from [from] (the driver's last position once collected, else the
  /// café). Always labelled an estimate.
  static Json estimate(
    Json settings,
    PurchaseOrder o, {
    Driver? driver,
    DeliveryPoint? from,
  }) {
    final to = dropoff(o);
    final start = from ?? venue(settings);
    final vehicle = driver?.vehicle ?? 'bike';
    final speed = speeds[vehicle] ?? 15;
    var prep = 0;
    if ({
      'awaitingPayment',
      'submitted',
      'accepted',
      'preparing',
    }.contains(o.status)) {
      prep = max(
        0,
        _setting(settings, 'preparationMinutes', 20) -
            _now().difference(o.createdAt).inMinutes,
      );
    }
    final distance = start == null || to == null ? null : road(start, to);
    final ride = distance == null ? null : (distance / 1000 / speed * 60).ceil();
    return {
      'estimate': true,
      'prepMinutes': prep,
      'rideMinutes': ride,
      'minutes': ride == null ? null : prep + ride,
      'distanceMeters': distance,
      'at': ride == null
          ? null
          : _now().add(Duration(minutes: prep + ride)).toIso8601String(),
      'vehicle': vehicle,
      'basis':
          'Straight line × 1.3 at ${speed.round()} km/h'
          '${prep > 0 ? ', after about $prep min in the kitchen' : ''}.',
    };
  }

  /// The customer's 4-digit handover code. Derived from the order rather
  /// than stored: only the customer's own tracking shows it, and the courier
  /// never sees it.
  static String dropoffCode(PurchaseOrder o) {
    final h = _hash('dropoff:${o.id}:${o.requestHash}');
    return (int.parse(h.substring(0, 8), radix: 16) % 10000)
        .toString()
        .padLeft(4, '0');
  }

  static String _codeHash(DeliveryAssignment a, String code) =>
      _hash('dropoff-check:${a.id}:$code');

  // ---- Lookups --------------------------------------------------------------

  static Future<Driver> _driver(Work w, int id) async {
    final d = await Driver.db.findById(w.s, id, transaction: w.tx);
    if (d == null || d.restaurantId != w.tenant) {
      _fail('not_found', 'Driver not found.');
    }
    return d;
  }

  static Future<DeliveryAssignment> _assignment(Work w, int id) async {
    final a = await DeliveryAssignment.db.findById(w.s, id, transaction: w.tx);
    if (a == null || a.restaurantId != w.tenant) {
      _fail('not_found', 'Delivery not found.');
    }
    return a;
  }

  static Future<Driver?> _mine(Work w) => Driver.db.findFirstRow(
    w.s,
    where: (t) =>
        t.restaurantId.equals(w.tenant) &
        t.userId.equals(w.user) &
        t.kind.equals('staff'),
    transaction: w.tx,
  );

  static Future<int> _load(Session s, int driverId, Transaction? tx) =>
      DeliveryAssignment.db.count(
        s,
        where: (t) => t.driverId.equals(driverId) & t.status.inSet(live),
        transaction: tx,
      );

  /// The driver card of a courier with a login, made on first use with the
  /// name on their profile.
  static Future<Driver> driverFor(Work w, String userId) async {
    final existing = await Driver.db.findFirstRow(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.userId.equals(userId) &
          t.kind.equals('staff'),
      transaction: w.tx,
    );
    if (existing != null) return existing;
    final profile = await ActorProfile.db.findFirstRow(
      w.s,
      where: (t) => t.userId.equals(userId),
      transaction: w.tx,
    );
    final shown = profile == null
        ? null
        : _json(profile.dataJson)['displayName'] as String?;
    final row = await Driver.db.insertRow(
      w.s,
      Driver(
        restaurantId: w.tenant,
        kind: 'staff',
        userId: userId,
        name: (shown == null || shown.trim().isEmpty) ? 'Courier' : shown.trim(),
        vehicle: 'bike',
        status: 'offline',
        active: true,
        version: 1,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: w.tx,
    );
    await w.audit('driver.created', 'driver', row.id);
    return row;
  }

  /// A driver's last consented position on a live job, if under 15 minutes old.
  static Future<DeliveryPing?> lastPing(
    Session s,
    Iterable<int> assignmentIds, {
    Transaction? tx,
  }) async {
    final ids = assignmentIds.toSet();
    if (ids.isEmpty) return null;
    return DeliveryPing.db.findFirstRow(
      s,
      where: (t) =>
          t.assignmentId.inSet(ids) &
          (t.at > _now().subtract(const Duration(minutes: 15))),
      orderBy: (t) => t.at.desc(),
      transaction: tx,
    );
  }

  /// A driver with no job left is available again.
  static Future<void> release(Work w, int? driverId) async {
    if (driverId == null) return;
    final d = await Driver.db.findById(w.s, driverId, transaction: w.tx);
    if (d == null || d.kind != 'staff' || d.status != 'busy') return;
    if (await _load(w.s, d.id!, w.tx) > 0) return;
    d
      ..status = 'available'
      ..version += 1
      ..updatedAt = _now();
    await Driver.db.updateRow(w.s, d, transaction: w.tx);
  }

  static Future<void> _withdraw(Work w, int assignmentId, {int? except}) =>
      DeliveryOffer.db.updateWhere(
        w.s,
        columnValues: (t) => [t.state('withdrawn'), t.respondedAt(_now())],
        where: (t) =>
            t.assignmentId.equals(assignmentId) &
            t.state.equals('offered') &
            (except == null ? Constant.bool(true) : t.id.notEquals(except)),
        transaction: w.tx,
      );

  // ---- Drivers ----------------------------------------------------------------

  static String? _email(Json d, String k) {
    if (d[k] == null) return null;
    final value = _str(d, k, max: 254).toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      _fail('invalid_input', 'Invalid $k.');
    }
    return value;
  }

  /// A manager adds or edits a driver card. A card may link a courier login;
  /// without one, the café dispatches that driver by phone.
  static Future<Json> saveDriver(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'driver.save',
    (w, d) async {
      _keys(d, {
        'name',
        'vehicle',
        'userId',
        'phoneLast4',
        'payoutEmail',
        'active',
      });
      final name = _str(d, 'name', max: 80);
      final vehicle = _str(
        d,
        'vehicle',
        fallback: 'bike',
        choices: speeds.keys.toSet(),
      );
      String? userId;
      if (d['userId'] != null) {
        userId = _str(d, 'userId', max: 100);
        await _role(s, userId, w.tenant, {'courier'}, tx: w.tx);
        final taken = await Driver.db.findFirstRow(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              t.userId.equals(userId) &
              t.kind.equals('staff'),
          transaction: w.tx,
        );
        if (taken != null && taken.id != c.resourceId) {
          _fail('driver_exists', 'This courier already has a driver card.');
        }
      }
      String? phone;
      if (d['phoneLast4'] != null) {
        phone = _str(d, 'phoneLast4', max: 4);
        if (!RegExp(r'^\d{4}$').hasMatch(phone)) {
          _fail('invalid_input', 'Give the last four digits of the phone.');
        }
      }
      final email = _email(d, 'payoutEmail');
      final active = _bool(d, 'active', fallback: true);
      if (c.resourceId == null) {
        final row = await Driver.db.insertRow(
          s,
          Driver(
            restaurantId: w.tenant,
            kind: 'staff',
            userId: userId,
            name: name,
            phoneLast4: phone,
            vehicle: vehicle,
            payoutEmail: email,
            status: 'offline',
            active: active,
            version: 1,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.audit('driver.created', 'driver', row.id);
        return {'id': row.id, 'version': row.version, 'status': row.status};
      }
      final row = await _driver(w, c.resourceId!);
      if (row.kind != 'staff') {
        _fail('invalid_input', 'Partner couriers are managed by their app.');
      }
      _version(row.version, c.expectedVersion);
      if (!active && await _load(s, row.id!, w.tx) > 0) {
        _fail('active_job', 'Reassign this driver\'s jobs first.');
      }
      row
        ..name = name
        ..vehicle = vehicle
        ..userId = userId
        ..phoneLast4 = phone
        ..payoutEmail = email
        ..active = active
        ..status = active ? row.status : 'offline'
        ..version += 1
        ..updatedAt = _now();
      await Driver.db.updateRow(s, row, transaction: w.tx);
      if (!active) {
        await DeliveryOffer.db.updateWhere(
          s,
          columnValues: (t) => [t.state('withdrawn'), t.respondedAt(_now())],
          where: (t) => t.driverId.equals(row.id!) & t.state.equals('offered'),
          transaction: w.tx,
        );
      }
      await w.audit('driver.updated', 'driver', row.id, {'active': active});
      return {'id': row.id, 'version': row.version, 'status': row.status};
    },
    roles: _managers,
  );

  /// A courier says they can take jobs (or stop), or a dispatcher sets it for
  /// a driver. A driver on a job stays busy until it is delivered.
  static Future<Json> availability(Session s, PlatformCommand c) =>
      _mutate(s, c, 'driver.availability', (w, d) async {
        _keys(d, {'status', 'vehicle'});
        final status = _str(d, 'status', choices: {'available', 'offline'});
        final m = await w.role(_staff);
        Driver row;
        if (c.resourceId != null) {
          row = await _driver(w, c.resourceId!);
          if (row.userId != w.user && !_holds(m, 'dispatch')) {
            _fail('forbidden', 'This action is not permitted.');
          }
        } else {
          if (m.role != 'courier') {
            _fail('invalid_input', 'resourceId is required.');
          }
          row = await _mine(w) ?? await driverFor(w, w.user);
        }
        if (row.kind != 'staff' || !row.active) {
          _fail('invalid_transition', 'This driver card is switched off.');
        }
        if (d['vehicle'] != null) {
          row.vehicle = _str(d, 'vehicle', choices: speeds.keys.toSet());
        }
        final load = await _load(s, row.id!, w.tx);
        row
          ..status = status == 'offline'
              ? 'offline'
              : load > 0
              ? 'busy'
              : 'available'
          ..lastSeenAt = _now()
          ..version += 1
          ..updatedAt = _now();
        await Driver.db.updateRow(s, row, transaction: w.tx);
        if (status == 'offline') {
          await DeliveryOffer.db.updateWhere(
            s,
            columnValues: (t) => [t.state('withdrawn'), t.respondedAt(_now())],
            where: (t) =>
                t.driverId.equals(row.id!) & t.state.equals('offered'),
            transaction: w.tx,
          );
        }
        await w.audit('driver.availability', 'driver', row.id, {
          'status': row.status,
        });
        return {
          'id': row.id,
          'status': row.status,
          'version': row.version,
          'activeJobs': load,
        };
      });

  // ---- Offers ---------------------------------------------------------------

  /// A dispatcher (or the AI dispatcher, after approval) offers a job to a
  /// driver for 90 seconds. An earlier open offer on the job is withdrawn.
  static Future<Json> offer(Session s, PlatformCommand c) =>
      _mutate(s, c, 'delivery.offer', (w, d) async {
        _keys(d, {'driverId'});
        await _capable(w, 'dispatch');
        final a = await _assignment(w, _id(c));
        if (c.expectedVersion != null) _version(a.version, c.expectedVersion);
        final driver = await _driver(w, _int(d, 'driverId', min: 1));
        return sendOffer(w, a, driver, by: 'person');
      }, roles: _staff);

  /// Shared by the command and the AI dispatcher's own path.
  static Future<Json> sendOffer(
    Work w,
    DeliveryAssignment a,
    Driver driver, {
    required String by,
  }) async {
    if (a.fulfilledBy == 'partner') {
      _fail('invalid_transition', 'The partner app delivers this order.');
    }
    if (a.status != 'unassigned') {
      _fail('invalid_transition', 'This job already has a driver.');
    }
    final (o, ctx) = await OrderingModule._order(w, a.orderId);
    if (!{'submitted', 'accepted', 'preparing', 'ready'}.contains(o.status)) {
      _fail('invalid_transition', 'This order cannot be dispatched now.');
    }
    if (driver.kind != 'staff' || !driver.active || driver.status == 'offline') {
      _fail('driver_unavailable', '${driver.name} is not taking jobs now.');
    }
    final ranked = (await DispatchAgent.rank(w, a, o)).firstWhere(
      (r) => r['driverId'] == driver.id,
      orElse: () => <String, dynamic>{'score': 0.0, 'reasons': <String>[]},
    );
    await _withdraw(w, a.id!);
    final row = await DeliveryOffer.db.insertRow(
      w.s,
      DeliveryOffer(
        restaurantId: w.tenant,
        assignmentId: a.id!,
        driverId: driver.id!,
        state: 'offered',
        expiresAt: _now().add(const Duration(seconds: offerSeconds)),
        score: (ranked['score'] as num).toDouble(),
        reasonJson: jsonEncode({...ranked, 'by': by}),
        createdAt: _now(),
      ),
      transaction: w.tx,
    );
    if (driver.userId != null) {
      await w.notify(driver.userId!, 'delivery.offer', {
        'deliveryId': a.id,
        'offerId': row.id,
        'orderId': o.id,
      }, 'delivery-offer:${row.id}');
    }
    await w.audit('delivery.offered', 'delivery', a.id, {
      'offerId': row.id,
      'driverId': driver.id,
      'by': by,
    });
    return {
      'offerId': row.id,
      'assignmentId': a.id,
      'driverId': driver.id,
      'driverName': driver.name,
      'number': ctx.orderNumber,
      'expiresAt': row.expiresAt.toIso8601String(),
      'score': row.score,
      'hasLogin': driver.userId != null,
    };
  }

  /// The driver accepts or declines; a dispatcher withdraws an offer (the
  /// console's Undo) or records the answer of a driver without the app.
  static Future<Json> respond(Session s, PlatformCommand c) =>
      _mutate(s, c, 'delivery.respond', (w, d) async {
        _keys(d, {'answer'});
        final answer = _str(
          d,
          'answer',
          choices: {'accept', 'decline', 'withdraw'},
        );
        final offer = await DeliveryOffer.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (offer == null || offer.restaurantId != w.tenant) {
          _fail('not_found', 'Offer not found.');
        }
        final driver = await _driver(w, offer.driverId);
        final m = await w.role(_staff);
        final own = driver.userId != null && driver.userId == w.user;
        if (answer == 'withdraw' || !own) {
          if (!_holds(m, 'dispatch')) _fail('not_found', 'Offer not found.');
          if (answer != 'withdraw' && driver.userId != null) {
            _fail('forbidden', 'Only ${driver.name} can answer this offer.');
          }
        }
        Json closed(String state) => {
          'offerId': offer.id,
          'state': state,
          'assignmentId': offer.assignmentId,
        };
        if (offer.state != 'offered') return closed(offer.state);
        offer.respondedAt = _now();
        if (answer != 'withdraw' && !offer.expiresAt.isAfter(_now())) {
          offer.state = 'expired';
          await DeliveryOffer.db.updateRow(s, offer, transaction: w.tx);
          return closed('expired');
        }
        final a = await _assignment(w, offer.assignmentId);
        if (answer == 'withdraw' || answer == 'decline') {
          offer.state = answer == 'withdraw' ? 'withdrawn' : 'declined';
          await DeliveryOffer.db.updateRow(s, offer, transaction: w.tx);
          await w.audit(
            answer == 'withdraw'
                ? 'delivery.offer_withdrawn'
                : 'delivery.declined',
            'delivery',
            a.id,
            {'offerId': offer.id, 'driverId': driver.id},
          );
          if (answer == 'withdraw' && driver.userId != null) {
            await w.notify(driver.userId!, 'delivery.offer_withdrawn', {
              'deliveryId': a.id,
              'offerId': offer.id,
            }, 'delivery-offer-withdrawn:${offer.id}');
          }
          if (answer == 'decline' && w.settings['dispatchAuto'] == true) {
            await w.job('dispatch.auto', 'dispatch-auto:${a.id}:${offer.id}', {
              'assignmentId': a.id,
            });
          }
          return closed(offer.state);
        }
        // Accept: the first accept wins.
        if (a.status != 'unassigned') {
          offer.state = 'withdrawn';
          await DeliveryOffer.db.updateRow(s, offer, transaction: w.tx);
          return closed('taken');
        }
        if (!driver.active || driver.status == 'offline') {
          _fail('driver_unavailable', 'Go available before accepting a job.');
        }
        final (o, _) = await OrderingModule._order(w, a.orderId);
        if ({'cancelled', 'rejected'}.contains(o.status)) {
          offer.state = 'withdrawn';
          await DeliveryOffer.db.updateRow(s, offer, transaction: w.tx);
          return closed('cancelled');
        }
        offer.state = 'accepted';
        await DeliveryOffer.db.updateRow(s, offer, transaction: w.tx);
        await assign(w, a, o, driver);
        return {
          ...closed('accepted'),
          'version': a.version,
          'etaAt': a.etaAt?.toIso8601String(),
        };
      });

  /// Gives a job to a driver: shared by an accepted offer and `delivery.assign`.
  static Future<void> assign(
    Work w,
    DeliveryAssignment a,
    PurchaseOrder o,
    Driver driver,
  ) async {
    final eta = estimate(w.settings, o, driver: driver);
    a
      ..driverId = driver.id
      ..courierId = driver.userId
      ..status = 'assigned'
      ..etaAt = eta['at'] == null ? null : DateTime.parse(eta['at'] as String)
      ..distanceMeters = eta['distanceMeters'] as int?
      ..feeMinor = o.deliveryFeeMinor
      ..codeHash = _codeHash(a, dropoffCode(o))
      ..version += 1
      ..updatedAt = _now();
    await DeliveryAssignment.db.updateRow(w.s, a, transaction: w.tx);
    driver
      ..status = 'busy'
      ..lastSeenAt = _now()
      ..version += 1
      ..updatedAt = _now();
    await Driver.db.updateRow(w.s, driver, transaction: w.tx);
    await _withdraw(w, a.id!);
    if (driver.userId != null) {
      await w.notify(driver.userId!, 'delivery.assigned', {
        'deliveryId': a.id,
        'orderId': o.id,
      }, 'delivery:${a.id}:${a.version}');
    }
    if (!OrderingModule.isWalkIn(o.customerId)) {
      await w.notify(o.customerId, 'delivery.assigned', {
        'orderId': o.id,
      }, 'order:${o.id}:driver:${a.version}');
    }
    await w.audit('delivery.assigned', 'delivery', a.id, {
      'driverId': driver.id,
    });
  }

  // ---- Positions, proof and the end of a job ---------------------------------

  /// One consented position: kept as a ping for the map (deleted on delivery
  /// or after two hours) and, for a partner's order, sent to its webhook at
  /// most every 30 seconds.
  static Future<void> ping(
    Work w,
    DeliveryAssignment a,
    double lat,
    double lng,
    double? accuracy,
  ) async {
    await DeliveryPing.db.insertRow(
      w.s,
      DeliveryPing(
        restaurantId: w.tenant,
        assignmentId: a.id!,
        lat: lat,
        lng: lng,
        accuracy: accuracy,
        at: _now(),
      ),
      transaction: w.tx,
    );
    if (a.driverId != null) {
      final d = await Driver.db.findById(w.s, a.driverId!, transaction: w.tx);
      if (d != null) {
        d.lastSeenAt = _now();
        await Driver.db.updateRow(w.s, d, transaction: w.tx);
      }
    }
    if (a.partnerAppId != null && a.fulfilledBy != 'partner') {
      final last = await PartnerEvent.db.findFirstRow(
        w.s,
        where: (t) =>
            t.partnerAppId.equals(a.partnerAppId!) &
            t.type.equals('driver.location') &
            t.ref.equals(a.partnerRef),
        orderBy: (t) => t.id.desc(),
        transaction: w.tx,
      );
      if (last == null ||
          last.createdAt.isBefore(
            _now().subtract(const Duration(seconds: 30)),
          )) {
        await PartnerModule.emit(w, a.partnerAppId!, 'driver.location', a.partnerRef, {
          'ref': a.partnerRef,
          'latitude': lat,
          'longitude': lng,
          'at': _now().toIso8601String(),
        });
      }
    }
  }

  /// The courier confirms the handover: the customer's code, a photo, or
  /// (when the café asks for neither) nothing. A manager may confirm without
  /// proof. A wrong code is counted and answered, not thrown, so the count
  /// survives; five wrong codes lock the job for a manager.
  static Future<Json> proof(Session s, PlatformCommand c) =>
      _mutate(s, c, 'delivery.proof', (w, d) async {
        _keys(d, {'code', 'mediaId', 'override'});
        final a = await _assignment(w, _id(c));
        _version(a.version, c.expectedVersion);
        final m = await w.role({..._managers, 'courier'});
        final manager = _managers.contains(m.role);
        if (!manager && a.courierId != w.user) {
          _fail('not_found', 'Delivery not found.');
        }
        if (a.fulfilledBy == 'partner') {
          _fail('invalid_transition', 'The partner app reports this delivery.');
        }
        if (a.status != 'outForDelivery') {
          _fail('invalid_transition', 'Mark the order out for delivery first.');
        }
        final (o, _) = await OrderingModule._order(w, a.orderId);
        final mode = (w.settings['deliveryProof'] as String?) ?? 'none';
        String? kind;
        if (d['code'] != null) {
          final given = _str(d, 'code', max: 8);
          final misses = await AuditRecord.db.count(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                t.kind.equals('delivery.code_mismatch') &
                t.entityType.equals('delivery') &
                t.entityId.equals(a.id!),
            transaction: w.tx,
          );
          if (misses >= 5) {
            _fail(
              'code_locked',
              'Too many wrong codes. Ask a manager to confirm this delivery.',
            );
          }
          if (_codeHash(a, given) !=
              (a.codeHash ?? _codeHash(a, dropoffCode(o)))) {
            await w.audit('delivery.code_mismatch', 'delivery', a.id);
            return {
              'delivered': false,
              'error': 'code_mismatch',
              'attemptsLeft': 4 - misses,
              'version': a.version,
            };
          }
          kind = 'code';
        }
        if (d['mediaId'] != null) {
          final media = await MediaAsset.db.findById(
            s,
            _int(d, 'mediaId', min: 1),
            transaction: w.tx,
          );
          if (media == null ||
              media.restaurantId != w.tenant ||
              media.purpose != 'deliveryProof' ||
              (media.userId != w.user && !manager) ||
              !{'quarantine', 'approved'}.contains(media.status)) {
            _fail('invalid_input', 'Upload the delivery photo first.');
          }
          a.proofMediaId = media.id;
          kind ??= 'photo';
        }
        final override = _bool(d, 'override');
        if (override && !manager) {
          _fail('forbidden', 'Only a manager can confirm without proof.');
        }
        final enough = switch (mode) {
          'code' => kind == 'code',
          'photo' => kind != null,
          _ => true,
        };
        if (!enough && !override) {
          _fail(
            'proof_required',
            mode == 'code'
                ? 'Ask the customer for their 4-digit code.'
                : 'Take a photo of the order at the door.',
          );
        }
        a.proofKind = kind ?? (override ? 'manager' : 'none');
        await finish(w, a, o);
        return {
          'delivered': true,
          'status': a.status,
          'version': a.version,
          'proofKind': a.proofKind,
        };
      });

  /// The end of a job: delivered, positions forgotten, the driver free.
  static Future<void> finish(
    Work w,
    DeliveryAssignment a,
    PurchaseOrder o,
  ) async {
    a
      ..status = 'delivered'
      ..deliveredAt = _now()
      ..locationJson = null
      ..locationExpiresAt = null
      ..locationConsent = false
      ..version += 1
      ..updatedAt = _now();
    await DeliveryAssignment.db.updateRow(w.s, a, transaction: w.tx);
    o.status = 'delivered';
    await OrderingModule._changed(w, o, 'delivery.delivered');
    await DeliveryPing.db.deleteWhere(
      w.s,
      where: (t) => t.assignmentId.equals(a.id!),
      transaction: w.tx,
    );
    await release(w, a.driverId);
    await w.audit('delivery.delivered', 'delivery', a.id, {
      'proofKind': a.proofKind,
    });
  }

  // ---- Hooks ------------------------------------------------------------------

  /// Order events: tell the partner app whose order it is, queue the
  /// automatic dispatcher, and free the driver of a cancelled order.
  static Future<void> _orderEvent(
    Work w,
    String type,
    int? id,
    String event,
  ) async {
    if (type != 'order' || id == null) return;
    final a = await DeliveryAssignment.db.findFirstRow(
      w.s,
      where: (t) => t.orderId.equals(id),
      transaction: w.tx,
    );
    if (a == null) return;
    if (event == 'order.cancelled') {
      await _withdraw(w, a.id!);
      await DeliveryPing.db.deleteWhere(
        w.s,
        where: (t) => t.assignmentId.equals(a.id!),
        transaction: w.tx,
      );
      await release(w, a.driverId);
    }
    if (event == 'order.accepted' &&
        a.status == 'unassigned' &&
        a.fulfilledBy != 'partner' &&
        w.settings['dispatchAuto'] == true) {
      await w.job('dispatch.auto', 'dispatch-auto:${a.id}:accepted', {
        'assignmentId': a.id,
      });
    }
    if (a.partnerAppId != null && !PartnerModule.byPartner(w)) {
      final o = await PurchaseOrder.db.findById(w.s, id, transaction: w.tx);
      await PartnerModule.emit(w, a.partnerAppId!, event, a.partnerRef, {
        'ref': a.partnerRef,
        'orderId': id,
        'status': o?.status,
        if (event == 'order.ready' && a.fulfilledBy == 'partner')
          'pickup': 'The order is ready at the counter.',
      });
    }
  }

  /// A restaurant driver's pickup and handover, for the partner whose order it is.
  static Future<void> _deliveryEvent(
    Work w,
    String type,
    int? id,
    String event,
  ) async {
    if (type != 'delivery' || id == null) return;
    final a = await DeliveryAssignment.db.findById(w.s, id, transaction: w.tx);
    if (a == null ||
        a.partnerAppId == null ||
        a.fulfilledBy == 'partner' ||
        PartnerModule.byPartner(w)) {
      return;
    }
    final driver = a.driverId == null
        ? null
        : await Driver.db.findById(w.s, a.driverId!, transaction: w.tx);
    await PartnerModule.emit(w, a.partnerAppId!, event, a.partnerRef, {
      'ref': a.partnerRef,
      'orderId': a.orderId,
      if (driver != null)
        'driver': {'name': firstName(driver.name), 'vehicle': driver.vehicle},
      if (event == 'order.delivered') 'proof': a.proofKind,
    });
  }

  static String firstName(String name) =>
      name.trim().split(RegExp(r'\s+')).first;

  /// The worker's sweep: offers past their 90 seconds expire (and the
  /// automatic dispatcher moves on), pings older than two hours go.
  static Future<void> sweep(Session s) async {
    final due = await DeliveryOffer.db.find(
      s,
      where: (t) => t.state.equals('offered') & (t.expiresAt < _now()),
      limit: 100,
    );
    if (due.isNotEmpty) {
      await DeliveryOffer.db.updateWhere(
        s,
        columnValues: (t) => [t.state('expired'), t.respondedAt(_now())],
        where: (t) =>
            t.id.inSet(due.map((o) => o.id!).toSet()) &
            t.state.equals('offered'),
      );
      await PlatformJob.db.insert(s, [
        for (final o in due)
          PlatformJob(
            restaurantId: o.restaurantId,
            kind: 'dispatch.auto',
            dedupeKey: 'dispatch-auto:${o.assignmentId}:${o.id}',
            payloadJson: jsonEncode({'assignmentId': o.assignmentId}),
            state: 'pending',
            attempts: 0,
            availableAt: _now(),
            createdAt: _now(),
          ),
      ], ignoreConflicts: true);
    }
    await DeliveryPing.db.deleteWhere(
      s,
      where: (t) => t.at < _now().subtract(const Duration(hours: 2)),
    );
  }

  // ---- Payroll ------------------------------------------------------------------

  /// Deliveries per driver for the payroll agent's `delivery` batch:
  /// `driverPayPerDeliveryMinor` × deliveries handed over in the period.
  /// Drivers without a PayPal email are held and named, like staff.
  static Future<Json> driverPay(
    Session s,
    int restaurantId,
    DateTime from,
    DateTime to,
    Json settings,
  ) async {
    final rate = _setting(settings, 'driverPayPerDeliveryMinor');
    final done = await DeliveryAssignment.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(restaurantId) &
          t.status.equals('delivered') &
          t.driverId.notEquals(null) &
          (t.deliveredAt >= from) &
          (t.deliveredAt < to),
      limit: 10000,
    );
    final byDriver = <int, List<int>>{};
    for (final a in done) {
      (byDriver[a.driverId!] ??= []).add(a.id!);
    }
    final people = <Json>[], held = <Json>[];
    for (final entry in byDriver.entries) {
      final d = await Driver.db.findById(s, entry.key);
      if (d == null || d.kind != 'staff') continue;
      final row = {
        'driverId': d.id,
        'recipientName': d.name,
        'deliveries': entry.value.length,
        'amountMinor': entry.value.length * rate,
        'assignmentIds': entry.value,
      };
      if (d.payoutEmail == null) {
        held.add({...row, 'reason': 'no PayPal email on the driver card'});
      } else {
        people.add({...row, 'recipientEmail': d.payoutEmail});
      }
    }
    return {
      'rateMinor': rate,
      'deliveries': done.length,
      'people': people,
      'held': held,
    };
  }

  /// The `delivery` payout batch, proposed beside tips and wages. Null when
  /// the café pays nothing per delivery or no driver delivered.
  static Future<PayoutBatch?> payBatch(
    Session s,
    AgentTask task,
    DateTime from,
    DateTime to,
    String currency,
  ) async {
    final policy = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(task.restaurantId),
    );
    final settings = {
      ...CatalogueModule.defaults,
      ..._json(policy?.settingsJson ?? '{}'),
    };
    final pay = await driverPay(s, task.restaurantId, from, to, settings);
    final rate = pay['rateMinor'] as int;
    final people = (pay['people'] as List)
        .cast<Json>()
        .where((p) => (p['amountMinor'] as int) > 0)
        .toList();
    if (rate <= 0 || people.isEmpty) return null;
    final total = people.fold<int>(0, (n, p) => n + (p['amountMinor'] as int));
    String day(DateTime t) => t.toIso8601String().substring(0, 10);
    return AgentModule.asAgent<PayoutBatch>(s, task.restaurantId, (w) async {
      final b = await PayoutBatch.db.insertRow(
        s,
        PayoutBatch(
          restaurantId: w.tenant,
          kind: 'delivery',
          periodFrom: from,
          periodTo: to,
          totalMinor: total,
          currency: currency,
          state: 'proposed',
          requestKey:
              'po${w.tenant}-${_uuid().replaceAll('-', '').substring(0, 20)}',
          taskId: task.id,
          summaryJson: jsonEncode({
            'source': 'deliveries',
            'rateMinor': rate,
            'deliveries': pay['deliveries'],
            'people': people.length,
            'summary':
                '${pay['deliveries']} deliveries at '
                '${PayPalGateway.money(rate)} $currency each.',
            'held': [
              for (final h in (pay['held'] as List).cast<Json>())
                {
                  'recipientName': h['recipientName'],
                  'amountMinor': h['amountMinor'],
                  'deliveries': h['deliveries'],
                  'reason': h['reason'],
                },
            ],
          }),
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      for (final p in people) {
        await PayoutItem.db.insertRow(
          s,
          PayoutItem(
            restaurantId: w.tenant,
            batchId: b.id!,
            recipientEmail: p['recipientEmail'] as String,
            recipientName: p['recipientName'] as String,
            // The delivery jobs this pays for, in the field shifts use.
            shiftIdsJson: jsonEncode(p['assignmentIds']),
            amountMinor: p['amountMinor'] as int,
            note:
                '${p['deliveries']} deliveries ${day(from)} to ${day(to)}',
            state: 'proposed',
          ),
          transaction: w.tx,
        );
      }
      await w.audit('payout.proposed', 'payoutBatch', b.id, {
        'kind': 'delivery',
        'totalMinor': total,
      });
      return b;
    });
  }

  // ---- Queries ------------------------------------------------------------------

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async => switch (name) {
    'drivers' => drivers(w, d),
    'delivery.board' => board(w, d),
    'courier.jobs' => courierJobs(w, d),
    _ => null,
  };

  static Future<Json> _driverRow(Work w, Driver x, {bool contact = false}) async {
    final jobs = await DeliveryAssignment.db.find(
      w.s,
      where: (t) => t.driverId.equals(x.id!) & t.status.inSet(live),
      transaction: w.tx,
    );
    final p = await lastPing(w.s, jobs.map((j) => j.id!), tx: w.tx);
    final today = await DeliveryAssignment.db.count(
      w.s,
      where: (t) =>
          t.driverId.equals(x.id!) &
          t.status.equals('delivered') &
          (t.deliveredAt > _now().subtract(const Duration(hours: 24))),
      transaction: w.tx,
    );
    return {
      'id': x.id,
      'name': x.name,
      'kind': x.kind,
      'vehicle': x.vehicle,
      'status': x.status,
      'active': x.active,
      'version': x.version,
      'hasLogin': x.userId != null,
      'userId': x.userId,
      'phoneLast4': x.phoneLast4,
      if (contact) 'payoutEmail': x.payoutEmail,
      'lastSeenAt': x.lastSeenAt?.toIso8601String(),
      'activeJobs': jobs.length,
      'jobIds': [for (final j in jobs) j.id],
      'deliveredToday': today,
      'position': p == null
          ? null
          : {'latitude': p.lat, 'longitude': p.lng, 'at': p.at.toIso8601String()},
      'sample': x.name.endsWith(JudgeModule.sample),
    };
  }

  static Future<Json> drivers(Work w, Json d) async {
    final m = await _capable(w, 'dispatch');
    final rows = await Driver.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (d['all'] == true || d['all'] == 'true'
              ? Constant.bool(true)
              : t.active.equals(true)),
      orderBy: (t) => t.id,
      limit: 200,
      transaction: w.tx,
    );
    return {
      'rows': [
        for (final x in rows)
          await _driverRow(w, x, contact: _managers.contains(m.role)),
      ],
    };
  }

  /// The dispatch board: live jobs (and those delivered in the last three
  /// hours), each with its open offer, driver, estimate and position.
  static Future<Json> board(Work w, Json d) async {
    await _capable(w, 'dispatch');
    final rows = await DeliveryAssignment.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.status.inSet({'unassigned', ...live}) |
              (t.status.equals('delivered') &
                  (t.deliveredAt >
                      _now().subtract(const Duration(hours: 3))))),
      orderBy: (t) => t.id.desc(),
      limit: 100,
      transaction: w.tx,
    );
    final apps = <int, PartnerApp?>{};
    final out = <Json>[];
    for (final a in rows) {
      final o = await PurchaseOrder.db.findById(w.s, a.orderId, transaction: w.tx);
      final ctx = await OrderContext.db.findFirstRow(
        w.s,
        where: (t) => t.orderId.equals(a.orderId),
        transaction: w.tx,
      );
      if (o == null) continue;
      final driver = a.driverId == null
          ? null
          : await Driver.db.findById(w.s, a.driverId!, transaction: w.tx);
      final open = await DeliveryOffer.db.findFirstRow(
        w.s,
        where: (t) =>
            t.assignmentId.equals(a.id!) &
            t.state.equals('offered') &
            (t.expiresAt > _now()),
        transaction: w.tx,
      );
      final offered = open == null
          ? null
          : await Driver.db.findById(w.s, open.driverId, transaction: w.tx);
      final p = {'collected', 'outForDelivery'}.contains(a.status)
          ? await lastPing(w.s, [a.id!], tx: w.tx)
          : null;
      PartnerApp? app;
      if (a.partnerAppId != null) {
        app = apps[a.partnerAppId!] ??= await PartnerApp.db.findById(
          w.s,
          a.partnerAppId!,
          transaction: w.tx,
        );
      }
      Json? address;
      if (o.address != null) {
        final full = _json(o.address!);
        address = {
          'line': full['line'],
          'city': full['city'],
          if (full['instructions'] != null) 'instructions': full['instructions'],
        };
      }
      out.add({
        'id': a.id,
        'orderId': o.id,
        'number': ctx?.orderNumber,
        'customerLabel': ctx?.customerLabel,
        'origin': ctx?.origin ?? 'online',
        'orderStatus': o.status,
        'status': a.status,
        'version': a.version,
        'fulfilledBy': a.fulfilledBy ?? 'restaurant',
        'partner': app == null
            ? null
            : {'id': app.id, 'name': app.name, 'simulator': app.simulator},
        'partnerRef': a.partnerRef,
        'ready': o.status == 'ready',
        'createdAt': o.createdAt.toIso8601String(),
        'totalMinor': o.totalMinor,
        'currency': o.currency,
        'feeMinor': a.feeMinor ?? o.deliveryFeeMinor,
        'address': address,
        'dropoff': coordinates(dropoff(o)),
        'eta': a.status == 'delivered'
            ? null
            : estimate(
                w.settings,
                o,
                driver: driver,
                from: p == null ? null : (lat: p.lat, lng: p.lng),
              ),
        'etaAt': a.etaAt?.toIso8601String(),
        'driver': driver == null
            ? null
            : {'id': driver.id, 'name': driver.name, 'vehicle': driver.vehicle, 'kind': driver.kind},
        'offer': open == null
            ? null
            : {
                'offerId': open.id,
                'driverId': open.driverId,
                'driverName': offered?.name,
                'expiresAt': open.expiresAt.toIso8601String(),
                'score': open.score,
                'by': _json(open.reasonJson)['by'],
              },
        'position': p == null
            ? null
            : {'latitude': p.lat, 'longitude': p.lng, 'at': p.at.toIso8601String()},
        'pickedUpAt': a.pickedUpAt?.toIso8601String(),
        'deliveredAt': a.deliveredAt?.toIso8601String(),
        'proofKind': a.proofKind,
        'issue': _json(a.issueJson),
      });
    }
    return {
      'rows': out,
      'venue': coordinates(venue(w.settings)),
      'proofMode': w.settings['deliveryProof'] ?? 'none',
      'dispatchAuto': w.settings['dispatchAuto'] == true,
      'feeMode': w.settings['deliveryFeeMode'] ?? 'flat',
      'aiDispatcher':
          AgentModule.enabled(DispatchAgent.agent) &&
          AgentModule.autonomy(w.settings, DispatchAgent.agent) != 'off',
      'now': _now().toIso8601String(),
    };
  }

  /// What a courier's phone shows: their card, open offers with the seconds
  /// left, and their jobs with the full address (only while they carry it).
  static Future<Json> courierJobs(Work w, Json d) async {
    await w.role({'courier', ..._managers});
    final me = await _mine(w);
    final offers = me == null
        ? <DeliveryOffer>[]
        : await DeliveryOffer.db.find(
            w.s,
            where: (t) =>
                t.driverId.equals(me.id!) &
                t.state.equals('offered') &
                (t.expiresAt > _now()),
            orderBy: (t) => t.id,
            transaction: w.tx,
          );
    final jobs = await DeliveryAssignment.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.courierId.equals(w.user) &
          t.status.inSet(live),
      orderBy: (t) => t.id,
      limit: 20,
      transaction: w.tx,
    );
    Future<(PurchaseOrder, OrderContext)> order(int id) =>
        OrderingModule._order(w, id);
    final offerRows = <Json>[];
    for (final x in offers) {
      final a = await DeliveryAssignment.db.findById(
        w.s,
        x.assignmentId,
        transaction: w.tx,
      );
      if (a == null || a.status != 'unassigned') continue;
      final (o, ctx) = await order(a.orderId);
      final full = o.address == null ? <String, dynamic>{} : _json(o.address!);
      offerRows.add({
        'offerId': x.id,
        'assignmentId': a.id,
        'expiresAt': x.expiresAt.toIso8601String(),
        'secondsLeft': max(0, x.expiresAt.difference(_now()).inSeconds),
        'number': ctx.orderNumber,
        'items': o.lines.fold<int>(0, (n, l) => n + l.quantity),
        // Only the area until the job is accepted.
        'area': full['city'],
        'feeMinor': o.deliveryFeeMinor,
        'currency': o.currency,
        'eta': estimate(w.settings, o, driver: me),
        'ready': o.status == 'ready',
      });
    }
    final jobRows = <Json>[];
    for (final a in jobs) {
      final (o, ctx) = await order(a.orderId);
      jobRows.add({
        'id': a.id,
        'orderId': o.id,
        'number': ctx.orderNumber,
        'customerLabel': ctx.customerLabel,
        'status': a.status,
        'version': a.version,
        'orderStatus': o.status,
        'ready': o.status == 'ready',
        'paid': OrderingModule.paymentCleared(o, ctx),
        'items': [
          for (final l in o.lines) {'name': l.name, 'quantity': l.quantity},
        ],
        'address': o.address == null ? null : _json(o.address!),
        'dropoff': coordinates(dropoff(o)),
        'eta': estimate(
          w.settings,
          o,
          driver: me,
          from: a.locationJson == null ? null : point(_json(a.locationJson!)),
        ),
        'locationConsent': a.locationConsent,
        'issue': _json(a.issueJson),
        'partner': a.partnerAppId != null,
      });
    }
    return {
      'driver': me == null ? null : await _driverRow(w, me),
      'offers': offerRows,
      'jobs': jobRows,
      'venue': coordinates(venue(w.settings)),
      'proofMode': w.settings['deliveryProof'] ?? 'none',
      'offerSeconds': offerSeconds,
      'now': _now().toIso8601String(),
    };
  }

  /// `delivery.tracking` (queries.dart): the customer's view, or a manager's.
  static Future<Json> tracking(Work w, Json d) async {
    final (o, ctx) = await OrderingModule._order(
      w,
      _int(d, 'orderId', min: 1),
    );
    final customer = o.customerId == w.user;
    if (!customer) await w.role(_managers);
    final a = await DeliveryAssignment.db.findFirstRow(
      w.s,
      where: (t) => t.orderId.equals(o.id!),
      transaction: w.tx,
    );
    if (a == null) _fail('not_found', 'Delivery not found.');
    final location =
        a.locationConsent &&
            a.locationExpiresAt != null &&
            a.locationExpiresAt!.isAfter(_now()) &&
            a.locationJson != null
        ? _json(a.locationJson!)
        : null;
    final driver = a.driverId == null
        ? null
        : await Driver.db.findById(w.s, a.driverId!, transaction: w.tx);
    final open = !{'delivered', 'cancelled'}.contains(a.status);
    final moving = {'collected', 'outForDelivery'}.contains(a.status);
    final mode = (w.settings['deliveryProof'] as String?) ?? 'none';
    return {
      'status': a.status,
      'version': a.version,
      'location': location,
      'orderStatus': o.status,
      'fulfilledBy': a.fulfilledBy ?? 'restaurant',
      'eta': open
          ? estimate(
              w.settings,
              o,
              driver: driver,
              from: moving ? point(location) : null,
            )
          : null,
      'venue': coordinates(venue(w.settings)),
      'dropoff': coordinates(dropoff(o)),
      'driver': driver == null
          ? null
          : {
              'name': firstName(driver.name),
              'vehicle': driver.vehicle,
              'partner': driver.kind == 'partner',
            },
      'pickedUpAt': a.pickedUpAt?.toIso8601String(),
      'deliveredAt': a.deliveredAt?.toIso8601String(),
      'proofMode': mode,
      if (customer && mode == 'code' && open && a.fulfilledBy != 'partner')
        'code': dropoffCode(o),
      'number': ctx.orderNumber,
    };
  }
}
