part of 'platform.dart';

/// The image studio: a photo for every dish. The owner picks Gemini or
/// OpenAI; the photo is drawn from the dish's own name, description and
/// ingredients, scanned and re-encoded like any upload, and waits for the
/// owner's approval. Customers see it labelled as an AI image.
class ImageAgent {
  static const agent = 'images';
  static const maxBatch = 12;

  /// Replaced in tests: private storage and the file scan.
  static Future<void> Function(String name, Uint8List bytes, String mime)
  store = ProviderClients.putFile;
  static Future<void> Function(Session s, int id) scan = AiModule.scan;

  /// Starts a photo for each of up to 12 dishes.
  static Future<Json> photo(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'menu.photo',
    (w, d) async {
      _keys(d, {'productIds', 'provider'});
      final provider = _str(d, 'provider', choices: ImageProviders.providers);
      if (!ImageProviders.configured(provider)) {
        _fail(
          'unavailable',
          '${ImageProviders.label(provider)} images are not set up yet.',
        );
      }
      final ids = _list(
        d,
        'productIds',
        max: maxBatch,
      ).map((v) => _int({'v': v}, 'v', min: 1)).toSet().toList();
      if (ids.isEmpty) _fail('invalid_input', 'Choose a dish.');
      await _rate(s, 'images:${w.user}', 20, w.tx, minutes: 60);
      final tasks = <int>[];
      for (final id in ids) {
        final p = await MenuProduct.db.findById(s, id, transaction: w.tx);
        if (p == null || p.restaurantId != w.tenant) {
          _fail('not_found', 'Item not found.');
        }
        final task = await AgentModule.enqueue(
          w,
          agent: agent,
          trigger: 'user',
          requestedBy: w.user,
          dedupeKey: 'images:$id:$provider:${c.requestKey}',
          title: 'Photo of ${p.name} (${ImageProviders.label(provider)})',
          input: {'productId': id, 'provider': provider},
          feature: 'images',
        );
        if (task == null) {
          _fail('unavailable', 'The image studio is switched off.');
        }
        tasks.add(task.id!);
      }
      return {'taskIds': tasks};
    },
    roles: _managers,
  );

  /// The photo brief: only the dish's own words, and what must not appear.
  static String promptFor(Json dish) {
    String clip(Object? v, int n) {
      final s = '${v ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim();
      return s.length > n ? s.substring(0, n) : s;
    }

    final description = clip(dish['description'], 300);
    final ingredients = [
      for (final i in (dish['ingredients'] as List? ?? const [])) clip(i, 40),
    ].where((i) => i.isNotEmpty).take(12).join(', ');
    final section = clip(dish['category'], 60);
    return 'A realistic, appetising photograph of one serving of '
        '${clip(dish['name'], 80)}${description.isEmpty ? '' : ': $description'}. '
        '${ingredients.isEmpty ? '' : 'Main ingredients: $ingredients. '}'
        '${section.isEmpty ? '' : 'Menu section: $section. '}'
        'Served as it would be in a small independent restaurant, on a '
        'plate, in a bowl, cup or glass as suits it, on a wooden or stone '
        'table, in soft natural light, seen from a 45-degree angle with a '
        'shallow depth of field. The background is a plain, softly blurred '
        'empty wall or table with nobody in it. Only the food and its '
        'tableware: no people or diners anywhere in the frame, no hands, no '
        'text, no menus, no logos, no watermarks.';
  }

  /// How long each attempt may take; a timed-out attempt is followed by the
  /// next one. Earlier photos took 44–48 s.
  static List<Duration> attemptLimits = const [
    Duration(seconds: 90),
    Duration(seconds: 120),
  ];

  static Future<AgentOutcome> run(Session s, AgentTask task) async {
    final input = _json(task.inputJson);
    final provider = _str(
      input,
      'provider',
      choices: ImageProviders.providers,
    );
    final productId = _int(input, 'productId', min: 1);
    final dish = await AgentModule.asAgent<Json>(s, task.restaurantId, (
      w,
    ) async {
      final p = await MenuProduct.db.findById(s, productId, transaction: w.tx);
      if (p == null || p.restaurantId != w.tenant) {
        _fail('not_found', 'Item not found.');
      }
      final def = await MenuDefinition.db.findFirstRow(
        s,
        where: (t) => t.productId.equals(productId),
        transaction: w.tx,
      );
      final d = def == null ? <String, dynamic>{} : _json(def.definitionJson);
      return {
        'name': p.name,
        'description': d['description'] ?? p.description,
        'category': def?.category ?? d['category'],
        'ingredients': d['ingredients'],
      };
    });
    final prompt = promptFor(dish);
    final model = ImageProviders.model(provider);
    final cost = ImageProviders.price(provider);
    final watch = Stopwatch()..start();
    // A slow answer is usually a busy moment at the provider, so a timed-out
    // first attempt is asked once more. Each attempt has its own budget
    // reservation, and a timed-out one stays charged.
    ({Uint8List bytes, String mime})? image;
    var attempts = 0;
    var charged = 0;
    while (image == null) {
      attempts++;
      final key = attempts == 1
          ? 'agent:${task.id}'
          : 'agent:${task.id}:$attempts';
      await AiBudget.reserve(
        s,
        key,
        feature: 'images',
        restaurantId: task.restaurantId,
        flatMicros: cost,
      );
      try {
        image = await ImageProviders.generate(
          provider,
          prompt,
          timeout: attemptLimits[attempts - 1],
        );
      } catch (e) {
        // Whether a failed call was charged is unknown: keep the reservation.
        await AiBudget.settle(s, key);
        charged += cost;
        if (e is DomainError &&
            e.code == 'ai_timeout' &&
            attempts < attemptLimits.length) {
          continue;
        }
        rethrow;
      }
      await AiBudget.settle(s, key, actualMicros: cost);
      charged += cost;
    }
    final photo = image;
    final object = 'v2/quarantine/gen/${_uuid()}';
    await store(object, photo.bytes, photo.mime);
    final asset = await AgentModule.asAgent<MediaAsset>(
      s,
      task.restaurantId,
      (w) => MediaAsset.db.insertRow(
        s,
        MediaAsset(
          restaurantId: w.tenant,
          userId: w.user,
          purpose: 'menuImage',
          objectName: object,
          mime: photo.mime,
          byteLength: photo.bytes.length,
          sha256: sha256.convert(photo.bytes).toString(),
          status: 'quarantine',
          public: false,
          metadataJson: jsonEncode({
            'origin': 'ai',
            'provider': provider,
            'model': model,
            'promptHash': _hash(prompt),
            'productId': productId,
          }),
          createdAt: _now(),
        ),
        transaction: w.tx,
      ),
    );
    await scan(s, asset.id!);
    if ((await MediaAsset.db.findById(s, asset.id!))?.status != 'approved') {
      _fail('file_rejected', 'The photo did not pass the file check.');
    }
    final label = ImageProviders.label(provider);
    final seconds = (watch.elapsedMilliseconds / 1000).toStringAsFixed(1);
    return AgentOutcome(
      '$label drew a photo of ${dish['name']} in $seconds s'
      '${attempts > 1 ? ', on the second try' : ''}.',
      drafts: [
        AgentDraft(
          'menu.image',
          'Use this photo for ${dish['name']}',
          'Drawn by $label ($model) from the dish\'s own name, description '
              'and ingredients. Customers see it marked as an AI image.',
          {'productId': productId, 'mediaId': asset.id},
          evidence: {'provider': provider, 'model': model},
        ),
      ],
      trace: [
        {
          'tool': 'draw_photo',
          'source': provider,
          'model': model,
          'ms': watch.elapsedMilliseconds,
          'attempts': attempts,
        },
        {'tool': 'file_check', 'mediaId': asset.id},
      ],
      chargedMicros: charged,
    );
  }

  /// Approving a photo publishes it on the dish.
  static final imageCommand = AgentCommand(
    roles: _managers,
    risk: 'catalogue',
    expiry: const Duration(days: 7),
    prepare: (w, p) async {
      _keys(p, {'productId', 'mediaId'});
      final product = await MenuProduct.db.findById(
        w.s,
        _int(p, 'productId', min: 1),
        transaction: w.tx,
      );
      if (product == null || product.restaurantId != w.tenant) {
        _fail('not_found', 'Item not found.');
      }
      final media = await MediaAsset.db.findById(
        w.s,
        _int(p, 'mediaId', min: 1),
        transaction: w.tx,
      );
      if (media == null ||
          media.restaurantId != w.tenant ||
          media.purpose != 'menuImage' ||
          media.status != 'approved') {
        _fail('not_found', 'Photo not found.');
      }
      final meta = _json(media.metadataJson);
      return (
        preview: <String, dynamic>{
          'dish': product.name,
          'mediaId': media.id,
          'provider': meta['provider'],
          'model': meta['model'],
        },
        context: _hash('${product.id}:${media.id}:${media.status}'),
      );
    },
    invoke: (s, rid, p, key) => CatalogueModule.image(
      s,
      PlatformCommand(
        requestKey: key,
        restaurantId: rid,
        resourceId: p['productId'] as int,
        dataJson: jsonEncode({'mediaId': p['mediaId']}),
      ),
    ),
  );
}
