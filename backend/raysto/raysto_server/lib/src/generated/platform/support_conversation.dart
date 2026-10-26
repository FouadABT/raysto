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

abstract class SupportConversation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SupportConversation._({
    this.id,
    this.restaurantId,
    this.orderId,
    required this.userId,
    required this.status,
    required this.subject,
    required this.escalated,
    required this.version,
    required this.createdAt,
  });

  factory SupportConversation({
    int? id,
    int? restaurantId,
    int? orderId,
    required String userId,
    required String status,
    required String subject,
    required bool escalated,
    required int version,
    required DateTime createdAt,
  }) = _SupportConversationImpl;

  factory SupportConversation.fromJson(Map<String, dynamic> jsonSerialization) {
    return SupportConversation(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int?,
      orderId: jsonSerialization['orderId'] as int?,
      userId: jsonSerialization['userId'] as String,
      status: jsonSerialization['status'] as String,
      subject: jsonSerialization['subject'] as String,
      escalated: _is.BoolJsonExtension.fromJson(jsonSerialization['escalated']),
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SupportConversationTable();

  static const db = SupportConversationRepository._();

  @override
  int? id;

  int? restaurantId;

  int? orderId;

  String userId;

  String status;

  String subject;

  bool escalated;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SupportConversation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SupportConversation copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    String? userId,
    String? status,
    String? subject,
    bool? escalated,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SupportConversation',
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (orderId != null) 'orderId': orderId,
      'userId': userId,
      'status': status,
      'subject': subject,
      'escalated': escalated,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SupportConversationInclude include() {
    return SupportConversationInclude._();
  }

  static SupportConversationIncludeList includeList({
    _is.WhereExpressionBuilder<SupportConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupportConversationTable>? orderBy,
    _is.OrderByListBuilder<SupportConversationTable>? orderByList,
    SupportConversationInclude? include,
  }) {
    return SupportConversationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupportConversation.t),
      orderByList: orderByList?.call(SupportConversation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SupportConversationImpl extends SupportConversation {
  _SupportConversationImpl({
    int? id,
    int? restaurantId,
    int? orderId,
    required String userId,
    required String status,
    required String subject,
    required bool escalated,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         userId: userId,
         status: status,
         subject: subject,
         escalated: escalated,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SupportConversation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SupportConversation copyWith({
    Object? id = _Undefined,
    Object? restaurantId = _Undefined,
    Object? orderId = _Undefined,
    String? userId,
    String? status,
    String? subject,
    bool? escalated,
    int? version,
    DateTime? createdAt,
  }) {
    return SupportConversation(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId is int? ? restaurantId : this.restaurantId,
      orderId: orderId is int? ? orderId : this.orderId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      escalated: escalated ?? this.escalated,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SupportConversationUpdateTable
    extends _is.UpdateTable<SupportConversationTable> {
  SupportConversationUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int? value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int? value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> subject(String value) => _is.ColumnValue(
    table.subject,
    value,
  );

  _is.ColumnValue<bool, bool> escalated(bool value) => _is.ColumnValue(
    table.escalated,
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

class SupportConversationTable extends _is.Table<int?> {
  SupportConversationTable({super.tableRelation})
    : super(tableName: 'raysto_support_conversation') {
    updateTable = SupportConversationUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    subject = _is.ColumnString(
      'subject',
      this,
    );
    escalated = _is.ColumnBool(
      'escalated',
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

  late final SupportConversationUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString userId;

  late final _is.ColumnString status;

  late final _is.ColumnString subject;

  late final _is.ColumnBool escalated;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    userId,
    status,
    subject,
    escalated,
    version,
    createdAt,
  ];
}

class SupportConversationInclude extends _is.IncludeObject {
  SupportConversationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SupportConversation.t;
}

class SupportConversationIncludeList extends _is.IncludeList {
  SupportConversationIncludeList._({
    _is.WhereExpressionBuilder<SupportConversationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SupportConversation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SupportConversation.t;
}

class SupportConversationRepository {
  const SupportConversationRepository._();

  /// Returns a list of [SupportConversation]s matching the given query parameters.
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
  Future<List<SupportConversation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupportConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupportConversationTable>? orderBy,
    _is.OrderByListBuilder<SupportConversationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SupportConversation>(
      where: where?.call(SupportConversation.t),
      orderBy: orderBy?.call(SupportConversation.t),
      orderByList: orderByList?.call(SupportConversation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SupportConversation] matching the given query parameters.
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
  Future<SupportConversation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupportConversationTable>? where,
    int? offset,
    _is.OrderByBuilder<SupportConversationTable>? orderBy,
    _is.OrderByListBuilder<SupportConversationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SupportConversation>(
      where: where?.call(SupportConversation.t),
      orderBy: orderBy?.call(SupportConversation.t),
      orderByList: orderByList?.call(SupportConversation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SupportConversation] by its [id] or null if no such row exists.
  Future<SupportConversation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SupportConversation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SupportConversation]s in the list and returns the inserted rows.
  ///
  /// The returned [SupportConversation]s will have their `id` fields set.
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
  Future<List<SupportConversation>> insert(
    _is.DatabaseSession session,
    List<SupportConversation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SupportConversation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SupportConversation] and returns the inserted row.
  ///
  /// The returned [SupportConversation] will have its `id` field set.
  Future<SupportConversation> insertRow(
    _is.DatabaseSession session,
    SupportConversation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SupportConversation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SupportConversation]s in the list and returns the resulting rows.
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
  /// The returned [SupportConversation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupportConversation>> upsert(
    _is.DatabaseSession session,
    List<SupportConversation> rows, {
    required _is.ColumnSelections<SupportConversationTable> conflictColumns,
    _is.ColumnSelections<SupportConversationTable>? updateColumns,
    _is.WhereExpressionBuilder<SupportConversationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SupportConversation>(
      rows,
      conflictColumns: conflictColumns(SupportConversation.t),
      updateColumns: updateColumns?.call(SupportConversation.t),
      updateWhere: updateWhere?.call(SupportConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SupportConversation] and returns the resulting row.
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
  /// The returned [SupportConversation] will have its `id` field set.
  Future<SupportConversation?> upsertRow(
    _is.DatabaseSession session,
    SupportConversation row, {
    required _is.ColumnSelections<SupportConversationTable> conflictColumns,
    _is.ColumnSelections<SupportConversationTable>? updateColumns,
    _is.WhereExpressionBuilder<SupportConversationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SupportConversation>(
      row,
      conflictColumns: conflictColumns(SupportConversation.t),
      updateColumns: updateColumns?.call(SupportConversation.t),
      updateWhere: updateWhere?.call(SupportConversation.t),
      transaction: transaction,
    );
  }

  /// Updates all [SupportConversation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupportConversation>> update(
    _is.DatabaseSession session,
    List<SupportConversation> rows, {
    _is.ColumnSelections<SupportConversationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SupportConversation>(
      rows,
      columns: columns?.call(SupportConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SupportConversation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SupportConversation> updateRow(
    _is.DatabaseSession session,
    SupportConversation row, {
    _is.ColumnSelections<SupportConversationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SupportConversation>(
      row,
      columns: columns?.call(SupportConversation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SupportConversation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SupportConversation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SupportConversationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SupportConversation>(
      id,
      columnValues: columnValues(SupportConversation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SupportConversation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupportConversation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SupportConversationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<SupportConversationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupportConversationTable>? orderBy,
    _is.OrderByListBuilder<SupportConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SupportConversation>(
      columnValues: columnValues(SupportConversation.t.updateTable),
      where: where(SupportConversation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupportConversation.t),
      orderByList: orderByList?.call(SupportConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SupportConversation]s in the list and returns the deleted rows.
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
  Future<List<SupportConversation>> delete(
    _is.DatabaseSession session,
    List<SupportConversation> rows, {
    _is.OrderByBuilder<SupportConversationTable>? orderBy,
    _is.OrderByListBuilder<SupportConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SupportConversation>(
      rows,
      orderBy: orderBy?.call(SupportConversation.t),
      orderByList: orderByList?.call(SupportConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SupportConversation].
  Future<SupportConversation> deleteRow(
    _is.DatabaseSession session,
    SupportConversation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SupportConversation>(
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
  Future<List<SupportConversation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupportConversationTable> where,
    _is.OrderByBuilder<SupportConversationTable>? orderBy,
    _is.OrderByListBuilder<SupportConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SupportConversation>(
      where: where(SupportConversation.t),
      orderBy: orderBy?.call(SupportConversation.t),
      orderByList: orderByList?.call(SupportConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupportConversationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SupportConversation>(
      where: where?.call(SupportConversation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SupportConversation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupportConversationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SupportConversation>(
      where: where(SupportConversation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
