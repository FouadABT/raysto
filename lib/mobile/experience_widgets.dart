import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/app_localizations.dart';

/// Shared editorial surface for the customer and restaurant workspaces.
class ExperienceHero extends StatelessWidget {
  const ExperienceHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.restaurant_outlined,
  });
  final String eyebrow, title, message;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => RaystoStoryHeader(
    eyebrow: context.tr(eyebrow),
    title: context.tr(title),
    message: context.tr(message),
    action: action,
    dark: true,
    compact: true,
    scene: switch (icon) {
      Icons.menu_book_outlined || Icons.auto_awesome => RaystoScene.menu,
      Icons.delivery_dining || Icons.shopping_bag_outlined => RaystoScene.bag,
      Icons.restaurant_outlined => RaystoScene.kitchen,
      _ => RaystoScene.table,
    },
  );
}

class ExperienceAction extends StatelessWidget {
  const ExperienceAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => RaystoActionCard(
    title: context.tr(title),
    subtitle: context.tr(subtitle),
    icon: icon,
    onTap: onTap,
  );
}

class ExperienceMetrics extends StatelessWidget {
  const ExperienceMetrics({super.key, required this.values});
  final List<(String, String, IconData)> values;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final value in values)
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(1) > 1.4
                ? c.maxWidth
                : (c.maxWidth - 10 * (values.length - 1)) / values.length,
            child: AppPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(value.$3, size: 21),
                  const SizedBox(height: 12),
                  Text(
                    value.$1,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(value.$2),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
