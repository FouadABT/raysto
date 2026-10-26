import 'package:flutter/material.dart';

import '../../backend/platform_api.dart';
import '../../design_system/design_system.dart';

String friendly(String key) => key
    .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
    .replaceAll('.', ' ')
    .replaceAll('_', ' ');

class InputSpec {
  const InputSpec(
    this.key,
    this.label, {
    this.kind = 'text',
    this.options,
    this.children,
    this.optional = false,
    this.value,
    this.help,
  });
  final String key, label, kind;
  final List<String>? options;
  final List<InputSpec>? children;
  final bool optional;
  final dynamic value;
  final String? help;
}

Future<RecordData?> editFields(
  BuildContext context,
  String title,
  List<InputSpec> fields, {
  RecordData initial = const {},
  Future<RecordData> Function(RecordData)? save,
  String submit = 'Save',
}) => Navigator.of(context).push<RecordData>(
  MaterialPageRoute(
    builder: (_) => RecordEditor(
      title: title,
      fields: fields,
      initial: initial,
      save: save,
      submit: submit,
    ),
  ),
);

class RecordEditor extends StatefulWidget {
  const RecordEditor({
    super.key,
    required this.title,
    required this.fields,
    required this.initial,
    this.save,
    required this.submit,
  });
  final String title, submit;
  final List<InputSpec> fields;
  final RecordData initial;
  final Future<RecordData> Function(RecordData)? save;
  @override
  State<RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends State<RecordEditor> {
  final _form = GlobalKey<FormState>();
  late RecordData values;
  bool busy = false, dirty = false, completed = false;
  String? error;
  @override
  void initState() {
    super.initState();
    values = {...widget.initial};
    for (final f in widget.fields) {
      if (!values.containsKey(f.key) && f.value != null) {
        values[f.key] = f.value;
      }
    }
  }

  Future<void> discard() async {
    if (busy) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      setState(() => completed = true);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> save() async {
    if (busy || !_form.currentState!.validate()) return;
    _form.currentState!.save();
    for (final field in widget.fields) {
      if (!field.optional &&
          field.kind == 'object' &&
          values[field.key] == null) {
        setState(
          () => error = 'Complete ${field.label.toLowerCase()} before saving.',
        );
        return;
      }
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final input = <String, dynamic>{};
      for (final f in widget.fields) {
        final value = values[f.key];
        if (value != null &&
            !(f.optional && value is String && value.trim().isEmpty)) {
          input[f.key] = value;
        }
      }
      final result = widget.save == null ? input : await widget.save!(input);
      if (mounted) {
        setState(() => completed = true);
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is PlatformFailure
              ? e.message
              : 'Unable to save. Please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(InputSpec f) {
    final current = values[f.key];
    if (f.kind == 'bool') {
      return SwitchListTile.adaptive(
        title: Text(f.label),
        subtitle: f.help == null ? null : Text(f.help!),
        value: current == true,
        onChanged: busy
            ? null
            : (v) => setState(() {
                values[f.key] = v;
                dirty = true;
              }),
      );
    }
    if (f.kind == 'object' || f.kind == 'list') {
      final list = f.kind == 'list'
          ? List<dynamic>.from(current as List? ?? [])
          : null;
      return AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(f.label, style: Theme.of(context).textTheme.titleMedium),
            if (f.help != null) Text(f.help!),
            if (list != null)
              for (var i = 0; i < list.length; i++)
                ListTile(
                  title: Text(
                    list[i] is Map
                        ? '${list[i]['name'] ?? list[i]['label'] ?? '${f.label} ${i + 1}'}'
                        : '${list[i]}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            list.removeAt(i);
                            values[f.key] = list;
                            dirty = true;
                          }),
                  ),
                  onTap: busy || f.children == null
                      ? null
                      : () async {
                          final v = await editFields(
                            context,
                            f.label,
                            f.children!,
                            initial: Map<String, dynamic>.from(list[i] as Map),
                          );
                          if (v != null && mounted) {
                            setState(() {
                              list[i] = v;
                              values[f.key] = list;
                              dirty = true;
                            });
                          }
                        },
                ),
            TextButton.icon(
              icon: Icon(list == null ? Icons.edit_outlined : Icons.add),
              label: Text(
                list == null
                    ? (current == null ? 'Add details' : 'Edit details')
                    : 'Add',
              ),
              onPressed: busy
                  ? null
                  : () async {
                      final fields =
                          f.children ?? [const InputSpec('value', 'Value')];
                      final v = await editFields(
                        context,
                        f.label,
                        fields,
                        initial: list == null && current is Map
                            ? Map<String, dynamic>.from(current)
                            : {},
                      );
                      if (v != null && mounted) {
                        setState(() {
                          values[f.key] = list == null
                              ? v
                              : [...list, f.children == null ? v['value'] : v];
                          dirty = true;
                        });
                      }
                    },
            ),
            if (current == null && !f.optional)
              const Text('Complete these details before saving.'),
          ],
        ),
      );
    }
    if (f.options != null) {
      return DropdownButtonFormField<String>(
        initialValue: f.options!.contains(current) ? current as String : null,
        isExpanded: true,
        decoration: InputDecoration(labelText: f.label, helperText: f.help),
        items: [
          for (final v in f.options!)
            DropdownMenuItem(value: v, child: Text(friendly(v))),
        ],
        onChanged: busy
            ? null
            : (v) {
                values[f.key] = v;
                dirty = true;
              },
        validator: (v) => !f.optional && v == null ? 'Choose an option' : null,
      );
    }
    if (f.kind == 'date') {
      return FormField<DateTime>(
        initialValue: current is String ? DateTime.tryParse(current) : null,
        validator: (_) => !f.optional && values[f.key] == null
            ? 'Choose a date and time'
            : null,
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(f.label),
              subtitle: Text(
                values[f.key] == null
                    ? 'Choose date and time'
                    : DateTime.parse(values[f.key]).toLocal().toString(),
              ),
              trailing: const Icon(Icons.event),
              onTap: busy
                  ? null
                  : () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: now.add(const Duration(days: 1)),
                        firstDate: now.subtract(const Duration(days: 93)),
                        lastDate: now.add(const Duration(days: 366)),
                      );
                      if (date == null || !mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null && mounted) {
                        setState(() {
                          values[f.key] = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ).toUtc().toIso8601String();
                          dirty = true;
                        });
                      }
                    },
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      );
    }
    return TextFormField(
      initialValue: current == null
          ? ''
          : f.kind == 'strings'
          ? (current as List).join(', ')
          : f.kind == 'money'
          ? ((current as num) / 100).toStringAsFixed(2)
          : '$current',
      enabled: !busy,
      maxLines: f.kind == 'long' ? 4 : 1,
      obscureText: f.kind == 'password',
      autocorrect: f.kind != 'password',
      keyboardType: {'int', 'decimal', 'money'}.contains(f.kind)
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: f.label,
        helperText: f.help,
        helperMaxLines: 3,
      ),
      onChanged: (_) => dirty = true,
      validator: (v) {
        if ((v?.trim().isEmpty ?? true)) return f.optional ? null : 'Required';
        if (f.kind == 'int' && int.tryParse(v!) == null) {
          return 'Enter a whole number';
        }
        if ({'decimal', 'money'}.contains(f.kind) &&
            (double.tryParse(v!)?.isFinite != true)) {
          return 'Enter a valid amount';
        }
        return null;
      },
      onSaved: (v) {
        if (v == null || v.trim().isEmpty) {
          if (f.optional) values.remove(f.key);
          return;
        }
        values[f.key] = switch (f.kind) {
          'int' => int.parse(v),
          'decimal' => double.parse(v),
          'money' => (double.parse(v) * 100).round(),
          'strings' =>
            v
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          _ => v.trim(),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: completed || !dirty && !busy,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) discard();
    },
    child: Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final f in widget.fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: field(f),
                ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              AppButton(label: widget.submit, busy: busy, onPressed: save),
            ],
          ),
        ),
      ),
    ),
  );
}

class RecordSummary extends StatelessWidget {
  const RecordSummary(this.data, {super.key});
  final RecordData data;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final e in data.entries)
        if (e.value != null &&
            !{
              'rows',
              'nextCursor',
              'approvalUrl',
              'settings',
              'menu',
              'definition',
              'snapshot',
              'profile',
            }.contains(e.key))
          if (e.value is Map)
            ExpansionTile(
              title: Text(friendly(e.key)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: RecordSummary(
                    Map<String, dynamic>.from(e.value as Map),
                  ),
                ),
              ],
            )
          else if (e.value is List)
            ExpansionTile(
              title: Text(friendly(e.key)),
              children: [
                for (final value in e.value as List)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: value is Map
                        ? RecordSummary(Map<String, dynamic>.from(value))
                        : Text('$value'),
                  ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                children: [
                  Text(
                    friendly(e.key),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SelectableText(
                    e.key.endsWith('Minor') && e.value is num
                        ? '${((e.value as num) / 100).toStringAsFixed(2)} ${data['currency'] ?? ''}'
                        : '${e.value}',
                  ),
                ],
              ),
            ),
    ],
  );
}
