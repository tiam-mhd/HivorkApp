class ProductStats {
  final int total;
  final int active;
  final int inactive;
  final int outOfStock;
  final int lowStock;
  final double totalInventoryValue;

  ProductStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.outOfStock,
    required this.lowStock,
    required this.totalInventoryValue,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      outOfStock: json['outOfStock'] ?? 0,
      lowStock: json['lowStock'] ?? 0,
      totalInventoryValue: _parseDouble(json['totalInventoryValue']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'outOfStock': outOfStock,
      'lowStock': lowStock,
      'totalInventoryValue': totalInventoryValue,
    };
  }
}
