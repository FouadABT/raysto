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

abstract class ConversationRoom
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ConversationRoom._({
    this.id,
    required this.restaurantId,
    required this.contextKey,
    this.visitId,
    this.orderId,
    this.hostUserId,
    bool? hostEverAssigned,
    this.waiterUserId,
    required this.sequence,
    required this.version,
    required this.createdAt,
  }) : hostEverAssigned = hostEverAssigned ?? false;

  factory ConversationRoom({
    int? id,
    required int restaurantId,
    required String contextKey,
    int? visitId,
    int? orderId,
    String? hostUserId,
    bool? hostEverAssigned,
    String? waiterUserId,
    required int sequence,
    required int version,
    required DateTime createdAt,
  }) = _ConversationRoomImpl;

  factory ConversationRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConversationRoom(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      contextKey: jsonSerialization['contextKey'] as String,
      visitId: jsonSerialization['visitId'] as int?,
      orderId: jsonSerialization['orderId'] as int?,
      hostUserId: jsonSerialization['hostUserId'] as String?,
      hostEverAssigned: jsonSerialization['hostEverAssigned'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['hostEverAssigned'],
            ),
      waiterUserId: jsonSerialization['waiterUserId'] as String?,
      sequence: jsonSerialization['sequence'] as int,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ConversationRoomTable();

  static const db = ConversationRoomRepository._();

  @override
  int? id;

  int restaurantId;

  String contextKey;

  int? visitId;

  int? orderId;

  String? hostUserId;

  bool hostEverAssigned;

  String? waiterUserId;

  int sequence;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ConversationRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ConversationRoom copyWith({
    int? id,
    int? restaurantId,
    String? contextKey,
    int? visitId,
    int? orderId,
    String? hostUserId,
    bool? hostEverAssigned,
    String? waiterUserId,
    int? sequence,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConversationRoom',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'contextKey': contextKey,
      if (visitId != null) 'visitId': visitId,
      if (orderId != null) 'orderId': orderId,
      if (hostUserId != null) 'hostUserId': hostUserId,
      'hostEverAssigned': hostEverAssigned,
      if (waiterUserId != null) 'waiterUserId': waiterUserId,
      'sequence': sequence,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ConversationRoomInclude include() {
    return ConversationRoomInclude._();
  }

  static ConversationRoomIncludeList includeList({
    _is.WhereExpressionBuilder<ConversationRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ConversationRoomTable>? orderBy,
    _is.OrderByListBuilder<ConversationRoomTable>? orderByList,
    ConversationRoomInclude? include,
  }) {
    return ConversationRoomIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConversationRoom.t),
      orderByList: orderByList?.call(ConversationRoom.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConversationRoomImpl extends ConversationRoom {
  _ConversationRoomImpl({
    int? id,
    required int restaurantId,
    required String contextKey,
    int? visitId,
    int? orderId,
    String? hostUserId,
    bool? hostEverAssigned,
    String? waiterUserId,
    required int sequence,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         contextKey: contextKey,
         visitId: visitId,
         orderId: orderId,
         hostUserId: hostUserId,
         hostEverAssigned: hostEverAssigned,
         waiterUserId: waiterUserId,
         sequence: sequence,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ConversationRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ConversationRoom copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? contextKey,
    Object? visitId = _Undefined,
    Object? orderId = _Undefined,
    Object? hostUserId = _Undefined,
    bool? hostEverAssigned,
    Object? waiterUserId = _Undefined,
    int? sequence,
    int? version,
    DateTime? createdAt,
  }) {
    return ConversationRoom(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      contextKey: contextKey ?? this.contextKey,
      visitId: visitId is int? ? visitId : this.visitId,
      orderId: orderId is int? ? orderId : this.orderId,
      hostUserId: hostUserId is String? ? hostUserId : this.hostUserId,
      hostEverAssigned: hostEverAssigned ?? this.hostEverAssigned,
      waiterUserId: waiterUserId is String? ? waiterUserId : this.waiterUserId,
      sequence: sequence ?? this.sequence,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ConversationRoomUpdateTable
    extends _is.UpdateTable<ConversationRoomTable> {
  ConversationRoomUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> contextKey(String value) => _is.ColumnValue(
    table.contextKey,
    value,
  );

  _is.ColumnValue<int, int> visitId(int? value) => _is.ColumnValue(
    table.visitId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int? value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> hostUserId(String? value) => _is.ColumnValue(
    table.hostUserId,
    value,
  );

  _is.ColumnValue<bool, bool> hostEverAssigned(bool value) => _is.ColumnValue(
    table.hostEverAssigned,
    value,
  );

  _is.ColumnValue<String, String> waiterUserId(String? value) =>
      _is.ColumnValue(
        table.waiterUserId,
        value,
      );

  _is.ColumnValue<int, int> sequence(int value) => _is.ColumnValue(
    table.sequence,
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
}

class ConversationRoomTable extends _is.Table<int?> {
  ConversationRoomTable({super.tableRelation})
    : super(tableName: 'raysto_conversation_room') {
    updateTable = ConversationRoomUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    contextKey = _is.ColumnString(
      'contextKey',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    hostUserId = _is.ColumnString(
      'hostUserId',
      this,
    );
    hostEverAssigned = _is.ColumnBool(
      'hostEverAssigned',
      this,
      hasDefault: true,
    );
    waiterUserId = _is.ColumnString(
      'waiterUserId',
      this,
    );
    sequence = _is.ColumnInt(
      'sequence',
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
  }

  late final ConversationRoomUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString contextKey;

  late final _is.ColumnInt visitId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString hostUserId;

  late final _is.ColumnBool hostEverAssigned;

  late final _is.ColumnString waiterUserId;

  late final _is.ColumnInt sequence;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    contextKey,
    visitId,
    orderId,
    hostUserId,
    hostEverAssigned,
    waiterUserId,
    sequence,
    version,
    createdAt,
  ];
}

class ConversationRoomInclude extends _is.IncludeObject {
  ConversationRoomInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ConversationRoom.t;
}

class ConversationRoomIncludeList extends _is.IncludeList {
  ConversationRoomIncludeList._({
    _is.WhereExpressionBuilder<ConversationRoomTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ConversationRoom.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ConversationRoom.t;
}

class ConversationRoomRepository {
  const ConversationRoomRepository._();

  /// Returns a list of [ConversationRoom]s matching the given query parameters.
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
  Future<List<ConversationRoom>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ConversationRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ConversationRoomTable>? orderBy,
    _is.OrderByListBuilder<ConversationRoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ConversationRoom>(
      where: where?.call(ConversationRoom.t),
      orderBy: orderBy?.call(ConversationRoom.t),
      orderByList: orderByList?.call(ConversationRoom.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ConversationRoom] matching the given query parameters.
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
  Future<ConversationRoom?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ConversationRoomTable>? where,
    int? offset,
    _is.OrderByBuilder<ConversationRoomTable>? orderBy,
    _is.OrderByListBuilder<ConversationRoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ConversationRoom>(
      where: where?.call(ConversationRoom.t),
      orderBy: orderBy?.call(ConversationRoom.t),
      orderByList: orderByList?.call(ConversationRoom.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ConversationRoom] by its [id] or null if no such row exists.
  Future<ConversationRoom?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ConversationRoom>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ConversationRoom]s in the list and returns the inserted rows.
  ///
  /// The returned [ConversationRoom]s will have their `id` fields set.
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
  Future<List<ConversationRoom>> insert(
    _is.DatabaseSession session,
    List<ConversationRoom> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ConversationRoom>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ConversationRoom] and returns the inserted row.
  ///
  /// The returned [ConversationRoom] will have its `id` field set.
  Future<ConversationRoom> insertRow(
    _is.DatabaseSession session,
    ConversationRoom row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ConversationRoom>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ConversationRoom]s in the list and returns the resulting rows.
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
  /// The returned [ConversationRoom]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConversationRoom>> upsert(
    _is.DatabaseSession session,
    List<ConversationRoom> rows, {
    required _is.ColumnSelections<ConversationRoomTable> conflictColumns,
    _is.ColumnSelections<ConversationRoomTable>? updateColumns,
    _is.WhereExpressionBuilder<ConversationRoomTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ConversationRoom>(
      rows,
      conflictColumns: conflictColumns(ConversationRoom.t),
      updateColumns: updateColumns?.call(ConversationRoom.t),
      updateWhere: updateWhere?.call(ConversationRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ConversationRoom] and returns the resulting row.
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
  /// The returned [ConversationRoom] will have its `id` field set.
  Future<ConversationRoom?> upsertRow(
    _is.DatabaseSession session,
    ConversationRoom row, {
    required _is.ColumnSelections<ConversationRoomTable> conflictColumns,
    _is.ColumnSelections<ConversationRoomTable>? updateColumns,
    _is.WhereExpressionBuilder<ConversationRoomTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ConversationRoom>(
      row,
      conflictColumns: conflictColumns(ConversationRoom.t),
      updateColumns: updateColumns?.call(ConversationRoom.t),
      updateWhere: updateWhere?.call(ConversationRoom.t),
      transaction: transaction,
    );
  }

  /// Updates all [ConversationRoom]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConversationRoom>> update(
    _is.DatabaseSession session,
    List<ConversationRoom> rows, {
    _is.ColumnSelections<ConversationRoomTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ConversationRoom>(
      rows,
      columns: columns?.call(ConversationRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ConversationRoom]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ConversationRoom> updateRow(
    _is.DatabaseSession session,
    ConversationRoom row, {
    _is.ColumnSelections<ConversationRoomTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ConversationRoom>(
      row,
      columns: columns?.call(ConversationRoom.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConversationRoom] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ConversationRoom?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ConversationRoomUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ConversationRoom>(
      id,
      columnValues: columnValues(ConversationRoom.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ConversationRoom]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConversationRoom>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ConversationRoomUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ConversationRoomTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ConversationRoomTable>? orderBy,
    _is.OrderByListBuilder<ConversationRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ConversationRoom>(
      columnValues: columnValues(ConversationRoom.t.updateTable),
      where: where(ConversationRoom.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConversationRoom.t),
      orderByList: orderByList?.call(ConversationRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ConversationRoom]s in the list and returns the deleted rows.
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
  Future<List<ConversationRoom>> delete(
    _is.DatabaseSession session,
    List<ConversationRoom> rows, {
    _is.OrderByBuilder<ConversationRoomTable>? orderBy,
    _is.OrderByListBuilder<ConversationRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ConversationRoom>(
      rows,
      orderBy: orderBy?.call(ConversationRoom.t),
      orderByList: orderByList?.call(ConversationRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ConversationRoom].
  Future<ConversationRoom> deleteRow(
    _is.DatabaseSession session,
    ConversationRoom row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ConversationRoom>(
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
  Future<List<ConversationRoom>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ConversationRoomTable> where,
    _is.OrderByBuilder<ConversationRoomTable>? orderBy,
    _is.OrderByListBuilder<ConversationRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ConversationRoom>(
      where: where(ConversationRoom.t),
      orderBy: orderBy?.call(ConversationRoom.t),
      orderByList: orderByList?.call(ConversationRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ConversationRoomTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ConversationRoom>(
      where: where?.call(ConversationRoom.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ConversationRoom] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ConversationRoomTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ConversationRoom>(
      where: where(ConversationRoom.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
