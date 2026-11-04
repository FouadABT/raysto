import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/services/paypal_mcp_client.dart';
import 'package:test/test.dart';
import '../fixtures/money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

/// One café for the accountant's tests (stream S1): an owner, a customer, a
/// burger at 9.00 with 10% tax on top, PayPal Sandbox and Gemini faked by
/// [MoneyAgentsUpstream], and a scripted vision read for bill files.
/// Isolated Raysto test database only.
class AccountantWorld {
  AccountantWorld(this.builder, this.name);

  final TestSessionBuilder builder;
  final String name;

  late TestSessionBuilder owner, customer;
  late Restaurant restaurant;
  late int burger;
  late MoneyAgentsUpstream upstream;

  /// The model's tool turns; replace per test.
  List<Json> Function(int turn, Json body) script = (_, _) => [
    {'text': 'Nothing to add.'},
  ];

  /// What the vision call reads from the next bill file.
  Json vision = const {};
  int visionCalls = 0;

  String get ownerId => '$name-owner';
  String get ownerAuth => '$name-owner-session';
  var _serial = 0;
  String key() => '${name}_fixture_${(++_serial).toString().padLeft(8, '0')}';

  TestSessionBuilder session(String user, {String? authId}) => builder.copyWith(
    authentication: AuthenticationOverride.authenticationInfo(user, {}, authId: authId),
  );

  PlatformCommand command(Json data, {int? id, int? version}) => PlatformCommand(
    requestKey: key(),
    restaurantId: restaurant.id,
    resourceId: id,
    expectedVersion: version,
    dataJson: jsonEncode(data),
  );

  Map<String, String> env = {};

  Future<void> setUp({Json settings = const {}}) async {
    owner = session(ownerId, authId: ownerAuth);
    customer = session('$name-customer');
    final s = builder.build();
    final now = DateTime.now().toUtc();
    for (final user in [ownerId, '$name-customer']) {
      await ActorProfile.db.insertRow(
        s,
        ActorProfile(
          userId: user,
          isGuest: false,
          disabled: false,
          dataJson: '{}',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    final created = await IdentityModule.createRestaurant(
      owner.build(),
      PlatformCommand(requestKey: key(), dataJson: '{"name":"Books fixture","currency":"USD"}'),
    );
    restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
    restaurant.published = true;
    await Restaurant.db.updateRow(s, restaurant);
    await patchSettings({
      ...CatalogueModule.defaults,
      'taxConfigured': true,
      'taxBps': 1000,
      // Tax on top: a 9.00 burger is charged 9.90.
      'pricesIncludeTax': false,
      'address': 'Fixture street',
      'contactEmail': 'owner@example.test',
      'country': 'US',
      'timezone': 'UTC',
      'hours': [
        for (var day = 1; day <= 7; day++) {'day': day, 'start': 0, 'end': 1440},
      ],
      ...settings,
    });
    burger = (await CatalogueModule.saveItem(
      owner.build(),
      command({'name': 'Burger', 'category': 'Mains', 'priceMinor': 900}, version: 1),
    ))['id'] as int;
    upstream = MoneyAgentsUpstream(gemini: (turn, body) => script(turn, body));
    ProviderClients.httpClient = client;
    env = {
      ...Platform.environment,
      'GEMINI_API_KEY': 'fixture-key',
      'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
      'RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED': 'true',
      'RAYSTO_SANDBOX_RESTAURANT_ID': '${restaurant.id}',
      'PAYPAL_SANDBOX_MERCHANT_ID': 'MERCHANT-FIXTURE',
      'PAYPAL_SANDBOX_CLIENT_ID': 'fixture-client',
      'PAYPAL_SANDBOX_CLIENT_SECRET': 'fixture-secret',
      'PAYPAL_V2_RETURN_URL': 'https://example.test/return',
      'PAYPAL_V2_CANCEL_URL': 'https://example.test/cancel',
      'RAYSTO_PUBLIC_API_URL': 'https://api.example.test',
      'RAYSTO_PAY_LINK_SECRET': 'fixture-pay-link-secret',
      // No email channel in tests: a send must say so, never pretend.
      'AWS_SES_REGION': '',
    };
    ProviderClients.environment = () => env;
    AgentModule.environment = () => {
      ...Platform.environment,
      'RAYSTO_AGENT_ACCOUNTANT_ENABLED': 'true',
      'RAYSTO_AGENT_CLOSE_ENABLED': 'true',
    };
    AiBudget.environment = () => {
      ...Platform.environment,
      'RAYSTO_AI_BUDGET_STAGE': 'hackathon',
      'RAYSTO_AI_INPUT_USD_PER_MILLION': '0.75',
      'RAYSTO_AI_OUTPUT_USD_PER_MILLION': '3.75',
      'RAYSTO_AI_TENANT_DAILY_MICROS': '2000000',
    };
    MenuAgent.readFile = (_) async => Uint8List.fromList(utf8.encode('%PDF-1.4 fixture bill'));
    // PayPal's MCP server is unreachable here: an invoice must fail honestly.
    CateringAgent.mcp = () => PayPalMcpClient(
      accessToken: () async => 'fixture',
      client: MockClient((_) async => http.Response('{}', 503)),
    );
  }

  void tearDown() {
    AgentModule.environment = () => Platform.environment;
    AiBudget.environment = () => Platform.environment;
    ProviderClients.environment = () => Platform.environment;
    ProviderClients.httpClient = http.Client.new;
    CateringAgent.mcp = () => PayPalMcpClient.configured(
      ProviderClients.environment(),
      accessToken: ProviderClients.paypalReadToken,
    );
  }

  /// The upstream, plus the one-shot vision read (a Gemini call without
  /// tools) that MoneyAgentsUpstream does not script.
  http.Client client() {
    final inner = upstream.client();
    return MockClient((r) async {
      if (r.url.host.contains('generativelanguage') && !r.url.path.endsWith(':countTokens')) {
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        if (body['tools'] == null) {
          visionCalls++;
          return http.Response.bytes(
            utf8.encode(upstream.sse([
              {'text': jsonEncode(vision)},
            ])),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        }
      }
      final copy = http.Request(r.method, r.url)
        ..headers.addAll(r.headers)
        ..bodyBytes = r.bodyBytes;
      return http.Response.fromStream(await inner.send(copy));
    });
  }

  Future<void> patchSettings(Json patch) async {
    final s = builder.build();
    final policy = (await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(restaurant.id!),
    ))!;
    policy.settingsJson = jsonEncode({...jsonDecode(policy.settingsJson) as Map, ...patch});
    await RestaurantPolicy.db.updateRow(s, policy);
  }

  Future<void> stepUp() => SecurityGrant.db.insertRow(
    builder.build(),
    SecurityGrant(
      userId: ownerId,
      kind: 'recent_auth',
      proofHash: sha256.convert(utf8.encode('stepup:$ownerId:$ownerAuth:recent_auth')).toString(),
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      createdAt: DateTime.now().toUtc(),
    ),
  );

  /// A scanned file, as the upload pipeline leaves it.
  Future<int> file(String purpose, String seed) async => (await MediaAsset.db.insertRow(
    builder.build(),
    MediaAsset(
      restaurantId: restaurant.id,
      userId: ownerId,
      purpose: purpose,
      objectName: 'v2/quarantine/$seed',
      mime: 'application/pdf',
      byteLength: 21,
      sha256: sha256.convert(utf8.encode(seed)).toString(),
      status: 'approved',
      public: false,
      metadataJson: '{"pages":1}',
      createdAt: DateTime.now().toUtc(),
    ),
  )).id!;

  /// A pickup order paid through the fake PayPal: [quantity] burgers and a tip.
  Future<int> sale({int quantity = 2, int tipMinor = 0, String method = 'paypal'}) async {
    final q = await OrderingModule.quote(
      customer.build(),
      CreateQuote(
        requestKey: key(),
        restaurantId: restaurant.id!,
        fulfillment: 'pickup',
        linesJson: jsonEncode([
          {'productId': burger, 'quantity': quantity},
        ]),
        tipMinor: tipMinor,
      ),
    );
    final id = (await OrderingModule.submit(
      customer.build(),
      SubmitOrder(requestKey: key(), restaurantId: restaurant.id!, quoteId: q['id'] as int),
    ))['orderId'] as int;
    final checkout = (await MoneyModule.allocate(
      customer.build(),
      AllocatePayment(requestKey: key(), restaurantId: restaurant.id!, orderId: id, method: method),
    ))['checkoutId'] as int;
    if (method == 'paypal') {
      await MoneyModule.checkout(customer.build(), command({}, id: checkout));
      upstream.status = 'APPROVED';
      expect((await MoneyModule.capture(customer.build(), command({}, id: checkout)))['state'], 'completed');
      upstream.status = 'CREATED';
    }
    return checkout;
  }

  Future<Json> read(String name, [Json d = const {}]) =>
      LedgerModule.read(owner.build(), restaurantId: restaurant.id!, name: name, d: d);

  /// A manual bill, through the same command the console uses.
  Future<Json> bill(Json fields, {bool approve = false}) => BillsModule.save(
    owner.build(),
    command({'category': 'other', ...fields, if (approve) 'approve': true}),
  );

  Future<Json> expectFailure(Future<Object?> Function() f, String code) async {
    try {
      await f();
    } on DomainError catch (e) {
      expect(e.code, code, reason: e.message);
      return {'code': e.code, 'message': e.message};
    }
    fail('Expected $code');
  }

  static String day(DateTime at) => at.toUtc().toIso8601String();
}
