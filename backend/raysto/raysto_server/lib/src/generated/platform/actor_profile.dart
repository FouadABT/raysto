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

abstract class ActorProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ActorProfile._({
    this.id,
    required this.userId,
    this.firebaseUid,
    required this.isGuest,
    required this.disabled,
    this.claimedBy,
    required this.dataJson,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActorProfile({
    int? id,
    required String userId,
    String? firebaseUid,
    required bool isGuest,
    required bool disabled,
    String? claimedBy,
    required String dataJson,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ActorProfileImpl;

  factory ActorProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return ActorProfile(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      firebaseUid: jsonSerialization['firebaseUid'] as String?,
      isGuest: _is.BoolJsonExtension.fromJson(jsonSerialization['isGuest']),
      disabled: _is.BoolJsonExtension.fromJson(jsonSerialization['disabled']),
      claimedBy: jsonSerialization['claimedBy'] as String?,
      dataJson: jsonSerialization['dataJson'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = ActorProfileTable();

  static const db = ActorProfileRepository._();

  @override
  int? id;

  String userId;

  String? firebaseUid;

  bool isGuest;

  bool disabled;

  String? claimedBy;

  String dataJson;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ActorProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ActorProfile copyWith({
    int? id,
    String? userId,
    String? firebaseUid,
    bool? isGuest,
    bool? disabled,
    String? claimedBy,
    String? dataJson,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ActorProfile',
      if (id != null) 'id': id,
      'userId': userId,
      if (firebaseUid != null) 'firebaseUid': firebaseUid,
      'isGuest': isGuest,
      'disabled': disabled,
      if (claimedBy != null) 'claimedBy': claimedBy,
      'dataJson': dataJson,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ActorProfileInclude include() {
    return ActorProfileInclude._();
  }

  static ActorProfileIncludeList includeList({
    _is.WhereExpressionBuilder<ActorProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActorProfileTable>? orderBy,
    _is.OrderByListBuilder<ActorProfileTable>? orderByList,
    ActorProfileInclude? include,
  }) {
    return ActorProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ActorProfile.t),
      orderByList: orderByList?.call(ActorProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ActorProfileImpl extends ActorProfile {
  _ActorProfileImpl({
    int? id,
    required String userId,
    String? firebaseUid,
    required bool isGuest,
    required bool disabled,
    String? claimedBy,
    required String dataJson,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         firebaseUid: firebaseUid,
         isGuest: isGuest,
         disabled: disabled,
         claimedBy: claimedBy,
         dataJson: dataJson,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ActorProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ActorProfile copyWith({
    Object? id = _Undefined,
    String? userId,
    Object? firebaseUid = _Undefined,
    bool? isGuest,
    bool? disabled,
    Object? claimedBy = _Undefined,
    String? dataJson,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActorProfile(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      firebaseUid: firebaseUid is String? ? firebaseUid : this.firebaseUid,
      isGuest: isGuest ?? this.isGuest,
      disabled: disabled ?? this.disabled,
      claimedBy: claimedBy is String? ? claimedBy : this.claimedBy,
      dataJson: dataJson ?? this.dataJson,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ActorProfileUpdateTable extends _is.UpdateTable<ActorProfileTable> {
  ActorProfileUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> firebaseUid(String? value) => _is.ColumnValue(
    table.firebaseUid,
    value,
  );

  _is.ColumnValue<bool, bool> isGuest(bool value) => _is.ColumnValue(
    table.isGuest,
    value,
  );

  _is.ColumnValue<bool, bool> disabled(bool value) => _is.ColumnValue(
    table.disabled,
    value,
  );

  _is.ColumnValue<String, String> claimedBy(String? value) => _is.ColumnValue(
    table.claimedBy,
    value,
  );

  _is.ColumnValue<String, String> dataJson(String value) => _is.ColumnValue(
    table.dataJson,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class ActorProfileTable extends _is.Table<int?> {
  ActorProfileTable({super.tableRelation})
    : super(tableName: 'raysto_actor_profile') {
    updateTable = ActorProfileUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    firebaseUid = _is.ColumnString(
      'firebaseUid',
      this,
    );
    isGuest = _is.ColumnBool(
      'isGuest',
      this,
    );
    disabled = _is.ColumnBool(
      'disabled',
      this,
    );
    claimedBy = _is.ColumnString(
      'claimedBy',
      this,
    );
    dataJson = _is.ColumnString(
      'dataJson',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final ActorProfileUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString firebaseUid;

  late final _is.ColumnBool isGuest;

  late final _is.ColumnBool disabled;

  late final _is.ColumnString claimedBy;

  late final _is.ColumnString dataJson;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    firebaseUid,
    isGuest,
    disabled,
    claimedBy,
    dataJson,
    version,
    createdAt,
    updatedAt,
  ];
}

class ActorProfileInclude extends _is.IncludeObject {
  ActorProfileInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ActorProfile.t;
}

class ActorProfileIncludeList extends _is.IncludeList {
  ActorProfileIncludeList._({
    _is.WhereExpressionBuilder<ActorProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ActorProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ActorProfile.t;
}

class ActorProfileRepository {
  const ActorProfileRepository._();

  /// Returns a list of [ActorProfile]s matching the given query parameters.
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
  Future<List<ActorProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActorProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActorProfileTable>? orderBy,
    _is.OrderByListBuilder<ActorProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ActorProfile>(
      where: where?.call(ActorProfile.t),
      orderBy: orderBy?.call(ActorProfile.t),
      orderByList: orderByList?.call(ActorProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ActorProfile] matching the given query parameters.
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
  Future<ActorProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActorProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<ActorProfileTable>? orderBy,
    _is.OrderByListBuilder<ActorProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ActorProfile>(
      where: where?.call(ActorProfile.t),
      orderBy: orderBy?.call(ActorProfile.t),
      orderByList: orderByList?.call(ActorProfile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ActorProfile] by its [id] or null if no such row exists.
  Future<ActorProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ActorProfile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ActorProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [ActorProfile]s will have their `id` fields set.
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
  Future<List<ActorProfile>> insert(
    _is.DatabaseSession session,
    List<ActorProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ActorProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ActorProfile] and returns the inserted row.
  ///
  /// The returned [ActorProfile] will have its `id` field set.
  Future<ActorProfile> insertRow(
    _is.DatabaseSession session,
    ActorProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ActorProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ActorProfile]s in the list and returns the resulting rows.
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
  /// The returned [ActorProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ActorProfile>> upsert(
    _is.DatabaseSession session,
    List<ActorProfile> rows, {
    required _is.ColumnSelections<ActorProfileTable> conflictColumns,
    _is.ColumnSelections<ActorProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<ActorProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ActorProfile>(
      rows,
      conflictColumns: conflictColumns(ActorProfile.t),
      updateColumns: updateColumns?.call(ActorProfile.t),
      updateWhere: updateWhere?.call(ActorProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ActorProfile] and returns the resulting row.
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
  /// The returned [ActorProfile] will have its `id` field set.
  Future<ActorProfile?> upsertRow(
    _is.DatabaseSession session,
    ActorProfile row, {
    required _is.ColumnSelections<ActorProfileTable> conflictColumns,
    _is.ColumnSelections<ActorProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<ActorProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ActorProfile>(
      row,
      conflictColumns: conflictColumns(ActorProfile.t),
      updateColumns: updateColumns?.call(ActorProfile.t),
      updateWhere: updateWhere?.call(ActorProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [ActorProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ActorProfile>> update(
    _is.DatabaseSession session,
    List<ActorProfile> rows, {
    _is.ColumnSelections<ActorProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ActorProfile>(
      rows,
      columns: columns?.call(ActorProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ActorProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ActorProfile> updateRow(
    _is.DatabaseSession session,
    ActorProfile row, {
    _is.ColumnSelections<ActorProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ActorProfile>(
      row,
      columns: columns?.call(ActorProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ActorProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ActorProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ActorProfileUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ActorProfile>(
      id,
      columnValues: columnValues(ActorProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ActorProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ActorProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ActorProfileUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ActorProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActorProfileTable>? orderBy,
    _is.OrderByListBuilder<ActorProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ActorProfile>(
      columnValues: columnValues(ActorProfile.t.updateTable),
      where: where(ActorProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ActorProfile.t),
      orderByList: orderByList?.call(ActorProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ActorProfile]s in the list and returns the deleted rows.
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
  Future<List<ActorProfile>> delete(
    _is.DatabaseSession session,
    List<ActorProfile> rows, {
    _is.OrderByBuilder<ActorProfileTable>? orderBy,
    _is.OrderByListBuilder<ActorProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ActorProfile>(
      rows,
      orderBy: orderBy?.call(ActorProfile.t),
      orderByList: orderByList?.call(ActorProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ActorProfile].
  Future<ActorProfile> deleteRow(
    _is.DatabaseSession session,
    ActorProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ActorProfile>(
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
  Future<List<ActorProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ActorProfileTable> where,
    _is.OrderByBuilder<ActorProfileTable>? orderBy,
    _is.OrderByListBuilder<ActorProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ActorProfile>(
      where: where(ActorProfile.t),
      orderBy: orderBy?.call(ActorProfile.t),
      orderByList: orderByList?.call(ActorProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActorProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ActorProfile>(
      where: where?.call(ActorProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ActorProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ActorProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ActorProfile>(
      where: where(ActorProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
