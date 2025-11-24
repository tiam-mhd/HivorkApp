import 'package:dio/dio.dart';
import '../models/product_variant.dart';
import '../models/attribute_enums.dart';

/// سرویس API برای مدیریت Variant های محصولات
class VariantApiService {
  final Dio dio;

  VariantApiService(this.dio);

  // ایجاد Variant جدید
  Future<ProductVariant> createVariant(String productId, Map<String, dynamic> variantData) async {
    try {
      print('🎨 [VARIANT_API] Creating variant with data: $variantData');
      
      final response = await dio.post(
        '/products/$productId/variants',
        data: variantData,
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final variantData = responseData['data'];
          
          if (variantData is List && variantData.isNotEmpty) {
            return ProductVariant.fromJson(variantData[0] as Map<String, dynamic>);
          }
          
          if (variantData is Map) {
            return ProductVariant.fromJson(variantData as Map<String, dynamic>);
          }
          
          throw Exception('Invalid variant data format');
        }
        
        if (responseData is Map) {
          return ProductVariant.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create variant');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      print('❌ [VARIANT_API] Error data: ${e.response?.data}');
      
      if (e.response?.statusCode == 409) {
        throw Exception('ترکیب ویژگی‌های این Variant تکراری است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد Variant');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات Variant: $e');
    }
  }

  // Bulk create variants
  Future<List<ProductVariant>> bulkCreateVariants(
    String productId,
    String businessId,
    List<Map<String, dynamic>> variantsData,
  ) async {
    try {
      print('🎨 [VARIANT_API] ===== BULK CREATE VARIANTS =====');
      print('🎨 [VARIANT_API] Product ID: $productId');
      print('🎨 [VARIANT_API] Creating ${variantsData.length} variants');
      print('🎨 [VARIANT_API] Variants data: $variantsData');
      
      final requestBody = {
        'variants': variantsData,
      };
      
      print('🎨 [VARIANT_API] Request body: $requestBody');
      print('🎨 [VARIANT_API] Business ID: $businessId');
      
      final response = await dio.post(
        '/products/$productId/variants/bulk?businessId=$businessId',
        data: requestBody,
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');
      print('✅ [VARIANT_API] Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        if (responseData is List) {
          return responseData
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to bulk create variants');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      print('❌ [VARIANT_API] Error data: ${e.response?.data}');
      print('❌ [VARIANT_API] Error message: ${e.message}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد گروهی Variant ها');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش ایجاد گروهی Variant ها: $e');
    }
  }

  // دریافت لیست Variants با فیلتر
  Future<Map<String, dynamic>> getVariants({
    required String productId,
    // required String businessId,
    VariantStatus? status,
    bool? hasStock,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      print('🎨 [VARIANT_API] Fetching variants for product: $productId');
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) {
        queryParams['status'] = status.apiValue;
      }
      if (hasStock != null) {
        queryParams['hasStock'] = hasStock;
      }

      // queryParams['businessId'] = businessId;

      final response = await dio.get(
        '/products/$productId/variants',
        queryParameters: queryParams,
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle direct array response (empty or with items)
        if (responseData is List) {
          final variants = responseData
              .map((json) {
                print('📦 [VARIANT_API] Variant attributes from list: ${json['attributes']}');
                return ProductVariant.fromJson(json as Map<String, dynamic>);
              })
              .toList();

          return {
            'data': variants,
            'pagination': {
              'page': page,
              'limit': limit,
              'total': variants.length,
              'totalPages': (variants.length / limit).ceil(),
            },
          };
        }
        
        // Handle object response with data and pagination
        if (responseData is Map) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final variants = dataList
              .map((json) {
                print('📦 [VARIANT_API] Variant attributes from paginated list: ${json['attributes']}');
                return ProductVariant.fromJson(json as Map<String, dynamic>);
              })
              .toList();

          return {
            'data': variants,
            'pagination': responseData['pagination'] ?? {
              'page': page,
              'limit': limit,
              'total': variants.length,
              'totalPages': 1,
            },
          };
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch variants');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      print('❌ [VARIANT_API] Error data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت لیست Variant ها');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش لیست Variant ها: $e');
    }
  }

  // دریافت Variants یک محصول
  Future<List<ProductVariant>> getProductVariants(String productId, String businessId) async {
    try {
      print('🎨 [VARIANT_API] Fetching variants for product: $productId');
      
      final response = await dio.get('/products/$productId/variants?businessId=$businessId');

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        if (responseData is List) {
          return responseData
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch product variants');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('محصول یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت Variant های محصول');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش Variant های محصول: $e');
    }
  }

  // دریافت یک Variant با ID
  Future<ProductVariant> getVariantById(String productId, String variantId, String businessId) async {
    try {
      print('🎨 [VARIANT_API] Fetching variant: $variantId');
      
      final response = await dio.get('/products/$productId/variants/$variantId?businessId=$businessId');

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final variantData = responseData['data'];
          print('📦 [VARIANT_API] Variant data attributes: ${variantData['attributes']}');
          return ProductVariant.fromJson(variantData as Map<String, dynamic>);
        }
        
        if (responseData is Map) {
          print('📦 [VARIANT_API] Direct variant data attributes: ${responseData['attributes']}');
          return ProductVariant.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch variant');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Variant یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت Variant');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات Variant: $e');
    }
  }

  // بروزرسانی Variant
  Future<ProductVariant> updateVariant(
    String productId,
    String variantId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🎨 [VARIANT_API] Updating variant $variantId with: $updates');
      
      final response = await dio.put(
        '/products/$productId/variants/$variantId',
        data: updates,
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final variantData = responseData['data'];
          return ProductVariant.fromJson(variantData as Map<String, dynamic>);
        }
        
        if (responseData is Map) {
          return ProductVariant.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update variant');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Variant یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در بروزرسانی Variant');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش بروزرسانی Variant: $e');
    }
  }

  // بروزرسانی موجودی Variant
  Future<ProductVariant> updateVariantStock(
    String productId,
    String variantId, {
    required double quantity,
    required String type, // 'increase' or 'decrease'
    String? reason,
    String? reference,
  }) async {
    try {
      print('🎨 [VARIANT_API] Updating stock for variant $variantId: $type $quantity');
      
      final response = await dio.patch(
        '/products/$productId/variants/$variantId/stock',
        data: {
          'quantity': quantity,
          'type': type,
          if (reason != null) 'reason': reason,
          if (reference != null) 'reference': reference,
        },
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final variantData = responseData['data'];
          return ProductVariant.fromJson(variantData as Map<String, dynamic>);
        }
        
        if (responseData is Map) {
          return ProductVariant.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update stock');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Variant یافت نشد');
      } else if (e.response?.statusCode == 400) {
        throw Exception('موجودی کافی نیست');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در بروزرسانی موجودی');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش بروزرسانی موجودی: $e');
    }
  }

  // حذف Variant
  Future<void> deleteVariant(String productId, String variantId) async {
    try {
      print('🎨 [VARIANT_API] Deleting variant: $variantId');
      
      final response = await dio.delete('/products/$productId/variants/$variantId');

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'Failed to delete variant');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Variant یافت نشد');
      } else if (e.response?.statusCode == 409) {
        throw Exception('این Variant در فاکتورها استفاده شده و قابل حذف نیست');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف Variant');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Error: $e');
      throw Exception('خطا در حذف Variant: $e');
    }
  }

  // تولید خودکار Variants براساس ویژگی‌های محصول
  Future<Map<String, dynamic>> autoGenerateVariants(String productId, String businessId) async {
    try {
      print('🎨 [VARIANT_API] Auto-generating variants for product: $productId');
      print('🎨 [VARIANT_API] Business ID: $businessId');
      
      final response = await dio.post('/products/$productId/variants/auto-generate?businessId=$businessId');

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');
      print('✅ [VARIANT_API] Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map) {
          final deletedCount = responseData['deleted'] ?? 0;
          final List<dynamic> createdList = responseData['created'] ?? [];
          
          final createdVariants = createdList
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();

          return {
            'deleted': deletedCount,
            'created': createdVariants,
          };
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to auto-generate variants');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      print('❌ [VARIANT_API] Error data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در تولید خودکار تنوع‌ها');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در تولید خودکار تنوع‌ها: $e');
    }
  }

  // دریافت Variants با موجودی کم
  Future<List<ProductVariant>> getLowStockVariants({
    String? businessId,
    int limit = 50,
  }) async {
    try {
      print('🎨 [VARIANT_API] Fetching low stock variants');
      
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      
      if (businessId != null) {
        queryParams['businessId'] = businessId;
      }

      final response = await dio.get(
        '/variants/low-stock',
        queryParameters: queryParams,
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        if (responseData is List) {
          return responseData
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch low stock variants');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت Variant های با موجودی کم');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش Variant های با موجودی کم: $e');
    }
  }

  // دریافت Variants بدون موجودی
  Future<List<ProductVariant>> getOutOfStockVariants({
    String? businessId,
    int limit = 50,
  }) async {
    try {
      print('🎨 [VARIANT_API] Fetching out of stock variants');
      
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      
      if (businessId != null) {
        queryParams['businessId'] = businessId;
      }

      final response = await dio.get(
        '/variants/out-of-stock',
        queryParameters: queryParams,
      );

      print('✅ [VARIANT_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        if (responseData is List) {
          return responseData
              .map((json) => ProductVariant.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch out of stock variants');
      }
    } on DioException catch (e) {
      print('❌ [VARIANT_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت Variant های بدون موجودی');
      }
    } catch (e) {
      print('❌ [VARIANT_API] Parse Error: $e');
      throw Exception('خطا در پردازش Variant های بدون موجودی: $e');
    }
  }
}
