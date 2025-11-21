/// Data type for product attributes
enum AttributeDataType {
  text,
  number,
  select,
  color,
  boolean,
  date;

  String get apiValue {
    switch (this) {
      case AttributeDataType.text:
        return 'text';
      case AttributeDataType.number:
        return 'number';
      case AttributeDataType.select:
        return 'select';
      case AttributeDataType.color:
        return 'color';
      case AttributeDataType.boolean:
        return 'boolean';
      case AttributeDataType.date:
        return 'date';
    }
  }

  String get displayName {
    switch (this) {
      case AttributeDataType.text:
        return 'متن';
      case AttributeDataType.number:
        return 'عدد';
      case AttributeDataType.select:
        return 'انتخابی';
      case AttributeDataType.color:
        return 'رنگ';
      case AttributeDataType.boolean:
        return 'بله/خیر';
      case AttributeDataType.date:
        return 'تاریخ';
    }
  }

  static AttributeDataType fromString(String value) {
    return AttributeDataType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => AttributeDataType.text,
    );
  }
}

/// Cardinality for attributes (single or multiple values)
enum AttributeCardinality {
  single,
  multiple;

  String get apiValue {
    switch (this) {
      case AttributeCardinality.single:
        return 'single';
      case AttributeCardinality.multiple:
        return 'multiple';
    }
  }

  String get displayName {
    switch (this) {
      case AttributeCardinality.single:
        return 'تک مقداره';
      case AttributeCardinality.multiple:
        return 'چند مقداره';
    }
  }

  static AttributeCardinality fromString(String value) {
    return AttributeCardinality.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => AttributeCardinality.single,
    );
  }
}

/// Scope of attribute (product level or variant level)
enum AttributeScope {
  productLevel,
  variantLevel;

  String get apiValue {
    switch (this) {
      case AttributeScope.productLevel:
        return 'product_level';
      case AttributeScope.variantLevel:
        return 'variant_level';
    }
  }

  String get displayName {
    switch (this) {
      case AttributeScope.productLevel:
        return 'ویژگی ثابت (سطح محصول)';
      case AttributeScope.variantLevel:
        return 'ویژگی متغیر (سطح تنوع)';
    }
  }

  String get description {
    switch (this) {
      case AttributeScope.productLevel:
        return 'برای تمام تنوع‌های محصول یکسان است';
      case AttributeScope.variantLevel:
        return 'در هر تنوع محصول می‌تواند متفاوت باشد';
    }
  }

  static AttributeScope fromString(String value) {
    return AttributeScope.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => AttributeScope.variantLevel,
    );
  }
}

/// Status of product variant
enum VariantStatus {
  inStock,
  lowStock,
  outOfStock,
  discontinued;

  String get apiValue {
    switch (this) {
      case VariantStatus.inStock:
        return 'in_stock';
      case VariantStatus.lowStock:
        return 'low_stock';
      case VariantStatus.outOfStock:
        return 'out_of_stock';
      case VariantStatus.discontinued:
        return 'discontinued';
    }
  }

  String get displayName {
    switch (this) {
      case VariantStatus.inStock:
        return 'موجود';
      case VariantStatus.lowStock:
        return 'موجودی کم';
      case VariantStatus.outOfStock:
        return 'ناموجود';
      case VariantStatus.discontinued:
        return 'متوقف شده';
    }
  }

  static VariantStatus fromString(String value) {
    return VariantStatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => VariantStatus.outOfStock,
    );
  }
}
