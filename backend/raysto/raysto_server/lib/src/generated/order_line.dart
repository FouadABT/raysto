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

abstract class OrderLine
    implements _is.SerializableModel, _is.ProtocolSerialization {
  OrderLine._({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPriceMinor,
  });

  factory OrderLine({
    required int productId,
    required String name,
    required int quantity,
    required int unitPriceMinor,
  }) = _OrderLineImpl;

  factory OrderLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderLine(
      productId: jsonSerialization['productId'] as int,
      name: jsonSerialization['name'] as String,
      quantity: jsonSerialization['quantity'] as int,
      unitPriceMinor: jsonSerialization['unitPriceMinor'] as int,
    );
  }

  int productId;

  String name;

  int quantity;

  int unitPriceMinor;

  /// Returns a shallow copy of this [OrderLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OrderLine copyWith({
    int? productId,
    String? name,
    int? quantity,
    int? unitPriceMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderLine',
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unitPriceMinor': unitPriceMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrderLine',
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unitPriceMinor': unitPriceMinor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _OrderLineImpl extends OrderLine {
  _OrderLineImpl({
    required int productId,
    required String name,
    required int quantity,
    required int unitPriceMinor,
  }) : super._(
         productId: productId,
         name: name,
         quantity: quantity,
         unitPriceMinor: unitPriceMinor,
       );

  /// Returns a shallow copy of this [OrderLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OrderLine copyWith({
    int? productId,
    String? name,
    int? quantity,
    int? unitPriceMinor,
  }) {
    return OrderLine(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    );
  }
}
