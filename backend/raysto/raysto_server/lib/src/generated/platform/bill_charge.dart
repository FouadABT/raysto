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

abstract class BillCharge
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  BillCharge._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    this.visitId,
    required this.lineKey,
    required this.kind,
    required this.amountMinor,
    required this.creditedMinor,
    required this.settledMinor,
    required this.reservedMinor,
    required this.foodNetMinor,
    required this.version,
  });

  factory BillCharge({
    int? id,
    required int restaurantId,
    required int orderId,
    int? visitId,
    required String lineKey,
    required String kind,
    required int amountMinor,
    required int creditedMinor,
    required int settledMinor,
    required int reservedMinor,
    required int foodNetMinor,
    required int version,
  }) = _BillChargeImpl;

  factory BillCharge.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillCharge(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      visitId: jsonSerialization['visitId'] as int?,
      lineKey: jsonSerialization['lineKey'] as String,
      kind: jsonSerialization['kind'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      creditedMinor: jsonSerialization['creditedMinor'] as int,
      settledMinor: jsonSerialization['settledMinor'] as int,
      reservedMinor: jsonSerialization['reservedMinor'] as int,
      foodNetMinor: jsonSerialization['foodNetMinor'] as int,
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = BillChargeTable();

  static const db = BillChargeRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  int? visitId;

  String lineKey;

  String kind;

  int amountMinor;

  int creditedMinor;

  int settledMinor;

  int reservedMinor;

  int foodNetMinor;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [BillCharge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BillCharge copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    int? visitId,
    String? lineKey,
    String? kind,
    int? amountMinor,
    int? creditedMinor,
    int? settledMinor,
    int? reservedMinor,
    int? foodNetMinor,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillCharge',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      if (visitId != null) 'visitId': visitId,
      'lineKey': lineKey,
      'kind': kind,
      'amountMinor': amountMinor,
      'creditedMinor': creditedMinor,
      'settledMinor': settledMinor,
      'reservedMinor': reservedMinor,
      'foodNetMinor': foodNetMinor,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static BillChargeInclude include() {
    return BillChargeInclude._();
  }

  static BillChargeIncludeList includeList({
    _is.WhereExpressionBuilder<BillChargeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillChargeTable>? orderBy,
    _is.OrderByListBuilder<BillChargeTable>? orderByList,
    BillChargeInclude? include,
  }) {
    return BillChargeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillCharge.t),
      orderByList: orderByList?.call(BillCharge.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillChargeImpl extends BillCharge {
  _BillChargeImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    int? visitId,
    required String lineKey,
    required String kind,
    required int amountMinor,
    required int creditedMinor,
    required int settledMinor,
    required int reservedMinor,
    required int foodNetMinor,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         visitId: visitId,
         lineKey: lineKey,
         kind: kind,
         amountMinor: amountMinor,
         creditedMinor: creditedMinor,
         settledMinor: settledMinor,
         reservedMinor: reservedMinor,
         foodNetMinor: foodNetMinor,
         version: version,
       );

  /// Returns a shallow copy of this [BillCharge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BillCharge copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    Object? visitId = _Undefined,
    String? lineKey,
    String? kind,
    int? amountMinor,
    int? creditedMinor,
    int? settledMinor,
    int? reservedMinor,
    int? foodNetMinor,
    int? version,
  }) {
    return BillCharge(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      visitId: visitId is int? ? visitId : this.visitId,
      lineKey: lineKey ?? this.lineKey,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      creditedMinor: creditedMinor ?? this.creditedMinor,
      settledMinor: settledMinor ?? this.settledMinor,
      reservedMinor: reservedMinor ?? this.reservedMinor,
      foodNetMinor: foodNetMinor ?? this.foodNetMinor,
      version: version ?? this.version,
    );
  }
}

class BillChargeUpdateTable extends _is.UpdateTable<BillChargeTable> {
  BillChargeUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<int, int> visitId(int? value) => _is.ColumnValue(
    table.visitId,
    value,
  );

  _is.ColumnValue<String, String> lineKey(String value) => _is.ColumnValue(
    table.lineKey,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> creditedMinor(int value) => _is.ColumnValue(
    table.creditedMinor,
    value,
  );

  _is.ColumnValue<int, int> settledMinor(int value) => _is.ColumnValue(
    table.settledMinor,
    value,
  );

  _is.ColumnValue<int, int> reservedMinor(int value) => _is.ColumnValue(
    table.reservedMinor,
    value,
  );

  _is.ColumnValue<int, int> foodNetMinor(int value) => _is.ColumnValue(
    table.foodNetMinor,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class BillChargeTable extends _is.Table<int?> {
  BillChargeTable({super.tableRelation})
    : super(tableName: 'raysto_bill_charge') {
    updateTable = BillChargeUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
      this,
    );
    lineKey = _is.ColumnString(
      'lineKey',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    creditedMinor = _is.ColumnInt(
      'creditedMinor',
      this,
    );
    settledMinor = _is.ColumnInt(
      'settledMinor',
      this,
    );
    reservedMinor = _is.ColumnInt(
      'reservedMinor',
      this,
    );
    foodNetMinor = _is.ColumnInt(
      'foodNetMinor',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final BillChargeUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnInt visitId;

  late final _is.ColumnString lineKey;

  late final _is.ColumnString kind;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnInt creditedMinor;

  late final _is.ColumnInt settledMinor;

  late final _is.ColumnInt reservedMinor;

  late final _is.ColumnInt foodNetMinor;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    visitId,
    lineKey,
    kind,
    amountMinor,
    creditedMinor,
    settledMinor,
    reservedMinor,
    foodNetMinor,
    version,
  ];
}

class BillChargeInclude extends _is.IncludeObject {
  BillChargeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => BillCharge.t;
}

class BillChargeIncludeList extends _is.IncludeList {
  BillChargeIncludeList._({
    _is.WhereExpressionBuilder<BillChargeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BillCharge.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => BillCharge.t;
}

class BillChargeRepository {
  const BillChargeRepository._();

  /// Returns a list of [BillCharge]s matching the given query parameters.
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
  Future<List<BillCharge>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillChargeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillChargeTable>? orderBy,
    _is.OrderByListBuilder<BillChargeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BillCharge>(
      where: where?.call(BillCharge.t),
      orderBy: orderBy?.call(BillCharge.t),
      orderByList: orderByList?.call(BillCharge.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BillCharge] matching the given query parameters.
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
  Future<BillCharge?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillChargeTable>? where,
    int? offset,
    _is.OrderByBuilder<BillChargeTable>? orderBy,
    _is.OrderByListBuilder<BillChargeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BillCharge>(
      where: where?.call(BillCharge.t),
      orderBy: orderBy?.call(BillCharge.t),
      orderByList: orderByList?.call(BillCharge.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BillCharge] by its [id] or null if no such row exists.
  Future<BillCharge?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BillCharge>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BillCharge]s in the list and returns the inserted rows.
  ///
  /// The returned [BillCharge]s will have their `id` fields set.
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
  Future<List<BillCharge>> insert(
    _is.DatabaseSession session,
    List<BillCharge> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BillCharge>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BillCharge] and returns the inserted row.
  ///
  /// The returned [BillCharge] will have its `id` field set.
  Future<BillCharge> insertRow(
    _is.DatabaseSession session,
    BillCharge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BillCharge>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BillCharge]s in the list and returns the resulting rows.
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
  /// The returned [BillCharge]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillCharge>> upsert(
    _is.DatabaseSession session,
    List<BillCharge> rows, {
    required _is.ColumnSelections<BillChargeTable> conflictColumns,
    _is.ColumnSelections<BillChargeTable>? updateColumns,
    _is.WhereExpressionBuilder<BillChargeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BillCharge>(
      rows,
      conflictColumns: conflictColumns(BillCharge.t),
      updateColumns: updateColumns?.call(BillCharge.t),
      updateWhere: updateWhere?.call(BillCharge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BillCharge] and returns the resulting row.
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
  /// The returned [BillCharge] will have its `id` field set.
  Future<BillCharge?> upsertRow(
    _is.DatabaseSession session,
    BillCharge row, {
    required _is.ColumnSelections<BillChargeTable> conflictColumns,
    _is.ColumnSelections<BillChargeTable>? updateColumns,
    _is.WhereExpressionBuilder<BillChargeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BillCharge>(
      row,
      conflictColumns: conflictColumns(BillCharge.t),
      updateColumns: updateColumns?.call(BillCharge.t),
      updateWhere: updateWhere?.call(BillCharge.t),
      transaction: transaction,
    );
  }

  /// Updates all [BillCharge]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillCharge>> update(
    _is.DatabaseSession session,
    List<BillCharge> rows, {
    _is.ColumnSelections<BillChargeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BillCharge>(
      rows,
      columns: columns?.call(BillCharge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BillCharge]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BillCharge> updateRow(
    _is.DatabaseSession session,
    BillCharge row, {
    _is.ColumnSelections<BillChargeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BillCharge>(
      row,
      columns: columns?.call(BillCharge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BillCharge] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BillCharge?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BillChargeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BillCharge>(
      id,
      columnValues: columnValues(BillCharge.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BillCharge]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillCharge>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BillChargeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BillChargeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillChargeTable>? orderBy,
    _is.OrderByListBuilder<BillChargeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BillCharge>(
      columnValues: columnValues(BillCharge.t.updateTable),
      where: where(BillCharge.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillCharge.t),
      orderByList: orderByList?.call(BillCharge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BillCharge]s in the list and returns the deleted rows.
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
  Future<List<BillCharge>> delete(
    _is.DatabaseSession session,
    List<BillCharge> rows, {
    _is.OrderByBuilder<BillChargeTable>? orderBy,
    _is.OrderByListBuilder<BillChargeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BillCharge>(
      rows,
      orderBy: orderBy?.call(BillCharge.t),
      orderByList: orderByList?.call(BillCharge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BillCharge].
  Future<BillCharge> deleteRow(
    _is.DatabaseSession session,
    BillCharge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BillCharge>(
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
  Future<List<BillCharge>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillChargeTable> where,
    _is.OrderByBuilder<BillChargeTable>? orderBy,
    _is.OrderByListBuilder<BillChargeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BillCharge>(
      where: where(BillCharge.t),
      orderBy: orderBy?.call(BillCharge.t),
      orderByList: orderByList?.call(BillCharge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillChargeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BillCharge>(
      where: where?.call(BillCharge.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BillCharge] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillChargeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BillCharge>(
      where: where(BillCharge.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
