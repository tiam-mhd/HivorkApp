import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/supplier_provider.dart';
import '../../data/models/supplier_model.dart';
import '../../data/dtos/supplier_dtos.dart';

class SupplierFormPage extends StatefulWidget {
  final String businessId;
  final Supplier? supplier;

  const SupplierFormPage({
    Key? key,
    required this.businessId,
    this.supplier,
  }) : super(key: key);

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _economicCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _paymentTermDaysController = TextEditingController();
  final _paymentTermTypeController = TextEditingController();
  final _defaultLeadTimeDaysController = TextEditingController();
  final _incotermController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdowns
  SupplierType _selectedType = SupplierType.distributor;
  String _selectedCurrency = 'IRR';

  final List<String> _currencies = ['IRR', 'USD', 'EUR', 'AED'];

  @override
  void initState() {
    super.initState();
    _countryController.text = 'Iran';
    _creditLimitController.text = '0';
    _paymentTermDaysController.text = '0';
    _defaultLeadTimeDaysController.text = '7';

    if (widget.supplier != null) {
      _loadSupplierData();
    }
  }

  void _loadSupplierData() {
    final s = widget.supplier!;
    _nameController.text = s.name;
    _codeController.text = s.code ?? '';
    _legalNameController.text = s.legalName ?? '';
    _selectedType = s.type;
    _taxIdController.text = s.taxId ?? '';
    _nationalIdController.text = s.nationalId ?? '';
    _registrationNumberController.text = s.registrationNumber ?? '';
    _economicCodeController.text = s.economicCode ?? '';
    _phoneController.text = s.phone ?? '';
    _emailController.text = s.email ?? '';
    _websiteController.text = s.website ?? '';
    _addressController.text = s.address ?? '';
    _cityController.text = s.city ?? '';
    _provinceController.text = s.province ?? '';
    _postalCodeController.text = s.postalCode ?? '';
    _countryController.text = s.country;
    _selectedCurrency = s.currency;
    _creditLimitController.text = s.creditLimit.toString();
    _paymentTermDaysController.text = s.paymentTermDays.toString();
    _paymentTermTypeController.text = s.paymentTermType ?? '';
    _defaultLeadTimeDaysController.text = s.defaultLeadTimeDays.toString();
    _incotermController.text = s.incoterm ?? '';
    _industryController.text = s.industry ?? '';
    _descriptionController.text = s.description ?? '';
    _notesController.text = s.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _legalNameController.dispose();
    _taxIdController.dispose();
    _nationalIdController.dispose();
    _registrationNumberController.dispose();
    _economicCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _creditLimitController.dispose();
    _paymentTermDaysController.dispose();
    _paymentTermTypeController.dispose();
    _defaultLeadTimeDaysController.dispose();
    _incotermController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'ویرایش تامین‌کننده' : 'افزودن تامین‌کننده'),
        actions: [
          TextButton(
            onPressed: _saveSupplier,
            child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _buildSectionTitle('اطلاعات پایه'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'نام تامین‌کننده *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'نام الزامی است';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'کد تامین‌کننده *',
                border: OutlineInputBorder(),
                hintText: 'SUP-001',
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'کد الزامی است';
                }
                if (value.length > 50) {
                  return 'کد نباید بیشتر از 50 کاراکتر باشد';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _legalNameController,
              decoration: const InputDecoration(
                labelText: 'نام قانونی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SupplierType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع تامین‌کننده',
                border: OutlineInputBorder(),
              ),
              items: SupplierType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.typeText),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _industryController,
              decoration: const InputDecoration(
                labelText: 'صنعت',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // IDs
            _buildSectionTitle('شناسه‌ها'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxIdController,
              decoration: const InputDecoration(
                labelText: 'شناسه مالیاتی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                labelText: 'شناسه ملی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registrationNumberController,
              decoration: const InputDecoration(
                labelText: 'شماره ثبت',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _economicCodeController,
              decoration: const InputDecoration(
                labelText: 'کد اقتصادی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionTitle('اطلاعات تماس'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'تلفن',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'ایمیل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'وبسایت',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            // Address
            _buildSectionTitle('آدرس'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'آدرس',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'شهر',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'استان',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'کد پستی',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'کشور',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Financial Terms
            _buildSectionTitle('شرایط مالی'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'ارز',
                border: OutlineInputBorder(),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _creditLimitController,
              decoration: const InputDecoration(
                labelText: 'سقف اعتبار',
                border: OutlineInputBorder(),
                suffixText: 'واحد ارز',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _paymentTermDaysController,
                    decoration: const InputDecoration(
                      labelText: 'مهلت پرداخت (روز)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _paymentTermTypeController,
                    decoration: const InputDecoration(
                      labelText: 'نوع شرایط',
                      border: OutlineInputBorder(),
                      hintText: 'مثلاً: نقدی، چک',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _defaultLeadTimeDaysController,
                    decoration: const InputDecoration(
                      labelText: 'زمان تحویل (روز)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _incotermController,
                    decoration: const InputDecoration(
                      labelText: 'Incoterm',
                      border: OutlineInputBorder(),
                      hintText: 'مثلاً: FOB, CIF',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Additional Info
            _buildSectionTitle('اطلاعات تکمیلی'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'توضیحات',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'یادداشت',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _saveSupplier() async {
    print('🔥 FORM DEBUG: _saveSupplier called');
    
    if (!_formKey.currentState!.validate()) {
      print('🔥 FORM DEBUG: Validation failed');
      return;
    }

    print('🔥 FORM DEBUG: Validation passed');
    
    final provider = context.read<SupplierProvider>();
    final isEdit = widget.supplier != null;

    print('🔥 FORM DEBUG: isEdit = $isEdit');
    print('🔥 FORM DEBUG: businessId = ${widget.businessId}');

    try {
      if (isEdit) {
        print('🔥 FORM DEBUG: Creating UpdateSupplierDto...');
        final dto = UpdateSupplierDto(
          name: _nameController.text.isEmpty ? null : _nameController.text,
          code: _codeController.text.isEmpty ? null : _codeController.text,
          legalName: _legalNameController.text.isEmpty
              ? null
              : _legalNameController.text,
          type: _selectedType.name,
          taxId: _taxIdController.text.isEmpty ? null : _taxIdController.text,
          nationalId: _nationalIdController.text.isEmpty
              ? null
              : _nationalIdController.text,
          registrationNumber: _registrationNumberController.text.isEmpty
              ? null
              : _registrationNumberController.text,
          economicCode: _economicCodeController.text.isEmpty
              ? null
              : _economicCodeController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          website:
              _websiteController.text.isEmpty ? null : _websiteController.text,
          address:
              _addressController.text.isEmpty ? null : _addressController.text,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          province:
              _provinceController.text.isEmpty ? null : _provinceController.text,
          postalCode: _postalCodeController.text.isEmpty
              ? null
              : _postalCodeController.text,
          country:
              _countryController.text.isEmpty ? null : _countryController.text,
          currency: _selectedCurrency,
          creditLimit: double.tryParse(_creditLimitController.text),
          paymentTermDays: int.tryParse(_paymentTermDaysController.text),
          paymentTermType: _paymentTermTypeController.text.isEmpty
              ? null
              : _paymentTermTypeController.text,
          defaultLeadTimeDays:
              int.tryParse(_defaultLeadTimeDaysController.text),
          incoterm:
              _incotermController.text.isEmpty ? null : _incotermController.text,
          industry:
              _industryController.text.isEmpty ? null : _industryController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        await provider.updateSupplier(
          widget.businessId,
          widget.supplier!.id,
          dto,
        );
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تامین‌کننده با موفقیت بروزرسانی شد'),
            ),
          );
        }
      } else {
        print('🔥 FORM DEBUG: Creating CreateSupplierDto...');
        print('🔥 FORM DEBUG: name = ${_nameController.text}');
        print('🔥 FORM DEBUG: code = ${_codeController.text}');
        print('🔥 FORM DEBUG: code isEmpty = ${_codeController.text.isEmpty}');
        print('🔥 FORM DEBUG: legalName = ${_legalNameController.text}');
        print('🔥 FORM DEBUG: type = ${_selectedType.name}');
        
        final dto = CreateSupplierDto(
          name: _nameController.text,
          code: _codeController.text,
          legalName: _legalNameController.text.isEmpty
              ? null
              : _legalNameController.text,
          type: _selectedType.name,
          taxId: _taxIdController.text.isEmpty ? null : _taxIdController.text,
          nationalId: _nationalIdController.text.isEmpty
              ? null
              : _nationalIdController.text,
          registrationNumber: _registrationNumberController.text.isEmpty
              ? null
              : _registrationNumberController.text,
          economicCode: _economicCodeController.text.isEmpty
              ? null
              : _economicCodeController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          website:
              _websiteController.text.isEmpty ? null : _websiteController.text,
          address:
              _addressController.text.isEmpty ? null : _addressController.text,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          province:
              _provinceController.text.isEmpty ? null : _provinceController.text,
          postalCode: _postalCodeController.text.isEmpty
              ? null
              : _postalCodeController.text,
          country:
              _countryController.text.isEmpty ? null : _countryController.text,
          currency: _selectedCurrency,
          creditLimit: double.tryParse(_creditLimitController.text),
          paymentTermDays: int.tryParse(_paymentTermDaysController.text),
          paymentTermType: _paymentTermTypeController.text.isEmpty
              ? null
              : _paymentTermTypeController.text,
          defaultLeadTimeDays:
              int.tryParse(_defaultLeadTimeDaysController.text),
          incoterm:
              _incotermController.text.isEmpty ? null : _incotermController.text,
          industry:
              _industryController.text.isEmpty ? null : _industryController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        print('🔥 FORM DEBUG: DTO created, calling provider.createSupplier...');
        final createdSupplier = await provider.createSupplier(widget.businessId, dto);
        print('🔥 FORM DEBUG: provider.createSupplier completed');

        if (mounted && createdSupplier != null) {
          Navigator.pop(context, createdSupplier);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تامین‌کننده با موفقیت ایجاد شد'),
            ),
          );
        } else if (mounted) {
          throw Exception('ایجاد تامین‌کننده ناموفق بود');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
