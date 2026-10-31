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

abstract class CreateQuote
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CreateQuote._({
    required this.requestKey,
    required this.restaurantId,
    this.visitId,
    required this.fulfillment,
    required this.linesJson,
    this.addressJson,
    this.slot,
    this.couponCode,
    required this.tipMinor,
    this.onBehalf,
    this.customerLabel,
  });

  factory CreateQuote({
    required String requestKey,
    required int restaurantId,
    int? visitId,
    required String fulfillment,
    required String linesJson,
    String? addressJson,
    DateTime? slot,
    String? couponCode,
    required int tipMinor,
    bool? onBehalf,
    String? customerLabel,
  }) = _CreateQuoteImpl;

  factory CreateQuote.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreateQuote(
      requestKey: jsonSerialization['requestKey'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int,
      visitId: jsonSerialization['visitId'] as int?,
      fulfillment: jsonSerialization['fulfillment'] as String,
      linesJson: jsonSerialization['linesJson'] as String,
      addressJson: jsonSerialization['addressJson'] as String?,
      slot: jsonSerialization['slot'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['slot']),
      couponCode: jsonSerialization['couponCode'] as String?,
      tipMinor: jsonSerialization['tipMinor'] as int,
      onBehalf: jsonSerialization['onBehalf'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['onBehalf']),
      customerLabel: jsonSerialization['customerLabel'] as String?,
    );
  }

  String requestKey;

  int restaurantId;

  int? visitId;

  String fulfillment;

  String linesJson;

  String? addressJson;

  DateTime? slot;

  String? couponCode;

  int tipMinor;

  bool? onBehalf;

  String? customerLabel;

  /// Returns a shallow copy of this [CreateQuote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CreateQuote copyWith({
    String? requestKey,
    int? restaurantId,
    int? visitId,
    String? fulfillment,
    String? linesJson,
    String? addressJson,
    DateTime? slot,
    String? couponCode,
    int? tipMinor,
    bool? onBehalf,
    String? customerLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreateQuote',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      if (visitId != null) 'visitId': visitId,
      'fulfillment': fulfillment,
      'linesJson': linesJson,
      if (addressJson != null) 'addressJson': addressJson,
      if (slot != null) 'slot': slot?.toJson(),
      if (couponCode != null) 'couponCode': couponCode,
      'tipMinor': tipMinor,
      if (onBehalf != null) 'onBehalf': onBehalf,
      if (customerLabel != null) 'customerLabel': customerLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreateQuote',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      if (visitId != null) 'visitId': visitId,
      'fulfillment': fulfillment,
      'linesJson': linesJson,
      if (addressJson != null) 'addressJson': addressJson,
      if (slot != null) 'slot': slot?.toJson(),
      if (couponCode != null) 'couponCode': couponCode,
      'tipMinor': tipMinor,
      if (onBehalf != null) 'onBehalf': onBehalf,
      if (customerLabel != null) 'customerLabel': customerLabel,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateQuoteImpl extends CreateQuote {
  _CreateQuoteImpl({
    required String requestKey,
    required int restaurantId,
    int? visitId,
    required String fulfillment,
    required String linesJson,
    String? addressJson,
    DateTime? slot,
    String? couponCode,
    required int tipMinor,
    bool? onBehalf,
    String? customerLabel,
  }) : super._(
         requestKey: requestKey,
         restaurantId: restaurantId,
         visitId: visitId,
         fulfillment: fulfillment,
         linesJson: linesJson,
         addressJson: addressJson,
         slot: slot,
         couponCode: couponCode,
         tipMinor: tipMinor,
         onBehalf: onBehalf,
         customerLabel: customerLabel,
       );

  /// Returns a shallow copy of this [CreateQuote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CreateQuote copyWith({
    String? requestKey,
    int? restaurantId,
    Object? visitId = _Undefined,
    String? fulfillment,
    String? linesJson,
    Object? addressJson = _Undefined,
    Object? slot = _Undefined,
    Object? couponCode = _Undefined,
    int? tipMinor,
    Object? onBehalf = _Undefined,
    Object? customerLabel = _Undefined,
  }) {
    return CreateQuote(
      requestKey: requestKey ?? this.requestKey,
      restaurantId: restaurantId ?? this.restaurantId,
      visitId: visitId is int? ? visitId : this.visitId,
      fulfillment: fulfillment ?? this.fulfillment,
      linesJson: linesJson ?? this.linesJson,
      addressJson: addressJson is String? ? addressJson : this.addressJson,
      slot: slot is DateTime? ? slot : this.slot,
      couponCode: couponCode is String? ? couponCode : this.couponCode,
      tipMinor: tipMinor ?? this.tipMinor,
      onBehalf: onBehalf is bool? ? onBehalf : this.onBehalf,
      customerLabel: customerLabel is String?
          ? customerLabel
          : this.customerLabel,
    );
  }
}
