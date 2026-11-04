part of 'platform.dart';

/// The supply planner: forecasts stock-outs by arithmetic, proposes
/// supplier orders and runs the 3-way match. A "plan" mode of the
/// supplies agent. Owner: stream S3.
class SupplyPlanner {
  /// Approval commands (AgentModule.commands, 0.16 anchor).
  static final Map<String, AgentCommand> commands = {};
}
