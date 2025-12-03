import 'package:json_annotation/json_annotation.dart';

part 'supplier_dtos.g.dart';

@JsonSerializable()
class CreateSupplierDto {
  final String code; // Required - unique per business
  final String name;
  final String? legalName;
  final String? type; // SupplierType as string
  
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
  final String? country;
  
  // Financial
  final String? currency;
  final int? paymentTermDays;
  final String? paymentTermType;
  final int? defaultLeadTimeDays;
  final String? incoterm;
  final double? creditLimit;
  
  // Additional Info
  final String? description;
  final String? notes;
  final List<String>? tags;
  final String? industry;
  final Map<String, dynamic>? customFields;

  CreateSupplierDto({
    required this.code,
    required this.name,
    this.legalName,
    this.type,
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
    this.country,
    this.currency,
    this.paymentTermDays,
    this.paymentTermType,
    this.defaultLeadTimeDays,
    this.incoterm,
    this.creditLimit,
    this.description,
    this.notes,
    this.tags,
    this.industry,
    this.customFields,
  });

  factory CreateSupplierDto.fromJson(Map<String, dynamic> json) =>
      _$CreateSupplierDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSupplierDtoToJson(this);
}

@JsonSerializable()
class UpdateSupplierDto {
  final String? name;
  final String? code;
  final String? legalName;
  final String? type;
  
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
  final String? country;
  
  // Financial
  final String? currency;
  final int? paymentTermDays;
  final String? paymentTermType;
  final int? defaultLeadTimeDays;
  final String? incoterm;
  final double? creditLimit;
  
  // Ratings (read-only, but included for completeness)
  final double? qualityRating;
  final double? onTimeDeliveryRate;
  
  // Additional Info
  final String? description;
  final String? notes;
  final List<String>? tags;
  final String? industry;
  final Map<String, dynamic>? customFields;

  UpdateSupplierDto({
    this.name,
    this.code,
    this.legalName,
    this.type,
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
    this.country,
    this.currency,
    this.paymentTermDays,
    this.paymentTermType,
    this.defaultLeadTimeDays,
    this.incoterm,
    this.creditLimit,
    this.qualityRating,
    this.onTimeDeliveryRate,
    this.description,
    this.notes,
    this.tags,
    this.industry,
    this.customFields,
  });

  factory UpdateSupplierDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateSupplierDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSupplierDtoToJson(this);
}

@JsonSerializable()
class FilterSuppliersDto {
  final String? search;
  final String? status; // SupplierStatus as string
  final String? type; // SupplierType as string
  final String? city;
  final String? province;
  final String? country;
  final String? industry;
  final String? tags; // Comma-separated string
  final bool? isLinkedBusiness;
  final double? minQualityRating;
  final double? minOnTimeDeliveryRate;
  final String? sortBy;
  final String? sortOrder;
  final int? page;
  final int? limit;

  FilterSuppliersDto({
    this.search,
    this.status,
    this.type,
    this.city,
    this.province,
    this.country,
    this.industry,
    this.tags,
    this.isLinkedBusiness,
    this.minQualityRating,
    this.minOnTimeDeliveryRate,
    this.sortBy,
    this.sortOrder,
    this.page,
    this.limit,
  });

  factory FilterSuppliersDto.fromJson(Map<String, dynamic> json) =>
      _$FilterSuppliersDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FilterSuppliersDtoToJson(this);

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{};
    if (search != null) map['search'] = search;
    if (status != null) map['status'] = status;
    if (type != null) map['type'] = type;
    if (city != null) map['city'] = city;
    if (province != null) map['province'] = province;
    if (country != null) map['country'] = country;
    if (industry != null) map['industry'] = industry;
    if (tags != null) map['tags'] = tags;
    if (isLinkedBusiness != null) map['isLinkedBusiness'] = isLinkedBusiness;
    if (minQualityRating != null) map['minQualityRating'] = minQualityRating;
    if (minOnTimeDeliveryRate != null) map['minOnTimeDeliveryRate'] = minOnTimeDeliveryRate;
    if (sortBy != null) map['sortBy'] = sortBy;
    if (sortOrder != null) map['sortOrder'] = sortOrder;
    if (page != null) map['page'] = page;
    if (limit != null) map['limit'] = limit;
    return map;
  }
}

@JsonSerializable()
class ChangeSupplierStatusDto {
  final String status; // DRAFT, PENDING, APPROVED, SUSPENDED, BLOCKED, ARCHIVED
  final String? reason;

  ChangeSupplierStatusDto({
    required this.status,
    this.reason,
  });

  factory ChangeSupplierStatusDto.fromJson(Map<String, dynamic> json) =>
      _$ChangeSupplierStatusDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeSupplierStatusDtoToJson(this);
}
