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

abstract class RestaurantPolicy
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RestaurantPolicy._({
    this.id,
    required this.restaurantId,
    required this.settingsJson,
    required this.version,
    required this.menuVersion,
    required this.suspended,
    int? orderSeq,
    this.orderSeqDay,
    required this.createdAt,
    required this.updatedAt,
  }) : orderSeq = orderSeq ?? 0;

  factory RestaurantPolicy({
    int? id,
    required int restaurantId,
    required String settingsJson,
    required int version,
    required int menuVersion,
    required bool suspended,
    int? orderSeq,
    String? orderSeqDay,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RestaurantPolicyImpl;

  factory RestaurantPolicy.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestaurantPolicy(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      settingsJson: jsonSerialization['settingsJson'] as String,
      version: jsonSerialization['version'] as int,
      menuVersion: jsonSerialization['menuVersion'] as int,
      suspended: _is.BoolJsonExtension.fromJson(jsonSerialization['suspended']),
      orderSeq: jsonSerialization['orderSeq'] as int?,
      orderSeqDay: jsonSerialization['orderSeqDay'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = RestaurantPolicyTable();

  static const db = RestaurantPolicyRepository._();

  @override
  int? id;

  int restaurantId;

  String settingsJson;

  int version;

  int menuVersion;

  bool suspended;

  int orderSeq;

  String? orderSeqDay;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RestaurantPolicy]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RestaurantPolicy copyWith({
    int? id,
    int? restaurantId,
    String? settingsJson,
    int? version,
    int? menuVersion,
    bool? suspended,
    int? orderSeq,
    String? orderSeqDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestaurantPolicy',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'settingsJson': settingsJson,
      'version': version,
      'menuVersion': menuVersion,
      'suspended': suspended,
      'orderSeq': orderSeq,
      if (orderSeqDay != null) 'orderSeqDay': orderSeqDay,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RestaurantPolicyInclude include() {
    return RestaurantPolicyInclude._();
  }

  static RestaurantPolicyIncludeList includeList({
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantPolicyTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPolicyTable>? orderByList,
    RestaurantPolicyInclude? include,
  }) {
    return RestaurantPolicyIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantPolicy.t),
      orderByList: orderByList?.call(RestaurantPolicy.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantPolicyImpl extends RestaurantPolicy {
  _RestaurantPolicyImpl({
    int? id,
    required int restaurantId,
    required String settingsJson,
    required int version,
    required int menuVersion,
    required bool suspended,
    int? orderSeq,
    String? orderSeqDay,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         settingsJson: settingsJson,
         version: version,
         menuVersion: menuVersion,
         suspended: suspended,
         orderSeq: orderSeq,
         orderSeqDay: orderSeqDay,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RestaurantPolicy]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RestaurantPolicy copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? settingsJson,
    int? version,
    int? menuVersion,
    bool? suspended,
    int? orderSeq,
    Object? orderSeqDay = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantPolicy(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      settingsJson: settingsJson ?? this.settingsJson,
      version: version ?? this.version,
      menuVersion: menuVersion ?? this.menuVersion,
      suspended: suspended ?? this.suspended,
      orderSeq: orderSeq ?? this.orderSeq,
      orderSeqDay: orderSeqDay is String? ? orderSeqDay : this.orderSeqDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RestaurantPolicyUpdateTable
    extends _is.UpdateTable<RestaurantPolicyTable> {
  RestaurantPolicyUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> settingsJson(String value) => _is.ColumnValue(
    table.settingsJson,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<int, int> menuVersion(int value) => _is.ColumnValue(
    table.menuVersion,
    value,
  );

  _is.ColumnValue<bool, bool> suspended(bool value) => _is.ColumnValue(
    table.suspended,
    value,
  );

  _is.ColumnValue<int, int> orderSeq(int value) => _is.ColumnValue(
    table.orderSeq,
    value,
  );

  _is.ColumnValue<String, String> orderSeqDay(String? value) => _is.ColumnValue(
    table.orderSeqDay,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RestaurantPolicyTable extends _is.Table<int?> {
  RestaurantPolicyTable({super.tableRelation})
    : super(tableName: 'raysto_restaurant_policy') {
    updateTable = RestaurantPolicyUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    settingsJson = _is.ColumnString(
      'settingsJson',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    menuVersion = _is.ColumnInt(
      'menuVersion',
      this,
    );
    suspended = _is.ColumnBool(
      'suspended',
      this,
    );
    orderSeq = _is.ColumnInt(
      'orderSeq',
      this,
      hasDefault: true,
    );
    orderSeqDay = _is.ColumnString(
      'orderSeqDay',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RestaurantPolicyUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString settingsJson;

  late final _is.ColumnInt version;

  late final _is.ColumnInt menuVersion;

  late final _is.ColumnBool suspended;

  late final _is.ColumnInt orderSeq;

  late final _is.ColumnString orderSeqDay;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    settingsJson,
    version,
    menuVersion,
    suspended,
    orderSeq,
    orderSeqDay,
    createdAt,
    updatedAt,
  ];
}

class RestaurantPolicyInclude extends _is.IncludeObject {
  RestaurantPolicyInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RestaurantPolicy.t;
}

class RestaurantPolicyIncludeList extends _is.IncludeList {
  RestaurantPolicyIncludeList._({
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RestaurantPolicy.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RestaurantPolicy.t;
}

class RestaurantPolicyRepository {
  const RestaurantPolicyRepository._();

  /// Returns a list of [RestaurantPolicy]s matching the given query parameters.
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
  Future<List<RestaurantPolicy>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantPolicyTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPolicyTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RestaurantPolicy>(
      where: where?.call(RestaurantPolicy.t),
      orderBy: orderBy?.call(RestaurantPolicy.t),
      orderByList: orderByList?.call(RestaurantPolicy.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RestaurantPolicy] matching the given query parameters.
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
  Future<RestaurantPolicy?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? where,
    int? offset,
    _is.OrderByBuilder<RestaurantPolicyTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPolicyTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RestaurantPolicy>(
      where: where?.call(RestaurantPolicy.t),
      orderBy: orderBy?.call(RestaurantPolicy.t),
      orderByList: orderByList?.call(RestaurantPolicy.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RestaurantPolicy] by its [id] or null if no such row exists.
  Future<RestaurantPolicy?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RestaurantPolicy>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RestaurantPolicy]s in the list and returns the inserted rows.
  ///
  /// The returned [RestaurantPolicy]s will have their `id` fields set.
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
  Future<List<RestaurantPolicy>> insert(
    _is.DatabaseSession session,
    List<RestaurantPolicy> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RestaurantPolicy>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RestaurantPolicy] and returns the inserted row.
  ///
  /// The returned [RestaurantPolicy] will have its `id` field set.
  Future<RestaurantPolicy> insertRow(
    _is.DatabaseSession session,
    RestaurantPolicy row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RestaurantPolicy>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RestaurantPolicy]s in the list and returns the resulting rows.
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
  /// The returned [RestaurantPolicy]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantPolicy>> upsert(
    _is.DatabaseSession session,
    List<RestaurantPolicy> rows, {
    required _is.ColumnSelections<RestaurantPolicyTable> conflictColumns,
    _is.ColumnSelections<RestaurantPolicyTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RestaurantPolicy>(
      rows,
      conflictColumns: conflictColumns(RestaurantPolicy.t),
      updateColumns: updateColumns?.call(RestaurantPolicy.t),
      updateWhere: updateWhere?.call(RestaurantPolicy.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RestaurantPolicy] and returns the resulting row.
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
  /// The returned [RestaurantPolicy] will have its `id` field set.
  Future<RestaurantPolicy?> upsertRow(
    _is.DatabaseSession session,
    RestaurantPolicy row, {
    required _is.ColumnSelections<RestaurantPolicyTable> conflictColumns,
    _is.ColumnSelections<RestaurantPolicyTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RestaurantPolicy>(
      row,
      conflictColumns: conflictColumns(RestaurantPolicy.t),
      updateColumns: updateColumns?.call(RestaurantPolicy.t),
      updateWhere: updateWhere?.call(RestaurantPolicy.t),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantPolicy]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantPolicy>> update(
    _is.DatabaseSession session,
    List<RestaurantPolicy> rows, {
    _is.ColumnSelections<RestaurantPolicyTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RestaurantPolicy>(
      rows,
      columns: columns?.call(RestaurantPolicy.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RestaurantPolicy]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RestaurantPolicy> updateRow(
    _is.DatabaseSession session,
    RestaurantPolicy row, {
    _is.ColumnSelections<RestaurantPolicyTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RestaurantPolicy>(
      row,
      columns: columns?.call(RestaurantPolicy.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestaurantPolicy] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RestaurantPolicy?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RestaurantPolicyUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RestaurantPolicy>(
      id,
      columnValues: columnValues(RestaurantPolicy.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantPolicy]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantPolicy>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RestaurantPolicyUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RestaurantPolicyTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantPolicyTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPolicyTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RestaurantPolicy>(
      columnValues: columnValues(RestaurantPolicy.t.updateTable),
      where: where(RestaurantPolicy.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantPolicy.t),
      orderByList: orderByList?.call(RestaurantPolicy.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RestaurantPolicy]s in the list and returns the deleted rows.
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
  Future<List<RestaurantPolicy>> delete(
    _is.DatabaseSession session,
    List<RestaurantPolicy> rows, {
    _is.OrderByBuilder<RestaurantPolicyTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPolicyTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RestaurantPolicy>(
      rows,
      orderBy: orderBy?.call(RestaurantPolicy.t),
      orderByList: orderByList?.call(RestaurantPolicy.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RestaurantPolicy].
  Future<RestaurantPolicy> deleteRow(
    _is.DatabaseSession session,
    RestaurantPolicy row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RestaurantPolicy>(
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
  Future<List<RestaurantPolicy>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantPolicyTable> where,
    _is.OrderByBuilder<RestaurantPolicyTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPolicyTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RestaurantPolicy>(
      where: where(RestaurantPolicy.t),
      orderBy: orderBy?.call(RestaurantPolicy.t),
      orderByList: orderByList?.call(RestaurantPolicy.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantPolicyTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RestaurantPolicy>(
      where: where?.call(RestaurantPolicy.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RestaurantPolicy] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantPolicyTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RestaurantPolicy>(
      where: where(RestaurantPolicy.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
