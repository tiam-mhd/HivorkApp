import 'package:dio/dio.dart';
import '../models/models.dart';

class ExpenseCategoryApiService {
  final Dio dio;

  ExpenseCategoryApiService(this.dio);

  /// Get all expense categories for a business
  Future<List<ExpenseCategory>> getCategories(String businessId) async {
    try {
      print('📂 [Category API] Loading categories for business: $businessId');
      
      final response = await dio.get(
        '/expense-categories',
        queryParameters: {'businessId': businessId},
      );

      final List<dynamic> data = response.data as List;
      print('✅ [Category API] Loaded ${data.length} categories');
      return data.map((json) => ExpenseCategory.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🔒 [Category API] 401 Unauthorized - Token may be missing or expired');
        throw Exception('Authentication failed. Please login again.');
      }
      print('❌ [Category API] Error: ${e.message}');
      throw Exception('Failed to load categories: ${e.message}');
    } catch (e) {
      print('❌ [Category API] Unexpected error: $e');
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Get category hierarchy tree
  Future<List<ExpenseCategory>> getHierarchy(String businessId) async {
    try {
      final response = await dio.get(
        '/expense-categories/hierarchy',
        queryParameters: {'businessId': businessId},
      );

      final List<dynamic> data = response.data as List;
      return data.map((json) => ExpenseCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load hierarchy: $e');
    }
  }

  /// Get a single category by ID
  Future<ExpenseCategory> getCategory(String id) async {
    try {
      final response = await dio.get('/expense-categories/$id');
      return ExpenseCategory.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  /// Create a new category
  Future<ExpenseCategory> createCategory({
    required String businessId,
    String? parentId,
    required String name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    int? sortOrder,
    double? budgetAmount,
  }) async {
    try {
      final response = await dio.post(
        '/expense-categories',
        data: {
          'businessId': businessId,
          if (parentId != null) 'parentId': parentId,
          'name': name,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
          if (icon != null) 'icon': icon,
          if (isActive != null) 'isActive': isActive,
          if (sortOrder != null) 'sortOrder': sortOrder,
          if (budgetAmount != null) 'budgetAmount': budgetAmount,
        },
      );

      return ExpenseCategory.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update a category
  Future<ExpenseCategory> updateCategory(
    String id, {
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    String? parentId,
    int? sortOrder,
    double? budgetAmount,
  }) async {
    try {
      final response = await dio.patch(
        '/expense-categories/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
          if (icon != null) 'icon': icon,
          if (isActive != null) 'isActive': isActive,
          if (parentId != null) 'parentId': parentId,
          if (sortOrder != null) 'sortOrder': sortOrder,
          if (budgetAmount != null) 'budgetAmount': budgetAmount,
        },
      );

      return ExpenseCategory.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      await dio.delete('/expense-categories/$id');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Create system default categories
  Future<void> createSystemCategories(String businessId) async {
    try {
      await dio.post(
        '/expense-categories/system',
        queryParameters: {'businessId': businessId},
      );
    } catch (e) {
      throw Exception('Failed to create system categories: $e');
    }
  }
}
