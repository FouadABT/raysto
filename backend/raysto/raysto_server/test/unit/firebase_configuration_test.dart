import 'package:raysto_server/src/auth/firebase_configuration.dart';
import 'package:serverpod_auth_idp_server/providers/firebase.dart';
import 'package:test/test.dart';

void main() {
  test('Firebase project must be explicit before enabling identity', () {
    expect(() => firebaseConfiguration({}), throwsStateError);
    expect(
      () => firebaseConfiguration({
        'FIREBASE_PROJECT_ID': 'https://other-project',
      }),
      throwsStateError,
    );
    final config = firebaseConfiguration({
      'FIREBASE_PROJECT_ID': 'raysto-38505',
    });
    expect(config.credentials.projectId, 'raysto-38505');
  });
  test('server refuses unverified email independently of the client', () {
    final config = firebaseConfiguration({
      'FIREBASE_PROJECT_ID': 'raysto-38505',
    });
    expect(
      () => config.firebaseAccountDetailsValidation((
        userIdentifier: 'firebase-user',
        email: 'user@example.test',
        fullName: null,
        image: null,
        verifiedEmail: false,
        phone: null,
      )),
      throwsA(isA<FirebaseEmailNotVerifiedException>()),
    );
    config.firebaseAccountDetailsValidation((
      userIdentifier: 'firebase-user',
      email: 'user@example.test',
      fullName: null,
      image: null,
      verifiedEmail: true,
      phone: null,
    ));
  });
}
