import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'product_catalog.dart';
import 'domain_catalog.dart';
import 'connected_catalog.dart';
import 'payment_catalog.dart';
import 'experience_catalog.dart';

/// English keys keep feature call sites readable; translated catalogues are
/// bundled and available offline. Restaurant-authored names remain verbatim.
class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  static const supportedLocales = [Locale('en'), Locale('fr'), Locale('ar')];
  static const delegate = _AppLocalizationsDelegate();

  String tr(String key) {
    // Domain enums are rendered as readable lower-case words by operational
    // lists. Resolve those through the same catalogue without duplicating it.
    final normalized = key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .toLowerCase();
    final sentenceCase = normalized.isEmpty
        ? normalized
        : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
    final values = translations[key] ?? translations[sentenceCase];
    if (values == null) return _dynamicMessage(key) ?? key;
    return switch (locale.languageCode) {
      'fr' => values.$1,
      'ar' => values.$2,
      _ => key,
    };
  }

  String? _dynamicMessage(String key) {
    if (locale.languageCode == 'en') return null;
    for (final entry in _messagePatterns.entries) {
      final match = RegExp(entry.key).firstMatch(key);
      if (match == null) continue;
      var result = locale.languageCode == 'ar'
          ? entry.value.$2
          : entry.value.$1;
      for (var index = 1; index <= match.groupCount; index++) {
        result = result.replaceAll('{$index}', match.group(index) ?? '');
      }
      return result;
    }
    return null;
  }
}

const _messagePatterns = <String, (String, String)>{
  r'^Line (\d+): use Category \| Dish \| Price \| Description\.$': (
    'Ligne {1} : utilisez Catégorie | Plat | Prix | Description.',
    'السطر {1}: استخدم الفئة | الطبق | السعر | الوصف.',
  ),
  r'^(.*) duplicates an existing item\. Rename it or discard the duplicate\.$':
      (
        '{1} fait doublon avec un plat existant. Renommez-le ou retirez le doublon.',
        '{1} يكرر صنفاً موجوداً. أعد تسميته أو أزل النسخة المكررة.',
      ),
  r'^(.*) is unavailable\. Remove it or choose a replacement\.$': (
    '{1} est indisponible. Retirez-le ou choisissez un remplacement.',
    '{1} غير متاح. أزله أو اختر بديلاً.',
  ),
  r'^(.*) has a new price\. Edit the basket item to review it\.$': (
    'Le prix de {1} a changé. Modifiez cet article dans le panier pour le vérifier.',
    'تغير سعر {1}. عدّل الصنف في السلة لمراجعته.',
  ),
  r'^An option in (.*) is no longer available\.$': (
    'Une option de {1} n’est plus disponible.',
    'أحد خيارات {1} لم يعد متاحاً.',
  ),
  r'^Choose (\d+)–(\d+) options for (.*)\.$': (
    'Choisissez de {1} à {2} options pour {3}.',
    'اختر من {1} إلى {2} خيارات لـ {3}.',
  ),
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension RaystoTranslations on BuildContext {
  String tr(String key) =>
      (Localizations.of<AppLocalizations>(this, AppLocalizations) ??
              const AppLocalizations(Locale('en')))
          .tr(key);
  String l(String en, String fr, String ar) =>
      switch (Localizations.localeOf(this).languageCode) {
        'fr' => fr,
        'ar' => ar,
        _ => en,
      };
}

const translations = <String, (String, String)>{
  ...experienceTranslations,
  ...paymentTranslations,
  ...connectedTranslations,
  ...domainTranslations,
  ...productTranslations,
  'Welcome to Raysto': ('Bienvenue sur Raysto', 'مرحباً بك في رايستو'),
  'Good food. Your way.': (
    'Bien manger, à votre façon.',
    'طعام شهي، على ذوقك.',
  ),
  'Discover local tables, order a favourite, and enjoy every moment.': (
    'Découvrez de bonnes tables, commandez vos favoris et profitez de chaque instant.',
    'اكتشف المطاعم، اطلب ما تحب واستمتع بكل لحظة.',
  ),
  'Explore demo accounts': (
    'Explorer les comptes démo',
    'استكشف الحسابات التجريبية',
  ),
  'Continue as guest': ('Continuer en tant qu’invité', 'المتابعة كضيف'),
  'For restaurants': ('Pour les restaurants', 'للمطاعم'),
  'Sign in': ('Se connecter', 'تسجيل الدخول'),
  'Create account': ('Créer un compte', 'إنشاء حساب'),
  'Email': ('Adresse e-mail', 'البريد الإلكتروني'),
  'Password': ('Mot de passe', 'كلمة المرور'),
  'Show password': ('Afficher le mot de passe', 'إظهار كلمة المرور'),
  'Hide password': ('Masquer le mot de passe', 'إخفاء كلمة المرور'),
  'Name': ('Nom', 'الاسم'),
  'Forgot password?': ('Mot de passe oublié ?', 'نسيت كلمة المرور؟'),
  'Local demo only': ('Démo locale uniquement', 'تجربة محلية فقط'),
  'No real account, email, or payment is created.': (
    'Aucun vrai compte, e-mail ou paiement n’est créé.',
    'لا يتم إنشاء حساب حقيقي أو إرسال بريد أو إجراء دفع.',
  ),
  'Choose an account': ('Choisir un compte', 'اختر حساباً'),
  'Customer': ('Client', 'عميل'),
  'New customer': ('Nouveau client', 'عميل جديد'),
  'Returning customer': ('Client fidèle', 'عميل عائد'),
  'Active diner': ('Client à table', 'ضيف على الطاولة'),
  'Owner': ('Propriétaire', 'مالك'),
  'Manager': ('Responsable', 'مدير'),
  'Waiter': ('Serveur', 'نادل'),
  'Kitchen': ('Cuisine', 'المطبخ'),
  'Courier': ('Livreur', 'مندوب توصيل'),
  'Guest': ('Invité', 'ضيف'),
  'Choose your language': ('Choisissez votre langue', 'اختر لغتك'),
  'Language': ('Langue', 'اللغة'),
  'Appearance': ('Apparence', 'المظهر'),
  'System': ('Système', 'النظام'),
  'Light': ('Clair', 'فاتح'),
  'Dark': ('Sombre', 'داكن'),
  'Continue': ('Continuer', 'متابعة'),
  'Back': ('Retour', 'رجوع'),
  'Skip': ('Passer', 'تخطي'),
  'Finish': ('Terminer', 'إنهاء'),
  'Save': ('Enregistrer', 'حفظ'),
  'Cancel': ('Annuler', 'إلغاء'),
  'Delete': ('Supprimer', 'حذف'),
  'Remove': ('Retirer', 'إزالة'),
  'Edit': ('Modifier', 'تعديل'),
  'Done': ('Terminé', 'تم'),
  'Retry': ('Réessayer', 'إعادة المحاولة'),
  'Reset': ('Réinitialiser', 'إعادة الضبط'),
  'Close': ('Fermer', 'إغلاق'),
  'Review': ('Vérifier', 'مراجعة'),
  'Confirm': ('Confirmer', 'تأكيد'),
  'Details': ('Détails', 'التفاصيل'),
  'Verify your demo account': (
    'Vérifier votre compte démo',
    'تحقق من حسابك التجريبي',
  ),
  'Demo verification code: 123456': (
    'Code démo : 123456',
    'رمز التحقق التجريبي: 123456',
  ),
  'Verification code': ('Code de vérification', 'رمز التحقق'),
  'Verify': ('Vérifier', 'تحقق'),
  'Resend demo code': ('Renouveler le code démo', 'تجديد الرمز التجريبي'),
  'Wrong code. Try 123456.': (
    'Code incorrect. Essayez 123456.',
    'رمز غير صحيح. جرب 123456.',
  ),
  'Code expired. Request another demo code.': (
    'Code expiré. Demandez un nouveau code démo.',
    'انتهت صلاحية الرمز. اطلب رمزاً تجريبياً جديداً.',
  ),
  'Reset password': ('Réinitialiser le mot de passe', 'إعادة ضبط كلمة المرور'),
  'Show local reset confirmation': (
    'Afficher la confirmation locale',
    'عرض تأكيد إعادة الضبط المحلي',
  ),
  'Reset simulated. No email was sent. Use the displayed demo password.': (
    'Réinitialisation simulée. Aucun e-mail envoyé. Utilisez le mot de passe démo affiché.',
    'تمت محاكاة إعادة الضبط. لم يُرسل بريد. استخدم كلمة المرور التجريبية المعروضة.',
  ),
  'Enter a valid email address.': (
    'Saisissez une adresse e-mail valide.',
    'أدخل بريداً إلكترونياً صالحاً.',
  ),
  'Enter your name.': ('Saisissez votre nom.', 'أدخل اسمك.'),
  'Use at least 8 characters.': (
    'Utilisez au moins 8 caractères.',
    'استخدم 8 أحرف على الأقل.',
  ),
  'Your Raysto, your preferences': (
    'Raysto, selon vos envies',
    'رايستو حسب تفضيلاتك',
  ),
  'A few optional choices help shape your discovery.': (
    'Quelques choix facultatifs personnalisent vos découvertes.',
    'خيارات اختيارية بسيطة لتخصيص اكتشافاتك.',
  ),
  'Quick setup': ('Configuration rapide', 'إعداد سريع'),
  'Guide me': ('Guidez-moi', 'أرشدني'),
  'What sounds good?': ('Quelles sont vos envies ?', 'ما الذي تفضله؟'),
  'Vegetarian': ('Végétarien', 'نباتي'),
  'Mediterranean': ('Méditerranéen', 'متوسطي'),
  'Comfort food': ('Cuisine réconfortante', 'أكلات منزلية'),
  'Quick lunches': ('Déjeuners rapides', 'غداء سريع'),
  'Family meals': ('Repas en famille', 'وجبات عائلية'),
  'Dine in': ('Sur place', 'في المطعم'),
  'Pickup': ('À emporter', 'استلام'),
  'Delivery': ('Livraison', 'توصيل'),
  'Choose how you like to order': (
    'Comment aimez-vous commander ?',
    'كيف تفضل الطلب؟',
  ),
  'Dining preferences': ('Préférences alimentaires', 'تفضيلات الطعام'),
  'Dietary information is provided by each demo menu. Ask staff about allergies.':
      (
        'Les informations alimentaires viennent du menu démo. Consultez le personnel pour les allergies.',
        'المعلومات الغذائية من القائمة التجريبية. اسأل الموظفين عن الحساسية.',
      ),
  'Permissions, on your terms': (
    'Les autorisations, à votre choix',
    'الأذونات حسب اختيارك',
  ),
  'These switches simulate permission states. They do not grant device access.':
      (
        'Ces options simulent les autorisations sans donner accès à votre appareil.',
        'هذه الخيارات تحاكي الأذونات ولا تمنح وصولاً إلى الجهاز.',
      ),
  'Location': ('Localisation', 'الموقع'),
  'Camera': ('Caméra', 'الكاميرا'),
  'Notifications': ('Notifications', 'الإشعارات'),
  'Use a manual address': (
    'Utiliser une adresse manuelle',
    'استخدم عنواناً يدوياً',
  ),
  'Use a demo code or manual entry': (
    'Utiliser un code démo ou une saisie manuelle',
    'استخدم رمزاً تجريبياً أو الإدخال اليدوي',
  ),
  'In-app notifications remain available': (
    'Les notifications restent visibles dans l’app',
    'تبقى الإشعارات داخل التطبيق متاحة',
  ),
  'Simulated allowed': ('Autorisé (simulation)', 'مسموح في المحاكاة'),
  'Simulated denied': ('Refusé (simulation)', 'مرفوض في المحاكاة'),
  'Not simulated': ('Non simulé', 'لم تتم المحاكاة'),
  'Your preferences at a glance': (
    'Vos préférences en bref',
    'تفضيلاتك بنظرة واحدة',
  ),
  'Ready to explore': ('Prêt à explorer', 'جاهز للاستكشاف'),
  'Your workspace': ('Votre espace', 'مساحة عملك'),
  'Assigned restaurant': ('Restaurant attribué', 'المطعم المعين'),
  'Your role': ('Votre rôle', 'دورك'),
  'Practice task': ('Exercice', 'مهمة تدريبية'),
  'Practice complete': ('Exercice terminé', 'اكتمل التدريب'),
  'Practice uses separate sample data. Restaurant records are unchanged.': (
    'L’exercice utilise des exemples séparés. Les données du restaurant restent inchangées.',
    'التدريب يستخدم بيانات منفصلة دون تغيير سجلات المطعم.',
  ),
  'Acknowledge water request': (
    'Accuser réception de la demande d’eau',
    'تأكيد طلب الماء',
  ),
  'Mark practice ticket ready': (
    'Marquer le ticket d’exercice prêt',
    'وضع تذكرة التدريب كجاهزة',
  ),
  'Confirm practice handoff': (
    'Confirmer la remise d’exercice',
    'تأكيد التسليم التدريبي',
  ),
  'View your setup checklist': (
    'Voir les étapes de configuration',
    'عرض قائمة الإعداد',
  ),
  'Profile': ('Profil', 'الملف الشخصي'),
  'Settings': ('Paramètres', 'الإعدادات'),
  'Edit profile': ('Modifier le profil', 'تعديل الملف الشخصي'),
  'Avatar': ('Avatar', 'الصورة'),
  'Preferences saved': ('Préférences enregistrées', 'تم حفظ التفضيلات'),
  'Language and appearance': ('Langue et apparence', 'اللغة والمظهر'),
  'Accessibility': ('Accessibilité', 'سهولة الوصول'),
  'Reduce motion': ('Réduire les animations', 'تقليل الحركة'),
  'System motion preferences always apply.': (
    'Les préférences système restent prioritaires.',
    'يُحترم إعداد تقليل الحركة في النظام دائماً.',
  ),
  'Haptics': ('Retour haptique', 'الاستجابة اللمسية'),
  'Additional text size': ('Taille de texte supplémentaire', 'حجم نص إضافي'),
  'Multiplies the system text size; never reduces it.': (
    'Multiplie la taille système sans la réduire.',
    'يضاعف حجم نص النظام دون تقليله.',
  ),
  'Saved addresses': ('Adresses enregistrées', 'العناوين المحفوظة'),
  'Add address': ('Ajouter une adresse', 'إضافة عنوان'),
  'Label': ('Libellé', 'التسمية'),
  'Street address': ('Adresse', 'عنوان الشارع'),
  'City': ('Ville', 'المدينة'),
  'Delivery instructions': ('Instructions de livraison', 'تعليمات التوصيل'),
  'Default address': ('Adresse par défaut', 'العنوان الافتراضي'),
  'Set as default': ('Définir par défaut', 'تعيين كافتراضي'),
  'Outside the demo delivery area': (
    'Hors de la zone de livraison démo',
    'خارج نطاق التوصيل التجريبي',
  ),
  'Favorites': ('Favoris', 'المفضلة'),
  'No favorites yet': ('Aucun favori pour le moment', 'لا توجد مفضلة بعد'),
  'Notification preferences': (
    'Préférences de notification',
    'تفضيلات الإشعارات',
  ),
  'Order updates': ('Suivi des commandes', 'تحديثات الطلبات'),
  'Service requests': ('Demandes de service', 'طلبات الخدمة'),
  'Reservations': ('Réservations', 'الحجوزات'),
  'Offers': ('Offres', 'العروض'),
  'Demo permission': ('Autorisation démo', 'إذن تجريبي'),
  'Preview notification': ('Aperçu de notification', 'معاينة الإشعار'),
  'Security and sessions': ('Sécurité et sessions', 'الأمان والجلسات'),
  'Change demo password': (
    'Changer le mot de passe démo',
    'تغيير كلمة المرور التجريبية',
  ),
  'Current password': ('Mot de passe actuel', 'كلمة المرور الحالية'),
  'New password': ('Nouveau mot de passe', 'كلمة المرور الجديدة'),
  'Confirm password': ('Confirmer le mot de passe', 'تأكيد كلمة المرور'),
  'Passwords do not match.': (
    'Les mots de passe ne correspondent pas.',
    'كلمتا المرور غير متطابقتين.',
  ),
  'Password change simulated. The shared demo password is unchanged.': (
    'Changement simulé. Le mot de passe partagé de démonstration reste inchangé.',
    'تمت محاكاة التغيير. كلمة المرور التجريبية المشتركة لم تتغير.',
  ),
  'This device': ('Cet appareil', 'هذا الجهاز'),
  'Current local session': (
    'Session locale actuelle',
    'الجلسة المحلية الحالية',
  ),
  'Sign out': ('Se déconnecter', 'تسجيل الخروج'),
  'Reset this demo account': (
    'Réinitialiser ce compte démo',
    'إعادة ضبط هذا الحساب التجريبي',
  ),
  'Help and support': ('Aide et assistance', 'المساعدة والدعم'),
  'FAQ': ('Questions fréquentes', 'أسئلة شائعة'),
  'Contact local support': (
    'Contacter l’assistance locale',
    'تواصل مع الدعم المحلي',
  ),
  'Support conversation': ('Conversation d’assistance', 'محادثة الدعم'),
  'Your message': ('Votre message', 'رسالتك'),
  'Send locally': ('Envoyer localement', 'إرسال محلياً'),
  'About Raysto': ('À propos de Raysto', 'عن رايستو'),
  'Privacy and terms': ('Confidentialité et conditions', 'الخصوصية والشروط'),
  'Demo information only. Real privacy and terms policies are pending.': (
    'Informations démo uniquement. Les politiques réelles restent à définir.',
    'معلومات تجريبية فقط. سياسات الخصوصية والشروط الفعلية لم تُحدد بعد.',
  ),
  'Demo controls': ('Commandes de démonstration', 'أدوات التجربة'),
  'Switch account': ('Changer de compte', 'تبديل الحساب'),
  'Restaurant': ('Restaurant', 'المطعم'),
  'Scenario': ('Scénario', 'السيناريو'),
  'Connectivity simulation': ('Simulation de connexion', 'محاكاة الاتصال'),
  'Online': ('En ligne', 'متصل'),
  'Offline': ('Hors ligne', 'غير متصل'),
  'Next payment outcome': (
    'Résultat du prochain paiement',
    'نتيجة الدفع التالي',
  ),
  'Success': ('Succès', 'نجاح'),
  'Pending': ('En attente', 'قيد الانتظار'),
  'Failed': ('Échec', 'فشل'),
  'Cancelled': ('Annulé', 'ملغى'),
  'Service delay': ('Délai du service', 'تأخير الخدمة'),
  'Instant': ('Instantané', 'فوري'),
  'Normal': ('Normal', 'عادي'),
  'Slow': ('Lent', 'بطيء'),
  'Advance 15 minutes': ('Avancer de 15 minutes', 'تقديم الوقت 15 دقيقة'),
  'Replay onboarding': ('Revoir le parcours d’accueil', 'إعادة الإعداد الأولي'),
  'Reset personal preferences': (
    'Réinitialiser les préférences personnelles',
    'إعادة ضبط التفضيلات الشخصية',
  ),
  'Reset whole demo': (
    'Réinitialiser toute la démo',
    'إعادة ضبط التجربة كاملة',
  ),
  'Component and motion gallery': (
    'Galerie des composants et animations',
    'معرض المكونات والحركة',
  ),
  'Unsaved changes': ('Modifications non enregistrées', 'تغييرات غير محفوظة'),
  'Discard your changes?': (
    'Abandonner vos modifications ?',
    'تجاهل التغييرات؟',
  ),
  'Keep editing': ('Continuer la modification', 'متابعة التعديل'),
  'Discard': ('Abandonner', 'تجاهل'),
  'Access denied': ('Accès refusé', 'الوصول مرفوض'),
  'This account does not have access to this workspace.': (
    'Ce compte n’a pas accès à cet espace.',
    'لا يملك هذا الحساب صلاحية الوصول إلى مساحة العمل.',
  ),
  'Demo session expired': ('Session démo expirée', 'انتهت الجلسة التجريبية'),
  'Restoring your local demo': (
    'Restauration de votre démo locale',
    'استعادة تجربتك المحلية',
  ),
  'Could not restore local data': (
    'Impossible de restaurer les données locales',
    'تعذرت استعادة البيانات المحلية',
  ),
  'Discover': ('Découvrir', 'اكتشف'),
  'Orders': ('Commandes', 'الطلبات'),
  'Assistant': ('Assistant', 'المساعد'),
  'Overview': ('Vue d’ensemble', 'نظرة عامة'),
  'Tables': ('Tables', 'الطاولات'),
  'Menu': ('Menu', 'القائمة'),
  'More': ('Plus', 'المزيد'),
  'Shift': ('Service', 'المناوبة'),
  'Requests': ('Demandes', 'الطلبات الخدمية'),
  'Queue': ('File', 'قائمة الانتظار'),
  'Availability': ('Disponibilité', 'التوفر'),
  'Tasks': ('Missions', 'المهام'),
  'Activity': ('Activité', 'النشاط'),
  'Search': ('Rechercher', 'بحث'),
  'All': ('Tout', 'الكل'),
  'Filters': ('Filtres', 'الفلاتر'),
  'Available': ('Disponible', 'متاح'),
  'Unavailable': ('Indisponible', 'غير متاح'),
  'Total': ('Total', 'الإجمالي'),
  'Subtotal': ('Sous-total', 'المجموع الفرعي'),
  'Discount': ('Réduction', 'الخصم'),
  'Delivery fee': ('Frais de livraison', 'رسوم التوصيل'),
  'Tip': ('Pourboire', 'الإكرامية'),
  'Balance': ('Solde', 'المتبقي'),
  'Paid': ('Payé', 'مدفوع'),
  'Unpaid': ('Non payé', 'غير مدفوع'),
  'Preparation': ('Préparation', 'التحضير'),
  'Payment': ('Paiement', 'الدفع'),
  'Submitted': ('Envoyé', 'تم الإرسال'),
  'Accepted': ('Accepté', 'مقبول'),
  'Preparing': ('En préparation', 'قيد التحضير'),
  'Ready': ('Prêt', 'جاهز'),
  'Served': ('Servi', 'تم التقديم'),
  'Collected': ('Retiré', 'تم الاستلام'),
  'Delivered': ('Livré', 'تم التوصيل'),
  'Completed': ('Terminé', 'مكتمل'),
  'Rejected': ('Refusé', 'مرفوض'),
  'Draft': ('Brouillon', 'مسودة'),
  'Cart': ('Panier', 'السلة'),
  'Checkout': ('Paiement', 'إتمام الطلب'),
  'Add to cart': ('Ajouter au panier', 'أضف إلى السلة'),
  'View cart': ('Voir le panier', 'عرض السلة'),
  'Order history': ('Historique des commandes', 'سجل الطلبات'),
  'Receipt': ('Reçu', 'الإيصال'),
  'Reorder': ('Commander à nouveau', 'إعادة الطلب'),
  'Scan table': ('Scanner la table', 'مسح رمز الطاولة'),
  'Use demo QR': ('Utiliser le QR démo', 'استخدم رمز QR تجريبي'),
  'Visit': ('Visite', 'الزيارة'),
  'Participants': ('Participants', 'المشاركون'),
  'Table bill': ('Addition de la table', 'فاتورة الطاولة'),
  'Another round': ('Nouvelle commande', 'طلب إضافي'),
  'Water': ('Eau', 'ماء'),
  'Cutlery': ('Couverts', 'أدوات المائدة'),
  'Assistance': ('Assistance', 'مساعدة'),
  'Bill': ('Addition', 'الفاتورة'),
  'Sent': ('Envoyé', 'مرسل'),
  'Acknowledged': ('Pris en compte', 'تم التأكيد'),
  'Occupied': ('Occupée', 'مشغولة'),
  'Reserved': ('Réservée', 'محجوزة'),
  'Needs reset': ('À préparer', 'تحتاج إلى تجهيز'),
  'Team': ('Équipe', 'الفريق'),
  'Reports': ('Rapports', 'التقارير'),
  'Payments': ('Paiements', 'المدفوعات'),
  'Delivery desk': ('Gestion des livraisons', 'مكتب التوصيل'),
  'Setup checklist': ('Étapes de configuration', 'قائمة الإعداد'),
  'Restaurant profile': ('Profil du restaurant', 'ملف المطعم'),
  'Services and hours': ('Services et horaires', 'الخدمات والمواعيد'),
  'Payment policy': ('Politique de paiement', 'سياسة الدفع'),
  'Storefront preview': ('Aperçu de la vitrine', 'معاينة واجهة المطعم'),
  'Floor plan': ('Plan de salle', 'مخطط القاعة'),
  'Waitlist': ('Liste d’attente', 'قائمة الانتظار'),
  'Publish locally': ('Publier localement', 'نشر محلياً'),
  'Demo checkout — no real payment.': (
    'Paiement démo — aucun paiement réel.',
    'دفع تجريبي — لا يتم دفع حقيقي.',
  ),
};
