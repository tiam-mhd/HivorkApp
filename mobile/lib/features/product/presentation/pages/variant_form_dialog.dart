import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';
import '../../data/models/product_variant.dart';
import '../../data/services/attribute_api_service.dart';
import '../../data/services/product_attribute_value_api_service.dart';
import '../../data/services/variant_api_service.dart';
import '../../data/services/image_upload_service.dart';
import '../widgets/variant_image_manager.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _currentStockController;
  late TextEditingController _salePriceController;

  bool _isLoading = false;
  bool _loadingAttributes = false;
  
  List<ProductAttribute> _variantAttributes = [];
  Map<String, List<String>> _productAttributeValues = {}; // مقادیر محصول
  Map<String, dynamic> _selectedAttributeValues = {};

  // Images
  File? _mainImageFile;
  List<File> _additionalImageFiles = [];
  Uint8List? _mainImageBytes; // برای وب
  List<Uint8List> _additionalImageBytes = []; // برای وب
  late ImageUploadService _imageUploadService;
  bool _uploadingImages = false;

  @override
  void initState() {
    super.initState();
    
    final dio = ServiceLocator().dio;
    _imageUploadService = ImageUploadService(dio);
    
    _nameController = TextEditingController(text: widget.variant?.name ?? '');
    _skuController = TextEditingController(text: widget.variant?.sku ?? '');
    _currentStockController = TextEditingController(
      text: widget.variant?.currentStock.toInt().toString() ?? '0',
    );
    _salePriceController = TextEditingController(
      text: widget.variant?.salePrice?.toInt().toString() ?? '',
    );
    
    _selectedAttributeValues = Map<String, dynamic>.from(widget.variant?.attributes ?? {});
    
    if (widget.variant != null) {
      print('🔍 [VARIANT_DIALOG] Loading variant attributes: ${_selectedAttributeValues}');
    }
    
    _loadVariantAttributes();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      final valueService = ProductAttributeValueApiService(dio);
      
      // بارگذاری تمام ویژگی‌های کسب‌وکار
      final attributes = await attributeService.getBusinessAttributes(widget.businessId);
      
      // بارگذاری مقادیر محصول
      final productValues = await valueService.getProductAttributeValues(widget.productId);
      
      // فیلتر: فقط ویژگی‌های variant-level که برای این محصول مقدار دارند
      final variantAttrs = attributes
          .where((attr) => 
              attr.scope == AttributeScope.variantLevel &&
              productValues.containsKey(attr.id) &&
              productValues[attr.id]!.isNotEmpty
          )
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      setState(() {
        _variantAttributes = variantAttrs;
        _productAttributeValues = productValues;
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
      if (attr.required && !_selectedAttributeValues.containsKey(attr.id)) {
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

      if (_nameController.text.isNotEmpty) {
        data['name'] = _nameController.text;
      }

      if (_salePriceController.text.isNotEmpty) {
        data['salePrice'] = double.parse(_salePriceController.text);
      }

      if (widget.variant != null) {
        // ویرایش تنوع
        await variantService.updateVariant(widget.productId, widget.variant!.id, data);
        
        // آپلود عکس‌ها بعد از ویرایش
        if (_mainImageFile != null || _additionalImageFiles.isNotEmpty) {
          await _uploadVariantImages(widget.variant!.id);
        }
      } else {
        // ایجاد تنوع جدید
        final result = await variantService.createVariant(widget.productId, data);
        
        // اگر عکس داریم، آپلود کن
        if (_mainImageFile != null || _additionalImageFiles.isNotEmpty) {
          await _uploadVariantImages(result.id);
        }
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

  Future<void> _uploadVariantImages(String variantId) async {
    setState(() => _uploadingImages = true);

    try {
      // آپلود عکس اصلی
      if (_mainImageFile != null) {
        await _imageUploadService.uploadVariantMainImage(
          productId: widget.productId,
          variantId: variantId,
          imageFile: _mainImageFile!,
          imageBytes: _mainImageBytes, // پاس دادن bytes برای وب
        );
      }

      // آپلود عکس‌های اضافی
      if (_additionalImageFiles.isNotEmpty) {
        await _imageUploadService.uploadVariantImages(
          productId: widget.productId,
          variantId: variantId,
          imageFiles: _additionalImageFiles,
          imageBytesList: _additionalImageBytes, // پاس دادن bytes برای وب
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در آپلود تصاویر: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() => _uploadingImages = false);
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
                          // نام تنوع
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'نام تنوع',
                              prefixIcon: Icon(Icons.label, size: 20),
                              hintText: 'مثال: تیشرت آبی - سایز بزرگ',
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'الزامی' : null,
                          ),
                          const SizedBox(height: 16),

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
                          const SizedBox(height: 24),

                          // Images Section
                          VariantImageManager(
                            variantId: widget.variant?.id,
                            mainImageUrl: widget.variant?.mainImage,
                            imageUrls: widget.variant?.images,
                            enabled: !_isLoading && !_uploadingImages,
                            onMainImageChanged: (file) {
                              setState(() => _mainImageFile = file);
                            },
                            onImagesChanged: (files) {
                              setState(() => _additionalImageFiles = files);
                            },
                            onMainImageBytesChanged: (bytes) {
                              setState(() => _mainImageBytes = bytes);
                            },
                            onImagesBytesChanged: (bytesList) {
                              setState(() => _additionalImageBytes = bytesList);
                            },
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
          initialValue: _selectedAttributeValues[attr.id]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: '${attr.name}${attr.required ? ' *' : ''}',
            prefixIcon: const Icon(Icons.text_fields, size: 20),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _selectedAttributeValues[attr.id] = attr.cardinality == AttributeCardinality.multiple
                  ? [value]
                  : value;
            } else {
              _selectedAttributeValues.remove(attr.id);
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
          initialValue: _selectedAttributeValues[attr.id]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: '${attr.name}${attr.required ? ' *' : ''}',
            prefixIcon: const Icon(Icons.numbers, size: 20),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              final numValue = double.tryParse(value);
              if (numValue != null) {
                _selectedAttributeValues[attr.id] = attr.cardinality == AttributeCardinality.multiple
                    ? [numValue]
                    : numValue;
              }
            } else {
              _selectedAttributeValues.remove(attr.id);
            }
          },
          validator: (v) => attr.required && (v?.isEmpty ?? true) ? 'الزامی' : null,
        );

      case AttributeDataType.boolean:
        final currentValue = _selectedAttributeValues[attr.id];
        final boolValue = currentValue is bool ? currentValue : (currentValue?.toString() == 'true');
        
        return SwitchListTile(
          title: Text(attr.name),
          value: boolValue,
          onChanged: (value) {
            setState(() {
              _selectedAttributeValues[attr.id] = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        );

      case AttributeDataType.date:
        return TextFormField(
          initialValue: _selectedAttributeValues[attr.id]?.toString() ?? '',
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
                _selectedAttributeValues[attr.id] = date.toIso8601String().split('T')[0];
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
        final currentValue = _selectedAttributeValues[attr.id];
        
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
                children: options.map((valueWithLabel) {
                  // Parse "value|label" format
                  String value = valueWithLabel;
                  String displayText = valueWithLabel;
                  if (valueWithLabel.contains('|')) {
                    final parts = valueWithLabel.split('|');
                    value = parts[0];
                    if (parts.length == 2 && parts[1].isNotEmpty) {
                      displayText = parts[1]; // Use label
                    } else {
                      displayText = value; // Use value
                    }
                  }
                  
                  // Check if selected (match either full format or value only)
                  final isSelected = selectedList.contains(valueWithLabel) || 
                                     selectedList.contains(value);
                  return FilterChip(
                    label: Text(displayText),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAttributeValues[attr.id] = [...selectedList, valueWithLabel];
                        } else {
                          final newList = List.from(selectedList)..remove(valueWithLabel);
                          if (newList.isEmpty) {
                            _selectedAttributeValues.remove(attr.id);
                          } else {
                            _selectedAttributeValues[attr.id] = newList;
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
          // Find matching option for current value
          String? matchedValue;
          if (currentValue != null) {
            final currentStr = currentValue.toString();
            matchedValue = options.firstWhere(
              (opt) => opt == currentStr || opt.startsWith('$currentStr|'),
              orElse: () => currentStr,
            );
          }
          
          return DropdownButtonFormField<String>(
            value: matchedValue,
            decoration: InputDecoration(
              labelText: '${attr.name}${attr.required ? ' *' : ''}',
              prefixIcon: const Icon(Icons.list, size: 20),
            ),
            items: options.map((valueWithLabel) {
              // Parse "value|label" format
              String displayText = valueWithLabel;
              if (valueWithLabel.contains('|')) {
                final parts = valueWithLabel.split('|');
                if (parts.length == 2 && parts[1].isNotEmpty) {
                  displayText = parts[1]; // Use label
                } else {
                  displayText = parts[0]; // Use value
                }
              }
              
              return DropdownMenuItem(
                value: valueWithLabel,
                child: Text(displayText),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  _selectedAttributeValues[attr.id] = value;
                } else {
                  _selectedAttributeValues.remove(attr.id);
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
        final currentValue = _selectedAttributeValues[attr.id];
        
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
                spacing: 12,
                runSpacing: 12,
                children: colorOptions.map((valueWithLabel) {
                  // Parse "value|label" format
                  String colorValue = valueWithLabel;
                  String? label;
                  if (valueWithLabel.contains('|')) {
                    final parts = valueWithLabel.split('|');
                    colorValue = parts[0];
                    if (parts.length == 2) {
                      label = parts[1];
                    }
                  }
                  
                  // Check if selected (match either full format or value only)
                  final isSelected = selectedList.contains(valueWithLabel) || 
                                     selectedList.contains(colorValue);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          final newList = List.from(selectedList)..remove(valueWithLabel);
                          if (newList.isEmpty) {
                            _selectedAttributeValues.remove(attr.id);
                          } else {
                            _selectedAttributeValues[attr.id] = newList;
                          }
                        } else {
                          _selectedAttributeValues[attr.id] = [...selectedList, valueWithLabel];
                        }
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _parseColor(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                        if (label != null && label.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
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
                spacing: 12,
                runSpacing: 12,
                children: colorOptions.map((valueWithLabel) {
                  // Parse "value|label" format
                  String colorValue = valueWithLabel;
                  String? label;
                  if (valueWithLabel.contains('|')) {
                    final parts = valueWithLabel.split('|');
                    colorValue = parts[0];
                    if (parts.length == 2) {
                      label = parts[1];
                    }
                  }
                  
                  // Check if selected (match either full format or value only)
                  final isSelected = currentValue == valueWithLabel || 
                                     currentValue == colorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedAttributeValues.remove(attr.id);
                        } else {
                          _selectedAttributeValues[attr.id] = valueWithLabel;
                        }
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _parseColor(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                        if (label != null && label.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
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
      // Remove label if exists (format: "#FF0000|قرمز")
      String cleanColor = colorCode;
      if (colorCode.contains('|')) {
        cleanColor = colorCode.split('|')[0];
      }
      
      // Parse hex color
      if (cleanColor.startsWith('#')) {
        final hex = cleanColor.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
      return Colors.grey;
    } catch (e) {
      print('❌ Failed to parse color: $colorCode');
      return Colors.grey;
    }
  }
}

