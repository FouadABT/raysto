import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Shared by the generated mobile endpoints and HTTP reporting routes.
class RaystoService {
  static const managers = {'owner', 'manager'};
  static const staff = {'owner', 'manager', 'waiter', 'kitchen', 'courier'};

  static Never fail(String code, String message) =>
      throw DomainError(code: code, message: message);

  static String user(Session session) =>
      session.authenticated?.userIdentifier ??
      fail('unauthorized', 'Sign in first.');

  static String text(String value, int max) {
    final result = value.trim();
    if (result.isEmpty || result.length > max) {
      fail('invalid_input', 'Text must contain between 1 and $max characters.');
    }
    return result;
  }

  static Future<Membership> requireRole(
    Session session,
    int restaurantId,
    Set<String> roles, {
    Transaction? transaction,
  }) async {
    final userId = user(session);
    final actor = await ActorProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
      transaction: transaction,
    );
    if (actor != null &&
        (actor.isGuest || actor.disabled || actor.claimedBy != null)) {
      fail('forbidden', 'This identity cannot operate a restaurant.');
    }
    if (await RestaurantPolicy.db.findFirstRow(
          session,
          where: (t) => t.restaurantId.equals(restaurantId),
          transaction: transaction,
        ) !=
        null) {
      fail('client_upgrade_required', 'Use the v2 API for this restaurant.');
    }
    final membership = await Membership.db.findFirstRow(
      session,
      where: (t) =>
          t.restaurantId.equals(restaurantId) & t.userId.equals(userId),
      transaction: transaction,
    );
    if (membership == null ||
        !membership.active ||
        !roles.contains(membership.role)) {
      fail('forbidden', 'This restaurant action is not permitted.');
    }
    return membership;
  }

  /// Locking the restaurant serializes menu/pricing/permission edits and order quotes.
  static Future<Restaurant> lockRestaurant(
    Session s,
    int id,
    Transaction tx,
  ) async {
    if (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(id),
          transaction: tx,
        ) !=
        null) {
      fail(
        'client_upgrade_required',
        'Use the v2 commands for this restaurant. Existing legacy records retain their original workflow.',
      );
    }
    return await Restaurant.db.findById(
          s,
          id,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ) ??
        fail('not_found', 'Restaurant not found.');
  }

  static Future<Restaurant> createRestaurant(
    Session s,
    String name,
    String currency,
    int deliveryFeeMinor,
  ) async {
    final owner = user(s);
    final actor = await ActorProfile.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(owner),
    );
    if (actor != null &&
        (actor.isGuest || actor.disabled || actor.claimedBy != null)) {
      fail('forbidden', 'Use a verified account to create a restaurant.');
    }
    if (!{'EUR', 'USD', 'GBP'}.contains(currency) ||
        deliveryFeeMinor < 0 ||
        deliveryFeeMinor > 10000) {
      fail('invalid_input', 'Unsupported currency or delivery fee.');
    }
    return s.db.transaction((tx) async {
      final restaurant = await Restaurant.db.insertRow(
        s,
        Restaurant(
          name: text(name, 120),
          currency: currency,
          deliveryFeeMinor: deliveryFeeMinor,
          published: false,
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: restaurant.id!,
          userId: owner,
          role: 'owner',
          active: true,
        ),
        transaction: tx,
      );
      return restaurant;
    });
  }

  static Future<void> setPublished(Session s, int id, bool published) async {
    await s.db.transaction((tx) async {
      final restaurant = await lockRestaurant(s, id, tx);
      await requireRole(s, id, managers, transaction: tx);
      restaurant.published = published;
      await Restaurant.db.updateRow(s, restaurant, transaction: tx);
    });
  }

  static Future<void> setMembership(
    Session s,
    int id,
    String targetUser,
    String role,
    bool active,
  ) async {
    if (!{'manager', 'waiter', 'kitchen', 'courier'}.contains(role)) {
      fail('invalid_input', 'Unsupported staff role.');
    }
    text(targetUser, 128);
    await s.db.transaction((tx) async {
      await lockRestaurant(s, id, tx);
      await requireRole(s, id, {'owner'}, transaction: tx);
      var member = await Membership.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(id) & t.userId.equals(targetUser),
        transaction: tx,
      );
      if (member?.role == 'owner') {
        fail('forbidden', 'The owner cannot be overwritten.');
      }
      if (member == null) {
        await Membership.db.insertRow(
          s,
          Membership(
            restaurantId: id,
            userId: targetUser,
            role: role,
            active: active,
          ),
          transaction: tx,
        );
      } else {
        member.role = role;
        member.active = active;
        await Membership.db.updateRow(s, member, transaction: tx);
      }
    });
  }

  static Future<MenuProduct> saveProduct(
    Session s,
    int restaurantId,
    int? id,
    String name,
    String description,
    int priceMinor,
    bool available,
  ) async {
    if (priceMinor < 1 || priceMinor > 100000 || description.length > 2000) {
      fail('invalid_input', 'Invalid price or description.');
    }
    return s.db.transaction((tx) async {
      await lockRestaurant(s, restaurantId, tx);
      await requireRole(s, restaurantId, managers, transaction: tx);
      if (id == null) {
        return MenuProduct.db.insertRow(
          s,
          MenuProduct(
            restaurantId: restaurantId,
            name: text(name, 120),
            description: description.trim(),
            priceMinor: priceMinor,
            available: available,
            version: 1,
          ),
          transaction: tx,
        );
      }
      final product = await MenuProduct.db.findById(s, id, transaction: tx);
      if (product == null || product.restaurantId != restaurantId) {
        fail('not_found', 'Product not found.');
      }
      product.name = text(name, 120);
      product.description = description.trim();
      product.priceMinor = priceMinor;
      product.available = available;
      product.version++;
      return MenuProduct.db.updateRow(s, product, transaction: tx);
    });
  }

  static Future<PurchaseOrder> placeOrder(
    Session s,
    int restaurantId,
    List<CartLine> lines,
    String fulfillment,
    String? address,
    String requestKey,
  ) async {
    final customer = user(s);
    if (!RegExp(r'^[a-zA-Z0-9_-]{16,64}$').hasMatch(requestKey) ||
        !{'pickup', 'delivery'}.contains(fulfillment) ||
        lines.isEmpty ||
        lines.length > 50) {
      fail('invalid_input', 'Invalid checkout request.');
    }
    final normalizedAddress = fulfillment == 'delivery'
        ? text(address ?? '', 500)
        : null;
    final sorted = [...lines]
      ..sort((a, b) => a.productId.compareTo(b.productId));
    final seen = <int>{};
    for (final line in sorted) {
      if (!seen.add(line.productId) ||
          line.quantity < 1 ||
          line.quantity > 20) {
        fail('invalid_input', 'Duplicate item or invalid quantity.');
      }
    }
    final hash = sha256
        .convert(
          utf8.encode(
            jsonEncode({
              'restaurant': restaurantId,
              'fulfillment': fulfillment,
              'address': normalizedAddress,
              'lines': [
                for (final line in sorted) [line.productId, line.quantity],
              ],
            }),
          ),
        )
        .toString();
    return s.db.transaction((tx) async {
      final restaurant = await lockRestaurant(s, restaurantId, tx);
      final existing = await PurchaseOrder.db.findFirstRow(
        s,
        where: (t) =>
            t.customerId.equals(customer) & t.requestKey.equals(requestKey),
        transaction: tx,
      );
      if (existing != null) {
        if (existing.requestHash != hash) {
          fail('conflict', 'Request key belongs to a different order.');
        }
        return existing;
      }
      if (!restaurant.published) {
        fail('unavailable', 'Restaurant is not accepting orders.');
      }
      final snapshot = <OrderLine>[];
      var subtotal = 0;
      for (final line in sorted) {
        final product = await MenuProduct.db.findById(
          s,
          line.productId,
          transaction: tx,
        );
        if (product == null ||
            product.restaurantId != restaurantId ||
            !product.available) {
          fail('unavailable', 'An item is unavailable. Refresh the menu.');
        }
        subtotal += product.priceMinor * line.quantity;
        snapshot.add(
          OrderLine(
            productId: product.id!,
            name: product.name,
            quantity: line.quantity,
            unitPriceMinor: product.priceMinor,
          ),
        );
      }
      final fee = fulfillment == 'delivery' ? restaurant.deliveryFeeMinor : 0;
      if (subtotal + fee > 1000000) {
        fail('invalid_input', 'Order exceeds the supported amount.');
      }
      final now = DateTime.now().toUtc();
      return PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: restaurantId,
          customerId: customer,
          requestKey: requestKey,
          requestHash: hash,
          fulfillment: fulfillment,
          address: normalizedAddress,
          lines: snapshot,
          currency: restaurant.currency,
          subtotalMinor: subtotal,
          deliveryFeeMinor: fee,
          totalMinor: subtotal + fee,
          status: 'placed',
          paymentStatus: 'unpaid',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
    });
  }

  static Future<PurchaseOrder> ownOrder(Session s, int id) async {
    final order = await PurchaseOrder.db.findById(s, id);
    if (order == null || order.customerId != user(s)) {
      fail('not_found', 'Order not found.');
    }
    return order;
  }

  static Future<void> emit(
    Session s,
    PurchaseOrder order,
    String kind,
    Transaction tx,
  ) async {
    final now = DateTime.now().toUtc();
    await OutboxEvent.db.insertRow(
      s,
      OutboxEvent(
        orderId: order.id!,
        userId: order.customerId,
        kind: kind,
        createdAt: now,
        attempts: 0,
        nextAttemptAt: now,
      ),
      transaction: tx,
    );
  }

  static Future<PurchaseOrder> transition(
    Session s,
    int id,
    int expectedVersion,
    String next,
  ) async {
    final initial =
        await PurchaseOrder.db.findById(s, id) ??
        fail('not_found', 'Order not found.');
    return s.db.transaction((tx) async {
      await lockRestaurant(s, initial.restaurantId, tx);
      final order = (await PurchaseOrder.db.findById(
        s,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      final member = await requireRole(
        s,
        order.restaurantId,
        staff,
        transaction: tx,
      );
      if (order.version != expectedVersion) {
        fail('conflict', 'Order changed. Refresh before retrying.');
      }
      final allowed = switch (order.status) {
        'placed' => {'accepted'},
        'accepted' => {'preparing'},
        'preparing' => {'ready'},
        'ready' =>
          order.fulfillment == 'delivery' ? {'outForDelivery'} : {'completed'},
        'outForDelivery' => {'completed'},
        _ => <String>{},
      };
      if (!allowed.contains(next)) {
        fail('invalid_transition', 'Invalid order transition.');
      }
      final roles = switch (next) {
        'accepted' => {'owner', 'manager', 'waiter'},
        'preparing' || 'ready' => {'owner', 'manager', 'kitchen'},
        'outForDelivery' => {'owner', 'manager'},
        _ =>
          order.fulfillment == 'delivery'
              ? {'owner', 'manager'}
              : {'owner', 'manager', 'waiter'},
      };
      if (!roles.contains(member.role)) {
        fail('forbidden', 'Your role cannot perform this transition.');
      }
      if (order.paymentStatus != 'paid') {
        fail('payment_required', 'Payment must be confirmed first.');
      }
      order.status = next;
      order.version++;
      order.updatedAt = DateTime.now().toUtc();
      await PurchaseOrder.db.updateRow(s, order, transaction: tx);
      await emit(s, order, 'order.$next', tx);
      return order;
    });
  }

  static Future<List<PurchaseOrder>> report(
    Session s,
    int restaurantId,
    int offset,
    int limit,
  ) async {
    await requireRole(s, restaurantId, managers);
    if (offset < 0 || offset > 100000 || limit < 1 || limit > 100) {
      fail('invalid_input', 'Invalid report page.');
    }
    return PurchaseOrder.db.find(
      s,
      where: (t) => t.restaurantId.equals(restaurantId),
      orderBy: (t) => t.id.desc(),
      offset: offset,
      limit: limit,
    );
  }
}
