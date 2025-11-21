import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/attribute_variant_theme.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';
import '../../data/services/attribute_api_service.dart';
import '../../data/services/product_attribute_value_api_service.dart';
import '../pages/attribute_values_dialog.dart';

/// Widget for selecting which attributes this product should have
/// Shows list of business attributes with checkboxes
class ProductAttributeSelector extends StatefulWidget {
  final String productId;
  final String businessId;
  final List<String> selectedAttributeIds;
  final Function(List<ProductAttribute>) onAttributesSelected;
  final Function(Map<String, List<String>>)? onGenerateVariants;

  const ProductAttributeSelector({
    Key? key,
    required this.productId,
    required this.businessId,
    required this.selectedAttributeIds,
    required this.onAttributesSelected,
    this.onGenerateVariants,
  }) : super(key: key);

  @override
  State<ProductAttributeSelector> createState() =>
      _ProductAttributeSelectorState();
}

class _ProductAttributeSelectorState extends State<ProductAttributeSelector> {
  late AttributeApiService _attributeService;
  late ProductAttributeValueApiService _attributeValueService;
  List<ProductAttribute> _businessAttributes = [];
  Set<String> _selectedIds = {};
  Map<String, List<String>> _attributeValues = {}; // Store values for each attribute
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _attributeService = AttributeApiService(dio);
    _attributeValueService = ProductAttributeValueApiService(dio);
    _selectedIds = Set.from(widget.selectedAttributeIds);
    _loadBusinessAttributes();
    _loadExistingAttributeValues();
  }

  Future<void> _loadExistingAttributeValues() async {
    try {
      print('🔍 [ATTRIBUTE_SELECTOR] Loading existing attribute values...');
      final values = await _attributeValueService.getProductAttributeValues(
        widget.productId,
      );
      
      setState(() {
        _attributeValues = values;
        // Add attribute IDs to selected set if they have values
        _selectedIds.addAll(values.keys);
      });
      
      print('✅ [ATTRIBUTE_SELECTOR] Loaded ${values.length} attribute values');
      print('✅ [ATTRIBUTE_SELECTOR] Selected IDs: $_selectedIds');
      
      // Notify parent with selected attributes
      final selected = _businessAttributes
          .where((a) => _selectedIds.contains(a.id))
          .toList();
      if (selected.isNotEmpty) {
        widget.onAttributesSelected(selected);
      }
    } catch (e) {
      print('⚠️ [ATTRIBUTE_SELECTOR] Error loading existing values: $e');
      // Don't show error to user, just continue with empty values
    }
  }

  Future<void> _loadBusinessAttributes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _attributeService.getAttributes(
        businessId: widget.businessId,
        scope: AttributeScope.variantLevel,
        isActive: true,
      );

      setState(() {
        _businessAttributes = result['data'] as List<ProductAttribute>;
        _isLoading = false;
      });
      
      // After loading attributes, notify parent with already selected ones
      final selected = _businessAttributes
          .where((a) => _selectedIds.contains(a.id))
          .toList();
      if (selected.isNotEmpty) {
        widget.onAttributesSelected(selected);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleAttribute(ProductAttribute attr) async {
    final wasSelected = _selectedIds.contains(attr.id);
    
    if (wasSelected) {
      // Deselecting - remove values
      setState(() {
        _selectedIds.remove(attr.id);
        _attributeValues.remove(attr.id);
      });
      
      // Update server with remaining attribute values
      await _saveAttributeValuesToServer();
    } else {
      // Selecting - show values dialog
      final values = await showDialog<List<String>>(
        context: context,
        builder: (context) => AttributeValuesDialog(
          attribute: attr,
          initialValues: _attributeValues[attr.id] ?? [],
          onSaved: (values) => values,
        ),
      );

      if (values != null && values.isNotEmpty) {
        setState(() {
          _selectedIds.add(attr.id);
          _attributeValues[attr.id] = values;
        });
        
        // Save to server immediately
        await _saveAttributeValuesToServer();
      } else {
        // User cancelled or didn't add values
        return;
      }
    }

    // Notify parent with selected attributes
    final selected = _businessAttributes
        .where((a) => _selectedIds.contains(a.id))
        .toList();
    widget.onAttributesSelected(selected);
  }

  Future<void> _saveAttributeValuesToServer() async {
    try {
      print('💾 [ATTRIBUTE_SELECTOR] Saving attribute values to server...');
      print('💾 [ATTRIBUTE_SELECTOR] Values: $_attributeValues');
      
      await _attributeValueService.setProductAttributeValues(
        widget.productId,
        _attributeValues,
      );
      
      print('✅ [ATTRIBUTE_SELECTOR] Attribute values saved successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مقادیر ویژگی‌ها با موفقیت ذخیره شد'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_SELECTOR] Error saving: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ذخیره: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _canGenerateVariants() {
    // Check if all selected attributes have values defined
    if (_selectedIds.isEmpty) return false;
    
    for (final id in _selectedIds) {
      if (_attributeValues[id] == null || _attributeValues[id]!.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  void _generateVariants() async {
    if (!_canGenerateVariants()) return;
    
    // Calculate total combinations
    int totalCombinations = 1;
    for (final id in _selectedIds) {
      totalCombinations *= _attributeValues[id]!.length;
    }

    // Confirm with user
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تولید خودکار ترکیبات'),
        content: Text(
          'با توجه به ویژگی‌های انتخاب شده، $totalCombinations ترکیب ایجاد خواهد شد.\n\n'
          'آیا مطمئن هستید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تولید'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onGenerateVariants != null) {
      widget.onGenerateVariants!(_attributeValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.errorColor),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBusinessAttributes,
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }

    if (_businessAttributes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'ویژگی‌ای تعریف نشده',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'ابتدا از بخش مدیریت ویژگی‌ها، ویژگی‌های متغیر مانند رنگ، سایز و... را تعریف کنید',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'انتخاب ویژگی‌های محصول',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'این محصول کدام ویژگی‌ها را دارد؟',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_selectedIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedIds.length} ویژگی',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _canGenerateVariants()
                          ? _generateVariants
                          : null,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('تولید خودکار ترکیبات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _businessAttributes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final attr = _businessAttributes[index];
              final isSelected = _selectedIds.contains(attr.id);

              return Card(
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? theme.primaryColor
                        : context.textSecondary.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) => _toggleAttribute(attr),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AttributeVariantTheme.getDataTypeColor(
                            attr.dataType,
                            isDark: context.isDarkMode,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          AttributeVariantTheme.getDataTypeIcon(attr.dataType),
                          size: 20,
                          color: AttributeVariantTheme.getDataTypeColor(
                            attr.dataType,
                            isDark: context.isDarkMode,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attr.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              attr.code,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (isSelected && _attributeValues[attr.id] != null) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: _attributeValues[attr.id]!
                                    .take(3)
                                    .map((value) => _buildValueChip(value, attr, theme))
                                    .toList(),
                              ),
                              if (_attributeValues[attr.id]!.length > 3)
                                Text(
                                  '+${_attributeValues[attr.id]!.length - 3} دیگر',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected && _attributeValues[attr.id] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_attributeValues[attr.id]!.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      _buildDataTypeBadge(attr.dataType, theme),
                    ],
                  ),
                  subtitle: attr.description != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8, right: 44),
                          child: Text(
                            attr.description!,
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: theme.primaryColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildValueChip(String value, ProductAttribute attr, ThemeData theme) {
    if (attr.dataType == AttributeDataType.color) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _parseColor(value),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: context.textSecondary.withOpacity(0.3),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AttributeVariantTheme.getDataTypeColor(
          attr.dataType,
          isDark: context.isDarkMode,
        ).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 10,
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  Widget _buildDataTypeBadge(AttributeDataType dataType, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AttributeVariantTheme.getDataTypeColor(
          dataType,
          isDark: context.isDarkMode,
        ).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        dataType.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AttributeVariantTheme.getDataTypeColor(
            dataType,
            isDark: context.isDarkMode,
          ),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
