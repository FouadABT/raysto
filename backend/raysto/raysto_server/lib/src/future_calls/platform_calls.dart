import 'package:serverpod/serverpod.dart';
import '../platform/platform.dart';

class PlatformCalls extends FutureCall {
  Future<void> dispatch(Session session) async {
    await PlatformWorker.dispatch(session);
  }
}
