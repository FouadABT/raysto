import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/l10n/app_localizations.dart';

String usd(num minor) => '\$${(minor / 100).toStringAsFixed(2)}';

const week = [
  ChartPoint('Wed', 0),
  ChartPoint('Thu', 0),
  ChartPoint('Fri', 1350),
  ChartPoint('Sat', 4280),
  ChartPoint('Sun', 3150),
  ChartPoint('Mon', 8600),
  ChartPoint('Tue', 2150),
];
const sample = [41200, 44800, 52600, 61900, 48300, 33700, 36100];

Widget host(
  Widget child, {
  double scale = 1,
  String locale = 'en',
  bool reduced = false,
}) => MotionScope(
  reducedMotion: reduced,
  child: MaterialApp(
    theme: AppTheme.light,
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: reduced,
      ),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  ),
);

Widget dashboard() => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const RaystoSparkline(
      values: [0, 0, 1350, 4280, 3150, 8600, 2150],
      semanticLabel: 'Paid sales, last 7 days',
    ),
    const SizedBox(height: 16),
    RaystoAreaChart(
      points: week,
      sample: sample,
      format: usd,
      semanticLabel: 'Paid sales by day',
    ),
    const SizedBox(height: 16),
    RaystoDonut(
      slices: const [
        ChartSlice('Pickup', 15100),
        ChartSlice('Counter', 3080),
        ChartSlice('Table', 1350),
      ],
      format: usd,
      semanticLabel: 'Sales by channel',
    ),
    const SizedBox(height: 16),
    RaystoRing(
      value: 2150 / 30000,
      semanticLabel: 'Daily target',
      semanticValue: '\$21.50 of \$300.00, 7%',
      center: const Text('7%'),
    ),
  ],
);

void main() {
  for (final (name, size, scale, locale) in [
    ('phone at 2× text', const Size(320, 800), 2.0, 'en'),
    ('tablet', const Size(1280, 800), 1.0, 'en'),
    ('Arabic at 2× text', const Size(320, 800), 2.0, 'ar'),
    ('landscape phone', const Size(800, 360), 1.0, 'en'),
  ]) {
    testWidgets('charts lay out without overflow: $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(dashboard(), scale: scale, locale: locale));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sample · not real sales'), findsOneWidget);
      expect(find.text('Pickup'), findsOneWidget);
    });
  }

  testWidgets('charts describe themselves to assistive technology', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(dashboard(), reduced: true));
    await tester.pump();
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Paid sales by day'))
          .getSemanticsData()
          .value,
      allOf(contains('Mon \$86.00'), contains('Sample · not real sales')),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Daily target')),
      matchesSemantics(
        label: 'Daily target',
        value: '\$21.50 of \$300.00, 7%',
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Sales by channel'))
          .getSemanticsData()
          .value,
      contains('Pickup \$151.00, 77%'),
    );
    semantics.dispose();
  });

  testWidgets('reduced motion paints the final state at once', (tester) async {
    await tester.pumpWidget(host(dashboard(), reduced: true));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('charts draw once and not again when the data refreshes', (
    tester,
  ) async {
    late StateSetter update;
    var values = <num>[1, 2, 3];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return RaystoSparkline(values: values, semanticLabel: 'Orders');
          },
        ),
      ),
    );
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    update(() => values = [3, 2, 1]);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
