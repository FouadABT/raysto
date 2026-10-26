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

abstract class MediaAsset
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MediaAsset._({
    this.id,
    this.restaurantId,
    required this.userId,
    required this.purpose,
    required this.objectName,
    required this.mime,
    required this.byteLength,
    required this.sha256,
    required this.status,
    required this.public,
    required this.metadataJson,
    required this.createdAt,
  });

  factory MediaAsset({
    int? id,
    int? restaurantId,
    required String userId,
    required String purpose,
    required String objectName,
    required String mime,
    required int byteLength,
    required String sha256,
    required String status,
    required bool public,
    required String metadataJson,
    required DateTime createdAt,
  }) = _MediaAssetImpl;

  factory MediaAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaAsset(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int?,
      userId: jsonSerialization['userId'] as String,
      purpose: jsonSerialization['purpose'] as String,
      objectName: jsonSerialization['objectName'] as String,
      mime: jsonSerialization['mime'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      sha256: jsonSerialization['sha256'] as String,
      status: jsonSerialization['status'] as String,
      public: _is.BoolJsonExtension.fromJson(jsonSerialization['public']),
      metadataJson: jsonSerialization['metadataJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MediaAssetTable();

  static const db = MediaAssetRepository._();

  @override
  int? id;

  int? restaurantId;

  String userId;

  String purpose;

  String objectName;

  String mime;

  int byteLength;

  String sha256;

  String status;

  bool public;

  String metadataJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MediaAsset]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MediaAsset copyWith({
    int? id,
    int? restaurantId,
    String? userId,
    String? purpose,
    String? objectName,
    String? mime,
    int? byteLength,
    String? sha256,
    String? status,
    bool? public,
    String? metadataJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaAsset',
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurantId': restaurantId,
      'userId': userId,
      'purpose': purpose,
      'objectName': objectName,
      'mime': mime,
      'byteLength': byteLength,
      'sha256': sha256,
      'status': status,
      'public': public,
      'metadataJson': metadataJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static MediaAssetInclude include() {
    return MediaAssetInclude._();
  }

  static MediaAssetIncludeList includeList({
    _is.WhereExpressionBuilder<MediaAssetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MediaAssetTable>? orderBy,
    _is.OrderByListBuilder<MediaAssetTable>? orderByList,
    MediaAssetInclude? include,
  }) {
    return MediaAssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaAssetImpl extends MediaAsset {
  _MediaAssetImpl({
    int? id,
    int? restaurantId,
    required String userId,
    required String purpose,
    required String objectName,
    required String mime,
    required int byteLength,
    required String sha256,
    required String status,
    required bool public,
    required String metadataJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         userId: userId,
         purpose: purpose,
         objectName: objectName,
         mime: mime,
         byteLength: byteLength,
         sha256: sha256,
         status: status,
         public: public,
         metadataJson: metadataJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MediaAsset]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MediaAsset copyWith({
    Object? id = _Undefined,
    Object? restaurantId = _Undefined,
    String? userId,
    String? purpose,
    String? objectName,
    String? mime,
    int? byteLength,
    String? sha256,
    String? status,
    bool? public,
    String? metadataJson,
    DateTime? createdAt,
  }) {
    return MediaAsset(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId is int? ? restaurantId : this.restaurantId,
      userId: userId ?? this.userId,
      purpose: purpose ?? this.purpose,
      objectName: objectName ?? this.objectName,
      mime: mime ?? this.mime,
      byteLength: byteLength ?? this.byteLength,
      sha256: sha256 ?? this.sha256,
      status: status ?? this.status,
      public: public ?? this.public,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MediaAssetUpdateTable extends _is.UpdateTable<MediaAssetTable> {
  MediaAssetUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int? value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> purpose(String value) => _is.ColumnValue(
    table.purpose,
    value,
  );

  _is.ColumnValue<String, String> objectName(String value) => _is.ColumnValue(
    table.objectName,
    value,
  );

  _is.ColumnValue<String, String> mime(String value) => _is.ColumnValue(
    table.mime,
    value,
  );

  _is.ColumnValue<int, int> byteLength(int value) => _is.ColumnValue(
    table.byteLength,
    value,
  );

  _is.ColumnValue<String, String> sha256(String value) => _is.ColumnValue(
    table.sha256,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<bool, bool> public(bool value) => _is.ColumnValue(
    table.public,
    value,
  );

  _is.ColumnValue<String, String> metadataJson(String value) => _is.ColumnValue(
    table.metadataJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MediaAssetTable extends _is.Table<int?> {
  MediaAssetTable({super.tableRelation})
    : super(tableName: 'raysto_media_asset') {
    updateTable = MediaAssetUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    purpose = _is.ColumnString(
      'purpose',
      this,
    );
    objectName = _is.ColumnString(
      'objectName',
      this,
    );
    mime = _is.ColumnString(
      'mime',
      this,
    );
    byteLength = _is.ColumnInt(
      'byteLength',
      this,
    );
    sha256 = _is.ColumnString(
      'sha256',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    public = _is.ColumnBool(
      'public',
      this,
    );
    metadataJson = _is.ColumnString(
      'metadataJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MediaAssetUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString userId;

  late final _is.ColumnString purpose;

  late final _is.ColumnString objectName;

  late final _is.ColumnString mime;

  late final _is.ColumnInt byteLength;

  late final _is.ColumnString sha256;

  late final _is.ColumnString status;

  late final _is.ColumnBool public;

  late final _is.ColumnString metadataJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    userId,
    purpose,
    objectName,
    mime,
    byteLength,
    sha256,
    status,
    public,
    metadataJson,
    createdAt,
  ];
}

class MediaAssetInclude extends _is.IncludeObject {
  MediaAssetInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MediaAsset.t;
}

class MediaAssetIncludeList extends _is.IncludeList {
  MediaAssetIncludeList._({
    _is.WhereExpressionBuilder<MediaAssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MediaAsset.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MediaAsset.t;
}

class MediaAssetRepository {
  const MediaAssetRepository._();

  /// Returns a list of [MediaAsset]s matching the given query parameters.
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
  Future<List<MediaAsset>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MediaAssetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MediaAssetTable>? orderBy,
    _is.OrderByListBuilder<MediaAssetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MediaAsset>(
      where: where?.call(MediaAsset.t),
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MediaAsset] matching the given query parameters.
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
  Future<MediaAsset?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MediaAssetTable>? where,
    int? offset,
    _is.OrderByBuilder<MediaAssetTable>? orderBy,
    _is.OrderByListBuilder<MediaAssetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MediaAsset>(
      where: where?.call(MediaAsset.t),
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MediaAsset] by its [id] or null if no such row exists.
  Future<MediaAsset?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MediaAsset>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MediaAsset]s in the list and returns the inserted rows.
  ///
  /// The returned [MediaAsset]s will have their `id` fields set.
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
  Future<List<MediaAsset>> insert(
    _is.DatabaseSession session,
    List<MediaAsset> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MediaAsset>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MediaAsset] and returns the inserted row.
  ///
  /// The returned [MediaAsset] will have its `id` field set.
  Future<MediaAsset> insertRow(
    _is.DatabaseSession session,
    MediaAsset row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MediaAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MediaAsset]s in the list and returns the resulting rows.
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
  /// The returned [MediaAsset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MediaAsset>> upsert(
    _is.DatabaseSession session,
    List<MediaAsset> rows, {
    required _is.ColumnSelections<MediaAssetTable> conflictColumns,
    _is.ColumnSelections<MediaAssetTable>? updateColumns,
    _is.WhereExpressionBuilder<MediaAssetTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MediaAsset>(
      rows,
      conflictColumns: conflictColumns(MediaAsset.t),
      updateColumns: updateColumns?.call(MediaAsset.t),
      updateWhere: updateWhere?.call(MediaAsset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MediaAsset] and returns the resulting row.
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
  /// The returned [MediaAsset] will have its `id` field set.
  Future<MediaAsset?> upsertRow(
    _is.DatabaseSession session,
    MediaAsset row, {
    required _is.ColumnSelections<MediaAssetTable> conflictColumns,
    _is.ColumnSelections<MediaAssetTable>? updateColumns,
    _is.WhereExpressionBuilder<MediaAssetTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MediaAsset>(
      row,
      conflictColumns: conflictColumns(MediaAsset.t),
      updateColumns: updateColumns?.call(MediaAsset.t),
      updateWhere: updateWhere?.call(MediaAsset.t),
      transaction: transaction,
    );
  }

  /// Updates all [MediaAsset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MediaAsset>> update(
    _is.DatabaseSession session,
    List<MediaAsset> rows, {
    _is.ColumnSelections<MediaAssetTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MediaAsset>(
      rows,
      columns: columns?.call(MediaAsset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MediaAsset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MediaAsset> updateRow(
    _is.DatabaseSession session,
    MediaAsset row, {
    _is.ColumnSelections<MediaAssetTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MediaAsset>(
      row,
      columns: columns?.call(MediaAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MediaAsset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MediaAsset?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MediaAssetUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MediaAsset>(
      id,
      columnValues: columnValues(MediaAsset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MediaAsset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MediaAsset>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MediaAssetUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MediaAssetTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MediaAssetTable>? orderBy,
    _is.OrderByListBuilder<MediaAssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MediaAsset>(
      columnValues: columnValues(MediaAsset.t.updateTable),
      where: where(MediaAsset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MediaAsset]s in the list and returns the deleted rows.
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
  Future<List<MediaAsset>> delete(
    _is.DatabaseSession session,
    List<MediaAsset> rows, {
    _is.OrderByBuilder<MediaAssetTable>? orderBy,
    _is.OrderByListBuilder<MediaAssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MediaAsset>(
      rows,
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MediaAsset].
  Future<MediaAsset> deleteRow(
    _is.DatabaseSession session,
    MediaAsset row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MediaAsset>(
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
  Future<List<MediaAsset>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MediaAssetTable> where,
    _is.OrderByBuilder<MediaAssetTable>? orderBy,
    _is.OrderByListBuilder<MediaAssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MediaAsset>(
      where: where(MediaAsset.t),
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MediaAssetTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MediaAsset>(
      where: where?.call(MediaAsset.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MediaAsset] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MediaAssetTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MediaAsset>(
      where: where(MediaAsset.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
