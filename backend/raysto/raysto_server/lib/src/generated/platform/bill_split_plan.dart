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

abstract class BillSplitPlan
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  BillSplitPlan._({
    this.id,
    required this.restaurantId,
    required this.roomId,
    this.activeRoomId,
    required this.createdBy,
    required this.payersJson,
    required this.sharesJson,
    required this.createdAt,
  });

  factory BillSplitPlan({
    int? id,
    required int restaurantId,
    required int roomId,
    int? activeRoomId,
    required String createdBy,
    required String payersJson,
    required String sharesJson,
    required DateTime createdAt,
  }) = _BillSplitPlanImpl;

  factory BillSplitPlan.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillSplitPlan(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      roomId: jsonSerialization['roomId'] as int,
      activeRoomId: jsonSerialization['activeRoomId'] as int?,
      createdBy: jsonSerialization['createdBy'] as String,
      payersJson: jsonSerialization['payersJson'] as String,
      sharesJson: jsonSerialization['sharesJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = BillSplitPlanTable();

  static const db = BillSplitPlanRepository._();

  @override
  int? id;

  int restaurantId;

  int roomId;

  int? activeRoomId;

  String createdBy;

  String payersJson;

  String sharesJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [BillSplitPlan]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BillSplitPlan copyWith({
    int? id,
    int? restaurantId,
    int? roomId,
    int? activeRoomId,
    String? createdBy,
    String? payersJson,
    String? sharesJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillSplitPlan',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'roomId': roomId,
      if (activeRoomId != null) 'activeRoomId': activeRoomId,
      'createdBy': createdBy,
      'payersJson': payersJson,
      'sharesJson': sharesJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static BillSplitPlanInclude include() {
    return BillSplitPlanInclude._();
  }

  static BillSplitPlanIncludeList includeList({
    _is.WhereExpressionBuilder<BillSplitPlanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillSplitPlanTable>? orderBy,
    _is.OrderByListBuilder<BillSplitPlanTable>? orderByList,
    BillSplitPlanInclude? include,
  }) {
    return BillSplitPlanIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillSplitPlan.t),
      orderByList: orderByList?.call(BillSplitPlan.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillSplitPlanImpl extends BillSplitPlan {
  _BillSplitPlanImpl({
    int? id,
    required int restaurantId,
    required int roomId,
    int? activeRoomId,
    required String createdBy,
    required String payersJson,
    required String sharesJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         roomId: roomId,
         activeRoomId: activeRoomId,
         createdBy: createdBy,
         payersJson: payersJson,
         sharesJson: sharesJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [BillSplitPlan]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BillSplitPlan copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? roomId,
    Object? activeRoomId = _Undefined,
    String? createdBy,
    String? payersJson,
    String? sharesJson,
    DateTime? createdAt,
  }) {
    return BillSplitPlan(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      roomId: roomId ?? this.roomId,
      activeRoomId: activeRoomId is int? ? activeRoomId : this.activeRoomId,
      createdBy: createdBy ?? this.createdBy,
      payersJson: payersJson ?? this.payersJson,
      sharesJson: sharesJson ?? this.sharesJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BillSplitPlanUpdateTable extends _is.UpdateTable<BillSplitPlanTable> {
  BillSplitPlanUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<int, int> activeRoomId(int? value) => _is.ColumnValue(
    table.activeRoomId,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<String, String> payersJson(String value) => _is.ColumnValue(
    table.payersJson,
    value,
  );

  _is.ColumnValue<String, String> sharesJson(String value) => _is.ColumnValue(
    table.sharesJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class BillSplitPlanTable extends _is.Table<int?> {
  BillSplitPlanTable({super.tableRelation})
    : super(tableName: 'raysto_bill_split_plan') {
    updateTable = BillSplitPlanUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    activeRoomId = _is.ColumnInt(
      'activeRoomId',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    payersJson = _is.ColumnString(
      'payersJson',
      this,
    );
    sharesJson = _is.ColumnString(
      'sharesJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final BillSplitPlanUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt roomId;

  late final _is.ColumnInt activeRoomId;

  late final _is.ColumnString createdBy;

  late final _is.ColumnString payersJson;

  late final _is.ColumnString sharesJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    roomId,
    activeRoomId,
    createdBy,
    payersJson,
    sharesJson,
    createdAt,
  ];
}

class BillSplitPlanInclude extends _is.IncludeObject {
  BillSplitPlanInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => BillSplitPlan.t;
}

class BillSplitPlanIncludeList extends _is.IncludeList {
  BillSplitPlanIncludeList._({
    _is.WhereExpressionBuilder<BillSplitPlanTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BillSplitPlan.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => BillSplitPlan.t;
}

class BillSplitPlanRepository {
  const BillSplitPlanRepository._();

  /// Returns a list of [BillSplitPlan]s matching the given query parameters.
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
  Future<List<BillSplitPlan>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillSplitPlanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillSplitPlanTable>? orderBy,
    _is.OrderByListBuilder<BillSplitPlanTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BillSplitPlan>(
      where: where?.call(BillSplitPlan.t),
      orderBy: orderBy?.call(BillSplitPlan.t),
      orderByList: orderByList?.call(BillSplitPlan.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BillSplitPlan] matching the given query parameters.
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
  Future<BillSplitPlan?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillSplitPlanTable>? where,
    int? offset,
    _is.OrderByBuilder<BillSplitPlanTable>? orderBy,
    _is.OrderByListBuilder<BillSplitPlanTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BillSplitPlan>(
      where: where?.call(BillSplitPlan.t),
      orderBy: orderBy?.call(BillSplitPlan.t),
      orderByList: orderByList?.call(BillSplitPlan.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BillSplitPlan] by its [id] or null if no such row exists.
  Future<BillSplitPlan?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BillSplitPlan>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BillSplitPlan]s in the list and returns the inserted rows.
  ///
  /// The returned [BillSplitPlan]s will have their `id` fields set.
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
  Future<List<BillSplitPlan>> insert(
    _is.DatabaseSession session,
    List<BillSplitPlan> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BillSplitPlan>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BillSplitPlan] and returns the inserted row.
  ///
  /// The returned [BillSplitPlan] will have its `id` field set.
  Future<BillSplitPlan> insertRow(
    _is.DatabaseSession session,
    BillSplitPlan row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BillSplitPlan>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BillSplitPlan]s in the list and returns the resulting rows.
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
  /// The returned [BillSplitPlan]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillSplitPlan>> upsert(
    _is.DatabaseSession session,
    List<BillSplitPlan> rows, {
    required _is.ColumnSelections<BillSplitPlanTable> conflictColumns,
    _is.ColumnSelections<BillSplitPlanTable>? updateColumns,
    _is.WhereExpressionBuilder<BillSplitPlanTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BillSplitPlan>(
      rows,
      conflictColumns: conflictColumns(BillSplitPlan.t),
      updateColumns: updateColumns?.call(BillSplitPlan.t),
      updateWhere: updateWhere?.call(BillSplitPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BillSplitPlan] and returns the resulting row.
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
  /// The returned [BillSplitPlan] will have its `id` field set.
  Future<BillSplitPlan?> upsertRow(
    _is.DatabaseSession session,
    BillSplitPlan row, {
    required _is.ColumnSelections<BillSplitPlanTable> conflictColumns,
    _is.ColumnSelections<BillSplitPlanTable>? updateColumns,
    _is.WhereExpressionBuilder<BillSplitPlanTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BillSplitPlan>(
      row,
      conflictColumns: conflictColumns(BillSplitPlan.t),
      updateColumns: updateColumns?.call(BillSplitPlan.t),
      updateWhere: updateWhere?.call(BillSplitPlan.t),
      transaction: transaction,
    );
  }

  /// Updates all [BillSplitPlan]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillSplitPlan>> update(
    _is.DatabaseSession session,
    List<BillSplitPlan> rows, {
    _is.ColumnSelections<BillSplitPlanTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BillSplitPlan>(
      rows,
      columns: columns?.call(BillSplitPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BillSplitPlan]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BillSplitPlan> updateRow(
    _is.DatabaseSession session,
    BillSplitPlan row, {
    _is.ColumnSelections<BillSplitPlanTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BillSplitPlan>(
      row,
      columns: columns?.call(BillSplitPlan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BillSplitPlan] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BillSplitPlan?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BillSplitPlanUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BillSplitPlan>(
      id,
      columnValues: columnValues(BillSplitPlan.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BillSplitPlan]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillSplitPlan>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BillSplitPlanUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BillSplitPlanTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillSplitPlanTable>? orderBy,
    _is.OrderByListBuilder<BillSplitPlanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BillSplitPlan>(
      columnValues: columnValues(BillSplitPlan.t.updateTable),
      where: where(BillSplitPlan.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillSplitPlan.t),
      orderByList: orderByList?.call(BillSplitPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BillSplitPlan]s in the list and returns the deleted rows.
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
  Future<List<BillSplitPlan>> delete(
    _is.DatabaseSession session,
    List<BillSplitPlan> rows, {
    _is.OrderByBuilder<BillSplitPlanTable>? orderBy,
    _is.OrderByListBuilder<BillSplitPlanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BillSplitPlan>(
      rows,
      orderBy: orderBy?.call(BillSplitPlan.t),
      orderByList: orderByList?.call(BillSplitPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BillSplitPlan].
  Future<BillSplitPlan> deleteRow(
    _is.DatabaseSession session,
    BillSplitPlan row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BillSplitPlan>(
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
  Future<List<BillSplitPlan>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillSplitPlanTable> where,
    _is.OrderByBuilder<BillSplitPlanTable>? orderBy,
    _is.OrderByListBuilder<BillSplitPlanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BillSplitPlan>(
      where: where(BillSplitPlan.t),
      orderBy: orderBy?.call(BillSplitPlan.t),
      orderByList: orderByList?.call(BillSplitPlan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillSplitPlanTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BillSplitPlan>(
      where: where?.call(BillSplitPlan.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BillSplitPlan] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillSplitPlanTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BillSplitPlan>(
      where: where(BillSplitPlan.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
