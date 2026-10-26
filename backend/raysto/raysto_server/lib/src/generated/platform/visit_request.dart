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

abstract class VisitRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  VisitRequest._({
    this.id,
    required this.restaurantId,
    required this.visitId,
    required this.userId,
    required this.kind,
    required this.status,
    this.assignedUserId,
    this.reason,
    required this.version,
    required this.createdAt,
  });

  factory VisitRequest({
    int? id,
    required int restaurantId,
    required int visitId,
    required String userId,
    required String kind,
    required String status,
    String? assignedUserId,
    String? reason,
    required int version,
    required DateTime createdAt,
  }) = _VisitRequestImpl;

  factory VisitRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return VisitRequest(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      visitId: jsonSerialization['visitId'] as int,
      userId: jsonSerialization['userId'] as String,
      kind: jsonSerialization['kind'] as String,
      status: jsonSerialization['status'] as String,
      assignedUserId: jsonSerialization['assignedUserId'] as String?,
      reason: jsonSerialization['reason'] as String?,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = VisitRequestTable();

  static const db = VisitRequestRepository._();

  @override
  int? id;

  int restaurantId;

  int visitId;

  String userId;

  String kind;

  String status;

  String? assignedUserId;

  String? reason;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [VisitRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  VisitRequest copyWith({
    int? id,
    int? restaurantId,
    int? visitId,
    String? userId,
    String? kind,
    String? status,
    String? assignedUserId,
    String? reason,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VisitRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'visitId': visitId,
      'userId': userId,
      'kind': kind,
      'status': status,
      if (assignedUserId != null) 'assignedUserId': assignedUserId,
      if (reason != null) 'reason': reason,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static VisitRequestInclude include() {
    return VisitRequestInclude._();
  }

  static VisitRequestIncludeList includeList({
    _is.WhereExpressionBuilder<VisitRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VisitRequestTable>? orderBy,
    _is.OrderByListBuilder<VisitRequestTable>? orderByList,
    VisitRequestInclude? include,
  }) {
    return VisitRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VisitRequest.t),
      orderByList: orderByList?.call(VisitRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VisitRequestImpl extends VisitRequest {
  _VisitRequestImpl({
    int? id,
    required int restaurantId,
    required int visitId,
    required String userId,
    required String kind,
    required String status,
    String? assignedUserId,
    String? reason,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         visitId: visitId,
         userId: userId,
         kind: kind,
         status: status,
         assignedUserId: assignedUserId,
         reason: reason,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [VisitRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  VisitRequest copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? visitId,
    String? userId,
    String? kind,
    String? status,
    Object? assignedUserId = _Undefined,
    Object? reason = _Undefined,
    int? version,
    DateTime? createdAt,
  }) {
    return VisitRequest(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      visitId: visitId ?? this.visitId,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      assignedUserId: assignedUserId is String?
          ? assignedUserId
          : this.assignedUserId,
      reason: reason is String? ? reason : this.reason,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class VisitRequestUpdateTable extends _is.UpdateTable<VisitRequestTable> {
  VisitRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> visitId(int value) => _is.ColumnValue(
    table.visitId,
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

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> assignedUserId(String? value) =>
      _is.ColumnValue(
        table.assignedUserId,
        value,
      );

  _is.ColumnValue<String, String> reason(String? value) => _is.ColumnValue(
    table.reason,
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
}

class VisitRequestTable extends _is.Table<int?> {
  VisitRequestTable({super.tableRelation})
    : super(tableName: 'raysto_visit_request') {
    updateTable = VisitRequestUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
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
    status = _is.ColumnString(
      'status',
      this,
    );
    assignedUserId = _is.ColumnString(
      'assignedUserId',
      this,
    );
    reason = _is.ColumnString(
      'reason',
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
  }

  late final VisitRequestUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt visitId;

  late final _is.ColumnString userId;

  late final _is.ColumnString kind;

  late final _is.ColumnString status;

  late final _is.ColumnString assignedUserId;

  late final _is.ColumnString reason;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    visitId,
    userId,
    kind,
    status,
    assignedUserId,
    reason,
    version,
    createdAt,
  ];
}

class VisitRequestInclude extends _is.IncludeObject {
  VisitRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => VisitRequest.t;
}

class VisitRequestIncludeList extends _is.IncludeList {
  VisitRequestIncludeList._({
    _is.WhereExpressionBuilder<VisitRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(VisitRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => VisitRequest.t;
}

class VisitRequestRepository {
  const VisitRequestRepository._();

  /// Returns a list of [VisitRequest]s matching the given query parameters.
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
  Future<List<VisitRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VisitRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VisitRequestTable>? orderBy,
    _is.OrderByListBuilder<VisitRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<VisitRequest>(
      where: where?.call(VisitRequest.t),
      orderBy: orderBy?.call(VisitRequest.t),
      orderByList: orderByList?.call(VisitRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [VisitRequest] matching the given query parameters.
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
  Future<VisitRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VisitRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<VisitRequestTable>? orderBy,
    _is.OrderByListBuilder<VisitRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<VisitRequest>(
      where: where?.call(VisitRequest.t),
      orderBy: orderBy?.call(VisitRequest.t),
      orderByList: orderByList?.call(VisitRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [VisitRequest] by its [id] or null if no such row exists.
  Future<VisitRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<VisitRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [VisitRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [VisitRequest]s will have their `id` fields set.
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
  Future<List<VisitRequest>> insert(
    _is.DatabaseSession session,
    List<VisitRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<VisitRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [VisitRequest] and returns the inserted row.
  ///
  /// The returned [VisitRequest] will have its `id` field set.
  Future<VisitRequest> insertRow(
    _is.DatabaseSession session,
    VisitRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<VisitRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [VisitRequest]s in the list and returns the resulting rows.
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
  /// The returned [VisitRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VisitRequest>> upsert(
    _is.DatabaseSession session,
    List<VisitRequest> rows, {
    required _is.ColumnSelections<VisitRequestTable> conflictColumns,
    _is.ColumnSelections<VisitRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<VisitRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<VisitRequest>(
      rows,
      conflictColumns: conflictColumns(VisitRequest.t),
      updateColumns: updateColumns?.call(VisitRequest.t),
      updateWhere: updateWhere?.call(VisitRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [VisitRequest] and returns the resulting row.
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
  /// The returned [VisitRequest] will have its `id` field set.
  Future<VisitRequest?> upsertRow(
    _is.DatabaseSession session,
    VisitRequest row, {
    required _is.ColumnSelections<VisitRequestTable> conflictColumns,
    _is.ColumnSelections<VisitRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<VisitRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<VisitRequest>(
      row,
      conflictColumns: conflictColumns(VisitRequest.t),
      updateColumns: updateColumns?.call(VisitRequest.t),
      updateWhere: updateWhere?.call(VisitRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [VisitRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VisitRequest>> update(
    _is.DatabaseSession session,
    List<VisitRequest> rows, {
    _is.ColumnSelections<VisitRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<VisitRequest>(
      rows,
      columns: columns?.call(VisitRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [VisitRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<VisitRequest> updateRow(
    _is.DatabaseSession session,
    VisitRequest row, {
    _is.ColumnSelections<VisitRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<VisitRequest>(
      row,
      columns: columns?.call(VisitRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VisitRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<VisitRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<VisitRequestUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<VisitRequest>(
      id,
      columnValues: columnValues(VisitRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [VisitRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VisitRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<VisitRequestUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<VisitRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VisitRequestTable>? orderBy,
    _is.OrderByListBuilder<VisitRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<VisitRequest>(
      columnValues: columnValues(VisitRequest.t.updateTable),
      where: where(VisitRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VisitRequest.t),
      orderByList: orderByList?.call(VisitRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [VisitRequest]s in the list and returns the deleted rows.
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
  Future<List<VisitRequest>> delete(
    _is.DatabaseSession session,
    List<VisitRequest> rows, {
    _is.OrderByBuilder<VisitRequestTable>? orderBy,
    _is.OrderByListBuilder<VisitRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<VisitRequest>(
      rows,
      orderBy: orderBy?.call(VisitRequest.t),
      orderByList: orderByList?.call(VisitRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [VisitRequest].
  Future<VisitRequest> deleteRow(
    _is.DatabaseSession session,
    VisitRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<VisitRequest>(
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
  Future<List<VisitRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VisitRequestTable> where,
    _is.OrderByBuilder<VisitRequestTable>? orderBy,
    _is.OrderByListBuilder<VisitRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<VisitRequest>(
      where: where(VisitRequest.t),
      orderBy: orderBy?.call(VisitRequest.t),
      orderByList: orderByList?.call(VisitRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VisitRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<VisitRequest>(
      where: where?.call(VisitRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [VisitRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VisitRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<VisitRequest>(
      where: where(VisitRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
