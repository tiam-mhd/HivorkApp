import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/enums/purchase_order_enums.dart';
import '../../data/providers/purchase_order_provider.dart';

class PurchaseOrderFilterBottomSheet extends StatefulWidget {
  const PurchaseOrderFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<PurchaseOrderFilterBottomSheet> createState() =>
      _PurchaseOrderFilterBottomSheetState();
}

class _PurchaseOrderFilterBottomSheetState
    extends State<PurchaseOrderFilterBottomSheet> {
  late PurchaseOrderStatus? _selectedStatus;
  late PurchaseOrderType? _selectedType;
  DateTimeRange? _selectedDateRange;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<PurchaseOrderProvider>();
    _selectedStatus = provider.filterStatus;
    _selectedType = provider.filterType;
    _selectedDateRange = provider.filterStartDate != null &&
            provider.filterEndDate != null
        ? DateTimeRange(
            start: provider.filterStartDate!,
            end: provider.filterEndDate!,
          )
        : null;

    if (provider.filterMinAmount != null) {
      _minAmountController.text = provider.filterMinAmount.toString();
    }
    if (provider.filterMaxAmount != null) {
      _maxAmountController.text = provider.filterMaxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'فیلتر سفارش‌ها',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('پاک کردن همه'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Filter
          Text(
            'وضعیت',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('همه', null),
              ...PurchaseOrderStatus.values.map(
                (status) => _buildStatusChip(status.label, status),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type Filter
          Text(
            'نوع سفارش',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('همه', null),
              ...PurchaseOrderType.values.map(
                (type) => _buildTypeChip(type.label, type),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range Filter
          Text(
            'بازه تاریخ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              _selectedDateRange != null
                  ? 'از ${_formatDate(_selectedDateRange!.start)} تا ${_formatDate(_selectedDateRange!.end)}'
                  : 'انتخاب بازه تاریخ',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
            ),
          ),
          const SizedBox(height: 16),

          // Amount Range Filter
          Text(
            'بازه مبلغ (ریال)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'حداقل',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'حداکثر',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Button
          FilledButton(
            onPressed: _applyFilters,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('اعمال فیلتر'),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, PurchaseOrderStatus? status) {
    final isSelected = _selectedStatus == status;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildTypeChip(String label, PurchaseOrderType? type) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      selectedColor: theme.colorScheme.secondaryContainer,
      checkmarkColor: theme.colorScheme.onSecondaryContainer,
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      locale: const Locale('fa'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _selectedDateRange = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _applyFilters() {
    final provider = context.read<PurchaseOrderProvider>();

    // Apply status filter
    provider.setStatusFilter(_selectedStatus);

    // Apply type filter
    provider.setTypeFilter(_selectedType);

    // Apply date range filter
    if (_selectedDateRange != null) {
      provider.setDateRangeFilter(
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );
    } else {
      provider.setDateRangeFilter(null, null);
    }

    // Apply amount range filter
    final minAmount = double.tryParse(_minAmountController.text);
    final maxAmount = double.tryParse(_maxAmountController.text);
    provider.setAmountRangeFilter(minAmount, maxAmount);

    Navigator.pop(context);
  }
}
