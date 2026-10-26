import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/domain.dart';
import '../l10n/app_localizations.dart';

Color tableStatusColor(BuildContext context, TableStatus status) {
  final c = Theme.of(context).colorScheme;
  return switch (status) {
    TableStatus.available => c.secondaryContainer,
    TableStatus.occupied => c.primary,
    TableStatus.reserved => c.tertiaryContainer,
    TableStatus.needsReset => c.errorContainer,
  };
}

Color tableStatusForeground(BuildContext context, TableStatus status) {
  final c = Theme.of(context).colorScheme;
  return switch (status) {
    TableStatus.available => c.onSecondaryContainer,
    TableStatus.occupied => c.onPrimary,
    TableStatus.reserved => c.onTertiaryContainer,
    TableStatus.needsReset => c.onErrorContainer,
  };
}

/// Displays the persisted room coordinates. Selection never joins a visit.
class DiningFloorMap extends StatefulWidget {
  const DiningFloorMap({
    super.key,
    required this.tables,
    required this.objects,
    required this.onSelect,
    this.selected,
  });
  final List<DemoTable> tables;
  final List<FloorObject> objects;
  final ValueChanged<String> onSelect;
  final String? selected;
  @override
  State<DiningFloorMap> createState() => _DiningFloorMapState();
}

class _DiningFloorMapState extends State<DiningFloorMap> {
  final _transform = TransformationController();
  Size? _viewport;
  Size? _lastRoom;
  Size get _room => Size(
    [
      860.0,
      ...widget.tables.map((t) => t.x + math.max(t.width, 72) + 40),
      ...widget.objects.map((o) => o.x + o.width + 40),
    ].reduce(math.max),
    [
      640.0,
      ...widget.tables.map((t) => t.y + math.max(t.height, 72) + 40),
      ...widget.objects.map((o) => o.y + o.height + 40),
    ].reduce(math.max),
  );
  void _fit(Size size) {
    final scale = math.min(
      size.width / _room.width,
      size.height / _room.height,
    );
    _transform.value = Matrix4.identity()..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Widget _table(BuildContext context, DemoTable table) {
    final radius = BorderRadius.circular(table.shape == 'round' ? 100 : 14);
    final color = tableStatusColor(context, table.status);
    final label = Center(
      child: ExcludeSemantics(
        child: Text(
          table.label.replaceFirst('Table ', ''),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: tableStatusForeground(context, table.status)),
        ),
      ),
    );
    final tile = Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: widget.selected == table.id
              ? Theme.of(context).colorScheme.onSurface
              : color,
          width: widget.selected == table.id ? 4 : 1,
        ),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        onTap: () => widget.onSelect(table.id),
        child: label,
      ),
    );
    final accessible = Semantics(
      button: true,
      selected: widget.selected == table.id,
      label:
          '${table.label}, ${table.seats} ${context.tr('seats')}, ${context.tr(table.status.name)}',
      child: Padding(padding: const EdgeInsets.all(7), child: tile),
    );
    return Positioned(
      left: table.x,
      top: table.y,
      width: math.max(table.width, 72),
      height: math.max(table.height, 72),
      child: Transform.rotate(
        angle: table.rotation * math.pi / 180,
        child: accessible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);
      if (_viewport != size || _lastRoom != _room) {
        _viewport = size;
        _lastRoom = _room;
        _fit(size);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: InteractiveViewer(
                  transformationController: _transform,
                  constrained: false,
                  minScale: .2,
                  maxScale: 2.5,
                  boundaryMargin: const EdgeInsets.all(120),
                  child: SizedBox(
                    width: _room.width,
                    height: _room.height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RoomGrid(
                              Theme.of(context).colorScheme.outlineVariant
                                  .withValues(alpha: .5),
                            ),
                          ),
                        ),
                        for (final object in widget.objects)
                          Positioned(
                            left: object.x,
                            top: object.y,
                            width: object.width,
                            height: object.height,
                            child: Transform.rotate(
                              angle: object.rotation * math.pi / 180,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: object.type == 'wall'
                                      ? Theme.of(context).colorScheme.outline
                                      : Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: object.type == 'entrance'
                                    ? const Icon(Icons.door_front_door_outlined)
                                    : null,
                              ),
                            ),
                          ),
                        for (final table in widget.tables)
                          _table(context, table),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: 10,
              bottom: 10,
              child: IconButton.filledTonal(
                tooltip: context.tr('Fit room'),
                onPressed: () => setState(() => _fit(size)),
                icon: const Icon(Icons.fit_screen),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _RoomGrid extends CustomPainter {
  const _RoomGrid(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 20; x < size.width; x += 28) {
      for (double y = 20; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 15, size.width - 30, size.height - 30),
        const Radius.circular(24),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_RoomGrid old) => old.color != color;
}

class TableStatusLegend extends StatelessWidget {
  const TableStatusLegend({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 10,
    children: [
      for (final status in TableStatus.values)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: tableStatusColor(context, status),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 12),
            ),
            const SizedBox(width: 6),
            Text(
              context.tr(status.name),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
    ],
  );
}
