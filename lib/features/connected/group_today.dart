part of 'connected_app.dart';

/// The franchise view: every venue of the group and a combined target.
/// Owner: stream S4 (docs/release-0.16-design.md). Placeholder until built.
Widget groupTodayPage(LiveContext live) => Builder(
  builder: (c) => Scaffold(
    appBar: AppBar(title: Text(c.tr('Group'))),
    body: RaystoEmptyState(
      title: c.tr('Coming in 0.16'),
      message: c.tr('All your venues side by side.'),
    ),
  ),
);
