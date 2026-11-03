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

abstract class DisputeCase
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DisputeCase._({
    this.id,
    required this.restaurantId,
    required this.providerDisputeId,
    this.captureId,
    required this.reason,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.evidenceJson,
    this.replyText,
    this.taskId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DisputeCase({
    int? id,
    required int restaurantId,
    required String providerDisputeId,
    int? captureId,
    required String reason,
    required int amountMinor,
    required String currency,
    required String status,
    required String evidenceJson,
    String? replyText,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DisputeCaseImpl;

  factory DisputeCase.fromJson(Map<String, dynamic> jsonSerialization) {
    return DisputeCase(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      providerDisputeId: jsonSerialization['providerDisputeId'] as String,
      captureId: jsonSerialization['captureId'] as int?,
      reason: jsonSerialization['reason'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      status: jsonSerialization['status'] as String,
      evidenceJson: jsonSerialization['evidenceJson'] as String,
      replyText: jsonSerialization['replyText'] as String?,
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

  static final t = DisputeCaseTable();

  static const db = DisputeCaseRepository._();

  @override
  int? id;

  int restaurantId;

  String providerDisputeId;

  int? captureId;

  String reason;

  int amountMinor;

  String currency;

  String status;

  String evidenceJson;

  String? replyText;

  int? taskId;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DisputeCase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DisputeCase copyWith({
    int? id,
    int? restaurantId,
    String? providerDisputeId,
    int? captureId,
    String? reason,
    int? amountMinor,
    String? currency,
    String? status,
    String? evidenceJson,
    String? replyText,
    int? taskId,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DisputeCase',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'providerDisputeId': providerDisputeId,
      if (captureId != null) 'captureId': captureId,
      'reason': reason,
      'amountMinor': amountMinor,
      'currency': currency,
      'status': status,
      'evidenceJson': evidenceJson,
      if (replyText != null) 'replyText': replyText,
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

  static DisputeCaseInclude include() {
    return DisputeCaseInclude._();
  }

  static DisputeCaseIncludeList includeList({
    _is.WhereExpressionBuilder<DisputeCaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DisputeCaseTable>? orderBy,
    _is.OrderByListBuilder<DisputeCaseTable>? orderByList,
    DisputeCaseInclude? include,
  }) {
    return DisputeCaseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DisputeCase.t),
      orderByList: orderByList?.call(DisputeCase.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DisputeCaseImpl extends DisputeCase {
  _DisputeCaseImpl({
    int? id,
    required int restaurantId,
    required String providerDisputeId,
    int? captureId,
    required String reason,
    required int amountMinor,
    required String currency,
    required String status,
    required String evidenceJson,
    String? replyText,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         providerDisputeId: providerDisputeId,
         captureId: captureId,
         reason: reason,
         amountMinor: amountMinor,
         currency: currency,
         status: status,
         evidenceJson: evidenceJson,
         replyText: replyText,
         taskId: taskId,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [DisputeCase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DisputeCase copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? providerDisputeId,
    Object? captureId = _Undefined,
    String? reason,
    int? amountMinor,
    String? currency,
    String? status,
    String? evidenceJson,
    Object? replyText = _Undefined,
    Object? taskId = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DisputeCase(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      providerDisputeId: providerDisputeId ?? this.providerDisputeId,
      captureId: captureId is int? ? captureId : this.captureId,
      reason: reason ?? this.reason,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      replyText: replyText is String? ? replyText : this.replyText,
      taskId: taskId is int? ? taskId : this.taskId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DisputeCaseUpdateTable extends _is.UpdateTable<DisputeCaseTable> {
  DisputeCaseUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> providerDisputeId(String value) =>
      _is.ColumnValue(
        table.providerDisputeId,
        value,
      );

  _is.ColumnValue<int, int> captureId(int? value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> evidenceJson(String value) => _is.ColumnValue(
    table.evidenceJson,
    value,
  );

  _is.ColumnValue<String, String> replyText(String? value) => _is.ColumnValue(
    table.replyText,
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

class DisputeCaseTable extends _is.Table<int?> {
  DisputeCaseTable({super.tableRelation})
    : super(tableName: 'raysto_dispute_case') {
    updateTable = DisputeCaseUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    providerDisputeId = _is.ColumnString(
      'providerDisputeId',
      this,
    );
    captureId = _is.ColumnInt(
      'captureId',
      this,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    evidenceJson = _is.ColumnString(
      'evidenceJson',
      this,
    );
    replyText = _is.ColumnString(
      'replyText',
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

  late final DisputeCaseUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString providerDisputeId;

  late final _is.ColumnInt captureId;

  late final _is.ColumnString reason;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString status;

  late final _is.ColumnString evidenceJson;

  late final _is.ColumnString replyText;

  late final _is.ColumnInt taskId;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    providerDisputeId,
    captureId,
    reason,
    amountMinor,
    currency,
    status,
    evidenceJson,
    replyText,
    taskId,
    version,
    createdAt,
    updatedAt,
  ];
}

class DisputeCaseInclude extends _is.IncludeObject {
  DisputeCaseInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DisputeCase.t;
}

class DisputeCaseIncludeList extends _is.IncludeList {
  DisputeCaseIncludeList._({
    _is.WhereExpressionBuilder<DisputeCaseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DisputeCase.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DisputeCase.t;
}

class DisputeCaseRepository {
  const DisputeCaseRepository._();

  /// Returns a list of [DisputeCase]s matching the given query parameters.
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
  Future<List<DisputeCase>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DisputeCaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DisputeCaseTable>? orderBy,
    _is.OrderByListBuilder<DisputeCaseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DisputeCase>(
      where: where?.call(DisputeCase.t),
      orderBy: orderBy?.call(DisputeCase.t),
      orderByList: orderByList?.call(DisputeCase.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DisputeCase] matching the given query parameters.
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
  Future<DisputeCase?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DisputeCaseTable>? where,
    int? offset,
    _is.OrderByBuilder<DisputeCaseTable>? orderBy,
    _is.OrderByListBuilder<DisputeCaseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DisputeCase>(
      where: where?.call(DisputeCase.t),
      orderBy: orderBy?.call(DisputeCase.t),
      orderByList: orderByList?.call(DisputeCase.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DisputeCase] by its [id] or null if no such row exists.
  Future<DisputeCase?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DisputeCase>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DisputeCase]s in the list and returns the inserted rows.
  ///
  /// The returned [DisputeCase]s will have their `id` fields set.
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
  Future<List<DisputeCase>> insert(
    _is.DatabaseSession session,
    List<DisputeCase> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DisputeCase>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DisputeCase] and returns the inserted row.
  ///
  /// The returned [DisputeCase] will have its `id` field set.
  Future<DisputeCase> insertRow(
    _is.DatabaseSession session,
    DisputeCase row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DisputeCase>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DisputeCase]s in the list and returns the resulting rows.
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
  /// The returned [DisputeCase]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DisputeCase>> upsert(
    _is.DatabaseSession session,
    List<DisputeCase> rows, {
    required _is.ColumnSelections<DisputeCaseTable> conflictColumns,
    _is.ColumnSelections<DisputeCaseTable>? updateColumns,
    _is.WhereExpressionBuilder<DisputeCaseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DisputeCase>(
      rows,
      conflictColumns: conflictColumns(DisputeCase.t),
      updateColumns: updateColumns?.call(DisputeCase.t),
      updateWhere: updateWhere?.call(DisputeCase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DisputeCase] and returns the resulting row.
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
  /// The returned [DisputeCase] will have its `id` field set.
  Future<DisputeCase?> upsertRow(
    _is.DatabaseSession session,
    DisputeCase row, {
    required _is.ColumnSelections<DisputeCaseTable> conflictColumns,
    _is.ColumnSelections<DisputeCaseTable>? updateColumns,
    _is.WhereExpressionBuilder<DisputeCaseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DisputeCase>(
      row,
      conflictColumns: conflictColumns(DisputeCase.t),
      updateColumns: updateColumns?.call(DisputeCase.t),
      updateWhere: updateWhere?.call(DisputeCase.t),
      transaction: transaction,
    );
  }

  /// Updates all [DisputeCase]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DisputeCase>> update(
    _is.DatabaseSession session,
    List<DisputeCase> rows, {
    _is.ColumnSelections<DisputeCaseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DisputeCase>(
      rows,
      columns: columns?.call(DisputeCase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DisputeCase]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DisputeCase> updateRow(
    _is.DatabaseSession session,
    DisputeCase row, {
    _is.ColumnSelections<DisputeCaseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DisputeCase>(
      row,
      columns: columns?.call(DisputeCase.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DisputeCase] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DisputeCase?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DisputeCaseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DisputeCase>(
      id,
      columnValues: columnValues(DisputeCase.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DisputeCase]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DisputeCase>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DisputeCaseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DisputeCaseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DisputeCaseTable>? orderBy,
    _is.OrderByListBuilder<DisputeCaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DisputeCase>(
      columnValues: columnValues(DisputeCase.t.updateTable),
      where: where(DisputeCase.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DisputeCase.t),
      orderByList: orderByList?.call(DisputeCase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DisputeCase]s in the list and returns the deleted rows.
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
  Future<List<DisputeCase>> delete(
    _is.DatabaseSession session,
    List<DisputeCase> rows, {
    _is.OrderByBuilder<DisputeCaseTable>? orderBy,
    _is.OrderByListBuilder<DisputeCaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DisputeCase>(
      rows,
      orderBy: orderBy?.call(DisputeCase.t),
      orderByList: orderByList?.call(DisputeCase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DisputeCase].
  Future<DisputeCase> deleteRow(
    _is.DatabaseSession session,
    DisputeCase row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DisputeCase>(
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
  Future<List<DisputeCase>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DisputeCaseTable> where,
    _is.OrderByBuilder<DisputeCaseTable>? orderBy,
    _is.OrderByListBuilder<DisputeCaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DisputeCase>(
      where: where(DisputeCase.t),
      orderBy: orderBy?.call(DisputeCase.t),
      orderByList: orderByList?.call(DisputeCase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DisputeCaseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DisputeCase>(
      where: where?.call(DisputeCase.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DisputeCase] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DisputeCaseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DisputeCase>(
      where: where(DisputeCase.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
