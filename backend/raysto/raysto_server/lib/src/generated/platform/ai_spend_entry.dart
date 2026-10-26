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

abstract class AiSpendEntry
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AiSpendEntry._({
    this.id,
    required this.sourceKey,
    required this.stage,
    required this.reservedMicros,
    required this.chargedMicros,
    required this.settled,
    required this.createdAt,
  });

  factory AiSpendEntry({
    int? id,
    required String sourceKey,
    required String stage,
    required int reservedMicros,
    required int chargedMicros,
    required bool settled,
    required DateTime createdAt,
  }) = _AiSpendEntryImpl;

  factory AiSpendEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiSpendEntry(
      id: jsonSerialization['id'] as int?,
      sourceKey: jsonSerialization['sourceKey'] as String,
      stage: jsonSerialization['stage'] as String,
      reservedMicros: jsonSerialization['reservedMicros'] as int,
      chargedMicros: jsonSerialization['chargedMicros'] as int,
      settled: _is.BoolJsonExtension.fromJson(jsonSerialization['settled']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AiSpendEntryTable();

  static const db = AiSpendEntryRepository._();

  @override
  int? id;

  String sourceKey;

  String stage;

  int reservedMicros;

  int chargedMicros;

  bool settled;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AiSpendEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AiSpendEntry copyWith({
    int? id,
    String? sourceKey,
    String? stage,
    int? reservedMicros,
    int? chargedMicros,
    bool? settled,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiSpendEntry',
      if (id != null) 'id': id,
      'sourceKey': sourceKey,
      'stage': stage,
      'reservedMicros': reservedMicros,
      'chargedMicros': chargedMicros,
      'settled': settled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AiSpendEntryInclude include() {
    return AiSpendEntryInclude._();
  }

  static AiSpendEntryIncludeList includeList({
    _is.WhereExpressionBuilder<AiSpendEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AiSpendEntryTable>? orderBy,
    _is.OrderByListBuilder<AiSpendEntryTable>? orderByList,
    AiSpendEntryInclude? include,
  }) {
    return AiSpendEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiSpendEntry.t),
      orderByList: orderByList?.call(AiSpendEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiSpendEntryImpl extends AiSpendEntry {
  _AiSpendEntryImpl({
    int? id,
    required String sourceKey,
    required String stage,
    required int reservedMicros,
    required int chargedMicros,
    required bool settled,
    required DateTime createdAt,
  }) : super._(
         id: id,
         sourceKey: sourceKey,
         stage: stage,
         reservedMicros: reservedMicros,
         chargedMicros: chargedMicros,
         settled: settled,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AiSpendEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AiSpendEntry copyWith({
    Object? id = _Undefined,
    String? sourceKey,
    String? stage,
    int? reservedMicros,
    int? chargedMicros,
    bool? settled,
    DateTime? createdAt,
  }) {
    return AiSpendEntry(
      id: id is int? ? id : this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      stage: stage ?? this.stage,
      reservedMicros: reservedMicros ?? this.reservedMicros,
      chargedMicros: chargedMicros ?? this.chargedMicros,
      settled: settled ?? this.settled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AiSpendEntryUpdateTable extends _is.UpdateTable<AiSpendEntryTable> {
  AiSpendEntryUpdateTable(super.table);

  _is.ColumnValue<String, String> sourceKey(String value) => _is.ColumnValue(
    table.sourceKey,
    value,
  );

  _is.ColumnValue<String, String> stage(String value) => _is.ColumnValue(
    table.stage,
    value,
  );

  _is.ColumnValue<int, int> reservedMicros(int value) => _is.ColumnValue(
    table.reservedMicros,
    value,
  );

  _is.ColumnValue<int, int> chargedMicros(int value) => _is.ColumnValue(
    table.chargedMicros,
    value,
  );

  _is.ColumnValue<bool, bool> settled(bool value) => _is.ColumnValue(
    table.settled,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AiSpendEntryTable extends _is.Table<int?> {
  AiSpendEntryTable({super.tableRelation})
    : super(tableName: 'raysto_ai_spend_entry') {
    updateTable = AiSpendEntryUpdateTable(this);
    sourceKey = _is.ColumnString(
      'sourceKey',
      this,
    );
    stage = _is.ColumnString(
      'stage',
      this,
    );
    reservedMicros = _is.ColumnInt(
      'reservedMicros',
      this,
    );
    chargedMicros = _is.ColumnInt(
      'chargedMicros',
      this,
    );
    settled = _is.ColumnBool(
      'settled',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final AiSpendEntryUpdateTable updateTable;

  late final _is.ColumnString sourceKey;

  late final _is.ColumnString stage;

  late final _is.ColumnInt reservedMicros;

  late final _is.ColumnInt chargedMicros;

  late final _is.ColumnBool settled;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    sourceKey,
    stage,
    reservedMicros,
    chargedMicros,
    settled,
    createdAt,
  ];
}

class AiSpendEntryInclude extends _is.IncludeObject {
  AiSpendEntryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AiSpendEntry.t;
}

class AiSpendEntryIncludeList extends _is.IncludeList {
  AiSpendEntryIncludeList._({
    _is.WhereExpressionBuilder<AiSpendEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiSpendEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AiSpendEntry.t;
}

class AiSpendEntryRepository {
  const AiSpendEntryRepository._();

  /// Returns a list of [AiSpendEntry]s matching the given query parameters.
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
  Future<List<AiSpendEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AiSpendEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AiSpendEntryTable>? orderBy,
    _is.OrderByListBuilder<AiSpendEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiSpendEntry>(
      where: where?.call(AiSpendEntry.t),
      orderBy: orderBy?.call(AiSpendEntry.t),
      orderByList: orderByList?.call(AiSpendEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiSpendEntry] matching the given query parameters.
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
  Future<AiSpendEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AiSpendEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<AiSpendEntryTable>? orderBy,
    _is.OrderByListBuilder<AiSpendEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiSpendEntry>(
      where: where?.call(AiSpendEntry.t),
      orderBy: orderBy?.call(AiSpendEntry.t),
      orderByList: orderByList?.call(AiSpendEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiSpendEntry] by its [id] or null if no such row exists.
  Future<AiSpendEntry?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiSpendEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiSpendEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [AiSpendEntry]s will have their `id` fields set.
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
  Future<List<AiSpendEntry>> insert(
    _is.DatabaseSession session,
    List<AiSpendEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AiSpendEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AiSpendEntry] and returns the inserted row.
  ///
  /// The returned [AiSpendEntry] will have its `id` field set.
  Future<AiSpendEntry> insertRow(
    _is.DatabaseSession session,
    AiSpendEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiSpendEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AiSpendEntry]s in the list and returns the resulting rows.
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
  /// The returned [AiSpendEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AiSpendEntry>> upsert(
    _is.DatabaseSession session,
    List<AiSpendEntry> rows, {
    required _is.ColumnSelections<AiSpendEntryTable> conflictColumns,
    _is.ColumnSelections<AiSpendEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<AiSpendEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AiSpendEntry>(
      rows,
      conflictColumns: conflictColumns(AiSpendEntry.t),
      updateColumns: updateColumns?.call(AiSpendEntry.t),
      updateWhere: updateWhere?.call(AiSpendEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AiSpendEntry] and returns the resulting row.
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
  /// The returned [AiSpendEntry] will have its `id` field set.
  Future<AiSpendEntry?> upsertRow(
    _is.DatabaseSession session,
    AiSpendEntry row, {
    required _is.ColumnSelections<AiSpendEntryTable> conflictColumns,
    _is.ColumnSelections<AiSpendEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<AiSpendEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AiSpendEntry>(
      row,
      conflictColumns: conflictColumns(AiSpendEntry.t),
      updateColumns: updateColumns?.call(AiSpendEntry.t),
      updateWhere: updateWhere?.call(AiSpendEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [AiSpendEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AiSpendEntry>> update(
    _is.DatabaseSession session,
    List<AiSpendEntry> rows, {
    _is.ColumnSelections<AiSpendEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AiSpendEntry>(
      rows,
      columns: columns?.call(AiSpendEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AiSpendEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiSpendEntry> updateRow(
    _is.DatabaseSession session,
    AiSpendEntry row, {
    _is.ColumnSelections<AiSpendEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiSpendEntry>(
      row,
      columns: columns?.call(AiSpendEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiSpendEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiSpendEntry?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AiSpendEntryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AiSpendEntry>(
      id,
      columnValues: columnValues(AiSpendEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiSpendEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AiSpendEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AiSpendEntryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AiSpendEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AiSpendEntryTable>? orderBy,
    _is.OrderByListBuilder<AiSpendEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AiSpendEntry>(
      columnValues: columnValues(AiSpendEntry.t.updateTable),
      where: where(AiSpendEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiSpendEntry.t),
      orderByList: orderByList?.call(AiSpendEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AiSpendEntry]s in the list and returns the deleted rows.
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
  Future<List<AiSpendEntry>> delete(
    _is.DatabaseSession session,
    List<AiSpendEntry> rows, {
    _is.OrderByBuilder<AiSpendEntryTable>? orderBy,
    _is.OrderByListBuilder<AiSpendEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AiSpendEntry>(
      rows,
      orderBy: orderBy?.call(AiSpendEntry.t),
      orderByList: orderByList?.call(AiSpendEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AiSpendEntry].
  Future<AiSpendEntry> deleteRow(
    _is.DatabaseSession session,
    AiSpendEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiSpendEntry>(
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
  Future<List<AiSpendEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AiSpendEntryTable> where,
    _is.OrderByBuilder<AiSpendEntryTable>? orderBy,
    _is.OrderByListBuilder<AiSpendEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AiSpendEntry>(
      where: where(AiSpendEntry.t),
      orderBy: orderBy?.call(AiSpendEntry.t),
      orderByList: orderByList?.call(AiSpendEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AiSpendEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AiSpendEntry>(
      where: where?.call(AiSpendEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiSpendEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AiSpendEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiSpendEntry>(
      where: where(AiSpendEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
