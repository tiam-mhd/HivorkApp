import 'package:json_annotation/json_annotation.dart';
import '../enums/purchase_order_enums.dart';

part 'purchase_order_payment_model.g.dart';

/// Purchase Order Payment Model
/// مطابق 100% با backend: PurchaseOrderPayment entity
@JsonSerializable()
class PurchaseOrderPaymentModel {
  final String id;
  final String purchaseOrderId;
  final String paymentNumber;
  final PaymentStatus status;
  final DateTime paymentDate;
  final String amount;
  final String currency;
  final PaymentMethod method;
  final String? referenceNumber;
  final String? transactionId;
  final String? notes;
  final List<String> attachments;
  final String? createdBy;
  final UserInfo? creator;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  PurchaseOrderPaymentModel({
    required this.id,
    required this.purchaseOrderId,
    required this.paymentNumber,
    this.status = PaymentStatus.pending,
    required this.paymentDate,
    required this.amount,
    this.currency = 'IRR',
    required this.method,
    this.referenceNumber,
    this.transactionId,
    this.notes,
    this.attachments = const [],
    this.createdBy,
    this.creator,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory PurchaseOrderPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderPaymentModelToJson(this);
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
