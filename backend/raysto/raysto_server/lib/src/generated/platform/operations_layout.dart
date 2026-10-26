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

abstract class OperationsLayout
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  OperationsLayout._({
    this.id,
    required this.restaurantId,
    required this.userId,
    required this.stateJson,
    required this.version,
  });

  factory OperationsLayout({
    int? id,
    required int restaurantId,
    required String userId,
    required String stateJson,
    required int version,
  }) = _OperationsLayoutImpl;

  factory OperationsLayout.fromJson(Map<String, dynamic> jsonSerialization) {
    return OperationsLayout(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      stateJson: jsonSerialization['stateJson'] as String,
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = OperationsLayoutTable();

  static const db = OperationsLayoutRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  String stateJson;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [OperationsLayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OperationsLayout copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? stateJson,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OperationsLayout',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'stateJson': stateJson,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static OperationsLayoutInclude include() {
    return OperationsLayoutInclude._();
  }

  static OperationsLayoutIncludeList includeList({
    _is.WhereExpressionBuilder<OperationsLayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OperationsLayoutTable>? orderBy,
    _is.OrderByListBuilder<OperationsLayoutTable>? orderByList,
    OperationsLayoutInclude? include,
  }) {
    return OperationsLayoutIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OperationsLayout.t),
      orderByList: orderByList?.call(OperationsLayout.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OperationsLayoutImpl extends OperationsLayout {
  _OperationsLayoutImpl({
    int? id,
    required int restaurantId,
    required String userId,
    required String stateJson,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         stateJson: stateJson,
         version: version,
       );

  /// Returns a shallow copy of this [OperationsLayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OperationsLayout copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    String? stateJson,
    int? version,
  }) {
    return OperationsLayout(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      stateJson: stateJson ?? this.stateJson,
      version: version ?? this.version,
    );
  }
}

class OperationsLayoutUpdateTable
    extends _is.UpdateTable<OperationsLayoutTable> {
  OperationsLayoutUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> stateJson(String value) => _is.ColumnValue(
    table.stateJson,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class OperationsLayoutTable extends _is.Table<int?> {
  OperationsLayoutTable({super.tableRelation})
    : super(tableName: 'raysto_operations_layout') {
    updateTable = OperationsLayoutUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    stateJson = _is.ColumnString(
      'stateJson',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final OperationsLayoutUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString stateJson;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    stateJson,
    version,
  ];
}

class OperationsLayoutInclude extends _is.IncludeObject {
  OperationsLayoutInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => OperationsLayout.t;
}

class OperationsLayoutIncludeList extends _is.IncludeList {
  OperationsLayoutIncludeList._({
    _is.WhereExpressionBuilder<OperationsLayoutTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OperationsLayout.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => OperationsLayout.t;
}

class OperationsLayoutRepository {
  const OperationsLayoutRepository._();

  /// Returns a list of [OperationsLayout]s matching the given query parameters.
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
  Future<List<OperationsLayout>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OperationsLayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OperationsLayoutTable>? orderBy,
    _is.OrderByListBuilder<OperationsLayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OperationsLayout>(
      where: where?.call(OperationsLayout.t),
      orderBy: orderBy?.call(OperationsLayout.t),
      orderByList: orderByList?.call(OperationsLayout.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OperationsLayout] matching the given query parameters.
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
  Future<OperationsLayout?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OperationsLayoutTable>? where,
    int? offset,
    _is.OrderByBuilder<OperationsLayoutTable>? orderBy,
    _is.OrderByListBuilder<OperationsLayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OperationsLayout>(
      where: where?.call(OperationsLayout.t),
      orderBy: orderBy?.call(OperationsLayout.t),
      orderByList: orderByList?.call(OperationsLayout.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OperationsLayout] by its [id] or null if no such row exists.
  Future<OperationsLayout?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OperationsLayout>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OperationsLayout]s in the list and returns the inserted rows.
  ///
  /// The returned [OperationsLayout]s will have their `id` fields set.
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
  Future<List<OperationsLayout>> insert(
    _is.DatabaseSession session,
    List<OperationsLayout> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OperationsLayout>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OperationsLayout] and returns the inserted row.
  ///
  /// The returned [OperationsLayout] will have its `id` field set.
  Future<OperationsLayout> insertRow(
    _is.DatabaseSession session,
    OperationsLayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OperationsLayout>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OperationsLayout]s in the list and returns the resulting rows.
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
  /// The returned [OperationsLayout]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OperationsLayout>> upsert(
    _is.DatabaseSession session,
    List<OperationsLayout> rows, {
    required _is.ColumnSelections<OperationsLayoutTable> conflictColumns,
    _is.ColumnSelections<OperationsLayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<OperationsLayoutTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OperationsLayout>(
      rows,
      conflictColumns: conflictColumns(OperationsLayout.t),
      updateColumns: updateColumns?.call(OperationsLayout.t),
      updateWhere: updateWhere?.call(OperationsLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OperationsLayout] and returns the resulting row.
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
  /// The returned [OperationsLayout] will have its `id` field set.
  Future<OperationsLayout?> upsertRow(
    _is.DatabaseSession session,
    OperationsLayout row, {
    required _is.ColumnSelections<OperationsLayoutTable> conflictColumns,
    _is.ColumnSelections<OperationsLayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<OperationsLayoutTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OperationsLayout>(
      row,
      conflictColumns: conflictColumns(OperationsLayout.t),
      updateColumns: updateColumns?.call(OperationsLayout.t),
      updateWhere: updateWhere?.call(OperationsLayout.t),
      transaction: transaction,
    );
  }

  /// Updates all [OperationsLayout]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OperationsLayout>> update(
    _is.DatabaseSession session,
    List<OperationsLayout> rows, {
    _is.ColumnSelections<OperationsLayoutTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OperationsLayout>(
      rows,
      columns: columns?.call(OperationsLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OperationsLayout]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OperationsLayout> updateRow(
    _is.DatabaseSession session,
    OperationsLayout row, {
    _is.ColumnSelections<OperationsLayoutTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OperationsLayout>(
      row,
      columns: columns?.call(OperationsLayout.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OperationsLayout] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OperationsLayout?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<OperationsLayoutUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OperationsLayout>(
      id,
      columnValues: columnValues(OperationsLayout.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OperationsLayout]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OperationsLayout>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OperationsLayoutUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<OperationsLayoutTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OperationsLayoutTable>? orderBy,
    _is.OrderByListBuilder<OperationsLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OperationsLayout>(
      columnValues: columnValues(OperationsLayout.t.updateTable),
      where: where(OperationsLayout.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OperationsLayout.t),
      orderByList: orderByList?.call(OperationsLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OperationsLayout]s in the list and returns the deleted rows.
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
  Future<List<OperationsLayout>> delete(
    _is.DatabaseSession session,
    List<OperationsLayout> rows, {
    _is.OrderByBuilder<OperationsLayoutTable>? orderBy,
    _is.OrderByListBuilder<OperationsLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OperationsLayout>(
      rows,
      orderBy: orderBy?.call(OperationsLayout.t),
      orderByList: orderByList?.call(OperationsLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OperationsLayout].
  Future<OperationsLayout> deleteRow(
    _is.DatabaseSession session,
    OperationsLayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OperationsLayout>(
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
  Future<List<OperationsLayout>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OperationsLayoutTable> where,
    _is.OrderByBuilder<OperationsLayoutTable>? orderBy,
    _is.OrderByListBuilder<OperationsLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OperationsLayout>(
      where: where(OperationsLayout.t),
      orderBy: orderBy?.call(OperationsLayout.t),
      orderByList: orderByList?.call(OperationsLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OperationsLayoutTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OperationsLayout>(
      where: where?.call(OperationsLayout.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OperationsLayout] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OperationsLayoutTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OperationsLayout>(
      where: where(OperationsLayout.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
