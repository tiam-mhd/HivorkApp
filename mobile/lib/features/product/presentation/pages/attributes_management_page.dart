import 'package:flutter/material.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/attribute_variant_theme.dart';
import '../../data/models/attribute_enums.dart';
import '../../data/models/product_attribute.dart';
import '../../data/services/attribute_api_service.dart';
import '../../../../core/di/service_locator.dart';
import 'attribute_form_dialog.dart';

class AttributesManagementPage extends StatefulWidget {
  final String businessId;

  const AttributesManagementPage({Key? key, required this.businessId})
    : super(key: key);

  @override
  State<AttributesManagementPage> createState() =>
      _AttributesManagementPageState();
}

class _AttributesManagementPageState extends State<AttributesManagementPage> {
  late AttributeApiService _attributeService;
  List<ProductAttribute> _attributes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  AttributeDataType? _filterDataType;
  AttributeCardinality? _filterCardinality;
  AttributeScope? _filterScope;
  bool? _filterIsActive;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _attributeService = AttributeApiService(dio);
    _loadAttributes();
  }

  Future<void> _loadAttributes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _attributeService.getAttributes(
        businessId: widget.businessId,
        dataType: _filterDataType,
        cardinality: _filterCardinality,
        scope: _filterScope,
        isActive: _filterIsActive,
      );

      setState(() {
        _attributes = result['data'] as List<ProductAttribute>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ProductAttribute> get _filteredAttributes {
    if (_searchQuery.isEmpty) return _attributes;

    return _attributes.where((attr) {
      return attr.name.contains(_searchQuery) ||
          attr.code.contains(_searchQuery) ||
          (attr.nameEn?.contains(_searchQuery) ?? false) ||
          attr.description?.contains(_searchQuery) == true;
    }).toList();
  }

  void _showAttributeForm({ProductAttribute? attribute}) {
    showDialog(
      context: context,
      builder: (context) => AttributeFormDialog(
        businessId: widget.businessId,
        attribute: attribute,
        onSaved: _loadAttributes,
      ),
    );
  }

  void _deleteAttribute(ProductAttribute attribute) {
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
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _attributeService.deleteAttribute(attribute.id);
                _loadAttributes();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ویژگی با موفقیت حذف شد')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: ${e.toString()}')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _toggleActiveStatus(ProductAttribute attribute) async {
    try {
      await _attributeService.updateAttribute(attribute.id, {
        'isActive': !attribute.isActive,
      });
      _loadAttributes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              attribute.isActive ? 'ویژگی غیرفعال شد' : 'ویژگی فعال شد',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'مدیریت ویژگی‌های محصولات',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'فیلترها',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجوی ویژگی...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active Filters Chips
          if (_filterDataType != null ||
              _filterCardinality != null ||
              _filterScope != null ||
              _filterIsActive != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_filterDataType != null)
                    _FilterChip(
                      label: 'نوع: ${_filterDataType!.displayName}',
                      onDeleted: () {
                        setState(() {
                          _filterDataType = null;
                        });
                        _loadAttributes();
                      },
                    ),
                  if (_filterCardinality != null)
                    _FilterChip(
                      label: 'تعداد: ${_filterCardinality!.displayName}',
                      onDeleted: () {
                        setState(() {
                          _filterCardinality = null;
                        });
                        _loadAttributes();
                      },
                    ),
                  if (_filterScope != null)
                    _FilterChip(
                      label: 'محدوده: ${_filterScope!.displayName}',
                      onDeleted: () {
                        setState(() {
                          _filterScope = null;
                        });
                        _loadAttributes();
                      },
                    ),
                  if (_filterIsActive != null)
                    _FilterChip(
                      label: _filterIsActive! ? 'فعال' : 'غیرفعال',
                      onDeleted: () {
                        setState(() {
                          _filterIsActive = null;
                        });
                        _loadAttributes();
                      },
                    ),
                ],
              ),
            ),

          // Attributes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: context.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'خطا در بارگذاری',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAttributes,
                          child: const Text('تلاش مجدد'),
                        ),
                      ],
                    ),
                  )
                : _filteredAttributes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 64,
                          color: context.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هیچ ویژگی‌ای یافت نشد',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'برای افزودن ویژگی جدید دکمه + را بزنید',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAttributes,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredAttributes.length,
                      itemBuilder: (context, index) {
                        final attribute = _filteredAttributes[index];
                        return _AttributeCard(
                          attribute: attribute,
                          onEdit: () =>
                              _showAttributeForm(attribute: attribute),
                          onDelete: () => _deleteAttribute(attribute),
                          onToggleActive: () => _toggleActiveStatus(attribute),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAttributeForm(),
        icon: const Icon(Icons.add),
        label: const Text('ویژگی جدید'),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        initialDataType: _filterDataType,
        initialCardinality: _filterCardinality,
        initialScope: _filterScope,
        initialIsActive: _filterIsActive,
        onApply: (dataType, cardinality, scope, isActive) {
          setState(() {
            _filterDataType = dataType;
            _filterCardinality = cardinality;
            _filterScope = scope;
            _filterIsActive = isActive;
          });
          _loadAttributes();
        },
      ),
    );
  }
}

// ============================================
// ATTRIBUTE CARD WIDGET
// ============================================

class _AttributeCard extends StatelessWidget {
  final ProductAttribute attribute;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _AttributeCard({
    required this.attribute,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  Color _parseColor(String colorCode) {
    try {
      final hex = colorCode.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Active Indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: attribute.isActive
                          ? context.variantActiveColor
                          : context.variantInactiveColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attribute.nameEn ?? attribute.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          attribute.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions Menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'toggle':
                          onToggleActive();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('ویرایش'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              attribute.isActive
                                  ? Icons.toggle_off
                                  : Icons.toggle_on,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              attribute.isActive ? 'غیرفعال کردن' : 'فعال کردن',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              if (attribute.description != null &&
                  attribute.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    attribute.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),

              // Badges Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AttributeVariantTheme.dataTypeBadge(
                    attribute.dataType,
                    context,
                  ),
                  AttributeVariantTheme.scopeBadge(attribute.scope, context),
                  _InfoBadge(
                    icon: AttributeVariantTheme.getCardinalityIcon(
                      attribute.cardinality,
                    ),
                    label: attribute.cardinality.displayName,
                    color: context.cardinalitySingleColor,
                  ),
                  if (attribute.required)
                    _InfoBadge(
                      icon: Icons.star,
                      label: 'الزامی',
                      color: context.errorColor,
                    ),
                ],
              ),

              // Options Preview (for select & color types)
              if ((attribute.dataType == AttributeDataType.select || 
                   attribute.dataType == AttributeDataType.color) &&
                  attribute.options != null &&
                  attribute.options!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'گزینه‌ها:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            attribute.options!.take(5).map((option) {
                              // برای رنگ، فقط دایره رنگی + نام
                              if (attribute.dataType == AttributeDataType.color && 
                                  option.color != null) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.surfaceColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: context.textSecondary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: _parseColor(option.color!),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark 
                                              ? Colors.grey.shade600 
                                              : Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        option.label,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              // برای بقیه، فقط label
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.surfaceColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: context.textSecondary.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  option.label,
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }).toList()..addAll([
                              if (attribute.options!.length > 5)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    '+${attribute.options!.length - 5}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ),
                            ]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// INFO BADGE WIDGET
// ============================================

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// FILTER CHIP WIDGET
// ============================================

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }
}

// ============================================
// FILTER DIALOG
// ============================================

class _FilterDialog extends StatefulWidget {
  final AttributeDataType? initialDataType;
  final AttributeCardinality? initialCardinality;
  final AttributeScope? initialScope;
  final bool? initialIsActive;
  final Function(
    AttributeDataType?,
    AttributeCardinality?,
    AttributeScope?,
    bool?,
  )
  onApply;

  const _FilterDialog({
    required this.initialDataType,
    required this.initialCardinality,
    required this.initialScope,
    required this.initialIsActive,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  AttributeDataType? _dataType;
  AttributeCardinality? _cardinality;
  AttributeScope? _scope;
  bool? _isActive;

  @override
  void initState() {
    super.initState();
    _dataType = widget.initialDataType;
    _cardinality = widget.initialCardinality;
    _scope = widget.initialScope;
    _isActive = widget.initialIsActive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('فیلتر ویژگی‌ها'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Type Filter
            const Text(
              'نوع داده:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('همه'),
                  selected: _dataType == null,
                  onSelected: (selected) {
                    setState(() {
                      _dataType = null;
                    });
                  },
                ),
                ...AttributeDataType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: _dataType == type,
                    onSelected: (selected) {
                      setState(() {
                        _dataType = selected ? type : null;
                      });
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // Cardinality Filter
            const Text(
              'تعداد مقادیر:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('همه'),
                  selected: _cardinality == null,
                  onSelected: (selected) {
                    setState(() {
                      _cardinality = null;
                    });
                  },
                ),
                ...AttributeCardinality.values.map((card) {
                  return ChoiceChip(
                    label: Text(card.displayName),
                    selected: _cardinality == card,
                    onSelected: (selected) {
                      setState(() {
                        _cardinality = selected ? card : null;
                      });
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // Scope Filter
            const Text(
              'محدوده:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('همه'),
                  selected: _scope == null,
                  onSelected: (selected) {
                    setState(() {
                      _scope = null;
                    });
                  },
                ),
                ...AttributeScope.values.map((scope) {
                  return ChoiceChip(
                    label: Text(scope.displayName),
                    selected: _scope == scope,
                    onSelected: (selected) {
                      setState(() {
                        _scope = selected ? scope : null;
                      });
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // Active Status Filter
            const Text('وضعیت:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('همه'),
                  selected: _isActive == null,
                  onSelected: (selected) {
                    setState(() {
                      _isActive = null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('فعال'),
                  selected: _isActive == true,
                  onSelected: (selected) {
                    setState(() {
                      _isActive = selected ? true : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('غیرفعال'),
                  selected: _isActive == false,
                  onSelected: (selected) {
                    setState(() {
                      _isActive = selected ? false : null;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _dataType = null;
              _cardinality = null;
              _scope = null;
              _isActive = null;
            });
          },
          child: const Text('پاک کردن همه'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_dataType, _cardinality, _scope, _isActive);
            Navigator.pop(context);
          },
          child: const Text('اعمال'),
        ),
      ],
    );
  }
}
