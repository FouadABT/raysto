import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'features/account/connected_account_entry.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF6F7F2),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Plus Jakarta Sans',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Noto Sans Arabic',
    ], await rootBundle.loadString('assets/licenses/NotoSansArabic-OFL.txt'));
  });
  runApp(
    RaystoApp(
      onlineAccountBuilder: (_) => const ConnectedAccountEntry(),
      paymentReturnBuilder: (_, uri) =>
          ConnectedAccountEntry(paymentReturn: uri),
    ),
  );
}
