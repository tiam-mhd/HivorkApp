import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_variant.dart';
import '../../data/services/variant_api_service.dart';
import '../../data/services/product_attribute_value_api_service.dart';
import '../../data/utils/variant_combination_generator.dart';
import '../pages/variants_management_page.dart';
import 'product_attribute_selector.dart';

/// Tab widget for product variants within product form
/// Shows a mini list and button to open full management page
class ProductVariantsTab extends StatefulWidget {
  final String productId;
  final String productName;
  final String businessId;
  final bool hasVariants;
  final Function(bool) onHasVariantsChanged;

  const ProductVariantsTab({
    Key? key,
    required this.productId,
    required this.productName,
    required this.businessId,
    required this.hasVariants,
    required this.onHasVariantsChanged,
  }) : super(key: key);

  @override
  State<ProductVariantsTab> createState() => _ProductVariantsTabState();
}

class _ProductVariantsTabState extends State<ProductVariantsTab>
    with AutomaticKeepAliveClientMixin {
  late VariantApiService _variantService;
  late ProductAttributeValueApiService _attributeValueService;
  List<ProductVariant> _variants = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _variantService = VariantApiService(dio);
    _attributeValueService = ProductAttributeValueApiService(dio);
    if (widget.hasVariants) {
      _loadVariants();
    }
  }

  Future<void> _loadVariants() async {
    if (!widget.hasVariants) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final variantsMap = await _variantService.getVariants(
        productId: widget.productId,
      );
      
      print('🔧 [VARIANTS_TAB] variantsMap type: ${variantsMap.runtimeType}');
      print('🔧 [VARIANTS_TAB] variantsMap data type: ${variantsMap['data'].runtimeType}');
      print('🔧 [VARIANTS_TAB] variantsMap: $variantsMap');
      
      setState(() {
        // data is already List<ProductVariant>, not List<Map>
        final data = variantsMap['data'];
        List<ProductVariant> variants;
        if (data is List<ProductVariant>) {
          variants = data;
        } else if (data is List) {
          // Fallback: try to parse as List<dynamic>
          variants = data
              .map((v) {
                if (v is ProductVariant) return v;
                if (v is Map<String, dynamic>) return ProductVariant.fromJson(v);
                throw Exception('Invalid variant type: ${v.runtimeType}');
              })
              .toList();
        } else {
          variants = [];
        }
        
        // Sort: in-stock first, then low-stock, then out-of-stock
        variants.sort((a, b) {
          final aOrder = _getStatusOrder(a.status);
          final bOrder = _getStatusOrder(b.status);
          return aOrder.compareTo(bOrder);
        });
        
        _variants = variants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleHasVariants(bool value) {
    if (value && _variants.isEmpty) {
      // Enabling variants - show info dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('فعال‌سازی ترکیبات'),
          content: const Text(
            'با فعال کردن ترکیبات، می‌توانید موجودی مستقل برای هر ترکیب ویژگی‌ها داشته باشید.\n\n'
            'ابتدا باید ویژگی‌های محصول را تعریف کنید.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onHasVariantsChanged(true);
                setState(() {});
                // Navigate to attributes management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VariantsManagementPage(
                      productId: widget.productId,
                      productName: widget.productName,
                      businessId: widget.businessId,
                    ),
                  ),
                ).then((_) => _loadVariants());
              },
              child: const Text('ادامه'),
            ),
          ],
        ),
      );
    } else if (!value && _variants.isNotEmpty) {
      // Disabling variants - show warning
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('غیرفعال‌سازی ترکیبات'),
          content: Text(
            'این محصول ${_variants.length} ترکیب دارد.\n'
            'با غیرفعال کردن، تمام ترکیبات حذف خواهند شد.\n\n'
            'آیا مطمئن هستید؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Delete all variants
                try {
                  for (final variant in _variants) {
                    await _variantService.deleteVariant(widget.productId, variant.id);
                  }
                  widget.onHasVariantsChanged(false);
                  setState(() {
                    _variants = [];
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمام ترکیبات حذف شدند')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطا: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف همه'),
            ),
          ],
        ),
      );
    } else {
      widget.onHasVariantsChanged(value);
      setState(() {});
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

  Future<void> _generateVariantsFromAttributes(
    Map<String, List<String>> attributeValues,
  ) async {
    setState(() => _isLoading = true);

    try {
      print('🔧 [VARIANTS_TAB] Generating variants from attributes');
      print('🔧 [VARIANTS_TAB] Attribute values (with IDs): $attributeValues');

      // First, save attribute values to backend
      await _attributeValueService.setProductAttributeValues(
        widget.productId,
        attributeValues,
      );

      print('🔧 [VARIANTS_TAB] Attribute values saved successfully');

      // Load attributes with metadata to get ID -> code mapping and cardinality
      final attributesMetadata = await _attributeValueService.getProductAttributeValuesWithMetadata(
        widget.productId,
      );
      
      print('🔧 [VARIANTS_TAB] Loaded attributes metadata: $attributesMetadata');

      // Build ID to code mapping and cardinality info
      final Map<String, String> idToCodeMap = {};
      final Map<String, String> codeToCardinalityMap = {};
      
      attributesMetadata.forEach((id, data) {
        final code = data['code'] as String;
        final attribute = data['attribute'] as Map<String, dynamic>;
        final cardinality = attribute['cardinality'] as String;
        
        idToCodeMap[id] = code;
        codeToCardinalityMap[code] = cardinality;
      });
      
      print('🔧 [VARIANTS_TAB] ID to Code mapping: $idToCodeMap');
      print('🔧 [VARIANTS_TAB] Cardinality mapping: $codeToCardinalityMap');

      // Generate all combinations (with IDs)
      final combinations =
          VariantCombinationGenerator.generateCombinations(attributeValues);

      print('🔧 [VARIANTS_TAB] Generated ${combinations.length} combinations');

      // Convert combinations from ID-based to code-based and prepare data
      final variantsData = combinations.map((combination) {
        // Convert attribute IDs to codes and format values based on cardinality
        final Map<String, dynamic> codeBasedAttributes = {};
        combination.forEach((attributeId, value) {
          final code = idToCodeMap[attributeId];
          if (code != null) {
            final cardinality = codeToCardinalityMap[code];
            // For 'multiple' cardinality, wrap single values in array
            // For 'single' cardinality, keep as string
            codeBasedAttributes[code] = cardinality == 'multiple' ? [value] : value;
          }
        });
        
        final skuSuffix =
            VariantCombinationGenerator.generateSKUSuffix(combination);
        final name = VariantCombinationGenerator.generateVariantName(combination);

        return {
          'sku': '${widget.productId.substring(0, 8).toUpperCase()}-$skuSuffix',
          'name': '${widget.productName} $name',
          'attributes': codeBasedAttributes,  // Formatted based on cardinality
          'currentStock': 0.0,
          'minStock': 0.0,
          'priceAdjustment': 0.0,
          'purchasePriceAdjustment': 0.0,
          'isActive': true,
        };
      }).toList();

      print('🔧 [VARIANTS_TAB] Prepared variants data: ${variantsData.length} items');
      print('🔧 [VARIANTS_TAB] First variant example: ${variantsData.first}');

      // Bulk create variants
      await _variantService.bulkCreateVariants(widget.productId, widget.businessId, variantsData);

      print('🔧 [VARIANTS_TAB] Variants created successfully');

      // Reload variants
      await _loadVariants();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${combinations.length} ترکیب با موفقیت ایجاد شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ [VARIANTS_TAB] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Minimal Expandable Card
          Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? theme.dividerColor.withOpacity(0.2)
                    : theme.dividerColor,
              ),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.hasVariants 
                      ? theme.primaryColor.withOpacity(0.15)
                      : (theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_mosaic,
                  color: widget.hasVariants 
                      ? theme.primaryColor 
                      : (theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600),
                  size: 20,
                ),
              ),
              title: Text(
                'تنوع محصول',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                widget.hasVariants 
                    ? (_variants.isEmpty ? 'ایجاد نشده' : '${_variants.length} نوع')
                    : 'غیرفعال',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_variants.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.green.withOpacity(0.2)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_variants.length}',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.green.shade300
                              : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Switch(
                    value: widget.hasVariants,
                    onChanged: _toggleHasVariants,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              children: [
                if (!widget.hasVariants)
                  _buildInactiveState(theme)
                else if (_isLoading)
                  _buildLoadingState()
                else if (_errorMessage != null)
                  _buildErrorState(theme)
                else if (_variants.isEmpty)
                  _buildEmptyState(theme)
                else
                  _buildVariantsList(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.toggle_off,
            size: 48,
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'برای استفاده از تنوع محصول، کلید بالا را فعال کنید',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: context.errorColor),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _loadVariants,
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_mosaic_outlined, 
            size: 48, 
            color: theme.primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'هنوز تنوعی ایجاد نشده',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          _buildGenerateButton(context),
        ],
      ),
    );
  }

  Widget _buildVariantsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mini Stats
        Row(
          children: [
            _buildMiniStat(
              'موجود',
              _variants.where((v) => v.status == VariantStatus.inStock).length,
              Colors.green,
            ),
            const SizedBox(width: 12),
            _buildMiniStat(
              'کم',
              _variants.where((v) => v.status == VariantStatus.lowStock).length,
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildMiniStat(
              'ناموجود',
              _variants.where((v) => v.status == VariantStatus.outOfStock).length,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Variants Preview (max 3)
        ..._variants.take(3).map((variant) => _buildVariantRow(variant, theme)),
        
        const SizedBox(height: 12),
        
        // View All Button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VariantsManagementPage(
                  productId: widget.productId,
                  productName: widget.productName,
                  businessId: widget.businessId,
                ),
              ),
            ).then((_) => _loadVariants());
          },
          icon: const Icon(Icons.open_in_new, size: 16),
          label: Text('مشاهده و مدیریت همه (${_variants.length})'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, int count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDark 
        ? (color == Colors.green ? Colors.green.shade300
           : color == Colors.orange ? Colors.orange.shade300
           : Colors.red.shade300)
        : (color == Colors.green ? Colors.green.shade600
           : color == Colors.orange ? Colors.orange.shade600
           : Colors.red.shade600);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? displayColor.withOpacity(0.2) : displayColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: displayColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: displayColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantRow(ProductVariant variant, ThemeData theme) {
    final colors = _extractColorCodes(variant);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Color indicator
          if (colors.isNotEmpty)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _parseColor(colors.first),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
              ),
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.circle_outlined,
                size: 16,
                color: isDark ? Colors.grey.shade500 : Colors.grey,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'موجودی: ${variant.currentStock.toInt()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(variant.status, theme).withOpacity(isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              variant.status.displayName,
              style: TextStyle(
                color: _getStatusColor(variant.status, theme),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  Color _getStatusColor(VariantStatus status, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
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

  Widget _buildGenerateButton(BuildContext context) {
    return ProductAttributeSelector(
      productId: widget.productId,
      businessId: widget.businessId,
      selectedAttributeIds: const [],
      onAttributesSelected: (attributes) {
        // Just pass through to generator
      },
      onGenerateVariants: _generateVariantsFromAttributes,
    );
  }
}
