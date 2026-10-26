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

abstract class MerchantConnection
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MerchantConnection._({
    this.id,
    required this.restaurantId,
    required this.trackingId,
    this.merchantId,
    required this.environment,
    required this.status,
    required this.capabilitiesJson,
    this.verifiedAt,
    required this.createdAt,
  });

  factory MerchantConnection({
    int? id,
    required int restaurantId,
    required String trackingId,
    String? merchantId,
    required String environment,
    required String status,
    required String capabilitiesJson,
    DateTime? verifiedAt,
    required DateTime createdAt,
  }) = _MerchantConnectionImpl;

  factory MerchantConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return MerchantConnection(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      trackingId: jsonSerialization['trackingId'] as String,
      merchantId: jsonSerialization['merchantId'] as String?,
      environment: jsonSerialization['environment'] as String,
      status: jsonSerialization['status'] as String,
      capabilitiesJson: jsonSerialization['capabilitiesJson'] as String,
      verifiedAt: jsonSerialization['verifiedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['verifiedAt']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MerchantConnectionTable();

  static const db = MerchantConnectionRepository._();

  @override
  int? id;

  int restaurantId;

  String trackingId;

  String? merchantId;

  String environment;

  String status;

  String capabilitiesJson;

  DateTime? verifiedAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MerchantConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MerchantConnection copyWith({
    int? id,
    int? restaurantId,
    String? trackingId,
    String? merchantId,
    String? environment,
    String? status,
    String? capabilitiesJson,
    DateTime? verifiedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MerchantConnection',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'trackingId': trackingId,
      if (merchantId != null) 'merchantId': merchantId,
      'environment': environment,
      'status': status,
      'capabilitiesJson': capabilitiesJson,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static MerchantConnectionInclude include() {
    return MerchantConnectionInclude._();
  }

  static MerchantConnectionIncludeList includeList({
    _is.WhereExpressionBuilder<MerchantConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MerchantConnectionTable>? orderBy,
    _is.OrderByListBuilder<MerchantConnectionTable>? orderByList,
    MerchantConnectionInclude? include,
  }) {
    return MerchantConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MerchantConnection.t),
      orderByList: orderByList?.call(MerchantConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MerchantConnectionImpl extends MerchantConnection {
  _MerchantConnectionImpl({
    int? id,
    required int restaurantId,
    required String trackingId,
    String? merchantId,
    required String environment,
    required String status,
    required String capabilitiesJson,
    DateTime? verifiedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         trackingId: trackingId,
         merchantId: merchantId,
         environment: environment,
         status: status,
         capabilitiesJson: capabilitiesJson,
         verifiedAt: verifiedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MerchantConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MerchantConnection copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? trackingId,
    Object? merchantId = _Undefined,
    String? environment,
    String? status,
    String? capabilitiesJson,
    Object? verifiedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return MerchantConnection(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      trackingId: trackingId ?? this.trackingId,
      merchantId: merchantId is String? ? merchantId : this.merchantId,
      environment: environment ?? this.environment,
      status: status ?? this.status,
      capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
      verifiedAt: verifiedAt is DateTime? ? verifiedAt : this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MerchantConnectionUpdateTable
    extends _is.UpdateTable<MerchantConnectionTable> {
  MerchantConnectionUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> trackingId(String value) => _is.ColumnValue(
    table.trackingId,
    value,
  );

  _is.ColumnValue<String, String> merchantId(String? value) => _is.ColumnValue(
    table.merchantId,
    value,
  );

  _is.ColumnValue<String, String> environment(String value) => _is.ColumnValue(
    table.environment,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> capabilitiesJson(String value) =>
      _is.ColumnValue(
        table.capabilitiesJson,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> verifiedAt(DateTime? value) =>
      _is.ColumnValue(
        table.verifiedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MerchantConnectionTable extends _is.Table<int?> {
  MerchantConnectionTable({super.tableRelation})
    : super(tableName: 'raysto_merchant_connection') {
    updateTable = MerchantConnectionUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    trackingId = _is.ColumnString(
      'trackingId',
      this,
    );
    merchantId = _is.ColumnString(
      'merchantId',
      this,
    );
    environment = _is.ColumnString(
      'environment',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    capabilitiesJson = _is.ColumnString(
      'capabilitiesJson',
      this,
    );
    verifiedAt = _is.ColumnDateTime(
      'verifiedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MerchantConnectionUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString trackingId;

  late final _is.ColumnString merchantId;

  late final _is.ColumnString environment;

  late final _is.ColumnString status;

  late final _is.ColumnString capabilitiesJson;

  late final _is.ColumnDateTime verifiedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    trackingId,
    merchantId,
    environment,
    status,
    capabilitiesJson,
    verifiedAt,
    createdAt,
  ];
}

class MerchantConnectionInclude extends _is.IncludeObject {
  MerchantConnectionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MerchantConnection.t;
}

class MerchantConnectionIncludeList extends _is.IncludeList {
  MerchantConnectionIncludeList._({
    _is.WhereExpressionBuilder<MerchantConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MerchantConnection.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MerchantConnection.t;
}

class MerchantConnectionRepository {
  const MerchantConnectionRepository._();

  /// Returns a list of [MerchantConnection]s matching the given query parameters.
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
  Future<List<MerchantConnection>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MerchantConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MerchantConnectionTable>? orderBy,
    _is.OrderByListBuilder<MerchantConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MerchantConnection>(
      where: where?.call(MerchantConnection.t),
      orderBy: orderBy?.call(MerchantConnection.t),
      orderByList: orderByList?.call(MerchantConnection.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MerchantConnection] matching the given query parameters.
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
  Future<MerchantConnection?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MerchantConnectionTable>? where,
    int? offset,
    _is.OrderByBuilder<MerchantConnectionTable>? orderBy,
    _is.OrderByListBuilder<MerchantConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MerchantConnection>(
      where: where?.call(MerchantConnection.t),
      orderBy: orderBy?.call(MerchantConnection.t),
      orderByList: orderByList?.call(MerchantConnection.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MerchantConnection] by its [id] or null if no such row exists.
  Future<MerchantConnection?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MerchantConnection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MerchantConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [MerchantConnection]s will have their `id` fields set.
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
  Future<List<MerchantConnection>> insert(
    _is.DatabaseSession session,
    List<MerchantConnection> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MerchantConnection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MerchantConnection] and returns the inserted row.
  ///
  /// The returned [MerchantConnection] will have its `id` field set.
  Future<MerchantConnection> insertRow(
    _is.DatabaseSession session,
    MerchantConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MerchantConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MerchantConnection]s in the list and returns the resulting rows.
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
  /// The returned [MerchantConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MerchantConnection>> upsert(
    _is.DatabaseSession session,
    List<MerchantConnection> rows, {
    required _is.ColumnSelections<MerchantConnectionTable> conflictColumns,
    _is.ColumnSelections<MerchantConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<MerchantConnectionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MerchantConnection>(
      rows,
      conflictColumns: conflictColumns(MerchantConnection.t),
      updateColumns: updateColumns?.call(MerchantConnection.t),
      updateWhere: updateWhere?.call(MerchantConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MerchantConnection] and returns the resulting row.
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
  /// The returned [MerchantConnection] will have its `id` field set.
  Future<MerchantConnection?> upsertRow(
    _is.DatabaseSession session,
    MerchantConnection row, {
    required _is.ColumnSelections<MerchantConnectionTable> conflictColumns,
    _is.ColumnSelections<MerchantConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<MerchantConnectionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MerchantConnection>(
      row,
      conflictColumns: conflictColumns(MerchantConnection.t),
      updateColumns: updateColumns?.call(MerchantConnection.t),
      updateWhere: updateWhere?.call(MerchantConnection.t),
      transaction: transaction,
    );
  }

  /// Updates all [MerchantConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MerchantConnection>> update(
    _is.DatabaseSession session,
    List<MerchantConnection> rows, {
    _is.ColumnSelections<MerchantConnectionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MerchantConnection>(
      rows,
      columns: columns?.call(MerchantConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MerchantConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MerchantConnection> updateRow(
    _is.DatabaseSession session,
    MerchantConnection row, {
    _is.ColumnSelections<MerchantConnectionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MerchantConnection>(
      row,
      columns: columns?.call(MerchantConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MerchantConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MerchantConnection?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MerchantConnectionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MerchantConnection>(
      id,
      columnValues: columnValues(MerchantConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MerchantConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MerchantConnection>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MerchantConnectionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<MerchantConnectionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MerchantConnectionTable>? orderBy,
    _is.OrderByListBuilder<MerchantConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MerchantConnection>(
      columnValues: columnValues(MerchantConnection.t.updateTable),
      where: where(MerchantConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MerchantConnection.t),
      orderByList: orderByList?.call(MerchantConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MerchantConnection]s in the list and returns the deleted rows.
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
  Future<List<MerchantConnection>> delete(
    _is.DatabaseSession session,
    List<MerchantConnection> rows, {
    _is.OrderByBuilder<MerchantConnectionTable>? orderBy,
    _is.OrderByListBuilder<MerchantConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MerchantConnection>(
      rows,
      orderBy: orderBy?.call(MerchantConnection.t),
      orderByList: orderByList?.call(MerchantConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MerchantConnection].
  Future<MerchantConnection> deleteRow(
    _is.DatabaseSession session,
    MerchantConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MerchantConnection>(
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
  Future<List<MerchantConnection>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MerchantConnectionTable> where,
    _is.OrderByBuilder<MerchantConnectionTable>? orderBy,
    _is.OrderByListBuilder<MerchantConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MerchantConnection>(
      where: where(MerchantConnection.t),
      orderBy: orderBy?.call(MerchantConnection.t),
      orderByList: orderByList?.call(MerchantConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MerchantConnectionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MerchantConnection>(
      where: where?.call(MerchantConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MerchantConnection] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MerchantConnectionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MerchantConnection>(
      where: where(MerchantConnection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
