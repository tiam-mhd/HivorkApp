import 'package:dio/dio.dart';
import '../models/recurring_expense.dart';

/// سرویس API برای مدیریت هزینه‌های تکراری
class RecurringExpenseApiService {
  final Dio dio;

  RecurringExpenseApiService(this.dio);

  /// دریافت لیست همه هزینه‌های تکراری
  Future<List<RecurringExpense>> getRecurringExpenses({
    required String businessId,
  }) async {
    try {
      print('🔄 [Recurring Expense API] Loading recurring expenses for business: $businessId');
      
      final response = await dio.get(
        '/recurring-expenses',
        queryParameters: {'businessId': businessId},
      );

      // Backend returns: { statusCode, message, data: [] }
      final responseData = response.data;
      final List<dynamic> data = (responseData is Map && responseData['data'] != null)
          ? responseData['data'] as List
          : responseData as List;
      print('✅ [Recurring Expense API] Loaded ${data.length} recurring expenses');
      return data.map((json) => RecurringExpense.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🔒 [Recurring Expense API] 401 Unauthorized - Token may be missing or expired');
        throw Exception('Authentication failed. Please login again.');
      }
      print('❌ [Recurring Expense API] Error: ${e.message}');
      throw Exception('خطا در دریافت هزینه‌های تکراری: ${e.message}');
    } catch (e) {
      print('❌ [Recurring Expense API] Unexpected error: $e');
      throw Exception('خطا در دریافت هزینه‌های تکراری: $e');
    }
  }

  /// دریافت یک هزینه تکراری به همراه هزینه‌های ایجاد شده
  Future<Map<String, dynamic>> getRecurringExpense({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/recurring-expenses/$id',
        queryParameters: {'businessId': businessId},
      );

      // Backend returns: { statusCode, message, data: {...} }
      final responseData = response.data;
      final data = (responseData is Map && responseData['data'] != null)
          ? responseData['data']
          : responseData;
      return {
        'recurringExpense': RecurringExpense.fromJson(data),
        'generatedExpenses': (data['generatedExpenses'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      }
      throw Exception('خطا در دریافت هزینه تکراری: ${e.message}');
    } catch (e) {
      throw Exception('خطا در دریافت هزینه تکراری: $e');
    }
  }

  /// ساخت هزینه تکراری جدید
  Future<RecurringExpense> createRecurringExpense(
    CreateRecurringExpenseDto dto,
  ) async {
    try {
      final response = await dio.post(
        '/recurring-expenses',
        data: dto.toJson(),
      );

      return RecurringExpense.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('خطا در ساخت هزینه تکراری: $e');
    }
  }

  /// بروزرسانی هزینه تکراری
  Future<RecurringExpense> updateRecurringExpense({
    required String id,
    required UpdateRecurringExpenseDto dto,
  }) async {
    try {
      final response = await dio.put(
        '/recurring-expenses/$id',
        data: dto.toJson(),
      );

      return RecurringExpense.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('خطا در بروزرسانی هزینه تکراری: $e');
    }
  }

  /// حذف هزینه تکراری
  Future<void> deleteRecurringExpense({
    required String id,
    required String businessId,
  }) async {
    try {
      await dio.delete(
        '/recurring-expenses/$id',
        queryParameters: {'businessId': businessId},
      );
    } catch (e) {
      throw Exception('خطا در حذف هزینه تکراری: $e');
    }
  }

  /// تغییر وضعیت فعال/غیرفعال
  Future<bool> toggleActive({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.post(
        '/recurring-expenses/$id/toggle-active',
        queryParameters: {'businessId': businessId},
      );

      return response.data['data']['isActive'] as bool;
    } catch (e) {
      throw Exception('خطا در تغییر وضعیت: $e');
    }
  }

  /// رد شدن از یک نوبت
  Future<Map<String, String>> skipNextOccurrence({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.post(
        '/recurring-expenses/$id/skip',
        queryParameters: {'businessId': businessId},
      );

      return {
        'previousNextOccurrence':
            response.data['data']['previousNextOccurrence'] as String,
        'newNextOccurrence':
            response.data['data']['newNextOccurrence'] as String,
      };
    } catch (e) {
      throw Exception('خطا در رد کردن نوبت: $e');
    }
  }

  /// دریافت تاریخ‌های آینده
  Future<List<DateTime>> getUpcomingOccurrences({
    required String id,
    required String businessId,
    int count = 5,
  }) async {
    try {
      final response = await dio.get(
        '/recurring-expenses/$id/upcoming',
        queryParameters: {
          'businessId': businessId,
          'count': count,
        },
      );

      final List<dynamic> dates = response.data['data'] as List;
      return dates.map((date) => DateTime.parse(date as String)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت تاریخ‌های آینده: $e');
    }
  }

  /// تست دستی cron job (فقط برای توسعه)
  Future<Map<String, int>> triggerCronManually() async {
    try {
      final response = await dio.post(
        '/recurring-expenses/cron/trigger-manual',
      );

      return {
        'created': response.data['data']['created'] as int,
        'errors': response.data['data']['errors'] as int,
      };
    } catch (e) {
      throw Exception('خطا در اجرای دستی cron: $e');
    }
  }
}
