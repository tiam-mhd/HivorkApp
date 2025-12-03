// Expense Category Model
class ExpenseCategory {
  final String id;
  final String businessId;
  final String? parentId;
  final String name;
  final String? description;
  final String color;
  final String? icon;
  final bool isActive;
  final bool isSystem;
  final int sortOrder;
  final double? budgetAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final ExpenseCategory? parent;
  final List<ExpenseCategory>? children;
  final int? expenseCount;

  ExpenseCategory({
    required this.id,
    required this.businessId,
    this.parentId,
    required this.name,
    this.description,
    required this.color,
    this.icon,
    required this.isActive,
    required this.isSystem,
    required this.sortOrder,
    this.budgetAmount,
    required this.createdAt,
    required this.updatedAt,
    this.parent,
    this.children,
    this.expenseCount,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      parentId: json['parentId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#808080',
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isSystem: json['isSystem'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      budgetAmount: json['budgetAmount'] != null 
          ? double.parse(json['budgetAmount'].toString()) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      parent: json['parent'] != null 
          ? ExpenseCategory.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((e) => ExpenseCategory.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      expenseCount: json['expenseCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'parentId': parentId,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'isSystem': isSystem,
      'sortOrder': sortOrder,
      'budgetAmount': budgetAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? businessId,
    String? parentId,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    bool? isSystem,
    int? sortOrder,
    double? budgetAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    ExpenseCategory? parent,
    List<ExpenseCategory>? children,
    int? expenseCount,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parent: parent ?? this.parent,
      children: children ?? this.children,
      expenseCount: expenseCount ?? this.expenseCount,
    );
  }
}
