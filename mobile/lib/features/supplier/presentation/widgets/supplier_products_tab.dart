import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/supplier_provider.dart';

class SupplierProductsTab extends StatefulWidget {
  final String businessId;
  final String supplierId;

  const SupplierProductsTab({Key? key, required this.businessId, required this.supplierId}) : super(key: key);

  @override
  State<SupplierProductsTab> createState() => _SupplierProductsTabState();
}

class _SupplierProductsTabState extends State<SupplierProductsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    if (widget.businessId.isEmpty) return;

    final provider = context.read<SupplierProvider>();
    await provider.loadSupplierProducts(widget.supplierId, widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingProducts) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.supplierProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('هیچ محصولی ثبت نشده'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن محصول'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.supplierProducts.length,
              itemBuilder: (context, index) {
                final supplierProduct = provider.supplierProducts[index];
                final product = supplierProduct.product;
                final variant = supplierProduct.productVariant;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                    supplierProduct.displayName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product?.sku != null)
                                    Text(
                                      'کد: ${product!.sku}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('ویرایش'),
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
                                if (value == 'edit') {
                                  _showProductDialog(supplierProduct: supplierProduct);
                                } else if (value == 'delete') {
                                  _deleteProduct(supplierProduct.id);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'قیمت خرید: ${supplierProduct.purchasePrice.toStringAsFixed(0)} تومان',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                if (supplierProduct.minOrderQuantity != null)
                                  Text(
                                    'حداقل سفارش: ${supplierProduct.minOrderQuantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: supplierProduct.isActive
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    supplierProduct.isActive ? 'فعال' : 'غیرفعال',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: supplierProduct.isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (supplierProduct.isPreferred)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star, size: 12, color: Colors.amber),
                                        SizedBox(width: 4),
                                        Text(
                                          'ترجیحی',
                                          style: TextStyle(fontSize: 10, color: Colors.amber),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog({supplierProduct}) {
    // Note: This would typically require product selection
    // For now, showing a simplified placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('افزودن محصول نیاز به انتخاب از لیست محصولات دارد'),
      ),
    );
  }

  void _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف محصول'),
        content: const Text('آیا از حذف این محصول از تامین‌کننده اطمینان دارید؟'),
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
    final success = await provider.removeProduct(
      widget.supplierId,
      productId,
      widget.businessId,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('محصول حذف شد'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'خطا در حذف محصول'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
