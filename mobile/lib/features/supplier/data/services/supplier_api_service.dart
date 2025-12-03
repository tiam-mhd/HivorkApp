import 'package:dio/dio.dart';
import '../models/supplier_model.dart';
import '../dtos/supplier_dtos.dart';

class SupplierApiService {
  final Dio dio;

  SupplierApiService(this.dio);

  // ========================
  // Supplier CRUD
  // ========================

  /// Create new supplier
  Future<Supplier> createSupplier({
    required String businessId,
    required CreateSupplierDto dto,
  }) async {
    try {
      print('🔥 CREATE SUPPLIER DEBUG: Starting...');
      print('🔥 CREATE SUPPLIER DEBUG: businessId = $businessId');
      print('🔥 CREATE SUPPLIER DEBUG: dto = $dto');
      final jsonData = dto.toJson();
      print('🔥 CREATE SUPPLIER DEBUG: dto.toJson() = $jsonData');
      
      final response = await dio.post(
        '/suppliers',
        queryParameters: {'businessId': businessId},
        data: jsonData,
      );
      
      print('🔥 CREATE SUPPLIER DEBUG: Response status = ${response.statusCode}');
      print('🔥 CREATE SUPPLIER DEBUG: Response data = ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Supplier.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create supplier');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('تامین‌کننده با این مشخصات قبلاً ثبت شده');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد تامین‌کننده');
      }
    }
  }

  /// Get suppliers with filters
  Future<Map<String, dynamic>> getSuppliers({
    required String businessId,
    FilterSuppliersDto? filter,
  }) async {
    try {
      print('🔥 API DEBUG: businessId = "$businessId"');
      print('🔥 API DEBUG: filter = $filter');
      
      final queryParams = filter?.toQueryParameters() ?? {};
      queryParams['businessId'] = businessId;
      
      print('🔥 API DEBUG: queryParams = $queryParams');
      print('🔥 API DEBUG: Calling GET /suppliers');

      final response = await dio.get(
        '/suppliers',
        queryParameters: queryParams,
      );
      
      print('🔥 API DEBUG: Response status = ${response.statusCode}');
      print('🔥 API DEBUG: Response data = ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'data': (data['data'] as List?)
              ?.map((json) => Supplier.fromJson(json))
              .toList() ?? [],
          'pagination': data['pagination'],
        };
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

  /// Get supplier by ID
  Future<Supplier> getSupplierById({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/suppliers/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return Supplier.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Supplier not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('تامین‌کننده یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت تامین‌کننده');
      }
    }
  }

  /// Update supplier
  Future<Supplier> updateSupplier({
    required String id,
    required String businessId,
    required UpdateSupplierDto dto,
  }) async {
    try {
      final response = await dio.patch(
        '/suppliers/$id',
        queryParameters: {'businessId': businessId},
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return Supplier.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update supplier');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ویرایش تامین‌کننده');
      }
    }
  }

  /// Delete supplier
  Future<void> deleteSupplier({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.delete(
        '/suppliers/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete supplier');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('تامین‌کننده دارای سفارش فعال است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف تامین‌کننده');
      }
    }
  }

  /// Change supplier status
  Future<Supplier> changeSupplierStatus({
    required String id,
    required String businessId,
    required ChangeSupplierStatusDto dto,
  }) async {
    try {
      final response = await dio.patch(
        '/suppliers/$id/status',
        queryParameters: {'businessId': businessId},
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return Supplier.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to change status');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در تغییر وضعیت');
      }
    }
  }

  /// Get supplier stats
  Future<Map<String, dynamic>> getSupplierStats({
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/suppliers/stats',
        queryParameters: {
          'supplierId': id,
          'businessId': businessId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch stats');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت آمار');
      }
    }
  }
}
