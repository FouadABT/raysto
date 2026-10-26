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

abstract class WebhookEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  WebhookEvent._({
    this.id,
    required this.providerEventId,
    required this.eventType,
    required this.receivedAt,
  });

  factory WebhookEvent({
    int? id,
    required String providerEventId,
    required String eventType,
    required DateTime receivedAt,
  }) = _WebhookEventImpl;

  factory WebhookEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return WebhookEvent(
      id: jsonSerialization['id'] as int?,
      providerEventId: jsonSerialization['providerEventId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  static final t = WebhookEventTable();

  static const db = WebhookEventRepository._();

  @override
  int? id;

  String providerEventId;

  String eventType;

  DateTime receivedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [WebhookEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WebhookEvent copyWith({
    int? id,
    String? providerEventId,
    String? eventType,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WebhookEvent',
      if (id != null) 'id': id,
      'providerEventId': providerEventId,
      'eventType': eventType,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static WebhookEventInclude include() {
    return WebhookEventInclude._();
  }

  static WebhookEventIncludeList includeList({
    _is.WhereExpressionBuilder<WebhookEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WebhookEventTable>? orderBy,
    _is.OrderByListBuilder<WebhookEventTable>? orderByList,
    WebhookEventInclude? include,
  }) {
    return WebhookEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WebhookEvent.t),
      orderByList: orderByList?.call(WebhookEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WebhookEventImpl extends WebhookEvent {
  _WebhookEventImpl({
    int? id,
    required String providerEventId,
    required String eventType,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         providerEventId: providerEventId,
         eventType: eventType,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [WebhookEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WebhookEvent copyWith({
    Object? id = _Undefined,
    String? providerEventId,
    String? eventType,
    DateTime? receivedAt,
  }) {
    return WebhookEvent(
      id: id is int? ? id : this.id,
      providerEventId: providerEventId ?? this.providerEventId,
      eventType: eventType ?? this.eventType,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class WebhookEventUpdateTable extends _is.UpdateTable<WebhookEventTable> {
  WebhookEventUpdateTable(super.table);

  _is.ColumnValue<String, String> providerEventId(String value) =>
      _is.ColumnValue(
        table.providerEventId,
        value,
      );

  _is.ColumnValue<String, String> eventType(String value) => _is.ColumnValue(
    table.eventType,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );
}

class WebhookEventTable extends _is.Table<int?> {
  WebhookEventTable({super.tableRelation})
    : super(tableName: 'raysto_webhook_event') {
    updateTable = WebhookEventUpdateTable(this);
    providerEventId = _is.ColumnString(
      'providerEventId',
      this,
    );
    eventType = _is.ColumnString(
      'eventType',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
  }

  late final WebhookEventUpdateTable updateTable;

  late final _is.ColumnString providerEventId;

  late final _is.ColumnString eventType;

  late final _is.ColumnDateTime receivedAt;

  @override
  List<_is.Column> get columns => [
    id,
    providerEventId,
    eventType,
    receivedAt,
  ];
}

class WebhookEventInclude extends _is.IncludeObject {
  WebhookEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => WebhookEvent.t;
}

class WebhookEventIncludeList extends _is.IncludeList {
  WebhookEventIncludeList._({
    _is.WhereExpressionBuilder<WebhookEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WebhookEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => WebhookEvent.t;
}

class WebhookEventRepository {
  const WebhookEventRepository._();

  /// Returns a list of [WebhookEvent]s matching the given query parameters.
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
  Future<List<WebhookEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WebhookEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WebhookEventTable>? orderBy,
    _is.OrderByListBuilder<WebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WebhookEvent>(
      where: where?.call(WebhookEvent.t),
      orderBy: orderBy?.call(WebhookEvent.t),
      orderByList: orderByList?.call(WebhookEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WebhookEvent] matching the given query parameters.
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
  Future<WebhookEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WebhookEventTable>? where,
    int? offset,
    _is.OrderByBuilder<WebhookEventTable>? orderBy,
    _is.OrderByListBuilder<WebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WebhookEvent>(
      where: where?.call(WebhookEvent.t),
      orderBy: orderBy?.call(WebhookEvent.t),
      orderByList: orderByList?.call(WebhookEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WebhookEvent] by its [id] or null if no such row exists.
  Future<WebhookEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WebhookEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WebhookEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [WebhookEvent]s will have their `id` fields set.
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
  Future<List<WebhookEvent>> insert(
    _is.DatabaseSession session,
    List<WebhookEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WebhookEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WebhookEvent] and returns the inserted row.
  ///
  /// The returned [WebhookEvent] will have its `id` field set.
  Future<WebhookEvent> insertRow(
    _is.DatabaseSession session,
    WebhookEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WebhookEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WebhookEvent]s in the list and returns the resulting rows.
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
  /// The returned [WebhookEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookEvent>> upsert(
    _is.DatabaseSession session,
    List<WebhookEvent> rows, {
    required _is.ColumnSelections<WebhookEventTable> conflictColumns,
    _is.ColumnSelections<WebhookEventTable>? updateColumns,
    _is.WhereExpressionBuilder<WebhookEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WebhookEvent>(
      rows,
      conflictColumns: conflictColumns(WebhookEvent.t),
      updateColumns: updateColumns?.call(WebhookEvent.t),
      updateWhere: updateWhere?.call(WebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WebhookEvent] and returns the resulting row.
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
  /// The returned [WebhookEvent] will have its `id` field set.
  Future<WebhookEvent?> upsertRow(
    _is.DatabaseSession session,
    WebhookEvent row, {
    required _is.ColumnSelections<WebhookEventTable> conflictColumns,
    _is.ColumnSelections<WebhookEventTable>? updateColumns,
    _is.WhereExpressionBuilder<WebhookEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WebhookEvent>(
      row,
      conflictColumns: conflictColumns(WebhookEvent.t),
      updateColumns: updateColumns?.call(WebhookEvent.t),
      updateWhere: updateWhere?.call(WebhookEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [WebhookEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookEvent>> update(
    _is.DatabaseSession session,
    List<WebhookEvent> rows, {
    _is.ColumnSelections<WebhookEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WebhookEvent>(
      rows,
      columns: columns?.call(WebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WebhookEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WebhookEvent> updateRow(
    _is.DatabaseSession session,
    WebhookEvent row, {
    _is.ColumnSelections<WebhookEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WebhookEvent>(
      row,
      columns: columns?.call(WebhookEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WebhookEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WebhookEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<WebhookEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WebhookEvent>(
      id,
      columnValues: columnValues(WebhookEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WebhookEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WebhookEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<WebhookEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WebhookEventTable>? orderBy,
    _is.OrderByListBuilder<WebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WebhookEvent>(
      columnValues: columnValues(WebhookEvent.t.updateTable),
      where: where(WebhookEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WebhookEvent.t),
      orderByList: orderByList?.call(WebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WebhookEvent]s in the list and returns the deleted rows.
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
  Future<List<WebhookEvent>> delete(
    _is.DatabaseSession session,
    List<WebhookEvent> rows, {
    _is.OrderByBuilder<WebhookEventTable>? orderBy,
    _is.OrderByListBuilder<WebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WebhookEvent>(
      rows,
      orderBy: orderBy?.call(WebhookEvent.t),
      orderByList: orderByList?.call(WebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WebhookEvent].
  Future<WebhookEvent> deleteRow(
    _is.DatabaseSession session,
    WebhookEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WebhookEvent>(
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
  Future<List<WebhookEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WebhookEventTable> where,
    _is.OrderByBuilder<WebhookEventTable>? orderBy,
    _is.OrderByListBuilder<WebhookEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WebhookEvent>(
      where: where(WebhookEvent.t),
      orderBy: orderBy?.call(WebhookEvent.t),
      orderByList: orderByList?.call(WebhookEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WebhookEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WebhookEvent>(
      where: where?.call(WebhookEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WebhookEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WebhookEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WebhookEvent>(
      where: where(WebhookEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
