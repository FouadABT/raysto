part of 'connected_app.dart';

/// Snap a bill, approve and pay it with PayPal, and send pay links.
/// Owner: stream S1 (docs/release-0.16-design.md). Placeholder until built.
Widget accountantPage(LiveContext live) => Builder(
  builder: (c) => Scaffold(
    appBar: AppBar(title: Text(c.tr('Accountant'))),
    body: RaystoEmptyState(
      title: c.tr('Coming in 0.16'),
      message: c.tr('Bills, pay links and the books, prepared by the AI accountant.'),
    ),
  ),
);
