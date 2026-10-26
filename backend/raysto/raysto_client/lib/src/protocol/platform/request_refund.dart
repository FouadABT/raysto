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

abstract class RequestRefund
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RequestRefund._({
    required this.requestKey,
    required this.restaurantId,
    required this.captureId,
    required this.amountMinor,
    required this.reason,
  });

  factory RequestRefund({
    required String requestKey,
    required int restaurantId,
    required int captureId,
    required int amountMinor,
    required String reason,
  }) = _RequestRefundImpl;

  factory RequestRefund.fromJson(Map<String, dynamic> jsonSerialization) {
    return RequestRefund(
      requestKey: jsonSerialization['requestKey'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int,
      captureId: jsonSerialization['captureId'] as int,
      amountMinor: jsonSerialization['amountMinor'] as int,
      reason: jsonSerialization['reason'] as String,
    );
  }

  String requestKey;

  int restaurantId;

  int captureId;

  int amountMinor;

  String reason;

  /// Returns a shallow copy of this [RequestRefund]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RequestRefund copyWith({
    String? requestKey,
    int? restaurantId,
    int? captureId,
    int? amountMinor,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RequestRefund',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      'captureId': captureId,
      'amountMinor': amountMinor,
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RequestRefund',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      'captureId': captureId,
      'amountMinor': amountMinor,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RequestRefundImpl extends RequestRefund {
  _RequestRefundImpl({
    required String requestKey,
    required int restaurantId,
    required int captureId,
    required int amountMinor,
    required String reason,
  }) : super._(
         requestKey: requestKey,
         restaurantId: restaurantId,
         captureId: captureId,
         amountMinor: amountMinor,
         reason: reason,
       );

  /// Returns a shallow copy of this [RequestRefund]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RequestRefund copyWith({
    String? requestKey,
    int? restaurantId,
    int? captureId,
    int? amountMinor,
    String? reason,
  }) {
    return RequestRefund(
      requestKey: requestKey ?? this.requestKey,
      restaurantId: restaurantId ?? this.restaurantId,
      captureId: captureId ?? this.captureId,
      amountMinor: amountMinor ?? this.amountMinor,
      reason: reason ?? this.reason,
    );
  }
}
