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

  /// Text and icons on lime: deeper than ink, so small text stays readable.
  static const limeInk = Color(0xFF2B3D06);
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

/// Material 3 corner scale. Cards keep the approved 24 (`AppRadius.card`),
/// a deliberate step between large and extra-large.
abstract final class AppShape {
  static const none = 0.0;
  static const extraSmall = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const card = AppRadius.card;
  static const extraLarge = 28.0;
  static const full = AppRadius.pill;
}

/// Material 3 state-layer opacities, laid over a surface in its "on" colour.
abstract final class AppStateLayer {
  static const hover = 0.08;
  static const focus = 0.10;
  static const pressed = 0.10;
  static const dragged = 0.16;
}

abstract final class AppType {
  static const family = 'PlusJakartaSans';

  /// Display emphasis only: the italic serif of a greeting's name. Arabic
  /// falls back to Noto Sans Arabic.
  static const displayItalic = 'FrauncesItalic';

  static TextStyle emphasis(
    double size, {
    Color color = AppColors.ink,
    double height = 1.15,
  }) => TextStyle(
    fontFamily: displayItalic,
    fontFamilyFallback: const ['NotoSansArabic'],
    fontStyle: FontStyle.italic,
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color,
    height: height,
    letterSpacing: size >= 28 ? -0.6 : 0,
  );

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

/// Chart colours. Series colours reach 3:1 against their surface, as
/// graphical objects must; a series is also always named, never colour alone.
@immutable
class RaystoChartColors extends ThemeExtension<RaystoChartColors> {
  const RaystoChartColors({
    required this.series,
    required this.line,
    required this.area,
    required this.grid,
    required this.sample,
    required this.track,
  });

  /// Categorical series, in order (channels, lanes, segments).
  final List<Color> series;

  /// The main line, its area fill (drawn with fading opacity), the grid,
  /// the dashed sample outline and a ring's empty track.
  final Color line, area, grid, sample, track;

  static const _light = RaystoChartColors(
    series: [
      Color(0xFF173F35), // forest: the real series
      Color(0xFF6A8F1F), // olive: lime's readable partner on white
      Color(0xFFB27A14), // mustard, darkened to 3:1 on white
      Color(0xFFB5543A), // burnt orange
      Color(0xFF5C7A8A), // slate
    ],
    line: Color(0xFF173F35),
    area: Color(0xFFD7F978),
    grid: Color(0xFFDCE2D9),
    sample: Color(0xFF68756C),
    track: Color(0xFFE6EDE2),
  );

  static const _dark = RaystoChartColors(
    series: [
      Color(0xFFB7DDA6),
      Color(0xFFD7F978),
      Color(0xFFF2A585),
      Color(0xFFF0C27A),
      Color(0xFFBDCABD),
    ],
    line: Color(0xFFD7F978),
    area: Color(0xFFD7F978),
    grid: Color(0xFF435647),
    sample: Color(0xFF8E9D8F),
    track: Color(0xFF2B3C31),
  );

  factory RaystoChartColors.forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;

  static RaystoChartColors of(BuildContext context) =>
      Theme.of(context).extension<RaystoChartColors>() ??
      RaystoChartColors.forBrightness(Theme.of(context).brightness);

  @override
  RaystoChartColors copyWith({
    List<Color>? series,
    Color? line,
    Color? area,
    Color? grid,
    Color? sample,
    Color? track,
  }) => RaystoChartColors(
    series: series ?? this.series,
    line: line ?? this.line,
    area: area ?? this.area,
    grid: grid ?? this.grid,
    sample: sample ?? this.sample,
    track: track ?? this.track,
  );

  @override
  RaystoChartColors lerp(covariant RaystoChartColors? other, double t) =>
      other == null
      ? this
      : RaystoChartColors(
          series: [
            for (var i = 0; i < series.length; i++)
              Color.lerp(
                series[i],
                other.series[i % other.series.length],
                t,
              )!,
          ],
          line: Color.lerp(line, other.line, t)!,
          area: Color.lerp(area, other.area, t)!,
          grid: Color.lerp(grid, other.grid, t)!,
          sample: Color.lerp(sample, other.sample, t)!,
          track: Color.lerp(track, other.track, t)!,
        );
}
