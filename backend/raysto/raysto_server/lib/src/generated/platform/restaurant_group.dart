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

abstract class RestaurantGroup
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RestaurantGroup._({
    this.id,
    required this.name,
    required this.ownerUserId,
    required this.currency,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantGroup({
    int? id,
    required String name,
    required String ownerUserId,
    required String currency,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RestaurantGroupImpl;

  factory RestaurantGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestaurantGroup(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      ownerUserId: jsonSerialization['ownerUserId'] as String,
      currency: jsonSerialization['currency'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = RestaurantGroupTable();

  static const db = RestaurantGroupRepository._();

  @override
  int? id;

  String name;

  String ownerUserId;

  String currency;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RestaurantGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RestaurantGroup copyWith({
    int? id,
    String? name,
    String? ownerUserId,
    String? currency,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestaurantGroup',
      if (id != null) 'id': id,
      'name': name,
      'ownerUserId': ownerUserId,
      'currency': currency,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RestaurantGroupInclude include() {
    return RestaurantGroupInclude._();
  }

  static RestaurantGroupIncludeList includeList({
    _is.WhereExpressionBuilder<RestaurantGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantGroupTable>? orderBy,
    _is.OrderByListBuilder<RestaurantGroupTable>? orderByList,
    RestaurantGroupInclude? include,
  }) {
    return RestaurantGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantGroup.t),
      orderByList: orderByList?.call(RestaurantGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantGroupImpl extends RestaurantGroup {
  _RestaurantGroupImpl({
    int? id,
    required String name,
    required String ownerUserId,
    required String currency,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         ownerUserId: ownerUserId,
         currency: currency,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RestaurantGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RestaurantGroup copyWith({
    Object? id = _Undefined,
    String? name,
    String? ownerUserId,
    String? currency,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantGroup(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      currency: currency ?? this.currency,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RestaurantGroupUpdateTable extends _is.UpdateTable<RestaurantGroupTable> {
  RestaurantGroupUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> ownerUserId(String value) => _is.ColumnValue(
    table.ownerUserId,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RestaurantGroupTable extends _is.Table<int?> {
  RestaurantGroupTable({super.tableRelation})
    : super(tableName: 'raysto_restaurant_group') {
    updateTable = RestaurantGroupUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    ownerUserId = _is.ColumnString(
      'ownerUserId',
      this,
    );
    currency = _is.ColumnString(
      'currency',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RestaurantGroupUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnString ownerUserId;

  late final _is.ColumnString currency;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    ownerUserId,
    currency,
    version,
    createdAt,
    updatedAt,
  ];
}

class RestaurantGroupInclude extends _is.IncludeObject {
  RestaurantGroupInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RestaurantGroup.t;
}

class RestaurantGroupIncludeList extends _is.IncludeList {
  RestaurantGroupIncludeList._({
    _is.WhereExpressionBuilder<RestaurantGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RestaurantGroup.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RestaurantGroup.t;
}

class RestaurantGroupRepository {
  const RestaurantGroupRepository._();

  /// Returns a list of [RestaurantGroup]s matching the given query parameters.
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
  Future<List<RestaurantGroup>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantGroupTable>? orderBy,
    _is.OrderByListBuilder<RestaurantGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RestaurantGroup>(
      where: where?.call(RestaurantGroup.t),
      orderBy: orderBy?.call(RestaurantGroup.t),
      orderByList: orderByList?.call(RestaurantGroup.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RestaurantGroup] matching the given query parameters.
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
  Future<RestaurantGroup?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantGroupTable>? where,
    int? offset,
    _is.OrderByBuilder<RestaurantGroupTable>? orderBy,
    _is.OrderByListBuilder<RestaurantGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RestaurantGroup>(
      where: where?.call(RestaurantGroup.t),
      orderBy: orderBy?.call(RestaurantGroup.t),
      orderByList: orderByList?.call(RestaurantGroup.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RestaurantGroup] by its [id] or null if no such row exists.
  Future<RestaurantGroup?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RestaurantGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RestaurantGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [RestaurantGroup]s will have their `id` fields set.
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
  Future<List<RestaurantGroup>> insert(
    _is.DatabaseSession session,
    List<RestaurantGroup> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RestaurantGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RestaurantGroup] and returns the inserted row.
  ///
  /// The returned [RestaurantGroup] will have its `id` field set.
  Future<RestaurantGroup> insertRow(
    _is.DatabaseSession session,
    RestaurantGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RestaurantGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RestaurantGroup]s in the list and returns the resulting rows.
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
  /// The returned [RestaurantGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantGroup>> upsert(
    _is.DatabaseSession session,
    List<RestaurantGroup> rows, {
    required _is.ColumnSelections<RestaurantGroupTable> conflictColumns,
    _is.ColumnSelections<RestaurantGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantGroupTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RestaurantGroup>(
      rows,
      conflictColumns: conflictColumns(RestaurantGroup.t),
      updateColumns: updateColumns?.call(RestaurantGroup.t),
      updateWhere: updateWhere?.call(RestaurantGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RestaurantGroup] and returns the resulting row.
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
  /// The returned [RestaurantGroup] will have its `id` field set.
  Future<RestaurantGroup?> upsertRow(
    _is.DatabaseSession session,
    RestaurantGroup row, {
    required _is.ColumnSelections<RestaurantGroupTable> conflictColumns,
    _is.ColumnSelections<RestaurantGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantGroupTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RestaurantGroup>(
      row,
      conflictColumns: conflictColumns(RestaurantGroup.t),
      updateColumns: updateColumns?.call(RestaurantGroup.t),
      updateWhere: updateWhere?.call(RestaurantGroup.t),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantGroup>> update(
    _is.DatabaseSession session,
    List<RestaurantGroup> rows, {
    _is.ColumnSelections<RestaurantGroupTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RestaurantGroup>(
      rows,
      columns: columns?.call(RestaurantGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RestaurantGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RestaurantGroup> updateRow(
    _is.DatabaseSession session,
    RestaurantGroup row, {
    _is.ColumnSelections<RestaurantGroupTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RestaurantGroup>(
      row,
      columns: columns?.call(RestaurantGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestaurantGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RestaurantGroup?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RestaurantGroupUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RestaurantGroup>(
      id,
      columnValues: columnValues(RestaurantGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantGroup>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RestaurantGroupUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RestaurantGroupTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantGroupTable>? orderBy,
    _is.OrderByListBuilder<RestaurantGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RestaurantGroup>(
      columnValues: columnValues(RestaurantGroup.t.updateTable),
      where: where(RestaurantGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantGroup.t),
      orderByList: orderByList?.call(RestaurantGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RestaurantGroup]s in the list and returns the deleted rows.
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
  Future<List<RestaurantGroup>> delete(
    _is.DatabaseSession session,
    List<RestaurantGroup> rows, {
    _is.OrderByBuilder<RestaurantGroupTable>? orderBy,
    _is.OrderByListBuilder<RestaurantGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RestaurantGroup>(
      rows,
      orderBy: orderBy?.call(RestaurantGroup.t),
      orderByList: orderByList?.call(RestaurantGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RestaurantGroup].
  Future<RestaurantGroup> deleteRow(
    _is.DatabaseSession session,
    RestaurantGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RestaurantGroup>(
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
  Future<List<RestaurantGroup>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantGroupTable> where,
    _is.OrderByBuilder<RestaurantGroupTable>? orderBy,
    _is.OrderByListBuilder<RestaurantGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RestaurantGroup>(
      where: where(RestaurantGroup.t),
      orderBy: orderBy?.call(RestaurantGroup.t),
      orderByList: orderByList?.call(RestaurantGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantGroupTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RestaurantGroup>(
      where: where?.call(RestaurantGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RestaurantGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantGroupTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RestaurantGroup>(
      where: where(RestaurantGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
