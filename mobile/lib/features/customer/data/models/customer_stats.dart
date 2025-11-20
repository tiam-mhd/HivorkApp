class CustomerStats {
  final int total;
  final int active;
  final int inactive;
  final int blocked;
  final int withDebt;
  final int withCredit;
  final double totalDebt;
  final double totalCredit;
  final double totalSales;

  CustomerStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.blocked,
    required this.withDebt,
    required this.withCredit,
    required this.totalDebt,
    required this.totalCredit,
    required this.totalSales,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      blocked: json['blocked'] ?? 0,
      withDebt: json['withDebt'] ?? 0,
      withCredit: json['withCredit'] ?? 0,
      totalDebt: _parseDouble(json['totalDebt']),
      totalCredit: _parseDouble(json['totalCredit']),
      totalSales: _parseDouble(json['totalSales']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
