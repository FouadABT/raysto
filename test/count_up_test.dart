import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';

String usd(num minor) => '\$${(minor / 100).toStringAsFixed(2)}';

Widget host(Widget child, {bool reduced = false, double scale = 1}) =>
    MotionScope(
      reducedMotion: reduced,
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduced,
          ),
          child: child!,
        ),
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// The number currently painted: the visible copy, not the width holder.
String shown(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: find.byType(CountUp), matching: find.byType(Text)),
    )
    .last
    .data!;

void main() {
  testWidgets('rolls up from zero to the exact value', (tester) async {
    await tester.pumpWidget(host(CountUp(value: 19530, format: usd)));
    await tester.pump(const Duration(milliseconds: 100));
    final mid = double.parse(shown(tester).substring(1));
    expect(mid, inExclusiveRange(0, 195.30));
    await tester.pumpAndSettle();
    expect(shown(tester), '\$195.30');
  });

  testWidgets('a change rolls from the previous value, never from zero', (
    tester,
  ) async {
    late StateSetter update;
    var value = 10000;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return CountUp(value: value, format: usd);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    update(() => value = 12000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(double.parse(shown(tester).substring(1)), greaterThanOrEqualTo(100));
    await tester.pumpAndSettle();
    expect(shown(tester), '\$120.00');
  });

  testWidgets('assistive technology hears only the final value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        CountUp(value: 19530, format: usd, semanticsLabel: 'Paid sales'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Paid sales')),
      matchesSemantics(label: 'Paid sales', value: '\$195.30'),
    );
    semantics.dispose();
  });

  testWidgets('reduced motion shows the value on the first frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(CountUp(value: 19530, format: usd), reduced: true),
    );
    expect(shown(tester), '\$195.30');
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('holds its width at 2× text so nothing beside it moves', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(CountUp(value: 1234567, format: usd), scale: 2),
    );
    final start = tester.getSize(find.byType(CountUp));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CountUp)), start);
    expect(tester.takeException(), isNull);
  });
}
