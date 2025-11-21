import 'package:json_annotation/json_annotation.dart';
import 'attribute_enums.dart';

part 'product_variant.g.dart';

// Converter for double values that might come as strings from backend
class DoubleConverter implements JsonConverter<double, dynamic> {
  const DoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.parse(json);
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

// Converter for nullable double values
class NullableDoubleConverter implements JsonConverter<double?, dynamic> {
  const NullableDoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.parse(json);
    return null;
  }

  @override
  dynamic toJson(double? object) => object;
}

// Converter for VariantStatus enum
class VariantStatusConverter implements JsonConverter<VariantStatus, String> {
  const VariantStatusConverter();

  @override
  VariantStatus fromJson(String json) => VariantStatus.fromString(json);

  @override
  String toJson(VariantStatus object) => object.apiValue;
}

@JsonSerializable(fieldRename: FieldRename.none)
class ProductVariant {
  final String id;
  final String productId;
  final String businessId;
  final String sku;
  final String? barcode;
  final String? name;
  final Map<String, dynamic> attributes;
  
  @DoubleConverter()
  final double currentStock;
  
  @DoubleConverter()
  final double minStock;
  
  @NullableDoubleConverter()
  final double? reorderPoint;
  
  @DoubleConverter()
  final double priceAdjustment;
  
  @DoubleConverter()
  final double purchasePriceAdjustment;
  
  @NullableDoubleConverter()
  final double? salePrice;
  
  @NullableDoubleConverter()
  final double? purchasePrice;
  
  final String? mainImage;
  final List<String>? images;
  
  @NullableDoubleConverter()
  final double? weight;
  
  final VariantDimensions? dimensions;
  final bool isActive;
  
  @VariantStatusConverter()
  final VariantStatus status;
  
  final int sortOrder;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.businessId,
    required this.sku,
    this.barcode,
    this.name,
    required this.attributes,
    this.currentStock = 0,
    this.minStock = 0,
    this.reorderPoint,
    this.priceAdjustment = 0,
    this.purchasePriceAdjustment = 0,
    this.salePrice,
    this.purchasePrice,
    this.mainImage,
    this.images,
    this.weight,
    this.dimensions,
    this.isActive = true,
    this.status = VariantStatus.inStock,
    this.sortOrder = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);

  Map<String, dynamic> toJson() => _$ProductVariantToJson(this);

  ProductVariant copyWith({
    String? id,
    String? productId,
    String? businessId,
    String? sku,
    String? barcode,
    String? name,
    Map<String, dynamic>? attributes,
    double? currentStock,
    double? minStock,
    double? reorderPoint,
    double? priceAdjustment,
    double? purchasePriceAdjustment,
    double? salePrice,
    double? purchasePrice,
    String? mainImage,
    List<String>? images,
    double? weight,
    VariantDimensions? dimensions,
    bool? isActive,
    VariantStatus? status,
    int? sortOrder,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      businessId: businessId ?? this.businessId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      attributes: attributes ?? this.attributes,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      purchasePriceAdjustment: purchasePriceAdjustment ?? this.purchasePriceAdjustment,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get final sale price (either absolute or base + adjustment)
  double getFinalSalePrice(double basePrice) {
    return salePrice ?? (basePrice + priceAdjustment);
  }

  /// Get final purchase price
  double getFinalPurchasePrice(double basePrice) {
    return purchasePrice ?? (basePrice + purchasePriceAdjustment);
  }

  /// Check if stock is low
  bool get isLowStock => status == VariantStatus.lowStock;

  /// Check if out of stock
  bool get isOutOfStock => status == VariantStatus.outOfStock;

  /// Get formatted attribute display
  String getAttributeDisplay() {
    if (attributes.isEmpty) return '';
    return attributes.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(' • ');
  }
}

@JsonSerializable(fieldRename: FieldRename.none)
class VariantDimensions {
  final double? length;
  final double? width;
  final double? height;
  final String? unit;

  VariantDimensions({
    this.length,
    this.width,
    this.height,
    this.unit,
  });

  factory VariantDimensions.fromJson(Map<String, dynamic> json) =>
      _$VariantDimensionsFromJson(json);

  Map<String, dynamic> toJson() => _$VariantDimensionsToJson(this);

  VariantDimensions copyWith({
    double? length,
    double? width,
    double? height,
    String? unit,
  }) {
    return VariantDimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      unit: unit ?? this.unit,
    );
  }
}

/// DTO for creating/updating variants
@JsonSerializable(fieldRename: FieldRename.none)
class VariantFormData {
  final String sku;
  final String? barcode;
  final String? name;
  final Map<String, dynamic> attributes;
  final double currentStock;
  final double minStock;
  final double? reorderPoint;
  final double priceAdjustment;
  final double purchasePriceAdjustment;
  final double? salePrice;
  final double? purchasePrice;
  final String? mainImage;
  final List<String>? images;
  final double? weight;
  final VariantDimensions? dimensions;
  final bool isActive;
  final int sortOrder;
  final String? notes;

  VariantFormData({
    required this.sku,
    this.barcode,
    this.name,
    required this.attributes,
    this.currentStock = 0,
    this.minStock = 0,
    this.reorderPoint,
    this.priceAdjustment = 0,
    this.purchasePriceAdjustment = 0,
    this.salePrice,
    this.purchasePrice,
    this.mainImage,
    this.images,
    this.weight,
    this.dimensions,
    this.isActive = true,
    this.sortOrder = 0,
    this.notes,
  });

  factory VariantFormData.fromJson(Map<String, dynamic> json) =>
      _$VariantFormDataFromJson(json);

  Map<String, dynamic> toJson() => _$VariantFormDataToJson(this);

  factory VariantFormData.fromVariant(ProductVariant variant) {
    return VariantFormData(
      sku: variant.sku,
      barcode: variant.barcode,
      name: variant.name,
      attributes: variant.attributes,
      currentStock: variant.currentStock,
      minStock: variant.minStock,
      reorderPoint: variant.reorderPoint,
      priceAdjustment: variant.priceAdjustment,
      purchasePriceAdjustment: variant.purchasePriceAdjustment,
      salePrice: variant.salePrice,
      purchasePrice: variant.purchasePrice,
      mainImage: variant.mainImage,
      images: variant.images,
      weight: variant.weight,
      dimensions: variant.dimensions,
      isActive: variant.isActive,
      sortOrder: variant.sortOrder,
      notes: variant.notes,
    );
  }

  VariantFormData copyWith({
    String? sku,
    String? barcode,
    String? name,
    Map<String, dynamic>? attributes,
    double? currentStock,
    double? minStock,
    double? reorderPoint,
    double? priceAdjustment,
    double? purchasePriceAdjustment,
    double? salePrice,
    double? purchasePrice,
    String? mainImage,
    List<String>? images,
    double? weight,
    VariantDimensions? dimensions,
    bool? isActive,
    int? sortOrder,
    String? notes,
  }) {
    return VariantFormData(
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      attributes: attributes ?? this.attributes,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      purchasePriceAdjustment: purchasePriceAdjustment ?? this.purchasePriceAdjustment,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      notes: notes ?? this.notes,
    );
  }
}
