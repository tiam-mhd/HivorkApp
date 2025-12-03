import 'expense_category.dart';

// Payment Method Enum
enum PaymentMethod {
  cash('cash', 'نقد'),
  card('card', 'کارت'),
  bankTransfer('bank_transfer', 'انتقال بانکی'),
  check('check', 'چک'),
  credit('credit', 'اعتباری'),
  other('other', 'سایر');

  final String value;
  final String label;

  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.other,
    );
  }
}

// Payment Status Enum
enum PaymentStatus {
  pending('pending', 'در انتظار'),
  paid('paid', 'پرداخت شده'),
  partiallyPaid('partially_paid', 'پرداخت جزئی'),
  cancelled('cancelled', 'لغو شده');

  final String value;
  final String label;

  const PaymentStatus(this.value, this.label);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

// Reference Type Enum
enum ReferenceType {
  productPurchase('product_purchase', 'خرید محصول'),
  salary('salary', 'حقوق'),
  supplierPayment('supplier_payment', 'پرداخت به تامین‌کننده'),
  rent('rent', 'اجاره'),
  utility('utility', 'خدمات عمومی'),
  other('other', 'سایر');

  final String value;
  final String label;

  const ReferenceType(this.value, this.label);

  static ReferenceType fromString(String value) {
    return ReferenceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReferenceType.other,
    );
  }
}

// Attachment Model
class ExpenseAttachment {
  final String url;
  final String filename;
  final String mimeType;
  final int size;

  ExpenseAttachment({
    required this.url,
    required this.filename,
    required this.mimeType,
    required this.size,
  });

  factory ExpenseAttachment.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachment(
      url: json['url'] as String,
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'mimeType': mimeType,
      'size': size,
    };
  }
}

// Recurring Rule Model
class RecurringRule {
  final String frequency; // daily, weekly, monthly, quarterly, yearly
  final int interval;
  final DateTime? endDate;

  RecurringRule({
    required this.frequency,
    required this.interval,
    this.endDate,
  });

  factory RecurringRule.fromJson(Map<String, dynamic> json) {
    return RecurringRule(
      frequency: json['frequency'] as String,
      interval: json['interval'] as int,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'interval': interval,
      'endDate': endDate?.toIso8601String(),
    };
  }
}

// Expense Model
class Expense {
  final String id;
  final String businessId;
  final String? categoryId;
  final String title;
  final String? description;
  final double amount;
  final DateTime expenseDate;
  final PaymentMethod? paymentMethod;
  final PaymentStatus paymentStatus;
  final ReferenceType? referenceType;
  final String? referenceId;
  final List<ExpenseAttachment> attachments;
  final bool isPaid;
  final List<String>? tags;
  final String? note;
  final bool isRecurring;
  final RecurringRule? recurringRule;
  final String createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations
  final ExpenseCategory? category;

  Expense({
    required this.id,
    required this.businessId,
    this.categoryId,
    required this.title,
    this.description,
    required this.amount,
    required this.expenseDate,
    this.paymentMethod,
    required this.paymentStatus,
    this.referenceType,
    this.referenceId,
    required this.attachments,
    required this.isPaid,
    this.tags,
    this.note,
    required this.isRecurring,
    this.recurringRule,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      categoryId: json['categoryId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: double.parse(json['amount'].toString()),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.fromString(json['paymentMethod'] as String)
          : null,
      paymentStatus: PaymentStatus.fromString(
        json['paymentStatus'] as String? ?? 'paid',
      ),
      referenceType: json['referenceType'] != null
          ? ReferenceType.fromString(json['referenceType'] as String)
          : null,
      referenceId: json['referenceId'] as String?,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((e) => ExpenseAttachment.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      isPaid: json['isPaid'] as bool? ?? true,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      note: json['note'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringRule: json['recurringRule'] != null
          ? RecurringRule.fromJson(json['recurringRule'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy'] as String,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      category: json['category'] != null
          ? ExpenseCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'paymentMethod': paymentMethod?.value,
      'paymentStatus': paymentStatus.value,
      'referenceType': referenceType?.value,
      'referenceId': referenceId,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'isPaid': isPaid,
      'tags': tags,
      'note': note,
      'isRecurring': isRecurring,
      'recurringRule': recurringRule?.toJson(),
      'createdBy': createdBy,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? businessId,
    String? categoryId,
    String? title,
    String? description,
    double? amount,
    DateTime? expenseDate,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    ReferenceType? referenceType,
    String? referenceId,
    List<ExpenseAttachment>? attachments,
    bool? isPaid,
    List<String>? tags,
    String? note,
    bool? isRecurring,
    RecurringRule? recurringRule,
    String? createdBy,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    ExpenseCategory? category,
  }) {
    return Expense(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      attachments: attachments ?? this.attachments,
      isPaid: isPaid ?? this.isPaid,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      category: category ?? this.category,
    );
  }

  // Helper getters
  bool get isApproved => approvedBy != null && approvedAt != null;
  bool get isPending => paymentStatus == PaymentStatus.pending;
  String get categoryName => category?.name ?? 'بدون دسته';
  String get paymentMethodLabel => paymentMethod?.label ?? '-';
  String get paymentStatusLabel => paymentStatus.label;
}
