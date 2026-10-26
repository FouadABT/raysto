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

abstract class SandboxPayment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SandboxPayment._({
    this.id,
    required this.userId,
    required this.requestKey,
    required this.providerRequestId,
    required this.amountMinor,
    required this.currency,
    required this.state,
    this.providerOrderId,
    this.approvalUrl,
    this.captureId,
    this.webhookEventId,
    this.webhookReceivedAt,
    this.capturedAt,
    required this.createdAt,
  });

  factory SandboxPayment({
    int? id,
    required String userId,
    required String requestKey,
    required String providerRequestId,
    required int amountMinor,
    required String currency,
    required String state,
    String? providerOrderId,
    String? approvalUrl,
    String? captureId,
    String? webhookEventId,
    DateTime? webhookReceivedAt,
    DateTime? capturedAt,
    required DateTime createdAt,
  }) = _SandboxPaymentImpl;

  factory SandboxPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return SandboxPayment(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      requestKey: jsonSerialization['requestKey'] as String,
      providerRequestId: jsonSerialization['providerRequestId'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      state: jsonSerialization['state'] as String,
      providerOrderId: jsonSerialization['providerOrderId'] as String?,
      approvalUrl: jsonSerialization['approvalUrl'] as String?,
      captureId: jsonSerialization['captureId'] as String?,
      webhookEventId: jsonSerialization['webhookEventId'] as String?,
      webhookReceivedAt: jsonSerialization['webhookReceivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['webhookReceivedAt'],
            ),
      capturedAt: jsonSerialization['capturedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['capturedAt']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SandboxPaymentTable();

  static const db = SandboxPaymentRepository._();

  @override
  int? id;

  String userId;

  String requestKey;

  String providerRequestId;

  int amountMinor;

  String currency;

  String state;

  String? providerOrderId;

  String? approvalUrl;

  String? captureId;

  String? webhookEventId;

  DateTime? webhookReceivedAt;

  DateTime? capturedAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SandboxPayment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SandboxPayment copyWith({
    int? id,
    String? userId,
    String? requestKey,
    String? providerRequestId,
    int? amountMinor,
    String? currency,
    String? state,
    String? providerOrderId,
    String? approvalUrl,
    String? captureId,
    String? webhookEventId,
    DateTime? webhookReceivedAt,
    DateTime? capturedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SandboxPayment',
      if (id != null) 'id': id,
      'userId': userId,
      'requestKey': requestKey,
      'providerRequestId': providerRequestId,
      'amountMinor': amountMinor,
      'currency': currency,
      'state': state,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      if (captureId != null) 'captureId': captureId,
      if (webhookEventId != null) 'webhookEventId': webhookEventId,
      if (webhookReceivedAt != null)
        'webhookReceivedAt': webhookReceivedAt?.toJson(),
      if (capturedAt != null) 'capturedAt': capturedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SandboxPayment',
      if (id != null) 'id': id,
      'userId': userId,
      'requestKey': requestKey,
      'providerRequestId': providerRequestId,
      'amountMinor': amountMinor,
      'currency': currency,
      'state': state,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      if (captureId != null) 'captureId': captureId,
      if (webhookEventId != null) 'webhookEventId': webhookEventId,
      if (webhookReceivedAt != null)
        'webhookReceivedAt': webhookReceivedAt?.toJson(),
      if (capturedAt != null) 'capturedAt': capturedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static SandboxPaymentInclude include() {
    return SandboxPaymentInclude._();
  }

  static SandboxPaymentIncludeList includeList({
    _is.WhereExpressionBuilder<SandboxPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SandboxPaymentTable>? orderBy,
    _is.OrderByListBuilder<SandboxPaymentTable>? orderByList,
    SandboxPaymentInclude? include,
  }) {
    return SandboxPaymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SandboxPayment.t),
      orderByList: orderByList?.call(SandboxPayment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SandboxPaymentImpl extends SandboxPayment {
  _SandboxPaymentImpl({
    int? id,
    required String userId,
    required String requestKey,
    required String providerRequestId,
    required int amountMinor,
    required String currency,
    required String state,
    String? providerOrderId,
    String? approvalUrl,
    String? captureId,
    String? webhookEventId,
    DateTime? webhookReceivedAt,
    DateTime? capturedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         requestKey: requestKey,
         providerRequestId: providerRequestId,
         amountMinor: amountMinor,
         currency: currency,
         state: state,
         providerOrderId: providerOrderId,
         approvalUrl: approvalUrl,
         captureId: captureId,
         webhookEventId: webhookEventId,
         webhookReceivedAt: webhookReceivedAt,
         capturedAt: capturedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SandboxPayment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SandboxPayment copyWith({
    Object? id = _Undefined,
    String? userId,
    String? requestKey,
    String? providerRequestId,
    int? amountMinor,
    String? currency,
    String? state,
    Object? providerOrderId = _Undefined,
    Object? approvalUrl = _Undefined,
    Object? captureId = _Undefined,
    Object? webhookEventId = _Undefined,
    Object? webhookReceivedAt = _Undefined,
    Object? capturedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return SandboxPayment(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      requestKey: requestKey ?? this.requestKey,
      providerRequestId: providerRequestId ?? this.providerRequestId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      state: state ?? this.state,
      providerOrderId: providerOrderId is String?
          ? providerOrderId
          : this.providerOrderId,
      approvalUrl: approvalUrl is String? ? approvalUrl : this.approvalUrl,
      captureId: captureId is String? ? captureId : this.captureId,
      webhookEventId: webhookEventId is String?
          ? webhookEventId
          : this.webhookEventId,
      webhookReceivedAt: webhookReceivedAt is DateTime?
          ? webhookReceivedAt
          : this.webhookReceivedAt,
      capturedAt: capturedAt is DateTime? ? capturedAt : this.capturedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SandboxPaymentUpdateTable extends _is.UpdateTable<SandboxPaymentTable> {
  SandboxPaymentUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> requestKey(String value) => _is.ColumnValue(
    table.requestKey,
    value,
  );

  _is.ColumnValue<String, String> providerRequestId(String value) =>
      _is.ColumnValue(
        table.providerRequestId,
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

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> providerOrderId(String? value) =>
      _is.ColumnValue(
        table.providerOrderId,
        value,
      );

  _is.ColumnValue<String, String> approvalUrl(String? value) => _is.ColumnValue(
    table.approvalUrl,
    value,
  );

  _is.ColumnValue<String, String> captureId(String? value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<String, String> webhookEventId(String? value) =>
      _is.ColumnValue(
        table.webhookEventId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> webhookReceivedAt(DateTime? value) =>
      _is.ColumnValue(
        table.webhookReceivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> capturedAt(DateTime? value) =>
      _is.ColumnValue(
        table.capturedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SandboxPaymentTable extends _is.Table<int?> {
  SandboxPaymentTable({super.tableRelation})
    : super(tableName: 'raysto_sandbox_payment') {
    updateTable = SandboxPaymentUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    requestKey = _is.ColumnString(
      'requestKey',
      this,
    );
    providerRequestId = _is.ColumnString(
      'providerRequestId',
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
    state = _is.ColumnString(
      'state',
      this,
    );
    providerOrderId = _is.ColumnString(
      'providerOrderId',
      this,
    );
    approvalUrl = _is.ColumnString(
      'approvalUrl',
      this,
    );
    captureId = _is.ColumnString(
      'captureId',
      this,
    );
    webhookEventId = _is.ColumnString(
      'webhookEventId',
      this,
    );
    webhookReceivedAt = _is.ColumnDateTime(
      'webhookReceivedAt',
      this,
    );
    capturedAt = _is.ColumnDateTime(
      'capturedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SandboxPaymentUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString requestKey;

  late final _is.ColumnString providerRequestId;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString state;

  late final _is.ColumnString providerOrderId;

  late final _is.ColumnString approvalUrl;

  late final _is.ColumnString captureId;

  late final _is.ColumnString webhookEventId;

  late final _is.ColumnDateTime webhookReceivedAt;

  late final _is.ColumnDateTime capturedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    requestKey,
    providerRequestId,
    amountMinor,
    currency,
    state,
    providerOrderId,
    approvalUrl,
    captureId,
    webhookEventId,
    webhookReceivedAt,
    capturedAt,
    createdAt,
  ];
}

class SandboxPaymentInclude extends _is.IncludeObject {
  SandboxPaymentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SandboxPayment.t;
}

class SandboxPaymentIncludeList extends _is.IncludeList {
  SandboxPaymentIncludeList._({
    _is.WhereExpressionBuilder<SandboxPaymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SandboxPayment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SandboxPayment.t;
}

class SandboxPaymentRepository {
  const SandboxPaymentRepository._();

  /// Returns a list of [SandboxPayment]s matching the given query parameters.
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
  Future<List<SandboxPayment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SandboxPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SandboxPaymentTable>? orderBy,
    _is.OrderByListBuilder<SandboxPaymentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SandboxPayment>(
      where: where?.call(SandboxPayment.t),
      orderBy: orderBy?.call(SandboxPayment.t),
      orderByList: orderByList?.call(SandboxPayment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SandboxPayment] matching the given query parameters.
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
  Future<SandboxPayment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SandboxPaymentTable>? where,
    int? offset,
    _is.OrderByBuilder<SandboxPaymentTable>? orderBy,
    _is.OrderByListBuilder<SandboxPaymentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SandboxPayment>(
      where: where?.call(SandboxPayment.t),
      orderBy: orderBy?.call(SandboxPayment.t),
      orderByList: orderByList?.call(SandboxPayment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SandboxPayment] by its [id] or null if no such row exists.
  Future<SandboxPayment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SandboxPayment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SandboxPayment]s in the list and returns the inserted rows.
  ///
  /// The returned [SandboxPayment]s will have their `id` fields set.
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
  Future<List<SandboxPayment>> insert(
    _is.DatabaseSession session,
    List<SandboxPayment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SandboxPayment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SandboxPayment] and returns the inserted row.
  ///
  /// The returned [SandboxPayment] will have its `id` field set.
  Future<SandboxPayment> insertRow(
    _is.DatabaseSession session,
    SandboxPayment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SandboxPayment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SandboxPayment]s in the list and returns the resulting rows.
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
  /// The returned [SandboxPayment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SandboxPayment>> upsert(
    _is.DatabaseSession session,
    List<SandboxPayment> rows, {
    required _is.ColumnSelections<SandboxPaymentTable> conflictColumns,
    _is.ColumnSelections<SandboxPaymentTable>? updateColumns,
    _is.WhereExpressionBuilder<SandboxPaymentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SandboxPayment>(
      rows,
      conflictColumns: conflictColumns(SandboxPayment.t),
      updateColumns: updateColumns?.call(SandboxPayment.t),
      updateWhere: updateWhere?.call(SandboxPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SandboxPayment] and returns the resulting row.
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
  /// The returned [SandboxPayment] will have its `id` field set.
  Future<SandboxPayment?> upsertRow(
    _is.DatabaseSession session,
    SandboxPayment row, {
    required _is.ColumnSelections<SandboxPaymentTable> conflictColumns,
    _is.ColumnSelections<SandboxPaymentTable>? updateColumns,
    _is.WhereExpressionBuilder<SandboxPaymentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SandboxPayment>(
      row,
      conflictColumns: conflictColumns(SandboxPayment.t),
      updateColumns: updateColumns?.call(SandboxPayment.t),
      updateWhere: updateWhere?.call(SandboxPayment.t),
      transaction: transaction,
    );
  }

  /// Updates all [SandboxPayment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SandboxPayment>> update(
    _is.DatabaseSession session,
    List<SandboxPayment> rows, {
    _is.ColumnSelections<SandboxPaymentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SandboxPayment>(
      rows,
      columns: columns?.call(SandboxPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SandboxPayment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SandboxPayment> updateRow(
    _is.DatabaseSession session,
    SandboxPayment row, {
    _is.ColumnSelections<SandboxPaymentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SandboxPayment>(
      row,
      columns: columns?.call(SandboxPayment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SandboxPayment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SandboxPayment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SandboxPaymentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SandboxPayment>(
      id,
      columnValues: columnValues(SandboxPayment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SandboxPayment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SandboxPayment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SandboxPaymentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SandboxPaymentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SandboxPaymentTable>? orderBy,
    _is.OrderByListBuilder<SandboxPaymentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SandboxPayment>(
      columnValues: columnValues(SandboxPayment.t.updateTable),
      where: where(SandboxPayment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SandboxPayment.t),
      orderByList: orderByList?.call(SandboxPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SandboxPayment]s in the list and returns the deleted rows.
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
  Future<List<SandboxPayment>> delete(
    _is.DatabaseSession session,
    List<SandboxPayment> rows, {
    _is.OrderByBuilder<SandboxPaymentTable>? orderBy,
    _is.OrderByListBuilder<SandboxPaymentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SandboxPayment>(
      rows,
      orderBy: orderBy?.call(SandboxPayment.t),
      orderByList: orderByList?.call(SandboxPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SandboxPayment].
  Future<SandboxPayment> deleteRow(
    _is.DatabaseSession session,
    SandboxPayment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SandboxPayment>(
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
  Future<List<SandboxPayment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SandboxPaymentTable> where,
    _is.OrderByBuilder<SandboxPaymentTable>? orderBy,
    _is.OrderByListBuilder<SandboxPaymentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SandboxPayment>(
      where: where(SandboxPayment.t),
      orderBy: orderBy?.call(SandboxPayment.t),
      orderByList: orderByList?.call(SandboxPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SandboxPaymentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SandboxPayment>(
      where: where?.call(SandboxPayment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SandboxPayment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SandboxPaymentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SandboxPayment>(
      where: where(SandboxPayment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
