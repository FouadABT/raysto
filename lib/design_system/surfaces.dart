import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'controls.dart';
import 'motion.dart';
import 'tokens.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.child, this.color, this.padding});

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Theme.of(context).colorScheme.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(AppRadius.card),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: padding ?? const EdgeInsets.all(AppSpace.panel),
      child: child,
    ),
  );
}

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
    if (trailing == null) return heading;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 8), trailing!],
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: 12),
            Flexible(child: trailing!),
          ],
        );
      },
    );
  }
}

class AppEyebrow extends StatelessWidget {
  const AppEyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppType.style(
      11,
      weight: FontWeight.w700,
      height: 1.5,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      tracking: 1.8,
    ),
  );
}

/// Noninteractive metadata. Choices should use [AppChip] instead.
class AppPill extends StatelessWidget {
  const AppPill({super.key, required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            ExcludeSemantics(child: Icon(icon, size: 15)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    ),
  );
}

class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.color,
    this.action,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Color? color;
  final Widget? action;

  @override
  Widget build(BuildContext context) => AppPanel(
    color: color ?? Theme.of(context).colorScheme.tertiaryContainer,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon ?? PhosphorIconsRegular.info, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (message != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (action != null) ...[const SizedBox(height: 14), action!],
      ],
    ),
  );
}

class AppDisclosure extends StatefulWidget {
  const AppDisclosure({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  State<AppDisclosure> createState() => _AppDisclosureState();
}

class _AppDisclosureState extends State<AppDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final arrow = Icon(
      reduced && _expanded
          ? PhosphorIconsRegular.caretUp
          : PhosphorIconsRegular.caretDown,
      size: 20,
    );
    final details = _expanded
        ? Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: widget.child,
          )
        : const SizedBox(width: double.infinity);
    return AppPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _expanded,
            child: AppTapSurface(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ExcludeSemantics(
                    child: reduced
                        ? arrow
                        : AnimatedRotation(
                            turns: _expanded ? .5 : 0,
                            duration: AppMotion.selection,
                            curve: AppMotion.spatial,
                            child: arrow,
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Collapsed children are removed immediately, including focus and
          // semantics. Only the surrounding size is animated during collapse.
          if (reduced)
            details
          else
            AnimatedSize(
              duration: AppMotion.selection,
              curve: AppMotion.spatial,
              alignment: Alignment.topCenter,
              child: details,
            ),
        ],
      ),
    );
  }
}

class AppProgress extends StatelessWidget {
  const AppProgress({super.key, required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final actual = value.clamp(0.0, 1.0);
    Widget track(double progress) => ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
    return Semantics(
      label: label,
      value: '${(actual * 100).round()} percent',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 10),
            if (AppMotion.reduced(context))
              track(actual)
            else
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: actual, end: actual),
                duration: AppMotion.milestone,
                curve: AppMotion.spatial,
                builder: (context, progress, child) => track(progress),
              ),
          ],
        ),
      ),
    );
  }
}

/// Stable image area with a decode fade, honest fallback and meaningful label.
class AppMedia extends StatelessWidget {
  const AppMedia({
    super.key,
    required this.asset,
    required this.semanticLabel,
    this.height = 180,
  });

  final String asset;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppRadius.media),
    child: SizedBox(
      width: double.infinity,
      height: height,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
          frameBuilder: (context, child, frame, synchronouslyLoaded) {
            if (synchronouslyLoaded || AppMotion.reduced(context)) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: AppMotion.selection,
              curve: AppMotion.effects,
              child: child,
            );
          },
          errorBuilder: (context, error, stack) => Semantics(
            label: '$semanticLabel. Image unavailable.',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsRegular.image, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Image unavailable',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required Widget child,
  bool enableDrag = true,
}) {
  final reduced = AppMotion.reduced(context);
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    enableDrag: enableDrag,
    requestFocus: true,
    showDragHandle: false,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .88,
    ),
    sheetAnimationStyle: reduced
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: AppMotion.sheet,
            reverseDuration: AppMotion.sheetReverse,
          ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppIconButton(
                      label: 'Close sheet',
                      icon: PhosphorIconsRegular.x,
                      onPressed: () => Navigator.of(sheetContext).maybePop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
