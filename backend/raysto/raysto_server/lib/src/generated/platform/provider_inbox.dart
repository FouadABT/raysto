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

abstract class ProviderInbox
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ProviderInbox._({
    this.id,
    required this.provider,
    required this.eventId,
    required this.eventType,
    required this.payloadJson,
    required this.status,
    required this.receivedAt,
    this.processedAt,
  });

  factory ProviderInbox({
    int? id,
    required String provider,
    required String eventId,
    required String eventType,
    required String payloadJson,
    required String status,
    required DateTime receivedAt,
    DateTime? processedAt,
  }) = _ProviderInboxImpl;

  factory ProviderInbox.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProviderInbox(
      id: jsonSerialization['id'] as int?,
      provider: jsonSerialization['provider'] as String,
      eventId: jsonSerialization['eventId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      payloadJson: jsonSerialization['payloadJson'] as String,
      status: jsonSerialization['status'] as String,
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
    );
  }

  static final t = ProviderInboxTable();

  static const db = ProviderInboxRepository._();

  @override
  int? id;

  String provider;

  String eventId;

  String eventType;

  String payloadJson;

  String status;

  DateTime receivedAt;

  DateTime? processedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProviderInbox]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProviderInbox copyWith({
    int? id,
    String? provider,
    String? eventId,
    String? eventType,
    String? payloadJson,
    String? status,
    DateTime? receivedAt,
    DateTime? processedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProviderInbox',
      if (id != null) 'id': id,
      'provider': provider,
      'eventId': eventId,
      'eventType': eventType,
      'payloadJson': payloadJson,
      'status': status,
      'receivedAt': receivedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ProviderInboxInclude include() {
    return ProviderInboxInclude._();
  }

  static ProviderInboxIncludeList includeList({
    _is.WhereExpressionBuilder<ProviderInboxTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProviderInboxTable>? orderBy,
    _is.OrderByListBuilder<ProviderInboxTable>? orderByList,
    ProviderInboxInclude? include,
  }) {
    return ProviderInboxIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProviderInbox.t),
      orderByList: orderByList?.call(ProviderInbox.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProviderInboxImpl extends ProviderInbox {
  _ProviderInboxImpl({
    int? id,
    required String provider,
    required String eventId,
    required String eventType,
    required String payloadJson,
    required String status,
    required DateTime receivedAt,
    DateTime? processedAt,
  }) : super._(
         id: id,
         provider: provider,
         eventId: eventId,
         eventType: eventType,
         payloadJson: payloadJson,
         status: status,
         receivedAt: receivedAt,
         processedAt: processedAt,
       );

  /// Returns a shallow copy of this [ProviderInbox]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProviderInbox copyWith({
    Object? id = _Undefined,
    String? provider,
    String? eventId,
    String? eventType,
    String? payloadJson,
    String? status,
    DateTime? receivedAt,
    Object? processedAt = _Undefined,
  }) {
    return ProviderInbox(
      id: id is int? ? id : this.id,
      provider: provider ?? this.provider,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      receivedAt: receivedAt ?? this.receivedAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
    );
  }
}

class ProviderInboxUpdateTable extends _is.UpdateTable<ProviderInboxTable> {
  ProviderInboxUpdateTable(super.table);

  _is.ColumnValue<String, String> provider(String value) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<String, String> eventId(String value) => _is.ColumnValue(
    table.eventId,
    value,
  );

  _is.ColumnValue<String, String> eventType(String value) => _is.ColumnValue(
    table.eventType,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> processedAt(DateTime? value) =>
      _is.ColumnValue(
        table.processedAt,
        value,
      );
}

class ProviderInboxTable extends _is.Table<int?> {
  ProviderInboxTable({super.tableRelation})
    : super(tableName: 'raysto_provider_inbox') {
    updateTable = ProviderInboxUpdateTable(this);
    provider = _is.ColumnString(
      'provider',
      this,
    );
    eventId = _is.ColumnString(
      'eventId',
      this,
    );
    eventType = _is.ColumnString(
      'eventType',
      this,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
    processedAt = _is.ColumnDateTime(
      'processedAt',
      this,
    );
  }

  late final ProviderInboxUpdateTable updateTable;

  late final _is.ColumnString provider;

  late final _is.ColumnString eventId;

  late final _is.ColumnString eventType;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime processedAt;

  @override
  List<_is.Column> get columns => [
    id,
    provider,
    eventId,
    eventType,
    payloadJson,
    status,
    receivedAt,
    processedAt,
  ];
}

class ProviderInboxInclude extends _is.IncludeObject {
  ProviderInboxInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ProviderInbox.t;
}

class ProviderInboxIncludeList extends _is.IncludeList {
  ProviderInboxIncludeList._({
    _is.WhereExpressionBuilder<ProviderInboxTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProviderInbox.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ProviderInbox.t;
}

class ProviderInboxRepository {
  const ProviderInboxRepository._();

  /// Returns a list of [ProviderInbox]s matching the given query parameters.
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
  Future<List<ProviderInbox>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProviderInboxTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProviderInboxTable>? orderBy,
    _is.OrderByListBuilder<ProviderInboxTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProviderInbox>(
      where: where?.call(ProviderInbox.t),
      orderBy: orderBy?.call(ProviderInbox.t),
      orderByList: orderByList?.call(ProviderInbox.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProviderInbox] matching the given query parameters.
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
  Future<ProviderInbox?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProviderInboxTable>? where,
    int? offset,
    _is.OrderByBuilder<ProviderInboxTable>? orderBy,
    _is.OrderByListBuilder<ProviderInboxTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProviderInbox>(
      where: where?.call(ProviderInbox.t),
      orderBy: orderBy?.call(ProviderInbox.t),
      orderByList: orderByList?.call(ProviderInbox.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProviderInbox] by its [id] or null if no such row exists.
  Future<ProviderInbox?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProviderInbox>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProviderInbox]s in the list and returns the inserted rows.
  ///
  /// The returned [ProviderInbox]s will have their `id` fields set.
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
  Future<List<ProviderInbox>> insert(
    _is.DatabaseSession session,
    List<ProviderInbox> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProviderInbox>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProviderInbox] and returns the inserted row.
  ///
  /// The returned [ProviderInbox] will have its `id` field set.
  Future<ProviderInbox> insertRow(
    _is.DatabaseSession session,
    ProviderInbox row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProviderInbox>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProviderInbox]s in the list and returns the resulting rows.
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
  /// The returned [ProviderInbox]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProviderInbox>> upsert(
    _is.DatabaseSession session,
    List<ProviderInbox> rows, {
    required _is.ColumnSelections<ProviderInboxTable> conflictColumns,
    _is.ColumnSelections<ProviderInboxTable>? updateColumns,
    _is.WhereExpressionBuilder<ProviderInboxTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProviderInbox>(
      rows,
      conflictColumns: conflictColumns(ProviderInbox.t),
      updateColumns: updateColumns?.call(ProviderInbox.t),
      updateWhere: updateWhere?.call(ProviderInbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProviderInbox] and returns the resulting row.
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
  /// The returned [ProviderInbox] will have its `id` field set.
  Future<ProviderInbox?> upsertRow(
    _is.DatabaseSession session,
    ProviderInbox row, {
    required _is.ColumnSelections<ProviderInboxTable> conflictColumns,
    _is.ColumnSelections<ProviderInboxTable>? updateColumns,
    _is.WhereExpressionBuilder<ProviderInboxTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProviderInbox>(
      row,
      conflictColumns: conflictColumns(ProviderInbox.t),
      updateColumns: updateColumns?.call(ProviderInbox.t),
      updateWhere: updateWhere?.call(ProviderInbox.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProviderInbox]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProviderInbox>> update(
    _is.DatabaseSession session,
    List<ProviderInbox> rows, {
    _is.ColumnSelections<ProviderInboxTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProviderInbox>(
      rows,
      columns: columns?.call(ProviderInbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProviderInbox]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProviderInbox> updateRow(
    _is.DatabaseSession session,
    ProviderInbox row, {
    _is.ColumnSelections<ProviderInboxTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProviderInbox>(
      row,
      columns: columns?.call(ProviderInbox.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProviderInbox] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProviderInbox?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ProviderInboxUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProviderInbox>(
      id,
      columnValues: columnValues(ProviderInbox.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProviderInbox]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProviderInbox>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProviderInboxUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ProviderInboxTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProviderInboxTable>? orderBy,
    _is.OrderByListBuilder<ProviderInboxTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProviderInbox>(
      columnValues: columnValues(ProviderInbox.t.updateTable),
      where: where(ProviderInbox.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProviderInbox.t),
      orderByList: orderByList?.call(ProviderInbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProviderInbox]s in the list and returns the deleted rows.
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
  Future<List<ProviderInbox>> delete(
    _is.DatabaseSession session,
    List<ProviderInbox> rows, {
    _is.OrderByBuilder<ProviderInboxTable>? orderBy,
    _is.OrderByListBuilder<ProviderInboxTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProviderInbox>(
      rows,
      orderBy: orderBy?.call(ProviderInbox.t),
      orderByList: orderByList?.call(ProviderInbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProviderInbox].
  Future<ProviderInbox> deleteRow(
    _is.DatabaseSession session,
    ProviderInbox row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProviderInbox>(
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
  Future<List<ProviderInbox>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProviderInboxTable> where,
    _is.OrderByBuilder<ProviderInboxTable>? orderBy,
    _is.OrderByListBuilder<ProviderInboxTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProviderInbox>(
      where: where(ProviderInbox.t),
      orderBy: orderBy?.call(ProviderInbox.t),
      orderByList: orderByList?.call(ProviderInbox.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProviderInboxTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProviderInbox>(
      where: where?.call(ProviderInbox.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProviderInbox] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProviderInboxTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProviderInbox>(
      where: where(ProviderInbox.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
