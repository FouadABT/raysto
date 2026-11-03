import 'package:flutter/material.dart';

/// Material 3 motion tokens (see docs/design-tokens.json). Durations sit on
/// Material's steps: short 50–200, medium 250–400, long 450–600 ms.
abstract final class AppMotion {
  static const feedback = Duration(milliseconds: 150); // short3
  static const selection = Duration(milliseconds: 250); // medium1
  static const branch = Duration(milliseconds: 400); // medium4
  static const sheet = Duration(milliseconds: 350); // medium3
  static const sheetReverse = Duration(milliseconds: 250); // medium1
  static const milestone = Duration(milliseconds: 450); // long1
  static const dock = Duration(milliseconds: 450); // long1
  static const reveal = Duration(milliseconds: 600); // long4

  /// Things arriving: emphasized decelerate.
  static const spatial = Easing.emphasizedDecelerate;

  /// Things moving from one place to another, start and end on screen.
  static const coordinated = Curves.easeInOutCubicEmphasized;

  /// Colour, opacity and small state changes: standard.
  static const effects = Easing.standard;

  /// Things leaving: emphasized accelerate.
  static const exit = Easing.emphasizedAccelerate;

  /// The entrance stagger of the guidelines: `min(order × 0.09, 0.36)` of
  /// [reveal], so the twentieth card does not wait for the first nineteen.
  static Duration stagger(int order) => Duration(
    milliseconds: (reveal.inMilliseconds * (order * 0.09).clamp(0.0, 0.36))
        .round(),
  );

  /// App preferences can add reduced motion, never override device preferences.
  static bool reduced(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_MotionData>();
    final platform =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    return (inherited?.reducedMotion ?? false) ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        platform.disableAnimations ||
        platform.reduceMotion;
  }

  static Duration duration(BuildContext context, Duration normal) =>
      reduced(context) ? Duration.zero : normal;
}

/// Listens for device accessibility changes as well as app preference changes.
class MotionScope extends StatefulWidget {
  const MotionScope({
    super.key,
    required this.reducedMotion,
    required this.child,
  });

  final bool reducedMotion;
  final Widget child;

  @override
  State<MotionScope> createState() => _MotionScopeState();
}

class _MotionScopeState extends State<MotionScope> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAccessibilityFeatures() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ancestor = context.dependOnInheritedWidgetOfExactType<_MotionData>();
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    return _MotionData(
      reducedMotion:
          widget.reducedMotion ||
          (ancestor?.reducedMotion ?? false) ||
          features.disableAnimations ||
          features.reduceMotion,
      child: widget.child,
    );
  }
}

class _MotionData extends InheritedWidget {
  const _MotionData({required this.reducedMotion, required super.child});

  final bool reducedMotion;

  @override
  bool updateShouldNotify(_MotionData oldWidget) =>
      reducedMotion != oldWidget.reducedMotion;
}
