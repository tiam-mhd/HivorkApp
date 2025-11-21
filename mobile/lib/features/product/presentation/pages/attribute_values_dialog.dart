import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/attribute_variant_theme.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';

/// Dialog for defining attribute values for a specific product
/// Shows different input types based on attribute data type
class AttributeValuesDialog extends StatefulWidget {
  final ProductAttribute attribute;
  final List<String> initialValues;
  final Function(List<String>) onSaved;

  const AttributeValuesDialog({
    Key? key,
    required this.attribute,
    required this.initialValues,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<AttributeValuesDialog> createState() => _AttributeValuesDialogState();
}

class _AttributeValuesDialogState extends State<AttributeValuesDialog> {
  late List<String> _values;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _values = List.from(widget.initialValues);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addValue(String value) {
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مقدار نمی‌تواند خالی باشد')),
      );
      return;
    }

    if (_values.contains(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این مقدار قبلاً اضافه شده')),
      );
      return;
    }

    setState(() {
      _values.add(value);
      _inputController.clear();
    });
  }

  void _removeValue(String value) {
    setState(() {
      _values.remove(value);
    });
  }

  void _save() {
    if (_values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل یک مقدار باید تعریف شود')),
      );
      return;
    }

    print('💾 [ATTRIBUTE_VALUES_DIALOG] Saving ${_values.length} values: $_values');
    
    // Return values through Navigator.pop
    Navigator.pop(context, _values);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AttributeVariantTheme.getDataTypeColor(
                  widget.attribute.dataType,
                  isDark: context.isDarkMode,
                ).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AttributeVariantTheme.getDataTypeColor(
                        widget.attribute.dataType,
                        isDark: context.isDarkMode,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AttributeVariantTheme.getDataTypeIcon(
                        widget.attribute.dataType,
                      ),
                      color: AttributeVariantTheme.getDataTypeColor(
                        widget.attribute.dataType,
                        isDark: context.isDarkMode,
                      ),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تعریف مقادیر: ${widget.attribute.name}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.attribute.dataType.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
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
              child: Column(
                children: [
                  // Input Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildInputSection(theme),
                  ),

                  const Divider(height: 1),

                  // Values List
                  Expanded(
                    child: _values.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 64,
                                  color: context.textSecondary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'هیچ مقداری تعریف نشده',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'از بخش بالا مقادیر را اضافه کنید',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _values.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final value = _values[index];
                              return _buildValueCard(value, theme);
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: context.textSecondary.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('ذخیره (${_values.length} مقدار)'),
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

  Widget _buildInputSection(ThemeData theme) {
    switch (widget.attribute.dataType) {
      case AttributeDataType.color:
        return _buildColorInput(theme);
      case AttributeDataType.select:
      case AttributeDataType.text:
      case AttributeDataType.number:
      default:
        return _buildTextInput(theme);
    }
  }

  Widget _buildTextInput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'افزودن مقدار جدید',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: widget.attribute.dataType ==
                              AttributeDataType.number
                          ? 'مثال: 42'
                          : 'مثال: قرمز، S، پنبه',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        AttributeVariantTheme.getDataTypeIcon(
                          widget.attribute.dataType,
                        ),
                      ),
                    ),
                    keyboardType: widget.attribute.dataType ==
                            AttributeDataType.number
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: widget.attribute.dataType ==
                            AttributeDataType.number
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : null,
                    onSubmitted: _addValue,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _addValue(_inputController.text.trim()),
                  icon: const Icon(Icons.add),
                  label: const Text('افزودن'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorInput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'افزودن رنگ جدید',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showColorPicker(context),
              icon: const Icon(Icons.palette),
              label: const Text('انتخاب رنگ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color selectedColor = Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انتخاب رنگ'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              final hexColor =
                  '#${selectedColor.value.toRadixString(16).substring(2)}';
              Navigator.pop(context);
              _addValue(hexColor);
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(String value, ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Value display based on type
            if (widget.attribute.dataType == AttributeDataType.color) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(value),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.textSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AttributeVariantTheme.getDataTypeColor(
                    widget.attribute.dataType,
                    isDark: context.isDarkMode,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AttributeVariantTheme.getDataTypeIcon(
                    widget.attribute.dataType,
                  ),
                  size: 20,
                  color: AttributeVariantTheme.getDataTypeColor(
                    widget.attribute.dataType,
                    isDark: context.isDarkMode,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: context.errorColor,
              onPressed: () => _removeValue(value),
              tooltip: 'حذف',
            ),
          ],
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
}
