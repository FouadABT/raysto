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

abstract class GroupVenue
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GroupVenue._({
    this.id,
    required this.groupId,
    required this.restaurantId,
    required this.attachedBy,
    required this.attachedAt,
  });

  factory GroupVenue({
    int? id,
    required int groupId,
    required int restaurantId,
    required String attachedBy,
    required DateTime attachedAt,
  }) = _GroupVenueImpl;

  factory GroupVenue.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupVenue(
      id: jsonSerialization['id'] as int?,
      groupId: jsonSerialization['groupId'] as int,
      restaurantId: jsonSerialization['restaurantId'] as int,
      attachedBy: jsonSerialization['attachedBy'] as String,
      attachedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['attachedAt'],
      ),
    );
  }

  static final t = GroupVenueTable();

  static const db = GroupVenueRepository._();

  @override
  int? id;

  int groupId;

  int restaurantId;

  String attachedBy;

  DateTime attachedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupVenue]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupVenue copyWith({
    int? id,
    int? groupId,
    int? restaurantId,
    String? attachedBy,
    DateTime? attachedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GroupVenue',
      if (id != null) 'id': id,
      'groupId': groupId,
      'restaurantId': restaurantId,
      'attachedBy': attachedBy,
      'attachedAt': attachedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static GroupVenueInclude include() {
    return GroupVenueInclude._();
  }

  static GroupVenueIncludeList includeList({
    _is.WhereExpressionBuilder<GroupVenueTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupVenueTable>? orderBy,
    _is.OrderByListBuilder<GroupVenueTable>? orderByList,
    GroupVenueInclude? include,
  }) {
    return GroupVenueIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupVenue.t),
      orderByList: orderByList?.call(GroupVenue.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupVenueImpl extends GroupVenue {
  _GroupVenueImpl({
    int? id,
    required int groupId,
    required int restaurantId,
    required String attachedBy,
    required DateTime attachedAt,
  }) : super._(
         id: id,
         groupId: groupId,
         restaurantId: restaurantId,
         attachedBy: attachedBy,
         attachedAt: attachedAt,
       );

  /// Returns a shallow copy of this [GroupVenue]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupVenue copyWith({
    Object? id = _Undefined,
    int? groupId,
    int? restaurantId,
    String? attachedBy,
    DateTime? attachedAt,
  }) {
    return GroupVenue(
      id: id is int? ? id : this.id,
      groupId: groupId ?? this.groupId,
      restaurantId: restaurantId ?? this.restaurantId,
      attachedBy: attachedBy ?? this.attachedBy,
      attachedAt: attachedAt ?? this.attachedAt,
    );
  }
}

class GroupVenueUpdateTable extends _is.UpdateTable<GroupVenueTable> {
  GroupVenueUpdateTable(super.table);

  _is.ColumnValue<int, int> groupId(int value) => _is.ColumnValue(
    table.groupId,
    value,
  );

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> attachedBy(String value) => _is.ColumnValue(
    table.attachedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> attachedAt(DateTime value) =>
      _is.ColumnValue(
        table.attachedAt,
        value,
      );
}

class GroupVenueTable extends _is.Table<int?> {
  GroupVenueTable({super.tableRelation})
    : super(tableName: 'raysto_group_venue') {
    updateTable = GroupVenueUpdateTable(this);
    groupId = _is.ColumnInt(
      'groupId',
      this,
    );
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    attachedBy = _is.ColumnString(
      'attachedBy',
      this,
    );
    attachedAt = _is.ColumnDateTime(
      'attachedAt',
      this,
    );
  }

  late final GroupVenueUpdateTable updateTable;

  late final _is.ColumnInt groupId;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString attachedBy;

  late final _is.ColumnDateTime attachedAt;

  @override
  List<_is.Column> get columns => [
    id,
    groupId,
    restaurantId,
    attachedBy,
    attachedAt,
  ];
}

class GroupVenueInclude extends _is.IncludeObject {
  GroupVenueInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GroupVenue.t;
}

class GroupVenueIncludeList extends _is.IncludeList {
  GroupVenueIncludeList._({
    _is.WhereExpressionBuilder<GroupVenueTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupVenue.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GroupVenue.t;
}

class GroupVenueRepository {
  const GroupVenueRepository._();

  /// Returns a list of [GroupVenue]s matching the given query parameters.
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
  Future<List<GroupVenue>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupVenueTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupVenueTable>? orderBy,
    _is.OrderByListBuilder<GroupVenueTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupVenue>(
      where: where?.call(GroupVenue.t),
      orderBy: orderBy?.call(GroupVenue.t),
      orderByList: orderByList?.call(GroupVenue.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupVenue] matching the given query parameters.
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
  Future<GroupVenue?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupVenueTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupVenueTable>? orderBy,
    _is.OrderByListBuilder<GroupVenueTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupVenue>(
      where: where?.call(GroupVenue.t),
      orderBy: orderBy?.call(GroupVenue.t),
      orderByList: orderByList?.call(GroupVenue.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupVenue] by its [id] or null if no such row exists.
  Future<GroupVenue?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupVenue>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupVenue]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupVenue]s will have their `id` fields set.
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
  Future<List<GroupVenue>> insert(
    _is.DatabaseSession session,
    List<GroupVenue> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupVenue>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupVenue] and returns the inserted row.
  ///
  /// The returned [GroupVenue] will have its `id` field set.
  Future<GroupVenue> insertRow(
    _is.DatabaseSession session,
    GroupVenue row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupVenue>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GroupVenue]s in the list and returns the resulting rows.
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
  /// The returned [GroupVenue]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupVenue>> upsert(
    _is.DatabaseSession session,
    List<GroupVenue> rows, {
    required _is.ColumnSelections<GroupVenueTable> conflictColumns,
    _is.ColumnSelections<GroupVenueTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupVenueTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupVenue>(
      rows,
      conflictColumns: conflictColumns(GroupVenue.t),
      updateColumns: updateColumns?.call(GroupVenue.t),
      updateWhere: updateWhere?.call(GroupVenue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupVenue] and returns the resulting row.
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
  /// The returned [GroupVenue] will have its `id` field set.
  Future<GroupVenue?> upsertRow(
    _is.DatabaseSession session,
    GroupVenue row, {
    required _is.ColumnSelections<GroupVenueTable> conflictColumns,
    _is.ColumnSelections<GroupVenueTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupVenueTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupVenue>(
      row,
      conflictColumns: conflictColumns(GroupVenue.t),
      updateColumns: updateColumns?.call(GroupVenue.t),
      updateWhere: updateWhere?.call(GroupVenue.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupVenue]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupVenue>> update(
    _is.DatabaseSession session,
    List<GroupVenue> rows, {
    _is.ColumnSelections<GroupVenueTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupVenue>(
      rows,
      columns: columns?.call(GroupVenue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupVenue]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupVenue> updateRow(
    _is.DatabaseSession session,
    GroupVenue row, {
    _is.ColumnSelections<GroupVenueTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupVenue>(
      row,
      columns: columns?.call(GroupVenue.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupVenue] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupVenue?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GroupVenueUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupVenue>(
      id,
      columnValues: columnValues(GroupVenue.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupVenue]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupVenue>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupVenueUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GroupVenueTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupVenueTable>? orderBy,
    _is.OrderByListBuilder<GroupVenueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupVenue>(
      columnValues: columnValues(GroupVenue.t.updateTable),
      where: where(GroupVenue.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupVenue.t),
      orderByList: orderByList?.call(GroupVenue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupVenue]s in the list and returns the deleted rows.
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
  Future<List<GroupVenue>> delete(
    _is.DatabaseSession session,
    List<GroupVenue> rows, {
    _is.OrderByBuilder<GroupVenueTable>? orderBy,
    _is.OrderByListBuilder<GroupVenueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupVenue>(
      rows,
      orderBy: orderBy?.call(GroupVenue.t),
      orderByList: orderByList?.call(GroupVenue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupVenue].
  Future<GroupVenue> deleteRow(
    _is.DatabaseSession session,
    GroupVenue row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupVenue>(
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
  Future<List<GroupVenue>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupVenueTable> where,
    _is.OrderByBuilder<GroupVenueTable>? orderBy,
    _is.OrderByListBuilder<GroupVenueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupVenue>(
      where: where(GroupVenue.t),
      orderBy: orderBy?.call(GroupVenue.t),
      orderByList: orderByList?.call(GroupVenue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupVenueTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupVenue>(
      where: where?.call(GroupVenue.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupVenue] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupVenueTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupVenue>(
      where: where(GroupVenue.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
