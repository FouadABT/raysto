import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'motion.dart';
import 'tokens.dart';

/// A stable Material hit target with native ink and an inner-only press scale.
/// Layout, focus and semantics remain at their original size during a press.
class AppTapSurface extends StatelessWidget {
  const AppTapSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.label,
    this.color,
    this.padding,
  });

  final Widget child;
  final VoidCallback onTap;
  final String? label;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => _PressSurface(
    onTap: onTap,
    label: label,
    color: color ?? Theme.of(context).colorScheme.surfaceContainerLowest,
    padding: padding ?? const EdgeInsets.all(AppSpace.panel),
    radius: AppRadius.card,
    child: child,
  );
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.secondary = false,
    this.busy = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool busy;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final scheme = Theme.of(context).colorScheme;
    final foreground = secondary || !enabled
        ? scheme.onSurface
        : scheme.onPrimary;
    final content = _PressSurface(
      onTap: enabled ? onPressed : null,
      label: busy ? '$label, in progress' : label,
      color: secondary || !enabled ? scheme.surfaceContainer : scheme.primary,
      focusColor: secondary || !enabled ? scheme.primary : scheme.onPrimary,
      radius: AppRadius.button,
      scale: .96,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy) ...[
            if (AppMotion.reduced(context))
              Icon(PhosphorIconsRegular.hourglass, size: 20, color: foreground)
            else
              SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              ),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge!
                  .copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
    return expanded
        ? SizedBox(width: double.infinity, child: content)
        : content;
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    excludeFromSemantics: true,
    child: _PressSurface(
      onTap: onPressed,
      label: label,
      color: Theme.of(context).colorScheme.surfaceContainer,
      radius: AppRadius.pill,
      padding: const EdgeInsets.all(10),
      scale: .96,
      child: Icon(
        icon,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

class AppChoice extends StatelessWidget {
  const AppChoice({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _PressSurface(
    onTap: onTap,
    selected: selected,
    color: selected
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerLowest,
    borderColor: selected
        ? Theme.of(context).colorScheme.primary
        : Colors.transparent,
    radius: AppRadius.choice,
    padding: const EdgeInsets.all(AppSpace.content),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 23),
          ),
          const SizedBox(width: AppSpace.standard),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpace.standard),
        ExcludeSemantics(
          child: Icon(
            selected
                ? PhosphorIconsFill.checkCircle
                : PhosphorIconsRegular.circle,
            size: 24,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    ),
  );
}

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => _PressSurface(
    onTap: onSelected,
    label: label,
    selected: selected,
    color: selected
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.surfaceContainerLowest,
    borderColor: selected
        ? Theme.of(context).colorScheme.primary
        : Colors.transparent,
    radius: AppRadius.pill,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected) ...[
          const Icon(PhosphorIconsRegular.check, size: 16),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
      ],
    ),
  );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.error,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? error;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType:
        keyboardType ??
        (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
    textInputAction: maxLines > 1
        ? TextInputAction.newline
        : TextInputAction.done,
    textCapitalization: TextCapitalization.sentences,
    onChanged: onChanged,
    style: Theme.of(context).textTheme.bodyLarge,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      errorText: error,
      alignLabelWithHint: maxLines > 1,
    ),
  );
}

class _PressSurface extends StatefulWidget {
  const _PressSurface({
    required this.child,
    required this.onTap,
    required this.color,
    required this.padding,
    required this.radius,
    this.label,
    this.selected,
    this.scale = .98,
    this.borderColor = Colors.transparent,
    this.focusColor = AppColors.forest,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final String? label;
  final bool? selected;
  final double scale;
  final Color borderColor;
  final Color focusColor;

  @override
  State<_PressSurface> createState() => _PressSurfaceState();
}

class _PressSurfaceState extends State<_PressSurface> {
  bool _pressed = false;
  bool _focused = false;
  bool _activatedThisFrame = false;

  void _activate() {
    final callback = widget.onTap;
    if (callback == null || _activatedThisFrame) return;
    // State owners set busy synchronously. Close the small pre-rebuild window
    // too, so two pointer/semantic activations cannot submit the same action.
    _activatedThisFrame = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activatedThisFrame = false;
    });
    WidgetsBinding.instance.ensureVisualUpdate();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final radius = BorderRadius.circular(widget.radius);
    final feedbackColor = widget.color.computeLuminance() < .18
        ? AppColors.white
        : widget.focusColor;
    final content = Padding(padding: widget.padding, child: widget.child);
    final decoration = BoxDecoration(color: widget.color, borderRadius: radius);
    // Foreground borders do not reduce the native InkWell's hit region.
    final boundary = BoxDecoration(
      borderRadius: radius,
      border: Border.all(
        color: _focused ? feedbackColor : widget.borderColor,
        width: 2,
      ),
    );
    final ink = Material(
      type: MaterialType.transparency,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (reduced)
            content
          else
            AnimatedScale(
              scale: _pressed ? widget.scale : 1,
              duration: AppMotion.feedback,
              curve: AppMotion.spatial,
              child: content,
            ),
          // Ink paints over opaque media as well as text. The native hit area
          // fills the stable surface while only the content underneath scales.
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onTap == null ? null : _activate,
                excludeFromSemantics: true,
                borderRadius: radius,
                splashColor: feedbackColor.withValues(alpha: .16),
                highlightColor: feedbackColor.withValues(alpha: .1),
                hoverColor: feedbackColor.withValues(alpha: .06),
                focusColor: feedbackColor.withValues(alpha: .1),
                onHighlightChanged: (value) {
                  if (_pressed != value) setState(() => _pressed = value);
                },
                onFocusChange: (value) {
                  if (_focused != value) setState(() => _focused = value);
                },
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap == null ? null : _activate,
      child: ExcludeSemantics(
        excluding: widget.label != null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: reduced
              ? Container(
                  decoration: decoration,
                  foregroundDecoration: boundary,
                  child: ink,
                )
              : AnimatedContainer(
                  decoration: decoration,
                  foregroundDecoration: boundary,
                  duration: AppMotion.selection,
                  curve: AppMotion.effects,
                  child: ink,
                ),
        ),
      ),
    );
  }
}
