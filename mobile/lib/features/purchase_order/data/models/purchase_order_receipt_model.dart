import 'package:json_annotation/json_annotation.dart';
import '../enums/purchase_order_enums.dart';
import 'purchase_order_item_model.dart';

part 'purchase_order_receipt_model.g.dart';

/// Purchase Order Receipt Model
/// مطابق 100% با backend: PurchaseOrderReceipt entity
@JsonSerializable()
class PurchaseOrderReceiptModel {
  final String id;
  final String purchaseOrderId;
  final String receiptNumber;
  final ReceiptStatus status;
  final DateTime receiptDate;
  final String? receivedBy;
  final String? notes;
  final List<String> attachments;
  final String? createdBy;
  final List<PurchaseOrderReceiptItemModel> items;
  final UserInfo? creator;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  PurchaseOrderReceiptModel({
    required this.id,
    required this.purchaseOrderId,
    required this.receiptNumber,
    this.status = ReceiptStatus.draft,
    required this.receiptDate,
    this.receivedBy,
    this.notes,
    this.attachments = const [],
    this.createdBy,
    this.items = const [],
    this.creator,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory PurchaseOrderReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderReceiptModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderReceiptModelToJson(this);
}

/// Purchase Order Receipt Item Model
/// مطابق 100% با backend: PurchaseOrderReceiptItem entity
@JsonSerializable()
class PurchaseOrderReceiptItemModel {
  final String id;
  final String receiptId;
  final String purchaseOrderItemId;
  final String receivedQuantity;
  final String rejectedQuantity;
  final String? rejectionReason;
  final String? notes;
  final PurchaseOrderItemModel? purchaseOrderItem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseOrderReceiptItemModel({
    required this.id,
    required this.receiptId,
    required this.purchaseOrderItemId,
    required this.receivedQuantity,
    this.rejectedQuantity = '0',
    this.rejectionReason,
    this.notes,
    this.purchaseOrderItem,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrderReceiptItemModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderReceiptItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderReceiptItemModelToJson(this);
}

/// User Info (for creator)
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
