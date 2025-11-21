import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/attribute_variant_theme.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';
import '../../data/services/attribute_api_service.dart';

class AttributeFormDialog extends StatefulWidget {
  final String businessId;
  final ProductAttribute? attribute;
  final VoidCallback onSaved;

  const AttributeFormDialog({
    Key? key,
    required this.businessId,
    this.attribute,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<AttributeFormDialog> createState() => _AttributeFormDialogState();
}

class _AttributeFormDialogState extends State<AttributeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameEnController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _helpTextController;
  
  late AttributeDataType _dataType;
  late AttributeCardinality _cardinality;
  late AttributeScope _scope;
  bool _isRequired = false;
  bool _isActive = true;
  bool _allowCustomValue = false;
  
  // Options removed - values will be defined at product level
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final attr = widget.attribute;
    
    _nameController = TextEditingController(text: attr?.name ?? '');
    _nameEnController = TextEditingController(text: attr?.nameEn ?? '');
    _codeController = TextEditingController(text: attr?.code ?? '');
    _descriptionController = TextEditingController(text: attr?.description ?? '');
    _helpTextController = TextEditingController(text: attr?.helpText ?? '');
    
    _dataType = attr?.dataType ?? AttributeDataType.text;
    _cardinality = attr?.cardinality ?? AttributeCardinality.single;
    _scope = attr?.scope ?? AttributeScope.variantLevel;
    _isRequired = attr?.required ?? false;
    _isActive = attr?.isActive ?? true;
    _allowCustomValue = attr?.allowCustomValue ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _helpTextController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = ServiceLocator().dio;
      final apiService = AttributeApiService(dio);

      final data = {
        'businessId': widget.businessId,
        'name': _nameController.text,
        'nameEn': _nameEnController.text.isNotEmpty ? _nameEnController.text : null,
        'code': _codeController.text,
        'dataType': _dataType.apiValue,
        'cardinality': _cardinality.apiValue,
        'scope': _scope.apiValue,
        'required': _isRequired,
        'isActive': _isActive,
        'allowCustomValue': _allowCustomValue,
        if (_descriptionController.text.isNotEmpty)
          'description': _descriptionController.text,
        if (_helpTextController.text.isNotEmpty)
          'helpText': _helpTextController.text,
      };

      if (widget.attribute != null) {
        await apiService.updateAttribute(widget.attribute!.id, data);
      } else {
        await apiService.createAttribute(data);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.attribute != null
                  ? 'ویژگی با موفقیت ویرایش شد'
                  : 'ویژگی با موفقیت ایجاد شد',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.attribute != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'ویرایش ویژگی' : 'افزودن ویژگی جدید',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      _SectionHeader(
                        icon: Icons.info_outline,
                        title: 'اطلاعات پایه',
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      
                      // Name (Persian)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'نام (فارسی) *',
                          hintText: 'مثال: رنگ، سایز، جنس',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'نام الزامی است';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Name En (English)
                      TextFormField(
                        controller: _nameEnController,
                        decoration: const InputDecoration(
                          labelText: 'نام انگلیسی',
                          hintText: 'Color, Size, Material',
                          prefixIcon: Icon(Icons.abc),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Code
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'کد (انگلیسی) *',
                          hintText: 'color, size, material',
                          helperText: 'فقط حروف انگلیسی کوچک، اعداد و خط تیره',
                          prefixIcon: Icon(Icons.code),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_-]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'کد الزامی است';
                          }
                          if (!RegExp(r'^[a-z][a-z0-9_-]*$').hasMatch(value)) {
                            return 'فرمت نامعتبر - باید با حرف شروع شود';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'توضیحات',
                          hintText: 'توضیح کوتاه درباره این ویژگی',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      // Help Text
                      TextFormField(
                        controller: _helpTextController,
                        decoration: const InputDecoration(
                          labelText: 'متن راهنما',
                          hintText: 'راهنمایی برای کاربر',
                          prefixIcon: Icon(Icons.help_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Help Text
                      TextFormField(
                        controller: _helpTextController,
                        decoration: const InputDecoration(
                          labelText: 'متن راهنما',
                          hintText: 'راهنمایی برای کاربر',
                          prefixIcon: Icon(Icons.help_outline),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Type Configuration Section
                      _SectionHeader(
                        icon: Icons.settings,
                        title: 'پیکربندی نوع',
                        color: context.secondaryColor,
                      ),
                      const SizedBox(height: 12),
                      
                      // Data Type
                      DropdownButtonFormField<AttributeDataType>(
                        value: _dataType,
                        decoration: const InputDecoration(
                          labelText: 'نوع داده *',
                          prefixIcon: Icon(Icons.data_object),
                        ),
                        items: AttributeDataType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  AttributeVariantTheme.getDataTypeIcon(type),
                                  size: 20,
                                  color: AttributeVariantTheme.getDataTypeColor(
                                    type,
                                    isDark: context.isDarkMode,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(type.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _dataType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Cardinality
                      DropdownButtonFormField<AttributeCardinality>(
                        value: _cardinality,
                        decoration: const InputDecoration(
                          labelText: 'تعداد مقادیر *',
                          helperText: 'تک‌انتخابی یا چندانتخابی',
                          prefixIcon: Icon(Icons.filter_list),
                        ),
                        items: AttributeCardinality.values.map((card) {
                          return DropdownMenuItem(
                            value: card,
                            child: Row(
                              children: [
                                Icon(
                                  AttributeVariantTheme.getCardinalityIcon(card),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(card.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _cardinality = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Scope
                      DropdownButtonFormField<AttributeScope>(
                        value: _scope,
                        decoration: const InputDecoration(
                          labelText: 'محدوده استفاده *',
                          helperText: 'ثابت (سطح محصول) یا متغیر (سطح Variant)',
                          prefixIcon: Icon(Icons.layers),
                        ),
                        items: AttributeScope.values.map((scope) {
                          return DropdownMenuItem(
                            value: scope,
                            child: Row(
                              children: [
                                Icon(
                                  AttributeVariantTheme.getScopeIcon(scope),
                                  size: 20,
                                  color: AttributeVariantTheme.getScopeColor(
                                    scope,
                                    isDark: context.isDarkMode,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(scope.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _scope = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Settings Section
                      _SectionHeader(
                        icon: Icons.tune,
                        title: 'تنظیمات',
                        color: context.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      
                      // Switches
                      SwitchListTile(
                        title: const Text('الزامی'),
                        subtitle: const Text('این ویژگی باید حتماً مقدار داشته باشد'),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value;
                          });
                        },
                      ),
                      if (_dataType == AttributeDataType.select)
                        SwitchListTile(
                          title: const Text('اجازه مقدار دلخواه'),
                          subtitle: const Text('کاربر می‌تواند مقدار دلخواه وارد کند'),
                          value: _allowCustomValue,
                          onChanged: (value) {
                            setState(() {
                              _allowCustomValue = value;
                            });
                          },
                        ),
                      SwitchListTile(
                        title: const Text('فعال'),
                        subtitle: const Text('وضعیت فعال/غیرفعال این ویژگی'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: Border(
                  top: BorderSide(
                    color: context.textSecondary.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('انصراف'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'ذخیره تغییرات' : 'ایجاد ویژگی'),
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
// SECTION HEADER WIDGET
// ============================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
