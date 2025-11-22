import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/di/service_locator.dart';
import '../../data/models/product.dart';
import '../../data/models/product_variant.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_api_service.dart';
import '../../data/services/variant_api_service.dart';
import '../bloc/product_bloc.dart';
import 'product_form_page.dart';
import 'variants_management_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductBloc _productBloc;
  late VariantApiService _variantService;
  List<ProductVariant> _variants = [];
  bool _isLoadingVariants = false;
  bool _hasLoadedVariants = false; // Track if we've attempted to load

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _productBloc = ProductBloc(ProductRepository(ProductApiService(dio)));
    _variantService = VariantApiService(dio);
    _productBloc.add(LoadProductById(widget.productId));
  }

  @override
  void dispose() {
    _productBloc.close();
    super.dispose();
  }

  Future<void> _loadVariants() async {
    if (_hasLoadedVariants) return; // Already attempted to load
    
    setState(() {
      _isLoadingVariants = true;
      _hasLoadedVariants = true; // Mark as attempted
    });

    try {
      print('🔵 [PRODUCT_DETAIL] Loading variants for product: ${widget.productId}');
      final result = await _variantService.getVariants(productId: widget.productId);
      
      print('✅ [PRODUCT_DETAIL] Variants API response: $result');
      print('✅ [PRODUCT_DETAIL] Data type: ${result['data'].runtimeType}');
      
      final data = result['data'];
      List<ProductVariant> variantsList;
      
      if (data is List<ProductVariant>) {
        variantsList = data;
      } else if (data is List) {
        // Parse from List<dynamic> or List<Map>
        variantsList = data
            .map((v) {
              if (v is ProductVariant) return v;
              if (v is Map<String, dynamic>) return ProductVariant.fromJson(v);
              throw Exception('Invalid variant type: ${v.runtimeType}');
            })
            .toList();
      } else {
        variantsList = [];
      }
      
      print('✅ [PRODUCT_DETAIL] Parsed ${variantsList.length} variants');
      
      // Sort: in-stock first
      variantsList.sort((a, b) {
        final aOrder = _getVariantStatusOrder(a.status);
        final bOrder = _getVariantStatusOrder(b.status);
        return aOrder.compareTo(bOrder);
      });

      setState(() {
        _variants = variantsList;
        _isLoadingVariants = false;
      });
      
      print('✅ [PRODUCT_DETAIL] Variants loaded successfully');
    } catch (e, stack) {
      print('❌ [PRODUCT_DETAIL] Error loading variants: $e');
      print('❌ [PRODUCT_DETAIL] Stack trace: $stack');
      setState(() {
        _isLoadingVariants = false;
      });
    }
  }

  int _getVariantStatusOrder(VariantStatus status) {
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

  String _getStatusLabel(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'فعال';
      case ProductStatus.inactive:
        return 'غیرفعال';
      case ProductStatus.outOfStock:
        return 'ناموجود';
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

  String _getTypeLabel(ProductType type) {
    switch (type) {
      case ProductType.goods:
        return 'کالا';
      case ProductType.service:
        return 'خدمات';
    }
  }

  void _showDeleteDialog(Product product) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('حذف محصول'),
        content: Text('آیا مطمئن هستید که می‌خواهید "${product.name}" را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _productBloc.add(DeleteProduct(product.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustDialog(Product product) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تنظیم موجودی'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text('اضافه'), icon: Icon(Icons.add)),
                  ButtonSegment(value: false, label: Text('کسر'), icon: Icon(Icons.remove)),
                ],
                selected: {isAdding},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() => isAdding = newSelection.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مقدار',
                  suffixText: _getUnitLabel(product.unit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.pop(dialogContext);
                  _productBloc.add(
                    AdjustProductStock(
                      product.id,
                      isAdding ? value : -value,
                    ),
                  );
                }
              },
              child: Text('تایید'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = intl.NumberFormat.decimalPattern('fa');

    return BlocProvider.value(
      value: _productBloc,
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            if (state.message.contains('حذف')) {
              Navigator.pop(context, true);
            } else {
              _productBloc.add(LoadProductById(widget.productId));
            }
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is ProductError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text('خطا در بارگذاری اطلاعات'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _productBloc.add(LoadProductById(widget.productId));
                        },
                        child: Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                );
              }

              if (state is! ProductDetailLoaded) {
                return SizedBox();
              }

              final product = state.product;

              return CustomScrollView(
                slivers: [
                  // AppBar with Image
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: product.mainImage != null
                          ? Image.network(
                              product.mainImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: theme.colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 80,
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductFormPage(
                                businessId: product.businessId,
                                product: product,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) {
                              // Reload product
                              _productBloc.add(LoadProductById(widget.productId));
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteDialog(product),
                      ),
                    ],
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(product.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(product.status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _getStatusLabel(product.status),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(product.status),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'کد: ${product.code}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              if (product.barcode != null) ...[
                                Text(' • ', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                                Text(
                                  'بارکد: ${product.barcode}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Category & Type
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: product.categoryColor != null
                                      ? _parseColor(product.categoryColor!).withOpacity(0.15)
                                      : (product.categoryName != null
                                          ? theme.colorScheme.primaryContainer
                                          : theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      product.categoryIcon != null
                                          ? _getIconData(product.categoryIcon!)
                                          : (product.categoryName != null
                                              ? Icons.category_outlined
                                              : Icons.folder_off_outlined),
                                      size: 16,
                                      color: product.categoryColor != null
                                          ? _parseColor(product.categoryColor!)
                                          : (product.categoryName != null
                                              ? theme.colorScheme.onPrimaryContainer
                                              : theme.colorScheme.onSurfaceVariant),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      product.categoryName ?? 'بدون دسته‌بندی',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: product.categoryColor != null
                                            ? _parseColor(product.categoryColor!)
                                            : (product.categoryName != null
                                                ? theme.colorScheme.onPrimaryContainer
                                                : theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      product.type == ProductType.goods
                                          ? Icons.inventory_2_outlined
                                          : Icons.engineering_outlined,
                                      size: 16,
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _getTypeLabel(product.type),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.straighten_outlined,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _getUnitLabel(product.unit),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (product.description != null) ...[
                            const SizedBox(height: 20),
                            Text(
                              product.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                height: 1.6,
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Price Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'قیمت فروش',
                                  '${numberFormat.format(product.salePrice)} تومان',
                                  Icons.sell_outlined,
                                  theme.colorScheme.primary,
                                  theme,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'قیمت خرید',
                                  '${numberFormat.format(product.purchasePrice)} تومان',
                                  Icons.shopping_cart_outlined,
                                  theme.colorScheme.secondary,
                                  theme,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Stock Section
                          _buildStockSection(product, theme, numberFormat),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
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

  Widget _buildStockSection(Product product, ThemeData theme, intl.NumberFormat numberFormat) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_outlined, size: 20, color: theme.colorScheme.primary),
              SizedBox(width: 8),
              Text(
                'موجودی انبار',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              if (product.hasVariants)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VariantsManagementPage(
                          productId: product.id,
                          productName: product.name,
                          businessId: product.businessId,
                        ),
                      ),
                    ).then((_) => _loadVariants());
                  },
                  icon: Icon(Icons.auto_awesome_mosaic, size: 16),
                  label: Text('مدیریت تنوع‌ها'),
                )
              else
                TextButton.icon(
                  onPressed: () => _showStockAdjustDialog(product),
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('تنظیم'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (product.hasVariants)
            _buildVariantStocks(product, theme, numberFormat)
          else
            _buildSimpleStock(product, theme, numberFormat),
        ],
      ),
    );
  }

  Widget _buildSimpleStock(Product product, ThemeData theme, intl.NumberFormat numberFormat) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'موجودی فعلی',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${numberFormat.format(product.currentStock)} ${_getUnitLabel(product.unit)}',
                    style: TextStyle(
                      fontSize: 18,
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
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حداقل موجودی',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${numberFormat.format(product.minStock)} ${_getUnitLabel(product.unit)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (product.isLowStock && !product.isOutOfStock)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'موجودی این محصول کم است',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVariantStocks(Product product, ThemeData theme, intl.NumberFormat numberFormat) {
    // Load variants only once on first render
    if (!_hasLoadedVariants && !_isLoadingVariants) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVariants();
      });
    }

    if (_isLoadingVariants) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_variants.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant, size: 20),
            SizedBox(width: 8),
            Text(
              'هنوز تنوعی ایجاد نشده است',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final isDark = theme.brightness == Brightness.dark;
    
    // Show up to 5 variants
    final displayVariants = _variants.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini summary
        Row(
          children: [
            _buildMiniStatBadge(
              'موجود',
              _variants.where((v) => v.status == VariantStatus.inStock).length,
              isDark ? Colors.green.shade300 : Colors.green.shade600,
              isDark,
            ),
            SizedBox(width: 8),
            _buildMiniStatBadge(
              'کم',
              _variants.where((v) => v.status == VariantStatus.lowStock).length,
              isDark ? Colors.orange.shade300 : Colors.orange.shade600,
              isDark,
            ),
            SizedBox(width: 8),
            _buildMiniStatBadge(
              'ناموجود',
              _variants.where((v) => v.status == VariantStatus.outOfStock).length,
              isDark ? Colors.red.shade300 : Colors.red.shade600,
              isDark,
            ),
          ],
        ),
        SizedBox(height: 12),
        
        // Variant list
        ...displayVariants.map((variant) => _buildVariantStockRow(variant, theme, numberFormat, isDark)),
        
        if (_variants.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VariantsManagementPage(
                      productId: product.id,
                      productName: product.name,
                      businessId: product.businessId,
                    ),
                  ),
                ).then((_) => _loadVariants());
              },
              child: Text('مشاهده ${_variants.length - 5} تنوع دیگر'),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniStatBadge(String label, int count, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantStockRow(ProductVariant variant, ThemeData theme, intl.NumberFormat numberFormat, bool isDark) {
    final colors = _extractColorCodes(variant);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.cardColor.withOpacity(0.3) 
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? Colors.grey.shade700.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Color indicator(s)
          if (colors.isNotEmpty)
            Wrap(
              spacing: 4,
              children: colors.take(3).map((color) => Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _parseVariantColor(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
              )).toList(),
            )
          else
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              _formatVariantName(variant.name ?? variant.sku),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Stock
          Text(
            '${numberFormat.format(variant.currentStock)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getVariantStatusColor(variant.status, isDark),
            ),
          ),
          SizedBox(width: 4),
          Text(
            'عدد',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Color _parseVariantColor(String colorCode) {
    try {
      return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  String _formatVariantName(String name) {
    return name.replaceAll(RegExp(r'#[0-9a-fA-F]{6}'), '').trim();
  }

  Color _getVariantStatusColor(VariantStatus status, bool isDark) {
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
