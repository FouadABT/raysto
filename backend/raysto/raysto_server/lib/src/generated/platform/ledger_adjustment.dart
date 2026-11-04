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

abstract class LedgerAdjustment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  LedgerAdjustment._({
    this.id,
    required this.restaurantId,
    required this.at,
    required this.debitAccount,
    required this.creditAccount,
    required this.amountMinor,
    required this.currency,
    required this.reason,
    required this.userId,
    required this.createdAt,
  });

  factory LedgerAdjustment({
    int? id,
    required int restaurantId,
    required DateTime at,
    required String debitAccount,
    required String creditAccount,
    required int amountMinor,
    required String currency,
    required String reason,
    required String userId,
    required DateTime createdAt,
  }) = _LedgerAdjustmentImpl;

  factory LedgerAdjustment.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerAdjustment(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      at: _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      debitAccount: jsonSerialization['debitAccount'] as String,
      creditAccount: jsonSerialization['creditAccount'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      reason: jsonSerialization['reason'] as String,
      userId: jsonSerialization['userId'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = LedgerAdjustmentTable();

  static const db = LedgerAdjustmentRepository._();

  @override
  int? id;

  int restaurantId;

  DateTime at;

  String debitAccount;

  String creditAccount;

  int amountMinor;

  String currency;

  String reason;

  String userId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [LedgerAdjustment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LedgerAdjustment copyWith({
    int? id,
    int? restaurantId,
    DateTime? at,
    String? debitAccount,
    String? creditAccount,
    int? amountMinor,
    String? currency,
    String? reason,
    String? userId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerAdjustment',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'at': at.toJson(),
      'debitAccount': debitAccount,
      'creditAccount': creditAccount,
      'amountMinor': amountMinor,
      'currency': currency,
      'reason': reason,
      'userId': userId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static LedgerAdjustmentInclude include() {
    return LedgerAdjustmentInclude._();
  }

  static LedgerAdjustmentIncludeList includeList({
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<LedgerAdjustmentTable>? orderByList,
    LedgerAdjustmentInclude? include,
  }) {
    return LedgerAdjustmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerAdjustment.t),
      orderByList: orderByList?.call(LedgerAdjustment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LedgerAdjustmentImpl extends LedgerAdjustment {
  _LedgerAdjustmentImpl({
    int? id,
    required int restaurantId,
    required DateTime at,
    required String debitAccount,
    required String creditAccount,
    required int amountMinor,
    required String currency,
    required String reason,
    required String userId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         at: at,
         debitAccount: debitAccount,
         creditAccount: creditAccount,
         amountMinor: amountMinor,
         currency: currency,
         reason: reason,
         userId: userId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [LedgerAdjustment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LedgerAdjustment copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    DateTime? at,
    String? debitAccount,
    String? creditAccount,
    int? amountMinor,
    String? currency,
    String? reason,
    String? userId,
    DateTime? createdAt,
  }) {
    return LedgerAdjustment(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      at: at ?? this.at,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LedgerAdjustmentUpdateTable
    extends _is.UpdateTable<LedgerAdjustmentTable> {
  LedgerAdjustmentUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> at(DateTime value) => _is.ColumnValue(
    table.at,
    value,
  );

  _is.ColumnValue<String, String> debitAccount(String value) => _is.ColumnValue(
    table.debitAccount,
    value,
  );

  _is.ColumnValue<String, String> creditAccount(String value) =>
      _is.ColumnValue(
        table.creditAccount,
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

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class LedgerAdjustmentTable extends _is.Table<int?> {
  LedgerAdjustmentTable({super.tableRelation})
    : super(tableName: 'raysto_ledger_adjustment') {
    updateTable = LedgerAdjustmentUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    at = _is.ColumnDateTime(
      'at',
      this,
    );
    debitAccount = _is.ColumnString(
      'debitAccount',
      this,
    );
    creditAccount = _is.ColumnString(
      'creditAccount',
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
    reason = _is.ColumnString(
      'reason',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final LedgerAdjustmentUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnDateTime at;

  late final _is.ColumnString debitAccount;

  late final _is.ColumnString creditAccount;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString reason;

  late final _is.ColumnString userId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    at,
    debitAccount,
    creditAccount,
    amountMinor,
    currency,
    reason,
    userId,
    createdAt,
  ];
}

class LedgerAdjustmentInclude extends _is.IncludeObject {
  LedgerAdjustmentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => LedgerAdjustment.t;
}

class LedgerAdjustmentIncludeList extends _is.IncludeList {
  LedgerAdjustmentIncludeList._({
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LedgerAdjustment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => LedgerAdjustment.t;
}

class LedgerAdjustmentRepository {
  const LedgerAdjustmentRepository._();

  /// Returns a list of [LedgerAdjustment]s matching the given query parameters.
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
  Future<List<LedgerAdjustment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<LedgerAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LedgerAdjustment>(
      where: where?.call(LedgerAdjustment.t),
      orderBy: orderBy?.call(LedgerAdjustment.t),
      orderByList: orderByList?.call(LedgerAdjustment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [LedgerAdjustment] matching the given query parameters.
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
  Future<LedgerAdjustment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? where,
    int? offset,
    _is.OrderByBuilder<LedgerAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<LedgerAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LedgerAdjustment>(
      where: where?.call(LedgerAdjustment.t),
      orderBy: orderBy?.call(LedgerAdjustment.t),
      orderByList: orderByList?.call(LedgerAdjustment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LedgerAdjustment] by its [id] or null if no such row exists.
  Future<LedgerAdjustment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LedgerAdjustment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LedgerAdjustment]s in the list and returns the inserted rows.
  ///
  /// The returned [LedgerAdjustment]s will have their `id` fields set.
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
  Future<List<LedgerAdjustment>> insert(
    _is.DatabaseSession session,
    List<LedgerAdjustment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LedgerAdjustment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LedgerAdjustment] and returns the inserted row.
  ///
  /// The returned [LedgerAdjustment] will have its `id` field set.
  Future<LedgerAdjustment> insertRow(
    _is.DatabaseSession session,
    LedgerAdjustment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LedgerAdjustment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LedgerAdjustment]s in the list and returns the resulting rows.
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
  /// The returned [LedgerAdjustment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAdjustment>> upsert(
    _is.DatabaseSession session,
    List<LedgerAdjustment> rows, {
    required _is.ColumnSelections<LedgerAdjustmentTable> conflictColumns,
    _is.ColumnSelections<LedgerAdjustmentTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LedgerAdjustment>(
      rows,
      conflictColumns: conflictColumns(LedgerAdjustment.t),
      updateColumns: updateColumns?.call(LedgerAdjustment.t),
      updateWhere: updateWhere?.call(LedgerAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LedgerAdjustment] and returns the resulting row.
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
  /// The returned [LedgerAdjustment] will have its `id` field set.
  Future<LedgerAdjustment?> upsertRow(
    _is.DatabaseSession session,
    LedgerAdjustment row, {
    required _is.ColumnSelections<LedgerAdjustmentTable> conflictColumns,
    _is.ColumnSelections<LedgerAdjustmentTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LedgerAdjustment>(
      row,
      conflictColumns: conflictColumns(LedgerAdjustment.t),
      updateColumns: updateColumns?.call(LedgerAdjustment.t),
      updateWhere: updateWhere?.call(LedgerAdjustment.t),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerAdjustment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAdjustment>> update(
    _is.DatabaseSession session,
    List<LedgerAdjustment> rows, {
    _is.ColumnSelections<LedgerAdjustmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LedgerAdjustment>(
      rows,
      columns: columns?.call(LedgerAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LedgerAdjustment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LedgerAdjustment> updateRow(
    _is.DatabaseSession session,
    LedgerAdjustment row, {
    _is.ColumnSelections<LedgerAdjustmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LedgerAdjustment>(
      row,
      columns: columns?.call(LedgerAdjustment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LedgerAdjustment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LedgerAdjustment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<LedgerAdjustmentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LedgerAdjustment>(
      id,
      columnValues: columnValues(LedgerAdjustment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerAdjustment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAdjustment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LedgerAdjustmentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<LedgerAdjustmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<LedgerAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LedgerAdjustment>(
      columnValues: columnValues(LedgerAdjustment.t.updateTable),
      where: where(LedgerAdjustment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerAdjustment.t),
      orderByList: orderByList?.call(LedgerAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LedgerAdjustment]s in the list and returns the deleted rows.
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
  Future<List<LedgerAdjustment>> delete(
    _is.DatabaseSession session,
    List<LedgerAdjustment> rows, {
    _is.OrderByBuilder<LedgerAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<LedgerAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LedgerAdjustment>(
      rows,
      orderBy: orderBy?.call(LedgerAdjustment.t),
      orderByList: orderByList?.call(LedgerAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LedgerAdjustment].
  Future<LedgerAdjustment> deleteRow(
    _is.DatabaseSession session,
    LedgerAdjustment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LedgerAdjustment>(
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
  Future<List<LedgerAdjustment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerAdjustmentTable> where,
    _is.OrderByBuilder<LedgerAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<LedgerAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LedgerAdjustment>(
      where: where(LedgerAdjustment.t),
      orderBy: orderBy?.call(LedgerAdjustment.t),
      orderByList: orderByList?.call(LedgerAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAdjustmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LedgerAdjustment>(
      where: where?.call(LedgerAdjustment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LedgerAdjustment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerAdjustmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LedgerAdjustment>(
      where: where(LedgerAdjustment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
