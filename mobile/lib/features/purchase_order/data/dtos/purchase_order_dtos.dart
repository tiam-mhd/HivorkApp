import '../enums/purchase_order_enums.dart';

/// Create Purchase Order Item DTO
/// مطابق 100% با backend: CreatePurchaseOrderItemDto
class CreatePurchaseOrderItemDto {
  final String? productId;
  final String? productVariantId;
  final String productName;
  final String? sku;
  final String? barcode;
  final String? description;
  double quantity; // non-final to allow quantity updates in UI
  final String? unit;
  final double unitPrice;
  final double discountPercent;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final String? notes;
  final Map<String, dynamic>? customFields;

  CreatePurchaseOrderItemDto({
    this.productId,
    this.productVariantId,
    required this.productName,
    this.sku,
    this.barcode,
    this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.notes,
    this.customFields,
  });

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (productVariantId != null) 'productVariantId': productVariantId,
      'productName': productName,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (description != null) 'description': description,
      'quantity': quantity,
      if (unit != null) 'unit': unit,
      'unitPrice': unitPrice,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      if (notes != null) 'notes': notes,
      if (customFields != null) 'customFields': customFields,
    };
  }

  factory CreatePurchaseOrderItemDto.fromJson(Map<String, dynamic> json) {
    return CreatePurchaseOrderItemDto(
      productId: json['productId'] as String?,
      productVariantId: json['productVariantId'] as String?,
      productName: json['productName'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }
}

/// Create Purchase Order DTO
/// مطابق 100% با backend: CreatePurchaseOrderDto
class CreatePurchaseOrderDto {
  final String supplierId;
  final String orderNumber;
  final PurchaseOrderType type;
  final PurchaseOrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final String currency;
  final double taxRate;
  final double discountAmount;
  final double shippingCost;
  final double otherCharges;
  final int paymentTermDays;
  final String? paymentMethod;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryProvince;
  final String? deliveryPostalCode;
  final String? incoterm;
  final String? trackingNumber;
  final String? shippingCompany;
  final String? notes;
  final String? internalNotes;
  final String? termsAndConditions;
  final String? attachments;
  final String? tags;
  final Map<String, dynamic>? customFields;
  final String? linkedB2bOrderId;
  final bool isB2bOrder;
  final List<CreatePurchaseOrderItemDto> items;

  CreatePurchaseOrderDto({
    required this.supplierId,
    required this.orderNumber,
    this.type = PurchaseOrderType.standard,
    this.status = PurchaseOrderStatus.draft,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.currency = 'IRR',
    this.taxRate = 0,
    this.discountAmount = 0,
    this.shippingCost = 0,
    this.otherCharges = 0,
    this.paymentTermDays = 0,
    this.paymentMethod,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryProvince,
    this.deliveryPostalCode,
    this.incoterm,
    this.trackingNumber,
    this.shippingCompany,
    this.notes,
    this.internalNotes,
    this.termsAndConditions,
    this.attachments,
    this.tags,
    this.customFields,
    this.linkedB2bOrderId,
    this.isB2bOrder = false,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'orderNumber': orderNumber,
      'type': type.name,
      'status': status.name,
      'orderDate': orderDate.toIso8601String(),
      if (expectedDeliveryDate != null)
        'expectedDeliveryDate': expectedDeliveryDate!.toIso8601String(),
      'currency': currency,
      'taxRate': taxRate,
      'discountAmount': discountAmount,
      'shippingCost': shippingCost,
      'otherCharges': otherCharges,
      'paymentTermDays': paymentTermDays,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (deliveryCity != null) 'deliveryCity': deliveryCity,
      if (deliveryProvince != null) 'deliveryProvince': deliveryProvince,
      if (deliveryPostalCode != null) 'deliveryPostalCode': deliveryPostalCode,
      if (incoterm != null) 'incoterm': incoterm,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (shippingCompany != null) 'shippingCompany': shippingCompany,
      if (notes != null) 'notes': notes,
      if (internalNotes != null) 'internalNotes': internalNotes,
      if (termsAndConditions != null) 'termsAndConditions': termsAndConditions,
      if (attachments != null) 'attachments': attachments,
      if (tags != null) 'tags': tags,
      if (customFields != null) 'customFields': customFields,
      if (linkedB2bOrderId != null) 'linkedB2bOrderId': linkedB2bOrderId,
      'isB2bOrder': isB2bOrder,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Update Purchase Order DTO
/// مطابق 100% با backend: UpdatePurchaseOrderDto (همه optional)
class UpdatePurchaseOrderDto {
  final String? supplierId;
  final PurchaseOrderType? type;
  final PurchaseOrderStatus? status;
  final DateTime? orderDate;
  final DateTime? expectedDeliveryDate;
  final String? currency;
  final double? taxRate;
  final double? discountAmount;
  final double? shippingCost;
  final double? otherCharges;
  final int? paymentTermDays;
  final String? paymentMethod;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryProvince;
  final String? deliveryPostalCode;
  final String? incoterm;
  final String? trackingNumber;
  final String? shippingCompany;
  final String? notes;
  final String? internalNotes;
  final String? termsAndConditions;
  final String? attachments;
  final String? tags;
  final Map<String, dynamic>? customFields;
  final String? linkedB2bOrderId;
  final bool? isB2bOrder;
  final List<CreatePurchaseOrderItemDto>? items;

  UpdatePurchaseOrderDto({
    this.supplierId,
    this.type,
    this.status,
    this.orderDate,
    this.expectedDeliveryDate,
    this.currency,
    this.taxRate,
    this.discountAmount,
    this.shippingCost,
    this.otherCharges,
    this.paymentTermDays,
    this.paymentMethod,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryProvince,
    this.deliveryPostalCode,
    this.incoterm,
    this.trackingNumber,
    this.shippingCompany,
    this.notes,
    this.internalNotes,
    this.termsAndConditions,
    this.attachments,
    this.tags,
    this.customFields,
    this.linkedB2bOrderId,
    this.isB2bOrder,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (supplierId != null) 'supplierId': supplierId,
      if (type != null) 'type': type!.name,
      if (status != null) 'status': status!.name,
      if (orderDate != null) 'orderDate': orderDate!.toIso8601String(),
      if (expectedDeliveryDate != null)
        'expectedDeliveryDate': expectedDeliveryDate!.toIso8601String(),
      if (currency != null) 'currency': currency,
      if (taxRate != null) 'taxRate': taxRate,
      if (discountAmount != null) 'discountAmount': discountAmount,
      if (shippingCost != null) 'shippingCost': shippingCost,
      if (otherCharges != null) 'otherCharges': otherCharges,
      if (paymentTermDays != null) 'paymentTermDays': paymentTermDays,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (deliveryCity != null) 'deliveryCity': deliveryCity,
      if (deliveryProvince != null) 'deliveryProvince': deliveryProvince,
      if (deliveryPostalCode != null) 'deliveryPostalCode': deliveryPostalCode,
      if (incoterm != null) 'incoterm': incoterm,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (shippingCompany != null) 'shippingCompany': shippingCompany,
      if (notes != null) 'notes': notes,
      if (internalNotes != null) 'internalNotes': internalNotes,
      if (termsAndConditions != null) 'termsAndConditions': termsAndConditions,
      if (attachments != null) 'attachments': attachments,
      if (tags != null) 'tags': tags,
      if (customFields != null) 'customFields': customFields,
      if (linkedB2bOrderId != null) 'linkedB2bOrderId': linkedB2bOrderId,
      if (isB2bOrder != null) 'isB2bOrder': isB2bOrder,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
    };
  }
}

/// Filter Purchase Order DTO
/// مطابق 100% با backend: FilterPurchaseOrderDto
class FilterPurchaseOrderDto {
  final String? search;
  final String? supplierId;
  final PurchaseOrderType? type;
  final PurchaseOrderStatus? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final DateTime? fromDeliveryDate;
  final DateTime? toDeliveryDate;
  final double? minAmount;
  final double? maxAmount;
  final bool? isB2bOrder;
  final String? tags;
  final int page;
  final int limit;
  final String? sortBy;
  final String sortOrder;

  FilterPurchaseOrderDto({
    this.search,
    this.supplierId,
    this.type,
    this.status,
    this.fromDate,
    this.toDate,
    this.fromDeliveryDate,
    this.toDeliveryDate,
    this.minAmount,
    this.maxAmount,
    this.isB2bOrder,
    this.tags,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder = 'DESC',
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (search != null && search!.isNotEmpty) 'search': search,
      if (supplierId != null) 'supplierId': supplierId,
      if (type != null) 'type': type!.name,
      if (status != null) 'status': status!.name,
      if (fromDate != null) 'fromDate': fromDate!.toIso8601String(),
      if (toDate != null) 'toDate': toDate!.toIso8601String(),
      if (fromDeliveryDate != null) 'fromDeliveryDate': fromDeliveryDate!.toIso8601String(),
      if (toDeliveryDate != null) 'toDeliveryDate': toDeliveryDate!.toIso8601String(),
      if (minAmount != null) 'minAmount': minAmount.toString(),
      if (maxAmount != null) 'maxAmount': maxAmount.toString(),
      if (isB2bOrder != null) 'isB2bOrder': isB2bOrder.toString(),
      if (tags != null) 'tags': tags,
      'page': page.toString(),
      'limit': limit.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }
}
