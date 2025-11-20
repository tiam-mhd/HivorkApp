import 'package:dio/dio.dart';
import '../models/customer_group.dart';

class CustomerGroupApiService {
  final Dio dio;

  CustomerGroupApiService(this.dio);

  // Create Customer Group
  Future<CustomerGroup> createGroup(Map<String, dynamic> groupData) async {
    try {
      print('📂 [GROUP_API] Creating group with data: $groupData');
      
      final response = await dio.post(
        '/customer-groups',
        data: groupData,
      );

      print('✅ [GROUP_API] Response status: ${response.statusCode}');
      print('📂 [GROUP_API] Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Backend returns {success: true, message: '...', data: {...}}
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('data')) {
          return CustomerGroup.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return CustomerGroup.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create group');
      }
    } on DioException catch (e) {
      print('❌ [GROUP_API] DioException: ${e.response?.statusCode}');
      print('❌ [GROUP_API] Error data: ${e.response?.data}');
      
      if (e.response?.statusCode == 409) {
        throw Exception('نام گروه تکراری است');
      } else if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('خطا در ایجاد گروه');
      }
    } catch (e) {
      print('❌ [GROUP_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات گروه: $e');
    }
  }

  // Get All Groups
  Future<List<CustomerGroup>> getGroups(String businessId) async {
    try {
      print('📂 [GROUP_API] Fetching groups for business: $businessId');
      
      final response = await dio.get(
        '/customer-groups',
        queryParameters: {'businessId': businessId},
      );

      print('✅ [GROUP_API] Response status: ${response.statusCode}');
      print('📂 [GROUP_API] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> groupsData;
        
        if (responseData is Map && responseData.containsKey('data')) {
          groupsData = responseData['data'] as List;
        } else {
          groupsData = responseData as List;
        }
        
        print('📂 [GROUP_API] Parsing ${groupsData.length} groups');
        
        return groupsData
            .map((json) => CustomerGroup.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch groups');
      }
    } on DioException catch (e) {
      print('❌ [GROUP_API] DioException: ${e.response?.statusCode}');
      print('❌ [GROUP_API] Error data: ${e.response?.data}');
      throw Exception('خطا در دریافت لیست گروه‌ها: ${e.message}');
    } catch (e) {
      print('❌ [GROUP_API] Parse Error: $e');
      throw Exception('خطا در پردازش اطلاعات گروه‌ها: $e');
    }
  }

  // Get Group by ID
  Future<CustomerGroup> getGroupById(String id, String businessId) async {
    try {
      final response = await dio.get(
        '/customer-groups/$id',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('data')) {
          return CustomerGroup.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return CustomerGroup.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception('Group not found');
      }
    } on DioException catch (e) {
      print('❌ [GROUP_API] Error fetching group: ${e.message}');
      throw Exception('گروه یافت نشد');
    }
  }

  // Update Group
  Future<CustomerGroup> updateGroup(
    String id,
    String businessId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('📂 [GROUP_API] Updating group $id');
      
      final response = await dio.patch(
        '/customer-groups/$id',
        queryParameters: {'businessId': businessId},
        data: updates,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('data')) {
          return CustomerGroup.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return CustomerGroup.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update group');
      }
    } on DioException catch (e) {
      print('❌ [GROUP_API] Error updating group: ${e.message}');
      if (e.response?.statusCode == 409) {
        throw Exception('نام گروه تکراری است');
      }
      throw Exception('خطا در بروزرسانی گروه');
    }
  }

  // Delete Group (customers will be moved to general group)
  Future<void> deleteGroup(String id, String businessId) async {
    try {
      await dio.delete(
        '/customer-groups/$id',
        queryParameters: {'businessId': businessId},
      );
    } on DioException catch (e) {
      print('❌ [GROUP_API] Error deleting group: ${e.message}');
      throw Exception('خطا در حذف گروه');
    }
  }

  // Get Group Statistics
  Future<Map<String, dynamic>> getGroupStats(String businessId) async {
    try {
      final response = await dio.get(
        '/customer-groups/stats',
        queryParameters: {'businessId': businessId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch stats');
      }
    } on DioException catch (e) {
      throw Exception('خطا در دریافت آمار گروه‌ها');
    }
  }
}
