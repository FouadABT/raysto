import 'package:flutter/foundation.dart';

typedef Json = Map<String, dynamic>;
DateTime date(Object? value) => DateTime.parse(value as String);
List<T> readList<T>(Json j, String key, T Function(Json) read) =>
    (j[key] as List? ?? [])
        .map((v) => read(Map<String, dynamic>.from(v as Map)))
        .toList();
T enumValue<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

class DomainException implements Exception {
  const DomainException(this.message);
  final String message;
  @override
  String toString() => message;
}

enum DemoRole { guest, customer, owner, manager, waiter, kitchen, courier }

enum ServiceMode { dineIn, pickup, delivery }

enum OrderStatus {
  draft,
  submitted,
  accepted,
  preparing,
  ready,
  served,
  collected,
  delivered,
  completed,
  rejected,
  cancelled,
}

enum PaymentOutcome { success, pending, failed, cancelled }

enum AttemptStatus { pending, succeeded, failed, cancelled }

enum TableStatus { available, occupied, reserved, needsReset }

enum RequestStatus { sent, acknowledged, completed, cancelled }

enum DeliveryStatus {
  unassigned,
  assigned,
  collected,
  outForDelivery,
  delivered,
  issue,
}

enum ReservationStatus { confirmed, arrived, seated, cancelled, noShow }

@immutable
class Money {
  const Money(this.minor, [this.currency = 'EUR']);
  final int minor;
  final String currency;
  Money operator +(Money other) {
    if (other.currency != currency) {
      throw const DomainException('Currencies cannot be mixed.');
    }
    return Money(minor + other.minor, currency);
  }

  Json toJson() => {'minor': minor, 'currency': currency};
}

class DemoSettings {
  DemoSettings({
    this.locale = 'en',
    this.appearance = 'system',
    this.reducedMotion = false,
    this.haptics = true,
    this.textScale = 1,
    Map<String, String>? permissions,
    Map<String, bool>? notifications,
  }) : permissions =
           permissions ??
           {
             'location': 'notAsked',
             'camera': 'notAsked',
             'notifications': 'notAsked',
           },
       notifications =
           notifications ?? {'orders': true, 'offers': false, 'service': true};
  String locale, appearance;
  bool reducedMotion, haptics;
  double textScale;
  Map<String, String> permissions;
  Map<String, bool> notifications;
  Json toJson() => {
    'locale': locale,
    'appearance': appearance,
    'reducedMotion': reducedMotion,
    'haptics': haptics,
    'textScale': textScale,
    'permissions': permissions,
    'notifications': notifications,
  };
  factory DemoSettings.fromJson(Json j) => DemoSettings(
    locale: j['locale'] ?? 'en',
    appearance: j['appearance'] ?? 'system',
    reducedMotion: j['reducedMotion'] ?? false,
    haptics: j['haptics'] ?? true,
    textScale: (j['textScale'] as num? ?? 1).toDouble().clamp(1.0, 2.0),
    permissions: Map<String, String>.from(j['permissions'] ?? {}),
    notifications: Map<String, bool>.from(j['notifications'] ?? {}),
  );
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    this.instructions = '',
    this.isDefault = false,
    this.eligible = true,
  });
  final String id, label, street, city, instructions;
  final bool isDefault, eligible;
  Address copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? instructions,
    bool? isDefault,
    bool? eligible,
  }) => Address(
    id: id ?? this.id,
    label: label ?? this.label,
    street: street ?? this.street,
    city: city ?? this.city,
    instructions: instructions ?? this.instructions,
    isDefault: isDefault ?? this.isDefault,
    eligible: eligible ?? this.eligible,
  );
  Json toJson() => {
    'id': id,
    'label': label,
    'street': street,
    'city': city,
    'instructions': instructions,
    'isDefault': isDefault,
    'eligible': eligible,
  };
  factory Address.fromJson(Json j) => Address(
    id: j['id'],
    label: j['label'],
    street: j['street'],
    city: j['city'],
    instructions: j['instructions'] ?? '',
    isDefault: j['isDefault'] ?? false,
    eligible: j['eligible'] ?? true,
  );
}

class DemoAccount {
  DemoAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.restaurantId,
    this.active = true,
    this.onboardingStep = 0,
    this.onboardingComplete = false,
    this.avatar = 'assets/images/salad_bowl.jpg',
    List<Address>? addresses,
    Map<String, bool>? preferences,
    Set<String>? favorites,
    List<String>? assignedTableIds,
    List<String>? workspaceIds,
  }) : addresses = addresses ?? [],
       preferences = preferences ?? {},
       favorites = favorites ?? {},
       assignedTableIds = assignedTableIds ?? [],
       workspaceIds =
           workspaceIds ?? (restaurantId == null ? [] : [restaurantId]);
  final String id, email;
  String name, avatar;
  DemoRole role;
  String? restaurantId;
  bool active, onboardingComplete;
  int onboardingStep;
  List<Address> addresses;
  Map<String, bool> preferences;
  Set<String> favorites;
  List<String> assignedTableIds;
  List<String> workspaceIds;
  bool hasRestaurantAccess(String id) => workspaceIds.contains(id);
  List<RoleAssignment> get assignments => workspaceIds
      .map(
        (id) => RoleAssignment(
          accountId: this.id,
          restaurantId: id,
          role: role,
          active: active,
        ),
      )
      .toList();
  bool get isStaff => ![DemoRole.customer, DemoRole.guest].contains(role);
  Json toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.name,
    'restaurantId': restaurantId,
    'active': active,
    'onboardingStep': onboardingStep,
    'onboardingComplete': onboardingComplete,
    'avatar': avatar,
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'preferences': preferences,
    'favorites': favorites.toList(),
    'assignedTableIds': assignedTableIds,
    'workspaceIds': workspaceIds,
  };
  factory DemoAccount.fromJson(Json j) => DemoAccount(
    id: j['id'],
    email: j['email'],
    name: j['name'],
    role: enumValue(DemoRole.values, j['role'], DemoRole.customer),
    restaurantId: j['restaurantId'],
    active: j['active'] ?? true,
    onboardingStep: j['onboardingStep'] ?? 0,
    onboardingComplete: j['onboardingComplete'] ?? false,
    avatar: j['avatar'] ?? 'assets/images/salad_bowl.jpg',
    addresses: readList(j, 'addresses', Address.fromJson),
    preferences: Map<String, bool>.from(j['preferences'] ?? {}),
    favorites: Set<String>.from(j['favorites'] ?? []),
    assignedTableIds: List<String>.from(j['assignedTableIds'] ?? []),
    workspaceIds: j['workspaceIds'] == null
        ? null
        : List<String>.from(j['workspaceIds']),
  );
}

class RoleAssignment {
  const RoleAssignment({
    required this.accountId,
    required this.restaurantId,
    required this.role,
    this.active = true,
  });
  final String accountId, restaurantId;
  final DemoRole role;
  final bool active;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    this.description = '',
    this.address = '',
    this.phone = '+000 000 000',
    this.cover = 'assets/images/salad_bowl.jpg',
    this.currency = 'EUR',
    this.services = const [
      ServiceMode.dineIn,
      ServiceMode.pickup,
      ServiceMode.delivery,
    ],
    this.open = true,
    this.published = true,
    this.payAtEnd = false,
    this.deliveryFeeMinor = 200,
    this.minimumDeliveryMinor = 1000,
    this.preparationMinutes = 20,
    this.hours = 'Mon–Sun 11:00–22:00',
    this.plan = 'Starter',
    this.guestOrdering = true,
    this.serviceArea = 'Demo Central',
    this.paypalConnected = true,
    this.logoAsset = 'assets/images/salad_bowl.jpg',
    this.deliverySlots = const ['ASAP', 'In 30 minutes', 'In 60 minutes'],
    this.pickupSlots = const ['ASAP', 'In 30 minutes', 'In 60 minutes'],
  });
  final String id,
      name,
      description,
      address,
      phone,
      cover,
      currency,
      hours,
      plan,
      serviceArea;
  final List<ServiceMode> services;
  final String logoAsset;
  final List<String> deliverySlots, pickupSlots;
  final bool open, published, payAtEnd, guestOrdering, paypalConnected;
  final int deliveryFeeMinor, minimumDeliveryMinor, preparationMinutes;
  Restaurant copyWith({
    String? name,
    String? description,
    String? address,
    String? phone,
    String? cover,
    List<ServiceMode>? services,
    bool? open,
    bool? published,
    bool? payAtEnd,
    int? deliveryFeeMinor,
    int? minimumDeliveryMinor,
    int? preparationMinutes,
    String? hours,
    String? plan,
    bool? guestOrdering,
    String? serviceArea,
    bool? paypalConnected,
    String? logoAsset,
    List<String>? deliverySlots,
    List<String>? pickupSlots,
  }) => Restaurant(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    cover: cover ?? this.cover,
    currency: currency,
    services: services ?? this.services,
    open: open ?? this.open,
    published: published ?? this.published,
    payAtEnd: payAtEnd ?? this.payAtEnd,
    deliveryFeeMinor: deliveryFeeMinor ?? this.deliveryFeeMinor,
    minimumDeliveryMinor: minimumDeliveryMinor ?? this.minimumDeliveryMinor,
    preparationMinutes: preparationMinutes ?? this.preparationMinutes,
    hours: hours ?? this.hours,
    plan: plan ?? this.plan,
    guestOrdering: guestOrdering ?? this.guestOrdering,
    serviceArea: serviceArea ?? this.serviceArea,
    paypalConnected: paypalConnected ?? this.paypalConnected,
    logoAsset: logoAsset ?? this.logoAsset,
    deliverySlots: deliverySlots ?? this.deliverySlots,
    pickupSlots: pickupSlots ?? this.pickupSlots,
  );
  Json toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'phone': phone,
    'cover': cover,
    'currency': currency,
    'services': services.map((e) => e.name).toList(),
    'open': open,
    'published': published,
    'payAtEnd': payAtEnd,
    'deliveryFeeMinor': deliveryFeeMinor,
    'minimumDeliveryMinor': minimumDeliveryMinor,
    'preparationMinutes': preparationMinutes,
    'hours': hours,
    'plan': plan,
    'guestOrdering': guestOrdering,
    'serviceArea': serviceArea,
    'paypalConnected': paypalConnected,
    'logoAsset': logoAsset,
    'deliverySlots': deliverySlots,
    'pickupSlots': pickupSlots,
  };
  factory Restaurant.fromJson(Json j) => Restaurant(
    id: j['id'],
    name: j['name'],
    description: j['description'] ?? '',
    address: j['address'] ?? '',
    phone: j['phone'] ?? '',
    cover: j['cover'] ?? 'assets/images/salad_bowl.jpg',
    currency: j['currency'] ?? 'EUR',
    services: (j['services'] as List? ?? [])
        .map((e) => enumValue(ServiceMode.values, e, ServiceMode.dineIn))
        .toList(),
    open: j['open'] ?? true,
    published: j['published'] ?? true,
    payAtEnd: j['payAtEnd'] ?? false,
    deliveryFeeMinor: j['deliveryFeeMinor'] ?? 200,
    minimumDeliveryMinor: j['minimumDeliveryMinor'] ?? 1000,
    preparationMinutes: j['preparationMinutes'] ?? 20,
    hours: j['hours'] ?? '',
    plan: j['plan'] ?? 'Starter',
    guestOrdering: j['guestOrdering'] ?? true,
    serviceArea: j['serviceArea'] ?? 'Demo Central',
    paypalConnected: j['paypalConnected'] ?? true,
    logoAsset: j['logoAsset'] ?? 'assets/images/salad_bowl.jpg',
    deliverySlots: List<String>.from(
      j['deliverySlots'] ?? ['ASAP', 'In 30 minutes', 'In 60 minutes'],
    ),
    pickupSlots: List<String>.from(
      j['pickupSlots'] ?? ['ASAP', 'In 30 minutes', 'In 60 minutes'],
    ),
  );
}

/// An authored daily demo opening interval, including overnight service.
class OpeningInterval {
  const OpeningInterval(this.startMinute, this.endMinute);
  final int startMinute, endMinute;
  bool contains(DateTime at) {
    final minute = at.hour * 60 + at.minute;
    return startMinute < endMinute
        ? minute >= startMinute && minute < endMinute
        : minute >= startMinute || minute < endMinute;
  }
}

class ModifierOption {
  const ModifierOption({
    required this.id,
    required this.name,
    this.priceMinor = 0,
  });
  final String id, name;
  final int priceMinor;
  Json toJson() => {'id': id, 'name': name, 'priceMinor': priceMinor};
  factory ModifierOption.fromJson(Json j) => ModifierOption(
    id: j['id'],
    name: j['name'],
    priceMinor: j['priceMinor'] ?? 0,
  );
}

class ModifierGroup {
  const ModifierGroup({
    required this.id,
    required this.name,
    required this.options,
    this.minSelections = 0,
    this.maxSelections = 1,
  });
  final String id, name;
  final List<ModifierOption> options;
  final int minSelections, maxSelections;
  bool get required => minSelections > 0;
  Json toJson() => {
    'id': id,
    'name': name,
    'options': options.map((e) => e.toJson()).toList(),
    'minSelections': minSelections,
    'maxSelections': maxSelections,
  };
  factory ModifierGroup.fromJson(Json j) => ModifierGroup(
    id: j['id'],
    name: j['name'],
    options: readList(j, 'options', ModifierOption.fromJson),
    minSelections: j['minSelections'] ?? 0,
    maxSelections: j['maxSelections'] ?? 1,
  );
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.category,
    required this.priceMinor,
    this.description = '',
    this.asset = 'assets/images/salad_bowl.jpg',
    this.ingredients = const [],
    this.dietary = const [],
    this.dietaryKnown = true,
    this.available = true,
    this.archived = false,
    this.modifierGroups = const [],
    this.reviewFlags = const [],
  });
  final String id, restaurantId, name, category, description, asset;
  final int priceMinor;
  final List<String> ingredients, dietary, reviewFlags;
  final bool dietaryKnown, available, archived;
  final List<ModifierGroup> modifierGroups;
  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    int? priceMinor,
    String? description,
    String? asset,
    List<String>? ingredients,
    List<String>? dietary,
    bool? dietaryKnown,
    bool? available,
    bool? archived,
    List<ModifierGroup>? modifierGroups,
    List<String>? reviewFlags,
  }) => MenuItem(
    id: id ?? this.id,
    restaurantId: restaurantId,
    name: name ?? this.name,
    category: category ?? this.category,
    priceMinor: priceMinor ?? this.priceMinor,
    description: description ?? this.description,
    asset: asset ?? this.asset,
    ingredients: ingredients ?? this.ingredients,
    dietary: dietary ?? this.dietary,
    dietaryKnown: dietaryKnown ?? this.dietaryKnown,
    available: available ?? this.available,
    archived: archived ?? this.archived,
    modifierGroups: modifierGroups ?? this.modifierGroups,
    reviewFlags: reviewFlags ?? this.reviewFlags,
  );
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'name': name,
    'category': category,
    'priceMinor': priceMinor,
    'description': description,
    'asset': asset,
    'ingredients': ingredients,
    'dietary': dietary,
    'dietaryKnown': dietaryKnown,
    'available': available,
    'archived': archived,
    'modifierGroups': modifierGroups.map((e) => e.toJson()).toList(),
    'reviewFlags': reviewFlags,
  };
  factory MenuItem.fromJson(Json j) => MenuItem(
    id: j['id'],
    restaurantId: j['restaurantId'],
    name: j['name'],
    category: j['category'],
    priceMinor: j['priceMinor'],
    description: j['description'] ?? '',
    asset: j['asset'] ?? 'assets/images/salad_bowl.jpg',
    ingredients: List<String>.from(j['ingredients'] ?? []),
    dietary: List<String>.from(j['dietary'] ?? []),
    dietaryKnown: j['dietaryKnown'] ?? true,
    available: j['available'] ?? true,
    archived: j['archived'] ?? false,
    modifierGroups: readList(j, 'modifierGroups', ModifierGroup.fromJson),
    reviewFlags: List<String>.from(j['reviewFlags'] ?? []),
  );
}

class DemoTable {
  const DemoTable({
    required this.id,
    required this.restaurantId,
    required this.label,
    this.seats = 4,
    this.zone = 'Main room',
    this.shape = 'round',
    this.x = 80,
    this.y = 80,
    this.width = 72,
    this.height = 72,
    this.rotation = 0,
    this.status = TableStatus.available,
    this.active = true,
    this.assignedStaffId,
  });
  final String id, restaurantId, label, zone, shape;
  final int seats;
  final double x, y, width, height, rotation;
  final TableStatus status;
  final bool active;
  final String? assignedStaffId;
  DemoTable copyWith({
    String? id,
    String? label,
    int? seats,
    String? zone,
    String? shape,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    TableStatus? status,
    bool? active,
    String? assignedStaffId,
  }) => DemoTable(
    id: id ?? this.id,
    restaurantId: restaurantId,
    label: label ?? this.label,
    seats: seats ?? this.seats,
    zone: zone ?? this.zone,
    shape: shape ?? this.shape,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    rotation: rotation ?? this.rotation,
    status: status ?? this.status,
    active: active ?? this.active,
    assignedStaffId: assignedStaffId ?? this.assignedStaffId,
  );
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'label': label,
    'seats': seats,
    'zone': zone,
    'shape': shape,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'rotation': rotation,
    'status': status.name,
    'active': active,
    'assignedStaffId': assignedStaffId,
  };
  factory DemoTable.fromJson(Json j) => DemoTable(
    id: j['id'],
    restaurantId: j['restaurantId'],
    label: j['label'],
    seats: j['seats'] ?? 4,
    zone: j['zone'] ?? 'Main room',
    shape: j['shape'] ?? 'round',
    x: (j['x'] as num).toDouble(),
    y: (j['y'] as num).toDouble(),
    width: (j['width'] as num? ?? 72).toDouble(),
    height: (j['height'] as num? ?? 72).toDouble(),
    rotation: (j['rotation'] as num? ?? 0).toDouble(),
    status: enumValue(TableStatus.values, j['status'], TableStatus.available),
    active: j['active'] ?? true,
    assignedStaffId: j['assignedStaffId'],
  );
}

class FloorObject {
  const FloorObject({
    required this.id,
    required this.restaurantId,
    required this.type,
    this.label = '',
    this.zone = 'Main room',
    this.x = 0,
    this.y = 0,
    this.width = 100,
    this.height = 12,
    this.rotation = 0,
  });
  final String id, restaurantId, type, label, zone;
  final double x, y, width, height, rotation;
  FloorObject copyWith({
    String? id,
    String? type,
    String? label,
    String? zone,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
  }) => FloorObject(
    id: id ?? this.id,
    restaurantId: restaurantId,
    type: type ?? this.type,
    label: label ?? this.label,
    zone: zone ?? this.zone,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    rotation: rotation ?? this.rotation,
  );
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'type': type,
    'label': label,
    'zone': zone,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'rotation': rotation,
  };
  factory FloorObject.fromJson(Json j) => FloorObject(
    id: j['id'],
    restaurantId: j['restaurantId'],
    type: j['type'],
    label: j['label'] ?? '',
    zone: j['zone'] ?? 'Main room',
    x: (j['x'] as num).toDouble(),
    y: (j['y'] as num).toDouble(),
    width: (j['width'] as num).toDouble(),
    height: (j['height'] as num).toDouble(),
    rotation: (j['rotation'] as num? ?? 0).toDouble(),
  );
}

class TableVisit {
  TableVisit({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.startedAt,
    required this.invitation,
    required this.invitationExpiresAt,
    this.guestCount = 2,
    List<String>? participantIds,
    this.closedAt,
    this.note = '',
  }) : participantIds = participantIds ?? [];
  final String id, restaurantId, invitation;
  String tableId, note;
  final DateTime startedAt, invitationExpiresAt;
  DateTime? closedAt;
  int guestCount;
  List<String> participantIds;
  bool get active => closedAt == null;
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'tableId': tableId,
    'startedAt': startedAt.toIso8601String(),
    'invitation': invitation,
    'invitationExpiresAt': invitationExpiresAt.toIso8601String(),
    'guestCount': guestCount,
    'participantIds': participantIds,
    'closedAt': closedAt?.toIso8601String(),
    'note': note,
  };
  factory TableVisit.fromJson(Json j) => TableVisit(
    id: j['id'],
    restaurantId: j['restaurantId'],
    tableId: j['tableId'],
    startedAt: date(j['startedAt']),
    invitation: j['invitation'],
    invitationExpiresAt: date(j['invitationExpiresAt']),
    guestCount: j['guestCount'] ?? 2,
    participantIds: List<String>.from(j['participantIds'] ?? []),
    closedAt: j['closedAt'] == null ? null : date(j['closedAt']),
    note: j['note'] ?? '',
  );
}

class CartLine {
  const CartLine({
    required this.id,
    required this.itemId,
    required this.name,
    required this.unitPriceMinor,
    this.quantity = 1,
    this.modifiers = const [],
    this.selections = const {},
    this.note = '',
    this.completed = false,
  });
  final String id, itemId, name, note;
  final int unitPriceMinor, quantity;
  final List<ModifierOption> modifiers;
  final Map<String, List<String>> selections;
  final bool completed;
  int get subtotalMinor =>
      (unitPriceMinor +
          modifiers.fold<int>(0, (sum, e) => sum + e.priceMinor)) *
      quantity;
  CartLine copyWith({
    String? id,
    int? quantity,
    String? note,
    bool? completed,
  }) => CartLine(
    id: id ?? this.id,
    itemId: itemId,
    name: name,
    unitPriceMinor: unitPriceMinor,
    quantity: quantity ?? this.quantity,
    modifiers: modifiers,
    selections: selections,
    note: note ?? this.note,
    completed: completed ?? this.completed,
  );
  Json toJson() => {
    'id': id,
    'itemId': itemId,
    'name': name,
    'unitPriceMinor': unitPriceMinor,
    'quantity': quantity,
    'modifiers': modifiers.map((e) => e.toJson()).toList(),
    'selections': selections,
    'note': note,
    'completed': completed,
  };
  factory CartLine.fromJson(Json j) => CartLine(
    id: j['id'],
    itemId: j['itemId'],
    name: j['name'],
    unitPriceMinor: j['unitPriceMinor'],
    quantity: j['quantity'] ?? 1,
    modifiers: readList(j, 'modifiers', ModifierOption.fromJson),
    selections: (j['selections'] as Map? ?? {}).map(
      (k, v) => MapEntry(k as String, List<String>.from(v as List)),
    ),
    note: j['note'] ?? '',
    completed: j['completed'] ?? false,
  );
}

class Cart {
  Cart({
    required this.accountId,
    required this.restaurantId,
    List<CartLine>? lines,
    this.mode = ServiceMode.pickup,
    this.visitId,
    this.addressId,
    this.pickupSlot,
    this.coupon = '',
    this.tipMinor = 0,
    this.revision = 0,
  }) : lines = lines ?? [];
  final String accountId, restaurantId;
  List<CartLine> lines;
  ServiceMode mode;
  String? visitId, addressId, pickupSlot;
  String coupon;
  int tipMinor, revision;
  Json toJson() => {
    'accountId': accountId,
    'restaurantId': restaurantId,
    'lines': lines.map((e) => e.toJson()).toList(),
    'mode': mode.name,
    'visitId': visitId,
    'addressId': addressId,
    'pickupSlot': pickupSlot,
    'coupon': coupon,
    'tipMinor': tipMinor,
    'revision': revision,
  };
  factory Cart.fromJson(Json j) => Cart(
    accountId: j['accountId'],
    restaurantId: j['restaurantId'],
    lines: readList(j, 'lines', CartLine.fromJson),
    mode: enumValue(ServiceMode.values, j['mode'], ServiceMode.pickup),
    visitId: j['visitId'],
    addressId: j['addressId'],
    pickupSlot: j['pickupSlot'],
    coupon: j['coupon'] ?? '',
    tipMinor: j['tipMinor'] ?? 0,
    revision: j['revision'] ?? 0,
  );
}

class CartTotals {
  const CartTotals({
    required this.subtotalMinor,
    required this.discountMinor,
    required this.deliveryFeeMinor,
    required this.tipMinor,
    required this.currency,
  });
  final int subtotalMinor, discountMinor, deliveryFeeMinor, tipMinor;
  final String currency;
  int get totalMinor =>
      subtotalMinor - discountMinor + deliveryFeeMinor + tipMinor;
}

class Order {
  Order({
    required this.id,
    required this.restaurantId,
    required this.accountId,
    required this.mode,
    required this.lines,
    required this.totalMinor,
    required this.createdAt,
    this.visitId,
    this.status = OrderStatus.submitted,
    this.note = '',
    this.reason = '',
    this.deliveryFeeMinor = 0,
    this.discountMinor = 0,
    this.tipMinor = 0,
    this.address,
    this.pickupSlot,
    List<String>? events,
  }) : events = events ?? [];
  final String id, restaurantId, accountId;
  final ServiceMode mode;
  final String? visitId, address, pickupSlot;
  List<CartLine> lines;
  final int totalMinor, deliveryFeeMinor, discountMinor, tipMinor;
  final DateTime createdAt;
  OrderStatus status;
  String note, reason;
  List<String> events;
  bool get cancelled =>
      status == OrderStatus.cancelled || status == OrderStatus.rejected;
  bool get actionable => [
    OrderStatus.submitted,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
  ].contains(status);
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'accountId': accountId,
    'mode': mode.name,
    'lines': lines.map((e) => e.toJson()).toList(),
    'totalMinor': totalMinor,
    'createdAt': createdAt.toIso8601String(),
    'visitId': visitId,
    'status': status.name,
    'note': note,
    'reason': reason,
    'deliveryFeeMinor': deliveryFeeMinor,
    'discountMinor': discountMinor,
    'tipMinor': tipMinor,
    'address': address,
    'pickupSlot': pickupSlot,
    'events': events,
  };
  factory Order.fromJson(Json j) => Order(
    id: j['id'],
    restaurantId: j['restaurantId'],
    accountId: j['accountId'],
    mode: enumValue(ServiceMode.values, j['mode'], ServiceMode.pickup),
    lines: readList(j, 'lines', CartLine.fromJson),
    totalMinor: j['totalMinor'],
    createdAt: date(j['createdAt']),
    visitId: j['visitId'],
    status: enumValue(OrderStatus.values, j['status'], OrderStatus.submitted),
    note: j['note'] ?? '',
    reason: j['reason'] ?? '',
    deliveryFeeMinor: j['deliveryFeeMinor'] ?? 0,
    discountMinor: j['discountMinor'] ?? 0,
    tipMinor: j['tipMinor'] ?? 0,
    address: j['address'],
    pickupSlot: j['pickupSlot'],
    events: List<String>.from(j['events'] ?? []),
  );
}

class CheckoutAttempt {
  CheckoutAttempt({
    required this.id,
    required this.accountId,
    required this.restaurantId,
    required this.totalMinor,
    required this.createdAt,
    required this.snapshot,
    this.visitId,
    this.orderId,
    this.status = AttemptStatus.pending,
    this.method = 'Demo PayPal',
    Map<String, int>? allocations,
    this.cartRevision = 0,
    this.generation = 0,
    this.deliveryFeeMinor = 0,
    this.discountMinor = 0,
    this.tipMinor = 0,
    this.address,
  }) : allocations = allocations ?? {};
  final String id, accountId, restaurantId, method;
  final String? visitId;
  String? orderId;
  final int totalMinor, cartRevision, generation;
  final int deliveryFeeMinor, discountMinor, tipMinor;
  final String? address;
  final DateTime createdAt;
  final Cart snapshot;
  final Map<String, int> allocations;
  AttemptStatus status;
  Json toJson() => {
    'id': id,
    'accountId': accountId,
    'restaurantId': restaurantId,
    'totalMinor': totalMinor,
    'createdAt': createdAt.toIso8601String(),
    'snapshot': snapshot.toJson(),
    'visitId': visitId,
    'orderId': orderId,
    'status': status.name,
    'method': method,
    'allocations': allocations,
    'cartRevision': cartRevision,
    'generation': generation,
    'deliveryFeeMinor': deliveryFeeMinor,
    'discountMinor': discountMinor,
    'tipMinor': tipMinor,
    'address': address,
  };
  factory CheckoutAttempt.fromJson(Json j) => CheckoutAttempt(
    id: j['id'],
    accountId: j['accountId'],
    restaurantId: j['restaurantId'],
    totalMinor: j['totalMinor'],
    createdAt: date(j['createdAt']),
    snapshot: Cart.fromJson(Map<String, dynamic>.from(j['snapshot'])),
    visitId: j['visitId'],
    orderId: j['orderId'],
    status: enumValue(AttemptStatus.values, j['status'], AttemptStatus.pending),
    method: j['method'] ?? 'Demo PayPal',
    allocations: Map<String, int>.from(j['allocations'] ?? {}),
    cartRevision: j['cartRevision'] ?? 0,
    generation: j['generation'] ?? 0,
    deliveryFeeMinor: j['deliveryFeeMinor'] ?? 0,
    discountMinor: j['discountMinor'] ?? 0,
    tipMinor: j['tipMinor'] ?? 0,
    address: j['address'],
  );
}

class Payment {
  const Payment({
    required this.id,
    required this.attemptId,
    required this.restaurantId,
    required this.accountId,
    required this.amountMinor,
    required this.allocations,
    required this.createdAt,
    required this.method,
    this.visitId,
  });
  final String id, attemptId, restaurantId, accountId, method;
  final String? visitId;
  final int amountMinor;
  final Map<String, int> allocations;
  final DateTime createdAt;
  Json toJson() => {
    'id': id,
    'attemptId': attemptId,
    'restaurantId': restaurantId,
    'accountId': accountId,
    'amountMinor': amountMinor,
    'allocations': allocations,
    'createdAt': createdAt.toIso8601String(),
    'method': method,
    'visitId': visitId,
  };
  factory Payment.fromJson(Json j) => Payment(
    id: j['id'],
    attemptId: j['attemptId'],
    restaurantId: j['restaurantId'],
    accountId: j['accountId'],
    amountMinor: j['amountMinor'],
    allocations: Map<String, int>.from(j['allocations']),
    createdAt: date(j['createdAt']),
    method: j['method'],
    visitId: j['visitId'],
  );
}

class Refund {
  const Refund({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    required this.amountMinor,
    required this.reason,
    required this.createdAt,
  });
  final String id, orderId, restaurantId, reason;
  final int amountMinor;
  final DateTime createdAt;
  Json toJson() => {
    'id': id,
    'orderId': orderId,
    'restaurantId': restaurantId,
    'amountMinor': amountMinor,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };
  factory Refund.fromJson(Json j) => Refund(
    id: j['id'],
    orderId: j['orderId'],
    restaurantId: j['restaurantId'],
    amountMinor: j['amountMinor'],
    reason: j['reason'],
    createdAt: date(j['createdAt']),
  );
}

class ServiceRequest {
  ServiceRequest({
    required this.id,
    required this.restaurantId,
    required this.visitId,
    required this.accountId,
    required this.kind,
    required this.createdAt,
    this.note = '',
    this.status = RequestStatus.sent,
    this.assigneeId,
    this.reason = '',
  });
  final String id, restaurantId, visitId, accountId, kind;
  final DateTime createdAt;
  String note, reason;
  String? assigneeId;
  RequestStatus status;
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'visitId': visitId,
    'accountId': accountId,
    'kind': kind,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
    'status': status.name,
    'assigneeId': assigneeId,
    'reason': reason,
  };
  factory ServiceRequest.fromJson(Json j) => ServiceRequest(
    id: j['id'],
    restaurantId: j['restaurantId'],
    visitId: j['visitId'],
    accountId: j['accountId'],
    kind: j['kind'],
    createdAt: date(j['createdAt']),
    note: j['note'] ?? '',
    status: enumValue(RequestStatus.values, j['status'], RequestStatus.sent),
    assigneeId: j['assigneeId'],
    reason: j['reason'] ?? '',
  );
}

class DeliveryTask {
  DeliveryTask({
    required this.id,
    required this.restaurantId,
    required this.orderId,
    required this.address,
    required this.createdAt,
    this.courierId,
    this.status = DeliveryStatus.unassigned,
    this.note = '',
    this.issue = '',
  });
  final String id, restaurantId, orderId, address;
  final DateTime createdAt;
  String? courierId;
  DeliveryStatus status;
  String note, issue;
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'orderId': orderId,
    'address': address,
    'createdAt': createdAt.toIso8601String(),
    'courierId': courierId,
    'status': status.name,
    'note': note,
    'issue': issue,
  };
  factory DeliveryTask.fromJson(Json j) => DeliveryTask(
    id: j['id'],
    restaurantId: j['restaurantId'],
    orderId: j['orderId'],
    address: j['address'],
    createdAt: date(j['createdAt']),
    courierId: j['courierId'],
    status: enumValue(
      DeliveryStatus.values,
      j['status'],
      DeliveryStatus.unassigned,
    ),
    note: j['note'] ?? '',
    issue: j['issue'] ?? '',
  );
}

class Reservation {
  Reservation({
    required this.id,
    required this.restaurantId,
    required this.accountId,
    required this.at,
    required this.guests,
    this.note = '',
    this.status = ReservationStatus.confirmed,
    this.visitId,
  });
  final String id, restaurantId, accountId;
  DateTime at;
  int guests;
  String note;
  ReservationStatus status;
  String? visitId;
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'accountId': accountId,
    'at': at.toIso8601String(),
    'guests': guests,
    'note': note,
    'status': status.name,
    'visitId': visitId,
  };
  factory Reservation.fromJson(Json j) => Reservation(
    id: j['id'],
    restaurantId: j['restaurantId'],
    accountId: j['accountId'],
    at: date(j['at']),
    guests: j['guests'],
    note: j['note'] ?? '',
    status: enumValue(
      ReservationStatus.values,
      j['status'],
      ReservationStatus.confirmed,
    ),
    visitId: j['visitId'],
  );
}

class WaitlistEntry {
  WaitlistEntry({
    required this.id,
    required this.restaurantId,
    required this.accountId,
    required this.createdAt,
    required this.guests,
    this.active = true,
    this.notified = false,
  });
  final String id, restaurantId, accountId;
  final DateTime createdAt;
  final int guests;
  bool active, notified;
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'accountId': accountId,
    'createdAt': createdAt.toIso8601String(),
    'guests': guests,
    'active': active,
    'notified': notified,
  };
  factory WaitlistEntry.fromJson(Json j) => WaitlistEntry(
    id: j['id'],
    restaurantId: j['restaurantId'],
    accountId: j['accountId'],
    createdAt: date(j['createdAt']),
    guests: j['guests'],
    active: j['active'] ?? true,
    notified: j['notified'] ?? false,
  );
}

class DemoNotification {
  DemoNotification({
    required this.id,
    required this.accountId,
    required this.restaurantId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.target = '',
    this.read = false,
    this.dismissed = false,
  });
  final String id, accountId, restaurantId, title, body, target;
  final DateTime createdAt;
  bool read, dismissed;
  Json toJson() => {
    'id': id,
    'accountId': accountId,
    'restaurantId': restaurantId,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'target': target,
    'read': read,
    'dismissed': dismissed,
  };
  factory DemoNotification.fromJson(Json j) => DemoNotification(
    id: j['id'],
    accountId: j['accountId'],
    restaurantId: j['restaurantId'],
    title: j['title'],
    body: j['body'],
    createdAt: date(j['createdAt']),
    target: j['target'] ?? '',
    read: j['read'] ?? false,
    dismissed: j['dismissed'] ?? false,
  );
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.restaurantId,
    required this.accountId,
    required this.title,
    required this.createdAt,
    this.target = '',
    this.detail = '',
  });
  final String id, restaurantId, accountId, title, target, detail;
  final DateTime createdAt;
  Json toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'accountId': accountId,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'target': target,
    'detail': detail,
  };
  factory ActivityEvent.fromJson(Json j) => ActivityEvent(
    id: j['id'],
    restaurantId: j['restaurantId'],
    accountId: j['accountId'],
    title: j['title'],
    createdAt: date(j['createdAt']),
    target: j['target'] ?? '',
    detail: j['detail'] ?? '',
  );
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.accountId,
    required this.text,
    required this.createdAt,
    this.orderId,
    this.fromSupport = false,
  });
  final String id, accountId, text;
  final String? orderId;
  final DateTime createdAt;
  final bool fromSupport;
  Json toJson() => {
    'id': id,
    'accountId': accountId,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'orderId': orderId,
    'fromSupport': fromSupport,
  };
  factory SupportMessage.fromJson(Json j) => SupportMessage(
    id: j['id'],
    accountId: j['accountId'],
    text: j['text'],
    createdAt: date(j['createdAt']),
    orderId: j['orderId'],
    fromSupport: j['fromSupport'] ?? false,
  );
}

class LocalReview {
  const LocalReview({
    required this.orderId,
    required this.accountId,
    required this.rating,
    required this.note,
  });
  final String orderId, accountId, note;
  final int rating;
  Json toJson() => {
    'orderId': orderId,
    'accountId': accountId,
    'rating': rating,
    'note': note,
  };
  factory LocalReview.fromJson(Json j) => LocalReview(
    orderId: j['orderId'],
    accountId: j['accountId'],
    rating: j['rating'],
    note: j['note'],
  );
}

class DemoReport {
  const DemoReport({
    required this.salesMinor,
    required this.capturedMinor,
    required this.refundedMinor,
    required this.outstandingMinor,
    required this.orderCount,
    required this.channelCounts,
    required this.topItems,
  });
  final int salesMinor,
      capturedMinor,
      refundedMinor,
      outstandingMinor,
      orderCount;
  final Map<ServiceMode, int> channelCounts;
  final Map<String, int> topItems;
  int get averageMinor =>
      orderCount == 0 ? 0 : (salesMinor / orderCount).round();
}
