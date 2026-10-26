part of 'operations.dart';

/// The canvas uses fixed logical room coordinates. InteractiveViewer transforms
/// presentation only; persisted positions never depend on handset dimensions.
class _RoomCanvas extends StatefulWidget {
  const _RoomCanvas({
    required this.tables,
    required this.objects,
    required this.onSelect,
    this.selected,
    this.onMove,
    this.onMoveStart,
    this.onMoveEnd,
    this.controller,
  });
  final List<DemoTable> tables;
  final List<FloorObject> objects;
  final ValueChanged<String> onSelect;
  final String? selected;
  final void Function(String, Offset)? onMove;
  final VoidCallback? onMoveStart, onMoveEnd;
  final TransformationController? controller;
  @override
  State<_RoomCanvas> createState() => _RoomCanvasState();
}

class _RoomCanvasState extends State<_RoomCanvas> {
  late final TransformationController ownController =
      TransformationController();
  TransformationController get transform => widget.controller ?? ownController;
  bool fitted = false;
  Offset? lastGlobal;
  @override
  void dispose() {
    ownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (!fitted) {
        fitted = true;
        final zoom = math.min(c.maxWidth / 800, c.maxHeight / 600);
        transform.value = Matrix4.identity()..scaleByDouble(zoom, zoom, 1, 1);
      }
      final colors = Theme.of(context).colorScheme;
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: colors.surfaceContainer,
          child: InteractiveViewer(
            transformationController: transform,
            minScale: .2,
            maxScale: 2.5,
            boundaryMargin: const EdgeInsets.all(240),
            constrained: false,
            panEnabled: widget.onMove == null || widget.selected == null,
            child: SizedBox(
              width: 800,
              height: 600,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(colors.outlineVariant),
                    ),
                  ),
                  for (final object in widget.objects)
                    _positioned(
                      context,
                      object.id,
                      object.x,
                      object.y,
                      object.width,
                      object.height,
                      object.rotation,
                      Semantics(
                        label: '${object.type} ${object.label}',
                        button: true,
                        selected: widget.selected == object.id,
                        child: Container(
                          decoration: BoxDecoration(
                            color: object.type == 'wall'
                                ? colors.outline
                                : colors.tertiaryContainer,
                            border: widget.selected == object.id
                                ? Border.all(color: colors.primary, width: 3)
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: object.type == 'entrance'
                              ? Icon(
                                  Icons.door_front_door_outlined,
                                  color: colors.onTertiaryContainer,
                                )
                              : null,
                        ),
                      ),
                    ),
                  for (final table in widget.tables)
                    _positioned(
                      context,
                      table.id,
                      table.x,
                      table.y,
                      table.width,
                      table.height,
                      table.rotation,
                      Semantics(
                        label:
                            '${table.label}, ${table.seats} ${context.tr('seats')}, ${context.tr(_words(table.status))}',
                        button: true,
                        selected: widget.selected == table.id,
                        child: Container(
                          decoration: BoxDecoration(
                            color: table.status == TableStatus.occupied
                                ? colors.primaryContainer
                                : table.status == TableStatus.needsReset
                                ? colors.tertiaryContainer
                                : colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(
                              table.shape == 'round' ? 100 : 12,
                            ),
                            border: Border.all(
                              color: widget.selected == table.id
                                  ? colors.primary
                                  : colors.outline,
                              width: widget.selected == table.id ? 4 : 1.5,
                            ),
                          ),
                          child: Center(
                            child: ExcludeSemantics(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  table.label
                                      .replaceFirst('Table ', '')
                                      .replaceFirst('Tableau ', ''),
                                  style: Theme.of(context).textTheme.labelLarge,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
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
        ),
      );
    },
  );
  Widget _positioned(
    BuildContext context,
    String id,
    double x,
    double y,
    double width,
    double height,
    double rotation,
    Widget child,
  ) => Positioned(
    left: x,
    top: y,
    width: width,
    height: height,
    child: Transform.rotate(
      angle: rotation * math.pi / 180,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect(id),
        onPanStart: widget.onMove != null && widget.selected == id
            ? (details) {
                lastGlobal = details.globalPosition;
                widget.onMoveStart?.call();
              }
            : null,
        onPanUpdate: widget.onMove != null && widget.selected == id
            ? (details) {
                final scale = transform.value.getMaxScaleOnAxis();
                final delta =
                    details.globalPosition -
                    (lastGlobal ?? details.globalPosition);
                lastGlobal = details.globalPosition;
                widget.onMove!(id, delta / scale);
              }
            : null,
        onPanEnd: widget.onMove != null && widget.selected == id
            ? (_) {
                lastGlobal = null;
                widget.onMoveEnd?.call();
              }
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (widget.onMove != null && widget.selected == id)
              Positioned(
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      Icons.open_with,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
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

class _GridPainter extends CustomPainter {
  const _GridPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = .7;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}

typedef _LayoutSnapshot = ({List<DemoTable> tables, List<FloorObject> objects});

class _FloorEditor extends StatefulWidget {
  const _FloorEditor({required this.store});
  final DemoStore store;
  @override
  State<_FloorEditor> createState() => _FloorEditorState();
}

class _FloorEditorState extends State<_FloorEditor> {
  late List<DemoTable> tables = List.of(widget.store.restaurantTables);
  late List<FloorObject> objects = widget.store.floorObjects
      .where((o) => o.restaurantId == widget.store.currentRestaurant.id)
      .toList();
  final transform = TransformationController();
  final List<_LayoutSnapshot> undo = [], redo = [];
  String? selected;
  bool dirty = false, list = false;
  void checkpoint() {
    undo.add((tables: List.of(tables), objects: List.of(objects)));
    redo.clear();
    dirty = true;
  }

  void restore(bool backwards) {
    final from = backwards ? undo : redo, to = backwards ? redo : undo;
    if (from.isEmpty) return;
    setState(() {
      to.add((tables: List.of(tables), objects: List.of(objects)));
      final state = from.removeLast();
      tables = List.of(state.tables);
      objects = List.of(state.objects);
      selected = null;
      dirty = true;
    });
  }

  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }

  void move(String id, Offset delta) {
    setState(() {
      tables = tables
          .map(
            (t) => t.id == id
                ? t.copyWith(
                    x: (t.x + delta.dx).clamp(0, 800 - t.width),
                    y: (t.y + delta.dy).clamp(0, 600 - t.height),
                  )
                : t,
          )
          .toList();
      objects = objects
          .map(
            (o) => o.id == id
                ? o.copyWith(
                    x: (o.x + delta.dx).clamp(0, 800 - o.width),
                    y: (o.y + delta.dy).clamp(0, 600 - o.height),
                  )
                : o,
          )
          .toList();
    });
  }

  void snap() {
    setState(() {
      tables = tables
          .map(
            (t) => t.id == selected
                ? t.copyWith(
                    x: (t.x / 10).round() * 10.0,
                    y: (t.y / 10).round() * 10.0,
                  )
                : t,
          )
          .toList();
      objects = objects
          .map(
            (o) => o.id == selected
                ? o.copyWith(
                    x: (o.x / 10).round() * 10.0,
                    y: (o.y / 10).round() * 10.0,
                  )
                : o,
          )
          .toList();
    });
  }

  void add(String type) {
    setState(() {
      checkpoint();
      final id = _uniqueId('${widget.store.currentRestaurant.id}-layout', [
        ...tables.map((t) => t.id),
        ...objects.map((o) => o.id),
      ]);
      selected = id;
      if (type == 'table') {
        tables.add(
          DemoTable(
            id: id,
            restaurantId: widget.store.currentRestaurant.id,
            label: 'Table ${tables.length + 1}',
            x: 120,
            y: 120,
          ),
        );
      } else {
        objects.add(
          FloorObject(
            id: id,
            restaurantId: widget.store.currentRestaurant.id,
            type: type,
            label: type == 'wall' ? 'Wall' : 'Entrance',
            x: 80,
            y: 40,
            width: type == 'wall' ? 160 : 48,
            height: type == 'wall' ? 12 : 48,
          ),
        );
      }
    });
  }

  void remove() {
    final t = tables.where((t) => t.id == selected).firstOrNull;
    if (t?.status == TableStatus.occupied) {
      _act(
        context,
        () => throw const DomainException(
          'Move or close the occupied visit before deleting its table.',
        ),
      );
      return;
    }
    setState(() {
      checkpoint();
      tables.removeWhere((t) => t.id == selected);
      objects.removeWhere((o) => o.id == selected);
      selected = null;
    });
  }

  void duplicate() {
    setState(() {
      checkpoint();
      final id = _uniqueId('${widget.store.currentRestaurant.id}-layout', [
        ...tables.map((t) => t.id),
        ...objects.map((o) => o.id),
      ]);
      final t = tables.where((t) => t.id == selected).firstOrNull;
      final o = objects.where((o) => o.id == selected).firstOrNull;
      if (t != null) {
        tables.add(
          t.copyWith(
            id: id,
            label: '${t.label} copy',
            x: (t.x + 30).clamp(0, 700),
            y: (t.y + 30).clamp(0, 500),
            status: TableStatus.available,
          ),
        );
      }
      if (o != null) {
        objects.add(
          o.copyWith(
            id: id,
            x: (o.x + 30).clamp(0, 700),
            y: (o.y + 30).clamp(0, 500),
          ),
        );
      }
      selected = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_manager(widget.store)) {
      return _Empty(
        title: context.tr('Access denied'),
        message: context.tr('A manager or owner can edit the floor plan.'),
      );
    }
    return _DraftGuard(
      dirty: dirty,
      child: _List(
        children: [
          _Heading(
            'Edit your room',
            subtitle:
                'Drag a selected object; positions snap to the 10-unit grid. Deselect to pan.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: undo.isEmpty ? null : () => restore(true),
                icon: const Icon(Icons.undo),
                label: Text(context.tr('Undo')),
              ),
              OutlinedButton.icon(
                onPressed: redo.isEmpty ? null : () => restore(false),
                icon: const Icon(Icons.redo),
                label: Text(context.tr('Redo')),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => list = !list),
                icon: Icon(list ? Icons.map_outlined : Icons.list),
                label: Text(context.tr(list ? 'Plan' : 'List')),
              ),
            ],
          ),
          if (!list) ...[
            SizedBox(
              height: 360,
              child: _RoomCanvas(
                tables: tables,
                objects: objects,
                controller: transform,
                selected: selected,
                onSelect: (id) =>
                    setState(() => selected = selected == id ? null : id),
                onMove: move,
                onMoveStart: () => setState(checkpoint),
                onMoveEnd: snap,
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: context.tr('Zoom in'),
                  onPressed: () {
                    transform.value = transform.value.clone()
                      ..scaleByDouble(1.2, 1.2, 1, 1);
                  },
                  icon: const Icon(Icons.zoom_in),
                ),
                IconButton(
                  tooltip: context.tr('Zoom out'),
                  onPressed: () {
                    transform.value = transform.value.clone()
                      ..scaleByDouble(.8, .8, 1, 1);
                  },
                  icon: const Icon(Icons.zoom_out),
                ),
                TextButton(
                  onPressed: () {
                    final zoom = math.min(
                      (MediaQuery.sizeOf(context).width - 32) / 800,
                      360 / 600,
                    );
                    transform.value = Matrix4.identity()
                      ..scaleByDouble(zoom, zoom, 1, 1);
                  },
                  child: Text(context.tr('Fit room')),
                ),
                TextButton(
                  onPressed: () => setState(() => selected = null),
                  child: Text(context.tr('Deselect')),
                ),
              ],
            ),
          ] else ...[
            for (final t in tables)
              _Link(
                t.label,
                '${t.zone} · x ${t.x.round()} / y ${t.y.round()}',
                Icons.table_restaurant_outlined,
                () => setState(() => selected = t.id),
              ),
            for (final o in objects)
              _Link(
                o.label,
                '${o.type} · x ${o.x.round()} / y ${o.y.round()}',
                Icons.crop_square,
                () => setState(() => selected = o.id),
              ),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge('Available', icon: Icons.circle_outlined),
              _Badge('Occupied', icon: Icons.people_outline),
              _Badge(
                'Needs reset',
                icon: Icons.cleaning_services_outlined,
                attention: true,
              ),
            ],
          ),
          if (selected != null)
            _Card(
              tonal: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tables.where((t) => t.id == selected).firstOrNull?.label ??
                        objects
                            .where((o) => o.id == selected)
                            .firstOrNull
                            ?.label ??
                        '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IconButton(
                        tooltip: context.tr('Move left'),
                        onPressed: () {
                          checkpoint();
                          move(selected!, const Offset(-10, 0));
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      IconButton(
                        tooltip: context.tr('Move up'),
                        onPressed: () {
                          checkpoint();
                          move(selected!, const Offset(0, -10));
                        },
                        icon: const Icon(Icons.arrow_upward),
                      ),
                      IconButton(
                        tooltip: context.tr('Move down'),
                        onPressed: () {
                          checkpoint();
                          move(selected!, const Offset(0, 10));
                        },
                        icon: const Icon(Icons.arrow_downward),
                      ),
                      IconButton(
                        tooltip: context.tr('Move right'),
                        onPressed: () {
                          checkpoint();
                          move(selected!, const Offset(10, 0));
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: inspector,
                        icon: const Icon(Icons.tune),
                        label: Text(context.tr('Inspector')),
                      ),
                      TextButton.icon(
                        onPressed: duplicate,
                        icon: const Icon(Icons.copy_outlined),
                        label: Text(context.tr('Duplicate')),
                      ),
                      TextButton.icon(
                        onPressed: remove,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(context.tr('Delete')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in ['table', 'wall', 'entrance'])
                OutlinedButton.icon(
                  onPressed: () => add(type),
                  icon: const Icon(Icons.add),
                  label: Text('${context.tr('Add')} ${context.tr(type)}'),
                ),
            ],
          ),
          AppButton(
            label: context.tr('Save floor plan'),
            onPressed: dirty
                ? () => _act(context, () {
                    widget.store.saveFloorPlan(tables, objects);
                    setState(() => dirty = false);
                    Navigator.pop(context);
                  })
                : null,
          ),
          TextButton(
            onPressed: () async {
              if (!dirty ||
                  await _confirm(
                    context,
                    'Discard changes?',
                    'The saved floor plan will stay unchanged.',
                    action: 'Discard',
                  )) {
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(context.tr('Cancel')),
          ),
        ],
      ),
    );
  }

  Future<void> inspector() async {
    final id = selected;
    final t = tables.where((t) => t.id == id).firstOrNull;
    final o = objects.where((o) => o.id == id).firstOrNull;
    if (t == null && o == null) return;
    final label = TextEditingController(text: t?.label ?? o!.label),
        zone = TextEditingController(text: t?.zone ?? o!.zone),
        seats = TextEditingController(text: '${t?.seats ?? 4}'),
        x = TextEditingController(text: '${(t?.x ?? o!.x).round()}'),
        y = TextEditingController(text: '${(t?.y ?? o!.y).round()}'),
        width = TextEditingController(
          text: '${(t?.width ?? o!.width).round()}',
        ),
        height = TextEditingController(
          text: '${(t?.height ?? o!.height).round()}',
        ),
        rotation = TextEditingController(
          text: '${(t?.rotation ?? o!.rotation).round()}',
        );
    var shape = t?.shape ?? 'rectangle';
    final form = GlobalKey<FormState>();
    await showAppSheet<void>(
      context,
      enableDrag: false,
      child: StatefulBuilder(
        builder: (context, update) => _InputDraft(
          controllers: [label, zone, seats, x, y, width, height, rotation],
          changed: shape != (t?.shape ?? 'rectangle'),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Heading('Object inspector'),
                const SizedBox(height: 16),
                _field(context, 'Label', label),
                const SizedBox(height: 16),
                _field(context, 'Zone', zone),
                if (t != null) ...[
                  const SizedBox(height: 16),
                  _field(
                    context,
                    'Seats',
                    seats,
                    type: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                        ? null
                        : context.tr('Enter a positive capacity'),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final v in ['round', 'rectangle'])
                        ChoiceChip(
                          label: Text(context.tr(v)),
                          selected: shape == v,
                          onSelected: (_) => update(() => shape = v),
                        ),
                    ],
                  ),
                ],
                for (final entry in {
                  'X position': x,
                  'Y position': y,
                  'Width': width,
                  'Height': height,
                  'Rotation': rotation,
                }.entries) ...[
                  const SizedBox(height: 16),
                  _field(
                    context,
                    entry.key,
                    entry.value,
                    type: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? context.tr('Enter a number')
                        : null,
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  label: context.tr('Apply to draft'),
                  onPressed: () {
                    if (!form.currentState!.validate()) return;
                    final px = double.parse(x.text),
                        py = double.parse(y.text),
                        w = double.parse(width.text),
                        h = double.parse(height.text);
                    if (px < 0 ||
                        py < 0 ||
                        w < 12 ||
                        h < 12 ||
                        px + w > 800 ||
                        py + h > 600) {
                      _act(
                        context,
                        () => throw const DomainException(
                          'Keep the object inside the 800 × 600 room with positive dimensions.',
                        ),
                      );
                      return;
                    }
                    if (t != null &&
                        tables.any(
                          (v) =>
                              v.id != id &&
                              v.label.toLowerCase() ==
                                  label.text.trim().toLowerCase(),
                        )) {
                      _act(
                        context,
                        () => throw const DomainException(
                          'Every table needs a unique label.',
                        ),
                      );
                      return;
                    }
                    setState(() {
                      checkpoint();
                      if (t != null) {
                        tables = tables
                            .map(
                              (v) => v.id == id
                                  ? v.copyWith(
                                      label: label.text.trim(),
                                      zone: zone.text.trim(),
                                      seats: int.parse(seats.text),
                                      shape: shape,
                                      x: px,
                                      y: py,
                                      width: w,
                                      height: h,
                                      rotation:
                                          double.parse(rotation.text) % 360,
                                    )
                                  : v,
                            )
                            .toList();
                      }
                      if (o != null) {
                        objects = objects
                            .map(
                              (v) => v.id == id
                                  ? v.copyWith(
                                      label: label.text.trim(),
                                      zone: zone.text.trim(),
                                      x: px,
                                      y: py,
                                      width: w,
                                      height: h,
                                      rotation:
                                          double.parse(rotation.text) % 360,
                                    )
                                  : v,
                            )
                            .toList();
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    for (final c in [label, zone, seats, x, y, width, height, rotation]) {
      c.dispose();
    }
  }
}
