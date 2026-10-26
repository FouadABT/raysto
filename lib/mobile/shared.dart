import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../design_system/design_system.dart';
import '../l10n/app_localizations.dart';

final _openPages = Expando<Map<Route<dynamic>?, Set<Type>>>(
  'open mobile detail routes by origin',
);
Future<T?> openPage<T>(BuildContext context, Widget page) async {
  final navigator = Navigator.of(context);
  final origin = ModalRoute.of(context);
  final origins = _openPages[navigator] ??= <Route<dynamic>?, Set<Type>>{};
  final pending = origins[origin] ??= <Type>{};
  if (!pending.add(page.runtimeType)) return null;
  try {
    return await navigator.push<T>(MaterialPageRoute(builder: (_) => page));
  } finally {
    pending.remove(page.runtimeType);
    if (pending.isEmpty) origins.remove(origin);
  }
}

Future<bool> confirmAction(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(context.tr(title)),
        content: Text(context.tr(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('Confirm')),
          ),
        ],
      ),
    ) ??
    false;

void showMessage(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.tr(message)), action: action));
}

Future<void> guarded(
  BuildContext context,
  FutureOr<dynamic> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) {
      showMessage(
        context,
        error.toString().replaceFirst('DomainException: ', ''),
      );
    }
  }
}

class MobilePage extends StatelessWidget {
  const MobilePage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.bottom,
    this.embedded = false,
  });
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool embedded;
  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: children
          .expand((child) => [child, const SizedBox(height: 16)])
          .toList(),
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(title)), actions: actions),
      body: body,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              top: false,
              minimum: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: bottom!,
            ),
    );
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });
  final String title;
  final Widget child;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSectionTitle(
        title: context.tr(title),
        subtitle: subtitle == null ? null : context.tr(subtitle!),
      ),
      const SizedBox(height: 12),
      child,
    ],
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.icon = Icons.circle_outlined});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final child = AppPill(label: context.tr(label), icon: icon);
    if (AppMotion.reduced(context)) return child;
    return AnimatedSize(
      duration: AppMotion.selection,
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.ramen_dining_outlined,
  });
  final String title, message;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => RaystoEmptyState(
    title: context.tr(title),
    message: context.tr(message),
    action: action,
    scene: switch (icon) {
      Icons.shopping_bag_outlined ||
      Icons.shopping_cart_outlined => RaystoScene.bag,
      Icons.receipt_long_outlined => RaystoScene.receipt,
      Icons.favorite_border || Icons.bookmark_border => RaystoScene.sprout,
      Icons.menu_book_outlined => RaystoScene.menu,
      _ => RaystoScene.table,
    },
  );
}

String money(BuildContext context, int minor, {String currency = 'EUR'}) =>
    NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).languageCode,
      name: currency,
    ).format(minor / 100);

class MoneyText extends StatelessWidget {
  const MoneyText(
    this.minor, {
    super.key,
    this.currency = 'EUR',
    this.large = false,
  });
  final int minor;
  final String currency;
  final bool large;
  @override
  Widget build(BuildContext context) => Text(
    money(context, minor, currency: currency),
    textDirection: TextDirection.ltr,
    style: large
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.titleSmall,
  );
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: context.tr('Decrease quantity'),
        onPressed: value > min ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove_circle_outline),
      ),
      Semantics(
        liveRegion: true,
        label: '${context.tr('Quantity')} $value',
        child: ExcludeSemantics(
          child: AnimatedSwitcher(
            duration: AppMotion.duration(context, AppMotion.feedback),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
      IconButton(
        tooltip: context.tr('Increase quantity'),
        onPressed: value < max ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add_circle_outline),
      ),
    ],
  );
}

class PriceRow extends StatelessWidget {
  const PriceRow(this.label, this.amount, {super.key, this.total = false});
  final String label;
  final int amount;
  final bool total;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        Text(
          context.tr(label),
          style: total ? Theme.of(context).textTheme.titleMedium : null,
        ),
        MoneyText(amount, large: total),
      ],
    ),
  );
}

class DraftGuard extends StatefulWidget {
  const DraftGuard({super.key, required this.dirty, required this.child});
  final bool dirty;
  final Widget child;
  @override
  State<DraftGuard> createState() => _DraftGuardState();
}

class _DraftGuardState extends State<DraftGuard> {
  bool _leaving = false, _asking = false;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.dirty || _leaving,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop || _asking) return;
      _asking = true;
      final discard = await confirmAction(
        context,
        'Discard changes?',
        'Your unsaved changes will be lost.',
      );
      _asking = false;
      if (discard && mounted) {
        setState(() => _leaving = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    },
    child: widget.child,
  );
}

class SchematicMap extends StatelessWidget {
  const SchematicMap({
    super.key,
    this.label = 'Simulated area · Central district',
  });
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 150,
        width: double.infinity,
        child: CustomPaint(
          painter: _MapPainter(Theme.of(context).colorScheme),
          child: Center(
            child: Icon(
              Icons.location_on,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      Text(context.tr(label), style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.colors);
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      Paint()..color = colors.surfaceContainer,
    );
    final paint = Paint()
      ..color = colors.surface
      ..strokeWidth = 12;
    for (double x = 30; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x + 35, size.height), paint);
    }
    for (double y = 25; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 10), paint);
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => oldDelegate.colors != colors;
}
