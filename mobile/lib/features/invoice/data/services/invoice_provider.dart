import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/invoice.dart';
import 'invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _invoiceService;
  String? _businessId;

  InvoiceProvider(this._invoiceService);

  // State
  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalInvoices = 0;
  
  // Filters
  String? _searchQuery;
  InvoiceType? _filterType;
  InvoiceStatus? _filterStatus;
  PaymentStatus? _filterPaymentStatus;
  ShippingStatus? _filterShippingStatus;

  // Getters
  String? get businessId => _businessId;
  List<Invoice> get invoices => _invoices;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalInvoices => _totalInvoices;
  String? get searchQuery => _searchQuery;
  InvoiceType? get filterType => _filterType;
  InvoiceStatus? get filterStatus => _filterStatus;
  PaymentStatus? get filterPaymentStatus => _filterPaymentStatus;
  ShippingStatus? get filterShippingStatus => _filterShippingStatus;
  bool get hasMore => _currentPage < _totalPages;

  /// تنظیم businessId
  void setBusinessId(String businessId) {
    _businessId = businessId;
  }

  /// بارگذاری فاکتورها با فیلتر
  Future<void> loadInvoices({
    bool refresh = false,
    String? search,
    InvoiceType? type,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    ShippingStatus? shippingStatus,
  }) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _invoices = [];
    }

    _isLoading = true;
    _error = null;
    
    // Update filters
    _searchQuery = search;
    _filterType = type;
    _filterStatus = status;
    _filterPaymentStatus = paymentStatus;
    _filterShippingStatus = shippingStatus;
    
    notifyListeners();

    try {
      final result = await _invoiceService.getInvoices(
        businessId: _businessId!,
        page: _currentPage,
        search: _searchQuery,
        type: _filterType,
        status: _filterStatus,
        paymentStatus: _filterPaymentStatus,
        shippingStatus: _filterShippingStatus,
      );

      if (refresh) {
        _invoices = result['data'];
      } else {
        _invoices.addAll(result['data']);
      }
      _totalInvoices = result['total'];
      _currentPage = result['page'];
      _totalPages = (result['total'] / result['limit']).ceil();
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// بارگذاری صفحه بعدی
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _businessId == null) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final result = await _invoiceService.getInvoices(
        businessId: _businessId!,
        page: _currentPage,
        search: _searchQuery,
        type: _filterType,
        status: _filterStatus,
        paymentStatus: _filterPaymentStatus,
        shippingStatus: _filterShippingStatus,
      );

      _invoices.addAll(result['data']);
      _totalInvoices = result['total'];
    } catch (e) {
      _error = _getErrorMessage(e);
      _currentPage--; // برگشت به صفحه قبل در صورت خطا
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// جستجو
  Future<void> search(String query) async {
    await loadInvoices(refresh: true, search: query);
  }

  /// اعمال فیلترها
  Future<void> applyFilters({
    InvoiceType? type,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    ShippingStatus? shippingStatus,
  }) async {
    await loadInvoices(
      refresh: true,
      type: type,
      status: status,
      paymentStatus: paymentStatus,
      shippingStatus: shippingStatus,
    );
  }

  /// پاک کردن فیلترها
  Future<void> clearFilters() async {
    _searchQuery = null;
    _filterType = null;
    _filterStatus = null;
    _filterPaymentStatus = null;
    _filterShippingStatus = null;
    await loadInvoices(refresh: true);
  }

  /// بارگذاری جزئیات فاکتور
  Future<void> loadInvoiceDetails(String id) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedInvoice = await _invoiceService.getInvoiceDetails(
        id: id,
        businessId: _businessId!,
      );
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ایجاد فاکتور جدید
  Future<bool> createInvoice(Map<String, dynamic> data) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _invoiceService.createInvoice(
        businessId: _businessId!,
        data: data,
      );
      await loadInvoices(refresh: true);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ویرایش فاکتور
  Future<bool> updateInvoice(String id, Map<String, dynamic> data) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _invoiceService.updateInvoice(
        id: id,
        businessId: _businessId!,
        data: data,
      );
      _selectedInvoice = updated;
      await loadInvoices(refresh: true);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف فاکتور
  Future<bool> deleteInvoice(String id) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    try {
      await _invoiceService.deleteInvoice(
        id: id,
        businessId: _businessId!,
      );
      await loadInvoices(refresh: true);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// نهایی کردن فاکتور
  Future<bool> finalizeInvoice(String id) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _invoiceService.finalizeInvoice(
        id: id,
        businessId: _businessId!,
      );
      _selectedInvoice = updated;
      await loadInvoices(refresh: true);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// لغو فاکتور
  Future<bool> cancelInvoice(String id, String? reason) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _invoiceService.cancelInvoice(
        id: id,
        businessId: _businessId!,
        reason: reason,
      );
      _selectedInvoice = updated;
      await loadInvoices(refresh: true);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تبدیل به فاکتور فروش
  Future<bool> convertToSales(String id) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _invoiceService.convertToSales(
        id: id,
        businessId: _businessId!,
      );
      _selectedInvoice = updated;
      await loadInvoices(refresh: true);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ثبت پرداخت
  Future<bool> addPayment(String invoiceId, Map<String, dynamic> data) async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _invoiceService.addPayment(
        id: invoiceId,
        businessId: _businessId!,
        data: data,
      );
      await loadInvoiceDetails(invoiceId);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// دریافت شماره فاکتور بعدی
  Future<String?> getNextInvoiceNumber() async {
    if (_businessId == null) {
      _error = 'کسب‌وکار انتخاب نشده است';
      notifyListeners();
      return null;
    }

    try {
      return await _invoiceService.getNextInvoiceNumber(
        businessId: _businessId!,
      );
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// پاک کردن خطا
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// پاک کردن فاکتور انتخاب شده
  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }

  /// استخراج پیام خطا
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response!.data is Map) {
        final message = error.response!.data['message'];
        // Handle both String and List<String> messages
        if (message is String) {
          return message;
        } else if (message is List) {
          return message.join('\n');
        }
        return 'خطای ناشناخته';
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'زمان اتصال به سرور به پایان رسید';
        case DioExceptionType.connectionError:
          return 'خطا در اتصال به سرور';
        case DioExceptionType.badResponse:
          return 'پاسخ نامعتبر از سرور';
        default:
          return 'خطای ناشناخته';
      }
    }
    return error.toString();
  }
}
