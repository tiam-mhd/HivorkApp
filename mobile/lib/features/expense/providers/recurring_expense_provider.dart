import 'package:flutter/foundation.dart';
import '../models/recurring_expense.dart';
import '../services/recurring_expense_api_service.dart';

/// Provider برای مدیریت state هزینه‌های تکراری
class RecurringExpenseProvider with ChangeNotifier {
  final RecurringExpenseApiService _apiService;

  RecurringExpenseProvider(this._apiService);

  // State
  List<RecurringExpense> _recurringExpenses = [];
  bool _isLoading = false;
  String? _error;
  RecurringExpense? _selectedRecurringExpense;
  List<dynamic> _generatedExpenses = [];
  List<DateTime> _upcomingOccurrences = [];

  // Getters
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RecurringExpense? get selectedRecurringExpense => _selectedRecurringExpense;
  List<dynamic> get generatedExpenses => _generatedExpenses;
  List<DateTime> get upcomingOccurrences => _upcomingOccurrences;

  /// هزینه‌های فعال
  List<RecurringExpense> get activeRecurringExpenses =>
      _recurringExpenses.where((e) => e.isActive).toList();

  /// هزینه‌های غیرفعال
  List<RecurringExpense> get inactiveRecurringExpenses =>
      _recurringExpenses.where((e) => !e.isActive).toList();

  /// هزینه‌های منقضی شده
  List<RecurringExpense> get expiredRecurringExpenses =>
      _recurringExpenses.where((e) => e.isExpired).toList();

  /// هزینه‌های قابل اجرا
  List<RecurringExpense> get executableRecurringExpenses =>
      _recurringExpenses.where((e) => e.isExecutable).toList();

  /// تعداد کل هزینه‌های تکراری
  int get totalCount => _recurringExpenses.length;

  /// تعداد هزینه‌های فعال
  int get activeCount => activeRecurringExpenses.length;

  /// مجموع مبلغ هزینه‌های فعال ماهانه
  double get totalMonthlyAmount {
    double total = 0;
    for (var expense in activeRecurringExpenses) {
      switch (expense.frequency) {
        case RecurringFrequency.daily:
          total += expense.amount * 30;
          break;
        case RecurringFrequency.weekly:
          total += expense.amount * 4;
          break;
        case RecurringFrequency.monthly:
          total += expense.amount;
          break;
        case RecurringFrequency.quarterly:
          total += expense.amount / 3;
          break;
        case RecurringFrequency.yearly:
          total += expense.amount / 12;
          break;
      }
    }
    return total;
  }

  /// دریافت لیست هزینه‌های تکراری
  Future<void> fetchRecurringExpenses(String businessId) async {
    _setLoading(true);
    _error = null;

    try {
      _recurringExpenses = await _apiService.getRecurringExpenses(
        businessId: businessId,
      );
      notifyListeners();
    } catch (e) {
      // Check if it's an authentication error
      if (e.toString().contains('Authentication failed') || 
          e.toString().contains('401')) {
        _error = 'احراز هویت انجام نشده است. لطفاً دوباره وارد شوید.';
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// دریافت یک هزینه تکراری با جزئیات
  Future<void> fetchRecurringExpenseDetails({
    required String id,
    required String businessId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _apiService.getRecurringExpense(
        id: id,
        businessId: businessId,
      );
      _selectedRecurringExpense = result['recurringExpense'];
      _generatedExpenses = result['generatedExpenses'];
      notifyListeners();
    } catch (e) {
      // Check if it's an authentication error
      if (e.toString().contains('Authentication failed') || 
          e.toString().contains('401')) {
        _error = 'احراز هویت انجام نشده است. لطفاً دوباره وارد شوید.';
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// ساخت هزینه تکراری جدید
  Future<void> createRecurringExpense(
    CreateRecurringExpenseDto dto,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final newExpense = await _apiService.createRecurringExpense(dto);
      _recurringExpenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// بروزرسانی هزینه تکراری
  Future<void> updateRecurringExpense({
    required String id,
    required UpdateRecurringExpenseDto dto,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedExpense = await _apiService.updateRecurringExpense(
        id: id,
        dto: dto,
      );

      final index = _recurringExpenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _recurringExpenses[index] = updatedExpense;
      }

      if (_selectedRecurringExpense?.id == id) {
        _selectedRecurringExpense = updatedExpense;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف هزینه تکراری
  Future<void> deleteRecurringExpense({
    required String id,
    required String businessId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _apiService.deleteRecurringExpense(
        id: id,
        businessId: businessId,
      );

      _recurringExpenses.removeWhere((e) => e.id == id);

      if (_selectedRecurringExpense?.id == id) {
        _selectedRecurringExpense = null;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// تغییر وضعیت فعال/غیرفعال
  Future<void> toggleActive({
    required String id,
    required String businessId,
  }) async {
    try {
      final newStatus = await _apiService.toggleActive(
        id: id,
        businessId: businessId,
      );

      final index = _recurringExpenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _recurringExpenses[index] = _recurringExpenses[index].copyWith(
          isActive: newStatus,
        );
      }

      if (_selectedRecurringExpense?.id == id) {
        _selectedRecurringExpense = _selectedRecurringExpense!.copyWith(
          isActive: newStatus,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// رد شدن از یک نوبت
  Future<void> skipNextOccurrence({
    required String id,
    required String businessId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _apiService.skipNextOccurrence(
        id: id,
        businessId: businessId,
      );

      // Refresh to get updated nextOccurrence
      await fetchRecurringExpenseDetails(id: id, businessId: businessId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// دریافت تاریخ‌های آینده
  Future<void> fetchUpcomingOccurrences({
    required String id,
    required String businessId,
    int count = 5,
  }) async {
    try {
      _upcomingOccurrences = await _apiService.getUpcomingOccurrences(
        id: id,
        businessId: businessId,
        count: count,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// تست دستی cron job
  Future<Map<String, int>> triggerCronManually() async {
    return await _apiService.triggerCronManually();
  }

  /// پاک کردن انتخاب
  void clearSelection() {
    _selectedRecurringExpense = null;
    _generatedExpenses = [];
    _upcomingOccurrences = [];
    notifyListeners();
  }

  /// پاک کردن خطا
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
