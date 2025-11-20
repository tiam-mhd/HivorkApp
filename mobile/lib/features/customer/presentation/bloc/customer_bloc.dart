import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_filter.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_event.dart';

export 'customer_event.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;
  String? _currentBusinessId;
  CustomerFilter? _currentFilter;

  CustomerBloc(this.repository) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadCustomerById>(_onLoadCustomerById);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<UpdateCustomerStatus>(_onUpdateStatus);
    on<LoadCustomerStats>(_onLoadStats);
    on<LoadCategories>(_onLoadCategories);
    on<LoadSources>(_onLoadSources);
    on<LoadTags>(_onLoadTags);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilter>(_onClearFilter);
    on<SearchCustomers>(_onSearchCustomers);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshCustomers>(_onRefreshCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      _currentBusinessId = event.businessId;
      _currentFilter = event.filter;

      final result = await repository.getCustomers(
        businessId: event.businessId,
        filter: event.filter,
      );

      final customers = (result['data'] as List).cast<Customer>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(CustomerLoaded(
        customers: customers,
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: event.filter,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadCustomerById(
    LoadCustomerById event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      final customer = await repository.getCustomerById(event.id);
      emit(CustomerDetailLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      final customer = await repository.createCustomer(event.customerData);
      emit(CustomerOperationSuccess('مشتری با موفقیت ایجاد شد', customer: customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      final customer = await repository.updateCustomer(event.id, event.updates);
      emit(CustomerOperationSuccess('مشتری با موفقیت بروزرسانی شد', customer: customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      await repository.deleteCustomer(event.id);
      emit(CustomerOperationSuccess('مشتری با موفقیت حذف شد'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateCustomerStatus event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      await repository.updateCustomerStatus(event.id, event.status);
      emit(CustomerOperationSuccess('وضعیت مشتری بروزرسانی شد'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadStats(
    LoadCustomerStats event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      final stats = await repository.getCustomerStats(event.businessId);
      emit(CustomerStatsLoaded({
        'total': stats.total,
        'active': stats.active,
        'inactive': stats.inactive,
        'blocked': stats.blocked,
        'withDebt': stats.withDebt,
        'withCredit': stats.withCredit,
        'totalDebt': stats.totalDebt,
        'totalCredit': stats.totalCredit,
        'totalSales': stats.totalSales,
      }));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      final categories = await repository.getCategories(event.businessId);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadSources(
    LoadSources event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      final sources = await repository.getSources(event.businessId);
      emit(SourcesLoaded(sources));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadTags(
    LoadTags event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      final tags = await repository.getTags(event.businessId);
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<CustomerState> emit,
  ) async {
    if (_currentBusinessId == null) return;
    
    _currentFilter = event.filter;
    add(LoadCustomers(businessId: _currentBusinessId!, filter: event.filter));
  }

  Future<void> _onClearFilter(
    ClearFilter event,
    Emitter<CustomerState> emit,
  ) async {
    if (_currentBusinessId == null) return;
    
    _currentFilter = null;
    add(LoadCustomers(businessId: _currentBusinessId!));
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    if (_currentBusinessId == null) return;
    
    _currentFilter = (_currentFilter ?? CustomerFilter()).copyWith(
      search: event.query.isEmpty ? null : event.query,
    );
    add(LoadCustomers(businessId: _currentBusinessId!, filter: _currentFilter));
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomerLoaded) return;
    
    final currentState = state as CustomerLoaded;
    if (!currentState.hasMore || _currentBusinessId == null) return;

    final nextPage = currentState.currentPage + 1;
    final nextFilter = (_currentFilter ?? CustomerFilter()).copyWith(page: nextPage);

    try {
      final result = await repository.getCustomers(
        businessId: _currentBusinessId!,
        filter: nextFilter,
      );

      final newCustomers = (result['data'] as List).cast<Customer>();
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = (total / limit).ceil();
      final hasMore = page < totalPages;

      emit(CustomerLoaded(
        customers: [...currentState.customers, ...newCustomers],
        total: total,
        currentPage: page,
        totalPages: totalPages,
        currentFilter: nextFilter,
        hasMore: hasMore,
      ));
    } catch (e) {
      // Don't emit error, just keep current state
    }
  }

  Future<void> _onRefreshCustomers(
    RefreshCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    if (_currentBusinessId == null) return;
    
    add(LoadCustomers(businessId: _currentBusinessId!, filter: _currentFilter));
  }
}
