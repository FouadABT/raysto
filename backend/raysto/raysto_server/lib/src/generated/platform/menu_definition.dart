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

abstract class MenuDefinition
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MenuDefinition._({
    this.id,
    required this.restaurantId,
    required this.productId,
    required this.category,
    required this.definitionJson,
    required this.archived,
    this.stockRemaining,
    required this.version,
  });

  factory MenuDefinition({
    int? id,
    required int restaurantId,
    required int productId,
    required String category,
    required String definitionJson,
    required bool archived,
    int? stockRemaining,
    required int version,
  }) = _MenuDefinitionImpl;

  factory MenuDefinition.fromJson(Map<String, dynamic> jsonSerialization) {
    return MenuDefinition(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      productId: jsonSerialization['productId'] as int,
      category: jsonSerialization['category'] as String,
      definitionJson: jsonSerialization['definitionJson'] as String,
      archived: _is.BoolJsonExtension.fromJson(jsonSerialization['archived']),
      stockRemaining: jsonSerialization['stockRemaining'] as int?,
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = MenuDefinitionTable();

  static const db = MenuDefinitionRepository._();

  @override
  int? id;

  int restaurantId;

  int productId;

  String category;

  String definitionJson;

  bool archived;

  int? stockRemaining;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MenuDefinition]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MenuDefinition copyWith({
    int? id,
    int? restaurantId,
    int? productId,
    String? category,
    String? definitionJson,
    bool? archived,
    int? stockRemaining,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MenuDefinition',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'productId': productId,
      'category': category,
      'definitionJson': definitionJson,
      'archived': archived,
      if (stockRemaining != null) 'stockRemaining': stockRemaining,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static MenuDefinitionInclude include() {
    return MenuDefinitionInclude._();
  }

  static MenuDefinitionIncludeList includeList({
    _is.WhereExpressionBuilder<MenuDefinitionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuDefinitionTable>? orderBy,
    _is.OrderByListBuilder<MenuDefinitionTable>? orderByList,
    MenuDefinitionInclude? include,
  }) {
    return MenuDefinitionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MenuDefinition.t),
      orderByList: orderByList?.call(MenuDefinition.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MenuDefinitionImpl extends MenuDefinition {
  _MenuDefinitionImpl({
    int? id,
    required int restaurantId,
    required int productId,
    required String category,
    required String definitionJson,
    required bool archived,
    int? stockRemaining,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         productId: productId,
         category: category,
         definitionJson: definitionJson,
         archived: archived,
         stockRemaining: stockRemaining,
         version: version,
       );

  /// Returns a shallow copy of this [MenuDefinition]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MenuDefinition copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? productId,
    String? category,
    String? definitionJson,
    bool? archived,
    Object? stockRemaining = _Undefined,
    int? version,
  }) {
    return MenuDefinition(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      productId: productId ?? this.productId,
      category: category ?? this.category,
      definitionJson: definitionJson ?? this.definitionJson,
      archived: archived ?? this.archived,
      stockRemaining: stockRemaining is int?
          ? stockRemaining
          : this.stockRemaining,
      version: version ?? this.version,
    );
  }
}

class MenuDefinitionUpdateTable extends _is.UpdateTable<MenuDefinitionTable> {
  MenuDefinitionUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> productId(int value) => _is.ColumnValue(
    table.productId,
    value,
  );

  _is.ColumnValue<String, String> category(String value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<String, String> definitionJson(String value) =>
      _is.ColumnValue(
        table.definitionJson,
        value,
      );

  _is.ColumnValue<bool, bool> archived(bool value) => _is.ColumnValue(
    table.archived,
    value,
  );

  _is.ColumnValue<int, int> stockRemaining(int? value) => _is.ColumnValue(
    table.stockRemaining,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class MenuDefinitionTable extends _is.Table<int?> {
  MenuDefinitionTable({super.tableRelation})
    : super(tableName: 'raysto_menu_definition') {
    updateTable = MenuDefinitionUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    productId = _is.ColumnInt(
      'productId',
      this,
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    definitionJson = _is.ColumnString(
      'definitionJson',
      this,
    );
    archived = _is.ColumnBool(
      'archived',
      this,
    );
    stockRemaining = _is.ColumnInt(
      'stockRemaining',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final MenuDefinitionUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt productId;

  late final _is.ColumnString category;

  late final _is.ColumnString definitionJson;

  late final _is.ColumnBool archived;

  late final _is.ColumnInt stockRemaining;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    productId,
    category,
    definitionJson,
    archived,
    stockRemaining,
    version,
  ];
}

class MenuDefinitionInclude extends _is.IncludeObject {
  MenuDefinitionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MenuDefinition.t;
}

class MenuDefinitionIncludeList extends _is.IncludeList {
  MenuDefinitionIncludeList._({
    _is.WhereExpressionBuilder<MenuDefinitionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MenuDefinition.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MenuDefinition.t;
}

class MenuDefinitionRepository {
  const MenuDefinitionRepository._();

  /// Returns a list of [MenuDefinition]s matching the given query parameters.
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
  Future<List<MenuDefinition>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuDefinitionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuDefinitionTable>? orderBy,
    _is.OrderByListBuilder<MenuDefinitionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MenuDefinition>(
      where: where?.call(MenuDefinition.t),
      orderBy: orderBy?.call(MenuDefinition.t),
      orderByList: orderByList?.call(MenuDefinition.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MenuDefinition] matching the given query parameters.
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
  Future<MenuDefinition?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuDefinitionTable>? where,
    int? offset,
    _is.OrderByBuilder<MenuDefinitionTable>? orderBy,
    _is.OrderByListBuilder<MenuDefinitionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MenuDefinition>(
      where: where?.call(MenuDefinition.t),
      orderBy: orderBy?.call(MenuDefinition.t),
      orderByList: orderByList?.call(MenuDefinition.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MenuDefinition] by its [id] or null if no such row exists.
  Future<MenuDefinition?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MenuDefinition>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MenuDefinition]s in the list and returns the inserted rows.
  ///
  /// The returned [MenuDefinition]s will have their `id` fields set.
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
  Future<List<MenuDefinition>> insert(
    _is.DatabaseSession session,
    List<MenuDefinition> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MenuDefinition>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MenuDefinition] and returns the inserted row.
  ///
  /// The returned [MenuDefinition] will have its `id` field set.
  Future<MenuDefinition> insertRow(
    _is.DatabaseSession session,
    MenuDefinition row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MenuDefinition>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MenuDefinition]s in the list and returns the resulting rows.
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
  /// The returned [MenuDefinition]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuDefinition>> upsert(
    _is.DatabaseSession session,
    List<MenuDefinition> rows, {
    required _is.ColumnSelections<MenuDefinitionTable> conflictColumns,
    _is.ColumnSelections<MenuDefinitionTable>? updateColumns,
    _is.WhereExpressionBuilder<MenuDefinitionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MenuDefinition>(
      rows,
      conflictColumns: conflictColumns(MenuDefinition.t),
      updateColumns: updateColumns?.call(MenuDefinition.t),
      updateWhere: updateWhere?.call(MenuDefinition.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MenuDefinition] and returns the resulting row.
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
  /// The returned [MenuDefinition] will have its `id` field set.
  Future<MenuDefinition?> upsertRow(
    _is.DatabaseSession session,
    MenuDefinition row, {
    required _is.ColumnSelections<MenuDefinitionTable> conflictColumns,
    _is.ColumnSelections<MenuDefinitionTable>? updateColumns,
    _is.WhereExpressionBuilder<MenuDefinitionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MenuDefinition>(
      row,
      conflictColumns: conflictColumns(MenuDefinition.t),
      updateColumns: updateColumns?.call(MenuDefinition.t),
      updateWhere: updateWhere?.call(MenuDefinition.t),
      transaction: transaction,
    );
  }

  /// Updates all [MenuDefinition]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuDefinition>> update(
    _is.DatabaseSession session,
    List<MenuDefinition> rows, {
    _is.ColumnSelections<MenuDefinitionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MenuDefinition>(
      rows,
      columns: columns?.call(MenuDefinition.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MenuDefinition]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MenuDefinition> updateRow(
    _is.DatabaseSession session,
    MenuDefinition row, {
    _is.ColumnSelections<MenuDefinitionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MenuDefinition>(
      row,
      columns: columns?.call(MenuDefinition.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MenuDefinition] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MenuDefinition?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MenuDefinitionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MenuDefinition>(
      id,
      columnValues: columnValues(MenuDefinition.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MenuDefinition]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuDefinition>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MenuDefinitionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MenuDefinitionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuDefinitionTable>? orderBy,
    _is.OrderByListBuilder<MenuDefinitionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MenuDefinition>(
      columnValues: columnValues(MenuDefinition.t.updateTable),
      where: where(MenuDefinition.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MenuDefinition.t),
      orderByList: orderByList?.call(MenuDefinition.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MenuDefinition]s in the list and returns the deleted rows.
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
  Future<List<MenuDefinition>> delete(
    _is.DatabaseSession session,
    List<MenuDefinition> rows, {
    _is.OrderByBuilder<MenuDefinitionTable>? orderBy,
    _is.OrderByListBuilder<MenuDefinitionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MenuDefinition>(
      rows,
      orderBy: orderBy?.call(MenuDefinition.t),
      orderByList: orderByList?.call(MenuDefinition.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MenuDefinition].
  Future<MenuDefinition> deleteRow(
    _is.DatabaseSession session,
    MenuDefinition row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MenuDefinition>(
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
  Future<List<MenuDefinition>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MenuDefinitionTable> where,
    _is.OrderByBuilder<MenuDefinitionTable>? orderBy,
    _is.OrderByListBuilder<MenuDefinitionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MenuDefinition>(
      where: where(MenuDefinition.t),
      orderBy: orderBy?.call(MenuDefinition.t),
      orderByList: orderByList?.call(MenuDefinition.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuDefinitionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MenuDefinition>(
      where: where?.call(MenuDefinition.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MenuDefinition] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MenuDefinitionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MenuDefinition>(
      where: where(MenuDefinition.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
