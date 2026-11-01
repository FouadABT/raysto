import 'dart:typed_data';

import 'package:raysto_server/src/platform/platform.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only.
void main() {
  withServerpod('Backend sessions', (builder, endpoints) {
    setUpAll(() {
      try {
        AuthServices.instance;
      } on StateError {
        // The test server does not start the app's own auth setup.
        AuthServices.set(
          tokenManagerBuilders: [
            JwtConfig(
              algorithm: JwtAlgorithm.hmacSha512(
                SecretKey('fixture-hmac-key-for-tests-only'),
              ),
              refreshTokenHashPepper: 'fixture-pepper-for-tests',
            ),
          ],
        );
      }
    });

    test(
      'someone who has signed in more than 100 times is still signed in',
      () async {
        final s = builder.build();
        final user = await AuthServices.instance.authUsers.create(s);
        final other = await AuthServices.instance.authUsers.create(s);
        RefreshToken token(UuidValue owner) => RefreshToken(
          authUserId: owner,
          scopeNames: const {},
          method: 'firebase',
          fixedSecret: ByteData(16),
          rotatingSecretHash: 'fixture',
        );
        // Listing a user's tokens returns only the first 100 by id.
        final tokens = await RefreshToken.db.insert(s, [
          for (var i = 0; i < 105; i++) token(user.id),
        ]);
        final listed = {
          for (final t in await AuthServices.instance.tokenManager.listTokens(
            s,
            authUserId: user.id,
          ))
            t.tokenId,
        };
        expect(listed, hasLength(100));
        final unlisted = [
          for (final t in tokens)
            if (!listed.contains('${t.id}')) t.id!,
        ];
        expect(unlisted, hasLength(5));
        for (final id in unlisted) {
          expect(
            await PlatformApi.sessionExists(s, '${user.id}', '$id'),
            isTrue,
            reason: 'A session past the first 100 is still signed in.',
          );
        }
        final newest = unlisted.last;
        final foreign = await RefreshToken.db.insertRow(s, token(other.id));
        expect(
          await PlatformApi.sessionExists(s, '${user.id}', '${foreign.id}'),
          isFalse,
          reason: 'Another person\'s session is not this person\'s.',
        );
        expect(
          await PlatformApi.sessionExists(s, '${user.id}', 'not-a-session'),
          isFalse,
        );
        await AuthServices.instance.tokenManager.revokeAllTokens(
          s,
          authUserId: user.id,
        );
        expect(
          await PlatformApi.sessionExists(s, '${user.id}', '$newest'),
          isFalse,
          reason: 'A revoked session is gone.',
        );
      },
    );
  });
}
