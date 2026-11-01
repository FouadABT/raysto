import 'package:serverpod/serverpod.dart';
import '../platform/platform.dart';

class PlatformCalls extends FutureCall {
  Future<void> dispatch(Session session) async {
    await PlatformWorker.dispatch(session);
  }

  /// Model and agent jobs, in their own lane beside the core worker.
  Future<void> dispatchAi(Session session) async {
    await PlatformWorker.dispatch(session, lane: 'ai');
  }
}
