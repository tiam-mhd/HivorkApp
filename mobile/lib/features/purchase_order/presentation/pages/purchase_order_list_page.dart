import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/purchase_order_provider.dart';
import '../../data/models/purchase_order_model.dart';
import '../widgets/purchase_order_card.dart';
import '../widgets/purchase_order_filter_bottom_sheet.dart';

class PurchaseOrderListPage extends StatefulWidget {
  final String businessId;

  const PurchaseOrderListPage({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  State<PurchaseOrderListPage> createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchaseOrders();
      _loadStats();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMorePurchaseOrders();
    }
  }

  Future<void> _loadPurchaseOrders() async {
    if (widget.businessId.isEmpty) return;

    final provider = context.read<PurchaseOrderProvider>();
    await provider.loadPurchaseOrders(widget.businessId, page: 1);

    if (mounted) {
      setState(() {
        _currentPage = 1;
        final pagination = provider.pagination;
        _hasMore = pagination != null &&
            pagination.page < pagination.totalPages;
      });
    }
  }

  Future<void> _loadMorePurchaseOrders() async {
    if (_isLoadingMore || widget.businessId.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    final provider = context.read<PurchaseOrderProvider>();
    final nextPage = _currentPage + 1;

    await provider.loadPurchaseOrders(widget.businessId, page: nextPage);

    if (mounted) {
      setState(() {
        _currentPage = nextPage;
        final pagination = provider.pagination;
        _hasMore = pagination != null &&
            pagination.page < pagination.totalPages;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadStats() async {
    if (widget.businessId.isEmpty) return;
    final provider = context.read<PurchaseOrderProvider>();
    await provider.loadStats(widget.businessId);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('جستجوی سفارش'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'شماره سفارش یا نام تامین‌کننده',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.pop(context);
              _applySearch(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applySearch(_searchController.text);
              },
              child: const Text('جستجو'),
            ),
          ],
        );
      },
    );
  }

  void _applySearch(String query) {
    final provider = context.read<PurchaseOrderProvider>();
    provider.setSearchQuery(query.isEmpty ? null : query);
    _loadPurchaseOrders();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PurchaseOrderFilterBottomSheet(),
    ).then((_) {
      // Reload after filter applied
      _loadPurchaseOrders();
    });
  }

  void _navigateToCreatePage() {
    context.go(
      '/purchase-order/create',
      extra: widget.businessId,
    );
  }

  void _navigateToDetailPage(PurchaseOrderModel purchaseOrder) {
    context.go(
      '/purchase-order/${purchaseOrder.id}',
      extra: {'businessId': widget.businessId},
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.businessId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('سفارشات خرید'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'شناسه کسب‌وکار موجود نیست',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'لطفاً ابتدا کسب‌وکار را انتخاب کنید',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('بازگشت'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('سفارشات خرید'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStatsDialog(),
          ),
        ],
      ),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, child) {
          // Error State
          if (provider.error != null && provider.purchaseOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadPurchaseOrders,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          // Loading State (first load)
          if (provider.isLoading && provider.purchaseOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty State
          if (provider.purchaseOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.hasActiveFilters
                        ? 'سفارشی با این فیلترها یافت نشد'
                        : 'هنوز سفارش خریدی ثبت نشده',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.hasActiveFilters
                        ? 'فیلترهای خود را تغییر دهید'
                        : 'اولین سفارش خرید خود را ثبت کنید',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  if (provider.hasActiveFilters)
                    OutlinedButton.icon(
                      onPressed: () {
                        provider.clearFilters();
                        _loadPurchaseOrders();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('حذف فیلترها'),
                    ),
                ],
              ),
            );
          }

          // List with Data
          return Column(
            children: [
              // Active Filters Chip
              if (provider.hasActiveFilters)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: theme.colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 20,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'فیلترها فعال',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          _loadPurchaseOrders();
                        },
                        child: const Text('حذف همه'),
                      ),
                    ],
                  ),
                ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadPurchaseOrders,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.purchaseOrders.length +
                        (_hasMore || _isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.purchaseOrders.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final purchaseOrder = provider.purchaseOrders[index];
                      return PurchaseOrderCard(
                        purchaseOrder: purchaseOrder,
                        onTap: () => _navigateToDetailPage(purchaseOrder),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePage,
        icon: const Icon(Icons.add),
        label: const Text('سفارش جدید'),
      ),
    );
  }

  void _showStatsDialog() {
    final provider = context.read<PurchaseOrderProvider>();
    final stats = provider.stats;

    if (stats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('آماری یافت نشد')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final numberFormat = NumberFormat('#,##0', 'fa');
        final currencyFormat = NumberFormat('#,##0', 'fa');

        return AlertDialog(
          title: const Text('آمار سفارشات خرید'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('تعداد کل سفارشات:',
                    numberFormat.format(stats.totalOrders), theme),
                const Divider(),
                const Text(
                  'تفکیک وضعیت:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStatRow('پیش‌نویس:',
                    numberFormat.format(stats.byStatus.draft), theme),
                _buildStatRow('در انتظار تایید:',
                    numberFormat.format(stats.byStatus.pending), theme),
                _buildStatRow('تایید شده:',
                    numberFormat.format(stats.byStatus.approved), theme),
                _buildStatRow('ارسال شده:',
                    numberFormat.format(stats.byStatus.sent), theme),
                _buildStatRow('تایید تامین‌کننده:',
                    numberFormat.format(stats.byStatus.confirmed), theme),
                _buildStatRow('دریافت جزئی:',
                    numberFormat.format(stats.byStatus.partiallyReceived), theme),
                _buildStatRow('دریافت کامل:',
                    numberFormat.format(stats.byStatus.received), theme),
                _buildStatRow(
                    'لغو شده:', numberFormat.format(stats.byStatus.cancelled), theme),
                _buildStatRow(
                    'بسته شده:', numberFormat.format(stats.byStatus.closed), theme),
                const Divider(),
                _buildStatRow('مجموع ارزش:',
                    '${currencyFormat.format(double.tryParse(stats.totalAmount) ?? 0)} ریال', theme),
                _buildStatRow('پرداخت شده:',
                    '${currencyFormat.format(double.tryParse(stats.totalPaid) ?? 0)} ریال', theme),
                _buildStatRow('باقیمانده:',
                    '${currencyFormat.format(double.tryParse(stats.totalRemaining) ?? 0)} ریال', theme),
                const Divider(),
                _buildStatRow(
                    'تعداد آیتم‌ها:', numberFormat.format(stats.totalItems), theme),
                _buildStatRow('تعداد کل واحدها:',
                    numberFormat.format(double.tryParse(stats.totalQuantity) ?? 0), theme),
                _buildStatRow('دریافت شده:',
                    numberFormat.format(double.tryParse(stats.receivedQuantity) ?? 0), theme),
                const Divider(),
                _buildStatRow('تامین‌کنندگان فعال:',
                    numberFormat.format(stats.activeSuppliers), theme),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بستن'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
