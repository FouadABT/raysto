import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Personal Firebase data only. SQL owns restaurants, permissions and commerce.
/// No listeners, uploads or presence writes start merely by constructing this.
class CloudAccountServices {
  CloudAccountServices({
    required this.auth,
    required this.firestoreDatabaseId,
    required this.databaseUrl,
  });
  final FirebaseAuth auth;
  final String firestoreDatabaseId;
  final String? databaseUrl;

  String get _uid {
    final user = auth.currentUser;
    if (user == null || !user.emailVerified) {
      throw StateError('A verified Firebase account is required.');
    }
    return user.uid;
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: firestoreDatabaseId,
  );

  /// One document read; no unbounded collections or background subscriptions.
  Future<Map<String, dynamic>?> readPreferences() async {
    final uid = _uid;
    final result = await _firestore
        .doc('users/$uid')
        .get(const GetOptions(source: Source.server));
    if (_uid != uid) throw StateError('Account changed during the request.');
    return result.data();
  }

  Future<void> savePreferences({
    required String displayName,
    required String locale,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty ||
        name.length > 80 ||
        !['en', 'fr', 'ar'].contains(locale)) {
      throw ArgumentError('Invalid account preferences.');
    }
    await _firestore.doc('users/$_uid').set({
      'displayName': name,
      'locale': locale,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Reference get _avatar => FirebaseStorage.instance.ref('users/$_uid/avatar');

  Future<void> uploadAvatar(
    Uint8List bytes, {
    required String contentType,
  }) async {
    if (bytes.isEmpty ||
        bytes.length > 5 * 1024 * 1024 ||
        !['image/jpeg', 'image/png', 'image/webp'].contains(contentType)) {
      throw ArgumentError('Choose a JPEG, PNG or WebP image up to 5 MiB.');
    }
    await _avatar.putData(bytes, SettableMetadata(contentType: contentType));
  }

  /// Fetch through authenticated SDK access; do not publish download-token URLs.
  Future<Uint8List?> readAvatar() async {
    final uid = _uid;
    final result = await _avatar.getData(5 * 1024 * 1024);
    if (_uid != uid) throw StateError('Account changed during the request.');
    return result;
  }

  Future<void> deleteAvatar() => _avatar.delete();

  /// Call explicitly when a future presence feature is visible. Each connection
  /// has its own record so multiple phones cannot overwrite each other's state.
  Future<DatabaseReference> openPresenceConnection() async {
    final uid = _uid;
    if (databaseUrl == null) {
      throw StateError('Realtime Database has not been configured.');
    }
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );
    final ref = database.ref('presence/$uid').push();
    await ref.onDisconnect().set({
      'state': 'offline',
      'updatedAt': ServerValue.timestamp,
    });
    if (_uid != uid) {
      await ref.onDisconnect().cancel();
      throw StateError('Account changed during the request.');
    }
    await ref.set({'state': 'online', 'updatedAt': ServerValue.timestamp});
    return ref;
  }

  Future<void> closePresenceConnection(DatabaseReference ref) async {
    // Remove before canceling onDisconnect, retaining server cleanup on failure.
    await ref.remove();
    await ref.onDisconnect().cancel();
  }
}
