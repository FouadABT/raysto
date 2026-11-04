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

abstract class StockItem
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StockItem._({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.costMinor,
    this.supplierId,
    required this.lowAt,
    required this.version,
    required this.updatedAt,
    this.parLevel,
    this.leadDays,
  });

  factory StockItem({
    int? id,
    required int restaurantId,
    required String name,
    required String unit,
    required double quantity,
    required int costMinor,
    int? supplierId,
    required double lowAt,
    required int version,
    required DateTime updatedAt,
    double? parLevel,
    int? leadDays,
  }) = _StockItemImpl;

  factory StockItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockItem(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      name: jsonSerialization['name'] as String,
      unit: jsonSerialization['unit'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      costMinor: jsonSerialization['costMinor'] as int,
      supplierId: jsonSerialization['supplierId'] as int?,
      lowAt: (jsonSerialization['lowAt'] as num).toDouble(),
      version: jsonSerialization['version'] as int,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      parLevel: (jsonSerialization['parLevel'] as num?)?.toDouble(),
      leadDays: jsonSerialization['leadDays'] as int?,
    );
  }

  static final t = StockItemTable();

  static const db = StockItemRepository._();

  @override
  int? id;

  int restaurantId;

  String name;

  String unit;

  double quantity;

  int costMinor;

  int? supplierId;

  double lowAt;

  int version;

  DateTime updatedAt;

  double? parLevel;

  int? leadDays;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StockItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StockItem copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? unit,
    double? quantity,
    int? costMinor,
    int? supplierId,
    double? lowAt,
    int? version,
    DateTime? updatedAt,
    double? parLevel,
    int? leadDays,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StockItem',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'costMinor': costMinor,
      if (supplierId != null) 'supplierId': supplierId,
      'lowAt': lowAt,
      'version': version,
      'updatedAt': updatedAt.toJson(),
      if (parLevel != null) 'parLevel': parLevel,
      if (leadDays != null) 'leadDays': leadDays,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StockItemInclude include() {
    return StockItemInclude._();
  }

  static StockItemIncludeList includeList({
    _is.WhereExpressionBuilder<StockItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockItemTable>? orderBy,
    _is.OrderByListBuilder<StockItemTable>? orderByList,
    StockItemInclude? include,
  }) {
    return StockItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockItem.t),
      orderByList: orderByList?.call(StockItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockItemImpl extends StockItem {
  _StockItemImpl({
    int? id,
    required int restaurantId,
    required String name,
    required String unit,
    required double quantity,
    required int costMinor,
    int? supplierId,
    required double lowAt,
    required int version,
    required DateTime updatedAt,
    double? parLevel,
    int? leadDays,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         name: name,
         unit: unit,
         quantity: quantity,
         costMinor: costMinor,
         supplierId: supplierId,
         lowAt: lowAt,
         version: version,
         updatedAt: updatedAt,
         parLevel: parLevel,
         leadDays: leadDays,
       );

  /// Returns a shallow copy of this [StockItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StockItem copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? name,
    String? unit,
    double? quantity,
    int? costMinor,
    Object? supplierId = _Undefined,
    double? lowAt,
    int? version,
    DateTime? updatedAt,
    Object? parLevel = _Undefined,
    Object? leadDays = _Undefined,
  }) {
    return StockItem(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      costMinor: costMinor ?? this.costMinor,
      supplierId: supplierId is int? ? supplierId : this.supplierId,
      lowAt: lowAt ?? this.lowAt,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      parLevel: parLevel is double? ? parLevel : this.parLevel,
      leadDays: leadDays is int? ? leadDays : this.leadDays,
    );
  }
}

class StockItemUpdateTable extends _is.UpdateTable<StockItemTable> {
  StockItemUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> unit(String value) => _is.ColumnValue(
    table.unit,
    value,
  );

  _is.ColumnValue<double, double> quantity(double value) => _is.ColumnValue(
    table.quantity,
    value,
  );

  _is.ColumnValue<int, int> costMinor(int value) => _is.ColumnValue(
    table.costMinor,
    value,
  );

  _is.ColumnValue<int, int> supplierId(int? value) => _is.ColumnValue(
    table.supplierId,
    value,
  );

  _is.ColumnValue<double, double> lowAt(double value) => _is.ColumnValue(
    table.lowAt,
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

  _is.ColumnValue<double, double> parLevel(double? value) => _is.ColumnValue(
    table.parLevel,
    value,
  );

  _is.ColumnValue<int, int> leadDays(int? value) => _is.ColumnValue(
    table.leadDays,
    value,
  );
}

class StockItemTable extends _is.Table<int?> {
  StockItemTable({super.tableRelation})
    : super(tableName: 'raysto_stock_item') {
    updateTable = StockItemUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    unit = _is.ColumnString(
      'unit',
      this,
    );
    quantity = _is.ColumnDouble(
      'quantity',
      this,
    );
    costMinor = _is.ColumnInt(
      'costMinor',
      this,
    );
    supplierId = _is.ColumnInt(
      'supplierId',
      this,
    );
    lowAt = _is.ColumnDouble(
      'lowAt',
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
    parLevel = _is.ColumnDouble(
      'parLevel',
      this,
    );
    leadDays = _is.ColumnInt(
      'leadDays',
      this,
    );
  }

  late final StockItemUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString name;

  late final _is.ColumnString unit;

  late final _is.ColumnDouble quantity;

  late final _is.ColumnInt costMinor;

  late final _is.ColumnInt supplierId;

  late final _is.ColumnDouble lowAt;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDouble parLevel;

  late final _is.ColumnInt leadDays;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    name,
    unit,
    quantity,
    costMinor,
    supplierId,
    lowAt,
    version,
    updatedAt,
    parLevel,
    leadDays,
  ];
}

class StockItemInclude extends _is.IncludeObject {
  StockItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StockItem.t;
}

class StockItemIncludeList extends _is.IncludeList {
  StockItemIncludeList._({
    _is.WhereExpressionBuilder<StockItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StockItem.t;
}

class StockItemRepository {
  const StockItemRepository._();

  /// Returns a list of [StockItem]s matching the given query parameters.
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
  Future<List<StockItem>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockItemTable>? orderBy,
    _is.OrderByListBuilder<StockItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StockItem>(
      where: where?.call(StockItem.t),
      orderBy: orderBy?.call(StockItem.t),
      orderByList: orderByList?.call(StockItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StockItem] matching the given query parameters.
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
  Future<StockItem?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockItemTable>? where,
    int? offset,
    _is.OrderByBuilder<StockItemTable>? orderBy,
    _is.OrderByListBuilder<StockItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StockItem>(
      where: where?.call(StockItem.t),
      orderBy: orderBy?.call(StockItem.t),
      orderByList: orderByList?.call(StockItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StockItem] by its [id] or null if no such row exists.
  Future<StockItem?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StockItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StockItem]s in the list and returns the inserted rows.
  ///
  /// The returned [StockItem]s will have their `id` fields set.
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
  Future<List<StockItem>> insert(
    _is.DatabaseSession session,
    List<StockItem> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StockItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StockItem] and returns the inserted row.
  ///
  /// The returned [StockItem] will have its `id` field set.
  Future<StockItem> insertRow(
    _is.DatabaseSession session,
    StockItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StockItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StockItem]s in the list and returns the resulting rows.
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
  /// The returned [StockItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockItem>> upsert(
    _is.DatabaseSession session,
    List<StockItem> rows, {
    required _is.ColumnSelections<StockItemTable> conflictColumns,
    _is.ColumnSelections<StockItemTable>? updateColumns,
    _is.WhereExpressionBuilder<StockItemTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StockItem>(
      rows,
      conflictColumns: conflictColumns(StockItem.t),
      updateColumns: updateColumns?.call(StockItem.t),
      updateWhere: updateWhere?.call(StockItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StockItem] and returns the resulting row.
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
  /// The returned [StockItem] will have its `id` field set.
  Future<StockItem?> upsertRow(
    _is.DatabaseSession session,
    StockItem row, {
    required _is.ColumnSelections<StockItemTable> conflictColumns,
    _is.ColumnSelections<StockItemTable>? updateColumns,
    _is.WhereExpressionBuilder<StockItemTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StockItem>(
      row,
      conflictColumns: conflictColumns(StockItem.t),
      updateColumns: updateColumns?.call(StockItem.t),
      updateWhere: updateWhere?.call(StockItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [StockItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockItem>> update(
    _is.DatabaseSession session,
    List<StockItem> rows, {
    _is.ColumnSelections<StockItemTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StockItem>(
      rows,
      columns: columns?.call(StockItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StockItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StockItem> updateRow(
    _is.DatabaseSession session,
    StockItem row, {
    _is.ColumnSelections<StockItemTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StockItem>(
      row,
      columns: columns?.call(StockItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StockItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StockItem?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StockItemUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StockItem>(
      id,
      columnValues: columnValues(StockItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StockItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockItem>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StockItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StockItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockItemTable>? orderBy,
    _is.OrderByListBuilder<StockItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StockItem>(
      columnValues: columnValues(StockItem.t.updateTable),
      where: where(StockItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockItem.t),
      orderByList: orderByList?.call(StockItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StockItem]s in the list and returns the deleted rows.
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
  Future<List<StockItem>> delete(
    _is.DatabaseSession session,
    List<StockItem> rows, {
    _is.OrderByBuilder<StockItemTable>? orderBy,
    _is.OrderByListBuilder<StockItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StockItem>(
      rows,
      orderBy: orderBy?.call(StockItem.t),
      orderByList: orderByList?.call(StockItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StockItem].
  Future<StockItem> deleteRow(
    _is.DatabaseSession session,
    StockItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StockItem>(
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
  Future<List<StockItem>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockItemTable> where,
    _is.OrderByBuilder<StockItemTable>? orderBy,
    _is.OrderByListBuilder<StockItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StockItem>(
      where: where(StockItem.t),
      orderBy: orderBy?.call(StockItem.t),
      orderByList: orderByList?.call(StockItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StockItem>(
      where: where?.call(StockItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockItem>(
      where: where(StockItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
