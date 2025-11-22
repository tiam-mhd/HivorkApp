/// Helper class for generating all possible combinations of attribute values
class VariantCombinationGenerator {
  /// Generates Cartesian product of attribute values
  /// Returns list of combinations, each as Map<attributeId, value>
  static List<Map<String, String>> generateCombinations(
    Map<String, List<String>> attributeValues,
  ) {
    if (attributeValues.isEmpty) return [];

    final attributeIds = attributeValues.keys.toList();
    final valueLists = attributeIds.map((id) => attributeValues[id]!).toList();

    return _cartesianProduct(valueLists, attributeIds);
  }

  static List<Map<String, String>> _cartesianProduct(
    List<List<String>> lists,
    List<String> keys,
  ) {
    if (lists.isEmpty) return [];
    if (lists.length == 1) {
      return lists[0].map((value) => {keys[0]: value}).toList();
    }

    final result = <Map<String, String>>[];
    final restProduct = _cartesianProduct(lists.sublist(1), keys.sublist(1));

    for (final value in lists[0]) {
      for (final combination in restProduct) {
        result.add({keys[0]: value, ...combination});
      }
    }

    return result;
  }

  /// Generates human-readable name from combination
  /// Values can be in "value|label" format - uses label for name
  /// Example: {color: '#FF0000|قرمز', size: 'M|متوسط'} => "قرمز - متوسط"
  static String generateVariantName(Map<String, String> combination) {
    return combination.values.map((v) {
      // Extract label from "value|label" format
      if (v.contains('|')) {
        return v.split('|').last;
      }
      return v;
    }).join(' - ');
  }

  /// Generates SKU suffix from combination
  /// Uses value part (before |) for SKU
  /// Example: {color: '#FF0000|قرمز', size: 'M|متوسط'} => "FF0000-M"
  static String generateSKUSuffix(Map<String, String> combination) {
    return combination.values
        .map((v) {
          // Extract value from "value|label" format
          final value = v.contains('|') ? v.split('|').first : v;
          return value.toUpperCase()
              .replaceAll('#', '')
              .replaceAll(' ', '-')
              .replaceAll('_', '-');
        })
        .join('-');
  }
}
