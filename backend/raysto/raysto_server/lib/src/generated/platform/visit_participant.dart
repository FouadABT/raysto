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

abstract class VisitParticipant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  VisitParticipant._({
    this.id,
    required this.restaurantId,
    required this.visitId,
    required this.userId,
    required this.active,
    required this.joinedAt,
  });

  factory VisitParticipant({
    int? id,
    required int restaurantId,
    required int visitId,
    required String userId,
    required bool active,
    required DateTime joinedAt,
  }) = _VisitParticipantImpl;

  factory VisitParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return VisitParticipant(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      visitId: jsonSerialization['visitId'] as int,
      userId: jsonSerialization['userId'] as String,
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      joinedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
    );
  }

  static final t = VisitParticipantTable();

  static const db = VisitParticipantRepository._();

  @override
  int? id;

  int restaurantId;

  int visitId;

  String userId;

  bool active;

  DateTime joinedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [VisitParticipant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  VisitParticipant copyWith({
    int? id,
    int? restaurantId,
    int? visitId,
    String? userId,
    bool? active,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VisitParticipant',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'visitId': visitId,
      'userId': userId,
      'active': active,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static VisitParticipantInclude include() {
    return VisitParticipantInclude._();
  }

  static VisitParticipantIncludeList includeList({
    _is.WhereExpressionBuilder<VisitParticipantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VisitParticipantTable>? orderBy,
    _is.OrderByListBuilder<VisitParticipantTable>? orderByList,
    VisitParticipantInclude? include,
  }) {
    return VisitParticipantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VisitParticipant.t),
      orderByList: orderByList?.call(VisitParticipant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VisitParticipantImpl extends VisitParticipant {
  _VisitParticipantImpl({
    int? id,
    required int restaurantId,
    required int visitId,
    required String userId,
    required bool active,
    required DateTime joinedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         visitId: visitId,
         userId: userId,
         active: active,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [VisitParticipant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  VisitParticipant copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? visitId,
    String? userId,
    bool? active,
    DateTime? joinedAt,
  }) {
    return VisitParticipant(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      visitId: visitId ?? this.visitId,
      userId: userId ?? this.userId,
      active: active ?? this.active,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class VisitParticipantUpdateTable
    extends _is.UpdateTable<VisitParticipantTable> {
  VisitParticipantUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> visitId(int value) => _is.ColumnValue(
    table.visitId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<bool, bool> active(bool value) => _is.ColumnValue(
    table.active,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );
}

class VisitParticipantTable extends _is.Table<int?> {
  VisitParticipantTable({super.tableRelation})
    : super(tableName: 'raysto_visit_participant') {
    updateTable = VisitParticipantUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    active = _is.ColumnBool(
      'active',
      this,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
    );
  }

  late final VisitParticipantUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt visitId;

  late final _is.ColumnString userId;

  late final _is.ColumnBool active;

  late final _is.ColumnDateTime joinedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    visitId,
    userId,
    active,
    joinedAt,
  ];
}

class VisitParticipantInclude extends _is.IncludeObject {
  VisitParticipantInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => VisitParticipant.t;
}

class VisitParticipantIncludeList extends _is.IncludeList {
  VisitParticipantIncludeList._({
    _is.WhereExpressionBuilder<VisitParticipantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(VisitParticipant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => VisitParticipant.t;
}

class VisitParticipantRepository {
  const VisitParticipantRepository._();

  /// Returns a list of [VisitParticipant]s matching the given query parameters.
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
  Future<List<VisitParticipant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VisitParticipantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VisitParticipantTable>? orderBy,
    _is.OrderByListBuilder<VisitParticipantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<VisitParticipant>(
      where: where?.call(VisitParticipant.t),
      orderBy: orderBy?.call(VisitParticipant.t),
      orderByList: orderByList?.call(VisitParticipant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [VisitParticipant] matching the given query parameters.
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
  Future<VisitParticipant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VisitParticipantTable>? where,
    int? offset,
    _is.OrderByBuilder<VisitParticipantTable>? orderBy,
    _is.OrderByListBuilder<VisitParticipantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<VisitParticipant>(
      where: where?.call(VisitParticipant.t),
      orderBy: orderBy?.call(VisitParticipant.t),
      orderByList: orderByList?.call(VisitParticipant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [VisitParticipant] by its [id] or null if no such row exists.
  Future<VisitParticipant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<VisitParticipant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [VisitParticipant]s in the list and returns the inserted rows.
  ///
  /// The returned [VisitParticipant]s will have their `id` fields set.
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
  Future<List<VisitParticipant>> insert(
    _is.DatabaseSession session,
    List<VisitParticipant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<VisitParticipant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [VisitParticipant] and returns the inserted row.
  ///
  /// The returned [VisitParticipant] will have its `id` field set.
  Future<VisitParticipant> insertRow(
    _is.DatabaseSession session,
    VisitParticipant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<VisitParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [VisitParticipant]s in the list and returns the resulting rows.
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
  /// The returned [VisitParticipant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VisitParticipant>> upsert(
    _is.DatabaseSession session,
    List<VisitParticipant> rows, {
    required _is.ColumnSelections<VisitParticipantTable> conflictColumns,
    _is.ColumnSelections<VisitParticipantTable>? updateColumns,
    _is.WhereExpressionBuilder<VisitParticipantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<VisitParticipant>(
      rows,
      conflictColumns: conflictColumns(VisitParticipant.t),
      updateColumns: updateColumns?.call(VisitParticipant.t),
      updateWhere: updateWhere?.call(VisitParticipant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [VisitParticipant] and returns the resulting row.
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
  /// The returned [VisitParticipant] will have its `id` field set.
  Future<VisitParticipant?> upsertRow(
    _is.DatabaseSession session,
    VisitParticipant row, {
    required _is.ColumnSelections<VisitParticipantTable> conflictColumns,
    _is.ColumnSelections<VisitParticipantTable>? updateColumns,
    _is.WhereExpressionBuilder<VisitParticipantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<VisitParticipant>(
      row,
      conflictColumns: conflictColumns(VisitParticipant.t),
      updateColumns: updateColumns?.call(VisitParticipant.t),
      updateWhere: updateWhere?.call(VisitParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates all [VisitParticipant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VisitParticipant>> update(
    _is.DatabaseSession session,
    List<VisitParticipant> rows, {
    _is.ColumnSelections<VisitParticipantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<VisitParticipant>(
      rows,
      columns: columns?.call(VisitParticipant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [VisitParticipant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<VisitParticipant> updateRow(
    _is.DatabaseSession session,
    VisitParticipant row, {
    _is.ColumnSelections<VisitParticipantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<VisitParticipant>(
      row,
      columns: columns?.call(VisitParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VisitParticipant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<VisitParticipant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<VisitParticipantUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<VisitParticipant>(
      id,
      columnValues: columnValues(VisitParticipant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [VisitParticipant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<VisitParticipant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<VisitParticipantUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<VisitParticipantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VisitParticipantTable>? orderBy,
    _is.OrderByListBuilder<VisitParticipantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<VisitParticipant>(
      columnValues: columnValues(VisitParticipant.t.updateTable),
      where: where(VisitParticipant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VisitParticipant.t),
      orderByList: orderByList?.call(VisitParticipant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [VisitParticipant]s in the list and returns the deleted rows.
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
  Future<List<VisitParticipant>> delete(
    _is.DatabaseSession session,
    List<VisitParticipant> rows, {
    _is.OrderByBuilder<VisitParticipantTable>? orderBy,
    _is.OrderByListBuilder<VisitParticipantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<VisitParticipant>(
      rows,
      orderBy: orderBy?.call(VisitParticipant.t),
      orderByList: orderByList?.call(VisitParticipant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [VisitParticipant].
  Future<VisitParticipant> deleteRow(
    _is.DatabaseSession session,
    VisitParticipant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<VisitParticipant>(
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
  Future<List<VisitParticipant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VisitParticipantTable> where,
    _is.OrderByBuilder<VisitParticipantTable>? orderBy,
    _is.OrderByListBuilder<VisitParticipantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<VisitParticipant>(
      where: where(VisitParticipant.t),
      orderBy: orderBy?.call(VisitParticipant.t),
      orderByList: orderByList?.call(VisitParticipant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VisitParticipantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<VisitParticipant>(
      where: where?.call(VisitParticipant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [VisitParticipant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VisitParticipantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<VisitParticipant>(
      where: where(VisitParticipant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
