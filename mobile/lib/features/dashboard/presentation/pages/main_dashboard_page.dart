import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../business/data/datasources/business_api_service.dart';
import '../../../business/data/models/business_model.dart';
import '../../../../core/di/service_locator.dart';
import '../widgets/no_business_widget.dart';
import '../../../product/presentation/pages/products_page.dart';
import 'home_tab_page.dart';
import 'customers_tab_page.dart';
import 'invoices_tab_page.dart';
import 'expenses_tab_page.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  late final BusinessApiService _businessApi;
  late final FlutterSecureStorage _storage;
  List<Business> _businesses = [];
  Business? _activeBusiness;
  bool _isLoadingBusinesses = true;
  bool _isBusinessListExpanded = false;
  
  static const String _activeBusinessIdKey = 'active_business_id';
  
  List<Widget> _getTabPages() {
    return [
      HomeTabPage(activeBusiness: _activeBusiness),
      _activeBusiness != null 
          ? ProductsPage(businessId: _activeBusiness!.id)
          : Center(child: Text('لطفاً کسب‌وکار را انتخاب کنید')),
      _activeBusiness != null
          ? CustomersTabPage(businessId: _activeBusiness!.id)
          : Center(child: Text('لطفاً کسب‌وکار را انتخاب کنید')),
      const InvoicesTabPage(),
      const ExpensesTabPage(),
    ];
  }

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'خانه'},
    {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'label': 'محصولات'},
    {'icon': Icons.people_outline, 'activeIcon': Icons.people, 'label': 'مشتریان'},
    {'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long, 'label': 'فاکتورها'},
    {'icon': Icons.attach_money_outlined, 'activeIcon': Icons.attach_money, 'label': 'هزینه‌ها'},
  ];

  @override
  void initState() {
    super.initState();
    _businessApi = BusinessApiService(ServiceLocator().dio);
    _storage = ServiceLocator().secureStorage;
    _loadBusinesses();
    
    // گوش دادن به تغییرات route برای رفرش کردن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForReload();
    });
  }
  
  void _checkForReload() {
    // هر بار که به dashboard برمی‌گردیم، لیست را رفرش می‌کنیم
    final router = GoRouter.of(context);
    router.routerDelegate.addListener(_onRouteChanged);
  }
  
  void _onRouteChanged() {
    // اگر در مسیر dashboard هستیم، رفرش کنیم
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    if (location == '/dashboard' && mounted) {
      _loadBusinesses();
    }
  }
  
  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    try {
      setState(() {
        _isLoadingBusinesses = true;
      });
      
      final businesses = await _businessApi.getMyBusinesses();
      
      // بازیابی آخرین کسب و کار فعال از حافظه
      Business? selectedBusiness;
      final savedBusinessId = await _storage.read(key: _activeBusinessIdKey);
      
      if (savedBusinessId != null && businesses.isNotEmpty) {
        selectedBusiness = businesses.firstWhere(
          (b) => b.id == savedBusinessId,
          orElse: () => businesses.first,
        );
      } else if (businesses.isNotEmpty) {
        selectedBusiness = businesses.first;
      }
      
      setState(() {
        _businesses = businesses;
        _activeBusiness = selectedBusiness;
        _isLoadingBusinesses = false;
      });
    } catch (e) {
      print('❌ Error loading businesses: $e');
      setState(() {
        _isLoadingBusinesses = false;
      });
    }
  }
  
  Future<void> _switchActiveBusiness(Business business) async {
    setState(() {
      _activeBusiness = business;
      _isBusinessListExpanded = false;
    });
    
    // ذخیره کسب و کار فعال در حافظه
    await _storage.write(key: _activeBusinessIdKey, value: business.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      
      // App Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/branding/Logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'هایورک',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Drawer (Side Menu)
      drawer: _buildDrawer(),

      // Body
      body: SafeArea(
        child: _isLoadingBusinesses
            ? const Center(child: CircularProgressIndicator())
            : _activeBusiness != null
                ? Column(
                    children: [
                      // Tab Content
                      Expanded(
                        child: _getTabPages()[_currentIndex],
                      ),
                    ],
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: const NoBusinessWidget(),
                    ),
                  ),
      ),

      // Bottom Navigation Bar - فقط وقتی کسب و کار داریم
      bottomNavigationBar: _activeBusiness != null
          ? Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_navItems.length, (index) {
                      final item = _navItems[index];
                      final isActive = _currentIndex == index;
                      
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isActive ? item['activeIcon'] : item['icon'],
                                  color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDrawer() {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    String userName = 'کاربر';
    String userPhone = '';
    
    if (authState is AuthAuthenticated) {
      userName = authState.user.fullName ?? 'کاربر';
      userPhone = authState.user.phone;
    }
    
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // User Info Section - Minimal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userPhone,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Active Business Section
            if (_activeBusiness != null) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Label
                    Padding(
                      padding: const EdgeInsets.only(right: 4, left: 4, bottom: 8),
                      child: Text(
                        'کسب و کار',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    // Business Card
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Main Business Info + Actions
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isBusinessListExpanded = !_isBusinessListExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Logo
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      color: theme.colorScheme.onPrimary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _activeBusiness!.name,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (_activeBusiness!.category != null) ...[
                                              Text(
                                                _activeBusiness!.category!.name,
                                                style: TextStyle(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (_activeBusiness!.industry != null) ...[
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ],
                                            if (_activeBusiness!.industry != null)
                                              Flexible(
                                                child: Text(
                                                  _activeBusiness!.industry!.name,
                                                  style: TextStyle(
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // Navigate to edit
                                        },
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                      if (_businesses.length > 1)
                                        Icon(
                                          _isBusinessListExpanded
                                              ? Icons.expand_less_rounded
                                              : Icons.expand_more_rounded,
                                          size: 20,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        )
                                      else
                                        Icon(
                                          _isBusinessListExpanded
                                              ? Icons.expand_less_rounded
                                              : Icons.expand_more_rounded,
                                          size: 20,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Business List (Expandable)
                          if (_isBusinessListExpanded)
                            Column(
                              children: [
                                // Other Businesses
                                if (_businesses.length > 1)
                                  ..._businesses.where((b) => b.id != _activeBusiness!.id).map((business) {
                                    return InkWell(
                                      onTap: () {
                                        _switchActiveBusiness(business);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: theme.colorScheme.outline.withOpacity(0.08),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.surface,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.storefront_outlined,
                                                size: 18,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    business.name,
                                                    style: TextStyle(
                                                      color: theme.colorScheme.onSurface,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (business.category != null || business.industry != null)
                                                    Text(
                                                      [
                                                        if (business.category != null) business.category!.name,
                                                        if (business.industry != null) business.industry!.name,
                                                      ].join(' • '),
                                                      style: TextStyle(
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                
                                // Add New Business Button
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push('/create-business');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                      border: Border(
                                        top: BorderSide(
                                          color: theme.colorScheme.outline.withOpacity(0.08),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'افزودن کسب و کار جدید',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 8),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'داشبورد',
                    isActive: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'تنظیمات',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_rounded,
                    title: 'راهنما',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_rounded,
                    title: 'درباره ما',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to about
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Container(
              margin: const EdgeInsets.all(16),
              child: _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'خروج از حساب',
                isLogout: true,
                onTap: () {
                  Navigator.pop(context);
                  
                  // نمایش دیالوگ تایید
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'خروج از حساب',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'آیا مطمئن هستید که می‌خواهید از حساب کاربری خود خارج شوید؟',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'انصراف',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<AuthBloc>().add(LogoutEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('خروج'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? theme.colorScheme.primary.withOpacity(0.1)
            : isLogout
                ? theme.colorScheme.error.withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withOpacity(0.15)
                : isLogout
                    ? theme.colorScheme.error.withOpacity(0.15)
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isActive
                ? theme.colorScheme.primary
                : isLogout
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.primary
                : isLogout
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: isActive
            ? Icon(
                Icons.chevron_left_rounded,
                color: theme.colorScheme.primary,
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
