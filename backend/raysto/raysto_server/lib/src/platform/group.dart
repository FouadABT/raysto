part of 'platform.dart';

/// Franchise groups: several restaurants under one owner (plan section 2).
///
/// Isolation: group roles (owner, areaManager, accountant) only read. Every
/// command that changes a restaurant still runs per venue through `_mutate`
/// with a real venue membership. A group accountant gets an explicit,
/// revocable `Membership(role: accountant)` in each venue, so money is never
/// reached through the group alone. Group reads look at venue rows directly,
/// filtered by the venue ids the group holds, and only after the caller's
/// group role is checked; no venue context ever reaches command code.
class GroupModule {
  static const roles = {'owner', 'areaManager', 'accountant'};
  static const memberRoles = {'areaManager', 'accountant'};
  static const maxVenues = 12;

  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'group.create': create,
    'group.attach': attach,
    'group.detach': detach,
    'group.member.invite': invite,
    'group.member.accept': accept,
    'group.member.revoke': revoke,
    'group.template.save': saveTemplate,
    'group.template.push': pushTemplate,
    'stock.transfer': transfer,
  };

  // ---------------------------------------------------------------- commands

  /// A new group; its creator is its owner. Venues join with `group.attach`.
  static Future<Json> create(Session s, PlatformCommand c) =>
      _mutate(s, c, 'group.create', (w, d) async {
        _keys(d, {'name', 'currency'});
        if (c.restaurantId != null) {
          _fail('invalid_input', 'A group is created without a restaurant.');
        }
        final group = await RestaurantGroup.db.insertRow(
          s,
          RestaurantGroup(
            name: _str(d, 'name', max: 120),
            ownerUserId: w.user,
            currency: _str(d, 'currency', choices: {'EUR', 'USD', 'GBP'}),
            version: 1,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        await GroupMembership.db.insertRow(
          s,
          GroupMembership(
            groupId: group.id!,
            userId: w.user,
            role: 'owner',
            active: true,
            version: 1,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.audit('group.created', 'group', group.id);
        return {'groupId': group.id, 'version': group.version};
      }, registered: true);

  /// Puts a venue in a group. The caller owns the venue (checked by `_mutate`)
  /// and the group (checked here, with the group row locked).
  static Future<Json> attach(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'group.attach',
    (w, d) async {
      _keys(d, {'groupId'});
      final group = await _ownedGroup(w, _int(d, 'groupId', min: 1));
      final elsewhere = await GroupVenue.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      if (elsewhere != null) {
        _fail(
          elsewhere.groupId == group.id ? 'conflict' : 'forbidden',
          elsewhere.groupId == group.id
              ? 'This restaurant is already in the group.'
              : 'This restaurant belongs to another group.',
        );
      }
      final count = await GroupVenue.db.count(
        s,
        where: (t) => t.groupId.equals(group.id!),
        transaction: w.tx,
      );
      if (count >= maxVenues) {
        _fail('limit_reached', 'A group holds at most $maxVenues restaurants.');
      }
      await GroupVenue.db.insertRow(
        s,
        GroupVenue(
          groupId: group.id!,
          restaurantId: w.tenant,
          attachedBy: w.user,
          attachedAt: _now(),
        ),
        transaction: w.tx,
      );
      // Group accountants already in the group get this venue's books too.
      for (final m in await _members(w, group.id!, {'accountant'})) {
        await _grantVenue(w, w.tenant, m.userId);
      }
      await _bump(w, group);
      await w.audit('group.attached', 'group', group.id, {'groupId': group.id});
      return {'groupId': group.id, 'restaurantId': w.tenant};
    },
    roles: {'owner'},
  );

  /// Takes a venue out of its group. Group accountants lose this venue's
  /// accountant membership; the venue's own team is untouched.
  static Future<Json> detach(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'group.detach',
    (w, d) async {
      _keys(d, {'groupId'});
      final group = await _ownedGroup(w, _int(d, 'groupId', min: 1));
      final link = await GroupVenue.db.findFirstRow(
        s,
        where: (t) =>
            t.groupId.equals(group.id!) & t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      if (link == null) _fail('not_found', 'This restaurant is not in the group.');
      await GroupVenue.db.deleteRow(s, link, transaction: w.tx);
      for (final m in await _members(w, group.id!, {'accountant'})) {
        await _revokeVenue(w, w.tenant, m.userId);
      }
      await _bump(w, group);
      await w.audit('group.detached', 'group', group.id, {'groupId': group.id});
      return {'groupId': group.id, 'restaurantId': w.tenant};
    },
    roles: {'owner'},
  );

  /// Invites someone into the group as area manager (reads only) or
  /// accountant (reads plus an accountant membership in each venue, granted
  /// when they accept). Owner only, after an identity check.
  static Future<Json> invite(Session s, PlatformCommand c) =>
      _mutate(s, c, 'group.member.invite', (w, d) async {
        _keys(d, {'groupId', 'email', 'role'});
        final group = await _ownedGroup(w, _int(d, 'groupId', min: 1));
        await _stepUp(w);
        final role = _str(d, 'role', choices: memberRoles);
        final email = _str(d, 'email', max: 254).toLowerCase();
        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
          _fail('invalid_input', 'Invalid email.');
        }
        final venues = await venueIds(w, group.id!);
        if (venues.isEmpty) {
          _fail('invalid_input', 'Attach a restaurant to the group first.');
        }
        final token = _secret();
        final invitation = await AccessInvitation.db.insertRow(
          s,
          AccessInvitation(
            // The table needs a restaurant; the group's first venue anchors it.
            restaurantId: venues.first,
            kind: 'group',
            targetId: group.id!,
            tokenHash: _hash(token),
            createdBy: w.user,
            recipientEmail: email,
            role: role,
            expiresAt: _now().add(const Duration(days: 3)),
            usesRemaining: 1,
            revoked: false,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.job('email.invitation', 'invite:${invitation.id}', {
          'invitationId': invitation.id,
          'token': token,
        });
        await w.audit('group.invited', 'invitation', invitation.id, {
          'groupId': group.id,
          'role': role,
        });
        return {
          'id': invitation.id,
          'invitationCode': token,
          'groupId': group.id,
          'role': role,
          'expiresAt': invitation.expiresAt.toIso8601String(),
        };
      }, registered: true);

  /// The invited person, signed in with the invited verified email, joins.
  static Future<Json> accept(Session s, PlatformCommand c) =>
      _mutate(s, c, 'group.member.accept', (w, d) async {
        _keys(d, {'token'});
        final i = await AccessInvitation.db.findFirstRow(
          s,
          where: (t) => t.tokenHash.equals(_hash(_str(d, 'token', max: 100))),
          transaction: w.tx,
          lockMode: LockMode.forUpdate,
        );
        if (i == null ||
            i.kind != 'group' ||
            i.revoked ||
            i.usesRemaining < 1 ||
            !i.expiresAt.isAfter(_now())) {
          _fail('invalid_invitation', 'Invitation expired or unavailable.');
        }
        final account = await AuthServices.instance.firebaseIdp.admin
            .findAccountByAuthUserId(s, authUserId: UuidValue.fromString(w.user));
        if (account?.email?.toLowerCase() != i.recipientEmail) {
          _fail('forbidden', 'Sign in with the invited verified email.');
        }
        final group = await RestaurantGroup.db.findById(
          s,
          i.targetId,
          transaction: w.tx,
          lockMode: LockMode.forUpdate,
        );
        if (group == null || group.ownerUserId != i.createdBy) {
          _fail('invalid_invitation', 'Invitation issuer no longer owns the group.');
        }
        await grant(w, group.id!, w.user, i.role!);
        i.usesRemaining = 0;
        await AccessInvitation.db.updateRow(s, i, transaction: w.tx);
        return {'groupId': group.id, 'role': i.role};
      }, registered: true);

  /// Ends a member's place in the group, and for an accountant the
  /// accountant memberships the group gave them. Owner only.
  static Future<Json> revoke(Session s, PlatformCommand c) =>
      _mutate(s, c, 'group.member.revoke', (w, d) async {
        _keys(d, {'groupId', 'userId'});
        final group = await _ownedGroup(w, _int(d, 'groupId', min: 1));
        final userId = _str(d, 'userId', max: 100);
        final m = await GroupMembership.db.findFirstRow(
          s,
          where: (t) => t.groupId.equals(group.id!) & t.userId.equals(userId),
          transaction: w.tx,
        );
        if (m == null || !m.active) _fail('not_found', 'Member not found.');
        if (m.role == 'owner') _fail('forbidden', 'The owner cannot be removed.');
        m
          ..active = false
          ..version += 1;
        await GroupMembership.db.updateRow(s, m, transaction: w.tx);
        if (m.role == 'accountant') {
          for (final venue in await venueIds(w, group.id!)) {
            await _revokeVenue(w, venue, userId);
          }
        }
        await w.audit('group.member_revoked', 'group', group.id, {
          'groupId': group.id,
          'role': m.role,
        });
        return {'groupId': group.id, 'userId': userId, 'active': false};
      }, registered: true);

  /// Saves a menu template the group can push to its venues as proposals.
  static Future<Json> saveTemplate(Session s, PlatformCommand c) =>
      _mutate(s, c, 'group.template.save', (w, d) async {
        _keys(d, {'groupId', 'name', 'items'});
        final group = await _ownedGroup(w, _int(d, 'groupId', min: 1));
        final items = _list(d, 'items', max: 200)
            // A template names dishes, not one venue's product ids.
            .map((v) => {...CatalogueModule.validateItem(_object(v))}..remove('productId'))
            .toList();
        if (items.isEmpty) _fail('invalid_input', 'A template needs dishes.');
        final name = _str(d, 'name', max: 120);
        MenuTemplate row;
        if (c.resourceId == null) {
          row = await MenuTemplate.db.insertRow(
            s,
            MenuTemplate(
              groupId: group.id!,
              name: name,
              itemsJson: jsonEncode(items),
              createdBy: w.user,
              version: 1,
              createdAt: _now(),
              updatedAt: _now(),
            ),
            transaction: w.tx,
          );
        } else {
          row =
              await MenuTemplate.db.findById(s, _id(c), transaction: w.tx) ??
              _fail('not_found', 'Template not found.');
          if (row.groupId != group.id) _fail('not_found', 'Template not found.');
          _version(row.version, c.expectedVersion);
          row
            ..name = name
            ..itemsJson = jsonEncode(items)
            ..version += 1
            ..updatedAt = _now();
          await MenuTemplate.db.updateRow(s, row, transaction: w.tx);
        }
        await w.audit('group.template_saved', 'menuTemplate', row.id, {
          'groupId': group.id,
        });
        return {'templateId': row.id, 'version': row.version};
      }, registered: true);

  /// Sends a template to every venue as a menu draft. Nothing changes on a
  /// menu until that venue's own manager publishes the draft through the
  /// usual path, so group prices are proposals, never forced.
  static Future<Json> pushTemplate(Session s, PlatformCommand c) =>
      _mutate(s, c, 'group.template.push', (w, d) async {
        _keys(d, {'groupId', 'templateId'});
        final group = await _ownedGroup(w, _int(d, 'groupId', min: 1));
        final template = await MenuTemplate.db.findById(
          s,
          _int(d, 'templateId', min: 1),
          transaction: w.tx,
        );
        if (template == null || template.groupId != group.id) {
          _fail('not_found', 'Template not found.');
        }
        final drafts = <Json>[];
        for (final venue in await venueIds(w, group.id!)) {
          final policy = await RestaurantPolicy.db.findFirstRow(
            s,
            where: (t) => t.restaurantId.equals(venue),
            transaction: w.tx,
          );
          if (policy == null) continue;
          final draft = await MenuDraft.db.insertRow(
            s,
            MenuDraft(
              restaurantId: venue,
              userId: w.user,
              itemsJson: template.itemsJson,
              baseMenuVersion: policy.menuVersion,
              version: 1,
              status: 'draft',
              createdAt: _now(),
            ),
            transaction: w.tx,
          );
          await _venueAudit(w, venue, 'group.template_pushed', 'menuDraft', draft.id, {
            'groupId': group.id,
            'templateId': template.id,
          });
          drafts.add({'restaurantId': venue, 'draftId': draft.id});
        }
        return {'templateId': template.id, 'drafts': drafts};
      }, registered: true);

  /// Moves stock from this venue to another venue of the same group. The
  /// caller manages both venues; two movements share one transfer id.
  static Future<Json> transfer(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'stock.transfer',
    (w, d) async {
      _keys(d, {'toRestaurantId', 'stockItemId', 'quantity'});
      final to = _int(d, 'toRestaurantId', min: 1, max: 1 << 31);
      if (to == w.tenant) _fail('invalid_input', 'Choose another restaurant.');
      await _role(s, w.user, to, _managers, tx: w.tx);
      final from = await GroupVenue.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      final dest = await GroupVenue.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(to),
        transaction: w.tx,
      );
      if (from == null || dest == null || from.groupId != dest.groupId) {
        _fail('forbidden', 'Both restaurants must be in the same group.');
      }
      final quantity = (d['quantity'] is num)
          ? (d['quantity'] as num).toDouble()
          : _fail('invalid_input', 'Invalid quantity.');
      if (quantity <= 0 || quantity > 100000) {
        _fail('invalid_input', 'Invalid quantity.');
      }
      final item = await StockItem.db.findById(
        s,
        _int(d, 'stockItemId', min: 1, max: 1 << 31),
        transaction: w.tx,
        lockMode: LockMode.forUpdate,
      );
      if (item == null || item.restaurantId != w.tenant) {
        _fail('not_found', 'Stock item not found.');
      }
      if (item.quantity < quantity) {
        _fail('invalid_input', 'Only ${item.quantity} ${item.unit} in stock.');
      }
      var target = await StockItem.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(to) & t.name.ilike(item.name),
        transaction: w.tx,
        lockMode: LockMode.forUpdate,
      );
      if (target != null && target.unit != item.unit) {
        _fail('invalid_input', 'The other restaurant counts ${item.name} in ${target.unit}.');
      }
      target ??= await StockItem.db.insertRow(
        s,
        StockItem(
          restaurantId: to,
          name: item.name,
          unit: item.unit,
          quantity: 0,
          costMinor: item.costMinor,
          lowAt: item.lowAt,
          version: 1,
          updatedAt: _now(),
          parLevel: item.parLevel,
          leadDays: item.leadDays,
        ),
        transaction: w.tx,
      );
      item
        ..quantity -= quantity
        ..version += 1
        ..updatedAt = _now();
      target
        ..quantity += quantity
        ..version += 1
        ..updatedAt = _now();
      await StockItem.db.updateRow(s, item, transaction: w.tx);
      await StockItem.db.updateRow(s, target, transaction: w.tx);
      final transferId = _uuid();
      await StockMovement.db.insert(
        s,
        [
          StockMovement(
            restaurantId: w.tenant,
            stockItemId: item.id!,
            kind: 'transfer',
            quantity: -quantity,
            unitCostMinor: item.costMinor,
            refType: 'transfer',
            refId: transferId,
            at: _now(),
            userId: w.user,
          ),
          StockMovement(
            restaurantId: to,
            stockItemId: target.id!,
            kind: 'transfer',
            quantity: quantity,
            unitCostMinor: item.costMinor,
            refType: 'transfer',
            refId: transferId,
            at: _now(),
            userId: w.user,
          ),
        ],
        transaction: w.tx,
      );
      await w.audit('stock.transferred', 'stockItem', item.id, {
        'transferId': transferId,
        'toRestaurantId': to,
        'quantity': quantity,
      });
      await _venueAudit(w, to, 'stock.transferred', 'stockItem', target.id, {
        'transferId': transferId,
        'fromRestaurantId': w.tenant,
        'quantity': quantity,
      });
      return {
        'transferId': transferId,
        'from': {'stockItemId': item.id, 'quantity': item.quantity},
        'to': {'stockItemId': target.id, 'quantity': target.quantity},
      };
    },
    roles: _managers,
  );

  /// Puts a person in a group; an accountant also gets an accountant
  /// membership in each venue. Used by `accept` and by the judges' seed.
  static Future<void> grant(Work w, int groupId, String userId, String role) async {
    if (!memberRoles.contains(role)) _fail('invalid_input', 'Unsupported role.');
    final existing = await GroupMembership.db.findFirstRow(
      w.s,
      where: (t) => t.groupId.equals(groupId) & t.userId.equals(userId),
      transaction: w.tx,
    );
    if (existing?.role == 'owner') {
      _fail('conflict', 'The owner already runs this group.');
    }
    if (existing == null) {
      await GroupMembership.db.insertRow(
        w.s,
        GroupMembership(
          groupId: groupId,
          userId: userId,
          role: role,
          active: true,
          version: 1,
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
    } else {
      existing
        ..role = role
        ..active = true
        ..version += 1;
      await GroupMembership.db.updateRow(w.s, existing, transaction: w.tx);
    }
    if (role == 'accountant') {
      for (final venue in await venueIds(w, groupId)) {
        await _grantVenue(w, venue, userId);
      }
    } else if (existing?.role == 'accountant') {
      for (final venue in await venueIds(w, groupId)) {
        await _revokeVenue(w, venue, userId);
      }
    }
    await w.audit('group.member_granted', 'group', groupId, {
      'groupId': groupId,
      'role': role,
    });
  }

  static Future<RestaurantGroup> _ownedGroup(Work w, int groupId) async {
    final group = await RestaurantGroup.db.findById(
      w.s,
      groupId,
      transaction: w.tx,
      lockMode: LockMode.forUpdate,
    );
    if (group == null) _fail('not_found', 'Group not found.');
    final m = await GroupMembership.db.findFirstRow(
      w.s,
      where: (t) => t.groupId.equals(groupId) & t.userId.equals(w.user),
      transaction: w.tx,
    );
    if (group.ownerUserId != w.user || m == null || !m.active || m.role != 'owner') {
      _fail('forbidden', 'Only the group owner can do this.');
    }
    return group;
  }

  static Future<void> _bump(Work w, RestaurantGroup group) async {
    group
      ..version += 1
      ..updatedAt = _now();
    await RestaurantGroup.db.updateRow(w.s, group, transaction: w.tx);
  }

  static Future<List<GroupMembership>> _members(
    Work w,
    int groupId,
    Set<String> roles,
  ) => GroupMembership.db.find(
    w.s,
    where: (t) =>
        t.groupId.equals(groupId) & t.active.equals(true) & t.role.inSet(roles),
    transaction: w.tx,
  );

  /// An accountant membership in one venue, unless the person already holds
  /// a role there (an owner or manager keeps theirs).
  static Future<void> _grantVenue(Work w, int venue, String userId) async {
    final m = await Membership.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(venue) & t.userId.equals(userId),
      transaction: w.tx,
    );
    if (m == null) {
      await Membership.db.insertRow(
        w.s,
        Membership(
          restaurantId: venue,
          userId: userId,
          role: 'accountant',
          active: true,
        ),
        transaction: w.tx,
      );
    } else if (m.role == 'accountant' && !m.active) {
      m.active = true;
      await Membership.db.updateRow(w.s, m, transaction: w.tx);
    } else {
      return;
    }
    await _venueAudit(w, venue, 'group.accountant_granted', 'membership', null, {
      'userId': userId,
    });
  }

  /// Only the accountant role a group gave is taken back.
  static Future<void> _revokeVenue(Work w, int venue, String userId) async {
    final m = await Membership.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(venue) & t.userId.equals(userId),
      transaction: w.tx,
    );
    if (m == null || m.role != 'accountant' || !m.active) return;
    m.active = false;
    await Membership.db.updateRow(w.s, m, transaction: w.tx);
    await _venueAudit(w, venue, 'group.accountant_revoked', 'membership', m.id, {
      'userId': userId,
    });
  }

  /// An audit row in another venue's trail (the venue's live board and
  /// history see what the group did there).
  static Future<void> _venueAudit(
    Work w,
    int venue,
    String kind,
    String type,
    int? id,
    Json details,
  ) => AuditRecord.db.insertRow(
    w.s,
    AuditRecord(
      restaurantId: venue,
      userId: w.user,
      requestKey: w.command.requestKey,
      kind: kind,
      entityType: type,
      entityId: id,
      detailsJson: jsonEncode(details),
      createdAt: _now(),
    ),
    transaction: w.tx,
  );

  // ----------------------------------------------------------------- queries

  /// The venue ids a group holds, oldest first.
  static Future<List<int>> venueIds(Work w, int groupId) async => [
    for (final v in await GroupVenue.db.find(
      w.s,
      where: (t) => t.groupId.equals(groupId),
      orderBy: (t) => t.attachedAt,
      limit: maxVenues,
      transaction: w.tx,
    ))
      v.restaurantId,
  ];

  /// The caller's role in a group, or a refusal. Guests, disabled accounts
  /// and agents never read a group.
  static Future<GroupMembership> _groupRole(
    Work w,
    int groupId,
    Set<String> allowed,
  ) async {
    if (w.actor.isGuest || w.actor.disabled || AgentModule.isService(w.actor)) {
      _fail('forbidden', 'A current registered account is required.');
    }
    final m = await GroupMembership.db.findFirstRow(
      w.s,
      where: (t) => t.groupId.equals(groupId) & t.userId.equals(w.user),
      transaction: w.tx,
    );
    if (m == null || !m.active || !allowed.contains(m.role)) {
      _fail('forbidden', 'This group is not yours to read.');
    }
    return m;
  }

  /// One venue as the group pages show it.
  static Future<List<_Venue>> _venues(Work w, int groupId) async {
    final out = <_Venue>[];
    for (final id in await venueIds(w, groupId)) {
      final r = await Restaurant.db.findById(w.s, id, transaction: w.tx);
      final p = await RestaurantPolicy.db.findFirstRow(
        w.s,
        where: (t) => t.restaurantId.equals(id),
        transaction: w.tx,
      );
      if (r == null) continue;
      final settings = {
        ...CatalogueModule.defaults,
        if (p != null) ..._json(p.settingsJson),
      };
      out.add(
        _Venue(id, r.name, r.currency, CatalogueModule.zone('${settings['timezone']}')),
      );
    }
    return out;
  }

  /// Local midnight `days` days back, as UTC, in the venue's own time zone.
  static DateTime _since(tz.Location zone, int days) {
    final now = tz.TZDateTime.now(zone);
    return tz.TZDateTime(zone, now.year, now.month, now.day)
        .subtract(Duration(days: days - 1))
        .toUtc();
  }

  static int _days(Json d) => switch (d['range'] ?? '7d') {
    'today' => 1,
    '7d' => 7,
    '30d' => 30,
    _ => _fail('invalid_input', 'Unsupported range.'),
  };

  static Future<List<PurchaseOrder>> _paid(Work w, int venue, DateTime from) =>
      PurchaseOrder.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(venue) &
            (t.createdAt >= from) &
            t.paymentStatus.inSet({'paid', 'partiallyRefunded'}) &
            t.status.notInSet({'cancelled', 'rejected', 'expired'}),
        limit: 20000,
        transaction: w.tx,
      );

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async {
    final s = w.s;
    final tx = w.tx;
    switch (name) {
      case 'group.list':
        final mine = await GroupMembership.db.find(
          s,
          where: (t) => t.userId.equals(w.user) & t.active.equals(true),
          limit: 50,
          transaction: tx,
        );
        final rows = <Json>[];
        for (final m in mine) {
          final g = await RestaurantGroup.db.findById(s, m.groupId, transaction: tx);
          if (g == null) continue;
          final venues = <Json>[];
          for (final v in await _venues(w, g.id!)) {
            final role = await Membership.db.findFirstRow(
              s,
              where: (t) =>
                  t.restaurantId.equals(v.id) &
                  t.userId.equals(w.user) &
                  t.active.equals(true),
              transaction: tx,
            );
            venues.add({
              'restaurantId': v.id,
              'name': v.name,
              'currency': v.currency,
              'role': role?.role,
            });
          }
          rows.add({
            'id': g.id,
            'name': g.name,
            'currency': g.currency,
            'role': m.role,
            'version': g.version,
            'venues': venues,
          });
        }
        return {'rows': rows, 'nextCursor': null};
      case 'group.overview':
        final gid = _int(d, 'groupId', min: 1, max: 1 << 31);
        await _groupRole(w, gid, roles);
        final days = _days(d);
        final rows = <Json>[];
        for (final v in await _venues(w, gid)) {
          final from = _since(v.zone, days);
          final orders = await _paid(w, v.id, from);
          final sales = orders.fold<int>(0, (n, o) => n + o.totalMinor);
          final refunds = await PaymentRefund.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(v.id) &
                (t.createdAt >= from) &
                t.state.notInSet({'failed', 'denied'}),
            transaction: tx,
          );
          final payouts = await PayoutBatch.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(v.id) &
                (t.createdAt >= from) &
                t.state.inSet({'sent', 'completed'}),
            transaction: tx,
          );
          final soon = _now().add(const Duration(days: 7));
          final bills = await Bill.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(v.id) &
                t.state.inSet({'review', 'approved', 'paying'}),
            transaction: tx,
          );
          final due = bills.where((b) => b.dueAt == null || !b.dueAt!.isAfter(soon));
          final stock = await StockItem.db.find(
            s,
            where: (t) => t.restaurantId.equals(v.id),
            transaction: tx,
          );
          final live = await DeliveryAssignment.db.count(
            s,
            where: (t) =>
                t.restaurantId.equals(v.id) &
                t.status.inSet({'assigned', 'collected', 'outForDelivery'}),
            transaction: tx,
          );
          rows.add({
            'restaurantId': v.id,
            'name': v.name,
            'currency': v.currency,
            'paidSalesMinor': sales,
            'orders': orders.length,
            'averageTicketMinor': orders.isEmpty ? 0 : (sales / orders.length).round(),
            'refundsMinor': refunds.fold<int>(0, (n, r) => n + r.amountMinor),
            'payoutsMinor': payouts.fold<int>(0, (n, p) => n + p.totalMinor),
            'billsDue': due.length,
            'billsDueMinor': due.fold<int>(0, (n, b) => n + b.amountMinor),
            'lowStock': stock.where((i) => i.quantity <= i.lowAt).length,
            'liveDeliveries': live,
          });
        }
        return {
          'groupId': gid,
          'range': d['range'] ?? '7d',
          'venues': rows,
          'totals': _totals(rows, const [
            'paidSalesMinor',
            'orders',
            'refundsMinor',
            'payoutsMinor',
            'billsDueMinor',
            'billsDue',
            'lowStock',
            'liveDeliveries',
          ]),
        };
      case 'group.compare':
        final gid = _int(d, 'groupId', min: 1, max: 1 << 31);
        await _groupRole(w, gid, roles);
        final days = _days(d);
        final rows = <Json>[];
        for (final v in await _venues(w, gid)) {
          final from = _since(v.zone, days);
          final buckets = <String, List<int>>{};
          for (var i = 0; i < days; i++) {
            final local = tz.TZDateTime.from(from, v.zone).add(Duration(days: i));
            buckets[_day(local)] = [0, 0];
          }
          for (final o in await _paid(w, v.id, from)) {
            final key = _day(tz.TZDateTime.from(o.createdAt, v.zone));
            final b = buckets[key];
            if (b == null) continue;
            b[0] += o.totalMinor;
            b[1] += 1;
          }
          for (final e in buckets.entries) {
            rows.add({
              'restaurantId': v.id,
              'venue': v.name,
              'currency': v.currency,
              'date': e.key,
              'salesMinor': e.value[0],
              'orders': e.value[1],
            });
          }
        }
        return {'groupId': gid, 'range': d['range'] ?? '7d', 'rows': rows};
      case 'group.ledger':
        final gid = _int(d, 'groupId', min: 1, max: 1 << 31);
        await _groupRole(w, gid, {'owner', 'accountant'});
        final days = d['range'] == null ? 30 : _days(d);
        final rows = <Json>[];
        final totals = <String, Json>{};
        for (final v in await _venues(w, gid)) {
          // A read-only view of one venue for the ledger, built only after the
          // group role check above; it never reaches command code.
          final venue = await Restaurant.db.findById(s, v.id, transaction: tx);
          final policy = await RestaurantPolicy.db.findFirstRow(
            s,
            where: (t) => t.restaurantId.equals(v.id),
            transaction: tx,
          );
          final view = Work(
            s,
            tx,
            w.actor,
            PlatformCommand(requestKey: _uuid(), restaurantId: v.id, dataJson: '{}'),
            venue,
            policy,
          );
          final lines = await LedgerModule.journal(view, _since(v.zone, days), _now());
          for (final l in lines) {
            rows.add({...l, 'restaurantId': v.id, 'venue': v.name});
            final account = l['account'] as String;
            final t = totals.putIfAbsent('${l['currency']}', () => {
              'currency': '${l['currency']}',
              'revenueMinor': 0,
              'costMinor': 0,
            });
            final debit = l['debitMinor'] as int, credit = l['creditMinor'] as int;
            if (LedgerModule.revenue(account)) {
              t['revenueMinor'] = (t['revenueMinor'] as int) + credit - debit;
            } else if (LedgerModule.cost(account)) {
              t['costMinor'] = (t['costMinor'] as int) + debit - credit;
            }
          }
        }
        for (final t in totals.values) {
          t['netMinor'] = (t['revenueMinor'] as int) - (t['costMinor'] as int);
        }
        rows.sort((a, b) => '${b['at']}'.compareTo('${a['at']}'));
        return {
          'groupId': gid,
          // The venues' own double-entry journals side by side, one currency
          // each; totals are per currency, never summed across them.
          'basis': 'journal',
          'rows': rows.take(2000).toList(),
          'truncated': rows.length > 2000,
          'totals': totals.values.toList(),
        };
      case 'group.payables':
        final gid = _int(d, 'groupId', min: 1, max: 1 << 31);
        await _groupRole(w, gid, {'owner', 'accountant'});
        final rows = <Json>[];
        for (final v in await _venues(w, gid)) {
          for (final b in await Bill.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(v.id) &
                t.state.inSet({'review', 'approved', 'paying'}),
            orderBy: (t) => t.dueAt,
            transaction: tx,
          )) {
            rows.add({
              'restaurantId': v.id,
              'venue': v.name,
              'currency': b.currency,
              'id': b.id,
              'vendor': b.vendor,
              'category': b.category,
              'amountMinor': b.amountMinor,
              'dueAt': b.dueAt?.toIso8601String(),
              'state': b.state,
              'daysOverdue': b.dueAt == null
                  ? 0
                  : max(0, _now().difference(b.dueAt!).inDays),
            });
          }
        }
        return {
          'groupId': gid,
          'rows': rows,
          'totals': _totals([
            for (final r in rows) {'currency': r['currency'], 'amountMinor': r['amountMinor']},
          ], const ['amountMinor']),
        };
      case 'group.templates':
        final gid = _int(d, 'groupId', min: 1, max: 1 << 31);
        await _groupRole(w, gid, roles);
        final templates = await MenuTemplate.db.find(
          s,
          where: (t) => t.groupId.equals(gid),
          orderBy: (t) => t.updatedAt.desc(),
          limit: 50,
          transaction: tx,
        );
        return {
          'rows': [
            for (final t in templates)
              {
                'id': t.id,
                'name': t.name,
                'items': jsonDecode(t.itemsJson),
                'version': t.version,
                'updatedAt': t.updatedAt.toIso8601String(),
              },
          ],
          'nextCursor': null,
        };
    }
    return null;
  }

  static String _day(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

  /// Sums per currency; amounts in different currencies are never added.
  static List<Json> _totals(List<Json> rows, List<String> keys) {
    final by = <String, Json>{};
    for (final r in rows) {
      final currency = '${r['currency']}';
      final t = by.putIfAbsent(currency, () => {
        'currency': currency,
        for (final k in keys) k: 0,
      });
      for (final k in keys) {
        t[k] = (t[k] as int) + ((r[k] as num?)?.toInt() ?? 0);
      }
    }
    return by.values.toList();
  }

  /// For tests: a group read as the signed-in person, without HTTP.
  static Future<Json> read(Session s, {required String name, Json d = const {}}) async {
    final actor = await _actor(s);
    return s.db.transaction((tx) async {
      final w = Work(
        s,
        tx,
        actor,
        PlatformCommand(requestKey: _uuid(), dataJson: '{}'),
        null,
        null,
      );
      return await query(w, name, d, 30, 0, (rows) => {'rows': rows}) ??
          _fail('not_found', 'Unknown query.');
    });
  }
}

class _Venue {
  _Venue(this.id, this.name, this.currency, this.zone);
  final int id;
  final String name;
  final String currency;
  final tz.Location zone;
}
