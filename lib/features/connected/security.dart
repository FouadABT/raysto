import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../backend/live_runtime.dart';
import '../../backend/auth/session_controller.dart';
import 'forms.dart';

Future<void> resolveFactor(
  BuildContext context,
  FirebaseAuthMultiFactorException error,
) async {
  final hints = error.resolver.hints;
  final selection = await showDialog<MultiFactorInfo>(
    context: context,
    builder: (c) => SimpleDialog(
      title: const Text('Verify your identity'),
      children: [
        for (final factor in hints)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, factor),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                factor.displayName ??
                    (factor is TotpMultiFactorInfo
                        ? 'Authenticator app'
                        : 'SMS verification'),
              ),
            ),
          ),
      ],
    ),
  );
  if (selection == null || !context.mounted) throw AccountSignInCanceled();
  String? verificationId;
  if (selection is PhoneMultiFactorInfo) {
    final completed = await _sendSms(error, selection);
    verificationId = completed;
  }
  if (!context.mounted) throw AccountSignInCanceled();
  final code = await editFields(
    context,
    'Verification code',
    const [
      InputSpec(
        'code',
        'Code',
        help: 'Enter the current code from your authenticator or SMS.',
      ),
    ],
    save: (data) async {
      final assertion = selection is TotpMultiFactorInfo
          ? await TotpMultiFactorGenerator.getAssertionForSignIn(
              selection.uid,
              data['code'],
            )
          : PhoneMultiFactorGenerator.getAssertion(
              PhoneAuthProvider.credential(
                verificationId: verificationId!,
                smsCode: data['code'],
              ),
            );
      await error.resolver.resolveSignIn(assertion);
      return {'verified': true};
    },
    submit: 'Verify',
  );
  if (code == null) throw AccountSignInCanceled();
}

Future<String> _sendSms(
  FirebaseAuthMultiFactorException error,
  PhoneMultiFactorInfo factor,
) async {
  // The SDK owns SMS verification; the code is used only to resolve this challenge.
  final completer = Completer<String>();
  await FirebaseAuth.instance.verifyPhoneNumber(
    multiFactorSession: error.resolver.session,
    multiFactorInfo: factor,
    verificationCompleted: (_) {},
    verificationFailed: (e) {
      if (!completer.isCompleted) completer.completeError(e);
    },
    codeSent: (id, _) {
      if (!completer.isCompleted) completer.complete(id);
    },
    codeAutoRetrievalTimeout: (id) {
      if (!completer.isCompleted) completer.complete(id);
    },
  );
  return completer.future;
}

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key, required this.runtime});
  final LiveRuntime runtime;
  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool busy = false;
  String? message;
  Future<void> reauthenticate() async {
    final user = widget.runtime.firebase.currentUser!;
    try {
      if (user.providerData.any((p) => p.providerId == 'password')) {
        final value = await editFields(
          context,
          'Confirm your password',
          const [InputSpec('password', 'Password', kind: 'password')],
          save: (v) async {
            try {
              await user.reauthenticateWithCredential(
                EmailAuthProvider.credential(
                  email: user.email!,
                  password: v['password'],
                ),
              );
            } on FirebaseAuthMultiFactorException catch (e) {
              if (!mounted) rethrow;
              await resolveFactor(context, e);
            }
            return {'verified': true};
          },
        );
        if (value == null) throw AccountSignInCanceled();
      } else {
        final google = await GoogleSignIn.instance.authenticate();
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken: google.authentication.idToken),
        );
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      if (!mounted) rethrow;
      await resolveFactor(context, e);
    }
  }

  Future<void> run(Future<void> Function() work) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await work();
      if (mounted) {
        setState(
          () => message =
              'Identity verified. You can continue your sensitive action.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              message = e is AccountSignInCanceled ? 'Verification cancelled.' : 'Verification could not be completed. Check your credentials and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> stepUp() async {
    await reauthenticate();
    await widget.runtime.platform.command('identity.stepUp', {
      'firebaseIdToken': await widget.runtime.firebase.currentUser!.getIdToken(
        true,
      ),
    });
  }

  Future<void> enroll() async {
    await reauthenticate();
    final user = widget.runtime.firebase.currentUser!;
    final secret = await TotpMultiFactorGenerator.generateSecret(
      await user.multiFactor.getSession(),
    );
    final url = await secret.generateQrCodeUrl(
      accountName: user.email,
      issuer: 'Raysto',
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Raysto to your authenticator'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: url, size: 200),
              const Text(
                'Scan with your authenticator, or enter this setup key:',
              ),
              SelectableText(secret.secretKey),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    await editFields(
      context,
      'Confirm authenticator',
      const [InputSpec('code', 'Authenticator code')],
      save: (v) async {
        await user.multiFactor.enroll(
          await TotpMultiFactorGenerator.getAssertionForEnrollment(
            secret,
            v['code'],
          ),
          displayName: 'Raysto authenticator',
        );
        return {'enrolled': true};
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Account security')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Confirm your identity before refunds or account changes. Ownership and payment settings also require a second factor.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: busy ? null : () => run(stepUp),
          child: const Text('Verify identity'),
        ),
        OutlinedButton(
          onPressed: busy ? null : () => run(enroll),
          child: const Text('Add authenticator app'),
        ),
        if (busy) const LinearProgressIndicator(),
        if (message != null) Text(message!),
      ],
    ),
  );
}
