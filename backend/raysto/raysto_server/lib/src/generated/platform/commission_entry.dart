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

abstract class CommissionEntry
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CommissionEntry._({
    this.id,
    required this.restaurantId,
    required this.captureId,
    this.refundId,
    required this.eventKey,
    required this.amountMinor,
    required this.currency,
    required this.state,
    required this.createdAt,
  });

  factory CommissionEntry({
    int? id,
    required int restaurantId,
    required int captureId,
    int? refundId,
    required String eventKey,
    required int amountMinor,
    required String currency,
    required String state,
    required DateTime createdAt,
  }) = _CommissionEntryImpl;

  factory CommissionEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return CommissionEntry(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      captureId: jsonSerialization['captureId'] as int,
      refundId: jsonSerialization['refundId'] as int?,
      eventKey: jsonSerialization['eventKey'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      state: jsonSerialization['state'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = CommissionEntryTable();

  static const db = CommissionEntryRepository._();

  @override
  int? id;

  int restaurantId;

  int captureId;

  int? refundId;

  String eventKey;

  int amountMinor;

  String currency;

  String state;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CommissionEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CommissionEntry copyWith({
    int? id,
    int? restaurantId,
    int? captureId,
    int? refundId,
    String? eventKey,
    int? amountMinor,
    String? currency,
    String? state,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CommissionEntry',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'captureId': captureId,
      if (refundId != null) 'refundId': refundId,
      'eventKey': eventKey,
      'amountMinor': amountMinor,
      'currency': currency,
      'state': state,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CommissionEntryInclude include() {
    return CommissionEntryInclude._();
  }

  static CommissionEntryIncludeList includeList({
    _is.WhereExpressionBuilder<CommissionEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CommissionEntryTable>? orderBy,
    _is.OrderByListBuilder<CommissionEntryTable>? orderByList,
    CommissionEntryInclude? include,
  }) {
    return CommissionEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CommissionEntry.t),
      orderByList: orderByList?.call(CommissionEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CommissionEntryImpl extends CommissionEntry {
  _CommissionEntryImpl({
    int? id,
    required int restaurantId,
    required int captureId,
    int? refundId,
    required String eventKey,
    required int amountMinor,
    required String currency,
    required String state,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         captureId: captureId,
         refundId: refundId,
         eventKey: eventKey,
         amountMinor: amountMinor,
         currency: currency,
         state: state,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CommissionEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CommissionEntry copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? captureId,
    Object? refundId = _Undefined,
    String? eventKey,
    int? amountMinor,
    String? currency,
    String? state,
    DateTime? createdAt,
  }) {
    return CommissionEntry(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      captureId: captureId ?? this.captureId,
      refundId: refundId is int? ? refundId : this.refundId,
      eventKey: eventKey ?? this.eventKey,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommissionEntryUpdateTable extends _is.UpdateTable<CommissionEntryTable> {
  CommissionEntryUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> captureId(int value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<int, int> refundId(int? value) => _is.ColumnValue(
    table.refundId,
    value,
  );

  _is.ColumnValue<String, String> eventKey(String value) => _is.ColumnValue(
    table.eventKey,
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

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CommissionEntryTable extends _is.Table<int?> {
  CommissionEntryTable({super.tableRelation})
    : super(tableName: 'raysto_commission_entry') {
    updateTable = CommissionEntryUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    captureId = _is.ColumnInt(
      'captureId',
      this,
    );
    refundId = _is.ColumnInt(
      'refundId',
      this,
    );
    eventKey = _is.ColumnString(
      'eventKey',
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
    state = _is.ColumnString(
      'state',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final CommissionEntryUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt captureId;

  late final _is.ColumnInt refundId;

  late final _is.ColumnString eventKey;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString state;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    captureId,
    refundId,
    eventKey,
    amountMinor,
    currency,
    state,
    createdAt,
  ];
}

class CommissionEntryInclude extends _is.IncludeObject {
  CommissionEntryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CommissionEntry.t;
}

class CommissionEntryIncludeList extends _is.IncludeList {
  CommissionEntryIncludeList._({
    _is.WhereExpressionBuilder<CommissionEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CommissionEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CommissionEntry.t;
}

class CommissionEntryRepository {
  const CommissionEntryRepository._();

  /// Returns a list of [CommissionEntry]s matching the given query parameters.
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
  Future<List<CommissionEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CommissionEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CommissionEntryTable>? orderBy,
    _is.OrderByListBuilder<CommissionEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CommissionEntry>(
      where: where?.call(CommissionEntry.t),
      orderBy: orderBy?.call(CommissionEntry.t),
      orderByList: orderByList?.call(CommissionEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CommissionEntry] matching the given query parameters.
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
  Future<CommissionEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CommissionEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<CommissionEntryTable>? orderBy,
    _is.OrderByListBuilder<CommissionEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CommissionEntry>(
      where: where?.call(CommissionEntry.t),
      orderBy: orderBy?.call(CommissionEntry.t),
      orderByList: orderByList?.call(CommissionEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CommissionEntry] by its [id] or null if no such row exists.
  Future<CommissionEntry?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CommissionEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CommissionEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [CommissionEntry]s will have their `id` fields set.
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
  Future<List<CommissionEntry>> insert(
    _is.DatabaseSession session,
    List<CommissionEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CommissionEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CommissionEntry] and returns the inserted row.
  ///
  /// The returned [CommissionEntry] will have its `id` field set.
  Future<CommissionEntry> insertRow(
    _is.DatabaseSession session,
    CommissionEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CommissionEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CommissionEntry]s in the list and returns the resulting rows.
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
  /// The returned [CommissionEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CommissionEntry>> upsert(
    _is.DatabaseSession session,
    List<CommissionEntry> rows, {
    required _is.ColumnSelections<CommissionEntryTable> conflictColumns,
    _is.ColumnSelections<CommissionEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<CommissionEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CommissionEntry>(
      rows,
      conflictColumns: conflictColumns(CommissionEntry.t),
      updateColumns: updateColumns?.call(CommissionEntry.t),
      updateWhere: updateWhere?.call(CommissionEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CommissionEntry] and returns the resulting row.
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
  /// The returned [CommissionEntry] will have its `id` field set.
  Future<CommissionEntry?> upsertRow(
    _is.DatabaseSession session,
    CommissionEntry row, {
    required _is.ColumnSelections<CommissionEntryTable> conflictColumns,
    _is.ColumnSelections<CommissionEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<CommissionEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CommissionEntry>(
      row,
      conflictColumns: conflictColumns(CommissionEntry.t),
      updateColumns: updateColumns?.call(CommissionEntry.t),
      updateWhere: updateWhere?.call(CommissionEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [CommissionEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CommissionEntry>> update(
    _is.DatabaseSession session,
    List<CommissionEntry> rows, {
    _is.ColumnSelections<CommissionEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CommissionEntry>(
      rows,
      columns: columns?.call(CommissionEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CommissionEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CommissionEntry> updateRow(
    _is.DatabaseSession session,
    CommissionEntry row, {
    _is.ColumnSelections<CommissionEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CommissionEntry>(
      row,
      columns: columns?.call(CommissionEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CommissionEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CommissionEntry?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CommissionEntryUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CommissionEntry>(
      id,
      columnValues: columnValues(CommissionEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CommissionEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CommissionEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CommissionEntryUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CommissionEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CommissionEntryTable>? orderBy,
    _is.OrderByListBuilder<CommissionEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CommissionEntry>(
      columnValues: columnValues(CommissionEntry.t.updateTable),
      where: where(CommissionEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CommissionEntry.t),
      orderByList: orderByList?.call(CommissionEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CommissionEntry]s in the list and returns the deleted rows.
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
  Future<List<CommissionEntry>> delete(
    _is.DatabaseSession session,
    List<CommissionEntry> rows, {
    _is.OrderByBuilder<CommissionEntryTable>? orderBy,
    _is.OrderByListBuilder<CommissionEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CommissionEntry>(
      rows,
      orderBy: orderBy?.call(CommissionEntry.t),
      orderByList: orderByList?.call(CommissionEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CommissionEntry].
  Future<CommissionEntry> deleteRow(
    _is.DatabaseSession session,
    CommissionEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CommissionEntry>(
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
  Future<List<CommissionEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CommissionEntryTable> where,
    _is.OrderByBuilder<CommissionEntryTable>? orderBy,
    _is.OrderByListBuilder<CommissionEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CommissionEntry>(
      where: where(CommissionEntry.t),
      orderBy: orderBy?.call(CommissionEntry.t),
      orderByList: orderByList?.call(CommissionEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CommissionEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CommissionEntry>(
      where: where?.call(CommissionEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CommissionEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CommissionEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CommissionEntry>(
      where: where(CommissionEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
