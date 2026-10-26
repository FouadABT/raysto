part of 'customer_screens.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _coupon = TextEditingController();
  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store,
          cart = store.cart,
          totals = store.cartTotals();
      return MobilePage(
        title: 'Your cart',
        children: [
          Text(
            store.currentRestaurant.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            context.tr(
              'A separate draft is kept for each customer and restaurant.',
            ),
          ),
          if (cart.lines.isEmpty)
            EmptyState(
              title: 'Your next good meal starts here',
              message: 'Choose something from the menu to start a basket.',
              action: FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => RestaurantScreen(store: store),
                  ),
                ),
                child: Text(context.tr('Browse the menu')),
              ),
            ),
          for (final line in cart.lines)
            AppPanel(
              key: ValueKey(line.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (line.modifiers.isNotEmpty)
                    Text(line.modifiers.map((m) => m.name).join(' · ')),
                  if (line.note.isNotEmpty) Text(line.note),
                  const SizedBox(height: 8),
                  MoneyText(line.subtotalMinor),
                  if (!store.menuItems.any(
                    (m) => m.id == line.itemId && m.available && !m.archived,
                  ))
                    AppNotice(
                      title: context.tr('This item is unavailable'),
                      message: context.tr(
                        'Remove it or choose a replacement before checkout.',
                      ),
                    ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      QuantityStepper(
                        value: line.quantity,
                        onChanged: (v) => guarded(
                          context,
                          () => store.updateCartLine(line.id, quantity: v),
                        ),
                      ),
                      TextButton(
                        onPressed: () => openPage(
                          context,
                          ItemScreen(
                            store: store,
                            itemId: line.itemId,
                            line: line,
                          ),
                        ),
                        child: Text(context.tr('Edit')),
                      ),
                      IconButton(
                        tooltip: context.tr('Remove item'),
                        onPressed: () {
                          store.removeCartLine(line.id);
                          showMessage(
                            context,
                            'Removed from cart',
                            action: SnackBarAction(
                              label: context.tr('Undo'),
                              onPressed: () => guarded(
                                context,
                                () => store.restoreCartLine(line),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (cart.lines.isNotEmpty) ...[
            Section(
              title: 'How would you like it?',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in store.currentRestaurant.services)
                    ChoiceChip(
                      label: Text(context.tr(modeLabel(mode))),
                      selected: cart.mode == mode,
                      onSelected: (_) => guarded(
                        context,
                        () => store.configureCart(mode: mode),
                      ),
                    ),
                ],
              ),
            ),
            if (cart.mode == ServiceMode.dineIn)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_restaurant_outlined),
                title: Text(
                  context.tr(
                    cart.visitId == null
                        ? 'Choose your table'
                        : 'Table visit connected',
                  ),
                ),
                subtitle: Text(
                  context.tr('A valid current visit is required for dine-in.'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPage(context, ScanScreen(store: store)),
              ),
            if (cart.mode == ServiceMode.delivery)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(context.tr('Delivery address')),
                subtitle: Text(
                  store.currentAccount.addresses
                          .where((a) => a.id == cart.addressId)
                          .firstOrNull
                          ?.street ??
                      context.tr('Choose an eligible address'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPage(
                  context,
                  LocationScreen(store: store, chooseForDelivery: true),
                ),
              ),
            if (cart.mode == ServiceMode.pickup)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(context.tr('Pickup time')),
                subtitle: Text(
                  cart.pickupSlot ?? context.tr('Choose a pickup slot'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPage(context, PickupScreen(store: store)),
              ),
            TextField(
              controller: _coupon,
              decoration: InputDecoration(
                labelText: context.tr('Discount code'),
                helperText: context.tr(
                  'Demo codes: FRESH10 · expired: EXPIRED',
                ),
                suffixIcon: IconButton(
                  tooltip: context.tr('Apply code'),
                  onPressed: () => guarded(context, () {
                    store.applyCoupon(_coupon.text);
                    showMessage(context, 'Discount applied');
                  }),
                  icon: const Icon(Icons.check),
                ),
              ),
            ),
            TotalsPanel(totals: totals),
            FilledButton.icon(
              onPressed: () => openPage(context, CheckoutScreen(store: store)),
              icon: const Icon(Icons.lock_outline),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(context.tr('Review checkout')),
              ),
            ),
          ],
        ],
      );
    },
  );
}

class TotalsPanel extends StatelessWidget {
  const TotalsPanel({super.key, required this.totals});
  final CartTotals totals;
  @override
  Widget build(BuildContext context) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PriceRow('Items', totals.subtotalMinor),
        if (totals.discountMinor > 0)
          PriceRow('Discount', -totals.discountMinor),
        if (totals.deliveryFeeMinor > 0)
          PriceRow('Delivery', totals.deliveryFeeMinor),
        if (totals.tipMinor > 0) PriceRow('Tip', totals.tipMinor),
        const Divider(),
        Semantics(
          liveRegion: true,
          child: PriceRow('Total', totals.totalMinor, total: true),
        ),
      ],
    ),
  );
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _busy = false, _payAtEnd = false;
  String _instrument = 'Demo PayPal balance';
  String? _error;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store, cart = store.cart;
      return MobilePage(
        title: 'Review checkout',
        children: [
          AppNotice(
            title: context.tr('Demo checkout — no real payment.'),
            message: context.tr(
              'No external account, card, or bank details are used.',
            ),
            icon: Icons.science_outlined,
          ),
          Text(
            store.currentRestaurant.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          StatusBadge(modeLabel(cart.mode), icon: Icons.shopping_bag_outlined),
          for (final line in cart.lines)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${line.quantity} × ${line.name}'),
              subtitle: Text(
                [
                  ...line.modifiers.map((m) => m.name),
                  if (line.note.isNotEmpty) line.note,
                ].join(' · '),
              ),
              trailing: MoneyText(line.subtotalMinor),
            ),
          if (cart.mode == ServiceMode.delivery)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Delivery address')),
              subtitle: Text(
                store.currentAccount.addresses
                        .where((a) => a.id == cart.addressId)
                        .firstOrNull
                        ?.street ??
                    context.tr('Address required'),
              ),
              onTap: () => openPage(
                context,
                LocationScreen(store: store, chooseForDelivery: true),
              ),
            ),
          if (cart.mode == ServiceMode.pickup)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Pickup time')),
              subtitle: Text(cart.pickupSlot ?? context.tr('Slot required')),
              onTap: () => openPage(context, PickupScreen(store: store)),
            ),
          Section(
            title: 'Optional tip',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tip in [0, 100, 200, 300])
                  ChoiceChip(
                    label: Text(
                      tip == 0 ? context.tr('No tip') : money(context, tip),
                    ),
                    selected: cart.tipMinor == tip,
                    onSelected: (_) => store.configureCart(tipMinor: tip),
                  ),
              ],
            ),
          ),
          if (cart.mode == ServiceMode.dineIn &&
              (store.currentRestaurant.payAtEnd ||
                  store.currentAccount.isStaff))
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Pay at the end of your visit')),
              subtitle: Text(
                context.tr(
                  'The restaurant can prepare this round while your bill stays open.',
                ),
              ),
              value: _payAtEnd,
              onChanged: (v) => setState(() => _payAtEnd = v),
            ),
          if (!_payAtEnd)
            DropdownButtonFormField<String>(
              initialValue: _instrument,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.tr('Simulated payment method'),
              ),
              items: ['Demo PayPal balance', 'Demo PayPal guest']
                  .map(
                    (s) =>
                        DropdownMenuItem(value: s, child: Text(context.tr(s))),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _instrument = v!),
            ),
          TotalsPanel(totals: store.cartTotals()),
          if (_error != null)
            AppNotice(
              title: context.tr('Checkout needs attention'),
              message: context.tr(_error!),
              icon: Icons.error_outline,
            ),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() {
                      _busy = true;
                      _error = null;
                    });
                    try {
                      final attempt = store.beginCheckout(
                        payAtEnd: _payAtEnd,
                        method: _instrument,
                      );
                      if (context.mounted) {
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              store: store,
                              attemptId: attempt.id,
                              autoResolve: !_payAtEnd,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) setState(() => _error = e.toString());
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.tr(
                  _busy
                      ? 'Starting checkout…'
                      : _payAtEnd
                      ? 'Confirm unpaid order'
                      : 'Confirm demo payment',
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.store,
    required this.attemptId,
    this.autoResolve = false,
  });
  final DemoStore store;
  final String attemptId;
  final bool autoResolve;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _error;
  @override
  void initState() {
    super.initState();
    if (widget.autoResolve &&
        widget.store.visibleAttempts.any((a) => a.id == widget.attemptId)) {
      widget.store
          .simulatePayment(widget.attemptId)
          .then<void>(
            (_) {},
            onError: (Object e) {
              if (mounted) setState(() => _error = e.toString());
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final attempt = store.visibleAttempts
          .where((a) => a.id == widget.attemptId)
          .firstOrNull;
      if (attempt == null) {
        return const MobilePage(
          title: 'Checkout unavailable',
          children: [
            EmptyState(
              title: 'This checkout cannot be opened',
              message: 'Return to your orders or start a new demo checkout.',
            ),
          ],
        );
      }
      final success = attempt.status == AttemptStatus.succeeded,
          pending = attempt.status == AttemptStatus.pending;
      final order = store.orders
          .where((o) => o.id == attempt.orderId)
          .firstOrNull;
      return MobilePage(
        title: pending
            ? 'Payment pending'
            : success
            ? 'Order confirmed'
            : 'Payment not completed',
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                success
                    ? Icons.check
                    : pending
                    ? Icons.hourglass_top
                    : Icons.info_outline,
                size: 40,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Text(
            context.tr(
              success
                  ? 'You’re all set.'
                  : pending
                  ? 'Your payment is still pending.'
                  : 'Your basket is safe.',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          MoneyText(attempt.totalMinor, large: true),
          StatusBadge(
            attempt.status.name,
            icon: success ? Icons.check_circle_outline : Icons.schedule,
          ),
          Text(context.tr('Demo checkout — no real payment.')),
          SelectableText('${context.tr('Attempt')} ${attempt.id}'),
          if (order != null) ...[
            StatusBadge(
              '${context.tr('Preparation')}: ${order.status.name}',
              icon: Icons.restaurant_outlined,
            ),
            Text(
              '${context.tr('Payment')}: ${context.tr(store.orderBalance(order.id) == 0 ? 'Settled' : 'Unpaid')}',
            ),
          ],
          if (_error != null)
            AppNotice(title: context.tr('Try again'), message: _error),
          if (pending) ...[
            Text(
              context.tr(
                'You can leave safely and resume from Orders. This exact amount and basket stay reserved.',
              ),
            ),
            Section(
              title: 'Resolve this demo attempt',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final outcome in [
                    PaymentOutcome.success,
                    PaymentOutcome.failed,
                    PaymentOutcome.cancelled,
                  ])
                    OutlinedButton(
                      onPressed: () => guarded(
                        context,
                        () => store.resolvePayment(attempt.id, outcome),
                      ),
                      child: Text(context.tr(outcome.name)),
                    ),
                ],
              ),
            ),
          ],
          if (success && order != null)
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      OrderDetailScreen(store: store, orderId: order.id),
                ),
              ),
              child: Text(context.tr('Track your order')),
            ),
          if (success && attempt.visitId != null && order == null)
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      VisitScreen(store: store, visitId: attempt.visitId!),
                ),
              ),
              child: Text(context.tr('View table bill')),
            ),
          if (!success && !pending) ...[
            Text(
              context.tr(
                'No payment was captured. Review your preserved draft and create a new attempt when ready.',
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      attempt.visitId != null && attempt.allocations.isNotEmpty
                      ? VisitScreen(store: store, visitId: attempt.visitId!)
                      : CheckoutScreen(store: store),
                ),
              ),
              child: Text(context.tr('Review and retry')),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: Text(context.tr('Back to the app')),
          ),
        ],
      );
    },
  );
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.store, this.embedded = false});
  final DemoStore store;
  final bool embedded;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final orders = store.visibleOrders
        .where(
          (o) =>
              _filter == 'All' ||
              (_filter == 'Active' ? o.actionable : !o.actionable),
        )
        .toList()
        .reversed;
    final pending = store.attempts.where(
      (a) =>
          a.accountId == store.currentAccount.id &&
          a.status == AttemptStatus.pending,
    );
    return MobilePage(
      title: 'Orders',
      embedded: widget.embedded,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final f in ['All', 'Active', 'History'])
              ChoiceChip(
                label: Text(context.tr(f)),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
          ],
        ),
        for (final attempt in pending)
          AppNotice(
            title: context.tr('Payment in progress'),
            message: '${attempt.id} · ${money(context, attempt.totalMinor)}',
            action: FilledButton.tonal(
              onPressed: () => openPage(
                context,
                PaymentScreen(store: store, attemptId: attempt.id),
              ),
              child: Text(context.tr('Resume checkout')),
            ),
          ),
        if (orders.isEmpty)
          const EmptyState(
            title: 'Your meals, in one place',
            message: 'Orders you place in this local demo will appear here.',
          ),
        for (final order in orders)
          OrderCard(
            store: store,
            order: order,
            onTap: () => openPage(
              context,
              OrderDetailScreen(store: store, orderId: order.id),
            ),
          ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.store,
    required this.order,
    required this.onTap,
  });
  final DemoStore store;
  final Order order;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.restaurants
                  .where((r) => r.id == order.restaurantId)
                  .first
                  .name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              order.lines.map((l) => '${l.quantity} × ${l.name}').join(', '),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(order.status.name, icon: Icons.restaurant_outlined),
                StatusBadge(
                  store.orderBalance(order.id) == 0 ? 'Settled' : 'Unpaid',
                  icon: Icons.receipt_long_outlined,
                ),
                StatusBadge(
                  modeLabel(order.mode),
                  icon: Icons.shopping_bag_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            MoneyText(order.totalMinor),
            Text(order.id, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.store,
    required this.orderId,
  });
  final DemoStore store;
  final String orderId;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final order = store.visibleOrders
          .where((o) => o.id == orderId)
          .firstOrNull;
      if (order == null) {
        return const MobilePage(
          title: 'Access denied',
          children: [
            EmptyState(
              title: 'This order is not available to this account',
              message: 'Switch to an authorized demo account to continue.',
            ),
          ],
        );
      }
      final stages = [
        OrderStatus.submitted,
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.ready,
        if (order.mode == ServiceMode.dineIn)
          OrderStatus.served
        else if (order.mode == ServiceMode.delivery)
          OrderStatus.delivered
        else
          OrderStatus.collected,
      ];
      final stage = stages.indexOf(order.status);
      return MobilePage(
        title: 'Order tracking',
        children: [
          Text(order.id, style: Theme.of(context).textTheme.titleLarge),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(order.status.name, icon: Icons.restaurant_outlined),
              StatusBadge(
                store.orderBalance(order.id) == 0 ? 'Settled' : 'Unpaid',
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
          if (order.reason.isNotEmpty)
            AppNotice(
              title: context.tr('Restaurant note'),
              message: order.reason,
            ),
          Section(
            title: 'Your order’s journey',
            child: Column(
              children: [
                for (var i = 0; i < stages.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      i <= stage
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: i <= stage
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    title: Text(context.tr(stages[i].name)),
                    subtitle: i == stage
                        ? Text(context.tr('Current stage'))
                        : null,
                  ),
              ],
            ),
          ),
          for (final line in order.lines)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${line.quantity} × ${line.name}'),
              subtitle: Text(
                [
                  ...line.modifiers.map((m) => m.name),
                  if (line.note.isNotEmpty) line.note,
                ].join(' · '),
              ),
              trailing: MoneyText(line.subtotalMinor),
            ),
          PriceRow('Total', order.totalMinor, total: true),
          if (order.mode == ServiceMode.delivery) ...[
            SchematicMap(),
            Text(order.address ?? context.tr('Demo address')),
          ],
          if (order.pickupSlot != null)
            Text('${context.tr('Pickup')}: ${order.pickupSlot}'),
          FilledButton.tonal(
            onPressed: () => openPage(
              context,
              ReceiptScreen(store: store, orderId: order.id),
            ),
            child: Text(context.tr('View receipt')),
          ),
          if (store
              .allowedOrderTransitions(order)
              .contains(OrderStatus.cancelled))
            OutlinedButton(
              onPressed: () async {
                if (await confirmAction(
                      context,
                      'Cancel this order?',
                      'A paid order needs a separate refund. Your preparation and payment records remain visible.',
                    ) &&
                    context.mounted) {
                  guarded(
                    context,
                    () => store.transitionOrder(
                      order.id,
                      OrderStatus.cancelled,
                      reason: 'Customer cancelled from order tracking',
                    ),
                  );
                }
              },
              child: Text(context.tr('Cancel order')),
            ),
          if (store
              .allowedOrderTransitions(order)
              .contains(OrderStatus.collected))
            FilledButton(
              onPressed: () => guarded(
                context,
                () => store.transitionOrder(order.id, OrderStatus.collected),
              ),
              child: Text(context.tr('Confirm pickup collection')),
            ),
          if (!order.actionable) ...[
            OutlinedButton(
              onPressed: () => guarded(context, () {
                store.selectRestaurant(order.restaurantId);
                store.reorder(order.id);
                openPage(context, CartScreen(store: store));
              }),
              child: Text(context.tr('Reorder as a new draft')),
            ),
            OutlinedButton(
              onPressed: () => openPage(
                context,
                ReviewScreen(store: store, orderId: order.id),
              ),
              child: Text(context.tr('Leave local feedback')),
            ),
          ],
          TextButton.icon(
            onPressed: () => openPage(
              context,
              SupportScreen(store: store, orderId: order.id),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(context.tr('Get help with this order')),
          ),
          Section(
            title: 'Activity',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final event in order.events)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(event),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.store, required this.orderId});
  final DemoStore store;
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = store.visibleOrders.where((o) => o.id == orderId).firstOrNull;
    if (order == null) {
      return const MobilePage(title: 'Access denied', children: []);
    }
    final refunds = store.refunds
        .where((r) => r.orderId == order.id)
        .fold<int>(0, (s, r) => s + r.amountMinor);
    return MobilePage(
      title: 'Local receipt',
      children: [
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('raysto', style: Theme.of(context).textTheme.headlineMedium),
              Text(
                store.restaurants
                    .firstWhere((r) => r.id == order.restaurantId)
                    .name,
              ),
              Text(order.id),
              Text(order.createdAt.toIso8601String().substring(0, 16)),
              const Divider(),
              for (final l in order.lines) ...[
                PriceRow('${l.quantity} × ${l.name}', l.subtotalMinor),
                if (l.modifiers.isNotEmpty)
                  Text(
                    l.modifiers.map((m) => m.name).join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
              if (order.deliveryFeeMinor > 0)
                PriceRow('Delivery', order.deliveryFeeMinor),
              if (order.discountMinor > 0)
                PriceRow('Discount', -order.discountMinor),
              if (order.tipMinor > 0) PriceRow('Tip', order.tipMinor),
              const Divider(),
              PriceRow('Order total', order.totalMinor, total: true),
              PriceRow('Captured', store.orderPaid(order.id)),
              PriceRow('Refunded', refunds),
              PriceRow('Outstanding', store.orderBalance(order.id)),
              const SizedBox(height: 20),
              Text(
                context.tr(
                  'Local demo receipt · no real transaction or tax document.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
