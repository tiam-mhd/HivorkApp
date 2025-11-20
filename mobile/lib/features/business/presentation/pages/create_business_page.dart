import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/business_api_service.dart';
import '../../data/datasources/business_metadata_api_service.dart';
import '../../data/models/business_model.dart';
import '../../data/models/business_metadata_model.dart';
import '../../../../core/di/service_locator.dart';

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  State<CreateBusinessPage> createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  final _pageController = PageController();
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  
  final _nameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  late final BusinessApiService _businessApi;
  late final BusinessMetadataApiService _metadataApi;
  
  List<BusinessCategory> _categories = [];
  List<BusinessIndustry> _industries = [];
  BusinessCategory? _selectedCategory;
  BusinessIndustry? _selectedIndustry;
  
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _businessApi = BusinessApiService(dio);
    _metadataApi = BusinessMetadataApiService(dio);
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final categories = await _metadataApi.getCategories();
      final industries = await _metadataApi.getIndustries();

      setState(() {
        _categories = categories;
        _industries = industries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKeys[_currentStep].currentState!.validate()) {
      return;
    }

    // اگر در آخرین مرحله هستیم، فرم را submit کنیم
    if (_currentStep == 2) {
      try {
        setState(() {
          _isSubmitting = true;
          _errorMessage = null;
        });

        final request = CreateBusinessRequest(
          name: _nameController.text.trim(),
          tradeName: _tradeNameController.text.trim().isEmpty ? null : _tradeNameController.text.trim(),
          categoryId: _selectedCategory?.id,
          industryId: _selectedIndustry?.id,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        );

        final business = await _businessApi.createBusiness(request);

        if (mounted) {
          // ذخیره ID کسب و کار جدید به عنوان کسب و کار فعال
          final storage = ServiceLocator().secureStorage;
          await storage.write(key: 'active_business_id', value: business.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('کسب و کار "${business.name}" با موفقیت ایجاد شد'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // برگشت به صفحه اصلی با سیگنال ریلود
          if (context.mounted) {
            context.go('/dashboard', extra: {'reload': true, 'newBusinessId': business.id});
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSubmitting = false;
        });
      }
    } else {
      // به مرحله بعد برویم
      _nextStep();
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _tradeNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'ایجاد کسب و کار',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Step Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _buildStepIndicator(0, 'اطلاعات پایه'),
                      _buildStepLine(0),
                      _buildStepIndicator(1, 'دسته‌بندی'),
                      _buildStepLine(1),
                      _buildStepIndicator(2, 'تماس و آدرس'),
                    ],
                  ),
                ),
                
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // PageView for steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),
                
                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('قبلی'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentStep == 0 ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _currentStep == 2 ? 'ثبت کسب و کار' : 'بعدی',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final theme = Theme.of(context);
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final theme = Theme.of(context);
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceVariant,
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اطلاعات پایه کسب و کار',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'نام و توضیحات کسب و کار خود را وارد کنید',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'نام کسب و کار *',
                hintText: 'مثال: فروشگاه الکترونیک آریا',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'نام کسب و کار الزامی است';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tradeNameController,
              decoration: InputDecoration(
                labelText: 'نام تجاری',
                hintText: 'مثال: آریا شاپ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.storefront),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'توضیحات',
                hintText: 'توضیح کوتاهی درباره کسب و کار',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'دسته‌بندی کسب و کار',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'دسته‌بندی و صنعت کسب و کار را انتخاب کنید',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            DropdownButtonFormField<BusinessCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'دسته‌بندی کسب و کار',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      if (category.icon != null)
                        Icon(
                          _getIconData(category.icon!),
                          size: 20,
                          color: category.color != null 
                              ? _parseColor(category.color!) 
                              : null,
                        ),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<BusinessIndustry>(
              value: _selectedIndustry,
              decoration: InputDecoration(
                labelText: 'صنعت',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.work),
              ),
              items: _industries.map((industry) {
                return DropdownMenuItem(
                  value: industry,
                  child: Row(
                    children: [
                      if (industry.icon != null)
                        Icon(
                          _getIconData(industry.icon!),
                          size: 20,
                          color: industry.color != null 
                              ? _parseColor(industry.color!) 
                              : null,
                        ),
                      const SizedBox(width: 8),
                      Text(industry.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIndustry = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اطلاعات تماس',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اطلاعات تماس و آدرس کسب و کار را وارد کنید',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'شماره تماس',
                hintText: '02112345678',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'ایمیل',
                hintText: 'info@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'فرمت ایمیل نامعتبر است';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'آدرس',
                hintText: 'تهران، خیابان ولیعصر، پلاک 123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // تبدیل نام آیکون به IconData
    switch (iconName) {
      case 'storefront': return Icons.storefront;
      case 'business': return Icons.business;
      case 'restaurant': return Icons.restaurant;
      case 'build': return Icons.build;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'local_shipping': return Icons.local_shipping;
      case 'computer': return Icons.computer;
      case 'phone_android': return Icons.phone_android;
      case 'checkroom': return Icons.checkroom;
      case 'fastfood': return Icons.fastfood;
      case 'electrical_services': return Icons.electrical_services;
      case 'construction': return Icons.construction;
      case 'spa': return Icons.spa;
      case 'school': return Icons.school;
      case 'local_hospital': return Icons.local_hospital;
      case 'directions_car': return Icons.directions_car;
      default: return Icons.business;
    }
  }

  Color? _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xff')));
    } catch (e) {
      return null;
    }
  }
}
