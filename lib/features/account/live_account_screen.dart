import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raysto_client/raysto_client.dart' as api;

import '../../backend/auth/session_controller.dart';
import '../../backend/live_runtime.dart';
import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import '../payments/connected_payments_screen.dart';
import '../payments/sandbox_test_screen.dart';
import '../connected/connected_app.dart';
import '../connected/security.dart';

/// Live identities and API records never enter the local DemoStore.
class LiveAccountScreen extends StatefulWidget {
  const LiveAccountScreen({
    super.key,
    required this.runtime,
    this.paymentReturn,
    this.openSandboxTest = false,
  });
  final LiveRuntime runtime;
  final Uri? paymentReturn;
  final bool openSandboxTest;
  @override
  State<LiveAccountScreen> createState() => _LiveAccountScreenState();
}

class _LiveAccountScreenState extends State<LiveAccountScreen> {
  late final SessionController _session;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _creating = false;
  bool _obscure = true;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _session = widget.runtime.createSession();
    widget.runtime.resolveMultiFactor = (e) => resolveFactor(context, e);
    if (_session.phase == SessionPhase.starting) {
      unawaited(_session.initialize());
    }
  }

  @override
  void dispose() {
    widget.runtime.resolveMultiFactor = null;
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_creating) {
      await _session.createAccount(_email.text, _password.text);
    } else {
      await _session.signIn(_email.text, _password.text);
    }
    if (mounted) _password.clear();
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await _session.signOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session,
    builder: (context, _) {
      if (_session.phase == SessionPhase.ready) {
        if (widget.openSandboxTest) {
          return SandboxTestScreen(
            runtime: widget.runtime,
            callback: widget.paymentReturn,
          );
        }
        if (widget.paymentReturn != null) {
          final callback = widget.paymentReturn!;
          if (callback.queryParameters['v'] == '2') {
            final checkout = int.tryParse(
              callback.queryParameters['checkoutId'] ?? '',
            );
            final tenant = int.tryParse(
              callback.queryParameters['restaurantId'] ?? '',
            );
            if (checkout != null &&
                tenant != null &&
                checkout > 0 &&
                tenant > 0) {
              return checkoutPage(
                LiveContext(widget.runtime, restaurantId: tenant),
                checkout,
              );
            }
          }
          return PaymentReturnScreen(
            runtime: widget.runtime,
            callback: widget.paymentReturn!,
          );
        }
        return ConnectedApp(
          key: ValueKey(_session.userId),
          runtime: widget.runtime,
          onSignOut: _signOut,
        );
      }
      final verification = _session.phase == SessionPhase.verificationRequired;
      return MobilePage(
        title: verification
            ? 'Check your email'
            : (_creating ? 'Create account' : 'Sign in'),
        children: [
          if (_session.phase == SessionPhase.starting ||
              _session.phase == SessionPhase.connecting)
            const LinearProgressIndicator(),
          if (_session.message != null)
            AppNotice(
              title: context.tr('Connection needs attention'),
              message: context.tr(_session.message!),
            ),
          if (verification) ...[
            const Icon(Icons.mark_email_unread_outlined, size: 48),
            Text(
              context.tr(
                'Open the verification link in your email, then return here.',
              ),
            ),
            AppButton(
              label: context.tr('I have verified my email'),
              busy: _session.busy,
              onPressed: _session.retry,
            ),
            OutlinedButton(
              onPressed: _session.busy ? null : _session.sendVerification,
              child: Text(context.tr('Resend verification email')),
            ),
            TextButton(
              onPressed: _signingOut ? null : _signOut,
              child: Text(context.tr('Use another account')),
            ),
          ] else ...[
            RaystoStoryHeader(
              eyebrow: context.tr('Welcome to Raysto'),
              title: context.tr(
                _creating
                    ? 'There’s a place\nfor you here.'
                    : 'Good food.\nYour way.',
              ),
              message: context.tr(
                'Sign in to sync your account and orders across your devices.',
              ),
              tableArt: true,
              compact: true,
            ),
            OutlinedButton.icon(
              onPressed: _session.busy ? null : _session.signInWithGoogle,
              icon: const Icon(Icons.account_circle_outlined),
              label: Text(context.tr('Continue with Google')),
            ),
            AutofillGroup(
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      key: const ValueKey('sign-in-email'),
                      controller: _email,
                      textDirection: TextDirection.ltr,
                      enabled: !_session.busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.tr('Email'),
                      ),
                      validator: (value) =>
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(value?.trim() ?? '')
                          ? null
                          : context.tr('Enter a valid email address.'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      enabled: !_session.busy,
                      obscureText: _obscure,
                      autofillHints: [
                        _creating
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _session.busy ? null : _submit(),
                      decoration: InputDecoration(
                        labelText: context.tr('Password'),
                        suffixIcon: IconButton(
                          tooltip: context.tr(
                            _obscure ? 'Show password' : 'Hide password',
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value?.length ?? 0) >= (_creating ? 8 : 1)
                          ? null
                          : context.tr(
                              _creating
                                  ? 'Use at least 8 characters.'
                                  : 'Enter your password.',
                            ),
                    ),
                  ],
                ),
              ),
            ),
            AppButton(
              label: context.tr(_creating ? 'Create account' : 'Sign in'),
              busy: _session.busy,
              onPressed: _submit,
            ),
            OutlinedButton(
              onPressed: _session.busy ? null : _session.continueAsGuest,
              child: const Text('Continue as a guest'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/demo'),
              child: const Text('Explore the offline demo'),
            ),
            if (_session.phase == SessionPhase.failure &&
                widget.runtime.firebase.currentUser != null)
              OutlinedButton(
                onPressed: _session.busy ? null : _session.retry,
                child: Text(context.tr('Retry connection')),
              ),
            TextButton(
              onPressed: _session.busy
                  ? null
                  : () => setState(() => _creating = !_creating),
              child: Text(
                context.tr(
                  _creating
                      ? 'Already have an account? Sign in'
                      : 'Create an account',
                ),
              ),
            ),
            if (!_creating)
              TextButton(
                onPressed: _session.busy
                    ? null
                    : () async {
                        final email = _email.text.trim();
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          showMessage(context, 'Enter a valid email address.');
                          return;
                        }
                        await _session.resetPassword(email);
                        if (context.mounted &&
                            _session.phase != SessionPhase.failure) {
                          showMessage(
                            context,
                            'If this account exists, a password reset email has been sent.',
                          );
                        }
                      },
                child: Text(context.tr('Forgot password?')),
              ),
          ],
        ],
      );
    },
  );
}

class LiveWorkspace extends StatefulWidget {
  const LiveWorkspace({
    super.key,
    required this.runtime,
    required this.userId,
    required this.email,
    required this.onSignOut,
    required this.signingOut,
  });
  final LiveRuntime runtime;
  final String userId;
  final String email;
  final Future<void> Function() onSignOut;
  final bool signingOut;
  @override
  State<LiveWorkspace> createState() => _LiveWorkspaceState();
}

class _LiveWorkspaceState extends State<LiveWorkspace> {
  List<api.Restaurant>? _restaurants;
  List<api.PurchaseOrder>? _orders;
  bool _error = false;
  bool _loading = false;
  bool _notificationBusy = false;
  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final results = await Future.wait<Object>([
        widget.runtime.connection.client.catalog.restaurants(),
        widget.runtime.connection.client.commerce.myOrders(0),
      ]);
      if (mounted) {
        setState(() {
          _restaurants = results[0] as List<api.Restaurant>;
          _orders = results[1] as List<api.PurchaseOrder>;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    key: ValueKey(widget.userId),
    title: 'Your account',
    actions: [
      IconButton(
        tooltip: context.tr('Refresh'),
        onPressed: _loading ? null : _refresh,
        icon: const Icon(Icons.refresh),
      ),
    ],
    children: [
      AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(context.tr('Connected to your Raysto account')),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.signingOut ? null : widget.onSignOut,
              child: Text(context.tr('Sign out')),
            ),
          ],
        ),
      ),
      if (_loading) const LinearProgressIndicator(),
      if (_error)
        AppNotice(
          title: context.tr('Connection needs attention'),
          message: context.tr(
            'Your data could not be refreshed. Check your connection and retry.',
          ),
          action: AppButton(label: context.tr('Retry'), onPressed: _refresh),
        ),
      Section(
        title: 'Restaurants',
        child: Column(
          children: [
            if (_restaurants?.isEmpty ?? false)
              Text(
                context.tr(
                  'Restaurants will appear here when they are published.',
                ),
              ),
            for (final restaurant in _restaurants ?? <api.Restaurant>[])
              Card(
                child: ListTile(
                  title: Text(restaurant.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openPage(
                    context,
                    LiveMenuScreen(
                      runtime: widget.runtime,
                      restaurant: restaurant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      Section(
        title: 'Your orders',
        child: Column(
          children: [
            if (_orders?.isEmpty ?? false)
              Text(context.tr('You have no orders yet.')),
            for (final order in _orders ?? <api.PurchaseOrder>[])
              Card(
                child: ListTile(
                  title: Text('#${order.id} · ${context.tr(order.status)}'),
                  subtitle: Text(
                    '${(order.totalMinor / 100).toStringAsFixed(2)} ${order.currency} · ${context.tr(order.paymentStatus)}',
                  ),
                ),
              ),
          ],
        ),
      ),
      AppButton(
        label: context.tr('Test PayPal Sandbox'),
        icon: Icons.payment_outlined,
        onPressed: () =>
            openPage(context, SandboxTestScreen(runtime: widget.runtime)),
      ),
      AppButton(
        label: context.tr('PayPal Sandbox'),
        icon: Icons.account_balance_wallet_outlined,
        onPressed: () =>
            openPage(context, ConnectedPaymentsScreen(runtime: widget.runtime)),
      ),
      AppButton(
        label: context.tr('Enable order notifications'),
        secondary: true,
        busy: _notificationBusy,
        onPressed: () async {
          setState(() => _notificationBusy = true);
          try {
            await widget.runtime.enableNotifications();
            if (context.mounted) {
              showMessage(context, 'Order notifications enabled.');
            }
          } catch (_) {
            if (context.mounted) {
              showMessage(
                context,
                'Notifications are unavailable. You can try again later.',
              );
            }
          } finally {
            if (mounted) setState(() => _notificationBusy = false);
          }
        },
      ),
    ],
  );
}

class LiveMenuScreen extends StatefulWidget {
  const LiveMenuScreen({
    super.key,
    required this.runtime,
    required this.restaurant,
  });
  final LiveRuntime runtime;
  final api.Restaurant restaurant;
  @override
  State<LiveMenuScreen> createState() => _LiveMenuScreenState();
}

class _LiveMenuScreenState extends State<LiveMenuScreen> {
  late Future<List<api.MenuProduct>> _menu;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _menu = widget.runtime.connection.client.catalog.menu(
      widget.restaurant.id!,
    );
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    title: widget.restaurant.name,
    children: [
      FutureBuilder(
        future: _menu,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppNotice(
              title: context.tr('Connection needs attention'),
              action: AppButton(
                label: context.tr('Retry'),
                onPressed: () => setState(_load),
              ),
            );
          }
          if (!snapshot.hasData) return const LinearProgressIndicator();
          if (snapshot.data!.isEmpty) {
            return Text(
              context.tr('The menu is being prepared. Check back soon.'),
            );
          }
          return Column(
            children: [
              for (final product in snapshot.data!)
                Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.description),
                    trailing: Text(
                      '${(product.priceMinor / 100).toStringAsFixed(2)} ${widget.restaurant.currency}',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}
