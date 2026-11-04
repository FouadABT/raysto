part of 'platform.dart';

/// The AI accountant: reads the journal, bills, requests and payouts,
/// explains rule-based anomalies and proposes payments. Owner: stream S1.
class AccountantAgent {
  static const agent = 'accountant';

  /// Approval commands (AgentModule.commands, 0.16 anchor).
  static final Map<String, AgentCommand> commands = {};

  static Future<AgentOutcome> run(Session s, AgentTask task) async =>
      const AgentOutcome('Not built yet.');
}
