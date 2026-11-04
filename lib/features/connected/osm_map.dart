part of 'connected_app.dart';

/// One place on the map: the café, a customer's door or a driver.
class MapSpot {
  const MapSpot(this.latitude, this.longitude, this.kind, this.label);
  final double latitude, longitude;

  /// `venue`, `dropoff` or `driver`.
  final String kind;
  final String label;

  /// A spot from a `{latitude, longitude}` record, or null without both.
  static MapSpot? from(Object? raw, String kind, String label) {
    final m = obj(raw);
    final lat = m['latitude'], lng = m['longitude'];
    if (lat is! num || lng is! num) return null;
    return MapSpot(lat.toDouble(), lng.toDouble(), kind, label);
  }
}

/// Serves a blank tile without the network: for widget tests and previews.
class BlankTileProvider extends fm.TileProvider {
  BlankTileProvider();
  static final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=',
  );

  @override
  ImageProvider getImage(fm.TileCoordinates coordinates, fm.TileLayer options) =>
      MemoryImage(_png);
}

/// The shared OpenStreetMap view (flutter_map), used by the courier home, the
/// manager's dispatch and the diner's tracking map. It follows the tile
/// policy: the attribution "© OpenStreetMap contributors", the app's own user
/// agent, and no tiles kept beyond the view. The map never animates itself,
/// so reduced motion needs nothing more. Owner: stream S2.
class RaystoOsmMap extends StatelessWidget {
  const RaystoOsmMap({
    super.key,
    required this.spots,
    required this.label,
    this.route = const [],
    this.height = 240,
  });

  final List<MapSpot> spots;

  /// What the map shows, read by screen readers with every place's name.
  final String label;

  /// A straight line through these places (a ride, never a road route).
  final List<MapSpot> route;
  final double height;

  /// Tests set [BlankTileProvider]; the app uses the network.
  static fm.TileProvider? tiles;

  /// A deployment can point the app at its own tile server.
  static const tileUrl = String.fromEnvironment(
    'RAYSTO_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = [
      for (final s in spots) ll.LatLng(s.latitude, s.longitude),
    ];
    final summary = spots.isEmpty
        ? context.tr('No places to show yet.')
        : spots.map((s) => s.label).join('; ');
    return Semantics(
      container: true,
      label: '${context.tr(label)}: $summary',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height,
          child: points.isEmpty
              ? ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Center(child: Text(context.tr('No places to show yet.'))),
                )
              : Stack(
                  children: [
                    ExcludeSemantics(
                      child: fm.FlutterMap(
                        options: fm.MapOptions(
                          initialCenter: points.first,
                          initialZoom: 15,
                          initialCameraFit: points.length > 1
                              ? fm.CameraFit.coordinates(
                                  coordinates: points,
                                  padding: const EdgeInsets.all(40),
                                  maxZoom: 16,
                                )
                              : null,
                          interactionOptions: const fm.InteractionOptions(
                            flags:
                                fm.InteractiveFlag.drag |
                                fm.InteractiveFlag.pinchZoom |
                                fm.InteractiveFlag.doubleTapZoom,
                          ),
                        ),
                        children: [
                          fm.TileLayer(
                            urlTemplate: tileUrl,
                            userAgentPackageName: 'com.gmrt.raysto',
                            tileProvider: tiles ?? fm.NetworkTileProvider(),
                            keepBuffer: 0,
                            maxZoom: 19,
                          ),
                          if (route.length > 1)
                            fm.PolylineLayer(
                              polylines: [
                                fm.Polyline(
                                  points: [
                                    for (final s in route)
                                      ll.LatLng(s.latitude, s.longitude),
                                  ],
                                  strokeWidth: 4,
                                  color: scheme.primary,
                                  pattern: fm.StrokePattern.dashed(
                                    segments: const [10, 8],
                                  ),
                                ),
                              ],
                            ),
                          fm.MarkerLayer(
                            markers: [
                              for (final s in spots)
                                fm.Marker(
                                  point: ll.LatLng(s.latitude, s.longitude),
                                  width: 40,
                                  height: 40,
                                  child: _MapPin(s),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Semantics(
                        link: true,
                        label: context.tr('© OpenStreetMap contributors'),
                        child: InkWell(
                          onTap: () => launchUrl(
                            Uri.parse('https://www.openstreetmap.org/copyright'),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: ColoredBox(
                            color: scheme.surface.withValues(alpha: 0.85),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              child: ExcludeSemantics(
                                child: Text(
                                  '© OpenStreetMap contributors',
                                  style: Theme.of(context).textTheme.labelSmall,
                                  textScaler: TextScaler.noScaling,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin(this.spot);
  final MapSpot spot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, background, foreground) = switch (spot.kind) {
      'venue' => (Icons.storefront, scheme.primary, scheme.onPrimary),
      'driver' => (
        Icons.delivery_dining,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      _ => (Icons.home_outlined, scheme.surface, scheme.primary),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.primary, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x40000000))],
      ),
      child: Icon(icon, size: 20, color: foreground),
    );
  }
}
