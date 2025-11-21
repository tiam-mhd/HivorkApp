import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/attribute_variant_theme.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_variant.dart';
import '../../data/services/variant_api_service.dart';

enum StockSortBy {
  stockAsc,
  stockDesc,
  skuAsc,
  skuDesc,
  productName,
}

extension StockSortByX on StockSortBy {
  String get displayName {
    switch (this) {
      case StockSortBy.stockAsc:
        return 'موجودی (کم به زیاد)';
      case StockSortBy.stockDesc:
        return 'موجودی (زیاد به کم)';
      case StockSortBy.skuAsc:
        return 'SKU (الفبا)';
      case StockSortBy.skuDesc:
        return 'SKU (معکوس)';
      case StockSortBy.productName:
        return 'نام محصول';
    }
  }

  IconData get icon {
    switch (this) {
      case StockSortBy.stockAsc:
      case StockSortBy.stockDesc:
        return Icons.trending_up;
      case StockSortBy.skuAsc:
      case StockSortBy.skuDesc:
        return Icons.sort_by_alpha;
      case StockSortBy.productName:
        return Icons.label;
    }
  }
}

class StockReportScreen extends StatefulWidget {
  final String businessId;

  const StockReportScreen({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen>
    with SingleTickerProviderStateMixin {
  late VariantApiService _variantService;
  late TabController _tabController;

  List<ProductVariant> _allVariants = [];
  List<ProductVariant> _filteredVariants = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  VariantStatus? _filterStatus;
  bool? _filterLowStock;
  StockSortBy _sortBy = StockSortBy.stockDesc;

  // Stats
  int _totalVariants = 0;
  int _lowStockCount = 0;
  int _outOfStockCount = 0;
  double _totalStockValue = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final dio = ServiceLocator().dio;
    _variantService = VariantApiService(dio);
    _loadVariants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVariants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all variants for the business
      // Note: این API باید در backend اضافه شود
      // TODO: Add API method to get all variants for business
      // For now, get low stock variants with high limit
      final variants = await _variantService.getLowStockVariants(
        businessId: widget.businessId,
        limit: 1000,
      );

      setState(() {
        _allVariants = variants;
        _calculateStats();
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateStats() {
    _totalVariants = _allVariants.length;
    _lowStockCount = _allVariants
        .where((v) => v.status == VariantStatus.lowStock)
        .length;
    _outOfStockCount = _allVariants
        .where((v) => v.status == VariantStatus.outOfStock)
        .length;
    _totalStockValue = _allVariants.fold(
      0,
      (sum, v) => sum + (v.currentStock * (v.salePrice ?? 0)),
    );
  }

  void _applyFiltersAndSort() {
    _filteredVariants = _allVariants.where((variant) {
      // Search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!variant.sku.toLowerCase().contains(query) &&
            !(variant.name?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Status filter
      if (_filterStatus != null && variant.status != _filterStatus) {
        return false;
      }

      // Low stock filter
      if (_filterLowStock == true && variant.status != VariantStatus.lowStock) {
        return false;
      }
      if (_filterLowStock == false &&
          variant.status == VariantStatus.lowStock) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case StockSortBy.stockAsc:
        _filteredVariants.sort((a, b) => a.currentStock.compareTo(b.currentStock));
        break;
      case StockSortBy.stockDesc:
        _filteredVariants.sort((a, b) => b.currentStock.compareTo(a.currentStock));
        break;
      case StockSortBy.skuAsc:
        _filteredVariants.sort((a, b) => a.sku.compareTo(b.sku));
        break;
      case StockSortBy.skuDesc:
        _filteredVariants.sort((a, b) => b.sku.compareTo(a.sku));
        break;
      case StockSortBy.productName:
        _filteredVariants.sort((a, b) =>
            (a.name ?? '').compareTo(b.name ?? ''));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارش موجودی'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'لیست'),
            Tab(icon: Icon(Icons.bar_chart), text: 'نمودار'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<StockSortBy>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _applyFiltersAndSort();
              });
            },
            itemBuilder: (context) => StockSortBy.values
                .map((sort) => PopupMenuItem(
                      value: sort,
                      child: Row(
                        children: [
                          Icon(sort.icon, size: 20),
                          const SizedBox(width: 12),
                          Text(sort.displayName),
                          if (_sortBy == sort) ...[
                            const Spacer(),
                            Icon(Icons.check, color: theme.primaryColor),
                          ],
                        ],
                      ),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToExcel,
            tooltip: 'خروجی Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsSection(),

          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو (SKU، نام محصول)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFiltersAndSort();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFiltersAndSort();
                });
              },
            ),
          ),

          // Active filters
          if (_filterStatus != null || _filterLowStock != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_filterStatus != null)
                    Chip(
                      label: Text(_filterStatus!.displayName),
                      onDeleted: () {
                        setState(() {
                          _filterStatus = null;
                          _applyFiltersAndSort();
                        });
                      },
                    ),
                  if (_filterLowStock != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_filterLowStock! ? 'موجودی کم' : 'موجودی کافی'),
                      onDeleted: () {
                        setState(() {
                          _filterLowStock = null;
                          _applyFiltersAndSort();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(),
                _buildChartView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'کل ترکیبات',
              value: _totalVariants.toString(),
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'موجودی کم',
              value: _lowStockCount.toString(),
              icon: Icons.warning_amber,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'ناموجود',
              value: _outOfStockCount.toString(),
              icon: Icons.block,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.textSecondary),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVariants,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (_filteredVariants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: context.textSecondary),
            const SizedBox(height: 16),
            const Text('موردی یافت نشد'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVariants.length,
      itemBuilder: (context, index) {
        final variant = _filteredVariants[index];
        return _StockListItem(variant: variant);
      },
    );
  }

  Widget _buildChartView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredVariants.isEmpty) {
      return const Center(child: Text('داده‌ای برای نمایش نیست'));
    }

    final statusCounts = <VariantStatus, int>{};
    for (final variant in _filteredVariants) {
      statusCounts[variant.status] = (statusCounts[variant.status] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie Chart: Status Distribution
          Text(
            'توزیع وضعیت',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: statusCounts.entries.map((entry) {
                  final color = AttributeVariantTheme.getStatusColor(
                    entry.key,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  );
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.value}\n${entry.key.displayName}',
                    color: color,
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Bar Chart: Top 10 by stock
          Text(
            'بیشترین موجودی (10 مورد)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: _filteredVariants
                    .take(10)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.currentStock,
                        color: Theme.of(context).primaryColor,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _filteredVariants.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _filteredVariants[value.toInt()].sku,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        initialStatus: _filterStatus,
        initialLowStock: _filterLowStock,
        onApply: (status, lowStock) {
          setState(() {
            _filterStatus = status;
            _filterLowStock = lowStock;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _exportToExcel() {
    // TODO: Implement Excel export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خروجی Excel در نسخه بعد اضافه خواهد شد')),
    );
  }
}

// ============================================
// STAT CARD
// ============================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// STOCK LIST ITEM
// ============================================

class _StockListItem extends StatelessWidget {
  final ProductVariant variant;

  const _StockListItem({required this.variant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.sku,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (variant.name != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          variant.name!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AttributeVariantTheme.statusBadge(variant.status, context),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'موجودی فعلی',
                    value: variant.currentStock.toStringAsFixed(0),
                    icon: Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'حداقل موجودی',
                    value: variant.minStock.toStringAsFixed(0),
                    icon: Icons.warning_amber,
                  ),
                ),
                if (variant.salePrice != null)
                  Expanded(
                    child: _InfoItem(
                      label: 'قیمت',
                      value: '${variant.salePrice!.toStringAsFixed(0)} تومان',
                      icon: Icons.sell,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: context.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

// ============================================
// FILTER DIALOG
// ============================================

class _FilterDialog extends StatefulWidget {
  final VariantStatus? initialStatus;
  final bool? initialLowStock;
  final Function(VariantStatus?, bool?) onApply;

  const _FilterDialog({
    required this.initialStatus,
    required this.initialLowStock,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  VariantStatus? _status;
  bool? _lowStock;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _lowStock = widget.initialLowStock;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('فیلترها'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('وضعیت:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('همه'),
                  selected: _status == null,
                  onSelected: (selected) {
                    setState(() => _status = null);
                  },
                ),
                ...VariantStatus.values.map((status) {
                  return ChoiceChip(
                    label: Text(status.displayName),
                    selected: _status == status,
                    onSelected: (selected) {
                      setState(() => _status = selected ? status : null);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            const Text('موجودی:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('همه'),
                  selected: _lowStock == null,
                  onSelected: (selected) {
                    setState(() => _lowStock = null);
                  },
                ),
                ChoiceChip(
                  label: const Text('موجودی کم'),
                  selected: _lowStock == true,
                  onSelected: (selected) {
                    setState(() => _lowStock = selected ? true : null);
                  },
                ),
                ChoiceChip(
                  label: const Text('موجودی کافی'),
                  selected: _lowStock == false,
                  onSelected: (selected) {
                    setState(() => _lowStock = selected ? false : null);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _status = null;
              _lowStock = null;
            });
          },
          child: const Text('پاک کردن'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_status, _lowStock);
            Navigator.pop(context);
          },
          child: const Text('اعمال'),
        ),
      ],
    );
  }
}
