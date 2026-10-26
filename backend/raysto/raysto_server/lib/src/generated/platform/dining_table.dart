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

abstract class DiningTable
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DiningTable._({
    this.id,
    required this.restaurantId,
    required this.label,
    required this.zone,
    required this.capacity,
    required this.active,
    required this.needsReset,
    required this.qrKey,
    required this.geometryJson,
    this.assignedWaiterId,
    required this.version,
  });

  factory DiningTable({
    int? id,
    required int restaurantId,
    required String label,
    required String zone,
    required int capacity,
    required bool active,
    required bool needsReset,
    required String qrKey,
    required String geometryJson,
    String? assignedWaiterId,
    required int version,
  }) = _DiningTableImpl;

  factory DiningTable.fromJson(Map<String, dynamic> jsonSerialization) {
    return DiningTable(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      label: jsonSerialization['label'] as String,
      zone: jsonSerialization['zone'] as String,
      capacity: jsonSerialization['capacity'] as int,
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      needsReset: _is.BoolJsonExtension.fromJson(
        jsonSerialization['needsReset'],
      ),
      qrKey: jsonSerialization['qrKey'] as String,
      geometryJson: jsonSerialization['geometryJson'] as String,
      assignedWaiterId: jsonSerialization['assignedWaiterId'] as String?,
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = DiningTableTable();

  static const db = DiningTableRepository._();

  @override
  int? id;

  int restaurantId;

  String label;

  String zone;

  int capacity;

  bool active;

  bool needsReset;

  String qrKey;

  String geometryJson;

  String? assignedWaiterId;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DiningTable]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DiningTable copyWith({
    int? id,
    int? restaurantId,
    String? label,
    String? zone,
    int? capacity,
    bool? active,
    bool? needsReset,
    String? qrKey,
    String? geometryJson,
    String? assignedWaiterId,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DiningTable',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'label': label,
      'zone': zone,
      'capacity': capacity,
      'active': active,
      'needsReset': needsReset,
      'qrKey': qrKey,
      'geometryJson': geometryJson,
      if (assignedWaiterId != null) 'assignedWaiterId': assignedWaiterId,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DiningTableInclude include() {
    return DiningTableInclude._();
  }

  static DiningTableIncludeList includeList({
    _is.WhereExpressionBuilder<DiningTableTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningTableTable>? orderBy,
    _is.OrderByListBuilder<DiningTableTable>? orderByList,
    DiningTableInclude? include,
  }) {
    return DiningTableIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningTable.t),
      orderByList: orderByList?.call(DiningTable.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DiningTableImpl extends DiningTable {
  _DiningTableImpl({
    int? id,
    required int restaurantId,
    required String label,
    required String zone,
    required int capacity,
    required bool active,
    required bool needsReset,
    required String qrKey,
    required String geometryJson,
    String? assignedWaiterId,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         label: label,
         zone: zone,
         capacity: capacity,
         active: active,
         needsReset: needsReset,
         qrKey: qrKey,
         geometryJson: geometryJson,
         assignedWaiterId: assignedWaiterId,
         version: version,
       );

  /// Returns a shallow copy of this [DiningTable]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DiningTable copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? label,
    String? zone,
    int? capacity,
    bool? active,
    bool? needsReset,
    String? qrKey,
    String? geometryJson,
    Object? assignedWaiterId = _Undefined,
    int? version,
  }) {
    return DiningTable(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      label: label ?? this.label,
      zone: zone ?? this.zone,
      capacity: capacity ?? this.capacity,
      active: active ?? this.active,
      needsReset: needsReset ?? this.needsReset,
      qrKey: qrKey ?? this.qrKey,
      geometryJson: geometryJson ?? this.geometryJson,
      assignedWaiterId: assignedWaiterId is String?
          ? assignedWaiterId
          : this.assignedWaiterId,
      version: version ?? this.version,
    );
  }
}

class DiningTableUpdateTable extends _is.UpdateTable<DiningTableTable> {
  DiningTableUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> label(String value) => _is.ColumnValue(
    table.label,
    value,
  );

  _is.ColumnValue<String, String> zone(String value) => _is.ColumnValue(
    table.zone,
    value,
  );

  _is.ColumnValue<int, int> capacity(int value) => _is.ColumnValue(
    table.capacity,
    value,
  );

  _is.ColumnValue<bool, bool> active(bool value) => _is.ColumnValue(
    table.active,
    value,
  );

  _is.ColumnValue<bool, bool> needsReset(bool value) => _is.ColumnValue(
    table.needsReset,
    value,
  );

  _is.ColumnValue<String, String> qrKey(String value) => _is.ColumnValue(
    table.qrKey,
    value,
  );

  _is.ColumnValue<String, String> geometryJson(String value) => _is.ColumnValue(
    table.geometryJson,
    value,
  );

  _is.ColumnValue<String, String> assignedWaiterId(String? value) =>
      _is.ColumnValue(
        table.assignedWaiterId,
        value,
      );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class DiningTableTable extends _is.Table<int?> {
  DiningTableTable({super.tableRelation})
    : super(tableName: 'raysto_dining_table') {
    updateTable = DiningTableUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    label = _is.ColumnString(
      'label',
      this,
    );
    zone = _is.ColumnString(
      'zone',
      this,
    );
    capacity = _is.ColumnInt(
      'capacity',
      this,
    );
    active = _is.ColumnBool(
      'active',
      this,
    );
    needsReset = _is.ColumnBool(
      'needsReset',
      this,
    );
    qrKey = _is.ColumnString(
      'qrKey',
      this,
    );
    geometryJson = _is.ColumnString(
      'geometryJson',
      this,
    );
    assignedWaiterId = _is.ColumnString(
      'assignedWaiterId',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final DiningTableUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString label;

  late final _is.ColumnString zone;

  late final _is.ColumnInt capacity;

  late final _is.ColumnBool active;

  late final _is.ColumnBool needsReset;

  late final _is.ColumnString qrKey;

  late final _is.ColumnString geometryJson;

  late final _is.ColumnString assignedWaiterId;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    label,
    zone,
    capacity,
    active,
    needsReset,
    qrKey,
    geometryJson,
    assignedWaiterId,
    version,
  ];
}

class DiningTableInclude extends _is.IncludeObject {
  DiningTableInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DiningTable.t;
}

class DiningTableIncludeList extends _is.IncludeList {
  DiningTableIncludeList._({
    _is.WhereExpressionBuilder<DiningTableTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DiningTable.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DiningTable.t;
}

class DiningTableRepository {
  const DiningTableRepository._();

  /// Returns a list of [DiningTable]s matching the given query parameters.
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
  Future<List<DiningTable>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningTableTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningTableTable>? orderBy,
    _is.OrderByListBuilder<DiningTableTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DiningTable>(
      where: where?.call(DiningTable.t),
      orderBy: orderBy?.call(DiningTable.t),
      orderByList: orderByList?.call(DiningTable.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DiningTable] matching the given query parameters.
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
  Future<DiningTable?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningTableTable>? where,
    int? offset,
    _is.OrderByBuilder<DiningTableTable>? orderBy,
    _is.OrderByListBuilder<DiningTableTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DiningTable>(
      where: where?.call(DiningTable.t),
      orderBy: orderBy?.call(DiningTable.t),
      orderByList: orderByList?.call(DiningTable.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DiningTable] by its [id] or null if no such row exists.
  Future<DiningTable?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DiningTable>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DiningTable]s in the list and returns the inserted rows.
  ///
  /// The returned [DiningTable]s will have their `id` fields set.
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
  Future<List<DiningTable>> insert(
    _is.DatabaseSession session,
    List<DiningTable> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DiningTable>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DiningTable] and returns the inserted row.
  ///
  /// The returned [DiningTable] will have its `id` field set.
  Future<DiningTable> insertRow(
    _is.DatabaseSession session,
    DiningTable row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DiningTable>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DiningTable]s in the list and returns the resulting rows.
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
  /// The returned [DiningTable]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningTable>> upsert(
    _is.DatabaseSession session,
    List<DiningTable> rows, {
    required _is.ColumnSelections<DiningTableTable> conflictColumns,
    _is.ColumnSelections<DiningTableTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningTableTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DiningTable>(
      rows,
      conflictColumns: conflictColumns(DiningTable.t),
      updateColumns: updateColumns?.call(DiningTable.t),
      updateWhere: updateWhere?.call(DiningTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DiningTable] and returns the resulting row.
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
  /// The returned [DiningTable] will have its `id` field set.
  Future<DiningTable?> upsertRow(
    _is.DatabaseSession session,
    DiningTable row, {
    required _is.ColumnSelections<DiningTableTable> conflictColumns,
    _is.ColumnSelections<DiningTableTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningTableTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DiningTable>(
      row,
      conflictColumns: conflictColumns(DiningTable.t),
      updateColumns: updateColumns?.call(DiningTable.t),
      updateWhere: updateWhere?.call(DiningTable.t),
      transaction: transaction,
    );
  }

  /// Updates all [DiningTable]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningTable>> update(
    _is.DatabaseSession session,
    List<DiningTable> rows, {
    _is.ColumnSelections<DiningTableTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DiningTable>(
      rows,
      columns: columns?.call(DiningTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DiningTable]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DiningTable> updateRow(
    _is.DatabaseSession session,
    DiningTable row, {
    _is.ColumnSelections<DiningTableTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DiningTable>(
      row,
      columns: columns?.call(DiningTable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DiningTable] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DiningTable?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DiningTableUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DiningTable>(
      id,
      columnValues: columnValues(DiningTable.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DiningTable]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningTable>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DiningTableUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DiningTableTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningTableTable>? orderBy,
    _is.OrderByListBuilder<DiningTableTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DiningTable>(
      columnValues: columnValues(DiningTable.t.updateTable),
      where: where(DiningTable.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningTable.t),
      orderByList: orderByList?.call(DiningTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DiningTable]s in the list and returns the deleted rows.
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
  Future<List<DiningTable>> delete(
    _is.DatabaseSession session,
    List<DiningTable> rows, {
    _is.OrderByBuilder<DiningTableTable>? orderBy,
    _is.OrderByListBuilder<DiningTableTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DiningTable>(
      rows,
      orderBy: orderBy?.call(DiningTable.t),
      orderByList: orderByList?.call(DiningTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DiningTable].
  Future<DiningTable> deleteRow(
    _is.DatabaseSession session,
    DiningTable row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DiningTable>(
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
  Future<List<DiningTable>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningTableTable> where,
    _is.OrderByBuilder<DiningTableTable>? orderBy,
    _is.OrderByListBuilder<DiningTableTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DiningTable>(
      where: where(DiningTable.t),
      orderBy: orderBy?.call(DiningTable.t),
      orderByList: orderByList?.call(DiningTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningTableTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DiningTable>(
      where: where?.call(DiningTable.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DiningTable] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningTableTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DiningTable>(
      where: where(DiningTable.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
