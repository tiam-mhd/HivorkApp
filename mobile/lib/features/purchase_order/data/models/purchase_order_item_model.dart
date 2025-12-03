import 'package:json_annotation/json_annotation.dart';

part 'purchase_order_item_model.g.dart';

/// Purchase Order Item Model
/// مطابق 100% با backend: PurchaseOrderItem entity
@JsonSerializable()
class PurchaseOrderItemModel {
  final String id;
  final String purchaseOrderId;
  final String? productId;
  final String? productVariantId;
  final String productName;
  final String? sku;
  final String? barcode;
  final String? description;
  final String quantity;
  final String receivedQuantity;
  final String? unit;
  final String unitPrice;
  final String discountPercent;
  final String discountAmount;
  final String taxRate;
  final String taxAmount;
  final String totalPrice;
  final String? notes;
  final ProductInfo? product;
  final ProductVariantInfo? productVariant;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseOrderItemModel({
    required this.id,
    required this.purchaseOrderId,
    this.productId,
    this.productVariantId,
    required this.productName,
    this.sku,
    this.barcode,
    this.description,
    required this.quantity,
    this.receivedQuantity = '0',
    this.unit,
    required this.unitPrice,
    this.discountPercent = '0',
    this.discountAmount = '0',
    this.taxRate = '0',
    this.taxAmount = '0',
    required this.totalPrice,
    this.notes,
    this.product,
    this.productVariant,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderItemModelToJson(this);
}

/// Product Info (populated)
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

/// Product Variant Info (populated)
@JsonSerializable()
class ProductVariantInfo {
  final String id;
  final String? sku;
  final List<AttributeValue>? attributeValues;

  ProductVariantInfo({
    required this.id,
    this.sku,
    this.attributeValues,
  });

  factory ProductVariantInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductVariantInfoToJson(this);
}

@JsonSerializable()
class AttributeValue {
  final String name;
  final String value;

  AttributeValue({
    required this.name,
    required this.value,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) =>
      _$AttributeValueFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeValueToJson(this);
}
