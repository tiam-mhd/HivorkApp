# راهنمای کامل پیاده‌سازی سیستم فاکتور - Hivork

## ✅ کارهای انجام شده

### Backend (100% تکمیل شده)
1. ✅ **Entity ها:**
   - `Invoice` - فاکتور اصلی با تمام فیلدهای مورد نیاز
   - `InvoiceItem` - اقلام فاکتور
   - `InvoicePayment` - پرداخت‌ها
   - `InvoiceExtraCost` - هزینه‌های اضافی

2. ✅ **DTOs:**
   - `CreateInvoiceDto` - ساخت فاکتور
   - `UpdateInvoiceDto` - ویرایش فاکتور
   - `FilterInvoiceDto` - فیلتر و جستجو
   - `CreatePaymentDto` - ثبت پرداخت
   - `CreateInvoiceItemDto` - اقلام فاکتور
   - `CreateInvoiceExtraCostDto` - هزینه‌های اضافی

3. ✅ **Service:**
   - ساخت فاکتور با محاسبات خودکار
   - لیست فاکتورها با فیلتر و صفحه‌بندی
   - جزئیات فاکتور
   - ویرایش فاکتور (فقط پیش‌نویس‌ها)
   - حذف فاکتور (فقط پیش‌نویس‌ها)
   - نهایی کردن فاکتور
   - لغو فاکتور
   - تبدیل پیش‌فاکتور به فاکتور فروش
   - ثبت پرداخت
   - حذف پرداخت
   - لیست پرداخت‌ها
   - گزارش خلاصه فروش

4. ✅ **Controller:**
   - تمام endpoint های مورد نیاز
   - Authentication و Authorization
   - Swagger Documentation

### Flutter (40% تکمیل شده)
1. ✅ **Models:**
   - کامل با تمام Enums
   - JSON Serialization
   - CopyWith Methods

## 🔨 کارهای باقیمانده

### فاز 1: Backend (باقیمانده)

#### 1. تست Backend
```bash
# راه‌اندازی بک‌اند
cd backend
npm run start:dev

# تست API ها با Thunder Client یا Postman
# فایل تست: backend/test.http
```

**API های مورد تست:**
- POST /api/invoices - ایجاد فاکتور
- GET /api/invoices - لیست فاکتورها
- GET /api/invoices/:id - جزئیات فاکتور
- PATCH /api/invoices/:id - ویرایش
- DELETE /api/invoices/:id - حذف
- POST /api/invoices/:id/finalize - نهایی کردن
- POST /api/invoices/:id/cancel - لغو
- POST /api/invoices/:id/payments - ثبت پرداخت
- GET /api/invoices/:id/payments - لیست پرداخت‌ها

### فاز 2: Flutter Services

#### 1. InvoiceService
مسیر: `mobile/lib/features/invoice/services/invoice_service.dart`

```dart
import 'package:dio/dio.dart';
import '../models/invoice.dart';
import '../../../core/services/api_service.dart';

class InvoiceService {
  final ApiService _apiService;

  InvoiceService(this._apiService);

  // دریافت لیست فاکتورها
  Future<Map<String, dynamic>> getInvoices({
    int page = 1,
    int limit = 20,
    String? search,
    InvoiceType? type,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    ShippingStatus? shippingStatus,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (type != null) 'type': type.value,
        if (status != null) 'status': status.value,
        if (paymentStatus != null) 'paymentStatus': paymentStatus.value,
        if (shippingStatus != null) 'shippingStatus': shippingStatus.value,
        if (customerId != null) 'customerId': customerId,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await _apiService.get(
        '/invoices',
        queryParameters: queryParams,
      );

      return {
        'data': (response.data['data'] as List)
            .map((json) => Invoice.fromJson(json))
            .toList(),
        'total': response.data['total'],
        'page': response.data['page'],
        'limit': response.data['limit'],
      };
    } catch (e) {
      rethrow;
    }
  }

  // ایجاد فاکتور
  Future<Invoice> createInvoice(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/invoices', data: data);
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // جزئیات فاکتور
  Future<Invoice> getInvoiceDetails(String id) async {
    try {
      final response = await _apiService.get('/invoices/$id');
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ویرایش فاکتور
  Future<Invoice> updateInvoice(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/invoices/$id', data: data);
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // حذف فاکتور
  Future<void> deleteInvoice(String id) async {
    try {
      await _apiService.delete('/invoices/$id');
    } catch (e) {
      rethrow;
    }
  }

  // نهایی کردن فاکتور
  Future<Invoice> finalizeInvoice(String id) async {
    try {
      final response = await _apiService.post('/invoices/$id/finalize');
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // لغو فاکتور
  Future<Invoice> cancelInvoice(String id, String? reason) async {
    try {
      final response = await _apiService.post(
        '/invoices/$id/cancel',
        data: {'reason': reason},
      );
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // تبدیل به فاکتور فروش
  Future<Invoice> convertToSales(String id) async {
    try {
      final response = await _apiService.post('/invoices/$id/convert-to-sales');
      return Invoice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ثبت پرداخت
  Future<InvoicePayment> addPayment(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/invoices/$id/payments', data: data);
      return InvoicePayment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // دریافت شماره فاکتور بعدی
  Future<String> getNextInvoiceNumber() async {
    try {
      final response = await _apiService.get('/invoices/next-number');
      return response.data['invoiceNumber'];
    } catch (e) {
      rethrow;
    }
  }

  // گزارش خلاصه
  Future<Map<String, dynamic>> getSummaryReport({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await _apiService.get(
        '/invoices/reports/summary',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
```

#### 2. InvoiceProvider (State Management)
مسیر: `mobile/lib/features/invoice/services/invoice_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../models/invoice.dart';
import 'invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _invoiceService;

  InvoiceProvider(this._invoiceService);

  // State
  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalInvoices = 0;

  // Getters
  List<Invoice> get invoices => _invoices;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalInvoices => _totalInvoices;

  // Load invoices with filters
  Future<void> loadInvoices({
    int page = 1,
    String? search,
    InvoiceType? type,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    ShippingStatus? shippingStatus,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _invoiceService.getInvoices(
        page: page,
        search: search,
        type: type,
        status: status,
        paymentStatus: paymentStatus,
        shippingStatus: shippingStatus,
      );

      _invoices = result['data'];
      _totalInvoices = result['total'];
      _currentPage = result['page'];
      _totalPages = (result['total'] / result['limit']).ceil();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load invoice details
  Future<void> loadInvoiceDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedInvoice = await _invoiceService.getInvoiceDetails(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create invoice
  Future<bool> createInvoice(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _invoiceService.createInvoice(data);
      await loadInvoices(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete invoice
  Future<bool> deleteInvoice(String id) async {
    try {
      await _invoiceService.deleteInvoice(id);
      await loadInvoices(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Finalize invoice
  Future<bool> finalizeInvoice(String id) async {
    try {
      final updated = await _invoiceService.finalizeInvoice(id);
      _selectedInvoice = updated;
      await loadInvoices(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add payment
  Future<bool> addPayment(String invoiceId, Map<String, dynamic> data) async {
    try {
      await _invoiceService.addPayment(invoiceId, data);
      await loadInvoiceDetails(invoiceId); // Refresh details
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### فاز 3: Flutter Screens

#### Dependencies مورد نیاز
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Network
  dio: ^5.4.0
  
  # Date & Time
  persian_datetime_picker: ^2.7.0
  shamsi_date: ^1.0.1
  intl: ^0.18.1
  
  # UI Components
  flutter_slidable: ^3.0.1
  shimmer: ^3.0.0
  
  # PDF
  pdf: ^3.10.7
  printing: ^5.12.0
  
  # Other
  uuid: ^4.2.2
```

#### 1. InvoiceListScreen
مسیر: `mobile/lib/features/invoice/screens/invoice_list_screen.dart`

**ویژگی‌ها:**
- لیست فاکتورها با Card های زیبا
- جستجو در شماره فاکتور و نام مشتری
- فیلتر بر اساس نوع، وضعیت، پرداخت، ارسال
- Pagination (صفحه‌بندی)
- Pull to refresh
- دکمه Float برای افزودن فاکتور جدید
- عملیات: مشاهده، ویرایش، حذف، نهایی کردن

**طراحی UI:**
```
┌─────────────────────────────────┐
│  🧾 فاکتورها         [🔍] [⚙️]  │
├─────────────────────────────────┤
│  [فروش] [پیش‌فاکتور] [همه]      │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ #202411-INV-0001            │ │
│ │ 👤 علی احمدی                │ │
│ │ 📅 1404/09/02  💰 5,000,000 │ │
│ │ ✅ پرداخت شده  📦 ارسال شده │ │
│ └─────────────────────────────┘ │
│                                 │
│ [Pagination]                    │
└─────────────────────────────────┘
        [+] افزودن فاکتور
```

#### 2. InvoiceTypeSelectionScreen
مسیر: `mobile/lib/features/invoice/screens/invoice_type_selection_screen.dart`

**طراحی:**
- Bottom Sheet یا صفحه جدید
- دو کارت بزرگ برای فاکتور فروش و پیش‌فاکتور
- توضیح مختصر هر کدام

#### 3. PersianDatePickerScreen
پکیج: `persian_datetime_picker`

```dart
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

Future<Jalali?> showPersianDatePicker(BuildContext context) async {
  return await showPersianDatePicker(
    context: context,
    initialDate: Jalali.now(),
    firstDate: Jalali(1400, 1),
    lastDate: Jalali(1410, 12),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
          ),
        ),
        child: child!,
      );
    },
  );
}
```

#### 4. CustomerSelectionScreen
مسیر: `mobile/lib/features/customer/screens/customer_selection_screen.dart`

**ویژگی‌ها:**
- لیست مشتریان با جستجو
- نمایش اطلاعات خلاصه (نام، تلفن، بدهی)
- انتخاب با تپ
- دکمه افزودن مشتری جدید

#### 5. ProductSelectionScreen
مسیر: `mobile/lib/features/product/screens/product_selection_screen.dart`

**ویژگی‌ها:**
- لیست محصولات و تنوع‌ها
- برای محصولات با تنوع: نمایش تنوع‌ها به جای محصول اصلی
- جستجو
- انتخاب چندتایی با Counter
- نمایش قیمت هر آیتم
- دکمه تایید و بازگشت

**طراحی:**
```
┌─────────────────────────────────┐
│  انتخاب محصولات      [✓] تایید  │
├─────────────────────────────────┤
│  [🔍 جستجو...]                  │
├─────────────────────────────────┤
│ ☑️ لپ‌تاپ ایسوس X550          │
│    18,000,000 ریال              │
│    [-] 2 [+]                    │
├─────────────────────────────────┤
│ ☐ کیبورد لاجیتک K120          │
│    250,000 ریال                 │
│    [-] 0 [+]                    │
└─────────────────────────────────┘
```

#### 6. CreateInvoiceScreen
مسیر: `mobile/lib/features/invoice/screens/create_invoice_screen.dart`

**ویژگی‌ها:**
- Step by step wizard یا یک صفحه طولانی با Scroll
- انتخاب تاریخ با date picker
- انتخاب مشتری
- انتخاب محصولات
- جدول اقلام با امکان ویرایش تعداد
- کارت محاسبات (جمع، تخفیف، مالیات، هزینه اضافی)
- Toggle های تخفیف، مالیات، هزینه اضافی
- انتخاب وضعیت پرداخت و ارسال (برای فاکتور فروش)
- فیلد توضیحات
- دکمه‌های ذخیره پیش‌نویس و نهایی کردن

**طراحی:**
```
┌─────────────────────────────────┐
│  ← ایجاد فاکتور         [ذخیره] │
├─────────────────────────────────┤
│  📅 تاریخ: 1404/09/02 [📅]      │
│  👤 مشتری: علی احمدی [انتخاب]  │
├─────────────────────────────────┤
│  📦 اقلام فاکتور        [افزودن]│
│  ┌────────────────────────────┐ │
│  │ لپ‌تاپ ایسوس              │ │
│  │ 2 × 18,000,000            │ │
│  │ = 36,000,000     [🗑️] [✏️] │ │
│  └────────────────────────────┘ │
├─────────────────────────────────┤
│  💰 محاسبات                     │
│  جمع مبلغ: 36,000,000           │
│  🎁 تخفیف: [Toggle] [10%] [✏️] │
│  📊 مالیات (9%): 3,240,000      │
│  💸 هزینه اضافی: [Toggle] [+]  │
│  ──────────────────────────────  │
│  مبلغ نهایی: 39,240,000         │
├─────────────────────────────────┤
│  💳 وضعیت پرداخت: [انتخاب]     │
│  📦 وضعیت ارسال: [انتخاب]      │
│  📝 توضیحات: [...]              │
└─────────────────────────────────┘
```

#### 7. InvoiceDetailScreen
مسیر: `mobile/lib/features/invoice/screens/invoice_detail_screen.dart`

**ویژگی‌ها:**
- نمایش کامل اطلاعات فاکتور
- اطلاعات مشتری
- جدول اقلام
- محاسبات
- وضعیت‌ها
- لیست پرداخت‌ها (برای فاکتور فروش)
- دکمه‌های عملیات: ویرایش، حذف، PDF، اشتراک‌گذاری
- برای پیش‌فاکتور: دکمه تبدیل به فاکتور فروش

### فاز 4: Widgets

#### 1. InvoiceCard
مسیر: `mobile/lib/features/invoice/widgets/invoice_card.dart`

**ویژگی‌ها:**
- نمایش خلاصه فاکتور
- Badge های وضعیت با رنگ‌های مختلف
- قابل تپ برای باز کردن جزئیات
- Slidable برای عملیات سریع

#### 2. InvoiceItemTable
مسیر: `mobile/lib/features/invoice/widgets/invoice_item_table.dart`

**ویژگی‌ها:**
- جدول اقلام
- نمایش نام، تعداد، قیمت واحد، جمع
- امکان ویرایش تعداد (در حالت ویرایش)

#### 3. InvoiceCalculationPanel
مسیر: `mobile/lib/features/invoice/widgets/invoice_calculation_panel.dart`

**ویژگی‌ها:**
- نمایش محاسبات
- جمع، تخفیف، مالیات، هزینه اضافی، مبلغ نهایی
- Expandable برای جزئیات

#### 4. InvoiceStatusBadge
مسیر: `mobile/lib/features/invoice/widgets/invoice_status_badge.dart`

**ویژگی‌ها:**
- Badge با رنگ و آیکون مناسب
- برای تمام نوع وضعیت‌ها

#### 5. PaymentMethodSelector
مسیر: `mobile/lib/features/invoice/widgets/payment_method_selector.dart`

**ویژگی‌ها:**
- BottomSheet یا Dialog
- لیست روش‌های پرداخت با آیکون

#### 6. DiscountInput
مسیر: `mobile/lib/features/invoice/widgets/discount_input.dart`

**ویژگی‌ها:**
- Toggle برای فعال/غیرفعال
- انتخاب نوع (درصد/مبلغ)
- Input برای مقدار

### فاز 5: PDF Generation

#### پکیج‌های مورد نیاز
```yaml
dependencies:
  pdf: ^3.10.7
  printing: ^5.12.0
```

#### InvoicePdfService
مسیر: `mobile/lib/features/invoice/services/invoice_pdf_service.dart`

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';

class InvoicePdfService {
  Future<void> generateAndPreview(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'فاکتور ${invoice.type.label}',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('شماره: ${invoice.invoiceNumber}'),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Customer Info
              pw.Text('مشتری: ${invoice.customerName ?? ""}'),
              pw.Text('تاریخ: ${invoice.issueDate}'),
              pw.SizedBox(height: 20),
              
              // Items Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    children: [
                      pw.Text('ردیف'),
                      pw.Text('محصول'),
                      pw.Text('تعداد'),
                      pw.Text('قیمت واحد'),
                      pw.Text('جمع'),
                    ],
                  ),
                  // Items
                  ...invoice.items.asMap().entries.map((entry) {
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Text('${entry.key + 1}'),
                        pw.Text(item.productName),
                        pw.Text('${item.quantity}'),
                        pw.Text('${item.unitPrice}'),
                        pw.Text('${item.totalPrice}'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('جمع مبلغ: ${invoice.subtotal}'),
                      pw.Text('تخفیف: ${invoice.discountAmount}'),
                      pw.Text('مالیات: ${invoice.taxAmount}'),
                      pw.Divider(),
                      pw.Text(
                        'مبلغ نهایی: ${invoice.totalAmount}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
```

### فاز 6: Testing

#### Backend Testing
```bash
# تست با npm scripts
npm test

# تست manual با Thunder Client
# فایل: backend/test.http
```

#### Flutter Testing
```bash
# Unit Tests
flutter test

# Integration Tests
flutter test integration_test/

# Widget Tests
flutter test test/widgets/
```

### نکات مهم UI/UX

#### تم و رنگ‌ها
```dart
// پالت رنگی
const primaryColor = Color(0xFF4CAF50);     // سبز
const errorColor = Color(0xFFF44336);       // قرمز
const warningColor = Color(0xFFFF9800);     // نارنجی
const infoColor = Color(0xFF2196F3);        // آبی

// Dark Mode
final darkTheme = ThemeData.dark().copyWith(
  // ...
);

// Light Mode
final lightTheme = ThemeData.light().copyWith(
  // ...
);
```

#### Font
```yaml
# pubspec.yaml
fonts:
  - family: IRANSans
    fonts:
      - asset: assets/fonts/IRANSans-Regular.ttf
      - asset: assets/fonts/IRANSans-Bold.ttf
        weight: 700
```

#### Spacing
```dart
// استاندارد spacing
const kSpacingSmall = 8.0;
const kSpacingMedium = 16.0;
const kSpacingLarge = 24.0;

// Border Radius
const kBorderRadius = 12.0;
```

#### Animation
```dart
// Duration
const kAnimationDuration = Duration(milliseconds: 300);
const kAnimationDurationFast = Duration(milliseconds: 150);

// Curves
const kAnimationCurve = Curves.easeInOut;
```

## 📝 نکات نهایی

### 1. Error Handling
همیشه error handling مناسب داشته باشید:
```dart
try {
  // API call
} on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    // Not found
  } else if (e.response?.statusCode == 400) {
    // Bad request
  }
} catch (e) {
  // General error
}
```

### 2. Loading States
از Shimmer برای loading استفاده کنید:
```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(...),
)
```

### 3. Empty States
برای لیست خالی UI زیبا داشته باشید:
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.receipt_long, size: 64),
      Text('هنوز فاکتوری ثبت نشده'),
      ElevatedButton(
        onPressed: () {},
        child: Text('ایجاد فاکتور اول'),
      ),
    ],
  ),
)
```

### 4. Validation
تمام ورودی‌ها را validate کنید:
```dart
final formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'این فیلد الزامی است';
    }
    return null;
  },
)
```

### 5. Navigation
از Named Routes استفاده کنید:
```dart
// routes.dart
static const invoiceList = '/invoices';
static const invoiceCreate = '/invoices/create';
static const invoiceDetail = '/invoices/:id';
```

## 🚀 اولویت‌بندی پیاده‌سازی

### هفته 1
1. تست کامل Backend
2. InvoiceService و Provider
3. InvoiceListScreen (ساده)

### هفته 2
4. CustomerSelectionScreen
5. ProductSelectionScreen
6. CreateInvoiceScreen (فرم اولیه)

### هفته 3
7. InvoiceDetailScreen
8. تمام Widgets
9. PDF Generator

### هفته 4
10. Polish و Refactor
11. Testing
12. Bug Fixes

## 📚 منابع

- [NestJS Documentation](https://docs.nestjs.com/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Persian DateTime Picker](https://pub.dev/packages/persian_datetime_picker)
- [PDF Package](https://pub.dev/packages/pdf)
- [Printing Package](https://pub.dev/packages/printing)

---

**موفق باشید! 🎉**
