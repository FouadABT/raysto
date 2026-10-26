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

abstract class MenuDraft
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MenuDraft._({
    this.id,
    required this.restaurantId,
    required this.userId,
    required this.itemsJson,
    required this.baseMenuVersion,
    required this.version,
    required this.status,
    required this.createdAt,
  });

  factory MenuDraft({
    int? id,
    required int restaurantId,
    required String userId,
    required String itemsJson,
    required int baseMenuVersion,
    required int version,
    required String status,
    required DateTime createdAt,
  }) = _MenuDraftImpl;

  factory MenuDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return MenuDraft(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      itemsJson: jsonSerialization['itemsJson'] as String,
      baseMenuVersion: jsonSerialization['baseMenuVersion'] as int,
      version: jsonSerialization['version'] as int,
      status: jsonSerialization['status'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MenuDraftTable();

  static const db = MenuDraftRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  String itemsJson;

  int baseMenuVersion;

  int version;

  String status;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MenuDraft]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MenuDraft copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? itemsJson,
    int? baseMenuVersion,
    int? version,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MenuDraft',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'itemsJson': itemsJson,
      'baseMenuVersion': baseMenuVersion,
      'version': version,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static MenuDraftInclude include() {
    return MenuDraftInclude._();
  }

  static MenuDraftIncludeList includeList({
    _is.WhereExpressionBuilder<MenuDraftTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuDraftTable>? orderBy,
    _is.OrderByListBuilder<MenuDraftTable>? orderByList,
    MenuDraftInclude? include,
  }) {
    return MenuDraftIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MenuDraft.t),
      orderByList: orderByList?.call(MenuDraft.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MenuDraftImpl extends MenuDraft {
  _MenuDraftImpl({
    int? id,
    required int restaurantId,
    required String userId,
    required String itemsJson,
    required int baseMenuVersion,
    required int version,
    required String status,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         itemsJson: itemsJson,
         baseMenuVersion: baseMenuVersion,
         version: version,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MenuDraft]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MenuDraft copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    String? itemsJson,
    int? baseMenuVersion,
    int? version,
    String? status,
    DateTime? createdAt,
  }) {
    return MenuDraft(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      itemsJson: itemsJson ?? this.itemsJson,
      baseMenuVersion: baseMenuVersion ?? this.baseMenuVersion,
      version: version ?? this.version,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MenuDraftUpdateTable extends _is.UpdateTable<MenuDraftTable> {
  MenuDraftUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> itemsJson(String value) => _is.ColumnValue(
    table.itemsJson,
    value,
  );

  _is.ColumnValue<int, int> baseMenuVersion(int value) => _is.ColumnValue(
    table.baseMenuVersion,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MenuDraftTable extends _is.Table<int?> {
  MenuDraftTable({super.tableRelation})
    : super(tableName: 'raysto_menu_draft') {
    updateTable = MenuDraftUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    itemsJson = _is.ColumnString(
      'itemsJson',
      this,
    );
    baseMenuVersion = _is.ColumnInt(
      'baseMenuVersion',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MenuDraftUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString itemsJson;

  late final _is.ColumnInt baseMenuVersion;

  late final _is.ColumnInt version;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    itemsJson,
    baseMenuVersion,
    version,
    status,
    createdAt,
  ];
}

class MenuDraftInclude extends _is.IncludeObject {
  MenuDraftInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MenuDraft.t;
}

class MenuDraftIncludeList extends _is.IncludeList {
  MenuDraftIncludeList._({
    _is.WhereExpressionBuilder<MenuDraftTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MenuDraft.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MenuDraft.t;
}

class MenuDraftRepository {
  const MenuDraftRepository._();

  /// Returns a list of [MenuDraft]s matching the given query parameters.
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
  Future<List<MenuDraft>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuDraftTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuDraftTable>? orderBy,
    _is.OrderByListBuilder<MenuDraftTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MenuDraft>(
      where: where?.call(MenuDraft.t),
      orderBy: orderBy?.call(MenuDraft.t),
      orderByList: orderByList?.call(MenuDraft.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MenuDraft] matching the given query parameters.
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
  Future<MenuDraft?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuDraftTable>? where,
    int? offset,
    _is.OrderByBuilder<MenuDraftTable>? orderBy,
    _is.OrderByListBuilder<MenuDraftTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MenuDraft>(
      where: where?.call(MenuDraft.t),
      orderBy: orderBy?.call(MenuDraft.t),
      orderByList: orderByList?.call(MenuDraft.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MenuDraft] by its [id] or null if no such row exists.
  Future<MenuDraft?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MenuDraft>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MenuDraft]s in the list and returns the inserted rows.
  ///
  /// The returned [MenuDraft]s will have their `id` fields set.
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
  Future<List<MenuDraft>> insert(
    _is.DatabaseSession session,
    List<MenuDraft> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MenuDraft>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MenuDraft] and returns the inserted row.
  ///
  /// The returned [MenuDraft] will have its `id` field set.
  Future<MenuDraft> insertRow(
    _is.DatabaseSession session,
    MenuDraft row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MenuDraft>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MenuDraft]s in the list and returns the resulting rows.
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
  /// The returned [MenuDraft]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuDraft>> upsert(
    _is.DatabaseSession session,
    List<MenuDraft> rows, {
    required _is.ColumnSelections<MenuDraftTable> conflictColumns,
    _is.ColumnSelections<MenuDraftTable>? updateColumns,
    _is.WhereExpressionBuilder<MenuDraftTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MenuDraft>(
      rows,
      conflictColumns: conflictColumns(MenuDraft.t),
      updateColumns: updateColumns?.call(MenuDraft.t),
      updateWhere: updateWhere?.call(MenuDraft.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MenuDraft] and returns the resulting row.
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
  /// The returned [MenuDraft] will have its `id` field set.
  Future<MenuDraft?> upsertRow(
    _is.DatabaseSession session,
    MenuDraft row, {
    required _is.ColumnSelections<MenuDraftTable> conflictColumns,
    _is.ColumnSelections<MenuDraftTable>? updateColumns,
    _is.WhereExpressionBuilder<MenuDraftTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MenuDraft>(
      row,
      conflictColumns: conflictColumns(MenuDraft.t),
      updateColumns: updateColumns?.call(MenuDraft.t),
      updateWhere: updateWhere?.call(MenuDraft.t),
      transaction: transaction,
    );
  }

  /// Updates all [MenuDraft]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuDraft>> update(
    _is.DatabaseSession session,
    List<MenuDraft> rows, {
    _is.ColumnSelections<MenuDraftTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MenuDraft>(
      rows,
      columns: columns?.call(MenuDraft.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MenuDraft]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MenuDraft> updateRow(
    _is.DatabaseSession session,
    MenuDraft row, {
    _is.ColumnSelections<MenuDraftTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MenuDraft>(
      row,
      columns: columns?.call(MenuDraft.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MenuDraft] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MenuDraft?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MenuDraftUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MenuDraft>(
      id,
      columnValues: columnValues(MenuDraft.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MenuDraft]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuDraft>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MenuDraftUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MenuDraftTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuDraftTable>? orderBy,
    _is.OrderByListBuilder<MenuDraftTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MenuDraft>(
      columnValues: columnValues(MenuDraft.t.updateTable),
      where: where(MenuDraft.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MenuDraft.t),
      orderByList: orderByList?.call(MenuDraft.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MenuDraft]s in the list and returns the deleted rows.
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
  Future<List<MenuDraft>> delete(
    _is.DatabaseSession session,
    List<MenuDraft> rows, {
    _is.OrderByBuilder<MenuDraftTable>? orderBy,
    _is.OrderByListBuilder<MenuDraftTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MenuDraft>(
      rows,
      orderBy: orderBy?.call(MenuDraft.t),
      orderByList: orderByList?.call(MenuDraft.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MenuDraft].
  Future<MenuDraft> deleteRow(
    _is.DatabaseSession session,
    MenuDraft row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MenuDraft>(
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
  Future<List<MenuDraft>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MenuDraftTable> where,
    _is.OrderByBuilder<MenuDraftTable>? orderBy,
    _is.OrderByListBuilder<MenuDraftTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MenuDraft>(
      where: where(MenuDraft.t),
      orderBy: orderBy?.call(MenuDraft.t),
      orderByList: orderByList?.call(MenuDraft.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuDraftTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MenuDraft>(
      where: where?.call(MenuDraft.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MenuDraft] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MenuDraftTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MenuDraft>(
      where: where(MenuDraft.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
