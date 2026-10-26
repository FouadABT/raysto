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

abstract class DiningWaitlist
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DiningWaitlist._({
    this.id,
    required this.restaurantId,
    required this.userId,
    required this.partySize,
    required this.status,
    required this.contactJson,
    this.offeredTableId,
    this.offerExpiresAt,
    required this.version,
    required this.createdAt,
  });

  factory DiningWaitlist({
    int? id,
    required int restaurantId,
    required String userId,
    required int partySize,
    required String status,
    required String contactJson,
    int? offeredTableId,
    DateTime? offerExpiresAt,
    required int version,
    required DateTime createdAt,
  }) = _DiningWaitlistImpl;

  factory DiningWaitlist.fromJson(Map<String, dynamic> jsonSerialization) {
    return DiningWaitlist(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      partySize: jsonSerialization['partySize'] as int,
      status: jsonSerialization['status'] as String,
      contactJson: jsonSerialization['contactJson'] as String,
      offeredTableId: jsonSerialization['offeredTableId'] as int?,
      offerExpiresAt: jsonSerialization['offerExpiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['offerExpiresAt'],
            ),
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = DiningWaitlistTable();

  static const db = DiningWaitlistRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  int partySize;

  String status;

  String contactJson;

  int? offeredTableId;

  DateTime? offerExpiresAt;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DiningWaitlist]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DiningWaitlist copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    int? partySize,
    String? status,
    String? contactJson,
    int? offeredTableId,
    DateTime? offerExpiresAt,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DiningWaitlist',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'partySize': partySize,
      'status': status,
      'contactJson': contactJson,
      if (offeredTableId != null) 'offeredTableId': offeredTableId,
      if (offerExpiresAt != null) 'offerExpiresAt': offerExpiresAt?.toJson(),
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DiningWaitlistInclude include() {
    return DiningWaitlistInclude._();
  }

  static DiningWaitlistIncludeList includeList({
    _is.WhereExpressionBuilder<DiningWaitlistTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningWaitlistTable>? orderBy,
    _is.OrderByListBuilder<DiningWaitlistTable>? orderByList,
    DiningWaitlistInclude? include,
  }) {
    return DiningWaitlistIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningWaitlist.t),
      orderByList: orderByList?.call(DiningWaitlist.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DiningWaitlistImpl extends DiningWaitlist {
  _DiningWaitlistImpl({
    int? id,
    required int restaurantId,
    required String userId,
    required int partySize,
    required String status,
    required String contactJson,
    int? offeredTableId,
    DateTime? offerExpiresAt,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         partySize: partySize,
         status: status,
         contactJson: contactJson,
         offeredTableId: offeredTableId,
         offerExpiresAt: offerExpiresAt,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DiningWaitlist]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DiningWaitlist copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    int? partySize,
    String? status,
    String? contactJson,
    Object? offeredTableId = _Undefined,
    Object? offerExpiresAt = _Undefined,
    int? version,
    DateTime? createdAt,
  }) {
    return DiningWaitlist(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      partySize: partySize ?? this.partySize,
      status: status ?? this.status,
      contactJson: contactJson ?? this.contactJson,
      offeredTableId: offeredTableId is int?
          ? offeredTableId
          : this.offeredTableId,
      offerExpiresAt: offerExpiresAt is DateTime?
          ? offerExpiresAt
          : this.offerExpiresAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DiningWaitlistUpdateTable extends _is.UpdateTable<DiningWaitlistTable> {
  DiningWaitlistUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> partySize(int value) => _is.ColumnValue(
    table.partySize,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> contactJson(String value) => _is.ColumnValue(
    table.contactJson,
    value,
  );

  _is.ColumnValue<int, int> offeredTableId(int? value) => _is.ColumnValue(
    table.offeredTableId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> offerExpiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.offerExpiresAt,
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

class DiningWaitlistTable extends _is.Table<int?> {
  DiningWaitlistTable({super.tableRelation})
    : super(tableName: 'raysto_dining_waitlist') {
    updateTable = DiningWaitlistUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    partySize = _is.ColumnInt(
      'partySize',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    contactJson = _is.ColumnString(
      'contactJson',
      this,
    );
    offeredTableId = _is.ColumnInt(
      'offeredTableId',
      this,
    );
    offerExpiresAt = _is.ColumnDateTime(
      'offerExpiresAt',
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

  late final DiningWaitlistUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnInt partySize;

  late final _is.ColumnString status;

  late final _is.ColumnString contactJson;

  late final _is.ColumnInt offeredTableId;

  late final _is.ColumnDateTime offerExpiresAt;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    partySize,
    status,
    contactJson,
    offeredTableId,
    offerExpiresAt,
    version,
    createdAt,
  ];
}

class DiningWaitlistInclude extends _is.IncludeObject {
  DiningWaitlistInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DiningWaitlist.t;
}

class DiningWaitlistIncludeList extends _is.IncludeList {
  DiningWaitlistIncludeList._({
    _is.WhereExpressionBuilder<DiningWaitlistTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DiningWaitlist.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DiningWaitlist.t;
}

class DiningWaitlistRepository {
  const DiningWaitlistRepository._();

  /// Returns a list of [DiningWaitlist]s matching the given query parameters.
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
  Future<List<DiningWaitlist>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningWaitlistTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningWaitlistTable>? orderBy,
    _is.OrderByListBuilder<DiningWaitlistTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DiningWaitlist>(
      where: where?.call(DiningWaitlist.t),
      orderBy: orderBy?.call(DiningWaitlist.t),
      orderByList: orderByList?.call(DiningWaitlist.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DiningWaitlist] matching the given query parameters.
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
  Future<DiningWaitlist?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningWaitlistTable>? where,
    int? offset,
    _is.OrderByBuilder<DiningWaitlistTable>? orderBy,
    _is.OrderByListBuilder<DiningWaitlistTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DiningWaitlist>(
      where: where?.call(DiningWaitlist.t),
      orderBy: orderBy?.call(DiningWaitlist.t),
      orderByList: orderByList?.call(DiningWaitlist.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DiningWaitlist] by its [id] or null if no such row exists.
  Future<DiningWaitlist?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DiningWaitlist>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DiningWaitlist]s in the list and returns the inserted rows.
  ///
  /// The returned [DiningWaitlist]s will have their `id` fields set.
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
  Future<List<DiningWaitlist>> insert(
    _is.DatabaseSession session,
    List<DiningWaitlist> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DiningWaitlist>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DiningWaitlist] and returns the inserted row.
  ///
  /// The returned [DiningWaitlist] will have its `id` field set.
  Future<DiningWaitlist> insertRow(
    _is.DatabaseSession session,
    DiningWaitlist row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DiningWaitlist>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DiningWaitlist]s in the list and returns the resulting rows.
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
  /// The returned [DiningWaitlist]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningWaitlist>> upsert(
    _is.DatabaseSession session,
    List<DiningWaitlist> rows, {
    required _is.ColumnSelections<DiningWaitlistTable> conflictColumns,
    _is.ColumnSelections<DiningWaitlistTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningWaitlistTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DiningWaitlist>(
      rows,
      conflictColumns: conflictColumns(DiningWaitlist.t),
      updateColumns: updateColumns?.call(DiningWaitlist.t),
      updateWhere: updateWhere?.call(DiningWaitlist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DiningWaitlist] and returns the resulting row.
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
  /// The returned [DiningWaitlist] will have its `id` field set.
  Future<DiningWaitlist?> upsertRow(
    _is.DatabaseSession session,
    DiningWaitlist row, {
    required _is.ColumnSelections<DiningWaitlistTable> conflictColumns,
    _is.ColumnSelections<DiningWaitlistTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningWaitlistTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DiningWaitlist>(
      row,
      conflictColumns: conflictColumns(DiningWaitlist.t),
      updateColumns: updateColumns?.call(DiningWaitlist.t),
      updateWhere: updateWhere?.call(DiningWaitlist.t),
      transaction: transaction,
    );
  }

  /// Updates all [DiningWaitlist]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningWaitlist>> update(
    _is.DatabaseSession session,
    List<DiningWaitlist> rows, {
    _is.ColumnSelections<DiningWaitlistTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DiningWaitlist>(
      rows,
      columns: columns?.call(DiningWaitlist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DiningWaitlist]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DiningWaitlist> updateRow(
    _is.DatabaseSession session,
    DiningWaitlist row, {
    _is.ColumnSelections<DiningWaitlistTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DiningWaitlist>(
      row,
      columns: columns?.call(DiningWaitlist.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DiningWaitlist] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DiningWaitlist?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DiningWaitlistUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DiningWaitlist>(
      id,
      columnValues: columnValues(DiningWaitlist.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DiningWaitlist]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningWaitlist>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DiningWaitlistUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DiningWaitlistTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningWaitlistTable>? orderBy,
    _is.OrderByListBuilder<DiningWaitlistTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DiningWaitlist>(
      columnValues: columnValues(DiningWaitlist.t.updateTable),
      where: where(DiningWaitlist.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningWaitlist.t),
      orderByList: orderByList?.call(DiningWaitlist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DiningWaitlist]s in the list and returns the deleted rows.
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
  Future<List<DiningWaitlist>> delete(
    _is.DatabaseSession session,
    List<DiningWaitlist> rows, {
    _is.OrderByBuilder<DiningWaitlistTable>? orderBy,
    _is.OrderByListBuilder<DiningWaitlistTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DiningWaitlist>(
      rows,
      orderBy: orderBy?.call(DiningWaitlist.t),
      orderByList: orderByList?.call(DiningWaitlist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DiningWaitlist].
  Future<DiningWaitlist> deleteRow(
    _is.DatabaseSession session,
    DiningWaitlist row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DiningWaitlist>(
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
  Future<List<DiningWaitlist>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningWaitlistTable> where,
    _is.OrderByBuilder<DiningWaitlistTable>? orderBy,
    _is.OrderByListBuilder<DiningWaitlistTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DiningWaitlist>(
      where: where(DiningWaitlist.t),
      orderBy: orderBy?.call(DiningWaitlist.t),
      orderByList: orderByList?.call(DiningWaitlist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningWaitlistTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DiningWaitlist>(
      where: where?.call(DiningWaitlist.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DiningWaitlist] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningWaitlistTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DiningWaitlist>(
      where: where(DiningWaitlist.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
