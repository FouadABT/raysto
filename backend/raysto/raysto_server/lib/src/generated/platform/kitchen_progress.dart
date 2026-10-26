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

abstract class KitchenProgress
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  KitchenProgress._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    required this.lineKey,
    required this.quantity,
    required this.completedQuantity,
    required this.version,
  });

  factory KitchenProgress({
    int? id,
    required int restaurantId,
    required int orderId,
    required String lineKey,
    required int quantity,
    required int completedQuantity,
    required int version,
  }) = _KitchenProgressImpl;

  factory KitchenProgress.fromJson(Map<String, dynamic> jsonSerialization) {
    return KitchenProgress(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      lineKey: jsonSerialization['lineKey'] as String,
      quantity: jsonSerialization['quantity'] as int,
      completedQuantity: jsonSerialization['completedQuantity'] as int,
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = KitchenProgressTable();

  static const db = KitchenProgressRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  String lineKey;

  int quantity;

  int completedQuantity;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [KitchenProgress]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  KitchenProgress copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    String? lineKey,
    int? quantity,
    int? completedQuantity,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'KitchenProgress',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      'lineKey': lineKey,
      'quantity': quantity,
      'completedQuantity': completedQuantity,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static KitchenProgressInclude include() {
    return KitchenProgressInclude._();
  }

  static KitchenProgressIncludeList includeList({
    _is.WhereExpressionBuilder<KitchenProgressTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenProgressTable>? orderBy,
    _is.OrderByListBuilder<KitchenProgressTable>? orderByList,
    KitchenProgressInclude? include,
  }) {
    return KitchenProgressIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(KitchenProgress.t),
      orderByList: orderByList?.call(KitchenProgress.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _KitchenProgressImpl extends KitchenProgress {
  _KitchenProgressImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    required String lineKey,
    required int quantity,
    required int completedQuantity,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         lineKey: lineKey,
         quantity: quantity,
         completedQuantity: completedQuantity,
         version: version,
       );

  /// Returns a shallow copy of this [KitchenProgress]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  KitchenProgress copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    String? lineKey,
    int? quantity,
    int? completedQuantity,
    int? version,
  }) {
    return KitchenProgress(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      lineKey: lineKey ?? this.lineKey,
      quantity: quantity ?? this.quantity,
      completedQuantity: completedQuantity ?? this.completedQuantity,
      version: version ?? this.version,
    );
  }
}

class KitchenProgressUpdateTable extends _is.UpdateTable<KitchenProgressTable> {
  KitchenProgressUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> lineKey(String value) => _is.ColumnValue(
    table.lineKey,
    value,
  );

  _is.ColumnValue<int, int> quantity(int value) => _is.ColumnValue(
    table.quantity,
    value,
  );

  _is.ColumnValue<int, int> completedQuantity(int value) => _is.ColumnValue(
    table.completedQuantity,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class KitchenProgressTable extends _is.Table<int?> {
  KitchenProgressTable({super.tableRelation})
    : super(tableName: 'raysto_kitchen_progress') {
    updateTable = KitchenProgressUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    lineKey = _is.ColumnString(
      'lineKey',
      this,
    );
    quantity = _is.ColumnInt(
      'quantity',
      this,
    );
    completedQuantity = _is.ColumnInt(
      'completedQuantity',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final KitchenProgressUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString lineKey;

  late final _is.ColumnInt quantity;

  late final _is.ColumnInt completedQuantity;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    lineKey,
    quantity,
    completedQuantity,
    version,
  ];
}

class KitchenProgressInclude extends _is.IncludeObject {
  KitchenProgressInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => KitchenProgress.t;
}

class KitchenProgressIncludeList extends _is.IncludeList {
  KitchenProgressIncludeList._({
    _is.WhereExpressionBuilder<KitchenProgressTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(KitchenProgress.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => KitchenProgress.t;
}

class KitchenProgressRepository {
  const KitchenProgressRepository._();

  /// Returns a list of [KitchenProgress]s matching the given query parameters.
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
  Future<List<KitchenProgress>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenProgressTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenProgressTable>? orderBy,
    _is.OrderByListBuilder<KitchenProgressTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<KitchenProgress>(
      where: where?.call(KitchenProgress.t),
      orderBy: orderBy?.call(KitchenProgress.t),
      orderByList: orderByList?.call(KitchenProgress.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [KitchenProgress] matching the given query parameters.
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
  Future<KitchenProgress?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenProgressTable>? where,
    int? offset,
    _is.OrderByBuilder<KitchenProgressTable>? orderBy,
    _is.OrderByListBuilder<KitchenProgressTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<KitchenProgress>(
      where: where?.call(KitchenProgress.t),
      orderBy: orderBy?.call(KitchenProgress.t),
      orderByList: orderByList?.call(KitchenProgress.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [KitchenProgress] by its [id] or null if no such row exists.
  Future<KitchenProgress?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<KitchenProgress>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [KitchenProgress]s in the list and returns the inserted rows.
  ///
  /// The returned [KitchenProgress]s will have their `id` fields set.
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
  Future<List<KitchenProgress>> insert(
    _is.DatabaseSession session,
    List<KitchenProgress> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<KitchenProgress>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [KitchenProgress] and returns the inserted row.
  ///
  /// The returned [KitchenProgress] will have its `id` field set.
  Future<KitchenProgress> insertRow(
    _is.DatabaseSession session,
    KitchenProgress row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<KitchenProgress>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [KitchenProgress]s in the list and returns the resulting rows.
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
  /// The returned [KitchenProgress]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<KitchenProgress>> upsert(
    _is.DatabaseSession session,
    List<KitchenProgress> rows, {
    required _is.ColumnSelections<KitchenProgressTable> conflictColumns,
    _is.ColumnSelections<KitchenProgressTable>? updateColumns,
    _is.WhereExpressionBuilder<KitchenProgressTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<KitchenProgress>(
      rows,
      conflictColumns: conflictColumns(KitchenProgress.t),
      updateColumns: updateColumns?.call(KitchenProgress.t),
      updateWhere: updateWhere?.call(KitchenProgress.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [KitchenProgress] and returns the resulting row.
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
  /// The returned [KitchenProgress] will have its `id` field set.
  Future<KitchenProgress?> upsertRow(
    _is.DatabaseSession session,
    KitchenProgress row, {
    required _is.ColumnSelections<KitchenProgressTable> conflictColumns,
    _is.ColumnSelections<KitchenProgressTable>? updateColumns,
    _is.WhereExpressionBuilder<KitchenProgressTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<KitchenProgress>(
      row,
      conflictColumns: conflictColumns(KitchenProgress.t),
      updateColumns: updateColumns?.call(KitchenProgress.t),
      updateWhere: updateWhere?.call(KitchenProgress.t),
      transaction: transaction,
    );
  }

  /// Updates all [KitchenProgress]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<KitchenProgress>> update(
    _is.DatabaseSession session,
    List<KitchenProgress> rows, {
    _is.ColumnSelections<KitchenProgressTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<KitchenProgress>(
      rows,
      columns: columns?.call(KitchenProgress.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [KitchenProgress]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<KitchenProgress> updateRow(
    _is.DatabaseSession session,
    KitchenProgress row, {
    _is.ColumnSelections<KitchenProgressTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<KitchenProgress>(
      row,
      columns: columns?.call(KitchenProgress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [KitchenProgress] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<KitchenProgress?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<KitchenProgressUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<KitchenProgress>(
      id,
      columnValues: columnValues(KitchenProgress.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [KitchenProgress]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<KitchenProgress>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<KitchenProgressUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<KitchenProgressTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenProgressTable>? orderBy,
    _is.OrderByListBuilder<KitchenProgressTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<KitchenProgress>(
      columnValues: columnValues(KitchenProgress.t.updateTable),
      where: where(KitchenProgress.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(KitchenProgress.t),
      orderByList: orderByList?.call(KitchenProgress.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [KitchenProgress]s in the list and returns the deleted rows.
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
  Future<List<KitchenProgress>> delete(
    _is.DatabaseSession session,
    List<KitchenProgress> rows, {
    _is.OrderByBuilder<KitchenProgressTable>? orderBy,
    _is.OrderByListBuilder<KitchenProgressTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<KitchenProgress>(
      rows,
      orderBy: orderBy?.call(KitchenProgress.t),
      orderByList: orderByList?.call(KitchenProgress.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [KitchenProgress].
  Future<KitchenProgress> deleteRow(
    _is.DatabaseSession session,
    KitchenProgress row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<KitchenProgress>(
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
  Future<List<KitchenProgress>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<KitchenProgressTable> where,
    _is.OrderByBuilder<KitchenProgressTable>? orderBy,
    _is.OrderByListBuilder<KitchenProgressTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<KitchenProgress>(
      where: where(KitchenProgress.t),
      orderBy: orderBy?.call(KitchenProgress.t),
      orderByList: orderByList?.call(KitchenProgress.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenProgressTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<KitchenProgress>(
      where: where?.call(KitchenProgress.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [KitchenProgress] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<KitchenProgressTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<KitchenProgress>(
      where: where(KitchenProgress.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
