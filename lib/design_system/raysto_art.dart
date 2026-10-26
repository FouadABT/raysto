import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'controls.dart';
import 'motion.dart';
import 'tokens.dart';

/// Raysto's own little printed-menu illustration family. These are decoration,
/// never a substitute for an action label, an actual dish photo or order state.
enum RaystoScene { table, menu, bag, kitchen, receipt, sprout }

/// A bounded entrance: no decorative animation keeps a screen awake. Content
/// stays mounted through refreshes; accessibility changes settle immediately.
class RaystoReveal extends StatefulWidget {
  const RaystoReveal({super.key, required this.child});
  final Widget child;

  @override
  State<RaystoReveal> createState() => _RaystoRevealState();
}

class _RaystoRevealState extends State<RaystoReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.reveal,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(_controller.value);
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      );
    },
  );
}

class RaystoWordmark extends StatelessWidget {
  const RaystoWordmark({super.key, this.inverse = false});
  final bool inverse;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Raysto',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'raysto',
          style: AppType.style(
            29,
            weight: FontWeight.w700,
            tracking: -1.5,
            color: inverse
                ? AppColors.paper
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 5),
        CustomPaint(
          size: const Size(19, 19),
          painter: _RosettePainter(
            inverse ? AppColors.lime : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ),
  );
}

/// Textured original art is bundled and decoded at a bounded size. The native
/// motifs elsewhere use the same plate curves, olive leaves and print marks.
class RaystoTableArt extends StatelessWidget {
  const RaystoTableArt({super.key, this.height = 165});
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: Image.asset(
        'assets/images/raysto-table-story.png',
        height: height,
        width: double.infinity,
        fit: BoxFit.contain,
        cacheWidth: 960,
        filterQuality: FilterQuality.medium,
      ),
    ),
  );
}

class RaystoStoryHeader extends StatelessWidget {
  const RaystoStoryHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
    this.scene = RaystoScene.table,
    this.dark = false,
    this.compact = false,
    this.tableArt = false,
    this.action,
  });
  final String eyebrow, title, message;
  final RaystoScene scene;
  final bool dark, compact, tableArt;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = dark ? AppColors.paper : scheme.onSurface;
    final muted = dark ? AppColors.mint : scheme.onSurfaceVariant;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final heading = Semantics(
      header: true,
      child: Text(
        title,
        style: AppType.style(
          largeText
              ? 22
              : compact
              ? 26
              : 32,
          color: ink,
          weight: FontWeight.w700,
          height: 1.12,
        ),
      ),
    );
    return RaystoReveal(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(28),
        ),
        child: ColoredBox(
          color: dark ? AppColors.forest : scheme.surfaceContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            eyebrow.toUpperCase(),
                            style: AppType.style(
                              11,
                              color: dark ? AppColors.lime : muted,
                              tracking: 1.7,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (compact && !tableArt)
                          RaystoIllustration(
                            scene: scene,
                            width: 76,
                            height: 60,
                            inverse: dark,
                          )
                        else
                          CustomPaint(
                            size: const Size(24, 24),
                            painter: _RosettePainter(
                              dark ? AppColors.lime : scheme.primary,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: compact ? 2 : 16),
                    if (compact && tableArt && !largeText)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 285 ||
                              MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                heading,
                                const SizedBox(height: 10),
                                const RaystoTableArt(height: 112),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: heading),
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 132,
                                child: RaystoTableArt(height: 116),
                              ),
                            ],
                          );
                        },
                      )
                    else
                      heading,
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: muted),
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 16),
                      action!,
                    ],
                  ],
                ),
              ),
              if (!compact && !largeText)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: tableArt
                      ? const RaystoTableArt()
                      : RaystoIllustration(
                          scene: scene,
                          height: 120,
                          inverse: dark,
                        ),
                ),
              ExcludeSemantics(
                child: CustomPaint(
                  size: const Size(double.infinity, 9),
                  painter: _PrintEdge(dark ? AppColors.lime : scheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RaystoActionCard extends StatelessWidget {
  const RaystoActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.featured = false,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppTapSurface(
      onTap: onTap,
      color: featured
          ? scheme.tertiaryContainer
          : scheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExcludeSemantics(
                  child: CustomPaint(
                    size: const Size(46, 46),
                    painter: _RosettePainter(
                      featured ? AppColors.lime : scheme.surfaceContainer,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 23,
                  color: featured ? AppColors.forest : scheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_rounded, size: 19),
        ],
      ),
    );
  }
}

class RaystoRestaurantCard extends StatelessWidget {
  const RaystoRestaurantCard({
    super.key,
    required this.name,
    required this.address,
    required this.isOpen,
    required this.onTap,
    this.modes = const [],
  });
  final String name, address;
  final bool isOpen;
  final List<String> modes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppTapSurface(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              isOpen ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
              size: 18,
            ),
            Text(
              isOpen ? 'Open now' : 'Closed now',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 5),
        Text(
          address,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                modes.isEmpty ? 'View the menu' : modes.join(' · '),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_outward_rounded, size: 21),
          ],
        ),
      ],
    ),
  );
}

class RaystoEmptyState extends StatelessWidget {
  const RaystoEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.scene = RaystoScene.table,
    this.action,
  });
  final String title, message;
  final RaystoScene scene;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
    child: Column(
      children: [
        RaystoIllustration(scene: scene, height: 118, width: 180),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

class RaystoIllustration extends StatefulWidget {
  const RaystoIllustration({
    super.key,
    required this.scene,
    this.width,
    this.height = 120,
    this.inverse = false,
  });
  final RaystoScene scene;
  final double? width;
  final double height;
  final bool inverse;

  @override
  State<RaystoIllustration> createState() => _RaystoIllustrationState();
}

class _RaystoIllustrationState extends State<RaystoIllustration>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _BistroPainter(
            widget.scene,
            _controller,
            widget.inverse
                ? AppColors.paper
                : Theme.of(context).colorScheme.onSurface,
            widget.inverse
                ? AppColors.lime
                : Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ),
    ),
  );
}

Path _rosette(Offset center, double radius, {int petals = 12}) {
  final p = Path();
  for (var i = 0; i <= 180; i++) {
    final angle = i / 180 * math.pi * 2;
    final r = radius * (1 + .055 * math.cos(angle * petals));
    final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
    if (i == 0) {
      p.moveTo(point.dx, point.dy);
    } else {
      p.lineTo(point.dx, point.dy);
    }
  }
  return p..close();
}

class _RosettePainter extends CustomPainter {
  const _RosettePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    _rosette(size.center(Offset.zero), size.shortestSide * .46, petals: 9),
    Paint()..color = color,
  );
  @override
  bool shouldRepaint(_RosettePainter old) => old.color != color;
}

class _PrintEdge extends CustomPainter {
  const _PrintEdge(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: .32);
    for (double x = 0; x < size.width; x += 18) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 9, 4), paint);
      canvas.drawRect(Rect.fromLTWH(x + 9, 4, 9, 4), paint);
    }
  }

  @override
  bool shouldRepaint(_PrintEdge old) => old.color != color;
}

/// Small, authored vector scenes: one drawing pass, no offscreen saveLayer,
/// clipping masks, random frame allocations or downloaded animation runtime.
class _BistroPainter extends CustomPainter {
  _BistroPainter(this.scene, this.progress, this.ink, this.accent)
    : super(repaint: progress);
  final RaystoScene scene;
  final Animation<double> progress;
  final Color ink, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 200, size.height / 140);
    canvas.save();
    canvas.translate((size.width - 200 * s) / 2, (size.height - 140 * s) / 2);
    canvas.scale(s);
    final t = Curves.easeOutCubic.transform(progress.value);
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = accent;
    canvas.drawOval(
      const Rect.fromLTWH(26, 113, 148, 8),
      Paint()..color = ink.withValues(alpha: .07),
    );
    canvas.save();
    canvas.translate(0, 10 * (1 - t));
    void stroke(Path p) => canvas.drawPath(p, line);
    void leaf(double x, double y, double angle) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(-20, -26, 0, -35)
          ..quadraticBezierTo(20, -14, 0, 0),
        Paint()..color = ink,
      );
      canvas.drawLine(
        const Offset(0, -4),
        const Offset(0, -26),
        Paint()
          ..color = accent
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }

    switch (scene) {
      case RaystoScene.table:
        canvas.drawPath(_rosette(const Offset(101, 75), 41), fill);
        canvas.drawPath(_rosette(const Offset(101, 75), 41), line);
        canvas.drawCircle(const Offset(101, 75), 29, line..strokeWidth = 1.5);
        line.strokeWidth = 2.5;
        leaf(98, 85, -.55);
        leaf(102, 85, .8);
        stroke(
          Path()
            ..moveTo(43, 40)
            ..lineTo(43, 106)
            ..moveTo(35, 40)
            ..lineTo(35, 59)
            ..quadraticBezierTo(43, 70, 51, 59)
            ..lineTo(51, 40),
        );
        canvas.drawOval(const Rect.fromLTWH(153, 38, 17, 29), line);
        canvas.drawLine(const Offset(161, 67), const Offset(161, 107), line);
      case RaystoScene.menu:
      case RaystoScene.receipt:
        canvas.save();
        canvas.translate(100, 71);
        canvas.rotate(-.09 * t);
        final paper = Path()
          ..moveTo(-37, -48)
          ..lineTo(37, -48)
          ..lineTo(37, 44);
        for (var i = 0; i < 7; i++) {
          paper.lineTo(37 - i * 11.0 - 5, 38);
          paper.lineTo(26 - i * 11.0, 44);
        }
        paper
          ..lineTo(-37, -48)
          ..close();
        canvas.drawPath(paper, fill);
        canvas.drawPath(paper, line);
        if (scene == RaystoScene.menu) {
          canvas.drawCircle(const Offset(0, -20), 13, line);
          leaf(2, -12, .5);
        } else {
          stroke(
            Path()
              ..moveTo(-12, -20)
              ..lineTo(-3, -11)
              ..lineTo(14, -30),
          );
        }
        for (var y = 7.0; y <= 27; y += 10) {
          canvas.drawLine(Offset(-22, y), Offset(y == 27 ? 6 : 22, y), line);
        }
        canvas.restore();
      case RaystoScene.bag:
        final bag = Path()
          ..moveTo(62, 48)
          ..lineTo(137, 48)
          ..lineTo(145, 113)
          ..lineTo(55, 113)
          ..close();
        canvas.drawPath(bag, fill);
        canvas.drawPath(bag, line);
        stroke(
          Path()
            ..moveTo(81, 55)
            ..lineTo(81, 35)
            ..cubicTo(81, 11, 120, 11, 120, 35)
            ..lineTo(120, 55),
        );
        canvas.drawPath(
          _rosette(const Offset(100, 82), 17),
          Paint()..color = ink,
        );
        canvas.drawLine(
          const Offset(94, 82),
          const Offset(99, 87),
          Paint()
            ..color = accent
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          const Offset(99, 87),
          const Offset(108, 76),
          Paint()
            ..color = accent
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      case RaystoScene.kitchen:
        final dome = Path()
          ..moveTo(49, 103)
          ..cubicTo(49, 36, 151, 36, 151, 103)
          ..close();
        canvas.drawPath(dome, fill);
        canvas.drawPath(dome, line);
        canvas.drawLine(const Offset(39, 111), const Offset(161, 111), line);
        canvas.drawOval(const Rect.fromLTWH(94, 40, 12, 10), line);
        stroke(
          Path()
            ..moveTo(64, 90)
            ..quadraticBezierTo(68, 68, 84, 65),
        );
        for (var i = 0; i < 3; i++) {
          final x = 77 + i * 22.0;
          stroke(
            Path()
              ..moveTo(x, 30 - t * 5)
              ..cubicTo(x - 7, 23 - t * 5, x + 8, 19 - t * 5, x, 11 - t * 5),
          );
        }
      case RaystoScene.sprout:
        canvas.drawPath(_rosette(const Offset(99, 72), 46), fill);
        stroke(
          Path()
            ..moveTo(99, 113)
            ..quadraticBezierTo(101, 73, 111, 40),
        );
        leaf(102, 82, -.9);
        leaf(105, 68, .7);
        leaf(108, 52, -.4);
        canvas.drawArc(
          const Rect.fromLTWH(70, 94, 58, 29),
          0,
          math.pi,
          false,
          line,
        );
    }
    canvas.restore();
    // Print registration marks arrive last; the settled scene is fully static.
    line.color = ink.withValues(alpha: t);
    canvas.drawLine(const Offset(164, 27), const Offset(164, 38), line);
    canvas.drawLine(const Offset(159, 32), const Offset(169, 32), line);
    canvas.drawCircle(const Offset(31, 87), 2.2, Paint()..color = ink);
    canvas.drawCircle(const Offset(173, 101), 1.5, Paint()..color = ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BistroPainter old) =>
      old.scene != scene ||
      old.ink != ink ||
      old.accent != accent ||
      old.progress != progress;
}
