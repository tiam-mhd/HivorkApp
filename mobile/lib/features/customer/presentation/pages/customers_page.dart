import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_filter.dart';
import '../../data/models/customer_group.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/customer_group_repository.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/services/customer_group_api_service.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/customer_list_item.dart';
import 'customer_form_page.dart';
import 'customer_detail_page.dart';
import 'customer_groups_management_page.dart';

class CustomersPage extends StatefulWidget {
  final String businessId;
  final CustomerFilter? initialFilter;

  const CustomersPage({
    Key? key,
    required this.businessId,
    this.initialFilter,
  }) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late CustomerBloc _customerBloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  CustomerFilter? _currentFilter;
  
  // Groups
  List<CustomerGroup> _groups = [];
  bool _loadingGroups = false;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    final dio = ServiceLocator().dio;
    _customerBloc = CustomerBloc(
      CustomerRepository(CustomerApiService(dio)),
    );
    _customerBloc.add(LoadCustomers(
      businessId: widget.businessId,
      filter: _currentFilter,
    ));

    _scrollController.addListener(_onScroll);
    _loadGroups();
  }
  
  Future<void> _loadGroups() async {
    setState(() => _loadingGroups = true);
    try {
      final dio = ServiceLocator().dio;
      final apiService = CustomerGroupApiService(dio);
      final groups = await apiService.getGroups(widget.businessId);
      setState(() {
        _groups = groups;
        _loadingGroups = false;
      });
    } catch (e) {
      print('❌ Error loading groups: $e');
      setState(() => _loadingGroups = false);
    }
  }
  
  void _onGroupSelected(String? groupId) {
    setState(() {
      _selectedGroupId = groupId;
      if (groupId == null) {
        _currentFilter = _currentFilter?.copyWith(groupId: null) ?? CustomerFilter();
      } else if (groupId == 'null') {
        _currentFilter = (_currentFilter ?? CustomerFilter()).copyWith(groupId: 'null');
      } else {
        _currentFilter = (_currentFilter ?? CustomerFilter()).copyWith(groupId: groupId);
      }
    });
    _customerBloc.add(LoadCustomers(businessId: widget.businessId, filter: _currentFilter));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _customerBloc.add(LoadNextPage());
    }
  }

  @override
  void dispose() {
    _customerBloc.close();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _customerBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مشتریان'),
          actions: [
            // گروه‌بندی
            IconButton(
              icon: const Icon(Icons.folder_special),
              tooltip: 'مدیریت گروه‌بندی',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerGroupsManagementPage(
                      businessId: widget.businessId,
                    ),
                  ),
                );
                _loadGroups();
                _customerBloc.add(LoadCustomers(
                  businessId: widget.businessId,
                  filter: _currentFilter,
                ));
              },
            ),
            // جستجو
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            // فیلتر
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Group filter chips
            if (_groups.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  children: [
                    // همه
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: const Text('همه'),
                        selected: _selectedGroupId == null,
                        onSelected: (_) => _onGroupSelected(null),
                      ),
                    ),
                    // عمومی (بدون گروه)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: const Text('عمومی'),
                        selected: _selectedGroupId == 'null',
                        onSelected: (_) => _onGroupSelected('null'),
                      ),
                    ),
                    // Groups
                    ..._groups.map((group) {
                      final isSelected = _selectedGroupId == group.id;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (group.color != null)
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: _parseColor(group.color!),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(group.name),
                              if (group.customerCount != null && group.customerCount! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    '(${group.customerCount})',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) => _onGroupSelected(group.id),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            
            // Customer list
            Expanded(
              child: BlocConsumer<CustomerBloc, CustomerState>(
                listener: (context, state) {
                  if (state is CustomerOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                    _customerBloc.add(LoadCustomers(
                      businessId: widget.businessId,
                      filter: _currentFilter,
                    ));
                  } else if (state is CustomerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CustomerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomerLoaded) {
                    if (state.customers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'مشتری یافت نشد',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'برای افزودن مشتری جدید روی دکمه + کلیک کنید',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _customerBloc.add(RefreshCustomers());
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.customers.length + (state.hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= state.customers.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final customer = state.customers[index];
                          return CustomerListItem(
                            customer: customer,
                            onTap: () => _navigateToDetail(customer),
                            onEdit: () => _navigateToEdit(customer),
                            onDelete: () => _confirmDelete(customer),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToCreate,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('جستجو'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'نام، کد، تلفن یا ایمیل',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _applySearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
              _applySearch('');
            },
            child: const Text('پاک کردن'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applySearch(_searchController.text);
            },
            child: const Text('جستجو'),
          ),
        ],
      ),
    );
  }

  void _applySearch(String query) {
    setState(() {
      _currentFilter = (_currentFilter ?? CustomerFilter()).copyWith(
        search: query.isEmpty ? null : query,
      );
    });
    _customerBloc.add(LoadCustomers(
      businessId: widget.businessId,
      filter: _currentFilter,
    ));
  }

  void _showFilterDialog() {
    // TODO: Implement advanced filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فیلتر پیشرفته به زودی...')),
    );
  }

  void _navigateToDetail(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(
          customerId: customer.id,
          businessId: widget.businessId,
        ),
      ),
    );
    
    // اگر در صفحه جزئیات تغییری رخ داده (ویرایش یا حذف)، لیست را بروزرسانی کن
    if (result == true) {
      _customerBloc.add(LoadCustomers(
        businessId: widget.businessId,
        filter: _currentFilter,
      ));
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _customerBloc,
          child: CustomerFormPage(
            businessId: widget.businessId,
            groups: _groups,
          ),
        ),
      ),
    );

    if (result == true) {
      _customerBloc.add(LoadCustomers(
        businessId: widget.businessId,
        filter: _currentFilter,
      ));
    }
  }

  void _navigateToEdit(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _customerBloc,
          child: CustomerFormPage(
            businessId: widget.businessId,
            customer: customer,
            groups: _groups,
          ),
        ),
      ),
    );

    if (result == true) {
      _customerBloc.add(LoadCustomers(
        businessId: widget.businessId,
        filter: _currentFilter,
      ));
    }
  }

  void _confirmDelete(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مشتری'),
        content: Text('آیا از حذف "${customer.displayName}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _customerBloc.add(DeleteCustomer(customer.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
