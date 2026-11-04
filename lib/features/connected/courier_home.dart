part of 'connected_app.dart';

/// A page that reloads every [every] while it is the visible page of a
/// visible branch with the app in the foreground, and stops otherwise. Late
/// answers after the page closes are dropped.
abstract class _PollingState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  Duration get every;
  Future<void> reload();

  /// Told when the page starts or stops being seen (location sharing uses it).
  void showingChanged(bool showing) {}

  Timer? _poll;
  bool? _visible;
  bool _foreground = true;
  bool get showing => _visible == true && _foreground;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible == _visible) return;
    _visible = visible;
    _poll?.cancel();
    _poll = null;
    if (visible) {
      _poll = Timer.periodic(every, (_) {
        if (showing && mounted && ModalRoute.of(context)?.isCurrent != false) {
          unawaited(reload());
        }
      });
      unawaited(reload());
    }
    showingChanged(showing);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (showing) unawaited(reload());
    showingChanged(showing);
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// One position for `delivery.location`.
typedef CourierFix = ({double latitude, double longitude, double accuracy});

/// Where positions come from: the phone's location in the foreground, after
/// the courier ticks consent and the system grants permission. Tests pass a
/// stream of their own.
typedef CourierPositions = Stream<CourierFix> Function();

Stream<CourierFix> _devicePositions() async* {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const PlatformFailure(
      'permission_required',
      'Location permission is required to share where you are.',
    );
  }
  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25,
    ),
  ).map(
    (p) => (latitude: p.latitude, longitude: p.longitude, accuracy: p.accuracy),
  );
}

/// The words for a vehicle.
String vehicleLabel(String vehicle) => switch (vehicle) {
  'foot' => 'On foot',
  'bike' => 'Bike',
  'scooter' => 'Scooter',
  'car' => 'Car',
  _ => friendly(vehicle),
};

/// The courier's home: going available, offers with their countdown, and
/// each job from the café to the door with its map and proof. The position
/// is shared only while this page is on screen, the courier has ticked
/// consent, and the order is collected or on its way: there is no
/// background tracking. Owner: stream S2 (docs/release-0.16-design.md).
class CourierHome extends StatefulWidget {
  const CourierHome({super.key, required this.live, this.positions, this.pickPhoto});
  final LiveContext live;
  final CourierPositions? positions;

  /// Tests pass a photo; the app opens the camera.
  final Future<Uint8List?> Function()? pickPhoto;

  @override
  State<CourierHome> createState() => _CourierHomeState();
}

class _CourierHomeState extends _PollingState<CourierHome> {
  Json? data;
  String? error;
  bool busy = false;
  bool consent = false;
  final codes = <int, TextEditingController>{};
  StreamSubscription<CourierFix>? _fixes;
  DateTime? _lastSent;
  CourierFix? _lastFix;
  Timer? _clock;

  LiveContext get live => widget.live;

  @override
  Duration get every => const Duration(seconds: 10);

  @override
  Future<void> reload() async {
    try {
      final d = await live.api.query('courier.jobs', live.params());
      if (!mounted) return;
      setState(() {
        data = d;
        error = null;
      });
      _syncClock();
      _syncSharing();
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

  List<Json> get offers => records(data?['offers']);
  List<Json> get jobs => records(data?['jobs']);
  Json get driver => obj(data?['driver']);
  Iterable<Json> get moving =>
      jobs.where((j) => {'collected', 'outForDelivery'}.contains(j['status']));

  /// The countdown redraws each second only while an offer is open.
  void _syncClock() {
    if (offers.isNotEmpty && showing) {
      _clock ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _clock?.cancel();
      _clock = null;
    }
  }

  @override
  void showingChanged(bool showing) {
    _syncClock();
    _syncSharing();
  }

  /// Shares the position only while everything allows it, and stops at once otherwise.
  void _syncSharing() {
    final should = consent && showing && moving.isNotEmpty;
    if (should && _fixes == null) {
      _fixes = (widget.positions ?? _devicePositions)().listen(
        _send,
        onError: (Object e) {
          _stopSharing();
          if (mounted) {
            setState(() => consent = false);
            showRaystoSnackBar(
              context,
              e is PlatformFailure ? e.message : context.tr('Location is not available.'),
            );
          }
        },
      );
    } else if (!should && _fixes != null) {
      _stopSharing();
    }
  }

  void _stopSharing() {
    unawaited(_fixes?.cancel());
    _fixes = null;
  }

  Future<void> _send(CourierFix fix) async {
    final now = DateTime.now();
    if (_lastSent != null && now.difference(_lastSent!) < const Duration(seconds: 15)) {
      return;
    }
    _lastSent = now;
    if (mounted) setState(() => _lastFix = fix);
    for (final job in moving) {
      try {
        await live.api.command(
          'delivery.location',
          {
            'consent': true,
            'latitude': fix.latitude,
            'longitude': fix.longitude,
            'accuracy': fix.accuracy,
          },
          restaurantId: live.restaurantId,
          resourceId: job['id'] as int,
        );
      } catch (_) {
        // The next position tries again; the job itself is unaffected.
      }
    }
  }

  Future<void> _setConsent(bool on) async {
    setState(() => consent = on);
    if (!on) {
      _stopSharing();
      for (final job in moving) {
        await live.api.command(
          'delivery.location',
          {'consent': false},
          restaurantId: live.restaurantId,
          resourceId: job['id'] as int,
        );
      }
    }
    _syncSharing();
  }

  Future<void> run(Future<String?> Function() work) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final said = await work();
      if (mounted && said != null) showRaystoSnackBar(context, said);
      await reload();
    } catch (e) {
      if (mounted) {
        showRaystoSnackBar(
          context,
          e is PlatformFailure ? e.message : context.tr('The action could not be completed. Please retry.'),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<String?> _answer(Json offer, String answer) async {
    final result = await live.api.command(
      'delivery.respond',
      {'answer': answer},
      restaurantId: live.restaurantId,
      resourceId: offer['offerId'] as int,
    );
    if (!mounted) return null;
    return context.tr(switch (result['state']) {
      'accepted' => 'The job is yours. Head to the café.',
      'declined' => 'Declined.',
      'taken' => 'Another driver took this job first.',
      'expired' => 'This offer ran out of time.',
      _ => 'This offer is closed.',
    });
  }

  Future<String?> _step(Json job, String status) async {
    await live.api.command(
      'delivery.transition',
      {'status': status},
      restaurantId: live.restaurantId,
      resourceId: job['id'] as int,
      version: job['version'] as int,
    );
    return null;
  }

  Future<String?> _deliver(Json job) async {
    final mode = '${data?['proofMode'] ?? 'none'}';
    final payload = <String, dynamic>{};
    if (mode == 'code') {
      final code = codes[job['id']]?.text.trim() ?? '';
      if (!RegExp(r'^\d{4}$').hasMatch(code)) {
        throw const PlatformFailure('invalid_input', 'Enter the 4-digit code the customer shows you.');
      }
      payload['code'] = code;
    } else if (mode == 'photo') {
      final bytes = await (widget.pickPhoto ?? _camera)();
      if (bytes == null) return null;
      final intent = await live.api.command('media.upload', {
        'purpose': 'deliveryProof',
        'mime': 'image/jpeg',
        'byteLength': bytes.length,
        'sha256': sha256.convert(bytes).toString(),
      }, restaurantId: live.restaurantId);
      final id = intent['mediaId'] as int;
      await live.api.upload(id, bytes);
      payload['mediaId'] = id;
    }
    final result = await live.api.command(
      'delivery.proof',
      payload,
      restaurantId: live.restaurantId,
      resourceId: job['id'] as int,
      version: job['version'] as int,
    );
    if (!mounted) return null;
    if (result['delivered'] == true) {
      codes.remove(job['id'])?.dispose();
      return context.tr('Delivered. Thank you!');
    }
    return context
        .tr('That code does not match. {n} tries left.')
        .replaceAll('{n}', '${result['attemptsLeft'] ?? 0}');
  }

  static Future<Uint8List?> _camera() async {
    final shot = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 80,
    );
    return shot?.readAsBytes();
  }

  @override
  void dispose() {
    _stopSharing();
    _clock?.cancel();
    for (final c in codes.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    final text = Theme.of(context).textTheme;
    final available = driver['status'] == 'available' || driver['status'] == 'busy';
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Deliveries'))),
      body: SafeArea(
        child: d == null
            ? Center(
                child: error == null
                    ? const CircularProgressIndicator()
                    : Padding(padding: const EdgeInsets.all(24), child: Text(error!, textAlign: TextAlign.center)),
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
                    AppPanel(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: available,
                        onChanged: busy
                            ? null
                            : (on) => run(() async {
                                await live.api.command(
                                  'driver.availability',
                                  {'status': on ? 'available' : 'offline'},
                                  restaurantId: live.restaurantId,
                                );
                                return null;
                              }),
                        title: Text(context.tr(available ? 'Taking jobs' : 'Not taking jobs')),
                        subtitle: Text(
                          driver.isEmpty
                              ? context.tr('Switch on to receive delivery offers.')
                              : '${context.tr(vehicleLabel('${driver['vehicle']}'))} · ${context.tr('{n} delivered today').replaceAll('{n}', '${driver['deliveredToday'] ?? 0}')}',
                        ),
                      ),
                    ),
                    for (final offer in offers) ...[
                      const SizedBox(height: 12),
                      _offerCard(context, offer),
                    ],
                    for (final job in jobs) ...[
                      const SizedBox(height: 12),
                      _jobCard(context, job),
                    ],
                    if (offers.isEmpty && jobs.isEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        context.tr(available ? 'No jobs right now. Offers appear here with 90 seconds to accept.' : 'Switch on to receive delivery offers.'),
                        style: text.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _offerCard(BuildContext context, Json offer) {
    final left = max(
      0,
      (DateTime.tryParse('${offer['expiresAt']}')?.difference(DateTime.now()).inSeconds ?? 0),
    );
    final total = (data?['offerSeconds'] as num? ?? 90).toDouble();
    final eta = etaWords(context, offer['eta']);
    final clock = '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}';
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${context.tr('New offer')} · #${offer['number'] ?? offer['assignmentId']}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            [
              context.tr('{n} items').replaceAll('{n}', '${offer['items']}'),
              if (offer['area'] != null) '${offer['area']}',
              ?eta,
            ].join(' · '),
          ),
          if (eta != null) Text(context.tr('Times are estimates.'), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Semantics(
            label: context.tr('{s} seconds left to accept').replaceAll('{s}', '$left'),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Expanded(child: LinearProgressIndicator(value: total == 0 ? 0 : left / total)),
                  const SizedBox(width: 12),
                  Text(clock, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: busy || left == 0 ? null : () => run(() => _answer(offer, 'accept')),
                child: Text(context.tr('Accept')),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => run(() => _answer(offer, 'decline')),
                child: Text(context.tr('Decline')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _jobCard(BuildContext context, Json job) {
    final status = '${job['status']}';
    final address = obj(job['address']);
    final text = Theme.of(context).textTheme;
    final mode = '${data?['proofMode'] ?? 'none'}';
    const steps = ['assigned', 'collected', 'outForDelivery', 'delivered'];
    final at = steps.indexOf(status);
    final fix = _lastFix;
    final me = fix == null || !{'collected', 'outForDelivery'}.contains(status)
        ? null
        : MapSpot(fix.latitude, fix.longitude, 'driver', context.tr('You'));
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('#${job['number'] ?? job['orderId']} · ${context.tr(trackingHeadline(status, '${job['orderStatus']}'))}', style: text.titleMedium),
          if (job['customerLabel'] != null) Text('${job['customerLabel']}'),
          const SizedBox(height: 4),
          Text([address['line'], address['city']].whereType<Object>().join(', ')),
          if (address['instructions'] != null)
            Text('${context.tr('Note')}: ${address['instructions']}', style: text.bodySmall),
          Text(
            records(job['items']).map((l) => '${l['quantity']}× ${l['name']}').join(', '),
            style: text.bodySmall,
          ),
          const SizedBox(height: 12),
          RaystoOsmMap(
            label: 'This delivery on the map',
            spots: [
              ?MapSpot.from(data?['venue'], 'venue', context.tr('The café')),
              ?MapSpot.from(job['dropoff'], 'dropoff', context.tr('The door')),
              ?me,
            ],
            route: [
              if (status == 'assigned') ?MapSpot.from(data?['venue'], 'venue', '') else ?me,
              ?MapSpot.from(job['dropoff'], 'dropoff', ''),
            ],
            height: 200,
          ),
          if (etaWords(context, job['eta']) case final eta?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('$eta · ${context.tr('an estimate')}'),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (i, step) in steps.skip(1).indexed)
                Chip(
                  avatar: Icon(i + 1 <= at ? Icons.check_circle : Icons.radio_button_unchecked, size: 18),
                  label: Text(context.tr(switch (step) {
                    'collected' => 'Collect',
                    'outForDelivery' => 'Out',
                    _ => 'Delivered',
                  })),
                ),
            ],
          ),
          if ({'collected', 'outForDelivery'}.contains(status))
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: consent,
              onChanged: (on) => run(() async {
                await _setConsent(on);
                return null;
              }),
              title: Text(context.tr('Share my location with the customer')),
              subtitle: Text(context.tr('Only while this screen is open and the order is on its way.')),
            ),
          const SizedBox(height: 8),
          if (status == 'assigned')
            FilledButton.icon(
              onPressed: busy || job['ready'] != true ? null : () => run(() => _step(job, 'collected')),
              icon: const Icon(Icons.storefront),
              label: Text(context.tr(job['ready'] == true ? 'I collected the order' : 'Waiting for the kitchen')),
            ),
          if (status == 'collected')
            FilledButton.icon(
              onPressed: busy ? null : () => run(() => _step(job, 'outForDelivery')),
              icon: const Icon(Icons.delivery_dining),
              label: Text(context.tr("I'm on my way")),
            ),
          if (status == 'outForDelivery') ...[
            if (mode == 'code')
              TextField(
                controller: codes.putIfAbsent(job['id'] as int, TextEditingController.new),
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: context.tr("The customer's 4-digit code"),
                ),
              ),
            FilledButton.icon(
              onPressed: busy ? null : () => run(() => _deliver(job)),
              icon: Icon(mode == 'photo' ? Icons.photo_camera_outlined : Icons.check),
              label: Text(context.tr(mode == 'photo' ? 'Take a photo and deliver' : 'Delivered')),
            ),
          ],
          if (status != 'issue')
            TextButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      await live.action(
                        context,
                        'Report a problem',
                        'delivery.transition',
                        id: job['id'],
                        version: job['version'],
                        fixed: const {'status': 'issue'},
                        fields: const [InputSpec('reason', 'What happened?', kind: 'long')],
                      );
                      return null;
                    }),
              child: Text(context.tr('Report a problem')),
            ),
        ],
      ),
    );
  }
}

/// The manager's dispatch on the phone: the board with its map, and offers
/// sent from a driver list. Drag and drop lives in the console.
Widget dispatchPage(LiveContext live) => DataPage(
  title: 'Dispatch',
  poll: true,
  load: () async {
    final board = await live.api.query('delivery.board', live.params());
    final drivers = await live.api.query('drivers', live.params());
    return {...board, 'drivers': drivers['rows']};
  },
  content: (c, board, refresh) {
    final rows = records(board['rows']);
    final free = records(board['drivers']).where(
      (d) => d['kind'] == 'staff' && d['active'] == true && d['status'] != 'offline',
    );
    return [
      RaystoOsmMap(
        label: 'Deliveries on the map',
        spots: [
          ?MapSpot.from(board['venue'], 'venue', c.tr('The café')),
          for (final r in rows)
            ?MapSpot.from(r['dropoff'], 'dropoff', '#${r['number'] ?? r['orderId']}'),
          for (final d in records(board['drivers']))
            ?MapSpot.from(d['position'], 'driver', '${d['name']}'),
        ],
        height: 240,
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty) Text(c.tr('No deliveries in the last three hours.')),
      for (final r in rows)
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '#${r['number'] ?? r['orderId']} · ${c.tr(trackingHeadline('${r['status']}', '${r['orderStatus']}'))}',
                style: Theme.of(c).textTheme.titleMedium,
              ),
              Text(
                [
                  obj(r['address'])['line'],
                  obj(r['driver'])['name'],
                  etaWords(c, r['eta']),
                ].whereType<Object>().join(' · '),
              ),
              if (r['offer'] != null)
                Text('${c.tr('Offered to')} ${obj(r['offer'])['driverName'] ?? ''}'),
              if (r['status'] == 'unassigned' && r['fulfilledBy'] != 'partner' && r['offer'] == null)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final d in free)
                      OutlinedButton(
                        onPressed: () => perform(c, () async {
                          await live.api.command(
                            'delivery.offer',
                            {'driverId': d['id']},
                            restaurantId: live.restaurantId,
                            resourceId: r['id'] as int,
                          );
                          if (c.mounted) {
                            showRaystoSnackBar(c, '${c.tr('Offered to')} ${d['name']}');
                          }
                          await refresh();
                        }),
                        child: Text('${c.tr('Offer to')} ${d['name']}'),
                      ),
                  ],
                ),
            ],
          ),
        ),
    ];
  },
);

/// A manager picks a driver for `delivery.assign`: the café's driver cards,
/// free ones first.
Future<int?> pickDriver(BuildContext context, LiveContext live) async {
  final drivers = records(
    (await live.api.query('drivers', live.params()))['rows'],
  ).where((d) => d['kind'] == 'staff' && d['active'] == true).toList()
    ..sort((a, b) => (a['status'] == 'available' ? 0 : 1).compareTo(b['status'] == 'available' ? 0 : 1));
  if (!context.mounted) return null;
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(title: Text(c.tr('Choose a driver'))),
          if (drivers.isEmpty) ListTile(title: Text(c.tr('No drivers yet.'))),
          for (final d in drivers)
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: Text('${d['name']}'),
              subtitle: Text(
                '${c.tr(vehicleLabel('${d['vehicle']}'))} · ${c.tr(friendly('${d['status']}'))} · ${c.tr('{n} on hand').replaceAll('{n}', '${d['activeJobs'] ?? 0}')}',
              ),
              onTap: () => Navigator.of(c).pop(d['id'] as int),
            ),
        ],
      ),
    ),
  );
}
