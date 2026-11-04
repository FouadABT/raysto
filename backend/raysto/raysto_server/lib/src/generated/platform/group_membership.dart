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

abstract class GroupMembership
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GroupMembership._({
    this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.active,
    required this.version,
    required this.createdAt,
  });

  factory GroupMembership({
    int? id,
    required int groupId,
    required String userId,
    required String role,
    required bool active,
    required int version,
    required DateTime createdAt,
  }) = _GroupMembershipImpl;

  factory GroupMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMembership(
      id: jsonSerialization['id'] as int?,
      groupId: jsonSerialization['groupId'] as int,
      userId: jsonSerialization['userId'] as String,
      role: jsonSerialization['role'] as String,
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = GroupMembershipTable();

  static const db = GroupMembershipRepository._();

  @override
  int? id;

  int groupId;

  String userId;

  String role;

  bool active;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupMembership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupMembership copyWith({
    int? id,
    int? groupId,
    String? userId,
    String? role,
    bool? active,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GroupMembership',
      if (id != null) 'id': id,
      'groupId': groupId,
      'userId': userId,
      'role': role,
      'active': active,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static GroupMembershipInclude include() {
    return GroupMembershipInclude._();
  }

  static GroupMembershipIncludeList includeList({
    _is.WhereExpressionBuilder<GroupMembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMembershipTable>? orderBy,
    _is.OrderByListBuilder<GroupMembershipTable>? orderByList,
    GroupMembershipInclude? include,
  }) {
    return GroupMembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMembership.t),
      orderByList: orderByList?.call(GroupMembership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMembershipImpl extends GroupMembership {
  _GroupMembershipImpl({
    int? id,
    required int groupId,
    required String userId,
    required String role,
    required bool active,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         groupId: groupId,
         userId: userId,
         role: role,
         active: active,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [GroupMembership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupMembership copyWith({
    Object? id = _Undefined,
    int? groupId,
    String? userId,
    String? role,
    bool? active,
    int? version,
    DateTime? createdAt,
  }) {
    return GroupMembership(
      id: id is int? ? id : this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      active: active ?? this.active,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GroupMembershipUpdateTable extends _is.UpdateTable<GroupMembershipTable> {
  GroupMembershipUpdateTable(super.table);

  _is.ColumnValue<int, int> groupId(int value) => _is.ColumnValue(
    table.groupId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<bool, bool> active(bool value) => _is.ColumnValue(
    table.active,
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

class GroupMembershipTable extends _is.Table<int?> {
  GroupMembershipTable({super.tableRelation})
    : super(tableName: 'raysto_group_membership') {
    updateTable = GroupMembershipUpdateTable(this);
    groupId = _is.ColumnInt(
      'groupId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
    );
    active = _is.ColumnBool(
      'active',
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

  late final GroupMembershipUpdateTable updateTable;

  late final _is.ColumnInt groupId;

  late final _is.ColumnString userId;

  late final _is.ColumnString role;

  late final _is.ColumnBool active;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    groupId,
    userId,
    role,
    active,
    version,
    createdAt,
  ];
}

class GroupMembershipInclude extends _is.IncludeObject {
  GroupMembershipInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GroupMembership.t;
}

class GroupMembershipIncludeList extends _is.IncludeList {
  GroupMembershipIncludeList._({
    _is.WhereExpressionBuilder<GroupMembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupMembership.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GroupMembership.t;
}

class GroupMembershipRepository {
  const GroupMembershipRepository._();

  /// Returns a list of [GroupMembership]s matching the given query parameters.
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
  Future<List<GroupMembership>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMembershipTable>? orderBy,
    _is.OrderByListBuilder<GroupMembershipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupMembership>(
      where: where?.call(GroupMembership.t),
      orderBy: orderBy?.call(GroupMembership.t),
      orderByList: orderByList?.call(GroupMembership.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupMembership] matching the given query parameters.
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
  Future<GroupMembership?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMembershipTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupMembershipTable>? orderBy,
    _is.OrderByListBuilder<GroupMembershipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupMembership>(
      where: where?.call(GroupMembership.t),
      orderBy: orderBy?.call(GroupMembership.t),
      orderByList: orderByList?.call(GroupMembership.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupMembership] by its [id] or null if no such row exists.
  Future<GroupMembership?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupMembership>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupMembership]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupMembership]s will have their `id` fields set.
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
  Future<List<GroupMembership>> insert(
    _is.DatabaseSession session,
    List<GroupMembership> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupMembership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupMembership] and returns the inserted row.
  ///
  /// The returned [GroupMembership] will have its `id` field set.
  Future<GroupMembership> insertRow(
    _is.DatabaseSession session,
    GroupMembership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GroupMembership]s in the list and returns the resulting rows.
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
  /// The returned [GroupMembership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMembership>> upsert(
    _is.DatabaseSession session,
    List<GroupMembership> rows, {
    required _is.ColumnSelections<GroupMembershipTable> conflictColumns,
    _is.ColumnSelections<GroupMembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupMembershipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupMembership>(
      rows,
      conflictColumns: conflictColumns(GroupMembership.t),
      updateColumns: updateColumns?.call(GroupMembership.t),
      updateWhere: updateWhere?.call(GroupMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupMembership] and returns the resulting row.
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
  /// The returned [GroupMembership] will have its `id` field set.
  Future<GroupMembership?> upsertRow(
    _is.DatabaseSession session,
    GroupMembership row, {
    required _is.ColumnSelections<GroupMembershipTable> conflictColumns,
    _is.ColumnSelections<GroupMembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupMembershipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupMembership>(
      row,
      conflictColumns: conflictColumns(GroupMembership.t),
      updateColumns: updateColumns?.call(GroupMembership.t),
      updateWhere: updateWhere?.call(GroupMembership.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMembership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMembership>> update(
    _is.DatabaseSession session,
    List<GroupMembership> rows, {
    _is.ColumnSelections<GroupMembershipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupMembership>(
      rows,
      columns: columns?.call(GroupMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupMembership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupMembership> updateRow(
    _is.DatabaseSession session,
    GroupMembership row, {
    _is.ColumnSelections<GroupMembershipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupMembership>(
      row,
      columns: columns?.call(GroupMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupMembership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupMembership?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GroupMembershipUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupMembership>(
      id,
      columnValues: columnValues(GroupMembership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMembership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMembership>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupMembershipUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<GroupMembershipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMembershipTable>? orderBy,
    _is.OrderByListBuilder<GroupMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupMembership>(
      columnValues: columnValues(GroupMembership.t.updateTable),
      where: where(GroupMembership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMembership.t),
      orderByList: orderByList?.call(GroupMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupMembership]s in the list and returns the deleted rows.
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
  Future<List<GroupMembership>> delete(
    _is.DatabaseSession session,
    List<GroupMembership> rows, {
    _is.OrderByBuilder<GroupMembershipTable>? orderBy,
    _is.OrderByListBuilder<GroupMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupMembership>(
      rows,
      orderBy: orderBy?.call(GroupMembership.t),
      orderByList: orderByList?.call(GroupMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupMembership].
  Future<GroupMembership> deleteRow(
    _is.DatabaseSession session,
    GroupMembership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupMembership>(
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
  Future<List<GroupMembership>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupMembershipTable> where,
    _is.OrderByBuilder<GroupMembershipTable>? orderBy,
    _is.OrderByListBuilder<GroupMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupMembership>(
      where: where(GroupMembership.t),
      orderBy: orderBy?.call(GroupMembership.t),
      orderByList: orderByList?.call(GroupMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMembershipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupMembership>(
      where: where?.call(GroupMembership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupMembership] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupMembershipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupMembership>(
      where: where(GroupMembership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
