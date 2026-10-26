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

abstract class SecurityGrant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SecurityGrant._({
    this.id,
    required this.userId,
    required this.kind,
    required this.proofHash,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
  });

  factory SecurityGrant({
    int? id,
    required String userId,
    required String kind,
    required String proofHash,
    required DateTime expiresAt,
    DateTime? usedAt,
    required DateTime createdAt,
  }) = _SecurityGrantImpl;

  factory SecurityGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return SecurityGrant(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      kind: jsonSerialization['kind'] as String,
      proofHash: jsonSerialization['proofHash'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SecurityGrantTable();

  static const db = SecurityGrantRepository._();

  @override
  int? id;

  String userId;

  String kind;

  String proofHash;

  DateTime expiresAt;

  DateTime? usedAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SecurityGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SecurityGrant copyWith({
    int? id,
    String? userId,
    String? kind,
    String? proofHash,
    DateTime? expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SecurityGrant',
      if (id != null) 'id': id,
      'userId': userId,
      'kind': kind,
      'proofHash': proofHash,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SecurityGrantInclude include() {
    return SecurityGrantInclude._();
  }

  static SecurityGrantIncludeList includeList({
    _is.WhereExpressionBuilder<SecurityGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SecurityGrantTable>? orderBy,
    _is.OrderByListBuilder<SecurityGrantTable>? orderByList,
    SecurityGrantInclude? include,
  }) {
    return SecurityGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SecurityGrant.t),
      orderByList: orderByList?.call(SecurityGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SecurityGrantImpl extends SecurityGrant {
  _SecurityGrantImpl({
    int? id,
    required String userId,
    required String kind,
    required String proofHash,
    required DateTime expiresAt,
    DateTime? usedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         kind: kind,
         proofHash: proofHash,
         expiresAt: expiresAt,
         usedAt: usedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SecurityGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SecurityGrant copyWith({
    Object? id = _Undefined,
    String? userId,
    String? kind,
    String? proofHash,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return SecurityGrant(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      proofHash: proofHash ?? this.proofHash,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SecurityGrantUpdateTable extends _is.UpdateTable<SecurityGrantTable> {
  SecurityGrantUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> proofHash(String value) => _is.ColumnValue(
    table.proofHash,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _is.ColumnValue(
        table.usedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SecurityGrantTable extends _is.Table<int?> {
  SecurityGrantTable({super.tableRelation})
    : super(tableName: 'raysto_security_grant') {
    updateTable = SecurityGrantUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    proofHash = _is.ColumnString(
      'proofHash',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    usedAt = _is.ColumnDateTime(
      'usedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SecurityGrantUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString kind;

  late final _is.ColumnString proofHash;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime usedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    kind,
    proofHash,
    expiresAt,
    usedAt,
    createdAt,
  ];
}

class SecurityGrantInclude extends _is.IncludeObject {
  SecurityGrantInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SecurityGrant.t;
}

class SecurityGrantIncludeList extends _is.IncludeList {
  SecurityGrantIncludeList._({
    _is.WhereExpressionBuilder<SecurityGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SecurityGrant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SecurityGrant.t;
}

class SecurityGrantRepository {
  const SecurityGrantRepository._();

  /// Returns a list of [SecurityGrant]s matching the given query parameters.
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
  Future<List<SecurityGrant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SecurityGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SecurityGrantTable>? orderBy,
    _is.OrderByListBuilder<SecurityGrantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SecurityGrant>(
      where: where?.call(SecurityGrant.t),
      orderBy: orderBy?.call(SecurityGrant.t),
      orderByList: orderByList?.call(SecurityGrant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SecurityGrant] matching the given query parameters.
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
  Future<SecurityGrant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SecurityGrantTable>? where,
    int? offset,
    _is.OrderByBuilder<SecurityGrantTable>? orderBy,
    _is.OrderByListBuilder<SecurityGrantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SecurityGrant>(
      where: where?.call(SecurityGrant.t),
      orderBy: orderBy?.call(SecurityGrant.t),
      orderByList: orderByList?.call(SecurityGrant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SecurityGrant] by its [id] or null if no such row exists.
  Future<SecurityGrant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SecurityGrant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SecurityGrant]s in the list and returns the inserted rows.
  ///
  /// The returned [SecurityGrant]s will have their `id` fields set.
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
  Future<List<SecurityGrant>> insert(
    _is.DatabaseSession session,
    List<SecurityGrant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SecurityGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SecurityGrant] and returns the inserted row.
  ///
  /// The returned [SecurityGrant] will have its `id` field set.
  Future<SecurityGrant> insertRow(
    _is.DatabaseSession session,
    SecurityGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SecurityGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SecurityGrant]s in the list and returns the resulting rows.
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
  /// The returned [SecurityGrant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SecurityGrant>> upsert(
    _is.DatabaseSession session,
    List<SecurityGrant> rows, {
    required _is.ColumnSelections<SecurityGrantTable> conflictColumns,
    _is.ColumnSelections<SecurityGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<SecurityGrantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SecurityGrant>(
      rows,
      conflictColumns: conflictColumns(SecurityGrant.t),
      updateColumns: updateColumns?.call(SecurityGrant.t),
      updateWhere: updateWhere?.call(SecurityGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SecurityGrant] and returns the resulting row.
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
  /// The returned [SecurityGrant] will have its `id` field set.
  Future<SecurityGrant?> upsertRow(
    _is.DatabaseSession session,
    SecurityGrant row, {
    required _is.ColumnSelections<SecurityGrantTable> conflictColumns,
    _is.ColumnSelections<SecurityGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<SecurityGrantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SecurityGrant>(
      row,
      conflictColumns: conflictColumns(SecurityGrant.t),
      updateColumns: updateColumns?.call(SecurityGrant.t),
      updateWhere: updateWhere?.call(SecurityGrant.t),
      transaction: transaction,
    );
  }

  /// Updates all [SecurityGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SecurityGrant>> update(
    _is.DatabaseSession session,
    List<SecurityGrant> rows, {
    _is.ColumnSelections<SecurityGrantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SecurityGrant>(
      rows,
      columns: columns?.call(SecurityGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SecurityGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SecurityGrant> updateRow(
    _is.DatabaseSession session,
    SecurityGrant row, {
    _is.ColumnSelections<SecurityGrantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SecurityGrant>(
      row,
      columns: columns?.call(SecurityGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SecurityGrant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SecurityGrant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SecurityGrantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SecurityGrant>(
      id,
      columnValues: columnValues(SecurityGrant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SecurityGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SecurityGrant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SecurityGrantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SecurityGrantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SecurityGrantTable>? orderBy,
    _is.OrderByListBuilder<SecurityGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SecurityGrant>(
      columnValues: columnValues(SecurityGrant.t.updateTable),
      where: where(SecurityGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SecurityGrant.t),
      orderByList: orderByList?.call(SecurityGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SecurityGrant]s in the list and returns the deleted rows.
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
  Future<List<SecurityGrant>> delete(
    _is.DatabaseSession session,
    List<SecurityGrant> rows, {
    _is.OrderByBuilder<SecurityGrantTable>? orderBy,
    _is.OrderByListBuilder<SecurityGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SecurityGrant>(
      rows,
      orderBy: orderBy?.call(SecurityGrant.t),
      orderByList: orderByList?.call(SecurityGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SecurityGrant].
  Future<SecurityGrant> deleteRow(
    _is.DatabaseSession session,
    SecurityGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SecurityGrant>(
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
  Future<List<SecurityGrant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SecurityGrantTable> where,
    _is.OrderByBuilder<SecurityGrantTable>? orderBy,
    _is.OrderByListBuilder<SecurityGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SecurityGrant>(
      where: where(SecurityGrant.t),
      orderBy: orderBy?.call(SecurityGrant.t),
      orderByList: orderByList?.call(SecurityGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SecurityGrantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SecurityGrant>(
      where: where?.call(SecurityGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SecurityGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SecurityGrantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SecurityGrant>(
      where: where(SecurityGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
