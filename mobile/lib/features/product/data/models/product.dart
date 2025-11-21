import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

// Converter برای تبدیل String به double (برای decimal های PostgreSQL)
class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double value) => value;
}

// Converter برای فیلدهای nullable
class NullableStringToDoubleConverter implements JsonConverter<double?, dynamic> {
  const NullableStringToDoubleConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

enum ProductType {
  @JsonValue('goods')
  goods,
  @JsonValue('service')
  service,
}

enum ProductUnit {
  @JsonValue('piece')
  piece,
  @JsonValue('kilogram')
  kilogram,
  @JsonValue('gram')
  gram,
  @JsonValue('liter')
  liter,
  @JsonValue('meter')
  meter,
  @JsonValue('square_meter')
  squareMeter,
  @JsonValue('cubic_meter')
  cubicMeter,
  @JsonValue('box')
  box,
  @JsonValue('carton')
  carton,
  @JsonValue('pack')
  pack,
  @JsonValue('hour')
  hour,
  @JsonValue('day')
  day,
  @JsonValue('month')
  month,
}

enum ProductStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('out_of_stock')
  outOfStock,
}

@JsonSerializable()
class ProductDimensions {
  final double? length;
  final double? width;
  final double? height;
  final String? unit;

  ProductDimensions({
    this.length,
    this.width,
    this.height,
    this.unit,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) =>
      _$ProductDimensionsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDimensionsToJson(this);
}

@JsonSerializable()
class Product {
  final String id;
  final String code;
  final String name;
  @JsonKey(name: 'nameEn', defaultValue: null)
  final String? nameEn;
  final String? description;
  final ProductType type;
  final ProductUnit unit;
  final String? barcode;
  final String? category;
  @JsonKey(name: 'categoryName')
  final String? categoryName;
  @JsonKey(name: 'categoryIcon')
  final String? categoryIcon;
  @JsonKey(name: 'categoryColor')
  final String? categoryColor;
  final String? brand;

  // Pricing
  @StringToDoubleConverter()
  @JsonKey(name: 'purchasePrice', defaultValue: 0.0)
  final double purchasePrice;
  @StringToDoubleConverter()
  @JsonKey(name: 'salePrice', defaultValue: 0.0)
  final double salePrice;
  @NullableStringToDoubleConverter()
  @JsonKey(name: 'wholesalePrice')
  final double? wholesalePrice;
  @StringToDoubleConverter()
  @JsonKey(name: 'taxRate', defaultValue: 0.0)
  final double taxRate;
  @StringToDoubleConverter()
  @JsonKey(name: 'discountRate', defaultValue: 0.0)
  final double discountRate;

  // Inventory
  @StringToDoubleConverter()
  @JsonKey(name: 'currentStock', defaultValue: 0.0)
  final double currentStock;
  @StringToDoubleConverter()
  @JsonKey(name: 'minStock', defaultValue: 0.0)
  final double minStock;
  @NullableStringToDoubleConverter()
  @JsonKey(name: 'maxStock')
  final double? maxStock;
  @NullableStringToDoubleConverter()
  @JsonKey(name: 'reorderPoint')
  final double? reorderPoint;
  @JsonKey(name: 'trackInventory', defaultValue: true)
  final bool trackInventory;
  
  // Variants
  @JsonKey(name: 'hasVariants', defaultValue: false)
  final bool hasVariants;
  @NullableStringToDoubleConverter()
  @JsonKey(name: 'totalStock')
  final double? totalStock;

  // Images
  @JsonKey(name: 'mainImage')
  final String? mainImage;
  final List<String>? images;

  // Additional info
  final String? supplier;
  final String? sku;
  @NullableStringToDoubleConverter()
  final double? weight;
  final ProductDimensions? dimensions;
  @JsonKey(name: 'customFields')
  final Map<String, dynamic>? customFields;
  final ProductStatus status;
  final String? notes;

  // Relations
  @JsonKey(name: 'businessId', required: true)
  final String businessId;

  // Timestamps
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    this.nameEn,
    this.description,
    required this.type,
    required this.unit,
    this.barcode,
    this.category,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.brand,
    required this.purchasePrice,
    required this.salePrice,
    this.wholesalePrice,
    required this.taxRate,
    required this.discountRate,
    required this.currentStock,
    required this.minStock,
    this.maxStock,
    this.reorderPoint,
    required this.trackInventory,
    required this.hasVariants,
    this.totalStock,
    this.mainImage,
    this.images,
    this.supplier,
    this.sku,
    this.weight,
    this.dimensions,
    this.customFields,
    required this.status,
    this.notes,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? code,
    String? name,
    String? nameEn,
    String? description,
    ProductType? type,
    ProductUnit? unit,
    String? barcode,
    String? category,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? brand,
    double? purchasePrice,
    double? salePrice,
    double? wholesalePrice,
    double? taxRate,
    double? discountRate,
    double? currentStock,
    double? minStock,
    double? maxStock,
    double? reorderPoint,
    bool? trackInventory,
    bool? hasVariants,
    double? totalStock,
    String? mainImage,
    List<String>? images,
    String? supplier,
    String? sku,
    double? weight,
    ProductDimensions? dimensions,
    Map<String, dynamic>? customFields,
    ProductStatus? status,
    String? notes,
    String? businessId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      brand: brand ?? this.brand,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      taxRate: taxRate ?? this.taxRate,
      discountRate: discountRate ?? this.discountRate,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      trackInventory: trackInventory ?? this.trackInventory,
      hasVariants: hasVariants ?? this.hasVariants,
      totalStock: totalStock ?? this.totalStock,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      supplier: supplier ?? this.supplier,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      customFields: customFields ?? this.customFields,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => trackInventory && currentStock <= minStock;
  bool get isOutOfStock => trackInventory && currentStock == 0;
  double get finalPrice => salePrice * (1 - discountRate / 100) * (1 + taxRate / 100);
  double get profitMargin => salePrice > 0 ? ((salePrice - purchasePrice) / salePrice * 100) : 0;
}
