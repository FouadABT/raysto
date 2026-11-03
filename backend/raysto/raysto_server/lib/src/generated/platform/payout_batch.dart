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

abstract class PayoutBatch
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PayoutBatch._({
    this.id,
    required this.restaurantId,
    required this.kind,
    required this.periodFrom,
    required this.periodTo,
    required this.totalMinor,
    required this.currency,
    required this.state,
    this.providerBatchId,
    required this.requestKey,
    this.taskId,
    required this.summaryJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PayoutBatch({
    int? id,
    required int restaurantId,
    required String kind,
    required DateTime periodFrom,
    required DateTime periodTo,
    required int totalMinor,
    required String currency,
    required String state,
    String? providerBatchId,
    required String requestKey,
    int? taskId,
    required String summaryJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PayoutBatchImpl;

  factory PayoutBatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return PayoutBatch(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      kind: jsonSerialization['kind'] as String,
      periodFrom: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['periodFrom'],
      ),
      periodTo: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['periodTo'],
      ),
      totalMinor: jsonSerialization['totalMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      state: jsonSerialization['state'] as String,
      providerBatchId: jsonSerialization['providerBatchId'] as String?,
      requestKey: jsonSerialization['requestKey'] as String,
      taskId: jsonSerialization['taskId'] as int?,
      summaryJson: jsonSerialization['summaryJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PayoutBatchTable();

  static const db = PayoutBatchRepository._();

  @override
  int? id;

  int restaurantId;

  String kind;

  DateTime periodFrom;

  DateTime periodTo;

  int totalMinor;

  String currency;

  String state;

  String? providerBatchId;

  String requestKey;

  int? taskId;

  String summaryJson;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PayoutBatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PayoutBatch copyWith({
    int? id,
    int? restaurantId,
    String? kind,
    DateTime? periodFrom,
    DateTime? periodTo,
    int? totalMinor,
    String? currency,
    String? state,
    String? providerBatchId,
    String? requestKey,
    int? taskId,
    String? summaryJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PayoutBatch',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'kind': kind,
      'periodFrom': periodFrom.toJson(),
      'periodTo': periodTo.toJson(),
      'totalMinor': totalMinor,
      'currency': currency,
      'state': state,
      if (providerBatchId != null) 'providerBatchId': providerBatchId,
      'requestKey': requestKey,
      if (taskId != null) 'taskId': taskId,
      'summaryJson': summaryJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PayoutBatchInclude include() {
    return PayoutBatchInclude._();
  }

  static PayoutBatchIncludeList includeList({
    _is.WhereExpressionBuilder<PayoutBatchTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayoutBatchTable>? orderBy,
    _is.OrderByListBuilder<PayoutBatchTable>? orderByList,
    PayoutBatchInclude? include,
  }) {
    return PayoutBatchIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PayoutBatch.t),
      orderByList: orderByList?.call(PayoutBatch.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PayoutBatchImpl extends PayoutBatch {
  _PayoutBatchImpl({
    int? id,
    required int restaurantId,
    required String kind,
    required DateTime periodFrom,
    required DateTime periodTo,
    required int totalMinor,
    required String currency,
    required String state,
    String? providerBatchId,
    required String requestKey,
    int? taskId,
    required String summaryJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         kind: kind,
         periodFrom: periodFrom,
         periodTo: periodTo,
         totalMinor: totalMinor,
         currency: currency,
         state: state,
         providerBatchId: providerBatchId,
         requestKey: requestKey,
         taskId: taskId,
         summaryJson: summaryJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PayoutBatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PayoutBatch copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? kind,
    DateTime? periodFrom,
    DateTime? periodTo,
    int? totalMinor,
    String? currency,
    String? state,
    Object? providerBatchId = _Undefined,
    String? requestKey,
    Object? taskId = _Undefined,
    String? summaryJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PayoutBatch(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      kind: kind ?? this.kind,
      periodFrom: periodFrom ?? this.periodFrom,
      periodTo: periodTo ?? this.periodTo,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      state: state ?? this.state,
      providerBatchId: providerBatchId is String?
          ? providerBatchId
          : this.providerBatchId,
      requestKey: requestKey ?? this.requestKey,
      taskId: taskId is int? ? taskId : this.taskId,
      summaryJson: summaryJson ?? this.summaryJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PayoutBatchUpdateTable extends _is.UpdateTable<PayoutBatchTable> {
  PayoutBatchUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> periodFrom(DateTime value) =>
      _is.ColumnValue(
        table.periodFrom,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> periodTo(DateTime value) =>
      _is.ColumnValue(
        table.periodTo,
        value,
      );

  _is.ColumnValue<int, int> totalMinor(int value) => _is.ColumnValue(
    table.totalMinor,
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

  _is.ColumnValue<String, String> providerBatchId(String? value) =>
      _is.ColumnValue(
        table.providerBatchId,
        value,
      );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
    value,
  );

  _is.ColumnValue<String, String> summaryJson(String value) => _is.ColumnValue(
    table.summaryJson,
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

class PayoutBatchTable extends _is.Table<int?> {
  PayoutBatchTable({super.tableRelation})
    : super(tableName: 'raysto_payout_batch') {
    updateTable = PayoutBatchUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    periodFrom = _is.ColumnDateTime(
      'periodFrom',
      this,
    );
    periodTo = _is.ColumnDateTime(
      'periodTo',
      this,
    );
    totalMinor = _is.ColumnInt(
      'totalMinor',
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
    providerBatchId = _is.ColumnString(
      'providerBatchId',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
      this,
    );
    summaryJson = _is.ColumnString(
      'summaryJson',
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

  late final PayoutBatchUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString kind;

  late final _is.ColumnDateTime periodFrom;

  late final _is.ColumnDateTime periodTo;

  late final _is.ColumnInt totalMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString state;

  late final _is.ColumnString providerBatchId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnInt taskId;

  late final _is.ColumnString summaryJson;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    kind,
    periodFrom,
    periodTo,
    totalMinor,
    currency,
    state,
    providerBatchId,
    requestKey,
    taskId,
    summaryJson,
    createdAt,
    updatedAt,
  ];
}

class PayoutBatchInclude extends _is.IncludeObject {
  PayoutBatchInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PayoutBatch.t;
}

class PayoutBatchIncludeList extends _is.IncludeList {
  PayoutBatchIncludeList._({
    _is.WhereExpressionBuilder<PayoutBatchTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PayoutBatch.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PayoutBatch.t;
}

class PayoutBatchRepository {
  const PayoutBatchRepository._();

  /// Returns a list of [PayoutBatch]s matching the given query parameters.
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
  Future<List<PayoutBatch>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayoutBatchTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayoutBatchTable>? orderBy,
    _is.OrderByListBuilder<PayoutBatchTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PayoutBatch>(
      where: where?.call(PayoutBatch.t),
      orderBy: orderBy?.call(PayoutBatch.t),
      orderByList: orderByList?.call(PayoutBatch.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PayoutBatch] matching the given query parameters.
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
  Future<PayoutBatch?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayoutBatchTable>? where,
    int? offset,
    _is.OrderByBuilder<PayoutBatchTable>? orderBy,
    _is.OrderByListBuilder<PayoutBatchTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PayoutBatch>(
      where: where?.call(PayoutBatch.t),
      orderBy: orderBy?.call(PayoutBatch.t),
      orderByList: orderByList?.call(PayoutBatch.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PayoutBatch] by its [id] or null if no such row exists.
  Future<PayoutBatch?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PayoutBatch>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PayoutBatch]s in the list and returns the inserted rows.
  ///
  /// The returned [PayoutBatch]s will have their `id` fields set.
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
  Future<List<PayoutBatch>> insert(
    _is.DatabaseSession session,
    List<PayoutBatch> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PayoutBatch>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PayoutBatch] and returns the inserted row.
  ///
  /// The returned [PayoutBatch] will have its `id` field set.
  Future<PayoutBatch> insertRow(
    _is.DatabaseSession session,
    PayoutBatch row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PayoutBatch>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PayoutBatch]s in the list and returns the resulting rows.
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
  /// The returned [PayoutBatch]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PayoutBatch>> upsert(
    _is.DatabaseSession session,
    List<PayoutBatch> rows, {
    required _is.ColumnSelections<PayoutBatchTable> conflictColumns,
    _is.ColumnSelections<PayoutBatchTable>? updateColumns,
    _is.WhereExpressionBuilder<PayoutBatchTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PayoutBatch>(
      rows,
      conflictColumns: conflictColumns(PayoutBatch.t),
      updateColumns: updateColumns?.call(PayoutBatch.t),
      updateWhere: updateWhere?.call(PayoutBatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PayoutBatch] and returns the resulting row.
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
  /// The returned [PayoutBatch] will have its `id` field set.
  Future<PayoutBatch?> upsertRow(
    _is.DatabaseSession session,
    PayoutBatch row, {
    required _is.ColumnSelections<PayoutBatchTable> conflictColumns,
    _is.ColumnSelections<PayoutBatchTable>? updateColumns,
    _is.WhereExpressionBuilder<PayoutBatchTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PayoutBatch>(
      row,
      conflictColumns: conflictColumns(PayoutBatch.t),
      updateColumns: updateColumns?.call(PayoutBatch.t),
      updateWhere: updateWhere?.call(PayoutBatch.t),
      transaction: transaction,
    );
  }

  /// Updates all [PayoutBatch]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PayoutBatch>> update(
    _is.DatabaseSession session,
    List<PayoutBatch> rows, {
    _is.ColumnSelections<PayoutBatchTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PayoutBatch>(
      rows,
      columns: columns?.call(PayoutBatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PayoutBatch]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PayoutBatch> updateRow(
    _is.DatabaseSession session,
    PayoutBatch row, {
    _is.ColumnSelections<PayoutBatchTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PayoutBatch>(
      row,
      columns: columns?.call(PayoutBatch.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PayoutBatch] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PayoutBatch?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PayoutBatchUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PayoutBatch>(
      id,
      columnValues: columnValues(PayoutBatch.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PayoutBatch]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PayoutBatch>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PayoutBatchUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PayoutBatchTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayoutBatchTable>? orderBy,
    _is.OrderByListBuilder<PayoutBatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PayoutBatch>(
      columnValues: columnValues(PayoutBatch.t.updateTable),
      where: where(PayoutBatch.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PayoutBatch.t),
      orderByList: orderByList?.call(PayoutBatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PayoutBatch]s in the list and returns the deleted rows.
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
  Future<List<PayoutBatch>> delete(
    _is.DatabaseSession session,
    List<PayoutBatch> rows, {
    _is.OrderByBuilder<PayoutBatchTable>? orderBy,
    _is.OrderByListBuilder<PayoutBatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PayoutBatch>(
      rows,
      orderBy: orderBy?.call(PayoutBatch.t),
      orderByList: orderByList?.call(PayoutBatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PayoutBatch].
  Future<PayoutBatch> deleteRow(
    _is.DatabaseSession session,
    PayoutBatch row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PayoutBatch>(
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
  Future<List<PayoutBatch>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PayoutBatchTable> where,
    _is.OrderByBuilder<PayoutBatchTable>? orderBy,
    _is.OrderByListBuilder<PayoutBatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PayoutBatch>(
      where: where(PayoutBatch.t),
      orderBy: orderBy?.call(PayoutBatch.t),
      orderByList: orderByList?.call(PayoutBatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayoutBatchTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PayoutBatch>(
      where: where?.call(PayoutBatch.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PayoutBatch] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PayoutBatchTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PayoutBatch>(
      where: where(PayoutBatch.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
