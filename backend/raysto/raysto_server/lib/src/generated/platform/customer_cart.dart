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

abstract class CustomerCart
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CustomerCart._({
    this.id,
    required this.restaurantId,
    required this.userId,
    required this.linesJson,
    required this.version,
    required this.updatedAt,
  });

  factory CustomerCart({
    int? id,
    required int restaurantId,
    required String userId,
    required String linesJson,
    required int version,
    required DateTime updatedAt,
  }) = _CustomerCartImpl;

  factory CustomerCart.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomerCart(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      linesJson: jsonSerialization['linesJson'] as String,
      version: jsonSerialization['version'] as int,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CustomerCartTable();

  static const db = CustomerCartRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  String linesJson;

  int version;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CustomerCart]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustomerCart copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? linesJson,
    int? version,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomerCart',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'linesJson': linesJson,
      'version': version,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CustomerCartInclude include() {
    return CustomerCartInclude._();
  }

  static CustomerCartIncludeList includeList({
    _is.WhereExpressionBuilder<CustomerCartTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerCartTable>? orderBy,
    _is.OrderByListBuilder<CustomerCartTable>? orderByList,
    CustomerCartInclude? include,
  }) {
    return CustomerCartIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerCart.t),
      orderByList: orderByList?.call(CustomerCart.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomerCartImpl extends CustomerCart {
  _CustomerCartImpl({
    int? id,
    required int restaurantId,
    required String userId,
    required String linesJson,
    required int version,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         linesJson: linesJson,
         version: version,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CustomerCart]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustomerCart copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    String? linesJson,
    int? version,
    DateTime? updatedAt,
  }) {
    return CustomerCart(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      linesJson: linesJson ?? this.linesJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CustomerCartUpdateTable extends _is.UpdateTable<CustomerCartTable> {
  CustomerCartUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> linesJson(String value) => _is.ColumnValue(
    table.linesJson,
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
}

class CustomerCartTable extends _is.Table<int?> {
  CustomerCartTable({super.tableRelation})
    : super(tableName: 'raysto_customer_cart') {
    updateTable = CustomerCartUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    linesJson = _is.ColumnString(
      'linesJson',
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
  }

  late final CustomerCartUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString linesJson;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    linesJson,
    version,
    updatedAt,
  ];
}

class CustomerCartInclude extends _is.IncludeObject {
  CustomerCartInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CustomerCart.t;
}

class CustomerCartIncludeList extends _is.IncludeList {
  CustomerCartIncludeList._({
    _is.WhereExpressionBuilder<CustomerCartTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomerCart.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CustomerCart.t;
}

class CustomerCartRepository {
  const CustomerCartRepository._();

  /// Returns a list of [CustomerCart]s matching the given query parameters.
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
  Future<List<CustomerCart>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerCartTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerCartTable>? orderBy,
    _is.OrderByListBuilder<CustomerCartTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomerCart>(
      where: where?.call(CustomerCart.t),
      orderBy: orderBy?.call(CustomerCart.t),
      orderByList: orderByList?.call(CustomerCart.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustomerCart] matching the given query parameters.
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
  Future<CustomerCart?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerCartTable>? where,
    int? offset,
    _is.OrderByBuilder<CustomerCartTable>? orderBy,
    _is.OrderByListBuilder<CustomerCartTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomerCart>(
      where: where?.call(CustomerCart.t),
      orderBy: orderBy?.call(CustomerCart.t),
      orderByList: orderByList?.call(CustomerCart.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomerCart] by its [id] or null if no such row exists.
  Future<CustomerCart?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomerCart>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomerCart]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomerCart]s will have their `id` fields set.
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
  Future<List<CustomerCart>> insert(
    _is.DatabaseSession session,
    List<CustomerCart> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomerCart>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomerCart] and returns the inserted row.
  ///
  /// The returned [CustomerCart] will have its `id` field set.
  Future<CustomerCart> insertRow(
    _is.DatabaseSession session,
    CustomerCart row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomerCart>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomerCart]s in the list and returns the resulting rows.
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
  /// The returned [CustomerCart]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerCart>> upsert(
    _is.DatabaseSession session,
    List<CustomerCart> rows, {
    required _is.ColumnSelections<CustomerCartTable> conflictColumns,
    _is.ColumnSelections<CustomerCartTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerCartTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomerCart>(
      rows,
      conflictColumns: conflictColumns(CustomerCart.t),
      updateColumns: updateColumns?.call(CustomerCart.t),
      updateWhere: updateWhere?.call(CustomerCart.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomerCart] and returns the resulting row.
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
  /// The returned [CustomerCart] will have its `id` field set.
  Future<CustomerCart?> upsertRow(
    _is.DatabaseSession session,
    CustomerCart row, {
    required _is.ColumnSelections<CustomerCartTable> conflictColumns,
    _is.ColumnSelections<CustomerCartTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerCartTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomerCart>(
      row,
      conflictColumns: conflictColumns(CustomerCart.t),
      updateColumns: updateColumns?.call(CustomerCart.t),
      updateWhere: updateWhere?.call(CustomerCart.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerCart]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerCart>> update(
    _is.DatabaseSession session,
    List<CustomerCart> rows, {
    _is.ColumnSelections<CustomerCartTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomerCart>(
      rows,
      columns: columns?.call(CustomerCart.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomerCart]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomerCart> updateRow(
    _is.DatabaseSession session,
    CustomerCart row, {
    _is.ColumnSelections<CustomerCartTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomerCart>(
      row,
      columns: columns?.call(CustomerCart.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomerCart] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomerCart?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CustomerCartUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomerCart>(
      id,
      columnValues: columnValues(CustomerCart.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerCart]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerCart>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustomerCartUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CustomerCartTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerCartTable>? orderBy,
    _is.OrderByListBuilder<CustomerCartTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomerCart>(
      columnValues: columnValues(CustomerCart.t.updateTable),
      where: where(CustomerCart.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerCart.t),
      orderByList: orderByList?.call(CustomerCart.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomerCart]s in the list and returns the deleted rows.
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
  Future<List<CustomerCart>> delete(
    _is.DatabaseSession session,
    List<CustomerCart> rows, {
    _is.OrderByBuilder<CustomerCartTable>? orderBy,
    _is.OrderByListBuilder<CustomerCartTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomerCart>(
      rows,
      orderBy: orderBy?.call(CustomerCart.t),
      orderByList: orderByList?.call(CustomerCart.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomerCart].
  Future<CustomerCart> deleteRow(
    _is.DatabaseSession session,
    CustomerCart row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomerCart>(
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
  Future<List<CustomerCart>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerCartTable> where,
    _is.OrderByBuilder<CustomerCartTable>? orderBy,
    _is.OrderByListBuilder<CustomerCartTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomerCart>(
      where: where(CustomerCart.t),
      orderBy: orderBy?.call(CustomerCart.t),
      orderByList: orderByList?.call(CustomerCart.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerCartTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustomerCart>(
      where: where?.call(CustomerCart.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomerCart] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerCartTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomerCart>(
      where: where(CustomerCart.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
