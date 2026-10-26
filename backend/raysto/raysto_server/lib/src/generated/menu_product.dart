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

abstract class MenuProduct
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MenuProduct._({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.available,
    required this.version,
  });

  factory MenuProduct({
    int? id,
    required int restaurantId,
    required String name,
    required String description,
    required int priceMinor,
    required bool available,
    required int version,
  }) = _MenuProductImpl;

  factory MenuProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return MenuProduct(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      priceMinor: jsonSerialization['priceMinor'] as int,
      available: _is.BoolJsonExtension.fromJson(jsonSerialization['available']),
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = MenuProductTable();

  static const db = MenuProductRepository._();

  @override
  int? id;

  int restaurantId;

  String name;

  String description;

  int priceMinor;

  bool available;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MenuProduct]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MenuProduct copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? description,
    int? priceMinor,
    bool? available,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MenuProduct',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'priceMinor': priceMinor,
      'available': available,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MenuProduct',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'priceMinor': priceMinor,
      'available': available,
      'version': version,
    };
  }

  static MenuProductInclude include() {
    return MenuProductInclude._();
  }

  static MenuProductIncludeList includeList({
    _is.WhereExpressionBuilder<MenuProductTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuProductTable>? orderBy,
    _is.OrderByListBuilder<MenuProductTable>? orderByList,
    MenuProductInclude? include,
  }) {
    return MenuProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MenuProduct.t),
      orderByList: orderByList?.call(MenuProduct.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MenuProductImpl extends MenuProduct {
  _MenuProductImpl({
    int? id,
    required int restaurantId,
    required String name,
    required String description,
    required int priceMinor,
    required bool available,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         name: name,
         description: description,
         priceMinor: priceMinor,
         available: available,
         version: version,
       );

  /// Returns a shallow copy of this [MenuProduct]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MenuProduct copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? name,
    String? description,
    int? priceMinor,
    bool? available,
    int? version,
  }) {
    return MenuProduct(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceMinor: priceMinor ?? this.priceMinor,
      available: available ?? this.available,
      version: version ?? this.version,
    );
  }
}

class MenuProductUpdateTable extends _is.UpdateTable<MenuProductTable> {
  MenuProductUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<int, int> priceMinor(int value) => _is.ColumnValue(
    table.priceMinor,
    value,
  );

  _is.ColumnValue<bool, bool> available(bool value) => _is.ColumnValue(
    table.available,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class MenuProductTable extends _is.Table<int?> {
  MenuProductTable({super.tableRelation})
    : super(tableName: 'raysto_menu_product') {
    updateTable = MenuProductUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    priceMinor = _is.ColumnInt(
      'priceMinor',
      this,
    );
    available = _is.ColumnBool(
      'available',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final MenuProductUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString name;

  late final _is.ColumnString description;

  late final _is.ColumnInt priceMinor;

  late final _is.ColumnBool available;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    name,
    description,
    priceMinor,
    available,
    version,
  ];
}

class MenuProductInclude extends _is.IncludeObject {
  MenuProductInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MenuProduct.t;
}

class MenuProductIncludeList extends _is.IncludeList {
  MenuProductIncludeList._({
    _is.WhereExpressionBuilder<MenuProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MenuProduct.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MenuProduct.t;
}

class MenuProductRepository {
  const MenuProductRepository._();

  /// Returns a list of [MenuProduct]s matching the given query parameters.
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
  Future<List<MenuProduct>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuProductTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuProductTable>? orderBy,
    _is.OrderByListBuilder<MenuProductTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MenuProduct>(
      where: where?.call(MenuProduct.t),
      orderBy: orderBy?.call(MenuProduct.t),
      orderByList: orderByList?.call(MenuProduct.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MenuProduct] matching the given query parameters.
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
  Future<MenuProduct?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuProductTable>? where,
    int? offset,
    _is.OrderByBuilder<MenuProductTable>? orderBy,
    _is.OrderByListBuilder<MenuProductTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MenuProduct>(
      where: where?.call(MenuProduct.t),
      orderBy: orderBy?.call(MenuProduct.t),
      orderByList: orderByList?.call(MenuProduct.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MenuProduct] by its [id] or null if no such row exists.
  Future<MenuProduct?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MenuProduct>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MenuProduct]s in the list and returns the inserted rows.
  ///
  /// The returned [MenuProduct]s will have their `id` fields set.
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
  Future<List<MenuProduct>> insert(
    _is.DatabaseSession session,
    List<MenuProduct> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MenuProduct>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MenuProduct] and returns the inserted row.
  ///
  /// The returned [MenuProduct] will have its `id` field set.
  Future<MenuProduct> insertRow(
    _is.DatabaseSession session,
    MenuProduct row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MenuProduct>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MenuProduct]s in the list and returns the resulting rows.
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
  /// The returned [MenuProduct]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuProduct>> upsert(
    _is.DatabaseSession session,
    List<MenuProduct> rows, {
    required _is.ColumnSelections<MenuProductTable> conflictColumns,
    _is.ColumnSelections<MenuProductTable>? updateColumns,
    _is.WhereExpressionBuilder<MenuProductTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MenuProduct>(
      rows,
      conflictColumns: conflictColumns(MenuProduct.t),
      updateColumns: updateColumns?.call(MenuProduct.t),
      updateWhere: updateWhere?.call(MenuProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MenuProduct] and returns the resulting row.
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
  /// The returned [MenuProduct] will have its `id` field set.
  Future<MenuProduct?> upsertRow(
    _is.DatabaseSession session,
    MenuProduct row, {
    required _is.ColumnSelections<MenuProductTable> conflictColumns,
    _is.ColumnSelections<MenuProductTable>? updateColumns,
    _is.WhereExpressionBuilder<MenuProductTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MenuProduct>(
      row,
      conflictColumns: conflictColumns(MenuProduct.t),
      updateColumns: updateColumns?.call(MenuProduct.t),
      updateWhere: updateWhere?.call(MenuProduct.t),
      transaction: transaction,
    );
  }

  /// Updates all [MenuProduct]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuProduct>> update(
    _is.DatabaseSession session,
    List<MenuProduct> rows, {
    _is.ColumnSelections<MenuProductTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MenuProduct>(
      rows,
      columns: columns?.call(MenuProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MenuProduct]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MenuProduct> updateRow(
    _is.DatabaseSession session,
    MenuProduct row, {
    _is.ColumnSelections<MenuProductTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MenuProduct>(
      row,
      columns: columns?.call(MenuProduct.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MenuProduct] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MenuProduct?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MenuProductUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MenuProduct>(
      id,
      columnValues: columnValues(MenuProduct.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MenuProduct]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MenuProduct>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MenuProductUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MenuProductTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MenuProductTable>? orderBy,
    _is.OrderByListBuilder<MenuProductTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MenuProduct>(
      columnValues: columnValues(MenuProduct.t.updateTable),
      where: where(MenuProduct.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MenuProduct.t),
      orderByList: orderByList?.call(MenuProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MenuProduct]s in the list and returns the deleted rows.
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
  Future<List<MenuProduct>> delete(
    _is.DatabaseSession session,
    List<MenuProduct> rows, {
    _is.OrderByBuilder<MenuProductTable>? orderBy,
    _is.OrderByListBuilder<MenuProductTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MenuProduct>(
      rows,
      orderBy: orderBy?.call(MenuProduct.t),
      orderByList: orderByList?.call(MenuProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MenuProduct].
  Future<MenuProduct> deleteRow(
    _is.DatabaseSession session,
    MenuProduct row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MenuProduct>(
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
  Future<List<MenuProduct>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MenuProductTable> where,
    _is.OrderByBuilder<MenuProductTable>? orderBy,
    _is.OrderByListBuilder<MenuProductTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MenuProduct>(
      where: where(MenuProduct.t),
      orderBy: orderBy?.call(MenuProduct.t),
      orderByList: orderByList?.call(MenuProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MenuProductTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MenuProduct>(
      where: where?.call(MenuProduct.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MenuProduct] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MenuProductTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MenuProduct>(
      where: where(MenuProduct.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
