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
import 'package:raysto_client/src/protocol/protocol.dart' as _iksyuhhm;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'order_line.dart' as _i7utqy3k;

abstract class PurchaseOrder
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PurchaseOrder._({
    this.id,
    required this.restaurantId,
    required this.customerId,
    required this.requestKey,
    required this.requestHash,
    required this.fulfillment,
    this.address,
    required this.lines,
    required this.currency,
    required this.subtotalMinor,
    required this.deliveryFeeMinor,
    required this.totalMinor,
    required this.status,
    required this.paymentStatus,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrder({
    int? id,
    required int restaurantId,
    required String customerId,
    required String requestKey,
    required String requestHash,
    required String fulfillment,
    String? address,
    required List<_i7utqy3k.OrderLine> lines,
    required String currency,
    required int subtotalMinor,
    required int deliveryFeeMinor,
    required int totalMinor,
    required String status,
    required String paymentStatus,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseOrderImpl;

  factory PurchaseOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseOrder(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      customerId: jsonSerialization['customerId'] as String,
      requestKey: jsonSerialization['requestKey'] as String,
      requestHash: jsonSerialization['requestHash'] as String,
      fulfillment: jsonSerialization['fulfillment'] as String,
      address: jsonSerialization['address'] as String?,
      lines: _iksyuhhm.Protocol().deserialize<List<_i7utqy3k.OrderLine>>(
        jsonSerialization['lines'],
      ),
      currency: jsonSerialization['currency'] as String,
      subtotalMinor: jsonSerialization['subtotalMinor'] as int,
      deliveryFeeMinor: jsonSerialization['deliveryFeeMinor'] as int,
      totalMinor: jsonSerialization['totalMinor'] as int,
      status: jsonSerialization['status'] as String,
      paymentStatus: jsonSerialization['paymentStatus'] as String,
      version: jsonSerialization['version'] as int,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int restaurantId;

  String customerId;

  String requestKey;

  String requestHash;

  String fulfillment;

  String? address;

  List<_i7utqy3k.OrderLine> lines;

  String currency;

  int subtotalMinor;

  int deliveryFeeMinor;

  int totalMinor;

  String status;

  String paymentStatus;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [PurchaseOrder]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PurchaseOrder copyWith({
    int? id,
    int? restaurantId,
    String? customerId,
    String? requestKey,
    String? requestHash,
    String? fulfillment,
    String? address,
    List<_i7utqy3k.OrderLine>? lines,
    String? currency,
    int? subtotalMinor,
    int? deliveryFeeMinor,
    int? totalMinor,
    String? status,
    String? paymentStatus,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseOrder',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'customerId': customerId,
      'requestKey': requestKey,
      'requestHash': requestHash,
      'fulfillment': fulfillment,
      if (address != null) 'address': address,
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
      'currency': currency,
      'subtotalMinor': subtotalMinor,
      'deliveryFeeMinor': deliveryFeeMinor,
      'totalMinor': totalMinor,
      'status': status,
      'paymentStatus': paymentStatus,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseOrder',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'customerId': customerId,
      'requestKey': requestKey,
      'requestHash': requestHash,
      'fulfillment': fulfillment,
      if (address != null) 'address': address,
      'lines': lines.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'currency': currency,
      'subtotalMinor': subtotalMinor,
      'deliveryFeeMinor': deliveryFeeMinor,
      'totalMinor': totalMinor,
      'status': status,
      'paymentStatus': paymentStatus,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseOrderImpl extends PurchaseOrder {
  _PurchaseOrderImpl({
    int? id,
    required int restaurantId,
    required String customerId,
    required String requestKey,
    required String requestHash,
    required String fulfillment,
    String? address,
    required List<_i7utqy3k.OrderLine> lines,
    required String currency,
    required int subtotalMinor,
    required int deliveryFeeMinor,
    required int totalMinor,
    required String status,
    required String paymentStatus,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         customerId: customerId,
         requestKey: requestKey,
         requestHash: requestHash,
         fulfillment: fulfillment,
         address: address,
         lines: lines,
         currency: currency,
         subtotalMinor: subtotalMinor,
         deliveryFeeMinor: deliveryFeeMinor,
         totalMinor: totalMinor,
         status: status,
         paymentStatus: paymentStatus,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PurchaseOrder]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PurchaseOrder copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? customerId,
    String? requestKey,
    String? requestHash,
    String? fulfillment,
    Object? address = _Undefined,
    List<_i7utqy3k.OrderLine>? lines,
    String? currency,
    int? subtotalMinor,
    int? deliveryFeeMinor,
    int? totalMinor,
    String? status,
    String? paymentStatus,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      customerId: customerId ?? this.customerId,
      requestKey: requestKey ?? this.requestKey,
      requestHash: requestHash ?? this.requestHash,
      fulfillment: fulfillment ?? this.fulfillment,
      address: address is String? ? address : this.address,
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
      currency: currency ?? this.currency,
      subtotalMinor: subtotalMinor ?? this.subtotalMinor,
      deliveryFeeMinor: deliveryFeeMinor ?? this.deliveryFeeMinor,
      totalMinor: totalMinor ?? this.totalMinor,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
