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

abstract class PriceQuote
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PriceQuote._({
    this.id,
    required this.restaurantId,
    required this.userId,
    this.visitId,
    required this.snapshotJson,
    required this.menuVersion,
    required this.totalMinor,
    required this.currency,
    required this.expiresAt,
    this.consumedOrderId,
    this.assistantProposalId,
    required this.createdAt,
  });

  factory PriceQuote({
    int? id,
    required int restaurantId,
    required String userId,
    int? visitId,
    required String snapshotJson,
    required int menuVersion,
    required int totalMinor,
    required String currency,
    required DateTime expiresAt,
    int? consumedOrderId,
    int? assistantProposalId,
    required DateTime createdAt,
  }) = _PriceQuoteImpl;

  factory PriceQuote.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceQuote(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      visitId: jsonSerialization['visitId'] as int?,
      snapshotJson: jsonSerialization['snapshotJson'] as String,
      menuVersion: jsonSerialization['menuVersion'] as int,
      totalMinor: jsonSerialization['totalMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedOrderId: jsonSerialization['consumedOrderId'] as int?,
      assistantProposalId: jsonSerialization['assistantProposalId'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PriceQuoteTable();

  static const db = PriceQuoteRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  int? visitId;

  String snapshotJson;

  int menuVersion;

  int totalMinor;

  String currency;

  DateTime expiresAt;

  int? consumedOrderId;

  int? assistantProposalId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PriceQuote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PriceQuote copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    int? visitId,
    String? snapshotJson,
    int? menuVersion,
    int? totalMinor,
    String? currency,
    DateTime? expiresAt,
    int? consumedOrderId,
    int? assistantProposalId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceQuote',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      if (visitId != null) 'visitId': visitId,
      'snapshotJson': snapshotJson,
      'menuVersion': menuVersion,
      'totalMinor': totalMinor,
      'currency': currency,
      'expiresAt': expiresAt.toJson(),
      if (consumedOrderId != null) 'consumedOrderId': consumedOrderId,
      if (assistantProposalId != null)
        'assistantProposalId': assistantProposalId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PriceQuoteInclude include() {
    return PriceQuoteInclude._();
  }

  static PriceQuoteIncludeList includeList({
    _is.WhereExpressionBuilder<PriceQuoteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PriceQuoteTable>? orderBy,
    _is.OrderByListBuilder<PriceQuoteTable>? orderByList,
    PriceQuoteInclude? include,
  }) {
    return PriceQuoteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PriceQuote.t),
      orderByList: orderByList?.call(PriceQuote.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PriceQuoteImpl extends PriceQuote {
  _PriceQuoteImpl({
    int? id,
    required int restaurantId,
    required String userId,
    int? visitId,
    required String snapshotJson,
    required int menuVersion,
    required int totalMinor,
    required String currency,
    required DateTime expiresAt,
    int? consumedOrderId,
    int? assistantProposalId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         visitId: visitId,
         snapshotJson: snapshotJson,
         menuVersion: menuVersion,
         totalMinor: totalMinor,
         currency: currency,
         expiresAt: expiresAt,
         consumedOrderId: consumedOrderId,
         assistantProposalId: assistantProposalId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PriceQuote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PriceQuote copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    Object? visitId = _Undefined,
    String? snapshotJson,
    int? menuVersion,
    int? totalMinor,
    String? currency,
    DateTime? expiresAt,
    Object? consumedOrderId = _Undefined,
    Object? assistantProposalId = _Undefined,
    DateTime? createdAt,
  }) {
    return PriceQuote(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      visitId: visitId is int? ? visitId : this.visitId,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      menuVersion: menuVersion ?? this.menuVersion,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedOrderId: consumedOrderId is int?
          ? consumedOrderId
          : this.consumedOrderId,
      assistantProposalId: assistantProposalId is int?
          ? assistantProposalId
          : this.assistantProposalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PriceQuoteUpdateTable extends _is.UpdateTable<PriceQuoteTable> {
  PriceQuoteUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> visitId(int? value) => _is.ColumnValue(
    table.visitId,
    value,
  );

  _is.ColumnValue<String, String> snapshotJson(String value) => _is.ColumnValue(
    table.snapshotJson,
    value,
  );

  _is.ColumnValue<int, int> menuVersion(int value) => _is.ColumnValue(
    table.menuVersion,
    value,
  );

  _is.ColumnValue<int, int> totalMinor(int value) => _is.ColumnValue(
    table.totalMinor,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<int, int> consumedOrderId(int? value) => _is.ColumnValue(
    table.consumedOrderId,
    value,
  );

  _is.ColumnValue<int, int> assistantProposalId(int? value) => _is.ColumnValue(
    table.assistantProposalId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class PriceQuoteTable extends _is.Table<int?> {
  PriceQuoteTable({super.tableRelation})
    : super(tableName: 'raysto_price_quote') {
    updateTable = PriceQuoteUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
      this,
    );
    snapshotJson = _is.ColumnString(
      'snapshotJson',
      this,
    );
    menuVersion = _is.ColumnInt(
      'menuVersion',
      this,
    );
    totalMinor = _is.ColumnInt(
      'totalMinor',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    consumedOrderId = _is.ColumnInt(
      'consumedOrderId',
      this,
    );
    assistantProposalId = _is.ColumnInt(
      'assistantProposalId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PriceQuoteUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnInt visitId;

  late final _is.ColumnString snapshotJson;

  late final _is.ColumnInt menuVersion;

  late final _is.ColumnInt totalMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnInt consumedOrderId;

  late final _is.ColumnInt assistantProposalId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    visitId,
    snapshotJson,
    menuVersion,
    totalMinor,
    currency,
    expiresAt,
    consumedOrderId,
    assistantProposalId,
    createdAt,
  ];
}

class PriceQuoteInclude extends _is.IncludeObject {
  PriceQuoteInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PriceQuote.t;
}

class PriceQuoteIncludeList extends _is.IncludeList {
  PriceQuoteIncludeList._({
    _is.WhereExpressionBuilder<PriceQuoteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PriceQuote.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PriceQuote.t;
}

class PriceQuoteRepository {
  const PriceQuoteRepository._();

  /// Returns a list of [PriceQuote]s matching the given query parameters.
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
  Future<List<PriceQuote>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PriceQuoteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PriceQuoteTable>? orderBy,
    _is.OrderByListBuilder<PriceQuoteTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PriceQuote>(
      where: where?.call(PriceQuote.t),
      orderBy: orderBy?.call(PriceQuote.t),
      orderByList: orderByList?.call(PriceQuote.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PriceQuote] matching the given query parameters.
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
  Future<PriceQuote?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PriceQuoteTable>? where,
    int? offset,
    _is.OrderByBuilder<PriceQuoteTable>? orderBy,
    _is.OrderByListBuilder<PriceQuoteTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PriceQuote>(
      where: where?.call(PriceQuote.t),
      orderBy: orderBy?.call(PriceQuote.t),
      orderByList: orderByList?.call(PriceQuote.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PriceQuote] by its [id] or null if no such row exists.
  Future<PriceQuote?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PriceQuote>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PriceQuote]s in the list and returns the inserted rows.
  ///
  /// The returned [PriceQuote]s will have their `id` fields set.
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
  Future<List<PriceQuote>> insert(
    _is.DatabaseSession session,
    List<PriceQuote> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PriceQuote>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PriceQuote] and returns the inserted row.
  ///
  /// The returned [PriceQuote] will have its `id` field set.
  Future<PriceQuote> insertRow(
    _is.DatabaseSession session,
    PriceQuote row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PriceQuote>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PriceQuote]s in the list and returns the resulting rows.
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
  /// The returned [PriceQuote]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PriceQuote>> upsert(
    _is.DatabaseSession session,
    List<PriceQuote> rows, {
    required _is.ColumnSelections<PriceQuoteTable> conflictColumns,
    _is.ColumnSelections<PriceQuoteTable>? updateColumns,
    _is.WhereExpressionBuilder<PriceQuoteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PriceQuote>(
      rows,
      conflictColumns: conflictColumns(PriceQuote.t),
      updateColumns: updateColumns?.call(PriceQuote.t),
      updateWhere: updateWhere?.call(PriceQuote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PriceQuote] and returns the resulting row.
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
  /// The returned [PriceQuote] will have its `id` field set.
  Future<PriceQuote?> upsertRow(
    _is.DatabaseSession session,
    PriceQuote row, {
    required _is.ColumnSelections<PriceQuoteTable> conflictColumns,
    _is.ColumnSelections<PriceQuoteTable>? updateColumns,
    _is.WhereExpressionBuilder<PriceQuoteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PriceQuote>(
      row,
      conflictColumns: conflictColumns(PriceQuote.t),
      updateColumns: updateColumns?.call(PriceQuote.t),
      updateWhere: updateWhere?.call(PriceQuote.t),
      transaction: transaction,
    );
  }

  /// Updates all [PriceQuote]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PriceQuote>> update(
    _is.DatabaseSession session,
    List<PriceQuote> rows, {
    _is.ColumnSelections<PriceQuoteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PriceQuote>(
      rows,
      columns: columns?.call(PriceQuote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PriceQuote]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PriceQuote> updateRow(
    _is.DatabaseSession session,
    PriceQuote row, {
    _is.ColumnSelections<PriceQuoteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PriceQuote>(
      row,
      columns: columns?.call(PriceQuote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PriceQuote] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PriceQuote?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PriceQuoteUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PriceQuote>(
      id,
      columnValues: columnValues(PriceQuote.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PriceQuote]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PriceQuote>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PriceQuoteUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PriceQuoteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PriceQuoteTable>? orderBy,
    _is.OrderByListBuilder<PriceQuoteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PriceQuote>(
      columnValues: columnValues(PriceQuote.t.updateTable),
      where: where(PriceQuote.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PriceQuote.t),
      orderByList: orderByList?.call(PriceQuote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PriceQuote]s in the list and returns the deleted rows.
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
  Future<List<PriceQuote>> delete(
    _is.DatabaseSession session,
    List<PriceQuote> rows, {
    _is.OrderByBuilder<PriceQuoteTable>? orderBy,
    _is.OrderByListBuilder<PriceQuoteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PriceQuote>(
      rows,
      orderBy: orderBy?.call(PriceQuote.t),
      orderByList: orderByList?.call(PriceQuote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PriceQuote].
  Future<PriceQuote> deleteRow(
    _is.DatabaseSession session,
    PriceQuote row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PriceQuote>(
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
  Future<List<PriceQuote>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PriceQuoteTable> where,
    _is.OrderByBuilder<PriceQuoteTable>? orderBy,
    _is.OrderByListBuilder<PriceQuoteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PriceQuote>(
      where: where(PriceQuote.t),
      orderBy: orderBy?.call(PriceQuote.t),
      orderByList: orderByList?.call(PriceQuote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PriceQuoteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PriceQuote>(
      where: where?.call(PriceQuote.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PriceQuote] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PriceQuoteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PriceQuote>(
      where: where(PriceQuote.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
