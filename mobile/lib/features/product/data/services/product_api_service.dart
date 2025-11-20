import 'package:dio/dio.dart';
import '../models/product.dart';
import '../models/product_filter.dart';
import '../models/product_stats.dart';

class ProductApiService {
  final Dio dio;

  ProductApiService(this.dio);

  // Create Product
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      print('📦 [PRODUCT_API] Creating product with data: $productData');
      
      final response = await dio.post(
        '/products',
        data: productData,
      );

      print('✅ [PRODUCT_API] Response status: ${response.statusCode}');
      print('📦 [PRODUCT_API] Response data type: ${response.data.runtimeType}');
      print('📦 [PRODUCT_API] Response data: ${response.data}');

      // Backend یه wrapper با data array برمیگردونه
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        // Check if response has 'data' key
        if (responseData is Map && responseData.containsKey('data')) {
          final productData = responseData['data'];
          print('📦 [PRODUCT_API] productData type: ${productData.runtimeType}');
          
          // اگر آرایه برگشت، اولین آیتم رو بگیر
          if (productData is List && productData.isNotEmpty) {
            print('📦 [PRODUCT_API] Parsing from array[0]');
            return Product.fromJson(productData[0] as Map<String, dynamic>);
          }
          
          // اگر مستقیم object برگشت
          if (productData is Map) {
            print('📦 [PRODUCT_API] Parsing from direct object');
            return Product.fromJson(productData as Map<String, dynamic>);
          }
          
          throw Exception('Invalid product data format: ${productData.runtimeType}');
        }
        
        // اگر خود response مستقیماً Product object باشه
        if (responseData is Map) {
          print('📦 [PRODUCT_API] Parsing from response directly');
          return Product.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format: ${responseData.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create product');
      }
    } on DioException catch (e) {
      print('❌ [PRODUCT_API] DioException: ${e.response?.statusCode}');
      print('❌ [PRODUCT_API] Error data: ${e.response?.data}');
      
      if (e.response?.statusCode == 409) {
        throw Exception('کد محصول تکراری است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد محصول');
      }
    } catch (e) {
      print('❌ [PRODUCT_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات محصول: $e');
    }
  }

  // Get Products with Filter
  Future<Map<String, dynamic>> getProducts({
    required String businessId,
    ProductFilter? filter,
  }) async {
    try {
      final queryParams = filter?.toQueryParameters() ?? {};
      queryParams['businessId'] = businessId;

      final response = await dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'data': (data['items'] as List? ?? data['data'] as List?)
              ?.map((json) => Product.fromJson(json))
              .toList() ?? [],
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'limit': data['limit'] ?? 10,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت محصولات');
      }
    }
  }

  // Get Product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await dio.get('/products/$id');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Product not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('محصول یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت محصول');
      }
    }
  }

  // Update Product
  Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      final response = await dio.patch(
        '/products/$id',
        data: updates,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('کد محصول تکراری است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در به‌روزرسانی محصول');
      }
    }
  }

  // Delete Product
  Future<void> deleteProduct(String id) async {
    try {
      final response = await dio.delete('/products/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('محصول در حال استفاده است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف محصول');
      }
    }
  }

  // Update Stock
  Future<Product> updateStock(String id, double quantity) async {
    try {
      final response = await dio.patch(
        '/products/$id/stock',
        data: {'quantity': quantity},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update stock');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در به‌روزرسانی موجودی');
      }
    }
  }

  // Adjust Stock
  Future<Product> adjustStock(String id, double adjustment) async {
    try {
      final response = await dio.patch(
        '/products/$id/stock/adjust',
        data: {'adjustment': adjustment},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to adjust stock');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('موجودی کافی نیست');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در تنظیم موجودی');
      }
    }
  }

  // Update Status
  Future<Product> updateStatus(String id, ProductStatus status) async {
    try {
      String statusValue;
      switch (status) {
        case ProductStatus.active:
          statusValue = 'active';
          break;
        case ProductStatus.inactive:
          statusValue = 'inactive';
          break;
        case ProductStatus.outOfStock:
          statusValue = 'out_of_stock';
          break;
      }

      final response = await dio.patch(
        '/products/$id/status',
        data: {'status': statusValue},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در تغییر وضعیت');
      }
    }
  }

  // Get Product Stats
  Future<ProductStats> getProductStats(String businessId) async {
    try {
      print('🔍 Fetching product stats for business: $businessId');
      print('🔍 Request URL: /products/stats?businessId=$businessId');
      
      final response = await dio.get(
        '/products/stats',
        queryParameters: {'businessId': businessId},
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response data type: ${response.data.runtimeType}');
      print('🔍 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        print('🔍 Extracted data: $data');
        
        final stats = ProductStats.fromJson(data);
        print('🔍 Parsed stats: total=${stats.total}, active=${stats.active}');
        
        return stats;
      } else {
        print('❌ Non-200 response: ${response.statusCode}');
        throw Exception(response.data['message'] ?? 'Failed to fetch stats');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت آمار');
      }
    }
  }

  // Get Categories
  Future<List<String>> getCategories(String businessId) async {
    try {
      final response = await dio.get(
        '/products/categories',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch categories');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت دسته‌بندی‌ها');
      }
    }
  }

  // Get Brands
  Future<List<String>> getBrands(String businessId) async {
    try {
      final response = await dio.get(
        '/products/brands',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch brands');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت برندها');
      }
    }
  }

  // Upload Image
  Future<Product> uploadImage(String id, String imageUrl) async {
    try {
      final response = await dio.post(
        '/products/$id/images',
        data: {'imageUrl': imageUrl},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload image');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در آپلود تصویر');
      }
    }
  }

  // Remove Image
  Future<Product> removeImage(String id, String imageUrl) async {
    try {
      final response = await dio.delete(
        '/products/$id/images',
        data: {'imageUrl': imageUrl},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove image');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف تصویر');
      }
    }
  }
}

