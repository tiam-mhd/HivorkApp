import 'package:json_annotation/json_annotation.dart';
import '../enums/purchase_order_enums.dart';
import 'purchase_order_item_model.dart';

part 'purchase_order_model.g.dart';

/// Purchase Order Model
/// مطابق 100% با backend: PurchaseOrder entity
@JsonSerializable()
class PurchaseOrderModel {
  final String id;
  final String businessId;
  final String supplierId;
  final String orderNumber;
  final PurchaseOrderType type;
  final PurchaseOrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String currency;
  final String subtotal;
  final String taxRate;
  final String taxAmount;
  final String discountAmount;
  final String shippingCost;
  final String otherCharges;
  final String totalAmount;
  final String paidAmount;
  final String remainingAmount;
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
  final List<String> attachments;
  final List<String> tags;
  final Map<String, dynamic>? customFields;
  final String? createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? sentAt;
  final DateTime? confirmedAt;
  final DateTime? closedAt;
  final String? linkedB2bOrderId;
  final bool isB2bOrder;
  final List<PurchaseOrderItemModel> items;
  final SupplierInfo? supplier;
  final UserInfo? creator;
  final UserInfo? approver;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  PurchaseOrderModel({
    required this.id,
    required this.businessId,
    required this.supplierId,
    required this.orderNumber,
    this.type = PurchaseOrderType.standard,
    this.status = PurchaseOrderStatus.draft,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.currency = 'IRR',
    required this.subtotal,
    this.taxRate = '0',
    this.taxAmount = '0',
    this.discountAmount = '0',
    this.shippingCost = '0',
    this.otherCharges = '0',
    required this.totalAmount,
    this.paidAmount = '0',
    this.remainingAmount = '0',
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
    this.attachments = const [],
    this.tags = const [],
    this.customFields,
    this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.sentAt,
    this.confirmedAt,
    this.closedAt,
    this.linkedB2bOrderId,
    this.isB2bOrder = false,
    this.items = const [],
    this.supplier,
    this.creator,
    this.approver,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderModelToJson(this);
}

/// Supplier Info (populated)
@JsonSerializable()
class SupplierInfo {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? companyName;

  SupplierInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.companyName,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) =>
      _$SupplierInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierInfoToJson(this);
}

/// User Info (populated)
@JsonSerializable()
class UserInfo {
  final String id;
  final String name;
  final String? email;

  UserInfo({
    required this.id,
    required this.name,
    this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
