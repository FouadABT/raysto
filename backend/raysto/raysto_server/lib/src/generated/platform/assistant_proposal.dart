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

abstract class AssistantProposal
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AssistantProposal._({
    this.id,
    required this.restaurantId,
    this.roomId,
    required this.runId,
    required this.userId,
    required this.kind,
    required this.payloadJson,
    required this.contextHash,
    required this.status,
    required this.version,
    required this.expiresAt,
    required this.createdAt,
  });

  factory AssistantProposal({
    int? id,
    required int restaurantId,
    int? roomId,
    required int runId,
    required String userId,
    required String kind,
    required String payloadJson,
    required String contextHash,
    required String status,
    required int version,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) = _AssistantProposalImpl;

  factory AssistantProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantProposal(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      roomId: jsonSerialization['roomId'] as int?,
      runId: jsonSerialization['runId'] as int,
      userId: jsonSerialization['userId'] as String,
      kind: jsonSerialization['kind'] as String,
      payloadJson: jsonSerialization['payloadJson'] as String,
      contextHash: jsonSerialization['contextHash'] as String,
      status: jsonSerialization['status'] as String,
      version: jsonSerialization['version'] as int,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AssistantProposalTable();

  static const db = AssistantProposalRepository._();

  @override
  int? id;

  int restaurantId;

  int? roomId;

  int runId;

  String userId;

  String kind;

  String payloadJson;

  String contextHash;

  String status;

  int version;

  DateTime expiresAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AssistantProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantProposal copyWith({
    int? id,
    int? restaurantId,
    int? roomId,
    int? runId,
    String? userId,
    String? kind,
    String? payloadJson,
    String? contextHash,
    String? status,
    int? version,
    DateTime? expiresAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantProposal',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      if (roomId != null) 'roomId': roomId,
      'runId': runId,
      'userId': userId,
      'kind': kind,
      'payloadJson': payloadJson,
      'contextHash': contextHash,
      'status': status,
      'version': version,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AssistantProposalInclude include() {
    return AssistantProposalInclude._();
  }

  static AssistantProposalIncludeList includeList({
    _is.WhereExpressionBuilder<AssistantProposalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantProposalTable>? orderBy,
    _is.OrderByListBuilder<AssistantProposalTable>? orderByList,
    AssistantProposalInclude? include,
  }) {
    return AssistantProposalIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantProposal.t),
      orderByList: orderByList?.call(AssistantProposal.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantProposalImpl extends AssistantProposal {
  _AssistantProposalImpl({
    int? id,
    required int restaurantId,
    int? roomId,
    required int runId,
    required String userId,
    required String kind,
    required String payloadJson,
    required String contextHash,
    required String status,
    required int version,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         roomId: roomId,
         runId: runId,
         userId: userId,
         kind: kind,
         payloadJson: payloadJson,
         contextHash: contextHash,
         status: status,
         version: version,
         expiresAt: expiresAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AssistantProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssistantProposal copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    Object? roomId = _Undefined,
    int? runId,
    String? userId,
    String? kind,
    String? payloadJson,
    String? contextHash,
    String? status,
    int? version,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return AssistantProposal(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      roomId: roomId is int? ? roomId : this.roomId,
      runId: runId ?? this.runId,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      contextHash: contextHash ?? this.contextHash,
      status: status ?? this.status,
      version: version ?? this.version,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AssistantProposalUpdateTable
    extends _is.UpdateTable<AssistantProposalTable> {
  AssistantProposalUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> roomId(int? value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<int, int> runId(int value) => _is.ColumnValue(
    table.runId,
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

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
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

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
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

class AssistantProposalTable extends _is.Table<int?> {
  AssistantProposalTable({super.tableRelation})
    : super(tableName: 'raysto_assistant_proposal') {
    updateTable = AssistantProposalUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    runId = _is.ColumnInt(
      'runId',
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
    payloadJson = _is.ColumnString(
      'payloadJson',
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
    version = _is.ColumnInt(
      'version',
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

  late final AssistantProposalUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt roomId;

  late final _is.ColumnInt runId;

  late final _is.ColumnString userId;

  late final _is.ColumnString kind;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnString contextHash;

  late final _is.ColumnString status;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    roomId,
    runId,
    userId,
    kind,
    payloadJson,
    contextHash,
    status,
    version,
    expiresAt,
    createdAt,
  ];
}

class AssistantProposalInclude extends _is.IncludeObject {
  AssistantProposalInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AssistantProposal.t;
}

class AssistantProposalIncludeList extends _is.IncludeList {
  AssistantProposalIncludeList._({
    _is.WhereExpressionBuilder<AssistantProposalTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssistantProposal.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AssistantProposal.t;
}

class AssistantProposalRepository {
  const AssistantProposalRepository._();

  /// Returns a list of [AssistantProposal]s matching the given query parameters.
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
  Future<List<AssistantProposal>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantProposalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantProposalTable>? orderBy,
    _is.OrderByListBuilder<AssistantProposalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssistantProposal>(
      where: where?.call(AssistantProposal.t),
      orderBy: orderBy?.call(AssistantProposal.t),
      orderByList: orderByList?.call(AssistantProposal.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AssistantProposal] matching the given query parameters.
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
  Future<AssistantProposal?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantProposalTable>? where,
    int? offset,
    _is.OrderByBuilder<AssistantProposalTable>? orderBy,
    _is.OrderByListBuilder<AssistantProposalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssistantProposal>(
      where: where?.call(AssistantProposal.t),
      orderBy: orderBy?.call(AssistantProposal.t),
      orderByList: orderByList?.call(AssistantProposal.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssistantProposal] by its [id] or null if no such row exists.
  Future<AssistantProposal?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssistantProposal>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssistantProposal]s in the list and returns the inserted rows.
  ///
  /// The returned [AssistantProposal]s will have their `id` fields set.
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
  Future<List<AssistantProposal>> insert(
    _is.DatabaseSession session,
    List<AssistantProposal> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssistantProposal>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssistantProposal] and returns the inserted row.
  ///
  /// The returned [AssistantProposal] will have its `id` field set.
  Future<AssistantProposal> insertRow(
    _is.DatabaseSession session,
    AssistantProposal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssistantProposal>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssistantProposal]s in the list and returns the resulting rows.
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
  /// The returned [AssistantProposal]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantProposal>> upsert(
    _is.DatabaseSession session,
    List<AssistantProposal> rows, {
    required _is.ColumnSelections<AssistantProposalTable> conflictColumns,
    _is.ColumnSelections<AssistantProposalTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantProposalTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssistantProposal>(
      rows,
      conflictColumns: conflictColumns(AssistantProposal.t),
      updateColumns: updateColumns?.call(AssistantProposal.t),
      updateWhere: updateWhere?.call(AssistantProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssistantProposal] and returns the resulting row.
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
  /// The returned [AssistantProposal] will have its `id` field set.
  Future<AssistantProposal?> upsertRow(
    _is.DatabaseSession session,
    AssistantProposal row, {
    required _is.ColumnSelections<AssistantProposalTable> conflictColumns,
    _is.ColumnSelections<AssistantProposalTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantProposalTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssistantProposal>(
      row,
      conflictColumns: conflictColumns(AssistantProposal.t),
      updateColumns: updateColumns?.call(AssistantProposal.t),
      updateWhere: updateWhere?.call(AssistantProposal.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantProposal]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantProposal>> update(
    _is.DatabaseSession session,
    List<AssistantProposal> rows, {
    _is.ColumnSelections<AssistantProposalTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssistantProposal>(
      rows,
      columns: columns?.call(AssistantProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssistantProposal]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssistantProposal> updateRow(
    _is.DatabaseSession session,
    AssistantProposal row, {
    _is.ColumnSelections<AssistantProposalTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssistantProposal>(
      row,
      columns: columns?.call(AssistantProposal.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssistantProposal] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssistantProposal?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AssistantProposalUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssistantProposal>(
      id,
      columnValues: columnValues(AssistantProposal.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantProposal]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantProposal>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssistantProposalUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AssistantProposalTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantProposalTable>? orderBy,
    _is.OrderByListBuilder<AssistantProposalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssistantProposal>(
      columnValues: columnValues(AssistantProposal.t.updateTable),
      where: where(AssistantProposal.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantProposal.t),
      orderByList: orderByList?.call(AssistantProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssistantProposal]s in the list and returns the deleted rows.
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
  Future<List<AssistantProposal>> delete(
    _is.DatabaseSession session,
    List<AssistantProposal> rows, {
    _is.OrderByBuilder<AssistantProposalTable>? orderBy,
    _is.OrderByListBuilder<AssistantProposalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssistantProposal>(
      rows,
      orderBy: orderBy?.call(AssistantProposal.t),
      orderByList: orderByList?.call(AssistantProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssistantProposal].
  Future<AssistantProposal> deleteRow(
    _is.DatabaseSession session,
    AssistantProposal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssistantProposal>(
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
  Future<List<AssistantProposal>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantProposalTable> where,
    _is.OrderByBuilder<AssistantProposalTable>? orderBy,
    _is.OrderByListBuilder<AssistantProposalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssistantProposal>(
      where: where(AssistantProposal.t),
      orderBy: orderBy?.call(AssistantProposal.t),
      orderByList: orderByList?.call(AssistantProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantProposalTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssistantProposal>(
      where: where?.call(AssistantProposal.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssistantProposal] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantProposalTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssistantProposal>(
      where: where(AssistantProposal.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
