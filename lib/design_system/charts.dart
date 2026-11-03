import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

/// One point of a series: a short label ("Tue", "14:00") and its value.
@immutable
class ChartPoint {
  const ChartPoint(this.label, this.value);
  final String label;
  final num value;
}

/// One slice of a donut, always named so colour is never the only signal.
@immutable
class ChartSlice {
  const ChartSlice(this.label, this.value);
  final String label;
  final num value;
}

/// Draws its child's progress from 0 to 1 once, when first shown, and never
/// again when the user comes back to the tab or the data refreshes. Under
/// reduced motion the final state is painted at once.
class _DrawOnce extends StatefulWidget {
  const _DrawOnce({required this.builder});
  final Widget Function(BuildContext context, double progress) builder;

  @override
  State<_DrawOnce> createState() => _DrawOnceState();
}

class _DrawOnceState extends State<_DrawOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: AppMotion.reveal,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _progress.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _progress.forward();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => widget.builder(
        context,
        AppMotion.spatial.transform(_progress.value),
      ),
    ),
  );
}

/// The small trend line inside a KPI card.
class RaystoSparkline extends StatelessWidget {
  const RaystoSparkline({
    super.key,
    required this.values,
    required this.semanticLabel,
    this.color,
    this.height = 32,
  });

  final List<num> values;

  /// What the trend is, e.g. "Paid sales, last 7 days".
  final String semanticLabel;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = RaystoChartColors.of(context);
    return Semantics(
      label: semanticLabel,
      value: _trendWords(values),
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: _DrawOnce(
            builder: (context, progress) => CustomPaint(
              painter: _LinePainter(
                values: values,
                progress: progress,
                line: color ?? colors.line,
                area: null,
                stroke: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A line over time with a soft fill, the real series always in front. An
/// optional [sample] series is drawn as a dashed outline behind it, with a
/// "Sample · not real sales" chip that never leaves the chart.
class RaystoAreaChart extends StatelessWidget {
  const RaystoAreaChart({
    super.key,
    required this.points,
    required this.semanticLabel,
    required this.format,
    this.sample,
    this.sampleLabel = 'Sample · not real sales',
    this.height = 200,
  });

  final List<ChartPoint> points;
  final String semanticLabel;
  final String Function(num value) format;

  /// Illustrative values aligned with [points]; never merged with them.
  final List<num>? sample;
  final String sampleLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = RaystoChartColors.of(context);
    final theme = Theme.of(context);
    final values = [for (final p in points) p.value];
    final top = [...values, ...?sample].fold<num>(0, math.max);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final picks = _axisPicks(points.length);
    return Semantics(
      label: semanticLabel,
      value: [
        for (final p in points) '${p.label} ${format(p.value)}',
        if (sample != null) sampleLabel,
      ].join(', '),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sample != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _SampleChip(label: sampleLabel),
              ),
            if (sample != null) const SizedBox(height: AppSpace.small),
            SizedBox(
              height: height,
              child: _DrawOnce(
                builder: (context, progress) => CustomPaint(
                  painter: _AreaPainter(
                    values: values,
                    sample: sample,
                    top: top,
                    progress: progress,
                    colors: colors,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.small),
            Row(
              children: [
                for (final (i, index) in picks.indexed) ...[
                  if (i > 0) const Spacer(),
                  Text(points[index].label, style: labelStyle),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = RaystoChartColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShape.small),
        border: Border.all(color: colors.sample),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 2,
              child: CustomPaint(painter: _DashPainter(colors.sample)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Parts of a whole: channels, sources. The legend names every slice.
class RaystoDonut extends StatelessWidget {
  const RaystoDonut({
    super.key,
    required this.slices,
    required this.semanticLabel,
    required this.format,
    this.center,
    this.size = 148,
    this.thickness = 18,
  });

  final List<ChartSlice> slices;
  final String semanticLabel;
  final String Function(num value) format;
  final Widget? center;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final colors = RaystoChartColors.of(context);
    final theme = Theme.of(context);
    final total = slices.fold<num>(0, (sum, s) => sum + s.value);
    Color colorOf(int i) => colors.series[i % colors.series.length];
    return Semantics(
      label: semanticLabel,
      value: [
        for (final s in slices)
          '${s.label} ${format(s.value)}'
              '${total > 0 ? ', ${(s.value * 100 / total).round()}%' : ''}',
      ].join('; '),
      child: ExcludeSemantics(
        child: Wrap(
          spacing: AppSpace.panel,
          runSpacing: AppSpace.content,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox.square(
              dimension: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _DrawOnce(
                    builder: (context, progress) => CustomPaint(
                      size: Size.square(size),
                      painter: _DonutPainter(
                        values: [for (final s in slices) s.value],
                        colors: [
                          for (var i = 0; i < slices.length; i++) colorOf(i),
                        ],
                        track: colors.track,
                        thickness: thickness,
                        progress: progress,
                      ),
                    ),
                  ),
                  ?center,
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, s) in slices.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    // At large text in a narrow column the amount moves
                    // under its name rather than off the edge; it stays whole.
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colorOf(i),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                s.label,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          format(s.value),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress toward a goal, e.g. today's sales against the daily target. The
/// arc stops at a full turn; the words say when the goal is passed.
class RaystoRing extends StatelessWidget {
  const RaystoRing({
    super.key,
    required this.value,
    required this.semanticLabel,
    required this.semanticValue,
    this.center,
    this.size = 96,
    this.thickness = 10,
    this.color,
  });

  /// 0 to 1 (and beyond, when a goal is passed).
  final double value;
  final String semanticLabel;

  /// The value in words, e.g. "$215 of $300, 72%".
  final String semanticValue;
  final Widget? center;
  final double size;
  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = RaystoChartColors.of(context);
    return Semantics(
      label: semanticLabel,
      value: semanticValue,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _DrawOnce(
                builder: (context, progress) => CustomPaint(
                  size: Size.square(size),
                  painter: _RingPainter(
                    value: value.isFinite ? value.clamp(0.0, 1.0) : 0,
                    progress: progress,
                    color: color ?? colors.series.first,
                    track: colors.track,
                    thickness: thickness,
                  ),
                ),
              ),
              ?center,
            ],
          ),
        ),
      ),
    );
  }
}

/// "Rising", "falling" or "flat": the trend of a series in words.
String _trendWords(List<num> values) {
  if (values.length < 2) return values.isEmpty ? 'No data' : 'One value';
  final first = values.first, last = values.last;
  if (last > first) return 'Rising';
  if (last < first) return 'Falling';
  return 'Flat';
}

/// The indices whose labels sit under a chart: first, middle and last, or
/// every label when there are few.
List<int> _axisPicks(int length) {
  if (length <= 0) return const [];
  if (length <= 4) return [for (var i = 0; i < length; i++) i];
  return [0, length ~/ 2, length - 1];
}

Path _linePath(List<num> values, num top, Size size, {double inset = 2}) {
  final path = Path();
  if (values.isEmpty) return path;
  final height = size.height - inset * 2;
  double x(int i) =>
      values.length == 1 ? size.width / 2 : size.width * i / (values.length - 1);
  double y(num v) =>
      inset + height - (top <= 0 ? 0 : height * (v / top).clamp(0, 1));
  path.moveTo(x(0), y(values[0]));
  // A gentle curve through the points, never overshooting below zero.
  for (var i = 1; i < values.length; i++) {
    final px = x(i - 1), py = y(values[i - 1]);
    final nx = x(i), ny = y(values[i]);
    final mid = (px + nx) / 2;
    path.cubicTo(mid, py, mid, ny, nx, ny);
  }
  return path;
}

Path _partial(Path path, double progress) {
  if (progress >= 1) return path;
  final out = Path();
  for (final PathMetric metric in path.computeMetrics()) {
    out.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
  }
  return out;
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.progress,
    required this.line,
    required this.area,
    required this.stroke,
  });
  final List<num> values;
  final double progress;
  final Color line;
  final Color? area;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final top = values.fold<num>(0, math.max);
    final path = _linePath(values, top, size, inset: stroke);
    canvas.drawPath(
      _partial(path, progress),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.progress != progress || old.values != values || old.line != line;
}

class _AreaPainter extends CustomPainter {
  _AreaPainter({
    required this.values,
    required this.sample,
    required this.top,
    required this.progress,
    required this.colors,
  });
  final List<num> values;
  final List<num>? sample;
  final num top;
  final double progress;
  final RaystoChartColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = colors.grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final sample = this.sample;
    if (sample != null && sample.isNotEmpty) {
      final outline = _linePath(sample, top, size);
      final dashed = Paint()
        ..color = colors.sample
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (final metric in _partial(outline, progress).computeMetrics()) {
        for (double d = 0; d < metric.length; d += 9) {
          canvas.drawPath(metric.extractPath(d, math.min(d + 5, metric.length)), dashed);
        }
      }
    }
    if (values.isEmpty) return;
    final line = _linePath(values, top, size);
    // The fill follows the drawing pen: it is clipped to the drawn width.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    final fill = Path.from(line)
      ..lineTo(values.length == 1 ? size.width / 2 : size.width, size.height)
      ..lineTo(values.length == 1 ? size.width / 2 : 0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.area.withValues(alpha: .55),
            colors.area.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();
    canvas.drawPath(
      _partial(line, progress),
      Paint()
        ..color = colors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_AreaPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.sample != sample ||
      old.top != top ||
      old.colors != colors;
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    for (double x = 0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + 4, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.track,
    required this.thickness,
    required this.progress,
  });
  final List<num> values;
  final List<Color> colors;
  final Color track;
  final double thickness;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(thickness / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    final total = values.fold<num>(0, (sum, v) => sum + v);
    if (total <= 0) return;
    // A small gap between slices keeps neighbours apart without colour.
    const gap = 0.035;
    var start = -math.pi / 2;
    final budget = math.pi * 2 * progress;
    var used = 0.0;
    for (var i = 0; i < values.length; i++) {
      final sweep = math.pi * 2 * (values[i] / total);
      final drawn = math.min(sweep, budget - used);
      if (drawn <= 0) break;
      final visible = math.max(0.0, drawn - (values.length > 1 ? gap : 0));
      if (visible > 0) {
        canvas.drawArc(
          rect,
          start,
          visible,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness
            ..strokeCap = StrokeCap.butt
            ..color = colors[i],
        );
      }
      start += sweep;
      used += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.values != values || old.colors != colors;
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.progress,
    required this.color,
    required this.track,
    required this.thickness,
  });
  final double value;
  final double progress;
  final Color color;
  final Color track;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(thickness / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    final sweep = math.pi * 2 * value * progress;
    if (sweep > 0) {
      canvas.drawArc(rect, -math.pi / 2, sweep, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.value != value || old.color != color;
}
