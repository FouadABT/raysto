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

abstract class DiningVisit
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DiningVisit._({
    this.id,
    required this.restaurantId,
    required this.tableId,
    this.activeTableId,
    required this.guestCount,
    required this.status,
    required this.version,
    required this.openedBy,
    required this.createdAt,
    this.closedAt,
  });

  factory DiningVisit({
    int? id,
    required int restaurantId,
    required int tableId,
    int? activeTableId,
    required int guestCount,
    required String status,
    required int version,
    required String openedBy,
    required DateTime createdAt,
    DateTime? closedAt,
  }) = _DiningVisitImpl;

  factory DiningVisit.fromJson(Map<String, dynamic> jsonSerialization) {
    return DiningVisit(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      tableId: jsonSerialization['tableId'] as int,
      activeTableId: jsonSerialization['activeTableId'] as int?,
      guestCount: jsonSerialization['guestCount'] as int,
      status: jsonSerialization['status'] as String,
      version: jsonSerialization['version'] as int,
      openedBy: jsonSerialization['openedBy'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
    );
  }

  static final t = DiningVisitTable();

  static const db = DiningVisitRepository._();

  @override
  int? id;

  int restaurantId;

  int tableId;

  int? activeTableId;

  int guestCount;

  String status;

  int version;

  String openedBy;

  DateTime createdAt;

  DateTime? closedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DiningVisit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DiningVisit copyWith({
    int? id,
    int? restaurantId,
    int? tableId,
    int? activeTableId,
    int? guestCount,
    String? status,
    int? version,
    String? openedBy,
    DateTime? createdAt,
    DateTime? closedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DiningVisit',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'tableId': tableId,
      if (activeTableId != null) 'activeTableId': activeTableId,
      'guestCount': guestCount,
      'status': status,
      'version': version,
      'openedBy': openedBy,
      'createdAt': createdAt.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DiningVisitInclude include() {
    return DiningVisitInclude._();
  }

  static DiningVisitIncludeList includeList({
    _is.WhereExpressionBuilder<DiningVisitTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningVisitTable>? orderBy,
    _is.OrderByListBuilder<DiningVisitTable>? orderByList,
    DiningVisitInclude? include,
  }) {
    return DiningVisitIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningVisit.t),
      orderByList: orderByList?.call(DiningVisit.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DiningVisitImpl extends DiningVisit {
  _DiningVisitImpl({
    int? id,
    required int restaurantId,
    required int tableId,
    int? activeTableId,
    required int guestCount,
    required String status,
    required int version,
    required String openedBy,
    required DateTime createdAt,
    DateTime? closedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         tableId: tableId,
         activeTableId: activeTableId,
         guestCount: guestCount,
         status: status,
         version: version,
         openedBy: openedBy,
         createdAt: createdAt,
         closedAt: closedAt,
       );

  /// Returns a shallow copy of this [DiningVisit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DiningVisit copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? tableId,
    Object? activeTableId = _Undefined,
    int? guestCount,
    String? status,
    int? version,
    String? openedBy,
    DateTime? createdAt,
    Object? closedAt = _Undefined,
  }) {
    return DiningVisit(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
      activeTableId: activeTableId is int? ? activeTableId : this.activeTableId,
      guestCount: guestCount ?? this.guestCount,
      status: status ?? this.status,
      version: version ?? this.version,
      openedBy: openedBy ?? this.openedBy,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt is DateTime? ? closedAt : this.closedAt,
    );
  }
}

class DiningVisitUpdateTable extends _is.UpdateTable<DiningVisitTable> {
  DiningVisitUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> tableId(int value) => _is.ColumnValue(
    table.tableId,
    value,
  );

  _is.ColumnValue<int, int> activeTableId(int? value) => _is.ColumnValue(
    table.activeTableId,
    value,
  );

  _is.ColumnValue<int, int> guestCount(int value) => _is.ColumnValue(
    table.guestCount,
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

  _is.ColumnValue<String, String> openedBy(String value) => _is.ColumnValue(
    table.openedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> closedAt(DateTime? value) =>
      _is.ColumnValue(
        table.closedAt,
        value,
      );
}

class DiningVisitTable extends _is.Table<int?> {
  DiningVisitTable({super.tableRelation})
    : super(tableName: 'raysto_dining_visit') {
    updateTable = DiningVisitUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    tableId = _is.ColumnInt(
      'tableId',
      this,
    );
    activeTableId = _is.ColumnInt(
      'activeTableId',
      this,
    );
    guestCount = _is.ColumnInt(
      'guestCount',
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
    openedBy = _is.ColumnString(
      'openedBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    closedAt = _is.ColumnDateTime(
      'closedAt',
      this,
    );
  }

  late final DiningVisitUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt tableId;

  late final _is.ColumnInt activeTableId;

  late final _is.ColumnInt guestCount;

  late final _is.ColumnString status;

  late final _is.ColumnInt version;

  late final _is.ColumnString openedBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime closedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    tableId,
    activeTableId,
    guestCount,
    status,
    version,
    openedBy,
    createdAt,
    closedAt,
  ];
}

class DiningVisitInclude extends _is.IncludeObject {
  DiningVisitInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DiningVisit.t;
}

class DiningVisitIncludeList extends _is.IncludeList {
  DiningVisitIncludeList._({
    _is.WhereExpressionBuilder<DiningVisitTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DiningVisit.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DiningVisit.t;
}

class DiningVisitRepository {
  const DiningVisitRepository._();

  /// Returns a list of [DiningVisit]s matching the given query parameters.
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
  Future<List<DiningVisit>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningVisitTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningVisitTable>? orderBy,
    _is.OrderByListBuilder<DiningVisitTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DiningVisit>(
      where: where?.call(DiningVisit.t),
      orderBy: orderBy?.call(DiningVisit.t),
      orderByList: orderByList?.call(DiningVisit.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DiningVisit] matching the given query parameters.
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
  Future<DiningVisit?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningVisitTable>? where,
    int? offset,
    _is.OrderByBuilder<DiningVisitTable>? orderBy,
    _is.OrderByListBuilder<DiningVisitTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DiningVisit>(
      where: where?.call(DiningVisit.t),
      orderBy: orderBy?.call(DiningVisit.t),
      orderByList: orderByList?.call(DiningVisit.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DiningVisit] by its [id] or null if no such row exists.
  Future<DiningVisit?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DiningVisit>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DiningVisit]s in the list and returns the inserted rows.
  ///
  /// The returned [DiningVisit]s will have their `id` fields set.
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
  Future<List<DiningVisit>> insert(
    _is.DatabaseSession session,
    List<DiningVisit> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DiningVisit>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DiningVisit] and returns the inserted row.
  ///
  /// The returned [DiningVisit] will have its `id` field set.
  Future<DiningVisit> insertRow(
    _is.DatabaseSession session,
    DiningVisit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DiningVisit>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DiningVisit]s in the list and returns the resulting rows.
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
  /// The returned [DiningVisit]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningVisit>> upsert(
    _is.DatabaseSession session,
    List<DiningVisit> rows, {
    required _is.ColumnSelections<DiningVisitTable> conflictColumns,
    _is.ColumnSelections<DiningVisitTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningVisitTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DiningVisit>(
      rows,
      conflictColumns: conflictColumns(DiningVisit.t),
      updateColumns: updateColumns?.call(DiningVisit.t),
      updateWhere: updateWhere?.call(DiningVisit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DiningVisit] and returns the resulting row.
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
  /// The returned [DiningVisit] will have its `id` field set.
  Future<DiningVisit?> upsertRow(
    _is.DatabaseSession session,
    DiningVisit row, {
    required _is.ColumnSelections<DiningVisitTable> conflictColumns,
    _is.ColumnSelections<DiningVisitTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningVisitTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DiningVisit>(
      row,
      conflictColumns: conflictColumns(DiningVisit.t),
      updateColumns: updateColumns?.call(DiningVisit.t),
      updateWhere: updateWhere?.call(DiningVisit.t),
      transaction: transaction,
    );
  }

  /// Updates all [DiningVisit]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningVisit>> update(
    _is.DatabaseSession session,
    List<DiningVisit> rows, {
    _is.ColumnSelections<DiningVisitTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DiningVisit>(
      rows,
      columns: columns?.call(DiningVisit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DiningVisit]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DiningVisit> updateRow(
    _is.DatabaseSession session,
    DiningVisit row, {
    _is.ColumnSelections<DiningVisitTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DiningVisit>(
      row,
      columns: columns?.call(DiningVisit.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DiningVisit] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DiningVisit?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DiningVisitUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DiningVisit>(
      id,
      columnValues: columnValues(DiningVisit.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DiningVisit]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningVisit>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DiningVisitUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DiningVisitTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningVisitTable>? orderBy,
    _is.OrderByListBuilder<DiningVisitTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DiningVisit>(
      columnValues: columnValues(DiningVisit.t.updateTable),
      where: where(DiningVisit.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningVisit.t),
      orderByList: orderByList?.call(DiningVisit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DiningVisit]s in the list and returns the deleted rows.
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
  Future<List<DiningVisit>> delete(
    _is.DatabaseSession session,
    List<DiningVisit> rows, {
    _is.OrderByBuilder<DiningVisitTable>? orderBy,
    _is.OrderByListBuilder<DiningVisitTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DiningVisit>(
      rows,
      orderBy: orderBy?.call(DiningVisit.t),
      orderByList: orderByList?.call(DiningVisit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DiningVisit].
  Future<DiningVisit> deleteRow(
    _is.DatabaseSession session,
    DiningVisit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DiningVisit>(
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
  Future<List<DiningVisit>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningVisitTable> where,
    _is.OrderByBuilder<DiningVisitTable>? orderBy,
    _is.OrderByListBuilder<DiningVisitTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DiningVisit>(
      where: where(DiningVisit.t),
      orderBy: orderBy?.call(DiningVisit.t),
      orderByList: orderByList?.call(DiningVisit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningVisitTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DiningVisit>(
      where: where?.call(DiningVisit.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DiningVisit] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningVisitTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DiningVisit>(
      where: where(DiningVisit.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
