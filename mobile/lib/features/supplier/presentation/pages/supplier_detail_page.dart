import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/supplier_provider.dart';
import '../../data/models/supplier_model.dart';
import '../widgets/supplier_info_tab.dart';
import '../widgets/supplier_contacts_tab.dart';
import '../widgets/supplier_products_tab.dart';
import '../widgets/supplier_documents_tab.dart';
import 'supplier_form_page.dart';

class SupplierDetailPage extends StatefulWidget {
  final String businessId;
  final String supplierId;

  const SupplierDetailPage({Key? key, required this.businessId, required this.supplierId}) : super(key: key);

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSupplier();
    });
  }

  Future<void> _loadSupplier() async {
    if (widget.businessId.isEmpty) return;

    final provider = context.read<SupplierProvider>();
    await provider.loadSupplier(widget.supplierId, widget.businessId);
    await provider.loadSupplierStats(widget.supplierId, widget.businessId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          // Error State
          if (provider.error != null && provider.selectedSupplier == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSupplier,
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          // Loading State
          if (provider.isLoading && provider.selectedSupplier == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final supplier = provider.selectedSupplier;
          if (supplier == null) {
            return const Center(child: Text('تامین‌کننده یافت نشد'));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(supplier.name),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.business,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (supplier.code != null)
                            Text(
                              'کد: ${supplier.code}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editSupplier(supplier),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'status',
                          child: Row(
                            children: [
                              Icon(
                                supplier.isActive ? Icons.block : Icons.check_circle,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(supplier.isActive ? 'غیرفعال کردن' : 'فعال کردن'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'status') {
                          _changeStatus(supplier);
                        } else if (value == 'delete') {
                          _deleteSupplier(supplier);
                        }
                      },
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
                        Tab(text: 'اطلاعات', icon: Icon(Icons.info)),
                        Tab(text: 'مخاطبین', icon: Icon(Icons.contacts)),
                        Tab(text: 'محصولات', icon: Icon(Icons.inventory)),
                        Tab(text: 'مدارک', icon: Icon(Icons.folder)),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                SupplierInfoTab(supplier: supplier),
                SupplierContactsTab(businessId: widget.businessId, supplierId: widget.supplierId),
                SupplierProductsTab(businessId: widget.businessId, supplierId: widget.supplierId),
                SupplierDocumentsTab(businessId: widget.businessId, supplierId: widget.supplierId),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editSupplier(supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierFormPage(businessId: widget.businessId, supplier: supplier),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadSupplier();
      }
    });
  }

  void _changeStatus(supplier) async {
    final newStatus = supplier.isActive
        ? SupplierStatus.suspended
        : SupplierStatus.approved;

    String? reason;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغییر وضعیت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('وضعیت تامین‌کننده به ${newStatus.statusText} تغییر می‌کند.'),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تایید'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (widget.businessId.isEmpty) return;

    final provider = context.read<SupplierProvider>();
    final success = await provider.changeSupplierStatus(
      widget.supplierId,
      widget.businessId,
      newStatus,
      reason,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('وضعیت با موفقیت تغییر کرد'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteSupplier(supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تامین‌کننده'),
        content: Text('آیا از حذف "${supplier.name}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (widget.businessId.isEmpty) return;

    final provider = context.read<SupplierProvider>();
    final success = await provider.deleteSupplier(widget.supplierId, widget.businessId);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تامین‌کننده حذف شد'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
