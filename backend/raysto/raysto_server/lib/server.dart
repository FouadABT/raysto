import 'dart:io';
import 'package:serverpod_auth_idp_server/core.dart';
import 'src/auth/firebase_configuration.dart';
import 'src/generated/serverpod.dart';
import 'src/web/api_routes.dart';
import 'src/web/platform_routes.dart';
import 'src/web/pay_link_route.dart';
import 'src/web/partner_routes.dart';
import 'src/web/platform_readiness.dart';
import 'src/platform/platform.dart';

/// No implicit demo sign-in, email logger, or alternative cloud storage provider.
void run(List<String> args) async {
  final pod = Serverpod(args);
  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      if (Platform.environment['RAYSTO_GUESTS_ENABLED'] == 'true')
        IdentityModule.guestConfiguration(),
      if (Platform.environment['RAYSTO_FIREBASE_ENABLED'] == 'true')
        firebaseConfiguration(Platform.environment),
    ],
  );
  if (Platform.environment['RAYSTO_PLATFORM_V2_ENABLED'] == 'true') {
    pod.authenticationHandler = PlatformApi.authenticate;
  }
  pod.webServer.addRoute(HealthRoute(), '/health');
  pod.webServer.addRoute(PlatformReadinessRoute(), '/ready');
  pod.webServer.addRoute(PlatformRoute(), '/api/v2/**');
  pod.webServer.addRoute(OrderReportRoute(), '/api/v1/orders');
  pod.webServer.addRoute(PayPalWebhookRoute(), '/webhooks/paypal');
  pod.webServer.addRoute(PayPalReturnRoute(), '/payments/return');
  pod.webServer.addRoute(PayPalReturnRoute(), '/payments/cancel');
  // 0.16: pay links (stream S1) and the Delivery Partner API (stream S2).
  pod.webServer.addRoute(PayLinkRoute(), '/pay/**');
  pod.webServer.addRoute(PartnerRoute(), '/api/partner/v1/**');
  await pod.start();
  if (Platform.environment['RAYSTO_PLATFORM_V2_ENABLED'] == 'true' &&
      Platform.environment['RAYSTO_PLATFORM_WORKER_ENABLED'] == 'true') {
    await pod.futureCalls.cancel('raysto-platform');
    await pod.futureCalls
        .callRecurring(identifier: 'raysto-platform')
        .every(const Duration(seconds: 15))
        .platformCalls
        .dispatch();
    // AI work runs beside the core lane; production.yaml allows concurrent
    // future calls (futureCall.concurrencyLimit) so neither waits on the other.
    await pod.futureCalls.cancel('raysto-ai');
    await pod.futureCalls
        .callRecurring(identifier: 'raysto-ai')
        .every(const Duration(seconds: 3))
        .platformCalls
        .dispatchAi();
  }
  if (Platform.environment['RAYSTO_NOTIFICATIONS_ENABLED'] == 'true') {
    // Enable this on exactly one scheduler instance in a multi-instance deployment.
    await pod.futureCalls.cancel('raysto-notifications');
    await pod.futureCalls
        .callRecurring(identifier: 'raysto-notifications')
        .every(const Duration(seconds: 30))
        .notificationCalls
        .dispatch();
  }
}
