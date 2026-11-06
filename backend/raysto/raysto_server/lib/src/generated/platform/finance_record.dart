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

abstract class FinanceRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FinanceRecord._({
    this.id,
    required this.restaurantId,
    required this.kind,
    required this.recordKey,
    required this.payloadJson,
    required this.createdBy,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinanceRecord({
    int? id,
    required int restaurantId,
    required String kind,
    required String recordKey,
    required String payloadJson,
    required String createdBy,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FinanceRecordImpl;

  factory FinanceRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return FinanceRecord(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      kind: jsonSerialization['kind'] as String,
      recordKey: jsonSerialization['recordKey'] as String,
      payloadJson: jsonSerialization['payloadJson'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = FinanceRecordTable();

  static const db = FinanceRecordRepository._();

  @override
  int? id;

  int restaurantId;

  String kind;

  String recordKey;

  String payloadJson;

  String createdBy;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FinanceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FinanceRecord copyWith({
    int? id,
    int? restaurantId,
    String? kind,
    String? recordKey,
    String? payloadJson,
    String? createdBy,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FinanceRecord',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'kind': kind,
      'recordKey': recordKey,
      'payloadJson': payloadJson,
      'createdBy': createdBy,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static FinanceRecordInclude include() {
    return FinanceRecordInclude._();
  }

  static FinanceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<FinanceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FinanceRecordTable>? orderBy,
    _is.OrderByListBuilder<FinanceRecordTable>? orderByList,
    FinanceRecordInclude? include,
  }) {
    return FinanceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FinanceRecord.t),
      orderByList: orderByList?.call(FinanceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FinanceRecordImpl extends FinanceRecord {
  _FinanceRecordImpl({
    int? id,
    required int restaurantId,
    required String kind,
    required String recordKey,
    required String payloadJson,
    required String createdBy,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         kind: kind,
         recordKey: recordKey,
         payloadJson: payloadJson,
         createdBy: createdBy,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FinanceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FinanceRecord copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? kind,
    String? recordKey,
    String? payloadJson,
    String? createdBy,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinanceRecord(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      kind: kind ?? this.kind,
      recordKey: recordKey ?? this.recordKey,
      payloadJson: payloadJson ?? this.payloadJson,
      createdBy: createdBy ?? this.createdBy,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FinanceRecordUpdateTable extends _is.UpdateTable<FinanceRecordTable> {
  FinanceRecordUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> recordKey(String value) => _is.ColumnValue(
    table.recordKey,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class FinanceRecordTable extends _is.Table<int?> {
  FinanceRecordTable({super.tableRelation})
    : super(tableName: 'raysto_finance_record') {
    updateTable = FinanceRecordUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    recordKey = _is.ColumnString(
      'recordKey',
      this,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final FinanceRecordUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString kind;

  late final _is.ColumnString recordKey;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnString createdBy;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    kind,
    recordKey,
    payloadJson,
    createdBy,
    version,
    createdAt,
    updatedAt,
  ];
}

class FinanceRecordInclude extends _is.IncludeObject {
  FinanceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FinanceRecord.t;
}

class FinanceRecordIncludeList extends _is.IncludeList {
  FinanceRecordIncludeList._({
    _is.WhereExpressionBuilder<FinanceRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FinanceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FinanceRecord.t;
}

class FinanceRecordRepository {
  const FinanceRecordRepository._();

  /// Returns a list of [FinanceRecord]s matching the given query parameters.
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
  Future<List<FinanceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FinanceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FinanceRecordTable>? orderBy,
    _is.OrderByListBuilder<FinanceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FinanceRecord>(
      where: where?.call(FinanceRecord.t),
      orderBy: orderBy?.call(FinanceRecord.t),
      orderByList: orderByList?.call(FinanceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FinanceRecord] matching the given query parameters.
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
  Future<FinanceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FinanceRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<FinanceRecordTable>? orderBy,
    _is.OrderByListBuilder<FinanceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FinanceRecord>(
      where: where?.call(FinanceRecord.t),
      orderBy: orderBy?.call(FinanceRecord.t),
      orderByList: orderByList?.call(FinanceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FinanceRecord] by its [id] or null if no such row exists.
  Future<FinanceRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FinanceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FinanceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [FinanceRecord]s will have their `id` fields set.
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
  Future<List<FinanceRecord>> insert(
    _is.DatabaseSession session,
    List<FinanceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FinanceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FinanceRecord] and returns the inserted row.
  ///
  /// The returned [FinanceRecord] will have its `id` field set.
  Future<FinanceRecord> insertRow(
    _is.DatabaseSession session,
    FinanceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FinanceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FinanceRecord]s in the list and returns the resulting rows.
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
  /// The returned [FinanceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FinanceRecord>> upsert(
    _is.DatabaseSession session,
    List<FinanceRecord> rows, {
    required _is.ColumnSelections<FinanceRecordTable> conflictColumns,
    _is.ColumnSelections<FinanceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<FinanceRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FinanceRecord>(
      rows,
      conflictColumns: conflictColumns(FinanceRecord.t),
      updateColumns: updateColumns?.call(FinanceRecord.t),
      updateWhere: updateWhere?.call(FinanceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FinanceRecord] and returns the resulting row.
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
  /// The returned [FinanceRecord] will have its `id` field set.
  Future<FinanceRecord?> upsertRow(
    _is.DatabaseSession session,
    FinanceRecord row, {
    required _is.ColumnSelections<FinanceRecordTable> conflictColumns,
    _is.ColumnSelections<FinanceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<FinanceRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FinanceRecord>(
      row,
      conflictColumns: conflictColumns(FinanceRecord.t),
      updateColumns: updateColumns?.call(FinanceRecord.t),
      updateWhere: updateWhere?.call(FinanceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [FinanceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FinanceRecord>> update(
    _is.DatabaseSession session,
    List<FinanceRecord> rows, {
    _is.ColumnSelections<FinanceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FinanceRecord>(
      rows,
      columns: columns?.call(FinanceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FinanceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FinanceRecord> updateRow(
    _is.DatabaseSession session,
    FinanceRecord row, {
    _is.ColumnSelections<FinanceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FinanceRecord>(
      row,
      columns: columns?.call(FinanceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FinanceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FinanceRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FinanceRecordUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FinanceRecord>(
      id,
      columnValues: columnValues(FinanceRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FinanceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FinanceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FinanceRecordUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FinanceRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FinanceRecordTable>? orderBy,
    _is.OrderByListBuilder<FinanceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FinanceRecord>(
      columnValues: columnValues(FinanceRecord.t.updateTable),
      where: where(FinanceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FinanceRecord.t),
      orderByList: orderByList?.call(FinanceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FinanceRecord]s in the list and returns the deleted rows.
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
  Future<List<FinanceRecord>> delete(
    _is.DatabaseSession session,
    List<FinanceRecord> rows, {
    _is.OrderByBuilder<FinanceRecordTable>? orderBy,
    _is.OrderByListBuilder<FinanceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FinanceRecord>(
      rows,
      orderBy: orderBy?.call(FinanceRecord.t),
      orderByList: orderByList?.call(FinanceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FinanceRecord].
  Future<FinanceRecord> deleteRow(
    _is.DatabaseSession session,
    FinanceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FinanceRecord>(
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
  Future<List<FinanceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FinanceRecordTable> where,
    _is.OrderByBuilder<FinanceRecordTable>? orderBy,
    _is.OrderByListBuilder<FinanceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FinanceRecord>(
      where: where(FinanceRecord.t),
      orderBy: orderBy?.call(FinanceRecord.t),
      orderByList: orderByList?.call(FinanceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FinanceRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FinanceRecord>(
      where: where?.call(FinanceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FinanceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FinanceRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FinanceRecord>(
      where: where(FinanceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
