part of 'platform.dart';

/// Saved AG Studio layouts, one per scope (`venue:{id}` or `group:{id}`),
/// person and console section. Only owners save: a venue's owner, or the
/// group's owner. Anyone who may read the scope may load the layout.
class StudioLayoutModule {
  static const sections = {
    'finance',
    'overview',
    'group',
    'accountant',
    'supplies',
    'dispatch',
    'money',
    'floor',
  };

  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {'studio.layout.save': save};

  static Future<Json> save(Session s, PlatformCommand c) =>
      _mutate(s, c, 'studio.layout.save', (w, d) async {
        _keys(d, {'scope', 'section', 'state'});
        final scope = _scope(_str(d, 'scope', max: 40));
        final section = _str(d, 'section', choices: sections);
        await _owns(w, scope);
        final state = jsonEncode(_object(d['state']));
        if (state.length > 120000) {
          _fail('invalid_input', 'This layout is too large to save.');
        }
        var row = await StudioLayout.db.findFirstRow(
          s,
          where: (t) =>
              t.scope.equals(scope.key) &
              t.userId.equals(w.user) &
              t.section.equals(section),
          transaction: w.tx,
          lockMode: LockMode.forUpdate,
        );
        if (row == null) {
          row = await StudioLayout.db.insertRow(
            s,
            StudioLayout(
              scope: scope.key,
              userId: w.user,
              section: section,
              stateJson: state,
              version: 1,
              updatedAt: _now(),
            ),
            transaction: w.tx,
          );
        } else {
          if (c.expectedVersion != null) _version(row.version, c.expectedVersion);
          row
            ..stateJson = state
            ..version += 1
            ..updatedAt = _now();
          await StudioLayout.db.updateRow(s, row, transaction: w.tx);
        }
        return {'scope': scope.key, 'section': section, 'version': row.version};
      }, registered: true);

  /// Only owners save layouts; a judges' café manager never does.
  static Future<void> _owns(Work w, _Scope scope) async {
    if (scope.kind == 'venue') {
      await _role(w.s, w.user, scope.id, {'owner'}, tx: w.tx);
    } else {
      await GroupModule._groupRole(w, scope.id, {'owner'});
    }
  }

  static Future<void> _reads(Work w, _Scope scope) async {
    if (scope.kind == 'venue') {
      await _role(w.s, w.user, scope.id, {..._managers, ..._finance}, tx: w.tx);
    } else {
      await GroupModule._groupRole(w, scope.id, GroupModule.roles);
    }
  }

  static _Scope _scope(String raw) {
    final m = RegExp(r'^(venue|group):([1-9]\d{0,9})$').firstMatch(raw);
    if (m == null) _fail('invalid_input', 'Invalid scope.');
    return _Scope(m.group(1)!, int.parse(m.group(2)!));
  }

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async {
    if (name != 'studio.layout') return null;
    final scope = _scope(_str(d, 'scope', max: 40));
    final section = _str(d, 'section', choices: sections);
    await _reads(w, scope);
    final row = await StudioLayout.db.findFirstRow(
      w.s,
      where: (t) =>
          t.scope.equals(scope.key) &
          t.userId.equals(w.user) &
          t.section.equals(section),
      transaction: w.tx,
    );
    return {
      'scope': scope.key,
      'section': section,
      'state': row == null ? null : jsonDecode(row.stateJson),
      'version': row?.version,
    };
  }
}

class _Scope {
  _Scope(this.kind, this.id);
  final String kind;
  final int id;
  String get key => '$kind:$id';
}
