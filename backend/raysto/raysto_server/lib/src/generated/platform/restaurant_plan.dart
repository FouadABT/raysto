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

abstract class RestaurantPlan
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RestaurantPlan._({
    this.id,
    required this.code,
    required this.version,
    required this.currency,
    required this.priceMinor,
    required this.commissionBps,
    required this.featuresJson,
    this.providerPlanId,
    required this.active,
    required this.createdAt,
  });

  factory RestaurantPlan({
    int? id,
    required String code,
    required int version,
    required String currency,
    required int priceMinor,
    required int commissionBps,
    required String featuresJson,
    String? providerPlanId,
    required bool active,
    required DateTime createdAt,
  }) = _RestaurantPlanImpl;

  factory RestaurantPlan.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestaurantPlan(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      version: jsonSerialization['version'] as int,
      currency: jsonSerialization['currency'] as String,
      priceMinor: jsonSerialization['priceMinor'] as int,
      commissionBps: jsonSerialization['commissionBps'] as int,
      featuresJson: jsonSerialization['featuresJson'] as String,
      providerPlanId: jsonSerialization['providerPlanId'] as String?,
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = RestaurantPlanTable();

  static const db = RestaurantPlanRepository._();

  @override
  int? id;

  String code;

  int version;

  String currency;

  int priceMinor;

  int commissionBps;

  String featuresJson;

  String? providerPlanId;

  bool active;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RestaurantPlan]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RestaurantPlan copyWith({
    int? id,
    String? code,
    int? version,
    String? currency,
    int? priceMinor,
    int? commissionBps,
    String? featuresJson,
    String? providerPlanId,
    bool? active,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestaurantPlan',
      if (id != null) 'id': id,
      'code': code,
      'version': version,
      'currency': currency,
      'priceMinor': priceMinor,
      'commissionBps': commissionBps,
      'featuresJson': featuresJson,
      if (providerPlanId != null) 'providerPlanId': providerPlanId,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RestaurantPlanInclude include() {
    return RestaurantPlanInclude._();
  }

  static RestaurantPlanIncludeList includeList({
    _is.WhereExpressionBuilder<RestaurantPlanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantPlanTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPlanTable>? orderByList,
    RestaurantPlanInclude? include,
  }) {
    return RestaurantPlanIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantPlan.t),
      orderByList: orderByList?.call(RestaurantPlan.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantPlanImpl extends RestaurantPlan {
  _RestaurantPlanImpl({
    int? id,
    required String code,
    required int version,
    required String currency,
    required int priceMinor,
    required int commissionBps,
    required String featuresJson,
    String? providerPlanId,
    required bool active,
    required DateTime createdAt,
  }) : super._(
         id: id,
         code: code,
         version: version,
         currency: currency,
         priceMinor: priceMinor,
         commissionBps: commissionBps,
         featuresJson: featuresJson,
         providerPlanId: providerPlanId,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [RestaurantPlan]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RestaurantPlan copyWith({
    Object? id = _Undefined,
    String? code,
    int? version,
    String? currency,
    int? priceMinor,
    int? commissionBps,
    String? featuresJson,
    Object? providerPlanId = _Undefined,
    bool? active,
    DateTime? createdAt,
  }) {
    return RestaurantPlan(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      version: version ?? this.version,
      currency: currency ?? this.currency,
      priceMinor: priceMinor ?? this.priceMinor,
      commissionBps: commissionBps ?? this.commissionBps,
      featuresJson: featuresJson ?? this.featuresJson,
      providerPlanId: providerPlanId is String?
          ? providerPlanId
          : this.providerPlanId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RestaurantPlanUpdateTable extends _is.UpdateTable<RestaurantPlanTable> {
  RestaurantPlanUpdateTable(super.table);

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<int, int> priceMinor(int value) => _is.ColumnValue(
    table.priceMinor,
    value,
  );

  _is.ColumnValue<int, int> commissionBps(int value) => _is.ColumnValue(
    table.commissionBps,
    value,
  );

  _is.ColumnValue<String, String> featuresJson(String value) => _is.ColumnValue(
    table.featuresJson,
    value,
  );

  _is.ColumnValue<String, String> providerPlanId(String? value) =>
      _is.ColumnValue(
        table.providerPlanId,
        value,
      );

  _is.ColumnValue<bool, bool> active(bool value) => _is.ColumnValue(
    table.active,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class RestaurantPlanTable extends _is.Table<int?> {
  RestaurantPlanTable({super.tableRelation})
    : super(tableName: 'raysto_restaurant_plan') {
    updateTable = RestaurantPlanUpdateTable(this);
    code = _is.ColumnString(
      'code',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    priceMinor = _is.ColumnInt(
      'priceMinor',
      this,
    );
    commissionBps = _is.ColumnInt(
      'commissionBps',
      this,
    );
    featuresJson = _is.ColumnString(
      'featuresJson',
      this,
    );
    providerPlanId = _is.ColumnString(
      'providerPlanId',
      this,
    );
    active = _is.ColumnBool(
      'active',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final RestaurantPlanUpdateTable updateTable;

  late final _is.ColumnString code;

  late final _is.ColumnInt version;

  late final _is.ColumnString currency;

  late final _is.ColumnInt priceMinor;

  late final _is.ColumnInt commissionBps;

  late final _is.ColumnString featuresJson;

  late final _is.ColumnString providerPlanId;

  late final _is.ColumnBool active;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    code,
    version,
    currency,
    priceMinor,
    commissionBps,
    featuresJson,
    providerPlanId,
    active,
    createdAt,
  ];
}

class RestaurantPlanInclude extends _is.IncludeObject {
  RestaurantPlanInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RestaurantPlan.t;
}

class RestaurantPlanIncludeList extends _is.IncludeList {
  RestaurantPlanIncludeList._({
    _is.WhereExpressionBuilder<RestaurantPlanTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RestaurantPlan.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RestaurantPlan.t;
}

class RestaurantPlanRepository {
  const RestaurantPlanRepository._();

  /// Returns a list of [RestaurantPlan]s matching the given query parameters.
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
  Future<List<RestaurantPlan>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantPlanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantPlanTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPlanTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RestaurantPlan>(
      where: where?.call(RestaurantPlan.t),
      orderBy: orderBy?.call(RestaurantPlan.t),
      orderByList: orderByList?.call(RestaurantPlan.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RestaurantPlan] matching the given query parameters.
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
  Future<RestaurantPlan?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantPlanTable>? where,
    int? offset,
    _is.OrderByBuilder<RestaurantPlanTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPlanTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RestaurantPlan>(
      where: where?.call(RestaurantPlan.t),
      orderBy: orderBy?.call(RestaurantPlan.t),
      orderByList: orderByList?.call(RestaurantPlan.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RestaurantPlan] by its [id] or null if no such row exists.
  Future<RestaurantPlan?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RestaurantPlan>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RestaurantPlan]s in the list and returns the inserted rows.
  ///
  /// The returned [RestaurantPlan]s will have their `id` fields set.
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
  Future<List<RestaurantPlan>> insert(
    _is.DatabaseSession session,
    List<RestaurantPlan> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RestaurantPlan>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RestaurantPlan] and returns the inserted row.
  ///
  /// The returned [RestaurantPlan] will have its `id` field set.
  Future<RestaurantPlan> insertRow(
    _is.DatabaseSession session,
    RestaurantPlan row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RestaurantPlan>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RestaurantPlan]s in the list and returns the resulting rows.
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
  /// The returned [RestaurantPlan]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantPlan>> upsert(
    _is.DatabaseSession session,
    List<RestaurantPlan> rows, {
    required _is.ColumnSelections<RestaurantPlanTable> conflictColumns,
    _is.ColumnSelections<RestaurantPlanTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantPlanTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RestaurantPlan>(
      rows,
      conflictColumns: conflictColumns(RestaurantPlan.t),
      updateColumns: updateColumns?.call(RestaurantPlan.t),
      updateWhere: updateWhere?.call(RestaurantPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RestaurantPlan] and returns the resulting row.
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
  /// The returned [RestaurantPlan] will have its `id` field set.
  Future<RestaurantPlan?> upsertRow(
    _is.DatabaseSession session,
    RestaurantPlan row, {
    required _is.ColumnSelections<RestaurantPlanTable> conflictColumns,
    _is.ColumnSelections<RestaurantPlanTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantPlanTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RestaurantPlan>(
      row,
      conflictColumns: conflictColumns(RestaurantPlan.t),
      updateColumns: updateColumns?.call(RestaurantPlan.t),
      updateWhere: updateWhere?.call(RestaurantPlan.t),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantPlan]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantPlan>> update(
    _is.DatabaseSession session,
    List<RestaurantPlan> rows, {
    _is.ColumnSelections<RestaurantPlanTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RestaurantPlan>(
      rows,
      columns: columns?.call(RestaurantPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RestaurantPlan]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RestaurantPlan> updateRow(
    _is.DatabaseSession session,
    RestaurantPlan row, {
    _is.ColumnSelections<RestaurantPlanTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RestaurantPlan>(
      row,
      columns: columns?.call(RestaurantPlan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestaurantPlan] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RestaurantPlan?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RestaurantPlanUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RestaurantPlan>(
      id,
      columnValues: columnValues(RestaurantPlan.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantPlan]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantPlan>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RestaurantPlanUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RestaurantPlanTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantPlanTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPlanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RestaurantPlan>(
      columnValues: columnValues(RestaurantPlan.t.updateTable),
      where: where(RestaurantPlan.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantPlan.t),
      orderByList: orderByList?.call(RestaurantPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RestaurantPlan]s in the list and returns the deleted rows.
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
  Future<List<RestaurantPlan>> delete(
    _is.DatabaseSession session,
    List<RestaurantPlan> rows, {
    _is.OrderByBuilder<RestaurantPlanTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPlanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RestaurantPlan>(
      rows,
      orderBy: orderBy?.call(RestaurantPlan.t),
      orderByList: orderByList?.call(RestaurantPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RestaurantPlan].
  Future<RestaurantPlan> deleteRow(
    _is.DatabaseSession session,
    RestaurantPlan row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RestaurantPlan>(
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
  Future<List<RestaurantPlan>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantPlanTable> where,
    _is.OrderByBuilder<RestaurantPlanTable>? orderBy,
    _is.OrderByListBuilder<RestaurantPlanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RestaurantPlan>(
      where: where(RestaurantPlan.t),
      orderBy: orderBy?.call(RestaurantPlan.t),
      orderByList: orderByList?.call(RestaurantPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantPlanTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RestaurantPlan>(
      where: where?.call(RestaurantPlan.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RestaurantPlan] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantPlanTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RestaurantPlan>(
      where: where(RestaurantPlan.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
