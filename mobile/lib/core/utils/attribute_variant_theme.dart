import 'package:flutter/material.dart';
import '../../features/product/data/models/attribute_enums.dart';
import '../theme/app_colors_v2.dart';

/// Utility class برای رنگ‌بندی و آیکون‌های Attribute و Variant - نسخه 2
/// 🎨 Based on the delicious AppColorsV2 palette!
class AttributeVariantTheme {
  AttributeVariantTheme._();
  
  // ============================================
  // ATTRIBUTE DATA TYPE - COLORS & ICONS
  // ============================================
  
  /// دریافت رنگ براساس نوع داده Attribute
  static Color getDataTypeColor(AttributeDataType dataType, {required bool isDark}) {
    switch (dataType) {
      case AttributeDataType.text:
        return isDark ? AppColorsV2.darkInfo : AppColorsV2.info;
      case AttributeDataType.number:
        return isDark ? AppColorsV2.darkSecondary : AppColorsV2.secondary;
      case AttributeDataType.select:
        return isDark ? AppColorsV2.darkPrimary : AppColorsV2.primary;
      case AttributeDataType.color:
        return isDark ? AppColorsV2.accent : AppColorsV2.accent;
      case AttributeDataType.boolean:
        return isDark ? AppColorsV2.darkSuccess : AppColorsV2.success;
      case AttributeDataType.date:
        return isDark ? AppColorsV2.darkWarning : AppColorsV2.warning;
    }
  }
  
  /// دریافت رنگ پس‌زمینه براساس نوع داده Attribute
  static Color getDataTypeBackgroundColor(AttributeDataType dataType, {required bool isDark}) {
    switch (dataType) {
      case AttributeDataType.text:
        return isDark ? AppColorsV2.darkSecondaryPale : AppColorsV2.infoPale;
      case AttributeDataType.number:
        return isDark ? AppColorsV2.darkSecondaryPale : AppColorsV2.secondaryPale;
      case AttributeDataType.select:
        return isDark ? AppColorsV2.darkPrimaryPale : AppColorsV2.primaryPale;
      case AttributeDataType.color:
        return isDark ? AppColorsV2.accentPale : AppColorsV2.accentPale;
      case AttributeDataType.boolean:
        return isDark ? AppColorsV2.darkSurfaceElevated : AppColorsV2.successPale;
      case AttributeDataType.date:
        return isDark ? AppColorsV2.warningPale : AppColorsV2.warningPale;
    }
  }
  
  /// دریافت آیکون براساس نوع داده Attribute
  static IconData getDataTypeIcon(AttributeDataType dataType) {
    switch (dataType) {
      case AttributeDataType.text:
        return Icons.text_fields_rounded;
      case AttributeDataType.number:
        return Icons.tag_rounded;
      case AttributeDataType.select:
        return Icons.list_alt_rounded;
      case AttributeDataType.color:
        return Icons.palette_rounded;
      case AttributeDataType.boolean:
        return Icons.toggle_on_rounded;
      case AttributeDataType.date:
        return Icons.calendar_today_rounded;
    }
  }
  
  // ============================================
  // VARIANT STATUS - COLORS & ICONS
  // ============================================
  
  /// دریافت رنگ براساس وضعیت Variant
  static Color getStatusColor(VariantStatus status, {required bool isDark}) {
    switch (status) {
      case VariantStatus.inStock:
        return isDark ? AppColorsV2.darkSuccess : AppColorsV2.success;
      case VariantStatus.lowStock:
        return isDark ? AppColorsV2.darkWarning : AppColorsV2.warning;
      case VariantStatus.outOfStock:
        return isDark ? AppColorsV2.darkError : AppColorsV2.error;
      case VariantStatus.discontinued:
        return isDark ? AppColorsV2.darkTextTertiary : AppColorsV2.textTertiary;
    }
  }
  
  /// دریافت رنگ پس‌زمینه براساس وضعیت Variant
  static Color getStatusBackgroundColor(VariantStatus status, {required bool isDark}) {
    switch (status) {
      case VariantStatus.inStock:
        return isDark ? AppColorsV2.darkSurfaceElevated : AppColorsV2.successPale;
      case VariantStatus.lowStock:
        return isDark ? AppColorsV2.warningPale : AppColorsV2.warningPale;
      case VariantStatus.outOfStock:
        return isDark ? AppColorsV2.darkSurface : AppColorsV2.errorPale;
      case VariantStatus.discontinued:
        return isDark ? AppColorsV2.darkBorderLight : AppColorsV2.borderLight;
    }
  }
  
  /// دریافت آیکون براساس وضعیت Variant
  static IconData getStatusIcon(VariantStatus status) {
    switch (status) {
      case VariantStatus.inStock:
        return Icons.check_circle_rounded;
      case VariantStatus.lowStock:
        return Icons.warning_amber_rounded;
      case VariantStatus.outOfStock:
        return Icons.cancel_rounded;
      case VariantStatus.discontinued:
        return Icons.remove_circle_outline_rounded;
    }
  }
  
  // ============================================
  // ATTRIBUTE SCOPE - COLORS & ICONS
  // ============================================
  
  /// دریافت رنگ براساس Scope
  static Color getScopeColor(AttributeScope scope, {required bool isDark}) {
    switch (scope) {
      case AttributeScope.productLevel:
        return isDark ? AppColorsV2.darkPrimary : AppColorsV2.primary;
      case AttributeScope.variantLevel:
        return isDark ? AppColorsV2.darkSecondary : AppColorsV2.secondary;
    }
  }
  
  /// دریافت رنگ پس‌زمینه براساس Scope
  static Color getScopeBackgroundColor(AttributeScope scope, {required bool isDark}) {
    switch (scope) {
      case AttributeScope.productLevel:
        return isDark ? AppColorsV2.darkPrimaryPale : AppColorsV2.primaryPale;
      case AttributeScope.variantLevel:
        return isDark ? AppColorsV2.darkSecondaryPale : AppColorsV2.secondaryPale;
    }
  }
  
  /// دریافت آیکون براساس Scope
  static IconData getScopeIcon(AttributeScope scope) {
    switch (scope) {
      case AttributeScope.productLevel:
        return Icons.lock_rounded;
      case AttributeScope.variantLevel:
        return Icons.tune_rounded;
    }
  }
  
  // ============================================
  // ATTRIBUTE CARDINALITY - COLORS & ICONS
  // ============================================
  
  /// دریافت رنگ براساس Cardinality
  static Color getCardinalityColor(AttributeCardinality cardinality, {required bool isDark}) {
    switch (cardinality) {
      case AttributeCardinality.single:
        return isDark ? AppColorsV2.darkInfo : AppColorsV2.info;
      case AttributeCardinality.multiple:
        return isDark ? AppColorsV2.accentLight : AppColorsV2.accent;
    }
  }
  
  /// دریافت رنگ پس‌زمینه براساس Cardinality
  static Color getCardinalityBackgroundColor(AttributeCardinality cardinality, {required bool isDark}) {
    switch (cardinality) {
      case AttributeCardinality.single:
        return isDark ? AppColorsV2.darkSecondaryPale : AppColorsV2.infoPale;
      case AttributeCardinality.multiple:
        return isDark ? AppColorsV2.accentPale : AppColorsV2.accentPale;
    }
  }
  
  /// دریافت آیکون براساس Cardinality
  static IconData getCardinalityIcon(AttributeCardinality cardinality) {
    switch (cardinality) {
      case AttributeCardinality.single:
        return Icons.radio_button_checked_rounded;
      case AttributeCardinality.multiple:
        return Icons.checklist_rounded;
    }
  }
  
  // ============================================
  // STOCK LEVEL - COLORS
  // ============================================
  
  /// دریافت رنگ براساس سطح موجودی (High/Medium/Low)
  static Color getStockLevelColor(double stock, double? lowStockThreshold, {required bool isDark}) {
    if (stock <= 0) {
      return isDark ? AppColorsV2.darkError : AppColorsV2.error;
    }
    
    final threshold = lowStockThreshold ?? 10;
    if (stock <= threshold) {
      return isDark ? AppColorsV2.darkWarning : AppColorsV2.warning;
    }
    
    return isDark ? AppColorsV2.darkSuccess : AppColorsV2.success;
  }
  
  /// دریافت رنگ پس‌زمینه براساس سطح موجودی
  static Color getStockLevelBackgroundColor(double stock, double? lowStockThreshold, {required bool isDark}) {
    if (stock <= 0) {
      return isDark ? AppColorsV2.darkSurface : AppColorsV2.errorPale;
    }
    
    final threshold = lowStockThreshold ?? 10;
    if (stock <= threshold) {
      return isDark ? AppColorsV2.warningPale : AppColorsV2.warningPale;
    }
    
    return isDark ? AppColorsV2.darkSurfaceElevated : AppColorsV2.successPale;
  }
  
  /// دریافت آیکون براساس سطح موجودی
  static IconData getStockLevelIcon(double stock, double? lowStockThreshold) {
    if (stock <= 0) {
      return Icons.inventory_2_outlined;
    }
    
    final threshold = lowStockThreshold ?? 10;
    if (stock <= threshold) {
      return Icons.warning_amber_rounded;
    }
    
    return Icons.inventory_2_rounded;
  }
  
  // ============================================
  // BADGE WIDGETS (Ready-to-use) - Enhanced V2
  // ============================================
  
  /// Badge برای نمایش نوع داده Attribute
  static Widget dataTypeBadge(
    AttributeDataType dataType,
    BuildContext context, {
    bool showIcon = true,
    bool compact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getDataTypeColor(dataType, isDark: isDark);
    final bgColor = getDataTypeBackgroundColor(dataType, isDark: isDark);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              getDataTypeIcon(dataType),
              size: compact ? 14 : 16,
              color: color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            dataType.displayName,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Badge برای نمایش وضعیت Variant
  static Widget statusBadge(
    VariantStatus status,
    BuildContext context, {
    bool showIcon = true,
    bool compact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getStatusColor(status, isDark: isDark);
    final bgColor = getStatusBackgroundColor(status, isDark: isDark);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              getStatusIcon(status),
              size: compact ? 14 : 16,
              color: color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Badge برای نمایش Scope
  static Widget scopeBadge(
    AttributeScope scope,
    BuildContext context, {
    bool showIcon = true,
    bool compact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getScopeColor(scope, isDark: isDark);
    final bgColor = getScopeBackgroundColor(scope, isDark: isDark);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              getScopeIcon(scope),
              size: compact ? 11 : 13,
              color: color,
            ),
            SizedBox(width: compact ? 3 : 5),
          ],
          Text(
            scope.displayName,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Badge برای نمایش Cardinality
  static Widget cardinalityBadge(
    AttributeCardinality cardinality,
    BuildContext context, {
    bool showIcon = true,
    bool compact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getCardinalityColor(cardinality, isDark: isDark);
    final bgColor = getCardinalityBackgroundColor(cardinality, isDark: isDark);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              getCardinalityIcon(cardinality),
              size: compact ? 11 : 13,
              color: color,
            ),
            SizedBox(width: compact ? 3 : 5),
          ],
          Text(
            cardinality.displayName,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Badge برای نمایش موجودی
  static Widget stockBadge(
    double stock,
    double? lowStockThreshold,
    BuildContext context, {
    bool showIcon = true,
    bool compact = false,
    String? customLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getStockLevelColor(stock, lowStockThreshold, isDark: isDark);
    final bgColor = getStockLevelBackgroundColor(stock, lowStockThreshold, isDark: isDark);
    final icon = getStockLevelIcon(stock, lowStockThreshold);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: compact ? 14 : 16,
              color: color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            customLabel ?? '${stock.toStringAsFixed(0)} عدد',
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
  
  // ============================================
  // HELPER METHODS - V2 Enhancements
  // ============================================
  
  /// دریافت gradient برای badge ها (اختیاری)
  static LinearGradient getStatusGradient(VariantStatus status, {required bool isDark}) {
    final color = getStatusColor(status, isDark: isDark);
    return LinearGradient(
      colors: [
        color.withValues(alpha: 0.15),
        color.withValues(alpha: 0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  /// دریافت shadow برای badge ها
  static List<BoxShadow> getBadgeShadow(Color color, {required bool isDark}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  /// Widget helper برای نمایش چندین badge در کنار هم
  static Widget badgeRow({
    required List<Widget> badges,
    double spacing = 8,
    WrapAlignment alignment = WrapAlignment.start,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: alignment,
      children: badges,
    );
  }
}
