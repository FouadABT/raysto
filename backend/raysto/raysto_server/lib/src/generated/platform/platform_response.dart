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

abstract class PlatformResponse
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PlatformResponse._({
    required this.requestId,
    required this.dataJson,
  });

  factory PlatformResponse({
    required String requestId,
    required String dataJson,
  }) = _PlatformResponseImpl;

  factory PlatformResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlatformResponse(
      requestId: jsonSerialization['requestId'] as String,
      dataJson: jsonSerialization['dataJson'] as String,
    );
  }

  String requestId;

  String dataJson;

  /// Returns a shallow copy of this [PlatformResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlatformResponse copyWith({
    String? requestId,
    String? dataJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlatformResponse',
      'requestId': requestId,
      'dataJson': dataJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlatformResponse',
      'requestId': requestId,
      'dataJson': dataJson,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PlatformResponseImpl extends PlatformResponse {
  _PlatformResponseImpl({
    required String requestId,
    required String dataJson,
  }) : super._(
         requestId: requestId,
         dataJson: dataJson,
       );

  /// Returns a shallow copy of this [PlatformResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlatformResponse copyWith({
    String? requestId,
    String? dataJson,
  }) {
    return PlatformResponse(
      requestId: requestId ?? this.requestId,
      dataJson: dataJson ?? this.dataJson,
    );
  }
}
