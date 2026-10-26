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

abstract class MutationReceipt
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MutationReceipt._({
    this.id,
    required this.userId,
    required this.requestKey,
    required this.operation,
    required this.requestHash,
    required this.resultJson,
    required this.createdAt,
  });

  factory MutationReceipt({
    int? id,
    required String userId,
    required String requestKey,
    required String operation,
    required String requestHash,
    required String resultJson,
    required DateTime createdAt,
  }) = _MutationReceiptImpl;

  factory MutationReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return MutationReceipt(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      requestKey: jsonSerialization['requestKey'] as String,
      operation: jsonSerialization['operation'] as String,
      requestHash: jsonSerialization['requestHash'] as String,
      resultJson: jsonSerialization['resultJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MutationReceiptTable();

  static const db = MutationReceiptRepository._();

  @override
  int? id;

  String userId;

  String requestKey;

  String operation;

  String requestHash;

  String resultJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MutationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MutationReceipt copyWith({
    int? id,
    String? userId,
    String? requestKey,
    String? operation,
    String? requestHash,
    String? resultJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MutationReceipt',
      if (id != null) 'id': id,
      'userId': userId,
      'requestKey': requestKey,
      'operation': operation,
      'requestHash': requestHash,
      'resultJson': resultJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static MutationReceiptInclude include() {
    return MutationReceiptInclude._();
  }

  static MutationReceiptIncludeList includeList({
    _is.WhereExpressionBuilder<MutationReceiptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MutationReceiptTable>? orderBy,
    _is.OrderByListBuilder<MutationReceiptTable>? orderByList,
    MutationReceiptInclude? include,
  }) {
    return MutationReceiptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MutationReceipt.t),
      orderByList: orderByList?.call(MutationReceipt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MutationReceiptImpl extends MutationReceipt {
  _MutationReceiptImpl({
    int? id,
    required String userId,
    required String requestKey,
    required String operation,
    required String requestHash,
    required String resultJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         requestKey: requestKey,
         operation: operation,
         requestHash: requestHash,
         resultJson: resultJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MutationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MutationReceipt copyWith({
    Object? id = _Undefined,
    String? userId,
    String? requestKey,
    String? operation,
    String? requestHash,
    String? resultJson,
    DateTime? createdAt,
  }) {
    return MutationReceipt(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      requestKey: requestKey ?? this.requestKey,
      operation: operation ?? this.operation,
      requestHash: requestHash ?? this.requestHash,
      resultJson: resultJson ?? this.resultJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MutationReceiptUpdateTable extends _is.UpdateTable<MutationReceiptTable> {
  MutationReceiptUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<String, String> operation(String value) => _is.ColumnValue(
    table.operation,
    value,
  );

  _is.ColumnValue<String, String> requestHash(String value) => _is.ColumnValue(
    table.requestHash,
    value,
  );

  _is.ColumnValue<String, String> resultJson(String value) => _is.ColumnValue(
    table.resultJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MutationReceiptTable extends _is.Table<int?> {
  MutationReceiptTable({super.tableRelation})
    : super(tableName: 'raysto_mutation_receipt') {
    updateTable = MutationReceiptUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    operation = _is.ColumnString(
      'operation',
      this,
    );
    requestHash = _is.ColumnString(
      'requestHash',
      this,
    );
    resultJson = _is.ColumnString(
      'resultJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MutationReceiptUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnString operation;

  late final _is.ColumnString requestHash;

  late final _is.ColumnString resultJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    requestKey,
    operation,
    requestHash,
    resultJson,
    createdAt,
  ];
}

class MutationReceiptInclude extends _is.IncludeObject {
  MutationReceiptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MutationReceipt.t;
}

class MutationReceiptIncludeList extends _is.IncludeList {
  MutationReceiptIncludeList._({
    _is.WhereExpressionBuilder<MutationReceiptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MutationReceipt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MutationReceipt.t;
}

class MutationReceiptRepository {
  const MutationReceiptRepository._();

  /// Returns a list of [MutationReceipt]s matching the given query parameters.
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
  Future<List<MutationReceipt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MutationReceiptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MutationReceiptTable>? orderBy,
    _is.OrderByListBuilder<MutationReceiptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MutationReceipt>(
      where: where?.call(MutationReceipt.t),
      orderBy: orderBy?.call(MutationReceipt.t),
      orderByList: orderByList?.call(MutationReceipt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MutationReceipt] matching the given query parameters.
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
  Future<MutationReceipt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MutationReceiptTable>? where,
    int? offset,
    _is.OrderByBuilder<MutationReceiptTable>? orderBy,
    _is.OrderByListBuilder<MutationReceiptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MutationReceipt>(
      where: where?.call(MutationReceipt.t),
      orderBy: orderBy?.call(MutationReceipt.t),
      orderByList: orderByList?.call(MutationReceipt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MutationReceipt] by its [id] or null if no such row exists.
  Future<MutationReceipt?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MutationReceipt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MutationReceipt]s in the list and returns the inserted rows.
  ///
  /// The returned [MutationReceipt]s will have their `id` fields set.
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
  Future<List<MutationReceipt>> insert(
    _is.DatabaseSession session,
    List<MutationReceipt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MutationReceipt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MutationReceipt] and returns the inserted row.
  ///
  /// The returned [MutationReceipt] will have its `id` field set.
  Future<MutationReceipt> insertRow(
    _is.DatabaseSession session,
    MutationReceipt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MutationReceipt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MutationReceipt]s in the list and returns the resulting rows.
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
  /// The returned [MutationReceipt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MutationReceipt>> upsert(
    _is.DatabaseSession session,
    List<MutationReceipt> rows, {
    required _is.ColumnSelections<MutationReceiptTable> conflictColumns,
    _is.ColumnSelections<MutationReceiptTable>? updateColumns,
    _is.WhereExpressionBuilder<MutationReceiptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MutationReceipt>(
      rows,
      conflictColumns: conflictColumns(MutationReceipt.t),
      updateColumns: updateColumns?.call(MutationReceipt.t),
      updateWhere: updateWhere?.call(MutationReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MutationReceipt] and returns the resulting row.
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
  /// The returned [MutationReceipt] will have its `id` field set.
  Future<MutationReceipt?> upsertRow(
    _is.DatabaseSession session,
    MutationReceipt row, {
    required _is.ColumnSelections<MutationReceiptTable> conflictColumns,
    _is.ColumnSelections<MutationReceiptTable>? updateColumns,
    _is.WhereExpressionBuilder<MutationReceiptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MutationReceipt>(
      row,
      conflictColumns: conflictColumns(MutationReceipt.t),
      updateColumns: updateColumns?.call(MutationReceipt.t),
      updateWhere: updateWhere?.call(MutationReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates all [MutationReceipt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MutationReceipt>> update(
    _is.DatabaseSession session,
    List<MutationReceipt> rows, {
    _is.ColumnSelections<MutationReceiptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MutationReceipt>(
      rows,
      columns: columns?.call(MutationReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MutationReceipt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MutationReceipt> updateRow(
    _is.DatabaseSession session,
    MutationReceipt row, {
    _is.ColumnSelections<MutationReceiptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MutationReceipt>(
      row,
      columns: columns?.call(MutationReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MutationReceipt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MutationReceipt?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MutationReceiptUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MutationReceipt>(
      id,
      columnValues: columnValues(MutationReceipt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MutationReceipt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MutationReceipt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MutationReceiptUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<MutationReceiptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MutationReceiptTable>? orderBy,
    _is.OrderByListBuilder<MutationReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MutationReceipt>(
      columnValues: columnValues(MutationReceipt.t.updateTable),
      where: where(MutationReceipt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MutationReceipt.t),
      orderByList: orderByList?.call(MutationReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MutationReceipt]s in the list and returns the deleted rows.
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
  Future<List<MutationReceipt>> delete(
    _is.DatabaseSession session,
    List<MutationReceipt> rows, {
    _is.OrderByBuilder<MutationReceiptTable>? orderBy,
    _is.OrderByListBuilder<MutationReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MutationReceipt>(
      rows,
      orderBy: orderBy?.call(MutationReceipt.t),
      orderByList: orderByList?.call(MutationReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MutationReceipt].
  Future<MutationReceipt> deleteRow(
    _is.DatabaseSession session,
    MutationReceipt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MutationReceipt>(
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
  Future<List<MutationReceipt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MutationReceiptTable> where,
    _is.OrderByBuilder<MutationReceiptTable>? orderBy,
    _is.OrderByListBuilder<MutationReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MutationReceipt>(
      where: where(MutationReceipt.t),
      orderBy: orderBy?.call(MutationReceipt.t),
      orderByList: orderByList?.call(MutationReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MutationReceiptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MutationReceipt>(
      where: where?.call(MutationReceipt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MutationReceipt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MutationReceiptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MutationReceipt>(
      where: where(MutationReceipt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
