import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../data/models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _getUnitLabel(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.piece:
        return 'عدد';
      case ProductUnit.kilogram:
        return 'کیلوگرم';
      case ProductUnit.gram:
        return 'گرم';
      case ProductUnit.liter:
        return 'لیتر';
      case ProductUnit.meter:
        return 'متر';
      case ProductUnit.squareMeter:
        return 'متر مربع';
      case ProductUnit.cubicMeter:
        return 'متر مکعب';
      case ProductUnit.box:
        return 'جعبه';
      case ProductUnit.carton:
        return 'کارتن';
      case ProductUnit.pack:
        return 'بسته';
      case ProductUnit.hour:
        return 'ساعت';
      case ProductUnit.day:
        return 'روز';
      case ProductUnit.month:
        return 'ماه';
    }
  }

  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return Colors.green;
      case ProductStatus.inactive:
        return Colors.grey;
      case ProductStatus.outOfStock:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = intl.NumberFormat.decimalPattern('fa');

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: product.mainImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.mainImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_outlined,
                            size: 28,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      size: 28,
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getStatusColor(product.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.code,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        product.categoryIcon != null
                            ? _getIconData(product.categoryIcon!)
                            : (product.category != null
                                ? Icons.category_outlined
                                : Icons.folder_off_outlined),
                        size: 10,
                        color: product.categoryColor != null
                            ? _parseColor(product.categoryColor!)
                            : (product.category != null
                                ? theme.colorScheme.primary.withOpacity(0.6)
                                : theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.categoryName ?? 'بدون دسته‌بندی',
                          style: TextStyle(
                            fontSize: 10,
                            color: product.categoryColor != null
                                ? _parseColor(product.categoryColor!)
                                : (product.categoryName != null
                                    ? theme.colorScheme.primary.withOpacity(0.7)
                                    : theme.colorScheme.onSurfaceVariant),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${numberFormat.format(product.currentStock)} ${_getUnitLabel(product.unit)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: product.isOutOfStock
                                    ? Colors.red
                                    : product.isLowStock
                                        ? Colors.orange
                                        : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${numberFormat.format(product.salePrice)} تومان',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons (Vertical)
            // const SizedBox(width: 8),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Material(
            //       color: Colors.transparent,
            //       child: InkWell(
            //         onTap: onEdit,
            //         borderRadius: BorderRadius.circular(8),
            //         child: Padding(
            //           padding: const EdgeInsets.all(6),
            //           child: Icon(
            //             Icons.edit_outlined,
            //             size: 18,
            //             color: theme.colorScheme.primary,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(height: 4),
            //     Material(
            //       color: Colors.transparent,
            //       child: InkWell(
            //         onTap: onDelete,
            //         borderRadius: BorderRadius.circular(8),
            //         child: Padding(
            //           padding: const EdgeInsets.all(6),
            //           child: Icon(
            //             Icons.delete_outline,
            //             size: 18,
            //             color: theme.colorScheme.error,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'category': Icons.category,
      'restaurant': Icons.restaurant,
      'shopping_cart': Icons.shopping_cart,
      'devices': Icons.devices,
      'checkroom': Icons.checkroom,
      'home': Icons.home,
      'sports': Icons.sports_soccer,
      'book': Icons.book,
      'healing': Icons.healing,
      'toys': Icons.toys,
      'build': Icons.build,
      'local_grocery_store': Icons.local_grocery_store,
      'fastfood': Icons.fastfood,
      'coffee': Icons.coffee,
      'cake': Icons.cake,
    };
    return iconMap[iconName] ?? Icons.category_outlined;
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(
                product.status == ProductStatus.active
                    ? Icons.block_outlined
                    : Icons.check_circle_outline,
                color: product.status == ProductStatus.active
                    ? theme.colorScheme.error
                    : Colors.green,
                size: 20,
              ),
              title: Text(
                product.status == ProductStatus.active
                    ? 'غیرفعال کردن'
                    : 'فعال کردن',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleStatus(context);
              },
            ),
            Divider(height: 1),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
              title: Text('افزایش موجودی', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _showStockDialog(context, isIncrease: true);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(Icons.remove_circle_outline, color: Colors.orange, size: 20),
              title: Text('کاهش موجودی', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _showStockDialog(context, isIncrease: false);
              },
            ),
            Divider(height: 1),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 20),
              title: Text('ویرایش', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
              title: Text('حذف', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _toggleStatus(BuildContext context) {
    // TODO: Implement toggle status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تغییر وضعیت به زودی اضافه می‌شود')),
    );
  }

  void _showStockDialog(BuildContext context, {required bool isIncrease}) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIncrease ? 'افزایش موجودی' : 'کاهش موجودی'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'مقدار',
            border: OutlineInputBorder(),
            suffixText: _getUnitLabel(product.unit),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement stock update
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('به‌روزرسانی موجودی به زودی اضافه می‌شود')),
              );
            },
            child: Text('تایید'),
          ),
        ],
      ),
    );
  }
}
