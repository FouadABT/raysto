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

abstract class CustomerFavorite
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CustomerFavorite._({
    this.id,
    required this.userId,
    required this.restaurantId,
    this.productId,
    required this.targetKey,
    required this.createdAt,
  });

  factory CustomerFavorite({
    int? id,
    required String userId,
    required int restaurantId,
    int? productId,
    required String targetKey,
    required DateTime createdAt,
  }) = _CustomerFavoriteImpl;

  factory CustomerFavorite.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomerFavorite(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int,
      productId: jsonSerialization['productId'] as int?,
      targetKey: jsonSerialization['targetKey'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = CustomerFavoriteTable();

  static const db = CustomerFavoriteRepository._();

  @override
  int? id;

  String userId;

  int restaurantId;

  int? productId;

  String targetKey;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CustomerFavorite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustomerFavorite copyWith({
    int? id,
    String? userId,
    int? restaurantId,
    int? productId,
    String? targetKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomerFavorite',
      if (id != null) 'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      if (productId != null) 'productId': productId,
      'targetKey': targetKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CustomerFavoriteInclude include() {
    return CustomerFavoriteInclude._();
  }

  static CustomerFavoriteIncludeList includeList({
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerFavoriteTable>? orderBy,
    _is.OrderByListBuilder<CustomerFavoriteTable>? orderByList,
    CustomerFavoriteInclude? include,
  }) {
    return CustomerFavoriteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerFavorite.t),
      orderByList: orderByList?.call(CustomerFavorite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomerFavoriteImpl extends CustomerFavorite {
  _CustomerFavoriteImpl({
    int? id,
    required String userId,
    required int restaurantId,
    int? productId,
    required String targetKey,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         restaurantId: restaurantId,
         productId: productId,
         targetKey: targetKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CustomerFavorite]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustomerFavorite copyWith({
    Object? id = _Undefined,
    String? userId,
    int? restaurantId,
    Object? productId = _Undefined,
    String? targetKey,
    DateTime? createdAt,
  }) {
    return CustomerFavorite(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      productId: productId is int? ? productId : this.productId,
      targetKey: targetKey ?? this.targetKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CustomerFavoriteUpdateTable
    extends _is.UpdateTable<CustomerFavoriteTable> {
  CustomerFavoriteUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> productId(int? value) => _is.ColumnValue(
    table.productId,
    value,
  );

  _is.ColumnValue<String, String> targetKey(String value) => _is.ColumnValue(
    table.targetKey,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CustomerFavoriteTable extends _is.Table<int?> {
  CustomerFavoriteTable({super.tableRelation})
    : super(tableName: 'raysto_customer_favorite') {
    updateTable = CustomerFavoriteUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    productId = _is.ColumnInt(
      'productId',
      this,
    );
    targetKey = _is.ColumnString(
      'targetKey',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final CustomerFavoriteUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt productId;

  late final _is.ColumnString targetKey;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    restaurantId,
    productId,
    targetKey,
    createdAt,
  ];
}

class CustomerFavoriteInclude extends _is.IncludeObject {
  CustomerFavoriteInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CustomerFavorite.t;
}

class CustomerFavoriteIncludeList extends _is.IncludeList {
  CustomerFavoriteIncludeList._({
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomerFavorite.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CustomerFavorite.t;
}

class CustomerFavoriteRepository {
  const CustomerFavoriteRepository._();

  /// Returns a list of [CustomerFavorite]s matching the given query parameters.
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
  Future<List<CustomerFavorite>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerFavoriteTable>? orderBy,
    _is.OrderByListBuilder<CustomerFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomerFavorite>(
      where: where?.call(CustomerFavorite.t),
      orderBy: orderBy?.call(CustomerFavorite.t),
      orderByList: orderByList?.call(CustomerFavorite.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustomerFavorite] matching the given query parameters.
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
  Future<CustomerFavorite?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? where,
    int? offset,
    _is.OrderByBuilder<CustomerFavoriteTable>? orderBy,
    _is.OrderByListBuilder<CustomerFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomerFavorite>(
      where: where?.call(CustomerFavorite.t),
      orderBy: orderBy?.call(CustomerFavorite.t),
      orderByList: orderByList?.call(CustomerFavorite.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomerFavorite] by its [id] or null if no such row exists.
  Future<CustomerFavorite?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomerFavorite>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomerFavorite]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomerFavorite]s will have their `id` fields set.
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
  Future<List<CustomerFavorite>> insert(
    _is.DatabaseSession session,
    List<CustomerFavorite> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomerFavorite>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomerFavorite] and returns the inserted row.
  ///
  /// The returned [CustomerFavorite] will have its `id` field set.
  Future<CustomerFavorite> insertRow(
    _is.DatabaseSession session,
    CustomerFavorite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomerFavorite>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomerFavorite]s in the list and returns the resulting rows.
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
  /// The returned [CustomerFavorite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerFavorite>> upsert(
    _is.DatabaseSession session,
    List<CustomerFavorite> rows, {
    required _is.ColumnSelections<CustomerFavoriteTable> conflictColumns,
    _is.ColumnSelections<CustomerFavoriteTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomerFavorite>(
      rows,
      conflictColumns: conflictColumns(CustomerFavorite.t),
      updateColumns: updateColumns?.call(CustomerFavorite.t),
      updateWhere: updateWhere?.call(CustomerFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomerFavorite] and returns the resulting row.
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
  /// The returned [CustomerFavorite] will have its `id` field set.
  Future<CustomerFavorite?> upsertRow(
    _is.DatabaseSession session,
    CustomerFavorite row, {
    required _is.ColumnSelections<CustomerFavoriteTable> conflictColumns,
    _is.ColumnSelections<CustomerFavoriteTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomerFavorite>(
      row,
      conflictColumns: conflictColumns(CustomerFavorite.t),
      updateColumns: updateColumns?.call(CustomerFavorite.t),
      updateWhere: updateWhere?.call(CustomerFavorite.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerFavorite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerFavorite>> update(
    _is.DatabaseSession session,
    List<CustomerFavorite> rows, {
    _is.ColumnSelections<CustomerFavoriteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomerFavorite>(
      rows,
      columns: columns?.call(CustomerFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomerFavorite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomerFavorite> updateRow(
    _is.DatabaseSession session,
    CustomerFavorite row, {
    _is.ColumnSelections<CustomerFavoriteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomerFavorite>(
      row,
      columns: columns?.call(CustomerFavorite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomerFavorite] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomerFavorite?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CustomerFavoriteUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomerFavorite>(
      id,
      columnValues: columnValues(CustomerFavorite.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerFavorite]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerFavorite>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustomerFavoriteUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CustomerFavoriteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerFavoriteTable>? orderBy,
    _is.OrderByListBuilder<CustomerFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomerFavorite>(
      columnValues: columnValues(CustomerFavorite.t.updateTable),
      where: where(CustomerFavorite.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerFavorite.t),
      orderByList: orderByList?.call(CustomerFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomerFavorite]s in the list and returns the deleted rows.
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
  Future<List<CustomerFavorite>> delete(
    _is.DatabaseSession session,
    List<CustomerFavorite> rows, {
    _is.OrderByBuilder<CustomerFavoriteTable>? orderBy,
    _is.OrderByListBuilder<CustomerFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomerFavorite>(
      rows,
      orderBy: orderBy?.call(CustomerFavorite.t),
      orderByList: orderByList?.call(CustomerFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomerFavorite].
  Future<CustomerFavorite> deleteRow(
    _is.DatabaseSession session,
    CustomerFavorite row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomerFavorite>(
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
  Future<List<CustomerFavorite>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerFavoriteTable> where,
    _is.OrderByBuilder<CustomerFavoriteTable>? orderBy,
    _is.OrderByListBuilder<CustomerFavoriteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomerFavorite>(
      where: where(CustomerFavorite.t),
      orderBy: orderBy?.call(CustomerFavorite.t),
      orderByList: orderByList?.call(CustomerFavorite.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerFavoriteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustomerFavorite>(
      where: where?.call(CustomerFavorite.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomerFavorite] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerFavoriteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomerFavorite>(
      where: where(CustomerFavorite.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
