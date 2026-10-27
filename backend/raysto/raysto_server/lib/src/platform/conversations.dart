part of 'platform.dart';

/// Room membership is derived from current business permissions on every read,
/// write and stream poll. RoomMember holds preferences/cursors, never authority.
class ConversationModule {
  static void enabled() {
    if (Platform.environment['RAYSTO_ROOMS_ENABLED'] != 'true') {
      _fail('not_enabled', 'Table conversations are not enabled yet.');
    }
  }

  static Future<ConversationRoom> room(
    Work w,
    int id, {
    bool write = false,
  }) async {
    enabled();
    final r = await ConversationRoom.db.findById(w.s, id, transaction: w.tx);
    if (r == null || r.restaurantId != w.tenant) {
      _fail('not_found', 'Conversation not found.');
    }
    if (r.visitId != null) {
      final v = await DiningModule._visit(w, r.visitId!);
      await _visitAccess(w, v);
      if (write && v.status != 'active') {
        _fail(
          'room_closed',
          'This visit is closed. Use private help for follow-up.',
        );
      }
    } else {
      final o = await PurchaseOrder.db.findById(
        w.s,
        r.orderId!,
        transaction: w.tx,
      );
      if (o == null) _fail('not_found', 'Order not found.');
      await _orderAccess(w, o);
      if (write && {'completed', 'cancelled', 'rejected'}.contains(o.status)) {
        _fail(
          'room_closed',
          'This order is closed. Use private help for follow-up.',
        );
      }
    }
    return r;
  }

  static Future<List<String>> diners(Work w, ConversationRoom r) async {
    if (r.visitId == null) {
      final o = await PurchaseOrder.db.findById(
        w.s,
        r.orderId!,
        transaction: w.tx,
      );
      return o == null ? [] : [o.customerId];
    }
    return (await VisitParticipant.db.find(
      w.s,
      where: (t) => t.visitId.equals(r.visitId!) & t.active.equals(true),
      orderBy: (t) => t.id,
      limit: 100,
      transaction: w.tx,
    )).map((p) => p.userId).toList();
  }

  static Future<void> synchronize(Work w, ConversationRoom r) async {
    final people = await diners(w, r);
    var changed = false;
    if (!r.hostEverAssigned && people.isNotEmpty) {
      r.hostUserId = people.firstOrNull;
      r.hostEverAssigned = true;
      changed = true;
    } else if (r.hostUserId != null && !people.contains(r.hostUserId)) {
      r.hostUserId = null;
      changed = true;
    }
    if (r.visitId != null) {
      final v = await DiningModule._visit(w, r.visitId!);
      final t = await DiningTable.db.findById(
        w.s,
        v.tableId,
        transaction: w.tx,
      );
      final assigned = t?.assignedWaiterId;
      final activeWaiter = assigned == null
          ? null
          : await Membership.db.findFirstRow(
              w.s,
              where: (m) =>
                  m.restaurantId.equals(w.tenant) &
                  m.userId.equals(assigned) &
                  m.active.equals(true) &
                  m.role.inSet({'owner', 'manager', 'waiter'}),
              transaction: w.tx,
            );
      final waiter = activeWaiter?.userId;
      if (waiter != r.waiterUserId) {
        r.waiterUserId = waiter;
        changed = true;
        await append(w, r, 'staff.changed', {
          'text': waiter == null
              ? 'Requests go to the restaurant service queue.'
              : 'Your assigned waiter changed. Current staff can see this visit’s service history.',
          'waiterUserId': waiter,
        });
      }
    }
    if (changed) {
      r.version++;
      await ConversationRoom.db.updateRow(w.s, r, transaction: w.tx);
    }
  }

  static Future<Json> open(Session s, PlatformCommand c) =>
      _mutate(s, c, 'room.open', (w, d) async {
        enabled();
        _keys(d, {'visitId', 'orderId'});
        if ((d['visitId'] == null) == (d['orderId'] == null)) {
          _fail('invalid_input', 'Choose one visit or order.');
        }
        int? visitId;
        int? orderId;
        if (d['visitId'] != null) {
          visitId = _int(d, 'visitId', min: 1);
          await _visitAccess(w, await DiningModule._visit(w, visitId));
        } else {
          orderId = _int(d, 'orderId', min: 1);
          final o = await PurchaseOrder.db.findById(
            s,
            orderId,
            transaction: w.tx,
          );
          if (o == null) _fail('not_found', 'Order not found.');
          await _orderAccess(w, o);
          final context = await OrderContext.db.findFirstRow(
            s,
            where: (t) => t.orderId.equals(orderId!),
            transaction: w.tx,
          );
          if (context?.visitId != null) {
            visitId = context!.visitId;
            orderId = null;
          }
        }
        final key = visitId != null ? 'visit:$visitId' : 'order:$orderId';
        var r = await ConversationRoom.db.findFirstRow(
          s,
          where: (t) => t.contextKey.equals(key),
          transaction: w.tx,
        );
        r ??= await ConversationRoom.db.insertRow(
          s,
          ConversationRoom(
            restaurantId: w.tenant,
            contextKey: key,
            visitId: visitId,
            orderId: orderId,
            sequence: 0,
            version: 1,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await room(w, r.id!);
        await synchronize(w, r);
        await member(w, r);
        return {'roomId': r.id, 'restaurantId': w.tenant};
      });

  static Future<RoomMember> member(Work w, ConversationRoom r) async {
    final existing = await RoomMember.db.findFirstRow(
      w.s,
      where: (t) => t.roomId.equals(r.id!) & t.userId.equals(w.user),
      transaction: w.tx,
    );
    return existing ??
        await RoomMember.db.insertRow(
          w.s,
          RoomMember(
            restaurantId: w.tenant,
            roomId: r.id!,
            userId: w.user,
            lastReadSequence: 0,
            preferencesJson: '{}',
            muted: false,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
  }

  static Future<RoomMessage> append(
    Work w,
    ConversationRoom r,
    String kind,
    Json body, {
    String? user,
    String? clientId,
    int? replyTo,
    bool notify = true,
  }) async {
    r.sequence++;
    await ConversationRoom.db.updateRow(w.s, r, transaction: w.tx);
    final row = await RoomMessage.db.insertRow(
      w.s,
      RoomMessage(
        restaurantId: w.tenant,
        roomId: r.id!,
        sequence: r.sequence,
        userId: user,
        clientMessageId: clientId,
        replyToId: replyTo,
        kind: kind,
        bodyJson: jsonEncode(body),
        createdAt: _now(),
      ),
      transaction: w.tx,
    );
    if (notify) {
      final targets = {
        ...await diners(w, r),
        if (r.waiterUserId != null) r.waiterUserId!,
      };
      for (final target in targets) {
        if (target == user) continue;
        final pref = await RoomMember.db.findFirstRow(
          w.s,
          where: (t) => t.roomId.equals(r.id!) & t.userId.equals(target),
          transaction: w.tx,
        );
        if (pref?.muted == true) continue;
        await w.notify(target, 'room.updated', {
          'roomId': r.id,
        }, 'room:${r.id}:${row.sequence}');
      }
    }
    return row;
  }

  static Json messageView(RoomMessage m) => {
    'id': m.id,
    'sequence': m.sequence,
    'kind': m.kind,
    'userId': m.userId,
    'clientMessageId': m.clientMessageId,
    'replyToId': m.replyToId,
    'body': _json(m.bodyJson),
    'createdAt': m.createdAt.toIso8601String(),
  };

  static Future<Json> send(Session s, PlatformCommand c) =>
      _mutate(s, c, 'room.message', (w, d) async {
        _keys(d, {'text', 'clientMessageId', 'replyToId'});
        final r = await room(w, _id(c), write: true);
        await synchronize(w, r);
        if (w.settings['customerChatEnabled'] == false &&
            (await diners(w, r)).contains(w.user)) {
          _fail(
            'chat_disabled',
            'This restaurant accepts structured service requests only.',
          );
        }
        final text = _str(d, 'text', max: 2000);
        final key = _str(d, 'clientMessageId', max: 100);
        final replyTo = d['replyToId'] == null
            ? null
            : _int(d, 'replyToId', min: 1);
        final old = await RoomMessage.db.findFirstRow(
          s,
          where: (t) =>
              t.roomId.equals(r.id!) &
              t.userId.equals(w.user) &
              t.clientMessageId.equals(key),
          transaction: w.tx,
        );
        if (old != null) {
          if (_json(old.bodyJson)['text'] != text || old.replyToId != replyTo) {
            _fail(
              'idempotency_conflict',
              'This message ID has different content.',
            );
          }
          return messageView(old);
        }
        if (replyTo != null) {
          final target = await RoomMessage.db.findById(
            s,
            replyTo,
            transaction: w.tx,
          );
          if (target == null || target.roomId != r.id) {
            _fail('not_found', 'Reply target not found.');
          }
        }
        await _rate(s, 'room-send:${w.user}', 30, w.tx);
        return messageView(
          await append(
            w,
            r,
            'message',
            {'text': text},
            user: w.user,
            clientId: key,
            replyTo: replyTo,
          ),
        );
      });

  static Future<Json> read(Session s, PlatformCommand c) =>
      _mutate(s, c, 'room.read', (w, d) async {
        _keys(d, {'sequence'});
        final r = await room(w, _id(c));
        final m = await member(w, r);
        m.lastReadSequence = max(
          m.lastReadSequence,
          _int(d, 'sequence', max: r.sequence),
        );
        await RoomMember.db.updateRow(s, m, transaction: w.tx);
        return {'sequence': m.lastReadSequence};
      });

  static Future<Json> preferences(Session s, PlatformCommand c) =>
      _mutate(s, c, 'room.preferences', (w, d) async {
        _keys(d, {'preferences', 'budgetMinor', 'shareWithTable', 'muted'});
        final r = await room(w, _id(c), write: true);
        final m = await member(w, r);
        m.preferencesJson = jsonEncode({
          'preferences': _list(
            d,
            'preferences',
            max: 12,
          ).map((v) => _str({'v': v}, 'v', max: 120)).toList(),
          if (d['budgetMinor'] != null)
            'budgetMinor': _int(d, 'budgetMinor', min: 1),
          'shareWithTable': _bool(d, 'shareWithTable'),
        });
        m.muted = _bool(d, 'muted');
        await RoomMember.db.updateRow(s, m, transaction: w.tx);
        r.version++;
        await ConversationRoom.db.updateRow(s, r, transaction: w.tx);
        await append(w, r, 'preferences.changed', {
          'text': 'Table preferences were updated.',
        }, notify: false);
        return {'version': r.version};
      });

  static Future<Json> host(Session s, PlatformCommand c) =>
      _mutate(s, c, 'room.host', (w, d) async {
        _keys(d, {'userId'});
        final r = await room(w, _id(c), write: true);
        _version(r.version, c.expectedVersion);
        if (r.hostUserId != w.user) {
          if (r.visitId != null) {
            await _visitAccess(
              w,
              await DiningModule._visit(w, r.visitId!),
              staffOnly: true,
            );
          } else {
            await w.role(_managers);
          }
        }
        final target = _str(d, 'userId', max: 100);
        if (!(await diners(w, r)).contains(target)) {
          _fail('invalid_input', 'Choose an admitted diner.');
        }
        r.hostUserId = target;
        r.hostEverAssigned = true;
        r.version++;
        await ConversationRoom.db.updateRow(s, r, transaction: w.tx);
        await append(w, r, 'host.changed', {
          'userId': target,
          'text': 'The table host changed.',
        });
        return {'version': r.version};
      });

  static Future<Json> report(Session s, PlatformCommand c) =>
      _mutate(s, c, 'room.report', (w, d) async {
        _keys(d, {'messageId', 'reason'});
        final r = await room(w, _id(c));
        final m = await RoomMessage.db.findById(
          s,
          _int(d, 'messageId', min: 1),
          transaction: w.tx,
        );
        if (m?.roomId != r.id) _fail('not_found', 'Message not found.');
        final reason = _str(d, 'reason', max: 500);
        final ticket = await SupportConversation.db.insertRow(
          s,
          SupportConversation(
            restaurantId: w.tenant,
            userId: w.user,
            status: 'open',
            subject: 'Conversation report',
            escalated: true,
            version: 1,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await SupportMessage.db.insertRow(
          s,
          SupportMessage(
            conversationId: ticket.id!,
            userId: w.user,
            text: 'Room ${r.id}, message ${m!.id}: $reason',
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        final managers = await Membership.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              t.active.equals(true) &
              t.role.inSet(_managers),
          transaction: w.tx,
          limit: 100,
        );
        for (final manager in managers) {
          await w.notify(manager.userId, 'support.reported', {
            'conversationId': ticket.id,
          }, 'report:${ticket.id}:${manager.userId}');
        }
        await w.audit('room.reported', 'conversation', ticket.id, {
          'roomId': r.id,
          'messageId': m.id,
        });
        return {'reported': true, 'conversationId': ticket.id};
      });

  static Future<Json> snapshot(Work w, Json d) async {
    final r = await room(w, _int(d, 'id', min: 1));
    final before = _int(
      d,
      'before',
      max: 9007199254740991,
      fallback: 9007199254740991,
    );
    final messages = await RoomMessage.db.find(
      w.s,
      where: (t) => t.roomId.equals(r.id!) & (t.sequence < before),
      orderBy: (t) => t.sequence.desc(),
      limit: 50,
      transaction: w.tx,
    );
    final members = <Json>[];
    final people = await diners(w, r);
    final waiter = r.visitId == null
        ? null
        : (await DiningTable.db.findById(
            w.s,
            (await DiningModule._visit(w, r.visitId!)).tableId,
            transaction: w.tx,
          ))?.assignedWaiterId;
    for (final user in {...people, ?waiter}) {
      final profile = await ActorProfile.db.findFirstRow(
        w.s,
        where: (t) => t.userId.equals(user),
        transaction: w.tx,
      );
      final m = await RoomMember.db.findFirstRow(
        w.s,
        where: (t) => t.roomId.equals(r.id!) & t.userId.equals(user),
        transaction: w.tx,
      );
      final pref = m == null ? <String, dynamic>{} : _json(m.preferencesJson);
      members.add({
        'userId': user,
        'name': profile == null
            ? 'Guest'
            : _json(profile.dataJson)['displayName'] ?? 'Guest',
        'role': user == waiter
            ? 'waiter'
            : user == r.hostUserId
            ? 'host'
            : 'diner',
        'lastReadSequence': m?.lastReadSequence ?? 0,
        if (user == w.user || pref['shareWithTable'] == true)
          'preferences': pref,
      });
    }
    final me = await RoomMember.db.findFirstRow(
      w.s,
      where: (t) => t.roomId.equals(r.id!) & t.userId.equals(w.user),
      transaction: w.tx,
    );
    final closed = r.visitId != null
        ? (await DiningModule._visit(w, r.visitId!)).status != 'active'
        : {'completed', 'cancelled', 'rejected'}.contains(
            (await PurchaseOrder.db.findById(
              w.s,
              r.orderId!,
              transaction: w.tx,
            ))!.status,
          );
    final visibleMessages = <Json>[];
    for (final message in messages.reversed) {
      if (me?.muted == true && message.kind == 'assistant.suggestion') continue;
      final view = messageView(message);
      final body = _object(view['body']);
      if (body['proposal'] is Map) {
        final proposal = await AssistantProposal.db.findById(
          w.s,
          _int(_object(body['proposal']), 'id', min: 1),
          transaction: w.tx,
        );
        if (proposal != null && proposal.roomId == r.id) {
          body['proposal'] = AssistantModule.proposalView(proposal);
        }
      }
      visibleMessages.add({...view, 'body': body});
    }
    return {
      'id': r.id,
      'restaurantId': w.tenant,
      'visitId': r.visitId,
      'orderId': r.orderId,
      'currency': w.restaurant!.currency,
      'hostUserId': r.hostUserId,
      'staffDisclosure':
          'Restaurant managers may access this room for service. Private help stays separate.',
      'lastReadSequence': me?.lastReadSequence ?? 0,
      'currentUserId': w.user,
      'audience': r.visitId == null
          ? 'You and restaurant support'
          : 'Everyone at this table + your waiter',
      'aiDisclosure':
          'Ask Raysto shares this room’s selected context and shared preferences with AI. Private help stays separate.',
      'version': r.version,
      'sequence': r.sequence,
      'closed': closed,
      'members': members,
      'muted': me?.muted ?? false,
      'myPreferences': me == null ? {} : _json(me.preferencesJson),
      'messages': visibleMessages,
      'beforeCursor': messages.length == 50 ? messages.last.sequence : null,
    };
  }

  /// Audit hooks publish only safe entity references, never private audit details.
  static Future<void> suggest(
    Work w,
    ConversationRoom r,
    String key,
    String text,
    String prompt,
  ) async {
    final exists = await RoomMessage.db.findFirstRow(
      w.s,
      where: (t) =>
          t.roomId.equals(r.id!) & t.clientMessageId.equals('suggestion:$key'),
      transaction: w.tx,
    );
    if (exists != null) return;
    await append(
      w,
      r,
      'assistant.suggestion',
      {'text': text, 'prompt': prompt},
      clientId: 'suggestion:$key',
      notify: false,
    );
  }

  static Future<void> businessEvent(
    Work w,
    String kind,
    String type,
    int? id,
  ) async {
    if (Platform.environment['RAYSTO_ROOMS_ENABLED'] != 'true' ||
        id == null ||
        w.restaurant == null) {
      return;
    }
    int? visitId;
    int? orderId;
    final activity = <String, dynamic>{};
    if (kind == 'menu.availability' && type == 'product') {
      final product = await MenuProduct.db.findById(w.s, id, transaction: w.tx);
      if (product?.available != false) return;
      final proposals = await AssistantProposal.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.kind.equals('basket') &
            t.status.inSet({'review', 'approved'}) &
            (t.expiresAt > _now()),
        limit: 200,
        transaction: w.tx,
      );
      for (final proposal in proposals) {
        final input = _object(_json(proposal.payloadJson)['input'] ?? {});
        if (!(input['lines'] as List? ?? []).any((l) => l['productId'] == id)) {
          continue;
        }
        proposal.status = 'stale';
        proposal.version++;
        await AssistantProposal.db.updateRow(w.s, proposal, transaction: w.tx);
        final r = proposal.roomId == null
            ? null
            : await ConversationRoom.db.findById(
                w.s,
                proposal.roomId!,
                transaction: w.tx,
              );
        if (r != null) {
          await suggest(
            w,
            r,
            'unavailable:${proposal.id}',
            'An item in an unsubmitted proposal is unavailable. Review a replacement before ordering.',
            'Review our latest basket, explain which item is unavailable, and suggest an available replacement within our shared budget.',
          );
        }
      }
      return;
    }
    if (type == 'visit') visitId = id;
    if (type == 'proposal') {
      final p = await AssistantProposal.db.findById(w.s, id, transaction: w.tx);
      final r = p?.roomId == null
          ? null
          : await ConversationRoom.db.findById(
              w.s,
              p!.roomId!,
              transaction: w.tx,
            );
      visitId = r?.visitId;
      orderId = r?.orderId;
    }
    if (type == 'order') orderId = id;
    if (type == 'serviceRequest') {
      final service = await VisitRequest.db.findById(
        w.s,
        id,
        transaction: w.tx,
      );
      visitId = service?.visitId;
      if (service != null) {
        activity.addAll({
          'serviceKind': service.kind,
          'status': service.status,
        });
      }
    }
    if (type == 'checkout' || type == 'capture' || type == 'refund') {
      int? checkoutId = type == 'checkout' ? id : null;
      if (type == 'capture') {
        checkoutId = (await PaymentCapture.db.findById(
          w.s,
          id,
          transaction: w.tx,
        ))?.checkoutId;
      }
      if (type == 'refund') {
        final f = await PaymentRefund.db.findById(w.s, id, transaction: w.tx);
        if (f != null) {
          checkoutId = (await PaymentCapture.db.findById(
            w.s,
            f.captureId,
            transaction: w.tx,
          ))?.checkoutId;
        }
      }
      final i = checkoutId == null
          ? null
          : await CheckoutIntent.db.findById(
              w.s,
              checkoutId,
              transaction: w.tx,
            );
      visitId = i?.visitId;
      orderId = i?.orderId;
      // Shared activity contains no payer identity, provider IDs or approval URL.
      if (i != null && type != 'refund') {
        activity.addAll({
          'amountMinor': i.amountMinor,
          'currency': i.currency,
          'status': i.state,
        });
      }
    }
    if (orderId != null) {
      visitId ??= (await OrderContext.db.findFirstRow(
        w.s,
        where: (t) => t.orderId.equals(orderId!),
        transaction: w.tx,
      ))?.visitId;
    }
    if (visitId == null && orderId == null && type != 'table') return;
    final rooms = await ConversationRoom.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (type == 'table'
              ? Constant.bool(true)
              : visitId != null
              ? t.visitId.equals(visitId)
              : t.orderId.equals(orderId)),
      limit: 200,
      transaction: w.tx,
    );
    for (final r in rooms) {
      if (type == 'table') {
        if (r.visitId == null ||
            (await DiningModule._visit(w, r.visitId!)).tableId != id) {
          continue;
        }
      }
      await synchronize(w, r);
      await append(w, r, 'activity', {
        'event': kind,
        'entityType': type,
        'entityId': id,
        ...activity,
      }, notify: false);
      if (kind == 'service.sent' && type == 'serviceRequest') {
        final request = await VisitRequest.db.findById(
          w.s,
          id,
          transaction: w.tx,
        );
        if (request?.kind == 'bill') {
          await suggest(
            w,
            r,
            'bill:$id',
            'Ready to settle? Raysto can explain the remaining bill or prepare your share.',
            'What remains unpaid at our table? Explain the available ways to split it.',
          );
        }
      }
      if (kind == 'payment.uncertain') {
        await suggest(
          w,
          r,
          'payment:$id',
          'A payment is still being checked. Keep its existing checkout while Raysto reconciles it.',
          'Check my latest payment status and explain whether I should wait or continue the existing checkout.',
        );
      }
    }
  }

  static Stream<Json> events(
    Session original,
    int tenant,
    int id,
    int after,
  ) async* {
    final identity = original.authenticated;
    final proof = {
      for (final name in ['x-raysto-firebase-token', 'x-firebase-appcheck'])
        if (PlatformApi.requestHeader(original, name) != null)
          name: PlatformApi.requestHeader(original, name)!,
    };
    var cursor = after;
    for (var tick = 0; tick < 25; tick++) {
      final s = await Serverpod.instance.createSession(enableLogging: false);
      Json batch;
      try {
        s.updateAuthenticated(identity);
        PlatformApi.bindHttpHeaders(s, proof);
        batch = await PlatformQueries.query(s, 'room.events', {
          'restaurantId': tenant,
          'id': id,
          'after': cursor,
        });
      } on DomainError catch (e) {
        yield {'kind': 'access.error', 'code': e.code};
        return;
      } finally {
        await s.close();
      }
      cursor = batch['cursor'] as int;
      yield {'kind': 'room.events', ...batch};
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  static Future<Json> eventPage(Work w, Json d) async {
    final r = await room(w, _int(d, 'id', min: 1));
    final after = _int(d, 'after', max: 9007199254740991, fallback: 0);
    if (after > r.sequence) {
      return {'cursor': r.sequence, 'reset': true, 'events': []};
    }
    final rows = await RoomMessage.db.find(
      w.s,
      where: (t) => t.roomId.equals(r.id!) & (t.sequence > after),
      orderBy: (t) => t.sequence,
      limit: 100,
      transaction: w.tx,
    );
    return {
      'cursor': rows.isEmpty ? after : rows.last.sequence,
      'events': rows.map(messageView).toList(),
    };
  }
}
