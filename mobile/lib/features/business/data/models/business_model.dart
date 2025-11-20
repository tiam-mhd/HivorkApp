import 'business_metadata_model.dart';

enum BusinessStatus {
  active,
  inactive,
  suspended,
}

class BusinessSettings {
  final String? invoicePrefix;
  final String? invoiceNumberFormat;
  final double? taxRate;
  final bool? enableInventory;
  final int? lowStockThreshold;

  BusinessSettings({
    this.invoicePrefix,
    this.invoiceNumberFormat,
    this.taxRate,
    this.enableInventory,
    this.lowStockThreshold,
  });

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      invoicePrefix: json['invoicePrefix'],
      invoiceNumberFormat: json['invoiceNumberFormat'],
      taxRate: json['taxRate']?.toDouble(),
      enableInventory: json['enableInventory'],
      lowStockThreshold: json['lowStockThreshold'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (invoicePrefix != null) 'invoicePrefix': invoicePrefix,
      if (invoiceNumberFormat != null) 'invoiceNumberFormat': invoiceNumberFormat,
      if (taxRate != null) 'taxRate': taxRate,
      if (enableInventory != null) 'enableInventory': enableInventory,
      if (lowStockThreshold != null) 'lowStockThreshold': lowStockThreshold,
    };
  }
}

class Business {
  final String id;
  final String name;
  final String? tradeName;
  final String? categoryId;
  final BusinessCategory? category;
  final String? industryId;
  final BusinessIndustry? industry;
  final BusinessStatus status;
  final String? description;
  
  // اطلاعات ثبتی
  final String? nationalId;
  final String? registrationNumber;
  final String? economicCode;
  
  // اطلاعات تماس
  final String? phone;
  final String? email;
  final String? website;
  
  // آدرس
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  
  // تنظیمات
  final String? logo;
  final String currency;
  final String locale;
  final String timezone;
  final BusinessSettings? settings;
  
  // روابط
  final String ownerId;
  
  // تاریخ‌ها
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    this.tradeName,
    this.categoryId,
    this.category,
    this.industryId,
    this.industry,
    required this.status,
    this.description,
    this.nationalId,
    this.registrationNumber,
    this.economicCode,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.logo,
    required this.currency,
    required this.locale,
    required this.timezone,
    this.settings,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      tradeName: json['tradeName'],
      categoryId: json['categoryId'],
      category: json['category'] != null 
          ? BusinessCategory.fromJson(json['category']) 
          : null,
      industryId: json['industryId'],
      industry: json['industry'] != null 
          ? BusinessIndustry.fromJson(json['industry']) 
          : null,
      status: _parseBusinessStatus(json['status']),
      description: json['description'],
      nationalId: json['nationalId'],
      registrationNumber: json['registrationNumber'],
      economicCode: json['economicCode'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      logo: json['logo'],
      currency: json['currency'] ?? 'IRR',
      locale: json['locale'] ?? 'fa-IR',
      timezone: json['timezone'] ?? 'Asia/Tehran',
      settings: json['settings'] != null 
          ? BusinessSettings.fromJson(json['settings']) 
          : null,
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (tradeName != null) 'tradeName': tradeName,
      if (categoryId != null) 'categoryId': categoryId,
      if (category != null) 'category': category!.toJson(),
      if (industryId != null) 'industryId': industryId,
      if (industry != null) 'industry': industry!.toJson(),
      'status': _businessStatusToString(status),
      if (description != null) 'description': description,
      if (nationalId != null) 'nationalId': nationalId,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
      if (economicCode != null) 'economicCode': economicCode,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postalCode': postalCode,
      if (logo != null) 'logo': logo,
      'currency': currency,
      'locale': locale,
      'timezone': timezone,
      if (settings != null) 'settings': settings!.toJson(),
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static BusinessStatus _parseBusinessStatus(String value) {
    switch (value) {
      case 'active': return BusinessStatus.active;
      case 'inactive': return BusinessStatus.inactive;
      case 'suspended': return BusinessStatus.suspended;
      default: return BusinessStatus.active;
    }
  }

  static String _businessStatusToString(BusinessStatus status) {
    switch (status) {
      case BusinessStatus.active: return 'active';
      case BusinessStatus.inactive: return 'inactive';
      case BusinessStatus.suspended: return 'suspended';
    }
  }
}

class CreateBusinessRequest {
  final String name;
  final String? tradeName;
  final String? categoryId;
  final String? industryId;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? nationalId;
  final String? registrationNumber;
  final String? economicCode;

  CreateBusinessRequest({
    required this.name,
    this.tradeName,
    this.categoryId,
    this.industryId,
    this.description,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.nationalId,
    this.registrationNumber,
    this.economicCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (tradeName != null && tradeName!.isNotEmpty) 'tradeName': tradeName,
      if (categoryId != null && categoryId!.isNotEmpty) 'categoryId': categoryId,
      if (industryId != null && industryId!.isNotEmpty) 'industryId': industryId,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (website != null && website!.isNotEmpty) 'website': website,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (state != null && state!.isNotEmpty) 'state': state,
      if (postalCode != null && postalCode!.isNotEmpty) 'postalCode': postalCode,
      if (nationalId != null && nationalId!.isNotEmpty) 'nationalId': nationalId,
      if (registrationNumber != null && registrationNumber!.isNotEmpty) 'registrationNumber': registrationNumber,
      if (economicCode != null && economicCode!.isNotEmpty) 'economicCode': economicCode,
    };
  }
}
