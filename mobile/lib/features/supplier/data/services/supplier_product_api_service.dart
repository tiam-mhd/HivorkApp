import 'package:dio/dio.dart';
import '../models/supplier_product_model.dart';

class SupplierProductApiService {
  final Dio dio;

  SupplierProductApiService(this.dio);

  /// Add product to supplier
  Future<SupplierProduct> addProduct({
    required String supplierId,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(
        '/suppliers/$supplierId/products',
        queryParameters: {'businessId': businessId},
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return SupplierProduct.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('محصول قبلاً به این تامین‌کننده اضافه شده');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در افزودن محصول');
      }
    }
  }

  /// Get supplier products
  Future<List<SupplierProduct>> getSupplierProducts({
    required String supplierId,
    required String businessId,
    bool? isActive,
    bool? isPreferred,
  }) async {
    try {
      final queryParams = <String, dynamic>{'businessId': businessId};
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (isPreferred != null) queryParams['isPreferred'] = isPreferred.toString();

      final response = await dio.get(
        '/suppliers/$supplierId/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SupplierProduct.fromJson(json)).toList();
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

  /// Get suppliers for a product
  Future<List<SupplierProduct>> getProductSuppliers({
    required String productId,
    required String businessId,
    String? productVariantId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'businessId': businessId};
      if (productVariantId != null) queryParams['productVariantId'] = productVariantId;

      final response = await dio.get(
        '/suppliers/products/$productId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SupplierProduct.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch suppliers');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت تامین‌کنندگان');
      }
    }
  }

  /// Update supplier product
  Future<SupplierProduct> updateSupplierProduct({
    required String supplierId,
    required String id,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.patch(
        '/suppliers/$supplierId/products/$id',
        queryParameters: {'businessId': businessId},
        data: data,
      );

      if (response.statusCode == 200) {
        return SupplierProduct.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ویرایش محصول');
      }
    }
  }

  /// Remove product from supplier
  Future<void> removeProduct({
    required String supplierId,
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.delete(
        '/suppliers/$supplierId/products/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to remove product');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف محصول');
      }
    }
  }
}
