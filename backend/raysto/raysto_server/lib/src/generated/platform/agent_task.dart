/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class AgentTask
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AgentTask._({
    this.id,
    required this.restaurantId,
    required this.agent,
    required this.trigger,
    this.triggerRef,
    this.requestedBy,
    required this.dedupeKey,
    required this.status,
    required this.title,
    this.summary,
    required this.inputJson,
    required this.stateJson,
    required this.traceJson,
    required this.feature,
    required this.reservedMicros,
    required this.chargedMicros,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory AgentTask({
    int? id,
    required int restaurantId,
    required String agent,
    required String trigger,
    String? triggerRef,
    String? requestedBy,
    required String dedupeKey,
    required String status,
    required String title,
    String? summary,
    required String inputJson,
    required String stateJson,
    required String traceJson,
    required String feature,
    required int reservedMicros,
    required int chargedMicros,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) = _AgentTaskImpl;

  factory AgentTask.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentTask(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      agent: jsonSerialization['agent'] as String,
      trigger: jsonSerialization['trigger'] as String,
      triggerRef: jsonSerialization['triggerRef'] as String?,
      requestedBy: jsonSerialization['requestedBy'] as String?,
      dedupeKey: jsonSerialization['dedupeKey'] as String,
      status: jsonSerialization['status'] as String,
      title: jsonSerialization['title'] as String,
      summary: jsonSerialization['summary'] as String?,
      inputJson: jsonSerialization['inputJson'] as String,
      stateJson: jsonSerialization['stateJson'] as String,
      traceJson: jsonSerialization['traceJson'] as String,
      feature: jsonSerialization['feature'] as String,
      reservedMicros: jsonSerialization['reservedMicros'] as int,
      chargedMicros: jsonSerialization['chargedMicros'] as int,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
    );
  }

  static final t = AgentTaskTable();

  static const db = AgentTaskRepository._();

  @override
  int? id;

  int restaurantId;

  String agent;

  String trigger;

  String? triggerRef;

  String? requestedBy;

  String dedupeKey;

  String status;

  String title;

  String? summary;

  String inputJson;

  String stateJson;

  String traceJson;

  String feature;

  int reservedMicros;

  int chargedMicros;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? completedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AgentTask]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentTask copyWith({
    int? id,
    int? restaurantId,
    String? agent,
    String? trigger,
    String? triggerRef,
    String? requestedBy,
    String? dedupeKey,
    String? status,
    String? title,
    String? summary,
    String? inputJson,
    String? stateJson,
    String? traceJson,
    String? feature,
    int? reservedMicros,
    int? chargedMicros,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentTask',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'agent': agent,
      'trigger': trigger,
      if (triggerRef != null) 'triggerRef': triggerRef,
      if (requestedBy != null) 'requestedBy': requestedBy,
      'dedupeKey': dedupeKey,
      'status': status,
      'title': title,
      if (summary != null) 'summary': summary,
      'inputJson': inputJson,
      'stateJson': stateJson,
      'traceJson': traceJson,
      'feature': feature,
      'reservedMicros': reservedMicros,
      'chargedMicros': chargedMicros,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AgentTaskInclude include() {
    return AgentTaskInclude._();
  }

  static AgentTaskIncludeList includeList({
    _is.WhereExpressionBuilder<AgentTaskTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentTaskTable>? orderBy,
    _is.OrderByListBuilder<AgentTaskTable>? orderByList,
    AgentTaskInclude? include,
  }) {
    return AgentTaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentTask.t),
      orderByList: orderByList?.call(AgentTask.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentTaskImpl extends AgentTask {
  _AgentTaskImpl({
    int? id,
    required int restaurantId,
    required String agent,
    required String trigger,
    String? triggerRef,
    String? requestedBy,
    required String dedupeKey,
    required String status,
    required String title,
    String? summary,
    required String inputJson,
    required String stateJson,
    required String traceJson,
    required String feature,
    required int reservedMicros,
    required int chargedMicros,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         agent: agent,
         trigger: trigger,
         triggerRef: triggerRef,
         requestedBy: requestedBy,
         dedupeKey: dedupeKey,
         status: status,
         title: title,
         summary: summary,
         inputJson: inputJson,
         stateJson: stateJson,
         traceJson: traceJson,
         feature: feature,
         reservedMicros: reservedMicros,
         chargedMicros: chargedMicros,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         completedAt: completedAt,
       );

  /// Returns a shallow copy of this [AgentTask]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentTask copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? agent,
    String? trigger,
    Object? triggerRef = _Undefined,
    Object? requestedBy = _Undefined,
    String? dedupeKey,
    String? status,
    String? title,
    Object? summary = _Undefined,
    String? inputJson,
    String? stateJson,
    String? traceJson,
    String? feature,
    int? reservedMicros,
    int? chargedMicros,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? completedAt = _Undefined,
  }) {
    return AgentTask(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      agent: agent ?? this.agent,
      trigger: trigger ?? this.trigger,
      triggerRef: triggerRef is String? ? triggerRef : this.triggerRef,
      requestedBy: requestedBy is String? ? requestedBy : this.requestedBy,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      status: status ?? this.status,
      title: title ?? this.title,
      summary: summary is String? ? summary : this.summary,
      inputJson: inputJson ?? this.inputJson,
      stateJson: stateJson ?? this.stateJson,
      traceJson: traceJson ?? this.traceJson,
      feature: feature ?? this.feature,
      reservedMicros: reservedMicros ?? this.reservedMicros,
      chargedMicros: chargedMicros ?? this.chargedMicros,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
    );
  }
}

class AgentTaskUpdateTable extends _is.UpdateTable<AgentTaskTable> {
  AgentTaskUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> agent(String value) => _is.ColumnValue(
    table.agent,
    value,
  );

  _is.ColumnValue<String, String> trigger(String value) => _is.ColumnValue(
    table.trigger,
    value,
  );

  _is.ColumnValue<String, String> triggerRef(String? value) => _is.ColumnValue(
    table.triggerRef,
    value,
  );

  _is.ColumnValue<String, String> requestedBy(String? value) => _is.ColumnValue(
    table.requestedBy,
    value,
  );

  _is.ColumnValue<String, String> dedupeKey(String value) => _is.ColumnValue(
    table.dedupeKey,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> summary(String? value) => _is.ColumnValue(
    table.summary,
    value,
  );

  _is.ColumnValue<String, String> inputJson(String value) => _is.ColumnValue(
    table.inputJson,
    value,
  );

  _is.ColumnValue<String, String> stateJson(String value) => _is.ColumnValue(
    table.stateJson,
    value,
  );

  _is.ColumnValue<String, String> traceJson(String value) => _is.ColumnValue(
    table.traceJson,
    value,
  );

  _is.ColumnValue<String, String> feature(String value) => _is.ColumnValue(
    table.feature,
    value,
  );

  _is.ColumnValue<int, int> reservedMicros(int value) => _is.ColumnValue(
    table.reservedMicros,
    value,
  );

  _is.ColumnValue<int, int> chargedMicros(int value) => _is.ColumnValue(
    table.chargedMicros,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );
}

class AgentTaskTable extends _is.Table<int?> {
  AgentTaskTable({super.tableRelation})
    : super(tableName: 'raysto_agent_task') {
    updateTable = AgentTaskUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    agent = _is.ColumnString(
      'agent',
      this,
    );
    trigger = _is.ColumnString(
      'trigger',
      this,
    );
    triggerRef = _is.ColumnString(
      'triggerRef',
      this,
    );
    requestedBy = _is.ColumnString(
      'requestedBy',
      this,
    );
    dedupeKey = _is.ColumnString(
      'dedupeKey',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    summary = _is.ColumnString(
      'summary',
      this,
    );
    inputJson = _is.ColumnString(
      'inputJson',
      this,
    );
    stateJson = _is.ColumnString(
      'stateJson',
      this,
    );
    traceJson = _is.ColumnString(
      'traceJson',
      this,
    );
    feature = _is.ColumnString(
      'feature',
      this,
    );
    reservedMicros = _is.ColumnInt(
      'reservedMicros',
      this,
    );
    chargedMicros = _is.ColumnInt(
      'chargedMicros',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
  }

  late final AgentTaskUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString agent;

  late final _is.ColumnString trigger;

  late final _is.ColumnString triggerRef;

  late final _is.ColumnString requestedBy;

  late final _is.ColumnString dedupeKey;

  late final _is.ColumnString status;

  late final _is.ColumnString title;

  late final _is.ColumnString summary;

  late final _is.ColumnString inputJson;

  late final _is.ColumnString stateJson;

  late final _is.ColumnString traceJson;

  late final _is.ColumnString feature;

  late final _is.ColumnInt reservedMicros;

  late final _is.ColumnInt chargedMicros;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime completedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    agent,
    trigger,
    triggerRef,
    requestedBy,
    dedupeKey,
    status,
    title,
    summary,
    inputJson,
    stateJson,
    traceJson,
    feature,
    reservedMicros,
    chargedMicros,
    version,
    createdAt,
    updatedAt,
    completedAt,
  ];
}

class AgentTaskInclude extends _is.IncludeObject {
  AgentTaskInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AgentTask.t;
}

class AgentTaskIncludeList extends _is.IncludeList {
  AgentTaskIncludeList._({
    _is.WhereExpressionBuilder<AgentTaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentTask.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AgentTask.t;
}

class AgentTaskRepository {
  const AgentTaskRepository._();

  /// Returns a list of [AgentTask]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<AgentTask>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentTaskTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentTaskTable>? orderBy,
    _is.OrderByListBuilder<AgentTaskTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentTask>(
      where: where?.call(AgentTask.t),
      orderBy: orderBy?.call(AgentTask.t),
      orderByList: orderByList?.call(AgentTask.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AgentTask] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<AgentTask?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentTaskTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentTaskTable>? orderBy,
    _is.OrderByListBuilder<AgentTaskTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentTask>(
      where: where?.call(AgentTask.t),
      orderBy: orderBy?.call(AgentTask.t),
      orderByList: orderByList?.call(AgentTask.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentTask] by its [id] or null if no such row exists.
  Future<AgentTask?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentTask>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentTask]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentTask]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentTask>> insert(
    _is.DatabaseSession session,
    List<AgentTask> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentTask>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentTask] and returns the inserted row.
  ///
  /// The returned [AgentTask] will have its `id` field set.
  Future<AgentTask> insertRow(
    _is.DatabaseSession session,
    AgentTask row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentTask>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentTask]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [AgentTask]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentTask>> upsert(
    _is.DatabaseSession session,
    List<AgentTask> rows, {
    required _is.ColumnSelections<AgentTaskTable> conflictColumns,
    _is.ColumnSelections<AgentTaskTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentTaskTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentTask>(
      rows,
      conflictColumns: conflictColumns(AgentTask.t),
      updateColumns: updateColumns?.call(AgentTask.t),
      updateWhere: updateWhere?.call(AgentTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentTask] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [AgentTask] will have its `id` field set.
  Future<AgentTask?> upsertRow(
    _is.DatabaseSession session,
    AgentTask row, {
    required _is.ColumnSelections<AgentTaskTable> conflictColumns,
    _is.ColumnSelections<AgentTaskTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentTaskTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentTask>(
      row,
      conflictColumns: conflictColumns(AgentTask.t),
      updateColumns: updateColumns?.call(AgentTask.t),
      updateWhere: updateWhere?.call(AgentTask.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentTask]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentTask>> update(
    _is.DatabaseSession session,
    List<AgentTask> rows, {
    _is.ColumnSelections<AgentTaskTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentTask>(
      rows,
      columns: columns?.call(AgentTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentTask]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentTask> updateRow(
    _is.DatabaseSession session,
    AgentTask row, {
    _is.ColumnSelections<AgentTaskTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentTask>(
      row,
      columns: columns?.call(AgentTask.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentTask] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentTask?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AgentTaskUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentTask>(
      id,
      columnValues: columnValues(AgentTask.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentTask]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentTask>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentTaskUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AgentTaskTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentTaskTable>? orderBy,
    _is.OrderByListBuilder<AgentTaskTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentTask>(
      columnValues: columnValues(AgentTask.t.updateTable),
      where: where(AgentTask.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentTask.t),
      orderByList: orderByList?.call(AgentTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentTask]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentTask>> delete(
    _is.DatabaseSession session,
    List<AgentTask> rows, {
    _is.OrderByBuilder<AgentTaskTable>? orderBy,
    _is.OrderByListBuilder<AgentTaskTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentTask>(
      rows,
      orderBy: orderBy?.call(AgentTask.t),
      orderByList: orderByList?.call(AgentTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentTask].
  Future<AgentTask> deleteRow(
    _is.DatabaseSession session,
    AgentTask row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentTask>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentTask>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentTaskTable> where,
    _is.OrderByBuilder<AgentTaskTable>? orderBy,
    _is.OrderByListBuilder<AgentTaskTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentTask>(
      where: where(AgentTask.t),
      orderBy: orderBy?.call(AgentTask.t),
      orderByList: orderByList?.call(AgentTask.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentTaskTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentTask>(
      where: where?.call(AgentTask.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentTask] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentTaskTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentTask>(
      where: where(AgentTask.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
