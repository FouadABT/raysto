import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  test('printed capitals become readable section names', () {
    expect(MenuAgent.heading('BREAKFAST'), 'Breakfast');
    expect(MenuAgent.heading('FISH & CHIPS'), 'Fish & Chips');
    expect(MenuAgent.heading('PLATS DU JOUR'), 'Plats Du Jour');
    expect(MenuAgent.heading('ÉTÉ'), 'Été');
    // Names the owner wrote are kept as they are.
    expect(MenuAgent.heading('Small plates'), 'Small plates');
    expect(MenuAgent.heading('مشروبات'), 'مشروبات');
    expect(MenuAgent.heading('2 FOR 1'), '2 For 1');
  });

  test('dish names match whatever the case, spacing or punctuation', () {
    expect(
      MenuAgent.normal('Croque-Monsieur'),
      MenuAgent.normal('croque monsieur'),
    );
    expect(MenuAgent.normal('  Lemon   tart '), 'lemon tart');
  });
}
