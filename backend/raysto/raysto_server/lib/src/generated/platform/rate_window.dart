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

abstract class RateWindow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RateWindow._({
    this.id,
    required this.bucket,
    required this.windowStart,
    required this.requests,
  });

  factory RateWindow({
    int? id,
    required String bucket,
    required DateTime windowStart,
    required int requests,
  }) = _RateWindowImpl;

  factory RateWindow.fromJson(Map<String, dynamic> jsonSerialization) {
    return RateWindow(
      id: jsonSerialization['id'] as int?,
      bucket: jsonSerialization['bucket'] as String,
      windowStart: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['windowStart'],
      ),
      requests: jsonSerialization['requests'] as int,
    );
  }

  static final t = RateWindowTable();

  static const db = RateWindowRepository._();

  @override
  int? id;

  String bucket;

  DateTime windowStart;

  int requests;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RateWindow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RateWindow copyWith({
    int? id,
    String? bucket,
    DateTime? windowStart,
    int? requests,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RateWindow',
      if (id != null) 'id': id,
      'bucket': bucket,
      'windowStart': windowStart.toJson(),
      'requests': requests,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RateWindowInclude include() {
    return RateWindowInclude._();
  }

  static RateWindowIncludeList includeList({
    _is.WhereExpressionBuilder<RateWindowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RateWindowTable>? orderBy,
    _is.OrderByListBuilder<RateWindowTable>? orderByList,
    RateWindowInclude? include,
  }) {
    return RateWindowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RateWindow.t),
      orderByList: orderByList?.call(RateWindow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RateWindowImpl extends RateWindow {
  _RateWindowImpl({
    int? id,
    required String bucket,
    required DateTime windowStart,
    required int requests,
  }) : super._(
         id: id,
         bucket: bucket,
         windowStart: windowStart,
         requests: requests,
       );

  /// Returns a shallow copy of this [RateWindow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RateWindow copyWith({
    Object? id = _Undefined,
    String? bucket,
    DateTime? windowStart,
    int? requests,
  }) {
    return RateWindow(
      id: id is int? ? id : this.id,
      bucket: bucket ?? this.bucket,
      windowStart: windowStart ?? this.windowStart,
      requests: requests ?? this.requests,
    );
  }
}

class RateWindowUpdateTable extends _is.UpdateTable<RateWindowTable> {
  RateWindowUpdateTable(super.table);

  _is.ColumnValue<String, String> bucket(String value) => _is.ColumnValue(
    table.bucket,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> windowStart(DateTime value) =>
      _is.ColumnValue(
        table.windowStart,
        value,
      );

  _is.ColumnValue<int, int> requests(int value) => _is.ColumnValue(
    table.requests,
    value,
  );
}

class RateWindowTable extends _is.Table<int?> {
  RateWindowTable({super.tableRelation})
    : super(tableName: 'raysto_rate_window') {
    updateTable = RateWindowUpdateTable(this);
    bucket = _is.ColumnString(
      'bucket',
      this,
    );
    windowStart = _is.ColumnDateTime(
      'windowStart',
      this,
    );
    requests = _is.ColumnInt(
      'requests',
      this,
    );
  }

  late final RateWindowUpdateTable updateTable;

  late final _is.ColumnString bucket;

  late final _is.ColumnDateTime windowStart;

  late final _is.ColumnInt requests;

  @override
  List<_is.Column> get columns => [
    id,
    bucket,
    windowStart,
    requests,
  ];
}

class RateWindowInclude extends _is.IncludeObject {
  RateWindowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RateWindow.t;
}

class RateWindowIncludeList extends _is.IncludeList {
  RateWindowIncludeList._({
    _is.WhereExpressionBuilder<RateWindowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RateWindow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RateWindow.t;
}

class RateWindowRepository {
  const RateWindowRepository._();

  /// Returns a list of [RateWindow]s matching the given query parameters.
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
  Future<List<RateWindow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RateWindowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RateWindowTable>? orderBy,
    _is.OrderByListBuilder<RateWindowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RateWindow>(
      where: where?.call(RateWindow.t),
      orderBy: orderBy?.call(RateWindow.t),
      orderByList: orderByList?.call(RateWindow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RateWindow] matching the given query parameters.
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
  Future<RateWindow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RateWindowTable>? where,
    int? offset,
    _is.OrderByBuilder<RateWindowTable>? orderBy,
    _is.OrderByListBuilder<RateWindowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RateWindow>(
      where: where?.call(RateWindow.t),
      orderBy: orderBy?.call(RateWindow.t),
      orderByList: orderByList?.call(RateWindow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RateWindow] by its [id] or null if no such row exists.
  Future<RateWindow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RateWindow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RateWindow]s in the list and returns the inserted rows.
  ///
  /// The returned [RateWindow]s will have their `id` fields set.
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
  Future<List<RateWindow>> insert(
    _is.DatabaseSession session,
    List<RateWindow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RateWindow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RateWindow] and returns the inserted row.
  ///
  /// The returned [RateWindow] will have its `id` field set.
  Future<RateWindow> insertRow(
    _is.DatabaseSession session,
    RateWindow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RateWindow>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RateWindow]s in the list and returns the resulting rows.
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
  /// The returned [RateWindow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RateWindow>> upsert(
    _is.DatabaseSession session,
    List<RateWindow> rows, {
    required _is.ColumnSelections<RateWindowTable> conflictColumns,
    _is.ColumnSelections<RateWindowTable>? updateColumns,
    _is.WhereExpressionBuilder<RateWindowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RateWindow>(
      rows,
      conflictColumns: conflictColumns(RateWindow.t),
      updateColumns: updateColumns?.call(RateWindow.t),
      updateWhere: updateWhere?.call(RateWindow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RateWindow] and returns the resulting row.
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
  /// The returned [RateWindow] will have its `id` field set.
  Future<RateWindow?> upsertRow(
    _is.DatabaseSession session,
    RateWindow row, {
    required _is.ColumnSelections<RateWindowTable> conflictColumns,
    _is.ColumnSelections<RateWindowTable>? updateColumns,
    _is.WhereExpressionBuilder<RateWindowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RateWindow>(
      row,
      conflictColumns: conflictColumns(RateWindow.t),
      updateColumns: updateColumns?.call(RateWindow.t),
      updateWhere: updateWhere?.call(RateWindow.t),
      transaction: transaction,
    );
  }

  /// Updates all [RateWindow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RateWindow>> update(
    _is.DatabaseSession session,
    List<RateWindow> rows, {
    _is.ColumnSelections<RateWindowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RateWindow>(
      rows,
      columns: columns?.call(RateWindow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RateWindow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RateWindow> updateRow(
    _is.DatabaseSession session,
    RateWindow row, {
    _is.ColumnSelections<RateWindowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RateWindow>(
      row,
      columns: columns?.call(RateWindow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RateWindow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RateWindow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RateWindowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RateWindow>(
      id,
      columnValues: columnValues(RateWindow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RateWindow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RateWindow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RateWindowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RateWindowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RateWindowTable>? orderBy,
    _is.OrderByListBuilder<RateWindowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RateWindow>(
      columnValues: columnValues(RateWindow.t.updateTable),
      where: where(RateWindow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RateWindow.t),
      orderByList: orderByList?.call(RateWindow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RateWindow]s in the list and returns the deleted rows.
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
  Future<List<RateWindow>> delete(
    _is.DatabaseSession session,
    List<RateWindow> rows, {
    _is.OrderByBuilder<RateWindowTable>? orderBy,
    _is.OrderByListBuilder<RateWindowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RateWindow>(
      rows,
      orderBy: orderBy?.call(RateWindow.t),
      orderByList: orderByList?.call(RateWindow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RateWindow].
  Future<RateWindow> deleteRow(
    _is.DatabaseSession session,
    RateWindow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RateWindow>(
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
  Future<List<RateWindow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RateWindowTable> where,
    _is.OrderByBuilder<RateWindowTable>? orderBy,
    _is.OrderByListBuilder<RateWindowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RateWindow>(
      where: where(RateWindow.t),
      orderBy: orderBy?.call(RateWindow.t),
      orderByList: orderByList?.call(RateWindow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RateWindowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RateWindow>(
      where: where?.call(RateWindow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RateWindow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RateWindowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RateWindow>(
      where: where(RateWindow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
