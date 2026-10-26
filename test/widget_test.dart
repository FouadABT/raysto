import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/foundation_preview_app.dart';
import 'package:raysto/app/preview_store.dart';
import 'package:raysto/design_system/design_system.dart';

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
  });

  void phone(WidgetTester tester, {double width = 390, double scale = 1}) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 844);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  test(
    'save, replace, remove and undo restore the complete committed record',
    () {
      final store = PreviewStore();
      final original = SavedDish(
        dish: sampleDishes.first,
        note: 'Weekend lunch',
        collection: 'A favorite',
      );
      store.save(original);
      store.save(SavedDish(dish: sampleDishes.first, note: 'Changed'));
      store.restore('bowl', original);
      expect(store.find('bowl'), same(original));
      final removed = store.remove('bowl');
      expect(store.saved, isEmpty);
      store.restore('bowl', removed);
      expect(store.find('bowl')?.note, 'Weekend lunch');
      store.dispose();
    },
  );

  testWidgets(
    'complete save flow shares note and collection with saved branch',
    (tester) async {
      phone(tester);
      final store = PreviewStore()..reducedMotion = true;
      addTearDown(store.dispose);
      await tester.pumpWidget(
        FoundationPreviewApp(store: store, initialRoute: '/dish/bowl'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save this idea'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppChoice, 'A favorite'));
      await tester.enterText(find.byType(TextField), 'Try for a slow Sunday');
      await tester.ensureVisible(find.text('Save idea'));
      await tester.tap(find.widgetWithText(AppButton, 'Save idea'));
      await tester.pumpAndSettle();
      expect(store.find('bowl')?.collection, 'A favorite');
      expect(store.find('bowl')?.note, 'Try for a slow Sunday');
      expect(find.text('A good idea, saved.'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'View saved ideas'));
      await tester.pumpAndSettle();
      // Direct links have a valid home beneath the detail route.
      await tester.tap(find.byKey(const ValueKey('dock-2')));
      await tester.pumpAndSettle();
      expect(find.text('Try for a slow Sunday'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove The seasonal bowl'));
      await tester.pumpAndSettle();
      expect(store.saved, isEmpty);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.find('bowl')?.note, 'Try for a slow Sunday');
    },
  );

  testWidgets(
    'dirty sheet close protects draft; cancel never changes committed data',
    (tester) async {
      phone(tester);
      final store = PreviewStore()..reducedMotion = true;
      addTearDown(store.dispose);
      await tester.pumpWidget(
        FoundationPreviewApp(store: store, initialRoute: '/dish/pasta'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save this idea'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Keep this draft');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Close sheet'));
      await tester.tap(find.byTooltip('Close sheet'));
      await tester.pumpAndSettle();
      expect(find.text('Discard these changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Keep this draft'), findsOneWidget);
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();
      expect(store.saved, isEmpty);
    },
  );

  testWidgets('rapid tabs preserve search and isolate inactive branch input', (
    tester,
  ) async {
    phone(tester);
    await tester.pumpWidget(const FoundationPreviewApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dock-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tomato');
    await tester.tap(find.byKey(const ValueKey('dock-2')));
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(find.byKey(const ValueKey('dock-0')));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byKey(const ValueKey('dock-1')));
    await tester.pumpAndSettle();
    expect(find.text('tomato'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final ignore = tester.widgetList<IgnorePointer>(
      find.byType(IgnorePointer, skipOffstage: false),
    );
    expect(
      ignore.where((widget) => widget.ignoring).length,
      greaterThanOrEqualTo(2),
    );
  });

  testWidgets(
    '320 wide at 2x text: all branches, detail and keyboard-safe sheet',
    (tester) async {
      phone(tester, width: 320, scale: 2);
      final store = PreviewStore()..reducedMotion = true;
      addTearDown(store.dispose);
      await tester.pumpWidget(FoundationPreviewApp(store: store));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final tab in [1, 2, 0]) {
        await tester.tap(find.byKey(ValueKey('dock-$tab')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final context = tester.element(find.byType(Scaffold).first);
      Navigator.of(context).pushNamed('/dish/bowl');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save this idea'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(AppTextField));
      await tester.enterText(
        find.byType(TextField),
        'Large text stays readable',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Save idea'));
      await tester.tap(find.widgetWithText(AppButton, 'Save idea'));
      await tester.pumpAndSettle();
      expect(store.find('bowl')?.note, 'Large text stays readable');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unknown direct route has a useful recovery', (tester) async {
    phone(tester);
    await tester.pumpWidget(
      const FoundationPreviewApp(initialRoute: '/dish/missing'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Back to Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Good food.\nGood moments.'), findsOneWidget);
  });
}
