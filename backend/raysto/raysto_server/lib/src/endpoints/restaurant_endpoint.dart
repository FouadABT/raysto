import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/raysto_service.dart';

class RestaurantEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<Restaurant> create(
    Session s,
    String name,
    String currency,
    int deliveryFeeMinor,
  ) => RaystoService.createRestaurant(s, name, currency, deliveryFeeMinor);

  Future<void> publish(Session s, int restaurantId, bool published) =>
      RaystoService.setPublished(s, restaurantId, published);

  Future<void> setStaff(
    Session s,
    int restaurantId,
    String userId,
    String role,
    bool active,
  ) => RaystoService.setMembership(s, restaurantId, userId, role, active);

  Future<MenuProduct> saveProduct(
    Session s,
    int restaurantId,
    int? productId,
    String name,
    String description,
    int priceMinor,
    bool available,
  ) => RaystoService.saveProduct(
    s,
    restaurantId,
    productId,
    name,
    description,
    priceMinor,
    available,
  );

  Future<PurchaseOrder> transition(
    Session s,
    int orderId,
    int expectedVersion,
    String nextStatus,
  ) => RaystoService.transition(s, orderId, expectedVersion, nextStatus);

  Future<List<PurchaseOrder>> orders(
    Session s,
    int restaurantId,
    int offset,
    int limit,
  ) => RaystoService.report(s, restaurantId, offset, limit);

  Future<List<PurchaseOrder>> queue(Session s, int restaurantId) async {
    final member = await RaystoService.requireRole(
      s,
      restaurantId,
      RaystoService.staff,
    );
    // Courier assignment/dispatch is a later workflow; do not expose the entire
    // restaurant's customer/address queue to an unassigned courier.
    if (member.role == 'courier') return [];
    return PurchaseOrder.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(restaurantId) & t.status.notEquals('completed'),
      limit: 100,
      orderBy: (t) => t.id,
    );
  }
}
