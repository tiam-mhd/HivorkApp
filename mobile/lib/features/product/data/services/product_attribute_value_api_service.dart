import 'package:dio/dio.dart';

/// API service for managing product attribute values
/// These are the values assigned to attributes for a specific product
class ProductAttributeValueApiService {
  final Dio dio;

  ProductAttributeValueApiService(this.dio);

  /// Set attribute values for a product
  /// This replaces all existing values
  Future<void> setProductAttributeValues(
    String productId,
    Map<String, List<String>> attributeValues,
  ) async {
    try {
      print('🎨 [ATTRIBUTE_VALUE_API] Setting values for product: $productId');
      print('🎨 [ATTRIBUTE_VALUE_API] Input attributeValues: $attributeValues');

      // Transform Map<attributeId, List<value>> to API format
      final values = attributeValues.entries.map((entry) {
        return {
          'attributeId': entry.key,
          'value': entry.value, // Store as JSON array
        };
      }).toList();

      print('🎨 [ATTRIBUTE_VALUE_API] Transformed values: $values');

      final response = await dio.post(
        '/products/$productId/attribute-values',
        data: {'values': values},
      );

      print('✅ [ATTRIBUTE_VALUE_API] Response status: ${response.statusCode}');
      print('✅ [ATTRIBUTE_VALUE_API] Response data: ${response.data}');
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_VALUE_API] Error data: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ذخیره مقادیر ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] Parse Error: $e');
      throw Exception('خطا در پردازش مقادیر ویژگی‌ها: $e');
    }
  }

  /// Get attribute values for a product
  /// Returns Map<attributeId, attributeData> where attributeData includes code and values
  Future<Map<String, dynamic>> getProductAttributeValuesWithMetadata(
    String productId,
  ) async {
    try {
      print('🎨 [ATTRIBUTE_VALUE_API] Fetching values with metadata for product: $productId');

      final response = await dio.get(
        '/products/$productId/attribute-values',
      );

      print('✅ [ATTRIBUTE_VALUE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        // Transform to Map<attributeId, {code, values, attribute}>
        final Map<String, dynamic> result = {};
        for (final item in data) {
          final attributeId = item['attributeId'] as String;
          final attribute = item['attribute'] as Map<String, dynamic>;
          final value = item['value'];
          
          result[attributeId] = {
            'code': attribute['code'],
            'values': value is List ? value.cast<String>() : [value.toString()],
            'attribute': attribute,  // Include full attribute data for cardinality
          };
        }
        
        return result;
      } else {
        throw Exception('Failed to fetch attribute values');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_VALUE_API] Error data: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت مقادیر ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] Parse Error: $e');
      throw Exception('خطا در پردازش مقادیر ویژگی‌ها: $e');
    }
  }

  /// Get attribute values for a product
  Future<Map<String, List<String>>> getProductAttributeValues(
    String productId,
  ) async {
    try {
      print('🎨 [ATTRIBUTE_VALUE_API] Fetching values for product: $productId');

      final response = await dio.get(
        '/products/$productId/attribute-values',
      );

      print('✅ [ATTRIBUTE_VALUE_API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        // Transform API format to Map<attributeId, List<value>>
        final Map<String, List<String>> result = {};
        for (final item in data) {
          final attributeId = item['attributeId'] as String;
          final value = item['value'];
          
          if (value is List) {
            result[attributeId] = value.cast<String>();
          } else {
            result[attributeId] = [value.toString()];
          }
        }
        
        return result;
      } else {
        throw Exception('Failed to fetch attribute values');
      }
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_VALUE_API] Error data: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت مقادیر ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] Parse Error: $e');
      throw Exception('خطا در پردازش مقادیر ویژگی‌ها: $e');
    }
  }

  /// Delete all attribute values for a product
  Future<void> deleteProductAttributeValues(String productId) async {
    try {
      print('🎨 [ATTRIBUTE_VALUE_API] Deleting values for product: $productId');

      final response = await dio.delete(
        '/products/$productId/attribute-values',
      );

      print('✅ [ATTRIBUTE_VALUE_API] Response status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] DioException: ${e.response?.statusCode}');
      print('❌ [ATTRIBUTE_VALUE_API] Error data: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف مقادیر ویژگی‌ها');
      }
    } catch (e) {
      print('❌ [ATTRIBUTE_VALUE_API] Parse Error: $e');
      throw Exception('خطا در پردازش حذف مقادیر ویژگی‌ها: $e');
    }
  }
}
