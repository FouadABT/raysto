import 'models.dart';

/// Converts user-authored lines into reviewable menu records, without AI guesses.
List<MenuItem> composeMenuDraft(String source, String restaurantId) {
  if (source.trim().isEmpty || source.length > 16000) {
    throw const DomainException('Paste a menu of up to 60 dishes to continue.');
  }
  final lines = source
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (lines.length > 60) {
    throw const DomainException('Paste a menu of up to 60 dishes to continue.');
  }
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final result = <MenuItem>[];
  for (var index = 0; index < lines.length; index++) {
    final parts = lines[index].split('|').map((s) => s.trim()).toList();
    if (parts.length < 3 ||
        parts.length > 4 ||
        parts[0].isEmpty ||
        parts[1].length < 2) {
      throw DomainException(
        'Line ${index + 1}: use Category | Dish | Price | Description.',
      );
    }
    final value = parts[2]
        .replaceAll('€', '')
        .replaceAll(RegExp(r'\bEUR\b', caseSensitive: false), '')
        .trim()
        .replaceAll(',', '.');
    final valid = RegExp(r'^\d{1,5}(\.\d{1,2})?$').hasMatch(value);
    final priceParts = value.split('.');
    final amount = valid
        ? int.parse(priceParts[0]) * 100 +
              (priceParts.length == 2
                  ? int.parse(priceParts[1].padRight(2, '0'))
                  : 0)
        : 0;
    result.add(
      MenuItem(
        id: '$restaurantId-composed-$stamp-$index',
        restaurantId: restaurantId,
        category: parts[0],
        name: parts[1],
        priceMinor: amount,
        description: parts.length == 4 ? parts[3] : '',
        asset: '',
        dietaryKnown: false,
        reviewFlags: [
          valid ? 'Review dish details' : 'Confirm the price before publishing',
        ],
      ),
    );
  }
  return result;
}
