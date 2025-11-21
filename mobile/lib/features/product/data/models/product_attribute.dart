import 'package:json_annotation/json_annotation.dart';
import 'attribute_enums.dart';

part 'product_attribute.g.dart';

// Converter for AttributeDataType enum
class AttributeDataTypeConverter implements JsonConverter<AttributeDataType, String> {
  const AttributeDataTypeConverter();

  @override
  AttributeDataType fromJson(String json) => AttributeDataType.fromString(json);

  @override
  String toJson(AttributeDataType object) => object.apiValue;
}

// Converter for AttributeCardinality enum
class AttributeCardinalityConverter implements JsonConverter<AttributeCardinality, String> {
  const AttributeCardinalityConverter();

  @override
  AttributeCardinality fromJson(String json) => AttributeCardinality.fromString(json);

  @override
  String toJson(AttributeCardinality object) => object.apiValue;
}

// Converter for AttributeScope enum
class AttributeScopeConverter implements JsonConverter<AttributeScope, String> {
  const AttributeScopeConverter();

  @override
  AttributeScope fromJson(String json) => AttributeScope.fromString(json);

  @override
  String toJson(AttributeScope object) => object.apiValue;
}

@JsonSerializable(fieldRename: FieldRename.none)
class AttributeOption {
  final String value;
  final String label;
  final String? color;
  final int sortOrder;

  AttributeOption({
    required this.value,
    required this.label,
    this.color,
    this.sortOrder = 0,
  });

  factory AttributeOption.fromJson(Map<String, dynamic> json) =>
      _$AttributeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeOptionToJson(this);

  AttributeOption copyWith({
    String? value,
    String? label,
    String? color,
    int? sortOrder,
  }) {
    return AttributeOption(
      value: value ?? this.value,
      label: label ?? this.label,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.none)
class ProductAttribute {
  final String id;
  final String businessId;
  final String name;
  final String? nameEn;
  final String code;
  
  @AttributeDataTypeConverter()
  final AttributeDataType dataType;
  
  @AttributeCardinalityConverter()
  final AttributeCardinality cardinality;
  
  @AttributeScopeConverter()
  final AttributeScope scope;
  
  final List<AttributeOption>? options;
  final bool allowCustomValue;
  final bool required;
  final double? minValue;
  final double? maxValue;
  final String? pattern;
  final String? description;
  final String? helpText;
  final int sortOrder;
  final String? displayFormat;
  final String? icon;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductAttribute({
    required this.id,
    required this.businessId,
    required this.name,
    this.nameEn,
    required this.code,
    required this.dataType,
    required this.cardinality,
    required this.scope,
    this.options,
    this.allowCustomValue = false,
    this.required = false,
    this.minValue,
    this.maxValue,
    this.pattern,
    this.description,
    this.helpText,
    this.sortOrder = 0,
    this.displayFormat,
    this.icon,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) =>
      _$ProductAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$ProductAttributeToJson(this);

  ProductAttribute copyWith({
    String? id,
    String? businessId,
    String? name,
    String? nameEn,
    String? code,
    AttributeDataType? dataType,
    AttributeCardinality? cardinality,
    AttributeScope? scope,
    List<AttributeOption>? options,
    bool? allowCustomValue,
    bool? required,
    double? minValue,
    double? maxValue,
    String? pattern,
    String? description,
    String? helpText,
    int? sortOrder,
    String? displayFormat,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductAttribute(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      code: code ?? this.code,
      dataType: dataType ?? this.dataType,
      cardinality: cardinality ?? this.cardinality,
      scope: scope ?? this.scope,
      options: options ?? this.options,
      allowCustomValue: allowCustomValue ?? this.allowCustomValue,
      required: required ?? this.required,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      pattern: pattern ?? this.pattern,
      description: description ?? this.description,
      helpText: helpText ?? this.helpText,
      sortOrder: sortOrder ?? this.sortOrder,
      displayFormat: displayFormat ?? this.displayFormat,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DTO for creating/updating attributes
@JsonSerializable(fieldRename: FieldRename.none)
class AttributeFormData {
  final String name;
  final String? nameEn;
  final String code;
  
  @AttributeDataTypeConverter()
  final AttributeDataType dataType;
  
  @AttributeCardinalityConverter()
  final AttributeCardinality cardinality;
  
  @AttributeScopeConverter()
  final AttributeScope scope;
  
  final List<AttributeOption>? options;
  final bool allowCustomValue;
  final bool required;
  final double? minValue;
  final double? maxValue;
  final String? pattern;
  final String? description;
  final String? helpText;
  final int sortOrder;
  final String? displayFormat;
  final String? icon;
  final bool isActive;

  AttributeFormData({
    required this.name,
    this.nameEn,
    required this.code,
    required this.dataType,
    required this.cardinality,
    required this.scope,
    this.options,
    this.allowCustomValue = false,
    this.required = false,
    this.minValue,
    this.maxValue,
    this.pattern,
    this.description,
    this.helpText,
    this.sortOrder = 0,
    this.displayFormat,
    this.icon,
    this.isActive = true,
  });

  factory AttributeFormData.fromJson(Map<String, dynamic> json) =>
      _$AttributeFormDataFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeFormDataToJson(this);

  factory AttributeFormData.fromAttribute(ProductAttribute attribute) {
    return AttributeFormData(
      name: attribute.name,
      nameEn: attribute.nameEn,
      code: attribute.code,
      dataType: attribute.dataType,
      cardinality: attribute.cardinality,
      scope: attribute.scope,
      options: attribute.options,
      allowCustomValue: attribute.allowCustomValue,
      required: attribute.required,
      minValue: attribute.minValue,
      maxValue: attribute.maxValue,
      pattern: attribute.pattern,
      description: attribute.description,
      helpText: attribute.helpText,
      sortOrder: attribute.sortOrder,
      displayFormat: attribute.displayFormat,
      icon: attribute.icon,
      isActive: attribute.isActive,
    );
  }
}
