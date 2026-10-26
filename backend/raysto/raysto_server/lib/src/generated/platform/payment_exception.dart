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

abstract class PaymentException
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PaymentException._({
    this.id,
    required this.restaurantId,
    required this.captureId,
    required this.providerEventId,
    required this.kind,
    required this.status,
    required this.amountMinor,
    required this.currency,
    required this.evidenceJson,
    required this.version,
    required this.createdAt,
  });

  factory PaymentException({
    int? id,
    required int restaurantId,
    required int captureId,
    required String providerEventId,
    required String kind,
    required String status,
    required int amountMinor,
    required String currency,
    required String evidenceJson,
    required int version,
    required DateTime createdAt,
  }) = _PaymentExceptionImpl;

  factory PaymentException.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentException(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      captureId: jsonSerialization['captureId'] as int,
      providerEventId: jsonSerialization['providerEventId'] as String,
      kind: jsonSerialization['kind'] as String,
      status: jsonSerialization['status'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      evidenceJson: jsonSerialization['evidenceJson'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PaymentExceptionTable();

  static const db = PaymentExceptionRepository._();

  @override
  int? id;

  int restaurantId;

  int captureId;

  String providerEventId;

  String kind;

  String status;

  int amountMinor;

  String currency;

  String evidenceJson;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PaymentException copyWith({
    int? id,
    int? restaurantId,
    int? captureId,
    String? providerEventId,
    String? kind,
    String? status,
    int? amountMinor,
    String? currency,
    String? evidenceJson,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentException',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'captureId': captureId,
      'providerEventId': providerEventId,
      'kind': kind,
      'status': status,
      'amountMinor': amountMinor,
      'currency': currency,
      'evidenceJson': evidenceJson,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PaymentExceptionInclude include() {
    return PaymentExceptionInclude._();
  }

  static PaymentExceptionIncludeList includeList({
    _is.WhereExpressionBuilder<PaymentExceptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentExceptionTable>? orderBy,
    _is.OrderByListBuilder<PaymentExceptionTable>? orderByList,
    PaymentExceptionInclude? include,
  }) {
    return PaymentExceptionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentException.t),
      orderByList: orderByList?.call(PaymentException.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentExceptionImpl extends PaymentException {
  _PaymentExceptionImpl({
    int? id,
    required int restaurantId,
    required int captureId,
    required String providerEventId,
    required String kind,
    required String status,
    required int amountMinor,
    required String currency,
    required String evidenceJson,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         captureId: captureId,
         providerEventId: providerEventId,
         kind: kind,
         status: status,
         amountMinor: amountMinor,
         currency: currency,
         evidenceJson: evidenceJson,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PaymentException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PaymentException copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? captureId,
    String? providerEventId,
    String? kind,
    String? status,
    int? amountMinor,
    String? currency,
    String? evidenceJson,
    int? version,
    DateTime? createdAt,
  }) {
    return PaymentException(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      captureId: captureId ?? this.captureId,
      providerEventId: providerEventId ?? this.providerEventId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentExceptionUpdateTable
    extends _is.UpdateTable<PaymentExceptionTable> {
  PaymentExceptionUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> captureId(int value) => _is.ColumnValue(
    table.captureId,
    value,
  );

  _is.ColumnValue<String, String> providerEventId(String value) =>
      _is.ColumnValue(
        table.providerEventId,
        value,
      );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
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

  _is.ColumnValue<String, String> evidenceJson(String value) => _is.ColumnValue(
    table.evidenceJson,
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
}

class PaymentExceptionTable extends _is.Table<int?> {
  PaymentExceptionTable({super.tableRelation})
    : super(tableName: 'raysto_payment_exception') {
    updateTable = PaymentExceptionUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    captureId = _is.ColumnInt(
      'captureId',
      this,
    );
    providerEventId = _is.ColumnString(
      'providerEventId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    status = _is.ColumnString(
      'status',
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
    evidenceJson = _is.ColumnString(
      'evidenceJson',
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
  }

  late final PaymentExceptionUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt captureId;

  late final _is.ColumnString providerEventId;

  late final _is.ColumnString kind;

  late final _is.ColumnString status;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnString evidenceJson;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    captureId,
    providerEventId,
    kind,
    status,
    amountMinor,
    currency,
    evidenceJson,
    version,
    createdAt,
  ];
}

class PaymentExceptionInclude extends _is.IncludeObject {
  PaymentExceptionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PaymentException.t;
}

class PaymentExceptionIncludeList extends _is.IncludeList {
  PaymentExceptionIncludeList._({
    _is.WhereExpressionBuilder<PaymentExceptionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentException.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PaymentException.t;
}

class PaymentExceptionRepository {
  const PaymentExceptionRepository._();

  /// Returns a list of [PaymentException]s matching the given query parameters.
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
  Future<List<PaymentException>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentExceptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentExceptionTable>? orderBy,
    _is.OrderByListBuilder<PaymentExceptionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PaymentException>(
      where: where?.call(PaymentException.t),
      orderBy: orderBy?.call(PaymentException.t),
      orderByList: orderByList?.call(PaymentException.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PaymentException] matching the given query parameters.
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
  Future<PaymentException?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentExceptionTable>? where,
    int? offset,
    _is.OrderByBuilder<PaymentExceptionTable>? orderBy,
    _is.OrderByListBuilder<PaymentExceptionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PaymentException>(
      where: where?.call(PaymentException.t),
      orderBy: orderBy?.call(PaymentException.t),
      orderByList: orderByList?.call(PaymentException.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PaymentException] by its [id] or null if no such row exists.
  Future<PaymentException?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PaymentException>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PaymentException]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentException]s will have their `id` fields set.
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
  Future<List<PaymentException>> insert(
    _is.DatabaseSession session,
    List<PaymentException> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PaymentException>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PaymentException] and returns the inserted row.
  ///
  /// The returned [PaymentException] will have its `id` field set.
  Future<PaymentException> insertRow(
    _is.DatabaseSession session,
    PaymentException row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentException>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PaymentException]s in the list and returns the resulting rows.
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
  /// The returned [PaymentException]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentException>> upsert(
    _is.DatabaseSession session,
    List<PaymentException> rows, {
    required _is.ColumnSelections<PaymentExceptionTable> conflictColumns,
    _is.ColumnSelections<PaymentExceptionTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentExceptionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PaymentException>(
      rows,
      conflictColumns: conflictColumns(PaymentException.t),
      updateColumns: updateColumns?.call(PaymentException.t),
      updateWhere: updateWhere?.call(PaymentException.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PaymentException] and returns the resulting row.
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
  /// The returned [PaymentException] will have its `id` field set.
  Future<PaymentException?> upsertRow(
    _is.DatabaseSession session,
    PaymentException row, {
    required _is.ColumnSelections<PaymentExceptionTable> conflictColumns,
    _is.ColumnSelections<PaymentExceptionTable>? updateColumns,
    _is.WhereExpressionBuilder<PaymentExceptionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PaymentException>(
      row,
      conflictColumns: conflictColumns(PaymentException.t),
      updateColumns: updateColumns?.call(PaymentException.t),
      updateWhere: updateWhere?.call(PaymentException.t),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentException]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentException>> update(
    _is.DatabaseSession session,
    List<PaymentException> rows, {
    _is.ColumnSelections<PaymentExceptionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PaymentException>(
      rows,
      columns: columns?.call(PaymentException.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PaymentException]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentException> updateRow(
    _is.DatabaseSession session,
    PaymentException row, {
    _is.ColumnSelections<PaymentExceptionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentException>(
      row,
      columns: columns?.call(PaymentException.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentException] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PaymentException?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PaymentExceptionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PaymentException>(
      id,
      columnValues: columnValues(PaymentException.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PaymentException]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PaymentException>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PaymentExceptionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PaymentExceptionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PaymentExceptionTable>? orderBy,
    _is.OrderByListBuilder<PaymentExceptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PaymentException>(
      columnValues: columnValues(PaymentException.t.updateTable),
      where: where(PaymentException.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentException.t),
      orderByList: orderByList?.call(PaymentException.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PaymentException]s in the list and returns the deleted rows.
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
  Future<List<PaymentException>> delete(
    _is.DatabaseSession session,
    List<PaymentException> rows, {
    _is.OrderByBuilder<PaymentExceptionTable>? orderBy,
    _is.OrderByListBuilder<PaymentExceptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PaymentException>(
      rows,
      orderBy: orderBy?.call(PaymentException.t),
      orderByList: orderByList?.call(PaymentException.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PaymentException].
  Future<PaymentException> deleteRow(
    _is.DatabaseSession session,
    PaymentException row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentException>(
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
  Future<List<PaymentException>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentExceptionTable> where,
    _is.OrderByBuilder<PaymentExceptionTable>? orderBy,
    _is.OrderByListBuilder<PaymentExceptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PaymentException>(
      where: where(PaymentException.t),
      orderBy: orderBy?.call(PaymentException.t),
      orderByList: orderByList?.call(PaymentException.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PaymentExceptionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PaymentException>(
      where: where?.call(PaymentException.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PaymentException] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PaymentExceptionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PaymentException>(
      where: where(PaymentException.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
