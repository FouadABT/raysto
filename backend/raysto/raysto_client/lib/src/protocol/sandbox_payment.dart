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

abstract class SandboxPayment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SandboxPayment._({
    this.id,
    required this.userId,
    required this.requestKey,
    required this.providerRequestId,
    required this.amountMinor,
    required this.currency,
    required this.state,
    this.providerOrderId,
    this.approvalUrl,
    this.captureId,
    this.webhookEventId,
    this.webhookReceivedAt,
    this.capturedAt,
    required this.createdAt,
  });

  factory SandboxPayment({
    int? id,
    required String userId,
    required String requestKey,
    required String providerRequestId,
    required int amountMinor,
    required String currency,
    required String state,
    String? providerOrderId,
    String? approvalUrl,
    String? captureId,
    String? webhookEventId,
    DateTime? webhookReceivedAt,
    DateTime? capturedAt,
    required DateTime createdAt,
  }) = _SandboxPaymentImpl;

  factory SandboxPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return SandboxPayment(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      requestKey: jsonSerialization['requestKey'] as String,
      providerRequestId: jsonSerialization['providerRequestId'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      currency: jsonSerialization['currency'] as String,
      state: jsonSerialization['state'] as String,
      providerOrderId: jsonSerialization['providerOrderId'] as String?,
      approvalUrl: jsonSerialization['approvalUrl'] as String?,
      captureId: jsonSerialization['captureId'] as String?,
      webhookEventId: jsonSerialization['webhookEventId'] as String?,
      webhookReceivedAt: jsonSerialization['webhookReceivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['webhookReceivedAt'],
            ),
      capturedAt: jsonSerialization['capturedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['capturedAt'],
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

  String userId;

  String requestKey;

  String providerRequestId;

  int amountMinor;

  String currency;

  String state;

  String? providerOrderId;

  String? approvalUrl;

  String? captureId;

  String? webhookEventId;

  DateTime? webhookReceivedAt;

  DateTime? capturedAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [SandboxPayment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SandboxPayment copyWith({
    int? id,
    String? userId,
    String? requestKey,
    String? providerRequestId,
    int? amountMinor,
    String? currency,
    String? state,
    String? providerOrderId,
    String? approvalUrl,
    String? captureId,
    String? webhookEventId,
    DateTime? webhookReceivedAt,
    DateTime? capturedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SandboxPayment',
      if (id != null) 'id': id,
      'userId': userId,
      'requestKey': requestKey,
      'providerRequestId': providerRequestId,
      'amountMinor': amountMinor,
      'currency': currency,
      'state': state,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      if (captureId != null) 'captureId': captureId,
      if (webhookEventId != null) 'webhookEventId': webhookEventId,
      if (webhookReceivedAt != null)
        'webhookReceivedAt': webhookReceivedAt?.toJson(),
      if (capturedAt != null) 'capturedAt': capturedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SandboxPayment',
      if (id != null) 'id': id,
      'userId': userId,
      'requestKey': requestKey,
      'providerRequestId': providerRequestId,
      'amountMinor': amountMinor,
      'currency': currency,
      'state': state,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (approvalUrl != null) 'approvalUrl': approvalUrl,
      if (captureId != null) 'captureId': captureId,
      if (webhookEventId != null) 'webhookEventId': webhookEventId,
      if (webhookReceivedAt != null)
        'webhookReceivedAt': webhookReceivedAt?.toJson(),
      if (capturedAt != null) 'capturedAt': capturedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SandboxPaymentImpl extends SandboxPayment {
  _SandboxPaymentImpl({
    int? id,
    required String userId,
    required String requestKey,
    required String providerRequestId,
    required int amountMinor,
    required String currency,
    required String state,
    String? providerOrderId,
    String? approvalUrl,
    String? captureId,
    String? webhookEventId,
    DateTime? webhookReceivedAt,
    DateTime? capturedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         requestKey: requestKey,
         providerRequestId: providerRequestId,
         amountMinor: amountMinor,
         currency: currency,
         state: state,
         providerOrderId: providerOrderId,
         approvalUrl: approvalUrl,
         captureId: captureId,
         webhookEventId: webhookEventId,
         webhookReceivedAt: webhookReceivedAt,
         capturedAt: capturedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SandboxPayment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SandboxPayment copyWith({
    Object? id = _Undefined,
    String? userId,
    String? requestKey,
    String? providerRequestId,
    int? amountMinor,
    String? currency,
    String? state,
    Object? providerOrderId = _Undefined,
    Object? approvalUrl = _Undefined,
    Object? captureId = _Undefined,
    Object? webhookEventId = _Undefined,
    Object? webhookReceivedAt = _Undefined,
    Object? capturedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return SandboxPayment(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      requestKey: requestKey ?? this.requestKey,
      providerRequestId: providerRequestId ?? this.providerRequestId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      state: state ?? this.state,
      providerOrderId: providerOrderId is String?
          ? providerOrderId
          : this.providerOrderId,
      approvalUrl: approvalUrl is String? ? approvalUrl : this.approvalUrl,
      captureId: captureId is String? ? captureId : this.captureId,
      webhookEventId: webhookEventId is String?
          ? webhookEventId
          : this.webhookEventId,
      webhookReceivedAt: webhookReceivedAt is DateTime?
          ? webhookReceivedAt
          : this.webhookReceivedAt,
      capturedAt: capturedAt is DateTime? ? capturedAt : this.capturedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
