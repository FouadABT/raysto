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

abstract class BillingHistory
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  BillingHistory._({
    this.id,
    required this.restaurantId,
    required this.providerSubscriptionId,
    required this.eventKey,
    required this.status,
    required this.detailsJson,
    required this.createdAt,
  });

  factory BillingHistory({
    int? id,
    required int restaurantId,
    required String providerSubscriptionId,
    required String eventKey,
    required String status,
    required String detailsJson,
    required DateTime createdAt,
  }) = _BillingHistoryImpl;

  factory BillingHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillingHistory(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      providerSubscriptionId:
          jsonSerialization['providerSubscriptionId'] as String,
      eventKey: jsonSerialization['eventKey'] as String,
      status: jsonSerialization['status'] as String,
      detailsJson: jsonSerialization['detailsJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = BillingHistoryTable();

  static const db = BillingHistoryRepository._();

  @override
  int? id;

  int restaurantId;

  String providerSubscriptionId;

  String eventKey;

  String status;

  String detailsJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [BillingHistory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BillingHistory copyWith({
    int? id,
    int? restaurantId,
    String? providerSubscriptionId,
    String? eventKey,
    String? status,
    String? detailsJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillingHistory',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'providerSubscriptionId': providerSubscriptionId,
      'eventKey': eventKey,
      'status': status,
      'detailsJson': detailsJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static BillingHistoryInclude include() {
    return BillingHistoryInclude._();
  }

  static BillingHistoryIncludeList includeList({
    _is.WhereExpressionBuilder<BillingHistoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillingHistoryTable>? orderBy,
    _is.OrderByListBuilder<BillingHistoryTable>? orderByList,
    BillingHistoryInclude? include,
  }) {
    return BillingHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillingHistory.t),
      orderByList: orderByList?.call(BillingHistory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillingHistoryImpl extends BillingHistory {
  _BillingHistoryImpl({
    int? id,
    required int restaurantId,
    required String providerSubscriptionId,
    required String eventKey,
    required String status,
    required String detailsJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         providerSubscriptionId: providerSubscriptionId,
         eventKey: eventKey,
         status: status,
         detailsJson: detailsJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [BillingHistory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BillingHistory copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? providerSubscriptionId,
    String? eventKey,
    String? status,
    String? detailsJson,
    DateTime? createdAt,
  }) {
    return BillingHistory(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      providerSubscriptionId:
          providerSubscriptionId ?? this.providerSubscriptionId,
      eventKey: eventKey ?? this.eventKey,
      status: status ?? this.status,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BillingHistoryUpdateTable extends _is.UpdateTable<BillingHistoryTable> {
  BillingHistoryUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> providerSubscriptionId(String value) =>
      _is.ColumnValue(
        table.providerSubscriptionId,
        value,
      );

  _is.ColumnValue<String, String> eventKey(String value) => _is.ColumnValue(
    table.eventKey,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> detailsJson(String value) => _is.ColumnValue(
    table.detailsJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class BillingHistoryTable extends _is.Table<int?> {
  BillingHistoryTable({super.tableRelation})
    : super(tableName: 'raysto_billing_history') {
    updateTable = BillingHistoryUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    providerSubscriptionId = _is.ColumnString(
      'providerSubscriptionId',
      this,
    );
    eventKey = _is.ColumnString(
      'eventKey',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    detailsJson = _is.ColumnString(
      'detailsJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final BillingHistoryUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString providerSubscriptionId;

  late final _is.ColumnString eventKey;

  late final _is.ColumnString status;

  late final _is.ColumnString detailsJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    providerSubscriptionId,
    eventKey,
    status,
    detailsJson,
    createdAt,
  ];
}

class BillingHistoryInclude extends _is.IncludeObject {
  BillingHistoryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => BillingHistory.t;
}

class BillingHistoryIncludeList extends _is.IncludeList {
  BillingHistoryIncludeList._({
    _is.WhereExpressionBuilder<BillingHistoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BillingHistory.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => BillingHistory.t;
}

class BillingHistoryRepository {
  const BillingHistoryRepository._();

  /// Returns a list of [BillingHistory]s matching the given query parameters.
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
  Future<List<BillingHistory>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillingHistoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillingHistoryTable>? orderBy,
    _is.OrderByListBuilder<BillingHistoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BillingHistory>(
      where: where?.call(BillingHistory.t),
      orderBy: orderBy?.call(BillingHistory.t),
      orderByList: orderByList?.call(BillingHistory.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BillingHistory] matching the given query parameters.
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
  Future<BillingHistory?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillingHistoryTable>? where,
    int? offset,
    _is.OrderByBuilder<BillingHistoryTable>? orderBy,
    _is.OrderByListBuilder<BillingHistoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BillingHistory>(
      where: where?.call(BillingHistory.t),
      orderBy: orderBy?.call(BillingHistory.t),
      orderByList: orderByList?.call(BillingHistory.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BillingHistory] by its [id] or null if no such row exists.
  Future<BillingHistory?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BillingHistory>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BillingHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [BillingHistory]s will have their `id` fields set.
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
  Future<List<BillingHistory>> insert(
    _is.DatabaseSession session,
    List<BillingHistory> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BillingHistory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BillingHistory] and returns the inserted row.
  ///
  /// The returned [BillingHistory] will have its `id` field set.
  Future<BillingHistory> insertRow(
    _is.DatabaseSession session,
    BillingHistory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BillingHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BillingHistory]s in the list and returns the resulting rows.
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
  /// The returned [BillingHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillingHistory>> upsert(
    _is.DatabaseSession session,
    List<BillingHistory> rows, {
    required _is.ColumnSelections<BillingHistoryTable> conflictColumns,
    _is.ColumnSelections<BillingHistoryTable>? updateColumns,
    _is.WhereExpressionBuilder<BillingHistoryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BillingHistory>(
      rows,
      conflictColumns: conflictColumns(BillingHistory.t),
      updateColumns: updateColumns?.call(BillingHistory.t),
      updateWhere: updateWhere?.call(BillingHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BillingHistory] and returns the resulting row.
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
  /// The returned [BillingHistory] will have its `id` field set.
  Future<BillingHistory?> upsertRow(
    _is.DatabaseSession session,
    BillingHistory row, {
    required _is.ColumnSelections<BillingHistoryTable> conflictColumns,
    _is.ColumnSelections<BillingHistoryTable>? updateColumns,
    _is.WhereExpressionBuilder<BillingHistoryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BillingHistory>(
      row,
      conflictColumns: conflictColumns(BillingHistory.t),
      updateColumns: updateColumns?.call(BillingHistory.t),
      updateWhere: updateWhere?.call(BillingHistory.t),
      transaction: transaction,
    );
  }

  /// Updates all [BillingHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillingHistory>> update(
    _is.DatabaseSession session,
    List<BillingHistory> rows, {
    _is.ColumnSelections<BillingHistoryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BillingHistory>(
      rows,
      columns: columns?.call(BillingHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BillingHistory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BillingHistory> updateRow(
    _is.DatabaseSession session,
    BillingHistory row, {
    _is.ColumnSelections<BillingHistoryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BillingHistory>(
      row,
      columns: columns?.call(BillingHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BillingHistory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BillingHistory?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BillingHistoryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BillingHistory>(
      id,
      columnValues: columnValues(BillingHistory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BillingHistory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillingHistory>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BillingHistoryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BillingHistoryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillingHistoryTable>? orderBy,
    _is.OrderByListBuilder<BillingHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BillingHistory>(
      columnValues: columnValues(BillingHistory.t.updateTable),
      where: where(BillingHistory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillingHistory.t),
      orderByList: orderByList?.call(BillingHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BillingHistory]s in the list and returns the deleted rows.
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
  Future<List<BillingHistory>> delete(
    _is.DatabaseSession session,
    List<BillingHistory> rows, {
    _is.OrderByBuilder<BillingHistoryTable>? orderBy,
    _is.OrderByListBuilder<BillingHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BillingHistory>(
      rows,
      orderBy: orderBy?.call(BillingHistory.t),
      orderByList: orderByList?.call(BillingHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BillingHistory].
  Future<BillingHistory> deleteRow(
    _is.DatabaseSession session,
    BillingHistory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BillingHistory>(
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
  Future<List<BillingHistory>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillingHistoryTable> where,
    _is.OrderByBuilder<BillingHistoryTable>? orderBy,
    _is.OrderByListBuilder<BillingHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BillingHistory>(
      where: where(BillingHistory.t),
      orderBy: orderBy?.call(BillingHistory.t),
      orderByList: orderByList?.call(BillingHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillingHistoryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BillingHistory>(
      where: where?.call(BillingHistory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BillingHistory] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillingHistoryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BillingHistory>(
      where: where(BillingHistory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
