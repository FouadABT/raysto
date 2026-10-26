import 'package:flutter/material.dart';

import '../../backend/live_runtime.dart';
import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import 'live_account_screen.dart';

/// Initializes Firebase only when the user chooses their real account.
class ConnectedAccountEntry extends StatefulWidget {
  const ConnectedAccountEntry({
    super.key,
    this.paymentReturn,
    this.openSandboxTest = false,
  });
  final Uri? paymentReturn;
  final bool openSandboxTest;
  @override
  State<ConnectedAccountEntry> createState() => _ConnectedAccountEntryState();
}

class _ConnectedAccountEntryState extends State<ConnectedAccountEntry> {
  late Future<LiveRuntime> _runtime;
  @override
  void initState() {
    super.initState();
    _runtime = LiveRuntime.shared();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _runtime,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return LiveAccountScreen(
          runtime: snapshot.data!,
          paymentReturn: widget.paymentReturn,
          openSandboxTest: widget.openSandboxTest,
        );
      }
      return MobilePage(
        title: 'Your Raysto account',
        children: [
          if (!snapshot.hasError) ...[
            const LinearProgressIndicator(),
            Text(context.tr('Preparing your secure connection…')),
          ] else
            AppNotice(
              title: context.tr('Account connection is unavailable'),
              message: context.tr(
                'Please try again later. You can still explore the demo.',
              ),
              action: AppButton(
                label: context.tr('Retry'),
                onPressed: () => setState(() {
                  _runtime = LiveRuntime.shared(retry: true);
                }),
              ),
            ),
        ],
      );
    },
  );
}
