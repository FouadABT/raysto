import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../design_system/design_system.dart';

class DockDestination {
  const DockDestination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const destinations = [
  DockDestination(
    'Discover',
    PhosphorIconsRegular.compass,
    PhosphorIconsFill.compass,
  ),
  DockDestination(
    'Menu',
    PhosphorIconsRegular.squaresFour,
    PhosphorIconsFill.squaresFour,
  ),
  DockDestination(
    'Saved',
    PhosphorIconsRegular.bookmarkSimple,
    PhosphorIconsFill.bookmarkSimple,
  ),
];

/// Large text gets a roomy navigation sheet instead of crushed dock labels.
class RaystoAdaptiveDock extends StatelessWidget {
  const RaystoAdaptiveDock({
    super.key,
    required this.index,
    required this.options,
    required this.onChanged,
    this.navigateLabel = 'Navigate',
  });
  final int index;
  final List<DockDestination> options;
  final ValueChanged<int> onChanged;
  final String navigateLabel;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    child: MediaQuery.textScalerOf(context).scale(1) <= 1.5
        ? RaystoDock(index: index, options: options, onChanged: onChanged)
        : AppButton(
            label: '${options[index].label} · $navigateLabel',
            icon: options[index].selectedIcon,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              showDragHandle: true,
              sheetAnimationStyle: AppMotion.reduced(context)
                  ? AnimationStyle.noAnimation
                  : null,
              builder: (c) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(c).height * .8,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    for (var i = 0; i < options.length; i++)
                      ListTile(
                        selected: i == index,
                        leading: Icon(options[i].icon),
                        title: Text(options[i].label),
                        trailing: i == index ? const Icon(Icons.check) : null,
                        onTap: () {
                          Navigator.pop(c);
                          onChanged(i);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
  );
}

class RaystoDock extends StatefulWidget {
  const RaystoDock({
    super.key,
    required this.index,
    required this.onChanged,
    this.options = destinations,
  });
  final List<DockDestination> options;
  final int index;
  final ValueChanged<int> onChanged;

  static double contentHeight(
    BuildContext context,
    double availableWidth, {
    List<DockDestination> options = destinations,
  }) {
    final style = Theme.of(context).textTheme.labelMedium!
        .copyWith(fontSize: 12, fontWeight: FontWeight.w600);
    double labelHeight = 0;
    for (final destination in options) {
      final painter =
          TextPainter(
            text: TextSpan(text: destination.label, style: style),
            textScaler: MediaQuery.textScalerOf(context),
            textDirection: Directionality.of(context),
          )..layout(
            maxWidth: math.max(1, (availableWidth - 12) / options.length - 12),
          );
      labelHeight = math.max(labelHeight, painter.height);
      painter.dispose();
    }
    return math.max(68, 46 + labelHeight);
  }

  @override
  State<RaystoDock> createState() => _RaystoDockState();
}

class _RaystoDockState extends State<RaystoDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _position = AnimationController.unbounded(
      vsync: this,
      value: widget.index.toDouble(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = AppMotion.reduced(context);
    if (_reduced) {
      _position.stop();
      _position.value = widget.index.toDouble();
    }
  }

  @override
  void didUpdateWidget(RaystoDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    if (_reduced) {
      _position.value = widget.index.toDouble();
      return;
    }
    final velocity = _position.velocity;
    _position
        .animateWith(
          SpringSimulation(
            const SpringDescription(mass: 1, stiffness: 260, damping: 26),
            _position.value,
            widget.index.toDouble(),
            velocity,
            tolerance: const Tolerance(distance: .001, velocity: .001),
          ),
        )
        .whenCompleteOrCancel(() {
          if (mounted &&
              !_position.isAnimating &&
              (_position.value - widget.index).abs() < .01) {
            _position.value = widget.index.toDouble();
          }
        });
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  Widget _labels(BuildContext context, Color color) => Row(
    children: List.generate(
      widget.options.length,
      (i) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.index == i
                    ? widget.options[i].selectedIcon
                    : widget.options[i].icon,
                size: 23,
                color: color,
              ),
              const SizedBox(height: 5),
              Text(
                widget.options[i].label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = RaystoDock.contentHeight(
        context,
        constraints.maxWidth,
        options: widget.options,
      );
      final width = (constraints.maxWidth - 12) / widget.options.length;
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return Material(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(27),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Keep white on forest and ink on the travelling lime shape,
                // including partially intersected labels during interruption.
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: _labels(context, AppColors.white),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _position,
                        child: ColoredBox(
                          color: AppColors.lime,
                          child: _labels(context, AppColors.ink),
                        ),
                        builder: (context, child) => ClipPath(
                          key: const ValueKey('dock-indicator-clip'),
                          clipper: _DockIndicatorClipper(
                            Rect.fromLTWH(
                              (rtl
                                      ? widget.options.length -
                                            1 -
                                            _position.value
                                      : _position.value) *
                                  width,
                              0,
                              width,
                              height,
                            ),
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    widget.options.length,
                    (i) => Expanded(
                      child: Semantics(
                        selected: widget.index == i,
                        enabled: true,
                        button: true,
                        label: widget.options[i].label,
                        onTap: () => widget.onChanged(i),
                        child: ExcludeSemantics(
                          child: _DockHitTarget(
                            key: ValueKey('dock-$i'),
                            height: height,
                            onTap: () => widget.onChanged(i),
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
    },
  );
}

class _DockIndicatorClipper extends CustomClipper<Path> {
  const _DockIndicatorClipper(this.rect);
  final Rect rect;

  @override
  Path getClip(Size size) =>
      Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(21)));

  @override
  bool shouldReclip(_DockIndicatorClipper oldClipper) =>
      oldClipper.rect != rect;
}

class _DockHitTarget extends StatefulWidget {
  const _DockHitTarget({super.key, required this.height, required this.onTap});
  final double height;
  final VoidCallback onTap;
  @override
  State<_DockHitTarget> createState() => _DockHitTargetState();
}

class _DockHitTargetState extends State<_DockHitTarget> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => Container(
    foregroundDecoration: _focused
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppColors.white, width: 2),
          )
        : null,
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (focused) => setState(() => _focused = focused),
        borderRadius: BorderRadius.circular(21),
        splashColor: AppColors.white.withValues(alpha: .18),
        focusColor: AppColors.forest.withValues(alpha: .16),
        child: SizedBox(height: widget.height),
      ),
    ),
  );
}

/// Branches retain their elements. Only the active branch receives input,
/// focus, accessibility navigation or ticker callbacks.
class RetainedBranches extends StatefulWidget {
  const RetainedBranches({
    super.key,
    required this.index,
    required this.children,
  });
  final int index;
  final List<Widget> children;
  @override
  State<RetainedBranches> createState() => _RetainedBranchesState();
}

class _BranchVisual {
  const _BranchVisual(this.opacity, this.offset, this.scale);
  final double opacity;
  final double offset;
  final double scale;
}

class _RetainedBranchesState extends State<RetainedBranches>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition;
  late List<_BranchVisual> _starts;
  late List<_BranchVisual> _targets;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _transition = AnimationController(
      vsync: this,
      duration: AppMotion.branch,
      value: 1,
    );
    _settle();
  }

  void _settle() {
    _starts = List.generate(
      widget.children.length,
      (i) => _BranchVisual(i == widget.index ? 1 : 0, 0, 1),
    );
    _targets = List.of(_starts);
  }

  _BranchVisual _visual(int index) {
    final start = _starts[index];
    final target = _targets[index];
    final t = _transition.value;
    final spatial = AppMotion.coordinated.transform(t);
    final double fade;
    if (target.opacity == 1) {
      fade = start.opacity == 0 ? ((t - .15) / .85).clamp(0.0, 1.0) : t;
    } else {
      fade = (t / .32).clamp(0.0, 1.0);
    }
    return _BranchVisual(
      start.opacity + (target.opacity - start.opacity) * fade,
      start.offset + (target.offset - start.offset) * spatial,
      start.scale + (target.scale - start.scale) * spatial,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = AppMotion.reduced(context);
    if (_reduced) {
      _settle();
      _transition.value = 1;
    }
  }

  @override
  void didUpdateWidget(RetainedBranches oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _settle();
      _transition.value = 1;
      return;
    }
    if (oldWidget.index == widget.index) return;
    if (_reduced) {
      _settle();
      _transition.value = 1;
      return;
    }
    var direction = widget.index > oldWidget.index ? 1 : -1;
    if (Directionality.of(context) == TextDirection.rtl) direction *= -1;
    // Capture this frame before retargeting: a partial incoming page must not
    // suddenly become a fully opaque outgoing page after another tap.
    final current = List.generate(widget.children.length, _visual);
    _starts = List.generate(widget.children.length, (i) {
      final visual = current[i];
      if (i == widget.index && visual.opacity <= .001) {
        return _BranchVisual(0, 40.0 * direction, .975);
      }
      return visual;
    });
    _targets = List.generate(
      widget.children.length,
      (i) => i == widget.index
          ? const _BranchVisual(1, 0, 1)
          : _BranchVisual(0, -40.0 * direction, .985),
    );
    _transition.forward(from: 0);
  }

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _transition,
    builder: (context, _) => Stack(
      children: List.generate(widget.children.length, (i) {
        final active = i == widget.index;
        final visual = _visual(i);
        return Positioned.fill(
          key: ValueKey('branch-$i'),
          child: Offstage(
            offstage: !active && visual.opacity <= .001,
            child: TickerMode(
              enabled: active,
              child: IgnorePointer(
                ignoring: !active,
                child: ExcludeFocus(
                  excluding: !active,
                  child: ExcludeSemantics(
                    excluding: !active,
                    child: Opacity(
                      key: ValueKey('branch-opacity-$i'),
                      opacity: visual.opacity.clamp(0, 1),
                      child: Transform.translate(
                        offset: Offset(visual.offset, 0),
                        child: Transform.scale(
                          scale: visual.scale,
                          child: widget.children[i],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}
