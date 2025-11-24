import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

// Converter برای تبدیل String به double
class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double value) => value;
}

enum CustomerType {
  @JsonValue('individual')
  individual,
  @JsonValue('company')
  company,
}

enum CustomerStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('blocked')
  blocked,
}

@JsonSerializable(fieldRename: FieldRename.none)
class Customer {
  final String id;
  final String customerCode;
  final String fullName;
  final CustomerType type;
  final String? phone;
  final String? email;
  final String? nationalId;
  
  // Company fields
  final String? companyName;
  final String? registrationNumber;
  final String? economicCode;
  final String? contactPerson;
  
  // Address
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  
  // Group
  final String? groupId;
  final String? groupName;
  final String? groupColor;
  final String? groupIcon;
  
  // User link
  final String? userId;
  
  // Classification
  final String? category;
  final String? source;
  
  // Financial
  @StringToDoubleConverter()
  final double creditLimit;
  @StringToDoubleConverter()
  final double currentBalance;
  final int paymentTermDays;
  @StringToDoubleConverter()
  final double discountRate;
  
  // Statistics
  final int totalOrders;
  @StringToDoubleConverter()
  final double totalPurchases;
  @StringToDoubleConverter()
  final double totalPayments;
  final DateTime? lastOrderDate;
  final DateTime? lastPaymentDate;
  
  // Additional info
  final DateTime? birthDate;
  final String? avatar;
  final String? notes;
  final List<String>? tags;
  final Map<String, dynamic>? customFields;
  
  final CustomerStatus status;
  final String businessId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.customerCode,
    required this.fullName,
    required this.type,
    this.phone,
    this.email,
    this.nationalId,
    this.companyName,
    this.registrationNumber,
    this.economicCode,
    this.contactPerson,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.groupId,
    this.groupName,
    this.groupColor,
    this.groupIcon,
    this.userId,
    this.category,
    this.source,
    this.creditLimit = 0,
    this.currentBalance = 0,
    this.paymentTermDays = 0,
    this.discountRate = 0,
    this.totalOrders = 0,
    this.totalPurchases = 0,
    this.totalPayments = 0,
    this.lastOrderDate,
    this.lastPaymentDate,
    this.birthDate,
    this.avatar,
    this.notes,
    this.tags,
    this.customFields,
    required this.status,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    Customer customer = _$CustomerFromJson(json);
    
    // بررسی groupId - اگر null باشه، گروه عمومی است
    if (json['groupId'] == null) {
      print('⚠️ [CUSTOMER] groupId is null, customer is in general group');
      // باید یک کپی جدید بسازیم با groupName, groupColor, groupIcon = null
      customer = Customer(
        id: customer.id,
        customerCode: customer.customerCode,
        fullName: customer.fullName,
        type: customer.type,
        phone: customer.phone,
        email: customer.email,
        nationalId: customer.nationalId,
        companyName: customer.companyName,
        registrationNumber: customer.registrationNumber,
        economicCode: customer.economicCode,
        contactPerson: customer.contactPerson,
        address: customer.address,
        city: customer.city,
        province: customer.province,
        postalCode: customer.postalCode,
        country: customer.country,
        groupId: null,
        groupName: null,
        groupColor: null,
        groupIcon: null,
        category: customer.category,
        source: customer.source,
        creditLimit: customer.creditLimit,
        currentBalance: customer.currentBalance,
        paymentTermDays: customer.paymentTermDays,
        discountRate: customer.discountRate,
        totalOrders: customer.totalOrders,
        totalPurchases: customer.totalPurchases,
        totalPayments: customer.totalPayments,
        lastOrderDate: customer.lastOrderDate,
        lastPaymentDate: customer.lastPaymentDate,
        birthDate: customer.birthDate,
        avatar: customer.avatar,
        notes: customer.notes,
        tags: customer.tags,
        customFields: customer.customFields,
        status: customer.status,
        businessId: customer.businessId,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
      );
      return customer;
    }
    
    // اگر group به صورت relation آمده، اطلاعات آن را استخراج کن
    if (json['group'] != null && json['group'] is Map) {
      final group = json['group'] as Map<String, dynamic>;
      print('🔄 [CUSTOMER] Parsing group: ${group['name']} (${group['color']})');
      return customer.copyWith(
        groupName: group['name'] as String?,
        groupColor: group['color'] as String?,
        groupIcon: group['icon'] as String?,
      );
    }
    
    return customer;
  }

  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer copyWith({
    String? id,
    String? customerCode,
    String? fullName,
    CustomerType? type,
    String? phone,
    String? email,
    String? nationalId,
    String? companyName,
    String? registrationNumber,
    String? economicCode,
    String? contactPerson,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    String? groupId,
    String? groupName,
    String? groupColor,
    String? groupIcon,
    String? userId,
    String? category,
    String? source,
    double? creditLimit,
    double? currentBalance,
    int? paymentTermDays,
    double? discountRate,
    int? totalOrders,
    double? totalPurchases,
    double? totalPayments,
    DateTime? lastOrderDate,
    DateTime? lastPaymentDate,
    DateTime? birthDate,
    String? avatar,
    String? notes,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    CustomerStatus? status,
    String? businessId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      fullName: fullName ?? this.fullName,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      companyName: companyName ?? this.companyName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      economicCode: economicCode ?? this.economicCode,
      contactPerson: contactPerson ?? this.contactPerson,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupColor: groupColor ?? this.groupColor,
      groupIcon: groupIcon ?? this.groupIcon,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      source: source ?? this.source,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      paymentTermDays: paymentTermDays ?? this.paymentTermDays,
      discountRate: discountRate ?? this.discountRate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalPayments: totalPayments ?? this.totalPayments,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      birthDate: birthDate ?? this.birthDate,
      avatar: avatar ?? this.avatar,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      status: status ?? this.status,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get hasDebt => currentBalance < 0;
  bool get hasCredit => currentBalance > 0;
  bool get isActive => status == CustomerStatus.active;
  bool get isCompany => type == CustomerType.company;
  
  String get displayName => isCompany && companyName != null 
      ? companyName! 
      : fullName;
      
  String get groupDisplayName => groupName ?? 'عمومی';
}
