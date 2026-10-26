import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/raysto_service.dart';
import '../services/payment_service.dart';

class CommerceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<PurchaseOrder> placeOrder(
    Session s,
    int restaurantId,
    List<CartLine> lines,
    String fulfillment,
    String? address,
    String requestKey,
  ) => RaystoService.placeOrder(
    s,
    restaurantId,
    lines,
    fulfillment,
    address,
    requestKey,
  );

  Future<PurchaseOrder> order(Session s, int orderId) =>
      RaystoService.ownOrder(s, orderId);

  Future<List<PurchaseOrder>> myOrders(Session s, int offset) async {
    final userId = RaystoService.user(s);
    if (offset < 0 || offset > 100000) {
      RaystoService.fail('invalid_input', 'Invalid page.');
    }
    return PurchaseOrder.db.find(
      s,
      where: (t) => t.customerId.equals(userId),
      orderBy: (t) => t.id.desc(),
      offset: offset,
      limit: 50,
    );
  }

  Future<CheckoutResult> checkout(Session s, int orderId) =>
      PaymentService.configured().checkout(s, orderId);

  Future<PurchaseOrder> capture(Session s, int orderId) =>
      PaymentService.configured().capture(s, orderId);

  Future<void> registerDevice(Session s, String token) async {
    final userId = RaystoService.user(s);
    RaystoService.text(token, 4096);
    // A device token is never transferred to a different account implicitly.
    final existing = await DeviceToken.db.findFirstRow(
      s,
      where: (t) => t.token.equals(token),
    );
    if (existing != null) {
      if (existing.userId != userId) {
        RaystoService.fail(
          'conflict',
          'Unregister the token from the previous account.',
        );
      }
      existing.updatedAt = DateTime.now().toUtc();
      await DeviceToken.db.updateRow(s, existing);
    } else {
      await DeviceToken.db.insertRow(
        s,
        DeviceToken(
          userId: userId,
          token: token,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  Future<void> unregisterDevice(Session s, String token) async {
    await DeviceToken.db.deleteWhere(
      s,
      where: (t) =>
          t.userId.equals(RaystoService.user(s)) & t.token.equals(token),
    );
  }

  Future<ServiceRequest> requestService(
    Session s,
    int orderId,
    String kind,
  ) async {
    final order = await RaystoService.ownOrder(s, orderId);
    if (!{'help', 'bill'}.contains(kind) || order.status == 'completed') {
      RaystoService.fail('invalid_input', 'Service request is unavailable.');
    }
    return s.db.transaction((tx) async {
      await PurchaseOrder.db.findById(
        s,
        orderId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final existing = await ServiceRequest.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(orderId) & t.kind.equals(kind),
        transaction: tx,
      );
      return existing ??
          await ServiceRequest.db.insertRow(
            s,
            ServiceRequest(
              restaurantId: order.restaurantId,
              orderId: orderId,
              customerId: order.customerId,
              kind: kind,
              status: 'open',
              createdAt: DateTime.now().toUtc(),
            ),
            transaction: tx,
          );
    });
  }
}
