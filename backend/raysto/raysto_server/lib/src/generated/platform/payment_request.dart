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

abstract class PaymentRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentRequest._({
    this.id,
    required this.restaurantId,
    required this.kind,
    required this.payerName,
    this.payerEmail,
    required this.description,
    required this.amountMinor,
    required this.currency,
    this.dueAt,
    required this.state,
    required this.linkTokenHash,
    this.checkoutIntentId,
    this.providerInvoiceId,
    required this.remindersSent,
    this.lastRemindedAt,
    this.partnerAppId,
    this.cateringRequestId,
    required this.createdBy,
    this.paidAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentRequest({
    int? id,
    required int restaurantId,
    required String kind,
    required String payerName,
    String? payerEmail,
    required String description,
    required int amountMinor,
    required String currency,
    DateTime? dueAt,
    required String state,
    required String linkTokenHash,
    int? checkoutIntentId,
    String? providerInvoiceId,
    required int remindersSent,
    DateTime? lastRemindedAt,
    int? partnerAppId,
    int? cateringRequestId,
    required String createdBy,
    DateTime? paidAt,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentRequestImpl;

  factory PaymentRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentRequest(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      kind: jsonSerialization['kind'] as String,
      payerName: jsonSerialization['payerName'] as String,
      payerEmail: jsonSerialization['payerEmail'] as String?,
      description: jsonSerialization['description'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      state: jsonSerialization['state'] as String,
      linkTokenHash: jsonSerialization['linkTokenHash'] as String,
      checkoutIntentId: jsonSerialization['checkoutIntentId'] as int?,
      providerInvoiceId: jsonSerialization['providerInvoiceId'] as String?,
      remindersSent: jsonSerialization['remindersSent'] as int,
      lastRemindedAt: jsonSerialization['lastRemindedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastRemindedAt'],
            ),
      partnerAppId: jsonSerialization['partnerAppId'] as int?,
      cateringRequestId: jsonSerialization['cateringRequestId'] as int?,
      createdBy: jsonSerialization['createdBy'] as String,
      paidAt: jsonSerialization['paidAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['paidAt']),
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PaymentRequestTable();

  static const db = PaymentRequestRepository._();

  @override
  int? id;

  int restaurantId;

  String kind;

  String payerName;

  String? payerEmail;

  String description;

  int amountMinor;

  String currency;

  DateTime? dueAt;

  String state;

  String linkTokenHash;

  int? checkoutIntentId;

  String? providerInvoiceId;

  int remindersSent;

  DateTime? lastRemindedAt;

  int? partnerAppId;

  int? cateringRequestId;

  String createdBy;

  DateTime? paidAt;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentRequest copyWith({
    int? id,
    int? restaurantId,
    String? kind,
    String? payerName,
    String? payerEmail,
    String? description,
    int? amountMinor,
    String? currency,
    DateTime? dueAt,
    String? state,
    String? linkTokenHash,
    int? checkoutIntentId,
    String? providerInvoiceId,
    int? remindersSent,
    DateTime? lastRemindedAt,
    int? partnerAppId,
    int? cateringRequestId,
    String? createdBy,
    DateTime? paidAt,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'kind': kind,
      'payerName': payerName,
      if (payerEmail != null) 'payerEmail': payerEmail,
      'description': description,
      'amountMinor': amountMinor,
      'currency': currency,
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      'state': state,
      'linkTokenHash': linkTokenHash,
      if (checkoutIntentId != null) 'checkoutIntentId': checkoutIntentId,
      if (providerInvoiceId != null) 'providerInvoiceId': providerInvoiceId,
      'remindersSent': remindersSent,
      if (lastRemindedAt != null) 'lastRemindedAt': lastRemindedAt?.toJson(),
      if (partnerAppId != null) 'partnerAppId': partnerAppId,
      if (cateringRequestId != null) 'cateringRequestId': cateringRequestId,
      'createdBy': createdBy,
      if (paidAt != null) 'paidAt': paidAt?.toJson(),
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentRequestInclude include() {
    return PaymentRequestInclude._();
  }

  static PaymentRequestIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentRequestTable>? orderBy,
    _is.OrderByListBuilder<PaymentRequestTable>? orderByList,
    PaymentRequestInclude? include,
  }) {
    return PaymentRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentRequest.t),
      orderByList: orderByList?.call(PaymentRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentRequestImpl extends PaymentRequest {
  _PaymentRequestImpl({
    int? id,
    required int restaurantId,
    required String kind,
    required String payerName,
    String? payerEmail,
    required String description,
    required int amountMinor,
    required String currency,
    DateTime? dueAt,
    required String state,
    required String linkTokenHash,
    int? checkoutIntentId,
    String? providerInvoiceId,
    required int remindersSent,
    DateTime? lastRemindedAt,
    int? partnerAppId,
    int? cateringRequestId,
    required String createdBy,
    DateTime? paidAt,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         kind: kind,
         payerName: payerName,
         payerEmail: payerEmail,
         description: description,
         amountMinor: amountMinor,
         currency: currency,
         dueAt: dueAt,
         state: state,
         linkTokenHash: linkTokenHash,
         checkoutIntentId: checkoutIntentId,
         providerInvoiceId: providerInvoiceId,
         remindersSent: remindersSent,
         lastRemindedAt: lastRemindedAt,
         partnerAppId: partnerAppId,
         cateringRequestId: cateringRequestId,
         createdBy: createdBy,
         paidAt: paidAt,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PaymentRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentRequest copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? kind,
    String? payerName,
    Object? payerEmail = _Undefined,
    String? description,
    int? amountMinor,
    String? currency,
    Object? dueAt = _Undefined,
    String? state,
    String? linkTokenHash,
    Object? checkoutIntentId = _Undefined,
    Object? providerInvoiceId = _Undefined,
    int? remindersSent,
    Object? lastRemindedAt = _Undefined,
    Object? partnerAppId = _Undefined,
    Object? cateringRequestId = _Undefined,
    String? createdBy,
    Object? paidAt = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentRequest(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      kind: kind ?? this.kind,
      payerName: payerName ?? this.payerName,
      payerEmail: payerEmail is String? ? payerEmail : this.payerEmail,
      description: description ?? this.description,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      state: state ?? this.state,
      linkTokenHash: linkTokenHash ?? this.linkTokenHash,
      checkoutIntentId: checkoutIntentId is int?
          ? checkoutIntentId
          : this.checkoutIntentId,
      providerInvoiceId: providerInvoiceId is String?
          ? providerInvoiceId
          : this.providerInvoiceId,
      remindersSent: remindersSent ?? this.remindersSent,
      lastRemindedAt: lastRemindedAt is DateTime?
          ? lastRemindedAt
          : this.lastRemindedAt,
      partnerAppId: partnerAppId is int? ? partnerAppId : this.partnerAppId,
      cateringRequestId: cateringRequestId is int?
          ? cateringRequestId
          : this.cateringRequestId,
      createdBy: createdBy ?? this.createdBy,
      paidAt: paidAt is DateTime? ? paidAt : this.paidAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentRequestUpdateTable extends _is.UpdateTable<PaymentRequestTable> {
  PaymentRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> payerName(String value) => _is.ColumnValue(
    table.payerName,
    value,
  );

  _is.ColumnValue<String, String> payerEmail(String? value) => _is.ColumnValue(
    table.payerEmail,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
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

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> linkTokenHash(String value) =>
      _is.ColumnValue(
        table.linkTokenHash,
        value,
      );

  _is.ColumnValue<int, int> checkoutIntentId(int? value) => _is.ColumnValue(
    table.checkoutIntentId,
    value,
  );

  _is.ColumnValue<String, String> providerInvoiceId(String? value) =>
      _is.ColumnValue(
        table.providerInvoiceId,
        value,
      );

  _is.ColumnValue<int, int> remindersSent(int value) => _is.ColumnValue(
    table.remindersSent,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastRemindedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastRemindedAt,
        value,
      );

  _is.ColumnValue<int, int> partnerAppId(int? value) => _is.ColumnValue(
    table.partnerAppId,
    value,
  );

  _is.ColumnValue<int, int> cateringRequestId(int? value) => _is.ColumnValue(
    table.cateringRequestId,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> paidAt(DateTime? value) =>
      _is.ColumnValue(
        table.paidAt,
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

class PaymentRequestTable extends _is.Table<int?> {
  PaymentRequestTable({super.tableRelation})
    : super(tableName: 'raysto_payment_request') {
    updateTable = PaymentRequestUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    payerName = _is.ColumnString(
      'payerName',
      this,
    );
    payerEmail = _is.ColumnString(
      'payerEmail',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
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
    state = _is.ColumnString(
      'state',
      this,
    );
    linkTokenHash = _is.ColumnString(
      'linkTokenHash',
      this,
    );
    checkoutIntentId = _is.ColumnInt(
      'checkoutIntentId',
      this,
    );
    providerInvoiceId = _is.ColumnString(
      'providerInvoiceId',
      this,
    );
    remindersSent = _is.ColumnInt(
      'remindersSent',
      this,
    );
    lastRemindedAt = _is.ColumnDateTime(
      'lastRemindedAt',
      this,
    );
    partnerAppId = _is.ColumnInt(
      'partnerAppId',
      this,
    );
    cateringRequestId = _is.ColumnInt(
      'cateringRequestId',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    paidAt = _is.ColumnDateTime(
      'paidAt',
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

  late final PaymentRequestUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString kind;

  late final _is.ColumnString payerName;

  late final _is.ColumnString payerEmail;

  late final _is.ColumnString description;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime dueAt;

  late final _is.ColumnString state;

  late final _is.ColumnString linkTokenHash;

  late final _is.ColumnInt checkoutIntentId;

  late final _is.ColumnString providerInvoiceId;

  late final _is.ColumnInt remindersSent;

  late final _is.ColumnDateTime lastRemindedAt;

  late final _is.ColumnInt partnerAppId;

  late final _is.ColumnInt cateringRequestId;

  late final _is.ColumnString createdBy;

  late final _is.ColumnDateTime paidAt;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    kind,
    payerName,
    payerEmail,
    description,
    amountMinor,
    currency,
    dueAt,
    state,
    linkTokenHash,
    checkoutIntentId,
    providerInvoiceId,
    remindersSent,
    lastRemindedAt,
    partnerAppId,
    cateringRequestId,
    createdBy,
    paidAt,
    version,
    createdAt,
    updatedAt,
  ];
}

class PaymentRequestInclude extends _is.IncludeObject {
  PaymentRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentRequest.t;
}

class PaymentRequestIncludeList extends _is.IncludeList {
  PaymentRequestIncludeList._({
    _is.WhereExpressionBuilder<PaymentRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentRequest.t;
}

class PaymentRequestRepository {
  const PaymentRequestRepository._();

  /// Returns a list of [PaymentRequest]s matching the given query parameters.
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
  Future<List<PaymentRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentRequestTable>? orderBy,
    _is.OrderByListBuilder<PaymentRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentRequest>(
      where: where?.call(PaymentRequest.t),
      orderBy: orderBy?.call(PaymentRequest.t),
      orderByList: orderByList?.call(PaymentRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentRequest] matching the given query parameters.
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
  Future<PaymentRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentRequestTable>? orderBy,
    _is.OrderByListBuilder<PaymentRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentRequest>(
      where: where?.call(PaymentRequest.t),
      orderBy: orderBy?.call(PaymentRequest.t),
      orderByList: orderByList?.call(PaymentRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentRequest] by its [id] or null if no such row exists.
  Future<PaymentRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentRequest]s will have their `id` fields set.
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
  Future<List<PaymentRequest>> insert(
    _is.DatabaseSession session,
    List<PaymentRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentRequest] and returns the inserted row.
  ///
  /// The returned [PaymentRequest] will have its `id` field set.
  Future<PaymentRequest> insertRow(
    _is.DatabaseSession session,
    PaymentRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentRequest]s in the list and returns the resulting rows.
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
  /// The returned [PaymentRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentRequest>> upsert(
    _is.DatabaseSession session,
    List<PaymentRequest> rows, {
    required _is.ColumnSelections<PaymentRequestTable> conflictColumns,
    _is.ColumnSelections<PaymentRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentRequest>(
      rows,
      conflictColumns: conflictColumns(PaymentRequest.t),
      updateColumns: updateColumns?.call(PaymentRequest.t),
      updateWhere: updateWhere?.call(PaymentRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentRequest] and returns the resulting row.
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
  /// The returned [PaymentRequest] will have its `id` field set.
  Future<PaymentRequest?> upsertRow(
    _is.DatabaseSession session,
    PaymentRequest row, {
    required _is.ColumnSelections<PaymentRequestTable> conflictColumns,
    _is.ColumnSelections<PaymentRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentRequest>(
      row,
      conflictColumns: conflictColumns(PaymentRequest.t),
      updateColumns: updateColumns?.call(PaymentRequest.t),
      updateWhere: updateWhere?.call(PaymentRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentRequest>> update(
    _is.DatabaseSession session,
    List<PaymentRequest> rows, {
    _is.ColumnSelections<PaymentRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentRequest>(
      rows,
      columns: columns?.call(PaymentRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentRequest> updateRow(
    _is.DatabaseSession session,
    PaymentRequest row, {
    _is.ColumnSelections<PaymentRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentRequest>(
      row,
      columns: columns?.call(PaymentRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentRequestUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentRequest>(
      id,
      columnValues: columnValues(PaymentRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentRequestUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PaymentRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentRequestTable>? orderBy,
    _is.OrderByListBuilder<PaymentRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentRequest>(
      columnValues: columnValues(PaymentRequest.t.updateTable),
      where: where(PaymentRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentRequest.t),
      orderByList: orderByList?.call(PaymentRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentRequest]s in the list and returns the deleted rows.
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
  Future<List<PaymentRequest>> delete(
    _is.DatabaseSession session,
    List<PaymentRequest> rows, {
    _is.OrderByBuilder<PaymentRequestTable>? orderBy,
    _is.OrderByListBuilder<PaymentRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentRequest>(
      rows,
      orderBy: orderBy?.call(PaymentRequest.t),
      orderByList: orderByList?.call(PaymentRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentRequest].
  Future<PaymentRequest> deleteRow(
    _is.DatabaseSession session,
    PaymentRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentRequest>(
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
  Future<List<PaymentRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentRequestTable> where,
    _is.OrderByBuilder<PaymentRequestTable>? orderBy,
    _is.OrderByListBuilder<PaymentRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentRequest>(
      where: where(PaymentRequest.t),
      orderBy: orderBy?.call(PaymentRequest.t),
      orderByList: orderByList?.call(PaymentRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentRequest>(
      where: where?.call(PaymentRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentRequest>(
      where: where(PaymentRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
