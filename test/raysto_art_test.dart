import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/navigation.dart';
import 'package:raysto/design_system/design_system.dart';

void main() {
  testWidgets('large-text navigation opens a scrollable chooser and changes destination', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.reset);
    var selected = 0;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
        child: MotionScope(reducedMotion: true, child: child!),
      ),
      home: StatefulBuilder(builder: (context, change) => Scaffold(
        bottomNavigationBar: RaystoAdaptiveDock(index: selected,
          onChanged: (i) => change(() => selected = i),
          options: const [
            DockDestination('Discover', Icons.explore, Icons.explore),
            DockDestination('Activity', Icons.receipt_long, Icons.receipt_long),
            DockDestination('Restaurants', Icons.storefront, Icons.storefront),
            DockDestination('Account', Icons.person, Icons.person),
          ],
        ),
      )),
    ));
    expect(find.byType(RaystoDock), findsNothing);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurants'));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(find.text('Restaurants · Navigate'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new illustrations settle and reduced motion stops an entrance immediately',
    (tester) async {
      var reduced = false;
      late StateSetter change;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              change = setState;
              return MotionScope(
                reducedMotion: reduced,
                child: Scaffold(
                  body: ListView(
                    children: [
                      for (final scene in RaystoScene.values)
                        RaystoIllustration(scene: scene, height: 80),
                      const RaystoReveal(child: Text('Ready to order')),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      change(() => reduced = true);
      await tester.pump();
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);
      expect(find.text('Ready to order'), findsOneWidget);
      change(() => reduced = false);
      await tester.pumpAndSettle();
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'Decoration must not loop or replay after preferences change.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'four destination dock supports rapid changes, RTL, large text and stable targets',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 780);
      addTearDown(tester.view.reset);
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: StatefulBuilder(
                builder: (context, change) => Scaffold(
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RaystoDock(
                      index: selected,
                      onChanged: (i) => change(() => selected = i),
                      options: const [
                        DockDestination(
                          'Discover',
                          Icons.explore_outlined,
                          Icons.explore,
                        ),
                        DockDestination(
                          'Activity',
                          Icons.receipt_long_outlined,
                          Icons.receipt_long,
                        ),
                        DockDestination(
                          'Restaurants',
                          Icons.storefront_outlined,
                          Icons.storefront,
                        ),
                        DockDestination(
                          'Account',
                          Icons.person_outline,
                          Icons.person,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      for (final index in [3, 0, 2, 1]) {
        final target = find.byKey(ValueKey('dock-$index'));
        expect(tester.getSize(target).shortestSide, greaterThanOrEqualTo(48));
        await tester.tap(target);
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
