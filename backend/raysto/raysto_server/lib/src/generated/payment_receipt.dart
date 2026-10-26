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

abstract class PaymentReceipt
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentReceipt._({
    this.id,
    required this.orderId,
    required this.captureId,
    required this.amountMinor,
    required this.currency,
    required this.createdAt,
  });

  factory PaymentReceipt({
    int? id,
    required int orderId,
    required String captureId,
    required int amountMinor,
    required String currency,
    required DateTime createdAt,
  }) = _PaymentReceiptImpl;

  factory PaymentReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentReceipt(
      id: jsonSerialization['id'] as int?,
      orderId: jsonSerialization['orderId'] as int,
      captureId: jsonSerialization['captureId'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PaymentReceiptTable();

  static const db = PaymentReceiptRepository._();

  @override
  int? id;

  int orderId;

  String captureId;

  int amountMinor;

  String currency;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentReceipt copyWith({
    int? id,
    int? orderId,
    String? captureId,
    int? amountMinor,
    String? currency,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentReceipt',
      if (id != null) 'id': id,
      'orderId': orderId,
      'captureId': captureId,
      'amountMinor': amountMinor,
      'currency': currency,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentReceiptInclude include() {
    return PaymentReceiptInclude._();
  }

  static PaymentReceiptIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentReceiptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentReceiptTable>? orderBy,
    _is.OrderByListBuilder<PaymentReceiptTable>? orderByList,
    PaymentReceiptInclude? include,
  }) {
    return PaymentReceiptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentReceipt.t),
      orderByList: orderByList?.call(PaymentReceipt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentReceiptImpl extends PaymentReceipt {
  _PaymentReceiptImpl({
    int? id,
    required int orderId,
    required String captureId,
    required int amountMinor,
    required String currency,
    required DateTime createdAt,
  }) : super._(
         id: id,
         orderId: orderId,
         captureId: captureId,
         amountMinor: amountMinor,
         currency: currency,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PaymentReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentReceipt copyWith({
    Object? id = _Undefined,
    int? orderId,
    String? captureId,
    int? amountMinor,
    String? currency,
    DateTime? createdAt,
  }) {
    return PaymentReceipt(
      id: id is int? ? id : this.id,
      orderId: orderId ?? this.orderId,
      captureId: captureId ?? this.captureId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentReceiptUpdateTable extends _is.UpdateTable<PaymentReceiptTable> {
  PaymentReceiptUpdateTable(super.table);

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> captureId(String value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class PaymentReceiptTable extends _is.Table<int?> {
  PaymentReceiptTable({super.tableRelation})
    : super(tableName: 'raysto_payment_receipt') {
    updateTable = PaymentReceiptUpdateTable(this);
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    captureId = _is.ColumnString(
      'captureId',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PaymentReceiptUpdateTable updateTable;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString captureId;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    orderId,
    captureId,
    amountMinor,
    currency,
    createdAt,
  ];
}

class PaymentReceiptInclude extends _is.IncludeObject {
  PaymentReceiptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentReceipt.t;
}

class PaymentReceiptIncludeList extends _is.IncludeList {
  PaymentReceiptIncludeList._({
    _is.WhereExpressionBuilder<PaymentReceiptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentReceipt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentReceipt.t;
}

class PaymentReceiptRepository {
  const PaymentReceiptRepository._();

  /// Returns a list of [PaymentReceipt]s matching the given query parameters.
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
  Future<List<PaymentReceipt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentReceiptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentReceiptTable>? orderBy,
    _is.OrderByListBuilder<PaymentReceiptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentReceipt>(
      where: where?.call(PaymentReceipt.t),
      orderBy: orderBy?.call(PaymentReceipt.t),
      orderByList: orderByList?.call(PaymentReceipt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentReceipt] matching the given query parameters.
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
  Future<PaymentReceipt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentReceiptTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentReceiptTable>? orderBy,
    _is.OrderByListBuilder<PaymentReceiptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentReceipt>(
      where: where?.call(PaymentReceipt.t),
      orderBy: orderBy?.call(PaymentReceipt.t),
      orderByList: orderByList?.call(PaymentReceipt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentReceipt] by its [id] or null if no such row exists.
  Future<PaymentReceipt?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentReceipt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentReceipt]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentReceipt]s will have their `id` fields set.
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
  Future<List<PaymentReceipt>> insert(
    _is.DatabaseSession session,
    List<PaymentReceipt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentReceipt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentReceipt] and returns the inserted row.
  ///
  /// The returned [PaymentReceipt] will have its `id` field set.
  Future<PaymentReceipt> insertRow(
    _is.DatabaseSession session,
    PaymentReceipt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentReceipt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentReceipt]s in the list and returns the resulting rows.
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
  /// The returned [PaymentReceipt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentReceipt>> upsert(
    _is.DatabaseSession session,
    List<PaymentReceipt> rows, {
    required _is.ColumnSelections<PaymentReceiptTable> conflictColumns,
    _is.ColumnSelections<PaymentReceiptTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentReceiptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentReceipt>(
      rows,
      conflictColumns: conflictColumns(PaymentReceipt.t),
      updateColumns: updateColumns?.call(PaymentReceipt.t),
      updateWhere: updateWhere?.call(PaymentReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentReceipt] and returns the resulting row.
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
  /// The returned [PaymentReceipt] will have its `id` field set.
  Future<PaymentReceipt?> upsertRow(
    _is.DatabaseSession session,
    PaymentReceipt row, {
    required _is.ColumnSelections<PaymentReceiptTable> conflictColumns,
    _is.ColumnSelections<PaymentReceiptTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentReceiptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentReceipt>(
      row,
      conflictColumns: conflictColumns(PaymentReceipt.t),
      updateColumns: updateColumns?.call(PaymentReceipt.t),
      updateWhere: updateWhere?.call(PaymentReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentReceipt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentReceipt>> update(
    _is.DatabaseSession session,
    List<PaymentReceipt> rows, {
    _is.ColumnSelections<PaymentReceiptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentReceipt>(
      rows,
      columns: columns?.call(PaymentReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentReceipt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentReceipt> updateRow(
    _is.DatabaseSession session,
    PaymentReceipt row, {
    _is.ColumnSelections<PaymentReceiptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentReceipt>(
      row,
      columns: columns?.call(PaymentReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentReceipt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentReceipt?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentReceiptUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentReceipt>(
      id,
      columnValues: columnValues(PaymentReceipt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentReceipt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentReceipt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentReceiptUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PaymentReceiptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentReceiptTable>? orderBy,
    _is.OrderByListBuilder<PaymentReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentReceipt>(
      columnValues: columnValues(PaymentReceipt.t.updateTable),
      where: where(PaymentReceipt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentReceipt.t),
      orderByList: orderByList?.call(PaymentReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentReceipt]s in the list and returns the deleted rows.
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
  Future<List<PaymentReceipt>> delete(
    _is.DatabaseSession session,
    List<PaymentReceipt> rows, {
    _is.OrderByBuilder<PaymentReceiptTable>? orderBy,
    _is.OrderByListBuilder<PaymentReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentReceipt>(
      rows,
      orderBy: orderBy?.call(PaymentReceipt.t),
      orderByList: orderByList?.call(PaymentReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentReceipt].
  Future<PaymentReceipt> deleteRow(
    _is.DatabaseSession session,
    PaymentReceipt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentReceipt>(
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
  Future<List<PaymentReceipt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentReceiptTable> where,
    _is.OrderByBuilder<PaymentReceiptTable>? orderBy,
    _is.OrderByListBuilder<PaymentReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentReceipt>(
      where: where(PaymentReceipt.t),
      orderBy: orderBy?.call(PaymentReceipt.t),
      orderByList: orderByList?.call(PaymentReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentReceiptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentReceipt>(
      where: where?.call(PaymentReceipt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentReceipt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentReceiptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentReceipt>(
      where: where(PaymentReceipt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
