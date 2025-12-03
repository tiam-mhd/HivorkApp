import 'package:dio/dio.dart';
import '../models/customer.dart';
import '../models/customer_filter.dart';
import '../models/customer_stats.dart';

class CustomerApiService {
  final Dio dio;

  CustomerApiService(this.dio);

  // Create Customer
  Future<Customer> createCustomer(Map<String, dynamic> customerData) async {
    try {
      print('👤 [CUSTOMER_API] Creating customer with data: $customerData');
      
      final response = await dio.post(
        '/customers',
        data: customerData,
      );

      print('✅ [CUSTOMER_API] Response status: ${response.statusCode}');
      print('👤 [CUSTOMER_API] Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Customer.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create customer');
      }
    } on DioException catch (e) {
      print('❌ [CUSTOMER_API] DioException: ${e.response?.statusCode}');
      print('❌ [CUSTOMER_API] Error data: ${e.response?.data}');
      
      if (e.response?.statusCode == 409) {
        throw Exception('کد مشتری یا شماره تماس تکراری است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد مشتری');
      }
    } catch (e) {
      print('❌ [CUSTOMER_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات مشتری: $e');
    }
  }

  // Get Customers with Filter
  Future<Map<String, dynamic>> getCustomers({
    required String businessId,
    CustomerFilter? filter,
  }) async {
    try {
      final queryParams = filter?.toQueryParameters() ?? {};
      queryParams['businessId'] = businessId;

      print('🔍 [CUSTOMER_API] Fetching customers with params: $queryParams');

      final response = await dio.get(
        '/customers',
        queryParameters: queryParams,
      );

      print('✅ [CUSTOMER_API] Response status: ${response.statusCode}');
      print('📦 [CUSTOMER_API] Response data type: ${response.data.runtimeType}');
      print('📦 [CUSTOMER_API] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'data': (data['data'] as List?)
              ?.map((json) => Customer.fromJson(json))
              .toList() ?? [],
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'limit': data['limit'] ?? 20,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch customers');
      }
    } on DioException catch (e) {
      print('❌ [CUSTOMER_API] DioException type: ${e.type}');
      print('❌ [CUSTOMER_API] Error message: ${e.message}');
      print('❌ [CUSTOMER_API] Response status: ${e.response?.statusCode}');
      print('❌ [CUSTOMER_API] Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('لطفاً دوباره وارد شوید');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در دریافت لیست مشتریان: ${e.message}');
      }
    } catch (e) {
      print('❌ [CUSTOMER_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات مشتریان: $e');
    }
  }

  // Get Customer by ID
  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await dio.get('/customers/$id');

      if (response.statusCode == 200) {
        print('✅ [CUSTOMER_API] Customer data: ${response.data}');
        return Customer.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Customer not found');
      }
    } on DioException catch (e) {
      print('❌ [CUSTOMER_API] Error fetching customer: ${e.message}');
      throw Exception('مشتری یافت نشد');
    }
  }

  // Update Customer
  Future<Customer> updateCustomer(String id, Map<String, dynamic> updates) async {
    try {
      print('👤 [CUSTOMER_API] Updating customer $id');
      print('👤 [CUSTOMER_API] Update data: $updates');
      
      final response = await dio.patch(
        '/customers/$id',
        data: updates,
      );

      print('👤 [CUSTOMER_API] Response status: ${response.statusCode}');
      print('👤 [CUSTOMER_API] Response data: ${response.data}');

      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update customer');
      }
    } on DioException catch (e) {
      print('❌ [CUSTOMER_API] Error updating customer: ${e.message}');
      if (e.response?.statusCode == 409) {
        throw Exception('شماره تماس یا ایمیل تکراری است');
      }
      throw Exception('خطا در بروزرسانی مشتری');
    }
  }

  // Delete Customer
  Future<void> deleteCustomer(String id) async {
    try {
      await dio.delete('/customers/$id');
    } on DioException catch (e) {
      print('❌ [CUSTOMER_API] Error deleting customer: ${e.message}');
      if (e.response?.statusCode == 409) {
        throw Exception('امکان حذف مشتری با حساب باز وجود ندارد');
      }
      throw Exception('خطا در حذف مشتری');
    }
  }

  // Update Customer Status
  Future<Customer> updateCustomerStatus(String id, String status) async {
    try {
      final response = await dio.patch(
        '/customers/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      } else {
        throw Exception('Failed to update status');
      }
    } on DioException catch (e) {
      throw Exception('خطا در بروزرسانی وضعیت مشتری');
    }
  }

  // Get Customer Statistics
  Future<CustomerStats> getCustomerStats(String businessId) async {
    try {
      final response = await dio.get(
        '/customers/stats',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return CustomerStats.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch stats');
      }
    } on DioException catch (e) {
      throw Exception('خطا در دریافت آمار مشتریان');
    }
  }

  // Get Categories
  Future<List<String>> getCategories(String businessId) async {
    try {
      final response = await dio.get(
        '/customers/categories',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get Sources
  Future<List<String>> getSources(String businessId) async {
    try {
      final response = await dio.get(
        '/customers/sources',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get Tags
  Future<List<String>> getTags(String businessId) async {
    try {
      final response = await dio.get(
        '/customers/tags',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Autocomplete Search
  Future<List<Map<String, dynamic>>> autocomplete({
    required String businessId,
    String? search,
    int limit = 10,
  }) async {
    try {
      print('🔍 [CUSTOMER_API] Autocomplete search: "$search"');
      
      final response = await dio.get(
        '/customers/autocomplete',
        queryParameters: {
          'businessId': businessId,
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
        },
      );

      print('✅ [CUSTOMER_API] Autocomplete response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print('❌ [CUSTOMER_API] Autocomplete error: ${e.message}');
      return [];
    } catch (e) {
      print('❌ [CUSTOMER_API] Autocomplete parse error: $e');
      return [];
    }
  }
}
