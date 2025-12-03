import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../models/models.dart';
import '../providers/expense_provider.dart';
import 'expense_form_page.dart';
import 'expense_stats_page.dart';
import 'budget_overview_page.dart';
import 'expense_attachments_page.dart';
import 'expense_analytics_page.dart';

class ExpensesPage extends StatefulWidget {
  final String businessId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const ExpensesPage({
    super.key,
    required this.businessId,
    this.scaffoldKey,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.loadExpenses(widget.businessId);
    expenseProvider.loadCategories(widget.businessId);
  }

  void _applyFilters() {
    context.read<ExpenseProvider>().loadExpenses(widget.businessId);
  }

  void _showFilterSheet(BuildContext context) {
    // TODO: Implement filter sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فیلترها به زودی اضافه می‌شود')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () {
            widget.scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.attach_money,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'هزینه‌ها',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetOverviewPage(businessId: widget.businessId),
                ),
              );
            },
            tooltip: 'بودجه',
          ),
          IconButton(
            icon: Icon(Icons.category_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {
              context.push('/expense-categories?businessId=${widget.businessId}');
            },
            tooltip: 'دسته‌بندی‌ها',
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
            onPressed: () {
              _showFilterSheet(context);
            },
            tooltip: 'فیلتر',
          ),
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseAnalyticsPage(businessId: widget.businessId),
                ),
              );
            },
            tooltip: 'تحلیل‌ها',
          ),
          IconButton(
            icon: Icon(Icons.insert_chart, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseStatsPage(businessId: widget.businessId),
                ),
              );
            },
            tooltip: 'آمار',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildRecurringExpensesCard(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildExpenseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormPage(businessId: widget.businessId),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('هزینه جدید'),
      ),
    );
  }

  Widget _buildRecurringExpensesCard() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/expenses/recurring', extra: widget.businessId);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.repeat_rounded,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هزینه‌های تکراری',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مدیریت هزینه‌های دوره‌ای و خودکار',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'جستجو در هزینه‌ها...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ExpenseProvider>().setSearchQuery(null);
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          context.read<ExpenseProvider>().setSearchQuery(value.isEmpty ? null : value);
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (!provider.hasActiveFilters) return const SizedBox.shrink();

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (provider.selectedCategoryId != null)
                _buildFilterChip(
                  label: provider.getCategoryById(provider.selectedCategoryId!)?.name ?? 'دسته',
                  onDeleted: () {
                    provider.setSelectedCategory(null);
                    _applyFilters();
                  },
                ),
              if (provider.selectedPaymentMethod != null)
                _buildFilterChip(
                  label: provider.selectedPaymentMethod!,
                  onDeleted: () {
                    provider.setSelectedPaymentMethod(null);
                    _applyFilters();
                  },
                ),
              if (provider.fromDate != null || provider.toDate != null)
                _buildFilterChip(
                  label: 'بازه تاریخ',
                  onDeleted: () {
                    provider.setDateRange(null, null);
                    _applyFilters();
                  },
                ),
              if (provider.hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    provider.clearFilters();
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('پاک کردن همه'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onDeleted}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Chip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  Widget _buildExpenseList() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
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
                    isAuthError ? 'خطای احراز هویت' : 'خطا در بارگذاری هزینه‌ها',
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

        if (provider.expenses.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هیچ هزینه‌ای ثبت نشده',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('برای افزودن هزینه جدید، دکمه زیر را بزنید'),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return _buildExpenseCard(expense);
            },
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final categoryColor = expense.category?.color != null
        ? _parseColor(expense.category!.color)
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormPage(
                businessId: widget.businessId,
                expense: expense,
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.categoryName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Text(
                    Formatters.formatCurrency(expense.amount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
              if (expense.description != null && expense.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  expense.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  // Date
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy/MM/dd').format(expense.expenseDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  // Payment method
                  if (expense.paymentMethod != null) ...[
                    Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      expense.paymentMethodLabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  const Spacer(),
                  // Status badge
                  _buildStatusBadge(expense.paymentStatus),
                ],
              ),
              // Tags
              if (expense.tags != null && expense.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: expense.tags!.take(3).map((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 10)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              // Quick actions row
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseAttachmentsPage(
                            expenseId: expense.id,
                            expenseTitle: expense.title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: const Text('پیوست‌ها', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case PaymentStatus.paid:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case PaymentStatus.partiallyPaid:
        color = Colors.blue;
        icon = Icons.hourglass_bottom;
        break;
      case PaymentStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterDialog(
        onApply: _applyFilters,
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FilterDialog extends StatefulWidget {
  final VoidCallback onApply;

  const _FilterDialog({required this.onApply});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  String? _selectedCategoryId;
  String? _selectedPaymentMethod;
  String? _selectedPaymentStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ExpenseProvider>();
    _selectedCategoryId = provider.selectedCategoryId;
    _selectedPaymentMethod = provider.selectedPaymentMethod;
    _selectedPaymentStatus = provider.selectedPaymentStatus;
    _fromDate = provider.fromDate;
    _toDate = provider.toDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فیلترها',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _selectedPaymentMethod = null;
                    _selectedPaymentStatus = null;
                    _fromDate = null;
                    _toDate = null;
                  });
                },
                child: const Text('پاک کردن'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Category filter
          const Text('دسته‌بندی', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              return DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'انتخاب دسته‌بندی',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('همه')),
                  ...provider.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Payment method filter
          const Text('روش پرداخت', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'انتخاب روش پرداخت',
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('همه')),
              ...PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method.value,
                  child: Text(method.label),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedPaymentMethod = value);
            },
          ),

          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final provider = context.read<ExpenseProvider>();
                    provider.setSelectedCategory(_selectedCategoryId);
                    provider.setSelectedPaymentMethod(_selectedPaymentMethod);
                    provider.setSelectedPaymentStatus(_selectedPaymentStatus);
                    provider.setDateRange(_fromDate, _toDate);
                    
                    Navigator.pop(context);
                    widget.onApply();
                  },
                  child: const Text('اعمال فیلتر'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
