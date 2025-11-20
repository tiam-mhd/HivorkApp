import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_group.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/services/customer_group_api_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../bloc/customer_bloc.dart';
import 'customer_form_page.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;
  final String businessId;

  const CustomerDetailPage({
    Key? key,
    required this.customerId,
    required this.businessId,
  }) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  Customer? _customer;
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCustomer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    try {
      final dio = ServiceLocator().dio;
      final apiService = CustomerApiService(dio);
      final customer = await apiService.getCustomerById(widget.customerId);
      setState(() {
        _customer = customer;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دریافت اطلاعات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(double value) {
    final formatter = intl.NumberFormat('#,###', 'fa_IR');
    return '${formatter.format(value)} تومان';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return intl.DateFormat('yyyy/MM/dd', 'fa_IR').format(date);
  }

  Color _getStatusColor(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return Colors.green;
      case CustomerStatus.inactive:
        return Colors.orange;
      case CustomerStatus.blocked:
        return Colors.red;
    }
  }

  String _getStatusText(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return 'فعال';
      case CustomerStatus.inactive:
        return 'غیرفعال';
      case CustomerStatus.blocked:
        return 'مسدود';
    }
  }

  Future<void> _makePhoneCall() async {
    if (_customer?.phone == null) return;
    
    try {
      // در Flutter برای باز کردن اپلیکیشن تلفن از Intent استفاده می‌شود
      // که در Android/iOS به صورت خودکار کار می‌کند
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('در حال تماس با ${_customer!.phone}...')),
        );
      }
      // در نسخه production باید از url_launcher استفاده شود
      // final phoneNumber = _customer!.phone!.replaceAll(RegExp(r'\s+'), '');
      // final uri = Uri.parse('tel:$phoneNumber');
      // await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری تماس: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    if (_customer?.email == null) return;
    
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('در حال باز کردن برنامه ایمیل...')),
        );
      }
      // در نسخه production باید از url_launcher استفاده شود
      // final emailUri = Uri.parse('mailto:${_customer!.email}');
      // await launchUrl(emailUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ارسال ایمیل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditForm() async {
    if (_customer == null) return;
    
    final dio = ServiceLocator().dio;
    final customerApiService = CustomerApiService(dio);
    final customerRepository = CustomerRepository(customerApiService);
    
    // دریافت لیست گروه‌ها برای فرم ویرایش
    List<CustomerGroup>? groups;
    try {
      final groupApiService = CustomerGroupApiService(dio);
      groups = await groupApiService.getGroups(widget.businessId);
    } catch (e) {
      print('خطا در دریافت گروه‌ها: $e');
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => CustomerBloc(customerRepository),
          child: CustomerFormPage(
            businessId: widget.businessId,
            customer: _customer,
            groups: groups,
          ),
        ),
      ),
    );
    
    // اگر ویرایش موفق بود، دوباره اطلاعات را بارگذاری کن
    if (result == true) {
      await _loadCustomer();
      // نیازی به بستن صفحه جزئیات نیست، فقط اطلاعات را بروز کن
    }
  }

  Future<void> _deleteCustomer() async {
    try {
      final dio = ServiceLocator().dio;
      final apiService = CustomerApiService(dio);
      await apiService.deleteCustomer(widget.customerId);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مشتری با موفقیت حذف شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در حذف مشتری: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _customer == null
              ? _buildErrorState()
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(colorScheme),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildHeader(theme, colorScheme),
                          _buildFinancialSummary(theme, colorScheme),
                          _buildTabBar(theme),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInfoTab(theme),
                          _buildTransactionsTab(theme),
                          _buildStatisticsTab(theme, colorScheme),
                          _buildNotesTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'مشتری یافت نشد',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('بازگشت'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 60,
      collapsedHeight: 56,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined),
          onPressed: _customer!.phone != null ? _makePhoneCall : null,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: _navigateToEditForm,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'email':
                if (_customer!.email != null) {
                  _sendEmail();
                }
                break;
              case 'delete':
                _showDeleteDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            if (_customer!.email != null)
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('ارسال ایمیل'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('حذف مشتری', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _customer!.avatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            _customer!.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              _customer!.isCompany
                                  ? Icons.business_rounded
                                  : Icons.person_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          _customer!.isCompany
                              ? Icons.business_rounded
                              : Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 16),
                // Name and Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer!.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _customer!.customerCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_customer!.status)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(_customer!.status)
                                .withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getStatusColor(_customer!.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(_customer!.status),
                              style: TextStyle(
                                color: _getStatusColor(_customer!.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 18,
                  color: _customer!.groupColor != null
                      ? Color(
                          int.parse(
                            _customer!.groupColor!
                                .replaceFirst('#', '0xFF'),
                          ),
                        )
                      : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'گروه:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _customer!.groupDisplayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _customer!.groupColor != null
                        ? Color(
                            int.parse(
                              _customer!.groupColor!
                                  .replaceFirst('#', '0xFF'),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFinancialCard(
              icon: Icons.account_balance_wallet,
              label: 'موجودی فعلی',
              value: _formatCurrency(_customer!.currentBalance),
              color: _customer!.currentBalance >= 0
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFinancialCard(
              icon: Icons.shopping_cart,
              label: 'مجموع خرید',
              value: _formatCurrency(_customer!.totalPurchases),
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: isDark ? Colors.white : Colors.white,
        unselectedLabelColor: isDark 
            ? theme.colorScheme.onSurface.withOpacity(0.7)
            : theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'اطلاعات'),
          Tab(text: 'تراکنش‌ها'),
          Tab(text: 'آمار'),
          Tab(text: 'یادداشت'),
        ],
      ),
    );
  }

  Widget _buildInfoTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoSection(
          title: 'اطلاعات تماس',
          icon: Icons.contact_phone,
          items: [
            if (_customer!.phone != null)
              _buildInfoItem(
                icon: Icons.phone,
                label: 'تلفن',
                value: _customer!.phone!,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _customer!.phone!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شماره تلفن کپی شد')),
                  );
                },
              ),
            if (_customer!.email != null)
              _buildInfoItem(
                icon: Icons.email,
                label: 'ایمیل',
                value: _customer!.email!,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _customer!.email!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ایمیل کپی شد')),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_customer!.isCompany) ...[
          _buildInfoSection(
            title: 'اطلاعات شرکت',
            icon: Icons.business,
            items: [
              if (_customer!.companyName != null)
                _buildInfoItem(
                  icon: Icons.business_center,
                  label: 'نام شرکت',
                  value: _customer!.companyName!,
                ),
              if (_customer!.registrationNumber != null)
                _buildInfoItem(
                  icon: Icons.numbers,
                  label: 'شماره ثبت',
                  value: _customer!.registrationNumber!,
                ),
              if (_customer!.economicCode != null)
                _buildInfoItem(
                  icon: Icons.code,
                  label: 'کد اقتصادی',
                  value: _customer!.economicCode!,
                ),
              if (_customer!.contactPerson != null)
                _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'شخص رابط',
                  value: _customer!.contactPerson!,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (_customer!.address != null ||
            _customer!.city != null ||
            _customer!.province != null) ...[
          _buildInfoSection(
            title: 'آدرس',
            icon: Icons.location_on,
            items: [
              if (_customer!.address != null)
                _buildInfoItem(
                  icon: Icons.home,
                  label: 'آدرس',
                  value: _customer!.address!,
                ),
              if (_customer!.city != null)
                _buildInfoItem(
                  icon: Icons.location_city,
                  label: 'شهر',
                  value: _customer!.city!,
                ),
              if (_customer!.province != null)
                _buildInfoItem(
                  icon: Icons.map,
                  label: 'استان',
                  value: _customer!.province!,
                ),
              if (_customer!.postalCode != null)
                _buildInfoItem(
                  icon: Icons.markunread_mailbox,
                  label: 'کد پستی',
                  value: _customer!.postalCode!,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildInfoSection(
          title: 'اطلاعات مالی',
          icon: Icons.account_balance,
          items: [
            _buildInfoItem(
              icon: Icons.credit_card,
              label: 'سقف اعتبار',
              value: _formatCurrency(_customer!.creditLimit),
            ),
            _buildInfoItem(
              icon: Icons.calendar_today,
              label: 'مهلت پرداخت',
              value: '${_customer!.paymentTermDays} روز',
            ),
            _buildInfoItem(
              icon: Icons.discount,
              label: 'درصد تخفیف',
              value: '${_customer!.discountRate}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoSection(
          title: 'اطلاعات اضافی',
          icon: Icons.info_outline,
          items: [
            if (_customer!.nationalId != null)
              _buildInfoItem(
                icon: Icons.badge,
                label: 'کد ملی',
                value: _customer!.nationalId!,
              ),
            if (_customer!.birthDate != null)
              _buildInfoItem(
                icon: Icons.cake,
                label: 'تاریخ تولد',
                value: _formatDate(_customer!.birthDate),
              ),
            _buildInfoItem(
              icon: Icons.calendar_month,
              label: 'تاریخ ثبت',
              value: _formatDate(_customer!.createdAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.copy, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'تراکنش‌ها به زودی',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          icon: Icons.shopping_bag,
          title: 'تعداد سفارشات',
          value: '${_customer!.totalOrders}',
          color: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.attach_money,
          title: 'مجموع خرید',
          value: _formatCurrency(_customer!.totalPurchases),
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.payment,
          title: 'مجموع پرداخت‌ها',
          value: _formatCurrency(_customer!.totalPayments),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.event,
          title: 'آخرین سفارش',
          value: _formatDate(_customer!.lastOrderDate),
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.calendar_today,
          title: 'آخرین پرداخت',
          value: _formatDate(_customer!.lastPaymentDate),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_alt),
                      const SizedBox(width: 12),
                      const Text(
                        'یادداشت‌ها',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Edit notes
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    _customer!.notes ?? 'یادداشتی ثبت نشده است',
                    style: TextStyle(
                      fontSize: 14,
                      color: _customer!.notes != null
                          ? Colors.black87
                          : Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_customer!.tags != null && _customer!.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'برچسب‌ها',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customer!.tags!
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      avatar: const Icon(Icons.label, size: 16),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مشتری'),
        content: Text('آیا از حذف ${_customer!.displayName} اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCustomer();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
