part of 'platform.dart';

/// The AI dispatcher: scores available drivers by distance and load and
/// proposes an offer. Owner: stream S2.
class DispatchAgent {
  static const agent = 'dispatch';

  /// Approval commands (AgentModule.commands, 0.16 anchor).
  static final Map<String, AgentCommand> commands = {};

  static Future<AgentOutcome> run(Session s, AgentTask task) async =>
      const AgentOutcome('Not built yet.');
}
