import '../../../customer/data/models/customer.dart';
import '../../../product/data/models/product.dart';
import '../../../product/data/models/product_variant.dart';
import '../../../business/data/models/business_model.dart';

// Helper function to safely parse numeric values from API
double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

// Helper function to safely parse int values from API
int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

// Enums
enum InvoiceType {
  sales('sales', 'فاکتور فروش'),
  proforma('proforma', 'پیش‌فاکتور'),
  purchase('purchase', 'فاکتور خرید'),
  returned('return', 'فاکتور برگشتی');

  final String value;
  final String label;
  const InvoiceType(this.value, this.label);

  static InvoiceType fromString(String value) {
    return InvoiceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InvoiceType.sales,
    );
  }
}

enum InvoiceStatus {
  draft('draft', 'پیش‌نویس'),
  finalized('finalized', 'نهایی'),
  cancelled('cancelled', 'لغو شده'),
  returned('returned', 'برگشت خورده');

  final String value;
  final String label;
  const InvoiceStatus(this.value, this.label);

  static InvoiceStatus fromString(String value) {
    return InvoiceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InvoiceStatus.draft,
    );
  }
}

enum PaymentStatus {
  unpaid('unpaid', 'پرداخت نشده'),
  partial('partial', 'پرداخت جزئی'),
  paid('paid', 'پرداخت شده');

  final String value;
  final String label;
  const PaymentStatus(this.value, this.label);

  static PaymentStatus? fromString(String? value) {
    if (value == null) return null;
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

enum ShippingStatus {
  pending('pending', 'ارسال نشده'),
  processing('processing', 'در حال ارسال'),
  shipped('shipped', 'ارسال شده'),
  delivered('delivered', 'تحویل داده شده');

  final String value;
  final String label;
  const ShippingStatus(this.value, this.label);

  static ShippingStatus? fromString(String? value) {
    if (value == null) return null;
    return ShippingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShippingStatus.pending,
    );
  }
}

enum DiscountType {
  percentage('percentage', 'درصدی'),
  amount('amount', 'مبلغی');

  final String value;
  final String label;
  const DiscountType(this.value, this.label);

  static DiscountType? fromString(String? value) {
    if (value == null) return null;
    return DiscountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DiscountType.percentage,
    );
  }
}

enum PaymentMethod {
  cash('cash', 'نقد'),
  card('card', 'کارت'),
  check('check', 'چک'),
  bankTransfer('bank_transfer', 'انتقال بانکی'),
  credit('credit', 'اعتباری'),
  other('other', 'سایر');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

// Invoice Item Model
class InvoiceItem {
  final String? id;
  final String? productId;
  final String? variantId;
  final String productName;
  final String? description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double taxRate;
  final double taxAmount;
  final double discountRate;
  final double discountAmount;
  final double totalPrice;
  final int sortOrder;
  
  // Nested objects
  final Product? product;
  final ProductVariant? variant;

  InvoiceItem({
    this.id,
    this.productId,
    this.variantId,
    required this.productName,
    this.description,
    required this.quantity,
    this.unit = 'عدد',
    required this.unitPrice,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.discountRate = 0,
    this.discountAmount = 0,
    required this.totalPrice,
    this.sortOrder = 1,
    this.product,
    this.variant,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      productId: json['productId'],
      variantId: json['variantId'],
      productName: json['productName'] ?? '',
      description: json['description'],
      quantity: _parseDouble(json['quantity']),
      unit: json['unit'] ?? 'عدد',
      unitPrice: _parseDouble(json['unitPrice']),
      taxRate: _parseDouble(json['taxRate']),
      taxAmount: _parseDouble(json['taxAmount']),
      discountRate: _parseDouble(json['discountRate']),
      discountAmount: _parseDouble(json['discountAmount']),
      totalPrice: _parseDouble(json['totalPrice']),
      sortOrder: _parseInt(json['sortOrder'], 1),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      variant: json['variant'] != null ? ProductVariant.fromJson(json['variant']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'productId': productId,
      if (variantId != null) 'variantId': variantId,
      'productName': productName,
      if (description != null) 'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'totalPrice': totalPrice,
      'sortOrder': sortOrder,
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? productName,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? taxRate,
    double? taxAmount,
    double? discountRate,
    double? discountAmount,
    double? totalPrice,
    int? sortOrder,
    Product? product,
    ProductVariant? variant,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      sortOrder: sortOrder ?? this.sortOrder,
      product: product ?? this.product,
      variant: variant ?? this.variant,
    );
  }
}

// Invoice Extra Cost Model
class InvoiceExtraCost {
  final String? id;
  final String title;
  final double amount;
  final String? description;
  final int sortOrder;

  InvoiceExtraCost({
    this.id,
    required this.title,
    required this.amount,
    this.description,
    this.sortOrder = 1,
  });

  factory InvoiceExtraCost.fromJson(Map<String, dynamic> json) {
    return InvoiceExtraCost(
      id: json['id'],
      title: json['title'] ?? '',
      amount: _parseDouble(json['amount']),
      description: json['description'],
      sortOrder: _parseInt(json['sortOrder'], 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      if (description != null) 'description': description,
      'sortOrder': sortOrder,
    };
  }

  InvoiceExtraCost copyWith({
    String? id,
    String? title,
    double? amount,
    String? description,
    int? sortOrder,
  }) {
    return InvoiceExtraCost(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Invoice Payment Model
class InvoicePayment {
  final String? id;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final DateTime? createdAt;

  InvoicePayment({
    this.id,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.createdAt,
  });

  factory InvoicePayment.fromJson(Map<String, dynamic> json) {
    return InvoicePayment(
      id: json['id'],
      amount: _parseDouble(json['amount']),
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentMethod: PaymentMethod.fromString(json['paymentMethod']),
      referenceNumber: json['referenceNumber'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod.value,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

// Main Invoice Model
class Invoice {
  final String? id;
  final String invoiceNumber;
  final InvoiceType type;
  final InvoiceStatus status;
  final String businessId;
  final String customerId;
  final String? customerName;
  final DateTime issueDate;
  final DateTime? dueDate;
  final double subtotal;
  final DiscountType? discountType;
  final double? discountValue;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final double extraCostsTotal;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final PaymentStatus? paymentStatus;
  final ShippingStatus? shippingStatus;
  final String? notes;
  final String? internalNotes;
  final String? terms;
  final DateTime? paymentDate;
  final DateTime? shippingDate;
  final List<InvoiceItem> items;
  final List<InvoiceExtraCost> extraCosts;
  final List<InvoicePayment> payments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Nested objects
  final Customer? customer;
  final Business? business;
  final String? createdById;
  final String? updatedById;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.type,
    required this.status,
    required this.businessId,
    required this.customerId,
    this.customerName,
    required this.issueDate,
    this.dueDate,
    required this.subtotal,
    this.discountType,
    this.discountValue,
    required this.discountAmount,
    this.taxRate = 9.0,
    required this.taxAmount,
    required this.extraCostsTotal,
    required this.totalAmount,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.paymentStatus,
    this.shippingStatus,
    this.notes,
    this.internalNotes,
    this.terms,
    this.paymentDate,
    this.shippingDate,
    this.items = const [],
    this.extraCosts = const [],
    this.payments = const [],
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.business,
    this.createdById,
    this.updatedById,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
      print('[Invoice.fromJson] id type: \\${json['id'] != null ? json['id'].runtimeType : 'null'}, value: \\${json['id'] ?? 'null'}');
      final dynamic createdByRaw = json['createdBy'];
      final dynamic updatedByRaw = json['updatedBy'];
      final String? createdById = createdByRaw is Map<String, dynamic> ? createdByRaw['id'] : createdByRaw as String?;
      final String? updatedById = updatedByRaw is Map<String, dynamic> ? updatedByRaw['id'] : updatedByRaw as String?;
      return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      type: InvoiceType.fromString(json['type']),
      status: InvoiceStatus.fromString(json['status']),
      businessId: json['businessId'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customer']?['fullName'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      subtotal: _parseDouble(json['subtotal']),
      discountType: DiscountType.fromString(json['discountType']),
      discountValue: json['discountValue'] != null ? _parseDouble(json['discountValue']) : null,
      discountAmount: _parseDouble(json['discountAmount']),
      taxRate: _parseDouble(json['taxRate'], 9.0),
      taxAmount: _parseDouble(json['taxAmount']),
      extraCostsTotal: _parseDouble(json['extraCostsTotal']),
      totalAmount: _parseDouble(json['totalAmount']),
      paidAmount: _parseDouble(json['paidAmount']),
      remainingAmount: _parseDouble(json['remainingAmount']),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus']),
      shippingStatus: ShippingStatus.fromString(json['shippingStatus']),
      notes: json['notes'],
      internalNotes: json['internalNotes'],
      terms: json['terms'],
      paymentDate: json['paymentDate'] != null 
          ? DateTime.parse(json['paymentDate']) 
          : null,
      shippingDate: json['shippingDate'] != null 
          ? DateTime.parse(json['shippingDate']) 
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => InvoiceItem.fromJson(i)).toList()
          : [],
      extraCosts: json['extraCosts'] != null
          ? (json['extraCosts'] as List).map((i) => InvoiceExtraCost.fromJson(i)).toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List).map((i) => InvoicePayment.fromJson(i)).toList()
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      business: json['business'] != null ? Business.fromJson(json['business']) : null,
      createdById: createdById,
      updatedById: updatedById,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'type': type.value,
      'status': status.value,
      'businessId': businessId,
      'customerId': customerId,
      'issueDate': issueDate.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'subtotal': subtotal,
      if (discountType != null) 'discountType': discountType!.value,
      if (discountValue != null) 'discountValue': discountValue,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'extraCostsTotal': extraCostsTotal,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      if (paymentStatus != null) 'paymentStatus': paymentStatus!.value,
      if (shippingStatus != null) 'shippingStatus': shippingStatus!.value,
      if (notes != null) 'notes': notes,
      if (internalNotes != null) 'internalNotes': internalNotes,
      if (terms != null) 'terms': terms,
      if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
      if (shippingDate != null) 'shippingDate': shippingDate!.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'extraCosts': extraCosts.map((i) => i.toJson()).toList(),
      'payments': payments.map((i) => i.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
