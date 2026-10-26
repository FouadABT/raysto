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

abstract class DiningReservation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DiningReservation._({
    this.id,
    required this.restaurantId,
    required this.userId,
    required this.tableId,
    required this.partySize,
    required this.startsAt,
    required this.endsAt,
    this.holdExpiresAt,
    required this.status,
    required this.contactJson,
    this.visitId,
    required this.version,
    required this.createdAt,
  });

  factory DiningReservation({
    int? id,
    required int restaurantId,
    required String userId,
    required int tableId,
    required int partySize,
    required DateTime startsAt,
    required DateTime endsAt,
    DateTime? holdExpiresAt,
    required String status,
    required String contactJson,
    int? visitId,
    required int version,
    required DateTime createdAt,
  }) = _DiningReservationImpl;

  factory DiningReservation.fromJson(Map<String, dynamic> jsonSerialization) {
    return DiningReservation(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      tableId: jsonSerialization['tableId'] as int,
      partySize: jsonSerialization['partySize'] as int,
      startsAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      endsAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      holdExpiresAt: jsonSerialization['holdExpiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['holdExpiresAt'],
            ),
      status: jsonSerialization['status'] as String,
      contactJson: jsonSerialization['contactJson'] as String,
      visitId: jsonSerialization['visitId'] as int?,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = DiningReservationTable();

  static const db = DiningReservationRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  int tableId;

  int partySize;

  DateTime startsAt;

  DateTime endsAt;

  DateTime? holdExpiresAt;

  String status;

  String contactJson;

  int? visitId;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DiningReservation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DiningReservation copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    int? tableId,
    int? partySize,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? holdExpiresAt,
    String? status,
    String? contactJson,
    int? visitId,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DiningReservation',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'tableId': tableId,
      'partySize': partySize,
      'startsAt': startsAt.toJson(),
      'endsAt': endsAt.toJson(),
      if (holdExpiresAt != null) 'holdExpiresAt': holdExpiresAt?.toJson(),
      'status': status,
      'contactJson': contactJson,
      if (visitId != null) 'visitId': visitId,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DiningReservationInclude include() {
    return DiningReservationInclude._();
  }

  static DiningReservationIncludeList includeList({
    _is.WhereExpressionBuilder<DiningReservationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningReservationTable>? orderBy,
    _is.OrderByListBuilder<DiningReservationTable>? orderByList,
    DiningReservationInclude? include,
  }) {
    return DiningReservationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningReservation.t),
      orderByList: orderByList?.call(DiningReservation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DiningReservationImpl extends DiningReservation {
  _DiningReservationImpl({
    int? id,
    required int restaurantId,
    required String userId,
    required int tableId,
    required int partySize,
    required DateTime startsAt,
    required DateTime endsAt,
    DateTime? holdExpiresAt,
    required String status,
    required String contactJson,
    int? visitId,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         tableId: tableId,
         partySize: partySize,
         startsAt: startsAt,
         endsAt: endsAt,
         holdExpiresAt: holdExpiresAt,
         status: status,
         contactJson: contactJson,
         visitId: visitId,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DiningReservation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DiningReservation copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    int? tableId,
    int? partySize,
    DateTime? startsAt,
    DateTime? endsAt,
    Object? holdExpiresAt = _Undefined,
    String? status,
    String? contactJson,
    Object? visitId = _Undefined,
    int? version,
    DateTime? createdAt,
  }) {
    return DiningReservation(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      tableId: tableId ?? this.tableId,
      partySize: partySize ?? this.partySize,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      holdExpiresAt: holdExpiresAt is DateTime?
          ? holdExpiresAt
          : this.holdExpiresAt,
      status: status ?? this.status,
      contactJson: contactJson ?? this.contactJson,
      visitId: visitId is int? ? visitId : this.visitId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DiningReservationUpdateTable
    extends _is.UpdateTable<DiningReservationTable> {
  DiningReservationUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> tableId(int value) => _is.ColumnValue(
    table.tableId,
    value,
  );

  _is.ColumnValue<int, int> partySize(int value) => _is.ColumnValue(
    table.partySize,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startsAt(DateTime value) =>
      _is.ColumnValue(
        table.startsAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> endsAt(DateTime value) => _is.ColumnValue(
    table.endsAt,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> holdExpiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.holdExpiresAt,
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

  _is.ColumnValue<int, int> visitId(int? value) => _is.ColumnValue(
    table.visitId,
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

class DiningReservationTable extends _is.Table<int?> {
  DiningReservationTable({super.tableRelation})
    : super(tableName: 'raysto_dining_reservation') {
    updateTable = DiningReservationUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    tableId = _is.ColumnInt(
      'tableId',
      this,
    );
    partySize = _is.ColumnInt(
      'partySize',
      this,
    );
    startsAt = _is.ColumnDateTime(
      'startsAt',
      this,
    );
    endsAt = _is.ColumnDateTime(
      'endsAt',
      this,
    );
    holdExpiresAt = _is.ColumnDateTime(
      'holdExpiresAt',
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
    visitId = _is.ColumnInt(
      'visitId',
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

  late final DiningReservationUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnInt tableId;

  late final _is.ColumnInt partySize;

  late final _is.ColumnDateTime startsAt;

  late final _is.ColumnDateTime endsAt;

  late final _is.ColumnDateTime holdExpiresAt;

  late final _is.ColumnString status;

  late final _is.ColumnString contactJson;

  late final _is.ColumnInt visitId;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    tableId,
    partySize,
    startsAt,
    endsAt,
    holdExpiresAt,
    status,
    contactJson,
    visitId,
    version,
    createdAt,
  ];
}

class DiningReservationInclude extends _is.IncludeObject {
  DiningReservationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DiningReservation.t;
}

class DiningReservationIncludeList extends _is.IncludeList {
  DiningReservationIncludeList._({
    _is.WhereExpressionBuilder<DiningReservationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DiningReservation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DiningReservation.t;
}

class DiningReservationRepository {
  const DiningReservationRepository._();

  /// Returns a list of [DiningReservation]s matching the given query parameters.
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
  Future<List<DiningReservation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningReservationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningReservationTable>? orderBy,
    _is.OrderByListBuilder<DiningReservationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DiningReservation>(
      where: where?.call(DiningReservation.t),
      orderBy: orderBy?.call(DiningReservation.t),
      orderByList: orderByList?.call(DiningReservation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DiningReservation] matching the given query parameters.
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
  Future<DiningReservation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningReservationTable>? where,
    int? offset,
    _is.OrderByBuilder<DiningReservationTable>? orderBy,
    _is.OrderByListBuilder<DiningReservationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DiningReservation>(
      where: where?.call(DiningReservation.t),
      orderBy: orderBy?.call(DiningReservation.t),
      orderByList: orderByList?.call(DiningReservation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DiningReservation] by its [id] or null if no such row exists.
  Future<DiningReservation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DiningReservation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DiningReservation]s in the list and returns the inserted rows.
  ///
  /// The returned [DiningReservation]s will have their `id` fields set.
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
  Future<List<DiningReservation>> insert(
    _is.DatabaseSession session,
    List<DiningReservation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DiningReservation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DiningReservation] and returns the inserted row.
  ///
  /// The returned [DiningReservation] will have its `id` field set.
  Future<DiningReservation> insertRow(
    _is.DatabaseSession session,
    DiningReservation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DiningReservation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DiningReservation]s in the list and returns the resulting rows.
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
  /// The returned [DiningReservation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningReservation>> upsert(
    _is.DatabaseSession session,
    List<DiningReservation> rows, {
    required _is.ColumnSelections<DiningReservationTable> conflictColumns,
    _is.ColumnSelections<DiningReservationTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningReservationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DiningReservation>(
      rows,
      conflictColumns: conflictColumns(DiningReservation.t),
      updateColumns: updateColumns?.call(DiningReservation.t),
      updateWhere: updateWhere?.call(DiningReservation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DiningReservation] and returns the resulting row.
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
  /// The returned [DiningReservation] will have its `id` field set.
  Future<DiningReservation?> upsertRow(
    _is.DatabaseSession session,
    DiningReservation row, {
    required _is.ColumnSelections<DiningReservationTable> conflictColumns,
    _is.ColumnSelections<DiningReservationTable>? updateColumns,
    _is.WhereExpressionBuilder<DiningReservationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DiningReservation>(
      row,
      conflictColumns: conflictColumns(DiningReservation.t),
      updateColumns: updateColumns?.call(DiningReservation.t),
      updateWhere: updateWhere?.call(DiningReservation.t),
      transaction: transaction,
    );
  }

  /// Updates all [DiningReservation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningReservation>> update(
    _is.DatabaseSession session,
    List<DiningReservation> rows, {
    _is.ColumnSelections<DiningReservationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DiningReservation>(
      rows,
      columns: columns?.call(DiningReservation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DiningReservation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DiningReservation> updateRow(
    _is.DatabaseSession session,
    DiningReservation row, {
    _is.ColumnSelections<DiningReservationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DiningReservation>(
      row,
      columns: columns?.call(DiningReservation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DiningReservation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DiningReservation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DiningReservationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DiningReservation>(
      id,
      columnValues: columnValues(DiningReservation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DiningReservation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningReservation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DiningReservationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DiningReservationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DiningReservationTable>? orderBy,
    _is.OrderByListBuilder<DiningReservationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DiningReservation>(
      columnValues: columnValues(DiningReservation.t.updateTable),
      where: where(DiningReservation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningReservation.t),
      orderByList: orderByList?.call(DiningReservation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DiningReservation]s in the list and returns the deleted rows.
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
  Future<List<DiningReservation>> delete(
    _is.DatabaseSession session,
    List<DiningReservation> rows, {
    _is.OrderByBuilder<DiningReservationTable>? orderBy,
    _is.OrderByListBuilder<DiningReservationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DiningReservation>(
      rows,
      orderBy: orderBy?.call(DiningReservation.t),
      orderByList: orderByList?.call(DiningReservation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DiningReservation].
  Future<DiningReservation> deleteRow(
    _is.DatabaseSession session,
    DiningReservation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DiningReservation>(
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
  Future<List<DiningReservation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningReservationTable> where,
    _is.OrderByBuilder<DiningReservationTable>? orderBy,
    _is.OrderByListBuilder<DiningReservationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DiningReservation>(
      where: where(DiningReservation.t),
      orderBy: orderBy?.call(DiningReservation.t),
      orderByList: orderByList?.call(DiningReservation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DiningReservationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DiningReservation>(
      where: where?.call(DiningReservation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DiningReservation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DiningReservationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DiningReservation>(
      where: where(DiningReservation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
