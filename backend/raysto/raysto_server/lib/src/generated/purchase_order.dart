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
import 'package:raysto_server/src/generated/protocol.dart' as _irq02k2f;
import 'package:serverpod/serverpod.dart' as _is;
import 'order_line.dart' as _i7utqy3k;

abstract class PurchaseOrder
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PurchaseOrder._({
    this.id,
    required this.restaurantId,
    required this.customerId,
    required this.requestKey,
    required this.requestHash,
    required this.fulfillment,
    this.address,
    required this.lines,
    required this.currency,
    required this.subtotalMinor,
    required this.deliveryFeeMinor,
    required this.totalMinor,
    required this.status,
    required this.paymentStatus,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrder({
    int? id,
    required int restaurantId,
    required String customerId,
    required String requestKey,
    required String requestHash,
    required String fulfillment,
    String? address,
    required List<_i7utqy3k.OrderLine> lines,
    required String currency,
    required int subtotalMinor,
    required int deliveryFeeMinor,
    required int totalMinor,
    required String status,
    required String paymentStatus,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseOrderImpl;

  factory PurchaseOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseOrder(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      customerId: jsonSerialization['customerId'] as String,
      requestKey: jsonSerialization['requestKey'] as String,
      requestHash: jsonSerialization['requestHash'] as String,
      fulfillment: jsonSerialization['fulfillment'] as String,
      address: jsonSerialization['address'] as String?,
      lines: _irq02k2f.Protocol().deserialize<List<_i7utqy3k.OrderLine>>(
        jsonSerialization['lines'],
      ),
      currency: jsonSerialization['currency'] as String,
      subtotalMinor: jsonSerialization['subtotalMinor'] as int,
      deliveryFeeMinor: jsonSerialization['deliveryFeeMinor'] as int,
      totalMinor: jsonSerialization['totalMinor'] as int,
      status: jsonSerialization['status'] as String,
      paymentStatus: jsonSerialization['paymentStatus'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PurchaseOrderTable();

  static const db = PurchaseOrderRepository._();

  @override
  int? id;

  int restaurantId;

  String customerId;

  String requestKey;

  String requestHash;

  String fulfillment;

  String? address;

  List<_i7utqy3k.OrderLine> lines;

  String currency;

  int subtotalMinor;

  int deliveryFeeMinor;

  int totalMinor;

  String status;

  String paymentStatus;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PurchaseOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PurchaseOrder copyWith({
    int? id,
    int? restaurantId,
    String? customerId,
    String? requestKey,
    String? requestHash,
    String? fulfillment,
    String? address,
    List<_i7utqy3k.OrderLine>? lines,
    String? currency,
    int? subtotalMinor,
    int? deliveryFeeMinor,
    int? totalMinor,
    String? status,
    String? paymentStatus,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseOrder',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'customerId': customerId,
      'requestKey': requestKey,
      'requestHash': requestHash,
      'fulfillment': fulfillment,
      if (address != null) 'address': address,
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
      'currency': currency,
      'subtotalMinor': subtotalMinor,
      'deliveryFeeMinor': deliveryFeeMinor,
      'totalMinor': totalMinor,
      'status': status,
      'paymentStatus': paymentStatus,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseOrder',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'customerId': customerId,
      'requestKey': requestKey,
      'requestHash': requestHash,
      'fulfillment': fulfillment,
      if (address != null) 'address': address,
      'lines': lines.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'currency': currency,
      'subtotalMinor': subtotalMinor,
      'deliveryFeeMinor': deliveryFeeMinor,
      'totalMinor': totalMinor,
      'status': status,
      'paymentStatus': paymentStatus,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static PurchaseOrderInclude include() {
    return PurchaseOrderInclude._();
  }

  static PurchaseOrderIncludeList includeList({
    _is.WhereExpressionBuilder<PurchaseOrderTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseOrderTable>? orderBy,
    _is.OrderByListBuilder<PurchaseOrderTable>? orderByList,
    PurchaseOrderInclude? include,
  }) {
    return PurchaseOrderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseOrder.t),
      orderByList: orderByList?.call(PurchaseOrder.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseOrderImpl extends PurchaseOrder {
  _PurchaseOrderImpl({
    int? id,
    required int restaurantId,
    required String customerId,
    required String requestKey,
    required String requestHash,
    required String fulfillment,
    String? address,
    required List<_i7utqy3k.OrderLine> lines,
    required String currency,
    required int subtotalMinor,
    required int deliveryFeeMinor,
    required int totalMinor,
    required String status,
    required String paymentStatus,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         customerId: customerId,
         requestKey: requestKey,
         requestHash: requestHash,
         fulfillment: fulfillment,
         address: address,
         lines: lines,
         currency: currency,
         subtotalMinor: subtotalMinor,
         deliveryFeeMinor: deliveryFeeMinor,
         totalMinor: totalMinor,
         status: status,
         paymentStatus: paymentStatus,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PurchaseOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PurchaseOrder copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? customerId,
    String? requestKey,
    String? requestHash,
    String? fulfillment,
    Object? address = _Undefined,
    List<_i7utqy3k.OrderLine>? lines,
    String? currency,
    int? subtotalMinor,
    int? deliveryFeeMinor,
    int? totalMinor,
    String? status,
    String? paymentStatus,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      customerId: customerId ?? this.customerId,
      requestKey: requestKey ?? this.requestKey,
      requestHash: requestHash ?? this.requestHash,
      fulfillment: fulfillment ?? this.fulfillment,
      address: address is String? ? address : this.address,
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
      currency: currency ?? this.currency,
      subtotalMinor: subtotalMinor ?? this.subtotalMinor,
      deliveryFeeMinor: deliveryFeeMinor ?? this.deliveryFeeMinor,
      totalMinor: totalMinor ?? this.totalMinor,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PurchaseOrderUpdateTable extends _is.UpdateTable<PurchaseOrderTable> {
  PurchaseOrderUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> customerId(String value) => _is.ColumnValue(
    table.customerId,
    value,
  );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<String, String> requestHash(String value) => _is.ColumnValue(
    table.requestHash,
    value,
  );

  _is.ColumnValue<String, String> fulfillment(String value) => _is.ColumnValue(
    table.fulfillment,
    value,
  );

  _is.ColumnValue<String, String> address(String? value) => _is.ColumnValue(
    table.address,
    value,
  );

  _is.ColumnValue<List<_i7utqy3k.OrderLine>, List<_i7utqy3k.OrderLine>> lines(
    List<_i7utqy3k.OrderLine> value,
  ) => _is.ColumnValue(
    table.lines,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<int, int> subtotalMinor(int value) => _is.ColumnValue(
    table.subtotalMinor,
    value,
  );

  _is.ColumnValue<int, int> deliveryFeeMinor(int value) => _is.ColumnValue(
    table.deliveryFeeMinor,
    value,
  );

  _is.ColumnValue<int, int> totalMinor(int value) => _is.ColumnValue(
    table.totalMinor,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> paymentStatus(String value) =>
      _is.ColumnValue(
        table.paymentStatus,
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

class PurchaseOrderTable extends _is.Table<int?> {
  PurchaseOrderTable({super.tableRelation}) : super(tableName: 'raysto_order') {
    updateTable = PurchaseOrderUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    customerId = _is.ColumnString(
      'customerId',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    requestHash = _is.ColumnString(
      'requestHash',
      this,
    );
    fulfillment = _is.ColumnString(
      'fulfillment',
      this,
    );
    address = _is.ColumnString(
      'address',
      this,
    );
    lines = _is.ColumnSerializable<List<_i7utqy3k.OrderLine>>(
      'lines',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    subtotalMinor = _is.ColumnInt(
      'subtotalMinor',
      this,
    );
    deliveryFeeMinor = _is.ColumnInt(
      'deliveryFeeMinor',
      this,
    );
    totalMinor = _is.ColumnInt(
      'totalMinor',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    paymentStatus = _is.ColumnString(
      'paymentStatus',
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

  late final PurchaseOrderUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString customerId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnString requestHash;

  late final _is.ColumnString fulfillment;

  late final _is.ColumnString address;

  late final _is.ColumnSerializable<List<_i7utqy3k.OrderLine>> lines;

  late final _is.ColumnString currency;

  late final _is.ColumnInt subtotalMinor;

  late final _is.ColumnInt deliveryFeeMinor;

  late final _is.ColumnInt totalMinor;

  late final _is.ColumnString status;

  late final _is.ColumnString paymentStatus;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    customerId,
    requestKey,
    requestHash,
    fulfillment,
    address,
    lines,
    currency,
    subtotalMinor,
    deliveryFeeMinor,
    totalMinor,
    status,
    paymentStatus,
    version,
    createdAt,
    updatedAt,
  ];
}

class PurchaseOrderInclude extends _is.IncludeObject {
  PurchaseOrderInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PurchaseOrder.t;
}

class PurchaseOrderIncludeList extends _is.IncludeList {
  PurchaseOrderIncludeList._({
    _is.WhereExpressionBuilder<PurchaseOrderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PurchaseOrder.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PurchaseOrder.t;
}

class PurchaseOrderRepository {
  const PurchaseOrderRepository._();

  /// Returns a list of [PurchaseOrder]s matching the given query parameters.
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
  Future<List<PurchaseOrder>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseOrderTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseOrderTable>? orderBy,
    _is.OrderByListBuilder<PurchaseOrderTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PurchaseOrder>(
      where: where?.call(PurchaseOrder.t),
      orderBy: orderBy?.call(PurchaseOrder.t),
      orderByList: orderByList?.call(PurchaseOrder.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PurchaseOrder] matching the given query parameters.
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
  Future<PurchaseOrder?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseOrderTable>? where,
    int? offset,
    _is.OrderByBuilder<PurchaseOrderTable>? orderBy,
    _is.OrderByListBuilder<PurchaseOrderTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PurchaseOrder>(
      where: where?.call(PurchaseOrder.t),
      orderBy: orderBy?.call(PurchaseOrder.t),
      orderByList: orderByList?.call(PurchaseOrder.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PurchaseOrder] by its [id] or null if no such row exists.
  Future<PurchaseOrder?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PurchaseOrder>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PurchaseOrder]s in the list and returns the inserted rows.
  ///
  /// The returned [PurchaseOrder]s will have their `id` fields set.
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
  Future<List<PurchaseOrder>> insert(
    _is.DatabaseSession session,
    List<PurchaseOrder> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PurchaseOrder>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PurchaseOrder] and returns the inserted row.
  ///
  /// The returned [PurchaseOrder] will have its `id` field set.
  Future<PurchaseOrder> insertRow(
    _is.DatabaseSession session,
    PurchaseOrder row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PurchaseOrder>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PurchaseOrder]s in the list and returns the resulting rows.
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
  /// The returned [PurchaseOrder]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseOrder>> upsert(
    _is.DatabaseSession session,
    List<PurchaseOrder> rows, {
    required _is.ColumnSelections<PurchaseOrderTable> conflictColumns,
    _is.ColumnSelections<PurchaseOrderTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseOrderTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PurchaseOrder>(
      rows,
      conflictColumns: conflictColumns(PurchaseOrder.t),
      updateColumns: updateColumns?.call(PurchaseOrder.t),
      updateWhere: updateWhere?.call(PurchaseOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PurchaseOrder] and returns the resulting row.
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
  /// The returned [PurchaseOrder] will have its `id` field set.
  Future<PurchaseOrder?> upsertRow(
    _is.DatabaseSession session,
    PurchaseOrder row, {
    required _is.ColumnSelections<PurchaseOrderTable> conflictColumns,
    _is.ColumnSelections<PurchaseOrderTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseOrderTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PurchaseOrder>(
      row,
      conflictColumns: conflictColumns(PurchaseOrder.t),
      updateColumns: updateColumns?.call(PurchaseOrder.t),
      updateWhere: updateWhere?.call(PurchaseOrder.t),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseOrder]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseOrder>> update(
    _is.DatabaseSession session,
    List<PurchaseOrder> rows, {
    _is.ColumnSelections<PurchaseOrderTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PurchaseOrder>(
      rows,
      columns: columns?.call(PurchaseOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PurchaseOrder]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PurchaseOrder> updateRow(
    _is.DatabaseSession session,
    PurchaseOrder row, {
    _is.ColumnSelections<PurchaseOrderTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PurchaseOrder>(
      row,
      columns: columns?.call(PurchaseOrder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PurchaseOrder] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PurchaseOrder?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PurchaseOrderUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PurchaseOrder>(
      id,
      columnValues: columnValues(PurchaseOrder.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseOrder]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseOrder>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PurchaseOrderUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PurchaseOrderTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseOrderTable>? orderBy,
    _is.OrderByListBuilder<PurchaseOrderTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PurchaseOrder>(
      columnValues: columnValues(PurchaseOrder.t.updateTable),
      where: where(PurchaseOrder.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseOrder.t),
      orderByList: orderByList?.call(PurchaseOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PurchaseOrder]s in the list and returns the deleted rows.
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
  Future<List<PurchaseOrder>> delete(
    _is.DatabaseSession session,
    List<PurchaseOrder> rows, {
    _is.OrderByBuilder<PurchaseOrderTable>? orderBy,
    _is.OrderByListBuilder<PurchaseOrderTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PurchaseOrder>(
      rows,
      orderBy: orderBy?.call(PurchaseOrder.t),
      orderByList: orderByList?.call(PurchaseOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PurchaseOrder].
  Future<PurchaseOrder> deleteRow(
    _is.DatabaseSession session,
    PurchaseOrder row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PurchaseOrder>(
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
  Future<List<PurchaseOrder>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseOrderTable> where,
    _is.OrderByBuilder<PurchaseOrderTable>? orderBy,
    _is.OrderByListBuilder<PurchaseOrderTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PurchaseOrder>(
      where: where(PurchaseOrder.t),
      orderBy: orderBy?.call(PurchaseOrder.t),
      orderByList: orderByList?.call(PurchaseOrder.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseOrderTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseOrder>(
      where: where?.call(PurchaseOrder.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PurchaseOrder] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseOrderTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PurchaseOrder>(
      where: where(PurchaseOrder.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
