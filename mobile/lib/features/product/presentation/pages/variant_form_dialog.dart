import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';
import '../../data/models/product_variant.dart';
import '../../data/services/attribute_api_service.dart';
import '../../data/services/product_attribute_value_api_service.dart';
import '../../data/services/variant_api_service.dart';

class VariantFormDialog extends StatefulWidget {
  final String productId;
  final String businessId;
  final ProductVariant? variant;
  final VoidCallback onSaved;

  const VariantFormDialog({
    Key? key,
    required this.productId,
    required this.businessId,
    this.variant,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<VariantFormDialog> createState() => _VariantFormDialogState();
}

class _VariantFormDialogState extends State<VariantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _skuController;
  late TextEditingController _currentStockController;
  late TextEditingController _salePriceController;

  bool _isLoading = false;
  bool _loadingAttributes = false;
  
  List<ProductAttribute> _variantAttributes = [];
  Map<String, dynamic> _selectedAttributeValues = {};

  @override
  void initState() {
    super.initState();
    
    _skuController = TextEditingController(text: widget.variant?.sku ?? '');
    _currentStockController = TextEditingController(
      text: widget.variant?.currentStock.toInt().toString() ?? '0',
    );
    _salePriceController = TextEditingController(
      text: widget.variant?.salePrice?.toInt().toString() ?? '',
    );
    
    _selectedAttributeValues = Map<String, dynamic>.from(widget.variant?.attributes ?? {});
    
    _loadVariantAttributes();
  }

  @override
  void dispose() {
    _skuController.dispose();
    _currentStockController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _loadVariantAttributes() async {
    setState(() => _loadingAttributes = true);

    try {
      final dio = ServiceLocator().dio;
      final attributeService = AttributeApiService(dio);
      
      // Use businessId directly instead of fetching product first
      final attributes = await attributeService.getBusinessAttributes(widget.businessId);
      
      final variantAttrs = attributes
          .where((attr) => attr.scope == AttributeScope.variantLevel)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      setState(() {
        _variantAttributes = variantAttrs;
        _loadingAttributes = false;
      });
    } catch (e) {
      setState(() => _loadingAttributes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate attributes
    for (final attr in _variantAttributes) {
      if (attr.required && !_selectedAttributeValues.containsKey(attr.code)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${attr.name} الزامی است')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final dio = ServiceLocator().dio;
      final variantService = VariantApiService(dio);

      final data = {
        'sku': _skuController.text,
        'currentStock': double.parse(_currentStockController.text),
        'minStock': 0.0,
        'attributes': _selectedAttributeValues,
      };

      if (_salePriceController.text.isNotEmpty) {
        data['salePrice'] = double.parse(_salePriceController.text);
      }

      if (widget.variant != null) {
        await variantService.updateVariant(widget.productId, widget.variant!.id, data);
      } else {
        await variantService.createVariant(widget.productId, data);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ذخیره شد')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_mosaic, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.variant == null ? 'تنوع جدید' : 'ویرایش تنوع',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loadingAttributes
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // SKU
                          TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'کد SKU',
                              prefixIcon: Icon(Icons.qr_code, size: 20),
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'الزامی' : null,
                          ),
                          const SizedBox(height: 16),

                          // Attributes Section
                          if (_variantAttributes.isNotEmpty) ...[
                            Text(
                              'ویژگی‌ها',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._variantAttributes.map((attr) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildAttributeInput(attr, isDark),
                            )),
                            const SizedBox(height: 8),
                          ],

                          // Stock
                          TextFormField(
                            controller: _currentStockController,
                            decoration: const InputDecoration(
                              labelText: 'موجودی',
                              prefixIcon: Icon(Icons.inventory, size: 20),
                              suffixText: 'عدد',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.isEmpty ?? true ? 'الزامی' : null,
                          ),
                          const SizedBox(height: 16),

                          // Price
                          TextFormField(
                            controller: _salePriceController,
                            decoration: const InputDecoration(
                              labelText: 'قیمت فروش',
                              prefixIcon: Icon(Icons.sell, size: 20),
                              suffixText: 'تومان',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('ذخیره'),
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

  Widget _buildAttributeInput(ProductAttribute attr, bool isDark) {
    switch (attr.dataType) {
      case AttributeDataType.text:
        return TextFormField(
          initialValue: _selectedAttributeValues[attr.code]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: '${attr.name}${attr.required ? ' *' : ''}',
            prefixIcon: const Icon(Icons.text_fields, size: 20),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _selectedAttributeValues[attr.code] = attr.cardinality == AttributeCardinality.multiple
                  ? [value]
                  : value;
            } else {
              _selectedAttributeValues.remove(attr.code);
            }
          },
          validator: (v) => attr.required && (v?.isEmpty ?? true) ? 'الزامی' : null,
        );

      case AttributeDataType.select:
        return _buildSelectInput(attr, isDark);

      case AttributeDataType.color:
        return _buildColorInput(attr, isDark);

      case AttributeDataType.number:
        return TextFormField(
          initialValue: _selectedAttributeValues[attr.code]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: '${attr.name}${attr.required ? ' *' : ''}',
            prefixIcon: const Icon(Icons.numbers, size: 20),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              final numValue = double.tryParse(value);
              if (numValue != null) {
                _selectedAttributeValues[attr.code] = attr.cardinality == AttributeCardinality.multiple
                    ? [numValue]
                    : numValue;
              }
            } else {
              _selectedAttributeValues.remove(attr.code);
            }
          },
          validator: (v) => attr.required && (v?.isEmpty ?? true) ? 'الزامی' : null,
        );

      case AttributeDataType.boolean:
        final currentValue = _selectedAttributeValues[attr.code];
        final boolValue = currentValue is bool ? currentValue : (currentValue?.toString() == 'true');
        
        return SwitchListTile(
          title: Text(attr.name),
          value: boolValue,
          onChanged: (value) {
            setState(() {
              _selectedAttributeValues[attr.code] = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        );

      case AttributeDataType.date:
        return TextFormField(
          initialValue: _selectedAttributeValues[attr.code]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: '${attr.name}${attr.required ? ' *' : ''}',
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _selectedAttributeValues[attr.code] = date.toIso8601String().split('T')[0];
              });
            }
          },
          validator: (v) => attr.required && (v?.isEmpty ?? true) ? 'الزامی' : null,
        );
    }
  }

  Widget _buildSelectInput(ProductAttribute attr, bool isDark) {
    return FutureBuilder<List<String>>(
      future: _loadAttributeValues(attr.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final options = snapshot.data ?? [];
        final currentValue = _selectedAttributeValues[attr.code];
        
        if (attr.cardinality == AttributeCardinality.multiple) {
          final selectedList = currentValue is List ? currentValue : (currentValue != null ? [currentValue] : []);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${attr.name}${attr.required ? ' *' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  final isSelected = selectedList.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAttributeValues[attr.code] = [...selectedList, option];
                        } else {
                          final newList = List.from(selectedList)..remove(option);
                          if (newList.isEmpty) {
                            _selectedAttributeValues.remove(attr.code);
                          } else {
                            _selectedAttributeValues[attr.code] = newList;
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          );
        } else {
          return DropdownButtonFormField<String>(
            value: currentValue?.toString(),
            decoration: InputDecoration(
              labelText: '${attr.name}${attr.required ? ' *' : ''}',
              prefixIcon: const Icon(Icons.list, size: 20),
            ),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  _selectedAttributeValues[attr.code] = value;
                } else {
                  _selectedAttributeValues.remove(attr.code);
                }
              });
            },
            validator: (v) => attr.required && v == null ? 'الزامی' : null,
          );
        }
      },
    );
  }

  Widget _buildColorInput(ProductAttribute attr, bool isDark) {
    return FutureBuilder<List<String>>(
      future: _loadAttributeValues(attr.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final colorOptions = snapshot.data ?? [];
        final currentValue = _selectedAttributeValues[attr.code];
        
        if (attr.cardinality == AttributeCardinality.multiple) {
          final selectedList = currentValue is List ? currentValue : (currentValue != null ? [currentValue] : []);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${attr.name}${attr.required ? ' *' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((colorCode) {
                  final isSelected = selectedList.contains(colorCode);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          final newList = List.from(selectedList)..remove(colorCode);
                          if (newList.isEmpty) {
                            _selectedAttributeValues.remove(attr.code);
                          } else {
                            _selectedAttributeValues[attr.code] = newList;
                          }
                        } else {
                          _selectedAttributeValues[attr.code] = [...selectedList, colorCode];
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(colorCode),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${attr.name}${attr.required ? ' *' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((colorCode) {
                  final isSelected = currentValue == colorCode;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedAttributeValues.remove(attr.code);
                        } else {
                          _selectedAttributeValues[attr.code] = colorCode;
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(colorCode),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<String>> _loadAttributeValues(String attributeId) async {
    try {
      // Find the attribute to get its details
      final attr = _variantAttributes.firstWhere((a) => a.id == attributeId);
      
      // First try to get values from product attribute values
      final dio = ServiceLocator().dio;
      final valueService = ProductAttributeValueApiService(dio);
      
      try {
        final productValues = await valueService.getProductAttributeValuesWithMetadata(widget.productId);
        
        // Check if this attribute has values defined for the product
        if (productValues.containsKey(attributeId)) {
          final values = productValues[attributeId]['values'] as List<String>;
          if (values.isNotEmpty) {
            return values;
          }
        }
      } catch (e) {
        print('⚠️ No product attribute values found, falling back to options');
      }
      
      // Fallback: use attribute options if available
      if (attr.options != null && attr.options!.isNotEmpty) {
        return attr.options!.map((opt) => opt.value).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error loading attribute values: $e');
      return [];
    }
  }

  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}

