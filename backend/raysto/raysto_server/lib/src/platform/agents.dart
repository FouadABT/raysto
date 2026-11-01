part of 'platform.dart';

/// A change an agent may prepare for a person. The model only names the kind
/// and its arguments; [prepare] checks them against current records, and the
/// approving person's own session runs [invoke], so every role check, version
/// check and step-up of the underlying command still applies.
class AgentCommand {
  const AgentCommand({
    required this.roles,
    required this.risk,
    required this.expiry,
    required this.prepare,
    required this.invoke,
  });

  /// Who may approve.
  final Set<String> roles;

  /// `catalogue`, `ops` or `money`. Money is never applied without a person.
  final String risk;
  final Duration expiry;

  /// Validates the payload now; returns what the person sees and a hash of
  /// the records it depends on. Approval recomputes it and refuses a change.
  final Future<({Json preview, String context})> Function(Work w, Json payload)
  prepare;

  /// Runs the real command on the approver's session with [key] as its
  /// idempotency key.
  final Future<Json> Function(
    Session s,
    int restaurantId,
    Json payload,
    String key,
  )
  invoke;
}

/// What an agent run proposes: a registry command with its arguments.
class AgentDraft {
  const AgentDraft(
    this.command,
    this.title,
    this.rationale,
    this.payload, {
    this.evidence = const {},
  });
  final String command;
  final String title;
  final String rationale;
  final Json payload;
  final Json evidence;
}

class AgentOutcome {
  const AgentOutcome(
    this.summary, {
    this.drafts = const [],
    this.trace = const [],
    this.chargedMicros = 0,
  });
  final String summary;
  final List<AgentDraft> drafts;
  final List<Json> trace;
  final int chargedMicros;
}

typedef AgentHandler = Future<AgentOutcome> Function(Session s, AgentTask task);
typedef AgentTrigger =
    Future<void> Function(Work w, String type, int? id, Json details);

/// AI coworkers. Each agent does one job, records what it did and why, and
/// leaves changes as actions a person approves. Agents act as the
/// restaurant's service identity, which has no membership: it can read and
/// propose, never run a command itself.
class AgentModule {
  static const names = {
    'menu',
    'images',
    'orders',
    'payments',
    'counter',
    'catering',
    'copilot',
    'translator',
    'marketing',
    'reviews',
  };

  /// Agents register their handlers here as they are built.
  static final Map<String, AgentHandler> handlers = {
    PaymentAgent.agent: PaymentAgent.run,
    MenuAgent.agent: MenuAgent.run,
    CopilotAgent.agent: CopilotAgent.run,
    ImageAgent.agent: ImageAgent.run,
  };

  /// Audit kinds that wake an agent, e.g. `payment.attention` → payments.
  static final Map<String, AgentTrigger> triggers = {
    'payment.uncertain': PaymentAgent.onCheckout,
    'payment.attention': PaymentAgent.onCheckout,
  };

  static final Map<String, AgentCommand> commands = {
    'menu.publish': MenuAgent.publishCommand,
    'menu.image': ImageAgent.imageCommand,
    'menu.soldOut': AgentCommand(
      roles: {'owner', 'manager', 'kitchen'},
      risk: 'catalogue',
      expiry: const Duration(hours: 2),
      prepare: (w, p) async {
        _keys(p, {'productId'});
        final product = await MenuProduct.db.findById(
          w.s,
          _int(p, 'productId', min: 1),
          transaction: w.tx,
        );
        if (product == null || product.restaurantId != w.tenant) {
          _fail('not_found', 'Item not found.');
        }
        if (!product.available) {
          _fail('invalid_transition', '${product.name} is already sold out.');
        }
        return (
          preview: <String, dynamic>{
            'item': product.name,
            'from': 'available',
            'to': 'sold out',
          },
          context: _hash(
            '${product.id}:${product.version}:${product.available}',
          ),
        );
      },
      invoke: (s, rid, p, key) async {
        final product = (await MenuProduct.db.findById(
          s,
          p['productId'] as int,
        ))!;
        return CatalogueModule.availability(
          s,
          PlatformCommand(
            requestKey: key,
            restaurantId: rid,
            resourceId: product.id,
            expectedVersion: product.version,
            dataJson: jsonEncode({'available': false}),
          ),
        );
      },
    ),
    'settings.patch': AgentCommand(
      roles: _managers,
      risk: 'ops',
      expiry: const Duration(minutes: 15),
      prepare: (w, p) async {
        _keys(p, {'settings'});
        final change = _object(p['settings']);
        _keys(change, {'paused', 'preparationMinutes', 'slotCapacity'});
        if (change.isEmpty) _fail('invalid_input', 'Nothing to change.');
        final current = w.settings;
        if (change.containsKey('paused')) _bool(change, 'paused');
        if (change.containsKey('preparationMinutes')) {
          _int(change, 'preparationMinutes', min: 1, max: 240);
        }
        if (change.containsKey('slotCapacity')) {
          _int(change, 'slotCapacity', min: 1, max: 500);
        }
        return (
          preview: <String, dynamic>{
            for (final k in change.keys)
              k: {'from': current[k], 'to': change[k]},
          },
          context: _hash(
            jsonEncode([
              for (final k in change.keys.toList()..sort()) current[k],
            ]),
          ),
        );
      },
      invoke: (s, rid, p, key) async {
        final restaurant = (await Restaurant.db.findById(s, rid))!;
        final policy = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(rid),
        ))!;
        return CatalogueModule.configure(
          s,
          PlatformCommand(
            requestKey: key,
            restaurantId: rid,
            expectedVersion: policy.version,
            dataJson: jsonEncode({
              'name': restaurant.name,
              'currency': restaurant.currency,
              'settings': _object(p['settings']),
            }),
          ),
        );
      },
    ),
    'payment.reconcile': AgentCommand(
      roles: _managers,
      risk: 'ops',
      expiry: const Duration(minutes: 30),
      prepare: (w, p) async {
        _keys(p, {'checkoutId'});
        final i = await _checkout(w, p);
        if ({'completed', 'cancelled', 'failed'}.contains(i.state)) {
          _fail('invalid_transition', 'This payment is already settled.');
        }
        return (
          preview: _checkoutPreview(i),
          context: _hash('${i.id}:${i.state}'),
        );
      },
      // Reconciling only brings Raysto in line with what PayPal recorded:
      // it captures an approved order or records a capture that happened.
      invoke: (s, rid, p, key) => MoneyModule.reconcile(
        s,
        p['checkoutId'] as int,
        capture: true,
        audit: true,
      ),
    ),
    'payment.release': AgentCommand(
      roles: _managers,
      risk: 'money',
      expiry: const Duration(minutes: 30),
      prepare: (w, p) async {
        _keys(p, {'checkoutId'});
        final i = await _checkout(w, p);
        if (!{
          'created',
          'approved',
          'capturing',
          'uncertain',
        }.contains(i.state)) {
          _fail('invalid_transition', 'This payment cannot be released.');
        }
        return (
          preview: _checkoutPreview(i),
          context: _hash('${i.id}:${i.state}'),
        );
      },
      invoke: (s, rid, p, key) => MoneyModule.release(
        s,
        PlatformCommand(
          requestKey: key,
          restaurantId: rid,
          resourceId: p['checkoutId'] as int,
          dataJson: '{}',
        ),
      ),
    ),
    'payment.refund': AgentCommand(
      roles: _managers,
      risk: 'money',
      expiry: const Duration(minutes: 30),
      prepare: (w, p) async {
        _keys(p, {'captureId', 'amountMinor', 'reason', 'orderId'});
        final capture = await PaymentCapture.db.findById(
          w.s,
          _int(p, 'captureId', min: 1),
          transaction: w.tx,
        );
        if (capture == null || capture.restaurantId != w.tenant) {
          _fail('not_found', 'Payment not found.');
        }
        final amount = _int(p, 'amountMinor', min: 1);
        final refunded = await _refunded(w, capture.id!);
        if (amount > capture.amountMinor - refunded) {
          _fail('invalid_amount', 'More than the refundable balance.');
        }
        _str(p, 'reason', max: 300);
        return (
          preview: <String, dynamic>{
            'amountMinor': amount,
            'currency': capture.currency,
            'capturedMinor': capture.amountMinor,
            'alreadyRefundedMinor': refunded,
            'providerCaptureId': capture.providerCaptureId,
          },
          context: _hash('${capture.id}:$refunded'),
        );
      },
      invoke: (s, rid, p, key) => MoneyModule.refund(
        s,
        RequestRefund(
          requestKey: key,
          restaurantId: rid,
          captureId: p['captureId'] as int,
          amountMinor: p['amountMinor'] as int,
          reason: p['reason'] as String,
          orderId: p['orderId'] as int?,
        ),
      ),
    ),
  };

  static Future<CheckoutIntent> _checkout(Work w, Json p) async {
    final i = await CheckoutIntent.db.findById(
      w.s,
      _int(p, 'checkoutId', min: 1),
      transaction: w.tx,
    );
    if (i == null || i.restaurantId != w.tenant) {
      _fail('not_found', 'Payment not found.');
    }
    return i;
  }

  static Json _checkoutPreview(CheckoutIntent i) => {
    'checkoutId': i.id,
    'state': i.state,
    'amountMinor': i.amountMinor,
    'currency': i.currency,
    'orderId': i.orderId,
    'visitId': i.visitId,
    'providerOrderId': i.providerOrderId,
  };

  static Future<int> _refunded(Work w, int captureId) async {
    final refunds = await PaymentRefund.db.find(
      w.s,
      where: (t) =>
          t.captureId.equals(captureId) &
          t.state.notInSet({'failed', 'denied'}),
      transaction: w.tx,
    );
    return refunds.fold<int>(0, (n, r) => n + r.amountMinor);
  }

  /// Test seam, like [ProviderClients.environment].
  static Map<String, String> Function() environment = () =>
      Platform.environment;

  /// Off unless the deployment enables it; the owner can still switch it off.
  static bool enabled(String agent) =>
      environment()['RAYSTO_AGENT_${agent.toUpperCase()}_ENABLED'] == 'true';

  static String autonomy(Json settings, String agent) =>
      (_object(settings['agents'] ?? {})[agent] as String?) ?? 'suggest';

  /// The restaurant's agent identity: no Firebase account, no membership, no
  /// session, so it can never pass a role check or run a command.
  static String serviceUser(int restaurantId) => const uuid.Uuid().v5(
    uuid.Namespace.url.value,
    'https://rays.to/agents/$restaurantId',
  );

  static bool isService(ActorProfile actor) =>
      _json(actor.dataJson)['service'] == 'agent';

  static Future<ActorProfile> serviceActor(
    Session s,
    int restaurantId, {
    Transaction? tx,
  }) async {
    final user = serviceUser(restaurantId);
    await ActorProfile.db.insert(
      s,
      [
        ActorProfile(
          userId: user,
          isGuest: false,
          disabled: false,
          dataJson: jsonEncode({'service': 'agent'}),
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    return (await ActorProfile.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(user),
      transaction: tx,
    ))!;
  }

  /// Runs [action] as the restaurant's agent inside one transaction.
  static Future<T> asAgent<T>(
    Session s,
    int restaurantId,
    Future<T> Function(Work w) action,
  ) => s.db.transaction((tx) async {
    final restaurant = await Restaurant.db.findById(
      s,
      restaurantId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (restaurant == null) _fail('not_found', 'Restaurant not found.');
    final policy = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(restaurantId),
      transaction: tx,
    );
    final actor = await serviceActor(s, restaurantId, tx: tx);
    return action(
      Work(
        s,
        tx,
        actor,
        PlatformCommand(
          requestKey: _uuid(),
          restaurantId: restaurantId,
          dataJson: '{}',
        ),
        restaurant,
        policy,
      ),
    );
  });

  /// Queues one agent task. Repeats of the same [dedupeKey] are ignored, so
  /// triggers can fire freely.
  static Future<AgentTask?> enqueue(
    Work w, {
    required String agent,
    required String trigger,
    required String dedupeKey,
    required String title,
    Json input = const {},
    String? triggerRef,
    String? requestedBy,
    String feature = 'agents',
    Duration delay = Duration.zero,
  }) async {
    if (!names.contains(agent)) _fail('invalid_input', 'Unknown agent.');
    if (!enabled(agent) || autonomy(w.settings, agent) == 'off') return null;
    await AgentTask.db.insert(
      w.s,
      [
        AgentTask(
          restaurantId: w.tenant,
          agent: agent,
          trigger: trigger,
          triggerRef: triggerRef,
          requestedBy: requestedBy,
          dedupeKey: dedupeKey,
          status: 'queued',
          title: title,
          inputJson: jsonEncode(input),
          stateJson: '{}',
          traceJson: '[]',
          feature: feature,
          reservedMicros: 0,
          chargedMicros: 0,
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
      ],
      ignoreConflicts: true,
      transaction: w.tx,
    );
    final task = await AgentTask.db.findFirstRow(
      w.s,
      where: (t) => t.dedupeKey.equals(dedupeKey),
      transaction: w.tx,
    );
    if (task == null || task.status != 'queued') return task;
    await w.job(
      'agent.run',
      'agent:${task.id}',
      {'taskId': task.id},
      at: delay == Duration.zero ? null : _now().add(delay),
    );
    return task;
  }

  /// Called for every audit record; wakes the agent registered for its kind.
  static Future<void> onAudit(
    Work w,
    String kind,
    String type,
    int? id,
    Json details,
  ) async {
    if (kind.startsWith('agent.') || w.restaurant == null) return;
    final trigger = triggers[kind];
    if (trigger != null) await trigger(w, type, id, details);
  }

  static Future<void> run(Session s, int taskId) async {
    final task = await AgentTask.db.findById(s, taskId);
    if (task == null || task.status != 'queued') return;
    final handler = handlers[task.agent];
    if (handler == null || !enabled(task.agent)) {
      await _finish(s, task, 'failed', 'This agent is switched off.');
      return;
    }
    task.status = 'running';
    task.version++;
    task.updatedAt = _now();
    await AgentTask.db.updateRow(s, task);
    final watch = Stopwatch()..start();
    AgentOutcome outcome;
    try {
      outcome = await handler(s, task);
    } on DomainError catch (e) {
      await _finish(s, task, 'failed', e.message, code: e.code);
      return;
    } catch (e) {
      // The type only: provider bodies and stack traces stay out of records.
      await _finish(
        s,
        task,
        'failed',
        'The agent stopped unexpectedly.',
        code: 'agent_failure',
        detail: e.runtimeType.toString(),
      );
      return;
    }
    await asAgent(s, task.restaurantId, (w) async {
      final fresh = await AgentTask.db.findById(
        s,
        task.id!,
        transaction: w.tx,
        lockMode: LockMode.forUpdate,
      );
      if (fresh == null || fresh.status != 'running') return;
      final trace = [
        ...(jsonDecode(fresh.traceJson) as List),
        ...outcome.trace,
      ];
      var ordinal = 0;
      for (final draft in outcome.drafts) {
        final command = commands[draft.command];
        if (command == null) {
          trace.add({'skipped': draft.command, 'code': 'unknown_command'});
          continue;
        }
        try {
          final prepared = await command.prepare(w, draft.payload);
          await AgentAction.db.insertRow(
            s,
            AgentAction(
              restaurantId: task.restaurantId,
              taskId: task.id!,
              agent: task.agent,
              ordinal: ordinal++,
              command: draft.command,
              title: draft.title,
              rationale: draft.rationale,
              payloadJson: jsonEncode(draft.payload),
              previewJson: jsonEncode(prepared.preview),
              evidenceJson: jsonEncode(draft.evidence),
              risk: command.risk,
              contextHash: prepared.context,
              status: 'pending',
              version: 1,
              expiresAt: _now().add(command.expiry),
              createdAt: _now(),
            ),
            transaction: w.tx,
          );
        } on DomainError catch (e) {
          trace.add({'skipped': draft.command, 'code': e.code});
        }
      }
      fresh.status = 'done';
      fresh.summary = outcome.summary;
      fresh.chargedMicros = outcome.chargedMicros;
      fresh.traceJson = jsonEncode(trace);
      fresh.stateJson = jsonEncode({
        ..._json(fresh.stateJson),
        'actions': ordinal,
        'ms': watch.elapsedMilliseconds,
      });
      fresh.completedAt = _now();
      fresh.updatedAt = _now();
      fresh.version++;
      await AgentTask.db.updateRow(s, fresh, transaction: w.tx);
      await w.audit('agent.task', 'agentTask', fresh.id, {
        'agent': fresh.agent,
        'actions': ordinal,
      });
      if (ordinal > 0) {
        final team = await Membership.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              t.active.equals(true) &
              t.role.inSet(_managers),
          transaction: w.tx,
        );
        for (final m in team) {
          await w.notify(m.userId, 'agent.action', {
            'taskId': fresh.id,
            'agent': fresh.agent,
            'actions': ordinal,
          }, 'agent-task:${fresh.id}:${m.userId}');
        }
      }
    });
  }

  static Future<void> _finish(
    Session s,
    AgentTask task,
    String status,
    String summary, {
    String? code,
    String? detail,
  }) async {
    task.status = status;
    task.summary = summary;
    task.stateJson = jsonEncode({
      ..._json(task.stateJson),
      'code': ?code,
      'detail': ?detail,
    });
    task.completedAt = _now();
    task.updatedAt = _now();
    task.version++;
    await AgentTask.db.updateRow(s, task);
  }

  /// Approve or reject an action. Approval runs in three steps: claim it in
  /// one transaction, run the real command on the approver's session, then
  /// record the outcome. A step-up request leaves it approved, so repeating
  /// the same request after verifying identity resumes it exactly once.
  static Future<Json> decide(Session s, PlatformCommand c) async {
    final claim = await _mutate(s, c, 'agent.decide', (w, d) async {
      _keys(d, {'decision'});
      final decision = _str(d, 'decision', choices: {'approve', 'reject'});
      final a = await AgentAction.db.findById(
        s,
        _id(c),
        transaction: w.tx,
        lockMode: LockMode.forUpdate,
      );
      if (a == null || a.restaurantId != w.tenant) {
        _fail('not_found', 'Action not found.');
      }
      final command =
          commands[a.command] ?? _fail('not_found', 'Action not found.');
      await w.role(command.roles);
      if (a.status == 'approved' && a.approverUserId == w.user) {
        return {'state': 'approved', 'actionId': a.id};
      }
      _version(a.version, c.expectedVersion);
      if (a.status != 'pending') {
        _fail('invalid_transition', 'This action was already decided.');
      }
      Json done(String state) {
        a.status = state;
        a.approverUserId = w.user;
        a.decidedAt = _now();
        a.version++;
        return {'state': state, 'actionId': a.id};
      }

      if (a.expiresAt.isBefore(_now())) {
        final result = done('expired');
        await AgentAction.db.updateRow(s, a, transaction: w.tx);
        return result;
      }
      if (decision == 'reject') {
        final result = done('rejected');
        await AgentAction.db.updateRow(s, a, transaction: w.tx);
        await w.audit('agent.rejected', 'agentAction', a.id);
        return result;
      }
      final prepared = await command.prepare(w, _json(a.payloadJson));
      if (prepared.context != a.contextHash) {
        final result = done('superseded');
        await AgentAction.db.updateRow(s, a, transaction: w.tx);
        await w.audit('agent.superseded', 'agentAction', a.id);
        return {...result, 'state': 'stale'};
      }
      final result = done('approved');
      a.executionKey = 'agent-${a.id}-${_hash(a.payloadJson).substring(0, 16)}';
      await AgentAction.db.updateRow(s, a, transaction: w.tx);
      await w.audit('agent.approved', 'agentAction', a.id);
      return result;
    }, registered: true);
    if (claim['state'] != 'approved') return claim;
    final a = await AgentAction.db.findById(s, claim['actionId'] as int);
    if (a == null) _fail('not_found', 'Action not found.');
    if (a.status != 'approved') {
      return {
        'state': a.status,
        'actionId': a.id,
        if (a.resultJson != null) 'result': _json(a.resultJson!),
      };
    }
    Json result;
    String? error;
    try {
      result = await commands[a.command]!.invoke(
        s,
        a.restaurantId,
        _json(a.payloadJson),
        a.executionKey!,
      );
    } on DomainError catch (e) {
      if ({
        'reauthentication_required',
        'mfa_required',
        'rate_limited',
      }.contains(e.code)) {
        return {
          'state': 'approved',
          'actionId': a.id,
          'needs': e.code,
          'message': e.message,
        };
      }
      error = e.code;
      result = {'error': e.code, 'message': e.message};
    }
    return s.db.transaction((tx) async {
      final fresh = (await AgentAction.db.findById(
        s,
        a.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      if (fresh.status != 'approved') {
        return {'state': fresh.status, 'actionId': fresh.id};
      }
      fresh.status = error == null ? 'executed' : 'failed';
      fresh.resultJson = jsonEncode(result);
      fresh.errorCode = error;
      fresh.version++;
      await AgentAction.db.updateRow(s, fresh, transaction: tx);
      await AuditRecord.db.insertRow(
        s,
        AuditRecord(
          restaurantId: fresh.restaurantId,
          userId: fresh.approverUserId!,
          requestKey: fresh.executionKey!,
          kind: error == null ? 'agent.executed' : 'agent.failed',
          entityType: 'agentAction',
          entityId: fresh.id,
          detailsJson: jsonEncode({'command': fresh.command, 'code': ?error}),
          createdAt: _now(),
        ),
        transaction: tx,
      );
      return {'state': fresh.status, 'actionId': fresh.id, 'result': result};
    });
  }

  /// Expires stale proposals and settles approvals whose command already ran.
  static Future<void> sweep(Session s) async {
    await AgentAction.db.updateWhere(
      s,
      columnValues: (t) => [t.status('expired')],
      where: (t) => t.status.equals('pending') & (t.expiresAt < _now()),
    );
    await AssistantProposal.db.updateWhere(
      s,
      columnValues: (t) => [t.status('expired')],
      where: (t) => t.status.equals('review') & (t.expiresAt < _now()),
    );
    final hanging = await AgentAction.db.find(
      s,
      where: (t) =>
          t.status.equals('approved') &
          (t.decidedAt < _now().subtract(const Duration(minutes: 10))),
      limit: 50,
    );
    for (final a in hanging) {
      final receipt = await MutationReceipt.db.findFirstRow(
        s,
        where: (t) =>
            t.userId.equals(a.approverUserId!) &
            t.requestKey.equals(a.executionKey!),
      );
      a.status = receipt == null ? 'pending' : 'executed';
      if (receipt != null) a.resultJson = receipt.resultJson;
      a.version++;
      await AgentAction.db.updateRow(s, a);
    }
  }

  static Json actionJson(AgentAction a, {AgentTask? task}) => {
    'id': a.id,
    'taskId': a.taskId,
    'agent': a.agent,
    'command': a.command,
    'title': a.title,
    'rationale': a.rationale,
    'risk': a.risk,
    'status': a.status,
    'preview': _json(a.previewJson),
    'evidence': _json(a.evidenceJson),
    'version': a.version,
    'expiresAt': a.expiresAt.toIso8601String(),
    'createdAt': a.createdAt.toIso8601String(),
    'decidedAt': a.decidedAt?.toIso8601String(),
    if (a.resultJson != null) 'result': _json(a.resultJson!),
    'errorCode': a.errorCode,
    if (task != null) 'task': taskJson(task, brief: true),
  };

  static Json taskJson(AgentTask t, {bool brief = false}) => {
    'id': t.id,
    'agent': t.agent,
    'trigger': t.trigger,
    'status': t.status,
    'title': t.title,
    'summary': t.summary,
    'chargedMicros': t.chargedMicros,
    'createdAt': t.createdAt.toIso8601String(),
    'completedAt': t.completedAt?.toIso8601String(),
    'state': _json(t.stateJson),
    if (!brief) 'trace': jsonDecode(t.traceJson),
  };

  /// Actions waiting for someone with the caller's role, newest first.
  static Future<Json> inbox(Work w, Json d) async {
    final m = await w.role(_staff);
    final rows = await AgentAction.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.status.inSet({'pending', 'approved'}) &
          (t.expiresAt > _now()),
      orderBy: (t) => t.id.desc(),
      limit: 100,
      transaction: w.tx,
    );
    final mine = rows.where(
      (a) => commands[a.command]?.roles.contains(m.role) ?? false,
    );
    final tasks = {
      for (final t in await AgentTask.db.find(
        w.s,
        where: (t) => t.id.inSet(mine.map((a) => a.taskId).toSet()),
        transaction: w.tx,
      ))
        t.id: t,
    };
    return {
      'rows': [for (final a in mine) actionJson(a, task: tasks[a.taskId])],
    };
  }

  /// Every agent task, newest first, with its outcome and cost.
  static Future<Json> activity(Work w, Json d, int limit, int cursor) async {
    await w.role(_managers);
    final rows = await AgentTask.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (cursor == 0 ? Constant.bool(true) : t.id < cursor) &
          (d['agent'] == null
              ? Constant.bool(true)
              : t.agent.equals(_str(d, 'agent', choices: names))),
      orderBy: (t) => t.id.desc(),
      limit: limit,
      transaction: w.tx,
    );
    return {
      'rows': [for (final t in rows) taskJson(t, brief: true)],
      'nextCursor': rows.length == limit ? rows.last.id : null,
    };
  }

  static Future<Json> task(Work w, Json d) async {
    await w.role(_managers);
    final t = await AgentTask.db.findById(
      w.s,
      _int(d, 'id', min: 1),
      transaction: w.tx,
    );
    if (t == null || t.restaurantId != w.tenant) {
      _fail('not_found', 'Agent task not found.');
    }
    final actions = await AgentAction.db.find(
      w.s,
      where: (a) => a.taskId.equals(t.id!),
      orderBy: (a) => a.ordinal,
      transaction: w.tx,
    );
    return {
      ...taskJson(t),
      'actions': [for (final a in actions) actionJson(a)],
    };
  }
}
