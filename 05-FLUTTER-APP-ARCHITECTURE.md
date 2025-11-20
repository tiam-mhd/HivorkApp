# 📱 معماری اپلیکیشن Flutter - Hivork Super App

## 🏗️ نمای کلی معماری

### Technology Stack
```
Framework: Flutter 3.16+
Language: Dart 3.2+
State Management: Riverpod 2.4+
Routing: Go Router 12+
HTTP Client: Dio 5.4+
Local Storage: Hive + Shared Preferences
Secure Storage: Flutter Secure Storage
Code Generation: Freezed + JSON Serializable
Dependency Injection: Riverpod
UI Components: Custom Design System
```

### معماری کلی: Clean Architecture + Feature-First

```
lib/
├── main.dart
├── app.dart
├── core/                           # هسته مشترک اپلیکیشن
│   ├── config/                    # تنظیمات و کانفیگ‌ها
│   │   ├── app_config.dart
│   │   ├── environment.dart
│   │   └── route_config.dart
│   ├── constants/                 # ثابت‌های اپلیکیشن
│   │   ├── api_constants.dart
│   │   ├── app_constants.dart
│   │   ├── asset_constants.dart
│   │   └── storage_keys.dart
│   ├── theme/                     # تم و استایل
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_shadows.dart
│   │   └── app_dimensions.dart
│   ├── network/                   # شبکه و API
│   │   ├── dio_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── error_interceptor.dart
│   │   └── api_response.dart
│   ├── storage/                   # ذخیره‌سازی محلی
│   │   ├── local_storage.dart
│   │   ├── secure_storage.dart
│   │   └── cache_manager.dart
│   ├── error/                     # مدیریت خطا
│   │   ├── failures.dart
│   │   ├── exceptions.dart
│   │   └── error_handler.dart
│   ├── utils/                     # ابزارهای کمکی
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   ├── string_utils.dart
│   │   └── pdf_generator.dart
│   └── extensions/                # Extension ها
│       ├── context_extensions.dart
│       ├── string_extensions.dart
│       ├── num_extensions.dart
│       └── date_extensions.dart
│
├── shared/                        # کامپوننت‌های مشترک
│   ├── widgets/                   # ویجت‌های قابل استفاده مجدد
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   ├── icon_button.dart
│   │   │   └── text_button.dart
│   │   ├── inputs/
│   │   │   ├── text_field.dart
│   │   │   ├── search_field.dart
│   │   │   ├── dropdown.dart
│   │   │   ├── date_picker.dart
│   │   │   └── image_picker.dart
│   │   ├── cards/
│   │   │   ├── base_card.dart
│   │   │   ├── product_card.dart
│   │   │   ├── customer_card.dart
│   │   │   └── invoice_card.dart
│   │   ├── dialogs/
│   │   │   ├── confirmation_dialog.dart
│   │   │   ├── bottom_sheet.dart
│   │   │   └── loading_dialog.dart
│   │   ├── loaders/
│   │   │   ├── shimmer_loader.dart
│   │   │   ├── circular_loader.dart
│   │   │   └── skeleton_loader.dart
│   │   ├── empty_states/
│   │   │   ├── empty_state.dart
│   │   │   └── error_state.dart
│   │   ├── lists/
│   │   │   ├── infinite_list.dart
│   │   │   └── refresh_list.dart
│   │   └── common/
│   │       ├── app_bar.dart
│   │       ├── bottom_nav.dart
│   │       ├── badge.dart
│   │       ├── chip.dart
│   │       └── avatar.dart
│   ├── providers/                 # Provider های مشترک
│   │   ├── auth_provider.dart
│   │   ├── current_business_provider.dart
│   │   └── connectivity_provider.dart
│   └── models/                    # مدل‌های مشترک
│       ├── paginated_response.dart
│       ├── api_error.dart
│       └── user.dart
│
├── features/                      # ماژول‌های اصلی (Feature-First)
│   │
│   ├── auth/                      # 🔐 احراز هویت
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── login_request.dart
│   │   │   │   ├── register_request.dart
│   │   │   │   └── auth_response.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── verify_phone_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── verify_phone_screen.dart
│   │       │   └── forgot_password_screen.dart
│   │       └── widgets/
│   │           ├── phone_input.dart
│   │           └── otp_input.dart
│   │
│   ├── onboarding/                # 🎯 آنبوردینگ
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── intro_screen.dart
│   │       │   └── welcome_screen.dart
│   │       └── widgets/
│   │           └── intro_page.dart
│   │
│   ├── business/                  # 🏢 مدیریت کسب‌وکار
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── business_model.dart
│   │   │   │   ├── business_category_model.dart
│   │   │   │   └── business_stats_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── business_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── business_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── business_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── business_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_businesses_usecase.dart
│   │   │       ├── create_business_usecase.dart
│   │   │       ├── update_business_usecase.dart
│   │   │       └── switch_business_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── business_list_provider.dart
│   │       │   └── current_business_provider.dart
│   │       ├── screens/
│   │       │   ├── business_list_screen.dart
│   │       │   ├── business_detail_screen.dart
│   │       │   ├── create_business_screen.dart
│   │       │   └── business_settings_screen.dart
│   │       └── widgets/
│   │           ├── business_card.dart
│   │           ├── business_switcher.dart
│   │           └── business_form.dart
│   │
│   ├── dashboard/                 # 📊 داشبورد اصلی
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── dashboard_stats_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── dashboard_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── dashboard_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── dashboard_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_dashboard_data_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── stats_card.dart
│   │           ├── sales_chart.dart
│   │           ├── recent_orders.dart
│   │           ├── top_products.dart
│   │           └── quick_actions.dart
│   │
│   ├── products/                  # 📦 مدیریت محصولات
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart
│   │   │   │   ├── product_category_model.dart
│   │   │   │   ├── product_variant_model.dart
│   │   │   │   └── inventory_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── product_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── product_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_products_usecase.dart
│   │   │       ├── create_product_usecase.dart
│   │   │       ├── update_product_usecase.dart
│   │   │       ├── delete_product_usecase.dart
│   │   │       └── adjust_inventory_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── product_list_provider.dart
│   │       │   ├── product_detail_provider.dart
│   │       │   └── product_form_provider.dart
│   │       ├── screens/
│   │       │   ├── product_list_screen.dart
│   │       │   ├── product_detail_screen.dart
│   │       │   ├── create_product_screen.dart
│   │       │   ├── edit_product_screen.dart
│   │       │   └── inventory_management_screen.dart
│   │       └── widgets/
│   │           ├── product_card.dart
│   │           ├── product_form.dart
│   │           ├── product_image_picker.dart
│   │           ├── product_variant_list.dart
│   │           ├── inventory_adjuster.dart
│   │           └── product_filter.dart
│   │
│   ├── customers/                 # 👥 مدیریت مشتریان
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── customer_model.dart
│   │   │   │   ├── customer_address_model.dart
│   │   │   │   └── customer_stats_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── customer_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── customer_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_customers_usecase.dart
│   │   │       ├── create_customer_usecase.dart
│   │   │       ├── update_customer_usecase.dart
│   │   │       └── delete_customer_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── customer_list_provider.dart
│   │       │   └── customer_detail_provider.dart
│   │       ├── screens/
│   │       │   ├── customer_list_screen.dart
│   │       │   ├── customer_detail_screen.dart
│   │       │   ├── create_customer_screen.dart
│   │       │   └── edit_customer_screen.dart
│   │       └── widgets/
│   │           ├── customer_card.dart
│   │           ├── customer_form.dart
│   │           ├── customer_address_list.dart
│   │           └── customer_stats.dart
│   │
│   ├── invoices/                  # 🧾 فاکتورها و فروش
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── invoice_model.dart
│   │   │   │   ├── invoice_item_model.dart
│   │   │   │   └── payment_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── invoice_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── invoice_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── invoice_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── invoice_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_invoices_usecase.dart
│   │   │       ├── create_invoice_usecase.dart
│   │   │       ├── update_invoice_usecase.dart
│   │   │       ├── confirm_invoice_usecase.dart
│   │   │       ├── cancel_invoice_usecase.dart
│   │   │       ├── generate_pdf_usecase.dart
│   │   │       └── add_payment_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── invoice_list_provider.dart
│   │       │   ├── invoice_detail_provider.dart
│   │       │   └── invoice_form_provider.dart
│   │       ├── screens/
│   │       │   ├── invoice_list_screen.dart
│   │       │   ├── invoice_detail_screen.dart
│   │       │   ├── create_invoice_screen.dart
│   │       │   ├── edit_invoice_screen.dart
│   │       │   └── invoice_preview_screen.dart
│   │       └── widgets/
│   │           ├── invoice_card.dart
│   │           ├── invoice_form.dart
│   │           ├── invoice_item_picker.dart
│   │           ├── invoice_summary.dart
│   │           ├── payment_form.dart
│   │           └── invoice_status_badge.dart
│   │
│   ├── expenses/                  # 💸 مدیریت هزینه‌ها
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── expense_model.dart
│   │   │   │   └── expense_category_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── expense_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── expense_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── expense_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── expense_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_expenses_usecase.dart
│   │   │       ├── create_expense_usecase.dart
│   │   │       ├── update_expense_usecase.dart
│   │   │       └── delete_expense_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── expense_provider.dart
│   │       ├── screens/
│   │       │   ├── expense_list_screen.dart
│   │       │   ├── create_expense_screen.dart
│   │       │   └── expense_categories_screen.dart
│   │       └── widgets/
│   │           ├── expense_card.dart
│   │           ├── expense_form.dart
│   │           └── expense_chart.dart
│   │
│   ├── analytics/                 # 📈 آنالیتیکس و گزارش‌ها
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── sales_report_model.dart
│   │   │   │   ├── profit_loss_model.dart
│   │   │   │   └── inventory_report_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── analytics_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── analytics_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── report_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── analytics_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_sales_report_usecase.dart
│   │   │       ├── get_profit_loss_usecase.dart
│   │   │       └── get_recommendations_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── analytics_provider.dart
│   │       ├── screens/
│   │       │   ├── analytics_screen.dart
│   │       │   ├── sales_report_screen.dart
│   │       │   ├── profit_loss_screen.dart
│   │       │   └── inventory_report_screen.dart
│   │       └── widgets/
│   │           ├── chart_widgets.dart
│   │           ├── report_filter.dart
│   │           └── recommendation_card.dart
│   │
│   ├── notifications/             # 🔔 نوتیفیکیشن‌ها
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── notification_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── notification_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── notification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── notification_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── notification_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_notifications_usecase.dart
│   │   │       └── mark_as_read_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── notification_provider.dart
│   │       ├── screens/
│   │       │   └── notifications_screen.dart
│   │       └── widgets/
│   │           └── notification_item.dart
│   │
│   ├── profile/                   # 👤 پروفایل کاربر
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── profile_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_profile_usecase.dart
│   │   │       ├── update_profile_usecase.dart
│   │   │       └── change_password_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       ├── screens/
│   │       │   ├── profile_screen.dart
│   │       │   ├── edit_profile_screen.dart
│   │       │   ├── change_password_screen.dart
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           ├── profile_header.dart
│   │           └── settings_item.dart
│   │
│   └── settings/                  # ⚙️ تنظیمات
│       └── presentation/
│           ├── screens/
│           │   ├── settings_screen.dart
│           │   ├── language_screen.dart
│           │   ├── theme_screen.dart
│           │   └── about_screen.dart
│           └── widgets/
│               └── setting_item.dart
│
└── l10n/                          # 🌐 چندزبانگی
    ├── app_fa.arb                # فارسی
    └── app_en.arb                # انگلیسی
```

---

## 🔧 تنظیمات اولیه

### pubspec.yaml

```yaml
name: hivork
description: Hivork Business Management App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Routing
  go_router: ^12.1.3
  
  # Network
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9
  lottie: ^2.7.0
  animations: ^2.0.11
  flutter_staggered_animations: ^1.1.1
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Date & Time
  intl: ^0.19.0
  persian_datetime_picker: ^2.6.0
  shamsi_date: ^1.0.1
  
  # Image
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
  
  # PDF
  pdf: ^3.10.7
  printing: ^5.12.0
  
  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5
  
  # Charts
  fl_chart: ^0.66.0
  syncfusion_flutter_charts: ^24.1.41
  
  # Utils
  equatable: ^2.0.5
  dartz: ^0.10.1
  logger: ^2.0.2+1
  connectivity_plus: ^5.0.2
  url_launcher: ^6.2.3
  share_plus: ^7.2.1
  path_provider: ^2.1.2
  package_info_plus: ^5.0.1
  device_info_plus: ^9.1.1
  
  # Firebase (اختیاری)
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^3.0.1
  
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  retrofit_generator: ^8.0.6
  hive_generator: ^2.0.1
  
  # Testing
  mocktail: ^1.0.2
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/fonts/
  
  fonts:
    - family: Vazir
      fonts:
        - asset: assets/fonts/Vazir-Regular.ttf
        - asset: assets/fonts/Vazir-Bold.ttf
          weight: 700
```

---

## 🎨 Design System

### app_theme.dart

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      textTheme: AppTextStyles.textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
  
  static ThemeData darkTheme() {
    // پیاده‌سازی تم تاریک
    return ThemeData.dark();
  }
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4BC7);
  static const Color primaryLight = Color(0xFF8C7CEF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00B894);
  static const Color secondaryDark = Color(0xFF009874);
  static const Color secondaryLight = Color(0xFF20D8B4);
  
  // Semantic Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
  static const Color info = Color(0xFF74B9FF);
  
  // Neutral Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFDFE6E9);
  static const Color border = Color(0xFFE1E8ED);
  static const Color inputBackground = Color(0xFFF5F6FA);
  
  // Status Colors
  static const Color statusDraft = Color(0xFF95A5A6);
  static const Color statusPending = Color(0xFFFDCB6E);
  static const Color statusConfirmed = Color(0xFF74B9FF);
  static const Color statusPaid = Color(0xFF00B894);
  static const Color statusCancelled = Color(0xFFFF7675);
}

class AppTextStyles {
  static const String fontFamily = 'Vazir';
  
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
      fontFamily: fontFamily,
    ),
  );
}
```

---

## 🌐 Network Layer

### dio_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.hivork.com/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'fa',
      },
    ),
  );
  
  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(ref),
    ErrorInterceptor(),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
    ),
  ]);
  
  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref ref;
  
  AuthInterceptor(this.ref);
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await ref.read(secureStorageProvider).read('access_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Get current business ID
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId != null) {
      options.headers['X-Business-ID'] = businessId;
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry request
        final opts = err.requestOptions;
        final response = await Dio().request(
          opts.path,
          options: Options(
            method: opts.method,
            headers: opts.headers,
          ),
          data: opts.data,
          queryParameters: opts.queryParameters,
        );
        handler.resolve(response);
      } else {
        // Logout user
        ref.read(authProvider.notifier).logout();
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }
  
  Future<bool> _refreshToken() async {
    // Implement token refresh logic
    return false;
  }
}
```

---

## 📦 Example Feature: Products

### product_model.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String businessId,
    required String name,
    required String slug,
    String? sku,
    String? barcode,
    String? description,
    required double price,
    double? costPrice,
    double? compareAtPrice,
    required bool trackInventory,
    required int stockQuantity,
    required int lowStockThreshold,
    @Default([]) List<ProductImage> images,
    String? thumbnailUrl,
    ProductCategory? category,
    @Default({}) Map<String, dynamic> attributes,
    required bool isActive,
    required bool isFeatured,
    @Default(0) int viewCount,
    @Default(0) int saleCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductModel;
  
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
    required String url,
    String? alt,
    required int order,
  }) = _ProductImage;
  
  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
}

@freezed
class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String id,
    required String name,
  }) = _ProductCategory;
  
  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
}
```

### product_repository.dart

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    required String businessId,
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    bool? isActive,
  });
  
  Future<Either<Failure, ProductEntity>> getProductById({
    required String businessId,
    required String productId,
  });
  
  Future<Either<Failure, ProductEntity>> createProduct({
    required String businessId,
    required Map<String, dynamic> data,
  });
  
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String businessId,
    required String productId,
    required Map<String, dynamic> data,
  });
  
  Future<Either<Failure, void>> deleteProduct({
    required String businessId,
    required String productId,
  });
  
  Future<Either<Failure, void>> adjustInventory({
    required String businessId,
    required String productId,
    required int quantity,
    required String reason,
  });
}
```

### product_list_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_list_provider.g.dart';

@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<ProductEntity>> build({
    required String businessId,
    String? search,
    String? categoryId,
  }) async {
    final repository = ref.read(productRepositoryProvider);
    
    final result = await repository.getProducts(
      businessId: businessId,
      search: search,
      categoryId: categoryId,
    );
    
    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(
      businessId: businessId,
      search: search,
      categoryId: categoryId,
    ));
  }
  
  Future<void> deleteProduct(String productId) async {
    final repository = ref.read(productRepositoryProvider);
    
    await repository.deleteProduct(
      businessId: businessId,
      productId: productId,
    );
    
    await refresh();
  }
}
```

### product_list_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  
  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  
  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(currentBusinessProvider)!.id;
    final productsAsync = ref.watch(productListProvider(
      businessId: businessId,
      search: _searchController.text,
      categoryId: _selectedCategoryId,
    ));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('محصولات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              controller: _searchController,
              hintText: 'جستجوی محصول...',
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyState(
                    title: 'محصولی یافت نشد',
                    message: 'محصول جدیدی اضافه کنید',
                    icon: Icons.inventory_2_outlined,
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.refresh(productListProvider(
                      businessId: businessId,
                      search: _searchController.text,
                      categoryId: _selectedCategoryId,
                    ).future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _navigateToDetail(product.id),
                        onDelete: () => _deleteProduct(product.id),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(productListProvider);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(),
        icon: const Icon(Icons.add),
        label: const Text('محصول جدید'),
      ),
    );
  }
  
  void _showFilterBottomSheet() {
    // Show category filter
  }
  
  void _navigateToDetail(String productId) {
    context.push('/products/$productId');
  }
  
  void _navigateToCreate() {
    context.push('/products/create');
  }
  
  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'حذف محصول',
      message: 'آیا از حذف این محصول اطمینان دارید؟',
    );
    
    if (confirmed) {
      await ref.read(productListProvider(
        businessId: businessId,
        search: _searchController.text,
        categoryId: _selectedCategoryId,
      ).notifier).deleteProduct(productId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('محصول با موفقیت حذف شد')),
        );
      }
    }
  }
}
```

---

## 🧪 Testing

### product_repository_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late ProductRepository repository;
  late MockProductRemoteDataSource mockRemoteDataSource;
  
  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockRemoteDataSource);
  });
  
  group('getProducts', () {
    test('should return products when call is successful', () async {
      // Arrange
      final products = [
        ProductModel(id: '1', name: 'Test Product'),
      ];
      
      when(() => mockRemoteDataSource.getProducts(any()))
          .thenAnswer((_) async => products);
      
      // Act
      final result = await repository.getProducts(businessId: 'test-id');
      
      // Assert
      expect(result.isRight(), true);
      verify(() => mockRemoteDataSource.getProducts(any())).called(1);
    });
  });
}
```

---

📅 **تاریخ**: 15 نوامبر 2025  
🔄 **نسخه**: 1.0  
📱 **پلتفرم**: Flutter 3.16+
