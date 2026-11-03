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

abstract class Expense
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Expense._({
    this.id,
    required this.restaurantId,
    required this.category,
    required this.amountMinor,
    required this.currency,
    required this.vatMinor,
    required this.spentAt,
    this.mediaId,
    required this.merchant,
    this.paypalTransactionId,
    this.taskId,
    required this.createdAt,
  });

  factory Expense({
    int? id,
    required int restaurantId,
    required String category,
    required int amountMinor,
    required String currency,
    required int vatMinor,
    required DateTime spentAt,
    int? mediaId,
    required String merchant,
    String? paypalTransactionId,
    int? taskId,
    required DateTime createdAt,
  }) = _ExpenseImpl;

  factory Expense.fromJson(Map<String, dynamic> jsonSerialization) {
    return Expense(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      category: jsonSerialization['category'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      vatMinor: jsonSerialization['vatMinor'] as int,
      spentAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['spentAt']),
      mediaId: jsonSerialization['mediaId'] as int?,
      merchant: jsonSerialization['merchant'] as String,
      paypalTransactionId: jsonSerialization['paypalTransactionId'] as String?,
      taskId: jsonSerialization['taskId'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ExpenseTable();

  static const db = ExpenseRepository._();

  @override
  int? id;

  int restaurantId;

  String category;

  int amountMinor;

  String currency;

  int vatMinor;

  DateTime spentAt;

  int? mediaId;

  String merchant;

  String? paypalTransactionId;

  int? taskId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Expense]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Expense copyWith({
    int? id,
    int? restaurantId,
    String? category,
    int? amountMinor,
    String? currency,
    int? vatMinor,
    DateTime? spentAt,
    int? mediaId,
    String? merchant,
    String? paypalTransactionId,
    int? taskId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Expense',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'category': category,
      'amountMinor': amountMinor,
      'currency': currency,
      'vatMinor': vatMinor,
      'spentAt': spentAt.toJson(),
      if (mediaId != null) 'mediaId': mediaId,
      'merchant': merchant,
      if (paypalTransactionId != null)
        'paypalTransactionId': paypalTransactionId,
      if (taskId != null) 'taskId': taskId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ExpenseInclude include() {
    return ExpenseInclude._();
  }

  static ExpenseIncludeList includeList({
    _is.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ExpenseTable>? orderBy,
    _is.OrderByListBuilder<ExpenseTable>? orderByList,
    ExpenseInclude? include,
  }) {
    return ExpenseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExpenseImpl extends Expense {
  _ExpenseImpl({
    int? id,
    required int restaurantId,
    required String category,
    required int amountMinor,
    required String currency,
    required int vatMinor,
    required DateTime spentAt,
    int? mediaId,
    required String merchant,
    String? paypalTransactionId,
    int? taskId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         category: category,
         amountMinor: amountMinor,
         currency: currency,
         vatMinor: vatMinor,
         spentAt: spentAt,
         mediaId: mediaId,
         merchant: merchant,
         paypalTransactionId: paypalTransactionId,
         taskId: taskId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Expense]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Expense copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? category,
    int? amountMinor,
    String? currency,
    int? vatMinor,
    DateTime? spentAt,
    Object? mediaId = _Undefined,
    String? merchant,
    Object? paypalTransactionId = _Undefined,
    Object? taskId = _Undefined,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      category: category ?? this.category,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      vatMinor: vatMinor ?? this.vatMinor,
      spentAt: spentAt ?? this.spentAt,
      mediaId: mediaId is int? ? mediaId : this.mediaId,
      merchant: merchant ?? this.merchant,
      paypalTransactionId: paypalTransactionId is String?
          ? paypalTransactionId
          : this.paypalTransactionId,
      taskId: taskId is int? ? taskId : this.taskId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExpenseUpdateTable extends _is.UpdateTable<ExpenseTable> {
  ExpenseUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> category(String value) => _is.ColumnValue(
    table.category,
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

  _is.ColumnValue<int, int> vatMinor(int value) => _is.ColumnValue(
    table.vatMinor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> spentAt(DateTime value) =>
      _is.ColumnValue(
        table.spentAt,
        value,
      );

  _is.ColumnValue<int, int> mediaId(int? value) => _is.ColumnValue(
    table.mediaId,
    value,
  );

  _is.ColumnValue<String, String> merchant(String value) => _is.ColumnValue(
    table.merchant,
    value,
  );

  _is.ColumnValue<String, String> paypalTransactionId(String? value) =>
      _is.ColumnValue(
        table.paypalTransactionId,
        value,
      );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ExpenseTable extends _is.Table<int?> {
  ExpenseTable({super.tableRelation}) : super(tableName: 'raysto_expense') {
    updateTable = ExpenseUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    category = _is.ColumnString(
      'category',
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
    vatMinor = _is.ColumnInt(
      'vatMinor',
      this,
    );
    spentAt = _is.ColumnDateTime(
      'spentAt',
      this,
    );
    mediaId = _is.ColumnInt(
      'mediaId',
      this,
    );
    merchant = _is.ColumnString(
      'merchant',
      this,
    );
    paypalTransactionId = _is.ColumnString(
      'paypalTransactionId',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ExpenseUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString category;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnInt vatMinor;

  late final _is.ColumnDateTime spentAt;

  late final _is.ColumnInt mediaId;

  late final _is.ColumnString merchant;

  late final _is.ColumnString paypalTransactionId;

  late final _is.ColumnInt taskId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    category,
    amountMinor,
    currency,
    vatMinor,
    spentAt,
    mediaId,
    merchant,
    paypalTransactionId,
    taskId,
    createdAt,
  ];
}

class ExpenseInclude extends _is.IncludeObject {
  ExpenseInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Expense.t;
}

class ExpenseIncludeList extends _is.IncludeList {
  ExpenseIncludeList._({
    _is.WhereExpressionBuilder<ExpenseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Expense.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Expense.t;
}

class ExpenseRepository {
  const ExpenseRepository._();

  /// Returns a list of [Expense]s matching the given query parameters.
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
  Future<List<Expense>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ExpenseTable>? orderBy,
    _is.OrderByListBuilder<ExpenseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Expense>(
      where: where?.call(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Expense] matching the given query parameters.
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
  Future<Expense?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ExpenseTable>? where,
    int? offset,
    _is.OrderByBuilder<ExpenseTable>? orderBy,
    _is.OrderByListBuilder<ExpenseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Expense>(
      where: where?.call(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Expense] by its [id] or null if no such row exists.
  Future<Expense?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Expense>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Expense]s in the list and returns the inserted rows.
  ///
  /// The returned [Expense]s will have their `id` fields set.
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
  Future<List<Expense>> insert(
    _is.DatabaseSession session,
    List<Expense> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Expense>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Expense] and returns the inserted row.
  ///
  /// The returned [Expense] will have its `id` field set.
  Future<Expense> insertRow(
    _is.DatabaseSession session,
    Expense row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Expense>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Expense]s in the list and returns the resulting rows.
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
  /// The returned [Expense]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Expense>> upsert(
    _is.DatabaseSession session,
    List<Expense> rows, {
    required _is.ColumnSelections<ExpenseTable> conflictColumns,
    _is.ColumnSelections<ExpenseTable>? updateColumns,
    _is.WhereExpressionBuilder<ExpenseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Expense>(
      rows,
      conflictColumns: conflictColumns(Expense.t),
      updateColumns: updateColumns?.call(Expense.t),
      updateWhere: updateWhere?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Expense] and returns the resulting row.
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
  /// The returned [Expense] will have its `id` field set.
  Future<Expense?> upsertRow(
    _is.DatabaseSession session,
    Expense row, {
    required _is.ColumnSelections<ExpenseTable> conflictColumns,
    _is.ColumnSelections<ExpenseTable>? updateColumns,
    _is.WhereExpressionBuilder<ExpenseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Expense>(
      row,
      conflictColumns: conflictColumns(Expense.t),
      updateColumns: updateColumns?.call(Expense.t),
      updateWhere: updateWhere?.call(Expense.t),
      transaction: transaction,
    );
  }

  /// Updates all [Expense]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Expense>> update(
    _is.DatabaseSession session,
    List<Expense> rows, {
    _is.ColumnSelections<ExpenseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Expense>(
      rows,
      columns: columns?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Expense]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Expense> updateRow(
    _is.DatabaseSession session,
    Expense row, {
    _is.ColumnSelections<ExpenseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Expense>(
      row,
      columns: columns?.call(Expense.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Expense] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Expense?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ExpenseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Expense>(
      id,
      columnValues: columnValues(Expense.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Expense]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Expense>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ExpenseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ExpenseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ExpenseTable>? orderBy,
    _is.OrderByListBuilder<ExpenseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Expense>(
      columnValues: columnValues(Expense.t.updateTable),
      where: where(Expense.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Expense]s in the list and returns the deleted rows.
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
  Future<List<Expense>> delete(
    _is.DatabaseSession session,
    List<Expense> rows, {
    _is.OrderByBuilder<ExpenseTable>? orderBy,
    _is.OrderByListBuilder<ExpenseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Expense>(
      rows,
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Expense].
  Future<Expense> deleteRow(
    _is.DatabaseSession session,
    Expense row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Expense>(
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
  Future<List<Expense>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ExpenseTable> where,
    _is.OrderByBuilder<ExpenseTable>? orderBy,
    _is.OrderByListBuilder<ExpenseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Expense>(
      where: where(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Expense>(
      where: where?.call(Expense.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Expense] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ExpenseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Expense>(
      where: where(Expense.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
