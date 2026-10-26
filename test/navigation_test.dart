import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/navigation.dart';
import 'package:raysto/design_system/design_system.dart';

// Element-based semantic finders can still match detached semantics retained by
// an outgoing branch. Accessibility traverses this attached tree instead.
List<SemanticsNode> _liveSemantics(WidgetTester tester) {
  final root = tester
      .binding
      .renderViews
      .single
      .owner!
      .semanticsOwner!
      .rootSemanticsNode!;
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return nodes;
}

void main() {
  testWidgets('rapid navigation preserves the visible outgoing opacity', (
    tester,
  ) async {
    var selected = 0;
    final activations = [0, 0, 0];
    late StateSetter update;
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MotionScope(
          reducedMotion: false,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return RetainedBranches(
                    index: selected,
                    children: List.generate(
                      3,
                      (i) => Center(
                        child: TextButton(
                          onPressed: () => activations[i]++,
                          child: Text('Branch $i action'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      update(() => selected = 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      final before = tester
          .widget<Opacity>(find.byKey(const ValueKey('branch-opacity-1')))
          .opacity;
      expect(before, inExclusiveRange(0, 1));

      update(() => selected = 2);
      await tester.pump();
      final after = tester
          .widget<Opacity>(find.byKey(const ValueKey('branch-opacity-1')))
          .opacity;
      expect(after, closeTo(before, .0001));
      final labels = _liveSemantics(
        tester,
      ).map((node) => node.getSemanticsData().label);
      expect(labels, isNot(contains('Branch 0 action')));
      expect(labels, isNot(contains('Branch 1 action')));
      await tester.pumpAndSettle();
      final activeActions = _liveSemantics(tester)
          .where((node) => node.getSemanticsData().label.startsWith('Branch '))
          .toList();
      expect(activeActions, hasLength(1));
      final active = activeActions.single;
      expect(active.getSemanticsData().label, 'Branch 2 action');
      expect(active.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      active.owner!.performAction(active.id, SemanticsAction.tap);
      expect(activations, [0, 0, 1]);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'travelling dock retargets in place and keeps single actionable semantics',
    (tester) async {
      var selected = 0;
      late StateSetter update;
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MotionScope(
            reducedMotion: false,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 320,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        update = setState;
                        return RaystoDock(
                          index: selected,
                          onChanged: (index) =>
                              setState(() => selected = index),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        Rect indicatorRect() {
          final finder = find.byKey(const ValueKey('dock-indicator-clip'));
          final clip = tester.widget<ClipPath>(finder);
          return clip.clipper!.getClip(tester.getSize(finder)).getBounds();
        }

        final saved = tester.getSemantics(find.bySemanticsLabel('Saved'));
        expect(saved.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        saved.owner!.performAction(saved.id, SemanticsAction.tap);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        final before = indicatorRect();
        expect(before.left, greaterThan(0));
        update(() => selected = 0);
        await tester.pump();
        expect(indicatorRect().left, closeTo(before.left, .0001));
        expect(find.bySemanticsLabel('Discover'), findsOneWidget);
        expect(find.bySemanticsLabel('Menu'), findsOneWidget);
        expect(find.bySemanticsLabel('Saved'), findsOneWidget);
        final discover = tester.getSemantics(find.bySemanticsLabel('Discover'));
        expect(
          discover.getSemanticsData().flagsCollection.isSelected,
          Tristate.isTrue,
        );
        await tester.pumpAndSettle();
        expect(indicatorRect().left, closeTo(0, .001));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
}
