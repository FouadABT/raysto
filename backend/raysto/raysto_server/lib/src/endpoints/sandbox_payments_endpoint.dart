import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/raysto_service.dart';
import '../services/sandbox_payment_service.dart';

/// A separate sandbox receipt, never a restaurant order or entitlement.
class SandboxPaymentsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  void _enabled() {
    if (Platform.environment['RAYSTO_SANDBOX_TEST_ENABLED'] != 'true') {
      RaystoService.fail(
        'not_configured',
        'Sandbox test checkout is disabled.',
      );
    }
  }

  Future<SandboxPayment> start(Session s, String requestKey) {
    _enabled();
    return SandboxPaymentService.start(s, requestKey);
  }

  Future<SandboxPayment> read(Session s, int paymentId) {
    _enabled();
    return SandboxPaymentService.own(s, paymentId);
  }

  Future<SandboxPayment> checkout(Session s, int paymentId) {
    _enabled();
    return SandboxPaymentService.configured().checkout(s, paymentId);
  }

  Future<SandboxPayment> capture(Session s, int paymentId) {
    _enabled();
    return SandboxPaymentService.configured().capture(s, paymentId);
  }
}
