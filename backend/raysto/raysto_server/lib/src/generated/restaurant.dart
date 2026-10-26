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

abstract class Restaurant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Restaurant._({
    this.id,
    required this.name,
    required this.currency,
    required this.deliveryFeeMinor,
    required this.published,
    required this.createdAt,
  });

  factory Restaurant({
    int? id,
    required String name,
    required String currency,
    required int deliveryFeeMinor,
    required bool published,
    required DateTime createdAt,
  }) = _RestaurantImpl;

  factory Restaurant.fromJson(Map<String, dynamic> jsonSerialization) {
    return Restaurant(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      currency: jsonSerialization['currency'] as String,
      deliveryFeeMinor: jsonSerialization['deliveryFeeMinor'] as int,
      published: _is.BoolJsonExtension.fromJson(jsonSerialization['published']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = RestaurantTable();

  static const db = RestaurantRepository._();

  @override
  int? id;

  String name;

  String currency;

  int deliveryFeeMinor;

  bool published;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Restaurant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Restaurant copyWith({
    int? id,
    String? name,
    String? currency,
    int? deliveryFeeMinor,
    bool? published,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Restaurant',
      if (id != null) 'id': id,
      'name': name,
      'currency': currency,
      'deliveryFeeMinor': deliveryFeeMinor,
      'published': published,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Restaurant',
      if (id != null) 'id': id,
      'name': name,
      'currency': currency,
      'deliveryFeeMinor': deliveryFeeMinor,
      'published': published,
      'createdAt': createdAt.toJson(),
    };
  }

  static RestaurantInclude include() {
    return RestaurantInclude._();
  }

  static RestaurantIncludeList includeList({
    _is.WhereExpressionBuilder<RestaurantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantTable>? orderBy,
    _is.OrderByListBuilder<RestaurantTable>? orderByList,
    RestaurantInclude? include,
  }) {
    return RestaurantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Restaurant.t),
      orderByList: orderByList?.call(Restaurant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantImpl extends Restaurant {
  _RestaurantImpl({
    int? id,
    required String name,
    required String currency,
    required int deliveryFeeMinor,
    required bool published,
    required DateTime createdAt,
  }) : super._(
         id: id,
         name: name,
         currency: currency,
         deliveryFeeMinor: deliveryFeeMinor,
         published: published,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Restaurant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Restaurant copyWith({
    Object? id = _Undefined,
    String? name,
    String? currency,
    int? deliveryFeeMinor,
    bool? published,
    DateTime? createdAt,
  }) {
    return Restaurant(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      deliveryFeeMinor: deliveryFeeMinor ?? this.deliveryFeeMinor,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RestaurantUpdateTable extends _is.UpdateTable<RestaurantTable> {
  RestaurantUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<int, int> deliveryFeeMinor(int value) => _is.ColumnValue(
    table.deliveryFeeMinor,
    value,
  );

  _is.ColumnValue<bool, bool> published(bool value) => _is.ColumnValue(
    table.published,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class RestaurantTable extends _is.Table<int?> {
  RestaurantTable({super.tableRelation})
    : super(tableName: 'raysto_restaurant') {
    updateTable = RestaurantUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    deliveryFeeMinor = _is.ColumnInt(
      'deliveryFeeMinor',
      this,
    );
    published = _is.ColumnBool(
      'published',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final RestaurantUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnString currency;

  late final _is.ColumnInt deliveryFeeMinor;

  late final _is.ColumnBool published;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    currency,
    deliveryFeeMinor,
    published,
    createdAt,
  ];
}

class RestaurantInclude extends _is.IncludeObject {
  RestaurantInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Restaurant.t;
}

class RestaurantIncludeList extends _is.IncludeList {
  RestaurantIncludeList._({
    _is.WhereExpressionBuilder<RestaurantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Restaurant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Restaurant.t;
}

class RestaurantRepository {
  const RestaurantRepository._();

  /// Returns a list of [Restaurant]s matching the given query parameters.
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
  Future<List<Restaurant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantTable>? orderBy,
    _is.OrderByListBuilder<RestaurantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Restaurant>(
      where: where?.call(Restaurant.t),
      orderBy: orderBy?.call(Restaurant.t),
      orderByList: orderByList?.call(Restaurant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Restaurant] matching the given query parameters.
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
  Future<Restaurant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantTable>? where,
    int? offset,
    _is.OrderByBuilder<RestaurantTable>? orderBy,
    _is.OrderByListBuilder<RestaurantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Restaurant>(
      where: where?.call(Restaurant.t),
      orderBy: orderBy?.call(Restaurant.t),
      orderByList: orderByList?.call(Restaurant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Restaurant] by its [id] or null if no such row exists.
  Future<Restaurant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Restaurant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Restaurant]s in the list and returns the inserted rows.
  ///
  /// The returned [Restaurant]s will have their `id` fields set.
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
  Future<List<Restaurant>> insert(
    _is.DatabaseSession session,
    List<Restaurant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Restaurant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Restaurant] and returns the inserted row.
  ///
  /// The returned [Restaurant] will have its `id` field set.
  Future<Restaurant> insertRow(
    _is.DatabaseSession session,
    Restaurant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Restaurant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Restaurant]s in the list and returns the resulting rows.
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
  /// The returned [Restaurant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Restaurant>> upsert(
    _is.DatabaseSession session,
    List<Restaurant> rows, {
    required _is.ColumnSelections<RestaurantTable> conflictColumns,
    _is.ColumnSelections<RestaurantTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Restaurant>(
      rows,
      conflictColumns: conflictColumns(Restaurant.t),
      updateColumns: updateColumns?.call(Restaurant.t),
      updateWhere: updateWhere?.call(Restaurant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Restaurant] and returns the resulting row.
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
  /// The returned [Restaurant] will have its `id` field set.
  Future<Restaurant?> upsertRow(
    _is.DatabaseSession session,
    Restaurant row, {
    required _is.ColumnSelections<RestaurantTable> conflictColumns,
    _is.ColumnSelections<RestaurantTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Restaurant>(
      row,
      conflictColumns: conflictColumns(Restaurant.t),
      updateColumns: updateColumns?.call(Restaurant.t),
      updateWhere: updateWhere?.call(Restaurant.t),
      transaction: transaction,
    );
  }

  /// Updates all [Restaurant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Restaurant>> update(
    _is.DatabaseSession session,
    List<Restaurant> rows, {
    _is.ColumnSelections<RestaurantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Restaurant>(
      rows,
      columns: columns?.call(Restaurant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Restaurant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Restaurant> updateRow(
    _is.DatabaseSession session,
    Restaurant row, {
    _is.ColumnSelections<RestaurantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Restaurant>(
      row,
      columns: columns?.call(Restaurant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Restaurant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Restaurant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RestaurantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Restaurant>(
      id,
      columnValues: columnValues(Restaurant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Restaurant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Restaurant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RestaurantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RestaurantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantTable>? orderBy,
    _is.OrderByListBuilder<RestaurantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Restaurant>(
      columnValues: columnValues(Restaurant.t.updateTable),
      where: where(Restaurant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Restaurant.t),
      orderByList: orderByList?.call(Restaurant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Restaurant]s in the list and returns the deleted rows.
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
  Future<List<Restaurant>> delete(
    _is.DatabaseSession session,
    List<Restaurant> rows, {
    _is.OrderByBuilder<RestaurantTable>? orderBy,
    _is.OrderByListBuilder<RestaurantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Restaurant>(
      rows,
      orderBy: orderBy?.call(Restaurant.t),
      orderByList: orderByList?.call(Restaurant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Restaurant].
  Future<Restaurant> deleteRow(
    _is.DatabaseSession session,
    Restaurant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Restaurant>(
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
  Future<List<Restaurant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantTable> where,
    _is.OrderByBuilder<RestaurantTable>? orderBy,
    _is.OrderByListBuilder<RestaurantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Restaurant>(
      where: where(Restaurant.t),
      orderBy: orderBy?.call(Restaurant.t),
      orderByList: orderByList?.call(Restaurant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Restaurant>(
      where: where?.call(Restaurant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Restaurant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Restaurant>(
      where: where(Restaurant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
