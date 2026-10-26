part of 'operations.dart';

String _money(BuildContext context, int minor) => NumberFormat.currency(
  locale: Localizations.localeOf(context).toLanguageTag(),
  symbol: '€',
  decimalDigits: 2,
).format(minor / 100);
bool _paid(DemoStore store, Order order) =>
    store.orderPaid(order.id) >= order.totalMinor;
String _uniqueId(String prefix, Iterable<String> existing) {
  final ids = existing.toSet();
  var number = ids.length + 1;
  while (ids.contains('$prefix-$number')) {
    number++;
  }
  return '$prefix-$number';
}

String _words(Enum value) => value.name.replaceAllMapped(
  RegExp(r'[A-Z]'),
  (m) => ' ${m[0]!.toLowerCase()}',
);
String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
bool _manager(DemoStore s) =>
    [DemoRole.owner, DemoRole.manager].contains(s.currentAccount.role);
bool _owner(DemoStore s) => s.currentAccount.role == DemoRole.owner;

Future<bool> _confirm(
  BuildContext context,
  String title,
  String message, {
  String action = 'Confirm',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr(title)),
        content: Text(context.tr(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr(action)),
          ),
        ],
      ),
    ) ??
    false;

void _act(BuildContext context, VoidCallback action) {
  try {
    action();
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error is DomainException ? error.message : error.toString(),
        ),
      ),
    );
  }
}

Future<String?> _ask(
  BuildContext context,
  String title, {
  String label = 'Reason',
  String initial = '',
  bool required = true,
}) async {
  final controller = TextEditingController(text: initial);
  final key = GlobalKey<FormState>();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.tr(title)),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: context.tr(label)),
          validator: (v) => required && (v?.trim().isEmpty ?? true)
              ? context.tr('Enter a value')
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (key.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: Text(context.tr('Save')),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

class _List extends StatelessWidget {
  const _List({required this.children, this.storageKey});
  final List<Widget> children;
  final String? storageKey;
  @override
  Widget build(BuildContext context) => ListView.separated(
    key: storageKey == null ? null : PageStorageKey(storageKey),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    itemCount: children.length,
    itemBuilder: (context, index) => children[index],
    separatorBuilder: (_, index) => const SizedBox(height: 16),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap, this.tonal = false});
  final Widget child;
  final VoidCallback? onTap;
  final bool tonal;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: tonal ? colors.secondaryContainer : colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: const EdgeInsets.all(16), child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title, {this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          context.tr(title),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(
          context.tr(subtitle!),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.label, {
    this.icon = Icons.circle_outlined,
    this.attention = false,
  });
  final String label;
  final IconData icon;
  final bool attention;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: attention ? c.tertiaryContainer : c.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: attention ? c.onTertiaryContainer : c.onSurface,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                context.tr(label),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: attention ? c.onTertiaryContainer : c.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.action,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link(this.title, this.subtitle, this.icon, this.onTap);
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => _Card(
    onTap: onTap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(title),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(context.tr(subtitle)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: LayoutBuilder(
      builder: (context, c) {
        if (MediaQuery.textScalerOf(context).scale(1) > 1.4) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(label),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                context.tr(value),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(context.tr(label))),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                context.tr(value),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// A form route owns a draft. Native back and the app bar both ask before loss.
class _DraftGuard extends StatefulWidget {
  const _DraftGuard({required this.dirty, required this.child});
  final bool dirty;
  final Widget child;
  @override
  State<_DraftGuard> createState() => _DraftGuardState();
}

class _DraftGuardState extends State<_DraftGuard> {
  bool confirming = false;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.dirty,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || !widget.dirty || confirming) return;
      confirming = true;
      if (await _confirm(
            context,
            'Discard changes?',
            'Your saved information will stay unchanged.',
            action: 'Discard',
          ) &&
          context.mounted) {
        Navigator.of(context).pop();
      }
      confirming = false;
    },
    child: widget.child,
  );
}

/// Tracks text held by a sheet while retaining the original values across its
/// local rebuilds. The sheet's explicit Save/Cancel commands own dismissal.
class _InputDraft extends StatefulWidget {
  const _InputDraft({
    required this.controllers,
    required this.child,
    this.changed = false,
  });
  final List<TextEditingController> controllers;
  final Widget child;
  final bool changed;
  @override
  State<_InputDraft> createState() => _InputDraftState();
}

class _InputDraftState extends State<_InputDraft> {
  late final original = widget.controllers.map((c) => c.text).toList();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge(widget.controllers),
    builder: (context, _) => _DraftGuard(
      dirty:
          widget.changed ||
          List.generate(
            widget.controllers.length,
            (i) => widget.controllers[i].text != original[i],
          ).any((v) => v),
      child: widget.child,
    ),
  );
}

Widget _field(
  BuildContext context,
  String label,
  TextEditingController controller, {
  int lines = 1,
  TextInputType? type,
  String? Function(String?)? validator,
}) => TextFormField(
  controller: controller,
  maxLines: lines,
  keyboardType: type,
  decoration: InputDecoration(labelText: context.tr(label)),
  validator:
      validator ??
      (v) => (v?.trim().isEmpty ?? true) ? context.tr('Enter a value') : null,
);
