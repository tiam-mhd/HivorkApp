import '../../data/models/customer.dart';
import '../../data/models/customer_filter.dart';

abstract class CustomerEvent {}

class LoadCustomers extends CustomerEvent {
  final String businessId;
  final CustomerFilter? filter;

  LoadCustomers({required this.businessId, this.filter});
}

class LoadCustomerById extends CustomerEvent {
  final String id;

  LoadCustomerById(this.id);
}

class CreateCustomer extends CustomerEvent {
  final Map<String, dynamic> customerData;

  CreateCustomer(this.customerData);
}

class UpdateCustomer extends CustomerEvent {
  final String id;
  final Map<String, dynamic> updates;

  UpdateCustomer(this.id, this.updates);
}

class DeleteCustomer extends CustomerEvent {
  final String id;

  DeleteCustomer(this.id);
}

class UpdateCustomerStatus extends CustomerEvent {
  final String id;
  final String status;

  UpdateCustomerStatus(this.id, this.status);
}

class LoadCustomerStats extends CustomerEvent {
  final String businessId;

  LoadCustomerStats(this.businessId);
}

class LoadCategories extends CustomerEvent {
  final String businessId;

  LoadCategories(this.businessId);
}

class LoadSources extends CustomerEvent {
  final String businessId;

  LoadSources(this.businessId);
}

class LoadTags extends CustomerEvent {
  final String businessId;

  LoadTags(this.businessId);
}

class ApplyFilter extends CustomerEvent {
  final CustomerFilter filter;

  ApplyFilter(this.filter);
}

class ClearFilter extends CustomerEvent {}

class SearchCustomers extends CustomerEvent {
  final String query;

  SearchCustomers(this.query);
}

class LoadNextPage extends CustomerEvent {}

class RefreshCustomers extends CustomerEvent {}

// Customer State
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final int total;
  final int currentPage;
  final int totalPages;
  final CustomerFilter? currentFilter;
  final bool hasMore;

  CustomerLoaded({
    required this.customers,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    this.currentFilter,
    required this.hasMore,
  });
}

class CustomerDetailLoaded extends CustomerState {
  final Customer customer;

  CustomerDetailLoaded(this.customer);
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  final Customer? customer;

  CustomerOperationSuccess(this.message, {this.customer});
}

class CustomerError extends CustomerState {
  final String message;

  CustomerError(this.message);
}

class CustomerStatsLoaded extends CustomerState {
  final Map<String, dynamic> stats;

  CustomerStatsLoaded(this.stats);
}

class CategoriesLoaded extends CustomerState {
  final List<String> categories;

  CategoriesLoaded(this.categories);
}

class SourcesLoaded extends CustomerState {
  final List<String> sources;

  SourcesLoaded(this.sources);
}

class TagsLoaded extends CustomerState {
  final List<String> tags;

  TagsLoaded(this.tags);
}
