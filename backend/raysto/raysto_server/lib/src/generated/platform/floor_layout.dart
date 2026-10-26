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

abstract class FloorLayout
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FloorLayout._({
    this.id,
    required this.restaurantId,
    required this.layoutJson,
    required this.version,
    required this.updatedAt,
  });

  factory FloorLayout({
    int? id,
    required int restaurantId,
    required String layoutJson,
    required int version,
    required DateTime updatedAt,
  }) = _FloorLayoutImpl;

  factory FloorLayout.fromJson(Map<String, dynamic> jsonSerialization) {
    return FloorLayout(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      layoutJson: jsonSerialization['layoutJson'] as String,
      version: jsonSerialization['version'] as int,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = FloorLayoutTable();

  static const db = FloorLayoutRepository._();

  @override
  int? id;

  int restaurantId;

  String layoutJson;

  int version;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FloorLayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FloorLayout copyWith({
    int? id,
    int? restaurantId,
    String? layoutJson,
    int? version,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FloorLayout',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'layoutJson': layoutJson,
      'version': version,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static FloorLayoutInclude include() {
    return FloorLayoutInclude._();
  }

  static FloorLayoutIncludeList includeList({
    _is.WhereExpressionBuilder<FloorLayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FloorLayoutTable>? orderBy,
    _is.OrderByListBuilder<FloorLayoutTable>? orderByList,
    FloorLayoutInclude? include,
  }) {
    return FloorLayoutIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FloorLayout.t),
      orderByList: orderByList?.call(FloorLayout.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FloorLayoutImpl extends FloorLayout {
  _FloorLayoutImpl({
    int? id,
    required int restaurantId,
    required String layoutJson,
    required int version,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         layoutJson: layoutJson,
         version: version,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FloorLayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FloorLayout copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? layoutJson,
    int? version,
    DateTime? updatedAt,
  }) {
    return FloorLayout(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      layoutJson: layoutJson ?? this.layoutJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FloorLayoutUpdateTable extends _is.UpdateTable<FloorLayoutTable> {
  FloorLayoutUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> layoutJson(String value) => _is.ColumnValue(
    table.layoutJson,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class FloorLayoutTable extends _is.Table<int?> {
  FloorLayoutTable({super.tableRelation})
    : super(tableName: 'raysto_floor_layout') {
    updateTable = FloorLayoutUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    layoutJson = _is.ColumnString(
      'layoutJson',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final FloorLayoutUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString layoutJson;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    layoutJson,
    version,
    updatedAt,
  ];
}

class FloorLayoutInclude extends _is.IncludeObject {
  FloorLayoutInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FloorLayout.t;
}

class FloorLayoutIncludeList extends _is.IncludeList {
  FloorLayoutIncludeList._({
    _is.WhereExpressionBuilder<FloorLayoutTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FloorLayout.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FloorLayout.t;
}

class FloorLayoutRepository {
  const FloorLayoutRepository._();

  /// Returns a list of [FloorLayout]s matching the given query parameters.
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
  Future<List<FloorLayout>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FloorLayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FloorLayoutTable>? orderBy,
    _is.OrderByListBuilder<FloorLayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FloorLayout>(
      where: where?.call(FloorLayout.t),
      orderBy: orderBy?.call(FloorLayout.t),
      orderByList: orderByList?.call(FloorLayout.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FloorLayout] matching the given query parameters.
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
  Future<FloorLayout?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FloorLayoutTable>? where,
    int? offset,
    _is.OrderByBuilder<FloorLayoutTable>? orderBy,
    _is.OrderByListBuilder<FloorLayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FloorLayout>(
      where: where?.call(FloorLayout.t),
      orderBy: orderBy?.call(FloorLayout.t),
      orderByList: orderByList?.call(FloorLayout.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FloorLayout] by its [id] or null if no such row exists.
  Future<FloorLayout?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FloorLayout>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FloorLayout]s in the list and returns the inserted rows.
  ///
  /// The returned [FloorLayout]s will have their `id` fields set.
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
  Future<List<FloorLayout>> insert(
    _is.DatabaseSession session,
    List<FloorLayout> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FloorLayout>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FloorLayout] and returns the inserted row.
  ///
  /// The returned [FloorLayout] will have its `id` field set.
  Future<FloorLayout> insertRow(
    _is.DatabaseSession session,
    FloorLayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FloorLayout>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FloorLayout]s in the list and returns the resulting rows.
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
  /// The returned [FloorLayout]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FloorLayout>> upsert(
    _is.DatabaseSession session,
    List<FloorLayout> rows, {
    required _is.ColumnSelections<FloorLayoutTable> conflictColumns,
    _is.ColumnSelections<FloorLayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<FloorLayoutTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FloorLayout>(
      rows,
      conflictColumns: conflictColumns(FloorLayout.t),
      updateColumns: updateColumns?.call(FloorLayout.t),
      updateWhere: updateWhere?.call(FloorLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FloorLayout] and returns the resulting row.
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
  /// The returned [FloorLayout] will have its `id` field set.
  Future<FloorLayout?> upsertRow(
    _is.DatabaseSession session,
    FloorLayout row, {
    required _is.ColumnSelections<FloorLayoutTable> conflictColumns,
    _is.ColumnSelections<FloorLayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<FloorLayoutTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FloorLayout>(
      row,
      conflictColumns: conflictColumns(FloorLayout.t),
      updateColumns: updateColumns?.call(FloorLayout.t),
      updateWhere: updateWhere?.call(FloorLayout.t),
      transaction: transaction,
    );
  }

  /// Updates all [FloorLayout]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FloorLayout>> update(
    _is.DatabaseSession session,
    List<FloorLayout> rows, {
    _is.ColumnSelections<FloorLayoutTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FloorLayout>(
      rows,
      columns: columns?.call(FloorLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FloorLayout]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FloorLayout> updateRow(
    _is.DatabaseSession session,
    FloorLayout row, {
    _is.ColumnSelections<FloorLayoutTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FloorLayout>(
      row,
      columns: columns?.call(FloorLayout.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FloorLayout] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FloorLayout?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FloorLayoutUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FloorLayout>(
      id,
      columnValues: columnValues(FloorLayout.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FloorLayout]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FloorLayout>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FloorLayoutUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FloorLayoutTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FloorLayoutTable>? orderBy,
    _is.OrderByListBuilder<FloorLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FloorLayout>(
      columnValues: columnValues(FloorLayout.t.updateTable),
      where: where(FloorLayout.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FloorLayout.t),
      orderByList: orderByList?.call(FloorLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FloorLayout]s in the list and returns the deleted rows.
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
  Future<List<FloorLayout>> delete(
    _is.DatabaseSession session,
    List<FloorLayout> rows, {
    _is.OrderByBuilder<FloorLayoutTable>? orderBy,
    _is.OrderByListBuilder<FloorLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FloorLayout>(
      rows,
      orderBy: orderBy?.call(FloorLayout.t),
      orderByList: orderByList?.call(FloorLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FloorLayout].
  Future<FloorLayout> deleteRow(
    _is.DatabaseSession session,
    FloorLayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FloorLayout>(
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
  Future<List<FloorLayout>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FloorLayoutTable> where,
    _is.OrderByBuilder<FloorLayoutTable>? orderBy,
    _is.OrderByListBuilder<FloorLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FloorLayout>(
      where: where(FloorLayout.t),
      orderBy: orderBy?.call(FloorLayout.t),
      orderByList: orderByList?.call(FloorLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FloorLayoutTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FloorLayout>(
      where: where?.call(FloorLayout.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FloorLayout] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FloorLayoutTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FloorLayout>(
      where: where(FloorLayout.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
