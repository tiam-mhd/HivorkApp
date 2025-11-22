import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_api_service.dart';
import '../../data/services/category_api_service.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_attributes_tab.dart';

class ProductFormPage extends StatefulWidget {
  final String businessId;
  final Product? product;

  const ProductFormPage({
    Key? key,
    required this.businessId,
    this.product,
  }) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late ProductBloc _productBloc;
  late TabController _tabController;

  // Controllers
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _brandController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _taxRateController = TextEditingController(text: '0');
  final _discountRateController = TextEditingController(text: '0');
  final _currentStockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '0');
  final _maxStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _skuController = TextEditingController();
  final _supplierController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  ProductType _selectedType = ProductType.goods;
  ProductUnit _selectedUnit = ProductUnit.piece;
  ProductStatus _selectedStatus = ProductStatus.active;
  bool _trackInventory = true;
  
  // Category selection
  ProductCategory? _selectedCategory;
  List<ProductCategory> _categories = [];
  bool _loadingCategories = true;
  
  // Variants
  bool _hasVariants = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final dio = ServiceLocator().dio;
    _productBloc = ProductBloc(ProductRepository(ProductApiService(dio)));
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      final dio = ServiceLocator().dio;
      final apiService = CategoryApiService(dio);
      final categories = await apiService.getCategoriesFlat(widget.businessId);
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
      
      // Populate fields after categories are loaded
      if (widget.product != null) {
        _populateFields();
      }
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
      
      // Still populate fields even if categories fail to load
      if (widget.product != null) {
        _populateFields();
      }
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _codeController.text = product.code;
    _nameController.text = product.name;
    _nameEnController.text = product.nameEn ?? '';
    _descriptionController.text = product.description ?? '';
    _barcodeController.text = product.barcode ?? '';
    _brandController.text = product.brand ?? '';
    _purchasePriceController.text = product.purchasePrice.toString();
    _salePriceController.text = product.salePrice.toString();
    _wholesalePriceController.text = product.wholesalePrice?.toString() ?? '';
    _taxRateController.text = product.taxRate.toString();
    _discountRateController.text = product.discountRate.toString();
    _currentStockController.text = product.currentStock.toString();
    _minStockController.text = product.minStock.toString();
    _maxStockController.text = product.maxStock?.toString() ?? '';
    _reorderPointController.text = product.reorderPoint?.toString() ?? '';
    _skuController.text = product.sku ?? '';
    _supplierController.text = product.supplier ?? '';
    _weightController.text = product.weight?.toString() ?? '';
    _notesController.text = product.notes ?? '';
    _selectedType = product.type;
    _selectedUnit = product.unit;
    _selectedStatus = product.status;
    _trackInventory = product.trackInventory;
    _hasVariants = product.hasVariants ?? false;
    
    // Set selected category if exists and categories are loaded
    if (product.category != null && _categories.isNotEmpty) {
      try {
        _selectedCategory = _categories.firstWhere(
          (cat) => cat.id == product.category,
        );
      } catch (e) {
        // Category not found in list, leave as null
        _selectedCategory = null;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _wholesalePriceController.dispose();
    _taxRateController.dispose();
    _discountRateController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _reorderPointController.dispose();
    _skuController.dispose();
    _supplierController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _productBloc.close();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final productData = {
      'name': _nameController.text,
      'nameEn': _nameEnController.text.isNotEmpty ? _nameEnController.text : null,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'type': _selectedType.name,
      'unit': _getUnitValue(_selectedUnit),
      'barcode': _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
      'category': _selectedCategory?.id,
      'brand': _brandController.text.isNotEmpty ? _brandController.text : null,
      'purchasePrice': double.parse(_purchasePriceController.text),
      'salePrice': double.parse(_salePriceController.text),
      'wholesalePrice': _wholesalePriceController.text.isNotEmpty
          ? double.parse(_wholesalePriceController.text)
          : null,
      'taxRate': double.parse(_taxRateController.text),
      'discountRate': double.parse(_discountRateController.text),
      'currentStock': double.parse(_currentStockController.text),
      'minStock': double.parse(_minStockController.text),
      'maxStock': _maxStockController.text.isNotEmpty
          ? double.parse(_maxStockController.text)
          : null,
      'reorderPoint': _reorderPointController.text.isNotEmpty
          ? double.parse(_reorderPointController.text)
          : null,
      'trackInventory': _trackInventory,
      'hasVariants': _hasVariants,
      'sku': _skuController.text.isNotEmpty ? _skuController.text : null,
      'supplier': _supplierController.text.isNotEmpty ? _supplierController.text : null,
      'weight': _weightController.text.isNotEmpty
          ? double.parse(_weightController.text)
          : null,
      'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
    };

    if (widget.product != null) {
      // Update - don't include code and businessId (immutable fields)
      _productBloc.add(UpdateProduct(widget.product!.id, productData));
    } else {
      // Create - include code and businessId
      productData['code'] = _codeController.text;
      productData['businessId'] = widget.businessId;
      _productBloc.add(CreateProduct(productData));
    }
  }

  String _getUnitValue(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.piece:
        return 'piece';
      case ProductUnit.kilogram:
        return 'kilogram';
      case ProductUnit.gram:
        return 'gram';
      case ProductUnit.liter:
        return 'liter';
      case ProductUnit.meter:
        return 'meter';
      case ProductUnit.squareMeter:
        return 'square_meter';
      case ProductUnit.cubicMeter:
        return 'cubic_meter';
      case ProductUnit.box:
        return 'box';
      case ProductUnit.carton:
        return 'carton';
      case ProductUnit.pack:
        return 'pack';
      case ProductUnit.hour:
        return 'hour';
      case ProductUnit.day:
        return 'day';
      case ProductUnit.month:
        return 'month';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Navigator.pop(context, true);
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
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              widget.product != null ? 'ویرایش محصول' : 'افزودن محصول',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'اطلاعات پایه', icon: Icon(Icons.info_outline, size: 20)),
                Tab(text: 'ویژگی‌ها و تنوع', icon: Icon(Icons.playlist_add, size: 20)),
              ],
            ),
          ),
          body: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final isLoading = state is ProductLoading;

              return TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: اطلاعات پایه
                  Form(
                    key: _formKey,
                    child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Basic Info Section
                    _buildSectionTitle('اطلاعات پایه', theme),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _codeController,
                      label: 'کد محصول',
                      hint: 'PRD-001',
                      validator: (value) => value?.isEmpty ?? true ? 'کد محصول الزامی است' : null,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'نام محصول',
                      hint: 'لپ‌تاپ ایسوس',
                      validator: (value) => value?.isEmpty ?? true ? 'نام محصول الزامی است' : null,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameEnController,
                      label: 'نام انگلیسی (اختیاری)',
                      hint: 'ASUS Laptop',
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'توضیحات (اختیاری)',
                      hint: 'توضیحات کامل محصول...',
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Type & Unit
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<ProductType>(
                            label: 'نوع',
                            value: _selectedType,
                            items: [
                              DropdownMenuItem(value: ProductType.goods, child: Text('کالا')),
                              DropdownMenuItem(value: ProductType.service, child: Text('خدمات')),
                            ],
                            onChanged: isLoading ? null : (value) {
                              setState(() => _selectedType = value!);
                            },
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown<ProductUnit>(
                            label: 'واحد',
                            value: _selectedUnit,
                            items: ProductUnit.values.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(_getUnitLabel(unit)),
                              );
                            }).toList(),
                            onChanged: isLoading ? null : (value) {
                              setState(() => _selectedUnit = value!);
                            },
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _barcodeController,
                            label: 'بارکد (اختیاری)',
                            hint: '1234567890',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _skuController,
                            label: 'SKU (اختیاری)',
                            hint: 'SKU-001',
                            enabled: !isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _loadingCategories
                              ? const Center(child: CircularProgressIndicator())
                              : _buildDropdown<ProductCategory?>(
                                  label: 'دسته‌بندی (اختیاری)',
                                  value: _selectedCategory,
                                  items: [
                                    DropdownMenuItem<ProductCategory?>(
                                      value: null,
                                      child: Text('دسته‌بندی نشده', 
                                        style: TextStyle(color: theme.colorScheme.outline)),
                                    ),
                                    ..._categories.map((cat) {
                                      return DropdownMenuItem<ProductCategory?>(
                                        value: cat,
                                        child: Text(cat.name),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: isLoading ? null : (value) {
                                    setState(() => _selectedCategory = value);
                                  },
                                  theme: theme,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _brandController,
                            label: 'برند (اختیاری)',
                            hint: 'ASUS',
                            enabled: !isLoading,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Pricing Section
                    _buildSectionTitle('قیمت‌گذاری', theme),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _purchasePriceController,
                            label: 'قیمت خرید',
                            hint: '1000000',
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty ?? true ? 'الزامی است' : null,
                            enabled: !isLoading,
                            suffix: Text('تومان', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _salePriceController,
                            label: 'قیمت فروش',
                            hint: '1200000',
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty ?? true ? 'الزامی است' : null,
                            enabled: !isLoading,
                            suffix: Text('تومان', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _wholesalePriceController,
                            label: 'قیمت عمده (اختیاری)',
                            hint: '1100000',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
                            suffix: Text('تومان', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _taxRateController,
                            label: 'مالیات (%)',
                            hint: '9',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
                            suffix: Text('%', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Inventory Section
                    _buildSectionTitle('موجودی', theme),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('این محصول دارای تنوع است'),
                      subtitle: Text('محصولات با تنوع دارای رنگ، سایز یا سایر ویژگی‌ها هستند'),
                      value: _hasVariants,
                      onChanged: isLoading ? null : (value) {
                        setState(() => _hasVariants = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text('ردیابی موجودی'),
                      value: _trackInventory,
                      onChanged: isLoading ? null : (value) {
                        setState(() => _trackInventory = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _currentStockController,
                            label: 'موجودی فعلی',
                            hint: '100',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading && _trackInventory && !_hasVariants,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _minStockController,
                            label: 'حداقل موجودی',
                            hint: '10',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading && _trackInventory && !_hasVariants,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _maxStockController,
                            label: 'حداکثر موجودی (اختیاری)',
                            hint: '1000',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading && _trackInventory && !_hasVariants,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _reorderPointController,
                            label: 'نقطه سفارش (اختیاری)',
                            hint: '20',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading && _trackInventory && !_hasVariants,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Additional Info Section
                    _buildSectionTitle('اطلاعات تکمیلی', theme),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _supplierController,
                            label: 'تامین‌کننده (اختیاری)',
                            hint: 'شرکت ABC',
                            enabled: !isLoading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'وزن/کیلوگرم (اختیاری)',
                            hint: '2.5',
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _notesController,
                      label: 'یادداشت‌ها (اختیاری)',
                      hint: 'یادداشت‌های داخلی...',
                      maxLines: 3,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                widget.product != null ? 'بروزرسانی محصول' : 'ذخیره محصول',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                    ),
                  ),
                  
                  // Tab 2: ویژگی‌ها و تنوع
                  widget.product?.id == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 64,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'ابتدا محصول را ذخیره کنید',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'بعد از ذخیره محصول، می‌توانید ویژگی‌ها و تنوع‌ها را مدیریت کنید',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ProductAttributesTab(
                          productId: widget.product!.id,
                          businessId: widget.businessId,
                          productName: _nameController.text.isNotEmpty ? _nameController.text : (widget.product?.name ?? 'محصول'),
                          hasVariants: _hasVariants,
                          onHasVariantsChanged: (value) {
                            setState(() => _hasVariants = value);
                          },
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffix: suffix,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    required ThemeData theme,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
