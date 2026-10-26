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

abstract class AssistantRun
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AssistantRun._({
    this.id,
    required this.restaurantId,
    this.roomId,
    required this.userId,
    required this.requestKey,
    required this.status,
    required this.inputJson,
    required this.outputJson,
    required this.traceJson,
    required this.reservedMicros,
    required this.chargedMicros,
    required this.budgetStage,
    required this.version,
    required this.createdAt,
    this.completedAt,
  });

  factory AssistantRun({
    int? id,
    required int restaurantId,
    int? roomId,
    required String userId,
    required String requestKey,
    required String status,
    required String inputJson,
    required String outputJson,
    required String traceJson,
    required int reservedMicros,
    required int chargedMicros,
    required String budgetStage,
    required int version,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _AssistantRunImpl;

  factory AssistantRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantRun(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      roomId: jsonSerialization['roomId'] as int?,
      userId: jsonSerialization['userId'] as String,
      requestKey: jsonSerialization['requestKey'] as String,
      status: jsonSerialization['status'] as String,
      inputJson: jsonSerialization['inputJson'] as String,
      outputJson: jsonSerialization['outputJson'] as String,
      traceJson: jsonSerialization['traceJson'] as String,
      reservedMicros: jsonSerialization['reservedMicros'] as int,
      chargedMicros: jsonSerialization['chargedMicros'] as int,
      budgetStage: jsonSerialization['budgetStage'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
    );
  }

  static final t = AssistantRunTable();

  static const db = AssistantRunRepository._();

  @override
  int? id;

  int restaurantId;

  int? roomId;

  String userId;

  String requestKey;

  String status;

  String inputJson;

  String outputJson;

  String traceJson;

  int reservedMicros;

  int chargedMicros;

  String budgetStage;

  int version;

  DateTime createdAt;

  DateTime? completedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AssistantRun]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantRun copyWith({
    int? id,
    int? restaurantId,
    int? roomId,
    String? userId,
    String? requestKey,
    String? status,
    String? inputJson,
    String? outputJson,
    String? traceJson,
    int? reservedMicros,
    int? chargedMicros,
    String? budgetStage,
    int? version,
    DateTime? createdAt,
    DateTime? completedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantRun',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      if (roomId != null) 'roomId': roomId,
      'userId': userId,
      'requestKey': requestKey,
      'status': status,
      'inputJson': inputJson,
      'outputJson': outputJson,
      'traceJson': traceJson,
      'reservedMicros': reservedMicros,
      'chargedMicros': chargedMicros,
      'budgetStage': budgetStage,
      'version': version,
      'createdAt': createdAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AssistantRunInclude include() {
    return AssistantRunInclude._();
  }

  static AssistantRunIncludeList includeList({
    _is.WhereExpressionBuilder<AssistantRunTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantRunTable>? orderBy,
    _is.OrderByListBuilder<AssistantRunTable>? orderByList,
    AssistantRunInclude? include,
  }) {
    return AssistantRunIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantRun.t),
      orderByList: orderByList?.call(AssistantRun.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantRunImpl extends AssistantRun {
  _AssistantRunImpl({
    int? id,
    required int restaurantId,
    int? roomId,
    required String userId,
    required String requestKey,
    required String status,
    required String inputJson,
    required String outputJson,
    required String traceJson,
    required int reservedMicros,
    required int chargedMicros,
    required String budgetStage,
    required int version,
    required DateTime createdAt,
    DateTime? completedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         roomId: roomId,
         userId: userId,
         requestKey: requestKey,
         status: status,
         inputJson: inputJson,
         outputJson: outputJson,
         traceJson: traceJson,
         reservedMicros: reservedMicros,
         chargedMicros: chargedMicros,
         budgetStage: budgetStage,
         version: version,
         createdAt: createdAt,
         completedAt: completedAt,
       );

  /// Returns a shallow copy of this [AssistantRun]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssistantRun copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    Object? roomId = _Undefined,
    String? userId,
    String? requestKey,
    String? status,
    String? inputJson,
    String? outputJson,
    String? traceJson,
    int? reservedMicros,
    int? chargedMicros,
    String? budgetStage,
    int? version,
    DateTime? createdAt,
    Object? completedAt = _Undefined,
  }) {
    return AssistantRun(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      roomId: roomId is int? ? roomId : this.roomId,
      userId: userId ?? this.userId,
      requestKey: requestKey ?? this.requestKey,
      status: status ?? this.status,
      inputJson: inputJson ?? this.inputJson,
      outputJson: outputJson ?? this.outputJson,
      traceJson: traceJson ?? this.traceJson,
      reservedMicros: reservedMicros ?? this.reservedMicros,
      chargedMicros: chargedMicros ?? this.chargedMicros,
      budgetStage: budgetStage ?? this.budgetStage,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
    );
  }
}

class AssistantRunUpdateTable extends _is.UpdateTable<AssistantRunTable> {
  AssistantRunUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> roomId(int? value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> inputJson(String value) => _is.ColumnValue(
    table.inputJson,
    value,
  );

  _is.ColumnValue<String, String> outputJson(String value) => _is.ColumnValue(
    table.outputJson,
    value,
  );

  _is.ColumnValue<String, String> traceJson(String value) => _is.ColumnValue(
    table.traceJson,
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

  _is.ColumnValue<String, String> budgetStage(String value) => _is.ColumnValue(
    table.budgetStage,
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

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );
}

class AssistantRunTable extends _is.Table<int?> {
  AssistantRunTable({super.tableRelation})
    : super(tableName: 'raysto_assistant_run') {
    updateTable = AssistantRunUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    inputJson = _is.ColumnString(
      'inputJson',
      this,
    );
    outputJson = _is.ColumnString(
      'outputJson',
      this,
    );
    traceJson = _is.ColumnString(
      'traceJson',
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
    budgetStage = _is.ColumnString(
      'budgetStage',
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
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
  }

  late final AssistantRunUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt roomId;

  late final _is.ColumnString userId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnString status;

  late final _is.ColumnString inputJson;

  late final _is.ColumnString outputJson;

  late final _is.ColumnString traceJson;

  late final _is.ColumnInt reservedMicros;

  late final _is.ColumnInt chargedMicros;

  late final _is.ColumnString budgetStage;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime completedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    roomId,
    userId,
    requestKey,
    status,
    inputJson,
    outputJson,
    traceJson,
    reservedMicros,
    chargedMicros,
    budgetStage,
    version,
    createdAt,
    completedAt,
  ];
}

class AssistantRunInclude extends _is.IncludeObject {
  AssistantRunInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AssistantRun.t;
}

class AssistantRunIncludeList extends _is.IncludeList {
  AssistantRunIncludeList._({
    _is.WhereExpressionBuilder<AssistantRunTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssistantRun.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AssistantRun.t;
}

class AssistantRunRepository {
  const AssistantRunRepository._();

  /// Returns a list of [AssistantRun]s matching the given query parameters.
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
  Future<List<AssistantRun>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantRunTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantRunTable>? orderBy,
    _is.OrderByListBuilder<AssistantRunTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssistantRun>(
      where: where?.call(AssistantRun.t),
      orderBy: orderBy?.call(AssistantRun.t),
      orderByList: orderByList?.call(AssistantRun.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AssistantRun] matching the given query parameters.
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
  Future<AssistantRun?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantRunTable>? where,
    int? offset,
    _is.OrderByBuilder<AssistantRunTable>? orderBy,
    _is.OrderByListBuilder<AssistantRunTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssistantRun>(
      where: where?.call(AssistantRun.t),
      orderBy: orderBy?.call(AssistantRun.t),
      orderByList: orderByList?.call(AssistantRun.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssistantRun] by its [id] or null if no such row exists.
  Future<AssistantRun?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssistantRun>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssistantRun]s in the list and returns the inserted rows.
  ///
  /// The returned [AssistantRun]s will have their `id` fields set.
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
  Future<List<AssistantRun>> insert(
    _is.DatabaseSession session,
    List<AssistantRun> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssistantRun>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssistantRun] and returns the inserted row.
  ///
  /// The returned [AssistantRun] will have its `id` field set.
  Future<AssistantRun> insertRow(
    _is.DatabaseSession session,
    AssistantRun row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssistantRun>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssistantRun]s in the list and returns the resulting rows.
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
  /// The returned [AssistantRun]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantRun>> upsert(
    _is.DatabaseSession session,
    List<AssistantRun> rows, {
    required _is.ColumnSelections<AssistantRunTable> conflictColumns,
    _is.ColumnSelections<AssistantRunTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantRunTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssistantRun>(
      rows,
      conflictColumns: conflictColumns(AssistantRun.t),
      updateColumns: updateColumns?.call(AssistantRun.t),
      updateWhere: updateWhere?.call(AssistantRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssistantRun] and returns the resulting row.
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
  /// The returned [AssistantRun] will have its `id` field set.
  Future<AssistantRun?> upsertRow(
    _is.DatabaseSession session,
    AssistantRun row, {
    required _is.ColumnSelections<AssistantRunTable> conflictColumns,
    _is.ColumnSelections<AssistantRunTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantRunTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssistantRun>(
      row,
      conflictColumns: conflictColumns(AssistantRun.t),
      updateColumns: updateColumns?.call(AssistantRun.t),
      updateWhere: updateWhere?.call(AssistantRun.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantRun]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantRun>> update(
    _is.DatabaseSession session,
    List<AssistantRun> rows, {
    _is.ColumnSelections<AssistantRunTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssistantRun>(
      rows,
      columns: columns?.call(AssistantRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssistantRun]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssistantRun> updateRow(
    _is.DatabaseSession session,
    AssistantRun row, {
    _is.ColumnSelections<AssistantRunTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssistantRun>(
      row,
      columns: columns?.call(AssistantRun.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssistantRun] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssistantRun?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AssistantRunUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssistantRun>(
      id,
      columnValues: columnValues(AssistantRun.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantRun]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantRun>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssistantRunUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AssistantRunTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantRunTable>? orderBy,
    _is.OrderByListBuilder<AssistantRunTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssistantRun>(
      columnValues: columnValues(AssistantRun.t.updateTable),
      where: where(AssistantRun.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantRun.t),
      orderByList: orderByList?.call(AssistantRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssistantRun]s in the list and returns the deleted rows.
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
  Future<List<AssistantRun>> delete(
    _is.DatabaseSession session,
    List<AssistantRun> rows, {
    _is.OrderByBuilder<AssistantRunTable>? orderBy,
    _is.OrderByListBuilder<AssistantRunTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssistantRun>(
      rows,
      orderBy: orderBy?.call(AssistantRun.t),
      orderByList: orderByList?.call(AssistantRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssistantRun].
  Future<AssistantRun> deleteRow(
    _is.DatabaseSession session,
    AssistantRun row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssistantRun>(
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
  Future<List<AssistantRun>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantRunTable> where,
    _is.OrderByBuilder<AssistantRunTable>? orderBy,
    _is.OrderByListBuilder<AssistantRunTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssistantRun>(
      where: where(AssistantRun.t),
      orderBy: orderBy?.call(AssistantRun.t),
      orderByList: orderByList?.call(AssistantRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantRunTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssistantRun>(
      where: where?.call(AssistantRun.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssistantRun] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantRunTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssistantRun>(
      where: where(AssistantRun.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
