part of 'platform.dart';

class WorkspaceModule {
  static Future<Json> archiveThread(Session s, PlatformCommand c) =>
      _mutate(s, c, 'operations.archiveThread', (w, d) async {
        _keys(d, {'threadKey'});
        await w.role(_managers);
        final key = _str(d, 'threadKey', max: 80);
        final rows = await AssistantRun.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              t.userId.equals(w.user) &
              t.roomId.equals(null) &
              t.status.notEquals('archived'),
          limit: 200,
          transaction: w.tx,
        );
        for (final row in rows.where(
          (r) => _json(r.inputJson)['threadKey'] == key,
        )) {
          row.status = 'archived';
          row.version++;
          await AssistantRun.db.updateRow(s, row, transaction: w.tx);
        }
        return {'archived': true};
      });
  static Future<Json> threads(Work w, Json d) async {
    await w.role(_managers);
    final rows = await AssistantRun.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.userId.equals(w.user) &
          t.roomId.equals(null) &
          t.status.notEquals('archived'),
      orderBy: (t) => t.id.desc(),
      limit: 200,
      transaction: w.tx,
    );
    return {
      'runs': rows.reversed.map((r) {
        final input = _json(r.inputJson);
        return {
          'id': r.id,
          'threadKey': input['threadKey'] ?? r.requestKey,
          'text': input['text'],
          'status': r.status,
          'answer': _json(r.outputJson),
          'steps': jsonDecode(r.traceJson),
          'createdAt': r.createdAt.toIso8601String(),
        };
      }).toList(),
    };
  }

  static Future<Json> snapshot(Work w, Json d) async {
    if (Platform.environment['RAYSTO_OPERATIONS_ENABLED'] != 'true') {
      _fail('not_enabled', 'Connected operations are not enabled.');
    }
    await w.role(_managers);
    final filter = _str(
      d,
      'filter',
      choices: {'all', 'billRequested', 'paymentExceptions'},
      fallback: 'all',
    );
    final tables = await DiningTable.db.find(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.id,
      limit: 201,
      transaction: w.tx,
    );
    if (tables.length > 200) {
      _fail(
        'page_required',
        'Narrow this restaurant workspace before loading.',
      );
    }
    final rows = <Json>[];
    for (final table in tables) {
      final visit = await DiningVisit.db.findFirstRow(
        w.s,
        where: (t) => t.activeTableId.equals(table.id!),
        transaction: w.tx,
      );
      final charges = visit == null
          ? <BillCharge>[]
          : await BillCharge.db.find(
              w.s,
              where: (t) => t.visitId.equals(visit.id!),
              limit: 501,
              transaction: w.tx,
            );
      if (charges.length > 500) {
        _fail('page_required', 'This bill requires a paginated report.');
      }
      final requests = visit == null
          ? <VisitRequest>[]
          : await VisitRequest.db.find(
              w.s,
              where: (t) =>
                  t.visitId.equals(visit.id!) &
                  t.status.inSet({'sent', 'acknowledged'}),
              limit: 100,
              transaction: w.tx,
            );
      final payments = visit == null
          ? <CheckoutIntent>[]
          : await CheckoutIntent.db.find(
              w.s,
              where: (t) => t.activeVisitId.equals(visit.id!),
              limit: 10,
              transaction: w.tx,
            );
      final balance = charges.fold<int>(
        0,
        (sum, b) =>
            sum + max(0, b.amountMinor - b.creditedMinor - b.settledMinor),
      );
      final billRequested = requests.any((r) => r.kind == 'bill');
      final exception = payments.any(
        (p) => {'uncertain', 'creating', 'capturing'}.contains(p.state),
      );
      if (filter == 'billRequested' && (!billRequested || balance == 0)) {
        continue;
      }
      if (filter == 'paymentExceptions' && !exception) continue;
      final room = visit == null
          ? null
          : await ConversationRoom.db.findFirstRow(
              w.s,
              where: (t) => t.visitId.equals(visit.id!),
              transaction: w.tx,
            );
      rows.add({
        'id': table.id,
        'label': table.label,
        'zone': table.zone,
        'geometry': _json(table.geometryJson),
        'capacity': table.capacity,
        'visitId': visit?.id,
        'roomId': room?.id,
        'guests': visit?.guestCount ?? 0,
        'status': visit != null
            ? 'occupied'
            : table.needsReset
            ? 'resetNeeded'
            : 'available',
        'outstandingMinor': balance,
        'currency': w.restaurant!.currency,
        'serviceCount': requests.length,
        'billRequested': billRequested,
        'paymentException': exception,
        'services': requests
            .map(
              (r) => {
                'id': r.id,
                'kind': r.kind,
                'status': r.status,
                'version': r.version,
              },
            )
            .toList(),
        'payments': payments
            .map(
              (p) => {
                'checkoutId': p.id,
                'state': p.state,
                'amountMinor': p.amountMinor,
              },
            )
            .toList(),
      });
    }
    final saved = await OperationsLayout.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
      transaction: w.tx,
    );
    final floor = await FloorLayout.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      transaction: w.tx,
    );
    final lastEvent = await AuditRecord.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.id.desc(),
      transaction: w.tx,
    );
    return {
      'restaurantId': w.tenant,
      'name': w.restaurant!.name,
      'currency': w.restaurant!.currency,
      'filter': filter,
      'rows': rows,
      'floor': floor == null ? null : _json(floor.layoutJson),
      'eventCursor': lastEvent?.id ?? 0,
      'asOf': _now().toIso8601String(),
      'layout': saved == null ? null : _json(saved.stateJson),
      'layoutVersion': saved?.version ?? 0,
      'outstandingMinor': rows.fold<int>(
        0,
        (sum, r) => sum + (r['outstandingMinor'] as int),
      ),
    };
  }

  static Future<Json> saveLayout(Session s, PlatformCommand c) =>
      _mutate(s, c, 'operations.layout', (w, d) async {
        _keys(d, {'state'});
        await w.role(_managers);
        final state = _object(d['state']);
        _keys(state, {
          'pages',
          'selectedPageId',
          'panels',
          'filter',
          'selectedTableId',
          'tab',
        });
        final encoded = jsonEncode(state);
        if (utf8.encode(encoded).length > 65536) {
          _fail('payload_too_large', 'Dashboard layout is too large.');
        }
        if (state['filter'] != null) {
          _str(
            state,
            'filter',
            choices: {'all', 'billRequested', 'paymentExceptions'},
          );
        }
        if (state['tab'] != null) {
          _str(
            state,
            'tab',
            choices: {'tables', 'orders', 'services', 'payments'},
          );
        }
        if (state['selectedTableId'] != null) {
          final table = await DiningTable.db.findById(
            s,
            _int(state, 'selectedTableId', min: 1),
            transaction: w.tx,
          );
          if (table == null || table.restaurantId != w.tenant) {
            _fail('not_found', 'Selected table is unavailable.');
          }
        }
        final pages = _list(state, 'pages', max: 8);
        final pageIds = <String>{};
        for (final raw in pages) {
          final page = _object(raw);
          final pageId = _str(page, 'id', max: 100);
          if (!pageIds.add(pageId)) {
            _fail('invalid_input', 'Duplicate dashboard page.');
          }
          final widgets = _object(page['widgets'] ?? {});
          if (widgets.length > 24) {
            _fail('limit_exceeded', 'Use at most 24 widgets per page.');
          }
          for (final value in widgets.values) {
            final widget = _object(value);
            _str(
              widget,
              'type',
              choices: {'raystoBalance', 'raystoService', 'raystoExceptions'},
            );
            _keys(widget, {'type', 'dataMapping', 'format'});
            _keys(_object(widget['dataMapping'] ?? {}), {});
            _keys(_object(widget['format'] ?? {}), {});
          }
        }
        var row = await OperationsLayout.db.findFirstRow(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
          transaction: w.tx,
        );
        _version(row?.version ?? 0, c.expectedVersion);
        if (row == null) {
          row = await OperationsLayout.db.insertRow(
            s,
            OperationsLayout(
              restaurantId: w.tenant,
              userId: w.user,
              stateJson: encoded,
              version: 1,
            ),
            transaction: w.tx,
          );
        } else {
          row.stateJson = encoded;
          row.version++;
          await OperationsLayout.db.updateRow(s, row, transaction: w.tx);
        }
        return {'version': row.version};
      });
}
