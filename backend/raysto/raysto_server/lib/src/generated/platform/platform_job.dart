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

abstract class PlatformJob
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PlatformJob._({
    this.id,
    this.restaurantId,
    this.userId,
    required this.kind,
    required this.dedupeKey,
    required this.payloadJson,
    required this.state,
    required this.attempts,
    required this.availableAt,
    this.leaseToken,
    this.leaseUntil,
    this.lastError,
    required this.createdAt,
  });

  factory PlatformJob({
    int? id,
    int? restaurantId,
    String? userId,
    required String kind,
    required String dedupeKey,
    required String payloadJson,
    required String state,
    required int attempts,
    required DateTime availableAt,
    String? leaseToken,
    DateTime? leaseUntil,
    String? lastError,
    required DateTime createdAt,
  }) = _PlatformJobImpl;

  factory PlatformJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlatformJob(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int?,
      userId: jsonSerialization['userId'] as String?,
      kind: jsonSerialization['kind'] as String,
      dedupeKey: jsonSerialization['dedupeKey'] as String,
      payloadJson: jsonSerialization['payloadJson'] as String,
      state: jsonSerialization['state'] as String,
      attempts: jsonSerialization['attempts'] as int,
      availableAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['availableAt'],
      ),
      leaseToken: jsonSerialization['leaseToken'] as String?,
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      lastError: jsonSerialization['lastError'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PlatformJobTable();

  static const db = PlatformJobRepository._();

  @override
  int? id;

  int? restaurantId;

  String? userId;

  String kind;

  String dedupeKey;

  String payloadJson;

  String state;

  int attempts;

  DateTime availableAt;

  String? leaseToken;

  DateTime? leaseUntil;

  String? lastError;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PlatformJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlatformJob copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? kind,
    String? dedupeKey,
    String? payloadJson,
    String? state,
    int? attempts,
    DateTime? availableAt,
    String? leaseToken,
    DateTime? leaseUntil,
    String? lastError,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlatformJob',
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (userId != null) 'userId': userId,
      'kind': kind,
      'dedupeKey': dedupeKey,
      'payloadJson': payloadJson,
      'state': state,
      'attempts': attempts,
      'availableAt': availableAt.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken,
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PlatformJobInclude include() {
    return PlatformJobInclude._();
  }

  static PlatformJobIncludeList includeList({
    _is.WhereExpressionBuilder<PlatformJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlatformJobTable>? orderBy,
    _is.OrderByListBuilder<PlatformJobTable>? orderByList,
    PlatformJobInclude? include,
  }) {
    return PlatformJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlatformJob.t),
      orderByList: orderByList?.call(PlatformJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlatformJobImpl extends PlatformJob {
  _PlatformJobImpl({
    int? id,
    int? restaurantId,
    String? userId,
    required String kind,
    required String dedupeKey,
    required String payloadJson,
    required String state,
    required int attempts,
    required DateTime availableAt,
    String? leaseToken,
    DateTime? leaseUntil,
    String? lastError,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         kind: kind,
         dedupeKey: dedupeKey,
         payloadJson: payloadJson,
         state: state,
         attempts: attempts,
         availableAt: availableAt,
         leaseToken: leaseToken,
         leaseUntil: leaseUntil,
         lastError: lastError,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PlatformJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlatformJob copyWith({
    Object? id = _Undefined,
    Object? restaurantId = _Undefined,
    Object? userId = _Undefined,
    String? kind,
    String? dedupeKey,
    String? payloadJson,
    String? state,
    int? attempts,
    DateTime? availableAt,
    Object? leaseToken = _Undefined,
    Object? leaseUntil = _Undefined,
    Object? lastError = _Undefined,
    DateTime? createdAt,
  }) {
    return PlatformJob(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId is int? ? restaurantId : this.restaurantId,
      userId: userId is String? ? userId : this.userId,
      kind: kind ?? this.kind,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      payloadJson: payloadJson ?? this.payloadJson,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      availableAt: availableAt ?? this.availableAt,
      leaseToken: leaseToken is String? ? leaseToken : this.leaseToken,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      lastError: lastError is String? ? lastError : this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PlatformJobUpdateTable extends _is.UpdateTable<PlatformJobTable> {
  PlatformJobUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int? value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> dedupeKey(String value) => _is.ColumnValue(
    table.dedupeKey,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> availableAt(DateTime value) =>
      _is.ColumnValue(
        table.availableAt,
        value,
      );

  _is.ColumnValue<String, String> leaseToken(String? value) => _is.ColumnValue(
    table.leaseToken,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class PlatformJobTable extends _is.Table<int?> {
  PlatformJobTable({super.tableRelation})
    : super(tableName: 'raysto_platform_job') {
    updateTable = PlatformJobUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    dedupeKey = _is.ColumnString(
      'dedupeKey',
      this,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
    );
    availableAt = _is.ColumnDateTime(
      'availableAt',
      this,
    );
    leaseToken = _is.ColumnString(
      'leaseToken',
      this,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PlatformJobUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString kind;

  late final _is.ColumnString dedupeKey;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnString state;

  late final _is.ColumnInt attempts;

  late final _is.ColumnDateTime availableAt;

  late final _is.ColumnString leaseToken;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnString lastError;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    kind,
    dedupeKey,
    payloadJson,
    state,
    attempts,
    availableAt,
    leaseToken,
    leaseUntil,
    lastError,
    createdAt,
  ];
}

class PlatformJobInclude extends _is.IncludeObject {
  PlatformJobInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PlatformJob.t;
}

class PlatformJobIncludeList extends _is.IncludeList {
  PlatformJobIncludeList._({
    _is.WhereExpressionBuilder<PlatformJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlatformJob.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PlatformJob.t;
}

class PlatformJobRepository {
  const PlatformJobRepository._();

  /// Returns a list of [PlatformJob]s matching the given query parameters.
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
  Future<List<PlatformJob>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlatformJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlatformJobTable>? orderBy,
    _is.OrderByListBuilder<PlatformJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PlatformJob>(
      where: where?.call(PlatformJob.t),
      orderBy: orderBy?.call(PlatformJob.t),
      orderByList: orderByList?.call(PlatformJob.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PlatformJob] matching the given query parameters.
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
  Future<PlatformJob?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlatformJobTable>? where,
    int? offset,
    _is.OrderByBuilder<PlatformJobTable>? orderBy,
    _is.OrderByListBuilder<PlatformJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PlatformJob>(
      where: where?.call(PlatformJob.t),
      orderBy: orderBy?.call(PlatformJob.t),
      orderByList: orderByList?.call(PlatformJob.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PlatformJob] by its [id] or null if no such row exists.
  Future<PlatformJob?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PlatformJob>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PlatformJob]s in the list and returns the inserted rows.
  ///
  /// The returned [PlatformJob]s will have their `id` fields set.
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
  Future<List<PlatformJob>> insert(
    _is.DatabaseSession session,
    List<PlatformJob> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PlatformJob>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PlatformJob] and returns the inserted row.
  ///
  /// The returned [PlatformJob] will have its `id` field set.
  Future<PlatformJob> insertRow(
    _is.DatabaseSession session,
    PlatformJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlatformJob>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PlatformJob]s in the list and returns the resulting rows.
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
  /// The returned [PlatformJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlatformJob>> upsert(
    _is.DatabaseSession session,
    List<PlatformJob> rows, {
    required _is.ColumnSelections<PlatformJobTable> conflictColumns,
    _is.ColumnSelections<PlatformJobTable>? updateColumns,
    _is.WhereExpressionBuilder<PlatformJobTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PlatformJob>(
      rows,
      conflictColumns: conflictColumns(PlatformJob.t),
      updateColumns: updateColumns?.call(PlatformJob.t),
      updateWhere: updateWhere?.call(PlatformJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PlatformJob] and returns the resulting row.
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
  /// The returned [PlatformJob] will have its `id` field set.
  Future<PlatformJob?> upsertRow(
    _is.DatabaseSession session,
    PlatformJob row, {
    required _is.ColumnSelections<PlatformJobTable> conflictColumns,
    _is.ColumnSelections<PlatformJobTable>? updateColumns,
    _is.WhereExpressionBuilder<PlatformJobTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PlatformJob>(
      row,
      conflictColumns: conflictColumns(PlatformJob.t),
      updateColumns: updateColumns?.call(PlatformJob.t),
      updateWhere: updateWhere?.call(PlatformJob.t),
      transaction: transaction,
    );
  }

  /// Updates all [PlatformJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlatformJob>> update(
    _is.DatabaseSession session,
    List<PlatformJob> rows, {
    _is.ColumnSelections<PlatformJobTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PlatformJob>(
      rows,
      columns: columns?.call(PlatformJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PlatformJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlatformJob> updateRow(
    _is.DatabaseSession session,
    PlatformJob row, {
    _is.ColumnSelections<PlatformJobTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PlatformJob>(
      row,
      columns: columns?.call(PlatformJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlatformJob] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PlatformJob?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PlatformJobUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PlatformJob>(
      id,
      columnValues: columnValues(PlatformJob.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlatformJob]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlatformJob>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PlatformJobUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PlatformJobTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlatformJobTable>? orderBy,
    _is.OrderByListBuilder<PlatformJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PlatformJob>(
      columnValues: columnValues(PlatformJob.t.updateTable),
      where: where(PlatformJob.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlatformJob.t),
      orderByList: orderByList?.call(PlatformJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PlatformJob]s in the list and returns the deleted rows.
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
  Future<List<PlatformJob>> delete(
    _is.DatabaseSession session,
    List<PlatformJob> rows, {
    _is.OrderByBuilder<PlatformJobTable>? orderBy,
    _is.OrderByListBuilder<PlatformJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PlatformJob>(
      rows,
      orderBy: orderBy?.call(PlatformJob.t),
      orderByList: orderByList?.call(PlatformJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PlatformJob].
  Future<PlatformJob> deleteRow(
    _is.DatabaseSession session,
    PlatformJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlatformJob>(
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
  Future<List<PlatformJob>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlatformJobTable> where,
    _is.OrderByBuilder<PlatformJobTable>? orderBy,
    _is.OrderByListBuilder<PlatformJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PlatformJob>(
      where: where(PlatformJob.t),
      orderBy: orderBy?.call(PlatformJob.t),
      orderByList: orderByList?.call(PlatformJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlatformJobTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PlatformJob>(
      where: where?.call(PlatformJob.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PlatformJob] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlatformJobTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PlatformJob>(
      where: where(PlatformJob.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
