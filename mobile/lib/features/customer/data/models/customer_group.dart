import 'package:json_annotation/json_annotation.dart';

part 'customer_group.g.dart';

// Converter for string to double
class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double value) => value;
}

// Converter for string to int
class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(int value) => value;
}

@JsonSerializable(fieldRename: FieldRename.none)
class CustomerGroup {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  
  @StringToDoubleConverter()
  final double discountRate;
  
  @StringToIntConverter()
  final int paymentTermDays;
  
  @StringToDoubleConverter()
  final double creditLimit;
  final int sortOrder;
  final bool isActive;
  final int? customerCount;
  final String businessId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerGroup({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.discountRate = 0,
    this.paymentTermDays = 0,
    this.creditLimit = 0,
    this.sortOrder = 0,
    this.isActive = true,
    this.customerCount,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerGroup.fromJson(Map<String, dynamic> json) =>
      _$CustomerGroupFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerGroupToJson(this);

  CustomerGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    double? discountRate,
    int? paymentTermDays,
    double? creditLimit,
    int? sortOrder,
    bool? isActive,
    int? customerCount,
    String? businessId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      discountRate: discountRate ?? this.discountRate,
      paymentTermDays: paymentTermDays ?? this.paymentTermDays,
      creditLimit: creditLimit ?? this.creditLimit,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      customerCount: customerCount ?? this.customerCount,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
