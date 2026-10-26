// Explicit visual-review capture utility; not part of the normal test suite.
// flutter test tool/render_preview_test.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/app.dart';
import 'package:raysto/app/preview_store.dart';
import 'package:raysto/design_system/design_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final jakarta = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      jakarta.addFont(
        rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
      );
    }
    await jakarta.load();
    for (final (family, file) in [
      ('PhosphorRegular', 'Phosphor.ttf'),
      ('PhosphorFill', 'Phosphor-Fill.ttf'),
    ]) {
      await (FontLoader('packages/phosphor_flutter/$family')..addFont(
            rootBundle.load('packages/phosphor_flutter/lib/fonts/$file'),
          ))
          .load();
    }
  });
  testWidgets('capture mobile review screens using bundled fonts and assets', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final store = PreviewStore();
    const boundary = Key('review-canvas');
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: RaystoApp(store: store),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    await tester.runAsync(() async {
      for (final dish in sampleDishes) {
        await precacheImage(AssetImage(dish.asset), context);
      }
    });
    await tester.pumpAndSettle();
    Future<void> capture(String name) => expectLater(
      find.byKey(boundary),
      matchesGoldenFile('../docs/screenshots/$name.png'),
    );
    await capture('discover');
    await tester.tap(find.byKey(const ValueKey('dock-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('navigation-in-motion');
    await tester.pumpAndSettle();
    await capture('menu');
    await tester.tap(find.byKey(const ValueKey('dock-2')));
    await tester.pumpAndSettle();
    await capture('saved-empty');
    store.save(
      SavedDish(
        dish: sampleDishes.first,
        collection: 'A favorite',
        note: 'For a slow Sunday.',
      ),
    );
    await tester.pumpAndSettle();
    await capture('saved');
    Navigator.of(context).pushNamed('/dish/bowl');
    await tester.pumpAndSettle();
    await capture('dish');
    await tester.tap(find.widgetWithText(AppButton, 'Edit saved idea'));
    await tester.pumpAndSettle();
    await capture('save-sheet');
    await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
    await tester.pumpAndSettle();
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    Navigator.of(context).pushNamed('/preferences');
    await tester.pumpAndSettle();
    await capture('preferences');
    Navigator.of(context).pushNamed('/gallery');
    await tester.pumpAndSettle();
    await capture('gallery');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    store.dispose();
  });
}
