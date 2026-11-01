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

abstract class AgentAction
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AgentAction._({
    this.id,
    required this.restaurantId,
    required this.taskId,
    required this.agent,
    required this.ordinal,
    required this.command,
    required this.title,
    required this.rationale,
    required this.payloadJson,
    required this.previewJson,
    required this.evidenceJson,
    required this.risk,
    required this.contextHash,
    required this.status,
    this.approverUserId,
    this.executionKey,
    this.resultJson,
    this.errorCode,
    required this.version,
    required this.expiresAt,
    this.decidedAt,
    required this.createdAt,
  });

  factory AgentAction({
    int? id,
    required int restaurantId,
    required int taskId,
    required String agent,
    required int ordinal,
    required String command,
    required String title,
    required String rationale,
    required String payloadJson,
    required String previewJson,
    required String evidenceJson,
    required String risk,
    required String contextHash,
    required String status,
    String? approverUserId,
    String? executionKey,
    String? resultJson,
    String? errorCode,
    required int version,
    required DateTime expiresAt,
    DateTime? decidedAt,
    required DateTime createdAt,
  }) = _AgentActionImpl;

  factory AgentAction.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentAction(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      taskId: jsonSerialization['taskId'] as int,
      agent: jsonSerialization['agent'] as String,
      ordinal: jsonSerialization['ordinal'] as int,
      command: jsonSerialization['command'] as String,
      title: jsonSerialization['title'] as String,
      rationale: jsonSerialization['rationale'] as String,
      payloadJson: jsonSerialization['payloadJson'] as String,
      previewJson: jsonSerialization['previewJson'] as String,
      evidenceJson: jsonSerialization['evidenceJson'] as String,
      risk: jsonSerialization['risk'] as String,
      contextHash: jsonSerialization['contextHash'] as String,
      status: jsonSerialization['status'] as String,
      approverUserId: jsonSerialization['approverUserId'] as String?,
      executionKey: jsonSerialization['executionKey'] as String?,
      resultJson: jsonSerialization['resultJson'] as String?,
      errorCode: jsonSerialization['errorCode'] as String?,
      version: jsonSerialization['version'] as int,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      decidedAt: jsonSerialization['decidedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['decidedAt']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AgentActionTable();

  static const db = AgentActionRepository._();

  @override
  int? id;

  int restaurantId;

  int taskId;

  String agent;

  int ordinal;

  String command;

  String title;

  String rationale;

  String payloadJson;

  String previewJson;

  String evidenceJson;

  String risk;

  String contextHash;

  String status;

  String? approverUserId;

  String? executionKey;

  String? resultJson;

  String? errorCode;

  int version;

  DateTime expiresAt;

  DateTime? decidedAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AgentAction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentAction copyWith({
    int? id,
    int? restaurantId,
    int? taskId,
    String? agent,
    int? ordinal,
    String? command,
    String? title,
    String? rationale,
    String? payloadJson,
    String? previewJson,
    String? evidenceJson,
    String? risk,
    String? contextHash,
    String? status,
    String? approverUserId,
    String? executionKey,
    String? resultJson,
    String? errorCode,
    int? version,
    DateTime? expiresAt,
    DateTime? decidedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentAction',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'taskId': taskId,
      'agent': agent,
      'ordinal': ordinal,
      'command': command,
      'title': title,
      'rationale': rationale,
      'payloadJson': payloadJson,
      'previewJson': previewJson,
      'evidenceJson': evidenceJson,
      'risk': risk,
      'contextHash': contextHash,
      'status': status,
      if (approverUserId != null) 'approverUserId': approverUserId,
      if (executionKey != null) 'executionKey': executionKey,
      if (resultJson != null) 'resultJson': resultJson,
      if (errorCode != null) 'errorCode': errorCode,
      'version': version,
      'expiresAt': expiresAt.toJson(),
      if (decidedAt != null) 'decidedAt': decidedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AgentActionInclude include() {
    return AgentActionInclude._();
  }

  static AgentActionIncludeList includeList({
    _is.WhereExpressionBuilder<AgentActionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentActionTable>? orderBy,
    _is.OrderByListBuilder<AgentActionTable>? orderByList,
    AgentActionInclude? include,
  }) {
    return AgentActionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentAction.t),
      orderByList: orderByList?.call(AgentAction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentActionImpl extends AgentAction {
  _AgentActionImpl({
    int? id,
    required int restaurantId,
    required int taskId,
    required String agent,
    required int ordinal,
    required String command,
    required String title,
    required String rationale,
    required String payloadJson,
    required String previewJson,
    required String evidenceJson,
    required String risk,
    required String contextHash,
    required String status,
    String? approverUserId,
    String? executionKey,
    String? resultJson,
    String? errorCode,
    required int version,
    required DateTime expiresAt,
    DateTime? decidedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         taskId: taskId,
         agent: agent,
         ordinal: ordinal,
         command: command,
         title: title,
         rationale: rationale,
         payloadJson: payloadJson,
         previewJson: previewJson,
         evidenceJson: evidenceJson,
         risk: risk,
         contextHash: contextHash,
         status: status,
         approverUserId: approverUserId,
         executionKey: executionKey,
         resultJson: resultJson,
         errorCode: errorCode,
         version: version,
         expiresAt: expiresAt,
         decidedAt: decidedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AgentAction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentAction copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? taskId,
    String? agent,
    int? ordinal,
    String? command,
    String? title,
    String? rationale,
    String? payloadJson,
    String? previewJson,
    String? evidenceJson,
    String? risk,
    String? contextHash,
    String? status,
    Object? approverUserId = _Undefined,
    Object? executionKey = _Undefined,
    Object? resultJson = _Undefined,
    Object? errorCode = _Undefined,
    int? version,
    DateTime? expiresAt,
    Object? decidedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return AgentAction(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      taskId: taskId ?? this.taskId,
      agent: agent ?? this.agent,
      ordinal: ordinal ?? this.ordinal,
      command: command ?? this.command,
      title: title ?? this.title,
      rationale: rationale ?? this.rationale,
      payloadJson: payloadJson ?? this.payloadJson,
      previewJson: previewJson ?? this.previewJson,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      risk: risk ?? this.risk,
      contextHash: contextHash ?? this.contextHash,
      status: status ?? this.status,
      approverUserId: approverUserId is String?
          ? approverUserId
          : this.approverUserId,
      executionKey: executionKey is String? ? executionKey : this.executionKey,
      resultJson: resultJson is String? ? resultJson : this.resultJson,
      errorCode: errorCode is String? ? errorCode : this.errorCode,
      version: version ?? this.version,
      expiresAt: expiresAt ?? this.expiresAt,
      decidedAt: decidedAt is DateTime? ? decidedAt : this.decidedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AgentActionUpdateTable extends _is.UpdateTable<AgentActionTable> {
  AgentActionUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> taskId(int value) => _is.ColumnValue(
    table.taskId,
    value,
  );

  _is.ColumnValue<String, String> agent(String value) => _is.ColumnValue(
    table.agent,
    value,
  );

  _is.ColumnValue<int, int> ordinal(int value) => _is.ColumnValue(
    table.ordinal,
    value,
  );

  _is.ColumnValue<String, String> command(String value) => _is.ColumnValue(
    table.command,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> rationale(String value) => _is.ColumnValue(
    table.rationale,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<String, String> previewJson(String value) => _is.ColumnValue(
    table.previewJson,
    value,
  );

  _is.ColumnValue<String, String> evidenceJson(String value) => _is.ColumnValue(
    table.evidenceJson,
    value,
  );

  _is.ColumnValue<String, String> risk(String value) => _is.ColumnValue(
    table.risk,
    value,
  );

  _is.ColumnValue<String, String> contextHash(String value) => _is.ColumnValue(
    table.contextHash,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> approverUserId(String? value) =>
      _is.ColumnValue(
        table.approverUserId,
        value,
      );

  _is.ColumnValue<String, String> executionKey(String? value) =>
      _is.ColumnValue(
        table.executionKey,
        value,
      );

  _is.ColumnValue<String, String> resultJson(String? value) => _is.ColumnValue(
    table.resultJson,
    value,
  );

  _is.ColumnValue<String, String> errorCode(String? value) => _is.ColumnValue(
    table.errorCode,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> decidedAt(DateTime? value) =>
      _is.ColumnValue(
        table.decidedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AgentActionTable extends _is.Table<int?> {
  AgentActionTable({super.tableRelation})
    : super(tableName: 'raysto_agent_action') {
    updateTable = AgentActionUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
      this,
    );
    agent = _is.ColumnString(
      'agent',
      this,
    );
    ordinal = _is.ColumnInt(
      'ordinal',
      this,
    );
    command = _is.ColumnString(
      'command',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    rationale = _is.ColumnString(
      'rationale',
      this,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
    );
    previewJson = _is.ColumnString(
      'previewJson',
      this,
    );
    evidenceJson = _is.ColumnString(
      'evidenceJson',
      this,
    );
    risk = _is.ColumnString(
      'risk',
      this,
    );
    contextHash = _is.ColumnString(
      'contextHash',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    approverUserId = _is.ColumnString(
      'approverUserId',
      this,
    );
    executionKey = _is.ColumnString(
      'executionKey',
      this,
    );
    resultJson = _is.ColumnString(
      'resultJson',
      this,
    );
    errorCode = _is.ColumnString(
      'errorCode',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    decidedAt = _is.ColumnDateTime(
      'decidedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final AgentActionUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt taskId;

  late final _is.ColumnString agent;

  late final _is.ColumnInt ordinal;

  late final _is.ColumnString command;

  late final _is.ColumnString title;

  late final _is.ColumnString rationale;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnString previewJson;

  late final _is.ColumnString evidenceJson;

  late final _is.ColumnString risk;

  late final _is.ColumnString contextHash;

  late final _is.ColumnString status;

  late final _is.ColumnString approverUserId;

  late final _is.ColumnString executionKey;

  late final _is.ColumnString resultJson;

  late final _is.ColumnString errorCode;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime decidedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    taskId,
    agent,
    ordinal,
    command,
    title,
    rationale,
    payloadJson,
    previewJson,
    evidenceJson,
    risk,
    contextHash,
    status,
    approverUserId,
    executionKey,
    resultJson,
    errorCode,
    version,
    expiresAt,
    decidedAt,
    createdAt,
  ];
}

class AgentActionInclude extends _is.IncludeObject {
  AgentActionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AgentAction.t;
}

class AgentActionIncludeList extends _is.IncludeList {
  AgentActionIncludeList._({
    _is.WhereExpressionBuilder<AgentActionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentAction.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AgentAction.t;
}

class AgentActionRepository {
  const AgentActionRepository._();

  /// Returns a list of [AgentAction]s matching the given query parameters.
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
  Future<List<AgentAction>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentActionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentActionTable>? orderBy,
    _is.OrderByListBuilder<AgentActionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentAction>(
      where: where?.call(AgentAction.t),
      orderBy: orderBy?.call(AgentAction.t),
      orderByList: orderByList?.call(AgentAction.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AgentAction] matching the given query parameters.
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
  Future<AgentAction?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentActionTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentActionTable>? orderBy,
    _is.OrderByListBuilder<AgentActionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentAction>(
      where: where?.call(AgentAction.t),
      orderBy: orderBy?.call(AgentAction.t),
      orderByList: orderByList?.call(AgentAction.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentAction] by its [id] or null if no such row exists.
  Future<AgentAction?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentAction>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentAction]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentAction]s will have their `id` fields set.
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
  Future<List<AgentAction>> insert(
    _is.DatabaseSession session,
    List<AgentAction> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentAction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentAction] and returns the inserted row.
  ///
  /// The returned [AgentAction] will have its `id` field set.
  Future<AgentAction> insertRow(
    _is.DatabaseSession session,
    AgentAction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentAction>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentAction]s in the list and returns the resulting rows.
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
  /// The returned [AgentAction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentAction>> upsert(
    _is.DatabaseSession session,
    List<AgentAction> rows, {
    required _is.ColumnSelections<AgentActionTable> conflictColumns,
    _is.ColumnSelections<AgentActionTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentActionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentAction>(
      rows,
      conflictColumns: conflictColumns(AgentAction.t),
      updateColumns: updateColumns?.call(AgentAction.t),
      updateWhere: updateWhere?.call(AgentAction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentAction] and returns the resulting row.
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
  /// The returned [AgentAction] will have its `id` field set.
  Future<AgentAction?> upsertRow(
    _is.DatabaseSession session,
    AgentAction row, {
    required _is.ColumnSelections<AgentActionTable> conflictColumns,
    _is.ColumnSelections<AgentActionTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentActionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentAction>(
      row,
      conflictColumns: conflictColumns(AgentAction.t),
      updateColumns: updateColumns?.call(AgentAction.t),
      updateWhere: updateWhere?.call(AgentAction.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentAction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentAction>> update(
    _is.DatabaseSession session,
    List<AgentAction> rows, {
    _is.ColumnSelections<AgentActionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentAction>(
      rows,
      columns: columns?.call(AgentAction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentAction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentAction> updateRow(
    _is.DatabaseSession session,
    AgentAction row, {
    _is.ColumnSelections<AgentActionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentAction>(
      row,
      columns: columns?.call(AgentAction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentAction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentAction?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AgentActionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentAction>(
      id,
      columnValues: columnValues(AgentAction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentAction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentAction>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentActionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AgentActionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentActionTable>? orderBy,
    _is.OrderByListBuilder<AgentActionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentAction>(
      columnValues: columnValues(AgentAction.t.updateTable),
      where: where(AgentAction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentAction.t),
      orderByList: orderByList?.call(AgentAction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentAction]s in the list and returns the deleted rows.
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
  Future<List<AgentAction>> delete(
    _is.DatabaseSession session,
    List<AgentAction> rows, {
    _is.OrderByBuilder<AgentActionTable>? orderBy,
    _is.OrderByListBuilder<AgentActionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentAction>(
      rows,
      orderBy: orderBy?.call(AgentAction.t),
      orderByList: orderByList?.call(AgentAction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentAction].
  Future<AgentAction> deleteRow(
    _is.DatabaseSession session,
    AgentAction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentAction>(
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
  Future<List<AgentAction>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentActionTable> where,
    _is.OrderByBuilder<AgentActionTable>? orderBy,
    _is.OrderByListBuilder<AgentActionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentAction>(
      where: where(AgentAction.t),
      orderBy: orderBy?.call(AgentAction.t),
      orderByList: orderByList?.call(AgentAction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentActionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentAction>(
      where: where?.call(AgentAction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentAction] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentActionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentAction>(
      where: where(AgentAction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
