import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/attribute_variant_theme.dart';

import '../../data/models/product_variant.dart';
import '../../data/services/variant_api_service.dart';

/// Widget for selecting a product variant in invoices
/// Shows all available variants with stock, price, and attributes
class VariantSelectorDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final double? basePrice;
  final Function(ProductVariant) onVariantSelected;

  const VariantSelectorDialog({
    Key? key,
    required this.productId,
    required this.productName,
    this.basePrice,
    required this.onVariantSelected,
  }) : super(key: key);

  @override
  State<VariantSelectorDialog> createState() => _VariantSelectorDialogState();
}

class _VariantSelectorDialogState extends State<VariantSelectorDialog> {
  late VariantApiService _variantService;
  List<ProductVariant> _variants = [];
  List<ProductVariant> _filteredVariants = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  bool _onlyInStock = true;

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
      final variantsMap = await _variantService.getVariants(
        productId: widget.productId,
      );
      
      setState(() {
        _variants = (variantsMap['data'] as List? ?? [])
            .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredVariants = _variants.where((variant) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!variant.sku.toLowerCase().contains(query) &&
            !(variant.name?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Stock filter
      if (_onlyInStock && variant.currentStock <= 0) {
        return false;
      }

      return variant.isActive;
    }).toList();

    // Sort by stock descending
    _filteredVariants.sort((a, b) => b.currentStock.compareTo(a.currentStock));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'انتخاب ترکیب',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.productName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'جستجو (SKU، نام)',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Stock filter
                  SwitchListTile(
                    value: _onlyInStock,
                    onChanged: (value) {
                      setState(() {
                        _onlyInStock = value;
                        _applyFilters();
                      });
                    },
                    title: const Text('فقط موجود'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: context.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
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
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: context.textSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _onlyInStock
                                        ? 'ترکیبی موجود نیست'
                                        : 'ترکیبی یافت نشد',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  if (_onlyInStock) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _onlyInStock = false;
                                          _applyFilters();
                                        });
                                      },
                                      child: const Text('نمایش همه'),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredVariants.length,
                              itemBuilder: (context, index) {
                                final variant = _filteredVariants[index];
                                return _VariantCard(
                                  variant: variant,
                                  basePrice: widget.basePrice,
                                  onTap: () {
                                    if (variant.currentStock <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('این ترکیب موجود نیست'),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.of(context).pop();
                                    widget.onVariantSelected(variant);
                                  },
                                );
                              },
                            ),
            ),

            // Footer
            if (_filteredVariants.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: context.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_filteredVariants.length} ترکیب یافت شد',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// VARIANT CARD
// ============================================

class _VariantCard extends StatelessWidget {
  final ProductVariant variant;
  final double? basePrice;
  final VoidCallback onTap;

  const _VariantCard({
    required this.variant,
    this.basePrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = variant.currentStock <= 0;
    final price = basePrice != null 
        ? variant.getFinalSalePrice(basePrice!) 
        : variant.salePrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isOutOfStock ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isOutOfStock ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: SKU + Status + Stock
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
                    const SizedBox(width: 12),
                    // Stock Badge
                    AttributeVariantTheme.stockBadge(
                      variant.currentStock,
                      variant.minStock,
                      context,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Attributes
                if (variant.attributes.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: variant.attributes.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.key,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary,
                              ),
                            ),
                            const Text(': '),
                            Text(
                              entry.value.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Price & Stock Row
                Row(
                  children: [
                    // Price
                    if (price != null) ...[
                      Icon(
                        Icons.sell,
                        size: 18,
                        color: context.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${price.toStringAsFixed(0)} تومان',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                      const Spacer(),
                    ],

                    // Stock count
                    Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${variant.currentStock.toStringAsFixed(0)} عدد',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Out of stock overlay
                if (isOutOfStock) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          'ناموجود',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet version (simpler, takes less space)
class VariantSelectorBottomSheet extends StatelessWidget {
  final String productId;
  final String productName;
  final double? basePrice;
  final Function(ProductVariant) onVariantSelected;

  const VariantSelectorBottomSheet({
    Key? key,
    required this.productId,
    required this.productName,
    this.basePrice,
    required this.onVariantSelected,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String productId,
    required String productName,
    double? basePrice,
    required Function(ProductVariant) onVariantSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VariantSelectorBottomSheet(
        productId: productId,
        productName: productName,
        basePrice: basePrice,
        onVariantSelected: onVariantSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: VariantSelectorDialog(
                  productId: productId,
                  productName: productName,
                  basePrice: basePrice,
                  onVariantSelected: onVariantSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
