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

abstract class MenuProduct
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MenuProduct._({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.available,
    required this.version,
  });

  factory MenuProduct({
    int? id,
    required int restaurantId,
    required String name,
    required String description,
    required int priceMinor,
    required bool available,
    required int version,
  }) = _MenuProductImpl;

  factory MenuProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return MenuProduct(
      id: jsonSerialization['id'] as int?,
      restaurantId: jsonSerialization['restaurantId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      priceMinor: jsonSerialization['priceMinor'] as int,
      available: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['available'],
      ),
      version: jsonSerialization['version'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int restaurantId;

  String name;

  String description;

  int priceMinor;

  bool available;

  int version;

  /// Returns a shallow copy of this [MenuProduct]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MenuProduct copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? description,
    int? priceMinor,
    bool? available,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MenuProduct',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'priceMinor': priceMinor,
      'available': available,
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MenuProduct',
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'priceMinor': priceMinor,
      'available': available,
      'version': version,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MenuProductImpl extends MenuProduct {
  _MenuProductImpl({
    int? id,
    required int restaurantId,
    required String name,
    required String description,
    required int priceMinor,
    required bool available,
    required int version,
  }) : super._(
         id: id,
         restaurantId: restaurantId,
         name: name,
         description: description,
         priceMinor: priceMinor,
         available: available,
         version: version,
       );

  /// Returns a shallow copy of this [MenuProduct]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MenuProduct copyWith({
    Object? id = _Undefined,
    int? restaurantId,
    String? name,
    String? description,
    int? priceMinor,
    bool? available,
    int? version,
  }) {
    return MenuProduct(
      id: id is int? ? id : this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceMinor: priceMinor ?? this.priceMinor,
      available: available ?? this.available,
      version: version ?? this.version,
    );
  }
}
