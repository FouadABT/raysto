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

abstract class Supplier
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Supplier._({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.payoutEmail,
    required this.version,
    required this.createdAt,
  });

  factory Supplier({
    int? id,
    required int restaurantId,
    required String name,
    required String payoutEmail,
    required int version,
    required DateTime createdAt,
  }) = _SupplierImpl;

  factory Supplier.fromJson(Map<String, dynamic> jsonSerialization) {
    return Supplier(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      name: jsonSerialization['name'] as String,
      payoutEmail: jsonSerialization['payoutEmail'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SupplierTable();

  static const db = SupplierRepository._();

  @override
  int? id;

  int restaurantId;

  String name;

  String payoutEmail;

  int version;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Supplier]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Supplier copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? payoutEmail,
    int? version,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Supplier',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'payoutEmail': payoutEmail,
      'version': version,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SupplierInclude include() {
    return SupplierInclude._();
  }

  static SupplierIncludeList includeList({
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    SupplierInclude? include,
  }) {
    return SupplierIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SupplierImpl extends Supplier {
  _SupplierImpl({
    int? id,
    required int restaurantId,
    required String name,
    required String payoutEmail,
    required int version,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         name: name,
         payoutEmail: payoutEmail,
         version: version,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Supplier]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Supplier copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? name,
    String? payoutEmail,
    int? version,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      payoutEmail: payoutEmail ?? this.payoutEmail,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SupplierUpdateTable extends _is.UpdateTable<SupplierTable> {
  SupplierUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> payoutEmail(String value) => _is.ColumnValue(
    table.payoutEmail,
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

class SupplierTable extends _is.Table<int?> {
  SupplierTable({super.tableRelation}) : super(tableName: 'raysto_supplier') {
    updateTable = SupplierUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    payoutEmail = _is.ColumnString(
      'payoutEmail',
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

  late final SupplierUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString name;

  late final _is.ColumnString payoutEmail;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    name,
    payoutEmail,
    version,
    createdAt,
  ];
}

class SupplierInclude extends _is.IncludeObject {
  SupplierInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Supplier.t;
}

class SupplierIncludeList extends _is.IncludeList {
  SupplierIncludeList._({
    _is.WhereExpressionBuilder<SupplierTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Supplier.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Supplier.t;
}

class SupplierRepository {
  const SupplierRepository._();

  /// Returns a list of [Supplier]s matching the given query parameters.
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
  Future<List<Supplier>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Supplier>(
      where: where?.call(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Supplier] matching the given query parameters.
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
  Future<Supplier?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Supplier>(
      where: where?.call(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Supplier] by its [id] or null if no such row exists.
  Future<Supplier?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Supplier>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Supplier]s in the list and returns the inserted rows.
  ///
  /// The returned [Supplier]s will have their `id` fields set.
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
  Future<List<Supplier>> insert(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Supplier>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Supplier] and returns the inserted row.
  ///
  /// The returned [Supplier] will have its `id` field set.
  Future<Supplier> insertRow(
    _is.DatabaseSession session,
    Supplier row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Supplier>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Supplier]s in the list and returns the resulting rows.
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
  /// The returned [Supplier]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Supplier>> upsert(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    required _is.ColumnSelections<SupplierTable> conflictColumns,
    _is.ColumnSelections<SupplierTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplierTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Supplier>(
      rows,
      conflictColumns: conflictColumns(Supplier.t),
      updateColumns: updateColumns?.call(Supplier.t),
      updateWhere: updateWhere?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Supplier] and returns the resulting row.
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
  /// The returned [Supplier] will have its `id` field set.
  Future<Supplier?> upsertRow(
    _is.DatabaseSession session,
    Supplier row, {
    required _is.ColumnSelections<SupplierTable> conflictColumns,
    _is.ColumnSelections<SupplierTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplierTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Supplier>(
      row,
      conflictColumns: conflictColumns(Supplier.t),
      updateColumns: updateColumns?.call(Supplier.t),
      updateWhere: updateWhere?.call(Supplier.t),
      transaction: transaction,
    );
  }

  /// Updates all [Supplier]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Supplier>> update(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    _is.ColumnSelections<SupplierTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Supplier>(
      rows,
      columns: columns?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Supplier]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Supplier> updateRow(
    _is.DatabaseSession session,
    Supplier row, {
    _is.ColumnSelections<SupplierTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Supplier>(
      row,
      columns: columns?.call(Supplier.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Supplier] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Supplier?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SupplierUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Supplier>(
      id,
      columnValues: columnValues(Supplier.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Supplier]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Supplier>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SupplierUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SupplierTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Supplier>(
      columnValues: columnValues(Supplier.t.updateTable),
      where: where(Supplier.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Supplier]s in the list and returns the deleted rows.
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
  Future<List<Supplier>> delete(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Supplier>(
      rows,
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Supplier].
  Future<Supplier> deleteRow(
    _is.DatabaseSession session,
    Supplier row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Supplier>(
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
  Future<List<Supplier>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplierTable> where,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Supplier>(
      where: where(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Supplier>(
      where: where?.call(Supplier.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Supplier] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplierTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Supplier>(
      where: where(Supplier.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
