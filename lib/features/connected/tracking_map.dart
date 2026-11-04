part of 'connected_app.dart';

/// The diner's live delivery map with its ETA.
/// Owner: stream S2 (docs/release-0.16-design.md). Placeholder until built.
Widget trackingMapPage(LiveContext live) => Builder(
  builder: (c) => Scaffold(
    appBar: AppBar(title: Text(c.tr('Delivery tracking'))),
    body: RaystoEmptyState(
      title: c.tr('Coming in 0.16'),
      message: c.tr('Your driver on a live map, with an estimated arrival time.'),
    ),
  ),
);
