import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:raysto/design_system/design_system.dart';

Widget _host(Widget child, {bool reducedMotion = false}) => MotionScope(
  reducedMotion: reducedMotion,
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('busy action closes the pre-rebuild double submission window', (
    tester,
  ) async {
    var submissions = 0;
    var busy = false;
    late StateSetter update;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AppButton(
              label: 'Confirm preview',
              busy: busy,
              onPressed: () {
                submissions++;
                setState(() => busy = true);
              },
            );
          },
        ),
      ),
    );

    // Two events can reach the old render tree before the busy rebuild.
    await tester.tap(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    expect(submissions, 1);
    await tester.pump();
    await tester.tap(find.byType(AppButton));
    expect(submissions, 1);

    update(() => busy = false);
    await tester.pump();
    await tester.tap(find.byType(AppButton));
    expect(submissions, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('press compression preserves the full icon action hit target', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _host(
        AppIconButton(
          label: 'Open preferences',
          icon: PhosphorIconsRegular.slidersHorizontal,
          onPressed: () => presses++,
        ),
      ),
    );
    final target = find.descendant(
      of: find.byType(AppIconButton),
      matching: find.byType(InkWell),
    );
    final original = tester.getRect(target);
    expect(original.width, greaterThanOrEqualTo(48));
    expect(original.height, greaterThanOrEqualTo(48));
    final gesture = await tester.startGesture(
      Offset(original.right - 1, original.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getRect(target), original);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(presses, 1);
  });

  testWidgets(
    'collapsing a disclosure immediately removes child focus and semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      try {
        await tester.pumpWidget(
          _host(
            AppDisclosure(
              title: 'Optional details',
              child: TextButton(
                focusNode: focus,
                onPressed: () {},
                child: const Text('Edit special request'),
              ),
            ),
          ),
        );
        expect(find.text('Edit special request'), findsNothing);
        await tester.tap(find.byType(AppTapSurface));
        await tester.pumpAndSettle();
        focus.requestFocus();
        await tester.pump();
        expect(focus.hasFocus, isTrue);
        expect(find.bySemanticsLabel('Edit special request'), findsOneWidget);

        await tester.tap(find.byType(AppTapSurface));
        await tester.pump();
        expect(find.text('Edit special request'), findsNothing);
        expect(find.bySemanticsLabel('Edit special request'), findsNothing);
        expect(focus.hasFocus, isFalse);
        await tester.pumpAndSettle();
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('selected choice exposes state without depending on color', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _host(AppChoice(title: 'A quiet table', selected: true, onTap: () {})),
      );
      final node = tester.getSemantics(find.byType(AppChoice));
      expect(
        node.getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('runtime device requests and app preference combine with OR', (
    tester,
  ) async {
    var appReduced = false;
    late StateSetter update;
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return _host(
            Builder(
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppMotion.reduced(context) ? 'Reduced' : 'Full motion'),
                  AppButton(label: 'Try feedback', onPressed: () {}),
                ],
              ),
            ),
            reducedMotion: appReduced,
          );
        },
      ),
    );
    expect(find.text('Full motion'), findsOneWidget);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    await tester.pump();
    expect(find.text('Reduced'), findsOneWidget);
    expect(find.byType(AnimatedScale), findsNothing);

    // Disabling an app override cannot override the operating system.
    update(() => appReduced = false);
    await tester.pump();
    expect(find.text('Reduced'), findsOneWidget);
    update(() => appReduced = true);
    await tester.pump();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await tester.pump();
    expect(find.text('Reduced'), findsOneWidget);
    update(() => appReduced = false);
    await tester.pump();
    expect(find.text('Full motion'), findsOneWidget);

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pump();
    expect(find.text('Reduced'), findsOneWidget);
  });

  testWidgets('nested motion scopes preserve ancestor reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        MotionScope(
          reducedMotion: false,
          child: Builder(
            builder: (context) =>
                Text(AppMotion.reduced(context) ? 'Reduced' : 'Full motion'),
          ),
        ),
        reducedMotion: true,
      ),
    );
    expect(find.text('Reduced'), findsOneWidget);
  });

  testWidgets('sheet remains scrollable at 320 width, 2x text and keyboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final controller = TextEditingController(
      text: 'Please seat us by a window.',
    );
    addTearDown(controller.dispose);
    var closed = false;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => AppButton(
            label: 'Edit request',
            onPressed: () async {
              final result = await showAppSheet<bool>(
                context,
                child: Builder(
                  builder: (sheetContext) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppSectionTitle(
                        title: 'Make yourself comfortable',
                        subtitle:
                            'Optional details stay editable until you confirm.',
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Special request',
                        controller: controller,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Keep this request',
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                      ),
                    ],
                  ),
                ),
              );
              closed = result ?? false;
            },
          ),
        ),
        reducedMotion: true,
      ),
    );
    await tester.tap(find.widgetWithText(AppButton, 'Edit request'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(
      find.widgetWithText(AppButton, 'Keep this request'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.widgetWithText(AppButton, 'Keep this request'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(controller.text, 'Please seat us by a window.');
    expect(tester.takeException(), isNull);
  });
}
