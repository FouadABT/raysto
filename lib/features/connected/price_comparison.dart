part of 'connected_app.dart';

class PriceComparisonPage extends StatefulWidget {
  const PriceComparisonPage({
    super.key,
    required this.live,
    required this.productId,
  });
  final LiveContext live;
  final int productId;
  @override
  State<PriceComparisonPage> createState() => _PriceComparisonPageState();
}

class _PriceComparisonPageState extends State<PriceComparisonPage> {
  Json? comparison, review;
  bool busy = false;
  String? error;
  PendingCommand? proposalRequest;
  String? proposalSignature;
  LiveContext get live => widget.live;
  Future<void> run(Future<void> Function() fn) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await fn();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> compare(Json policy) async {
    final previous = comparison;
    final inputs = obj(previous?['inputs']);
    PendingCommand? pending;
    String? fingerprint;
    final result = await editFields(
      context,
      context.tr('Compare a pricing decision'),
      [
        InputSpec(
          'baselineUnits',
          context.tr('Assumed baseline units'),
          kind: 'int',
        ),
        InputSpec('volume', context.tr('Assumed volume change (%)')),
        InputSpec('cap', context.tr('Increase limit (%)')),
        InputSpec(
          'candidatePriceMinor',
          context.tr('Price to inspect'),
          kind: 'money',
          optional: true,
        ),
      ],
      initial: {
        'baselineUnits': inputs['baselineUnits'],
        'volume': '${(inputs['volumeChangeBps'] as num? ?? -1000) / 100}',
        'cap':
            '${(inputs['maxIncreaseBps'] as num? ?? policy['maxIncreaseBps'] as num? ?? 0) / 100}',
        'candidatePriceMinor': inputs['candidatePriceMinor'],
      },
      save: (data) async {
        int percentage(String key) {
          final n = num.tryParse('${data[key]}'.replaceAll(',', '.'));
          if (n == null || !n.isFinite) {
            throw const FormatException('Enter a valid percentage.');
          }
          return (n * 100).round();
        }

        final payload = {
          'productId': widget.productId,
          if (previous != null) 'parentId': previous['id'],
          'baselineUnits': data['baselineUnits'],
          'volumeChangeBps': percentage('volume'),
          'maxIncreaseBps': percentage('cap'),
          'candidatePriceMinor': data['candidatePriceMinor'],
        };
        final next = jsonEncode(payload);
        if (pending == null || fingerprint != next) {
          pending = live.api.prepare(
            previous == null
                ? 'pricing.comparison.create'
                : 'pricing.comparison.revise',
            payload,
            restaurantId: live.restaurantId,
          );
          fingerprint = next;
        }
        return live.api.submit(pending!);
      },
      submit: context.tr('Compare options'),
    );
    if (result != null && mounted) {
      setState(() {
        comparison = PriceComparisonDto.fromJson(result).data;
        review = null;
      });
    }
  }

  Future<void> propose(Json option) async {
    final data = {'comparisonId': comparison!['id'], 'option': option['key']};
    final signature = jsonEncode(data);
    if (proposalRequest == null || proposalSignature != signature) {
      proposalRequest = live.api.prepare(
        'pricing.propose',
        data,
        restaurantId: live.restaurantId,
      );
      proposalSignature = signature;
    }
    final result = await live.api.submit(proposalRequest!);
    proposalRequest = null;
    if (mounted) setState(() => review = result);
  }

  Future<void> history({bool comparisons = false, int? cursor}) async {
    await push(
      context,
      DataPage(
        title: context.tr(
          comparisons ? 'Resume a saved comparison' : 'Decisions to revisit',
        ),
        load: () => live.api.query(
          comparisons ? 'pricing.comparisons' : 'pricing.decisions',
          live.params({'cursor': ?cursor}),
        ),
        content: (c, d, refresh) => [
          for (final row in records(d['rows']))
            ListTile(
              title: Text(
                '${row['productName']} · ${comparisons ? '${c.tr('Revision')} ${row['revision']}' : row['choice']}',
              ),
              subtitle: Text('${row['at'] ?? row['expiresAt']}'),
              onTap: () => run(() async {
                if (!comparisons) {
                  await decisionDetail(row['id'] as int);
                  return;
                }
                if (row['productId'] != widget.productId) {
                  throw StateError(
                    c.tr('Select this dish in Sales and margins first.'),
                  );
                }
                final saved = await live.api.query(
                  'pricing.comparison',
                  live.params({'id': row['id']}),
                );
                if (mounted && c.mounted) {
                  setState(() {
                    comparison = PriceComparisonDto.fromJson(saved).data;
                    review = null;
                  });
                  Navigator.of(c).pop();
                }
              }),
            ),
          if (d['nextCursor'] != null)
            AppButton(
              label: c.tr('Load earlier records'),
              secondary: true,
              onPressed: () => history(
                comparisons: comparisons,
                cursor: d['nextCursor'] as int,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> decide(String choice, VoidCallback refresh) async {
    final result = await live.action(
      context,
      context.tr('Record decision'),
      'pricing.decision.record',
      fixed: {'comparisonId': comparison!['id'], 'choice': choice},
      fields: [
        InputSpec(
          'reason',
          context.tr('Decision reason'),
          options: const [
            'customer_sensitivity',
            'missing_evidence',
            'timing',
            'assumptions',
            'target_met',
            'other',
          ],
        ),
        InputSpec('note', context.tr('Optional decision note'), optional: true),
      ],
    );
    if (result != null) refresh();
  }

  Future<void> challenge() async {
    final task = await live.action(
      context,
      context.tr('Challenge this comparison'),
      'finance.investigate',
      fixed: {
        'productId': widget.productId,
        if (comparison != null) 'comparisonId': comparison!['id'],
      },
      fields: [InputSpec('text', context.tr('Question'))],
    );
    if (task == null || !mounted) return;
    await push(
      context,
      DataPage(
        title: context.tr('Financial analysis'),
        load: () => live.api.query(
          'finance.analysis',
          live.params({'id': task['taskId']}),
        ),
        content: (c, d, refresh) => [
          Text('${d['summary'] ?? d['status'] ?? c.tr('Pending')}'),
          if (d['source'] != null) Text('${c.tr('Source')}: ${d['source']}'),
          if (d['comparison'] is Map)
            AppButton(
              label: c.tr('Review comparison'),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    comparison = PriceComparisonDto.fromJson(
                      obj(d['comparison']),
                    ).data;
                    review = null;
                  });
                }
                Navigator.of(c).pop();
              },
            ),
          AppButton(
            label: c.tr('Refresh analysis'),
            secondary: true,
            onPressed: refresh,
          ),
        ],
      ),
    );
  }

  Future<void> decisionDetail(int id) => push(
    context,
    DataPage(
      title: context.tr('Recorded decision outcome'),
      load: () =>
          live.api.query('pricing.decision.outcome', live.params({'id': id})),
      content: (c, d, refresh) => [
        Text(
          '${d['productName']} · ${d['choice']}',
          style: Theme.of(c).textTheme.titleLarge,
        ),
        Text('${d['reason']} · ${d['note'] ?? ''}'),
        Text(
          '${c.tr('Approval')}: ${obj(d['approval'])['status'] ?? c.tr('No price action requested')}',
        ),
        Text('${c.tr('Observation')}: ${d['observationStatus']}'),
        ExpansionTile(
          title: Text(c.tr('Original comparison and evidence')),
          children: [
            Text(
              '${c.tr('Revision')} ${obj(d['comparison'])['revision']} · ${obj(d['comparison'])['baselineDefinition']}',
            ),
            for (final option in records(obj(d['comparison'])['options']))
              Text(
                '${c.tr('Scenario')} · ${option['key']} · ${financeKnownMoney(option['priceMinor'], '${d['currency']}')} · ${c.tr('Contribution before shared overhead')}: ${financeKnownMoney(option['contributionMinor'], '${d['currency']}')}',
              ),
            for (final line in records(
              obj(obj(d['comparison'])['evidence'])['lines'],
            ))
              Text(
                '${line['name']} · ${line['quantityMicros'] is num ? (line['quantityMicros'] as num) / 1000000 : c.tr('Unknown')} ${line['unit']} · ${c.tr('Receipt')} #${obj(line['source'])['id']}',
              ),
          ],
        ),
        for (final key in ['before', 'after'])
          if (d[key] is Map)
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.tr(
                      key == 'before'
                          ? 'Before publication'
                          : 'After publication',
                    ),
                    style: Theme.of(c).textTheme.titleMedium,
                  ),
                  Text(
                    '${obj(d[key])['from'] ?? '—'} → ${obj(d[key])['to'] ?? '—'}',
                  ),
                  Text(
                    '${c.tr('Units')}: ${obj(d[key])['units'] ?? 0} · ${c.tr('Costed orders')}: ${obj(d[key])['costedOrders'] ?? 0}/${obj(d[key])['orders'] ?? 0}',
                  ),
                  Text(
                    '${c.tr('Recorded contribution')}: ${financeKnownMoney(obj(d[key])['contributionMinor'], '${d['currency']}')}',
                  ),
                  if (key == 'after')
                    Text(
                      '${c.tr('Complete observation days')}: ${obj(d[key])['elapsedCompleteDays'] ?? 0}/7',
                    ),
                  if (obj(d[key])['complete'] != true)
                    Text(
                      c.tr(
                        'Incomplete evidence. A complete financial result is unavailable.',
                      ),
                    ),
                ],
              ),
            ),
        for (final order in records(d['orders']))
          ExpansionTile(
            title: Text(
              '${c.tr('Order')} #${order['orderId']} · ${order['state']}',
            ),
            subtitle: Text(
              '${c.tr('New price units')}: ${order['newPriceUnits']} · ${c.tr('Earned at')}: ${order['earnedAt'] ?? c.tr('Unknown')}',
            ),
            children: [
              for (final capture in records(order['captures']))
                Text(
                  '${c.tr('Collection')} · ${capture['state']} · ${financeKnownMoney(capture['amountMinor'], '${capture['currency']}')} · ${capture['providerCaptureId'] ?? c.tr('Unknown')}',
                ),
              if (order['refundAllocationUncertain'] == true)
                Text(c.tr('Refund allocation remains uncertain.')),
              Text(
                '${c.tr('Recorded contribution')}: ${financeKnownMoney(order['contributionMinor'], '${d['currency']}')}',
              ),
            ],
          ),
        if (d['ordersTruncated'] == true)
          Text(
            c.tr(
              'Order preview is partial; period totals include all matched records.',
            ),
          ),
        for (final bill in records(d['supplierPayments']))
          AppNotice(
            title: '${c.tr('Bill')} #${bill['billId']}',
            message:
                '${bill['state']} · ${bill['batchState'] ?? c.tr('No payout recorded')}\n${records(bill['items']).map((i) => '${i['state']} · ${i['providerItemId'] ?? c.tr('Pending')}').join('\n')}',
            icon: Icons.receipt_long,
          ),
        for (final text in (d['limitations'] as List? ?? const []))
          Text('$text'),
        AppButton(label: c.tr('Refresh'), secondary: true, onPressed: refresh),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => DataPage(
    title: context.tr('Compare a pricing decision'),
    load: () async {
      final results = await Future.wait([
        live.api.query(
          'costing.product',
          live.params({'id': widget.productId}),
        ),
        live.api.query('pricing.policy', live.params()),
        live.api.query('pricing.decisions', live.params()),
        live.api.query(
          'costing.investigation',
          live.params({'productId': widget.productId}),
        ),
      ]);
      return {
        'product': results[0],
        'policy': results[1],
        'decisions': results[2],
        'setup': results[3],
      };
    },
    content: (c, d, refresh) {
      final product = obj(d['product']), policy = obj(d['policy']);
      final code = '${product['currency'] ?? 'USD'}';
      String amount(dynamic n) => financeKnownMoney(n, code);
      final valid =
          comparison?['valid'] == true &&
          DateTime.parse(comparison!['expiresAt'] as String)
              .isAfter(DateTime.now());
      return [
        Text('${product['name']}', style: Theme.of(c).textTheme.headlineSmall),
        AppNotice(
          title: c.tr('Investigate a cost change'),
          message: c.tr(
            'Start with one dish. Confirm its supplier evidence, recipe units, yield, packaging and pricing policy. Accounting opening balances are not needed for a cost comparison.',
          ),
          icon: Icons.manage_search,
        ),
        AppButton(
          label: c.tr('Save setup checkpoint'),
          secondary: true,
          onPressed: busy
              ? null
              : () => run(() async {
                  await live.api.command('costing.investigation.checkpoint', {
                    'productId': widget.productId,
                  }, restaurantId: live.restaurantId);
                  if (mounted) refresh();
                }),
        ),
        if (obj(d['setup'])['startedAt'] != null)
          Text(
            '${c.tr('Setup started')}: ${obj(d['setup'])['startedAt']} · ${c.tr('Elapsed setup seconds')}: ${obj(d['setup'])['elapsedSetupSeconds'] ?? c.tr('Pending')}',
          ),
        Text(
          c.tr(
            'Setup timing includes pauses. Research sessions measure active effort separately.',
          ),
        ),
        for (final missing in (product['missing'] as List? ?? const []))
          Text('$missing'),
        AppButton(
          label: c.tr('Review recipe and receipt inputs'),
          secondary: true,
          onPressed: () => Navigator.of(c).pop(),
        ),
        if (product['sample'] == true)
          Text(c.tr('Sample café · illustrative records')),
        AppButton(
          label: c.tr('Resume a saved comparison'),
          secondary: true,
          onPressed: busy ? null : () => history(comparisons: true),
        ),
        Text(c.tr('Volume is an owner assumption, not a forecast.')),
        if (error != null)
          AppNotice(
            title: c.tr('Please review'),
            message: error!,
            icon: Icons.info_outline,
          ),
        AppButton(
          label: c.tr(
            comparison == null
                ? 'Compare options'
                : 'Recalculate as a new revision',
          ),
          icon: Icons.compare_arrows,
          onPressed:
              busy || product['complete'] != true || policy['confirmed'] != true
              ? null
              : () => run(() => compare(policy)),
        ),
        AppButton(
          label: c.tr('Challenge this comparison'),
          secondary: true,
          icon: Icons.auto_awesome,
          onPressed: busy ? null : () => run(challenge),
        ),
        if (comparison != null) ...[
          Text(
            '${c.tr('Revision')} ${comparison!['revision']} · ${comparison!['baselineDefinition']}',
          ),
          if (!valid)
            Text(
              c.tr(
                'Comparison is stale or expired. Recalculate before acting.',
              ),
            ),
          for (final option in records(comparison!['options']))
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.tr(
                      option['key'] == 'keep'
                          ? 'Keep current price'
                          : option['key'] == 'custom'
                          ? 'Owner-entered price'
                          : 'Lowest qualifying price',
                    ),
                    style: Theme.of(c).textTheme.titleLarge,
                  ),
                  Text(
                    '${c.tr('Menu price')}: ${amount(option['priceMinor'])}',
                  ),
                  Text(
                    '${c.tr('Net revenue')}: ${amount(option['netPriceMinor'])} · ${c.tr('Variable cost')}: ${amount(option['costMinor'])}',
                  ),
                  Text(
                    '${c.tr('Estimated fee')}: ${amount(option['feeMinor'])}',
                  ),
                  Text(
                    '${c.tr('Contribution before shared overhead')}: ${amount(option['contributionMinor'])}',
                  ),
                  Text(
                    '${c.tr('Contribution rate')}: ${option['contributionBps'] == null ? c.tr('Unknown') : '${(option['contributionBps'] as num) / 100}%'}',
                  ),
                  Text(
                    '${c.tr('Break-even units')}: ${option['breakEvenUnits'] ?? c.tr('Unknown')}',
                  ),
                  for (final s in records(option['sensitivity']))
                    Text(
                      '${c.tr('Scenario')}: ${(s['volumeChangeBps'] as num) / 100}% · ${s['units']} ${c.tr('Units')} · ${amount(s['contributionMinor'])}',
                    ),
                  if ((option['violations'] as List).isNotEmpty)
                    Text(
                      '${c.tr('Analysis limits')}: ${(option['violations'] as List).join(', ')}',
                    ),
                  if (option['publishable'] == true && live.manager)
                    AppButton(
                      label: c.tr('Prepare review for this price'),
                      onPressed: busy || !valid || review != null
                          ? null
                          : () => run(() => propose(option)),
                    ),
                ],
              ),
            ),
          Text(
            '${c.tr('Required variable-cost reduction')}: ${amount(comparison!['keepPriceCostReductionMinor'])}',
          ),
          Text(
            c.tr(
              'This is a mathematical requirement. No supplier saving or recipe alternative has been verified.',
            ),
          ),
          for (final text in (comparison!['assumptions'] as List))
            Text('$text'),
          if (live.manager)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final choice in ['keep', 'defer', 'reject'])
                  AppButton(
                    label: c.tr(
                      choice == 'keep'
                          ? 'Keep current price'
                          : choice == 'defer'
                          ? 'Defer decision'
                          : 'Reject recommendation',
                    ),
                    secondary: true,
                    onPressed: busy || !valid
                        ? null
                        : () => run(() => decide(choice, refresh)),
                  ),
              ],
            ),
        ],
        if (review != null)
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.tr('Review before publishing'),
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                Text(
                  '${amount(obj(review!['preview'])['fromMinor'])} → ${amount(obj(review!['preview'])['toMinor'])}',
                ),
                Text(
                  c.tr(
                    'Existing orders and checkouts keep their prices. Supplier payment requires separate approval.',
                  ),
                ),
                AppButton(
                  label: c.tr('Approve and publish price'),
                  onPressed: busy
                      ? null
                      : () => run(() async {
                          final result = await live.api.command(
                            'agent.decide',
                            {'decision': 'approve'},
                            restaurantId: live.restaurantId,
                            resourceId: review!['actionId'] as int,
                            version: review!['version'] as int,
                          );
                          if (result['state'] != 'executed') {
                            throw StateError('${result['state']}');
                          }
                          if (mounted) {
                            setState(() {
                              review = null;
                              comparison = null;
                            });
                            refresh();
                          }
                        }),
                ),
                AppButton(
                  label: c.tr('Reject proposal'),
                  secondary: true,
                  onPressed: busy
                      ? null
                      : () => run(() async {
                          await live.api.command(
                            'agent.decide',
                            {'decision': 'reject'},
                            restaurantId: live.restaurantId,
                            resourceId: review!['actionId'] as int,
                            version: review!['version'] as int,
                          );
                          if (mounted) {
                            setState(() => review = null);
                            refresh();
                          }
                        }),
                ),
              ],
            ),
          ),
        Text(
          c.tr('Decisions to revisit'),
          style: Theme.of(c).textTheme.titleLarge,
        ),
        for (final decision in records(obj(d['decisions'])['rows']))
          ListTile(
            title: Text('${decision['productName']} · ${decision['choice']}'),
            subtitle: Text('${decision['at']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => decisionDetail(decision['id'] as int),
          ),
        if (obj(d['decisions'])['nextCursor'] != null)
          AppButton(
            label: c.tr('Load earlier records'),
            secondary: true,
            onPressed: () =>
                history(cursor: obj(d['decisions'])['nextCursor'] as int),
          ),
      ];
    },
  );
}
