import 'package:raysto_client/raysto_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// Explicit opt-in connection. The approved offline demo is never silently
/// treated as server data.
class BackendConnection {
  final Client client;
  final Uri apiUrl;

  BackendConnection(this.apiUrl)
    : client = Client(_validated(apiUrl))
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = FlutterAuthSessionManager();

  static String _validated(Uri uri) {
    final local = {'localhost', '127.0.0.1', '10.0.2.2'}.contains(uri.host);
    if (uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !(uri.scheme == 'https' || local && uri.scheme == 'http')) {
      throw ArgumentError(
        'Use an HTTPS backend URL (HTTP is allowed only for local development).',
      );
    }
    return uri.toString().endsWith('/') ? uri.toString() : '${uri.toString()}/';
  }

  factory BackendConnection.fromEnvironment() {
    const url = String.fromEnvironment('RAYSTO_API_URL');
    if (url.isEmpty) {
      throw StateError('RAYSTO_API_URL is required for server mode.');
    }
    return BackendConnection(Uri.parse(url));
  }
}
