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

abstract class Complaint
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Complaint._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    this.captureId,
    this.userId,
    required this.text,
    required this.status,
    this.refundId,
    this.taskId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint({
    int? id,
    required int restaurantId,
    required int orderId,
    int? captureId,
    String? userId,
    required String text,
    required String status,
    int? refundId,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ComplaintImpl;

  factory Complaint.fromJson(Map<String, dynamic> jsonSerialization) {
    return Complaint(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      captureId: jsonSerialization['captureId'] as int?,
      userId: jsonSerialization['userId'] as String?,
      text: jsonSerialization['text'] as String,
      status: jsonSerialization['status'] as String,
      refundId: jsonSerialization['refundId'] as int?,
      taskId: jsonSerialization['taskId'] as int?,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = ComplaintTable();

  static const db = ComplaintRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  int? captureId;

  String? userId;

  String text;

  String status;

  int? refundId;

  int? taskId;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Complaint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Complaint copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    int? captureId,
    String? userId,
    String? text,
    String? status,
    int? refundId,
    int? taskId,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Complaint',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      if (captureId != null) 'captureId': captureId,
      if (userId != null) 'userId': userId,
      'text': text,
      'status': status,
      if (refundId != null) 'refundId': refundId,
      if (taskId != null) 'taskId': taskId,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ComplaintInclude include() {
    return ComplaintInclude._();
  }

  static ComplaintIncludeList includeList({
    _is.WhereExpressionBuilder<ComplaintTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ComplaintTable>? orderBy,
    _is.OrderByListBuilder<ComplaintTable>? orderByList,
    ComplaintInclude? include,
  }) {
    return ComplaintIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Complaint.t),
      orderByList: orderByList?.call(Complaint.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ComplaintImpl extends Complaint {
  _ComplaintImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    int? captureId,
    String? userId,
    required String text,
    required String status,
    int? refundId,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         captureId: captureId,
         userId: userId,
         text: text,
         status: status,
         refundId: refundId,
         taskId: taskId,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Complaint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Complaint copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    Object? captureId = _Undefined,
    Object? userId = _Undefined,
    String? text,
    String? status,
    Object? refundId = _Undefined,
    Object? taskId = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Complaint(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      captureId: captureId is int? ? captureId : this.captureId,
      userId: userId is String? ? userId : this.userId,
      text: text ?? this.text,
      status: status ?? this.status,
      refundId: refundId is int? ? refundId : this.refundId,
      taskId: taskId is int? ? taskId : this.taskId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ComplaintUpdateTable extends _is.UpdateTable<ComplaintTable> {
  ComplaintUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<int, int> captureId(int? value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> refundId(int? value) => _is.ColumnValue(
    table.refundId,
    value,
  );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
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

class ComplaintTable extends _is.Table<int?> {
  ComplaintTable({super.tableRelation}) : super(tableName: 'raysto_complaint') {
    updateTable = ComplaintUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    captureId = _is.ColumnInt(
      'captureId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    refundId = _is.ColumnInt(
      'refundId',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
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

  late final ComplaintUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnInt captureId;

  late final _is.ColumnString userId;

  late final _is.ColumnString text;

  late final _is.ColumnString status;

  late final _is.ColumnInt refundId;

  late final _is.ColumnInt taskId;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    captureId,
    userId,
    text,
    status,
    refundId,
    taskId,
    version,
    createdAt,
    updatedAt,
  ];
}

class ComplaintInclude extends _is.IncludeObject {
  ComplaintInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Complaint.t;
}

class ComplaintIncludeList extends _is.IncludeList {
  ComplaintIncludeList._({
    _is.WhereExpressionBuilder<ComplaintTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Complaint.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Complaint.t;
}

class ComplaintRepository {
  const ComplaintRepository._();

  /// Returns a list of [Complaint]s matching the given query parameters.
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
  Future<List<Complaint>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ComplaintTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ComplaintTable>? orderBy,
    _is.OrderByListBuilder<ComplaintTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Complaint>(
      where: where?.call(Complaint.t),
      orderBy: orderBy?.call(Complaint.t),
      orderByList: orderByList?.call(Complaint.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Complaint] matching the given query parameters.
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
  Future<Complaint?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ComplaintTable>? where,
    int? offset,
    _is.OrderByBuilder<ComplaintTable>? orderBy,
    _is.OrderByListBuilder<ComplaintTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Complaint>(
      where: where?.call(Complaint.t),
      orderBy: orderBy?.call(Complaint.t),
      orderByList: orderByList?.call(Complaint.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Complaint] by its [id] or null if no such row exists.
  Future<Complaint?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Complaint>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Complaint]s in the list and returns the inserted rows.
  ///
  /// The returned [Complaint]s will have their `id` fields set.
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
  Future<List<Complaint>> insert(
    _is.DatabaseSession session,
    List<Complaint> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Complaint>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Complaint] and returns the inserted row.
  ///
  /// The returned [Complaint] will have its `id` field set.
  Future<Complaint> insertRow(
    _is.DatabaseSession session,
    Complaint row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Complaint>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Complaint]s in the list and returns the resulting rows.
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
  /// The returned [Complaint]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Complaint>> upsert(
    _is.DatabaseSession session,
    List<Complaint> rows, {
    required _is.ColumnSelections<ComplaintTable> conflictColumns,
    _is.ColumnSelections<ComplaintTable>? updateColumns,
    _is.WhereExpressionBuilder<ComplaintTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Complaint>(
      rows,
      conflictColumns: conflictColumns(Complaint.t),
      updateColumns: updateColumns?.call(Complaint.t),
      updateWhere: updateWhere?.call(Complaint.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Complaint] and returns the resulting row.
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
  /// The returned [Complaint] will have its `id` field set.
  Future<Complaint?> upsertRow(
    _is.DatabaseSession session,
    Complaint row, {
    required _is.ColumnSelections<ComplaintTable> conflictColumns,
    _is.ColumnSelections<ComplaintTable>? updateColumns,
    _is.WhereExpressionBuilder<ComplaintTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Complaint>(
      row,
      conflictColumns: conflictColumns(Complaint.t),
      updateColumns: updateColumns?.call(Complaint.t),
      updateWhere: updateWhere?.call(Complaint.t),
      transaction: transaction,
    );
  }

  /// Updates all [Complaint]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Complaint>> update(
    _is.DatabaseSession session,
    List<Complaint> rows, {
    _is.ColumnSelections<ComplaintTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Complaint>(
      rows,
      columns: columns?.call(Complaint.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Complaint]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Complaint> updateRow(
    _is.DatabaseSession session,
    Complaint row, {
    _is.ColumnSelections<ComplaintTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Complaint>(
      row,
      columns: columns?.call(Complaint.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Complaint] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Complaint?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ComplaintUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Complaint>(
      id,
      columnValues: columnValues(Complaint.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Complaint]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Complaint>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ComplaintUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ComplaintTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ComplaintTable>? orderBy,
    _is.OrderByListBuilder<ComplaintTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Complaint>(
      columnValues: columnValues(Complaint.t.updateTable),
      where: where(Complaint.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Complaint.t),
      orderByList: orderByList?.call(Complaint.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Complaint]s in the list and returns the deleted rows.
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
  Future<List<Complaint>> delete(
    _is.DatabaseSession session,
    List<Complaint> rows, {
    _is.OrderByBuilder<ComplaintTable>? orderBy,
    _is.OrderByListBuilder<ComplaintTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Complaint>(
      rows,
      orderBy: orderBy?.call(Complaint.t),
      orderByList: orderByList?.call(Complaint.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Complaint].
  Future<Complaint> deleteRow(
    _is.DatabaseSession session,
    Complaint row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Complaint>(
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
  Future<List<Complaint>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ComplaintTable> where,
    _is.OrderByBuilder<ComplaintTable>? orderBy,
    _is.OrderByListBuilder<ComplaintTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Complaint>(
      where: where(Complaint.t),
      orderBy: orderBy?.call(Complaint.t),
      orderByList: orderByList?.call(Complaint.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ComplaintTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Complaint>(
      where: where?.call(Complaint.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Complaint] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ComplaintTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Complaint>(
      where: where(Complaint.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
