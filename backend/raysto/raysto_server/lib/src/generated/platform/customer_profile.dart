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

abstract class CustomerProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CustomerProfile._({
    this.id,
    required this.restaurantId,
    this.userId,
    required this.emailHash,
    required this.displayName,
    required this.visits,
    required this.spentMinor,
    required this.lastSeenAt,
    required this.tagsJson,
    this.couponCode,
    required this.updatedAt,
  });

  factory CustomerProfile({
    int? id,
    required int restaurantId,
    String? userId,
    required String emailHash,
    required String displayName,
    required int visits,
    required int spentMinor,
    required DateTime lastSeenAt,
    required String tagsJson,
    String? couponCode,
    required DateTime updatedAt,
  }) = _CustomerProfileImpl;

  factory CustomerProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomerProfile(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      userId: jsonSerialization['userId'] as String?,
      emailHash: jsonSerialization['emailHash'] as String,
      displayName: jsonSerialization['displayName'] as String,
      visits: jsonSerialization['visits'] as int,
      spentMinor: jsonSerialization['spentMinor'] as int,
      lastSeenAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSeenAt'],
      ),
      tagsJson: jsonSerialization['tagsJson'] as String,
      couponCode: jsonSerialization['couponCode'] as String?,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CustomerProfileTable();

  static const db = CustomerProfileRepository._();

  @override
  int? id;

  int restaurantId;

  String? userId;

  String emailHash;

  String displayName;

  int visits;

  int spentMinor;

  DateTime lastSeenAt;

  String tagsJson;

  String? couponCode;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CustomerProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustomerProfile copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? emailHash,
    String? displayName,
    int? visits,
    int? spentMinor,
    DateTime? lastSeenAt,
    String? tagsJson,
    String? couponCode,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomerProfile',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      if (userId != null) 'userId': userId,
      'emailHash': emailHash,
      'displayName': displayName,
      'visits': visits,
      'spentMinor': spentMinor,
      'lastSeenAt': lastSeenAt.toJson(),
      'tagsJson': tagsJson,
      if (couponCode != null) 'couponCode': couponCode,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CustomerProfileInclude include() {
    return CustomerProfileInclude._();
  }

  static CustomerProfileIncludeList includeList({
    _is.WhereExpressionBuilder<CustomerProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerProfileTable>? orderBy,
    _is.OrderByListBuilder<CustomerProfileTable>? orderByList,
    CustomerProfileInclude? include,
  }) {
    return CustomerProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerProfile.t),
      orderByList: orderByList?.call(CustomerProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomerProfileImpl extends CustomerProfile {
  _CustomerProfileImpl({
    int? id,
    required int restaurantId,
    String? userId,
    required String emailHash,
    required String displayName,
    required int visits,
    required int spentMinor,
    required DateTime lastSeenAt,
    required String tagsJson,
    String? couponCode,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         emailHash: emailHash,
         displayName: displayName,
         visits: visits,
         spentMinor: spentMinor,
         lastSeenAt: lastSeenAt,
         tagsJson: tagsJson,
         couponCode: couponCode,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CustomerProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustomerProfile copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    Object? userId = _Undefined,
    String? emailHash,
    String? displayName,
    int? visits,
    int? spentMinor,
    DateTime? lastSeenAt,
    String? tagsJson,
    Object? couponCode = _Undefined,
    DateTime? updatedAt,
  }) {
    return CustomerProfile(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId is String? ? userId : this.userId,
      emailHash: emailHash ?? this.emailHash,
      displayName: displayName ?? this.displayName,
      visits: visits ?? this.visits,
      spentMinor: spentMinor ?? this.spentMinor,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      tagsJson: tagsJson ?? this.tagsJson,
      couponCode: couponCode is String? ? couponCode : this.couponCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CustomerProfileUpdateTable extends _is.UpdateTable<CustomerProfileTable> {
  CustomerProfileUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> emailHash(String value) => _is.ColumnValue(
    table.emailHash,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<int, int> visits(int value) => _is.ColumnValue(
    table.visits,
    value,
  );

  _is.ColumnValue<int, int> spentMinor(int value) => _is.ColumnValue(
    table.spentMinor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastSeenAt(DateTime value) =>
      _is.ColumnValue(
        table.lastSeenAt,
        value,
      );

  _is.ColumnValue<String, String> tagsJson(String value) => _is.ColumnValue(
    table.tagsJson,
    value,
  );

  _is.ColumnValue<String, String> couponCode(String? value) => _is.ColumnValue(
    table.couponCode,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CustomerProfileTable extends _is.Table<int?> {
  CustomerProfileTable({super.tableRelation})
    : super(tableName: 'raysto_customer_profile') {
    updateTable = CustomerProfileUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    emailHash = _is.ColumnString(
      'emailHash',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    visits = _is.ColumnInt(
      'visits',
      this,
    );
    spentMinor = _is.ColumnInt(
      'spentMinor',
      this,
    );
    lastSeenAt = _is.ColumnDateTime(
      'lastSeenAt',
      this,
    );
    tagsJson = _is.ColumnString(
      'tagsJson',
      this,
    );
    couponCode = _is.ColumnString(
      'couponCode',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CustomerProfileUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString emailHash;

  late final _is.ColumnString displayName;

  late final _is.ColumnInt visits;

  late final _is.ColumnInt spentMinor;

  late final _is.ColumnDateTime lastSeenAt;

  late final _is.ColumnString tagsJson;

  late final _is.ColumnString couponCode;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    emailHash,
    displayName,
    visits,
    spentMinor,
    lastSeenAt,
    tagsJson,
    couponCode,
    updatedAt,
  ];
}

class CustomerProfileInclude extends _is.IncludeObject {
  CustomerProfileInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CustomerProfile.t;
}

class CustomerProfileIncludeList extends _is.IncludeList {
  CustomerProfileIncludeList._({
    _is.WhereExpressionBuilder<CustomerProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomerProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CustomerProfile.t;
}

class CustomerProfileRepository {
  const CustomerProfileRepository._();

  /// Returns a list of [CustomerProfile]s matching the given query parameters.
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
  Future<List<CustomerProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerProfileTable>? orderBy,
    _is.OrderByListBuilder<CustomerProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomerProfile>(
      where: where?.call(CustomerProfile.t),
      orderBy: orderBy?.call(CustomerProfile.t),
      orderByList: orderByList?.call(CustomerProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustomerProfile] matching the given query parameters.
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
  Future<CustomerProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<CustomerProfileTable>? orderBy,
    _is.OrderByListBuilder<CustomerProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomerProfile>(
      where: where?.call(CustomerProfile.t),
      orderBy: orderBy?.call(CustomerProfile.t),
      orderByList: orderByList?.call(CustomerProfile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomerProfile] by its [id] or null if no such row exists.
  Future<CustomerProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomerProfile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomerProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomerProfile]s will have their `id` fields set.
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
  Future<List<CustomerProfile>> insert(
    _is.DatabaseSession session,
    List<CustomerProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomerProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomerProfile] and returns the inserted row.
  ///
  /// The returned [CustomerProfile] will have its `id` field set.
  Future<CustomerProfile> insertRow(
    _is.DatabaseSession session,
    CustomerProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomerProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomerProfile]s in the list and returns the resulting rows.
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
  /// The returned [CustomerProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerProfile>> upsert(
    _is.DatabaseSession session,
    List<CustomerProfile> rows, {
    required _is.ColumnSelections<CustomerProfileTable> conflictColumns,
    _is.ColumnSelections<CustomerProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomerProfile>(
      rows,
      conflictColumns: conflictColumns(CustomerProfile.t),
      updateColumns: updateColumns?.call(CustomerProfile.t),
      updateWhere: updateWhere?.call(CustomerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomerProfile] and returns the resulting row.
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
  /// The returned [CustomerProfile] will have its `id` field set.
  Future<CustomerProfile?> upsertRow(
    _is.DatabaseSession session,
    CustomerProfile row, {
    required _is.ColumnSelections<CustomerProfileTable> conflictColumns,
    _is.ColumnSelections<CustomerProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomerProfile>(
      row,
      conflictColumns: conflictColumns(CustomerProfile.t),
      updateColumns: updateColumns?.call(CustomerProfile.t),
      updateWhere: updateWhere?.call(CustomerProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerProfile>> update(
    _is.DatabaseSession session,
    List<CustomerProfile> rows, {
    _is.ColumnSelections<CustomerProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomerProfile>(
      rows,
      columns: columns?.call(CustomerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomerProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomerProfile> updateRow(
    _is.DatabaseSession session,
    CustomerProfile row, {
    _is.ColumnSelections<CustomerProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomerProfile>(
      row,
      columns: columns?.call(CustomerProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomerProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomerProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CustomerProfileUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomerProfile>(
      id,
      columnValues: columnValues(CustomerProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustomerProfileUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CustomerProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerProfileTable>? orderBy,
    _is.OrderByListBuilder<CustomerProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomerProfile>(
      columnValues: columnValues(CustomerProfile.t.updateTable),
      where: where(CustomerProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerProfile.t),
      orderByList: orderByList?.call(CustomerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomerProfile]s in the list and returns the deleted rows.
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
  Future<List<CustomerProfile>> delete(
    _is.DatabaseSession session,
    List<CustomerProfile> rows, {
    _is.OrderByBuilder<CustomerProfileTable>? orderBy,
    _is.OrderByListBuilder<CustomerProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomerProfile>(
      rows,
      orderBy: orderBy?.call(CustomerProfile.t),
      orderByList: orderByList?.call(CustomerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomerProfile].
  Future<CustomerProfile> deleteRow(
    _is.DatabaseSession session,
    CustomerProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomerProfile>(
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
  Future<List<CustomerProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerProfileTable> where,
    _is.OrderByBuilder<CustomerProfileTable>? orderBy,
    _is.OrderByListBuilder<CustomerProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomerProfile>(
      where: where(CustomerProfile.t),
      orderBy: orderBy?.call(CustomerProfile.t),
      orderByList: orderByList?.call(CustomerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustomerProfile>(
      where: where?.call(CustomerProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomerProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomerProfile>(
      where: where(CustomerProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
