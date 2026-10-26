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

abstract class PlatformCommand
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlatformCommand._({
    required this.requestKey,
    this.restaurantId,
    this.resourceId,
    this.expectedVersion,
    required this.dataJson,
  });

  factory PlatformCommand({
    required String requestKey,
    int? restaurantId,
    int? resourceId,
    int? expectedVersion,
    required String dataJson,
  }) = _PlatformCommandImpl;

  factory PlatformCommand.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlatformCommand(
      requestKey: jsonSerialization['requestKey'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int?,
      resourceId: jsonSerialization['resourceId'] as int?,
      expectedVersion: jsonSerialization['expectedVersion'] as int?,
      dataJson: jsonSerialization['dataJson'] as String,
    );
  }

  String requestKey;

  int? restaurantId;

  int? resourceId;

  int? expectedVersion;

  String dataJson;

  /// Returns a shallow copy of this [PlatformCommand]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlatformCommand copyWith({
    String? requestKey,
    int? restaurantId,
    int? resourceId,
    int? expectedVersion,
    String? dataJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlatformCommand',
      'requestKey': requestKey,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (resourceId != null) 'resourceId': resourceId,
      if (expectedVersion != null) 'expectedVersion': expectedVersion,
      'dataJson': dataJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlatformCommand',
      'requestKey': requestKey,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (resourceId != null) 'resourceId': resourceId,
      if (expectedVersion != null) 'expectedVersion': expectedVersion,
      'dataJson': dataJson,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlatformCommandImpl extends PlatformCommand {
  _PlatformCommandImpl({
    required String requestKey,
    int? restaurantId,
    int? resourceId,
    int? expectedVersion,
    required String dataJson,
  }) : super._(
         requestKey: requestKey,
         restaurantId: restaurantId,
         resourceId: resourceId,
         expectedVersion: expectedVersion,
         dataJson: dataJson,
       );

  /// Returns a shallow copy of this [PlatformCommand]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlatformCommand copyWith({
    String? requestKey,
    Object? restaurantId = _Undefined,
    Object? resourceId = _Undefined,
    Object? expectedVersion = _Undefined,
    String? dataJson,
  }) {
    return PlatformCommand(
      requestKey: requestKey ?? this.requestKey,
      restaurantId: restaurantId is int? ? restaurantId : this.restaurantId,
      resourceId: resourceId is int? ? resourceId : this.resourceId,
      expectedVersion: expectedVersion is int?
          ? expectedVersion
          : this.expectedVersion,
      dataJson: dataJson ?? this.dataJson,
    );
  }
}
