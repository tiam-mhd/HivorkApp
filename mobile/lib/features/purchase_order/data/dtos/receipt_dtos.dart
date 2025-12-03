import '../enums/purchase_order_enums.dart';

/// Create Receipt Item DTO
/// مطابق 100% با backend: CreateReceiptItemDto
class CreateReceiptItemDto {
  final String purchaseOrderItemId;
  final double receivedQuantity;
  final double rejectedQuantity;
  final String? rejectionReason;
  final String? notes;

  CreateReceiptItemDto({
    required this.purchaseOrderItemId,
    required this.receivedQuantity,
    this.rejectedQuantity = 0,
    this.rejectionReason,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrderItemId': purchaseOrderItemId,
      'receivedQuantity': receivedQuantity,
      'rejectedQuantity': rejectedQuantity,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (notes != null) 'notes': notes,
    };
  }

  factory CreateReceiptItemDto.fromJson(Map<String, dynamic> json) {
    return CreateReceiptItemDto(
      purchaseOrderItemId: json['purchaseOrderItemId'] as String,
      receivedQuantity: (json['receivedQuantity'] as num).toDouble(),
      rejectedQuantity: (json['rejectedQuantity'] as num?)?.toDouble() ?? 0,
      rejectionReason: json['rejectionReason'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Create Receipt DTO
/// مطابق 100% با backend: CreateReceiptDto
class CreateReceiptDto {
  final String purchaseOrderId;
  final String receiptNumber;
  final ReceiptStatus status;
  final DateTime receiptDate;
  final String? receivedBy;
  final String? notes;
  final String? attachments;
  final List<CreateReceiptItemDto> items;

  CreateReceiptDto({
    required this.purchaseOrderId,
    required this.receiptNumber,
    this.status = ReceiptStatus.draft,
    required this.receiptDate,
    this.receivedBy,
    this.notes,
    this.attachments,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrderId': purchaseOrderId,
      'receiptNumber': receiptNumber,
      'status': status.name,
      'receiptDate': receiptDate.toIso8601String(),
      if (receivedBy != null) 'receivedBy': receivedBy,
      if (notes != null) 'notes': notes,
      if (attachments != null) 'attachments': attachments,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CreateReceiptDto.fromJson(Map<String, dynamic> json) {
    return CreateReceiptDto(
      purchaseOrderId: json['purchaseOrderId'] as String,
      receiptNumber: json['receiptNumber'] as String,
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceiptStatus.draft,
      ),
      receiptDate: DateTime.parse(json['receiptDate'] as String),
      receivedBy: json['receivedBy'] as String?,
      notes: json['notes'] as String?,
      attachments: json['attachments'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => CreateReceiptItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Update Receipt DTO
/// مطابق 100% با backend: UpdateReceiptDto (همه optional)
class UpdateReceiptDto {
  final String? receiptNumber;
  final ReceiptStatus? status;
  final DateTime? receiptDate;
  final String? receivedBy;
  final String? notes;
  final String? attachments;
  final List<CreateReceiptItemDto>? items;

  UpdateReceiptDto({
    this.receiptNumber,
    this.status,
    this.receiptDate,
    this.receivedBy,
    this.notes,
    this.attachments,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
      if (status != null) 'status': status!.name,
      if (receiptDate != null) 'receiptDate': receiptDate!.toIso8601String(),
      if (receivedBy != null) 'receivedBy': receivedBy,
      if (notes != null) 'notes': notes,
      if (attachments != null) 'attachments': attachments,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
    };
  }

  factory UpdateReceiptDto.fromJson(Map<String, dynamic> json) {
    return UpdateReceiptDto(
      receiptNumber: json['receiptNumber'] as String?,
      status: json['status'] != null
          ? ReceiptStatus.values.firstWhere(
              (e) => e.name == json['status'],
            )
          : null,
      receiptDate: json['receiptDate'] != null
          ? DateTime.parse(json['receiptDate'] as String)
          : null,
      receivedBy: json['receivedBy'] as String?,
      notes: json['notes'] as String?,
      attachments: json['attachments'] as String?,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => CreateReceiptItemDto.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
