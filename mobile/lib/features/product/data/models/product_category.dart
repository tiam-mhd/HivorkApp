import 'package:json_annotation/json_annotation.dart';

part 'product_category.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductCategory {
  final String id;
  final String name;
  @JsonKey(name: 'nameEn')
  final String? nameEn;
  final String? description;
  final String? icon;
  final String? color;
  @JsonKey(name: 'sortOrder', defaultValue: 0)
  final int sortOrder;
  @JsonKey(name: 'isActive', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'businessId')
  final String businessId;
  
  // Tree structure
  final ProductCategory? parent;
  final List<ProductCategory>? children;
  
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  ProductCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.isActive,
    required this.businessId,
    this.parent,
    this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);

  ProductCategory copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isActive,
    String? businessId,
    ProductCategory? parent,
    List<ProductCategory>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      businessId: businessId ?? this.businessId,
      parent: parent ?? this.parent,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get hasParent => parent != null;
  bool get isRoot => !hasParent;
  
  String get displayName => name;
  String get fullPath {
    if (parent == null) return name;
    return '${parent!.fullPath} > $name';
  }
}
