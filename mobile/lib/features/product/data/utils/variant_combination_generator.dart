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
  /// Example: {color: 'red', size: 'M'} => "قرمز - M"
  static String generateVariantName(Map<String, String> combination) {
    return combination.values.join(' - ');
  }

  /// Generates SKU suffix from combination
  /// Example: {color: 'red', size: 'M'} => "RED-M"
  static String generateSKUSuffix(Map<String, String> combination) {
    return combination.values
        .map((v) => v.toUpperCase().replaceAll(' ', '-'))
        .join('-');
  }
}
