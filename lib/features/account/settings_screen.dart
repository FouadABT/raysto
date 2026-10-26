import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../demo/gallery/gallery_screen.dart';
import '../../domain/domain.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import 'entry_screen.dart';
import 'connected_account_entry.dart';
import '../payments/payment_lab_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store, this.embedded = false});
  final DemoStore store;
  final bool embedded;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final account = store.currentAccount;
      Widget tile(
        String title,
        IconData icon,
        Widget page, {
        String? subtitle,
      }) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Icon(icon),
        title: Text(context.tr(title)),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openPage(context, page),
      );
      return MobilePage(
        title: 'Profile',
        embedded: embedded,
        children: [
          if (store.persistenceError != null)
            AppNotice(
              title: context.l(
                'Local save needs attention',
                'Enregistrement local à vérifier',
                'الحفظ المحلي يحتاج إلى مراجعة',
              ),
              message: context.tr(store.persistenceError!),
              action: AppButton(
                label: context.tr('Retry'),
                onPressed: () => guarded(context, store.retryPersistence),
              ),
            ),
          if (store.restorationNotice != null)
            AppNotice(
              title: context.l(
                'Local restoration',
                'Restauration locale',
                'الاستعادة المحلية',
              ),
              message: context.tr(store.restorationNotice!),
            ),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(account.avatar),
                ),
                const SizedBox(height: 16),
                Text(
                  account.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(account.email, textDirection: TextDirection.ltr),
                const SizedBox(height: 10),
                StatusBadge(
                  roleTitle(account.role),
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
          ),
          AppPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                tile(
                  'Use my Raysto account',
                  Icons.cloud_outlined,
                  const ConnectedAccountEntry(),
                ),
                tile(
                  'Test PayPal Sandbox',
                  Icons.payment_outlined,
                  const ConnectedAccountEntry(openSandboxTest: true),
                ),
                tile(
                  'Edit profile',
                  Icons.person_outline,
                  ProfileEditorScreen(store: store),
                ),
                tile(
                  'Language and appearance',
                  Icons.palette_outlined,
                  LanguageAppearanceScreen(store: store),
                ),
                tile(
                  'Accessibility',
                  Icons.accessibility_new_outlined,
                  AccessibilityScreen(store: store),
                ),
                tile(
                  'Dining preferences',
                  Icons.restaurant_outlined,
                  DiningPreferencesScreen(store: store),
                ),
                tile(
                  'Saved addresses',
                  Icons.home_outlined,
                  AddressBookScreen(store: store),
                ),
                tile(
                  'Favorites',
                  Icons.favorite_outline,
                  AccountFavoritesScreen(store: store),
                ),
                tile(
                  'Notification preferences',
                  Icons.notifications_outlined,
                  NotificationSettingsScreen(store: store),
                ),
              ],
            ),
          ),
          AppPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                tile(
                  'Security and sessions',
                  Icons.lock_outline,
                  SecurityScreen(store: store),
                ),
                tile(
                  'Help and support',
                  Icons.help_outline,
                  HelpScreen(store: store),
                ),
                tile(
                  'About Raysto',
                  Icons.info_outline,
                  const AboutRaystoScreen(),
                ),
                tile(
                  'Demo controls',
                  Icons.tune_outlined,
                  DemoControlsScreen(store: store),
                ),
                tile(
                  'Payment test lab',
                  Icons.science_outlined,
                  const PaymentLabScreen(),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              if (await confirmAction(
                context,
                'Sign out',
                context.l(
                  'End this local session? Saved demo data stays on this device.',
                  'Terminer cette session locale ? Les données restent sur cet appareil.',
                  'إنهاء الجلسة المحلية؟ تبقى البيانات التجريبية على الجهاز.',
                ),
              )) {
                store.signOut();
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(context.tr('Sign out')),
          ),
          Text(
            context.l(
              'Raysto 0.2.0 · Mobile demo · rays.to',
              'Raysto 0.2.0 · Démo mobile · rays.to',
              'رايستو 0.2.0 · تجربة الهاتف · rays.to',
            ),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      );
    },
  );
}

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  late final TextEditingController _name;
  late String _avatar;
  final _form = GlobalKey<FormState>();
  bool _saved = false;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.store.currentAccount.name);
    _avatar = widget.store.currentAccount.avatar;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraftGuard(
    dirty:
        !_saved &&
        (_name.text != widget.store.currentAccount.name ||
            _avatar != widget.store.currentAccount.avatar),
    child: MobilePage(
      title: 'Edit profile',
      children: [
        Form(
          key: _form,
          child: TextFormField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: context.tr('Name')),
            validator: (v) => (v ?? '').trim().length < 2
                ? context.tr('Enter your name.')
                : null,
          ),
        ),
        Section(
          title: 'Avatar',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                      'assets/images/salad_bowl.jpg',
                      'assets/images/tomato_pasta.jpg',
                      'assets/images/wood_fired_pizza.jpg',
                    ]
                    .map(
                      (asset) => Semantics(
                        selected: _avatar == asset,
                        label: context.l(
                          'Choose food avatar',
                          'Choisir un avatar gourmand',
                          'اختيار صورة طعام',
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () => setState(() => _avatar = asset),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _avatar == asset
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: AssetImage(asset),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        AppButton(
          label: context.tr('Save'),
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            widget.store.updateProfile(
              name: _name.text.trim(),
              avatar: _avatar,
            );
            setState(() => _saved = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.pop(context);
            });
          },
        ),
      ],
    ),
  );
}

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Accessibility',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.tr('Reduce motion')),
          subtitle: Text(context.tr('System motion preferences always apply.')),
          value: store.settings.reducedMotion,
          onChanged: (v) => store.updateSettings(reducedMotion: v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.tr('Haptics')),
          value: store.settings.haptics,
          onChanged: (v) => store.updateSettings(haptics: v),
        ),
        Section(
          title: 'Additional text size',
          subtitle: 'Multiplies the system text size; never reduces it.',
          child: Column(
            children: [
              Slider(
                value: store.settings.textScale.clamp(1, 1.5),
                min: 1,
                max: 1.5,
                divisions: 5,
                label: '${(store.settings.textScale * 100).round()}%',
                onChanged: (v) => store.updateSettings(textScale: v),
              ),
              Text(
                '${(store.settings.textScale * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        AppNotice(
          title: context.tr('Good food. Your way.'),
          message: context.l(
            'This preview follows your system text size and your additional size preference.',
            'Cet aperçu suit la taille de texte du système et votre préférence supplémentaire.',
            'تتبع هذه المعاينة حجم نص النظام والحجم الإضافي الذي اخترته.',
          ),
        ),
      ],
    ),
  );
}

class DiningPreferencesScreen extends StatelessWidget {
  const DiningPreferencesScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Dining preferences',
      children: [
        Text(
          context.tr(
            'Dietary information is provided by each demo menu. Ask staff about allergies.',
          ),
        ),
        ...[
          'Vegetarian',
          'Mediterranean',
          'Comfort food',
          'Quick lunches',
          'Family meals',
          'Dine in',
          'Pickup',
          'Delivery',
        ].map(
          (label) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr(label)),
            value: store.currentAccount.preferences[label] ?? false,
            onChanged: (v) => store.setPreference(label, v),
          ),
        ),
      ],
    ),
  );
}

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Saved addresses',
      children: [
        const SchematicMap(),
        Text(
          context.l(
            'Demo delivery area: Central district. Enter “Central” or “Demo Central” as the city. Other cities can be saved but cannot be used for delivery.',
            'Zone démo : quartier Central. Saisissez « Central » ou « Demo Central » comme ville. Les autres villes peuvent être enregistrées, sans livraison.',
            'نطاق التوصيل التجريبي: المنطقة المركزية. أدخل Central أو Demo Central للمدينة. يمكن حفظ المدن الأخرى دون توصيل.',
          ),
        ),
        if (store.currentAccount.addresses.isEmpty)
          EmptyState(
            title: 'Saved addresses',
            message: context.l(
              'Add an address for a delivery order. Manual entry works without location access.',
              'Ajoutez une adresse pour commander en livraison. La saisie manuelle fonctionne sans localisation.',
              'أضف عنواناً للتوصيل. يعمل الإدخال اليدوي دون إذن الموقع.',
            ),
            icon: Icons.home_outlined,
          ),
        ...store.currentAccount.addresses.map(
          (address) => AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  address.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${address.street}\n${address.city}'),
                if (address.instructions.isNotEmpty) Text(address.instructions),
                if (!address.eligible)
                  Text(
                    context.tr('Outside the demo delivery area'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (address.isDefault)
                  StatusBadge(
                    'Default address',
                    icon: Icons.check_circle_outline,
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => openPage(
                        context,
                        AddressEditorScreen(store: store, address: address),
                      ),
                      child: Text(context.tr('Edit')),
                    ),
                    if (!address.isDefault)
                      TextButton(
                        onPressed: () => store.setDefaultAddress(address.id),
                        child: Text(context.tr('Set as default')),
                      ),
                    TextButton(
                      onPressed: () async {
                        if (await confirmAction(
                          context,
                          'Delete',
                          address.label,
                        )) {
                          store.deleteAddress(address.id);
                        }
                      },
                      child: Text(context.tr('Delete')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppButton(
          label: context.tr('Add address'),
          icon: Icons.add,
          onPressed: () => openPage(context, AddressEditorScreen(store: store)),
        ),
      ],
    ),
  );
}

class AddressEditorScreen extends StatefulWidget {
  const AddressEditorScreen({super.key, required this.store, this.address});
  final DemoStore store;
  final Address? address;
  @override
  State<AddressEditorScreen> createState() => _AddressEditorScreenState();
}

class _AddressEditorScreenState extends State<AddressEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _label, _street, _city, _instructions;
  bool _dirty = false, _saved = false;
  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _label = TextEditingController(text: a?.label ?? 'Home');
    _street = TextEditingController(text: a?.street);
    _city = TextEditingController(text: a?.city ?? 'Central');
    _instructions = TextEditingController(text: a?.instructions);
  }

  @override
  void dispose() {
    _label.dispose();
    _street.dispose();
    _city.dispose();
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraftGuard(
    dirty: _dirty && !_saved,
    child: MobilePage(
      title: 'Add address',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              for (final field in [
                (_label, 'Label'),
                (_street, 'Street address'),
                (_city, 'City'),
                (_instructions, 'Delivery instructions'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: field.$1,
                    maxLines: field.$2 == 'Delivery instructions' ? 3 : 1,
                    onChanged: (_) => setState(() => _dirty = true),
                    decoration: InputDecoration(
                      labelText: context.tr(field.$2),
                    ),
                    validator: (v) =>
                        field.$2 != 'Delivery instructions' &&
                            (v ?? '').trim().isEmpty
                        ? context.l(
                            'This field is required.',
                            'Ce champ est obligatoire.',
                            'هذا الحقل مطلوب.',
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
        AppButton(
          label: context.tr('Save'),
          onPressed: () => guarded(context, () {
            if (!_form.currentState!.validate()) return;
            final eligible = [
              'central',
              'demo central',
            ].contains(_city.text.trim().toLowerCase());
            widget.store.saveAddress(
              Address(
                id:
                    widget.address?.id ??
                    'address-${widget.store.currentAccount.id}-${DateTime.now().microsecondsSinceEpoch}',
                label: _label.text.trim(),
                street: _street.text.trim(),
                city: _city.text.trim(),
                instructions: _instructions.text.trim(),
                isDefault:
                    widget.address?.isDefault ??
                    widget.store.currentAccount.addresses.isEmpty,
                eligible: eligible,
              ),
            );
            setState(() => _saved = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.pop(context);
            });
          }),
        ),
      ],
    ),
  );
}

class AccountFavoritesScreen extends StatelessWidget {
  const AccountFavoritesScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Favorites',
      children: [
        if (store.currentAccount.favorites.isEmpty)
          EmptyState(
            title: 'No favorites yet',
            message: context.l(
              'Save a restaurant or menu item from Discover.',
              'Enregistrez un restaurant ou un plat depuis Découvrir.',
              'احفظ مطعماً أو طبقاً من شاشة الاكتشاف.',
            ),
            icon: Icons.favorite_outline,
          ),
        ...store.restaurants
            .where((r) => store.currentAccount.favorites.contains(r.id))
            .map(
              (r) => ListTile(
                title: Text(r.name),
                leading: const Icon(Icons.restaurant),
                trailing: IconButton(
                  tooltip: context.tr('Remove'),
                  onPressed: () => store.toggleFavorite(r.id),
                  icon: const Icon(Icons.favorite),
                ),
              ),
            ),
        ...store.menuItems
            .where((m) => store.currentAccount.favorites.contains(m.id))
            .map(
              (item) => ListTile(
                title: Text(item.name),
                subtitle: Text(
                  context.tr(
                    item.available && !item.archived
                        ? 'Available'
                        : 'Unavailable',
                  ),
                ),
                leading: CircleAvatar(backgroundImage: AssetImage(item.asset)),
                trailing: IconButton(
                  tooltip: context.tr('Remove'),
                  onPressed: () => store.toggleFavorite(item.id),
                  icon: const Icon(Icons.favorite),
                ),
              ),
            ),
      ],
    ),
  );
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Notification preferences',
      children: [
        ...[
          ('orders', 'Order updates'),
          ('service', 'Service requests'),
          ('reservations', 'Reservations'),
          ('offers', 'Offers'),
        ].map(
          (p) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr(p.$2)),
            value: store.settings.notifications[p.$1] ?? false,
            onChanged: (v) => store.setNotificationPreference(p.$1, v),
          ),
        ),
        PermissionControls(store: store),
        AppButton(
          label: context.tr('Preview notification'),
          secondary: true,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(Icons.notifications_outlined),
              title: Text(
                context.l(
                  'Demo order is ready',
                  'La commande démo est prête',
                  'الطلب التجريبي جاهز',
                ),
              ),
              content: Text(
                context.l(
                  'In-app preview only. No system notification was sent.',
                  'Aperçu dans l’app uniquement. Aucune notification système envoyée.',
                  'معاينة داخل التطبيق فقط. لم يتم إرسال إشعار للنظام.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('Close')),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Security and sessions',
    children: [
      AppNotice(
        title: context.tr('Local demo only'),
        message: context.l(
          'Do not enter a real password. All sample accounts use RaystoDemo123!.',
          'N’utilisez pas un vrai mot de passe. Tous les comptes utilisent RaystoDemo123!.',
          'لا تدخل كلمة مرور حقيقية. تستخدم الحسابات التجريبية RaystoDemo123!.',
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.phone_android),
        title: Text(context.tr('This device')),
        subtitle: Text(context.tr('Current local session')),
      ),
      AppButton(
        label: context.tr('Change demo password'),
        secondary: true,
        onPressed: () => openPage(context, const PasswordDemoScreen()),
      ),
      OutlinedButton(
        onPressed: () async {
          if (await confirmAction(
            context,
            'Reset this demo account',
            context.l(
              'Clear this account’s private carts, addresses, favorites, dining preferences, onboarding progress, support messages and reviews. App settings on this device also return to defaults. Shared restaurant orders, visits and payments are preserved. No real account is deleted.',
              'Effacer les paniers privés, adresses, favoris, préférences alimentaires, progression d’accueil, messages d’assistance et avis de ce compte. Les paramètres de l’app reviennent aussi aux valeurs par défaut. Commandes, visites et paiements partagés du restaurant sont conservés. Aucun compte réel n’est supprimé.',
              'مسح السلال الخاصة والعناوين والمفضلة وتفضيلات الطعام وتقدم الإعداد ورسائل الدعم والتقييمات لهذا الحساب. تعود إعدادات التطبيق على هذا الجهاز إلى القيم الافتراضية أيضاً. تبقى طلبات المطعم وزياراته ومدفوعاته المشتركة محفوظة. لا يُحذف حساب حقيقي.',
            ),
          )) {
            store.resetPersonal();
            if (context.mounted) {
              showMessage(context, context.tr('Preferences saved'));
            }
          }
        },
        child: Text(context.tr('Reset this demo account')),
      ),
    ],
  );
}

class PasswordDemoScreen extends StatefulWidget {
  const PasswordDemoScreen({super.key});
  @override
  State<PasswordDemoScreen> createState() => _PasswordDemoScreenState();
}

class _PasswordDemoScreenState extends State<PasswordDemoScreen> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController(),
      _next = TextEditingController(),
      _confirm = TextEditingController();
  bool _done = false;
  @override
  void dispose() {
    _old.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Change demo password',
    children: [
      if (_done)
        AppNotice(
          title: context.tr('Done'),
          message: context.tr(
            'Password change simulated. The shared demo password is unchanged.',
          ),
        )
      else
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _old,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('Current password'),
                  helperText: 'RaystoDemo123!',
                ),
                validator: (v) => v == 'RaystoDemo123!'
                    ? null
                    : context.l(
                        'Use the displayed demo password.',
                        'Utilisez le mot de passe démo affiché.',
                        'استخدم كلمة المرور التجريبية المعروضة.',
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _next,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('New password'),
                ),
                validator: (v) => (v ?? '').length < 8
                    ? context.tr('Use at least 8 characters.')
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('Confirm password'),
                ),
                validator: (v) => v != _next.text
                    ? context.tr('Passwords do not match.')
                    : null,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: context.tr('Save'),
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    _old.clear();
                    _next.clear();
                    _confirm.clear();
                    setState(() => _done = true);
                  }
                },
              ),
            ],
          ),
        ),
    ],
  );
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Help and support',
    children: [
      AppDisclosure(
        title: context.l(
          'Is this a real payment?',
          'Est-ce un vrai paiement ?',
          'هل هذا دفع حقيقي؟',
        ),
        child: Text(
          context.l(
            'No. Demo PayPal and cash only update this local world. No money moves.',
            'Non. PayPal démo et espèces modifient uniquement les données locales. Aucun argent ne circule.',
            'لا. محاكاة PayPal والنقد تحدثان البيانات المحلية فقط دون تحويل أموال.',
          ),
        ),
      ),
      AppDisclosure(
        title: context.l(
          'Why can’t I join an occupied table?',
          'Pourquoi ne puis-je pas rejoindre une table occupée ?',
          'لماذا لا يمكنني الانضمام لطاولة مشغولة؟',
        ),
        child: Text(
          context.l(
            'A table QR identifies the table. Joining a current party requires its active invitation code.',
            'Le QR identifie la table. Pour rejoindre le groupe présent, il faut son invitation active.',
            'يحدد رمز الطاولة هويتها. يتطلب الانضمام إلى الجلسة رمز دعوة صالحاً.',
          ),
        ),
      ),
      AppDisclosure(
        title: context.l(
          'Where is my data stored?',
          'Où sont mes données ?',
          'أين تُحفظ بياناتي؟',
        ),
        child: Text(
          context.l(
            'Demo data is saved on this installation. Switch accounts to inspect connected roles. Reset the whole demo to restore fixtures.',
            'Les données sont stockées sur cette installation. Changez de compte pour explorer les rôles. Réinitialisez la démo pour retrouver les exemples.',
            'تُحفظ البيانات التجريبية على هذا الجهاز. بدّل الحساب لرؤية الأدوار المتصلة. أعد ضبط التجربة لاستعادة الأمثلة.',
          ),
        ),
      ),
      AppDisclosure(
        title: context.l(
          'Can I trust allergy information?',
          'Puis-je me fier aux allergènes ?',
          'هل يمكنني الاعتماد على معلومات الحساسية؟',
        ),
        child: Text(
          context.tr(
            'Dietary information is provided by each demo menu. Ask staff about allergies.',
          ),
        ),
      ),
      AppButton(
        label: context.tr('Contact local support'),
        icon: Icons.chat_bubble_outline,
        onPressed: () =>
            openPage(context, SupportConversationScreen(store: store)),
      ),
      TextButton(
        onPressed: () => openPage(context, const AboutRaystoScreen()),
        child: Text(context.tr('Privacy and terms')),
      ),
    ],
  );
}

class SupportConversationScreen extends StatefulWidget {
  const SupportConversationScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<SupportConversationScreen> createState() =>
      _SupportConversationScreenState();
}

class _SupportConversationScreenState extends State<SupportConversationScreen> {
  final _message = TextEditingController();
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final value = (text ?? _message.text).trim();
    if (value.isEmpty) return;
    widget.store.addSupportMessage(value);
    _message.clear();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => MobilePage(
      title: 'Support conversation',
      children: [
        AppNotice(
          title: context.tr('Local demo only'),
          message: context.l(
            'Replies are simulated on this device. No message reaches a restaurant or support team.',
            'Les réponses sont simulées sur cet appareil. Aucun message n’atteint un restaurant ou une équipe.',
            'الردود محاكاة على هذا الجهاز. لا تُرسل رسائل إلى المطعم أو فريق الدعم.',
          ),
        ),
        ...widget.store.supportMessages
            .where((m) => m.accountId == widget.store.currentAccount.id)
            .map(
              (m) => AppPanel(
                color: m.fromSupport
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Text(m.text),
              ),
            ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Payment', 'Order updates', 'Dietary information']
              .map(
                (label) => ActionChip(
                  label: Text(context.tr(label)),
                  onPressed: () => _send(label),
                ),
              )
              .toList(),
        ),
        TextField(
          controller: _message,
          maxLines: 3,
          decoration: InputDecoration(labelText: context.tr('Your message')),
        ),
        AppButton(label: context.tr('Send locally'), onPressed: _send),
      ],
    ),
  );
}

class AboutRaystoScreen extends StatelessWidget {
  const AboutRaystoScreen({super.key});
  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'About Raysto',
    children: [
      const Text('Raysto · 0.2.0+2'),
      Text(
        context.l(
          'A mobile restaurant experience for customers and restaurant teams. Independent from Awhar. Intended website: rays.to.',
          'Une expérience mobile pour les clients et les équipes de restaurant. Indépendant d’Awhar. Site prévu : rays.to.',
          'تجربة هاتف لعملاء المطاعم وفرقها. مستقلة عن Awhar. الموقع المقصود: rays.to.',
        ),
      ),
      AppNotice(
        title: context.tr('Privacy and terms'),
        message: context.tr(
          'Demo information only. Real privacy and terms policies are pending.',
        ),
      ),
      Text(
        context.l(
          'The demo keeps its workflow data on this installation. It uses fictional identities, bundled photos and fonts, and simulated messages, payments, location and AI. Global reset removes this local demo state and restores the fixtures.',
          'La démo conserve ses données sur cette installation : identités fictives, photos et polices intégrées, messages, paiements, localisation et IA simulés. La réinitialisation globale restaure les exemples.',
          'تحفظ التجربة بياناتها على هذا الجهاز. تستخدم هويات خيالية وصوراً وخطوطاً مدمجة ومحاكاة للرسائل والدفع والموقع والذكاء الاصطناعي. تعيد إعادة الضبط الشاملة البيانات الأصلية.',
        ),
      ),
      OutlinedButton(
        onPressed: () => showLicensePage(
          context: context,
          applicationName: 'Raysto',
          applicationVersion: '0.2.0',
        ),
        child: Text(
          context.l(
            'Open-source licenses',
            'Licences open source',
            'تراخيص المصادر المفتوحة',
          ),
        ),
      ),
    ],
  );
}

class DemoControlsScreen extends StatelessWidget {
  const DemoControlsScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Demo controls',
      children: [
        AppNotice(
          title: context.tr('Local demo only'),
          message: context.l(
            'Shared activity stays within this installation. Scenario replacement resets the world and invalidates older pending work.',
            'L’activité est partagée uniquement sur cette installation. Un changement de scénario réinitialise le monde et invalide le travail antérieur.',
            'يظل النشاط المشترك على هذا الجهاز. يؤدي تبديل السيناريو إلى إعادة ضبط البيانات وإلغاء العمليات القديمة.',
          ),
        ),
        AppButton(
          label: context.tr('Switch account'),
          icon: Icons.switch_account_outlined,
          onPressed: () =>
              openPage(context, AccountChooserScreen(store: store)),
        ),
        Section(
          title: 'Restaurant',
          child: Column(
            children: store.restaurants
                .where(
                  (r) =>
                      !store.currentAccount.isStaff ||
                      store.currentAccount.hasRestaurantAccess(r.id),
                )
                .map(
                  (r) => AppChoice(
                    title: r.name,
                    selected: store.currentRestaurant.id == r.id,
                    onTap: () =>
                        guarded(context, () => store.selectRestaurant(r.id)),
                  ),
                )
                .toList(),
          ),
        ),
        Section(
          title: 'Scenario',
          child: Column(
            children: [
              for (final scenario in [
                ('A', 'First order'),
                ('B', 'Dine-in with PayPal'),
                ('C', 'Pay at end'),
                ('D', 'Delivery'),
                ('E', 'Pickup'),
                ('F', 'Payment recovery'),
                ('G', 'Restaurant setup'),
                ('H', 'Availability change'),
                ('I', 'Floor and service'),
                ('J', 'Permissions'),
                ('K', 'Reservations and waitlist'),
                ('L', 'Accessibility and reset'),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${scenario.$1} · ${context.tr(scenario.$2)}'),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () async {
                    if (await confirmAction(
                      context,
                      'Scenario',
                      context.l(
                        'Replace the local world with this scenario? Current demo changes will be reset.',
                        'Remplacer le monde local par ce scénario ? Les modifications actuelles seront réinitialisées.',
                        'استبدال البيانات المحلية بهذا السيناريو؟ ستُعاد ضبط التغييرات الحالية.',
                      ),
                    )) {
                      store.loadScenario(scenario.$1);
                    }
                  },
                ),
            ],
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.tr('Connectivity simulation')),
          subtitle: Text(context.tr(store.online ? 'Online' : 'Offline')),
          value: store.online,
          onChanged: store.setConnectivity,
        ),
        Section(
          title: 'Next payment outcome',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentOutcome.values
                .map(
                  (value) => ChoiceChip(
                    label: Text(
                      context.tr(
                        '${value.name[0].toUpperCase()}${value.name.substring(1)}',
                      ),
                    ),
                    selected: store.nextPaymentOutcome == value,
                    onSelected: (_) => store.setPaymentOutcome(value),
                  ),
                )
                .toList(),
          ),
        ),
        Section(
          title: 'Service delay',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['instant', 'normal', 'slow']
                .map(
                  (value) => ChoiceChip(
                    label: Text(
                      context.tr(
                        '${value[0].toUpperCase()}${value.substring(1)}',
                      ),
                    ),
                    selected: store.delayMode == value,
                    onSelected: (_) => store.setDelayMode(value),
                  ),
                )
                .toList(),
          ),
        ),
        Text(
          '${context.l('Demo clock', 'Horloge démo', 'الساعة التجريبية')}: ${store.now.toIso8601String().substring(0, 16).replaceFirst('T', ' ')}',
        ),
        OutlinedButton(
          onPressed: () => store.advanceTime(const Duration(minutes: 15)),
          child: Text(context.tr('Advance 15 minutes')),
        ),
        OutlinedButton(
          onPressed: () {
            store.updateOnboardingStep(0);
            openPage(
              context,
              OnboardingScreen(
                store: store,
                onComplete: () => Navigator.of(context).pop(),
              ),
            );
          },
          child: Text(context.tr('Replay onboarding')),
        ),
        OutlinedButton(
          onPressed: () async {
            if (await confirmAction(
              context,
              'Reset personal demo data',
              context.l(
                'Clear this account’s private carts, addresses, favorites, dining preferences, onboarding progress, support messages and reviews. App settings on this device also return to defaults. Shared restaurant orders, visits and payments are preserved.',
                'Effacer les paniers privés, adresses, favoris, préférences alimentaires, progression d’accueil, messages d’assistance et avis de ce compte. Les paramètres de l’app reviennent aussi aux valeurs par défaut. Commandes, visites et paiements partagés du restaurant sont conservés.',
                'مسح السلال الخاصة والعناوين والمفضلة وتفضيلات الطعام وتقدم الإعداد ورسائل الدعم والتقييمات لهذا الحساب. تعود إعدادات التطبيق على هذا الجهاز إلى القيم الافتراضية أيضاً. تبقى طلبات المطعم وزياراته ومدفوعاته المشتركة محفوظة.',
              ),
            )) {
              store.resetPersonal();
            }
          },
          child: Text(context.tr('Reset personal demo data')),
        ),
        OutlinedButton(
          onPressed: () async {
            if (await confirmAction(
              context,
              'Reset whole demo',
              context.l(
                'Restore all original fixtures and cancel older pending operations? This affects every local demo account.',
                'Restaurer tous les exemples et annuler les opérations antérieures ? Tous les comptes démo locaux sont concernés.',
                'استعادة كل البيانات الأصلية وإلغاء العمليات المعلقة القديمة؟ يشمل ذلك جميع الحسابات التجريبية المحلية.',
              ),
            )) {
              store.resetWorld();
            }
          },
          child: Text(context.tr('Reset whole demo')),
        ),
        TextButton(
          onPressed: () => openPage(context, const GalleryScreen()),
          child: Text(context.tr('Component and motion gallery')),
        ),
        OutlinedButton(
          onPressed: () => openPage(context, AccessStateScreen(store: store)),
          child: Text(context.tr('Access denied')),
        ),
        OutlinedButton(
          onPressed: () => openPage(
            context,
            AccessStateScreen(
              store: store,
              state: 'Demo session expired',
              onRecover: () {
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
          child: Text(context.tr('Demo session expired')),
        ),
      ],
    ),
  );
}
