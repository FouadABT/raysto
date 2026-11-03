// Shared fixture for the money agents' tests: a USD café with one dish, an
// owner who can pass the identity check, a diner, a fake Gemini that answers
// with the function calls a test scripts, and the PayPal MCP stdio fixture.
// Isolated Raysto test database only; no provider is ever called.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/services/paypal_mcp_client.dart';
import 'test_tools/serverpod_test_tools.dart';

class MoneyAgentsFixture {
  MoneyAgentsFixture(this.builder, this.prefix);
  final TestSessionBuilder builder;
  final String prefix;
  late TestSessionBuilder owner, customer;
  late Restaurant restaurant;
  late int burger;
  String get ownerUser => '$prefix-owner';
  String get ownerAuth => '$prefix-owner-session';
  String get customerUser => '$prefix-customer';
  var _serial = 0;
  String key() => '${prefix}_${(++_serial).toString().padLeft(8, '0')}';

  TestSessionBuilder session(String user, {String? authId}) =>
      builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          user,
          {},
          authId: authId,
        ),
      );

  PlatformCommand command(Json data, {int? id, int? version}) =>
      PlatformCommand(
        requestKey: key(),
        restaurantId: restaurant.id,
        resourceId: id,
        expectedVersion: version,
        dataJson: jsonEncode(data),
      );

  Future<void> setUp({Set<String> agents = const {}}) async {
    owner = session(ownerUser, authId: ownerAuth);
    customer = session(customerUser);
    final s = builder.build();
    final now = DateTime.now().toUtc();
    for (final user in [ownerUser, customerUser]) {
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
      PlatformCommand(
        requestKey: key(),
        dataJson: '{"name":"Money agents fixture","currency":"USD"}',
      ),
    );
    restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
    restaurant.published = true;
    await Restaurant.db.updateRow(s, restaurant);
    final policy = (await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(restaurant.id!),
    ))!;
    policy.settingsJson = jsonEncode({
      ...CatalogueModule.defaults,
      'taxConfigured': true,
      'address': 'Fixture street',
      'contactEmail': 'owner@example.test',
      'country': 'US',
      'timezone': 'America/New_York',
      'hours': [
        for (var day = 1; day <= 7; day++)
          {'day': day, 'start': 0, 'end': 1440},
      ],
    });
    await RestaurantPolicy.db.updateRow(s, policy);
    burger =
        (await CatalogueModule.saveItem(
              owner.build(),
              command({
                'name': 'Burger',
                'category': 'Mains',
                'priceMinor': 900,
              }, version: 1),
            ))['id']
            as int;
    AgentModule.environment = () => {
      ...Platform.environment,
      for (final a in agents) 'RAYSTO_AGENT_${a.toUpperCase()}_ENABLED': 'true',
    };
    ProviderClients.environment = () => {
      ...Platform.environment,
      'GEMINI_API_KEY': 'fixture-key',
    };
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

  Future<void> patchSettings(Json patch) async {
    final s = builder.build();
    final policy = (await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(restaurant.id!),
    ))!;
    policy.settingsJson = jsonEncode({
      ...jsonDecode(policy.settingsJson) as Map,
      ...patch,
    });
    await RestaurantPolicy.db.updateRow(s, policy);
  }

  /// A pickup order of one burger, paid in cash at the counter.
  Future<int> paidOrder() async {
    final q = await OrderingModule.quote(
      customer.build(),
      CreateQuote(
        requestKey: key(),
        restaurantId: restaurant.id!,
        fulfillment: 'pickup',
        linesJson: jsonEncode([
          {'productId': burger, 'quantity': 1},
        ]),
        tipMinor: 0,
      ),
    );
    final orderId =
        (await OrderingModule.submit(
              customer.build(),
              SubmitOrder(
                requestKey: key(),
                restaurantId: restaurant.id!,
                quoteId: q['id'] as int,
              ),
            ))['orderId']
            as int;
    await MoneyModule.allocate(
      owner.build(),
      AllocatePayment(
        requestKey: key(),
        restaurantId: restaurant.id!,
        orderId: orderId,
        method: 'cash',
      ),
    );
    return orderId;
  }

  /// The owner has just confirmed their identity.
  Future<void> grantStepUp() async {
    final s = builder.build();
    final now = DateTime.now().toUtc();
    await SecurityGrant.db.insertRow(
      s,
      SecurityGrant(
        userId: ownerUser,
        kind: 'recent_auth',
        proofHash: sha256
            .convert(utf8.encode('stepup:$ownerUser:$ownerAuth:recent_auth'))
            .toString(),
        expiresAt: now.add(const Duration(minutes: 5)),
        createdAt: now,
      ),
    );
  }

  /// Gemini answers turn by turn with the given function calls; a turn given
  /// as a string is a plain text answer.
  void scriptGemini(List<Object> turns, {List<String>? prompts}) {
    var turn = 0;
    String sse(List<Json> parts) =>
        'data: ${jsonEncode({
          'candidates': [
            {
              'index': 0,
              'content': {'role': 'model', 'parts': parts},
              'finishReason': 'STOP',
            },
          ],
          'usageMetadata': {'promptTokenCount': 400, 'candidatesTokenCount': 60, 'totalTokenCount': 460},
        })}\r\n\r\n';
    ProviderClients.httpClient = () => MockClient((r) async {
      if (r.url.path.endsWith(':countTokens')) {
        return http.Response('{"totalTokens": 400}', 200);
      }
      prompts?.add(r.body);
      final script = turns[turn < turns.length ? turn : turns.length - 1];
      turn++;
      final parts = script is String
          ? [
              {'text': script},
            ]
          : [
              for (final call in script as List<Json>)
                {'functionCall': call},
            ];
      return http.Response.bytes(
        utf8.encode(sse(parts)),
        200,
        headers: {'content-type': 'text/event-stream; charset=utf-8'},
      );
    });
  }

  /// The PayPal MCP stdio protocol fixture stands in for PayPal's server.
  void useMcpFixture() {
    CateringAgent.mcp = () => PayPalMcpClient.stdio(
      accessToken: () async => 'fixture-token',
      executable: Platform.resolvedExecutable,
      script: File('test/fixtures/paypal_mcp_stdio_fixture.dart').absolute.path,
    );
  }

  Future<List<AgentAction>> actionsOf(int taskId) => AgentAction.db.find(
    builder.build(),
    where: (t) => t.taskId.equals(taskId),
    orderBy: (t) => t.ordinal,
  );

  Future<Json> decide(AgentAction a, {String decision = 'approve'}) =>
      AgentModule.decide(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: a.id,
          expectedVersion: a.version,
          dataJson: jsonEncode({'decision': decision}),
        ),
      );
}
