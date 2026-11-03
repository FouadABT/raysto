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

abstract class CateringRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CateringRequest._({
    this.id,
    required this.restaurantId,
    required this.customerEmail,
    this.customerName,
    required this.text,
    this.eventAt,
    required this.quoteJson,
    required this.status,
    this.providerInvoiceId,
    this.invoiceNumber,
    this.qrMediaId,
    this.orderId,
    required this.depositMinor,
    required this.totalMinor,
    required this.currency,
    this.dueAt,
    this.remindedAt,
    this.taskId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CateringRequest({
    int? id,
    required int restaurantId,
    required String customerEmail,
    String? customerName,
    required String text,
    DateTime? eventAt,
    required String quoteJson,
    required String status,
    String? providerInvoiceId,
    String? invoiceNumber,
    int? qrMediaId,
    int? orderId,
    required int depositMinor,
    required int totalMinor,
    required String currency,
    DateTime? dueAt,
    DateTime? remindedAt,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CateringRequestImpl;

  factory CateringRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return CateringRequest(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      customerEmail: jsonSerialization['customerEmail'] as String,
      customerName: jsonSerialization['customerName'] as String?,
      text: jsonSerialization['text'] as String,
      eventAt: jsonSerialization['eventAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['eventAt']),
      quoteJson: jsonSerialization['quoteJson'] as String,
      status: jsonSerialization['status'] as String,
      providerInvoiceId: jsonSerialization['providerInvoiceId'] as String?,
      invoiceNumber: jsonSerialization['invoiceNumber'] as String?,
      qrMediaId: jsonSerialization['qrMediaId'] as int?,
      orderId: jsonSerialization['orderId'] as int?,
      depositMinor: jsonSerialization['depositMinor'] as int,
      totalMinor: jsonSerialization['totalMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      remindedAt: jsonSerialization['remindedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['remindedAt']),
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

  static final t = CateringRequestTable();

  static const db = CateringRequestRepository._();

  @override
  int? id;

  int restaurantId;

  String customerEmail;

  String? customerName;

  String text;

  DateTime? eventAt;

  String quoteJson;

  String status;

  String? providerInvoiceId;

  String? invoiceNumber;

  int? qrMediaId;

  int? orderId;

  int depositMinor;

  int totalMinor;

  String currency;

  DateTime? dueAt;

  DateTime? remindedAt;

  int? taskId;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CateringRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CateringRequest copyWith({
    int? id,
    int? restaurantId,
    String? customerEmail,
    String? customerName,
    String? text,
    DateTime? eventAt,
    String? quoteJson,
    String? status,
    String? providerInvoiceId,
    String? invoiceNumber,
    int? qrMediaId,
    int? orderId,
    int? depositMinor,
    int? totalMinor,
    String? currency,
    DateTime? dueAt,
    DateTime? remindedAt,
    int? taskId,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CateringRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'customerEmail': customerEmail,
      if (customerName != null) 'customerName': customerName,
      'text': text,
      if (eventAt != null) 'eventAt': eventAt?.toJson(),
      'quoteJson': quoteJson,
      'status': status,
      if (providerInvoiceId != null) 'providerInvoiceId': providerInvoiceId,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      if (qrMediaId != null) 'qrMediaId': qrMediaId,
      if (orderId != null) 'orderId': orderId,
      'depositMinor': depositMinor,
      'totalMinor': totalMinor,
      'currency': currency,
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (remindedAt != null) 'remindedAt': remindedAt?.toJson(),
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

  static CateringRequestInclude include() {
    return CateringRequestInclude._();
  }

  static CateringRequestIncludeList includeList({
    _is.WhereExpressionBuilder<CateringRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CateringRequestTable>? orderBy,
    _is.OrderByListBuilder<CateringRequestTable>? orderByList,
    CateringRequestInclude? include,
  }) {
    return CateringRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CateringRequest.t),
      orderByList: orderByList?.call(CateringRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CateringRequestImpl extends CateringRequest {
  _CateringRequestImpl({
    int? id,
    required int restaurantId,
    required String customerEmail,
    String? customerName,
    required String text,
    DateTime? eventAt,
    required String quoteJson,
    required String status,
    String? providerInvoiceId,
    String? invoiceNumber,
    int? qrMediaId,
    int? orderId,
    required int depositMinor,
    required int totalMinor,
    required String currency,
    DateTime? dueAt,
    DateTime? remindedAt,
    int? taskId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         customerEmail: customerEmail,
         customerName: customerName,
         text: text,
         eventAt: eventAt,
         quoteJson: quoteJson,
         status: status,
         providerInvoiceId: providerInvoiceId,
         invoiceNumber: invoiceNumber,
         qrMediaId: qrMediaId,
         orderId: orderId,
         depositMinor: depositMinor,
         totalMinor: totalMinor,
         currency: currency,
         dueAt: dueAt,
         remindedAt: remindedAt,
         taskId: taskId,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CateringRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CateringRequest copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? customerEmail,
    Object? customerName = _Undefined,
    String? text,
    Object? eventAt = _Undefined,
    String? quoteJson,
    String? status,
    Object? providerInvoiceId = _Undefined,
    Object? invoiceNumber = _Undefined,
    Object? qrMediaId = _Undefined,
    Object? orderId = _Undefined,
    int? depositMinor,
    int? totalMinor,
    String? currency,
    Object? dueAt = _Undefined,
    Object? remindedAt = _Undefined,
    Object? taskId = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CateringRequest(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName is String? ? customerName : this.customerName,
      text: text ?? this.text,
      eventAt: eventAt is DateTime? ? eventAt : this.eventAt,
      quoteJson: quoteJson ?? this.quoteJson,
      status: status ?? this.status,
      providerInvoiceId: providerInvoiceId is String?
          ? providerInvoiceId
          : this.providerInvoiceId,
      invoiceNumber: invoiceNumber is String?
          ? invoiceNumber
          : this.invoiceNumber,
      qrMediaId: qrMediaId is int? ? qrMediaId : this.qrMediaId,
      orderId: orderId is int? ? orderId : this.orderId,
      depositMinor: depositMinor ?? this.depositMinor,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      remindedAt: remindedAt is DateTime? ? remindedAt : this.remindedAt,
      taskId: taskId is int? ? taskId : this.taskId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CateringRequestUpdateTable extends _is.UpdateTable<CateringRequestTable> {
  CateringRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> customerEmail(String value) =>
      _is.ColumnValue(
        table.customerEmail,
        value,
      );

  _is.ColumnValue<String, String> customerName(String? value) =>
      _is.ColumnValue(
        table.customerName,
        value,
      );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> eventAt(DateTime? value) =>
      _is.ColumnValue(
        table.eventAt,
        value,
      );

  _is.ColumnValue<String, String> quoteJson(String value) => _is.ColumnValue(
    table.quoteJson,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> providerInvoiceId(String? value) =>
      _is.ColumnValue(
        table.providerInvoiceId,
        value,
      );

  _is.ColumnValue<String, String> invoiceNumber(String? value) =>
      _is.ColumnValue(
        table.invoiceNumber,
        value,
      );

  _is.ColumnValue<int, int> qrMediaId(int? value) => _is.ColumnValue(
    table.qrMediaId,
    value,
  );

  _is.ColumnValue<int, int> orderId(int? value) => _is.ColumnValue(
    table.orderId,
    value,
  );

  _is.ColumnValue<int, int> depositMinor(int value) => _is.ColumnValue(
    table.depositMinor,
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

  _is.ColumnValue<DateTime, DateTime> dueAt(DateTime? value) => _is.ColumnValue(
    table.dueAt,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> remindedAt(DateTime? value) =>
      _is.ColumnValue(
        table.remindedAt,
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

class CateringRequestTable extends _is.Table<int?> {
  CateringRequestTable({super.tableRelation})
    : super(tableName: 'raysto_catering_request') {
    updateTable = CateringRequestUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    customerEmail = _is.ColumnString(
      'customerEmail',
      this,
    );
    customerName = _is.ColumnString(
      'customerName',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    eventAt = _is.ColumnDateTime(
      'eventAt',
      this,
    );
    quoteJson = _is.ColumnString(
      'quoteJson',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    providerInvoiceId = _is.ColumnString(
      'providerInvoiceId',
      this,
    );
    invoiceNumber = _is.ColumnString(
      'invoiceNumber',
      this,
    );
    qrMediaId = _is.ColumnInt(
      'qrMediaId',
      this,
    );
    orderId = _is.ColumnInt(
      'orderId',
      this,
    );
    depositMinor = _is.ColumnInt(
      'depositMinor',
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
    dueAt = _is.ColumnDateTime(
      'dueAt',
      this,
    );
    remindedAt = _is.ColumnDateTime(
      'remindedAt',
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

  late final CateringRequestUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString customerEmail;

  late final _is.ColumnString customerName;

  late final _is.ColumnString text;

  late final _is.ColumnDateTime eventAt;

  late final _is.ColumnString quoteJson;

  late final _is.ColumnString status;

  late final _is.ColumnString providerInvoiceId;

  late final _is.ColumnString invoiceNumber;

  late final _is.ColumnInt qrMediaId;

  late final _is.ColumnInt orderId;

  late final _is.ColumnInt depositMinor;

  late final _is.ColumnInt totalMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime dueAt;

  late final _is.ColumnDateTime remindedAt;

  late final _is.ColumnInt taskId;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    customerEmail,
    customerName,
    text,
    eventAt,
    quoteJson,
    status,
    providerInvoiceId,
    invoiceNumber,
    qrMediaId,
    orderId,
    depositMinor,
    totalMinor,
    currency,
    dueAt,
    remindedAt,
    taskId,
    version,
    createdAt,
    updatedAt,
  ];
}

class CateringRequestInclude extends _is.IncludeObject {
  CateringRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CateringRequest.t;
}

class CateringRequestIncludeList extends _is.IncludeList {
  CateringRequestIncludeList._({
    _is.WhereExpressionBuilder<CateringRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CateringRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CateringRequest.t;
}

class CateringRequestRepository {
  const CateringRequestRepository._();

  /// Returns a list of [CateringRequest]s matching the given query parameters.
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
  Future<List<CateringRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CateringRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CateringRequestTable>? orderBy,
    _is.OrderByListBuilder<CateringRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CateringRequest>(
      where: where?.call(CateringRequest.t),
      orderBy: orderBy?.call(CateringRequest.t),
      orderByList: orderByList?.call(CateringRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CateringRequest] matching the given query parameters.
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
  Future<CateringRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CateringRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<CateringRequestTable>? orderBy,
    _is.OrderByListBuilder<CateringRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CateringRequest>(
      where: where?.call(CateringRequest.t),
      orderBy: orderBy?.call(CateringRequest.t),
      orderByList: orderByList?.call(CateringRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CateringRequest] by its [id] or null if no such row exists.
  Future<CateringRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CateringRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CateringRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [CateringRequest]s will have their `id` fields set.
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
  Future<List<CateringRequest>> insert(
    _is.DatabaseSession session,
    List<CateringRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CateringRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CateringRequest] and returns the inserted row.
  ///
  /// The returned [CateringRequest] will have its `id` field set.
  Future<CateringRequest> insertRow(
    _is.DatabaseSession session,
    CateringRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CateringRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CateringRequest]s in the list and returns the resulting rows.
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
  /// The returned [CateringRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CateringRequest>> upsert(
    _is.DatabaseSession session,
    List<CateringRequest> rows, {
    required _is.ColumnSelections<CateringRequestTable> conflictColumns,
    _is.ColumnSelections<CateringRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<CateringRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CateringRequest>(
      rows,
      conflictColumns: conflictColumns(CateringRequest.t),
      updateColumns: updateColumns?.call(CateringRequest.t),
      updateWhere: updateWhere?.call(CateringRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CateringRequest] and returns the resulting row.
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
  /// The returned [CateringRequest] will have its `id` field set.
  Future<CateringRequest?> upsertRow(
    _is.DatabaseSession session,
    CateringRequest row, {
    required _is.ColumnSelections<CateringRequestTable> conflictColumns,
    _is.ColumnSelections<CateringRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<CateringRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CateringRequest>(
      row,
      conflictColumns: conflictColumns(CateringRequest.t),
      updateColumns: updateColumns?.call(CateringRequest.t),
      updateWhere: updateWhere?.call(CateringRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [CateringRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CateringRequest>> update(
    _is.DatabaseSession session,
    List<CateringRequest> rows, {
    _is.ColumnSelections<CateringRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CateringRequest>(
      rows,
      columns: columns?.call(CateringRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CateringRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CateringRequest> updateRow(
    _is.DatabaseSession session,
    CateringRequest row, {
    _is.ColumnSelections<CateringRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CateringRequest>(
      row,
      columns: columns?.call(CateringRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CateringRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CateringRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CateringRequestUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CateringRequest>(
      id,
      columnValues: columnValues(CateringRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CateringRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CateringRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CateringRequestUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CateringRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CateringRequestTable>? orderBy,
    _is.OrderByListBuilder<CateringRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CateringRequest>(
      columnValues: columnValues(CateringRequest.t.updateTable),
      where: where(CateringRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CateringRequest.t),
      orderByList: orderByList?.call(CateringRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CateringRequest]s in the list and returns the deleted rows.
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
  Future<List<CateringRequest>> delete(
    _is.DatabaseSession session,
    List<CateringRequest> rows, {
    _is.OrderByBuilder<CateringRequestTable>? orderBy,
    _is.OrderByListBuilder<CateringRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CateringRequest>(
      rows,
      orderBy: orderBy?.call(CateringRequest.t),
      orderByList: orderByList?.call(CateringRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CateringRequest].
  Future<CateringRequest> deleteRow(
    _is.DatabaseSession session,
    CateringRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CateringRequest>(
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
  Future<List<CateringRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CateringRequestTable> where,
    _is.OrderByBuilder<CateringRequestTable>? orderBy,
    _is.OrderByListBuilder<CateringRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CateringRequest>(
      where: where(CateringRequest.t),
      orderBy: orderBy?.call(CateringRequest.t),
      orderByList: orderByList?.call(CateringRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CateringRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CateringRequest>(
      where: where?.call(CateringRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CateringRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CateringRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CateringRequest>(
      where: where(CateringRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
