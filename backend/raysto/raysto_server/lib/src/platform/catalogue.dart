part of 'platform.dart';

class CatalogueModule {
  static const defaults = <String, dynamic>{
    'address': '',
    'contactEmail': '',
    'timezone': 'Europe/Brussels',
    'country': '',
    'languages': ['en'],
    'modes': ['dineIn', 'pickup'],
    'hours': [],
    'holidays': [],
    'paused': false,
    'guestOrdering': true,
    'customerChatEnabled': true,
    'selfSeating': false,
    'paymentTiming': 'before',
    'autoAcceptPaid': false,
    'deliveryFeeMinor': 0,
    'deliveryMinimumMinor': 0,
    'deliveryZones': [],
    'preparationMinutes': 20,
    'slotMinutes': 15,
    'slotCapacity': 20,
    'reservationMinutes': 90,
    'taxConfigured': false,
    'taxBps': 0,
    'pricesIncludeTax': true,
    'coupons': [],
  };
  static bool _tzInitialized = false;
  static tz.Location zone(String name) {
    if (!_tzInitialized) {
      tzdata.initializeTimeZones();
      _tzInitialized = true;
    }
    try {
      return tz.getLocation(name);
    } catch (_) {
      _fail('invalid_input', 'Unknown restaurant timezone.');
    }
  }

  static Json address(Json d) {
    _keys(d, {
      'id',
      'label',
      'line',
      'city',
      'postalCode',
      'country',
      'latitude',
      'longitude',
      'instructions',
      'default',
    });
    final result = <String, dynamic>{
      'line': _str(d, 'line', max: 300),
      'city': _str(d, 'city', max: 100),
      'country': _str(d, 'country', max: 2),
    };
    for (final k in ['id', 'label', 'postalCode', 'instructions']) {
      if (d[k] != null) {
        result[k] = _str(d, k, max: k == 'instructions' ? 500 : 100);
      }
    }
    if (d['latitude'] != null || d['longitude'] != null) {
      result['latitude'] = coordinate(d['latitude'], 90);
      result['longitude'] = coordinate(d['longitude'], 180);
    }
    result['default'] = _bool(d, 'default');
    return result;
  }

  static double coordinate(dynamic value, double bound) {
    if (value is! num || !value.isFinite || value.abs() > bound) {
      _fail('invalid_input', 'Invalid coordinate.');
    }
    return value.toDouble();
  }

  static Json validateSettings(Json d) {
    _keys(d, defaults.keys.toSet());
    final merged = <String, dynamic>{...defaults, ...d};
    _str(merged, 'address', max: 500);
    _str(merged, 'contactEmail', max: 254);
    _str(merged, 'country', max: 2);
    zone(_str(merged, 'timezone', max: 80));
    for (final b in [
      'paused',
      'guestOrdering',
      'customerChatEnabled',
      'selfSeating',
      'taxConfigured',
      'pricesIncludeTax',
      'autoAcceptPaid',
    ]) {
      _bool(merged, b);
    }
    _str(merged, 'paymentTiming', choices: {'before', 'end'});
    final modes = _list(merged, 'modes', max: 3);
    if (modes.isEmpty ||
        modes.any((v) => !{'dineIn', 'pickup', 'delivery'}.contains(v)) ||
        modes.toSet().length != modes.length) {
      _fail('invalid_input', 'Choose valid service modes.');
    }
    if (_list(
      merged,
      'languages',
      max: 3,
    ).any((v) => !{'en', 'fr', 'ar'}.contains(v))) {
      _fail('invalid_input', 'Unsupported language.');
    }
    for (final n in ['deliveryFeeMinor', 'deliveryMinimumMinor']) {
      _int(merged, n);
    }
    _int(merged, 'taxBps', max: 10000);
    _int(merged, 'preparationMinutes', min: 1, max: 240);
    _int(merged, 'slotMinutes', min: 5, max: 120);
    _int(merged, 'slotCapacity', min: 1, max: 500);
    _int(merged, 'reservationMinutes', min: 15, max: 360);
    for (final raw in _list(merged, 'hours', max: 28)) {
      final h = _object(raw);
      _keys(h, {'day', 'start', 'end'});
      _int(h, 'day', min: 1, max: 7);
      if (_int(h, 'start', max: 1439) >= _int(h, 'end', min: 1, max: 1440)) {
        _fail(
          'invalid_input',
          'Opening intervals must have positive duration.',
        );
      }
    }
    for (final h in _list(merged, 'holidays', max: 366)) {
      if (h is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(h)) {
        _fail('invalid_input', 'Invalid holiday date.');
      }
    }
    for (final raw in _list(merged, 'deliveryZones', max: 20)) {
      final z = _object(raw);
      _keys(z, {'latitude', 'longitude', 'radiusKm'});
      coordinate(z['latitude'], 90);
      coordinate(z['longitude'], 180);
      if (z['radiusKm'] is! num ||
          !(z['radiusKm'] as num).isFinite ||
          z['radiusKm'] <= 0 ||
          z['radiusKm'] > 100) {
        _fail('invalid_input', 'Delivery radius must be 0–100 km.');
      }
    }
    final codes = <String>{};
    for (final raw in _list(merged, 'coupons', max: 100)) {
      final p = _object(raw);
      _keys(p, {
        'code',
        'type',
        'value',
        'minimumMinor',
        'startsAt',
        'expiresAt',
        'maxUses',
        'maxPerUser',
      });
      final code = _str(p, 'code', max: 30);
      if (!codes.add(code) || !RegExp(r'^[A-Z0-9_-]+$').hasMatch(code)) {
        _fail('invalid_input', 'Coupon codes must be unique uppercase values.');
      }
      _str(p, 'type', choices: {'fixed', 'percent'});
      _int(p, 'value', max: p['type'] == 'percent' ? 10000 : 1000000);
      _int(p, 'minimumMinor', fallback: 0);
      _int(p, 'maxUses', min: 1, max: 100000);
      _int(p, 'maxPerUser', min: 1, max: 100);
      if (!_date(p, 'expiresAt').isAfter(_date(p, 'startsAt'))) {
        _fail('invalid_input', 'Invalid coupon dates.');
      }
    }
    return merged;
  }

  static bool openAt(Json settings, DateTime at) {
    if (settings['paused'] == true) return false;
    final local = tz.TZDateTime.from(at, zone(settings['timezone'] as String));
    final date =
        '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    if ((settings['holidays'] as List).contains(date)) return false;
    final minutes = local.hour * 60 + local.minute;
    return (settings['hours'] as List).any(
      (h) =>
          h['day'] == local.weekday &&
          h['start'] <= minutes &&
          minutes < h['end'],
    );
  }

  static bool delivers(Json settings, Json address) {
    if (address['latitude'] == null || address['longitude'] == null) {
      return false;
    }
    final lat = coordinate(address['latitude'], 90) * pi / 180,
        lon = coordinate(address['longitude'], 180) * pi / 180;
    return (settings['deliveryZones'] as List).any((z) {
      final la = (z['latitude'] as num) * pi / 180,
          lo = (z['longitude'] as num) * pi / 180;
      final a =
          pow(sin((lat - la) / 2), 2) +
          cos(lat) * cos(la) * pow(sin((lon - lo) / 2), 2);
      return 6371 * 2 * atan2(sqrt(a), sqrt(max(0, 1 - a))) <=
          (z['radiusKm'] as num);
    });
  }

  static Future<Json> configure(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'restaurant.configure',
    (w, d) async {
      _keys(d, {'name', 'currency', 'settings'});
      final p =
          w.policy ??
          _fail(
            'upgrade_required',
            'Initialize this restaurant before configuring v2.',
          );
      _version(p.version, c.expectedVersion);
      // A partial save changes only the keys it sends; everything else keeps
      // its saved value instead of falling back to a default.
      final prior = w.settings;
      final settings = validateSettings({
        ...prior,
        ..._object(d['settings']),
      });
      if (settings['paymentTiming'] != prior['paymentTiming'] ||
          settings['taxBps'] != prior['taxBps'] ||
          settings['pricesIncludeTax'] != prior['pricesIncludeTax']) {
        await w.role({'owner'});
        await _stepUp(w, mfa: true);
      }
      final currency = _str(d, 'currency', choices: {'EUR', 'USD', 'GBP'});
      if (currency != w.restaurant!.currency) {
        final existing = await PurchaseOrder.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          transaction: w.tx,
        );
        if (existing != null) {
          _fail(
            'currency_locked',
            'Currency cannot change after an order has been recorded.',
          );
        }
        await w.role({'owner'});
        await _stepUp(w, mfa: true);
      }
      w.restaurant!.name = _str(d, 'name', max: 120);
      w.restaurant!.currency = currency;
      w.restaurant!.deliveryFeeMinor = settings['deliveryFeeMinor'] as int;
      await Restaurant.db.updateRow(s, w.restaurant!, transaction: w.tx);
      p.settingsJson = jsonEncode(settings);
      p.version++;
      p.updatedAt = _now();
      await RestaurantPolicy.db.updateRow(s, p, transaction: w.tx);
      await w.audit('restaurant.configured', 'restaurant', w.tenant);
      return {'version': p.version};
    },
    roles: _managers,
    registered: true,
  );

  static Future<Json> publish(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'restaurant.publish',
    (w, d) async {
      _keys(d, {'published'});
      final published = _bool(d, 'published');
      if (published) {
        final settings = validateSettings(w.settings);
        if (settings['taxConfigured'] != true ||
            (settings['hours'] as List).isEmpty) {
          _fail(
            'setup_incomplete',
            'Confirm tax configuration and opening hours.',
          );
        }
        if (w.policy!.suspended) _fail('forbidden', 'Restaurant is suspended.');
        final item = await MenuDefinition.db.findFirstRow(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) & t.archived.equals(false),
          transaction: w.tx,
        );
        if (item == null) {
          _fail('setup_incomplete', 'Publish at least one menu item.');
        }
      }
      w.restaurant!.published = published;
      await Restaurant.db.updateRow(s, w.restaurant!, transaction: w.tx);
      await w.audit('restaurant.publication', 'restaurant', w.tenant, {
        'published': published,
      });
      return {'published': published};
    },
    roles: _managers,
  );

  static Json validateItem(Json d) {
    _keys(d, {
      'productId',
      'name',
      'description',
      'category',
      'priceMinor',
      'available',
      'archived',
      'stockRemaining',
      'mediaId',
      'translations',
      'ingredients',
      'allergens',
      'dietary',
      'modifiers',
    });
    _str(d, 'name', max: 150);
    _str(d, 'category', max: 80);
    _int(d, 'priceMinor');
    if (d['description'] != null &&
        (d['description'] is! String ||
            (d['description'] as String).length > 4000)) {
      _fail('invalid_input', 'Invalid description.');
    }
    _bool(d, 'available', fallback: true);
    _bool(d, 'archived');
    if (d['stockRemaining'] != null) _int(d, 'stockRemaining', max: 100000);
    for (final k in ['ingredients', 'allergens', 'dietary']) {
      if (d[k] != null) {
        for (final v in _list(d, k, max: 50)) {
          _str({'v': v}, 'v', max: 100);
        }
      }
    }
    final translations = _object(d['translations'] ?? {});
    _keys(translations, {'en', 'fr', 'ar'});
    for (final value in translations.values) {
      final t = _object(value);
      _keys(t, {'name', 'description'});
      _str(t, 'name', max: 150);
      if (t['description'] != null) _str(t, 'description', max: 4000);
    }
    final groups = <String>{};
    for (final raw in _list(d, 'modifiers', max: 20)) {
      final g = _object(raw);
      _keys(g, {'id', 'name', 'min', 'max', 'options'});
      if (!groups.add(_str(g, 'id', max: 50))) {
        _fail('invalid_input', 'Modifier group IDs must be unique.');
      }
      _str(g, 'name', max: 100);
      final options = _list(g, 'options', max: 30);
      if (_int(g, 'min', max: 30) > _int(g, 'max', max: 30) ||
          g['max'] > options.length) {
        _fail('invalid_input', 'Invalid modifier selection limits.');
      }
      final ids = <String>{};
      for (final rawOption in options) {
        final o = _object(rawOption);
        _keys(o, {'id', 'name', 'priceMinor', 'available'});
        if (!ids.add(_str(o, 'id', max: 50))) {
          _fail('invalid_input', 'Modifier option IDs must be unique.');
        }
        _str(o, 'name', max: 100);
        _int(o, 'priceMinor');
        _bool(o, 'available', fallback: true);
      }
    }
    return {
      ...d,
      'description': d['description'] ?? '',
      'available': d['available'] ?? true,
      'archived': d['archived'] ?? false,
      'translations': translations,
      'modifiers': d['modifiers'] ?? [],
      'ingredients': d['ingredients'],
      'allergens': d['allergens'],
      'dietary': d['dietary'],
    };
  }

  static Future<int> _writeItem(Work w, Json d) async {
    final definition = validateItem(d);
    final id = d['productId'];
    MenuProduct product;
    final oldDefinition = id == null
        ? null
        : await MenuDefinition.db.findFirstRow(
            w.s,
            where: (t) => t.productId.equals(_int(d, 'productId', min: 1)),
            transaction: w.tx,
          );
    if (definition['archived'] != true &&
        (oldDefinition == null || oldDefinition.archived)) {
      if (await MenuDefinition.db.count(
            w.s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) & t.archived.equals(false),
            transaction: w.tx,
          ) >=
          200) {
        _fail(
          'menu_limit',
          'A restaurant supports 200 current catalogue items. Archive an unused item before adding another.',
        );
      }
    }
    if (id == null) {
      product = await MenuProduct.db.insertRow(
        w.s,
        MenuProduct(
          restaurantId: w.tenant,
          name: d['name'],
          description: definition['description'],
          priceMinor: d['priceMinor'],
          available: definition['available'] && !definition['archived'],
          version: 1,
        ),
        transaction: w.tx,
      );
    } else {
      product =
          await MenuProduct.db.findById(
            w.s,
            _int(d, 'productId', min: 1),
            transaction: w.tx,
          ) ??
          _fail('not_found', 'Menu item not found.');
      if (product.restaurantId != w.tenant) {
        _fail('not_found', 'Menu item not found.');
      }
      product.name = d['name'];
      product.description = definition['description'];
      product.priceMinor = d['priceMinor'];
      product.available = definition['available'] && !definition['archived'];
      product.version++;
      await MenuProduct.db.updateRow(w.s, product, transaction: w.tx);
    }
    if (d['mediaId'] != null) {
      final media = await MediaAsset.db.findById(
        w.s,
        _int(d, 'mediaId', min: 1),
        transaction: w.tx,
      );
      if (media == null ||
          media.restaurantId != w.tenant ||
          media.status != 'approved' ||
          media.purpose != 'menuImage' ||
          !media.public) {
        _fail('invalid_input', 'Choose an approved published menu image.');
      }
    }
    final existing = await MenuDefinition.db.findFirstRow(
      w.s,
      where: (t) => t.productId.equals(product.id!),
      transaction: w.tx,
    );
    if (existing == null) {
      await MenuDefinition.db.insertRow(
        w.s,
        MenuDefinition(
          restaurantId: w.tenant,
          productId: product.id!,
          category: d['category'],
          definitionJson: jsonEncode(definition),
          archived: definition['archived'],
          stockRemaining: d['stockRemaining'],
          version: product.version,
        ),
        transaction: w.tx,
      );
    } else {
      existing.category = d['category'];
      existing.definitionJson = jsonEncode(definition);
      existing.archived = definition['archived'];
      existing.stockRemaining = d['stockRemaining'];
      existing.version = product.version;
      await MenuDefinition.db.updateRow(w.s, existing, transaction: w.tx);
    }
    return product.id!;
  }

  static Future<void> _bumpMenu(Work w) async {
    w.policy!.menuVersion++;
    await RestaurantPolicy.db.updateRow(w.s, w.policy!, transaction: w.tx);
  }

  static Future<Json> saveItem(Session s, PlatformCommand c) =>
      _mutate(s, c, 'menu.save', (w, d) async {
        if (w.policy == null) {
          _fail('upgrade_required', 'Initialize restaurant policy first.');
        }
        _version(w.policy!.menuVersion, c.expectedVersion);
        final id = await _writeItem(w, d);
        await _bumpMenu(w);
        await w.audit('menu.item_saved', 'product', id);
        return {'id': id, 'menuVersion': w.policy!.menuVersion};
      }, roles: _managers);
  static Future<Json> availability(Session s, PlatformCommand c) =>
      _mutate(s, c, 'menu.availability', (w, d) async {
        _keys(d, {'available', 'stockRemaining'});
        if (d['available'] is! bool) {
          _fail('invalid_input', 'State whether the item is available.');
        }
        final product = await MenuProduct.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (product == null || product.restaurantId != w.tenant) {
          _fail('not_found', 'Item not found.');
        }
        _version(product.version, c.expectedVersion);
        product.available = _bool(d, 'available');
        product.version++;
        await MenuProduct.db.updateRow(s, product, transaction: w.tx);
        final def = await MenuDefinition.db.findFirstRow(
          s,
          where: (t) => t.productId.equals(product.id!),
          transaction: w.tx,
        );
        if (def != null) {
          def.stockRemaining = d['stockRemaining'] == null
              ? def.stockRemaining
              : _int(d, 'stockRemaining', max: 100000);
          def.version = product.version;
          await MenuDefinition.db.updateRow(s, def, transaction: w.tx);
        }
        // Availability is not a menu edit: order.submit re-prices every quote
        // and refuses lines that became unavailable, so other quotes stay valid.
        await w.audit('menu.availability', 'product', product.id);
        return {'version': product.version};
      }, roles: {'owner', 'manager', 'kitchen'});
  static Future<Json> draft(Session s, PlatformCommand c) =>
      _mutate(s, c, 'menu.draft', (w, d) async {
        _keys(d, {'items', 'discard'});
        final items = _list(
          d,
          'items',
          max: 200,
        ).map((v) => validateItem(_object(v))).toList();
        MenuDraft row;
        if (c.resourceId == null) {
          row = await MenuDraft.db.insertRow(
            s,
            MenuDraft(
              restaurantId: w.tenant,
              userId: w.user,
              itemsJson: jsonEncode(items),
              baseMenuVersion: w.policy!.menuVersion,
              version: 1,
              status: 'draft',
              createdAt: _now(),
            ),
            transaction: w.tx,
          );
        } else {
          row =
              await MenuDraft.db.findById(s, _id(c), transaction: w.tx) ??
              _fail('not_found', 'Draft not found.');
          if (row.restaurantId != w.tenant || row.status != 'draft') {
            _fail('not_found', 'Draft not found.');
          }
          _version(row.version, c.expectedVersion);
          row.itemsJson = jsonEncode(items);
          row.version++;
          if (_bool(d, 'discard')) row.status = 'discarded';
          await MenuDraft.db.updateRow(s, row, transaction: w.tx);
        }
        return {'id': row.id, 'version': row.version, 'status': row.status};
      }, roles: _managers);
  static Future<Json> publishDraft(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'menu.publishDraft',
    (w, d) async {
      _keys(d, {'confirm'});
      if (!_bool(d, 'confirm')) {
        _fail('confirmation_required', 'Confirm menu publication.');
      }
      final row = await MenuDraft.db.findById(s, _id(c), transaction: w.tx);
      if (row == null ||
          row.restaurantId != w.tenant ||
          row.status != 'draft') {
        _fail('not_found', 'Draft not found.');
      }
      _version(row.version, c.expectedVersion);
      _version(w.policy!.menuVersion, row.baseMenuVersion);
      final items = (jsonDecode(row.itemsJson) as List).cast<Json>();
      final names = <String>{};
      final productIds = <int>{};
      if (items.isEmpty) _fail('invalid_input', 'Draft is empty.');
      for (final item in items) {
        if (item['productId'] != null &&
            !productIds.add(_int(item, 'productId', min: 1))) {
          _fail('duplicate_item', 'A draft cannot update one product twice.');
        }
        if (!names.add((item['name'] as String).toLowerCase())) {
          _fail('duplicate_item', 'Resolve duplicate dish names.');
        }
      }
      // A published draft is the complete current catalogue. Archive omitted
      // entries in the same transaction, preserving historical product IDs.
      final old = await MenuDefinition.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) & t.archived.equals(false),
        transaction: w.tx,
      );
      for (final definition in old) {
        if (productIds.contains(definition.productId)) continue;
        definition.archived = true;
        definition.version++;
        definition.definitionJson = jsonEncode({
          ..._json(definition.definitionJson),
          'archived': true,
          'available': false,
        });
        await MenuDefinition.db.updateRow(s, definition, transaction: w.tx);
        final product = (await MenuProduct.db.findById(
          s,
          definition.productId,
          transaction: w.tx,
        ))!;
        product.available = false;
        product.version++;
        await MenuProduct.db.updateRow(s, product, transaction: w.tx);
      }
      for (final item in items) {
        await _writeItem(w, item);
      }
      await _bumpMenu(w);
      row.status = 'published';
      row.version++;
      await MenuDraft.db.updateRow(s, row, transaction: w.tx);
      await w.audit('menu.published', 'menuDraft', row.id);
      return {'menuVersion': w.policy!.menuVersion};
    },
    roles: _managers,
  );
}
