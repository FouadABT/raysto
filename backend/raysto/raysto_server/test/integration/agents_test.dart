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
    AgentHandler? previousHandler;

    /// Runs one fixture task that proposes [drafts]; returns its actions.
    /// The fixture borrows the not-yet-built reviews agent's name.
    Future<List<AgentAction>> propose() async {
      final s = builder.build();
      final task = await AgentModule.asAgent(
        s,
        restaurant.id!,
        (w) => AgentModule.enqueue(
          w,
          agent: 'reviews',
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
        'RAYSTO_AGENT_REVIEWS_ENABLED': 'true',
      };
      previousHandler = AgentModule.handlers['reviews'];
      AgentModule.handlers['reviews'] = (s, task) async =>
          AgentOutcome('Fixture outcome', drafts: drafts);
    });
    tearDown(() {
      AgentModule.environment = () => Platform.environment;
      if (previousHandler == null) {
        AgentModule.handlers.remove('reviews');
      } else {
        AgentModule.handlers['reviews'] = previousHandler!;
      }
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
      'a manager asks the payments agent to check a checkout now',
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
            providerRequestId: 'fixture-request-3',
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
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_PAYMENTS_ENABLED': 'true',
        };
        PlatformCommand ask(String reason) => command({
          'reason': reason,
        }, id: checkout.id);

        await expectLater(
          PaymentAgent.check(waiter.build(), ask('left')),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
          ),
        );
        await expectLater(
          PaymentAgent.check(owner.build(), ask('paid')),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'invalid_input'),
          ),
        );
        final asked = await PaymentAgent.check(owner.build(), ask('left'));
        final task = (await AgentTask.db.findById(s, asked['taskId'] as int))!;
        expect(task.status, 'queued');
        expect(task.trigger, 'user');
        expect(task.requestedBy, 'agents-owner');
        expect(jsonDecode(task.inputJson), {
          'checkoutId': checkout.id,
          'reason': 'left',
        });
        final job = await PlatformJob.db.findFirstRow(
          s,
          where: (t) => t.dedupeKey.equals('agent:${task.id}'),
        );
        expect(job?.kind, 'agent.run');
        // Asking twice for the same reason does not queue a second check.
        final again = await PaymentAgent.check(owner.build(), ask('left'));
        expect(again['taskId'], task.id);

        ProviderClients.environment = () => {
          ...Platform.environment,
          'GEMINI_API_KEY': 'fixture-key',
        };
        final prompts = <String>[];
        ProviderClients.httpClient = () => MockClient((r) async {
          if (r.url.path.endsWith(':countTokens')) {
            return http.Response('{"totalTokens": 400}', 200);
          }
          prompts.add(r.body);
          return http.Response.bytes(
            utf8.encode(
              'data: ${jsonEncode({
                'candidates': [
                  {
                    'index': 0,
                    'content': {
                      'role': 'model',
                      'parts': [
                        {'text': 'Checked.'},
                      ],
                    },
                    'finishReason': 'STOP',
                  },
                ],
                'usageMetadata': {'promptTokenCount': 400, 'candidatesTokenCount': 5, 'totalTokenCount': 405},
              })}\r\n\r\n',
            ),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        });
        await AgentModule.run(s, task.id!);
        expect(prompts.first, contains('left it without finishing the payment'));
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
      'the copilot asks for a longer promise in a rush and goes back after',
      () async {
        final s = builder.build();
        final now = DateTime.now().toUtc();
        // A real configuration, so approving a settings change validates.
        final policy = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;
        policy.settingsJson = jsonEncode({
          ...jsonDecode(policy.settingsJson) as Map,
          'taxConfigured': true,
          'address': 'Fixture street',
          'contactEmail': 'owner@example.test',
          'country': 'BE',
          'hours': [
            for (var day = 1; day <= 7; day++)
              {'day': day, 'start': 0, 'end': 1440},
          ],
        });
        await RestaurantPolicy.db.updateRow(s, policy);
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_COPILOT_ENABLED': 'true',
        };
        ProviderClients.environment = () => {
          ...Platform.environment,
          'GEMINI_API_KEY': 'fixture-key',
        };
        // Placed 40 minutes ago for pickup tomorrow: not late, not queued.
        final ahead = await PurchaseOrder.db.insertRow(
          s,
          PurchaseOrder(
            restaurantId: restaurant.id!,
            customerId: 'agents-customer',
            requestKey: key(),
            requestHash: 'fixture',
            fulfillment: 'pickup',
            lines: [],
            currency: 'EUR',
            subtotalMinor: 900,
            deliveryFeeMinor: 0,
            totalMinor: 900,
            status: 'submitted',
            paymentStatus: 'paid',
            version: 1,
            createdAt: now.subtract(const Duration(minutes: 40)),
            updatedAt: now.subtract(const Duration(minutes: 40)),
          ),
        );
        await OrderContext.db.insertRow(
          s,
          OrderContext(
            restaurantId: restaurant.id!,
            orderId: ahead.id!,
            detailsJson: '{}',
            paymentTiming: 'before',
            cancellationRequested: false,
            stockReleased: false,
            slotKey:
                'pickup:${now.add(const Duration(days: 1)).toIso8601String()}',
            createdAt: now.subtract(const Duration(minutes: 40)),
          ),
        );
        await CopilotAgent.sweep(s, force: true);
        expect(
          await AgentTask.db.count(s, where: (t) => t.agent.equals('copilot')),
          0,
          reason: 'An order scheduled for tomorrow is not late.',
        );
        // One order accepted 35 minutes ago: past the 20-minute promise.
        final late = await PurchaseOrder.db.insertRow(
          s,
          PurchaseOrder(
            restaurantId: restaurant.id!,
            customerId: 'agents-customer',
            requestKey: key(),
            requestHash: 'fixture',
            fulfillment: 'pickup',
            lines: [],
            currency: 'EUR',
            subtotalMinor: 900,
            deliveryFeeMinor: 0,
            totalMinor: 900,
            status: 'accepted',
            paymentStatus: 'paid',
            version: 1,
            createdAt: now.subtract(const Duration(minutes: 35)),
            updatedAt: now.subtract(const Duration(minutes: 30)),
          ),
        );
        String sse(Json part) =>
            'data: ${jsonEncode({
              'candidates': [
                {
                  'index': 0,
                  'content': {
                    'role': 'model',
                    'parts': [part],
                  },
                  'finishReason': 'STOP',
                },
              ],
              'usageMetadata': {'promptTokenCount': 300, 'candidatesTokenCount': 40, 'totalTokenCount': 340},
            })}\r\n\r\n';
        Json call(String name, [Json args = const {}]) => {
          'functionCall': {'name': name, 'args': args},
        };
        final script = [
          call('read_kitchen'),
          call('propose_preparation_time', {
            'decision': 'change',
            'minutes': 45,
            'explanation':
                'One order has waited 35 minutes against a 20-minute promise. Promising 45 minutes keeps new pickups honest.',
          }),
          call('read_kitchen'),
          call('propose_preparation_time', {
            'decision': 'change',
            'minutes': 20,
            'explanation':
                'The queue is empty and nothing is late. Customers can be promised 20 minutes again.',
          }),
        ];
        final prompts = <String>[];
        ProviderClients.httpClient = () => MockClient((r) async {
          if (r.url.path.endsWith(':countTokens')) {
            return http.Response('{"totalTokens": 300}', 200);
          }
          final body = jsonDecode(r.body) as Map;
          prompts.add(jsonEncode(body['systemInstruction']));
          return http.Response.bytes(
            utf8.encode(sse(script.removeAt(0))),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        });

        await CopilotAgent.sweep(s, force: true);
        final rush = (await AgentTask.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(restaurant.id!) & t.agent.equals('copilot'),
        )).single;
        expect(jsonDecode(rush.inputJson), {
          'signal': 'rush',
          'usualMinutes': 20,
        });
        await AgentModule.run(s, rush.id!);
        final raise = (await AgentAction.db.find(
          s,
          where: (t) => t.taskId.equals(rush.id!),
        )).single;
        expect(raise.command, 'settings.patch');
        expect(jsonDecode(raise.payloadJson), {
          'settings': {'preparationMinutes': 45},
        });
        final evidence = jsonDecode(raise.evidenceJson) as Map;
        expect(evidence['queue'], 1);
        expect(evidence['oldestOpenMinutes'], greaterThanOrEqualTo(35));
        expect(evidence['mostLateMinutes'], greaterThanOrEqualTo(15));
        expect(evidence['usualMinutes'], 20);
        // While the proposal waits, the next sweep does not stack another.
        await CopilotAgent.sweep(s, force: true);
        expect(
          await AgentTask.db.count(
            s,
            where: (t) => t.agent.equals('copilot'),
          ),
          1,
        );
        expect((await decide(owner, raise))['state'], 'executed');
        Future<int> promised() async => jsonDecode(
          (await RestaurantPolicy.db.findById(s, policy.id!))!.settingsJson,
        )['preparationMinutes'];
        expect(await promised(), 45);

        // The order is collected; the kitchen is calm again.
        late.status = 'collected';
        late.updatedAt = DateTime.now().toUtc();
        await PurchaseOrder.db.updateRow(s, late);
        await CopilotAgent.sweep(s, force: true);
        final calm = (await AgentTask.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(restaurant.id!) &
              t.agent.equals('copilot') &
              t.id.notEquals(rush.id!),
        )).single;
        expect(jsonDecode(calm.inputJson), {
          'signal': 'calm',
          'usualMinutes': 20,
        });
        await AgentModule.run(s, calm.id!);
        final back = (await AgentAction.db.find(
          s,
          where: (t) => t.taskId.equals(calm.id!),
        )).single;
        expect(back.title, contains('Back to 20 minutes'));
        expect((await decide(owner, back))['state'], 'executed');
        expect(await promised(), 20);
        expect(prompts.last, contains('usual 20 minutes'));
      },
    );

    test(
      'the image studio draws a dish, and approving it labels and publishes the photo',
      () async {
        final s = builder.build();
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_IMAGES_ENABLED': 'true',
        };
        ProviderClients.environment = () => {
          ...Platform.environment,
          'OPENAI_API_KEY': 'fixture-openai',
          'RAYSTO_AI_IMAGE_USD_OPENAI': '0.05',
        }..remove('GEMINI_API_KEY');
        final stored = <String, Uint8List>{};
        final store = ImageAgent.store, scan = ImageAgent.scan;
        addTearDown(() {
          ImageAgent.store = store;
          ImageAgent.scan = scan;
        });
        ImageAgent.store = (name, bytes, mime) async => stored[name] = bytes;
        // Stands in for the virus scan and re-encode of an upload.
        ImageAgent.scan = (s, id) async {
          final a = (await MediaAsset.db.findById(s, id))!;
          a
            ..status = 'approved'
            ..objectName = 'v2/sanitized/$id/${a.sha256}.jpg'
            ..mime = 'image/jpeg'
            ..metadataJson = jsonEncode({
              ...jsonDecode(a.metadataJson) as Map,
              'width': 1536,
              'height': 1024,
            });
          await MediaAsset.db.updateRow(s, a);
        };
        final requests = <http.Request>[];
        ProviderClients.httpClient = () => MockClient((r) async {
          requests.add(r);
          return http.Response(
            jsonEncode({
              'data': [
                {'b64_json': base64Encode(List.filled(4000, 7))},
              ],
            }),
            200,
          );
        });
        final policy = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;

        await expectLater(
          ImageAgent.photo(
            owner.build(),
            command({
              'productIds': [burger],
              'provider': 'gemini',
            }),
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'unavailable'),
          ),
        );
        await expectLater(
          ImageAgent.photo(
            waiter.build(),
            command({
              'productIds': [burger],
              'provider': 'openai',
            }),
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
          ),
        );
        final started = await ImageAgent.photo(
          owner.build(),
          command({
            'productIds': [burger],
            'provider': 'openai',
          }),
        );
        final taskId = (started['taskIds'] as List).single as int;
        await AgentModule.run(s, taskId);
        final task = (await AgentTask.db.findById(s, taskId))!;
        expect(
          task.status,
          'done',
          reason: '${task.summary} ${task.stateJson}',
        );
        expect(task.chargedMicros, 50000);
        final sent = requests.single;
        expect(sent.url.host, 'api.openai.com');
        expect(sent.headers['authorization'], 'Bearer fixture-openai');
        final body = jsonDecode(sent.body) as Map;
        expect(body['model'], 'gpt-image-1');
        expect(body['prompt'], contains('Burger'));
        expect(body['prompt'], contains('no people'));
        expect(stored.keys.single, startsWith('v2/quarantine/gen/'));

        final action = (await AgentAction.db.find(
          s,
          where: (t) => t.taskId.equals(taskId),
        )).single;
        expect(action.command, 'menu.image');
        expect(action.risk, 'catalogue');
        final preview = jsonDecode(action.previewJson) as Map;
        expect(preview['dish'], 'Burger');
        expect(preview['provider'], 'openai');
        final mediaId = preview['mediaId'] as int;
        expect(
          (await MediaAsset.db.findById(s, mediaId))!.public,
          isFalse,
          reason: 'Nobody sees the photo before the owner approves it.',
        );

        expect((await decide(owner, action))['state'], 'executed');
        final media = (await MediaAsset.db.findById(s, mediaId))!;
        expect(media.public, isTrue);
        expect(jsonDecode(media.metadataJson)['origin'], 'ai');
        expect(
          (await RestaurantPolicy.db.findById(s, policy.id!))!.menuVersion,
          policy.menuVersion,
          reason: 'A photo changes no price, so open quotes stay valid.',
        );
        final item = (await PlatformQueries.sellable(
          s,
          restaurant.id!,
        )).singleWhere((i) => i['productId'] == burger);
        expect(item['mediaId'], mediaId);
        expect(item['aiImage'], isTrue);

        // An owner's later edit keeps the photo labelled as AI.
        await CatalogueModule.saveItem(
          owner.build(),
          command({
            'productId': burger,
            'name': 'Burger',
            'category': 'Mains',
            'priceMinor': 950,
            'mediaId': mediaId,
          }, version: policy.menuVersion),
        );
        final edited = (await PlatformQueries.sellable(
          s,
          restaurant.id!,
        )).singleWhere((i) => i['productId'] == burger);
        expect(edited['priceMinor'], 950);
        expect(edited['aiImage'], isTrue);
      },
    );

    test(
      'a photo that times out is asked once more, and both attempts are charged',
      () async {
        AgentModule.environment = () => {
          ...Platform.environment,
          'RAYSTO_AGENT_IMAGES_ENABLED': 'true',
        };
        ProviderClients.environment = () => {
          ...Platform.environment,
          'OPENAI_API_KEY': 'fixture-openai',
          'RAYSTO_AI_IMAGE_USD_OPENAI': '0.05',
        }..remove('GEMINI_API_KEY');
        final store = ImageAgent.store, scan = ImageAgent.scan;
        final limits = ImageAgent.attemptLimits;
        addTearDown(() {
          ImageAgent.store = store;
          ImageAgent.scan = scan;
          ImageAgent.attemptLimits = limits;
        });
        ImageAgent.attemptLimits = const [
          Duration(milliseconds: 50),
          Duration(seconds: 5),
        ];
        ImageAgent.store = (name, bytes, mime) async {};
        ImageAgent.scan = (s, id) async {
          final a = (await MediaAsset.db.findById(s, id))!;
          await MediaAsset.db.updateRow(s, a..status = 'approved');
        };
        var calls = 0;
        ProviderClients.httpClient = () => MockClient((r) async {
          calls++;
          // The first request is slower than its limit; the second answers.
          if (calls == 1) {
            await Future.delayed(const Duration(milliseconds: 400));
          }
          return http.Response(
            jsonEncode({
              'data': [
                {'b64_json': base64Encode(List.filled(4000, 7))},
              ],
            }),
            200,
          );
        });
        final started = await ImageAgent.photo(
          owner.build(),
          command({
            'productIds': [burger],
            'provider': 'openai',
          }),
        );
        final taskId = (started['taskIds'] as List).single as int;
        await AgentModule.run(builder.build(), taskId);
        final task = (await AgentTask.db.findById(builder.build(), taskId))!;
        expect(task.status, 'done', reason: '${task.summary}');
        expect(calls, 2);
        expect(task.summary, contains('second try'));
        expect(task.chargedMicros, 100000);

        // Two slow answers fail the task instead of asking a third time.
        calls = 0;
        ImageAgent.attemptLimits = const [
          Duration(milliseconds: 50),
          Duration(milliseconds: 50),
        ];
        ProviderClients.httpClient = () => MockClient((r) async {
          calls++;
          await Future.delayed(const Duration(milliseconds: 400));
          return http.Response('{}', 200);
        });
        final again = await ImageAgent.photo(
          owner.build(),
          command({
            'productIds': [burger],
            'provider': 'openai',
          }),
        );
        final failedId = (again['taskIds'] as List).single as int;
        await AgentModule.run(builder.build(), failedId);
        final failed = (await AgentTask.db.findById(
          builder.build(),
          failedId,
        ))!;
        expect(failed.status, 'failed');
        expect(failed.summary, contains('took too long'));
        expect(calls, 2);
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
