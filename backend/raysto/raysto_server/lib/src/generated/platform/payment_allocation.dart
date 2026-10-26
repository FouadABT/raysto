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

abstract class PaymentAllocation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentAllocation._({
    this.id,
    required this.restaurantId,
    required this.checkoutId,
    required this.chargeId,
    required this.amountMinor,
    required this.foodNetMinor,
    required this.refundedMinor,
    required this.state,
  });

  factory PaymentAllocation({
    int? id,
    required int restaurantId,
    required int checkoutId,
    required int chargeId,
    required int amountMinor,
    required int foodNetMinor,
    required int refundedMinor,
    required String state,
  }) = _PaymentAllocationImpl;

  factory PaymentAllocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentAllocation(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      checkoutId: jsonSerialization['checkoutId'] as int,
      chargeId: jsonSerialization['chargeId'] as int,
      amountMinor: jsonSerialization['amountMinor'] as int,
      foodNetMinor: jsonSerialization['foodNetMinor'] as int,
      refundedMinor: jsonSerialization['refundedMinor'] as int,
      state: jsonSerialization['state'] as String,
    );
  }

  static final t = PaymentAllocationTable();

  static const db = PaymentAllocationRepository._();

  @override
  int? id;

  int restaurantId;

  int checkoutId;

  int chargeId;

  int amountMinor;

  int foodNetMinor;

  int refundedMinor;

  String state;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentAllocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentAllocation copyWith({
    int? id,
    int? restaurantId,
    int? checkoutId,
    int? chargeId,
    int? amountMinor,
    int? foodNetMinor,
    int? refundedMinor,
    String? state,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentAllocation',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'checkoutId': checkoutId,
      'chargeId': chargeId,
      'amountMinor': amountMinor,
      'foodNetMinor': foodNetMinor,
      'refundedMinor': refundedMinor,
      'state': state,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentAllocationInclude include() {
    return PaymentAllocationInclude._();
  }

  static PaymentAllocationIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<PaymentAllocationTable>? orderByList,
    PaymentAllocationInclude? include,
  }) {
    return PaymentAllocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentAllocation.t),
      orderByList: orderByList?.call(PaymentAllocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentAllocationImpl extends PaymentAllocation {
  _PaymentAllocationImpl({
    int? id,
    required int restaurantId,
    required int checkoutId,
    required int chargeId,
    required int amountMinor,
    required int foodNetMinor,
    required int refundedMinor,
    required String state,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         checkoutId: checkoutId,
         chargeId: chargeId,
         amountMinor: amountMinor,
         foodNetMinor: foodNetMinor,
         refundedMinor: refundedMinor,
         state: state,
       );

  /// Returns a shallow copy of this [PaymentAllocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentAllocation copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? checkoutId,
    int? chargeId,
    int? amountMinor,
    int? foodNetMinor,
    int? refundedMinor,
    String? state,
  }) {
    return PaymentAllocation(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      checkoutId: checkoutId ?? this.checkoutId,
      chargeId: chargeId ?? this.chargeId,
      amountMinor: amountMinor ?? this.amountMinor,
      foodNetMinor: foodNetMinor ?? this.foodNetMinor,
      refundedMinor: refundedMinor ?? this.refundedMinor,
      state: state ?? this.state,
    );
  }
}

class PaymentAllocationUpdateTable
    extends _is.UpdateTable<PaymentAllocationTable> {
  PaymentAllocationUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> checkoutId(int value) => _is.ColumnValue(
    table.checkoutId,
    value,
  );

  _is.ColumnValue<int, int> chargeId(int value) => _is.ColumnValue(
    table.chargeId,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> foodNetMinor(int value) => _is.ColumnValue(
    table.foodNetMinor,
    value,
  );

  _is.ColumnValue<int, int> refundedMinor(int value) => _is.ColumnValue(
    table.refundedMinor,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );
}

class PaymentAllocationTable extends _is.Table<int?> {
  PaymentAllocationTable({super.tableRelation})
    : super(tableName: 'raysto_payment_allocation') {
    updateTable = PaymentAllocationUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    checkoutId = _is.ColumnInt(
      'checkoutId',
      this,
    );
    chargeId = _is.ColumnInt(
      'chargeId',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    foodNetMinor = _is.ColumnInt(
      'foodNetMinor',
      this,
    );
    refundedMinor = _is.ColumnInt(
      'refundedMinor',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
  }

  late final PaymentAllocationUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt checkoutId;

  late final _is.ColumnInt chargeId;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnInt foodNetMinor;

  late final _is.ColumnInt refundedMinor;

  late final _is.ColumnString state;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    checkoutId,
    chargeId,
    amountMinor,
    foodNetMinor,
    refundedMinor,
    state,
  ];
}

class PaymentAllocationInclude extends _is.IncludeObject {
  PaymentAllocationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentAllocation.t;
}

class PaymentAllocationIncludeList extends _is.IncludeList {
  PaymentAllocationIncludeList._({
    _is.WhereExpressionBuilder<PaymentAllocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentAllocation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentAllocation.t;
}

class PaymentAllocationRepository {
  const PaymentAllocationRepository._();

  /// Returns a list of [PaymentAllocation]s matching the given query parameters.
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
  Future<List<PaymentAllocation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<PaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentAllocation>(
      where: where?.call(PaymentAllocation.t),
      orderBy: orderBy?.call(PaymentAllocation.t),
      orderByList: orderByList?.call(PaymentAllocation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentAllocation] matching the given query parameters.
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
  Future<PaymentAllocation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentAllocationTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<PaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentAllocation>(
      where: where?.call(PaymentAllocation.t),
      orderBy: orderBy?.call(PaymentAllocation.t),
      orderByList: orderByList?.call(PaymentAllocation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentAllocation] by its [id] or null if no such row exists.
  Future<PaymentAllocation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentAllocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentAllocation]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentAllocation]s will have their `id` fields set.
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
  Future<List<PaymentAllocation>> insert(
    _is.DatabaseSession session,
    List<PaymentAllocation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentAllocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentAllocation] and returns the inserted row.
  ///
  /// The returned [PaymentAllocation] will have its `id` field set.
  Future<PaymentAllocation> insertRow(
    _is.DatabaseSession session,
    PaymentAllocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentAllocation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentAllocation]s in the list and returns the resulting rows.
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
  /// The returned [PaymentAllocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentAllocation>> upsert(
    _is.DatabaseSession session,
    List<PaymentAllocation> rows, {
    required _is.ColumnSelections<PaymentAllocationTable> conflictColumns,
    _is.ColumnSelections<PaymentAllocationTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentAllocationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentAllocation>(
      rows,
      conflictColumns: conflictColumns(PaymentAllocation.t),
      updateColumns: updateColumns?.call(PaymentAllocation.t),
      updateWhere: updateWhere?.call(PaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentAllocation] and returns the resulting row.
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
  /// The returned [PaymentAllocation] will have its `id` field set.
  Future<PaymentAllocation?> upsertRow(
    _is.DatabaseSession session,
    PaymentAllocation row, {
    required _is.ColumnSelections<PaymentAllocationTable> conflictColumns,
    _is.ColumnSelections<PaymentAllocationTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentAllocationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentAllocation>(
      row,
      conflictColumns: conflictColumns(PaymentAllocation.t),
      updateColumns: updateColumns?.call(PaymentAllocation.t),
      updateWhere: updateWhere?.call(PaymentAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentAllocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentAllocation>> update(
    _is.DatabaseSession session,
    List<PaymentAllocation> rows, {
    _is.ColumnSelections<PaymentAllocationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentAllocation>(
      rows,
      columns: columns?.call(PaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentAllocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentAllocation> updateRow(
    _is.DatabaseSession session,
    PaymentAllocation row, {
    _is.ColumnSelections<PaymentAllocationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentAllocation>(
      row,
      columns: columns?.call(PaymentAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentAllocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentAllocation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentAllocationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentAllocation>(
      id,
      columnValues: columnValues(PaymentAllocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentAllocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentAllocation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentAllocationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PaymentAllocationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<PaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentAllocation>(
      columnValues: columnValues(PaymentAllocation.t.updateTable),
      where: where(PaymentAllocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentAllocation.t),
      orderByList: orderByList?.call(PaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentAllocation]s in the list and returns the deleted rows.
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
  Future<List<PaymentAllocation>> delete(
    _is.DatabaseSession session,
    List<PaymentAllocation> rows, {
    _is.OrderByBuilder<PaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<PaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentAllocation>(
      rows,
      orderBy: orderBy?.call(PaymentAllocation.t),
      orderByList: orderByList?.call(PaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentAllocation].
  Future<PaymentAllocation> deleteRow(
    _is.DatabaseSession session,
    PaymentAllocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentAllocation>(
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
  Future<List<PaymentAllocation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentAllocationTable> where,
    _is.OrderByBuilder<PaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<PaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentAllocation>(
      where: where(PaymentAllocation.t),
      orderBy: orderBy?.call(PaymentAllocation.t),
      orderByList: orderByList?.call(PaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentAllocationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentAllocation>(
      where: where?.call(PaymentAllocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentAllocation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentAllocationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentAllocation>(
      where: where(PaymentAllocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
