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

abstract class PartnerApp
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PartnerApp._({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.keyPrefix,
    required this.keyHash,
    this.webhookUrl,
    required this.secretVersion,
    required this.simulator,
    required this.active,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerApp({
    int? id,
    required int restaurantId,
    required String name,
    required String keyPrefix,
    required String keyHash,
    String? webhookUrl,
    required int secretVersion,
    required bool simulator,
    required bool active,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PartnerAppImpl;

  factory PartnerApp.fromJson(Map<String, dynamic> jsonSerialization) {
    return PartnerApp(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      name: jsonSerialization['name'] as String,
      keyPrefix: jsonSerialization['keyPrefix'] as String,
      keyHash: jsonSerialization['keyHash'] as String,
      webhookUrl: jsonSerialization['webhookUrl'] as String?,
      secretVersion: jsonSerialization['secretVersion'] as int,
      simulator: _is.BoolJsonExtension.fromJson(jsonSerialization['simulator']),
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      version: jsonSerialization['version'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PartnerAppTable();

  static const db = PartnerAppRepository._();

  @override
  int? id;

  int restaurantId;

  String name;

  String keyPrefix;

  String keyHash;

  String? webhookUrl;

  int secretVersion;

  bool simulator;

  bool active;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PartnerApp]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PartnerApp copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? keyPrefix,
    String? keyHash,
    String? webhookUrl,
    int? secretVersion,
    bool? simulator,
    bool? active,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PartnerApp',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'keyPrefix': keyPrefix,
      'keyHash': keyHash,
      if (webhookUrl != null) 'webhookUrl': webhookUrl,
      'secretVersion': secretVersion,
      'simulator': simulator,
      'active': active,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PartnerAppInclude include() {
    return PartnerAppInclude._();
  }

  static PartnerAppIncludeList includeList({
    _is.WhereExpressionBuilder<PartnerAppTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartnerAppTable>? orderBy,
    _is.OrderByListBuilder<PartnerAppTable>? orderByList,
    PartnerAppInclude? include,
  }) {
    return PartnerAppIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PartnerApp.t),
      orderByList: orderByList?.call(PartnerApp.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PartnerAppImpl extends PartnerApp {
  _PartnerAppImpl({
    int? id,
    required int restaurantId,
    required String name,
    required String keyPrefix,
    required String keyHash,
    String? webhookUrl,
    required int secretVersion,
    required bool simulator,
    required bool active,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         name: name,
         keyPrefix: keyPrefix,
         keyHash: keyHash,
         webhookUrl: webhookUrl,
         secretVersion: secretVersion,
         simulator: simulator,
         active: active,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PartnerApp]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PartnerApp copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? name,
    String? keyPrefix,
    String? keyHash,
    Object? webhookUrl = _Undefined,
    int? secretVersion,
    bool? simulator,
    bool? active,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerApp(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      keyPrefix: keyPrefix ?? this.keyPrefix,
      keyHash: keyHash ?? this.keyHash,
      webhookUrl: webhookUrl is String? ? webhookUrl : this.webhookUrl,
      secretVersion: secretVersion ?? this.secretVersion,
      simulator: simulator ?? this.simulator,
      active: active ?? this.active,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PartnerAppUpdateTable extends _is.UpdateTable<PartnerAppTable> {
  PartnerAppUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> keyPrefix(String value) => _is.ColumnValue(
    table.keyPrefix,
    value,
  );

  _is.ColumnValue<String, String> keyHash(String value) => _is.ColumnValue(
    table.keyHash,
    value,
  );

  _is.ColumnValue<String, String> webhookUrl(String? value) => _is.ColumnValue(
    table.webhookUrl,
    value,
  );

  _is.ColumnValue<int, int> secretVersion(int value) => _is.ColumnValue(
    table.secretVersion,
    value,
  );

  _is.ColumnValue<bool, bool> simulator(bool value) => _is.ColumnValue(
    table.simulator,
    value,
  );

  _is.ColumnValue<bool, bool> active(bool value) => _is.ColumnValue(
    table.active,
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

class PartnerAppTable extends _is.Table<int?> {
  PartnerAppTable({super.tableRelation})
    : super(tableName: 'raysto_partner_app') {
    updateTable = PartnerAppUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    keyPrefix = _is.ColumnString(
      'keyPrefix',
      this,
    );
    keyHash = _is.ColumnString(
      'keyHash',
      this,
    );
    webhookUrl = _is.ColumnString(
      'webhookUrl',
      this,
    );
    secretVersion = _is.ColumnInt(
      'secretVersion',
      this,
    );
    simulator = _is.ColumnBool(
      'simulator',
      this,
    );
    active = _is.ColumnBool(
      'active',
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

  late final PartnerAppUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString name;

  late final _is.ColumnString keyPrefix;

  late final _is.ColumnString keyHash;

  late final _is.ColumnString webhookUrl;

  late final _is.ColumnInt secretVersion;

  late final _is.ColumnBool simulator;

  late final _is.ColumnBool active;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    name,
    keyPrefix,
    keyHash,
    webhookUrl,
    secretVersion,
    simulator,
    active,
    version,
    createdAt,
    updatedAt,
  ];
}

class PartnerAppInclude extends _is.IncludeObject {
  PartnerAppInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PartnerApp.t;
}

class PartnerAppIncludeList extends _is.IncludeList {
  PartnerAppIncludeList._({
    _is.WhereExpressionBuilder<PartnerAppTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PartnerApp.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PartnerApp.t;
}

class PartnerAppRepository {
  const PartnerAppRepository._();

  /// Returns a list of [PartnerApp]s matching the given query parameters.
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
  Future<List<PartnerApp>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartnerAppTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartnerAppTable>? orderBy,
    _is.OrderByListBuilder<PartnerAppTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PartnerApp>(
      where: where?.call(PartnerApp.t),
      orderBy: orderBy?.call(PartnerApp.t),
      orderByList: orderByList?.call(PartnerApp.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PartnerApp] matching the given query parameters.
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
  Future<PartnerApp?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartnerAppTable>? where,
    int? offset,
    _is.OrderByBuilder<PartnerAppTable>? orderBy,
    _is.OrderByListBuilder<PartnerAppTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PartnerApp>(
      where: where?.call(PartnerApp.t),
      orderBy: orderBy?.call(PartnerApp.t),
      orderByList: orderByList?.call(PartnerApp.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PartnerApp] by its [id] or null if no such row exists.
  Future<PartnerApp?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PartnerApp>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PartnerApp]s in the list and returns the inserted rows.
  ///
  /// The returned [PartnerApp]s will have their `id` fields set.
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
  Future<List<PartnerApp>> insert(
    _is.DatabaseSession session,
    List<PartnerApp> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PartnerApp>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PartnerApp] and returns the inserted row.
  ///
  /// The returned [PartnerApp] will have its `id` field set.
  Future<PartnerApp> insertRow(
    _is.DatabaseSession session,
    PartnerApp row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PartnerApp>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PartnerApp]s in the list and returns the resulting rows.
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
  /// The returned [PartnerApp]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PartnerApp>> upsert(
    _is.DatabaseSession session,
    List<PartnerApp> rows, {
    required _is.ColumnSelections<PartnerAppTable> conflictColumns,
    _is.ColumnSelections<PartnerAppTable>? updateColumns,
    _is.WhereExpressionBuilder<PartnerAppTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PartnerApp>(
      rows,
      conflictColumns: conflictColumns(PartnerApp.t),
      updateColumns: updateColumns?.call(PartnerApp.t),
      updateWhere: updateWhere?.call(PartnerApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PartnerApp] and returns the resulting row.
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
  /// The returned [PartnerApp] will have its `id` field set.
  Future<PartnerApp?> upsertRow(
    _is.DatabaseSession session,
    PartnerApp row, {
    required _is.ColumnSelections<PartnerAppTable> conflictColumns,
    _is.ColumnSelections<PartnerAppTable>? updateColumns,
    _is.WhereExpressionBuilder<PartnerAppTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PartnerApp>(
      row,
      conflictColumns: conflictColumns(PartnerApp.t),
      updateColumns: updateColumns?.call(PartnerApp.t),
      updateWhere: updateWhere?.call(PartnerApp.t),
      transaction: transaction,
    );
  }

  /// Updates all [PartnerApp]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PartnerApp>> update(
    _is.DatabaseSession session,
    List<PartnerApp> rows, {
    _is.ColumnSelections<PartnerAppTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PartnerApp>(
      rows,
      columns: columns?.call(PartnerApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PartnerApp]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PartnerApp> updateRow(
    _is.DatabaseSession session,
    PartnerApp row, {
    _is.ColumnSelections<PartnerAppTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PartnerApp>(
      row,
      columns: columns?.call(PartnerApp.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PartnerApp] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PartnerApp?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PartnerAppUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PartnerApp>(
      id,
      columnValues: columnValues(PartnerApp.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PartnerApp]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PartnerApp>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PartnerAppUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PartnerAppTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartnerAppTable>? orderBy,
    _is.OrderByListBuilder<PartnerAppTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PartnerApp>(
      columnValues: columnValues(PartnerApp.t.updateTable),
      where: where(PartnerApp.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PartnerApp.t),
      orderByList: orderByList?.call(PartnerApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PartnerApp]s in the list and returns the deleted rows.
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
  Future<List<PartnerApp>> delete(
    _is.DatabaseSession session,
    List<PartnerApp> rows, {
    _is.OrderByBuilder<PartnerAppTable>? orderBy,
    _is.OrderByListBuilder<PartnerAppTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PartnerApp>(
      rows,
      orderBy: orderBy?.call(PartnerApp.t),
      orderByList: orderByList?.call(PartnerApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PartnerApp].
  Future<PartnerApp> deleteRow(
    _is.DatabaseSession session,
    PartnerApp row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PartnerApp>(
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
  Future<List<PartnerApp>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PartnerAppTable> where,
    _is.OrderByBuilder<PartnerAppTable>? orderBy,
    _is.OrderByListBuilder<PartnerAppTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PartnerApp>(
      where: where(PartnerApp.t),
      orderBy: orderBy?.call(PartnerApp.t),
      orderByList: orderByList?.call(PartnerApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartnerAppTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PartnerApp>(
      where: where?.call(PartnerApp.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PartnerApp] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PartnerAppTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PartnerApp>(
      where: where(PartnerApp.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
