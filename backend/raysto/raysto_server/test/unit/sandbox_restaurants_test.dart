import 'dart:io';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

// Which restaurants take payments on the one Sandbox merchant.
void main() {
  void configure(String ids, {bool enabled = true}) {
    ProviderClients.environment = () => {
      'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
      'RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED': '$enabled',
      'RAYSTO_SANDBOX_RESTAURANT_ID': ids,
    };
  }

  tearDown(() => ProviderClients.environment = () => Platform.environment);

  test('one id binds only that restaurant', () {
    configure('3');
    expect(ProviderClients.singleRestaurant(3), isTrue);
    expect(ProviderClients.singleRestaurant(4), isFalse);
  });

  test('a comma-separated list binds each listed restaurant', () {
    configure('3, 7');
    expect(ProviderClients.singleRestaurant(3), isTrue);
    expect(ProviderClients.singleRestaurant(7), isTrue);
    expect(ProviderClients.singleRestaurant(37), isFalse);
  });

  test('nothing is bound when the Sandbox merchant is off or ids are bad', () {
    configure('3', enabled: false);
    expect(ProviderClients.singleRestaurant(3), isFalse);
    configure('');
    expect(ProviderClients.singleRestaurant(0), isFalse);
    configure('x,,3x');
    expect(ProviderClients.singleRestaurant(3), isFalse);
  });
}
