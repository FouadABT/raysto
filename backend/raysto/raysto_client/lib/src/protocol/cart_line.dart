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

abstract class CartLine
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CartLine._({
    required this.productId,
    required this.quantity,
  });

  factory CartLine({
    required int productId,
    required int quantity,
  }) = _CartLineImpl;

  factory CartLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return CartLine(
      productId: jsonSerialization['productId'] as int,
      quantity: jsonSerialization['quantity'] as int,
    );
  }

  int productId;

  int quantity;

  /// Returns a shallow copy of this [CartLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CartLine copyWith({
    int? productId,
    int? quantity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CartLine',
      'productId': productId,
      'quantity': quantity,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CartLine',
      'productId': productId,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CartLineImpl extends CartLine {
  _CartLineImpl({
    required int productId,
    required int quantity,
  }) : super._(
         productId: productId,
         quantity: quantity,
       );

  /// Returns a shallow copy of this [CartLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CartLine copyWith({
    int? productId,
    int? quantity,
  }) {
    return CartLine(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}
