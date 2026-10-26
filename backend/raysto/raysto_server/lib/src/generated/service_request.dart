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

abstract class ServiceRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ServiceRequest._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    required this.customerId,
    required this.kind,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequest({
    int? id,
    required int restaurantId,
    required int orderId,
    required String customerId,
    required String kind,
    required String status,
    required DateTime createdAt,
  }) = _ServiceRequestImpl;

  factory ServiceRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ServiceRequest(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      customerId: jsonSerialization['customerId'] as String,
      kind: jsonSerialization['kind'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ServiceRequestTable();

  static const db = ServiceRequestRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  String customerId;

  String kind;

  String status;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ServiceRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ServiceRequest copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    String? customerId,
    String? kind,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ServiceRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      'customerId': customerId,
      'kind': kind,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ServiceRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      'customerId': customerId,
      'kind': kind,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  static ServiceRequestInclude include() {
    return ServiceRequestInclude._();
  }

  static ServiceRequestIncludeList includeList({
    _is.WhereExpressionBuilder<ServiceRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ServiceRequestTable>? orderBy,
    _is.OrderByListBuilder<ServiceRequestTable>? orderByList,
    ServiceRequestInclude? include,
  }) {
    return ServiceRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ServiceRequest.t),
      orderByList: orderByList?.call(ServiceRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ServiceRequestImpl extends ServiceRequest {
  _ServiceRequestImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    required String customerId,
    required String kind,
    required String status,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         customerId: customerId,
         kind: kind,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ServiceRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ServiceRequest copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    String? customerId,
    String? kind,
    String? status,
    DateTime? createdAt,
  }) {
    return ServiceRequest(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ServiceRequestUpdateTable extends _is.UpdateTable<ServiceRequestTable> {
  ServiceRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> customerId(String value) => _is.ColumnValue(
    table.customerId,
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

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ServiceRequestTable extends _is.Table<int?> {
  ServiceRequestTable({super.tableRelation})
    : super(tableName: 'raysto_service_request') {
    updateTable = ServiceRequestUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    customerId = _is.ColumnString(
      'customerId',
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
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ServiceRequestUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString customerId;

  late final _is.ColumnString kind;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    customerId,
    kind,
    status,
    createdAt,
  ];
}

class ServiceRequestInclude extends _is.IncludeObject {
  ServiceRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ServiceRequest.t;
}

class ServiceRequestIncludeList extends _is.IncludeList {
  ServiceRequestIncludeList._({
    _is.WhereExpressionBuilder<ServiceRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ServiceRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ServiceRequest.t;
}

class ServiceRequestRepository {
  const ServiceRequestRepository._();

  /// Returns a list of [ServiceRequest]s matching the given query parameters.
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
  Future<List<ServiceRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ServiceRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ServiceRequestTable>? orderBy,
    _is.OrderByListBuilder<ServiceRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ServiceRequest>(
      where: where?.call(ServiceRequest.t),
      orderBy: orderBy?.call(ServiceRequest.t),
      orderByList: orderByList?.call(ServiceRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ServiceRequest] matching the given query parameters.
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
  Future<ServiceRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ServiceRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<ServiceRequestTable>? orderBy,
    _is.OrderByListBuilder<ServiceRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ServiceRequest>(
      where: where?.call(ServiceRequest.t),
      orderBy: orderBy?.call(ServiceRequest.t),
      orderByList: orderByList?.call(ServiceRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ServiceRequest] by its [id] or null if no such row exists.
  Future<ServiceRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ServiceRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ServiceRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [ServiceRequest]s will have their `id` fields set.
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
  Future<List<ServiceRequest>> insert(
    _is.DatabaseSession session,
    List<ServiceRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ServiceRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ServiceRequest] and returns the inserted row.
  ///
  /// The returned [ServiceRequest] will have its `id` field set.
  Future<ServiceRequest> insertRow(
    _is.DatabaseSession session,
    ServiceRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ServiceRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ServiceRequest]s in the list and returns the resulting rows.
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
  /// The returned [ServiceRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ServiceRequest>> upsert(
    _is.DatabaseSession session,
    List<ServiceRequest> rows, {
    required _is.ColumnSelections<ServiceRequestTable> conflictColumns,
    _is.ColumnSelections<ServiceRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ServiceRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ServiceRequest>(
      rows,
      conflictColumns: conflictColumns(ServiceRequest.t),
      updateColumns: updateColumns?.call(ServiceRequest.t),
      updateWhere: updateWhere?.call(ServiceRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ServiceRequest] and returns the resulting row.
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
  /// The returned [ServiceRequest] will have its `id` field set.
  Future<ServiceRequest?> upsertRow(
    _is.DatabaseSession session,
    ServiceRequest row, {
    required _is.ColumnSelections<ServiceRequestTable> conflictColumns,
    _is.ColumnSelections<ServiceRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ServiceRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ServiceRequest>(
      row,
      conflictColumns: conflictColumns(ServiceRequest.t),
      updateColumns: updateColumns?.call(ServiceRequest.t),
      updateWhere: updateWhere?.call(ServiceRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [ServiceRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ServiceRequest>> update(
    _is.DatabaseSession session,
    List<ServiceRequest> rows, {
    _is.ColumnSelections<ServiceRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ServiceRequest>(
      rows,
      columns: columns?.call(ServiceRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ServiceRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ServiceRequest> updateRow(
    _is.DatabaseSession session,
    ServiceRequest row, {
    _is.ColumnSelections<ServiceRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ServiceRequest>(
      row,
      columns: columns?.call(ServiceRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ServiceRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ServiceRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ServiceRequestUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ServiceRequest>(
      id,
      columnValues: columnValues(ServiceRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ServiceRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ServiceRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ServiceRequestUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ServiceRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ServiceRequestTable>? orderBy,
    _is.OrderByListBuilder<ServiceRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ServiceRequest>(
      columnValues: columnValues(ServiceRequest.t.updateTable),
      where: where(ServiceRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ServiceRequest.t),
      orderByList: orderByList?.call(ServiceRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ServiceRequest]s in the list and returns the deleted rows.
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
  Future<List<ServiceRequest>> delete(
    _is.DatabaseSession session,
    List<ServiceRequest> rows, {
    _is.OrderByBuilder<ServiceRequestTable>? orderBy,
    _is.OrderByListBuilder<ServiceRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ServiceRequest>(
      rows,
      orderBy: orderBy?.call(ServiceRequest.t),
      orderByList: orderByList?.call(ServiceRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ServiceRequest].
  Future<ServiceRequest> deleteRow(
    _is.DatabaseSession session,
    ServiceRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ServiceRequest>(
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
  Future<List<ServiceRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ServiceRequestTable> where,
    _is.OrderByBuilder<ServiceRequestTable>? orderBy,
    _is.OrderByListBuilder<ServiceRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ServiceRequest>(
      where: where(ServiceRequest.t),
      orderBy: orderBy?.call(ServiceRequest.t),
      orderByList: orderByList?.call(ServiceRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ServiceRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ServiceRequest>(
      where: where?.call(ServiceRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ServiceRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ServiceRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ServiceRequest>(
      where: where(ServiceRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
