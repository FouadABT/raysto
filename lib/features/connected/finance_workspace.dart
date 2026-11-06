part of 'connected_app.dart';

/// Native owner costing and price review, using the same server calculations
/// and approval registry as the AG Studio workspace. No client money maths.
class FinanceWorkspace extends StatefulWidget {
  const FinanceWorkspace({super.key, required this.live});
  final LiveContext live;
  @override
  State<FinanceWorkspace> createState() => _FinanceWorkspaceState();
}

String financeKnownMoney(dynamic amount, String code) =>
    amount is num && amount.isFinite ? money(amount, code) : 'Unknown';

class _FinanceWorkspaceState extends State<FinanceWorkspace> {
  late final RestaurantFeed feed = RestaurantFeed(widget.live)..start();
  Json? scenario, review;
  int? selected;
  bool busy = false;
  String? error, note;
  LiveContext get live => widget.live;

  @override
  void dispose() {
    feed.dispose();
    super.dispose();
  }

  Future<Json> load() async {
    final values = await Future.wait([
      live.api.query('costing.products', live.params()),
      live.api.query('pricing.policy', live.params()),
      live.api.query('finance.summary', live.params()),
      live.api.query('finance.policy', live.params()),
    ]);
    final products = [
      for (final row in records(values[0]['rows']))
        ProductCostDto.fromJson(row).data,
    ];
    return {
      'products': {...values[0], 'rows': products},
      'policy': PricingPolicyDto.fromJson(values[1]).data,
      'summary': FinanceSummaryDto.fromJson(values[2]).data,
      'accounting': values[3],
    };
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      note = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> policy(
    Json current,
    List<Json> products,
    VoidCallback refresh,
  ) async {
    final names = {
      for (final p in products)
        '${p['name']} (#${p['productId']})': p['productId'],
    };
    num percent(dynamic n) => (n as num? ?? 0) / 100;
    PendingCommand? pending;
    String? fingerprint;
    final result = await editFields(
      context,
      context.tr('Owner pricing policy'),
      [
        InputSpec('target', context.tr('Target contribution (%)')),
        InputSpec('cap', context.tr('Maximum price increase (%)')),
        InputSpec('increment', context.tr('Price rounding increment')),
        InputSpec('minimum', context.tr('Minimum product price')),
        InputSpec('maximum', context.tr('Maximum product price')),
        InputSpec('fee', context.tr('Estimated payment fee (%)')),
        InputSpec('fixed', context.tr('Estimated fixed fee per item')),
        InputSpec(
          'protected',
          context.tr('Protected products'),
          kind: 'list',
          optional: true,
          children: [
            InputSpec(
              'product',
              context.tr('Product'),
              options: names.keys.toList(),
            ),
          ],
        ),
      ],
      initial: {
        'target': current['targetBps'] == null
            ? ''
            : '${percent(current['targetBps'])}',
        'cap': '${percent(current['maxIncreaseBps'])}',
        'increment': '${percent(current['incrementMinor'])}',
        'minimum': '${percent(current['minimumMinor'])}',
        'maximum': '${percent(current['maximumMinor'])}',
        'fee': '${percent(current['feeBps'])}',
        'fixed': '${percent(current['feeFixedMinor'])}',
        'protected': [
          for (final id in current['excludedProducts'] as List? ?? const [])
            {
              'product': names.entries
                  .where((e) => e.value == id)
                  .firstOrNull
                  ?.key,
            },
        ],
      },
      save: (d) async {
        int scaled(String field) {
          final n = num.tryParse('${d[field]}'.replaceAll(',', '.'));
          if (n == null || !n.isFinite) {
            throw const PlatformFailure(
              'invalid_input',
              'Enter a valid decimal amount.',
            );
          }
          return (n * 100).round();
        }

        final data = {
          'targetBps': scaled('target'),
          'maxIncreaseBps': scaled('cap'),
          'incrementMinor': scaled('increment'),
          'minimumMinor': scaled('minimum'),
          'maximumMinor': scaled('maximum'),
          'feeBps': scaled('fee'),
          'feeFixedMinor': scaled('fixed'),
          'excludedProducts': [
            for (final p in records(d['protected'])) names[p['product']],
          ],
        };
        final next = jsonEncode(data);
        if (pending == null || fingerprint != next) {
          pending = live.api.prepare(
            'pricing.policy.save',
            data,
            restaurantId: live.restaurantId,
            version: current['version'] as int,
          );
          fingerprint = next;
        }
        return live.api.submit(pending!);
      },
    );
    if (result != null && mounted) {
      setState(() {
        scenario = null;
        review = null;
      });
      refresh();
    }
  }

  Future<void> calculate(Json product) async {
    PendingCommand? pending;
    String? fingerprint;
    final result = await editFields(
      context,
      context.tr('Price scenario'),
      [
        InputSpec('baselineUnits', context.tr('Baseline units'), kind: 'int'),
        InputSpec(
          'volume',
          context.tr('Assumed volume change (%)'),
          help: context.tr('This is an assumption, not a forecast.'),
        ),
      ],
      initial: const {'baselineUnits': 100, 'volume': '-10'},
      save: (d) async {
        final volume = num.tryParse('${d['volume']}'.replaceAll(',', '.'));
        if (volume == null || !volume.isFinite) {
          throw const PlatformFailure(
            'invalid_input',
            'Enter a valid percentage.',
          );
        }
        final data = {
          'productId': product['productId'],
          'baselineUnits': d['baselineUnits'],
          'volumeChangeBps': (volume * 100).round(),
        };
        final next = jsonEncode(data);
        if (pending == null || fingerprint != next) {
          pending = live.api.prepare(
            'pricing.scenario.create',
            data,
            restaurantId: live.restaurantId,
          );
          fingerprint = next;
        }
        return live.api.submit(pending!);
      },
      submit: context.tr('Calculate scenario'),
    );
    if (result != null && mounted) {
      setState(() {
        scenario = PricingScenarioDto.fromJson(result).data;
        review = null;
      });
    }
  }

  Future<void> accounting(VoidCallback refresh) async {
    final result = await live.action(
      context,
      context.tr('Review accounting cutover'),
      'finance.policy.save',
      version: 0,
      fields: [
        InputSpec('reason', context.tr('Review notes')),
        InputSpec(
          'opening',
          context.tr('Reviewed opening balances'),
          kind: 'list',
          optional: true,
          children: [
            InputSpec(
              'account',
              context.tr('Account'),
              options: const [
                '1000',
                '1010',
                '1100',
                '1200',
                '2000',
                '2050',
                '2100',
                '2110',
                '2200',
                '2250',
                '2300',
                '3000',
              ],
            ),
            InputSpec(
              'debitMinor',
              context.tr('Debit amount'),
              kind: 'money',
              value: 0,
            ),
            InputSpec(
              'creditMinor',
              context.tr('Credit amount'),
              kind: 'money',
              value: 0,
            ),
          ],
        ),
        InputSpec(
          'reviewed',
          context.tr(
            'I reviewed these balances. An empty list means zero balances.',
          ),
          kind: 'bool',
        ),
      ],
    );
    if (result != null) refresh();
  }

  Future<void> investigate(Json? product) async {
    final result = await live.action(
      context,
      context.tr('Investigate the evidence'),
      'finance.investigate',
      fields: [InputSpec('text', context.tr('Question'))],
      fixed: {
        if (product != null) 'productId': product['productId'],
        if (scenario != null) 'scenarioId': scenario!['id'],
      },
    );
    if (result == null || !mounted) return;
    await push(
      context,
      DataPage(
        title: context.tr('Financial analysis'),
        trigger: feed,
        load: () => live.api.query(
          'finance.analysis',
          live.params({'id': result['taskId']}),
        ),
        content: (c, d, refresh) => [
          AppNotice(
            title: c.tr('Evidence-based investigation'),
            message: '${d['summary'] ?? d['status'] ?? 'Pending'}',
            icon: Icons.manage_search,
          ),
          if (d['source'] != null) Text('${c.tr('Source')}: ${d['source']}'),
          if (d['scenario'] is Map)
            AppButton(
              label: c.tr('Review scenario'),
              icon: Icons.analytics_outlined,
              onPressed: () {
                setState(() {
                  scenario = PricingScenarioDto.fromJson(obj(d['scenario']))
                      .data;
                  review = null;
                });
                Navigator.of(c).pop();
              },
            ),
          for (final entry in obj(d['evidence']).entries) ...[
            Text(entry.key, style: Theme.of(c).textTheme.titleMedium),
            if (obj(entry.value)['replacementCostMinor'] != null)
              Text(
                '${c.tr('Replacement cost')}: ${money(obj(entry.value)['replacementCostMinor'] as num, '${product?['currency'] ?? 'USD'}')}',
              ),
            for (final line in records(obj(entry.value)['lines']))
              ListTile(
                title: Text('${line['name']}'),
                subtitle: Text(
                  '${c.tr('Receipt')} #${obj(line['source'])['id'] ?? c.tr('Unknown')}',
                ),
              ),
          ],
          AppButton(
            label: c.tr('Refresh analysis'),
            secondary: true,
            onPressed: refresh,
          ),
        ],
      ),
    );
  }

  Future<void> propose() async {
    final value = scenario;
    if (value == null) return;
    final current = await live.api.query(
      'pricing.scenario',
      live.params({'id': value['id']}),
    );
    if (current['validForPublication'] != true) {
      throw const PlatformFailure(
        'stale',
        'Recalculate before preparing this price change.',
      );
    }
    final result = await live.api.command('pricing.propose', {
      'scenarioId': value['id'],
    }, restaurantId: live.restaurantId);
    if (mounted) {
      setState(
        () => review = {
          'id': result['actionId'],
          'version': result['version'],
          'preview': result['preview'],
          'agent': 'pricing',
          'status': 'pending',
          'risk': 'catalogue',
          'title': context.tr('Review menu price change'),
          'rationale': context.tr(
            'Changes new quotes after approval. Existing orders and PayPal amounts stay frozen.',
          ),
          'evidence': {
            'source': 'Server-calculated scenario',
            'scenarioId': value['id'],
          },
        },
      );
    }
  }

  Future<void> recipe(Json product, VoidCallback refresh) async {
    final stock = <Json>[];
    int? cursor;
    do {
      final page = await live.api.query(
        'stock',
        live.params({'limit': 100, 'cursor': ?cursor}),
      );
      stock.addAll(records(page['rows']));
      cursor = page['nextCursor'] as int?;
    } while (cursor != null && stock.length < 1000);
    if (!mounted) return;
    if (cursor != null) {
      throw const PlatformFailure(
        'page_required',
        'Narrow the stock list before editing this recipe.',
      );
    }
    final labels = {
      for (final s in stock) '${s['name']} · ${s['unit']}': s['id'],
    };
    final modifiers = {
      for (final m in records(product['modifierOptions']))
        '${m['name']}': m['id'],
    };
    final raw = obj(product['recipe']);
    final source = records(raw['lines']).isNotEmpty
        ? records(raw['lines'])
        : records(product['lines']);
    final initialLines = [
      for (final l in source)
        {
          'ingredient': labels.entries
              .where((e) => e.value == l['stockItemId'])
              .firstOrNull
              ?.key,
          'quantity': ((l['quantityMicros'] as num) / 1000000).toString(),
          'unit': l['unit'] ?? l['purchaseUnit'],
          'yield': '${(l['yieldBps'] as num? ?? 10000) / 100}',
          'packSize': ((l['packSizeMicros'] as num? ?? 1000000) / 1000000)
              .toString(),
          if (l['option'] != null)
            'modifier': modifiers.entries
                .where((e) => e.value == l['option'])
                .firstOrNull
                ?.key,
          'mode': l['mode'] ?? 'add',
        },
    ];
    PendingCommand? pending;
    String? fingerprint;
    final result = await editFields(
      context,
      context.tr('Recipe and packaging'),
      [
        InputSpec(
          'lines',
          context.tr('Ingredients'),
          kind: 'list',
          children: [
            InputSpec(
              'ingredient',
              context.tr('Ingredient'),
              options: labels.keys.toList(),
            ),
            InputSpec('quantity', context.tr('Quantity per portion')),
            InputSpec(
              'unit',
              context.tr('Recipe unit'),
              options: const ['g', 'kg', 'ml', 'l', 'piece', 'unit'],
            ),
            InputSpec('yield', context.tr('Usable yield (%)'), value: '100'),
            InputSpec(
              'packSize',
              context.tr('Units covered by receipt price'),
              value: '1',
            ),
            InputSpec(
              'modifier',
              context.tr('Modifier reference'),
              options: modifiers.keys.toList(),
              optional: true,
            ),
            InputSpec(
              'mode',
              context.tr('Modifier adjustment'),
              options: const ['add', 'remove'],
              value: 'add',
            ),
          ],
        ),
        InputSpec('packaging', context.tr('Packaging per portion')),
        InputSpec(
          'packagingConfirmed',
          context.tr('Packaging cost confirmed, including a genuine zero'),
          kind: 'bool',
        ),
      ],
      initial: {
        'lines': initialLines,
        'packaging': '${(product['packagingMinor'] as num? ?? 0) / 100}',
        'packagingConfirmed': raw['packagingConfirmed'] ?? false,
      },
      save: (input) async {
        final packaging = num.tryParse(
          '${input['packaging']}'.replaceAll(',', '.'),
        );
        if (packaging == null || !packaging.isFinite) {
          throw const PlatformFailure(
            'invalid_input',
            'Enter a valid packaging amount.',
          );
        }
        final data = {
          'productId': product['productId'],
          'packagingMinor': (packaging * 100).round(),
          'packagingConfirmed': input['packagingConfirmed'],
          'lines': [
            for (final l in records(input['lines']))
              {
                'stockItemId': labels[l['ingredient']],
                'quantity': l['quantity'],
                'unit': l['unit'],
                'yieldBps':
                    ((num.tryParse('${l['yield']}'.replaceAll(',', '.')) ??
                                -1) *
                            100)
                        .round(),
                'packSize': l['packSize'],
                'mode': l['mode'],
                if (l['modifier'] != null) 'option': modifiers[l['modifier']],
              },
          ],
        };
        final next = jsonEncode(data);
        if (pending == null || fingerprint != next) {
          pending = live.api.prepare(
            'costing.recipe.save',
            data,
            restaurantId: live.restaurantId,
            version: product['recipeVersion'] as int,
          );
          fingerprint = next;
        }
        return live.api.submit(pending!);
      },
    );
    if (result != null && mounted) {
      setState(() {
        scenario = null;
        review = null;
      });
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) => DataPage(
    title: context.tr('Sales and margins'),
    trigger: feed,
    load: load,
    content: (c, data, refresh) {
      final products = records(obj(data['products'])['rows']);
      final policyValue = obj(data['policy']), summary = obj(data['summary']);
      final product =
          products.where((p) => p['productId'] == selected).firstOrNull ??
          products.firstOrNull;
      final code = '${summary['currency'] ?? product?['currency'] ?? 'USD'}';
      String amount(dynamic n) => n is num ? money(n, code) : c.tr('Unknown');
      return [
        RaystoStoryHeader(
          eyebrow: c.tr('Restaurant finances'),
          title: c.tr('Understand the cost. Review the decision.'),
          message: c.tr(
            'Receipt-backed costs and owner-defined scenarios. No payment is made from a chart.',
          ),
          scene: RaystoScene.kitchen,
          compact: true,
        ),
        if (error != null)
          AppNotice(
            title: c.tr('Action could not complete'),
            message: error,
            icon: Icons.info_outline,
          ),
        if (note != null)
          AppNotice(title: note!, icon: Icons.check_circle_outline),
        if (live.manager)
          AppButton(
            label: c.tr('Add or edit a menu dish'),
            secondary: true,
            icon: Icons.restaurant_menu,
            onPressed: () async {
              await push(c, menuPage(live));
              if (mounted) refresh();
            },
          ),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${summary['basisLabel']}',
                style: Theme.of(c).textTheme.titleMedium,
              ),
              Text(
                '${c.tr('Recorded net sales')}: ${amount(summary['netSalesMinor'])}',
              ),
              Text(
                '${c.tr('Recognized costs')}: ${amount(summary['recognizedCostsMinor'])}',
              ),
              Text(
                '${c.tr(summary['operatingResultMinor'] == null ? 'Recorded result' : 'Operating result')}: ${amount(summary['operatingResultMinor'] ?? summary['recordedResultMinor'])}',
              ),
              if (summary['basis'] == 'management-accrual-v1') ...[
                Text(
                  '${c.tr('Collected money')}: ${amount(summary['collectedMoneyMinor'])}',
                ),
                Text(
                  '${c.tr('Recorded cash position')}: ${amount(summary['recordedCashPositionMinor'])}',
                ),
                Text(
                  '${c.tr('Payables')}: ${amount(summary['payablesMinor'])}',
                ),
                Text(
                  '${c.tr('Receivables')}: ${amount(summary['receivablesMinor'])}',
                ),
                Text(
                  '${c.tr('Customer deposits')}: ${amount(summary['customerDepositsMinor'])}',
                ),
              ],
              for (final line in summary['limitations'] as List? ?? const [])
                Text('$line'),
            ],
          ),
        ),
        AppButton(
          label: c.tr('Owner pricing policy'),
          icon: Icons.tune,
          secondary: true,
          onPressed: busy || live.role != 'owner'
              ? null
              : () => run(() => policy(policyValue, products, refresh)),
        ),
        if (obj(data['accounting'])['configured'] != true &&
            live.role == 'owner')
          AppButton(
            label: c.tr('Review accounting cutover'),
            secondary: true,
            icon: Icons.fact_check_outlined,
            onPressed: busy ? null : () => run(() => accounting(refresh)),
          ),
        AppButton(
          label: c.tr('Investigate the evidence'),
          secondary: true,
          icon: Icons.manage_search,
          onPressed: busy ? null : () => run(() => investigate(product)),
        ),
        if (products.isNotEmpty)
          DropdownButtonFormField<int>(
            key: ValueKey(product?['productId']),
            initialValue: product?['productId'] as int?,
            isExpanded: true,
            decoration: InputDecoration(labelText: c.tr('Inspect a dish')),
            items: [
              for (final p in products)
                DropdownMenuItem(
                  value: p['productId'] as int,
                  child: Text('${p['name']}'),
                ),
            ],
            onChanged: busy
                ? null
                : (v) => setState(() {
                    selected = v;
                    scenario = null;
                    review = null;
                  }),
          ),
        if (product != null) ...[
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product['name']}',
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                Text('${c.tr('Menu price')}: ${amount(product['priceMinor'])}'),
                Text(
                  '${c.tr('Replacement cost')}: ${amount(product['replacementCostMinor'])}',
                ),
                Text(
                  '${c.tr('Contribution before fees and overhead')}: ${amount(product['contributionMinor'])}',
                ),
                if (obj(product['change'])['complete'] == true) ...[
                  Text(
                    '${c.tr('Recorded recipe-cost change')}: ${amount(obj(product['change'])['costIncreaseMinor'])}',
                  ),
                  Text('${obj(product['change'])['assumption']}'),
                ],
                for (final issue in product['missing'] as List? ?? const [])
                  Text('• $issue'),
                for (final line in records(product['lines']))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${line['name']} · ${(line['quantityMicros'] as num) / 1000000} ${line['unit'] ?? line['purchaseUnit']}',
                    ),
                    subtitle: Text(
                      '${c.tr('Receipt')} #${obj(line['source'])['id'] ?? c.tr('Unknown')}',
                    ),
                    trailing: Text(amount(line['costMinor'])),
                    onTap: obj(line['source'])['id'] == null
                        ? null
                        : () => push(
                            c,
                            DataPage(
                              title: c.tr('Confirmed receipt evidence'),
                              load: () => live.api.query(
                                'finance.evidence',
                                live.params({'id': obj(line['source'])['id']}),
                              ),
                              content: (context, record, reload) => [
                                Text(
                                  '${record['ingredient']} · ${record['quantity']} ${record['purchaseUnit']}',
                                ),
                                Text(
                                  '${c.tr('Receipt unit cost')}: ${amount(record['unitCostMinor'])}',
                                ),
                                Text('${record['at']}'),
                                for (final issue
                                    in record['limitations'] as List? ??
                                        const [])
                                  Text('$issue'),
                                if (record['mediaId'] != null)
                                  AppButton(
                                    label: c.tr('Open source document'),
                                    icon: Icons.description_outlined,
                                    onPressed: () => showFile(
                                      context,
                                      live,
                                      record['mediaId'] as int,
                                    ),
                                  ),
                                if (record['purchaseUnit'] == null &&
                                    live.manager)
                                  AppButton(
                                    label: c.tr(
                                      'Confirm original receipt unit',
                                    ),
                                    secondary: true,
                                    onPressed: () async {
                                      final result = await live.action(
                                        context,
                                        c.tr('Confirm original receipt unit'),
                                        'costing.receipt.confirm',
                                        id: record['id'] as int,
                                        fields: [
                                          InputSpec(
                                            'purchaseUnit',
                                            c.tr(
                                              'Unit stated on the original receipt',
                                            ),
                                            options: const [
                                              'g',
                                              'kg',
                                              'ml',
                                              'l',
                                              'piece',
                                              'unit',
                                              'box',
                                            ],
                                          ),
                                          InputSpec(
                                            'reason',
                                            c.tr('Evidence and review notes'),
                                          ),
                                          InputSpec(
                                            'reviewed',
                                            c.tr(
                                              'I checked the original receipt. I am not inferring its unit.',
                                            ),
                                            kind: 'bool',
                                          ),
                                        ],
                                      );
                                      if (result != null) await reload();
                                    },
                                  ),
                              ],
                            ),
                          ),
                  ),
              ],
            ),
          ),
          AppButton(
            label: c.tr('Edit recipe and packaging'),
            secondary: true,
            icon: Icons.edit_outlined,
            onPressed: busy || !live.manager
                ? null
                : () => run(() => recipe(product, refresh)),
          ),
          AppButton(
            label: c.tr('Calculate scenario'),
            icon: Icons.analytics_outlined,
            onPressed:
                busy ||
                    product['complete'] != true ||
                    policyValue['confirmed'] != true
                ? null
                : () => run(() => calculate(product)),
          ),
          AppButton(
            label: c.tr('Compare a pricing decision'),
            icon: Icons.compare_arrows,
            onPressed: () => push(
              c,
              PriceComparisonPage(
                live: live,
                productId: product['productId'] as int,
              ),
            ),
          ),
          if (policyValue['confirmed'] != true)
            Text(c.tr('The owner must confirm a contribution target first.')),
        ],
        if (scenario != null)
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.tr('Scenario · demand response is assumed'),
                  style: Theme.of(c).textTheme.titleMedium,
                ),
                if (scenario!['kind'] == 'price-restoration')
                  Text(
                    c.tr(
                      'Restoring a previous price uses current costs. Review the contribution target before publishing.',
                    ),
                  ),
                Text(
                  '${c.tr('Current price')}: ${amount(obj(scenario!['current'])['priceMinor'])}',
                ),
                Text(
                  '${c.tr('Candidate price')}: ${amount(obj(scenario!['recommended'])['priceMinor'])}',
                ),
                Text(
                  '${c.tr('Break-even units')}: ${scenario!['breakEvenUnits'] ?? c.tr('Not applicable')}',
                ),
                for (final row in records(scenario!['sensitivity']))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${(row['volumeChangeBps'] as num) / 100}% · ${row['units']} ${c.tr('units')}',
                    ),
                    subtitle: Text(
                      '${c.tr('Projected contribution')}: ${amount(row['contributionMinor'])}',
                    ),
                  ),
                for (final assumption
                    in scenario!['assumptions'] as List? ?? const [])
                  Text('$assumption'),
                if (scenario!['feasible'] != true)
                  Text(
                    c.tr('The target cannot be met within the owner’s limits.'),
                  ),
                AppButton(
                  label: c.tr('Prepare price review'),
                  icon: Icons.fact_check_outlined,
                  onPressed:
                      busy ||
                          !live.manager ||
                          review != null ||
                          scenario!['feasible'] != true ||
                          obj(scenario!['recommended'])['priceMinor'] ==
                              obj(scenario!['current'])['priceMinor']
                      ? null
                      : () => run(propose),
                ),
              ],
            ),
          ),
        if (review != null)
          AgentActionCard(
            live: live,
            action: review!,
            onDone: () async {
              if (mounted) {
                setState(() {
                  scenario = null;
                  review = null;
                  note = context.tr(
                    'The reviewed action finished. Check its recorded outcome.',
                  );
                });
              }
              refresh();
            },
          ),
        tile(
          c.tr('Price-change history'),
          Icons.history,
          () => push(
            c,
            DataPage(
              title: c.tr('Price-change history'),
              load: () => live.api.query('pricing.history', live.params()),
              content: (context, d, _) => [
                for (final r in records(d['rows']))
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${amount(r['fromMinor'])} → ${amount(r['toMinor'])}',
                        ),
                        Text('${r['effectiveAt']}'),
                        Text('${c.tr('Reviewed action')} #${r['actionId']}'),
                        AppButton(
                          label: c.tr('Compare restoring this price'),
                          secondary: true,
                          onPressed: () async {
                            final result = await live.action(
                              context,
                              c.tr('Compare restoring this price'),
                              'pricing.undo.scenario',
                              id: r['id'] as int,
                              submit: c.tr('Calculate scenario'),
                            );
                            if (result != null && mounted && context.mounted) {
                              setState(() {
                                selected = result['productId'] as int;
                                scenario = PricingScenarioDto.fromJson(result)
                                    .data;
                                review = null;
                              });
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        tile(
          c.tr('Bills and payments'),
          Icons.receipt_long_outlined,
          () => push(c, AccountantPage(live: live)),
        ),
        tile(
          c.tr('Stock and supplies'),
          Icons.inventory_2_outlined,
          () => push(c, SuppliesPage(live: live)),
        ),
        tile(
          c.tr('AI proposals'),
          Icons.auto_awesome,
          () => push(c, agentsPage(live)),
        ),
      ];
    },
  );
}
