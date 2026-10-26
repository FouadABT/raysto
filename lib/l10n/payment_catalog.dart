const paymentTranslations = <String, (String, String)>{
  'Test PayPal Sandbox': ('Tester PayPal Sandbox', 'اختبار PayPal التجريبي'),
  'A real Sandbox checkout': (
    'Un vrai paiement Sandbox',
    'دفع فعلي في البيئة التجريبية',
  ),
  'PayPal opens in your browser. Approve USD 1.00 with a Sandbox Personal buyer account, then return and complete the payment. No real money is charged.':
      (
        'PayPal s’ouvre dans votre navigateur. Approuvez 1,00 USD avec un compte acheteur Personnel Sandbox, puis revenez finaliser le paiement. Aucun argent réel n’est débité.',
        'يفتح PayPal في المتصفح. وافق على دفع 1.00 دولار بحساب مشترٍ شخصي تجريبي، ثم عد لإتمام الدفع. لن يتم خصم أموال حقيقية.',
      ),
  'Your checkout is kept. Retry before starting another payment.': (
    'Votre paiement est conservé. Réessayez avant d’en commencer un autre.',
    'تم الاحتفاظ بعملية الدفع. أعد المحاولة قبل بدء دفع جديد.',
  ),
  'Finish your saved checkout first': (
    'Terminez d’abord le paiement enregistré',
    'أكمل عملية الدفع المحفوظة أولاً',
  ),
  'Open saved checkout': (
    'Ouvrir le paiement enregistré',
    'فتح عملية الدفع المحفوظة',
  ),
  'Test USD 1.00 with PayPal': (
    'Tester 1,00 USD avec PayPal',
    'اختبار دفع 1.00 دولار عبر PayPal',
  ),
  'Start another test': ('Commencer un autre test', 'بدء اختبار آخر'),
  'Refresh receipt': ('Actualiser le reçu', 'تحديث الإيصال'),
  'Sandbox capture confirmed': (
    'Encaissement Sandbox confirmé',
    'تم تأكيد التحصيل التجريبي',
  ),
  'Sandbox receipt': ('Reçu Sandbox', 'إيصال تجريبي'),
  'PayPal order': ('Commande PayPal', 'طلب PayPal'),
  'Capture ID': ('Identifiant d’encaissement', 'معرّف التحصيل'),
  'Webhook: waiting for PayPal delivery': (
    'Webhook : en attente de PayPal',
    'Webhook: في انتظار إشعار PayPal',
  ),
  'Webhook: verified and received': (
    'Webhook : vérifié et reçu',
    'Webhook: تم التحقق والاستلام',
  ),
  'Reset local test': (
    'Réinitialiser le test local',
    'إعادة ضبط الاختبار المحلي',
  ),
  'Payment test lab': ('Laboratoire de paiement', 'مختبر اختبار الدفع'),
  'PayPal Sandbox': ('PayPal Sandbox', 'بيئة PayPal التجريبية'),
  'Ready when you are': (
    'Prêt quand vous le souhaitez',
    'جاهز عندما تكون مستعداً',
  ),
  'Restoring checkout': ('Restauration du paiement', 'استعادة عملية الدفع'),
  'Preparing checkout': ('Préparation du paiement', 'تحضير عملية الدفع'),
  'Checkout saved': ('Paiement enregistré', 'تم حفظ عملية الدفع'),
  'Continue in PayPal': ('Continuer sur PayPal', 'المتابعة في PayPal'),
  'Checking payment': ('Vérification du paiement', 'التحقق من الدفع'),
  'Completing payment': ('Finalisation du paiement', 'إتمام الدفع'),
  'Payment confirmed': ('Paiement confirmé', 'تم تأكيد الدفع'),
  'Checkout paused': ('Paiement en pause', 'تم إيقاف الدفع مؤقتاً'),
  'Payment needs attention': (
    'Paiement à vérifier',
    'عملية الدفع تحتاج إلى مراجعة',
  ),
  'Your checkout could not be saved securely. Retry recovery before continuing.':
      (
        'Le paiement n’a pas pu être enregistré de façon sécurisée. Réessayez la restauration avant de continuer.',
        'تعذر حفظ عملية الدفع بأمان. أعد محاولة الاستعادة قبل المتابعة.',
      ),
  'This checkout needs review. Payment details do not match or the checkout has expired. Do not start a second payment.':
      (
        'Ce paiement doit être vérifié. Les détails ne correspondent pas ou le paiement a expiré. Ne lancez pas un second paiement.',
        'تحتاج عملية الدفع إلى مراجعة. التفاصيل غير متطابقة أو انتهت صلاحيتها. لا تبدأ عملية دفع ثانية.',
      ),
  'This checkout is unavailable for the connected account.': (
    'Ce paiement n’est pas disponible pour le compte connecté.',
    'عملية الدفع غير متاحة للحساب المتصل.',
  ),
  'Approval has not been confirmed. Continue in PayPal, then check again.': (
    'L’approbation n’est pas confirmée. Continuez sur PayPal, puis vérifiez à nouveau.',
    'لم يتم تأكيد الموافقة. تابع في PayPal ثم تحقق مجدداً.',
  ),
  'Payment status is not confirmed. Check your connection and check again before starting another checkout.':
      (
        'Le statut du paiement n’est pas confirmé. Vérifiez votre connexion et le statut avant de lancer un autre paiement.',
        'حالة الدفع غير مؤكدة. تحقق من اتصالك ومن الحالة قبل بدء عملية دفع أخرى.',
      ),
  'The backend confirmed payment. You can safely continue.': (
    'Le serveur a confirmé le paiement. Vous pouvez continuer.',
    'أكد الخادم الدفع. يمكنك المتابعة بأمان.',
  ),
  'Returning from cancellation does not cancel or refund an order. Your checkout is kept for later.':
      (
        'Le retour après annulation n’annule ni ne rembourse la commande. Le paiement est conservé pour plus tard.',
        'العودة من الإلغاء لا تلغي الطلب ولا تسترد المبلغ. تم الاحتفاظ بعملية الدفع لوقت لاحق.',
      ),
  'Approve with your sandbox buyer account, then return here and check the payment.':
      (
        'Approuvez avec votre compte acheteur Sandbox, puis revenez vérifier le paiement.',
        'وافق باستخدام حساب المشتري التجريبي ثم عد إلى هنا للتحقق من الدفع.',
      ),
  'Choose an unpaid order to prepare a sandbox checkout.': (
    'Choisissez une commande impayée pour préparer un paiement Sandbox.',
    'اختر طلباً غير مدفوع لتحضير عملية دفع تجريبية.',
  ),
  'Your total comes from the backend. Returning from PayPal alone does not confirm payment.':
      (
        'Le total provient du serveur. Le retour depuis PayPal ne confirme pas à lui seul le paiement.',
        'يأتي المجموع من الخادم. العودة من PayPal وحدها لا تؤكد الدفع.',
      ),
  'Order reference': ('Référence de commande', 'مرجع الطلب'),
  'Check and complete payment': (
    'Vérifier et finaliser le paiement',
    'التحقق من الدفع وإتمامه',
  ),
  'Simulate opening PayPal': (
    'Simuler l’ouverture de PayPal',
    'محاكاة فتح PayPal',
  ),
  'Open PayPal Sandbox': ('Ouvrir PayPal Sandbox', 'فتح PayPal التجريبي'),
  'Recover checkout': ('Récupérer le paiement', 'استعادة عملية الدفع'),
  'Check payment status': (
    'Vérifier le statut du paiement',
    'التحقق من حالة الدفع',
  ),
  'Retry recovery': ('Réessayer la restauration', 'إعادة محاولة الاستعادة'),
  'Remove saved checkout?': (
    'Supprimer le paiement enregistré ?',
    'هل تريد إزالة عملية الدفع المحفوظة؟',
  ),
  'Remove saved checkout': (
    'Supprimer le paiement enregistré',
    'إزالة عملية الدفع المحفوظة',
  ),
  'This removes only this device’s recovery reference. It does not cancel, refund or change the order. You can reopen the order later.':
      (
        'Seule la référence de restauration sur cet appareil est supprimée. La commande n’est ni annulée, ni remboursée, ni modifiée. Vous pourrez la rouvrir.',
        'يؤدي هذا إلى إزالة مرجع الاستعادة على هذا الجهاز فقط. لا يلغي الطلب أو يغيره أو يسترد المبلغ. يمكنك فتح الطلب لاحقاً.',
      ),
  'Local simulation — no PayPal requests': (
    'Simulation locale — aucun appel PayPal',
    'محاكاة محلية — دون طلبات إلى PayPal',
  ),
  'These controls exercise the reusable payment core without an account, restaurant or real transaction.':
      (
        'Ces commandes testent le cœur de paiement réutilisable sans compte, restaurant ni transaction réelle.',
        'تختبر هذه الأدوات نظام الدفع القابل لإعادة الاستخدام دون حساب أو مطعم أو معاملة حقيقية.',
      ),
  'Prepare test checkout': (
    'Préparer un paiement de test',
    'تحضير عملية دفع للاختبار',
  ),
  'Try interrupted checkout': (
    'Tester un paiement interrompu',
    'اختبار انقطاع عملية الدفع',
  ),
  'Simulate network available': (
    'Simuler un réseau disponible',
    'محاكاة توفر الشبكة',
  ),
  'Lose the next capture response': (
    'Perdre la prochaine réponse de capture',
    'فقدان استجابة التحصيل التالية',
  ),
  'The simulated backend settles; the app must recover by checking status.': (
    'Le serveur simulé règle le paiement ; l’application doit récupérer son statut.',
    'يتم الدفع في الخادم المحاكى؛ على التطبيق استعادة الحالة بالتحقق منها.',
  ),
  'Simulate buyer approval and return': (
    'Simuler l’approbation et le retour',
    'محاكاة موافقة المشتري والعودة',
  ),
  'Simulate cancellation return': (
    'Simuler le retour après annulation',
    'محاكاة العودة بعد الإلغاء',
  ),
  'Recreate payment controller': (
    'Recréer le contrôleur de paiement',
    'إعادة إنشاء وحدة التحكم بالدفع',
  ),
  'Recovery here uses memory to imitate a restart. Connected payments use encrypted device storage.':
      (
        'La restauration utilise ici la mémoire pour imiter un redémarrage. Les paiements connectés utilisent le stockage chiffré de l’appareil.',
        'تستخدم الاستعادة هنا الذاكرة لمحاكاة إعادة التشغيل. تستخدم عمليات الدفع المتصلة تخزين الجهاز المشفر.',
      ),
  'Connect your account first': (
    'Connectez d’abord votre compte',
    'اتصل بحسابك أولاً',
  ),
  'Your saved checkout is private to the account that started it.': (
    'Le paiement enregistré est réservé au compte qui l’a lancé.',
    'عملية الدفع المحفوظة خاصة بالحساب الذي بدأها.',
  ),
  'Sandbox payments only': (
    'Paiements Sandbox uniquement',
    'عمليات دفع تجريبية فقط',
  ),
  'Use a PayPal sandbox Personal account to approve. No real money is charged.':
      (
        'Utilisez un compte Personnel PayPal Sandbox pour approuver. Aucun argent réel n’est débité.',
        'استخدم حساب PayPal شخصياً تجريبياً للموافقة. لن تُخصم أموال حقيقية.',
      ),
  'Return link could not be matched': (
    'Le lien de retour ne correspond pas',
    'تعذر مطابقة رابط العودة',
  ),
  'No payment was confirmed from this link. Reopen your order and check its status.':
      (
        'Aucun paiement n’a été confirmé par ce lien. Rouvrez votre commande et vérifiez son statut.',
        'لم يتم تأكيد أي دفع من هذا الرابط. افتح طلبك مجدداً وتحقق من حالته.',
      ),
  'No connected orders yet. This payment core is ready for future order flows; the local test lab works without an order.':
      (
        'Aucune commande connectée pour le moment. Le cœur de paiement est prêt pour les futurs parcours ; le laboratoire local fonctionne sans commande.',
        'لا توجد طلبات متصلة بعد. نظام الدفع جاهز لمسارات الطلبات المستقبلية؛ يعمل المختبر المحلي دون طلب.',
      ),
};
