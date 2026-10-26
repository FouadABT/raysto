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

abstract class AllocatePayment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AllocatePayment._({
    required this.requestKey,
    required this.restaurantId,
    this.visitId,
    this.orderId,
    this.amountMinor,
    this.lineKeys,
    required this.method,
  });

  factory AllocatePayment({
    required String requestKey,
    required int restaurantId,
    int? visitId,
    int? orderId,
    int? amountMinor,
    List<String>? lineKeys,
    required String method,
  }) = _AllocatePaymentImpl;

  factory AllocatePayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return AllocatePayment(
      requestKey: jsonSerialization['requestKey'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int,
      visitId: jsonSerialization['visitId'] as int?,
      orderId: jsonSerialization['orderId'] as int?,
      amountMinor: jsonSerialization['amountMinor'] as int?,
      lineKeys: jsonSerialization['lineKeys'] == null
          ? null
          : _iksyuhhm.Protocol().deserialize<List<String>>(
              jsonSerialization['lineKeys'],
            ),
      method: jsonSerialization['method'] as String,
    );
  }

  String requestKey;

  int restaurantId;

  int? visitId;

  int? orderId;

  int? amountMinor;

  List<String>? lineKeys;

  String method;

  /// Returns a shallow copy of this [AllocatePayment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AllocatePayment copyWith({
    String? requestKey,
    int? restaurantId,
    int? visitId,
    int? orderId,
    int? amountMinor,
    List<String>? lineKeys,
    String? method,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AllocatePayment',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      if (visitId != null) 'visitId': visitId,
      if (orderId != null) 'orderId': orderId,
      if (amountMinor != null) 'amountMinor': amountMinor,
      if (lineKeys != null) 'lineKeys': lineKeys?.toJson(),
      'method': method,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AllocatePayment',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      if (visitId != null) 'visitId': visitId,
      if (orderId != null) 'orderId': orderId,
      if (amountMinor != null) 'amountMinor': amountMinor,
      if (lineKeys != null) 'lineKeys': lineKeys?.toJson(),
      'method': method,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AllocatePaymentImpl extends AllocatePayment {
  _AllocatePaymentImpl({
    required String requestKey,
    required int restaurantId,
    int? visitId,
    int? orderId,
    int? amountMinor,
    List<String>? lineKeys,
    required String method,
  }) : super._(
         requestKey: requestKey,
         restaurantId: restaurantId,
         visitId: visitId,
         orderId: orderId,
         amountMinor: amountMinor,
         lineKeys: lineKeys,
         method: method,
       );

  /// Returns a shallow copy of this [AllocatePayment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AllocatePayment copyWith({
    String? requestKey,
    int? restaurantId,
    Object? visitId = _Undefined,
    Object? orderId = _Undefined,
    Object? amountMinor = _Undefined,
    Object? lineKeys = _Undefined,
    String? method,
  }) {
    return AllocatePayment(
      requestKey: requestKey ?? this.requestKey,
      restaurantId: restaurantId ?? this.restaurantId,
      visitId: visitId is int? ? visitId : this.visitId,
      orderId: orderId is int? ? orderId : this.orderId,
      amountMinor: amountMinor is int? ? amountMinor : this.amountMinor,
      lineKeys: lineKeys is List<String>?
          ? lineKeys
          : this.lineKeys?.map((e0) => e0).toList(),
      method: method ?? this.method,
    );
  }
}
