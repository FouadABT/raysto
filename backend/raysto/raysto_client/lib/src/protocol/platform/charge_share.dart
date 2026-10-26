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

abstract class ChargeShare
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ChargeShare._({
    required this.chargeId,
    required this.amountMinor,
    required this.expectedVersion,
  });

  factory ChargeShare({
    required int chargeId,
    required int amountMinor,
    required int expectedVersion,
  }) = _ChargeShareImpl;

  factory ChargeShare.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChargeShare(
      chargeId: jsonSerialization['chargeId'] as int,
      amountMinor: jsonSerialization['amountMinor'] as int,
      expectedVersion: jsonSerialization['expectedVersion'] as int,
    );
  }

  int chargeId;

  int amountMinor;

  int expectedVersion;

  /// Returns a shallow copy of this [ChargeShare]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ChargeShare copyWith({
    int? chargeId,
    int? amountMinor,
    int? expectedVersion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChargeShare',
      'chargeId': chargeId,
      'amountMinor': amountMinor,
      'expectedVersion': expectedVersion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChargeShare',
      'chargeId': chargeId,
      'amountMinor': amountMinor,
      'expectedVersion': expectedVersion,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ChargeShareImpl extends ChargeShare {
  _ChargeShareImpl({
    required int chargeId,
    required int amountMinor,
    required int expectedVersion,
  }) : super._(
         chargeId: chargeId,
         amountMinor: amountMinor,
         expectedVersion: expectedVersion,
       );

  /// Returns a shallow copy of this [ChargeShare]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ChargeShare copyWith({
    int? chargeId,
    int? amountMinor,
    int? expectedVersion,
  }) {
    return ChargeShare(
      chargeId: chargeId ?? this.chargeId,
      amountMinor: amountMinor ?? this.amountMinor,
      expectedVersion: expectedVersion ?? this.expectedVersion,
    );
  }
}
