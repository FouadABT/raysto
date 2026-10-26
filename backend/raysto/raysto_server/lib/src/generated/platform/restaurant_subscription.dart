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

abstract class RestaurantSubscription
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RestaurantSubscription._({
    this.id,
    required this.restaurantId,
    required this.planId,
    this.providerSubscriptionId,
    required this.status,
    this.periodEndsAt,
    this.graceEndsAt,
    this.approvalUrl,
    required this.requestKey,
    required this.updatedAt,
  });

  factory RestaurantSubscription({
    int? id,
    required int restaurantId,
    required int planId,
    String? providerSubscriptionId,
    required String status,
    DateTime? periodEndsAt,
    DateTime? graceEndsAt,
    String? approvalUrl,
    required String requestKey,
    required DateTime updatedAt,
  }) = _RestaurantSubscriptionImpl;

  factory RestaurantSubscription.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RestaurantSubscription(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      planId: jsonSerialization['planId'] as int,
      providerSubscriptionId:
          jsonSerialization['providerSubscriptionId'] as String?,
      status: jsonSerialization['status'] as String,
      periodEndsAt: jsonSerialization['periodEndsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['periodEndsAt'],
            ),
      graceEndsAt: jsonSerialization['graceEndsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['graceEndsAt'],
            ),
      approvalUrl: jsonSerialization['approvalUrl'] as String?,
      requestKey: jsonSerialization['requestKey'] as String,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = RestaurantSubscriptionTable();

  static const db = RestaurantSubscriptionRepository._();

  @override
  int? id;

  int restaurantId;

  int planId;

  String? providerSubscriptionId;

  String status;

  DateTime? periodEndsAt;

  DateTime? graceEndsAt;

  String? approvalUrl;

  String requestKey;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RestaurantSubscription]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RestaurantSubscription copyWith({
    int? id,
    int? restaurantId,
    int? planId,
    String? providerSubscriptionId,
    String? status,
    DateTime? periodEndsAt,
    DateTime? graceEndsAt,
    String? approvalUrl,
    String? requestKey,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestaurantSubscription',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'planId': planId,
      if (providerSubscriptionId != null)
        'providerSubscriptionId': providerSubscriptionId,
      'status': status,
      if (periodEndsAt != null) 'periodEndsAt': periodEndsAt?.toJson(),
      if (graceEndsAt != null) 'graceEndsAt': graceEndsAt?.toJson(),
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      'requestKey': requestKey,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RestaurantSubscriptionInclude include() {
    return RestaurantSubscriptionInclude._();
  }

  static RestaurantSubscriptionIncludeList includeList({
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantSubscriptionTable>? orderBy,
    _is.OrderByListBuilder<RestaurantSubscriptionTable>? orderByList,
    RestaurantSubscriptionInclude? include,
  }) {
    return RestaurantSubscriptionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantSubscription.t),
      orderByList: orderByList?.call(RestaurantSubscription.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantSubscriptionImpl extends RestaurantSubscription {
  _RestaurantSubscriptionImpl({
    int? id,
    required int restaurantId,
    required int planId,
    String? providerSubscriptionId,
    required String status,
    DateTime? periodEndsAt,
    DateTime? graceEndsAt,
    String? approvalUrl,
    required String requestKey,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         planId: planId,
         providerSubscriptionId: providerSubscriptionId,
         status: status,
         periodEndsAt: periodEndsAt,
         graceEndsAt: graceEndsAt,
         approvalUrl: approvalUrl,
         requestKey: requestKey,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RestaurantSubscription]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RestaurantSubscription copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? planId,
    Object? providerSubscriptionId = _Undefined,
    String? status,
    Object? periodEndsAt = _Undefined,
    Object? graceEndsAt = _Undefined,
    Object? approvalUrl = _Undefined,
    String? requestKey,
    DateTime? updatedAt,
  }) {
    return RestaurantSubscription(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      planId: planId ?? this.planId,
      providerSubscriptionId: providerSubscriptionId is String?
          ? providerSubscriptionId
          : this.providerSubscriptionId,
      status: status ?? this.status,
      periodEndsAt: periodEndsAt is DateTime?
          ? periodEndsAt
          : this.periodEndsAt,
      graceEndsAt: graceEndsAt is DateTime? ? graceEndsAt : this.graceEndsAt,
      approvalUrl: approvalUrl is String? ? approvalUrl : this.approvalUrl,
      requestKey: requestKey ?? this.requestKey,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RestaurantSubscriptionUpdateTable
    extends _is.UpdateTable<RestaurantSubscriptionTable> {
  RestaurantSubscriptionUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> planId(int value) => _is.ColumnValue(
    table.planId,
    value,
  );

  _is.ColumnValue<String, String> providerSubscriptionId(String? value) =>
      _is.ColumnValue(
        table.providerSubscriptionId,
        value,
      );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> periodEndsAt(DateTime? value) =>
      _is.ColumnValue(
        table.periodEndsAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> graceEndsAt(DateTime? value) =>
      _is.ColumnValue(
        table.graceEndsAt,
        value,
      );

  _is.ColumnValue<String, String> approvalUrl(String? value) => _is.ColumnValue(
    table.approvalUrl,
    value,
  );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RestaurantSubscriptionTable extends _is.Table<int?> {
  RestaurantSubscriptionTable({super.tableRelation})
    : super(tableName: 'raysto_restaurant_subscription') {
    updateTable = RestaurantSubscriptionUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    planId = _is.ColumnInt(
      'planId',
      this,
    );
    providerSubscriptionId = _is.ColumnString(
      'providerSubscriptionId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    periodEndsAt = _is.ColumnDateTime(
      'periodEndsAt',
      this,
    );
    graceEndsAt = _is.ColumnDateTime(
      'graceEndsAt',
      this,
    );
    approvalUrl = _is.ColumnString(
      'approvalUrl',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RestaurantSubscriptionUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt planId;

  late final _is.ColumnString providerSubscriptionId;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime periodEndsAt;

  late final _is.ColumnDateTime graceEndsAt;

  late final _is.ColumnString approvalUrl;

  late final _is.ColumnString requestKey;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    planId,
    providerSubscriptionId,
    status,
    periodEndsAt,
    graceEndsAt,
    approvalUrl,
    requestKey,
    updatedAt,
  ];
}

class RestaurantSubscriptionInclude extends _is.IncludeObject {
  RestaurantSubscriptionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RestaurantSubscription.t;
}

class RestaurantSubscriptionIncludeList extends _is.IncludeList {
  RestaurantSubscriptionIncludeList._({
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RestaurantSubscription.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RestaurantSubscription.t;
}

class RestaurantSubscriptionRepository {
  const RestaurantSubscriptionRepository._();

  /// Returns a list of [RestaurantSubscription]s matching the given query parameters.
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
  Future<List<RestaurantSubscription>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantSubscriptionTable>? orderBy,
    _is.OrderByListBuilder<RestaurantSubscriptionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RestaurantSubscription>(
      where: where?.call(RestaurantSubscription.t),
      orderBy: orderBy?.call(RestaurantSubscription.t),
      orderByList: orderByList?.call(RestaurantSubscription.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RestaurantSubscription] matching the given query parameters.
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
  Future<RestaurantSubscription?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? where,
    int? offset,
    _is.OrderByBuilder<RestaurantSubscriptionTable>? orderBy,
    _is.OrderByListBuilder<RestaurantSubscriptionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RestaurantSubscription>(
      where: where?.call(RestaurantSubscription.t),
      orderBy: orderBy?.call(RestaurantSubscription.t),
      orderByList: orderByList?.call(RestaurantSubscription.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RestaurantSubscription] by its [id] or null if no such row exists.
  Future<RestaurantSubscription?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RestaurantSubscription>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RestaurantSubscription]s in the list and returns the inserted rows.
  ///
  /// The returned [RestaurantSubscription]s will have their `id` fields set.
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
  Future<List<RestaurantSubscription>> insert(
    _is.DatabaseSession session,
    List<RestaurantSubscription> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RestaurantSubscription>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RestaurantSubscription] and returns the inserted row.
  ///
  /// The returned [RestaurantSubscription] will have its `id` field set.
  Future<RestaurantSubscription> insertRow(
    _is.DatabaseSession session,
    RestaurantSubscription row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RestaurantSubscription>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RestaurantSubscription]s in the list and returns the resulting rows.
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
  /// The returned [RestaurantSubscription]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantSubscription>> upsert(
    _is.DatabaseSession session,
    List<RestaurantSubscription> rows, {
    required _is.ColumnSelections<RestaurantSubscriptionTable> conflictColumns,
    _is.ColumnSelections<RestaurantSubscriptionTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RestaurantSubscription>(
      rows,
      conflictColumns: conflictColumns(RestaurantSubscription.t),
      updateColumns: updateColumns?.call(RestaurantSubscription.t),
      updateWhere: updateWhere?.call(RestaurantSubscription.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RestaurantSubscription] and returns the resulting row.
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
  /// The returned [RestaurantSubscription] will have its `id` field set.
  Future<RestaurantSubscription?> upsertRow(
    _is.DatabaseSession session,
    RestaurantSubscription row, {
    required _is.ColumnSelections<RestaurantSubscriptionTable> conflictColumns,
    _is.ColumnSelections<RestaurantSubscriptionTable>? updateColumns,
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RestaurantSubscription>(
      row,
      conflictColumns: conflictColumns(RestaurantSubscription.t),
      updateColumns: updateColumns?.call(RestaurantSubscription.t),
      updateWhere: updateWhere?.call(RestaurantSubscription.t),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantSubscription]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantSubscription>> update(
    _is.DatabaseSession session,
    List<RestaurantSubscription> rows, {
    _is.ColumnSelections<RestaurantSubscriptionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RestaurantSubscription>(
      rows,
      columns: columns?.call(RestaurantSubscription.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RestaurantSubscription]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RestaurantSubscription> updateRow(
    _is.DatabaseSession session,
    RestaurantSubscription row, {
    _is.ColumnSelections<RestaurantSubscriptionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RestaurantSubscription>(
      row,
      columns: columns?.call(RestaurantSubscription.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestaurantSubscription] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RestaurantSubscription?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RestaurantSubscriptionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RestaurantSubscription>(
      id,
      columnValues: columnValues(RestaurantSubscription.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantSubscription]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RestaurantSubscription>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RestaurantSubscriptionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RestaurantSubscriptionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RestaurantSubscriptionTable>? orderBy,
    _is.OrderByListBuilder<RestaurantSubscriptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RestaurantSubscription>(
      columnValues: columnValues(RestaurantSubscription.t.updateTable),
      where: where(RestaurantSubscription.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantSubscription.t),
      orderByList: orderByList?.call(RestaurantSubscription.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RestaurantSubscription]s in the list and returns the deleted rows.
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
  Future<List<RestaurantSubscription>> delete(
    _is.DatabaseSession session,
    List<RestaurantSubscription> rows, {
    _is.OrderByBuilder<RestaurantSubscriptionTable>? orderBy,
    _is.OrderByListBuilder<RestaurantSubscriptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RestaurantSubscription>(
      rows,
      orderBy: orderBy?.call(RestaurantSubscription.t),
      orderByList: orderByList?.call(RestaurantSubscription.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RestaurantSubscription].
  Future<RestaurantSubscription> deleteRow(
    _is.DatabaseSession session,
    RestaurantSubscription row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RestaurantSubscription>(
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
  Future<List<RestaurantSubscription>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantSubscriptionTable> where,
    _is.OrderByBuilder<RestaurantSubscriptionTable>? orderBy,
    _is.OrderByListBuilder<RestaurantSubscriptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RestaurantSubscription>(
      where: where(RestaurantSubscription.t),
      orderBy: orderBy?.call(RestaurantSubscription.t),
      orderByList: orderByList?.call(RestaurantSubscription.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RestaurantSubscriptionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RestaurantSubscription>(
      where: where?.call(RestaurantSubscription.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RestaurantSubscription] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RestaurantSubscriptionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RestaurantSubscription>(
      where: where(RestaurantSubscription.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
