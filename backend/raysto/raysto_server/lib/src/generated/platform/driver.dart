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

abstract class Driver implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Driver._({
    this.id,
    required this.restaurantId,
    required this.kind,
    this.userId,
    this.partnerAppId,
    required this.name,
    this.phoneLast4,
    required this.vehicle,
    this.payoutEmail,
    required this.status,
    this.lastSeenAt,
    required this.active,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver({
    int? id,
    required int restaurantId,
    required String kind,
    String? userId,
    int? partnerAppId,
    required String name,
    String? phoneLast4,
    required String vehicle,
    String? payoutEmail,
    required String status,
    DateTime? lastSeenAt,
    required bool active,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DriverImpl;

  factory Driver.fromJson(Map<String, dynamic> jsonSerialization) {
    return Driver(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      kind: jsonSerialization['kind'] as String,
      userId: jsonSerialization['userId'] as String?,
      partnerAppId: jsonSerialization['partnerAppId'] as int?,
      name: jsonSerialization['name'] as String,
      phoneLast4: jsonSerialization['phoneLast4'] as String?,
      vehicle: jsonSerialization['vehicle'] as String,
      payoutEmail: jsonSerialization['payoutEmail'] as String?,
      status: jsonSerialization['status'] as String,
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = DriverTable();

  static const db = DriverRepository._();

  @override
  int? id;

  int restaurantId;

  String kind;

  String? userId;

  int? partnerAppId;

  String name;

  String? phoneLast4;

  String vehicle;

  String? payoutEmail;

  String status;

  DateTime? lastSeenAt;

  bool active;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Driver]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Driver copyWith({
    int? id,
    int? restaurantId,
    String? kind,
    String? userId,
    int? partnerAppId,
    String? name,
    String? phoneLast4,
    String? vehicle,
    String? payoutEmail,
    String? status,
    DateTime? lastSeenAt,
    bool? active,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Driver',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'kind': kind,
      if (userId != null) 'userId': userId,
      if (partnerAppId != null) 'partnerAppId': partnerAppId,
      'name': name,
      if (phoneLast4 != null) 'phoneLast4': phoneLast4,
      'vehicle': vehicle,
      if (payoutEmail != null) 'payoutEmail': payoutEmail,
      'status': status,
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      'active': active,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DriverInclude include() {
    return DriverInclude._();
  }

  static DriverIncludeList includeList({
    _is.WhereExpressionBuilder<DriverTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriverTable>? orderBy,
    _is.OrderByListBuilder<DriverTable>? orderByList,
    DriverInclude? include,
  }) {
    return DriverIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Driver.t),
      orderByList: orderByList?.call(Driver.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriverImpl extends Driver {
  _DriverImpl({
    int? id,
    required int restaurantId,
    required String kind,
    String? userId,
    int? partnerAppId,
    required String name,
    String? phoneLast4,
    required String vehicle,
    String? payoutEmail,
    required String status,
    DateTime? lastSeenAt,
    required bool active,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         kind: kind,
         userId: userId,
         partnerAppId: partnerAppId,
         name: name,
         phoneLast4: phoneLast4,
         vehicle: vehicle,
         payoutEmail: payoutEmail,
         status: status,
         lastSeenAt: lastSeenAt,
         active: active,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Driver]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Driver copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? kind,
    Object? userId = _Undefined,
    Object? partnerAppId = _Undefined,
    String? name,
    Object? phoneLast4 = _Undefined,
    String? vehicle,
    Object? payoutEmail = _Undefined,
    String? status,
    Object? lastSeenAt = _Undefined,
    bool? active,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      kind: kind ?? this.kind,
      userId: userId is String? ? userId : this.userId,
      partnerAppId: partnerAppId is int? ? partnerAppId : this.partnerAppId,
      name: name ?? this.name,
      phoneLast4: phoneLast4 is String? ? phoneLast4 : this.phoneLast4,
      vehicle: vehicle ?? this.vehicle,
      payoutEmail: payoutEmail is String? ? payoutEmail : this.payoutEmail,
      status: status ?? this.status,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
      active: active ?? this.active,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DriverUpdateTable extends _is.UpdateTable<DriverTable> {
  DriverUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> partnerAppId(int? value) => _is.ColumnValue(
    table.partnerAppId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> phoneLast4(String? value) => _is.ColumnValue(
    table.phoneLast4,
    value,
  );

  _is.ColumnValue<String, String> vehicle(String value) => _is.ColumnValue(
    table.vehicle,
    value,
  );

  _is.ColumnValue<String, String> payoutEmail(String? value) => _is.ColumnValue(
    table.payoutEmail,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastSeenAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSeenAt,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class DriverTable extends _is.Table<int?> {
  DriverTable({super.tableRelation}) : super(tableName: 'raysto_driver') {
    updateTable = DriverUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    partnerAppId = _is.ColumnInt(
      'partnerAppId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    phoneLast4 = _is.ColumnString(
      'phoneLast4',
      this,
    );
    vehicle = _is.ColumnString(
      'vehicle',
      this,
    );
    payoutEmail = _is.ColumnString(
      'payoutEmail',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    lastSeenAt = _is.ColumnDateTime(
      'lastSeenAt',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final DriverUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString kind;

  late final _is.ColumnString userId;

  late final _is.ColumnInt partnerAppId;

  late final _is.ColumnString name;

  late final _is.ColumnString phoneLast4;

  late final _is.ColumnString vehicle;

  late final _is.ColumnString payoutEmail;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime lastSeenAt;

  late final _is.ColumnBool active;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    kind,
    userId,
    partnerAppId,
    name,
    phoneLast4,
    vehicle,
    payoutEmail,
    status,
    lastSeenAt,
    active,
    version,
    createdAt,
    updatedAt,
  ];
}

class DriverInclude extends _is.IncludeObject {
  DriverInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Driver.t;
}

class DriverIncludeList extends _is.IncludeList {
  DriverIncludeList._({
    _is.WhereExpressionBuilder<DriverTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Driver.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Driver.t;
}

class DriverRepository {
  const DriverRepository._();

  /// Returns a list of [Driver]s matching the given query parameters.
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
  Future<List<Driver>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriverTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriverTable>? orderBy,
    _is.OrderByListBuilder<DriverTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Driver>(
      where: where?.call(Driver.t),
      orderBy: orderBy?.call(Driver.t),
      orderByList: orderByList?.call(Driver.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Driver] matching the given query parameters.
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
  Future<Driver?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriverTable>? where,
    int? offset,
    _is.OrderByBuilder<DriverTable>? orderBy,
    _is.OrderByListBuilder<DriverTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Driver>(
      where: where?.call(Driver.t),
      orderBy: orderBy?.call(Driver.t),
      orderByList: orderByList?.call(Driver.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Driver] by its [id] or null if no such row exists.
  Future<Driver?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Driver>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Driver]s in the list and returns the inserted rows.
  ///
  /// The returned [Driver]s will have their `id` fields set.
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
  Future<List<Driver>> insert(
    _is.DatabaseSession session,
    List<Driver> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Driver>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Driver] and returns the inserted row.
  ///
  /// The returned [Driver] will have its `id` field set.
  Future<Driver> insertRow(
    _is.DatabaseSession session,
    Driver row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Driver>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Driver]s in the list and returns the resulting rows.
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
  /// The returned [Driver]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Driver>> upsert(
    _is.DatabaseSession session,
    List<Driver> rows, {
    required _is.ColumnSelections<DriverTable> conflictColumns,
    _is.ColumnSelections<DriverTable>? updateColumns,
    _is.WhereExpressionBuilder<DriverTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Driver>(
      rows,
      conflictColumns: conflictColumns(Driver.t),
      updateColumns: updateColumns?.call(Driver.t),
      updateWhere: updateWhere?.call(Driver.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Driver] and returns the resulting row.
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
  /// The returned [Driver] will have its `id` field set.
  Future<Driver?> upsertRow(
    _is.DatabaseSession session,
    Driver row, {
    required _is.ColumnSelections<DriverTable> conflictColumns,
    _is.ColumnSelections<DriverTable>? updateColumns,
    _is.WhereExpressionBuilder<DriverTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Driver>(
      row,
      conflictColumns: conflictColumns(Driver.t),
      updateColumns: updateColumns?.call(Driver.t),
      updateWhere: updateWhere?.call(Driver.t),
      transaction: transaction,
    );
  }

  /// Updates all [Driver]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Driver>> update(
    _is.DatabaseSession session,
    List<Driver> rows, {
    _is.ColumnSelections<DriverTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Driver>(
      rows,
      columns: columns?.call(Driver.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Driver]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Driver> updateRow(
    _is.DatabaseSession session,
    Driver row, {
    _is.ColumnSelections<DriverTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Driver>(
      row,
      columns: columns?.call(Driver.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Driver] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Driver?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DriverUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Driver>(
      id,
      columnValues: columnValues(Driver.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Driver]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Driver>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DriverUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DriverTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriverTable>? orderBy,
    _is.OrderByListBuilder<DriverTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Driver>(
      columnValues: columnValues(Driver.t.updateTable),
      where: where(Driver.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Driver.t),
      orderByList: orderByList?.call(Driver.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Driver]s in the list and returns the deleted rows.
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
  Future<List<Driver>> delete(
    _is.DatabaseSession session,
    List<Driver> rows, {
    _is.OrderByBuilder<DriverTable>? orderBy,
    _is.OrderByListBuilder<DriverTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Driver>(
      rows,
      orderBy: orderBy?.call(Driver.t),
      orderByList: orderByList?.call(Driver.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Driver].
  Future<Driver> deleteRow(
    _is.DatabaseSession session,
    Driver row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Driver>(
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
  Future<List<Driver>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriverTable> where,
    _is.OrderByBuilder<DriverTable>? orderBy,
    _is.OrderByListBuilder<DriverTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Driver>(
      where: where(Driver.t),
      orderBy: orderBy?.call(Driver.t),
      orderByList: orderByList?.call(Driver.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriverTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Driver>(
      where: where?.call(Driver.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Driver] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriverTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Driver>(
      where: where(Driver.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
