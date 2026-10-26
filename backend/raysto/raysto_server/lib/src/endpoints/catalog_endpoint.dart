import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class CatalogEndpoint extends Endpoint {
  Future<List<Restaurant>> restaurants(Session s) => Restaurant.db.find(
    s,
    where: (t) => t.published.equals(true),
    limit: 100,
    orderBy: (t) => t.id,
  );

  Future<List<MenuProduct>> menu(Session s, int restaurantId) async {
    final restaurant = await Restaurant.db.findById(s, restaurantId);
    if (restaurant == null || !restaurant.published) return [];
    return MenuProduct.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(restaurantId) & t.available.equals(true),
      orderBy: (t) => t.id,
      limit: 500,
    );
  }
}
