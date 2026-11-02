/// The hackathon judges' build: their published logins, compiled in with
/// `--dart-define`. Every account here is on PayPal Sandbox. Without the
/// defines the app is the ordinary build.
class JudgeBuild {
  const JudgeBuild._();
  static const dinerEmail = String.fromEnvironment('RAYSTO_JUDGE_DINER_EMAIL');
  static const dinerPassword = String.fromEnvironment(
    'RAYSTO_JUDGE_DINER_PASSWORD',
  );
  static const managerEmail = String.fromEnvironment('RAYSTO_JUDGE_EMAIL');
  static const managerPassword = String.fromEnvironment(
    'RAYSTO_JUDGE_PASSWORD',
  );
  static bool get enabled =>
      dinerEmail.isNotEmpty &&
      dinerPassword.isNotEmpty &&
      managerEmail.isNotEmpty &&
      managerPassword.isNotEmpty;
}
