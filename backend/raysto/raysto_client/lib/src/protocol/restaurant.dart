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

abstract class Restaurant
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Restaurant._({
    this.id,
    required this.name,
    required this.currency,
    required this.deliveryFeeMinor,
    required this.published,
    required this.createdAt,
  });

  factory Restaurant({
    int? id,
    required String name,
    required String currency,
    required int deliveryFeeMinor,
    required bool published,
    required DateTime createdAt,
  }) = _RestaurantImpl;

  factory Restaurant.fromJson(Map<String, dynamic> jsonSerialization) {
    return Restaurant(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      currency: jsonSerialization['currency'] as String,
      deliveryFeeMinor: jsonSerialization['deliveryFeeMinor'] as int,
      published: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['published'],
      ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  String currency;

  int deliveryFeeMinor;

  bool published;

  DateTime createdAt;

  /// Returns a shallow copy of this [Restaurant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Restaurant copyWith({
    int? id,
    String? name,
    String? currency,
    int? deliveryFeeMinor,
    bool? published,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Restaurant',
      if (id != null) 'id': id,
      'name': name,
      'currency': currency,
      'deliveryFeeMinor': deliveryFeeMinor,
      'published': published,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Restaurant',
      if (id != null) 'id': id,
      'name': name,
      'currency': currency,
      'deliveryFeeMinor': deliveryFeeMinor,
      'published': published,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantImpl extends Restaurant {
  _RestaurantImpl({
    int? id,
    required String name,
    required String currency,
    required int deliveryFeeMinor,
    required bool published,
    required DateTime createdAt,
  }) : super._(
         id: id,
         name: name,
         currency: currency,
         deliveryFeeMinor: deliveryFeeMinor,
         published: published,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Restaurant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Restaurant copyWith({
    Object? id = _Undefined,
    String? name,
    String? currency,
    int? deliveryFeeMinor,
    bool? published,
    DateTime? createdAt,
  }) {
    return Restaurant(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      deliveryFeeMinor: deliveryFeeMinor ?? this.deliveryFeeMinor,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
