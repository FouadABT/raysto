part of 'platform.dart';

class PlatformQueries {
  static Future<Json> query(Session s, String name, Json d) async {
    PlatformApi.enabled();
    final limit = _int(d, 'limit', min: 1, max: 100, fallback: 30);
    final cursor = _int(d, 'cursor', fallback: 0, max: 9007199254740991);
    if (name == 'discovery') return discover(s, d, limit, cursor);
    if (name == 'table.resolve') {
      _keys(d, {'qr'});
      final table = await DiningTable.db.findFirstRow(
        s,
        where: (t) =>
            t.qrKey.equals(_str(d, 'qr', max: 100)) & t.active.equals(true),
      );
      if (table == null) _fail('not_found', 'Table not found.');
      final r = await Restaurant.db.findById(s, table.restaurantId);
      final p = await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(table.restaurantId),
      );
      if (r?.published != true || p?.suspended != false) {
        _fail('not_found', 'Table not found.');
      }
      return {
        'restaurantId': table.restaurantId,
        'tableId': table.id,
        'label': table.label,
        'requiresSeating': _json(p!.settingsJson)['selfSeating'] != true,
      };
    }
    if (name == 'storefront') {
      return storefront(s, _int(d, 'restaurantId', min: 1));
    }
    if (name == 'availability') return availability(s, d);
    await PlatformApi.guard(s);
    final actor = await _actor(s);
    return s.db.transaction((tx) async {
      final tenant = d['restaurantId'] == null
          ? null
          : _int(d, 'restaurantId', min: 1);
      final restaurant = tenant == null
          ? null
          : await Restaurant.db.findById(s, tenant, transaction: tx);
      if (tenant != null && restaurant == null) {
        _fail('not_found', 'Restaurant not found.');
      }
      final policy = tenant == null
          ? null
          : await RestaurantPolicy.db.findFirstRow(
              s,
              where: (t) => t.restaurantId.equals(tenant),
              transaction: tx,
            );
      final w = Work(
        s,
        tx,
        actor,
        PlatformCommand(
          requestKey: _uuid(),
          restaurantId: tenant,
          dataJson: '{}',
        ),
        restaurant,
        policy,
      );
      await _rate(s, 'read:${actor.userId}', 240, tx);
      Json page(List<Json> rows) => {
        'rows': rows,
        'nextCursor': rows.length == limit ? rows.last['id'] : null,
      };
      switch (name) {
        case 'room':
          return ConversationModule.snapshot(w, d);
        case 'room.events':
          return ConversationModule.eventPage(w, d);
        case 'assistant.run':
          return AssistantModule.query(w, d);
        case 'operations.snapshot':
          return WorkspaceModule.snapshot(w, d);
        case 'operations.threads':
          return WorkspaceModule.threads(w, d);
        case 'reviews.manage':
        case 'admin.reviews':
          if (name == 'admin.reviews') {
            await _admin(w);
          } else {
            await w.role(_managers);
          }
          final reviews = await CustomerReview.db.find(
            s,
            where: (t) =>
                (t.id > cursor) &
                (name == 'admin.reviews'
                    ? t.status.equals('pending')
                    : t.restaurantId.equals(w.tenant)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page([
            for (final review in reviews)
              {
                'id': review.id,
                'restaurantId': review.restaurantId,
                'rating': review.rating,
                'text': review.text,
                'response': review.response,
                'status': review.status,
                'version': review.version,
              },
          ]);
        case 'admin.financialCases':
          await _admin(w);
          final cases = await PaymentException.db.find(
            s,
            where: (t) => (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page([
            for (final item in cases)
              {
                'id': item.id,
                'restaurantId': item.restaurantId,
                'captureId': item.captureId,
                'kind': item.kind,
                'status': item.status,
                'version': item.version,
                'amountMinor': item.amountMinor,
                'currency': item.currency,
              },
          ]);
        case 'restaurant.manage':
          await w.role(_managers);
          final merchant = await MerchantConnection.db.findFirstRow(
            s,
            where: (t) => t.restaurantId.equals(w.tenant),
            transaction: tx,
          );
          return {
            'id': restaurant!.id,
            'name': restaurant.name,
            'currency': restaurant.currency,
            'published': restaurant.published,
            'settings': policy == null
                ? CatalogueModule.defaults
                : _json(policy.settingsJson),
            'version': policy?.version ?? 0,
            'menuVersion': policy?.menuVersion ?? 0,
            'merchantStatus': merchant?.status ?? 'notConnected',
          };
        case 'checkouts':
          if (d['staff'] == true) await w.role(_managers);
          final attempts = await CheckoutIntent.db.find(
            s,
            where: (t) =>
                (t.id > cursor) &
                (tenant == null
                    ? Constant.bool(true)
                    : t.restaurantId.equals(tenant)) &
                (d['staff'] == true
                    ? Constant.bool(true)
                    : t.userId.equals(w.user)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            attempts
                .map(
                  (a) => {
                    'id': a.id,
                    'restaurantId': a.restaurantId,
                    ...MoneyModule.view(a),
                  },
                )
                .toList(),
          );
        case 'visits':
          final ids = (await VisitParticipant.db.find(
            s,
            where: (t) => t.userId.equals(w.user) & t.active.equals(true),
            limit: 100,
            transaction: tx,
          )).map((p) => p.visitId).toSet();
          final visits = await DiningVisit.db.find(
            s,
            where: (t) => t.id.inSet(ids) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            visits
                .map(
                  (v) => {
                    'id': v.id,
                    'restaurantId': v.restaurantId,
                    'tableId': v.tableId,
                    'status': v.status,
                    'version': v.version,
                  },
                )
                .toList(),
          );
        case 'media':
          if (tenant != null) await w.role(_managers);
          final files = await MediaAsset.db.find(
            s,
            where: (t) =>
                t.userId.equals(w.user) &
                (t.id > cursor) &
                (tenant == null
                    ? Constant.bool(true)
                    : t.restaurantId.equals(tenant)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            files
                .map(
                  (f) => {
                    'id': f.id,
                    'purpose': f.purpose,
                    'status': f.status,
                    'published': f.public,
                    'mime': f.mime,
                  },
                )
                .toList(),
          );
        case 'ai.jobs':
          final jobs = await AiOperation.db.find(
            s,
            where: (t) =>
                t.userId.equals(w.user) &
                (t.id > cursor) &
                (tenant == null
                    ? Constant.bool(true)
                    : t.restaurantId.equals(tenant)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            jobs
                .map(
                  (a) => {
                    'id': a.id,
                    'restaurantId': a.restaurantId,
                    'kind': a.kind,
                    'status': a.status,
                    'version': a.version,
                  },
                )
                .toList(),
          );
        case 'admin.revenue':
          await _admin(w);
          final from = _date(d, 'from');
          final until = _date(d, 'until');
          if (!until.isAfter(from) || until.difference(from).inDays > 93) {
            _fail('invalid_input', 'Use a report range of at most 93 days.');
          }
          final payments = await BillingHistory.db.find(
            s,
            where: (t) =>
                t.status.inSet({'paymentRecorded', 'refundRecorded'}) &
                (t.createdAt >= from) &
                (t.createdAt < until),
            limit: 10001,
            transaction: tx,
          );
          final fees = await CommissionEntry.db.find(
            s,
            where: (t) => (t.createdAt >= from) & (t.createdAt < until),
            limit: 10001,
            transaction: tx,
          );
          if (payments.length > 10000 || fees.length > 10000) {
            _fail(
              'report_requires_partition',
              'Choose a narrower reporting period.',
            );
          }
          final subscriptions = <String, int>{};
          final commissions = <String, int>{};
          for (final payment in payments) {
            final detail = _json(payment.detailsJson);
            final code = detail['currency'] as String;
            subscriptions[code] =
                (subscriptions[code] ?? 0) + (detail['amountMinor'] as int);
          }
          for (final fee in fees) {
            commissions[fee.currency] =
                (commissions[fee.currency] ?? 0) + fee.amountMinor;
          }
          return {
            'subscriptionCollectionsMinorByCurrency': subscriptions,
            'commissionMinorByCurrency': commissions,
            'from': from.toIso8601String(),
            'until': until.toIso8601String(),
          };
        case 'exports':
          final files = await MediaAsset.db.find(
            s,
            where: (t) =>
                t.userId.equals(w.user) &
                t.purpose.equals('export') &
                (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            files
                .map(
                  (f) => {
                    'id': f.id,
                    'downloadPath': '/api/v2/media/${f.id}',
                    'expiresAt': _json(f.metadataJson)['expiresAt'],
                  },
                )
                .toList(),
          );
        case 'support.inbox':
          final staff = d['staff'] == true;
          if (staff) {
            if (tenant == null) {
              await _admin(w);
            } else {
              await w.role(_managers);
            }
          }
          final conversations = await SupportConversation.db.find(
            s,
            where: (t) =>
                (t.id > cursor) &
                (staff
                    ? t.restaurantId.equals(tenant)
                    : t.userId.equals(w.user)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            conversations
                .map(
                  (c) => {
                    'id': c.id,
                    'restaurantId': c.restaurantId,
                    'orderId': c.orderId,
                    'subject': c.subject,
                    'status': c.status,
                    'escalated': c.escalated,
                    'version': c.version,
                  },
                )
                .toList(),
          );
        case 'delivery.tracking':
          final (o, ctx) = await OrderingModule._order(
            w,
            _int(d, 'orderId', min: 1),
          );
          if (o.customerId != w.user) await w.role(_managers);
          final task = await DeliveryAssignment.db.findFirstRow(
            s,
            where: (t) => t.orderId.equals(o.id!),
            transaction: tx,
          );
          if (task == null) _fail('not_found', 'Delivery not found.');
          return {
            'status': task.status,
            'version': task.version,
            'location':
                task.locationConsent &&
                    task.locationExpiresAt != null &&
                    task.locationExpiresAt!.isAfter(_now()) &&
                    task.locationJson != null
                ? _json(task.locationJson!)
                : null,
          };
        case 'billing.history':
          await w.role({'owner'});
          final rows = await BillingHistory.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'status': r.status,
                    'details': _json(r.detailsJson),
                    'createdAt': r.createdAt.toIso8601String(),
                  },
                )
                .toList(),
          );
        case 'payment.exceptions':
          await w.role(_managers);
          final rows = await PaymentException.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'captureId': r.captureId,
                    'kind': r.kind,
                    'status': r.status,
                    'amountMinor': r.amountMinor,
                    'currency': r.currency,
                    'version': r.version,
                  },
                )
                .toList(),
          );
        case 'me':
          final memberships = await Membership.db.find(
            s,
            where: (t) => t.userId.equals(w.user) & t.active.equals(true),
            limit: 100,
            transaction: tx,
          );
          return {
            'guest': actor.isGuest,
            'platformAdmin': !actor.isGuest && _platformAdmin(w.user),
            'profile': _json(actor.dataJson),
            'version': actor.version,
            'memberships': [
              for (final m in memberships)
                {
                  'restaurantId': m.restaurantId,
                  'role': m.role,
                  'name': (await Restaurant.db.findById(
                    s,
                    m.restaurantId,
                    transaction: tx,
                  ))?.name,
                },
            ],
          };
        case 'cart':
          final cart = await CustomerCart.db.findFirstRow(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
            transaction: tx,
          );
          return {
            'version': cart?.version ?? 0,
            'lines': cart == null ? [] : jsonDecode(cart.linesJson),
          };
        case 'orders':
          final staff = d['staff'] == true;
          Membership? staffMember;
          if (staff) staffMember = await w.role(_operators);
          final assignedTables = staffMember?.role == 'waiter'
              ? (await DiningTable.db.find(
                  s,
                  where: (t) =>
                      t.restaurantId.equals(w.tenant) &
                      t.assignedWaiterId.equals(w.user),
                  transaction: tx,
                )).map((t) => t.id!).toSet()
              : <int>{};
          final assignedVisits = staffMember?.role == 'waiter'
              ? (await DiningVisit.db.find(
                  s,
                  where: (t) => t.tableId.inSet(assignedTables),
                  transaction: tx,
                )).map((v) => v.id!).toSet()
              : <int>{};
          final assignedOrders = staffMember?.role == 'waiter'
              ? (await OrderContext.db.find(
                  s,
                  where: (t) => t.visitId.inSet(assignedVisits),
                  transaction: tx,
                )).map((o) => o.orderId).toSet()
              : <int>{};
          final rows = await PurchaseOrder.db.find(
            s,
            where: (t) =>
                (t.id > cursor) &
                (staff
                    ? t.restaurantId.equals(w.tenant) &
                          (staffMember?.role == 'waiter'
                              ? t.id.inSet(assignedOrders)
                              : Constant.bool(true))
                    : t.customerId.equals(w.user)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page([
            for (final o in rows)
              _safeOrder(
                o,
                await OrderContext.db.findFirstRow(
                  s,
                  where: (t) => t.orderId.equals(o.id!),
                  transaction: tx,
                ),
              ),
          ]);
        case 'order':
          final (o, ctx) = await OrderingModule._order(
            w,
            _int(d, 'id', min: 1),
          );
          await _orderAccess(w, o);
          final events = await AuditRecord.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                t.entityType.equals('order') &
                t.entityId.equals(o.id!) &
                (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return {
            ..._safeOrder(o, ctx, contact: o.customerId == w.user),
            'timeline': events
                .map(
                  (e) => {
                    'id': e.id,
                    'kind': e.kind,
                    'at': e.createdAt.toIso8601String(),
                  },
                )
                .toList(),
          };
        case 'visit':
          final visit = await DiningModule._visit(w, _int(d, 'id', min: 1));
          await _visitAccess(w, visit);
          final charges = await BillCharge.db.find(
            s,
            where: (t) => t.visitId.equals(visit.id!) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          final participants = await VisitParticipant.db.find(
            s,
            where: (t) => t.visitId.equals(visit.id!) & t.active.equals(true),
            limit: 100,
            transaction: tx,
          );
          return {
            'id': visit.id,
            'tableId': visit.tableId,
            'status': visit.status,
            'version': visit.version,
            'guestCount': visit.guestCount,
            'participantCount': participants.length,
            ...page(
              charges
                  .map(
                    (b) => {
                      'id': b.id,
                      'itemKey': '${b.orderId}:${b.lineKey}',
                      'orderId': b.orderId,
                      'kind': b.kind,
                      'amountMinor': b.amountMinor,
                      'creditedMinor': b.creditedMinor,
                      'settledMinor': b.settledMinor,
                      'reservedMinor': b.reservedMinor,
                      'remainingMinor': max(
                        0,
                        b.amountMinor - b.creditedMinor - b.settledMinor,
                      ),
                      'version': b.version,
                    },
                  )
                  .toList(),
            ),
          };
        case 'floor':
          final m = await w.role(_operators);
          final layout = await FloorLayout.db.findFirstRow(
            s,
            where: (t) => t.restaurantId.equals(w.tenant),
            transaction: tx,
          );
          final tables = await DiningTable.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return {
            'layout': layout == null ? null : _json(layout.layoutJson),
            'version': layout?.version ?? 0,
            ...page([
              for (final t in tables)
                if (m.role != 'waiter' || t.assignedWaiterId == w.user)
                  {
                    'id': t.id,
                    'label': t.label,
                    'capacity': t.capacity,
                    'zone': t.zone,
                    'active': t.active,
                    'needsReset': t.needsReset,
                    'version': t.version,
                    'geometry': _json(t.geometryJson),
                    'qr': t.qrKey,
                    'assignedWaiterId': t.assignedWaiterId,
                    'visitId': (await DiningVisit.db.findFirstRow(
                      s,
                      where: (v) => v.activeTableId.equals(t.id!),
                      transaction: tx,
                    ))?.id,
                  },
            ]),
          };
        case 'team':
          await w.role(_managers);
          final members = await Membership.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            members
                .map(
                  (m) => {
                    'id': m.id,
                    'userId': m.userId,
                    'role': m.role,
                    'active': m.active,
                  },
                )
                .toList(),
          );
        case 'menu.manage':
          await w.role({'owner', 'manager', 'kitchen'});
          final items = await MenuDefinition.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return {
            'menuVersion': policy?.menuVersion,
            ...page(
              items
                  .map(
                    (m) => {
                      'id': m.id,
                      'productId': m.productId,
                      'definition': _json(m.definitionJson),
                      'version': m.version,
                      'stockRemaining': m.stockRemaining,
                      'archived': m.archived,
                    },
                  )
                  .toList(),
            ),
          };
        case 'menu.drafts':
          await w.role(_managers);
          final drafts = await MenuDraft.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            drafts
                .map(
                  (m) => {
                    'id': m.id,
                    'items': jsonDecode(m.itemsJson),
                    'version': m.version,
                    'baseMenuVersion': m.baseMenuVersion,
                    'status': m.status,
                  },
                )
                .toList(),
          );
        case 'kitchen':
          await w.role({'owner', 'manager', 'kitchen'});
          final orders = await PurchaseOrder.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                t.status.inSet({
                  'submitted',
                  'accepted',
                  'preparing',
                  'ready',
                }) &
                (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page([
            for (final o in orders)
              {
                ..._safeOrder(
                  o,
                  await OrderContext.db.findFirstRow(
                    s,
                    where: (t) => t.orderId.equals(o.id!),
                    transaction: tx,
                  ),
                ),
                'tickets':
                    (await KitchenProgress.db.find(
                          s,
                          where: (t) => t.orderId.equals(o.id!),
                          limit: 100,
                          transaction: tx,
                        ))
                        .map(
                          (k) => {
                            'id': k.id,
                            'lineKey': k.lineKey,
                            'quantity': k.quantity,
                            'completedQuantity': k.completedQuantity,
                            'version': k.version,
                          },
                        )
                        .toList(),
              },
          ]);
        case 'deliveries':
          final m = await w.role({'owner', 'manager', 'courier'});
          final tasks = await DeliveryAssignment.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                (t.id > cursor) &
                (m.role == 'courier'
                    ? t.courierId.equals(w.user)
                    : Constant.bool(true)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page([
            for (final t in tasks)
              {
                'id': t.id,
                'orderId': t.orderId,
                'status': t.status,
                'version': t.version,
                'courierId': t.courierId,
                'issue': _json(t.issueJson),
                if (!{'delivered', 'cancelled'}.contains(t.status))
                  'address': (await PurchaseOrder.db.findById(
                    s,
                    t.orderId,
                    transaction: tx,
                  ))?.address,
              },
          ]);
        case 'reservations':
          final staff = d['staff'] == true;
          if (staff) await w.role(_operators);
          final rows = await DiningReservation.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                (t.id > cursor) &
                (staff ? Constant.bool(true) : t.userId.equals(w.user)),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'tableId': r.tableId,
                    'partySize': r.partySize,
                    'startsAt': r.startsAt.toIso8601String(),
                    'endsAt': r.endsAt.toIso8601String(),
                    'status': r.status,
                    'version': r.version,
                    'contact': _json(r.contactJson),
                  },
                )
                .toList(),
          );
        case 'waitlist':
          await w.role(_operators);
          final rows = await DiningWaitlist.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'partySize': r.partySize,
                    'status': r.status,
                    'version': r.version,
                    'offeredTableId': r.offeredTableId,
                    'contact': _json(r.contactJson),
                  },
                )
                .toList(),
          );
        case 'services':
          final visit = await DiningModule._visit(
            w,
            _int(d, 'visitId', min: 1),
          );
          await _visitAccess(w, visit);
          final rows = await VisitRequest.db.find(
            s,
            where: (t) => t.visitId.equals(visit.id!) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'kind': r.kind,
                    'status': r.status,
                    'version': r.version,
                    'assignedUserId': r.assignedUserId,
                  },
                )
                .toList(),
          );
        case 'checkout':
          final i = await MoneyModule._intent(w, _int(d, 'id', min: 1));
          final capture = await PaymentCapture.db.findFirstRow(
            s,
            where: (t) => t.checkoutId.equals(i.id!),
            transaction: tx,
          );
          return {
            ...MoneyModule.view(i),
            'captureId': capture?.id,
            'refundedMinor': capture?.refundedMinor ?? 0,
          };
        case 'billing':
          await w.role({'owner'});
          final sub = await RestaurantSubscription.db.findFirstRow(
            s,
            where: (t) => t.restaurantId.equals(w.tenant),
            transaction: tx,
          );
          final plans = await RestaurantPlan.db.find(
            s,
            where: (t) =>
                t.active.equals(true) & t.currency.equals(restaurant!.currency),
            limit: 100,
            transaction: tx,
          );
          return {
            'subscription': sub == null
                ? null
                : {
                    'id': sub.id,
                    'planId': sub.planId,
                    'status': sub.status,
                    'approvalUrl': sub.approvalUrl,
                    'periodEndsAt': sub.periodEndsAt?.toIso8601String(),
                    'graceEndsAt': sub.graceEndsAt?.toIso8601String(),
                  },
            'plans': plans
                .map(
                  (p) => {
                    'id': p.id,
                    'code': p.code,
                    'version': p.version,
                    'priceMinor': p.priceMinor,
                    'currency': p.currency,
                    'commissionBps': p.commissionBps,
                    'features': _json(p.featuresJson),
                  },
                )
                .toList(),
          };
        case 'notifications':
          final rows = await UserNotification.db.find(
            s,
            where: (t) =>
                t.userId.equals(w.user) &
                (t.id > cursor) &
                t.dismissedAt.equals(null),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (n) => {
                    'id': n.id,
                    'kind': n.kind,
                    'reference': _json(n.referenceJson),
                    'read': n.readAt != null,
                    'createdAt': n.createdAt.toIso8601String(),
                  },
                )
                .toList(),
          );
        case 'favorites':
          final rows = await CustomerFavorite.db.find(
            s,
            where: (t) => t.userId.equals(w.user) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'restaurantId': r.restaurantId,
                    'productId': r.productId,
                  },
                )
                .toList(),
          );
        case 'support':
          final conv = await OperationsModule.conversation(
            w,
            _int(d, 'id', min: 1),
          );
          final rows = await SupportMessage.db.find(
            s,
            where: (t) => t.conversationId.equals(conv.id!) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return {
            'status': conv.status,
            'version': conv.version,
            'subject': conv.subject,
            ...page(
              rows
                  .map(
                    (m) => {
                      'id': m.id,
                      'own': m.userId == w.user,
                      'text': m.text,
                      'mediaId': m.mediaId,
                      'createdAt': m.createdAt.toIso8601String(),
                    },
                  )
                  .toList(),
            ),
          };
        case 'ai':
          final a = await AiModule._operation(w, _int(d, 'id', min: 1));
          return {
            'id': a.id,
            'kind': a.kind,
            'status': a.status,
            'version': a.version,
            'menuVersion': a.menuVersion,
            'output': a.outputJson == null ? null : _json(a.outputJson!),
            'expiresAt': a.expiresAt.toIso8601String(),
          };
        case 'report':
          await w.role(_managers);
          final from = _date(d, 'from');
          final until = _date(d, 'until');
          if (!until.isAfter(from) || until.difference(from).inDays > 93) {
            _fail('invalid_input', 'Report range must be at most 93 days.');
          }
          final report = _str(
            d,
            'report',
            choices: {
              'orders',
              'collections',
              'refunds',
              'commission',
              'audit',
              'summary',
            },
          );
          if (report == 'summary') {
            final totals = await s.db.unsafeQuery(
              '''SELECT
              (SELECT COUNT(*) FROM raysto_order WHERE "restaurantId"=@tenant AND "createdAt">=@start AND "createdAt"<@end),
              (SELECT COUNT(*) FROM raysto_order WHERE "restaurantId"=@tenant AND "createdAt">=@start AND "createdAt"<@end AND status='completed'),
              (SELECT COALESCE(SUM("totalMinor"),0) FROM raysto_order WHERE "restaurantId"=@tenant AND "createdAt">=@start AND "createdAt"<@end AND status NOT IN ('cancelled','rejected','awaitingPayment')),
              (SELECT COALESCE(SUM("amountMinor"),0) FROM raysto_payment_capture WHERE "restaurantId"=@tenant AND "createdAt">=@start AND "createdAt"<@end AND state='completed'),
              (SELECT COALESCE(SUM("amountMinor"),0) FROM raysto_payment_refund WHERE "restaurantId"=@tenant AND "updatedAt">=@start AND "updatedAt"<@end AND state='completed'),
              (SELECT COALESCE(SUM("amountMinor"),0) FROM raysto_commission_entry WHERE "restaurantId"=@tenant AND "createdAt">=@start AND "createdAt"<@end),
              (SELECT COALESCE(SUM(GREATEST(0,b."amountMinor"-b."creditedMinor"-b."settledMinor")),0) FROM raysto_bill_charge b JOIN raysto_order o ON o.id=b."orderId" WHERE b."restaurantId"=@tenant AND o."createdAt">=@start AND o."createdAt"<@end)
            ''',
              parameters: QueryParameters.named({
                'tenant': w.tenant,
                'start': from,
                'end': until,
              }),
              transaction: tx,
            );
            final row = totals.single;
            final labels = [
              'ordersCreated',
              'completedOrders',
              'bookedSalesMinor',
              'collectionsMinor',
              'refundsMinor',
              'commissionMinor',
              'currentOutstandingMinorForOrdersInRange',
            ];
            return {
              'currency': restaurant!.currency,
              'from': from.toIso8601String(),
              'until': until.toIso8601String(),
              for (var n = 0; n < labels.length; n++)
                labels[n]: int.parse('${row[n]}'),
            };
          }
          if (report == 'orders') {
            final rows = await PurchaseOrder.db.find(
              s,
              where: (t) =>
                  t.restaurantId.equals(w.tenant) &
                  (t.id > cursor) &
                  (t.createdAt >= from) &
                  (t.createdAt < until),
              orderBy: (t) => t.id,
              limit: limit,
              transaction: tx,
            );
            return page(
              rows
                  .map(
                    (o) => {
                      'id': o.id,
                      'status': o.status,
                      'paymentStatus': o.paymentStatus,
                      'fulfillment': o.fulfillment,
                      'totalMinor': o.totalMinor,
                      'currency': o.currency,
                      'createdAt': o.createdAt.toIso8601String(),
                    },
                  )
                  .toList(),
            );
          }
          if (report == 'collections') {
            final rows = await PaymentCapture.db.find(
              s,
              where: (t) =>
                  t.restaurantId.equals(w.tenant) &
                  (t.id > cursor) &
                  (t.createdAt >= from) &
                  (t.createdAt < until),
              orderBy: (t) => t.id,
              limit: limit,
              transaction: tx,
            );
            return page(
              rows
                  .map(
                    (r) => {
                      'id': r.id,
                      'checkoutId': r.checkoutId,
                      'amountMinor': r.amountMinor,
                      'refundedMinor': r.refundedMinor,
                      'currency': r.currency,
                      'state': r.state,
                    },
                  )
                  .toList(),
            );
          }
          if (report == 'refunds') {
            final rows = await PaymentRefund.db.find(
              s,
              where: (t) =>
                  t.restaurantId.equals(w.tenant) &
                  (t.id > cursor) &
                  (t.createdAt >= from) &
                  (t.createdAt < until),
              orderBy: (t) => t.id,
              limit: limit,
              transaction: tx,
            );
            return page(
              rows
                  .map(
                    (r) => {
                      'id': r.id,
                      'captureId': r.captureId,
                      'amountMinor': r.amountMinor,
                      'state': r.state,
                      'reason': r.reason,
                    },
                  )
                  .toList(),
            );
          }
          if (report == 'commission') {
            final rows = await CommissionEntry.db.find(
              s,
              where: (t) =>
                  t.restaurantId.equals(w.tenant) &
                  (t.id > cursor) &
                  (t.createdAt >= from) &
                  (t.createdAt < until),
              orderBy: (t) => t.id,
              limit: limit,
              transaction: tx,
            );
            return page(
              rows
                  .map(
                    (r) => {
                      'id': r.id,
                      'amountMinor': r.amountMinor,
                      'currency': r.currency,
                      'state': r.state,
                    },
                  )
                  .toList(),
            );
          }
          final rows = await AuditRecord.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                (t.id > cursor) &
                (t.createdAt >= from) &
                (t.createdAt < until),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (r) => {
                    'id': r.id,
                    'kind': r.kind,
                    'entityType': r.entityType,
                    'entityId': r.entityId,
                    'at': r.createdAt.toIso8601String(),
                  },
                )
                .toList(),
          );
        case 'admin.jobs':
          await _admin(w);
          final rows = await PlatformJob.db.find(
            s,
            where: (t) => t.state.equals('dead') & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (j) => {
                    'id': j.id,
                    'restaurantId': j.restaurantId,
                    'kind': j.kind,
                    'attempts': j.attempts,
                    'lastError': j.lastError,
                  },
                )
                .toList(),
          );
        case 'admin.paymentExceptions':
          await _admin(w);
          final rows = await ProviderInbox.db.find(
            s,
            where: (t) => t.status.equals('operatorReview') & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: limit,
            transaction: tx,
          );
          return page(
            rows
                .map(
                  (i) => {
                    'id': i.id,
                    'provider': i.provider,
                    'eventId': i.eventId,
                    'eventType': i.eventType,
                    'receivedAt': i.receivedAt.toIso8601String(),
                  },
                )
                .toList(),
          );
        default:
          _fail('not_found', 'Unknown query.');
      }
    });
  }

  static Future<Json> discover(Session s, Json d, int limit, int cursor) async {
    _keys(d, {
      'q',
      'mode',
      'latitude',
      'longitude',
      'limit',
      'cursor',
      'openNow',
    });
    final q = d['q'] == null ? '' : _str(d, 'q', max: 80);
    final mode = d['mode'] == null
        ? null
        : _str(d, 'mode', choices: {'dineIn', 'pickup', 'delivery'});
    final searchIds = q.isEmpty
        ? null
        : (await s.db.unsafeQuery(
            '''SELECT r.id FROM raysto_restaurant r
         JOIN raysto_restaurant_policy policy ON policy."restaurantId"=r.id
         WHERE r.published AND NOT policy.suspended AND r.id > @cursor
         AND (to_tsvector('simple', r.name) @@ plainto_tsquery('simple', @term)
           OR EXISTS (SELECT 1 FROM raysto_menu_product m
             WHERE m."restaurantId"=r.id AND m.available
             AND to_tsvector('simple', m.name) @@ plainto_tsquery('simple', @term)))
         ORDER BY r.id LIMIT @pageSize''',
            parameters: QueryParameters.named({
              'cursor': cursor,
              'term': q,
              'pageSize': limit,
            }),
          )).map((r) => r.first as int).toSet();
    final rows = await Restaurant.db.find(
      s,
      where: (t) =>
          t.published.equals(true) &
          (t.id > cursor) &
          (searchIds == null ? Constant.bool(true) : t.id.inSet(searchIds)),
      orderBy: (t) => t.id,
      limit: limit,
    );
    final out = <Json>[];
    for (final r in rows) {
      final p = await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(r.id!),
      );
      if (p == null || p.suspended) continue;
      final settings = _json(p.settingsJson);
      if (mode != null && !(settings['modes'] as List).contains(mode)) continue;
      if (d['openNow'] == true && !CatalogueModule.openAt(settings, _now())) {
        continue;
      }
      if (mode == 'delivery' && d['latitude'] != null) {
        if (!CatalogueModule.delivers(settings, {
          'latitude': CatalogueModule.coordinate(d['latitude'], 90),
          'longitude': CatalogueModule.coordinate(d['longitude'], 180),
        })) {
          continue;
        }
      }
      out.add({
        'id': r.id,
        'name': r.name,
        'currency': r.currency,
        'modes': settings['modes'],
        'open': CatalogueModule.openAt(settings, _now()),
        'address': settings['address'],
      });
    }
    return {
      'rows': out,
      'nextCursor': rows.length == limit ? rows.last.id : null,
    };
  }

  static Future<Json> availability(Session s, Json d) async {
    _keys(d, {'restaurantId', 'startsAt', 'partySize', 'mode'});
    final id = _int(d, 'restaurantId', min: 1);
    final mode = _str(d, 'mode', choices: {'reservation', 'pickup'});
    final at = _date(d, 'startsAt');
    final r = await Restaurant.db.findById(s, id);
    final p = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(id),
    );
    if (r?.published != true || p == null || p.suspended) {
      _fail('not_found', 'Restaurant not found.');
    }
    final settings = _json(p.settingsJson);
    if (at.isBefore(_now()) ||
        at.isAfter(_now().add(const Duration(days: 90))) ||
        !CatalogueModule.openAt(settings, at)) {
      return {'available': false, 'rows': []};
    }
    if (mode == 'pickup') {
      final local = tz.TZDateTime.from(
        at,
        CatalogueModule.zone(settings['timezone'] as String),
      );
      if (local.minute % (settings['slotMinutes'] as int) != 0 ||
          at.isBefore(
            _now().add(
              Duration(minutes: settings['preparationMinutes'] as int),
            ),
          )) {
        return {'available': false};
      }
      final slot = at.toIso8601String();
      final contexts = await OrderContext.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(id) & t.slotKey.equals('pickup:$slot'),
        limit: 1000,
      );
      var used = 0;
      for (final c in contexts) {
        final o = await PurchaseOrder.db.findById(s, c.orderId);
        if (o != null && !{'cancelled', 'rejected'}.contains(o.status)) used++;
      }
      return {
        'available': used < (settings['slotCapacity'] as int),
        'remaining': max(0, (settings['slotCapacity'] as int) - used),
        'startsAt': slot,
      };
    }
    final size = _int(d, 'partySize', min: 1, max: 50);
    final end = at.add(
      Duration(minutes: settings['reservationMinutes'] as int),
    );
    final tables = await DiningTable.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(id) &
          t.active.equals(true) &
          (t.capacity >= size),
      limit: 200,
    );
    final available = <Json>[];
    for (final table in tables) {
      final reservations = await DiningReservation.db.find(
        s,
        where: (t) =>
            t.tableId.equals(table.id!) & (t.startsAt < end) & (t.endsAt > at),
        limit: 100,
      );
      if (reservations.any(
        (x) =>
            {'confirmed', 'arrived', 'seated'}.contains(x.status) ||
            x.status == 'held' && x.holdExpiresAt!.isAfter(_now()),
      )) {
        continue;
      }
      if (at.isBefore(
            _now().add(
              Duration(minutes: settings['reservationMinutes'] as int),
            ),
          ) &&
          await DiningVisit.db.findFirstRow(
                s,
                where: (t) => t.activeTableId.equals(table.id!),
              ) !=
              null) {
        continue;
      }
      available.add({'tableId': table.id, 'capacity': table.capacity});
    }
    return {
      'available': available.isNotEmpty,
      'rows': available,
      'startsAt': at.toIso8601String(),
      'endsAt': end.toIso8601String(),
      'advisory': true,
    };
  }

  static Future<Json> storefront(Session s, int id) async {
    final r = await Restaurant.db.findById(s, id);
    final p = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(id),
    );
    if (r == null || !r.published || p == null || p.suspended) {
      _fail('not_found', 'Restaurant not found.');
    }
    final items = await MenuProduct.db.find(
      s,
      where: (t) => t.restaurantId.equals(id) & t.available.equals(true),
      limit: 200,
    );
    final menu = <Json>[];
    for (final i in items) {
      final def = await MenuDefinition.db.findFirstRow(
        s,
        where: (t) => t.productId.equals(i.id!),
      );
      if (def == null || def.archived) continue;
      menu.add({
        ...Map<String, dynamic>.from(_json(def.definitionJson))
          ..remove('stockRemaining'),
        'productId': i.id,
        'name': i.name,
        'priceMinor': i.priceMinor,
        'available': i.available,
        'version': i.version,
      });
    }
    final reviews = await CustomerReview.db.find(
      s,
      where: (t) => t.restaurantId.equals(id) & t.status.equals('published'),
      orderBy: (t) => t.createdAt.desc(),
      limit: 30,
    );
    return {
      'id': id,
      'name': r.name,
      'currency': r.currency,
      'settings': {
        for (final key in [
          'address',
          'contactEmail',
          'timezone',
          'country',
          'languages',
          'modes',
          'hours',
          'holidays',
          'paused',
          'selfSeating',
          'paymentTiming',
          'deliveryFeeMinor',
          'deliveryMinimumMinor',
          'preparationMinutes',
          'slotMinutes',
          'pricesIncludeTax',
        ])
          key: _json(p.settingsJson)[key],
      },
      'menuVersion': p.menuVersion,
      'menu': menu,
      'reviews': reviews
          .map(
            (r) => {'rating': r.rating, 'text': r.text, 'response': r.response},
          )
          .toList(),
    };
  }

  static Stream<PlatformEvent> events(
    Session s,
    int restaurantId,
    int after,
  ) async* {
    // Each poll owns its session: an HTTP response may outlive its route session.
    final identity = s.authenticated;
    final bearer = s.request?.headers['authorization']?.first;
    final firebase = PlatformApi.requestHeader(s, 'x-raysto-firebase-token');
    var cursor = after;
    for (var n = 0; n < 12; n++) {
      final poll = await Serverpod.instance.createSession(enableLogging: false);
      final batch = <PlatformEvent>[];
      try {
        poll.updateAuthenticated(
          bearer != null && bearer.startsWith('Bearer ')
              ? await AuthServices.instance.tokenManager.validateToken(
                  poll,
                  bearer.substring(7),
                )
              : identity,
        );
        final actor = await _actor(poll);
        await PlatformApi.requireCurrentSession(poll);
        if (!actor.isGuest) {
          if (firebase == null) {
            _fail(
              'firebase_proof_required',
              'Current identity proof is required for live updates.',
            );
          }
          await ProviderClients.verifyIdentity(
            poll,
            firebase,
            actor.firebaseUid!,
            recent: false,
          );
        }
        if (restaurantId == 0) {
          final notifications = await UserNotification.db.find(
            poll,
            where: (t) => t.userId.equals(actor.userId) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: 100,
          );
          for (final row in notifications) {
            cursor = row.id!;
            batch.add(
              PlatformEvent(
                cursor: cursor,
                kind: 'inbox.changed',
                createdAt: row.createdAt,
              ),
            );
          }
        } else {
          await _role(poll, actor.userId, restaurantId, {
            'owner',
            'manager',
            'waiter',
            'kitchen',
            'courier',
          });
          final rows = await AuditRecord.db.find(
            poll,
            where: (t) => t.restaurantId.equals(restaurantId) & (t.id > cursor),
            orderBy: (t) => t.id,
            limit: 100,
          );
          for (final r in rows) {
            cursor = r.id!;
            batch.add(
              PlatformEvent(
                cursor: cursor,
                kind: 'snapshot.changed',
                createdAt: r.createdAt,
              ),
            );
          }
        }
        if (batch.isEmpty) {
          batch.add(
            PlatformEvent(
              cursor: cursor,
              kind: 'heartbeat',
              createdAt: _now(),
            ),
          );
        }
      } finally {
        await poll.close();
      }
      for (final event in batch) {
        yield event;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
