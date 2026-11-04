part of 'connected_app.dart';

/// Count stock and receive a supplier delivery by camera.
/// Owner: stream S3 (docs/release-0.16-design.md). Placeholder until built.
Widget suppliesPage(LiveContext live) => Builder(
  builder: (c) => Scaffold(
    appBar: AppBar(title: Text(c.tr('Supplies'))),
    body: RaystoEmptyState(
      title: c.tr('Coming in 0.16'),
      message: c.tr('Stock counts, supplier orders and deliveries, planned by the AI.'),
    ),
  ),
);
