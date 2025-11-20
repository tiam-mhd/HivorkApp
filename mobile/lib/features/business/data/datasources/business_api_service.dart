import 'package:dio/dio.dart';
import '../models/business_model.dart';

class BusinessApiService {
  final Dio dio;

  BusinessApiService(this.dio);

  /// Create a new business
  Future<Business> createBusiness(CreateBusinessRequest request) async {
    try {
      print('\n🚀 [Business API] ============ CREATE BUSINESS ============');
      print('📝 [Business API] Business name: ${request.name}');
      print('📦 [Business API] Request data: ${request.toJson()}');
      
      final response = await dio.post(
        '/business',
        data: request.toJson(),
      );

      print('✅ [Business API] Response received: ${response.statusCode}');
      print('📦 [Business API] Response data: ${response.data}');
      print('🏁 [Business API] ============ END ============\n');

      if (response.data['success'] == true) {
        return Business.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'خطا در ایجاد کسب و کار');
      }
    } on DioException catch (e) {
      print('\n❌ [Business API] ============ ERROR ============');
      print('💥 [Business API] Status: ${e.response?.statusCode}');
      print('📦 [Business API] Error data: ${e.response?.data}');
      print('🔴 [Business API] Error message: ${e.message}');
      print('🏁 [Business API] ============ END ERROR ============\n');
      
      if (e.response?.statusCode == 401) {
        throw Exception('لطفاً ابتدا وارد حساب کاربری خود شوید');
      } else if (e.response?.statusCode == 409) {
        throw Exception('کسب و کار با این نام قبلاً ثبت شده است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Get list of my businesses
  Future<List<Business>> getMyBusinesses() async {
    try {
      final response = await dio.get('/business/my-businesses');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Business.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت لیست کسب و کارها');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Get business details by ID
  Future<Business> getBusinessById(String id) async {
    try {
      final response = await dio.get('/business/$id');

      if (response.data['success'] == true) {
        return Business.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت اطلاعات کسب و کار');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('کسب و کار یافت نشد');
      } else if (e.response?.statusCode == 403) {
        throw Exception('دسترسی به این کسب و کار ندارید');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Get business statistics
  Future<Map<String, dynamic>> getBusinessStats(String id) async {
    try {
      final response = await dio.get('/business/$id/stats');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت آمار کسب و کار');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Update business
  Future<Business> updateBusiness(String id, Map<String, dynamic> updates) async {
    try {
      final response = await dio.patch(
        '/business/$id',
        data: updates,
      );

      if (response.data['success'] == true) {
        return Business.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'خطا در ویرایش کسب و کار');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Delete business
  Future<void> deleteBusiness(String id) async {
    try {
      final response = await dio.delete('/business/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'خطا در حذف کسب و کار');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('فقط مالک کسب و کار می‌تواند آن را حذف کند');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }
}
