import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../data/models/product.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductGridItem({
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

  Color _getStatusColor(ProductStatus status, ThemeData theme) {
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
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Status Badge
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: product.mainImage != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            product.mainImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(product.status, theme).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons (Edit & Delete)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          color: Colors.white,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 14),
                          color: Colors.white,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.code,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                              size: 11,
                              color: product.categoryColor != null
                                  ? _parseColor(product.categoryColor!)
                                  : (product.category != null
                                      ? theme.colorScheme.primary.withOpacity(0.7)
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
                                          ? theme.colorScheme.primary.withOpacity(0.8)
                                          : theme.colorScheme.onSurfaceVariant),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'موجودی:',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '${numberFormat.format(product.currentStock)} ${_getUnitLabel(product.unit)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: product.isOutOfStock
                                    ? Colors.red
                                    : product.isLowStock
                                        ? Colors.orange
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${numberFormat.format(product.salePrice)} تومان',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
      // Remove # if exists
      String hexColor = colorString.replaceAll('#', '');
      // Add FF for alpha if not present
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
    final theme = Theme.of(context);
    
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
