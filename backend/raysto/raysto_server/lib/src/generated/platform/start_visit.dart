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

abstract class StartVisit
    implements _is.SerializableModel, _is.ProtocolSerialization {
  StartVisit._({
    required this.requestKey,
    required this.restaurantId,
    required this.tableId,
    required this.guestCount,
    this.seatingToken,
  });

  factory StartVisit({
    required String requestKey,
    required int restaurantId,
    required int tableId,
    required int guestCount,
    String? seatingToken,
  }) = _StartVisitImpl;

  factory StartVisit.fromJson(Map<String, dynamic> jsonSerialization) {
    return StartVisit(
      requestKey: jsonSerialization['requestKey'] as String,
      restaurantId: jsonSerialization['restaurantId'] as int,
      tableId: jsonSerialization['tableId'] as int,
      guestCount: jsonSerialization['guestCount'] as int,
      seatingToken: jsonSerialization['seatingToken'] as String?,
    );
  }

  String requestKey;

  int restaurantId;

  int tableId;

  int guestCount;

  String? seatingToken;

  /// Returns a shallow copy of this [StartVisit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StartVisit copyWith({
    String? requestKey,
    int? restaurantId,
    int? tableId,
    int? guestCount,
    String? seatingToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StartVisit',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      'tableId': tableId,
      'guestCount': guestCount,
      if (seatingToken != null) 'seatingToken': seatingToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StartVisit',
      'requestKey': requestKey,
      'restaurantId': restaurantId,
      'tableId': tableId,
      'guestCount': guestCount,
      if (seatingToken != null) 'seatingToken': seatingToken,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StartVisitImpl extends StartVisit {
  _StartVisitImpl({
    required String requestKey,
    required int restaurantId,
    required int tableId,
    required int guestCount,
    String? seatingToken,
  }) : super._(
         requestKey: requestKey,
         restaurantId: restaurantId,
         tableId: tableId,
         guestCount: guestCount,
         seatingToken: seatingToken,
       );

  /// Returns a shallow copy of this [StartVisit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StartVisit copyWith({
    String? requestKey,
    int? restaurantId,
    int? tableId,
    int? guestCount,
    Object? seatingToken = _Undefined,
  }) {
    return StartVisit(
      requestKey: requestKey ?? this.requestKey,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
      guestCount: guestCount ?? this.guestCount,
      seatingToken: seatingToken is String? ? seatingToken : this.seatingToken,
    );
  }
}
