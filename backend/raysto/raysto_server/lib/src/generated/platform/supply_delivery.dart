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

abstract class SupplyDelivery
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SupplyDelivery._({
    this.id,
    required this.restaurantId,
    this.supplierId,
    required this.mediaId,
    required this.linesJson,
    required this.totalMinor,
    required this.currency,
    required this.state,
    this.payoutBatchId,
    this.taskId,
    required this.version,
    required this.createdAt,
  });

  factory SupplyDelivery({
    int? id,
    required int restaurantId,
    int? supplierId,
    required int mediaId,
    required String linesJson,
    required int totalMinor,
    required String currency,
    required String state,
    int? payoutBatchId,
    int? taskId,
    required int version,
    required DateTime createdAt,
  }) = _SupplyDeliveryImpl;

  factory SupplyDelivery.fromJson(Map<String, dynamic> jsonSerialization) {
    return SupplyDelivery(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      supplierId: jsonSerialization['supplierId'] as int?,
      mediaId: jsonSerialization['mediaId'] as int,
      linesJson: jsonSerialization['linesJson'] as String,
      totalMinor: jsonSerialization['totalMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      state: jsonSerialization['state'] as String,
      payoutBatchId: jsonSerialization['payoutBatchId'] as int?,
      taskId: jsonSerialization['taskId'] as int?,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SupplyDeliveryTable();

  static const db = SupplyDeliveryRepository._();

  @override
  int? id;

  int restaurantId;

  int? supplierId;

  int mediaId;

  String linesJson;

  int totalMinor;

  String currency;

  String state;

  int? payoutBatchId;

  int? taskId;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SupplyDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SupplyDelivery copyWith({
    int? id,
    int? restaurantId,
    int? supplierId,
    int? mediaId,
    String? linesJson,
    int? totalMinor,
    String? currency,
    String? state,
    int? payoutBatchId,
    int? taskId,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SupplyDelivery',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      if (supplierId != null) 'supplierId': supplierId,
      'mediaId': mediaId,
      'linesJson': linesJson,
      'totalMinor': totalMinor,
      'currency': currency,
      'state': state,
      if (payoutBatchId != null) 'payoutBatchId': payoutBatchId,
      if (taskId != null) 'taskId': taskId,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SupplyDeliveryInclude include() {
    return SupplyDeliveryInclude._();
  }

  static SupplyDeliveryIncludeList includeList({
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplyDeliveryTable>? orderBy,
    _is.OrderByListBuilder<SupplyDeliveryTable>? orderByList,
    SupplyDeliveryInclude? include,
  }) {
    return SupplyDeliveryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupplyDelivery.t),
      orderByList: orderByList?.call(SupplyDelivery.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SupplyDeliveryImpl extends SupplyDelivery {
  _SupplyDeliveryImpl({
    int? id,
    required int restaurantId,
    int? supplierId,
    required int mediaId,
    required String linesJson,
    required int totalMinor,
    required String currency,
    required String state,
    int? payoutBatchId,
    int? taskId,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         supplierId: supplierId,
         mediaId: mediaId,
         linesJson: linesJson,
         totalMinor: totalMinor,
         currency: currency,
         state: state,
         payoutBatchId: payoutBatchId,
         taskId: taskId,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SupplyDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SupplyDelivery copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    Object? supplierId = _Undefined,
    int? mediaId,
    String? linesJson,
    int? totalMinor,
    String? currency,
    String? state,
    Object? payoutBatchId = _Undefined,
    Object? taskId = _Undefined,
    int? version,
    DateTime? createdAt,
  }) {
    return SupplyDelivery(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      supplierId: supplierId is int? ? supplierId : this.supplierId,
      mediaId: mediaId ?? this.mediaId,
      linesJson: linesJson ?? this.linesJson,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      state: state ?? this.state,
      payoutBatchId: payoutBatchId is int? ? payoutBatchId : this.payoutBatchId,
      taskId: taskId is int? ? taskId : this.taskId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SupplyDeliveryUpdateTable extends _is.UpdateTable<SupplyDeliveryTable> {
  SupplyDeliveryUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> supplierId(int? value) => _is.ColumnValue(
    table.supplierId,
    value,
  );

  _is.ColumnValue<int, int> mediaId(int value) => _is.ColumnValue(
    table.mediaId,
    value,
  );

  _is.ColumnValue<String, String> linesJson(String value) => _is.ColumnValue(
    table.linesJson,
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

  _is.ColumnValue<int, int> payoutBatchId(int? value) => _is.ColumnValue(
    table.payoutBatchId,
    value,
  );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
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

class SupplyDeliveryTable extends _is.Table<int?> {
  SupplyDeliveryTable({super.tableRelation})
    : super(tableName: 'raysto_supply_delivery') {
    updateTable = SupplyDeliveryUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    supplierId = _is.ColumnInt(
      'supplierId',
      this,
    );
    mediaId = _is.ColumnInt(
      'mediaId',
      this,
    );
    linesJson = _is.ColumnString(
      'linesJson',
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
    payoutBatchId = _is.ColumnInt(
      'payoutBatchId',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
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

  late final SupplyDeliveryUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt supplierId;

  late final _is.ColumnInt mediaId;

  late final _is.ColumnString linesJson;

  late final _is.ColumnInt totalMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString state;

  late final _is.ColumnInt payoutBatchId;

  late final _is.ColumnInt taskId;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    supplierId,
    mediaId,
    linesJson,
    totalMinor,
    currency,
    state,
    payoutBatchId,
    taskId,
    version,
    createdAt,
  ];
}

class SupplyDeliveryInclude extends _is.IncludeObject {
  SupplyDeliveryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SupplyDelivery.t;
}

class SupplyDeliveryIncludeList extends _is.IncludeList {
  SupplyDeliveryIncludeList._({
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SupplyDelivery.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SupplyDelivery.t;
}

class SupplyDeliveryRepository {
  const SupplyDeliveryRepository._();

  /// Returns a list of [SupplyDelivery]s matching the given query parameters.
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
  Future<List<SupplyDelivery>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplyDeliveryTable>? orderBy,
    _is.OrderByListBuilder<SupplyDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SupplyDelivery>(
      where: where?.call(SupplyDelivery.t),
      orderBy: orderBy?.call(SupplyDelivery.t),
      orderByList: orderByList?.call(SupplyDelivery.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SupplyDelivery] matching the given query parameters.
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
  Future<SupplyDelivery?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? where,
    int? offset,
    _is.OrderByBuilder<SupplyDeliveryTable>? orderBy,
    _is.OrderByListBuilder<SupplyDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SupplyDelivery>(
      where: where?.call(SupplyDelivery.t),
      orderBy: orderBy?.call(SupplyDelivery.t),
      orderByList: orderByList?.call(SupplyDelivery.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SupplyDelivery] by its [id] or null if no such row exists.
  Future<SupplyDelivery?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SupplyDelivery>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SupplyDelivery]s in the list and returns the inserted rows.
  ///
  /// The returned [SupplyDelivery]s will have their `id` fields set.
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
  Future<List<SupplyDelivery>> insert(
    _is.DatabaseSession session,
    List<SupplyDelivery> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SupplyDelivery>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SupplyDelivery] and returns the inserted row.
  ///
  /// The returned [SupplyDelivery] will have its `id` field set.
  Future<SupplyDelivery> insertRow(
    _is.DatabaseSession session,
    SupplyDelivery row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SupplyDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SupplyDelivery]s in the list and returns the resulting rows.
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
  /// The returned [SupplyDelivery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupplyDelivery>> upsert(
    _is.DatabaseSession session,
    List<SupplyDelivery> rows, {
    required _is.ColumnSelections<SupplyDeliveryTable> conflictColumns,
    _is.ColumnSelections<SupplyDeliveryTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SupplyDelivery>(
      rows,
      conflictColumns: conflictColumns(SupplyDelivery.t),
      updateColumns: updateColumns?.call(SupplyDelivery.t),
      updateWhere: updateWhere?.call(SupplyDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SupplyDelivery] and returns the resulting row.
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
  /// The returned [SupplyDelivery] will have its `id` field set.
  Future<SupplyDelivery?> upsertRow(
    _is.DatabaseSession session,
    SupplyDelivery row, {
    required _is.ColumnSelections<SupplyDeliveryTable> conflictColumns,
    _is.ColumnSelections<SupplyDeliveryTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SupplyDelivery>(
      row,
      conflictColumns: conflictColumns(SupplyDelivery.t),
      updateColumns: updateColumns?.call(SupplyDelivery.t),
      updateWhere: updateWhere?.call(SupplyDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates all [SupplyDelivery]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupplyDelivery>> update(
    _is.DatabaseSession session,
    List<SupplyDelivery> rows, {
    _is.ColumnSelections<SupplyDeliveryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SupplyDelivery>(
      rows,
      columns: columns?.call(SupplyDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SupplyDelivery]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SupplyDelivery> updateRow(
    _is.DatabaseSession session,
    SupplyDelivery row, {
    _is.ColumnSelections<SupplyDeliveryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SupplyDelivery>(
      row,
      columns: columns?.call(SupplyDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SupplyDelivery] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SupplyDelivery?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SupplyDeliveryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SupplyDelivery>(
      id,
      columnValues: columnValues(SupplyDelivery.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SupplyDelivery]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupplyDelivery>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SupplyDeliveryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SupplyDeliveryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplyDeliveryTable>? orderBy,
    _is.OrderByListBuilder<SupplyDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SupplyDelivery>(
      columnValues: columnValues(SupplyDelivery.t.updateTable),
      where: where(SupplyDelivery.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupplyDelivery.t),
      orderByList: orderByList?.call(SupplyDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SupplyDelivery]s in the list and returns the deleted rows.
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
  Future<List<SupplyDelivery>> delete(
    _is.DatabaseSession session,
    List<SupplyDelivery> rows, {
    _is.OrderByBuilder<SupplyDeliveryTable>? orderBy,
    _is.OrderByListBuilder<SupplyDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SupplyDelivery>(
      rows,
      orderBy: orderBy?.call(SupplyDelivery.t),
      orderByList: orderByList?.call(SupplyDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SupplyDelivery].
  Future<SupplyDelivery> deleteRow(
    _is.DatabaseSession session,
    SupplyDelivery row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SupplyDelivery>(
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
  Future<List<SupplyDelivery>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplyDeliveryTable> where,
    _is.OrderByBuilder<SupplyDeliveryTable>? orderBy,
    _is.OrderByListBuilder<SupplyDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SupplyDelivery>(
      where: where(SupplyDelivery.t),
      orderBy: orderBy?.call(SupplyDelivery.t),
      orderByList: orderByList?.call(SupplyDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplyDeliveryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SupplyDelivery>(
      where: where?.call(SupplyDelivery.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SupplyDelivery] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplyDeliveryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SupplyDelivery>(
      where: where(SupplyDelivery.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
