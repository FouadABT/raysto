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

abstract class PayoutItem
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PayoutItem._({
    this.id,
    required this.restaurantId,
    required this.batchId,
    required this.recipientEmail,
    required this.recipientName,
    required this.shiftIdsJson,
    required this.amountMinor,
    required this.note,
    this.providerItemId,
    required this.state,
  });

  factory PayoutItem({
    int? id,
    required int restaurantId,
    required int batchId,
    required String recipientEmail,
    required String recipientName,
    required String shiftIdsJson,
    required int amountMinor,
    required String note,
    String? providerItemId,
    required String state,
  }) = _PayoutItemImpl;

  factory PayoutItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return PayoutItem(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      batchId: jsonSerialization['batchId'] as int,
      recipientEmail: jsonSerialization['recipientEmail'] as String,
      recipientName: jsonSerialization['recipientName'] as String,
      shiftIdsJson: jsonSerialization['shiftIdsJson'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      note: jsonSerialization['note'] as String,
      providerItemId: jsonSerialization['providerItemId'] as String?,
      state: jsonSerialization['state'] as String,
    );
  }

  static final t = PayoutItemTable();

  static const db = PayoutItemRepository._();

  @override
  int? id;

  int restaurantId;

  int batchId;

  String recipientEmail;

  String recipientName;

  String shiftIdsJson;

  int amountMinor;

  String note;

  String? providerItemId;

  String state;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PayoutItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PayoutItem copyWith({
    int? id,
    int? restaurantId,
    int? batchId,
    String? recipientEmail,
    String? recipientName,
    String? shiftIdsJson,
    int? amountMinor,
    String? note,
    String? providerItemId,
    String? state,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PayoutItem',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'batchId': batchId,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'shiftIdsJson': shiftIdsJson,
      'amountMinor': amountMinor,
      'note': note,
      if (providerItemId != null) 'providerItemId': providerItemId,
      'state': state,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PayoutItemInclude include() {
    return PayoutItemInclude._();
  }

  static PayoutItemIncludeList includeList({
    _is.WhereExpressionBuilder<PayoutItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayoutItemTable>? orderBy,
    _is.OrderByListBuilder<PayoutItemTable>? orderByList,
    PayoutItemInclude? include,
  }) {
    return PayoutItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PayoutItem.t),
      orderByList: orderByList?.call(PayoutItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PayoutItemImpl extends PayoutItem {
  _PayoutItemImpl({
    int? id,
    required int restaurantId,
    required int batchId,
    required String recipientEmail,
    required String recipientName,
    required String shiftIdsJson,
    required int amountMinor,
    required String note,
    String? providerItemId,
    required String state,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         batchId: batchId,
         recipientEmail: recipientEmail,
         recipientName: recipientName,
         shiftIdsJson: shiftIdsJson,
         amountMinor: amountMinor,
         note: note,
         providerItemId: providerItemId,
         state: state,
       );

  /// Returns a shallow copy of this [PayoutItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PayoutItem copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? batchId,
    String? recipientEmail,
    String? recipientName,
    String? shiftIdsJson,
    int? amountMinor,
    String? note,
    Object? providerItemId = _Undefined,
    String? state,
  }) {
    return PayoutItem(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      batchId: batchId ?? this.batchId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      shiftIdsJson: shiftIdsJson ?? this.shiftIdsJson,
      amountMinor: amountMinor ?? this.amountMinor,
      note: note ?? this.note,
      providerItemId: providerItemId is String?
          ? providerItemId
          : this.providerItemId,
      state: state ?? this.state,
    );
  }
}

class PayoutItemUpdateTable extends _is.UpdateTable<PayoutItemTable> {
  PayoutItemUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<int, int> batchId(int value) => _is.ColumnValue(
    table.batchId,
    value,
  );

  _is.ColumnValue<String, String> recipientEmail(String value) =>
      _is.ColumnValue(
        table.recipientEmail,
        value,
      );

  _is.ColumnValue<String, String> recipientName(String value) =>
      _is.ColumnValue(
        table.recipientName,
        value,
      );

  _is.ColumnValue<String, String> shiftIdsJson(String value) => _is.ColumnValue(
    table.shiftIdsJson,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<String, String> note(String value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<String, String> providerItemId(String? value) =>
      _is.ColumnValue(
        table.providerItemId,
        value,
      );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );
}

class PayoutItemTable extends _is.Table<int?> {
  PayoutItemTable({super.tableRelation})
    : super(tableName: 'raysto_payout_item') {
    updateTable = PayoutItemUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    batchId = _is.ColumnInt(
      'batchId',
      this,
    );
    recipientEmail = _is.ColumnString(
      'recipientEmail',
      this,
    );
    recipientName = _is.ColumnString(
      'recipientName',
      this,
    );
    shiftIdsJson = _is.ColumnString(
      'shiftIdsJson',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    providerItemId = _is.ColumnString(
      'providerItemId',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
  }

  late final PayoutItemUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnInt batchId;

  late final _is.ColumnString recipientEmail;

  late final _is.ColumnString recipientName;

  late final _is.ColumnString shiftIdsJson;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString note;

  late final _is.ColumnString providerItemId;

  late final _is.ColumnString state;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    batchId,
    recipientEmail,
    recipientName,
    shiftIdsJson,
    amountMinor,
    note,
    providerItemId,
    state,
  ];
}

class PayoutItemInclude extends _is.IncludeObject {
  PayoutItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PayoutItem.t;
}

class PayoutItemIncludeList extends _is.IncludeList {
  PayoutItemIncludeList._({
    _is.WhereExpressionBuilder<PayoutItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PayoutItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PayoutItem.t;
}

class PayoutItemRepository {
  const PayoutItemRepository._();

  /// Returns a list of [PayoutItem]s matching the given query parameters.
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
  Future<List<PayoutItem>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayoutItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayoutItemTable>? orderBy,
    _is.OrderByListBuilder<PayoutItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PayoutItem>(
      where: where?.call(PayoutItem.t),
      orderBy: orderBy?.call(PayoutItem.t),
      orderByList: orderByList?.call(PayoutItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PayoutItem] matching the given query parameters.
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
  Future<PayoutItem?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayoutItemTable>? where,
    int? offset,
    _is.OrderByBuilder<PayoutItemTable>? orderBy,
    _is.OrderByListBuilder<PayoutItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PayoutItem>(
      where: where?.call(PayoutItem.t),
      orderBy: orderBy?.call(PayoutItem.t),
      orderByList: orderByList?.call(PayoutItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PayoutItem] by its [id] or null if no such row exists.
  Future<PayoutItem?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PayoutItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PayoutItem]s in the list and returns the inserted rows.
  ///
  /// The returned [PayoutItem]s will have their `id` fields set.
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
  Future<List<PayoutItem>> insert(
    _is.DatabaseSession session,
    List<PayoutItem> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PayoutItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PayoutItem] and returns the inserted row.
  ///
  /// The returned [PayoutItem] will have its `id` field set.
  Future<PayoutItem> insertRow(
    _is.DatabaseSession session,
    PayoutItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PayoutItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PayoutItem]s in the list and returns the resulting rows.
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
  /// The returned [PayoutItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PayoutItem>> upsert(
    _is.DatabaseSession session,
    List<PayoutItem> rows, {
    required _is.ColumnSelections<PayoutItemTable> conflictColumns,
    _is.ColumnSelections<PayoutItemTable>? updateColumns,
    _is.WhereExpressionBuilder<PayoutItemTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PayoutItem>(
      rows,
      conflictColumns: conflictColumns(PayoutItem.t),
      updateColumns: updateColumns?.call(PayoutItem.t),
      updateWhere: updateWhere?.call(PayoutItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PayoutItem] and returns the resulting row.
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
  /// The returned [PayoutItem] will have its `id` field set.
  Future<PayoutItem?> upsertRow(
    _is.DatabaseSession session,
    PayoutItem row, {
    required _is.ColumnSelections<PayoutItemTable> conflictColumns,
    _is.ColumnSelections<PayoutItemTable>? updateColumns,
    _is.WhereExpressionBuilder<PayoutItemTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PayoutItem>(
      row,
      conflictColumns: conflictColumns(PayoutItem.t),
      updateColumns: updateColumns?.call(PayoutItem.t),
      updateWhere: updateWhere?.call(PayoutItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [PayoutItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PayoutItem>> update(
    _is.DatabaseSession session,
    List<PayoutItem> rows, {
    _is.ColumnSelections<PayoutItemTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PayoutItem>(
      rows,
      columns: columns?.call(PayoutItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PayoutItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PayoutItem> updateRow(
    _is.DatabaseSession session,
    PayoutItem row, {
    _is.ColumnSelections<PayoutItemTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PayoutItem>(
      row,
      columns: columns?.call(PayoutItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PayoutItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PayoutItem?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PayoutItemUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PayoutItem>(
      id,
      columnValues: columnValues(PayoutItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PayoutItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PayoutItem>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PayoutItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PayoutItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayoutItemTable>? orderBy,
    _is.OrderByListBuilder<PayoutItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PayoutItem>(
      columnValues: columnValues(PayoutItem.t.updateTable),
      where: where(PayoutItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PayoutItem.t),
      orderByList: orderByList?.call(PayoutItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PayoutItem]s in the list and returns the deleted rows.
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
  Future<List<PayoutItem>> delete(
    _is.DatabaseSession session,
    List<PayoutItem> rows, {
    _is.OrderByBuilder<PayoutItemTable>? orderBy,
    _is.OrderByListBuilder<PayoutItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PayoutItem>(
      rows,
      orderBy: orderBy?.call(PayoutItem.t),
      orderByList: orderByList?.call(PayoutItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PayoutItem].
  Future<PayoutItem> deleteRow(
    _is.DatabaseSession session,
    PayoutItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PayoutItem>(
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
  Future<List<PayoutItem>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PayoutItemTable> where,
    _is.OrderByBuilder<PayoutItemTable>? orderBy,
    _is.OrderByListBuilder<PayoutItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PayoutItem>(
      where: where(PayoutItem.t),
      orderBy: orderBy?.call(PayoutItem.t),
      orderByList: orderByList?.call(PayoutItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayoutItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PayoutItem>(
      where: where?.call(PayoutItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PayoutItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PayoutItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PayoutItem>(
      where: where(PayoutItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
