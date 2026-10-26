import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const feedback = Duration(milliseconds: 140);
  static const selection = Duration(milliseconds: 240);
  static const branch = Duration(milliseconds: 400);
  static const sheet = Duration(milliseconds: 360);
  static const sheetReverse = Duration(milliseconds: 240);
  static const milestone = Duration(milliseconds: 440);
  static const dock = Duration(milliseconds: 460);
  static const reveal = Duration(milliseconds: 650);

  static const spatial = Curves.easeOutCubic;
  static const coordinated = Curves.easeInOutCubicEmphasized;
  static const effects = Curves.easeInOut;

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
