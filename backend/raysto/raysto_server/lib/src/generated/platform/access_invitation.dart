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

abstract class AccessInvitation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AccessInvitation._({
    this.id,
    required this.restaurantId,
    required this.kind,
    required this.targetId,
    required this.tokenHash,
    required this.createdBy,
    this.recipientEmail,
    this.role,
    required this.expiresAt,
    required this.usesRemaining,
    required this.revoked,
    required this.createdAt,
  });

  factory AccessInvitation({
    int? id,
    required int restaurantId,
    required String kind,
    required int targetId,
    required String tokenHash,
    required String createdBy,
    String? recipientEmail,
    String? role,
    required DateTime expiresAt,
    required int usesRemaining,
    required bool revoked,
    required DateTime createdAt,
  }) = _AccessInvitationImpl;

  factory AccessInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccessInvitation(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      kind: jsonSerialization['kind'] as String,
      targetId: jsonSerialization['targetId'] as int,
      tokenHash: jsonSerialization['tokenHash'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      recipientEmail: jsonSerialization['recipientEmail'] as String?,
      role: jsonSerialization['role'] as String?,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usesRemaining: jsonSerialization['usesRemaining'] as int,
      revoked: _is.BoolJsonExtension.fromJson(jsonSerialization['revoked']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AccessInvitationTable();

  static const db = AccessInvitationRepository._();

  @override
  int? id;

  int restaurantId;

  String kind;

  int targetId;

  String tokenHash;

  String createdBy;

  String? recipientEmail;

  String? role;

  DateTime expiresAt;

  int usesRemaining;

  bool revoked;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccessInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccessInvitation copyWith({
    int? id,
    int? restaurantId,
    String? kind,
    int? targetId,
    String? tokenHash,
    String? createdBy,
    String? recipientEmail,
    String? role,
    DateTime? expiresAt,
    int? usesRemaining,
    bool? revoked,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccessInvitation',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'kind': kind,
      'targetId': targetId,
      'tokenHash': tokenHash,
      'createdBy': createdBy,
      if (recipientEmail != null) 'recipientEmail': recipientEmail,
      if (role != null) 'role': role,
      'expiresAt': expiresAt.toJson(),
      'usesRemaining': usesRemaining,
      'revoked': revoked,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AccessInvitationInclude include() {
    return AccessInvitationInclude._();
  }

  static AccessInvitationIncludeList includeList({
    _is.WhereExpressionBuilder<AccessInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccessInvitationTable>? orderBy,
    _is.OrderByListBuilder<AccessInvitationTable>? orderByList,
    AccessInvitationInclude? include,
  }) {
    return AccessInvitationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccessInvitation.t),
      orderByList: orderByList?.call(AccessInvitation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccessInvitationImpl extends AccessInvitation {
  _AccessInvitationImpl({
    int? id,
    required int restaurantId,
    required String kind,
    required int targetId,
    required String tokenHash,
    required String createdBy,
    String? recipientEmail,
    String? role,
    required DateTime expiresAt,
    required int usesRemaining,
    required bool revoked,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         kind: kind,
         targetId: targetId,
         tokenHash: tokenHash,
         createdBy: createdBy,
         recipientEmail: recipientEmail,
         role: role,
         expiresAt: expiresAt,
         usesRemaining: usesRemaining,
         revoked: revoked,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AccessInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccessInvitation copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? kind,
    int? targetId,
    String? tokenHash,
    String? createdBy,
    Object? recipientEmail = _Undefined,
    Object? role = _Undefined,
    DateTime? expiresAt,
    int? usesRemaining,
    bool? revoked,
    DateTime? createdAt,
  }) {
    return AccessInvitation(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      kind: kind ?? this.kind,
      targetId: targetId ?? this.targetId,
      tokenHash: tokenHash ?? this.tokenHash,
      createdBy: createdBy ?? this.createdBy,
      recipientEmail: recipientEmail is String?
          ? recipientEmail
          : this.recipientEmail,
      role: role is String? ? role : this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      usesRemaining: usesRemaining ?? this.usesRemaining,
      revoked: revoked ?? this.revoked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AccessInvitationUpdateTable
    extends _is.UpdateTable<AccessInvitationTable> {
  AccessInvitationUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> targetId(int value) => _is.ColumnValue(
    table.targetId,
    value,
  );

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<String, String> recipientEmail(String? value) =>
      _is.ColumnValue(
        table.recipientEmail,
        value,
      );

  _is.ColumnValue<String, String> role(String? value) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<int, int> usesRemaining(int value) => _is.ColumnValue(
    table.usesRemaining,
    value,
  );

  _is.ColumnValue<bool, bool> revoked(bool value) => _is.ColumnValue(
    table.revoked,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AccessInvitationTable extends _is.Table<int?> {
  AccessInvitationTable({super.tableRelation})
    : super(tableName: 'raysto_access_invitation') {
    updateTable = AccessInvitationUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    targetId = _is.ColumnInt(
      'targetId',
      this,
    );
    tokenHash = _is.ColumnString(
      'tokenHash',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    recipientEmail = _is.ColumnString(
      'recipientEmail',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    usesRemaining = _is.ColumnInt(
      'usesRemaining',
      this,
    );
    revoked = _is.ColumnBool(
      'revoked',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final AccessInvitationUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString kind;

  late final _is.ColumnInt targetId;

  late final _is.ColumnString tokenHash;

  late final _is.ColumnString createdBy;

  late final _is.ColumnString recipientEmail;

  late final _is.ColumnString role;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnInt usesRemaining;

  late final _is.ColumnBool revoked;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    kind,
    targetId,
    tokenHash,
    createdBy,
    recipientEmail,
    role,
    expiresAt,
    usesRemaining,
    revoked,
    createdAt,
  ];
}

class AccessInvitationInclude extends _is.IncludeObject {
  AccessInvitationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AccessInvitation.t;
}

class AccessInvitationIncludeList extends _is.IncludeList {
  AccessInvitationIncludeList._({
    _is.WhereExpressionBuilder<AccessInvitationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccessInvitation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AccessInvitation.t;
}

class AccessInvitationRepository {
  const AccessInvitationRepository._();

  /// Returns a list of [AccessInvitation]s matching the given query parameters.
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
  Future<List<AccessInvitation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccessInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccessInvitationTable>? orderBy,
    _is.OrderByListBuilder<AccessInvitationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccessInvitation>(
      where: where?.call(AccessInvitation.t),
      orderBy: orderBy?.call(AccessInvitation.t),
      orderByList: orderByList?.call(AccessInvitation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AccessInvitation] matching the given query parameters.
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
  Future<AccessInvitation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccessInvitationTable>? where,
    int? offset,
    _is.OrderByBuilder<AccessInvitationTable>? orderBy,
    _is.OrderByListBuilder<AccessInvitationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccessInvitation>(
      where: where?.call(AccessInvitation.t),
      orderBy: orderBy?.call(AccessInvitation.t),
      orderByList: orderByList?.call(AccessInvitation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccessInvitation] by its [id] or null if no such row exists.
  Future<AccessInvitation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccessInvitation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccessInvitation]s in the list and returns the inserted rows.
  ///
  /// The returned [AccessInvitation]s will have their `id` fields set.
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
  Future<List<AccessInvitation>> insert(
    _is.DatabaseSession session,
    List<AccessInvitation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccessInvitation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccessInvitation] and returns the inserted row.
  ///
  /// The returned [AccessInvitation] will have its `id` field set.
  Future<AccessInvitation> insertRow(
    _is.DatabaseSession session,
    AccessInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccessInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AccessInvitation]s in the list and returns the resulting rows.
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
  /// The returned [AccessInvitation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccessInvitation>> upsert(
    _is.DatabaseSession session,
    List<AccessInvitation> rows, {
    required _is.ColumnSelections<AccessInvitationTable> conflictColumns,
    _is.ColumnSelections<AccessInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<AccessInvitationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccessInvitation>(
      rows,
      conflictColumns: conflictColumns(AccessInvitation.t),
      updateColumns: updateColumns?.call(AccessInvitation.t),
      updateWhere: updateWhere?.call(AccessInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccessInvitation] and returns the resulting row.
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
  /// The returned [AccessInvitation] will have its `id` field set.
  Future<AccessInvitation?> upsertRow(
    _is.DatabaseSession session,
    AccessInvitation row, {
    required _is.ColumnSelections<AccessInvitationTable> conflictColumns,
    _is.ColumnSelections<AccessInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<AccessInvitationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccessInvitation>(
      row,
      conflictColumns: conflictColumns(AccessInvitation.t),
      updateColumns: updateColumns?.call(AccessInvitation.t),
      updateWhere: updateWhere?.call(AccessInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccessInvitation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccessInvitation>> update(
    _is.DatabaseSession session,
    List<AccessInvitation> rows, {
    _is.ColumnSelections<AccessInvitationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccessInvitation>(
      rows,
      columns: columns?.call(AccessInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccessInvitation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccessInvitation> updateRow(
    _is.DatabaseSession session,
    AccessInvitation row, {
    _is.ColumnSelections<AccessInvitationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccessInvitation>(
      row,
      columns: columns?.call(AccessInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccessInvitation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccessInvitation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AccessInvitationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccessInvitation>(
      id,
      columnValues: columnValues(AccessInvitation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccessInvitation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccessInvitation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccessInvitationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AccessInvitationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccessInvitationTable>? orderBy,
    _is.OrderByListBuilder<AccessInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccessInvitation>(
      columnValues: columnValues(AccessInvitation.t.updateTable),
      where: where(AccessInvitation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccessInvitation.t),
      orderByList: orderByList?.call(AccessInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccessInvitation]s in the list and returns the deleted rows.
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
  Future<List<AccessInvitation>> delete(
    _is.DatabaseSession session,
    List<AccessInvitation> rows, {
    _is.OrderByBuilder<AccessInvitationTable>? orderBy,
    _is.OrderByListBuilder<AccessInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccessInvitation>(
      rows,
      orderBy: orderBy?.call(AccessInvitation.t),
      orderByList: orderByList?.call(AccessInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccessInvitation].
  Future<AccessInvitation> deleteRow(
    _is.DatabaseSession session,
    AccessInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccessInvitation>(
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
  Future<List<AccessInvitation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccessInvitationTable> where,
    _is.OrderByBuilder<AccessInvitationTable>? orderBy,
    _is.OrderByListBuilder<AccessInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccessInvitation>(
      where: where(AccessInvitation.t),
      orderBy: orderBy?.call(AccessInvitation.t),
      orderByList: orderByList?.call(AccessInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccessInvitationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccessInvitation>(
      where: where?.call(AccessInvitation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccessInvitation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccessInvitationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccessInvitation>(
      where: where(AccessInvitation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
