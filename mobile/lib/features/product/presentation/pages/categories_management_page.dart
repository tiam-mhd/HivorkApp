import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/product_category.dart';
import '../../data/services/category_api_service.dart';
import '../bloc/category_bloc.dart';
import 'category_form_dialog.dart';

class CategoriesManagementPage extends StatefulWidget {
  final String businessId;

  const CategoriesManagementPage({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  State<CategoriesManagementPage> createState() => _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  late CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _categoryBloc = CategoryBloc(CategoryApiService(dio));
    _categoryBloc.add(LoadCategories(widget.businessId));
  }

  @override
  void dispose() {
    _categoryBloc.close();
    super.dispose();
  }

  void _showCategoryForm({ProductCategory? category, ProductCategory? parent}) {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        businessId: widget.businessId,
        category: category,
        parentCategory: parent,
        onSaved: () {
          _categoryBloc.add(LoadCategories(widget.businessId));
        },
      ),
    );
  }

  void _deleteCategory(ProductCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف دسته‌بندی'),
        content: Text(
          category.hasChildren
              ? 'آیا از حذف "${category.name}" و تمام زیردسته‌های آن اطمینان دارید؟'
              : 'آیا از حذف "${category.name}" اطمینان دارید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _categoryBloc.add(DeleteCategory(category.id, widget.businessId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _categoryBloc,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'مدیریت دسته‌بندی محصولات',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocConsumer<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is CategoryOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _categoryBloc.add(LoadCategories(widget.businessId));
            }
          },
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoryLoaded) {
              if (state.categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'هیچ دسته‌بندی وجود ندارد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اولین دسته‌بندی خود را ایجاد کنید',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: state.categories.map((category) {
                  return _buildCategoryTree(category, theme, 0);
                }).toList(),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCategoryForm(),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('افزودن دسته‌بندی'),
        ),
      ),
    );
  }

  Widget _buildCategoryTree(ProductCategory category, ThemeData theme, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            right: level * 20.0,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color != null
                    ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
                    : theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconData(category.icon),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: category.description != null
                ? Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add Subcategory
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  onPressed: () => _showCategoryForm(parent: category),
                  tooltip: 'افزودن زیردسته',
                ),
                // Edit
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                  onPressed: () => _showCategoryForm(category: category),
                  tooltip: 'ویرایش',
                ),
                // Delete
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onPressed: () => _deleteCategory(category),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ),
        ),
        if (category.hasChildren)
          ...category.children!.map((child) {
            return _buildCategoryTree(child, theme, level + 1);
          }).toList(),
      ],
    );
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.category;
    
    final iconMap = {
      'devices': Icons.devices,
      'food': Icons.restaurant,
      'fashion': Icons.checkroom,
      'home': Icons.home,
      'sports': Icons.sports_soccer,
      'books': Icons.book,
      'toys': Icons.toys,
      'health': Icons.health_and_safety,
      'beauty': Icons.face,
      'auto': Icons.directions_car,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }
}
