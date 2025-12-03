import 'package:json_annotation/json_annotation.dart';

part 'supplier_model.g.dart';

enum SupplierStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('suspended')
  suspended,
  @JsonValue('blocked')
  blocked,
  @JsonValue('archived')
  archived,
}

enum SupplierType {
  @JsonValue('manufacturer')
  manufacturer,
  @JsonValue('distributor')
  distributor,
  @JsonValue('wholesaler')
  wholesaler,
  @JsonValue('importer')
  importer,
  @JsonValue('service')
  service,
  @JsonValue('freelancer')
  freelancer,
  @JsonValue('other')
  other,
}

extension SupplierStatusExtension on SupplierStatus {
  String get statusText {
    switch (this) {
      case SupplierStatus.draft:
        return 'پیش‌نویس';
      case SupplierStatus.pending:
        return 'در انتظار تایید';
      case SupplierStatus.approved:
        return 'تایید شده';
      case SupplierStatus.suspended:
        return 'معلق';
      case SupplierStatus.blocked:
        return 'مسدود';
      case SupplierStatus.archived:
        return 'بایگانی شده';
    }
  }
}

extension SupplierTypeExtension on SupplierType {
  String get typeText {
    switch (this) {
      case SupplierType.manufacturer:
        return 'تولیدکننده';
      case SupplierType.distributor:
        return 'توزیع‌کننده';
      case SupplierType.wholesaler:
        return 'عمده‌فروش';
      case SupplierType.importer:
        return 'واردکننده';
      case SupplierType.service:
        return 'خدماتی';
      case SupplierType.freelancer:
        return 'فریلنسر';
      case SupplierType.other:
        return 'سایر';
    }
  }
}

@JsonSerializable()
class Supplier {
  final String id;
  final String businessId;
  final String code;
  final String name;
  final String? legalName;
  final SupplierType type;
  final SupplierStatus status;
  
  // IDs
  final String? taxId;
  final String? nationalId;
  final String? registrationNumber;
  final String? economicCode;
  
  // Contact
  final String? phone;
  final String? email;
  final String? website;
  
  // Address
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String country;
  
  // Financial
  final String currency;
  final int paymentTermDays;
  final String? paymentTermType;
  final int defaultLeadTimeDays;
  final String? incoterm;
  final String creditLimit;
  
  // Ratings & Stats
  final String qualityRating;
  final String onTimeDeliveryRate;
  final int totalOrders;
  final String totalPurchaseAmount;
  final DateTime? lastOrderDate;
  final DateTime? lastPaymentDate;
  final String currentDebt;
  final String totalPaid;
  
  // Additional Info
  final String? description;
  final String? notes;
  final List<String>? tags;
  final String? industry;
  final Map<String, dynamic>? customFields;
  
  // Business Linking
  final String? linkedBusinessId;
  final bool isLinkedBusiness;
  final DateTime? linkedAt;
  
  // Approval
  final DateTime? onboardingDate;
  final DateTime? approvedAt;
  final String? approvedBy;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Supplier({
    required this.id,
    required this.businessId,
    required this.code,
    required this.name,
    this.legalName,
    this.type = SupplierType.distributor,
    this.status = SupplierStatus.draft,
    this.taxId,
    this.nationalId,
    this.registrationNumber,
    this.economicCode,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country = 'Iran',
    this.currency = 'IRR',
    this.paymentTermDays = 0,
    this.paymentTermType,
    this.defaultLeadTimeDays = 7,
    this.incoterm,
    this.creditLimit = '0',
    this.qualityRating = '0',
    this.onTimeDeliveryRate = '100',
    this.totalOrders = 0,
    this.totalPurchaseAmount = '0',
    this.lastOrderDate,
    this.lastPaymentDate,
    this.currentDebt = '0',
    this.totalPaid = '0',
    this.description,
    this.notes,
    this.tags,
    this.industry,
    this.customFields,
    this.linkedBusinessId,
    this.isLinkedBusiness = false,
    this.linkedAt,
    this.onboardingDate,
    this.approvedAt,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierToJson(this);

  bool get isActive => status == SupplierStatus.approved;
  bool get isDraft => status == SupplierStatus.draft;
  bool get isPending => status == SupplierStatus.pending;
  bool get isSuspended => status == SupplierStatus.suspended;
  bool get isBlocked => status == SupplierStatus.blocked;
  bool get isArchived => status == SupplierStatus.archived;
  
  // Helper for balance display (debt - paid)
  double get balance => (double.tryParse(currentDebt) ?? 0.0) - (double.tryParse(totalPaid) ?? 0.0);
  bool get hasDebt => balance > 0;
  
  // Compatibility getters for UI
  int? get paymentTerms => paymentTermDays;
  String get statusText => status.statusText;
}
