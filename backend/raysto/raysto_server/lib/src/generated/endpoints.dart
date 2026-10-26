/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _idt;
import 'package:raysto_server/src/generated/cart_line.dart' as _ifrjnlf7;
import 'package:raysto_server/src/generated/future_calls.dart' as _iumpf3gz;
import 'package:raysto_server/src/generated/platform/allocate_payment.dart'
    as _ilxdd4ja;
import 'package:raysto_server/src/generated/platform/create_quote.dart'
    as _idq38b00;
import 'package:raysto_server/src/generated/platform/platform_command.dart'
    as _iv1e8li7;
import 'package:raysto_server/src/generated/platform/request_refund.dart'
    as _i6w4orm5;
import 'package:raysto_server/src/generated/platform/start_visit.dart'
    as _ib0xrr85;
import 'package:raysto_server/src/generated/platform/submit_order.dart'
    as _iv7abq5k;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/firebase_endpoint.dart' as _i3k73vau;
import '../auth/guest_endpoint.dart' as _ibkbr31c;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/catalog_endpoint.dart' as _i32f0vjp;
import '../endpoints/commerce_endpoint.dart' as _ix7awdju;
import '../endpoints/platform_endpoint.dart' as _ibj2cm6k;
import '../endpoints/restaurant_endpoint.dart' as _iext627r;
import '../endpoints/sandbox_payments_endpoint.dart' as _iccl7wzi;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'firebase': _i3k73vau.FirebaseEndpoint()
        ..initialize(
          server,
          'firebase',
          null,
        ),
      'guest': _ibkbr31c.GuestEndpoint()
        ..initialize(
          server,
          'guest',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'catalog': _i32f0vjp.CatalogEndpoint()
        ..initialize(
          server,
          'catalog',
          null,
        ),
      'commerce': _ix7awdju.CommerceEndpoint()
        ..initialize(
          server,
          'commerce',
          null,
        ),
      'platform': _ibj2cm6k.PlatformEndpoint()
        ..initialize(
          server,
          'platform',
          null,
        ),
      'restaurant': _iext627r.RestaurantEndpoint()
        ..initialize(
          server,
          'restaurant',
          null,
        ),
      'sandboxPayments': _iccl7wzi.SandboxPaymentsEndpoint()
        ..initialize(
          server,
          'sandboxPayments',
          null,
        ),
    };
    connectors['firebase'] = _is.EndpointConnector(
      name: 'firebase',
      endpoint: endpoints['firebase']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'idToken': _is.ParameterDescription(
              name: 'idToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['firebase'] as _i3k73vau.FirebaseEndpoint).login(
                    session,
                    idToken: params['idToken'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['firebase'] as _i3k73vau.FirebaseEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['guest'] = _is.EndpointConnector(
      name: 'guest',
      endpoint: endpoints['guest']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['guest'] as _ibkbr31c.GuestEndpoint).login(
                session,
                token: params['token'],
              ),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['catalog'] = _is.EndpointConnector(
      name: 'catalog',
      endpoint: endpoints['catalog']!,
      methodConnectors: {
        'restaurants': _is.MethodConnector(
          name: 'restaurants',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['catalog'] as _i32f0vjp.CatalogEndpoint)
                  .restaurants(session),
        ),
        'menu': _is.MethodConnector(
          name: 'menu',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['catalog'] as _i32f0vjp.CatalogEndpoint).menu(
                    session,
                    params['restaurantId'],
                  ),
        ),
      },
    );
    connectors['commerce'] = _is.EndpointConnector(
      name: 'commerce',
      endpoint: endpoints['commerce']!,
      methodConnectors: {
        'placeOrder': _is.MethodConnector(
          name: 'placeOrder',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'lines': _is.ParameterDescription(
              name: 'lines',
              type: _is.getType<List<_ifrjnlf7.CartLine>>(),
              nullable: false,
            ),
            'fulfillment': _is.ParameterDescription(
              name: 'fulfillment',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'address': _is.ParameterDescription(
              name: 'address',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'requestKey': _is.ParameterDescription(
              name: 'requestKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .placeOrder(
                    session,
                    params['restaurantId'],
                    params['lines'],
                    params['fulfillment'],
                    params['address'],
                    params['requestKey'],
                  ),
        ),
        'order': _is.MethodConnector(
          name: 'order',
          params: {
            'orderId': _is.ParameterDescription(
              name: 'orderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['commerce'] as _ix7awdju.CommerceEndpoint).order(
                    session,
                    params['orderId'],
                  ),
        ),
        'myOrders': _is.MethodConnector(
          name: 'myOrders',
          params: {
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .myOrders(
                    session,
                    params['offset'],
                  ),
        ),
        'checkout': _is.MethodConnector(
          name: 'checkout',
          params: {
            'orderId': _is.ParameterDescription(
              name: 'orderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .checkout(
                    session,
                    params['orderId'],
                  ),
        ),
        'capture': _is.MethodConnector(
          name: 'capture',
          params: {
            'orderId': _is.ParameterDescription(
              name: 'orderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['commerce'] as _ix7awdju.CommerceEndpoint).capture(
                    session,
                    params['orderId'],
                  ),
        ),
        'registerDevice': _is.MethodConnector(
          name: 'registerDevice',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .registerDevice(
                    session,
                    params['token'],
                  ),
        ),
        'unregisterDevice': _is.MethodConnector(
          name: 'unregisterDevice',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .unregisterDevice(
                    session,
                    params['token'],
                  ),
        ),
        'requestService': _is.MethodConnector(
          name: 'requestService',
          params: {
            'orderId': _is.ParameterDescription(
              name: 'orderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .requestService(
                    session,
                    params['orderId'],
                    params['kind'],
                  ),
        ),
      },
    );
    connectors['platform'] = _is.EndpointConnector(
      name: 'platform',
      endpoint: endpoints['platform']!,
      methodConnectors: {
        'command': _is.MethodConnector(
          name: 'command',
          params: {
            'operation': _is.ParameterDescription(
              name: 'operation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'command': _is.ParameterDescription(
              name: 'command',
              type: _is.getType<_iv1e8li7.PlatformCommand>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint).command(
                    session,
                    params['operation'],
                    params['command'],
                  ),
        ),
        'query': _is.MethodConnector(
          name: 'query',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'parametersJson': _is.ParameterDescription(
              name: 'parametersJson',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint).query(
                    session,
                    params['name'],
                    params['parametersJson'],
                  ),
        ),
        'createQuote': _is.MethodConnector(
          name: 'createQuote',
          params: {
            'command': _is.ParameterDescription(
              name: 'command',
              type: _is.getType<_idq38b00.CreateQuote>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint)
                  .createQuote(
                    session,
                    params['command'],
                  ),
        ),
        'submitOrder': _is.MethodConnector(
          name: 'submitOrder',
          params: {
            'command': _is.ParameterDescription(
              name: 'command',
              type: _is.getType<_iv7abq5k.SubmitOrder>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint)
                  .submitOrder(
                    session,
                    params['command'],
                  ),
        ),
        'startVisit': _is.MethodConnector(
          name: 'startVisit',
          params: {
            'command': _is.ParameterDescription(
              name: 'command',
              type: _is.getType<_ib0xrr85.StartVisit>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint)
                  .startVisit(
                    session,
                    params['command'],
                  ),
        ),
        'allocatePayment': _is.MethodConnector(
          name: 'allocatePayment',
          params: {
            'command': _is.ParameterDescription(
              name: 'command',
              type: _is.getType<_ilxdd4ja.AllocatePayment>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint)
                  .allocatePayment(
                    session,
                    params['command'],
                  ),
        ),
        'requestRefund': _is.MethodConnector(
          name: 'requestRefund',
          params: {
            'command': _is.ParameterDescription(
              name: 'command',
              type: _is.getType<_i6w4orm5.RequestRefund>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint)
                  .requestRefund(
                    session,
                    params['command'],
                  ),
        ),
        'uploadContent': _is.MethodConnector(
          name: 'uploadContent',
          params: {
            'mediaId': _is.ParameterDescription(
              name: 'mediaId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'bytes': _is.ParameterDescription(
              name: 'bytes',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint)
                  .uploadContent(
                    session,
                    params['mediaId'],
                    params['bytes'],
                  ),
        ),
        'events': _is.MethodStreamConnector(
          name: 'events',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'after': _is.ParameterDescription(
              name: 'after',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['platform'] as _ibj2cm6k.PlatformEndpoint).events(
                session,
                params['restaurantId'],
                params['after'],
              ),
        ),
      },
    );
    connectors['restaurant'] = _is.EndpointConnector(
      name: 'restaurant',
      endpoint: endpoints['restaurant']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'currency': _is.ParameterDescription(
              name: 'currency',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deliveryFeeMinor': _is.ParameterDescription(
              name: 'deliveryFeeMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .create(
                        session,
                        params['name'],
                        params['currency'],
                        params['deliveryFeeMinor'],
                      ),
        ),
        'publish': _is.MethodConnector(
          name: 'publish',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'published': _is.ParameterDescription(
              name: 'published',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .publish(
                        session,
                        params['restaurantId'],
                        params['published'],
                      ),
        ),
        'setStaff': _is.MethodConnector(
          name: 'setStaff',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'userId': _is.ParameterDescription(
              name: 'userId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'active': _is.ParameterDescription(
              name: 'active',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .setStaff(
                        session,
                        params['restaurantId'],
                        params['userId'],
                        params['role'],
                        params['active'],
                      ),
        ),
        'saveProduct': _is.MethodConnector(
          name: 'saveProduct',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'productId': _is.ParameterDescription(
              name: 'productId',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'priceMinor': _is.ParameterDescription(
              name: 'priceMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'available': _is.ParameterDescription(
              name: 'available',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .saveProduct(
                        session,
                        params['restaurantId'],
                        params['productId'],
                        params['name'],
                        params['description'],
                        params['priceMinor'],
                        params['available'],
                      ),
        ),
        'transition': _is.MethodConnector(
          name: 'transition',
          params: {
            'orderId': _is.ParameterDescription(
              name: 'orderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'expectedVersion': _is.ParameterDescription(
              name: 'expectedVersion',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'nextStatus': _is.ParameterDescription(
              name: 'nextStatus',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .transition(
                        session,
                        params['orderId'],
                        params['expectedVersion'],
                        params['nextStatus'],
                      ),
        ),
        'orders': _is.MethodConnector(
          name: 'orders',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .orders(
                        session,
                        params['restaurantId'],
                        params['offset'],
                        params['limit'],
                      ),
        ),
        'queue': _is.MethodConnector(
          name: 'queue',
          params: {
            'restaurantId': _is.ParameterDescription(
              name: 'restaurantId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restaurant'] as _iext627r.RestaurantEndpoint)
                      .queue(
                        session,
                        params['restaurantId'],
                      ),
        ),
      },
    );
    connectors['sandboxPayments'] = _is.EndpointConnector(
      name: 'sandboxPayments',
      endpoint: endpoints['sandboxPayments']!,
      methodConnectors: {
        'start': _is.MethodConnector(
          name: 'start',
          params: {
            'requestKey': _is.ParameterDescription(
              name: 'requestKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sandboxPayments']
                          as _iccl7wzi.SandboxPaymentsEndpoint)
                      .start(
                        session,
                        params['requestKey'],
                      ),
        ),
        'read': _is.MethodConnector(
          name: 'read',
          params: {
            'paymentId': _is.ParameterDescription(
              name: 'paymentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sandboxPayments']
                          as _iccl7wzi.SandboxPaymentsEndpoint)
                      .read(
                        session,
                        params['paymentId'],
                      ),
        ),
        'checkout': _is.MethodConnector(
          name: 'checkout',
          params: {
            'paymentId': _is.ParameterDescription(
              name: 'paymentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sandboxPayments']
                          as _iccl7wzi.SandboxPaymentsEndpoint)
                      .checkout(
                        session,
                        params['paymentId'],
                      ),
        ),
        'capture': _is.MethodConnector(
          name: 'capture',
          params: {
            'paymentId': _is.ParameterDescription(
              name: 'paymentId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sandboxPayments']
                          as _iccl7wzi.SandboxPaymentsEndpoint)
                      .capture(
                        session,
                        params['paymentId'],
                      ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _iumpf3gz.FutureCalls();
  }
}
