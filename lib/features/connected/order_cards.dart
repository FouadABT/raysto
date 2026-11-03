part of 'connected_app.dart';

// The diner's side of an order, in the language of the staff cards: a card of
// lines, a clear total, and each state as a chip before any sentence.

/// One line of an order: quantity, name, chosen options or note, and price.
/// The price moves under the name on a narrow card or at large text sizes,
/// so the name never shrinks to a sliver.
class OrderLine extends StatelessWidget {
  const OrderLine({
    super.key,
    required this.quantity,
    required this.name,
    this.details = const [],
    this.price,
    this.trailing,
  });
  final Object? quantity;
  final String name;
  final List<String> details;
  final String? price;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = details.where((d) => d.isNotEmpty).toList();
    final figures = theme.textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final count = Text(
      '$quantity×',
      style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700),
    );
    final title = Text(
      name,
      style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
    );
    final more = shown.isEmpty
        ? null
        : Text(
            shown.join(' · '),
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
    return LayoutBuilder(
      builder: (context, box) {
        // A narrow card or large text gives the name the whole width: the
        // quantity leads it, and the price and any action sit underneath.
        if (box.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$quantity×  ', style: count.style),
                      TextSpan(text: name, style: title.style),
                    ],
                  ),
                ),
                ?more,
                if (price != null || trailing != null)
                  Row(
                    children: [
                      Expanded(
                        child: price == null
                            ? const SizedBox.shrink()
                            : Text(price!, style: figures),
                      ),
                      ?trailing,
                    ],
                  ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 34),
                child: count,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, ?more],
                ),
              ),
              if (price != null) ...[
                const SizedBox(width: 12),
                Text(price!, style: figures),
              ],
              ?trailing,
            ],
          ),
        );
      },
    );
  }
}

/// A label and its amount on one line; the amount wraps under its label when
/// there is no room. The total is set larger, as on the staff cards.
class MoneyRow extends StatelessWidget {
  const MoneyRow(this.label, this.amount, {super.key, this.total = false});
  final String label, amount;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final figures =
        (total
                ? theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.bodyMedium!)
            .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: total ? 4 : 1),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 2,
        children: [
          Text(
            label,
            style: total
                ? theme.textTheme.titleMedium
                : theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          Text(amount, style: figures),
        ],
      ),
    );
  }
}

/// The card every customer order view shares: a state color along its edge,
/// a heading, chips, the lines, then the money.
class CustomerOrderCard extends StatelessWidget {
  const CustomerOrderCard({
    super.key,
    this.heading,
    this.chips = const [],
    this.notice,
    this.lines = const [],
    this.money = const [],
    this.footer,
    this.accent,
  });
  final Widget? heading;
  final List<Widget> chips;
  final Widget? notice;
  final List<Widget> lines;
  final List<Widget> money;
  final Widget? footer;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <Widget>[
      ?heading,
      if (chips.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: chips),
      ?notice,
      if (lines.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: lines),
      if (money.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 10),
            ...money,
          ],
        ),
      ?footer,
    ];
    return AppPanel(
      padding: EdgeInsets.zero,
      accent: accent,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          accent == null ? 20 : 26,
          18,
          20,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, part) in parts.indexed) ...[
              if (i > 0) const SizedBox(height: 12),
              part,
            ],
          ],
        ),
      ),
    );
  }
}

/// The server's priced quote: how and when, what, and what it costs. Every
/// amount is the quote's own; nothing is recomputed on the phone.
Widget quoteCard(BuildContext c, Json d) {
  final currency = '${d['currency'] ?? ''}';
  final how = StaffOrder({
    'fulfillment': d['fulfillment'],
    'origin': d['origin'],
  });
  int minor(String key) => (d[key] as num? ?? 0).toInt();
  final subtotal = minor('subtotalMinor'), discount = minor('discountMinor');
  final tax = minor('taxMinor'), fee = minor('deliveryFeeMinor');
  final tip = minor('tipMinor'), total = minor('totalMinor');
  // Prices that already include tax show it as included, not added.
  final taxAdded = total == subtotal - discount + tax + fee + tip;
  final expires = DateTime.tryParse('${d['expiresAt'] ?? ''}')?.toLocal();
  final theme = Theme.of(c);
  return CustomerOrderCard(
    chips: [
      AppPill(label: c.tr(how.channel), icon: channelIcon(how)),
      if (d['fulfillment'] == 'pickup')
        AppPill(label: pickupLabel(c, d['slot']), icon: Icons.schedule),
      if (d['paymentTiming'] != null)
        AppPill(
          label: c.tr(
            d['paymentTiming'] == 'end'
                ? 'Pay at the end of your visit'
                : 'Pay before preparation',
          ),
          icon: Icons.payments_outlined,
          color: theme.extension<AppStatusColors>()?.warning,
        ),
    ],
    lines: [
      for (final line in records(d['lines']))
        OrderLine(
          quantity: line['quantity'],
          name: '${line['name']}',
          details: [optionNames(line), '${line['note'] ?? ''}'],
          price: lineTotal(line, currency),
        ),
    ],
    money: [
      if (subtotal != total)
        MoneyRow(c.tr('Subtotal'), money(subtotal, currency)),
      if (discount > 0)
        MoneyRow(c.tr('Discount'), '−${money(discount, currency)}'),
      if (tax > 0)
        MoneyRow(c.tr(taxAdded ? 'Tax' : 'Tax included'), money(tax, currency)),
      if (fee > 0) MoneyRow(c.tr('Delivery fee'), money(fee, currency)),
      if (tip > 0) MoneyRow(c.tr('Tip'), money(tip, currency)),
      MoneyRow(c.tr('Total'), money(total, currency), total: true),
    ],
    footer: expires == null
        ? null
        : Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${c.tr('Price held until')} ${MaterialLocalizations.of(c).formatTimeOfDay(TimeOfDay.fromDateTime(expires))}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
  );
}

/// A placed order as the diner follows it: where it stands, how it is paid,
/// the code to collect it, what is in it and its total.
Widget orderCard(BuildContext c, Json d) {
  final o = StaffOrder(d);
  final theme = Theme.of(c);
  final address = obj(d['address']);
  final where = [
    address['line'],
    [address['postalCode'], address['city']].whereType<Object>().join(' '),
    address['country'],
  ].whereType<Object>().map((v) => '$v').where((v) => v.isNotEmpty);
  return CustomerOrderCard(
    accent: stateAccent(o.status),
    heading: cardHeading(
      c,
      customerStatus(c, o.status),
      aside: o.number == null ? null : '#${o.number}',
    ),
    chips: [
      AppPill(label: c.tr(o.channel), icon: channelIcon(o)),
      statePill(c, o.paymentStatus),
      if (o.customerLabel != null)
        AppPill(label: o.customerLabel!, icon: Icons.person_outline),
    ],
    notice: o.pickupCode == null ? null : pickupCodeStrip(c, o.pickupCode!),
    lines: [
      for (final line in o.lines)
        OrderLine(
          quantity: line['quantity'],
          name: '${line['name']}',
          details: [optionNames(line), '${line['note'] ?? ''}'],
          price: lineTotal(line, o.currency),
        ),
    ],
    money: [
      MoneyRow(c.tr('Total'), money(o.totalMinor, o.currency), total: true),
    ],
    footer: o.fulfillment != 'delivery' || where.isEmpty
        ? null
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  where.join(', '),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
  );
}

/// A checkout as the diner reads it: the amount, its state, what it pays
/// for, and the sentence that says what happens next.
Widget checkoutCard(BuildContext c, Json d, String title, String message) {
  final state = '${d['state']}';
  final currency = '${d['currency'] ?? ''}';
  final theme = Theme.of(c);
  final refunded = d['refundedMinor'] as num? ?? 0;
  return CustomerOrderCard(
    accent: paymentAccent(state),
    heading: cardHeading(c, money(d['amountMinor'], currency)),
    chips: [
      statePill(c, state),
      if (d['orderId'] != null)
        AppPill(
          label: '${c.tr('Order')} #${d['orderId']}',
          icon: Icons.receipt_long_outlined,
        ),
      if (d['visitId'] != null)
        AppPill(label: c.tr('Shared table bill'), icon: Icons.groups_outlined),
    ],
    notice: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          message,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
    money: [
      if (refunded > 0) MoneyRow(c.tr('Refunded'), money(refunded, currency)),
    ],
    footer: d['captureId'] == null
        ? null
        : Text(
            '${c.tr('Receipt')} #${d['captureId']}',
            style: theme.textTheme.bodySmall,
          ),
  );
}

/// The tip choices a diner sees before PayPal: none by default, three
/// percentages of the amount, or a sum of their own. The chosen amount is
/// what goes to the server; nothing is recomputed afterwards.
const tipPercents = [5, 10, 15];

int tipFor(int amountMinor, int percent) => (amountMinor * percent / 100).round();

/// The row of tip chips with the amount each would add; "Other" asks for a
/// sum. [onChanged] receives the tip in minor units (0 for none).
class TipChooser extends StatelessWidget {
  const TipChooser({
    super.key,
    required this.amountMinor,
    required this.currency,
    required this.tipMinor,
    required this.onChanged,
  });
  final int amountMinor, tipMinor;
  final String currency;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    final preset = tipMinor == 0 || tipPercents.any((p) => tipFor(amountMinor, p) == tipMinor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(c.tr('Add a tip for the team?'), style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        // One sideways line on a phone, so every choice stays a 48px target.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppChip(
                label: c.tr('No tip'),
                selected: tipMinor == 0,
                onSelected: () => onChanged(0),
              ),
              for (final p in tipPercents) ...[
                const SizedBox(width: 8),
                AppChip(
                  label: '$p% · ${money(tipFor(amountMinor, p), currency)}',
                  selected: tipMinor != 0 && tipFor(amountMinor, p) == tipMinor,
                  onSelected: () => onChanged(tipFor(amountMinor, p)),
                ),
              ],
              const SizedBox(width: 8),
              AppChip(
                label: preset
                    ? c.tr('Other')
                    : '${c.tr('Other')} · ${money(tipMinor, currency)}',
                selected: !preset,
                onSelected: () async {
                  final form = await editFields(c, c.tr('Add a tip for the team?'), [
                    InputSpec('tipMinor', c.tr('Tip'), kind: 'money'),
                  ], initial: {
                    'tipMinor': preset ? null : tipMinor,
                  }, submit: c.tr('Add tip'));
                  final chosen = (form?['tipMinor'] as int?) ?? 0;
                  if (form != null) onChanged(chosen.clamp(0, amountMinor ~/ 2));
                },
              ),
            ],
          ),
        ),
        if (tipMinor > 0) ...[
          const SizedBox(height: 8),
          MoneyRow(c.tr('Tip'), money(tipMinor, currency)),
          MoneyRow(c.tr('Total'), money(amountMinor + tipMinor, currency), total: true),
        ],
      ],
    );
  }
}

/// A big first line for a card, with a quieter word beside it that moves
/// beneath when the card is narrow or the text is large.
Widget cardHeading(BuildContext c, String title, {String? aside}) {
  final theme = Theme.of(c);
  return Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 10,
    runSpacing: 4,
    children: [
      Text(
        title,
        style: theme.textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      if (aside != null)
        Text(
          aside,
          style: theme.textTheme.labelLarge!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
    ],
  );
}

/// An order or payment state as the diner reads it: a submitted order is
/// "Submitted" to them, where the staff boards call it "New".
String customerStatus(BuildContext c, String status) =>
    status == 'submitted' ? c.tr('Submitted') : statusLabel(c, status);

/// A payment or order state as a chip: green once paid, amber while it waits,
/// red when it stopped. The word always comes with the color.
Widget statePill(BuildContext c, String state) {
  final theme = Theme.of(c);
  final colors = theme.extension<AppStatusColors>();
  final (icon, color) = switch (state) {
    'paid' || 'completed' => (Icons.check_circle_outline, colors?.success),
    'refunded' || 'partiallyRefunded' => (Icons.undo, null),
    'failed' ||
    'cancelled' ||
    'rejected' ||
    'released' ||
    'reversed' => (Icons.error_outline, theme.colorScheme.errorContainer),
    _ => (Icons.schedule, colors?.warning),
  };
  return AppPill(label: customerStatus(c, state), icon: icon, color: color);
}

/// The edge color of a payment card, matching its chip.
Color paymentAccent(String state) => switch (state) {
  'paid' || 'completed' => AppColors.forest,
  'refunded' || 'partiallyRefunded' => AppColors.line,
  'failed' || 'cancelled' || 'released' || 'reversed' => AppColors.error,
  _ => const Color(0xFFE2B04A),
};

/// "Pickup at 12:30", with the day when it is not today.
String pickupLabel(BuildContext c, Object? slot) {
  final at = DateTime.tryParse('${slot ?? ''}')?.toLocal();
  if (at == null) return c.tr('Pickup as soon as it is ready');
  final l = MaterialLocalizations.of(c);
  final now = DateTime.now();
  final today =
      at.year == now.year && at.month == now.month && at.day == now.day;
  final time = l.formatTimeOfDay(TimeOfDay.fromDateTime(at));
  return '${c.tr('Pickup at')} ${today ? '' : '${l.formatShortMonthDay(at)}, '}$time';
}

/// A priced line's amount, or nothing when the line carries no price.
String? lineTotal(Json line, String currency) {
  final unit = line['unitPriceMinor'] as num?;
  final quantity = line['quantity'] as num?;
  if (unit == null || quantity == null) return null;
  return money(unit * quantity, currency);
}

/// The lime strip the counter reads at handover, as on the staff cards.
Widget pickupCodeStrip(BuildContext c, String code) {
  final theme = Theme.of(c);
  return Align(
    alignment: AlignmentDirectional.centerStart,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.key_outlined, size: 18, color: AppColors.forest),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${c.tr('Pickup code')} $code',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
