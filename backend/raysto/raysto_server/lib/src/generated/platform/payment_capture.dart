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

abstract class PaymentCapture
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentCapture._({
    this.id,
    required this.restaurantId,
    required this.checkoutId,
    required this.providerCaptureId,
    required this.amountMinor,
    required this.refundedMinor,
    required this.currency,
    required this.state,
    required this.createdAt,
  });

  factory PaymentCapture({
    int? id,
    required int restaurantId,
    required int checkoutId,
    required String providerCaptureId,
    required int amountMinor,
    required int refundedMinor,
    required String currency,
    required String state,
    required DateTime createdAt,
  }) = _PaymentCaptureImpl;

  factory PaymentCapture.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentCapture(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      checkoutId: jsonSerialization['checkoutId'] as int,
      providerCaptureId: jsonSerialization['providerCaptureId'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      refundedMinor: jsonSerialization['refundedMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      state: jsonSerialization['state'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PaymentCaptureTable();

  static const db = PaymentCaptureRepository._();

  @override
  int? id;

  int restaurantId;

  int checkoutId;

  String providerCaptureId;

  int amountMinor;

  int refundedMinor;

  String currency;

  String state;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentCapture]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentCapture copyWith({
    int? id,
    int? restaurantId,
    int? checkoutId,
    String? providerCaptureId,
    int? amountMinor,
    int? refundedMinor,
    String? currency,
    String? state,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentCapture',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'checkoutId': checkoutId,
      'providerCaptureId': providerCaptureId,
      'amountMinor': amountMinor,
      'refundedMinor': refundedMinor,
      'currency': currency,
      'state': state,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentCaptureInclude include() {
    return PaymentCaptureInclude._();
  }

  static PaymentCaptureIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentCaptureTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentCaptureTable>? orderBy,
    _is.OrderByListBuilder<PaymentCaptureTable>? orderByList,
    PaymentCaptureInclude? include,
  }) {
    return PaymentCaptureIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentCapture.t),
      orderByList: orderByList?.call(PaymentCapture.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentCaptureImpl extends PaymentCapture {
  _PaymentCaptureImpl({
    int? id,
    required int restaurantId,
    required int checkoutId,
    required String providerCaptureId,
    required int amountMinor,
    required int refundedMinor,
    required String currency,
    required String state,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         checkoutId: checkoutId,
         providerCaptureId: providerCaptureId,
         amountMinor: amountMinor,
         refundedMinor: refundedMinor,
         currency: currency,
         state: state,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PaymentCapture]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentCapture copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? checkoutId,
    String? providerCaptureId,
    int? amountMinor,
    int? refundedMinor,
    String? currency,
    String? state,
    DateTime? createdAt,
  }) {
    return PaymentCapture(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      checkoutId: checkoutId ?? this.checkoutId,
      providerCaptureId: providerCaptureId ?? this.providerCaptureId,
      amountMinor: amountMinor ?? this.amountMinor,
      refundedMinor: refundedMinor ?? this.refundedMinor,
      currency: currency ?? this.currency,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentCaptureUpdateTable extends _is.UpdateTable<PaymentCaptureTable> {
  PaymentCaptureUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> checkoutId(int value) => _is.ColumnValue(
    table.checkoutId,
    value,
  );

  _is.ColumnValue<String, String> providerCaptureId(String value) =>
      _is.ColumnValue(
        table.providerCaptureId,
        value,
      );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> refundedMinor(int value) => _is.ColumnValue(
    table.refundedMinor,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
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

class PaymentCaptureTable extends _is.Table<int?> {
  PaymentCaptureTable({super.tableRelation})
    : super(tableName: 'raysto_payment_capture') {
    updateTable = PaymentCaptureUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    checkoutId = _is.ColumnInt(
      'checkoutId',
      this,
    );
    providerCaptureId = _is.ColumnString(
      'providerCaptureId',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    refundedMinor = _is.ColumnInt(
      'refundedMinor',
      this,
    );
    currency = _is.ColumnString(
      'currency',
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

  late final PaymentCaptureUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt checkoutId;

  late final _is.ColumnString providerCaptureId;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnInt refundedMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString state;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    checkoutId,
    providerCaptureId,
    amountMinor,
    refundedMinor,
    currency,
    state,
    createdAt,
  ];
}

class PaymentCaptureInclude extends _is.IncludeObject {
  PaymentCaptureInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentCapture.t;
}

class PaymentCaptureIncludeList extends _is.IncludeList {
  PaymentCaptureIncludeList._({
    _is.WhereExpressionBuilder<PaymentCaptureTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentCapture.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentCapture.t;
}

class PaymentCaptureRepository {
  const PaymentCaptureRepository._();

  /// Returns a list of [PaymentCapture]s matching the given query parameters.
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
  Future<List<PaymentCapture>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentCaptureTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentCaptureTable>? orderBy,
    _is.OrderByListBuilder<PaymentCaptureTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentCapture>(
      where: where?.call(PaymentCapture.t),
      orderBy: orderBy?.call(PaymentCapture.t),
      orderByList: orderByList?.call(PaymentCapture.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentCapture] matching the given query parameters.
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
  Future<PaymentCapture?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentCaptureTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentCaptureTable>? orderBy,
    _is.OrderByListBuilder<PaymentCaptureTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentCapture>(
      where: where?.call(PaymentCapture.t),
      orderBy: orderBy?.call(PaymentCapture.t),
      orderByList: orderByList?.call(PaymentCapture.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentCapture] by its [id] or null if no such row exists.
  Future<PaymentCapture?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentCapture>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentCapture]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentCapture]s will have their `id` fields set.
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
  Future<List<PaymentCapture>> insert(
    _is.DatabaseSession session,
    List<PaymentCapture> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentCapture>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentCapture] and returns the inserted row.
  ///
  /// The returned [PaymentCapture] will have its `id` field set.
  Future<PaymentCapture> insertRow(
    _is.DatabaseSession session,
    PaymentCapture row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentCapture>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentCapture]s in the list and returns the resulting rows.
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
  /// The returned [PaymentCapture]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentCapture>> upsert(
    _is.DatabaseSession session,
    List<PaymentCapture> rows, {
    required _is.ColumnSelections<PaymentCaptureTable> conflictColumns,
    _is.ColumnSelections<PaymentCaptureTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentCaptureTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentCapture>(
      rows,
      conflictColumns: conflictColumns(PaymentCapture.t),
      updateColumns: updateColumns?.call(PaymentCapture.t),
      updateWhere: updateWhere?.call(PaymentCapture.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentCapture] and returns the resulting row.
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
  /// The returned [PaymentCapture] will have its `id` field set.
  Future<PaymentCapture?> upsertRow(
    _is.DatabaseSession session,
    PaymentCapture row, {
    required _is.ColumnSelections<PaymentCaptureTable> conflictColumns,
    _is.ColumnSelections<PaymentCaptureTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentCaptureTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentCapture>(
      row,
      conflictColumns: conflictColumns(PaymentCapture.t),
      updateColumns: updateColumns?.call(PaymentCapture.t),
      updateWhere: updateWhere?.call(PaymentCapture.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentCapture]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentCapture>> update(
    _is.DatabaseSession session,
    List<PaymentCapture> rows, {
    _is.ColumnSelections<PaymentCaptureTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentCapture>(
      rows,
      columns: columns?.call(PaymentCapture.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentCapture]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentCapture> updateRow(
    _is.DatabaseSession session,
    PaymentCapture row, {
    _is.ColumnSelections<PaymentCaptureTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentCapture>(
      row,
      columns: columns?.call(PaymentCapture.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentCapture] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentCapture?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentCaptureUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentCapture>(
      id,
      columnValues: columnValues(PaymentCapture.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentCapture]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentCapture>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentCaptureUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PaymentCaptureTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentCaptureTable>? orderBy,
    _is.OrderByListBuilder<PaymentCaptureTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentCapture>(
      columnValues: columnValues(PaymentCapture.t.updateTable),
      where: where(PaymentCapture.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentCapture.t),
      orderByList: orderByList?.call(PaymentCapture.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentCapture]s in the list and returns the deleted rows.
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
  Future<List<PaymentCapture>> delete(
    _is.DatabaseSession session,
    List<PaymentCapture> rows, {
    _is.OrderByBuilder<PaymentCaptureTable>? orderBy,
    _is.OrderByListBuilder<PaymentCaptureTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentCapture>(
      rows,
      orderBy: orderBy?.call(PaymentCapture.t),
      orderByList: orderByList?.call(PaymentCapture.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentCapture].
  Future<PaymentCapture> deleteRow(
    _is.DatabaseSession session,
    PaymentCapture row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentCapture>(
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
  Future<List<PaymentCapture>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentCaptureTable> where,
    _is.OrderByBuilder<PaymentCaptureTable>? orderBy,
    _is.OrderByListBuilder<PaymentCaptureTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentCapture>(
      where: where(PaymentCapture.t),
      orderBy: orderBy?.call(PaymentCapture.t),
      orderByList: orderByList?.call(PaymentCapture.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentCaptureTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentCapture>(
      where: where?.call(PaymentCapture.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentCapture] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentCaptureTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentCapture>(
      where: where(PaymentCapture.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
