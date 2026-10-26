import 'package:serverpod_auth_idp_server/providers/firebase.dart';

/// Signature verification needs the selected project ID and Google's public
/// signing certificates. Admin credentials are reserved for FCM/Storage.
FirebaseIdpConfig firebaseConfiguration(Map<String, String> environment) {
  final projectId = environment['FIREBASE_PROJECT_ID']?.trim();
  if (projectId == null ||
      !RegExp(r'^[a-z][a-z0-9-]{4,28}[a-z0-9]$').hasMatch(projectId)) {
    throw StateError(
      'Set FIREBASE_PROJECT_ID to the selected Firebase project before enabling authentication.',
    );
  }
  return FirebaseIdpConfig(
    credentials: FirebaseServiceAccountCredentials(projectId: projectId),
    firebaseAccountDetailsValidation: FirebaseIdpConfig.requireVerifiedEmail,
  );
}
