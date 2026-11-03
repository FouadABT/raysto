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

abstract class StaffShift
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StaffShift._({
    this.id,
    required this.restaurantId,
    this.userId,
    required this.name,
    required this.role,
    required this.startsAt,
    required this.endsAt,
    this.clockInAt,
    this.clockOutAt,
    required this.hourlyRateMinor,
    this.payoutEmail,
    required this.version,
    required this.createdAt,
  });

  factory StaffShift({
    int? id,
    required int restaurantId,
    String? userId,
    required String name,
    required String role,
    required DateTime startsAt,
    required DateTime endsAt,
    DateTime? clockInAt,
    DateTime? clockOutAt,
    required int hourlyRateMinor,
    String? payoutEmail,
    required int version,
    required DateTime createdAt,
  }) = _StaffShiftImpl;

  factory StaffShift.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffShift(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String?,
      name: jsonSerialization['name'] as String,
      role: jsonSerialization['role'] as String,
      startsAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      endsAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      clockInAt: jsonSerialization['clockInAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['clockInAt']),
      clockOutAt: jsonSerialization['clockOutAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['clockOutAt']),
      hourlyRateMinor: jsonSerialization['hourlyRateMinor'] as int,
      payoutEmail: jsonSerialization['payoutEmail'] as String?,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = StaffShiftTable();

  static const db = StaffShiftRepository._();

  @override
  int? id;

  int restaurantId;

  String? userId;

  String name;

  String role;

  DateTime startsAt;

  DateTime endsAt;

  DateTime? clockInAt;

  DateTime? clockOutAt;

  int hourlyRateMinor;

  String? payoutEmail;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StaffShift]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StaffShift copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? name,
    String? role,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? clockInAt,
    DateTime? clockOutAt,
    int? hourlyRateMinor,
    String? payoutEmail,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StaffShift',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      if (userId != null) 'userId': userId,
      'name': name,
      'role': role,
      'startsAt': startsAt.toJson(),
      'endsAt': endsAt.toJson(),
      if (clockInAt != null) 'clockInAt': clockInAt?.toJson(),
      if (clockOutAt != null) 'clockOutAt': clockOutAt?.toJson(),
      'hourlyRateMinor': hourlyRateMinor,
      if (payoutEmail != null) 'payoutEmail': payoutEmail,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StaffShiftInclude include() {
    return StaffShiftInclude._();
  }

  static StaffShiftIncludeList includeList({
    _is.WhereExpressionBuilder<StaffShiftTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffShiftTable>? orderBy,
    _is.OrderByListBuilder<StaffShiftTable>? orderByList,
    StaffShiftInclude? include,
  }) {
    return StaffShiftIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffShift.t),
      orderByList: orderByList?.call(StaffShift.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StaffShiftImpl extends StaffShift {
  _StaffShiftImpl({
    int? id,
    required int restaurantId,
    String? userId,
    required String name,
    required String role,
    required DateTime startsAt,
    required DateTime endsAt,
    DateTime? clockInAt,
    DateTime? clockOutAt,
    required int hourlyRateMinor,
    String? payoutEmail,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         name: name,
         role: role,
         startsAt: startsAt,
         endsAt: endsAt,
         clockInAt: clockInAt,
         clockOutAt: clockOutAt,
         hourlyRateMinor: hourlyRateMinor,
         payoutEmail: payoutEmail,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [StaffShift]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StaffShift copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    Object? userId = _Undefined,
    String? name,
    String? role,
    DateTime? startsAt,
    DateTime? endsAt,
    Object? clockInAt = _Undefined,
    Object? clockOutAt = _Undefined,
    int? hourlyRateMinor,
    Object? payoutEmail = _Undefined,
    int? version,
    DateTime? createdAt,
  }) {
    return StaffShift(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId is String? ? userId : this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      clockInAt: clockInAt is DateTime? ? clockInAt : this.clockInAt,
      clockOutAt: clockOutAt is DateTime? ? clockOutAt : this.clockOutAt,
      hourlyRateMinor: hourlyRateMinor ?? this.hourlyRateMinor,
      payoutEmail: payoutEmail is String? ? payoutEmail : this.payoutEmail,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StaffShiftUpdateTable extends _is.UpdateTable<StaffShiftTable> {
  StaffShiftUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
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

  _is.ColumnValue<DateTime, DateTime> clockInAt(DateTime? value) =>
      _is.ColumnValue(
        table.clockInAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> clockOutAt(DateTime? value) =>
      _is.ColumnValue(
        table.clockOutAt,
        value,
      );

  _is.ColumnValue<int, int> hourlyRateMinor(int value) => _is.ColumnValue(
    table.hourlyRateMinor,
    value,
  );

  _is.ColumnValue<String, String> payoutEmail(String? value) => _is.ColumnValue(
    table.payoutEmail,
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

class StaffShiftTable extends _is.Table<int?> {
  StaffShiftTable({super.tableRelation})
    : super(tableName: 'raysto_staff_shift') {
    updateTable = StaffShiftUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    role = _is.ColumnString(
      'role',
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
    clockInAt = _is.ColumnDateTime(
      'clockInAt',
      this,
    );
    clockOutAt = _is.ColumnDateTime(
      'clockOutAt',
      this,
    );
    hourlyRateMinor = _is.ColumnInt(
      'hourlyRateMinor',
      this,
    );
    payoutEmail = _is.ColumnString(
      'payoutEmail',
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

  late final StaffShiftUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString name;

  late final _is.ColumnString role;

  late final _is.ColumnDateTime startsAt;

  late final _is.ColumnDateTime endsAt;

  late final _is.ColumnDateTime clockInAt;

  late final _is.ColumnDateTime clockOutAt;

  late final _is.ColumnInt hourlyRateMinor;

  late final _is.ColumnString payoutEmail;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    name,
    role,
    startsAt,
    endsAt,
    clockInAt,
    clockOutAt,
    hourlyRateMinor,
    payoutEmail,
    version,
    createdAt,
  ];
}

class StaffShiftInclude extends _is.IncludeObject {
  StaffShiftInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StaffShift.t;
}

class StaffShiftIncludeList extends _is.IncludeList {
  StaffShiftIncludeList._({
    _is.WhereExpressionBuilder<StaffShiftTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StaffShift.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StaffShift.t;
}

class StaffShiftRepository {
  const StaffShiftRepository._();

  /// Returns a list of [StaffShift]s matching the given query parameters.
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
  Future<List<StaffShift>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffShiftTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffShiftTable>? orderBy,
    _is.OrderByListBuilder<StaffShiftTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StaffShift>(
      where: where?.call(StaffShift.t),
      orderBy: orderBy?.call(StaffShift.t),
      orderByList: orderByList?.call(StaffShift.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StaffShift] matching the given query parameters.
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
  Future<StaffShift?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffShiftTable>? where,
    int? offset,
    _is.OrderByBuilder<StaffShiftTable>? orderBy,
    _is.OrderByListBuilder<StaffShiftTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StaffShift>(
      where: where?.call(StaffShift.t),
      orderBy: orderBy?.call(StaffShift.t),
      orderByList: orderByList?.call(StaffShift.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StaffShift] by its [id] or null if no such row exists.
  Future<StaffShift?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StaffShift>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StaffShift]s in the list and returns the inserted rows.
  ///
  /// The returned [StaffShift]s will have their `id` fields set.
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
  Future<List<StaffShift>> insert(
    _is.DatabaseSession session,
    List<StaffShift> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StaffShift>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StaffShift] and returns the inserted row.
  ///
  /// The returned [StaffShift] will have its `id` field set.
  Future<StaffShift> insertRow(
    _is.DatabaseSession session,
    StaffShift row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StaffShift>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StaffShift]s in the list and returns the resulting rows.
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
  /// The returned [StaffShift]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffShift>> upsert(
    _is.DatabaseSession session,
    List<StaffShift> rows, {
    required _is.ColumnSelections<StaffShiftTable> conflictColumns,
    _is.ColumnSelections<StaffShiftTable>? updateColumns,
    _is.WhereExpressionBuilder<StaffShiftTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StaffShift>(
      rows,
      conflictColumns: conflictColumns(StaffShift.t),
      updateColumns: updateColumns?.call(StaffShift.t),
      updateWhere: updateWhere?.call(StaffShift.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StaffShift] and returns the resulting row.
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
  /// The returned [StaffShift] will have its `id` field set.
  Future<StaffShift?> upsertRow(
    _is.DatabaseSession session,
    StaffShift row, {
    required _is.ColumnSelections<StaffShiftTable> conflictColumns,
    _is.ColumnSelections<StaffShiftTable>? updateColumns,
    _is.WhereExpressionBuilder<StaffShiftTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StaffShift>(
      row,
      conflictColumns: conflictColumns(StaffShift.t),
      updateColumns: updateColumns?.call(StaffShift.t),
      updateWhere: updateWhere?.call(StaffShift.t),
      transaction: transaction,
    );
  }

  /// Updates all [StaffShift]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffShift>> update(
    _is.DatabaseSession session,
    List<StaffShift> rows, {
    _is.ColumnSelections<StaffShiftTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StaffShift>(
      rows,
      columns: columns?.call(StaffShift.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StaffShift]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StaffShift> updateRow(
    _is.DatabaseSession session,
    StaffShift row, {
    _is.ColumnSelections<StaffShiftTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StaffShift>(
      row,
      columns: columns?.call(StaffShift.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StaffShift] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StaffShift?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StaffShiftUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StaffShift>(
      id,
      columnValues: columnValues(StaffShift.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StaffShift]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffShift>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StaffShiftUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StaffShiftTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffShiftTable>? orderBy,
    _is.OrderByListBuilder<StaffShiftTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StaffShift>(
      columnValues: columnValues(StaffShift.t.updateTable),
      where: where(StaffShift.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffShift.t),
      orderByList: orderByList?.call(StaffShift.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StaffShift]s in the list and returns the deleted rows.
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
  Future<List<StaffShift>> delete(
    _is.DatabaseSession session,
    List<StaffShift> rows, {
    _is.OrderByBuilder<StaffShiftTable>? orderBy,
    _is.OrderByListBuilder<StaffShiftTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StaffShift>(
      rows,
      orderBy: orderBy?.call(StaffShift.t),
      orderByList: orderByList?.call(StaffShift.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StaffShift].
  Future<StaffShift> deleteRow(
    _is.DatabaseSession session,
    StaffShift row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StaffShift>(
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
  Future<List<StaffShift>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StaffShiftTable> where,
    _is.OrderByBuilder<StaffShiftTable>? orderBy,
    _is.OrderByListBuilder<StaffShiftTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StaffShift>(
      where: where(StaffShift.t),
      orderBy: orderBy?.call(StaffShift.t),
      orderByList: orderByList?.call(StaffShift.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffShiftTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StaffShift>(
      where: where?.call(StaffShift.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StaffShift] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StaffShiftTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StaffShift>(
      where: where(StaffShift.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
