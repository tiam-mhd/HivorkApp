import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/document_model.dart';

class DocumentApiService {
  final Dio dio;

  DocumentApiService(this.dio);

  /// Upload document
  Future<SupplierDocument> uploadDocument({
    required String supplierId,
    required String businessId,
    required String filePath,
    required String documentType,
    String? documentNumber,
    String? issueDate,
    String? expiryDate,
    String? notes,
  }) async {
    try {
      // Create FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          contentType: MediaType('application', 'octet-stream'),
        ),
        'documentType': documentType,
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (issueDate != null) 'issueDate': issueDate,
        if (expiryDate != null) 'expiryDate': expiryDate,
        if (notes != null) 'notes': notes,
      });

      final response = await dio.post(
        '/suppliers/$supplierId/documents',
        queryParameters: {'businessId': businessId},
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return SupplierDocument.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload document');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('فایل نامعتبر یا بیش از 10MB');
      } else if (e.response?.statusCode == 415) {
        throw Exception('فرمت فایل پشتیبانی نمی‌شود');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در آپلود مستند');
      }
    }
  }

  /// Get documents
  Future<List<SupplierDocument>> getDocuments({
    required String supplierId,
    required String businessId,
    String? documentType,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'businessId': businessId};
      if (documentType != null) queryParams['documentType'] = documentType;
      if (status != null) queryParams['status'] = status;

      final response = await dio.get(
        '/suppliers/$supplierId/documents',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SupplierDocument.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch documents');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت مستندات');
      }
    }
  }

  /// Get document by ID
  Future<SupplierDocument> getDocumentById({
    required String supplierId,
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/suppliers/$supplierId/documents/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return SupplierDocument.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Document not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('مستند یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت مستند');
      }
    }
  }

  /// Approve document
  Future<SupplierDocument> approveDocument({
    required String supplierId,
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.patch(
        '/suppliers/$supplierId/documents/$id/approve',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return SupplierDocument.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to approve document');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در تایید مستند');
      }
    }
  }

  /// Reject document
  Future<SupplierDocument> rejectDocument({
    required String supplierId,
    required String id,
    required String businessId,
    required String reason,
  }) async {
    try {
      final response = await dio.patch(
        '/suppliers/$supplierId/documents/$id/reject',
        queryParameters: {'businessId': businessId},
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return SupplierDocument.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to reject document');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در رد مستند');
      }
    }
  }

  /// Delete document
  Future<void> deleteDocument({
    required String supplierId,
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.delete(
        '/suppliers/$supplierId/documents/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete document');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف مستند');
      }
    }
  }
}
