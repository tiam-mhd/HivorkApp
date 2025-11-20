class BusinessCategory {
  final String id;
  final String name;
  final String nameEn;
  final String slug;
  final String? description;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.slug,
    this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'slug': slug,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BusinessIndustry {
  final String id;
  final String name;
  final String nameEn;
  final String slug;
  final String? description;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessIndustry({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.slug,
    this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessIndustry.fromJson(Map<String, dynamic> json) {
    return BusinessIndustry(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'slug': slug,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
