part of 'connected_app.dart';

/// Dispatch for managers and the courier home: offers, steps, map and proof.
/// Owner: stream S2 (docs/release-0.16-design.md). Placeholder until built.
Widget dispatchPage(LiveContext live) => Builder(
  builder: (c) => Scaffold(
    appBar: AppBar(title: Text(c.tr('Dispatch'))),
    body: RaystoEmptyState(
      title: c.tr('Coming in 0.16'),
      message: c.tr('Drivers, offers and deliveries on a live map.'),
    ),
  ),
);
