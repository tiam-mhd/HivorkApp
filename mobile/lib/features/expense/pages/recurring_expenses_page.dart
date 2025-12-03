import 'package:flutter/material.dart';
import 'package:hivork_app/features/expense/models/expense.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../models/recurring_expense.dart';
import '../providers/recurring_expense_provider.dart';
import 'recurring_expense_form_page.dart';

class RecurringExpensesPage extends StatefulWidget {
  final String businessId;

  const RecurringExpensesPage({super.key, required this.businessId});

  @override
  State<RecurringExpensesPage> createState() => _RecurringExpensesPageState();
}

class _RecurringExpensesPageState extends State<RecurringExpensesPage> {
  String _filterStatus = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<RecurringExpenseProvider>().fetchRecurringExpenses(
          widget.businessId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هزینه‌های تکراری'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('همه'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('فعال'),
              ),
              const PopupMenuItem(
                value: 'inactive',
                child: Text('غیرفعال'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<RecurringExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            final isAuthError = provider.error!.contains('احراز هویت') || 
                                provider.error!.contains('Authentication');
            
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAuthError ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAuthError ? 'خطای احراز هویت' : 'خطا در دریافت اطلاعات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (isAuthError)
                      FilledButton.icon(
                        onPressed: () {
                          // Navigate to login
                          context.go('/phone-entry');
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('ورود مجدد'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('تلاش مجدد'),
                      ),
                  ],
                ),
              ),
            );
          }

          final expenses = _getFilteredExpenses(provider);

          if (expenses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: Column(
              children: [
                _buildSummaryCard(provider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return _buildExpenseCard(expenses[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecurringExpenseFormPage(
                businessId: widget.businessId,
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('هزینه تکراری جدید'),
      ),
    );
  }

  List<RecurringExpense> _getFilteredExpenses(
    RecurringExpenseProvider provider,
  ) {
    switch (_filterStatus) {
      case 'active':
        return provider.activeRecurringExpenses;
      case 'inactive':
        return provider.inactiveRecurringExpenses;
      default:
        return provider.recurringExpenses;
    }
  }

  Widget _buildSummaryCard(RecurringExpenseProvider provider) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Formatters.formatNumber(provider.totalCount),
            'کل',
            Icons.layers_rounded,
          ),
          _buildSummaryDivider(),
          _buildSummaryItem(
            Formatters.formatNumber(provider.activeCount),
            'فعال',
            Icons.check_circle_outline_rounded,
          ),
          _buildSummaryDivider(),
          _buildSummaryItem(
            Formatters.formatCurrency(provider.totalMonthlyAmount),
            'ماهانه',
            Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(RecurringExpense expense) {
    final theme = Theme.of(context);
    final nextDate = expense.nextOccurrence;
    final isOverdue = nextDate.isBefore(DateTime.now());
    final categoryColor = expense.category != null && expense.category!['color'] != null
        ? _parseColor(expense.category!['color'])
        : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showExpenseDetails(expense),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color Indicator
              Container(
                width: 3,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      expense.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Frequency & Next Date
                    Row(
                      children: [
                        Icon(
                          isOverdue ? Icons.warning_amber : Icons.schedule,
                          size: 14,
                          color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${expense.frequency.persianLabel} • ${_formatDate(nextDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(expense.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: expense.isActive
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expense.isActive ? 'فعال' : 'غیرفعال',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: expense.isActive
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // Actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurfaceVariant),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          expense.isActive ? Icons.pause : Icons.play_arrow,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(expense.isActive ? 'غیرفعال کردن' : 'فعال کردن'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        const Text('ویرایش'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: theme.colorScheme.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      _toggleActive(expense);
                      break;
                    case 'edit':
                      _editExpense(expense);
                      break;
                    case 'delete':
                      _deleteExpense(expense);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return Theme.of(context).colorScheme.primary;
    
    try {
      if (colorValue is String) {
        final hexColor = colorValue.replaceAll('#', '');
        return Color(int.parse('FF$hexColor', radix: 16));
      }
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.primary;
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.repeat_rounded,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'هزینه تکراری ندارید',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'برای افزودن هزینه تکراری جدید از دکمه زیر استفاده کنید',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff < 0) {
      return 'معوقه';
    } else if (diff == 0) {
      return 'امروز';
    } else if (diff == 1) {
      return 'فردا';
    } else if (diff <= 7) {
      return '$diff روز دیگر';
    } else if (diff > 7 && diff <= 30) {
      return '${Formatters.formatNumber(int.parse((diff/7).toStringAsFixed(0)))} هفته بعد';
    } else if (diff > 30 && diff <= 60) {
      return 'ماه بعد';
    } else if (diff > 60 && diff <= 365) {
      return '${Formatters.formatNumber(int.parse((diff/30).toStringAsFixed(0)))} ماه بعد';
    } else{
      return '${Formatters.formatNumber(int.parse((diff/365).toStringAsFixed(0)))} سال بعد';
    }
  }

  void _showExpenseDetails(RecurringExpense expense) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildDetailsSheet(expense, scrollController);
        },
      ),
    );
  }

  Widget _buildDetailsSheet(
    RecurringExpense expense,
    ScrollController scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (expense.description != null && expense.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              expense.description!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildDetailRow(
            'مبلغ',
            Formatters.formatCurrency(expense.amount),
            Icons.attach_money,
          ),
          _buildDetailRow(
            'دوره تکرار',
            expense.frequencyDescription,
            Icons.repeat,
          ),
          _buildDetailRow(
            'تاریخ شروع',
            Formatters.formatPersianDate(expense.startDate),
            Icons.play_circle,
          ),
          if (expense.hasEndDate)
            _buildDetailRow(
              'تاریخ پایان',
              Formatters.formatPersianDate(expense.endDate!),
              Icons.stop_circle,
            ),
          _buildDetailRow(
            'تاریخ بعدی',
            Formatters.formatPersianDate(expense.nextOccurrence),
            Icons.calendar_today,
          ),
          _buildDetailRow(
            'روش پرداخت',
            PaymentMethod.fromString(expense.paymentMethod).label,
            Icons.payment,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _skipNext(expense);
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('رد شدن از نوبت بعد'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showUpcoming(expense);
                  },
                  icon: const Icon(Icons.calendar_view_week),
                  label: const Text('مشاهده آینده'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(RecurringExpense expense) async {
    try {
      await context.read<RecurringExpenseProvider>().toggleActive(
            id: expense.id,
            businessId: widget.businessId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            expense.isActive
                ? 'هزینه تکراری غیرفعال شد'
                : 'هزینه تکراری فعال شد',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: ${e.toString()}')),
      );
    }
  }

  Future<void> _editExpense(RecurringExpense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecurringExpenseFormPage(
          businessId: widget.businessId,
          expense: expense,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteExpense(RecurringExpense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف هزینه تکراری'),
        content: Text('آیا از حذف "${expense.title}" اطمینان دارید?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<RecurringExpenseProvider>().deleteRecurringExpense(
            id: expense.id,
            businessId: widget.businessId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هزینه تکراری حذف شد')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: ${e.toString()}')),
      );
    }
  }

  Future<void> _skipNext(RecurringExpense expense) async {
    try {
      await context.read<RecurringExpenseProvider>().skipNextOccurrence(
            id: expense.id,
            businessId: widget.businessId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نوبت بعدی رد شد')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: ${e.toString()}')),
      );
    }
  }

  Future<void> _showUpcoming(RecurringExpense expense) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تاریخ‌های آینده'),
        content: FutureBuilder(
          future: context
              .read<RecurringExpenseProvider>()
              .fetchUpcomingOccurrences(
                id: expense.id,
                businessId: widget.businessId,
                count: 10,
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final provider = context.watch<RecurringExpenseProvider>();
            final dates = provider.upcomingOccurrences;

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      Formatters.formatPersianDate(dates[index]),
                    ),
                    subtitle: Text(_formatDate(dates[index])),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}
