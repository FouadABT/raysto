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

abstract class CheckoutIntent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CheckoutIntent._({
    this.id,
    required this.restaurantId,
    required this.userId,
    this.visitId,
    this.activeVisitId,
    this.orderId,
    required this.requestKey,
    required this.requestHash,
    required this.providerRequestId,
    this.providerOrderId,
    required this.merchantId,
    this.approvalUrl,
    required this.state,
    required this.method,
    required this.currency,
    required this.amountMinor,
    required this.commissionMinor,
    required this.commissionBps,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheckoutIntent({
    int? id,
    required int restaurantId,
    required String userId,
    int? visitId,
    int? activeVisitId,
    int? orderId,
    required String requestKey,
    required String requestHash,
    required String providerRequestId,
    String? providerOrderId,
    required String merchantId,
    String? approvalUrl,
    required String state,
    required String method,
    required String currency,
    required int amountMinor,
    required int commissionMinor,
    required int commissionBps,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CheckoutIntentImpl;

  factory CheckoutIntent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CheckoutIntent(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String,
      visitId: jsonSerialization['visitId'] as int?,
      activeVisitId: jsonSerialization['activeVisitId'] as int?,
      orderId: jsonSerialization['orderId'] as int?,
      requestKey: jsonSerialization['requestKey'] as String,
      requestHash: jsonSerialization['requestHash'] as String,
      providerRequestId: jsonSerialization['providerRequestId'] as String,
      providerOrderId: jsonSerialization['providerOrderId'] as String?,
      merchantId: jsonSerialization['merchantId'] as String,
      approvalUrl: jsonSerialization['approvalUrl'] as String?,
      state: jsonSerialization['state'] as String,
      method: jsonSerialization['method'] as String,
      currency: jsonSerialization['currency'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      commissionMinor: jsonSerialization['commissionMinor'] as int,
      commissionBps: jsonSerialization['commissionBps'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CheckoutIntentTable();

  static const db = CheckoutIntentRepository._();

  @override
  int? id;

  int restaurantId;

  String userId;

  int? visitId;

  int? activeVisitId;

  int? orderId;

  String requestKey;

  String requestHash;

  String providerRequestId;

  String? providerOrderId;

  String merchantId;

  String? approvalUrl;

  String state;

  String method;

  String currency;

  int amountMinor;

  int commissionMinor;

  int commissionBps;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CheckoutIntent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CheckoutIntent copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    int? visitId,
    int? activeVisitId,
    int? orderId,
    String? requestKey,
    String? requestHash,
    String? providerRequestId,
    String? providerOrderId,
    String? merchantId,
    String? approvalUrl,
    String? state,
    String? method,
    String? currency,
    int? amountMinor,
    int? commissionMinor,
    int? commissionBps,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CheckoutIntent',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      if (visitId != null) 'visitId': visitId,
      if (activeVisitId != null) 'activeVisitId': activeVisitId,
      if (orderId != null) 'orderId': orderId,
      'requestKey': requestKey,
      'requestHash': requestHash,
      'providerRequestId': providerRequestId,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      'merchantId': merchantId,
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      'state': state,
      'method': method,
      'currency': currency,
      'amountMinor': amountMinor,
      'commissionMinor': commissionMinor,
      'commissionBps': commissionBps,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CheckoutIntentInclude include() {
    return CheckoutIntentInclude._();
  }

  static CheckoutIntentIncludeList includeList({
    _is.WhereExpressionBuilder<CheckoutIntentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CheckoutIntentTable>? orderBy,
    _is.OrderByListBuilder<CheckoutIntentTable>? orderByList,
    CheckoutIntentInclude? include,
  }) {
    return CheckoutIntentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CheckoutIntent.t),
      orderByList: orderByList?.call(CheckoutIntent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CheckoutIntentImpl extends CheckoutIntent {
  _CheckoutIntentImpl({
    int? id,
    required int restaurantId,
    required String userId,
    int? visitId,
    int? activeVisitId,
    int? orderId,
    required String requestKey,
    required String requestHash,
    required String providerRequestId,
    String? providerOrderId,
    required String merchantId,
    String? approvalUrl,
    required String state,
    required String method,
    required String currency,
    required int amountMinor,
    required int commissionMinor,
    required int commissionBps,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         visitId: visitId,
         activeVisitId: activeVisitId,
         orderId: orderId,
         requestKey: requestKey,
         requestHash: requestHash,
         providerRequestId: providerRequestId,
         providerOrderId: providerOrderId,
         merchantId: merchantId,
         approvalUrl: approvalUrl,
         state: state,
         method: method,
         currency: currency,
         amountMinor: amountMinor,
         commissionMinor: commissionMinor,
         commissionBps: commissionBps,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CheckoutIntent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CheckoutIntent copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? userId,
    Object? visitId = _Undefined,
    Object? activeVisitId = _Undefined,
    Object? orderId = _Undefined,
    String? requestKey,
    String? requestHash,
    String? providerRequestId,
    Object? providerOrderId = _Undefined,
    String? merchantId,
    Object? approvalUrl = _Undefined,
    String? state,
    String? method,
    String? currency,
    int? amountMinor,
    int? commissionMinor,
    int? commissionBps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CheckoutIntent(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      visitId: visitId is int? ? visitId : this.visitId,
      activeVisitId: activeVisitId is int? ? activeVisitId : this.activeVisitId,
      orderId: orderId is int? ? orderId : this.orderId,
      requestKey: requestKey ?? this.requestKey,
      requestHash: requestHash ?? this.requestHash,
      providerRequestId: providerRequestId ?? this.providerRequestId,
      providerOrderId: providerOrderId is String?
          ? providerOrderId
          : this.providerOrderId,
      merchantId: merchantId ?? this.merchantId,
      approvalUrl: approvalUrl is String? ? approvalUrl : this.approvalUrl,
      state: state ?? this.state,
      method: method ?? this.method,
      currency: currency ?? this.currency,
      amountMinor: amountMinor ?? this.amountMinor,
      commissionMinor: commissionMinor ?? this.commissionMinor,
      commissionBps: commissionBps ?? this.commissionBps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CheckoutIntentUpdateTable extends _is.UpdateTable<CheckoutIntentTable> {
  CheckoutIntentUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> visitId(int? value) => _is.ColumnValue(
    table.visitId,
    value,
  );

  _is.ColumnValue<int, int> activeVisitId(int? value) => _is.ColumnValue(
    table.activeVisitId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int? value) => _is.ColumnValue(
    table.orderId,
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

  _is.ColumnValue<String, String> providerRequestId(String value) =>
      _is.ColumnValue(
        table.providerRequestId,
        value,
      );

  _is.ColumnValue<String, String> providerOrderId(String? value) =>
      _is.ColumnValue(
        table.providerOrderId,
        value,
      );

  _is.ColumnValue<String, String> merchantId(String value) => _is.ColumnValue(
    table.merchantId,
    value,
  );

  _is.ColumnValue<String, String> approvalUrl(String? value) => _is.ColumnValue(
    table.approvalUrl,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> method(String value) => _is.ColumnValue(
    table.method,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> commissionMinor(int value) => _is.ColumnValue(
    table.commissionMinor,
    value,
  );

  _is.ColumnValue<int, int> commissionBps(int value) => _is.ColumnValue(
    table.commissionBps,
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

class CheckoutIntentTable extends _is.Table<int?> {
  CheckoutIntentTable({super.tableRelation})
    : super(tableName: 'raysto_checkout_intent') {
    updateTable = CheckoutIntentUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    visitId = _is.ColumnInt(
      'visitId',
      this,
    );
    activeVisitId = _is.ColumnInt(
      'activeVisitId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
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
    providerRequestId = _is.ColumnString(
      'providerRequestId',
      this,
    );
    providerOrderId = _is.ColumnString(
      'providerOrderId',
      this,
    );
    merchantId = _is.ColumnString(
      'merchantId',
      this,
    );
    approvalUrl = _is.ColumnString(
      'approvalUrl',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    method = _is.ColumnString(
      'method',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    commissionMinor = _is.ColumnInt(
      'commissionMinor',
      this,
    );
    commissionBps = _is.ColumnInt(
      'commissionBps',
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

  late final CheckoutIntentUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnInt visitId;

  late final _is.ColumnInt activeVisitId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnString requestHash;

  late final _is.ColumnString providerRequestId;

  late final _is.ColumnString providerOrderId;

  late final _is.ColumnString merchantId;

  late final _is.ColumnString approvalUrl;

  late final _is.ColumnString state;

  late final _is.ColumnString method;

  late final _is.ColumnString currency;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnInt commissionMinor;

  late final _is.ColumnInt commissionBps;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    visitId,
    activeVisitId,
    orderId,
    requestKey,
    requestHash,
    providerRequestId,
    providerOrderId,
    merchantId,
    approvalUrl,
    state,
    method,
    currency,
    amountMinor,
    commissionMinor,
    commissionBps,
    createdAt,
    updatedAt,
  ];
}

class CheckoutIntentInclude extends _is.IncludeObject {
  CheckoutIntentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CheckoutIntent.t;
}

class CheckoutIntentIncludeList extends _is.IncludeList {
  CheckoutIntentIncludeList._({
    _is.WhereExpressionBuilder<CheckoutIntentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CheckoutIntent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CheckoutIntent.t;
}

class CheckoutIntentRepository {
  const CheckoutIntentRepository._();

  /// Returns a list of [CheckoutIntent]s matching the given query parameters.
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
  Future<List<CheckoutIntent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CheckoutIntentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CheckoutIntentTable>? orderBy,
    _is.OrderByListBuilder<CheckoutIntentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CheckoutIntent>(
      where: where?.call(CheckoutIntent.t),
      orderBy: orderBy?.call(CheckoutIntent.t),
      orderByList: orderByList?.call(CheckoutIntent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CheckoutIntent] matching the given query parameters.
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
  Future<CheckoutIntent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CheckoutIntentTable>? where,
    int? offset,
    _is.OrderByBuilder<CheckoutIntentTable>? orderBy,
    _is.OrderByListBuilder<CheckoutIntentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CheckoutIntent>(
      where: where?.call(CheckoutIntent.t),
      orderBy: orderBy?.call(CheckoutIntent.t),
      orderByList: orderByList?.call(CheckoutIntent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CheckoutIntent] by its [id] or null if no such row exists.
  Future<CheckoutIntent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CheckoutIntent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CheckoutIntent]s in the list and returns the inserted rows.
  ///
  /// The returned [CheckoutIntent]s will have their `id` fields set.
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
  Future<List<CheckoutIntent>> insert(
    _is.DatabaseSession session,
    List<CheckoutIntent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CheckoutIntent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CheckoutIntent] and returns the inserted row.
  ///
  /// The returned [CheckoutIntent] will have its `id` field set.
  Future<CheckoutIntent> insertRow(
    _is.DatabaseSession session,
    CheckoutIntent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CheckoutIntent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CheckoutIntent]s in the list and returns the resulting rows.
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
  /// The returned [CheckoutIntent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CheckoutIntent>> upsert(
    _is.DatabaseSession session,
    List<CheckoutIntent> rows, {
    required _is.ColumnSelections<CheckoutIntentTable> conflictColumns,
    _is.ColumnSelections<CheckoutIntentTable>? updateColumns,
    _is.WhereExpressionBuilder<CheckoutIntentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CheckoutIntent>(
      rows,
      conflictColumns: conflictColumns(CheckoutIntent.t),
      updateColumns: updateColumns?.call(CheckoutIntent.t),
      updateWhere: updateWhere?.call(CheckoutIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CheckoutIntent] and returns the resulting row.
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
  /// The returned [CheckoutIntent] will have its `id` field set.
  Future<CheckoutIntent?> upsertRow(
    _is.DatabaseSession session,
    CheckoutIntent row, {
    required _is.ColumnSelections<CheckoutIntentTable> conflictColumns,
    _is.ColumnSelections<CheckoutIntentTable>? updateColumns,
    _is.WhereExpressionBuilder<CheckoutIntentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CheckoutIntent>(
      row,
      conflictColumns: conflictColumns(CheckoutIntent.t),
      updateColumns: updateColumns?.call(CheckoutIntent.t),
      updateWhere: updateWhere?.call(CheckoutIntent.t),
      transaction: transaction,
    );
  }

  /// Updates all [CheckoutIntent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CheckoutIntent>> update(
    _is.DatabaseSession session,
    List<CheckoutIntent> rows, {
    _is.ColumnSelections<CheckoutIntentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CheckoutIntent>(
      rows,
      columns: columns?.call(CheckoutIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CheckoutIntent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CheckoutIntent> updateRow(
    _is.DatabaseSession session,
    CheckoutIntent row, {
    _is.ColumnSelections<CheckoutIntentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CheckoutIntent>(
      row,
      columns: columns?.call(CheckoutIntent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CheckoutIntent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CheckoutIntent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CheckoutIntentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CheckoutIntent>(
      id,
      columnValues: columnValues(CheckoutIntent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CheckoutIntent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CheckoutIntent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CheckoutIntentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CheckoutIntentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CheckoutIntentTable>? orderBy,
    _is.OrderByListBuilder<CheckoutIntentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CheckoutIntent>(
      columnValues: columnValues(CheckoutIntent.t.updateTable),
      where: where(CheckoutIntent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CheckoutIntent.t),
      orderByList: orderByList?.call(CheckoutIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CheckoutIntent]s in the list and returns the deleted rows.
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
  Future<List<CheckoutIntent>> delete(
    _is.DatabaseSession session,
    List<CheckoutIntent> rows, {
    _is.OrderByBuilder<CheckoutIntentTable>? orderBy,
    _is.OrderByListBuilder<CheckoutIntentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CheckoutIntent>(
      rows,
      orderBy: orderBy?.call(CheckoutIntent.t),
      orderByList: orderByList?.call(CheckoutIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CheckoutIntent].
  Future<CheckoutIntent> deleteRow(
    _is.DatabaseSession session,
    CheckoutIntent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CheckoutIntent>(
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
  Future<List<CheckoutIntent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CheckoutIntentTable> where,
    _is.OrderByBuilder<CheckoutIntentTable>? orderBy,
    _is.OrderByListBuilder<CheckoutIntentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CheckoutIntent>(
      where: where(CheckoutIntent.t),
      orderBy: orderBy?.call(CheckoutIntent.t),
      orderByList: orderByList?.call(CheckoutIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CheckoutIntentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CheckoutIntent>(
      where: where?.call(CheckoutIntent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CheckoutIntent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CheckoutIntentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CheckoutIntent>(
      where: where(CheckoutIntent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
