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

abstract class SupplierOrder
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SupplierOrder._({
    this.id,
    required this.restaurantId,
    this.supplierId,
    required this.state,
    required this.linesJson,
    required this.totalMinor,
    required this.currency,
    this.expectedAt,
    this.sentAt,
    this.receivedAt,
    this.billId,
    this.taskId,
    this.note,
    required this.createdBy,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierOrder({
    int? id,
    required int restaurantId,
    int? supplierId,
    required String state,
    required String linesJson,
    required int totalMinor,
    required String currency,
    DateTime? expectedAt,
    DateTime? sentAt,
    DateTime? receivedAt,
    int? billId,
    int? taskId,
    String? note,
    required String createdBy,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SupplierOrderImpl;

  factory SupplierOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return SupplierOrder(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      supplierId: jsonSerialization['supplierId'] as int?,
      state: jsonSerialization['state'] as String,
      linesJson: jsonSerialization['linesJson'] as String,
      totalMinor: jsonSerialization['totalMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      expectedAt: jsonSerialization['expectedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['expectedAt']),
      sentAt: jsonSerialization['sentAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['receivedAt']),
      billId: jsonSerialization['billId'] as int?,
      taskId: jsonSerialization['taskId'] as int?,
      note: jsonSerialization['note'] as String?,
      createdBy: jsonSerialization['createdBy'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = SupplierOrderTable();

  static const db = SupplierOrderRepository._();

  @override
  int? id;

  int restaurantId;

  int? supplierId;

  String state;

  String linesJson;

  int totalMinor;

  String currency;

  DateTime? expectedAt;

  DateTime? sentAt;

  DateTime? receivedAt;

  int? billId;

  int? taskId;

  String? note;

  String createdBy;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SupplierOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SupplierOrder copyWith({
    int? id,
    int? restaurantId,
    int? supplierId,
    String? state,
    String? linesJson,
    int? totalMinor,
    String? currency,
    DateTime? expectedAt,
    DateTime? sentAt,
    DateTime? receivedAt,
    int? billId,
    int? taskId,
    String? note,
    String? createdBy,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SupplierOrder',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      if (supplierId != null) 'supplierId': supplierId,
      'state': state,
      'linesJson': linesJson,
      'totalMinor': totalMinor,
      'currency': currency,
      if (expectedAt != null) 'expectedAt': expectedAt?.toJson(),
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
      if (billId != null) 'billId': billId,
      if (taskId != null) 'taskId': taskId,
      if (note != null) 'note': note,
      'createdBy': createdBy,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SupplierOrderInclude include() {
    return SupplierOrderInclude._();
  }

  static SupplierOrderIncludeList includeList({
    _is.WhereExpressionBuilder<SupplierOrderTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierOrderTable>? orderBy,
    _is.OrderByListBuilder<SupplierOrderTable>? orderByList,
    SupplierOrderInclude? include,
  }) {
    return SupplierOrderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupplierOrder.t),
      orderByList: orderByList?.call(SupplierOrder.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SupplierOrderImpl extends SupplierOrder {
  _SupplierOrderImpl({
    int? id,
    required int restaurantId,
    int? supplierId,
    required String state,
    required String linesJson,
    required int totalMinor,
    required String currency,
    DateTime? expectedAt,
    DateTime? sentAt,
    DateTime? receivedAt,
    int? billId,
    int? taskId,
    String? note,
    required String createdBy,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         supplierId: supplierId,
         state: state,
         linesJson: linesJson,
         totalMinor: totalMinor,
         currency: currency,
         expectedAt: expectedAt,
         sentAt: sentAt,
         receivedAt: receivedAt,
         billId: billId,
         taskId: taskId,
         note: note,
         createdBy: createdBy,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SupplierOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SupplierOrder copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    Object? supplierId = _Undefined,
    String? state,
    String? linesJson,
    int? totalMinor,
    String? currency,
    Object? expectedAt = _Undefined,
    Object? sentAt = _Undefined,
    Object? receivedAt = _Undefined,
    Object? billId = _Undefined,
    Object? taskId = _Undefined,
    Object? note = _Undefined,
    String? createdBy,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierOrder(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      supplierId: supplierId is int? ? supplierId : this.supplierId,
      state: state ?? this.state,
      linesJson: linesJson ?? this.linesJson,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      expectedAt: expectedAt is DateTime? ? expectedAt : this.expectedAt,
      sentAt: sentAt is DateTime? ? sentAt : this.sentAt,
      receivedAt: receivedAt is DateTime? ? receivedAt : this.receivedAt,
      billId: billId is int? ? billId : this.billId,
      taskId: taskId is int? ? taskId : this.taskId,
      note: note is String? ? note : this.note,
      createdBy: createdBy ?? this.createdBy,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SupplierOrderUpdateTable extends _is.UpdateTable<SupplierOrderTable> {
  SupplierOrderUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> supplierId(int? value) => _is.ColumnValue(
    table.supplierId,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> linesJson(String value) => _is.ColumnValue(
    table.linesJson,
    value,
  );

  _is.ColumnValue<int, int> totalMinor(int value) => _is.ColumnValue(
    table.totalMinor,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expectedAt(DateTime? value) =>
      _is.ColumnValue(
        table.expectedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> sentAt(DateTime? value) =>
      _is.ColumnValue(
        table.sentAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime? value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<int, int> billId(int? value) => _is.ColumnValue(
    table.billId,
    value,
  );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
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

class SupplierOrderTable extends _is.Table<int?> {
  SupplierOrderTable({super.tableRelation})
    : super(tableName: 'raysto_supplier_order') {
    updateTable = SupplierOrderUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    supplierId = _is.ColumnInt(
      'supplierId',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    linesJson = _is.ColumnString(
      'linesJson',
      this,
    );
    totalMinor = _is.ColumnInt(
      'totalMinor',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    expectedAt = _is.ColumnDateTime(
      'expectedAt',
      this,
    );
    sentAt = _is.ColumnDateTime(
      'sentAt',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
    billId = _is.ColumnInt(
      'billId',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
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

  late final SupplierOrderUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt supplierId;

  late final _is.ColumnString state;

  late final _is.ColumnString linesJson;

  late final _is.ColumnInt totalMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime expectedAt;

  late final _is.ColumnDateTime sentAt;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnInt billId;

  late final _is.ColumnInt taskId;

  late final _is.ColumnString note;

  late final _is.ColumnString createdBy;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    supplierId,
    state,
    linesJson,
    totalMinor,
    currency,
    expectedAt,
    sentAt,
    receivedAt,
    billId,
    taskId,
    note,
    createdBy,
    version,
    createdAt,
    updatedAt,
  ];
}

class SupplierOrderInclude extends _is.IncludeObject {
  SupplierOrderInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SupplierOrder.t;
}

class SupplierOrderIncludeList extends _is.IncludeList {
  SupplierOrderIncludeList._({
    _is.WhereExpressionBuilder<SupplierOrderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SupplierOrder.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SupplierOrder.t;
}

class SupplierOrderRepository {
  const SupplierOrderRepository._();

  /// Returns a list of [SupplierOrder]s matching the given query parameters.
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
  Future<List<SupplierOrder>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierOrderTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierOrderTable>? orderBy,
    _is.OrderByListBuilder<SupplierOrderTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SupplierOrder>(
      where: where?.call(SupplierOrder.t),
      orderBy: orderBy?.call(SupplierOrder.t),
      orderByList: orderByList?.call(SupplierOrder.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SupplierOrder] matching the given query parameters.
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
  Future<SupplierOrder?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierOrderTable>? where,
    int? offset,
    _is.OrderByBuilder<SupplierOrderTable>? orderBy,
    _is.OrderByListBuilder<SupplierOrderTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SupplierOrder>(
      where: where?.call(SupplierOrder.t),
      orderBy: orderBy?.call(SupplierOrder.t),
      orderByList: orderByList?.call(SupplierOrder.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SupplierOrder] by its [id] or null if no such row exists.
  Future<SupplierOrder?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SupplierOrder>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SupplierOrder]s in the list and returns the inserted rows.
  ///
  /// The returned [SupplierOrder]s will have their `id` fields set.
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
  Future<List<SupplierOrder>> insert(
    _is.DatabaseSession session,
    List<SupplierOrder> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SupplierOrder>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SupplierOrder] and returns the inserted row.
  ///
  /// The returned [SupplierOrder] will have its `id` field set.
  Future<SupplierOrder> insertRow(
    _is.DatabaseSession session,
    SupplierOrder row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SupplierOrder>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SupplierOrder]s in the list and returns the resulting rows.
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
  /// The returned [SupplierOrder]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupplierOrder>> upsert(
    _is.DatabaseSession session,
    List<SupplierOrder> rows, {
    required _is.ColumnSelections<SupplierOrderTable> conflictColumns,
    _is.ColumnSelections<SupplierOrderTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplierOrderTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SupplierOrder>(
      rows,
      conflictColumns: conflictColumns(SupplierOrder.t),
      updateColumns: updateColumns?.call(SupplierOrder.t),
      updateWhere: updateWhere?.call(SupplierOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SupplierOrder] and returns the resulting row.
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
  /// The returned [SupplierOrder] will have its `id` field set.
  Future<SupplierOrder?> upsertRow(
    _is.DatabaseSession session,
    SupplierOrder row, {
    required _is.ColumnSelections<SupplierOrderTable> conflictColumns,
    _is.ColumnSelections<SupplierOrderTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplierOrderTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SupplierOrder>(
      row,
      conflictColumns: conflictColumns(SupplierOrder.t),
      updateColumns: updateColumns?.call(SupplierOrder.t),
      updateWhere: updateWhere?.call(SupplierOrder.t),
      transaction: transaction,
    );
  }

  /// Updates all [SupplierOrder]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupplierOrder>> update(
    _is.DatabaseSession session,
    List<SupplierOrder> rows, {
    _is.ColumnSelections<SupplierOrderTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SupplierOrder>(
      rows,
      columns: columns?.call(SupplierOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SupplierOrder]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SupplierOrder> updateRow(
    _is.DatabaseSession session,
    SupplierOrder row, {
    _is.ColumnSelections<SupplierOrderTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SupplierOrder>(
      row,
      columns: columns?.call(SupplierOrder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SupplierOrder] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SupplierOrder?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SupplierOrderUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SupplierOrder>(
      id,
      columnValues: columnValues(SupplierOrder.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SupplierOrder]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SupplierOrder>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SupplierOrderUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SupplierOrderTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierOrderTable>? orderBy,
    _is.OrderByListBuilder<SupplierOrderTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SupplierOrder>(
      columnValues: columnValues(SupplierOrder.t.updateTable),
      where: where(SupplierOrder.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SupplierOrder.t),
      orderByList: orderByList?.call(SupplierOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SupplierOrder]s in the list and returns the deleted rows.
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
  Future<List<SupplierOrder>> delete(
    _is.DatabaseSession session,
    List<SupplierOrder> rows, {
    _is.OrderByBuilder<SupplierOrderTable>? orderBy,
    _is.OrderByListBuilder<SupplierOrderTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SupplierOrder>(
      rows,
      orderBy: orderBy?.call(SupplierOrder.t),
      orderByList: orderByList?.call(SupplierOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SupplierOrder].
  Future<SupplierOrder> deleteRow(
    _is.DatabaseSession session,
    SupplierOrder row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SupplierOrder>(
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
  Future<List<SupplierOrder>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplierOrderTable> where,
    _is.OrderByBuilder<SupplierOrderTable>? orderBy,
    _is.OrderByListBuilder<SupplierOrderTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SupplierOrder>(
      where: where(SupplierOrder.t),
      orderBy: orderBy?.call(SupplierOrder.t),
      orderByList: orderByList?.call(SupplierOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierOrderTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SupplierOrder>(
      where: where?.call(SupplierOrder.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SupplierOrder] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplierOrderTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SupplierOrder>(
      where: where(SupplierOrder.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
