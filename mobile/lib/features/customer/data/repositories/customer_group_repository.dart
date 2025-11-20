import '../models/customer_group.dart';
import '../services/customer_group_api_service.dart';

class CustomerGroupRepository {
  final CustomerGroupApiService apiService;

  CustomerGroupRepository(this.apiService);

  Future<CustomerGroup> createGroup(Map<String, dynamic> groupData) async {
    return await apiService.createGroup(groupData);
  }

  Future<List<CustomerGroup>> getGroups(String businessId) async {
    return await apiService.getGroups(businessId);
  }

  Future<CustomerGroup> getGroupById(String id, String businessId) async {
    return await apiService.getGroupById(id, businessId);
  }

  Future<CustomerGroup> updateGroup(
    String id,
    String businessId,
    Map<String, dynamic> updates,
  ) async {
    return await apiService.updateGroup(id, businessId, updates);
  }

  Future<void> deleteGroup(String id, String businessId) async {
    await apiService.deleteGroup(id, businessId);
  }

  Future<Map<String, dynamic>> getGroupStats(String businessId) async {
    return await apiService.getGroupStats(businessId);
  }
}
