import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';

/// The Flutter half of docs/design-tokens.json must say what the file says.
/// The console's half is checked by web/tests/tokens.test.ts.
void main() {
  final tokens =
      jsonDecode(File('docs/design-tokens.json').readAsStringSync())
          as Map<String, dynamic>;
  Map<String, dynamic> at(List<String> path) {
    dynamic node = tokens;
    for (final key in path) {
      node = (node as Map<String, dynamic>)[key];
    }
    return node as Map<String, dynamic>;
  }

  Color color(Map<String, dynamic> group, String name) {
    final hex = (group[name] as Map)[r'$value'] as String;
    return Color(int.parse('ff${hex.substring(1)}', radix: 16));
  }

  Duration duration(Map<String, dynamic> group, String name) {
    final value = (group[name] as Map)[r'$value'] as String;
    return Duration(milliseconds: int.parse(value.replaceAll('ms', '')));
  }

  void sameCurve(Curve actual, Map<String, dynamic> group, String name) {
    final bezier = ((group[name] as Map)[r'$value'] as List)
        .map((v) => (v as num).toDouble())
        .toList();
    expect(actual, isA<Cubic>(), reason: name);
    final cubic = actual as Cubic;
    expect([cubic.a, cubic.b, cubic.c, cubic.d], bezier, reason: name);
  }

  test('the light colour scheme is the shared Material 3 roles', () {
    final scheme = AppTheme.light.colorScheme;
    final roles = at(['md', 'sys', 'color']);
    final expected = <String, Color>{
      'primary': scheme.primary,
      'on-primary': scheme.onPrimary,
      'primary-container': scheme.primaryContainer,
      'on-primary-container': scheme.onPrimaryContainer,
      'secondary': scheme.secondary,
      'on-secondary': scheme.onSecondary,
      'secondary-container': scheme.secondaryContainer,
      'on-secondary-container': scheme.onSecondaryContainer,
      'tertiary-container': scheme.tertiaryContainer,
      'on-tertiary-container': scheme.onTertiaryContainer,
      'surface': scheme.surface,
      'on-surface': scheme.onSurface,
      'surface-container-lowest': scheme.surfaceContainerLowest,
      'surface-container-low': scheme.surfaceContainerLow,
      'surface-container': scheme.surfaceContainer,
      'on-surface-variant': scheme.onSurfaceVariant,
      'outline': scheme.outline,
      'outline-variant': scheme.outlineVariant,
      'error': scheme.error,
      'on-error': scheme.onError,
      'error-container': scheme.errorContainer,
      'on-error-container': scheme.onErrorContainer,
      'inverse-surface': scheme.inverseSurface,
      'inverse-on-surface': scheme.onInverseSurface,
      'inverse-primary': scheme.inversePrimary,
      'scrim': scheme.scrim,
    };
    for (final MapEntry(:key, :value) in expected.entries) {
      expect(value, color(roles, key), reason: key);
    }
  });

  test('chart colours, shapes and state layers match', () {
    final chart = at(['raysto', 'chart']);
    final colors = RaystoChartColors.forBrightness(Brightness.light);
    for (var i = 0; i < 5; i++) {
      expect(colors.series[i], color(chart, '${i + 1}'), reason: 'chart ${i + 1}');
    }
    expect(colors.area, color(chart, 'fill'));
    expect(colors.sample, color(chart, 'sample'));

    final shape = at(['md', 'sys', 'shape']);
    double px(Map<String, dynamic> group, String name) => double.parse(
      ((group[name] as Map)[r'$value'] as String).replaceAll('px', ''),
    );
    expect(AppShape.extraSmall, px(shape, 'corner-extra-small'));
    expect(AppShape.small, px(shape, 'corner-small'));
    expect(AppShape.medium, px(shape, 'corner-medium'));
    expect(AppShape.large, px(shape, 'corner-large'));
    expect(AppShape.extraLarge, px(shape, 'corner-extra-large'));
    expect(AppShape.card, px(at(['raysto', 'shape']), 'card'));

    final state = at(['md', 'sys', 'state']);
    double number(String name) =>
        ((state[name] as Map)[r'$value'] as num).toDouble();
    expect(AppStateLayer.hover, number('hover'));
    expect(AppStateLayer.focus, number('focus'));
    expect(AppStateLayer.pressed, number('pressed'));
    expect(AppStateLayer.dragged, number('dragged'));
  });

  test('AppMotion uses the shared durations and Material 3 curves', () {
    final motion = at(['flutter', 'motion']);
    expect(AppMotion.feedback, duration(motion, 'feedback'));
    expect(AppMotion.selection, duration(motion, 'selection'));
    expect(AppMotion.branch, duration(motion, 'branch'));
    expect(AppMotion.sheet, duration(motion, 'sheet'));
    expect(AppMotion.sheetReverse, duration(motion, 'sheetReverse'));
    expect(AppMotion.milestone, duration(motion, 'milestone'));
    expect(AppMotion.dock, duration(motion, 'dock'));
    expect(AppMotion.reveal, duration(motion, 'reveal'));
    sameCurve(AppMotion.spatial, motion, 'spatial');
    sameCurve(AppMotion.effects, motion, 'effects');
    sameCurve(AppMotion.exit, motion, 'exit');

    final sys = at(['md', 'sys', 'motion']);
    sameCurve(Easing.emphasizedDecelerate, sys, 'easing-emphasized-decelerate');
    sameCurve(Easing.emphasizedAccelerate, sys, 'easing-emphasized-accelerate');
    sameCurve(Easing.standard, sys, 'easing-standard');
  });

  test('the entrance stagger stops at 0.36 of a reveal', () {
    expect(AppMotion.stagger(0), Duration.zero);
    expect(AppMotion.stagger(1), const Duration(milliseconds: 54));
    expect(AppMotion.stagger(4), const Duration(milliseconds: 216));
    expect(AppMotion.stagger(20), const Duration(milliseconds: 216));
  });
}
