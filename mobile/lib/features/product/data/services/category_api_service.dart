import 'package:dio/dio.dart';
import '../models/product_category.dart';

class CategoryApiService {
  final Dio dio;

  CategoryApiService(this.dio);

  // Create Category
  Future<ProductCategory> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await dio.post(
        '/product-categories',
        data: categoryData,
      );

      return ProductCategory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('دسته‌بندی والد یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد دسته‌بندی');
      }
    }
  }

  // Get Categories (Tree)
  Future<List<ProductCategory>> getCategories(String businessId) async {
    try {
      final response = await dio.get(
        '/product-categories',
        queryParameters: {'businessId': businessId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ProductCategory.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در بارگذاری دسته‌بندی‌ها');
      }
    }
  }

  // Get Categories (Flat List)
  Future<List<ProductCategory>> getCategoriesFlat(String businessId) async {
    try {
      final response = await dio.get(
        '/product-categories/flat',
        queryParameters: {'businessId': businessId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ProductCategory.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در بارگذاری دسته‌بندی‌ها');
      }
    }
  }

  // Get Category by ID
  Future<ProductCategory> getCategoryById(String id, String businessId) async {
    try {
      final response = await dio.get(
        '/product-categories/$id',
        queryParameters: {'businessId': businessId},
      );

      return ProductCategory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('دسته‌بندی یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در بارگذاری دسته‌بندی');
      }
    }
  }

  // Update Category
  Future<ProductCategory> updateCategory(String id, String businessId, Map<String, dynamic> categoryData) async {
    try {
      final response = await dio.put(
        '/product-categories/$id',
        queryParameters: {'businessId': businessId},
        data: categoryData,
      );

      return ProductCategory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('دسته‌بندی یافت نشد');
      } else if (e.response?.statusCode == 400) {
        throw Exception('خطا: ${e.response!.data['message']}');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ویرایش دسته‌بندی');
      }
    }
  }

  // Delete Category
  Future<void> deleteCategory(String id, String businessId) async {
    try {
      await dio.delete(
        '/product-categories/$id',
        queryParameters: {'businessId': businessId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('دسته‌بندی یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف دسته‌بندی');
      }
    }
  }

  // Move Category
  Future<ProductCategory> moveCategory(String id, String businessId, String? parentId) async {
    try {
      final response = await dio.put(
        '/product-categories/$id/move',
        queryParameters: {'businessId': businessId},
        data: {'parentId': parentId},
      );

      return ProductCategory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('خطا: ${e.response!.data['message']}');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در جابجایی دسته‌بندی');
      }
    }
  }
}
