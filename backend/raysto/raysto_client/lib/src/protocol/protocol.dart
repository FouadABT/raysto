/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:raysto_client/src/protocol/cart_line.dart' as _ipjdc1on;
import 'package:raysto_client/src/protocol/menu_product.dart' as _i6l7aqus;
import 'package:raysto_client/src/protocol/purchase_order.dart' as _i9r4fpg5;
import 'package:raysto_client/src/protocol/restaurant.dart' as _i11vln88;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'cart_line.dart' as _ihfq9pvm;
import 'checkout_result.dart' as _i5rg4892;
import 'domain_error.dart' as _immikmlr;
import 'menu_product.dart' as _i0rg43cj;
import 'order_line.dart' as _i7utqy3k;
import 'platform/allocate_payment.dart' as _iho8f24j;
import 'platform/charge_share.dart' as _iaiv5uup;
import 'platform/create_quote.dart' as _ihuzea45;
import 'platform/platform_command.dart' as _in5mt2du;
import 'platform/platform_event.dart' as _i46ou76b;
import 'platform/platform_response.dart' as _ibbs4n93;
import 'platform/request_refund.dart' as _i7dkxoyy;
import 'platform/start_visit.dart' as _ic6k5ko2;
import 'platform/submit_order.dart' as _ijdjbc0u;
import 'purchase_order.dart' as _i4elpxu0;
import 'restaurant.dart' as _iwilqhab;
import 'sandbox_payment.dart' as _iftkb6t2;
import 'service_request.dart' as _ijgh7vob;
export 'cart_line.dart';
export 'checkout_result.dart';
export 'domain_error.dart';
export 'menu_product.dart';
export 'order_line.dart';
export 'platform/allocate_payment.dart';
export 'platform/charge_share.dart';
export 'platform/create_quote.dart';
export 'platform/platform_command.dart';
export 'platform/platform_event.dart';
export 'platform/platform_response.dart';
export 'platform/request_refund.dart';
export 'platform/start_visit.dart';
export 'platform/submit_order.dart';
export 'purchase_order.dart';
export 'restaurant.dart';
export 'sandbox_payment.dart';
export 'service_request.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ihfq9pvm.CartLine) {
      return _ihfq9pvm.CartLine.fromJson(data) as T;
    }
    if (t == _i5rg4892.CheckoutResult) {
      return _i5rg4892.CheckoutResult.fromJson(data) as T;
    }
    if (t == _immikmlr.DomainError) {
      return _immikmlr.DomainError.fromJson(data) as T;
    }
    if (t == _i0rg43cj.MenuProduct) {
      return _i0rg43cj.MenuProduct.fromJson(data) as T;
    }
    if (t == _i7utqy3k.OrderLine) {
      return _i7utqy3k.OrderLine.fromJson(data) as T;
    }
    if (t == _iho8f24j.AllocatePayment) {
      return _iho8f24j.AllocatePayment.fromJson(data) as T;
    }
    if (t == _iaiv5uup.ChargeShare) {
      return _iaiv5uup.ChargeShare.fromJson(data) as T;
    }
    if (t == _ihuzea45.CreateQuote) {
      return _ihuzea45.CreateQuote.fromJson(data) as T;
    }
    if (t == _in5mt2du.PlatformCommand) {
      return _in5mt2du.PlatformCommand.fromJson(data) as T;
    }
    if (t == _i46ou76b.PlatformEvent) {
      return _i46ou76b.PlatformEvent.fromJson(data) as T;
    }
    if (t == _ibbs4n93.PlatformResponse) {
      return _ibbs4n93.PlatformResponse.fromJson(data) as T;
    }
    if (t == _i7dkxoyy.RequestRefund) {
      return _i7dkxoyy.RequestRefund.fromJson(data) as T;
    }
    if (t == _ic6k5ko2.StartVisit) {
      return _ic6k5ko2.StartVisit.fromJson(data) as T;
    }
    if (t == _ijdjbc0u.SubmitOrder) {
      return _ijdjbc0u.SubmitOrder.fromJson(data) as T;
    }
    if (t == _i4elpxu0.PurchaseOrder) {
      return _i4elpxu0.PurchaseOrder.fromJson(data) as T;
    }
    if (t == _iwilqhab.Restaurant) {
      return _iwilqhab.Restaurant.fromJson(data) as T;
    }
    if (t == _iftkb6t2.SandboxPayment) {
      return _iftkb6t2.SandboxPayment.fromJson(data) as T;
    }
    if (t == _ijgh7vob.ServiceRequest) {
      return _ijgh7vob.ServiceRequest.fromJson(data) as T;
    }
    if (t == _isc.getType<_ihfq9pvm.CartLine?>()) {
      return (data != null ? _ihfq9pvm.CartLine.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5rg4892.CheckoutResult?>()) {
      return (data != null ? _i5rg4892.CheckoutResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_immikmlr.DomainError?>()) {
      return (data != null ? _immikmlr.DomainError.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0rg43cj.MenuProduct?>()) {
      return (data != null ? _i0rg43cj.MenuProduct.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i7utqy3k.OrderLine?>()) {
      return (data != null ? _i7utqy3k.OrderLine.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iho8f24j.AllocatePayment?>()) {
      return (data != null ? _iho8f24j.AllocatePayment.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iaiv5uup.ChargeShare?>()) {
      return (data != null ? _iaiv5uup.ChargeShare.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ihuzea45.CreateQuote?>()) {
      return (data != null ? _ihuzea45.CreateQuote.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_in5mt2du.PlatformCommand?>()) {
      return (data != null ? _in5mt2du.PlatformCommand.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i46ou76b.PlatformEvent?>()) {
      return (data != null ? _i46ou76b.PlatformEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ibbs4n93.PlatformResponse?>()) {
      return (data != null ? _ibbs4n93.PlatformResponse.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7dkxoyy.RequestRefund?>()) {
      return (data != null ? _i7dkxoyy.RequestRefund.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ic6k5ko2.StartVisit?>()) {
      return (data != null ? _ic6k5ko2.StartVisit.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijdjbc0u.SubmitOrder?>()) {
      return (data != null ? _ijdjbc0u.SubmitOrder.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4elpxu0.PurchaseOrder?>()) {
      return (data != null ? _i4elpxu0.PurchaseOrder.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iwilqhab.Restaurant?>()) {
      return (data != null ? _iwilqhab.Restaurant.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iftkb6t2.SandboxPayment?>()) {
      return (data != null ? _iftkb6t2.SandboxPayment.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ijgh7vob.ServiceRequest?>()) {
      return (data != null ? _ijgh7vob.ServiceRequest.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_iaiv5uup.ChargeShare>) {
      return (data as List)
              .map((e) => deserialize<_iaiv5uup.ChargeShare>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_iaiv5uup.ChargeShare>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_iaiv5uup.ChargeShare>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i7utqy3k.OrderLine>) {
      return (data as List)
              .map((e) => deserialize<_i7utqy3k.OrderLine>(e))
              .toList()
          as T;
    }
    if (t == List<_i11vln88.Restaurant>) {
      return (data as List)
              .map((e) => deserialize<_i11vln88.Restaurant>(e))
              .toList()
          as T;
    }
    if (t == List<_i6l7aqus.MenuProduct>) {
      return (data as List)
              .map((e) => deserialize<_i6l7aqus.MenuProduct>(e))
              .toList()
          as T;
    }
    if (t == List<_ipjdc1on.CartLine>) {
      return (data as List)
              .map((e) => deserialize<_ipjdc1on.CartLine>(e))
              .toList()
          as T;
    }
    if (t == List<_i9r4fpg5.PurchaseOrder>) {
      return (data as List)
              .map((e) => deserialize<_i9r4fpg5.PurchaseOrder>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ihfq9pvm.CartLine => 'CartLine',
      _i5rg4892.CheckoutResult => 'CheckoutResult',
      _immikmlr.DomainError => 'DomainError',
      _i0rg43cj.MenuProduct => 'MenuProduct',
      _i7utqy3k.OrderLine => 'OrderLine',
      _iho8f24j.AllocatePayment => 'AllocatePayment',
      _iaiv5uup.ChargeShare => 'ChargeShare',
      _ihuzea45.CreateQuote => 'CreateQuote',
      _in5mt2du.PlatformCommand => 'PlatformCommand',
      _i46ou76b.PlatformEvent => 'PlatformEvent',
      _ibbs4n93.PlatformResponse => 'PlatformResponse',
      _i7dkxoyy.RequestRefund => 'RequestRefund',
      _ic6k5ko2.StartVisit => 'StartVisit',
      _ijdjbc0u.SubmitOrder => 'SubmitOrder',
      _i4elpxu0.PurchaseOrder => 'PurchaseOrder',
      _iwilqhab.Restaurant => 'Restaurant',
      _iftkb6t2.SandboxPayment => 'SandboxPayment',
      _ijgh7vob.ServiceRequest => 'ServiceRequest',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('raysto.', '');
    }

    switch (data) {
      case _ihfq9pvm.CartLine():
        return 'CartLine';
      case _i5rg4892.CheckoutResult():
        return 'CheckoutResult';
      case _immikmlr.DomainError():
        return 'DomainError';
      case _i0rg43cj.MenuProduct():
        return 'MenuProduct';
      case _i7utqy3k.OrderLine():
        return 'OrderLine';
      case _iho8f24j.AllocatePayment():
        return 'AllocatePayment';
      case _iaiv5uup.ChargeShare():
        return 'ChargeShare';
      case _ihuzea45.CreateQuote():
        return 'CreateQuote';
      case _in5mt2du.PlatformCommand():
        return 'PlatformCommand';
      case _i46ou76b.PlatformEvent():
        return 'PlatformEvent';
      case _ibbs4n93.PlatformResponse():
        return 'PlatformResponse';
      case _i7dkxoyy.RequestRefund():
        return 'RequestRefund';
      case _ic6k5ko2.StartVisit():
        return 'StartVisit';
      case _ijdjbc0u.SubmitOrder():
        return 'SubmitOrder';
      case _i4elpxu0.PurchaseOrder():
        return 'PurchaseOrder';
      case _iwilqhab.Restaurant():
        return 'Restaurant';
      case _iftkb6t2.SandboxPayment():
        return 'SandboxPayment';
      case _ijgh7vob.ServiceRequest():
        return 'ServiceRequest';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CartLine') {
      return deserialize<_ihfq9pvm.CartLine>(data['data']);
    }
    if (dataClassName == 'CheckoutResult') {
      return deserialize<_i5rg4892.CheckoutResult>(data['data']);
    }
    if (dataClassName == 'DomainError') {
      return deserialize<_immikmlr.DomainError>(data['data']);
    }
    if (dataClassName == 'MenuProduct') {
      return deserialize<_i0rg43cj.MenuProduct>(data['data']);
    }
    if (dataClassName == 'OrderLine') {
      return deserialize<_i7utqy3k.OrderLine>(data['data']);
    }
    if (dataClassName == 'AllocatePayment') {
      return deserialize<_iho8f24j.AllocatePayment>(data['data']);
    }
    if (dataClassName == 'ChargeShare') {
      return deserialize<_iaiv5uup.ChargeShare>(data['data']);
    }
    if (dataClassName == 'CreateQuote') {
      return deserialize<_ihuzea45.CreateQuote>(data['data']);
    }
    if (dataClassName == 'PlatformCommand') {
      return deserialize<_in5mt2du.PlatformCommand>(data['data']);
    }
    if (dataClassName == 'PlatformEvent') {
      return deserialize<_i46ou76b.PlatformEvent>(data['data']);
    }
    if (dataClassName == 'PlatformResponse') {
      return deserialize<_ibbs4n93.PlatformResponse>(data['data']);
    }
    if (dataClassName == 'RequestRefund') {
      return deserialize<_i7dkxoyy.RequestRefund>(data['data']);
    }
    if (dataClassName == 'StartVisit') {
      return deserialize<_ic6k5ko2.StartVisit>(data['data']);
    }
    if (dataClassName == 'SubmitOrder') {
      return deserialize<_ijdjbc0u.SubmitOrder>(data['data']);
    }
    if (dataClassName == 'PurchaseOrder') {
      return deserialize<_i4elpxu0.PurchaseOrder>(data['data']);
    }
    if (dataClassName == 'Restaurant') {
      return deserialize<_iwilqhab.Restaurant>(data['data']);
    }
    if (dataClassName == 'SandboxPayment') {
      return deserialize<_iftkb6t2.SandboxPayment>(data['data']);
    }
    if (dataClassName == 'ServiceRequest') {
      return deserialize<_ijgh7vob.ServiceRequest>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('raysto', this);
    _iacc.Protocol().registerHostProtocol('raysto', this);
  }

  @override
  String getModuleName() => 'raysto';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
