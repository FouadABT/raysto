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

abstract class PartnerEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PartnerEvent._({
    this.id,
    required this.restaurantId,
    required this.partnerAppId,
    required this.direction,
    required this.type,
    this.ref,
    required this.status,
    required this.attempts,
    this.responseCode,
    required this.payloadJson,
    this.idempotencyKey,
    this.nextAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerEvent({
    int? id,
    required int restaurantId,
    required int partnerAppId,
    required String direction,
    required String type,
    String? ref,
    required String status,
    required int attempts,
    int? responseCode,
    required String payloadJson,
    String? idempotencyKey,
    DateTime? nextAttemptAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PartnerEventImpl;

  factory PartnerEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return PartnerEvent(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      partnerAppId: jsonSerialization['partnerAppId'] as int,
      direction: jsonSerialization['direction'] as String,
      type: jsonSerialization['type'] as String,
      ref: jsonSerialization['ref'] as String?,
      status: jsonSerialization['status'] as String,
      attempts: jsonSerialization['attempts'] as int,
      responseCode: jsonSerialization['responseCode'] as int?,
      payloadJson: jsonSerialization['payloadJson'] as String,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PartnerEventTable();

  static const db = PartnerEventRepository._();

  @override
  int? id;

  int restaurantId;

  int partnerAppId;

  String direction;

  String type;

  String? ref;

  String status;

  int attempts;

  int? responseCode;

  String payloadJson;

  String? idempotencyKey;

  DateTime? nextAttemptAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PartnerEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PartnerEvent copyWith({
    int? id,
    int? restaurantId,
    int? partnerAppId,
    String? direction,
    String? type,
    String? ref,
    String? status,
    int? attempts,
    int? responseCode,
    String? payloadJson,
    String? idempotencyKey,
    DateTime? nextAttemptAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PartnerEvent',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'partnerAppId': partnerAppId,
      'direction': direction,
      'type': type,
      if (ref != null) 'ref': ref,
      'status': status,
      'attempts': attempts,
      if (responseCode != null) 'responseCode': responseCode,
      'payloadJson': payloadJson,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PartnerEventInclude include() {
    return PartnerEventInclude._();
  }

  static PartnerEventIncludeList includeList({
    _is.WhereExpressionBuilder<PartnerEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartnerEventTable>? orderBy,
    _is.OrderByListBuilder<PartnerEventTable>? orderByList,
    PartnerEventInclude? include,
  }) {
    return PartnerEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PartnerEvent.t),
      orderByList: orderByList?.call(PartnerEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PartnerEventImpl extends PartnerEvent {
  _PartnerEventImpl({
    int? id,
    required int restaurantId,
    required int partnerAppId,
    required String direction,
    required String type,
    String? ref,
    required String status,
    required int attempts,
    int? responseCode,
    required String payloadJson,
    String? idempotencyKey,
    DateTime? nextAttemptAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         partnerAppId: partnerAppId,
         direction: direction,
         type: type,
         ref: ref,
         status: status,
         attempts: attempts,
         responseCode: responseCode,
         payloadJson: payloadJson,
         idempotencyKey: idempotencyKey,
         nextAttemptAt: nextAttemptAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PartnerEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PartnerEvent copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? partnerAppId,
    String? direction,
    String? type,
    Object? ref = _Undefined,
    String? status,
    int? attempts,
    Object? responseCode = _Undefined,
    String? payloadJson,
    Object? idempotencyKey = _Undefined,
    Object? nextAttemptAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerEvent(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      partnerAppId: partnerAppId ?? this.partnerAppId,
      direction: direction ?? this.direction,
      type: type ?? this.type,
      ref: ref is String? ? ref : this.ref,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      responseCode: responseCode is int? ? responseCode : this.responseCode,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey is String?
          ? idempotencyKey
          : this.idempotencyKey,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PartnerEventUpdateTable extends _is.UpdateTable<PartnerEventTable> {
  PartnerEventUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> partnerAppId(int value) => _is.ColumnValue(
    table.partnerAppId,
    value,
  );

  _is.ColumnValue<String, String> direction(String value) => _is.ColumnValue(
    table.direction,
    value,
  );

  _is.ColumnValue<String, String> type(String value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<String, String> ref(String? value) => _is.ColumnValue(
    table.ref,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
    value,
  );

  _is.ColumnValue<int, int> responseCode(int? value) => _is.ColumnValue(
    table.responseCode,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<String, String> idempotencyKey(String? value) =>
      _is.ColumnValue(
        table.idempotencyKey,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime? value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
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

class PartnerEventTable extends _is.Table<int?> {
  PartnerEventTable({super.tableRelation})
    : super(tableName: 'raysto_partner_event') {
    updateTable = PartnerEventUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    partnerAppId = _is.ColumnInt(
      'partnerAppId',
      this,
    );
    direction = _is.ColumnString(
      'direction',
      this,
    );
    type = _is.ColumnString(
      'type',
      this,
    );
    ref = _is.ColumnString(
      'ref',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
    );
    responseCode = _is.ColumnInt(
      'responseCode',
      this,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
    );
    idempotencyKey = _is.ColumnString(
      'idempotencyKey',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
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

  late final PartnerEventUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt partnerAppId;

  late final _is.ColumnString direction;

  late final _is.ColumnString type;

  late final _is.ColumnString ref;

  late final _is.ColumnString status;

  late final _is.ColumnInt attempts;

  late final _is.ColumnInt responseCode;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnString idempotencyKey;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    partnerAppId,
    direction,
    type,
    ref,
    status,
    attempts,
    responseCode,
    payloadJson,
    idempotencyKey,
    nextAttemptAt,
    createdAt,
    updatedAt,
  ];
}

class PartnerEventInclude extends _is.IncludeObject {
  PartnerEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PartnerEvent.t;
}

class PartnerEventIncludeList extends _is.IncludeList {
  PartnerEventIncludeList._({
    _is.WhereExpressionBuilder<PartnerEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PartnerEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PartnerEvent.t;
}

class PartnerEventRepository {
  const PartnerEventRepository._();

  /// Returns a list of [PartnerEvent]s matching the given query parameters.
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
  Future<List<PartnerEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartnerEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartnerEventTable>? orderBy,
    _is.OrderByListBuilder<PartnerEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PartnerEvent>(
      where: where?.call(PartnerEvent.t),
      orderBy: orderBy?.call(PartnerEvent.t),
      orderByList: orderByList?.call(PartnerEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PartnerEvent] matching the given query parameters.
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
  Future<PartnerEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartnerEventTable>? where,
    int? offset,
    _is.OrderByBuilder<PartnerEventTable>? orderBy,
    _is.OrderByListBuilder<PartnerEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PartnerEvent>(
      where: where?.call(PartnerEvent.t),
      orderBy: orderBy?.call(PartnerEvent.t),
      orderByList: orderByList?.call(PartnerEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PartnerEvent] by its [id] or null if no such row exists.
  Future<PartnerEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PartnerEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PartnerEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [PartnerEvent]s will have their `id` fields set.
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
  Future<List<PartnerEvent>> insert(
    _is.DatabaseSession session,
    List<PartnerEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PartnerEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PartnerEvent] and returns the inserted row.
  ///
  /// The returned [PartnerEvent] will have its `id` field set.
  Future<PartnerEvent> insertRow(
    _is.DatabaseSession session,
    PartnerEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PartnerEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PartnerEvent]s in the list and returns the resulting rows.
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
  /// The returned [PartnerEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PartnerEvent>> upsert(
    _is.DatabaseSession session,
    List<PartnerEvent> rows, {
    required _is.ColumnSelections<PartnerEventTable> conflictColumns,
    _is.ColumnSelections<PartnerEventTable>? updateColumns,
    _is.WhereExpressionBuilder<PartnerEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PartnerEvent>(
      rows,
      conflictColumns: conflictColumns(PartnerEvent.t),
      updateColumns: updateColumns?.call(PartnerEvent.t),
      updateWhere: updateWhere?.call(PartnerEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PartnerEvent] and returns the resulting row.
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
  /// The returned [PartnerEvent] will have its `id` field set.
  Future<PartnerEvent?> upsertRow(
    _is.DatabaseSession session,
    PartnerEvent row, {
    required _is.ColumnSelections<PartnerEventTable> conflictColumns,
    _is.ColumnSelections<PartnerEventTable>? updateColumns,
    _is.WhereExpressionBuilder<PartnerEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PartnerEvent>(
      row,
      conflictColumns: conflictColumns(PartnerEvent.t),
      updateColumns: updateColumns?.call(PartnerEvent.t),
      updateWhere: updateWhere?.call(PartnerEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [PartnerEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PartnerEvent>> update(
    _is.DatabaseSession session,
    List<PartnerEvent> rows, {
    _is.ColumnSelections<PartnerEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PartnerEvent>(
      rows,
      columns: columns?.call(PartnerEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PartnerEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PartnerEvent> updateRow(
    _is.DatabaseSession session,
    PartnerEvent row, {
    _is.ColumnSelections<PartnerEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PartnerEvent>(
      row,
      columns: columns?.call(PartnerEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PartnerEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PartnerEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PartnerEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PartnerEvent>(
      id,
      columnValues: columnValues(PartnerEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PartnerEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PartnerEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PartnerEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PartnerEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartnerEventTable>? orderBy,
    _is.OrderByListBuilder<PartnerEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PartnerEvent>(
      columnValues: columnValues(PartnerEvent.t.updateTable),
      where: where(PartnerEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PartnerEvent.t),
      orderByList: orderByList?.call(PartnerEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PartnerEvent]s in the list and returns the deleted rows.
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
  Future<List<PartnerEvent>> delete(
    _is.DatabaseSession session,
    List<PartnerEvent> rows, {
    _is.OrderByBuilder<PartnerEventTable>? orderBy,
    _is.OrderByListBuilder<PartnerEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PartnerEvent>(
      rows,
      orderBy: orderBy?.call(PartnerEvent.t),
      orderByList: orderByList?.call(PartnerEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PartnerEvent].
  Future<PartnerEvent> deleteRow(
    _is.DatabaseSession session,
    PartnerEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PartnerEvent>(
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
  Future<List<PartnerEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PartnerEventTable> where,
    _is.OrderByBuilder<PartnerEventTable>? orderBy,
    _is.OrderByListBuilder<PartnerEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PartnerEvent>(
      where: where(PartnerEvent.t),
      orderBy: orderBy?.call(PartnerEvent.t),
      orderByList: orderByList?.call(PartnerEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartnerEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PartnerEvent>(
      where: where?.call(PartnerEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PartnerEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PartnerEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PartnerEvent>(
      where: where(PartnerEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
