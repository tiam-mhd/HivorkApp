import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/expense_api_service.dart';
import '../services/expense_category_api_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseApiService _expenseApiService;
  final ExpenseCategoryApiService _categoryApiService;

  ExpenseProvider(this._expenseApiService, this._categoryApiService);

  // State
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> _categoryHierarchy = [];
  ExpenseStats? _stats;
  List<Map<String, dynamic>> _budgetStatus = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _searchQuery;
  String? _selectedCategoryId;
  String? _selectedPaymentMethod;
  String? _selectedPaymentStatus;
  DateTime? _fromDate;
  DateTime? _toDate;
  double? _minAmount;
  double? _maxAmount;

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  List<ExpenseCategory> get categoryHierarchy => _categoryHierarchy;
  ExpenseStats? get stats => _stats;
  List<Map<String, dynamic>> get budgetStatus => _budgetStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  String? get selectedPaymentStatus => _selectedPaymentStatus;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;

  bool get hasActiveFilters =>
      _searchQuery != null ||
      _selectedCategoryId != null ||
      _selectedPaymentMethod != null ||
      _selectedPaymentStatus != null ||
      _fromDate != null ||
      _toDate != null ||
      _minAmount != null ||
      _maxAmount != null;

  // Load expenses
  Future<void> loadExpenses(String businessId) async {
    if (businessId.isEmpty) {
      _error = 'شناسه کسب‌وکار موجود نیست. لطفاً ابتدا کسب‌وکار را انتخاب کنید.';
      _expenses = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _expenseApiService.getExpenses(
        businessId: businessId,
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        paymentMethod: _selectedPaymentMethod,
        paymentStatus: _selectedPaymentStatus,
        fromDate: _fromDate,
        toDate: _toDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
      );
      _error = null;
    } catch (e) {
      // Check if it's an authentication error
      if (e.toString().contains('Authentication failed') || 
          e.toString().contains('401')) {
        _error = 'احراز هویت انجام نشده است. لطفاً دوباره وارد شوید.';
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories(String businessId) async {
    if (businessId.isEmpty) {
      _error = 'شناسه کسب‌وکار موجود نیست';
      notifyListeners();
      return;
    }

    try {
      _categories = await _categoryApiService.getCategories(businessId);
      // Don't override expense loading error with category success
      if (_error?.contains('احراز هویت') != true && 
          _error?.contains('Authentication') != true) {
        _error = null;
      }
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
    }
  }

  // Load category hierarchy
  Future<void> loadCategoryHierarchy(String businessId) async {
    try {
      _categoryHierarchy = await _categoryApiService.getHierarchy(businessId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load stats
  Future<void> loadStats(String businessId) async {
    try {
      _stats = await _expenseApiService.getStats(businessId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Create expense
  Future<Expense?> createExpense({
    required String businessId,
    String? categoryId,
    required String title,
    String? description,
    required double amount,
    required DateTime expenseDate,
    String? paymentMethod,
    String? paymentStatus,
    String? referenceType,
    String? referenceId,
    bool? isPaid,
    List<String>? tags,
    String? note,
  }) async {
    try {
      final expense = await _expenseApiService.createExpense(
        businessId: businessId,
        categoryId: categoryId,
        title: title,
        description: description,
        amount: amount,
        expenseDate: expenseDate,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        referenceType: referenceType,
        referenceId: referenceId,
        isPaid: isPaid,
        tags: tags,
        note: note,
      );

      // Add to list
      _expenses.insert(0, expense);
      notifyListeners();

      return expense;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update expense
  Future<Expense?> updateExpense(
    String id, {
    String? categoryId,
    String? title,
    String? description,
    double? amount,
    DateTime? expenseDate,
    String? paymentMethod,
    String? paymentStatus,
    bool? isPaid,
    List<String>? tags,
    String? note,
  }) async {
    try {
      final updatedExpense = await _expenseApiService.updateExpense(
        id,
        categoryId: categoryId,
        title: title,
        description: description,
        amount: amount,
        expenseDate: expenseDate,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        isPaid: isPaid,
        tags: tags,
        note: note,
      );

      // Update in list
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        notifyListeners();
      }

      return updatedExpense;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      await _expenseApiService.deleteExpense(id);

      // Remove from list
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Approve expense
  Future<Expense?> approveExpense(String id) async {
    try {
      final approvedExpense = await _expenseApiService.approveExpense(id);

      // Update in list
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = approvedExpense;
        notifyListeners();
      }

      return approvedExpense;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Create category
  Future<ExpenseCategory?> createCategory({
    required String businessId,
    String? parentId,
    required String name,
    String? description,
    String? color,
    String? icon,
    double? budgetAmount,
  }) async {
    try {
      final category = await _categoryApiService.createCategory(
        businessId: businessId,
        parentId: parentId,
        name: name,
        description: description,
        color: color,
        icon: icon,
        budgetAmount: budgetAmount,
      );

      // Add to list
      _categories.add(category);
      notifyListeners();

      return category;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update category
  Future<ExpenseCategory?> updateCategory(
    String id, {
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    double? budgetAmount,
  }) async {
    try {
      final updatedCategory = await _categoryApiService.updateCategory(
        id,
        name: name,
        description: description,
        color: color,
        icon: icon,
        isActive: isActive,
        budgetAmount: budgetAmount,
      );

      // Update in list
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }

      return updatedCategory;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      await _categoryApiService.deleteCategory(id);

      // Remove from list
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Create system categories
  Future<bool> createSystemCategories(String businessId) async {
    try {
      await _categoryApiService.createSystemCategories(businessId);
      await loadCategories(businessId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Filter methods
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSelectedPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setSelectedPaymentStatus(String? status) {
    _selectedPaymentStatus = status;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void setAmountRange(double? min, double? max) {
    _minAmount = min;
    _maxAmount = max;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCategoryId = null;
    _selectedPaymentMethod = null;
    _selectedPaymentStatus = null;
    _fromDate = null;
    _toDate = null;
    _minAmount = null;
    _maxAmount = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods
  ExpenseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Expense> getExpensesByCategory(String categoryId) {
    return _expenses.where((e) => e.categoryId == categoryId).toList();
  }

  double getTotalAmount() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  int getExpenseCount() {
    return _expenses.length;
  }

  // Load budget status
  Future<void> loadBudgetStatus(String businessId, {int? year, int? month}) async {
    if (businessId.isEmpty) {
      _error = 'شناسه کسب‌وکار موجود نیست';
      _budgetStatus = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgetStatus = await _expenseApiService.getBudgetStatus(
        businessId: businessId,
        year: year,
        month: month,
      );
      _error = null;
    } catch (e) {
      if (e.toString().contains('Authentication failed') || 
          e.toString().contains('401')) {
        _error = 'احراز هویت انجام نشده است. لطفاً دوباره وارد شوید.';
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }
      _budgetStatus = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
