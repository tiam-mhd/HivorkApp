// Category Breakdown for Stats
class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final String color;
  final double total;
  final double percentage;

  CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.total,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      color: json['color'] as String,
      total: double.parse(json['total'].toString()),
      percentage: double.parse(json['percentage'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'color': color,
      'total': total,
      'percentage': percentage,
    };
  }
}

// Expense Statistics Model
class ExpenseStats {
  final double todayTotal;
  final double thisMonthTotal;
  final double lastMonthTotal;
  final double thisYearTotal;
  final int totalExpenses;
  final double monthlyChange;
  final List<CategoryBreakdown> categoryBreakdown;

  ExpenseStats({
    required this.todayTotal,
    required this.thisMonthTotal,
    required this.lastMonthTotal,
    required this.thisYearTotal,
    required this.totalExpenses,
    required this.monthlyChange,
    required this.categoryBreakdown,
  });

  factory ExpenseStats.fromJson(Map<String, dynamic> json) {
    return ExpenseStats(
      todayTotal: double.parse(json['todayTotal'].toString()),
      thisMonthTotal: double.parse(json['thisMonthTotal'].toString()),
      lastMonthTotal: double.parse(json['lastMonthTotal'].toString()),
      thisYearTotal: double.parse(json['thisYearTotal'].toString()),
      totalExpenses: json['totalExpenses'] as int,
      monthlyChange: double.parse(json['monthlyChange'].toString()),
      categoryBreakdown: (json['categoryBreakdown'] as List)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayTotal': todayTotal,
      'thisMonthTotal': thisMonthTotal,
      'lastMonthTotal': lastMonthTotal,
      'thisYearTotal': thisYearTotal,
      'totalExpenses': totalExpenses,
      'monthlyChange': monthlyChange,
      'categoryBreakdown': categoryBreakdown.map((e) => e.toJson()).toList(),
    };
  }

  // Helper getters
  bool get hasIncreased => monthlyChange > 0;
  bool get hasDecreased => monthlyChange < 0;
  String get monthlyChangeText {
    if (monthlyChange == 0) return 'بدون تغییر';
    final sign = monthlyChange > 0 ? '+' : '';
    return '$sign${monthlyChange.toStringAsFixed(1)}%';
  }
}
