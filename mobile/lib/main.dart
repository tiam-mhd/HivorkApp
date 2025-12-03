import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hivork_app/core/theme/app_theme_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_notifier.dart';
import 'core/constants/app_constants.dart';
import 'core/router/multi_stream_refresh_notifier.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/dio_client.dart';
import 'core/di/service_locator.dart';
import 'features/auth/data/datasources/auth_api_service.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/phone_entry_page.dart';
import 'features/auth/presentation/pages/verify_otp_page.dart';
import 'features/auth/presentation/pages/login_password_page.dart';
import 'features/auth/presentation/pages/register_details_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/dashboard/presentation/pages/main_dashboard_page.dart';
import 'features/business/presentation/pages/create_business_page.dart';
import 'features/product/presentation/pages/products_page.dart';
import 'features/product/presentation/pages/product_form_page.dart';
import 'features/product/presentation/pages/product_detail_page.dart';
import 'features/product/presentation/pages/attributes_management_page.dart';
import 'features/product/presentation/pages/variants_management_page.dart';
import 'features/product/presentation/pages/stock_report_screen.dart';
import 'features/invoice/data/services/invoice_provider.dart';
import 'features/invoice/data/services/invoice_service.dart';
import 'features/expense/providers/expense_provider.dart';
import 'features/expense/services/expense_api_service.dart';
import 'features/expense/services/expense_category_api_service.dart';
import 'features/expense/providers/recurring_expense_provider.dart';
import 'features/expense/services/recurring_expense_api_service.dart';
import 'features/expense/pages/recurring_expenses_page.dart';
import 'features/expense/pages/expense_categories_page.dart';
import 'features/supplier/data/providers/supplier_provider.dart';
import 'features/supplier/data/services/supplier_api_service.dart';
import 'features/supplier/data/services/contact_api_service.dart';
import 'features/supplier/data/services/supplier_product_api_service.dart';
import 'features/supplier/data/services/document_api_service.dart';
import 'features/supplier/presentation/pages/supplier_list_page.dart';
import 'features/supplier/presentation/pages/supplier_detail_page.dart';
import 'features/supplier/presentation/pages/supplier_form_page.dart';
import 'features/purchase_order/data/providers/purchase_order_provider.dart';
import 'features/purchase_order/data/services/purchase_order_api_service.dart';
import 'features/purchase_order/data/services/payment_api_service.dart';
import 'features/purchase_order/data/services/receipt_api_service.dart';
import 'features/purchase_order/presentation/pages/purchase_order_list_page.dart';
import 'features/purchase_order/presentation/pages/purchase_order_form_page.dart';
import 'features/purchase_order/presentation/pages/purchase_order_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Remove # from URL in web
  usePathUrlStrategy();
  
  // Initialize dependencies
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  // Add logging interceptor for debugging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    requestHeader: true,
    responseHeader: false,
  ));
  
  final secureStorage = const FlutterSecureStorage();
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize AuthLocalDataSource early
  final authLocalDataSource = AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    sharedPreferences: sharedPreferences,
  );
  
  // Add auth interceptor to dio BEFORE initializing ServiceLocator
  dio.interceptors.add(AuthInterceptor(authLocalDataSource));
  
  // Initialize ServiceLocator with dio that has auth interceptor
  ServiceLocator().init(secureStorage, dio);
  
  runApp(HivorkApp(
    dio: dio,
    dioClient: DioClient(secureStorage),
    secureStorage: secureStorage,
    sharedPreferences: sharedPreferences,
  ));
}

class HivorkApp extends StatefulWidget {
  final Dio dio;
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  const HivorkApp({
    super.key,
    required this.dio,
    required this.dioClient,
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  State<HivorkApp> createState() => _HivorkAppState();
}

class _HivorkAppState extends State<HivorkApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  late final ThemeNotifier _themeNotifier;
  bool _minSplashTimeElapsed = false;
  bool _initialAuthCheckDone = false; // پرچم برای اینکه بدونیم اولین چک auth انجام شده
  final _splashTimerController = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    
    // Initialize theme notifier
    _themeNotifier = ThemeNotifier(widget.secureStorage);
    
    // حداقل 3 ثانیه برای splash screen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _minSplashTimeElapsed = true;
        _splashTimerController.add(true);
      }
    });
    
    // Initialize data sources and repositories (AuthLocalDataSource already added to dio)
    final authLocalDataSource = AuthLocalDataSourceImpl(
      secureStorage: widget.secureStorage,
      sharedPreferences: widget.sharedPreferences,
    );
    
    final authApiService = AuthApiService(widget.dio);
    final authRepository = AuthRepositoryImpl(
      apiService: authApiService,
      localDataSource: authLocalDataSource,
    );
    
    // Initialize use cases
    final sendOtpUseCase = SendOtpUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final loginUseCase = LoginUseCase(authRepository);
    final verifyPhoneUseCase = VerifyPhoneUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final getProfileUseCase = GetProfileUseCase(authRepository);
    final isLoggedInUseCase = IsLoggedInUseCase(authRepository);
    
    // Create AuthBloc
    _authBloc = AuthBloc(
      sendOtpUseCase: sendOtpUseCase,
      registerUseCase: registerUseCase,
      loginUseCase: loginUseCase,
      verifyPhoneUseCase: verifyPhoneUseCase,
      logoutUseCase: logoutUseCase,
      getProfileUseCase: getProfileUseCase,
      isLoggedInUseCase: isLoggedInUseCase,
    );
    
    // Check auth status on startup
    _authBloc.add(CheckAuthStatusEvent());
    
    // Configure router with redirect logic
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: MultiStreamRefreshNotifier([
        _authBloc.stream,
        _splashTimerController.stream,
      ]),
      redirect: (context, state) {
        final authState = _authBloc.state;
        final currentLocation = state.matchedLocation;
        
        print('🗺️ [ROUTER] Redirect check: ${authState.runtimeType} -> $currentLocation (initialCheckDone: $_initialAuthCheckDone)');
        
        // فقط به state های authentication-related واکنش نشون بده
        // state هایی مثل AuthOtpSent, AuthError, AuthPhoneVerified نباید redirect رو trigger کنن
        final shouldIgnoreRedirect = authState is! AuthInitial &&
                                     authState is! AuthLoading &&
                                     authState is! AuthAuthenticated &&
                                     authState is! AuthUnauthenticated &&
                                     authState is! AuthRegistrationSuccess;
        
        if (shouldIgnoreRedirect && currentLocation != '/splash') {
          print('⏭️ [ROUTER] Ignoring redirect for ${authState.runtimeType}');
          return null;
        }
        
        // اگر هنوز در حال چک کردن auth هستیم و توی splash هستیم، بمانیم
        // ولی فقط برای اولین بار! بعد از اون AuthLoading نباید بره splash
        if ((authState is AuthInitial || (authState is AuthLoading && !_initialAuthCheckDone))) {
          if (currentLocation != '/splash') {
            print('⏳ [ROUTER] Initial auth check, go to splash');
            return '/splash';
          }
          return null;
        }
        
        // اگر auth check اولیه تمام شد، پرچم رو set کن
        if ((authState is AuthAuthenticated || authState is AuthUnauthenticated) && !_initialAuthCheckDone) {
          _initialAuthCheckDone = true;
          print('✓ [ROUTER] Initial auth check completed');
        }
        
        // اگر در splash هستیم و auth check تمام شده، اما 3 ثانیه نگذشته، بمانیم
        if (currentLocation == '/splash' && !_minSplashTimeElapsed) {
          print('⏳ [ROUTER] Minimum splash time not elapsed yet');
          return null;
        }
        
        // اگر در splash هستیم و هم auth تمام شده و هم 3 ثانیه گذشته، به مقصد نهایی برویم
        if (currentLocation == '/splash') {
          if (authState is AuthAuthenticated || authState is AuthRegistrationSuccess) {
            print('✅ [ROUTER] Auth complete, redirecting to dashboard');
            return '/dashboard';
          } else {
            print('❌ [ROUTER] Not authenticated, redirecting to phone-entry');
            return '/phone-entry';
          }
        }
        
        // قوانین معمولی redirect
        if ((authState is AuthAuthenticated || authState is AuthRegistrationSuccess) && 
            currentLocation == '/phone-entry') {
          print('✅ [ROUTER] Already authenticated, redirecting to dashboard');
          return '/dashboard';
        }
        
        if (authState is AuthUnauthenticated && currentLocation == '/dashboard') {
          print('❌ [ROUTER] Not authenticated, redirecting to phone-entry');
          return '/phone-entry';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/phone-entry',
          builder: (context, state) => const PhoneEntryPage(),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return VerifyOtpPage(
              phone: extra['phone'] as String,
              exists: extra['exists'] as bool,
              isForgotPassword: extra['isForgotPassword'] as bool? ?? false,
            );
          },
        ),
        GoRoute(
          path: '/login-password',
          builder: (context, state) {
            final phone = state.extra as String;
            return LoginPasswordPage(phone: phone);
          },
        ),
        GoRoute(
          path: '/register-details',
          builder: (context, state) {
            final phone = state.extra as String;
            return RegisterDetailsPage(phone: phone);
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) {
            final extra = state.extra;
            String phone;
            
            // extra میتونه String باشه یا Map
            if (extra is Map<String, dynamic>) {
              phone = extra['phone'] as String;
            } else if (extra is String) {
              phone = extra;
            } else {
              phone = ''; // fallback
            }
            
            return ResetPasswordPage(phone: phone);
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const MainDashboardPage(),
        ),
        GoRoute(
          path: '/suppliers',
          builder: (context, state) {
            final businessId = state.extra as String? ?? '';
            print('🔥 ROUTE DEBUG: businessId from extra = "$businessId"');
            return SupplierListPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/supplier/create',
          builder: (context, state) {
            final businessId = state.extra as String? ?? '';
            return SupplierFormPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/supplier/:id',
          builder: (context, state) {
            final supplierId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, String>? ?? {};
            final businessId = extra['businessId'] ?? '';
            return SupplierDetailPage(
              supplierId: supplierId,
              businessId: businessId,
            );
          },
        ),
        // Purchase Order Routes
        GoRoute(
          path: '/purchase-orders',
          builder: (context, state) {
            final businessId = state.extra as String? ?? '';
            return PurchaseOrderListPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/purchase-order/create',
          builder: (context, state) {
            final businessId = state.extra as String? ?? '';
            return PurchaseOrderFormPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/purchase-order/:id',
          builder: (context, state) {
            final orderId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, String>? ?? {};
            final businessId = extra['businessId'] ?? '';
            return PurchaseOrderDetailPage(
              purchaseOrderId: orderId,
              businessId: businessId,
            );
          },
        ),
        GoRoute(
          path: '/purchase-order/:id/edit',
          builder: (context, state) {
            final orderId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, String>? ?? {};
            final businessId = extra['businessId'] ?? '';
            return PurchaseOrderFormPage(
              businessId: businessId,
              purchaseOrderId: orderId,
            );
          },
        ),
        GoRoute(
          path: '/create-business',
          builder: (context, state) => const CreateBusinessPage(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) {
            final businessId = state.uri.queryParameters['businessId'] ?? '';
            return ProductsPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/product/create',
          builder: (context, state) {
            final businessId = state.uri.queryParameters['businessId'] ?? '';
            return ProductFormPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/product/edit/:id',
          builder: (context, state) {
            final businessId = state.uri.queryParameters['businessId'] ?? '';
            // TODO: Load product by ID and pass to form
            return ProductFormPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: '/attributes',
          builder: (context, state) {
            final businessId = state.uri.queryParameters['businessId'] ?? '';
            return AttributesManagementPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/variants',
          builder: (context, state) {
            final productId = state.uri.queryParameters['productId'] ?? '';
            final productName = state.uri.queryParameters['productName'] ?? 'محصول';
            final businessId = state.uri.queryParameters['businessId'] ?? '';
            return VariantsManagementPage(
              productId: productId,
              productName: productName,
              businessId: businessId,
            );
          },
        ),
        GoRoute(
          path: '/stock-report',
          builder: (context, state) {
            final businessId = state.uri.queryParameters['businessId'] ?? '';
            return StockReportScreen(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/expenses/recurring',
          builder: (context, state) {
            final businessId = state.extra as String? ?? '';
            return RecurringExpensesPage(businessId: businessId);
          },
        ),
        GoRoute(
          path: '/expenses/categories',
          builder: (context, state) {
            final businessId = state.extra as String? ?? '';
            return ExpenseCategoriesPage(businessId: businessId);
          },
        ),
      ],
    );
    
    // Check auth status on startup
    _authBloc.add(CheckAuthStatusEvent());
  }

  @override
  void dispose() {
    _splashTimerController.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeNotifier),
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider(
            InvoiceService(widget.dio),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            ExpenseApiService(widget.dio),
            ExpenseCategoryApiService(widget.dio),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RecurringExpenseProvider(
            RecurringExpenseApiService(widget.dio),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SupplierProvider(
            SupplierApiService(widget.dio),
            ContactApiService(widget.dio),
            SupplierProductApiService(widget.dio),
            DocumentApiService(widget.dio),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchaseOrderProvider(
            PurchaseOrderApiService(widget.dio),
            PaymentApiService(widget.dio),
            ReceiptApiService(widget.dio),
          ),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return BlocProvider.value(
            value: _authBloc,
            child: MaterialApp.router(
              title: 'هایورک',
              debugShowCheckedModeBanner: false,
              
              // Theme - Controlled by ThemeNotifier
              theme: AppThemeV2.lightTheme,
              darkTheme: AppThemeV2.darkTheme,
              themeMode: themeNotifier.themeMode,
              
              // Localization
              locale: const Locale('fa', 'IR'),
              supportedLocales: const [
                Locale('fa', 'IR'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              
              // Router
              routerConfig: _router,
            ),
          );
        },
      ),
    );
  }
}
