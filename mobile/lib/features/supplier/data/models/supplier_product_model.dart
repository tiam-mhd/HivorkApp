import 'package:json_annotation/json_annotation.dart';

part 'supplier_product_model.g.dart';

@JsonSerializable()
class SupplierProduct {
  final String id;
  final String supplierId;
  final String? productId;
  final String? productVariantId;
  
  final String? supplierSku;
  final String? supplierProductName;
  final double purchasePrice;
  final String currency;
  final double? minOrderQuantity;
  final int? leadTimeDays;
  final bool isPreferred;
  final bool isActive;
  final int? priority;
  final double? discount;
  final DateTime? priceValidFrom;
  final DateTime? priceValidTo;
  final String? notes;
  final Map<String, dynamic>? customFields;
  
  // Populated fields (optional, from backend relations)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ProductInfo? product;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ProductVariantInfo? productVariant;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SupplierProduct({
    required this.id,
    required this.supplierId,
    this.productId,
    this.productVariantId,
    this.supplierSku,
    this.supplierProductName,
    required this.purchasePrice,
    this.currency = 'IRR',
    this.minOrderQuantity,
    this.leadTimeDays,
    this.isPreferred = false,
    this.isActive = true,
    this.priority,
    this.discount,
    this.priceValidFrom,
    this.priceValidTo,
    this.notes,
    this.customFields,
    this.product,
    this.productVariant,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SupplierProduct.fromJson(Map<String, dynamic> json) =>
      _$SupplierProductFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierProductToJson(this);

  String get displayName => supplierProductName ?? product?.name ?? 'بدون نام';
  
  bool get hasPriceValidity => priceValidFrom != null && priceValidTo != null;
  
  bool get isPriceValid {
    if (!hasPriceValidity) return true;
    final now = DateTime.now();
    return now.isAfter(priceValidFrom!) && now.isBefore(priceValidTo!);
  }
  
  double get effectivePrice {
    if (discount != null && discount! > 0) {
      return purchasePrice * (1 - discount! / 100);
    }
    return purchasePrice;
  }
}

// Helper classes for populated data
@JsonSerializable()
class ProductInfo {
  final String id;
  final String name;
  final String? sku;
  final String? imageUrl;

  ProductInfo({
    required this.id,
    required this.name,
    this.sku,
    this.imageUrl,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductInfoToJson(this);
}

@JsonSerializable()
class ProductVariantInfo {
  final String id;
  final String name;
  final String? sku;
  final String? imageUrl;

  ProductVariantInfo({
    required this.id,
    required this.name,
    this.sku,
    this.imageUrl,
  });

  factory ProductVariantInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantInfoToJson(this);
}
