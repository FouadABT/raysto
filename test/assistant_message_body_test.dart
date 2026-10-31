import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/assistant_message_body.dart';

void main() {
  testWidgets('assistant emphasis renders as text and blocks remote images', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AssistantMessageBody(
            text: '**Garden pasta** — \$12.00\n\n*Ask staff about allergens.*\n\n![External image](https://example.invalid/tracking.png)',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final visible = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
        .join(' ');
    expect(visible, contains('Garden pasta'));
    expect(visible, contains('Ask staff about allergens.'));
    expect(visible, isNot(contains('**')));
    expect(find.byType(Image), findsNothing);
    expect(find.text('External image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
