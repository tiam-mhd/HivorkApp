// import 'package:flutter/material.dart';
// import '../../features/product/data/models/attribute_enums.dart';
// import '../theme/app_colors.dart';

// /// Utility class برای رنگ‌بندی و آیکون‌های Attribute و Variant
// class AttributeVariantTheme {
//   AttributeVariantTheme._();
  
//   // ============================================
//   // ATTRIBUTE DATA TYPE - COLORS & ICONS
//   // ============================================
  
//   /// دریافت رنگ براساس نوع داده Attribute
//   static Color getDataTypeColor(AttributeDataType dataType, {required bool isDark}) {
//     switch (dataType) {
//       case AttributeDataType.text:
//         return isDark ? AppColors.darkAttributeText : AppColors.attributeText;
//       case AttributeDataType.number:
//         return isDark ? AppColors.darkAttributeNumber : AppColors.attributeNumber;
//       case AttributeDataType.select:
//         return isDark ? AppColors.darkAttributeSelect : AppColors.attributeSelect;
//       case AttributeDataType.color:
//         return isDark ? AppColors.darkAttributeColor : AppColors.attributeColor;
//       case AttributeDataType.boolean:
//         return isDark ? AppColors.darkAttributeBoolean : AppColors.attributeBoolean;
//       case AttributeDataType.date:
//         return isDark ? AppColors.darkAttributeDate : AppColors.attributeDate;
//     }
//   }
  
//   /// دریافت آیکون براساس نوع داده Attribute
//   static IconData getDataTypeIcon(AttributeDataType dataType) {
//     switch (dataType) {
//       case AttributeDataType.text:
//         return Icons.text_fields;
//       case AttributeDataType.number:
//         return Icons.numbers;
//       case AttributeDataType.select:
//         return Icons.list_alt;
//       case AttributeDataType.color:
//         return Icons.palette;
//       case AttributeDataType.boolean:
//         return Icons.toggle_on;
//       case AttributeDataType.date:
//         return Icons.calendar_today;
//     }
//   }
  
//   // ============================================
//   // VARIANT STATUS - COLORS & ICONS
//   // ============================================
  
//   /// دریافت رنگ براساس وضعیت Variant
//   static Color getStatusColor(VariantStatus status, {required bool isDark}) {
//     switch (status) {
//       case VariantStatus.inStock:
//         return isDark ? AppColors.darkVariantActive : AppColors.variantActive;
//       case VariantStatus.lowStock:
//         return isDark ? AppColors.darkVariantLowStock : AppColors.variantLowStock;
//       case VariantStatus.outOfStock:
//         return isDark ? AppColors.darkVariantOutOfStock : AppColors.variantOutOfStock;
//       case VariantStatus.discontinued:
//         return isDark ? AppColors.darkVariantInactive : AppColors.variantInactive;
//     }
//   }
  
//   /// دریافت رنگ پس‌زمینه براساس وضعیت Variant
//   static Color getStatusBackgroundColor(VariantStatus status, {required bool isDark}) {
//     final color = getStatusColor(status, isDark: isDark);
//     return color.withOpacity(isDark ? 0.2 : 0.1);
//   }
  
//   /// دریافت آیکون براساس وضعیت Variant
//   static IconData getStatusIcon(VariantStatus status) {
//     switch (status) {
//       case VariantStatus.inStock:
//         return Icons.check_circle;
//       case VariantStatus.lowStock:
//         return Icons.warning;
//       case VariantStatus.outOfStock:
//         return Icons.block;
//       case VariantStatus.discontinued:
//         return Icons.remove_circle_outline;
//     }
//   }
  
//   // ============================================
//   // ATTRIBUTE SCOPE - COLORS & ICONS
//   // ============================================
  
//   /// دریافت رنگ براساس Scope
//   static Color getScopeColor(AttributeScope scope, {required bool isDark}) {
//     switch (scope) {
//       case AttributeScope.productLevel:
//         return isDark ? AppColors.darkScopeFixed : AppColors.scopeFixed;
//       case AttributeScope.variantLevel:
//         return isDark ? AppColors.darkScopeVariable : AppColors.scopeVariable;
//     }
//   }
  
//   /// دریافت آیکون براساس Scope
//   static IconData getScopeIcon(AttributeScope scope) {
//     switch (scope) {
//       case AttributeScope.productLevel:
//         return Icons.lock;
//       case AttributeScope.variantLevel:
//         return Icons.tune;
//     }
//   }
  
//   // ============================================
//   // ATTRIBUTE CARDINALITY - COLORS & ICONS
//   // ============================================
  
//   /// دریافت رنگ براساس Cardinality
//   static Color getCardinalityColor(AttributeCardinality cardinality, {required bool isDark}) {
//     switch (cardinality) {
//       case AttributeCardinality.single:
//         return isDark ? AppColors.darkCardinalitySingle : AppColors.cardinalitySingle;
//       case AttributeCardinality.multiple:
//         return isDark ? AppColors.darkCardinalityMultiple : AppColors.cardinalityMultiple;
//     }
//   }
  
//   /// دریافت آیکون براساس Cardinality
//   static IconData getCardinalityIcon(AttributeCardinality cardinality) {
//     switch (cardinality) {
//       case AttributeCardinality.single:
//         return Icons.radio_button_checked;
//       case AttributeCardinality.multiple:
//         return Icons.checklist;
//     }
//   }
  
//   // ============================================
//   // STOCK LEVEL - COLORS
//   // ============================================
  
//   /// دریافت رنگ براساس سطح موجودی (High/Medium/Low)
//   static Color getStockLevelColor(double stock, double? lowStockThreshold, {required bool isDark}) {
//     if (stock <= 0) {
//       return getStatusColor(VariantStatus.outOfStock, isDark: isDark);
//     }
    
//     final threshold = lowStockThreshold ?? 10;
//     if (stock <= threshold) {
//       return getStatusColor(VariantStatus.lowStock, isDark: isDark);
//     }
    
//     return getStatusColor(VariantStatus.inStock, isDark: isDark);
//   }
  
//   /// دریافت رنگ پس‌زمینه براساس سطح موجودی
//   static Color getStockLevelBackgroundColor(double stock, double? lowStockThreshold, {required bool isDark}) {
//     if (stock <= 0) {
//       return isDark ? AppColors.darkStockLowBg : AppColors.stockLowBg;
//     }
    
//     final threshold = lowStockThreshold ?? 10;
//     if (stock <= threshold) {
//       return isDark ? AppColors.darkStockMediumBg : AppColors.stockMediumBg;
//     }
    
//     return isDark ? AppColors.darkStockHighBg : AppColors.stockHighBg;
//   }
  
//   /// دریافت آیکون براساس سطح موجودی
//   static IconData getStockLevelIcon(double stock, double? lowStockThreshold) {
//     if (stock <= 0) {
//       return Icons.inventory_2_outlined;
//     }
    
//     final threshold = lowStockThreshold ?? 10;
//     if (stock <= threshold) {
//       return Icons.warning_amber;
//     }
    
//     return Icons.inventory_2;
//   }
  
//   // ============================================
//   // BADGE WIDGETS (Ready-to-use)
//   // ============================================
  
//   /// Badge برای نمایش نوع داده Attribute
//   static Widget dataTypeBadge(
//     AttributeDataType dataType,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final color = getDataTypeColor(dataType, isDark: isDark);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3), width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             getDataTypeIcon(dataType),
//             size: 14,
//             color: color,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             dataType.displayName,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// Badge برای نمایش وضعیت Variant
//   static Widget statusBadge(
//     VariantStatus status,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final color = getStatusColor(status, isDark: isDark);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3), width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             getStatusIcon(status),
//             size: 14,
//             color: color,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             status.displayName,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// Badge برای نمایش Scope
//   static Widget scopeBadge(
//     AttributeScope scope,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final color = getScopeColor(scope, isDark: isDark);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: color.withOpacity(0.3), width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             getScopeIcon(scope),
//             size: 12,
//             color: color,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             scope.displayName,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// Badge برای نمایش موجودی
//   static Widget stockBadge(
//     double stock,
//     double? lowStockThreshold,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final color = getStockLevelColor(stock, lowStockThreshold, isDark: isDark);
//     final icon = getStockLevelIcon(stock, lowStockThreshold);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3), width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 14,
//             color: color,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             '${stock.toStringAsFixed(0)} عدد',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
