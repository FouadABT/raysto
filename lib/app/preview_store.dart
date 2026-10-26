import 'package:flutter/foundation.dart';

/// Authored examples only. Nothing in this model represents a live restaurant.
@immutable
class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.asset,
    required this.ingredients,
  });
  final String id;
  final String name;
  final String category;
  final String description;
  final String asset;
  final String ingredients;
}

const sampleDishes = <Dish>[
  Dish(
    id: 'bowl',
    name: 'The seasonal bowl',
    category: 'Fresh',
    description:
        'A little color, a little crunch. A generous bowl of simple, good things.',
    asset: 'assets/images/salad_bowl.jpg',
    ingredients:
        'Avocado, chickpeas, roasted sweet potato, tomatoes and salad greens.',
  ),
  Dish(
    id: 'pasta',
    name: 'Tomato & basil pasta',
    category: 'Comfort',
    description:
        'The familiar favorite. Farfalle, sweet tomatoes and a handful of fresh basil.',
    asset: 'assets/images/tomato_pasta.jpg',
    ingredients: 'Farfalle pasta, cherry tomatoes, basil and olive oil.',
  ),
  Dish(
    id: 'pizza',
    name: 'A simple margherita',
    category: 'Comfort',
    description:
        'Golden edges and a classic combination. Made for an unhurried moment.',
    asset: 'assets/images/wood_fired_pizza.jpg',
    ingredients: 'Pizza dough, tomato, mozzarella and fresh basil.',
  ),
];

@immutable
class SavedDish {
  const SavedDish({
    required this.dish,
    this.note = '',
    this.collection = 'Want to try',
  });
  final Dish dish;
  final String note;
  final String collection;
}

/// The single source of truth for this session's explicitly labeled preview.
class PreviewStore extends ChangeNotifier {
  final Map<String, SavedDish> _saved = {};
  bool _reducedMotion = false;
  int _destination = 0;
  int get destination => _destination;
  set destination(int value) {
    if (value == _destination || value < 0 || value > 2) return;
    _destination = value;
    notifyListeners();
  }

  bool get reducedMotion => _reducedMotion;
  List<SavedDish> get saved => List.unmodifiable(_saved.values);
  SavedDish? find(String id) => _saved[id];

  set reducedMotion(bool value) {
    if (_reducedMotion == value) return;
    _reducedMotion = value;
    notifyListeners();
  }

  void save(SavedDish value) {
    _saved[value.dish.id] = value;
    notifyListeners();
  }

  SavedDish? remove(String id) {
    final previous = _saved.remove(id);
    if (previous != null) notifyListeners();
    return previous;
  }

  void restore(String id, SavedDish? previous) {
    if (previous == null) {
      _saved.remove(id);
    } else {
      _saved[id] = previous;
    }
    notifyListeners();
  }
}
