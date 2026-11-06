import 'package:raysto_server/src/web/platform_routes.dart';
import 'package:test/test.dart';

void main() {
  test(
    'HTTP group queries deliver integer IDs to the authorized domain query',
    () {
      expect(
        PlatformRoute.parseQueryParameters({'groupId': '17', 'range': '7d'}),
        {'groupId': 17, 'range': '7d'},
      );
    },
  );
  test('malformed IDs stay invalid rather than becoming another group', () {
    for (final value in ['17.5', 'other', '']) {
      expect(
        PlatformRoute.parseQueryParameters({'groupId': value})['groupId'],
        value,
      );
    }
  });
  test(
    'HTTP dates, decimal coordinates and explicit booleans retain their types',
    () {
      expect(
        PlatformRoute.parseQueryParameters({
          'restaurantId': '4',
          'latitude': '40.5',
          'staff': 'true',
          'openNow': 'false',
          'from': '2026-11-06',
          'cursor': '8',
        }),
        {
          'restaurantId': 4,
          'latitude': 40.5,
          'staff': true,
          'openNow': false,
          'from': '2026-11-06',
          'cursor': 8,
        },
      );
    },
  );
}
