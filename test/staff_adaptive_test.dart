import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/navigation.dart';
import 'package:raysto/features/connected/connected_app.dart';

import 'staff_m3_screens_test.dart' as screens;
import 'today_test.dart' as today;

class AdaptiveApi extends screens.ScreensApi {
  @override
  Future<Map<String, dynamic>> query(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    if (name == 'dashboard') {
      return today.fixture('${data['range'] ?? 'today'}');
    }
    if (name == 'me') {
      return {'userId': 'owner', 'memberships': [], 'profile': {}};
    }
    return super.query(name, data);
  }
}

void main() {
  testWidgets('counter draft and active place survive dock/rail changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    final api = AdaptiveApi();
    final live = screens.owner(api);
    await tester.pumpWidget(
      screens.host(
        StaffShell(
          live: live,
          memberships: const [
            {'restaurantId': 1, 'role': 'owner', 'restaurantName': 'QA café'},
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(RaystoAdaptiveDock),
        matching: find.bySemanticsLabel('Counter'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Device QA');

    tester.view.physicalSize = const Size(1100, 500);
    await tester.pumpAndSettle();
    expect(find.byType(StaffRail), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Device QA',
    );
    final agents = find.descendant(
      of: find.byType(StaffRail),
      matching: find.text('Agents'),
    );
    await tester.ensureVisible(agents);
    await tester.tap(agents);
    await tester.pumpAndSettle();
    expect(find.text('Pay wages 448.00 USD with PayPal'), findsOneWidget);

    tester.view.physicalSize = const Size(320, 800);
    await tester.pumpAndSettle();
    expect(
      find.text('Pay wages 448.00 USD with PayPal'),
      findsOneWidget,
      reason: 'The rail adds a Kitchen destination; it must not shift the active phone tab.',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(RaystoAdaptiveDock),
        matching: find.bySemanticsLabel('Counter'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Device QA',
    );
    expect(api.commands, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });
}
