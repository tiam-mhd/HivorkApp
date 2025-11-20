import '../models/customer.dart';
import '../models/customer_filter.dart';
import '../models/customer_stats.dart';
import '../services/customer_api_service.dart';

class CustomerRepository {
  final CustomerApiService apiService;

  CustomerRepository(this.apiService);

  Future<Customer> createCustomer(Map<String, dynamic> customerData) async {
    return await apiService.createCustomer(customerData);
  }

  Future<Map<String, dynamic>> getCustomers({
    required String businessId,
    CustomerFilter? filter,
  }) async {
    return await apiService.getCustomers(
      businessId: businessId,
      filter: filter,
    );
  }

  Future<Customer> getCustomerById(String id) async {
    return await apiService.getCustomerById(id);
  }

  Future<Customer> updateCustomer(String id, Map<String, dynamic> updates) async {
    return await apiService.updateCustomer(id, updates);
  }

  Future<void> deleteCustomer(String id) async {
    await apiService.deleteCustomer(id);
  }

  Future<Customer> updateCustomerStatus(String id, String status) async {
    return await apiService.updateCustomerStatus(id, status);
  }

  Future<CustomerStats> getCustomerStats(String businessId) async {
    return await apiService.getCustomerStats(businessId);
  }

  Future<List<String>> getCategories(String businessId) async {
    return await apiService.getCategories(businessId);
  }

  Future<List<String>> getSources(String businessId) async {
    return await apiService.getSources(businessId);
  }

  Future<List<String>> getTags(String businessId) async {
    return await apiService.getTags(businessId);
  }
}
