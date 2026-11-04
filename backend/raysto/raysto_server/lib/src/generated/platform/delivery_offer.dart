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

abstract class DeliveryOffer
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DeliveryOffer._({
    this.id,
    required this.restaurantId,
    required this.assignmentId,
    required this.driverId,
    required this.state,
    required this.expiresAt,
    required this.score,
    required this.reasonJson,
    required this.createdAt,
    this.respondedAt,
  });

  factory DeliveryOffer({
    int? id,
    required int restaurantId,
    required int assignmentId,
    required int driverId,
    required String state,
    required DateTime expiresAt,
    required double score,
    required String reasonJson,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _DeliveryOfferImpl;

  factory DeliveryOffer.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeliveryOffer(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      assignmentId: jsonSerialization['assignmentId'] as int,
      driverId: jsonSerialization['driverId'] as int,
      state: jsonSerialization['state'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      score: (jsonSerialization['score'] as num).toDouble(),
      reasonJson: jsonSerialization['reasonJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      respondedAt: jsonSerialization['respondedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['respondedAt'],
            ),
    );
  }

  static final t = DeliveryOfferTable();

  static const db = DeliveryOfferRepository._();

  @override
  int? id;

  int restaurantId;

  int assignmentId;

  int driverId;

  String state;

  DateTime expiresAt;

  double score;

  String reasonJson;

  DateTime createdAt;

  DateTime? respondedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DeliveryOffer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeliveryOffer copyWith({
    int? id,
    int? restaurantId,
    int? assignmentId,
    int? driverId,
    String? state,
    DateTime? expiresAt,
    double? score,
    String? reasonJson,
    DateTime? createdAt,
    DateTime? respondedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeliveryOffer',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'assignmentId': assignmentId,
      'driverId': driverId,
      'state': state,
      'expiresAt': expiresAt.toJson(),
      'score': score,
      'reasonJson': reasonJson,
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DeliveryOfferInclude include() {
    return DeliveryOfferInclude._();
  }

  static DeliveryOfferIncludeList includeList({
    _is.WhereExpressionBuilder<DeliveryOfferTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryOfferTable>? orderBy,
    _is.OrderByListBuilder<DeliveryOfferTable>? orderByList,
    DeliveryOfferInclude? include,
  }) {
    return DeliveryOfferIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryOffer.t),
      orderByList: orderByList?.call(DeliveryOffer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeliveryOfferImpl extends DeliveryOffer {
  _DeliveryOfferImpl({
    int? id,
    required int restaurantId,
    required int assignmentId,
    required int driverId,
    required String state,
    required DateTime expiresAt,
    required double score,
    required String reasonJson,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         assignmentId: assignmentId,
         driverId: driverId,
         state: state,
         expiresAt: expiresAt,
         score: score,
         reasonJson: reasonJson,
         createdAt: createdAt,
         respondedAt: respondedAt,
       );

  /// Returns a shallow copy of this [DeliveryOffer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeliveryOffer copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? assignmentId,
    int? driverId,
    String? state,
    DateTime? expiresAt,
    double? score,
    String? reasonJson,
    DateTime? createdAt,
    Object? respondedAt = _Undefined,
  }) {
    return DeliveryOffer(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      assignmentId: assignmentId ?? this.assignmentId,
      driverId: driverId ?? this.driverId,
      state: state ?? this.state,
      expiresAt: expiresAt ?? this.expiresAt,
      score: score ?? this.score,
      reasonJson: reasonJson ?? this.reasonJson,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt is DateTime? ? respondedAt : this.respondedAt,
    );
  }
}

class DeliveryOfferUpdateTable extends _is.UpdateTable<DeliveryOfferTable> {
  DeliveryOfferUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> assignmentId(int value) => _is.ColumnValue(
    table.assignmentId,
    value,
  );

  _is.ColumnValue<int, int> driverId(int value) => _is.ColumnValue(
    table.driverId,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<double, double> score(double value) => _is.ColumnValue(
    table.score,
    value,
  );

  _is.ColumnValue<String, String> reasonJson(String value) => _is.ColumnValue(
    table.reasonJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> respondedAt(DateTime? value) =>
      _is.ColumnValue(
        table.respondedAt,
        value,
      );
}

class DeliveryOfferTable extends _is.Table<int?> {
  DeliveryOfferTable({super.tableRelation})
    : super(tableName: 'raysto_delivery_offer') {
    updateTable = DeliveryOfferUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    assignmentId = _is.ColumnInt(
      'assignmentId',
      this,
    );
    driverId = _is.ColumnInt(
      'driverId',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    score = _is.ColumnDouble(
      'score',
      this,
    );
    reasonJson = _is.ColumnString(
      'reasonJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    respondedAt = _is.ColumnDateTime(
      'respondedAt',
      this,
    );
  }

  late final DeliveryOfferUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt assignmentId;

  late final _is.ColumnInt driverId;

  late final _is.ColumnString state;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDouble score;

  late final _is.ColumnString reasonJson;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime respondedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    assignmentId,
    driverId,
    state,
    expiresAt,
    score,
    reasonJson,
    createdAt,
    respondedAt,
  ];
}

class DeliveryOfferInclude extends _is.IncludeObject {
  DeliveryOfferInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DeliveryOffer.t;
}

class DeliveryOfferIncludeList extends _is.IncludeList {
  DeliveryOfferIncludeList._({
    _is.WhereExpressionBuilder<DeliveryOfferTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DeliveryOffer.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DeliveryOffer.t;
}

class DeliveryOfferRepository {
  const DeliveryOfferRepository._();

  /// Returns a list of [DeliveryOffer]s matching the given query parameters.
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
  Future<List<DeliveryOffer>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryOfferTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryOfferTable>? orderBy,
    _is.OrderByListBuilder<DeliveryOfferTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DeliveryOffer>(
      where: where?.call(DeliveryOffer.t),
      orderBy: orderBy?.call(DeliveryOffer.t),
      orderByList: orderByList?.call(DeliveryOffer.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DeliveryOffer] matching the given query parameters.
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
  Future<DeliveryOffer?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryOfferTable>? where,
    int? offset,
    _is.OrderByBuilder<DeliveryOfferTable>? orderBy,
    _is.OrderByListBuilder<DeliveryOfferTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DeliveryOffer>(
      where: where?.call(DeliveryOffer.t),
      orderBy: orderBy?.call(DeliveryOffer.t),
      orderByList: orderByList?.call(DeliveryOffer.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DeliveryOffer] by its [id] or null if no such row exists.
  Future<DeliveryOffer?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DeliveryOffer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DeliveryOffer]s in the list and returns the inserted rows.
  ///
  /// The returned [DeliveryOffer]s will have their `id` fields set.
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
  Future<List<DeliveryOffer>> insert(
    _is.DatabaseSession session,
    List<DeliveryOffer> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DeliveryOffer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DeliveryOffer] and returns the inserted row.
  ///
  /// The returned [DeliveryOffer] will have its `id` field set.
  Future<DeliveryOffer> insertRow(
    _is.DatabaseSession session,
    DeliveryOffer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DeliveryOffer>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DeliveryOffer]s in the list and returns the resulting rows.
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
  /// The returned [DeliveryOffer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryOffer>> upsert(
    _is.DatabaseSession session,
    List<DeliveryOffer> rows, {
    required _is.ColumnSelections<DeliveryOfferTable> conflictColumns,
    _is.ColumnSelections<DeliveryOfferTable>? updateColumns,
    _is.WhereExpressionBuilder<DeliveryOfferTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DeliveryOffer>(
      rows,
      conflictColumns: conflictColumns(DeliveryOffer.t),
      updateColumns: updateColumns?.call(DeliveryOffer.t),
      updateWhere: updateWhere?.call(DeliveryOffer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DeliveryOffer] and returns the resulting row.
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
  /// The returned [DeliveryOffer] will have its `id` field set.
  Future<DeliveryOffer?> upsertRow(
    _is.DatabaseSession session,
    DeliveryOffer row, {
    required _is.ColumnSelections<DeliveryOfferTable> conflictColumns,
    _is.ColumnSelections<DeliveryOfferTable>? updateColumns,
    _is.WhereExpressionBuilder<DeliveryOfferTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DeliveryOffer>(
      row,
      conflictColumns: conflictColumns(DeliveryOffer.t),
      updateColumns: updateColumns?.call(DeliveryOffer.t),
      updateWhere: updateWhere?.call(DeliveryOffer.t),
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryOffer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryOffer>> update(
    _is.DatabaseSession session,
    List<DeliveryOffer> rows, {
    _is.ColumnSelections<DeliveryOfferTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DeliveryOffer>(
      rows,
      columns: columns?.call(DeliveryOffer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DeliveryOffer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DeliveryOffer> updateRow(
    _is.DatabaseSession session,
    DeliveryOffer row, {
    _is.ColumnSelections<DeliveryOfferTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DeliveryOffer>(
      row,
      columns: columns?.call(DeliveryOffer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeliveryOffer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DeliveryOffer?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DeliveryOfferUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DeliveryOffer>(
      id,
      columnValues: columnValues(DeliveryOffer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryOffer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeliveryOffer>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DeliveryOfferUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DeliveryOfferTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeliveryOfferTable>? orderBy,
    _is.OrderByListBuilder<DeliveryOfferTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DeliveryOffer>(
      columnValues: columnValues(DeliveryOffer.t.updateTable),
      where: where(DeliveryOffer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryOffer.t),
      orderByList: orderByList?.call(DeliveryOffer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DeliveryOffer]s in the list and returns the deleted rows.
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
  Future<List<DeliveryOffer>> delete(
    _is.DatabaseSession session,
    List<DeliveryOffer> rows, {
    _is.OrderByBuilder<DeliveryOfferTable>? orderBy,
    _is.OrderByListBuilder<DeliveryOfferTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DeliveryOffer>(
      rows,
      orderBy: orderBy?.call(DeliveryOffer.t),
      orderByList: orderByList?.call(DeliveryOffer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DeliveryOffer].
  Future<DeliveryOffer> deleteRow(
    _is.DatabaseSession session,
    DeliveryOffer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DeliveryOffer>(
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
  Future<List<DeliveryOffer>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeliveryOfferTable> where,
    _is.OrderByBuilder<DeliveryOfferTable>? orderBy,
    _is.OrderByListBuilder<DeliveryOfferTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DeliveryOffer>(
      where: where(DeliveryOffer.t),
      orderBy: orderBy?.call(DeliveryOffer.t),
      orderByList: orderByList?.call(DeliveryOffer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeliveryOfferTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DeliveryOffer>(
      where: where?.call(DeliveryOffer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DeliveryOffer] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeliveryOfferTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DeliveryOffer>(
      where: where(DeliveryOffer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
