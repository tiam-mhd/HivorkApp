import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../providers/expense_provider.dart';

class BudgetOverviewPage extends StatefulWidget {
  final String businessId;

  const BudgetOverviewPage({super.key, required this.businessId});

  @override
  State<BudgetOverviewPage> createState() => _BudgetOverviewPageState();
}

class _BudgetOverviewPageState extends State<BudgetOverviewPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBudgetStatus();
    });
  }

  void _loadBudgetStatus() {
    context.read<ExpenseProvider>().loadBudgetStatus(
          widget.businessId,
          year: _selectedDate.year,
          month: _selectedDate.month,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('وضعیت بودجه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadBudgetStatus,
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.budgetStatus.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.budgetStatus.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'خطا در دریافت اطلاعات',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadBudgetStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadBudgetStatus(),
            child: CustomScrollView(
              slivers: [
                // Month Selector
                SliverToBoxAdapter(
                  child: _buildMonthSelector(theme),
                ),

                // Summary Card
                if (provider.budgetStatus.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSummaryCard(provider, theme),
                  ),

                // Budget List
                if (provider.budgetStatus.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(theme),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final budget = provider.budgetStatus[index];
                          return _buildBudgetCard(budget, theme);
                        },
                        childCount: provider.budgetStatus.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
              _loadBudgetStatus();
            },
          ),
          Text(
            _getMonthYearLabel(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _selectedDate.month == DateTime.now().month &&
                    _selectedDate.year == DateTime.now().year
                ? null
                : () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                    _loadBudgetStatus();
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseProvider provider, ThemeData theme) {
    final totalBudget = provider.budgetStatus.fold<double>(
      0,
      (sum, b) => sum + (b['budget'] as num).toDouble(),
    );
    final totalSpent = provider.budgetStatus.fold<double>(
      0,
      (sum, b) => sum + (b['spent'] as num).toDouble(),
    );
    final totalRemaining = totalBudget - totalSpent;
    final overallPercentage =
        totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

    Color progressColor;
    if (overallPercentage >= 100) {
      progressColor = theme.colorScheme.error;
    } else if (overallPercentage >= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خلاصه بودجه',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'بودجه کل',
                    Formatters.formatCurrency(totalBudget),
                    Icons.account_balance_wallet_outlined,
                    theme.colorScheme.primary,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'هزینه شده',
                    Formatters.formatCurrency(totalSpent),
                    Icons.payments_outlined,
                    progressColor,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'باقیمانده',
                    Formatters.formatCurrency(totalRemaining),
                    Icons.savings_outlined,
                    totalRemaining >= 0 ? Colors.green : theme.colorScheme.error,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'درصد مصرف',
                    '${overallPercentage.toStringAsFixed(1)}%',
                    Icons.pie_chart_outline,
                    progressColor,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (overallPercentage / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget, ThemeData theme) {
    final categoryName = budget['categoryName'] as String;
    final budgetAmount = (budget['budget'] as num).toDouble();
    final spent = (budget['spent'] as num).toDouble();
    final remaining = (budget['remaining'] as num).toDouble();
    final percentage = (budget['percentage'] as num).toDouble();
    final status = budget['status'] as String;
    final colorHex = budget['categoryColor'] as String?;

    Color categoryColor = theme.colorScheme.primary;
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        categoryColor = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Use default if parsing fails
      }
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'exceeded':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.error_rounded;
        statusText = 'تجاوز از بودجه';
        break;
      case 'danger':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_rounded;
        statusText = 'نزدیک به حد مجاز';
        break;
      case 'warning':
        statusColor = Colors.amber;
        statusIcon = Icons.info_rounded;
        statusText = 'هشدار';
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'در محدوده';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'مصرف شده',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بودجه',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(budgetAmount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هزینه شده',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(spent),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'باقیمانده',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(remaining),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: remaining >= 0
                              ? Colors.green
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'بودجه‌ای تعریف نشده',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'برای دسته‌بندی‌های هزینه خود بودجه ماهانه تعیین کنید',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to categories page
                context.push('/expenses/categories', extra: widget.businessId);
              },
              icon: const Icon(Icons.category_outlined),
              label: const Text('مدیریت دسته‌بندی‌ها'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthYearLabel() {
    // For now using Gregorian month names
    const gregorianMonths = [
      'ژانویه',
      'فوریه',
      'مارس',
      'آوریل',
      'می',
      'ژوئن',
      'ژوئیه',
      'اوت',
      'سپتامبر',
      'اکتبر',
      'نوامبر',
      'دسامبر',
    ];

    return '${gregorianMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
  }
}
