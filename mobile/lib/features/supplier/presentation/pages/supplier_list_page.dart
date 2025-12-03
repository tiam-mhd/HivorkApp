import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/supplier_provider.dart';
import '../../data/models/supplier_model.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_filter_bottom_sheet.dart';
import 'supplier_form_page.dart';
import 'supplier_detail_page.dart';

class SupplierListPage extends StatefulWidget {
  final String businessId;
  final bool selectionMode; // برای حالت انتخاب تامین‌کننده در سفارش خرید
  final Supplier? selectedSupplier; // تامین‌کننده انتخاب شده قبلی

  const SupplierListPage({
    Key? key,
    required this.businessId,
    this.selectionMode = false,
    this.selectedSupplier,
  }) : super(key: key);

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
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
      _loadSuppliers();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreSuppliers();
    }
  }

  Future<void> _loadSuppliers() async {
    print('🔥 PAGE DEBUG: _loadSuppliers called, businessId = "${widget.businessId}"');
    
    if (widget.businessId.isEmpty) {
      print('❌ PAGE ERROR: businessId is empty!');
      return;
    }

    final provider = context.read<SupplierProvider>();
    print('🔥 PAGE DEBUG: Calling provider.loadSuppliers');
    await provider.loadSuppliers(widget.businessId, page: 1);
    print('🔥 PAGE DEBUG: loadSuppliers completed');
    
    setState(() {
      _currentPage = 1;
      _hasMore = provider.pagination?['hasMore'] ?? false;
    });
  }

  Future<void> _loadMoreSuppliers() async {
    if (_isLoadingMore || widget.businessId.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    final provider = context.read<SupplierProvider>();
    final nextPage = _currentPage + 1;
    
    await provider.loadSuppliers(widget.businessId, page: nextPage);
    
    setState(() {
      _currentPage = nextPage;
      _hasMore = provider.pagination?['hasMore'] ?? false;
      _isLoadingMore = false;
    });
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

    // Check if businessId is empty
    if (widget.businessId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تامین‌کنندگان'),
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
      appBar: widget.selectionMode
          ? AppBar(
              title: const Text('انتخاب تامین‌کننده'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showSearchDialog,
                ),
              ],
            )
          : AppBar(
              title: const Text('تامین‌کنندگان'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showSearchDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterBottomSheet,
                ),
              ],
            ),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          // Error State
          if (provider.error != null && provider.suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSuppliers,
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          // Loading State
          if (provider.isLoading && provider.suppliers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Empty State
          if (provider.suppliers.isEmpty) {
            return _buildEmptyState();
          }

          // List State
          return RefreshIndicator(
            onRefresh: _loadSuppliers,
            child: Column(
              children: [
                // Active Filters
                if (provider.hasActiveFilters)
                  _buildActiveFilters(provider),

                // Stats Summary
                _buildStatsSummary(provider),

                // Supplier List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.suppliers.length + 
                        (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.suppliers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final supplier = provider.suppliers[index];
                      return SupplierCard(
                        supplier: supplier,
                        onTap: () {
                          if (widget.selectionMode) {
                            Navigator.pop(context, supplier);
                          } else {
                            _viewSupplier(supplier.id);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: widget.selectionMode
          ? FloatingActionButton.extended(
              onPressed: _createSupplierAndSelect,
              icon: const Icon(Icons.add),
              label: const Text('تامین‌کننده جدید'),
            )
          : FloatingActionButton.extended(
              onPressed: _createSupplier,
              icon: const Icon(Icons.add),
              label: const Text('تامین‌کننده جدید'),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'هیچ تامین‌کننده‌ای ثبت نشده',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای شروع، یک تامین‌کننده جدید اضافه کنید',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createSupplier,
            icon: const Icon(Icons.add),
            label: const Text('افزودن تامین‌کننده'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(SupplierProvider provider) {
    final total = provider.suppliers.length;
    final active = provider.suppliers.where((s) => s.status == SupplierStatus.approved).length;
    final inactive = provider.suppliers.where((s) => s.status == SupplierStatus.suspended).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('مجموع', total.toString(), Colors.blue),
          _buildStatItem('فعال', active.toString(), Colors.green),
          _buildStatItem('غیرفعال', inactive.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters(SupplierProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (provider.searchQuery != null)
            _buildFilterChip(
              label: 'جستجو: ${provider.searchQuery}',
              onDeleted: () {
                _searchController.clear();
                provider.setSearchQuery(null);
                _loadSuppliers();
              },
            ),
          if (provider.statusFilter != null)
            _buildFilterChip(
              label: 'وضعیت: ${provider.statusFilter!.statusText}',
              onDeleted: () {
                provider.setStatusFilter(null);
                _loadSuppliers();
              },
            ),
          if (provider.typeFilter != null)
            _buildFilterChip(
              label: 'نوع: ${provider.typeFilter!.typeText}',
              onDeleted: () {
                provider.setTypeFilter(null);
                _loadSuppliers();
              },
            ),
          if (provider.cityFilter != null)
            _buildFilterChip(
              label: 'شهر: ${provider.cityFilter}',
              onDeleted: () {
                provider.setCityFilter(null);
                _loadSuppliers();
              },
            ),
          TextButton.icon(
            onPressed: () {
              provider.clearFilters();
              _searchController.clear();
              _loadSuppliers();
            },
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('پاک کردن همه'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('جستجو'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'نام، کد یا شماره تماس تامین‌کننده...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            final provider = context.read<SupplierProvider>();
            provider.setSearchQuery(value.isEmpty ? null : value);
            _loadSuppliers();
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
              final provider = context.read<SupplierProvider>();
              final query = _searchController.text;
              provider.setSearchQuery(query.isEmpty ? null : query);
              _loadSuppliers();
            },
            child: const Text('جستجو'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SupplierFilterBottomSheet(
        businessId: widget.businessId,
      ),
    );
  }

  void _createSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierFormPage(businessId: widget.businessId),
      ),
    ).then((created) {
      if (created == true) {
        _loadSuppliers();
      }
    });
  }

  void _createSupplierAndSelect() async {
    final result = await Navigator.push<Supplier>(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierFormPage(businessId: widget.businessId),
      ),
    );

    if (result != null && mounted) {
      // بازگشت با تامین‌کننده جدید
      Navigator.pop(context, result);
    }
  }

  void _editSupplier(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierFormPage(businessId: widget.businessId, supplier: supplier),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadSuppliers();
      }
    });
  }

  void _viewSupplier(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailPage(businessId: widget.businessId, supplierId: id),
      ),
    );
  }

  void _deleteSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تامین‌کننده'),
        content: Text('آیا از حذف "${supplier.name}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              if (widget.businessId.isEmpty) {
                _showErrorSnackBar('شناسه کسب‌وکار موجود نیست');
                return;
              }

              final provider = context.read<SupplierProvider>();
              final success = await provider.deleteSupplier(supplier.id, widget.businessId);

              if (success) {
                _showSuccessSnackBar('تامین‌کننده با موفقیت حذف شد');
              } else {
                _showErrorSnackBar(provider.error ?? 'خطا در حذف تامین‌کننده');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _changeSupplierStatus(Supplier supplier) {
    final newStatus = supplier.status == SupplierStatus.approved
        ? SupplierStatus.suspended
        : SupplierStatus.approved;

    showDialog(
      context: context,
      builder: (context) {
        String? reason;
        return AlertDialog(
          title: const Text('تغییر وضعیت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('وضعیت "${supplier.name}" به ${newStatus.statusText} تغییر می‌کند.'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'دلیل (اختیاری)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => reason = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                if (widget.businessId.isEmpty) {
                  _showErrorSnackBar('شناسه کسب‌وکار موجود نیست');
                  return;
                }

                final provider = context.read<SupplierProvider>();
                final success = await provider.changeSupplierStatus(
                  supplier.id,
                  widget.businessId,
                  newStatus,
                  reason,
                );

                if (success) {
                  _showSuccessSnackBar('وضعیت تامین‌کننده تغییر کرد');
                } else {
                  _showErrorSnackBar(provider.error ?? 'خطا در تغییر وضعیت');
                }
              },
              child: const Text('تایید'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
