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

abstract class DeliveryAssignment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DeliveryAssignment._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    this.courierId,
    required this.status,
    required this.issueJson,
    this.locationJson,
    this.locationExpiresAt,
    required this.locationConsent,
    required this.version,
    required this.updatedAt,
  });

  factory DeliveryAssignment({
    int? id,
    required int restaurantId,
    required int orderId,
    String? courierId,
    required String status,
    required String issueJson,
    String? locationJson,
    DateTime? locationExpiresAt,
    required bool locationConsent,
    required int version,
    required DateTime updatedAt,
  }) = _DeliveryAssignmentImpl;

  factory DeliveryAssignment.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeliveryAssignment(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      courierId: jsonSerialization['courierId'] as String?,
      status: jsonSerialization['status'] as String,
      issueJson: jsonSerialization['issueJson'] as String,
      locationJson: jsonSerialization['locationJson'] as String?,
      locationExpiresAt: jsonSerialization['locationExpiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['locationExpiresAt'],
            ),
      locationConsent: _is.BoolJsonExtension.fromJson(
        jsonSerialization['locationConsent'],
      ),
      version: jsonSerialization['version'] as int,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = DeliveryAssignmentTable();

  static const db = DeliveryAssignmentRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  String? courierId;

  String status;

  String issueJson;

  String? locationJson;

  DateTime? locationExpiresAt;

  bool locationConsent;

  int version;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DeliveryAssignment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeliveryAssignment copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    String? courierId,
    String? status,
    String? issueJson,
    String? locationJson,
    DateTime? locationExpiresAt,
    bool? locationConsent,
    int? version,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeliveryAssignment',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      if (courierId != null) 'courierId': courierId,
      'status': status,
      'issueJson': issueJson,
      if (locationJson != null) 'locationJson': locationJson,
      if (locationExpiresAt != null)
        'locationExpiresAt': locationExpiresAt?.toJson(),
      'locationConsent': locationConsent,
      'version': version,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DeliveryAssignmentInclude include() {
    return DeliveryAssignmentInclude._();
  }

  static DeliveryAssignmentIncludeList includeList({
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryAssignmentTable>? orderBy,
    _is.OrderByListBuilder<DeliveryAssignmentTable>? orderByList,
    DeliveryAssignmentInclude? include,
  }) {
    return DeliveryAssignmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryAssignment.t),
      orderByList: orderByList?.call(DeliveryAssignment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeliveryAssignmentImpl extends DeliveryAssignment {
  _DeliveryAssignmentImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    String? courierId,
    required String status,
    required String issueJson,
    String? locationJson,
    DateTime? locationExpiresAt,
    required bool locationConsent,
    required int version,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         courierId: courierId,
         status: status,
         issueJson: issueJson,
         locationJson: locationJson,
         locationExpiresAt: locationExpiresAt,
         locationConsent: locationConsent,
         version: version,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [DeliveryAssignment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeliveryAssignment copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    Object? courierId = _Undefined,
    String? status,
    String? issueJson,
    Object? locationJson = _Undefined,
    Object? locationExpiresAt = _Undefined,
    bool? locationConsent,
    int? version,
    DateTime? updatedAt,
  }) {
    return DeliveryAssignment(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      courierId: courierId is String? ? courierId : this.courierId,
      status: status ?? this.status,
      issueJson: issueJson ?? this.issueJson,
      locationJson: locationJson is String? ? locationJson : this.locationJson,
      locationExpiresAt: locationExpiresAt is DateTime?
          ? locationExpiresAt
          : this.locationExpiresAt,
      locationConsent: locationConsent ?? this.locationConsent,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DeliveryAssignmentUpdateTable
    extends _is.UpdateTable<DeliveryAssignmentTable> {
  DeliveryAssignmentUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<String, String> courierId(String? value) => _is.ColumnValue(
    table.courierId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> issueJson(String value) => _is.ColumnValue(
    table.issueJson,
    value,
  );

  _is.ColumnValue<String, String> locationJson(String? value) =>
      _is.ColumnValue(
        table.locationJson,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> locationExpiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.locationExpiresAt,
        value,
      );

  _is.ColumnValue<bool, bool> locationConsent(bool value) => _is.ColumnValue(
    table.locationConsent,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class DeliveryAssignmentTable extends _is.Table<int?> {
  DeliveryAssignmentTable({super.tableRelation})
    : super(tableName: 'raysto_delivery_assignment') {
    updateTable = DeliveryAssignmentUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    courierId = _is.ColumnString(
      'courierId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    issueJson = _is.ColumnString(
      'issueJson',
      this,
    );
    locationJson = _is.ColumnString(
      'locationJson',
      this,
    );
    locationExpiresAt = _is.ColumnDateTime(
      'locationExpiresAt',
      this,
    );
    locationConsent = _is.ColumnBool(
      'locationConsent',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final DeliveryAssignmentUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString courierId;

  late final _is.ColumnString status;

  late final _is.ColumnString issueJson;

  late final _is.ColumnString locationJson;

  late final _is.ColumnDateTime locationExpiresAt;

  late final _is.ColumnBool locationConsent;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    courierId,
    status,
    issueJson,
    locationJson,
    locationExpiresAt,
    locationConsent,
    version,
    updatedAt,
  ];
}

class DeliveryAssignmentInclude extends _is.IncludeObject {
  DeliveryAssignmentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DeliveryAssignment.t;
}

class DeliveryAssignmentIncludeList extends _is.IncludeList {
  DeliveryAssignmentIncludeList._({
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DeliveryAssignment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DeliveryAssignment.t;
}

class DeliveryAssignmentRepository {
  const DeliveryAssignmentRepository._();

  /// Returns a list of [DeliveryAssignment]s matching the given query parameters.
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
  Future<List<DeliveryAssignment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryAssignmentTable>? orderBy,
    _is.OrderByListBuilder<DeliveryAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DeliveryAssignment>(
      where: where?.call(DeliveryAssignment.t),
      orderBy: orderBy?.call(DeliveryAssignment.t),
      orderByList: orderByList?.call(DeliveryAssignment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DeliveryAssignment] matching the given query parameters.
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
  Future<DeliveryAssignment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? where,
    int? offset,
    _is.OrderByBuilder<DeliveryAssignmentTable>? orderBy,
    _is.OrderByListBuilder<DeliveryAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DeliveryAssignment>(
      where: where?.call(DeliveryAssignment.t),
      orderBy: orderBy?.call(DeliveryAssignment.t),
      orderByList: orderByList?.call(DeliveryAssignment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DeliveryAssignment] by its [id] or null if no such row exists.
  Future<DeliveryAssignment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DeliveryAssignment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DeliveryAssignment]s in the list and returns the inserted rows.
  ///
  /// The returned [DeliveryAssignment]s will have their `id` fields set.
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
  Future<List<DeliveryAssignment>> insert(
    _is.DatabaseSession session,
    List<DeliveryAssignment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DeliveryAssignment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DeliveryAssignment] and returns the inserted row.
  ///
  /// The returned [DeliveryAssignment] will have its `id` field set.
  Future<DeliveryAssignment> insertRow(
    _is.DatabaseSession session,
    DeliveryAssignment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DeliveryAssignment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DeliveryAssignment]s in the list and returns the resulting rows.
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
  /// The returned [DeliveryAssignment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryAssignment>> upsert(
    _is.DatabaseSession session,
    List<DeliveryAssignment> rows, {
    required _is.ColumnSelections<DeliveryAssignmentTable> conflictColumns,
    _is.ColumnSelections<DeliveryAssignmentTable>? updateColumns,
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DeliveryAssignment>(
      rows,
      conflictColumns: conflictColumns(DeliveryAssignment.t),
      updateColumns: updateColumns?.call(DeliveryAssignment.t),
      updateWhere: updateWhere?.call(DeliveryAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DeliveryAssignment] and returns the resulting row.
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
  /// The returned [DeliveryAssignment] will have its `id` field set.
  Future<DeliveryAssignment?> upsertRow(
    _is.DatabaseSession session,
    DeliveryAssignment row, {
    required _is.ColumnSelections<DeliveryAssignmentTable> conflictColumns,
    _is.ColumnSelections<DeliveryAssignmentTable>? updateColumns,
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DeliveryAssignment>(
      row,
      conflictColumns: conflictColumns(DeliveryAssignment.t),
      updateColumns: updateColumns?.call(DeliveryAssignment.t),
      updateWhere: updateWhere?.call(DeliveryAssignment.t),
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryAssignment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryAssignment>> update(
    _is.DatabaseSession session,
    List<DeliveryAssignment> rows, {
    _is.ColumnSelections<DeliveryAssignmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DeliveryAssignment>(
      rows,
      columns: columns?.call(DeliveryAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DeliveryAssignment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DeliveryAssignment> updateRow(
    _is.DatabaseSession session,
    DeliveryAssignment row, {
    _is.ColumnSelections<DeliveryAssignmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DeliveryAssignment>(
      row,
      columns: columns?.call(DeliveryAssignment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeliveryAssignment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DeliveryAssignment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DeliveryAssignmentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DeliveryAssignment>(
      id,
      columnValues: columnValues(DeliveryAssignment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryAssignment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryAssignment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DeliveryAssignmentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DeliveryAssignmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryAssignmentTable>? orderBy,
    _is.OrderByListBuilder<DeliveryAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DeliveryAssignment>(
      columnValues: columnValues(DeliveryAssignment.t.updateTable),
      where: where(DeliveryAssignment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryAssignment.t),
      orderByList: orderByList?.call(DeliveryAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DeliveryAssignment]s in the list and returns the deleted rows.
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
  Future<List<DeliveryAssignment>> delete(
    _is.DatabaseSession session,
    List<DeliveryAssignment> rows, {
    _is.OrderByBuilder<DeliveryAssignmentTable>? orderBy,
    _is.OrderByListBuilder<DeliveryAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DeliveryAssignment>(
      rows,
      orderBy: orderBy?.call(DeliveryAssignment.t),
      orderByList: orderByList?.call(DeliveryAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DeliveryAssignment].
  Future<DeliveryAssignment> deleteRow(
    _is.DatabaseSession session,
    DeliveryAssignment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DeliveryAssignment>(
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
  Future<List<DeliveryAssignment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeliveryAssignmentTable> where,
    _is.OrderByBuilder<DeliveryAssignmentTable>? orderBy,
    _is.OrderByListBuilder<DeliveryAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DeliveryAssignment>(
      where: where(DeliveryAssignment.t),
      orderBy: orderBy?.call(DeliveryAssignment.t),
      orderByList: orderByList?.call(DeliveryAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryAssignmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DeliveryAssignment>(
      where: where?.call(DeliveryAssignment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DeliveryAssignment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeliveryAssignmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DeliveryAssignment>(
      where: where(DeliveryAssignment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
