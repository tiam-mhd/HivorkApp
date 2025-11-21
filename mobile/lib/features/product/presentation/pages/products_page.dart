import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/product.dart';
import '../../data/models/product_filter.dart';
import '../../data/models/product_category.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_api_service.dart';
import '../../data/services/category_api_service.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/product_list_item.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';
import 'categories_management_page.dart';
import 'attributes_management_page.dart';
import 'stock_report_screen.dart';
import 'package:go_router/go_router.dart';

enum ViewMode { list, grid }

class ProductsPage extends StatefulWidget {
  final String businessId;
  final ProductFilter? initialFilter;

  const ProductsPage({
    Key? key,
    required this.businessId,
    this.initialFilter,
  }) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ProductBloc _productBloc;
  ViewMode _viewMode = ViewMode.list; // همیشه در حالت لیست
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // فیلتر فعلی برای ذخیره و نمایش
  ProductFilter? _currentFilter;
  
  // دسته‌بندی‌ها
  List<ProductCategory> _categories = [];
  bool _loadingCategories = false;
  String? _selectedCategoryId; // null = همه، 'uncategorized' = بدون دسته‌بندی

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    final dio = ServiceLocator().dio;
    _productBloc = ProductBloc(
      ProductRepository(ProductApiService(dio)),
    );
    _productBloc.add(LoadProducts(
      widget.businessId,
      filter: _currentFilter,
    ));

    _scrollController.addListener(_onScroll);
    _loadCategories();
    _loadViewMode();
  }
  
  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('product_view_mode');
    if (savedMode != null) {
      setState(() {
        _viewMode = savedMode == 'list' ? ViewMode.list : ViewMode.grid;
      });
    }
  }
  
  Future<void> _saveViewMode(ViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('product_view_mode', mode == ViewMode.list ? 'list' : 'grid');
  }
  
  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final dio = ServiceLocator().dio;
      final apiService = CategoryApiService(dio);
      final categories = await apiService.getCategoriesFlat(widget.businessId);
      print('📂 Categories loaded: ${categories.length}');
      for (var cat in categories) {
        print('  - ${cat.name} (${cat.id})');
      }
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() => _loadingCategories = false);
    }
  }
  
  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null) {
        // همه محصولات
        _currentFilter = _currentFilter?.copyWith(category: null) ?? ProductFilter();
      } else if (categoryId == 'uncategorized') {
        // محصولات بدون دسته‌بندی
        _currentFilter = (_currentFilter ?? ProductFilter()).copyWith(category: 'null');
      } else {
        // دسته‌بندی خاص
        _currentFilter = (_currentFilter ?? ProductFilter()).copyWith(category: categoryId);
      }
    });
    _productBloc.add(LoadProducts(widget.businessId, filter: _currentFilter));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _productBloc.state;
      if (state is ProductLoaded && state.hasMore) {
        _productBloc.add(LoadNextPage());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _productBloc.close();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }
  
  // رفرش لیست محصولات
  Future<void> _refreshProducts() async {
    _productBloc.add(LoadProducts(
      widget.businessId,
      filter: _currentFilter,
    ));
  }
  
  // چک کردن اینکه آیا فیلتر فعالی وجود دارد
  bool _hasActiveFilters() {
    if (_currentFilter == null) return false;
    return _currentFilter!.status != null ||
           _currentFilter!.type != null ||
           _currentFilter!.category != null ||
           (_currentFilter!.lowStock ?? false) ||
           (_currentFilter!.outOfStock ?? false) ||
           _currentFilter!.minPrice != null ||
           _currentFilter!.maxPrice != null;
  }
  
  // نمایش فیلترهای فعال به صورت chip
  Widget _buildActiveFilters(ThemeData theme) {
    final filters = <String>[];
    
    if (_currentFilter!.status != null) {
      filters.add(_getStatusLabel(_currentFilter!.status!));
    }
    if (_currentFilter!.type != null) {
      filters.add(_getTypeLabel(_currentFilter!.type!));
    }
    if (_currentFilter!.category != null) {
      if (_currentFilter!.category == 'null') {
        filters.add('دسته‌بندی نشده');
      } else {
        final category = _categories.firstWhere(
          (c) => c.id == _currentFilter!.category,
          orElse: () => _categories.first,
        );
        filters.add(category.name);
      }
    }
    if (_currentFilter!.lowStock ?? false) {
      filters.add('موجودی کم');
    }
    if (_currentFilter!.outOfStock ?? false) {
      filters.add('ناموجود');
    }
    if (_currentFilter!.minPrice != null || _currentFilter!.maxPrice != null) {
      String priceLabel = 'قیمت: ';
      if (_currentFilter!.minPrice != null && _currentFilter!.maxPrice != null) {
        priceLabel += '${_formatPrice(_currentFilter!.minPrice!)} - ${_formatPrice(_currentFilter!.maxPrice!)}';
      } else if (_currentFilter!.minPrice != null) {
        priceLabel += 'از ${_formatPrice(_currentFilter!.minPrice!)}';
      } else {
        priceLabel += 'تا ${_formatPrice(_currentFilter!.maxPrice!)}';
      }
      filters.add(priceLabel);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Chip(
                      label: Text(
                        filter,
                        style: const TextStyle(fontSize: 11),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() {
                          _currentFilter = null;
                        });
                        _productBloc.add(LoadProducts(widget.businessId));
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
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
  
  String _getTypeLabel(ProductType type) {
    switch (type) {
      case ProductType.goods:
        return 'کالا';
      case ProductType.service:
        return 'خدمات';
    }
  }
  
  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} میلیون';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} هزار';
    }
    return price.toStringAsFixed(0);
  }
  
  Widget _buildCategoriesScroll(ThemeData theme) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // همه محصولات
          _buildCategoryChip(
            label: 'همه',
            isSelected: _selectedCategoryId == null,
            onTap: () => _onCategorySelected(null),
            theme: theme,
          ),
          const SizedBox(width: 8),
          // دسته‌بندی نشده
          _buildCategoryChip(
            label: 'بدون دسته',
            isSelected: _selectedCategoryId == 'uncategorized',
            onTap: () => _onCategorySelected('uncategorized'),
            theme: theme,
          ),
          const SizedBox(width: 8),
          // دسته‌بندی‌ها
          ..._categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildCategoryChip(
                label: category.name,
                isSelected: _selectedCategoryId == category.id,
                onTap: () => _onCategorySelected(category.id),
                theme: theme,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'devices':
        return Icons.devices_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'fashion':
        return Icons.checkroom_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'sports':
        return Icons.sports_soccer_outlined;
      case 'beauty':
        return Icons.face_outlined;
      case 'books':
        return Icons.menu_book_outlined;
      case 'toys':
        return Icons.toys_outlined;
      case 'automotive':
        return Icons.directions_car_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildFilterSheet() {
    final theme = Theme.of(context);
    ProductStatus? selectedStatus = _currentFilter?.status;
    ProductType? selectedType = _currentFilter?.type;
    String? selectedCategory = _currentFilter?.category;
    bool lowStock = _currentFilter?.lowStock ?? false;
    bool outOfStock = _currentFilter?.outOfStock ?? false;
    
    // کنترلرهای قیمت
    final minPriceController = TextEditingController(
      text: _currentFilter?.minPrice?.toString() ?? '',
    );
    final maxPriceController = TextEditingController(
      text: _currentFilter?.maxPrice?.toString() ?? '',
    );

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'فیلترها',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    // const Spacer(),
                    // TextButton(
                    //   onPressed: () {
                    //     _productBloc.add(ClearFilter());
                    //     Navigator.pop(context);
                    //   },
                    //   child: const Text('پاک کردن'),
                    // ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Filters
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Status Filter
                    Text(
                      'وضعیت',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          'فعال',
                          selectedStatus == ProductStatus.active,
                          () => setState(() {
                            selectedStatus = selectedStatus == ProductStatus.active
                                ? null
                                : ProductStatus.active;
                          }),
                          theme,
                        ),
                        _buildFilterChip(
                          'غیرفعال',
                          selectedStatus == ProductStatus.inactive,
                          () => setState(() {
                            selectedStatus = selectedStatus == ProductStatus.inactive
                                ? null
                                : ProductStatus.inactive;
                          }),
                          theme,
                        ),
                        _buildFilterChip(
                          'ناموجود',
                          selectedStatus == ProductStatus.outOfStock,
                          () => setState(() {
                            selectedStatus = selectedStatus == ProductStatus.outOfStock
                                ? null
                                : ProductStatus.outOfStock;
                          }),
                          theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Type Filter
                    Text(
                      'نوع محصول',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          'کالا',
                          selectedType == ProductType.goods,
                          () => setState(() {
                            selectedType = selectedType == ProductType.goods
                                ? null
                                : ProductType.goods;
                          }),
                          theme,
                        ),
                        _buildFilterChip(
                          'خدمات',
                          selectedType == ProductType.service,
                          () => setState(() {
                            selectedType = selectedType == ProductType.service
                                ? null
                                : ProductType.service;
                          }),
                          theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stock Filters
                    Text(
                      'موجودی',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('موجودی کم'),
                      value: lowStock,
                      onChanged: (value) => setState(() => lowStock = value ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('ناموجود'),
                      value: outOfStock,
                      onChanged: (value) => setState(() => outOfStock = value ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    
                    // Category Filter
                    Text(
                      'دسته‌بندی',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          'دسته‌بندی نشده',
                          selectedCategory == 'null',
                          () => setState(() {
                            selectedCategory = selectedCategory == 'null' ? null : 'null';
                          }),
                          theme,
                          icon: Icons.folder_off_outlined,
                        ),
                        ..._categories.map((category) {
                          return _buildFilterChip(
                            category.name,
                            selectedCategory == category.id,
                            () => setState(() {
                              selectedCategory = selectedCategory == category.id ? null : category.id;
                            }),
                            theme,
                            icon: _getCategoryIcon(category.icon),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Price Range Filter
                    Text(
                      'محدوده قیمت',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'از (تومان)',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'تا (تومان)',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // دکمه پاک کردن فیلترها
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // آپدیت state اصلی صفحه (نه StatefulBuilder)
                            this.setState(() {
                              _currentFilter = null;
                            });
                            _productBloc.add(LoadProducts(widget.businessId));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'پاک کردن',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // دکمه اعمال فیلترها
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final filter = ProductFilter(
                              status: selectedStatus,
                              type: selectedType,
                              category: selectedCategory,
                              lowStock: lowStock,
                              outOfStock: outOfStock,
                              minPrice: minPriceController.text.isNotEmpty 
                                  ? double.tryParse(minPriceController.text) 
                                  : null,
                              maxPrice: maxPriceController.text.isNotEmpty 
                                  ? double.tryParse(maxPriceController.text) 
                                  : null,
                            );
                            Navigator.pop(context);
                            // آپدیت state اصلی صفحه (نه StatefulBuilder)
                            this.setState(() {
                              _currentFilter = filter;
                            });
                            _productBloc.add(ApplyFilter(filter));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'اعمال فیلترها',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label, 
    bool selected, 
    VoidCallback onTap, 
    ThemeData theme, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _productBloc,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'محصولات',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // دکمه گزارش موجودی
            IconButton(
              icon: Icon(Icons.bar_chart_rounded, color: theme.colorScheme.onSurface),
              onPressed: () {
                context.push('/stock-report?businessId=${widget.businessId}');
              },
              tooltip: 'گزارش موجودی',
            ),
            // دکمه مدیریت ویژگی‌ها
            IconButton(
              icon: Icon(Icons.tune, color: theme.colorScheme.onSurface),
              onPressed: () {
                context.push('/attributes?businessId=${widget.businessId}');
              },
              tooltip: 'مدیریت ویژگی‌ها',
            ),
            // دکمه دسته‌بندی
            IconButton(
              icon: Icon(Icons.category_outlined, color: theme.colorScheme.onSurface),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriesManagementPage(businessId: widget.businessId),
                  ),
                );
              },
              tooltip: 'مدیریت دسته‌بندی',
            ),
            // IconButton(
            //   icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            //   onPressed: _refreshProducts,
            //   tooltip: 'رفرش',
            // ),
            // IconButton(
            //   icon: Icon(
            //     _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
            //     color: theme.colorScheme.onSurface,
            //   ),
            //   onPressed: () {
            //     final newMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
            //     setState(() {
            //       _viewMode = newMode;
            //     });
            //     _saveViewMode(newMode);
            //   },
            // ),
            // IconButton(
            //   icon: Icon(Icons.filter_list_rounded, color: theme.colorScheme.onSurface),
            //   onPressed: _showFilterSheet,
            // ),
            // const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _productBloc.add(LoadProducts(widget.businessId, filter: _currentFilter));
                  } else {
                    _productBloc.add(SearchProducts(value));
                  }
                },
                decoration: InputDecoration(
                  hintText: 'جستجو...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _productBloc.add(LoadProducts(widget.businessId, filter: _currentFilter));
                            setState(() {});
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: _refreshProducts,
                        tooltip: 'بازخوانی',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: _showFilterSheet,
                        tooltip: 'فیلتر',
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            
            // Categories Horizontal Scroll
            _buildCategoriesScroll(theme),
            
            // Active Filter Chips
            if (_currentFilter != null && _hasActiveFilters()) 
              _buildActiveFilters(theme),

            // Products List/Grid
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductError) {
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
                            'خطا در بارگذاری محصولات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _productBloc.add(LoadProducts(widget.businessId));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'محصولی یافت نشد',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اولین محصول خود را اضافه کنید',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshProducts,
                      child: _viewMode == ViewMode.grid
                          ? GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: state.products.length +
                                  (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.products.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final product = state.products[index];
                                return ProductGridItem(
                                  product: product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(productId: product.id),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductFormPage(
                                          businessId: widget.businessId,
                                          product: product,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        _productBloc.add(RefreshProducts());
                                      }
                                    });
                                  },
                                  onDelete: () => _showDeleteDialog(context, product),
                                );
                              },
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
                              itemCount: state.products.length +
                                  (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.products.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final product = state.products[index];
                                return ProductListItem(
                                  product: product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(productId: product.id),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductFormPage(
                                          businessId: widget.businessId,
                                          product: product,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        _productBloc.add(RefreshProducts());
                                      }
                                    });
                                  },
                                  onDelete: () => _showDeleteDialog(context, product),
                                );
                              },
                            ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductFormPage(businessId: widget.businessId),
              ),
            ).then((result) {
              if (result == true) {
                _productBloc.add(RefreshProducts());
              }
            });
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('افزودن محصول'),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('حذف محصول'),
        content: Text('آیا از حذف "${product.name}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _productBloc.add(DeleteProduct(product.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('محصول "${product.name}" حذف شد'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
