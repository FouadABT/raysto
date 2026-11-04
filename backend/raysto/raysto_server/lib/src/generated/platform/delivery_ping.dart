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

abstract class DeliveryPing
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DeliveryPing._({
    this.id,
    required this.restaurantId,
    required this.assignmentId,
    required this.lat,
    required this.lng,
    this.accuracy,
    required this.at,
  });

  factory DeliveryPing({
    int? id,
    required int restaurantId,
    required int assignmentId,
    required double lat,
    required double lng,
    double? accuracy,
    required DateTime at,
  }) = _DeliveryPingImpl;

  factory DeliveryPing.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeliveryPing(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      assignmentId: jsonSerialization['assignmentId'] as int,
      lat: (jsonSerialization['lat'] as num).toDouble(),
      lng: (jsonSerialization['lng'] as num).toDouble(),
      accuracy: (jsonSerialization['accuracy'] as num?)?.toDouble(),
      at: _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  static final t = DeliveryPingTable();

  static const db = DeliveryPingRepository._();

  @override
  int? id;

  int restaurantId;

  int assignmentId;

  double lat;

  double lng;

  double? accuracy;

  DateTime at;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DeliveryPing]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeliveryPing copyWith({
    int? id,
    int? restaurantId,
    int? assignmentId,
    double? lat,
    double? lng,
    double? accuracy,
    DateTime? at,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeliveryPing',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'assignmentId': assignmentId,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      'at': at.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DeliveryPingInclude include() {
    return DeliveryPingInclude._();
  }

  static DeliveryPingIncludeList includeList({
    _is.WhereExpressionBuilder<DeliveryPingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryPingTable>? orderBy,
    _is.OrderByListBuilder<DeliveryPingTable>? orderByList,
    DeliveryPingInclude? include,
  }) {
    return DeliveryPingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryPing.t),
      orderByList: orderByList?.call(DeliveryPing.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeliveryPingImpl extends DeliveryPing {
  _DeliveryPingImpl({
    int? id,
    required int restaurantId,
    required int assignmentId,
    required double lat,
    required double lng,
    double? accuracy,
    required DateTime at,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         assignmentId: assignmentId,
         lat: lat,
         lng: lng,
         accuracy: accuracy,
         at: at,
       );

  /// Returns a shallow copy of this [DeliveryPing]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeliveryPing copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? assignmentId,
    double? lat,
    double? lng,
    Object? accuracy = _Undefined,
    DateTime? at,
  }) {
    return DeliveryPing(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      assignmentId: assignmentId ?? this.assignmentId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy is double? ? accuracy : this.accuracy,
      at: at ?? this.at,
    );
  }
}

class DeliveryPingUpdateTable extends _is.UpdateTable<DeliveryPingTable> {
  DeliveryPingUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> assignmentId(int value) => _is.ColumnValue(
    table.assignmentId,
    value,
  );

  _is.ColumnValue<double, double> lat(double value) => _is.ColumnValue(
    table.lat,
    value,
  );

  _is.ColumnValue<double, double> lng(double value) => _is.ColumnValue(
    table.lng,
    value,
  );

  _is.ColumnValue<double, double> accuracy(double? value) => _is.ColumnValue(
    table.accuracy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> at(DateTime value) => _is.ColumnValue(
    table.at,
    value,
  );
}

class DeliveryPingTable extends _is.Table<int?> {
  DeliveryPingTable({super.tableRelation})
    : super(tableName: 'raysto_delivery_ping') {
    updateTable = DeliveryPingUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    assignmentId = _is.ColumnInt(
      'assignmentId',
      this,
    );
    lat = _is.ColumnDouble(
      'lat',
      this,
    );
    lng = _is.ColumnDouble(
      'lng',
      this,
    );
    accuracy = _is.ColumnDouble(
      'accuracy',
      this,
    );
    at = _is.ColumnDateTime(
      'at',
      this,
    );
  }

  late final DeliveryPingUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt assignmentId;

  late final _is.ColumnDouble lat;

  late final _is.ColumnDouble lng;

  late final _is.ColumnDouble accuracy;

  late final _is.ColumnDateTime at;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    assignmentId,
    lat,
    lng,
    accuracy,
    at,
  ];
}

class DeliveryPingInclude extends _is.IncludeObject {
  DeliveryPingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DeliveryPing.t;
}

class DeliveryPingIncludeList extends _is.IncludeList {
  DeliveryPingIncludeList._({
    _is.WhereExpressionBuilder<DeliveryPingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DeliveryPing.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DeliveryPing.t;
}

class DeliveryPingRepository {
  const DeliveryPingRepository._();

  /// Returns a list of [DeliveryPing]s matching the given query parameters.
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
  Future<List<DeliveryPing>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryPingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryPingTable>? orderBy,
    _is.OrderByListBuilder<DeliveryPingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DeliveryPing>(
      where: where?.call(DeliveryPing.t),
      orderBy: orderBy?.call(DeliveryPing.t),
      orderByList: orderByList?.call(DeliveryPing.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DeliveryPing] matching the given query parameters.
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
  Future<DeliveryPing?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryPingTable>? where,
    int? offset,
    _is.OrderByBuilder<DeliveryPingTable>? orderBy,
    _is.OrderByListBuilder<DeliveryPingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DeliveryPing>(
      where: where?.call(DeliveryPing.t),
      orderBy: orderBy?.call(DeliveryPing.t),
      orderByList: orderByList?.call(DeliveryPing.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DeliveryPing] by its [id] or null if no such row exists.
  Future<DeliveryPing?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DeliveryPing>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DeliveryPing]s in the list and returns the inserted rows.
  ///
  /// The returned [DeliveryPing]s will have their `id` fields set.
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
  Future<List<DeliveryPing>> insert(
    _is.DatabaseSession session,
    List<DeliveryPing> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DeliveryPing>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DeliveryPing] and returns the inserted row.
  ///
  /// The returned [DeliveryPing] will have its `id` field set.
  Future<DeliveryPing> insertRow(
    _is.DatabaseSession session,
    DeliveryPing row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DeliveryPing>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DeliveryPing]s in the list and returns the resulting rows.
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
  /// The returned [DeliveryPing]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryPing>> upsert(
    _is.DatabaseSession session,
    List<DeliveryPing> rows, {
    required _is.ColumnSelections<DeliveryPingTable> conflictColumns,
    _is.ColumnSelections<DeliveryPingTable>? updateColumns,
    _is.WhereExpressionBuilder<DeliveryPingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DeliveryPing>(
      rows,
      conflictColumns: conflictColumns(DeliveryPing.t),
      updateColumns: updateColumns?.call(DeliveryPing.t),
      updateWhere: updateWhere?.call(DeliveryPing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DeliveryPing] and returns the resulting row.
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
  /// The returned [DeliveryPing] will have its `id` field set.
  Future<DeliveryPing?> upsertRow(
    _is.DatabaseSession session,
    DeliveryPing row, {
    required _is.ColumnSelections<DeliveryPingTable> conflictColumns,
    _is.ColumnSelections<DeliveryPingTable>? updateColumns,
    _is.WhereExpressionBuilder<DeliveryPingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DeliveryPing>(
      row,
      conflictColumns: conflictColumns(DeliveryPing.t),
      updateColumns: updateColumns?.call(DeliveryPing.t),
      updateWhere: updateWhere?.call(DeliveryPing.t),
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryPing]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryPing>> update(
    _is.DatabaseSession session,
    List<DeliveryPing> rows, {
    _is.ColumnSelections<DeliveryPingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DeliveryPing>(
      rows,
      columns: columns?.call(DeliveryPing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DeliveryPing]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DeliveryPing> updateRow(
    _is.DatabaseSession session,
    DeliveryPing row, {
    _is.ColumnSelections<DeliveryPingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DeliveryPing>(
      row,
      columns: columns?.call(DeliveryPing.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeliveryPing] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DeliveryPing?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DeliveryPingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DeliveryPing>(
      id,
      columnValues: columnValues(DeliveryPing.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryPing]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryPing>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DeliveryPingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DeliveryPingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryPingTable>? orderBy,
    _is.OrderByListBuilder<DeliveryPingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DeliveryPing>(
      columnValues: columnValues(DeliveryPing.t.updateTable),
      where: where(DeliveryPing.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryPing.t),
      orderByList: orderByList?.call(DeliveryPing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DeliveryPing]s in the list and returns the deleted rows.
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
  Future<List<DeliveryPing>> delete(
    _is.DatabaseSession session,
    List<DeliveryPing> rows, {
    _is.OrderByBuilder<DeliveryPingTable>? orderBy,
    _is.OrderByListBuilder<DeliveryPingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DeliveryPing>(
      rows,
      orderBy: orderBy?.call(DeliveryPing.t),
      orderByList: orderByList?.call(DeliveryPing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DeliveryPing].
  Future<DeliveryPing> deleteRow(
    _is.DatabaseSession session,
    DeliveryPing row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DeliveryPing>(
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
  Future<List<DeliveryPing>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeliveryPingTable> where,
    _is.OrderByBuilder<DeliveryPingTable>? orderBy,
    _is.OrderByListBuilder<DeliveryPingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DeliveryPing>(
      where: where(DeliveryPing.t),
      orderBy: orderBy?.call(DeliveryPing.t),
      orderByList: orderByList?.call(DeliveryPing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryPingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DeliveryPing>(
      where: where?.call(DeliveryPing.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DeliveryPing] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeliveryPingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DeliveryPing>(
      where: where(DeliveryPing.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
