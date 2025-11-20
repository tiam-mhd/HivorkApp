import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_group.dart';
import '../bloc/customer_bloc.dart';

class CustomerFormPage extends StatefulWidget {
  final String businessId;
  final Customer? customer;
  final List<CustomerGroup>? groups;

  const CustomerFormPage({
    Key? key,
    required this.businessId,
    this.customer,
    this.groups,
  }) : super(key: key);

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  CustomerType _type = CustomerType.individual;
  String? _selectedGroupId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.customer?.customerCode ?? '');
    _nameController = TextEditingController(text: widget.customer?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _type = widget.customer?.type ?? CustomerType.individual;
    
    // بررسی اینکه groupId مشتری در لیست گروه‌ها موجود باشه
    final customerGroupId = widget.customer?.groupId;
    print('🔍 [FORM_INIT] Customer groupId: $customerGroupId');
    print('🔍 [FORM_INIT] Customer groupName: ${widget.customer?.groupName}');
    print('🔍 [FORM_INIT] Available groups: ${widget.groups?.map((g) => '${g.name}(${g.id})').join(', ')}');
    
    if (customerGroupId != null && widget.groups != null) {
      final groupExists = widget.groups!.any((g) => g.id == customerGroupId);
      _selectedGroupId = groupExists ? customerGroupId : null;
      print('🔍 [FORM_INIT] Group exists: $groupExists, Selected: $_selectedGroupId');
    } else {
      _selectedGroupId = customerGroupId;
      print('🔍 [FORM_INIT] No group or no groups list, Selected: $_selectedGroupId');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'افزودن مشتری' : 'ویرایش مشتری'),
      ),
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            Navigator.pop(context, true);
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
            setState(() => _saving = false);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام و نام خانوادگی *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'نام الزامی است' : null,
                ),
                const SizedBox(height: 16),
                
                // Phone (Required)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'شماره تماس *',
                    border: OutlineInputBorder(),
                    helperText: 'الزامی',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true ? 'شماره تماس الزامی است' : null,
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'ایمیل',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Group Selection
                DropdownButtonFormField<String>(
                  value: _selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'گروه',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('عمومی')),
                    if (widget.groups != null)
                      ...widget.groups!.map((group) => DropdownMenuItem(
                            value: group.id,
                            child: Text(group.name),
                          )).toList(),
                  ],
                  onChanged: (value) {
                    print('📝 [FORM] Group changed to: $value');
                    setState(() => _selectedGroupId = value);
                  },
                ),
                const SizedBox(height: 24),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveCustomer,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(widget.customer == null ? 'ذخیره' : 'بروزرسانی'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'fullName': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      'type': _type.toString().split('.').last,
      'groupId': _selectedGroupId,
    };

    print('💾 [FORM] Saving customer with data: $data');
    print('💾 [FORM] Selected groupId: $_selectedGroupId');

    if (widget.customer == null) {
      // فقط برای ایجاد مشتری جدید businessId ارسال می‌شود
      data['businessId'] = widget.businessId;
      context.read<CustomerBloc>().add(CreateCustomer(data));
    } else {
      // برای ویرایش businessId و customerCode ارسال نمی‌شود چون غیرقابل تغییرند
      context.read<CustomerBloc>().add(UpdateCustomer(widget.customer!.id, data));
    }
  }
}
