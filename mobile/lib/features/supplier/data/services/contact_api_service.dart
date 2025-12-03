import 'package:dio/dio.dart';
import '../models/contact_model.dart';

class ContactApiService {
  final Dio dio;

  ContactApiService(this.dio);

  /// Create contact
  Future<Contact> createContact({
    required String supplierId,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(
        '/suppliers/$supplierId/contacts',
        queryParameters: {'businessId': businessId},
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Contact.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create contact');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد مخاطب');
      }
    }
  }

  /// Get contacts
  Future<List<Contact>> getContacts({
    required String supplierId,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/suppliers/$supplierId/contacts',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Contact.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch contacts');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت مخاطبین');
      }
    }
  }

  /// Get contact by ID
  Future<Contact> getContactById({
    required String supplierId,
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.get(
        '/suppliers/$supplierId/contacts/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return Contact.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Contact not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('مخاطب یافت نشد');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت مخاطب');
      }
    }
  }

  /// Update contact
  Future<Contact> updateContact({
    required String supplierId,
    required String id,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.patch(
        '/suppliers/$supplierId/contacts/$id',
        queryParameters: {'businessId': businessId},
        data: data,
      );

      if (response.statusCode == 200) {
        return Contact.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update contact');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ویرایش مخاطب');
      }
    }
  }

  /// Delete contact
  Future<void> deleteContact({
    required String supplierId,
    required String id,
    required String businessId,
  }) async {
    try {
      final response = await dio.delete(
        '/suppliers/$supplierId/contacts/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete contact');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در حذف مخاطب');
      }
    }
  }
}
