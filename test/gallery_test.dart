import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/demo/gallery/gallery_screen.dart';
import 'package:raysto/design_system/design_system.dart';

Future<void> _loadGalleryFonts() async {
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
}

Future<void> _pumpGallery(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MotionScope(
      reducedMotion: false,
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const GalleryScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _button(String label) => find.widgetWithText(AppButton, label);
Finder _chip(String label) => find.widgetWithText(AppChip, label);
Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    250,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 50,
  );
  await tester.pumpAndSettle();
}

Future<void> _top(WidgetTester tester) async {
  tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .jumpTo(0);
  await tester.pumpAndSettle();
}

Future<void> _collection(WidgetTester tester, String label) async {
  await _top(tester);
  await _reveal(tester, _chip(label));
  await tester.tap(_chip(label));
  await tester.pumpAndSettle();
}

Future<void> _inspectToBottom(WidgetTester tester) async {
  for (var step = 0; step < 40; step++) {
    expect(tester.takeException(), isNull);
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    if (position.pixels >= position.maxScrollExtent) return;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  fail('Gallery did not reach the end within 40 scrolls.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadGalleryFonts);

  testWidgets(
    'dark gallery collections retain readable surfaces at large text',
    (tester) async {
      await _pumpGallery(
        tester,
        size: const Size(320, 740),
        textScale: 2,
        dark: true,
      );
      for (final label in [
        'Foundations',
        'Actions',
        'Selection',
        'Inputs',
        'Feedback',
        'Surfaces',
      ]) {
        await _collection(tester, label);
        await _inspectToBottom(tester);
      }
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppTheme.dark.colorScheme.surface);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all collections and recovery states fit 320px with 2x text', (
    tester,
  ) async {
    await _pumpGallery(tester, size: const Size(320, 740), textScale: 2);
    for (final label in [
      'Foundations',
      'Actions',
      'Selection',
      'Inputs',
      'Feedback',
      'Surfaces',
    ]) {
      await _collection(tester, label);
      await _inspectToBottom(tester);
    }
    for (final state in [
      'First use',
      'No matches',
      'Loading',
      'Refreshing',
      'Error',
      'Offline',
      'Permission',
      'Session',
      'Partial',
      'Success',
      'Removed',
    ]) {
      await _collection(tester, 'Feedback');
      await _reveal(tester, _chip(state));
      await tester.tap(_chip(state));
      await tester.pumpAndSettle();
      await _inspectToBottom(tester);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'validation preserves drafts; save, discard and undo restore data',
    (tester) async {
      await _pumpGallery(tester);
      await _collection(tester, 'Inputs');
      await _reveal(tester, _field('Plan name'));
      await tester.enterText(_field('Plan name'), '');
      await tester.enterText(
        _field('Note (optional)'),
        'Keep this exact note.',
      );
      await _reveal(tester, _button('Save sample note'));
      await tester.tap(_button('Save sample note'));
      await tester.pumpAndSettle();
      expect(find.text('Use a name with 3 to 60 characters.'), findsOneWidget);
      expect(
        tester.widget<TextField>(_field('Note (optional)')).controller!.text,
        'Keep this exact note.',
      );

      await _collection(tester, 'Actions');
      await _collection(tester, 'Inputs');
      await _reveal(tester, _field('Plan name'));
      expect(
        tester.widget<TextField>(_field('Plan name')).controller!.text,
        '',
      );
      expect(
        tester.widget<TextField>(_field('Note (optional)')).controller!.text,
        'Keep this exact note.',
      );
      await tester.enterText(_field('Plan name'), 'Friday lunch');
      await _reveal(tester, _button('Save sample note'));
      await tester.tap(_button('Save sample note'));
      await tester.pumpAndSettle();
      expect(
        find.text('Your sample dining note has been saved in this gallery.'),
        findsOneWidget,
      );

      await _top(tester);
      await _reveal(tester, _field('Note (optional)'));
      await tester.enterText(_field('Note (optional)'), 'A newer draft.');
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppButton>(_button('Undo last save')).onPressed,
        isNull,
      );
      await _reveal(tester, _button('Discard draft'));
      await tester.tap(_button('Discard draft'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_field('Note (optional)')).controller!.text,
        'Keep this exact note.',
      );
      await _reveal(tester, _button('Undo last save'));
      await tester.tap(_button('Undo last save'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_field('Plan name')).controller!.text,
        'Dinner with friends',
      );
      expect(
        tester.widget<TextField>(_field('Note (optional)')).controller!.text,
        'A quiet corner, if one is available.',
      );
      expect(find.text('Previous name and note restored.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('sheets cancel drafts and removal has a real undo', (
    tester,
  ) async {
    await _pumpGallery(tester);
    await _collection(tester, 'Surfaces');
    final paceControl = find.widgetWithText(AppTapSurface, 'Set your pace');
    await _reveal(tester, paceControl);
    await tester.tap(paceControl);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppChoice, 'No rush'));
    await tester.tap(_button('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('A relaxed meal'), findsOneWidget);

    await tester.tap(paceControl);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppChoice, 'No rush'));
    await tester.tap(_button('Apply pace'));
    await tester.pumpAndSettle();
    expect(find.text('No rush'), findsOneWidget);

    await _reveal(tester, _button('Remove sample place'));
    await tester.tap(_button('Remove sample place'));
    await tester.pumpAndSettle();
    await tester.tap(_button('Keep place'));
    await tester.pumpAndSettle();
    expect(find.text('Market Table'), findsOneWidget);

    await tester.tap(_button('Remove sample place'));
    await tester.pumpAndSettle();
    await tester.tap(_button('Remove sample place').last);
    await tester.pumpAndSettle();
    expect(find.text('Market Table removed'), findsOneWidget);
    expect(find.text('Market Table'), findsNothing);
    await _reveal(tester, _button('Undo removal'));
    await tester.tap(_button('Undo removal'));
    await tester.pumpAndSettle();
    expect(find.text('Market Table'), findsOneWidget);
    expect(find.text('Market Table removed'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
