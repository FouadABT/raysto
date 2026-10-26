import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../domain/domain.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import '../operations/operations.dart' show openOperation;

String roleTitle(DemoRole role) => switch (role) {
  DemoRole.guest => 'Guest',
  DemoRole.customer => 'Customer',
  DemoRole.owner => 'Owner',
  DemoRole.manager => 'Manager',
  DemoRole.waiter => 'Waiter',
  DemoRole.kitchen => 'Kitchen',
  DemoRole.courier => 'Courier',
};

class EntryScreen extends StatefulWidget {
  const EntryScreen({
    super.key,
    required this.store,
    this.onComplete,
    this.onlineAccountBuilder,
  });
  final DemoStore store;
  final VoidCallback? onComplete;
  final WidgetBuilder? onlineAccountBuilder;
  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  bool _onboarding = false;
  @override
  void initState() {
    super.initState();
    _onboarding =
        widget.store.sessionActive &&
        !widget.store.currentAccount.onboardingComplete &&
        widget.store.currentAccount.role != DemoRole.guest;
  }

  Future<void> _entered() async {
    if (!widget.store.currentAccount.onboardingComplete &&
        widget.store.currentAccount.role != DemoRole.guest) {
      setState(() => _onboarding = true);
    } else {
      widget.onComplete?.call();
    }
  }

  Future<void> _accounts({bool business = false}) async {
    final chosen = await openPage<bool>(
      context,
      AccountChooserScreen(store: widget.store, businessOnly: business),
    );
    if (chosen == true && mounted) _entered();
  }

  @override
  Widget build(BuildContext context) {
    if (_onboarding) {
      return OnboardingScreen(
        store: widget.store,
        onComplete: widget.onComplete,
      );
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                const RaystoWordmark(),
                const Spacer(),
                IconButton(
                  tooltip: context.tr('Language and appearance'),
                  onPressed: () => openPage(
                    context,
                    LanguageAppearanceScreen(store: widget.store),
                  ),
                  icon: const Icon(Icons.language),
                ),
              ],
            ),
            const SizedBox(height: 24),
            RaystoStoryHeader(
              eyebrow: context.tr('Welcome to Raysto'),
              title: context.tr('Good food. Your way.'),
              message: context.tr(
                'Discover local tables, order a favourite, and enjoy every moment.',
              ),
              tableArt: true,
            ),
            const SizedBox(height: 24),
            if (widget.onlineAccountBuilder != null) ...[
              AppButton(
                label: context.tr('Use my Raysto account'),
                icon: Icons.person_outline,
                onPressed: () =>
                    openPage(context, widget.onlineAccountBuilder!(context)),
              ),
              const SizedBox(height: 10),
            ],
            AppButton(
              label: context.tr('Explore demo accounts'),
              secondary: widget.onlineAccountBuilder != null,
              icon: Icons.people_outline,
              onPressed: _accounts,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: context.tr('Continue as guest'),
              secondary: true,
              onPressed: () {
                widget.store.switchAccount('guest');
                widget.onComplete?.call();
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () async {
                    final result = await openPage<bool>(
                      context,
                      DemoAuthScreen(store: widget.store),
                    );
                    if (result == true && mounted) _entered();
                  },
                  child: Text(
                    context.tr(
                      widget.onlineAccountBuilder == null
                          ? 'Sign in'
                          : 'Practice sign-in',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _accounts(business: true),
                  child: Text(
                    context.tr(
                      widget.onlineAccountBuilder == null
                          ? 'For restaurants'
                          : 'Practice restaurant roles',
                    ),
                  ),
                ),
              ],
            ),
            AppNotice(
              title: context.tr(
                widget.onlineAccountBuilder == null
                    ? 'Local demo only'
                    : 'About the demo',
              ),
              message: context.tr(
                widget.onlineAccountBuilder == null
                    ? 'No real account, email, or payment is created.'
                    : 'Demo accounts and guest exploration use sample data stored on this device.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountChooserScreen extends StatelessWidget {
  const AccountChooserScreen({
    super.key,
    required this.store,
    this.businessOnly = false,
  });
  final DemoStore store;
  final bool businessOnly;
  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Choose an account',
    children: [
      AppNotice(
        title: context.tr('Local demo only'),
        message: context.l(
          'All accounts share restaurant activity on this installation. Private carts and preferences stay separate.',
          'Les comptes partagent l’activité de cette installation. Paniers et préférences restent privés.',
          'تشارك الحسابات نشاط المطعم على هذا الجهاز. تبقى السلال والتفضيلات منفصلة.',
        ),
      ),
      ...store.accounts
          .where((a) => a.active && (!businessOnly || a.isStaff))
          .map(
            (account) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  account.isStaff ? Icons.badge_outlined : Icons.person_outline,
                ),
                title: Text(account.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.email, textDirection: TextDirection.ltr),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr(roleTitle(account.role))} · ${account.restaurantId == 'harbor'
                          ? 'Harbor Cafe'
                          : account.isStaff
                          ? 'Olive Kitchen'
                          : account.id == 'diner'
                          ? 'Table 06'
                          : context.tr(account.onboardingComplete ? 'Ready to explore' : 'New customer')}',
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => guarded(context, () {
                  store.switchAccount(account.id);
                  Navigator.pop(context, true);
                }),
              ),
            ),
          ),
      SelectableText(
        context.l(
          'Shared demo password: RaystoDemo123!\nVerification code: 123456',
          'Mot de passe démo : RaystoDemo123!\nCode : 123456',
          'كلمة المرور التجريبية: RaystoDemo123!\nرمز التحقق: 123456',
        ),
      ),
    ],
  );
}

class DemoAuthScreen extends StatefulWidget {
  const DemoAuthScreen({super.key, required this.store, this.create = false});
  final DemoStore store;
  final bool create;
  @override
  State<DemoAuthScreen> createState() => _DemoAuthScreenState();
}

class _DemoAuthScreenState extends State<DemoAuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController();
  bool _visible = false, _busy = false, _saved = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final generation = widget.store.generation;
    try {
      await widget.store.simulateViewDelay();
      if (!mounted || generation != widget.store.generation) return;
      if (widget.create) {
        final verified = await openPage<bool>(
          context,
          VerificationScreen(store: widget.store),
        );
        if (!mounted || verified != true) return;
        widget.store.createAccount(
          _name.text.trim(),
          _email.text.trim(),
          _password.text,
        );
      } else {
        widget.store.signIn(_email.text.trim(), _password.text);
      }
      if (mounted) {
        setState(() => _saved = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => DraftGuard(
    dirty:
        !_saved &&
        widget.create &&
        (_name.text.isNotEmpty || _email.text.isNotEmpty),
    child: MobilePage(
      title: widget.create ? 'Create account' : 'Sign in',
      children: [
        AppNotice(
          title: context.tr('Local demo only'),
          message: context.tr('No real account, email, or payment is created.'),
        ),
        Form(
          key: _form,
          child: Column(
            children: [
              if (widget.create) ...[
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: context.tr('Name')),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v ?? '').trim().length < 2
                      ? context.tr('Enter your name.')
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: context.tr('Email')),
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v ?? '')
                    ? null
                    : context.tr('Enter a valid email address.'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: !_visible,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: context.tr('Password'),
                  suffixIcon: IconButton(
                    tooltip: context.tr(
                      _visible ? 'Hide password' : 'Show password',
                    ),
                    onPressed: () => setState(() => _visible = !_visible),
                    icon: Icon(
                      _visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (v) => (v ?? '').length < 8
                    ? context.tr('Use at least 8 characters.')
                    : null,
              ),
            ],
          ),
        ),
        if (_error != null)
          AppNotice(
            title: context.tr('Retry'),
            message: _error,
            icon: Icons.error_outline,
          ),
        AppButton(
          label: context.tr(widget.create ? 'Create account' : 'Sign in'),
          busy: _busy,
          onPressed: _submit,
        ),
        if (!widget.create) ...[
          TextButton(
            onPressed: () =>
                openPage(context, RecoveryScreen(store: widget.store)),
            child: Text(context.tr('Forgot password?')),
          ),
          OutlinedButton(
            onPressed: () async {
              final result = await openPage<bool>(
                context,
                DemoAuthScreen(store: widget.store, create: true),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: Text(context.tr('Create account')),
          ),
        ],
        const SelectableText('customer@raysto.test\nRaystoDemo123!'),
      ],
    ),
  );
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _code = TextEditingController();
  Timer? _countdown;
  int _seconds = 30;
  late DateTime _expires;
  String? _error;
  @override
  void initState() {
    super.initState();
    _expires = widget.store.now.add(const Duration(minutes: 5));
    _start();
  }

  void _start() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _seconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Verify your demo account',
    children: [
      AppNotice(
        title: context.tr('Demo verification code: 123456'),
        message: context.l(
          'No message was sent. This code verifies this local demonstration only.',
          'Aucun message envoyé. Ce code vérifie uniquement cette démo locale.',
          'لم تُرسل رسالة. هذا الرمز للتحقق من التجربة المحلية فقط.',
        ),
      ),
      TextField(
        controller: _code,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: context.tr('Verification code'),
          errorText: _error,
        ),
      ),
      AppButton(
        label: context.tr('Verify'),
        onPressed: () {
          if (widget.store.now.isAfter(_expires)) {
            setState(
              () => _error = context.tr(
                'Code expired. Request another demo code.',
              ),
            );
          } else if (_code.text != '123456') {
            setState(() => _error = context.tr('Wrong code. Try 123456.'));
          } else {
            Navigator.pop(context, true);
          }
        },
      ),
      OutlinedButton(
        onPressed: _seconds == 0
            ? () {
                setState(() {
                  _seconds = 30;
                  _error = null;
                  _expires = widget.store.now.add(const Duration(minutes: 5));
                });
                _start();
              }
            : null,
        child: Text(
          '${context.tr('Resend demo code')}${_seconds > 0 ? ' ($_seconds)' : ''}',
        ),
      ),
      TextButton(
        onPressed: () {
          widget.store.advanceTime(const Duration(minutes: 6));
          setState(
            () =>
                _error = context.tr('Code expired. Request another demo code.'),
          );
        },
        child: Text(
          context.l(
            'Simulate expired code',
            'Simuler un code expiré',
            'محاكاة انتهاء صلاحية الرمز',
          ),
        ),
      ),
    ],
  );
}

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _email = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _complete = false;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Reset password',
    children: [
      if (_complete) ...[
        AppNotice(
          title: context.tr('Reset password'),
          message: context.tr(
            'Reset simulated. No email was sent. Use the displayed demo password.',
          ),
        ),
        const SelectableText('RaystoDemo123!'),
        AppButton(
          label: context.tr('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ] else ...[
        Form(
          key: _form,
          child: TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: context.tr('Email')),
            validator: (v) =>
                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v ?? '')
                ? null
                : context.tr('Enter a valid email address.'),
          ),
        ),
        AppButton(
          label: context.tr('Show local reset confirmation'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              setState(() => _complete = true);
            }
          },
        ),
      ],
    ],
  );
}

class LanguageAppearanceScreen extends StatelessWidget {
  const LanguageAppearanceScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Language and appearance',
      children: [LanguageAppearanceControls(store: store)],
    ),
  );
}

class LanguageAppearanceControls extends StatelessWidget {
  const LanguageAppearanceControls({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.tr('Language'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [('en', 'English'), ('fr', 'Français'), ('ar', 'العربية')]
            .map(
              (v) => ChoiceChip(
                label: Text(v.$2),
                selected: store.settings.locale == v.$1,
                onSelected: (_) => store.updateSettings(locale: v.$1),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      Text(
        context.tr('Appearance'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [('system', 'System'), ('light', 'Light'), ('dark', 'Dark')]
            .map(
              (v) => ChoiceChip(
                label: Text(context.tr(v.$2)),
                selected: store.settings.appearance == v.$1,
                onSelected: (_) => store.updateSettings(appearance: v.$1),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      AppPanel(
        child: Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.tr('Good food. Your way.'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class PermissionControls extends StatelessWidget {
  const PermissionControls({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppNotice(
        title: context.tr('Permissions, on your terms'),
        message: context.tr(
          'These switches simulate permission states. They do not grant device access.',
        ),
      ),
      ...[
        (
          'location',
          'Location',
          'Use a manual address',
          Icons.location_on_outlined,
        ),
        (
          'camera',
          'Camera',
          'Use a demo code or manual entry',
          Icons.qr_code_scanner,
        ),
        (
          'notifications',
          'Notifications',
          'In-app notifications remain available',
          Icons.notifications_outlined,
        ),
      ].map(
        (p) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(p.$4),
                title: Text(context.tr(p.$2)),
                subtitle: Text(context.tr(p.$3)),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          ('allowed', 'Simulated allowed'),
                          ('denied', 'Simulated denied'),
                          ('notAsked', 'Not simulated'),
                        ]
                        .map(
                          (s) => ChoiceChip(
                            label: Text(context.tr(s.$2)),
                            selected: store.settings.permissions[p.$1] == s.$1,
                            onSelected: (_) => store.setPermission(p.$1, s.$1),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.store, this.onComplete});
  final DemoStore store;
  final VoidCallback? onComplete;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int _step;
  late final TextEditingController _name;
  late final DemoStore _practiceWorld;
  final _chat = TextEditingController();
  bool _guided = false;
  String? _reply;
  @override
  void initState() {
    super.initState();
    _step = widget.store.currentAccount.onboardingStep.clamp(0, 3);
    _name = TextEditingController(text: widget.store.currentAccount.name);
    _practiceWorld = DemoStore(persistence: MemoryDemoPersistence());
    final role = widget.store.currentAccount.role;
    _practiceWorld.switchAccount(switch (role) {
      DemoRole.waiter => 'waiter',
      DemoRole.kitchen => 'kitchen',
      DemoRole.courier => 'courier',
      _ => 'owner',
    });
  }

  @override
  void dispose() {
    _practiceWorld.dispose();
    _name.dispose();
    _chat.dispose();
    super.dispose();
  }

  void _move(int value) {
    if (_name.text.trim().length >= 2) {
      widget.store.updateProfile(name: _name.text.trim());
    }
    setState(() => _step = value.clamp(0, 3));
    widget.store.updateOnboardingStep(_step);
  }

  void _finish() {
    widget.store.completeOnboarding();
    widget.onComplete?.call();
  }

  Widget _choices(List<String> choices) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: choices
        .map(
          (label) => FilterChip(
            label: Text(context.tr(label)),
            selected: widget.store.currentAccount.preferences[label] ?? false,
            onSelected: (selected) =>
                widget.store.setPreference(label, selected),
          ),
        )
        .toList(),
  );
  void _guide() {
    final query = _chat.text.toLowerCase();
    final recognized = <String>[];
    if (RegExp('veget|نبات').hasMatch(query)) recognized.add('Vegetarian');
    if (RegExp('family|famille|عائل').hasMatch(query)) {
      recognized.add('Family meals');
    }
    if (RegExp('quick|rapide|سريع').hasMatch(query)) {
      recognized.add('Quick lunches');
    }
    if (RegExp('mediter|متوسط').hasMatch(query)) {
      recognized.add('Mediterranean');
    }
    for (final key in recognized) {
      widget.store.setPreference(key, true);
    }
    setState(
      () => _reply = recognized.isEmpty
          ? context.l(
              'I can help with vegetarian meals, family meals, quick lunches, or Mediterranean food. Choose a suggestion below; nothing is required.',
              'Je peux vous aider pour les repas végétariens, en famille, rapides ou méditerranéens. Choisissez une suggestion ; tout est facultatif.',
              'أستطيع المساعدة في الوجبات النباتية والعائلية والسريعة والمتوسطية. اختر اقتراحاً أدناه؛ كل الخيارات اختيارية.',
            )
          : '${context.l('Added to your editable preferences:', 'Ajouté à vos préférences modifiables :', 'تمت الإضافة إلى تفضيلاتك القابلة للتعديل:')} ${recognized.map(context.tr).join(', ')}',
    );
    _chat.clear();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final staff = widget.store.currentAccount.isStaff;
      final content = switch (_step) {
        0 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Your Raysto, your preferences'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('A few optional choices help shape your discovery.'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: context.tr('Name')),
            ),
            const SizedBox(height: 24),
            LanguageAppearanceControls(store: widget.store),
          ],
        ),
        1 when staff => _staffStep(context),
        1 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('What sounds good?'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(context.tr('Quick setup')),
                  selected: !_guided,
                  onSelected: (_) => setState(() => _guided = false),
                ),
                ChoiceChip(
                  label: Text(context.tr('Guide me')),
                  selected: _guided,
                  onSelected: (_) => setState(() => _guided = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_guided) ...[
              AppNotice(
                title: context.l(
                  'Local guided setup',
                  'Guide local',
                  'إعداد محلي موجه',
                ),
                message:
                    _reply ??
                    context.l(
                      'Tell me what you enjoy. Try “vegetarian and quick lunches”.',
                      'Dites-moi vos envies. Essayez « végétarien et rapide ».',
                      'أخبرني بما تحب. جرب «نباتي وغداء سريع».',
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _chat,
                decoration: InputDecoration(
                  labelText: context.tr('Your message'),
                ),
                onSubmitted: (_) => _guide(),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _guide,
                child: Text(context.tr('Send locally')),
              ),
              const SizedBox(height: 16),
            ],
            _choices([
              'Vegetarian',
              'Mediterranean',
              'Comfort food',
              'Quick lunches',
              'Family meals',
            ]),
            const SizedBox(height: 24),
            Text(
              context.tr('Choose how you like to order'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _choices(['Dine in', 'Pickup', 'Delivery']),
            const SizedBox(height: 24),
            Text(
              context.tr(
                'Dietary information is provided by each demo menu. Ask staff about allergies.',
              ),
            ),
          ],
        ),
        2 => PermissionControls(store: widget.store),
        _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Your preferences at a glance'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.store.currentAccount.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(context.tr(roleTitle(widget.store.currentAccount.role))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.store.currentAccount.preferences.entries
                        .where((e) => e.value)
                        .map(
                          (e) => InputChip(
                            label: Text(context.tr(e.key)),
                            onDeleted: () =>
                                widget.store.setPreference(e.key, false),
                          ),
                        )
                        .toList(),
                  ),
                  TextButton(
                    onPressed: () => _move(1),
                    child: Text(context.tr('Edit')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppMedia(
              asset: widget.store.currentRestaurant.cover,
              semanticLabel: widget.store.currentRestaurant.name,
            ),
            const SizedBox(height: 16),
            Text(
              widget.store.currentRestaurant.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              staff
                  ? context.l(
                      'Your workspace is ready. Continue with the real setup checklist and operational screens.',
                      'Votre espace est prêt. Continuez avec la configuration et les écrans opérationnels.',
                      'مساحة عملك جاهزة. تابع إلى قائمة الإعداد وشاشات العمليات.',
                    )
                  : context.l(
                      'A fresh menu to explore, shaped by your choices. Preferences can always be changed.',
                      'Un menu à découvrir selon vos choix. Vos préférences restent modifiables.',
                      'قائمة جديدة للاستكشاف حسب خياراتك. يمكنك تعديل التفضيلات دائماً.',
                    ),
            ),
          ],
        ),
      };
      return Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(staff ? 'Your workspace' : 'Welcome to Raysto'),
          ),
          leading: _step > 0
              ? IconButton(
                  tooltip: context.tr('Back'),
                  onPressed: () => _move(_step - 1),
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
          actions: [
            TextButton(onPressed: _finish, child: Text(context.tr('Skip'))),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppProgress(value: (_step + 1) / 4, label: '${_step + 1} / 4'),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: AppMotion.reduced(context)
                    ? Duration.zero
                    : AppMotion.branch,
                switchInCurve: AppMotion.spatial,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    for (final child in previous)
                      IgnorePointer(
                        child: ExcludeFocus(
                          child: ExcludeSemantics(
                            child: TickerMode(enabled: false, child: child),
                          ),
                        ),
                      ),
                    ?current,
                  ],
                ),
                child: KeyedSubtree(key: ValueKey(_step), child: content),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: context.tr(_step == 3 ? 'Ready to explore' : 'Continue'),
                onPressed: _step == 3 ? _finish : () => _move(_step + 1),
              ),
            ],
          ),
        ),
      );
    },
  );
  Widget _staffStep(BuildContext context) {
    final role = widget.store.currentAccount.role;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('Your workspace'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        AppNotice(
          title: widget.store.currentRestaurant.name,
          message: '${context.tr('Your role')}: ${context.tr(roleTitle(role))}',
        ),
        if (widget.store.currentAccount.workspaceIds.length > 1) ...[
          const SizedBox(height: 16),
          for (final restaurant in widget.store.restaurants.where(
            (r) => widget.store.currentAccount.hasRestaurantAccess(r.id),
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppChoice(
                title: restaurant.name,
                selected: restaurant.id == widget.store.currentRestaurant.id,
                onTap: () => widget.store.selectRestaurant(restaurant.id),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Text(
          context.l(
            'Use the role navigation to find work, open a record for details, and confirm changes. Only permitted actions are available.',
            'La navigation de votre rôle permet de trouver le travail, consulter les détails et confirmer les changements. Seules les actions autorisées sont proposées.',
            'استخدم التنقل الخاص بدورك للعثور على المهام وفتح تفاصيلها وتأكيد التغييرات. تظهر الإجراءات المسموح بها فقط.',
          ),
        ),
        const SizedBox(height: 24),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr(
                  [DemoRole.owner, DemoRole.manager].contains(role)
                      ? 'Setup checklist'
                      : 'Practice task',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                [DemoRole.owner, DemoRole.manager].contains(role)
                    ? context.l(
                        'Open each setup task, save your changes, and return here to continue. The customer preview reflects your saved restaurant.',
                        'Ouvrez chaque étape, enregistrez vos modifications et revenez ici. L’aperçu client reflète votre restaurant enregistré.',
                        'افتح كل مهمة إعداد واحفظ التغييرات ثم عُد للمتابعة. تعكس معاينة العميل إعدادات المطعم المحفوظة.',
                      )
                    : context.tr(
                        'Practice uses separate sample data. Restaurant records are unchanged.',
                      ),
              ),
              const SizedBox(height: 16),
              if ([
                DemoRole.waiter,
                DemoRole.kitchen,
                DemoRole.courier,
              ].contains(role))
                _practiceRecord(context, role)
              else
                AppButton(
                  label: context.tr('Open setup checklist'),
                  secondary: true,
                  onPressed: () =>
                      openOperation(context, widget.store, 'setup'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l(
            'Setup tasks: restaurant identity, services and hours, menu, tables, payment policy, storefront preview.',
            'Configuration : identité, services et horaires, menu, tables, paiement et aperçu de la vitrine.',
            'مهام الإعداد: هوية المطعم والخدمات والمواعيد والقائمة والطاولات وسياسة الدفع ومعاينة الواجهة.',
          ),
        ),
      ],
    );
  }

  Widget _practiceRecord(BuildContext context, DemoRole role) {
    final request = _practiceWorld.requests.firstWhere(
      (r) => r.id == 'request-water',
    );
    final order = _practiceWorld.orders.firstWhere(
      (o) => o.id == 'order-kitchen',
    );
    final delivery = _practiceWorld.deliveries.firstWhere(
      (d) => d.id == 'delivery-ready',
    );
    final done = switch (role) {
      DemoRole.waiter => request.status == RequestStatus.completed,
      DemoRole.kitchen => order.status == OrderStatus.ready,
      _ => delivery.status == DeliveryStatus.delivered,
    };
    final status = switch (role) {
      DemoRole.waiter => request.status.name,
      DemoRole.kitchen => order.status.name,
      _ => delivery.status.name,
    };
    final label = switch (role) {
      DemoRole.waiter =>
        request.status == RequestStatus.sent
            ? 'Acknowledge water request'
            : 'Mark completed',
      DemoRole.kitchen => 'Mark practice ticket ready',
      _ => switch (delivery.status) {
        DeliveryStatus.assigned => 'Confirm pickup',
        DeliveryStatus.collected => 'Start delivery',
        _ => 'Confirm delivered',
      },
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(switch (role) {
          DemoRole.waiter => context.l(
            'Practice · Table 02 · Water for two',
            'Exercice · Table 02 · Eau pour deux',
            'تدريب · الطاولة 02 · ماء لشخصين',
          ),
          DemoRole.kitchen => context.l(
            'Practice ticket · Table 02 · 1 pizza',
            'Ticket d’exercice · Table 02 · 1 pizza',
            'تذكرة تدريب · الطاولة 02 · بيتزا واحدة',
          ),
          _ => context.l(
            'Practice delivery · 18 Olive Lane · one package',
            'Livraison d’exercice · 18 Olive Lane · un colis',
            'توصيل تدريبي · 18 Olive Lane · طرد واحد',
          ),
        }),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: StatusBadge(
            done ? 'Practice complete' : status,
            icon: done ? Icons.check_circle_outline : Icons.hourglass_empty,
          ),
        ),
        if (!done) ...[
          const SizedBox(height: 16),
          AppButton(
            label: context.tr(label),
            secondary: true,
            onPressed: () => guarded(context, () {
              switch (role) {
                case DemoRole.waiter:
                  _practiceWorld.transitionRequest(
                    request.id,
                    request.status == RequestStatus.sent
                        ? RequestStatus.acknowledged
                        : RequestStatus.completed,
                  );
                case DemoRole.kitchen:
                  for (final line in order.lines) {
                    _practiceWorld.completeOrderItem(order.id, line.id, true);
                  }
                  _practiceWorld.transitionOrder(order.id, OrderStatus.ready);
                case DemoRole.courier:
                  _practiceWorld.progressDelivery(
                    delivery.id,
                    switch (delivery.status) {
                      DeliveryStatus.assigned => DeliveryStatus.collected,
                      DeliveryStatus.collected => DeliveryStatus.outForDelivery,
                      _ => DeliveryStatus.delivered,
                    },
                  );
                default:
                  break;
              }
              setState(() {});
            }),
          ),
        ],
      ],
    );
  }
}

class AccessStateScreen extends StatelessWidget {
  const AccessStateScreen({
    super.key,
    required this.store,
    this.state = 'Access denied',
    this.onRecover,
  });
  final DemoStore store;
  final String state;
  final VoidCallback? onRecover;
  @override
  Widget build(BuildContext context) => MobilePage(
    title: state,
    children: [
      EmptyState(
        title: state,
        message: state == 'Access denied'
            ? 'This account does not have access to this workspace.'
            : 'Your local demo can be restored or restarted.',
        icon: Icons.lock_outline,
        action: AppButton(
          label: context.tr('Explore demo accounts'),
          onPressed: () async {
            await openPage(context, AccountChooserScreen(store: store));
            onRecover?.call();
          },
        ),
      ),
    ],
  );
}
