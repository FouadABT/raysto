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

abstract class RecipeLine
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RecipeLine._({
    this.id,
    required this.restaurantId,
    required this.productId,
    required this.stockItemId,
    required this.quantity,
    required this.updatedAt,
  });

  factory RecipeLine({
    int? id,
    required int restaurantId,
    required int productId,
    required int stockItemId,
    required double quantity,
    required DateTime updatedAt,
  }) = _RecipeLineImpl;

  factory RecipeLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecipeLine(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      productId: jsonSerialization['productId'] as int,
      stockItemId: jsonSerialization['stockItemId'] as int,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = RecipeLineTable();

  static const db = RecipeLineRepository._();

  @override
  int? id;

  int restaurantId;

  int productId;

  int stockItemId;

  double quantity;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RecipeLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecipeLine copyWith({
    int? id,
    int? restaurantId,
    int? productId,
    int? stockItemId,
    double? quantity,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecipeLine',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'productId': productId,
      'stockItemId': stockItemId,
      'quantity': quantity,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RecipeLineInclude include() {
    return RecipeLineInclude._();
  }

  static RecipeLineIncludeList includeList({
    _is.WhereExpressionBuilder<RecipeLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeLineTable>? orderBy,
    _is.OrderByListBuilder<RecipeLineTable>? orderByList,
    RecipeLineInclude? include,
  }) {
    return RecipeLineIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeLine.t),
      orderByList: orderByList?.call(RecipeLine.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecipeLineImpl extends RecipeLine {
  _RecipeLineImpl({
    int? id,
    required int restaurantId,
    required int productId,
    required int stockItemId,
    required double quantity,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         productId: productId,
         stockItemId: stockItemId,
         quantity: quantity,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RecipeLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecipeLine copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? productId,
    int? stockItemId,
    double? quantity,
    DateTime? updatedAt,
  }) {
    return RecipeLine(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      productId: productId ?? this.productId,
      stockItemId: stockItemId ?? this.stockItemId,
      quantity: quantity ?? this.quantity,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RecipeLineUpdateTable extends _is.UpdateTable<RecipeLineTable> {
  RecipeLineUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> productId(int value) => _is.ColumnValue(
    table.productId,
    value,
  );

  _is.ColumnValue<int, int> stockItemId(int value) => _is.ColumnValue(
    table.stockItemId,
    value,
  );

  _is.ColumnValue<double, double> quantity(double value) => _is.ColumnValue(
    table.quantity,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RecipeLineTable extends _is.Table<int?> {
  RecipeLineTable({super.tableRelation})
    : super(tableName: 'raysto_recipe_line') {
    updateTable = RecipeLineUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    productId = _is.ColumnInt(
      'productId',
      this,
    );
    stockItemId = _is.ColumnInt(
      'stockItemId',
      this,
    );
    quantity = _is.ColumnDouble(
      'quantity',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RecipeLineUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt productId;

  late final _is.ColumnInt stockItemId;

  late final _is.ColumnDouble quantity;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    productId,
    stockItemId,
    quantity,
    updatedAt,
  ];
}

class RecipeLineInclude extends _is.IncludeObject {
  RecipeLineInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RecipeLine.t;
}

class RecipeLineIncludeList extends _is.IncludeList {
  RecipeLineIncludeList._({
    _is.WhereExpressionBuilder<RecipeLineTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecipeLine.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RecipeLine.t;
}

class RecipeLineRepository {
  const RecipeLineRepository._();

  /// Returns a list of [RecipeLine]s matching the given query parameters.
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
  Future<List<RecipeLine>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeLineTable>? orderBy,
    _is.OrderByListBuilder<RecipeLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RecipeLine>(
      where: where?.call(RecipeLine.t),
      orderBy: orderBy?.call(RecipeLine.t),
      orderByList: orderByList?.call(RecipeLine.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RecipeLine] matching the given query parameters.
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
  Future<RecipeLine?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeLineTable>? where,
    int? offset,
    _is.OrderByBuilder<RecipeLineTable>? orderBy,
    _is.OrderByListBuilder<RecipeLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RecipeLine>(
      where: where?.call(RecipeLine.t),
      orderBy: orderBy?.call(RecipeLine.t),
      orderByList: orderByList?.call(RecipeLine.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RecipeLine] by its [id] or null if no such row exists.
  Future<RecipeLine?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RecipeLine>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RecipeLine]s in the list and returns the inserted rows.
  ///
  /// The returned [RecipeLine]s will have their `id` fields set.
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
  Future<List<RecipeLine>> insert(
    _is.DatabaseSession session,
    List<RecipeLine> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RecipeLine>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RecipeLine] and returns the inserted row.
  ///
  /// The returned [RecipeLine] will have its `id` field set.
  Future<RecipeLine> insertRow(
    _is.DatabaseSession session,
    RecipeLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecipeLine>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RecipeLine]s in the list and returns the resulting rows.
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
  /// The returned [RecipeLine]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeLine>> upsert(
    _is.DatabaseSession session,
    List<RecipeLine> rows, {
    required _is.ColumnSelections<RecipeLineTable> conflictColumns,
    _is.ColumnSelections<RecipeLineTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeLineTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RecipeLine>(
      rows,
      conflictColumns: conflictColumns(RecipeLine.t),
      updateColumns: updateColumns?.call(RecipeLine.t),
      updateWhere: updateWhere?.call(RecipeLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RecipeLine] and returns the resulting row.
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
  /// The returned [RecipeLine] will have its `id` field set.
  Future<RecipeLine?> upsertRow(
    _is.DatabaseSession session,
    RecipeLine row, {
    required _is.ColumnSelections<RecipeLineTable> conflictColumns,
    _is.ColumnSelections<RecipeLineTable>? updateColumns,
    _is.WhereExpressionBuilder<RecipeLineTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RecipeLine>(
      row,
      conflictColumns: conflictColumns(RecipeLine.t),
      updateColumns: updateColumns?.call(RecipeLine.t),
      updateWhere: updateWhere?.call(RecipeLine.t),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeLine]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeLine>> update(
    _is.DatabaseSession session,
    List<RecipeLine> rows, {
    _is.ColumnSelections<RecipeLineTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RecipeLine>(
      rows,
      columns: columns?.call(RecipeLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RecipeLine]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecipeLine> updateRow(
    _is.DatabaseSession session,
    RecipeLine row, {
    _is.ColumnSelections<RecipeLineTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecipeLine>(
      row,
      columns: columns?.call(RecipeLine.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecipeLine] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecipeLine?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RecipeLineUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RecipeLine>(
      id,
      columnValues: columnValues(RecipeLine.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecipeLine]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecipeLine>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecipeLineUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RecipeLineTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecipeLineTable>? orderBy,
    _is.OrderByListBuilder<RecipeLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RecipeLine>(
      columnValues: columnValues(RecipeLine.t.updateTable),
      where: where(RecipeLine.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecipeLine.t),
      orderByList: orderByList?.call(RecipeLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RecipeLine]s in the list and returns the deleted rows.
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
  Future<List<RecipeLine>> delete(
    _is.DatabaseSession session,
    List<RecipeLine> rows, {
    _is.OrderByBuilder<RecipeLineTable>? orderBy,
    _is.OrderByListBuilder<RecipeLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RecipeLine>(
      rows,
      orderBy: orderBy?.call(RecipeLine.t),
      orderByList: orderByList?.call(RecipeLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RecipeLine].
  Future<RecipeLine> deleteRow(
    _is.DatabaseSession session,
    RecipeLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecipeLine>(
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
  Future<List<RecipeLine>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeLineTable> where,
    _is.OrderByBuilder<RecipeLineTable>? orderBy,
    _is.OrderByListBuilder<RecipeLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RecipeLine>(
      where: where(RecipeLine.t),
      orderBy: orderBy?.call(RecipeLine.t),
      orderByList: orderByList?.call(RecipeLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecipeLineTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RecipeLine>(
      where: where?.call(RecipeLine.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RecipeLine] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecipeLineTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RecipeLine>(
      where: where(RecipeLine.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
