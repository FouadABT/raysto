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

abstract class PaymentAttempt
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentAttempt._({
    this.id,
    required this.orderId,
    required this.requestId,
    this.providerOrderId,
    this.approvalUrl,
    required this.state,
    required this.createdAt,
  });

  factory PaymentAttempt({
    int? id,
    required int orderId,
    required String requestId,
    String? providerOrderId,
    String? approvalUrl,
    required String state,
    required DateTime createdAt,
  }) = _PaymentAttemptImpl;

  factory PaymentAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentAttempt(
      id: jsonSerialization['id'] as int?,
      orderId: jsonSerialization['orderId'] as int,
      requestId: jsonSerialization['requestId'] as String,
      providerOrderId: jsonSerialization['providerOrderId'] as String?,
      approvalUrl: jsonSerialization['approvalUrl'] as String?,
      state: jsonSerialization['state'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PaymentAttemptTable();

  static const db = PaymentAttemptRepository._();

  @override
  int? id;

  int orderId;

  String requestId;

  String? providerOrderId;

  String? approvalUrl;

  String state;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentAttempt copyWith({
    int? id,
    int? orderId,
    String? requestId,
    String? providerOrderId,
    String? approvalUrl,
    String? state,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentAttempt',
      if (id != null) 'id': id,
      'orderId': orderId,
      'requestId': requestId,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      'state': state,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentAttemptInclude include() {
    return PaymentAttemptInclude._();
  }

  static PaymentAttemptIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentAttemptTable>? orderBy,
    _is.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    PaymentAttemptInclude? include,
  }) {
    return PaymentAttemptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentAttemptImpl extends PaymentAttempt {
  _PaymentAttemptImpl({
    int? id,
    required int orderId,
    required String requestId,
    String? providerOrderId,
    String? approvalUrl,
    required String state,
    required DateTime createdAt,
  }) : super._(
         id: id,
         orderId: orderId,
         requestId: requestId,
         providerOrderId: providerOrderId,
         approvalUrl: approvalUrl,
         state: state,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PaymentAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentAttempt copyWith({
    Object? id = _Undefined,
    int? orderId,
    String? requestId,
    Object? providerOrderId = _Undefined,
    Object? approvalUrl = _Undefined,
    String? state,
    DateTime? createdAt,
  }) {
    return PaymentAttempt(
      id: id is int? ? id : this.id,
      orderId: orderId ?? this.orderId,
      requestId: requestId ?? this.requestId,
      providerOrderId: providerOrderId is String?
          ? providerOrderId
          : this.providerOrderId,
      approvalUrl: approvalUrl is String? ? approvalUrl : this.approvalUrl,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentAttemptUpdateTable extends _is.UpdateTable<PaymentAttemptTable> {
  PaymentAttemptUpdateTable(super.table);

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> requestId(String value) => _is.ColumnValue(
    table.requestId,
    value,
  );

  _is.ColumnValue<String, String> providerOrderId(String? value) =>
      _is.ColumnValue(
        table.providerOrderId,
        value,
      );

  _is.ColumnValue<String, String> approvalUrl(String? value) => _is.ColumnValue(
    table.approvalUrl,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class PaymentAttemptTable extends _is.Table<int?> {
  PaymentAttemptTable({super.tableRelation})
    : super(tableName: 'raysto_payment_attempt') {
    updateTable = PaymentAttemptUpdateTable(this);
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    requestId = _is.ColumnString(
      'requestId',
      this,
    );
    providerOrderId = _is.ColumnString(
      'providerOrderId',
      this,
    );
    approvalUrl = _is.ColumnString(
      'approvalUrl',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PaymentAttemptUpdateTable updateTable;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString requestId;

  late final _is.ColumnString providerOrderId;

  late final _is.ColumnString approvalUrl;

  late final _is.ColumnString state;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    orderId,
    requestId,
    providerOrderId,
    approvalUrl,
    state,
    createdAt,
  ];
}

class PaymentAttemptInclude extends _is.IncludeObject {
  PaymentAttemptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentAttempt.t;
}

class PaymentAttemptIncludeList extends _is.IncludeList {
  PaymentAttemptIncludeList._({
    _is.WhereExpressionBuilder<PaymentAttemptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentAttempt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentAttempt.t;
}

class PaymentAttemptRepository {
  const PaymentAttemptRepository._();

  /// Returns a list of [PaymentAttempt]s matching the given query parameters.
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
  Future<List<PaymentAttempt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentAttemptTable>? orderBy,
    _is.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentAttempt>(
      where: where?.call(PaymentAttempt.t),
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentAttempt] matching the given query parameters.
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
  Future<PaymentAttempt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentAttemptTable>? orderBy,
    _is.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentAttempt>(
      where: where?.call(PaymentAttempt.t),
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentAttempt] by its [id] or null if no such row exists.
  Future<PaymentAttempt?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentAttempt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentAttempt]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentAttempt]s will have their `id` fields set.
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
  Future<List<PaymentAttempt>> insert(
    _is.DatabaseSession session,
    List<PaymentAttempt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentAttempt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentAttempt] and returns the inserted row.
  ///
  /// The returned [PaymentAttempt] will have its `id` field set.
  Future<PaymentAttempt> insertRow(
    _is.DatabaseSession session,
    PaymentAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentAttempt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentAttempt]s in the list and returns the resulting rows.
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
  /// The returned [PaymentAttempt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentAttempt>> upsert(
    _is.DatabaseSession session,
    List<PaymentAttempt> rows, {
    required _is.ColumnSelections<PaymentAttemptTable> conflictColumns,
    _is.ColumnSelections<PaymentAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentAttemptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentAttempt>(
      rows,
      conflictColumns: conflictColumns(PaymentAttempt.t),
      updateColumns: updateColumns?.call(PaymentAttempt.t),
      updateWhere: updateWhere?.call(PaymentAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentAttempt] and returns the resulting row.
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
  /// The returned [PaymentAttempt] will have its `id` field set.
  Future<PaymentAttempt?> upsertRow(
    _is.DatabaseSession session,
    PaymentAttempt row, {
    required _is.ColumnSelections<PaymentAttemptTable> conflictColumns,
    _is.ColumnSelections<PaymentAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentAttemptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentAttempt>(
      row,
      conflictColumns: conflictColumns(PaymentAttempt.t),
      updateColumns: updateColumns?.call(PaymentAttempt.t),
      updateWhere: updateWhere?.call(PaymentAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentAttempt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentAttempt>> update(
    _is.DatabaseSession session,
    List<PaymentAttempt> rows, {
    _is.ColumnSelections<PaymentAttemptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentAttempt>(
      rows,
      columns: columns?.call(PaymentAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentAttempt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentAttempt> updateRow(
    _is.DatabaseSession session,
    PaymentAttempt row, {
    _is.ColumnSelections<PaymentAttemptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentAttempt>(
      row,
      columns: columns?.call(PaymentAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentAttempt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentAttempt?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentAttemptUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentAttempt>(
      id,
      columnValues: columnValues(PaymentAttempt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentAttempt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentAttempt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentAttemptUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PaymentAttemptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentAttemptTable>? orderBy,
    _is.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentAttempt>(
      columnValues: columnValues(PaymentAttempt.t.updateTable),
      where: where(PaymentAttempt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentAttempt]s in the list and returns the deleted rows.
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
  Future<List<PaymentAttempt>> delete(
    _is.DatabaseSession session,
    List<PaymentAttempt> rows, {
    _is.OrderByBuilder<PaymentAttemptTable>? orderBy,
    _is.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentAttempt>(
      rows,
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentAttempt].
  Future<PaymentAttempt> deleteRow(
    _is.DatabaseSession session,
    PaymentAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentAttempt>(
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
  Future<List<PaymentAttempt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentAttemptTable> where,
    _is.OrderByBuilder<PaymentAttemptTable>? orderBy,
    _is.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentAttempt>(
      where: where(PaymentAttempt.t),
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentAttempt>(
      where: where?.call(PaymentAttempt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentAttempt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentAttemptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentAttempt>(
      where: where(PaymentAttempt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
