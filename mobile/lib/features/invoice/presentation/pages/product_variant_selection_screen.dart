import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../product/data/models/product.dart';
import '../../../product/data/models/product_variant.dart';
import '../../../product/data/models/product_filter.dart';
import '../../../product/data/repositories/product_repository.dart';
import '../../../product/data/services/product_api_service.dart';
import '../../../product/data/services/variant_api_service.dart';
import '../../../product/presentation/bloc/product_bloc.dart';

/// صفحه انتخاب محصول و تنوع برای فاکتور
/// منطق: محصولات بدون تنوع مستقیم، محصولات با تنوع فقط تنوع‌هارو نشون میده
class ProductVariantSelectionScreen extends StatefulWidget {
  final String businessId;

  const ProductVariantSelectionScreen({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  State<ProductVariantSelectionScreen> createState() =>
      _ProductVariantSelectionScreenState();
}

class _ProductVariantSelectionScreenState
    extends State<ProductVariantSelectionScreen> {
  late ProductBloc _productBloc;
  late VariantApiService _variantService;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // نگهداری لیست نهایی برای نمایش (محصولات بدون تنوع + تنوع‌های محصولات با تنوع)
  List<Map<String, dynamic>> _displayItems = [];
  bool _isLoadingItems = false;
  bool _hasBuiltItems = false; // Flag to track if we've already built items
  
  // لیست آیتم‌های انتخاب شده برای اضافه به فاکتور
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _productBloc = ProductBloc(
      ProductRepository(ProductApiService(dio)),
    );
    _variantService = VariantApiService(dio);
    _productBloc.add(LoadProducts(
      widget.businessId,
      filter: ProductFilter(status: ProductStatus.active),
    ));

    _scrollController.addListener(_onScroll);
  }
  
  /// ساخت لیست آیتم‌ها برای نمایش
  Future<void> _buildDisplayItems(List<Product> products) async {
    if (_isLoadingItems) return; // جلوگیری از اجرای مکرر
    
    debugPrint('🔨 Building display items from ${products.length} products');
    
    setState(() {
      _isLoadingItems = true;
    });
    
    final items = <Map<String, dynamic>>[];
    
    for (var product in products) {
      debugPrint('📦 Processing: ${product.name} (hasVariants: ${product.hasVariants})');
      
      if (product.hasVariants) {
        // برای محصولات با تنوع، تنوع‌ها رو بارگذاری و اضافه می‌کنیم
        try {
          final response = await _variantService.getVariants(
            productId: product.id,
          );
          // response['data'] خودش لیست ProductVariant هست، نه Map
          final variants = (response['data'] as List<ProductVariant>? ?? [])
              .where((v) => v.isActive && v.currentStock > 0)
              .toList();
          
          debugPrint('  ✅ Found ${variants.length} active variants with stock');
          
          for (var variant in variants) {
            items.add({
              'type': 'variant',
              'product': product,
              'variant': variant,
            });
          }
        } catch (e) {
          debugPrint('  ❌ Error loading variants for ${product.id}: $e');
        }
      } else {
        // محصولات بدون تنوع رو مستقیم اضافه می‌کنیم
        debugPrint('  ✅ Adding product without variants');
        items.add({
          'type': 'product',
          'product': product,
          'variant': null,
        });
      }
    }
    
    debugPrint('✨ Final display items count: ${items.length}');
    
    if (mounted) {
      setState(() {
        _displayItems = items;
        _isLoadingItems = false;
        _hasBuiltItems = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _productBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _productBloc.add(LoadNextPage());
    }
  }

  void _onSearch(String query) {
    _productBloc.add(SearchProducts(query));
    // بعد از جستجو، لیست نمایش رو دوباره بسازیم
    setState(() {
      _hasBuiltItems = false;
      _displayItems = [];
    });
  }

  /// انتخاب یک آیتم (محصول یا تنوع)
  // Toggle انتخاب یک آیتم
  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }
  
  // اضافه کردن آیتم‌های انتخاب شده به فاکتور
  void _addSelectedItems() {
    if (_selectedItemIds.isEmpty) return;
    
    final selectedItems = _displayItems.where((item) {
      final product = item['product'] as Product;
      final variant = item['variant'] as ProductVariant?;
      final itemId = variant?.id ?? product.id;
      return _selectedItemIds.contains(itemId);
    }).map((item) => {
      'product': item['product'],
      'variant': item['variant'],
    }).toList();
    
    Navigator.pop(context, selectedItems);
  }

  /// ساخت ویجت نمایش هر آیتم
  Widget _buildSelectionItem(Product product, ProductVariant? variant) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // تعیین ID یکتا برای این آیتم
    final itemId = variant?.id ?? product.id;
    final isSelected = _selectedItemIds.contains(itemId);
    
    // تعیین عکس: عکس تنوع → عکس محصول → بدون عکس
    String? imageUrl;
    if (variant?.mainImage != null) {
      imageUrl = variant!.mainImage;
    } else if (product.mainImage != null) {
      imageUrl = product.mainImage;
    }
    
    // تعیین نام نمایشی
    String displayName;
    if (variant != null && variant.name != null && variant.name!.isNotEmpty) {
      displayName = variant.name!;
    } else if (variant != null && variant.attributes.isNotEmpty) {
      // اگر تنوع اسم نداشت، از attributes استفاده کن
      displayName = variant.attributes.values.join(' • ');
    } else {
      displayName = product.name;
    }
    
    // قیمت و موجودی
    final price = variant?.salePrice ?? product.salePrice;
    final stock = variant?.currentStock ?? product.currentStock;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.cardColor,
        border: Border.all(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _toggleSelection(itemId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // عکس
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              color: theme.colorScheme.outline,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        color: theme.colorScheme.outline,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              // اطلاعات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // قیمت
                        Text(
                          '${price.toStringAsFixed(0)} تومان',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: theme.colorScheme.outline)),
                        const SizedBox(width: 8),
                        // موجودی
                        Text(
                          'موجودی: ${stock.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: stock > 0 
                                ? (isDark ? Colors.green[300] : Colors.green[700])
                                : (isDark ? Colors.red[300] : Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedItemIds.isEmpty 
              ? 'انتخاب محصول'
              : '${_selectedItemIds.length} مورد انتخاب شده',
        ),
        actions: [
          if (_selectedItemIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedItemIds.clear();
                });
              },
              child: const Text('پاک کردن'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearch,
            ),
          ),
        ),
      ),
      body: BlocProvider.value(
        value: _productBloc,
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            // Loading state - نمایش اولیه
            if (state is ProductLoading && _displayItems.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state - خطا در بارگذاری اولیه
            if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _productBloc.add(LoadProducts(
                          widget.businessId,
                          filter: ProductFilter(status: ProductStatus.active),
                        ));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              );
            }

            // دریافت محصولات از stateهای مختلف
            List<Product> products = [];

            if (state is ProductLoaded) {
              products = state.products;
              // وقتی محصولات لود شد و هنوز لیست نساختیم، بسازیم
              if (!_hasBuiltItems && !_isLoadingItems && products.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _buildDisplayItems(products);
                });
              }
            } else if (state is ProductLoadingMore) {
              products = state.currentProducts;
            }

            // Empty state - وقتی محصولی نیست و در حال ساخت نیستیم
            if (products.isEmpty && !_isLoadingItems && _hasBuiltItems) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'محصولی یافت نشد',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            // در حال ساخت لیست نمایش
            if (_isLoadingItems) {
              return const Center(child: CircularProgressIndicator());
            }

            // نمایش لیست آیتم‌ها (محصولات بدون تنوع + تنوع‌های محصولات با تنوع)
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _displayItems.length,
                    itemBuilder: (context, index) {
                      final item = _displayItems[index];
                      final product = item['product'] as Product;
                      final variant = item['variant'] as ProductVariant?;
                      
                      return _buildSelectionItem(product, variant);
                    },
                  ),
                ),
                // دکمه اضافه به فاکتور
                if (_selectedItemIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addSelectedItems,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'اضافه به فاکتور (${_selectedItemIds.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
