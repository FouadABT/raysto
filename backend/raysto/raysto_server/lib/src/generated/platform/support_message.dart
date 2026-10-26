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

abstract class SupportMessage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SupportMessage._({
    this.id,
    required this.conversationId,
    required this.userId,
    required this.text,
    this.mediaId,
    required this.createdAt,
  });

  factory SupportMessage({
    int? id,
    required int conversationId,
    required String userId,
    required String text,
    int? mediaId,
    required DateTime createdAt,
  }) = _SupportMessageImpl;

  factory SupportMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return SupportMessage(
      id: jsonSerialization['id'] as int?,
      conversationId: jsonSerialization['conversationId'] as int,
      userId: jsonSerialization['userId'] as String,
      text: jsonSerialization['text'] as String,
      mediaId: jsonSerialization['mediaId'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SupportMessageTable();

  static const db = SupportMessageRepository._();

  @override
  int? id;

  int conversationId;

  String userId;

  String text;

  int? mediaId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SupportMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SupportMessage copyWith({
    int? id,
    int? conversationId,
    String? userId,
    String? text,
    int? mediaId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SupportMessage',
      if (id != null) 'id': id,
      'conversationId': conversationId,
      'userId': userId,
      'text': text,
      if (mediaId != null) 'mediaId': mediaId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SupportMessageInclude include() {
    return SupportMessageInclude._();
  }

  static SupportMessageIncludeList includeList({
    _is.WhereExpressionBuilder<SupportMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupportMessageTable>? orderBy,
    _is.OrderByListBuilder<SupportMessageTable>? orderByList,
    SupportMessageInclude? include,
  }) {
    return SupportMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupportMessage.t),
      orderByList: orderByList?.call(SupportMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SupportMessageImpl extends SupportMessage {
  _SupportMessageImpl({
    int? id,
    required int conversationId,
    required String userId,
    required String text,
    int? mediaId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         conversationId: conversationId,
         userId: userId,
         text: text,
         mediaId: mediaId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SupportMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SupportMessage copyWith({
    Object? id = _Undefined,
    int? conversationId,
    String? userId,
    String? text,
    Object? mediaId = _Undefined,
    DateTime? createdAt,
  }) {
    return SupportMessage(
      id: id is int? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      mediaId: mediaId is int? ? mediaId : this.mediaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SupportMessageUpdateTable extends _is.UpdateTable<SupportMessageTable> {
  SupportMessageUpdateTable(super.table);

  _is.ColumnValue<int, int> conversationId(int value) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<int, int> mediaId(int? value) => _is.ColumnValue(
    table.mediaId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SupportMessageTable extends _is.Table<int?> {
  SupportMessageTable({super.tableRelation})
    : super(tableName: 'raysto_support_message') {
    updateTable = SupportMessageUpdateTable(this);
    conversationId = _is.ColumnInt(
      'conversationId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    mediaId = _is.ColumnInt(
      'mediaId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SupportMessageUpdateTable updateTable;

  late final _is.ColumnInt conversationId;

  late final _is.ColumnString userId;

  late final _is.ColumnString text;

  late final _is.ColumnInt mediaId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    conversationId,
    userId,
    text,
    mediaId,
    createdAt,
  ];
}

class SupportMessageInclude extends _is.IncludeObject {
  SupportMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SupportMessage.t;
}

class SupportMessageIncludeList extends _is.IncludeList {
  SupportMessageIncludeList._({
    _is.WhereExpressionBuilder<SupportMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SupportMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SupportMessage.t;
}

class SupportMessageRepository {
  const SupportMessageRepository._();

  /// Returns a list of [SupportMessage]s matching the given query parameters.
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
  Future<List<SupportMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupportMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupportMessageTable>? orderBy,
    _is.OrderByListBuilder<SupportMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SupportMessage>(
      where: where?.call(SupportMessage.t),
      orderBy: orderBy?.call(SupportMessage.t),
      orderByList: orderByList?.call(SupportMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SupportMessage] matching the given query parameters.
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
  Future<SupportMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupportMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<SupportMessageTable>? orderBy,
    _is.OrderByListBuilder<SupportMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SupportMessage>(
      where: where?.call(SupportMessage.t),
      orderBy: orderBy?.call(SupportMessage.t),
      orderByList: orderByList?.call(SupportMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SupportMessage] by its [id] or null if no such row exists.
  Future<SupportMessage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SupportMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SupportMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [SupportMessage]s will have their `id` fields set.
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
  Future<List<SupportMessage>> insert(
    _is.DatabaseSession session,
    List<SupportMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SupportMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SupportMessage] and returns the inserted row.
  ///
  /// The returned [SupportMessage] will have its `id` field set.
  Future<SupportMessage> insertRow(
    _is.DatabaseSession session,
    SupportMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SupportMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SupportMessage]s in the list and returns the resulting rows.
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
  /// The returned [SupportMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupportMessage>> upsert(
    _is.DatabaseSession session,
    List<SupportMessage> rows, {
    required _is.ColumnSelections<SupportMessageTable> conflictColumns,
    _is.ColumnSelections<SupportMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<SupportMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SupportMessage>(
      rows,
      conflictColumns: conflictColumns(SupportMessage.t),
      updateColumns: updateColumns?.call(SupportMessage.t),
      updateWhere: updateWhere?.call(SupportMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SupportMessage] and returns the resulting row.
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
  /// The returned [SupportMessage] will have its `id` field set.
  Future<SupportMessage?> upsertRow(
    _is.DatabaseSession session,
    SupportMessage row, {
    required _is.ColumnSelections<SupportMessageTable> conflictColumns,
    _is.ColumnSelections<SupportMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<SupportMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SupportMessage>(
      row,
      conflictColumns: conflictColumns(SupportMessage.t),
      updateColumns: updateColumns?.call(SupportMessage.t),
      updateWhere: updateWhere?.call(SupportMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [SupportMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupportMessage>> update(
    _is.DatabaseSession session,
    List<SupportMessage> rows, {
    _is.ColumnSelections<SupportMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SupportMessage>(
      rows,
      columns: columns?.call(SupportMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SupportMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SupportMessage> updateRow(
    _is.DatabaseSession session,
    SupportMessage row, {
    _is.ColumnSelections<SupportMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SupportMessage>(
      row,
      columns: columns?.call(SupportMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SupportMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SupportMessage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SupportMessageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SupportMessage>(
      id,
      columnValues: columnValues(SupportMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SupportMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupportMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SupportMessageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SupportMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupportMessageTable>? orderBy,
    _is.OrderByListBuilder<SupportMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SupportMessage>(
      columnValues: columnValues(SupportMessage.t.updateTable),
      where: where(SupportMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupportMessage.t),
      orderByList: orderByList?.call(SupportMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SupportMessage]s in the list and returns the deleted rows.
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
  Future<List<SupportMessage>> delete(
    _is.DatabaseSession session,
    List<SupportMessage> rows, {
    _is.OrderByBuilder<SupportMessageTable>? orderBy,
    _is.OrderByListBuilder<SupportMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SupportMessage>(
      rows,
      orderBy: orderBy?.call(SupportMessage.t),
      orderByList: orderByList?.call(SupportMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SupportMessage].
  Future<SupportMessage> deleteRow(
    _is.DatabaseSession session,
    SupportMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SupportMessage>(
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
  Future<List<SupportMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupportMessageTable> where,
    _is.OrderByBuilder<SupportMessageTable>? orderBy,
    _is.OrderByListBuilder<SupportMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SupportMessage>(
      where: where(SupportMessage.t),
      orderBy: orderBy?.call(SupportMessage.t),
      orderByList: orderByList?.call(SupportMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupportMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SupportMessage>(
      where: where?.call(SupportMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SupportMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupportMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SupportMessage>(
      where: where(SupportMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
