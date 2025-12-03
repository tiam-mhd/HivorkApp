import '../enums/purchase_order_enums.dart';

/// Create Payment DTO
/// مطابق 100% با backend: CreatePaymentDto
class CreatePaymentDto {
  final String purchaseOrderId;
  final String paymentNumber;
  final PaymentStatus status;
  final DateTime paymentDate;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final String? referenceNumber;
  final String? transactionId;
  final String? notes;
  final String? attachments;

  CreatePaymentDto({
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
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrderId': purchaseOrderId,
      'paymentNumber': paymentNumber,
      'status': status.name,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'method': method.name,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (transactionId != null) 'transactionId': transactionId,
      if (notes != null) 'notes': notes,
      if (attachments != null) 'attachments': attachments,
    };
  }

  factory CreatePaymentDto.fromJson(Map<String, dynamic> json) {
    return CreatePaymentDto(
      purchaseOrderId: json['purchaseOrderId'] as String,
      paymentNumber: json['paymentNumber'] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'IRR',
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
      ),
      referenceNumber: json['referenceNumber'] as String?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      attachments: json['attachments'] as String?,
    );
  }
}

/// Update Payment DTO
/// مطابق 100% با backend: UpdatePaymentDto (همه optional)
class UpdatePaymentDto {
  final String? paymentNumber;
  final PaymentStatus? status;
  final DateTime? paymentDate;
  final double? amount;
  final String? currency;
  final PaymentMethod? method;
  final String? referenceNumber;
  final String? transactionId;
  final String? notes;
  final String? attachments;

  UpdatePaymentDto({
    this.paymentNumber,
    this.status,
    this.paymentDate,
    this.amount,
    this.currency,
    this.method,
    this.referenceNumber,
    this.transactionId,
    this.notes,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      if (paymentNumber != null) 'paymentNumber': paymentNumber,
      if (status != null) 'status': status!.name,
      if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (method != null) 'method': method!.name,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (transactionId != null) 'transactionId': transactionId,
      if (notes != null) 'notes': notes,
      if (attachments != null) 'attachments': attachments,
    };
  }

  factory UpdatePaymentDto.fromJson(Map<String, dynamic> json) {
    return UpdatePaymentDto(
      paymentNumber: json['paymentNumber'] as String?,
      status: json['status'] != null
          ? PaymentStatus.values.firstWhere(
              (e) => e.name == json['status'],
            )
          : null,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      method: json['method'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['method'],
            )
          : null,
      referenceNumber: json['referenceNumber'] as String?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      attachments: json['attachments'] as String?,
    );
  }
}
