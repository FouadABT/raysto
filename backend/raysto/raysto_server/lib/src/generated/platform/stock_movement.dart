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

abstract class StockMovement
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StockMovement._({
    this.id,
    required this.restaurantId,
    required this.stockItemId,
    required this.kind,
    required this.quantity,
    this.unitCostMinor,
    this.purchaseUnit,
    required this.refType,
    required this.refId,
    required this.at,
    this.userId,
  });

  factory StockMovement({
    int? id,
    required int restaurantId,
    required int stockItemId,
    required String kind,
    required double quantity,
    int? unitCostMinor,
    String? purchaseUnit,
    required String refType,
    required String refId,
    required DateTime at,
    String? userId,
  }) = _StockMovementImpl;

  factory StockMovement.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockMovement(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      stockItemId: jsonSerialization['stockItemId'] as int,
      kind: jsonSerialization['kind'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      unitCostMinor: jsonSerialization['unitCostMinor'] as int?,
      purchaseUnit: jsonSerialization['purchaseUnit'] as String?,
      refType: jsonSerialization['refType'] as String,
      refId: jsonSerialization['refId'] as String,
      at: _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      userId: jsonSerialization['userId'] as String?,
    );
  }

  static final t = StockMovementTable();

  static const db = StockMovementRepository._();

  @override
  int? id;

  int restaurantId;

  int stockItemId;

  String kind;

  double quantity;

  int? unitCostMinor;

  String? purchaseUnit;

  String refType;

  String refId;

  DateTime at;

  String? userId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StockMovement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StockMovement copyWith({
    int? id,
    int? restaurantId,
    int? stockItemId,
    String? kind,
    double? quantity,
    int? unitCostMinor,
    String? purchaseUnit,
    String? refType,
    String? refId,
    DateTime? at,
    String? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StockMovement',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'stockItemId': stockItemId,
      'kind': kind,
      'quantity': quantity,
      if (unitCostMinor != null) 'unitCostMinor': unitCostMinor,
      if (purchaseUnit != null) 'purchaseUnit': purchaseUnit,
      'refType': refType,
      'refId': refId,
      'at': at.toJson(),
      if (userId != null) 'userId': userId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StockMovementInclude include() {
    return StockMovementInclude._();
  }

  static StockMovementIncludeList includeList({
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    StockMovementInclude? include,
  }) {
    return StockMovementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockMovementImpl extends StockMovement {
  _StockMovementImpl({
    int? id,
    required int restaurantId,
    required int stockItemId,
    required String kind,
    required double quantity,
    int? unitCostMinor,
    String? purchaseUnit,
    required String refType,
    required String refId,
    required DateTime at,
    String? userId,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         stockItemId: stockItemId,
         kind: kind,
         quantity: quantity,
         unitCostMinor: unitCostMinor,
         purchaseUnit: purchaseUnit,
         refType: refType,
         refId: refId,
         at: at,
         userId: userId,
       );

  /// Returns a shallow copy of this [StockMovement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StockMovement copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? stockItemId,
    String? kind,
    double? quantity,
    Object? unitCostMinor = _Undefined,
    Object? purchaseUnit = _Undefined,
    String? refType,
    String? refId,
    DateTime? at,
    Object? userId = _Undefined,
  }) {
    return StockMovement(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      stockItemId: stockItemId ?? this.stockItemId,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      unitCostMinor: unitCostMinor is int? ? unitCostMinor : this.unitCostMinor,
      purchaseUnit: purchaseUnit is String? ? purchaseUnit : this.purchaseUnit,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      at: at ?? this.at,
      userId: userId is String? ? userId : this.userId,
    );
  }
}

class StockMovementUpdateTable extends _is.UpdateTable<StockMovementTable> {
  StockMovementUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> stockItemId(int value) => _is.ColumnValue(
    table.stockItemId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<double, double> quantity(double value) => _is.ColumnValue(
    table.quantity,
    value,
  );

  _is.ColumnValue<int, int> unitCostMinor(int? value) => _is.ColumnValue(
    table.unitCostMinor,
    value,
  );

  _is.ColumnValue<String, String> purchaseUnit(String? value) =>
      _is.ColumnValue(
        table.purchaseUnit,
        value,
      );

  _is.ColumnValue<String, String> refType(String value) => _is.ColumnValue(
    table.refType,
    value,
  );

  _is.ColumnValue<String, String> refId(String value) => _is.ColumnValue(
    table.refId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> at(DateTime value) => _is.ColumnValue(
    table.at,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );
}

class StockMovementTable extends _is.Table<int?> {
  StockMovementTable({super.tableRelation})
    : super(tableName: 'raysto_stock_movement') {
    updateTable = StockMovementUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    stockItemId = _is.ColumnInt(
      'stockItemId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    quantity = _is.ColumnDouble(
      'quantity',
      this,
    );
    unitCostMinor = _is.ColumnInt(
      'unitCostMinor',
      this,
    );
    purchaseUnit = _is.ColumnString(
      'purchaseUnit',
      this,
    );
    refType = _is.ColumnString(
      'refType',
      this,
    );
    refId = _is.ColumnString(
      'refId',
      this,
    );
    at = _is.ColumnDateTime(
      'at',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
  }

  late final StockMovementUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt stockItemId;

  late final _is.ColumnString kind;

  late final _is.ColumnDouble quantity;

  late final _is.ColumnInt unitCostMinor;

  late final _is.ColumnString purchaseUnit;

  late final _is.ColumnString refType;

  late final _is.ColumnString refId;

  late final _is.ColumnDateTime at;

  late final _is.ColumnString userId;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    stockItemId,
    kind,
    quantity,
    unitCostMinor,
    purchaseUnit,
    refType,
    refId,
    at,
    userId,
  ];
}

class StockMovementInclude extends _is.IncludeObject {
  StockMovementInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StockMovement.t;
}

class StockMovementIncludeList extends _is.IncludeList {
  StockMovementIncludeList._({
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockMovement.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StockMovement.t;
}

class StockMovementRepository {
  const StockMovementRepository._();

  /// Returns a list of [StockMovement]s matching the given query parameters.
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
  Future<List<StockMovement>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StockMovement>(
      where: where?.call(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StockMovement] matching the given query parameters.
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
  Future<StockMovement?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StockMovement>(
      where: where?.call(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StockMovement] by its [id] or null if no such row exists.
  Future<StockMovement?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StockMovement>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StockMovement]s in the list and returns the inserted rows.
  ///
  /// The returned [StockMovement]s will have their `id` fields set.
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
  Future<List<StockMovement>> insert(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StockMovement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StockMovement] and returns the inserted row.
  ///
  /// The returned [StockMovement] will have its `id` field set.
  Future<StockMovement> insertRow(
    _is.DatabaseSession session,
    StockMovement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StockMovement>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StockMovement]s in the list and returns the resulting rows.
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
  /// The returned [StockMovement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockMovement>> upsert(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    required _is.ColumnSelections<StockMovementTable> conflictColumns,
    _is.ColumnSelections<StockMovementTable>? updateColumns,
    _is.WhereExpressionBuilder<StockMovementTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StockMovement>(
      rows,
      conflictColumns: conflictColumns(StockMovement.t),
      updateColumns: updateColumns?.call(StockMovement.t),
      updateWhere: updateWhere?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StockMovement] and returns the resulting row.
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
  /// The returned [StockMovement] will have its `id` field set.
  Future<StockMovement?> upsertRow(
    _is.DatabaseSession session,
    StockMovement row, {
    required _is.ColumnSelections<StockMovementTable> conflictColumns,
    _is.ColumnSelections<StockMovementTable>? updateColumns,
    _is.WhereExpressionBuilder<StockMovementTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StockMovement>(
      row,
      conflictColumns: conflictColumns(StockMovement.t),
      updateColumns: updateColumns?.call(StockMovement.t),
      updateWhere: updateWhere?.call(StockMovement.t),
      transaction: transaction,
    );
  }

  /// Updates all [StockMovement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockMovement>> update(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    _is.ColumnSelections<StockMovementTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StockMovement>(
      rows,
      columns: columns?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StockMovement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StockMovement> updateRow(
    _is.DatabaseSession session,
    StockMovement row, {
    _is.ColumnSelections<StockMovementTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StockMovement>(
      row,
      columns: columns?.call(StockMovement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StockMovement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StockMovement?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StockMovementUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StockMovement>(
      id,
      columnValues: columnValues(StockMovement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StockMovement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockMovement>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StockMovementUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StockMovementTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StockMovement>(
      columnValues: columnValues(StockMovement.t.updateTable),
      where: where(StockMovement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StockMovement]s in the list and returns the deleted rows.
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
  Future<List<StockMovement>> delete(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StockMovement>(
      rows,
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StockMovement].
  Future<StockMovement> deleteRow(
    _is.DatabaseSession session,
    StockMovement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StockMovement>(
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
  Future<List<StockMovement>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockMovementTable> where,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StockMovement>(
      where: where(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StockMovement>(
      where: where?.call(StockMovement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockMovement] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockMovementTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockMovement>(
      where: where(StockMovement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
