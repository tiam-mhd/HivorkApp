import 'package:dio/dio.dart';
import '../models/business_metadata_model.dart';

class BusinessMetadataApiService {
  final Dio dio;

  BusinessMetadataApiService(this.dio);

  /// Get list of active business categories
  Future<List<BusinessCategory>> getCategories() async {
    try {
      final response = await dio.get('/business-metadata/categories');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BusinessCategory.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت دسته‌بندی‌ها');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Get list of active business industries
  Future<List<BusinessIndustry>> getIndustries() async {
    try {
      final response = await dio.get('/business-metadata/industries');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BusinessIndustry.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت صنایع');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Get all categories (admin only - includes inactive)
  Future<List<BusinessCategory>> getAllCategories() async {
    try {
      final response = await dio.get('/business-metadata/categories/all');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BusinessCategory.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت دسته‌بندی‌ها');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }

  /// Get all industries (admin only - includes inactive)
  Future<List<BusinessIndustry>> getAllIndustries() async {
    try {
      final response = await dio.get('/business-metadata/industries/all');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BusinessIndustry.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'خطا در دریافت صنایع');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ارتباط با سرور');
      }
    }
  }
}
