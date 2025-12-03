import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../../../core/utils/formatters.dart';

class ExpenseAnalyticsPage extends StatefulWidget {
  final String businessId;

  const ExpenseAnalyticsPage({
    super.key,
    required this.businessId,
  });

  @override
  State<ExpenseAnalyticsPage> createState() => _ExpenseAnalyticsPageState();
}

class _ExpenseAnalyticsPageState extends State<ExpenseAnalyticsPage> {
  String _selectedPeriod = 'month'; // month, quarter, year
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<FlSpot> _trendData = [];
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ExpenseProvider>().loadExpenses(widget.businessId);
      _calculateAnalytics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateAnalytics() {
    final provider = context.read<ExpenseProvider>();
    final expenses = provider.expenses;
    
    // محاسبه داده‌های نمودار روند
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // گروه‌بندی هزینه‌ها بر اساس روز
    Map<int, double> dailyExpenses = {};
    for (var expense in expenses) {
      if (expense.expenseDate.isAfter(startOfMonth) && 
          expense.expenseDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        final day = expense.expenseDate.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + expense.amount;
      }
    }
    
    // تبدیل به FlSpot برای نمودار
    _trendData = dailyExpenses.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    
    // محاسبه مقایسه‌های دوره‌ای
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    
    double currentMonthTotal = 0;
    double lastMonthTotal = 0;
    
    for (var expense in expenses) {
      if (expense.expenseDate.isAfter(startOfMonth)) {
        currentMonthTotal += expense.amount;
      } else if (expense.expenseDate.isAfter(lastMonthStart) && 
                 expense.expenseDate.isBefore(lastMonthEnd.add(const Duration(days: 1)))) {
        lastMonthTotal += expense.amount;
      }
    }
    
    // محاسبه هزینه‌های هفته جاری و گذشته
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = startOfWeek.subtract(const Duration(days: 7));
    final lastWeekEnd = startOfWeek.subtract(const Duration(days: 1));
    
    double currentWeekTotal = 0;
    double lastWeekTotal = 0;
    
    for (var expense in expenses) {
      if (expense.expenseDate.isAfter(startOfWeek)) {
        currentWeekTotal += expense.amount;
      } else if (expense.expenseDate.isAfter(lastWeekStart) && 
                 expense.expenseDate.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
        lastWeekTotal += expense.amount;
      }
    }
    
    // محاسبه روند دسته‌بندی‌ها
    Map<String, Map<String, dynamic>> categoryData = {};
    
    for (var expense in expenses) {
      if (expense.category == null) continue;
      
      final categoryName = expense.category!.name;
      final categoryColor = expense.category!.color ?? '#9C27B0';
      
      if (!categoryData.containsKey(categoryName)) {
        categoryData[categoryName] = {
          'name': categoryName,
          'color': categoryColor,
          'currentMonth': 0.0,
          'lastMonth': 0.0,
        };
      }
      
      if (expense.expenseDate.isAfter(startOfMonth)) {
        categoryData[categoryName]!['currentMonth'] += expense.amount;
      } else if (expense.expenseDate.isAfter(lastMonthStart) && 
                 expense.expenseDate.isBefore(lastMonthEnd.add(const Duration(days: 1)))) {
        categoryData[categoryName]!['lastMonth'] += expense.amount;
      }
    }
    
    _analytics = {
      'currentMonthTotal': currentMonthTotal,
      'lastMonthTotal': lastMonthTotal,
      'currentWeekTotal': currentWeekTotal,
      'lastWeekTotal': lastWeekTotal,
      'categoryData': categoryData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحلیل پیشرفته هزینه‌ها'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAnalytics,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 24),
                      _buildTrendChart(),
                      const SizedBox(height: 24),
                      _buildComparisonSection(),
                      const SizedBox(height: 24),
                      _buildCategoryTrends(),
                      const SizedBox(height: 24),
                      _buildInsights(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'دوره زمانی',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton('روزانه', 'day'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton('ماهانه', 'month'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton('سه ماهه', 'quarter'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton('سالانه', 'year'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedPeriod = value);
        _loadAnalytics();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildTrendChart() {
    if (_trendData.isEmpty) {
      return Card(
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'داده‌ای برای نمایش وجود ندارد',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final maxY = _trendData.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2;
    final maxX = _trendData.map((e) => e.x).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'روند هزینه‌ها',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'آذر ۱۴۰۴',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatShortCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: maxX > 15 ? 5 : 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  minX: 0,
                  maxX: maxX + 1,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _trendData,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection() {
    final currentMonthTotal = _analytics['currentMonthTotal'] ?? 0.0;
    final lastMonthTotal = _analytics['lastMonthTotal'] ?? 0.0;
    final currentWeekTotal = _analytics['currentWeekTotal'] ?? 0.0;
    final lastWeekTotal = _analytics['lastWeekTotal'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مقایسه دوره‌ای',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
              'ماه جاری',
              currentMonthTotal,
              'ماه گذشته',
              lastMonthTotal,
              isIncrease: currentMonthTotal > lastMonthTotal,
            ),
            const Divider(height: 24),
            _buildComparisonRow(
              'این هفته',
              currentWeekTotal,
              'هفته گذشته',
              lastWeekTotal,
              isIncrease: currentWeekTotal > lastWeekTotal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String period1,
    double amount1,
    String period2,
    double amount2, {
    required bool isIncrease,
  }) {
    final percentChange = amount2 > 0 
        ? ((amount1 - amount2) / amount2 * 100).abs() 
        : (amount1 > 0 ? 100.0 : 0.0);
    final color = isIncrease ? Colors.red : Colors.green;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(period1, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                Formatters.formatCurrency(amount1),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '${percentChange.toStringAsFixed(1)}٪',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(period2, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                Formatters.formatCurrency(amount2),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTrends() {
    final categoryData = _analytics['categoryData'] as Map<String, Map<String, dynamic>>? ?? {};
    
    if (categoryData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'روند دسته‌بندی‌ها',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'داده‌ای برای نمایش وجود ندارد',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // مرتب‌سازی بر اساس مبلغ ماه جاری
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => (b.value['currentMonth'] as double).compareTo(a.value['currentMonth'] as double));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'روند دسته‌بندی‌ها',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.take(5).map((entry) {
              final data = entry.value;
              final currentMonth = data['currentMonth'] as double;
              final lastMonth = data['lastMonth'] as double;
              final trend = lastMonth > 0 
                  ? ((currentMonth - lastMonth) / lastMonth * 100) 
                  : (currentMonth > 0 ? 100.0 : 0.0);
              
              Color color;
              try {
                final colorHex = data['color'] as String;
                final hexColor = colorHex.replaceAll('#', '');
                color = Color(int.parse('FF$hexColor', radix: 16));
              } catch (e) {
                color = Theme.of(context).colorScheme.primary;
              }
              
              return _buildCategoryTrendItem(
                entry.key,
                currentMonth,
                trend,
                color,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTrendItem(
    String name,
    double amount,
    double trend,
    Color color,
  ) {
    final isPositive = trend >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(amount),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (trend != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 12,
                    color: isPositive ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${trend.abs().toStringAsFixed(1)}٪',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    final categoryData = _analytics['categoryData'] as Map<String, Map<String, dynamic>>? ?? {};
    final List<Widget> insights = [];

    // تحلیل روند دسته‌بندی‌ها برای بینش‌ها
    categoryData.forEach((name, data) {
      final currentMonth = data['currentMonth'] as double;
      final lastMonth = data['lastMonth'] as double;
      
      if (lastMonth > 0) {
        final changePercent = ((currentMonth - lastMonth) / lastMonth * 100);
        
        if (changePercent.abs() > 10) {
          insights.add(
            _buildInsightItem(
              changePercent > 0 ? Icons.warning_amber : Icons.trending_down,
              'هزینه $name ${changePercent > 0 ? "${changePercent.toStringAsFixed(1)}٪ افزایش" : "${changePercent.abs().toStringAsFixed(1)}٪ کاهش"} یافته است',
              changePercent > 0 ? Colors.orange : Colors.green,
            ),
          );
        }
      }
    });

    // محاسبه میانگین روزهایی که هزینه ثبت شده
    if (_trendData.isNotEmpty) {
      final avgDay = _trendData.map((e) => e.x).reduce((a, b) => a + b) / _trendData.length;
      String period = 'اوایل ماه';
      if (avgDay > 20) {
        period = 'اواخر ماه';
      } else if (avgDay > 10) {
        period = 'اواسط ماه';
      }
      
      insights.add(
        _buildInsightItem(
          Icons.schedule,
          'بیشترین هزینه‌ها در $period ثبت می‌شوند',
          Colors.blue,
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        const Center(
          child: Text(
            'بینش خاصی یافت نشد',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'بینش‌های هوشمند',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.take(3).toList().asMap().entries.map((entry) {
              if (entry.key > 0) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    entry.value,
                  ],
                );
              }
              return entry.value;
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}م';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}ه';
    }
    return value.toStringAsFixed(0);
  }
}
