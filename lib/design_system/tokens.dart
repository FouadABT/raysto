import 'package:flutter/material.dart';

/// Canonical light palette. Status colors use white foregrounds; warm peach is
/// a supporting surface, not a substitute for a semantic error color.
abstract final class AppColors {
  static const paper = Color(0xFFF6F7F2);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF173E34);
  static const forest = Color(0xFF173F35);
  static const muted = Color(0xFF68756C);
  // Canonical muted narrowly misses 4.5:1 on paper. This semantic text alias
  // maintains readable supporting copy on paper, mint and peach surfaces.
  static const secondaryText = Color(0xFF59675E);
  static const lime = Color(0xFFD7F978);
  static const mint = Color(0xFFE6EDE2);
  static const peach = Color(0xFFF3E8DB);
  static const line = Color(0xFFDCE2D9);

  static const error = Color(0xFFA32D32);
  static const onError = white;
  static const warning = Color(0xFF805300);
  static const onWarning = white;
  static const success = Color(0xFF28633F);
  static const onSuccess = white;

  static const primary = forest;
  static const onPrimary = white;
  static const selected = lime;
  static const supportingSurface = mint;
  static const warmSurface = peach;
  static const outlineSubtle = line;
}

abstract final class AppSpace {
  static const micro = 4.0;
  static const small = 8.0;
  static const standard = 12.0;
  static const content = 16.0;
  static const panel = 20.0;
  static const gutter = 22.0;
  static const sheet = 24.0;
  static const section = 28.0;
  static const large = 32.0;
}

abstract final class AppRadius {
  static const card = 24.0;
  static const button = 22.0;
  static const choice = 18.0;
  static const media = 28.0;
  static const sheet = 28.0;
  static const dock = 27.0;
  static const pill = 999.0;
}

abstract final class AppType {
  static const family = 'PlusJakartaSans';

  static TextStyle style(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double height = 1.5,
    double? tracking,
  }) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: const ['NotoSansArabic'],
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: tracking ?? (size >= 28 ? -1.1 : -0.15),
  );
}

/// Semantic status pairs are independent from preparation and payment state.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.information,
    required this.onInformation,
  });
  final Color success,
      onSuccess,
      warning,
      onWarning,
      information,
      onInformation;

  factory AppStatusColors.forBrightness(Brightness brightness) =>
      brightness == Brightness.dark
      ? const AppStatusColors(
          success: Color(0xFF284B35),
          onSuccess: Color(0xFFB9F2C7),
          warning: Color(0xFF503D12),
          onWarning: Color(0xFFFFE1A0),
          information: Color(0xFF243F4B),
          onInformation: Color(0xFFBCE7F5),
        )
      : const AppStatusColors(
          success: Color(0xFFDFEFDE),
          onSuccess: Color(0xFF20512E),
          warning: Color(0xFFF9EBC7),
          onWarning: Color(0xFF674600),
          information: Color(0xFFDCECF3),
          onInformation: Color(0xFF1D4A5B),
        );

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? information,
    Color? onInformation,
  }) => AppStatusColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    information: information ?? this.information,
    onInformation: onInformation ?? this.onInformation,
  );

  @override
  AppStatusColors lerp(covariant AppStatusColors? other, double t) =>
      other == null
      ? this
      : AppStatusColors(
          success: Color.lerp(success, other.success, t)!,
          onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
          warning: Color.lerp(warning, other.warning, t)!,
          onWarning: Color.lerp(onWarning, other.onWarning, t)!,
          information: Color.lerp(information, other.information, t)!,
          onInformation: Color.lerp(onInformation, other.onInformation, t)!,
        );
}
