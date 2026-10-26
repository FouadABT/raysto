import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:raysto_client/raysto_client.dart' as api;
import 'package:url_launcher/url_launcher.dart';

import 'payment_models.dart';

class ServerpodPaymentBackend implements PaymentBackend {
  ServerpodPaymentBackend(this.client, this.currentOwner);
  final api.Client client;
  final String? Function() currentOwner;

  int _id(String reference) {
    final id = int.tryParse(reference);
    if (id == null || id <= 0 || '$id' != reference) {
      throw const PaymentException(PaymentProblem.notAllowed);
    }
    return id;
  }

  Future<T> _call<T>(Future<T> Function() action) async {
    if (currentOwner() == null) {
      throw const PaymentException(PaymentProblem.notAllowed);
    }
    try {
      return await action();
    } on api.DomainError catch (e) {
      throw PaymentException(switch (e.code) {
        'payment_mismatch' => PaymentProblem.invalidResponse,
        'reconciliation_required' => PaymentProblem.reconciliationRequired,
        'approval_required' => PaymentProblem.notApproved,
        'forbidden' ||
        'not_found' ||
        'unauthenticated' => PaymentProblem.notAllowed,
        _ => PaymentProblem.unavailable,
      });
    }
  }

  PaymentOrder _order(api.PurchaseOrder order) {
    if (order.customerId != currentOwner() ||
        order.id == null ||
        !{'paid', 'unpaid'}.contains(order.paymentStatus)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
    return PaymentOrder(
      reference: '${order.id}',
      amount: PaymentAmount(order.totalMinor, order.currency),
      paid: order.paymentStatus == 'paid',
    );
  }

  @override
  Future<PaymentOrder> read(String reference) => _call(
    () async => reference.startsWith('sandbox:')
        ? _sandbox(
            await client.sandboxPayments.read(_id(reference.substring(8))),
          )
        : _order(await client.commerce.order(_id(reference))),
  );

  PaymentOrder _sandbox(api.SandboxPayment payment) {
    if (payment.userId != currentOwner() ||
        payment.id == null ||
        payment.amountMinor != 100 ||
        payment.currency != 'USD' ||
        !{'created', 'awaitingApproval', 'captured'}.contains(payment.state)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
    return PaymentOrder(
      reference: 'sandbox:${payment.id}',
      amount: PaymentAmount(payment.amountMinor, payment.currency),
      paid: payment.state == 'captured',
    );
  }

  @override
  Future<PaymentApproval> prepare(String reference) => _call(() async {
    if (reference.startsWith('sandbox:')) {
      final result = await client.sandboxPayments.checkout(
        _id(reference.substring(8)),
      );
      _sandbox(result);
      if (result.providerOrderId == null || result.approvalUrl == null) {
        throw const PaymentException(PaymentProblem.invalidResponse);
      }
      return PaymentApproval(
        reference: 'sandbox:${result.id}',
        providerId: result.providerOrderId!,
        url: Uri.parse(result.approvalUrl!),
      );
    }
    final result = await client.commerce.checkout(_id(reference));
    return PaymentApproval(
      reference: '${result.orderId}',
      providerId: result.providerOrderId,
      url: Uri.parse(result.approvalUrl),
    );
  });
  @override
  Future<PaymentOrder> complete(String reference) => _call(
    () async => reference.startsWith('sandbox:')
        ? _sandbox(
            await client.sandboxPayments.capture(_id(reference.substring(8))),
          )
        : _order(await client.commerce.capture(_id(reference))),
  );
}

/// Persist before the first network call, so a lost start response is resumable.
class SandboxCheckoutStarter {
  SandboxCheckoutStarter(
    this.client,
    String backend, {
    FlutterSecureStorage? storage,
  }) : _namespace = base64Url.encode(utf8.encode(backend)),
       _storage = storage ?? const FlutterSecureStorage();
  final api.Client client;
  final String _namespace;
  final FlutterSecureStorage _storage;
  String _key(String owner) =>
      'raysto.sandbox.start.v1.$_namespace.${base64Url.encode(utf8.encode(owner))}';

  Future<api.SandboxPayment?> restore(String owner) async {
    final key = await _storage.read(key: _key(owner));
    return key == null ? null : client.sandboxPayments.start(key);
  }

  Future<api.SandboxPayment> start(String owner) async {
    var key = await _storage.read(key: _key(owner));
    if (key == null) {
      final random = Random.secure();
      key = base64Url
          .encode(List.generate(24, (_) => random.nextInt(256)))
          .replaceAll('=', '');
      await _storage.write(key: _key(owner), value: key);
    }
    return client.sandboxPayments.start(key);
  }

  Future<void> clear(String owner) => _storage.delete(key: _key(owner));
}

class SecurePaymentStore implements PaymentStore {
  SecurePaymentStore(String backend, {FlutterSecureStorage? storage})
    : _namespace = base64Url.encode(utf8.encode(backend)),
      _storage = storage ?? const FlutterSecureStorage();
  final String _namespace;
  final FlutterSecureStorage _storage;
  String _key(String owner) =>
      'raysto.payments.v1.$_namespace.${base64Url.encode(utf8.encode(owner))}';
  @override
  Future<PendingPayment?> read(String owner) async {
    final value = await _storage.read(key: _key(owner));
    return value == null
        ? null
        : PendingPayment.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> write(String owner, PendingPayment payment) =>
      _storage.write(key: _key(owner), value: jsonEncode(payment.toJson()));
  @override
  Future<void> clear(String owner) => _storage.delete(key: _key(owner));
}

class ExternalPaymentBrowser implements PaymentBrowser {
  @override
  Future<bool> open(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}
