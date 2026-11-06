import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';

import 'accountant_app_test.dart' as support;

class FinanceApi extends support.AccountantApi {
  bool complete = true;
  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> p = const {},
  ]) async => switch (operation) {
    'costing.products' => {
      'rows': [
        {
          'productId': 1,
          'name': 'Café sandwich',
          'priceMinor': 900,
          'currency': 'USD',
          'replacementCostMinor': complete ? 385 : null,
          'contributionMinor': complete ? 515 : null,
          'complete': complete,
          'recipeVersion': 1,
          'packagingMinor': 0,
          'recipe': {'packagingConfirmed': true, 'lines': []},
          'lines': [],
          'missing': [if (!complete) 'No confirmed ingredient receipt.'],
        },
      ],
    },
    'pricing.policy' => {
      'version': 1,
      'confirmed': true,
      'targetBps': 6000,
      'maxIncreaseBps': 1000,
      'incrementMinor': 10,
      'minimumMinor': 1,
      'maximumMinor': 100000000,
      'feeBps': 0,
      'feeFixedMinor': 0,
      'excludedProducts': [],
    },
    'costing.product' =>
      ((await query('costing.products'))['rows'] as List).first,
    'pricing.decisions' => {'rows': [], 'nextCursor': null},
    'costing.investigation' => {'ready': complete, 'stepsSaved': false},
    'pricing.comparisons' => {
      'rows': [comparison],
      'nextCursor': null,
    },
    'pricing.comparison' => comparison,
    'finance.policy' => {'configured': true, 'version': 1},
    'finance.summary' => {
      'basis': 'management-accrual-v1',
      'basisLabel': 'Management accrual',
      'currency': 'USD',
      'netSalesMinor': 900,
      'recognizedCostsMinor': 385,
      'recordedResultMinor': 515,
      'operatingResultMinor': 515,
      'limitations': ['Recorded cash is not a verified bank balance.'],
    },
    'pricing.scenario' => {'validForPublication': true},
    _ => super.query(operation, p),
  };
  Map<String, dynamic> get comparison => {
    'id': 40,
    'revision': 1,
    'productId': 1,
    'productName': 'Café sandwich',
    'currency': 'USD',
    'sample': true,
    'valid': true,
    'expiresAt': '2099-01-01T00:00:00Z',
    'baselineDefinition': 'Keep current price with confirmed cost',
    'inputs': {
      'baselineUnits': 100,
      'volumeChangeBps': -1000,
      'maxIncreaseBps': 1000,
      'candidatePriceMinor': null,
    },
    'keepPriceCostReductionMinor': 25,
    'assumptions': ['Volume response is an assumption.'],
    'options': [
      for (final pair in [('keep', 900, 515), ('recommended', 970, 585)])
        {
          'key': pair.$1,
          'priceMinor': pair.$2,
          'netPriceMinor': pair.$2,
          'costMinor': 385,
          'feeMinor': 0,
          'contributionMinor': pair.$3,
          'contributionBps': pair.$1 == 'keep' ? 5722 : 6030,
          'breakEvenUnits': pair.$1 == 'keep' ? 100 : 89,
          'publishable': pair.$1 != 'keep',
          'violations': [],
          'sensitivity': [
            {
              'volumeChangeBps': -1000,
              'units': 90,
              'contributionMinor': pair.$3 * 90,
            },
          ],
        },
    ],
  };
  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    sent.add(command);
    if (command.operation == 'pricing.scenario.create') {
      return {
        'id': 20,
        'productId': 1,
        'expiresAt': '2099-01-01T00:00:00Z',
        'feasible': true,
        'current': {'priceMinor': 900},
        'recommended': {'priceMinor': 970},
        'breakEvenUnits': 89,
        'sensitivity': [
          {'volumeChangeBps': 0, 'units': 100, 'contributionMinor': 58500},
          {'volumeChangeBps': -1000, 'units': 90, 'contributionMinor': 52650},
        ],
        'assumptions': ['Volume response is assumed, not predicted.'],
      };
    }
    if (command.operation == 'pricing.propose') {
      return {
        'actionId': 30,
        'version': 1,
        'preview': {'fromMinor': 900, 'toMinor': 970, 'currency': 'USD'},
      };
    }
    return {};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(
        rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
      );
    }
    await fonts.load();
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  });
  late FinanceApi api;
  late LiveContext live;
  setUp(() {
    api = FinanceApi();
    live = LiveContext(
      support.Runtime(api),
      restaurantId: 1,
      role: 'owner',
      name: 'Café',
    );
  });
  test('unknown amounts stay unknown', () {
    expect(financeKnownMoney(null, 'USD'), 'Unknown');
    expect(financeKnownMoney(0, 'USD'), contains('0.00'));
  });
  for (final locale in ['en', 'fr', 'ar']) {
    testWidgets(
      'native comparison resumes saved evidence at 320px and 2x text in $locale',
      (tester) async {
        await support.size(tester, const Size(320, 800));
        await tester.pumpWidget(
          support.host(
            PriceComparisonPage(live: live, productId: 1),
            locale: locale,
          ),
        );
        await tester.pumpAndSettle();
        final label = locale == 'ar'
            ? 'استئناف مقارنة محفوظة'
            : locale == 'fr'
            ? 'Reprendre une comparaison enregistrée'
            : 'Resume a saved comparison';
        await tester.scrollUntilVisible(
          find.text(label),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.widgetWithText(AppButton, label));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.widgetWithText(AppButton, label),
            matching: find.byType(InkWell),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Café sandwich').last);
        await tester.pumpAndSettle();
        final target = locale == 'ar'
            ? 'أقل سعر يحقق الشروط'
            : locale == 'fr'
            ? 'Plus bas prix conforme'
            : 'Lowest qualifying price';
        await tester.scrollUntilVisible(
          find.text(target),
          220,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 40,
        );
        expect(find.text(target), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(api.sent, isEmpty);
      },
    );
  }
  for (final size in [
    const Size(320, 800),
    const Size(800, 360),
    const Size(1024, 800),
  ]) {
    testWidgets('financial evidence remains usable at $size and 2x text', (
      tester,
    ) async {
      await support.size(tester, size);
      await tester.pumpWidget(support.host(FinanceWorkspace(live: live)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final list = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Calculate scenario'),
        200,
        scrollable: list,
      );
      await tester.ensureVisible(find.widgetWithText(AppButton, 'Calculate scenario'));
      await tester.pumpAndSettle();
      Finder ink(String label) => find.descendant(
        of: find.widgetWithText(AppButton, label),
        matching: find.byType(InkWell),
      );
      await tester.tap(ink('Calculate scenario'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final calculate = find.widgetWithText(AppButton, 'Calculate scenario').last;
      await tester.ensureVisible(calculate);
      await tester.pumpAndSettle();
      await tester.tap(ink('Calculate scenario').last);
      await tester.pumpAndSettle();
      final sent = api.sent
          .where((p) => p.operation == 'pricing.scenario.create')
          .toList();
      expect(sent.length, 1);
      expect(jsonDecode(sent.single.body['dataJson'] as String), {
        'productId': 1,
        'baselineUnits': 100,
        'volumeChangeBps': -1000,
      });
      await tester.scrollUntilVisible(
        find.text('Prepare price review'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      // Computing a scenario must not publish any price or payment.
      expect(
        api.sent.any(
          (p) => p.operation == 'menu.price.apply' || p.operation == 'bill.pay',
        ),
        false,
      );
    });
  }
  testWidgets('incomplete costs visibly refuse a scenario', (tester) async {
    api.complete = false;
    await support.size(tester, const Size(320, 800));
    await tester.pumpWidget(
      support.host(FinanceWorkspace(live: live), scale: 1),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('No confirmed ingredient receipt.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.textContaining('No confirmed ingredient receipt.'),
      findsOneWidget,
    );
    expect(api.sent, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Arabic finance controls retain RTL at 2x text', (tester) async {
    await support.size(tester, const Size(320, 800));
    await tester.pumpWidget(
      support.host(FinanceWorkspace(live: live), locale: 'ar'),
    );
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(FinanceWorkspace))),
      TextDirection.rtl,
    );
    await tester.scrollUntilVisible(
      find.text('حساب السيناريو'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
