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

abstract class CustomerReview
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CustomerReview._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    required this.userId,
    required this.rating,
    required this.text,
    this.response,
    required this.status,
    required this.version,
    required this.createdAt,
  });

  factory CustomerReview({
    int? id,
    required int restaurantId,
    required int orderId,
    required String userId,
    required int rating,
    required String text,
    String? response,
    required String status,
    required int version,
    required DateTime createdAt,
  }) = _CustomerReviewImpl;

  factory CustomerReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomerReview(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      userId: jsonSerialization['userId'] as String,
      rating: jsonSerialization['rating'] as int,
      text: jsonSerialization['text'] as String,
      response: jsonSerialization['response'] as String?,
      status: jsonSerialization['status'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = CustomerReviewTable();

  static const db = CustomerReviewRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  String userId;

  int rating;

  String text;

  String? response;

  String status;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CustomerReview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustomerReview copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    String? userId,
    int? rating,
    String? text,
    String? response,
    String? status,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomerReview',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      'userId': userId,
      'rating': rating,
      'text': text,
      if (response != null) 'response': response,
      'status': status,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CustomerReviewInclude include() {
    return CustomerReviewInclude._();
  }

  static CustomerReviewIncludeList includeList({
    _is.WhereExpressionBuilder<CustomerReviewTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerReviewTable>? orderBy,
    _is.OrderByListBuilder<CustomerReviewTable>? orderByList,
    CustomerReviewInclude? include,
  }) {
    return CustomerReviewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerReview.t),
      orderByList: orderByList?.call(CustomerReview.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomerReviewImpl extends CustomerReview {
  _CustomerReviewImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    required String userId,
    required int rating,
    required String text,
    String? response,
    required String status,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         userId: userId,
         rating: rating,
         text: text,
         response: response,
         status: status,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CustomerReview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustomerReview copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    String? userId,
    int? rating,
    String? text,
    Object? response = _Undefined,
    String? status,
    int? version,
    DateTime? createdAt,
  }) {
    return CustomerReview(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      response: response is String? ? response : this.response,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CustomerReviewUpdateTable extends _is.UpdateTable<CustomerReviewTable> {
  CustomerReviewUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> rating(int value) => _is.ColumnValue(
    table.rating,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<String, String> response(String? value) => _is.ColumnValue(
    table.response,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CustomerReviewTable extends _is.Table<int?> {
  CustomerReviewTable({super.tableRelation})
    : super(tableName: 'raysto_customer_review') {
    updateTable = CustomerReviewUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    rating = _is.ColumnInt(
      'rating',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    response = _is.ColumnString(
      'response',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final CustomerReviewUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString userId;

  late final _is.ColumnInt rating;

  late final _is.ColumnString text;

  late final _is.ColumnString response;

  late final _is.ColumnString status;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    userId,
    rating,
    text,
    response,
    status,
    version,
    createdAt,
  ];
}

class CustomerReviewInclude extends _is.IncludeObject {
  CustomerReviewInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CustomerReview.t;
}

class CustomerReviewIncludeList extends _is.IncludeList {
  CustomerReviewIncludeList._({
    _is.WhereExpressionBuilder<CustomerReviewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomerReview.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CustomerReview.t;
}

class CustomerReviewRepository {
  const CustomerReviewRepository._();

  /// Returns a list of [CustomerReview]s matching the given query parameters.
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
  Future<List<CustomerReview>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerReviewTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerReviewTable>? orderBy,
    _is.OrderByListBuilder<CustomerReviewTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomerReview>(
      where: where?.call(CustomerReview.t),
      orderBy: orderBy?.call(CustomerReview.t),
      orderByList: orderByList?.call(CustomerReview.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustomerReview] matching the given query parameters.
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
  Future<CustomerReview?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerReviewTable>? where,
    int? offset,
    _is.OrderByBuilder<CustomerReviewTable>? orderBy,
    _is.OrderByListBuilder<CustomerReviewTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomerReview>(
      where: where?.call(CustomerReview.t),
      orderBy: orderBy?.call(CustomerReview.t),
      orderByList: orderByList?.call(CustomerReview.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomerReview] by its [id] or null if no such row exists.
  Future<CustomerReview?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomerReview>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomerReview]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomerReview]s will have their `id` fields set.
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
  Future<List<CustomerReview>> insert(
    _is.DatabaseSession session,
    List<CustomerReview> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomerReview>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomerReview] and returns the inserted row.
  ///
  /// The returned [CustomerReview] will have its `id` field set.
  Future<CustomerReview> insertRow(
    _is.DatabaseSession session,
    CustomerReview row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomerReview>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomerReview]s in the list and returns the resulting rows.
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
  /// The returned [CustomerReview]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerReview>> upsert(
    _is.DatabaseSession session,
    List<CustomerReview> rows, {
    required _is.ColumnSelections<CustomerReviewTable> conflictColumns,
    _is.ColumnSelections<CustomerReviewTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerReviewTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomerReview>(
      rows,
      conflictColumns: conflictColumns(CustomerReview.t),
      updateColumns: updateColumns?.call(CustomerReview.t),
      updateWhere: updateWhere?.call(CustomerReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomerReview] and returns the resulting row.
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
  /// The returned [CustomerReview] will have its `id` field set.
  Future<CustomerReview?> upsertRow(
    _is.DatabaseSession session,
    CustomerReview row, {
    required _is.ColumnSelections<CustomerReviewTable> conflictColumns,
    _is.ColumnSelections<CustomerReviewTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerReviewTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomerReview>(
      row,
      conflictColumns: conflictColumns(CustomerReview.t),
      updateColumns: updateColumns?.call(CustomerReview.t),
      updateWhere: updateWhere?.call(CustomerReview.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerReview]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerReview>> update(
    _is.DatabaseSession session,
    List<CustomerReview> rows, {
    _is.ColumnSelections<CustomerReviewTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomerReview>(
      rows,
      columns: columns?.call(CustomerReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomerReview]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomerReview> updateRow(
    _is.DatabaseSession session,
    CustomerReview row, {
    _is.ColumnSelections<CustomerReviewTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomerReview>(
      row,
      columns: columns?.call(CustomerReview.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomerReview] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomerReview?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CustomerReviewUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomerReview>(
      id,
      columnValues: columnValues(CustomerReview.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerReview]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerReview>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustomerReviewUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CustomerReviewTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerReviewTable>? orderBy,
    _is.OrderByListBuilder<CustomerReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomerReview>(
      columnValues: columnValues(CustomerReview.t.updateTable),
      where: where(CustomerReview.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerReview.t),
      orderByList: orderByList?.call(CustomerReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomerReview]s in the list and returns the deleted rows.
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
  Future<List<CustomerReview>> delete(
    _is.DatabaseSession session,
    List<CustomerReview> rows, {
    _is.OrderByBuilder<CustomerReviewTable>? orderBy,
    _is.OrderByListBuilder<CustomerReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomerReview>(
      rows,
      orderBy: orderBy?.call(CustomerReview.t),
      orderByList: orderByList?.call(CustomerReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomerReview].
  Future<CustomerReview> deleteRow(
    _is.DatabaseSession session,
    CustomerReview row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomerReview>(
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
  Future<List<CustomerReview>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerReviewTable> where,
    _is.OrderByBuilder<CustomerReviewTable>? orderBy,
    _is.OrderByListBuilder<CustomerReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomerReview>(
      where: where(CustomerReview.t),
      orderBy: orderBy?.call(CustomerReview.t),
      orderByList: orderByList?.call(CustomerReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerReviewTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustomerReview>(
      where: where?.call(CustomerReview.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomerReview] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerReviewTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomerReview>(
      where: where(CustomerReview.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
