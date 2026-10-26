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

abstract class CheckoutResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CheckoutResult._({
    required this.orderId,
    required this.providerOrderId,
    required this.approvalUrl,
  });

  factory CheckoutResult({
    required int orderId,
    required String providerOrderId,
    required String approvalUrl,
  }) = _CheckoutResultImpl;

  factory CheckoutResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return CheckoutResult(
      orderId: jsonSerialization['orderId'] as int,
      providerOrderId: jsonSerialization['providerOrderId'] as String,
      approvalUrl: jsonSerialization['approvalUrl'] as String,
    );
  }

  int orderId;

  String providerOrderId;

  String approvalUrl;

  /// Returns a shallow copy of this [CheckoutResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CheckoutResult copyWith({
    int? orderId,
    String? providerOrderId,
    String? approvalUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CheckoutResult',
      'orderId': orderId,
      'providerOrderId': providerOrderId,
      'approvalUrl': approvalUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CheckoutResult',
      'orderId': orderId,
      'providerOrderId': providerOrderId,
      'approvalUrl': approvalUrl,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CheckoutResultImpl extends CheckoutResult {
  _CheckoutResultImpl({
    required int orderId,
    required String providerOrderId,
    required String approvalUrl,
  }) : super._(
         orderId: orderId,
         providerOrderId: providerOrderId,
         approvalUrl: approvalUrl,
       );

  /// Returns a shallow copy of this [CheckoutResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CheckoutResult copyWith({
    int? orderId,
    String? providerOrderId,
    String? approvalUrl,
  }) {
    return CheckoutResult(
      orderId: orderId ?? this.orderId,
      providerOrderId: providerOrderId ?? this.providerOrderId,
      approvalUrl: approvalUrl ?? this.approvalUrl,
    );
  }
}
