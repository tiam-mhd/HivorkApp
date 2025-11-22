// import 'package:flutter/material.dart';
// import '../../../../core/di/service_locator.dart';
// import '../../../../core/extensions/theme_extension.dart';
// import '../../data/models/attribute_enums.dart';
// import '../../data/models/product_attribute.dart';
// import '../../data/models/product_variant.dart';
// import '../../data/services/variant_api_service.dart';
// import '../../data/services/attribute_api_service.dart';
// import '../../data/services/product_attribute_value_api_service.dart';
// import '../../data/utils/variant_combination_generator.dart';
// import '../pages/variants_management_page.dart';
// import 'product_attribute_selector.dart';

// /// Tab widget for product variants within product form
// /// Shows a mini list and button to open full management page
// class ProductVariantsTab extends StatefulWidget {
//   final String productId;
//   final String productName;
//   final String businessId;
//   final bool hasVariants;
//   final Function(bool) onHasVariantsChanged;

//   const ProductVariantsTab({
//     Key? key,
//     required this.productId,
//     required this.productName,
//     required this.businessId,
//     required this.hasVariants,
//     required this.onHasVariantsChanged,
//   }) : super(key: key);

//   @override
//   State<ProductVariantsTab> createState() => _ProductVariantsTabState();
// }

// class _ProductVariantsTabState extends State<ProductVariantsTab>
//     with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
//   late VariantApiService _variantService;
//   late ProductAttributeValueApiService _attributeValueService;
//   late AttributeApiService _attributeService;
//   late TabController _subTabController;
  
//   List<ProductVariant> _variants = [];
//   List<ProductAttribute> _allAttributes = [];
//   Map<String, List<String>> _productAttributeValues = {};
//   bool _isLoading = false;
//   bool _isLoadingAttributes = false;
//   String? _errorMessage;
//   String? _attributeErrorMessage;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _subTabController = TabController(length: 2, vsync: this);
//     final dio = ServiceLocator().dio;
//     _variantService = VariantApiService(dio);
//     _attributeValueService = ProductAttributeValueApiService(dio);
//     _attributeService = AttributeApiService(dio);
//     _loadData();
//   }
  
//   @override
//   void dispose() {
//     _subTabController.dispose();
//     super.dispose();
//   }
  
//   Future<void> _loadData() async {
//     await Future.wait([
//       _loadAttributes(),
//       if (widget.hasVariants) _loadVariants(),
//     ]);
//   }
  
//   Future<void> _loadAttributes() async {
//     setState(() {
//       _isLoadingAttributes = true;
//       _attributeErrorMessage = null;
//     });

//     try {
//       final attributes = await _attributeService.getBusinessAttributes(widget.businessId);
//       final values = await _attributeValueService.getProductAttributeValues(widget.productId);

//       setState(() {
//         _allAttributes = attributes;
//         _productAttributeValues = values;
//         _isLoadingAttributes = false;
//       });
//     } catch (e) {
//       setState(() {
//         _attributeErrorMessage = e.toString();
//         _isLoadingAttributes = false;
//       });
//     }
//   }

//   Future<void> _loadVariants() async {
//     if (!widget.hasVariants) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final variantsMap = await _variantService.getVariants(
//         productId: widget.productId,
//       );
      
//       print('🔧 [VARIANTS_TAB] variantsMap type: ${variantsMap.runtimeType}');
//       print('🔧 [VARIANTS_TAB] variantsMap data type: ${variantsMap['data'].runtimeType}');
//       print('🔧 [VARIANTS_TAB] variantsMap: $variantsMap');
      
//       setState(() {
//         // data is already List<ProductVariant>, not List<Map>
//         final data = variantsMap['data'];
//         List<ProductVariant> variants;
//         if (data is List<ProductVariant>) {
//           variants = data;
//         } else if (data is List) {
//           // Fallback: try to parse as List<dynamic>
//           variants = data
//               .map((v) {
//                 if (v is ProductVariant) return v;
//                 if (v is Map<String, dynamic>) return ProductVariant.fromJson(v);
//                 throw Exception('Invalid variant type: ${v.runtimeType}');
//               })
//               .toList();
//         } else {
//           variants = [];
//         }
        
//         // Sort: in-stock first, then low-stock, then out-of-stock
//         variants.sort((a, b) {
//           final aOrder = _getStatusOrder(a.status);
//           final bOrder = _getStatusOrder(b.status);
//           return aOrder.compareTo(bOrder);
//         });
        
//         _variants = variants;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   void _toggleHasVariants(bool value) {
//     if (value && _variants.isEmpty) {
//       // Enabling variants - show info dialog
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('فعال‌سازی ترکیبات'),
//           content: const Text(
//             'با فعال کردن ترکیبات، می‌توانید موجودی مستقل برای هر ترکیب ویژگی‌ها داشته باشید.\n\n'
//             'ابتدا باید ویژگی‌های محصول را تعریف کنید.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('انصراف'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 widget.onHasVariantsChanged(true);
//                 setState(() {});
//                 // Navigate to attributes management
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VariantsManagementPage(
//                       productId: widget.productId,
//                       productName: widget.productName,
//                       businessId: widget.businessId,
//                     ),
//                   ),
//                 ).then((_) => _loadVariants());
//               },
//               child: const Text('ادامه'),
//             ),
//           ],
//         ),
//       );
//     } else if (!value && _variants.isNotEmpty) {
//       // Disabling variants - show warning
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('غیرفعال‌سازی ترکیبات'),
//           content: Text(
//             'این محصول ${_variants.length} ترکیب دارد.\n'
//             'با غیرفعال کردن، تمام ترکیبات حذف خواهند شد.\n\n'
//             'آیا مطمئن هستید؟',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('انصراف'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 // Delete all variants
//                 try {
//                   for (final variant in _variants) {
//                     await _variantService.deleteVariant(widget.productId, variant.id);
//                   }
//                   widget.onHasVariantsChanged(false);
//                   setState(() {
//                     _variants = [];
//                   });
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('تمام ترکیبات حذف شدند')),
//                     );
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('خطا: $e')),
//                     );
//                   }
//                 }
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('حذف همه'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       widget.onHasVariantsChanged(value);
//       setState(() {});
//     }
//   }

//   int _getStatusOrder(VariantStatus status) {
//     switch (status) {
//       case VariantStatus.inStock:
//         return 0;
//       case VariantStatus.lowStock:
//         return 1;
//       case VariantStatus.outOfStock:
//         return 2;
//       case VariantStatus.discontinued:
//         return 3;
//     }
//   }

//   Future<void> _generateVariantsFromAttributes(
//     Map<String, List<String>> attributeValues,
//   ) async {
//     setState(() => _isLoading = true);

//     try {
//       print('🔧 [VARIANTS_TAB] Generating variants from attributes');
//       print('🔧 [VARIANTS_TAB] Attribute values (with IDs): $attributeValues');

//       // First, save attribute values to backend
//       await _attributeValueService.setProductAttributeValues(
//         widget.productId,
//         attributeValues,
//       );

//       print('🔧 [VARIANTS_TAB] Attribute values saved successfully');

//       // Load attributes with metadata to get ID -> code mapping and cardinality
//       final attributesMetadata = await _attributeValueService.getProductAttributeValuesWithMetadata(
//         widget.productId,
//       );
      
//       print('🔧 [VARIANTS_TAB] Loaded attributes metadata: $attributesMetadata');

//       // Build ID to code mapping and cardinality info
//       final Map<String, String> idToCodeMap = {};
//       final Map<String, String> codeToCardinalityMap = {};
      
//       attributesMetadata.forEach((id, data) {
//         final code = data['code'] as String;
//         final attribute = data['attribute'] as Map<String, dynamic>;
//         final cardinality = attribute['cardinality'] as String;
        
//         idToCodeMap[id] = code;
//         codeToCardinalityMap[code] = cardinality;
//       });
      
//       print('🔧 [VARIANTS_TAB] ID to Code mapping: $idToCodeMap');
//       print('🔧 [VARIANTS_TAB] Cardinality mapping: $codeToCardinalityMap');

//       // Generate all combinations (with IDs)
//       final combinations =
//           VariantCombinationGenerator.generateCombinations(attributeValues);

//       print('🔧 [VARIANTS_TAB] Generated ${combinations.length} combinations');

//       // Convert combinations from ID-based to code-based and prepare data
//       final variantsData = combinations.map((combination) {
//         // Convert attribute IDs to codes and format values based on cardinality
//         final Map<String, dynamic> codeBasedAttributes = {};
//         combination.forEach((attributeId, valueWithLabel) {
//           final code = idToCodeMap[attributeId];
//           if (code != null) {
//             // Extract value from "value|label" format
//             final value = valueWithLabel.contains('|') 
//                 ? valueWithLabel.split('|').first 
//                 : valueWithLabel;
            
//             final cardinality = codeToCardinalityMap[code];
//             // For 'multiple' cardinality, wrap single values in array
//             // For 'single' cardinality, keep as string
//             codeBasedAttributes[code] = cardinality == 'multiple' ? [value] : value;
//           }
//         });
        
//         final skuSuffix =
//             VariantCombinationGenerator.generateSKUSuffix(combination);
//         final name = VariantCombinationGenerator.generateVariantName(combination);

//         return {
//           'sku': '${widget.productId.substring(0, 8).toUpperCase()}-$skuSuffix',
//           'name': '${widget.productName} $name',
//           'attributes': codeBasedAttributes,  // Formatted based on cardinality
//           'currentStock': 0.0,
//           'minStock': 0.0,
//           'priceAdjustment': 0.0,
//           'purchasePriceAdjustment': 0.0,
//           'isActive': true,
//         };
//       }).toList();

//       print('🔧 [VARIANTS_TAB] Prepared variants data: ${variantsData.length} items');
//       print('🔧 [VARIANTS_TAB] First variant example: ${variantsData.first}');

//       // Bulk create variants
//       await _variantService.bulkCreateVariants(widget.productId, widget.businessId, variantsData);

//       print('🔧 [VARIANTS_TAB] Variants created successfully');

//       // Reload variants
//       await _loadVariants();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${combinations.length} ترکیب با موفقیت ایجاد شد'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       print('❌ [VARIANTS_TAB] Error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطا: ${e.toString().replaceAll('Exception: ', '')}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }  
  
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final theme = Theme.of(context);

//     return Column(
//       children: [
//         // Sub-TabBar برای ویژگی‌ها و تنوع‌ها
//         Container(
//           color: theme.scaffoldBackgroundColor,
//           child: TabBar(
//             controller: _subTabController,
//             labelColor: theme.colorScheme.primary,
//             unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
//             indicatorColor: theme.colorScheme.primary,
//             tabs: const [
//               Tab(text: 'ویژگی‌های محصول', icon: Icon(Icons.label_outline, size: 18)),
//               Tab(text: 'تنوع‌ها', icon: Icon(Icons.playlist_add, size: 18)),
//             ],
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _subTabController,
//             children: [
//               // Tab 1: Attributes
//               _buildAttributesSection(theme),
//               // Tab 2: Variants  
//               _buildVariantsSection(theme),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   // بخش ویژگی‌ها
//   Widget _buildAttributesSection(ThemeData theme) {
//     if (_isLoadingAttributes) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_attributeErrorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(_attributeErrorMessage!, textAlign: TextAlign.center),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadAttributes,
//               child: const Text('تلاش مجدد'),
//             ),
//           ],
//         ),
//       );
//     }

//     final assignedAttributes = _allAttributes
//         .where((attr) => _productAttributeValues.containsKey(attr.id))
//         .toList()
//       ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

//     if (assignedAttributes.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.label_outline,
//                 size: 64,
//                 color: theme.colorScheme.outline,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'هنوز ویژگی‌ای اضافه نشده',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: theme.colorScheme.outline,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'با دکمه + ویژگی اضافه کنید',
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.outline,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _addAttribute,
//                 icon: const Icon(Icons.add),
//                 label: const Text('افزودن ویژگی'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: assignedAttributes.length,
//       itemBuilder: (context, index) {
//         final attribute = assignedAttributes[index];
//         return _buildAttributeCard(attribute, theme);
//       },
//     );
//   }
  
//   // بخش تنوع‌ها
//   Widget _buildVariantsSection(ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Minimal Expandable Card
//           Card(
//             elevation: 0,
//             color: theme.cardColor,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: BorderSide(
//                 color: theme.brightness == Brightness.dark
//                     ? theme.dividerColor.withOpacity(0.2)
//                     : theme.dividerColor,
//               ),
//             ),
//             child: ExpansionTile(
//               tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: widget.hasVariants 
//                       ? theme.primaryColor.withOpacity(0.15)
//                       : (theme.brightness == Brightness.dark
//                           ? Colors.grey.shade800
//                           : Colors.grey.shade100),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.auto_awesome_mosaic,
//                   color: widget.hasVariants 
//                       ? theme.primaryColor 
//                       : (theme.brightness == Brightness.dark
//                           ? Colors.grey.shade400
//                           : Colors.grey.shade600),
//                   size: 20,
//                 ),
//               ),
//               title: Text(
//                 'تنوع محصول',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               subtitle: Text(
//                 widget.hasVariants 
//                     ? (_variants.isEmpty ? 'ایجاد نشده' : '${_variants.length} نوع')
//                     : 'غیرفعال',
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: context.textSecondary,
//                 ),
//               ),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (_variants.isNotEmpty)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: theme.brightness == Brightness.dark
//                             ? Colors.green.withOpacity(0.2)
//                             : Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${_variants.length}',
//                         style: TextStyle(
//                           color: theme.brightness == Brightness.dark
//                               ? Colors.green.shade300
//                               : Colors.green.shade700,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                   Switch(
//                     value: widget.hasVariants,
//                     onChanged: _toggleHasVariants,
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                 ],
//               ),
//               children: [
//                 if (!widget.hasVariants)
//                   _buildInactiveState(theme)
//                 else if (_isLoading)
//                   _buildLoadingState()
//                 else if (_errorMessage != null)
//                   _buildErrorState(theme)
//                 else if (_variants.isEmpty)
//                   _buildEmptyState(theme)
//                 else
//                   _buildVariantsList(theme),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInactiveState(ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           Icon(
//             Icons.toggle_off,
//             size: 48,
//             color: theme.brightness == Brightness.dark
//                 ? Colors.grey.shade600
//                 : Colors.grey.shade400,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'برای استفاده از تنوع محصول، کلید بالا را فعال کنید',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: context.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Padding(
//       padding: EdgeInsets.all(24),
//       child: Center(child: CircularProgressIndicator()),
//     );
//   }

//   Widget _buildErrorState(ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           Icon(Icons.error_outline, size: 48, color: context.errorColor),
//           const SizedBox(height: 12),
//           Text(_errorMessage!, textAlign: TextAlign.center),
//           const SizedBox(height: 16),
//           OutlinedButton(
//             onPressed: _loadVariants,
//             child: const Text('تلاش مجدد'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Column(
//         children: [
//           Icon(Icons.auto_awesome_mosaic_outlined, 
//             size: 48, 
//             color: theme.primaryColor.withOpacity(0.3),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'هنوز تنوعی ایجاد نشده',
//             style: theme.textTheme.titleSmall,
//           ),
//           const SizedBox(height: 16),
//           _buildGenerateButton(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildVariantsList(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Mini Stats
//         Row(
//           children: [
//             _buildMiniStat(
//               'موجود',
//               _variants.where((v) => v.status == VariantStatus.inStock).length,
//               Colors.green,
//             ),
//             const SizedBox(width: 12),
//             _buildMiniStat(
//               'کم',
//               _variants.where((v) => v.status == VariantStatus.lowStock).length,
//               Colors.orange,
//             ),
//             const SizedBox(width: 12),
//             _buildMiniStat(
//               'ناموجود',
//               _variants.where((v) => v.status == VariantStatus.outOfStock).length,
//               Colors.red,
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
        
//         // Variants Preview (max 3)
//         ..._variants.take(3).map((variant) => _buildVariantRow(variant, theme)),
        
//         const SizedBox(height: 12),
        
//         // View All Button
//         OutlinedButton.icon(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => VariantsManagementPage(
//                   productId: widget.productId,
//                   productName: widget.productName,
//                   businessId: widget.businessId,
//                 ),
//               ),
//             ).then((_) => _loadVariants());
//           },
//           icon: const Icon(Icons.open_in_new, size: 16),
//           label: Text('مشاهده و مدیریت همه (${_variants.length})'),
//           style: OutlinedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 40),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMiniStat(String label, int count, Color color) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final displayColor = isDark 
//         ? (color == Colors.green ? Colors.green.shade300
//            : color == Colors.orange ? Colors.orange.shade300
//            : Colors.red.shade300)
//         : (color == Colors.green ? Colors.green.shade600
//            : color == Colors.orange ? Colors.orange.shade600
//            : Colors.red.shade600);
    
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: isDark ? displayColor.withOpacity(0.2) : displayColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                 color: displayColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                 color: displayColor,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVariantRow(ProductVariant variant, ThemeData theme) {
//     final colors = _extractColorCodes(variant);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           // Color indicator
//           if (colors.isNotEmpty)
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: _parseColor(colors.first),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
//                 ),
//               ),
//             )
//           else
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.circle_outlined,
//                 size: 16,
//                 color: isDark ? Colors.grey.shade500 : Colors.grey,
//               ),
//             ),
//           const SizedBox(width: 12),
          
//           // Name
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _formatVariantName(variant.name ?? variant.sku),
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   'موجودی: ${variant.currentStock.toInt()}',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: context.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Status badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: _getStatusColor(variant.status, theme).withOpacity(isDark ? 0.25 : 0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               variant.status.displayName,
//               style: TextStyle(
//                 color: _getStatusColor(variant.status, theme),
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<String> _extractColorCodes(ProductVariant variant) {
//     final colors = <String>{};
    
//     variant.attributes.forEach((key, value) {
//       if (key.toLowerCase() == 'color' || key == 'رنگ') {
//         if (value is List) {
//           for (final item in value) {
//             final str = item.toString();
//             if (str.startsWith('#') && str.length == 7) {
//               colors.add(str.toLowerCase());
//             }
//           }
//         } else {
//           final str = value.toString();
//           if (str.startsWith('#') && str.length == 7) {
//             colors.add(str.toLowerCase());
//           }
//         }
//       }
//     });
    
//     return colors.toList();
//   }

//   Color _parseColor(String colorCode) {
//     try {
//       return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
//     } catch (e) {
//       return Colors.grey;
//     }
//   }

//   String _formatVariantName(String name) {
//     return name.replaceAll(RegExp(r'#[0-9a-fA-F]{6}'), '').trim();
//   }

//   Color _getStatusColor(VariantStatus status, ThemeData theme) {
//     final isDark = theme.brightness == Brightness.dark;
//     switch (status) {
//       case VariantStatus.inStock:
//         return isDark ? Colors.green.shade300 : Colors.green.shade600;
//       case VariantStatus.lowStock:
//         return isDark ? Colors.orange.shade300 : Colors.orange.shade600;
//       case VariantStatus.outOfStock:
//         return isDark ? Colors.red.shade300 : Colors.red.shade600;
//       case VariantStatus.discontinued:
//         return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
//     }
//   }

//   Widget _buildGenerateButton(BuildContext context) {
//     return ProductAttributeSelector(
//       productId: widget.productId,
//       businessId: widget.businessId,
//       selectedAttributeIds: const [],
//       onAttributesSelected: (attributes) {
//         // Just pass through to generator
//       },
//       onGenerateVariants: _generateVariantsFromAttributes,
//     );
//   }
  
//   // ==================== Attribute Management Methods ====================
  
//   void _addAttribute() {
//     final availableAttributes = _allAttributes
//         .where((attr) => !_productAttributeValues.containsKey(attr.id))
//         .toList()
//       ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
//     if (availableAttributes.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('همه ویژگی‌ها به محصول اضافه شده‌اند')),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => _AttributePickerDialog(
//         attributes: availableAttributes,
//         onSelect: (attribute) {
//           setState(() {
//             _productAttributeValues[attribute.id] = [];
//           });
//           // Don't save yet - wait for user to set values
//           // User must click edit icon to set values
//           // _saveAttributeValues(); // REMOVED
//         },
//       ),
//     );
//   }
  
//   Future<void> _saveAttributeValues() async {
//     try {
//       await _attributeValueService.setProductAttributeValues(
//         widget.productId,
//         _productAttributeValues,
//       );
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('ویژگی‌ها با موفقیت ذخیره شد'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطا: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
  
//   void _removeAttribute(ProductAttribute attribute) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف ویژگی'),
//         content: Text('آیا از حذف ویژگی "${attribute.name}" اطمینان دارید؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('انصراف'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 _productAttributeValues.remove(attribute.id);
//               });
//               _saveAttributeValues();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _editAttributeValue(ProductAttribute attribute) {
//     final currentValues = _productAttributeValues[attribute.id] ?? [];
    
//     if ((attribute.dataType == AttributeDataType.select || attribute.dataType == AttributeDataType.color) && 
//         attribute.options != null && attribute.options!.isNotEmpty) {
//       if (attribute.cardinality == AttributeCardinality.multiple) {
//         _showMultiOptionPicker(attribute, currentValues);
//       } else {
//         _showSingleOptionPicker(attribute, currentValues.isNotEmpty ? currentValues.first : null);
//       }
//     } else if (attribute.dataType == AttributeDataType.boolean) {
//       _showBooleanPicker(attribute, currentValues.isNotEmpty ? currentValues.first == 'true' : false);
//     } else if (attribute.dataType == AttributeDataType.date) {
//       _showDatePicker(attribute, currentValues.isNotEmpty ? currentValues.first : null);
//     } else {
//       if (attribute.cardinality == AttributeCardinality.multiple) {
//         _showMultiTextInput(attribute, currentValues);
//       } else {
//         _showSingleTextInput(attribute, currentValues.isNotEmpty ? currentValues.first : null);
//       }
//     }
//   }
  
//   void _showSingleOptionPicker(ProductAttribute attribute, String? currentValue) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String? selectedValue = currentValue;
//         return StatefulBuilder(
//           builder: (context, setState) => AlertDialog(
//             title: Text(attribute.name),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: (attribute.options ?? []).map((option) {
//                   if (attribute.dataType == AttributeDataType.color) {
//                     Color? color;
//                     try {
//                       color = Color(int.parse(option.value.replaceFirst('#', '0xFF')));
//                     } catch (e) {
//                       color = Colors.grey;
//                     }
//                     return ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: color,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       title: Text(option.label),
//                       trailing: selectedValue == option.value ? const Icon(Icons.check, color: Colors.green) : null,
//                       onTap: () {
//                         setState(() => selectedValue = option.value);
//                       },
//                     );
//                   } else {
//                     return RadioListTile<String>(
//                       title: Text(option.label),
//                       value: option.value,
//                       groupValue: selectedValue,
//                       onChanged: (value) {
//                         setState(() => selectedValue = value);
//                       },
//                     );
//                   }
//                 }).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('انصراف'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   if (selectedValue != null) {
//                     // Find the label for selected value
//                     final selectedOption = (attribute.options ?? []).firstWhere(
//                       (opt) => opt.value == selectedValue,
//                       orElse: () => AttributeOption(value: selectedValue!, label: selectedValue!),
//                     );
//                     this.setState(() {
//                       _productAttributeValues[attribute.id] = ['${selectedOption.value}|${selectedOption.label}'];
//                     });
//                   } else {
//                     this.setState(() {
//                       _productAttributeValues[attribute.id] = [];
//                     });
//                   }
//                   _saveAttributeValues();
//                 },
//                 child: const Text('ذخیره'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   void _showMultiOptionPicker(ProductAttribute attribute, List<String> currentValues) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         Set<String> selectedValues = Set<String>.from(currentValues);
//         return StatefulBuilder(
//           builder: (context, setState) => AlertDialog(
//             title: Text(attribute.name),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: (attribute.options ?? []).map((option) {
//                   final isSelected = selectedValues.contains(option.value);
                  
//                   if (attribute.dataType == AttributeDataType.color) {
//                     Color? color;
//                     try {
//                       color = Color(int.parse(option.value.replaceFirst('#', '0xFF')));
//                     } catch (e) {
//                       color = Colors.grey;
//                     }
//                     return CheckboxListTile(
//                       secondary: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: color,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       title: Text(option.label),
//                       value: isSelected,
//                       onChanged: (checked) {
//                         setState(() {
//                           if (checked == true) {
//                             selectedValues.add(option.value);
//                           } else {
//                             selectedValues.remove(option.value);
//                           }
//                         });
//                       },
//                     );
//                   } else {
//                     return CheckboxListTile(
//                       title: Text(option.label),
//                       value: isSelected,
//                       onChanged: (checked) {
//                         setState(() {
//                           if (checked == true) {
//                             selectedValues.add(option.value);
//                           } else {
//                             selectedValues.remove(option.value);
//                           }
//                         });
//                       },
//                     );
//                   }
//                 }).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('انصراف'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   final selectedList = selectedValues.map((val) {
//                     final selectedOption = (attribute.options ?? []).firstWhere(
//                       (opt) => opt.value == val,
//                       orElse: () => AttributeOption(value: val, label: val),
//                     );
//                     return '${selectedOption.value}|${selectedOption.label}';
//                   }).toList();
                  
//                   this.setState(() {
//                     _productAttributeValues[attribute.id] = selectedList;
//                   });
//                   _saveAttributeValues();
//                 },
//                 child: const Text('ذخیره'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   void _showBooleanPicker(ProductAttribute attribute, bool currentValue) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         bool selectedValue = currentValue;
//         return StatefulBuilder(
//           builder: (context, setState) => AlertDialog(
//             title: Text(attribute.name),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 RadioListTile<bool>(
//                   title: const Text('بله'),
//                   value: true,
//                   groupValue: selectedValue,
//                   onChanged: (value) {
//                     setState(() => selectedValue = value!);
//                   },
//                 ),
//                 RadioListTile<bool>(
//                   title: const Text('خیر'),
//                   value: false,
//                   groupValue: selectedValue,
//                   onChanged: (value) {
//                     setState(() => selectedValue = value!);
//                   },
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('انصراف'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   this.setState(() {
//                     _productAttributeValues[attribute.id] = [selectedValue.toString()];
//                   });
//                   _saveAttributeValues();
//                 },
//                 child: const Text('ذخیره'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   void _showDatePicker(ProductAttribute attribute, String? currentValue) async {
//     final now = DateTime.now();
//     final initialDate = currentValue != null ? DateTime.tryParse(currentValue) ?? now : now;
    
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );

//     if (picked != null) {
//       setState(() {
//         _productAttributeValues[attribute.id] = [picked.toIso8601String().split('T')[0]];
//       });
//       _saveAttributeValues();
//     }
//   }
  
//   void _showSingleTextInput(ProductAttribute attribute, String? currentValue) {
//     final controller = TextEditingController(text: currentValue ?? '');
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(attribute.name),
//         content: TextField(
//           controller: controller,
//           keyboardType: attribute.dataType == AttributeDataType.number
//               ? TextInputType.number
//               : TextInputType.text,
//           decoration: const InputDecoration(
//             hintText: 'مقدار را وارد کنید',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('انصراف'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 final value = controller.text.trim();
//                 _productAttributeValues[attribute.id] = value.isNotEmpty ? [value] : [];
//               });
//               _saveAttributeValues();
//             },
//             child: const Text('ذخیره'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _showMultiTextInput(ProductAttribute attribute, List<String> currentValues) {
//     final controllers = currentValues.isNotEmpty
//         ? currentValues.map((v) => TextEditingController(text: v)).toList()
//         : [TextEditingController()];

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           title: Text(attribute.name),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ...controllers.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final controller = entry.value;
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: controller,
//                             keyboardType: attribute.dataType == AttributeDataType.number
//                                 ? TextInputType.number
//                                 : TextInputType.text,
//                             decoration: InputDecoration(
//                               hintText: 'مقدار ${index + 1}',
//                               border: const OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                         if (controllers.length > 1)
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle, color: Colors.red),
//                             onPressed: () {
//                               setState(() {
//                                 controllers.removeAt(index);
//                               });
//                             },
//                           ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 const SizedBox(height: 8),
//                 OutlinedButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       controllers.add(TextEditingController());
//                     });
//                   },
//                   icon: const Icon(Icons.add),
//                   label: const Text('افزودن مقدار'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('انصراف'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 this.setState(() {
//                   final values = controllers
//                       .map((c) => c.text.trim())
//                       .where((v) => v.isNotEmpty)
//                       .toList();
//                   _productAttributeValues[attribute.id] = values;
//                 });
//                 _saveAttributeValues();
//               },
//               child: const Text('ذخیره'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildAttributeCard(ProductAttribute attribute, ThemeData theme) {
//     final values = _productAttributeValues[attribute.id] ?? [];
//     final isDark = theme.brightness == Brightness.dark;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
//           child: Icon(
//             _getAttributeIcon(attribute.dataType),
//             color: isDark ? Colors.blue.shade100 : Colors.blue.shade800,
//             size: 20,
//           ),
//         ),
//         title: Row(
//           children: [
//             Expanded(child: Text(attribute.name)),
//             if (attribute.required)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade100,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   'الزامی',
//                   style: TextStyle(fontSize: 10, color: Colors.red.shade900),
//                 ),
//               ),
//           ],
//         ),
//         subtitle: Text(_formatAttributeValues(values)),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit, size: 20),
//               onPressed: () => _editAttributeValue(attribute),
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//               onPressed: () => _removeAttribute(attribute),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   IconData _getAttributeIcon(AttributeDataType type) {
//     switch (type) {
//       case AttributeDataType.text:
//         return Icons.text_fields;
//       case AttributeDataType.number:
//         return Icons.numbers;
//       case AttributeDataType.select:
//         return Icons.list;
//       case AttributeDataType.color:
//         return Icons.palette;
//       case AttributeDataType.boolean:
//         return Icons.toggle_on;
//       case AttributeDataType.date:
//         return Icons.calendar_today;
//     }
//   }
  
//   String _formatAttributeValues(List<String> values) {
//     if (values.isEmpty) return 'مقدار تنظیم نشده';
//     // Extract labels from "value|label" format
//     return values.map((v) {
//       if (v.contains('|')) {
//         return v.split('|').last; // Get label part
//       }
//       return v;
//     }).join(', ');
//   }
// }

// // Dialog برای انتخاب ویژگی
// class _AttributePickerDialog extends StatelessWidget {
//   final List<ProductAttribute> attributes;
//   final Function(ProductAttribute) onSelect;

//   const _AttributePickerDialog({
//     required this.attributes,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('انتخاب ویژگی'),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: attributes.length,
//           itemBuilder: (context, index) {
//             final attr = attributes[index];
//             return ListTile(
//               title: Text(attr.name),
//               subtitle: Text(_getScopeLabel(attr.scope)),
//               trailing: attr.required
//                   ? Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade100,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         'الزامی',
//                         style: TextStyle(fontSize: 10, color: Colors.red.shade900),
//                       ),
//                     )
//                   : null,
//               onTap: () {
//                 Navigator.pop(context);
//                 onSelect(attr);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   String _getScopeLabel(AttributeScope scope) {
//     switch (scope) {
//       case AttributeScope.productLevel:
//         return 'سطح محصول';
//       case AttributeScope.variantLevel:
//         return 'سطح تنوع';
//     }
//   }
// }

