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

abstract class MerchantApp
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MerchantApp._({
    this.id,
    required this.restaurantId,
    required this.environment,
    required this.clientId,
    required this.secretCipher,
    required this.keyVersion,
    required this.credentialVersion,
    required this.status,
    this.merchantId,
    this.appId,
    required this.webhookToken,
    this.webhookId,
    required this.webhookStatus,
    required this.featuresJson,
    this.checkedAt,
    required this.savedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory MerchantApp({
    int? id,
    required int restaurantId,
    required String environment,
    required String clientId,
    required String secretCipher,
    required int keyVersion,
    required int credentialVersion,
    required String status,
    String? merchantId,
    String? appId,
    required String webhookToken,
    String? webhookId,
    required String webhookStatus,
    required String featuresJson,
    DateTime? checkedAt,
    required String savedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
  }) = _MerchantAppImpl;

  factory MerchantApp.fromJson(Map<String, dynamic> jsonSerialization) {
    return MerchantApp(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      environment: jsonSerialization['environment'] as String,
      clientId: jsonSerialization['clientId'] as String,
      secretCipher: jsonSerialization['secretCipher'] as String,
      keyVersion: jsonSerialization['keyVersion'] as int,
      credentialVersion: jsonSerialization['credentialVersion'] as int,
      status: jsonSerialization['status'] as String,
      merchantId: jsonSerialization['merchantId'] as String?,
      appId: jsonSerialization['appId'] as String?,
      webhookToken: jsonSerialization['webhookToken'] as String,
      webhookId: jsonSerialization['webhookId'] as String?,
      webhookStatus: jsonSerialization['webhookStatus'] as String,
      featuresJson: jsonSerialization['featuresJson'] as String,
      checkedAt: jsonSerialization['checkedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['checkedAt']),
      savedBy: jsonSerialization['savedBy'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = MerchantAppTable();

  static const db = MerchantAppRepository._();

  @override
  int? id;

  int restaurantId;

  String environment;

  String clientId;

  String secretCipher;

  int keyVersion;

  int credentialVersion;

  String status;

  String? merchantId;

  String? appId;

  String webhookToken;

  String? webhookId;

  String webhookStatus;

  String featuresJson;

  DateTime? checkedAt;

  String savedBy;

  DateTime createdAt;

  DateTime updatedAt;

  int version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MerchantApp]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MerchantApp copyWith({
    int? id,
    int? restaurantId,
    String? environment,
    String? clientId,
    String? secretCipher,
    int? keyVersion,
    int? credentialVersion,
    String? status,
    String? merchantId,
    String? appId,
    String? webhookToken,
    String? webhookId,
    String? webhookStatus,
    String? featuresJson,
    DateTime? checkedAt,
    String? savedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MerchantApp',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'environment': environment,
      'clientId': clientId,
      'secretCipher': secretCipher,
      'keyVersion': keyVersion,
      'credentialVersion': credentialVersion,
      'status': status,
      if (merchantId != null) 'merchantId': merchantId,
      if (appId != null) 'appId': appId,
      'webhookToken': webhookToken,
      if (webhookId != null) 'webhookId': webhookId,
      'webhookStatus': webhookStatus,
      'featuresJson': featuresJson,
      if (checkedAt != null) 'checkedAt': checkedAt?.toJson(),
      'savedBy': savedBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static MerchantAppInclude include() {
    return MerchantAppInclude._();
  }

  static MerchantAppIncludeList includeList({
    _is.WhereExpressionBuilder<MerchantAppTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MerchantAppTable>? orderBy,
    _is.OrderByListBuilder<MerchantAppTable>? orderByList,
    MerchantAppInclude? include,
  }) {
    return MerchantAppIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MerchantApp.t),
      orderByList: orderByList?.call(MerchantApp.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MerchantAppImpl extends MerchantApp {
  _MerchantAppImpl({
    int? id,
    required int restaurantId,
    required String environment,
    required String clientId,
    required String secretCipher,
    required int keyVersion,
    required int credentialVersion,
    required String status,
    String? merchantId,
    String? appId,
    required String webhookToken,
    String? webhookId,
    required String webhookStatus,
    required String featuresJson,
    DateTime? checkedAt,
    required String savedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         environment: environment,
         clientId: clientId,
         secretCipher: secretCipher,
         keyVersion: keyVersion,
         credentialVersion: credentialVersion,
         status: status,
         merchantId: merchantId,
         appId: appId,
         webhookToken: webhookToken,
         webhookId: webhookId,
         webhookStatus: webhookStatus,
         featuresJson: featuresJson,
         checkedAt: checkedAt,
         savedBy: savedBy,
         createdAt: createdAt,
         updatedAt: updatedAt,
         version: version,
       );

  /// Returns a shallow copy of this [MerchantApp]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MerchantApp copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? environment,
    String? clientId,
    String? secretCipher,
    int? keyVersion,
    int? credentialVersion,
    String? status,
    Object? merchantId = _Undefined,
    Object? appId = _Undefined,
    String? webhookToken,
    Object? webhookId = _Undefined,
    String? webhookStatus,
    String? featuresJson,
    Object? checkedAt = _Undefined,
    String? savedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return MerchantApp(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      environment: environment ?? this.environment,
      clientId: clientId ?? this.clientId,
      secretCipher: secretCipher ?? this.secretCipher,
      keyVersion: keyVersion ?? this.keyVersion,
      credentialVersion: credentialVersion ?? this.credentialVersion,
      status: status ?? this.status,
      merchantId: merchantId is String? ? merchantId : this.merchantId,
      appId: appId is String? ? appId : this.appId,
      webhookToken: webhookToken ?? this.webhookToken,
      webhookId: webhookId is String? ? webhookId : this.webhookId,
      webhookStatus: webhookStatus ?? this.webhookStatus,
      featuresJson: featuresJson ?? this.featuresJson,
      checkedAt: checkedAt is DateTime? ? checkedAt : this.checkedAt,
      savedBy: savedBy ?? this.savedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class MerchantAppUpdateTable extends _is.UpdateTable<MerchantAppTable> {
  MerchantAppUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> environment(String value) => _is.ColumnValue(
    table.environment,
    value,
  );

  _is.ColumnValue<String, String> clientId(String value) => _is.ColumnValue(
    table.clientId,
    value,
  );

  _is.ColumnValue<String, String> secretCipher(String value) => _is.ColumnValue(
    table.secretCipher,
    value,
  );

  _is.ColumnValue<int, int> keyVersion(int value) => _is.ColumnValue(
    table.keyVersion,
    value,
  );

  _is.ColumnValue<int, int> credentialVersion(int value) => _is.ColumnValue(
    table.credentialVersion,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> merchantId(String? value) => _is.ColumnValue(
    table.merchantId,
    value,
  );

  _is.ColumnValue<String, String> appId(String? value) => _is.ColumnValue(
    table.appId,
    value,
  );

  _is.ColumnValue<String, String> webhookToken(String value) => _is.ColumnValue(
    table.webhookToken,
    value,
  );

  _is.ColumnValue<String, String> webhookId(String? value) => _is.ColumnValue(
    table.webhookId,
    value,
  );

  _is.ColumnValue<String, String> webhookStatus(String value) =>
      _is.ColumnValue(
        table.webhookStatus,
        value,
      );

  _is.ColumnValue<String, String> featuresJson(String value) => _is.ColumnValue(
    table.featuresJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> checkedAt(DateTime? value) =>
      _is.ColumnValue(
        table.checkedAt,
        value,
      );

  _is.ColumnValue<String, String> savedBy(String value) => _is.ColumnValue(
    table.savedBy,
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

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class MerchantAppTable extends _is.Table<int?> {
  MerchantAppTable({super.tableRelation})
    : super(tableName: 'raysto_merchant_app') {
    updateTable = MerchantAppUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    environment = _is.ColumnString(
      'environment',
      this,
    );
    clientId = _is.ColumnString(
      'clientId',
      this,
    );
    secretCipher = _is.ColumnString(
      'secretCipher',
      this,
    );
    keyVersion = _is.ColumnInt(
      'keyVersion',
      this,
    );
    credentialVersion = _is.ColumnInt(
      'credentialVersion',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    merchantId = _is.ColumnString(
      'merchantId',
      this,
    );
    appId = _is.ColumnString(
      'appId',
      this,
    );
    webhookToken = _is.ColumnString(
      'webhookToken',
      this,
    );
    webhookId = _is.ColumnString(
      'webhookId',
      this,
    );
    webhookStatus = _is.ColumnString(
      'webhookStatus',
      this,
    );
    featuresJson = _is.ColumnString(
      'featuresJson',
      this,
    );
    checkedAt = _is.ColumnDateTime(
      'checkedAt',
      this,
    );
    savedBy = _is.ColumnString(
      'savedBy',
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
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final MerchantAppUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString environment;

  late final _is.ColumnString clientId;

  late final _is.ColumnString secretCipher;

  late final _is.ColumnInt keyVersion;

  late final _is.ColumnInt credentialVersion;

  late final _is.ColumnString status;

  late final _is.ColumnString merchantId;

  late final _is.ColumnString appId;

  late final _is.ColumnString webhookToken;

  late final _is.ColumnString webhookId;

  late final _is.ColumnString webhookStatus;

  late final _is.ColumnString featuresJson;

  late final _is.ColumnDateTime checkedAt;

  late final _is.ColumnString savedBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    environment,
    clientId,
    secretCipher,
    keyVersion,
    credentialVersion,
    status,
    merchantId,
    appId,
    webhookToken,
    webhookId,
    webhookStatus,
    featuresJson,
    checkedAt,
    savedBy,
    createdAt,
    updatedAt,
    version,
  ];
}

class MerchantAppInclude extends _is.IncludeObject {
  MerchantAppInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MerchantApp.t;
}

class MerchantAppIncludeList extends _is.IncludeList {
  MerchantAppIncludeList._({
    _is.WhereExpressionBuilder<MerchantAppTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MerchantApp.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MerchantApp.t;
}

class MerchantAppRepository {
  const MerchantAppRepository._();

  /// Returns a list of [MerchantApp]s matching the given query parameters.
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
  Future<List<MerchantApp>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MerchantAppTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MerchantAppTable>? orderBy,
    _is.OrderByListBuilder<MerchantAppTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MerchantApp>(
      where: where?.call(MerchantApp.t),
      orderBy: orderBy?.call(MerchantApp.t),
      orderByList: orderByList?.call(MerchantApp.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MerchantApp] matching the given query parameters.
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
  Future<MerchantApp?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MerchantAppTable>? where,
    int? offset,
    _is.OrderByBuilder<MerchantAppTable>? orderBy,
    _is.OrderByListBuilder<MerchantAppTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MerchantApp>(
      where: where?.call(MerchantApp.t),
      orderBy: orderBy?.call(MerchantApp.t),
      orderByList: orderByList?.call(MerchantApp.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MerchantApp] by its [id] or null if no such row exists.
  Future<MerchantApp?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MerchantApp>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MerchantApp]s in the list and returns the inserted rows.
  ///
  /// The returned [MerchantApp]s will have their `id` fields set.
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
  Future<List<MerchantApp>> insert(
    _is.DatabaseSession session,
    List<MerchantApp> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MerchantApp>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MerchantApp] and returns the inserted row.
  ///
  /// The returned [MerchantApp] will have its `id` field set.
  Future<MerchantApp> insertRow(
    _is.DatabaseSession session,
    MerchantApp row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MerchantApp>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MerchantApp]s in the list and returns the resulting rows.
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
  /// The returned [MerchantApp]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MerchantApp>> upsert(
    _is.DatabaseSession session,
    List<MerchantApp> rows, {
    required _is.ColumnSelections<MerchantAppTable> conflictColumns,
    _is.ColumnSelections<MerchantAppTable>? updateColumns,
    _is.WhereExpressionBuilder<MerchantAppTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MerchantApp>(
      rows,
      conflictColumns: conflictColumns(MerchantApp.t),
      updateColumns: updateColumns?.call(MerchantApp.t),
      updateWhere: updateWhere?.call(MerchantApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MerchantApp] and returns the resulting row.
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
  /// The returned [MerchantApp] will have its `id` field set.
  Future<MerchantApp?> upsertRow(
    _is.DatabaseSession session,
    MerchantApp row, {
    required _is.ColumnSelections<MerchantAppTable> conflictColumns,
    _is.ColumnSelections<MerchantAppTable>? updateColumns,
    _is.WhereExpressionBuilder<MerchantAppTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MerchantApp>(
      row,
      conflictColumns: conflictColumns(MerchantApp.t),
      updateColumns: updateColumns?.call(MerchantApp.t),
      updateWhere: updateWhere?.call(MerchantApp.t),
      transaction: transaction,
    );
  }

  /// Updates all [MerchantApp]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MerchantApp>> update(
    _is.DatabaseSession session,
    List<MerchantApp> rows, {
    _is.ColumnSelections<MerchantAppTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MerchantApp>(
      rows,
      columns: columns?.call(MerchantApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MerchantApp]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MerchantApp> updateRow(
    _is.DatabaseSession session,
    MerchantApp row, {
    _is.ColumnSelections<MerchantAppTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MerchantApp>(
      row,
      columns: columns?.call(MerchantApp.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MerchantApp] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MerchantApp?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MerchantAppUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MerchantApp>(
      id,
      columnValues: columnValues(MerchantApp.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MerchantApp]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MerchantApp>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MerchantAppUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MerchantAppTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MerchantAppTable>? orderBy,
    _is.OrderByListBuilder<MerchantAppTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MerchantApp>(
      columnValues: columnValues(MerchantApp.t.updateTable),
      where: where(MerchantApp.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MerchantApp.t),
      orderByList: orderByList?.call(MerchantApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MerchantApp]s in the list and returns the deleted rows.
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
  Future<List<MerchantApp>> delete(
    _is.DatabaseSession session,
    List<MerchantApp> rows, {
    _is.OrderByBuilder<MerchantAppTable>? orderBy,
    _is.OrderByListBuilder<MerchantAppTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MerchantApp>(
      rows,
      orderBy: orderBy?.call(MerchantApp.t),
      orderByList: orderByList?.call(MerchantApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MerchantApp].
  Future<MerchantApp> deleteRow(
    _is.DatabaseSession session,
    MerchantApp row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MerchantApp>(
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
  Future<List<MerchantApp>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MerchantAppTable> where,
    _is.OrderByBuilder<MerchantAppTable>? orderBy,
    _is.OrderByListBuilder<MerchantAppTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MerchantApp>(
      where: where(MerchantApp.t),
      orderBy: orderBy?.call(MerchantApp.t),
      orderByList: orderByList?.call(MerchantApp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MerchantAppTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MerchantApp>(
      where: where?.call(MerchantApp.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MerchantApp] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MerchantAppTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MerchantApp>(
      where: where(MerchantApp.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
