import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';
import '../../data/services/attribute_api_service.dart';
import '../../data/services/product_attribute_value_api_service.dart';
import '../pages/variants_management_page.dart';

/// Custom FAB location to position it above the variant management section
class _CustomFabLocation extends FloatingActionButtonLocation {
  const _CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Position at bottom-left, but with offset from bottom
    final double fabX = kFloatingActionButtonMargin + scaffoldGeometry.minInsets.left;
    final double fabY = scaffoldGeometry.scaffoldSize.height - 
                        scaffoldGeometry.minInsets.bottom - 
                        kFloatingActionButtonMargin - 
                        scaffoldGeometry.floatingActionButtonSize.height - 
                        160.0; // Extra offset to clear the variant box
    return Offset(fabX, fabY);
  }
}

/// Tab for managing product attributes and their values
class ProductAttributesTab extends StatefulWidget {
  final String productId;
  final String businessId;
  final String productName;
  final bool hasVariants;
  final Function(bool) onHasVariantsChanged;

  const ProductAttributesTab({
    Key? key,
    required this.productId,
    required this.businessId,
    required this.productName,
    required this.hasVariants,
    required this.onHasVariantsChanged,
  }) : super(key: key);

  @override
  State<ProductAttributesTab> createState() => _ProductAttributesTabState();
}

class _ProductAttributesTabState extends State<ProductAttributesTab>
    with AutomaticKeepAliveClientMixin {
  late AttributeApiService _attributeService;
  late ProductAttributeValueApiService _valueService;

  List<ProductAttribute> _allAttributes = [];
  Map<String, List<String>> _productAttributeValues = {};  // API format
  bool _isLoading = false;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _attributeService = AttributeApiService(dio);
    _valueService = ProductAttributeValueApiService(dio);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔵 [ATTRIBUTES_TAB] Loading data for product: ${widget.productId}');
      
      // Load all business attributes
      final attributes = await _attributeService.getBusinessAttributes(widget.businessId);
      print('✅ [ATTRIBUTES_TAB] Loaded ${attributes.length} attributes');
      
      // Load product's attribute values
      final values = await _valueService.getProductAttributeValues(widget.productId);
      print('✅ [ATTRIBUTES_TAB] Loaded ${values.length} attribute values');

      setState(() {
        _allAttributes = attributes;
        _productAttributeValues = values;
        _isLoading = false;
      });
    } catch (e, stack) {
      print('❌ [ATTRIBUTES_TAB] Error loading data: $e');
      print('❌ [ATTRIBUTES_TAB] Stack trace: $stack');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Get only attributes that are assigned to this product
  List<ProductAttribute> get _assignedAttributes {
    return _allAttributes
        .where((attr) => _productAttributeValues.containsKey(attr.id))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // Get attributes that are NOT assigned yet
  List<ProductAttribute> get _availableAttributes {
    return _allAttributes
        .where((attr) => !_productAttributeValues.containsKey(attr.id))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> _saveValues() async {
    try {
      await _valueService.setProductAttributeValues(
        widget.productId,
        _productAttributeValues,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ویژگی‌ها با موفقیت ذخیره شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addAttribute() {
    if (_availableAttributes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('همه ویژگی‌ها به محصول اضافه شده‌اند')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AttributePickerDialog(
        attributes: _availableAttributes,
        onSelect: (attribute) {
          setState(() {
            _productAttributeValues[attribute.id] = [];
          });
          _saveValues();
        },
      ),
    );
  }

  void _removeAttribute(ProductAttribute attribute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف ویژگی'),
        content: Text('آیا از حذف ویژگی "${attribute.name}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _productAttributeValues.remove(attribute.id);
              });
              _saveValues();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _editAttributeValue(ProductAttribute attribute) {
    final currentValues = _productAttributeValues[attribute.id] ?? [];
    
    // Show appropriate editor based on dataType
    if (attribute.dataType == AttributeDataType.color) {
      // برای رنگ همیشه color picker نشون بده
      if (attribute.cardinality == AttributeCardinality.multiple) {
        _showMultiColorPickerDialog(attribute, currentValues);
      } else {
        _showColorPickerDialog(attribute, currentValues.isNotEmpty ? currentValues.first : null);
      }
    } else if (attribute.dataType == AttributeDataType.select && 
        attribute.options != null && attribute.options!.isNotEmpty) {
      if (attribute.cardinality == AttributeCardinality.multiple) {
        _showMultiOptionPicker(attribute, currentValues);
      } else {
        _showSingleOptionPicker(attribute, currentValues.isNotEmpty ? currentValues.first : null);
      }
    } else if (attribute.dataType == AttributeDataType.boolean) {
      _showBooleanPicker(attribute, currentValues.isNotEmpty ? currentValues.first == 'true' : false);
    } else if (attribute.dataType == AttributeDataType.date) {
      _showDatePicker(attribute, currentValues.isNotEmpty ? currentValues.first : null);
    } else {
      // Text or number
      if (attribute.cardinality == AttributeCardinality.multiple) {
        _showMultiTextInput(attribute, currentValues);
      } else {
        _showSingleTextInput(attribute, currentValues.isNotEmpty ? currentValues.first : null);
      }
    }
  }

  void _showColorPickerDialog(ProductAttribute attribute, String? currentValue) {
    Color pickerColor = Colors.blue;
    
    // Parse current color if exists
    if (currentValue != null && currentValue.isNotEmpty) {
      try {
        final colorOption = attribute.options?.firstWhere(
          (opt) => opt.value == currentValue,
          orElse: () => attribute.options!.first,
        );
        if (colorOption?.color != null) {
          pickerColor = Color(int.parse(colorOption!.color!.replaceFirst('#', '0xFF')));
        }
      } catch (e) {
        pickerColor = Colors.blue;
      }
    }

    final labelController = TextEditingController();
    
    // اگر مقدار قبلی وجود داشت و شامل label بود، آن را parse کنیم
    if (currentValue != null && currentValue.contains('|')) {
      final parts = currentValue.split('|');
      if (parts.length == 2) {
        labelController.text = parts[1];
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = pickerColor;
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(attribute.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color Picker
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setState(() => selectedColor = color);
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    paletteType: PaletteType.hsvWithHue,
                    pickerAreaHeightPercent: 0.8,
                  ),
                  const SizedBox(height: 16),
                  // رنگ انتخاب شده
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // فیلد عنوان
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان (نمایشی)',
                      hintText: 'مثلاً: قرمز، آبی، ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // تبدیل Color به hex string
                  final hexColor = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
                  final label = labelController.text.trim();
                  final finalValue = label.isNotEmpty ? '$hexColor|$label' : hexColor;
                  
                  // ذخیره مقدار
                  this.setState(() {
                    _productAttributeValues[attribute.id] = [finalValue];
                  });
                  _saveValues();
                },
                child: const Text('انتخاب'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSingleOptionPicker(ProductAttribute attribute, String? currentValue) {
    // برای color از color picker استفاده می‌کنیم
    if (attribute.dataType == AttributeDataType.color) {
      _showColorPickerDialog(attribute, currentValue);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String? selectedValue = currentValue;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(attribute.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: (attribute.options ?? []).map((option) {
                  return RadioListTile<String>(
                    title: Text(option.label),
                    value: option.value,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      setState(() => selectedValue = value);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.setState(() {
                    _productAttributeValues[attribute.id] = selectedValue != null ? [selectedValue!] : [];
                  });
                  _saveValues();
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMultiColorPickerDialog(ProductAttribute attribute, List<String> currentValues) {
    List<Color> selectedColors = [];
    Map<String, String> colorLabels = {}; // ذخیره label برای هر رنگ
    
    // Parse current colors
    for (var value in currentValues) {
      try {
        if (value.contains('|')) {
          final parts = value.split('|');
          final hexColor = parts[0];
          selectedColors.add(Color(int.parse(hexColor.replaceFirst('#', '0xFF'))));
          if (parts.length == 2) {
            colorLabels[hexColor] = parts[1];
          }
        } else {
          selectedColors.add(Color(int.parse(value.replaceFirst('#', '0xFF'))));
        }
      } catch (e) {
        // Skip invalid colors
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        List<Color> colors = List.from(selectedColors);
        Color pickerColor = Colors.blue;
        final colorLabelController = TextEditingController();
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(attribute.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // رنگ‌های انتخاب شده
                  if (colors.isNotEmpty) ...[
                    const Text('رنگ‌های انتخاب شده:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((color) => Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() => colors.remove(color));
                              },
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  // Color Picker
                  const Text('افزودن رنگ جدید:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (color) {
                      setState(() => pickerColor = color);
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    paletteType: PaletteType.hsvWithHue,
                    pickerAreaHeightPercent: 0.6,
                  ),
                  const SizedBox(height: 12),
                  // فیلد عنوان برای رنگ جدید
                  TextField(
                    controller: colorLabelController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان رنگ (نمایشی)',
                      hintText: 'مثلاً: قرمز، آبی، ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!colors.contains(pickerColor)) {
                        setState(() => colors.add(pickerColor));
                        // ذخیره label همراه با رنگ
                        final label = colorLabelController.text.trim();
                        if (label.isNotEmpty) {
                          final hexColor = '#${pickerColor.value.toRadixString(16).substring(2).toUpperCase()}';
                          colorLabels[hexColor] = label;
                        }
                        colorLabelController.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن این رنگ'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // تبدیل به hex strings با label
                  final hexColors = colors.map((color) {
                    final hexColor = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    final label = colorLabels[hexColor];
                    return label != null && label.isNotEmpty ? '$hexColor|$label' : hexColor;
                  }).toList();
                  
                  // ذخیره
                  this.setState(() {
                    _productAttributeValues[attribute.id] = hexColors;
                  });
                  _saveValues();
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMultiOptionPicker(ProductAttribute attribute, List<String> currentValues) {
    // برای color از multi color picker استفاده می‌کنیم
    if (attribute.dataType == AttributeDataType.color) {
      _showMultiColorPickerDialog(attribute, currentValues);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        Set<String> selectedValues = Set<String>.from(currentValues);
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(attribute.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: (attribute.options ?? []).map((option) {
                  final isSelected = selectedValues.contains(option.value);
                  
                  return CheckboxListTile(
                    title: Text(option.label),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedValues.add(option.value);
                        } else {
                          selectedValues.remove(option.value);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.setState(() {
                    _productAttributeValues[attribute.id] = selectedValues.toList();
                  });
                  _saveValues();
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBooleanPicker(ProductAttribute attribute, bool currentValue) {
    showDialog(
      context: context,
      builder: (context) {
        bool selectedValue = currentValue;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(attribute.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: const Text('بله'),
                  value: true,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setState(() => selectedValue = value!);
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('خیر'),
                  value: false,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setState(() => selectedValue = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.setState(() {
                    _productAttributeValues[attribute.id] = [selectedValue.toString()];
                  });
                  _saveValues();
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDatePicker(ProductAttribute attribute, String? currentValue) async {
    final now = DateTime.now();
    final initialDate = currentValue != null ? DateTime.tryParse(currentValue) ?? now : now;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _productAttributeValues[attribute.id] = [picked.toIso8601String().split('T')[0]];
      });
      _saveValues();
    }
  }

  void _showSingleTextInput(ProductAttribute attribute, String? currentValue) {
    // Parse current value (format: "value|label")
    String value = '';
    String label = '';
    
    if (currentValue != null && currentValue.contains('|')) {
      final parts = currentValue.split('|');
      value = parts[0];
      label = parts.length > 1 ? parts[1] : parts[0];
    } else if (currentValue != null) {
      value = currentValue;
      label = currentValue;
    }
    
    final valueController = TextEditingController(text: value);
    final labelController = TextEditingController(text: label);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attribute.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مقدار و عنوان را وارد کنید:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              keyboardType: attribute.dataType == AttributeDataType.number
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: 'مقدار',
                hintText: attribute.dataType == AttributeDataType.number ? '100' : 'مثال: XL',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'عنوان (نمایشی)',
                hintText: attribute.dataType == AttributeDataType.number ? 'صد واحد' : 'بزرگ',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final val = valueController.text.trim();
              final lbl = labelController.text.trim();
              
              setState(() {
                if (val.isNotEmpty) {
                  // ذخیره به فرمت "value|label"
                  _productAttributeValues[attribute.id] = ['$val|${lbl.isNotEmpty ? lbl : val}'];
                } else {
                  _productAttributeValues[attribute.id] = [];
                }
              });
              _saveValues();
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  void _showMultiTextInput(ProductAttribute attribute, List<String> currentValues) {
    // Parse current values (format: "value|label")
    final entries = currentValues.map((v) {
      if (v.contains('|')) {
        final parts = v.split('|');
        return {'value': parts[0], 'label': parts.length > 1 ? parts[1] : parts[0]};
      }
      return {'value': v, 'label': v};
    }).toList();

    final valueControllers = entries.map((e) => TextEditingController(text: e['value'])).toList();
    final labelControllers = entries.map((e) => TextEditingController(text: e['label'])).toList();
    
    if (valueControllers.isEmpty) {
      valueControllers.add(TextEditingController());
      labelControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(attribute.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مقدار و عنوان را وارد کنید:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ...valueControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final valueController = entry.value;
                  final labelController = labelControllers[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'مورد ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (valueControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    valueControllers.removeAt(index);
                                    labelControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valueController,
                          keyboardType: attribute.dataType == AttributeDataType.number
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'مقدار',
                            hintText: attribute.dataType == AttributeDataType.number ? '100' : 'مثال: XL',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: labelController,
                          decoration: InputDecoration(
                            labelText: 'عنوان (نمایشی)',
                            hintText: attribute.dataType == AttributeDataType.number ? 'صد واحد' : 'بزرگ',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      valueControllers.add(TextEditingController());
                      labelControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('افزودن مورد جدید'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {
                  final values = <String>[];
                  for (int i = 0; i < valueControllers.length; i++) {
                    final value = valueControllers[i].text.trim();
                    final label = labelControllers[i].text.trim();
                    if (value.isNotEmpty) {
                      // ذخیره به فرمت "value|label"
                      values.add('$value|${label.isNotEmpty ? label : value}');
                    }
                  }
                  _productAttributeValues[attribute.id] = values;
                });
                _saveValues();
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // بخش ویژگی‌ها
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      )
                    : _assignedAttributes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.label_outline,
                                  size: 64,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'هنوز ویژگی‌ای اضافه نشده',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'با دکمه + ویژگی اضافه کنید',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom: 80,
                            ),
                            itemCount: _assignedAttributes.length,
                            itemBuilder: (context, index) {
                              final attribute = _assignedAttributes[index];
                              return _buildAttributeCard(attribute, theme);
                            },
                          ),
          ),
          
          // بخش تنوع محصول
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_mosaic,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تنوع محصول',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: widget.hasVariants,
                        onChanged: (value) => widget.onHasVariantsChanged(value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.hasVariants) ...[
                    Text(
                      'برای مدیریت کامل تنوع‌ها، ابتدا ویژگی‌ها را تعریف کنید',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _assignedAttributes.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VariantsManagementPage(
                                    productId: widget.productId,
                                    productName: widget.productName,
                                    businessId: widget.businessId,
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('مدیریت تنوع‌ها'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ] else
                    Text(
                      'برای استفاده از تنوع محصول، کلید بالا را فعال کنید',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAttribute,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: const _CustomFabLocation(),
    );
  }

  Widget _buildAttributeCard(ProductAttribute attribute, ThemeData theme) {
    final values = _productAttributeValues[attribute.id] ?? [];
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
          child: Icon(
            _getAttributeIcon(attribute.dataType),
            color: isDark ? Colors.blue.shade100 : Colors.blue.shade800,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(attribute.name)),
            if (attribute.required)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'الزامی',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade900),
                ),
              ),
          ],
        ),
        subtitle: _buildFormattedValues(attribute, values),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editAttributeValue(attribute),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _removeAttribute(attribute),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormattedValues(ProductAttribute attribute, List<String> values) {
    if (values.isEmpty) {
      return const Text('مقدار تنظیم نشده');
    }

    // برای رنگ، نمایش رنگ‌ها با دایره رنگی و label
    if (attribute.dataType == AttributeDataType.color) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: values.map((value) {
          // Parse value|label format
          String hexValue = value;
          String? label;
          if (value.contains('|')) {
            final parts = value.split('|');
            hexValue = parts[0];
            if (parts.length == 2) {
              label = parts[1];
            }
          }
          
          // Parse color directly from hex value
          Color color;
          try {
            // Handle both #FF0000 and FF0000 formats
            final cleanValue = hexValue.replaceAll('#', '');
            color = Color(int.parse('FF$cleanValue', radix: 16));
          } catch (e) {
            print('❌ Failed to parse color: $hexValue, error: $e');
            color = Colors.grey;
          }
          
          // دایره رنگی همراه با label (اگر وجود داشت)
          return label != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                )
              : Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                );
        }).toList(),
      );
    }
    
    // برای select، نمایش label به جای value
    if (attribute.dataType == AttributeDataType.select && attribute.options != null) {
      final labels = values.map((value) {
        final option = attribute.options!.firstWhere(
          (opt) => opt.value == value,
          orElse: () => attribute.options!.first,
        );
        return option.label;
      }).join(', ');
      return Text(labels);
    }
    
    // برای boolean، نمایش بله/خیر
    if (attribute.dataType == AttributeDataType.boolean) {
      final boolValue = values.isNotEmpty && values.first == 'true';
      return Text(boolValue ? 'بله' : 'خیر');
    }
    
    // برای تاریخ، فرمت شمسی (اگه نیاز باشه)
    if (attribute.dataType == AttributeDataType.date) {
      return Text(values.join(', '));
    }
    
    // برای text و number - نمایش label اگر موجود باشد، وگرنه value
    final displayValues = values.map((v) {
      if (v.contains('|')) {
        final parts = v.split('|');
        return parts.length == 2 ? parts[1] : v; // label
      }
      return v; // value
    }).join(', ');
    
    return Text(displayValues);
  }

  IconData _getAttributeIcon(AttributeDataType type) {
    switch (type) {
      case AttributeDataType.text:
        return Icons.text_fields;
      case AttributeDataType.number:
        return Icons.numbers;
      case AttributeDataType.select:
        return Icons.list;
      case AttributeDataType.color:
        return Icons.palette;
      case AttributeDataType.boolean:
        return Icons.toggle_on;
      case AttributeDataType.date:
        return Icons.calendar_today;
    }
  }
}class _AttributePickerDialog extends StatelessWidget {
  final List<ProductAttribute> attributes;
  final Function(ProductAttribute) onSelect;

  const _AttributePickerDialog({
    required this.attributes,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('انتخاب ویژگی'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: attributes.length,
          itemBuilder: (context, index) {
            final attr = attributes[index];
            return ListTile(
              title: Text(attr.name),
              subtitle: Text(_getScopeLabel(attr.scope)),
              trailing: attr.required
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'الزامی',
                        style: TextStyle(fontSize: 10, color: Colors.red.shade900),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                onSelect(attr);
              },
            );
          },
        ),
      ),
    );
  }

  String _getScopeLabel(AttributeScope scope) {
    switch (scope) {
      case AttributeScope.productLevel:
        return 'سطح محصول';
      case AttributeScope.variantLevel:
        return 'سطح تنوع';
    }
  }
}
