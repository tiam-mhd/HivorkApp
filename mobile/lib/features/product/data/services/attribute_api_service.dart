import 'package:dio/dio.dart';
import '../models/product_attribute.dart';
import '../models/attribute_enums.dart';

/// سرویس API برای مدیریت ویژگی‌های محصولات
class AttributeApiService {
  final Dio dio;

  AttributeApiService(this.dio);

  // ایجاد Attribute جدید
  Future<ProductAttribute> createAttribute(Map<String, dynamic> attributeData) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Creating attribute with data: $attributeData');
      
      final response = await dio.post(
        '/products/attributes',
        data: attributeData,
      );

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final attributeData = responseData['data'];
          
          if (attributeData is List && attributeData.isNotEmpty) {
            return ProductAttribute.fromJson(attributeData[0] as Map<String, dynamic>);
          }
          
          if (attributeData is Map) {
            return ProductAttribute.fromJson(attributeData as Map<String, dynamic>);
          }
          
          throw Exception('Invalid attribute data format');
        }
        
        if (responseData is Map) {
          return ProductAttribute.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create attribute');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_API] Error data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد ویژگی');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات ویژگی: $e');
    }
  }

  // دریافت لیست Attributes با فیلتر
  Future<Map<String, dynamic>> getAttributes({
    required String businessId,
    AttributeDataType? dataType,
    AttributeCardinality? cardinality,
    AttributeScope? scope,
    bool? isActive,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Fetching attributes for business: $businessId');
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'businessId': businessId,
        'page': page,
        'limit': limit,
      };
      
      if (dataType != null) {
        queryParams['dataType'] = dataType.apiValue;
      }
      if (cardinality != null) {
        queryParams['cardinality'] = cardinality.apiValue;
      }
      if (scope != null) {
        queryParams['scope'] = scope.apiValue;
      }
      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }

      final response = await dio.get(
        '/products/attributes',
        queryParameters: queryParams,
      );

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final attributes = dataList
              .map((json) => ProductAttribute.fromJson(json as Map<String, dynamic>))
              .toList();

          return {
            'data': attributes,
            'pagination': responseData['pagination'] ?? {
              'page': page,
              'limit': limit,
              'total': attributes.length,
              'totalPages': 1,
            },
          };
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch attributes');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_API] Error data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت لیست ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش لیست ویژگی‌ها: $e');
    }
  }

  // دریافت یک Attribute با ID
  Future<ProductAttribute> getAttributeById(String id) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Fetching attribute: $id');
      
      final response = await dio.get('/products/attributes/$id');

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final attributeData = responseData['data'];
          return ProductAttribute.fromJson(attributeData as Map<String, dynamic>);
        }
        
        if (responseData is Map) {
          return ProductAttribute.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch attribute');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('ویژگی یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت ویژگی');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات ویژگی: $e');
    }
  }

  // بروزرسانی Attribute
  Future<ProductAttribute> updateAttribute(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Updating attribute $id with: $updates');
      
      final response = await dio.patch(
        '/products/attributes/$id',
        data: updates,
      );

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final attributeData = responseData['data'];
          return ProductAttribute.fromJson(attributeData as Map<String, dynamic>);
        }
        
        if (responseData is Map) {
          return ProductAttribute.fromJson(responseData as Map<String, dynamic>);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update attribute');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('ویژگی یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در بروزرسانی ویژگی');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش بروزرسانی ویژگی: $e');
    }
  }

  // حذف Attribute
  Future<void> deleteAttribute(String id) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Deleting attribute: $id');
      
      final response = await dio.delete('/products/attributes/$id');

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'Failed to delete attribute');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('ویژگی یافت نشد');
      } else if (e.response?.statusCode == 409) {
        throw Exception('این ویژگی در محصولات یا Variant ها استفاده شده و قابل حذف نیست');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف ویژگی');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Error: $e');
      throw Exception('خطا در حذف ویژگی: $e');
    }
  }

  // Bulk create attributes
  Future<List<ProductAttribute>> bulkCreateAttributes(
    List<Map<String, dynamic>> attributesData,
  ) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Bulk creating ${attributesData.length} attributes');
      
      final response = await dio.post(
        '/products/attributes/bulk',
        data: {'attributes': attributesData},
      );

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((json) => ProductAttribute.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        if (responseData is List) {
          return responseData
              .map((json) => ProductAttribute.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to bulk create attributes');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_API] Error data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد گروهی ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش ایجاد گروهی ویژگی‌ها: $e');
    }
  }

  // Get attributes by product ID (fixed attributes for product)
  /// Get all attributes for a business
  Future<List<ProductAttribute>> getBusinessAttributes(String businessId) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Fetching attributes for business: $businessId');
      
      final response = await dio.get(
        '/products/attributes',
        queryParameters: {'businessId': businessId},
      );

      print('✅ [ATTRIBUTE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((json) => ProductAttribute.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        if (responseData is List) {
          return responseData
              .map((json) => ProductAttribute.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch attributes');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش ویژگی‌ها: $e');
    }
  }

  Future<List<ProductAttribute>> getProductAttributes(String productId) async {
    try {
      print('🏷️ [ATTRIBUTE_API] Fetching attributes for product: $productId');
      
      // Note: Backend doesn't have /products/:productId/attributes endpoint
      // We need to use /products/attributes with businessId filter
      // First, get the product to find its businessId
      
      final productResponse = await dio.get('/products/$productId');
      if (productResponse.statusCode != 200) {
        throw Exception('محصول یافت نشد');
      }
      
      final productData = productResponse.data;
      final businessId = productData is Map && productData.containsKey('businessId') 
          ? productData['businessId'] 
          : (productData is Map && productData.containsKey('data') && productData['data'] is Map)
              ? productData['data']['businessId']
              : null;
              
      if (businessId == null) {
        throw Exception('شناسه کسب‌وکار یافت نشد');
      }
      
      // Now get attributes for this business
      return await getBusinessAttributes(businessId);
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_API] DioException: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('محصول یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت ویژگی‌های محصول');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_API] Parse Error: $e');
      throw Exception('خطا در پردازش ویژگی‌های محصول: $e');
    }
  }
}
