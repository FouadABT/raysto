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

abstract class OrderContext
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  OrderContext._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    this.visitId,
    this.quoteId,
    required this.detailsJson,
    required this.paymentTiming,
    required this.cancellationRequested,
    required this.stockReleased,
    this.slotKey,
    this.couponCode,
    String? origin,
    this.customerLabel,
    this.placedBy,
    this.serviceDay,
    this.orderNumber,
    this.pickupCode,
    required this.createdAt,
  }) : origin = origin ?? 'online';

  factory OrderContext({
    int? id,
    required int restaurantId,
    required int orderId,
    int? visitId,
    int? quoteId,
    required String detailsJson,
    required String paymentTiming,
    required bool cancellationRequested,
    required bool stockReleased,
    String? slotKey,
    String? couponCode,
    String? origin,
    String? customerLabel,
    String? placedBy,
    String? serviceDay,
    int? orderNumber,
    String? pickupCode,
    required DateTime createdAt,
  }) = _OrderContextImpl;

  factory OrderContext.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderContext(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      visitId: jsonSerialization['visitId'] as int?,
      quoteId: jsonSerialization['quoteId'] as int?,
      detailsJson: jsonSerialization['detailsJson'] as String,
      paymentTiming: jsonSerialization['paymentTiming'] as String,
      cancellationRequested: _is.BoolJsonExtension.fromJson(
        jsonSerialization['cancellationRequested'],
      ),
      stockReleased: _is.BoolJsonExtension.fromJson(
        jsonSerialization['stockReleased'],
      ),
      slotKey: jsonSerialization['slotKey'] as String?,
      couponCode: jsonSerialization['couponCode'] as String?,
      origin: jsonSerialization['origin'] as String?,
      customerLabel: jsonSerialization['customerLabel'] as String?,
      placedBy: jsonSerialization['placedBy'] as String?,
      serviceDay: jsonSerialization['serviceDay'] as String?,
      orderNumber: jsonSerialization['orderNumber'] as int?,
      pickupCode: jsonSerialization['pickupCode'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = OrderContextTable();

  static const db = OrderContextRepository._();

  @override
  int? id;

  int restaurantId;

  int orderId;

  int? visitId;

  int? quoteId;

  String detailsJson;

  String paymentTiming;

  bool cancellationRequested;

  bool stockReleased;

  String? slotKey;

  String? couponCode;

  String origin;

  String? customerLabel;

  String? placedBy;

  String? serviceDay;

  int? orderNumber;

  String? pickupCode;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [OrderContext]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OrderContext copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    int? visitId,
    int? quoteId,
    String? detailsJson,
    String? paymentTiming,
    bool? cancellationRequested,
    bool? stockReleased,
    String? slotKey,
    String? couponCode,
    String? origin,
    String? customerLabel,
    String? placedBy,
    String? serviceDay,
    int? orderNumber,
    String? pickupCode,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderContext',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      if (visitId != null) 'visitId': visitId,
      if (quoteId != null) 'quoteId': quoteId,
      'detailsJson': detailsJson,
      'paymentTiming': paymentTiming,
      'cancellationRequested': cancellationRequested,
      'stockReleased': stockReleased,
      if (slotKey != null) 'slotKey': slotKey,
      if (couponCode != null) 'couponCode': couponCode,
      'origin': origin,
      if (customerLabel != null) 'customerLabel': customerLabel,
      if (placedBy != null) 'placedBy': placedBy,
      if (serviceDay != null) 'serviceDay': serviceDay,
      if (orderNumber != null) 'orderNumber': orderNumber,
      if (pickupCode != null) 'pickupCode': pickupCode,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static OrderContextInclude include() {
    return OrderContextInclude._();
  }

  static OrderContextIncludeList includeList({
    _is.WhereExpressionBuilder<OrderContextTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OrderContextTable>? orderBy,
    _is.OrderByListBuilder<OrderContextTable>? orderByList,
    OrderContextInclude? include,
  }) {
    return OrderContextIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrderContext.t),
      orderByList: orderByList?.call(OrderContext.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderContextImpl extends OrderContext {
  _OrderContextImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    int? visitId,
    int? quoteId,
    required String detailsJson,
    required String paymentTiming,
    required bool cancellationRequested,
    required bool stockReleased,
    String? slotKey,
    String? couponCode,
    String? origin,
    String? customerLabel,
    String? placedBy,
    String? serviceDay,
    int? orderNumber,
    String? pickupCode,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         visitId: visitId,
         quoteId: quoteId,
         detailsJson: detailsJson,
         paymentTiming: paymentTiming,
         cancellationRequested: cancellationRequested,
         stockReleased: stockReleased,
         slotKey: slotKey,
         couponCode: couponCode,
         origin: origin,
         customerLabel: customerLabel,
         placedBy: placedBy,
         serviceDay: serviceDay,
         orderNumber: orderNumber,
         pickupCode: pickupCode,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [OrderContext]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OrderContext copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    Object? visitId = _Undefined,
    Object? quoteId = _Undefined,
    String? detailsJson,
    String? paymentTiming,
    bool? cancellationRequested,
    bool? stockReleased,
    Object? slotKey = _Undefined,
    Object? couponCode = _Undefined,
    String? origin,
    Object? customerLabel = _Undefined,
    Object? placedBy = _Undefined,
    Object? serviceDay = _Undefined,
    Object? orderNumber = _Undefined,
    Object? pickupCode = _Undefined,
    DateTime? createdAt,
  }) {
    return OrderContext(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      visitId: visitId is int? ? visitId : this.visitId,
      quoteId: quoteId is int? ? quoteId : this.quoteId,
      detailsJson: detailsJson ?? this.detailsJson,
      paymentTiming: paymentTiming ?? this.paymentTiming,
      cancellationRequested:
          cancellationRequested ?? this.cancellationRequested,
      stockReleased: stockReleased ?? this.stockReleased,
      slotKey: slotKey is String? ? slotKey : this.slotKey,
      couponCode: couponCode is String? ? couponCode : this.couponCode,
      origin: origin ?? this.origin,
      customerLabel: customerLabel is String?
          ? customerLabel
          : this.customerLabel,
      placedBy: placedBy is String? ? placedBy : this.placedBy,
      serviceDay: serviceDay is String? ? serviceDay : this.serviceDay,
      orderNumber: orderNumber is int? ? orderNumber : this.orderNumber,
      pickupCode: pickupCode is String? ? pickupCode : this.pickupCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OrderContextUpdateTable extends _is.UpdateTable<OrderContextTable> {
  OrderContextUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<int, int> visitId(int? value) => _is.ColumnValue(
    table.visitId,
    value,
  );

  _is.ColumnValue<int, int> quoteId(int? value) => _is.ColumnValue(
    table.quoteId,
    value,
  );

  _is.ColumnValue<String, String> detailsJson(String value) => _is.ColumnValue(
    table.detailsJson,
    value,
  );

  _is.ColumnValue<String, String> paymentTiming(String value) =>
      _is.ColumnValue(
        table.paymentTiming,
        value,
      );

  _is.ColumnValue<bool, bool> cancellationRequested(bool value) =>
      _is.ColumnValue(
        table.cancellationRequested,
        value,
      );

  _is.ColumnValue<bool, bool> stockReleased(bool value) => _is.ColumnValue(
    table.stockReleased,
    value,
  );

  _is.ColumnValue<String, String> slotKey(String? value) => _is.ColumnValue(
    table.slotKey,
    value,
  );

  _is.ColumnValue<String, String> couponCode(String? value) => _is.ColumnValue(
    table.couponCode,
    value,
  );

  _is.ColumnValue<String, String> origin(String value) => _is.ColumnValue(
    table.origin,
    value,
  );

  _is.ColumnValue<String, String> customerLabel(String? value) =>
      _is.ColumnValue(
        table.customerLabel,
        value,
      );

  _is.ColumnValue<String, String> placedBy(String? value) => _is.ColumnValue(
    table.placedBy,
    value,
  );

  _is.ColumnValue<String, String> serviceDay(String? value) => _is.ColumnValue(
    table.serviceDay,
    value,
  );

  _is.ColumnValue<int, int> orderNumber(int? value) => _is.ColumnValue(
    table.orderNumber,
    value,
  );

  _is.ColumnValue<String, String> pickupCode(String? value) => _is.ColumnValue(
    table.pickupCode,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class OrderContextTable extends _is.Table<int?> {
  OrderContextTable({super.tableRelation})
    : super(tableName: 'raysto_order_context') {
    updateTable = OrderContextUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
      this,
    );
    quoteId = _is.ColumnInt(
      'quoteId',
      this,
    );
    detailsJson = _is.ColumnString(
      'detailsJson',
      this,
    );
    paymentTiming = _is.ColumnString(
      'paymentTiming',
      this,
    );
    cancellationRequested = _is.ColumnBool(
      'cancellationRequested',
      this,
    );
    stockReleased = _is.ColumnBool(
      'stockReleased',
      this,
    );
    slotKey = _is.ColumnString(
      'slotKey',
      this,
    );
    couponCode = _is.ColumnString(
      'couponCode',
      this,
    );
    origin = _is.ColumnString(
      'origin',
      this,
      hasDefault: true,
    );
    customerLabel = _is.ColumnString(
      'customerLabel',
      this,
    );
    placedBy = _is.ColumnString(
      'placedBy',
      this,
    );
    serviceDay = _is.ColumnString(
      'serviceDay',
      this,
    );
    orderNumber = _is.ColumnInt(
      'orderNumber',
      this,
    );
    pickupCode = _is.ColumnString(
      'pickupCode',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final OrderContextUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnInt visitId;

  late final _is.ColumnInt quoteId;

  late final _is.ColumnString detailsJson;

  late final _is.ColumnString paymentTiming;

  late final _is.ColumnBool cancellationRequested;

  late final _is.ColumnBool stockReleased;

  late final _is.ColumnString slotKey;

  late final _is.ColumnString couponCode;

  late final _is.ColumnString origin;

  late final _is.ColumnString customerLabel;

  late final _is.ColumnString placedBy;

  late final _is.ColumnString serviceDay;

  late final _is.ColumnInt orderNumber;

  late final _is.ColumnString pickupCode;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    orderId,
    visitId,
    quoteId,
    detailsJson,
    paymentTiming,
    cancellationRequested,
    stockReleased,
    slotKey,
    couponCode,
    origin,
    customerLabel,
    placedBy,
    serviceDay,
    orderNumber,
    pickupCode,
    createdAt,
  ];
}

class OrderContextInclude extends _is.IncludeObject {
  OrderContextInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => OrderContext.t;
}

class OrderContextIncludeList extends _is.IncludeList {
  OrderContextIncludeList._({
    _is.WhereExpressionBuilder<OrderContextTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OrderContext.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => OrderContext.t;
}

class OrderContextRepository {
  const OrderContextRepository._();

  /// Returns a list of [OrderContext]s matching the given query parameters.
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
  Future<List<OrderContext>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OrderContextTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OrderContextTable>? orderBy,
    _is.OrderByListBuilder<OrderContextTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OrderContext>(
      where: where?.call(OrderContext.t),
      orderBy: orderBy?.call(OrderContext.t),
      orderByList: orderByList?.call(OrderContext.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OrderContext] matching the given query parameters.
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
  Future<OrderContext?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OrderContextTable>? where,
    int? offset,
    _is.OrderByBuilder<OrderContextTable>? orderBy,
    _is.OrderByListBuilder<OrderContextTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OrderContext>(
      where: where?.call(OrderContext.t),
      orderBy: orderBy?.call(OrderContext.t),
      orderByList: orderByList?.call(OrderContext.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OrderContext] by its [id] or null if no such row exists.
  Future<OrderContext?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OrderContext>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OrderContext]s in the list and returns the inserted rows.
  ///
  /// The returned [OrderContext]s will have their `id` fields set.
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
  Future<List<OrderContext>> insert(
    _is.DatabaseSession session,
    List<OrderContext> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OrderContext>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OrderContext] and returns the inserted row.
  ///
  /// The returned [OrderContext] will have its `id` field set.
  Future<OrderContext> insertRow(
    _is.DatabaseSession session,
    OrderContext row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OrderContext>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OrderContext]s in the list and returns the resulting rows.
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
  /// The returned [OrderContext]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OrderContext>> upsert(
    _is.DatabaseSession session,
    List<OrderContext> rows, {
    required _is.ColumnSelections<OrderContextTable> conflictColumns,
    _is.ColumnSelections<OrderContextTable>? updateColumns,
    _is.WhereExpressionBuilder<OrderContextTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OrderContext>(
      rows,
      conflictColumns: conflictColumns(OrderContext.t),
      updateColumns: updateColumns?.call(OrderContext.t),
      updateWhere: updateWhere?.call(OrderContext.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OrderContext] and returns the resulting row.
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
  /// The returned [OrderContext] will have its `id` field set.
  Future<OrderContext?> upsertRow(
    _is.DatabaseSession session,
    OrderContext row, {
    required _is.ColumnSelections<OrderContextTable> conflictColumns,
    _is.ColumnSelections<OrderContextTable>? updateColumns,
    _is.WhereExpressionBuilder<OrderContextTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OrderContext>(
      row,
      conflictColumns: conflictColumns(OrderContext.t),
      updateColumns: updateColumns?.call(OrderContext.t),
      updateWhere: updateWhere?.call(OrderContext.t),
      transaction: transaction,
    );
  }

  /// Updates all [OrderContext]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OrderContext>> update(
    _is.DatabaseSession session,
    List<OrderContext> rows, {
    _is.ColumnSelections<OrderContextTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OrderContext>(
      rows,
      columns: columns?.call(OrderContext.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OrderContext]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OrderContext> updateRow(
    _is.DatabaseSession session,
    OrderContext row, {
    _is.ColumnSelections<OrderContextTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OrderContext>(
      row,
      columns: columns?.call(OrderContext.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OrderContext] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OrderContext?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<OrderContextUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OrderContext>(
      id,
      columnValues: columnValues(OrderContext.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OrderContext]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OrderContext>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OrderContextUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<OrderContextTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OrderContextTable>? orderBy,
    _is.OrderByListBuilder<OrderContextTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OrderContext>(
      columnValues: columnValues(OrderContext.t.updateTable),
      where: where(OrderContext.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrderContext.t),
      orderByList: orderByList?.call(OrderContext.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OrderContext]s in the list and returns the deleted rows.
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
  Future<List<OrderContext>> delete(
    _is.DatabaseSession session,
    List<OrderContext> rows, {
    _is.OrderByBuilder<OrderContextTable>? orderBy,
    _is.OrderByListBuilder<OrderContextTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OrderContext>(
      rows,
      orderBy: orderBy?.call(OrderContext.t),
      orderByList: orderByList?.call(OrderContext.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OrderContext].
  Future<OrderContext> deleteRow(
    _is.DatabaseSession session,
    OrderContext row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OrderContext>(
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
  Future<List<OrderContext>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OrderContextTable> where,
    _is.OrderByBuilder<OrderContextTable>? orderBy,
    _is.OrderByListBuilder<OrderContextTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OrderContext>(
      where: where(OrderContext.t),
      orderBy: orderBy?.call(OrderContext.t),
      orderByList: orderByList?.call(OrderContext.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OrderContextTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OrderContext>(
      where: where?.call(OrderContext.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OrderContext] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OrderContextTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OrderContext>(
      where: where(OrderContext.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
