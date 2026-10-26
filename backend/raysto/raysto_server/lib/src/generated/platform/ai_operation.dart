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

abstract class AiOperation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AiOperation._({
    this.id,
    required this.restaurantId,
    required this.userId,
    required this.kind,
    this.mediaId,
    required this.inputJson,
    this.outputJson,
    required this.status,
    required this.menuVersion,
    required this.version,
    required this.inputTokens,
    required this.outputTokens,
    required this.expiresAt,
    required this.createdAt,
  });

  factory AiOperation({
    int? id,
    required int restaurantId,
    required String userId,
    required String kind,
    int? mediaId,
    required String inputJson,
    String? outputJson,
    required String status,
    required int menuVersion,
    required int version,
    required int inputTokens,
    required int outputTokens,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) = _AiOperationImpl;

  factory AiOperation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiOperation(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      kind: jsonSerialization['kind'] as String,
      mediaId: jsonSerialization['mediaId'] as int?,
      inputJson: jsonSerialization['inputJson'] as String,
      outputJson: jsonSerialization['outputJson'] as String?,
      status: jsonSerialization['status'] as String,
      menuVersion: jsonSerialization['menuVersion'] as int,
      version: jsonSerialization['version'] as int,
      inputTokens: jsonSerialization['inputTokens'] as int,
      outputTokens: jsonSerialization['outputTokens'] as int,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AiOperationTable();

  static const db = AiOperationRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  String kind;

  int? mediaId;

  String inputJson;

  String? outputJson;

  String status;

  int menuVersion;

  int version;

  int inputTokens;

  int outputTokens;

  DateTime expiresAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AiOperation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AiOperation copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? kind,
    int? mediaId,
    String? inputJson,
    String? outputJson,
    String? status,
    int? menuVersion,
    int? version,
    int? inputTokens,
    int? outputTokens,
    DateTime? expiresAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiOperation',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'kind': kind,
      if (mediaId != null) 'mediaId': mediaId,
      'inputJson': inputJson,
      if (outputJson != null) 'outputJson': outputJson,
      'status': status,
      'menuVersion': menuVersion,
      'version': version,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AiOperationInclude include() {
    return AiOperationInclude._();
  }

  static AiOperationIncludeList includeList({
    _is.WhereExpressionBuilder<AiOperationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AiOperationTable>? orderBy,
    _is.OrderByListBuilder<AiOperationTable>? orderByList,
    AiOperationInclude? include,
  }) {
    return AiOperationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiOperation.t),
      orderByList: orderByList?.call(AiOperation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiOperationImpl extends AiOperation {
  _AiOperationImpl({
    int? id,
    required int restaurantId,
    required String userId,
    required String kind,
    int? mediaId,
    required String inputJson,
    String? outputJson,
    required String status,
    required int menuVersion,
    required int version,
    required int inputTokens,
    required int outputTokens,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         kind: kind,
         mediaId: mediaId,
         inputJson: inputJson,
         outputJson: outputJson,
         status: status,
         menuVersion: menuVersion,
         version: version,
         inputTokens: inputTokens,
         outputTokens: outputTokens,
         expiresAt: expiresAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AiOperation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AiOperation copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    String? kind,
    Object? mediaId = _Undefined,
    String? inputJson,
    Object? outputJson = _Undefined,
    String? status,
    int? menuVersion,
    int? version,
    int? inputTokens,
    int? outputTokens,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return AiOperation(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      mediaId: mediaId is int? ? mediaId : this.mediaId,
      inputJson: inputJson ?? this.inputJson,
      outputJson: outputJson is String? ? outputJson : this.outputJson,
      status: status ?? this.status,
      menuVersion: menuVersion ?? this.menuVersion,
      version: version ?? this.version,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AiOperationUpdateTable extends _is.UpdateTable<AiOperationTable> {
  AiOperationUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> mediaId(int? value) => _is.ColumnValue(
    table.mediaId,
    value,
  );

  _is.ColumnValue<String, String> inputJson(String value) => _is.ColumnValue(
    table.inputJson,
    value,
  );

  _is.ColumnValue<String, String> outputJson(String? value) => _is.ColumnValue(
    table.outputJson,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> menuVersion(int value) => _is.ColumnValue(
    table.menuVersion,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<int, int> inputTokens(int value) => _is.ColumnValue(
    table.inputTokens,
    value,
  );

  _is.ColumnValue<int, int> outputTokens(int value) => _is.ColumnValue(
    table.outputTokens,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AiOperationTable extends _is.Table<int?> {
  AiOperationTable({super.tableRelation})
    : super(tableName: 'raysto_ai_operation') {
    updateTable = AiOperationUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    mediaId = _is.ColumnInt(
      'mediaId',
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
    status = _is.ColumnString(
      'status',
      this,
    );
    menuVersion = _is.ColumnInt(
      'menuVersion',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    inputTokens = _is.ColumnInt(
      'inputTokens',
      this,
    );
    outputTokens = _is.ColumnInt(
      'outputTokens',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final AiOperationUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString kind;

  late final _is.ColumnInt mediaId;

  late final _is.ColumnString inputJson;

  late final _is.ColumnString outputJson;

  late final _is.ColumnString status;

  late final _is.ColumnInt menuVersion;

  late final _is.ColumnInt version;

  late final _is.ColumnInt inputTokens;

  late final _is.ColumnInt outputTokens;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    kind,
    mediaId,
    inputJson,
    outputJson,
    status,
    menuVersion,
    version,
    inputTokens,
    outputTokens,
    expiresAt,
    createdAt,
  ];
}

class AiOperationInclude extends _is.IncludeObject {
  AiOperationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AiOperation.t;
}

class AiOperationIncludeList extends _is.IncludeList {
  AiOperationIncludeList._({
    _is.WhereExpressionBuilder<AiOperationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiOperation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AiOperation.t;
}

class AiOperationRepository {
  const AiOperationRepository._();

  /// Returns a list of [AiOperation]s matching the given query parameters.
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
  Future<List<AiOperation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AiOperationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AiOperationTable>? orderBy,
    _is.OrderByListBuilder<AiOperationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiOperation>(
      where: where?.call(AiOperation.t),
      orderBy: orderBy?.call(AiOperation.t),
      orderByList: orderByList?.call(AiOperation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiOperation] matching the given query parameters.
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
  Future<AiOperation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AiOperationTable>? where,
    int? offset,
    _is.OrderByBuilder<AiOperationTable>? orderBy,
    _is.OrderByListBuilder<AiOperationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiOperation>(
      where: where?.call(AiOperation.t),
      orderBy: orderBy?.call(AiOperation.t),
      orderByList: orderByList?.call(AiOperation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiOperation] by its [id] or null if no such row exists.
  Future<AiOperation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiOperation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiOperation]s in the list and returns the inserted rows.
  ///
  /// The returned [AiOperation]s will have their `id` fields set.
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
  Future<List<AiOperation>> insert(
    _is.DatabaseSession session,
    List<AiOperation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AiOperation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AiOperation] and returns the inserted row.
  ///
  /// The returned [AiOperation] will have its `id` field set.
  Future<AiOperation> insertRow(
    _is.DatabaseSession session,
    AiOperation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiOperation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AiOperation]s in the list and returns the resulting rows.
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
  /// The returned [AiOperation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AiOperation>> upsert(
    _is.DatabaseSession session,
    List<AiOperation> rows, {
    required _is.ColumnSelections<AiOperationTable> conflictColumns,
    _is.ColumnSelections<AiOperationTable>? updateColumns,
    _is.WhereExpressionBuilder<AiOperationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AiOperation>(
      rows,
      conflictColumns: conflictColumns(AiOperation.t),
      updateColumns: updateColumns?.call(AiOperation.t),
      updateWhere: updateWhere?.call(AiOperation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AiOperation] and returns the resulting row.
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
  /// The returned [AiOperation] will have its `id` field set.
  Future<AiOperation?> upsertRow(
    _is.DatabaseSession session,
    AiOperation row, {
    required _is.ColumnSelections<AiOperationTable> conflictColumns,
    _is.ColumnSelections<AiOperationTable>? updateColumns,
    _is.WhereExpressionBuilder<AiOperationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AiOperation>(
      row,
      conflictColumns: conflictColumns(AiOperation.t),
      updateColumns: updateColumns?.call(AiOperation.t),
      updateWhere: updateWhere?.call(AiOperation.t),
      transaction: transaction,
    );
  }

  /// Updates all [AiOperation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AiOperation>> update(
    _is.DatabaseSession session,
    List<AiOperation> rows, {
    _is.ColumnSelections<AiOperationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AiOperation>(
      rows,
      columns: columns?.call(AiOperation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AiOperation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiOperation> updateRow(
    _is.DatabaseSession session,
    AiOperation row, {
    _is.ColumnSelections<AiOperationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiOperation>(
      row,
      columns: columns?.call(AiOperation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiOperation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiOperation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AiOperationUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AiOperation>(
      id,
      columnValues: columnValues(AiOperation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiOperation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AiOperation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AiOperationUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AiOperationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AiOperationTable>? orderBy,
    _is.OrderByListBuilder<AiOperationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AiOperation>(
      columnValues: columnValues(AiOperation.t.updateTable),
      where: where(AiOperation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiOperation.t),
      orderByList: orderByList?.call(AiOperation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AiOperation]s in the list and returns the deleted rows.
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
  Future<List<AiOperation>> delete(
    _is.DatabaseSession session,
    List<AiOperation> rows, {
    _is.OrderByBuilder<AiOperationTable>? orderBy,
    _is.OrderByListBuilder<AiOperationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AiOperation>(
      rows,
      orderBy: orderBy?.call(AiOperation.t),
      orderByList: orderByList?.call(AiOperation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AiOperation].
  Future<AiOperation> deleteRow(
    _is.DatabaseSession session,
    AiOperation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiOperation>(
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
  Future<List<AiOperation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AiOperationTable> where,
    _is.OrderByBuilder<AiOperationTable>? orderBy,
    _is.OrderByListBuilder<AiOperationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AiOperation>(
      where: where(AiOperation.t),
      orderBy: orderBy?.call(AiOperation.t),
      orderByList: orderByList?.call(AiOperation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AiOperationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AiOperation>(
      where: where?.call(AiOperation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiOperation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AiOperationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiOperation>(
      where: where(AiOperation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
