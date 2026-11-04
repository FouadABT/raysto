part of 'connected_app.dart';

/// The café's PayPal account on the phone (stream S6), read-only: which
/// account the money goes through, what the café's own PayPal app can do,
/// and whether Connect with PayPal is available yet. The owner adds or
/// changes keys from the console on a computer, so a secret never passes
/// through the phone.
Widget paypalAccountPage(LiveContext live) => PayPalAccountPage(live: live);

String paypalModeLabel(String mode) => switch (mode) {
  'ownApp' => 'Your own PayPal app',
  'partner' => 'Connected with PayPal',
  'sharedSandbox' => 'Raysto\'s shared Sandbox account',
  _ => 'Not connected',
};

String paypalModeLine(String mode) => switch (mode) {
  'ownApp' => 'Payments, refunds and payouts go through your own PayPal app.',
  'partner' => 'Payments go to your PayPal account through Raysto\'s partner connection.',
  'sharedSandbox' => 'This demo café uses Raysto\'s shared Sandbox account.',
  _ => 'This café cannot take PayPal payments yet.',
};

/// The checklist in display order, with the words the phone shows.
const paypalFeatureLabels = {
  'orders': 'Take payments',
  'refunds': 'Refunds',
  'payouts': 'Payouts',
  'invoicing': 'Invoicing',
  'transactionSearch': 'Transaction Search',
  'disputes': 'Disputes',
};

String paypalFeatureWord(String state) => switch (state) {
  'enabled' => 'On',
  'notEnabled' => 'Not enabled in your PayPal app',
  'keysRejected' => 'PayPal refused the keys',
  'unknown' => 'Could not check',
  _ => 'Not checked yet',
};

String paypalWebhookWord(String state) => switch (state) {
  'registered' => 'PayPal tells Raysto about payments as they happen.',
  'failed' => 'Raysto could not add its webhook to the app.',
  _ => 'Not set up yet.',
};

class PayPalAccountPage extends StatefulWidget {
  const PayPalAccountPage({super.key, required this.live});
  final LiveContext live;
  @override
  State<PayPalAccountPage> createState() => _PayPalAccountPageState();
}

class _PayPalAccountPageState extends State<PayPalAccountPage> {
  Json? status;
  String? error;

  @override
  void initState() {
    super.initState();
    unawaited(load());
  }

  Future<void> load() async {
    try {
      final d = await widget.live.api.query('merchant.status', widget.live.params());
      if (mounted) setState(() => (status = d, error = null));
    } on PlatformFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = status;
    final own = obj(s?['ownApp']);
    final partner = obj(s?['partner']);
    final scheme = Theme.of(context).colorScheme;
    final features = {for (final f in records(own['features'])) '${f['name']}': '${f['state']}'};
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('PayPal account'))),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (error != null)
                RaystoEmptyState(title: context.tr('The PayPal account could not load'), message: error!)
              else if (s == null)
                const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.account_balance_outlined, color: scheme.primary),
                            Text(
                              context.tr(paypalModeLabel('${s['mode']}')),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (s['environment'] == 'sandbox')
                              Chip(label: Text(context.tr('PayPal Sandbox'))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(context.tr(paypalModeLine('${s['mode']}'))),
                      ],
                    ),
                  ),
                ),
                if (own.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(context.tr('Your own PayPal app'), style: Theme.of(context).textTheme.titleMedium),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('Client ID ending')),
                    subtitle: Text('••••${own['clientIdEnd']}'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('PayPal merchant ID')),
                    subtitle: Text(
                      own['merchantId'] is String
                          ? own['merchantId'] as String
                          : context.tr('Learned from your first payment'),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('Webhook')),
                    subtitle: Text(context.tr(paypalWebhookWord('${own['webhook']}'))),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    container: true,
                    label: context.tr('What the PayPal app can do'),
                    child: Column(
                      children: [
                        for (final e in paypalFeatureLabels.entries)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              features[e.key] == 'enabled'
                                  ? Icons.check_circle_outline
                                  : features[e.key] == 'notEnabled'
                                  ? Icons.cancel_outlined
                                  : Icons.help_outline,
                              color: features[e.key] == 'enabled' ? scheme.primary : scheme.error,
                            ),
                            title: Text(context.tr(e.value)),
                            subtitle: Text(context.tr(paypalFeatureWord(features[e.key] ?? 'unchecked'))),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(context.tr('Connect with PayPal'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  partner['status'] == 'ready'
                      ? '${context.tr('Connected with PayPal')}: ${partner['merchantId']}'
                      : partner['note'] is String
                      ? context.tr(partner['note'] as String)
                      : context.tr('Not connected'),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr(
                    'The owner adds or changes PayPal app keys from the console on a computer; they never pass through the phone.',
                  ),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
