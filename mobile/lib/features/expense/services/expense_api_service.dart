import 'dart:io';
import 'package:dio/dio.dart';
import '../models/models.dart';

class ExpenseApiService {
  final Dio dio;

  ExpenseApiService(this.dio);

  /// Get all expenses with filters
  Future<List<Expense>> getExpenses({
    required String businessId,
    String? search,
    String? categoryId,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    int? page,
    int? limit,
  }) async {
    try {
      print('📊 [Expense API] Loading expenses for business: $businessId');
      
      final queryParams = <String, dynamic>{
        'businessId': businessId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String().split('T')[0],
        if (toDate != null) 'toDate': toDate.toIso8601String().split('T')[0],
        if (minAmount != null) 'minAmount': minAmount,
        if (maxAmount != null) 'maxAmount': maxAmount,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      };

      final response = await dio.get(
        '/expenses',
        queryParameters: queryParams,
      );

      // Backend returns: { data: [], total, page, limit }
      if (response.data is Map && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'] as List;
        print('✅ [Expense API] Loaded ${data.length} expenses');
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        // Fallback if backend returns array directly
        final List<dynamic> data = response.data as List;
        print('✅ [Expense API] Loaded ${data.length} expenses');
        return data.map((json) => Expense.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🔒 [Expense API] 401 Unauthorized - Token may be missing or expired');
        throw Exception('Authentication failed. Please login again.');
      }
      print('❌ [Expense API] Error: ${e.message}');
      throw Exception('Failed to load expenses: ${e.message}');
    } catch (e) {
      print('❌ [Expense API] Unexpected error: $e');
      throw Exception('Failed to load expenses: $e');
    }
  }

  /// Get expense statistics
  Future<ExpenseStats> getStats(String businessId) async {
    try {
      final response = await dio.get(
        '/expenses/stats',
        queryParameters: {'businessId': businessId},
      );

      return ExpenseStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  /// Get top expenses
  Future<List<Expense>> getTopExpenses(String businessId, {int limit = 10}) async {
    try {
      final response = await dio.get(
        '/expenses/top',
        queryParameters: {
          'businessId': businessId,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data as List;
      return data.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load top expenses: $e');
    }
  }

  /// Get daily total
  Future<double> getDailyTotal(String businessId, DateTime date) async {
    try {
      final response = await dio.get(
        '/expenses/daily-total',
        queryParameters: {
          'businessId': businessId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return double.parse(response.data['total'].toString());
    } catch (e) {
      throw Exception('Failed to load daily total: $e');
    }
  }

  /// Get monthly total
  Future<double> getMonthlyTotal(String businessId, int year, int month) async {
    try {
      final response = await dio.get(
        '/expenses/monthly-total',
        queryParameters: {
          'businessId': businessId,
          'year': year,
          'month': month,
        },
      );

      return double.parse(response.data['total'].toString());
    } catch (e) {
      throw Exception('Failed to load monthly total: $e');
    }
  }

  /// Get yearly total
  Future<double> getYearlyTotal(String businessId, int year) async {
    try {
      final response = await dio.get(
        '/expenses/yearly-total',
        queryParameters: {
          'businessId': businessId,
          'year': year,
        },
      );

      return double.parse(response.data['total'].toString());
    } catch (e) {
      throw Exception('Failed to load yearly total: $e');
    }
  }

  /// Get a single expense by ID
  Future<Expense> getExpense(String id) async {
    try {
      final response = await dio.get('/expenses/$id');
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load expense: $e');
    }
  }

  /// Create a new expense
  Future<Expense> createExpense({
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
    bool? isRecurring,
    Map<String, dynamic>? recurringRule,
  }) async {
    try {
      final response = await dio.post(
        '/expenses',
        data: {
          'businessId': businessId,
          if (categoryId != null) 'categoryId': categoryId,
          'title': title,
          if (description != null) 'description': description,
          'amount': amount,
          'expenseDate': expenseDate.toIso8601String().split('T')[0],
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
          if (paymentStatus != null) 'paymentStatus': paymentStatus,
          if (referenceType != null) 'referenceType': referenceType,
          if (referenceId != null) 'referenceId': referenceId,
          if (isPaid != null) 'isPaid': isPaid,
          if (tags != null) 'tags': tags,
          if (note != null) 'note': note,
          if (isRecurring != null) 'isRecurring': isRecurring,
          if (recurringRule != null) 'recurringRule': recurringRule,
        },
      );

      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  /// Update an expense
  Future<Expense> updateExpense(
    String id, {
    String? categoryId,
    String? title,
    String? description,
    double? amount,
    DateTime? expenseDate,
    String? paymentMethod,
    String? paymentStatus,
    String? referenceType,
    String? referenceId,
    bool? isPaid,
    List<String>? tags,
    String? note,
    bool? isRecurring,
    Map<String, dynamic>? recurringRule,
  }) async {
    try {
      final response = await dio.patch(
        '/expenses/$id',
        data: {
          if (categoryId != null) 'categoryId': categoryId,
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (amount != null) 'amount': amount,
          if (expenseDate != null) 'expenseDate': expenseDate.toIso8601String().split('T')[0],
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
          if (paymentStatus != null) 'paymentStatus': paymentStatus,
          if (referenceType != null) 'referenceType': referenceType,
          if (referenceId != null) 'referenceId': referenceId,
          if (isPaid != null) 'isPaid': isPaid,
          if (tags != null) 'tags': tags,
          if (note != null) 'note': note,
          if (isRecurring != null) 'isRecurring': isRecurring,
          if (recurringRule != null) 'recurringRule': recurringRule,
        },
      );

      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete an expense (soft delete)
  Future<void> deleteExpense(String id) async {
    try {
      await dio.delete('/expenses/$id');
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  /// Upload attachment to an expense
  Future<Expense> uploadAttachment(String id, File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '/expenses/$id/attachments',
        data: formData,
      );

      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  /// Remove attachment from an expense
  Future<void> removeAttachment(String id, String fileUrl) async {
    try {
      await dio.delete(
        '/expenses/$id/attachments',
        queryParameters: {'fileUrl': fileUrl},
      );
    } catch (e) {
      throw Exception('Failed to remove attachment: $e');
    }
  }

  /// Approve an expense
  Future<Expense> approveExpense(String id) async {
    try {
      final response = await dio.post('/expenses/$id/approve');
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve expense: $e');
    }
  }

  /// Get budget status for all categories
  Future<List<Map<String, dynamic>>> getBudgetStatus({
    required String businessId,
    int? year,
    int? month,
  }) async {
    try {
      print('📊 [Expense API] Loading budget status for business: $businessId');
      
      final queryParams = <String, dynamic>{
        'businessId': businessId,
        if (year != null) 'year': year,
        if (month != null) 'month': month,
      };

      final response = await dio.get(
        '/expenses/budget-status',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        print('✅ [Expense API] Loaded ${response.data.length} budget items');
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('❌ [Expense API] Error loading budget status: $e');
      throw Exception('Failed to load budget status: $e');
    }
  }
}
