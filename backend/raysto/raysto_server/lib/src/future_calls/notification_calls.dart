import 'package:serverpod/serverpod.dart';
import '../services/firebase_services.dart';

/// Schedule from a trusted AWS task; no public dispatch endpoint is exposed.
class NotificationCalls extends FutureCall {
  Future<void> dispatch(Session session) async {
    await FirebaseServices.fromEnvironment().dispatchOutbox(session);
  }
}
