import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/extensions/theme_extension.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_variant.dart';
import '../../data/services/variant_api_service.dart';
import '../../../../core/di/service_locator.dart';
import 'variant_form_dialog.dart';

class VariantsManagementPage extends StatefulWidget {
  final String productId;
  final String productName;
  final String businessId;

  const VariantsManagementPage({
    Key? key,
    required this.productId,
    required this.productName,
    required this.businessId,
  }) : super(key: key);

  @override
  State<VariantsManagementPage> createState() => _VariantsManagementPageState();
}

class _VariantsManagementPageState extends State<VariantsManagementPage> {
  late VariantApiService _variantService;
  List<ProductVariant> _variants = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _variantService = VariantApiService(dio);
    _loadVariants();
  }

  Future<void> _loadVariants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _variantService.getVariants(productId: widget.productId);
      final variantsList = result['data'] as List<ProductVariant>;

      // Sort: in-stock first
      variantsList.sort((a, b) {
        final aOrder = _getStatusOrder(a.status);
        final bOrder = _getStatusOrder(b.status);
        return aOrder.compareTo(bOrder);
      });

      setState(() {
        _variants = variantsList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int _getStatusOrder(VariantStatus status) {
    switch (status) {
      case VariantStatus.inStock:
        return 0;
      case VariantStatus.lowStock:
        return 1;
      case VariantStatus.outOfStock:
        return 2;
      case VariantStatus.discontinued:
        return 3;
    }
  }

  List<ProductVariant> get _filteredVariants {
    if (_searchQuery.isEmpty) return _variants;
    return _variants.where((v) =>
      v.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (v.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  void _deleteVariant(ProductVariant variant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تنوع'),
        content: Text('آیا از حذف "${_formatVariantName(variant.name ?? variant.sku)}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _variantService.deleteVariant(widget.productId, variant.id);
                _loadVariants();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تنوع با موفقیت حذف شد')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: ${e.toString()}')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _quickStockEdit(ProductVariant variant) {
    final controller = TextEditingController(text: variant.currentStock.toInt().toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظیم موجودی'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'موجودی جدید',
            suffixText: 'عدد',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('مقدار نامعتبر')),
                );
                return;
              }
              
              Navigator.pop(context);
              try {
                final formData = VariantFormData.fromVariant(variant).copyWith(
                  currentStock: value,
                );
                
                await _variantService.updateVariant(
                  widget.productId,
                  variant.id,
                  formData.toJson(),
                );
                _loadVariants();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('موجودی بروزرسانی شد')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('مدیریت تنوع‌ها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.productName,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Variants List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: context.errorColor),
                            const SizedBox(height: 16),
                            Text('خطا در بارگذاری'),
                            const SizedBox(height: 8),
                            Text(_errorMessage!, style: TextStyle(fontSize: 12, color: context.textSecondary)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadVariants,
                              child: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      )
                    : _filteredVariants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: context.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  'هیچ تنوعی یافت نشد',
                                  style: TextStyle(color: context.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadVariants,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredVariants.length,
                              itemBuilder: (context, index) {
                                final variant = _filteredVariants[index];
                                return _buildVariantCard(variant, theme, isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_variants.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ابتدا برای محصول ویژگی تعریف کنید')),
            );
            return;
          }
          showDialog(
            context: context,
            builder: (context) => VariantFormDialog(
              productId: widget.productId,
              businessId: widget.businessId,
              onSaved: _loadVariants,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVariantCard(ProductVariant variant, ThemeData theme, bool isDark) {
    final numberFormat = intl.NumberFormat('#,###', 'fa');
    final colors = _extractColorCodes(variant);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => VariantFormDialog(
              productId: widget.productId,
              businessId: variant.businessId,
              variant: variant,
              onSaved: _loadVariants,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Color Circle
                  if (colors.isNotEmpty)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _parseColor(colors.first),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                    ),
                  const SizedBox(width: 12),
                  
                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatVariantName(variant.name ?? variant.sku),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          variant.sku,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(variant.status, isDark).withOpacity(isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      variant.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(variant.status, isDark),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // More Menu
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'stock':
                          _quickStockEdit(variant);
                          break;
                        case 'delete':
                          _deleteVariant(variant);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'stock',
                        child: Row(
                          children: [
                            Icon(Icons.inventory, size: 18),
                            SizedBox(width: 8),
                            Text('موجودی'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stock & Price Row
              Row(
                children: [
                  Icon(Icons.inventory_outlined, size: 14, color: context.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${numberFormat.format(variant.currentStock.toInt())} عدد',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(variant.status, isDark),
                    ),
                  ),
                  if (variant.salePrice != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.sell, size: 14, color: context.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${numberFormat.format(variant.salePrice)} ت',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _extractColorCodes(ProductVariant variant) {
    final colors = <String>{};
    
    variant.attributes.forEach((key, value) {
      if (key.toLowerCase() == 'color' || key == 'رنگ') {
        if (value is List) {
          for (final item in value) {
            final str = item.toString();
            if (str.startsWith('#') && str.length == 7) {
              colors.add(str.toLowerCase());
            }
          }
        } else {
          final str = value.toString();
          if (str.startsWith('#') && str.length == 7) {
            colors.add(str.toLowerCase());
          }
        }
      }
    });
    
    return colors.toList();
  }

  Color _parseColor(String colorCode) {
    try {
      return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  String _formatVariantName(String name) {
    return name.replaceAll(RegExp(r'#[0-9a-fA-F]{6}'), '').trim();
  }

  Color _getStatusColor(VariantStatus status, bool isDark) {
    switch (status) {
      case VariantStatus.inStock:
        return isDark ? Colors.green.shade300 : Colors.green.shade600;
      case VariantStatus.lowStock:
        return isDark ? Colors.orange.shade300 : Colors.orange.shade600;
      case VariantStatus.outOfStock:
        return isDark ? Colors.red.shade300 : Colors.red.shade600;
      case VariantStatus.discontinued:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }
}
