part of 'platform.dart';

class DiningModule {
  static Json geometry(Json d) {
    _keys(d, {'x', 'y', 'width', 'height', 'rotation', 'shape'});
    for (final k in ['x', 'y', 'width', 'height', 'rotation']) {
      final n = d[k];
      if (n is! num ||
          !n.isFinite ||
          n < 0 ||
          n > (k == 'rotation' ? 359 : 10000)) {
        _fail('invalid_input', 'Invalid table geometry.');
      }
    }
    if (d['width'] < 10 || d['height'] < 10) {
      _fail('invalid_input', 'Table dimensions are too small.');
    }
    _str(d, 'shape', choices: {'rectangle', 'round'});
    return d;
  }

  static Future<Json> saveFloor(Session s, PlatformCommand c) =>
      _mutate(s, c, 'floor.save', (w, d) async {
        _keys(d, {'width', 'height', 'zones', 'objects'});
        _int(d, 'width', min: 100, max: 10000);
        _int(d, 'height', min: 100, max: 10000);
        final zones = _list(d, 'zones', max: 30);
        final names = <String>{};
        for (final z in zones) {
          if (!names.add(_str({'zone': z}, 'zone', max: 80))) {
            _fail('invalid_input', 'Zone names must be unique.');
          }
        }
        final ids = <String>{};
        for (final raw in _list(d, 'objects', max: 200)) {
          final o = _object(raw);
          _keys(o, {'id', 'kind', 'label', 'geometry'});
          if (!ids.add(_str(o, 'id', max: 100))) {
            _fail('invalid_input', 'Object IDs must be unique.');
          }
          _str(o, 'kind', choices: {'wall', 'entrance', 'label'});
          _str(o, 'label', max: 80);
          geometry(_object(o['geometry']));
        }
        final tables = await DiningTable.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          transaction: w.tx,
        );
        for (final table in tables) {
          if (!names.contains(table.zone)) {
            _fail('conflict', 'Move tables before removing their zone.');
          }
        }
        var layout = await FloorLayout.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          transaction: w.tx,
        );
        if (layout == null) {
          if (c.expectedVersion != 0) {
            _fail('version_conflict', 'Use version 0 for a new layout.');
          }
          layout = await FloorLayout.db.insertRow(
            s,
            FloorLayout(
              restaurantId: w.tenant,
              layoutJson: jsonEncode(d),
              version: 1,
              updatedAt: _now(),
            ),
            transaction: w.tx,
          );
        } else {
          _version(layout.version, c.expectedVersion);
          layout.layoutJson = jsonEncode(d);
          layout.version++;
          layout.updatedAt = _now();
          await FloorLayout.db.updateRow(s, layout, transaction: w.tx);
        }
        await w.audit('floor.saved', 'layout', layout.id);
        return {'id': layout.id, 'version': layout.version};
      }, roles: _managers);

  static Future<Json> saveTable(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'table.save', (w, d) async {
    _keys(d, {
      'label',
      'zone',
      'capacity',
      'active',
      'geometry',
      'assignedWaiterId',
      'rotateQr',
    });
    final label = _str(d, 'label', max: 40),
        zoneName = _str(d, 'zone', max: 80);
    final seats = _int(d, 'capacity', min: 1, max: 50);
    final geo = geometry(_object(d['geometry']));
    final active = _bool(d, 'active', fallback: true);
    final layout = await FloorLayout.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(w.tenant),
      transaction: w.tx,
    );
    if (layout == null ||
        !(_json(layout.layoutJson)['zones'] as List).contains(zoneName)) {
      _fail('invalid_input', 'Choose a configured floor zone.');
    }
    final bounds = _json(layout.layoutJson);
    if (geo['x'] + geo['width'] > bounds['width'] ||
        geo['y'] + geo['height'] > bounds['height']) {
      _fail('invalid_input', 'Table must fit inside the room.');
    }
    if (d['assignedWaiterId'] != null) {
      await _role(s, _str(d, 'assignedWaiterId', max: 100), w.tenant, {
        'waiter',
      }, tx: w.tx);
    }
    final duplicate = await DiningTable.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(w.tenant) & t.label.equals(label),
      transaction: w.tx,
    );
    if (duplicate != null && duplicate.id != c.resourceId) {
      _fail('duplicate_label', 'Table label is already used.');
    }
    DiningTable table;
    if (c.resourceId == null) {
      table = await DiningTable.db.insertRow(
        s,
        DiningTable(
          restaurantId: w.tenant,
          label: label,
          zone: zoneName,
          capacity: seats,
          active: active,
          needsReset: false,
          qrKey: _secret(),
          geometryJson: jsonEncode(geo),
          assignedWaiterId: d['assignedWaiterId'],
          version: 1,
        ),
        transaction: w.tx,
      );
    } else {
      table = await _table(w, _id(c));
      _version(table.version, c.expectedVersion);
      final visit = await DiningVisit.db.findFirstRow(
        s,
        where: (t) => t.activeTableId.equals(table.id!),
        transaction: w.tx,
      );
      if (visit != null && (!active || seats < visit.guestCount)) {
        _fail(
          'occupied_table',
          'Resolve the active visit before deactivating or reducing capacity.',
        );
      }
      table.label = label;
      table.zone = zoneName;
      table.capacity = seats;
      table.active = active;
      table.geometryJson = jsonEncode(geo);
      table.assignedWaiterId = d['assignedWaiterId'];
      if (_bool(d, 'rotateQr')) table.qrKey = _secret();
      table.version++;
      await DiningTable.db.updateRow(s, table, transaction: w.tx);
    }
    await w.audit('table.saved', 'table', table.id);
    return {
      'id': table.id,
      'version': table.version,
      'qrUrl': 'https://rays.to/t/${table.qrKey}',
    };
  }, roles: _managers);
  static Future<DiningTable> _table(Work w, int id) async {
    final t = await DiningTable.db.findById(w.s, id, transaction: w.tx);
    if (t == null || t.restaurantId != w.tenant) {
      _fail('not_found', 'Table not found.');
    }
    return t;
  }

  static Future<DiningVisit> _visit(Work w, int id) async {
    final v = await DiningVisit.db.findById(w.s, id, transaction: w.tx);
    if (v == null || v.restaurantId != w.tenant) {
      _fail('not_found', 'Visit not found.');
    }
    return v;
  }

  static Future<Json> start(Session s, StartVisit r) => _mutate(
    s,
    PlatformCommand(
      requestKey: r.requestKey,
      restaurantId: r.restaurantId,
      dataJson: jsonEncode({
        'tableId': r.tableId,
        'guestCount': r.guestCount,
        'seatingToken': r.seatingToken,
      }),
    ),
    'visit.start',
    (w, d) async {
      final table = await _table(w, r.tableId);
      final m = await Membership.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.userId.equals(w.user) &
            t.active.equals(true),
        transaction: w.tx,
      );
      final staff = m != null && _operators.contains(m.role);
      if (staff && m.role == 'waiter' && table.assignedWaiterId != w.user) {
        _fail('forbidden', 'Table is not assigned to you.');
      }
      if (!staff && w.settings['selfSeating'] != true) {
        final token =
            r.seatingToken ??
            _fail(
              'seating_confirmation_required',
              'Ask staff to confirm your seating.',
            );
        final i = await IdentityModule._invitation(w, token, 'seating');
        if (i.targetId != table.id) {
          _fail('invalid_invitation', 'Invitation is for a different table.');
        }
        i.usesRemaining--;
        await AccessInvitation.db.updateRow(s, i, transaction: w.tx);
      }
      if (w.actor.isGuest && w.settings['guestOrdering'] != true) {
        _fail('account_required', 'This restaurant requires an account.');
      }
      final visit = await _open(
        w,
        table,
        r.guestCount,
        participant: staff ? null : w.user,
      );
      return {'id': visit.id, 'version': visit.version};
    },
    active: true,
  );

  static Future<DiningVisit> _open(
    Work w,
    DiningTable table,
    int guests, {
    String? participant,
    int? reservationId,
    int? waitlistId,
  }) async {
    if (!table.active ||
        table.needsReset ||
        guests < 1 ||
        guests > table.capacity) {
      _fail(
        'table_unavailable',
        'Table is not ready or party exceeds capacity.',
      );
    }
    if (await DiningVisit.db.findFirstRow(
          w.s,
          where: (t) => t.activeTableId.equals(table.id!),
          transaction: w.tx,
        ) !=
        null) {
      _fail('table_occupied', 'This table has an active party.');
    }
    final offers = await DiningWaitlist.db.find(
      w.s,
      where: (t) =>
          t.offeredTableId.equals(table.id!) &
          t.status.equals('offered') &
          (t.offerExpiresAt > _now()),
      transaction: w.tx,
    );
    if (offers.any((o) => o.id != waitlistId)) {
      _fail('table_reserved', 'This table has an active waitlist offer.');
    }
    final reservations = await DiningReservation.db.find(
      w.s,
      where: (t) =>
          t.tableId.equals(table.id!) &
          (t.startsAt <
              _now().add(
                Duration(minutes: w.settings['reservationMinutes'] as int),
              )) &
          (t.endsAt > _now()),
      transaction: w.tx,
    );
    if (reservations.any(
      (r) =>
          r.id != reservationId &&
          {'confirmed', 'arrived', 'held'}.contains(r.status) &&
          (r.status != 'held' || r.holdExpiresAt!.isAfter(_now())),
    )) {
      _fail('table_reserved', 'The table is reserved.');
    }
    final visit = await DiningVisit.db.insertRow(
      w.s,
      DiningVisit(
        restaurantId: w.tenant,
        tableId: table.id!,
        activeTableId: table.id!,
        guestCount: guests,
        status: 'active',
        version: 1,
        openedBy: w.user,
        createdAt: _now(),
      ),
      transaction: w.tx,
    );
    if (participant != null) {
      await VisitParticipant.db.insertRow(
        w.s,
        VisitParticipant(
          restaurantId: w.tenant,
          visitId: visit.id!,
          userId: participant,
          active: true,
          joinedAt: _now(),
        ),
        transaction: w.tx,
      );
    }
    await w.audit('visit.opened', 'visit', visit.id);
    return visit;
  }

  static Future<Json> invite(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'visit.invite',
    (w, d) async {
      _keys(d, {'kind', 'uses', 'revokeId'});
      final kind = _str(d, 'kind', choices: {'seating', 'visit'});
      if (kind == 'seating') {
        await w.role(_operators);
        final table = await _table(w, _id(c));
        final member = await w.role(_operators);
        if (member.role == 'waiter' && table.assignedWaiterId != w.user) {
          _fail('forbidden', 'Table is not assigned to you.');
        }
      } else {
        final visit = await _visit(w, _id(c));
        await _visitAccess(w, visit);
        if (visit.status != 'active') _fail('visit_closed', 'Visit is closed.');
      }
      if (d['revokeId'] != null) {
        final old = await AccessInvitation.db.findById(
          s,
          _int(d, 'revokeId', min: 1),
          transaction: w.tx,
        );
        if (old == null ||
            old.restaurantId != w.tenant ||
            old.targetId != _id(c) ||
            old.kind != kind) {
          _fail('not_found', 'Invitation not found.');
        }
        old.revoked = true;
        await AccessInvitation.db.updateRow(s, old, transaction: w.tx);
        return {'revoked': true};
      }
      final token = _secret();
      final i = await AccessInvitation.db.insertRow(
        s,
        AccessInvitation(
          restaurantId: w.tenant,
          kind: kind,
          targetId: _id(c),
          tokenHash: _hash(token),
          createdBy: w.user,
          expiresAt: _now().add(Duration(minutes: kind == 'seating' ? 10 : 30)),
          usesRemaining: kind == 'seating'
              ? 1
              : _int(d, 'uses', min: 1, max: 20, fallback: 1),
          revoked: false,
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      return {
        'id': i.id,
        'token': token,
        'expiresAt': i.expiresAt.toIso8601String(),
      };
    },
  );
  static Future<Json> join(Session s, PlatformCommand c) =>
      _mutate(s, c, 'visit.join', (w, d) async {
        _keys(d, {'token'});
        final i = await IdentityModule._invitation(
          w,
          _str(d, 'token', max: 100),
          'visit',
        );
        final visit = await _visit(w, i.targetId);
        if (visit.status != 'active') _fail('visit_closed', 'Visit is closed.');
        final existing = await VisitParticipant.db.findFirstRow(
          s,
          where: (t) => t.visitId.equals(visit.id!) & t.userId.equals(w.user),
          transaction: w.tx,
        );
        if (existing?.active == true) return {'visitId': visit.id};
        final participants = await VisitParticipant.db.count(
          s,
          where: (t) => t.visitId.equals(visit.id!) & t.active.equals(true),
          transaction: w.tx,
        );
        if (participants >= visit.guestCount) {
          _fail('capacity_exceeded', 'Ask staff to update the party size.');
        }
        if (existing == null) {
          await VisitParticipant.db.insertRow(
            s,
            VisitParticipant(
              restaurantId: w.tenant,
              visitId: visit.id!,
              userId: w.user,
              active: true,
              joinedAt: _now(),
            ),
            transaction: w.tx,
          );
        } else {
          existing.active = true;
          await VisitParticipant.db.updateRow(s, existing, transaction: w.tx);
        }
        i.usesRemaining--;
        await AccessInvitation.db.updateRow(s, i, transaction: w.tx);
        await w.audit('visit.joined', 'visit', visit.id);
        return {'visitId': visit.id};
      }, active: true);
  static Future<Json> leave(Session s, PlatformCommand c) =>
      _mutate(s, c, 'visit.leave', (w, d) async {
        _keys(d, {});
        final visit = await _visit(w, _id(c));
        await _visitAccess(w, visit);
        final pending = await CheckoutIntent.db.findFirstRow(
          s,
          where: (t) =>
              t.activeVisitId.equals(visit.id!) & t.userId.equals(w.user),
          transaction: w.tx,
        );
        if (pending != null) {
          _fail('payment_pending', 'Resolve your payment before leaving.');
        }
        await VisitParticipant.db.updateWhere(
          s,
          columnValues: (t) => [t.active(false)],
          where: (t) => t.visitId.equals(visit.id!) & t.userId.equals(w.user),
          transaction: w.tx,
        );
        await w.audit('visit.left', 'visit', visit.id);
        return {'left': true};
      });
  static Future<Json> move(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'visit.move',
    (w, d) async {
      _keys(d, {'tableId', 'guestCount', 'confirm'});
      if (!_bool(d, 'confirm')) {
        _fail('confirmation_required', 'Confirm moving this party.');
      }
      final visit = await _visit(w, _id(c));
      await _visitAccess(w, visit, staffOnly: true);
      _version(visit.version, c.expectedVersion);
      if (visit.status != 'active') _fail('visit_closed', 'Visit is closed.');
      final next = await _table(w, _int(d, 'tableId', min: 1));
      final guests = _int(
        d,
        'guestCount',
        min: 1,
        max: 50,
        fallback: visit.guestCount,
      );
      if (!next.active || next.needsReset || next.capacity < guests) {
        _fail('table_unavailable', 'Destination is not eligible.');
      }
      if (next.id != visit.tableId) {
        if (await DiningVisit.db.findFirstRow(
              s,
              where: (t) => t.activeTableId.equals(next.id!),
              transaction: w.tx,
            ) !=
            null) {
          _fail('table_occupied', 'Destination is occupied.');
        }
        final overlapping = await DiningReservation.db.find(
          s,
          where: (t) =>
              t.tableId.equals(next.id!) &
              (t.startsAt <
                  _now().add(
                    Duration(minutes: w.settings['reservationMinutes'] as int),
                  )) &
              (t.endsAt > _now()),
          transaction: w.tx,
        );
        if (overlapping.any(
          (r) => {'confirmed', 'arrived', 'held'}.contains(r.status),
        )) {
          _fail('table_reserved', 'Destination is reserved.');
        }
        final old = await _table(w, visit.tableId);
        old.needsReset = true;
        old.version++;
        await DiningTable.db.updateRow(s, old, transaction: w.tx);
        visit.tableId = next.id!;
        visit.activeTableId = next.id;
      }
      visit.guestCount = guests;
      visit.version++;
      await DiningVisit.db.updateRow(s, visit, transaction: w.tx);
      await w.audit('visit.moved', 'visit', visit.id);
      return {'version': visit.version, 'tableId': visit.tableId};
    },
    roles: _operators,
  );
  static Future<Json> close(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'visit.close',
    (w, d) async {
      _keys(d, {});
      final visit = await _visit(w, _id(c));
      await _visitAccess(w, visit, staffOnly: true);
      _version(visit.version, c.expectedVersion);
      if (visit.status != 'active') {
        _fail('visit_closed', 'Visit is already closed.');
      }
      final contexts = await OrderContext.db.find(
        s,
        where: (t) => t.visitId.equals(visit.id!),
        transaction: w.tx,
      );
      for (final ctx in contexts) {
        final order = await PurchaseOrder.db.findById(
          s,
          ctx.orderId,
          transaction: w.tx,
        );
        if (order != null &&
            !{'completed', 'cancelled', 'rejected'}.contains(order.status)) {
          _fail('orders_unresolved', 'Finish or cancel outstanding orders.');
        }
      }
      final charges = await BillCharge.db.find(
        s,
        where: (t) => t.visitId.equals(visit.id!),
        transaction: w.tx,
      );
      if (charges.any(
        (v) =>
            v.amountMinor - v.creditedMinor - v.settledMinor > 0 ||
            v.reservedMinor > 0,
      )) {
        _fail('balance_unsettled', 'Resolve the bill before closing.');
      }
      if (await CheckoutIntent.db.findFirstRow(
            s,
            where: (t) => t.activeVisitId.equals(visit.id!),
            transaction: w.tx,
          ) !=
          null) {
        _fail('payment_pending', 'Resolve pending payment.');
      }
      final requests = await VisitRequest.db.find(
        s,
        where: (t) => t.visitId.equals(visit.id!),
        transaction: w.tx,
      );
      if (requests.any((r) => !{'completed', 'cancelled'}.contains(r.status))) {
        _fail('requests_unresolved', 'Resolve outstanding service requests.');
      }
      visit.status = 'closed';
      visit.closedAt = _now();
      visit.activeTableId = null;
      visit.version++;
      await DiningVisit.db.updateRow(s, visit, transaction: w.tx);
      final table = await _table(w, visit.tableId);
      table.needsReset = true;
      table.version++;
      await DiningTable.db.updateRow(s, table, transaction: w.tx);
      await AccessInvitation.db.updateWhere(
        s,
        columnValues: (t) => [t.revoked(true)],
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.kind.equals('visit') &
            t.targetId.equals(visit.id!),
        transaction: w.tx,
      );
      await w.audit('visit.closed', 'visit', visit.id);
      return {'status': 'closed', 'version': visit.version};
    },
    roles: _operators,
  );
  static Future<Json> resetTable(Session s, PlatformCommand c) =>
      _mutate(s, c, 'table.reset', (w, d) async {
        _keys(d, {});
        final table = await _table(w, _id(c));
        _version(table.version, c.expectedVersion);
        final role = await w.role(_operators);
        if (role.role == 'waiter' && table.assignedWaiterId != w.user) {
          _fail('forbidden', 'Table is not assigned to you.');
        }
        if (await DiningVisit.db.findFirstRow(
              s,
              where: (t) => t.activeTableId.equals(table.id!),
              transaction: w.tx,
            ) !=
            null) {
          _fail('table_occupied', 'Close the visit before resetting.');
        }
        table.needsReset = false;
        table.version++;
        await DiningTable.db.updateRow(s, table, transaction: w.tx);
        await w.audit('table.reset', 'table', table.id);
        return {'version': table.version};
      }, roles: _operators);
  static Future<Json> request(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'service.create', (w, d) async {
    _keys(d, {'kind'});
    final visit = await _visit(w, _id(c));
    await _visitAccess(w, visit);
    if (visit.status != 'active') _fail('visit_closed', 'Visit is closed.');
    final kind = _str(d, 'kind', choices: {'water', 'cutlery', 'help', 'bill'});
    final requests = await VisitRequest.db.find(
      s,
      where: (t) => t.visitId.equals(visit.id!) & t.kind.equals(kind),
      transaction: w.tx,
    );
    final existing = requests
        .where((r) => {'sent', 'acknowledged'}.contains(r.status))
        .firstOrNull;
    if (existing != null) return {'id': existing.id, 'status': existing.status};
    final row = await VisitRequest.db.insertRow(
      s,
      VisitRequest(
        restaurantId: w.tenant,
        visitId: visit.id!,
        userId: w.user,
        kind: kind,
        status: 'sent',
        version: 1,
        createdAt: _now(),
      ),
      transaction: w.tx,
    );
    await w.audit('service.sent', 'serviceRequest', row.id);
    return {'id': row.id, 'version': 1};
  });
  static Future<Json> transitionRequest(Session s, PlatformCommand c) =>
      _mutate(s, c, 'service.transition', (w, d) async {
        _keys(d, {'status', 'assignedUserId', 'reason'});
        final row = await VisitRequest.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (row == null || row.restaurantId != w.tenant) {
          _fail('not_found', 'Request not found.');
        }
        _version(row.version, c.expectedVersion);
        final next = _str(
          d,
          'status',
          choices: {'acknowledged', 'completed', 'cancelled'},
        );
        final visit = await _visit(w, row.visitId);
        if (!(next == 'cancelled' && row.userId == w.user)) {
          await _visitAccess(w, visit, staffOnly: true);
        }
        if (!{'sent', 'acknowledged'}.contains(row.status)) {
          _fail('invalid_transition', 'Request is already resolved.');
        }
        if (next == 'cancelled') row.reason = _str(d, 'reason', max: 500);
        if (d['assignedUserId'] != null) {
          await w.role(_managers);
          await _role(
            s,
            _str(d, 'assignedUserId', max: 100),
            w.tenant,
            _operators,
            tx: w.tx,
          );
          row.assignedUserId = d['assignedUserId'];
        }
        row.status = next;
        row.version++;
        await VisitRequest.db.updateRow(s, row, transaction: w.tx);
        await w.audit('service.$next', 'serviceRequest', row.id);
        return {'version': row.version};
      });

  static Future<void> _bookingAvailable(
    Work w,
    int tableId,
    int size,
    DateTime start,
    DateTime end, {
    int? exclude,
  }) async {
    final table = await _table(w, tableId);
    if (!table.active ||
        size > table.capacity ||
        !end.isAfter(start) ||
        start.isBefore(_now()) ||
        start.isAfter(_now().add(const Duration(days: 90)))) {
      _fail('slot_unavailable', 'Invalid reservation time or table.');
    }
    if (!CatalogueModule.openAt(w.settings, start) ||
        !CatalogueModule.openAt(
          w.settings,
          end.subtract(const Duration(minutes: 1)),
        )) {
      _fail('closed', 'Reservation is outside service hours.');
    }
    final conflicts = await DiningReservation.db.find(
      w.s,
      where: (t) =>
          t.tableId.equals(tableId) & (t.startsAt < end) & (t.endsAt > start),
      transaction: w.tx,
    );
    if (conflicts.any(
      (r) =>
          r.id != exclude &&
          {'held', 'confirmed', 'arrived', 'seated'}.contains(r.status) &&
          (r.status != 'held' || r.holdExpiresAt!.isAfter(_now())),
    )) {
      _fail('slot_unavailable', 'This table is already booked.');
    }
    if (start.isBefore(
          _now().add(
            Duration(minutes: w.settings['reservationMinutes'] as int),
          ),
        ) &&
        await DiningVisit.db.findFirstRow(
              w.s,
              where: (t) => t.activeTableId.equals(tableId),
              transaction: w.tx,
            ) !=
            null) {
      _fail('table_occupied', 'This table is occupied.');
    }
  }

  static Future<Json> reserve(Session s, PlatformCommand c) =>
      _mutate(s, c, 'reservation.create', (w, d) async {
        _keys(d, {'tableId', 'partySize', 'startsAt', 'contact'});
        final start = _date(d, 'startsAt');
        final end = start.add(
          Duration(minutes: w.settings['reservationMinutes'] as int),
        );
        final size = _int(d, 'partySize', min: 1, max: 50),
            tableId = _int(d, 'tableId', min: 1);
        await _bookingAvailable(w, tableId, size, start, end);
        final contact = OperationsModule.contact(_object(d['contact']));
        final row = await DiningReservation.db.insertRow(
          s,
          DiningReservation(
            restaurantId: w.tenant,
            userId: w.user,
            tableId: tableId,
            partySize: size,
            startsAt: start,
            endsAt: end,
            holdExpiresAt: _now().add(const Duration(minutes: 5)),
            status: 'held',
            contactJson: jsonEncode(contact),
            version: 1,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.job('reservation.expire', 'reservation:${row.id}:expire', {
          'reservationId': row.id,
        }, at: row.holdExpiresAt);
        await w.audit('reservation.held', 'reservation', row.id);
        return {
          'id': row.id,
          'version': 1,
          'holdExpiresAt': row.holdExpiresAt!.toIso8601String(),
        };
      }, active: true);
  static Future<Json> reservationTransition(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'reservation.transition', (w, d) async {
    _keys(d, {'status', 'startsAt', 'tableId', 'partySize'});
    final r = await DiningReservation.db.findById(s, _id(c), transaction: w.tx);
    if (r == null || r.restaurantId != w.tenant) {
      _fail('not_found', 'Reservation not found.');
    }
    _version(r.version, c.expectedVersion);
    final next = _str(
      d,
      'status',
      choices: {
        'confirmed',
        'arrived',
        'seated',
        'cancelled',
        'noShow',
        'modified',
      },
    );
    if (r.userId != w.user || {'arrived', 'seated', 'noShow'}.contains(next)) {
      final member = await w.role(_operators);
      if (member.role == 'waiter') {
        final table = await _table(w, r.tableId);
        if (table.assignedWaiterId != w.user) {
          _fail('forbidden', 'This table is not assigned to you.');
        }
        if (next == 'modified' && _int(d, 'tableId', min: 1) != r.tableId) {
          final destination = await _table(w, _int(d, 'tableId', min: 1));
          if (destination.assignedWaiterId != w.user) {
            _fail('forbidden', 'The destination table is not assigned to you.');
          }
        }
      }
    }
    final allowed = {
      'held': {'confirmed', 'cancelled'},
      'confirmed': {'modified', 'arrived', 'cancelled', 'noShow'},
      'arrived': {'seated', 'cancelled'},
    };
    if (!(allowed[r.status]?.contains(next) ?? false)) {
      _fail('invalid_transition', 'Invalid reservation transition.');
    }
    if (r.status == 'held' && !r.holdExpiresAt!.isAfter(_now())) {
      _fail('hold_expired', 'Reservation hold expired.');
    }
    if (next == 'modified') {
      final start = _date(d, 'startsAt'),
          end = _date(
            d,
            'startsAt',
          ).add(Duration(minutes: w.settings['reservationMinutes'] as int));
      final tableId = _int(d, 'tableId', min: 1),
          size = _int(d, 'partySize', min: 1, max: 50);
      await _bookingAvailable(w, tableId, size, start, end, exclude: r.id);
      r.tableId = tableId;
      r.startsAt = start;
      r.endsAt = end;
      r.partySize = size;
    } else if (next == 'seated') {
      final table = await _table(w, r.tableId);
      final visit = await _open(
        w,
        table,
        r.partySize,
        participant: r.userId,
        reservationId: r.id,
      );
      r.visitId = visit.id;
      r.status = next;
    } else {
      if (next == 'noShow' &&
          _now().isBefore(r.startsAt.add(const Duration(minutes: 15)))) {
        _fail('too_early', 'The arrival grace period has not ended.');
      }
      r.status = next;
    }
    r.version++;
    await DiningReservation.db.updateRow(s, r, transaction: w.tx);
    await w.notify(r.userId, 'reservation.$next', {
      'id': r.id,
    }, 'reservation:${r.id}:${r.version}');
    await w.audit('reservation.$next', 'reservation', r.id);
    return {'version': r.version, 'status': r.status, 'visitId': r.visitId};
  });
  static Future<Json> waitlistJoin(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'waitlist.join',
    (w, d) async {
      _keys(d, {'partySize', 'contact'});
      final entries = await DiningWaitlist.db.find(
        s,
        where: (t) => t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
        transaction: w.tx,
      );
      if (entries.any((r) => {'waiting', 'offered'}.contains(r.status))) {
        _fail('already_waiting', 'You already have an active waitlist entry.');
      }
      final r = await DiningWaitlist.db.insertRow(
        s,
        DiningWaitlist(
          restaurantId: w.tenant,
          userId: w.user,
          partySize: _int(d, 'partySize', min: 1, max: 50),
          contactJson: jsonEncode(
            OperationsModule.contact(_object(d['contact'])),
          ),
          status: 'waiting',
          version: 1,
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      return {'id': r.id, 'version': 1};
    },
    active: true,
  );
  static Future<Json> waitlistTransition(Session s, PlatformCommand c) =>
      _mutate(s, c, 'waitlist.transition', (w, d) async {
        _keys(d, {'status', 'tableId'});
        final r = await DiningWaitlist.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (r == null || r.restaurantId != w.tenant) {
          _fail('not_found', 'Waitlist entry not found.');
        }
        _version(r.version, c.expectedVersion);
        final next = _str(
          d,
          'status',
          choices: {'offered', 'seated', 'left', 'waiting'},
        );
        if (!(next == 'left' && r.userId == w.user)) await w.role(_operators);
        if (!{'waiting', 'offered'}.contains(r.status)) {
          _fail('invalid_transition', 'Waitlist entry is resolved.');
        }
        if (next == 'offered') {
          final table = await _table(w, _int(d, 'tableId', min: 1));
          if (table.capacity < r.partySize ||
              !table.active ||
              table.needsReset) {
            _fail('table_unavailable', 'Table is not eligible.');
          }
          final member = await w.role(_operators);
          if (member.role == 'waiter' && table.assignedWaiterId != w.user) {
            _fail('forbidden', 'This table is not assigned to you.');
          }
          if (await DiningVisit.db.findFirstRow(
                s,
                where: (t) => t.activeTableId.equals(table.id!),
                transaction: w.tx,
              ) !=
              null) {
            _fail('table_occupied', 'Table is occupied.');
          }
          final offers = await DiningWaitlist.db.find(
            s,
            where: (t) =>
                t.offeredTableId.equals(table.id!) &
                t.status.equals('offered') &
                (t.offerExpiresAt > _now()),
            transaction: w.tx,
          );
          if (offers.any((o) => o.id != r.id)) {
            _fail('table_reserved', 'Another party holds this offer.');
          }
          r.offeredTableId = table.id;
          r.offerExpiresAt = _now().add(const Duration(minutes: 10));
          await w.notify(r.userId, 'waitlist.offered', {
            'id': r.id,
          }, 'waitlist:${r.id}:${r.version + 1}');
        }
        int? visitId;
        if (next == 'seated') {
          if (r.status != 'offered' ||
              r.offerExpiresAt == null ||
              !r.offerExpiresAt!.isAfter(_now())) {
            _fail('offer_expired', 'Offer expired.');
          }
          visitId = (await _open(
            w,
            await _table(w, r.offeredTableId!),
            r.partySize,
            participant: r.userId,
            waitlistId: r.id,
          )).id;
        }
        r.status = next;
        r.version++;
        await DiningWaitlist.db.updateRow(s, r, transaction: w.tx);
        await w.audit('waitlist.$next', 'waitlist', r.id);
        return {'version': r.version, 'status': r.status, 'visitId': visitId};
      });
}
