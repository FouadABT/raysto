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

abstract class Bill implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Bill._({
    this.id,
    required this.restaurantId,
    required this.vendor,
    required this.category,
    this.reference,
    required this.amountMinor,
    required this.vatMinor,
    required this.currency,
    this.issuedAt,
    this.dueAt,
    this.periodFrom,
    this.periodTo,
    required this.state,
    required this.payVia,
    this.payeeEmail,
    this.recurring,
    this.recurringOfId,
    this.sourceMediaId,
    this.proofMediaId,
    this.contentSha,
    this.supplierId,
    this.supplierOrderId,
    this.payoutBatchId,
    required this.readJson,
    this.duplicateOfId,
    this.taskId,
    this.paidAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill({
    int? id,
    required int restaurantId,
    required String vendor,
    required String category,
    String? reference,
    required int amountMinor,
    required int vatMinor,
    required String currency,
    DateTime? issuedAt,
    DateTime? dueAt,
    DateTime? periodFrom,
    DateTime? periodTo,
    required String state,
    required String payVia,
    String? payeeEmail,
    String? recurring,
    int? recurringOfId,
    int? sourceMediaId,
    int? proofMediaId,
    String? contentSha,
    int? supplierId,
    int? supplierOrderId,
    int? payoutBatchId,
    required String readJson,
    int? duplicateOfId,
    int? taskId,
    DateTime? paidAt,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BillImpl;

  factory Bill.fromJson(Map<String, dynamic> jsonSerialization) {
    return Bill(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      vendor: jsonSerialization['vendor'] as String,
      category: jsonSerialization['category'] as String,
      reference: jsonSerialization['reference'] as String?,
      amountMinor: jsonSerialization['amountMinor'] as int,
      vatMinor: jsonSerialization['vatMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      issuedAt: jsonSerialization['issuedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['issuedAt']),
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      periodFrom: jsonSerialization['periodFrom'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['periodFrom']),
      periodTo: jsonSerialization['periodTo'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['periodTo']),
      state: jsonSerialization['state'] as String,
      payVia: jsonSerialization['payVia'] as String,
      payeeEmail: jsonSerialization['payeeEmail'] as String?,
      recurring: jsonSerialization['recurring'] as String?,
      recurringOfId: jsonSerialization['recurringOfId'] as int?,
      sourceMediaId: jsonSerialization['sourceMediaId'] as int?,
      proofMediaId: jsonSerialization['proofMediaId'] as int?,
      contentSha: jsonSerialization['contentSha'] as String?,
      supplierId: jsonSerialization['supplierId'] as int?,
      supplierOrderId: jsonSerialization['supplierOrderId'] as int?,
      payoutBatchId: jsonSerialization['payoutBatchId'] as int?,
      readJson: jsonSerialization['readJson'] as String,
      duplicateOfId: jsonSerialization['duplicateOfId'] as int?,
      taskId: jsonSerialization['taskId'] as int?,
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

  static final t = BillTable();

  static const db = BillRepository._();

  @override
  int? id;

  int restaurantId;

  String vendor;

  String category;

  String? reference;

  int amountMinor;

  int vatMinor;

  String currency;

  DateTime? issuedAt;

  DateTime? dueAt;

  DateTime? periodFrom;

  DateTime? periodTo;

  String state;

  String payVia;

  String? payeeEmail;

  String? recurring;

  int? recurringOfId;

  int? sourceMediaId;

  int? proofMediaId;

  String? contentSha;

  int? supplierId;

  int? supplierOrderId;

  int? payoutBatchId;

  String readJson;

  int? duplicateOfId;

  int? taskId;

  DateTime? paidAt;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Bill]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Bill copyWith({
    int? id,
    int? restaurantId,
    String? vendor,
    String? category,
    String? reference,
    int? amountMinor,
    int? vatMinor,
    String? currency,
    DateTime? issuedAt,
    DateTime? dueAt,
    DateTime? periodFrom,
    DateTime? periodTo,
    String? state,
    String? payVia,
    String? payeeEmail,
    String? recurring,
    int? recurringOfId,
    int? sourceMediaId,
    int? proofMediaId,
    String? contentSha,
    int? supplierId,
    int? supplierOrderId,
    int? payoutBatchId,
    String? readJson,
    int? duplicateOfId,
    int? taskId,
    DateTime? paidAt,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Bill',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'vendor': vendor,
      'category': category,
      if (reference != null) 'reference': reference,
      'amountMinor': amountMinor,
      'vatMinor': vatMinor,
      'currency': currency,
      if (issuedAt != null) 'issuedAt': issuedAt?.toJson(),
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (periodFrom != null) 'periodFrom': periodFrom?.toJson(),
      if (periodTo != null) 'periodTo': periodTo?.toJson(),
      'state': state,
      'payVia': payVia,
      if (payeeEmail != null) 'payeeEmail': payeeEmail,
      if (recurring != null) 'recurring': recurring,
      if (recurringOfId != null) 'recurringOfId': recurringOfId,
      if (sourceMediaId != null) 'sourceMediaId': sourceMediaId,
      if (proofMediaId != null) 'proofMediaId': proofMediaId,
      if (contentSha != null) 'contentSha': contentSha,
      if (supplierId != null) 'supplierId': supplierId,
      if (supplierOrderId != null) 'supplierOrderId': supplierOrderId,
      if (payoutBatchId != null) 'payoutBatchId': payoutBatchId,
      'readJson': readJson,
      if (duplicateOfId != null) 'duplicateOfId': duplicateOfId,
      if (taskId != null) 'taskId': taskId,
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

  static BillInclude include() {
    return BillInclude._();
  }

  static BillIncludeList includeList({
    _is.WhereExpressionBuilder<BillTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillTable>? orderBy,
    _is.OrderByListBuilder<BillTable>? orderByList,
    BillInclude? include,
  }) {
    return BillIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillImpl extends Bill {
  _BillImpl({
    int? id,
    required int restaurantId,
    required String vendor,
    required String category,
    String? reference,
    required int amountMinor,
    required int vatMinor,
    required String currency,
    DateTime? issuedAt,
    DateTime? dueAt,
    DateTime? periodFrom,
    DateTime? periodTo,
    required String state,
    required String payVia,
    String? payeeEmail,
    String? recurring,
    int? recurringOfId,
    int? sourceMediaId,
    int? proofMediaId,
    String? contentSha,
    int? supplierId,
    int? supplierOrderId,
    int? payoutBatchId,
    required String readJson,
    int? duplicateOfId,
    int? taskId,
    DateTime? paidAt,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         vendor: vendor,
         category: category,
         reference: reference,
         amountMinor: amountMinor,
         vatMinor: vatMinor,
         currency: currency,
         issuedAt: issuedAt,
         dueAt: dueAt,
         periodFrom: periodFrom,
         periodTo: periodTo,
         state: state,
         payVia: payVia,
         payeeEmail: payeeEmail,
         recurring: recurring,
         recurringOfId: recurringOfId,
         sourceMediaId: sourceMediaId,
         proofMediaId: proofMediaId,
         contentSha: contentSha,
         supplierId: supplierId,
         supplierOrderId: supplierOrderId,
         payoutBatchId: payoutBatchId,
         readJson: readJson,
         duplicateOfId: duplicateOfId,
         taskId: taskId,
         paidAt: paidAt,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Bill]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Bill copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? vendor,
    String? category,
    Object? reference = _Undefined,
    int? amountMinor,
    int? vatMinor,
    String? currency,
    Object? issuedAt = _Undefined,
    Object? dueAt = _Undefined,
    Object? periodFrom = _Undefined,
    Object? periodTo = _Undefined,
    String? state,
    String? payVia,
    Object? payeeEmail = _Undefined,
    Object? recurring = _Undefined,
    Object? recurringOfId = _Undefined,
    Object? sourceMediaId = _Undefined,
    Object? proofMediaId = _Undefined,
    Object? contentSha = _Undefined,
    Object? supplierId = _Undefined,
    Object? supplierOrderId = _Undefined,
    Object? payoutBatchId = _Undefined,
    String? readJson,
    Object? duplicateOfId = _Undefined,
    Object? taskId = _Undefined,
    Object? paidAt = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      vendor: vendor ?? this.vendor,
      category: category ?? this.category,
      reference: reference is String? ? reference : this.reference,
      amountMinor: amountMinor ?? this.amountMinor,
      vatMinor: vatMinor ?? this.vatMinor,
      currency: currency ?? this.currency,
      issuedAt: issuedAt is DateTime? ? issuedAt : this.issuedAt,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      periodFrom: periodFrom is DateTime? ? periodFrom : this.periodFrom,
      periodTo: periodTo is DateTime? ? periodTo : this.periodTo,
      state: state ?? this.state,
      payVia: payVia ?? this.payVia,
      payeeEmail: payeeEmail is String? ? payeeEmail : this.payeeEmail,
      recurring: recurring is String? ? recurring : this.recurring,
      recurringOfId: recurringOfId is int? ? recurringOfId : this.recurringOfId,
      sourceMediaId: sourceMediaId is int? ? sourceMediaId : this.sourceMediaId,
      proofMediaId: proofMediaId is int? ? proofMediaId : this.proofMediaId,
      contentSha: contentSha is String? ? contentSha : this.contentSha,
      supplierId: supplierId is int? ? supplierId : this.supplierId,
      supplierOrderId: supplierOrderId is int?
          ? supplierOrderId
          : this.supplierOrderId,
      payoutBatchId: payoutBatchId is int? ? payoutBatchId : this.payoutBatchId,
      readJson: readJson ?? this.readJson,
      duplicateOfId: duplicateOfId is int? ? duplicateOfId : this.duplicateOfId,
      taskId: taskId is int? ? taskId : this.taskId,
      paidAt: paidAt is DateTime? ? paidAt : this.paidAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BillUpdateTable extends _is.UpdateTable<BillTable> {
  BillUpdateTable(super.table);

  _is.ColumnValue<int, int> restaurantId(int value) => _is.ColumnValue(
    table.restaurantId,
    value,
  );

  _is.ColumnValue<String, String> vendor(String value) => _is.ColumnValue(
    table.vendor,
    value,
  );

  _is.ColumnValue<String, String> category(String value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<String, String> reference(String? value) => _is.ColumnValue(
    table.reference,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> vatMinor(int value) => _is.ColumnValue(
    table.vatMinor,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> issuedAt(DateTime? value) =>
      _is.ColumnValue(
        table.issuedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> dueAt(DateTime? value) => _is.ColumnValue(
    table.dueAt,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> periodFrom(DateTime? value) =>
      _is.ColumnValue(
        table.periodFrom,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> periodTo(DateTime? value) =>
      _is.ColumnValue(
        table.periodTo,
        value,
      );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> payVia(String value) => _is.ColumnValue(
    table.payVia,
    value,
  );

  _is.ColumnValue<String, String> payeeEmail(String? value) => _is.ColumnValue(
    table.payeeEmail,
    value,
  );

  _is.ColumnValue<String, String> recurring(String? value) => _is.ColumnValue(
    table.recurring,
    value,
  );

  _is.ColumnValue<int, int> recurringOfId(int? value) => _is.ColumnValue(
    table.recurringOfId,
    value,
  );

  _is.ColumnValue<int, int> sourceMediaId(int? value) => _is.ColumnValue(
    table.sourceMediaId,
    value,
  );

  _is.ColumnValue<int, int> proofMediaId(int? value) => _is.ColumnValue(
    table.proofMediaId,
    value,
  );

  _is.ColumnValue<String, String> contentSha(String? value) => _is.ColumnValue(
    table.contentSha,
    value,
  );

  _is.ColumnValue<int, int> supplierId(int? value) => _is.ColumnValue(
    table.supplierId,
    value,
  );

  _is.ColumnValue<int, int> supplierOrderId(int? value) => _is.ColumnValue(
    table.supplierOrderId,
    value,
  );

  _is.ColumnValue<int, int> payoutBatchId(int? value) => _is.ColumnValue(
    table.payoutBatchId,
    value,
  );

  _is.ColumnValue<String, String> readJson(String value) => _is.ColumnValue(
    table.readJson,
    value,
  );

  _is.ColumnValue<int, int> duplicateOfId(int? value) => _is.ColumnValue(
    table.duplicateOfId,
    value,
  );

  _is.ColumnValue<int, int> taskId(int? value) => _is.ColumnValue(
    table.taskId,
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

class BillTable extends _is.Table<int?> {
  BillTable({super.tableRelation}) : super(tableName: 'raysto_bill') {
    updateTable = BillUpdateTable(this);
    restaurantId = _is.ColumnInt(
      'restaurantId',
      this,
    );
    vendor = _is.ColumnString(
      'vendor',
      this,
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    reference = _is.ColumnString(
      'reference',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    vatMinor = _is.ColumnInt(
      'vatMinor',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    issuedAt = _is.ColumnDateTime(
      'issuedAt',
      this,
    );
    dueAt = _is.ColumnDateTime(
      'dueAt',
      this,
    );
    periodFrom = _is.ColumnDateTime(
      'periodFrom',
      this,
    );
    periodTo = _is.ColumnDateTime(
      'periodTo',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    payVia = _is.ColumnString(
      'payVia',
      this,
    );
    payeeEmail = _is.ColumnString(
      'payeeEmail',
      this,
    );
    recurring = _is.ColumnString(
      'recurring',
      this,
    );
    recurringOfId = _is.ColumnInt(
      'recurringOfId',
      this,
    );
    sourceMediaId = _is.ColumnInt(
      'sourceMediaId',
      this,
    );
    proofMediaId = _is.ColumnInt(
      'proofMediaId',
      this,
    );
    contentSha = _is.ColumnString(
      'contentSha',
      this,
    );
    supplierId = _is.ColumnInt(
      'supplierId',
      this,
    );
    supplierOrderId = _is.ColumnInt(
      'supplierOrderId',
      this,
    );
    payoutBatchId = _is.ColumnInt(
      'payoutBatchId',
      this,
    );
    readJson = _is.ColumnString(
      'readJson',
      this,
    );
    duplicateOfId = _is.ColumnInt(
      'duplicateOfId',
      this,
    );
    taskId = _is.ColumnInt(
      'taskId',
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

  late final BillUpdateTable updateTable;

  late final _is.ColumnInt restaurantId;

  late final _is.ColumnString vendor;

  late final _is.ColumnString category;

  late final _is.ColumnString reference;

  late final _is.ColumnInt amountMinor;

  late final _is.ColumnInt vatMinor;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime issuedAt;

  late final _is.ColumnDateTime dueAt;

  late final _is.ColumnDateTime periodFrom;

  late final _is.ColumnDateTime periodTo;

  late final _is.ColumnString state;

  late final _is.ColumnString payVia;

  late final _is.ColumnString payeeEmail;

  late final _is.ColumnString recurring;

  late final _is.ColumnInt recurringOfId;

  late final _is.ColumnInt sourceMediaId;

  late final _is.ColumnInt proofMediaId;

  late final _is.ColumnString contentSha;

  late final _is.ColumnInt supplierId;

  late final _is.ColumnInt supplierOrderId;

  late final _is.ColumnInt payoutBatchId;

  late final _is.ColumnString readJson;

  late final _is.ColumnInt duplicateOfId;

  late final _is.ColumnInt taskId;

  late final _is.ColumnDateTime paidAt;

  late final _is.ColumnInt version;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    restaurantId,
    vendor,
    category,
    reference,
    amountMinor,
    vatMinor,
    currency,
    issuedAt,
    dueAt,
    periodFrom,
    periodTo,
    state,
    payVia,
    payeeEmail,
    recurring,
    recurringOfId,
    sourceMediaId,
    proofMediaId,
    contentSha,
    supplierId,
    supplierOrderId,
    payoutBatchId,
    readJson,
    duplicateOfId,
    taskId,
    paidAt,
    version,
    createdAt,
    updatedAt,
  ];
}

class BillInclude extends _is.IncludeObject {
  BillInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Bill.t;
}

class BillIncludeList extends _is.IncludeList {
  BillIncludeList._({
    _is.WhereExpressionBuilder<BillTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Bill.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Bill.t;
}

class BillRepository {
  const BillRepository._();

  /// Returns a list of [Bill]s matching the given query parameters.
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
  Future<List<Bill>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillTable>? orderBy,
    _is.OrderByListBuilder<BillTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Bill>(
      where: where?.call(Bill.t),
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Bill] matching the given query parameters.
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
  Future<Bill?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillTable>? where,
    int? offset,
    _is.OrderByBuilder<BillTable>? orderBy,
    _is.OrderByListBuilder<BillTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Bill>(
      where: where?.call(Bill.t),
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Bill] by its [id] or null if no such row exists.
  Future<Bill?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Bill>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Bill]s in the list and returns the inserted rows.
  ///
  /// The returned [Bill]s will have their `id` fields set.
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
  Future<List<Bill>> insert(
    _is.DatabaseSession session,
    List<Bill> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Bill>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Bill] and returns the inserted row.
  ///
  /// The returned [Bill] will have its `id` field set.
  Future<Bill> insertRow(
    _is.DatabaseSession session,
    Bill row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Bill>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Bill]s in the list and returns the resulting rows.
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
  /// The returned [Bill]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Bill>> upsert(
    _is.DatabaseSession session,
    List<Bill> rows, {
    required _is.ColumnSelections<BillTable> conflictColumns,
    _is.ColumnSelections<BillTable>? updateColumns,
    _is.WhereExpressionBuilder<BillTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Bill>(
      rows,
      conflictColumns: conflictColumns(Bill.t),
      updateColumns: updateColumns?.call(Bill.t),
      updateWhere: updateWhere?.call(Bill.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Bill] and returns the resulting row.
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
  /// The returned [Bill] will have its `id` field set.
  Future<Bill?> upsertRow(
    _is.DatabaseSession session,
    Bill row, {
    required _is.ColumnSelections<BillTable> conflictColumns,
    _is.ColumnSelections<BillTable>? updateColumns,
    _is.WhereExpressionBuilder<BillTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Bill>(
      row,
      conflictColumns: conflictColumns(Bill.t),
      updateColumns: updateColumns?.call(Bill.t),
      updateWhere: updateWhere?.call(Bill.t),
      transaction: transaction,
    );
  }

  /// Updates all [Bill]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Bill>> update(
    _is.DatabaseSession session,
    List<Bill> rows, {
    _is.ColumnSelections<BillTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Bill>(
      rows,
      columns: columns?.call(Bill.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Bill]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Bill> updateRow(
    _is.DatabaseSession session,
    Bill row, {
    _is.ColumnSelections<BillTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Bill>(
      row,
      columns: columns?.call(Bill.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Bill] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Bill?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BillUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Bill>(
      id,
      columnValues: columnValues(Bill.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Bill]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Bill>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BillUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BillTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillTable>? orderBy,
    _is.OrderByListBuilder<BillTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Bill>(
      columnValues: columnValues(Bill.t.updateTable),
      where: where(Bill.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Bill]s in the list and returns the deleted rows.
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
  Future<List<Bill>> delete(
    _is.DatabaseSession session,
    List<Bill> rows, {
    _is.OrderByBuilder<BillTable>? orderBy,
    _is.OrderByListBuilder<BillTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Bill>(
      rows,
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Bill].
  Future<Bill> deleteRow(
    _is.DatabaseSession session,
    Bill row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Bill>(
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
  Future<List<Bill>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillTable> where,
    _is.OrderByBuilder<BillTable>? orderBy,
    _is.OrderByListBuilder<BillTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Bill>(
      where: where(Bill.t),
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Bill>(
      where: where?.call(Bill.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Bill] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Bill>(
      where: where(Bill.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
