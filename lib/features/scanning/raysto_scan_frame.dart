import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

/// A single introductory sweep guides placement without a perpetual pulse.
/// Detection and the actual scan window remain owned by MobileScanner.
class RaystoScanFrame extends StatelessWidget {
  const RaystoScanFrame({super.key, required this.window});
  final Rect window;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: AppMotion.reduced(context) ? 1 : 0, end: 1),
        duration: AppMotion.duration(
          context,
          const Duration(milliseconds: 1100),
        ),
        builder: (context, t, _) =>
            CustomPaint(painter: _FramePainter(window, t)),
      ),
    ),
  );
}

class _FramePainter extends CustomPainter {
  const _FramePainter(this.window, this.progress);
  final Rect window;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(window, const Radius.circular(24)));
    canvas.drawPath(mask, Paint()..color = Colors.black.withValues(alpha: .5));
    final ink = Paint()
      ..color = AppColors.lime
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final corner in [
      window.topLeft,
      window.topRight,
      window.bottomLeft,
      window.bottomRight,
    ]) {
      final dx = corner.dx == window.left ? 1.0 : -1.0;
      final dy = corner.dy == window.top ? 1.0 : -1.0;
      final path = Path()
        ..moveTo(corner.dx + dx * 38, corner.dy)
        ..lineTo(corner.dx + dx * 24, corner.dy)
        ..quadraticBezierTo(
          corner.dx,
          corner.dy,
          corner.dx,
          corner.dy + dy * 24,
        )
        ..lineTo(corner.dx, corner.dy + dy * 38);
      canvas.drawPath(path, ink);
    }
    final y = window.top + 24 + (window.height - 48) * progress;
    canvas.drawLine(
      Offset(window.left + 16, y),
      Offset(window.right - 16, y),
      Paint()
        ..color = AppColors.lime.withValues(
          alpha: math.sin(progress * math.pi).clamp(0, 1) * .7,
        )
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.window != window || old.progress != progress;
}
