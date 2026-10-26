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

abstract class RoomMessage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RoomMessage._({
    this.id,
    required this.restaurantId,
    required this.roomId,
    required this.sequence,
    this.userId,
    this.clientMessageId,
    this.replyToId,
    required this.kind,
    required this.bodyJson,
    required this.createdAt,
  });

  factory RoomMessage({
    int? id,
    required int restaurantId,
    required int roomId,
    required int sequence,
    String? userId,
    String? clientMessageId,
    int? replyToId,
    required String kind,
    required String bodyJson,
    required DateTime createdAt,
  }) = _RoomMessageImpl;

  factory RoomMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomMessage(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      roomId: jsonSerialization['roomId'] as int,
      sequence: jsonSerialization['sequence'] as int,
      userId: jsonSerialization['userId'] as String?,
      clientMessageId: jsonSerialization['clientMessageId'] as String?,
      replyToId: jsonSerialization['replyToId'] as int?,
      kind: jsonSerialization['kind'] as String,
      bodyJson: jsonSerialization['bodyJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = RoomMessageTable();

  static const db = RoomMessageRepository._();

  @override
  int? id;

  int restaurantId;

  int roomId;

  int sequence;

  String? userId;

  String? clientMessageId;

  int? replyToId;

  String kind;

  String bodyJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RoomMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RoomMessage copyWith({
    int? id,
    int? restaurantId,
    int? roomId,
    int? sequence,
    String? userId,
    String? clientMessageId,
    int? replyToId,
    String? kind,
    String? bodyJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomMessage',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'roomId': roomId,
      'sequence': sequence,
      if (userId != null) 'userId': userId,
      if (clientMessageId != null) 'clientMessageId': clientMessageId,
      if (replyToId != null) 'replyToId': replyToId,
      'kind': kind,
      'bodyJson': bodyJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RoomMessageInclude include() {
    return RoomMessageInclude._();
  }

  static RoomMessageIncludeList includeList({
    _is.WhereExpressionBuilder<RoomMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomMessageTable>? orderBy,
    _is.OrderByListBuilder<RoomMessageTable>? orderByList,
    RoomMessageInclude? include,
  }) {
    return RoomMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomMessage.t),
      orderByList: orderByList?.call(RoomMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomMessageImpl extends RoomMessage {
  _RoomMessageImpl({
    int? id,
    required int restaurantId,
    required int roomId,
    required int sequence,
    String? userId,
    String? clientMessageId,
    int? replyToId,
    required String kind,
    required String bodyJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         roomId: roomId,
         sequence: sequence,
         userId: userId,
         clientMessageId: clientMessageId,
         replyToId: replyToId,
         kind: kind,
         bodyJson: bodyJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [RoomMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RoomMessage copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? roomId,
    int? sequence,
    Object? userId = _Undefined,
    Object? clientMessageId = _Undefined,
    Object? replyToId = _Undefined,
    String? kind,
    String? bodyJson,
    DateTime? createdAt,
  }) {
    return RoomMessage(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      roomId: roomId ?? this.roomId,
      sequence: sequence ?? this.sequence,
      userId: userId is String? ? userId : this.userId,
      clientMessageId: clientMessageId is String?
          ? clientMessageId
          : this.clientMessageId,
      replyToId: replyToId is int? ? replyToId : this.replyToId,
      kind: kind ?? this.kind,
      bodyJson: bodyJson ?? this.bodyJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RoomMessageUpdateTable extends _is.UpdateTable<RoomMessageTable> {
  RoomMessageUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<int, int> sequence(int value) => _is.ColumnValue(
    table.sequence,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> clientMessageId(String? value) =>
      _is.ColumnValue(
        table.clientMessageId,
        value,
      );

  _is.ColumnValue<int, int> replyToId(int? value) => _is.ColumnValue(
    table.replyToId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> bodyJson(String value) => _is.ColumnValue(
    table.bodyJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class RoomMessageTable extends _is.Table<int?> {
  RoomMessageTable({super.tableRelation})
    : super(tableName: 'raysto_room_message') {
    updateTable = RoomMessageUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    sequence = _is.ColumnInt(
      'sequence',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    clientMessageId = _is.ColumnString(
      'clientMessageId',
      this,
    );
    replyToId = _is.ColumnInt(
      'replyToId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    bodyJson = _is.ColumnString(
      'bodyJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final RoomMessageUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt roomId;

  late final _is.ColumnInt sequence;

  late final _is.ColumnString userId;

  late final _is.ColumnString clientMessageId;

  late final _is.ColumnInt replyToId;

  late final _is.ColumnString kind;

  late final _is.ColumnString bodyJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    roomId,
    sequence,
    userId,
    clientMessageId,
    replyToId,
    kind,
    bodyJson,
    createdAt,
  ];
}

class RoomMessageInclude extends _is.IncludeObject {
  RoomMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RoomMessage.t;
}

class RoomMessageIncludeList extends _is.IncludeList {
  RoomMessageIncludeList._({
    _is.WhereExpressionBuilder<RoomMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoomMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RoomMessage.t;
}

class RoomMessageRepository {
  const RoomMessageRepository._();

  /// Returns a list of [RoomMessage]s matching the given query parameters.
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
  Future<List<RoomMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomMessageTable>? orderBy,
    _is.OrderByListBuilder<RoomMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoomMessage>(
      where: where?.call(RoomMessage.t),
      orderBy: orderBy?.call(RoomMessage.t),
      orderByList: orderByList?.call(RoomMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RoomMessage] matching the given query parameters.
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
  Future<RoomMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<RoomMessageTable>? orderBy,
    _is.OrderByListBuilder<RoomMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoomMessage>(
      where: where?.call(RoomMessage.t),
      orderBy: orderBy?.call(RoomMessage.t),
      orderByList: orderByList?.call(RoomMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoomMessage] by its [id] or null if no such row exists.
  Future<RoomMessage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoomMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoomMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [RoomMessage]s will have their `id` fields set.
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
  Future<List<RoomMessage>> insert(
    _is.DatabaseSession session,
    List<RoomMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RoomMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RoomMessage] and returns the inserted row.
  ///
  /// The returned [RoomMessage] will have its `id` field set.
  Future<RoomMessage> insertRow(
    _is.DatabaseSession session,
    RoomMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoomMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RoomMessage]s in the list and returns the resulting rows.
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
  /// The returned [RoomMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomMessage>> upsert(
    _is.DatabaseSession session,
    List<RoomMessage> rows, {
    required _is.ColumnSelections<RoomMessageTable> conflictColumns,
    _is.ColumnSelections<RoomMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RoomMessage>(
      rows,
      conflictColumns: conflictColumns(RoomMessage.t),
      updateColumns: updateColumns?.call(RoomMessage.t),
      updateWhere: updateWhere?.call(RoomMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RoomMessage] and returns the resulting row.
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
  /// The returned [RoomMessage] will have its `id` field set.
  Future<RoomMessage?> upsertRow(
    _is.DatabaseSession session,
    RoomMessage row, {
    required _is.ColumnSelections<RoomMessageTable> conflictColumns,
    _is.ColumnSelections<RoomMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RoomMessage>(
      row,
      conflictColumns: conflictColumns(RoomMessage.t),
      updateColumns: updateColumns?.call(RoomMessage.t),
      updateWhere: updateWhere?.call(RoomMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [RoomMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomMessage>> update(
    _is.DatabaseSession session,
    List<RoomMessage> rows, {
    _is.ColumnSelections<RoomMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RoomMessage>(
      rows,
      columns: columns?.call(RoomMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RoomMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoomMessage> updateRow(
    _is.DatabaseSession session,
    RoomMessage row, {
    _is.ColumnSelections<RoomMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoomMessage>(
      row,
      columns: columns?.call(RoomMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoomMessage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RoomMessageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RoomMessage>(
      id,
      columnValues: columnValues(RoomMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoomMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RoomMessageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RoomMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomMessageTable>? orderBy,
    _is.OrderByListBuilder<RoomMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RoomMessage>(
      columnValues: columnValues(RoomMessage.t.updateTable),
      where: where(RoomMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomMessage.t),
      orderByList: orderByList?.call(RoomMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RoomMessage]s in the list and returns the deleted rows.
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
  Future<List<RoomMessage>> delete(
    _is.DatabaseSession session,
    List<RoomMessage> rows, {
    _is.OrderByBuilder<RoomMessageTable>? orderBy,
    _is.OrderByListBuilder<RoomMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RoomMessage>(
      rows,
      orderBy: orderBy?.call(RoomMessage.t),
      orderByList: orderByList?.call(RoomMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RoomMessage].
  Future<RoomMessage> deleteRow(
    _is.DatabaseSession session,
    RoomMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoomMessage>(
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
  Future<List<RoomMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomMessageTable> where,
    _is.OrderByBuilder<RoomMessageTable>? orderBy,
    _is.OrderByListBuilder<RoomMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RoomMessage>(
      where: where(RoomMessage.t),
      orderBy: orderBy?.call(RoomMessage.t),
      orderByList: orderByList?.call(RoomMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RoomMessage>(
      where: where?.call(RoomMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoomMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoomMessage>(
      where: where(RoomMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
