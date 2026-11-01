import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Agents here use a fixed handler, not a
// model, so these tests cover the approval layer itself.
void main() {
  withServerpod('AI coworkers: tasks, approvals and the AI lane', (
    builder,
    endpoints,
  ) {
    late TestSessionBuilder owner, kitchen, waiter;
    late Restaurant restaurant;
    late int burger;
    const ownerAuth = 'agents-owner-session';
    var serial = 0;
    String key() => 'agents_fixture_${(++serial).toString().padLeft(8, '0')}';
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
    List<AgentDraft> drafts = [];

    /// Runs one copilot task that proposes [drafts]; returns its actions.
    Future<List<AgentAction>> propose() async {
      final s = builder.build();
      final task = await AgentModule.asAgent(
        s,
        restaurant.id!,
        (w) => AgentModule.enqueue(
          w,
          agent: 'copilot',
          trigger: 'event',
          dedupeKey: 'fixture:${key()}',
          title: 'Fixture suggestion',
        ),
      );
      expect(task, isNotNull);
      await AgentModule.run(s, task!.id!);
      return AgentAction.db.find(
        s,
        where: (t) => t.taskId.equals(task.id!),
        orderBy: (t) => t.ordinal,
      );
    }

    Future<Json> inboxFor(String user) async {
      final s = builder.build();
      return s.db.transaction((tx) async {
        final actor = (await ActorProfile.db.findFirstRow(
          s,
          where: (t) => t.userId.equals(user),
          transaction: tx,
        ))!;
        final policy = await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
          transaction: tx,
        );
        return AgentModule.inbox(
          Work(
            s,
            tx,
            actor,
            PlatformCommand(
              requestKey: key(),
              restaurantId: restaurant.id,
              dataJson: '{}',
            ),
            restaurant,
            policy,
          ),
          {},
        );
      });
    }

    setUp(() async {
      owner = session('agents-owner', authId: ownerAuth);
      kitchen = session('agents-kitchen');
      waiter = session('agents-waiter');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in ['agents-owner', 'agents-kitchen', 'agents-waiter']) {
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
          dataJson: '{"name":"Agent fixture","currency":"EUR"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
      for (final (user, role) in [
        ('agents-kitchen', 'kitchen'),
        ('agents-waiter', 'waiter'),
      ]) {
        await Membership.db.insertRow(
          s,
          Membership(
            restaurantId: restaurant.id!,
            userId: user,
            role: role,
            active: true,
          ),
        );
      }
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
        'RAYSTO_AGENT_COPILOT_ENABLED': 'true',
      };
      AgentModule.handlers['copilot'] = (s, task) async =>
          AgentOutcome('Fixture outcome', drafts: drafts);
    });
    tearDown(() {
      AgentModule.environment = () => Platform.environment;
      AgentModule.handlers.remove('copilot');
      AiBudget.environment = () => Platform.environment;
      ProviderClients.environment = () => Platform.environment;
      ProviderClients.httpClient = http.Client.new;
    });

    Future<Json> decide(
      TestSessionBuilder who,
      AgentAction a, {
      String decision = 'approve',
      String? requestKey,
    }) => AgentModule.decide(
      who.build(),
      PlatformCommand(
        requestKey: requestKey ?? key(),
        restaurantId: restaurant.id,
        resourceId: a.id,
        expectedVersion: a.version,
        dataJson: jsonEncode({'decision': decision}),
      ),
    );

    test(
      'kitchen approves a sold-out proposal and it runs exactly once',
      () async {
        drafts = [
          AgentDraft(
            'menu.soldOut',
            'Mark Burger sold out',
            'Rejected three times in ten minutes.',
            {'productId': burger},
          ),
        ];
        final actions = await propose();
        expect(actions, hasLength(1));
        expect(actions.single.status, 'pending');
        expect(jsonDecode(actions.single.previewJson)['item'], 'Burger');

        final inbox = await inboxFor('agents-kitchen');
        expect((inbox['rows'] as List), hasLength(1));
        final waiterInbox = await inboxFor('agents-waiter');
        expect((waiterInbox['rows'] as List), isEmpty);

        await expectLater(
          decide(waiter, actions.single),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
          ),
        );
        final requestKey = key();
        final done = await decide(
          kitchen,
          actions.single,
          requestKey: requestKey,
        );
        expect(done['state'], 'executed');
        final product = (await MenuProduct.db.findById(
          builder.build(),
          burger,
        ))!;
        expect(product.available, isFalse);
        final again = await decide(
          kitchen,
          actions.single,
          requestKey: requestKey,
        );
        expect(again['state'], 'executed');
        expect(
          (await MenuProduct.db.findById(builder.build(), burger))!.version,
          product.version,
        );
      },
    );

    test('a proposal whose records changed is refused, not applied', () async {
      drafts = [
        AgentDraft('menu.soldOut', 'Sold out', 'Fixture', {
          'productId': burger,
        }),
      ];
      final action = (await propose()).single;
      final product = (await MenuProduct.db.findById(builder.build(), burger))!;
      await CatalogueModule.availability(
        owner.build(),
        command({'available': true}, id: burger, version: product.version),
      );
      final result = await decide(owner, action);
      expect(result['state'], 'stale');
      final row = (await AgentAction.db.findById(builder.build(), action.id!))!;
      expect(row.status, 'superseded');
    });

    test('money waits for a fresh identity check, then runs once', () async {
      final s = builder.build();
      final now = DateTime.now().toUtc();
      final checkout = await CheckoutIntent.db.insertRow(
        s,
        CheckoutIntent(
          restaurantId: restaurant.id!,
          userId: 'agents-owner',
          requestKey: key(),
          requestHash: 'fixture',
          providerRequestId: 'fixture-request',
          merchantId: 'MERCHANT-FIXTURE',
          state: 'created',
          method: 'paypal',
          currency: 'EUR',
          amountMinor: 900,
          commissionMinor: 0,
          commissionBps: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      drafts = [
        AgentDraft(
          'payment.release',
          'Release an abandoned payment',
          'Created 40 minutes ago and never approved at PayPal.',
          {'checkoutId': checkout.id},
        ),
      ];
      final action = (await propose()).single;
      expect(action.risk, 'money');
      final requestKey = key();
      final held = await decide(owner, action, requestKey: requestKey);
      expect(held['state'], 'approved');
      expect(held['needs'], 'reauthentication_required');
      expect(
        (await CheckoutIntent.db.findById(s, checkout.id!))!.state,
        'created',
      );
      await SecurityGrant.db.insertRow(
        s,
        SecurityGrant(
          userId: 'agents-owner',
          kind: 'recent_auth',
          proofHash: sha256
              .convert(
                utf8.encode('stepup:agents-owner:$ownerAuth:recent_auth'),
              )
              .toString(),
          expiresAt: now.add(const Duration(minutes: 5)),
          createdAt: now,
        ),
      );
      final done = await decide(owner, action, requestKey: requestKey);
      expect(done['state'], 'executed');
      expect(
        (await CheckoutIntent.db.findById(s, checkout.id!))!.state,
        'cancelled',
      );
    });

    test('the agent identity can read but never passes a role check', () async {
      final s = builder.build();
      final agent = await AgentModule.serviceActor(s, restaurant.id!);
      expect(AgentModule.isService(agent), isTrue);
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: restaurant.id!,
          userId: agent.userId,
          role: 'owner',
          active: true,
        ),
      );
      await expectLater(
        AgentModule.asAgent(s, restaurant.id!, (w) => w.role({'owner'})),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
    });

    test(
      'AI jobs run beside a payment job instead of waiting for it',
      () async {
        final s = builder.build();
        final now = DateTime.now().toUtc();
        await PlatformJob.db.insertRow(
          s,
          PlatformJob(
            restaurantId: restaurant.id,
            kind: 'payment.reconcile',
            dedupeKey: 'lane-core-${key()}',
            payloadJson: '{"checkoutId":1}',
            state: 'running',
            attempts: 1,
            availableAt: now,
            leaseUntil: now.add(const Duration(minutes: 5)),
            leaseToken: 'busy',
            createdAt: now,
          ),
        );
        final ai = await PlatformJob.db.insertRow(
          s,
          PlatformJob(
            restaurantId: restaurant.id,
            kind: 'agent.run',
            dedupeKey: 'lane-ai-${key()}',
            payloadJson: '{"taskId":999999}',
            state: 'pending',
            attempts: 0,
            availableAt: now,
            createdAt: now,
          ),
        );
        expect(await PlatformWorker.dispatch(s, lane: 'ai', limit: 1), 1);
        expect((await PlatformJob.db.findById(s, ai.id!))!.state, 'done');
      },
    );

    test(
      'the payments agent finds an abandoned checkout and drafts its release',
      () async {
        final s = builder.build();
        final now = DateTime.now().toUtc();
        final checkout = await CheckoutIntent.db.insertRow(
          s,
          CheckoutIntent(
            restaurantId: restaurant.id!,
            userId: 'agents-owner',
            requestKey: key(),
            requestHash: 'fixture',
            providerRequestId: 'fixture-request-2',
            merchantId: 'MERCHANT-FIXTURE',
            state: 'created',
            method: 'paypal',
            currency: 'EUR',
            amountMinor: 1350,
            commissionMinor: 0,
            commissionBps: 0,
            createdAt: now.subtract(const Duration(minutes: 40)),
            updatedAt: now.subtract(const Duration(minutes: 40)),
          ),
        );
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_PAYMENTS_ENABLED': 'true',
        };
        ProviderClients.environment = () => {
          ...Platform.environment,
          'GEMINI_API_KEY': 'fixture-key',
        };
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
        var turn = 0;
        final seenTools = <String>[];
        ProviderClients.httpClient = () => MockClient((r) async {
          if (r.url.path.endsWith(':countTokens')) {
            return http.Response('{"totalTokens": 400}', 200);
          }
          final body = jsonDecode(r.body) as Map;
          seenTools.addAll([
            for (final d
                in (body['tools'] as List).single['functionDeclarations']
                    as List)
              d['name'] as String,
          ]);
          turn++;
          return http.Response.bytes(
            utf8.encode(
              turn == 1
                  ? sse([
                      {
                        'functionCall': {'name': 'read_ledger', 'args': {}},
                      },
                      {
                        'functionCall': {'name': 'read_paypal', 'args': {}},
                      },
                    ])
                  : sse([
                      {
                        'functionCall': {
                          'name': 'propose_fix',
                          'args': {
                            'fix': 'release',
                            'explanation':
                                'The customer opened PayPal 40 minutes ago but never approved €13.50. Releasing it frees the bill for another payment.',
                          },
                        },
                      },
                    ]),
            ),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        });

        await PaymentAgent.sweep(s);
        final task = await AgentTask.db.findFirstRow(
          s,
          where: (t) =>
              t.dedupeKey.equals('payments:checkout:${checkout.id}:created'),
        );
        expect(task, isNotNull);
        await AgentModule.run(s, task!.id!);
        final done = (await AgentTask.db.findById(s, task.id!))!;
        expect(
          done.status,
          'done',
          reason: '${done.summary} ${done.stateJson}',
        );
        expect(done.chargedMicros, greaterThan(0));
        expect(seenTools.toSet(), {
          'read_ledger',
          'read_paypal',
          'propose_fix',
        });
        final action = (await AgentAction.db.find(
          s,
          where: (t) => t.taskId.equals(task.id!),
        )).single;
        expect(action.command, 'payment.release');
        expect(action.risk, 'money');
        expect(action.rationale, contains('40 minutes'));
        final evidence = jsonDecode(action.evidenceJson) as Map;
        expect(evidence['paypalStatus'], 'NO_PAYPAL_ORDER');
        expect(evidence['ledgerState'], 'created');
        expect(evidence['amountMinor'], 1350);
      },
    );

    test(
      'a menu photo becomes a merged, categorised draft that publishes without archiving',
      () async {
        final s = builder.build();
        final now = DateTime.now().toUtc();
        final menuVersion = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!.menuVersion;
        await CatalogueModule.saveItem(
          owner.build(),
          command({
            'name': 'Fries',
            'category': 'Sides',
            'priceMinor': 350,
          }, version: menuVersion),
        );
        final policy = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;
        policy.settingsJson = jsonEncode({
          ...CatalogueModule.defaults,
          ...jsonDecode(policy.settingsJson) as Map<String, dynamic>,
          'languages': ['en', 'fr'],
        });
        await RestaurantPolicy.db.updateRow(s, policy);
        final photo = await MediaAsset.db.insertRow(
          s,
          MediaAsset(
            restaurantId: restaurant.id,
            userId: 'agents-owner',
            purpose: 'menuSource',
            objectName: 'v2/sanitized/fixture/${key()}.jpg',
            mime: 'image/jpeg',
            byteLength: 3,
            sha256: 'fixture',
            status: 'approved',
            public: false,
            metadataJson: '{}',
            createdAt: now,
          ),
        );
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_MENU_ENABLED': 'true',
        };
        ProviderClients.environment = () => {
          ...Platform.environment,
          'GEMINI_API_KEY': 'fixture-key',
        };
        MenuAgent.readFile = (_) async =>
            Uint8List.fromList([0xff, 0xd8, 0xff]);
        addTearDown(() => MenuAgent.readFile = ProviderClients.getFile);
        String answer(Json json) =>
            'data: ${jsonEncode({
              'candidates': [
                {
                  'index': 0,
                  'content': {
                    'role': 'model',
                    'parts': [
                      {'text': jsonEncode(json)},
                    ],
                  },
                  'finishReason': 'STOP',
                },
              ],
              'usageMetadata': {'promptTokenCount': 1500, 'candidatesTokenCount': 400, 'totalTokenCount': 1900},
            })}\r\n\r\n';
        ProviderClients.httpClient = () => MockClient((r) async {
          if (r.url.path.endsWith(':countTokens')) {
            return http.Response('{"totalTokens": 1500}', 200);
          }
          final photoPage = r.body.contains('inlineData');
          final body = photoPage
              ? answer({
                  'items': [
                    {
                      'name': 'Burger',
                      'section': 'Burgers',
                      'priceMinor': 950,
                      'options': [],
                      'dietary': [],
                      'allergens': null,
                      'ingredients': null,
                      'priceConfidence': 'high',
                    },
                    {
                      'name': 'Falafel wrap',
                      'description': 'Chickpea falafel, tahini',
                      'section': 'Wraps',
                      'priceMinor': 750,
                      'options': [
                        {'name': 'Extra halloumi', 'priceMinor': 150},
                      ],
                      'dietary': ['vegetarian'],
                      'allergens': null,
                      'ingredients': null,
                      'priceConfidence': 'high',
                    },
                    {
                      'name': 'Lemonade',
                      'section': 'Drinks',
                      'priceMinor': null,
                      'options': [],
                      'dietary': [],
                      'allergens': null,
                      'ingredients': null,
                      'priceConfidence': 'low',
                    },
                  ],
                })
              : answer({
                  'sections': [
                    {
                      'name': 'Wraps',
                      'translations': {'fr': 'Wraps'},
                    },
                    {
                      'name': 'Burgers',
                      'translations': {'fr': 'Burgers'},
                    },
                    {
                      'name': 'Drinks',
                      'translations': {'fr': 'Boissons'},
                    },
                  ],
                  'items': [
                    {
                      'key': 0,
                      'section': 'Burgers',
                      'description': null,
                      'dietary': [],
                      'translations': {
                        'fr': {'name': 'Burger', 'description': null},
                      },
                    },
                    {
                      'key': 1,
                      'section': 'Wraps',
                      'description': 'Chickpea falafel, tahini',
                      'dietary': ['vegetarian'],
                      'translations': {
                        'fr': {
                          'name': 'Wrap falafel',
                          'description': 'Falafel de pois chiches, tahini',
                        },
                      },
                    },
                    {
                      'key': 2,
                      'section': 'Drinks',
                      'description': null,
                      'dietary': [],
                      'translations': {
                        'fr': {'name': 'Limonade', 'description': null},
                      },
                    },
                  ],
                });
          return http.Response.bytes(
            utf8.encode(body),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        });

        final started = await MenuAgent.snap(
          owner.build(),
          command({
            'mediaIds': [photo.id],
          }),
        );
        await AgentModule.run(s, started['taskId'] as int);
        final task = (await AgentTask.db.findById(
          s,
          started['taskId'] as int,
        ))!;
        expect(
          task.status,
          'done',
          reason: '${task.summary} ${task.stateJson}',
        );
        expect(task.chargedMicros, greaterThan(0));
        final actions = await AgentAction.db.find(
          s,
          where: (t) => t.taskId.equals(task.id!),
        );
        expect(actions, hasLength(1), reason: task.traceJson);
        final action = actions.single;
        expect(action.command, 'menu.publish');
        final evidence = jsonDecode(action.evidenceJson) as Map;
        expect(evidence['new'], 2);
        expect(evidence['changed'], 1);
        expect(evidence['checkPrices'], ['Lemonade']);
        expect(evidence['sections'], ['Wraps', 'Burgers', 'Drinks']);

        final done = await decide(owner, action);
        expect(done['state'], 'executed', reason: '$done');
        final products = {
          for (final p in await MenuProduct.db.find(
            s,
            where: (t) => t.restaurantId.equals(restaurant.id!),
          ))
            p.name: p,
        };
        expect(products['Burger']!.priceMinor, 950);
        expect(
          products['Fries']!.available,
          isTrue,
          reason: 'merge keeps dishes not in the photo',
        );
        expect(products['Falafel wrap']!.available, isTrue);
        expect(
          products['Lemonade']!.available,
          isFalse,
          reason: 'no readable price',
        );
        final wrap = (await MenuDefinition.db.findFirstRow(
          s,
          where: (t) => t.productId.equals(products['Falafel wrap']!.id!),
        ))!;
        final definition = jsonDecode(wrap.definitionJson) as Map;
        expect(definition['category'], 'Wraps');
        expect(definition['translations']['fr']['name'], 'Wrap falafel');
        expect(definition['dietary'], ['vegetarian']);
        expect(definition['allergens'], isNull);
        expect(
          (definition['modifiers'] as List).single['options'][0]['name'],
          'Extra halloumi',
        );
        final settings =
            jsonDecode(
                  (await RestaurantPolicy.db.findFirstRow(
                    s,
                    where: (t) => t.restaurantId.equals(restaurant.id!),
                  ))!.settingsJson,
                )
                as Map;
        expect(
          [for (final c in settings['menuCategories']) c['name']],
          ['Wraps', 'Burgers', 'Drinks'],
        );
      },
    );

    test(
      'the counter hears an order and keeps only real dishes and options',
      () async {
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_COUNTER_ENABLED': 'true',
        };
        ProviderClients.environment = () => {
          ...Platform.environment,
          'GEMINI_API_KEY': 'fixture-key',
        };
        final policy = (await RestaurantPolicy.db.findFirstRow(
          builder.build(),
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;
        final coffee =
            (await CatalogueModule.saveItem(
                  owner.build(),
                  command({
                    'name': 'Coffee',
                    'category': 'Drinks',
                    'priceMinor': 300,
                    'modifiers': [
                      {
                        'id': 'milk',
                        'name': 'Milk',
                        'min': 0,
                        'max': 1,
                        'options': [
                          {
                            'id': 'oat',
                            'name': 'Oat milk',
                            'priceMinor': 40,
                            'available': true,
                          },
                        ],
                      },
                    ],
                  }, version: policy.menuVersion),
                ))['id']
                as int;
        final seen = <Map>[];
        final replies = [
          {
            'lines': [
              {
                'productId': burger,
                'quantity': 2,
                'options': ['bogus'],
                'note': 'no onion',
              },
              {
                'productId': coffee,
                'quantity': 1,
                'options': ['milk:oat', 'oat'],
              },
              {'productId': 999999, 'quantity': 1},
              {'productId': burger, 'quantity': 40},
            ],
            'customerLabel': 'Sam',
            'unmatched': ['lemonade'],
          },
          {
            'lines': <Map>[],
            'unmatched': ['a song on the radio'],
          },
        ];
        ProviderClients.httpClient = () => MockClient((r) async {
          if (r.url.path.endsWith(':countTokens')) {
            return http.Response('{"totalTokens": 300}', 200);
          }
          seen.add(jsonDecode(r.body) as Map);
          final text = jsonEncode(replies[seen.length - 1]);
          return http.Response.bytes(
            utf8.encode(
              'data: ${jsonEncode({
                'candidates': [
                  {
                    'index': 0,
                    'content': {
                      'role': 'model',
                      'parts': [
                        {'text': text},
                      ],
                    },
                    'finishReason': 'STOP',
                  },
                ],
                'usageMetadata': {'promptTokenCount': 300, 'candidatesTokenCount': 60, 'totalTokenCount': 360},
              })}\r\n\r\n',
            ),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        });
        final heard = await VoiceModule.counter(
          owner.build(),
          restaurant.id!,
          Uint8List.fromList(List.filled(2000, 1)),
          'audio/wav',
        );
        expect(heard['lines'], [
          {
            'productId': burger,
            'quantity': 2,
            'options': [],
            'note': 'no onion',
          },
          {
            'productId': coffee,
            'quantity': 1,
            'options': ['milk:oat'],
            'note': '',
          },
        ]);
        expect(heard['customerLabel'], 'Sam');
        expect(heard['unmatched'], ['lemonade']);
        final request = seen.single;
        final parts = (request['contents'] as List).single['parts'] as List;
        expect(parts.last['inlineData']['mimeType'], 'audio/wav');
        expect(request['generationConfig']['responseSchema'], isNotNull);
        // The model is shown options exactly as an order line names them.
        final shown = jsonDecode(parts.first['text'] as String)['menu'] as List;
        expect(
          shown.firstWhere((m) => m['productId'] == coffee)['options'],
          [
            {'id': 'milk:oat', 'name': 'Oat milk'},
          ],
        );
        // Hearing no dish is an answer, not an error.
        final nothing = await VoiceModule.counter(
          owner.build(),
          restaurant.id!,
          Uint8List.fromList(List.filled(2000, 1)),
          'audio/wav',
        );
        expect(nothing['lines'], isEmpty);
        expect(nothing['unmatched'], ['a song on the radio']);
        await expectLater(
          VoiceModule.counter(
            waiter.build(),
            restaurant.id!,
            Uint8List.fromList(List.filled(2000, 1)),
            'audio/wav',
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
          ),
        );
      },
    );

    test(
      'feature and restaurant ceilings stop spending before the total',
      () async {
        AiBudget.environment = () => {
          ...Platform.environment,
          'RAYSTO_AI_BUDGET_STAGE': 'hackathon',
          'RAYSTO_AI_INPUT_USD_PER_MILLION': '0.75',
          'RAYSTO_AI_OUTPUT_USD_PER_MILLION': '3.75',
          'RAYSTO_AI_TENANT_DAILY_MICROS': '2000000',
        };
        final s = builder.build();
        await AiBudget.reserve(
          s,
          'fixture-image-${key()}',
          feature: 'images',
          restaurantId: restaurant.id,
          flatMicros: 1500000,
        );
        await expectLater(
          AiBudget.reserve(
            s,
            'fixture-image-${key()}',
            feature: 'images',
            restaurantId: restaurant.id,
            flatMicros: 1500000,
          ),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'ai_budget_exhausted',
            ),
          ),
        );
        final other = 'fixture-voice-${key()}';
        await AiBudget.reserve(s, other, feature: 'voice', flatMicros: 400000);
        expect(await AiBudget.settle(s, other, actualMicros: 1000), 1000);
        await expectLater(
          AiBudget.reserve(s, 'fixture-x-${key()}', feature: 'unknown'),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'ai_feature_unknown',
            ),
          ),
        );
      },
    );
  });
}
