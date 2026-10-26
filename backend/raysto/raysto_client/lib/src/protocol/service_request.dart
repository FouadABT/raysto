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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class ServiceRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ServiceRequest._({
    this.id,
    required this.restaurantId,
    required this.orderId,
    required this.customerId,
    required this.kind,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequest({
    int? id,
    required int restaurantId,
    required int orderId,
    required String customerId,
    required String kind,
    required String status,
    required DateTime createdAt,
  }) = _ServiceRequestImpl;

  factory ServiceRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ServiceRequest(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      orderId: jsonSerialization['orderId'] as int,
      customerId: jsonSerialization['customerId'] as String,
      kind: jsonSerialization['kind'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int restaurantId;

  int orderId;

  String customerId;

  String kind;

  String status;

  DateTime createdAt;

  /// Returns a shallow copy of this [ServiceRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ServiceRequest copyWith({
    int? id,
    int? restaurantId,
    int? orderId,
    String? customerId,
    String? kind,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ServiceRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      'customerId': customerId,
      'kind': kind,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ServiceRequest',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'orderId': orderId,
      'customerId': customerId,
      'kind': kind,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ServiceRequestImpl extends ServiceRequest {
  _ServiceRequestImpl({
    int? id,
    required int restaurantId,
    required int orderId,
    required String customerId,
    required String kind,
    required String status,
    required DateTime createdAt,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         orderId: orderId,
         customerId: customerId,
         kind: kind,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ServiceRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ServiceRequest copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    int? orderId,
    String? customerId,
    String? kind,
    String? status,
    DateTime? createdAt,
  }) {
    return ServiceRequest(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
