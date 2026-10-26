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

abstract class PaymentRefund
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentRefund._({
    this.id,
    required this.restaurantId,
    required this.captureId,
    required this.requestKey,
    this.providerRefundId,
    required this.allocationJson,
    required this.amountMinor,
    required this.commissionMinor,
    required this.reason,
    required this.state,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentRefund({
    int? id,
    required int restaurantId,
    required int captureId,
    required String requestKey,
    String? providerRefundId,
    required String allocationJson,
    required int amountMinor,
    required int commissionMinor,
    required String reason,
    required String state,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentRefundImpl;

  factory PaymentRefund.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentRefund(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      captureId: jsonSerialization['captureId'] as int,
      requestKey: jsonSerialization['requestKey'] as String,
      providerRefundId: jsonSerialization['providerRefundId'] as String?,
      allocationJson: jsonSerialization['allocationJson'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      commissionMinor: jsonSerialization['commissionMinor'] as int,
      reason: jsonSerialization['reason'] as String,
      state: jsonSerialization['state'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PaymentRefundTable();

  static const db = PaymentRefundRepository._();

  @override
  int? id;

  int restaurantId;

  int captureId;

  String requestKey;

  String? providerRefundId;

  String allocationJson;

  int amountMinor;

  int commissionMinor;

  String reason;

  String state;

  String createdBy;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentRefund]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentRefund copyWith({
    int? id,
    int? restaurantId,
    int? captureId,
    String? requestKey,
    String? providerRefundId,
    String? allocationJson,
    int? amountMinor,
    int? commissionMinor,
    String? reason,
    String? state,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentRefund',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'captureId': captureId,
      'requestKey': requestKey,
      if (providerRefundId != null) 'providerRefundId': providerRefundId,
      'allocationJson': allocationJson,
      'amountMinor': amountMinor,
      'commissionMinor': commissionMinor,
      'reason': reason,
      'state': state,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentRefundInclude include() {
    return PaymentRefundInclude._();
  }

  static PaymentRefundIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentRefundTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentRefundTable>? orderBy,
    _is.OrderByListBuilder<PaymentRefundTable>? orderByList,
    PaymentRefundInclude? include,
  }) {
    return PaymentRefundIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentRefund.t),
      orderByList: orderByList?.call(PaymentRefund.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentRefundImpl extends PaymentRefund {
  _PaymentRefundImpl({
    int? id,
    required int restaurantId,
    required int captureId,
    required String requestKey,
    String? providerRefundId,
    required String allocationJson,
    required int amountMinor,
    required int commissionMinor,
    required String reason,
    required String state,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         captureId: captureId,
         requestKey: requestKey,
         providerRefundId: providerRefundId,
         allocationJson: allocationJson,
         amountMinor: amountMinor,
         commissionMinor: commissionMinor,
         reason: reason,
         state: state,
         createdBy: createdBy,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PaymentRefund]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentRefund copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? captureId,
    String? requestKey,
    Object? providerRefundId = _Undefined,
    String? allocationJson,
    int? amountMinor,
    int? commissionMinor,
    String? reason,
    String? state,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentRefund(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      captureId: captureId ?? this.captureId,
      requestKey: requestKey ?? this.requestKey,
      providerRefundId: providerRefundId is String?
          ? providerRefundId
          : this.providerRefundId,
      allocationJson: allocationJson ?? this.allocationJson,
      amountMinor: amountMinor ?? this.amountMinor,
      commissionMinor: commissionMinor ?? this.commissionMinor,
      reason: reason ?? this.reason,
      state: state ?? this.state,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentRefundUpdateTable extends _is.UpdateTable<PaymentRefundTable> {
  PaymentRefundUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> captureId(int value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<String, String> providerRefundId(String? value) =>
      _is.ColumnValue(
        table.providerRefundId,
        value,
      );

  _is.ColumnValue<String, String> allocationJson(String value) =>
      _is.ColumnValue(
        table.allocationJson,
        value,
      );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> commissionMinor(int value) => _is.ColumnValue(
    table.commissionMinor,
    value,
  );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
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
}

class PaymentRefundTable extends _is.Table<int?> {
  PaymentRefundTable({super.tableRelation})
    : super(tableName: 'raysto_payment_refund') {
    updateTable = PaymentRefundUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    captureId = _is.ColumnInt(
      'captureId',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    providerRefundId = _is.ColumnString(
      'providerRefundId',
      this,
    );
    allocationJson = _is.ColumnString(
      'allocationJson',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    commissionMinor = _is.ColumnInt(
      'commissionMinor',
      this,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
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
  }

  late final PaymentRefundUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt captureId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnString providerRefundId;

  late final _is.ColumnString allocationJson;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnInt commissionMinor;

  late final _is.ColumnString reason;

  late final _is.ColumnString state;

  late final _is.ColumnString createdBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    captureId,
    requestKey,
    providerRefundId,
    allocationJson,
    amountMinor,
    commissionMinor,
    reason,
    state,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

class PaymentRefundInclude extends _is.IncludeObject {
  PaymentRefundInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentRefund.t;
}

class PaymentRefundIncludeList extends _is.IncludeList {
  PaymentRefundIncludeList._({
    _is.WhereExpressionBuilder<PaymentRefundTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentRefund.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentRefund.t;
}

class PaymentRefundRepository {
  const PaymentRefundRepository._();

  /// Returns a list of [PaymentRefund]s matching the given query parameters.
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
  Future<List<PaymentRefund>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentRefundTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentRefundTable>? orderBy,
    _is.OrderByListBuilder<PaymentRefundTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentRefund>(
      where: where?.call(PaymentRefund.t),
      orderBy: orderBy?.call(PaymentRefund.t),
      orderByList: orderByList?.call(PaymentRefund.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentRefund] matching the given query parameters.
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
  Future<PaymentRefund?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentRefundTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentRefundTable>? orderBy,
    _is.OrderByListBuilder<PaymentRefundTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentRefund>(
      where: where?.call(PaymentRefund.t),
      orderBy: orderBy?.call(PaymentRefund.t),
      orderByList: orderByList?.call(PaymentRefund.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentRefund] by its [id] or null if no such row exists.
  Future<PaymentRefund?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentRefund>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentRefund]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentRefund]s will have their `id` fields set.
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
  Future<List<PaymentRefund>> insert(
    _is.DatabaseSession session,
    List<PaymentRefund> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentRefund>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentRefund] and returns the inserted row.
  ///
  /// The returned [PaymentRefund] will have its `id` field set.
  Future<PaymentRefund> insertRow(
    _is.DatabaseSession session,
    PaymentRefund row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentRefund>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentRefund]s in the list and returns the resulting rows.
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
  /// The returned [PaymentRefund]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentRefund>> upsert(
    _is.DatabaseSession session,
    List<PaymentRefund> rows, {
    required _is.ColumnSelections<PaymentRefundTable> conflictColumns,
    _is.ColumnSelections<PaymentRefundTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentRefundTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentRefund>(
      rows,
      conflictColumns: conflictColumns(PaymentRefund.t),
      updateColumns: updateColumns?.call(PaymentRefund.t),
      updateWhere: updateWhere?.call(PaymentRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentRefund] and returns the resulting row.
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
  /// The returned [PaymentRefund] will have its `id` field set.
  Future<PaymentRefund?> upsertRow(
    _is.DatabaseSession session,
    PaymentRefund row, {
    required _is.ColumnSelections<PaymentRefundTable> conflictColumns,
    _is.ColumnSelections<PaymentRefundTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentRefundTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentRefund>(
      row,
      conflictColumns: conflictColumns(PaymentRefund.t),
      updateColumns: updateColumns?.call(PaymentRefund.t),
      updateWhere: updateWhere?.call(PaymentRefund.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentRefund]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentRefund>> update(
    _is.DatabaseSession session,
    List<PaymentRefund> rows, {
    _is.ColumnSelections<PaymentRefundTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentRefund>(
      rows,
      columns: columns?.call(PaymentRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentRefund]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentRefund> updateRow(
    _is.DatabaseSession session,
    PaymentRefund row, {
    _is.ColumnSelections<PaymentRefundTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentRefund>(
      row,
      columns: columns?.call(PaymentRefund.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentRefund] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentRefund?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentRefundUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentRefund>(
      id,
      columnValues: columnValues(PaymentRefund.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentRefund]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentRefund>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentRefundUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PaymentRefundTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentRefundTable>? orderBy,
    _is.OrderByListBuilder<PaymentRefundTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentRefund>(
      columnValues: columnValues(PaymentRefund.t.updateTable),
      where: where(PaymentRefund.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentRefund.t),
      orderByList: orderByList?.call(PaymentRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentRefund]s in the list and returns the deleted rows.
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
  Future<List<PaymentRefund>> delete(
    _is.DatabaseSession session,
    List<PaymentRefund> rows, {
    _is.OrderByBuilder<PaymentRefundTable>? orderBy,
    _is.OrderByListBuilder<PaymentRefundTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentRefund>(
      rows,
      orderBy: orderBy?.call(PaymentRefund.t),
      orderByList: orderByList?.call(PaymentRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentRefund].
  Future<PaymentRefund> deleteRow(
    _is.DatabaseSession session,
    PaymentRefund row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentRefund>(
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
  Future<List<PaymentRefund>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentRefundTable> where,
    _is.OrderByBuilder<PaymentRefundTable>? orderBy,
    _is.OrderByListBuilder<PaymentRefundTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentRefund>(
      where: where(PaymentRefund.t),
      orderBy: orderBy?.call(PaymentRefund.t),
      orderByList: orderByList?.call(PaymentRefund.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentRefundTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentRefund>(
      where: where?.call(PaymentRefund.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentRefund] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentRefundTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentRefund>(
      where: where(PaymentRefund.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
