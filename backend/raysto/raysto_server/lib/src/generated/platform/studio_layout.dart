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

abstract class StudioLayout
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StudioLayout._({
    this.id,
    required this.scope,
    required this.userId,
    required this.section,
    required this.stateJson,
    required this.version,
    required this.updatedAt,
  });

  factory StudioLayout({
    int? id,
    required String scope,
    required String userId,
    required String section,
    required String stateJson,
    required int version,
    required DateTime updatedAt,
  }) = _StudioLayoutImpl;

  factory StudioLayout.fromJson(Map<String, dynamic> jsonSerialization) {
    return StudioLayout(
      id: jsonSerialization['id'] as int?,
      scope: jsonSerialization['scope'] as String,
      userId: jsonSerialization['userId'] as String,
      section: jsonSerialization['section'] as String,
      stateJson: jsonSerialization['stateJson'] as String,
      version: jsonSerialization['version'] as int,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = StudioLayoutTable();

  static const db = StudioLayoutRepository._();

  @override
  int? id;

  String scope;

  String userId;

  String section;

  String stateJson;

  int version;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StudioLayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StudioLayout copyWith({
    int? id,
    String? scope,
    String? userId,
    String? section,
    String? stateJson,
    int? version,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StudioLayout',
      if (id != null) 'id': id,
      'scope': scope,
      'userId': userId,
      'section': section,
      'stateJson': stateJson,
      'version': version,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StudioLayoutInclude include() {
    return StudioLayoutInclude._();
  }

  static StudioLayoutIncludeList includeList({
    _is.WhereExpressionBuilder<StudioLayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StudioLayoutTable>? orderBy,
    _is.OrderByListBuilder<StudioLayoutTable>? orderByList,
    StudioLayoutInclude? include,
  }) {
    return StudioLayoutIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StudioLayout.t),
      orderByList: orderByList?.call(StudioLayout.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StudioLayoutImpl extends StudioLayout {
  _StudioLayoutImpl({
    int? id,
    required String scope,
    required String userId,
    required String section,
    required String stateJson,
    required int version,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         scope: scope,
         userId: userId,
         section: section,
         stateJson: stateJson,
         version: version,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [StudioLayout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StudioLayout copyWith({
    Object? id = _Undefined,
    String? scope,
    String? userId,
    String? section,
    String? stateJson,
    int? version,
    DateTime? updatedAt,
  }) {
    return StudioLayout(
      id: id is int? ? id : this.id,
      scope: scope ?? this.scope,
      userId: userId ?? this.userId,
      section: section ?? this.section,
      stateJson: stateJson ?? this.stateJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StudioLayoutUpdateTable extends _is.UpdateTable<StudioLayoutTable> {
  StudioLayoutUpdateTable(super.table);

  _is.ColumnValue<String, String> scope(String value) => _is.ColumnValue(
    table.scope,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> section(String value) => _is.ColumnValue(
    table.section,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class StudioLayoutTable extends _is.Table<int?> {
  StudioLayoutTable({super.tableRelation})
    : super(tableName: 'raysto_studio_layout') {
    updateTable = StudioLayoutUpdateTable(this);
    scope = _is.ColumnString(
      'scope',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    section = _is.ColumnString(
      'section',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final StudioLayoutUpdateTable updateTable;

  late final _is.ColumnString scope;

  late final _is.ColumnString userId;

  late final _is.ColumnString section;

  late final _is.ColumnString stateJson;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scope,
    userId,
    section,
    stateJson,
    version,
    updatedAt,
  ];
}

class StudioLayoutInclude extends _is.IncludeObject {
  StudioLayoutInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StudioLayout.t;
}

class StudioLayoutIncludeList extends _is.IncludeList {
  StudioLayoutIncludeList._({
    _is.WhereExpressionBuilder<StudioLayoutTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StudioLayout.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StudioLayout.t;
}

class StudioLayoutRepository {
  const StudioLayoutRepository._();

  /// Returns a list of [StudioLayout]s matching the given query parameters.
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
  Future<List<StudioLayout>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StudioLayoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StudioLayoutTable>? orderBy,
    _is.OrderByListBuilder<StudioLayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StudioLayout>(
      where: where?.call(StudioLayout.t),
      orderBy: orderBy?.call(StudioLayout.t),
      orderByList: orderByList?.call(StudioLayout.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StudioLayout] matching the given query parameters.
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
  Future<StudioLayout?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StudioLayoutTable>? where,
    int? offset,
    _is.OrderByBuilder<StudioLayoutTable>? orderBy,
    _is.OrderByListBuilder<StudioLayoutTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StudioLayout>(
      where: where?.call(StudioLayout.t),
      orderBy: orderBy?.call(StudioLayout.t),
      orderByList: orderByList?.call(StudioLayout.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StudioLayout] by its [id] or null if no such row exists.
  Future<StudioLayout?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StudioLayout>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StudioLayout]s in the list and returns the inserted rows.
  ///
  /// The returned [StudioLayout]s will have their `id` fields set.
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
  Future<List<StudioLayout>> insert(
    _is.DatabaseSession session,
    List<StudioLayout> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StudioLayout>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StudioLayout] and returns the inserted row.
  ///
  /// The returned [StudioLayout] will have its `id` field set.
  Future<StudioLayout> insertRow(
    _is.DatabaseSession session,
    StudioLayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StudioLayout>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StudioLayout]s in the list and returns the resulting rows.
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
  /// The returned [StudioLayout]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StudioLayout>> upsert(
    _is.DatabaseSession session,
    List<StudioLayout> rows, {
    required _is.ColumnSelections<StudioLayoutTable> conflictColumns,
    _is.ColumnSelections<StudioLayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<StudioLayoutTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StudioLayout>(
      rows,
      conflictColumns: conflictColumns(StudioLayout.t),
      updateColumns: updateColumns?.call(StudioLayout.t),
      updateWhere: updateWhere?.call(StudioLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StudioLayout] and returns the resulting row.
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
  /// The returned [StudioLayout] will have its `id` field set.
  Future<StudioLayout?> upsertRow(
    _is.DatabaseSession session,
    StudioLayout row, {
    required _is.ColumnSelections<StudioLayoutTable> conflictColumns,
    _is.ColumnSelections<StudioLayoutTable>? updateColumns,
    _is.WhereExpressionBuilder<StudioLayoutTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StudioLayout>(
      row,
      conflictColumns: conflictColumns(StudioLayout.t),
      updateColumns: updateColumns?.call(StudioLayout.t),
      updateWhere: updateWhere?.call(StudioLayout.t),
      transaction: transaction,
    );
  }

  /// Updates all [StudioLayout]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StudioLayout>> update(
    _is.DatabaseSession session,
    List<StudioLayout> rows, {
    _is.ColumnSelections<StudioLayoutTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StudioLayout>(
      rows,
      columns: columns?.call(StudioLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StudioLayout]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StudioLayout> updateRow(
    _is.DatabaseSession session,
    StudioLayout row, {
    _is.ColumnSelections<StudioLayoutTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StudioLayout>(
      row,
      columns: columns?.call(StudioLayout.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StudioLayout] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StudioLayout?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StudioLayoutUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StudioLayout>(
      id,
      columnValues: columnValues(StudioLayout.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StudioLayout]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StudioLayout>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StudioLayoutUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StudioLayoutTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StudioLayoutTable>? orderBy,
    _is.OrderByListBuilder<StudioLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StudioLayout>(
      columnValues: columnValues(StudioLayout.t.updateTable),
      where: where(StudioLayout.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StudioLayout.t),
      orderByList: orderByList?.call(StudioLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StudioLayout]s in the list and returns the deleted rows.
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
  Future<List<StudioLayout>> delete(
    _is.DatabaseSession session,
    List<StudioLayout> rows, {
    _is.OrderByBuilder<StudioLayoutTable>? orderBy,
    _is.OrderByListBuilder<StudioLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StudioLayout>(
      rows,
      orderBy: orderBy?.call(StudioLayout.t),
      orderByList: orderByList?.call(StudioLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StudioLayout].
  Future<StudioLayout> deleteRow(
    _is.DatabaseSession session,
    StudioLayout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StudioLayout>(
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
  Future<List<StudioLayout>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StudioLayoutTable> where,
    _is.OrderByBuilder<StudioLayoutTable>? orderBy,
    _is.OrderByListBuilder<StudioLayoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StudioLayout>(
      where: where(StudioLayout.t),
      orderBy: orderBy?.call(StudioLayout.t),
      orderByList: orderByList?.call(StudioLayout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StudioLayoutTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StudioLayout>(
      where: where?.call(StudioLayout.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StudioLayout] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StudioLayoutTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StudioLayout>(
      where: where(StudioLayout.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
