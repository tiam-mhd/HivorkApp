import 'package:json_annotation/json_annotation.dart';

part 'recurring_expense.g.dart';

/// Custom converter برای amount که می‌تواند String یا num باشد
class AmountConverter implements JsonConverter<double, dynamic> {
  const AmountConverter();

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

/// تناوب تکرار هزینه
enum RecurringFrequency {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly;

  String get persianLabel {
    switch (this) {
      case RecurringFrequency.daily:
        return 'روزانه';
      case RecurringFrequency.weekly:
        return 'هفتگی';
      case RecurringFrequency.monthly:
        return 'ماهانه';
      case RecurringFrequency.quarterly:
        return 'سه‌ماهه';
      case RecurringFrequency.yearly:
        return 'سالانه';
    }
  }

  String get icon {
    switch (this) {
      case RecurringFrequency.daily:
        return '📅';
      case RecurringFrequency.weekly:
        return '📆';
      case RecurringFrequency.monthly:
        return '🗓️';
      case RecurringFrequency.quarterly:
        return '📊';
      case RecurringFrequency.yearly:
        return '🎯';
    }
  }
}

/// مدل هزینه تکراری
@JsonSerializable()
class RecurringExpense {
  final String id;
  final String businessId;
  final String? categoryId;
  final String title;
  final String? description;
  
  @AmountConverter()
  final double amount;
  
  final RecurringFrequency frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrence;
  final String paymentMethod;
  final bool isActive;
  final bool autoCreate;
  final DateTime? lastCreatedAt;
  final String? tags;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  // روابط (optional)
  final Map<String, dynamic>? category;

  const RecurringExpense({
    required this.id,
    required this.businessId,
    this.categoryId,
    required this.title,
    this.description,
    required this.amount,
    required this.frequency,
    required this.interval,
    required this.startDate,
    this.endDate,
    required this.nextOccurrence,
    required this.paymentMethod,
    required this.isActive,
    required this.autoCreate,
    this.lastCreatedAt,
    this.tags,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      _$RecurringExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringExpenseToJson(this);

  /// نسخه کپی با تغییرات
  RecurringExpense copyWith({
    String? id,
    String? businessId,
    String? categoryId,
    String? title,
    String? description,
    double? amount,
    RecurringFrequency? frequency,
    int? interval,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextOccurrence,
    String? paymentMethod,
    bool? isActive,
    bool? autoCreate,
    DateTime? lastCreatedAt,
    String? tags,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? category,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isActive: isActive ?? this.isActive,
      autoCreate: autoCreate ?? this.autoCreate,
      lastCreatedAt: lastCreatedAt ?? this.lastCreatedAt,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  /// توضیحات تناوب (مثلا: "هر ماه" یا "هر 2 هفته")
  String get frequencyDescription {
    if (interval == 1) {
      switch (frequency) {
        case RecurringFrequency.daily:
          return 'هر روز';
        case RecurringFrequency.weekly:
          return 'هر هفته';
        case RecurringFrequency.monthly:
          return 'هر ماه';
        case RecurringFrequency.quarterly:
          return 'هر سه ماه';
        case RecurringFrequency.yearly:
          return 'هر سال';
      }
    } else {
      String unit;
      switch (frequency) {
        case RecurringFrequency.daily:
          unit = 'روز';
          break;
        case RecurringFrequency.weekly:
          unit = 'هفته';
          break;
        case RecurringFrequency.monthly:
          unit = 'ماه';
          break;
        case RecurringFrequency.quarterly:
          unit = 'سه‌ماهه';
          break;
        case RecurringFrequency.yearly:
          unit = 'سال';
          break;
      }
      return 'هر $interval $unit';
    }
  }

  /// آیا تاریخ پایان دارد؟
  bool get hasEndDate => endDate != null;

  /// آیا منقضی شده؟
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// آیا فعال و قابل اجرا است؟
  bool get isExecutable => isActive && autoCreate && !isExpired;

  /// لیست برچسب‌ها
  List<String> get tagsList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((e) => e.trim()).toList();
  }
}

/// DTO برای ساخت هزینه تکراری
@JsonSerializable()
class CreateRecurringExpenseDto {
  final String businessId;
  final String? categoryId;
  final String title;
  final String? description;
  final double amount;
  final RecurringFrequency frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final String paymentMethod;
  final bool autoCreate;
  final String? tags;
  final String? note;

  const CreateRecurringExpenseDto({
    required this.businessId,
    this.categoryId,
    required this.title,
    this.description,
    required this.amount,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    required this.paymentMethod,
    this.autoCreate = true,
    this.tags,
    this.note,
  });

  factory CreateRecurringExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRecurringExpenseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRecurringExpenseDtoToJson(this);
}

/// DTO برای بروزرسانی هزینه تکراری
@JsonSerializable()
class UpdateRecurringExpenseDto {
  final String? categoryId;
  final String? title;
  final String? description;
  final double? amount;
  final RecurringFrequency? frequency;
  final int? interval;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final bool? autoCreate;
  final bool? isActive;
  final String? tags;
  final String? note;

  const UpdateRecurringExpenseDto({
    this.categoryId,
    this.title,
    this.description,
    this.amount,
    this.frequency,
    this.interval,
    this.startDate,
    this.endDate,
    this.paymentMethod,
    this.autoCreate,
    this.isActive,
    this.tags,
    this.note,
  });

  factory UpdateRecurringExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateRecurringExpenseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateRecurringExpenseDtoToJson(this);
}
