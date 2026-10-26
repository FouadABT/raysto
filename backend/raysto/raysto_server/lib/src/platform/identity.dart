part of 'platform.dart';

class IdentityModule {
  static Future<void> teamCapacity(Work w) async {
    if (Platform.environment['RAYSTO_BILLING_ENFORCED'] != 'true') return;
    await _entitled(w.s, w.tenant, w.tx);
    final sub = (await RestaurantSubscription.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      transaction: w.tx,
    ))!;
    final plan = (await RestaurantPlan.db.findById(
      w.s,
      sub.planId,
      transaction: w.tx,
    ))!;
    final cap = _int(_json(plan.featuresJson), 'maxTeamMembers');
    if (await Membership.db.count(
          w.s,
          where: (t) => t.restaurantId.equals(w.tenant) & t.active.equals(true),
          transaction: w.tx,
        ) >=
        cap) {
      _fail('team_limit', 'This subscription has no available team seats.');
    }
  }

  static Future<Json> exchange(Session s, Json d, {required bool guest}) async {
    PlatformApi.enabled();
    _keys(d, guest ? {'appCheckToken'} : {'firebaseIdToken'});
    if (guest) {
      final result = await AuthServices.instance.anonymousIdp.login(
        s,
        token: _str(d, 'appCheckToken', max: 16000),
      );
      return result.toJson();
    }
    await ProviderClients.checkApp(s);
    final token = _str(d, 'firebaseIdToken', max: 16000);
    final details = await AuthServices.instance.firebaseIdp.utils
        .fetchAccountDetails(s, idToken: token);
    await ProviderClients.verifyIdentity(
      s,
      token,
      details.userIdentifier,
      recent: false,
    );
    final result = await AuthServices.instance.firebaseIdp.login(
      s,
      idToken: token,
    );
    return result.toJson();
  }

  static AnonymousIdpConfig guestConfiguration() => AnonymousIdpConfig(
    perIpAddressRateLimit: const RateLimit(
      maxAttempts: 10,
      timeframe: Duration(hours: 1),
    ),
    onBeforeAnonymousAccountCreated: (s, {token, required transaction}) async {
      if (Platform.environment['RAYSTO_GUESTS_ENABLED'] != 'true') {
        _fail('not_enabled', 'Guest sessions are not enabled.');
      }
      await ProviderClients.checkApp(s, token: token, required: true);
    },
    onAfterAnonymousAccountCreated:
        (s, {required authUserId, required transaction}) async {
          await ActorProfile.db.insertRow(
            s,
            ActorProfile(
              userId: authUserId.toString(),
              isGuest: true,
              disabled: false,
              dataJson: '{}',
              version: 1,
              createdAt: _now(),
              updatedAt: _now(),
            ),
            transaction: transaction,
          );
        },
  );

  static Future<Json> profile(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'identity.profile',
    (w, d) async {
      _keys(d, {
        'displayName',
        'locale',
        'addresses',
        'preferences',
        'notifications',
        'onboarding',
      });
      _version(w.actor.version, c.expectedVersion);
      final name = _str(d, 'displayName', max: 80);
      final locale = _str(d, 'locale', choices: {'en', 'fr', 'ar'});
      final addresses = _list(
        d,
        'addresses',
        max: 20,
      ).map((a) => CatalogueModule.address(_object(a))).toList();
      final preferences = _list(
        d,
        'preferences',
        max: 30,
      ).map((v) => _str({'value': v}, 'value', max: 80)).toList();
      final notifications = _object(d['notifications'] ?? {});
      _keys(notifications, {'orders', 'reservations', 'marketing', 'support'});
      for (final k in notifications.keys) {
        _bool(notifications, k);
      }
      final progress = _object(d['onboarding'] ?? {});
      _keys(progress, {'customer', 'owner', 'staff'});
      for (final k in progress.keys) {
        _int(progress, k, max: 20);
      }
      w.actor.dataJson = jsonEncode({
        'displayName': name,
        'locale': locale,
        'addresses': addresses,
        'preferences': preferences,
        'notifications': notifications,
        'onboarding': progress,
      });
      w.actor.version++;
      w.actor.updatedAt = _now();
      await ActorProfile.db.updateRow(s, w.actor, transaction: w.tx);
      return {'version': w.actor.version};
    },
  );

  static Future<Json> createRestaurant(Session s, PlatformCommand c) =>
      _mutate(s, c, 'restaurant.create', (w, d) async {
        _keys(d, {'name', 'currency'});
        final restaurant = await Restaurant.db.insertRow(
          s,
          Restaurant(
            name: _str(d, 'name', max: 120),
            currency: _str(d, 'currency', choices: {'EUR', 'USD', 'GBP'}),
            deliveryFeeMinor: 0,
            published: false,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await Membership.db.insertRow(
          s,
          Membership(
            restaurantId: restaurant.id!,
            userId: w.user,
            role: 'owner',
            active: true,
          ),
          transaction: w.tx,
        );
        await RestaurantPolicy.db.insertRow(
          s,
          RestaurantPolicy(
            restaurantId: restaurant.id!,
            settingsJson: jsonEncode(CatalogueModule.defaults),
            version: 1,
            menuVersion: 1,
            suspended: false,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.audit('restaurant.created', 'restaurant', restaurant.id);
        return {'id': restaurant.id, 'version': 1};
      }, registered: true);

  static Future<Json> claimTicket(Session s, PlatformCommand c) =>
      _mutate(s, c, 'identity.claimTicket', (w, d) async {
        _keys(d, {});
        if (!w.actor.isGuest) {
          _fail(
            'invalid_transition',
            'Only a guest session can issue a claim ticket.',
          );
        }
        final token = _secret();
        await SecurityGrant.db.insertRow(
          s,
          SecurityGrant(
            userId: w.user,
            kind: 'guest_claim',
            proofHash: _hash(token),
            expiresAt: _now().add(const Duration(minutes: 10)),
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        return {'claimToken': token, 'expiresInSeconds': 600};
      });

  static Future<Json> claim(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'identity.claim', (w, d) async {
    _keys(d, {'claimToken'});
    final grant = await SecurityGrant.db.findFirstRow(
      s,
      where: (t) =>
          t.proofHash.equals(_hash(_str(d, 'claimToken', max: 100))) &
          t.kind.equals('guest_claim'),
      transaction: w.tx,
      lockMode: LockMode.forUpdate,
    );
    if (grant == null ||
        grant.usedAt != null ||
        !grant.expiresAt.isAfter(_now()) ||
        grant.userId == w.user) {
      _fail('invalid_invitation', 'Claim ticket expired or unavailable.');
    }
    final guest = await ActorProfile.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(grant.userId),
      transaction: w.tx,
      lockMode: LockMode.forUpdate,
    );
    if (guest == null ||
        !guest.isGuest ||
        guest.claimedBy != null ||
        guest.disabled) {
      _fail('invalid_invitation', 'Guest is unavailable.');
    }
    // Transfer only personal ownership. Memberships and privileged grants are deliberately excluded.
    await PurchaseOrder.db.updateWhere(
      s,
      columnValues: (t) => [t.customerId(w.user)],
      where: (t) => t.customerId.equals(guest.userId),
      transaction: w.tx,
    );
    await DiningReservation.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await DiningWaitlist.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await CheckoutIntent.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await SupportConversation.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await SupportMessage.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await UserNotification.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await MediaAsset.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await CustomerReview.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await VisitRequest.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    await AiOperation.db.updateWhere(
      s,
      columnValues: (t) => [t.userId(w.user)],
      where: (t) => t.userId.equals(guest.userId) & t.kind.equals('recommend'),
      transaction: w.tx,
    );
    final favorites = await CustomerFavorite.db.find(
      s,
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    for (final favorite in favorites) {
      final existing = await CustomerFavorite.db.findFirstRow(
        s,
        where: (t) =>
            t.userId.equals(w.user) & t.targetKey.equals(favorite.targetKey),
        transaction: w.tx,
      );
      if (existing == null) {
        favorite.userId = w.user;
        await CustomerFavorite.db.updateRow(s, favorite, transaction: w.tx);
      } else {
        await CustomerFavorite.db.deleteRow(s, favorite, transaction: w.tx);
      }
    }
    final participants = await VisitParticipant.db.find(
      s,
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    for (final p in participants) {
      final existing = await VisitParticipant.db.findFirstRow(
        s,
        where: (t) => t.visitId.equals(p.visitId) & t.userId.equals(w.user),
        transaction: w.tx,
      );
      if (existing == null) {
        p.userId = w.user;
        await VisitParticipant.db.updateRow(s, p, transaction: w.tx);
      } else {
        existing.active = existing.active || p.active;
        await VisitParticipant.db.updateRow(s, existing, transaction: w.tx);
        await VisitParticipant.db.deleteRow(s, p, transaction: w.tx);
      }
    }
    final carts = await CustomerCart.db.find(
      s,
      where: (t) => t.userId.equals(guest.userId),
      transaction: w.tx,
    );
    for (final cart in carts) {
      final existing = await CustomerCart.db.findFirstRow(
        s,
        where: (t) =>
            t.userId.equals(w.user) & t.restaurantId.equals(cart.restaurantId),
        transaction: w.tx,
      );
      if (existing == null) {
        cart.userId = w.user;
        await CustomerCart.db.updateRow(s, cart, transaction: w.tx);
      } else if (existing.linesJson == '[]') {
        existing.linesJson = cart.linesJson;
        existing.version++;
        await CustomerCart.db.updateRow(s, existing, transaction: w.tx);
      }
    }
    guest.disabled = true;
    guest.claimedBy = w.user;
    await ActorProfile.db.updateRow(s, guest, transaction: w.tx);
    grant.usedAt = _now();
    await SecurityGrant.db.updateRow(s, grant, transaction: w.tx);
    await AuthServices.instance.tokenManager.revokeAllTokens(
      s,
      authUserId: UuidValue.fromString(guest.userId),
      transaction: w.tx,
    );
    await w.audit('identity.guest_claimed', 'actor', guest.id);
    return {
      'claimed': true,
      'cartConflictPolicy': 'Existing registered cart is preserved.',
    };
  }, registered: true);

  static Future<Json> revokeSessions(Session s, PlatformCommand c) =>
      _mutate(s, c, 'identity.revokeSessions', (w, d) async {
        _keys(d, {});
        await AuthServices.instance.tokenManager.revokeAllTokens(
          s,
          authUserId: UuidValue.fromString(w.user),
          transaction: w.tx,
        );
        await w.audit('identity.sessions_revoked', 'actor', w.actor.id);
        return {'revoked': true};
      });

  static Future<Json> stepUp(Session s, PlatformCommand c) async {
    final actor = await _actor(s);
    final d = _json(c.dataJson);
    _keys(d, {'firebaseIdToken'});
    if (actor.firebaseUid == null || actor.isGuest) {
      _fail('verified_account_required', 'A verified account is required.');
    }
    final claims = await ProviderClients.verifyIdentity(
      s,
      _str(d, 'firebaseIdToken', max: 16000),
      actor.firebaseUid!,
    );
    // Do not retain the credential in the mutation fingerprint or response.
    final safe = PlatformCommand(
      requestKey: c.requestKey,
      dataJson: jsonEncode({
        'mfa': claims['mfa'] == true,
        'authTime': claims['authTime'],
      }),
    );
    return _mutate(s, safe, 'identity.stepUp', (w, proof) async {
      for (final kind in ['recent_auth', if (proof['mfa'] == true) 'mfa']) {
        final binding = _hash(
          'stepup:${w.user}:${s.authenticated!.authId}:$kind',
        );
        final existing = await SecurityGrant.db.findFirstRow(
          s,
          where: (t) => t.proofHash.equals(binding),
          transaction: w.tx,
        );
        if (existing != null) {
          existing.expiresAt = _now().add(const Duration(minutes: 5));
          await SecurityGrant.db.updateRow(s, existing, transaction: w.tx);
          continue;
        }
        await SecurityGrant.db.insertRow(
          s,
          SecurityGrant(
            userId: w.user,
            kind: kind,
            proofHash: binding,
            expiresAt: _now().add(const Duration(minutes: 5)),
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
      }
      return {'recentAuth': true, 'mfa': proof['mfa'], 'expiresInSeconds': 300};
    }, registered: true);
  }

  static Future<Json> invite(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'team.invite',
    (w, d) async {
      _keys(d, {'email', 'role'});
      final member = await w.role(_managers);
      final role = _str(
        d,
        'role',
        choices: member.role == 'owner'
            ? {'manager', 'waiter', 'kitchen', 'courier'}
            : {'waiter', 'kitchen', 'courier'},
      );
      final email = _str(d, 'email', max: 254).toLowerCase();
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        _fail('invalid_input', 'Invalid email.');
      }
      final token = _secret();
      final invitation = await AccessInvitation.db.insertRow(
        s,
        AccessInvitation(
          restaurantId: w.tenant,
          kind: 'team',
          targetId: w.tenant,
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
      await w.audit('team.invited', 'invitation', invitation.id, {
        'role': role,
      });
      return {
        'id': invitation.id,
        'deliveryStatus': 'queued',
        'invitationCode': token,
        'restaurantId': w.tenant,
        'expiresAt': invitation.expiresAt.toIso8601String(),
      };
    },
    roles: _managers,
    registered: true,
  );

  static Future<Json> accept(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'team.accept',
    (w, d) async {
      _keys(d, {'token'});
      final i = await _invitation(w, _str(d, 'token', max: 100), 'team');
      final account = await AuthServices.instance.firebaseIdp.admin
          .findAccountByAuthUserId(s, authUserId: UuidValue.fromString(w.user));
      if (account?.email?.toLowerCase() != i.recipientEmail) {
        _fail('forbidden', 'Sign in with the invited verified email.');
      }
      final issuer = await _role(
        s,
        i.createdBy,
        w.tenant,
        i.role == 'manager' ? {'owner'} : _managers,
        tx: w.tx,
      );
      if (!issuer.active) {
        _fail('invalid_invitation', 'Invitation issuer is no longer active.');
      }
      final existing = await Membership.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
        transaction: w.tx,
      );
      if (existing?.role == 'owner') {
        _fail('conflict', 'Ownership cannot be changed by an invitation.');
      }
      if (existing?.active != true) await teamCapacity(w);
      if (existing == null) {
        await Membership.db.insertRow(
          s,
          Membership(
            restaurantId: w.tenant,
            userId: w.user,
            role: i.role!,
            active: true,
          ),
          transaction: w.tx,
        );
      } else {
        existing.role = i.role!;
        existing.active = true;
        await Membership.db.updateRow(s, existing, transaction: w.tx);
      }
      i.usesRemaining = 0;
      await AccessInvitation.db.updateRow(s, i, transaction: w.tx);
      await w.audit('team.accepted', 'membership', existing?.id);
      return {'restaurantId': w.tenant, 'role': i.role};
    },
    registered: true,
  );

  static Future<AccessInvitation> _invitation(
    Work w,
    String token,
    String kind,
  ) async {
    final i = await AccessInvitation.db.findFirstRow(
      w.s,
      where: (t) => t.tokenHash.equals(_hash(token)),
      transaction: w.tx,
      lockMode: LockMode.forUpdate,
    );
    if (i == null ||
        i.restaurantId != w.tenant ||
        i.kind != kind ||
        i.revoked ||
        i.usesRemaining < 1 ||
        !i.expiresAt.isAfter(_now())) {
      _fail('invalid_invitation', 'Invitation expired or unavailable.');
    }
    return i;
  }

  static Future<Json> membership(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'team.membership',
    (w, d) async {
      _keys(d, {'userId', 'role', 'active'});
      final caller = await w.role(_managers);
      final target = await Membership.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.userId.equals(_str(d, 'userId', max: 100)),
        transaction: w.tx,
      );
      if (target == null) _fail('not_found', 'Membership not found.');
      if (target.role == 'owner' ||
          caller.role == 'manager' && target.role == 'manager') {
        _fail('forbidden', 'This role cannot be changed here.');
      }
      target.role = _str(
        d,
        'role',
        choices: caller.role == 'owner'
            ? {'manager', 'waiter', 'kitchen', 'courier'}
            : {'waiter', 'kitchen', 'courier'},
      );
      if (!target.active && _bool(d, 'active')) await teamCapacity(w);
      target.active = _bool(d, 'active');
      await Membership.db.updateRow(s, target, transaction: w.tx);
      await AccessInvitation.db.updateWhere(
        s,
        columnValues: (t) => [t.revoked(true)],
        where: (t) =>
            t.restaurantId.equals(w.tenant) & t.createdBy.equals(target.userId),
        transaction: w.tx,
      );
      await w.audit('team.membership_changed', 'membership', target.id, {
        'role': target.role,
        'active': target.active,
      });
      return {'id': target.id, 'active': target.active, 'role': target.role};
    },
    roles: _managers,
    registered: true,
  );

  static Future<Json> transfer(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'team.transfer',
    (w, d) async {
      _keys(d, {'newOwnerId'});
      await _stepUp(w, mfa: true);
      final target = await _role(
        s,
        _str(d, 'newOwnerId', max: 100),
        w.tenant,
        _managers,
        tx: w.tx,
      );
      if (target.userId == w.user) {
        _fail('invalid_input', 'Choose another active manager.');
      }
      final owner = await w.role({'owner'});
      target.role = 'owner';
      owner.role = 'manager';
      await Membership.db.update(s, [target, owner], transaction: w.tx);
      await w.audit('team.ownership_transferred', 'membership', target.id);
      return {'ownerId': target.userId};
    },
    roles: {'owner'},
    registered: true,
  );

  static Future<Json> privacy(Session s, PlatformCommand c) =>
      _mutate(s, c, 'identity.privacy', (w, d) async {
        _keys(d, {'action'});
        final action = _str(d, 'action', choices: {'export', 'delete'});
        if (action == 'delete') {
          if (!w.actor.isGuest) await _stepUp(w);
          final owns = await Membership.db.findFirstRow(
            s,
            where: (t) =>
                t.userId.equals(w.user) &
                t.role.equals('owner') &
                t.active.equals(true),
            transaction: w.tx,
          );
          if (owns != null) {
            _fail(
              'ownership_transfer_required',
              'Transfer restaurant ownership before deleting this account.',
            );
          }
          w.actor.disabled = true;
          await ActorProfile.db.updateRow(s, w.actor, transaction: w.tx);
          await AuthServices.instance.tokenManager.revokeAllTokens(
            s,
            authUserId: UuidValue.fromString(w.user),
            transaction: w.tx,
          );
        }
        await w.job(
          'privacy.$action',
          'privacy:${w.user}:$action:${c.requestKey}',
          {'action': action},
        );
        await w.audit('privacy.$action', 'actor', w.actor.id);
        return {
          'status': 'queued',
          'financialRecords':
              'Retained according to the configured retention policy.',
        };
      });
}
