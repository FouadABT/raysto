import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'motion.dart';
import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final lightScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.forest,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.forest,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.mint,
          onPrimaryContainer: AppColors.ink,
          secondary: AppColors.forest,
          onSecondary: AppColors.white,
          secondaryContainer: AppColors.lime,
          onSecondaryContainer: AppColors.ink,
          tertiaryContainer: AppColors.peach,
          onTertiaryContainer: AppColors.ink,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          surfaceContainerLowest: AppColors.white,
          surfaceContainerLow: AppColors.paper,
          surfaceContainer: AppColors.mint,
          onSurfaceVariant: AppColors.secondaryText,
          outline: AppColors.muted,
          outlineVariant: AppColors.line,
          error: AppColors.error,
          onError: AppColors.onError,
        );
    final scheme = dark
        ? ColorScheme.fromSeed(
            seedColor: AppColors.lime,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFFB7DDA6),
            onPrimary: const Color(0xFF153821),
            primaryContainer: const Color(0xFF2C4B38),
            onPrimaryContainer: const Color(0xFFD6EFCF),
            secondary: AppColors.lime,
            onSecondary: const Color(0xFF253509),
            secondaryContainer: const Color(0xFF3D4C22),
            onSecondaryContainer: const Color(0xFFE0F5B7),
            tertiaryContainer: const Color(0xFF4C3D2D),
            onTertiaryContainer: const Color(0xFFF6DFC2),
            surface: const Color(0xFF111B17),
            onSurface: const Color(0xFFE3ECE2),
            surfaceContainerLowest: const Color(0xFF18251E),
            surfaceContainerLow: const Color(0xFF1D2B23),
            surfaceContainer: const Color(0xFF233329),
            surfaceContainerHigh: const Color(0xFF2B3C31),
            surfaceContainerHighest: const Color(0xFF344639),
            onSurfaceVariant: const Color(0xFFBDCABD),
            outline: const Color(0xFF8E9D8F),
            outlineVariant: const Color(0xFF435647),
            error: const Color(0xFFFFB4AB),
            onError: const Color(0xFF690005),
          )
        : lightScheme;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppType.family,
      fontFamilyFallback: const ['NotoSansArabic'],
      extensions: [AppStatusColors.forBrightness(brightness)],
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _MotionAwarePageTransitionsBuilder(
            PredictiveBackPageTransitionsBuilder(),
          ),
          TargetPlatform.iOS: _MotionAwarePageTransitionsBuilder(
            CupertinoPageTransitionsBuilder(),
          ),
          TargetPlatform.macOS: _MotionAwarePageTransitionsBuilder(
            CupertinoPageTransitionsBuilder(),
          ),
          TargetPlatform.windows: _MotionAwarePageTransitionsBuilder(
            FadeForwardsPageTransitionsBuilder(),
          ),
          TargetPlatform.linux: _MotionAwarePageTransitionsBuilder(
            FadeForwardsPageTransitionsBuilder(),
          ),
        },
      ),
      textTheme: TextTheme(
        displayLarge: AppType.style(36, weight: FontWeight.w700, height: 1.12),
        displayMedium: AppType.style(34, weight: FontWeight.w700, height: 1.15),
        displaySmall: AppType.style(32, weight: FontWeight.w700, height: 1.18),
        headlineLarge: AppType.style(32, weight: FontWeight.w700, height: 1.18),
        headlineMedium: AppType.style(28, weight: FontWeight.w700, height: 1.2),
        headlineSmall: AppType.style(24, weight: FontWeight.w600, height: 1.25),
        titleLarge: AppType.style(21, weight: FontWeight.w600, height: 1.3),
        titleMedium: AppType.style(16, weight: FontWeight.w600, height: 1.35),
        titleSmall: AppType.style(14, weight: FontWeight.w600, height: 1.4),
        bodyLarge: AppType.style(16, height: 1.6),
        bodyMedium: AppType.style(14, height: 1.6),
        bodySmall: AppType.style(
          12,
          color: scheme.onSurfaceVariant,
          height: 1.6,
        ),
        labelLarge: AppType.style(15, weight: FontWeight.w600, height: 1.3),
        labelMedium: AppType.style(12, weight: FontWeight.w600, height: 1.4),
        labelSmall: AppType.style(11, weight: FontWeight.w600, height: 1.4),
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpace.gutter,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x66173E34),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.all(AppSpace.content),
        hintStyle: AppType.style(14, color: scheme.onSurfaceVariant),
        errorStyle: AppType.style(12, color: scheme.error),
        errorMaxLines: 4,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.choice),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.choice),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.choice),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.choice),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.choice),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.secondaryContainer,
        selectionHandleColor: scheme.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.forest,
        contentTextStyle: AppType.style(14, color: AppColors.white),
        actionTextColor: AppColors.lime,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onSecondaryContainer
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.all(scheme.outline),
      ),
    );
  }
}

/// Native gesture detectors remain mounted in reduced motion. Passive movement
/// is suppressed by fixing the animations, not by deleting the route wrapper.
class _MotionAwarePageTransitionsBuilder extends PageTransitionsBuilder {
  const _MotionAwarePageTransitionsBuilder(this.delegate);

  final PageTransitionsBuilder delegate;

  @override
  Duration get transitionDuration => delegate.transitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Widget transition(BuildContext context) {
      final suppress =
          AppMotion.reduced(context) && !route.popGestureInProgress;
      return delegate.buildTransitions<T>(
        route,
        context,
        suppress ? kAlwaysCompleteAnimation : animation,
        suppress ? kAlwaysDismissedAnimation : secondaryAnimation,
        child,
      );
    }

    final navigator = route.navigator;
    if (navigator == null) return transition(context);
    return ValueListenableBuilder<bool>(
      valueListenable: navigator.userGestureInProgressNotifier,
      builder: (context, _, _) => transition(context),
    );
  }
}
