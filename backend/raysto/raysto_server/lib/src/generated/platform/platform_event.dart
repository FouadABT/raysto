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

abstract class PlatformEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PlatformEvent._({
    required this.cursor,
    required this.kind,
    this.entityId,
    required this.createdAt,
  });

  factory PlatformEvent({
    required int cursor,
    required String kind,
    int? entityId,
    required DateTime createdAt,
  }) = _PlatformEventImpl;

  factory PlatformEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlatformEvent(
      cursor: jsonSerialization['cursor'] as int,
      kind: jsonSerialization['kind'] as String,
      entityId: jsonSerialization['entityId'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  int cursor;

  String kind;

  int? entityId;

  DateTime createdAt;

  /// Returns a shallow copy of this [PlatformEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlatformEvent copyWith({
    int? cursor,
    String? kind,
    int? entityId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlatformEvent',
      'cursor': cursor,
      'kind': kind,
      if (entityId != null) 'entityId': entityId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlatformEvent',
      'cursor': cursor,
      'kind': kind,
      if (entityId != null) 'entityId': entityId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlatformEventImpl extends PlatformEvent {
  _PlatformEventImpl({
    required int cursor,
    required String kind,
    int? entityId,
    required DateTime createdAt,
  }) : super._(
         cursor: cursor,
         kind: kind,
         entityId: entityId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PlatformEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlatformEvent copyWith({
    int? cursor,
    String? kind,
    Object? entityId = _Undefined,
    DateTime? createdAt,
  }) {
    return PlatformEvent(
      cursor: cursor ?? this.cursor,
      kind: kind ?? this.kind,
      entityId: entityId is int? ? entityId : this.entityId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
