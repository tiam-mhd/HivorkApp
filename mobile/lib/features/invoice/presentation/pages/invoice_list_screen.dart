import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/invoice_provider.dart';
import '../../data/models/invoice.dart';
import '../widgets/invoice_card.dart';
import '../widgets/invoice_empty_state.dart';
import '../widgets/invoice_filter_bottom_sheet.dart';
import 'create_invoice_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // بارگذاری اولیه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InvoiceProvider>();
      // فرض بر این که businessId از جای دیگه تنظیم شده
      provider.loadInvoices(refresh: true);
    });
  }

  void _onScroll() {
    final provider = context.read<InvoiceProvider>();
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent * 0.9 &&
      !provider.isLoadingMore &&
      provider.hasMore) {
    provider.loadMore();
  }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('فاکتورها'),
        actions: [
          // جستجو
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          // فیلتر
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          // Error State
          if (provider.error != null && provider.invoices.isEmpty) {
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
                    onPressed: () => provider.loadInvoices(refresh: true),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          // Loading State (اولین بار)
          if (provider.isLoading && provider.invoices.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Empty State
          if (provider.invoices.isEmpty) {
            return InvoiceEmptyState(
              onCreatePressed: _createInvoice,
            );
          }

          // List State
          return RefreshIndicator(
            onRefresh: () => provider.loadInvoices(refresh: true),
            child: Column(
              children: [
                // فیلترهای فعال
                if (provider.searchQuery != null ||
                    provider.filterType != null ||
                    provider.filterStatus != null ||
                    provider.filterPaymentStatus != null ||
                    provider.filterShippingStatus != null)
                  _buildActiveFilters(provider),

                // لیست فاکتورها
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.invoices.length + 
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.invoices.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final invoice = provider.invoices[index];
                      // Robust id check
                      final id = invoice.id;
                      print('[InvoiceListScreen] Rendering invoice id type: \\${id.runtimeType}, value: $id');
                      if (id!.isEmpty) {
                        return ListTile(
                          leading: const Icon(Icons.error, color: Colors.red),
                          title: const Text('خطا: id فاکتور نامعتبر است'),
                          subtitle: Text('id: $id'),
                        );
                      }
                      return InvoiceCard(
                        invoice: invoice,
                        onTap: () => _viewInvoice(id),
                        onEdit: invoice.status == InvoiceStatus.draft
                            ? () => _editInvoice(id)
                            : null,
                        onDelete: invoice.status == InvoiceStatus.draft
                            ? () => _deleteInvoice(invoice)
                            : null,
                        onFinalize: invoice.status == InvoiceStatus.draft
                            ? () => _finalizeInvoice(invoice)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createInvoice,
        icon: const Icon(Icons.add),
        label: const Text('فاکتور جدید'),
      ),
    );
  }

  Widget _buildActiveFilters(InvoiceProvider provider) {
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
                provider.search('');
              },
            ),
          if (provider.filterType != null)
            _buildFilterChip(
              label: provider.filterType!.label,
              onDeleted: () => provider.applyFilters(),
            ),
          if (provider.filterStatus != null)
            _buildFilterChip(
              label: provider.filterStatus!.label,
              onDeleted: () => provider.applyFilters(),
            ),
          if (provider.filterPaymentStatus != null)
            _buildFilterChip(
              label: provider.filterPaymentStatus!.label,
              onDeleted: () => provider.applyFilters(),
            ),
          if (provider.filterShippingStatus != null)
            _buildFilterChip(
              label: provider.filterShippingStatus!.label,
              onDeleted: () => provider.applyFilters(),
            ),
          TextButton.icon(
            onPressed: () => provider.clearFilters(),
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
            hintText: 'شماره فاکتور یا نام مشتری...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            context.read<InvoiceProvider>().search(value);
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
              context.read<InvoiceProvider>().search(_searchController.text);
            },
            child: const Text('جستجو'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const InvoiceFilterBottomSheet(),
    );
  }

  void _createInvoice() {
    final provider = context.read<InvoiceProvider>();
    
    // Navigate to create invoice screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInvoiceScreen(
          businessId: provider.businessId ?? '',
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh list after creating invoice
        provider.loadInvoices();
      }
    });
  }

  void _viewInvoice(String id) {
    Navigator.pushNamed(
      context,
      '/invoices/detail',
      arguments: id,
    );
  }

  void _editInvoice(String id) {
    Navigator.pushNamed(
      context,
      '/invoices/edit',
      arguments: id,
    );
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف فاکتور'),
        content: Text(
          'آیا از حذف فاکتور ${invoice.invoiceNumber} اطمینان دارید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<InvoiceProvider>().deleteInvoice(
        invoice.id ?? '',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'فاکتور با موفقیت حذف شد'
                  : 'خطا در حذف فاکتور',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _finalizeInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نهایی کردن فاکتور'),
        content: const Text(
          'پس از نهایی کردن، امکان ویرایش فاکتور وجود نخواهد داشت. آیا ادامه می‌دهید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نهایی کردن'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<InvoiceProvider>().finalizeInvoice(
        invoice.id ?? '',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'فاکتور با موفقیت نهایی شد'
                  : 'خطا در نهایی کردن فاکتور',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
