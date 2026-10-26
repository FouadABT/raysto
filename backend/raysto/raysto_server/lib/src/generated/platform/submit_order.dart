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

abstract class SubmitOrder
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SubmitOrder._({
    required this.requestKey,
    required this.restaurantId,
    required this.quoteId,
  });

  factory SubmitOrder({
    required String requestKey,
    required int restaurantId,
    required int quoteId,
  }) = _SubmitOrderImpl;

  factory SubmitOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubmitOrder(
      requestKey: jsonSerialization['requestKey'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int,
      quoteId: jsonSerialization['quoteId'] as int,
    );
  }

  String requestKey;

  int restaurantId;

  int quoteId;

  /// Returns a shallow copy of this [SubmitOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SubmitOrder copyWith({
    String? requestKey,
    int? restaurantId,
    int? quoteId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SubmitOrder',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      'quoteId': quoteId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SubmitOrder',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      'quoteId': quoteId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SubmitOrderImpl extends SubmitOrder {
  _SubmitOrderImpl({
    required String requestKey,
    required int restaurantId,
    required int quoteId,
  }) : super._(
         requestKey: requestKey,
         restaurantId: restaurantId,
         quoteId: quoteId,
       );

  /// Returns a shallow copy of this [SubmitOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SubmitOrder copyWith({
    String? requestKey,
    int? restaurantId,
    int? quoteId,
  }) {
    return SubmitOrder(
      requestKey: requestKey ?? this.requestKey,
      restaurantId: restaurantId ?? this.restaurantId,
      quoteId: quoteId ?? this.quoteId,
    );
  }
}
