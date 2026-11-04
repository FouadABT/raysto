part of 'connected_app.dart';

/// The diner's delivery: where it is, when it should arrive (always an
/// estimate), who brings it and the code to give at the door. It reads
/// `delivery.tracking` every 15 seconds, only while it is the visible page.
/// Owner: stream S2 (docs/release-0.16-design.md).
Widget trackingMapPage(LiveContext live, {required int orderId}) =>
    TrackingMapPage(live: live, orderId: orderId);

/// "About 12 min" from an estimate record, or null without one.
String? etaWords(BuildContext context, Object? raw) {
  final minutes = obj(raw)['minutes'];
  if (minutes is! num) return null;
  return context.tr('About {n} min').replaceAll('{n}', '${minutes.round()}');
}

String trackingHeadline(String status, String orderStatus) => switch (status) {
  'unassigned' =>
    {'awaitingPayment', 'submitted', 'accepted', 'preparing'}.contains(orderStatus)
        ? 'Being prepared'
        : 'Finding a driver',
  'assigned' => 'A driver is on it',
  'collected' => 'Collected from the café',
  'outForDelivery' => 'On the way',
  'delivered' => 'Delivered',
  'issue' => 'The driver reported a problem',
  'cancelled' => 'Cancelled',
  _ => 'Delivery',
};

class TrackingMapPage extends StatefulWidget {
  const TrackingMapPage({super.key, required this.live, required this.orderId});
  final LiveContext live;
  final int orderId;

  @override
  State<TrackingMapPage> createState() => _TrackingMapPageState();
}

class _TrackingMapPageState extends _PollingState<TrackingMapPage> {
  Json? data;
  String? error;

  @override
  Duration get every => const Duration(seconds: 15);

  @override
  Future<void> reload() async {
    try {
      final d = await widget.live.api.query(
        'delivery.tracking',
        widget.live.params({'orderId': widget.orderId}),
      );
      if (mounted) {
        setState(() {
          data = d;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is PlatformFailure
              ? e.message
              : context.tr('Could not refresh. Please try again.'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Your delivery'))),
      body: SafeArea(
        child: d == null
            ? Center(
                child: error == null
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(error!, textAlign: TextAlign.center),
                      ),
              )
            : RefreshIndicator(
                onRefresh: reload,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    Text(
                      context.tr(trackingHeadline('${d['status']}', '${d['orderStatus']}')),
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (etaWords(context, d['eta']) case final eta?)
                      Semantics(
                        label: '$eta, ${context.tr('an estimate')}',
                        child: ExcludeSemantics(
                          child: Row(
                            children: [
                              Flexible(child: Text(eta, style: text.titleLarge)),
                              const SizedBox(width: 8),
                              Chip(label: Text(context.tr('Estimate'))),
                            ],
                          ),
                        ),
                      ),
                    if (obj(d['eta'])['basis'] case final String basis)
                      Text(basis, style: text.bodySmall),
                    const SizedBox(height: 16),
                    RaystoOsmMap(
                      label: 'Your delivery on the map',
                      spots: _spots(context, d),
                      route: [
                        ?MapSpot.from(d['location'], 'driver', ''),
                        ?MapSpot.from(d['dropoff'], 'dropoff', ''),
                      ],
                      height: 260,
                    ),
                    const SizedBox(height: 16),
                    if (obj(d['driver']) case final driver when driver.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.delivery_dining),
                        title: Text('${driver['name']}'),
                        subtitle: Text(context.tr(friendly('${driver['vehicle']}'))),
                      ),
                    if (d['code'] case final String code)
                      AppPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('Your handover code'), style: text.titleMedium),
                            const SizedBox(height: 4),
                            Semantics(
                              label: code.split('').join(' '),
                              child: ExcludeSemantics(
                                child: Text(code, style: text.displaySmall?.copyWith(letterSpacing: 6)),
                              ),
                            ),
                            Text(context.tr('Give it to the driver at the door.')),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    ..._steps(context, '${d['status']}'),
                  ],
                ),
              ),
      ),
    );
  }

  List<MapSpot> _spots(BuildContext context, Json d) => [
    ?MapSpot.from(d['venue'], 'venue', context.tr('The café')),
    ?MapSpot.from(d['dropoff'], 'dropoff', context.tr('Your door')),
    ?MapSpot.from(
      d['location'],
      'driver',
      '${obj(d['driver'])['name'] ?? context.tr('Your driver')}',
    ),
  ];

  List<Widget> _steps(BuildContext context, String status) {
    const order = ['assigned', 'collected', 'outForDelivery', 'delivered'];
    final reached = order.indexOf(status);
    return [
      for (final (i, step) in order.indexed)
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            i <= reached ? Icons.check_circle : Icons.radio_button_unchecked,
            color: i <= reached ? Theme.of(context).colorScheme.primary : null,
          ),
          title: Text(context.tr(switch (step) {
            'assigned' => 'Driver assigned',
            'collected' => 'Collected',
            'outForDelivery' => 'On the way',
            _ => 'Delivered',
          })),
        ),
    ];
  }
}
