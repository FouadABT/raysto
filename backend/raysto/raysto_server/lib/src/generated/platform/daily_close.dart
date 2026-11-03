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

abstract class DailyClose
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DailyClose._({
    this.id,
    required this.restaurantId,
    required this.day,
    required this.source,
    required this.summaryJson,
    required this.gapsJson,
    required this.state,
    this.signedBy,
    this.taskId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyClose({
    int? id,
    required int restaurantId,
    required String day,
    required String source,
    required String summaryJson,
    required String gapsJson,
    required String state,
    String? signedBy,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DailyCloseImpl;

  factory DailyClose.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyClose(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      day: jsonSerialization['day'] as String,
      source: jsonSerialization['source'] as String,
      summaryJson: jsonSerialization['summaryJson'] as String,
      gapsJson: jsonSerialization['gapsJson'] as String,
      state: jsonSerialization['state'] as String,
      signedBy: jsonSerialization['signedBy'] as String?,
      taskId: jsonSerialization['taskId'] as int?,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = DailyCloseTable();

  static const db = DailyCloseRepository._();

  @override
  int? id;

  int restaurantId;

  String day;

  String source;

  String summaryJson;

  String gapsJson;

  String state;

  String? signedBy;

  int? taskId;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DailyClose]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DailyClose copyWith({
    int? id,
    int? restaurantId,
    String? day,
    String? source,
    String? summaryJson,
    String? gapsJson,
    String? state,
    String? signedBy,
    int? taskId,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyClose',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'day': day,
      'source': source,
      'summaryJson': summaryJson,
      'gapsJson': gapsJson,
      'state': state,
      if (signedBy != null) 'signedBy': signedBy,
      if (taskId != null) 'taskId': taskId,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DailyCloseInclude include() {
    return DailyCloseInclude._();
  }

  static DailyCloseIncludeList includeList({
    _is.WhereExpressionBuilder<DailyCloseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyCloseTable>? orderBy,
    _is.OrderByListBuilder<DailyCloseTable>? orderByList,
    DailyCloseInclude? include,
  }) {
    return DailyCloseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyClose.t),
      orderByList: orderByList?.call(DailyClose.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyCloseImpl extends DailyClose {
  _DailyCloseImpl({
    int? id,
    required int restaurantId,
    required String day,
    required String source,
    required String summaryJson,
    required String gapsJson,
    required String state,
    String? signedBy,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         day: day,
         source: source,
         summaryJson: summaryJson,
         gapsJson: gapsJson,
         state: state,
         signedBy: signedBy,
         taskId: taskId,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [DailyClose]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DailyClose copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? day,
    String? source,
    String? summaryJson,
    String? gapsJson,
    String? state,
    Object? signedBy = _Undefined,
    Object? taskId = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyClose(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      day: day ?? this.day,
      source: source ?? this.source,
      summaryJson: summaryJson ?? this.summaryJson,
      gapsJson: gapsJson ?? this.gapsJson,
      state: state ?? this.state,
      signedBy: signedBy is String? ? signedBy : this.signedBy,
      taskId: taskId is int? ? taskId : this.taskId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DailyCloseUpdateTable extends _is.UpdateTable<DailyCloseTable> {
  DailyCloseUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> day(String value) => _is.ColumnValue(
    table.day,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<String, String> summaryJson(String value) => _is.ColumnValue(
    table.summaryJson,
    value,
  );

  _is.ColumnValue<String, String> gapsJson(String value) => _is.ColumnValue(
    table.gapsJson,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> signedBy(String? value) => _is.ColumnValue(
    table.signedBy,
    value,
  );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
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

class DailyCloseTable extends _is.Table<int?> {
  DailyCloseTable({super.tableRelation})
    : super(tableName: 'raysto_daily_close') {
    updateTable = DailyCloseUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    day = _is.ColumnString(
      'day',
      this,
    );
    source = _is.ColumnString(
      'source',
      this,
    );
    summaryJson = _is.ColumnString(
      'summaryJson',
      this,
    );
    gapsJson = _is.ColumnString(
      'gapsJson',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    signedBy = _is.ColumnString(
      'signedBy',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
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

  late final DailyCloseUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString day;

  late final _is.ColumnString source;

  late final _is.ColumnString summaryJson;

  late final _is.ColumnString gapsJson;

  late final _is.ColumnString state;

  late final _is.ColumnString signedBy;

  late final _is.ColumnInt taskId;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    day,
    source,
    summaryJson,
    gapsJson,
    state,
    signedBy,
    taskId,
    version,
    createdAt,
    updatedAt,
  ];
}

class DailyCloseInclude extends _is.IncludeObject {
  DailyCloseInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DailyClose.t;
}

class DailyCloseIncludeList extends _is.IncludeList {
  DailyCloseIncludeList._({
    _is.WhereExpressionBuilder<DailyCloseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyClose.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DailyClose.t;
}

class DailyCloseRepository {
  const DailyCloseRepository._();

  /// Returns a list of [DailyClose]s matching the given query parameters.
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
  Future<List<DailyClose>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyCloseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyCloseTable>? orderBy,
    _is.OrderByListBuilder<DailyCloseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DailyClose>(
      where: where?.call(DailyClose.t),
      orderBy: orderBy?.call(DailyClose.t),
      orderByList: orderByList?.call(DailyClose.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DailyClose] matching the given query parameters.
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
  Future<DailyClose?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyCloseTable>? where,
    int? offset,
    _is.OrderByBuilder<DailyCloseTable>? orderBy,
    _is.OrderByListBuilder<DailyCloseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DailyClose>(
      where: where?.call(DailyClose.t),
      orderBy: orderBy?.call(DailyClose.t),
      orderByList: orderByList?.call(DailyClose.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DailyClose] by its [id] or null if no such row exists.
  Future<DailyClose?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DailyClose>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DailyClose]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyClose]s will have their `id` fields set.
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
  Future<List<DailyClose>> insert(
    _is.DatabaseSession session,
    List<DailyClose> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DailyClose>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DailyClose] and returns the inserted row.
  ///
  /// The returned [DailyClose] will have its `id` field set.
  Future<DailyClose> insertRow(
    _is.DatabaseSession session,
    DailyClose row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyClose>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DailyClose]s in the list and returns the resulting rows.
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
  /// The returned [DailyClose]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyClose>> upsert(
    _is.DatabaseSession session,
    List<DailyClose> rows, {
    required _is.ColumnSelections<DailyCloseTable> conflictColumns,
    _is.ColumnSelections<DailyCloseTable>? updateColumns,
    _is.WhereExpressionBuilder<DailyCloseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DailyClose>(
      rows,
      conflictColumns: conflictColumns(DailyClose.t),
      updateColumns: updateColumns?.call(DailyClose.t),
      updateWhere: updateWhere?.call(DailyClose.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DailyClose] and returns the resulting row.
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
  /// The returned [DailyClose] will have its `id` field set.
  Future<DailyClose?> upsertRow(
    _is.DatabaseSession session,
    DailyClose row, {
    required _is.ColumnSelections<DailyCloseTable> conflictColumns,
    _is.ColumnSelections<DailyCloseTable>? updateColumns,
    _is.WhereExpressionBuilder<DailyCloseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DailyClose>(
      row,
      conflictColumns: conflictColumns(DailyClose.t),
      updateColumns: updateColumns?.call(DailyClose.t),
      updateWhere: updateWhere?.call(DailyClose.t),
      transaction: transaction,
    );
  }

  /// Updates all [DailyClose]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyClose>> update(
    _is.DatabaseSession session,
    List<DailyClose> rows, {
    _is.ColumnSelections<DailyCloseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DailyClose>(
      rows,
      columns: columns?.call(DailyClose.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DailyClose]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyClose> updateRow(
    _is.DatabaseSession session,
    DailyClose row, {
    _is.ColumnSelections<DailyCloseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyClose>(
      row,
      columns: columns?.call(DailyClose.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyClose] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyClose?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DailyCloseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyClose>(
      id,
      columnValues: columnValues(DailyClose.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyClose]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyClose>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DailyCloseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DailyCloseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyCloseTable>? orderBy,
    _is.OrderByListBuilder<DailyCloseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DailyClose>(
      columnValues: columnValues(DailyClose.t.updateTable),
      where: where(DailyClose.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyClose.t),
      orderByList: orderByList?.call(DailyClose.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DailyClose]s in the list and returns the deleted rows.
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
  Future<List<DailyClose>> delete(
    _is.DatabaseSession session,
    List<DailyClose> rows, {
    _is.OrderByBuilder<DailyCloseTable>? orderBy,
    _is.OrderByListBuilder<DailyCloseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DailyClose>(
      rows,
      orderBy: orderBy?.call(DailyClose.t),
      orderByList: orderByList?.call(DailyClose.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DailyClose].
  Future<DailyClose> deleteRow(
    _is.DatabaseSession session,
    DailyClose row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyClose>(
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
  Future<List<DailyClose>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DailyCloseTable> where,
    _is.OrderByBuilder<DailyCloseTable>? orderBy,
    _is.OrderByListBuilder<DailyCloseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DailyClose>(
      where: where(DailyClose.t),
      orderBy: orderBy?.call(DailyClose.t),
      orderByList: orderByList?.call(DailyClose.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyCloseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DailyClose>(
      where: where?.call(DailyClose.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DailyClose] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DailyCloseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DailyClose>(
      where: where(DailyClose.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
