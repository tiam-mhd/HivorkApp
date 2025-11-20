import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/product_category.dart';
import '../../data/services/category_api_service.dart';

class CategoryFormDialog extends StatefulWidget {
  final String businessId;
  final ProductCategory? category;
  final ProductCategory? parentCategory;
  final VoidCallback onSaved;

  const CategoryFormDialog({
    Key? key,
    required this.businessId,
    this.category,
    this.parentCategory,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameEnController;
  late TextEditingController _descriptionController;
  
  String? _selectedIcon;
  String? _selectedColor;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'devices', 'icon': Icons.devices, 'label': 'الکترونیک'},
    {'name': 'food', 'icon': Icons.restaurant, 'label': 'مواد غذایی'},
    {'name': 'fashion', 'icon': Icons.checkroom, 'label': 'پوشاک'},
    {'name': 'home', 'icon': Icons.home, 'label': 'خانه'},
    {'name': 'sports', 'icon': Icons.sports_soccer, 'label': 'ورزشی'},
    {'name': 'books', 'icon': Icons.book, 'label': 'کتاب'},
    {'name': 'toys', 'icon': Icons.toys, 'label': 'اسباب بازی'},
    {'name': 'health', 'icon': Icons.health_and_safety, 'label': 'بهداشتی'},
    {'name': 'beauty', 'icon': Icons.face, 'label': 'آرایشی'},
    {'name': 'auto', 'icon': Icons.directions_car, 'label': 'خودرو'},
  ];

  final List<String> _colors = [
    '#2196F3', '#4CAF50', '#FF9800', '#F44336',
    '#9C27B0', '#00BCD4', '#FFEB3B', '#795548',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _nameEnController = TextEditingController(text: widget.category?.nameEn ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
    _selectedIcon = widget.category?.icon ?? 'devices';
    _selectedColor = widget.category?.color ?? '#2196F3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = ServiceLocator().dio;
      final apiService = CategoryApiService(dio);

      final data = {
        'name': _nameController.text,
        'nameEn': _nameEnController.text.isNotEmpty ? _nameEnController.text : null,
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        'icon': _selectedIcon,
        'color': _selectedColor,
        'businessId': widget.businessId,
        if (widget.parentCategory != null) 'parentId': widget.parentCategory!.id,
      };

      if (widget.category != null) {
        await apiService.updateCategory(widget.category!.id, widget.businessId, data);
      } else {
        await apiService.createCategory(data);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
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
    final isEdit = widget.category != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  isEdit ? 'ویرایش دسته‌بندی' : 'افزودن دسته‌بندی',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (widget.parentCategory != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.subdirectory_arrow_right, size: 16, color: theme.colorScheme.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          'زیردسته: ${widget.parentCategory!.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام دسته‌بندی *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'نام دسته‌بندی الزامی است';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Name En
                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'نام انگلیسی',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Icon Selection
                Text(
                  'آیکون',
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
                  children: _icons.map((iconData) {
                    final isSelected = _selectedIcon == iconData['name'];
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = iconData['name']),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconData['icon'],
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Color Selection
                Text(
                  'رنگ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colors.map((color) {
                    final isSelected = _selectedColor == color;
                    return InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
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
                          : Text(isEdit ? 'ذخیره' : 'افزودن'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
